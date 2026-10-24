# Wickwarden — code contract (normative)

Several agents build in parallel from this document alone. **Never write to a file you do not
own** (section 2). If you need something from the core, build against the API below; if the API is
missing something, report it, do not patch the core. Numbers come from
[dev-world-plan.md](dev-world-plan.md); this file defines the interfaces.

Godot 4.7 (`config_version=5`), GDScript, static typing where reasonable. Run commands from the repo
root. `make test` runs every test, `make check` = import + test + gdlint.

## 1. Rules for every work package (WP1-WP7)

1. Behaviour goes in `_physics_process` (or the hooks the base classes call from it). Never in `_process`.
2. **Do not declare `class_name` in WP files** (enemies, projectiles, items, cracked wall, tests). Core
   classes already have one. A new `class_name` needs a re-import, and parallel agents re-importing the
   same checkout corrupt each other. Reference your own scenes by path.
3. **Use `load("res://...")` for anything another WP delivers** (for example `scenes/enemies/spore.tscn`,
   `scenes/enemies/tallow_drop.tscn`, `scenes/items/*.tscn`) and null-check the result. Never `preload()`
   it: a missing file would become a parse error that breaks the whole game.
4. Every entity has exactly one child named `Visual` (the base classes create it with
   `Placeholder`; see section 10). Game logic never **reads** from `Visual`.
5. Damage is in **half-hearts** (`int`). 2 = one heart.
6. No tutorial text in the game world. No AI attribution lines in code or commits.
7. A WP is done when: `make test T="<your test>"` passes, `make lint` is clean, and your `.tscn` loads
   (your test instantiates it). Run the whole `make test` once before reporting.
8. Do not edit `docs/`, `project.godot`, `tools/`, `Makefile` or anything under `scripts/core`,
   `scripts/combat`, `scripts/player`, `scripts/world` (except your own file), `scripts/ui`,
   `scripts/pickups`, `scripts/autoload`, `tests/base_test.gd`, `tests/runner.*`.
9. `.gd.uid` files appear after `make import`. If you generate one for your file, commit it with the file.

## 2. File ownership

Directory layout (what exists after WP0):

```
project.godot  Makefile  gdlintrc  AGENTS.md  CLAUDE.md  README.md
docs/                      dev-world-plan.md  story.md  code-contract.md
scripts/autoload/          game_state.gd (GameState)  events.gd (Events)
scripts/core/              layers.gd (Layers)  world_constants.gd (WorldConst)
scripts/art/               placeholder.gd (Placeholder)  light_texture.gd (LightTexture)
scripts/combat/            hitbox.gd (Hitbox)  hurtbox.gd (Hurtbox)
scripts/player/            player.gd (Player)
scripts/items/             item_base.gd (ItemBase)  item_registry.gd (ItemRegistry)   [+ WP6 files]
scripts/enemies/           enemy_base.gd (EnemyBase)  enemy_projectile.gd (EnemyProjectile)
                           dummy_walker.gd (worked example)                             [+ WP1-5 files]
scripts/pickups/           pickup_base.gd (PickupBase)  pickup_collector.gd (PickupCollector)  drop_table.gd (DropTable)
scripts/world/             world.gd (World)  room.gd (Room)  room_door.gd  solid_block.gd  brazier.gd
                           gate.gd  locked_door.gd  bush.gd                              [+ WP6 cracked_wall.gd]
scripts/ui/                hud.gd (Hud)  pause_menu.gd (PauseMenu)  debug_overlay.gd (DebugOverlay, dev mode)
scenes/player/player.tscn
scenes/enemies/            dummy_walker.tscn                                             [+ WP1-5 scenes]
scenes/items/              (empty)                                                       [+ WP6 scenes]
scenes/pickups/            ember brass_bit brass_coin pitch_pot_bundle key wick_core item_pickup .tscn
scenes/world/              world.tscn   rooms/ow_0_0 .. ow_2_1, cave_1 .tscn            [+ WP6 cracked_wall.tscn]
scenes/ui/                 hud.tscn  pause_menu.tscn
tests/                     base_test.gd (TestCase)  runner.gd/.tscn  test_*.gd  fixtures/
tools/                     run_godot_check.py  godot_env.py  capture.gd/.tscn (screenshot helper)
```

| WP | Owner | Files (exactly these; nothing else) |
|---|---|---|
| WP0 | Sonnet | everything not listed below |
| WP1 Spitcap + spore | Haiku | `scripts/enemies/spitcap.gd`, `scenes/enemies/spitcap.tscn`, `scripts/enemies/spore.gd`, `scenes/enemies/spore.tscn`, `tests/test_spitcap.gd` |
| WP2 Skitterwick | Haiku | `scripts/enemies/skitterwick.gd`, `scenes/enemies/skitterwick.tscn`, `tests/test_skitterwick.gd` |
| WP3 Duskmoth | Haiku | `scripts/enemies/duskmoth.gd`, `scenes/enemies/duskmoth.tscn`, `tests/test_duskmoth.gd` |
| WP4 Tallow blob + drop | Haiku | `scripts/enemies/tallow_blob.gd`, `scenes/enemies/tallow_blob.tscn`, `scripts/enemies/tallow_drop.gd`, `scenes/enemies/tallow_drop.tscn`, `tests/test_tallow_blob.gd` |
| WP5 Hollow | Haiku | `scripts/enemies/hollow.gd`, `scenes/enemies/hollow.tscn`, `tests/test_hollow.gd` |
| WP6 Items + cracked wall | Haiku | `scripts/items/tether_moth.gd`, `scenes/items/tether_moth.tscn`, `scripts/items/pitch_pot.gd`, `scenes/items/pitch_pot.tscn`, `scripts/world/cracked_wall.gd`, `scenes/world/cracked_wall.tscn`, `tests/test_tether_moth.gd`, `tests/test_pitch_pot.gd`, `tests/test_cracked_wall.gd` |
| WP7 Integration | Sonnet | `scenes/world/rooms/*.tscn` (content), pickup/prop placement, `tests/test_dev_world.gd`, `tests/test_dev_world_route.gd`, `docs/` updates, uid files, final commit. After WP7 the core files (world, hitbox/hurtbox groups, placeholder, hud, enemy_base `adopt_deferred`, capture tool, dev mode) were extended by WP7 as listed in section 15 |

The scene paths above are fixed: `ItemRegistry` and the other WPs load them by path.

## 3. Collision layers (bitmask values)

Godot stores `collision_layer` / `collision_mask` as **bitmasks**. Layer number N has value `1 << (N-1)`.
Never assign a layer *number*. Use `Layers.*` (scripts/core/layers.gd), the single source of truth.

| Layer | Value | `Layers.` constant | On this layer | Mask detects |
|---|---|---|---|---|
| 1 | 1 | `WORLD` | walls, rocks, closed doors/gates, braziers, bushes, cracked walls | - |
| 2 | 2 | `PLAYER_BODY` | Player | `WORLD` |
| 3 | 4 | `ENEMY_BODY` | enemy CharacterBody2D | `WORLD` |
| 4 | 8 | `PLAYER_HURTBOX` | player Hurtbox | - |
| 5 | 16 | `ENEMY_HURTBOX` | enemy Hurtbox | - |
| 6 | 32 | `PLAYER_HITBOX` | hook swing, flare, moth stun | `ENEMY_HURTBOX` + `PROP_HURTBOX` |
| 7 | 64 | `ENEMY_HITBOX` | contact damage, projectiles | `PLAYER_HURTBOX` |
| 8 | 128 | `PICKUP` | pickups | `PICKUP_COLLECTOR` |
| 9 | 256 | `PICKUP_COLLECTOR` | player collector, moth carrier | - |
| 10 | 512 | `PROP_HURTBOX` | bush, brazier (things the hook or a blast hits) | - |

- Enemies do **not** collide with the player or each other (their bodies only use `WORLD`). Damage
  happens through hitboxes/hurtboxes only.
