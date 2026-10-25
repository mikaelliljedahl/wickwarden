# Wickwarden — state

Status as of 2026-10-25, end of session 2 (see handoff.md status section for bugs and next steps). Read this first: it says what is done, what is running and what comes next.
It is updated when a step or a work package lands. The index of all documents is [README.md](README.md) in this folder.

## Where the project stands

| Part | Status | Documents |
|---|---|---|
| Step 1: dev world | Done. Seven rooms, five monster types, tether moth, pitch pot, cracked wall, locked door, brazier gate, and the route test. Historical plan. | [dev-world-plan.md](dev-world-plan.md); details in "Step 1" below |
| Step 2: art pass | Done. GPT Image art for every dev-world entity and room, cut by `make art`. The owner has not yet approved it in play. | [asset-contract.md](asset-contract.md), [art-provenance.md](art-provenance.md); details in "Step 2" below |
| Planning of the full game | Done: world plan, work packages, monster/boss/tool spec, owner decisions, art inventory, intro script. | [world-plan.md](world-plan.md), [world-work-packages.md](world-work-packages.md), [monsters-bosses-tools.md](monsters-bosses-tools.md), [decisions.md](decisions.md), [art-inventory.md](art-inventory.md), [intro-script.md](intro-script.md) |
| World build (waves 0 and 1 done; wave 2 in progress) | Wave 0 (foundation F0–F14, G1, D1–D3) done. Wave 1 done (P01–P15, T01–T08, M0–M5) with deviations: T03 raft is a fixed lane (free steering not built), player body has the WATER mask (F7b). Wave 2: Brackwater R1 rooms done; R2.a, R2.b, R4.a–R4.c, R5.b done; 32 of 88 overworld rooms built. Not started: R2.c, R2.d, R3, R4.d–f, R5.a/c/d, R6, minibosses, bosses, caves, ending, QA. Open bugs and next steps: [handoff.md](handoff.md) section Status. | [world-work-packages.md](world-work-packages.md) section 5, [code-contract.md](code-contract.md) section 16 |
| Art for the full game | Batches 1 to 3 done: 42 Tamsin sheet images, logged in `tools/source_art/log_b01.md` and `log_b02_b03.md`, not yet in the art manifest. Batches 4 to 86 in production. | [art-inventory.md](art-inventory.md) section 4; progress in `tools/art_prompts/PROGRESS.md` |

At the last update `make check` was green on the committed tree (import, 25 headless test files, gdlint, world data
checks). `make art-test` passes (the Python tests of the cut tool).

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

1. Land F2 (world runtime: data-driven rooms, streaming, shared hooks) and commit it; then F3 to F5 in the order of
   [world-work-packages.md](world-work-packages.md) section 5.
2. Art: the owner culls each batch before the next one starts (art-inventory section 4). Each kept image gets its
   provenance row and its manifest entry.
3. Play step 2 with `make run` and `make dev`; decide the swing width and whether the walk cycle needs a new sheet.
4. Playtest balance on `make dev` and `make run`; tune only through the constants named in the code contract.
5. The title screen, saves and the intro belong to the world build (F12 to F14), not to step 1.
