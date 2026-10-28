## timeout=360
extends "res://tests/test_route_cave_1.gd"
## Controlled integration probe: real C01 acquisition first; positioned combat/tool starts,
## regular enemies removed, hurtbox disabled. Walking covers gate approaches and transitions,
## not a continuous human playthrough. No progression flags or items are injected.


func run() -> void:
	await super.run()
	# C01 leaves real acquired moth, pot, cinder wick and its earned persistent state.
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	await r2_border()
	await r2_grate()
	await r2_secret(&"ow_4_1", &"ow_4_1#cache", "cracked_wall.gd")
	await r2_secret(&"ow_6_0", &"ow_6_0#shop", "cracked_wall.gd")
	await r2_secret(&"ow_3_3", &"ow_3_3#hut", "burnable.gd")
	await r2_secret(&"ow_7_2", &"ow_7_2#bag", "cracked_wall.gd")
	await r2_ledge()
	await r2_shores()
	await r2_sling_source()
	await r2_save()
	await dispose(world)


func r2_border() -> void:
	var room := await enter(&"ow_2_0")
	var hedge = scripted(room, "burnable.gd")
	check(not hedge.is_open, "C01 acquisition did not inject border progress")
	player.place_at(room.global_position + Vector2(1740, 480))
	Input.action_press(&"move_right")
	await seconds(.5)
	release_inputs()
	check_eq(world.get_current_room_id(), &"ow_2_0", "closed border stops actual travel")
	await swing(hedge)
	check(not hedge.is_open, "hook cannot replace acquired cinder wick")
	GameState.set_active_item(&"cinder_wick")
	player.place_at(hedge.global_position - Vector2(180, 0))
	player.facing = Vector2.RIGHT
	check(player.use_item(), "acquired C01 wick casts at border")
	await seconds(1.8)
	check(hedge.is_open, "actual fire opens e005")
	player.place_at(room.global_position + Vector2(1740, 480))
	await cross(&"move_right", &"ow_3_0")
	room = await enter(&"ow_3_0")
	check(scripted(room, "burnable.gd").is_open, "paired arrival hedge opens from shared flag")
	await walk(Vector2(240, 480))
	await cross(&"move_left", &"ow_2_0")
	check(GameState.has_flag(&"burned_e005"), "actual paired roundtrip retains burn")


func r2_grate() -> void:
	var room := await enter(&"ow_3_2")
	var door := scripted(room, "room_door.gd") as RoomDoor
	player.place_at(door.global_position + Vector2(0, 100))
	Input.action_press(&"move_up")
	await seconds(.8)
	release_inputs()
	await seconds(.5)
	check_eq(world.get_current_room_id(), &"ow_3_2#grate", "real vine alcove door enters pocket")
	room = await enter(&"ow_3_2#grate")
	await r2_capture("grate-closed")
	var before := GameState.keys_in(&"ow")
	player.place_at(room.global_position + Vector2(912, 480))
	Input.action_press(&"move_up")
	await seconds(.7)
	release_inputs()
	check(player.global_position.y - room.global_position.y > 360, "permanent grate blocks body")
	check_eq(GameState.keys_in(&"ow"), before, "walking cannot collect sealed key")
	player.place_at(room.global_position + Vector2(912, 432))
	player.facing = Vector2.UP
	GameState.set_active_item(&"tether_moth")
	await frames(3)
	check(player.use_item(), "acquired moth launches across permanent grate")
	await seconds(1.8)
	check_eq(GameState.keys_in(&"ow"), before + 1, "real carried key credits ow scope")
	check_eq(GameState.keys_in(&"c2"), 0, "overworld key never credits C02")
	check(GameState.has_flag(&"picked_key_ow_2"), "actual grated key pickup persists")
	await r2_capture("grate-fetched")
	await r2_return(&"ow_3_2")


