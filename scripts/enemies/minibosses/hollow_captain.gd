extends "res://scripts/enemies/boss_base.gd"
## C1 Hollow Captain: limited turning, front guard and a committed shield bash.

const KIND := &"hollow_captain"
const INTERVAL := 4.0
const WARNING := 0.5
const DASH_TIME := 0.4
const RECOVERY := 1.0
const TURN_SPEED := 100.0
const DASH_SPEED := 300.0

enum State { PATROL, TELEGRAPH, BASH, RECOVER }

var state: State = State.PATROL
var _timer := INTERVAL
var _cycle := INTERVAL
var _aim := Vector2.DOWN
var _stun_immunity := 0.0


func _init() -> void:
	max_hp = 12
	contact_damage = 2
	move_speed = 120.0
	body_radius = 30.0
	visual_kind = KIND
	miniboss = true
	arena_lock = false
	drops_enabled = false
	stun_scale = 1.0
	knockback_scale = 0.5
	armor_front_deg = 140.0
	Placeholder.register_kind(
		KIND, {"shape": "circle", "color": Color(0.65, 0.58, 0.36), "radius": 30.0}
	)


func _enter_phase(_number: int) -> void:
	state = State.PATROL
	_cycle = INTERVAL
	_timer = INTERVAL
	armor_front_deg = 140.0
	_stun_immunity = 0.0
	_aim = Vector2.DOWN
	_restore_contact()


func reset_fight() -> void:
	if is_dead or is_dying() or is_defeated():
		return
	super.reset_fight()
	_enter_phase(1)


func _boss_physics(delta: float) -> void:
	_cycle -= delta
	_timer -= delta
	velocity = Vector2.ZERO
	if state == State.PATROL or state == State.TELEGRAPH:
		var target := direction_to_player()
		if target != Vector2.ZERO:
			var turn := deg_to_rad(TURN_SPEED) * delta
			set_facing_dir(facing_dir.rotated(clampf(facing_dir.angle_to(target), -turn, turn)))
	match state:
		State.PATROL:
			velocity = facing_dir * move_speed if get_player() != null else Vector2.ZERO
			if _cycle <= 0.0:
				state = State.TELEGRAPH
				_timer = WARNING
				_cycle = INTERVAL
		State.TELEGRAPH:
			if _timer <= 0.0:
				state = State.BASH
				_timer = DASH_TIME
				_aim = facing_dir
				contact_hitbox.damage = 3
				contact_hitbox.activate()
		State.BASH:
			velocity = _aim * DASH_SPEED
			if _timer <= 0.0:
				state = State.RECOVER
				_timer = RECOVERY
				armor_front_deg = 0.0
				velocity = Vector2.ZERO
				_restore_contact()
		State.RECOVER:
			if _timer <= 0.0:
				state = State.PATROL
				armor_front_deg = 140.0
	queue_redraw()


func _on_stunned(_seconds: float) -> void:
	state = State.RECOVER
	_timer = RECOVERY
	armor_front_deg = 0.0
	_restore_contact()
	queue_redraw()


func _restore_contact() -> void:
	if contact_hitbox != null:
		contact_hitbox.damage = contact_damage


func _draw() -> void:
	if is_dead or is_dying():
		return
	if armor_front_deg > 0.0 and not is_stunned():
		var angle := facing_dir.angle()
		draw_arc(
			Vector2.ZERO,
			40.0,
			angle - deg_to_rad(70),
			angle + deg_to_rad(70),
			24,
			Color(0.95, 0.82, 0.4),
			7.0
		)
	if state == State.TELEGRAPH:
		draw_line(Vector2.ZERO, facing_dir * DASH_SPEED * DASH_TIME, Color(1, 0.5, 0.15, 0.8), 10.0)


func stun(seconds: float) -> void:
	if _stun_immunity > 0.0 or is_stunned() or is_dying():
		return
	super.stun(minf(seconds, 1.5))


func _tick_timers(delta: float) -> void:
	super(delta)
	_stun_immunity = maxf(0.0, _stun_immunity - delta)


func _on_stun_end() -> void:
	_stun_immunity = 3.0
	state = State.PATROL
	armor_front_deg = 140.0
	queue_redraw()


func _on_hurt(hitbox: Hitbox) -> void:
	super(hitbox)
	if is_dying():
		set_contact_enabled(false)


func _on_death() -> void:
	super()
	for kind: StringName in [&"ember", &"ember", &"brass_coin", &"brass_coin"]:
		PickupBase.spawn(kind, get_parent(), global_position, true)
