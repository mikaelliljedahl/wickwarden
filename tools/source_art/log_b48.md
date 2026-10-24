# Batch 48 generation log (producer f)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job; batches 48 to 52 were run by an earlier f producer, see below). Each PNG was checked by SHA-256 against the PNG in its own `~/.codex/generated_images/<session>/` folder (match in every case) and against all other `tools/source_art/` files (no duplicate).

Batch 48: proj_slag_ball, proj_spore_bolt, proj_thorn_needle, proj_ember_bolt, proj_beam_bolt, proj_ink_bolt.

Defects not fixed (kept for the owner's cull): Montage check (all 18 viewed as sheets): five poses per sheet in one row, flight then impact, no touching. Earlier-run files: slag_ball v1-v3 and spore_bolt v2/v3 were run with hush_spitcap.png attached (no spitcap in output). ember/beam/thorn/ink regenerated under -r1 with no reference (see PROGRESS_f.md). Sizes 1536x1024.

Prompt entries: `tools/art_prompts/batch_48.md`, job id heading per image; the fenced prompt of each entry was passed unchanged. Reference images as named in each entry.

## Files

| File | Size | Reference | Codex session | Output ID | SHA-256 (first 16) | Job id |
|---|---|---|---|---|---|---|
| `proj_slag_ball_v1.png` | 1536x1024 | see entry | `01a16f54-39ad-7522-bc92-a7dfab76d86d` | `exec-9afbab42-0dbd-4074-bd0a-209757b72304` | `7a168e6fca811cc0` | `b48_proj_slag_ball_v1` |
| `proj_slag_ball_v2.png` | 1536x1024 | see entry | `01a16f54-4646-7a30-8679-01b62ef4a80b` | `exec-37261474-7539-4b84-8698-2448852eef67` | `c10e57f2ec70bf32` | `b48_proj_slag_ball_v2` |
| `proj_slag_ball_v3.png` | 1536x1024 | see entry | `01a16f54-4f36-7f50-b7c7-c074240a4fbf` | `exec-fe3183a4-0ce8-4f67-8238-b1c619c38ddb` | `3913d6c5a2de132b` | `b48_proj_slag_ball_v3` |
| `proj_spore_bolt_v1.png` | 1536x1024 | see entry | `01a16f5c-f696-73b2-bcb9-0abc1b795d63` | `exec-bfa2a515-c975-4d05-a31c-5605b0c95ddb` | `7678611c831921c2` | `b48_proj_spore_bolt_v1` |
| `proj_spore_bolt_v2.png` | 1536x1024 | see entry | `01a16f54-7cb7-79b0-ad7e-1f312367fe74` | `exec-3c0d6a96-dd0f-4dd7-b422-2f342e0ba016` | `ad1f52eed9270f42` | `b48_proj_spore_bolt_v2` |
| `proj_spore_bolt_v3.png` | 1536x1024 | see entry | `01a16f54-7de7-70d1-a580-aa916bd8ac36` | `exec-e5ceefbc-91d6-4665-a1b8-be905896a86d` | `01010fdd1acf5615` | `b48_proj_spore_bolt_v3` |
| `proj_thorn_needle_v1.png` | 1536x1024 | see entry | `01a16f60-d5a3-7311-8da6-148b2949a9a9` | `exec-3f8447c0-003c-4601-bed5-102a8b94ad5a` | `ac0ced4b550996d8` | `b48_proj_thorn_needle_v1` |
| `proj_thorn_needle_v2.png` | 1536x1024 | see entry | `01a16f60-d94b-7773-b8bb-6f1d340ad732` | `exec-6cf34e8e-0897-4559-8553-4186e55068c9` | `2ca44e0bb43a4a45` | `b48_proj_thorn_needle_v2` |
| `proj_thorn_needle_v3.png` | 1536x1024 | see entry | `01a16f60-e086-7933-b139-bd24328a30fb` | `exec-82ee7e9c-31af-49b8-9da2-59738c43e081` | `bab2dcc55bc81afb` | `b48_proj_thorn_needle_v3` |
| `proj_ember_bolt_v1.png` | 1536x1024 | see entry | `01a16f5f-6721-7673-866e-c1c6e0ae123b` | `exec-9959fbac-cd87-40ff-90fd-969f872b7484` | `abe8b07a48f819e2` | `b48_proj_ember_bolt_v1` |
| `proj_ember_bolt_v2.png` | 1536x1024 | see entry | `01a16f5f-6e3c-7f10-bf8e-41a9ac08e40f` | `exec-21b202c6-ac3a-46c7-ba0b-7e78e2af1536` | `81a052115f592529` | `b48_proj_ember_bolt_v2` |
| `proj_ember_bolt_v3.png` | 1536x1024 | see entry | `01a16f5f-7605-7933-b463-4d2767b4593d` | `exec-f62fbf9a-7fb3-4c53-9bd6-97b887139318` | `cace33da6b0700c7` | `b48_proj_ember_bolt_v3` |
| `proj_beam_bolt_v1.png` | 1536x1024 | see entry | `01a16f5f-7fd3-7c72-8356-3882324a2ef5` | `exec-746fe189-24c7-46fc-9383-cb6fe0e341f6` | `03ab6a7539c41c6d` | `b48_proj_beam_bolt_v1` |
| `proj_beam_bolt_v2.png` | 1536x1024 | see entry | `01a16f5f-84fa-70a3-a483-f7584bc11257` | `exec-9017f8a2-1efe-4a85-ad6a-25e975f388e9` | `65b3cb2c57f1b732` | `b48_proj_beam_bolt_v2` |
| `proj_beam_bolt_v3.png` | 1536x1024 | see entry | `01a16f60-c758-71a2-ba52-bdc2ce623785` | `exec-f805fd9a-2cc8-4f2a-95e0-bafeeca824ba` | `380c80802e57d938` | `b48_proj_beam_bolt_v3` |
| `proj_ink_bolt_v1.png` | 1536x1024 | see entry | `01a16f60-ea9a-7c52-a8b1-7242e966cf54` | `exec-10554f85-ad83-4827-8ebe-78d740e05e18` | `8910af988f0710e5` | `b48_proj_ink_bolt_v1` |
| `proj_ink_bolt_v2.png` | 1536x1024 | see entry | `01a16f68-ddeb-7e13-89ba-4a6b15bea619` | `exec-553e0d0a-45d5-43de-9c92-2e053841c29c` | `8bfc46dc95dbf60a` | `b48_proj_ink_bolt_v2` |
| `proj_ink_bolt_v3.png` | 1536x1024 | see entry | `01a16f68-e491-7441-a7ad-e20324b00d68` | `exec-4ac0e81e-23de-41eb-b2a8-4b97a00deb8c` | `4a8da5401c187d77` | `b48_proj_ink_bolt_v3` |

Rejected attempts: none recorded in this log (earlier-run rejects, if any, are in the local Codex folders only).