- Teams: `Layers.Team.PLAYER`, `ENEMY`, `NEUTRAL`. `Hitbox.setup(team)` sets layer and mask for you
  (a `NEUTRAL` hitbox hits player, enemy and prop hurtboxes: explosions).
- **Trap: an `Area2D` with `monitorable = false` does not detect bodies in Godot 4.7.** Leave
  `monitorable` at its default `true` on every Area2D that polls `get_overlapping_bodies()`.
- Areas poll overlaps in `_physics_process`; overlaps show up one physics frame after a node enters
  the tree or an area is activated. Tests must wait frames.

## 4. Getting the player

```gdscript
var player := get_tree().get_first_node_in_group(&"player") as Player   # null if there is none
```

In an enemy use the cached helpers (they never return a stale node):

```gdscript
var p: Node2D = get_player()                 # null in a world without a player
var pos: Vector2 = player_position(global_position)   # fallback when there is none
var dir: Vector2 = direction_to_player()     # normalised, ZERO when there is no player
```

Player public API (everything else is internal):

```gdscript
player.global_position: Vector2          # origin = body centre, collision circle r 26
player.facing: Vector2                   # UP / DOWN / LEFT / RIGHT
player.is_dead() -> bool
player.is_invulnerable() -> bool         # i-frames running
player.ward_up: bool
player.take_damage(amount: int, from_pos: Vector2, knock_speed := 640.0, knock_time := 0.14) -> bool
player.use_item() -> bool                # uses GameState.active_item (see section 9)
player.cycle_item() -> void
player.collector: PickupCollector        # the player's pickup area
signal died, hurt_taken(amount), swing_started(facing), flare_fired, item_used(item_id)
```

The player is in group `player`; the World is in group `world`; enemies in `enemies`; pickups in
`pickups`; projectiles in `projectiles`; items in `items` and `item_<id>`; braziers in `braziers`,
bushes in `bushes`.

## 5. Autoloads

`GameState` (run state; health in half-hearts):

```gdscript
health, max_health (6..40), currency, keys (count of the current scope, section 16.5), pitch_pots (0..pot_max()): int
items: Dictionary[StringName, true]; active_item: StringName
visited_rooms: Dictionary; current_room: StringName; flags: Dictionary
damage(amount) -> bool (true = dead)   heal(n)   full_heal()   add_max_heart(hearts := 1)  # + full heal
add_currency(n)  add_key(n := 1, scope := &"ow")  use_key(scope := &"ow") -> bool  keys_in(scope) -> int
add_pitch_pots(n)  spend_pitch_pot() -> bool
has_item(id)  acquire_item(id)  set_active_item(id)  cycle_item()
set_flag(flag, value := true)  has_flag(flag)  mark_visited(room_id)  reset()
signals: health_changed, currency_changed, keys_changed, pitch_pots_changed, item_acquired,
         active_item_changed, room_visited, flag_changed
```

World build amendments to `GameState` (section 16.5 gives the rules): `big_keys` and `fragments` are
flag-backed (`has_big_key(cave)`, `add_fragment(cave)`); `pot_max()` is 10 plus 4 per pot bag flag, and
`PITCH_POT_MAX` stays as the base; `slugs`, `slug_max()` (30), `add_slugs(n)`, `spend_slug() -> bool`;
`WALLET_CAP` (999) with `spend_currency(n) -> bool`; signals `slugs_changed`, `pot_max_changed`.

`Events` (signal bus, no state): `room_entered(room_id)`, `room_left`, `enemy_died(enemy, at)`,
`player_hurt(amount)`, `player_died`, `player_respawned`, `pickup_collected(kind)`,
`brazier_lit(id)`, `explosion(at, radius)`.

Persistent-flag naming (written by the core, read by tests and WP7): `picked_<persistent_id>` (placed
pickups), `door_<door_id>` (locked doors), `gate_<gate_id>`, `brazier_<brazier_id>`,
and for the cracked wall (WP6) `cracked_<wall_id>`. The world build adds the flags of section 16.4.

## 6. Combat components

`Hitbox` (Area2D, `scripts/combat/hitbox.gd`). Add a collision shape (`add_circle(r)` or your own
`CollisionShape2D` / `CollisionPolygon2D`), set fields, then `activate()`.

| Field | Meaning |
|---|---|
| `damage: int` | half-hearts. 0 is allowed (stun-only) |
| `damage_vs_player: int` | used instead of `damage` against the player team; -1 = off (pitch pot: damage 4, vs player 2) |
| `knockback: float`, `knockback_time: float` | victim velocity px/s and seconds, away from `source`. Defaults 480 / 0.12. Set `knockback = 0` for none |
| `stun_time: float` | seconds of stun for enemies (tether moth: 2.0) |
| `kind: StringName` | `&"hook"`, `&"flare"`, `&"explosion"`, `&"stun"`, `&"contact"`, `&"projectile"`. Props filter on it |
| `team: Layers.Team` | who owns it |
| `source: Node2D` | knockback origin (null = the hitbox itself) |
| `once_per_target: bool` | true: each hurtbox once per activation (swings, blasts). false: retried every frame, paced by the victim's i-frames (contact) |
| `blockable: bool` | a raised ward destroys the carrier (projectiles) |
| `knockback_direction: Vector2` | fixed direction; ZERO = away from `source` |
| `active: bool`, `activate()`, `deactivate()` | only active hitboxes hit anything |
| `signal hit_landed(hurtbox)`, `signal blocked` | |

`Hurtbox` (Area2D): `team`, `enabled`, `invulnerable`, `filter: Callable(hitbox) -> bool`,
`signal hurt(hitbox)` (emitted for every accepted hit), `receive_hit(hitbox) -> bool`. The owner
computes damage with `hitbox.damage_for(hurtbox)` and applies its own i-frames. Players take 0.9 s
i-frames, enemies 0.25 s (done by `Player` / `EnemyBase`).

Timings/knockbacks you can rely on: enemy hit = white flash 0.1 s, knockback 480 px/s for 0.12 s,
i-frames 0.25 s. Player hit = knockback 640 px/s for 0.14 s, i-frames 0.9 s with blink.

## 7. EnemyBase (`scripts/enemies/enemy_base.gd`)

Every enemy `extends EnemyBase` (no `class_name`). The base creates the body shape, `Hurtbox`,
contact `Hitbox` and the `Visual` at `_ready()`, so an **enemy scene is only a `CharacterBody2D`
root with the script attached** (see the template in section 12).

Stats (set them in `_init()` of the subclass; the scene does not override them):

```gdscript
max_hp: int            contact_damage: int (half-hearts; 0 = harmless body)
move_speed: float      visual_kind: StringName (Placeholder kind, section 10)
body_radius: float     drops_enabled: bool        drop_roll_override: float (tests; <0 = random)
```

State and fields you may read: `hp`, `is_dead`, `facing_dir`, `hit_wall` (last move touched a wall),
`room_rect: Rect2` (global; the enemy never leaves it), `hurtbox`, `contact_hitbox`, `visual`.
State you may set: `velocity`, `invulnerable` (true = ignores all hits: airborne skitterwick),
`facing_dir` via `set_facing_dir(dir)`.

Virtual hooks (all optional, all called from the base `_physics_process`):

```gdscript
func _enemy_ready() -> void            # end of _ready(); start your first timer
func _enemy_physics(delta: float) -> void   # per frame while the enemy may act. SET `velocity` ONLY.
func _on_hurt(hitbox: Hitbox) -> void  # after a damaging hit; hp already reduced (hitbox is null for apply_damage)
func _on_death() -> void               # once, hp reached 0; spawn children here; may set drops_enabled = false
func _on_stunned(seconds: float) -> void
func _on_stun_end() -> void
```

The base calls `move_and_slide()` after `_enemy_physics` (do **not** call it yourself) and then clamps
the position into `room_rect`. `_enemy_physics` is NOT called while the enemy is in knockback, stunned
or dead. Contact damage stays active while stunned.

