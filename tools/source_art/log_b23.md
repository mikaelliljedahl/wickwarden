# Batch 23 log (20 images)

Prompts: `tools/art_prompts/batch_23.md` (job id in each heading). Backend codex, model `cheapest` (gpt-6-luna, effort medium), one image per job. Each output is checked byte-identical (SHA-256) against its own session folder under `~/.codex/generated_images/<session>/`. Verdicts: ok, weak (why), failed. Fragment names and designs are in `tools/art_prompts/DESIGNS_c.md`.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `fragment_c1_v1.png` | `b23_fragment_c1_v1` | `01a16f4f-de20-77f3-a9fd-28fc0cd310d0` | `exec-2be456e2-e1d9-44c4-a1b5-2e29125252ed.png` | 1536x1024 | `f0ca630efbfd61c1` | ok (Warmth: four poses, glow medium, brightest, medium, dimmest; brass base with prongs, a little wider than the thin rim) |
| `fragment_c1_v2.png` | `b23_fragment_c1_v2` | `01a16f4f-e3c8-7c93-a2e0-871280bc1f8f` | `exec-8049af27-7dbe-40da-a52d-559e8439e2a2.png` | 1536x1024 | `1da9e714678da13f` | ok (Warmth; rounder shard body than v1) |
| `fragment_c1_v3.png` | `b23_fragment_c1_v3` | `01a16f4f-ef14-73c2-a7ed-9d725d6f082e` | `exec-16742f95-e795-441c-beba-7ce62fd021cf.png` | 1536x1024 | `020139caad508ffc` | ok (Warmth; four distinct glow poses) |
| `fragment_c2_v1.png` | `b23_fragment_c2_v1` | `01a16f4f-f67d-7540-8d6f-08f506e8046a` | `exec-7bce487e-c6d0-4253-849c-84ce38ba3ea5.png` | 1536x1024 | `eb708fe8554531b9` | ok (Growth: green glass with a leaf pattern inside) |
| `fragment_c2_v2.png` | `b23_fragment_c2_v2` | `01a16f4f-feea-71d2-b605-a5c16f426430` | `exec-ba5beee4-8e3f-45a2-a84f-7aea20a914b8.png` | 1536x1024 | `4074b427c6203b3d` | ok (Growth) |
| `fragment_c2_v3.png` | `b23_fragment_c2_v3` | `01a16f50-046b-7693-97f3-e38052355571` | `exec-a9056bff-5472-48d4-9004-312bd7aa6f4b.png` | 1536x1024 | `1a0e207e6fb7bc02` | ok (Growth; moss grows on the lower shard, a variation that is acceptable) |
| `fragment_c3_v1.png` | `b23_fragment_c3_v1` | `01a16f51-7a2c-7ff1-8bd8-1135c5b26fa1` | `exec-eda93611-7c8c-4f78-bee9-c90bd1855d5b.png` | 1536x1024 | `a4253e687e7c2147` | weak (Rain: poses 1 and 2 are nearly the same brightness, so the glow order is not clear) |
| `fragment_c3_v2.png` | `b23_fragment_c3_v2` | `01a16f51-80d6-7dd1-bbc3-6f231dc3c90f` | `exec-0445d760-9846-4ad1-bf9d-a51793e0b693.png` | 1536x1024 | `27231fd238e67a3e` | weak (Rain: pose 3 is brighter than pose 2, the specified brightest pose) |
| `fragment_c3_v3.png` | `b23_fragment_c3_v3` | `01a16f51-9259-7cf1-b762-67956f399bbd` | `exec-cecf32f5-8547-490d-86ad-f3c6f6023197.png` | 1536x1024 | `79250eae469ea79d` | ok (Rain: the glow order is clear; the job could not inspect its own image, so the verdict is from the montage) |
| `fragment_c4_v1.png` | `b23_fragment_c4_v1` | `01a16f51-c505-71f2-8913-318a99b494e8` | `exec-dfd34ca2-ed09-4fb8-81fc-429969f1fc63.png` | 1536x1024 | `bdb88c326fffe9d4` | ok (Sleep: violet shard, four glow poses; the violet is close to the magenta key, check the despill at cut) |
| `fragment_c4_v2.png` | `b23_fragment_c4_v2` | `01a16f51-c8fd-7e91-aa63-c7393d184f11` | `exec-96152922-42c3-42fe-a80f-9e71170c781b.png` | 1536x1024 | `566aa0f47f5f6f28` | ok (Sleep; the same key-closeness note) |
| `fragment_c4_v3.png` | `b23_fragment_c4_v3` | `01a16f51-dc47-77c2-9035-908b40fed15e` | `exec-df2f235b-b237-4b7c-992e-927265064bdd.png` | 1536x1024 | `f6dc51ffca74609c` | ok (Sleep; the same key-closeness note) |
| `fragment_c5_v1.png` | `b23_fragment_c5_v1` | `01a16f53-1940-76c2-961c-08fcc3191852` | `exec-3362d34c-4e7e-41c7-9445-7cc2b2a1b826.png` | 1536x1024 | `767f12f8e5e8e839` | ok (Memory: pale cream-white glass with fine lines, four glow poses) |
| `fragment_c5_v2.png` | `b23_fragment_c5_v2` | `01a16f53-1c98-7761-96e6-08424ef64050` | `exec-f759336c-2486-4da1-a9d1-462dba7ec2c1.png` | 1536x1024 | `63c6a18a152038a0` | ok (Memory; pose 3 glow a little brighter than medium, acceptable) |
| `fragment_c5_v3.png` | `b23_fragment_c5_v3` | `01a16f53-2350-7212-be17-597c0f263c1e` | `exec-6807a208-c750-4f30-9c72-0dd5a10a3429.png` | 1536x1024 | `5f553a3770f5d808` | weak (Memory: warm gold-tan glass instead of pale silver-white; close to Warmth) |
| `fragment_c6_v1.png` | `b23_fragment_c6_v1` | `01a16f53-2c9b-7300-8508-c939c51fccab` | `exec-4f69a21f-6033-4a4f-9092-00a0e35d0704.png` | 1536x1024 | `17035ee73fe11c77` | ok (Song: rose-pink glass with ripple lines, four glow poses; pink is close to the magenta key, check the despill) |
| `fragment_c6_v2.png` | `b23_fragment_c6_v2` | `01a16f53-329d-7051-9de9-f534b734ca48` | `exec-ed459320-55bd-41ee-b6d4-2274ab7751e0.png` | 1536x1024 | `9f201fb03d3a6eb8` | weak (Song: the dimmest pose 4 still has a fairly bright inner glow) |
| `fragment_c6_v3.png` | `b23_fragment_c6_v3` | `01a16f53-3b3f-7ee2-abab-9cbdd96bf2c4` | `exec-fe6f11bd-8601-42ff-afe2-5a762968c0da.png` | 1536x1024 | `401f792a79430cff` | ok (Song; the same key-closeness note) |
| `fragment_c7_v1.png` | `b23_fragment_c7_v1` | `01a16f54-897f-7cd3-a27b-ca7e7ce9d57e` | `exec-c72972cc-4559-467d-8b98-b14d1c91f3fd.png` | 1536x1024 | `bc6040b04ac35e36` | ok (Courage: deep red-orange glass with a bright core, four glow poses) |
| `fragment_c7_v2.png` | `b23_fragment_c7_v2` | `01a16f54-8adc-7542-81b5-40dfd1e363d2` | `exec-1c0c8c09-2428-4e1b-a789-5694ce50f978.png` | 1536x1024 | `2ee140d2b16e4d0c` | ok (Courage; the same set) |

## Batch 23 totals

20 images verified (SHA-256 matches the own-session folder for every file; no duplicate hashes in `tools/source_art/`).
Ok: 16 (`fragment_c1` v1 to v3, `fragment_c2` v1 to v3, `fragment_c3_v3`, `fragment_c4` v1 to v3, `fragment_c5_v1`, `fragment_c5_v2`, `fragment_c6_v1`, `fragment_c6_v3`, `fragment_c7` v1 and v2).
Weak: 4 (`fragment_c3_v1`, `fragment_c3_v2`, `fragment_c5_v3`, `fragment_c6_v2`).
Failed: 0. Weak images stay in the source folder for the owner's cull.
Notes: the six key-close pinks and violets (c4 Sleep, c6 Song) need a check of the despill in the cut step; the magenta key is close to their hue.
