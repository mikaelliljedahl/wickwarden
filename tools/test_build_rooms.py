#!/usr/bin/env python3
"""Unit tests of tools/build_rooms.py. Run: python3 -m unittest tools/test_build_rooms.py

The round trip compiles tests/fixtures/rooms/ow_0_1.room with the real world data and compares the node
list with tests/fixtures/rooms/expected_ow_0_1.tscn (the hand-made scene of the same room). The other tests
change that fixture, or build a small synthetic world, and check that the compiler rejects the change.
"""

from __future__ import annotations

import contextlib
import io
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


def node_list(text: str) -> list[str]:
    """Node headers and properties with ExtResource ids replaced by their paths (ids differ by writer)."""
    ext = {ident: path for _, path, ident in re.findall(r'\[ext_resource type="(\w+)" path="([^"]+)" id="(\d+)"\]', text)}
    out = []
    for line in text.splitlines():
        if line.startswith("[node") or re.match(r"^\w+ = ", line):
            out.append(re.sub(r'ExtResource\("(\d+)"\)', lambda m: "RES(" + ext[m.group(1)] + ")", line))
    return out


def real_world() -> br.World:
    return br.World(__import__("json").loads(br.WORLD_FILE.read_text(encoding="utf-8")))


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
             edges: list[dict] | None = None, items: dict | None = None) -> br.World:
    return br.World({
        "rooms": rooms,
        "pockets": pockets or [],
        "pickups": pickups or [],
        "edges": edges or [],
        "items": items or {},
    })


def room_record(room_id: str, exits: list[str], enemies: dict | None = None, grid=(5, 5)) -> dict:
    return {"id": room_id, "grid": list(grid), "exits": exits, "dark": False, "scope": "ow",
            "enemies": enemies or {}, "scene": "", "region": "x", "name": "x"}


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


if __name__ == "__main__":
    unittest.main()
