# Art production progress, batches 12 to 19 (producer b)

Range: `docs/art-inventory.md` section 4, batches B12 to B19 (144 images, 8 batches of 18). Prompts are written by `tools/art_prompts/gen_b.py`-style templates from the verbatim shared, sheet, texture and face blocks of `art-brief.md`; the batch files are the output. The icon and edge-strip blocks are written from the sheet block and `asset-contract.md` section 7 (see the header of each batch file).

| Batch | Content | Images | Status |
|---|---|---|---|
| 12 | shared cave sets stone and root (textures, faces) | 18 | generated, verified, logged (`log_b12.md`); 3 ok-looking units, the rest weak (rubble, rock-dominant) |
| 13 | cave tex water, two cave edge strips, bramble snapper, fen leech, cinder wisp | 18 | generated, verified, logged (`log_b13.md`): 5 ok, 11 weak, 2 failed; edge strips at 2.5:1 |
| 14 | watcher eye (3 views), husk hound walk (3 facings) | 18 | generated, verified, logged (`log_b14.md`): 6 ok, 12 weak; side references watcher v1 and husk v2 |
| 15 | husk hound states, brine crab walk (3 facings) and states, wickling | 18 | generated, verified, logged (`log_b15.md`): 5 ok, 13 weak; brine side reference v1 |
| 16 | mirror shade walk (3 facings) and states (fade, echo swing, decoy crack) | 18 | generated, verified, logged (`log_b16.md`): 4 ok, 13 weak, 1 failed (walk side v2, three attempts coloured); walk side reference v1 |
| 17 | choirling (3 rows), icons tether moth, pitch pot, cinder wick, tallow sling, reed raft | 18 | generated, verified, logged (`log_b17.md`): 15 ok, 3 weak (choirling); two cinder wick images recovered from the job's own session folder |
| 18 | icons heft mitts, glow jar, lantern chime, skitter boots, reel line; item cinder wick (pedestal) | 18 | generated, verified, logged (`log_b18.md`): 17 ok, 1 weak (glow jar v3, heart-shaped) |
| 19 | pedestal items tallow sling, reed raft, heft mitts, glow jar, lantern chime, skitter boots | 18 | generated, verified, logged (`log_b19.md`): 16 ok, 2 weak (glow jar v3, lantern chime v3) |

## Known problems

- Every texture comes back at 1254x1254, not 1024x1024 (the tool, as in batches 1 to 3 and the terrain pass). Not resized, per the README.
- Batch 12 stone and root textures: most variants show rubble or rock-dominant ground instead of cut slabs or roots. Kept for the owner's cull, logged as weak.
- Parallel jobs: each job copied from its own session folder; every output was checked by SHA-256 against its session folder, and no duplicate hashes exist in `tools/source_art/`.
- Another producer writes into the shared scratchpad; producer b keeps its records in its own folder only.

- Edge strips (`edge_*`, batch 13 so far): the tool returns about 2.5:1 (1983x793, 2048x768) for the requested 1536x384 (4:1). Each edge file is kept as it came out. The cut tool needs a 4:1 source (384x96 cell); this must be solved before the edges are cut (crop, or a different request). Owner decision.
- Batch 13 fen leech: the prompt says no water, but the generator drew ripples and puddles around the body in most variants.

- Facing (batch 14 up views): the up units came out in side profile or with the eye facing the viewer (watcher up v1 to v3, husk up v1 to v3 weak). The batch 14 prompts were run with the older facing wording; batches 15 and 16 use the stronger wording (chest and face at the viewer for down, back at the viewer and body square to the camera for up). Batch 14 up units are kept as weak for the owner's cull; no retries yet.

- Brine crab, down and up (batch 15): every front and rear view came out as a side profile or a three-quarter view, even with the stronger facing text (brine down v1 to v3 all weak; brine up v1 to v3 weak). A crab with a side-only read may need a different subject wording or a side-only unit; the owner decides.
- Batch 15 facing text: batches 15 and 16 use the stronger down and up wording (see batch 14 note).

- Mirror shade silhouettes (batch 16): the reference `tamsin_walk.png` is in colour and the model keeps colour, face and lantern in many variants (walk side v2 failed three times; side v3 first try and down v2, up v1, up v2 show shading or detail). The stronger silhouette wording (`SHADE_NEW` in the generator) was used from the retries on; the owner may want a silhouette-only reference.
- Walk cycles in batch 16 and batch 14/15 repeat leg arrangements in pose pairs (1 and 3, 2 and 4) in most variants (README rejection rule). Kept as weak for the owner's cull.

- Choirling (batch 17): all three variants show a leafy, mossy body instead of the pale wax singer. The reference `hush_spitcap.png` is the cause (its cap is olive and moss). Not retried: weak for the owner's cull; `hush_skitterwick.png` would be the next reference to try.
- Failed-looking jobs (batch 17): cinder wick v2 and v3 jobs reported FAILED because `CODEX_THREAD_ID` was unset, but each job's own session folder held exactly one PNG written at run time. The lead copied from that folder only and checked by SHA-256.

- Icons (batches 17 to 19): every 1024x1024 request came back 1254x1254 (the same tool behaviour as the textures); not resized. The landscape pedestal sheets come back at 1536x1024 as requested.

## Totals (batches 12 to 19)

- 144 images, one verdict each: 78 ok, 63 weak, 3 failed. The failed ones: `edge_cave_floor_to_wall_v2` and `edge_cave_water_v2` (kept in the repo with their failed verdict, 2.7:1 aspect and band position); `mirror_shade_walk_side_v2` (three attempts, coloured Tamsin; no file in the repo). The owner culls.
- Structural findings for the owner: edge strips come back at 2.5:1 (cut tool needs 4:1); the choirling reference; the crab front and rear views; mirror-shade silhouettes; every 1024x1024 request returns 1254x1254.

## Process

Submit one job per image (backend codex, model cheapest), at most 6 running. Verify each copy against the own session folder, view it (montage of three), write the log line, stop the job with stop_agent, update the provenance rows (generated with the verification script), record invented design details here, then commit the batch (batch file, its source images, its log; provenance is shared and is committed by whoever commits it first).
