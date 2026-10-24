# Batch 54 generation log (producer f)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job; batches 48 to 52 were run by an earlier f producer, see below). Each PNG was checked by SHA-256 against the PNG in its own `~/.codex/generated_images/<session>/` folder (match in every case) and against all other `tools/source_art/` files (no duplicate).

Batch 54: hollow_captain walk (side, down, up), actions (down, side).

Defects not fixed (kept for the owner's cull): hollow_captain walk side v1-v3 are 2172x724, not 1536x1024 (generator size); the held guard is drawn as a lantern/cage instead of a round brass guard in every sheet. walk down v1: magenta cuts through cloak edges, lantern guard; v2: caged lantern, magenta holes at cloak edges, little walk variation; v3: poses similar, guard lantern-like. walk up v1: lantern at left side; v2: clean; v3: part of guard peeks out at right side. actions down v1: glossy heavy outline look, magenta holes in cape tears, poses 3-4 overlap capes; v2: lantern guard, pose 2 turned sideways; v3: lantern guard, poses 2-4 angled. actions side v1: lantern cage in all poses; v2: all eight poses present, no defects seen; v3: lantern guard. side v2 (retry -r1 of the first failed job): lantern guard, top-row first two poses lantern-forward. Not fixed.

Prompt entries: `tools/art_prompts/batch_54.md`, job id heading per image; the fenced prompt of each entry was passed unchanged. Reference images as named in each entry.

## Files

| File | Size | Reference | Codex session | Output ID | SHA-256 (first 16) | Job id |
|---|---|---|---|---|---|---|
| `hollow_captain_walk_side_v1.png` | 2172x724 | see entry | `01a16f9f-284f-7831-b8bb-d70bef25eac5` | `exec-93e2827e-7457-4422-95be-d9f8dd4096d3` | `2ca35e5c926c8e73` | `b54_hollow_captain_walk_side_v1` |
| `hollow_captain_walk_side_v2.png` | 2172x724 | see entry | `01a16fa4-4f5d-7e90-a558-eec479285252` | `exec-166df156-132f-46a2-b885-feaeba8f69e1` | `c09e10e848fe3e62` | `b54_hollow_captain_walk_side_v2` |
| `hollow_captain_walk_side_v3.png` | 2172x724 | see entry | `01a16fa3-508d-7322-a642-58ea3867e963` | `exec-e038a636-e800-4777-8ecf-f8c636d904a0` | `49ada1befa7c6e07` | `b54_hollow_captain_walk_side_v3` |
| `hollow_captain_walk_down_v1.png` | 1536x1024 | see entry | `01a16fa3-c384-7201-bf38-ceb2902a378c` | `exec-a7a9f7bd-f75b-410f-9c40-6472a7c8f09a` | `3d2798fe554e9431` | `b54_hollow_captain_walk_down_v1` |
| `hollow_captain_walk_down_v2.png` | 1536x1024 | see entry | `01a16fa4-4008-7142-b773-7001d0f6f271` | `exec-b49cca74-9a8f-435d-9fc6-66225675ec3d` | `41e17fb3e4c8fa79` | `b54_hollow_captain_walk_down_v2` |
| `hollow_captain_walk_down_v3.png` | 1536x1024 | see entry | `01a16fa4-712c-74e3-844f-c7e9955f8dbc` | `exec-51b9d475-abe9-49fc-8552-eac5cd6126f0` | `7eb67ae8997e87fd` | `b54_hollow_captain_walk_down_v3` |
| `hollow_captain_walk_up_v1.png` | 1536x1024 | see entry | `01a16fa4-694f-77a3-b78b-3744f12054ef` | `exec-8f3235bc-bab0-4340-9e07-cc27fc7a8de8` | `7beaac11ec488eee` | `b54_hollow_captain_walk_up_v1` |
| `hollow_captain_walk_up_v2.png` | 1536x1024 | see entry | `01a16fab-84a4-79b2-8823-b783296e5d3c` | `exec-7f651a7f-ed15-437f-9c5b-54afcbe0646f` | `6c0ecc70e134002d` | `b54_hollow_captain_walk_up_v2` |
| `hollow_captain_walk_up_v3.png` | 1536x1024 | see entry | `01a16fab-8666-7f92-b411-550d979f3084` | `exec-20c2465c-3cd6-4c08-8cfa-b5e1962803d1` | `81502b12129426e1` | `b54_hollow_captain_walk_up_v3` |
| `hollow_captain_actions_down_v1.png` | 1536x1024 | see entry | `01a16fa7-8f98-7bc1-a047-51c8d68552c5` | `exec-5df4a6f9-c35d-4735-bf8d-77959fda00d9` | `4564cc8507c48a83` | `b54_hollow_captain_actions_down_v1` |
| `hollow_captain_actions_down_v2.png` | 1536x1024 | see entry | `01a16fa7-8fca-76d0-9fc6-5d1ee27c0711` | `exec-2ee623ce-2174-438f-8e7f-4b85234cfb8b` | `e996a20051ea3095` | `b54_hollow_captain_actions_down_v2` |
| `hollow_captain_actions_down_v3.png` | 1536x1024 | see entry | `01a16fa7-8ea0-7e51-b4fd-2141fd999ae8` | `exec-30192ee7-07c1-4f12-8aa5-b32df9f96c7e` | `66699df21e4894ae` | `b54_hollow_captain_actions_down_v3` |
| `hollow_captain_actions_side_v1.png` | 1536x1024 | see entry | `01a16fa7-8d1b-74a1-97c1-794d94c879ea` | `exec-8692e787-8007-4df9-9a5f-abad68e26e54` | `1b10e4c14c084538` | `b54_hollow_captain_actions_side_v1` |
| `hollow_captain_actions_side_v2.png` | 1536x1024 | see entry | `01a16fab-84d2-76c1-95f4-53f74d74db50` | `exec-50843502-77a1-4580-ae28-ff915d99ebd6` | `d8a3a859805e9737` | `b54_hollow_captain_actions_side_v2` |
| `hollow_captain_actions_side_v3.png` | 1536x1024 | see entry | `01a16fa7-8e7c-75c0-b76d-b3a17e43b2c5` | `exec-aae82758-b5d8-42d8-a937-de31b9a80c37` | `cd33e978adfb420e` | `b54_hollow_captain_actions_side_v3` |

Rejected attempts: none recorded in this log (earlier-run rejects, if any, are in the local Codex folders only).
