# Art production progress, producer g (batches 60 to 71)

Range: `docs/art-inventory.md` section 4, batches B60 to B71 (204 images in 68 units). Prompts: `batch_60.md` to `batch_71.md`, generated from the shared block and sheet block of `batch_35.md`. Invented details: `DESIGNS_g.md`. Facing and leg wording: `PROGRESS.md` (facing rule and per-pose leg text).

| Batch | Units | Images | Status |
|---|---|---|---|
| 60 | abacus_brute walk (side, down, up), actions (side, down) | 15 | done: generated, verified, logged (`log_b60.md`), provenance added, committed (`614885a`); 6 ok, 9 weak (walk leg repeats) |
| 61 | wick_automaton walk (side, down, up), actions (side, down) | 15 | done: generated, verified, logged (`log_b61.md`), provenance added, committed; 5 ok, 10 weak |
| 62 | corrows_echo walk (side, down, up), actions (side, down), miniboss_death_wax | 18 | done: generated, verified, logged (`log_b62.md`), provenance added, committed (`0d96799`); 9 ok, 9 weak (walks weak) |
| 64 | briar_bloom_p2, briar_seed, tidewick_head (side, down, up), tidewick_body | 18 | done: generated, verified, logged (`log_b64.md`), provenance added, committed; 12 ok, 6 weak (head up x3 side-on, head down v2, body v3, bloom v2 background) |
| 63 | kilnkeeper_p1 (side, down), kilnkeeper_p2 (side, down), briar_mother_p1, seed_eye | 18 | done: generated, verified, logged (`log_b63.md`), provenance added, committed; 9 ok, 9 weak; anchors kilnkeeper_p1_side v3 and briar_mother_p1 v1 |
| 65 | tidewick_tail, hushed_colossus_body, hushed_colossus_arms (slam, sweep), colossus_shard, archivist_p1 | 18 | done: generated, verified, logged (`log_b65.md`), provenance added, committed; 10 ok, 8 weak (colossus body humanoid in all three; archivist v3 pseudo-writing; slam v2/v3 single arm) |
| 66 | archivist_p2_p3 (three), archivist_decoy (three), dirge_head bass, alto, treble (three each) | 15 | done: generated, verified, logged (`log_b66.md`), provenance added; 13 ok, 2 weak (archivist_p2_p3 v1 has nine poses; dirge_head_bass v3 rings crowd neighbours) |
| 67 | gloam_knight p1 side, p1 down, p1 up, p2 down, p2 side | 15 | done: generated, verified, logged (`log_b67.md`), provenance added; 9 ok, 6 weak (p1 down x3: 4/2/2 layout in every try, top row front-facing; p1 up v1 walk repeat; p2 down v2 middle pose; p2 side v3 slash telegraph); anchor `gloam_knight_p1_side_v1` (producer pick) |
| 68 | coinwyrm head side, head down, plates a, plates b, tail, coin heap | 18 | done: generated, verified, logged (`log_b68.md`), provenance added; 15 ok, 3 weak (head down v1 crowns on bare poses; plates b v1 and v2 cheek plates read as heads or armour sections; tail all ok); anchor `coinwyrm_head_side_v1` (producer pick) |
| 69 | lock_warden body closed/open, body broken, lock plate, lock keyhole, unlit p1 mass, unlit eye | 18 | done: 18 of 18 verified (hashes match own session folders, no duplicates), logged (`log_b69.md`), provenance added, committed; 7 ok, 11 weak; anchors lock_warden_body_closed_open_v1 and unlit_p1_mass_v1 (producer picks); closed/open v3 and unlit mass v2 retried as `-r1` after wrong images |
| 70 | unlit hush hand, unlit p2 shell side and down, unlit p3 heart shielded and exposed, ninth lantern | 18 | not started |
| 71 | unlit chains, hud heart full, hud heart half empty, hud heart beat, hud wick core slot, hud item frame | 18 | not started |

## Known problems

- The walk rule is not held. Most walk and facing units repeat a leg stance in poses 1 and 3 (or 2 and 4) despite the leg wording, and the back and down units often read side-on. These are logged weak; the owner's cull decides. The README regeneration rule (at most three tries per sheet) was not applied because each unit already has three variants.
- Anchors are producer picks, not owner decisions (see `DESIGNS_g.md`): `abacus_brute_walk_side_v1`, `wick_automaton_walk_side_v1`, `corrows_echo_walk_side_v1` (weak, design only).
- The commit of batch 60 swept in another producer's staged file `tools/source_art/log_b25.md` (it was in the shared index). Future commits use `git commit -- <paths>`, which takes only the named paths.

## Recipe used

One Codex job per image (`cheapest`), at most six running at once, idempotency key = job id. Each job copies its PNG from its own session folder; the copy is checked against that folder by SHA-256 and against all other `tools/source_art/` files for duplicates. Each image is viewed and given a verdict (ok, weak with the reason); the agent's own report is used as a second look. Anchor units are chosen after their first generation and dependents are regenerated into the batch file (`render.py` in the scratchpad fills the design reference line).

## Resumed Codex production, 2026-10-25

B71 partial: `hud_heart_full_v1`–`v3` and `unlit_chains_v1`–`v2` generated, own-session hashes verified, no duplicate source hashes, visually opened in `/tmp/wickwarden-art-wave1-review.jpg`. Three hearts ok; two chains weak (middle-row baseline varies). Log: `tools/source_art/log_b71_resume_01.md`. Provenance rows staged separately in `/tmp/wickwarden-art-provenance-additions.md` for lead reconciliation; shared provenance untouched. `unlit_chains_v3` still running at this checkpoint.

B71 second checkpoint: `unlit_chains_v3`, `hud_heart_half_empty_v1`–`v3`, `hud_heart_beat_v1`–`v2` generated, own-session hashes verified, unique source hashes, opened `/tmp/wickwarden-art-wave2-review.jpg`. All six weak: chain baseline, little beat size change; half/empty and beat jobs accidentally omitted the PENDING design anchor (recorded in log). No overwrite or regeneration. Log: `log_b71_resume_02.md`. Six next jobs submitted (beat v3, core slot v1–3, item frame v1–2); beat v3 received managed correction naming full-heart v1 anchor.

B71 third checkpoint: beat v3, wick core slots v1–3 and item frames v1–2 verified by own-session SHA256 and uniqueness; opened `/tmp/wickwarden-art-wave3-review.jpg`. Log `log_b71_resume_03.md`. Slot v2 ok; five weak (perspective, medallion shape, reported faint background texture, missing beat anchor). Managed correction arrived too late; beat v3 was not regenerated. B71 now 17/18 generated; final item frame v3 submitted, plus five B80 icons.
