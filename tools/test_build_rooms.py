#!/usr/bin/env python3
"""Unit tests of tools/build_rooms.py. Run: python3 -m unittest tools/test_build_rooms.py

The round trip compiles tests/fixtures/rooms/ow_0_1.room with the real world data and compares the node
list with tests/fixtures/rooms/expected_ow_0_1.tscn (the hand-made scene of the same room). The other tests
change that fixture, or build a small synthetic world, and check that the compiler rejects the change.
"""

from __future__ import annotations

import contextlib
import io
import json
import re
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import build_rooms as br  # noqa: E402

FIXTURES = br.ROOT / "tests" / "fixtures" / "rooms"
FIXTURE_ROOM = FIXTURES / "ow_0_1.room"
EXPECTED_SCENE = FIXTURES / "expected_ow_0_1.tscn"
SHOP_FIXTURE = FIXTURES / "shop.room"


def node_list(text: str) -> list[str]:
    """Node headers and properties with ExtResource ids replaced by their paths (ids differ by writer)."""
    ext = {ident: path for _, path, ident in re.findall(r'\[ext_resource type="(\w+)" path="([^"]+)" id="(\d+)"\]', text)}
    out = []
    for line in text.splitlines():
        if line.startswith("[node") or re.match(r"^\w+ = ", line):
            out.append(re.sub(r'ExtResource\("(\d+)"\)', lambda m: "RES(" + ext[m.group(1)] + ")", line))
    return out


def emitted_nodes(text: str) -> dict[tuple[str, ...], dict[str, object]]:
    """Read emitted node parents, instance resources and properties for path-resolution checks."""
    ext = {ident: path for _, path, ident in re.findall(r'\[ext_resource type="(\w+)" path="([^"]+)" id="(\d+)"\]', text)}
    nodes: dict[tuple[str, ...], dict[str, object]] = {}
    root: tuple[str, ...] = ()
    current: dict[str, object] | None = None
    for line in text.splitlines():
        if line.startswith('[node name='):
            name_match = re.search(r'\[node name="([^"]+)"', line)
            assert name_match is not None, line
            parent_match = re.search(r' parent="([^"]+)"', line)
            instance_match = re.search(r' instance=ExtResource\("(\d+)"\)', line)
            name = name_match.group(1)
            if parent_match is None:
                root = (name,)
                path = root
            else:
                parent = parent_match.group(1)
                path = root + (() if parent == "." else tuple(parent.split("/"))) + (name,)
            current = {
                "parent": parent_match.group(1) if parent_match else "",
                "scene": ext.get(instance_match.group(1)) if instance_match else None,
                "properties": [],
            }
            nodes[path] = current
        elif current is not None and " = " in line:
            current["properties"].append(line.strip())
    return nodes


def resolve_emitted_path(start: tuple[str, ...], path: str,
                         nodes: dict[tuple[str, ...], dict[str, object]]) -> tuple[str, ...]:
    """Resolve a generated relative NodePath against the parsed emitted hierarchy."""
    current = start
    for segment in path.split("/"):
        if segment == "..":
            current = current[:-1]
        elif segment not in ("", "."):
            current += (segment,)
        assert current in nodes, f"{path!r} from {start!r} does not resolve at {current!r}"
    return current


def real_world() -> br.World:
    world = json.loads(br.WORLD_FILE.read_text(encoding="utf-8"))
    prices = json.loads(br.SHOP_PRICES_FILE.read_text(encoding="utf-8"))
    return br.World(world, prices, json.loads(br.GRAPH_FILE.read_text(encoding="utf-8")))


def fixture_lines() -> list[str]:
    return FIXTURE_ROOM.read_text(encoding="utf-8").split("\n")


def with_grid_char(lines: list[str], col: int, row: int, char: str) -> str:
    """The fixture with one grid character changed (grid rows follow the 'grid' line)."""
    start = lines.index("grid") + 1
    rows = list(lines)
    line = rows[start + row]
    rows[start + row] = line[:col] + char + line[col + 1 :]
    return "\n".join(rows)


def compile_text(text: str, world: br.World, name: str = "ow_0_1.room") -> tuple[str | None, list[str]]:
    """Compiles room text from a temporary file named `name` (the file name gives the room id)."""
    with tempfile.TemporaryDirectory() as tmp:
        path = Path(tmp) / name
        path.write_text(text, encoding="utf-8")
        return br.compile_room(path, world)


def world_of(rooms: list[dict], pockets: list[dict] | None = None, pickups: list[dict] | None = None,
             edges: list[dict] | None = None, items: dict | None = None, prices: dict | None = None) -> br.World:
    return br.World({
        "rooms": rooms,
        "pockets": pockets or [],
        "pickups": pickups or [],
        "edges": edges or [],
        "items": items or {},
    }, prices)


def room_record(room_id: str, exits: list[str], enemies: dict | None = None, grid=(5, 5)) -> dict:
    return {"id": room_id, "grid": list(grid), "exits": exits, "dark": False, "scope": "ow",
            "enemies": enemies or {}, "scene": "", "region": "x", "name": "x"}


def open_grid(exits: list[str]) -> list[str]:
    grid = [["#" if c in (0, 19) or r in (0, 9) else "." for c in range(20)] for r in range(10)]
    for side in exits:
        for col, row in br.GAP_TILES[side]:
            grid[row][col] = "."
    return ["".join(row) for row in grid]


def room_text(room_id: str, exits: list[str], entity: str) -> str:
    return "\n".join([f"room {room_id}", "grid", *open_grid(exits), entity]) + "\n"


class PocketDarkness(unittest.TestCase):
    def world(self, scope: str, host_dark: bool, override: bool | None = None,
              graph_override: bool | None = None, host_scope: str | None = None) -> br.World:
        host = dict(room_record("host", []), scope=host_scope or scope, dark=host_dark)
        pocket = dict(id="host#cache", host="host", grid=[26, 30], in_place=False, scope=scope)
        if override is not None:
            pocket["dark"] = override
        data = dict(rooms=[host], pockets=[pocket], edges=[], pickups=[], items={})
        node = dict(id=pocket["id"])
        if graph_override is not None:
            node["dark"] = graph_override
        return br.World(data, graph={"nodes": [node]})

    def test_matching_cave_pocket_inherits_host_darkness(self) -> None:
        for dark in (False, True):
            world = self.world("c1", dark)
            record = world.room("host#cache")
            self.assertIs(record["dark"], dark)
            self.assertEqual(record["scope"], "c1")
            self.assertEqual(record["grid"], (26, 30))
            self.assertEqual(record["host"], "host")

    def test_explicit_pocket_darkness_wins(self) -> None:
        for dark in (False, True):
            self.assertIs(self.world("c1", not dark, override=dark).room("host#cache")["dark"], dark)
            self.assertIs(self.world("c1", not dark, graph_override=dark).room("host#cache")["dark"], dark)
        self.assertIs(self.world("c1", True, override=False, graph_override=True)
                      .room("host#cache")["dark"], False)

    def test_overworld_and_mismatched_scope_keep_bright_default(self) -> None:
        for scope, host_scope in (("ow", "ow"), ("c1", "c2")):
            self.assertIs(self.world(scope, True, host_scope=host_scope).room("host#cache")["dark"], False)

    def test_actual_crack_compiles_dark_and_overworld_shop_is_unchanged(self) -> None:
        world = real_world()
        pocket = world.room("cave_1_6#crack")
        self.assertIs(pocket["dark"], True)
        source = room_text(pocket["id"], [], "cache 10,3 id=cache_cave_1_6")
        text, errors = compile_text(source, world, "cave_1_6__crack.room")
        self.assertEqual(errors, [])
        self.assertIn("dark = true", text)
        shop = world.room("ow_1_2#shop")
        self.assertIs(shop["dark"], False)
        self.assertEqual(shop["scope"], "ow")


class RoundTrip(unittest.TestCase):
    def test_ow_0_1_matches_the_hand_made_scene(self) -> None:
        text, errors = compile_text(FIXTURE_ROOM.read_text(encoding="utf-8"), real_world())
        self.assertEqual(errors, [])
        assert text is not None
        self.assertEqual(node_list(text), node_list(EXPECTED_SCENE.read_text(encoding="utf-8")))

    def test_output_is_deterministic(self) -> None:
        source = FIXTURE_ROOM.read_text(encoding="utf-8")
        first, _ = compile_text(source, real_world())
        second, _ = compile_text(source, real_world())
        self.assertEqual(first, second)


class PersistentIdAliases(unittest.TestCase):
    def test_dev_room_writes_its_legacy_pickup_id(self) -> None:
        pickup_id = "wick_core_ow_2_0"
        world = world_of(
            [room_record("ow_2_0", [])],
            pickups=[{"id": pickup_id, "kind": "wick_core", "node": "ow_2_0"}],
        )
        text, errors = compile_text(
            room_text("ow_2_0", [], f"pickup wick_core 5,5 id={pickup_id}"), world, "ow_2_0.room"
        )
        self.assertEqual(errors, [])
        self.assertIn('persistent_id = &"wick_core_cache"', text or "")

    def test_non_dev_room_keeps_its_graph_pickup_id(self) -> None:
        pickup_id = "wick_core_ow_5_5"
        world = world_of(
            [room_record("ow_5_5", [])],
            pickups=[{"id": pickup_id, "kind": "wick_core", "node": "ow_5_5"}],
        )
        text, errors = compile_text(
            room_text("ow_5_5", [], f"pickup wick_core 5,5 id={pickup_id}"), world, "ow_5_5.room"
        )
        self.assertEqual(errors, [])
        self.assertIn(f'persistent_id = &"{pickup_id}"', text or "")


class FixtureRejections(unittest.TestCase):
    """Each change to the ow_0_1 fixture must fail with its own message."""

    def assert_rejected(self, text: str, message: str) -> None:
        result, errors = compile_text(text, real_world())
        self.assertIsNone(result)
        self.assertTrue(any(message in e for e in errors), f"{message!r} not in {errors}")

    def test_blocked_north_corridor(self) -> None:
        # (9,2) is inside the three-deep corridor in front of the north gap.
        self.assert_rejected(with_grid_char(fixture_lines(), 9, 2, "#"), "exit n corridor blocked at tile (9, 2)")

    def test_gap_missing_for_graph_exit(self) -> None:
        self.assert_rejected(with_grid_char(fixture_lines(), 19, 4, "#"), "graph exit e needs a gap")

    def test_gap_where_graph_has_no_exit(self) -> None:
        self.assert_rejected(with_grid_char(fixture_lines(), 0, 4, "."), "the graph has no exit w")

    def test_unknown_grid_character(self) -> None:
        self.assert_rejected(with_grid_char(fixture_lines(), 1, 1, "x"), "unknown grid character")

    def test_enemy_count_differs_from_graph(self) -> None:
        text = "\n".join(fixture_lines()) + "\nenemy duskmoth 3,3\n"
        self.assert_rejected(text, "enemies")

    def test_unknown_monster_scene_is_reported(self) -> None:
        text = FIXTURE_ROOM.read_text(encoding="utf-8").replace("enemy duskmoth 8,8", "enemy wraith 8,8")
        self.assert_rejected(text, "scenes/enemies/wraith.tscn does not exist")

    def test_graph_pickup_must_be_placed(self) -> None:
        text = "\n".join(line for line in fixture_lines() if "tether_moth" not in line)
        self.assert_rejected(text, "graph pickup tether_moth (item) is not placed")

    def test_room_id_must_match_the_file(self) -> None:
        text = FIXTURE_ROOM.read_text(encoding="utf-8").replace("room ow_0_1", "room ow_0_2")
        self.assert_rejected(text, "room is ow_0_2, the file is ow_0_1")

    def test_in_place_pocket_has_no_scene_of_its_own(self) -> None:
        source = FIXTURE_ROOM.read_text(encoding="utf-8").replace("room ow_0_1", "room ow_2_0#cache")
        result, errors = compile_text(source, real_world(), "ow_2_0__cache.room")
        self.assertIsNone(result)
        self.assertTrue(any("opens in place" in e for e in errors), errors)

    def test_entity_before_grid_is_an_error(self) -> None:
        text = "room ow_0_1\nenemy duskmoth 2,2\n" + FIXTURE_ROOM.read_text(encoding="utf-8")
        self.assert_rejected(text, "comes before the grid block")


class SyntheticRooms(unittest.TestCase):
    """A 20x10 room with a sealed box (ow_5_5#cache, in place) closed by a cracked wall at (12,2)."""

    def box_grid(self, gaps: list[tuple[int, int]]) -> list[str]:
        grid = [["#" if c in (0, 19) or r in (0, 9) else "." for c in range(20)] for r in range(10)]
        grid[4][0] = grid[5][0] = "."  # the one graph exit, west
        for c in range(12, 19):
            grid[1][c] = grid[4][c] = "#"
        for r in range(1, 5):
            grid[r][12] = grid[r][18] = "#"
        for c, r in gaps:
            grid[r][c] = "."
        return ["".join(row) for row in grid]

    def room_text(self, gaps, extra: str) -> str:
        return "\n".join(["room ow_5_5", "grid", *self.box_grid(gaps), "pickup wick_core 15,2 id=wick_core_cache", extra]) + "\n"

    def world(self, enemies: dict | None = None, pickups: bool = True) -> br.World:
        return world_of(
            [room_record("ow_5_5", ["w"], enemies)],
            pockets=[{"id": "ow_5_5#cache", "host": "ow_5_5", "grid": [0, 30], "in_place": True, "scope": "ow"}],
            pickups=[{"id": "wick_core_cache", "kind": "wick_core", "node": "ow_5_5#cache"}] if pickups else [],
            edges=[{"id": "e1", "a": "ow_5_5", "b": "ow_5_5#cache", "link": "door", "gate": "bomb",
                    "needs": ["pitch_pot"], "dir": "both", "key": None, "prop": "cracked wall"}],
        )

    def test_sealed_box_with_one_cracked_wall_compiles(self) -> None:
        text, errors = compile_text(self.room_text([(12, 2)], "opener cracked_wall 12,2 id=cache_wall"),
                                    self.world(), "ow_5_5.room")
        self.assertEqual(errors, [])
        self.assertIn('wall_id = &"cache_wall"', text or "")

    def test_open_box_is_rejected(self) -> None:
        _, errors = compile_text(self.room_text([(12, 2)], ""), self.world(), "ow_5_5.room")
        self.assertTrue(any("sealed pickup wick_core_cache is reachable while closed" in e for e in errors), errors)

    def test_two_openers_are_rejected(self) -> None:
        extra = "opener cracked_wall 12,2 id=cache_wall\nopener cracked_wall 15,4 id=cache_other"
        _, errors = compile_text(self.room_text([(12, 2), (15, 4)], extra), self.world(), "ow_5_5.room")
        self.assertTrue(any("needs exactly one opener, found 2" in e for e in errors), errors)

    def test_hollow_off_tile_centre_is_rejected(self) -> None:
        extra = "enemy hollow @100,100"
        _, errors = compile_text(self.room_text([(12, 2)], "opener cracked_wall 12,2 id=cache_wall\n" + extra),
                                 self.world({"hollow": 1}, pickups=True), "ow_5_5.room")
        self.assertTrue(any("hollow is not on a tile centre" in e for e in errors), errors)

    def test_missing_pickup_in_sealed_box_is_rejected(self) -> None:
        text = self.room_text([(12, 2)], "opener cracked_wall 12,2 id=cache_wall").replace(
            "pickup wick_core 15,2 id=wick_core_cache\n", "")
        _, errors = compile_text(text, self.world(), "ow_5_5.room")
        self.assertTrue(any("graph pickup wick_core_cache" in e for e in errors), errors)


