# Wickwarden — orchestrator handoff

Audience: a new orchestrator (an agent session or a human) who takes over the build with no other context.
Language: English. The owner writes Swedish; see section 7 for how to talk to him.

Read this file first, then [state.md](state.md). The rules for agents are in [../AGENTS.md](../AGENTS.md).

---

## Status (update at every push)

Observed code snapshot (2026-10-25, committed HEAD `b905d4d4006f1c4bfeac86499b09f2cbbc30e784`): **222/222 scene targets are committed**. The graph contains 192 rooms (88 overworld and 104 cave rooms) plus 33 pockets; three pockets are in-place and 30 have separate scenes. There are 221 `.room` sources because `cave_1` is hand-authored. No target scene is missing at this HEAD. The last globally validated and pushed runtime remains `baffec96f976940cd585ce38dbc590a39f088a91`; the personal `origin/main` record is `0f66f8f9b902a01a8e58fd6a77facd3ebab899c1`. Later code/art commits are unverified as one global snapshot and unpushed. This status refresh ran no tests or gates and made no push.

**Region and cave acceptance:** C04 has a functional GO report. C05 has a final functional GO after regenerated scenes `e6c8b12` and pocket blocker rebind `1829791`. All C06 rooms and pocket scenes are committed; full regional push/bidirectional acceptance remains pending. C08's twelve rooms are built. C09 and C10 outputs now complete the 222-scene inventory, while regional route/composition acceptance is still finishing. C07 scenes are present; its full lead acceptance remains in progress after an ownership-path conflict. E1 ending flow is implemented in `5728847`; paintings/choice sprites landed in `b66ddd3`, and `b905d4d` removes duplicate stands beneath the painted ending lanterns. The full earned-route playthrough has not passed.

Recent encounter cleanup includes Briar/Archivist copy fairness `710c798`, Archivist helper cleanup `d85b759`, Lock Warden clone rebuild `e19ba3c`, and Unlit helper cleanup `e6957bf`. Q7 exposed a Bramble Snapper/Heft Mitts mismatch in `4606df5`; `b4449ed` applies the immunity fix, but Q7 has not been rerun after it. Earlier B06/B07, MB4/MB5, B08–B10, F6 cave/door support and mapper `02fded4` are committed. This does not imply all encounter, art or regional acceptance is complete.

**Integration queue:** Q1 scene-graph solver is committed in `c7bb5bf` and its report passes on the complete 222-scene snapshot. Q2 completeness/layout review is running. A reported combined gate before `b4449ed` had 11 failing suites out of 129, including four cave_9 content defects under Q2; that report said `world-check`, `rooms-check` and global lint passed. The cave_9 defects still need scoped triage. C09's two earlier route reports were separately reproduced as F3 reachability false positives; eight real-Player checks passed. Q4 capture tooling landed in `4a43792`; three real captures and byte-identical repeats passed, but capture/review of all 222 targets remains outstanding. Q2/Q4 in the binding WP table still says 218 scenes/images, while the graph now requires 222; report this discrepancy and leave the plan untouched. Q7's `4606df5` result was 580/582 before `b4449ed` fixed Bramble Snapper immunity to Heft Mitts throws. Rerun Q7 before claiming the matrix green. C07–C10 functional lead tests are in flight. B07 streamed-pit return and F3 moth-over-pit checks, pocket-terrain mapping, overworld composition review and encounter-lifecycle review are also active. Q3 playthrough, Q5 visual review, Q6 soak/economy, Q8 performance/memory and Q9 final QA docs remain open.

**Art and release:** source production is closed at final FX `d2fe1a5` and provenance `2fa8c69`; the mapper integrates 26 keys. Runtime art still has body/transient-tool placeholders, terrain and pickup/shop presentation, mapping/render cleanup and human visual review. No all-art-done claim. Human feel/balance review, full playthrough, full-room review, performance/memory measurement, Z1 fix rounds, tuning and Z3 release/export checks remain outstanding.

Design notes to preserve during review: B10's implementation keeps the literal 330 orbit around `(960, 288)`, including the upper arc leaving the room. This is an implementation note only; no normative number changed and no owner decision is implied. B07 keeps the literal dive toward the player and hit-table recovery. Boots remain a mobility/progression requirement; strict combat necessity is not proven. Do not convert that into a new owner decision.

