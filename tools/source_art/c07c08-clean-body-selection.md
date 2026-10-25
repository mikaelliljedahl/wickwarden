# C07/C08 clean subset integration — 2026-10-25

Existing reviewed painted sources only, legacy magenta pipeline. No generation, raw editing, manual pixel isolation, actor/physics/UI changes or global import/cut. Selected source hashes verified below; original origin records unchanged. Review references and records are retained honestly, including missing provenance log fields; no inferred model/job/log history. Partial clean body subset only, NOT all art complete.

Only Pale Squire and Abacus Brute walks down/side/up4@6; each idle facing is its first walk frame. Common scale groups retain reviewed action references as measurement-only recipes with EMPTY outputs (no action pixels published), preserving exact reviewed scale. Actions/merged bands/Gloam phase bodies/Coinwyrm/plates/heaps/shared reelable/shared strike are withheld. Lance only r0p0..1 fly2@6 + idle alias; impact excluded. Rightward source axis; dark trail remains low contrast. Cutter reports +1px horizontal containment adjustment for lance p0 (reviewed proof), no head plume/action slides involved.

Actual World captures OPENED /tmp/clean-a-pale-world.png (cave_7_4), /tmp/clean-a-abacus-world.png (cave_8_4); capture-only white ambient, SaveGame disabled, Dummy audio. All selected walk bodies and lance source/cut proofs OPENED. Art22, sprite_visual+pale_squire+abacus_brute+boss_gloam_knight four suites, global lint PASS.

All original manifest/runtime entries semantically identical and every preexisting PNG SHA256 byte-identical against task snapshot. Foreign staging/source origin/provenance untouched; explicit own-path commit only, no push.

## Runtime interfaces

- `pale_squire`: {"anchor": [128.0, 206.0], "animations": {"idle_down": {"file": "res://assets/sprites/pale_squire_idle_down.png", "fps": 6.0, "frames": 1, "loop": true}, "idle_side": {"file": "res://assets/sprites/pale_squire_idle_side.png", "fps": 6.0, "frames": 1, "loop": true}, "idle_up": {"file": "res://assets/sprites/pale_squire_idle_up.png", "fps": 6.0, "frames": 1, "loop": true}, "walk_down": {"file": "res://assets/sprites/pale_squire_walk_down.png", "fps": 6.0, "frames": 4, "loop": true}, "walk_side": {"file": "res://assets/sprites/pale_squire_walk_side.png", "fps": 6.0, "frames": 4, "loop": true}, "walk_up": {"file": "res://assets/sprites/pale_squire_walk_up.png", "fps": 6.0, "frames": 4, "loop": true}}, "cell": [256, 256], "foot": 236, "mirror_side": true, "radius": 30.0}
- `abacus_brute`: {"anchor": [160.0, 252.0], "animations": {"idle_down": {"file": "res://assets/sprites/abacus_brute_idle_down.png", "fps": 6.0, "frames": 1, "loop": true}, "idle_side": {"file": "res://assets/sprites/abacus_brute_idle_side.png", "fps": 6.0, "frames": 1, "loop": true}, "idle_up": {"file": "res://assets/sprites/abacus_brute_idle_up.png", "fps": 6.0, "frames": 1, "loop": true}, "walk_down": {"file": "res://assets/sprites/abacus_brute_walk_down.png", "fps": 6.0, "frames": 4, "loop": true}, "walk_side": {"file": "res://assets/sprites/abacus_brute_walk_side.png", "fps": 6.0, "frames": 4, "loop": true}, "walk_up": {"file": "res://assets/sprites/abacus_brute_walk_up.png", "fps": 6.0, "frames": 4, "loop": true}}, "cell": [320, 320], "foot": 292, "mirror_side": true, "radius": 40.0}
- `gloam_lance`: {"anchor": [48.0, 48.0], "animations": {"fly": {"file": "res://assets/sprites/gloam_lance_fly.png", "fps": 6.0, "frames": 2, "loop": true}, "idle": {"file": "res://assets/sprites/gloam_lance_fly.png", "fps": 6.0, "frames": 2, "loop": true}}, "cell": [96, 96], "centered": true, "mirror_side": true}

