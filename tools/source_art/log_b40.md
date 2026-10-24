# Batch 40 log (18 images)

Prompts: `tools/art_prompts/batch_40.md` (job id `b40_<output>` for each row). Backend codex, model `cheapest` (gpt-6-luna, effort medium), one image per job, 1536x1024. Each output is checked byte-identical (SHA-256) against its own session folder under `~/.codex/generated_images/<session>/`. No hash is duplicated in `tools/source_art/`. Verdicts are from viewing the montage; weak images are kept for the owner's cull. Run by producer a, 2026-10-24.

Two runs: eleven files (`pump_valve_*`, `pipe_segment_*`, `mirror_reflective_1_v1` and `_v2`) came from an earlier run whose log was never written. Their hashes match their session folders and they were viewed in this run, so they are kept and logged here. Seven files (`mirror_reflective_1_v3`, `mirror_reflective_2_v1` to `_v3`, `mirror_cracked_v1` to `_v3`, `mirror_cracked_v2`) were generated in this run.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `pump_valve_1_v1.png` | `b40_pump_valve_1_v1` | `01a16f78-c130-7f51-a5d9-fcc94a0cb11d` | `exec-5735259c-a07f-43a5-a116-7635efdbe82b.png` | 1536x1024 | `c480476f7138ce9c` | ok (iron wheel valve, two stubs, brass gauge; plain silhouette) |
| `pump_valve_1_v2.png` | `b40_pump_valve_1_v2` | `01a16f78-c4b9-7261-9bae-81d64e8618f5` | `exec-3fa55fc6-d0ec-40b4-85ae-784d485d1675.png` | 1536x1024 | `eead2797cf6c81a9` | weak (a second gauge on a pipe stub and a larger body; not the single-gauge design) |
| `pump_valve_1_v3.png` | `b40_pump_valve_1_v3` | `01a16f78-ce2f-7fa1-ad19-ded801f21e09` | `exec-b3b3b4f7-a74e-4514-a5f8-48652600e0f2.png` | 1536x1024 | `e71156382ec219b1` | ok (valve with gauge on the housing; clear) |
| `pump_valve_2_v1.png` | `b40_pump_valve_2_v1` | `01a16f78-d46a-7d51-8f5e-41a1d3f1a48c` | `exec-35b73ce8-8af9-46e0-afd8-f4f6c7731983.png` | 1536x1024 | `5b3923f6bda0c797` | ok (tall hand pump with lever, on subject; a flower and moss base not asked for) |
| `pump_valve_2_v2.png` | `b40_pump_valve_2_v2` | `01a16f78-e95c-7ae1-938f-c40179bf29a0` | `exec-1ddac504-9e95-4ea2-84c1-64fe0bb2384e.png` | 1536x1024 | `5dbb76fd7a4d49a9` | ok (tall hand pump with lever, on subject; moss at the base not asked for) |
| `pump_valve_2_v3.png` | `b40_pump_valve_2_v3` | `01a16f79-016a-7921-8941-a289edf53ae7` | `exec-5af233e2-b840-41d8-a4ba-cbe47bb7539b.png` | 1536x1024 | `c592af273779786e` | ok (tall hand pump with lever, on subject; flowers at the base not asked for) |
| `pipe_segment_v1.png` | `b40_pipe_segment_v1` | `01a16f7a-e5b7-7e71-9460-d9d4993445b8` | `exec-29d0fdc7-41f9-445c-9906-9aa7cd920758.png` | 1536x1024 | `f99dfbb22a74480b` | ok (flanged pipe with brass bands; drip at the flange) |
| `pipe_segment_v2.png` | `b40_pipe_segment_v2` | `01a16f7a-e689-7e72-b583-ef607adf4174` | `exec-587b264c-eb7a-4836-a09d-dcac175d4b35.png` | 1536x1024 | `694ce00b53e0164e` | ok (flanged pipe, brass bands) |
| `pipe_segment_v3.png` | `b40_pipe_segment_v3` | `01a16f7a-f088-7f50-9e25-45705138b127` | `exec-d05c3dd7-49cd-4718-9502-cf967e9ef88a.png` | 1536x1024 | `def3f15cd9419b7b` | ok (flanged pipe, brass bands, thin crack) |
| `mirror_reflective_1_v1.png` | `b40_mirror_reflective_1_v1` | `01a16f7a-f847-7611-8528-a62769081b36` | `exec-1ecd828e-c3ec-4d7a-ae0d-26e7056426d0.png` | 1536x1024 | `5104e7447d286b56` | ok (arched wood-frame standing mirror; sky reflection) |
| `mirror_reflective_1_v2.png` | `b40_mirror_reflective_1_v2` | `01a16f89-b67a-73d2-bedf-8e5606924101` | `exec-d8f64ef4-782f-4a3b-ae2a-dc7fb39980da.png` | 1536x1024 | `7c2164441519baa1` | ok (same mirror, aged glass with spots) |
| `mirror_reflective_1_v3.png` | `b40_mirror_reflective_1_v3` | `01a16fa8-7388-7f61-a8a0-7adce890d29d` | `exec-aa7c2c3e-4006-4af6-a3f3-c08ac9dc8fbb.png` | 1536x1024 | `34a25a9d0e1ef1f8` | weak (faint magenta bleed under the bottom frame) |
| `mirror_reflective_2_v1.png` | `b40_mirror_reflective_2_v1` | `01a16fa8-a9a1-79e3-8516-a98c506abda2` | `exec-2e31faff-947a-46bf-9e12-cc3076b6609a.png` | 1536x1024 | `4d200edcd0eb3b12` | weak (oval mirror with vines and a finial, not asked for) |
| `mirror_reflective_2_v2.png` | `b40_mirror_reflective_2_v2` | `01a16fa8-cb95-74b3-b282-947e37e8cd02` | `exec-82ef13e5-048e-42e0-8a95-0dac9768eb43.png` | 1536x1024 | `b6895bcbaec5aa44` | ok (oval mirror, plain frame, uncropped) |
| `mirror_reflective_2_v3.png` | `b40_mirror_reflective_2_v3` | `01a16fa8-81fd-7971-8cc8-a46ddb93818c` | `exec-9612f970-980e-488a-8a32-6a0d6e66d7be.png` | 1536x1024 | `d44097ea64572737` | weak (leafy frame and stand, not asked for) |
| `mirror_cracked_v1.png` | `b40_mirror_cracked_v1` | `01a16fa8-878a-7fb0-9887-2a405923d188` | `exec-f375a1cc-e117-48a2-9a53-5c6263253021.png` | 1536x1024 | `1d2490b199ab6757` | ok (cracked mirror, branching cracks, chips) |
| `mirror_cracked_v2.png` | `b40_mirror_cracked_v2` | `01a16fa8-7235-76e2-a0b0-903d58837a84` | `exec-59cd806e-213b-4463-90d5-6127ad78a2f5.png` | 1536x1024 | `c6b5edfdf63bcf27` | weak (ivy over the frame, not asked for) |
| `mirror_cracked_v3.png` | `b40_mirror_cracked_v3` | `01a16fac-56df-7bd1-aeba-5d378cac6f2f` | `exec-50e33549-cbc3-457d-b2d5-0f47250cd13d.png` | 1536x1024 | `b4e64b91d4037a8f` | ok (cracked mirror, plain frame) |

Totals: 13 ok, 5 weak, 0 failed. Failed attempts: none. The reference-path error (relative path) that hit `hidden_stairs_v1` in batch 27 was avoided by using absolute reference paths.

Note: the mirror outputs often add vines, leaves and ornaments the prompt does not ask for, and the pump and pipe outputs add moss and flowers at the base; logged as weak where it changes the design, else ok. Logged as weak; the owner culls.
