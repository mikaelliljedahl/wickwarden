extends TestCase
## Mooring (P03): the post is a solid WORLD body with a dock zone and its look; get_ride_path() is an arc
## from this post to the target post, ends exactly on the target and crosses a room edge when needed;
## a stand-in raft (the Player's external motion at RIDE_SPEED) rides the path to the target.

const SCENE := "res://scenes/world/mooring.tscn"
const SCRIPT := "res://scripts/world/mooring.gd"
const ROOM_W := 1920.0


func run() -> void:
	await _post_and_look()
	await _no_target_no_path()
	await _path_ends_on_target_across_edge()
	await _path_in_one_room_is_an_arc()
	await _stand_in_raft_rides_path()


## Builds a mooring from the scene (untyped: the script has no class_name, so it is a plain Node here).
func _make_post(
	parent: Node, id: StringName, target_room: StringName, target: StringName, at: Vector2
) -> Variant:
	var scene := load(SCENE) as PackedScene
	var post: Node2D = scene.instantiate()
	post.set(&"mooring_id", id)
	post.set(&"target_room", target_room)
	post.set(&"target_mooring", target)
	parent.add_child(post)
	post.global_position = at
	return post


## Two Room nodes side by side (grid (0, 0) and (1, 0)), no walls, in the test tree.
func _make_rooms() -> Array[Room]:
	var rooms: Array[Room] = []
	for grid in [Vector2i(0, 0), Vector2i(1, 0)]:
		var room := Room.new()
		room.room_id = &"ow_test_a" if grid.x == 0 else &"ow_test_b"
		room.grid = grid
		room.build_walls = false
		add_child(room)
		rooms.append(room)
	return rooms


func _post_and_look() -> void:
	reset_state()
	var scene := load(SCENE) as PackedScene
	check(scene != null, "the mooring scene loads")
	var post: Node2D = scene.instantiate()
	add_child(post)
	await frames(2)
	check(post.is_in_group(&"mooring"), "a mooring is in group mooring")
	check(post is StaticBody2D, "a mooring post is a solid body")
	check_eq((post as StaticBody2D).collision_layer, Layers.WORLD, "the post sits on layer WORLD")
	check(post.get_node_or_null("Post") != null, "the post has a collision shape")
	check(post.get_node_or_null(Placeholder.VISUAL_NAME) != null, "the mooring has a Visual child")
	check(Placeholder.has_kind(&"mooring"), "the mooring kind is registered")
	var zone := post.get_node_or_null("DockZone") as Area2D
	check(zone != null, "the mooring has a dock zone")
	if zone != null:
		check_eq(zone.collision_mask, Layers.PLAYER_BODY, "the dock zone sees the player body")
		var circle := (zone.get_node("Shape") as CollisionShape2D).shape as CircleShape2D
		check_near(circle.radius, 80.0, 0.01, "the dock zone has radius 80")
	var script = load(SCRIPT)
	check_near(script.RIDE_SPEED, 240.0, 0.01, "the raft rides at 240 px/s")
	await dispose(post)


## Without a target in the tree the path is empty (the player refuses an empty path).
func _no_target_no_path() -> void:
	reset_state()
	var arena := make_arena()
	var post: Variant = _make_post(arena, &"lonely", &"ow_test_b", &"nowhere", Vector2(300, 300))
	await frames(2)
	var path: Array[Vector2] = post.get_ride_path()
	check(path.is_empty(), "no target in the tree gives an empty path")
	await dispose(arena)


## A post in room A rides to a post in room B across the edge at x = 1920. The path ends on the target
## and passes into room B.
func _path_ends_on_target_across_edge() -> void:
	reset_state()
	var rooms := _make_rooms()
	var from_post: Variant = _make_post(
		rooms[0], &"west_shore", &"ow_test_b", &"east_shore", Vector2(1500, 480)
	)
	var to_post: Variant = _make_post(
		rooms[1], &"east_shore", &"ow_test_a", &"west_shore", Vector2(ROOM_W + 300, 480)
	)
	await frames(2)
	check(
		from_post.global_position.is_equal_approx(Vector2(1500, 480)),
		"the west post stands in room A"
	)
	check(
		to_post.global_position.is_equal_approx(Vector2(ROOM_W + 300, 480)),
		"the east post stands in room B"
	)
	check(from_post.room_id_of() == &"ow_test_a", "a post knows the room it stands in")
	var path: Array[Vector2] = from_post.get_ride_path()
	check(path.size() >= 2, "a crossing has at least two path points")
	if not path.is_empty():
		check(
			path[path.size() - 1] == to_post.landing_position(),
			"the path ends exactly on the target's landing point"
		)
		var crosses := false
		for point in path:
			if point.x > ROOM_W:
				crosses = true
		check(crosses, "the path crosses the edge into room B")
	for room in rooms:
		await dispose(room)


## Within one room the path is an arc: some sample is off the straight chord, and it ends on the target.
func _path_in_one_room_is_an_arc() -> void:
	reset_state()
	var rooms := _make_rooms()
	var from_post: Variant = _make_post(
		rooms[0], &"north", &"ow_test_a", &"south", Vector2(400, 200)
	)
	var to_post: Variant = _make_post(
		rooms[0], &"south", &"ow_test_a", &"north", Vector2(1400, 200)
	)
	await frames(2)
	var path: Array[Vector2] = from_post.get_ride_path()
	check(path.size() >= 2, "a crossing inside one room has path points")
	var max_off_chord := 0.0
	for point in path:
		max_off_chord = maxf(max_off_chord, absf(point.y - 200.0))
	check(max_off_chord > 20.0, "the path arcs away from the straight chord")
	check(
		not path.is_empty() and path[path.size() - 1] == to_post.landing_position(),
		"the arc ends on the target's landing point"
	)
	var script = load(SCRIPT)
	var previous: Vector2 = from_post.landing_position()
	var steps_ok := true
	for point in path:
		if previous.distance_to(point) > script.SAMPLE_PX * 1.5:
			steps_ok = false
		previous = point
	check(steps_ok, "path points are about one sample step apart (within 1.5 steps)")
	for room in rooms:
		await dispose(room)


## A stand-in raft: the player's external motion along the ride path at RIDE_SPEED reaches the target
## post and the motion ends there.
func _stand_in_raft_rides_path() -> void:
	reset_state()
	var rooms := _make_rooms()
	var from_post: Variant = _make_post(
		rooms[0], &"ride_from", &"ow_test_b", &"ride_to", Vector2(1500, 600)
	)
	var to_post: Variant = _make_post(
		rooms[1], &"ride_to", &"ow_test_a", &"ride_from", Vector2(ROOM_W + 400, 600)
	)
	var player := make_player(rooms[0], from_post.landing_position())
	await frames(2)
	var path: Array[Vector2] = from_post.get_ride_path()
	var script = load(SCRIPT)
	var finished := [false]
	player.motion_finished.connect(func() -> void: finished[0] = true)
	check(
		player.begin_external_motion(path, script.RIDE_SPEED), "the stand-in raft starts the ride"
	)
	await seconds(5.0)
	check(finished[0], "the ride ends")
	check(not player.is_external_motion(), "no motion runs after the ride")
	check(
		player.global_position.distance_to(to_post.landing_position()) < 0.5,
		"the raft lands on the target's landing point"
	)
	for room in rooms:
		await dispose(room)
