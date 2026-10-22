extends EnemyBase
## Skitterwick (plan section 6): a hopping spider. It waits 0.4-1.2 s on the ground, then hops
## toward a random point near the player: hop distance 140-260 px over an airtime of 0.5 s.
## Invulnerable and harmless while airborne. Only the Visual arcs upwards; logic never reads it.
## It does NOT declare a class_name (see docs/code-contract.md).

const WAIT_MIN := 0.4
const WAIT_MAX := 1.2
const AIRTIME := 0.5
const AIM_RADIUS := 120.0
const HOP_MIN := 140.0
const HOP_MAX := 260.0
const ARC_HEIGHT := 36.0
const HOP_TRIES := 8
const BODY_RADIUS := 22.0
## Presentation only: the crouch cue shows this many seconds before a takeoff.
const CROUCH_LEAD := 0.2

## Set at takeoff. Public for tests; game logic only writes them.
var hop_start: Vector2 = Vector2.ZERO
var hop_target: Vector2 = Vector2.ZERO

var _airborne: bool = false
var _wait_timer: float = 0.0
var _air_total: int = 1
var _air_frame: int = 0
var _hop_velocity: Vector2 = Vector2.ZERO
## Presentation only: the animation currently asked of the Visual.
var _shown_state: StringName = &""


func _init() -> void:
	max_hp = 2
	contact_damage = 1
	# Nominal speed only: a hop covers its distance in AIRTIME (see _takeoff).
	move_speed = HOP_MIN / AIRTIME
	visual_kind = &"skitterwick"
	body_radius = BODY_RADIUS


func _enemy_ready() -> void:
	_wait_timer = randf_range(WAIT_MIN, WAIT_MAX)


## Presentation only: hop in the air, crouch just before a takeoff, otherwise idle. The state is
## only sent when it changes, so a finished hop is not restarted every frame.
func _process(_delta: float) -> void:
	if visual == null or not visual.has_method("play_anim"):
		return
	visual.set(&"auto_motion", false)
	var state: StringName = &"idle"
	if _airborne:
		state = &"hop"
	elif _wait_timer > 0.0 and _wait_timer <= CROUCH_LEAD:
		state = &"crouch"
	if state != _shown_state:
		_shown_state = state
		visual.call("play_anim", state)


func _enemy_physics(delta: float) -> void:
	if _airborne:
		_fly()
		return
	velocity = Vector2.ZERO
	_wait_timer -= delta
	if _wait_timer <= 0.0:
		_takeoff()


## True while the skitterwick is in the air (invulnerable, no contact damage).
func is_airborne() -> bool:
	return _airborne


## A stun that arrives mid-hop ends the hop at once: it lands where it is.
func _on_stunned(_seconds: float) -> void:
	if _airborne:
		_land()


func _takeoff() -> void:
	hop_start = global_position
	hop_target = _pick_hop_target()
	var hop := hop_target - hop_start
	if not hop.is_zero_approx():
		set_facing_dir(hop)
	# Velocity is chosen so that the hop covers exactly `hop` over whole physics frames.
	var ticks := float(Engine.physics_ticks_per_second)
	_air_total = maxi(1, roundi(AIRTIME * ticks))
	_air_frame = 0
	_airborne = true
	invulnerable = true
	hurtbox.invulnerable = true
	set_contact_enabled(false)
	_hop_velocity = hop * ticks / float(_air_total)
	velocity = _hop_velocity
	_set_arc(0.0)


func _fly() -> void:
	_air_frame += 1
	if _air_frame >= _air_total:
		_land()
		return
	velocity = _hop_velocity
	_set_arc(float(_air_frame) / float(_air_total))


func _land() -> void:
	_airborne = false
	invulnerable = false
	velocity = Vector2.ZERO
	set_contact_enabled(true)
	_set_arc(0.0)
	_wait_timer = randf_range(WAIT_MIN, WAIT_MAX)


## Presentation only: lifts the Visual in an arc. The body never moves vertically.
func _set_arc(progress: float) -> void:
	if visual != null:
		visual.position = Vector2(0.0, -ARC_HEIGHT * sin(PI * progress))


## A random point near the player, reached by a hop of 140-260 px that stays inside the room.
func _pick_hop_target() -> Vector2:
	var start := global_position
	var centre := player_position(start)
	var target := start
	for i in range(HOP_TRIES):
		var aim := centre + Vector2.RIGHT.rotated(randf() * TAU) * (randf() * AIM_RADIUS)
		target = start + _hop_vector(aim - start)
		if _in_room(target):
			return target
	return _clamp_to_room(target)


func _hop_vector(toward: Vector2) -> Vector2:
	var dir := Vector2.RIGHT.rotated(randf() * TAU)
	if not toward.is_zero_approx():
		dir = toward.normalized()
	return dir * clampf(toward.length(), HOP_MIN, HOP_MAX)


func _in_room(point: Vector2) -> bool:
	if room_rect.size == Vector2.ZERO:
		return true
	return room_rect.grow(-BODY_RADIUS).has_point(point)


func _clamp_to_room(point: Vector2) -> Vector2:
	if room_rect.size == Vector2.ZERO:
		return point
	var r := room_rect.grow(-BODY_RADIUS)
	return Vector2(clampf(point.x, r.position.x, r.end.x), clampf(point.y, r.position.y, r.end.y))
