# Wickwarden

A top-down action-adventure in Godot 4.7 (GDScript). You play Tamsin, an apprentice lamplighter who
goes down into the craters where the Nine Lanterns fell. Mechanics follow classic top-down adventures
(flip-screen rooms, a main weapon, sub-items, hidden passages, keys); story and art are original.

Step 1 is a small playable dev world with placeholder art: 3x2 overworld rooms plus a dark cave,
the lamp hook, a ward, two sub-items and five monster types. See [docs/dev-world-plan.md](docs/dev-world-plan.md).

## Run

With Godot 4.7 on `PATH`, from the repo root:

```sh
make run     # play
make import  # rebuild the class cache (after adding class_name scripts)
make test    # headless tests, one Godot process per tests/test_*.gd
make check   # import, test and gdlint
```

## Controls

| Action | Keyboard | Gamepad |
|---|---|---|
| Move | WASD / arrows | left stick / D-pad |
| Lamp hook (hold to charge) | J / Space | A |
| Use item | K | X |
| Ward (hold) | L | RB |
| Change item | I | Y |
| Pause | Esc | Start |

## Layout

`scripts/` code, `scenes/` scenes, `tests/` headless tests, `tools/` test runner and screenshot helper,
`docs/` plan and [code contract](docs/code-contract.md). Licence: see `LICENSE`.
