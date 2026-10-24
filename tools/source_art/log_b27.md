# Batch 27 log (18 images)

Prompts: `tools/art_prompts/batch_27.md` (job id `b27_<output>` for each row). Backend codex, model `cheapest` (gpt-6-luna, effort medium), one image per job, 1536x1024. Each output is checked byte-identical (SHA-256) against its own session folder under `~/.codex/generated_images/<session>/`. No hash is duplicated in `tools/source_art/`. Verdicts are from viewing the montage; weak images are kept for the owner's cull. Run by producer a, 2026-10-24.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `heavy_stones_v1.png` | `b27_heavy_stones_v1` | `01a16f95-01c2-7d63-bf9f-3377d934afa8` | `exec-8b59d1ea-d5f1-4ec0-9888-9acd07e8b5c4.png` | 1536x1024 | `d1bfeb4232b383ff` | ok (1 + 3 states read clearly; dense foliage around the stones, not dark rock) |
| `heavy_stones_v2.png` | `b27_heavy_stones_v2` | `01a16f96-fb3c-7a73-ad62-409e9b0637f0` | `exec-0b4d432e-e7ce-4889-9fe9-17ea87c89dfa.png` | 1536x1024 | `8e41334f47f507f8` | weak (foliage and rock-wall framing around the stones, against the prompt) |
| `heavy_stones_v3.png` | `b27_heavy_stones_v3` | `01a16f96-fdab-7031-a325-763a4ea1dfd0` | `exec-7c313c17-321c-45cf-8fa3-246b64f96819.png` | 1536x1024 | `7b0e0358bdf3adb7` | weak (dark foliage and rock framing the top pose; broken poses keep large wall sides) |
| `resonance_stone_v1.png` | `b27_resonance_stone_v1` | `01a16f96-fbf2-7892-a0e5-2abd9d76ca62` | `exec-fac99a05-e996-4f5d-8153-45e96bc89c2c.png` | 1536x1024 | `7c70b601843564c8` | ok (dormant stone above four awake states; vegetation around the base) |
| `resonance_stone_v2.png` | `b27_resonance_stone_v2` | `01a16f96-fc11-7091-bf88-206df4a37439` | `exec-ae572709-190b-4053-a0c4-ca0b17c333a0.png` | 1536x1024 | `1e7e953011f41aa7` | weak (heavy moss, plants and flowers at the base; rings spread across the cells) |
| `resonance_stone_v3.png` | `b27_resonance_stone_v3` | `01a16f96-fbb8-7e43-9400-d0e153e54d62` | `exec-b9e6d095-230b-4bf9-880a-203e2d677fde.png` | 1536x1024 | `0b48b3907d1c3e61` | weak (first awake pose already has a broad, bright violet ring) |
| `resonance_door_v1.png` | `b27_resonance_door_v1` | `01a16f96-fb38-7d21-a5b1-6f083ecb571b` | `exec-dfa9350b-4a32-4c7c-8e87-19c2ac534e18.png` | 1536x1024 | `5810e9e8dd33cd44` | weak (open-state disc still partly in the doorway, not rolled aside) |
| `resonance_door_v2.png` | `b27_resonance_door_v2` | `01a16f9b-5247-77b2-a1c6-c013301d5194` | `exec-9f63b220-0837-4240-b547-9bd215616a8f.png` | 1536x1024 | `dc72914933d264a9` | ok (six poses in three rows; no visible defect in the job report) |
| `resonance_door_v3.png` | `b27_resonance_door_v3` | `01a16f9b-5272-7951-8cd6-ebbe854bb628` | `exec-dd47cf47-4cbb-4760-aa9f-fc1ed602371d.png` | 1536x1024 | `0577a25d61584d03` | ok (six poses in three rows; ring sequence and rolled-aside door readable) |
| `resonance_vault_v1.png` | `b27_resonance_vault_v1` | `01a16f9b-5747-7692-ac9b-b6ad104aed70` | `exec-898a90fd-dc6c-4297-9026-1e6e7fc7aafd.png` | 1536x1024 | `1b137cebb2d0c7f0` | weak (middle awake states, two and three rings, look alike; ring progression unclear) |
| `resonance_vault_v2.png` | `b27_resonance_vault_v2` | `01a16f9b-53ba-7661-9686-73095abf5c7d` | `exec-c59b34c8-812c-44b5-a2fc-063fcca74d46.png` | 1536x1024 | `fab45b86fb311fc1` | ok (six poses in 1/4/1 rows; the magenta reads bright pink) |
| `resonance_vault_v3.png` | `b27_resonance_vault_v3` | `01a16f9b-7ac8-7881-9edb-93cc606f20e9` | `exec-ffb237fa-a847-41b9-aef9-60d4d4bfd452.png` | 1536x1024 | `dee9d363bed1cb67` | ok (six states in 1/4/1 rows; nothing apparent) |
| `hidden_seam_v1.png` | `b27_hidden_seam_v1` | `01a16f9b-5504-7df1-a723-854f20468fa6` | `exec-3cf01f17-080f-4a92-922d-2458282fd4ac.png` | 1536x1024 | `a7a97a1f423084ea` | ok (four poses; the hidden pose's seam is a dark crack, not a faint scuff) |
| `hidden_seam_v2.png` | `b27_hidden_seam_v2` | `01a16f9f-5981-73e3-bcfb-76c899424a25` | `exec-4f8cd74f-7055-4f71-ab12-63cd8c669df1.png` | 1536x1024 | `aacc4a2272b26be3` | weak (prominent dark seam in the hidden pose; floor reads as raised paving slabs) |
| `hidden_seam_v3.png` | `b27_hidden_seam_v3` | `01a16f9f-82d2-7821-8512-79fc32c3ba4c` | `exec-528db8c5-7c23-48ad-8ba8-7bced9ad110f.png` | 1536x1024 | `a52272b59829822b` | weak (clearly visible central seam in the hidden pose, not a faint scuff) |
| `hidden_stairs_v1.png` | `b27_hidden_stairs_v1` | `01a16fa3-04e0-7353-be45-2e0449a95409` | `exec-28ef64ae-1bfb-4bde-99da-df794afd1410.png` | 1536x1024 | `41bbf3db797a19e2` | ok (slab slides from stairs to fully open; top slab boundary subtle; retry, see the attempt note) |
| `hidden_stairs_v2.png` | `b27_hidden_stairs_v2` | `01a16f9f-54d1-7c20-baea-ca85b6bedde2` | `exec-f35c2a9c-ec2b-4d6a-a66a-b5ba15521e2e.png` | 1536x1024 | `6a08cb2c01831de3` | weak (the three revealed poses look alike; weak progression) |
| `hidden_stairs_v3.png` | `b27_hidden_stairs_v3` | `01a16f9f-5c8d-7743-bb1b-d647cb0cc866` | `exec-b48f5d19-5d9e-4761-948d-fd81edc34290.png` | 1536x1024 | `834c164773ce2991` | weak (the three revealed poses look nearly identical) |

Failed attempt: `b27_hidden_stairs_v1`, first try (session `01a16f9f-7b55-7e60-8056-95f1e3f2249a`): the tool rejected the relative reference path (`AbsolutePathBuf deserialized without a base path`); no image was produced. Retried as `b27_hidden_stairs_v1-r1` with the absolute reference path (session `01a16fa3-04e0-7353-be45-2e0449a95409`), which is the file kept above.

Totals: 8 ok, 10 weak, 0 failed after retry (1 failed attempt, retried).

Note on the prompt text: the batch prompts ask for dark rock surroundings and a faint scuff in the hidden pose; the outputs often add foliage and show a stronger seam. These are logged as weak; the owner culls.
