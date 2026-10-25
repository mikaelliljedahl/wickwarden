# Built encounter and reward runtime art selection

Existing-source integration only. Sources are the already committed B13/B14/B15, B18/B19/B23, B26/B28/B29, B54/B55 and B63/B64/B65 productions; their original per-batch source logs and docs/art-provenance.md retain generation/session provenance. This pass creates no images and rewrites no raw source or shared provenance. Binding cells/foot rows come from asset-contract section7 and inventory sizes; actual body radii come from actor scripts. Props use the established height-minus6 foot alignment convention, with actual rectangle/radius override handled by SpriteVisual.

## Source, extraction and output records

Pose intervals below are zero-based [start,end), integers select one pose. A row marked skip contributes to band recognition only and is never published. The existing cutter removes key colour, segments real gaps, applies one shared family scale and aligns its outputs; no cell-grid cuts, per-frame scaling, alpha thresholds or new cutter code.

### hollow_captain_walk_down_v3

- Raw: `tools/source_art/hollow_captain_walk_down_v3.png`; SHA256 `7eb67ae8997e87fd35043bad4daa50a00e4845c4ae0fa153f971b3044c086eb0`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 4 separated poses.
  - `hollow_captain.walk_down` poses `[0, 4]` -> `res://assets/sprites/hollow_captain_walk_down.png`, 4 frames, 8.0fps, loop=True.
  - `hollow_captain.idle_down` poses `0` -> `res://assets/sprites/hollow_captain_idle_down.png`, 1 frames, 1.0fps, loop=True.

### hollow_captain_walk_side_v2

- Raw: `tools/source_art/hollow_captain_walk_side_v2.png`; SHA256 `c09e10e848fe3e62768a45345be191f0ca7988a302eb38ac111a4384967943d5`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 4 separated poses.
  - `hollow_captain.walk_side` poses `[0, 4]` -> `res://assets/sprites/hollow_captain_walk_side.png`, 4 frames, 8.0fps, loop=True.
  - `hollow_captain.idle_side` poses `0` -> `res://assets/sprites/hollow_captain_idle_side.png`, 1 frames, 1.0fps, loop=True.

### thorn_warden_walk_down_v1

- Raw: `tools/source_art/thorn_warden_walk_down_v1.png`; SHA256 `5f0b78f06a052ceb73c947b9df51fd01e59dea13af57d2e27beee78511e07e5d`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 4 separated poses.
  - `thorn_warden.walk_down` poses `[0, 4]` -> `res://assets/sprites/thorn_warden_walk_down.png`, 4 frames, 8.0fps, loop=True.
  - `thorn_warden.idle_down` poses `0` -> `res://assets/sprites/thorn_warden_idle_down.png`, 1 frames, 1.0fps, loop=True.

### thorn_warden_walk_side_v2

- Raw: `tools/source_art/thorn_warden_walk_side_v2.png`; SHA256 `2d3a81c5bfcd3d1950d98b47938977617b010bed40726175405fd09f524affeb`. Byte-identical to committed source.
- Parameters: `{"min_gap": 1}`.
- Row 0: 4 separated poses.
  - `thorn_warden.walk_side` poses `[0, 4]` -> `res://assets/sprites/thorn_warden_walk_side.png`, 4 frames, 8.0fps, loop=True.
  - `thorn_warden.idle_side` poses `0` -> `res://assets/sprites/thorn_warden_idle_side.png`, 1 frames, 1.0fps, loop=True.

### kilnkeeper_p1_down_v3

- Raw: `tools/source_art/kilnkeeper_p1_down_v3.png`; SHA256 `b5c51a7fc28652db2099c9cfb20da9871e83d8a8f881983efc59466f175b89ec`. Byte-identical to committed source.
- Parameters: `{"band_floor": 0.9, "min_gap_y": 1}`.
- Row 0: 2 separated poses.
  - `kilnkeeper.idle_down` poses `[0, 2]` -> `res://assets/sprites/kilnkeeper_idle_down.png`, 2 frames, 8.0fps, loop=True.
- Row 1: 4 separated poses.
  - `kilnkeeper.walk_down` poses `[0, 4]` -> `res://assets/sprites/kilnkeeper_walk_down.png`, 4 frames, 8.0fps, loop=True.
