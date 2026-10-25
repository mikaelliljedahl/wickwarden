# Current status

Updated 2026-10-25 at 21:23 UTC for the final verified runtime `16df5d1902a1e8fb6108aa117aa971cccefe44a7`. It descends from the prior published checkpoint `dd1ec581d2e80e1ba4a9baa433430a53b801ff15`; no commits follow the tested SHA at this update. The full gate passed on this exact runtime in a detached worktree with Dummy audio from the first import. This documentation update records the new gate and the current pause handoff.

**Final checkpoint gate:** logs are in `/tmp/wickwarden-urgent-final-16df5d1-logs/`. `make check` passed 133/133 Godot suites, clean lint and world-data checks; Python generator/compiler tests passed 172. `rooms-check` passed 221/221, `art-test` passed 22/22, and global ownership passed for 92 work packages and 53 batches (192 rooms, 33 pockets). The isolated run used Dummy audio from the first import. The verifier reported no timeouts, SIGSEGV, engine/script/parse errors, leaks, skips, or waivers. The detached gate worktree was removed after testing. These results apply to `16df5d1902a1e8fb6108aa117aa971cccefe44a7`.

**Included fixes and reviews:** P09's low-fence grate is a permanent physical barrier: the real Tether Moth can fetch through it while the player is blocked; clone placement and missing-art fallback were verified in the actual World. `a7e0f1f` supplies the low-fence helper and `fd5e597` completes P09 runtime/tests. C09 thorn wall, eye cell, ninth fragment, portal, and hidden-seam reveal work are fixed (`909800b`, `aca1fb3`, `ce838b3`, `4c11205`). The sling-ammo HUD icon is in `23f4a1e`; Cinder Wick light is in `a2c6ee8`; Lock Warden plates are in `2c3d481`/`6ec36ff`; B06/B09 and heavy-door presentation are included. Abacus Brute and Pale Squire actor-only cues landed in `47db582`/`b3fcc83`: two focused suites and lint passed, and eight dark before/after captures are available; timings, radii and damage did not change.

M5 Mirror Shade alpha presentation is closed in `d28ec6d`/`c5f109b`: 71 shader proof images, all 12 frames checked against the flat-alpha requirement, and default production GPU rendering reviewed. The all-ten player guide and README link are in `d83944f`, with route correction `bb0821b` independently reviewed PASS at `/tmp/walkthrough-review.md`; later guide update `aaf7d65` records the cave Lockpick rule. The guide is a source-checked route, not a recorded full playthrough. The earlier Archivist SIGSEGV was fixed in `6753dcf`; multiple later global cohorts passed.

**Recent runtime and owner decisions:** decision 47 is implemented by `4fe3f33` and verified in cave route tests at `16df5d1`: each cave Lockpick passively opens every key-locked door in that cave, including the boss door, without consuming held small keys. Before pickup, ordinary locked doors still consume one same-cave small key. Other caves, overworld locks, and elemental/barrier puzzles are unchanged. Existing key retention is verified in C2 and C8. HUD fallback for the purple fragment now uses existing `fragment_c1` art (`fa37150`); its focused test coverage is 580.

**Confirmed regression:** OW10_3 has a real reachability/presentation regression from room build `26dd1`: the decorative hut at `(720, 816)` cannot be reached from its south/front wall, and the functional shop door at `(1200, 288)` floats. The earlier route check followed an old portal and did not validate this route. Reproduction is recorded at `/tmp/ow103-regression-repro.log`; the user's live save was not changed. Next work needs RoomDoor building support/whitelisting, a reachable house or trigger, and a safe route from the pocket. OW10_7 has a similar item flagged for review. Neither issue is fixed. The user's new iframe-breathing-space audit `f05c40` is read-only and active; no value is selected yet. After pause, review ordinary enemy attack invulnerability frames first, while preserving the B07 pitfall exception.

**Open work and preserved WIP:** B09 body/keyhole art remains on HOLD. Gloam Knight, Coinwyrm, Ninth Lantern and B01 mouth art remain open or on HOLD. Cue polish remains for Lull Mauler, Hushed Colossus, Dirge Choir, Wick Automaton, Corrow's Echo, Hollow Captain, Mirror Warden, Thorn Warden, The Unlit and shared markers. Human balance, Q3 continuous playthrough, Q5 per-room visual review, Q6 economy/soak, full Q7 weakness matrix, Q8 performance, and release remain open. The C1/C5 observation came from a read-only save; no user save was changed. Do not describe the former key behavior as unresolved: the current Lockpick rule is implemented and route-tested.

