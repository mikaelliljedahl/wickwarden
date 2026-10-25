extends "res://scripts/enemies/boss_base.gd"
## Corrow's remembered combo, retreat and chime-interruptible flare.


class WaxHook:
	extends EnemyProjectile
	var origin := Vector2.ZERO
	var returning := false

	func _projectile_physics(_delta: float) -> void:
		if not returning and global_position.distance_to(origin) >= 480.0:
			returning = true
			direction = -direction
		if returning and global_position.distance_to(origin) < 12.0:
			destroy(&"range")


enum State { APPROACH, TELL, COMBO, RETREAT, GLOW, FLARE, RECOVER }

var state := State.APPROACH
var _timer := 0.0
var _aim := Vector2.RIGHT
var _retreat_left := 0.0
var _swings := 0
var _attack: Hitbox
var _attack_left := 0.0
var _immunity := 0.0
var _hook: EnemyProjectile


func _init() -> void:
	max_hp = 36
	contact_damage = 4
	move_speed = 200.0
	body_radius = 30.0
	visual_kind = &"corrows_echo"
	miniboss = true
	drops_enabled = false
	arena_lock = false
	stun_scale = 1.0
	knockback_scale = 0.5
	Placeholder.register_kind(
		visual_kind, {"shape": "circle", "color": Color(0.65, 0.65, 0.8), "radius": 30.0}
	)
	Placeholder.register_kind(
		&"wax_hook", {"shape": "circle", "color": Color(0.8, 0.75, 0.6), "radius": 16.0}
	)


func _enter_phase(_number: int) -> void:
	_cancel_attack()
	state = State.APPROACH
	_timer = 0.0
	_immunity = 0.0
	chime_stun_time = 0.0


func reset_fight() -> void:
	if is_dying():
		return
	_cancel_attack()
	if is_instance_valid(_hook):
		_hook.destroy(&"range")
	_hook = null
	super()
	if not is_dead:
		_enter_phase(1)


func _boss_physics(delta: float) -> void:
	velocity = Vector2.ZERO
	_timer -= delta
	_attack_left -= delta
	if _attack_left <= 0.0:
		_cancel_attack()
	match state:
		State.APPROACH:
			set_facing_dir(direction_to_player())
			velocity = facing_dir * move_speed if get_player() != null else Vector2.ZERO
			if get_player() != null and player_position().distance_to(global_position) <= 150.0:
				state = State.TELL
				_timer = 0.5
				_aim = facing_dir
		State.TELL:
			if _timer <= 0.0:
				state = State.COMBO
				_swings = 1
				_timer = 0.4
				_strike(150, 110, 3)
		State.COMBO:
			if _timer <= 0.0:
				if _swings == 1:
					_strike(150, 110, 3)
					_swings = 2
					_timer = 0.4
				else:
					state = State.RETREAT
					_retreat_left = 192.0
		State.RETREAT:
			var step := minf(move_speed * delta, _retreat_left)
			velocity = -_aim * step / delta
			_retreat_left -= step
			if _retreat_left <= 0.0:
				state = State.GLOW
				_timer = 0.8
				chime_stun_time = 2.0
		State.GLOW:
			if _timer <= 0.0:
				chime_stun_time = 0.0
				_strike(170, 360, 4)
				state = State.FLARE
				_timer = 0.2
		State.FLARE:
			if _timer <= 0.0:
				if hp < 18:
					_throw_hook()
				state = State.RECOVER
				_timer = 0.5
		State.RECOVER:
			if _timer <= 0.0:
				state = State.APPROACH
	queue_redraw()


func _strike(reach: float, arc: float, damage: int) -> void:
	_cancel_attack()
	_attack = Hitbox.new()
	_attack.team = Layers.Team.ENEMY
	_attack.source = self
	_attack.damage = damage
	_attack.kind = &"wax_flare" if arc == 360 else &"wax_hook"
	_attack.blockable = false
	_attack.rotation = _aim.angle()
	var polygon := CollisionPolygon2D.new()
	var points := PackedVector2Array([Vector2.ZERO])
	for i in range(33):
		points.append(Vector2.from_angle(deg_to_rad(-arc * 0.5 + arc * i / 32.0)) * reach)
	polygon.polygon = points
	_attack.add_child(polygon)
	add_child(_attack)
	_attack.activate()
	_attack_left = 0.12


func _throw_hook() -> void:
	if is_instance_valid(_hook):
		return
	var hook := WaxHook.new()
	hook.speed = 600.0
	hook.damage = 2
	hook.visual_kind = &"wax_hook"
	hook.origin = global_position
	hook.lifetime = 2.0
	get_parent().add_child(hook)
	hook.launch(global_position, direction_to_player())
	_hook = hook
	add_hazard(hook)


func clear_hazards() -> void:
	if is_instance_valid(_hook):
		_hook.destroy(&"range")
	_hook = null
	super()


func _cancel_attack() -> void:
	if is_instance_valid(_attack):
		_attack.deactivate()
		_attack.queue_free()
	_attack = null


func stun(seconds: float) -> void:
	if _immunity > 0.0 or is_stunned() or is_dying():
		return
	# Chime is enabled only in the glow. Moth never exceeds one second.
	super.stun(2.0 if chime_stun_time > 0.0 and seconds == 2.0 else minf(seconds, 1.0))


func _on_stunned(_seconds: float) -> void:
	_cancel_attack()
	chime_stun_time = 0.0
	state = State.RECOVER
	_timer = 0.5
	set_contact_enabled(false)


func _on_stun_end() -> void:
	_immunity = 3.0
	set_contact_enabled(not is_dying())


func _tick_timers(delta: float) -> void:
	super(delta)
	_immunity = maxf(0.0, _immunity - delta)


func _on_hurt(hitbox: Hitbox) -> void:
	super(hitbox)
	if is_dying():
		_cancel_attack()
		chime_stun_time = 0.0
		_stun_time = 0.0
		_knock_time = 0.0
		set_contact_enabled(false)


func _on_death() -> void:
	super()
	for kind: StringName in [&"ember", &"ember", &"brass_coin", &"brass_coin"]:
		PickupBase.spawn(kind, get_parent(), global_position, true)


func _draw() -> void:
	if is_dead or is_dying():
		return
	if state == State.TELL:
		draw_arc(
			Vector2.ZERO,
			150,
			_aim.angle() - deg_to_rad(55),
			_aim.angle() + deg_to_rad(55),
			24,
			Color(1, 0.7, 0.3),
			4
		)
	elif state == State.GLOW or state == State.FLARE:
		draw_arc(Vector2.ZERO, 170, 0, TAU, 48, Color(1, 0.8, 0.35, 0.6), 7)
