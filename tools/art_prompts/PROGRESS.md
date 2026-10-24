# Art production progress

Next batch to do: **4** (see `docs/art-inventory.md` section 4). Batches 1 to 3 are done; no prompt file for batch 4 exists yet.

## Status

| Batch | Content | Prompts | Images | Status |
|---|---|---|---|---|
| 1 | Tamsin wick cast, sling shot, raft ride, mitts lift (side) | `batch_01.md` | 12 | generated, verified, logged, committed (`log_b01.md`) |
| 2 | Tamsin mitts carry (side, down, up), throw | `batch_02.md` | 18 | generated, verified, logged, committed (`log_b02_b03.md`) |
| 3 | Tamsin mitts pull and push (side, down, up) | `batch_03.md` | 18 | generated, verified, logged, committed (`log_b02_b03.md`) |

All 42 images exist as `tools/source_art/tamsin_*_vN.png` (1536x1024), all are in `docs/art-provenance.md`. Rejections are left to the owner's cull.

## Known problems

- Parallel Codex jobs can copy another job's image. Batches 1 to 3 had no such case in the final wave (all 42 hashes unique, each equal to the png in its own session folder), but keep checking.
- One job (`ww-b02-carry-up-v1`) failed with `backend_not_started`; it was resubmitted under idempotency key `ww-b02-carry-up-v1-retry1`. Use a new idempotency key for every resubmission.
- Quality defects found by viewing (details in the logs): the `pull_down` and `push_down` sheets show Tamsin in side profile instead of facing the viewer (all 6); `pull_up` and `push_up` are mostly side-on, not clearly away from the viewer; nearly every 4-pose walk-like sheet repeats the same leg arrangement in poses 1 and 3 and in poses 2 and 4 despite the leg wording in the prompts. Fix idea for later prompts: describe the facing more forcefully ("her chest and face point at the viewer; her body is square to the camera, not turned to the right") and give a distinct pose description for every one of the four poses.
- Image tool returns 1536x1024 for sheets; textures 1254x1254 (see README).

## Recipe used (works)

1. Load schemas: `ToolSearch select:mcp__agentteamforge__submit_job,mcp__agentteamforge__get_job,mcp__agentteamforge__list_jobs,mcp__agentteamforge__stop_agent`.
2. `submit_job`: backend `codex`, model `cheapest`, cwd the repo, one job per image, `timeout_s` 900, `expected_outputs` [absolute png path], unique `idempotency_key`, name `ww-bNN-<id>`. Instruction: "Make ONE image call with your native image generation tool (gpt-image). Do not plan or analyse. Entry: <job id> in tools/art_prompts/batch_NN.md. 1. Read the entry. 2. Pass its fenced prompt EXACTLY as written, with the reference images listed in the entry attached. Size WxH. 3. Copy the generated file unchanged to the output file named in the entry. Other jobs run in parallel in the same ~/.codex/generated_images/ tree: copy ONLY from the folder named after your own session/thread id ($CODEX_THREAD_ID if set), never the newest file overall. 4. Edit no other file, run no git, do not retry. Report: output path, width x height, generated file name, your session id, visible defects."
3. At most 15 jobs in parallel; a wave of 15 finishes in about 2 minutes. Wait with a background `until [ files exist ]` loop (a foreground `sleep` is blocked).
4. Verify: for each output, sha256 it and compare with the pngs in `~/.codex/generated_images/<session_id>/` (session_id from `list_jobs`/`get_job`). A match gives the output id (file name) too. If different and the folder has one png, copy it over the output. Check there are no duplicate hashes across `tools/source_art/tamsin_*.png`.
5. `stop_agent` every finished job of the wave (each `job_id`; `list_jobs` shows `agent_live: true` for the ones still open).
6. View the images (a montage of three variants per row with `magick a.png b.png c.png -resize 1000x -append out.jpg` keeps the cost low), write the log `tools/source_art/log_<batch>.md` in the layout of `log_terrain.md` (file, date, references, attempts, size, tool, session, output id, SHA-256, defects, prompt entry and exact prompt), add rows to the table in `docs/art-provenance.md`, commit only `tools/source_art/`, `tools/art_prompts/` and `docs/art-provenance.md` (no AI attribution, never push).