- Row 2: 3 separated poses.
  - `kilnkeeper.slag_fan_down` poses `[0, 3]` -> `res://assets/sprites/kilnkeeper_slag_fan_down.png`, 3 frames, 8.0fps, loop=True.

### kilnkeeper_p1_side_v3

- Raw: `tools/source_art/kilnkeeper_p1_side_v3.png`; SHA256 `10ba92ee0334f06834f6c14fff6635d91fb34e25a1d466461bcc8b34ffe5b786`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 4 separated poses.
  - `kilnkeeper.walk_side` poses `[0, 4]` -> `res://assets/sprites/kilnkeeper_walk_side.png`, 4 frames, 8.0fps, loop=True.
  - `kilnkeeper.idle_side` poses `0` -> `res://assets/sprites/kilnkeeper_idle_side.png`, 1 frames, 1.0fps, loop=True.
- Row 1: skipped/rejected band, no output.

### kilnkeeper_p2_side_v3

- Raw: `tools/source_art/kilnkeeper_p2_side_v3.png`; SHA256 `1636f1455862c578c9720093b7aff28c6a98ac44d2ad3cd2104c9427085a370c`. Byte-identical to committed source.
- Parameters: `{"band_floor": 0.9, "min_gap_y": 1}`.
- Row 0: 4 separated poses.
  - `kilnkeeper_p2.walk_side` poses `[0, 4]` -> `res://assets/sprites/kilnkeeper_p2_walk_side.png`, 4 frames, 8.0fps, loop=True.
  - `kilnkeeper_p2.idle_side` poses `0` -> `res://assets/sprites/kilnkeeper_p2_idle_side.png`, 1 frames, 1.0fps, loop=True.
- Row 1: 3 separated poses.
  - `kilnkeeper_p2.splash_side` poses `[0, 3]` -> `res://assets/sprites/kilnkeeper_p2_splash_side.png`, 3 frames, 8.0fps, loop=True.
- Row 2: 2 separated poses.
  - `kilnkeeper_p2.rush_side` poses `[0, 2]` -> `res://assets/sprites/kilnkeeper_p2_rush_side.png`, 2 frames, 8.0fps, loop=True.

### briar_mother_p1_v1

- Raw: `tools/source_art/briar_mother_p1_v1.png`; SHA256 `0f34dae5ec95b5156d292fc6f94f8842eb64db86a7cc823b8792a8a91bbed208`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 2 separated poses.
  - `briar_canopy.idle` poses `[0, 2]` -> `res://assets/sprites/briar_canopy_idle.png`, 2 frames, 8.0fps, loop=True.
- Row 1: 1 separated poses.
  - `briar_canopy.eye_lost` poses `0` -> `res://assets/sprites/briar_canopy_eye_lost.png`, 1 frames, 1.0fps, loop=True.

### briar_bloom_p2_v1

- Raw: `tools/source_art/briar_bloom_p2_v1.png`; SHA256 `125bac23860d29980676029d3a7f66bc3bfb044afd9792797660917a4bb39ced`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 2 separated poses.
  - `briar_bloom.idle` poses `[0, 2]` -> `res://assets/sprites/briar_bloom_idle.png`, 2 frames, 8.0fps, loop=True.
- Row 1: 2 separated poses.
  - `briar_bloom.sweep` poses `[0, 2]` -> `res://assets/sprites/briar_bloom_sweep.png`, 2 frames, 8.0fps, loop=True.

### seed_eye_v1

- Raw: `tools/source_art/seed_eye_v1.png`; SHA256 `9bc5931703e3186d07b1a4810b8fea7bdfb6541062f21119ae6d7467cadaa9cc`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 1 separated poses.
  - `briar_eye.raised` poses `0` -> `res://assets/sprites/briar_eye_raised.png`, 1 frames, 1.0fps, loop=True.
- Row 1: 3 separated poses.
  - `briar_eye.lower` poses `[0, 3]` -> `res://assets/sprites/briar_eye_lower.png`, 3 frames, 8.0fps, loop=False.
- Row 2: 2 separated poses.
  - `briar_eye.idle` poses `[0, 2]` -> `res://assets/sprites/briar_eye_idle.png`, 2 frames, 8.0fps, loop=True.
