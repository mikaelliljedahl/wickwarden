# Brief for a Wickwarden build worker

You build ONE work package (WP) of Wickwarden, a Godot 4.7 GDScript game, in the git repo
/home/mikael/code/github/wickwarden (branch main). Several agents work in this repo at the same time and
have uncommitted files there. Those files are not yours: leave them alone.

## READ FIRST (in this order; skip nothing)
1. AGENTS.md (repo root): the absolute work rules.
2. docs/world-work-packages.md: section 3 (rules for every WP), section 4 (interface contracts), the section
   that holds your WP (section 5 for F-WPs, section 6 for P/T/M-WPs), and the row of your WP: it names the
   Depends, the Owns, the deliverable and the test. Section 6 says which spec document holds your stats.
3. docs/code-contract.md: section 1 and section 16 (16.2 rules, 16.3 interfaces, 16.4 flags, 16.8 file layout).
4. docs/decisions.md (binding; it wins over every plan where they differ).
5. The spec document your WP names (for example docs/monsters-bosses-tools.md or docs/world-plan.md).
   Read only the sections your WP needs.
6. The Depends of your WP are already merged on main. Read the scripts you call. Do not guess an interface.

## YOUR FILES
Only the paths of your WP's Owns list: the "owns" entry for your WP in tools/wp_ownership.json, plus the
standard files that section 6 of world-work-packages.md names (if your WP has them). Write nothing else.
If you need a change in a file you do not own, stop and report it in your final message. Do not patch it.

## RULES
- No `class_name` in new WP files (`extends "res://path.gd"` is fine).
- `load()` with a null check for files another WP delivers. Never `preload()` for those.
- Collision layers only through `Layers.*` constants, never numbers.
- Damage is in half-hearts (int).
- Movement and combat logic in `_physics_process`.
- Every entity has a `Visual` child. Game logic never reads from `Visual`.
- Placeholder art only for new entities (`Placeholder.register_kind(...)`).
- No tutorial text and no pop-up instructions in the game world. Button help lives only in the pause menu.
  Story text (title, intro, ending) is allowed.
- Do not edit normative documents (docs/*.md marked Binding, AGENTS.md, decisions.md). Do not change numbers.
- If the spec is wrong or two documents disagree, stop and report it. Do not decide it yourself.
- No AI attribution anywhere: no Co-Authored-By lines, no "Generated with" lines, in code, comments, commits.
- Code and comments in English.

## WORK IN SMALL STEPS
One behaviour at a time. After each step run `make test T="<your test name>"`, where the name is the part
of tests/test_<name>.gd (for example `make test T="burnable"`; several names separated by spaces).
Fix until green. A new test file must pass on its own.

## BEFORE YOU COMMIT
- `make test T="<your test names>"` passes.
- `make lint` is clean.
- Visual check if your WP names one: run the capture tool with your gallery fixture from section 6 of
  world-work-packages.md (`godot --path . res://tools/capture.tscn -- --fixture=res://tests/fixtures/gallery/<WP>.tscn --out=<png>`;
  check tools/capture.gd for the exact arguments), then open the PNG with the read tool and describe what you see
  in your report. Keep the PNG out of git (write it under /tmp).
- Ownership: `printf '%s\n' <each path you changed or created> | python3 tools/check_ownership.py <WP>` must print OK.
  Pass only your own paths.

## GIT
- Never `git add -A`, `git add .`, `git reset`, `git stash`, `git checkout -- <file>`, `git clean`, or any push.
- Commit only your own paths: `git add <your paths>`, then `git commit -m "<message>" -- <your paths>`.
- Use a short imperative commit message in English, no WP id needed, no AI attribution.
- If git reports a conflict or a staged file that is not yours, stop and report it.
- Commit once when the WP is done and green (more commits are fine if each is green and only your paths).

## FINAL REPORT (your last message, max 15 lines)
- DONE or FAILED.
- Commit hash(es).
- Every file you created or changed.
- The last result line of `make test` and of `make lint`.
- The visual check: one sentence on what the picture shows.
- Unclear points or spec problems, one line each.

## EXTRA RULE (added by the lead)
- Never run `make format`, `gdformat`, or any command that rewrites files outside your Owns list. Formatting
  only your own new files with `gdformat <your file>` is allowed. Other agents' files stay as they are.
