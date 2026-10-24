# Batch 64 generation log (producer g)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job). Each job copied its PNG to `tools/source_art/`; the copy was checked by SHA-256 against the PNG in the job's own `~/.codex/generated_images/<session>/` folder (the only PNG with the same hash), and hashes are unique across `tools/source_art/`. Prompts: `tools/art_prompts/batch_64.md` (the entry heading is the job id). Verdicts are the producer's own view of each image, not the owner's cull.

## Summary (one line per image)

- `briar_bloom_p2_v1.png`: ok - two bloom-idle and two sweep-telegraph poses in two rows; lower-right pose sits near the bottom edge
- `briar_bloom_p2_v2.png`: weak - background reads brighter pink than pure magenta (key drift); the poses are fine
- `briar_bloom_p2_v3.png`: ok - four poses (idle and sweep telegraph) read; poses are large and close to the edges but not clipped
- `briar_seed_v1.png`: ok - falling, landed (two wobble poses) and burst (four shard poses) rows read in order; the final pose has many scattered shards
- `briar_seed_v2.png`: ok - falling, landed and burst rows read; bottom-row debris crowds the gaps a little
- `briar_seed_v3.png`: ok - falling, landed and burst rows read; a few detached fragments and motion streaks near the falling pose
- `tidewick_body_v1.png`: ok - two submerged ripple poses and one reverse-turn segment read; no defects seen
- `tidewick_body_v2.png`: ok - two ripple poses and one reverse-turn segment read; faint magenta streak in the background, not in the subject
- `tidewick_body_v3.png`: weak - magenta-tinted brush strokes extend past the ripple rings, uneven background
- `tidewick_head_down_v1.png`: ok - front view with two poses; glowing eyes and mouth read; no defects seen
- `tidewick_head_down_v2.png`: weak - a coiled neck mass shows behind the head in both poses; second jaw opened wide (front-facing, not clean)
- `tidewick_head_down_v3.png`: ok - front view with two poses; glowing eyes and mouth read; slight fuzz on the rear edge of the left pose
- `tidewick_head_side_v1.png`: ok - three rows (swim, ember spit telegraph, phase-2 scorched) read; design consistent
- `tidewick_head_side_v2.png`: ok - three rows read; the ember glow and scorched head are clear
- `tidewick_head_side_v3.png`: ok - three rows (swim, ember spit telegraph, phase-2 scorched) read in side profile; no defects seen
- `tidewick_head_up_v1.png`: weak - drawn in side profile facing right, not back-facing; the tail sweeps down: facing rule failed
- `tidewick_head_up_v2.png`: weak - reads as a spiked tail section rather than a back-facing head; facing rule failed; slight magenta fringe
- `tidewick_head_up_v3.png`: weak - side profiles with the serpent body extended; not backs to the camera; poses nearly identical

## Details

| File | Codex session | Output ID | SHA-256 (first 16) |
|---|---|---|---|
| `briar_bloom_p2_v1.png` | `01a16f67-caaf-7112-beb6-a3a03114c2a7` | `exec-3e5147bd-6c25-4d4f-9906-03906333d36d` | `125bac23860d2998` |
| `briar_bloom_p2_v2.png` | `01a16f67-cc4c-7782-a0d4-7a9e80de8fb5` | `exec-cdb2623c-a984-471b-ba51-8b2231a7cb27` | `ad43da7066a2dfb0` |
| `briar_bloom_p2_v3.png` | `01a16f67-d01e-7e21-b93d-c1ca4ff9d748` | `exec-439d7bb4-6613-4846-b65a-76e3db20813c` | `91f74765835bce63` |
| `briar_seed_v1.png` | `01a16f63-6c42-7452-9c67-96d2570811f1` | `exec-067b7524-9495-43da-b045-ee2026f22f64` | `60ec8ee12f3e1200` |
| `briar_seed_v2.png` | `01a16f63-7a2d-7f13-a4df-5d8408636aca` | `exec-bcab6331-e6bc-4361-affa-35e13fc7209c` | `192b72f600c6bcce` |
| `briar_seed_v3.png` | `01a16f67-d569-7550-bc4e-66129fb36168` | `exec-c0f51d6b-6c53-4bc2-b392-ab50833752b7` | `5944ed04ee722763` |
| `tidewick_body_v1.png` | `01a16f6b-444a-7f20-af35-efc59a9aba25` | `exec-5012552f-6004-44ac-9eee-8bb7ffa9a6f4` | `4d80fab828760e4c` |
| `tidewick_body_v2.png` | `01a16f6b-4c2d-7023-a11c-69ee81eb9602` | `exec-7a95f182-608a-4cf3-b1a3-0191793d4abd` | `cf44fbb831bab218` |
| `tidewick_body_v3.png` | `01a16f6b-8489-7b63-9467-e8435f0ae06e` | `exec-e9ea38f1-a650-47ba-a84f-4c2df68871de` | `7f31835d0117c943` |
| `tidewick_head_down_v1.png` | `01a16f69-a5be-75b1-862e-e2c840af21ee` | `exec-43f0c03c-0031-4d16-88eb-f56f15ec4f81` | `5bc9b7e64d8e3ce8` |
| `tidewick_head_down_v2.png` | `01a16f69-a9e2-7b53-a866-950b9c940f0a` | `exec-50b1d9cb-426c-4276-9d1f-7507b8cda20a` | `ec42d584ec933218` |
| `tidewick_head_down_v3.png` | `01a16f69-af8d-7e13-a60f-d25524cbca38` | `exec-f08766dd-c4da-4c15-804d-a9639acfa564` | `ee62e9368f7e7bc9` |
| `tidewick_head_side_v1.png` | `01a16f67-de36-7d01-84be-2379cc522bc8` | `exec-eb838121-07f8-40ab-939d-9dde072cd2d4` | `4f3e49a46361ba82` |
| `tidewick_head_side_v2.png` | `01a16f67-e37c-75c2-baa3-b84c94a2f5df` | `exec-1efcdc79-ce07-4262-ad21-2035691f08e3` | `af2ea24e175254c2` |
| `tidewick_head_side_v3.png` | `01a16f69-9bd1-7ad0-8b71-59af3243041c` | `exec-50dfd224-8324-4385-8847-cd8ceeb8a2f9` | `7421c1b15dd93d20` |
| `tidewick_head_up_v1.png` | `01a16f69-be90-7813-a9fd-1271078b225f` | `exec-f14604f1-1708-4ca1-bec0-ee9c2763c280` | `bc279da4052a1966` |
| `tidewick_head_up_v2.png` | `01a16f6a-5216-72a2-b67f-f039ab2fea62` | `exec-3178773b-d7e2-44ac-b665-432f2b9a8f97` | `5b0ca054af04e024` |
| `tidewick_head_up_v3.png` | `01a16f6b-1bf7-7bd1-acd0-9cd5b12f675c` | `exec-be0ebbc4-f113-44b7-ac10-c94b28276bac` | `aaba11a437ba79c6` |
