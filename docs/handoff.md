# Wickwarden — orchestrator handoff

Audience: a new orchestrator (a Claude Code session or a human) who takes over the build with no other context.
Language: English. The owner writes Swedish; see section 7 for how to talk to him.

Read this file first, then [state.md](state.md). The rules for agents are in [../AGENTS.md](../AGENTS.md).

---

## Status (update at every push)

- Date: 2026-10-24
- HEAD when this section was written: `04c90ee` (F13). The lead session hit its usage limit here; a new orchestrator should start from this point.
- Repo state: other agents write to the repo at the same time. Uncommitted files exist that are not ours (see section 6).

| Part | State |
|---|---|
| Step 1 (dev world) | Done. Historical. |
| Step 2 (art pass) | Done in code. Owner has not approved it in play. |
| Planning (world plan, WPs, decisions, graph, monster spec, art inventory, intro script) | Done. |
| Wave 0 (foundation) | F0–F13 done. F14 (intro) not started; can start now. Run `make check` first to confirm F13 is green. |
| Wave 1 (parts: P01–P15, T01–T08, M0–M5) | Not started. Gate (F0–F7 merged) is met. Start with the WPs whose Depends are done. |
| Wave 2 (regions R1–R6, MB1–MB5, B01–B10) | Not started. |
| Wave 3 (caves C01–C10, E1 ending) | Not started. |
| Wave 4 (QA Q1–Q9) | Not started. |
| Wave 5 (Z1–Z3) | Not started. |

### Wave 0 detail

| WP | Content | Commit | State |
|---|---|---|---|
| G1 | Graph: ward puzzles, sling ammo rule | `2ea7e6d` (plus `671764e` dark flag) | Done |
| D1 | Decisions written into world plan | `fc9d71c` | Done |
| D2 | Ownership manifest and checker | `c13219b` | Done |
| D3 | Intro script | `49eb6d6` | Done |
| F0 | Code contract section 16 | `b7c900b`, `c936226` | Done |
| F1 | Runtime world data (`data/world_data.json`, `scripts/core/world_data.gd`) | `5495b45` | Done |
| F2 | World runtime: data-driven rooms, streaming | `ba537ac` | Done (`state.md` still says running; stale) |
| F3 | Graph-versus-scenes test, area test base | `5094372` | Done |
| F4 | Scoped keys, big keys, fragments, gated pickups | `cf058bc` | Done |
| F5 | Wallet, pot capacity, bags, slug ammo | `606aae9` | Done |
| F6 | Room kit: `tools/build_rooms.py`, `docs/room-kit.md` | `e433d40` (committed by another agent; 28 unit tests OK) | Done |
| F7 | Player motion and modifier API | `9e394e4` | Done |
| F8 | One-way ledge drops | `92ef136` | Done |
| F9 | Shops | `d512e39` | Done |
| F10 | Item subscreen | `0325e58` | Done |
| F11 | Minimap for 192 rooms | `8b7c0b0` | Done |
| F12 | Save system | `e89353b` | Done |
| F13 | Title screen and new-game flow | `04c90ee` | Done (committed by a pi agent; lead has not re-verified `make check`) |
| F14 | Intro sequence | none | Not started. Can start now (F13, D3 done). |
| Fix-ups | Cave mouth flags `dd9fd08`, shop checkpoint test `ca33a0c`, shop and cache lines in the room kit `5430704`, Makefile and area test `95f21e2` | see log | Done. A job for `GameState.from_dict` may still be open: check `git log`. |

### Art status

| Batches | State |
|---|---|
| 1–7 | Prompts, sources, logs committed. Batches 1–3 have known defects (see section 5). |
| 12–15 | Committed with logs. Many units weak; owner culls. |
| 20–24 | Committed with logs. |
| 25 | Log `log_b25.md` committed. `PROGRESS_c.md` still says "not started" (stale). |
| 28–31 | Committed with logs. |
| 36 | Committed with log. Boardwalk tiles weak. |
| 37 | In progress (producer e). Prompt `batch_37.md` not committed. |
| 60 | Committed with prompts, sources and log (producer g). |
| 72 | Committed with log (producer h). |
| Prompts exist, no log yet | 8, 16–19, 26, 27, 32–35, 38–59, 61–71, 73, 74 (several untracked). Check `tools/source_art/` before a batch. |
| Prompts not written | 9, 10, 11, 75–86 |

Counts at writing: `tools/source_art/` has 517 entries, 485 of them PNG. `docs/art-inventory.md` has 397 rows, 1461 images, 86 batches.

### Last checks (at writing)

