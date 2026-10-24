# Batch 75 generation log (producer h)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job). Each image was taken from the job's own session folder under `~/.codex/generated_images/<session_id>/` (the `session_id` field of get_job), never from the file a job named in its report: several reports named another session's file. The copy was checked by SHA-256 against the source and for duplicates across `tools/source_art/`. Each unit was viewed as a montage of its variants. The prompt of each job is the fenced entry in `tools/art_prompts/batch_75.md`, passed unchanged (the log does not repeat it).

## Summary (one line per image)

- `hud_minimap_unvisited_v1.png`: ok - flat slate stone disc with a dark recess, brass rim
- `hud_minimap_unvisited_v2.png`: ok - slate disc with brass rim; its job reported no image, its own folder holds the disc
- `hud_minimap_unvisited_v3.png`: ok - slate disc with a dark recess
- `hud_minimap_visited_v1.png`: weak - disc is warm brass-gold, not the pale straw wax asked for; kept for the cull
- `hud_minimap_visited_v2.png`: ok - pale wax disc with a soft honey glow; its job reported splashes (another session's file), not used
- `hud_minimap_visited_v3.png`: ok - pale wax disc with a soft honey glow
- `hud_minimap_current_v1.png`: ok - flat brass ring with a warm glow inside; its job reported a stone portal (another session's file), not used
- `hud_minimap_current_v2.png`: weak - brass ring, but a diffuse pink and yellow glow washes over the magenta background (the key), so the edge will key poorly
- `hud_minimap_current_v3.png`: ok - brass ring, a little larger than the others (kept)
- `hud_minimap_cave_mouth_v1.png`: ok - flat rock disc with a dark arch opening and violet light, moss rim
- `hud_minimap_cave_mouth_v2.png`: ok - rock disc with a violet arch; its job reported rocks (another session's file), not used
- `hud_minimap_cave_mouth_v3.png`: ok - rock disc with a violet arch and an amber rim; its job reported crystals (another session's file), not used
- `hud_minimap_shop_v1.png`: weak - brass disc with a compass rose, not an ochre awning with a coin
- `hud_minimap_shop_v2.png`: weak - same compass rose as v1; its job reported no image (the folder holds one, checked)
- `hud_minimap_shop_v3.png`: weak - leaf emblem on a brass disc, not an awning with a coin
- `hud_minimap_boss_v1.png`: ok - grey wax disc with a cold teal dot and brass rim; a little large
- `hud_minimap_boss_v2.png`: ok - grey disc with teal dot, clean
- `hud_minimap_boss_v3.png`: ok - grey disc with teal dot, ornate brass rim (kept)
- `hud_minimap_locked_v1.png`: ok - brass padlock, closed; its job reported a doorway medallion (another session's file), not used
- `hud_minimap_locked_v2.png`: ok - brass padlock, closed

## Details

### `hud_minimap_unvisited_v1.png`

- File: `tools/source_art/hud_minimap_unvisited_v1.png`
- Session ID: `01a16f68-ded4-7e90-8c6d-f4d8c79bde88`
- Generated file name: `exec-fa9ec2bb-df1d-4ffd-a7dc-a440cfb07d17.png`
- Source path copied from: `~/.codex/generated_images/01a16f68-ded4-7e90-8c6d-f4d8c79bde88/exec-fa9ec2bb-df1d-4ffd-a7dc-a440cfb07d17.png`
- Image size: 1536x1024
- SHA-256: `1386cfdf806d79e0fb4db7e807224c318287ec8c16cd8f71fbba60e08ab58518`
- Verdict: ok. flat slate stone disc with a dark recess, brass rim
- Attempts: 1 (no regeneration)

### `hud_minimap_unvisited_v2.png`

- File: `tools/source_art/hud_minimap_unvisited_v2.png`
- Session ID: `01a16f68-ded1-70e3-9302-1519a635f548`
- Generated file name: `exec-6fe1632e-71d2-403c-915c-d447d2a9a237.png`
- Source path copied from: `~/.codex/generated_images/01a16f68-ded1-70e3-9302-1519a635f548/exec-6fe1632e-71d2-403c-915c-d447d2a9a237.png`
- Image size: 1536x1024
- SHA-256: `915d1bd5b70784345fffdf724df306f74a070ff37aada52474e3009454fd244f`
- Verdict: ok. slate disc with brass rim; its job reported no image, its own folder holds the disc
- Attempts: 1 (no regeneration)

### `hud_minimap_unvisited_v3.png`

- File: `tools/source_art/hud_minimap_unvisited_v3.png`
- Session ID: `01a16f68-e2ec-7db1-8413-2c0d2a93ea0d`
- Generated file name: `exec-89cf5eb8-f804-4548-a9a6-9b36b787da8a.png`
- Source path copied from: `~/.codex/generated_images/01a16f68-e2ec-7db1-8413-2c0d2a93ea0d/exec-89cf5eb8-f804-4548-a9a6-9b36b787da8a.png`
- Image size: 1536x1024
- SHA-256: `139417be696f3c3babe930c78e8c4950420e9fe778c6db0dd4a4cfb71e4dee36`
- Verdict: ok. slate disc with a dark recess
- Attempts: 1 (no regeneration)

### `hud_minimap_visited_v1.png`

- File: `tools/source_art/hud_minimap_visited_v1.png`
- Session ID: `01a16f68-e8a6-7b73-a889-b5f386f32c50`
- Generated file name: `exec-fda99394-7fa4-4320-a93d-6e2eb7963f01.png`
- Source path copied from: `~/.codex/generated_images/01a16f68-e8a6-7b73-a889-b5f386f32c50/exec-fda99394-7fa4-4320-a93d-6e2eb7963f01.png`
- Image size: 1536x1024
- SHA-256: `bc4baf28a07dcea02f486af594baaefc98130d46be6289c9e953d80bbe489dd9`
- Verdict: weak. disc is warm brass-gold, not the pale straw wax asked for; kept for the cull
- Attempts: 1 (no regeneration)

### `hud_minimap_visited_v2.png`

- File: `tools/source_art/hud_minimap_visited_v2.png`
- Session ID: `01a16f68-ecc1-7c32-a0fe-f4d2586a1d70`
- Generated file name: `exec-30bab887-a27b-4f72-a490-8fd5c8332f7d.png`
- Source path copied from: `~/.codex/generated_images/01a16f68-ecc1-7c32-a0fe-f4d2586a1d70/exec-30bab887-a27b-4f72-a490-8fd5c8332f7d.png`
- Image size: 1536x1024
- SHA-256: `95b5c9fac3a04cf706552a87c2a76749e6a47d3a3c86835ca944426deaff7689`
- Verdict: ok. pale wax disc with a soft honey glow; its job reported splashes (another session's file), not used
- Attempts: 1 (no regeneration)

### `hud_minimap_visited_v3.png`

- File: `tools/source_art/hud_minimap_visited_v3.png`
- Session ID: `01a16f68-f34a-70e2-a416-92ac91619710`
- Generated file name: `exec-4705bb3f-84e2-4be8-9ad6-de01219f24bd.png`
- Source path copied from: `~/.codex/generated_images/01a16f68-f34a-70e2-a416-92ac91619710/exec-4705bb3f-84e2-4be8-9ad6-de01219f24bd.png`
- Image size: 1536x1024
- SHA-256: `493a963a4b7b2d84c44cbbb0e48750c934dbe4aab807762e78c3786dece4aac7`
- Verdict: ok. pale wax disc with a soft honey glow
- Attempts: 1 (no regeneration)

### `hud_minimap_current_v1.png`

- File: `tools/source_art/hud_minimap_current_v1.png`
- Session ID: `01a16f6b-9047-7c30-a3c9-108c9a5317ed`
- Generated file name: `exec-7565540c-4787-45a8-bba1-54cd34060a53.png`
- Source path copied from: `~/.codex/generated_images/01a16f6b-9047-7c30-a3c9-108c9a5317ed/exec-7565540c-4787-45a8-bba1-54cd34060a53.png`
- Image size: 1536x1024
- SHA-256: `aeffda51f42ae2ef3ad612bc39e01993b93fba2a594b0b15084f58325c4f6846`
- Verdict: ok. flat brass ring with a warm glow inside; its job reported a stone portal (another session's file), not used
- Attempts: 1 (no regeneration)

### `hud_minimap_current_v2.png`

- File: `tools/source_art/hud_minimap_current_v2.png`
- Session ID: `01a16f6b-92d0-7103-8f5b-ab50c1db508e`
- Generated file name: `exec-76a8ea91-9944-4421-a04c-86eb9f872b2b.png`
- Source path copied from: `~/.codex/generated_images/01a16f6b-92d0-7103-8f5b-ab50c1db508e/exec-76a8ea91-9944-4421-a04c-86eb9f872b2b.png`
- Image size: 1536x1024
- SHA-256: `43a6bcb88de6154a614ab539822c41f45bd89ff6fb5bb4fa0851a935092bf39a`
- Verdict: weak. brass ring, but a diffuse pink and yellow glow washes over the magenta background (the key), so the edge will key poorly
- Attempts: 1 (no regeneration)

### `hud_minimap_current_v3.png`

- File: `tools/source_art/hud_minimap_current_v3.png`
- Session ID: `01a16f6b-a4b0-7cc2-a9b0-377c7a1ec62d`
- Generated file name: `exec-204d96fe-e8c0-4128-80a8-0100f4dfe6bd.png`
- Source path copied from: `~/.codex/generated_images/01a16f6b-a4b0-7cc2-a9b0-377c7a1ec62d/exec-204d96fe-e8c0-4128-80a8-0100f4dfe6bd.png`
- Image size: 1536x1024
- SHA-256: `ed896f9d7bd0dddf409b05ccf0d29691dd1b32241be6ec375a7e6108676c9af6`
- Verdict: ok. brass ring, a little larger than the others (kept)
- Attempts: 1 (no regeneration)

### `hud_minimap_cave_mouth_v1.png`

- File: `tools/source_art/hud_minimap_cave_mouth_v1.png`
- Session ID: `01a16f6b-b068-7293-a64b-4665ef69eaf2`
- Generated file name: `exec-deebe571-483f-4854-ac69-3d56a317a499.png`
- Source path copied from: `~/.codex/generated_images/01a16f6b-b068-7293-a64b-4665ef69eaf2/exec-deebe571-483f-4854-ac69-3d56a317a499.png`
- Image size: 1536x1024
- SHA-256: `abce0e49ba255fde264e1d5a07030592ea1f6321282a81565b47eb2b5a80d862`
- Verdict: ok. flat rock disc with a dark arch opening and violet light, moss rim
- Attempts: 1 (no regeneration)

### `hud_minimap_cave_mouth_v2.png`

- File: `tools/source_art/hud_minimap_cave_mouth_v2.png`
- Session ID: `01a16f6b-b606-7bc3-8ab0-63dd8591896f`
- Generated file name: `exec-280e0f79-3732-4f8a-b9ad-e3fac9985479.png`
- Source path copied from: `~/.codex/generated_images/01a16f6b-b606-7bc3-8ab0-63dd8591896f/exec-280e0f79-3732-4f8a-b9ad-e3fac9985479.png`
- Image size: 1536x1024
- SHA-256: `3aaf235db2cd83d291700c8037bef968dceea7c3e3096ab8ce9993484c18798b`
- Verdict: ok. rock disc with a violet arch; its job reported rocks (another session's file), not used
- Attempts: 1 (no regeneration)

### `hud_minimap_cave_mouth_v3.png`

- File: `tools/source_art/hud_minimap_cave_mouth_v3.png`
- Session ID: `01a16f6b-ca4c-7192-8f14-43ffc93586e8`
- Generated file name: `exec-9f8b2c7d-d772-473e-8823-5974a93cba36.png`
- Source path copied from: `~/.codex/generated_images/01a16f6b-ca4c-7192-8f14-43ffc93586e8/exec-9f8b2c7d-d772-473e-8823-5974a93cba36.png`
- Image size: 1536x1024
- SHA-256: `cfe245f527e06cb653e2f069f4d391512cb4c1c6878ed64d1a0ae146c97df241`
- Verdict: ok. rock disc with a violet arch and an amber rim; its job reported crystals (another session's file), not used
- Attempts: 1 (no regeneration)

### `hud_minimap_shop_v1.png`

- File: `tools/source_art/hud_minimap_shop_v1.png`
- Session ID: `01a16f6d-e245-7a01-ac66-113248be8023`
- Generated file name: `exec-2b38d8b2-de08-4c57-a30d-88cf05b8a111.png`
- Source path copied from: `~/.codex/generated_images/01a16f6d-e245-7a01-ac66-113248be8023/exec-2b38d8b2-de08-4c57-a30d-88cf05b8a111.png`
- Image size: 1536x1024
- SHA-256: `91073a5cc6ce5bb1c1763c058fe2a5f4b8a8a04de7d358abb1abcd7f6f001a04`
- Verdict: weak. brass disc with a compass rose, not an ochre awning with a coin
- Attempts: 1 (no regeneration)

### `hud_minimap_shop_v2.png`

- File: `tools/source_art/hud_minimap_shop_v2.png`
- Session ID: `01a16f6d-e718-7102-bcfb-fcef439ab315`
- Generated file name: `exec-c4c707cd-ebd8-44c9-ace3-36b206eda371.png`
- Source path copied from: `~/.codex/generated_images/01a16f6d-e718-7102-bcfb-fcef439ab315/exec-c4c707cd-ebd8-44c9-ace3-36b206eda371.png`
- Image size: 1536x1024
- SHA-256: `1cf1fdc1e7a7c6bcefd3e14d61584ff2cc60faa1dc37999ed21889e65f030c00`
- Verdict: weak. same compass rose as v1; its job reported no image (the folder holds one, checked)
- Attempts: 1 (no regeneration)

### `hud_minimap_shop_v3.png`

- File: `tools/source_art/hud_minimap_shop_v3.png`
- Session ID: `01a16f6d-ec2d-7e11-8c47-3da91228fac3`
- Generated file name: `exec-a4eb8ae1-a534-4ea0-8458-34d2b4c90098.png`
- Source path copied from: `~/.codex/generated_images/01a16f6d-ec2d-7e11-8c47-3da91228fac3/exec-a4eb8ae1-a534-4ea0-8458-34d2b4c90098.png`
- Image size: 1536x1024
- SHA-256: `2c0b15a699e1b77a6e9983afc59e072e968b3f2d9a12ed0f78d13012589eb2f7`
- Verdict: weak. leaf emblem on a brass disc, not an awning with a coin
- Attempts: 1 (no regeneration)

### `hud_minimap_boss_v1.png`

- File: `tools/source_art/hud_minimap_boss_v1.png`
- Session ID: `01a16f6d-eea9-7bd2-8cef-9499818315ce`
- Generated file name: `exec-d8df181d-ae38-4e33-93ab-e37ef5a7ca55.png`
- Source path copied from: `~/.codex/generated_images/01a16f6d-eea9-7bd2-8cef-9499818315ce/exec-d8df181d-ae38-4e33-93ab-e37ef5a7ca55.png`
- Image size: 1536x1024
- SHA-256: `258512f15c327b51d37d57b171bf07cd1235da29372bfade07f88da68d4e3965`
- Verdict: ok. grey wax disc with a cold teal dot and brass rim; a little large
- Attempts: 1 (no regeneration)

### `hud_minimap_boss_v2.png`

- File: `tools/source_art/hud_minimap_boss_v2.png`
- Session ID: `01a16f6d-f7dc-75a3-85d5-0088760582ce`
- Generated file name: `exec-10db2492-0a97-4a6e-9f96-6d78621a4bdf.png`
- Source path copied from: `~/.codex/generated_images/01a16f6d-f7dc-75a3-85d5-0088760582ce/exec-10db2492-0a97-4a6e-9f96-6d78621a4bdf.png`
- Image size: 1536x1024
- SHA-256: `848ddf8e36c32a4cf3a8c2f32ffdd259871dd2ef705e3cb4e89183b1b4f9b542`
- Verdict: ok. grey disc with teal dot, clean
- Attempts: 1 (no regeneration)

### `hud_minimap_boss_v3.png`

- File: `tools/source_art/hud_minimap_boss_v3.png`
- Session ID: `01a16f6d-fd22-7972-996d-6f571a8f4405`
- Generated file name: `exec-51944741-e8a7-4f92-b1aa-bfa58a1d376e.png`
- Source path copied from: `~/.codex/generated_images/01a16f6d-fd22-7972-996d-6f571a8f4405/exec-51944741-e8a7-4f92-b1aa-bfa58a1d376e.png`
- Image size: 1536x1024
- SHA-256: `17d5866728836830b3c996a4d9b57c50e360d225d5c1075cc08a11e8d43b2d16`
- Verdict: ok. grey disc with teal dot, ornate brass rim (kept)
- Attempts: 1 (no regeneration)

### `hud_minimap_locked_v1.png`

- File: `tools/source_art/hud_minimap_locked_v1.png`
- Session ID: `01a16f70-22c9-7e63-a51d-179fb6212bc4`
- Generated file name: `exec-fb52883b-09d8-4dc5-a3f3-4c418352d758.png`
- Source path copied from: `~/.codex/generated_images/01a16f70-22c9-7e63-a51d-179fb6212bc4/exec-fb52883b-09d8-4dc5-a3f3-4c418352d758.png`
- Image size: 1536x1024
- SHA-256: `2630640115c8e4b25be9753d554746b73e489b171ab018c2deab0706a0201fef`
- Verdict: ok. brass padlock, closed; its job reported a doorway medallion (another session's file), not used
- Attempts: 1 (no regeneration)

### `hud_minimap_locked_v2.png`

- File: `tools/source_art/hud_minimap_locked_v2.png`
- Session ID: `01a16f70-2444-7cf0-a970-ce7b0870ef0c`
- Generated file name: `exec-d17d9675-c9f3-429d-8624-bf633b2b70e9.png`
- Source path copied from: `~/.codex/generated_images/01a16f70-2444-7cf0-a970-ce7b0870ef0c/exec-d17d9675-c9f3-429d-8624-bf633b2b70e9.png`
- Image size: 1536x1024
- SHA-256: `3504100726a9a546c2e6c0c13cee49750c389b04ab1e5baa71fb765e5b97322f`
- Verdict: ok. brass padlock, closed
- Attempts: 1 (no regeneration)

## Rejected attempts (not kept; the files stay in the local Codex folders)

- `hud_minimap_unvisited_v1`: job 01a16f643cef762daf219c8efe0049db ; session 01a16f64-41d2-7c62-881b-33cb1b26fb89 ; no usable file in the job report (concurrent outputs); reference items.png
- `hud_minimap_unvisited_v2`: job 01a16f643d4673c3aed8f1a24ad3913a ; session 01a16f64-437e-72d3-98f9-aab5bb39625f ; lit candle, not the tile; reference items.png
- `hud_minimap_unvisited_v3`: job 01a16f644136750a823bc5ccd6eaac6a ; session 01a16f64-46f1-7a92-b1b1-557a000248a4 ; lit bomb on a platform; reference items.png
- `hud_minimap_visited_v1`: job 01a16f6446d87f5eb5cef56a4e98a082 ; session 01a16f64-4ec5-7ea1-9e91-cd5fa8b47d39 ; moth with a glowing bulb tail; reference items.png
- `hud_minimap_visited_v2`: job 01a16f644c457f1ea44588900bcefe8a ; session 01a16f64-547d-7a10-aa12-521c4ad2b8be ; large moth with a glowing orb; reference items.png
- `hud_minimap_visited_v3`: job 01a16f6451d47ea4b3c9165e39b5e807 ; session 01a16f64-5a9d-7700-8f8d-620a6a5a1e41 ; lit bomb; reference items.png
- `hud_minimap_unvisited_v1`: job 01a16f66609b74f0a8f995ef2697deee ; session 01a16f66-6502-79e1-b54e-749e30bb6fe0 ; (retry 2) a small figure with a lantern; the tile subject was read as a character; no references
- `hud_minimap_unvisited_v2`: job 01a16f66669973a288988cc5c3cc3602 ; session 01a16f66-6b87-7903-8a07-1ca74884e51a ; (retry 2) a small figure with a lantern; same drift
- `hud_minimap_unvisited_v3`: job 01a16f666bbf746aaa4b88aa20c8102e ; session 01a16f66-713f-7210-a426-ce9e54ab6a69 ; (retry 2) job returned an empty result; no file to take
- `hud_minimap_visited_v1`: job 01a16f66717074f495d0643fdc34b582 ; session 01a16f66-8ab6-79e3-a81a-a745674ef223 ; (retry 2) a candle; the tile subject was read as an object
- `hud_minimap_visited_v2`: job 01a16f66a9cc7390b6df4653ad76c1ea ; session 01a16f66-a9cc-7390-b6df-4653ad76c1ea ; (retry 2) a lantern; the tile subject was read as an object
- `hud_minimap_visited_v3`: job 01a16f667c777ebdbee715c01c3f8fdb ; session 01a16f66-b505-7ff3-8f21-cdaf859bb32c ; (retry 2) molten furnace monsters; the job report wrong subject
- `hud_minimap_current_v1`: job 01a16f6456b17ca498d740085b44ad2c ; cancelled by the lead (seventh job in a wave, over the limit of six); no output
- `hud_minimap_current_v1`: job 01a16f68f25176cba5fa7e94c70307aa ; cancelled by the lead (seventh job in a wave); no output
- `hud_minimap_locked_v1`: job 01a16f6da3ff7cfcbfc372b76945330d ; cancelled by the lead (seventh job in a wave); no output

