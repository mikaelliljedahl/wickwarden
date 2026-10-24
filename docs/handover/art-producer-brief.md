# Brief for a Wickwarden ART producer (pi, Haiku)

You produce source art for Wickwarden (Godot 4.7) in the git repo /home/mikael/code/github/wickwarden (branch main).
Other agents commit to the same repo at the same time. Their files are not yours: leave them alone.
The original art producers were stopped. You take over YOUR BATCH RANGE from where the progress file says it stopped.

## READ FIRST
1. tools/art_prompts/README.md (rules for prompts and the run recipe, section "Run recipe").
2. docs/handoff.md section 5 "Art pipeline" (recipe, verification, known weak points).
3. tools/art_prompts/PROGRESS.md (the recipe that worked) and your progress file PROGRESS_<x>.md (named in your task).
4. docs/art-inventory.md section 4 (the batch table) for your batches.
5. The batch files tools/art_prompts/batch_NN.md for your batches. Each job has an entry with a job id heading, its fenced prompt and reference images.

## JOB RECIPE (one image per Codex job)
- Submit with the AgentTeamForge tool: in pi use mcp({tool:"agentteamforge_submit_job", args:{...}}). If that tool is missing or fails, STOP and report "BRIDGE_FAIL: <error>" as your final message.
- args: backend "codex", model "cheapest", cwd the repo, name like "ww-b40-jobid-v1" (letters, digits, '-' or '_' only, max 64), idempotency_key a unique string (the job id; for a retry use "<job id>-r1"), timeout_s 900, expected_outputs [absolute path of the output PNG in tools/source_art/].
- instruction: "Make ONE image call with your native image generation tool (gpt-image). Do not plan or analyse. Entry: <job id> in tools/art_prompts/batch_NN.md. 1. Read the entry. 2. Pass its fenced prompt EXACTLY as written, with the reference images listed in the entry attached. Size WxH. 3. Copy the generated file unchanged to the output file named in the entry. Other jobs run in parallel in the same ~/.codex/generated_images/ tree: copy ONLY from the folder named after your own session/thread id ($CODEX_THREAD_ID if set), never the newest file overall. 4. Edit no other file, run no git, do not retry. Report: output path, width x height, generated file name, your session id, visible defects."
- At most 6 Codex jobs running at once for you.
- Wait with background sleeps, e.g. `sleep 240` in bash (a job takes 3 to 5 minutes). Poll with get_job / list_jobs.
- FIRST ACTION: submit ONE job (the first image of your first batch) as a bridge test. Wait for it, verify it (below). Then continue. If the bridge works, say so in your final report.

## VERIFY EVERY PNG
- Get the job's session_id (get_job / list_jobs).
- Take the PNG ONLY from ~/.codex/generated_images/<session_id>/. Never take the newest file in that folder.
- SHA-256 of the copy must be unique among all files in tools/source_art/ (compare with every existing PNG there). Duplicates are not allowed.
- View the result (montage of the variants: `magick a.png b.png c.png -resize 1000x -append /tmp/ww-art/out.jpg`, then open with the read tool). Note defects. Do NOT reject images by hand: weak images are logged; the owner culls. Regenerate at most three times for a sheet that breaks the README rules (item 7 of "Run recipe").
- stop_agent every Codex job after its wave (list_jobs shows agent_live true for open ones).

## LOGS, PROVENANCE, COMMITS
- Per batch write tools/source_art/log_bNN.md in the layout of tools/source_art/log_terrain.md (file, date, references, attempts, size, tool, session, output id, SHA-256, defects, prompt entry).
- Add a row per kept image to docs/art-provenance.md (follow the table format there).
- Update your PROGRESS_<x>.md table (status per batch).
- Commit ONLY your paths: `git add <paths>` then `git commit -m "Art batch NN-MM: prompts, source images, log, provenance (producer X)" -- <paths>`. Never git add -A or git add ., never reset, stash, checkout, clean, or push. Do not commit a file of another producer.
- Commit after each finished batch.
- No AI attribution in commits (no Co-Authored-By, no "Generated with").

## NEW PROMPTS (only if your range has batches without a batch file)
Write tools/art_prompts/batch_NN.md following tools/art_prompts/README.md and the existing batch files (keep the shared prompt blocks verbatim; forbid pixel art, text, grids and frames; flat key background; `Image size: WxH.` as the last line). Commit the prompt file with the batch.

## FINAL REPORT (max 15 lines)
- DONE, PARTIAL or BRIDGE_FAIL.
- Batches finished, batches open, counts (images generated, weak, failed).
- Commit hashes.
- Bridge test result (did submit_job work from pi).
- Open problems, one line each.
