# C09/C10 clean subset integration — 2026-10-25

Existing reviewed painted sources only, legacy magenta pipeline. No generation, raw editing, manual pixel isolation, actor/physics/UI changes or global import/cut. Selected source hashes verified below; original origin records unchanged. Review references and records are retained honestly, including missing provenance log fields; no inferred model/job/log history. Partial clean body subset only, NOT all art complete.

Only primary37 accepted source frames: Automaton12walk, Echo12walk, hand4rise/2hold/3sink, compact mass2idle, hook2fly. Walk facings idle aliases select first pose. Hand idle aliases hold; rise/sink nonloop, holdloop. No lifetime added. Current separately owned HandPresentation observes rise age<1, hold age1..2.5, sink age>=2.5, with unchanged retirement at3s; the earlier reviewer handoff predates this adapter. No keyhole, eye, lantern, lock body/plate, shell/heart or chain mapping. Corrow side uses existing params.split=components, no merged neighbours.

All original manifest/runtime entries semantically identical and every preexisting PNG SHA256 byte-identical against task snapshot. Foreign staging/source origin/provenance untouched; explicit own-path commit only, no push.

## Runtime interfaces

- `wick_automaton`: {"anchor": [128.0, 204.0], "animations": {"idle_down": {"file": "res://assets/sprites/wick_automaton_idle_down.png", "fps": 6.0, "frames": 1, "loop": true}, "idle_side": {"file": "res://assets/sprites/wick_automaton_idle_side.png", "fps": 6.0, "frames": 1, "loop": true}, "idle_up": {"file": "res://assets/sprites/wick_automaton_idle_up.png", "fps": 6.0, "frames": 1, "loop": true}, "walk_down": {"file": "res://assets/sprites/wick_automaton_walk_down.png", "fps": 6.0, "frames": 4, "loop": true}, "walk_side": {"file": "res://assets/sprites/wick_automaton_walk_side.png", "fps": 6.0, "frames": 4, "loop": true}, "walk_up": {"file": "res://assets/sprites/wick_automaton_walk_up.png", "fps": 6.0, "frames": 4, "loop": true}}, "cell": [256, 256], "foot": 236, "mirror_side": true, "radius": 32.0}
- `corrows_echo`: {"anchor": [128.0, 206.0], "animations": {"idle_down": {"file": "res://assets/sprites/corrows_echo_idle_down.png", "fps": 6.0, "frames": 1, "loop": true}, "idle_side": {"file": "res://assets/sprites/corrows_echo_idle_side.png", "fps": 6.0, "frames": 1, "loop": true}, "idle_up": {"file": "res://assets/sprites/corrows_echo_idle_up.png", "fps": 6.0, "frames": 1, "loop": true}, "walk_down": {"file": "res://assets/sprites/corrows_echo_walk_down.png", "fps": 6.0, "frames": 4, "loop": true}, "walk_side": {"file": "res://assets/sprites/corrows_echo_walk_side.png", "fps": 6.0, "frames": 4, "loop": true}, "walk_up": {"file": "res://assets/sprites/corrows_echo_walk_up.png", "fps": 6.0, "frames": 4, "loop": true}}, "cell": [256, 256], "foot": 236, "mirror_side": true, "radius": 30.0}
- `unlit_hush_hand`: {"anchor": [96.0, 76.0], "animations": {"hold": {"file": "res://assets/sprites/unlit_hush_hand_hold.png", "fps": 6.0, "frames": 2, "loop": true}, "idle": {"file": "res://assets/sprites/unlit_hush_hand_hold.png", "fps": 6.0, "frames": 2, "loop": true}, "rise": {"file": "res://assets/sprites/unlit_hush_hand_rise.png", "fps": 6.0, "frames": 4, "loop": false}, "sink": {"file": "res://assets/sprites/unlit_hush_hand_sink.png", "fps": 6.0, "frames": 3, "loop": false}}, "cell": [192, 192], "foot": 176, "mirror_side": true, "radius": 100.0}
- `unlit_p1_mass`: {"anchor": [384.0, 384.0], "animations": {"idle": {"file": "res://assets/sprites/unlit_p1_mass_idle.png", "fps": 6.0, "frames": 2, "loop": true}}, "cell": [768, 768], "centered": true, "mirror_side": true, "radius": 120.0}
- `wax_hook`: {"anchor": [48.0, 48.0], "animations": {"fly": {"file": "res://assets/sprites/wax_hook_fly.png", "fps": 6.0, "frames": 2, "loop": true}, "idle": {"file": "res://assets/sprites/wax_hook_fly.png", "fps": 6.0, "frames": 2, "loop": true}}, "cell": [96, 96], "centered": true, "mirror_side": true, "radius": 16.0}

## Exact selected frame review and origins

