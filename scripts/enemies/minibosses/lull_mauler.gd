extends "res://scripts/enemies/boss_base.gd"
## C4 miniboss: smash debris can be returned with the base hook before the mitts are found.

const KIND := &"lull_mauler"
const SMASH_WARNING := 0.9
const SWEEP_WARNING := 0.6
const RECOVERY := 1.2
# Attack cadence is not fixed by the row: alternate smash and sweep with a short approach.
const APPROACH_TIME := 1.5

enum State { WALK, SMASH_WARNING, SWEEP_WARNING, RECOVER }

var state: State = State.WALK
var _timer := APPROACH_TIME
var _smash_next := true
var _stun_immunity := 0.0
var _aim := Vector2.DOWN
var _impact := Vector2.ZERO
var _attack: Hitbox
var _attack_left := 0.0
var _smash_art: Texture2D


class SweepWarning:
	extends Node2D

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		var mauler = get_parent()
		if mauler.is_dead or mauler.is_dying():
			return
		var aim: Vector2 = mauler._aim
		var edge := Color(1.0, 0.6, 0.2, 0.7)
		if mauler.state == State.SWEEP_WARNING:
			draw_arc(Vector2.ZERO, 140.0, aim.angle() - PI / 2, aim.angle() + PI / 2, 32, edge, 3.0)
			draw_line(Vector2.ZERO, aim.rotated(-PI / 2) * 140.0, edge, 3.0)
			draw_line(Vector2.ZERO, aim.rotated(PI / 2) * 140.0, edge, 3.0)
		elif is_instance_valid(mauler._attack) and mauler._attack.active:
			if mauler._attack.kind == &"slam":
				var centre: Vector2 = mauler._impact - mauler.global_position
				if mauler._smash_art != null:
					draw_texture_rect(
						mauler._smash_art, Rect2(centre - Vector2(110, 110), Vector2(220, 220)), false
					)
				draw_arc(centre, 110.0, 0.0, TAU, 48, edge, 3.0)
			else:
				var start := aim.angle() - PI / 2
				var finish := aim.angle() + PI / 2
				draw_arc(Vector2.ZERO, 126.0, start, finish, 32, Color(0.75, 0.55, 0.35, 0.45), 24.0)
				draw_arc(Vector2.ZERO, 126.0, start, finish, 32, Color(1, 0.82, 0.55, 0.8), 7.0)
				draw_arc(Vector2.ZERO, 140.0, start, finish, 32, edge, 3.0)
				draw_line(Vector2.ZERO, aim.rotated(-PI / 2) * 140.0, edge, 3.0)
				draw_line(Vector2.ZERO, aim.rotated(PI / 2) * 140.0, edge, 3.0)


class SlagChunk:
	extends "res://scripts/world/liftable.gd"
	## Keep this encounter-only helper within MB2 ownership; P06 still supplies mitts handling.
	var deflected := false

	func _body_shape() -> Shape2D:
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(96, 96)
		return rectangle

	func _on_ready() -> void:
		_hurtbox.hurt.connect(_on_struck)
		_hitbox.hit_landed.connect(_on_landed_hit)

	func _accepts_grab(hitbox: Hitbox) -> bool:
		return state == State.LYING and hitbox.kind in [&"grab", &"hook"]

	func _on_struck(hitbox: Hitbox) -> void:
		if hitbox.kind != &"hook" or state != State.LYING:
			return
		var heading := (global_position - hitbox.origin()).normalized()
		lift(self)
		deflected = true
		_hitbox.damage = 4
		throw(heading)

	func _fly(delta: float) -> void:
		if not deflected:
			super(delta)
			return
		var step := minf(400.0 * delta, _fly_left)
		_fly_left -= step
		if move_and_collide(_fly_dir * step) != null or _fly_left <= 0.0:
			_land()

	func _on_landed_hit(_victim: Hurtbox) -> void:
		if state == State.FLYING:
			_land()


func _init() -> void:
	max_hp = 24
	contact_damage = 3
	move_speed = 70.0
	body_radius = 40.0
	visual_kind = KIND
	drops_enabled = false
	miniboss = true
	arena_lock = false
	stun_scale = 1.0
	knockback_scale = 0.5
	Placeholder.register_kind(
		KIND, {"shape": "circle", "color": Color(0.5, 0.42, 0.36), "radius": 40.0}
	)
	Placeholder.register_kind(
		&"mauler_slag_chunk",
		{"shape": "rect", "color": Color(0.35, 0.3, 0.26), "size": Vector2(96, 96)},
		true
	)


