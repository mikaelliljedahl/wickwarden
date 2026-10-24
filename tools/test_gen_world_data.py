#!/usr/bin/env python3
"""Unit tests of tools/gen_world_data.py. Run: python3 -m unittest tools/test_gen_world_data.py"""

from __future__ import annotations

import contextlib
import copy
import hashlib
import io
import json
import re
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import gen_world_data as gwd  # noqa: E402

PLAN_PATH = gwd.ROOT / "docs" / "world-plan.md"


def graph_bytes() -> bytes:
    return gwd.GRAPH_PATH.read_bytes()


def fresh_graph() -> dict:
    return json.loads(graph_bytes())


def node_by_id(graph: dict, node_id: str) -> dict:
    return next(node for node in graph["nodes"] if node["id"] == node_id)


def build_from(graph: dict) -> dict:
    return gwd.build(graph, json.dumps(graph).encode("utf-8"))


def plan_cave_rows() -> dict[int, tuple[str | None, str]]:
    """Cave number -> (lantern or None, entrance room) from the cave table of world-plan section 4."""
    rows: dict[int, tuple[str | None, str]] = {}
    in_table = False
    for line in PLAN_PATH.read_text(encoding="utf-8").splitlines():
        if line.startswith("| Cave | Name | Lantern |"):
            in_table = True
            continue
        if not in_table:
            continue
        if not line.startswith("|"):
            break
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        number = re.match(r"^C(\d+)$", cells[0])
        if number is None:
            continue
        lantern_word = cells[2].split(" ")[0]
        lantern = None if lantern_word.startswith("none") else lantern_word
        rows[int(number.group(1))] = (lantern, cells[3].strip("`"))
    return rows


class BuildTest(unittest.TestCase):
    def setUp(self) -> None:
        self.data = gwd.build(fresh_graph(), graph_bytes())

    def test_counts_match_the_graph(self) -> None:
        self.assertEqual(len(self.data["rooms"]), 192)
        self.assertEqual(len(self.data["pockets"]), 33)
        self.assertEqual(len(self.data["edges"]), 259)
        self.assertEqual(len(self.data["pickups"]), 73)
        self.assertEqual(len(self.data["items"]), 29)
        self.assertEqual(len(self.data["shops"]), 6)
        self.assertEqual(len(self.data["caves"]), gwd.CAVE_COUNT)

    def test_source_sha_is_the_sha256_of_the_graph_file(self) -> None:
        self.assertEqual(self.data["source_sha"], hashlib.sha256(graph_bytes()).hexdigest())

    def test_source_sha_follows_the_graph_bytes(self) -> None:
        changed = graph_bytes() + b"\n"
        other = gwd.build(json.loads(changed), changed)
        self.assertNotEqual(other["source_sha"], self.data["source_sha"])

    def test_scene_paths_use_the_agreed_names(self) -> None:
        room = next(r for r in self.data["rooms"] if r["id"] == "cave_1_4")
        self.assertEqual(room["scene"], "res://scenes/world/rooms/cave_1_4.tscn")
        shop = next(p for p in self.data["pockets"] if p["id"] == "ow_1_2#shop")
        self.assertEqual(shop["scene"], "res://scenes/world/rooms/ow_1_2__shop.tscn")
        self.assertFalse(shop["in_place"])

    def test_exactly_three_pockets_are_in_place_without_scene(self) -> None:
        in_place = sorted(p["id"] for p in self.data["pockets"] if p["in_place"])
        self.assertEqual(in_place, sorted(gwd.IN_PLACE))
        for pocket in self.data["pockets"]:
            if pocket["in_place"]:
                self.assertIsNone(pocket["scene"], pocket["id"])
            else:
                self.assertEqual(pocket["scene"], "res://scenes/world/rooms/%s.tscn" % pocket["id"].replace("#", "__"))

    def test_pocket_grids_sit_in_the_pocket_row_and_are_unique(self) -> None:
        pocket_grids = [tuple(p["grid"]) for p in self.data["pockets"]]
        self.assertTrue(all(y == gwd.POCKET_ROW for _, y in pocket_grids))
        room_grids = {tuple(r["grid"]) for r in self.data["rooms"]}
        self.assertEqual(len(room_grids), len(self.data["rooms"]))
        self.assertEqual(len(set(pocket_grids)), len(pocket_grids))
        self.assertFalse(room_grids & set(pocket_grids))

    def test_cave_rooms_sit_in_rows_12_and_later(self) -> None:
        for room in self.data["rooms"]:
            if room["scope"] != "ow":
                self.assertGreaterEqual(room["grid"][1], 12, room["id"])
            else:
                self.assertLessEqual(room["grid"][1], 8, room["id"])

    def test_dark_follows_the_graph(self) -> None:
        # Decision 42: every cave room is dark (boss arenas included) except the ten rooms of cave 9.
        dark = [room["id"] for room in self.data["rooms"] if room["dark"]]
        cave_9 = [room["id"] for room in self.data["rooms"] if room["scope"] == "c9"]
        self.assertEqual(len(cave_9), 10)
        self.assertEqual(len(dark), 94)
        self.assertFalse(set(dark) & set(cave_9))
        self.assertIn("cave_1_8", dark)
        graph = fresh_graph()
        node_by_id(graph, "cave_1_8")["dark"] = False
        data = build_from(graph)
        dark = [room["id"] for room in data["rooms"] if room["dark"]]
        self.assertEqual(len(dark), 93)
        self.assertNotIn("cave_1_8", dark)

    def test_caves_match_the_cave_table_of_the_plan(self) -> None:
        rows = plan_cave_rows()
        self.assertEqual(sorted(rows), list(range(1, gwd.CAVE_COUNT + 1)))
        for cave in self.data["caves"]:
            lantern, entrance = rows[cave["number"]]
            self.assertEqual(cave["lantern"], lantern, cave["scope"])
            self.assertEqual(cave["mouth"], entrance, cave["scope"])

    def test_pickups_and_items_keep_their_fields_without_contents(self) -> None:
        for pickup in self.data["pickups"]:
            self.assertNotIn("contents", pickup)
            self.assertIn("node", pickup)
        self.assertEqual(self.data["items"]["tether_moth"], {"node": "ow_0_1"})

    def test_every_edge_joins_known_nodes(self) -> None:
        known = {r["id"] for r in self.data["rooms"]} | {p["id"] for p in self.data["pockets"]}
        for edge in self.data["edges"]:
            self.assertIn(edge["a"], known)
            self.assertIn(edge["b"], known)

    def test_render_is_valid_json_and_deterministic(self) -> None:
        text = gwd.render(self.data)
        self.assertEqual(json.loads(text), self.data)
        self.assertEqual(gwd.render(gwd.build(fresh_graph(), graph_bytes())), text)