The worktree has two unstaged tracked changes outside this task: `docs/art-provenance.md` removes 36 FX source rows, and producer-E `tools/art_prompts/PROGRESS_e.md` records batches 43–45 complete while 46–47 remain unstarted. Preserve both. The 77 foreign staged paths retain fingerprint `cc7b8baf06d7e79c8d9ed63e5c68b4e971422c0795514e2e8381c9c1771cf4a3`; preserve the staged index, untracked art candidates, import metadata and UID files.

## World build and functional acceptance

- All **222/222 graph scene targets** are committed: 88 overworld rooms, 104 cave rooms, and 30 separate pocket scenes. The graph has 33 pockets total, three in-place. There are 221 `.room` sources because `cave_1` is hand-authored. No scene output is missing at the observed HEAD.
- Q2's strict inventory and layout checks passed at `c2a5924`; F3's full-graph run passed 1,136 checks at `92786ea`. The earlier C07 moth-pit and C09 reel/refill graph-validator flags were false positives, not content defects. A separate real B07 streamed pit-return issue was fixed in `5f69076`; its fresh-entry, death-reset, and re-entry checks passed. The binding Q2/Q4 inventory row still says 218 rather than the graph's 222; report the mismatch without changing normative documents.
- C06–C10 functional lead test commits are present: C06 `081518e` (166 headless and 193 render checks), C07 `32e0ab8` (route PASS), C08 `d5e65ad` (150 render checks), C09 `5cd96d9` (40 area, 227 route, 243 render checks), and C10 `1af39cc` (53 area, 243 route, 258 render checks). C09's older OPEN down-throw label has an independent recheck under job `816d3c`, currently marked needs_reconciliation; no result or confirmed reachability defect is available. P06 fix `4e9d1a4` passes 138 checks across all four throw directions.
- Decision 47's cave Lockpick rule is implemented in `4fe3f33`; C2/C8 route tests at `16df5d1` verify held small keys are retained. The earlier read-only save observation (C1 lock and already-open C5 door) did not change the save and is not an open mechanics issue.
- E1 ending flow and branch tests are present (`5728847`, `1af39cc`); ending paintings landed in `b66ddd3` and duplicate stands under painted lanterns were removed in `b905d4d`. This is not a completed continuous earned-route playthrough.

## QA and capture status

- Q1's scene-graph solver is committed and passes. Q2 inventory/layout acceptance is complete at the committed 222-target inventory. Q7 reports **582 passing checks** after Snapper fix `b4449ed`; coverage of all 20 encounters' weakness cases is still pending.
- The committed still-capture baseline `d3cf9a5` renders the 222 room and pocket targets from source snapshot `c2a5924` into 16 labelled area sheets at 480×270 thumbnails, with Dummy audio and isolated user data. This is a capture baseline, not Q5 human visual approval or a human playthrough.
- The previously reproduced Archivist native SIGSEGV was fixed in `6753dcf`; multiple later global cohorts passed, including the full gate at `16df5d1`. It is not a current open bug.
- Remaining QA: Q3 full continuous earned-route playthrough; Q5 human visual review; Q6 soak/economy; complete Q7's 20-encounter weakness coverage; Q8 performance/memory; and Q9/release checks.

## Art and presentation

Source image production is closed at final FX `d2fe1a5` and provenance checkpoint `2fa8c69`. Runtime mapper `02fded4` covers 26 keys. Native-alpha cutter support `62a82aa` passes, with 227 previously cut PNGs byte-identical. The ten found-tool menu icons and equipped HUD icons are integrated; equipped-label fit landed in `9664e50`. The `fd5e597` gate includes reviewed C09 props and seam, pocket exit framing, the sling-ammo HUD icon, Lock Warden plates, B06/B09 presentation, Mirror Shade alpha silhouettes and low-fence grate behavior.