## Exact selected frame review and origins

```json
[
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/pale_squire_walk_down_v2.png",
    "row": 0,
    "pose": 0,
    "bbox": [
      26,
      97,
      353,
      831
    ],
    "source_footpoint": [
      208.63840979079635,
      830
    ],
    "factor": 0.2997275204359673,
    "kind": "pale_squire",
    "state": "walk_down",
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206.0
    ],
    "foot": 236,
    "input_mode": "key",
    "batch": "B59",
    "sha256": "d7a60f41942d8ed11b603cf8a7457c62ed9bb4cce5b42cb6d47bb6509491ef0b",
    "provenance_log": "tools/source_art/log_b59.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/pale_squire_walk_down_v2.png",
    "row": 0,
    "pose": 1,
    "bbox": [
      395,
      96,
      705,
      825
    ],
    "source_footpoint": [
      566.551241069837,
      824
    ],
    "factor": 0.2997275204359673,
    "kind": "pale_squire",
    "state": "walk_down",
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206.0
    ],
    "foot": 236,
    "input_mode": "key",
    "batch": "B59",
    "sha256": "d7a60f41942d8ed11b603cf8a7457c62ed9bb4cce5b42cb6d47bb6509491ef0b",
    "provenance_log": "tools/source_art/log_b59.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/pale_squire_walk_down_v2.png",
    "row": 0,
    "pose": 2,
    "bbox": [
      760,
      96,
      1090,
      829
    ],
    "source_footpoint": [
      941.0866754636245,
      828
    ],
    "factor": 0.2997275204359673,
    "kind": "pale_squire",
    "state": "walk_down",
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206.0
    ],
    "foot": 236,
    "input_mode": "key",
    "batch": "B59",
    "sha256": "d7a60f41942d8ed11b603cf8a7457c62ed9bb4cce5b42cb6d47bb6509491ef0b",
    "provenance_log": "tools/source_art/log_b59.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/pale_squire_walk_down_v2.png",
    "row": 0,
    "pose": 3,
    "bbox": [
      1154,
      96,
      1477,
      829
    ],
    "source_footpoint": [
      1334.7707412533214,
      828
    ],
    "factor": 0.2997275204359673,
    "kind": "pale_squire",
    "state": "walk_down",
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206.0
    ],
    "foot": 236,
    "input_mode": "key",
    "batch": "B59",
    "sha256": "d7a60f41942d8ed11b603cf8a7457c62ed9bb4cce5b42cb6d47bb6509491ef0b",
    "provenance_log": "tools/source_art/log_b59.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/pale_squire_walk_side_v1.png",
    "row": 0,
    "pose": 0,
    "bbox": [
      43,
      133,
      406,
      791
    ],
    "source_footpoint": [
      208.88849747085126,
      790
    ],
    "factor": 0.2997275204359673,
    "kind": "pale_squire",
    "state": "walk_side",
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206.0
    ],
    "foot": 236,
    "input_mode": "key",
    "batch": "B59",
    "sha256": "0152c147ab1b2534ef71f83d4b0fcd24581817dacb2c25a17b7c43054fe7eb27",
    "provenance_log": "tools/source_art/log_b59.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/pale_squire_walk_side_v1.png",
    "row": 0,
    "pose": 1,
    "bbox": [
      437,
      133,
      699,
      792
    ],
    "source_footpoint": [
      559.5579256115157,
      790
    ],
    "factor": 0.2997275204359673,
    "kind": "pale_squire",
    "state": "walk_side",
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206.0
    ],
    "foot": 236,
    "input_mode": "key",
    "batch": "B59",
    "sha256": "0152c147ab1b2534ef71f83d4b0fcd24581817dacb2c25a17b7c43054fe7eb27",
    "provenance_log": "tools/source_art/log_b59.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/pale_squire_walk_side_v1.png",
    "row": 0,
    "pose": 2,
    "bbox": [
      754,
      133,
      1144,
      791
    ],
    "source_footpoint": [
      931.2226008845317,
      790
    ],
    "factor": 0.2997275204359673,
    "kind": "pale_squire",
    "state": "walk_side",
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206.0
    ],
    "foot": 236,
    "input_mode": "key",
    "batch": "B59",
    "sha256": "0152c147ab1b2534ef71f83d4b0fcd24581817dacb2c25a17b7c43054fe7eb27",
    "provenance_log": "tools/source_art/log_b59.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/pale_squire_walk_side_v1.png",
    "row": 0,
    "pose": 3,
    "bbox": [
      1196,
      133,
      1471,
      792
    ],
    "source_footpoint": [
      1325.0223566543345,
      790
    ],
    "factor": 0.2997275204359673,
    "kind": "pale_squire",
    "state": "walk_side",
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206.0
    ],
    "foot": 236,
    "input_mode": "key",
    "batch": "B59",
    "sha256": "0152c147ab1b2534ef71f83d4b0fcd24581817dacb2c25a17b7c43054fe7eb27",
    "provenance_log": "tools/source_art/log_b59.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/pale_squire_walk_up_v1.png",
    "row": 0,
    "pose": 0,
    "bbox": [
      74,
      129,
      379,
      802
    ],
    "source_footpoint": [
      212.85123679622544,
      801
    ],
    "factor": 0.2997275204359673,
    "kind": "pale_squire",
    "state": "walk_up",
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206.0
    ],
    "foot": 236,
    "input_mode": "key",
    "batch": "B59",
    "sha256": "0197cdffa7f6b6378c5ecbd712646f346578aa918672d049b44786f8442cb386",
    "provenance_log": "tools/source_art/log_b59.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/pale_squire_walk_up_v1.png",
    "row": 0,
    "pose": 1,
    "bbox": [
      462,
      130,
      742,
      797
    ],
    "source_footpoint": [
      597.1973325578678,
      796
    ],
    "factor": 0.2997275204359673,
    "kind": "pale_squire",
    "state": "walk_up",
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206.0
    ],
    "foot": 236,
    "input_mode": "key",
    "batch": "B59",
    "sha256": "0197cdffa7f6b6378c5ecbd712646f346578aa918672d049b44786f8442cb386",
    "provenance_log": "tools/source_art/log_b59.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/pale_squire_walk_up_v1.png",
    "row": 0,
    "pose": 2,
    "bbox": [
      808,
      130,
      1112,
      802
    ],
    "source_footpoint": [
      950.6459293970136,
      801
    ],
    "factor": 0.2997275204359673,
    "kind": "pale_squire",
    "state": "walk_up",
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206.0
    ],
    "foot": 236,
    "input_mode": "key",
    "batch": "B59",
    "sha256": "0197cdffa7f6b6378c5ecbd712646f346578aa918672d049b44786f8442cb386",
    "provenance_log": "tools/source_art/log_b59.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/pale_squire_walk_up_v1.png",
    "row": 0,
    "pose": 3,
    "bbox": [
      1200,
      130,
      1493,
      779
    ],
    "source_footpoint": [
      1339.5241066498616,
      778
    ],
    "factor": 0.2997275204359673,
    "kind": "pale_squire",
    "state": "walk_up",
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206.0
    ],
    "foot": 236,
    "input_mode": "key",
    "batch": "B59",
    "sha256": "0197cdffa7f6b6378c5ecbd712646f346578aa918672d049b44786f8442cb386",
    "provenance_log": "tools/source_art/log_b59.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/abacus_brute_walk_down_v2.png",
    "row": 0,
    "pose": 0,
    "bbox": [
      28,
      191,
      384,
      793
    ],
    "source_footpoint": [
      209.4384795140699,
      792
    ],
    "factor": 0.4584717607973422,
    "kind": "abacus_brute",
    "state": "walk_down",
    "cell": [
      320,
      320
    ],
    "anchor": [
      160.0,
      252.0
    ],
    "foot": 292,
    "input_mode": "key",
    "batch": "B60",
    "sha256": "f83620c1d4e3c7df9165c0cd64756e5add97c7f66e14213b010d1b5a90dbc10e",
    "provenance_log": "tools/source_art/log_b60.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/abacus_brute_walk_down_v2.png",
    "row": 0,
    "pose": 1,
    "bbox": [
      417,
      194,
      756,
      789
    ],
    "source_footpoint": [
      590.1290156962326,
      788
    ],
    "factor": 0.4584717607973422,
    "kind": "abacus_brute",
    "state": "walk_down",
    "cell": [
      320,
      320
    ],
    "anchor": [
      160.0,
      252.0
    ],
    "foot": 292,
    "input_mode": "key",
    "batch": "B60",
    "sha256": "f83620c1d4e3c7df9165c0cd64756e5add97c7f66e14213b010d1b5a90dbc10e",
    "provenance_log": "tools/source_art/log_b60.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/abacus_brute_walk_down_v2.png",
    "row": 0,
    "pose": 2,
    "bbox": [
      781,
      191,
      1125,
      793
    ],
    "source_footpoint": [
      957.1755382080833,
      792
    ],
    "factor": 0.4584717607973422,
    "kind": "abacus_brute",
    "state": "walk_down",
    "cell": [
      320,
      320
    ],
    "anchor": [
      160.0,
      252.0
    ],
    "foot": 292,
    "input_mode": "key",
    "batch": "B60",
    "sha256": "f83620c1d4e3c7df9165c0cd64756e5add97c7f66e14213b010d1b5a90dbc10e",
    "provenance_log": "tools/source_art/log_b60.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/abacus_brute_walk_down_v2.png",
    "row": 0,
    "pose": 3,
    "bbox": [
      1162,
      192,
      1506,
      784
    ],
    "source_footpoint": [
      1338.4815883840338,
      783
    ],
    "factor": 0.4584717607973422,
    "kind": "abacus_brute",
    "state": "walk_down",
    "cell": [
      320,
      320
    ],
    "anchor": [
      160.0,
      252.0
    ],
    "foot": 292,
    "input_mode": "key",
    "batch": "B60",
    "sha256": "f83620c1d4e3c7df9165c0cd64756e5add97c7f66e14213b010d1b5a90dbc10e",
    "provenance_log": "tools/source_art/log_b60.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/abacus_brute_walk_side_v1.png",
    "row": 0,
    "pose": 0,
    "bbox": [
      29,
      239,
      384,
      768
    ],
    "source_footpoint": [
      207.49616214532915,
      767
    ],
    "factor": 0.4584717607973422,
    "kind": "abacus_brute",
    "state": "walk_side",
    "cell": [
      320,
      320
    ],
    "anchor": [
      160.0,
      252.0
    ],
    "foot": 292,
    "input_mode": "key",
    "batch": "B60",
    "sha256": "ad4465a9f473d1b5e4cd2e5185e27837053037158ff16fcf64da437b29b5cee2",
    "provenance_log": "tools/source_art/log_b60.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/abacus_brute_walk_side_v1.png",
    "row": 0,
    "pose": 1,
    "bbox": [
      441,
      239,
      713,
      771
    ],
    "source_footpoint": [
      573.5709017238762,
      770
    ],
    "factor": 0.4584717607973422,
    "kind": "abacus_brute",
    "state": "walk_side",
    "cell": [
      320,
      320
    ],
    "anchor": [
      160.0,
      252.0
    ],
    "foot": 292,
    "input_mode": "key",
    "batch": "B60",
    "sha256": "ad4465a9f473d1b5e4cd2e5185e27837053037158ff16fcf64da437b29b5cee2",
    "provenance_log": "tools/source_art/log_b60.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/abacus_brute_walk_side_v1.png",
    "row": 0,
    "pose": 2,
    "bbox": [
      770,
      239,
      1133,
      768
    ],
    "source_footpoint": [
      949.1703634456774,
      767
    ],
    "factor": 0.4584717607973422,
    "kind": "abacus_brute",
    "state": "walk_side",
    "cell": [
      320,
      320
    ],
    "anchor": [
      160.0,
      252.0
    ],
    "foot": 292,
    "input_mode": "key",
    "batch": "B60",
    "sha256": "ad4465a9f473d1b5e4cd2e5185e27837053037158ff16fcf64da437b29b5cee2",
    "provenance_log": "tools/source_art/log_b60.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/abacus_brute_walk_side_v1.png",
    "row": 0,
    "pose": 3,
    "bbox": [
      1192,
      239,
      1472,
      771
    ],
    "source_footpoint": [
      1332.5152758833356,
      770
    ],
    "factor": 0.4584717607973422,
    "kind": "abacus_brute",
    "state": "walk_side",
    "cell": [
      320,
      320
    ],
    "anchor": [
      160.0,
      252.0
    ],
    "foot": 292,
    "input_mode": "key",
    "batch": "B60",
    "sha256": "ad4465a9f473d1b5e4cd2e5185e27837053037158ff16fcf64da437b29b5cee2",
    "provenance_log": "tools/source_art/log_b60.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/abacus_brute_walk_up_v1.png",
    "row": 0,
    "pose": 0,
    "bbox": [
      58,
      238,
      353,
      773
    ],
    "source_footpoint": [
      204.14952434886354,
      771
    ],
    "factor": 0.4584717607973422,
    "kind": "abacus_brute",
    "state": "walk_up",
    "cell": [
      320,
      320
    ],
    "anchor": [
      160.0,
      252.0
    ],
    "foot": 292,
    "input_mode": "key",
    "batch": "B60",
    "sha256": "00fbdd84b33ef082baee2ca7a83ce29fd3207932f984bdcca6ec05efc7e09e12",
    "provenance_log": "tools/source_art/log_b60.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/abacus_brute_walk_up_v1.png",
    "row": 0,
    "pose": 1,
    "bbox": [
      440,
      237,
      730,
      771
    ],
    "source_footpoint": [
      587.3628628993991,
      770
    ],
    "factor": 0.4584717607973422,
    "kind": "abacus_brute",
    "state": "walk_up",
    "cell": [
      320,
      320
    ],
    "anchor": [
      160.0,
      252.0
    ],
    "foot": 292,
    "input_mode": "key",
    "batch": "B60",
    "sha256": "00fbdd84b33ef082baee2ca7a83ce29fd3207932f984bdcca6ec05efc7e09e12",
    "provenance_log": "tools/source_art/log_b60.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/abacus_brute_walk_up_v1.png",
    "row": 0,
    "pose": 2,
    "bbox": [
      804,
      237,
      1098,
      774
    ],
    "source_footpoint": [
      946.2872817840414,
      773
    ],
    "factor": 0.4584717607973422,
    "kind": "abacus_brute",
    "state": "walk_up",
    "cell": [
      320,
      320
    ],
    "anchor": [
      160.0,
      252.0
    ],
    "foot": 292,
    "input_mode": "key",
    "batch": "B60",
    "sha256": "00fbdd84b33ef082baee2ca7a83ce29fd3207932f984bdcca6ec05efc7e09e12",
    "provenance_log": "tools/source_art/log_b60.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/abacus_brute_walk_up_v1.png",
    "row": 0,
    "pose": 3,
    "bbox": [
      1193,
      237,
      1482,
      771
    ],
    "source_footpoint": [
      1337.2178887256337,
      770
    ],
    "factor": 0.4584717607973422,
    "kind": "abacus_brute",
    "state": "walk_up",
    "cell": [
      320,
      320
    ],
    "anchor": [
      160.0,
      252.0
    ],
    "foot": 292,
    "input_mode": "key",
    "batch": "B60",
    "sha256": "00fbdd84b33ef082baee2ca7a83ce29fd3207932f984bdcca6ec05efc7e09e12",
    "provenance_log": "tools/source_art/log_b60.md",
    "existing_provenance_entry": "",
    "verdict": "accept-body-cycle-with-repeated-strides"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/proj_lance_v1.png",
    "row": 0,
    "pose": 0,
    "bbox": [
      41,
      461,
      326,
      534
    ],
    "source_footpoint": null,
    "factor": 0.2807017543859649,
    "kind": "gloam_lance",
    "state": "combined",
    "cell": [
      96,
      96
    ],
    "anchor": [
      48.0,
      48.0
    ],
    "foot": null,
    "input_mode": "key",
    "batch": "B49",
    "sha256": "b0b6e1d1d397884fe9c1db3fb02a72fbf46a172a52fbbe4bbe8fc440d2c5a6c7",
    "provenance_log": "tools/source_art/log_b49.md",
    "existing_provenance_entry": "",
    "verdict": "accept-flight-poses-0-1-only-impact-separate"
  },
  {
    "source": "/home/mikael/code/github/wickwarden/tools/source_art/proj_lance_v1.png",
    "row": 0,
    "pose": 1,
    "bbox": [
      382,
      436,
      649,
      545
    ],
    "source_footpoint": null,
    "factor": 0.2807017543859649,
    "kind": "gloam_lance",
    "state": "combined",
    "cell": [
      96,
      96
    ],
    "anchor": [
      48.0,
      48.0
    ],
    "foot": null,
    "input_mode": "key",
    "batch": "B49",
    "sha256": "b0b6e1d1d397884fe9c1db3fb02a72fbf46a172a52fbbe4bbe8fc440d2c5a6c7",
    "provenance_log": "tools/source_art/log_b49.md",
    "existing_provenance_entry": "",
    "verdict": "accept-flight-poses-0-1-only-impact-separate"
  }
]
```

