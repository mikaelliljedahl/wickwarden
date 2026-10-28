## timeout=900
extends "res://tests/test_route_cave_6.gd"
## In-progress Q3 shard. The previous shard earns C1-C5 in this process.
## This continues through C6-C9 using real actors and tools, with positioned room
## starts and ordinary-enemy removal.


func run() -> void:
	var start_frame := Engine.get_physics_frames()
	var previous_script := load("res://tests/test_playthrough_2.gd") as GDScript
	check(previous_script != null, "previous earned-route shard loads")
	if previous_script == null:
		return
	var previous := previous_script.new() as TestCase
	add_child(previous)
	await previous.run()
	checks += previous.checks
	for failure in previous.failures:
		failures.append("C1-C5: " + failure)
	await dispose(previous)
	for cave in [&"c1", &"c2", &"c3", &"c4", &"c5"]:
		check(GameState.has_fragment(cave), "earned fragment retained: " + String(cave))
	check(GameState.has_item(&"heft_mitts"), "earned mitts retained")
	check(GameState.has_item(&"glow_jar"), "earned jar retained")
	if not failures.is_empty():
		return
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	await mouth()
	await c6_first_key()
	await singer_and_chime()
	await second_key()
	await c6_vault()
	await dirge()
	check(GameState.has_fragment(&"c6"), "Dirge drops the earned sixth fragment")
	check(GameState.has_flag(&"boss_cave_6_11_defeated"), "Dirge is defeated")
	await dispose(world)
	if failures.is_empty():
		save_c6()
	if failures.is_empty():
		world = await make_world()
		player = world.player
		await cave_seven()
		check(GameState.has_fragment(&"c7"), "Gloam Knight drops the earned seventh fragment")
		check(GameState.has_flag(&"boss_cave_7_11_defeated"), "Gloam Knight is defeated")
		if failures.is_empty():
			await cave_eight()
		check(GameState.has_fragment(&"c8"), "Coinwyrm drops the earned eighth fragment")
		check(GameState.has_flag(&"boss_cave_8_12_defeated"), "Coinwyrm is defeated")
		if failures.is_empty():
			await cave_nine()
		check(GameState.has_fragment(&"c9"), "Lock Warden drops the earned ninth fragment")
		check(GameState.has_flag(&"boss_cave_9_10_defeated"), "Lock Warden is defeated")
		await dispose(world)
	print("C1-C9 simulated play time: %.2f seconds" % ((Engine.get_physics_frames() - start_frame) / 60.0))
	SaveGame.enabled = false