- Row 3: 2 separated poses.
  - `briar_eye.spore` poses `[0, 2]` -> `res://assets/sprites/briar_eye_spore.png`, 2 frames, 8.0fps, loop=True.

### briar_seed_v1

- Raw: `tools/source_art/briar_seed_v1.png`; SHA256 `60ec8ee12f3e1200700029a6db2ebd115427790ec03718829289947fab9c7e4b`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 1 separated poses.
  - `briar_seed.fall` poses `0` -> `res://assets/sprites/briar_seed_fall.png`, 1 frames, 1.0fps, loop=True.
- Row 1: 2 separated poses.
  - `briar_seed.idle` poses `[0, 2]` -> `res://assets/sprites/briar_seed_idle.png`, 2 frames, 8.0fps, loop=True.
- Row 2: 4 separated poses.
  - `briar_seed.burst` poses `[0, 4]` -> `res://assets/sprites/briar_seed_burst.png`, 4 frames, 8.0fps, loop=False.

### sump_lurker_v3

- Raw: `tools/source_art/sump_lurker_v3.png`; SHA256 `f0fe614096b3e593323402fb9977fb6caceb69cc815268425125e61277ddfc86`. Byte-identical to committed source.
- Parameters: `{"min_gap": 1}`.
- Row 0: 3 separated poses.
  - `sump_lurker.surface` poses `[0, 3]` -> `res://assets/sprites/sump_lurker_surface.png`, 3 frames, 8.0fps, loop=False.
- Row 1: 3 separated poses.
  - `sump_lurker.bite` poses `[0, 3]` -> `res://assets/sprites/sump_lurker_bite.png`, 3 frames, 8.0fps, loop=False.
- Row 2: 4 separated poses.
  - `sump_lurker.idle` poses `[0, 2]` -> `res://assets/sprites/sump_lurker_idle.png`, 2 frames, 8.0fps, loop=True.
  - `sump_lurker.spit` poses `[2, 4]` -> `res://assets/sprites/sump_lurker_spit.png`, 2 frames, 8.0fps, loop=True.
- Row 3: 3 separated poses.
  - `sump_lurker.dive` poses `[0, 3]` -> `res://assets/sprites/sump_lurker_dive.png`, 3 frames, 8.0fps, loop=False.

### tidewick_head_side_v1

- Raw: `tools/source_art/tidewick_head_side_v1.png`; SHA256 `4f3e49a46361ba82d12de0f9d434db3d7432ea9ebd82eff55909ab2699ec8eca`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 2 separated poses.
  - `tidewick_head.walk_side` poses `[0, 2]` -> `res://assets/sprites/tidewick_head_walk_side.png`, 2 frames, 8.0fps, loop=True.
  - `tidewick_head.idle_side` poses `[0, 2]` -> `res://assets/sprites/tidewick_head_idle_side.png`, 2 frames, 8.0fps, loop=True.
- Row 1: 2 separated poses.
  - `tidewick_head.spit_side` poses `[0, 2]` -> `res://assets/sprites/tidewick_head_spit_side.png`, 2 frames, 8.0fps, loop=True.
- Row 2: 2 separated poses.
  - `tidewick_head.scorched_side` poses `[0, 2]` -> `res://assets/sprites/tidewick_head_scorched_side.png`, 2 frames, 8.0fps, loop=True.

### tidewick_head_down_v1

- Raw: `tools/source_art/tidewick_head_down_v1.png`; SHA256 `5bc9b7e64d8e3ce8893c9ae572dd83c94b1616685131141866e4a6de63817d9a`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 2 separated poses.
  - `tidewick_head.walk_down` poses `[0, 2]` -> `res://assets/sprites/tidewick_head_walk_down.png`, 2 frames, 8.0fps, loop=True.
  - `tidewick_head.idle_down` poses `[0, 2]` -> `res://assets/sprites/tidewick_head_idle_down.png`, 2 frames, 8.0fps, loop=True.

### tidewick_body_v1

- Raw: `tools/source_art/tidewick_body_v1.png`; SHA256 `4d80fab828760e4ceaca5c56b06dcd7b34d3fddc3e5b55f0e6da2be6a0c21453`. Byte-identical to committed source.
- Parameters: `{"min_gap": 1, "noise_area": 500}`.
- Row 0: 2 separated poses.
  - `tidewick_body.idle` poses `[0, 2]` -> `res://assets/sprites/tidewick_body_idle.png`, 2 frames, 8.0fps, loop=True.
