extends "res://tests/test_dev_world_route.gd"


## Controlled loadout/positioning integration; no claim of earned C04/C05/C08 tools or human play.
## Regular enemies are removed except the three natural ward wisps. No gate flags are injected.
func run() -> void:
	await super.run()
	# Historical route earns moth/pot; later tools below are explicitly controlled loadouts.
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	await court()
	await secrets()
	await open_edges()
	await kiln()
	await bomb_cache()
	await heavy_border()
	await jar_stairs()
	await reel_border()
	await shop()
	await ward_cache()
	await persistence()
	await dispose(world)


func walk(dir: StringName, duration: float) -> void:
	Input.action_press(dir)
	await seconds(duration)
	Input.action_release(dir)
	await frames(3)


func court() -> void:
	var room := await _enter(&"ow_8_1")
	player.place_at(room.global_position + Vector2(220, 480))
	await walk(&"move_left", 0.9)
	check_eq(
		world.get_current_room_id(), &"ow_8_1", "closed court gate blocks physical west traversal"
	)
	GameState.acquire_item(&"tallow_sling")
	print("CONTROLLED R3 loadout: tallow_sling; C02 acquisition tested separately")
	GameState.set_active_item(&"tallow_sling")
	var eye := _find(room, "eye_switch.gd") as Node2D
	player.place_at(eye.global_position + Vector2(240, 0))
	player.facing = Vector2.LEFT
	await frames(3)
	check(player.use_item(), "real sling launches at court eye")
	await seconds(0.7)
	check(GameState.has_flag(&"eye_e028"), "real slug opens paired Eyegate flag")
	player.place_at(room.global_position + Vector2(220, 480))
	await walk(&"move_left", 1.3)
	check_eq(
		world.get_current_room_id(), &"ow_7_1", "opened court gate permits real west traversal"
	)
	room = await _enter(&"ow_8_1")
	player.place_at(room.global_position + Vector2(1800, 480))
	await walk(&"move_right", 1.2)
	check_eq(world.get_current_room_id(), &"ow_9_1", "court east route enters Slag Road")
	room = await _enter(&"ow_9_1")
	player.place_at(room.global_position + Vector2(960, 130))
	await walk(&"move_up", 1.2)
	check_eq(world.get_current_room_id(), &"ow_9_0", "Slag Road north route enters Smoke Terrace")
	room = await _enter(&"ow_9_0")
	player.place_at(room.global_position + Vector2(140, 480))
	await walk(&"move_left", 1.2)
	check_eq(world.get_current_room_id(), &"ow_8_0", "Smoke Terrace west route enters Ash Rim")
	room = await _enter(&"ow_8_0")
	player.place_at(room.global_position + Vector2(960, 820))
	await walk(&"move_down", 1.2)
	check_eq(world.get_current_room_id(), &"ow_8_1", "Ash Rim south route returns to court")


func secrets() -> void:
	for id in [&"ow_8_0", &"ow_9_0"]:
		var room := await _enter(id)
		var x := 384.0 if id == &"ow_8_0" else 1440.0
		var target := StringName(String(id) + "#cache")
		player.place_at(room.global_position + Vector2(x, 456))
		await walk(&"move_up", 0.7)
		check_eq(world.get_current_room_id(), id, "secret stays closed before its actual tool")
		if id == &"ow_8_0":
			await _swing_at(room.global_position + Vector2(x, 336), Vector2.UP)
			check(GameState.has_flag(&"revealed_e131"), "actual hook swing reveals Ash Rim cache")
		else:
			player.place_at(room.global_position + Vector2(x, 406))
			player.facing = Vector2.UP
			Input.action_press(&"attack")
			await frames(57)
			Input.action_release(&"attack")
			await frames(20)
			check(
				GameState.has_flag(&"melted_e132"), "actual charged flare melts Smoke Terrace seal"
			)
		player.place_at(room.global_position + Vector2(x, 456))
		await walk(&"move_up", 1.4)
		check_eq(world.get_current_room_id(), target, "walking crosses real opened secret door")
		if world.get_current_room_id() != target:
			continue
		var pocket := world.get_room(target)
		player.place_at(pocket.global_position + Vector2(1008, 440))
		await walk(&"move_up", 0.4)
		check(
			GameState.has_flag(StringName("picked_cache_" + String(id) + "_brass")),
			"actual cache brass collects"
		)
		player.place_at(pocket.global_position + Vector2(912, 700))
		await walk(&"move_down", 1.1)
		check_eq(
			world.get_current_room_id(), id, "cache return door reaches safe FromPocket marker"
		)
		await seconds(0.5)
		check_eq(world.get_current_room_id(), id, "return marker avoids door bounce")


