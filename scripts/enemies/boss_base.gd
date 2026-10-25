extends EnemyBase
## Base of every boss and miniboss (monsters-bosses-tools sections 3 and 4.0). Not a class_name: subclasses
## use `extends "res://scripts/enemies/boss_base.gd"` or the boss file's own path.
##
## What the base does for you:
##   * Intro: `intro_time` seconds (1.5) after the boss enters the room it is invulnerable, has no hurtbox and
##     no contact; then the fight starts with `_enter_phase(1)`. Minibosses have no intro.
##   * Phases: `thresholds` lists the HP at which the next phase starts (phase 2 when hp <= thresholds[0]).
##     A phase change clears the boss's hazards (projectiles, telegraphs, hitboxes added with add_hazard),
##     makes it invulnerable for 1.2 s, spawns one timed ember at the arena centre if Tamsin is hurt, and
##     calls `_enter_phase(n)`.
##   * Resupply (`resupply = true`, C2, C9, C10): a pitch pot bundle and a slug bundle when Tamsin needs them,
##     at each phase start and every 30 s.
##   * Arena lock (`arena_lock`, not for minibosses): the first hit closes every node of group `arena_door` in
##     the boss's room (it must have `set_locked(locked: bool)`). Death, reset_fight() and leaving the room open them.
##   * Death: the lethal hit starts 1.5 s of death throes (flash, no attacks, hazards cleared). The flag
##     `boss_<arena id>_defeated` (miniboss: `mini_<room id>`) is set at once, signal `defeated` is emitted, then
##     the boss dies. `death_drops` (untimed pickups) appear at the arena centre and 192 px to its right.
##     No drop table roll (drops_enabled is false).
##   * A defeated boss stays dead: a boss whose flag is set is hidden and inert when its room loads.
##   * Stun and knockback are off (stun_scale and knockback_scale are 0); a subclass that needs them sets them.
##   * Parts (BossPart, group-less EnemyBase children) are attached with adopt_part(); the boss hears their
##     `damaged` and `died` signals through _on_part_hurt() and _on_part_defeated().
##
## Subclass hooks (override; do not override _enemy_ready / _enemy_physics, the base drives the fight):
##   _boss_ready()            once, when the boss is set up (not for a retired boss)
##   _boss_physics(delta)     the fight: attacks and movement. Set `velocity` only. Not run during the
##                            intro, a phase pause or the death throes.
##   _enter_phase(number)     a phase starts (1 when the intro ends). Start the attack timers here.
##   _on_part_hurt(amount, part) and _on_part_defeated(part)
##   _on_death()              call super() first; the base sets the flag and clears the boss's parts.
##
## Shared numbers: ARENA_CENTRE is the room-local centre (960, 480); the drops and the resupply use it.

signal defeated(boss: EnemyBase)
signal phase_changed(phase: int)
signal arena_lock_changed(locked: bool)

const ARENA_CENTRE := Vector2(960.0, 480.0)
const DROP_SPREAD := 192.0
const PHASE_PAUSE := 1.2
const DEATH_TIME := 1.5
const DEATH_BLINK := 0.1
const RESUPPLY_INTERVAL := 30.0
const RESUPPLY_POT_BELOW := 4
const RESUPPLY_SLUG_BELOW := 8
const HEALTH_RING_RADIUS := 14.0

## Identity of the boss (for tests, logs and the boss tables).
@export var boss_id: StringName = &""
## Room id used for the flag. Empty = the id of the Room this node is in.
@export var arena_id: StringName = &""
## True for minibosses: flag `mini_<room id>`, no intro, no arena lock.
@export var miniboss: bool = false
## True: the first hit closes the arena doors (group `arena_door`). Ignored for minibosses.
@export var arena_lock: bool = true
## Seconds between the boss becoming visible and the fight starting.
@export var intro_time: float = 1.5
## HP at which the next phase starts, one entry per phase change (phase 2 at thresholds[0], phase 3 at [1]).
@export var thresholds: Array[int] = []
## True: pitch pot and slug bundles are spawned at phase starts and every 30 s when Tamsin needs them.
@export var resupply: bool = false
## Untimed pickup kinds spawned on death: the first at the arena centre, the others 192 px to its right.
@export var death_drops: Array[StringName] = []
## True: a thin ring around the boss shows its HP (default off, monsters-bosses-tools open question 2).
@export var health_ring: bool = false
## Current phase, 1 to phase_count().
var phase: int = 1

