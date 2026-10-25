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


if __name__ == "__main__":
    unittest.main()