func ward_cache() -> void:
	await reload_world()
	player.set_hurtbox_enabled(self, true)
	world.start_at(&"ow_9_1")
	var room := world.get_room(&"ow_9_1")
	await frames(3)
	var pad := _find(room, "ward_plate.gd")
	for n in room.get_node("Props").get_children():
		if n.get("blocks_absorbed") != null and not n.blocker:
			pad = n
	player.place_at(room.global_position + Vector2(384, 456))
	await walk(&"move_up", 0.6)
	check_eq(world.get_current_room_id(), &"ow_9_1", "unsolved ward vault prevents entry")
	player.place_at(pad.global_position)
	Input.action_press(&"ward")
	await frames(3)
	# Keep all three authored enemies at their real scene positions, steering only the ward.
	for frame in range(600):
		var nearest: EnemyBase = null
		var distance := INF
		for enemy in room.get_enemies():
			if enemy.is_dead:
				continue
			var d := player.global_position.distance_to(enemy.global_position)
			if d < distance:
				nearest = enemy
				distance = d
		if nearest != null:
			player.facing = player.global_position.direction_to(nearest.global_position)
		await frames(1)
		if pad.is_satisfied:
			break
	check_eq(pad.blocks_absorbed, 3, "three real authored cinder-wisp bursts satisfy pad")
	check(GameState.has_flag(&"ward_e256"), "ward puzzle persists completion")
	await capture("ward-earned")
	Input.action_release(&"ward")
	player.place_at(room.global_position + Vector2(384, 456))
	await walk(&"move_up", 1.7)
	check_eq(
		world.get_current_room_id(), &"ow_9_1#ward", "real opened ward vault permits walking entry"
	)


func reload_world() -> void:
	await dispose(world)
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)


func open_edges() -> void:
	# Physical round trips over every ordinary region edge, starting in its clear edge approach.
	for pair in [
		[&"ow_8_0", &"ow_9_0", true],
		[&"ow_9_0", &"ow_10_0", true],
		[&"ow_8_0", &"ow_8_1", false],
		[&"ow_9_0", &"ow_9_1", false],
		[&"ow_8_1", &"ow_9_1", true],
		[&"ow_9_1", &"ow_10_1", true],
		[&"ow_9_1", &"ow_9_2", false],
		[&"ow_10_1", &"ow_11_1", true],
		[&"ow_10_1", &"ow_10_2", false],
		[&"ow_11_1", &"ow_11_2", false],
		[&"ow_8_2", &"ow_9_2", true],
		[&"ow_9_2", &"ow_10_2", true],
		[&"ow_9_2", &"ow_9_3", false],
		[&"ow_10_2", &"ow_11_2", true],
		[&"ow_10_2", &"ow_10_3", false],
		[&"ow_9_3", &"ow_10_3", true],
		[&"ow_10_3", &"ow_10_4", false],
	]:
		for reverse in [false, true]:
			var room := await _enter(pair[1] if reverse else pair[0])
			var horizontal: bool = pair[2]
			var start := Vector2(150, 480) if reverse else Vector2(1770, 480)
			var action: StringName = &"move_left" if reverse else &"move_right"
			if not horizontal:
				start = Vector2(960, 150) if reverse else Vector2(960, 810)
				action = &"move_up" if reverse else &"move_down"
			player.place_at(room.global_position + start)
			await walk(action, 1.3)
			check_eq(
				world.get_current_room_id(),
				pair[0] if reverse else pair[1],
				"actual open R3 edge roundtrip"
			)


func pocket_return(host: StringName) -> void:
	var room := world.get_room(world.get_current_room_id())
	var door := _find(room, "room_door.gd") as RoomDoor
	player.place_at(door.global_position - Vector2(0, 110))
	await walk(&"move_down", 1.2)
	check_eq(world.get_current_room_id(), host, "actual pocket return reaches host")
	await seconds(0.5)
	check_eq(world.get_current_room_id(), host, "FromPocket avoids return bounce")


