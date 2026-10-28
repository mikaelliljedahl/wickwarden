class_name EnemyBase
extends CharacterBody2D
## Base class of every enemy. Subclass it, set stats in _init(), override the virtual hooks.
## See docs/code-contract.md for the full contract and scripts/enemies/dummy_walker.gd for a
## minimal worked example.
##
## The base builds everything an enemy needs at _ready (body CollisionShape2D, Hurtbox, contact
## Hitbox, Placeholder "Visual") unless the scene already provides a node with that name, so an
## enemy scene can be just a CharacterBody2D root with the script attached.
##
## Subclass rules:
##   * Set hp / speed / visual in _init() (before the scene sets properties, after base _init).
##   * Put behaviour in _enemy_physics(delta): set `velocity` only. The base calls move_and_slide()
##     and keeps the enemy inside `room_rect` afterwards.
##   * Never read from the "Visual" node.

signal damaged(amount: int)
signal died(enemy: EnemyBase)
signal stunned(seconds: float)
## A hit from the front guard (armor_front_deg) was stopped: hitbox is the blocked hit.
signal guard_blocked(hitbox: Hitbox)

const FLASH_TIME := 0.1
const HIT_KNOCKBACK_FALLBACK := 480.0
const IFRAME_TIME := 0.25
const BODY_NAME := "BodyShape"
const HURTBOX_NAME := "Hurtbox"
const CONTACT_NAME := "ContactHitbox"
## Seconds of the guard spark and the push on the attacker (monsters-bosses-tools section 1.3).
const GUARD_PUSH_SPEED := 200.0
const GUARD_PUSH_TIME := 0.1

@export var max_hp: int = 2
## Contact damage in half-hearts, dealt by the ContactHitbox while it overlaps the player.
@export var contact_damage: int = 1
@export var move_speed: float = 120.0
## Placeholder kind and size (see scripts/art/placeholder.gd KINDS).
@export var visual_kind: StringName = &"generic"
@export var body_radius: float = 28.0
## False for enemies that must not drop loot (e.g. spawned children).
@export var drops_enabled: bool = true
## Tests: force the drop roll (0..1). Negative = random.
@export var drop_roll_override: float = -1.0

## Global rectangle the enemy is kept inside. Set by Room on spawn. Rect2() (size 0) = unbounded.
var room_rect: Rect2 = Rect2()
var hp: int = 2
var is_dead: bool = false
## Set by subclasses (e.g. airborne skitterwick): ignores all hits while true.
var invulnerable: bool = false
## True after a move_and_slide() that touched a wall, for turn-around logic.
var hit_wall: bool = false
var facing_dir: Vector2 = Vector2.DOWN

## Stat knobs set in _init() (plain vars: a scene never overrides them).
## Multiplies the stun time of a hit with stun_time (moth stun). 0 = immune. Direct stun() is not scaled.
var stun_scale: float = 1.0
## Multiplies the knockback speed of every hit. 0 = immune to knockback.
var knockback_scale: float = 1.0
## Seconds of stun for a `chime` hit (lantern chime). 0 = the chime does nothing. Set it to 0 while a
## monster cannot be stunned by the chime (for example a head that is not singing).
var chime_stun_time: float = 0.0
## True: a light enemy the reel line pulls to Tamsin and stuns for 0.8 s (read by the reel tool).
var reel_light: bool = false
## Front guard arc in degrees (a shield). A hit from inside the arc is blocked (spark, 0 damage). 0 = no guard.
## The guard is down while stunned, and flare and explosion hits pierce it.
var armor_front_deg: float = 0.0
## True: the enemy lives in water zones only (fen leech). Movement inside water is the monster's job.
var water_only: bool = false
## True: the enemy ignores deep water (WATER blockers): flyers, leeches and rafts. False: ground enemies stop at it.
var ignore_water: bool = false

var hurtbox: Hurtbox
var contact_hitbox: Hitbox
var visual: Node2D

var _knock_velocity: Vector2 = Vector2.ZERO
var _knock_time: float = 0.0
var _stun_time: float = 0.0
var _iframe_time: float = 0.0
var _flash_time: float = 0.0
var _player: Node2D


