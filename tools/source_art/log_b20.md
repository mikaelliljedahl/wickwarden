# Batch 20 log (18 images)

Prompts: `tools/art_prompts/batch_20.md` (one entry per image, job id in the heading). Backend codex, model `cheapest`
(gpt-6-luna, effort medium), one image per job. Each output was checked byte-identical (SHA-256) against the png in its
own job's session folder under `~/.codex/generated_images/<session>/`. No hash is shared with any other file in
`tools/source_art/`.

Verdict key: ok, weak (why), failed.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `item_reel_line_v1.png` | `b20_item_reel_line_v1` | `01a16f40-bde2-7670-9216-8a21dd3850e5` | `exec-e33de974-b7e8-4038-8ade-411287d50786.png` | 1536x1024 | `63bba027b983b72a` | weak (poses 1 to 3 show no glint, only pose 4 has a sparkle; the spool and pedestal are otherwise right) |
| `item_reel_line_v2.png` | `b20_item_reel_line_v2` | `01a16f40-c3ec-7193-9f3e-a8e50284967f` | `exec-c72e5ae4-8099-4fb2-a0e4-02820c928fa6.png` | 1536x1024 | `c672eff8dc5b2714` | weak (glint only in poses 2 and 4; pose 3 nearly identical to pose 1) |
| `item_reel_line_v3.png` | `b20_item_reel_line_v3` | `01a16f40-ccf9-78f2-9b79-44d1921d0e03` | `exec-16235c85-ecf3-474f-a0e1-62b11102112c.png` | 2172x724 (requested 1536x1024, not fixed by hand; four poses in one row) | `4be5e5387988be6a` | weak (poses 1 and 3 nearly identical, highlights broad on pose 2 instead of local) |
| `icon_base_hook_v1.png` | `b20_icon_base_hook_v1` | `01a16f40-d24e-7f72-a313-4964436dbb1f` | `exec-32679af6-9f0e-4560-b4fe-559157ba6818.png` | 1536x1024 | `5fc024dd106601ff` | ok |
| `icon_base_hook_v2.png` | `b20_icon_base_hook_v2` | `01a16f40-da0e-7e42-b1c3-f5b9df34e757` | `exec-b7f115d2-634d-4b05-ba63-411b1722c723.png` | 1536x1024 | `4f90c01887a31c60` | ok |
| `icon_base_hook_v3.png` | `b20_icon_base_hook_v3` | `01a16f40-e178-76a1-b9bd-6a24ac14c5d2` | `exec-e7456958-8178-4453-a00a-969c6da3c6a3.png` | 1536x1024 | `6025b7b2a9314a78` | ok (lamp hook with lantern, single centred icon) |
| `icon_base_flare_v1.png` | `b20_icon_base_flare_v1` | `01a16f42-6978-7f03-96cd-de43fba3da02` | `exec-e870d9a3-9064-44e1-974a-d281a8b2638f.png` | 1536x1024 | `b7f75038e9fb22c8` | ok |
| `icon_base_flare_v2.png` | `b20_icon_base_flare_v2` | `01a16f42-6aed-75c0-b84f-48f10f1f5c09` | `exec-9b5eef8e-c115-424b-84b8-13c325f4c0d2.png` | 1536x1024 | `cf4b00411dff5e7b` | ok |
| `icon_base_flare_v3.png` | `b20_icon_base_flare_v3` | `01a16f42-7155-7a43-8687-9abb992746c3` | `exec-15edd181-1c02-4167-b91a-8e21b8bde366.png` | 1536x1024 | `7f70cf96c46fd9e3` | ok |
| `icon_base_ward_v1.png` | `b20_icon_base_ward_v1` | `01a16f42-7aa4-7512-a5f4-41363cb4c407` | `exec-7f60bff5-75b6-41f7-bdc3-fb69cf59c832.png` | 1536x1024 | `e146f07add0b686b` | ok (round lantern-shield, amber centre, clear silhouette) |
| `icon_base_ward_v2.png` | `b20_icon_base_ward_v2` | `01a16f42-8743-7692-a582-c019376b5c9a` | `exec-f94c0a55-7c64-4424-8283-95b6fb345251.png` | 1536x1024 | `372fd942df9ed14d` | weak (icon larger than the prompt asks, iron crossbars cut the amber centre, no outward light fan) |
| `icon_base_ward_v3.png` | `b20_icon_base_ward_v3` | `01a16f42-8ba2-7572-8704-89cf996445bc` | `exec-1c772399-81a6-4555-a9ef-9f7ac3edeab0.png` | 1536x1024 | `b9c1d70774eb7a5b` | weak (reads as a round pendant medallion with a top ring and a flame symbol in the glass, not a shield) |
| `flame_cinder_v1.png` | `b20_flame_cinder_v1` | `01a16f43-ea89-7ce1-8bbc-2954e0c71db7` | `exec-31f3abea-d9ad-4c21-a7f3-14dfa0bb46bd.png` | 1536x1024 | `9fd8a3a1e6376461` | weak (11 poses in 4/4/3 rows, but the standing and fade flames sit on a large charred rubble bed and run past the 96 px cell) |
| `flame_cinder_v2.png` | `b20_flame_cinder_v2` | `01a16f43-f042-7091-b09a-95b5995b9556` | `exec-0fd41328-a0a6-4f46-9ad8-5e292cd0a5bd.png` | 1536x1024 | `433158d4ac5156c3` | weak (same rubble bed and oversize flames as v1; the job reported 10 poses, but 11 are present in 4/4/3 rows) |
| `flame_cinder_v3.png` | `b20_flame_cinder_v3` | `01a16f43-f720-7d62-b189-9532400f7b24` | `exec-f6e5d3e4-1dcf-4425-baee-c365cb9d12c2.png` | 1536x1024 | `c20fa52bc5b727f1` | ok (11 poses in 4/4/3 rows; smoke on the last two fade poses is subtle) |
| `slug_tallow_v1.png` | `b20_slug_tallow_v1` | `01a16f44-11ae-7e31-84bd-41d3be7eb71d` | `exec-1980340c-3ef3-4447-8c34-e05e0d1f1357.png` | 1536x1024 | `6ce0cce59c7af7f5` | ok (2 flight poses, 3 splat poses) |
| `slug_tallow_v2.png` | `b20_slug_tallow_v2` | `01a16f44-124d-7db0-83d4-c5c5e3a27a72` | `exec-54929239-f5c4-4515-a483-acbaec87b15e.png` | 1536x1024 | `d18faac825cd5363` | ok (2 flight poses, 3 splat poses) |
| `slug_tallow_v3.png` | `b20_slug_tallow_v3` | `01a16f44-35c0-7113-9591-d0b87bda824f` | `exec-70507bc8-4ec0-46f5-9365-4f21c9587d5f.png` | 1536x1024 | `ad739268a4010531` | weak (the two flight poses look nearly identical; the longer, fainter streak of pose 2 is not clear) |

## Batch 20 totals

18 images verified (SHA-256 matches the own-session folder for every file; no duplicate hashes in `tools/source_art/`).
Ok: 10 (`icon_base_hook` v1 to v3, `icon_base_flare` v1 to v3, `icon_base_ward_v1`, `flame_cinder_v3`, `slug_tallow_v1`, `slug_tallow_v2`).
Weak: 8 (`item_reel_line` v1 to v3, `icon_base_ward_v2`, `icon_base_ward_v3`, `flame_cinder_v1`, `flame_cinder_v2`, `slug_tallow_v3`).
Failed: 0. Weak images stay in the source folder for the owner's cull.