func r2_secret(host: StringName, pocket: StringName, script: String) -> void:
	var room := await enter(host)
	var seal = scripted(room, script)
	var door := scripted(room, "room_door.gd") as RoomDoor
	check(not seal.is_open, "%s secret starts sealed" % host)
	player.place_at(door.global_position)
	await frames(6)
	check_eq(world.get_current_room_id(), host, "sealed pocket rejects trigger overlap")
	await swing(seal)
	check(not seal.is_open, "hook preserves hidden-tool challenge")
	var flame := script == "burnable.gd"
	GameState.set_active_item(&"cinder_wick" if flame else &"pitch_pot")
	player.place_at(seal.global_position + Vector2(0, 82))
	player.facing = Vector2.UP
	await frames(3)
	check(player.use_item(), "actual acquired tool used on %s" % host)
	await seconds(1.9)
	check(seal.is_open, "actual tool opens %s" % pocket)
	player.place_at(door.global_position + Vector2(0, 100))
	Input.action_press(&"move_up")
	await seconds(.8)
	release_inputs()
	await seconds(.5)
	check_eq(world.get_current_room_id(), pocket, "walking enters opened pocket")
	room = await enter(pocket)
	await r2_capture(String(pocket).replace("#", "-"))
	var max_before := GameState.max_health
	for node in room.get_node("Props").get_children():
		if is_instance_valid(node) and node is PickupBase:
			player.place_at(node.global_position + Vector2(0, 35))
			await frames(5)
	if pocket == &"ow_6_0#shop":
		for stock in room.get_node("Props").get_children():
			if stock.get("stock") == &"ember":
				GameState.damage(2)
				var brass := GameState.currency
				var hp := GameState.health
				player.place_at(stock.global_position + Vector2(0, 35))
				await frames(5)
				check_eq(GameState.currency, brass - 8, "real S2 ember costs eight earned brass")
				check_eq(GameState.health, hp + 2, "actual S2 purchase heals one heart")
	if pocket == &"ow_3_3#hut":
		check_eq(GameState.max_health, max_before + 2, "actual hermit core increases max health")
	if pocket == &"ow_7_2#bag":
		check(GameState.has_flag(&"pot_bag_1"), "actual wreck bag collected")
		check_eq(GameState.pot_max(), 14, "actual first bag adds four capacity")
	if pocket == &"ow_4_1#cache":
		check(GameState.has_flag(&"picked_cache_ow_4_1_brass"), "real cache brass collected")
	await r2_return(host)
	room = await enter(host)
	check(scripted(room, script).is_open, "secret remains open after pocket return")


func r2_return(host: StringName) -> void:
	var room := world.get_room(world.get_current_room_id())
	var exit := scripted(room, "room_door.gd") as RoomDoor
	player.place_at(exit.global_position - Vector2(0, 100))
	Input.action_press(&"move_down")
	await seconds(.8)
	release_inputs()
	await seconds(.5)
	check_eq(world.get_current_room_id(), host, "actual pocket return targets host")
	room = world.get_room(host)
	check(
		(
			(player.global_position - room.global_position).distance_to(
				room.get_node("Spawns/FromPocket").position
			)
			< 60
		),
		"return lands at clear FromPocket marker"
	)


func r2_ledge() -> void:
	var room := await enter(&"ow_4_2")
	player.place_at(room.global_position + Vector2(960, 700))
	await walk(Vector2(960, 820))
	await cross(&"move_down", &"ow_4_3")
	room = world.get_room(&"ow_4_3")
	player.place_at(room.global_position + Vector2(960, 160))
	Input.action_press(&"move_up")
	await seconds(1)
	release_inputs()
	check_eq(world.get_current_room_id(), &"ow_4_3", "Drop Ledge cannot be climbed in reverse")