func kiln() -> void:
	# Earn a real wrong-scope key too: kiln must refuse it without consuming it.
	var store := await _enter(&"cave_1_3")
	player.place_at(store.global_position + Vector2(1008, 432))
	player.facing = Vector2.UP
	GameState.set_active_item(&"tether_moth")
	check(player.use_item(), "earned moth retrieves actual C01 scoped key")
	await seconds(1.8)
	check_eq(GameState.keys_in(&"c1"), 1, "actual wrong-scope key acquired")
	var closed_room := await _enter(&"ow_10_1")
	player.place_at(closed_room.global_position + Vector2(960, 460))
	await walk(&"move_up", 0.8)
	check_eq(world.get_current_room_id(), &"ow_10_1", "kiln blocks entry without ow key")
	check_eq(GameState.keys_in(&"c1"), 1, "closed kiln preserves actual wrong-scope key")
	# The second overworld key is actually fetched with the earned moth, not minted.
	var room := await _enter(&"ow_3_2#grate")
	player.place_at(room.global_position + Vector2(912, 432))
	player.facing = Vector2.UP
	GameState.set_active_item(&"tether_moth")
	check(player.use_item(), "earned moth fires at actual overworld grate key")
	await seconds(1.8)
	check_eq(GameState.keys_in(&"ow"), 1, "grated key actually credits ow scope")
	check_eq(GameState.keys_in(&"c4"), 0, "overworld key never credits C04")
	room = await _enter(&"ow_10_1")
	var lock := _find(room, "locked_door.gd") as LockedDoor
	check_eq(lock.scope, &"ow", "kiln lock explicitly consumes ow scope")
	player.place_at(room.global_position + Vector2(960, 460))
	await walk(&"move_up", 1.4)
	check_eq(world.get_current_room_id(), &"ow_10_1#hut", "earned key opens kiln and permits entry")
	check_eq(GameState.keys_in(&"ow"), 0, "kiln consumes exactly one actual ow key")
	check_eq(GameState.keys_in(&"c1"), 1, "kiln leaves actual C01 key unspent")
	room = world.get_room(&"ow_10_1#hut")
	var bag := _pickup(room, &"pot_bag_2")
	var capacity := GameState.pot_max()
	await _walk_onto(bag)
	check_eq(GameState.pot_max(), capacity + 4, "actual kiln satchel expands capacity")
	check(GameState.has_flag(&"picked_pot_bag_2"), "kiln satchel persists by graph id")
	await pocket_return(&"ow_10_1")
	await reload_world()
	room = await _enter(&"ow_10_1")
	check(_find(room, "locked_door.gd").is_open, "kiln lock persists after unload")


func bomb_cache() -> void:
	var room := await _enter(&"ow_11_2")
	var wall := _find(room, "cracked_wall.gd") as Node2D
	await _swing_at(wall.global_position, Vector2.RIGHT)
	check(not GameState.has_flag(&"cracked_e135"), "hook cannot replace bomb at Slag Cache")
	player.place_at(wall.global_position - Vector2(82, 0))
	player.facing = Vector2.RIGHT
	GameState.set_active_item(&"pitch_pot")
	check(player.use_item(), "earned pot places real bomb at slag wall")
	await seconds(1.9)
	check(GameState.has_flag(&"cracked_e135"), "actual pot blast breaks e135")
	player.place_at(room.global_position + Vector2(1450, 528))
	await walk(&"move_right", 1.3)
	check_eq(
		world.get_current_room_id(), &"ow_11_2#cache", "actual blasted notch enters core pocket"
	)
	room = world.get_room(&"ow_11_2#cache")
	var hearts := GameState.max_health
	await _walk_onto(_pickup(room, &"wick_core_ow_11_2"))
	check_eq(GameState.max_health, hearts + 2, "real slag core increases health")
	await pocket_return(&"ow_11_2")


