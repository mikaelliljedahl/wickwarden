extends EnemyBase
## Minimal worked example enemy. Copy this file to start a new enemy.
##
## Behaviour: walk in a random cardinal direction for 0.5-1.2 s, rest for 0.4 s, repeat. Turns
## around when it hits a wall. 2 hp, contact damage 1, speed 100.
## It does NOT declare a class_name (WP files must not; see docs/code-contract.md).

const WALK_MIN := 0.5
const WALK_MAX := 1.2
const REST_TIME := 0.4
const DIRECTIONS: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

var _walking: bool = false
var _timer: float = 0.0


func _init() -> void:
	max_hp = 2
	contact_damage = 1
	move_speed = 100.0
	visual_kind = &"dummy_walker"
	body_radius = 28.0


func _enemy_ready() -> void:
	_start_rest()


func _enemy_physics(delta: float) -> void:
	_timer -= delta
	if _walking:
		velocity = facing_dir * move_speed
		if hit_wall:
			facing_dir = -facing_dir
		if _timer <= 0.0:
			_start_rest()
	else:
		velocity = Vector2.ZERO
		if _timer <= 0.0:
			_start_walk()


func _start_walk() -> void:
	_walking = true
	_timer = randf_range(WALK_MIN, WALK_MAX)
	set_facing_dir(DIRECTIONS[randi() % DIRECTIONS.size()])


func _start_rest() -> void:
	_walking = false
	_timer = REST_TIME
