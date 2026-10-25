# C04/C05 body and reward art selection

Existing committed B19/B23/B24/B56/B57/B58/B65/B66 source sheets only; per-batch source logs and shared provenance retain original origin/session records. No new image generation, raw edits, actor edits, image editing or cutter edits. Binding cells/foot lines follow asset-contract section7 and inventory; body radii follow actual actor scripts. Existing prop convention height-minus6 is used for the 96px slag chunk; no new normative sizes.

## Runtime key/state contract

| Runtime key | Cell | Foot | Anchor | Animations (frames) |
|---|---|---|---|---|
| `lull_mauler` | [320, 320] | 292 | [160.0, 252.0] | walk_side:4, idle_side:1, walk_down:4, idle_down:1, walk_up:4, idle_up:1 |
| `mauler_slag_chunk` | [96, 96] | 90 | [48.0, 90] | idle:1 |
| `hushed_colossus` | [640, 640] | 600 | [320.0, 510.0] | asleep:1, idle:2, wake_2:2, wake_3:2 |
| `colossus_shard` | [96, 96] | 88 | [48.0, 52.0] | fall:1, idle:1, lying_b:1, lying_c:1, crumble:4 |
| `mirror_warden` | [256, 256] | 236 | [128.0, 206.0] | walk_side:4, idle_side:1 |
| `archivist` | [256, 256] | centre | [128.0, 128.0] | idle:4, float:4, cast:3, blink:3, copy:3, stunned:2, page_break:3, last_page:3 |
| `archivist_decoy` | [256, 256] | centre | [128.0, 128.0] | idle:4, float:4 |
| `choir_warden` | [256, 256] | 236 | [128.0, 206.0] | walk_side:4, idle_side:1, inhale_down:2, note_down:2, recover_down:1 |
| `item_heft_mitts` | [96, 96] | 88 | [48.0, 88.0] | idle:1, glint:3 |
| `item_glow_jar` | [96, 96] | 88 | [48.0, 88.0] | idle:1, glint:3 |
| `fragment_c4` | [96, 96] | 88 | [48.0, 88.0] | idle:1 |
| `fragment_c5` | [96, 96] | 88 | [48.0, 88.0] | idle:4 |

## Existing raw hashes and extraction

Pose indices are zero-based; intervals are [start,end). All selected poses of a family share one scale factor; foot lines stay fixed, and centred actors use alpha-mass centring. No per-frame scaling or hard-alpha cut.

### lull_mauler_walk_side_v1

Raw `tools/source_art/lull_mauler_walk_side_v1.png`, SHA256 `2b5ad810620059e7b80d950f0cd0bf1913b57ee7d520a631f7920d5fee836f3d`; committed bytes unchanged.
Existing-cutter params: `{"min_gap": 1}`.
- Row0: 4 source poses.
  - `lull_mauler.walk_side` poses `[0, 4]` -> `lull_mauler_walk_side.png`; 8fps; loop=True.
  - `lull_mauler.idle_side` poses `0` -> `lull_mauler_idle_side.png`; 1fps; loop=True.

### lull_mauler_walk_down_v1

Raw `tools/source_art/lull_mauler_walk_down_v1.png`, SHA256 `9c8ada014ad34adb627bf7364f30005ce935128dc0ad6c89c2a6b4d37c7c27fc`; committed bytes unchanged.
Existing-cutter params: `{"min_gap": 1}`.
- Row0: 4 source poses.
  - `lull_mauler.walk_down` poses `[0, 4]` -> `lull_mauler_walk_down.png`; 8fps; loop=True.
  - `lull_mauler.idle_down` poses `0` -> `lull_mauler_idle_down.png`; 1fps; loop=True.

### lull_mauler_walk_up_v3

Raw `tools/source_art/lull_mauler_walk_up_v3.png`, SHA256 `42f2bd9783c340dd239b3001055c8aa0c1c0a35bc0f50dc29c50a4f62b15a582`; committed bytes unchanged.
Existing-cutter params: `{"min_gap": 1}`.
- Row0: 4 source poses.
  - `lull_mauler.walk_up` poses `[0, 4]` -> `lull_mauler_walk_up.png`; 8fps; loop=True.
  - `lull_mauler.idle_up` poses `0` -> `lull_mauler_idle_up.png`; 1fps; loop=True.

### slag_chunk_v1

Raw `tools/source_art/slag_chunk_v1.png`, SHA256 `c4abe25c88b03b88c096f477e38b08f2762dacc5a15d45d4e98f31aa4735aae4`; committed bytes unchanged.
Existing-cutter params: `{}`.
- Row0: 3 source poses.
  - `mauler_slag_chunk.idle` poses `0` -> `mauler_slag_chunk_idle.png`; 1fps; loop=True.

