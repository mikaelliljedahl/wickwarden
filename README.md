# Wickwarden

A top-down action-adventure in Godot 4.7 (GDScript). You play Tamsin, an apprentice lamplighter who
goes down into the craters where the Nine Lanterns fell. Mechanics follow classic top-down adventures
(flip-screen rooms, a main weapon, sub-items, hidden passages, keys); story and art are original.

Step 1 is a small playable dev world with placeholder art: 3x2 overworld rooms plus a dark cave,
the lamp hook, a ward, two sub-items and five monster types. See [docs/dev-world-plan.md](docs/dev-world-plan.md)
and [docs/state.md](docs/state.md) for what is in and what is next.

## Run

With Godot 4.7 on `PATH`, from the repo root:

```sh
make run     # play (the real start: three hearts, no items)
make dev     # dev start: all sub-items, 10 pitch pots, 5 keys; F1 toggles hitbox/hurtbox drawing
make import  # rebuild the class cache (after adding class_name scripts)
make test    # headless tests, one Godot process per tests/test_*.gd (make test T="player enemy" for a subset)
make check   # import, test and gdlint
```

`make dev` is `godot --path . -- --dev-mode`.

## Controls

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | WASD / arrows | left stick / D-pad |
| Lamp hook (hold 0.8 s to charge a flare) | J / Space | A |
| Use item | K | X |
| Ward (hold) | L | RB |
| Change item | I | Y |
| Pause (shows this help in game) | Esc | Start |
| Hitbox overlay (dev mode only) | F1 | - |

## Status

Step 1 (dev world) is complete: seven rooms (`ow_0_0` .. `ow_2_1` and the cave), all five monsters, tether
moth and pitch pot, cracked wall, locked door, brazier gate, HUD, room slides and fades. The route
tether moth -> cave key -> locked door -> pitch pot -> cracked wall -> wick core is covered by
`tests/test_dev_world_route.gd`. Art is placeholder shapes; step 2 is the high-detail art pass.

Screenshots: `docs/screens/step1/` (made with `tools/capture.tscn`, see the code contract, section 15).

## Layout

`scripts/` code, `scenes/` scenes, `tests/` headless tests, `tools/` test runner and screenshot helper,
`docs/` plan, [code contract](docs/code-contract.md) and [state](docs/state.md). Licence: see `LICENSE`.
