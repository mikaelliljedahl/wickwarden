# Batch 53 generation log (producer f)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job; batches 48 to 52 were run by an earlier f producer, see below). Each PNG was checked by SHA-256 against the PNG in its own `~/.codex/generated_images/<session>/` folder (match in every case) and against all other `tools/source_art/` files (no duplicate).

Batch 53: npc_villager_b (down, up, side), npc_corrow_wax (down), npc_corrow_ghost (down, provisional).

Defects not fixed (kept for the owner's cull): villager_b down v3: headscarf reads as loose hair with pale neck wrap; apron pale not patched. villager_b up v1 clean; up v2 top-row poses nearly identical; up v3 idle poses nearly identical. villager_b side v1: basket/apron overlap at waist, idle variation limited; side v2: top idle poses very similar; side v3: woman carries flower basket. corrow_wax down v1: 10 poses in 4/2/4, row 2 centred so it does not align with rows 1 and 3, fade row dissolves; v2: idle poses very similar; v3: clean, background may not be exact #FF00FF. corrow_ghost down v1: ghost mostly opaque, middle pose coat wind-swept; v2: opaque-looking, magenta halo at edges; v3: middle figure coat trails right. All 1536x1024.

Prompt entries: `tools/art_prompts/batch_53.md`, job id heading per image; the fenced prompt of each entry was passed unchanged. Reference images as named in each entry.

## Files

| File | Size | Reference | Codex session | Output ID | SHA-256 (first 16) | Job id |
|---|---|---|---|---|---|---|
| `npc_villager_b_down_v1.png` | 1536x1024 | see entry | `01a16f85-b7f5-7fd1-b6da-1e181a73bf2a` | `exec-7a8ab4ab-b635-465c-99a8-3a5a4f820073` | `fc818d52dd64d81c` | `b53_npc_villager_b_down_v1` |
| `npc_villager_b_down_v2.png` | 1536x1024 | see entry | `01a16f85-b7c5-7443-8f50-69379d4dd05a` | `exec-5418c9d8-4f0b-4dd1-9df2-ca22f106e36e` | `cc227f1e052a3f7a` | `b53_npc_villager_b_down_v2` |
| `npc_villager_b_down_v3.png` | 1536x1024 | see entry | `01a16f95-fc30-78e1-b7f1-ad0034f60b79` | `exec-dc09cb34-d865-47d0-8ddd-627a56229507` | `1be40d327b652efd` | `b53_npc_villager_b_down_v3` |
| `npc_villager_b_up_v1.png` | 1536x1024 | see entry | `01a16f96-6dbc-7482-99c3-70ca70bf0fa4` | `exec-65d5a4c9-6dc3-4db0-b783-763c43f401f5` | `7a70eb9eb89f902e` | `b53_npc_villager_b_up_v1` |
| `npc_villager_b_up_v2.png` | 1536x1024 | see entry | `01a16f9a-bac7-77a3-aaaa-c9c2c1983ed0` | `exec-0ef9c02f-b314-4f94-b41d-3d59db8f16f1` | `dedc466cedd613c4` | `b53_npc_villager_b_up_v2` |
| `npc_villager_b_up_v3.png` | 1536x1024 | see entry | `01a16f9a-ba30-74c1-a7f8-cfa74e1f9058` | `exec-ca6447ff-9c0d-4176-b027-681fe3ee5d3d` | `349921a12588779e` | `b53_npc_villager_b_up_v3` |
| `npc_villager_b_side_v1.png` | 1536x1024 | see entry | `01a16f9a-baa1-7f92-b039-c8a0ea60ff3d` | `exec-026c6954-d0c4-4759-8555-09459a1a36e7` | `9cc83255b72dc1ad` | `b53_npc_villager_b_side_v1` |
| `npc_villager_b_side_v2.png` | 1536x1024 | see entry | `01a16f9a-b88d-7211-b7ea-c176af1031a6` | `exec-f00e5360-7682-4479-8f15-70dbfb650092` | `e06fff59e4db37a5` | `b53_npc_villager_b_side_v2` |
| `npc_villager_b_side_v3.png` | 1536x1024 | see entry | `01a16f9a-b93b-7510-ad30-b25d5313b908` | `exec-f614708c-c67d-4cc3-aaa0-da11e3d7cf91` | `642b97ca10125bcf` | `b53_npc_villager_b_side_v3` |
| `npc_corrow_wax_down_v1.png` | 1536x1024 | see entry | `01a16f9a-ba2f-7e50-a233-87552abcb221` | `exec-64b31ac1-a63b-492c-8974-6ab8412a5eb0` | `8a06ca594d38c9a5` | `b53_npc_corrow_wax_down_v1` |
| `npc_corrow_wax_down_v2.png` | 1536x1024 | see entry | `01a16f9f-059e-7a62-9430-a1ed37235eda` | `exec-9e8d4713-2e59-4c67-913d-e97fa61d22cd` | `e071bc648264b192` | `b53_npc_corrow_wax_down_v2` |
| `npc_corrow_wax_down_v3.png` | 1536x1024 | see entry | `01a16f9f-0502-7483-aae8-27162d5429c5` | `exec-a6c0d876-a58b-4b01-b83a-6d61ba44db50` | `039c4445210e563b` | `b53_npc_corrow_wax_down_v3` |
| `npc_corrow_ghost_down_v1.png` | 1536x1024 | see entry | `01a16f9f-07a3-7f12-9f47-0a88ae52fe1c` | `exec-3f016c0c-a8a6-4efe-9e75-bdde5fab8d4c` | `dc3e26f3eb12188c` | `b53_npc_corrow_ghost_down_v1` |
| `npc_corrow_ghost_down_v2.png` | 1536x1024 | see entry | `01a16f9f-0789-7682-8cda-8cd361293358` | `exec-d762ea5d-2b18-49da-beb3-a3ff399b9db9` | `777520c3cee04d7e` | `b53_npc_corrow_ghost_down_v2` |
| `npc_corrow_ghost_down_v3.png` | 1536x1024 | see entry | `01a16f9f-0681-7791-a3a5-65f502c2f3b6` | `exec-53bf0d37-156f-4db1-ace2-46665a91d6b7` | `c25bd26bbc00e2ec` | `b53_npc_corrow_ghost_down_v3` |

Rejected attempts: none recorded in this log (earlier-run rejects, if any, are in the local Codex folders only).
