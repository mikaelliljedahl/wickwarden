## timeout=240
extends TestCase
## Controlled later-game loadout and positioned tool probes, not earned cave progression or a
## human playthrough. Regular combat is removed. Real tools, pickups, hazards, doors and World
## transitions remain active. Nine-fragment fixtures below are labelled, scoped real pickups;
## no boss defeat, door, reveal or acquisition flags are set by the test.

var world: World
var player: Player


func run() -> void:
	reset_state()
	world = await make_world()
	player = world.player
	for item in [&"pitch_pot", &"glow_jar", &"lantern_chime", &"reel_line", &"skitter_boots"]:
		GameState.acquire_item(item)
	GameState.add_pitch_pots(10)
	await _beach()
	await _paired_reel()
	await _paired_boots()
	await _ravines()
	await _bomb_cache()
	await _chime()
	await _seam()
	await _pier()
	await _shop()
	await _save()
	await _enter(&"ow_11_5")
	var restored := await _enter(&"ow_9_7")
	check(_find(restored, "resonance_stone.gd").is_awake, "disk-restored chime gate stays awake")
	restored = await _enter(&"ow_11_7")
	check(_find(restored, "hidden_seam.gd").is_revealed, "disk-restored seam stays revealed")
	restored = await _enter(&"ow_11_6")
	check(_find(restored, "cracked_wall.gd").is_open, "disk-restored bomb mouth stays open")
	await dispose(world)
	await _ninth()


func _enter(id: StringName) -> Room:
	world.start_at(id)
	var room := world.get_room(id)
	check(room != null, "%s actual scene exists" % id)
	if room == null:
		return null
	for enemy in room.get_enemies():
		enemy.drops_enabled = false
		enemy.queue_free()
	await frames(5)
	return room


func _find(room: Room, suffix: String) -> Node:
	for node in room.find_children("*", "", true, false):
		if node.get_script() != null and node.get_script().resource_path.ends_with(suffix):
			return node
	return null


func _at(room: Room, pos: Vector2) -> void:
	player.place_at(room.global_position + pos)
	await frames(4)


func _move(action: StringName, count: int) -> void:
	Input.action_press(action)
	await frames(count)
	Input.action_release(action)
	await frames(3)


func _use(item: StringName, dir: Vector2, count: int = 110) -> void:
	GameState.set_active_item(item)
	player.facing = dir
	check(player.use_item(), "%s real activation" % item)
	await frames(count)


func _hook(target: Node2D) -> void:
	player.place_at(target.global_position + Vector2(0, 76))
	player.facing = Vector2.UP
	await frames(3)
	Input.action_press(&"attack")
	await frames(2)
	Input.action_release(&"attack")
	await frames(20)


func _return(host: StringName) -> void:
	var room := world.get_room(world.get_current_room_id())
	var door := _find(room, "room_door.gd") as RoomDoor
	check(door != null, "pocket has a real return door")
	if door == null:
		return
	player.place_at(door.global_position + Vector2(0, -90))
	await _move(&"move_down", 35)
	await frames(40)
	check_eq(world.get_current_room_id(), host, "actual pocket return reaches host")
	if world.get_current_room_id() == host:
		for enemy in world.get_room(host).get_enemies():
			enemy.drops_enabled = false
			enemy.queue_free()
		await frames(3)


func _collect(room: Room) -> void:
	for node in room.get_node("Props").get_children():
		if is_instance_valid(node) and node is PickupBase:
			player.place_at(node.global_position + Vector2(0, 35))
			await frames(6)


func _beach() -> void:
	var room := await _enter(&"ow_10_5")
	await _at(room, Vector2(912, 624))
	var hp := GameState.health
	await _move(&"move_up", 35)
	check(GameState.health < hp, "e079 foot approach falls")
	check(player.global_position.y - room.global_position.y > 576, "e079 foot cannot cross")
	await frames(110)
	await _at(room, Vector2(912, 624))
	hp = GameState.health
	await _use(&"skitter_boots", Vector2.UP)
	check(GameState.health < hp, "e079 boots land in wide chasm and fall")
	GameState.heal(GameState.max_health)
	await frames(110)
	await _at(room, Vector2(912, 624))
	hp = GameState.health
	await _use(&"reel_line", Vector2.UP)
	check_near(player.global_position.y - room.global_position.y, 120, 2, "north reel safe 72 stop")
	await _move(&"move_down", 12)
	await _use(&"reel_line", Vector2.DOWN)
	check_near(player.global_position.y - room.global_position.y, 648, 2, "south reel safe 72 stop")
	check_eq(GameState.health, hp, "reel both ways avoids fall damage")
	# The paired Cinderflats bank is tested with its actual geometry, too.
	room = await _enter(&"ow_10_4")
	var rings := get_tree().get_nodes_in_group(&"anchor_ring")
	check(rings.size() >= 2, "paired e079 bank has real return targets")


