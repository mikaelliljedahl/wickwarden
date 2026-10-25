## timeout=240
extends "res://tests/test_dev_world_route.gd"
## Controlled room-entry acceptance, not an earned or continuous full-game playthrough.
## Pot is earned on the historical route. Mitts/raft/boots are a controlled late kit:
## their cave acquisition routes are unbuilt. No gate or reveal flags are injected.
## Enemies are removed without drops except the real watcher used for the ward puzzle.


func run() -> void:
	reset_state()
	world = await make_world()
	player = world.player
	await _tether_moth()
	await _cave_gate_and_key()
	await _locked_door_and_pitch_pot()
	await _cache()
	await _shop()
	await _ward_cache()
	await _rush_wall()
	await _plain_boundaries()
	await _drop()
	await _boulder()
	await _paired_stones()
	await _rafts()
	await _ravines()
	await _saved_reload()
	print("PENDING R5: C6 destination absent; late kit does not prove earning cave tools")
	release_inputs()
	await dispose(world)


func _walk(action: StringName, duration: float) -> void:
	Input.action_press(action)
	await seconds(duration)
	Input.action_release(action)
	await seconds(0.6)


func _door(room: Room, target: StringName) -> RoomDoor:
	for node in _props(room):
		if node is RoomDoor and node.target_room == target:
			return node
	return null


func _through(room: Room, target: StringName) -> void:
	var door := _door(room, target)
	check(door != null, "real door exists to %s" % target)
	if door == null:
		return
	var inside := "#" in String(room.room_id)
	player.place_at(door.global_position + Vector2(0, -96 if inside else 96))
	await frames(5)
	await _walk(&"move_down" if inside else &"move_up", 1.0)
	check_eq(world.get_current_room_id(), target, "walk through actual door to %s" % target)


func _cache() -> void:
	var room := await _enter(&"ow_4_8")
	var wall := _find(room, "cracked_wall.gd")
	player.place_at(room.global_position + Vector2(1296, 816))
	await _walk(&"move_up", 0.7)
	check_eq(world.get_current_room_id(), &"ow_4_8", "sealed cache refuses walking")
	await _swing_at(wall.global_position, Vector2.UP)
	check(not wall.is_open, "hook cannot break bomb seal")
	player.place_at(room.global_position + Vector2(1296, 816))
	player.facing = Vector2.UP
	var pots := GameState.pitch_pots
	check(player.use_item(), "earned pot places actual cache bomb")
	player.place_at(room.global_position + Vector2(1104, 816))
	await seconds(3.0)
	check_eq(GameState.pitch_pots, pots - 1, "cache costs one pot")
	check(GameState.has_flag(&"cracked_ow_4_8_cache"), "blast persists cache opening")
	player.place_at(room.global_position + Vector2(1296, 816))
	await _walk(&"move_up", 1.25)
	check_eq(world.get_current_room_id(), &"ow_4_8#cache", "opened niche enters real cache")
	var pocket := world.get_room(&"ow_4_8#cache")
	var core := _pickup(pocket, &"wick_core_ow_4_8")
	check(core != null, "cache contains exact graph core")
	var health := GameState.max_health
	if core != null:
		await _walk_onto(core)
	check_eq(GameState.max_health, health + 2, "core adds one heart")
	await _through(pocket, &"ow_4_8")
	await _enter(&"ow_0_0")
	room = await _enter(&"ow_4_8")
	check(_find(room, "cracked_wall.gd").is_open, "bomb seal stays open on reload")


func _shop() -> void:
	var room := await _enter(&"ow_5_7")
	await _through(room, &"ow_5_7#shop")
	var shop := world.get_room(&"ow_5_7#shop")
	var stock: Node2D
	var count := 0
	for node in _props(shop):
		if node.get_script() != null and node.get_script().resource_path.ends_with("shop_item.gd"):
			count += 1
			if node.get("stock") == &"slug_bundle":
				stock = node
	check_eq(count, 4, "S4 has all four graph wares")
	check(stock != null, "S4 supplies limited sling ammo")
	if stock != null:
		GameState.spend_currency(GameState.currency)
		GameState.acquire_item(&"tallow_sling")
		var slugs := GameState.slugs
		player.place_at(stock.global_position)
		await frames(5)
		check_eq(GameState.slugs, slugs, "unaffordable bundle refuses purchase")
		GameState.add_currency(100)
		player.place_at(stock.global_position + Vector2(0, 100))
		await frames(4)
		player.place_at(stock.global_position)
		await frames(4)
		check_eq(GameState.slugs, slugs + 6, "real S4 purchase grants six slugs")
		check(GameState.currency < 100, "S4 charges brass")
	await _through(shop, &"ow_5_7")