## Body layer, mask and motion are set here, not in _init(): a subclass _init() does not run the base
## _init() in Godot 4.7, so the body would stay on the WORLD layer.
func _ready() -> void:
	collision_layer = Layers.ENEMY_BODY
	collision_mask = Layers.WORLD if ignore_water else Layers.WORLD | Layers.WATER
	motion_mode = MOTION_MODE_FLOATING
	add_to_group(&"enemies")
	hp = max_hp
	if get_node_or_null(BODY_NAME) == null:
		var body := CollisionShape2D.new()
		body.name = BODY_NAME
		var circle := CircleShape2D.new()
		circle.radius = body_radius
		body.shape = circle
		add_child(body)
	hurtbox = get_node_or_null(HURTBOX_NAME) as Hurtbox
	if hurtbox == null:
		hurtbox = Hurtbox.new()
		hurtbox.name = HURTBOX_NAME
		hurtbox.team = Layers.Team.ENEMY
		hurtbox.add_circle(body_radius)
		add_child(hurtbox)
	hurtbox.hurt.connect(_on_hurtbox_hurt)
	contact_hitbox = get_node_or_null(CONTACT_NAME) as Hitbox
	if contact_hitbox == null:
		contact_hitbox = Hitbox.new()
		contact_hitbox.name = CONTACT_NAME
		contact_hitbox.team = Layers.Team.ENEMY
		contact_hitbox.kind = &"contact"
		contact_hitbox.once_per_target = false
		contact_hitbox.knockback = 640.0
		contact_hitbox.knockback_time = 0.14
		contact_hitbox.add_circle(body_radius * 0.9)
		add_child(contact_hitbox)
	contact_hitbox.damage = contact_damage
	contact_hitbox.source = self
	contact_hitbox.active = contact_damage > 0
	visual = get_node_or_null(Placeholder.VISUAL_NAME) as Node2D
	if visual == null:
		visual = SpriteVisual.attach(self, visual_kind, body_radius)
	_enemy_ready()


# ---- Virtual hooks (override in subclasses) -------------------------------------------------


## Called once at the end of _ready(). Connect signals, pick the first timer, etc.
func _enemy_ready() -> void:
	pass


## Called every physics frame while the enemy may act (not dead, not stunned, not in knockback).
## Set `velocity`; do not call move_and_slide().
func _enemy_physics(_delta: float) -> void:
	pass


## Called after an accepted hit that did damage, before death is evaluated. `hp` is already reduced.
func _on_hurt(_hitbox: Hitbox) -> void:
	pass


## Called once when hp reaches 0, before the puff, drop roll and queue_free. Spawn children here
## (use get_parent()). `drops_enabled` may be set to false here to suppress loot.
func _on_death() -> void:
	pass


## Called when a stun starts (seconds is the new remaining stun) and when it ends.
func _on_stunned(_seconds: float) -> void:
	pass


func _on_stun_end() -> void:
	pass


## Called with an accepted damaging hit before it is applied. Return the damage to apply; 0 blocks it.
## The default returns `amount` unchanged (the front guard is checked by the base before this hook).
func _resolve_damage(_hitbox: Hitbox, amount: int) -> int:
	return amount


# ---- Public API ------------------------------------------------------------------------------


## Stops movement and attacks for `seconds` (tether moth). Contact damage stays active.
## Longer stuns override shorter ones; they never shorten a running stun.
func stun(seconds: float) -> void:
	if is_dead or seconds <= 0.0:
		return
	var was_stunned := _stun_time > 0.0
	_stun_time = maxf(_stun_time, seconds)
	velocity = Vector2.ZERO
	Audio.play_sfx(&"stun", global_position)
	stunned.emit(_stun_time)
	if not was_stunned:
		_on_stunned(_stun_time)


func is_stunned() -> bool:
	return _stun_time > 0.0


func is_knocked_back() -> bool:
	return _knock_time > 0.0


## Throws the enemy away with the given velocity for `time` seconds.
func apply_knockback(vel: Vector2, time: float) -> void:
	_knock_velocity = vel
	_knock_time = time


## Applies damage without a Hitbox (tests, scripted damage). Returns false if ignored.
func apply_damage(
	amount: int,
	from_pos: Vector2,
	knock_speed: float = HIT_KNOCKBACK_FALLBACK,
	knock_time: float = 0.12
) -> bool:
	if not can_be_hurt():
		return false
	hp -= amount
	damaged.emit(amount)
	_after_hit(from_pos, knock_speed, knock_time)
	return true


func can_be_hurt() -> bool:
	return not is_dead and not invulnerable and _iframe_time <= 0.0


## Contact damage on/off (e.g. while airborne or dying).
func set_contact_enabled(enabled: bool) -> void:
	if contact_hitbox != null:
		contact_hitbox.active = enabled and contact_damage > 0


