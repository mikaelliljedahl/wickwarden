extends TestCase
## One-way ledge drops (F8): a room declares its drop sides (Room.drop_exits); World lets the player
## cross one only where WorldData marks the edge one-way. The landing is on the entry line of the
## lower room, the lower room's solid north wall keeps the way back shut, and an undeclared drop blocks.
## The Ledge prop is a placeholder lip with a Visual child.

const UPPER := &"ow_4_2"  # grid (4, 2): exits n, e, s, w; the drop leaves through s (edge e041)
const LOWER := &"ow_4_3"  # grid (4, 3): exits e and s only, no gap back to the north
const GAP_X := 8640.0  # centre of the south gap of UPPER (origin (7680, 1920) + 960)
const LOWER_TOP := 2880.0  # the boundary between the two rooms (UPPER origin y + 960)


func run() -> void:
	await _ledge_prop()
	_room_drop_sides()
	await _drop_crosses()
	await _way_back_closed()
	await _undeclared_drop_blocks()


## The prop loads, draws a placeholder through a Visual child and registers its kind.
func _ledge_prop() -> void:
	var scene := load("res://scenes/world/ledge.tscn") as PackedScene
	check(scene != null, "the ledge scene loads")
	if scene == null:
		return
	var ledge := scene.instantiate() as Node2D
	add_child(ledge)
	check(ledge.get_node_or_null("Visual") != null, "the ledge has a Visual child")
	check(Placeholder.has_kind(&"ledge"), "the ledge kind is registered")
	check(Placeholder.is_static_kind(&"ledge"), "the ledge is a static kind")
	await dispose(ledge)


## The room API: drop sides are a subset of the exits; the graph confirms the drop is one-way.
func _room_drop_sides() -> void:
	var room := Room.new()
	var exits: Array[StringName] = [&"n", &"s"]
	var drops: Array[StringName] = [&"s"]
	room.exits = exits
	room.drop_exits = drops
	check(room.is_drop_side(&"s"), "a declared drop side is a drop side")
	check(not room.is_drop_side(&"n"), "an exit that is not declared is not a drop side")
	check(room.has_exit(&"s"), "a drop side is still an exit (it has the gap)")
	room.free()
	check(WorldData.is_oneway(String(UPPER), String(LOWER)), "the graph drops from the upper room")
	check(not WorldData.is_oneway(String(LOWER), String(UPPER)), "and not back up")


## Packed room `room_id` with the given exits and drop sides; its grid comes from the graph.
func _pack(room_id: StringName, exits: Array[StringName], drops: Array[StringName]) -> PackedScene:
	var room := Room.new()
	room.grid = WorldData.grid(String(room_id))
	room.exits = exits
	room.drop_exits = drops
	var packed := PackedScene.new()
	packed.pack(room)
	room.free()
	return packed


## Two rooms of the real graph with their scenes added to a fresh world (add_room_scene hook).
func _drop_world(upper_drops: Array[StringName]) -> World:
	var upper_exits: Array[StringName] = [&"n", &"e", &"s", &"w"]
	var lower_exits: Array[StringName] = [&"e", &"s"]
	var world := await make_world()
	world.add_room_scene(UPPER, _pack(UPPER, upper_exits, upper_drops))
	world.add_room_scene(LOWER, _pack(LOWER, lower_exits, []))
	world.start_at(UPPER)
	world.player.place_at(Vector2(GAP_X, LOWER_TOP - 180.0))
	await frames(2)
	return world


## Walking south through the gap of the upper room drops into the lower room at its entry line,
## and the camera slides there as for any edge.
func _drop_crosses() -> void:
	reset_state()
	var world := await _drop_world([&"s"])
	var player := world.player
	Input.action_press(&"move_down")
	var guard := 0
	while not world.is_transitioning() and guard < 200:
		await frames(1)
		guard += 1
	release_inputs()
	check(world.is_transitioning(), "walking off the drop starts a slide")
	await _wait(world)
	check_eq(world.get_current_room_id(), LOWER, "the drop lands in the lower room")
	# The entry line is the inner face of the north wall; the body is pushed out of the wall by
	# physics within a frame (its radius), so the landing lies between the two.
	var landing_y := player.global_position.y
	check(
		(
			landing_y >= LOWER_TOP + WorldConst.ENTRY_INSET - 0.5
			and landing_y <= LOWER_TOP + WorldConst.ENTRY_INSET + Player.BODY_RADIUS + 0.5
		),
		"the landing is inside the lower room, at its north wall (got y %.1f)" % landing_y
	)
	check_near(player.global_position.x, GAP_X, 0.5, "the landing keeps the lateral position")
	check_eq(
		world.camera.position,
		world.get_room(LOWER).position + WorldConst.CAMERA_OFFSET,
		"the camera slides to the lower room"
	)
	await dispose(world)


## After the drop the north wall of the lower room is solid: holding north never leaves it.
func _way_back_closed() -> void:
	reset_state()
	var world := await _drop_world([&"s"])
	var player := world.player
	player.place_at(Vector2(GAP_X, LOWER_TOP + 300.0))
	await frames(2)
	Input.action_press(&"move_down")
	await seconds(0.3)
	release_inputs()
	await _wait(world)
	check_eq(world.get_current_room_id(), LOWER, "now in the lower room")
	Input.action_press(&"move_up")
	await seconds(2.0)
	release_inputs()
	check_eq(world.get_current_room_id(), LOWER, "holding north does not climb back up")
	check(
		player.global_position.y >= LOWER_TOP + WorldConst.WALL_THICKNESS + 26.0 - 1.0,
		"the solid north wall of the lower room stops the player"
	)
	await dispose(world)


## Without a declared drop side the same edge is closed: the player stays in the upper room.
func _undeclared_drop_blocks() -> void:
	reset_state()
	var world := await _drop_world([])
	var player := world.player
	Input.action_press(&"move_down")
	await seconds(2.0)
	release_inputs()
	check_eq(world.get_current_room_id(), UPPER, "an undeclared drop does not cross")
	# One frame of walking may pass the clamp before World holds the player at the edge.
	check(
		player.global_position.y <= LOWER_TOP + Player.WALK_SPEED / FPS + 0.5,
		"the player is held at the room edge"
	)
	await dispose(world)


func _wait(world: World, max_frames: int = 120) -> void:
	var n := 0
	while world.is_transitioning() and n < max_frames:
		await frames(1)
		n += 1