### hushed_colossus_body_v1

Raw `tools/source_art/hushed_colossus_body_v1.png`, SHA256 `d39d96761f99966f2e18e249ad9aafb653af469d6782e384f32b3dcc20d2b001`; committed bytes unchanged.
Existing-cutter params: `{}`.
- Row0: 1 source poses.
  - `hushed_colossus.asleep` poses `0` -> `hushed_colossus_asleep.png`; 1fps; loop=True.
- Row1: 2 source poses.
  - `hushed_colossus.idle` poses `[0, 2]` -> `hushed_colossus_idle.png`; 8fps; loop=True.
- Row2: 2 source poses.
  - `hushed_colossus.wake_2` poses `[0, 2]` -> `hushed_colossus_wake_2.png`; 8fps; loop=True.
- Row3: 2 source poses.
  - `hushed_colossus.wake_3` poses `[0, 2]` -> `hushed_colossus_wake_3.png`; 8fps; loop=True.

### colossus_shard_v1

Raw `tools/source_art/colossus_shard_v1.png`, SHA256 `f13b9f8f1f3a150b012b8ed798cfd9c921eb9e64057e737e0152c73f4358e92e`; committed bytes unchanged.
Existing-cutter params: `{"min_gap": 1, "noise_area": 500}`.
- Row0: 1 source poses.
  - `colossus_shard.fall` poses `0` -> `colossus_shard_fall.png`; 1fps; loop=True.
- Row1: 3 source poses.
  - `colossus_shard.idle` poses `0` -> `colossus_shard_idle.png`; 1fps; loop=True.
  - `colossus_shard.lying_b` poses `1` -> `colossus_shard_lying_b.png`; 1fps; loop=True.
  - `colossus_shard.lying_c` poses `2` -> `colossus_shard_lying_c.png`; 1fps; loop=True.
- Row2: 4 source poses.
  - `colossus_shard.crumble` poses `[0, 4]` -> `colossus_shard_crumble.png`; 8fps; loop=False.

### mirror_warden_walk_side_v1

Raw `tools/source_art/mirror_warden_walk_side_v1.png`, SHA256 `b518f98a7aa68689e354e4056e67d646f789b3864b756894240abb23fe5a880f`; committed bytes unchanged.
Existing-cutter params: `{"min_gap": 1}`.
- Row0: 4 source poses.
  - `mirror_warden.walk_side` poses `[0, 4]` -> `mirror_warden_walk_side.png`; 8fps; loop=True.
  - `mirror_warden.idle_side` poses `0` -> `mirror_warden_idle_side.png`; 1fps; loop=True.

### archivist_p1_v1

Raw `tools/source_art/archivist_p1_v1.png`, SHA256 `fc9b3b91bdec85006e58d9dc6dbc992bbe49cbd0d7190258363e88ba72f0c9e9`; committed bytes unchanged.
Existing-cutter params: `{}`.
- Row0: 4 source poses.
  - `archivist.idle` poses `[0, 4]` -> `archivist_idle.png`; 8fps; loop=True.
  - `archivist.float` poses `[0, 4]` -> `archivist_float.png`; 8fps; loop=True.
- Row1: 3 source poses.
  - `archivist.cast` poses `[0, 3]` -> `archivist_cast.png`; 8fps; loop=True.
- Row2: 3 source poses.
  - `archivist.blink` poses `[0, 3]` -> `archivist_blink.png`; 8fps; loop=False.

### archivist_p2_p3_v2

Raw `tools/source_art/archivist_p2_p3_v2.png`, SHA256 `551962f9a9efe1e1ca1c7e69bcd2f085395eeccbdb5518b858fd84f70ff1ee31`; committed bytes unchanged.
Existing-cutter params: `{"band_floor": 0.9, "min_gap_y": 1}`.
- Row0: 3 source poses.
  - `archivist.copy` poses `[0, 3]` -> `archivist_copy.png`; 8fps; loop=True.
- Row1: 2 source poses.
  - `archivist.stunned` poses `[0, 2]` -> `archivist_stunned.png`; 8fps; loop=True.
- Row2: 3 source poses.
  - `archivist.page_break` poses `[0, 3]` -> `archivist_page_break.png`; 8fps; loop=False.
- Row3: 3 source poses.
  - `archivist.last_page` poses `[0, 3]` -> `archivist_last_page.png`; 8fps; loop=True.

### archivist_decoy_v1