Public methods:

```gdscript
stun(seconds)                     is_stunned() -> bool         is_knocked_back() -> bool
apply_knockback(vel: Vector2, time: float)
apply_damage(amount, from_pos, knock_speed := 480.0, knock_time := 0.12) -> bool   # scripted/test damage
can_be_hurt() -> bool             kill()
set_contact_enabled(enabled: bool)         # airborne hop: set_contact_enabled(false) + invulnerable = true
get_player() / player_position(fallback) / direction_to_player()
set_facing_dir(dir)
fire_projectile(scene: PackedScene, dir, speed := -1.0, damage := -1, from := Vector2.INF) -> EnemyProjectile
adopt(child: EnemyBase, at: Vector2) -> EnemyBase     # add a child enemy next to this one, in the tree at once
adopt_deferred(child, at) -> EnemyBase                # same, but call_deferred: safe in physics callbacks and _on_death()
signals: damaged(amount), died(enemy), stunned(seconds)
```

Use `adopt_deferred()` whenever the call can run inside a physics callback (area/body signals, hit handlers,
`_on_death()`): `adopt()` adds the child to the tree immediately and Godot rejects that while physics queries
flush. `adopt_deferred()` sets the child's position in the parent's space first and adds it at the end of the
frame (the child is not in the tree yet when it returns). The tallow blob splits with it.

On death the base: calls `_on_death()`, adds a puff, rolls the drop table (section 8), emits `died` and
`Events.enemy_died`, then `queue_free()`. Hit flash, knockback, i-frames, stun and confinement are all in
the base; do not reimplement them. `process_mode` is managed by the World (rooms are frozen during a
slide); never touch it.

Enemy numbers (plan section 6; **all damage values are half-hearts**, speeds px/s, so `contact_damage = 1`
is half a heart and the hollow's `2` is one heart):

| Enemy | hp | contact | speed | `visual_kind` |
|---|---|---|---|---|
| spitcap | 2 | 1 | 120 | `spitcap` (spore: damage 1, 360 px/s, `spore`) |
| skitterwick | 2 | 1 | hop 140-260 px in 0.5 s | `skitterwick` |
| duskmoth | 1 | 1 | 260 | `duskmoth` |
| tallow_blob | 2 | 1 | 160 | `tallow_blob` |
| tallow_drop | 1 | 1 | 220 | `tallow_drop` |
| hollow | 4 | 2 | 140 (dash 300 for 0.5 s) | `hollow` |

Behaviour text is in the plan; this contract only fixes the interfaces.

**Optional per-enemy test hooks.** Some enemies expose a read-only state query so tests can assert on a
state without reading private fields. They are not part of the base API and nothing in the game depends on
them: `Skitterwick.is_airborne()` (in the hop), `Duskmoth.is_flying()` (in its flight state),
`Hollow.is_charging()` (in the 0.5 s dash). A new enemy may add its own in the same style.

**Decisions where the plan and this contract were silent** (made by the WPs, kept as the rule):

- **Stun mid-hop lands the skitterwick.** A stun that arrives while it is airborne ends the hop at once: it
  lands where it is, is hittable again and has contact damage again. Its next wait timer is drawn at the landing
  and only runs once the stun is over.
- **Stun mid-flight pauses the duskmoth.** The base does not call `_enemy_physics` while stunned, so the
  flight/rest timers stand still; it carries on with the rest of its flight afterwards.
- **The hollow's cooldown is stationary.** After a dash (0.5 s at 300 px/s) it stands still for 0.6 s and cannot
  dash again; then it snaps back onto the 96 px grid. A hit or a stun during the dash ends it early (same
  recovery).
- **The tether moth stuns on both legs and turns back at any WORLD body.** Its stun hitbox is re-armed when it
  turns, so an enemy can be stunned on the way out and again on the way back. A ray along its path that hits
  anything on the `WORLD` layer (rock, bush, brazier, closed door or gate, cracked wall, wall ring) makes it
  turn back early.
- **An opened cracked wall stays in the tree with its collision off.** `_open()` disables the shape
  (deferred), hides the `Visual`, leaves the `explodable` group and sets `cracked_<wall_id>`; the node is
  not freed, so a later visit finds it open (flag) without respawning anything.
- **Finding the pitch pot item grants 6 pitch pots** (WP7). The plan says the pitch pot ammo "starts 0": that
  is the count before the item exists, and `GameState.acquire_item` still grants none (unit tests rely on it).
  The placed item pickup (`PickupBase.ITEM_FOUND_AMMO`, kind `item`) adds 6 the first time it is collected, so
  the first cracked wall can be opened without farming drops. Change the one constant to tune it.

## 8. EnemyProjectile, pickups, drops

`EnemyProjectile` (Area2D, `scripts/enemies/enemy_projectile.gd`): moves straight, damages the player,
destroyed by walls (`WORLD`), by the ward (when `blockable_by_ward`), by leaving `room_rect`, on a
successful hit, and after `lifetime`.

```gdscript
@export damage := 1, speed := 360.0, radius := 12.0, blockable_by_ward := true, lifetime := 5.0,
        visual_kind := &"spore", knockback := 640.0, knockback_time := 0.14, destroy_on_hit := true
var direction: Vector2; var room_rect: Rect2; var hitbox: Hitbox
EnemyProjectile.fire(parent, at, dir, speed := 360.0, damage := 1) -> EnemyProjectile   # plain one
launch(at: Vector2, dir: Vector2)          # place + aim a scene instance after add_child
destroy(reason := &"hit")                  # reasons: &"wall" &"ward" &"hit" &"range" &"bounds"
func _projectile_physics(delta)            # hook: extra motion before the straight move
func _on_destroyed(reason)                 # hook
signal destroyed(reason)
```

A projectile scene is an `Area2D` root with your script (`extends EnemyProjectile`). Spawn it with
`fire_projectile(load("res://scenes/enemies/spore.tscn"), dir, 360.0, 1)` (null-check `load` is
done for you: a null scene gives a plain projectile).

Pickups (`scripts/pickups/pickup_base.gd`), kinds `ember` (+2 half-hearts), `brass_bit` (+1),
`brass_coin` (+5), `pitch_pot_bundle` (+4 pots), `key` (+1), `wick_core` (+1 max heart, full heal),
`item` (grants `item_id`):

```gdscript
PickupBase.spawn(kind, parent, global_pos, timed := true) -> PickupBase   # timed: 8 s, blinks the last 2 s
pickup.collect(collector: Node = null) -> bool     # THE collect method: applies, frees, false if done already
pickup.begin_carry(by: Node2D) -> bool             # follow `by`, no timeout; applied only by collect()
pickup.end_carry()   pickup.is_carried()   pickup.time_left()
fields: kind, amount (0 = default), timeout (0 = never), persistent_id, item_id, is_collected
signal collected(kind)
```

`PickupCollector` (Area2D, layer `PICKUP_COLLECTOR`): the player's collects instantly. **Carrier** (tether
moth): add one to your item node:

```gdscript
var c := PickupCollector.new()
c.carrier = true            # touched pickups are carried (begin_carry), not applied
c.add_circle(30.0)          # collision radius
add_child(c)                # owner_node defaults to the parent; it is who the pickup follows
c.picked.connect(func(p: PickupBase) -> void: ...)
```

A carried pickup sits on the carrier. When the carrier overlaps the player's collector the player collects
it automatically; you may also call `pickup.collect(player)` yourself.

`DropTable.pick(roll, pitch_pot_found) -> StringName` (one roll: ember 25 %, brass bit 35 %, coin 5 %,
bundle 10 % only after the pitch pot item is found, else nothing). Enemies roll it in the base.

## 9. Sub-items (WP6)

The Player is generic: `use_item()` does `ItemRegistry.create(GameState.active_item)` and, if that
returns an `ItemBase`, sets `item.player`, `item.facing`, adds it to the **player's parent** at the player's
position and calls `activate()`. `false` from `activate()` refuses the use (the node is freed). A
missing scene file = silent no-op.

