# Wickwarden — orchestrator handoff

Audience: a new orchestrator (an agent session or a human) who takes over the build with no other context.
Language: English. The owner writes Swedish; see section 7 for how to talk to him.

Read this file first, then [state.md](state.md). The rules for agents are in [../AGENTS.md](../AGENTS.md).

---

## Status (update at every push)

Last updated: 2026-10-25, final integrated checkpoint. Read [state.md](state.md) next.

- **Verified pre-push HEAD:** `a1cf76d`; latest checked code/room commit is `90c7c0a`. The status commit follows that checkpoint and cannot name itself. Push outcome will be recorded in a follow-up status commit.
- **Gates green:** `make check`: all 70 test files passed, gdlint reported no problems, world data up to date, 96 Python tests OK. `make rooms-check`: checked 66 of 66 sources. `python3 tools/check_ownership.py --global`: 92 WPs, 53 room batches; 192 graph rooms/33 pockets each assigned once; no wave 1–5 path overlap.
- **Logs:** `/tmp/wickwarden-final-check.log`, `/tmp/wickwarden-final-rooms.log`, `/tmp/wickwarden-final-ownership.log`. Commit stats/path review since `ebf58bb`: `/tmp/wickwarden-checkpoint-scopes.txt`, `/tmp/wickwarden-checkpoint-ownership-review.txt`. Room migration commits each contain one scene in the named batch; repaired raft waiver is isolated to F3 `tests/area_base.gd`.
- **Shared tree:** no uncommitted tracked code or room edits at verification. Preexisting staged art deletions/replacements and untracked art, handover brief and UID files remain protected. Do not reset, stash, clean, bulk-add or sweep these into commits.
- **Workflow:** owner replaced Haiku with ATF Codex **GPT-6.1 Sol low** for coding and authorized parallel agents. Root only orchestrates. Final integration explicitly owns only `docs/state.md`, `docs/handoff.md` and verified personal-account pushes. Continuous push authorization applies after green gates.
- **Current work:** art coordinator continues generation at six image jobs. Earlier code jobs and the former integration assignment are finished/cancelled; no stale active job table is retained. Do not wait for all art to finish before checkpointing. Art progress files are production records, not proof of runtime integration.

### Wave status

| Wave | State | Notes |
|---|---|---|
| 0 foundation | Delivered | F0–F14, G1, D1–D3; subsequent compiler/API fixes integrated. |
| 1 props, tools, regular monsters | Delivered with deviation | T03 remains a fixed-lane raft; free steering is pending. P15 runtime watcher regression and pocket entry pass. |
| 2 Brackwater R1 | Room batches landed | Regional acceptance/route tests remain. |
| 2 Thornwood R2 | R2.a–d room batches landed | R2.c completed in `ed60cf3`; R2.d `eab67e7`. |
| 2 Tallowfen/Mirrormere R4 | R4.a–f room batches landed | R4.d `e2e551a`, R4.e `25c65b3`; regional acceptance remains. |
| 2 Gravelight R5 | R5.a–b landed | R5.a gate follow-ups `c709196`, `b542a4e`; R5.c/d remain. |
| 2 Cinderflats R3, Hushmarch R6 | Not delivered | Also all minibosses MB1–MB5 and bosses B01–B10 remain. |
| 3 caves C01–C10, ending E1 | Not delivered | Historical dev `cave_1` exists; missing cave 2/5/9 destinations are expected wave-3 work. |
| 4 QA, 5 release | Not delivered | Full wave 2 is not complete. |

Actual built scenes: **55/88 overworld rooms, 11 separate pockets, one historical cave scene**. The compiler checks 66 authored sources; these numbers count different things and should not be substituted for one another.

### Resolved at this checkpoint

