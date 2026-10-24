# Batch 51 generation log (producer f)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job; batches 48 to 52 were run by an earlier f producer, see below). Each PNG was checked by SHA-256 against the PNG in its own `~/.codex/generated_images/<session>/` folder (match in every case) and against all other `tools/source_art/` files (no duplicate).

Batch 51: light_jar_glow, npc_tilly, npc_peddler, npc_ashwife, npc_mason, npc_pilgrim (down).

Defects not fixed (kept for the owner's cull): light_jar_glow v2 (1254x1254, subtle background texture) and v3 (1254x1254, painterly background variation). npc_tilly/peddler/ashwife/mason/pilgrim down v1-v3: montage check, eight-figure rows clean, no contact. Sizes 1536x1024 except light_jar_glow (1254x1254).

Prompt entries: `tools/art_prompts/batch_51.md`, job id heading per image; the fenced prompt of each entry was passed unchanged. Reference images as named in each entry.

## Files

| File | Size | Reference | Codex session | Output ID | SHA-256 (first 16) | Job id |
|---|---|---|---|---|---|---|
| `light_jar_glow_v1.png` | 1254x1254 | see entry | `01a16f71-af7b-7213-b810-af93fc71420c` | `exec-da016c8e-6cfb-4902-a706-5059a757a16e` | `76940bb57e62dcfb` | `b51_light_jar_glow_v1` |
| `light_jar_glow_v2.png` | 1254x1254 | see entry | `01a16f95-fbc2-73c1-8feb-5397b8ea3844` | `exec-2e098144-b7eb-4953-bc50-cbd666f09c90` | `1340be74bd307a6d` | `b51_light_jar_glow_v2` |
| `light_jar_glow_v3.png` | 1254x1254 | see entry | `01a16f95-fcf7-7052-b882-c1a01fdbd54a` | `exec-f91295d2-acef-4f3e-b319-f527b90fe603` | `23f02d9cc68acc06` | `b51_light_jar_glow_v3` |
| `npc_tilly_down_v1.png` | 1536x1024 | see entry | `01a16f73-5468-7251-8860-8d32fcc27996` | `exec-fc48d2c9-8e69-4156-a4a7-a7b5aaf94384` | `67bb1895986369be` | `b51_npc_tilly_down_v1` |
| `npc_tilly_down_v2.png` | 1536x1024 | see entry | `01a16f73-4d3c-79c1-932e-a244fff489c5` | `exec-0ffa2898-67aa-4111-9255-51d990269605` | `76e83a30d964cdc3` | `b51_npc_tilly_down_v2` |
| `npc_tilly_down_v3.png` | 1536x1024 | see entry | `01a16f73-56f4-72f3-822e-a4aaa04558cf` | `exec-b8cad5fd-a8b7-445f-ba83-f964c027cd7c` | `562e863cd6f87922` | `b51_npc_tilly_down_v3` |
| `npc_peddler_down_v1.png` | 1536x1024 | see entry | `01a16f78-0a9d-7453-b14b-b9eaacc77763` | `exec-e738f439-68c9-488a-8fca-2b74d08e7af4` | `fefb7ba4a05c8568` | `b51_npc_peddler_down_v1` |
| `npc_peddler_down_v2.png` | 1536x1024 | see entry | `01a16f78-335a-7062-a2f6-a24fcca54acd` | `exec-39cb6ef4-1bbd-4825-93e0-9c38fbf4a1f3` | `25a18c2535abfc69` | `b51_npc_peddler_down_v2` |
| `npc_peddler_down_v3.png` | 1536x1024 | see entry | `01a16f78-3547-7610-aa54-94d32b6eac77` | `exec-e50c67c9-567e-4ed4-9850-f7e8e21f58a9` | `5b6509c7b5c2489b` | `b51_npc_peddler_down_v3` |
| `npc_ashwife_down_v1.png` | 1536x1024 | see entry | `01a16f78-34df-79f2-bdfe-c76e5614535f` | `exec-aff99525-4a08-457b-94fd-f7feb9f46f19` | `c48f366a9c0be06d` | `b51_npc_ashwife_down_v1` |
| `npc_ashwife_down_v2.png` | 1536x1024 | see entry | `01a16f7a-47de-72e2-a6d2-aeff37fe27db` | `exec-a982003a-a690-46fd-8859-4c179285343e` | `e57634e561827669` | `b51_npc_ashwife_down_v2` |
| `npc_ashwife_down_v3.png` | 1536x1024 | see entry | `01a16f78-369a-7721-a654-a4c42ed30e26` | `exec-799d8df3-cc2e-4dfb-a532-df66e91a9938` | `60efb647b4d1a565` | `b51_npc_ashwife_down_v3` |
| `npc_mason_down_v1.png` | 1536x1024 | see entry | `01a16f7a-5578-7662-8193-d616ba6764e0` | `exec-a0979a27-29ef-4933-84f3-1239c02ae26f` | `f07705d2679a590e` | `b51_npc_mason_down_v1` |
| `npc_mason_down_v2.png` | 1536x1024 | see entry | `01a16f7a-6177-76b2-a793-b003609f8916` | `exec-3b87e874-072f-4f2a-996d-1c19177c628b` | `c042dec2adde2e83` | `b51_npc_mason_down_v2` |
| `npc_mason_down_v3.png` | 1536x1024 | see entry | `01a16f7a-614d-74c1-80be-e962fc0ce93c` | `exec-9fbcf97d-20d2-47c7-b96b-71c5fa25fb3d` | `adc15416eaf05c6f` | `b51_npc_mason_down_v3` |
| `npc_pilgrim_down_v1.png` | 1536x1024 | see entry | `01a16f82-9aa8-7e21-af7b-2a741564af3b` | `exec-09be3428-a673-4e3b-a71e-a599e149d152` | `924a00ce12a2bdb4` | `b51_npc_pilgrim_down_v1` |
| `npc_pilgrim_down_v2.png` | 1536x1024 | see entry | `01a16f82-98b8-7303-b977-8241b47ae7d0` | `exec-666b0f39-8e05-44b2-816c-9964eee0ceed` | `aa3b337bc5383139` | `b51_npc_pilgrim_down_v2` |
| `npc_pilgrim_down_v3.png` | 1536x1024 | see entry | `01a16f82-98bc-78b3-a3ed-2db77cb07d8d` | `exec-0bc83124-30d3-4e4f-8f60-10a095829117` | `8f9f56b1793d7898` | `b51_npc_pilgrim_down_v3` |

Rejected attempts: none recorded in this log (earlier-run rejects, if any, are in the local Codex folders only).