```gdscript
# scripts/items/item_base.gd   (class_name ItemBase, extends Node2D)
var item_id: StringName        # set in _init() of your script
var player: Node2D             # the Player (a Player; typed loosely)
var facing: Vector2            # UP / DOWN / LEFT / RIGHT at the moment of use
func activate() -> bool        # override. Spend ammo and enforce limits HERE
func active_count() -> int     # live instances of this item (including this one)
func finish() -> void          # emit finished and queue_free
static func group_name(id) -> StringName   # &"item_<id>"
```

- Item scene root extends `ItemBase`. The root may be `Node2D` (type in the .tscn) or an `Area2D` etc.
  if your script says `extends ItemBase` it must be a `Node2D`-derived root.
- The World frees all nodes in group `items` on every room change, so never rely on an item surviving a
  transition.
- `ItemRegistry` (static): `items` dict (`id -> {scene, name}`), `get_scene(id)`, `create(id)`,
  `register(id, path, name)`. The ids and scene paths for WP6 are fixed:
  `tether_moth` -> `res://scenes/items/tether_moth.tscn`, `pitch_pot` -> `res://scenes/items/pitch_pot.tscn`.
- Acquiring an item is `GameState.acquire_item(id)` (the placed `PickupBase` of kind `item` does it).
  The first item found becomes active; `Player.cycle_item()` cycles through acquired items.

**Tether moth** (plan section 4): `activate()` returns false if `active_count() > 1`. Flies 420 px along
`facing` at 900 px/s, then returns to the player (then `finish()`). Carries a stun `Hitbox`
(`team = PLAYER`, `damage = 0`, `knockback = 0`, `stun_time = 2.0`, `kind = &"stun"`, `once_per_target`
true, `source = self`, `activate()`) and a carrier `PickupCollector` (above).

**Pitch pot** (plan section 4): `activate()` returns false if `active_count() > 2` or
`GameState.spend_pitch_pot()` is false (spend only after the limit check). Placed one tile
(96 px) in front of the player, explodes after 1.6 s: a `NEUTRAL` `Hitbox` (`kind = &"explosion"`,
`damage = 4`, `damage_vs_player = 2`, radius 150, `source = self`, activate for ~0.1 s) plus the
explodable call below, `Events.explosion.emit(global_position, 150.0)`, then `finish()`.

**Explodable contract (WP6 pot -> WP6 cracked wall, and anything else that breaks):** a node that
reacts to explosions is in group `explodable` and has the method

```gdscript
func on_explosion(pos: Vector2, radius: float) -> void   # pos = explosion centre (global)
```

The pot calls it for every node in `get_tree().get_nodes_in_group(&"explodable")`; the node decides
for itself whether it is in range (for a wall: distance from `pos` to its nearest edge <= `radius`).
`CrackedWall` (`scripts/world/cracked_wall.gd`, root `StaticBody2D`, layer `WORLD`, exports `wall_id`
and `size`, flag `cracked_<wall_id>`, starts open when the flag exists) is WP6's. Bushes also die to
`kind == &"explosion"` hitboxes (they use the hitbox route, not `explodable`).

## 10. Placeholder art

`Placeholder` (`scripts/art/placeholder.gd`) draws a coloured shape per entity kind. The base classes
call it for you. For your own nodes:

```gdscript
Placeholder.attach(parent, &"spitcap")            # creates/replaces the child named "Visual"; returns it
Placeholder.attach(parent, &"hollow", 0.0, Vector2(56, 64))   # radius / size overrides
visual.set_facing(Vector2.LEFT)                   # redraws the facing nub (optional method)
visual.modulate / visual.visible                  # presentation only; never read in logic
Placeholder.color_of(&"spore")  Placeholder.puff(parent, at, color, radius)
```

Kinds already in `Placeholder.KINDS`: dummy_walker, spitcap, spore, skitterwick, duskmoth, tallow_blob,
tallow_drop, hollow, tether_moth, pitch_pot, explosion, the pickups, brazier, gate, locked_door, bush,
rock, wall, water, cracked_wall, pedestal, door_marker, ward, hook_arc, flare. Use them via
`visual_kind` (enemies) / `visual_kind` (projectiles) / `Placeholder.attach` (items, walls). To change a kind's
look, edit its one line in `KINDS` (shape, colour, radius/size); that is allowed for the kind of your own
entity only and is the one permitted edit in a core file. Step 2 replaces `Visual` with an
`AnimatedSprite2D`: keep to `modulate`, `visible`, `set_facing`.

## 11. Room system (WP7 and tests)

- A **Room** (`scripts/world/room.gd`, scene root `Node2D` + script) is 1920x960 px at
  `grid * (1920, 960)` in world space. Exports: `room_id`, `grid`, `exits` (`&"n" &"e" &"s" &"w"`),
  `dark`, `floor_color`, `build_walls`. Containers (children of the room, `y_sort_enabled`):
  `Enemies` (placed enemy instances; respawn on every entry), `Bushes` (respawn on entry), `Props`
  (permanent: SolidBlock, Brazier, Gate, LockedDoor, RoomDoor, placed pickups, CrackedWall), `Spawns`
  (`Marker2D` entry points, e.g. `Default`).
- **Walls** are plain `StaticBody2D` rectangles (layer `WORLD`), a 96 px ring with a 192 px gap centred on
  each exit side. Chosen over `TileMapLayer` on purpose: Hollowtide's trap was that tile collision
  polygons are measured from the tile **centre**. If tiles come in step 2, test the real tile collision.
- Room positions: `ow_x_y` at `(x*1920, y*960)`. `cave_1` is at grid (0, 3), i.e. world `(0, 2880)`, until
  F2 moves it to grid (1, 13), world `(1920, 12480)` (section 16.7). Cave rooms use grid rows 12 and later.
  Local coordinates inside a room scene are 0..1920 x 0..960. Interior (walkable) is 96..1824 x 96..864.
- **World** (`scripts/world/world.gd`, `scenes/world/world.tscn`, main scene): rooms, player, camera,
  HUD (120 px band), pause menu, lighting. Room grids, exits, scene paths and door targets come from
  `data/world_data.json` (section 16.7); `ROOM_PATHS` is removed by F2, so the list of rooms is the graph.
  Only the current room and the rooms it can slide into stay loaded. Edge crossing slides the camera 0.45 s with player and rooms frozen and puts the
  player 96 px inside the new room (lateral position kept in the gap). `warp_to(room_id, spawn := &"Default",
  fade := true)` fades 0.3 s out / 0.3 s in. Dying: 0.8 s later fade, full health, at the checkpoint
  (the last cave mouth or shop entered, default `ow_0_0` / `Default`; section 16.9). Dark rooms: `CanvasModulate` plus the player's `PointLight2D` (radius 260).
  Useful for tests: `world.start_at(id, spawn)`, `world.is_transitioning()`, `world.get_current_room_id()`,
  `world.get_room(id)`, `world.player`, `world.camera`, `world.fade_rect`.
- `Room.register_template(container, node)` adds an enemy/bush template at runtime (tests).
- Props: `SolidBlock` (`size`, `kind`), `Brazier` (`brazier_id`, lit by `hook`/`flare` hitboxes, signal
  `lit_changed`), `Gate` (`gate_id`, `braziers: Array[NodePath]` relative to the gate), `LockedDoor`
  (`door_id`, touching with a key spends it), `Bush`, `RoomDoor` (`target_room`, `target_spawn`; put the
  target spawn marker outside the target door's trigger), `PickupBase` placed with `persistent_id` (and
  `item_id` for kind `item`; pedestal = a `SolidBlock` of kind `pedestal`).