- Shared Thorn Gate flag (`9de34d5`, source consistency `e0363f9`); paired lake moorings, water gates and leech shallows (`96c9afb`, `0636747`); ledge landing and compiler directional ledges.
- Compiler linked door blockers, permanent grate fetch validation and concealed entrances (`f237631`, `7007af0`, `de6d667`). Eight scene metadata refreshes `e7bc25d` through `8cd0621` and strict raft waiver removal `90c7c0a` are coherent; `rooms-check` is green.
- R2.c eye-switch portcullis, thorn hut and permanent grated key challenge (`ed60cf3`); spawn/source cleanup (`e0363f9`). Earlier live-tree `ow_3_5` graph failure no longer reproduces in the integrated graph suite.
- Orchard/hedgerow layout review (`1fb01dc`), title viewport activation (`e10700f`), watcher projectiles counted by ward plate (`ce8b07b`, `8e70395`: three actual blocks and pocket entry), wickling synchronization (`7798025`, worker reported 64 deterministic seeds).

### Visual evidence

Workers captured and opened their room/runtime images under `/tmp`. Integration additionally opened `/tmp/r2c_eyegate_final.png` (clear central approach, eye placeholder and east portcullis opening), `/tmp/ward-runtime-open.png` (ward active and unobstructed stone pocket doorway), and `/tmp/wickwarden-migration-ow_7_3.png` (pond banks, reed islands, mooring placeholders and water exit lanes). Placeholder props remain visibly simple; screenshots do not replace mechanical gate tests. Other worker captures include `/tmp/r2c_grate_closed.png`, `/tmp/r2c_grate_fetched.png`, `/tmp/r2c_hermit_final.png`, `/tmp/r2c_lane_final.png`, `/tmp/f13-new-world.png`, `/tmp/f13-continue-world.png`, `/tmp/ow_4_0-after.png`, `/tmp/ow_2_4-after.png`, `/tmp/r5a-final-ow_8_5.png` and `/tmp/wickwarden-priority-ow_6_3.png`.

### Remaining work and owner decisions

1. Finish remaining wave-2 regions/batches, region area/route tests, minibosses and bosses, then the cave pilot and wave 3. Preserve hidden entrances and tool requirements; do not make every cave entrance obvious.
2. Free-steering raft remains unbuilt (needed by Tidewick); existing raft is fixed-lane. Human playthrough/feel approval remains open.
3. Binding conflict: `ow_1_5#cache` is separate in graph/runtime but described in place in world-plan table 7.1.1. Owner decision required before normative edits. Exit corridor depth wording versus compiler `EXIT_DEPTH=3` also remains open.
4. Sling damage is settled by decision 43: **1**, despite stale interface tables saying 2; do not reopen the settled number. Watcher-eye stun length and mirror-shade decoy remain owner questions.
5. Presentation gaps remain: bridge/boardwalk art, bush-cluster cut-screen look, stone steps/cracked-wall nook and standing lamp. Art sheet quality/culling, manifest integration and in-play approval are pending.
6. Untracked UID files and the untracked room-batch brief predate this checkpoint or import; they are not silently committed by integration.

### Art checkpoint

At `a1cf76d`, **1,306 committed source PNGs** are all named in **95 committed source logs**. Eighteen committed filenames lack committed provenance rows: `fx_dust_puff_v1..3`, `fx_ember_sparks_v1..3`, `fx_fire_big_v1..3`, `fx_fire_small_v1..3`, `fx_smoke_column_v1..3`, `fx_smoke_puff_v1..3` (all `.png`). The coordinator has been notified; provenance/progress edits are underway. Count committed files again after art commits. Historical `PROGRESS.md` is stale; consult range progress and logs. Generation continues, with no requirement to finish all images for this checkpoint.

### Next checkpoint procedure

Review any commits after the verified HEAD: art/log/progress-only changes preserve this code gate; code or room changes require the relevant checks again. Commit only state/handoff with explicit paths, use the personal-account push command below without printing credentials, verify local HEAD against origin, then record the push outcome in a follow-up docs commit and push it. Every push's handoff names the actual pre-push checkpoint, never an impossible self-reference.

