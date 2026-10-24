# Batch 61 generation log (producer g)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job). Each job copied its PNG to `tools/source_art/`; the copy was checked by SHA-256 against the PNG in the job's own `~/.codex/generated_images/<session>/` folder (the only PNG with the same hash), and hashes are unique across `tools/source_art/`. Prompts: `tools/art_prompts/batch_61.md` (the entry heading is the job id). Verdicts are the producer's own view of each image, not the owner's cull.

## Summary (one line per image)

- `wick_automaton_actions_down_v1.png`: weak - figures face right instead of the viewer; front view not held
- `wick_automaton_actions_down_v2.png`: weak - figures face at an angle, not square to the viewer
- `wick_automaton_actions_down_v3.png`: weak - figures angle three-quarter instead of facing forward
- `wick_automaton_actions_side_v1.png`: ok - three rows read clearly: telegraph glow, flame jet, vent steam; flame jets extend near neighbouring poses
- `wick_automaton_actions_side_v2.png`: ok - three rows read clearly: telegraph glow, flame jet, vent steam; flame reaches near the right edge
- `wick_automaton_actions_side_v3.png`: ok - three rows read clearly (telegraph, flame jet, vent steam); slight three-quarter drift, as v1 and v2
- `wick_automaton_walk_down_v1.png`: weak - front view; poses 1 and 3 look nearly identical in leg stance
- `wick_automaton_walk_down_v2.png`: weak - figures angle right instead of facing the camera; poses 1 and 3 look very similar
- `wick_automaton_walk_down_v3.png`: weak - front view; poses 2 to 4 repeat the same leg arrangement, the cycle is weak
- `wick_automaton_walk_side_v1.png`: ok - four side-walk poses, gear, window and spout clear, leg stance differs
- `wick_automaton_walk_side_v2.png`: ok - four side-walk poses with distinct leg stances
- `wick_automaton_walk_side_v3.png`: weak - poses 1/3 and 2/4 repeat the same leg arrangement
- `wick_automaton_walk_up_v1.png`: weak - back view; poses 1 and 3 share one leg stance, poses 2 and 4 share the lifted leg
- `wick_automaton_walk_up_v2.png`: weak - back view reads as side-on; poses repeat the same leg stance across the cycle
- `wick_automaton_walk_up_v3.png`: weak - back view; poses 1 and 3 look alike, the walk cycle is weak

## Details

| File | Codex session | Output ID | SHA-256 (first 16) |
|---|---|---|---|
| `wick_automaton_actions_down_v1.png` | `01a16f5c-d2dc-7f82-b308-541fe5ae1885` | `exec-f7894688-f42a-46ee-a95d-56399f06ac3d` | `ed7531de78ad5161` |
| `wick_automaton_actions_down_v2.png` | `01a16f5c-d594-7962-a101-807cdb54fd02` | `exec-9db26137-0019-429e-949b-dfb65d8b8acd` | `36d62832608593b3` |
| `wick_automaton_actions_down_v3.png` | `01a16f5c-dc1f-7fc1-9fce-e51d4d697d49` | `exec-58fe0a6c-44ab-4f98-803f-31ef0c76b43f` | `ad0bb935f3f80f34` |
| `wick_automaton_actions_side_v1.png` | `01a16f5b-bf84-7c53-a3f9-c05546a898cc` | `exec-aff3e102-af89-45d0-8d46-7cc16bde7010` | `66c1123a1aeed796` |
| `wick_automaton_actions_side_v2.png` | `01a16f5b-c6a3-7a02-9beb-0e1caeec1e6f` | `exec-a8ea5feb-69b9-431d-a0aa-723f3fdcef54` | `8f3b0137199e4df1` |
| `wick_automaton_actions_side_v3.png` | `01a16f5c-810f-74c3-a653-92129f35a295` | `exec-833a18af-5c1d-45b9-ba31-098eddf25704` | `ad9d09609c826173` |
| `wick_automaton_walk_down_v1.png` | `01a16f5a-7722-78f0-89fe-e7f90ed6382c` | `exec-e8efbcc1-6f1b-43f2-b5e4-12a09edcc272` | `df6bf39180f449cb` |
| `wick_automaton_walk_down_v2.png` | `01a16f5a-9e91-7ae2-bbd7-37d6d0b94481` | `exec-6cfda41b-eaf3-4912-bbe2-0a65025bcdf0` | `385cb73fa2bdbbfd` |
| `wick_automaton_walk_down_v3.png` | `01a16f5a-a605-7592-b4e8-4fa15da24782` | `exec-d75303e0-d5b7-4749-8c84-51ca481bffd4` | `337a67d9b90e1d9d` |
| `wick_automaton_walk_side_v1.png` | `01a16f55-7a45-7f83-8488-fcf839228926` | `exec-22540cc7-6033-40a2-9610-d45e05b44c31` | `c0eeebb42c3b0f95` |
| `wick_automaton_walk_side_v2.png` | `01a16f55-8178-7133-b715-9ea17e028fe7` | `exec-3df09c42-c72c-4d8d-b1ca-5a00195e922e` | `6376f7f8bd6cd2c7` |
| `wick_automaton_walk_side_v3.png` | `01a16f55-8834-7852-bd0e-9eb6973f6148` | `exec-3b1c6c46-62a1-409b-9ad0-3224cee18792` | `533a677f7b60d4f9` |
| `wick_automaton_walk_up_v1.png` | `01a16f5b-ab6e-7252-b5af-04fdf759f75e` | `exec-2a233520-d0f3-4297-869c-ce93e301e3e5` | `86d47c582f975e5c` |
| `wick_automaton_walk_up_v2.png` | `01a16f5b-b179-7f32-8c8e-b9950cb87047` | `exec-ad6d6caa-2a9f-4b72-b7a0-b75cbeb0673c` | `ef3dc5157f38c59a` |
| `wick_automaton_walk_up_v3.png` | `01a16f5b-b863-74c0-8f22-1278fee7e1a9` | `exec-34af720b-a00c-4cac-8bea-f7eb0ca6932e` | `3fdcc9570d389327` |