Raw `tools/source_art/archivist_decoy_v1.png`, SHA256 `d497b041002be70ea6a73cf920440e9c9da5369ffa3e4a873f558da94dbd3ab6`; committed bytes unchanged.
Existing-cutter params: `{}`.
- Row0: 4 source poses.
  - `archivist_decoy.idle` poses `[0, 4]` -> `archivist_decoy_idle.png`; 8fps; loop=True.
  - `archivist_decoy.float` poses `[0, 4]` -> `archivist_decoy_float.png`; 8fps; loop=True.

### choir_warden_walk_side_v1

Raw `tools/source_art/choir_warden_walk_side_v1.png`, SHA256 `a76ce8af99f026c44065324b02b64087a21bcdb1a2034372a013ec6230c2dd66`; committed bytes unchanged.
Existing-cutter params: `{}`.
- Row0: 4 source poses.
  - `choir_warden.walk_side` poses `[0, 4]` -> `choir_warden_walk_side.png`; 8fps; loop=True.
  - `choir_warden.idle_side` poses `0` -> `choir_warden_idle_side.png`; 1fps; loop=True.

### choir_warden_actions_down_v3

Raw `tools/source_art/choir_warden_actions_down_v3.png`, SHA256 `8a55f1ff98d95b070a4f1131ddf5a7124034be90ab99792e30da64f3a79692a4`; committed bytes unchanged.
Existing-cutter params: `{"noise_area": 500, "split": "components"}`.
- Row0: 4 source poses.
  - `choir_warden.inhale_down` poses `[0, 2]` -> `choir_warden_inhale_down.png`; 8fps; loop=True.
  - `choir_warden.note_down` poses `[2, 4]` -> `choir_warden_note_down.png`; 8fps; loop=True.
- Row1: 1 source poses.
  - `choir_warden.recover_down` poses `0` -> `choir_warden_recover_down.png`; 1fps; loop=True.

### item_heft_mitts_v1

Raw `tools/source_art/item_heft_mitts_v1.png`, SHA256 `5865c5ee2c5dba658c2e15894d3b3b440505f2e16f59160219ed05cdb6e58a1c`; committed bytes unchanged.
Existing-cutter params: `{}`.
- Row0: 1 source poses.
  - `item_heft_mitts.idle` poses `0` -> `item_heft_mitts_idle.png`; 1fps; loop=True.
- Row1: 3 source poses.
  - `item_heft_mitts.glint` poses `[0, 3]` -> `item_heft_mitts_glint.png`; 8fps; loop=True.

### item_glow_jar_v1

Raw `tools/source_art/item_glow_jar_v1.png`, SHA256 `0df3cd8adb5229cb5ec0c653e7f45aaef8be7a5f8017a6bc36972ce2c937d9ee`; committed bytes unchanged.
Existing-cutter params: `{}`.
- Row0: 1 source poses.
  - `item_glow_jar.idle` poses `0` -> `item_glow_jar_idle.png`; 1fps; loop=True.
- Row1: 3 source poses.
  - `item_glow_jar.glint` poses `[0, 3]` -> `item_glow_jar_glint.png`; 8fps; loop=True.

### fragment_c4_v1

Raw `tools/source_art/fragment_c4_v1.png`, SHA256 `bdb88c326fffe9d42c7c131a694d9a7b4adc691fef1d024954488e885de52d00`; committed bytes unchanged.
Existing-cutter params: `{"chroma": false}`.
- Row0: 4 source poses.
  - `fragment_c4.idle` poses `3` -> `fragment_c4_idle.png`; 1fps; loop=True.

### fragment_c5_v1

Raw `tools/source_art/fragment_c5_v1.png`, SHA256 `767f12f8e5e8e839881c968441478ecbb6a290f3d0667f2a8edadb1f87a0fce9`; committed bytes unchanged.
Existing-cutter params: `{}`.
- Row0: 4 source poses.
  - `fragment_c5.idle` poses `[0, 4]` -> `fragment_c5_idle.png`; 8fps; loop=True.

## Visual choices, retained weaknesses and withheld material

Mauler sidev1/downv1/upv3 have contained four-pose rows, with min_gap1 for actual narrow gaps. They retain source design and weak stride variation/downward lean. The action sheets have twelve poses in three groups of four instead of the inventory’s five semantic counts; not published as invented actions. Mauler slag uses the actual runtime mauler_slag_chunk key with slag_chunk_v1 pose0. All three slag variants are more molten-orange than the cooled-grey brief; this is explicitly retained source quality, not a wrong-family substitution.

Colossus bodyv1 is the source-log anchor, with asleep1 and wake1/2/3 pairs. Humanoid seated build is a source weakness shared by all variants. The body already includes arms; no separate arm layer is published without an actor assembly/placement contract. Shardv1 uses the falling pose, three separately named static lying alternatives and crumble4 nonloop. Lying variants do not loop as a shape-changing animation. noise_area500/min_gap1 clusters small detached debris with their own shard, without changing matte pixels. Liftable already uses SpriteVisual and the exact colossus_shard/mauler_slag_chunk keys; carry/throw mechanics are unchanged.