- `CrackedWall` (WP6, `scenes/world/cracked_wall.tscn`) is placed in `Props` with `wall_id` (and a `size`).
- World build (section 16): generated rooms are `scenes/world/rooms/<id>.tscn` and pockets
  `scenes/world/rooms/<id>__<tag>.tscn`, compiled from `tools/rooms/*.room` (section 16.8). The seven step-1
  rooms stay hand-made. Launch argument `--start-room=<id>[:spawn]` starts play or capture in any room.

## 12. Writing an enemy: worked example

`scripts/enemies/dummy_walker.gd` is implemented and tested (`tests/test_dummy_walker.gd`). Copy it.

```gdscript
extends EnemyBase
# no class_name

var _walking := false
var _timer := 0.0

func _init() -> void:                 # stats here, not in the scene
	max_hp = 2
	contact_damage = 1
	move_speed = 100.0
	visual_kind = &"dummy_walker"
	body_radius = 28.0

func _enemy_ready() -> void:
	_timer = 0.4

func _enemy_physics(delta: float) -> void:   # set velocity ONLY
	_timer -= delta
	if _walking:
		velocity = facing_dir * move_speed
		if hit_wall:
			facing_dir = -facing_dir
		if _timer <= 0.0:
			_walking = false
			_timer = 0.4
	else:
		velocity = Vector2.ZERO
		if _timer <= 0.0:
			_walking = true
			_timer = randf_range(0.5, 1.2)
			set_facing_dir(Vector2.RIGHT)
```

Scene `scenes/enemies/<name>.tscn` (minimal, nothing else needed):

```
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/enemies/<name>.gd" id="1"]

[node name="<Name>" type="CharacterBody2D"]
script = ExtResource("1")
```

A projectile scene is the same with `type="Area2D"` and `extends EnemyProjectile`.
Keep randomness through `randf()` / `randf_range()` / `randi()`; tests do not seed it, so write tests that
hold for any roll (use `drop_roll_override` for drops).

## 13. Tests

- Every `tests/test_*.gd` is a suite. **Nobody registers anything**: `tools/run_godot_check.py`
  discovers files, runs each in its own headless Godot process with `--fixed-fps 60` (deterministic, one
  physics frame = 1/60 s, runs faster than real time) and isolated `user://`.
  `make test` (all), `make test T="spitcap spore"` (name filters), `python3 tools/run_godot_check.py --list`.
- A suite fails on a failed check, non-zero exit, timeout (90 s), `SCRIPT ERROR`, engine `ERROR:` line or
  leaked objects. Free everything you create (`await dispose(node)`).
- A test file: `extends TestCase` (no `class_name`), override `run()` (it may `await`). `TestCase` (in
  `tests/base_test.gd`) offers:

```gdscript
check(cond, msg)   check_eq(actual, expected, msg)   check_near(actual, expected, tol, msg)
await frames(n)    await seconds(s)                  # physics frames / game seconds
reset_state()      release_inputs()                  # GameState.reset() + release all actions
make_arena(walls: Array[Rect2] = []) -> Node2D       # bare Node2D with optional solid rectangles (global coords)
make_player(parent, at) -> Player
make_enemy(parent, "res://scenes/enemies/x.tscn", at) -> EnemyBase
make_dummy(parent, at, hp := 6) -> EnemyBase         # stationary, harmless EnemyBase for hit tests
make_hitbox(parent, at, team, damage, radius := 30.0) -> Hitbox     # active immediately
make_world() -> World                                # awaits 2 frames
await dispose(node)                                  # queue_free + wait
```

- Skeleton:

```gdscript
extends TestCase

func run() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(600, 500))
	var enemy := make_enemy(arena, "res://scenes/enemies/spitcap.tscn", Vector2(900, 500))
	await frames(2)
	check_eq(enemy.hp, 2, "spitcap has 2 hp")
	# ... behave: await seconds(2.0); check(...)
	await dispose(arena)
```

- Drive the player with `Input.action_press(&"move_right")` / `action_release` (then `release_inputs()` at
  the end). Move the player with `player.place_at(pos)`. Turn it to a facing by pressing a move action
  for two frames.
- To damage an enemy: `enemy.apply_damage(n, from_pos)`, or `make_hitbox(arena, enemy.global_position,
  Layers.Team.PLAYER, n)`. To check player damage: `GameState.health` (half-hearts).
- Tests must hold for any random roll and must not depend on wall-clock time. Wait with `seconds()`.
- `await frames(2)` after adding a node before asserting on overlaps.

## 14. Pitfalls (already hit)

- `collision_layer`/`mask` are bitmasks (section 3). Use `Layers.*`.
- `Area2D.monitorable = false` kills body detection in 4.7 (section 3).
- `preload()` of another WP's file is a hard parse error if it is missing: `load()` + null check.
- New `class_name` scripts need `make import` (class cache) before anything can use them; WP files avoid it.
- `queue_free()` is deferred: a node freed this frame is still valid until the next one. Tests use `dispose()`.
- Do not change `monitoring`, shapes or `disabled` inside `area_entered`-style signals (Godot raises
  "flushing queries"). The core polls overlaps in `_physics_process` instead; do the same, or `set_deferred`.
- Rooms are frozen with `process_mode = DISABLED` during slides: never create `Timer` nodes you need
  to fire while frozen; count time in `_physics_process(delta)`.
- Tile collision polygons (step 2) are measured from the tile centre. Verify real collision visually.
- Metrics do not replace looking: `godot --path . res://tools/capture.tscn -- --room=ow_1_1 --out=/tmp/x.png`
  saves a screenshot (needs a display; not `--headless`).

## 15. Dev world content and tooling (WP7)

**Groups added to the combat components:** every `Hitbox` is in group `hitboxes`, every `Hurtbox` in
`hurtboxes` (the debug overlay reads them; nothing else should).

**Room authoring.** The seven step-1 rooms are plain `.tscn` files built on the 96 px grid (the world build's
rooms are `.room` files compiled by `tools/build_rooms.py`, section 16.8; the same grid rules apply to both): a tile `(c, r)` of the
20x10 grid has its centre at `(96c + 48, 96r + 48)` in room-local pixels, the interior is tiles 1..18 x 1..8,
exits are 2 tiles wide (tiles 9-10 on the n/s sides, rows 4-5 on the w/e sides). Keep a corridor of 3 tiles
in front of each exit free, put hollows on tile centres (they walk the grid) and keep sealed spots (secret
cache, key chamber, the pitch pot closet) closed on every side by solid blocks plus exactly one opener
(cracked wall, gate, locked door). `tests/test_dev_world.gd` checks all of that on the real scenes: enemy
counts per room, nothing on an obstacle, exits clear and reachable, sealed pickups unreachable while closed.
Placed pickups use these persistent ids: `tether_moth`, `pitch_pot`, `cave_key`, `wick_core_cache`; ids of
the openers: brazier `cave_west` / `cave_east`, gate `cave_gate`, door `ow_2_1_pitch`, wall `ow_2_0_cache`.
Pedestal items sit 22 px in front (south) of the solid pedestal so the player's pickup circle can reach them.

**Route (tested in `tests/test_dev_world_route.gd`):** tether moth (`ow_0_1`, pedestal) -> cave entrance in
`ow_1_1` -> light both cave braziers with the hook (gate opens) -> key (`cave_1`) -> locked door in `ow_2_1`
(spends the key) -> pitch pot item (+6 pots) -> place a pot at the cracked wall in `ow_2_0` -> wick core
(+1 max heart, full heal).

**Dev mode.** `godot --path . -- --dev-mode` (`make dev`): all sub-items, 10 pitch pots, 5 keys in every
scope (`World.apply_dev_loadout()`, F4), and F1 toggles `DebugOverlay` (active hitboxes red, hurtboxes green).
Dev mode skips the title and does not write saves (section 16.9). Without the
argument nothing changes: `make run` is the real start. `World.dev_mode`, `World.set_debug_draw(on)`.

