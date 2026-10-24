extends ItemBase
## Reed raft (T03), fixed lane. `use_item` within BOARD_RANGE px of a Mooring post boards the raft: Tamsin stands
## still for BOARD_TIME s with her actions locked. Then she rides the post's `get_ride_path()` to the target post at
## RIDE_SPEED through the Player motion API (walls and water do not stop it; the path crosses room edges). The raft
## node follows her and leaves group `items` while it rides, so the World's room-change sweep does not free it.
## It finishes when the ride ends: arrival, or death or place_at, which both end the motion. No ammo.
## Refused away from a mooring, or when the target post is not in the tree (empty path). Spec: monsters-bosses-tools
## 5.4. Free steering is not built (a later WP); the boarding and the lane are the only ride modes here.

const BOARD_RANGE := 72.0
const BOARD_TIME := 0.3
## Same speed as Mooring.RIDE_SPEED (monsters-bosses-tools 5.4); the test checks the two agree.
const RIDE_SPEED := 240.0
## The raft look sits under Tamsin's feet (the item node is at her position).
const BOARD_OFFSET := Vector2(0, 14)
const MOORING_GROUP := &"mooring"

var _hero: Player
var _boarding: bool = false
var _board_left: float = 0.0
var _riding: bool = false
var _path: Array[Vector2] = []


func _init() -> void:
	item_id = &"reed_raft"


func _ready() -> void:
	if not Placeholder.has_kind(&"reed_raft"):
		Placeholder.register_kind(
			&"reed_raft",
			{"shape": "rect", "color": Color(0.5, 0.42, 0.22), "size": Vector2(64, 40)}
		)
	var look := SpriteVisual.attach(self, &"reed_raft")
	look.position = BOARD_OFFSET


func _exit_tree() -> void:
	_release_hero()


## Boards at the nearest mooring in range when that post has a target in the tree. Refused (nothing spent) when
## there is no mooring in range, no target, Tamsin is dead or in a motion, or another raft is in the tree.
func activate() -> bool:
	_hero = player as Player
	if _hero == null or _hero.is_dead() or _hero.is_external_motion() or active_count() > 1:
		return false
	var post := _nearest_mooring()
	if post == null:
		return false
	var path: Array[Vector2] = post.call(&"get_ride_path")
	if path.is_empty():
		return false
	_path = path
	remove_from_group(&"items")
	_boarding = true
	_board_left = BOARD_TIME
	_hero.lock_actions(self, true)
	_hero.set_speed_scale(self, 0.0)
	global_position = _hero.global_position
	return true


func _physics_process(delta: float) -> void:
	if _riding:
		global_position = _hero.global_position
		return
	if not _boarding:
		return
	if _hero.is_dead():
		finish()
		return
	global_position = _hero.global_position
	_board_left -= delta
	if _board_left <= 0.0:
		_start_ride()


## Begins the ride along the lane. A refused motion (the player died meanwhile) ends the item at once.
func _start_ride() -> void:
	_boarding = false
	_release_hero()
	if not _hero.begin_external_motion(_path, RIDE_SPEED):
		finish()
		return
	_riding = true
	_hero.motion_finished.connect(_on_ride_over, CONNECT_ONE_SHOT)


## Arrival, death or place_at ended the ride: the raft is done.
func _on_ride_over() -> void:
	_riding = false
	finish()


## Gives back Tamsin's walking speed and actions. Safe to call more than once.
func _release_hero() -> void:
	if _hero == null or not is_instance_valid(_hero):
		return
	_hero.lock_actions(self, false)
	_hero.set_speed_scale(self, 1.0)


## The mooring post closest to Tamsin within BOARD_RANGE of its origin, or null.
func _nearest_mooring() -> Node2D:
	var best: Node2D = null
	var best_dist := BOARD_RANGE
	for node in get_tree().get_nodes_in_group(MOORING_GROUP):
		var post := node as Node2D
		if post == null:
			continue
		var dist := post.global_position.distance_to(_hero.global_position)
		if dist <= best_dist:
			best = post
			best_dist = dist
	return best