The previous C02 functional GO (`6bb45ad`) carries its stated controls and art limits. The passing `baffec96` gate does not cover later commits. No `.room` source or compiled room scene was dirty at this inspection, and a worker-reported combined run said `rooms-check` passed before the latest Q1/Q4/Q7 and ending-presentation commits. No stale room outputs are currently identified; the complete exact-SHA gates remain pending. The shared index showed 77 staged paths during final inspection; preserve all staged and unstaged art, provenance, import, UID and implementation work. Graphics checks use `--audio-driver Dummy`. Commit only these two living documents.

The previous verified personal-origin push is `0f66f8f9b902a01a8e58fd6a77facd3ebab899c1`, with tested runtime parent `baffec96f976940cd585ce38dbc590a39f088a91`. Current observed code HEAD `b905d4d` is later and has no global green gate or push. Do not treat historical verification as coverage of current code. Before the next push, select one exact committed snapshot after active writers finish, run the exact-SHA gates, and push only that validated runtime SHA. Record its test results and actual remote hash in a docs-only follow-up.

### All-ten item-menu icon integration

- **Landed:** pipeline `b2e516c` publishes `icon_tether_moth`, `icon_pitch_pot`, `icon_cinder_wick`, `icon_tallow_sling`, `icon_reed_raft`, `icon_heft_mitts`, `icon_glow_jar`, `icon_lantern_chime`, `icon_skitter_boots`, `icon_reel_line` as 128x128 `idle` frames at `assets/sprites/icon_<id>.png`. Existing object sprites are unchanged. Selection/proof/deterministic regeneration evidence: [tool-icon-selection.md](../tools/source_art/tool-icon-selection.md). Pipeline worker `job_01a1739ff3b572b09e40ad5f76ef905f` under coordinator `job_01a1739f19307a5fa41dd847babdb336` selected already-generated B17/B18 variants; no new icon generation was needed.
- **Menu:** `43552ec` prefers the exact dedicated runtime kind, falls back to object-id art and then geometry. All ten found tools are painted; unfound items remain silhouettes. No player tool-use sheet is used. Equipped HUD icons were later added by `d72aec1`.
- **Visual proof opened:** `/tmp/wickwarden-menu-dev-art.png` shows all ten distinct painted tools, a readable equipped label and selection frame. `/tmp/wickwarden-menu-new-art.png` shows all ten dark question-mark silhouettes. Temporary harness `/tmp/wickwarden-menu-capture.gd` instantiates the actual World with new-game/dev state; capture logs have existing exit cleanup warnings (8 ObjectDB instances / 4 resources), with no draw or script errors. Full-size images stay out of git.
- **Current gates:** `make check` passed all 70 Godot suites, lint, generated world-data check and 96 Python tests; `make rooms-check` passed 66/66; global ownership passed 92 WPs / 53 room batches. Logs: `/tmp/wickwarden-menu-final-check.log`, `/tmp/wickwarden-menu-final-rooms.log`, `/tmp/wickwarden-menu-final-ownership.log`. Explicit F10 ownership and diff checks passed. All-ten art, unfound states, object fallback and absent-art fallback are tested.
- **Checked revision:** code checkpoint `43552ec`; later commits through `f33ab9b` contain source art, logs, selection verification, progress and these status documents only. Verify later commits and tracked runtime/code dirt before pushing; unrelated ongoing generation need not finish. `make import` left ten untracked icon `.png.import` files, which remain outside owned commits along with inherited UID files. Preexisting staged source deletions, untracked replacements and shared provenance edits remain protected.

### Wave status