func r2_sling_source() -> void:
	var room := await enter(&"ow_7_1")
	var eye = scripted(room, "eye_switch.gd")
	await swing(eye)
	check(not GameState.has_flag(&"eye_e028"), "hook cannot open Eyegate before sling")
	player.place_at(room.global_position + Vector2(1740, 480))
	Input.action_press(&"move_right")
	await seconds(.7)
	release_inputs()
	check_eq(world.get_current_room_id(), &"ow_7_1", "closed Eyegate physically blocks east")
	room = await enter(&"ow_5_1")
	var mouth := scripted(room, "room_door.gd") as RoomDoor
	if not ResourceLoader.exists(WorldData.scene_path("cave_2_5")):
		print("PENDING R2: actual C02 sling source unavailable; no substitute loadout")
		return
	player.place_at(mouth.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_2_1", "actual Briar Mouth enters available C02")
	room = await enter(&"cave_2_1")
	check(GameState.has_flag(&"mouth_c2"), "real mouth entry sets save flag")
	var exit := scripted(room, "room_door.gd") as RoomDoor
	player.place_at(exit.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"ow_5_1", "actual C02 exit returns to Briar Mouth")
	room = world.get_room(&"ow_5_1")
	check(
		(
			(player.global_position - room.global_position).distance_to(
				room.get_node("Spawns/FromCave").position
			)
			< 60
		),
		"C02 return uses FromCave"
	)
	mouth = scripted(room, "room_door.gd") as RoomDoor
	player.place_at(mouth.global_position)
	await seconds(1)
	room = await enter(&"cave_2_1")
	player.place_at(room.global_position + Vector2(1680, 480))
	await cross(&"move_right", &"cave_2_2")
	room = await enter(&"cave_2_2")
	var lock := scripted(room, "locked_door.gd") as LockedDoor
	player.place_at(room.global_position + Vector2(1740, 480))
	Input.action_press(&"move_right")
	await seconds(.6)
	release_inputs()
	check(not lock.is_open, "real ow key cannot open c2 lock")
	check_eq(GameState.keys_in(&"ow"), 1, "wrong-scope rejection preserves fetched ow key")
	var hedge = scripted(room, "burnable.gd")
	GameState.set_active_item(&"cinder_wick")
	player.place_at(hedge.global_position + Vector2(0, 180))
	player.facing = Vector2.UP
	check(player.use_item(), "real C01 wick opens C02 source route")
	await seconds(1.8)
	player.place_at(room.global_position + Vector2(960, 180))
	await cross(&"move_up", &"cave_2_3")
	room = await enter(&"cave_2_3")
	player.place_at(pickup(room, &"key_c2_1").global_position)
	await frames(5)
	check_eq(GameState.keys_in(&"c2"), 1, "actual C02 nook key collected")
	player.place_at(room.global_position + Vector2(960, 780))
	await cross(&"move_down", &"cave_2_2")
	room = await enter(&"cave_2_2")
	player.place_at(room.global_position + Vector2(1740, 480))
	await cross(&"move_right", &"cave_2_4")
	room = await enter(&"cave_2_4")
	check_eq(GameState.keys_in(&"c2"), 0, "actual C02 lock spends matching key")
	check(scripted(room, "locked_door.gd").is_open, "C02 paired lock shares actual spend")
	var warden = room.get_enemies()[0]
	for attempt in range(24):
		if not is_instance_valid(warden) or warden.is_dead:
			break
		player.place_at(warden.global_position - Vector2(180, 0))
		player.facing = Vector2.RIGHT
		GameState.set_active_item(&"cinder_wick")
		player.use_item()
		await seconds(.9)
	await seconds(1.6)
	check(GameState.has_flag(&"mini_cave_2_4"), "actual acquired fire defeats assembled Warden")
	player.place_at(room.global_position + Vector2(1680, 480))
	await cross(&"move_right", &"cave_2_5")
	room = await enter(&"cave_2_5")
	player.place_at(pickup(room, &"tallow_sling").global_position + Vector2(0, 46))
	await frames(5)
	check(GameState.has_item(&"tallow_sling"), "actual C02 pedestal grants sling")
	room = await enter(&"ow_7_1")
	eye = scripted(room, "eye_switch.gd")
	GameState.set_active_item(&"tallow_sling")
	player.place_at(eye.global_position - Vector2(200, 0))
	player.facing = Vector2.RIGHT
	var ammo := GameState.slugs
	check(player.use_item(), "actual acquired sling fires at Eyegate")
	await seconds(.7)
	check(GameState.has_flag(&"eye_e028"), "actual slug opens Eyegate persistently")
	check_eq(GameState.slugs, ammo - 1, "Eyegate consumes one actual slug")
	await r2_capture("eyegate-open")
	await enter(&"ow_7_0")
	room = await enter(&"ow_7_1")
	check(scripted(room, "eye_switch.gd").is_on, "Eyegate remains on after actual reload")
	if ResourceLoader.exists(WorldData.scene_path("ow_8_1")):
		player.place_at(room.global_position + Vector2(1740, 480))
		await cross(&"move_right", &"ow_8_1")
		room = await enter(&"ow_8_1")
		check(scripted(room, "eye_switch.gd").is_on, "paired Cinderflats eye shares opened state")
	else:
		print("PENDING R2: open Eyegate boundary awaits actual ow_8_1; no absent region claimed")


func r2_save() -> void:
	var flags: Dictionary = GameState.flags.duplicate(true)
	check(not SaveGame.enabled, "controlled route never writes user's save")
	# Runner supplies an isolated temporary userdata root for each suite.
	check(isolated_test_profile(), "save probe isolated from user slot")
	if not isolated_test_profile():
		return
	SaveGame.enabled = true
	check(SaveGame.save(), "actual R2 flags save to isolated disk slot")
	reset_state()
	SaveGame.enabled = true
	check(SaveGame.load_into_state(), "actual R2 save reloads")
	check_eq(GameState.flags, flags, "earned gates pickups mouth and bag flags survive save")
	check_eq(GameState.keys_in(&"ow"), 1, "save retains actual unspent overworld key")
	SaveGame.enabled = false


func r2_shores() -> void:
	check(not GameState.has_item(&"reed_raft"), "route has not injected future C03 raft")
	for probe in [
		[&"ow_6_1", Vector2(960, 780), &"move_down"],
		[&"ow_5_2", Vector2(1740, 480), &"move_right"],
		[&"ow_5_2", Vector2(960, 780), &"move_down"],
		[&"ow_7_2", Vector2(180, 480), &"move_left"],
		[&"ow_7_2", Vector2(960, 780), &"move_down"],
	]:
		var room := await enter(probe[0])
		player.place_at(room.global_position + probe[1])
		Input.action_press(probe[2])
		await seconds(.8)
		release_inputs()
		check_eq(world.get_current_room_id(), probe[0], "actual water blocks unrafted shore")
	print("PENDING R2: acquired-raft crossings require future C03; only closed shores accepted")


func r2_capture(label: String) -> void:
	if OS.get_environment("WICK_R2_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		get_viewport().get_texture().get_image().save_png("/tmp/wick-r2-" + label + ".png"),
		OK,
		"actual R2 state capture"
	)