func _ward_cache() -> void:
	world.start_at(&"ow_8_5")
	await frames(3)
	var room := world.get_room(&"ow_8_5")
	for enemy in room.get_enemies():
		if enemy.name != &"WatcherEye1":
			enemy.queue_free()
	var pad := _find(room, "ward_plate.gd")
	var door := _door(room, &"ow_8_5#ward")
	player.place_at(door.global_position)
	await frames(4)
	check_eq(world.get_current_room_id(), &"ow_8_5", "unearned ward secret refuses overlap")
	player.place_at(pad.global_position)
	player.facing = Vector2.RIGHT
	Input.action_press(&"ward")
	for tick in range(900):
		await frames(1)
		if pad.get("is_satisfied"):
			break
	Input.action_release(&"ward")
	check_eq(pad.get("blocks_absorbed"), 3, "three actual watcher shots satisfy ward")
	await _proof("earned-ward")
	check(GameState.has_flag(&"ward_e257"), "actual blocks persist ward completion")
	player.place_at(room.global_position + Vector2(432, 624))
	await _walk(&"move_up", 0.8)
	check_eq(world.get_current_room_id(), &"ow_8_5#ward", "ward opens physical secret entry")
	var pocket := world.get_room(&"ow_8_5#ward")
	var reward := _pickup(pocket, &"cache_ow_8_5_ward_brass")
	check(reward != null, "ward pocket contains brass reward")
	if reward != null:
		await _walk_onto(reward)
	await _through(pocket, &"ow_8_5")


func _rush_wall() -> void:
	var room := await _enter(&"ow_3_7")
	player.place_at(room.global_position + Vector2(180, 480))
	await _walk(&"move_left", 1.0)
	check_eq(world.get_current_room_id(), &"ow_3_7", "uncut rush border refuses walking")
	for node in _props(room):
		if is_instance_valid(node) and node is Bush:
			node.drops_enabled = false
			await _swing_at(node.global_position, Vector2.LEFT)
	player.place_at(room.global_position + Vector2(180, 480))
	await _walk(&"move_left", 1.0)
	# The opposite endpoint has its own physical cut screen, handled by its real hook.
	check_eq(world.get_current_room_id(), &"ow_2_7", "hook-cut rush border enters actual Last Pier")


func _plain_boundaries() -> void:
	var area := load("res://tests/test_area_gravelight.gd") as GDScript
	check(area != null, "regional room list loads")
	if area == null:
		return
	var data: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string("res://data/world_data.json")
	)
	for edge: Dictionary in data["edges"]:
		if edge["link"] != "step" or edge["gate"] != null:
			continue
		if not edge["a"] in area.REGION:
			continue
		for pair in [[edge["a"], edge["b"]], [edge["b"], edge["a"]]]:
			var room := await _enter(StringName(pair[0]))
			var delta := WorldData.grid(pair[1]) - WorldData.grid(pair[0])
			var at := Vector2(960, 480)
			var action := &"move_right"
			if delta.x != 0:
				at.x = 1740 if delta.x > 0 else 180
				action = &"move_right" if delta.x > 0 else &"move_left"
			else:
				at.y = 780 if delta.y > 0 else 180
				action = &"move_down" if delta.y > 0 else &"move_up"
			player.place_at(room.global_position + at)
			await _walk(action, 1.0)
			check_eq(
				String(world.get_current_room_id()), pair[1], "reciprocal walk %s -> %s" % pair
			)


