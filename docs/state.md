# Wickwarden — state

Current integration snapshot (2026-10-25, code/art HEAD `cbb4b20`): MB1 Hollow Captain and Thorn Warden (`e65b7b5`, actual-tool checks `b4e3c1a`), M0 reset (`7b92e01`), B01 Kilnkeeper (`3c1dddc`, death-contact fix `a9bdedb`) and B02 Briar Mother (`36899fa`, decision 46 in `e91212b`) are committed. F4 scoped rewards (`a4dd00d`), F6 cave compiler/validation (`1f9993c`, `daff879`, `3a1574c`), F3 cave checks (`519c16b`), R1 assembled-area/route acceptance (`1d91efb`, `4e635c0`), paired burnables (`1b5457b`) and paired gate/lock synchronization (`e5b78cf`, 37 worker checks) have landed.

C01 is committed: first four rooms `deec8c1`, rooms 5–8 and the crack pocket `4bb839e`, assembled area and physical route acceptance `4facb6e`. Worker reports 84 Godot suites and 124 Python tests passing. Prior active-tree blockers are resolved: room-owned rewards `bc78242`, inherited pocket darkness `09a5893`, scoped BossDoor geometry validation `0d4ff46`. Actual committed totals are **75 room scenes: 55 overworld, 12 separate pockets and 8 C01 rooms**, with **74 .room sources**; historical `cave_1` is handmade. C02–C10 room construction has not started. Outer independent C01 review is read-only; human playthrough approval remains open.

Final integration is waiting only for the HUD all-tool-icons worker `job_01a1741b2c847ecaa537cd9c6f3ef52f` to commit its owned `scripts/ui/hud.gd` / `tests/test_hud_map.gd` change. The stable full gate and personal-origin push remain pending; future cave construction is not a checkpoint dependency.

Presentation sweep (`fb5fd5a`, `cdec164`, `607fae0`, `2021975`, `a92286d`, `c065bc5`, `e5db629`, `8b6ecc9`, `c986419`) maps placed props, travel zones, decoys, soft ward light and target-specific entrances. Root independent QA reports zero fallback bodies among the original 67 placed entities. Wickling body art is committed in `42d8393`. Seven tool/projectile body mappings landed in `1f4e7ea`; runtime presentation `421bf42` and `cbb4b20` paints transient tool bodies, softens held cues, aligns rolling flame art and keeps the raft rider visible. C01 miniboss/boss bodies and fragment presentation still need visual integration/polish; do not infer complete cave art from the tool pass. This is not final visual polish. P2 barrier art still has invisible collider tails where painted alpha ends before the collision rectangle; this remains open. Preserve concealed mouths, decorative ow_2_6 huts and the existing S1/R2 door physics. Missing C3 destination content is future construction, not a door defect.

Source-art coordinator is closed: final FX `d2fe1a5`, provenance checkpoint `2fa8c69`; no image producer is currently running. Runtime art acceptance remains separate. Arena retreat is a pending owner question; no new physical barrier is approved. B01 uses the existing harmless M0 default API without an adapter.

Latest previously verified personal origin/main checkpoint: `2fa8c69`. Current integration gates and the next push are pending; older green results below are historical only. Foreign staged source deletions, untracked replacements, shared provenance changes and import/UID files remain protected.

## Item-menu art checkpoint

All ten found tools now show dedicated painted icons: Tether Moth, Pitch Pot, Cinder Wick, Tallow Sling, Reed Raft, Heft Mitts, Glow Jar, Lantern Chime, Skitter Boots and Reel Line. `item_menu.gd` asks `SpriteVisual.icon_of` for `icon_<id>` first, then accepted object art, then the existing geometric fallback. Unfound tools retain silhouettes and question marks; navigation, equip and layout are unchanged. No found-item placeholder remains with the committed icon set. HUD rendering is unchanged.

Pipeline `b2e516c` publishes ten 128x128 runtime kinds and preserves every existing object animation. Selected B17/B18 sources, reasons, hashes and proof checks are recorded in [tool-icon-selection.md](../tools/source_art/tool-icon-selection.md); source generation was already complete. Source generation is closed; runtime integration and acceptance remain separate.

Opened actual World captures: `/tmp/wickwarden-menu-dev-art.png` shows all ten painted tools and the equipped selection; `/tmp/wickwarden-menu-new-art.png` shows all ten unfound silhouettes. Tests cover all ten icons, all ten unfound states, accepted-object fallback and absent-art fallback. `make check` passed (70 Godot test files, lint, current world data, 96 Python tests), `make rooms-check` passed (66/66), and global ownership passed (92 WPs, 53 room batches). Logs: `/tmp/wickwarden-menu-final-{check,rooms,ownership}.log`. Later commits through `bae0a42` contain source art/log/progress only; no checked code changed. Protected source deletions/replacements, shared provenance edits and untracked import/UID files remain outside this checkpoint's owned commits.

## Where the project stands

| Part | Status | Documents |
|---|---|---|
| Step 1: dev world | Done: seven rooms and the tested tool/key/core route. | [dev-world-plan.md](dev-world-plan.md) |
| Step 2: art pass | Done for dev-world entities; owner approval in play remains open. | [asset-contract.md](asset-contract.md), [art-provenance.md](art-provenance.md) |
| Full game planning | Done; binding plans and owner decisions govern implementation. | [world-plan.md](world-plan.md), [world-work-packages.md](world-work-packages.md), [code-contract.md](code-contract.md), [decisions.md](decisions.md) |
| World build | Waves 0 and 1 delivered, with fixed-lane raft deviation. Wave 2 remains partial: **55/88 overworld rooms, 12 separate pocket scenes and 8 C01 rooms**. R1, R2.a–d, R4.a–f and R5.a–b room batches landed. R1 acceptance, MB1 and B01/B02 landed; R3, R6, R5.c–d and remaining regional/combat work remain. | [handoff.md](handoff.md), [world-work-packages.md](world-work-packages.md) |
| Caves, ending, QA and release | C01 rooms and assembled area/physical route acceptance committed. C02–C10, ending, QA and release remain. | [world-work-packages.md](world-work-packages.md) |
| Full game art | Source coordinator closed at final FX `d2fe1a5` and provenance `2fa8c69`; runtime integration and visual acceptance remain. | [handoff.md](handoff.md), range progress and source logs |

The owner replaced the prior Haiku workflow with ATF Codex **GPT-6.1 Sol low** for coding and authorized parallel agents. The lead orchestrates; this integration worker owns only state/handoff and the delegated verified push. Preexisting staged art deletions, untracked replacements and unrelated UID files remain untouched.

Integrated checks passed: `make check` (70 test files, lint, current world data and 96 Python tests), `make rooms-check` (66/66 sources), and `python3 tools/check_ownership.py --global` (92 WPs, 53 room batches, no overlapping wave 1–5 paths). Logs: `/tmp/wickwarden-final-check.log`, `/tmp/wickwarden-final-rooms.log`, `/tmp/wickwarden-final-ownership.log`. Commit scope review: `/tmp/wickwarden-checkpoint-ownership-review.txt`.

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
