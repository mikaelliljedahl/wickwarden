# Batch 80 generation log (producer h)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job). Each image was taken from the job's own session folder under `~/.codex/generated_images/<session_id>/` (the `session_id` field of get_job), never from the file a job named in its report: several reports named another session's file. The copy was checked by SHA-256 against the source and for duplicates across `tools/source_art/`. Each unit was viewed as a montage of its variants. The prompt of each job is the fenced entry in `tools/art_prompts/batch_80.md`, passed unchanged (the log does not repeat it).

## Summary (one line per image)

- `warp_icon_c6_v3.png`: ok - mossy arch with bronze bells, softer light
- `warp_icon_c7_v1.png`: ok - dark stone mouth on a ledge with a red-orange glow
- `warp_icon_c7_v2.png`: weak - cave mouth with a hooded figure holding a lantern in front (the job reported it; kept)
- `warp_icon_c7_v3.png`: weak - cave mouth with a hanging lantern in front (the job reported it; kept)

## Details

### `warp_icon_c6_v3.png`

- File: `tools/source_art/warp_icon_c6_v3.png`
- Session ID: `01a16f87-6a30-7e40-b56e-3b6bf0efb085`
- Generated file name: `exec-79b04a81-bce6-48fb-9cf7-6fa80cf5a392.png`
- Source path copied from: `~/.codex/generated_images/01a16f87-6a30-7e40-b56e-3b6bf0efb085/exec-79b04a81-bce6-48fb-9cf7-6fa80cf5a392.png`
- Image size: 1536x1024
- SHA-256: `cb240e53b66b63b6eb07d0cba99a21bd7dd99c78db48ed5204f9b8e67fa82d29`
- Verdict: ok. mossy arch with bronze bells, softer light
- Attempts: 1 (no regeneration)

### `warp_icon_c7_v1.png`

- File: `tools/source_art/warp_icon_c7_v1.png`
- Session ID: `01a16f87-6cf3-7f00-b66e-8082bc1f2be2`
- Generated file name: `exec-8a55421e-47af-4f67-abf1-129c198a0e4a.png`
- Source path copied from: `~/.codex/generated_images/01a16f87-6cf3-7f00-b66e-8082bc1f2be2/exec-8a55421e-47af-4f67-abf1-129c198a0e4a.png`
- Image size: 1536x1024
- SHA-256: `6516422f264c578aa15d1f2aebfbc58ad1815a9e4d025db1dc699fc71fa89054`
- Verdict: ok. dark stone mouth on a ledge with a red-orange glow
- Attempts: 1 (no regeneration)

### `warp_icon_c7_v2.png`

- File: `tools/source_art/warp_icon_c7_v2.png`
- Session ID: `01a16f87-b30d-75a2-ab0e-4f0764fc7065`
- Generated file name: `exec-52d503fb-adbe-456e-98ae-9c6454ea6bb9.png`
- Source path copied from: `~/.codex/generated_images/01a16f87-b30d-75a2-ab0e-4f0764fc7065/exec-52d503fb-adbe-456e-98ae-9c6454ea6bb9.png`
- Image size: 1536x1024
- SHA-256: `15baf15a635a30c802a6866de93229f377bfc566d3daa489731f828c1215ccd7`
- Verdict: weak. cave mouth with a hooded figure holding a lantern in front (the job reported it; kept)
- Attempts: 1 (no regeneration)

### `warp_icon_c7_v3.png`

- File: `tools/source_art/warp_icon_c7_v3.png`
- Session ID: `01a16f87-b496-7041-b5be-9d69e2753ee7`
- Generated file name: `exec-4a01f6a9-1615-4ffb-bbcc-50549bbc6211.png`
- Source path copied from: `~/.codex/generated_images/01a16f87-b496-7041-b5be-9d69e2753ee7/exec-4a01f6a9-1615-4ffb-bbcc-50549bbc6211.png`
- Image size: 1536x1024
- SHA-256: `1cb962da312c9a32677bd251bb392557b99e1e495adf59e20a6b74ffbfdf06cc`
- Verdict: weak. cave mouth with a hanging lantern in front (the job reported it; kept)
- Attempts: 1 (no regeneration)

