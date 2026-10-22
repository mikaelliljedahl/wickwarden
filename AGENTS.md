# Wickwarden — agent input

Wickwarden is a top-down action-adventure in Godot 4.7 (GDScript): lamp hook, sub-items, flip-screen
rooms and five monster types. It shares mechanics with classic top-down adventures; story, names and
art are original. Step 1 is a small dev world with placeholder art.
The normative documents in `docs/` are binding; other documents guide the work.

| File | Contents |
|---|---|
| [docs/dev-world-plan.md](docs/dev-world-plan.md) | Step-1 plan: all numbers, controls, entity specs, work packages WP0-WP7. Binding. |
| [docs/code-contract.md](docs/code-contract.md) | File ownership per WP, APIs, collision layers, tests, worked example. Binding. |
| [docs/story.md](docs/story.md) | Story sketch (context only). |

## Commands
- `make run` starts the game. `make import` rebuilds the class cache. `make test` runs every
  `tests/test_*.gd` headless (`make test T="player enemy"` for a subset). `make lint` runs gdlint.
  `make check` = import + test + lint. `make format` runs gdformat.

## Absolute work rules
- Read the plan and `docs/code-contract.md` before code; never guess dimensions, paths or interfaces.
- Only write to files that `docs/code-contract.md` assigns to your work package.
- Do not change normative documents or agreed numbers locally; report objections.
- Movement and combat logic goes in `_physics_process`. Damage is in half-hearts (int).
- Collision layers are bitmasks; use `Layers.*`, never layer numbers.
- Use `load()` (null-checked), never `preload()`, for files another WP delivers.
- WP files declare no `class_name`.
- Every entity has a `Visual` child; game logic never reads from it.
- Never put tutorial text or pop-up instructions in the game world. Button help lives only in the pause menu.
- Verify visually as well as with tests (`tools/capture.tscn` saves a screenshot).
- No AI attribution lines in code, commits or pull requests.