| Wave | State | Notes |
|---|---|---|
| 0 foundation | Delivered | F0–F14, G1, D1–D3; subsequent compiler/API fixes integrated. |
| 1 props, tools, regular monsters | Delivered with deviation | Free-steering raft combat/rider API landed in `3466f30`. P15 runtime watcher regression and pocket entry pass. |
| 2 Brackwater R1 | Room batches landed | Assembled area/route acceptance landed in `1d91efb` and `4e635c0`. |
| 2 Thornwood R2 | R2.a–d room batches landed | Regional acceptance landed in `5c6462f`. |
| 2 Tallowfen/Mirrormere R4 | R4.a–f room batches landed | Regional acceptance landed in `82ae92b`. |
| 2 Gravelight R5 | Room batches and lead acceptance passed at tested snapshot | `baffec96`; spawn fix `7405e80`. Newer tree unverified. |
| 2 Cinderflats R3, Hushmarch R6 | Room batches and lead acceptance passed at tested snapshot | `9d19ed2`, `dc097c3`; newer tree unverified. |
| 3 caves C01–C10, ending E1 | All 222 scene targets are present; E1 flow is implemented | C04/C05 functional GO reports. C06 area-level push acceptance and C07–C10 regional route/composition acceptance remain open. E1 has no full earned-route playthrough yet. |
| 4 QA, 5 release | In progress | Q1 is committed and its solver report passes. Q2 has four cave_9 content defects in a reported 11/129 failing combined gate. Q4 tooling is committed, with three captures reported. Q7 fix `b4449ed` awaits matrix rerun. Q3/Q5/Q6/Q8/Q9 and Z1–Z3 remain open. |

### Resolved at this checkpoint

- Shared Thorn Gate flag (`9de34d5`, source consistency `e0363f9`); paired lake moorings, water gates and leech shallows (`96c9afb`, `0636747`); ledge landing and compiler directional ledges.
- Compiler linked door blockers, permanent grate fetch validation and concealed entrances (`f237631`, `7007af0`, `de6d667`). Eight scene metadata refreshes `e7bc25d` through `8cd0621` and strict raft waiver removal `90c7c0a` are coherent; `rooms-check` is green.
- R2.c eye-switch portcullis, thorn hut and permanent grated key challenge (`ed60cf3`); spawn/source cleanup (`e0363f9`). Earlier live-tree `ow_3_5` graph failure no longer reproduces in the integrated graph suite.
- Orchard/hedgerow layout review (`1fb01dc`), title viewport activation (`e10700f`), watcher projectiles counted by ward plate (`ce8b07b`, `8e70395`: three actual blocks and pocket entry), wickling synchronization (`7798025`, worker reported 64 deterministic seeds).

### Visual evidence

Workers captured and opened their room/runtime images under `/tmp`. Integration additionally opened `/tmp/r2c_eyegate_final.png` (clear central approach, eye placeholder and east portcullis opening), `/tmp/ward-runtime-open.png` (ward active and unobstructed stone pocket doorway), and `/tmp/wickwarden-migration-ow_7_3.png` (pond banks, reed islands, mooring placeholders and water exit lanes). Placeholder props remain visibly simple; screenshots do not replace mechanical gate tests. Additional worker-reviewed evidence: `/tmp/ow_4_0-repaired-occlusion-probe.png` shows the player fully visible at tile 10,6; `/tmp/ow_2_4-after.png` shows the dry tile 8/9 lane; `/tmp/gated-ow_7_3.png` and `/tmp/gated-ow_1_5.png` retain the player outside closed secret gates; `/tmp/f10-new-menu.png` and `/tmp/f10-dev-glow-equipped.png` cover item-menu use. Other worker captures include `/tmp/r2c_grate_closed.png`, `/tmp/r2c_grate_fetched.png`, `/tmp/r2c_hermit_final.png`, `/tmp/r2c_lane_final.png`, `/tmp/f13-new-world.png`, `/tmp/f13-continue-world.png`, `/tmp/ow_4_0-after.png`, `/tmp/ow_2_4-after.png`, `/tmp/r5a-final-ow_8_5.png` and `/tmp/wickwarden-priority-ow_6_3.png`.

### Remaining work and owner decisions

