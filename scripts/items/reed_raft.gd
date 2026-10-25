extends ItemBase
## Reed raft: authored fixed lanes and opt-in free-steering deep-water basins.
## Player advances free steering in physics, so World slides pause the rider and vehicle together.

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
var _free_steering := false
var _launch := Vector2.ZERO
var _source_post: Node2D
var _left_source := false
var _ride_velocity := Vector2.ZERO
const ACCELERATION := RIDE_SPEED / 0.2
const DECELERATION := RIDE_SPEED / 0.4
const DOCK_RADIUS := 80.0


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
	var painted := look as SpriteVisual
	if painted != null:
		# Sort the deck just before its rider. Compensate in the sprite offset so
		# every painted pixel keeps BOARD_OFFSET; the raft/player transforms stay unchanged.
		y_sort_enabled = true
		look.position.y = -1.0
		painted.offset += BOARD_OFFSET - look.position


func _exit_tree() -> void:
	if _riding and is_instance_valid(_hero):
		_hero.end_external_motion()
	_release_hero()


## Boards at the nearest mooring in range, into an adjacent opt-in basin or its existing paired lane.
## Refused when neither is available, the player is dead or in motion, or another raft is live.
func activate() -> bool:
	_hero = player as Player
	if _hero == null or _hero.is_dead() or _hero.is_external_motion() or active_count() > 1:
		return false
	var post := _nearest_mooring()
	if post == null:
		return false
	var path: Array[Vector2] = post.call(&"get_ride_path")
	_source_post = post
	_free_steering = _find_launch(post)
	if path.is_empty() and not _free_steering:
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


## Begins the selected free-water or lane motion after boarding. Refusal frees the vehicle.
func _start_ride() -> void:
	_boarding = false
	_release_hero()
	var accepted := false
	if _free_steering:
		accepted = _hero.begin_raft_motion(self)
		if accepted:
			_hero.global_position = _launch
	else:
		accepted = _hero.begin_external_motion(_path, RIDE_SPEED)
	if not accepted:
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


## Advances the vehicle only from Player physics. Every displacement uses the same swept union.
func advance_raft(delta: float, push: Vector2, direction: Vector2) -> void:
	var rate := DECELERATION if direction.is_zero_approx() else ACCELERATION
	_ride_velocity = _ride_velocity.move_toward(direction * RIDE_SPEED, rate * delta)
	var start := _hero.global_position
	var after_push := _sweep_water(start, push)
	_hero.global_position = _sweep_water(after_push, _ride_velocity * delta)
	_hero.velocity = (_hero.global_position - after_push) / delta
	global_position = _hero.global_position
	if not is_instance_valid(_source_post):
		_left_source = true
	elif global_position.distance_to(_source_post.global_position) > DOCK_RADIUS:
		_left_source = true
	for node in get_tree().get_nodes_in_group(MOORING_GROUP):
		if node == _source_post and not _left_source:
			continue
		if global_position.distance_to(node.global_position) <= DOCK_RADIUS:
			_land(node)
			return


## Explicit raft use lands only at a nearby dock, including the launch dock.
func request_dock() -> bool:
	for post in get_tree().get_nodes_in_group(MOORING_GROUP):
		if _hero.global_position.distance_to(post.global_position) <= DOCK_RADIUS:
			_land(post)
			return true
	return false


func _land(post: Node2D) -> void:
	var landing: Vector2 = post.landing_position()
	_hero.end_external_motion()
	_hero.global_position = landing


func _find_launch(post: Node2D) -> bool:
	var best := BOARD_RANGE
	var found := false
	for zone in _deep_zones():
		if not zone.raft_free_steering:
			continue
		var point: Vector2 = zone.nearest_point(post.global_position)
		var distance := point.distance_to(post.global_position)
		if distance <= best:
			best = distance
			_launch = point
			found = true
	return found


func _deep_zones() -> Array[Node]:
	var zones: Array[Node] = []
	for zone in get_tree().get_nodes_in_group(&"water_zone"):
		if zone.deep:
			zones.append(zone)
	return zones


## Segment/rectangle intervals are merged from t=0. Stop at the first land gap, even when
## the endpoint lies in another water rectangle. Touching rectangles form one continuous union.
func _sweep_water(start: Vector2, displacement: Vector2) -> Vector2:
	if displacement.is_zero_approx():
		return start
	var intervals: Array[Vector2] = []
	for zone in _deep_zones():
		var rect: Rect2 = zone.global_rect()
		var enter := 0.0
		var leave := 1.0
		for axis in range(2):
			if absf(displacement[axis]) < 0.00001:
				if start[axis] < rect.position[axis] or start[axis] > rect.end[axis]:
					leave = -1.0
			else:
				var a := (rect.position[axis] - start[axis]) / displacement[axis]
				var b := (rect.end[axis] - start[axis]) / displacement[axis]
				enter = maxf(enter, minf(a, b))
				leave = minf(leave, maxf(a, b))
		if enter <= leave:
			intervals.append(Vector2(enter, leave))
	intervals.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
	var reach := 0.0
	for interval in intervals:
		if interval.x > reach + 0.000001:
			break
		reach = maxf(reach, interval.y)
	return start + displacement * clampf(reach, 0.0, 1.0)