func _ravines() -> void:
	for dir in [Vector2.UP, Vector2.LEFT]:
		var room := await _enter(&"ow_9_6")
		var pit := _edge_pit(room, dir)
		var start: Vector2 = pit.position - dir * 96
		await _at(room, start)
		GameState.heal(GameState.max_health)
		await frames(110)
		var hp := GameState.health
		await _move(&"move_up" if dir == Vector2.UP else &"move_left", 25)
		check(GameState.health < hp, "ravine approach falls on foot")
		await frames(110)
		await _at(room, start)
		hp = GameState.health
		await _use(&"skitter_boots", dir, 28)
		check_near(
			(player.global_position - room.global_position).distance_to(start + dir * 192),
			0,
			3,
			"boots land across actual ravine"
		)
		await frames(45)
		await _use(&"skitter_boots", -dir)
		check_near(
			(player.global_position - room.global_position).distance_to(start),
			0,
			3,
			"boots return to same approach"
		)
		check_eq(GameState.health, hp, "ravine boots both ways avoid damage")


func _bomb_cache() -> void:
	var room := await _enter(&"ow_11_6")
	var wall = _find(room, "cracked_wall.gd")
	var door := _find(room, "room_door.gd") as RoomDoor
	player.place_at(door.global_position)
	await frames(5)
	check_eq(world.get_current_room_id(), &"ow_11_6", "sealed bomb cache rejects overlap")
	await _hook(wall)
	check(not wall.is_open, "hook cannot replace bomb")
	player.place_at(wall.global_position + Vector2(0, 82))
	await _use(&"pitch_pot", Vector2.UP)
	check(GameState.has_flag(&"cracked_e142"), "real explosion persists bomb opening")
	player.place_at(door.global_position)
	await frames(65)
	check_eq(world.get_current_room_id(), &"ow_11_6#cache", "bomb mouth enters real cache")
	room = world.get_room(&"ow_11_6#cache")
	var hp := GameState.max_health
	await _collect(room)
	check_eq(GameState.max_health, hp + 2, "actual cache core increases max health")
	await _return(&"ow_11_6")
	await _enter(&"ow_8_7")
	room = await _enter(&"ow_11_6")
	check(_find(room, "cracked_wall.gd").is_open, "bomb opening survives room unload")


func _chime() -> void:
	var room := await _enter(&"ow_9_7")
	var seal = _find(room, "resonance_stone.gd")
	var door := _find(room, "room_door.gd") as RoomDoor
	check(not seal.is_awake, "C8 mouth starts asleep")
	player.place_at(door.global_position)
	await frames(5)
	check_eq(world.get_current_room_id(), &"ow_9_7", "asleep C8 mouth rejects overlap")
	await _hook(seal)
	check(not seal.is_awake, "hook cannot wake resonance door")
	player.place_at(seal.global_position + Vector2(0, 150))
	await _use(&"lantern_chime", Vector2.UP)
	check(seal.is_awake, "real released chime wave wakes C8 mouth")
	check(GameState.has_flag(&"resonated_e253"), "chime awakening persists")
	await _capture("chime-open")
	check(door._gate_is_open(), "C8 linked door observes awakened blocker")
	check_eq(door.target_spawn, &"FromOverworld", "C8 uses actual cave entry contract")
	if not ResourceLoader.exists(WorldData.scene_path("cave_8_1")):
		print("PENDING R6: C8 traversal/acquisition awaits cave_8_1; no fake warp")
	await _enter(&"ow_11_5")
	room = await _enter(&"ow_9_7")
	check(_find(room, "resonance_stone.gd").is_awake, "chime state survives unloading")


func _seam() -> void:
	var room := await _enter(&"ow_11_7")
	var seam = _find(room, "hidden_seam.gd")
	var door := _find(room, "room_door.gd") as RoomDoor
	check(not seam.is_shown, "graveyard seam starts hidden")
	player.place_at(door.global_position)
	await frames(5)
	check_eq(world.get_current_room_id(), &"ow_11_7", "hidden seam rejects trigger overlap")
	await _hook(seam)
	check(not seam.is_revealed, "hook preserves glow-only secret")
	player.place_at(seam.global_position - Vector2(220, 0))
	await _use(&"glow_jar", Vector2.RIGHT)
	check(seam.is_revealed, "real jar permanently unseals crypt")
	check(GameState.has_flag(&"revealed_e144"), "jar exposure persists")
	await _capture("seam-open")
	player.place_at(door.global_position)
	await frames(65)
	check_eq(world.get_current_room_id(), &"ow_11_7#cache", "revealed seam enters actual crypt")
	var money := GameState.currency
	await _collect(world.get_room(&"ow_11_7#cache"))
	check_eq(GameState.currency, money + 60, "actual crypt contains sixty brass")
	await _return(&"ow_11_7")
	await _enter(&"ow_8_7")
	room = await _enter(&"ow_11_7")
	check(_find(room, "hidden_seam.gd").is_revealed, "seam survives unload")


