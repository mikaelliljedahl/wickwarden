# Art production progress, batches 12 to 19 (producer b)

Range: `docs/art-inventory.md` section 4, batches B12 to B19 (144 images, 8 batches of 18). Prompts are written by `tools/art_prompts/gen_b.py`-style templates from the verbatim shared, sheet, texture and face blocks of `art-brief.md`; the batch files are the output. The icon and edge-strip blocks are written from the sheet block and `asset-contract.md` section 7 (see the header of each batch file).

| Batch | Content | Images | Status |
|---|---|---|---|
| 12 | shared cave sets stone and root (textures, faces) | 18 | generated, verified, logged (`log_b12.md`); 3 ok-looking units, the rest weak (rubble, rock-dominant) |
| 13 | cave tex water, two cave edge strips, bramble snapper, fen leech, cinder wisp | 18 | generated, verified, logged (`log_b13.md`): 5 ok, 11 weak, 2 failed; edge strips at 2.5:1 |
| 14 | watcher eye (3 views), husk hound walk (3 facings) | 18 | not started |
| 15 | husk hound states, brine crab walk and states, wickling | 18 | not started |
| 16 | mirror shade walk and states | 18 | not started |
| 17 | choirling, icons tether moth, pitch pot, cinder wick, tallow sling, reed raft | 18 | not started |
| 18 | icons heft mitts, glow jar, lantern chime, skitter boots, reel line; item cinder wick | 18 | not started |
| 19 | pedestal items tallow sling, reed raft, heft mitts, glow jar, lantern chime, skitter boots | 18 | not started |

## Known problems

- Every texture comes back at 1254x1254, not 1024x1024 (the tool, as in batches 1 to 3 and the terrain pass). Not resized, per the README.
- Batch 12 stone and root textures: most variants show rubble or rock-dominant ground instead of cut slabs or roots. Kept for the owner's cull, logged as weak.
- Parallel jobs: each job copied from its own session folder; every output was checked by SHA-256 against its session folder, and no duplicate hashes exist in `tools/source_art/`.
- Another producer writes into the shared scratchpad; producer b keeps its records in its own folder only.

- Edge strips (`edge_*`, batch 13 so far): the tool returns about 2.5:1 (1983x793, 2048x768) for the requested 1536x384 (4:1). Each edge file is kept as it came out. The cut tool needs a 4:1 source (384x96 cell); this must be solved before the edges are cut (crop, or a different request). Owner decision.
- Batch 13 fen leech: the prompt says no water, but the generator drew ripples and puddles around the body in most variants.

## Process

Submit one job per image (backend codex, model cheapest), at most 6 running. Verify each copy against the own session folder, view it (montage of three), write the log line, stop the job with stop_agent, update the provenance rows (generated with the verification script), record invented design details here, then commit the batch (batch file, its source images, its log; provenance is shared and is committed by whoever commits it first).