var _intro_left: float = 0.0
var _fight_started: bool = false
var _pause_left: float = 0.0
var _dying: bool = false
var _death_left: float = 0.0
var _defeated: bool = false
var _arena_locked: bool = false
var _ember_pending: bool = false
var _resupply_pending: bool = false
var _resupply_left: float = RESUPPLY_INTERVAL
var _hazards: Array[Node] = []
var _parts: Array[EnemyBase] = []


func _init() -> void:
	_register_kinds()
	visual_kind = &"boss"
	body_radius = 60.0
	drops_enabled = false
	stun_scale = 0.0
	knockback_scale = 0.0


## Placeholder look of the boss kind (placeholder visuals only).
static func _register_kinds() -> void:
	if not Placeholder.has_kind(&"boss"):
		Placeholder.register_kind(
			&"boss", {"shape": "circle", "color": Color(0.45, 0.3, 0.55), "radius": 60.0}
		)


func _enemy_ready() -> void:
	add_to_group(&"bosses")
	if not Events.player_died.is_connected(_on_player_died):
		Events.player_died.connect(_on_player_died)
	if GameState.has_flag(_defeat_flag()):
		_retire()
		return
	_reset_state()
	_boss_ready()


# ---- Virtual hooks ---------------------------------------------------------------------------


## Once, when the boss is set up. Connect signals and create parts here.
func _boss_ready() -> void:
	pass


## The fight: attacks and movement, every physics frame while the boss is active. Set `velocity` only.
func _boss_physics(_delta: float) -> void:
	pass


## A phase starts (1 when the intro ends, then 2, 3 ...). Start the attack timers of that phase here.
func _enter_phase(_number: int) -> void:
	pass


## A part of this boss took `amount` damage (the part's hp is already reduced).
func _on_part_hurt(_amount: int, _part: EnemyBase) -> void:
	pass


## A part of this boss died (it is gone at the end of the frame).
func _on_part_defeated(_part: EnemyBase) -> void:
	pass


func _on_hurt(_hitbox: Hitbox) -> void:
	if _dying:
		return
	_lock_arena()
	if hp <= 0:
		hp = 1  # kept alive for the death throes; _tick_death() calls kill()
		_begin_death()
		return
	_check_thresholds()
	queue_redraw()


func _on_death() -> void:
	_defeat()
	clear_hazards()
	_free_parts()
	for i in range(death_drops.size()):
		var offset := Vector2(DROP_SPREAD, 0.0) if i > 0 else Vector2.ZERO
		spawn_pickup(death_drops[i], ARENA_CENTRE + offset, false)


# ---- Public API ------------------------------------------------------------------------------


## Number of phases: one more than the thresholds.
func phase_count() -> int:
	return thresholds.size() + 1


func is_defeated() -> bool:
	return _defeated


func is_dying() -> bool:
	return _dying


## True while the intro runs (the boss is visible but cannot be hurt and does not attack).
func is_in_intro() -> bool:
	return not _fight_started and not is_dead


## True during the 1.2 s invulnerable pause of a phase change.
func is_pausing() -> bool:
	return _pause_left > 0.0


func is_arena_locked() -> bool:
	return _arena_locked


## Records a hazard (a projectile, telegraph or hitbox this boss made). Phase changes and death remove them.
func add_hazard(node: Node) -> void:
	if node == null:
		return
	_hazards.append(node)


## Removes every hazard recorded with add_hazard() or fired with fire_projectile().
func clear_hazards() -> void:
	for node in _hazards:
		if is_instance_valid(node) and not node.is_queued_for_deletion():
			node.queue_free()
	_hazards = []


## Adds a part (a BossPart or any EnemyBase) next to the boss at `at`. The part's `damaged` and `died`
## signals come to this boss. Safe in physics callbacks (adopt_deferred).
func adopt_part(part: EnemyBase, at: Vector2) -> EnemyBase:
	part.damaged.connect(_on_part_hurt.bind(part))
	part.died.connect(_part_died)
	_parts.append(part)
	return adopt_deferred(part, at)