- Row 1: 1 separated poses.
  - `tidewick_body.reverse` poses `0` -> `res://assets/sprites/tidewick_body_reverse.png`, 1 frames, 1.0fps, loop=True.

### tidewick_tail_v1

- Raw: `tools/source_art/tidewick_tail_v1.png`; SHA256 `4a0d2b95bff6fb726ac1db942350d957f7edb2d3e6a171c49a6ad8464a35d75e`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 2 separated poses.
  - `tidewick_tail.idle` poses `[0, 2]` -> `res://assets/sprites/tidewick_tail_idle.png`, 2 frames, 8.0fps, loop=True.
- Row 1: 3 separated poses.
  - `tidewick_tail.surface` poses `[0, 3]` -> `res://assets/sprites/tidewick_tail_surface.png`, 3 frames, 8.0fps, loop=False.
- Row 2: 4 separated poses.
  - `tidewick_tail.exposed` poses `[0, 4]` -> `res://assets/sprites/tidewick_tail_exposed.png`, 4 frames, 8.0fps, loop=True.

### cinder_wisp_v1

- Raw: `tools/source_art/cinder_wisp_v1.png`; SHA256 `f904ad74e217d148b2d8ba5d13cef5a848cc9dd43b11432b6cb5588a505a5eef`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 4 separated poses.
  - `cinder_wisp.idle` poses `[0, 4]` -> `res://assets/sprites/cinder_wisp_idle.png`, 4 frames, 8.0fps, loop=True.
  - `cinder_wisp.move` poses `[0, 4]` -> `res://assets/sprites/cinder_wisp_move.png`, 4 frames, 8.0fps, loop=True.
- Row 1: 2 separated poses.
  - `cinder_wisp.swell` poses `[0, 2]` -> `res://assets/sprites/cinder_wisp_swell.png`, 2 frames, 8.0fps, loop=True.

### husk_hound_walk_side_v2

- Raw: `tools/source_art/husk_hound_walk_side_v2.png`; SHA256 `9b0edcdc9255cba7f3df76922eab6ba817bc133dfe2dbe73a03197ef1d403dde`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 4 separated poses.
  - `husk_hound.walk_side` poses `[0, 4]` -> `res://assets/sprites/husk_hound_walk_side.png`, 4 frames, 8.0fps, loop=True.
  - `husk_hound.idle_side` poses `0` -> `res://assets/sprites/husk_hound_idle_side.png`, 1 frames, 1.0fps, loop=True.

### brine_crab_walk_side_v1

- Raw: `tools/source_art/brine_crab_walk_side_v1.png`; SHA256 `51c39dbd2e16e5e3677e12ba0bbbbffde3d858f7c580e72b8df464934ec9f1c8`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 4 separated poses.
  - `brine_crab.walk_side` poses `[0, 4]` -> `res://assets/sprites/brine_crab_walk_side.png`, 4 frames, 8.0fps, loop=True.
  - `brine_crab.idle_side` poses `0` -> `res://assets/sprites/brine_crab_idle_side.png`, 1 frames, 1.0fps, loop=True.

### item_cinder_wick_v1

- Raw: `tools/source_art/item_cinder_wick_v1.png`; SHA256 `82019fa059ca680af963cd452467aaf5f9410f23d2b59e838cbef40ddaec30ee`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 1 separated poses.
  - `item_cinder_wick.idle` poses `0` -> `res://assets/sprites/item_cinder_wick_idle.png`, 1 frames, 1.0fps, loop=True.
- Row 1: 3 separated poses.
  - `item_cinder_wick.glint` poses `[0, 3]` -> `res://assets/sprites/item_cinder_wick_glint.png`, 3 frames, 8.0fps, loop=True.

### item_tallow_sling_v1

- Raw: `tools/source_art/item_tallow_sling_v1.png`; SHA256 `1584ce65be167daa7ebda77a552619f74fe80a4c096ee3d2ddd4bfca18353f22`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 1 separated poses.
  - `item_tallow_sling.idle` poses `0` -> `res://assets/sprites/item_tallow_sling_idle.png`, 1 frames, 1.0fps, loop=True.