Runtime presentation is not complete. Body and transient-tool fallbacks/placeholders, terrain and pickup/shop visuals, remaining mapping/render cleanup, and human visual review remain. B01 wax plate and kiln pillar are integrated; mouth candidates A–C were rejected for exterior halo/alpha spill. B09's four plate targets are delivered, but its body and keyhole art remain on HOLD. The C1/overworld consumer accepts B art at 104×51 with a clear waist projection against the 64 px target; raw source hash prefix `d463` is accepted without a binding exception. Gloam Knight, Coinwyrm and Ninth Lantern art remain open or on HOLD. Remaining actor cue backlog: Lull Mauler, Hushed Colossus, Dirge Choir, Wick Automaton, Corrow's Echo, Hollow Captain, Mirror Warden, Thorn Warden, The Unlit, and shared markers. No blanket all-art-done claim.

## Current checkpoint boundary and next gate

The shared index contains **77 foreign staged paths** (binary diff fingerprint `cc7b8baf06d7e79c8d9ed63e5c68b4e971422c0795514e2e8381c9c1771cf4a3`); this docs update preserves them and all other foreign work. The user's game audio remains enabled; headless gates use Dummy audio.

The last published runtime is `fd5e59725ff1114881c4d5d567aaf56f8c9017e2` in docs-bearing commit `dd1ec581d2e80e1ba4a9baa433430a53b801ff15`. The current fully verified runtime is `16df5d1902a1e8fb6108aa117aa971cccefe44a7`; this docs-only update is prepared for fast-forward publication and adds no runtime blobs. Preserve the 77 staged paths and all dirty/untracked work. The guide and README link landed in `d83944f`, with route correction `bb0821b` independently reviewed PASS and owner-rule update `aaf7d65`; the guide does not count as Q3. Human balance and visual feel, continuous human playthrough, Q5 per-room review, Q6 soak/economy, complete Q7 weakness coverage, Q8 performance/memory, and release/export acceptance remain open.

## All-ten tool-menu and HUD icon checkpoint

All ten found tools have dedicated painted menu icons, and equipped HUD icons are integrated. The scoped F10 evidence and captures are historical checks of that feature, not a global gate for the current HEAD. Unfound tools retain their silhouettes and question marks.

## Step 1: the dev world (what runs today)

- **World**: 3x2 overworld (`ow_0_0` .. `ow_2_1`) plus the dark `cave_1`, room slides (0.45 s), cave fades (0.3 s),
  enemies respawn on entry, items/doors/walls/pickups stay changed. HUD band, pause menu with the button help.
- **Player**: Tamsin with lamp hook, charge flare, ward, two sub-items. Numbers as in the plan.
- **Enemies**: spitcap (+spore), skitterwick, duskmoth, tallow blob (+drop), hollow, on the shared `EnemyBase`.
- **Items and props**: tether moth, pitch pot (6 pots when the item is found), cracked wall, brazier + gate,
  locked door with small key, bushes, rocks, trees, pond, reeds, ruin walls, huts, sign post.
- **Rooms** (spec: plan section 2; screenshots in `docs/screens/step1/`):

  | Room | Content |
  |---|---|
  | `ow_0_0` | start, huts, sign post, 2 spitcaps |
  | `ow_1_0` | field with rocks and bushes, 3 skitterwicks |
  | `ow_2_0` | ruin, cracked wall to the secret cache with a wick core, 2 hollows |
  | `ow_0_1` | pond and reeds, 4 duskmoths, tether moth on a pedestal |
  | `ow_1_1` | crossroads, 2 tallow blobs, 1 spitcap, cave entrance |
  | `ow_2_1` | dead end, locked door to the pitch pot item |
  | `cave_1` | dark, 2 unlit braziers open a gate to a key, 3 hollows |

- **Route** (all tested): tether moth -> cave entrance -> light both braziers -> key -> locked door -> pitch pot
  (+6 pots) -> cracked wall in `ow_2_0` -> wick core (max hearts 3 -> 4).
- **Tooling**: `make run` (real start), `make dev` (all items, 10 pots, 5 keys, F1 hitbox overlay),
  `tools/capture.tscn` (1920x1080 screenshots incl. flare, charge and pot actions), `make test`, `make check`.
- **Tests**: per-feature suites from WP0-WP6, `tests/test_dev_world.gd` (room contents, layout/reachability on
  the real scenes, a 5 s enemy soak per room, dev loadout), `tests/test_dev_world_route.gd` (the route above).

### Deviations from the step-1 plan

