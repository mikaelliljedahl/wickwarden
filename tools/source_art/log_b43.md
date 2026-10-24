# Batch 43 log (18 images kept)

Prompts: `tools/art_prompts/batch_43.md` (job id in each heading). Backend codex, model `cheapest` (gpt-6-luna, effort medium), one image per job, idempotency key = job id. Each output is checked byte-identical (SHA-256) against its own session folder under `~/.codex/generated_images/<session>/`, and no hash is duplicated in `tools/source_art/`. Verdicts: ok, weak (why). Nothing was rejected by hand; the owner culls.

Date: 2026-10-24. Producer e.

Reference images: `tools/source_art/fx_explosion.png` (all effects), `tools/source_art/braziers.png` (fire units, fire colour). No figure in this batch, so the facing and leg rule does not apply.

Attempts: every image was generated once, except `fx_dust_puff_v2`. Its first job (`ww-b43-fx_dust_puff-v2`, idempotency key `b43_fx_dust_puff_v2`, session `01a16fae-0bf5-76b3-acf3-f0fabb60e31a`) FAILED at the reference attach: the image tool rejected the relative reference path. No image was generated. It was resubmitted as `b43_fx_dust_puff_v2-r1` with the reference given as an absolute path; the prompt was unchanged. The table row is the -r1 image.

Sizes: every sheet came back as 1536x1024, as requested. Frame counts: 4 frames for the fire, smoke and dust units, 5 for the ember sparks ...

