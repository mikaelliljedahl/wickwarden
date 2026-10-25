Status refresh (2026-10-25, committed code HEAD observed as `b905d4d4006f1c4bfeac86499b09f2cbbc30e784`): **222/222 scene targets are committed**. The graph has 192 rooms (88 overworld and 104 cave rooms) and 33 pockets; three pockets are in-place, leaving 30 rendered pocket scenes. There are 221 `.room` sources; `cave_1` remains hand-authored. No target scene is missing at this HEAD. The last globally validated and pushed runtime remains `baffec96f976940cd585ce38dbc590a39f088a91` (personal `origin/main` record `0f66f8f9b902a01a8e58fd6a77facd3ebab899c1`). Later code/art commits remain unverified as one global snapshot and unpushed. This docs refresh did not run tests, global gates or a push.

C04 and C05 functional acceptance have GO reports; C05 followed the regenerated outputs `e6c8b12` and pocket-door blocker rebind `1829791`. C06's eleven rooms and pocket scenes are committed, but full regional push/bidirectional acceptance remains open. C08's twelve rooms are built. C09 and C10 room outputs now fill the graph inventory, with regional acceptance still finishing. E1 ending flow is implemented in `5728847`; paintings/choice sprites landed in `b66ddd3`, and `b905d4d` removes duplicate stands beneath the painted ending lanterns. Recent encounter cleanup includes Briar/Archivist copy fairness `710c798`, Archivist helper cleanup `d85b759`, Lock Warden clone rebuild `e19ba3c`, and Unlit helper cleanup `e6957bf`.

QA is active and not globally accepted. Q1 scene-graph solver is committed in `c7bb5bf` and its report passes on the complete 222-scene snapshot. Q2 completeness/layout review is in progress. The latest combined-gate report before `b4449ed` had 11 failing suites out of 129, including four cave_9 content defects under Q2; that report said `world-check`, `rooms-check` and global lint passed. The four cave_9 defects still need scoped triage. C09's two earlier route reports were separately reproduced as F3 reachability false positives; eight real-Player checks passed. Q4 capture tooling landed in `4a43792`; three real captures and byte-identical repeats passed, but capture/review of all 222 targets remains outstanding. The binding Q2/Q4 table still says 218 scenes/images, while the graph requires 222; flag this discrepancy without editing the binding plan. Q7 `4606df5` reported 580/582 before `b4449ed` fixed Bramble Snapper immunity to Heft Mitts throws. Rerun Q7 before claiming the matrix green. C07–C10 functional lead tests are active; B07 streamed-pit return and F3 moth-over-pit checks, pocket-terrain mapping, overworld composition review and encounter-lifecycle review are also active. Q3 full playthrough, Q5 visual review, Q6 soak/economy, Q8 performance/memory and Q9 final QA documentation remain open. Z1 fixes, human tuning/playthrough and Z3 release checks are not complete.

Art source production is closed at final FX `d2fe1a5` and provenance checkpoint `2fa8c69`; mapper `02fded4` integrates 26 keys. Art/runtime acceptance remains incomplete: body and transient-tool placeholders, terrain and pickup/shop presentation, remaining mapping/render cleanup, and human visual review still need work. Do not claim all placeholders or art are gone.

The full-room output count is complete at this HEAD. No `.room` source or compiled room scene was dirty at this inspection, and a worker-reported combined run said `rooms-check` passed before the latest Q1/Q4/Q7 and ending-presentation commits. No stale room outputs are currently identified; rerun the full exact-SHA gate after the current fixes. The shared index showed 77 staged paths during the final inspection. Preserve all foreign staged and unstaged art, provenance, import, UID and implementation changes. Graphics checks use `--audio-driver Dummy`. Commit only `docs/state.md` and `docs/handoff.md`.

Design notes to preserve during review: B10's implementation keeps the literal 330 orbit around `(960, 288)`, including the upper arc leaving the room. This is an implementation note only; no normative number changed and no owner decision is implied. B07 keeps the literal dive toward the player and hit-table recovery. Boots remain a mobility/progression requirement; strict combat necessity is not proven. Do not convert that into a new owner decision.

The previous C02 functional GO (`6bb45ad`) carries its stated controls and art limits. The passing `baffec96` gate does not cover later commits. This observed HEAD is an inventory snapshot, not a global validation claim. Graphics checks remain silent with `--audio-driver Dummy`; commit only these two living documents.

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
| World build | All 88 overworld rooms and all 222 graph scene targets are present in the observed commit. C04/C05 have functional GO reports; C06 full regional push acceptance and C07–C10 regional acceptance remain in progress. Encounter implementations have landed, with QA findings still open. | [handoff.md](handoff.md), [world-work-packages.md](world-work-packages.md) |
| Caves, ending, QA and release | C01–C05 have accepted functional reports; C06 rooms are committed but regional push acceptance is pending. C07–C10 scenes are present; regional lead acceptance, Q1–Q8 integration work and release remain open. E1 flow is implemented but full playthrough/release acceptance is not complete. | [world-work-packages.md](world-work-packages.md) |
| Full game art | Source production is closed at final FX `d2fe1a5` and provenance `2fa8c69`; mapper `02fded4` maps 26 keys. Runtime art still has placeholder bodies/transient tools and terrain, pickup/shop and visual-review work. | [handoff.md](handoff.md), range progress and source logs |

Owner’s current budget choice: use Codex **Luna xhigh** for mechanical tasks. The root orchestrates; this worker owns only state/handoff. Preexisting staged art deletions, untracked replacements and unrelated UID files remain untouched.

The verified commit and isolated gate recorded above apply only to `baffec96`; the current scene inventory at `b905d4d` is not globally gated. The next stable checkpoint needs `make check`, `make rooms-check`, `make art-test`, global ownership and source/runtime consistency checks on one exact committed SHA, plus Q2 cave_9 triage and a Q7 rerun after the snapper fix.

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

1. Finish Q2 completeness/layout review and Q3 full-route playthrough, then complete Q4–Q8 capture, visual review, soak/economy, matrix and performance work.
2. Rerun Q7 after `b4449ed` changed Bramble Snapper immunity to match matrix row 5.9; do not claim the matrix green until that rerun passes.
3. Complete remaining regional acceptance, especially C06 push/bidirectional checks and C07–C10 route/composition review.
4. Finish runtime art mapping, placeholder replacement, terrain and pickup/shop visuals, and human visual approval; source production is closed.
5. Run the exact-SHA global gates before any checkpoint push. Human playthrough, feel/balance tuning, performance soak and release/export checks remain open; preserve secret entrances and established tool requirements.