## The parts of this boss that are still alive.
func parts() -> Array[EnemyBase]:
	var alive: Array[EnemyBase] = []
	for part in _parts:
		if is_instance_valid(part) and not part.is_dead:
			alive.append(part)
	return alive


## Restores the boss to its start: full HP, phase 1, intro again, arena doors open, parts and hazards gone.
## Does nothing to a dead boss. Called on player death; leaving the room frees the boss and the next
## entry makes a new one.
func reset_fight() -> void:
	if is_dead:
		return
	_set_arena_locked(false)
	clear_hazards()
	_free_parts()
	_reset_state()


## Room-local point `local` converted to global coordinates (the room's origin is the boss's room).
func arena_point(local: Vector2) -> Vector2:
	var room := _room()
	var origin := room.global_position if room != null else global_position - ARENA_CENTRE
	return origin + local


## Spawns a pickup of `kind` under the boss's parent at a room-local point. Timed pickups vanish after 8 s.
func spawn_pickup(kind: StringName, local: Vector2, timed: bool) -> void:
	var parent := get_parent()
	if parent == null:
		return
	PickupBase.spawn(kind, parent, arena_point(local), timed)


## Fires a projectile like EnemyBase and records it as a hazard of this boss.
func fire_projectile(
	scene: PackedScene,
	dir: Vector2,
	proj_speed: float = -1.0,
	proj_damage: int = -1,
	from: Vector2 = Vector2.INF
) -> EnemyProjectile:
	var projectile := super.fire_projectile(scene, dir, proj_speed, proj_damage, from)
	add_hazard(projectile)
	return projectile


func _draw() -> void:
	if not health_ring or is_dead:
		return
	var ring_radius := body_radius + HEALTH_RING_RADIUS
	draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 64, Color(0.0, 0.0, 0.0, 0.5), 6.0)
	var ratio := clampf(float(hp) / float(max_hp), 0.0, 1.0) if max_hp > 0 else 0.0
	if ratio > 0.0:
		draw_arc(
			Vector2.ZERO,
			ring_radius,
			-PI * 0.5,
			-PI * 0.5 + TAU * ratio,
			64,
			Color(0.9, 0.3, 0.25),
			6.0
		)


# ---- Fight driver ----------------------------------------------------------------------------


func _enemy_physics(delta: float) -> void:
	velocity = Vector2.ZERO
	if _dying:
		_tick_death(delta)
		return
	if not _fight_started:
		_intro_left -= delta
		if _intro_left > 0.0:
			return
		_start_fight()
	_flush_phase_effects()
	if _pause_left > 0.0:
		_pause_left -= delta
		if _pause_left <= 0.0:
			_pause_left = 0.0
			invulnerable = false
		return
	if resupply:
		_resupply_left -= delta
		if _resupply_left <= 0.0:
			_resupply_left = RESUPPLY_INTERVAL
			_spawn_resupply()
	if health_ring:
		queue_redraw()
	_boss_physics(delta)


func _start_fight() -> void:
	_fight_started = true
	_intro_left = 0.0
	hurtbox.enabled = true
	invulnerable = false
	set_contact_enabled(true)
	_resupply_pending = resupply
	_resupply_left = RESUPPLY_INTERVAL
	_enter_phase(phase)


func _check_thresholds() -> void:
	while phase <= thresholds.size() and hp <= thresholds[phase - 1]:
		_start_phase(phase + 1)


func _start_phase(number: int) -> void:
	phase = number
	clear_hazards()
	_pause_left = PHASE_PAUSE
	invulnerable = true
	_ember_pending = true
	_resupply_pending = resupply
	_resupply_left = RESUPPLY_INTERVAL
	phase_changed.emit(phase)
	_enter_phase(phase)


## Spawns the phase-start pickups. Runs in _enemy_physics, never inside a hit callback.
func _flush_phase_effects() -> void:
	if _ember_pending:
		_ember_pending = false
		if GameState.health < GameState.max_health:
			spawn_pickup(&"ember", ARENA_CENTRE, true)
	if _resupply_pending:
		_resupply_pending = false
		_spawn_resupply()


