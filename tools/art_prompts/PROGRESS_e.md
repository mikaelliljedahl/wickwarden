# Art production progress, producer e (batches 36 to 47)

Range: `docs/art-inventory.md` section 4, batches B36 to B47 only. Prompts: `batch_36.md` to `batch_47.md`. Invented designs and unit splits: `DESIGNS_e.md`. Per-batch records: `tools/source_art/log_b36.md` and so on.

Facing and leg rule (`PROGRESS.md`): not needed in this range, no batch has a walk-like or turned figure (props, effects and one lantern pedestal only).

| Batch | Content | Images | Status |
|---|---|---|---|
| 36 | boardwalk (straight, end, corner), dock pier | 12 | done: generated, verified (own-session SHA-256), viewed, logged (`log_b36.md`), provenance added; 3 ok (dock pier), 9 weak (boardwalk tiles stand on stub legs or posts) |
| 37 | wax vat 1 and 2, wax vat pipe, lily pads, shipwreck 1 and 2 | 18 | done: generated, verified (own-session SHA-256), viewed, logged (`log_b37.md`), provenance added; 15 ok, 3 weak (shipwreck 1 v3: magenta through the sail; shipwreck 2 v1 and v2: sand and rocks under the wreck); wax_vat_2_v3 first attempt failed at the reference attach, resubmitted as `-r1` |
| 38 | rusted lantern post, salt crystals 1 and 2, driftwood net, village well, haystack | 18 | done: generated, verified (own-session SHA-256), viewed, logged (`log_b38.md`), provenance added; 13 ok, 5 weak (lantern posts 1 to 3: glass or gold roof, ivy, stone base, magenta in the glass of v3; salt crystals 2 v1 and v2 angular) |
| 39 | cottage, ledge drop, bell 1 to 3 | 15 | done: generated, verified (own-session SHA-256), viewed, logged (`log_b39.md`), provenance added; 12 ok, 3 weak (bell 3: round brass disk reads as a gong). Cottage first attempts (two houses per sheet) rejected, prompt fixed, regenerated as -r1 |
| 40 to 47 | see batch files | 18 each | prompts written, not started |

Wave rule: at most 6 Codex jobs at the same time, one image per job, model `cheapest`, idempotency key `ww-bNN-<unit>-vN`. Each job's output is copied from its own session folder only; SHA-256 checked against that folder and against `tools/source_art/` for duplicates.

## Known problems

- Boardwalk tiles (batch 36): the planks come out on stub legs or with posts, so they read as pallets, jetties or dock corners, not flat ground tiles. The tile prompt needs "flat on the ground, no legs, no stubs, no posts, nothing under the planks" in a later pass. Not regenerated; the owner decides.
- Eight-frame strips (`fx_boss_death_light`, `fx_boss_death_wax`, `fx_rekindle_burst`, batch 46 and 47): a 1536 px row gives 192 px slots for a 768 px cell, about 4x upscale. Open point in `DESIGNS_e.md`.
- `fx_chime_ring`: a 512 px cell cannot hold the 480 px radius of the inventory. Open point in `DESIGNS_e.md`.
- `ledge_drop` (batch 39) and the regional units with two poses: the cut tool needs a multi-piece rule for two poses in one row, or the owner splits the names.

## Recipe used

Same as `PROGRESS.md`: one Codex job per image (`cheapest`, gpt-6-luna medium), at most six running. The job reads its entry in the batch file and copies the png from its own session folder only. Verification by SHA-256 against the own session folder (session id from `get_job`) and against all other `tools/source_art/` files; viewing each image with the Read tool; `stop_agent` after each wave.