- Row 1: 3 separated poses.
  - `item_tallow_sling.glint` poses `[0, 3]` -> `res://assets/sprites/item_tallow_sling_glint.png`, 3 frames, 8.0fps, loop=True.

### item_reed_raft_v1

- Raw: `tools/source_art/item_reed_raft_v1.png`; SHA256 `27c8007ce5abeca813144440fccb7a7487773eeaaf1cc01a67dce2c5c6609145`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 1 separated poses.
  - `item_reed_raft.idle` poses `0` -> `res://assets/sprites/item_reed_raft_idle.png`, 1 frames, 1.0fps, loop=True.
- Row 1: 3 separated poses.
  - `item_reed_raft.glint` poses `[0, 3]` -> `res://assets/sprites/item_reed_raft_glint.png`, 3 frames, 8.0fps, loop=True.

### fragment_c1_v1

- Raw: `tools/source_art/fragment_c1_v1.png`; SHA256 `f0ca630efbfd61c1b97723fc28658db3ae194034d762708ba00ddfcc71ac1670`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 4 separated poses.
  - `fragment_c1.idle` poses `[0, 4]` -> `res://assets/sprites/fragment_c1_idle.png`, 4 frames, 8.0fps, loop=True.

### fragment_c2_v1

- Raw: `tools/source_art/fragment_c2_v1.png`; SHA256 `eb708fe8554531b9f228270d2afc8ae47b6faf4ca4f6d2b70566fdd9c6de07ca`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 4 separated poses.
  - `fragment_c2.idle` poses `[0, 4]` -> `res://assets/sprites/fragment_c2_idle.png`, 4 frames, 8.0fps, loop=True.

### fragment_c3_v1

- Raw: `tools/source_art/fragment_c3_v1.png`; SHA256 `a4253e687e7c2147401362b773b6937465a69dcbcf4e80a0bfcd65211968c0a0`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 4 separated poses.
  - `fragment_c3.idle` poses `[0, 4]` -> `res://assets/sprites/fragment_c3_idle.png`, 4 frames, 8.0fps, loop=True.

### moss_wall_v1

- Raw: `tools/source_art/moss_wall_v1.png`; SHA256 `7569f3420c958c6161c87d13731401476e45b0270c268d49bff271c7edcc35c8`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 1 separated poses.
  - `moss_wall.idle` poses `0` -> `res://assets/sprites/moss_wall_idle.png`, 1 frames, 1.0fps, loop=True.
- Row 1: skipped/rejected band, no output.

### wax_seal_v3

- Raw: `tools/source_art/wax_seal_v3.png`; SHA256 `3869cc73e4a395dfb82da838aacea6132365a2b28d5d454d1d1301f744b0c523`. Byte-identical to committed source.
- Parameters: `{"min_gap": 1}`.
- Row 0: 1 separated poses.
  - `wax_seal.idle` poses `0` -> `res://assets/sprites/wax_seal_idle.png`, 1 frames, 1.0fps, loop=True.
- Row 1: 5 separated poses.
  - `wax_seal.melt` poses `[0, 5]` -> `res://assets/sprites/wax_seal_melt.png`, 5 frames, 8.0fps, loop=False.
- Row 2: 1 separated poses.
  - `wax_seal.open` poses `0` -> `res://assets/sprites/wax_seal_open.png`, 1 frames, 1.0fps, loop=True.

### anchor_ring_v2

- Raw: `tools/source_art/anchor_ring_v2.png`; SHA256 `2bad3debb5c212a4eb35612cd2e60a7fe14765c69aa09508aafda289c853124b`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 3 separated poses.
  - `anchor_ring.idle` poses `0` -> `res://assets/sprites/anchor_ring_idle.png`, 1 frames, 1.0fps, loop=True.

### anchor_pocket_v1

- Raw: `tools/source_art/anchor_pocket_v1.png`; SHA256 `2fc19382561deba5aed8492713e9828a0ccce654e4c87a65b2be9573e72ed676`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 3 separated poses.
  - `anchor_pocket.idle` poses `0` -> `res://assets/sprites/anchor_pocket_idle.png`, 1 frames, 1.0fps, loop=True.

### boss_door_v1

