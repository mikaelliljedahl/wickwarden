# Batch 36 log (12 images)

Prompts: `tools/art_prompts/batch_36.md` (job id in each heading). Backend codex, model `cheapest` (gpt-6-luna, effort medium), one image per job. Each output is checked byte-identical (SHA-256) against its own session folder under `~/.codex/generated_images/<session>/`. Verdicts: ok, weak (why), failed.

Reference images: `tools/source_art/ow_props.png` (boardwalk tiles), `tools/source_art/ow_structures.png` (dock pier). Prompt wording: as written in the batch file (no facing or leg rule applies: no figure in this batch). Job timing: about 1 to 2 minutes per image in this wave.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `boardwalk_straight_v1.png` | `job_01a16f5191ce7b668ab311e5f51978b7` | `01a16f51-d753-7311-98a3-20456c6a48ba` | `exec-ddc6e9b0-1a41-4ed8-b852-12f25dcd6e1b.png` | 1536x1024 | `5ab4cabeffb28ab6` | weak (stubs under the deck: reads as a pallet on legs, not a flat tile) |
| `boardwalk_straight_v2.png` | `job_01a16f5192137205b74b536e0e88b9bc` | `01a16f51-d8e0-70f2-958c-f4ca5507a518` | `exec-d4eb6891-cf78-4cc3-b87a-df3ca1d25c7f.png` | 1536x1024 | `e116bd7d812bb263` | weak (stubs under the deck; planks brown, not weathered grey; a centre nail-like detail) |
| `boardwalk_straight_v3.png` | `job_01a16f51973979a39af47232f20e2076` | `01a16f51-d9b8-7203-8c4d-d16eaf648bd8` | `exec-ccb241d8-a454-449b-a817-57e6548cff5d.png` | 1536x1024 | `eb61d82a5c8831e9` | weak (stubs under the deck; four plank rows, not one tile; golden brown) |
| `boardwalk_end_v1.png` | `job_01a16f519dc573cdb35ec2aef7e9fab9` | `01a16f51-e57f-70d0-84a3-3b16712b50f8` | `exec-63f9f221-9bc0-4953-89f4-a8939f05072f.png` | 1536x1024 | `ddd6086bf009eb26` | weak (stilt legs under the deck, post and rope: close to the dock pier) |
| `boardwalk_end_v2.png` | `job_01a16f51a4297b31bf3b368aeecd809d` | `01a16f51-e7a0-7da2-b11a-4d5d6da9b863` | `exec-4bd1f971-29dd-4401-95ae-84cf5365296a.png` | 1536x1024 | `4eb3b1e95c055812` | weak (stub legs under the deck; post and rope; tile larger than the 96 px cell) |
| `boardwalk_end_v3.png` | `job_01a16f51aa1570cba43db57160e7774c` | `01a16f51-f31b-7dc2-a0de-be7220750b8e` | `exec-9c8fa67e-8dc6-4da3-8d6c-6003c605b5c9.png` | 1536x1024 | `cbe764dcc6ce07fd` | weak (stub legs under the deck; post and rope; close to the dock pier) |
| `boardwalk_corner_v1.png` | `job_01a16f53428a727baf7c9ce06b24fe58` | `01a16f53-488e-7011-983a-72e1e27796e0` | `exec-3708ef46-c5eb-4002-9778-f562e6427df8.png` | 1536x1024 | `0b54ecdc5546672f` | weak (L-shaped dock with three rope posts, not one corner tile) |
| `boardwalk_corner_v2.png` | `job_01a16f5349167efe9f558570bf7cbaa2` | `01a16f53-4e56-7422-bb82-af318d65e53d` | `exec-a1ca649d-33b4-4afe-820f-616850a3eaed.png` | 1536x1024 | `5df6943044dfdbe1` | weak (dock corner with several rope-wrapped posts; not a square tile) |
| `boardwalk_corner_v3.png` | `job_01a16f534fe27f2aa3a706ab73198e52` | `01a16f53-57a9-7040-9444-e0cc2ec3d164` | `exec-92777b02-252f-4284-b457-d36120d70dd0.png` | 1536x1024 | `8d92458212d3a2ad` | weak (cleanest of the three, but two rope posts make it a dock corner, not a tile) |
| `dock_pier_v1.png` | `job_01a16f5356c57913a246b7e0c5a0c203` | `01a16f53-7486-72c3-90d7-b8e88647c183` | `exec-ef5919c6-7e15-44a7-a9bb-d1e44ebe7027.png` | 1536x1024 | `5092d0aecb0b801d` | ok (pier end with ring post; support posts under the deck over water) |
| `dock_pier_v2.png` | `job_01a16f535d597d84956ef31c5e883541` | `01a16f53-8dca-7862-811f-bb2add284dcb` | `exec-9b08a16d-3346-4a29-bac8-68887e1deeaa.png` | 1536x1024 | `ba603728766b0d01` | ok (pier end with ring post and moss; support posts under the deck) |
| `dock_pier_v3.png` | `job_01a16f5364307c02ad390f4092b61ab5` | `01a16f53-ac77-7351-aa9d-014c3257b0a2` | `exec-719f9dca-e515-4130-ab25-543ae08064c3.png` | 1536x1024 | `9e018fa1fe677655` | ok (pier end with ring post; legs under the deck) |

## Batch 36 totals

12 images verified (SHA-256 matches the own-session folder for every file; no duplicate hashes in `tools/source_art/`).
Ok: 3 (`dock_pier` v1 to v3).
Weak: 9 (`boardwalk_straight`, `boardwalk_end`, `boardwalk_corner`, v1 to v3 each). Common defect: the boardwalk tiles stand on stub legs or posts, so they read as pallets, jetties or dock corners, not flat ground tiles. The prompt for the tiles needs "flat on the ground, no legs, no stubs, no posts" in a later pass; not regenerated here, the owner decides.
Failed: 0.