func _boss_ready() -> void:
	var path := "res://assets/sprites/colossus_quake_z1_idle.png"
	if ResourceLoader.exists(path):
		_smash_art = load(path) as Texture2D
	if get_node_or_null("SweepWarning") == null:
		var warning := SweepWarning.new()
		warning.name = "SweepWarning"
		var material := CanvasItemMaterial.new()
		material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		warning.material = material
		add_child(warning)


func _enter_phase(_number: int) -> void:
	state = State.WALK
	_timer = APPROACH_TIME
	_smash_next = true
	_stun_immunity = 0.0
	_attack_left = 0.0
	if is_instance_valid(_attack):
		_attack.deactivate()


func _boss_physics(delta: float) -> void:
	velocity = Vector2.ZERO
	_timer -= delta
	if _attack_left > 0.0:
		_attack_left -= delta
		if _attack_left <= 0.0 and is_instance_valid(_attack):
			_attack.deactivate()
	match state:
		State.WALK:
			set_facing_dir(direction_to_player())
			velocity = facing_dir * move_speed
			if _timer <= 0.0:
				_aim = facing_dir
				_impact = global_position + _aim * 96.0
				state = State.SMASH_WARNING if _smash_next else State.SWEEP_WARNING
				_timer = SMASH_WARNING if _smash_next else SWEEP_WARNING
				velocity = Vector2.ZERO
		State.SMASH_WARNING, State.SWEEP_WARNING:
			if _timer <= 0.0:
				_strike(state == State.SMASH_WARNING)
				_smash_next = not _smash_next
				state = State.RECOVER
				_timer = RECOVERY
		State.RECOVER:
			if _timer <= 0.0:
				state = State.WALK
				_timer = APPROACH_TIME
	queue_redraw()


func _strike(smash: bool) -> void:
	if is_instance_valid(_attack):
		_attack.queue_free()
	_attack = Hitbox.new()
	_attack.team = Layers.Team.ENEMY
	_attack.source = self
	_attack.kind = &"slam" if smash else &"sweep"
	_attack.damage = 4 if smash else 3
	if smash:
		_attack.add_circle(110.0, _impact - global_position)
		var chunk := SlagChunk.new()
		chunk.look = &"mauler_slag_chunk"
		chunk.radius = 48.0
		get_parent().add_child(chunk)
		chunk.global_position = _impact
		add_hazard(chunk)
	else:
		var polygon := CollisionPolygon2D.new()
		var points := PackedVector2Array([Vector2.ZERO])
		for i in range(17):
			points.append(Vector2.from_angle(_aim.angle() - PI / 2 + PI * i / 16.0) * 140.0)
		polygon.polygon = points
		_attack.add_child(polygon)
	add_child(_attack)
	_attack.activate()
	_attack_left = 0.12


func stun(seconds: float) -> void:
	if _stun_immunity > 0.0 or is_stunned() or is_dying():
		return
	super.stun(minf(seconds, 1.5))


func _on_stunned(_seconds: float) -> void:
	state = State.RECOVER
	_timer = RECOVERY
	if is_instance_valid(_attack):
		_attack.deactivate()
	_attack_left = 0.0
	set_contact_enabled(false)


func _on_stun_end() -> void:
	_stun_immunity = 3.0
	set_contact_enabled(true)


func _tick_timers(delta: float) -> void:
	super(delta)
	_stun_immunity = maxf(0.0, _stun_immunity - delta)


func _on_hurt(hitbox: Hitbox) -> void:
	super(hitbox)
	if is_dying():
		_stun_time = 0.0
		_knock_time = 0.0
		velocity = Vector2.ZERO
		set_contact_enabled(false)
		if is_instance_valid(_attack):
			_attack.deactivate()


func _on_death() -> void:
	super()
	for kind: StringName in [&"ember", &"ember", &"brass_coin", &"brass_coin"]:
		PickupBase.spawn(kind, get_parent(), global_position, true)


func _draw() -> void:
	if is_dead or is_dying():
		return
	if state == State.SMASH_WARNING:
		var centre := _impact - global_position
		if _smash_art != null:
			draw_texture_rect(
				_smash_art, Rect2(centre - Vector2(96, 96), Vector2(192, 192)), false,
				Color(1, 1, 1, 0.65)
			)
		else:
			draw_circle(centre, 110.0, Color(0.15, 0.08, 0.04, 0.65))
		draw_arc(centre, 110.0, 0.0, TAU, 48, Color(1, 0.6, 0.2), 3.0)
