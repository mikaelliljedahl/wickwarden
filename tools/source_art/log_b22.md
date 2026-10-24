# Batch 22 log (12 images)

Prompts: `tools/art_prompts/batch_22.md` (job id in each heading). Backend codex, model `cheapest` (gpt-6-luna, effort medium), one image per job. Each output is checked byte-identical (SHA-256) against its own session folder under `~/.codex/generated_images/<session>/`. Verdicts: ok, weak (why), failed.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `slug_bundle_v1.png` | `b22_slug_bundle_v1` | `01a16f4c-1210-7600-9fc3-65c2aa3bad14` | `exec-d44e9fa4-c8b1-4364-a81e-cde5dcf92c34.png` | 1536x1024 | `ccb0ca57e4d71049` | ok (four poses: plain bundle, then glints on the top pellet, the string and the bottom pellet; the third glint is warm, not white) |
| `slug_bundle_v2.png` | `b22_slug_bundle_v2` | `01a16f4c-19be-7441-a2d5-1dfc10047860` | `exec-43ad7f29-7b9a-49b9-b9c6-86779b50095c.png` | 1536x1024 | `bea66186138c2a7c` | ok (same four-pose sequence; glints slightly warm) |
| `slug_bundle_v3.png` | `b22_slug_bundle_v3` | `01a16f4c-1f6e-7662-a2a9-60acbbe23104` | `exec-4e48a070-4649-48f0-a895-10e8bbf295d8.png` | 1536x1024 | `fdd7435fa2db1e3e` | ok (same sequence; the glint of pose 2 has ray-like spikes) |
| `pot_bag_v1.png` | `b22_pot_bag_v1` | `01a16f4c-2787-7a61-a8be-cfae40ca8d10` | `exec-2f01ff06-8be4-4619-8b8e-d1a02295a8dd.png` | 1536x1024 | `a0764cdd0fc1f716` | ok (plain pouch, then glints on the ring, the drawstring and the edge) |
| `pot_bag_v2.png` | `b22_pot_bag_v2` | `01a16f4c-9bbe-7bf1-98c0-6a377062cf67` | `exec-d3fc4374-8369-40bf-b2e3-18c8a9496b35.png` | 1536x1024 | `533ade7ba7e38ff4` | ok (same sequence) |
| `pot_bag_v3.png` | `b22_pot_bag_v3` | `01a16f4c-9dc7-7953-89e9-73c56254c4ae` | `exec-d166f32a-80a0-474b-b64a-3964fd79945a.png` | 1536x1024 | `524cae95683eda77` | ok (same sequence) |
| `tallow_flask_v1.png` | `b22_tallow_flask_v1` | `01a16f4d-f48a-7321-8f23-bca976c3add2` | `exec-2209af9c-e796-41e8-b126-1be407b8557c.png` | 1536x1024 | `a4fec6e1d0686d77` | failed (wrong subject: a heart-shaped glass lantern with a flame inside, with an ornate brass base; not a small round flask of tallow) |
| `tallow_flask_v2.png` | `b22_tallow_flask_v2` | `01a16f4d-fafd-72e0-9ef5-b86dda7f79ba` | `exec-b443cd01-734c-4563-9abe-eef1b7a2a57c.png` | 1536x1024 | `7b6b95fe68172572` | failed (same wrong subject: heart-shaped ornate vessel with a flame, not a round flask) |
| `tallow_flask_v3.png` | `b22_tallow_flask_v3` | `01a16f4e-06eb-7311-884e-756ccdcb3224` | `exec-501accd4-f5bd-45d1-8e5b-0efe2b794b2d.png` | 1536x1024 | `3e8f231a284b6a2b` | failed (same wrong subject: heart-shaped lantern with an internal flame) |
| `bigkey_v1.png` | `b22_bigkey_v1` | `01a16f4e-0d4a-7b00-9975-a248d78a9e89` | `exec-645e39d8-0aa8-42f2-b1b7-e3748ec973c3.png` | 1536x1024 | `e3c144683611ddf7` | weak (bow is a flame crown, not a lantern cage; brass is saturated gold, not neutral pale brass; the last glint has a magenta centre) |
| `bigkey_v2.png` | `b22_bigkey_v2` | `01a16f4e-17bc-7d31-956a-c5e9c4e937bd` | `exec-fccbf139-3d6d-45b3-bf13-9595601949aa.png` | 1536x1024 | `fb06d2aaa31e0ca9` | weak (flame-crown bow instead of a lantern cage; brass saturated gold) |
| `bigkey_v3.png` | `b22_bigkey_v3` | `01a16f4e-19df-7162-8535-87f08e72ff35` | `exec-a6d778e9-46c1-4117-91e2-9300ab6abb8d.png` | 1536x1024 | `3daa96ba672cea99` | weak (lantern-shaped bow with brass bars is the right shape; the shaft is short and stubby and the brass saturated gold) |

## Batch 22 totals

12 images verified (SHA-256 matches the own-session folder for every file; no duplicate hashes in `tools/source_art/`).
Ok: 6 (`slug_bundle` v1 to v3, `pot_bag` v1 to v3).
Weak: 3 (`bigkey` v1 to v3).
Failed: 3 (`tallow_flask` v1 to v3, wrong subject: heart-shaped lantern, not a round flask of tallow). Not regenerated here; the owner decides on a redo, and a stronger wording ("a round stoppered flask, sphere shape, no flame, no lantern") would be the first thing to try.