```json
[
  {
    "source": "tools/source_art/wick_automaton_walk_down_v1.png",
    "batch": "B61",
    "existing_job_id": "b61_wick_automaton_walk_down_v1",
    "sha256": "df6bf39180f449cbe545f58ab0367e0d8f725fc4d4443477bb1dafa9f04aeec0",
    "kind": "wick_automaton",
    "state": "walk_down",
    "source_row": 0,
    "source_pose": 0,
    "source_bbox": [
      64,
      205,
      343,
      796
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      204
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      114.5,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      92,
      56,
      177,
      237
    ],
    "uniform_scale": 0.30456852791878175,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/wick_automaton_walk_down.png.png",
    "provenance_prompt": "tools/art_prompts/batch_61.md",
    "provenance_log": "tools/source_art/log_b61.md"
  },
  {
    "source": "tools/source_art/wick_automaton_walk_down_v1.png",
    "batch": "B61",
    "existing_job_id": "b61_wick_automaton_walk_down_v1",
    "sha256": "df6bf39180f449cbe545f58ab0367e0d8f725fc4d4443477bb1dafa9f04aeec0",
    "kind": "wick_automaton",
    "state": "walk_down",
    "source_row": 0,
    "source_pose": 1,
    "source_bbox": [
      442,
      205,
      722,
      792
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      204
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      114.5,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      91,
      57,
      176,
      237
    ],
    "uniform_scale": 0.30456852791878175,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/wick_automaton_walk_down.png.png",
    "provenance_prompt": "tools/art_prompts/batch_61.md",
    "provenance_log": "tools/source_art/log_b61.md"
  },
  {
    "source": "tools/source_art/wick_automaton_walk_down_v1.png",
    "batch": "B61",
    "existing_job_id": "b61_wick_automaton_walk_down_v1",
    "sha256": "df6bf39180f449cbe545f58ab0367e0d8f725fc4d4443477bb1dafa9f04aeec0",
    "kind": "wick_automaton",
    "state": "walk_down",
    "source_row": 0,
    "source_pose": 2,
    "source_bbox": [
      824,
      205,
      1104,
      796
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      204
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      118.5,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      93,
      56,
      178,
      237
    ],
    "uniform_scale": 0.30456852791878175,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/wick_automaton_walk_down.png.png",
    "provenance_prompt": "tools/art_prompts/batch_61.md",
    "provenance_log": "tools/source_art/log_b61.md"
  },
  {
    "source": "tools/source_art/wick_automaton_walk_down_v1.png",
    "batch": "B61",
    "existing_job_id": "b61_wick_automaton_walk_down_v1",
    "sha256": "df6bf39180f449cbe545f58ab0367e0d8f725fc4d4443477bb1dafa9f04aeec0",
    "kind": "wick_automaton",
    "state": "walk_down",
    "source_row": 0,
    "source_pose": 3,
    "source_bbox": [
      1208,
      204,
      1487,
      792
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      204
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      114.5,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      91,
      58,
      176,
      237
    ],
    "uniform_scale": 0.30456852791878175,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/wick_automaton_walk_down.png.png",
    "provenance_prompt": "tools/art_prompts/batch_61.md",
    "provenance_log": "tools/source_art/log_b61.md"
  },
  {
    "source": "tools/source_art/wick_automaton_walk_side_v1.png",
    "batch": "B61",
    "existing_job_id": "b61_wick_automaton_walk_side_v1",
    "sha256": "c0eeebb42c3b0f95ba0678cab872c01404737b0f0023870e5eb31d27e4c72835",
    "kind": "wick_automaton",
    "state": "walk_side",
    "source_row": 0,
    "source_pose": 0,
    "source_bbox": [
      29,
      222,
      375,
      780
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      204
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      157.0,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      79,
      66,
      186,
      237
    ],
    "uniform_scale": 0.30456852791878175,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/wick_automaton_walk_side.png.png",
    "provenance_prompt": "tools/art_prompts/batch_61.md",
    "provenance_log": "tools/source_art/log_b61.md"
  },
  {
    "source": "tools/source_art/wick_automaton_walk_side_v1.png",
    "batch": "B61",
    "existing_job_id": "b61_wick_automaton_walk_side_v1",
    "sha256": "c0eeebb42c3b0f95ba0678cab872c01404737b0f0023870e5eb31d27e4c72835",
    "kind": "wick_automaton",
    "state": "walk_side",
    "source_row": 0,
    "source_pose": 1,
    "source_bbox": [
      450,
      222,
      736,
      780
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      204
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      122.0,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      89,
      66,
      176,
      237
    ],
    "uniform_scale": 0.30456852791878175,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/wick_automaton_walk_side.png.png",
    "provenance_prompt": "tools/art_prompts/batch_61.md",
    "provenance_log": "tools/source_art/log_b61.md"
  },
  {
    "source": "tools/source_art/wick_automaton_walk_side_v1.png",
    "batch": "B61",
    "existing_job_id": "b61_wick_automaton_walk_side_v1",
    "sha256": "c0eeebb42c3b0f95ba0678cab872c01404737b0f0023870e5eb31d27e4c72835",
    "kind": "wick_automaton",
    "state": "walk_side",
    "source_row": 0,
    "source_pose": 2,
    "source_bbox": [
      789,
      222,
      1136,
      781
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      204
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      156.0,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      78,
      66,
      185,
      237
    ],
    "uniform_scale": 0.30456852791878175,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/wick_automaton_walk_side.png.png",
    "provenance_prompt": "tools/art_prompts/batch_61.md",
    "provenance_log": "tools/source_art/log_b61.md"
  },
  {
    "source": "tools/source_art/wick_automaton_walk_side_v1.png",
    "batch": "B61",
    "existing_job_id": "b61_wick_automaton_walk_side_v1",
    "sha256": "c0eeebb42c3b0f95ba0678cab872c01404737b0f0023870e5eb31d27e4c72835",
    "kind": "wick_automaton",
    "state": "walk_side",
    "source_row": 0,
    "source_pose": 3,
    "source_bbox": [
      1222,
      222,
      1509,
      780
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      204
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      122.0,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      90,
      66,
      178,
      237
    ],
    "uniform_scale": 0.30456852791878175,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/wick_automaton_walk_side.png.png",
    "provenance_prompt": "tools/art_prompts/batch_61.md",
    "provenance_log": "tools/source_art/log_b61.md"
  },
  {
    "source": "tools/source_art/wick_automaton_walk_up_v1.png",
    "batch": "B61",
    "existing_job_id": "b61_wick_automaton_walk_up_v1",
    "sha256": "86d47c582f975e5c66a00025a46245a87d1fb85d69bc23caba00e6c4369ae4b8",
    "kind": "wick_automaton",
    "state": "walk_up",
    "source_row": 0,
    "source_pose": 0,
    "source_bbox": [
      30,
      202,
      352,
      781
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      204
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      150.5,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      76,
      59,
      175,
      237
    ],
    "uniform_scale": 0.30456852791878175,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/wick_automaton_walk_up.png.png",
    "provenance_prompt": "tools/art_prompts/batch_61.md",
    "provenance_log": "tools/source_art/log_b61.md"
  },
  {
    "source": "tools/source_art/wick_automaton_walk_up_v1.png",
    "batch": "B61",
    "existing_job_id": "b61_wick_automaton_walk_up_v1",
    "sha256": "86d47c582f975e5c66a00025a46245a87d1fb85d69bc23caba00e6c4369ae4b8",
    "kind": "wick_automaton",
    "state": "walk_up",
    "source_row": 0,
    "source_pose": 1,
    "source_bbox": [
      435,
      202,
      705,
      782
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      204
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      112.0,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      84,
      59,
      165,
      237
    ],
    "uniform_scale": 0.30456852791878175,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/wick_automaton_walk_up.png.png",
    "provenance_prompt": "tools/art_prompts/batch_61.md",
    "provenance_log": "tools/source_art/log_b61.md"
  },
  {
    "source": "tools/source_art/wick_automaton_walk_up_v1.png",
    "batch": "B61",
    "existing_job_id": "b61_wick_automaton_walk_up_v1",
    "sha256": "86d47c582f975e5c66a00025a46245a87d1fb85d69bc23caba00e6c4369ae4b8",
    "kind": "wick_automaton",
    "state": "walk_up",
    "source_row": 0,
    "source_pose": 2,
    "source_bbox": [
      792,
      202,
      1120,
      781
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      204
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      151.5,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      76,
      59,
      176,
      237
    ],
    "uniform_scale": 0.30456852791878175,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/wick_automaton_walk_up.png.png",
    "provenance_prompt": "tools/art_prompts/batch_61.md",
    "provenance_log": "tools/source_art/log_b61.md"
  },
  {
    "source": "tools/source_art/wick_automaton_walk_up_v1.png",
    "batch": "B61",
    "existing_job_id": "b61_wick_automaton_walk_up_v1",
    "sha256": "86d47c582f975e5c66a00025a46245a87d1fb85d69bc23caba00e6c4369ae4b8",
    "kind": "wick_automaton",
    "state": "walk_up",
    "source_row": 0,
    "source_pose": 3,
    "source_bbox": [
      1203,
      202,
      1473,
      782
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      204
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      141.0,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      83,
      59,
      165,
      237
    ],
    "uniform_scale": 0.30456852791878175,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/wick_automaton_walk_up.png.png",
    "provenance_prompt": "tools/art_prompts/batch_61.md",
    "provenance_log": "tools/source_art/log_b61.md"
  },
  {
    "source": "tools/source_art/corrows_echo_walk_down_v1.png",
    "batch": "B62",
    "existing_job_id": "b62_corrows_echo_walk_down_v1",
    "sha256": "c3901a109f9e84860becf08fd20c0b54f8a7c274d4d7f8a49ed4806da3d79131",
    "kind": "corrows_echo",
    "state": "walk_down",
    "source_row": 0,
    "source_pose": 0,
    "source_bbox": [
      43,
      179,
      365,
      829
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      131.0,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      89,
      56,
      178,
      237
    ],
    "uniform_scale": 0.27692307692307694,
    "proof_strip": "/tmp/c09c10-review-37ab/strips-r3/corrows_echo_walk_down.png.png",
    "provenance_prompt": "tools/art_prompts/batch_62.md",
    "provenance_log": "tools/source_art/log_b62.md"
  },
  {
    "source": "tools/source_art/corrows_echo_walk_down_v1.png",
    "batch": "B62",
    "existing_job_id": "b62_corrows_echo_walk_down_v1",
    "sha256": "c3901a109f9e84860becf08fd20c0b54f8a7c274d4d7f8a49ed4806da3d79131",
    "kind": "corrows_echo",
    "state": "walk_down",
    "source_row": 0,
    "source_pose": 1,
    "source_bbox": [
      422,
      179,
      746,
      821
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      133.5,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      88,
      58,
      178,
      237
    ],
    "uniform_scale": 0.27692307692307694,
    "proof_strip": "/tmp/c09c10-review-37ab/strips-r3/corrows_echo_walk_down.png.png",
    "provenance_prompt": "tools/art_prompts/batch_62.md",
    "provenance_log": "tools/source_art/log_b62.md"
  },
  {
    "source": "tools/source_art/corrows_echo_walk_down_v1.png",
    "batch": "B62",
    "existing_job_id": "b62_corrows_echo_walk_down_v1",
    "sha256": "c3901a109f9e84860becf08fd20c0b54f8a7c274d4d7f8a49ed4806da3d79131",
    "kind": "corrows_echo",
    "state": "walk_down",
    "source_row": 0,
    "source_pose": 2,
    "source_bbox": [
      803,
      179,
      1127,
      824
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      132.0,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      89,
      57,
      179,
      237
    ],
    "uniform_scale": 0.27692307692307694,
    "proof_strip": "/tmp/c09c10-review-37ab/strips-r3/corrows_echo_walk_down.png.png",
    "provenance_prompt": "tools/art_prompts/batch_62.md",
    "provenance_log": "tools/source_art/log_b62.md"
  },
  {
    "source": "tools/source_art/corrows_echo_walk_down_v1.png",
    "batch": "B62",
    "existing_job_id": "b62_corrows_echo_walk_down_v1",
    "sha256": "c3901a109f9e84860becf08fd20c0b54f8a7c274d4d7f8a49ed4806da3d79131",
    "kind": "corrows_echo",
    "state": "walk_down",
    "source_row": 0,
    "source_pose": 3,
    "source_bbox": [
      1183,
      179,
      1502,
      821
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      124.0,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      89,
      58,
      177,
      237
    ],
    "uniform_scale": 0.27692307692307694,
    "proof_strip": "/tmp/c09c10-review-37ab/strips-r3/corrows_echo_walk_down.png.png",
    "provenance_prompt": "tools/art_prompts/batch_62.md",
    "provenance_log": "tools/source_art/log_b62.md"
  },
  {
    "source": "tools/source_art/corrows_echo_walk_side_v1.png",
    "batch": "B62",
    "existing_job_id": "b62_corrows_echo_walk_side_v1",
    "sha256": "d0edfd062d5f4dbf9d5edad088647d5091ff7036452190f6c1735dcd775bb3c9",
    "kind": "corrows_echo",
    "state": "walk_side",
    "source_row": 0,
    "source_pose": 0,
    "source_bbox": [
      16,
      208,
      408,
      794
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      161.0,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      82,
      74,
      191,
      237
    ],
    "uniform_scale": 0.27692307692307694,
    "proof_strip": "/tmp/c09c10-review-37ab/strips-r3/corrows_echo_walk_side.png.png",
    "provenance_prompt": "tools/art_prompts/batch_62.md",
    "provenance_log": "tools/source_art/log_b62.md"
  },
  {
    "source": "tools/source_art/corrows_echo_walk_side_v1.png",
    "batch": "B62",
    "existing_job_id": "b62_corrows_echo_walk_side_v1",
    "sha256": "d0edfd062d5f4dbf9d5edad088647d5091ff7036452190f6c1735dcd775bb3c9",
    "kind": "corrows_echo",
    "state": "walk_side",
    "source_row": 0,
    "source_pose": 1,
    "source_bbox": [
      426,
      208,
      747,
      792
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      127.5,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      92,
      74,
      180,
      237
    ],
    "uniform_scale": 0.27692307692307694,
    "proof_strip": "/tmp/c09c10-review-37ab/strips-r3/corrows_echo_walk_side.png.png",
    "provenance_prompt": "tools/art_prompts/batch_62.md",
    "provenance_log": "tools/source_art/log_b62.md"
  },
  {
    "source": "tools/source_art/corrows_echo_walk_side_v1.png",
    "batch": "B62",
    "existing_job_id": "b62_corrows_echo_walk_side_v1",
    "sha256": "d0edfd062d5f4dbf9d5edad088647d5091ff7036452190f6c1735dcd775bb3c9",
    "kind": "corrows_echo",
    "state": "walk_side",
    "source_row": 0,
    "source_pose": 2,
    "source_bbox": [
      755,
      208,
      1132,
      794
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      161.5,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      82,
      74,
      187,
      237
    ],
    "uniform_scale": 0.27692307692307694,
    "proof_strip": "/tmp/c09c10-review-37ab/strips-r3/corrows_echo_walk_side.png.png",
    "provenance_prompt": "tools/art_prompts/batch_62.md",
    "provenance_log": "tools/source_art/log_b62.md"
  },
  {
    "source": "tools/source_art/corrows_echo_walk_side_v1.png",
    "batch": "B62",
    "existing_job_id": "b62_corrows_echo_walk_side_v1",
    "sha256": "d0edfd062d5f4dbf9d5edad088647d5091ff7036452190f6c1735dcd775bb3c9",
    "kind": "corrows_echo",
    "state": "walk_side",
    "source_row": 0,
    "source_pose": 3,
    "source_bbox": [
      1179,
      208,
      1512,
      792
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      126.0,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      91,
      74,
      183,
      237
    ],
    "uniform_scale": 0.27692307692307694,
    "proof_strip": "/tmp/c09c10-review-37ab/strips-r3/corrows_echo_walk_side.png.png",
    "provenance_prompt": "tools/art_prompts/batch_62.md",
    "provenance_log": "tools/source_art/log_b62.md"
  },
  {
    "source": "tools/source_art/corrows_echo_walk_up_v2.png",
    "batch": "B62",
    "existing_job_id": "b62_corrows_echo_walk_up_v2",
    "sha256": "99bc843a221d19c93c005a7fe48b3f7e0df19fcb1f27167e51de6fbc25d07913",
    "kind": "corrows_echo",
    "state": "walk_up",
    "source_row": 0,
    "source_pose": 0,
    "source_bbox": [
      42,
      197,
      385,
      806
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      151.5,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      73,
      67,
      169,
      237
    ],
    "uniform_scale": 0.27692307692307694,
    "proof_strip": "/tmp/c09c10-review-37ab/strips-r3/corrows_echo_walk_up.png.png",
    "provenance_prompt": "tools/art_prompts/batch_62.md",
    "provenance_log": "tools/source_art/log_b62.md"
  },
  {
    "source": "tools/source_art/corrows_echo_walk_up_v2.png",
    "batch": "B62",
    "existing_job_id": "b62_corrows_echo_walk_up_v2",
    "sha256": "99bc843a221d19c93c005a7fe48b3f7e0df19fcb1f27167e51de6fbc25d07913",
    "kind": "corrows_echo",
    "state": "walk_up",
    "source_row": 0,
    "source_pose": 1,
    "source_bbox": [
      428,
      196,
      746,
      801
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      116.0,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      77,
      68,
      165,
      237
    ],
    "uniform_scale": 0.27692307692307694,
    "proof_strip": "/tmp/c09c10-review-37ab/strips-r3/corrows_echo_walk_up.png.png",
    "provenance_prompt": "tools/art_prompts/batch_62.md",
    "provenance_log": "tools/source_art/log_b62.md"
  },
  {
    "source": "tools/source_art/corrows_echo_walk_up_v2.png",
    "batch": "B62",
    "existing_job_id": "b62_corrows_echo_walk_up_v2",
    "sha256": "99bc843a221d19c93c005a7fe48b3f7e0df19fcb1f27167e51de6fbc25d07913",
    "kind": "corrows_echo",
    "state": "walk_up",
    "source_row": 0,
    "source_pose": 2,
    "source_bbox": [
      797,
      198,
      1138,
      806
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      149.0,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      73,
      68,
      169,
      237
    ],
    "uniform_scale": 0.27692307692307694,
    "proof_strip": "/tmp/c09c10-review-37ab/strips-r3/corrows_echo_walk_up.png.png",
    "provenance_prompt": "tools/art_prompts/batch_62.md",
    "provenance_log": "tools/source_art/log_b62.md"
  },
  {
    "source": "tools/source_art/corrows_echo_walk_up_v2.png",
    "batch": "B62",
    "existing_job_id": "b62_corrows_echo_walk_up_v2",
    "sha256": "99bc843a221d19c93c005a7fe48b3f7e0df19fcb1f27167e51de6fbc25d07913",
    "kind": "corrows_echo",
    "state": "walk_up",
    "source_row": 0,
    "source_pose": 3,
    "source_bbox": [
      1182,
      196,
      1498,
      801
    ],
    "cell": [
      256,
      256
    ],
    "anchor": [
      128.0,
      206
    ],
    "alignment": "foot",
    "foot": 236,
    "actual_footpoint_at_measure_floor_0_1": [
      116.0,
      236
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      76,
      68,
      165,
      237
    ],
    "uniform_scale": 0.27692307692307694,
    "proof_strip": "/tmp/c09c10-review-37ab/strips-r3/corrows_echo_walk_up.png.png",
    "provenance_prompt": "tools/art_prompts/batch_62.md",
    "provenance_log": "tools/source_art/log_b62.md"
  },
  {
    "source": "tools/source_art/unlit_p1_mass_v1.png",
    "batch": "B69",
    "existing_job_id": "b69_unlit_p1_mass_v1",
    "sha256": "71f4a326fdc67df11cd71de4ebcc7f2b03b9dc1c131f4cc398ef3229aae0438b",
    "kind": "unlit_p1_mass",
    "state": "idle",
    "source_row": 0,
    "source_pose": 0,
    "source_bbox": [
      85,
      201,
      693,
      806
    ],
    "cell": [
      768,
      768
    ],
    "anchor": [
      384.0,
      384.0
    ],
    "alignment": "center",
    "foot": null,
    "actual_footpoint_at_measure_floor_0_1": null,
    "alpha_bounds_at_measure_floor_0_1": [
      247,
      240,
      521,
      513
    ],
    "uniform_scale": 0.45161290322580644,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/unlit_p1_mass_idle.png.png",
    "provenance_prompt": "tools/art_prompts/batch_69.md",
    "provenance_log": "tools/source_art/log_b69.md"
  },
  {
    "source": "tools/source_art/unlit_p1_mass_v1.png",
    "batch": "B69",
    "existing_job_id": "b69_unlit_p1_mass_v1",
    "sha256": "71f4a326fdc67df11cd71de4ebcc7f2b03b9dc1c131f4cc398ef3229aae0438b",
    "kind": "unlit_p1_mass",
    "state": "idle",
    "source_row": 0,
    "source_pose": 1,
    "source_bbox": [
      841,
      194,
      1449,
      814
    ],
    "cell": [
      768,
      768
    ],
    "anchor": [
      384.0,
      384.0
    ],
    "alignment": "center",
    "foot": null,
    "actual_footpoint_at_measure_floor_0_1": null,
    "alpha_bounds_at_measure_floor_0_1": [
      245,
      238,
      519,
      518
    ],
    "uniform_scale": 0.45161290322580644,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/unlit_p1_mass_idle.png.png",
    "provenance_prompt": "tools/art_prompts/batch_69.md",
    "provenance_log": "tools/source_art/log_b69.md"
  },
  {
    "source": "tools/source_art/unlit_hush_hand_v1.png",
    "batch": "B70",
    "existing_job_id": "b70_unlit_hush_hand_v1",
    "sha256": "28a2d38d948006b8b317b116fc62d83438bb85fcf3421f62037ece9ee109225a",
    "kind": "unlit_hush_hand",
    "state": "rise",
    "source_row": 0,
    "source_pose": 0,
    "source_bbox": [
      90,
      238,
      342,
      339
    ],
    "cell": [
      192,
      192
    ],
    "anchor": [
      96.0,
      76
    ],
    "alignment": "foot",
    "foot": 176,
    "actual_footpoint_at_measure_floor_0_1": [
      90.0,
      176
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      29,
      124,
      161,
      177
    ],
    "uniform_scale": 0.5245901639344263,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/unlit_hush_hand_rise.png.png",
    "provenance_prompt": "tools/art_prompts/batch_70.md",
    "provenance_log": null
  },
  {
    "source": "tools/source_art/unlit_hush_hand_v1.png",
    "batch": "B70",
    "existing_job_id": "b70_unlit_hush_hand_v1",
    "sha256": "28a2d38d948006b8b317b116fc62d83438bb85fcf3421f62037ece9ee109225a",
    "kind": "unlit_hush_hand",
    "state": "rise",
    "source_row": 0,
    "source_pose": 1,
    "source_bbox": [
      463,
      136,
      697,
      336
    ],
    "cell": [
      192,
      192
    ],
    "anchor": [
      96.0,
      76
    ],
    "alignment": "foot",
    "foot": 176,
    "actual_footpoint_at_measure_floor_0_1": [
      96.0,
      176
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      31,
      72,
      154,
      177
    ],
    "uniform_scale": 0.5245901639344263,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/unlit_hush_hand_rise.png.png",
    "provenance_prompt": "tools/art_prompts/batch_70.md",
    "provenance_log": null
  },
  {
    "source": "tools/source_art/unlit_hush_hand_v1.png",
    "batch": "B70",
    "existing_job_id": "b70_unlit_hush_hand_v1",
    "sha256": "28a2d38d948006b8b317b116fc62d83438bb85fcf3421f62037ece9ee109225a",
    "kind": "unlit_hush_hand",
    "state": "rise",
    "source_row": 0,
    "source_pose": 2,
    "source_bbox": [
      828,
      99,
      1089,
      340
    ],
    "cell": [
      192,
      192
    ],
    "anchor": [
      96.0,
      76
    ],
    "alignment": "foot",
    "foot": 176,
    "actual_footpoint_at_measure_floor_0_1": [
      83.5,
      176
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      31,
      50,
      168,
      177
    ],
    "uniform_scale": 0.5245901639344263,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/unlit_hush_hand_rise.png.png",
    "provenance_prompt": "tools/art_prompts/batch_70.md",
    "provenance_log": null
  },
  {
    "source": "tools/source_art/unlit_hush_hand_v1.png",
    "batch": "B70",
    "existing_job_id": "b70_unlit_hush_hand_v1",
    "sha256": "28a2d38d948006b8b317b116fc62d83438bb85fcf3421f62037ece9ee109225a",
    "kind": "unlit_hush_hand",
    "state": "rise",
    "source_row": 0,
    "source_pose": 3,
    "source_bbox": [
      1189,
      33,
      1471,
      338
    ],
    "cell": [
      192,
      192
    ],
    "anchor": [
      96.0,
      76
    ],
    "alignment": "foot",
    "foot": 176,
    "actual_footpoint_at_measure_floor_0_1": [
      116.5,
      176
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      29,
      17,
      177,
      177
    ],
    "uniform_scale": 0.5245901639344263,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/unlit_hush_hand_rise.png.png",
    "provenance_prompt": "tools/art_prompts/batch_70.md",
    "provenance_log": null
  },
  {
    "source": "tools/source_art/unlit_hush_hand_v1.png",
    "batch": "B70",
    "existing_job_id": "b70_unlit_hush_hand_v1",
    "sha256": "28a2d38d948006b8b317b116fc62d83438bb85fcf3421f62037ece9ee109225a",
    "kind": "unlit_hush_hand",
    "state": "hold",
    "source_row": 1,
    "source_pose": 0,
    "source_bbox": [
      446,
      407,
      697,
      665
    ],
    "cell": [
      192,
      192
    ],
    "anchor": [
      96.0,
      76
    ],
    "alignment": "foot",
    "foot": 176,
    "actual_footpoint_at_measure_floor_0_1": [
      131.0,
      176
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      26,
      42,
      158,
      177
    ],
    "uniform_scale": 0.5245901639344263,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/unlit_hush_hand_hold.png.png",
    "provenance_prompt": "tools/art_prompts/batch_70.md",
    "provenance_log": null
  },
  {
    "source": "tools/source_art/unlit_hush_hand_v1.png",
    "batch": "B70",
    "existing_job_id": "b70_unlit_hush_hand_v1",
    "sha256": "28a2d38d948006b8b317b116fc62d83438bb85fcf3421f62037ece9ee109225a",
    "kind": "unlit_hush_hand",
    "state": "hold",
    "source_row": 1,
    "source_pose": 1,
    "source_bbox": [
      852,
      431,
      1061,
      669
    ],
    "cell": [
      192,
      192
    ],
    "anchor": [
      96.0,
      76
    ],
    "alignment": "foot",
    "foot": 176,
    "actual_footpoint_at_measure_floor_0_1": [
      113.0,
      176
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      41,
      52,
      151,
      177
    ],
    "uniform_scale": 0.5245901639344263,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/unlit_hush_hand_hold.png.png",
    "provenance_prompt": "tools/art_prompts/batch_70.md",
    "provenance_log": null
  },
  {
    "source": "tools/source_art/unlit_hush_hand_v1.png",
    "batch": "B70",
    "existing_job_id": "b70_unlit_hush_hand_v1",
    "sha256": "28a2d38d948006b8b317b116fc62d83438bb85fcf3421f62037ece9ee109225a",
    "kind": "unlit_hush_hand",
    "state": "sink",
    "source_row": 2,
    "source_pose": 0,
    "source_bbox": [
      208,
      749,
      416,
      943
    ],
    "cell": [
      192,
      192
    ],
    "anchor": [
      96.0,
      76
    ],
    "alignment": "foot",
    "foot": 176,
    "actual_footpoint_at_measure_floor_0_1": [
      76.5,
      176
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      42,
      75,
      151,
      177
    ],
    "uniform_scale": 0.5245901639344263,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/unlit_hush_hand_sink.png.png",
    "provenance_prompt": "tools/art_prompts/batch_70.md",
    "provenance_log": null
  },
  {
    "source": "tools/source_art/unlit_hush_hand_v1.png",
    "batch": "B70",
    "existing_job_id": "b70_unlit_hush_hand_v1",
    "sha256": "28a2d38d948006b8b317b116fc62d83438bb85fcf3421f62037ece9ee109225a",
    "kind": "unlit_hush_hand",
    "state": "sink",
    "source_row": 2,
    "source_pose": 1,
    "source_bbox": [
      646,
      801,
      881,
      938
    ],
    "cell": [
      192,
      192
    ],
    "anchor": [
      96.0,
      76
    ],
    "alignment": "foot",
    "foot": 176,
    "actual_footpoint_at_measure_floor_0_1": [
      73.5,
      176
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      34,
      105,
      157,
      177
    ],
    "uniform_scale": 0.5245901639344263,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/unlit_hush_hand_sink.png.png",
    "provenance_prompt": "tools/art_prompts/batch_70.md",
    "provenance_log": null
  },
  {
    "source": "tools/source_art/unlit_hush_hand_v1.png",
    "batch": "B70",
    "existing_job_id": "b70_unlit_hush_hand_v1",
    "sha256": "28a2d38d948006b8b317b116fc62d83438bb85fcf3421f62037ece9ee109225a",
    "kind": "unlit_hush_hand",
    "state": "sink",
    "source_row": 2,
    "source_pose": 2,
    "source_bbox": [
      1088,
      844,
      1338,
      939
    ],
    "cell": [
      192,
      192
    ],
    "anchor": [
      96.0,
      76
    ],
    "alignment": "foot",
    "foot": 176,
    "actual_footpoint_at_measure_floor_0_1": [
      92.0,
      176
    ],
    "alpha_bounds_at_measure_floor_0_1": [
      27,
      127,
      158,
      177
    ],
    "uniform_scale": 0.5245901639344263,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/unlit_hush_hand_sink.png.png",
    "provenance_prompt": "tools/art_prompts/batch_70.md",
    "provenance_log": null
  },
  {
    "source": "tools/source_art/proj_wax_hook_v2.png",
    "batch": "B50",
    "existing_job_id": "b50_proj_wax_hook_v2",
    "sha256": "cbb22d57ac89fc1c338654645ec84bc9a525d932e4926f5f052c243499fd7a3f",
    "kind": "wax_hook",
    "state": "fly",
    "source_row": 0,
    "source_pose": 0,
    "source_bbox": [
      43,
      374,
      320,
      645
    ],
    "cell": [
      96,
      96
    ],
    "anchor": [
      48.0,
      48.0
    ],
    "alignment": "center",
    "foot": null,
    "actual_footpoint_at_measure_floor_0_1": null,
    "alpha_bounds_at_measure_floor_0_1": [
      17,
      23,
      77,
      81
    ],
    "uniform_scale": 0.21993127147766323,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/wax_hook_fly.png.png",
    "provenance_prompt": "tools/art_prompts/batch_50.md",
    "provenance_log": "tools/source_art/log_b50.md"
  },
  {
    "source": "tools/source_art/proj_wax_hook_v2.png",
    "batch": "B50",
    "existing_job_id": "b50_proj_wax_hook_v2",
    "sha256": "cbb22d57ac89fc1c338654645ec84bc9a525d932e4926f5f052c243499fd7a3f",
    "kind": "wax_hook",
    "state": "fly",
    "source_row": 0,
    "source_pose": 1,
    "source_bbox": [
      361,
      356,
      563,
      600
    ],
    "cell": [
      96,
      96
    ],
    "anchor": [
      48.0,
      48.0
    ],
    "alignment": "center",
    "foot": null,
    "actual_footpoint_at_measure_floor_0_1": null,
    "alpha_bounds_at_measure_floor_0_1": [
      24,
      21,
      69,
      76
    ],
    "uniform_scale": 0.21993127147766323,
    "proof_strip": "/tmp/c09c10-review-37ab/strips/wax_hook_fly.png.png",
    "provenance_prompt": "tools/art_prompts/batch_50.md",
    "provenance_log": "tools/source_art/log_b50.md"
  }
]
```

