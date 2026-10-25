extends "res://scripts/enemies/boss_base.gd"
## C6 singer: ward the sustained area note or sidestep, then strike the closed mouth.

const KIND := &"choir_warden"
const INTERVAL := 5.0
const WARNING := 0.8
const SING_TIME := 1.5
const RECOVERY := 1.4
const CONE_REACH := 480.0
const CONE_ANGLE := 90.0

enum State { WALK, TELEGRAPH, SING, RECOVER }

var state: State = State.WALK
var _timer := 0.0
var _cycle := INTERVAL
var _stun_immunity := 0.0
var _aim := Vector2.RIGHT
var _cone: Hitbox


func _init() -> void:
	max_hp = 20
	contact_damage = 2
	move_speed = 100.0
	body_radius = 30.0
	visual_kind = KIND
	miniboss = true
	arena_lock = false
	drops_enabled = false
	stun_scale = 1.0
	knockback_scale = 0.5
	Placeholder.register_kind(
		KIND, {"shape": "circle", "color": Color(0.6, 0.54, 0.76), "radius": 30.0}
	)


func _enter_phase(_number: int) -> void:
	state = State.WALK
	_timer = 0.0
	_cycle = INTERVAL
	_stun_immunity = 0.0
	_cancel_note()


func reset_fight() -> void:
	super()
	if not is_dead:
		_enter_phase(1)


func _boss_physics(delta: float) -> void:
	velocity = Vector2.ZERO
	_timer -= delta
	_cycle -= delta
	match state:
		State.WALK:
			var direction := direction_to_player()
			set_facing_dir(direction)
			velocity = direction * move_speed
			if _cycle <= 0.0:
				state = State.TELEGRAPH
				_timer = WARNING
				_cycle = INTERVAL
				_aim = facing_dir
				velocity = Vector2.ZERO
		State.TELEGRAPH:
			if _timer <= 0.0:
				_start_note()
		State.SING:
			if _timer <= 0.0:
				_cancel_note()
				state = State.RECOVER
				_timer = RECOVERY
		State.RECOVER:
			if _timer <= 0.0:
				state = State.WALK
	queue_redraw()


func _start_note() -> void:
	_cancel_note()
	state = State.SING
	_timer = SING_TIME
	_cone = Hitbox.new()
	_cone.team = Layers.Team.ENEMY
	_cone.damage = 2
	_cone.kind = &"song"
	_cone.source = self
	_cone.blockable = true
	_cone.block_destroys_carrier = false
	_cone.once_per_target = true
	_cone.rotation = _aim.angle()
	var polygon := CollisionPolygon2D.new()
	var points := PackedVector2Array([Vector2.ZERO])
	for i in range(17):
		points.append(Vector2.from_angle(deg_to_rad(-45.0 + 90.0 * i / 16.0)) * CONE_REACH)
	polygon.polygon = points
	_cone.add_child(polygon)
	add_child(_cone)
	_cone.activate()


func _cancel_note() -> void:
	if is_instance_valid(_cone):
		_cone.deactivate()
		_cone.queue_free()
	_cone = null


func _resolve_damage(_hitbox: Hitbox, amount: int) -> int:
	# The specified 1.4-second closed-mouth recovery is the normal opening; moth opens it too.
	return amount if state == State.RECOVER or is_stunned() else 0


func stun(seconds: float) -> void:
	if _stun_immunity > 0.0 or is_stunned() or is_dying():
		return
	super.stun(minf(seconds, 1.5))


func _on_stunned(_seconds: float) -> void:
	_cancel_note()
	state = State.RECOVER
	_timer = RECOVERY
	set_contact_enabled(false)
	queue_redraw()


func _on_stun_end() -> void:
	_stun_immunity = 3.0
	set_contact_enabled(not is_dying())


func _tick_timers(delta: float) -> void:
	super(delta)
	_stun_immunity = maxf(0.0, _stun_immunity - delta)


func _on_hurt(hitbox: Hitbox) -> void:
	super(hitbox)
	if is_dying():
		_stun_time = 0.0
		_knock_time = 0.0
		velocity = Vector2.ZERO
		_cancel_note()
		set_contact_enabled(false)


func _on_death() -> void:
	super()
	for kind: StringName in [&"ember", &"ember", &"brass_coin", &"brass_coin"]:
		PickupBase.spawn(kind, get_parent(), global_position, true)


func _draw() -> void:
	if is_dead or is_dying():
		return
	if state == State.TELEGRAPH or state == State.SING:
		var alpha := 0.8 if state == State.TELEGRAPH else 0.4
		var points := PackedVector2Array([Vector2.ZERO])
		for i in range(17):
			points.append(
				Vector2.from_angle(_aim.angle() + deg_to_rad(-45.0 + 90.0 * i / 16.0)) * CONE_REACH
			)
		draw_colored_polygon(points, Color(0.7, 0.65, 1.0, alpha * 0.25))
		draw_polyline(points, Color(0.85, 0.8, 1.0, alpha), 4.0)
	elif state == State.RECOVER:
		draw_line(Vector2(-16, -10), Vector2(16, -10), Color(0.9, 0.85, 1), 5.0)