**Screenshots.** `tools/capture.tscn` renders into a 1920x1080 SubViewport (size independent of the window):
`godot --path . res://tools/capture.tscn -- --room=ow_1_1 --out=docs/screens/step1/ow_1_1.png`. Options:
`--spawn --frames --place=x,y --facing=up|down|left|right --dev --hitboxes --action=flare|charge|pot`.
The world build adds `--fixture=<scene>` and `--start-room=<id>` (section 16.10).
The step-1 shots are in `docs/screens/step1/` (`docs/.gdignore` keeps Godot from importing them).

## 16. World build (full game)

Written by F0 ([world-work-packages.md](world-work-packages.md)). Binding for every world work package (WP).
Sections 1 to 15 still apply. Each change to them is listed in 16.11; sections 5, 11 and 15 are amended in place.

### 16.1 Sources, precedence and scope

- Design: [world-plan.md](world-plan.md), graph [world-graph.json](world-graph.json). Monsters, bosses and tools:
  [monsters-bosses-tools.md](monsters-bosses-tools.md). Owner decisions: [decisions.md](decisions.md).
- Precedence: owner decisions (decisions.md, world-work-packages.md section 1) win over both plans. For a monster
  number the monster file wins. For an interface or a file name the work package that owns it wins
  (world-work-packages.md section 4 and the Owns lists). Conflicts found while writing this section are in 16.12.
- Scope: 192 rooms (88 overworld, 104 cave), 33 pockets (30 with a scene, 3 in place), 8 tools, regular monsters,
  minibosses, bosses, saves, the title and the intro.
- Ownership of a world file is its Owns list in world-work-packages.md, mapped to paths by `tools/wp_ownership.json`
  (D2). Checks: `python3 tools/check_ownership.py <WP> [--base main]` and `python3 tools/check_ownership.py --global`.
  Section 2 (the step-1 table) does not apply to world WPs.

### 16.2 Rules for every world WP

1. **Read first**: AGENTS.md, this file (sections 1 and 3 to 16), your WP row and the inputs it names. Never guess
   a dimension, path or interface.
2. **Only write the files in your Owns list.** Anything else is reported to the lead, not patched. In waves 1 to 5
   no two WPs own the same file. In wave 0 (sequential) a later WP may amend an earlier file only where its Owns
   list says "amends".
3. Section 1 rules stay: behaviour in `_physics_process`; no `class_name` in WP files (`extends "res://path.gd"` is
   fine); `load()` plus a null check for files another WP delivers; a `Visual` child; half-heart integers;
   `Layers.*` constants. Core files in `scripts/core/` may declare `class_name` (`WorldData`). Story text (title,
   intro, ending) is allowed in the game. Button help lives only in the pause menu.
4. **Placeholder art only.** New entities register their look with `Placeholder.register_kind(...)` (16.6) from
   their own script. Content WPs do not edit `Placeholder.KINDS` or `tools/make_audio.py`. New content reuses the
   existing sounds or stays silent. Art comes in a later pass.
5. **Persistence by flags.** Anything that survives a room change or a save is a flag of 16.4 or of section 5.
   Rooms can be unloaded at any time, so no state lives in a room node.
6. The interface contracts of 16.3 are the only coupling between parallel WPs. A WP's tests use the real
   counterpart if it exists and a small stand-in that obeys the same contract otherwise. F3 and Q7 test every real pair.
7. **Done means**: `make test T="<own suites>"` passes, `make lint` is clean, the visual check of your row was made
   (a capture, 16.10), and the report lists every file touched. The lead runs the full `make check` after the merge.
8. A WP that finds a spec problem stops and reports it. It does not change numbers, normative documents or
   `docs/monsters-bosses-tools.md`.

### 16.3 Interface contracts

These are the only coupling between parallel world WPs (copied from world-work-packages.md section 4).

| Contract | Defined as |
|---|---|
| Fire | `Hitbox.kind = &"fire"`. A prop that burns is in group `burnable` and has `on_fire(pos: Vector2)`. `Brazier` also lights on `fire`. |
| Sling | `Hitbox.kind = &"sling"` (damage 2, one slug on screen, costs one slug). An `EyeSwitch` is in group `eye_switch` and reacts to `sling` hitboxes on `PROP_HURTBOX`. |
| Chime | A resonance prop is in group `resonant` and has `on_chime()`. The warp list is `GameState` flags `mouth_c1` .. `mouth_c10` (set when a cave mouth is first entered). |
| Glow | A hidden prop is in group `revealable` and has `reveal()` / `hide_again()`. The jar adds a `PointLight2D` (radius 520, 6 s) and calls `reveal()` on every `revealable` within its radius while it burns. |
| Raft | `Mooring` is in group `mooring` with `mooring_id`, `target_room`, `target_mooring`. The raft rides the player between two moorings with the Player motion API (F7). |
| Boots | `PitZone` is in group `pit_zone`. `Player.is_airborne()` is true during the leap; a pit only acts when the player is not airborne. |
| Reel | `AnchorRing` is in group `anchor_ring` with `get_anchor_position()`. The reel hitbox has `kind = &"reel"` and carries small pickups with `PickupBase.begin_carry`. |
| Mitts | A small thing is in group `liftable` (`lift(by)`, `throw(dir)`); a `HeavyStone` is in group `heavy` (`try_move(dir)`, `lift_by_mitts(by)`). The mitts item checks `GameState.has_item(&"heft_mitts")`. |
| Grate | A grate is in group `grate`. It blocks the player body (layer `WORLD`); the tether moth's turn-back ray ignores bodies in that group (P09 amends `tether_moth.gd`). |
| Ward | The ward absorbs a blockable `Hitbox`; the existing `Hitbox.blocked` signal fires. A `WardPlate` counts those blocks (P15). |
| Shallows | Fen leeches need `Area2D` zones in group `shallows`; rooms place them (R4, C03, C09, C10). |
| Boss | `BossBase` (M0) extends `EnemyBase`, sets flag `boss_<cave room id>_defeated` on death (for example `boss_cave_10_14_defeated`), emits `defeated`, and locks the arena doors for the fight. Placed rewards use `PickupBase.requires_flag` (F4) so they appear only after that flag. |
| Spawn markers | Cave mouth room has marker `FromCave`; cave entrance room has marker `FromOverworld`; pocket door pairs use `FromPocket` / `Inside`. All room doors take their targets from `data/world_data.json`. |
| Gate prop names | One prop name per row of world-plan 1.3 / 2.2; the generator emits a `prop` string per edge and `tests/test_world_graph.gd` maps each to a scene or script (F3 table). |

### 16.4 Flags

Flags are `GameState` flags and survive room changes and saves (section 16.9). Existing flags of section 5 stay.

| Flag | Set when | Set by (WP) |
|---|---|---|
| `picked_<persistent_id>`, `door_<door_id>`, `gate_<gate_id>`, `brazier_<brazier_id>`, `cracked_<wall_id>` | existing | core (section 5) |
| `mouth_c1` .. `mouth_c10` | the mouth room of cave N is entered for the first time; the warp list (T06) reads them | World |
| `bigkey_c1` .. `bigkey_c10` | the big key of cave N is collected (kind `big_key`) | F4 |
| `frag_c1` .. `frag_c9` | the fragment of cave N is collected (kind `fragment`). C10 gives none. | F4 |
| `boss_<cave room id>_defeated` | the boss of that cave room dies (for example `boss_cave_10_14_defeated`) | M0 and the boss WPs |
| `mini_<room_id>` | a miniboss dies; it does not respawn | miniboss WPs (monster file section 3) |
| `door_boss_<cave>` | the BossDoor opens with `bigkey_cN` | P10 |
| `door_ninth` | the Ninth Door opens with `frag_c1` .. `frag_c9` | P11 |
| `pot_bag_1`, `pot_bag_2` | a pot bag is collected; `pot_max()` rises by 4 (14, then 18) | F5 |
| `shop_<id>` | a one-time shop stock item is sold | F9 |
| `burned_<id>` | a `Burnable` prop has burned open and stays open | P01 |
| `eye_<id>` | an `EyeSwitch` is on | P02 |
| `moved_<id>` | a `HeavyStone` opening was moved or lifted open | P06 |
| `resonated_<id>` | a resonance stone or door is awake | P07 |
| `revealed_<id>` | a `HiddenSeam` is revealed | P08 |
| `ward_<id>` | a `WardPlate` was satisfied | P15 |
| `ending_rekindle`, `ending_wickwarden` | the ending choice was made (names from the monster file, 16.12) | E1 |
| `intro_seen` | the intro finished once. It is kept in `user://settings.json`, not in the save | F14 writes, F13 reads |

