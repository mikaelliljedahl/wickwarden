# Batch 45 log (18 images kept)

Prompts: `tools/art_prompts/batch_45.md` (job id in each heading). Backend codex, model `cheapest` (gpt-6-luna, effort medium), one image per job, idempotency key = job id. Each output is checked byte-identical (SHA-256) against its own session folder under `~/.codex/generated_images/<session>/`, and no hash is duplicated in `tools/source_art/`. Verdicts: ok, weak (why). Nothing was rejected by hand; the owner culls.

Date: 2026-10-24. Producer e.

Reference images: `tools/source_art/fx_explosion.png` (all units). No figure in this batch, so the facing and leg rule does not apply.

Attempts: every image was generated once. Sizes: every sheet came back as 1536x1024, as requested. Frame counts: chime ring 5 frames (cell 512), warp out and warp in 6 (cell 384), glow burst 4 (cell 192), leap dust 4 (cell 128), reel hit 3 (cell 96).

Reference paths: the entries give relative paths; the jobs of this batch were told to attach them by absolute path (`/home/mikael/code/github/wickwarden/tools/source_art/...`). No job reported a rejected reference.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `fx_chime_ring_v1.png` | `b45_fx_chime_ring_v1` | `01a16fc4-35e0-7172-a82b-36d3270cf7ad` | `exec-8bf9cb8a-05aa-4253-882f-8849d7368834.png` | 1536x1024 | `a1aad76fec4313cf` | ok (scattered bright flecks round the rings; spacing a little uneven) |
| `fx_chime_ring_v2.png` | `b45_fx_chime_ring_v2` | `01a16fc4-36d3-7972-96a4-cc2f76937978` | `exec-880a75f7-97bf-44df-b7a4-7c9670fe5799.png` | 1536x1024 | `5c7f977d5637ad04` | ok (sparks round the rings; largest ring near the right edge) |
| `fx_chime_ring_v3.png` | `b45_fx_chime_ring_v3` | `01a16fc4-35cc-7e63-bdb2-08a301a96a96` | `exec-447fcd53-6b3f-4bb4-bfaa-13f2aa77915a.png` | 1536x1024 | `67df95c2a8910991` | weak (ring centres drift right, uneven spacing; frame 5 off its slot centre) |
| `fx_warp_out_v1.png` | `b45_fx_warp_out_v1` | `01a16fc4-3617-7b12-81f8-fe5c67a88733` | `exec-ab7e341a-4a7c-4b57-b646-d0bc05b33808.png` | 1536x1024 | `aeb4c92df7b91d4f` | weak (effects sit low, large empty top area; first swirl near the left edge) |
| `fx_warp_out_v2.png` | `b45_fx_warp_out_v2` | `01a16fc4-34f7-7c80-bc99-9b557d7e7075` | `exec-a99b69d4-f374-4a95-8a2e-b6407f8a8ae5.png` | 1536x1024 | `2d03dbebe6156e46` | weak (first four spirals large and alike) |
| `fx_warp_out_v3.png` | `b45_fx_warp_out_v3` | `01a16fc4-3796-70e0-9277-b1b90ec8a754` | `exec-c0ac8b68-e6db-47ee-bcf7-ddd39ecbf6e8.png` | 1536x1024 | `e680b97fd7a178d0` | weak (leftmost vortex clipped by the canvas edge; frames unevenly sized) |
| `fx_warp_in_v1.png` | `b45_fx_warp_in_v1` | `01a16fc8-7a7b-7d00-909e-49707057fb80` | `exec-945c7d0c-7afe-491e-8122-0d07c1f77d52.png` | 1536x1024 | `ca440382b7f8f3a9` | ok (frame 1 a sharp starburst rather than a small spot; final ring slightly cloudy) |
| `fx_warp_in_v2.png` | `b45_fx_warp_in_v2` | `01a16fc8-79ee-7520-bca2-7c1d77e21c80` | `exec-c7e30e47-ef96-4c25-bda9-ec3811b23906.png` | 1536x1024 | `47b0ad341d488b3f` | weak (spirals look flame-like, not a soft spiral settling into a ring) |
| `fx_warp_in_v3.png` | `b45_fx_warp_in_v3` | `01a16fc8-7a11-7ce3-8b15-cc0f6df818c2` | `exec-fb01effc-b38a-4427-b897-519f2485cfa5.png` | 1536x1024 | `460ea4817a2a2d93` | ok |
| `fx_glow_burst_v1.png` | `b45_fx_glow_burst_v1` | `01a16fc8-79ab-7a01-84ad-942cd6cdeee0` | `exec-a07acc77-4379-4fd2-b5d6-9bc892b76b2e.png` | 1536x1024 | `343cda22711c6bfc` | weak (intact jar body and cap in frame 2 among the shatter) |
| `fx_glow_burst_v2.png` | `b45_fx_glow_burst_v2` | `01a16fc8-7910-7440-80a3-bbe39d5912bc` | `exec-46867ad6-7d56-46f8-8df0-54dbc6551f83.png` | 1536x1024 | `55e88773c8066c76` | ok (near-white bloom dominates frames 1 to 3) |
| `fx_glow_burst_v3.png` | `b45_fx_glow_burst_v3` | `01a16fc8-79c4-7e60-9254-df0682ffb750` | `exec-e594e8e8-34ba-4b62-9cc3-078f5c286b61.png` | 1536x1024 | `04009925061d38b7` | weak (shard debris still in frame 3 during the fade) |
| `fx_leap_dust_v1.png` | `b45_fx_leap_dust_v1` | `01a16fcc-bc7c-7f62-8654-4fc7bb37450e` | `exec-b0084b5b-b115-4cd7-b949-78d3d1fd6163.png` | 1536x1024 | `b805eb8137c4b0bf` | ok (broad irregular dust puffs; debris specks) |
| `fx_leap_dust_v2.png` | `b45_fx_leap_dust_v2` | `01a16fcc-bd7f-7803-b586-e32420113f41` | `exec-f26763f2-365c-4c73-b402-1dcc5674f4fc.png` | 1536x1024 | `c5f050843291884d` | ok (puffs large and detailed for a small effect; frames 3 and 4 alike) |
| `fx_leap_dust_v3.png` | `b45_fx_leap_dust_v3` | `01a16fcc-bd91-7c50-a108-1356a99b8b9e` | `exec-a84543ed-9314-4e32-a65a-4816fd0c461b.png` | 1536x1024 | `b31a4a38cd695591` | ok (small debris round frame 1) |
| `fx_reel_hit_v1.png` | `b45_fx_reel_hit_v1` | `01a16fcc-bbe5-7db3-99aa-cd5c733e32bf` | `exec-b149d9fc-f0f8-4822-b34b-a3714832a1e4.png` | 1536x1024 | `b638f56a6f2e7b8f` | weak (flashes larger and more elaborate than a small spark with three rays) |
| `fx_reel_hit_v2.png` | `b45_fx_reel_hit_v2` | `01a16fcc-bb78-70b1-9641-ebe12af4ce1a` | `exec-ab4526b4-45e5-48d8-9bbc-6b3f8cd803d3.png` | 1536x1024 | `7f521d2d53203143` | weak (extra spark flecks and rays beyond three) |
| `fx_reel_hit_v3.png` | `b45_fx_reel_hit_v3` | `01a16fcc-bb2b-7052-a694-b88c91c4359b` | `exec-363bc419-bd05-4d2b-855d-d3deb642e85c.png` | 1536x1024 | `d9ad88e003c66f06` | weak (large starbursts with dark flecks, not a small spark) |

## Batch 45 totals

18 images kept and verified. Verdicts: 8 ok, 10 weak. SHA-256 matches the own-session folder for every file; no duplicate hashes in `tools/source_art/`.