- Pitch pot ammo: still "starts 0" in `GameState`, but picking up the item in the world grants 6
  (`PickupBase.ITEM_FOUND_AMMO`), otherwise the cracked wall could not be opened on the route.
- The cave entrance moved from `(1344, 288)` to the tile centre `(1392, 240)` (spawn marker `FromCave` to
  `(1392, 432)`), so it sits in a rock notch without straddling tiles. `tests/test_world.gd` follows.
- The cave exit is a 2-tile door (192x96) at the bottom of the cave instead of a 1-tile one.
- New placeholder kinds: tree, reed, sign_post, hut. Static props no longer draw the facing nub.
- The HUD item label shows the full name ("Tether Moth") instead of a 9-character cut.

### Step-1 known issues

- The tether moth is not mechanically needed for the route: the plan puts the key behind the braziers, and the
  hook lights them. The moth only comes first by room order and is useful against the hollows.
- The cave is very dark (lamp radius 260 on a near-black room, as in the plan). Unlit braziers are only visible
  close up; there is no hint text in the world by rule. Check the feel in play.
- A pitch pot placed at a cracked wall hurts the player (2 half-hearts, plan) because the wall is within 96 px.
  The player has 1.6 s to step back. Three hearts is enough, but it is tight with a hollow nearby.
- Walking is not simulated end to end: the route test places the player next to each target; reachability of
  everything is proven on the tile grid (`test_dev_world`), and the 5 s soak shows enemies do not clip into
  obstacles. A human playthrough with `make dev` is still the final judge of the feel.
- Skitterwick hops and duskmoth flights slide along obstacles; no special pathing. Hollows walk tile centres, so
  obstacles must stay on the 96 px grid (the layout test enforces the rest).
- The debug overlay draws hit/hurt boxes only, not body or wall shapes.
- Room border (presentation only): `scripts/art/border_edge.gd` gives the wall ring a wavy, per-room deterministic inner
  edge (leaves / rough rock), a contact shadow, a dark band and a lit lip; drawn from `Room._draw`. Collision unchanged.

## Step 2: the art pass (what it adds)

- **Art pipeline**: [asset-contract.md](asset-contract.md) (normative: cells for 96 px tiles, foot line,
  strips, non-destructive post-processing), [art-brief.md](art-brief.md) (style and one prompt per sheet),
  [art-provenance.md](art-provenance.md) (every source sheet with its Codex session, output ID and hash).
  24 step-2 source sheets in `tools/source_art/`; `make art` cuts the sheets listed in `tools/art_manifest.json`
  into `assets/sprites/` and `sprites.json`.
- **Runtime**: `SpriteVisual` (an `AnimatedSprite2D`) replaces `Placeholder` as each entity's `Visual`; it
  builds its frames from the manifest, draws a soft contact shadow and falls back to `Placeholder` for a
  kind without art. `PlayerVisual` picks Tamsin's walk, swing, charge, ward and hurt from her public state.
  Rooms draw world-aligned tiled terrain textures. Water and wall blocks are painted by terrain
  shaders (`assets/shaders/`): touching blocks form one pond with soft, irregular mud banks and a shore
  line, or one ruined wall with a front face, broken top edges and a soft shadow (three-quarter view).
  The collision rectangles are unchanged. The step-1 game logic is unchanged.
- **Walk cycles remade**: the first walk sheets had six near-identical poses per row, so the feet looked still.
  Tamsin's `walk_{down,up,side}` and the hollow's `walk_side` and `walk_up` now come from new sheets with four
  distinct poses (stride, passing, stride, passing; 8 fps); `tamsin_walk.png` stays as the design and scale
  reference only. The hollow's `walk_down` is still from `hush_hollow.png`.
- **Effects**: the hook swing trail (`scripts/art/swing_trail.gd`) and the flare ring
  (`scripts/art/flare_ring.gd`) are procedural, additive light drawn exactly on the hit shapes. The pitch
  pot explosion and the enemy and bush death puffs use the painted explosion strip.
- **Screenshots**: `docs/screens/step2/` (every room, swing, charge, flare, pot, lit brazier, hitboxes).
  `tools/capture.tscn` has a new `--action=swing`.

### Audio

