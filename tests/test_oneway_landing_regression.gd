extends TestCase
## Natural one-way arrivals and immediate boots input, with ordinary player damage.


func run() -> void:
	for edge: Array in [[&"ow_4_2", &"ow_4_3"], [&"ow_4_5", &"ow_4_6"]]:
		for delay: int in [0, 3, 15]:
			await _drop_and_jump(edge[0], edge[1], delay)
		for delay: int in [3, 15]:
			await _drop_and_jump(edge[0], edge[1], delay, true)
	await _overlap_corner_and_obstacle()
	await _overlap_leapable_rail()
	await _reel_from_wall_overlap()
	await _boots_selected_on_free_raft()


func _drop_and_jump(upper: StringName, lower: StringName, delay: int, free_start := false) -> void:
	reset_state()
	var world := await make_world()
	world.start_at(upper)
	await frames(3)
	var room := world.get_room(upper)
	var peer := world.get_room(lower)
	for enemy in room.get_enemies() + peer.get_enemies():
		enemy.queue_free()
	var player := world.player
	player.place_at(room.global_position + Vector2(960, 780))
	GameState.acquire_item(&"skitter_boots")
	GameState.set_active_item(&"skitter_boots")
	await frames(3)
	Input.action_press(&"move_down")
	for i in range(180):
		if world.is_transitioning():
			break
		await frames(1)
	release_inputs()
	check(world.is_transitioning(), "%s: walk starts drop" % upper)
	for i in range(150):
		if not world.is_transitioning():
			break
		await frames(1)
	check_eq(world.get_current_room_id(), lower, "%s: natural arrival" % upper)
	# Room entry may spawn its roamers after the initial fixture cleanup.
	for enemy in peer.get_enemies():
		enemy.queue_free()
	await frames(delay)
	Input.action_press(&"move_down" if free_start else &"move_up")
	Input.action_press(&"use_item")
	await frames(2)
	if delay == 0:
		check(not player.is_airborne(), "%s: overlapping boots launch refused" % lower)
	elif free_start:
		check(player.is_airborne(), "%s delay %d: free boots launch begins" % [lower, delay])
	Input.action_release(&"use_item")
	await frames(660 if delay == 0 else 90)
	release_inputs()
	await frames(3)
	var label := "%s delay %d" % [lower, delay]
	check_eq(world.get_current_room_id(), lower, label + ": return remains closed")
	check(not player.is_external_motion() and not player.is_airborne(), label + ": motion ends")
	check(player.hurtbox.enabled, label + ": hurtbox restored")
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = (player.get_node("BodyShape") as CollisionShape2D).shape
	query.transform = player.global_transform
	query.collision_mask = Layers.WORLD
	check(player.get_world_2d().direct_space_state.intersect_shape(query).is_empty(),
		label + ": body clear of walls")
	var before := player.global_position
	Input.action_press(&"move_down")
	await frames(30)
	release_inputs()
	check(player.global_position.y > before.y + 30.0, label + ": can walk away")
	check_eq(GameState.health, 6, label + ": no traversal damage")
	check(player.take_damage(2, player.global_position, 0.0, 0.0), label + ": damage works")
	check_eq(GameState.health, 4, label + ": damage applied")
	await dispose(world)


func _overlap_corner_and_obstacle() -> void:
	reset_state()
	var walls: Array[Rect2] = [Rect2(480, 400, 20, 200), Rect2(400, 480, 200, 20)]
	var arena := make_arena(walls)
	var player := make_player(arena, Vector2(600, 600))
	GameState.acquire_item(&"skitter_boots")
	GameState.set_active_item(&"skitter_boots")
	await frames(2)
	player.place_at(Vector2(510, 510))
	player.facing = Vector2.RIGHT
	var before := player.global_position
	check(not player.use_item(), "boots refuse a body overlapping two corner walls")
	check_eq(player.global_position, before, "refusal does not relocate into an obstacle or hazard")
	check(not player.is_external_motion() and player.hurtbox.enabled, "refusal keeps body active")
	Input.action_press(&"move_down")
	await frames(15)
	release_inputs()
	player.facing = Vector2.RIGHT
	var launch := player.global_position
	check(player.use_item(), "boots work again after ordinary movement clears the corner")
	await frames(30)
	check_near(player.global_position.x - launch.x, 192.0, 1.0, "cleared leap retains full range")
	await dispose(arena)


func _overlap_leapable_rail() -> void:
	reset_state()
	var arena := make_arena()
	var rail := StaticBody2D.new()
	rail.collision_layer = Layers.WORLD
	rail.add_to_group(&"leapable")
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(16, 200)
	shape.shape = rectangle
	rail.add_child(shape)
	rail.position = Vector2(500, 500)
	arena.add_child(rail)
	var player := make_player(arena, Vector2(400, 500))
	GameState.acquire_item(&"skitter_boots")
	GameState.set_active_item(&"skitter_boots")
	await frames(2)
	player.place_at(Vector2(500, 500))
	player.facing = Vector2.RIGHT
	check(player.use_item(), "overlapping leapable rail does not prevent boots")
	await frames(30)
	check_near(player.global_position.x, 692.0, 1.0, "rail leap retains full range")
	await dispose(arena)


func _reel_from_wall_overlap() -> void:
	reset_state()
	var walls: Array[Rect2] = [Rect2(480, 400, 20, 200)]
	var arena := make_arena(walls)
	var player := make_player(arena, Vector2(600, 500))
	var scene := load("res://scenes/world/anchor_ring.tscn") as PackedScene
	var ring := scene.instantiate() as Node2D
	arena.add_child(ring)
	ring.global_position = Vector2(900, 500)
	GameState.acquire_item(&"reel_line")
	GameState.set_active_item(&"reel_line")
	await frames(2)
	player.place_at(Vector2(510, 500))
	player.facing = Vector2.RIGHT
	check(player.use_item(), "reel still fires from an overlapping start")
	await seconds(1.5)
	check_near(player.global_position.x, 828.0, 2.0, "actual reel pull reaches its anchor")
	check(not player.is_external_motion() and player.hurtbox.enabled, "reel ends normally")
	await dispose(arena)


func _boots_selected_on_free_raft() -> void:
	reset_state()
	var arena := make_arena()
	var water_scene := load("res://scenes/world/water_zone.tscn") as PackedScene
	var water := water_scene.instantiate() as Area2D
	water.set(&"size", Vector2(600, 600))
	water.set(&"deep", true)
	water.set(&"raft_free_steering", true)
	arena.add_child(water)
	water.global_position = Vector2(700, 500)
	var post_scene := load("res://scenes/world/mooring.tscn") as PackedScene
	var post := post_scene.instantiate() as Node2D
	post.set(&"mooring_id", &"dock")
	arena.add_child(post)
	post.global_position = Vector2(368, 400)
	var player := make_player(arena, post.call(&"landing_position"))
	GameState.acquire_item(&"reed_raft")
	GameState.acquire_item(&"skitter_boots")
	GameState.set_active_item(&"reed_raft")
	await frames(2)
	check(player.use_item(), "real free raft boards")
	await seconds(0.4)
	Input.action_press(&"move_right")
	await seconds(1.0)
	release_inputs()
	GameState.set_active_item(&"skitter_boots")
	check(not player.use_item(), "boots button away from dock does not disembark")
	check(player.is_on_raft() and player.hurtbox.enabled, "free raft remains active on water")
	var before := player.global_position.x
	Input.action_press(&"move_right")
	await frames(20)
	release_inputs()
	check(player.is_on_raft() and player.global_position.x > before + 20.0,
		"free raft keeps steering with boots selected")
	await dispose(arena)
