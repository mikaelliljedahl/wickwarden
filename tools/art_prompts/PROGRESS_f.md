# Art production progress, producer f (batches 48 to 59)

Range: `docs/art-inventory.md` section 4, batches B48 to B59 only (192 images). Other producers work on other ranges (see `PROGRESS.md`, `PROGRESS_a.md` to `PROGRESS_d.md`). Invented details: `DESIGNS_f.md`.

| Batch | Content | Images | Status |
|---|---|---|---|
| 48 | proj_slag_ball, proj_spore_bolt, proj_thorn_needle, proj_ember_bolt, proj_beam_bolt, proj_ink_bolt | 18 | in progress (see notes) |
| 49 | proj_page_ring, proj_note_ring, proj_lance, proj_coin, proj_key_volley, proj_gaze_bolt | 18 | not started |
| 50 | proj_hush_torrent, proj_water_jet, proj_wax_hook, light_glow_warm, light_glow_cold, light_shaft | 18 | not started |
| 51 | light_jar_glow, npc_tilly, npc_peddler, npc_ashwife, npc_mason, npc_pilgrim | 18 | not started |
| 52 | npc_keeper, npc_villager_a | 12 | not started |
| 53 | npc_villager_b, npc_corrow_wax, npc_corrow_ghost (provisional) | 15 | not started |
| 54 | hollow_captain_walk, hollow_captain_actions | 15 | not started |
| 55 | thorn_warden_walk, thorn_warden_actions, sump_lurker | 18 | not started |
| 56 | lull_mauler_walk, lull_mauler_actions | 15 | done: 15 of 15 generated, verified (hashes match own session folders, no duplicates), logged (`log_b56.md`), provenance added; walk side v1 anchor (producer pick); 1 failed job (`b56_lull_mauler_actions_side_v2`, relative reference path) regenerated as `-r1`; 5 ok, 10 weak |
| 57 | mirror_warden_walk, mirror_warden_actions | 15 | not started |
| 58 | choir_warden_walk, choir_warden_actions | 15 | not started |
| 59 | pale_squire_walk, pale_squire_actions | 15 | not started |

## Run notes

- Prompt files `batch_48.md` to `batch_59.md`, generated from the verbatim shared block, the sheet block and the facing sentences of `art-brief.md`; the leg wording and facing wording follow `PROGRESS.md` and `PROGRESS_a.md` (facing: "its face or front points straight at the viewer ..." for down; "its back is to the viewer ..." for up; four distinct walk poses with leg A and leg B).
- Job recipe: codex backend, model `cheapest`, one image per job, at most 6 running at once, idempotency key = job id (`-r1` suffix for a resubmission), timeout 900 s. Each job copies the image from its own session folder; the orchestrator checks the SHA-256 against that session folder and against all other `tools/source_art/` files.
- Walk and action sheets: the side sheet is generated first; the down and up sheets and the action sheets name the side or same-facing walk sheet (variant 1) as design reference, so they run after it.
- Rows: a sheet has one row per animation or per group of at most four poses; the row map is in each sheet's layout line.

## Problems

- Batch 56: `b56_lull_mauler_actions_side_v2` failed with "AbsolutePathBuf deserialized without a base path" because the reference was a relative path. Use absolute reference paths in job text.
- Batch 56 walk units repeat leg arrangements (poses 1 and 3, 2 and 3) and down/up units drift sideways; logged weak.

- Batch 48, `proj_spore_bolt_v1` (job `b48_proj_spore_bolt_v1`): failed; the job attached its own session folder as a reference image. Resubmitted as `-r1`, accepted.
- Batch 48, `proj_ember_bolt` v1 to v3 and `proj_beam_bolt` v1 and v2 (first run): the style reference `tools/source_art/hush_spitcap.png` made the model draw the spitcap creature in every pose. Rejected; regenerated under `-r1` with no reference (the entries of ember, thorn, beam and ink now say "none"). The first-run files are overwritten by the regenerated ones.
- `proj_slag_ball` v1 to v3 and `proj_spore_bolt` v2 and v3 were run with `hush_spitcap.png` attached; their images show no spitcap, and the entries keep that reference, as run.
