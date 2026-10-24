# Batch 77 generation log (producer h)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job). Each image was taken from the job's own session folder under `~/.codex/generated_images/<session_id>/` (the `session_id` field of get_job), never from the file a job named in its report: several reports named another session's file. The copy was checked by SHA-256 against the source and for duplicates across `tools/source_art/`. Each unit was viewed as a montage of its variants. The prompt of each job is the fenced entry in `tools/art_prompts/batch_77.md`, passed unchanged (the log does not repeat it).

## Summary (one line per image)

- `subscreen_slot_empty_v1.png`: ok - brass square frame with rivets and a dark slate empty recess
- `subscreen_slot_empty_v2.png`: ok - brass square frame, dark slate recess
- `subscreen_slot_empty_v3.png`: ok - brass square frame, dark slate recess; its job reported stone busts (another session's file), not used
- `subscreen_slot_selected_v1.png`: ok - brass frame with a warm amber rim and a lighter straw recess
- `subscreen_slot_selected_v2.png`: ok - brass frame with amber rim and lighter straw recess; its job reported several figures (another session's file), not used
- `subscreen_slot_selected_v3.png`: ok - brass frame with amber rim and straw recess; its job reported no image (folder holds the frame)
- `subscreen_slot_locked_v1.png`: ok - dark featureless sack silhouette in a brass slot; its job reported a dragon (another session's file), not used
- `subscreen_slot_locked_v2.png`: ok - dark silhouette in a brass slot
- `subscreen_slot_locked_v3.png`: ok - dark featureless sack silhouette in a brass slot
- `subscreen_cursor_v1.png`: ok - three amber teardrop flames in a row on magenta (the three poses differ in lean)
- `subscreen_cursor_v2.png`: weak - three flames, with small detached flecks around the main flames
- `subscreen_cursor_v3.png`: ok - three flames; the file is byte-identical to tools/source_art/lock_warden_body_closed_open_v3.png (another producer's file), which is therefore a wrong copy of this sheet; that file is not changed here
- `pause_panel_v2.png`: ok - dark panel with a brass border and plain interior
- `pause_panel_v1.png`: ok - dark slate panel with a brass border, plain interior; its job reported no result (folder holds the panel)
- `pause_panel_v3.png`: ok - dark slate panel with brass border; the first pause v3 job was cancelled by the lead (see the rejects), the retry is kept

## Details

### `subscreen_slot_empty_v1.png`

- File: `tools/source_art/subscreen_slot_empty_v1.png`
- Session ID: `01a16f76-9826-77e3-8410-84471f90e954`
- Generated file name: `exec-786b6a5e-0f6f-494f-b64c-c6c54c2b7288.png`
- Source path copied from: `~/.codex/generated_images/01a16f76-9826-77e3-8410-84471f90e954/exec-786b6a5e-0f6f-494f-b64c-c6c54c2b7288.png`
- Image size: 1536x1024
- SHA-256: `28a671cdee55a35fc9b3de8a173978e03038de1b8bd6b7fd0302d5bb1a1e1b89`
- Verdict: ok. brass square frame with rivets and a dark slate empty recess
- Attempts: 1 (no regeneration)

### `subscreen_slot_empty_v2.png`

- File: `tools/source_art/subscreen_slot_empty_v2.png`
- Session ID: `01a16f76-bb21-7170-926a-a3a756656590`
- Generated file name: `exec-63b06322-e1e6-4b86-aa33-8d58f50230ce.png`
- Source path copied from: `~/.codex/generated_images/01a16f76-bb21-7170-926a-a3a756656590/exec-63b06322-e1e6-4b86-aa33-8d58f50230ce.png`
- Image size: 1536x1024
- SHA-256: `15df7a4946f51296f8d1083dfc137687ebac5e6f3ecebf03ecefbbdd97165138`
- Verdict: ok. brass square frame, dark slate recess
- Attempts: 1 (no regeneration)

### `subscreen_slot_empty_v3.png`

- File: `tools/source_art/subscreen_slot_empty_v3.png`
- Session ID: `01a16f76-bdb9-7690-8c0b-1a1c18ddc7de`
- Generated file name: `exec-9c70ee31-2e6a-47da-ba80-d34387b51ead.png`
- Source path copied from: `~/.codex/generated_images/01a16f76-bdb9-7690-8c0b-1a1c18ddc7de/exec-9c70ee31-2e6a-47da-ba80-d34387b51ead.png`
- Image size: 1536x1024
- SHA-256: `609f137f2899dacd2f046ba28a52797c4a41a188db31e1a50f70f72a8b8a325a`
- Verdict: ok. brass square frame, dark slate recess; its job reported stone busts (another session's file), not used
- Attempts: 1 (no regeneration)

### `subscreen_slot_selected_v1.png`

- File: `tools/source_art/subscreen_slot_selected_v1.png`
- Session ID: `01a16f78-44b6-7381-9245-4ec8fa6ee1ad`
- Generated file name: `exec-3246f68f-cadb-444e-82df-5ef860efd513.png`
- Source path copied from: `~/.codex/generated_images/01a16f78-44b6-7381-9245-4ec8fa6ee1ad/exec-3246f68f-cadb-444e-82df-5ef860efd513.png`
- Image size: 1536x1024
- SHA-256: `77109199cb5c695e485f1a51782817618d055840578721c749bc041f804cca00`
- Verdict: ok. brass frame with a warm amber rim and a lighter straw recess
- Attempts: 1 (no regeneration)

### `subscreen_slot_selected_v2.png`

- File: `tools/source_art/subscreen_slot_selected_v2.png`
- Session ID: `01a16f78-81ea-7202-b9fc-ab339526ac46`
- Generated file name: `exec-e0923cb7-9c3e-445d-b63c-af32f1acfab6.png`
- Source path copied from: `~/.codex/generated_images/01a16f78-81ea-7202-b9fc-ab339526ac46/exec-e0923cb7-9c3e-445d-b63c-af32f1acfab6.png`
- Image size: 1536x1024
- SHA-256: `8a0fc0db7eda5ed0adaeb33b75ca02ff3bce5a055906c056d3138853d07b0882`
- Verdict: ok. brass frame with amber rim and lighter straw recess; its job reported several figures (another session's file), not used
- Attempts: 1 (no regeneration)

### `subscreen_slot_selected_v3.png`

- File: `tools/source_art/subscreen_slot_selected_v3.png`
- Session ID: `01a16f78-b48a-7633-937a-e559a57adaa4`
- Generated file name: `exec-bc455cf3-a8ad-45fc-9ae7-2ccf579fbeb3.png`
- Source path copied from: `~/.codex/generated_images/01a16f78-b48a-7633-937a-e559a57adaa4/exec-bc455cf3-a8ad-45fc-9ae7-2ccf579fbeb3.png`
- Image size: 1536x1024
- SHA-256: `c418e26f45c13408c098cffd26ad5b19aaa11c235b703d4d778061ef01e38843`
- Verdict: ok. brass frame with amber rim and straw recess; its job reported no image (folder holds the frame)
- Attempts: 1 (no regeneration)

### `subscreen_slot_locked_v1.png`

- File: `tools/source_art/subscreen_slot_locked_v1.png`
- Session ID: `01a16f7a-4923-7f53-93c5-faefb45525fe`
- Generated file name: `exec-beb73a71-0ca1-4279-b35c-2e50cd88ab0f.png`
- Source path copied from: `~/.codex/generated_images/01a16f7a-4923-7f53-93c5-faefb45525fe/exec-beb73a71-0ca1-4279-b35c-2e50cd88ab0f.png`
- Image size: 1536x1024
- SHA-256: `72b4943737bd3610a91cc20e6e2cfaf92358c3678f9dd02289246bc8af4a0907`
- Verdict: ok. dark featureless sack silhouette in a brass slot; its job reported a dragon (another session's file), not used
- Attempts: 1 (no regeneration)

### `subscreen_slot_locked_v2.png`

- File: `tools/source_art/subscreen_slot_locked_v2.png`
- Session ID: `01a16f7a-6da5-7673-a804-ab7657466517`
- Generated file name: `exec-2fd8701f-1635-4308-8fbd-bb32d30f6e89.png`
- Source path copied from: `~/.codex/generated_images/01a16f7a-6da5-7673-a804-ab7657466517/exec-2fd8701f-1635-4308-8fbd-bb32d30f6e89.png`
- Image size: 1536x1024
- SHA-256: `43cc51877792723dd6d5141c3d6ed453a1c1351b7fdf326d2fc8b1baf2c0531f`
- Verdict: ok. dark silhouette in a brass slot
- Attempts: 1 (no regeneration)

### `subscreen_slot_locked_v3.png`

- File: `tools/source_art/subscreen_slot_locked_v3.png`
- Session ID: `01a16f7a-d059-79c2-b007-0a14cd4f5b18`
- Generated file name: `exec-d442fe3a-dacb-4158-9e10-58063d12d51b.png`
- Source path copied from: `~/.codex/generated_images/01a16f7a-d059-79c2-b007-0a14cd4f5b18/exec-d442fe3a-dacb-4158-9e10-58063d12d51b.png`
- Image size: 1536x1024
- SHA-256: `da795c8791e438f340348493c840eb5cc0eae0a731fbc1813cb6a7f6a7911297`
- Verdict: ok. dark featureless sack silhouette in a brass slot
- Attempts: 1 (no regeneration)

### `subscreen_cursor_v1.png`

- File: `tools/source_art/subscreen_cursor_v1.png`
- Session ID: `01a16f7a-df8d-7fd0-8c20-6a558d03531b`
- Generated file name: `exec-a53ac667-6dbb-4a63-8c57-638e407d583b.png`
- Source path copied from: `~/.codex/generated_images/01a16f7a-df8d-7fd0-8c20-6a558d03531b/exec-a53ac667-6dbb-4a63-8c57-638e407d583b.png`
- Image size: 1536x1024
- SHA-256: `0aa8aed7112e5942dda3db8c5af5d432971180b428c936fd4d40fd0cf4337d75`
- Verdict: ok. three amber teardrop flames in a row on magenta (the three poses differ in lean)
- Attempts: 1 (no regeneration)

### `subscreen_cursor_v2.png`

- File: `tools/source_art/subscreen_cursor_v2.png`
- Session ID: `01a16f7a-e537-7392-8a97-6a3b3603fc6b`
- Generated file name: `exec-c1ddb785-43c5-4047-8d3b-3e3264dcdb6a.png`
- Source path copied from: `~/.codex/generated_images/01a16f7a-e537-7392-8a97-6a3b3603fc6b/exec-c1ddb785-43c5-4047-8d3b-3e3264dcdb6a.png`
- Image size: 1536x1024
- SHA-256: `3d64d995ce9270acb617f4985a72bf3a4dca852298ce60ea49ae137c7bb40cc2`
- Verdict: weak. three flames, with small detached flecks around the main flames
- Attempts: 1 (no regeneration)

### `subscreen_cursor_v3.png`

- File: `tools/source_art/subscreen_cursor_v3.png`
- Session ID: `01a16f7c-6b7f-7873-9ce9-95a117ebff91`
- Generated file name: `exec-ee6a8778-69b6-4398-9d2b-146a2dcfe261.png`
- Source path copied from: `~/.codex/generated_images/01a16f7c-6b7f-7873-9ce9-95a117ebff91/exec-ee6a8778-69b6-4398-9d2b-146a2dcfe261.png`
- Image size: 1536x1024
- SHA-256: `811f47cd036057a2bbd16eab6af5e73aa7ea5bbeaaf83d4c11c37c4f099c61f3`
- Verdict: ok. three flames; the file is byte-identical to tools/source_art/lock_warden_body_closed_open_v3.png (another producer's file), which is therefore a wrong copy of this sheet; that file is not changed here
- Attempts: 1 (no regeneration)

### `pause_panel_v2.png`

- File: `tools/source_art/pause_panel_v2.png`
- Session ID: `01a16f7c-9c4b-71c3-b749-b2358d86e082`
- Generated file name: `exec-92460778-cffa-4fc8-ba5e-8f80287933df.png`
- Source path copied from: `~/.codex/generated_images/01a16f7c-9c4b-71c3-b749-b2358d86e082/exec-92460778-cffa-4fc8-ba5e-8f80287933df.png`
- Image size: 1536x1024
- SHA-256: `a2033ca64ac0c3b0a64a5cce72f965c53fbd6421e7f219bd23f7fd872c4ca8d9`
- Verdict: ok. dark panel with a brass border and plain interior
- Attempts: 1 (no regeneration)

### `pause_panel_v1.png`

- File: `tools/source_art/pause_panel_v1.png`
- Session ID: `01a16f7c-6cbb-7c90-99c9-874c1c67b118`
- Generated file name: `exec-1594c0d0-3c7d-4de9-85ad-b45ae4074841.png`
- Source path copied from: `~/.codex/generated_images/01a16f7c-6cbb-7c90-99c9-874c1c67b118/exec-1594c0d0-3c7d-4de9-85ad-b45ae4074841.png`
- Image size: 1536x1024
- SHA-256: `22669fe91e82f25f6f6f10562890e3b29258694e59163716fee1e36f24742685`
- Verdict: ok. dark slate panel with a brass border, plain interior; its job reported no result (folder holds the panel)
- Attempts: 1 (no regeneration)

### `pause_panel_v3.png`

- File: `tools/source_art/pause_panel_v3.png`
- Session ID: `01a16f7e-b58d-7032-abba-d4cfbadf6dd1`
- Generated file name: `exec-5f8a273f-fc62-43e7-83f9-babd2e61f785.png`
- Source path copied from: `~/.codex/generated_images/01a16f7e-b58d-7032-abba-d4cfbadf6dd1/exec-5f8a273f-fc62-43e7-83f9-babd2e61f785.png`
- Image size: 1536x1024
- SHA-256: `52582af0e3c4438d9475481604b191d543572021c600326632bb7131f0ba7dfa`
- Verdict: ok. dark slate panel with brass border; the first pause v3 job was cancelled by the lead (see the rejects), the retry is kept
- Attempts: 1 (no regeneration)

## Rejected attempts (not kept; the files stay in the local Codex folders)

- `pause_panel_v3`: job 01a16f7bb4e37a1a8e526f2581f47149 ; cancelled by the lead (seventh job in a wave); no output
- `subscreen_cursor_v3`: job 01a16f7ba44c76c78478f74a12003efb ; first attempt: its folder held a brass rope spool and hook on a 1254x1254 canvas (the job report named the same file); not used; the retry is kept
- `subscreen_slot_locked_v1`: job 01a16f798a0179d4b40c6b8e6b95424f ; first attempt: its report named a gold dragon (another session's file); the folder file is the sack silhouette, kept

