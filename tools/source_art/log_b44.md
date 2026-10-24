# Batch 44 log (18 images kept)

Prompts: `tools/art_prompts/batch_44.md` (job id in each heading). Backend codex, model `cheapest` (gpt-6-luna, effort medium), one image per job, idempotency key = job id. Each output is checked byte-identical (SHA-256) against its own session folder under `~/.codex/generated_images/<session>/`, and no hash is duplicated in `tools/source_art/`. Verdicts: ok, weak (why). Nothing was rejected by hand; the owner culls.

Date: 2026-10-24. Producer e.

Reference images: `tools/source_art/fx_explosion.png` (all units); `tools/source_art/braziers.png` added for the wisp burst units (fire colour). No figure in this batch, so the facing and leg rule does not apply.

Attempts: every image was generated once. Sizes: every sheet came back as 1536x1024, as requested. Frame counts: hit spark 3 frames, enemy poof 5, water splash 5, water ripple 4, raft wake 4, wisp burst 5 (one row each, per the batch entries).

Reference paths: the entries give relative paths; the jobs of this batch were told to attach them by absolute path (`/home/mikael/code/github/wickwarden/tools/source_art/...`). No job reported a rejected reference.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `fx_hit_spark_v1.png` | `b44_fx_hit_spark_v1` | `01a16fb7-3a06-7f72-91c9-a3942e1426cf` | `exec-fa20cfec-674f-4810-96fa-5843ac048647.png` | 1536x1024 | `09799645f3923118` | weak (fiery explosion with dark shard-like debris, not a small white-gold spark) |
| `fx_hit_spark_v2.png` | `b44_fx_hit_spark_v2` | `01a16fb6-e318-76e3-ab68-fd13e3d77ed6` | `exec-c69b53de-a989-4967-b79d-2ad74207a145.png` | 1536x1024 | `9d4e7ee7d18d1e7d` | weak (last frame still has rocks and glow, not a few sparks) |
| `fx_hit_spark_v3.png` | `b44_fx_hit_spark_v3` | `01a16fb7-4002-7040-9cfe-2d8059a95d56` | `exec-11169d0b-7579-41b9-a2ba-21fccd22a226.png` | 1536x1024 | `264e9c23775e6966` | weak (dark brown rocky flecks among the spark frames) |
| `fx_enemy_poof_v1.png` | `b44_fx_enemy_poof_v1` | `01a16fb6-e2f2-7920-af01-78509751f7e6` | `exec-dac7aaef-9430-4c14-be95-0f149075244c.png` | 1536x1024 | `78e7844dd0032201` | ok |
| `fx_enemy_poof_v2.png` | `b44_fx_enemy_poof_v2` | `01a16fb7-4be8-7fe3-845a-2dcf24a3ddd1` | `exec-17a04d52-8cc3-4c56-814b-cf34a3fe99d1.png` | 1536x1024 | `f9fa2ae6bc0afcfb` | weak (first four frames look alike; progression hard to read) |
| `fx_enemy_poof_v3.png` | `b44_fx_enemy_poof_v3` | `01a16fb6-e3cd-73c3-a405-3227539e149a` | `exec-187b754a-f33a-4ff9-9935-492a0e628906.png` | 1536x1024 | `534eb7efe8e14f59` | ok |
| `fx_water_splash_v1.png` | `b44_fx_water_splash_v1` | `01a16fbb-21d3-7a42-92d4-59be73bb5d9d` | `exec-6ecc5306-f769-4fa7-badc-3e42130f4a35.png` | 1536x1024 | `63fb56ce38fc1afa` | ok |
| `fx_water_splash_v2.png` | `b44_fx_water_splash_v2` | `01a16fbb-22c9-7282-83e9-70d5eb2f330a` | `exec-2aafa0b8-bd74-42aa-a925-479493a395fe.png` | 1536x1024 | `65b5526a92316737` | ok (frames 2 and 3 alike; frames 4 and 5 lose the body) |
| `fx_water_splash_v3.png` | `b44_fx_water_splash_v3` | `01a16fbb-23e0-7ab1-bdfa-852afcc98341` | `exec-bde4b69e-4149-44aa-a506-1cf061198503.png` | 1536x1024 | `b1ae9dfc86f22875` | weak (magenta-filled centres in the middle frames, may key out) |
| `fx_water_ripple_v1.png` | `b44_fx_water_ripple_v1` | `01a16fbb-2208-7a93-af29-0ab231d4fd29` | `exec-2a8ac076-ebe4-4959-ae58-bf7a32db5f17.png` | 1536x1024 | `fc5a1c3cfc56b378` | ok (first frames have a central splash, stray droplets; last two rings faint) |
| `fx_water_ripple_v2.png` | `b44_fx_water_ripple_v2` | `01a16fbb-226b-7851-ac44-5baa7173cdc9` | `exec-602d89bb-cf6e-4fe2-8f5b-716f5ff63ee4.png` | 1536x1024 | `2946f832e46073bd` | weak (rings oversized and close; magenta through later rings) |
| `fx_water_ripple_v3.png` | `b44_fx_water_ripple_v3` | `01a16fbb-2272-7fa3-8e5c-1d6de09f3206` | `exec-2927f24f-90e9-480d-b622-24cc23da8401.png` | 1536x1024 | `c338faca5ea1b86f` | weak (ripples larger and more detailed than a ring; frame 1 very small, frame 4 faint) |
| `fx_raft_wake_v1.png` | `b44_fx_raft_wake_v1` | `01a16fbf-5f54-74a1-ab94-4129624bcd93` | `exec-831d88ed-acb6-481f-9838-db4fc25d6658.png` | 1536x1024 | `bc449ecede4cc501` | ok (frames 3 and 4 nearly the same size) |
| `fx_raft_wake_v2.png` | `b44_fx_raft_wake_v2` | `01a16fbf-5e66-71b2-a274-56fa844db9d8` | `exec-40deb2c4-271c-42d4-b50a-471ac5421a08.png` | 1536x1024 | `f9c832fbfbcde3cc` | ok (wakes large and tall; frame 4 tips near the top edge) |
| `fx_raft_wake_v3.png` | `b44_fx_raft_wake_v3` | `01a16fbf-5f84-75a3-b563-b45bf58a9864` | `exec-e43d12b3-5478-4e46-b5f6-150ecb221f5f.png` | 1536x1024 | `57372a0fb8888de4` | weak (frames vary a lot in size; frame 4 touches the right edge) |
| `fx_wisp_burst_v1.png` | `b44_fx_wisp_burst_v1` | `01a16fbf-5f31-7040-8021-2cfd0207362f` | `exec-d512c656-e52b-4e46-9c6f-1920b173b033.png` | 1536x1024 | `e186704da89ee20a` | ok (frame 1 a starburst then rings; frames 2 and 3 alike) |
| `fx_wisp_burst_v2.png` | `b44_fx_wisp_burst_v2` | `01a16fbf-5ec7-7f33-a6ad-780175377bf6` | `exec-57ae31c2-bf16-4a28-bf4c-7986dff4c0f0.png` | 1536x1024 | `6be8e11f790b13a0` | weak (explosive and cloudy, not a clean flame ring) |
| `fx_wisp_burst_v3.png` | `b44_fx_wisp_burst_v3` | `01a16fbf-5f9a-72b1-bd7e-ea048258f6f2` | `exec-e10b00da-120e-4a71-9837-caa055e042ae.png` | 1536x1024 | `5961c341c7d05e41` | weak (frames 1 and 2 filled bursts, not open rings; last ring uneven and faint) |

## Batch 44 totals

18 images kept and verified. Verdicts: 8 ok, 10 weak. SHA-256 matches the own-session folder for every file; no duplicate hashes in `tools/source_art/`.
