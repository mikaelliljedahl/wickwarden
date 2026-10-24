# Batch 38 log (18 images)

Prompts: `tools/art_prompts/batch_38.md` (job id in each heading). Backend codex, model `cheapest` (gpt-6-luna, effort medium), one image per job. Each output is checked byte-identical (SHA-256) against its own session folder under `~/.codex/generated_images/<session>/`. Verdicts: ok, weak (why), failed.

Reference images: `tools/source_art/ow_props.png` (lantern post, salt, driftwood, well, haystack). No figure in this batch, so the facing and leg rule does not apply.

Job events: two driftwood and one haystack job still showed `running` after their PNG was in place; the PNG was checked against the own-session file and the job was stopped after its copy was verified.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `rusted_lantern_post_v1.png` | `job_01a16f6bee117eb6a8d684caa11e2fe9` | `01a16f6c-22c3-7492-991c-38b20c8de96d` | `exec-06816037-dfc0-4b9a-992e-fd96a3c5a35d.png` | 1536x1024 | `d449f55d26848898` | weak (glass panes and gold roof, not an empty dark housing; ivy and rocks at the base) |
| `rusted_lantern_post_v2.png` | `job_01a16f6bf4b47b5895a83c39fd5b7fe2` | `01a16f6c-29de-77a3-9b09-2402b1724d94` | `exec-cde014a9-3069-4594-bdb4-b96696498baf.png` | 1536x1024 | `71a2731ac499f2ff` | weak (glass lantern and leafy base, more elaborate than a plain iron post) |
| `rusted_lantern_post_v3.png` | `job_01a16f6bfc677369a067a031b6e185ca` | `01a16f6c-4cf8-7c60-9eb5-a73948f72323` | `exec-a2abb2b0-aef1-49e7-a7ad-eb14bf5f65a6.png` | 1536x1024 | `fcf0490d6298af31` | weak (magenta tint in the glass panes, which cuts as holes; stone base with foliage) |
| `salt_crystals_1_v1.png` | `job_01a16f6c02a676de8c9152e6227f1618` | `01a16f6c-4f95-7f82-87c9-ce420a2042f0` | `exec-af255d28-c16b-43f5-bdda-fdbf6ac959d6.png` | 1536x1024 | `0f0f7fb062a5fa7c` | ok (angular crystals on a dirt crust) |
| `salt_crystals_1_v2.png` | `job_01a16f6c09557cf684e1184054f96ef6` | `01a16f6c-6a9f-7433-bed4-7e0957497ba6` | `exec-09b72f65-0e29-4e32-be05-39c0fb441319.png` | 1536x1024 | `452b6e9ed9461b27` | ok (cream crystals with a warm lit face) |
| `salt_crystals_1_v3.png` | `job_01a16f6c0faf72cfb106a13fe83897c7` | `01a16f6c-5a58-76e1-9d39-155a7d301bfd` | `exec-f5073fe0-51a6-428f-a2a3-ce92c4fe3f2e.png` | 1536x1024 | `0f929330ef601bbb` | ok (crystal cluster on rock, centred) |
| `salt_crystals_2_v1.png` | `job_01a16f6d5d1675b884134a3aedf71c6c` | `01a16f6d-64fd-78a2-b580-da8c3de1facf` | `exec-0da645e7-2d69-42d2-8cad-6df2ed90943c.png` | 1536x1024 | `1f77cb3054d2cd48` | weak (angular pointed spikes; the brief asks for rounded and cloudy crystals) |
| `salt_crystals_2_v2.png` | `job_01a16f6d626c7b0aa6d589094b5d77c8` | `01a16f6d-792a-7cc2-87b1-c688695fa1c3` | `exec-7908b78c-38f8-4d5b-b168-d9bdfaf0515d.png` | 1536x1024 | `a5b3f0a5781ee8bb` | weak (angular and chunky, not rounded and cloudy) |
| `salt_crystals_2_v3.png` | `job_01a16f6d6b077c6a8a79598f60d811b7` | `01a16f6d-7f19-79d0-bf25-6422e3192c8d` | `exec-5fca0341-2c49-48ab-b46c-db9d3813226b.png` | 1536x1024 | `2cef9c6c55b22c73` | ok (cloudy rounded clusters with two taller spikes) |
| `driftwood_net_v1.png` | `job_01a16f6d7006733a8ed833fc9bd14880` | `01a16f6d-df77-7a50-b152-b84dcc60e9bc` | `exec-cb8b1d81-e7bf-4dc4-8f31-44edf90ced9e.png` | 1536x1024 | `d73bfa1d2a19ba26` | ok (driftwood pile with a net and cork floats; a few green sprigs) |
| `driftwood_net_v2.png` | `job_01a16f6d769170a5a8b0f123a190bd79` | `01a16f6d-dfc5-7941-85d8-7271d9edf5f9` | `exec-c4e76744-e6d1-4cd4-a1d9-32689ef07c54.png` | 1536x1024 | `ceadd861870ec564` | ok (logs under a net with cork floats) |
| `driftwood_net_v3.png` | `job_01a16f6d7de47e2ca268ba3bfc7f43fc` | `01a16f6d-e1b5-7a11-8e9f-0eab3ea25624` | `exec-957011cc-9db3-4e09-bf28-7ac7392c046a.png` | 1536x1024 | `3144e0aedac43a86` | ok (driftwood and net pile, uncropped) |
| `village_well_v1.png` | `job_01a16f6ee4fe75379570bfed6e30ef43` | `01a16f6e-eb60-7920-8268-851d7b7d9469` | `exec-6311b950-9e93-4982-9ea2-587fa6f3603c.png` | 1536x1024 | `c6ee2766d50c625e` | ok (well with roof, crank and bucket; extra greenery and flowers, roof a little large) |
| `village_well_v2.png` | `job_01a16f6ee854747b8216bb044d61c328` | `01a16f6e-ecf0-73d3-9fb6-c13cff86a239` | `exec-b669de92-01d6-41ad-9d30-3cbe5f276a58.png` | 1536x1024 | `15832ba632f41269` | ok (well with plank roof, rope on the crank, bucket) |
| `village_well_v3.png` | `job_01a16f6eee4f71cea458f00d05d69e6f` | `01a16f6e-f376-7910-8378-f6916247fcb1` | `exec-af0f91da-d89a-4817-9021-225acc6fb7fe.png` | 1536x1024 | `05b0ec21a0292cc0` | ok (well with plank roof and bucket on a stone ring) |
| `haystack_v1.png` | `job_01a16f6ef4a370669065eac606cc1305` | `01a16f6e-fa03-7a81-8bee-397e253d25f6` | `exec-00ee85af-84d8-4b7f-9f25-63df33292f5d.png` | 1536x1024 | `9ee95e1331a84845` | ok (round straw stack with two rope bands) |
| `haystack_v2.png` | `job_01a16f6efb2477679477da775e801d84` | `01a16f6f-00a2-7ef0-9b02-d13078df88e9` | `exec-c3a9df3b-ab8c-4ffa-9e58-872f779f1181.png` | 1536x1024 | `210be2ec38c61813` | ok (round straw stack, two rope bands, bound top) |
| `haystack_v3.png` | `job_01a16f6f01267cdfac2ba98b29dbdc9b` | `01a16f6f-0698-7b11-92aa-89f2fd173e6b` | `exec-519765e8-c29e-4f42-b38a-345c97a9d9a1.png` | 1536x1024 | `86f017175c57c5cb` | ok (straw stack with rope bands; the loose tuft at the foot is faint) |


## Batch 38 totals

18 images verified (SHA-256 matches the own-session folder for every file; no duplicate hashes in `tools/source_art/`).
Ok: 13 (`salt_crystals_1` v1 to v3, `salt_crystals_2` v3, `driftwood_net` v1 to v3, `village_well` v1 to v3, `haystack` v1 to v3).
Weak: 5 (`rusted_lantern_post` v1 to v3: glass panes or gold roof instead of an empty dark housing, ivy and stone bases; v3 has magenta showing through the glass, which the cut will read as holes; `salt_crystals_2` v1 and v2: angular and pointed, not rounded and cloudy).
Failed: 0.
