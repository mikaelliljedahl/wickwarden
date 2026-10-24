# Batch 52 generation log (producer f)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job; batches 48 to 52 were run by an earlier f producer, see below). Each PNG was checked by SHA-256 against the PNG in its own `~/.codex/generated_images/<session>/` folder (match in every case) and against all other `tools/source_art/` files (no duplicate).

Batch 52: npc_keeper (down), npc_villager_a (down, up, side).

Defects not fixed (kept for the owner's cull): npc_keeper and npc_villager_a down/up/side: montage check. villager_a_up_v3 (job b52_npc_villager_a_up_v3, 1536x1024, eight separated back-facing poses, no defects). Leg arrangements in walk rows show some repetition (not fixed).

Prompt entries: `tools/art_prompts/batch_52.md`, job id heading per image; the fenced prompt of each entry was passed unchanged. Reference images as named in each entry.

## Files

| File | Size | Reference | Codex session | Output ID | SHA-256 (first 16) | Job id |
|---|---|---|---|---|---|---|
| `npc_keeper_down_v1.png` | 1536x1024 | see entry | `01a16f82-9af5-7131-803c-7af11ea7ecc7` | `exec-a5eba268-baba-439e-b118-547be3fd18b6` | `ec925c6640df896e` | `b52_npc_keeper_down_v1` |
| `npc_keeper_down_v2.png` | 1536x1024 | see entry | `01a16f84-794b-77b2-80b9-03525e672302` | `exec-18aefebe-e1ed-41ba-b9e1-8fd48c60d37e` | `604614130e2fa6c4` | `b52_npc_keeper_down_v2` |
| `npc_keeper_down_v3.png` | 1536x1024 | see entry | `01a16f82-9b00-7670-a996-d6f756afc8f6` | `exec-617a756f-ea0c-4304-af01-8f07750dbc6b` | `68156da745c60f19` | `b52_npc_keeper_down_v3` |
| `npc_villager_a_down_v1.png` | 1536x1024 | see entry | `01a16f84-37ec-7981-851f-a430e0fc73fb` | `exec-1614818f-34fa-4064-8492-b3fb7f788ff7` | `691bb2d60d0ebbef` | `b52_npc_villager_a_down_v1` |
| `npc_villager_a_down_v2.png` | 1536x1024 | see entry | `01a16f84-373c-7703-a145-68d866daf3fd` | `exec-4d87f906-f34c-4f66-9cb8-2718ca619382` | `05b852a0291b77d9` | `b52_npc_villager_a_down_v2` |
| `npc_villager_a_down_v3.png` | 1536x1024 | see entry | `01a16f84-3776-7f80-a9df-df25804cfa3a` | `exec-7224a6fd-4f57-4872-91ea-71a5155f794e` | `665b5723a1f6ec28` | `b52_npc_villager_a_down_v3` |
| `npc_villager_a_up_v1.png` | 1536x1024 | see entry | `01a16f84-37ca-7201-b78f-c46763d7f833` | `exec-eb87b99a-b1a2-43e6-93ea-a868fd72232b` | `4bd0a000fecd4e15` | `b52_npc_villager_a_up_v1` |
| `npc_villager_a_up_v2.png` | 1536x1024 | see entry | `01a16f84-390f-75a0-a717-fbbb02f44acb` | `exec-bc6bb393-c50d-43f7-a90f-3db7be585d18` | `a43070af054aacbe` | `b52_npc_villager_a_up_v2` |
| `npc_villager_a_up_v3.png` | 1536x1024 | see entry | `01a16f95-fb16-71d1-abbe-5a2eb733016a` | `exec-9881d48c-82d0-4b20-a637-92bb2df5f007` | `274e839f6d4b7a8c` | `b52_npc_villager_a_up_v3` |
| `npc_villager_a_side_v1.png` | 1536x1024 | see entry | `01a16f85-b75d-7f81-a5dc-c3fd81e15a14` | `exec-6fc2f2c9-7120-441b-a021-f47f9897ee53` | `4ae617ba7006a6b1` | `b52_npc_villager_a_side_v1` |
| `npc_villager_a_side_v2.png` | 1536x1024 | see entry | `01a16f85-b850-7000-b517-6975f89393bf` | `exec-12dac45c-d8b2-49d2-ab0f-7fe0c2ba587f` | `191b935051e1dfe3` | `b52_npc_villager_a_side_v2` |
| `npc_villager_a_side_v3.png` | 1536x1024 | see entry | `01a16f85-b6e9-79b0-95ef-8f2e21691a99` | `exec-3d5f7099-dac4-4b8a-96b6-c10f3fe19574` | `cac124fde2581d85` | `b52_npc_villager_a_side_v3` |

Rejected attempts: none recorded in this log (earlier-run rejects, if any, are in the local Codex folders only).