1. Finish Q2 completeness/layout and triage its four cave_9 content defects; complete C06 regional push acceptance and C07–C10 route/composition acceptance. C09's two earlier route reports were F3 false positives, not confirmed blocked routes.
2. Rerun Q7 after `b4449ed` changed Bramble Snapper immunity to match matrix row 5.9; do not claim the matrix green until the rerun passes.
3. Complete Q3 earned-route playthrough, Q4 captures for all 222 scene targets, Q5 visual review, Q6 soak/economy, Q7 full matrix and Q8 performance/memory checks. Q2/Q4's binding count of 218 conflicts with the current graph target of 222; raise it without editing the plan locally.
4. Free-steering raft and Tidewick real-raft behavior landed (`3466f30`, `72899cd`, `5e78e1f`); human playthrough/feel and balance approval remain open. The hook swing and walk-cycle timing also need owner play review.
5. Finish body/transient-tool art, terrain and pickup/shop presentation, mapping/render cleanup and human visual review. Source production is closed; runtime art acceptance is not.
6. Binding conflicts still needing owner direction: `ow_1_5#cache` placement and exit corridor depth versus `EXIT_DEPTH=3`. Sling damage is settled by decision 43: **1**. Watcher-eye stun and mirror-shade decoy remain owner questions.

### Art checkpoint

Source production is closed at final FX `d2fe1a5` and provenance checkpoint `2fa8c69`. Mapper `02fded4` integrates 26 keys; C04/C05 encounter/reward art is in `824c596`. Runtime presentation still has body/transient-tool placeholders, terrain and pickup/shop gaps, remaining mapping/render cleanup and visual review. Inherited staged source deletions/replacements, provenance edits and import/UID changes remain protected.

### Next checkpoint procedure

The isolated gate is valid only for `baffec96`. The observed `b905d4d` inventory is not a globally green runtime snapshot. The next checkpoint needs one exact committed SHA after active writers land, `make check`, `make rooms-check`, `make art-test`, global ownership and source/runtime consistency checks. Triage Q2's four cave_9 content defects and rerun Q7 after the snapper immunity fix. Push only that validated SHA under standing authorization; do not include later unverified runtime commits. Record the tested SHA and actual remote hash in a docs-only follow-up. Never include credentials in output.

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
| `make capture-all` | Capture tooling is present and being exercised; complete coverage of the 222 targets and all review sheets remain pending. |
| `make playthrough` | Full earned-route shards and acceptance remain pending (Q3). |

Other checkers (not in `make check`):
- `python3 tools/check_ownership.py --global`
- `python3 tools/check_world_graph.py --stats --rounds --orders`
- `python3 -m unittest tools/test_check_ownership.py`

## 3. The orchestration workflow

The lead (you) delegates and does as little as possible. Each WP is done by one agent. The lead delegates verification to an integration worker.

**Model rule (owner update, 2026-10-25):** use Codex **Luna xhigh** for mechanical tasks to save budget. The root lead orchestrates; workers execute implementation and checks. Model labels in the binding WP plan remain historical assignments; do not edit normative documents to match this workflow instruction.

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

Use AgentTeamForge with the Codex backend and the repo working directory. For mechanical tasks, use **Luna xhigh** per the owner. Read the current ATF tool schema for exact model identifiers and fields. Parallel jobs need disjoint owned paths. The root lead coordinates; delegated workers run shell commands and make changes.

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

At this status refresh, the shared index showed 77 staged paths and active implementation changes outside this worker's ownership. Q1 and Q4 are committed; C07–C10 lead tests, Q2 triage and art/review work continue in parallel. Do not add, reset, stash, clean or rewrite any shared changes. Commit living status with the explicit paths `docs/state.md` and `docs/handoff.md` only. Recheck the index before and after that commit; leave every other staged and unstaged change untouched.

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
4. **Continue from the checkpoint.** Read current work and remaining batches above. Foundation and wave 1 are delivered; choose remaining wave 2 work with satisfied dependencies and disjoint ownership. Source production is closed; runtime art integration continues separately.
5. **Start ATF workers.** Use Codex Luna xhigh for mechanical work, with the brief of section 4. Parallel only with disjoint files. The root lead only orchestrates; delegate shell checks and document work too.
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
- **Producers:** Claude-side producers a-h ran on the previous lead's account. b (12-19) and d (28-35) finished. Check PROGRESS_a, _c, _e, _f, _g, _h for the rest. Those historical producer states are superseded by the closed source coordinator recorded above; do not restart generation from this historical note.
- Build agents choose the best variant (v1-v3) when they use an image; the owner does not cull.