## All referenced raw hashes (including measurement-only sources)

- `tools/source_art/wick_automaton_walk_down_v1.png`: df6bf39180f449cbe545f58ab0367e0d8f725fc4d4443477bb1dafa9f04aeec0
- `tools/source_art/wick_automaton_walk_side_v1.png`: c0eeebb42c3b0f95ba0678cab872c01404737b0f0023870e5eb31d27e4c72835
- `tools/source_art/wick_automaton_walk_up_v1.png`: 86d47c582f975e5c66a00025a46245a87d1fb85d69bc23caba00e6c4369ae4b8
- `tools/source_art/corrows_echo_walk_down_v1.png`: c3901a109f9e84860becf08fd20c0b54f8a7c274d4d7f8a49ed4806da3d79131
- `tools/source_art/corrows_echo_walk_side_v1.png`: d0edfd062d5f4dbf9d5edad088647d5091ff7036452190f6c1735dcd775bb3c9
- `tools/source_art/corrows_echo_walk_up_v2.png`: 99bc843a221d19c93c005a7fe48b3f7e0df19fcb1f27167e51de6fbc25d07913
- `tools/source_art/unlit_p1_mass_v1.png`: 71f4a326fdc67df11cd71de4ebcc7f2b03b9dc1c131f4cc398ef3229aae0438b
- `tools/source_art/unlit_hush_hand_v1.png`: 28a2d38d948006b8b317b116fc62d83438bb85fcf3421f62037ece9ee109225a
- `tools/source_art/proj_wax_hook_v2.png`: cbb22d57ac89fc1c338654645ec84bc9a525d932e4926f5f052c243499fd7a3f

