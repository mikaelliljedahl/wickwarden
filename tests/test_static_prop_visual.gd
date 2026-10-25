extends TestCase
## Presentation offsets keep the solid footprint and actual room entrance contracts intact.


func run() -> void:
	await _offset_contract()
	await _entrance(&"ow_1_2", &"ow_1_2#shop", Vector2(1488, 240), false)
	await _entrance(&"ow_3_3", &"ow_3_3#hut", Vector2(1392, 432), true)


func _offset_contract() -> void:
	var arena := make_arena()
	for shift in [Vector2.ZERO, Vector2(-64, 84)]:
		var block := SolidBlock.new()
		block.kind = &"hut"
		block.size = Vector2(192, 96)
		block.set("visual_offset", shift)
		arena.add_child(block)
		check_eq(block.get_node("Visual").position, shift, "only Visual receives the offset")
		check_eq(block.position, Vector2.ZERO, "body origin stays fixed")
		check_eq(block.rect(), Rect2(-96, -48, 192, 96), "solid footprint stays fixed")
		for child in block.get_children():
			if child is CollisionShape2D:
				check_eq(child.position, Vector2.ZERO, "collision stays centred")
		await dispose(block)
	await dispose(arena)


func _walk(action: StringName, duration: float) -> void:
	Input.action_press(action)
	await seconds(duration)
	Input.action_release(action)
	await seconds(0.8)


func _entrance(id: StringName, target: StringName, centre: Vector2, gated: bool) -> void:
	reset_state()
	var world := await make_world()
	world.start_at(id)
	await frames(3)
	var room := world.get_room(id)
	var door: RoomDoor
	var hut: SolidBlock
	var blocker: Node2D
	for prop in room.get_node("Props").get_children():
		if prop is RoomDoor:
			door = prop
		elif prop is SolidBlock and prop.kind == &"hut":
			hut = prop
		elif prop.get("burn_id") == &"e129":
			blocker = prop
	check(door != null and hut != null, "%s real house and door exist" % id)
	if door == null or hut == null:
		await dispose(world)
		return
	check_eq(door.position, centre, "%s trigger stays fixed" % id)
	var visual := hut.get_node("Visual") as SpriteVisual
	var threshold := hut.position + visual.position + visual.offset + Vector2(208, 374)
	check_eq(threshold, centre, "%s painted threshold matches real trigger" % id)
	check_eq(door.target_room, target, "%s destination stays fixed" % id)
	check_eq(door.target_spawn, &"Inside", "%s target spawn stays fixed" % id)
	world.player.place_at(room.global_position + centre + Vector2(0, 180))
	if gated:
		await _walk(&"move_up", 0.8)
		check_eq(world.get_current_room_id(), id, "intact thorn gate stops normal walking")
		check(not GameState.has_flag(&"burned_e129"), "walking cannot open the gate")
		GameState.acquire_item(&"cinder_wick")
		GameState.set_active_item(&"cinder_wick")
		world.player.facing = Vector2.UP
		world.player.use_item()
		await seconds(2.0)
		check(GameState.has_flag(&"burned_e129"), "actual Cinder Wick burns gate persistently")
		check(blocker.get("is_open"), "authoritative gate opens")
	await _walk(&"move_up", 0.9)
	check_eq(world.get_current_room_id(), target, "%s normal walking enters painted door" % id)
	if world.get_current_room_id() == target:
		await _walk(&"move_down", 2.0)
		check_eq(world.get_current_room_id(), id, "%s reverse exit returns outside" % id)
		if gated:
			check(GameState.has_flag(&"burned_e129"), "burn flag survives return")
			await _walk(&"move_up", 1.5)
			check_eq(world.get_current_room_id(), target, "open gate remains usable on revisit")
	await dispose(world)