## The player node, or null in a world without one. Cached; re-resolved if it was freed.
func get_player() -> Node2D:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group(&"player") as Node2D
	return _player


## Player position, or `fallback` when there is no player.
func player_position(fallback: Vector2 = Vector2.ZERO) -> Vector2:
	var p := get_player()
	return p.global_position if p != null else fallback


func direction_to_player() -> Vector2:
	var p := get_player()
	if p == null:
		return Vector2.ZERO
	return (p.global_position - global_position).normalized()


## Adds `child` (an EnemyBase you built) next to this enemy at `at`, sharing the room rect. The child
## enters the tree immediately, so do NOT call this from a physics callback (area/body signals, a
## hit handler): use adopt_deferred() there.
func adopt(child: EnemyBase, at: Vector2) -> EnemyBase:
	child.room_rect = room_rect
	get_parent().add_child(child)
	child.global_position = at
	return child


## Same as adopt(), but the child enters the tree at the end of the frame (call_deferred), which is
## safe inside physics callbacks and `_on_death()`. The child's position is set before it is added;
## it is not in the tree yet when this returns. Returns `child`.
func adopt_deferred(child: EnemyBase, at: Vector2) -> EnemyBase:
	var parent := get_parent()
	if parent == null:
		return child
	child.room_rect = room_rect
	var parent_2d := parent as Node2D
	child.position = parent_2d.to_local(at) if parent_2d != null else at
	parent.call_deferred(&"add_child", child)
	return child