### 16.5 Keys, wallet, ammo, pickups, shops, items (additions to sections 5, 8 and 9)

- **Scoped keys** (decision 3). A key's scope is `ow` or a cave `cN`. `keys_in(scope)`, `add_key(n, scope)`, `use_key(scope)`.
  A key spends only in its own scope. `LockedDoor` and `PickupBase` take `scope` (default `ow`); the scene states it,
  and the graph test checks it against the graph.
- **Big keys and fragments** are flag-backed: `has_big_key(cave)` reads `bigkey_cN`; `add_fragment(cave)` sets `frag_cN`.
- **Wallet**: `WALLET_CAP = 999` (decision 7). `spend_currency(n) -> bool` spends only when there is enough.
- **Pitch pot limit**: `pot_max()` = 10 plus 4 per pot bag flag (10, 14, 18; decision 4). `PITCH_POT_MAX` stays as the base.
- **Sling ammo** (decision 9): `slugs`, `slug_max()` = 30; 12 on the first pickup of the sling; `slug_bundle` +6;
  `add_slugs(n)`, `spend_slug() -> bool`. The drop table is `pick(roll, pitch_pot_found, sling_found)`; the slug
  bundle drops at 8 % only after the sling is found.
- **New pickup kinds** (section 8): `big_key`, `fragment`, `pot_bag` (sets the next bag flag), `slug_bundle`. Placed
  pickups may set `requires_flag`: inactive and invisible until that flag exists. Wick cores stay kind `wick_core`
  with the persistent ids of section 15 plus `wick_core_cN`.
- **Shops** (F9): `ShopItem`, a walk-up purchase. Stock kinds: `ember` (+1 heart at purchase), `pot_bundle` (+4 pots,
  only after the pot item is found), `slug_bundle`, `tallow_flask` (full heal on purchase, no inventory slot;
  decision 13). Prices are read from `data/shop_prices.json`, never written in code.
- **Items** (section 9, F10): `ItemRegistry` registers all ten ids up front: `tether_moth`, `pitch_pot` (step 1) and
  `cinder_wick`, `tallow_sling`, `reed_raft`, `heft_mitts`, `glow_jar`, `lantern_chime`, `skitter_boots`, `reel_line`.
  Scripts are `res://scripts/items/<id>.gd` and scenes `res://scenes/items/<id>.tscn`.
- **Item subscreen** (decision 6, 20): opens with Tab (Select on a gamepad). It shows all items in a grid; move keys
  select; confirm equips. `cycle_item` stays as the quick switch.

### 16.6 Combat, props, monsters and placeholders (additions to sections 3, 6, 7, 10)

- **Collision layers** (section 3 table is not edited): `WATER` = 1024 (layer 11), blocker bodies of deep water;
  `FEET` = 2048 (layer 12), foot sensors. `PitZone` has mask `FEET`. Use `Layers.*` only.
- **Hitbox kinds** (section 6): `&"fire"`, `&"sling"`, `&"reel"`, `&"thrown"`, `&"grab"`, `&"chime"`. New fields
  `block_destroys_carrier := true` and `tick_interval := 0.0`.
- **Enemy fields and hooks** (section 7): `stun_scale`, `knockback_scale`, `chime_stun_time`, `reel_light`,
  `armor_front_deg`, `water_only`, `ignore_water`; virtual `_resolve_damage(hitbox, amount) -> int` (0 blocks);
  signal `guard_blocked(hitbox)`. Projectiles (section 8) gain `homing_turn_deg` and `shape_capsule`.
- **Player** (section 4 and 16.3): state enum `NORMAL, CARRY, RAFT, LEAP, REEL`; `begin_external_motion(mode,
  path_or_controller)`, `end_external_motion()`; a foot sensor on `FEET`; `set_hurtbox_enabled(bool)`. The existing
  `use_item()` stays generic.
- **Tool and monster API details** are section 7 of [monsters-bosses-tools.md](monsters-bosses-tools.md). That section
  is part of this contract. M0 owns the four core files it names (decision 36) and merges them before any wave 1
  monster WP starts.
- **Placeholders** (section 10): `Placeholder.register_kind(kind, definition, is_static := false)` and
  `Placeholder.has_kind(kind)`. A world WP registers its kind from its own script. `Placeholder.KINDS` is not edited
  by content WPs. The look-edit allowance of section 10 is for step 1 only.

### 16.7 Data and world runtime (amends section 11)

- **`data/world_data.json`** is generated by `tools/gen_world_data.py` from `docs/world-graph.json` (F1). It is never
  edited by hand. `make world-check` regenerates it to a temporary file and fails when the committed copy differs.
  It holds rooms (`id`, `scene`, `grid`, `exits`, `dark`, `scope` = `ow` or `cN`, `region`, `name`, `enemies`),
  pockets (`id`, `scene` with `#` replaced by `__`, `in_place`, virtual `grid` on row 30), edges (`a`, `b`, `link`,
  `gate`, `needs`, `dir`, `key`, `prop`), pickups, items, shops, caves (mouth room, entrance room, lantern name) and
  `source_sha` of the graph.
- **`WorldData`** (`scripts/core/world_data.gd`, static methods): `room_ids()`, `has(id)`, `scene_path(id)`,
  `grid(id)`, `exits(id)`, `scope_of(id)`, `neighbors(id)`, `edge_between(a, b)`, `is_oneway(a, b)`, `cave_of(id)`,
  `pickups_in(id)`, `all_pockets()`.
- **Pockets**: a pocket `<room>#<tag>` has the scene `scenes/world/rooms/<room>__<tag>.tscn` (for example `ow_7_2#bag`
  becomes `ow_7_2__bag.tscn`). The three sealed spots `ow_2_0#cache`, `ow_2_1#closet` and `cave_1#alcove` are
  `in_place` (no scene; decision 15). Every other pocket has its own scene. Pockets sit on virtual row 30 and are
  never part of the world grid.
- **Grid**: cave rooms use rows 12 and later. `cave_1` moves from grid (0, 3) to grid (1, 13), world (1920, 12480)
  (F2). Overworld rooms keep `(x*1920, y*960)`.
- **World** (F2): `ROOM_PATHS` is removed; `_by_grid` is built from `WorldData`. The current room and the rooms it
  can slide into stay loaded; `get_room(id)` loads on demand; pockets load on `warp_to`. `World.add_room_scene(room_id,
  packed_scene)` is a test and capture hook. A room without a scene is a warning and a closed edge.
- **Doors and spawns**: targets of generated rooms come from `data/world_data.json`. Markers: `FromCave` (cave mouth
  room), `FromOverworld` (cave entrance room), `FromPocket` and `Inside` (pocket door pairs).
- **Data files** are read at run time from `data/` (`world_data.json`, `shop_prices.json`, `intro.json`,
  `ending.json`). Nothing reads `docs/` at run time (`docs/.gdignore`). The export includes `data/*.json` through the
  JSON export filter (decision 17).

### 16.8 File layout (new)

The Owns lists of world-work-packages.md are authoritative; this table is the summary.