func _drop() -> void:
	var room := await _enter(&"ow_4_5")
	player.place_at(room.global_position + Vector2(960, 780))
	await _walk(&"move_down", 1.0)
	check_eq(world.get_current_room_id(), &"ow_4_6", "Dockside drops to actual Cliff Foot")
	room = await _enter(&"ow_4_6")
	player.place_at(room.global_position + Vector2(960, 180))
	await _walk(&"move_up", 1.0)
	check_eq(world.get_current_room_id(), &"ow_4_6", "drop cannot be climbed backwards")


func _push(room: Room, at: Vector2, direction: Vector2, action: StringName) -> void:
	player.place_at(room.global_position + at)
	player.facing = direction
	await frames(3)
	Input.action_press(action)
	check(player.use_item(), "real mitts grab starts push")
	await seconds(1.9)
	Input.action_release(action)
	await seconds(0.4)


func _boulder() -> void:
	var room := await _enter(&"ow_6_6")
	var stone := _find(room, "heavy_stone.gd")
	var door := _door(room, &"cave_6_1")
	player.place_at(room.global_position + Vector2(1410, 432))
	await _walk(&"move_right", 0.8)
	check_eq(stone.get("path"), "", "walking without mitts cannot push")
	check(not door._gate_is_open(), "C6 mouth requires actual clearance")
	GameState.add_key(1, &"c6")
	await _swing_at(stone.global_position, Vector2.RIGHT)
	check(not door._gate_is_open(), "hook and cave-scoped key cannot substitute for mitts")
	GameState.acquire_item(&"heft_mitts")
	GameState.set_active_item(&"heft_mitts")
	await _push(room, Vector2(1488, 510), Vector2.UP, &"move_up")
	check_eq(stone.get("path"), "", "real wall blocks attempted upward push")
	check(not door._gate_is_open(), "blocked push does not unlock C6")
	await _push(room, Vector2(1410, 432), Vector2.RIGHT, &"move_right")
	check(not String(stone.get("path")).is_empty(), "actual mitts move boulder along clear lane")
	check(door._gate_is_open(), "cleared footprint opens linked C6 mouth")
	await _proof("pushed-mouth")
	check(GameState.has_flag(&"moved_cave6door"), "actual push persists moved state")
	check(
		not ResourceLoader.exists(WorldData.scene_path("cave_6_1")),
		"C6 remains explicit future target"
	)


func _paired_stones() -> void:
	var room := await _enter(&"ow_9_4")
	var other := world.get_room(&"ow_9_3")
	var stone := _find(room, "heavy_stone.gd")
	var partner := _find(other, "heavy_stone.gd")
	player.place_at(stone.global_position + Vector2(0, 80))
	player.facing = Vector2.UP
	await frames(3)
	check(player.use_item(), "mitts lift actual e063 stone")
	await seconds(0.5)
	Input.action_press(&"use_item")
	await frames(3)
	Input.action_release(&"use_item")
	await seconds(1.3)
	check(GameState.has_flag(&"moved_e063"), "throw persists shared border opening")
	check(not is_instance_valid(partner), "preloaded reciprocal stone follows earned opening")


func _rafts() -> void:
	GameState.acquire_item(&"reed_raft")
	GameState.set_active_item(&"reed_raft")
	for pair in [
		[&"ow_8_4", &"ow_7_4", &"e075"],
		[&"ow_5_6", &"ow_5_5", &"e089"],
		[&"ow_6_6", &"ow_6_5", &"e090"]
	]:
		for ends in [[pair[0], pair[1]], [pair[1], pair[0]]]:
			var room := await _enter(ends[0])
			var post: Node2D
			for node in _props(room):
				if node.is_in_group(&"mooring") and node.get("mooring_id") == pair[2]:
					post = node
			check(post != null, "graph paired post exists")
			if post == null:
				continue
			var path: Array[Vector2] = post.call("get_ride_path")
			player.place_at(post.call("landing_position"))
			var direction := (post.global_position - player.global_position).normalized()
			player.facing = direction
			await frames(3)
			var action: StringName = &"move_up"
			if absf(direction.x) > absf(direction.y):
				action = &"move_right" if direction.x > 0 else &"move_left"
			else:
				action = &"move_down" if direction.y > 0 else &"move_up"
			await _walk(action, 0.7)
			check_eq(world.get_current_room_id(), ends[0], "raft water refuses walking")
			player.place_at(post.global_position - direction * 64.0)
			await frames(3)
			check(player.use_item(), "late kit boards actual fixed-lane raft")
			await seconds(0.5)
			for tick in range(1800):
				if not player.is_external_motion() and not world.is_transitioning():
					break
				await frames(1)
			check_eq(world.get_current_room_id(), ends[1], "raft reaches reciprocal real endpoint")
			check_near(
				player.global_position.distance_to(path[-1]), 0.0, 3.0, "raft lands at paired post"
			)