Mirror sidev1 is contained and four poses separate with min_gap1. The shield has bronze/gold detail rather than the pale-silver brief, as recorded by B57; sidev3 adds a conspicuous cape. This maps the correct existing Mirror Warden family and records its weakness. Both real boss and Reflection currently request mirror_warden, so there is no invented mirror-decoy runtime kind. Reflection timing, sensors and reveal cracks remain actor-owned. The six-frame combo spans rows in the action source; not mislabeled as one clean six-frame strip.

Archivist p1v1 supplies float/cast/blink; p2_p3v2 supplies copy/stunned/page_break/last_page. Existing band_floor0.9/min_gap_y1 separates the four strong bands while retaining faint glows. Reject p2_p3v1 for actual overlapping/missing poses and p1v3 for pseudo-writing. Decoyv1 is a distinct paler/no-shadow source, mapped archivist_decoy (no shadow flag). The actual Copy._ready currently explicitly attaches Placeholder with archivist; owner must attach archivist_decoy. Spatter floor hazard and projectile both currently reuse archivist_spatter with incompatible shapes/sizes; this pass does not disguise that problem with one wrong body mapping.

Choir sidev1 is cleanly contained but nearly static, so walk4 retains limited movement quality. Actions downv3 has four top poses (inhale2 then note2) and a lower recover1, separated by existing component segmentation/noise_area500. Ribbons remain attached to the correct figure. No source is claimed to show a better stride than it does.

Dedicated item_heft_mitts/item_glow_jar sources include their painted pedestal, use96px pickup cells and remain distinct from existing tool-use bodies/icons. Fragment c5 preserves four white/gold glow poses. Fragment c4 has subject purple close to the magenta key: default chroma classification visibly turned the glass blue/green. Disabling optional chroma preserves the original opaque purple via continuous colour-distance matte. Bright poses0..2 still have key-contaminated internal/glow patches, so only the clean dim pose3 is published as static idle1. The animation is explicitly withheld pending cleaner existing source/proof or later approved production; not called four clean frames. Opened all three existing variants; all retain purple/key proximity. No raw recolouring or alpha threshold was used.

## Verification

Opened raw source comparisons `/tmp/c45-source-{0,1,2}.jpg`, `/tmp/c45-reward-sources.jpg`, `/tmp/c45-fragment-c4-variants.jpg`; all sixteen source/output cutter proofs opened in `/tmp/c45-cutter-proof-{0,1,2}.jpg`. Final C4 static strip was reopened separately after withholding contaminated glow poses. Original proofs are tools/source_art/proofs/<sheet>_proof.png.

20 art tests pass. Eight targeted Godot suites pass: sprite_visual, lull_mauler, boss_hushed_colossus, mirror_warden, boss_archivist, choir_warden, pickups, liftable. Temporary headless --audio-driver Dummy runtime harness checks all12 keys attach, default textures load, all92 frames load as nonempty images, expected loops and cardinal idle-facing fallbacks work. Prior input kind/scale-group/sheet records, prior runtime entries and all prior sprite PNG hashes compare unchanged against pre-task snapshots. All sixteen selected raw sources compare byte-identical to committed sources. Existing texture metadata regenerated via the unchanged cutter in a temporary output directory; old sprite PNGs untouched.

Global lint attempt found only three max-line-length violations in foreign untracked tests/test_route_cave_4.gd lines26,30,80. Reported to root; no actor/test files changed here. No full-world recapture, push or blanket art-complete claim.

## Screenshot and remaining work

Opened actual supplied `/tmp/codex-clipboard-f09caba8-790b-4e2d-a2e5-6da7df551769.png`; file exists,400x353. Its solid circle with offset dark facing nub matches Placeholder._draw/_draw_facing_nub geometry. The image has no room/HUD/node identifier. Actual Archivist fallback is a rectangle, Colossus radius90, Mirror Warden radius30 pale armour recipe; Choir Warden’s radius30 directional circle is a plausible source-code match at the player-relative display scale. This is a candidate, not a unique actor identification from colour. A room/node identifier or runtime reproduction of that location is still needed to prove which entity the crop depicts.

Briar canopy variants all retain painted fruit-eyes, so none is a clean base to overlay three live eyes without duplication. Clean-base production remains later separately assigned work; no image edits here. B01 wax-plate/pillar/mouth exact-source absence remains explicit backlog; no wrong substitute is published. Actor-owned work remains phase animation selection, Archivist copy attachment and separate spatter/projection cues.
