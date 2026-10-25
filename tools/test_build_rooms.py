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
        self.assertTrue(any("opener cut_screen needs look=reed_cluster or look=rush_wall" in e for e in errors), errors)

    def hidden_stairs_world(self) -> br.World:
        return world_of(
            [room_record("ow_0_2", ["e"]), room_record("cave_9_1", [])],
            edges=[{"id": "e254", "a": "ow_0_2", "b": "cave_9_1", "link": "door", "gate": "hidden",
                    "needs": ["glow_jar"], "dir": "both", "prop": "hidden stairs"}],
        )

    def test_hidden_stairs_builds_a_persistent_target_door(self) -> None:
        text, errors = compile_text(
            room_text("ow_0_2", ["e"], "hidden_stairs cave_9_1 FromOverworld 5,5 id=lamp_stairs"),
            self.hidden_stairs_world(),
            "ow_0_2.room",
        )
        self.assertEqual(errors, [])
        self.assertIn('path="res://scenes/world/hidden_stairs.tscn"', text or "")
        self.assertIn('seam_id = &"lamp_stairs"', text or "")
        self.assertIn('door_target = &"cave_9_1"', text or "")
        self.assertIn('door_spawn = &"FromOverworld"', text or "")

    def test_hidden_stairs_must_target_a_graph_door_partner(self) -> None:
        _, errors = compile_text(
            room_text("ow_0_2", ["e"], "hidden_stairs cave_9_2 FromOverworld 5,5 id=lamp_stairs"),
            self.hidden_stairs_world(),
            "ow_0_2.room",
        )
        self.assertTrue(any("door to cave_9_2 is not a door of the graph for ow_0_2" in e for e in errors), errors)


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
        edge = dict(id="e063", a="ow_5_5", b="ow_5_6", prop="heavy stones", link="step", gate="item")
        self.assertTrue(self.compile("opener thorn_door 15,4 id=e063", edges=[edge])[1])

    def test_heavy_gate_must_seal_both_gap_tiles(self):
        edge = dict(id="e063", a="ow_5_5", b="ow_5_6", prop="heavy stones", link="step", gate="item")
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
                    self.assertIn(f'blocker_path = NodePath("../{name}")', text)
                    self.assertNotIn('requires_flag', text)

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