## Sets `facing_dir` and turns the Visual (if it supports it). Pass a non-zero vector.
func set_facing_dir(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		return
	facing_dir = dir.normalized()
	if visual != null and visual.has_method("set_facing"):
		visual.call("set_facing", facing_dir)


## Fires a projectile from this enemy (or from `from`) into the enemy's parent so it is cleaned up
## with the room. `scene` is a PackedScene whose root extends EnemyProjectile, or null for a plain
## EnemyProjectile. speed < 0 / dmg < 0 keep the projectile's own defaults.
func fire_projectile(
	scene: PackedScene,
	dir: Vector2,
	proj_speed: float = -1.0,
	proj_damage: int = -1,
	from: Vector2 = Vector2.INF
) -> EnemyProjectile:
	var projectile: EnemyProjectile = null
	if scene != null:
		projectile = scene.instantiate() as EnemyProjectile
	if projectile == null:
		projectile = EnemyProjectile.new()
	if proj_speed >= 0.0:
		projectile.speed = proj_speed
	if proj_damage >= 0:
		projectile.damage = proj_damage
	projectile.room_rect = room_rect
	Audio.play_sfx(&"spit", global_position)
	get_parent().add_child(projectile)
	projectile.launch(global_position if from == Vector2.INF else from, dir)
	return projectile


func kill() -> void:
	if is_dead:
		return
	hp = 0
	_die()


# ---- Internals -------------------------------------------------------------------------------


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_tick_timers(delta)
	if _knock_time > 0.0:
		velocity = _knock_velocity
		_knock_time -= delta
		move_and_slide()
		hit_wall = get_slide_collision_count() > 0
		_confine()
		return
	if _stun_time > 0.0:
		velocity = Vector2.ZERO
		hit_wall = false
		_stun_time -= delta
		if _stun_time <= 0.0:
			_stun_time = 0.0
			_on_stun_end()
		return
	_enemy_physics(delta)
	move_and_slide()
	hit_wall = get_slide_collision_count() > 0
	_confine()


func _tick_timers(delta: float) -> void:
	if _iframe_time > 0.0:
		_iframe_time -= delta
	hurtbox.invulnerable = invulnerable or _iframe_time > 0.0
	if _flash_time > 0.0:
		_flash_time -= delta
		if _flash_time <= 0.0:
			_set_flash(false)


func _confine() -> void:
	if room_rect.size == Vector2.ZERO:
		return
	var r := room_rect.grow(-body_radius)
	global_position = Vector2(
		clampf(global_position.x, r.position.x, r.end.x),
		clampf(global_position.y, r.position.y, r.end.y)
	)


func _on_hurtbox_hurt(hitbox: Hitbox) -> void:
	if is_dead:
		return
	var amount := hitbox.damage_for(hurtbox)
	if hitbox.stun_time > 0.0:
		stun(hitbox.stun_time * stun_scale)
	if hitbox.kind == &"chime" and chime_stun_time > 0.0:
		stun(chime_stun_time)
	if _guard_blocks(hitbox):
		_spark_guard(hitbox)
		return
	amount = _resolve_damage(hitbox, amount)
	if amount <= 0:
		return
	hp -= amount
	damaged.emit(amount)
	if hitbox.kind == &"hook" or hitbox.kind == &"flare":
		Audio.play_sfx(&"hook_hit", global_position)
	Audio.play_sfx(&"enemy_hurt", global_position)
	_after_hit(hitbox.origin(), hitbox.knockback, hitbox.knockback_time, hitbox)


func _after_hit(
	from_pos: Vector2, knock_speed: float, knock_time: float, hitbox: Hitbox = null
) -> void:
	_iframe_time = IFRAME_TIME
	hurtbox.invulnerable = true
	_flash_time = FLASH_TIME
	_set_flash(true)
	var speed := knock_speed * knockback_scale
	if speed > 0.0 and hp > 0:
		var dir := global_position - from_pos
		if hitbox != null and hitbox.knockback_direction != Vector2.ZERO:
			dir = hitbox.knockback_direction
		if dir.length_squared() < 0.0001:
			dir = Vector2.DOWN
		apply_knockback(dir.normalized() * speed, knock_time)
	_on_hurt(hitbox)
	if hp <= 0:
		_die()


## True when the front guard stops `hitbox`: the guard is up, the enemy is not stunned, the hit is not
## a flare or explosion, and its origin is inside the front arc (armor_front_deg, centred on facing_dir).
func _guard_blocks(hitbox: Hitbox) -> bool:
	if armor_front_deg <= 0.0 or is_stunned():
		return false
	if hitbox.kind == &"flare" or hitbox.kind == &"explosion":
		return false
	var to_attacker := hitbox.origin() - global_position
	if to_attacker.length_squared() < 0.0001:
		return false
	return absf(facing_dir.angle_to(to_attacker)) <= deg_to_rad(armor_front_deg) * 0.5


## A guarded hit: spark, signal, and the attacker is pushed back (enemies only; the player has no
## knockback API).
func _spark_guard(hitbox: Hitbox) -> void:
	guard_blocked.emit(hitbox)
	Audio.play_sfx(&"ward_block", global_position)
	var parent := get_parent()
	if parent != null:
		var spark_at := (
			global_position + (hitbox.origin() - global_position).normalized() * body_radius
		)
		var spark := SpriteVisual.spawn_effect(parent, &"lock_key_volley", spark_at)
		if spark is SpriteVisual and spark.sprite_frames.has_animation(&"impact"):
			# Three impact frames at 8 fps, sped up to the old 0.25 s puff duration.
			spark.z_index = 10
			spark.speed_scale = 1.5
			spark.play_anim(&"impact")
		else:
			if spark != null:
				spark.queue_free()
			Placeholder.puff(parent, spark_at, Color(1.0, 0.95, 0.7, 0.9), 12.0)
	var attacker := hitbox.source
	if is_instance_valid(attacker) and attacker.has_method(&"apply_knockback"):
		var away := attacker.global_position - global_position
		if away.length_squared() < 0.0001:
			away = Vector2.DOWN
		attacker.call(&"apply_knockback", away.normalized() * GUARD_PUSH_SPEED, GUARD_PUSH_TIME)


func _die() -> void:
	if is_dead:
		return
	is_dead = true
	hurtbox.enabled = false
	set_contact_enabled(false)
	_on_death()
	var parent := get_parent()
	if parent != null:
		var effect := &"explosion"
		var effect_scale := 0.3
		var first_frame := 3
		if _uses_regular_death_effect():
			effect = &"fx_enemy_poof_z1"
			effect_scale = 0.8
			first_frame = 0
		if (
			SpriteVisual.spawn_effect(parent, effect, global_position, effect_scale, first_frame)
			== null
		):
			Placeholder.puff(parent, global_position, Placeholder.color_of(visual_kind))
		if drops_enabled:
			var kind := DropTable.roll(drop_roll_override)
			if kind != &"":
				PickupBase.spawn(kind, parent, global_position)
	died.emit(self)
	Events.enemy_died.emit(self, global_position)
	queue_free()


func _set_flash(on: bool) -> void:
	if visual != null:
		visual.modulate = Color(4.0, 4.0, 4.0, 1.0) if on else Color.WHITE


## Bosses and their parts retain their existing death presentation.
func _uses_regular_death_effect() -> bool:
	if is_in_group(&"bosses"):
		return false
	var script := get_script() as Script
	while script != null:
		if script.resource_path == "res://scripts/enemies/boss_part.gd":
			return false
		script = script.get_base_script()
	return true