- `make check`: green. Import, 30 test files passed (`all 30 test files passed in 5s`), gdlint "no problems found", `data/world_data.json` up to date, `tools/test_gen_world_data.py` 23 tests OK.
- `python3 tools/check_ownership.py --global`: OK. 92 WPs, 53 room batches, 192 rooms and 33 pockets, no path owned twice in waves 1–5.
- `python3 -m unittest tools/test_check_ownership.py`: 23 tests OK.
- `python3 tools/check_world_graph.py --stats --rounds --orders`: exit 0, mutation self-test OK.
- Note: `make check` does not run the graph checker or the ownership tests. Run them too before a push that touches those files.

### Open decisions

None open. `docs/decisions.md` (2026-10-24, decisions 1–42) answers all points of the plan, including the open questions of `world-work-packages.md` section 15 (decisions 14–25). The decision wins over the plan.

Open points that need the owner:
- Human visual approval of step 2 and of art batches 1–3 (play with `make run` and `make dev`).
- Hook swing width (`SWING_ARC_DEG`, `SWING_REACH` in `scripts/player/player.gd`): owner finds it wide.
- Walk cycle reads a little lame. Possible fix: a six-pose cycle or another fps, before a new Codex sheet.
- Edge strip cut tool (see section 5).

### Known stale documents

- `docs/state.md`: says F2 is running, F3–F14 not started, `make check` has 25 test files (now 30), and "Next steps 1. Land F2". Update it when a WP lands (AGENTS rule).
- `tools/art_prompts/PROGRESS.md`: says next batch is 4 and "no prompt file for batch 4 exists". Both false.
- `tools/art_prompts/README.md`: says prompts written are batches 1 to 3 only.
- `tools/art_prompts/PROGRESS_c.md`: batches 25–27 "not started" (25 has a log).
- `tools/art_prompts/PROGRESS_e.md`: batch 37 "in progress" (verify).
- `docs/art-inventory.md` section 5, item 3: says the intro script does not exist (D3 is done).
- `Makefile`: `world-check` runs only the generator check. The graph checker (`tools/check_world_graph.py`) and the ownership tests are not in `make check`. The `rooms` and `rooms-check` targets are still stubs although `tools/build_rooms.py` exists.
- `tools/art_prompts/PROGRESS_f.md`, `PROGRESS_g.md` and `DESIGNS_g.md` do not exist. Producer f keeps its design notes in `DESIGNS_f.md`; producer g in its logs.

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
- **Push command** (only the orchestrator pushes, only when the owner asks or when pushing continuously, see section 7):

  ```
  GH_TOKEN=$(gh auth token --user mikaelliljedahl) git push origin main
  ```

- **No AI attribution** in commits, PRs, code or docs. No `Co-authored-by` lines, no "generated with" lines.

## 2. Reading order

Index: [README.md](README.md). Where two documents differ, a binding document wins, and `decisions.md` wins over every plan.

Read in this order:

1. [state.md](state.md): where the project stands (may be stale; check section "Status" of this file and `git log`).
2. [decisions.md](decisions.md) (**binding**): the owner's decisions of 2026-10-24, numbered 1–42.
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
| `make rooms`, `make rooms-check`, `make capture-all`, `make playthrough` | **Still stubs**: they print "not built yet" and fail. `tools/build_rooms.py` exists (F6), but the Makefile targets are not wired to it. `Makefile` is owned by F1, so wire it in an F1 fix, or in a small WP that names the Makefile in its Owns. `capture-all` needs Q4, `playthrough` needs Q3. |

Other checkers (not in `make check`):
- `python3 tools/check_ownership.py --global`
- `python3 tools/check_world_graph.py --stats --rounds --orders`
- `python3 -m unittest tools/test_check_ownership.py`

## 3. The orchestration workflow

The lead (you) delegates and does as little as possible. Each WP is done by one agent. The lead then verifies.