func heavy_border() -> void:
	var room := await _enter(&"ow_9_3")
	player.place_at(room.global_position + Vector2(960, 790))
	await walk(&"move_down", 0.8)
	check_eq(world.get_current_room_id(), &"ow_9_3", "heavy border blocks body before mitts")
	GameState.acquire_item(&"heft_mitts")
	print("CONTROLLED R3 loadout: heft_mitts; C04 acquisition remains pending")
	GameState.set_active_item(&"heft_mitts")
	var stone := _find(room, "heavy_stone.gd") as Node2D
	player.place_at(stone.global_position - Vector2(0, 90))
	player.facing = Vector2.DOWN
	check(player.use_item(), "real controlled mitts touch border stone")
	await seconds(0.5)
	Input.action_press(&"use_item")
	await frames(3)
	Input.action_release(&"use_item")
	await seconds(1)
	check(GameState.has_flag(&"moved_e063"), "actual mitts lift/throw opens e063")
	player.place_at(room.global_position + Vector2(960, 790))
	await walk(&"move_down", 1.4)
	check_eq(world.get_current_room_id(), &"ow_9_4", "lifted pass crosses to Gravelight")
	room = await _enter(&"ow_9_4")
	check(_find(room, "heavy_stone.gd") == null, "paired Gravelight stone restores cleared body")
	player.place_at(room.global_position + Vector2(960, 160))
	await walk(&"move_up", 1.4)
	check_eq(world.get_current_room_id(), &"ow_9_3", "paired cleared pass allows physical return")


func jar_stairs() -> void:
	var room := await _enter(&"ow_10_2")
	var seam := _find(room, "hidden_seam.gd") as Node2D
	check(not seam.is_shown, "C07 stairs start concealed")
	await _swing_at(seam.global_position, Vector2.UP)
	check(not seam.is_shown, "hook cannot reveal glow-jar stairs")
	GameState.acquire_item(&"glow_jar")
	print("CONTROLLED R3 loadout: glow_jar; C05 acquisition remains pending")
	GameState.set_active_item(&"glow_jar")
	player.place_at(seam.global_position + Vector2(0, 240))
	player.facing = Vector2.UP
	check(player.use_item(), "real jar throws light over actual C07 stairs")
	await seconds(2)
	check(
		GameState.has_flag(&"revealed_e252"), "real continuous jar light permanently reveals stairs"
	)
	check(seam.is_shown, "C07 mouth visibly opens under jar")
	for id in [&"cave_4_1", &"cave_7_1"]:
		if not ResourceLoader.exists(WorldData.scene_path(id)):
			print("PENDING R3 future destination/earned acquisition: ", id)
	await capture("stairs-revealed")


func reel_border() -> void:
	for host in [&"ow_10_4", &"ow_10_5"]:
		var bank := await _enter(host)
		player.set_hurtbox_enabled(self, true)
		var start_y := 744.0 if host == &"ow_10_4" else 648.0
		player.place_at(bank.global_position + Vector2(912, start_y))
		await frames(3)
		var before := GameState.health
		await walk(&"move_up", 0.5)
		check_eq(
			GameState.health, before - 2, "walking into real anchor chasm falls before reel loadout"
		)
		check_eq(world.get_current_room_id(), host, "unreeled fall never crosses border")
		GameState.heal(GameState.max_health)
		player.set_hurtbox_enabled(self, false)
	GameState.acquire_item(&"reel_line")
	print("CONTROLLED R3 loadout: reel_line; C08 acquisition remains pending")
	GameState.set_active_item(&"reel_line")
	for host in [&"ow_10_4", &"ow_10_5"]:
		for reverse in [false, true]:
			var room := await _enter(host)
			var y := 744.0 if host == &"ow_10_4" else 624.0
			var target := 240.0 if host == &"ow_10_4" else 48.0
			if reverse:
				y = 312.0 if host == &"ow_10_4" else 144.0
				target = 792.0 if host == &"ow_10_4" else 720.0
			player.place_at(room.global_position + Vector2(912, y))
			player.facing = Vector2.DOWN if reverse else Vector2.UP
			var hp := GameState.health
			check(player.use_item(), "real reel launches across authored border chasm")
			var seen := false
			var over_pit := false
			for frame in range(120):
				await frames(1)
				if player.is_external_motion():
					seen = true
					check(player.is_airborne(), "validated reel motion clears actual pit")
					for pit in get_tree().get_nodes_in_group(&"pit_zone"):
						if pit.holds(player.global_position):
							over_pit = true
				elif seen:
					break
			check(seen and over_pit, "real line actually pulls over live region pit")
			check_near(
				player.position.y - room.position.y,
				target + (-72.0 if reverse else 72.0),
				3,
				"actual reel lands safely before anchor"
			)
			check_eq(GameState.health, hp, "actual border reel crossing avoids pit damage")
			await seconds(0.8)
	# Walk the shared border from each safe bank; each room's own pit was traversed above.
	var room := await _enter(&"ow_10_4")
	player.place_at(room.global_position + Vector2(960, 810))
	await walk(&"move_down", 1.2)
	check_eq(world.get_current_room_id(), &"ow_10_5", "actual reel border joins Anchor Beach")
	room = await _enter(&"ow_10_5")
	player.place_at(room.global_position + Vector2(960, 140))
	await walk(&"move_up", 1.2)
	check_eq(world.get_current_room_id(), &"ow_10_4", "Anchor Beach border returns to ledge")
	await capture("anchor-return")


