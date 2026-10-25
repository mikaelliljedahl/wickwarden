extends "res://scripts/enemies/boss_base.gd"
## C7: moth at the pit edge, rather than the boots found after this encounter.

const KIND := &"pale_squire"
const WARNING := 0.4  # This specific row overrides the generic miniboss minimum.
const LUNGE_SPEED := 520.0
const LUNGE_TIME := 0.6
const RECOVERY := 0.8
const FALL_DAMAGE := 6
const FALL_TIME := 3.0
const APPROACH := 1.5  # The row leaves attack cadence unspecified.

enum State { WALK, TELEGRAPH, LUNGE, RECOVER, FALLEN }

var state: State = State.WALK
var _timer := APPROACH
var _aim := Vector2.RIGHT
var _stun_immunity := 0.0
var _entry := Vector2.ZERO


func _init() -> void:
	max_hp = 16
	contact_damage = 2
	move_speed = 160.0
	body_radius = 30.0
	visual_kind = KIND
	miniboss = true
	arena_lock = false
	drops_enabled = false
	stun_scale = 1.0
	knockback_scale = 0.5
	Placeholder.register_kind(
		KIND, {"shape": "circle", "color": Color(0.85, 0.86, 0.81), "radius": 30.0}
	)


func _enter_phase(_number: int) -> void:
	state = State.WALK
	_timer = APPROACH
	_stun_immunity = 0.0
	var room := _room()
	_entry = room.get_spawn_position() if room != null else global_position
	_set_present(true)


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
			if _over_pit(global_position + velocity * delta, body_radius):
				velocity = Vector2.ZERO
			if _timer <= 0.0:
				state = State.TELEGRAPH
				_timer = WARNING
				_aim = facing_dir
				velocity = Vector2.ZERO
		State.TELEGRAPH:
			if _timer <= 0.0:
				state = State.LUNGE
				_timer = LUNGE_TIME
		State.LUNGE:
			# Only the committed lunge crosses the pit. It deals the specified contact stab.
			var active_step := minf(delta, maxf(0.0, _timer + delta))
			velocity = _aim * LUNGE_SPEED * active_step / delta
			if _timer <= 0.0:
				state = State.RECOVER
				_timer = RECOVERY
		State.RECOVER:
			if _timer <= 0.0:
				state = State.WALK
				_timer = APPROACH
		State.FALLEN:
			if _timer <= 0.0:
				global_position = _entry
				state = State.RECOVER
				_timer = RECOVERY
				_set_present(true)
	queue_redraw()


func _over_pit(at: Vector2, margin := 0.0) -> bool:
	var scope: Node = _room()
	if scope == null:
		scope = get_parent()
	for pit in get_tree().get_nodes_in_group(&"pit_zone"):
		if scope.is_ancestor_of(pit):
			var footprint := Rect2(pit.global_position - pit.size * 0.5, pit.size)
			if footprint.grow(margin).has_point(at):
				return true
	return false


func _fall() -> void:
	if state == State.FALLEN or is_dying():
		return
	state = State.FALLEN
	_timer = FALL_TIME
	_stun_time = 0.0
	_knock_time = 0.0
	_stun_immunity = 3.0
	velocity = Vector2.ZERO
	# Environmental fall damage is additional to the triggering hit and bypasses its i-frame.
	_iframe_time = 0.0
	invulnerable = false
	apply_damage(FALL_DAMAGE, global_position, 0.0)
	if not is_dying():
		_set_present(false)
	queue_redraw()


func _set_present(present: bool) -> void:
	invulnerable = not present
	hurtbox.enabled = present
	hurtbox.invulnerable = not present
	set_contact_enabled(present)
	var body := get_node_or_null(BODY_NAME) as CollisionShape2D
	if body != null:
		body.set_deferred(&"disabled", not present)
	if visual != null:
		visual.visible = present


func stun(seconds: float) -> void:
	if _stun_immunity > 0.0 or is_stunned() or is_dying() or state == State.FALLEN:
		return
	super.stun(minf(seconds, 1.5))


func _on_stunned(_seconds: float) -> void:
	if _over_pit(global_position):
		_fall()
	else:
		state = State.RECOVER
		_timer = RECOVERY
		set_contact_enabled(false)


func _on_stun_end() -> void:
	_stun_immunity = 3.0
	set_contact_enabled(not is_dying() and state != State.FALLEN)


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
	elif state != State.FALLEN and _over_pit(global_position):
		_fall()


func _on_death() -> void:
	super()
	for kind: StringName in [&"ember", &"ember", &"brass_coin", &"brass_coin"]:
		PickupBase.spawn(kind, get_parent(), global_position, true)


func _draw() -> void:
	if is_dead or is_dying() or state == State.FALLEN:
		return
	if state == State.TELEGRAPH:
		draw_line(Vector2.ZERO, _aim * LUNGE_SPEED * LUNGE_TIME, Color(1, 0.85, 0.5), 8.0)