func _spawn_resupply() -> void:
	if GameState.has_item(&"pitch_pot") and GameState.pitch_pots < RESUPPLY_POT_BELOW:
		spawn_pickup(&"pitch_pot_bundle", ARENA_CENTRE, true)
	if GameState.has_item(&"tallow_sling") and GameState.slugs < RESUPPLY_SLUG_BELOW:
		spawn_pickup(&"slug_bundle", ARENA_CENTRE, true)


func _begin_death() -> void:
	_dying = true
	_death_left = DEATH_TIME
	invulnerable = true
	clear_hazards()
	_defeat()


func _tick_death(delta: float) -> void:
	_death_left -= delta
	if visual != null:
		var flash := int(_death_left / DEATH_BLINK) % 2 == 0
		visual.modulate = Color(4.0, 4.0, 4.0, 1.0) if flash else Color.WHITE
	if _death_left <= 0.0:
		kill()


## Sets the defeat flag and signal once, and opens the arena.
func _defeat() -> void:
	if _defeated:
		return
	_defeated = true
	_set_arena_locked(false)
	GameState.set_flag(_defeat_flag())
	defeated.emit(self)


func _reset_state() -> void:
	# EnemyBase timers otherwise delay the new fight or carry old hits into it.
	_stun_time = 0.0
	_knock_time = 0.0
	_knock_velocity = Vector2.ZERO
	_iframe_time = 0.0
	_flash_time = 0.0
	velocity = Vector2.ZERO
	hit_wall = false
	hp = max_hp
	phase = 1
	_fight_started = false
	_intro_left = 0.0 if miniboss else intro_time
	_pause_left = 0.0
	_dying = false
	_death_left = 0.0
	_defeated = false
	_arena_locked = false
	_ember_pending = false
	_resupply_pending = false
	_resupply_left = RESUPPLY_INTERVAL
	_hazards = []
	_parts = []
	var intro := _intro_left > 0.0
	hurtbox.enabled = not intro
	invulnerable = intro
	hurtbox.invulnerable = intro
	set_contact_enabled(not intro)
	if visual != null:
		visual.modulate = Color.WHITE
	queue_redraw()


## A boss that is already defeated: hidden, no hurtbox, no contact, never runs.
func _retire() -> void:
	is_dead = true
	hurtbox.enabled = false
	set_contact_enabled(false)
	visible = false


func _free_parts() -> void:
	for part in _parts:
		if is_instance_valid(part) and not part.is_queued_for_deletion():
			part.queue_free()
	_parts = []


func _part_died(enemy: EnemyBase) -> void:
	_parts.erase(enemy)
	_on_part_defeated(enemy)


func _lock_arena() -> void:
	if arena_lock and not miniboss and not _defeated:
		_set_arena_locked(true)


func _set_arena_locked(locked: bool) -> void:
	if _arena_locked == locked:
		return
	_arena_locked = locked
	for door in _arena_doors():
		door.call(&"set_locked", locked)
	arena_lock_changed.emit(locked)


func _arena_doors() -> Array[Node]:
	var doors: Array[Node] = []
	if not is_inside_tree():
		return doors
	var scope: Node = _room()
	if scope == null:
		scope = get_parent()
	if scope == null:
		return doors
	for node in get_tree().get_nodes_in_group(&"arena_door"):
		if scope.is_ancestor_of(node) and node.has_method(&"set_locked"):
			doors.append(node)
	return doors


func _on_player_died() -> void:
	reset_fight()


func _exit_tree() -> void:
	if Events.player_died.is_connected(_on_player_died):
		Events.player_died.disconnect(_on_player_died)
	_set_arena_locked(false)


func _room() -> Room:
	var node := get_parent()
	while node != null:
		if node is Room:
			return node as Room
		node = node.get_parent()
	return null


func _room_id() -> StringName:
	if arena_id != &"":
		return arena_id
	var room := _room()
	return room.room_id if room != null else &""


## The flag set on death: `boss_<arena room id>_defeated`, or `mini_<room id>` for a miniboss.
func _defeat_flag() -> StringName:
	if miniboss:
		return StringName("mini_%s" % _room_id())
	return StringName("boss_%s_defeated" % _room_id())
