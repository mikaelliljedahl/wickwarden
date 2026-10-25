Current local snapshot (2026-10-25, committed HEAD `f05c7ea27aec21b7181d3c119dc64ab78ade679c`): **159 scenes = 88 overworld + 25 pockets + 46 cave rooms**, with **158 `.room` sources**. The cave scenes are C01 8, C02 9, C03 9, C04 10 and C05 10; `cave_1` remains hand-authored. Counts use committed files only and exclude active/untracked outputs. The last globally validated and pushed runtime remains `baffec96f976940cd585ce38dbc590a39f088a91` (personal origin/main record `0f66f8f`). All code/art commits after that remain untested as a global snapshot and unpushed.

New committed mechanics and presentation: source mapper `02fded4` maps 26 keys; world factory `270c234`; boss-state adapters `ae7944c` and canonical Serpent `0eeeb9f` avoid duplicate colliders and clear the rider. B06 Dirge Choir `844a04f`; B07 Gloam Knight `f39ab1e`, dive recovery `451cf69` and public fall-damage API `81a9af4`; MB4 Pale Squire/Abacus Brute `6ccb3cf`; MB5 encounters `635e489`; B08 Coinwyrm `f05c7ea`. Tidewick art ordering/rider is in `0eeeb9f`. F6 cave-gate aliases `c27a8ec`, cut-screen regrowth `038395b`, and P08 paired reveal `f2b7e41` are committed. F6 support `f386a2b` remains the base for the current NodePath dependency.

C04 room batches are delivered in `dd1f0cd`, `616a17d`, `02e788c`, `e4c1090` and `16aa8c9`; C05 batches in `b41c01f`, `01ee1a4`, `f0dbc2f`, `9cc2e45` and `d4c07f7`. Encounter/reward art was published in `824c596`. C04 and C05 lead acceptance tests are still active. Eleven generated C04 regrowth outputs are held until the F6 door-relative `NodePath` fix covers two older overworld doors; do not call this path or the overall branch green.

Active queue and next priorities: land the F6 relative-path fix and C04/C05 lead tests, then choose a coherent SHA for the next detached stable gate. C06.a/b/c and C07.a/b/c are assigned in parallel, with no corresponding rooms in the committed tree yet. B09 Lock Warden and B10 The Unlit remain active; B08 and MB5 commits need their ongoing integration/review status checked. Art batch C45 (next 12 keys) is active; boss/world adapters inspect keys while the mapper audits and integrates existing sources. Some render cleanup has landed, but bodies/placeholders and terrain, pickup/shop visuals remain incomplete. Do not claim all art done.

Design notes to preserve during review: B10's implementation keeps the literal 330 orbit around `(960, 288)`, including the upper arc leaving the room. This is an implementation note only; no normative number changed and no owner decision is implied. B07 keeps the literal dive toward the player and hit-table recovery. Boots remain a mobility/progression requirement; strict combat necessity is not proven. Do not convert that into a new owner decision.

The previous C02 functional GO (`6bb45ad`) carries its stated controls and art limits. The passing `baffec96` gate does not cover these later commits. No tests, global gates, or push were run for this status refresh. Graphics checks remain silent with `--audio-driver Dummy`; preserve all 77 foreign staged paths and unrelated art/provenance/import/UID changes. Commit only these two living documents.

## Item-menu art checkpoint

All ten found tools now show dedicated painted icons: Tether Moth, Pitch Pot, Cinder Wick, Tallow Sling, Reed Raft, Heft Mitts, Glow Jar, Lantern Chime, Skitter Boots and Reel Line. `item_menu.gd` asks `SpriteVisual.icon_of` for `icon_<id>` first, then accepted object art, then the existing geometric fallback. Unfound tools retain silhouettes and question marks; navigation, equip and layout are unchanged. No found-item placeholder remains with the committed icon set. Equipped HUD icons were subsequently updated by `d72aec1`.

Pipeline `b2e516c` publishes ten 128x128 runtime kinds and preserves every existing object animation. Selected B17/B18 sources, reasons, hashes and proof checks are recorded in [tool-icon-selection.md](../tools/source_art/tool-icon-selection.md); source generation was already complete. Source generation is closed; runtime integration and acceptance remain separate.

Opened actual World captures: `/tmp/wickwarden-menu-dev-art.png` shows all ten painted tools and the equipped selection; `/tmp/wickwarden-menu-new-art.png` shows all ten unfound silhouettes. Tests cover all ten icons, all ten unfound states, accepted-object fallback and absent-art fallback. `make check` passed (70 Godot test files, lint, current world data, 96 Python tests), `make rooms-check` passed (66/66), and global ownership passed (92 WPs, 53 room batches). Logs: `/tmp/wickwarden-menu-final-{check,rooms,ownership}.log`. Later commits through `bae0a42` contain source art/log/progress only; no checked code changed. Protected source deletions/replacements, shared provenance edits and untracked import/UID files remain outside this checkpoint's owned commits.

