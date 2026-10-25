extends "res://scripts/enemies/boss_base.gd"
## C8 pre-reel answer: a pitch pot or charge flare shatters the four-HP front rail.

const KIND := &"abacus_brute"
const RAIL_HP := 4
const WARNING := 0.7
const WHIRL_TIME := 1.2
const WHIRL_RADIUS := 192.0
const APPROACH := 2.0  # The row does not prescribe an attack interval.

enum State { WALK, TELEGRAPH, WHIRL }

var state: State = State.WALK
var rail_hp := RAIL_HP
var _timer := APPROACH
var _stun_immunity := 0.0
var _whirl: Hitbox


func _init() -> void:
	max_hp = 28
	contact_damage = 3
	move_speed = 90.0
	body_radius = 40.0
	visual_kind = KIND
	miniboss = true
	arena_lock = false
	drops_enabled = false
	stun_scale = 1.0
	knockback_scale = 0.5
	armor_front_deg = 140.0
	Placeholder.register_kind(
		KIND, {"shape": "circle", "color": Color(0.65, 0.52, 0.35), "radius": 40.0}
	)


func _enter_phase(_number: int) -> void:
	state = State.WALK
	_timer = APPROACH
	rail_hp = RAIL_HP
	armor_front_deg = 140.0
	move_speed = 90.0
	_stun_immunity = 0.0
	_cancel_whirl()


func reset_fight() -> void:
	super()
	if not is_dead:
		_enter_phase(1)


func _boss_physics(delta: float) -> void:
	velocity = Vector2.ZERO
	_timer -= delta
	match state:
		State.WALK:
			var direction := direction_to_player()
			set_facing_dir(direction)
			velocity = direction * move_speed
			if _timer <= 0.0:
				state = State.TELEGRAPH
				_timer = WARNING
				velocity = Vector2.ZERO
		State.TELEGRAPH:
			if _timer <= 0.0:
				_start_whirl()
		State.WHIRL:
			if _timer <= 0.0:
				_cancel_whirl()
				state = State.WALK
				_timer = APPROACH
	queue_redraw()


func _start_whirl() -> void:
	_cancel_whirl()
	state = State.WHIRL
	_timer = WHIRL_TIME
	_whirl = Hitbox.new()
	_whirl.team = Layers.Team.ENEMY
	_whirl.kind = &"chain_whirl"
	_whirl.damage = 3
	_whirl.source = self
	_whirl.add_circle(WHIRL_RADIUS)
	add_child(_whirl)
	_whirl.activate()


func _cancel_whirl() -> void:
	if is_instance_valid(_whirl):
		_whirl.deactivate()
		_whirl.queue_free()
	_whirl = null


func _resolve_damage(hitbox: Hitbox, amount: int) -> int:
	if rail_hp > 0 and hitbox.kind in [&"flare", &"explosion"]:
		var offset := hitbox.origin() - global_position
		if offset.is_zero_approx() or absf(facing_dir.angle_to(offset)) <= deg_to_rad(70.0):
			rail_hp = maxi(0, rail_hp - amount)
			if rail_hp == 0:
				armor_front_deg = 0.0
				move_speed = 130.0
			queue_redraw()
			# The qualifying front hit is absorbed by the rail, without body-damage spill.
			return 0
	return amount


func stun(seconds: float) -> void:
	if _stun_immunity > 0.0 or is_stunned() or is_dying():
		return
	super.stun(minf(seconds, 1.5))


func _on_stunned(_seconds: float) -> void:
	_cancel_whirl()
	state = State.WALK
	_timer = APPROACH
	set_contact_enabled(false)


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
		_cancel_whirl()
		set_contact_enabled(false)


func _on_death() -> void:
	super()
	for kind: StringName in [&"ember", &"ember", &"brass_coin", &"brass_coin"]:
		PickupBase.spawn(kind, get_parent(), global_position, true)


func _draw() -> void:
	if is_dead or is_dying():
		return
	if rail_hp > 0 and not is_stunned():
		draw_arc(
			Vector2.ZERO,
			52.0,
			facing_dir.angle() - deg_to_rad(70.0),
			facing_dir.angle() + deg_to_rad(70.0),
			28,
			Color(0.9, 0.8, 0.5),
			8.0
		)
	if state == State.TELEGRAPH or state == State.WHIRL:
		var color := Color(1, 0.65, 0.25, 0.8)
		draw_arc(Vector2.ZERO, WHIRL_RADIUS, 0, TAU, 64, color, 5.0)
