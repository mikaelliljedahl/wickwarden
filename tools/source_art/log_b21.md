# Batch 21 log (18 images)

Prompts: `tools/art_prompts/batch_21.md` (job id in each heading). Backend codex, model `cheapest` (gpt-6-luna, effort medium), one image per job. Each output is checked byte-identical (SHA-256) against its own session folder under `~/.codex/generated_images/<session>/`. Verdicts: ok, weak (why), failed.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `reed_raft_vehicle_v1.png` | `b21_reed_raft_vehicle_v1` | `01a16f46-7936-76b0-944a-58b33922f806` | `exec-eb475811-44b7-4e3a-baa1-e912780f0a84.png` | 1536x1024 | `904a4b9fda219e6b` | weak (7 poses in 2/3/2 rows; the dock boards and the post in the board and dock rows are cut at the cell edge) |
| `reed_raft_vehicle_v2.png` | `b21_reed_raft_vehicle_v2` | `01a16f46-8107-74f1-b548-c609540121f8` | `exec-cc52d0ab-1841-4cb3-919b-ddf47f4aa9d3.png` | 1536x1024 | `8465dc3426b433e1` | weak (the landing pieces in the board row are cramped and clipped at the left edge of their cells) |
| `reed_raft_vehicle_v3.png` | `b21_reed_raft_vehicle_v3` | `01a16f46-8864-7e92-a9e0-4393e6c00307` | `exec-7feb32d5-d5f5-4e79-88fa-648ff7d37fd7.png` | 1536x1024 | `35a77486c5a1a055` | weak (dock boards and posts intrude into the three middle poses; magenta fringe at the raft and pier edges) |
| `jar_thrown_v1.png` | `b21_jar_thrown_v1` | `01a16f46-91b3-7802-b279-da277ca83c7d` | `exec-cb0218bf-e258-4909-9250-dd399d561e40.png` | 1536x1024 | `c91551c0b0bc0e0b` | ok (4 tumble poses, 3 shatter poses, the shatter bursts into glass) |
| `jar_thrown_v2.png` | `b21_jar_thrown_v2` | `01a16f46-97e6-7da0-8068-4452a2ad618e` | `exec-d5ea1e61-4b62-4bba-aaca-57c7f0c0d64a.png` | 1536x1024 | `c2daa6ec5f7a5a8c` | weak (the first shatter pose still reads as an intact cracked jar) |
| `jar_thrown_v3.png` | `b21_jar_thrown_v3` | `01a16f46-9e11-7531-a20a-a9762db62ca2` | `exec-805cf2c4-3635-4c9f-a17c-378151be8737.png` | 1536x1024 | `beb40580514954bf` | weak (the first shatter pose still reads as an intact cracked jar) |
| `jar_lit_v1.png` | `b21_jar_lit_v1` | `01a16f48-5347-7142-a8a2-7392afbfc31c` | `exec-22e563fc-af0e-464e-871c-f9b3e6565e81.png` | 1536x1024 | `a17c3e0d3708d536` | ok (4 poses, glow levels differ; the vessel is an ornate heart-shaped lantern, not a plain jar) |
| `jar_lit_v2.png` | `b21_jar_lit_v2` | `01a16f48-57c1-7233-b58d-e21c501b2372` | `exec-3096e15a-06b6-4ece-8f09-ab034fde96f1.png` | 1536x1024 | `f487806740e7399a` | weak (glow almost the same in all four poses; pose 3 has a detached bright spot; heart-shaped vessel) |
| `jar_lit_v3.png` | `b21_jar_lit_v3` | `01a16f48-5fcd-71c2-889f-e7108cd68578` | `exec-c440a73b-5710-4f2a-8189-1265cc4c592d.png` | 1536x1024 | `c30376bc6d409920` | ok (4 poses, the glow varies; heart-shaped vessel as in v1) |
| `reel_tip_v1.png` | `b21_reel_tip_v1` | `01a16f48-6893-79f1-a4a9-9e0f6acf7f82` | `exec-8504690c-ceb5-4234-9543-0379967457c3.png` | 1536x1024 | `6f62c40d526f0312` | ok (2 poses: open and closed hook with a spark; the cord tail is extra but acceptable) |
| `reel_tip_v2.png` | `b21_reel_tip_v2` | `01a16f48-755d-7831-893c-a68994ae466a` | `exec-b8e2494a-4e14-4567-a17f-164245e637c0.png` | 1536x1024 | `186fecd51c1247f1` | ok (2 poses, subtle difference; cord ends fade) |
| `reel_tip_v3.png` | `b21_reel_tip_v3` | `01a16f48-7734-7c52-86fc-7de6834db185` | `exec-fdd53b53-1d37-4da8-b0d9-de876d4a9b2e.png` | 1536x1024 | `983c9aa39eec3e4f` | weak (magenta tint and fuzz on the cord ends; background mildly uneven, a risk for the key removal) |
| `reel_line_rope_v1.png` | `b21_reel_line_rope_v1` | `01a16f49-e900-74b3-844c-2451556d0466` | `exec-8ab8fe04-6681-4d09-9341-26ed6e95ff8b.png` | 1536x1024 | `96cea33db878043b` | ok (one braided cord across the full width over flat magenta) |
| `reel_line_rope_v2.png` | `b21_reel_line_rope_v2` | `01a16f49-ee8f-7f20-96a6-7f3e1d80c887` | `exec-af3f0660-8306-4856-9470-430e55c342e0.png` | 1536x1024 | `b94c62bca0e09ebb` | failed (wrong subject: a reed raft with a dock and posts, no cord; the water strokes and colour fringe reach into the key) |
| `reel_line_rope_v3.png` | `b21_reel_line_rope_v3` | `01a16f49-f602-7e00-b655-5517d8f34d09` | `exec-c537b821-93e4-4db8-a380-90ab9c5828ca.png` | 1536x1024 | `8b74d5a9bb153e05` | ok (one continuous cord across the full width) |
| `liftable_rock_small_v1.png` | `b21_liftable_rock_small_v1` | `01a16f49-fd35-7ad0-80e8-7f0e9e19d388` | `exec-cb4f0246-919e-4f49-a75b-6ea68de609d4.png` | 1536x1024 | `9a1cecbe67fbcf9d` | ok (rock, urn and crate on row 1; four break-puff poses on row 2; the puff sizes vary) |
| `liftable_rock_small_v2.png` | `b21_liftable_rock_small_v2` | `01a16f4a-059c-7930-a417-3267e502cf77` | `exec-e2661998-af57-4b16-a6c1-d9a5dd76f58a.png` | 1536x1024 | `f25b1b0226f6f868` | ok (rock, urn and crate; four break-puff poses, slightly cluttered with chips) |
| `liftable_rock_small_v3.png` | `b21_liftable_rock_small_v3` | `01a16f4a-0b8a-7750-b166-110d1f699d15` | `exec-690ccd4b-bbb8-4ef7-b1ce-43cbbb8fbe99.png` | 1536x1024 | `ca5f071f54ce11ee` | weak (the background reads pink rather than pure key; vegetation and flowers clutter the rock, urn and crate) |

## Batch 21 totals

18 images verified (SHA-256 matches the own-session folder for every file; no duplicate hashes in `tools/source_art/`).
Ok: 9 (`jar_thrown_v1`, `jar_lit_v1`, `jar_lit_v3`, `reel_tip_v1`, `reel_tip_v2`, `reel_line_rope_v1`, `reel_line_rope_v3`, `liftable_rock_small_v1`, `liftable_rock_small_v2`).
Weak: 8 (`reed_raft_vehicle` v1 to v3, `jar_thrown_v2`, `jar_thrown_v3`, `jar_lit_v2`, `reel_tip_v3`, `liftable_rock_small_v3`).
Failed: 1 (`reel_line_rope_v2`, wrong subject). Not regenerated here; the owner culls and can ask for a redo of the failed file and of the reed raft sheets (the landing boards and posts are part of the sprite and cut at the cell edge).
