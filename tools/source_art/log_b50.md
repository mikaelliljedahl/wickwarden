# Batch 50 generation log (producer f)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job; batches 48 to 52 were run by an earlier f producer, see below). Each PNG was checked by SHA-256 against the PNG in its own `~/.codex/generated_images/<session>/` folder (match in every case) and against all other `tools/source_art/` files (no duplicate).

Batch 50: proj_hush_torrent, proj_water_jet, proj_wax_hook, light_glow_warm, light_glow_cold, light_shaft.

Defects not fixed (kept for the owner's cull): light_glow_cold v2 (job b50_light_glow_cold_v2, 1254x1254 instead of 1024x1024, no defects). light_glow_cold v3 (job b50_light_glow_cold_v3, 1254x1254, background slightly textured and pink-purple, not flat #FF00FF). light_shaft v1-v3 are 1024x1536, not the requested size; not fixed. Other sheets: montage check, poses clean.

Prompt entries: `tools/art_prompts/batch_50.md`, job id heading per image; the fenced prompt of each entry was passed unchanged. Reference images as named in each entry.

## Files

| File | Size | Reference | Codex session | Output ID | SHA-256 (first 16) | Job id |
|---|---|---|---|---|---|---|
| `proj_hush_torrent_v1.png` | 1536x1024 | see entry | `01a16f6e-2b36-7841-97c1-ae2bdec53890` | `exec-e84cde0a-acc0-4df6-afa9-44fa9f18b3e6` | `dbb3b99f7292f434` | `b50_proj_hush_torrent_v1` |
| `proj_hush_torrent_v2.png` | 1536x1024 | see entry | `01a16f6e-2c21-7430-9633-81fe3f3ff6a7` | `exec-f6d109db-ebfb-49f8-8714-f0e832759a7c` | `dfa172a05357df17` | `b50_proj_hush_torrent_v2` |
| `proj_hush_torrent_v3.png` | 1536x1024 | see entry | `01a16f6e-4da2-7711-a58e-69166d1644f1` | `exec-2b86a1a2-8a1e-4a71-8a9d-0af7ce0655ec` | `9ff7385fea223a43` | `b50_proj_hush_torrent_v3` |
| `proj_water_jet_v1.png` | 1536x1024 | see entry | `01a16f6f-4af0-7891-9c22-ee0807c987de` | `exec-dfaf7950-dde0-449d-8560-ce90c4b94ceb` | `629392e09ef33ae2` | `b50_proj_water_jet_v1` |
| `proj_water_jet_v2.png` | 1536x1024 | see entry | `01a16f6f-4c54-7a83-b896-e0e03e713d80` | `exec-2be2c6a2-a7a9-4a0f-887f-0f0cdd6b445e` | `3380c4743e9bee12` | `b50_proj_water_jet_v2` |
| `proj_water_jet_v3.png` | 1536x1024 | see entry | `01a16f6f-4bf3-7400-80a0-3352bd786437` | `exec-6dc0357e-ac23-4743-9431-32a130da5f72` | `1b8ee70f3d7f7e10` | `b50_proj_water_jet_v3` |
| `proj_wax_hook_v1.png` | 1536x1024 | see entry | `01a16f6f-4ca3-7351-b2f3-c865922809ef` | `exec-96c98763-9a45-420e-a649-a4fb458c8b18` | `388e2729ec2756cb` | `b50_proj_wax_hook_v1` |
| `proj_wax_hook_v2.png` | 1536x1024 | see entry | `01a16f6f-69d1-75d3-9ca6-6d72246ed9d9` | `exec-cf6e2522-2986-4b25-9a80-68f74ba30e2b` | `cbb22d57ac89fc1c` | `b50_proj_wax_hook_v2` |
| `proj_wax_hook_v3.png` | 1536x1024 | see entry | `01a16f71-adec-7b03-a7f2-bd144baf12d6` | `exec-63fd9bec-8024-47cb-bcd1-a3a0e24c5766` | `fa8d1b6f6c4ecb79` | `b50_proj_wax_hook_v3` |
| `light_glow_warm_v1.png` | 1254x1254 | see entry | `01a16f70-85d9-7ad0-8be8-f84acf6cd138` | `exec-00534954-5b7a-41e1-8cab-3124c39d5ea2` | `99be629d68641c76` | `b50_light_glow_warm_v1` |
| `light_glow_warm_v2.png` | 1254x1254 | see entry | `01a16f70-969e-70e0-a13f-0670fe2f42dc` | `exec-d8136f61-0c08-4b5e-a21c-33608845ed29` | `a8686897370f7a14` | `b50_light_glow_warm_v2` |
| `light_glow_warm_v3.png` | 1254x1254 | see entry | `01a16f70-a73c-7960-bfb6-e2cc032a2fab` | `exec-ac5bf4af-9812-4d4d-96da-0934eaea4a3c` | `a124083a1467a19b` | `b50_light_glow_warm_v3` |
| `light_glow_cold_v1.png` | 1254x1254 | see entry | `01a16f70-b1af-7b83-8f1a-ac970fc8b514` | `exec-d89be5d4-705e-4dcd-a35d-e2fae68dbffa` | `62302c17259fdffc` | `b50_light_glow_cold_v1` |
| `light_glow_cold_v2.png` | 1254x1254 | see entry | `01a16f95-3776-7fc0-a4d1-8dfd477fdb01` | `exec-3f7a0aaa-216d-44fe-a2a6-a76cbb243c5a` | `2adcbad57437e914` | `b50_light_glow_cold_v2` |
| `light_glow_cold_v3.png` | 1254x1254 | see entry | `01a16f95-f949-75e2-99b8-43dd9afa9fdb` | `exec-89bea64d-2b6f-4999-bea5-5680a66a2d68` | `576afd4f1549cc77` | `b50_light_glow_cold_v3` |
| `light_shaft_v1.png` | 1024x1536 | see entry | `01a16f71-ae63-7d03-a466-f6e9d0d96e55` | `exec-68bcedbc-9335-4dd0-ad63-8ec5000c0a2e` | `608e4ae9e0e0ba5d` | `b50_light_shaft_v1` |
| `light_shaft_v2.png` | 1024x1536 | see entry | `01a16f71-afcf-7b50-a7d8-6243b893b2d4` | `exec-13142f49-75ae-47d3-833c-094950d85596` | `02e38af2ebc21292` | `b50_light_shaft_v2` |
| `light_shaft_v3.png` | 1024x1536 | see entry | `01a16f71-ae1f-7103-8abe-16a04ccdb5f5` | `exec-a20f0c3b-dcec-4d09-8ef4-75966ccdfc0c` | `538da20bb7c3fa50` | `b50_light_shaft_v3` |

Rejected attempts: none recorded in this log (earlier-run rejects, if any, are in the local Codex folders only).
