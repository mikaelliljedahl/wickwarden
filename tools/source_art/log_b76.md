# Batch 76 generation log (producer h)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job). Each image was taken from the job's own session folder under `~/.codex/generated_images/<session_id>/` (the `session_id` field of get_job), never from the file a job named in its report: several reports named another session's file. The copy was checked by SHA-256 against the source and for duplicates across `tools/source_art/`. Each unit was viewed as a montage of its variants. The prompt of each job is the fenced entry in `tools/art_prompts/batch_76.md`, passed unchanged (the log does not repeat it).

## Summary (one line per image)

- `hud_minimap_locked_v3.png`: ok - brass padlock, closed; its job reported no image, its own folder holds the padlock
- `hud_minimap_pocket_v1.png`: ok - stone disc with a doorway arch and amber glint; its job reported no image (folder checked)
- `hud_minimap_pocket_v2.png`: ok - stone disc with a doorway arch and amber glint; its job reported paper monsters (another session's file), not used
- `hud_minimap_pocket_v3.png`: ok - stone disc with a doorway arch; its job reported a parchment sheet (another session's file), not used
- `hud_minimap_frame_v1.png`: ok - brass frame with rivets and an empty magenta-keyed opening; a faint pink tint at the inner edge
- `hud_minimap_frame_v2.png`: weak - brass frame with a magenta and white halo along the inner edge
- `hud_minimap_frame_v3.png`: ok - brass frame with rivets, clean opening
- `hud_status_band_v1.png`: ok - dark dusk stone band with two brass lines, full canvas (the code crops the strip from it); its job reported a frame (another session's file), not used
- `hud_status_band_v2.png`: weak - dark stone band with brass lines and a light spot on the left; full canvas
- `hud_status_band_v3.png`: failed - dark stone band with a white surround above and below, not full canvas; its job reported a frame (another session's file)
- `subscreen_panel_v1.png`: ok - dark dusk panel with a brass border and plain interior; its job reported compass medallions (another session's file), not used
- `subscreen_panel_v2.png`: weak - brass border with ornate medallions on the edges, not the plain panel asked for
- `subscreen_panel_v3.png`: ok - dark panel with a brass border, plain interior

## Details

### `hud_minimap_locked_v3.png`

- File: `tools/source_art/hud_minimap_locked_v3.png`
- Session ID: `01a16f70-2804-7a63-a73d-ae6b3e76fa18`
- Generated file name: `exec-814704f3-6a8e-407c-83ae-4e7a23a52715.png`
- Source path copied from: `~/.codex/generated_images/01a16f70-2804-7a63-a73d-ae6b3e76fa18/exec-814704f3-6a8e-407c-83ae-4e7a23a52715.png`
- Image size: 1536x1024
- SHA-256: `0f09e210808917bbbdbcd8cd4577ecaa02b142c000dfd1ff5c9cc16b8f6c01d6`
- Verdict: ok. brass padlock, closed; its job reported no image, its own folder holds the padlock
- Attempts: 1 (no regeneration)

### `hud_minimap_pocket_v1.png`

- File: `tools/source_art/hud_minimap_pocket_v1.png`
- Session ID: `01a16f70-2d39-7aa2-9811-ce531958f510`
- Generated file name: `exec-b551710a-9189-4fb7-b530-16824738ae35.png`
- Source path copied from: `~/.codex/generated_images/01a16f70-2d39-7aa2-9811-ce531958f510/exec-b551710a-9189-4fb7-b530-16824738ae35.png`
- Image size: 1536x1024
- SHA-256: `de4d8ebec90dcb108324f6a415eee56bd1cf6a22c21a60724a4214b77ae47ce1`
- Verdict: ok. stone disc with a doorway arch and amber glint; its job reported no image (folder checked)
- Attempts: 1 (no regeneration)

### `hud_minimap_pocket_v2.png`

- File: `tools/source_art/hud_minimap_pocket_v2.png`
- Session ID: `01a16f70-3219-7151-9b17-b325450bc829`
- Generated file name: `exec-84072807-b944-4bf8-b74a-cae7895b770d.png`
- Source path copied from: `~/.codex/generated_images/01a16f70-3219-7151-9b17-b325450bc829/exec-84072807-b944-4bf8-b74a-cae7895b770d.png`
- Image size: 1536x1024
- SHA-256: `8e42f67da94e1bfa9f2f512942d4eb6681406228b6b2748126f33761a0e5313f`
- Verdict: ok. stone disc with a doorway arch and amber glint; its job reported paper monsters (another session's file), not used
- Attempts: 1 (no regeneration)

### `hud_minimap_pocket_v3.png`

- File: `tools/source_art/hud_minimap_pocket_v3.png`
- Session ID: `01a16f70-37ed-7aa0-9421-18728b1f0925`
- Generated file name: `exec-ba2db1db-c3cd-4909-9b05-e21fe51274a0.png`
- Source path copied from: `~/.codex/generated_images/01a16f70-37ed-7aa0-9421-18728b1f0925/exec-ba2db1db-c3cd-4909-9b05-e21fe51274a0.png`
- Image size: 1536x1024
- SHA-256: `70221de933b8421eaaf0efd58d7f525faecbc88541fe121f5dcd79ba03c46708`
- Verdict: ok. stone disc with a doorway arch; its job reported a parchment sheet (another session's file), not used
- Attempts: 1 (no regeneration)

### `hud_minimap_frame_v1.png`

- File: `tools/source_art/hud_minimap_frame_v1.png`
- Session ID: `01a16f72-9a02-74c0-80ef-469c2ec2a899`
- Generated file name: `exec-0dc68f5f-1ecf-44b3-921c-a0953b21284a.png`
- Source path copied from: `~/.codex/generated_images/01a16f72-9a02-74c0-80ef-469c2ec2a899/exec-0dc68f5f-1ecf-44b3-921c-a0953b21284a.png`
- Image size: 1536x1024
- SHA-256: `e04ccdd1671ceb3dee7ad9897cd1bbdfae3936485766792c5a19ff6ca3ae4565`
- Verdict: ok. brass frame with rivets and an empty magenta-keyed opening; a faint pink tint at the inner edge
- Attempts: 1 (no regeneration)

### `hud_minimap_frame_v2.png`

- File: `tools/source_art/hud_minimap_frame_v2.png`
- Session ID: `01a16f72-9a3a-7710-871c-5bb2ffe26d5a`
- Generated file name: `exec-f1a1b9dc-8cd0-4f3f-a8be-890677e53dd9.png`
- Source path copied from: `~/.codex/generated_images/01a16f72-9a3a-7710-871c-5bb2ffe26d5a/exec-f1a1b9dc-8cd0-4f3f-a8be-890677e53dd9.png`
- Image size: 1536x1024
- SHA-256: `78a9336e2f5d91d3c1b1804c31e5c16ea279c95247a382dbfa2789e21c909528`
- Verdict: weak. brass frame with a magenta and white halo along the inner edge
- Attempts: 1 (no regeneration)

### `hud_minimap_frame_v3.png`

- File: `tools/source_art/hud_minimap_frame_v3.png`
- Session ID: `01a16f72-a08d-76c0-849f-fdabd1963fc1`
- Generated file name: `exec-659d201b-a00f-4a35-a3a5-0b3a97fda588.png`
- Source path copied from: `~/.codex/generated_images/01a16f72-a08d-76c0-849f-fdabd1963fc1/exec-659d201b-a00f-4a35-a3a5-0b3a97fda588.png`
- Image size: 1536x1024
- SHA-256: `1b2d5728878d12c7ff3a1a89c1aee97178d4b43e4c552604b9768572664a7066`
- Verdict: ok. brass frame with rivets, clean opening
- Attempts: 1 (no regeneration)

### `hud_status_band_v1.png`

- File: `tools/source_art/hud_status_band_v1.png`
- Session ID: `01a16f72-a66b-7470-acbe-6839043280c7`
- Generated file name: `exec-d2ec26d9-ee0d-47d5-8367-21dda5181d77.png`
- Source path copied from: `~/.codex/generated_images/01a16f72-a66b-7470-acbe-6839043280c7/exec-d2ec26d9-ee0d-47d5-8367-21dda5181d77.png`
- Image size: 1536x1024
- SHA-256: `8858449f088913772bcc20a646247bae6cf419b0415d718889eee3a1b1fb9d30`
- Verdict: ok. dark dusk stone band with two brass lines, full canvas (the code crops the strip from it); its job reported a frame (another session's file), not used
- Attempts: 1 (no regeneration)

### `hud_status_band_v2.png`

- File: `tools/source_art/hud_status_band_v2.png`
- Session ID: `01a16f72-aba0-7733-bd72-63cf610512b0`
- Generated file name: `exec-f9ece2d0-085b-4ddb-b746-014056a0095d.png`
- Source path copied from: `~/.codex/generated_images/01a16f72-aba0-7733-bd72-63cf610512b0/exec-f9ece2d0-085b-4ddb-b746-014056a0095d.png`
- Image size: 1536x1024
- SHA-256: `99da3a60e5b32c1273b2017f974f9b6d347be22174f2a624121d2a37038068ea`
- Verdict: weak. dark stone band with brass lines and a light spot on the left; full canvas
- Attempts: 1 (no regeneration)

### `hud_status_band_v3.png`

- File: `tools/source_art/hud_status_band_v3.png`
- Session ID: `01a16f72-b1f6-7aa0-a098-629092f79298`
- Generated file name: `exec-9d5ebfbb-9c5e-45e9-849a-53ea2a07a8ea.png`
- Source path copied from: `~/.codex/generated_images/01a16f72-b1f6-7aa0-a098-629092f79298/exec-9d5ebfbb-9c5e-45e9-849a-53ea2a07a8ea.png`
- Image size: 1536x1024
- SHA-256: `813702413fdc2e693b7abfe7cdf488017dc6335d3bc50d12ade6281e67a8bf65`
- Verdict: failed. dark stone band with a white surround above and below, not full canvas; its job reported a frame (another session's file)
- Attempts: 1 (no regeneration)

### `subscreen_panel_v1.png`

- File: `tools/source_art/subscreen_panel_v1.png`
- Session ID: `01a16f75-f5dc-7101-9181-fd4bcfe04b38`
- Generated file name: `exec-13cebfbb-bdbc-48fc-909c-69345dc7d3ce.png`
- Source path copied from: `~/.codex/generated_images/01a16f75-f5dc-7101-9181-fd4bcfe04b38/exec-13cebfbb-bdbc-48fc-909c-69345dc7d3ce.png`
- Image size: 1536x1024
- SHA-256: `53c19c8ef2d2e662e4ef7512be30c5a85281562a3e81c7e3457ef77528dafef3`
- Verdict: ok. dark dusk panel with a brass border and plain interior; its job reported compass medallions (another session's file), not used
- Attempts: 1 (no regeneration)

### `subscreen_panel_v2.png`

- File: `tools/source_art/subscreen_panel_v2.png`
- Session ID: `01a16f75-fbf4-7f62-a097-c0fcee94ad56`
- Generated file name: `exec-ec04decb-4c2a-47c9-99ee-29309b9b086e.png`
- Source path copied from: `~/.codex/generated_images/01a16f75-fbf4-7f62-a097-c0fcee94ad56/exec-ec04decb-4c2a-47c9-99ee-29309b9b086e.png`
- Image size: 1536x1024
- SHA-256: `6a462d85cf00e0e54d56883108a9f29c80bfe2ae88558472dfe12fca0009c2fb`
- Verdict: weak. brass border with ornate medallions on the edges, not the plain panel asked for
- Attempts: 1 (no regeneration)

### `subscreen_panel_v3.png`

- File: `tools/source_art/subscreen_panel_v3.png`
- Session ID: `01a16f76-204e-75b2-b0c7-128b382ec81b`
- Generated file name: `exec-eab9c313-c825-45a0-bb1c-72020cdfd4e4.png`
- Source path copied from: `~/.codex/generated_images/01a16f76-204e-75b2-b0c7-128b382ec81b/exec-eab9c313-c825-45a0-bb1c-72020cdfd4e4.png`
- Image size: 1536x1024
- SHA-256: `7e9eba228b8802c40666b905b1a4cb00dbdd6acc3fc9b5ac1831a4c298b0fd2f`
- Verdict: ok. dark panel with a brass border, plain interior
- Attempts: 1 (no regeneration)