## Integration validation and remaining presentation limits

Opened actual World /tmp/clean-b-automaton-world.png (cave_9_4), /tmp/clean-b-echo-world.png (cave_10_4), /tmp/clean-b-mass-world.png (cave_10_14). Body scale and alpha are clean. Mass is partially obscured by existing large purple ninth_lantern fallback and anchor placeholders; those are withheld assets, not evidence to map rejected full-body sources as parts. Root notified. No all-boss-art-complete claim. Capture-only white ambient, SaveGame disabled, Dummy audio.

Every accepted source/cut proof OPENED, including all hand rise/hold/sink poses and final Corrow component-split proof. Exact five-key Godot check loads every animation/frame texture PASS. Art22, sprite_visual+wick_automaton+corrows_echo+boss_the_unlit four focused suites and lint PASS. All37 source frames copied from the primary accepted-frames record, no conditional scratch outputs. Hand B70 provenance_log is null in original reviewer record: batch_70.md prompt and existing b70_unlit_hush_hand_v1 job ID exist; no log or model/session history invented. Wax hook two tumbling curved frames have no unique stable rightward axis; flight velocity remains actor-owned. No impact frames published.

Hand World proof OPENED /tmp/clean-b-hand-world.png: capture-only trigger of existing boss _spawn_hands, move player clear, then80 normal physics frames. Actual runtime HandPresentation/telegraph/lifetime unchanged; painted hold hands visible with intentional100-radius circles. A first natural380-frame capture stalled before screenshot (likely game-over pause); terminated only that capture, no false pass claimed.