class Scopes(unittest.TestCase):
    """A key and a locked door take the scope of their room (decision 3): cave keys are c1 .. c10."""

    def test_small_key_in_a_cave_takes_the_cave_scope(self) -> None:
        world = world_of(
            [dict(room_record("cave_5_2", []), scope="c5")],
            pickups=[{"id": "cave_key", "kind": "small_key", "node": "cave_5_2"}],
        )
        text = "\n".join(["room cave_5_2", "grid", *(["#" * 20] + ["#" + "." * 18 + "#"] * 8 + ["#" * 20]),
                           "pickup small_key 3,3 id=cave_key"]) + "\n"
        result, errors = compile_text(text, world, "cave_5_2.room")
        self.assertEqual(errors, [])
        self.assertIn('scope = &"c5"', result or "")

    def test_locked_door_in_a_cave_takes_the_cave_scope(self) -> None:
        world = world_of([dict(room_record("cave_5_2", []), scope="c5")])
        text = "\n".join(["room cave_5_2", "grid", *(["#" * 20] + ["#" + "." * 18 + "#"] * 8 + ["#" * 20]),
                           "opener locked_door 5,5 id=cave_lock"]) + "\n"
        result, errors = compile_text(text, world, "cave_5_2.room")
        self.assertEqual(errors, [])
        self.assertIn('scope = &"c5"', result or "")


class PropKinds(unittest.TestCase):
    def test_visual_offset_changes_only_presentation(self) -> None:
        world = world_of([room_record("ow_5_5", [])])
        source = room_text("ow_5_5", [], "prop hut 5,5 size=192,96")
        original, errors = compile_text(source, world, "ow_5_5.room")
        self.assertEqual(errors, [])
        for value in ("-64,84", "0,0"):
            result, errors = compile_text(source.rstrip() + f" visual_offset={value}\n", world, "ow_5_5.room")
            self.assertEqual(errors, [])
            expected = original
            if value != "0,0":
                expected = original.replace('kind = &"hut"', 'kind = &"hut"\nvisual_offset = Vector2(-64, 84)')
            self.assertEqual(result, expected)
            again, _ = compile_text(source.rstrip() + f" visual_offset={value}\n", world, "ow_5_5.room")
            self.assertEqual(result, again)

    def test_visual_offset_rejects_invalid_numbers(self) -> None:
        world = world_of([room_record("ow_5_5", [])])
        for value in ("1", "1,2,3", "nan,0", "0,inf", "a,b"):
            result, errors = compile_text(room_text("ow_5_5", [], f"prop hut 5,5 visual_offset={value}"),
                                          world, "ow_5_5.room")
            self.assertIsNone(result)
            self.assertTrue(any("visual_offset takes two finite" in e for e in errors), errors)

    def test_a_prop_with_its_own_script_is_refused(self) -> None:
        world = world_of([room_record("ow_5_5", [])])
        text = "\n".join(["room ow_5_5", "grid", *(["#" * 20] + ["#" + "." * 18 + "#"] * 8 + ["#" * 20]),
                           "prop thorn_hedge 5,5"]) + "\n"
        result, errors = compile_text(text, world, "ow_5_5.room")
        self.assertIsNone(result)
        self.assertTrue(any("prop kind must be one of" in e for e in errors), errors)


class ScriptedOpeners(unittest.TestCase):
    def test_thorn_hedge_uses_scene_size_and_rotates_for_east_gap(self) -> None:
        world = world_of([room_record("ow_2_0", ["e"])])
        text, errors = compile_text(
            room_text("ow_2_0", ["e"], "opener thorn_hedge @1872,480 id=ow_2_0_hedge"),
            world,
            "ow_2_0.room",
        )
        self.assertEqual(errors, [])
        self.assertIn('path="res://scenes/world/thorn_hedge.tscn"', text or "")
        self.assertIn('burn_id = &"ow_2_0_hedge"', text or "")
        self.assertIn("rotation = 1.570796", text or "")
        self.assertNotIn("size = Vector2", text or "")  # the scene's 192 x 96 size is the default

    def test_thorn_hedge_outside_an_exit_corridor_is_rejected(self) -> None:
        world = world_of([room_record("ow_2_0", ["e"])])
        _, errors = compile_text(
            room_text("ow_2_0", ["e"], "opener thorn_hedge 5,5 id=ow_2_0_hedge"),
            world,
            "ow_2_0.room",
        )
        self.assertTrue(any(":13: opener thorn_hedge must stand in a graph exit corridor" in e for e in errors), errors)

    def test_cut_screen_uses_the_selected_bush_scene(self) -> None:
        world = world_of([room_record("ow_1_2", ["s"])])
        for look in ("reed_cluster", "rush_wall"):
            with self.subTest(look=look):
                text, errors = compile_text(
                    room_text("ow_1_2", ["s"], f"opener cut_screen 9,9 look={look}"),
                    world,
                    "ow_1_2.room",
                )
                self.assertEqual(errors, [])
                self.assertIn(f'path="res://scenes/world/{look}.tscn"', text or "")

    def test_cut_screen_rejects_unknown_looks(self) -> None:
        world = world_of([room_record("ow_1_2", ["s"])])
        _, errors = compile_text(
            room_text("ow_1_2", ["s"], "opener cut_screen 9,9 look=reed_wall"),
            world,
            "ow_1_2.room",
        )
        self.assertTrue(any("opener cut_screen needs look=reed_cluster, rush_wall, moss_wall or dry_vine_screen" in e for e in errors), errors)

    def hidden_stairs_world(self) -> br.World:
        return world_of(
            [dict(room_record("ow_0_2", ["e"]), scope="ow"),
             dict(room_record("cave_9_1", []), scope="c9")],
            edges=[{"id": "e254", "a": "ow_0_2", "b": "cave_9_1", "link": "door", "gate": "hidden",
                    "needs": ["glow_jar"], "dir": "both", "prop": "hidden stairs"}],
        )

    def test_hidden_stairs_builds_a_persistent_target_door(self) -> None:
        text, errors = compile_text(
            room_text("ow_0_2", ["e"], "hidden_stairs cave_9_1 FromOverworld 5,5 id=ow_0_2_stairs"),
            self.hidden_stairs_world(),
            "ow_0_2.room",
        )
        self.assertEqual(errors, [])
        self.assertIn('path="res://scenes/world/hidden_stairs.tscn"', text or "")
        self.assertIn('seam_id = &"ow_0_2_stairs"', text or "")
        self.assertIn('door_target = &"cave_9_1"', text or "")
        self.assertIn('door_spawn = &"FromOverworld"', text or "")

    def test_actual_ow_0_2_source_builds_with_its_historical_reveal_flag(self) -> None:
        source = br.ROOMS_DIR / "ow_0_2.room"
        text, errors = br.compile_room(source, real_world())
        self.assertEqual(errors, [])
        self.assertIsNotNone(text)
        self.assertIn('path="res://scenes/world/hidden_stairs.tscn"', text or "")
        self.assertIn('seam_id = &"ow_0_2_stairs"', text or "")
        self.assertIn('door_target = &"cave_9_1"', text or "")
        self.assertIn('door_spawn = &"FromOverworld"', text or "")
        committed = (br.ROOT / "scenes/world/rooms/ow_0_2.tscn").read_text(encoding="utf-8")
        self.assertEqual(text, committed)

    def test_historical_stairs_id_is_limited_to_the_exact_e254_pair(self) -> None:
        world = self.hidden_stairs_world()
        world.edges[0]["id"] = "e253"
        _, errors = compile_text(
            room_text("ow_0_2", ["e"], "hidden_stairs cave_9_1 FromOverworld 5,5 id=ow_0_2_stairs"),
            world,
            "ow_0_2.room",
        )
        self.assertTrue(any("hidden stairs edge e253 needs exactly one graph-linked hidden_stairs opener" in e
                            for e in errors), errors)

    def test_historical_stairs_id_does_not_bypass_partner_or_glow_gate_checks(self) -> None:
        _, target_errors = compile_text(
            room_text("ow_0_2", ["e"], "hidden_stairs cave_9_2 FromOverworld 5,5 id=ow_0_2_stairs"),
            self.hidden_stairs_world(),
            "ow_0_2.room",
        )
        self.assertTrue(any("door to cave_9_2 is not a door of the graph for ow_0_2" in e
                            for e in target_errors), target_errors)

        world = self.hidden_stairs_world()
        world.edges[0]["needs"] = ["tallow_sling"]
        _, gate_errors = compile_text(
            room_text("ow_0_2", ["e"], "hidden_stairs cave_9_1 FromOverworld 5,5 id=ow_0_2_stairs"),
            world,
            "ow_0_2.room",
        )
        self.assertTrue(any("hidden stairs edge e254 must be a two-way hidden glow_jar door" in e
                            for e in gate_errors), gate_errors)

    def test_hidden_stairs_must_target_a_graph_door_partner(self) -> None:
        _, errors = compile_text(
            room_text("ow_0_2", ["e"], "hidden_stairs cave_9_2 FromOverworld 5,5 id=lamp_stairs"),
            self.hidden_stairs_world(),
            "ow_0_2.room",
        )
        self.assertTrue(any("door to cave_9_2 is not a door of the graph for ow_0_2" in e for e in errors), errors)


class HiddenStairsMouth(unittest.TestCase):
    EDGE_ID = "e252"
    OVERWORLD = "ow_10_2"
    CAVE = "cave_7_1"

    def world(self, edge_change: dict | None = None) -> br.World:
        edge = dict(next(e for e in real_world().edges if e["id"] == self.EDGE_ID))
        edge.update(edge_change or {})
        rooms = [dict(room_record(self.OVERWORLD, ["n", "e", "s", "w"], grid=(10, 2)), scope="ow"),
                 dict(room_record(self.CAVE, ["w"], grid=(52, 13)), scope="c7")]
        return world_of(rooms, edges=[edge])

    def compile(self, room_id: str, exits: list[str], entity: str, edge_change: dict | None = None):
        source = room_text(room_id, exits, entity) if entity else room_text(room_id, exits, "")
        return compile_text(source, self.world(edge_change), room_id + ".room")

    def test_actual_e252_plain_cave_return_is_unblocked_and_paired(self) -> None:
        text, errors = self.compile(self.CAVE, ["w"], f"door {self.OVERWORLD} FromCave 5,5")
        self.assertEqual(errors, [])
        self.assertIsNotNone(text)
        nodes = emitted_nodes(text or "")
        doors = [node for node in nodes.values() if node["scene"] is None and node["parent"] == "Props"
                 and any(prop.startswith('target_room = &"ow_10_2"') for prop in node["properties"])]
        self.assertEqual(len(doors), 1)
        self.assertFalse(any("blocker_path" in prop or "requires_flag" in prop
                             for node in doors for prop in node["properties"]))

    def test_actual_e252_overworld_entry_keeps_revealable_geometry_and_glow_requirement(self) -> None:
        text, errors = self.compile(
            self.OVERWORLD, ["n", "e", "s", "w"],
            f"hidden_stairs {self.CAVE} FromOverworld 5,5 id={self.EDGE_ID}",
        )
        self.assertEqual(errors, [])
        self.assertIn('path="res://scenes/world/hidden_stairs.tscn"', text or "")
        self.assertIn('seam_id = &"e252"', text or "")
        self.assertIn('door_target = &"cave_7_1"', text or "")
        self.assertIn('door_spawn = &"FromOverworld"', text or "")
        scene = (br.ROOT / "scenes/world/hidden_stairs.tscn").read_text(encoding="utf-8")
        self.assertIn('path="res://scripts/world/hidden_seam.gd"', scene)
        self.assertIn('look = &"hidden_stairs"', scene)
        seam = (br.ROOT / "scripts/world/hidden_seam.gd").read_text(encoding="utf-8")
        self.assertIn("const EXPOSE_TIME := 1.0", seam)
        self.assertIn('var size: Vector2 = Vector2(192, 96)', seam)
        self.assertIn('add_to_group(&"revealable")', seam)
        self.assertIn("_set_open(false)", seam)
        self.assertIn("_set_open(true)", seam)
        self.assertIn("_body_shape.set_deferred(\"disabled\", open)", seam)
        self.assertIn("_show_door()", seam)
        jar = (br.ROOT / "scripts/items/jar.gd").read_text(encoding="utf-8")
        self.assertIn('get_nodes_in_group(&"revealable")', jar)
        self.assertIn('prop.call(&"reveal")', jar)
        self.assertEqual(br.MOUTH_REQUIREMENTS["hidden stairs"], ("hidden", ["glow_jar"]))

    def test_plain_overworld_ingress_and_missing_reveal_opener_are_rejected(self) -> None:
        _, ingress_errors = self.compile(self.OVERWORLD, ["n", "e", "s", "w"],
                                          f"door {self.CAVE} FromOverworld 5,5")
        self.assertTrue(any("only valid from its cave mouth" in error for error in ingress_errors), ingress_errors)
        _, missing_errors = self.compile(self.OVERWORLD, ["n", "e", "s", "w"], "")
        self.assertTrue(any("needs exactly one graph-linked hidden_stairs opener" in error
                            for error in missing_errors), missing_errors)

    def test_hidden_stairs_must_match_e252_target_spawn_id_and_requirements(self) -> None:
        variants = [
            (f"hidden_stairs {self.CAVE} FromOverworld 5,5 id=other", None, "needs exactly one graph-linked"),
            (f"hidden_stairs cave_7_2 FromOverworld 5,5 id=e252", None, "must target cave_7_1 FromOverworld"),
            (f"hidden_stairs {self.CAVE} Default 5,5 id=e252", None, "must target cave_7_1 FromOverworld"),
            (f"hidden_stairs {self.CAVE} FromOverworld 5,5 id=e252", {"needs": ["tallow_sling"]},
             "must be a two-way hidden glow_jar door"),
        ]
        for entity, edge_change, expected in variants:
            with self.subTest(entity=entity, edge_change=edge_change):
                _, errors = self.compile(self.OVERWORLD, ["n", "e", "s", "w"], entity, edge_change)
                self.assertTrue(any(expected in error for error in errors), errors)

    def test_cave_return_rejects_wrong_target_marker_and_direction(self) -> None:
        variants = [
            (f"door ow_10_3 FromCave 5,5", None, "not a door of the graph"),
            (f"door {self.OVERWORLD} FromOverworld 5,5", None, "must target FromCave"),
            (f"door {self.OVERWORLD} FromCave 5,5 blocker=e252", None, "takes no blocker"),
            (f"door {self.OVERWORLD} FromCave 5,5", {"dir": "a_to_b"},
             "must be a two-way hidden glow_jar door"),
        ]
        for entity, edge_change, expected in variants:
            with self.subTest(entity=entity, edge_change=edge_change):
                _, errors = self.compile(self.CAVE, ["w"], entity, edge_change)
                self.assertTrue(any(expected in error for error in errors), errors)


