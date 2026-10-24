#!/usr/bin/env python3
"""Tests for tools/check_ownership.py. Synthetic manifests and document snippets.

    python3 -m unittest tools/test_check_ownership.py
"""

import json
import subprocess
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import check_ownership as co  # noqa: E402

TOOLS = Path(__file__).resolve().parent
DOC_SNIPPET = """\
## 5. Wave 0: foundation

### G1. Graph amendments (Sonnet)

- **Owns:** `docs/world-graph.json`.

## 6. Wave 1: parts

| ID, model | Depends | Owns | Deliverable | Test |
|---|---|---|---|---|
| P01 Burnable, Haiku | F4 | `burnable.gd` | Hedge | fire opens |

## 7. Wave 2: regions

| WP, model | Depends | Region details | Extra owned files (lead) |
|---|---|---|---|
| R1 Brackwater Ford, Sonnet lead, Haiku batches | F6 | 2 rooms | `tests/test_area_brackwater.gd` |

#### 7.1.1 Room batches

| Batch | Rooms | Pockets | Room ids |
|---|---|---|---|
| R1.a | 2 rooms | 0 | `ow_0_0`, `ow_0_1` |
| R1.b | 2 rooms | 1 | `ow_2_0 (in-place #cache)`, `ow_1_2 +#shop` |

## 8. Wave 3: caves

#### 8.1.1 Cave room batches

| Batch | Rooms | Pockets | Room ids |
|---|---|---|---|
| C01.a | 1 rooms | 0 | `cave_1 (in-place #alcove)` |

### 8.2 E1. The ending (Sonnet)

## 11. Art

| G9 | not a work package | 0 | `x` |
"""


def entry(wave, owns=(), amends=()):
    e = {"wave": wave, "owns": list(owns)}
    if amends:
        e["amends"] = list(amends)
    return e


def manifest(wps):
    return {"format": 1, "wps": wps}


class StrayFileTest(unittest.TestCase):
    def setUp(self):
        self.m = manifest({
            "P01": entry(1, ["scripts/world/burnable.gd", "tests/test_burnable.gd"],
                         amends=["scripts/items/tether_moth.gd"]),
            "P02": entry(1, ["scripts/world/eye_switch.gd", "scenes/world/eye_*.tscn"]),
        })

    def test_clean_wp_has_no_stray_files(self):
        files = ["scripts/world/burnable.gd", "scripts/world/burnable.gd.uid", "tests/test_burnable.gd"]
        self.assertEqual(co.stray_files(self.m, "P01", files), [])

    def test_amended_file_is_allowed(self):
        self.assertEqual(co.stray_files(self.m, "P01", ["scripts/items/tether_moth.gd"]), [])

    def test_stray_file_is_reported(self):
        files = ["scripts/world/burnable.gd", "scripts/world/eye_switch.gd"]
        self.assertEqual(co.stray_files(self.m, "P01", files), ["scripts/world/eye_switch.gd"])

    def test_uid_of_a_stray_script_is_reported(self):
        self.assertEqual(co.stray_files(self.m, "P01", ["scripts/world/eye_switch.gd.uid"]),
                         ["scripts/world/eye_switch.gd.uid"])

    def test_glob_owns_match_and_paths_are_normalised(self):
        files = ["./scenes/world/eye_cell.tscn", "scenes/world/eye_cell.tscn.bak"]
        self.assertEqual(co.stray_files(self.m, "P02", files), ["scenes/world/eye_cell.tscn.bak"])

    def test_unknown_wp_is_a_key_error_for_the_caller(self):
        with self.assertRaises(KeyError):
            co.stray_files(self.m, "P99", [])


class SharedOwnerTest(unittest.TestCase):
    def test_duplicate_owner_in_waves_1_to_5_is_reported(self):
        wps = {"P01": entry(1, ["scripts/x.gd"]), "C01": entry(3, ["scripts/x.gd"])}
        errors = co.shared_owners(wps)
        self.assertEqual(len(errors), 1)
        self.assertIn("scripts/x.gd", errors[0])

    def test_amends_do_not_count_as_an_owner(self):
        wps = {"Q9": entry(4, ["docs/state.md"]), "Z3": entry(5, ["export_presets.cfg"], amends=["docs/state.md"])}
        self.assertEqual(co.shared_owners(wps), [])

    def test_wave_zero_is_not_checked(self):
        wps = {"F4": entry(0, ["scripts/x.gd"]), "F5": entry(0, ["scripts/x.gd"])}
        self.assertEqual(co.shared_owners(wps), [])

    def test_literal_path_inside_another_wps_glob_is_reported(self):
        wps = {"Q4": entry(4, ["docs/screens/step3/contact-*.png"]),
               "Q5": entry(4, ["docs/screens/step3/contact-hush.png"])}
        self.assertEqual(len(co.shared_owners(wps)), 1)

    def test_paths_must_be_relative(self):
        wps = {"X1": entry(1, ["/abs/path.gd", "../up.gd", "ok/path.gd"])}
        self.assertEqual(len(co.path_errors(wps)), 2)


