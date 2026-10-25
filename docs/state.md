# Current status

Updated 2026-10-25 after the verified cohort push. The gated runtime snapshot is `1eebc1eaf59a64ec95c9e904b3257f01e8f46458` (`verified-1eebc1e`); personal `origin/main` was verified at that exact SHA at 2026-10-25 19:59 UTC. The local tip was `4c11205` immediately after the push and has since advanced to `23f4a1ed7218d3d2d99cea0e2328fa7886566668`; neither later commit is covered by this gate.

**Published checkpoint:** the exact verified SHA was pushed as a fast-forward from `7d8741ff8f4972d1629f19d94f96d1693f89bf86` to personal `origin/main`. Independent isolated logs are in `/tmp/wickwarden-cohort-1eebc1e-logs/`. `make check` passed all 133 Godot test files in 18 seconds; lint and world-data checks passed; the Python generator/compiler suite passed 172 tests. `rooms-check` passed 221/221, `art-test` passed 22 tests, and global ownership passed for 92 work packages and 53 room batches (192 rooms, 33 pockets). The verifier reported no script errors, crashes, timeouts, or leaks. Headless graphics used Dummy audio.

The verified snapshot includes the C06–C10 presentation and scene updates through `1eebc1e`: the `ow_10_3` shelter-mouth correction, reviewed cave art mappings, B06 Dirge presentation, B10 Unlit presentation, upright painted heavy doors, Cinder Wick flame lighting, and Mirror Shade reflection animation. It also includes the 16-sheet Q4 contact-capture baseline from `d3cf9a5` (source snapshot `c2a5924`). These results apply to this exact snapshot.

**Later local work:** `4c11205` adds reviewed hidden-seam art/mapping files, and `23f4a1e` changes the sling-ammo HUD art with a focused test. Neither commit was included in the cohort gate or push. Mirror raw mapping and the hidden-seam user-rectangle follow-up remain in progress. Do not publish later runtime or art changes until a new exact committed snapshot passes the required gates.

## World build and functional acceptance

- All **222/222 graph scene targets** are committed: 88 overworld rooms, 104 cave rooms, and 30 separate pocket scenes. The graph has 33 pockets total, three in-place. There are 221 `.room` sources because `cave_1` is hand-authored. No scene output is missing at the observed HEAD.
- Q2's strict inventory and layout checks passed at `c2a5924`; F3's full-graph run passed 1,136 checks at `92786ea`. The earlier C07 moth-pit and C09 reel/refill graph-validator flags were false positives, not content defects. A separate real B07 streamed pit-return issue was fixed in `5f69076`; its fresh-entry, death-reset, and re-entry checks passed. The binding Q2/Q4 inventory row still says 218 rather than the graph's 222; report the mismatch without changing normative documents.
- C06–C10 functional lead test commits are present: C06 `081518e` (166 headless and 193 render checks), C07 `32e0ab8` (route PASS), C08 `d5e65ad` (150 render checks), C09 `5cd96d9` (40 area, 227 route, 243 render checks), and C10 `1af39cc` (53 area, 243 route, 258 render checks). C09's older OPEN down-throw label has an independent recheck under job `816d3c`, currently marked needs_reconciliation; no result or confirmed reachability defect is available. P06 fix `4e9d1a4` passes 138 checks across all four throw directions.
- E1 ending flow and branch tests are present (`5728847`, `1af39cc`); ending paintings landed in `b66ddd3` and duplicate stands under painted lanterns were removed in `b905d4d`. This is not a completed continuous earned-route playthrough.

## QA and capture status