class NinthDoorReturn(unittest.TestCase):
    OVERWORLD = "ow_10_8"
    CAVE = "cave_10_1"

    def world(self, edge_change: dict | None = None) -> br.World:
        actual = real_world()
        edge = dict(next(e for e in actual.edges if e["id"] == "e255"))
        edge.update(edge_change or {})
        overworld = actual.room(self.OVERWORLD)
        cave = actual.room(self.CAVE)
        rooms = [dict(room_record(self.OVERWORLD, overworld["exits"], grid=overworld["grid"]), scope="ow"),
                 dict(room_record(self.CAVE, cave["exits"], grid=cave["grid"]), scope="c10")]
        return world_of(rooms, edges=[edge])

    def compile(self, room_id: str, entity: str, edge_change: dict | None = None):
        world = self.world(edge_change)
        rec = world.room(room_id)
        return compile_text(room_text(room_id, rec["exits"], entity), world, room_id + ".room")

    def test_actual_e255_plain_cave_return_is_unblocked(self) -> None:
        text, errors = self.compile(self.CAVE, f"door {self.OVERWORLD} FromCave 5,5")
        self.assertEqual(errors, [])
        self.assertIn('target_room = &"ow_10_8"', text or "")
        self.assertNotIn("blocker_path", text or "")
        self.assertNotIn("requires_flag", text or "")

    def test_actual_e255_overworld_ingress_keeps_the_real_nine_fragment_door(self) -> None:
        source = f"opener ninth_door 5,5 id=e255\ndoor {self.CAVE} FromOverworld 6,5 blocker=e255"
        text, errors = self.compile(self.OVERWORLD, source)
        self.assertEqual(errors, [])
        self.assertIn('path="res://scenes/world/ninth_door.tscn"', text or "")
        self.assertIn('blocker_path = NodePath("../NinthDoor1")', text or "")
        scene = (br.ROOT / "scenes/world/ninth_door.tscn").read_text(encoding="utf-8")
        self.assertIn('path="res://scripts/world/ninth_door.gd"', scene)
        door_script = (br.ROOT / "scripts/world/ninth_door.gd").read_text(encoding="utf-8")
        self.assertIn('GameState.FRAGMENT_CAVES', door_script)
        self.assertIn("func can_open()", door_script)
        self.assertIn("GameState.has_fragment", door_script)

    def test_plain_overworld_ingress_and_wrong_return_pairs_are_rejected(self) -> None:
        _, ingress_errors = self.compile(self.OVERWORLD, f"door {self.CAVE} FromOverworld 5,5")
        self.assertTrue(any("needs exactly one ninth_door blocker" in error for error in ingress_errors), ingress_errors)
        variants = [
            ("door ow_10_7 FromCave 5,5", None, "not a door of the graph"),
            (f"door {self.OVERWORLD} FromOverworld 5,5", None, "must target FromCave"),
            (f"door {self.OVERWORLD} FromCave 5,5 blocker=e255", None, "takes no blocker"),
            (f"door {self.OVERWORLD} FromCave 5,5", {"dir": "a_to_b"}, "two-way nine-fragment"),
            (f"door {self.OVERWORLD} FromCave 5,5", {"needs": [f"frag:c{i}" for i in range(1, 9)]},
             "mouth requirements do not match graph prop"),
        ]
        for entity, edge_change, expected in variants:
            with self.subTest(entity=entity, edge_change=edge_change):
                _, errors = self.compile(self.CAVE, entity, edge_change)
                self.assertTrue(any(expected in error for error in errors), errors)


class EndingTriggerEntity(unittest.TestCase):
    FINAL_ROOM = "cave_10_14"

    def world(self, room_id: str = FINAL_ROOM) -> br.World:
        actual = real_world().room(room_id)
        return world_of([dict(room_record(room_id, actual["exits"], grid=actual["grid"]), scope=actual["scope"])])

    def test_final_room_emits_only_the_e1_scene_at_the_authored_position(self) -> None:
        text, errors = compile_text(room_text(self.FINAL_ROOM, ["e"], "ending_trigger @960,480"),
                                    self.world(), self.FINAL_ROOM + ".room")
        self.assertEqual(errors, [])
        nodes = emitted_nodes(text or "")
        triggers = [node for node in nodes.values() if node["scene"] == "res://scenes/world/ending_trigger.tscn"]
        self.assertEqual(len(triggers), 1)
        self.assertEqual(triggers[0]["parent"], "Props")
        self.assertEqual(triggers[0]["properties"], ["position = Vector2(960, 480)"])
        scene = (br.ROOT / "scenes/world/ending_trigger.tscn").read_text(encoding="utf-8")
        self.assertIn('path="res://scripts/world/ending_trigger.gd"', scene)
        script = (br.ROOT / "scripts/world/ending_trigger.gd").read_text(encoding="utf-8")
        self.assertIn('const BOSS_FLAG := &"boss_cave_10_14_defeated"', script)
        self.assertIn("const DEATH_FADE_TIME := 2.0", script)
        self.assertNotIn("ending_rekindle", text or "")
        self.assertNotIn("ending_wickwarden", text or "")

    def test_ending_trigger_is_rejected_outside_final_room_and_has_no_options(self) -> None:
        _, room_errors = compile_text(room_text("cave_10_13", ["e"], "ending_trigger 5,5"),
                                      self.world("cave_10_13"), "cave_10_13.room")
        self.assertTrue(any("only valid in cave_10_14" in error for error in room_errors), room_errors)
        _, option_errors = compile_text(room_text(self.FINAL_ROOM, ["e"], "ending_trigger 5,5 id=ending"),
                                        self.world(), self.FINAL_ROOM + ".room")
        self.assertTrue(any("takes no option 'id'" in error for error in option_errors), option_errors)
        _, argument_errors = compile_text(room_text(self.FINAL_ROOM, ["e"], "ending_trigger unknown 5,5"),
                                          self.world(), self.FINAL_ROOM + ".room")
        self.assertTrue(any("takes only a position" in error for error in argument_errors), argument_errors)


class C09EntryRefills(unittest.TestCase):
    ROOM = "cave_9_4"

    def world(self, room_id: str = ROOM, pickups: list[dict] | None = None) -> br.World:
        actual = real_world().room(room_id)
        record = dict(room_record(room_id, actual["exits"], grid=actual["grid"]), scope=actual["scope"])
        return world_of([record], pickups=pickups)

    def compile(self, entities: list[str], room_id: str = ROOM, pickups: list[dict] | None = None):
        world = self.world(room_id, pickups)
        exits = world.room(room_id)["exits"]
        return compile_text(room_text(room_id, exits, "\n".join(entities)), world, room_id + ".room")

    def two_refills(self) -> list[str]:
        return ["refill pot_bundle @384,480", "refill pot_bundle @576,480"]

    def test_c09_4_emits_two_existing_refill_scenes_with_empty_persistent_ids(self) -> None:
        text, errors = self.compile(self.two_refills())
        self.assertEqual(errors, [])
        nodes = emitted_nodes(text or "")
        refills = [node for node in nodes.values()
                   if node["scene"] == "res://scenes/pickups/pitch_pot_bundle.tscn"]
        self.assertEqual(len(refills), 2)
        self.assertEqual({tuple(node["properties"]) for node in refills}, {
            ("position = Vector2(384, 480)", 'persistent_id = &""', "respawn_on_enter = true"),
            ("position = Vector2(576, 480)", 'persistent_id = &""', "respawn_on_enter = true"),
        })
        self.assertTrue(all(node["parent"] == "Props" for node in refills))
        self.assertTrue(all("amount =" not in prop and "requires_flag" not in prop and "scope =" not in prop
                            for node in refills for prop in node["properties"]))
        scene = (br.ROOT / "scenes/pickups/pitch_pot_bundle.tscn").read_text(encoding="utf-8")
        self.assertIn('path="res://scripts/pickups/pickup_base.gd"', scene)
        self.assertIn('kind = &"pitch_pot_bundle"', scene)
        pickup_base = (br.ROOT / "scripts/pickups/pickup_base.gd").read_text(encoding="utf-8")
        self.assertIn('@export var persistent_id: StringName = &""', pickup_base)
        self.assertIn('@export var respawn_on_enter: bool = false', pickup_base)
        room_script = (br.ROOT / "scripts/world/room.gd").read_text(encoding="utf-8")
        self.assertIn("child is PickupBase and child.respawn_on_enter", room_script)
        self.assertIn('refill.persistent_id = &""', room_script)
        self.assertIn('get_node("Props").add_child(refill)', room_script)

    def test_refills_do_not_replace_or_weaken_exact_graph_pickup_checks(self) -> None:
        graph_pickup = {"id": "workbench_key", "kind": "small_key", "node": self.ROOM, "scope": "c9"}
        entities = self.two_refills() + ["pickup small_key 8,5 id=workbench_key"]
        text, errors = self.compile(entities, pickups=[graph_pickup])
        self.assertEqual(errors, [])
        nodes = emitted_nodes(text or "")
        self.assertEqual(sum(node["scene"] == "res://scenes/pickups/pitch_pot_bundle.tscn"
                             for node in nodes.values()), 2)
        _, missing_errors = self.compile(self.two_refills(), pickups=[graph_pickup])
        self.assertTrue(any("graph pickup workbench_key (small_key) is not placed" in error
                            for error in missing_errors), missing_errors)
        _, extra_errors = self.compile(entities + ["pickup small_key 9,5 id=not_in_graph"], pickups=[graph_pickup])
        self.assertTrue(any("pickup not_in_graph is not in the graph" in error for error in extra_errors), extra_errors)

    def test_only_two_distinct_c09_4_pot_bundle_refills_are_allowed(self) -> None:
        for entities in ([], self.two_refills()[:1], self.two_refills() + ["refill pot_bundle 8,5"]):
            with self.subTest(entities=entities):
                _, errors = self.compile(entities)
                self.assertTrue(any("exactly two refill pot_bundle" in error for error in errors), errors)
        _, duplicate_errors = self.compile(["refill pot_bundle @384,480", "refill pot_bundle @384,480"])
        self.assertTrue(any("distinct positions" in error for error in duplicate_errors), duplicate_errors)

    def test_refill_rejects_other_rooms_kinds_and_persistent_options(self) -> None:
        _, room_errors = self.compile(self.two_refills(), room_id="cave_9_5")
        self.assertTrue(any("only valid in cave_9_4" in error for error in room_errors), room_errors)
        _, kind_errors = self.compile(["refill brass_coin @384,480", self.two_refills()[1]])
        self.assertTrue(any("only supports pot_bundle" in error for error in kind_errors), kind_errors)
        for option in ("id=fake", "persistent_id=fake", "requires=boss_defeated", "scope=c9", "amount=999"):
            with self.subTest(option=option):
                _, errors = self.compile([f"refill pot_bundle @384,480 {option}", self.two_refills()[1]])
                self.assertTrue(any("takes no option" in error for error in errors), errors)


class Geometry(unittest.TestCase):
    def test_merge_is_row_major_and_greedy(self) -> None:
        grid = ["." * 20 for _ in range(10)]
        grid[3] = "...." + "w" * 5 + "..." + "." * 8
        grid[4] = "..." + "w" + "wwwww" + "." * 11
        grid[5] = "..." + "w" + "wwwww" + "." * 11
        grid[6] = "...." + "www" + "." * 13
        rects = br.merge_rects(grid, "w")
        self.assertEqual(rects, [(4, 3, 5, 3), (3, 4, 1, 2), (4, 6, 3, 1)])

    def test_ring_hash_is_not_merged(self) -> None:
        grid = ["#" * 20] + ["#" + "." * 18 + "#" for _ in range(8)] + ["#" * 20]
        self.assertEqual(br.merge_rects(grid, "#"), [])

    def test_tile_of_clamps_to_the_grid(self) -> None:
        self.assertEqual(br.tile_of(-5, 2000), (0, 9))
        self.assertEqual(br.tile_of(240, 240), (2, 2))

    def test_corridor_is_two_wide_and_four_deep(self) -> None:
        self.assertEqual(len(br.exit_corridor("n")), 8)
        self.assertIn((10, 3), br.exit_corridor("n"))
        self.assertNotIn((10, 4), br.exit_corridor("n"))

    def test_snake_names(self) -> None:
        self.assertEqual(br.snake("Tallow blob"), "tallow_blob")
        self.assertEqual(br.snake("NEW:wickling"), "wickling")

    def test_bigkey_items_are_pickups(self) -> None:
        self.assertEqual(br.item_as_pickup("bigkey:c1", {"node": "cave_1_7"})["id"], "bigkey_c1")
        self.assertEqual(br.item_as_pickup("frag:c2", {"node": "cave_2_9", "after_boss": True})["kind"], "fragment")


