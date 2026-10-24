# Batch 62 generation log (producer g)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job). Each job copied its PNG to `tools/source_art/`; the copy was checked by SHA-256 against the PNG in the job's own `~/.codex/generated_images/<session>/` folder (the only PNG with the same hash), and hashes are unique across `tools/source_art/`. Prompts: `tools/art_prompts/batch_62.md` (the entry heading is the job id). Verdicts are the producer's own view of each image, not the owner's cull.

## Summary (one line per image)

- `corrows_echo_actions_down_v1.png`: ok - front view with the states in bands; the hook-throw pose at the bottom left faces sideways
- `corrows_echo_actions_down_v2.png`: ok - front view; states in bands read clearly, the hook throw shows the cord
- `corrows_echo_actions_down_v3.png`: ok - front view with a few figures drifting to three-quarter; states in bands read clearly
- `corrows_echo_actions_side_v1.png`: weak - all states readable but scale varies between poses and some are rear three-quarter, not strict side profile
- `corrows_echo_actions_side_v2.png`: ok - animation bands clear: combo, retreat, flare charge, chime stun, hook throw; side profile mostly held
- `corrows_echo_actions_side_v3.png`: ok - animation bands clear: combo, retreat, flare charge, chime stun, hook throw; side profile mostly held
- `corrows_echo_walk_down_v1.png`: weak - front view; the four poses barely change the leg stance
- `corrows_echo_walk_down_v2.png`: ok - front view, square to the camera; leg stances differ across the four poses, subtle
- `corrows_echo_walk_down_v3.png`: weak - front view; poses repeat the same leg stance
- `corrows_echo_walk_side_v1.png`: weak - poses 1/3 and 2/4 look duplicated; alternating walk cycle unclear (anchor kept for design only)
- `corrows_echo_walk_side_v2.png`: weak - poses 2 and 4 lift the same leg; leg arrangement not opposite
- `corrows_echo_walk_side_v3.png`: weak - poses 1 and 3 near-repeat; poses 2 and 4 also repeat the same leg lift
- `corrows_echo_walk_up_v1.png`: weak - back view; poses 1 and 3 repeat, poses 2 and 4 repeat the lifted leg
- `corrows_echo_walk_up_v2.png`: weak - back view; the same leg arrangement repeats across the four poses
- `corrows_echo_walk_up_v3.png`: weak - back view; poses 2 to 4 nearly identical
- `miniboss_death_wax_v1.png`: ok - six-frame wax collapse, the figure melts into a puddle with a dying violet glow; no face
- `miniboss_death_wax_v2.png`: ok - six-frame wax collapse, a deeper melt and a dying violet glow; no face
- `miniboss_death_wax_v3.png`: ok - six-frame wax collapse; dark contact shadows at the bases (kept)

## Details

| File | Codex session | Output ID | SHA-256 (first 16) |
|---|---|---|---|
| `corrows_echo_actions_down_v1.png` | `01a16f60-215d-72b1-8a01-3faaf890c3cc` | `exec-49940d80-f05e-454b-b24a-4e5fb74185df` | `4dc7997905ac7895` |
| `corrows_echo_actions_down_v2.png` | `01a16f60-37ad-7a62-829c-b1fcbec6df23` | `exec-3f088b25-5362-4629-a5e5-c666d0a9a1ea` | `bc56114f97dd190c` |
| `corrows_echo_actions_down_v3.png` | `01a16f60-9cec-78d2-8543-329b3d118ad2` | `exec-a85573a0-03ab-4874-8681-14d526c20d12` | `f321200157ee060b` |
| `corrows_echo_actions_side_v1.png` | `01a16f5e-c179-7642-975d-f478e290ca22` | `exec-6508dc03-4388-4710-abd4-cec42a915d4a` | `8e1c580cfe07efce` |
| `corrows_echo_actions_side_v2.png` | `01a16f5f-c7a8-7f41-9614-b41bb7ac28ce` | `exec-f51360b4-8407-4922-804a-616c88701895` | `52d04e07c7e1bb61` |
| `corrows_echo_actions_side_v3.png` | `01a16f5f-f10d-7a93-bb63-a62b495415bf` | `exec-5b8cb2fc-e9a4-44b0-b362-c90ca3c1d37a` | `d4119d2d2fdb4dd8` |
| `corrows_echo_walk_down_v1.png` | `01a16f5c-e47b-77d0-89d4-c43b249afd08` | `exec-721e4e93-a6b4-4f2d-895e-b50ebbd2427a` | `c3901a109f9e8486` |
| `corrows_echo_walk_down_v2.png` | `01a16f5e-7936-7f80-8d34-293f4098c383` | `exec-6fc9b9ee-8b12-4fcc-914d-93be6f10490f` | `4e4442ae7e030e1c` |
| `corrows_echo_walk_down_v3.png` | `01a16f5e-8b26-7a33-9fe9-7e15b1457cbc` | `exec-d35ba365-6e93-461a-bbce-5ccfad998d6d` | `732d9faeea9fc7ba` |
| `corrows_echo_walk_side_v1.png` | `01a16f56-bc61-7b93-a1cd-d3dd6dc25dce` | `exec-96765bd6-c7e1-430a-a140-b8d57a791452` | `d0edfd062d5f4dbf` |
| `corrows_echo_walk_side_v2.png` | `01a16f56-be1d-7dd2-9850-e79c5a938424` | `exec-07e32f8a-b069-45f1-99d6-f184cf85c71f` | `600a056cff3db859` |
| `corrows_echo_walk_side_v3.png` | `01a16f56-c5fc-7281-aa14-1296c0bbbaa6` | `exec-ffe4538b-0513-4f4f-aa9c-483d6bbb094b` | `c274be4c827e347b` |
| `corrows_echo_walk_up_v1.png` | `01a16f5e-8c3f-7832-8571-768f336c23f2` | `exec-5682efd1-6bb6-47a2-bdc4-72342b81fc9b` | `716e215358e37f2a` |
| `corrows_echo_walk_up_v2.png` | `01a16f5e-9094-7552-92e1-7a29b7c2b2a5` | `exec-caf82f24-5e1a-4b1c-a0a1-5d4d84060402` | `99bc843a221d19c9` |
| `corrows_echo_walk_up_v3.png` | `01a16f5e-9561-7270-942a-934adee802d4` | `exec-43163531-98c4-4ebb-aa1d-06d49b01964a` | `ac069402cf5f6153` |
| `miniboss_death_wax_v1.png` | `01a16f56-cc32-7d22-b9f2-7e45e4602189` | `exec-c7fdf694-6154-4006-b7bd-d14329c4992e` | `c1be012ed9d1c762` |
| `miniboss_death_wax_v2.png` | `01a16f61-8729-7fe3-85ce-b56158b54c26` | `exec-176eb7a6-ce70-45c3-906c-1528d52b894c` | `c691e43ca7599318` |
| `miniboss_death_wax_v3.png` | `01a16f61-9bdc-7b20-8bdd-cdaab9bb09bc` | `exec-781b7ede-8ed6-40de-b3da-46dd7892fb7e` | `e2143c670e669b89` |