All audio is synthesised by `tools/make_audio.py` (see [audio-provenance.md](audio-provenance.md)); rebuild
with `make audio`. The `Audio` autoload (`scripts/audio/audio.gd`, process mode ALWAYS) offers
`play_sfx(name, at := Vector2.INF, volume_db := 0.0, pitch_jitter := 0.05)` (16 pooled players, 2D when `at`
is given) and `play_music(name)` (1 s crossfade). Buses in `default_bus_layout.tres`: Master, Music (-10 dB), SFX.
Music follows `Events.room_entered`: `cave*` rooms play `cave`, all others `overworld`; it ducks while the tree is
paused. Audio is presentation only: gameplay scripts hold one-line `Audio.play_sfx` calls.

| Sound | Event |
|---|---|
| `swing` | hook swing starts (player) |
| `charge_start`, `charge_ready` | charge begins / reaches full (player) |
| `flare` | charge released (player) |
| `hook_hit`, `enemy_hurt` | hook or flare damages an enemy; any damaging hit (enemy_base) |
| `hook_clank` | hook hits an already lit brazier |
| `bush_cut` | bush cut down |
| `ward_block` | raised ward stops a hitbox |
| `moth_launch`, `stun` | tether moth thrown; an enemy is stunned |
| `pot_place`, `pot_explode` | pitch pot placed; `Events.explosion` |
| `player_hurt`, `player_death` | `Events.player_hurt`, `Events.player_died` |
| `enemy_death` | `Events.enemy_died` |
| `spit` | an enemy fires a projectile (`fire_projectile`) |
| `hollow_dash` | hollow starts its dash |
| `pickup_heart/coin/key/pots/core/item` | `Events.pickup_collected` by kind |
| `gate_open`, `door_unlock`, `wall_break`, `brazier_lit` | gate opens, key unlocks, cracked wall breaks, brazier ignites |
| `room_transition` | `Events.room_entered` (not the first) |
| `pause_open`, `pause_close` | the tree's paused flag changes (watched by the autoload) |
| `menu_move`, `menu_select` | synthesised and loadable, unused: the pause menu has no selectable items |

Not covered: the hook has no hit detection against rocks or walls, so there is no wall-hit sound.

## Open points

- The older C09 OPEN down-throw report has no reconciled result in the current record. The committed P06 change passes four-direction streamed-room checks; do not report a confirmed route failure unless the recheck reproduces one. C09's thorn wall, eye cell and ninth fragment art are mapped in `909800b`.
- Q7's 582 checks pass after `b4449ed`, but the requested 20-encounter weakness coverage is incomplete.
- The Archivist SIGSEGV fix landed in `6753dcf`, and two later global cohorts passed. No current SIGSEGV blocker is recorded.
- Runtime art still has body/transient-tool fallbacks, terrain and pickup/shop gaps, remaining mapping/render cleanup, B09 body/keyhole HOLD, and rejected haloed B01 mouth candidates. Human review is open. P09's low-fence grate fix and actual-World real Moth/player-block/clone/fallback checks passed in `fd5e597`.
- The Abacus Brute and Pale Squire actor-only cue pass is committed (`47db582`, `b3fcc83`); two focused suites and lint passed, and eight dark before/after captures await review. Broader cue cleanup remains open for Lull Mauler, Hushed Colossus, Dirge Choir, Wick Automaton, Corrow's Echo, Hollow Captain, Mirror Warden, Thorn Warden, The Unlit and shared markers.
- M5 Mirror Shade alpha rendering is closed in `d28ec6d`/`c5f109b`, including the default production GPU proof.
- The all-ten walkthrough and README link are committed in `d83944f`; route correction `bb0821b` passed independent review. This is a recommended guide, not a recorded full playthrough.
- The owner has not approved overall balance, visual feel, or a continuous full-game playthrough. Soak/economy, performance/memory, and release/export checks remain open.

## Next steps

1. Publish the verified runtime `16df5d1902a1e8fb6108aa117aa971cccefe44a7` with this docs-only status update to personal `origin/main`; verify the remote SHA.
2. Preserve the foreign staged index, provenance/progress WIP, and untracked art/import/UID work.
3. Fix and verify OW10_3/OW10_7 house access and trigger placement; finish the read-only iframe audit before selecting balance values.
4. Complete Q3 full earned-route playthrough, Q5 per-room visual review, Q6 soak/economy, Q7 weakness coverage, Q8 performance/memory, human balance, and Q9/Z release work.
5. Finish remaining runtime art and obtain human visual approval. Source image production is closed, but the game is not fully art-complete.