---

## 1. What the project is

- **Wickwarden** is a top-down action-adventure in **Godot 4.7** (GDScript).
- It is a mechanics-only homage to *Zelda 1* and *A Link to the Past*. Story, names and art are original. Do not copy another game's characters, names or art.
- Player: **Tamsin**. Tools: lamp hook, charge flare, ward, sub-items. Enemies: the **Hush**.
- Art is **hi-fi painterly GPT Image** (generated through Codex). Never an 8-bit or 16-bit look. No pixel art, no outlines on every shape, no text in images.
- **Step 1** (dev world, 7 rooms) and **step 2** (art pass) are done.
- **The world build** (the full game: 192 rooms including caves, 33 pockets, 10 caves, 10 bosses, 5 miniboss pairs, 8 tools) is being built now, by work packages (WPs).
- **Repo:** `/home/mikael/code/github/wickwarden`. Remote `origin` is `https://github.com/mikaelliljedahl/wickwarden.git`.
- **Account:** the repo is **private** on the **personal** account `mikaelliljedahl`, not the Auxality account. Do not use the Auxality account for this repo.
- **Push command** (delegated integration worker only, on lead instruction under owner authorization, see section 7):

  ```
  GH_TOKEN=$(gh auth token --user mikaelliljedahl) git push origin main
  ```

- **No AI attribution** in commits, PRs, code or docs. No `Co-authored-by` lines, no "generated with" lines.

## 2. Reading order

Index: [README.md](README.md). Where two documents differ, a binding document wins, and `decisions.md` wins over every plan.

Read in this order:

1. [state.md](state.md): where the project stands (may be stale; check section "Status" of this file and `git log`).
2. [decisions.md](decisions.md) (**binding**): the owner's decisions of 2026-10-24, numbered 1–44.
3. [world-work-packages.md](world-work-packages.md) (**binding**): sections 3 (rules for every WP), 4 (interface contracts), 5 (wave 0), then the table of the wave you work on. Section 12 has the dependency graph, section 13 the rules for agents.
4. [code-contract.md](code-contract.md) (**binding**): section 1 (rules), section 16 (world build contract: 16.1 scope, 16.2 rules for every world WP, 16.3 interfaces, 16.4 flags, 16.8 file layout).
5. [world-plan.md](world-plan.md) (**binding**): the master plan (rooms, gates, caves, tools). Reference, large (117 KB). Read the section your WP names.
6. [world-graph.json](world-graph.json) (**binding** data): the graph. `data/world_data.json` is generated from it. Never edit the JSON by hand.
7. [monsters-bosses-tools.md](monsters-bosses-tools.md) (**binding**): monsters, minibosses, bosses, tools. Section 7 lists API additions.
8. [asset-contract.md](asset-contract.md) (**binding**): art interface (cells, foot line, strips, manifest, `SpriteVisual`).
9. Guides: [art-brief.md](art-brief.md), [art-inventory.md](art-inventory.md), [art-provenance.md](art-provenance.md), [room-kit.md](room-kit.md) (F6, committed in `e433d40`), [intro-script.md](intro-script.md), [story.md](story.md) (context), [audio-provenance.md](audio-provenance.md).
10. History: [dev-world-plan.md](dev-world-plan.md) (step 1), `screens/`.

Commands (from `Makefile`):

| Command | What it does |
|---|---|
| `make run` | start the game |
| `make dev` | start with all items, 10 pots, 5 keys, F1 hitbox overlay |
| `make import` | rebuild class cache (needed after adding or renaming a `class_name`) |
| `make test` | every `tests/test_*.gd`, each in its own headless Godot process. Subset: `make test T="player enemy"` |
| `make lint` | `gdlint scripts tests` (gdtoolkit 4.5.0 via uv) |
| `make format` | `gdformat` (not in `check`) |
| `make check` | import + test + lint + world-check + world-gen-test. **The gate.** |
| `make world-data` | regenerate `data/world_data.json` |
| `make world-check` | fail if the committed data differs from the graph |
| `make world-gen-test` | unit tests of the generator |
| `make art` / `make art-test` | cut `tools/source_art/` sheets into `assets/sprites/` / test the cut tool |
| `make audio` | synthesise sounds (`tools/make_audio.py`) |
| `make rooms`, `make rooms-check` | Wired to `tools/build_rooms.py`; compile only explicitly owned room ids during concurrent work. |
| `make capture-all`, `make playthrough` | Still pending QA work; these targets fail until implemented. |

