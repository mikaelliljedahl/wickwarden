## timeout=600
extends "res://tests/test_route_cave_3.gd"
## In-progress Q3 shard: earned C1-C2 state continues into C3, C4 and C5. Positioned
## starts, room warps and removal of regular enemies follow the route helpers.
## The raft crosses the two real lake edges before the C5 mouth.


func run() -> void:
	var start_frame := Engine.get_physics_frames()
	var previous_script := load("res://tests/test_playthrough_1.gd") as GDScript
	check(previous_script != null, "previous earned-route shard loads")
	if previous_script == null:
		return
	var previous := previous_script.new() as TestCase
	add_child(previous)
	await previous.run()
	checks += previous.checks
	for failure in previous.failures:
		failures.append("C1-C2: " + failure)
	await dispose(previous)
	check(GameState.has_fragment(&"c1"), "earned first fragment is retained")
	check(GameState.has_fragment(&"c2"), "earned second fragment is retained")
	check(GameState.has_item(&"pitch_pot"), "earned pot is retained")
	if not failures.is_empty():
		return
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	await cave_three()
	check(GameState.has_fragment(&"c1"), "C1 fragment survives C3")
	check(GameState.has_fragment(&"c2"), "C2 fragment survives C3")
	check(GameState.has_fragment(&"c3"), "Tidewick drops the earned third fragment")
	check(GameState.has_flag(&"boss_cave_3_9_defeated"), "Tidewick is defeated")
	await dispose(world)
	if not failures.is_empty() or not await save_c3():
		return
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	await cave_four()
	check(GameState.has_fragment(&"c3"), "C3 fragment survives C4")
	check(GameState.has_fragment(&"c4"), "Colossus drops the earned fourth fragment")
	check(GameState.has_flag(&"boss_cave_4_10_defeated"), "Colossus is defeated")
	if failures.is_empty():
		var rootbridge := await enter(&"ow_6_1")
		await ride(rootbridge, &"ow_6_2", &"e027")
		await ride(world.get_room(&"ow_6_2"), &"ow_6_3", &"e045")
		check_eq(world.get_current_room_id(), &"ow_6_3", "earned raft reaches Lantern Isle")
	if failures.is_empty():
		await cave_five()
	check(GameState.has_fragment(&"c5"), "Archivist drops the earned fifth fragment")
	check(GameState.has_flag(&"boss_cave_5_10_defeated"), "Archivist is defeated")
	print("C1-C5 simulated play time: %.2f seconds" % ((Engine.get_physics_frames() - start_frame) / 60.0))
	await dispose(world)
	SaveGame.enabled = false


func save_c3() -> bool:
	var safe := isolated_test_profile()
	check(safe, "C3 save requires isolated test userdata")
	if not safe:
		return false
	var before := summary()
	SaveGame.enabled = true
	var saved := SaveGame.save()
	check(saved, "earned C3 state saves")
	if not saved:
		SaveGame.enabled = false
		return false
	reset_state()
	var loaded := SaveGame.load_into_state()
	check(loaded, "earned C3 state reloads")
	if loaded:
		check_eq(summary(), before, "C3 state survives save and reload")
	SaveGame.enabled = false
	return loaded


