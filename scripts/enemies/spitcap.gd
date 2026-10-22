extends EnemyBase
## Spitcap (rock spitter). Walks in a random cardinal direction for 0.6-1.6 s, then stops. If the
## player is roughly on its row or column (within 48 px on the other axis) it faces the player and
## spits a spore (360 px/s, 1 half-heart), then pauses 0.5 s. Otherwise it picks a new direction.
## 2 hp, contact damage 1, speed 120. Turns around when it hits a wall.
## While stunned it does nothing (the base skips _enemy_physics during a stun).
## It does NOT declare a class_name (WP files must not; see docs/code-contract.md).

enum State { WALK, PAUSE }

const WALK_MIN := 0.6
const WALK_MAX := 1.6
const SPIT_PAUSE := 0.5
const ALIGN_TOLERANCE := 48.0
const SPORE_SPEED := 360.0
const SPORE_DAMAGE := 1
const SPORE_SCENE_PATH := "res://scenes/enemies/spore.tscn"
const DIRECTIONS: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

var _state: State = State.WALK
var _timer: float = 0.0
var _spore_scene: PackedScene


func _init() -> void:
	max_hp = 2
	contact_damage = 1
	move_speed = 120.0
	visual_kind = &"spitcap"
	body_radius = 30.0


func _enemy_ready() -> void:
	_spore_scene = load(SPORE_SCENE_PATH) as PackedScene   # null is fine: plain projectile
	_start_walk()


func _enemy_physics(delta: float) -> void:
	_timer -= delta
	if _state == State.PAUSE:
		velocity = Vector2.ZERO
		if _timer <= 0.0:
			_start_walk()
		return
	velocity = facing_dir * move_speed
	if hit_wall:
		set_facing_dir(-facing_dir)
	if _timer <= 0.0:
		_stop_and_decide()


func _start_walk() -> void:
	_state = State.WALK
	_timer = randf_range(WALK_MIN, WALK_MAX)
	set_facing_dir(DIRECTIONS[randi() % DIRECTIONS.size()])


## Called when a walk ends: spit if the player is aligned, otherwise pick a new direction.
func _stop_and_decide() -> void:
	velocity = Vector2.ZERO
	var aim := _aligned_direction()
	if aim == Vector2.ZERO:
		_start_walk()
		return
	set_facing_dir(aim)
	fire_projectile(
		_spore_scene,
		aim,
		SPORE_SPEED,
		SPORE_DAMAGE,
		global_position + aim * (body_radius + 14.0)
	)
	_state = State.PAUSE
	_timer = SPIT_PAUSE


## Cardinal direction from this spitcap toward the player when the player is roughly on its row or
## column (within ALIGN_TOLERANCE on the other axis). Vector2.ZERO when there is no such alignment.
func _aligned_direction() -> Vector2:
	var player := get_player()
	if player == null:
		return Vector2.ZERO
	var offset := player.global_position - global_position
	var row_gap := absf(offset.y)
	var col_gap := absf(offset.x)
	var on_row := row_gap <= ALIGN_TOLERANCE
	var on_col := col_gap <= ALIGN_TOLERANCE
	if on_row and (not on_col or row_gap <= col_gap):
		return Vector2.RIGHT if offset.x >= 0.0 else Vector2.LEFT
	if on_col:
		return Vector2.DOWN if offset.y >= 0.0 else Vector2.UP
	return Vector2.ZERO