## All referenced raw hashes (including measurement-only sources)

- `tools/source_art/pale_squire_walk_down_v2.png`: d7a60f41942d8ed11b603cf8a7457c62ed9bb4cce5b42cb6d47bb6509491ef0b
- `tools/source_art/pale_squire_walk_side_v1.png`: 0152c147ab1b2534ef71f83d4b0fcd24581817dacb2c25a17b7c43054fe7eb27
- `tools/source_art/pale_squire_walk_up_v1.png`: 0197cdffa7f6b6378c5ecbd712646f346578aa918672d049b44786f8442cb386
- `tools/source_art/abacus_brute_walk_down_v2.png`: f83620c1d4e3c7df9165c0cd64756e5add97c7f66e14213b010d1b5a90dbc10e
- `tools/source_art/abacus_brute_walk_side_v1.png`: ad4465a9f473d1b5e4cd2e5185e27837053037158ff16fcf64da437b29b5cee2
- `tools/source_art/abacus_brute_walk_up_v1.png`: 00fbdd84b33ef082baee2ca7a83ce29fd3207932f984bdcca6ec05efc7e09e12
- `tools/source_art/proj_lance_v1.png`: b0b6e1d1d397884fe9c1db3fb02a72fbf46a172a52fbbe4bbe8fc440d2c5a6c7
- `tools/source_art/pale_squire_actions_down_v2.png`: c5b8cf7de50da2a53bb1d92b3a95b88128a436ab33e9c23af5b8f8254c038955
- `tools/source_art/pale_squire_actions_side_v2.png`: 4bcef3c6596d3165d566bcda0f864f2f5f5dcb9c4909a72ce85ee6c6aaaf1d38
- `tools/source_art/abacus_brute_actions_down_v1.png`: 7b72aac43609560d3dba726990b4c8da809dbe0f7d302aab88ee58e89ad4083e
- `tools/source_art/abacus_brute_actions_side_v1.png`: 154f15ec17b51d94fabaa20bc2294684956e88e93ab0d4aabd50fb099aec65f8