Defects not fixed (for the owner's cull): the fire units (small in particular) have flames taller than a low fire and loose detached sparks; the three smoke puffs came back as fiery explosion puffs with sparks and debris, not soft smoke (weak for all three); the dust puff v2 is rock-studded; the smoke column v2 is denser than the thin wisps asked for; the dark pebble flecks in dust v1 and v3 may need a clean-up.

Rejected outputs: the failed `fx_dust_puff_v2` job produced no file. Everything else is in the table below.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `fx_fire_small_v1.png` | `b43_fx_fire_small_v1` | `01a16fa5-9bb4-7ea3-979d-5d5d5775bf25` | `exec-48e31723-c19c-4bd2-9db3-18fe6a49fc77.png` | 1536x1024 | `9c6a99db80ecd513` | weak (flames taller than a low fire; loose ember flecks) |
| `fx_fire_small_v2.png` | `b43_fx_fire_small_v2` | `01a16fa5-9dc1-7083-858d-9c87106083a8` | `exec-9a8abc53-16fc-4092-82b7-a245199bf686.png` | 1536x1024 | `79b9af23c01c5fe0` | weak (second flame much taller than the others; many detached sparks) |
| `fx_fire_small_v3.png` | `b43_fx_fire_small_v3` | `01a16fa6-5703-79d3-8450-e88da45fa9ce` | `exec-345c9aba-ce19-4ac9-8882-9f5f235456fa.png` | 1536x1024 | `3c249cd24b3dc819` | weak (flames large for a small fire; detached sparks) |
| `fx_fire_big_v1.png` | `b43_fx_fire_big_v1` | `01a16fa5-9c28-75b3-83af-5591c2f2b30b` | `exec-ea32e780-223d-4e11-b9bc-42d7869c3994.png` | 1536x1024 | `989b1a09469ad373` | ok (frames similar; flames sit low, much empty space above; ember flecks) |
| `fx_fire_big_v2.png` | `b43_fx_fire_big_v2` | `01a16fa5-9cd8-7c70-b5dd-5b5a48d080ed` | `exec-b61a67d6-ec28-4a06-8185-e393e6e5ce21.png` | 1536x1024 | `63ff7588625a1f95` | ok |
| `fx_fire_big_v3.png` | `b43_fx_fire_big_v3` | `01a16fa5-9dc5-74b0-bacd-6926a168e91d` | `exec-fe79e390-caf3-4eef-a955-bb6560695f46.png` | 1536x1024 | `4df5cddebff17c21` | ok (small ember specks) |
| `fx_ember_sparks_v1.png` | `b43_fx_ember_sparks_v1` | `01a16fa9-d6a8-7583-b332-36b8e751dda9` | `exec-1e6157f0-4c44-4fbc-bbad-4355ff400930.png` | 1536x1024 | `d94f91303b548a03` | ok |
| `fx_ember_sparks_v2.png` | `b43_fx_ember_sparks_v2` | `01a16faa-9cf0-7d43-8f69-b2d1cb259889` | `exec-8f27878a-5ce6-4400-93cc-787dfa9744e4.png` | 1536x1024 | `f77ad482dedab4c1` | ok (frame 4 smaller and lower than frame 3; glow on the magenta) |
| `fx_ember_sparks_v3.png` | `b43_fx_ember_sparks_v3` | `01a16faa-9149-7b03-a239-79ac5d7874df` | `exec-0bc88698-f0f0-43f1-bfbb-c28e0bc6763b.png` | 1536x1024 | `03bccc082a70a09f` | ok |
| `fx_smoke_puff_v1.png` | `b43_fx_smoke_puff_v1` | `01a16fa9-d5b1-7892-bc70-53b3b58cec87` | `exec-13d7703a-1eae-4902-af3b-7bf90737e075.png` | 1536x1024 | `c1cebb6cfef4b04a` | weak (fiery explosion puffs with sparks and debris, not soft smoke) |
| `fx_smoke_puff_v2.png` | `b43_fx_smoke_puff_v2` | `01a16faa-677f-7cc1-87f9-cb0358c4d5ac` | `exec-607046fc-6fd2-4ff3-a559-015fd5ed8ad7.png` | 1536x1024 | `20dbb45ef402509c` | weak (same as v1: explosion, not smoke) |
| `fx_smoke_puff_v3.png` | `b43_fx_smoke_puff_v3` | `01a16faa-9210-7b33-8ca3-ef17c6273a86` | `exec-ae6be3e2-8efe-4817-a140-d0c1e85fc432.png` | 1536x1024 | `ef561bdad9e9389e` | weak (same as v1: explosion, not smoke) |
| `fx_smoke_column_v1.png` | `b43_fx_smoke_column_v1` | `01a16fae-0cd3-73f1-b2cb-bb1e5d8ed9ce` | `exec-18a27540-b25c-47e7-a533-36c71ec5e31d.png` | 1536x1024 | `daa163dfdf483838` | ok (slight magenta fringe at the soft edges) |
| `fx_smoke_column_v2.png` | `b43_fx_smoke_column_v2` | `01a16fae-0b06-70a1-921f-e9d935393c5b` | `exec-2674fe3f-0abe-4912-97e3-64a39fbdd45e.png` | 1536x1024 | `50c85b54d57617f3` | weak (denser and cloudier than the thin wisps asked for) |
| `fx_smoke_column_v3.png` | `b43_fx_smoke_column_v3` | `01a16fae-0d48-7b03-8b78-9034ba1e242e` | `exec-e922d90b-894d-4ffd-ac8d-a5eb169b7d7b.png` | 1536x1024 | `2179b15685342fd5` | ok (frame 3 noticeably larger than the others) |
| `fx_dust_puff_v1.png` | `b43_fx_dust_puff_v1` | `01a16fae-0d4d-7f80-825b-84ffe23297c5` | `exec-11d64585-2508-4ca5-a582-0f92c7db2dea.png` | 1536x1024 | `2cd24dc95735e3ab` | ok (dark pebble-like debris round the puffs) |
| `fx_dust_puff_v2.png` | `b43_fx_dust_puff_v2` | `01a16fb1-b933-72d0-b0da-6c1a537bc759` | `exec-c55a5845-8e24-4625-8a6c-7ecc9242b0ef.png` | 1536x1024 | `29c461efff0a80b0` | weak (rock-studded explosions, not low dust puffs) |
| `fx_dust_puff_v3.png` | `b43_fx_dust_puff_v3` | `01a16fae-0b42-7aa2-9fcc-b0c4314e0568` | `exec-a2c9c475-7ab1-4366-9c8a-239cb95f66f8.png` | 1536x1024 | `cec61275e58ae44c` | ok (dark flecks round the clouds; frame shapes and spacing vary) |

## Batch 43 totals

18 images kept and verified. Verdicts: 10 ok, 8 weak (3 small fire, 3 smoke puff, smoke column v2, dust puff v2). SHA-256 matches the own-session folder for every file; no duplicate hashes in `tools/source_art/`.