- Raw: `tools/source_art/boss_door_v1.png`; SHA256 `012cd583b5657a54ad77eca41095e7f3dc06102d372571a2044e693e2fb8f704`. Byte-identical to committed source.
- Parameters: `{}`.
- Row 0: 1 separated poses.
  - `boss_door.idle` poses `0` -> `res://assets/sprites/boss_door_idle.png`, 1 frames, 1.0fps, loop=True.
- Row 1: 4 separated poses.
  - `boss_door.unlock` poses `[0, 4]` -> `res://assets/sprites/boss_door_unlock.png`, 4 frames, 8.0fps, loop=False.
- Row 2: 1 separated poses.
  - `boss_door.open` poses `0` -> `res://assets/sprites/boss_door_open.png`, 1 frames, 1.0fps, loop=True.

## Runtime interface

| Key | Cell | Foot | Anchor | Body radius / prop footprint |
|---|---|---|---|---|
| `hollow_captain` | [256, 256] | 236 | [128.0, 206.0] | 30 |
| `thorn_warden` | [256, 256] | 236 | [128.0, 206.0] | 30 |
| `kilnkeeper` | [512, 512] | 470 | [256.0, 410.0] | 60 |
| `kilnkeeper_p2` | [512, 512] | 470 | [256.0, 410.0] | 60 |
| `briar_canopy` | [768, 512] | centre | [384.0, 256.0] | none |
| `briar_bloom` | [512, 512] | centre | [256.0, 256.0] | none |
| `briar_eye` | [128, 192] | 180 | [64.0, 154.0] | 26 |
| `briar_seed` | [128, 128] | centre | [64.0, 64.0] | none |
| `sump_lurker` | [384, 384] | 340 | [192.0, 300.0] | 40 |
| `tidewick_head` | [256, 256] | centre | [128.0, 128.0] | none |
| `tidewick_body` | [192, 192] | centre | [96.0, 96.0] | none |
| `tidewick_tail` | [256, 256] | centre | [128.0, 128.0] | none |
| `cinder_wisp` | [128, 128] | centre | [64.0, 64.0] | none |
| `husk_hound` | [192, 192] | 176 | [96.0, 150.0] | 26 |
| `brine_crab` | [192, 192] | 176 | [96.0, 146.0] | 30 |
| `item_cinder_wick` | [96, 96] | 88 | [48.0, 88.0] | none |
| `item_tallow_sling` | [96, 96] | 88 | [48.0, 88.0] | none |
| `item_reed_raft` | [96, 96] | 88 | [48.0, 88.0] | none |
| `fragment_c1` | [96, 96] | 88 | [48.0, 88.0] | none |
| `fragment_c2` | [96, 96] | 88 | [48.0, 88.0] | none |
| `fragment_c3` | [96, 96] | 88 | [48.0, 88.0] | none |
| `moss_wall` | [192, 192] | 186 | [96.0, 186] | rect_h 96 (overridable) |
| `wax_seal` | [192, 192] | 186 | [96.0, 186] | rect_h 96 (overridable) |
| `anchor_ring` | [128, 160] | 154 | [64.0, 154] | rect_h 48 (overridable) |
| `anchor_pocket` | [192, 192] | 186 | [96.0, 186] | rect_h 48 (overridable) |
| `boss_door` | [192, 288] | 282 | [96.0, 282] | rect_h 96 (overridable) |

## Selection reasons and retained limits