func c6_first_key() -> void:
	var room := await enter(&"cave_6_2")
	await bomb_arch(room)
	await edge(&"cave_6_2", &"cave_6_3", Vector2.UP)
	room = world.get_room(&"cave_6_3")
	await collect(room, &"key_c6_1")
	await edge(&"cave_6_3", &"cave_6_2", Vector2.DOWN)
	room = world.get_room(&"cave_6_2")
	await contact(scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check_eq(GameState.keys_in(&"c6"), 0, "first C6 lock spends its real key")
	await edge(&"cave_6_2", &"cave_6_4", Vector2.RIGHT)


func c6_vault() -> void:
	var room := await enter(&"cave_6_8")
	await ward_cache(room)
	room = world.get_room(&"cave_6_8")
	await contact(scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check_eq(GameState.keys_in(&"c6"), 0, "second C6 lock spends its real key")
	await edge(&"cave_6_8", &"cave_6_9", Vector2.RIGHT)
	room = world.get_room(&"cave_6_9")
	await bomb(scripted(room, "cracked_wall.gd"))
	var door := door_to(room, &"cave_6_9#crypt")
	player.place_at(door.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_6_9#crypt", "real bomb opens the crypt")
	room = await enter(&"cave_6_9#crypt")
	await collect(room, &"wick_core_c6_hidden")
	await return_pocket(room, &"cave_6_9")
	room = world.get_room(&"cave_6_9")
	await collect(room, &"bigkey_c6")
	check(GameState.has_big_key(&"c6"), "C6 Lockpick is collected")
	await edge(&"cave_6_9", &"cave_6_8", Vector2.LEFT)
	await push_gate(&"cave_6_8", &"cave_6_10")
	room = world.get_room(&"cave_6_10")
	await contact(scripted(room, "boss_door.gd"), Vector2.DOWN)
	await edge(&"cave_6_10", &"cave_6_11", Vector2.DOWN)


func save_c6() -> void:
	var safe := isolated_test_profile()
	check(safe, "C6 save requires isolated test userdata")
	if not safe:
		return
	var before := summary()
	SaveGame.enabled = true
	if not SaveGame.save():
		check(false, "earned C6 state saves")
		return
	reset_state()
	var loaded := SaveGame.load_into_state()
	check(loaded, "earned C6 state reloads")
	if loaded:
		check_eq(summary(), before, "C6 state survives save and reload")
	SaveGame.enabled = false


func cave_seven() -> void:
	var script := load("res://tests/test_route_cave_7.gd") as GDScript
	check(script != null, "C7 helpers load")
	if script == null:
		return
	var route = script.new()
	add_child(route)
	route.world = world
	route.player = player
	player.set_hurtbox_enabled(route, false)
	var room: Room = await route.enter(&"ow_10_2")
	var seam = route.scripted(room, "hidden_seam.gd")
	await route.throw_jar(seam.global_position + Vector2(0, 150), Vector2.UP)
	await seconds(2)
	check(seam.is_revealed, "earned jar reveals the C7 stairs")
	player.place_at(route.door_to(room, &"cave_7_1").global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_7_1", "actual mouth enters C7")
	await route.edge(&"cave_7_1", &"cave_7_2", Vector2.LEFT)
	await route.edge(&"cave_7_2", &"cave_7_3", Vector2.UP)
	room = world.get_room(&"cave_7_3")
	player.place_at(room.global_position + Vector2(1008, 432))
	player.facing = Vector2.UP
	GameState.set_active_item(&"tether_moth")
	check(player.use_item(), "earned moth fetches the C7 key over the pit")
	await seconds(1.7)
	check_eq(GameState.keys_in(&"c7"), 1, "first C7 key is collected")
	await route.edge(&"cave_7_3", &"cave_7_2", Vector2.DOWN)
	room = world.get_room(&"cave_7_2")
	await route.contact(route.scripted(room, "locked_door.gd"), Vector2.LEFT)
	await route.edge(&"cave_7_2", &"cave_7_4", Vector2.LEFT)
	await route.squire()
	await route.edge(&"cave_7_4", &"cave_7_5", Vector2.LEFT)
	room = world.get_room(&"cave_7_5")
	await route.collect(room, &"skitter_boots")
	check(GameState.has_item(&"skitter_boots"), "C7 rack grants the real boots")
	await route.leap(Vector2(960, 336), Vector2.UP)
	await route.edge(&"cave_7_5", &"cave_7_6", Vector2.UP)
	room = world.get_room(&"cave_7_6")
	await route.collect(room, &"key_c7_2")
	await route.leap(Vector2(960, 624), Vector2.DOWN)
	await route.edge(&"cave_7_6", &"cave_7_5", Vector2.DOWN)
	await route.edge(&"cave_7_5", &"cave_7_8", Vector2.DOWN)
	room = world.get_room(&"cave_7_8")
	await route.contact(route.scripted(room, "locked_door.gd"), Vector2.LEFT)
	await route.edge(&"cave_7_8", &"cave_7_9", Vector2.LEFT)
	await route.collect(world.get_room(&"cave_7_9"), &"bigkey_c7")
	check(GameState.has_big_key(&"c7"), "C7 Lockpick is collected")
	await route.edge(&"cave_7_9", &"cave_7_8", Vector2.RIGHT)
	await route.edge(&"cave_7_8", &"cave_7_10", Vector2.RIGHT)
	room = world.get_room(&"cave_7_10")
	await route.contact(route.scripted(room, "boss_door.gd"), Vector2.DOWN)
	await route.edge(&"cave_7_10", &"cave_7_11", Vector2.DOWN)
	await route.knight()
	checks += route.checks
	for failure in route.failures:
		failures.append("C7: " + failure)
	player.set_hurtbox_enabled(route, true)
	await dispose(route)


func cave_eight() -> void:
	var script := load("res://tests/test_route_cave_8.gd") as GDScript
	check(script != null, "C8 helpers load")
	if script == null:
		return
	var route = script.new()
	add_child(route)
	route.world = world
	route.player = player
	player.set_hurtbox_enabled(route, false)
	await route.counting_mouth()
	var room: Room = await route.enter(&"cave_8_2")
	var eye: Node2D = route.switch_in(room)
	await route.collect(room, &"slug_bundle_cave_8_2")
	player.place_at(eye.global_position + Vector2(0, 160))
	player.facing = Vector2.UP
	GameState.set_active_item(&"tallow_sling")
	check(player.use_item(), "earned sling opens the C8 eye")
	await seconds(0.6)
	check(eye.is_on, "C8 eye is open")
	await route.edge(&"cave_8_2", &"cave_8_3", Vector2.UP)
	room = world.get_room(&"cave_8_3")
	await route.collect(room, &"key_c8_1")
	await route.edge(&"cave_8_3", &"cave_8_2", Vector2.DOWN)
	room = world.get_room(&"cave_8_2")
	await route.contact(route.scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check_eq(GameState.keys_in(&"c8"), 0, "first C8 lock spends its real key")
	await route.edge(&"cave_8_2", &"cave_8_4", Vector2.RIGHT)
	await route.brute()
	await route.reel_and_vault()
	room = await route.enter(&"cave_8_8")
	await route.contact(route.scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check_eq(GameState.keys_in(&"c8"), 1, "Lockpick retains the second C8 key")
	await route.edge(&"cave_8_8", &"cave_8_9", Vector2.RIGHT)
	room = world.get_room(&"cave_8_9")
	await route.collect(room, &"key_c8_3")
	await route.edge(&"cave_8_9", &"cave_8_10", Vector2.DOWN)
	room = world.get_room(&"cave_8_10")
	await route.contact(route.scripted(room, "locked_door.gd"), Vector2.LEFT)
	check_eq(GameState.keys_in(&"c8"), 2, "Lockpick retains both C8 keys")
	await route.edge(&"cave_8_10", &"cave_8_11", Vector2.LEFT)
	room = world.get_room(&"cave_8_11")
	await route.contact(route.scripted(room, "boss_door.gd"), Vector2.LEFT)
	await route.edge(&"cave_8_11", &"cave_8_12", Vector2.LEFT)
	await route.coinwyrm()
	checks += route.checks
	for failure in route.failures:
		failures.append("C8: " + failure)
	player.set_hurtbox_enabled(route, true)
	await dispose(route)


func cave_nine() -> void:
	var script := load("res://tests/test_route_cave_9.gd") as GDScript
	check(script != null, "C9 helpers load")
	if script == null:
		return
	var route = script.new()
	add_child(route)
	route.world = world
	route.player = player
	player.set_hurtbox_enabled(route, false)
	await route.mouth()
	var room: Room = await route.enter(&"cave_9_2")
	var thorn: Node2D = route.scripted(room, "burnable.gd")
	player.place_at(thorn.global_position + Vector2(0, 180))
	player.facing = Vector2.UP
	GameState.set_active_item(&"cinder_wick")
	check(player.use_item(), "earned wick burns the C9 thorn")
	await seconds(1.8)
	check(GameState.has_flag(&"burned_e223"), "C9 thorn gate opens")
	await route.edge(&"cave_9_2", &"cave_9_3", Vector2.UP)
	await route.collect(world.get_room(&"cave_9_3"), &"key_c9_1")
	await route.edge(&"cave_9_3", &"cave_9_2", Vector2.DOWN)
	room = world.get_room(&"cave_9_2")
	await route.contact(route.scripted(room, "locked_door.gd"), Vector2.RIGHT)
	await route.edge(&"cave_9_2", &"cave_9_4", Vector2.RIGHT)
	room = world.get_room(&"cave_9_4")
	var enemy: EnemyBase = route.scripted_enemy(room, "wick_automaton.gd")
	player.place_at(enemy.global_position + Vector2(0, 160))
	player.facing = Vector2.UP
	GameState.set_active_item(&"tether_moth")
	check(player.use_item(), "earned moth stuns the Automaton")
	await frames(15)
	check(enemy.is_stunned(), "actual moth opens the Automaton vent")
	for attempt in range(50):
		if not is_instance_valid(enemy) or enemy.is_dying():
			break
		await route.hook_enemy(enemy)
	check(GameState.has_flag(&"mini_cave_9_4"), "real moth and hook defeat the Automaton")
	await seconds(1.7)
	await route.cell()
	await route.edge(&"cave_9_2", &"cave_9_4", Vector2.RIGHT)
	await route.ride(world.get_room(&"cave_9_4"), &"cave_9_5", &"e225")
	room = world.get_room(&"cave_9_5")
	await route.leap(room, Vector2(960, 336), Vector2.UP)
	await route.cross(&"move_up", &"cave_9_6")
	room = world.get_room(&"cave_9_6")
	await route.collect(room, &"key_c9_2")
	await route.leap(room, Vector2(960, 624), Vector2.DOWN)
	await route.cross(&"move_down", &"cave_9_5")
	room = world.get_room(&"cave_9_5")
	var stone = route.scripted(room, "heavy_stone.gd")
	player.place_at(stone.global_position + Vector2(0, -100))
	player.facing = Vector2.DOWN
	GameState.set_active_item(&"heft_mitts")
	check(player.use_item(), "earned mitts lift the C9 stone")
	await frames(24)
	check(stone.is_carried(), "C9 stone is carried")
	player.facing = Vector2.RIGHT
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await seconds(1.3)
	check(GameState.has_flag(&"moved_e228"), "real throw opens C9 heavy gate")
	await route.edge(&"cave_9_5", &"cave_9_8", Vector2.DOWN)
	room = world.get_room(&"cave_9_8")
	await route.contact(route.scripted(room, "locked_door.gd"), Vector2.LEFT)
	await route.edge(&"cave_9_8", &"cave_9_9", Vector2.LEFT)
	await route.edge(&"cave_9_9", &"cave_9_8", Vector2.RIGHT)
	await route.edge(&"cave_9_8", &"cave_9_5", Vector2.UP)
	await route.leap(world.get_room(&"cave_9_5"), Vector2(960, 336), Vector2.UP)
	await route.cross(&"move_up", &"cave_9_6")
	room = world.get_room(&"cave_9_6")
	await route.reel(room, Vector2(1200, 432), Vector2.RIGHT, 1608)
	await route.edge(&"cave_9_6", &"cave_9_7", Vector2.RIGHT)
	room = world.get_room(&"cave_9_7")
	await route.reel(room, Vector2(336, 432), Vector2.RIGHT, 744)
	await route.collect(room, &"bigkey_c9")
	check(GameState.has_big_key(&"c9"), "C9 Lockpick is collected")
	await route.reel(room, Vector2(720, 432), Vector2.LEFT, 312)
	await route.edge(&"cave_9_7", &"cave_9_6", Vector2.LEFT)
	room = world.get_room(&"cave_9_6")
	await route.reel(room, Vector2(1584, 432), Vector2.LEFT, 1176)
	await route.leap(room, Vector2(960, 624), Vector2.DOWN)
	await route.cross(&"move_down", &"cave_9_5")
	await route.edge(&"cave_9_5", &"cave_9_8", Vector2.DOWN)
	await route.edge(&"cave_9_8", &"cave_9_9", Vector2.LEFT)
	await route.vault_and_door()
	await route.lock_floor()
	checks += route.checks
	for failure in route.failures:
		failures.append("C9: " + failure)
	player.set_hurtbox_enabled(route, true)
	await dispose(route)