Other checkers (not in `make check`):
- `python3 tools/check_ownership.py --global`
- `python3 tools/check_world_graph.py --stats --rounds --orders`
- `python3 -m unittest tools/test_check_ownership.py`

## 3. The orchestration workflow

The lead (you) delegates and does as little as possible. Each WP is done by one agent. The lead delegates verification to an integration worker.

**Model rule (owner takeover, 2026-10-25):** all coding is delegated through ATF to Codex **GPT-6.1 Sol at low effort**. The root lead only orchestrates; workers execute verification and edits. This replaces the earlier Haiku/Sonnet workflow. Model labels in the binding WP plan remain historical assignments; do not edit normative documents to match this workflow instruction.

**Per-WP flow:**

1. Pick a WP whose `Depends` are merged (committed on `main`) and whose files do not overlap with running WPs.
2. Start one agent with the brief of section 4.
3. The agent works in small steps. After each step it runs `make test T="<own suites>"`.
4. The agent commits only its own paths (`git add <paths>`, never `git add -A`). It reports.
5. The integration worker verifies on the lead’s instruction:
   - `git log --oneline | head` shows the commit, and `git show --stat <hash>` shows only the WP's Owns files.
   - `python3 tools/check_ownership.py <WP>` with the file list on stdin (see below) prints OK.
   - `make check` is green on the new HEAD.
   - The report lists the screenshot check where the WP needs one (`tools/capture.tscn`).
6. If a check fails, the lead sends the agent back, or starts a fix WP with its own Owns list. The lead does not hand-edit agent files without a reason.
7. Update `docs/state.md` when a WP lands (AGENTS rule). Update the status section of this file at every push.

**Ownership check.** The checker reads the changed file list on stdin:

```
(git diff --name-only; git ls-files --others --exclude-standard) | python3 tools/check_ownership.py P01
```