func cave_three() -> void:
	var room := await enter(&"ow_3_5")
	var wall = scripted(room, "cracked_wall.gd")
	var door := door_to(room, &"cave_3_1")
	await bomb(wall)
	check(wall.is_open, "earned pot opens the C3 mouth")
	player.place_at(door.global_position + Vector2(0, 100))
	await frames(3)
	player.place_at(door.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_3_1", "actual mouth enters C3")
	room = world.get_room(&"cave_3_1")
	player.place_at(room.global_position + Vector2(1680, 480))
	await cross(&"move_right", &"cave_3_2")
	room = world.get_room(&"cave_3_2")
	await cut_moss(room)
	player.place_at(room.global_position + Vector2(960, 200))
	await cross(&"move_up", &"cave_3_3")
	room = world.get_room(&"cave_3_3")
	await collect(room, &"key_c3_1")
	check_eq(GameState.keys_in(&"c3"), 1, "C3 key is collected")
	await cut_moss(room)
	player.place_at(room.global_position + Vector2(960, 740))
	await cross(&"move_down", &"cave_3_2")
	room = world.get_room(&"cave_3_2")
	await contact(scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check_eq(GameState.keys_in(&"c3"), 0, "C3 lock spends its real key")
	await cross(&"move_right", &"cave_3_4")
	room = world.get_room(&"cave_3_4")
	await lurker(room)
	player.place_at(room.global_position + Vector2(1680, 480))
	await cross(&"move_right", &"cave_3_5")
	room = world.get_room(&"cave_3_5")
	await collect(room, &"reed_raft")
	check(GameState.has_item(&"reed_raft"), "C3 pedestal grants the real raft")
	await ride(room, &"cave_3_6", &"e167")
	room = world.get_room(&"cave_3_6")
	await collect(room, &"bigkey_c3")
	check(GameState.has_big_key(&"c3"), "C3 Lockpick is collected")
	await ride(room, &"cave_3_7", &"e168")
	room = world.get_room(&"cave_3_7")
	await cut_hidden_core(room)
	if not GameState.has_flag(&"picked_wick_core_c3_hidden"):
		await collect(room, &"wick_core_c3_hidden")
	check(GameState.has_flag(&"picked_wick_core_c3_hidden"), "hidden C3 heart is collected")
	await ride(room, &"cave_3_6", &"e168")
	await ride(world.get_room(&"cave_3_6"), &"cave_3_5", &"e167")
	room = world.get_room(&"cave_3_5")
	player.place_at(room.global_position + Vector2(960, 740))
	await cross(&"move_down", &"cave_3_8")
	room = world.get_room(&"cave_3_8")
	await contact(scripted(room, "boss_door.gd"), Vector2.RIGHT)
	await cross(&"move_right", &"cave_3_9")
	await tidewick(world.get_room(&"cave_3_9"))


func cave_four() -> void:
	var script := load("res://tests/test_route_cave_4.gd") as GDScript
	check(script != null, "C4 helpers load")
	if script == null:
		return
	var route = script.new()
	add_child(route)
	route.world = world
	route.player = player
	var room: Room = await route.enter(&"ow_9_2")
	var mouth: RoomDoor = route.door_to(room, &"cave_4_1")
	player.place_at(mouth.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_4_1", "actual mouth enters C4")
	room = await route.enter(&"cave_4_2")
	var eye = route.eye_switch(room)
	await route.cast(eye, &"tallow_sling", Vector2.UP, 150)
	await seconds(0.5)
	check(eye.is_on, "earned sling opens the C4 eye")
	player.place_at(room.global_position + Vector2(960, 200))
	await route.cross(&"move_up", &"cave_4_3")
	room = world.get_room(&"cave_4_3")
	await route.collect(room, &"key_c4_1")
	player.place_at(room.global_position + Vector2(960, 740))
	await route.cross(&"move_down", &"cave_4_2")
	room = world.get_room(&"cave_4_2")
	await route.contact(route.scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check_eq(GameState.keys_in(&"c4"), 0, "first C4 lock spends its real key")
	await route.cross(&"move_right", &"cave_4_4")
	room = world.get_room(&"cave_4_4")
	await route.mauler(room)
	player.place_at(room.global_position + Vector2(1680, 480))
	await route.cross(&"move_right", &"cave_4_5")
	room = world.get_room(&"cave_4_5")
	await route.collect(room, &"heft_mitts")
	check(GameState.has_item(&"heft_mitts"), "C4 pedestal grants the real mitts")
	await route.lift_throw(route.scripted(room, "heavy_stone.gd"), Vector2.UP)
	await seconds(0.9)
	check(GameState.has_flag(&"moved_e175"), "earned mitts open the heavy gate")
	player.place_at(room.global_position + Vector2(960, 200))
	await route.cross(&"move_up", &"cave_4_6")
	room = world.get_room(&"cave_4_6")
	await route.collect(room, &"key_c4_2")
	player.place_at(room.global_position + Vector2(960, 740))
	await route.cross(&"move_down", &"cave_4_5")
	room = world.get_room(&"cave_4_5")
	player.place_at(room.global_position + Vector2(960, 740))
	await route.cross(&"move_down", &"cave_4_7")
	room = world.get_room(&"cave_4_7")
	await route.contact(route.scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check_eq(GameState.keys_in(&"c4"), 0, "second C4 lock spends its real key")
	await route.cross(&"move_right", &"cave_4_8")
	room = world.get_room(&"cave_4_8")
	await route.collect(room, &"bigkey_c4")
	check(GameState.has_big_key(&"c4"), "C4 Lockpick is collected")
	player.place_at(room.global_position + Vector2(240, 480))
	await route.cross(&"move_left", &"cave_4_7")
	room = world.get_room(&"cave_4_7")
	player.place_at(room.global_position + Vector2(240, 480))
	await route.cross(&"move_left", &"cave_4_9")
	room = world.get_room(&"cave_4_9")
	await route.contact(route.scripted(room, "boss_door.gd"), Vector2.DOWN)
	await route.cross(&"move_down", &"cave_4_10")
	await route.colossus(world.get_room(&"cave_4_10"))
	checks += route.checks
	for failure in route.failures:
		failures.append("C4: " + failure)
	await dispose(route)


func cave_five() -> void:
	var script := load("res://tests/test_route_cave_5.gd") as GDScript
	check(script != null, "C5 helpers load")
	if script == null:
		return
	var route = script.new()
	add_child(route)
	route.world = world
	route.player = player
	player.set_hurtbox_enabled(self, true)
	player.set_hurtbox_enabled(route, false)
	await route.mouth()
	var room: Room = await route.enter(&"cave_5_2")
	await route.vines(room)
	await route.edge(&"cave_5_2", &"cave_5_3", Vector2.UP)
	room = world.get_room(&"cave_5_3")
	await route.collect(room, &"key_c5_1")
	await route.vines(room)
	await route.edge(&"cave_5_3", &"cave_5_2", Vector2.DOWN)
	room = world.get_room(&"cave_5_2")
	await route.contact(route.scripted(room, "locked_door.gd"), Vector2.LEFT)
	check_eq(GameState.keys_in(&"c5"), 0, "first C5 lock spends its real key")
	await route.edge(&"cave_5_2", &"cave_5_4", Vector2.LEFT)
	await route.warden_and_jar()
	room = await route.enter(&"cave_5_5")
	var seam = route.scripted(room, "hidden_seam.gd")
	await route.throw_jar(room.global_position + Vector2(960, 432), Vector2.UP)
	await seconds(1.8)
	check(seam.is_revealed, "earned jar reveals the hidden C5 passage")
	await route.edge(&"cave_5_5", &"cave_5_6", Vector2.UP)
	room = world.get_room(&"cave_5_6")
	await route.collect(room, &"key_c5_2")
	await route.edge(&"cave_5_6", &"cave_5_5", Vector2.DOWN)
	await route.edge(&"cave_5_5", &"cave_5_7", Vector2.DOWN)
	room = world.get_room(&"cave_5_7")
	await route.contact(route.scripted(room, "locked_door.gd"), Vector2.LEFT)
	check_eq(GameState.keys_in(&"c5"), 0, "second C5 lock spends its real key")
	await route.edge(&"cave_5_7", &"cave_5_8", Vector2.LEFT)
	room = world.get_room(&"cave_5_8")
	await route.collect(room, &"bigkey_c5")
	check(GameState.has_big_key(&"c5"), "C5 Lockpick is collected")
	await route.edge(&"cave_5_8", &"cave_5_7", Vector2.RIGHT)
	await route.edge(&"cave_5_7", &"cave_5_9", Vector2.RIGHT)
	room = world.get_room(&"cave_5_9")
	await route.contact(route.scripted(room, "boss_door.gd"), Vector2.DOWN)
	await route.edge(&"cave_5_9", &"cave_5_10", Vector2.DOWN)
	await route.last_page()
	checks += route.checks
	for failure in route.failures:
		failures.append("C5: " + failure)
	await dispose(route)
