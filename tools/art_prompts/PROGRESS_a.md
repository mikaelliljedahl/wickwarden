# Art production progress (producer a: batches 4 to 11)

Scope: batches 4 to 11 only (coordinator instruction). Batches 12 and up belong to other producers.
Limit: at most 6 Codex jobs running at once. Only this file and `DESIGNS_a.md` are written for tracking; `PROGRESS.md` belongs to the earlier producer and is read, not edited.

## Status

| Batch | Prompts | Images | Status |
|---|---|---|---|
| 4 | `batch_04.md` (6 rows, side only) | 18 | generated, checked, logged (`log_b04.md`); 15 ok, 3 weak (reel pull: line cut at the right edge) |
| 5 | `batch_05.md` (pot place, moth throw side; item get, flask drink, pit fall, death down) | 18 | prompts written; not yet submitted |
| 6 to 11 | not yet written | | |

## Run notes

- Job instruction: each job reads its own fenced prompt from the batch file (`### <job id>` heading) and attaches the listed reference images; it writes nothing. The orchestrator copies the PNG from `~/.codex/generated_images/<session_id>/`, checks SHA-256 against all other `tools/source_art/` files, then views it.
- Idempotency keys are the job ids; resubmit under a new key (`<job id>-r1`) after a failure.
- Stopped by mistake: `b04_jar_throw_side_v1` (job `job_01a16f3c3b7876249991ea3a184fa338`, cancelled before it produced an image; it was the 7th submission above the limit of 6). Resubmit it as `b04_jar_throw_side_v1-r1` when a slot is free.
- Facing and leg-pose fix from `PROGRESS.md` (coordinator): applies to every walk-like or facing sheet from batch 5 on (down-only and up/down rows). Its wording: "her chest and face point at the viewer; her body is square to the camera, not turned to the right" for down; "her back is to the viewer, the braid and coat back visible" for up; every pose gets its own distinct description (pose 1 = contact, leg A forward; pose 2 = passing; pose 3 = contact, leg B forward; pose 4 = passing with the other leg lifted), so poses 1 and 3 and 2 and 4 never repeat the same leg arrangement. Batch 4 has no facing rows, so its prompts are unchanged.
- Images returned at 1536x1024 by the tool.

## Problems

- Batch 4: `b04_jar_throw_side_v1` stopped by mistake (cancelled), resubmitted as `-r1`. Some jobs report an output name that is not in their own session folder, and one session folder holds two images (chime_hold v1 and v3, leap v3). Rule: take the own-folder file that matches the reported name, else the later one; each case is named in `log_b04.md`.
- Batch 4 reel pull (v1 to v3): the line runs off the right edge in pose 2. Kept as weak for the cull; regenerate those three if the owner rejects them.
- Batch 5 uses the down-facing wording from the coordinator note (front view, square to the camera) and the down reference `tamsin_walk_down.png` for the four down rows.
