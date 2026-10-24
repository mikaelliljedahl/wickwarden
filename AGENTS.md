# Wickwarden — agent input

Wickwarden is a top-down action-adventure in Godot 4.7 (GDScript): lamp hook, sub-items, flip-screen
rooms and the Hush (regular monsters, minibosses and bosses). It shares mechanics with classic top-down
adventures; story, names and art are original. The dev world (step 1) and its painterly GPT Image art (step 2)
are done. The full game (the world build) is planned in `docs/world-plan.md`, split into work packages in
`docs/world-work-packages.md`, and contracted in `docs/code-contract.md` section 16. Current status: `docs/state.md`.
Index of all documents: `docs/README.md`.
The documents marked **Binding** in the table are normative. Other documents guide the work.

| File | Contents | Status |
|---|---|---|
| [docs/state.md](docs/state.md) | Current status: what is done, what is running, open points and next steps. Read it first. | Living status; update it when a step or work package lands |
| [docs/handoff.md](docs/handoff.md) | Orchestrator handoff: workflow, how to start agents, art pipeline, owner preferences, status and a start checklist. | Living status; update it at every push |
| [docs/decisions.md](docs/decisions.md) | The owner's decisions of 2026-10-24. They win over the plans where they differ. | **Binding** |
| [docs/code-contract.md](docs/code-contract.md) | File ownership, APIs, collision layers, tests; section 16 is the world build contract. | **Binding** |
| [docs/asset-contract.md](docs/asset-contract.md) | Art interface: cells, foot line, strips, manifest, `SpriteVisual`. | **Binding** |
| [docs/monsters-bosses-tools.md](docs/monsters-bosses-tools.md) | Regular monsters, minibosses, bosses and the eight tools. Section 7 lists the code contract additions. | **Binding** |
| [docs/world-plan.md](docs/world-plan.md) | World build: rooms, gates, caves, tools (master plan). | **Binding** |
| [docs/world-work-packages.md](docs/world-work-packages.md) | World build: work packages, owners, waves, interface contracts. | **Binding** |
| [docs/world-graph.json](docs/world-graph.json) | The machine-readable world graph. The source of `data/world_data.json`, which is generated; never edit that file by hand. | **Binding** (data) |
| [docs/dev-world-plan.md](docs/dev-world-plan.md) | Step-1 plan (dev world), done and historical. Its numbers still stand where the dev rooms cite them. | Historical; the current plan is `world-plan.md` |
| [docs/art-brief.md](docs/art-brief.md) | Art style, shared prompt blocks and one prompt per source sheet. | Guide; `asset-contract.md` wins on conflict |
| [docs/art-inventory.md](docs/art-inventory.md) | The full list of art the game needs, with sizes, frames and the 86 generation batches. | Guide; `decisions.md` and `asset-contract.md` win |
| [docs/art-provenance.md](docs/art-provenance.md) | Origin of every source image. | Record; update it with every new image |
| [docs/audio-provenance.md](docs/audio-provenance.md) | How the sounds and music are made (synthesised by `tools/make_audio.py`, no samples). | Record |
| [docs/intro-script.md](docs/intro-script.md) | The intro text: six stills with lines and hold times. | Guide (content) |
| [docs/story.md](docs/story.md) | Story sketch: premise, characters and the lanterns. | Context only |
| [docs/screens/](docs/screens/) | Screenshots of step 1 (`step1/`) and step 2 (`step2/`). | Record |
| [docs/README.md](docs/README.md) | Index of every document in `docs/`, grouped. | Index |

## Commands
- `make run` starts the game. `make import` rebuilds the class cache. `make test` runs every
  `tests/test_*.gd` headless (`make test T="player enemy"` for a subset). `make lint` runs gdlint.
  `make check` = import + test + lint + world-check + world-gen-test. `make format` runs gdformat. `make art` cuts
  `tools/source_art/` into `assets/sprites/`; `make art-test` tests the cut tool.
- World build: `make world-data` regenerates `data/world_data.json` from `docs/world-graph.json`;
  `make world-check` fails when the committed file differs; `make world-gen-test` tests the generator.
- Not built yet: `make rooms`, `make rooms-check`, `make capture-all` and `make playthrough` print a message and
  fail until their work packages (F6, Q3, Q4) land. `make rooms` will compile `tools/rooms/*.room` into
  `scenes/world/rooms/`; `make capture-all` will capture every room.

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
