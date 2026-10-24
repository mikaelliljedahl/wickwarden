# Wickwarden

A top-down action-adventure in Godot 4.7 (GDScript). You play Tamsin, an apprentice lamplighter who
goes down into the craters where the Nine Lanterns fell. Mechanics follow classic top-down adventures
(flip-screen rooms, a main weapon, sub-items, hidden passages, keys); story and art are original.

The playable dev world (step 1: seven rooms, five monster types, the lamp hook, a ward and two sub-items)
and its painterly art (step 2) are done. The full game is being built from the world plan. See
[docs/state.md](docs/state.md) for where things stand and [docs/README.md](docs/README.md) for every document.

## Run

With Godot 4.7 on `PATH`, from the repo root:

```sh
make run     # play (the real start: three hearts, no items)
make dev     # dev start: all sub-items, 10 pitch pots, 5 keys; F1 toggles hitbox/hurtbox drawing
make import  # rebuild the class cache (after adding class_name scripts)
make test    # headless tests, one Godot process per tests/test_*.gd (make test T="player enemy" for a subset)
make check   # import, test, gdlint and the world data checks
```

`make dev` is `godot --path . -- --dev-mode`.

## Controls

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | WASD / arrows | left stick / D-pad |
| Lamp hook (hold 0.8 s to charge a flare) | Space / J | A |
| Use item | E / K | X |
| Ward (hold) | Shift / L | RB |
| Change item | Q / I | Y |
| Pause (shows this help in game) | Esc | Start |
| Hitbox overlay (dev mode only) | F1 | - |

## Status (2026-10-24)

- **Step 1, the dev world: done.** Seven rooms (`ow_0_0` .. `ow_2_1` and the cave), all five monsters, tether
  moth and pitch pot, cracked wall, locked door, brazier gate, HUD, room slides and fades. The route
  tether moth -> cave key -> locked door -> pitch pot -> cracked wall -> wick core is covered by
  `tests/test_dev_world_route.gd`. The step-1 plan is [docs/dev-world-plan.md](docs/dev-world-plan.md) (historical).
- **Step 2, the art pass: done.** Painterly GPT Image art for every entity and room, cut by `make art` (see the
  [asset contract](docs/asset-contract.md), the [art brief](docs/art-brief.md) and the
  [art provenance](docs/art-provenance.md)). The art is original; every source sheet is listed with its origin.
- **Planning of the full game: done.** The [world plan](docs/world-plan.md), the
  [work packages](docs/world-work-packages.md), the [monster, boss and tool spec](docs/monsters-bosses-tools.md),
  the [decisions](docs/decisions.md) and the [art inventory](docs/art-inventory.md).
- **World build: in progress.** Wave 0 has the graph amendments, the decisions in the plan, the ownership checker,
  the intro script, the code contract (section 16) and the runtime world data. The world runtime is being built.
- **Art for the full game: in production.** Batches 1 to 3 are done; batches 4 to 86 are being generated.

Screenshots: `docs/screens/step2/` (step 1 placeholders: `docs/screens/step1/`), made with `tools/capture.tscn`.

## Layout

`scripts/` code, `scenes/` scenes, `tests/` headless tests, `assets/` sprites, audio and shaders, `data/` generated
world data, `tools/` test runner, art cutting and audio synthesis, the world graph checks and the screenshot helper,
`docs/` the plans and contracts (see [docs/README.md](docs/README.md)). Licence: see `LICENSE`.
