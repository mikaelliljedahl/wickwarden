# Batch 24 log (19 images)

Prompts: `tools/art_prompts/batch_24.md` (job id in each heading). Backend codex, model `cheapest` (gpt-6-luna, effort medium), one image per job. Each output is checked byte-identical (SHA-256) against its own session folder under `~/.codex/generated_images/<session>/`. Verdicts: ok, weak (why), failed.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `fragment_c7_v3.png` | `b24_fragment_c7_v3` | `01a16f56-5f6d-78c1-b2a4-daa5cd5a30d9` | `exec-49881c64-b6f9-43cb-aeb1-a7f219d89dc6.png` | 1536x1024 | `496016e73957c91a` | ok (Courage: red shard, four glow poses) |
| `fragment_c8_v1.png` | `b24_fragment_c8_v1` | `01a16f56-684a-7de0-aab4-02bba18c3b14` | `exec-8137a157-6290-41bc-93d0-7e93fed02646.png` | 1536x1024 | `25bc5c908538a658` | ok (Trade: bronze-gold glass with a coin disc, four glow poses) |
| `fragment_c8_v2.png` | `b24_fragment_c8_v2` | `01a16f56-6c89-7de3-9047-9effb66ef79a` | `exec-d3d8e52e-a315-4910-8faf-fecc1d12ed7e.png` | 1536x1024 | `26e21c72ccf1754d` | weak (Trade: the coin disc sits high in pose 3 and projects in front of the glass; the glow order is off) |
| `fragment_c8_v3.png` | `b24_fragment_c8_v3` | `01a16f56-744a-7893-957f-31448905614e` | `exec-a60503c5-3aa0-48cc-bc09-c82925c97ce5.png` | 1536x1024 | `559a4c9b47f51006` | ok (Trade: coin disc visible, glow order clear) |
| `fragment_c9_v1.png` | `b24_fragment_c9_v1` | `01a16f56-7bfc-7510-b0db-a2ebed1e0553` | `exec-400d12e0-15b2-4dcf-b853-2b30cef0a88f.png` | 1536x1024 | `d1e6d3385f976597` | weak (Corrow's Last Wick: the glass reads dark grey-bronze rather than black; the third pose is brighter than medium; broad gold base) |
| `fragment_c9_v2.png` | `b24_fragment_c9_v2` | `01a16f56-838f-7e13-8527-a7c56cce4aed` | `exec-372230ad-1b50-4602-b39d-6107e654aa37.png` | 1536x1024 | `db49ed9738cecb06` | ok (Corrow's Last Wick: dark glass with a pale white wick flame, four poses) |
| `fragment_c9_v3.png` | `b24_fragment_c9_v3` | `01a16f57-b8b8-7bc1-bdaa-a8e03160980e` | `exec-9a11dfc2-403c-48ce-9505-56f0585c28b7.png` | 1536x1024 | `bd2f1ba27d3526fa` | weak (Corrow's Last Wick: smoky grey-silver glass rather than black; the background reads pinkish) |
| `slag_chunk_v1.png` | `b24_slag_chunk_v1` | `01a16f57-ba94-76e3-8823-3cc4f286182a` | `exec-69530920-11e5-45ac-8ad7-d505d54e977f.png` | 1536x1024 | `c4abe25c88b03b88` | weak (the cracks glow orange like molten lava rather than cooled slag; hit frames have many flying chips) |
| `slag_chunk_v2.png` | `b24_slag_chunk_v2` | `01a16f57-c15a-77a1-a855-b2c1934249c5` | `exec-d3f1d688-74d9-46bb-b964-bccef0813176.png` | 1536x1024 | `21b3d1a95e7960fe` | weak (the slag reads bright orange and molten, not dark grey-black) |
| `slag_chunk_v3.png` | `b24_slag_chunk_v3` | `01a16f57-c936-7041-81df-01fc77de08f8` | `exec-2ac94f39-7f69-46bd-b89c-33ece0c12aef.png` | 1536x1024 | `3d726ceb68a2b63a` | weak (a strong orange molten glow, not subtle rust-red glints; more cracking and debris than asked; the three slag variants share the glow problem) |
| `thorn_hedge_v1.png` | `b24_thorn_hedge_v1` | `01a16f57-d118-7e30-a47f-78cc5442013c` | `exec-943c2af9-755c-403f-a0dc-71f657e789bc.png` | 1536x1024 | `70e7e120764e64a6` | ok (closed hedge, five burning poses in order, burnt-open gap; a faint orange tint on the closed hedge in the montage, acceptable) |
| `thorn_hedge_v2.png` | `b24_thorn_hedge_v2` | `01a16f57-d733-7b91-bddd-f6198b71e3bb` | `exec-c1b9a420-c0b4-46dc-8b08-e9af5a839b94.png` | 1536x1024 | `6b3053357cf4eaf9` | ok (closed, five burning, burnt open; clear states) |
| `thorn_hedge_v3.png` | `b24_thorn_hedge_v3` | `01a16f59-3652-7590-b12e-fa53f283162e` | `exec-1c4e1d66-b68a-4d29-9fff-bb884032cd1f.png` | 1536x1024 | `4a8abda07c8da2eb` | weak (soft magenta spill around the sprite edges; the cut step needs a despill check) |
| `thorn_wall_v1.png` | `b24_thorn_wall_v1` | `01a16f59-435f-72a1-bab3-cba31cf1121b` | `exec-ade64a31-0ab6-4441-a07a-a79e2f07cbaf.png` | 1536x1024 | `3e5c36bd26fa46a0` | ok (closed wall, five burning poses, burnt-open passage) |
| `thorn_wall_v2.png` | `b24_thorn_wall_v2` | `01a16f59-4310-7993-a5a9-4b14a63d7ca5` | `exec-e9750b27-ff4b-4428-919b-b627a407a2e0.png` | 1536x1024 | `26b6ecb1684e46e1` | ok (the first and last burning poses are close to the closed wall, but the states are readable) |
| `thorn_wall_v3.png` | `b24_thorn_wall_v3` | `01a16f59-4c86-7d42-aae1-15d0c89314e6` | `exec-a99f1026-c07a-4862-8b84-a68f1b459031.png` | 1536x1024 | `572a8c20c61a114d` | ok (moss on the wall top; closed, five burning, open) |
| `thorn_door_v1.png` | `b24_thorn_door_v1` | `01a16f59-52dd-7a02-a24a-31d858a64b4a` | `exec-56b99a45-7828-4554-b4a2-a29ae8ec4b19.png` | 1536x1024 | `cbfd8c876f56f078` | ok (sealed door with lock, five burning poses, open doorway; the sealed pose is smaller in the job's own report) |
| `thorn_door_v2.png` | `b24_thorn_door_v2` | `01a16f59-5a46-7470-a193-af883bdf463a` | `exec-48452024-220d-4400-b40b-9001f5f20eed.png` | 1536x1024 | `32938ab9f40a7e65` | ok (sealed door, five burning poses, open doorway) |
| `thorn_door_v3.png` | `b24_thorn_door_v3` | `01a16f5a-7749-7140-9a5b-d354fbfa96bd` | `exec-2a92c648-4595-4d61-9969-cc4f4862dd2a.png` | 1536x1024 | `ef8fd78652ea511e` | ok (sealed door, five burning poses, open doorway) |

## Batch 24 totals

19 images verified (SHA-256 matches the own-session folder for every file; no duplicate hashes in `tools/source_art/`).
Ok: 12 (`fragment_c7_v3`, `fragment_c8_v1`, `fragment_c8_v3`, `fragment_c9_v2`, `thorn_hedge_v1`, `thorn_hedge_v2`, `thorn_wall_v1` to `v3`, `thorn_door_v1` to `v3`).
Weak: 7 (`fragment_c8_v2`, `fragment_c9_v1`, `fragment_c9_v3`, `slag_chunk_v1` to `v3`, `thorn_hedge_v3`).
Failed: 0. Weak images stay in the source folder for the owner's cull. The orange glow of all three slag variants is the main defect; a redo with "dark grey-black slag with rust-red glints only" is the first thing to try.
