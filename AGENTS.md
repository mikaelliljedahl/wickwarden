# Wickwarden — agent input

Wickwarden is a top-down action-adventure in Godot 4.7 (GDScript): lamp hook, sub-items, flip-screen
rooms and the Hush (regular monsters, minibosses and bosses). It shares mechanics with classic top-down
adventures; story, names and art are original. The dev world (step 1) has painterly GPT Image art (step 2).
The full game (the world build) is planned in `docs/world-plan.md` and split into work packages in
`docs/world-work-packages.md`; `docs/code-contract.md` section 16 is its contract.
The normative documents in `docs/` are binding; other documents guide the work.

| File | Contents |
|---|---|
| [docs/dev-world-plan.md](docs/dev-world-plan.md) | Step-1 plan: all numbers, controls, entity specs, work packages WP0-WP7. Binding. |
| [docs/code-contract.md](docs/code-contract.md) | File ownership per WP, APIs, collision layers, tests, worked example; section 16 is the world build. Binding. |
| [docs/world-plan.md](docs/world-plan.md) | World build: rooms, gates, caves, tools (master plan). Binding. |
| [docs/world-work-packages.md](docs/world-work-packages.md) | World build: work packages, owners, waves, interface contracts. Binding. |
| [docs/monsters-bosses-tools.md](docs/monsters-bosses-tools.md) | Regular monsters, minibosses, bosses and the eight tools. Binding. Section 7 lists code contract additions. |
| [docs/decisions.md](docs/decisions.md) | The owner's binding decisions. They win over the plans where they differ. |
| [docs/asset-contract.md](docs/asset-contract.md) | Art interface: cells, foot line, strips, manifest, `SpriteVisual`. Binding. |
| [docs/art-brief.md](docs/art-brief.md) | Art style and one prompt per source sheet. |
| [docs/art-provenance.md](docs/art-provenance.md) | Origin of every source image. Update it with every new image. |
| [docs/story.md](docs/story.md) | Story sketch (context only). |

## Commands
- `make run` starts the game. `make import` rebuilds the class cache. `make test` runs every
  `tests/test_*.gd` headless (`make test T="player enemy"` for a subset). `make lint` runs gdlint.
  `make check` = import + test + lint. `make format` runs gdformat. `make art` cuts `tools/source_art/`
  into `assets/sprites/`; `make art-test` tests the cut tool.
- World build: `make world-data` regenerates `data/world_data.json` from `docs/world-graph.json`;
  `make world-check` fails when the committed file differs. `make rooms` compiles `tools/rooms/*.room`
  into `scenes/world/rooms/`. `make capture-all` captures every room.

## Absolute work rules
- Read the plan and `docs/code-contract.md` before code; never guess dimensions, paths or interfaces.
- Only write to files that `docs/code-contract.md` assigns to your work package. World build: the owner of
  a file is its Owns list in `docs/world-work-packages.md` (checked by `tools/check_ownership.py`); the rules
  of `docs/code-contract.md` section 16.2 apply to every world work package.
- Do not change normative documents or agreed numbers locally; report objections.
- Movement and combat logic goes in `_physics_process`. Damage is in half-hearts (int).
- Collision layers are bitmasks; use `Layers.*`, never layer numbers.
- Use `load()` (null-checked), never `preload()`, for files another WP delivers.
- WP files declare no `class_name`.
- Every entity has a `Visual` child; game logic never reads from it.
- Never put tutorial text or pop-up instructions in the game world. Button help lives only in the pause menu.
- Verify visually as well as with tests (`tools/capture.tscn` saves a screenshot).
- No AI attribution lines in code, commits or pull requests.