- Captain downv3 and sidev2 keep four contained body poses. All source guards remain lantern cages instead of round brass guards; no altered design is invented. Thorn downv1 has limited stride difference; sidev2 is contained and readable, with min_gap1 to separate close but non-touching poses. No up sheet is claimed valid where source facings failed.
- Kilnkeeper p1 downv3 and sidev3 are the strongest logged body layouts. Down uses band_floor0.9/min_gap_y1 to retain distinct 2/4/3 bands without removing faint pixels. P1 side publishes only the clean four-pose walk row; lower rush/recover band is interleaved and skipped. P2 uses sidev3: band settings separate4/3/2. The cracked body is phase-specific existing art, with walk/idle/splash/rush; p2 down molten sheets have bridged smoke and are deliberately not published. Both phases use the exact same scale factor over all selected references. P2 rush pose1 is shifted horizontally inside its cell by the existing cutter, never cropped; proof opened.
- Briar canopyv1 and bloomv1 keep their full silhouettes and phase shapes; canopy has painted fruit-eyes and the runtime has separate live eyes, so their compositing remains actor-owner work. Seed-eyev1 supplies the exact runtime briar_eye, not a wrong seed-eye key. Briar-seedv1 supplies falling, landed and burst states. Raised/hidden versus vulnerable eye and seed timings are not changed by this mapping.
- Sumpv3 is cleaner than v1 toothed closed mouth and v2 droplets. Actual source rows are3/3/4/3, not the inventory semantic five-row description: row2 poses0..1 are surfaced idle, poses2..3 water-jet spit. min_gap1 finds their real narrow gap. Shared scale includes all thirteen poses; foot340 stays fixed.
- Tidewick head sidev1/downv1, bodyv1 and tailv1 preserve the same brass/bronze/water palette. Head side faces RIGHT; down faces the viewer. Up sources are not claimed valid rear facings. Body noise_area500/min_gap1 merges detached small ripple fragments into the actual two primary poses, preserving original matte pixels (no destructive removal threshold change). Tail states explicitly distinguish submerged/surfacing/exposed flame. These centred kinds do not subtract actor radii; actor owners must preserve their assembly offsets.
- Cinder-wispv1 gives four hot-ember motion poses and swell2. Hound sidev2 was opened against v1/v3 and has the clearest four strides. Crab sidev1 has the strongest contained claw/leg poses. Other defective rear/front sheets are not substituted as false facings.
- The three item_* pickup sheets v1 contain their own painted pedestal/stand and use96px cells, distinct from vehicle/projectile/UI art. Fragment c1/c2/c3 v1 gives distinct orange/green/cyan glowing lantern glass. Existing vehicle reed_raft and every old key are unchanged. PickupBase must prefer item_<item_id> and fragment_<scope>; this mapping does not patch it.
- Moss-wallv1 closed pose is intact; cut row skipped because Bush removes the blocker. Wax-sealv3 gives distinct closed/melt5/open with min_gap1. Anchor ringv2/pocketv1 publish idle only; targeted streak poses are not claimed ready. Boss-doorv1 publishes closed/unlock4/open at the binding192x288 cell. Geometry, trigger/collider sizes and persistence remain unchanged.

## Verification and integration boundary

Opened raw comparisons `/tmp/new-art-source-audit-{0,1,2}.jpg` and `/tmp/encounter-candidates.jpg`; opened all thirty selected source+output cutter proofs in `/tmp/encounter-cutter-proof-{0,1,2,3,4}.jpg`. Every output and source segmentation was inspected; no selected body overlaps another source pose. Original proofs are `tools/source_art/proofs/<source>_proof.png` (ignored).

`make art-test`:20 tests pass. Targeted Godot11 suites pass: sprite_visual, hollow_captain, thorn_warden, boss_kilnkeeper, boss_briar_mother, sump_lurker, boss_tidewick, cinder_wisp, husk_hound, brine_crab, pickups. `make lint` passes. Temporary headless Dummy harness `/tmp/encounter-key-check.tscn` checks all26 keys attach as SpriteVisual, default textures load, every animation/frame image loads (163 frame checks), expected loop flags and cardinal idle fallbacks. All pass. Existing sprites.json records compare semantically equal and all previously existing sprite PNG hashes compare unchanged against pre-task snapshots. All thirty chosen raw files compare byte-for-byte with committed sources. Existing texture records were preserved through an existing-cutter regeneration in a temporary output directory; old PNG files were not rewritten. No full check or all-room recapture.

Remaining separately owned work: actor adapters for explicit Placeholder overwrites (Kilnkeeper and overlays, Tidewick body/tail/ripple, wax seal, anchor ring/pocket); PickupBase item/fragment selection; phase/action selection and canopy/live-eye compositing; actual post-adapter gameplay captures. No mapping here for unverified kiln plate/pillar/mouth or generic whole-family swaps. Mauler/Archivist and new Ninth/seam/resonance portal keys remain later audit batches, not claimed complete. The separately mentioned purple-circle screenshot path was not present in this worker conversation and has been requested from the lead; colour alone is not an identification.