func _pier() -> void:
	var room := await _enter(&"ow_8_8")
	await _at(room, Vector2(912, 528))
	GameState.heal(GameState.max_health)
	await frames(110)
	var hp := GameState.health
	await _move(&"move_left", 35)
	check(GameState.health < hp, "Black Pier chasm rejects walking")
	check(player.global_position.x - room.global_position.x > 768, "foot cannot reach pocket bank")
	await frames(110)
	await _at(room, Vector2(912, 528))
	hp = GameState.health
	await _use(&"skitter_boots", Vector2.LEFT)
	check(GameState.health < hp, "Black Pier chasm rejects boots")
	GameState.heal(GameState.max_health)
	await frames(110)
	await _at(room, Vector2(912, 528))
	hp = GameState.health
	await _move(&"move_left", 10)
	await _use(&"reel_line", Vector2.LEFT)
	check_near(
		player.global_position.x - room.global_position.x, 408, 3, "reel reaches isolated pier"
	)
	check_eq(GameState.health, hp, "outbound pier reel avoids fall")
	await _capture("pier-landed")
	# Walk the isolated bank to the real trigger, without teleporting across the chasm.
	await _move(&"move_down", 32)
	await _move(&"move_left", 28)
	await frames(45)
	check_eq(world.get_current_room_id(), &"ow_8_8#cache", "walking from reel landing enters cache")
	var money := GameState.currency
	await _collect(world.get_room(&"ow_8_8#cache"))
	check_eq(GameState.currency, money + 50, "actual pier cache gives fifty brass")
	check(GameState.has_flag(&"picked_cache_ow_8_8_pots"), "actual pot bundle collected")
	await _return(&"ow_8_8")
	room = world.get_room(&"ow_8_8")
	await _walk_local(room, Vector2(432, 624))
	await _walk_local(room, Vector2(432, 528))
	await _use(&"reel_line", Vector2.RIGHT)
	check_near(
		player.global_position.x - room.global_position.x, 840, 3, "return reel reaches main pier"
	)
	await _enter(&"ow_11_5")
	await _enter(&"ow_8_8#cache")
	check(GameState.has_flag(&"picked_cache_ow_8_8_brass"), "pier cache collection survives unload")
	check_eq(
		(
			world
			. get_room(&"ow_8_8#cache")
			. get_node("Props")
			. get_children()
			. filter(func(n: Node) -> bool: return n is PickupBase)
			. size()
		),
		0,
		"collected cache does not respawn"
	)


func _shop() -> void:
	var room := await _enter(&"ow_10_7")
	var door := _find(room, "room_door.gd") as RoomDoor
	check_eq(door.entrance_kind(), &"pocket_stall", "S5 entrance uses the stall art")
	check(door.get_node("Visual") is SpriteVisual, "S5 stall has painted art")
	player.place_at(door.global_position + Vector2(0, 192))
	await _move(&"move_up", 30)
	await frames(65)
	check_eq(world.get_current_room_id(), &"ow_10_7#shop", "walking north enters S5")
	if world.get_current_room_id() != &"ow_10_7#shop":
		return
	room = world.get_room(&"ow_10_7#shop")
	GameState.acquire_item(&"tallow_sling")  # Explicit future-cave loadout, not earned C02 progress.
	var stock: Node2D
	for node in room.get_node("Props").get_children():
		if node.get("stock_id") == &"slug_bundle_s5":
			stock = node
	check(stock != null, "S5 contains graph slug source")
	if stock != null:
		var money := GameState.currency
		var ammo := GameState.slugs
		player.place_at(stock.global_position + Vector2(0, 46))
		await frames(8)
		check_eq(GameState.slugs, ammo + 6, "real shop bundle refills six slugs")
		check_eq(GameState.currency, money - 10, "S5 charges configured price")
		check(GameState.has_flag(&"shop_slug_bundle_s5"), "actual purchase persists")
	await _return(&"ow_10_7")
	await frames(40)
	check_eq(world.get_current_room_id(), &"ow_10_7", "return marker avoids door bounce")
	await _move(&"move_down", 25)
	check_eq(world.get_current_room_id(), &"ow_10_7", "player can walk away from the stall")
	await _move(&"move_up", 55)
	await frames(65)
	check_eq(world.get_current_room_id(), &"ow_10_7#shop", "player can walk back into S5")
	if world.get_current_room_id() == &"ow_10_7#shop":
		await _return(&"ow_10_7")