**Model rule (owner's workflow):** every WP is done by **one Haiku agent at high effort**, in small steps.
Note the conflict: `world-work-packages.md` names **Sonnet** for most foundation WPs (sections 5, 6–10). Default: use Haiku, as the owner asked. If a Haiku run fails twice on the same WP, use Sonnet for that WP and write it in the status. Do not change the plan document to match.

**Per-WP flow:**

1. Pick a WP whose `Depends` are merged (committed on `main`) and whose files do not overlap with running WPs.
2. Start one agent with the brief of section 4.
3. The agent works in small steps. After each step it runs `make test T="<own suites>"`.
4. The agent commits only its own paths (`git add <paths>`, never `git add -A`). It reports.
5. The lead verifies:
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
- Do not push. Only the orchestrator pushes (section 7).
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

Two ways. Use either. Both run the same brief.

**A. Claude Code Agent tool:** `model: haiku`, `effort: high`, `run_in_background: true`, working directory the repo.

**B. AgentTeamForge `submit_job`:** `backend: "pi"`, `model: "anthropic/claude-haiku-5-5"`, `effort: "high"`, `cwd` the repo. This has a separate usage budget. Stop the job after it reports with `stop_agent(job_id)`.

Use the tools' schemas (load them with `ToolSearch` if they are deferred). Agents cannot see this conversation: the brief must be self-contained.

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
- A WP's Haiku agent that fails twice on the same step: stop it, read its report, and split the WP into smaller WPs with the lead's Owns lists.

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

## 7. Owner preferences (for an orchestrating Claude)

- The owner writes **Swedish**. Replies to him are in **Swedish**, short plain sentences, in the style of **ASD-STE100** (one idea per sentence, simple words, no idioms).
- All **repo documents, code, comments, commit messages and PR texts are in English.**
- The owner wants the lead to **delegate**. The lead does little work itself. Start agents; verify; report.
- Do not ask needless questions. Decide small things yourself, note the choice in the status or in the doc, and go on. Ask only for decisions that the decisions document does not settle, or for pushes and irreversible actions the owner has not asked for.
- **Push policy:** push only when asked, or when the owner says to push continuously. **Currently: push continuously.** After every push, update the "Status (update at every push)" section of this file (date and HEAD) and commit that change too.
- Push command: `GH_TOKEN=$(gh auth token --user mikaelliljedahl) git push origin main`. Only the orchestrator pushes. Agents never push.
- No AI attribution in commits, PRs or docs.

## 8. Start here (checklist for the new orchestrator)

1. **Orient.** Read this file, then [state.md](state.md). Run `git log --oneline | head -20`, `git status` and `git diff --cached --stat`. Note HEAD. Update the status section here if it is out of date.
2. **Read the binding rules.** `decisions.md`, `code-contract.md` section 1 and section 16, `world-work-packages.md` sections 3, 4, 5 and 13. Skim `world-plan.md` and `monsters-bosses-tools.md` only where a WP names them.
3. **Check the gate.** Run `make check` and `python3 tools/check_ownership.py --global`. Both must be green. If not, the first WP is a fix, not new content.
4. **Choose the next WPs.** Now: **F12** and **F9** (Depends done), then F13 and F14 in order. Wave 1 may start (gate F0–F7 met); the wave-1 WPs need only the Depends in their rows. Use the dependency column of the WP table; never start a WP before its `Depends` are on `main`.
5. **Start agents.** One Haiku agent per WP (section 3, model rule), with the brief of section 4. Parallel only with disjoint files. Keep the number of agents you run within your usage budget.
6. **Verify each result.** `git show --stat <hash>`, `python3 tools/check_ownership.py <WP>` with the stdin list, `make check` on HEAD. Fix or send back. Update `docs/state.md` when a WP lands.
7. **Art, when the wave needs it.** Pick the next batch from `docs/art-inventory.md` section 4 whose prompts exist (or write them with the README rules). Run the Codex recipe (section 5). Verify SHA-256, log, provenance, commit only art paths. Stop all jobs after the wave.
8. **Push and update.** When the owner says push (or push continuously): `make check` green, push with the command of section 7, update the status section of this file with the date and new HEAD, commit that, and report to the owner in Swedish, short.

---

## Appendix: what the WP numbers mean

- **G, D** — graph and decisions (wave 0, done).
- **F0–F14** — foundation (wave 0). F0 contract, F1 runtime data, F2 World runtime, F3 graph test, F4 keys/pickups, F5 wallet/pots/slugs, F6 room kit, F7 player motion API, F8 ledges, F9 shops, F10 item subscreen, F11 minimap, F12 saves, F13 title, F14 intro.
- **P01–P15** — props (wave 1). **T01–T08** — tools (wave 1). **M0–M5** — boss base and regular monsters (wave 1).
- **R1–R6** — regions (wave 2; batches of rooms, Haiku; a Sonnet lead per region). **MB1–MB5** — minibosses (wave 2). **B01–B10** — bosses (wave 2).
- **C01–C10** — caves (wave 3, batches). **E1** — ending (wave 3).
- **Q1–Q9** — integration and QA (wave 4). **Z1–Z3** — fix rounds, tuning, release candidate (wave 5).
- Batch ids for rooms: `ow_<x>_<y>` overworld, `cave_<n>_<k>` caves, `#pocket` suffix for pockets.