- Q1's scene-graph solver is committed and passes. Q2 inventory/layout acceptance is complete at the committed 222-target inventory. Q7 reports **582 passing checks** after Snapper fix `b4449ed`; coverage of all 20 encounters' weakness cases is still pending.
- The committed still-capture baseline `d3cf9a5` renders the 222 room and pocket targets from source snapshot `c2a5924` into 16 labelled area sheets at 480×270 thumbnails, with Dummy audio and isolated user data. This is a capture baseline, not Q5 human visual approval or a human playthrough.
- The confirmed intermittent Archivist native SIGSEGV remains open for instrumented localization and a real fix (work prefix `7f2ddf`). It blocks global release; do not waive it as a flaky test. Three regional route-fixture regressions were repaired in `7d8741f`, with the affected suites passing.
- Remaining QA: Q3 full continuous earned-route playthrough; Q5 human visual review; Q6 soak/economy; complete Q7's 20-encounter weakness coverage; Q8 performance/memory; and Q9/release checks.

## Art and presentation

Source image production is closed at final FX `d2fe1a5` and provenance checkpoint `2fa8c69`. Runtime mapper `02fded4` covers 26 keys. Native-alpha cutter support `62a82aa` passes, with 227 previously cut PNGs byte-identical. The ten found-tool menu icons and equipped HUD icons are integrated; equipped-label fit landed in `9664e50`. The verified snapshot includes reviewed C06–C10 assets and presentation through `1eebc1e`; the later `4c11205` hidden-seam selection/mapping work is not gated.

Runtime presentation is not complete. Body and transient-tool fallbacks/placeholders, terrain and pickup/shop visuals, remaining mapping/render cleanup, and human visual review remain. B01 wax plate and kiln pillar are integrated; mouth candidates A–C were rejected for exterior halo/alpha spill. Gloam Knight full-body art and Coinwyrm art remain on HOLD. Mirror raw mapping and the hidden-seam user-rectangle work remain open. No blanket all-art-done claim.

## Current checkpoint boundary and next gate

The shared index contains **77 foreign staged paths** (binary diff fingerprint `cc7b8baf06d7e79c8d9ed63e5c68b4e971422c0795514e2e8381c9c1771cf4a3`); this docs update preserves them and all other foreign work. The user's game audio remains enabled; headless gates use Dummy audio.

The current local tip observed during this docs update is `23f4a1e`, after hidden-seam art/mapping commit `4c11205`; both are beyond the validated SHA, as is later dirty work. Do not publish them or any later tip without a new exact-SHA verification. C09's older OPEN down-throw label has an independent recheck job `816d3c` marked needs_reconciliation, with no confirmed result. For the next runtime/art checkpoint, let its writers land, choose one exact committed SHA, and run `make check`, `make rooms-check`, `make art-test`, `python3 tools/check_ownership.py --global`, and the source/runtime hash audit at that SHA. Human balance and visual feel, full continuous human playthrough (Q3), Q5 review, Q6 soak/economy, complete Q7 weakness coverage, Q8 performance/memory, and release/export acceptance remain open.

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

- The C09 OPEN down-throw report is under independent native recheck. The committed P06 change passes four-direction streamed-room checks; do not report a confirmed route failure unless the recheck reproduces one.
- Q7's 582 checks pass after `b4449ed`, but the requested 20-encounter weakness coverage is incomplete.
- The Archivist has an independently reproduced intermittent native SIGSEGV. Instrument its cause and fix it before calling the global release gate green.
- Runtime art still has body/transient-tool fallbacks, terrain and pickup/shop gaps, remaining mapping/render cleanup, B01 plate/pillar integration and rejected haloed mouth candidates. Human review is open.
- The owner has not approved overall balance, visual feel, or a continuous full-game playthrough. Soak/economy, performance/memory, and release/export checks remain open.

## Next steps

1. Resolve the C09 job's needs_reconciliation state and receive ongoing cave/B01 art-integration reports; correct only confirmed findings in their owned files.
2. After runtime writers land, select one exact committed SHA and run the full global gates plus source/runtime hash audit with graphics on Dummy audio. Keep the resulting gate record tied to that SHA.
3. Complete Q3 full earned-route playthrough, Q5 visual review, Q6 soak/economy, Q7 weakness coverage, Q8 performance/memory, and Q9/Z release work. Resolve the Archivist SIGSEGV before claiming release readiness.
4. Finish runtime art presentation and human visual approval. Source image production is closed, but the game is not fully art-complete.