func _save() -> void:
	check(not SaveGame.enabled, "route kept user save disabled")
	check(OS.get_user_data_dir().begins_with("/tmp/"), "disk probe requires isolated userdata")
	if not OS.get_user_data_dir().begins_with("/tmp/"):
		return
	var flags := GameState.flags.duplicate(true)
	var money := GameState.currency
	SaveGame.enabled = true
	check(SaveGame.save(), "actual R6 gate state saves to isolated slot")
	reset_state()
	SaveGame.enabled = true
	check(SaveGame.load_into_state(), "actual R6 disk save reloads")
	check_eq(GameState.flags, flags, "gate pickup and shop flags survive isolated disk")
	check_eq(GameState.currency, money, "cache and purchase brass survives disk")
	SaveGame.enabled = false


func _fragment_fixture(room: Room, scope: StringName) -> void:
	var packed := load("res://scenes/pickups/fragment.tscn") as PackedScene
	check(packed != null, "real fragment scene loads for controlled scope fixture")
	if packed == null:
		return
	var fragment := packed.instantiate() as PickupBase
	fragment.scope = scope
	fragment.persistent_id = StringName("r6_fixture_%s" % scope)
	fragment.position = Vector2(912, 528)
	room.get_node("Props").add_child(fragment)
	player.place_at(fragment.global_position + Vector2(0, 35))
	await frames(6)
	check(GameState.has_fragment(scope), "real fixture pickup credits only %s" % scope)


func _ninth() -> void:
	# Each eight-of-nine set omits a different cave. These are contact/requirement fixtures,
	# not claims that unbuilt caves were completed. The ninth fragment is also physically collected.
	for missing in range(1, 10):
		reset_state()
		world = await make_world()
		player = world.player
		var room := await _enter(&"ow_10_8")
		var gate = _find(room, "ninth_door.gd")
		var door := _find(room, "room_door.gd") as RoomDoor
		check(not gate.is_open and gate.lit_count() == 0, "empty Ninth Door stays closed")
		if missing == 1:
			await _at(room, Vector2(1440, 720))
			await _move(&"move_up", 35)
			check(not gate.is_open, "physical contact with zero fragments is refused")
		for n in range(1, 10):
			if n != missing:
				await _fragment_fixture(room, StringName("c%d" % n))
		check_eq(gate.lit_count(), 8, "eight scoped fixtures light exactly eight sockets")
		check(not GameState.has_fragment(StringName("c%d" % missing)), "missing scope not credited")
		await _at(room, Vector2(1440, 720))
		await _move(&"move_up", 35)
		check(not gate.is_open, "physical contact rejects set missing c%d" % missing)
		check(not GameState.has_flag(&"door_ninth"), "partial set creates no opening flag")
		check(not door._gate_is_open(), "partial set keeps cave trigger blocked")
		check(
			player.global_position.y - room.global_position.y > 690,
			"partial gate physically stops body"
		)
		if missing == 9:
			await _fragment_fixture(room, &"c9")
			await _at(room, Vector2(1440, 720))
			await _move(&"move_up", 18)
			check(gate.is_open, "physical contact with all nine opens Ninth Door")
			await _capture("ninth-open")
			check(door._gate_is_open(), "all nine release actual linked cave mouth")
			check(GameState.has_flag(&"door_ninth"), "actual full-set contact persists")
			for n in range(1, 10):
				check(GameState.has_fragment(StringName("c%d" % n)), "opening spends no fragment")
			check_eq(door.target_room, &"cave_10_1", "Ninth Door targets real C10 id")
			check_eq(door.target_spawn, &"FromOverworld", "C10 mouth uses contracted marker")
			if not ResourceLoader.exists(WorldData.scene_path("cave_10_1")):
				print("PENDING R6: C10 traversal awaits cave_10_1; no fake final cave")
			await _enter(&"ow_11_5")
			room = await _enter(&"ow_10_8")
			check(_find(room, "ninth_door.gd").is_open, "Ninth Door survives unload")
			await _save()
			await _enter(&"ow_11_5")
			room = await _enter(&"ow_10_8")
			check(_find(room, "ninth_door.gd").is_open, "disk-restored Ninth Door stays open")
		await dispose(world)