func _ravines() -> void:
	GameState.acquire_item(&"skitter_boots")
	GameState.set_active_item(&"skitter_boots")
	for spec in [
		[&"ow_8_6", Vector2(1570, 480), Vector2.RIGHT, &"move_right"],
		[&"ow_9_5", Vector2(960, 610), Vector2.DOWN, &"move_down"]
	]:
		GameState.heal(GameState.max_health)
		var room := await _enter(spec[0])
		player.place_at(room.global_position + spec[1])
		await frames(3)
		var hp := GameState.health
		await _walk(spec[3], 0.27)
		check_eq(GameState.health, hp - 2, "walking into ravine falls for one heart")
		player.place_at(room.global_position + spec[1])
		player.facing = spec[2]
		await frames(3)
		hp = GameState.health
		check(player.use_item(), "actual boots launch across ravine")
		await seconds(0.5)
		check_eq(GameState.health, hp, "boots land without pit damage")
		check_near(
			player.global_position.distance_to(room.global_position + spec[1] + spec[2] * 192),
			0.0,
			3.0,
			"boots reach opposite bank"
		)
		await seconds(0.7)
		player.facing = -spec[2]
		check(player.use_item(), "actual boots launch back")
		await seconds(0.5)
		check_eq(GameState.health, hp, "return leap is safe")
		await seconds(0.6)
		player.facing = spec[2]
		check(player.use_item(), "boots repeat outward leap for boundary traversal")
		await seconds(1.0)
		await _walk(spec[3], 1.0)
		check_eq(
			world.get_current_room_id(), &"ow_9_6", "boots route enters real R6 Ravine Landing"
		)
		var landing := await _enter(&"ow_9_6")
		var at := Vector2(350, 480) if spec[2] == Vector2.RIGHT else Vector2(960, 350)
		player.place_at(landing.global_position + at)
		player.facing = -spec[2]
		await frames(3)
		check(player.use_item(), "boots cross actual reciprocal arrival pit")
		await seconds(1.0)
		await _walk(&"move_left" if spec[2] == Vector2.RIGHT else &"move_up", 1.0)
		check_eq(
			world.get_current_room_id(), spec[0], "R6 bank returns across real regional boundary"
		)


func _saved_reload() -> void:
	# Round-trip real SaveGame schema through a unique /tmp file, never user://save_1.json.
	var path := "/tmp/wick-r5-save-%s.json" % OS.get_process_id()
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(SaveGame._snapshot()))
	file.close()
	var snapshot: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	await dispose(world)
	reset_state()
	SaveGame._restore(snapshot)
	DirAccess.remove_absolute(path)
	world = await make_world()
	player = world.player
	var room := await _enter(&"ow_6_6")
	var stone := _find(room, "heavy_stone.gd")
	check(not String(stone.get("path")).is_empty(), "save restores earned push path")
	check(_door(room, &"cave_6_1")._gate_is_open(), "save restores physical C6 clearance")
	room = await _enter(&"ow_9_4")
	check(_find(room, "heavy_stone.gd") == null, "save restores paired border opening")
	room = await _enter(&"ow_4_8#cache")
	check(_pickup(room, &"wick_core_ow_4_8") == null, "save keeps collected core absent")
	check(GameState.has_flag(&"ward_e257"), "save keeps earned secret reveal")
	check_eq(GameState.keys_in(&"c6"), 1, "wrong-scope key remains unspent through R5 gates")
	check(not SaveGame.enabled, "normal user save remains disabled")


func _proof(label: String) -> void:
	if not OS.get_cmdline_user_args().has("--r5-proof"):
		return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("/tmp/r5-lead-%s.png" % label)
