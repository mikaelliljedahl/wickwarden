extends "res://scripts/enemies/boss_base.gd"
## Brass plating and a committed, wardable flame jet; the vent opens after firing.

enum State { WALK, TELL, JET, VENT }

var state := State.WALK
var _timer := 0.0
var _cycle := 4.0
var _immunity := 0.0
var _aim := Vector2.RIGHT
var _jet: Hitbox
var _pulse := 0.0
var _fire_art: Texture2D = load("res://assets/sprites/wick_automaton_jet_z1_idle.png") as Texture2D


func _init() -> void:
	max_hp = 30
	contact_damage = 3
	move_speed = 110.0
	body_radius = 32.0
	visual_kind = &"wick_automaton"
	miniboss = true
	drops_enabled = false
	arena_lock = false
	stun_scale = 1.0
	knockback_scale = 0.5
	Placeholder.register_kind(
		visual_kind, {"shape": "circle", "color": Color(0.7, 0.5, 0.2), "radius": 32.0}
	)


func _enter_phase(_number: int) -> void:
	_cancel_jet()
	state = State.WALK
	_cycle = 4.0
	_timer = 0.0
	_immunity = 0.0


func reset_fight() -> void:
	if is_dying():
		return
	_cancel_jet()
	super()
	if not is_dead:
		_enter_phase(1)


func _boss_physics(delta: float) -> void:
	velocity = Vector2.ZERO
	_timer -= delta
	_cycle -= delta
	match state:
		State.WALK:
			set_facing_dir(direction_to_player())
			velocity = facing_dir * move_speed if get_player() != null else Vector2.ZERO
			if _cycle <= 0.0:
				state = State.TELL
				_timer = 0.6
				_cycle = 4.0
				_aim = facing_dir
		State.TELL:
			if _timer <= 0.0:
				state = State.JET
				_timer = 0.8
				_pulse = 0.0
		State.JET:
			_pulse -= delta
			if _timer <= 0.0:
				_cancel_jet()
				state = State.VENT
				_timer = 1.5
			elif _pulse <= 0.0:
				_cancel_jet()
				_jet = Hitbox.new()
				_jet.team = Layers.Team.ENEMY
				_jet.damage = 1
				_jet.kind = &"fire"
				_jet.source = self
				_jet.blockable = true
				_jet.block_destroys_carrier = false
				_jet.rotation = _aim.angle()
				var shape := CollisionShape2D.new()
				var rectangle := RectangleShape2D.new()
				rectangle.size = Vector2(192, 64)
				shape.shape = rectangle
				shape.position.x = 96
				_jet.add_child(shape)
				add_child(_jet)
				_jet.activate()
				_pulse = 0.3
		State.VENT:
			if _timer <= 0.0:
				state = State.WALK
	queue_redraw()


func _cancel_jet() -> void:
	if is_instance_valid(_jet):
		_jet.deactivate()
		_jet.queue_free()
	_jet = null


func _resolve_damage(hitbox: Hitbox, amount: int) -> int:
	match hitbox.kind:
		&"hook":
			return 2 if state == State.VENT or is_stunned() else 1
		&"flare":
			return 2
		&"explosion":
			return 4
	return amount


func stun(seconds: float) -> void:
	if _immunity > 0.0 or is_stunned() or is_dying():
		return
	super.stun(minf(seconds, 1.5))


func _on_stunned(_seconds: float) -> void:
	_cancel_jet()
	state = State.VENT
	_timer = 1.5
	set_contact_enabled(false)


func _on_stun_end() -> void:
	state = State.WALK
	_timer = 0.0
	_immunity = 3.0
	set_contact_enabled(not is_dying())


func _tick_timers(delta: float) -> void:
	super(delta)
	_immunity = maxf(0.0, _immunity - delta)


func _on_hurt(hitbox: Hitbox) -> void:
	super(hitbox)
	if is_dying():
		_cancel_jet()
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
		draw_line(Vector2.ZERO, _aim * 192, Color(1, 0.45, 0.1, 0.5), 64.0)
	elif state == State.JET:
		draw_set_transform(Vector2.ZERO, _aim.angle())
		draw_rect(Rect2(0, -32, 192, 64), Color(1, 0.5, 0.12, 0.8), false, 2.0)
		if _fire_art != null:
			draw_texture_rect(_fire_art, Rect2(0, -32, 192, 64), false)
		else:
			draw_rect(Rect2(0, -32, 192, 64), Color(1, 0.45, 0.1, 0.5))
		draw_set_transform(Vector2.ZERO)
	elif state == State.VENT or is_stunned():
		draw_arc(Vector2.ZERO, 38, 0, TAU, 24, Color(1, 0.75, 0.25), 5)