class DocumentTest(unittest.TestCase):
    def test_wave_and_ids_are_read_from_headings_and_tables(self):
        waves, batches = co.parse_doc(DOC_SNIPPET)
        self.assertEqual(waves["G1"], 0)
        self.assertEqual(waves["P01"], 1)
        self.assertEqual(waves["R1"], 2)
        self.assertEqual(waves["E1"], 3)
        self.assertNotIn("G9", waves)
        self.assertEqual(set(batches), {"R1.a", "R1.b", "C01.a"})

    def test_batch_rows_expand_rooms_pockets_and_in_place(self):
        _, batches = co.parse_doc(DOC_SNIPPET)
        b = batches["R1.b"]
        self.assertEqual(b["rooms"], ["ow_2_0", "ow_1_2"])
        self.assertEqual(b["pockets"], ["ow_1_2#shop"])
        self.assertEqual(b["in_place"], ["ow_2_0#cache"])
        self.assertEqual(b["owns"], ["tools/rooms/ow_2_0.room", "scenes/world/rooms/ow_2_0.tscn",
                                     "tools/rooms/ow_1_2.room", "scenes/world/rooms/ow_1_2.tscn",
                                     "tools/rooms/ow_1_2__shop.room", "scenes/world/rooms/ow_1_2__shop.tscn"])
        self.assertEqual(batches["C01.a"]["wave"], 3)
        self.assertEqual(b["wave"], 2)

    def test_room_count_that_disagrees_with_the_table_is_an_error(self):
        bad = DOC_SNIPPET.replace("| R1.a | 2 rooms | 0 |", "| R1.a | 3 rooms | 0 |")
        with self.assertRaises(co.DocError):
            co.parse_doc(bad)

    def test_regen_keeps_hand_entries_and_rebuilds_batches(self):
        m = manifest({
            "R1": entry(2, ["tests/test_area_brackwater.gd"]),
            "R1.a": {"wave": 2, "kind": co.BATCH_KIND, "rooms": ["old"], "pockets": [], "in_place": [], "owns": []},
            "R2": entry(2, ["tests/test_area_thornwood.gd"]),
        })
        new = co.regen(m, DOC_SNIPPET)
        # C01.a has no parent entry in this manifest, so it is appended at the end.
        self.assertEqual(list(new["wps"]), ["R1", "R1.a", "R1.b", "R2", "C01.a"])
        self.assertEqual(new["wps"]["R1"], m["wps"]["R1"])
        self.assertEqual(new["wps"]["R1.a"]["rooms"], ["ow_0_0", "ow_0_1"])

    def test_real_document_has_92_work_packages_and_53_batches(self):
        waves, batches = co.parse_doc(co.DOC_PATH.read_text(encoding="utf-8"))
        self.assertEqual(len(waves), 92)
        self.assertEqual(len(batches), 53)
        self.assertEqual(sorted(set(waves.values())), [0, 1, 2, 3, 4, 5])


class GraphCoverageTest(unittest.TestCase):
    def setUp(self):
        self.graph = {"nodes": [
            {"id": "ow_0_0", "kind": "room"}, {"id": "ow_0_1", "kind": "room"},
            {"id": "ow_1_2#shop", "kind": "pocket"},
        ]}

    def batches(self, rooms, pockets=()):
        return {"R1.a": co.batch_entry("R1.a", list(rooms), list(pockets), [])}

    def test_every_room_and_pocket_in_exactly_one_batch(self):
        errors, n_rooms, n_pockets = co.check_graph(self.graph, self.batches(["ow_0_0", "ow_0_1"], ["ow_1_2#shop"]))
        self.assertEqual(errors, [])
        self.assertEqual((n_rooms, n_pockets), (2, 1))

    def test_missing_room_is_reported(self):
        errors, _, _ = co.check_graph(self.graph, self.batches(["ow_0_0"], ["ow_1_2#shop"]))
        self.assertEqual(errors, ["ow_0_1 is in the graph but in no room batch"])

    def test_room_in_two_batches_is_reported(self):
        batches = {"R1.a": co.batch_entry("R1.a", ["ow_0_0"], [], []),
                   "R1.b": co.batch_entry("R1.b", ["ow_0_0", "ow_0_1"], ["ow_1_2#shop"], [])}
        errors, _, _ = co.check_graph(self.graph, batches)
        self.assertTrue(any("ow_0_0 is in more than one batch" in e for e in errors))

    def test_room_id_that_is_not_in_the_graph_is_reported(self):
        errors, _, _ = co.check_graph(self.graph, self.batches(["ow_0_0", "ow_0_1", "ow_9_9"], ["ow_1_2#shop"]))
        self.assertEqual(errors, ["R1.a: ow_9_9 is not a room in the graph"])


class CommandLineTest(unittest.TestCase):
    def run_checker(self, args, stdin):
        return subprocess.run([sys.executable, str(TOOLS / "check_ownership.py")] + args,
                              input=stdin, capture_output=True, text=True)

    def test_clean_wp_exits_0(self):
        r = self.run_checker(["P01"], "scripts/world/burnable.gd\nscripts/world/burnable.gd.uid\n")
        self.assertEqual(r.returncode, 0, r.stdout)

    def test_stray_file_exits_1_and_names_it(self):
        r = self.run_checker(["P01"], "scripts/world/burnable.gd\nscripts/world/bush.gd\n")
        self.assertEqual(r.returncode, 1)
        self.assertIn("STRAY scripts/world/bush.gd", r.stdout)

    def test_unknown_wp_exits_2(self):
        self.assertEqual(self.run_checker(["P99"], "").returncode, 2)


if __name__ == "__main__":
    unittest.main()