Output: `OK P01: n file(s) inside Owns` or `STRAY <path>` with exit 1. Other modes: `--base REF` (takes changed files from `git diff` against REF; note that it includes other agents' work, so use the stdin form for a single WP), `--global` (whole manifest: no path owned twice in waves 1–5), `--regen` (rebuild room-batch entries from the tables; needed only when the graph changes). The manifest is `tools/wp_ownership.json`.

**Parallel rules.**
- Run in parallel only WPs with disjoint files whose `Depends` are done.
- Waves 1–5: no two WPs own the same file (`--global` checks this).
- Wave 0 is sequential (F7 to F14 touch `world.gd`, `player.gd`, `hud.gd`, `pause_menu.gd`).
- `project.godot` and `Makefile` are shared: serialise the WPs that touch them.

**Git rules for agents and lead.**
- Commit only your own paths: `git add <paths>`. Never `git add -A` or `git add .`.
- Never `git reset`, `git stash`, `git checkout -- <file>`, `git clean` or force-push. Other agents' uncommitted work is in the tree.
- If `git status` shows staged files that are not yours, commit with the paths: `git commit -m "<msg>" -- <your paths>`. Do not unstage others' files.
- Do not push unless explicitly assigned integration push work by the lead (section 7).
- Commit messages: short, imperative, no WP-internal jargon needed. No AI attribution.

**Code rules (from `world-work-packages.md` section 3 and `code-contract.md` 16.2; AGENTS.md is the short form).**
- Read first: AGENTS.md, the contract section, the WP row, the named inputs. Never guess dimensions, paths or interfaces.
- Only write files in your `Owns` list. Anything else is reported, not patched.
- Movement and combat logic in `_physics_process`.
- Damage in half-hearts (int).
- `Layers.*` constants for collision layers, never numbers.
- `load()` with a null check for files another WP delivers. Never `preload()` for those.
- **No `class_name` in new WP files.** Older files keep theirs: `World`, `Placeholder`, `WorldData`, `Hud`, `ItemRegistry`, `PauseMenu`. (`extends "res://path.gd"` is fine.)
- Every entity has a `Visual` child. Game logic never reads from `Visual`.
- Placeholder art only for new entities (`Placeholder.register_kind(...)`). Art comes later.
- Persistence by `GameState` flags (names in code contract 16.4), never by room node state.
- No tutorial text or pop-up instructions in the game world. Button help only in the pause menu. Story text (title, intro, ending) is allowed.
- Tests: `tests/test_*.gd` are auto-discovered by `make test`. Each test file needs its suite to pass alone.
- Verify visually as well as with tests: `tools/capture.tscn` saves a 1920x1080 screenshot.
- A WP that finds a spec problem stops and reports it. It does not change numbers or normative documents.

## 4. How to start agents

Use AgentTeamForge with the Codex backend, **GPT-6.1 Sol**, **low effort**, and the repo working directory. Read the available ATF tool schema for exact model identifiers and fields. Do not start Claude/Haiku jobs: that quota is exhausted. Parallel jobs need disjoint owned paths. The root lead coordinates; delegated workers run shell commands and make changes.

Agents need self-contained briefs, including the current shared-tree and push restrictions.

**Brief template (fill the `<...>` parts):**

```
You are building work package <WP id> of Wickwarden (Godot 4.7, GDScript) in <repo path>.
You are one of several agents in this repo at the same time. Other agents have uncommitted files. Not yours: leave them.

READ FIRST (in this order, skip nothing):
1. AGENTS.md (repo root).
2. docs/world-work-packages.md: section 3 (rules), section 4 (interface contracts), the row of <WP id>, and the rows of its Depends: <Depends list>.
3. docs/code-contract.md: section 1 and section 16 (16.2 rules, 16.3 interfaces, 16.4 flags, 16.8 file layout).
4. docs/decisions.md (binding).
5. <WP-specific inputs: e.g. docs/monsters-bosses-tools.md section X, docs/world-plan.md section Y>.

YOUR FILES: only the paths in your Owns list: <Owns from the WP row and tools/wp_ownership.json>. Write nothing else. If you need a change elsewhere, stop and report it.

RULES: no class_name in new files; load() with null check for files from other WPs; Layers.* for collision; damage in half-hearts (int); every entity has a Visual child; movement in _physics_process; placeholder art only; no tutorial text in the world; no AI attribution anywhere.

GIT: never git add -A, never reset, stash, checkout or clean. Commit only your paths: git add <your paths>, then git commit -m "<message>" -- <your paths>. Do not push. Other agents commit at the same time; if git reports a conflict, stop and report.

WORK IN SMALL STEPS: one behaviour at a time. After each step run: make test T="<your suites>". Fix until green.

CHECK BEFORE YOU COMMIT:
- make test T="<your suites>" passes.
- make lint is clean.
- Ownership: (git diff --name-only; git ls-files --others --exclude-standard) | python3 tools/check_ownership.py <WP id>   must print OK.
- Visual check if the WP row names one: tools/capture.tscn, then look at the image.

FINAL COMMIT MESSAGE: "<short imperative summary>" (no WP jargon needed, no AI attribution).

REPORT (your final message, max 15 lines):
- DONE or FAILED.
- Commit hash.
- Every file touched.
- The exact result lines of make test and make lint.
- Unclear points or spec problems, one line each.
```

**Notes on the brief:**
- Give the WP its exact `Owns` line. Do not give a longer file list than the plan.
- Name the suites: `make test T="world"` works on a subset. Test file names map to `tests/test_<name>.gd`.
- If a worker fails twice on the same step, read its report and split the task into smaller assignments with explicit owned paths.

## 5. Art pipeline

**Documents and folders:**

| What | Where |
|---|---|
| Inventory: 397 rows, 1461 images, 86 batches (section 4 is the batch table B01–B86) | `docs/art-inventory.md` |
| Style, shared prompt blocks, character designs | `docs/art-brief.md` |
| Interface (cells, foot line, strips, manifest, edge strip format) | `docs/asset-contract.md` (binding) |
| Prompt files, one per batch (`batch_NN.md`), each prompt with a job id heading | `tools/art_prompts/` |
| Rules for the prompts and the run recipe | `tools/art_prompts/README.md` |
| Output images | `tools/source_art/` (file names `<sheet>[_<facing>]_vN.png`, N = 1 to 3) |
| Per-batch log (file, session, output id, SHA-256, defects, exact prompt) | `tools/source_art/log_bNN.md` (also `log_terrain.md` etc.) |
| Source provenance table | `docs/art-provenance.md` (every kept image gets a row) |
| Progress | `tools/art_prompts/PROGRESS.md` (producers 1–3) and `PROGRESS_a.md` … `PROGRESS_h.md` (producers a–h, ranges below) |
| Invented design details per producer | `tools/art_prompts/DESIGNS_a.md` … `DESIGNS_h.md` |
| Manifest for `make art` | `tools/art_manifest.json` (only accepted sheets go in) |

**Producers (by batch range):** a 4–11, b 12–19, c 20–27, d 28–35, e 36–47, f 48–59, g 60–71, h 72–86. Each producer works only in its range.

**Recipe (Codex image jobs):**
1. Submit one AgentTeamForge job per image: `backend: "codex"`, `model: "cheapest"` (gpt-6-luna; the image tool is the same at every tier). One image per job.
2. Job text: "Make ONE image call with your native image generation tool. Pass the fenced prompt from the batch file EXACTLY as written, with the reference images listed in the entry attached. Copy the generated PNG only from `~/.codex/generated_images/<your session id>/`. Edit no other file. Run no git. Report output path, size, generated file name, session id, visible defects." Set `expected_outputs` to the absolute PNG path, `timeout_s` 900, a unique `idempotency_key` (the job id; resubmit under a new key, e.g. `<job id>-r1`).
3. Limit: at most **6 Codex jobs per producer** at a time, about 48 in total over 8 producers.
4. Wait with background sleeps (a foreground `sleep` is blocked). A job takes about 3–5 minutes.
5. **Verify every PNG:**
   - Get the job's `session_id` (`get_job` / `list_jobs`).
   - Take the PNG **only** from `~/.codex/generated_images/<session_id>/`. Never take the newest file in the folder: parallel jobs write there and sometimes copy another job's image. Several job reports named another session's file.
   - Compare its SHA-256 with the file in `tools/source_art/` and with all other files there. No duplicates allowed.
   - Look at each image (montage of three variants: `magick a.png b.png c.png -resize 1000x -append out.jpg`).
6. `stop_agent` every job after its wave (`list_jobs` shows `agent_live: true` for open ones). Image jobs cost no Codex weekly quota.
7. Write the log, add provenance rows, commit only `tools/source_art/`, `tools/art_prompts/` and `docs/art-provenance.md`.
8. Do not reject an image by hand without the owner. Weak images are logged; the owner culls. Regenerate at most three times for a sheet that breaks the rules in `tools/art_prompts/README.md` section "Run recipe" item 7.

**Prompt rules (from the README):** forbid pixel art, text, grids and frames, poses that touch, and other games' names. Keep the shared block verbatim. Demand one row of poses, flat key background (magenta or green, never in the subject), `Image size: WxH.` as the last line. Walk cycles say in words which leg leads in which pose.

**Known art weak points (do not repeat them without a fix):**
- **Down and up views** often come out as **side profile** (batches 1–3 `pull_down`, `push_down`; batch 14 up units; batch 15 brine crab front and rear). Fix in later prompts: "her chest and face point at the viewer; her body is square to the camera, not turned to the right" (down); "her back is to the viewer, the braid and coat back visible" (up).
- **Walk cycles repeat poses**: poses 1 and 3 and poses 2 and 4 show the same leg arrangement. Fix: give every pose its own description (pose 1 = contact, leg A forward; pose 2 = passing; pose 3 = contact, leg B forward; pose 4 = passing with the other leg lifted).
- **Build agents cull variants**: the build agents pick one of v1–v3 per row when they use the images. The owner culls too. Do not assume a variant is accepted.
- Textures come back 1254x1254, not 1024x1024. Sheets may come back 2172x724 or 1536x1024. Do not resize by hand; log it.
- **Edge strips** (`edge_*`, decision 34: 384x96 cells, alpha, no foot line): the tool returns about 2.5:1 for a requested 4:1. **The cut tool has no edge-strip kind yet** (`tools/cut_sprites.py` has none). Edges are not cut until that task is done.
- Eight-frame strips (`fx_boss_death_light`, `fx_boss_death_wax`, `fx_rekindle_burst`) and `fx_chime_ring` (512 px cell, 480 px radius) have open cell-size questions (`DESIGNS_e.md`).
- Boardwalk tiles stand on legs or posts: prompt needs "flat on the ground, no legs, no stubs, no posts, nothing under the planks".
- Tallow flask drifts to a heart-shaped vessel (`tallow_flask`, batch 22, all failed); `jar_lit` similar.
- Glint poses come out with weak highlights.
- Batch 24: slag chunk orange glow; thorn hedge magenta spill.

**Art not yet in the game:** batches 1–3 and later art are not in `tools/art_manifest.json` until the owner accepts them. `make art` cuts only what the manifest lists.

## 6. Current working tree (other agents)

At writing, `git status` showed uncommitted work by others. Do not add it, reset it or delete it. Check again before you commit:

- Art prompts and sources for batches written but not committed (see "Art status" above). Batch 61 landed as `ffa8efd`.
- A `docs/art-provenance.md` change may be pending.

Staged files: check `git diff --cached --stat` before any commit. Commit with explicit paths.

## 7. Owner preferences (for the orchestrating lead)

- The owner writes **Swedish**. Replies to him are in **Swedish**, short plain sentences, in the style of **ASD-STE100** (one idea per sentence, simple words, no idioms).
- All **repo documents, code, comments, commit messages and PR texts are in English.**
- The owner wants the lead to **delegate**. The lead does little work itself. Start agents; verify; report.
- Do not ask needless questions. Decide small things yourself, note the choice in the status or in the doc, and go on. Ask only for decisions that the decisions document does not settle, or for pushes and irreversible actions the owner has not asked for.
- **Push policy:** push only when asked, or when the owner says to push continuously. **Currently: push continuously.** After every push, update the "Status (update at every push)" section of this file (date and HEAD) and commit that change too.
- Push command: `GH_TOKEN=$(gh auth token --user mikaelliljedahl) git push origin main`. Only the delegated integration worker pushes when instructed by the lead.
- No AI attribution in commits, PRs or docs.

## 8. Start here (checklist for the new orchestrator)

1. **Orient.** Read this file, then [state.md](state.md). Delegate shell inspection: `git log --oneline | head -20`, `git status` and `git diff --cached --stat`. Note HEAD. Update the status section here if it is out of date.
2. **Read the binding rules.** `decisions.md`, `code-contract.md` section 1 and section 16, `world-work-packages.md` sections 3, 4, 5 and 13. Skim `world-plan.md` and `monsters-bosses-tools.md` only where a WP names them.
3. **Delegate the gate check.** Have the integration worker run `make check` and `python3 tools/check_ownership.py --global`. Both must be green. If not, the first WP is a fix, not new content.
4. **Continue from the checkpoint.** Read current work and remaining batches above. Foundation and wave 1 are delivered; choose remaining wave 2 work with satisfied dependencies and disjoint ownership. Art production continues separately.
5. **Start ATF workers.** Use Codex GPT-6.1 Sol low for coding, with the brief of section 4. Parallel only with disjoint files. The root lead only orchestrates; delegate shell checks and document work too.
6. **Delegate verification of each result.** `git show --stat <hash>`, `python3 tools/check_ownership.py <WP>` with the stdin list, `make check` on HEAD. Fix or send back. Update `docs/state.md` when a WP lands.
7. **Art, when the wave needs it.** Pick the next batch from `docs/art-inventory.md` section 4 whose prompts exist (or write them with the README rules). Run the Codex recipe (section 5). Verify SHA-256, log, provenance, commit only art paths. Stop all jobs after the wave.
8. **Push and update.** The integration worker waits for the lead’s instruction while this shared tree is active. Under the continuous push authorization: `make check` green, push with the command of section 7, update the status section of this file with the date and new HEAD, commit that, and report to the owner in Swedish, short.

---

## Appendix: what the WP numbers mean

- **G, D** — graph and decisions (wave 0, done).
- **F0–F14** — foundation (wave 0). F0 contract, F1 runtime data, F2 World runtime, F3 graph test, F4 keys/pickups, F5 wallet/pots/slugs, F6 room kit, F7 player motion API, F8 ledges, F9 shops, F10 item subscreen, F11 minimap, F12 saves, F13 title, F14 intro.
- **P01–P15** — props (wave 1). **T01–T08** — tools (wave 1). **M0–M5** — boss base and regular monsters (wave 1).
- **R1–R6** — regions (wave 2; batches of rooms, Haiku; a Sonnet lead per region). **MB1–MB5** — minibosses (wave 2). **B01–B10** — bosses (wave 2).
- **C01–C10** — caves (wave 3, batches). **E1** — ending (wave 3).
- **Q1–Q9** — integration and QA (wave 4). **Z1–Z3** — fix rounds, tuning, release candidate (wave 5).
- Batch ids for rooms: `ow_<x>_<y>` overworld, `cave_<n>_<k>` caves, `#pocket` suffix for pockets.

## Open art points from producers (added by the previous lead)

- **Edge strips:** the image tool returns about 2.5:1 (for example 1983x793 or 2048x768) where docs/asset-contract.md asks for 4:1 (1536x384). The cut tool needs a rule for this before `edge_*` files can be cut: either crop and scale to the contract size, or order again. `edge_cave_floor_to_wall_v2` and `edge_cave_water_v2` failed (band too low, magenta above).
- **Sizes:** every 1024x1024 request returned 1254x1254. The cut tool must scale with one factor. Sheets of 1536x1024 return as requested.
- **Weak groups that need new prompts** (details in tools/art_prompts/PROGRESS_*.md and tools/source_art/log_bNN.md): brine crab front and rear views (side profile), choirling (too mossy; try `hush_skitterwick.png` as reference), mirror shade (coloured Tamsin instead of silhouette), many walk cycles that repeat poses 1=3 and 2=4, `wax_seal` (drips read as blood), `dry_vine_screen` and `bush_cluster` (cut would count wrong blobs), `pocket_plain_door` (too ornate), `pocket_lighthouse_door` (square base).
- **Producers:** Claude-side producers a-h ran on the previous lead's account. b (12-19) and d (28-35) finished. Check PROGRESS_a, _c, _e, _f, _g, _h for the rest. Producers e (36-47) and g (60-71) were still working when the lead stopped. Resume missing ranges through ATF under the current takeover workflow (see the art section above).
- Build agents choose the best variant (v1-v3) when they use an image; the owner does not cull.
