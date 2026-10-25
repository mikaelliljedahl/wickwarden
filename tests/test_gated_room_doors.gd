extends TestCase
## Real-scene regressions: the player's body reaches the trigger beyond an intact opener.


func run() -> void:
	for id in [&"ow_7_3", &"ow_1_5", &"ow_4_1", &"ow_6_0", &"ow_3_5"]:
		await _check_entrance(id)
	await _explicit_requirements()


func _check_entrance(id: StringName) -> void:
	reset_state()
	var world := await make_world()
	world.start_at(id)
	await frames(3)
	var room := world.get_room(id)
	var door: RoomDoor
	for child in room.get_node("Props").get_children():
		if child is RoomDoor:
			door = child
	check(door != null, "%s has a real entrance" % id)
	if door == null:
		await dispose(world)
		return
	var opener: Node2D
	for child in room.get_node("Props").get_children():
		if child is StaticBody2D and child.position == door.position:
			opener = child
	check(opener != null, "%s has an authoritative opener" % id)
	if opener == null:
		await dispose(world)
		return
	# 60 px is the reviewer's ow_7_3 repro: body overlaps the 96 px door below the bush.
	if not opener is Bush:
		# Force overlap for rectangular walls: normal collision recovery keeps bodies outside.
		world.player.set_physics_process(false)
	world.player.place_at(door.global_position + Vector2(0, 60))
	await frames(5)
	check(door.has_overlapping_bodies(), "%s reproduces trigger edge overlap" % id)
	check(not world.is_transitioning(), "%s intact opener prevents entry" % id)
	check_eq(world.get_current_room_id(), id, "%s stays outside" % id)
	var flag := &""
	if opener is Bush:
		opener.drops_enabled = false
		opener.cut_down()
	else:
		flag = opener.call("flag_name")
		opener.call("on_explosion", opener.global_position, 96.0)
	check(door._gate_is_open(), "%s required opener enables entry" % id)
	await frames(4)
	if ResourceLoader.exists(WorldData.scene_path(String(door.target_room))):
		check(world.is_transitioning(), "%s enters after opening" % id)
	if flag != &"":
		check(GameState.has_flag(flag), "%s opening persists in GameState" % id)
	await seconds(1.0)
	await dispose(world)
	# Reinstantiate the actual scene with the same state: walls stay open, bushes regrow.
	var scene := load(WorldData.scene_path(String(id))) as PackedScene
	check(scene != null, "%s scene reloads" % id)
	var reloaded := scene.instantiate() as Room
	add_child(reloaded)
	await frames(2)
	for child in reloaded.get_node("Props").get_children():
		if child is RoomDoor:
			check_eq(child._gate_is_open(), flag != &"", "%s reload respects opener state" % id)
	await dispose(reloaded)


func _explicit_requirements() -> void:
	reset_state()
	var arena := make_arena()
	var plain := RoomDoor.new()
	arena.add_child(plain)
	check(plain._gate_is_open(), "plain door stays usable")
	var gated := RoomDoor.new()
	gated.position = Vector2(300, 300)
	gated.requires_flag = &"cracked_test"
	arena.add_child(gated)
	check(not gated._gate_is_open(), "required flag blocks entry")
	GameState.set_flag(&"cracked_test")
	check(gated._gate_is_open(), "authoritative flag enables entry")
	var bush := Bush.new()
	bush.name = "OffsetBush"
	bush.position = Vector2(500, 500)
	bush.drops_enabled = false
	arena.add_child(bush)
	var offset := RoomDoor.new()
	offset.position = Vector2(600, 500)
	offset.blocker_path = NodePath("../OffsetBush")
	arena.add_child(offset)
	check(not offset._gate_is_open(), "explicit link blocks even with offset opener")
	bush.cut_down()
	check(offset._gate_is_open(), "cutting linked offset opener enables entrance")
	var linked := RoomDoor.new()
	linked.blocker_path = NodePath("../Missing")
	arena.add_child(linked)
	check(not linked._gate_is_open(), "missing explicit blocker fails closed")
	await dispose(arena)
