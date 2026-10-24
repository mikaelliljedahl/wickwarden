# Batch 63 generation log (producer g)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job). Each job copied its PNG to `tools/source_art/`; the copy was checked by SHA-256 against the PNG in the job's own `~/.codex/generated_images/<session>/` folder (the only PNG with the same hash), and hashes are unique across `tools/source_art/`. Prompts: `tools/art_prompts/batch_63.md` (the entry heading is the job id). Verdicts are the producer's own view of each image, not the owner's cull.

## Summary (one line per image)

- `briar_mother_p1_v1.png`: ok - canopy-sleep poses (two) and the eye-lost pose (one hollow eye, two red fruit-eyes) read clearly; design consistent
- `briar_mother_p1_v2.png`: ok - sleeping faces partly covered by roots; eye-lost pose shows two red eyes and a dark hollow; design holds
- `briar_mother_p1_v3.png`: ok - sleeping figure and three red fruit-eyes read; eye-lost pose has one hollow eye; design holds
- `kilnkeeper_p1_down_v1.png`: weak - front view; walk poses nearly identical with inconsistent legs; some slag droplets reach far from the figure
- `kilnkeeper_p1_down_v2.png`: weak - front view; pose scale and vertical placement vary; bottom-row slag sprays spread into the gaps
- `kilnkeeper_p1_down_v3.png`: ok - front view; walk legs vary across poses; fan and splash row read clearly; scale consistent
- `kilnkeeper_p1_side_v1.png`: weak - figures read three-quarter, walk poses 2 and 4 nearly alike; stun pose has an awkward raised hand
- `kilnkeeper_p1_side_v2.png`: weak - most walk and rush poses are three-quarter views; the stun pose faces the camera; design consistent
- `kilnkeeper_p1_side_v3.png`: ok - walk poses closer to side profile than v1 and v2; legs differ across poses; rush and stun rows read; some three-quarter drift (chosen as anchor)
- `kilnkeeper_p2_down_v1.png`: ok - front view; molten, cracked-idle and walk rows in place; walk legs differ subtly
- `kilnkeeper_p2_down_v2.png`: weak - molten, cracked-idle and walk rows read; chimney smoke touches and is cut by the top edge
- `kilnkeeper_p2_down_v3.png`: weak - molten, cracked-idle and walk rows read; chimney smoke clipped by the top edge
- `kilnkeeper_p2_side_v1.png`: weak - figures drift to three-quarter; walk leg alternation unclear
- `kilnkeeper_p2_side_v2.png`: weak - rush and splash rows drift to three-quarter; splash crowds the gaps between poses
- `kilnkeeper_p2_side_v3.png`: weak - side profile holds better than v1, but the walk poses lack clear leg alternation
- `seed_eye_v1.png`: ok - raised, lowering (three), lowered and spore rows read; eye and stalk clear
- `seed_eye_v2.png`: ok - raised, lowering (three), lowered and spore rows read as a stalk bending and the eye opening; oversized root clumps at the base
- `seed_eye_v3.png`: ok - raised, lowering, lowered and spore rows read; uneven spacing with a large gap under the top pose

## Details

| File | Codex session | Output ID | SHA-256 (first 16) |
|---|---|---|---|
| `briar_mother_p1_v1.png` | `01a16f63-156c-7422-862e-fe3da70feb3f` | `exec-554b5a22-c7df-4c4f-9910-777edcd1ebc3` | `0f34dae5ec95b515` |
| `briar_mother_p1_v2.png` | `01a16f63-2e4d-7871-b895-ee69127c7020` | `exec-ec2e1117-b3bf-4373-8a60-11d0cad9edc2` | `101aa8753a12dfa9` |
| `briar_mother_p1_v3.png` | `01a16f63-65e8-7880-8bcf-de91b881559d` | `exec-dff8ab85-b7f1-4b6c-ada7-265ea23ded9a` | `19f24e3ffa90d8ed` |
| `kilnkeeper_p1_down_v1.png` | `01a16f64-632e-7c52-a4b3-a51b1a25ab3a` | `exec-bb2da8a8-5342-4321-ad0e-09897d8dedb6` | `9467577b976718fe` |
| `kilnkeeper_p1_down_v2.png` | `01a16f64-6ba9-7ce1-9f91-460ca54afec7` | `exec-f0128fd9-1e44-4053-9f58-5b783b0332c2` | `223e9f97555c099f` |
| `kilnkeeper_p1_down_v3.png` | `01a16f64-d79e-7442-8e6c-b1156ffaba68` | `exec-6041cf0b-9357-4ee7-8eb6-7069416a732a` | `b5c51a7fc28652db` |
| `kilnkeeper_p1_side_v1.png` | `01a16f61-a352-74e0-a4d6-da41924bad08` | `exec-52e0728c-3644-40af-90f4-c65e10790318` | `a9484743efe146ee` |
| `kilnkeeper_p1_side_v2.png` | `01a16f61-a98c-7981-a267-37cd2bdc9047` | `exec-2dc8dd01-9b34-4944-a685-ad804ed15eee` | `3754ac57778ed0f1` |
| `kilnkeeper_p1_side_v3.png` | `01a16f63-1376-7b71-b19f-4a6845b83237` | `exec-c5d97a26-3dc5-4d24-b00d-b30542771675` | `10ba92ee0334f068` |
| `kilnkeeper_p2_down_v1.png` | `01a16f65-9862-70e0-b083-f0670ace0de1` | `exec-e73bd3e0-eda6-48d8-bbd4-6aef4db23fba` | `a5b79216c54a4b3d` |
| `kilnkeeper_p2_down_v2.png` | `01a16f65-98b3-7c60-a7a0-31dcb459440c` | `exec-e299f35d-ad74-4199-a5ff-37e08e4a59f7` | `b3363d5fac2f801e` |
| `kilnkeeper_p2_down_v3.png` | `01a16f66-3fc1-7372-8f66-9c18032cba77` | `exec-09ce1e5d-657a-4954-8e8d-c9671a32d2f5` | `5bbe840145b256bf` |
| `kilnkeeper_p2_side_v1.png` | `01a16f64-e6fa-7a42-85b0-e6b02e0d3cc6` | `exec-2fb1e2ea-fb4f-49a7-9621-1b3380335989` | `9da620fb409e23e0` |
| `kilnkeeper_p2_side_v2.png` | `01a16f64-f759-7c83-aba1-23b40477c6ab` | `exec-cc748ef6-db1e-47d3-ad2e-e40e6f63a483` | `df69773c968cdd2d` |
| `kilnkeeper_p2_side_v3.png` | `01a16f65-0263-7bd1-913e-ce92a7c76b6e` | `exec-b58151a6-e6b2-4874-8034-dcd31529a5b8` | `1636f1455862c578` |
| `seed_eye_v1.png` | `01a16f65-e18a-7810-b4fb-51b2c937ece9` | `exec-6ce8d9cd-728c-4536-b1d6-eb17b9c2bf97` | `9bc5931703e3186d` |
| `seed_eye_v2.png` | `01a16f65-e43b-74c3-b7a5-d48dbff3df3a` | `exec-006bc8db-31c7-4231-b449-4ecfefdf0dc3` | `223fcbdb3a78cb37` |
| `seed_eye_v3.png` | `01a16f66-4286-7d92-9655-8c9773185176` | `exec-33dada4c-9552-4c78-ac7e-09f129792489` | `cd39769cc79425e4` |