class RejectionTest(unittest.TestCase):
    def assert_rejected(self, graph: dict, why: str) -> None:
        with self.assertRaises(gwd.GraphError, msg=why):
            build_from(graph)

    def test_wrong_format_is_rejected(self) -> None:
        graph = fresh_graph()
        graph["format"] = 2
        self.assert_rejected(graph, "format")

    def test_duplicate_node_id_is_rejected(self) -> None:
        graph = fresh_graph()
        graph["nodes"].append(copy.deepcopy(graph["nodes"][0]))
        self.assert_rejected(graph, "duplicate node")

    def test_exit_without_step_link_is_rejected(self) -> None:
        graph = fresh_graph()
        node_by_id(graph, "ow_0_0")["exits"] = ["e"]
        self.assert_rejected(graph, "exits must equal step links")

    def test_lower_side_of_a_ledge_drop_must_not_list_the_side(self) -> None:
        graph = fresh_graph()
        node_by_id(graph, "ow_4_3")["exits"].append("n")
        self.assert_rejected(graph, "one-way lower room lists the ledge")

    def test_two_rooms_on_one_cell_are_rejected(self) -> None:
        graph = fresh_graph()
        node_by_id(graph, "ow_1_0")["grid"] = [0, 0]
        self.assert_rejected(graph, "shared grid cell")

    def test_pickup_on_unknown_node_is_rejected(self) -> None:
        graph = fresh_graph()
        graph["pickups"][0]["node"] = "nowhere"
        self.assert_rejected(graph, "unknown pickup node")

    def test_non_boolean_dark_is_rejected(self) -> None:
        graph = fresh_graph()
        node_by_id(graph, "ow_0_0")["dark"] = "yes"
        self.assert_rejected(graph, "dark must be a bool")

    def test_cave_without_a_mouth_is_rejected(self) -> None:
        graph = fresh_graph()
        graph["edges"] = [e for e in graph["edges"] if e["id"] != "e246"]
        self.assert_rejected(graph, "cave 1 has no door from the overworld")


def run_quietly(argv: list[str]) -> int:
    with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
        return gwd.main(argv)


class CommandTest(unittest.TestCase):
    def test_check_fails_on_a_missing_or_stale_file_and_passes_after_writing(self) -> None:
        with tempfile.TemporaryDirectory() as folder:
            out = Path(folder) / "world_data.json"
            self.assertEqual(run_quietly(["--check", "--out", str(out)]), 1)
            self.assertEqual(run_quietly(["--out", str(out)]), 0)
            self.assertEqual(run_quietly(["--check", "--out", str(out)]), 0)
            out.write_text(out.read_text(encoding="utf-8") + " ", encoding="utf-8")
            self.assertEqual(run_quietly(["--check", "--out", str(out)]), 1)

    def test_invalid_graph_exits_with_two(self) -> None:
        with tempfile.TemporaryDirectory() as folder:
            graph = fresh_graph()
            graph["format"] = 9
            path = Path(folder) / "graph.json"
            path.write_text(json.dumps(graph), encoding="utf-8")
            out = Path(folder) / "world_data.json"
            self.assertEqual(run_quietly(["--graph", str(path), "--out", str(out)]), 2)
            self.assertFalse(out.exists())

    def test_committed_data_is_current(self) -> None:
        self.assertEqual(run_quietly(["--check"]), 0, "data/world_data.json is stale; run make world-data")


if __name__ == "__main__":
    unittest.main()
