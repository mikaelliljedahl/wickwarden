## timeout=1200
extends "res://tests/test_route_cave_10.gd"
## Runs the earned C1-C9 route in this process, then the real final cave and
## both ending branches. Like the earlier shards, this positions the player,
## warps between selected rooms and removes ordinary enemies; it is not a human run.


func run() -> void:
	var start_frame := Engine.get_physics_frames()
	var previous_script := load("res://tests/test_playthrough_3.gd") as GDScript
	check(previous_script != null, "previous earned-route shard loads")
	if previous_script == null:
		return
	var previous := previous_script.new() as TestCase
	add_child(previous)
	await previous.run()
	checks += previous.checks
	for failure in previous.failures:
		failures.append("C1-C9: " + failure)
	await dispose(previous)
	for number in range(1, 10):
		check(GameState.has_fragment(StringName("c%d" % number)), "earned fragment %d retained" % number)
	if not failures.is_empty() or not save_before_final():
		return
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	await earned_ninth_mouth()
	await earned_garden_and_echo()
	await choir_and_chime()
	await span_and_ward()
	await earned_vault_and_eye()
	await final_fight()
	if not failures.is_empty():
		await dispose(world)
		return
	await c10_persistence()
	await ending_branch(&"rekindle")
	await dispose(world)
	GameState.reset()
	SaveGame.enabled = true
	check(SaveGame.load_into_state(), "second ending reloads the earned pre-choice state")
	SaveGame.enabled = false
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	await ending_branch(&"wickwarden")
	await dispose(world)
	get_tree().current_scene = get_parent()
	SaveGame.enabled = false
	print(
		"C1-C10 and both endings simulated play time: %.2f seconds"
		% ((Engine.get_physics_frames() - start_frame) / 60.0)
	)


func save_before_final() -> bool:
	var isolated := OS.get_environment("XDG_DATA_HOME")
	var safe := isolated.begins_with("/tmp/wickwarden-check-")
	safe = safe and OS.get_user_data_dir().begins_with(isolated + "/")
	check(safe, "final route save requires isolated test userdata")
	if not safe:
		return false
	var before := summary()
	SaveGame.enabled = true
	var saved := SaveGame.save()
	check(saved, "earned nine-fragment state saves")
	if not saved:
		SaveGame.enabled = false
		return false
	reset_state()
	var loaded := SaveGame.load_into_state()
	check(loaded, "earned nine-fragment state reloads")
	if loaded:
		check_eq(summary(), before, "earned state survives the final route save")
	SaveGame.enabled = false
	return loaded


func earned_ninth_mouth() -> void:
	var room := await enter(&"ow_10_8")
	var gate = scripted(room, "ninth_door.gd")
	var door := door_to(room, &"cave_10_1")
	check_eq(GameState.fragment_count(), 9, "the nine actual prior fragments are held")
	player.place_at(gate.global_position + Vector2(0, 70))
	await frames(5)
	check(gate.is_open, "contact with nine earned fragments opens the Ninth Door")
	check(GameState.has_flag(&"door_ninth"), "real contact persists Ninth Door")
	player.place_at(door.global_position + Vector2(0, 160))
	await frames(3)
	player.place_at(door.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_10_1", "actual Ninth Door enters C10")
	await edge(&"cave_10_1", &"cave_10_2", Vector2.RIGHT)


func earned_garden_and_echo() -> void:
	var room := await enter(&"cave_10_2")
	await blocked(Vector2(1650, 480), &"move_right", scripted(room, "locked_door.gd"), "wrong-scope c10 lock")
	var c8_keys := GameState.keys_in(&"c8")
	await fire_at(scripted(room, "burnable.gd").global_position, Vector2.UP)
	check(GameState.has_flag(&"burned_e234"), "earned wick opens garden")
	await edge(&"cave_10_2", &"cave_10_3", Vector2.UP)
	await collect(world.get_room(&"cave_10_3"), &"key_c10_1")
	await edge(&"cave_10_3", &"cave_10_2", Vector2.DOWN)
	room = world.get_room(&"cave_10_2")
	await contact(scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check_eq(GameState.keys_in(&"c10"), 0, "first C10 key is spent")
	check_eq(GameState.keys_in(&"c8"), c8_keys, "C10 lock preserves C8 keys")
	await edge(&"cave_10_2", &"cave_10_4", Vector2.RIGHT)
	room = world.get_room(&"cave_10_4")
	var echo = scripted_enemy(room, "corrows_echo.gd")
	check(echo != null, "actual Echo appears")
	if echo == null:
		return
	var stunned := false
	for tick in range(900):
		player.place_at(echo.global_position + Vector2(0, 110))
		if echo.state == echo.State.GLOW:
			GameState.set_active_item(&"lantern_chime")
			check(player.use_item(), "earned chime interrupts natural Echo glow")
			await frames(16)
			stunned = echo.is_stunned()
			break
		await frames(1)
	check(stunned, "actual chime stuns Echo")
	for attempt in range(70):
		if not is_instance_valid(echo) or echo.is_dying():
			break
		await hook_enemy(echo)
	check(GameState.has_flag(&"mini_cave_10_4"), "actual chime and hook defeat Echo")
	await seconds(1.7)
	await ride(room, &"cave_10_5", &"e236")


func earned_vault_and_eye() -> void:
	await spend_lock(&"cave_10_10", &"cave_10_11", &"e242")
	var room := world.get_room(&"cave_10_11")
	await collect(room, &"key_c10_3")
	await spend_lock(&"cave_10_11", &"cave_10_12", &"e243")
	room = world.get_room(&"cave_10_12")
	await collect(room, &"slug_bundle_cave_10_12")
	var eye: Node2D
	for node in room.get_node("Props").get_children():
		if node.get_script() != null and node.get_script().resource_path.ends_with("eye_switch.gd") and not node.blocker:
			eye = node
	player.place_at(eye.global_position + Vector2(0, 160))
	player.facing = Vector2.UP
	GameState.set_active_item(&"tallow_sling")
	check(player.use_item(), "earned sling opens the final eye")
	await seconds(0.6)
	check(eye.is_on, "final eye is open")
	await edge(&"cave_10_12", &"cave_10_13", Vector2.UP)
	await collect(world.get_room(&"cave_10_13"), &"bigkey_c10")
	check(GameState.has_big_key(&"c10"), "final Lockpick is collected")
	await edge(&"cave_10_13", &"cave_10_12", Vector2.DOWN)
	room = world.get_room(&"cave_10_12")
	await contact(scripted(room, "boss_door.gd"), Vector2.LEFT)
	await edge(&"cave_10_12", &"cave_10_14", Vector2.LEFT)
