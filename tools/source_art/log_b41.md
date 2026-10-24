# Batch 41 log (18 images)

Prompts: `tools/art_prompts/batch_41.md` (job id `b41_<output>` for each row). Backend codex, model `cheapest` (gpt-6-luna, effort medium), one image per job, 1536x1024. Each output is checked byte-identical (SHA-256) against its own session folder under `~/.codex/generated_images/<session>/`. No hash is duplicated in `tools/source_art/`. Verdicts are from viewing the montage; weak images are kept for the owner's cull. Run by producer a, 2026-10-24.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `workbench_1_v1.png` | `b41_workbench_1_v1` | `01a16fb0-0cd8-79c0-9541-60444969f0a6` | `exec-cf1abe22-6360-404d-a015-f960160f694b.png` | 1536x1024 | `8032dc9975ffb7bb` | ok (single bench on magenta; intact) |
| `workbench_1_v2.png` | `b41_workbench_1_v2` | `01a16faf-c65f-7d73-b8e4-5437f4bf8f45` | `exec-4a8b9a61-a5f1-4a90-812e-8540e62a89e1.png` | 1536x1024 | `7f35e927edca1e83` | weak (leafy vines and extra shelf clutter beyond the plain design) |
| `workbench_1_v3.png` | `b41_workbench_1_v3` | `01a16faf-c369-7332-81c7-881a063a9651` | `exec-680b71e4-fde7-48ad-ae77-f7ae8a1d9dfc.png` | 1536x1024 | `65d79a43f4302111` | weak (a vivid magenta cord on the shelf may drop out with the key) |
| `workbench_2_v1.png` | `b41_workbench_2_v1` | `01a16faf-cc7d-7df3-b686-32c8d9a5ff46` | `exec-1ba76a04-ac75-4f4b-ad49-d7efeec53f6f.png` | 1536x1024 | `a8bc36c016e5e7b9` | ok (bench with lantern and drawer; no visible defect) |
| `workbench_2_v2.png` | `b41_workbench_2_v2` | `01a16faf-a663-7253-bdca-1384907a3059` | `exec-14db5fcd-5805-4e9a-80ff-9493a25cd181.png` | 1536x1024 | `9026d26e529abaec` | ok (isolated bench on magenta) |
| `workbench_2_v3.png` | `b41_workbench_2_v3` | `01a16faf-a582-7831-8f5e-b7453810ff68` | `exec-c7d815d2-edda-4b00-99d9-f59ff448fed7.png` | 1536x1024 | `f2530874d72a0b00` | ok (one complete bench on magenta) |
| `mural_1_v1.png` | `b41_mural_1_v1-r1` | `01a16fb4-7dbe-7203-aa3d-b56a85d38e72` | `exec-568e2822-d08b-4243-aa6e-1276fd6281af.png` | 1536x1024 | `e8be4c2d9657a474` | ok (lanterns along a dusk hill; ivy on the frame) |
| `mural_1_v2.png` | `b41_mural_1_v2` | `01a16fb5-211e-7490-892b-8a4625aae198` | `exec-1a86816b-52f8-478d-8e36-dc82c1d302ab.png` | 1536x1024 | `b1d26c71fa8793f7` | weak (four hanging lanterns on a wire, not set along a hill) |
| `mural_1_v3.png` | `b41_mural_1_v3` | `01a16fb4-7e4c-7c52-8f48-925f07a506c3` | `exec-ee929efc-87d9-432e-8c25-14b75d8654c1.png` | 1536x1024 | `ef469957e7208d1e` | weak (detailed lit valley, not a simple row of lanterns; faded frame) |
| `mural_2_v1.png` | `b41_mural_2_v1` | `01a16fb4-7d15-7c40-8ac3-553d9baeee0d` | `exec-8ee98d6a-cbf5-4fa4-afc2-ce784c70f220.png` | 1536x1024 | `cb0297297355809a` | ok (harbour, pale moon, boat; framed) |
| `mural_2_v2.png` | `b41_mural_2_v2` | `01a16fb4-83cc-7063-8fc7-83669e0ca58d` | `exec-4811f502-26f2-4737-b3d7-0b3f7337085c.png` | 1536x1024 | `9ffd88f9ff24c1f5` | ok (framed harbour mural; no visible defect) |
| `mural_2_v3.png` | `b41_mural_2_v3` | `01a16fb4-83bb-7380-ab09-324555fa1f91` | `exec-94230865-e756-4005-a486-8793281cf309.png` | 1536x1024 | `13dcdafcedb5ff3d` | weak (cracked stone and vines beyond the framed mural) |
| `mural_3_v1.png` | `b41_mural_3_v1` | `01a16fb9-5d0c-7460-acb0-d661b2605671` | `exec-60246fee-f430-46da-ac4f-b55417b3a3dc.png` | 1536x1024 | `138ba8fdbb94259e` | ok (tree with birds; framed) |
| `mural_3_v2.png` | `b41_mural_3_v2` | `01a16fb9-5d0b-7992-96ef-99057affee4b` | `exec-8407f94f-155a-42aa-b0e7-9cfae3898490.png` | 1536x1024 | `56f62db59ee489c2` | ok (tree with birds; legible on magenta) |
| `mural_3_v3.png` | `b41_mural_3_v3` | `01a16fb9-5d8e-7670-a834-90c1eab0e36b` | `exec-0a369808-1e25-4ed0-9af3-0a2e4cbab65c.png` | 1536x1024 | `741e8d41a42a9361` | ok (tree and birds; uncropped) |
| `mural_4_v1.png` | `b41_mural_4_v1` | `01a16fb9-5c8e-7e40-a044-f874a5eebaa0` | `exec-e85ff2be-db90-4602-b6f7-0c7f9d909e06.png` | 1536x1024 | `bf66008c9a0832f2` | ok (lantern in a star ring on violet; intact) |
| `mural_4_v2.png` | `b41_mural_4_v2` | `01a16fb9-4beb-7270-ae58-659fef0f94ab` | `exec-23ec5981-67dd-4e4c-90b7-bf22de63c313.png` | 1536x1024 | `12e857216296d286` | ok (lantern in a ring; uniform magenta) |
| `mural_4_v3.png` | `b41_mural_4_v3` | `01a16fb9-5b60-77b3-828b-c1b4924d5260` | `exec-04260b8f-4b18-407f-b49c-ce4c517e3c67.png` | 1536x1024 | `7b77129a256491ef` | ok (lantern in a ring with leaf border; intact) |

Totals: 13 ok, 5 weak, 0 failed.

Attempts: `b41_mural_1_v1` was first submitted as `b41_mural_1_v1` and cancelled before it started (it was above the limit of six running jobs); it was resubmitted as `b41_mural_1_v1-r1`, which is the file kept above. The first wave held six jobs and the second wave six more, with absolute reference paths.

Note: the mural and workbench outputs often add ivy, leaves or clutter that the prompts do not ask for. Logged as weak where the design changes; the owner culls.