| Path | Content | Owner |
|---|---|---|
| `docs/world-plan.md`, `docs/world-graph.json`, `docs/world-work-packages.md`, `docs/monsters-bosses-tools.md`, `docs/decisions.md` | designs and decisions | their WPs and the owner |
| `docs/intro-script.md` | intro lines and still briefs | D3 |
| `docs/room-kit.md` | `.room` format | F6 |
| `data/world_data.json` | generated graph | F1 |
| `data/shop_prices.json` | shop prices (tuning, no code) | F9 |
| `data/intro.json` | intro lines | F14 |
| `data/ending.json` | ending lines | E1 |
| `tools/gen_world_data.py`, `tools/build_rooms.py`, `tools/check_world_graph.py` | generator, room compiler, graph checker | F1, F6, G1 |
| `tools/rooms/<id>.room`, `tools/rooms/<id>__<tag>.room` | room sources (the compiler's input) | room batch WPs |
| `tools/wp_ownership.json`, `tools/check_ownership.py`, `tools/test_check_ownership.py` | ownership map and checker | D2 |
| `scenes/world/rooms/<id>.tscn`, `scenes/world/rooms/<id>__<tag>.tscn` | compiled rooms and pockets (never edited by hand); the seven step-1 rooms stay hand-made | F6, room batch WPs |
| `scenes/bosses/<name>_arena.tscn` | boss arena fragment, placed in the boss room by the lead | boss WPs |
| `scripts/core/world_data.gd` (`WorldData`) | static data reader | F1 |
| `scripts/autoload/save_game.gd` (`SaveGame`) | the save slot | F12 |
| `scripts/world/*` props (burnable, eye_switch, mooring, water_zone, pit_zone, anchor_ring, reelable, liftable, heavy_stone, resonance_stone, hidden_seam, ward_plate, ninth_door, boss_door, shop_item, ending_trigger, ...) | props and triggers | the P-, S- and E-WPs |
| `scripts/items/<id>.gd`, `scenes/items/<id>.tscn` | the eight tools and their helpers | T-WPs |
| `scripts/enemies/*` | regular monsters, minibosses, bosses, `boss_base.gd`, `boss_part.gd`, `telegraph.gd` | M-, B- WPs; M0 for the boss base |
| `scripts/ui/*` | title, menu list, intro, ending, warp picker, item subscreen, minimap in `hud.gd` | F10, F11, F13, F14, E1, T06 |
| `tests/test_world_data.gd`, `tests/test_world_graph.gd`, `tests/area_base.gd`, `tests/fixtures/gallery/<wp>.tscn`, `tests/fixtures/rooms/` | tests and fixtures | F1, F3, F2, F6 |
| `assets/art/<name>.png` | stills and sprites (a later art pass) | art |
| user data: `user://save_1.json`, `user://save_1.bad`, `user://settings.json` | save slot, a kept corrupt save, settings | F12, F13 |

### 16.9 Saves, title and flow

- **One save slot** (decision 16): `user://save_1.json`, versioned (`format`, `game_version`), written atomically
  (temporary file, then rename). Contents: health, max health, wallet, keys by scope, pots, slugs, items, active item,
  visited rooms, all flags, the checkpoint room and the playtime. A corrupt or newer file is ignored with a warning
  and kept as `save_1.bad`.
- **Autosave** on every room entry (debounced to once per second) and after every persistent pickup.
- **Checkpoint**: the last cave mouth or shop entered; default `ow_0_0`. Death returns the player there with full
  health; flags are kept.
- **`SaveGame`** (autoload): `has_save()`, `save()`, `load_into_state()`, `erase()`, `launch_mode` (`&"new"`,
  `&"continue"`, `&"dev"`). `SaveGame.enabled` is false in tests and in `--dev-mode`; `TestCase.reset_state()` keeps it so.
- **Title** (decision 14): New game, Continue, Quit. Continue is greyed out without a save. New game with a save asks
  once (Yes/No) before it erases the slot. The title is the main scene; `--dev-mode`, `--start-room` and the capture
  tool skip it.
- **Intro** after New game: six stills, skippable at once by any confirm key or Esc (decision 21). It shows no skip hint.
  It sets `intro_seen` in the settings file.
- **Ending** (decisions 12, 22): after the Unlit dies (flag `boss_cave_10_14_defeated`), two lit lanterns with Corrow
  between them; no text during the choice. Both endings end with the credits and a return to the title; the save is
  marked `completed`.
- **Pause menu** has "Back to title" (decision 23).

### 16.10 Build commands, captures and tests

- **Make targets** added by F1: `world-data`, `world-check`, `world-gen-test`, `rooms`, `rooms-check`, `capture-all`,
  `playthrough`. A target whose tool is built later prints "not built yet". `check` gains `world-check` and `world-gen-test`.
  AGENTS.md lists `world-data`, `world-check`, `rooms` and `capture-all` for daily use.
- **Long suites**: a suite may declare `## timeout=<seconds>` as its first line (F3) to exceed the 90 s default (decision 24).
- **Captures**: `tools/capture.gd --fixture=<scene>` renders a WP's gallery scene `tests/fixtures/gallery/<wp>.tscn`
  (F2). `--start-room=<id>[:spawn]` captures any room. Full-size captures stay out of git; commit contact sheets only
  (decision 18).

### 16.11 Amendment table

| Section | Change | Where | WP |
|---|---|---|---|
| 3 Collision layers | `WATER` 1024, `FEET` 2048 | 16.6 (table not edited) | M0 |
| 5 Autoloads | `GameState`: scoped keys, big keys, fragments, wallet cap, pot limit, slugs; flags | edited in place, 16.4 | F4, F5 |
| 6 Combat components | new hitbox kinds and fields | 16.6 | M0 |
| 7 EnemyBase | new fields and virtual `_resolve_damage`, signal `guard_blocked` | 16.6 | M0 |
| 8 Pickups | kinds `big_key`, `fragment`, `pot_bag`, `slug_bundle`; `scope`, `requires_flag` | 16.5 | F4, F5 |
| 9 Sub-items | ten ids; item subscreen; Tab | 16.5 | F10 |
| 10 Placeholder art | `register_kind`, `has_kind`; `KINDS` not edited by content WPs | 16.6 | F2 |
| 11 Room system | data-driven rooms, streaming, `cave_1` moves, pockets, `--start-room`, checkpoint respawn | edited in place, 16.7 | F1, F2, F12 |
| 13 Tests | `## timeout=<seconds>` header | 16.10 | F3 |
| 15 Dev world | five keys in every scope; dev mode skips title and saves; room authoring; capture options | edited in place | F4, F6, F12, F13 |
| 1, 2, 4, 12, 14 | unchanged. Section 2 is the step-1 table | none | |
| 16 (new) | the world build | this section | F0 |

### 16.12 Open conflicts (for the lead)

Found while writing this section. The contract above uses the name in the second column. The lead settles each one
before the WP named in the last column starts.

| Topic | Monster file says | Work packages say (used here) | Before |
|---|---|---|---|
| Boss flag | `boss_cN` (sections 4 intro and 7.3) | `boss_<cave room id>_defeated` (M0, B10, F0) | M0 |
| Mouth flag | (open question 8) set when fragment N is taken | set on first entry of the mouth room (F0, T06) | T06 |
| Sling and pot API | `tallow_slugs`, `add_tallow_slugs`, `spend_tallow_slug`, `add_pot_bags` (7.2) | `slugs`, `add_slugs`, `spend_slug`, `pot_max()` (F5) | F5 |
| Flag spellings | `burn_<id>`, `stone_<id>`, `seam_<id>`, `reson_<id>` | `burned_`, `moved_`, `revealed_`, `resonated_` (P01, P06, P08, P07) | P01 |
| Ending | `ending_choice.gd`, flags `ending_rekindle` / `ending_wickwarden` (7.3) | `ending_trigger.gd`, no flag names (E1). The flag names are kept in 16.4 | E1 |
| Intro flag | `intro_seen` is a save flag (F14 says "sets intro_seen") | a settings-file flag (F13) | F13 |
| Make and AGENTS | `rooms-check`, `world-gen-test`, `playthrough` exist (F1) | not in AGENTS.md (F0 lists four commands) | F0 review |