## Where the project stands

| Part | Status | Documents |
|---|---|---|
| Step 1: dev world | Done: seven rooms and the tested tool/key/core route. | [dev-world-plan.md](dev-world-plan.md) |
| Step 2: art pass | Done for dev-world entities; owner approval in play remains open. | [asset-contract.md](asset-contract.md), [art-provenance.md](art-provenance.md) |
| Full game planning | Done; binding plans and owner decisions govern implementation. | [world-plan.md](world-plan.md), [world-work-packages.md](world-work-packages.md), [code-contract.md](code-contract.md), [decisions.md](decisions.md) |
| World build | Waves 0 and 1 delivered; free-steering raft API now committed. All **88/88 overworld rooms** are authored. R1–R6 room batches and their current lead tests have landed. Committed cave rooms now cover C01–C05 (46 cave scenes); C04/C05 lead acceptance is active. B03–B08 and MB3–MB5 implementations have landed, with ongoing encounter reviews as assigned. | [handoff.md](handoff.md), [world-work-packages.md](world-work-packages.md) |
| Caves, ending, QA and release | C01–C03 acceptance landed. C04/C05 rooms are committed and lead tests active; C06/C07 batches are assigned, C08–C10 and ending remain. | [world-work-packages.md](world-work-packages.md) |
| Full game art | Source coordinator closed at final FX `d2fe1a5` and provenance `2fa8c69`; mapper `02fded4` integrated 26 keys, while C45 12-key batch and remaining runtime art are active. | [handoff.md](handoff.md), range progress and source logs |

Owner’s current budget choice: use Codex **Luna xhigh** for mechanical tasks. The root orchestrates; this worker owns only state/handoff. Preexisting staged art deletions, untracked replacements and unrelated UID files remain untouched.

The verified commit and isolated gate recorded above apply only to `baffec96`; HEAD `f05c7ea` needs a new stable gate after C04/C05 lead tests and the regrowth `NodePath` fix.

Resolved since takeover: paired raft/water gates and strict area validation, leech shallows, directional ledges, shared hedge identifiers, opener-linked pocket doors, concealed-entrance validation and cave spawn markers; R2.c tool gates/grate fetch, R4.d/e/f and R5.a rooms; title viewport activation; actual watcher projectile ward blocks and entry into the unlocked pocket; stable wickling offset regression. Compiler-output migration landed as eight owned scene commits followed by `90c7c0a` removing the repaired raft waiver. Earlier concurrent-tree graph failure at `ow_3_5` is resolved by the passing integrated graph suite.

The owner wants secret cave entrances under bushes or behind bombable rocks preserved, including tool challenges. Layout review clarified the orchard and hedgerow routes (`1fb01dc`) without changing that intent. Remaining specifications and polish are recorded in handoff; binding documents were not changed.

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

- **The hook swing width is open for tuning.** The user finds the 110° arc with 120 px reach
  (`SWING_ARC_DEG`, `SWING_REACH` in `scripts/player/player.gd`) rather wide. The numbers are unchanged; the
  swing trail draws exactly that sector so the width can be judged with the real art in play.
- **The walk cycle looks a little lame (haltande).** The user judged it good enough for now, in play, for Tamsin
  and for the Hollow. Open art item: check the leg order of the four poses (stride, passing, stride, passing) and the
  frame timing at 8 fps (`walk_*` in `tools/art_manifest.json`). Try a six-pose cycle or another fps before a new
  Codex sheet. The art is unchanged.
- **No human visual approval yet** for step 2 or for batches 1 to 3. Judge the art in play with `make run` / `make dev`.
- **Batches 1 to 3 have known defects** (`pull_down` and `push_down` show Tamsin in side profile; the four-pose walk-like
  sheets repeat leg arrangements). They are listed in `tools/art_prompts/PROGRESS.md`; later prompts carry the fix.
- The tallow blob rests on its flattest pose, so a still blob looks low.
- A faint olive tint remains in the explosion smoke and near Tamsin's braid tip in the charge poses
  (green-key spill that the despill cannot tell apart from painted colour).
- Art production: the AgentTeamForge daemon restarted several times during batches 1 to 3; three Codex agents stopped
  before they wrote their logs. The lead wrote those logs from the session folders (see the provenance).
- **Repository size**: `docs/screens/step2/` holds full-size screenshots (about 25 MB). Decision 18 in
  [decisions.md](decisions.md) says only 16 contact sheets of room captures are committed, not the full-size screenshots.

## Next steps

1. Complete transient tool art integration and visual review; source production is closed.
2. Review committed C01 acceptance and presentation; continue remaining regions, caves, minibosses and bosses within ownership.
3. Resolve the pocket placement and exit-depth conflicts with the owner. Preserve secret entrances and tool challenges.
4. Keep checks green at each delegated checkpoint and push under the standing authorization with protected explicit paths.
5. Play with `make run` and `make dev` to judge swing width, walk timing and balance; tune only agreed constants.
