# Art production progress, producer c (batches 20 to 27)

Owner ranges: art batches 20 to 27 of `docs/art-inventory.md` section 4. Other producers work on other ranges (see `PROGRESS.md`, `PROGRESS_a.md`).

| Batch | Content | Prompts | Images | Status |
|---|---|---|---|---|
| 20 | item_reel_line, icon_hook_flare_ward, flame_cinder, slug_tallow | `batch_20.md` | 18 | generated, verified (hashes, montages), 10 ok, 8 weak; logged in `log_b20.md`; provenance rows added; committed |
| 21 | reed_raft_vehicle, jar_thrown, jar_lit, reel_tip, reel_line_rope, liftable_rock_small | `batch_21.md` | 18 | generated, verified, 9 ok, 8 weak, 1 failed (`reel_line_rope_v2`, wrong subject); logged in `log_b21.md`; provenance added; committed |
| 22 | slug_bundle, pot_bag, tallow_flask, bigkey | `batch_22.md` | 12 | not started |
| 23 | fragment_c1_to_c9 (units c1 to c6, c7 variants 1 and 2) | `batch_23.md` | 20 | not started |
| 24 | fragment_c1_to_c9 (c7 variant 3, c8, c9), slag_chunk, thorn_hedge, thorn_wall, thorn_door | `batch_24.md` | 19 | not started |
| 25 | eye_switch, eye_portcullis, eye_cell, mooring, edge_pit_rim, pit_fill | `batch_25.md` | 18 | not started |
| 26 | low_rail, anchor_ring, anchor_pocket, heavy_stone, heavy_boulder, heavy_door | `batch_26.md` | 18 | not started |
| 27 | heavy_stones, resonance_stone, resonance_door, resonance_vault, hidden_seam, hidden_stairs | `batch_27.md` | 18 | not started |

Total: 141 images in 8 batches. Batches 20 and 21 are done (36 images).

## Recipe used

One Codex job per image (`cheapest`, gpt-6-luna, effort medium), at most six running at once. Each job reads its entry in the batch file and copies the png from its own session folder only. Each output is checked against its session folder by SHA-256 and against all other `tools/source_art/` files for duplicates. Montages (three variants per unit) are viewed. Every job is stopped after its result is in.

## Known problems

- Batch 21: `reel_line_rope_v2` failed (a reed raft and dock instead of a cord); the reed raft sheets (v1 to v3) have the landing boards cut at the cell edge. Not regenerated; the owner decides.

- `item_reel_line_v3` came back 2172x724 instead of 1536x1024. The four poses are still in one row, so the file is kept as returned.
- A job can report a pose count that the image does not show. The flame_cinder_v2 job said 10 poses; the image has 11 (4/4/3). The montage decides, not the job report.
- Glint poses (idle plus glint 3) come out with weak highlights: poses 2 to 4 often look like pose 1. Logged as weak.
