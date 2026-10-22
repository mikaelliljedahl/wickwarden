extends EnemyBase
## Duskmoth (the bat analogue, plan section 6). HP 1, contact damage 1, speed 260.
##
## Rests on the ground. When the player is within 300 px and the rest is over, it flies for a random
## 2-4 s in curves: the heading turns at a random rate (-4..+4 rad/s, re-rolled every 0.2-0.5 s),
## it bounces off walls and steers back inwards near the room edges. After a flight it rests for at
## least 1.0 s before it can wake again. While stunned it stays still (the base holds velocity at 0).
## It does NOT declare a class_name (see docs/code-contract.md).

const WAKE_RANGE := 300.0
const FLY_MIN := 2.0
const FLY_MAX := 4.0
const REST_TIME := 1.0
const TURN_RATE_MAX := 4.0
const TURN_TIME_MIN := 0.2
const TURN_TIME_MAX := 0.5
## Distance from a room edge at which the heading starts to turn back inwards.
const EDGE_MARGIN := 96.0

var _flying: bool = false
var _timer: float = 0.0
var _turn_rate: float = 0.0
var _turn_timer: float = 0.0


func _init() -> void:
	max_hp = 1
	contact_damage = 1
	move_speed = 260.0
	visual_kind = &"duskmoth"
	body_radius = 22.0


func _enemy_ready() -> void:
	_start_rest()


func _enemy_physics(delta: float) -> void:
	if _flying:
		_fly(delta)
	else:
		velocity = Vector2.ZERO
		_timer -= delta
		if _timer <= 0.0 and _player_in_wake_range():
			_start_flight()


## True while the moth is in its flight state.
func is_flying() -> bool:
	return _flying


func _fly(delta: float) -> void:
	_timer -= delta
	_turn_timer -= delta
	if _turn_timer <= 0.0:
		_turn_rate = randf_range(-TURN_RATE_MAX, TURN_RATE_MAX)
		_turn_timer = randf_range(TURN_TIME_MIN, TURN_TIME_MAX)
	var heading: Vector2 = facing_dir.rotated(_turn_rate * delta)
	if hit_wall and get_slide_collision_count() > 0:
		heading = heading.bounce(get_slide_collision(0).get_normal())
	heading = _steer_from_edges(heading)
	set_facing_dir(heading)
	velocity = facing_dir * move_speed
	if _timer <= 0.0:
		_start_rest()


func _start_flight() -> void:
	_flying = true
	_timer = randf_range(FLY_MIN, FLY_MAX)
	_turn_rate = 0.0
	_turn_timer = 0.0
	set_facing_dir(Vector2.RIGHT.rotated(randf() * TAU))


func _start_rest() -> void:
	_flying = false
	_timer = REST_TIME
	velocity = Vector2.ZERO


func _player_in_wake_range() -> bool:
	var p: Node2D = get_player()
	return p != null and p.global_position.distance_to(global_position) <= WAKE_RANGE


## Turns a heading back inwards when the moth is near a room edge and still moving outwards.
func _steer_from_edges(dir: Vector2) -> Vector2:
	if room_rect.size == Vector2.ZERO:
		return dir
	var inner: Rect2 = room_rect.grow(-EDGE_MARGIN)
	var d: Vector2 = dir
	if global_position.x < inner.position.x and d.x < 0.0:
		d.x = -d.x
	if global_position.x > inner.end.x and d.x > 0.0:
		d.x = -d.x
	if global_position.y < inner.position.y and d.y < 0.0:
		d.y = -d.y
	if global_position.y > inner.end.y and d.y > 0.0:
		d.y = -d.y
	return d.normalized()
