# Batch 37 log (18 images)

Prompts: `tools/art_prompts/batch_37.md` (job id in each heading). Backend codex, model `cheapest` (gpt-6-luna, effort medium), one image per job. Each output is checked byte-identical (SHA-256) against its own session folder under `~/.codex/generated_images/<session>/`. Verdicts: ok, weak (why), failed.

Reference images: `tools/source_art/ow_props.png` (wax vats, pipe, lily pads, shipwrecks). No figure in this batch, so the facing and leg rule does not apply.

Job events: `wax_vat_2_v3` (first job) failed: the image call broke while attaching the reference image, no file was made; resubmitted as `ww-b37-wax_vat_2-v3-r1` (job `job_01a16f67ca297489b581d10a0fcd56a8`), which produced the file in the table.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `wax_vat_1_v1.png` | `job_01a16f552a16716db1a8ac1a39aee38b` | `01a16f55-2fe5-7cb2-9058-5ebdd562e5fd` | `exec-5936bce8-7c7f-42a8-99a6-b3d8dba24d70.png` | 1536x1024 | `9d97486ea1a0858e` | ok (domed lid, wax drips, brass tap; one vat, uncropped) |
| `wax_vat_1_v2.png` | `job_01a16f552a5270ef890a602f2188a899` | `01a16f55-31bb-7c41-bee8-d283c4f8f8f8` | `exec-0dc9f35d-b605-40ab-96ce-b7f01a596b24.png` | 1536x1024 | `20c39315d149da3a` | ok (domed lid with knob, wax drips, brass tap) |
| `wax_vat_1_v3.png` | `job_01a16f552cca77608596377108b9eb9e` | `01a16f55-328f-7990-914b-decf4ada4f4a` | `exec-5cb44bd3-9f10-4796-9bfb-1c487677216d.png` | 1536x1024 | `b760e2f8a91ae4ce` | ok (domed lid, lighter wax, brass tap) |
| `wax_vat_2_v1.png` | `job_01a16f55340e76a9b5b8e6240b2a6529` | `01a16f55-39c2-7631-95d7-8933bdbd4e56` | `exec-7cbd2647-5986-41ad-b3a2-bab692ef84ca.png` | 1536x1024 | `d08ca12888d5b42d` | ok (tall oval tank on four legs, ladle, brass tap) |
| `wax_vat_2_v2.png` | `job_01a16f553add7d96b5536726278eb2ad` | `01a16f55-4008-74b1-aa84-0a699f23d80c` | `exec-296d0cfd-8fba-46f9-a375-4ccac0ff0a0d.png` | 1536x1024 | `aa1f79224c098890` | ok (tall tank, flat lid with wax rim, ladle hung on side) |
| `wax_vat_2_v3.png` | `job_01a16f67ca297489b581d10a0fcd56a8` | `01a16f67-cf43-7f81-8651-fbd7e194bcf0` | `exec-d5502dd8-ff42-440c-b6e6-ee50504384e1.png` | 1536x1024 | `54f17a9b4facd4e1` | ok (retry of failed r0; tall tank, ladle, legs; uncropped) |
| `wax_vat_pipe_v1.png` | `job_01a16f67f526734ab3f104cc9054a390` | `01a16f67-fa77-7f12-bc72-0a2d73d4b247` | `exec-cc000da4-7c4f-4070-8243-bda9431e0507.png` | 1536x1024 | `683e3f94cba8702a` | ok (elbow pipe with two flanges, wax drips) |
| `wax_vat_pipe_v2.png` | `job_01a16f67f9957793a1cd5ae78f95aa8a` | `01a16f68-014e-7af1-b36d-5d4e89552d0e` | `exec-67ec64ea-b04b-46eb-9c82-b63071203662.png` | 1536x1024 | `7c877379c0338e9a` | ok (elbow pipe, one flange open, wax on the bend) |
| `wax_vat_pipe_v3.png` | `job_01a16f6800af7d90848e7ebcdeb5e6c1` | `01a16f68-0836-7cd3-a145-77517bc4b818` | `exec-d7922eb0-3597-4485-8108-e2c616b6c188.png` | 1536x1024 | `7d277ca9ca1b022f` | ok (elbow pipe, wide flange and wax crust) |
| `lily_pads_v1.png` | `job_01a16f680766742fa225e92026b9a42f` | `01a16f68-0cbd-7de3-beba-a337fb3ab3a1` | `exec-781b087e-9357-429c-8cea-00270c74af24.png` | 1536x1024 | `3c5cb25b07ffc239` | ok (three poses, one bud each; pose 2 lifted; poses 1 and 3 close) |
| `lily_pads_v2.png` | `job_01a16f680dfd7b8c80a8415e61ca274e` | `01a16f68-6cba-7b61-a60f-c0b3e5ee15aa` | `exec-d46352f0-d284-48d9-9d60-3cc51c1dfcb9.png` | 1536x1024 | `f46ef99bb50aa8ac` | ok (three poses, pads turned, one lifted edge each) |
| `lily_pads_v3.png` | `job_01a16f69979a7b0cafb0ee569a7a4a3c` | `01a16f69-c0bb-74e3-ab5f-e4df292924af` | `exec-1c5a5a8e-a73d-4246-9636-2d05ada06a69.png` | 1536x1024 | `3805f11480ee3af1` | ok (three poses; pads more saturated than asked, poses 1 and 3 close) |
| `shipwreck_1_v1.png` | `job_01a16f699b51747a8cecf89c43346b08` | `01a16f69-c28a-7a62-92bb-f5363bcff1fd` | `exec-dc690a88-cd5d-4b39-8df4-23fec2324d7b.png` | 1536x1024 | `2cc9dc3be1a3a78e` | ok (hull on its side, ribs and torn sail; fills most of the canvas) |
| `shipwreck_1_v2.png` | `job_01a16f69a2527ab0ae0328b64320ac25` | `01a16f69-ce4c-7ee0-91b5-447881f2d2b1` | `exec-20eaafe4-6017-48e7-91a4-7ef32e0d63d0.png` | 1536x1024 | `52b15f29b2c718fd` | ok (hull with broken ribs and a rag sail; reads as a wreck) |
| `shipwreck_1_v3.png` | `job_01a16f69a8ce7bea8543ef80291758e8` | `01a16f69-e56d-7720-b004-24cf42185fcd` | `exec-22bbaebf-02c9-434c-8e2d-22273a4f35f1.png` | 1536x1024 | `6ab4fb683a3ea7ae` | weak (magenta shows through holes in the sail; the hull reads upright, not on its side) |
| `shipwreck_2_v1.png` | `job_01a16f69b0077449b7d4299c6be7ca06` | `01a16f69-f7ad-7370-ac3c-fd39be5386fe` | `exec-42ae685a-dfbc-416c-8601-8567cf5b9bcb.png` | 1536x1024 | `604e0712cfeb1fe9` | weak (sand patch and rocks drawn under the wreck, against the no-floor rule) |
| `shipwreck_2_v2.png` | `job_01a16f69b5bf7d0f8126294859af342b` | `01a16f6a-26e1-7180-8a31-87af9a294c3e` | `exec-e43bfd6f-c302-4c86-9ea2-c292a64387fe.png` | 1536x1024 | `e1ead086f1ee876f` | weak (sand patch and rocks drawn under the wreck; the job reported no defects, the view shows them) |
| `shipwreck_2_v3.png` | `job_01a16f6add707d47bfb687debefa2dbf` | `01a16f6a-e44e-71c3-be89-d664862578fb` | `exec-99911566-f5b0-4c30-8448-05d067659304.png` | 1536x1024 | `32edeb9c5e48600d` | ok (rocks and moss piled at the base; no sand patch) |


## Batch 37 totals

18 images verified (SHA-256 matches the own-session folder for every file; no duplicate hashes in `tools/source_art/`).
Ok: 15 (`wax_vat_1` v1 to v3, `wax_vat_2` v1 to v3, `wax_vat_pipe` v1 to v3, `lily_pads` v1 to v3, `shipwreck_1` v1 and v2, `shipwreck_2` v3).
Weak: 3 (`shipwreck_1` v3: magenta shows through the sail holes and the hull reads upright; `shipwreck_2` v1 and v2: sand patch and rocks drawn under the wreck, against the no-floor rule; the job of v2 reported no defects, the view shows them).
Failed: 0 final (one first attempt, `wax_vat_2_v3`, failed at the reference attach and was replaced by `-r1`).
