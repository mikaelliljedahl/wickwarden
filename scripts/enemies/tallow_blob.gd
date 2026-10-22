extends EnemyBase
## Tallow blob (plan section 6): a splitting wax slime. Moves in short steps toward the player:
## 0.35 s of movement, then a pause of 0.3-0.6 s, repeat. On death it splits into 2 tallow drops
## placed 30 px left and right of it, in the same parent and the same room rect.
## 2 hp, contact damage 1, speed 160. It does NOT declare a class_name (see docs/code-contract.md).
## The tallow drop extends this script and overrides the split, so a drop never splits.

const STEP_TIME := 0.35
const PAUSE_MIN := 0.3
const PAUSE_MAX := 0.6
const SPLIT_OFFSET := 30.0
const DROP_SCENE_PATH := "res://scenes/enemies/tallow_drop.tscn"

var _stepping: bool = false
var _timer: float = 0.0
var _step_dir: Vector2 = Vector2.ZERO


func _init() -> void:
	max_hp = 2
	contact_damage = 1
	move_speed = 160.0
	visual_kind = &"tallow_blob"
	body_radius = 34.0


func _enemy_ready() -> void:
	_start_pause()


func _enemy_physics(delta: float) -> void:
	_timer -= delta
	if _stepping:
		velocity = _step_dir * move_speed
		if _timer <= 0.0:
			_start_pause()
	else:
		velocity = Vector2.ZERO
		if _timer <= 0.0:
			_start_step()


func _start_step() -> void:
	_stepping = true
	_timer = STEP_TIME
	_step_dir = direction_to_player()
	if _step_dir != Vector2.ZERO:
		set_facing_dir(_step_dir)


func _start_pause() -> void:
	_stepping = false
	_timer = randf_range(PAUSE_MIN, PAUSE_MAX)
	_step_dir = Vector2.ZERO


## Splits into two tallow drops. Nodes are added with call_deferred because death can happen
## inside a physics callback; the drops are positioned in the parent's space before they are added.
func _on_death() -> void:
	var parent := get_parent()
	var drop_scene := load(DROP_SCENE_PATH) as PackedScene
	if parent == null or drop_scene == null:
		return
	for side: float in [-1.0, 1.0]:
		var drop := drop_scene.instantiate() as EnemyBase
		if drop == null:
			continue
		drop.room_rect = room_rect
		var at := _inside_room(global_position + Vector2(SPLIT_OFFSET * side, 0.0), drop.body_radius)
		var parent_2d := parent as Node2D
		drop.position = parent_2d.to_local(at) if parent_2d != null else at
		parent.call_deferred(&"add_child", drop)


## Keeps a drop's spawn point inside the room, so a split next to a wall stays in the room.
func _inside_room(pos: Vector2, radius: float) -> Vector2:
	if room_rect.size == Vector2.ZERO:
		return pos
	var r := room_rect.grow(-radius)
	return Vector2(clampf(pos.x, r.position.x, r.end.x), clampf(pos.y, r.position.y, r.end.y))
