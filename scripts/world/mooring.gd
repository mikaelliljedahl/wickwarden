extends StaticBody2D
## A mooring post on a shore: a solid post (layer WORLD) with a dock zone of 80 px. A raft crossing links two
## posts: `target_room` and `target_mooring` name the post at the other end, which names this one back
## (world-plan 2.3, monsters file 5.4). The post is in group `mooring`.
##
## `get_ride_path()` returns the path of a raft ride from this post to the target post: a quadratic arc
## over the water, sampled every SAMPLE_PX, ending exactly on the target's landing point. The landing point
## is beside the post, not on it: the post is solid and the player body (radius 26) would be pushed out.
## The path is in world coordinates and may cross a room edge; the World slides the camera while the ride
## runs (F7). The target post must be in the tree now (its room is loaded). Otherwise the path is empty.

## Speed of the raft in px/s (monsters file 5.4). Callers pass it to Player.begin_external_motion.
const RIDE_SPEED := 240.0
const DOCK_RADIUS := 80.0
## The arc bulges by this share of the crossing length, on the side of the chord's left normal.
const ARC_HEIGHT := 0.2
const SAMPLE_PX := 24.0
const POST_SIZE := Vector2(32, 32)
const KIND := &"mooring"

@export var mooring_id: StringName = &""
## Room id and mooring id of the post at the other end of the crossing.
@export var target_room: StringName = &""
@export var target_mooring: StringName = &""
## Landing point of this post relative to its origin: clear of the post (16 px half-size) and of the player
## body (radius 26), so the player stands on the shore beside the post after a ride.
@export var landing_offset: Vector2 = Vector2(0, 56)
## Debug only: draws the ride path to the target as a faint line (used by the gallery capture).
@export var draw_ride_path: bool = false

var _post: CollisionShape2D


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0


func _ready() -> void:
	add_to_group(&"mooring")
	if not Placeholder.has_kind(KIND):
		Placeholder.register_kind(
			KIND, {"shape": "rect", "color": Color(0.42, 0.3, 0.18), "size": POST_SIZE}, true
		)
	var rect := RectangleShape2D.new()
	rect.size = POST_SIZE
	_post = CollisionShape2D.new()
	_post.name = "Post"
	_post.shape = rect
	add_child(_post)
	_add_dock_zone()
	SpriteVisual.attach(self, KIND, 0.0, POST_SIZE)


func _draw() -> void:
	if not draw_ride_path or not is_inside_tree():
		return
	var path := get_ride_path()
	var previous := Vector2.ZERO
	for point in path:
		var local := to_local(point)
		draw_line(previous, local, Color(1.0, 0.92, 0.5, 0.6), 3.0)
		previous = local


## Id of the Room this post stands in, or &"" when it is in no Room.
func room_id_of() -> StringName:
	var node := get_parent()
	while node != null:
		if node is Room:
			return (node as Room).room_id
		node = node.get_parent()
	return &""


## Landing point of this post in world coordinates (its origin plus `landing_offset`).
func landing_position() -> Vector2:
	return global_position + landing_offset


## The ride from this post's landing point to the target post's landing point, in world coordinates,
## excluding the start. Empty when the target is not in the tree.
func get_ride_path() -> Array[Vector2]:
	var path: Array[Vector2] = []
	var target := find_target()
	if target == null:
		return path
	var start := landing_position()
	var end: Vector2 = target.call(&"landing_position")
	var chord := end - start
	var length := chord.length()
	if length < 1.0:
		return path
	var normal := Vector2(-chord.y, chord.x).normalized()
	var control := start.lerp(end, 0.5) + normal * length * ARC_HEIGHT
	var count := maxi(2, ceili(length / SAMPLE_PX))
	for i in range(1, count + 1):
		if i == count:
			path.append(end)
		else:
			var t := float(i) / float(count)
			path.append(_bezier(start, control, end, t))
	return path


## The post this one rides to: the one in group `mooring` with id `target_mooring` in room
## `target_room`, not this post. Null when there is none in the tree.
func find_target() -> Node2D:
	for node in get_tree().get_nodes_in_group(&"mooring"):
		if node == self or node.get_script() != get_script():
			continue
		if node.get(&"mooring_id") == target_mooring and node.room_id_of() == target_room:
			return node as Node2D
	return null


static func _bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var u := 1.0 - t
	return u * u * p0 + 2.0 * u * t * p1 + t * t * p2


func _add_dock_zone() -> void:
	var zone := Area2D.new()
	zone.name = "DockZone"
	zone.collision_layer = 0
	zone.collision_mask = Layers.PLAYER_BODY
	var shape := CircleShape2D.new()
	shape.radius = DOCK_RADIUS
	var node := CollisionShape2D.new()
	node.name = "Shape"
	node.shape = shape
	zone.add_child(node)
	add_child(zone)
