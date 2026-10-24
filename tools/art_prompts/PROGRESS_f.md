# Art production progress, producer f (batches 48 to 59)

Range: `docs/art-inventory.md` section 4, batches B48 to B59 only (192 images). Other producers work on other ranges (see `PROGRESS.md`, `PROGRESS_a.md` to `PROGRESS_d.md`). Invented details: `DESIGNS_f.md`.

| Batch | Content | Images | Status |
|---|---|---|---|
| 48 | proj_slag_ball, proj_spore_bolt, proj_thorn_needle, proj_ember_bolt, proj_beam_bolt, proj_ink_bolt | 18 | done, verified, logged (`log_b48.md`) |
| 49 | proj_page_ring, proj_note_ring, proj_lance, proj_coin, proj_key_volley, proj_gaze_bolt | 18 | done, verified, logged (`log_b49.md`) |
| 50 | proj_hush_torrent, proj_water_jet, proj_wax_hook, light_glow_warm, light_glow_cold, light_shaft | 18 | done, verified, logged (`log_b50.md`); light_shaft is 1024x1536 |
| 51 | light_jar_glow, npc_tilly, npc_peddler, npc_ashwife, npc_mason, npc_pilgrim | 18 | done, verified, logged (`log_b51.md`) |
| 52 | npc_keeper, npc_villager_a | 12 | done, verified, logged (`log_b52.md`) |
| 53 | npc_villager_b, npc_corrow_wax, npc_corrow_ghost (provisional) | 15 | done, verified, logged (`log_b53.md`) |
| 54 | hollow_captain_walk, hollow_captain_actions | 15 | done, verified, logged (`log_b54.md`); walk side is 2172x724, guard drawn as lantern |
| 55 | thorn_warden_walk, thorn_warden_actions, sump_lurker | 18 | done, verified, logged (`log_b55.md`) |
| 56 | lull_mauler_walk, lull_mauler_actions | 15 | done: 15 of 15 generated, verified (hashes match own session folders, no duplicates), logged (`log_b56.md`), provenance added; walk side v1 anchor (producer pick); 1 failed job (`b56_lull_mauler_actions_side_v2`, relative reference path) regenerated as `-r1`; 5 ok, 10 weak |
| 57 | mirror_warden_walk, mirror_warden_actions | 15 | done: 15 of 15 generated, verified (hashes match own session folders, no duplicates), logged (`log_b57.md`), provenance added; walk side v1 anchor (producer pick); 1 ok (actions down v3), 14 weak; all units show gold/bronze armour instead of pale silver-grey and unrequested capes; down and up units drift to side or three-quarter |
| 58 | choir_warden_walk, choir_warden_actions | 15 | done: 15 of 15 generated, verified (hashes match own session folders, no duplicates), logged (`log_b58.md`), provenance added; walk side v1 anchor (producer pick); 3 ok, 12 weak; walk units near-static (poses 1 and 3 alike), inhale poses alike in actions |
| 59 | pale_squire_walk, pale_squire_actions | 15 | done: 15 of 15 generated, verified (hashes match own session folders, no duplicates), logged (`log_b59.md`), provenance added; walk side v1 anchor (producer pick); 0 ok, 15 weak; every unit draws gold/cream armour and red cape or tabard instead of chalk-white; walk poses near-identical |

## Run notes

- Prompt files `batch_48.md` to `batch_59.md`, generated from the verbatim shared block, the sheet block and the facing sentences of `art-brief.md`; the leg wording and facing wording follow `PROGRESS.md` and `PROGRESS_a.md` (facing: "its face or front points straight at the viewer ..." for down; "its back is to the viewer ..." for up; four distinct walk poses with leg A and leg B).
- Job recipe: codex backend, model `cheapest`, one image per job, at most 6 running at once, idempotency key = job id (`-r1` suffix for a resubmission), timeout 900 s. Each job copies the image from its own session folder; the orchestrator checks the SHA-256 against that session folder and against all other `tools/source_art/` files.
- Walk and action sheets: the side sheet is generated first; the down and up sheets and the action sheets name the side or same-facing walk sheet (variant 1) as design reference, so they run after it.
- Rows: a sheet has one row per animation or per group of at most four poses; the row map is in each sheet's layout line.

## Problems

- Batch 56: `b56_lull_mauler_actions_side_v2` failed with "AbsolutePathBuf deserialized without a base path" because the reference was a relative path. Use absolute reference paths in job text.
- Batch 57: the job text used relative reference paths for the first wave; later jobs used absolute paths. Armour colour drift (gold/bronze, dark capes) in every unit of the Mirror Warden; logged for the owner.
- Batch 56 walk units repeat leg arrangements (poses 1 and 3, 2 and 3) and down/up units drift sideways; logged weak.

- Batch 48, `proj_spore_bolt_v1` (job `b48_proj_spore_bolt_v1`): failed; the job attached its own session folder as a reference image. Resubmitted as `-r1`, accepted.
- Batch 48, `proj_ember_bolt` v1 to v3 and `proj_beam_bolt` v1 and v2 (first run): the style reference `tools/source_art/hush_spitcap.png` made the model draw the spitcap creature in every pose. Rejected; regenerated under `-r1` with no reference (the entries of ember, thorn, beam and ink now say "none"). The first-run files are overwritten by the regenerated ones.
- `proj_slag_ball` v1 to v3 and `proj_spore_bolt` v2 and v3 were run with `hush_spitcap.png` attached; their images show no spitcap, and the entries keep that reference, as run.

## Run log (pi producer, batches 48 to 55)

- The earlier Claude-side f producer had generated batches 48 to 53 (81 images) without logs or provenance. This run verified all 81 (SHA-256 equal to the PNG in the session folder, no duplicates) and wrote their logs.
- Bridge test: `agentteamforge_submit_job` from pi worked (job `b50_light_glow_cold_v2`, verified).
- Images generated in this run: 2 (b50), 2 (b51), 1 (b52), 13 (b53), 15 (b54), 18 (b55) = 51; all verified.
- Resubmissions: `b54_hollow_captain_actions_side_v2` failed with a relative reference path (`AbsolutePathBuf` error), resubmitted as `b54_hollow_captain_actions_side_v2-r1` with an absolute path, accepted. From batch 55 on, reference paths are absolute.
- Sizes returned: several images came back 1254x1254 (light, 1024 requested), 2172x724 (hollow captain walk side) and light_shaft 1024x1536. Not fixed; logged.