func shop() -> void:
	var room := await _enter(&"ow_10_3")
	var door := _find(room, "room_door.gd") as RoomDoor
	check_eq(door.entrance_kind(), &"pocket_cart", "S3 entrance uses the cart art")
	check(door.get_node("Visual") is SpriteVisual, "S3 cart has painted art")
	player.place_at(door.global_position + Vector2(0, 144))
	await walk(&"move_up", 1.2)
	check_eq(world.get_current_room_id(), &"ow_10_3#shop", "walking north enters the cart")
	if world.get_current_room_id() != &"ow_10_3#shop":
		return
	room = world.get_room(&"ow_10_3#shop")
	GameState.add_currency(150)
	var stock: Node2D
	for node in _props(room):
		if node.get("stock") == &"slug_bundle":
			stock = node
	var slugs := GameState.slugs
	player.place_at(stock.global_position + Vector2(0, 46))
	await frames(4)
	check_eq(GameState.slugs, mini(slugs + 6, 30), "actual S3 slug stock replenishes sling")
	check(GameState.has_flag(&"shop_slug_bundle_s3"), "one-time S3 stock persists")
	await pocket_return(&"ow_10_3")
	room = world.get_room(&"ow_10_3")
	await walk(&"move_down", 0.8)
	check_eq(world.get_current_room_id(), &"ow_10_3", "player can walk away from the cart")
	await walk(&"move_up", 1.4)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"ow_10_3#shop", "player can walk back into the cart")
	if world.get_current_room_id() == &"ow_10_3#shop":
		await pocket_return(&"ow_10_3")


func persistence() -> void:
	var flags := GameState.flags.duplicate(true)
	check(not SaveGame.enabled, "acceptance writes no ordinary user save")
	if not isolated_test_profile():
		print("PENDING R3 disk persistence: isolated /tmp userdata required")
		return
	SaveGame.enabled = true
	check(SaveGame.save(), "actual earned R3 state writes isolated save")
	reset_state()
	SaveGame.enabled = true
	check(SaveGame.load_into_state(), "isolated R3 state reloads")
	check_eq(GameState.flags, flags, "all actual gate and pickup flags survive disk")
	SaveGame.enabled = false
	await reload_world()
	var room := await _enter(&"ow_8_0")
	check(_find(room, "hidden_seam.gd").is_shown, "hook cache remains open after reload")
	room = await _enter(&"ow_9_0")
	check(_find(room, "wax_seal.gd").is_open, "wax seal remains melted after reload")
	room = await _enter(&"ow_9_1")
	check(GameState.has_flag(&"ward_e256"), "ward cache remains earned after reload")
	room = await _enter(&"ow_10_1#hut")
	check(_pickup(room, &"pot_bag_2") == null, "satchel cannot duplicate after reload")
	room = await _enter(&"ow_11_2#cache")
	check(_pickup(room, &"wick_core_ow_11_2") == null, "core cannot duplicate after reload")


func capture(label: String) -> void:
	if OS.get_environment("WICK_R3_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		get_viewport().get_texture().get_image().save_png("/tmp/wick-r3-" + label + ".png"),
		OK,
		"actual R3 representative capture"
	)