class Command(unittest.TestCase):
    def test_check_fails_on_missing_scene_then_passes_after_build(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "out"
            args = ["ow_0_1", "--rooms-dir", str(FIXTURES), "--out-dir", str(out)]
            with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                self.assertEqual(br.main(["--check", *args]), 1)
                self.assertEqual(br.main(args), 0)
                self.assertEqual(br.main(["--check", *args]), 0)
            self.assertTrue((out / "ow_0_1.tscn").exists())

    def test_unknown_room_name_is_reported(self) -> None:
        with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(br.main(["ow_9_9", "--rooms-dir", str(FIXTURES), "--out-dir", str(FIXTURES)]), 1)



def pocket_text(entities: list[str], room: str = "ow_5_5#cache") -> str:
    """A pocket source: a walled 20x10 box with the given entity lines."""
    box = ["#" * 20] + ["#" + "." * 18 + "#"] * 8 + ["#" * 20]
    return "\n".join([f"room {room}", "grid", *box, *entities]) + "\n"


class Shops(unittest.TestCase):
    """`shop` lines place ShopItem nodes. Each stock is priced in data/shop_prices.json for its shop, and the
    room must be the graph's shop of that id (the graph's slug bundles of the shop are its stock)."""

    def fixture(self) -> str:
        return SHOP_FIXTURE.read_text(encoding="utf-8")

    def test_fixture_compiles_with_the_graph_and_the_prices(self) -> None:
        text, errors = compile_text(self.fixture(), real_world(), "ow_1_2__shop.room")
        self.assertEqual(errors, [])
        self.assertEqual((text or "").count('[node name="ShopItem'), 2)
        self.assertIn('shop = &"S1"', text or "")
        self.assertIn('stock = &"ember"', text or "")
        self.assertIn('stock_id = &"pot_s1"', text or "")
        self.assertNotIn("price", text or "")  # ShopItem reads the price from data/shop_prices.json

    def test_stock_without_a_price_is_refused(self) -> None:
        text = self.fixture().replace("shop S1 ember @528,358", "shop S1 tallow_flask @528,358")
        _, errors = compile_text(text, real_world(), "ow_1_2__shop.room")
        self.assertTrue(any("no price for tallow_flask in shop S1" in e for e in errors), errors)

    def test_one_time_stock_needs_an_id(self) -> None:
        text = self.fixture().replace("pot_bundle @1392,358 id=pot_s1", "pot_bundle @1392,358")
        _, errors = compile_text(text, real_world(), "ow_1_2__shop.room")
        self.assertTrue(any("one-time stock and needs id=" in e for e in errors), errors)

    def test_shop_line_must_name_the_graphs_shop(self) -> None:
        text = self.fixture().replace("shop S1", "shop S3")
        _, errors = compile_text(text, real_world(), "ow_1_2__shop.room")
        self.assertTrue(any("ow_1_2#shop is shop S1 in the graph, not S3" in e for e in errors), errors)

    def test_a_room_that_is_no_shop_refuses_shop_lines(self) -> None:
        text = self.fixture().replace("room ow_1_2#shop", "room ow_4_1#cache")
        _, errors = compile_text(text, real_world(), "ow_4_1__cache.room")
        self.assertTrue(any("ow_4_1#cache is not a shop of the graph" in e for e in errors), errors)

    def test_graph_stock_of_the_shop_must_be_placed(self) -> None:
        # S3 of the graph sells a slug bundle (slug_bundle_s3); the fixture with S3's other stock lacks it.
        text = (
            self.fixture()
            .replace("ow_1_2#shop", "ow_10_3#shop")
            .replace("door ow_1_2", "door ow_10_3")
            .replace("shop S1 ember @528,358", "shop S3 tallow_flask @528,358")
            .replace("shop S1 pot_bundle @1392,358 id=pot_s1", "shop S3 pot_bundle @1392,358 id=pot_s3")
        )
        _, errors = compile_text(text, real_world(), "ow_10_3__shop.room")
        self.assertTrue(any("graph stock slug_bundle_s3 (slug_bundle) is not placed" in e for e in errors), errors)
        self.assertEqual(len(errors), 1, errors)
        placed = text + "shop S3 slug_bundle @1392,742 id=slug_bundle_s3\n"
        result, errors = compile_text(placed, real_world(), "ow_10_3__shop.room")
        self.assertEqual(errors, [])
        self.assertIsNotNone(result)


class Caches(unittest.TestCase):
    """A `cache` line puts the contents of the graph's cache on its spot: brass as one coin with the amount,
    each ember, a pot bundle. Slug bundles are their own pickup lines."""

    def world(self, contents: str) -> br.World:
        return world_of(
            [room_record("ow_5_5", ["w"])],
            pockets=[{"id": "ow_5_5#cache", "host": "ow_5_5", "grid": [0, 30], "in_place": False, "scope": "ow"}],
            pickups=[
                {"id": "cache_ow_5_5", "kind": "cache", "node": "ow_5_5#cache", "contents": contents},
                {"id": "slug_bundle_ow_5_5", "kind": "slug_bundle", "node": "ow_5_5#cache"},
            ],
            edges=[{"id": "e1", "a": "ow_5_5", "b": "ow_5_5#cache", "link": "door", "gate": None,
                    "needs": [], "dir": "both", "key": None, "prop": None}],
        )

    def entities(self, cache_id: str = "cache_ow_5_5") -> list[str]:
        return [f"cache 5,4 id={cache_id}", "pickup slug_bundle 6,4 id=slug_bundle_ow_5_5",
                "door ow_5_5 FromPocket 9,8", "spawn Inside 9,6"]

    def test_pieces_come_from_the_graph_text(self) -> None:
        world = self.world("30 brass, ember, pot bundle, slug bundle")
        text, errors = compile_text(pocket_text(self.entities()), world, "ow_5_5__cache.room")
        self.assertEqual(errors, [])
        out = text or ""
        self.assertIn('persistent_id = &"cache_ow_5_5_brass"', out)
        self.assertIn("amount = 30", out)
        self.assertIn('persistent_id = &"cache_ow_5_5_ember1"', out)
        self.assertIn('persistent_id = &"cache_ow_5_5_pots"', out)
        self.assertNotIn("slugs", out)  # the slug bundle is the pickup line, not a piece of the cache

    def test_cache_parts(self) -> None:
        self.assertEqual(
            br.cache_pieces("c", "40 brass"), [("brass", "c_brass", 40)]
        )
        self.assertEqual(
            br.cache_pieces("c", "2 embers, pot bundle"),
            [("ember", "c_ember1", 0), ("ember", "c_ember2", 0), ("pot_bundle", "c_pots", 0)],
        )
        self.assertIsNone(br.cache_pieces("c", "a chest"))

    def test_unknown_contents_are_refused(self) -> None:
        _, errors = compile_text(pocket_text(self.entities()), self.world("a chest of gold"), "ow_5_5__cache.room")
        self.assertTrue(any("does not know" in e for e in errors), errors)

    def test_missing_cache_line_is_refused(self) -> None:
        entities = [e for e in self.entities() if not e.startswith("cache")]
        _, errors = compile_text(pocket_text(entities), self.world("40 brass"), "ow_5_5__cache.room")
        self.assertTrue(any("graph pickup cache_ow_5_5 (cache) is not placed" in e for e in errors), errors)

    def test_cache_id_must_be_in_the_graph(self) -> None:
        _, errors = compile_text(pocket_text(self.entities("cache_ow_9_9")), self.world("40 brass"),
                                 "ow_5_5__cache.room")
        self.assertTrue(any("pickup cache_ow_9_9 is not in the graph for this room" in e for e in errors), errors)

    def test_cache_needs_an_id(self) -> None:
        entities = ["cache 5,4", *self.entities()[1:]]
        _, errors = compile_text(pocket_text(entities), self.world("40 brass"), "ow_5_5__cache.room")
        self.assertTrue(any("cache takes a position and id=" in e for e in errors), errors)

    def test_every_cache_text_of_the_graph_is_understood(self) -> None:
        caches = [p for p in real_world().pickups if p["kind"] == "cache"]
        self.assertGreater(len(caches), 10)
        for cache in caches:
            self.assertIsNotNone(br.cache_pieces(cache["id"], cache["contents"]), cache["contents"])


class Crossings(unittest.TestCase):
    def world(self, enemies=None):
        return world_of([room_record("ow_5_5", ["e"], enemies, (5, 5)),
                         room_record("ow_6_5", ["w"], grid=(6, 5))], edges=[
            {"a": "ow_5_5", "b": "ow_6_5", "link": "step", "gate": "item",
             "dir": "both", "prop": "mooring and water"}])

    def compile(self, entities, world=None):
        return compile_text(room_text("ow_5_5", ["e"], entities), world or self.world(), "ow_5_5.room")

    def test_water_and_mooring_block_foot_exit(self):
        text, errors = self.compile("water @1728,480 size=192,768\n"
                                    "mooring 15,3 id=east target_room=ow_6_5 target_mooring=west")
        self.assertEqual(errors, [])
        self.assertIn('path="res://scenes/world/water_zone.tscn"', text)
        self.assertIn('deep = true', text)
        self.assertIn('mooring_id = &"east"', text)

    def test_post_without_water_does_not_gate_exit(self):
        _, errors = self.compile("mooring 15,3 id=east target_room=ow_6_5 target_mooring=west")
        self.assertTrue(any("walkable on foot" in e for e in errors), errors)

    def test_narrow_water_can_be_walked_around(self):
        _, errors = self.compile("water 17,4 size=96,96\n"
                                "mooring 15,3 id=east target_room=ow_6_5 target_mooring=west")
        self.assertTrue(any("walkable on foot" in e for e in errors), errors)

    def test_water_without_post_is_rejected(self):
        _, errors = self.compile("water @1728,480 size=192,768")
        self.assertTrue(any("needs a mooring" in e for e in errors), errors)

    def test_mooring_landing_must_be_clear(self):
        _, errors = self.compile("water @1728,480 size=192,768\n"
                                "mooring 15,3 id=east target_room=ow_6_5 target_mooring=west landing_offset=240,0")
        self.assertTrue(any("landing is on an obstacle" in e for e in errors), errors)

    def test_duplicate_mooring_ids_rejected(self):
        post = "mooring 15,3 id=east target_room=ow_6_5 target_mooring=west"
        _, errors = self.compile(post + "\n" + post)
        self.assertTrue(any("duplicate mooring id" in e for e in errors), errors)

    def test_unknown_target_rejected(self):
        _, errors = self.compile("mooring 15,3 id=east target_room=ow_9_9 target_mooring=west")
        self.assertTrue(any("graph raft edge" in e for e in errors), errors)

    def test_shallows_contain_leeches(self):
        world = world_of([room_record("ow_5_5", [], {"Fen leech": 1})])
        source = room_text("ow_5_5", [], "shallows 5,5 size=192,192\nenemy fen_leech 5,5")
        text, errors = compile_text(source, world, "ow_5_5.room")
        self.assertEqual(errors, [])
        self.assertIn('path="res://scenes/world/shallow_zone.tscn"', text)
        _, errors = compile_text(source.replace("enemy fen_leech 5,5", "enemy fen_leech 8,5"), world, "ow_5_5.room")
        self.assertTrue(any("must start in water or shallows" in e for e in errors), errors)

    def test_ledge_only_emits_outgoing_drop(self):
        world = self.world()
        world.edges[0].update(gate="oneway", dir="a>b", prop="cliff drop")
        text, errors = self.compile("ledge e 18,4 size=48,288", world)
        self.assertEqual(errors, [])
        self.assertIn('drop_exits = Array[StringName]([&"e"])', text)
        _, errors = compile_text(room_text("ow_6_5", ["w"], "ledge w 1,4"), world, "ow_6_5.room")
        self.assertTrue(any("outgoing graph one-way" in e for e in errors), errors)

    def test_door_validation_with_shallows_does_not_read_enemy_state(self):
        source = SHOP_FIXTURE.read_text(encoding="utf-8") + "\nshallows 3,3 size=96,96\n"
        text, errors = compile_text(source, real_world(), "ow_1_2__shop.room")
        self.assertEqual(errors, [])
        self.assertIn('target_room = &"ow_1_2"', text)

    def test_bad_sizes_and_offsets_rejected(self):
        for entity in ["water 5,5 size=-1,96", "shallows 5,5 size=0,96",
                       "mooring 5,5 id=x target_room=ow_6_5 target_mooring=y landing_offset=no"]:
            _, errors = self.compile(entity)
            self.assertTrue(errors, entity)




class ScriptedGateExtensions(unittest.TestCase):
    def compile(self, entities, exits=None, grid=None, edges=None):
        exits = exits or []
        world = world_of([room_record("ow_5_5", exits), room_record("ow_5_6", ["n"], grid=(5, 6))], edges=edges)
        source = room_text("ow_5_5", exits, entities)
        if grid:
            source = "\n".join(["room ow_5_5", "grid", *grid, entities])
        return compile_text(source, world, "ow_5_5.room")

    def test_eye_pair_emits_real_scenes_and_shared_id(self):
        text, errors = self.compile("eye_switch 12,3 id=e028\nopener eye_portcullis @1872,480 id=e028", ["e"])
        self.assertEqual(errors, [])
        self.assertIn('rotation = 1.570796', text)
        self.assertEqual(text.count('eye_id = &"e028"'), 2)
        self.assertIn('scenes/world/eye_portcullis.tscn', text)

    def test_missing_or_mismatched_eye_link_fails(self):
        for lines in ["opener eye_portcullis 15,4 id=e028",
                      "eye_switch 12,3 id=other\nopener eye_portcullis 15,4 id=e028"]:
            with self.subTest(lines=lines):
                self.assertTrue(self.compile(lines)[1])

    def test_duplicate_control_fails(self):
        self.assertTrue(self.compile("eye_switch 12,3 id=e028\neye_switch 13,3 id=e028\nopener eye_portcullis 15,4 id=e028")[1])

    def test_thorn_and_heavy_use_existing_persistent_apis(self):
        for kind, field, size in [("thorn_door", "burn_id", "192, 96"), ("heavy_stone", "stone_id", "96, 96")]:
            text, errors = self.compile(f"opener {kind} 15,4 id=e063")
            self.assertEqual(errors, [])
            self.assertIn(f'{field} = &"e063"', text)
            self.assertIn(f'size = Vector2({size})', text)

    def test_gate_id_must_match_graph_type(self):
        edge = dict(id="e063", a="ow_5_5", b="ow_5_6", prop="heavy stones", link="step", gate="item", needs=["heft_mitts"])
        self.assertTrue(self.compile("opener thorn_door 15,4 id=e063", edges=[edge])[1])

    def test_heavy_gate_must_seal_both_gap_tiles(self):
        edge = dict(id="e063", a="ow_5_5", b="ow_5_6", prop="heavy stones", link="step", gate="item", needs=["heft_mitts"])
        _, errors = self.compile("opener heavy_stone @960,912 id=e063 size=192,96", ["s"], edges=[edge])
        self.assertEqual(errors, [])
        _, errors = self.compile("opener heavy_stone 9,9 id=e063", ["s"], edges=[edge])
        self.assertTrue(any("walkable while closed" in e for e in errors), errors)

    def test_ward_pair_and_production_shooter_options(self):
        lines = "ward_plate 12,3 id=e257 blocks_required=4\nopener ward_blocker 15,4 id=e257"
        text, errors = self.compile(lines)
        self.assertEqual(errors, [])
        self.assertEqual(text.count('ward_id = &"e257"'), 2)
        self.assertIn('blocker = true', text)
        self.assertIn('blocks_required = 4', text)
        for option in ['blocks_required=0', 'blocks_required=21', 'test_spore_post=true']:
            self.assertTrue(self.compile(lines.replace('blocks_required=4', option))[1])

    def test_pit_gate_requires_barrier_and_safe_landing(self):
        edge = dict(id="e093", a="ow_5_5", b="ow_5_6", prop="ravine leap", link="step", gate="item")
        for width in (96, 288):
            source = f'pit @960,720 size=1728,{width} look=ravine'
            text, errors = self.compile(source, ["s"], edges=[edge])
            if width == 96:
                self.assertEqual(errors, [])
                self.assertIn('look = &"ravine"', text)
            else:
                self.assertTrue(any('safe 192' in e for e in errors), errors)
        self.assertTrue(any('walkable' in e for e in self.compile('pit 2,2', ["s"], edges=[edge])[1]))


class PermanentGrateFetch(unittest.TestCase):
    def compile(self, key="5,2", grate=True, bypass=False, wall=False, spawn="5,5"):
        host = "ow_5_5"
        pocket = host + "#grate"
        world = world_of([room_record(host, [])], pockets=[dict(id=pocket, grid=[5,30], scope="ow", host=host, in_place=False)],
                         pickups=[dict(id="key_ow_2", kind="small_key", node=pocket)],
                         edges=[dict(id="e130", a=host, b=pocket, prop="grated alcove", needs=["tether_moth"], link="door", gate="item")])
        grid = open_grid([])
        grid[3] = '#' * 20
        if grate:
            grid[3] = grid[3][:5] + '..' + grid[3][7:]
        if bypass:
            grid[3] = grid[3][:15] + '.' + grid[3][16:]
        lines = [f'spawn Default {spawn}', f'pickup small_key {key} id=key_ow_2']
        if grate:
            lines += ['grate @576,336 size=192,96']
        if wall:
            grid[2] = '#' * 20
        source = '\n'.join([f'room {pocket}', 'grid', *grid, *lines])
        return compile_text(source, world, 'ow_5_5__grate.room')

    def test_permanent_grate_key_is_fetchable(self):
        text, errors = self.compile(key="5,1")
        self.assertEqual(errors, [])
        self.assertIn('scenes/world/grate.tscn', text)
        self.assertNotIn('burn_id', text)

    def test_no_blanket_unreachable_pickup_waiver(self):
        for opts in [dict(grate=False), dict(bypass=True), dict(key="15,1"), dict(wall=True), dict(spawn="5,1")]:
            with self.subTest(opts=opts):
                self.assertTrue(self.compile(**opts)[1])


class DoorBlockerLinks(unittest.TestCase):
    def compile(self, kind="thorn_door", prop="thorn-sealed door", extra="", door_opts="", offset=True):
        host, pocket = "ow_5_5", "ow_5_5#cache"
        world = world_of([room_record(host, [])],
                         pockets=[dict(id=pocket, grid=[5, 30], host=host, scope="ow", in_place=False)],
                         edges=[dict(id="e129", a=host, b=pocket, link="door", gate="item", prop=prop)])
        options = "look=reed_cluster id=mouth" if kind == "cut_screen" else "id=mouth"
        door_pos = "14,4" if offset else "15,4"
        lines = f"opener {kind} 15,4 {options}\n{extra}\ndoor {pocket} Inside {door_pos} {door_opts}"
        return compile_text(room_text(host, [], lines), world, "ow_5_5.room")

    def test_offset_and_colocated_thorn_cracked_and_cut_link_named_nodes(self):
        for kind, prop, name in [("thorn_door", "thorn-sealed door", "ThornDoor1"),
                                 ("cracked_wall", "cracked wall", "CrackedWall1"),
                                 ("cut_screen", "reed cluster", "ReedCluster1")]:
            for offset in (True, False):
                with self.subTest(kind=kind, offset=offset):
                    text, errors = self.compile(kind, prop, offset=offset)
                    self.assertEqual(errors, [])
                    expected_path = f"../../Bushes/{name}" if kind == "cut_screen" else f"../{name}"
                    self.assertIn(f'blocker_path = NodePath("{expected_path}")', text)
                    self.assertNotIn('requires_flag', text)

    def test_actual_cut_screen_doors_resolve_across_room_containers(self):
        world = real_world()
        for room_id in ("ow_1_5", "ow_7_3"):
            with self.subTest(room=room_id):
                source = (br.ROOT / "tools" / "rooms" / f"{room_id}.room").read_text(encoding="utf-8")
                text, errors = compile_text(source, world, f"{room_id}.room")
                self.assertEqual(errors, [])
                assert text is not None
                nodes = emitted_nodes(text)
                doors = [(path, node, prop) for path, node in nodes.items()
                         for prop in node["properties"]
                         if prop.startswith("blocker_path = NodePath(")]
                self.assertEqual(len(doors), 1)
                door_path, door, blocker_prop = doors[0]
                blocker_match = re.fullmatch(r'blocker_path = NodePath\("([^"]+)"\)', blocker_prop)
                self.assertIsNotNone(blocker_match, blocker_prop)
                self.assertEqual(door["parent"], "Props")
                target_path = resolve_emitted_path(door_path, blocker_match.group(1), nodes)
                blocker = nodes[target_path]
                self.assertEqual(blocker["parent"], "Bushes")
                self.assertEqual(blocker["scene"], "res://scenes/world/reed_cluster.tscn")
                self.assertEqual(blocker_match.group(1), "../../Bushes/ReedCluster1")

        # The resolved target is a real Bush. RoomDoor keeps the mouth closed while its Bush is
        # solid, then opens when hook-cutting sets is_cut and frees that blocker.
        door_script = (br.ROOT / "scripts/world/room_door.gd").read_text(encoding="utf-8")
        bush_script = (br.ROOT / "scripts/world/bush.gd").read_text(encoding="utf-8")
        self.assertIn("if blocker is Bush:", door_script)
        self.assertIn("if not blocker.is_cut:", door_script)
        self.assertIn('if hitbox.kind == &"hook"', bush_script)
        self.assertIn("is_cut = true", bush_script)
        self.assertIn("queue_free()", bush_script)

    def test_ambiguous_offset_requires_explicit_compiler_id(self):
        extra = "opener thorn_door 17,6 id=other"
        self.assertTrue(self.compile(extra=extra)[1])
        text, errors = self.compile(extra=extra, door_opts="blocker=other")
        self.assertEqual(errors, [])
        self.assertIn('blocker_path = NodePath("../ThornDoor2")', text)
        self.assertTrue(self.compile(extra=extra, door_opts="blocker=missing")[1])

    def test_grate_pocket_portal_is_free(self):
        host, pocket = "ow_5_5", "ow_5_5#grate"
        world = world_of([room_record(host, [])],
                         pockets=[dict(id=pocket, grid=[5, 30], host=host, scope="ow", in_place=False)],
                         edges=[dict(id="e130", a=host, b=pocket, link="door", gate="item", prop="grated alcove")])
        text, errors = compile_text(room_text(host, [], f"door {pocket} Inside 15,4"), world, "ow_5_5.room")
        self.assertEqual(errors, [])
        self.assertNotIn("blocker_path", text)
        text, errors = compile_text(room_text(pocket, [], f"door {host} FromPocket 15,4"), world, "ow_5_5__grate.room")
        self.assertEqual(errors, [])
        self.assertNotIn("blocker_path", text)


class MissingMouthOpeners(unittest.TestCase):
    CASES = [("e131", "hook_tap_wall", "seam_id", "192, 96"),
             ("e132", "wax_seal", "seal_id", "192, 96"),
             ("e251", "heavy_boulder", "stone_id", "96, 96")]

    def compile(self, edge_id, kind, ident=None, extra="", edge_change=None):
        # Use the actual normative gate, isolated from the other room workers' layouts.
        actual = real_world()
        edge = dict(next(e for e in actual.edges if e["id"] == edge_id))
        edge.update(edge_change or {})
        host, target = edge["a"], edge["b"]
        host_record = actual.room(host)
        host_room = dict(room_record(host, [], grid=host_record["grid"]), scope=host_record["scope"])
        rooms = [host_room]
        pockets = []
        if "#" in target:
            pockets = [dict(id=target, grid=[5, 30], host=host, scope="ow", in_place=False)]
        else:
            target_record = actual.room(target)
            rooms.append(dict(room_record(target, [], grid=target_record["grid"]), scope=target_record["scope"]))
        world = world_of(rooms, pockets=pockets, edges=[edge])
        ident = ident or edge_id
        spawn = "FromOverworld" if edge_id == "e255" else "Inside"
        source = room_text(host, [], f"opener {kind} 15,4 id={ident} {extra}\n"
                           f"door {target} {spawn} 14,4 blocker={ident}")
        return compile_text(source, world, host + ".room")

    def test_real_gate_scenes_exports_and_offset_blocker_references(self):
        for edge, kind, field, size in self.CASES:
            with self.subTest(edge=edge):
                ident = "cave6door" if edge == "e251" else edge
                text, errors = self.compile(edge, kind, ident)
                self.assertEqual(errors, [])
                self.assertIn(f'res://scenes/world/{kind}.tscn', text)
                self.assertIn(f'{field} = &"{ident}"', text)
                self.assertIn(f'size = Vector2({size})', text)
                self.assertIn(f'blocker_path = NodePath("../{br.camel(kind)}1")', text)
                self.assertNotIn('requires_flag', text)
                # Keep scene-owned mechanics, rather than overriding them with a look or mode.
                scene = (br.ROOT / f"scenes/world/{kind}.tscn").read_text()
                if kind == "hook_tap_wall":
                    self.assertIn('hidden_seam.gd', scene)
                    self.assertIn('hook_tap = true', scene)
                elif kind == "heavy_boulder":
                    self.assertIn('heavy_stone.gd', scene)
                    self.assertIn('mode = 1', scene)
                else:
                    self.assertIn('wax_seal.gd', scene)

    def test_wrong_scene_cannot_substitute_for_required_gate(self):
        for edge, required, _, _ in self.CASES:
            for kind in ("heavy_stone", "hook_tap_wall", "wax_seal", "heavy_boulder"):
                if kind != required:
                    self.assertTrue(self.compile(edge, kind)[1], (edge, kind))

    def test_exact_graph_requirements_and_supported_options(self):
        for edge, kind, _, _ in self.CASES:
            for change in (dict(gate="bomb"), dict(needs=["pitch_pot"])):
                self.assertTrue(self.compile(edge, kind, edge_change=change)[1])
            for extra in ("size=0,96", "mode=0", "look=rock", "scope=ow"):
                self.assertTrue(self.compile(edge, kind, extra=extra)[1])

    def test_hidden_and_wax_footprints_really_seal_and_reopen(self):
        # A two-tile passage must open only when the one physical opener is removed.
        for edge, kind, _, _ in self.CASES[:2]:
            gate = dict(next(e for e in real_world().edges if e["id"] == edge))
            gate.update(a="ow_5_5", b="ow_5_6", link="step")
            helper = ScriptedGateExtensions()
            text, errors = helper.compile(f"opener {kind} @960,912 id={edge}", ["s"], edges=[gate])
            self.assertEqual(errors, [])
            self.assertIn('size = Vector2(192, 96)', text)
            _, errors = helper.compile(f"opener {kind} 9,9 id={edge} size=96,96", ["s"], edges=[gate])
            self.assertTrue(any("walkable while closed" in e for e in errors), errors)


class RemainingCaveOpenerGaps(unittest.TestCase):
    STEP_CASES = (
        ("e194", "resonance_stone", "resonance_stone", "resonance_id", ("cave_6_5", "cave_6_6"), ""),
        ("e198", "heavy_door", "heavy_door", "stone_id", ("cave_6_8", "cave_6_10"), ""),
        ("e212", "eye_portcullis", "eye_portcullis", "eye_id", ("cave_8_2", "cave_8_3"),
         "eye_switch 12,3 id=e212"),
        ("e223", "thorn_wall", "thorn_wall", "burn_id", ("cave_9_2", "cave_9_3"), ""),
        ("e234", "thorn_wall", "thorn_wall", "burn_id", ("cave_10_2", "cave_10_3"), ""),
        ("e238", "resonance_stone", "resonance_stone", "resonance_id", ("cave_10_6", "cave_10_7"), ""),
        ("e244", "eye_portcullis", "eye_portcullis", "eye_id", ("cave_10_12", "cave_10_13"),
         "eye_switch 12,3 id=e244"),
    )
    POSITIONS = {"n": "@960,144", "s": "@960,816", "w": "@144,432", "e": "@1776,432"}

    def world_for_edge(self, edge_id, edge_change=None):
        actual = real_world()
        edge = dict(next(e for e in actual.edges if e["id"] == edge_id))
        edge.update(edge_change or {})
        rooms, pockets = [], []
        for room_id in (edge["a"], edge["b"]):
            record = actual.room(room_id)
            if record["pocket"]:
                pockets.append({"id": room_id, "grid": list(record["grid"]), "host": record["host"],
                                "scope": record["scope"], "in_place": record["in_place"]})
            else:
                room = room_record(room_id, record["exits"], grid=record["grid"])
                room.update(scope=record["scope"], dark=record["dark"])
                rooms.append(room)
        return world_of(rooms, pockets=pockets, edges=[edge]), edge, actual

    def compile(self, edge_id, room_id, kind, extra="", edge_change=None, extra_entities="",
                position_override=None, id_override=None):
        world, edge, actual = self.world_for_edge(edge_id, edge_change)
        other = edge["b"] if edge["a"] == room_id else edge["a"]
        side = br.edge_side(world, room_id, other) if edge.get("link") == "step" else None
        position = position_override or (self.POSITIONS[side] if side is not None else "@1440,480")
        opener_id = id_override or edge_id
        entities = [line for line in (extra_entities.strip(), f"opener {kind} {position} id={opener_id} {extra}".strip())
                    if line]
        if edge.get("link") == "door":
            entities.append(f"door {other} Inside {position} blocker={edge_id}")
        source = room_text(room_id, world.room(room_id)["exits"], "\n".join(entities))
        text, errors = compile_text(source, world, f"{room_id}.room")
        return text, errors, world, source, edge, actual

    def assert_resolved_blocker_scene(self, text, expected_scene):
        nodes = emitted_nodes(text)
        doors = [(path, node, prop) for path, node in nodes.items()
                 for prop in node["properties"] if prop.startswith("blocker_path = NodePath(")]
        self.assertEqual(len(doors), 1)
        door_path, _, blocker_prop = doors[0]
        match = re.fullmatch(r'blocker_path = NodePath\("([^"]+)"\)', blocker_prop)
        self.assertIsNotNone(match)
        blocker_path = resolve_emitted_path(door_path, match.group(1), nodes)
        self.assertEqual(nodes[blocker_path]["scene"], expected_scene)
        return match.group(1)

    def assert_step_gate_geometry(self, edge_id, room_id, kind, extra_entities=""):
        text, errors, world, source, edge, _ = self.compile(edge_id, room_id, kind,
                                                              extra_entities=extra_entities)
        self.assertEqual(errors, [], (edge_id, room_id))
        self.assertIsNotNone(text)
        other = edge["b"] if edge["a"] == room_id else edge["a"]
        side = br.edge_side(world, room_id, other)
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / f"{room_id}.room"
            path.write_text(source, encoding="utf-8")
            parse_errors = []
            src = br.parse_source(path, parse_errors)
            self.assertEqual(parse_errors, [])
            plan = br.build_plan(src, world, parse_errors)
            self.assertEqual(parse_errors, [])
            closed = br.closed_flood(plan, br.tile_of(*br.ROOM_CENTRE_PX), None)
            opened = br.closed_flood(plan, br.tile_of(*br.ROOM_CENTRE_PX), 0)
        gap = set(br.GAP_TILES[side])
        self.assertFalse(gap & closed, f"{edge_id} {room_id} must be physically closed")
        self.assertTrue(gap & opened, f"{edge_id} {room_id} must open when its scene is cleared")

    def test_exact_step_scenes_exports_and_paired_ids_at_both_endpoints(self):
        for edge_id, kind, scene, field, endpoints, extra_entities in self.STEP_CASES:
            for room_id in endpoints:
                with self.subTest(edge=edge_id, room=room_id):
                    text, errors, world, _, edge, _ = self.compile(edge_id, room_id, kind,
                                                                    extra_entities=extra_entities)
                    self.assertEqual(errors, [])
                    self.assertIn(f'path="res://scenes/world/{scene}.tscn"', text)
                    self.assertIn(f'{field} = &"{edge_id}"', text)
                    self.assertIn('size = Vector2(192, 96)', text)
                    self.assertNotIn('requires_flag', text)
                    self.assertNotIn('blocker_path', text)
                    side = br.edge_side(world, room_id, edge["b"] if edge["a"] == room_id else edge["a"])
                    if side in ("e", "w"):
                        self.assertIn('rotation = 1.570796', text)
                    else:
                        self.assertNotIn('rotation = 1.570796', text)
                    scene_text = (br.ROOT / f"scenes/world/{scene}.tscn").read_text(encoding="utf-8")
                    if kind == "resonance_stone":
                        self.assertIn("resonance_stone.gd", scene_text)
                        self.assertIn('look = &"resonance_stone"', scene_text)
                        runtime = (br.ROOT / "scripts/world/resonance_stone.gd").read_text(encoding="utf-8")
                        self.assertIn('return hitbox.kind == &"chime"', runtime)
                        self.assertIn('_shape.set_deferred("disabled", value)', runtime)
                    elif kind == "heavy_door":
                        self.assertIn("heavy_stone.gd", scene_text)
                        self.assertIn('look = &"heavy_door"', scene_text)
                        self.assertIn("mode = 1", scene_text)  # Scene-owned P06 PUSH mode.
                        self.assertNotIn("mode =", text)  # The compiler does not rewrite its mode.
                        runtime = (br.ROOT / "scripts/world/heavy_stone.gd").read_text(encoding="utf-8")
                        self.assertIn("if mode != Mode.PUSH", runtime)
                    elif kind == "eye_portcullis":
                        self.assertIn("eye_switch.gd", scene_text)
                        self.assertIn("blocker = true", scene_text)
                    else:
                        self.assertIn("burnable.gd", scene_text)
                        self.assertIn('look = &"thorn_wall"', scene_text)
                        runtime = (br.ROOT / "scripts/world/burnable.gd").read_text(encoding="utf-8")
                        self.assertIn('return hitbox.kind == &"fire"', runtime)
                        self.assertIn('_shape.set_deferred("disabled", true)', runtime)

    def test_step_openers_block_and_clear_the_actual_graph_corridors(self):
        for edge_id, kind, _, _, endpoints, extra_entities in self.STEP_CASES:
            for room_id in endpoints:
                with self.subTest(edge=edge_id, room=room_id):
                    self.assert_step_gate_geometry(edge_id, room_id, kind, extra_entities)

    def test_eye_cell_and_resonance_vault_use_their_real_door_scenes_and_links(self):
        text, errors, _, _, _, _ = self.compile(
            "e231", "cave_9_2", "eye_cell", extra_entities="eye_switch 12,3 id=e231")
        self.assertEqual(errors, [])
        self.assertIn('path="res://scenes/world/eye_cell.tscn"', text)
        self.assertIn('eye_id = &"e231"', text)
        self.assertEqual(self.assert_resolved_blocker_scene(text, "res://scenes/world/eye_cell.tscn"),
                         "../EyeCell1")
        eye_scene = (br.ROOT / "scenes/world/eye_cell.tscn").read_text(encoding="utf-8")
        self.assertIn("eye_switch.gd", eye_scene)
        self.assertIn("blocker = true", eye_scene)
        self.assertTrue(self.compile("e231", "cave_9_2", "eye_cell")[1], "the eye cell needs its linked switch")
        self.assertTrue(self.compile("e231", "cave_9_2", "eye_portcullis", extra_entities="eye_switch 12,3 id=e231")[1])

        text, errors, _, _, _, _ = self.compile("e232", "cave_9_9", "resonance_vault")
        self.assertEqual(errors, [])
        self.assertIn('path="res://scenes/world/resonance_vault.tscn"', text)
        self.assertIn('resonance_id = &"e232"', text)
        self.assertEqual(self.assert_resolved_blocker_scene(text, "res://scenes/world/resonance_vault.tscn"),
                         "../ResonanceVault1")
        self.assertNotIn("requires_flag", text)
        vault_scene = (br.ROOT / "scenes/world/resonance_vault.tscn").read_text(encoding="utf-8")
        self.assertIn("resonance_stone.gd", vault_scene)
        self.assertIn('look = &"resonance_vault"', vault_scene)

    def test_scene_types_graph_props_capabilities_and_options_are_exact(self):
        cases = (("e194", "cave_6_5", "resonance_stone", "resonance_door", ""),
                 ("e198", "cave_6_8", "heavy_door", "heavy_stone", ""),
                 ("e212", "cave_8_2", "eye_portcullis", "resonance_stone", "eye_switch 12,3 id=e212"),
                 ("e223", "cave_9_2", "thorn_wall", "thorn_door", ""),
                 ("e231", "cave_9_2", "eye_cell", "eye_portcullis", "eye_switch 12,3 id=e231"),
                 ("e232", "cave_9_9", "resonance_vault", "resonance_stone", ""),
                 ("e234", "cave_10_2", "thorn_wall", "thorn_door", ""),
                 ("e238", "cave_10_6", "resonance_stone", "resonance_door", ""),
                 ("e244", "cave_10_12", "eye_portcullis", "resonance_stone", "eye_switch 12,3 id=e244"))
        for edge_id, room_id, required, wrong, extra_entities in cases:
            with self.subTest(edge=edge_id, wrong=wrong):
                self.assertTrue(self.compile(edge_id, room_id, wrong, extra_entities=extra_entities)[1],
                                (edge_id, wrong))
                self.assertTrue(self.compile(edge_id, room_id, required, id_override="missing_edge",
                                             extra_entities=extra_entities)[1], (edge_id, "missing edge id"))
                for change in (dict(prop="unrelated prop"), dict(gate="bomb"), dict(needs=["pitch_pot"])):
                    self.assertTrue(self.compile(edge_id, room_id, required, edge_change=change,
                                                 extra_entities=extra_entities)[1],
                                    (edge_id, change))
                for option in ("mode=0", "look=rock", "scope=ow", "size=0,96"):
                    self.assertTrue(self.compile(edge_id, room_id, required, extra=option,
                                                 extra_entities=extra_entities)[1],
                                    (edge_id, option))

    def test_heavy_door_local_size_must_physically_seal_the_rotated_exit(self):
        # size= is the HeavyDoor scene's local body size; a 90-degree scene rotation swaps its
        # world footprint. The actual west endpoint cannot be sealed by a horizontal 192x96 body.
        _, errors, _, _, _, _ = self.compile("e198", "cave_6_8", "heavy_door", extra="size=96,192",
                                              position_override="@144,432")
        self.assertTrue(any("must span 192 px across its graph exit" in error for error in errors), errors)


class AnchorRingCrossings(unittest.TestCase):
    def compile(self, host="ow_10_4", anchors=None, pit="pit @960,528 size=1728,288", extra="", gate_change=None):
        edge = dict(next(e for e in real_world().edges if e["id"] == "e079"))
        edge.update(gate_change or {})
        rooms = [room_record("ow_10_4", ["n", "s"], grid=(10, 4)),
                 room_record("ow_10_5", ["n", "s"], grid=(10, 5))]
        world = world_of(rooms, edges=[edge])
        if host == "ow_10_4":
            spawn = "9,3"
            anchors = anchors if anchors is not None else "anchor_ring 9,9\nanchor_ring 9,2"
        else:
            spawn, pit = "9,6", "pit @960,432 size=1728,288"
            anchors = anchors if anchors is not None else "anchor_ring 9,0\nanchor_ring 9,7"
        source = room_text(host, ["n", "s"], f"spawn Default {spawn}\n{pit}\n{anchors}\n{extra}")
        return compile_text(source, world, host + ".room")

    def test_actual_e079_both_rooms_have_real_ring_targets_and_pit(self):
        for host in ("ow_10_4", "ow_10_5"):
            with self.subTest(host=host):
                text, errors = self.compile(host)
                self.assertEqual(errors, [])
                self.assertIn('res://scenes/world/anchor_ring.tscn', text)
                self.assertIn('res://scenes/world/pit.tscn', text)
                self.assertEqual(text.count('instance=ExtResource('), 3)
                self.assertNotIn('blocker_path', text)
                self.assertNotIn('requires_flag', text)
                self.assertNotIn('gate_id', text)

    def test_exports_and_invalid_options(self):
        text, errors = self.compile(anchors="anchor_ring 9,9 look=anchor_pocket max_range=576\nanchor_ring 9,2")
        self.assertEqual(errors, [])
        self.assertIn('look = &"anchor_pocket"', text)
        self.assertIn('max_range = 576.0', text)
        for options in ("max_range=-1", "max_range=nan", "max_range=inf", "max_range=no",
                        "look=rock", "id=e079", "size=96,96", "target_room=ow_10_5"):
            self.assertTrue(self.compile(anchors=f"anchor_ring 9,9 {options}\nanchor_ring 9,2")[1], options)

    def test_rejects_fake_gate_walking_boots_and_absent_return_route(self):
        for options, message in [
                (dict(pit=""), "walkable on foot"),
                (dict(anchors=""), "clear 576 px"),
                (dict(anchors="anchor_ring 9,9"), "return anchor"),
                (dict(pit="pit @960,528 size=1728,96"), "crossable with 192 px boots"),
                (dict(pit="pit @960,528 size=1536,288"), "walkable on foot")]:
            with self.subTest(options=options):
                _, errors = self.compile(**options)
                self.assertTrue(any(message in e for e in errors), errors)

    def test_chasm_width_is_measured_in_pixels_not_rounded_tiles(self):
        for width in (287, 481):
            _, errors = self.compile(pit=f"pit @960,528 size=1728,{width}")
            self.assertTrue(any("288–480 px chasm" in e for e in errors), errors)

    def test_rejects_blocked_ray_unsafe_landing_range_and_wrong_requirements(self):
        for options in (dict(extra="prop wall 9,7"),
                        dict(anchors="anchor_ring 9,6\nanchor_ring 9,2"),
                        dict(anchors="anchor_ring 9,9 max_range=575\nanchor_ring 9,2"),
                        dict(anchors="anchor_ring @912,1008\nanchor_ring 9,2"),
                        dict(anchors="anchor_ring 9,5\nanchor_ring 9,2"),
                        dict(gate_change={"needs": ["skitter_boots"]}),
                        dict(gate_change={"gate": "hidden"})):
            with self.subTest(options=options):
                self.assertTrue(self.compile(**options)[1])


class RemainingRegionMouths(unittest.TestCase):
    CASES = [("e253", "resonance_door", "resonance_id"),
             ("e144", "sealed_seam", "seam_id"),
             ("e255", "ninth_door", None)]

    def compile(self, edge_id, kind, extra="", edge_change=None, ident=None):
        return MissingMouthOpeners().compile(edge_id, kind, ident, extra, edge_change)

    def test_actual_mouth_scenes_exports_and_offset_physical_links(self):
        for edge, kind, field in self.CASES:
            with self.subTest(edge=edge):
                text, errors = self.compile(edge, kind)
                self.assertEqual(errors, [])
                self.assertIn(f'res://scenes/world/{kind}.tscn', text)
                self.assertIn('size = Vector2(192, 96)', text)
                self.assertIn(f'blocker_path = NodePath("../{br.camel(kind)}1")', text)
                if field:
                    self.assertIn(f'{field} = &"{edge}"', text)
                else:
                    self.assertNotIn(f'= &"{edge}"', text)  # NinthDoor has no exported id.
                self.assertNotIn('requires_flag', text)
                self.assertNotIn('hook_tap = true', text)

    def test_exact_requirements_even_with_custom_persistent_ids(self):
        for edge, kind, _ in self.CASES:
            for ident in (None, "custom_mouth"):
                for change in (dict(needs=["hook"]), dict(gate="bomb")):
                    self.assertTrue(self.compile(edge, kind, ident=ident, edge_change=change)[1])
            for option in ("look=rock", "hook_tap=true", "scope=c1", "size=0,96"):
                self.assertTrue(self.compile(edge, kind, extra=option)[1])
            self.assertTrue(self.compile(edge, "wax_seal")[1])
        fragments = [f"frag:c{i}" for i in range(1, 9)]
        self.assertTrue(self.compile("e255", "ninth_door", edge_change=dict(needs=fragments))[1])

    def test_real_openers_close_and_reopen_a_two_tile_passage(self):
        for edge_id, kind, _ in self.CASES:
            edge = dict(next(e for e in real_world().edges if e["id"] == edge_id))
            edge.update(a="ow_5_5", b="ow_5_6", link="step")
            text, errors = ScriptedGateExtensions().compile(
                f"opener {kind} @960,912 id={edge_id}", ["s"], edges=[edge])
            self.assertEqual(errors, [])
            self.assertIn('size = Vector2(192, 96)', text)
            _, errors = ScriptedGateExtensions().compile(
                f"opener {kind} 9,9 id={edge_id} size=96,96", ["s"], edges=[edge])
            self.assertTrue(any("walkable while closed" in e for e in errors), errors)

    def anchor_pocket(self, pit="pit @960,432 size=1728,288", anchors=None,
                      door="9,8", spawn="10,8", options="", change=None):
        edge = dict(next(e for e in real_world().edges if e["id"] == "e145"))
        edge.update(change or {})
        host, target = edge["a"], edge["b"]
        world = world_of([room_record(host, [])],
                         pockets=[dict(id=target, grid=[8, 30], host=host, scope="ow", in_place=False)],
                         edges=[edge])
        anchors = anchors if anchors is not None else "anchor_ring 9,8 look=anchor_pocket\nanchor_ring 9,1"
        text = room_text(host, [], f"spawn Default 9,2\nspawn FromPocket {spawn}\n{pit}\n{anchors}\n"
                         f"door {target} Inside {door} {options}")
        return compile_text(text, world, host + ".room")

    def test_world_body_overlapping_pit_still_stops_reel_tip(self):
        for pit in ("pit @960,432 size=1728,288\nprop wall 9,4",
                    "prop wall 9,4\npit @960,432 size=1728,288"):
            _, errors = self.anchor_pocket(pit=pit)
            self.assertTrue(any("clear 576 px reel pull" in e for e in errors), errors)

    def test_actual_e145_is_a_reel_chasm_mouth_not_a_fake_openable_ring(self):
        text, errors = self.anchor_pocket()
        self.assertEqual(errors, [])
        self.assertIn('look = &"anchor_pocket"', text)
        self.assertIn('target_room = &"ow_8_8#cache"', text)
        self.assertNotIn('blocker_path', text)
        self.assertNotIn('requires_flag', text)
        self.assertNotIn('gate_id', text)

    def test_anchor_mouth_rejects_all_bypasses_and_bad_return_spawn(self):
        for options in (dict(pit=""), dict(pit="pit @960,432 size=1728,96"),
                        dict(anchors=""), dict(anchors="anchor_ring 9,8"),
                        dict(door="9,2"), dict(spawn="9,2"),
                        dict(options="blocker=e145"), dict(change={"needs": ["hook"]})):
            with self.subTest(options=options):
                self.assertTrue(self.anchor_pocket(**options)[1])


class CisternCompilerGaps(unittest.TestCase):
    def raft(self, edge_id, host_is_a=True, water=True, post=True, narrow=False, prop=None):
        edge = dict(next(e for e in real_world().edges if e["id"] == edge_id))
        if prop is not None:
            edge["prop"] = prop
        graph = real_world()
        host = edge["a"] if host_is_a else edge["b"]
        other = edge["b"] if host_is_a else edge["a"]
        side = br.edge_side(graph, host, other)
        opposite = {"n": "s", "s": "n", "e": "w", "w": "e"}[side]
        world = world_of([room_record(host, [side], grid=tuple(graph.room(host)["grid"])),
                          room_record(other, [opposite], grid=tuple(graph.room(other)["grid"]))], edges=[edge])
        position, size, mooring = {
            "n": ("@960,192", "1728,192", "9,4"),
            "s": ("@960,768", "1728,192", "9,5"),
            "e": ("@1728,480", "192,768", "15,3"),
            "w": ("@192,480", "192,768", "4,3"),
        }[side]
        entities = []
        if water:
            entities.append(f"water {'5,2' if narrow else position} size={'96,96' if narrow else size}")
        if post:
            entities.append(f"mooring {mooring} id=source target_room={other} target_mooring=arrival")
        return compile_text(room_text(host, [side], "\n".join(entities)), world, host + ".room")

    def test_actual_flooded_edges_on_each_side_keep_water_and_paired_lane_exports(self):
        for edge_id in ("e167", "e168"):
            for host_is_a in (True, False):
                with self.subTest(edge=edge_id, side=host_is_a):
                    text, errors = self.raft(edge_id, host_is_a)
                    self.assertEqual(errors, [])
                    self.assertIn('res://scenes/world/water_zone.tscn', text)
                    self.assertIn('res://scenes/world/mooring.tscn', text)
                    self.assertIn('deep = true', text)
                    self.assertIn('mooring_id = &"source"', text)
                    self.assertIn('target_mooring = &"arrival"', text)
                    edge = next(e for e in real_world().edges if e["id"] == edge_id)
                    target = edge['b'] if host_is_a else edge['a']
                    self.assertIn(f'target_room = &"{target}"', text)

    def test_flooded_passages_keep_existing_denial_and_post_requirements(self):
        for edge_id in ("e167", "e168"):
            for options, message in [(dict(post=False), "needs a mooring"),
                                     (dict(water=False), "walkable on foot"),
                                     (dict(narrow=True), "walkable on foot")]:
                _, errors = self.raft(edge_id, **options)
                self.assertTrue(any(message in e for e in errors), errors)
            _, errors = self.raft(edge_id, post=False, prop="ordinary corridor")
            self.assertTrue(any("corridor blocked" in e for e in errors), errors)

    def test_actual_e164_emits_real_cuttable_moss_and_seals_then_opens(self):
        edge = dict(next(e for e in real_world().edges if e["id"] == "e164"))
        graph = real_world()
        for host, other, side, row in [(edge['a'], edge['b'], 'n', 0),
                                        (edge['b'], edge['a'], 's', 9)]:
            world = world_of([room_record(host, [side], grid=tuple(graph.room(host)["grid"])),
                              room_record(other, [], grid=tuple(graph.room(other)["grid"]))], edges=[edge])
            source = room_text(host, [side], f"opener cut_screen 9,{row} look=moss_wall\n"
                               f"opener cut_screen 10,{row} look=moss_wall")
            text, errors = compile_text(source, world, host + '.room')
            self.assertEqual(errors, [])
            self.assertIn('res://scenes/world/moss_wall.tscn', text)
            self.assertIn('[node name="MossWall1"', text)
            with tempfile.TemporaryDirectory() as tmp:
                path = Path(tmp) / (host + '.room')
                path.write_text(source)
                errors = []
                src = br.parse_source(path, errors)
                plan = br.build_plan(src, world, errors)
                self.assertEqual(errors, [])
                spawn = br.tile_of(*br.ROOM_CENTRE_PX)
                self.assertFalse(set(br.GAP_TILES[side]) & br.closed_flood(plan, spawn, None))
                self.assertTrue(set(br.GAP_TILES[side]) & br.closed_flood(plan, spawn, 0))
        scene = (br.ROOT / 'scenes/world/moss_wall.tscn').read_text()
        self.assertIn('scripts/world/bush.gd', scene)
        self.assertIn('variant = &"moss_wall"', scene)


class DryVineScreen(unittest.TestCase):
    def test_actual_e182_screen_uses_hook_cuttable_runtime_scene_and_keeps_approach(self):
        edge = dict(next(e for e in real_world().edges if e["id"] == "e182"))
        graph = real_world()
        for host, other, side, row in [(edge["a"], edge["b"], "n", 1),
                                       (edge["b"], edge["a"], "s", 8)]:
            world = world_of([room_record(host, [side], grid=tuple(graph.room(host)["grid"])),
                              room_record(other, [], grid=tuple(graph.room(other)["grid"]))], edges=[edge])
            default = "@1632,528" if host == edge["a"] else "@960,720"
            source = room_text(host, [side],
                               f"spawn Default {default}\n"
                               f"opener cut_screen 9,{row} look=dry_vine_screen\n"
                               f"opener cut_screen 10,{row} look=dry_vine_screen")
            text, errors = compile_text(source, world, host + ".room")
            self.assertEqual(errors, [])
            self.assertIn('res://scenes/world/dry_vine_screen.tscn', text)
            self.assertIn('[node name="DryVineScreen1"', text)
            self.assertEqual(text.count('instance=ExtResource('), 2)
            with tempfile.TemporaryDirectory() as tmp:
                path = Path(tmp) / (host + ".room")
                path.write_text(source)
                errors = []
                src = br.parse_source(path, errors)
                plan = br.build_plan(src, world, errors)
                self.assertEqual(errors, [])
                # Three tiles of clear approach remain behind the two screen tiles.
                spawn = br.tile_of(*br.ROOM_CENTRE_PX)
                self.assertFalse(set(br.GAP_TILES[side]) & br.closed_flood(plan, spawn, None))
                self.assertTrue(set(br.GAP_TILES[side]) & br.closed_flood(plan, spawn, 0))
                for col in (9, 10):
                    self.assertTrue(any((col, depth) not in plan.static
                                        for depth in range(1, br.EXIT_DEPTH + 1)))
        # A graph cut exit cannot compile as an open walk-through with no authored screen.
        _, errors = compile_text(room_text(edge["a"], ["n"], "spawn Default @1632,528"),
                                 world_of([room_record(edge["a"], ["n"], grid=tuple(graph.room(edge["a"])["grid"])),
                                           room_record(edge["b"], ["s"], grid=tuple(graph.room(edge["b"])["grid"]))],
                                          edges=[edge]), edge["a"] + ".room")
        self.assertTrue(any("cut exit n needs a screen" in e for e in errors), errors)
        # The same edge cannot silently receive a visually similar but semantically wrong screen.
        a, b = edge["a"], edge["b"]
        world = world_of([room_record(a, ["n"], grid=tuple(graph.room(a)["grid"])),
                          room_record(b, ["s"], grid=tuple(graph.room(b)["grid"]))], edges=[edge])
        _, errors = compile_text(room_text(a, ["n"],
            "spawn Default @1632,528\nopener cut_screen 9,1 look=moss_wall\nopener cut_screen 10,1 look=moss_wall"), world, a + ".room")
        self.assertTrue(any("look must match graph prop dry vine screen" in e for e in errors), errors)
        scene = (br.ROOT / "scenes/world/dry_vine_screen.tscn").read_text()
        script = (br.ROOT / "scripts/world/bush.gd").read_text()
        self.assertIn("scripts/world/bush.gd", scene)
        self.assertIn('variant = &"dry_vine_screen"', scene)
        self.assertIn('"dry_vine_screen"', script)
        self.assertIn('hitbox.kind == &"hook"', script)


class ExistingCaveAliases(unittest.TestCase):
    def compile_edge(self, edge_id, lines, wrong_edge=None, host_is_a=True):
        edge = dict(next(e for e in real_world().edges if e["id"] == edge_id))
        edge.update(wrong_edge or {})
        graph = real_world()
        host, target = (edge["a"], edge["b"]) if host_is_a else (edge["b"], edge["a"])
        rooms = [room_record(host, list(graph.room(host)["exits"]), grid=tuple(graph.room(host)["grid"])),
                 room_record(target, list(graph.room(target)["exits"]), grid=tuple(graph.room(target)["grid"]))]
        world = world_of(rooms, edges=[edge])
        source = room_text(host, list(graph.room(host)["exits"]), lines)
        return compile_text(source, world, host + ".room")

    def test_e172_eye_switch_alias_keeps_real_sling_control_and_portcullis(self):
        for edge_id in ("e172", "e212", "e244"):
            for host_is_a, opener_pos in ((True, "@960,48"), (False, "@960,912")):
                lines = f"eye_switch 12,3 id={edge_id}\nopener eye_portcullis {opener_pos} id={edge_id}"
                text, errors = self.compile_edge(edge_id, lines, host_is_a=host_is_a)
                self.assertEqual(errors, [])
                self.assertIn('res://scenes/world/eye_switch.tscn', text)
                self.assertIn('res://scenes/world/eye_portcullis.tscn', text)
                self.assertEqual(text.count(f'eye_id = &"{edge_id}"'), 2)
            self.assertIn('blocker = true', (br.ROOT / 'scenes/world/eye_portcullis.tscn').read_text())
        _, errors = self.compile_edge("e172", "eye_switch 12,3 id=e172\nopener eye_portcullis @960,48 id=e172",
                                      {"needs": ["reel_line"]})
        self.assertTrue(any("does not match the graph gate requirements" in e for e in errors), errors)
        _, errors = self.compile_edge("e172", "eye_switch 12,3 id=e172\nopener heavy_stone 9,0 id=e172")
        self.assertTrue(errors)

    def test_e175_singular_is_the_existing_lift_mode_heavy_stone(self):
        text, errors = self.compile_edge(
            "e175", "opener heavy_stone @960,48 id=e175 size=192,96")
        self.assertEqual(errors, [])
        self.assertIn('res://scenes/world/heavy_stone.tscn', text)
        self.assertIn('stone_id = &"e175"', text)
        self.assertIn('size = Vector2(192, 96)', text)
        scene = (br.ROOT / "scenes/world/heavy_stone.tscn").read_text()
        self.assertIn('mode = 0', scene)  # LIFT; singular gate is not the PUSH boulder.
        _, errors = self.compile_edge("e175", "opener heavy_boulder @960,48 id=e175 size=192,96")
        self.assertTrue(errors)
        for needs in (["pitch_pot"], ["heft_mitts", "tallow_sling"]):
            _, errors = self.compile_edge("e175", "opener heavy_stone @960,48 id=e175 size=192,96",
                                          {"needs": needs})
            self.assertTrue(any("graph gate requirements" in e for e in errors), errors)

    def test_e185_hidden_seam_uses_shared_reveal_id_and_real_closed_body(self):
        for host_is_a, position in ((True, "@960,48"), (False, "@960,912")):
            text, errors = self.compile_edge("e185", f"opener hidden_seam {position} id=e185",
                                             host_is_a=host_is_a)
            self.assertEqual(errors, [])
            self.assertIn('res://scenes/world/hidden_seam.tscn', text)
            self.assertIn('seam_id = &"e185"', text)
            self.assertIn('size = Vector2(192, 96)', text)
            self.assertNotIn('hook_tap = true', text)
            self.assertNotIn('RoomDoor', text)
            scene = (br.ROOT / "scenes/world/hidden_seam.tscn").read_text()
            script = (br.ROOT / "scripts/world/hidden_seam.gd").read_text()
            self.assertIn('look = &"hidden_seam"', scene)
            self.assertIn('revealable', script)
            wrong = self.compile_edge("e185", f"opener hidden_seam {position} id=e185 hook_tap=true",
                                      host_is_a=host_is_a)[1]
            self.assertTrue(wrong)
        for change in ({"needs": ["tether_moth"]}, {"gate": "item"}, {"prop": "sealed seam"}):
            _, errors = self.compile_edge("e185", "opener hidden_seam @960,48 id=e185", change)
            self.assertTrue(errors)
        # Without the seam the graph passage is accidentally open; a wrong id cannot bind e185.
        _, errors = self.compile_edge("e185", "")
        self.assertTrue(any("graph-linked seam" in e for e in errors), errors)
        _, errors = self.compile_edge("e185", "opener hidden_seam @960,48 id=other")
        self.assertTrue(any("id must match graph edge e185" in e for e in errors), errors)

    def test_hyphen_normalization_is_limited_to_encounter_scene_names(self):
        world = real_world()
        self.assertEqual(world.room("cave_4_4")["encounters"]["miniboss"], "lull_mauler")
        self.assertEqual(next(e["id"] for e in world.edges if e["id"] == "e175"), "e175")
        self.assertEqual(br.encounter_snake("Corrow's Echo"), "corrows_echo")
        self.assertEqual(world.room("cave_10_4")["encounters"]["miniboss"], "corrows_echo")
        for name in ("Lull-Mauler", "lull_mauler"):
            text, errors = compile_text(room_text("cave_4_4", world.room("cave_4_4")["exits"], f"miniboss {name} 10,5"),
                                        world, "cave_4_4.room")
            self.assertEqual(errors, [])
            self.assertIn('res://scenes/enemies/minibosses/lull_mauler.tscn', text)
        _, errors = compile_text(room_text("cave_4_4", world.room("cave_4_4")["exits"], "miniboss lull_mauler 10,5"),
                                 world, "cave_4_4.room")
        self.assertEqual(errors, [])


class CutScreenRespawnOutput(unittest.TestCase):
    def test_actual_variant_scenes_are_emitted_under_room_respawn_container(self):
        room = "cave_5_2"
        world = world_of([room_record(room, [])])
        room_script = (br.ROOT / "scripts/world/room.gd").read_text()
        self.assertIn('const RESPAWN_CONTAINERS: Array[StringName] = [&"Enemies", &"Bushes"]', room_script)
        self.assertIn('container.remove_child(child)', room_script)
        self.assertIn('var node: Node = template.duplicate()', room_script)
        self.assertIn('container.add_child(node)', room_script)
        for look in ("dry_vine_screen", "moss_wall", "reed_cluster"):
            with self.subTest(look=look):
                source = room_text(room, [], f"opener cut_screen 5,5 look={look}\n"
                                             f"opener cut_screen 6,5 look={look}")
                text, errors = compile_text(source, world, room + ".room")
                self.assertEqual(errors, [])
                scene_path = f"res://scenes/world/{look}.tscn"
                self.assertIn(f'path="{scene_path}"', text)
                self.assertEqual(text.count(f'instance=ExtResource('), 2)
                self.assertEqual(text.count('parent="Bushes" instance=ExtResource('), 2)
                self.assertNotIn('parent="Props" instance=ExtResource(', text)
                # Two authored Bush templates; cut frees one live copy, leave clears the other,
                # and enter duplicates both templates back into the tracked container.
                templates = [line for line in text.splitlines()
                             if line.startswith('[node name=') and 'parent="Bushes"' in line]
                active = list(templates)
                active.pop(0)
                active.clear()  # Room.leave/_clear_respawn_containers.
                active.extend(templates)  # Room.enter/template.duplicate/add_child.
                self.assertEqual(len(active), 2)
                self.assertEqual(active, templates)
                runtime_scene = (br.ROOT / f"scenes/world/{look}.tscn").read_text()
                self.assertIn('scripts/world/bush.gd', runtime_scene)

    def test_actual_e182_closed_open_and_regrow_use_the_tracked_parent(self):
        edge = dict(next(e for e in real_world().edges if e["id"] == "e182"))
        graph = real_world()
        host = edge["a"]
        target = edge["b"]
        world = world_of([room_record(host, graph.room(host)["exits"], graph.room(host)["enemies"],
                                         graph.room(host)["grid"]),
                          room_record(target, graph.room(target)["exits"], graph.room(target)["enemies"],
                                      graph.room(target)["grid"])],
                         edges=[edge])
        source = (br.ROOT / "tools/rooms/cave_5_2.room").read_text()
        text, errors = compile_text(source, world, "cave_5_2.room")
        self.assertEqual(errors, [])
        self.assertEqual(text.count('parent="Bushes" instance=ExtResource('), 2)
        self.assertNotIn('parent="Props" instance=ExtResource(', text)
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "cave_5_2.room"
            path.write_text(source)
            errors = []
            src = br.parse_source(path, errors)
            plan = br.build_plan(src, world, errors)
            self.assertEqual(errors, [])
            closed = br.closed_flood(plan, (17, 5), None)
            opened = br.closed_flood(plan, (17, 5), 0)
            self.assertFalse(set(br.GAP_TILES["n"]) & closed)
            self.assertTrue(set(br.GAP_TILES["n"]) & opened)


class CavePilot(unittest.TestCase):
    def encounter_world(self, role="boss", name="Kilnkeeper"):
        record = room_record("cave_1_8", [])
        record["scope"] = "c1"
        return br.World({"rooms": [record], "pockets": [], "edges": [], "pickups": [], "items": {}},
                        graph={"nodes": [{"id": record["id"], role: {"name": name}}]})

    def test_raw_graph_roles_survive_empty_runtime_enemy_counts(self):
        world = real_world()
        self.assertEqual(world.room("cave_1_5")["encounters"], {"miniboss": "hollow_captain"})
        self.assertEqual(world.room("cave_1_8")["encounters"], {"boss": "kilnkeeper"})

    def test_encounters_use_owned_scene_directories(self):
        from unittest.mock import patch
        for role, name, directory in (("boss", "kilnkeeper", "bosses"),
                                       ("miniboss", "hollow_captain", "minibosses")):
            with self.subTest(role=role), patch.object(Path, "is_file", return_value=True):
                text, errors = compile_text(room_text("cave_1_8", [], f"{role} {name} 5,5"),
                                            self.encounter_world(role, name), "cave_1_8.room")
                self.assertEqual(errors, [])
                self.assertIn(f"res://scenes/enemies/{directory}/{name}.tscn", text)

    def test_missing_encounter_scene_fails(self):
        from unittest.mock import patch
        original = Path.is_file
        with patch.object(Path, "is_file", lambda p: False if p.name == "kilnkeeper.tscn" else original(p)):
            text, errors = compile_text(room_text("cave_1_8", [], "boss kilnkeeper 5,5"),
                                        self.encounter_world(), "cave_1_8.room")
        self.assertIsNone(text)
        self.assertTrue(any("bosses/kilnkeeper.tscn does not exist" in e for e in errors))

    def test_missing_wrong_duplicate_and_regular_encounters_fail(self):
        for entities in ("", "boss hollow_captain 5,5", "boss kilnkeeper 5,5\nboss kilnkeeper 6,5",
                         "enemy kilnkeeper 5,5", "miniboss kilnkeeper 5,5"):
            text, errors = compile_text(room_text("cave_1_8", [], entities), self.encounter_world(), "cave_1_8.room")
            self.assertIsNone(text)
            self.assertTrue(any("graph" in e for e in errors), errors)

    def test_arena_explicit_position_and_missing_resource(self):
        from unittest.mock import patch
        source = room_text("cave_1_8", [], "boss kilnkeeper 5,5\narena kilnkeeper @0,0")
        with patch.object(Path, "is_file", return_value=True):
            text, errors = compile_text(source, self.encounter_world(), "cave_1_8.room")
        self.assertEqual(errors, [])
        self.assertIn('path="res://scenes/bosses/kilnkeeper_arena.tscn"', text)
        self.assertIn('[node name="Arena1" parent="Props"', text)
        self.assertIn("position = Vector2(0, 0)", text)
        original = Path.is_file
        arena_path = br.ROOT / "scenes/bosses/kilnkeeper_arena.tscn"
        with patch.object(Path, "is_file", lambda p: False if p == arena_path else original(p)):
            missing_text, errors = compile_text(source, self.encounter_world(), "cave_1_8.room")
        self.assertIsNone(missing_text)
        self.assertTrue(any("kilnkeeper_arena.tscn does not exist" in e for e in errors))

    def test_wrong_duplicate_and_malformed_arena_fail(self):
        for arena in ("arena hollow @0,0", "arena kilnkeeper @0,0\narena kilnkeeper @0,0",
                      "arena kilnkeeper", "arena kilnkeeper @0,0 file=anything"):
            text, errors = compile_text(room_text("cave_1_8", [], "boss kilnkeeper 5,5\n" + arena),
                                        self.encounter_world(), "cave_1_8.room")
            self.assertIsNone(text)
            self.assertTrue(errors)

    def gate_world(self, kind="brazier"):
        a = room_record("cave_1_4", ["n"], grid=(2,13))
        b = room_record("cave_1_5", ["s"], grid=(2,12))
        a["scope"] = b["scope"] = "c1"
        return world_of([a,b], edges=[{"id": "e149", "a": a["id"], "b": b["id"],
            "gate": kind, "link": "step", "prop": "two braziers, gate" if kind == "brazier" else "boss door",
            "needs": ["hook"] if kind == "brazier" else ["bigkey:c1"]}])

    def gate_source(self, opener="opener gate @960,48 id=e149 braziers=left,right"):
        return room_text("cave_1_4", ["n"], "brazier 5,5 id=right\nbrazier 4,5 id=left\n" + opener)

    def test_gate_wires_ids_to_sorted_node_names(self):
        source = (FIXTURES / "cave_pilot.room").read_text()
        text, errors = compile_text(source, self.gate_world(), "cave_1_4.room")
        self.assertEqual(text, (FIXTURES / "expected_cave_pilot.tscn").read_text())
        self.assertEqual(errors, [])
        self.assertIn('braziers = Array[NodePath]([NodePath("../Brazier1"), NodePath("../Brazier2")])', text)
        self.assertIn('gate_id = &"e149"', text)
        self.assertIn('brazier_id = &"left"', text)

    def test_gate_bad_links_policy_and_placement_fail(self):
        for source in (self.gate_source().replace("left,right", "left,missing"),
                       self.gate_source().replace("left,right", "left,left"),
                       self.gate_source().replace("left,right", "left"),
                       self.gate_source().replace("id=right", "id=left"),
                       self.gate_source().replace("id=e149", "id=e999"),
                       self.gate_source().replace("@960,48", "5,4"),
                       self.gate_source().replace("@960,48", "9,0")):
            text, errors = compile_text(source, self.gate_world(), "cave_1_4.room")
            self.assertIsNone(text)
            self.assertTrue(errors)

    def test_east_boss_door_swaps_footprint(self):
        world = self.gate_world("boss")
        world.rooms["cave_1_4"]["exits"] = ["e"]
        world.rooms["cave_1_5"]["grid"] = (3, 13)
        source = room_text("cave_1_4", ["e"], "opener boss_door @1872,480 id=e149")
        text, errors = compile_text(source, world, "cave_1_4.room")
        self.assertEqual(errors, [])
        self.assertIn("size = Vector2(96, 192)", text)

    def test_brazier_on_obstacle_is_rejected(self):
        source = self.gate_source().replace("brazier 5,5", "brazier 0,0")
        text, errors = compile_text(source, self.gate_world(), "cave_1_4.room")
        self.assertIsNone(text)
        self.assertTrue(any("brazier overlaps a solid obstacle" in e for e in errors))

    def test_boss_door_uses_actual_cave_export(self):
        text, errors = compile_text(self.gate_source("opener boss_door @960,48 id=e149"),
                                    self.gate_world("boss"), "cave_1_4.room")
        self.assertEqual(errors, [])
        self.assertIn('path="res://scenes/world/boss_door.tscn"', text)
        self.assertIn('cave = &"c1"', text)
        self.assertNotIn('door_id', text)

    def test_boss_door_rejects_other_cave_key_and_wrong_gate(self):
        for world in (self.gate_world(), self.gate_world("boss")):
            world.edges[0]["needs"] = ["bigkey:c2"]
            text, errors = compile_text(self.gate_source("opener boss_door @960,48 id=e149"),
                                        world, "cave_1_4.room")
            self.assertIsNone(text)
            self.assertTrue(errors)

    def test_standalone_generated_arena_fights_with_one_persistent_reward_each(self):
        import os
        import subprocess
        source = room_text("cave_1_8", ["w"],
                           "arena kilnkeeper @0,0\nboss kilnkeeper @1488,480\n"
                           "pickup fragment @960,480 id=frag_c1 scope=c1 requires=boss_cave_1_8_defeated\n"
                           "pickup wick_core @1152,480 id=wick_core_c1 requires=boss_cave_1_8_defeated\n"
                           "spawn Default @192,480")
        text, errors = compile_text(source, real_world(), "cave_1_8.room")
        self.assertEqual(errors, [])
        with tempfile.TemporaryDirectory() as tmp:
            fixture = Path(tmp) / "kilnkeeper_reward.tscn"
            fixture.write_text(text, encoding="utf-8")
            env = dict(os.environ, WICKWARDEN_KILNKEEPER_ROOM=str(fixture))
            result = subprocess.run([sys.executable, str(br.ROOT / "tools/run_godot_check.py"),
                                     "boss_kilnkeeper"], cwd=br.ROOT, env=env,
                                    capture_output=True, text=True, timeout=90)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_arena_reward_declarations_reject_duplicate_and_kind_mismatch(self):
        base = ("arena kilnkeeper @0,0\nboss kilnkeeper 15,5\n"
                "pickup fragment 10,5 id=frag_c1 scope=c1 requires=boss_cave_1_8_defeated\n"
                "pickup wick_core 12,5 id=wick_core_c1 requires=boss_cave_1_8_defeated")
        for entities, diagnostic in (
            (base + "\npickup fragment 9,5 id=frag_c1 scope=c1 requires=boss_cave_1_8_defeated", "placed twice"),
            (base.replace("pickup fragment", "pickup wick_core").replace(" scope=c1", ""), "graph says fragment"),
        ):
            with self.subTest(diagnostic=diagnostic):
                text, errors = compile_text(room_text("cave_1_8", ["w"], entities),
                                            real_world(), "cave_1_8.room")
                self.assertIsNone(text)
                self.assertTrue(any(diagnostic in error for error in errors), errors)

    def test_both_boss_reward_kinds_need_exact_room_flag(self):
        world = real_world()
        rewards = {p["id"]:p for p in world.pickups}
        self.assertTrue(rewards["wick_core_c1"]["after_boss"])
        self.assertTrue(rewards["frag_c1"]["after_boss"])
        from unittest.mock import patch
        base = "boss kilnkeeper 5,5\npickup fragment 10,5 id=frag_c1 requires=boss_cave_1_8_defeated\npickup wick_core 12,5 id=wick_core_c1 requires=boss_cave_1_8_defeated"
        for wrong in ("boss_cave_2_9_defeated", "boss_nonsense_defeated", ""):
            for ident in ("frag_c1", "wick_core_c1"):
                entities = base.replace(f"id={ident} requires=boss_cave_1_8_defeated", f"id={ident} requires={wrong}")
                text, errors = compile_text(room_text("cave_1_8", ["w"], entities), world, "cave_1_8.room")
                self.assertIsNone(text)
                self.assertTrue(any(f"{ident} comes after a boss" in e for e in errors), errors)
        with patch.object(Path, "is_file", return_value=True):
            text, errors = compile_text(room_text("cave_1_8", ["w"], base), world, "cave_1_8.room")
        self.assertEqual(errors, [])


class CavePickupPrerequisites(unittest.TestCase):
    def test_cave_capability_pickups_infer_scope_and_reject_wrong_override(self):
        for kind, ident, capability in (("big_key", "bigkey_c1", "bigkey:c1"),
                                         ("fragment", "frag_c1", "frag:c1")):
            world = world_of([dict(room_record("cave_1_7", []), scope="c1")],
                             items={capability: {"node": "cave_1_7"}})
            for suffix in ("", " scope=c1"):
                text, errors = compile_text(room_text("cave_1_7", [], f"pickup {kind} 5,5 id={ident}" + suffix),
                                            world, "cave_1_7.room")
                self.assertEqual(errors, [])
                self.assertIn('scope = &"c1"', text)
            for scope in ("ow", "c2", ""):
                text, errors = compile_text(room_text("cave_1_7", [], f"pickup {kind} 5,5 id={ident} scope={scope}"),
                                            world, "cave_1_7.room")
                self.assertIsNone(text)
                self.assertTrue(any("scope" in e for e in errors))

    def test_missing_graph_cave_scope_is_rejected(self):
        for kind in ("big_key", "fragment"):
            world = world_of([room_record("ow_5_5", [])],
                             pickups=[{"id": "bad_reward", "node": "ow_5_5", "kind": kind}])
            text, errors = compile_text(room_text("ow_5_5", [], f"pickup {kind} 5,5 id=bad_reward"), world, "ow_5_5.room")
            self.assertIsNone(text)
            self.assertTrue(any("graph cave scope" in e for e in errors))

    def test_legacy_alcove_key_retains_graph_overworld_scope(self):
        world = real_world()
        self.assertEqual(world.pickup_record("key_ow_1")["scope"], "ow")
        source = br.Source(Path("cave_1.room"))
        source.room_id, source.scope = "cave_1", "c1"
        ent = br.Entity("pickup", 1, (960,480), ["small_key"], {"id": "key_ow_1"})
        plan, errors = br.Plan(), []
        self.assertTrue(br.dispatch_pickup(ent, (0,0,0), source, plan, world, errors))
        props = dict(plan.singles[0][1].props)
        self.assertEqual(props["persistent_id"], '&"cave_key"')
        self.assertNotIn("scope", props)  # PickupBase's unchanged default is ow.
        ent.opts["scope"] = "c1"
        self.assertFalse(br.dispatch_pickup(ent, (0,0,0), source, br.Plan(), world, errors))

    def moth_room(self, key="5,1", grate=True, bypass=False, wall=False, spawn="5,5", extra=""):
        world = real_world()
        grid = open_grid(["s"])
        grid[3] = "#" * 20
        if grate:
            grid[3] = grid[3][:5] + ".." + grid[3][7:]
        if bypass:
            grid[3] = grid[3][:15] + "." + grid[3][16:]
        if wall:
            grid[2] = "#" * 20
        lines = [f"spawn Default {spawn}", f"pickup small_key {key} id=key_c1_1",
                 "enemy wickling 8,5", "enemy wickling 12,5", extra]
        if grate:
            lines.append("grate @576,336 size=192,96")
        source = "\n".join(["room cave_1_3", "grid", *grid, *lines])
        return source, world

    def test_real_cave_1_3_room_key_is_sealed_and_moth_fetchable(self):
        source = (FIXTURES / "cave_moth_key.room").read_text()
        text, errors = compile_text(source, real_world(), "cave_1_3.room")
        self.assertEqual(text, (FIXTURES / "expected_cave_moth_key.tscn").read_text())
        self.assertEqual(errors, [])
        self.assertIn('scope = &"c1"', text)
        self.assertIn('persistent_id = &"key_c1_1"', text)

    def test_room_key_walkable_far_blocked_or_wrong_entry_is_rejected(self):
        for opts in ({"grate": False}, {"bypass": True}, {"key": "15,1"}, {"wall": True},
                     {"spawn": "5,1"}, {"extra": "spawn FromOverworld 5,1"}):
            with self.subTest(opts=opts):
                source, world = self.moth_room(**opts)
                text, errors = compile_text(source, world, "cave_1_3.room")
                self.assertIsNone(text)
                self.assertTrue(any("moth pickup" in e for e in errors), errors)

    def test_room_key_wrong_explicit_scope_is_rejected(self):
        source, world = self.moth_room()
        text, errors = compile_text(source.replace("id=key_c1_1", "id=key_c1_1 scope=ow"), world, "cave_1_3.room")
        self.assertIsNone(text)
        self.assertTrue(any("graph says c1" in e for e in errors))

    def test_room_key_checks_exit_entry_even_if_default_can_fetch(self):
        source, world = self.moth_room()
        world.rooms["cave_1_3"]["exits"].append("n")
        rows = source.splitlines()
        rows[2] = open_grid(["s", "n"])[0]
        text, errors = compile_text("\n".join(rows), world, "cave_1_3.room")
        self.assertIsNone(text)
        self.assertTrue(any("moth pickup" in e for e in errors), errors)


if __name__ == "__main__":
    unittest.main()