func _cross(action: StringName, target: StringName) -> void:
	Input.action_press(action)
	for count in range(150):
		await frames(1)
		if world.get_current_room_id() == target:
			break
	Input.action_release(action)
	await frames(35)
	check_eq(world.get_current_room_id(), target, "actual paired edge transition")


func _paired_reel() -> void:
	var room := await _enter(&"ow_10_4")
	await _at(room, Vector2(912, 300))
	GameState.heal(GameState.max_health)
	await frames(110)
	var hp := GameState.health
	await _move(&"move_down", 35)
	check(GameState.health < hp, "paired ledge foot approach falls")
	await frames(110)
	await _at(room, Vector2(912, 300))
	hp = GameState.health
	await _use(&"skitter_boots", Vector2.DOWN)
	check(GameState.health < hp, "paired ledge wide chasm rejects boots")
	GameState.heal(GameState.max_health)
	await frames(110)
	await _at(room, Vector2(912, 300))
	hp = GameState.health
	await _use(&"reel_line", Vector2.DOWN)
	check_near(
		player.global_position.y - room.global_position.y, 720, 3, "paired ledge reel lands south"
	)
	await _cross(&"move_down", &"ow_10_5")
	room = await _enter(&"ow_10_5")
	await _at(room, Vector2(912, 144))
	await _use(&"reel_line", Vector2.DOWN)
	check_near(
		player.global_position.y - room.global_position.y, 648, 3, "arrival bank reel reaches beach"
	)
	await _move(&"move_up", 4)
	await _use(&"reel_line", Vector2.UP)
	await _cross(&"move_up", &"ow_10_4")
	room = await _enter(&"ow_10_4")
	await _at(room, Vector2(912, 732))
	await _use(&"reel_line", Vector2.UP)
	check_near(
		player.global_position.y - room.global_position.y,
		312,
		3,
		"paired return reel reaches ledge"
	)
	check_eq(GameState.health, hp, "e079 paired round trip has no pit damage")


func _edge_pit(room: Room, side: Vector2) -> Node2D:
	var result: Node2D
	for node in room.get_node("Props").get_children():
		if node.get_script() != null and node.get_script().resource_path.ends_with("pit_zone.gd"):
			if result == null or node.position.dot(side) > result.position.dot(side):
				result = node
	check(result != null, "actual edge has a physical pit zone")
	return result


func _paired_boots() -> void:
	for probe in [
		[&"ow_9_5", Vector2.DOWN, &"move_down", &"move_up"],
		[&"ow_8_6", Vector2.RIGHT, &"move_right", &"move_left"]
	]:
		var room := await _enter(probe[0])
		var dir: Vector2 = probe[1]
		var pit := _edge_pit(room, dir)
		var start: Vector2 = pit.position - dir * 96
		GameState.heal(GameState.max_health)
		await frames(110)
		await _at(room, start)
		var hp := GameState.health
		await _use(&"skitter_boots", dir)
		await _cross(probe[2], &"ow_9_6")
		check_eq(GameState.health, hp, "World arrival after paired leap is safe")
		room = await _enter(&"ow_9_6")
		pit = _edge_pit(room, -dir)
		await _at(room, pit.position - dir * 96)
		await _use(&"skitter_boots", dir)
		await _use(&"skitter_boots", -dir)
		await _cross(probe[3], probe[0])
		check_eq(GameState.health, hp, "World return arrival after paired leap is safe")
		room = await _enter(probe[0])
		pit = _edge_pit(room, dir)
		await _at(room, pit.position + dir * 96)
		await _use(&"skitter_boots", -dir)
		check_near(
			(player.global_position - room.global_position).distance_to(start),
			0,
			3,
			"paired ravine round trip returns to departure bank"
		)
		check_eq(GameState.health, hp, "paired ravine round trip avoids pit damage")


func _capture(label: String) -> void:
	if OS.get_environment("WICK_R6_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		get_viewport().get_texture().get_image().save_png("/tmp/wick-r6-" + label + ".png"),
		OK,
		"actual R6 route state capture"
	)


func _walk_local(room: Room, target: Vector2) -> void:
	for count in range(200):
		var diff := target - (player.global_position - room.global_position)
		if diff.length() < 7:
			break
		release_inputs()
		if absf(diff.x) > 5:
			Input.action_press(&"move_right" if diff.x > 0 else &"move_left")
		elif absf(diff.y) > 5:
			Input.action_press(&"move_down" if diff.y > 0 else &"move_up")
		await frames(1)
	release_inputs()
	check_near(
		(player.global_position - room.global_position).distance_to(target),
		0,
		8,
		"actual bank walking reaches reel launch"
	)
