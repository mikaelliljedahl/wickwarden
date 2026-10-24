# Batch 39 log (15 images kept)

Prompts: `tools/art_prompts/batch_39.md` (job id in each heading). Backend codex, model `cheapest` (gpt-6-luna, effort medium), one image per job. Each output is checked byte-identical (SHA-256) against its own session folder under `~/.codex/generated_images/<session>/`. Verdicts: ok, weak (why), failed.

Reference images: `tools/source_art/ow_structures.png` (cottage, ledge), `tools/source_art/ow_props.png` (bells). No figure in this batch, so the facing and leg rule does not apply.

Rejected first attempts (not in the repository, the sheets had two buildings): the cottage prompt said "Exactly 1 pose" and then described a second design next to the hut, and all three sheets came back with two houses. Rejected sessions: `01a16f70-34a0-7952-b42a-26ba1485ba2f` (`exec-374ce437-9e89-41c0-a485-1941231b1174.png`, job `job_01a16f702f627a02b589a43dbbd5b388`), `01a16f70-3c2c-7fa2-a0c8-9095d0e4e2d5` (`exec-37f7b931-9190-49f2-8077-8b3161a0179a.png`, job `job_01a16f7035f7782bb17e1a95eccb8ee6`), `01a16f70-42d1-79e0-8297-aeb059a00842` (`exec-e9a32d9f-649e-4c0b-b934-777b4c59c0bd.png`, job `job_01a16f703ccd76ffa4a679a522158fb3`). The prompt was corrected to "one small village cottage ... single building only" and the three cottage units were regenerated as `-r1` jobs; the rows below are the `-r1` sheets. The batch file carries the corrected text.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `cottage_v1.png` | `job_01a16f71c10b7dd3ade2a6410c404c46` | `01a16f71-c615-7041-8f05-1e8b52cfa86a` | `exec-2c7f9a92-46d2-48ab-8dee-a112582c5e6a.png` | 1536x1024 | `13aa5adc42a60555` | ok (retry: one stone cottage with lit window and lantern; larger than a small cottage) |
| `cottage_v2.png` | `job_01a16f71c43877bf9cb493283605a737` | `01a16f71-c968-7e31-8278-3ce9254134ff` | `exec-44b2f26d-ad96-49aa-90d6-0cc2f04dbe2e.png` | 1536x1024 | `df68d4b4f1ad8e92` | ok (retry: one cottage, lantern by the door, window; nearly fills the width) |
| `cottage_v3.png` | `job_01a16f71ca767aeba54d4719d272dd80` | `01a16f71-cfb1-7bb2-b028-cb1c0bc42498` | `exec-d3b3941d-f7b8-411d-b4d8-099db39316f0.png` | 1536x1024 | `4d66f9e7a502ac2a` | ok (retry: one cottage with a lit window and a lantern; a little lush) |
| `bell_1_v1.png` | `job_01a16f71d1097304ac044f79ad8c034f` | `01a16f71-d59c-7783-bfc1-c2b8d33f3184` | `exec-a78653b0-8130-4f27-accd-69ec805791d3.png` | 1536x1024 | `ebce20ac2cd25df9` | ok (bronze bell hung in a timber frame on stone bases) |
| `bell_1_v2.png` | `job_01a16f71d77b78729bc42c1374e4c8d5` | `01a16f72-5c74-76a0-9354-9c13c2580314` | `exec-2268e993-b473-4449-ab6d-4e1624e2e4b3.png` | 1536x1024 | `96d901f15f1ef516` | ok (bell in a timber frame with rusted straps and braces) |
| `ledge_drop_v1.png` | `job_01a16f70434a7f41a580b38b4d357ce1` | `01a16f70-4909-7f70-9b5b-eb072b87d62c` | `exec-89b44061-6f86-4bb4-91a8-c2b717874719.png` | 1536x1024 | `7b39f63ed439a059` | ok (straight rim and outer corner, both separated; shadow under the lip) |
| `ledge_drop_v2.png` | `job_01a16f704a5274398c7e156f712dacdb` | `01a16f70-4eec-7d11-a8b2-34e205a6e74e` | `exec-92695a3a-c306-48e4-9517-2c2cb1600669.png` | 1536x1024 | `f58fdc8a21ceefb2` | ok (straight rim and outer corner; flowers on top not in the prompt) |
| `ledge_drop_v3.png` | `job_01a16f70507a77b6bc3d8ac9bb4b8a4c` | `01a16f70-824d-7432-92c1-13ec36298af4` | `exec-515c5be5-8826-4ab3-8b29-dfb42224e77d.png` | 1536x1024 | `183812707e26f701` | ok (straight rim and outer corner; shadow under the lip) |
| `ledge_drop_v3.png` | `job_01a16f70507a77b6bc3d8ac9bb4b8a4c` | `01a16f70-824d-7432-92c1-13ec36298af4` | `exec-515c5be5-8826-4ab3-8b29-dfb42224e77d.png` | 1536x1024 | `183812707e26f701` | ok (straight rim and outer corner; shadow under the lip) |
| `bell_1_v3.png` | `job_01a16f733af37144847b245aad34509a` | `01a16f74-076a-7b52-aea5-89af92b368e5` | `exec-bd42ac45-0587-4ef2-ae85-ad24291cbe7e.png` | 1536x1024 | `176bd7b9fa769e0c` | ok (bell in timber frame; vines and stone footings at the bases) |
| `bell_2_v1.png` | `job_01a16f7341c27b71bf15bd4cfcb52d5a` | `01a16f74-38f1-71d1-8178-5b8f9da50a08` | `exec-75dcae48-04bc-4a0d-8121-b48df6f65b66.png` | 1536x1024 | `2065a145e8059666` | ok (five organ pipes with mouths and a small bell; foliage on the base) |
| `bell_2_v2.png` | `job_01a16f7349ae70f793f26a694f96691b` | `01a16f74-687d-7d92-be37-afc1c159ed2c` | `exec-6c4fbb84-6d6d-40e3-98ab-d6cd44b7b957.png` | 1536x1024 | `136827b6fa8c01da` | ok (five pipes and a bell; the background reads pink in the report, pixels are key-coloured) |
| `bell_2_v3.png` | `job_01a16f734f5e7fb69d40d4ec9b3a180e` | `01a16f74-737c-71c1-9dac-350be6e6d3c6` | `exec-b65ad8b5-e269-4f69-8c31-07a75b6ebe0b.png` | 1536x1024 | `dcb0de443a2ed125` | ok (organ pipes and a bell; some vines around the pipes) |
| `bell_3_v1.png` | `job_01a16f7355697048b0585a1689bf681a` | `01a16f74-7940-7192-ac40-a69910408c8f` | `exec-f88f83b1-293e-4206-a936-e7adccb25596.png` | 1536x1024 | `30e8ef9344a75e48` | weak (round brass disk reads as a gong or shield, not a bell; pipes brass, not tin) |
| `bell_3_v2.png` | `job_01a16f736a597f83a837311dc67cde62` | `01a16f74-8387-7e53-abe4-47bcf6d9e1af` | `exec-74207bf9-0c6d-41c2-bdfa-864dfeb9a92a.png` | 1536x1024 | `c0f1a23625b44c2a` | weak (round brass disk reads as a gong or shield, not a bell; pipes brass, not tin) |
| `bell_3_v3.png` | `job_01a16f7557307a21896e3e185f918886` | `01a16f76-d96b-7db1-b219-ccad8199b719` | `exec-3421f318-2f34-49a0-b44a-66424e57d9b7.png` | 1536x1024 | `6ae9755e8a112040` | weak (round brass disk reads as a gong with a crank, not a bell; pipes brass, not tin) |


## Batch 39 totals

15 images kept and verified (SHA-256 matches the own-session folder for every file; no duplicate hashes in `tools/source_art/`).
Ok: 12 (`cottage` v1 to v3 (retries), `ledge_drop` v1 to v3, `bell_1` v1 to v3, `bell_2` v1 to v3).
Weak: 3 (`bell_3` v1 to v3: the round brass disk reads as a gong or shield with a crank, not a bell; the pipes are brass rather than tin).
Failed: 0 kept (three first attempts of `cottage` rejected and regenerated, see above).
