# Batch 66 generation log (producer g)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job). Each job copied its PNG to `tools/source_art/`; the copy was checked by SHA-256 against the PNG in the job's own `~/.codex/generated_images/<session>/` folder (the only PNG with the same hash), and hashes are unique across `tools/source_art/`. Prompts: `tools/art_prompts/batch_66.md` (the entry heading is the job id). Verdicts are the producer's own view of each image, not the owner's cull.

## Summary (one line per image)

- `archivist_decoy_v1.png`: ok - four paler float poses without the shadow cue; scale varies slightly
- `archivist_decoy_v2.png`: ok - pale decoy float poses with no shadow; scale and height vary a little
- `archivist_decoy_v3.png`: ok - pale float poses with no shadow; reads more opaque than translucent, kept
- `archivist_p2_p3_v1.png`: weak - top row poses overlap; sheet has nine poses instead of eleven
- `archivist_p2_p3_v2.png`: ok - copy, stunned, page-break and last-page rows read in order (eleven poses); faint background variation
- `archivist_p2_p3_v3.png`: ok - copy-phase shimmer reads as faint ghost figures; stunned, page-break and last-page rows read
- `dirge_head_alto_v1.png`: ok - sleep to scream rows read; faint pink rings and dust, no defects seen
- `dirge_head_alto_v2.png`: ok - floating stone specks around several poses; poses read in order
- `dirge_head_alto_v3.png`: ok - effects and debris come close to neighbouring poses; poses read, kept
- `dirge_head_bass_v1.png`: ok - sound rings and dust are broad gold glows across row 3; poses read, acceptable
- `dirge_head_bass_v2.png`: ok - open-mouth and sound rows read; rings and dust sit clear of neighbours
- `dirge_head_bass_v3.png`: weak - pink sound rings and dust in row 3 crowd neighbouring poses; spacing tighter than v1
- `dirge_head_treble_v1.png`: ok - ten poses in four rows; sound rings and dust in row 3 clear of neighbours; poses read in order
- `dirge_head_treble_v2.png`: ok - brass column with side pipes, a different design from v1 and v3 (alternative variant); poses read in order, rings and dust clear
- `dirge_head_treble_v3.png`: ok - ten poses in four rows; rings and dust in row 3 read, clear of neighbours; face and column consistent

## Details

| File | Codex session | Output ID | SHA-256 (first 16) |
|---|---|---|---|
| `archivist_decoy_v1.png` | `01a16f71-6a63-7aa0-b6e1-dec7fc32111a` | `exec-234307d6-8690-4039-9f3f-c9acd817ad04` | `d497b041002be70e` |
| `archivist_decoy_v2.png` | `01a16f71-7196-7a32-b82f-6ebc27a881f0` | `exec-7f3da843-aa75-4e0f-a314-0ee3acc30440` | `6006683b154785e6` |
| `archivist_decoy_v3.png` | `01a16f71-77bb-77c1-9c12-f814d2f6c3cd` | `exec-3b7e24f0-7f81-467c-947d-e2741b12ea7e` | `8d87267d1844aa86` |
| `archivist_p2_p3_v1.png` | `01a16f71-6349-78b3-ab14-d54d4d7cb172` | `exec-d7466a15-6976-455e-8de1-15fa14b57f41` | `92621c3171fc6e93` |
| `archivist_p2_p3_v2.png` | `01a16f71-5ea4-7e60-b2f1-ec91d2d7ee17` | `exec-c0287281-1516-4cb9-b7cb-60385eedd442` | `551962f9a9efe1e1` |
| `archivist_p2_p3_v3.png` | `01a16f71-63ad-7623-aec2-a2eb944688ba` | `exec-9d191725-c9f4-485f-aa03-088e60b99bb9` | `fd166fabe3a28a83` |
| `dirge_head_alto_v1.png` | `01a16f73-4c60-7d42-9661-ae2137467fa0` | `exec-5659c570-6dc2-4b3e-a527-00c47cb191a7` | `27f424571543f695` |
| `dirge_head_alto_v2.png` | `01a16f73-5aa2-7722-b57e-0b2b1eea8e71` | `exec-a946dae4-30e0-4989-b79c-deb182b568af` | `9184a429b4a52abc` |
| `dirge_head_alto_v3.png` | `01a16f73-6325-74f1-b920-c2beb2221bc8` | `exec-8e1387ee-6bd4-4e3a-a1ee-be4d4229d88e` | `ff033a644a0ce912` |
| `dirge_head_bass_v1.png` | `01a16f72-a7c7-7963-a84f-0a9300c00e5d` | `exec-a33e47d0-e8ae-47e0-84b7-d693ed2fc81e` | `1392faddf0181449` |
| `dirge_head_bass_v2.png` | `01a16f72-ae65-7140-8279-656e39bcb5a3` | `exec-bd0018a7-d1d0-4b3e-8630-616053822e76` | `e8c0b58caedbb892` |
| `dirge_head_bass_v3.png` | `01a16f72-b543-7963-abcf-8ca1754470e0` | `exec-ddbcc6c1-b866-4682-af54-4aa57596e81d` | `7f9ca21924b038da` |
| `dirge_head_treble_v1.png` | `01a16f76-47d5-7383-b6cf-23be9614327c` | `exec-d905df0a-9673-41c5-ba13-9307b8ab123f` | `b92c9b9c0532c6ea` |
| `dirge_head_treble_v2.png` | `01a16f76-966b-72e2-bc84-aa0fc6377108` | `exec-0839c073-52fa-4898-bbd3-c98cdc0f7d3e` | `87c2c3d4a0fef0ae` |
| `dirge_head_treble_v3.png` | `01a16f76-95f0-7863-be05-41c4e7d52437` | `exec-7e1e0020-46dc-46f4-a49f-0a2002b5f942` | `a64a43857b8be75e` |
