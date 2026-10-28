## timeout=300
extends "res://tests/test_route_cave_5.gd"
## Positioned integration route; ordinary mobs removed and hero hurtbox suppressed except ward/death.
## Prerequisite pedestal acquisitions are labelled fixtures, not prior-cave combat completion.
## No HP, phase, timer, ammo, inventory or progression flag injection.


func run() -> void:
	reset_state()
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	await acquire_kit()
	for pair in [
		[&"cave_1_5", &"cinder_wick"],
		[&"cave_2_5", &"tallow_sling"],
		[&"cave_3_5", &"reed_raft"],
		[&"cave_4_5", &"heft_mitts"],
		[&"cave_5_5", &"glow_jar"],
		[&"cave_6_5", &"lantern_chime"],
		[&"cave_7_5", &"skitter_boots"]
	]:
		var source := await enter(pair[0])
		await collect(source, pair[1])
		check(GameState.has_item(pair[1]), "labelled actual prerequisite pedestal: " + pair[1])
	check(not GameState.has_item(&"reel_line"), "pre-Reel C09 Automaton attempt")
	await mouth()
	await first_key()
	await automaton()
	# The pre-Reel excursion proves this encounter without implying continuous C08 combat.
	var source := await enter(&"cave_8_5")
	await collect(source, &"reel_line")
	check(GameState.has_item(&"reel_line"), "labelled actual C08 Reel Line pedestal fixture")
	source = await enter(&"cave_8_7")
	await collect(source, &"bigkey_c8")
	check(GameState.has_big_key(&"c8"), "actual foreign Lockpick fixture for scope rejection")
	await enter(&"ow_0_2")
	await mouth()
	await cell()
	await edge(&"cave_9_2", &"cave_9_4", Vector2.RIGHT)
	check_eq(world.get_room(&"cave_9_4").get_enemies().size(), 0, "earned mini stays defeated")
	await ride(world.get_room(&"cave_9_4"), &"cave_9_5", &"e225")
	await crossings()
	await vault_and_door()
	await lock_floor()
	await persistence()
	await dispose(world)


func mouth() -> void:
	var room := await enter(&"ow_0_2")
	var seam = scripted(room, "hidden_seam.gd")
	var door: Node2D = seam
	if not seam.is_revealed:
		player.place_at(door.global_position)
		await frames(5)
		check_eq(world.get_current_room_id(), &"ow_0_2", "concealed mouth rejects overlap")
		await throw_jar(seam.global_position + Vector2(0, 192), Vector2.UP)
		await seconds(1.6)
		check(seam.is_revealed, "actual jar reveals hidden stairs")
	player.place_at(door.global_position + Vector2(0, 120))
	await frames(3)
	player.place_at(door.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_9_1", "actual revealed stairs enter workshop")
	check(GameState.has_flag(&"mouth_c9"), "actual entry records mouth")
	await edge(&"cave_9_1", &"cave_9_2", Vector2.RIGHT)


func first_key() -> void:
	var room := await enter(&"cave_9_2")
	await blocked(
		Vector2(1680, 480), &"move_right", scripted(room, "locked_door.gd"), "foreign c1 key"
	)
	check_eq(GameState.keys_in(&"c1"), 1, "c9 lock preserves earned c1 key")
	var thorn = scripted(room, "burnable.gd")
	await swing_from(thorn.global_position, Vector2.UP)
	check(not GameState.has_flag(&"burned_e223"), "hook cannot burn workshop thorn")
	player.place_at(thorn.global_position + Vector2(0, 180))
	player.facing = Vector2.UP
	GameState.set_active_item(&"cinder_wick")
	check(player.use_item(), "actual earned wick launches at thorn")
	await seconds(1.8)
	check(GameState.has_flag(&"burned_e223"), "real fire opens paired thorn")
	await edge(&"cave_9_2", &"cave_9_3", Vector2.UP)
	await collect(world.get_room(&"cave_9_3"), &"key_c9_1")
	check_eq(GameState.keys_in(&"c9"), 1, "actual study key belongs to c9")
	await edge(&"cave_9_3", &"cave_9_2", Vector2.DOWN)
	room = world.get_room(&"cave_9_2")
	await contact(scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check_eq(GameState.keys_in(&"c9"), 0, "first c9 key spent once")
	check(
		scripted(world.get_room(&"cave_9_4"), "locked_door.gd").is_open, "paired first lock opens"
	)
	await edge(&"cave_9_2", &"cave_9_4", Vector2.RIGHT)


func automaton() -> void:
	var room := await enter(&"cave_9_4")
	var enemy = scripted_enemy(room, "wick_automaton.gd")
	check(enemy != null, "actual room-owned Automaton")
	if enemy == null:
		return
	check(not GameState.has_item(&"reel_line"), "actual Automaton fight precedes Reel fixture")
	# Natural flame jet, actual held ward, no synthetic projectile or timer setup.
	player.place_at(room.global_position + Vector2(960, 650))
	player.facing = Vector2.UP
	Input.action_press(&"ward")
	player.set_hurtbox_enabled(self, true)
	var blocks: Array[int] = []
	var seen := {}
	for tick in range(420):
		for box in get_tree().get_nodes_in_group(&"hitboxes"):
			if enemy.is_ancestor_of(box) and box.blockable and not seen.has(box.get_instance_id()):
				seen[box.get_instance_id()] = true
				box.blocked.connect(func() -> void: blocks.append(1))
		var aim: Vector2 = (
			enemy._aim
			if enemy.state != enemy.State.WALK
			else (Vector2.UP if enemy.position.y > 480 else Vector2.DOWN)
		)
		player.global_position = enemy.global_position + aim * 150
		player.facing = -aim
		await frames(1)
		if not blocks.is_empty():
			break
	check(not blocks.is_empty(), "actual ward blocks naturally fired Automaton jet")
	release_inputs()
	await frames(3)
	player.set_hurtbox_enabled(self, false)
	GameState.set_active_item(&"tether_moth")
	player.place_at(enemy.global_position + Vector2(0, 160))
	player.facing = Vector2.UP
	check(player.use_item(), "real earned moth launches at Automaton")
	await frames(15)
	check(enemy.is_stunned(), "real moth stuns Automaton")
	var used_supply := false
	for attempt in range(12):
		if enemy.is_dying():
			break
		if GameState.pitch_pots == 0:
			for refill in pickups(room):
				if refill.kind == &"pitch_pot_bundle" and refill.persistent_id == &"":
					player.place_at(refill.global_position)
					await frames(5)
					used_supply = true
					break
		await bomb(enemy)
	check(used_supply, "pre-Reel fight actually uses authored workbench pot refill")
	check(GameState.has_flag(&"mini_cave_9_4"), "real moth and pots earn Automaton defeat")
	await seconds(1.7)
	await capture_state("automaton-defeated")


func cell() -> void:
	var room := await enter(&"cave_9_2")
	var eye = scripted(room, "eye_switch.gd")
	var door := door_to(room, &"cave_9_2#cell")
	player.place_at(door.global_position)
	await frames(5)
	check_eq(world.get_current_room_id(), &"cave_9_2", "closed eye cell rejects overlap")
	await shoot(eye.global_position)
	check(GameState.has_flag(&"eye_e231"), "actual slug opens eye cell")
	await pocket(&"cave_9_2", &"cave_9_2#cell")
	room = world.get_room(&"cave_9_2#cell")
	var brass := GameState.currency
	await collect(room, &"cache_cave_9_2_brass")
	check_eq(GameState.currency, brass + 80, "actual separate cell pays 80 brass")
	await pocket(&"cave_9_2#cell", &"cave_9_2")


func crossings() -> void:
	var room := await enter(&"cave_9_5")
	await leap(room, Vector2(960, 336), Vector2.UP)
	await cross(&"move_up", &"cave_9_6")
	room = world.get_room(&"cave_9_6")
	await collect(room, &"key_c9_2")
	check_eq(GameState.keys_in(&"c9"), 1, "second actual c9 key")
	await leap(room, Vector2(960, 624), Vector2.DOWN)
	await cross(&"move_down", &"cave_9_5")
	room = world.get_room(&"cave_9_5")
	var stone = scripted(room, "heavy_stone.gd")
	await swing_from(stone.global_position, Vector2.DOWN)
	check(not GameState.has_flag(&"moved_e228"), "hook cannot clear heavy stone")
	player.place_at(stone.global_position + Vector2(0, -100))
	player.facing = Vector2.DOWN
	GameState.set_active_item(&"heft_mitts")
	check(player.use_item(), "actual mitts lift heavy gate")
	await frames(24)
	check(stone.is_carried(), "actual heavy stone carried")
	# A sideways throw lands in the active room before taking the next screen.
	player.facing = Vector2.RIGHT
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await seconds(1.3)
	check(GameState.has_flag(&"moved_e228"), "actual throw persists paired heavy opening")
	await edge(&"cave_9_5", &"cave_9_8", Vector2.DOWN)
	room = world.get_room(&"cave_9_8")
	await contact(scripted(room, "locked_door.gd"), Vector2.LEFT)
	check_eq(GameState.keys_in(&"c9"), 0, "second scoped key spent once")
	check_eq(GameState.keys_in(&"c1"), 1, "both C09 locks preserve actual foreign key")
	await edge(&"cave_9_8", &"cave_9_9", Vector2.LEFT)
	room = world.get_room(&"cave_9_9")
	await blocked(
		Vector2(960, 730), &"move_down", scripted(room, "boss_door.gd"), "foreign C08 Lockpick"
	)
	check(not GameState.has_big_key(&"c9"), "foreign Lockpick never grants C09 authority")
	await edge(&"cave_9_9", &"cave_9_8", Vector2.RIGHT)
	await edge(&"cave_9_8", &"cave_9_5", Vector2.UP)
	await leap(world.get_room(&"cave_9_5"), Vector2(960, 336), Vector2.UP)
	await cross(&"move_up", &"cave_9_6")
	room = world.get_room(&"cave_9_6")
	await reel(room, Vector2(1200, 432), Vector2.RIGHT, 1608)
	await edge(&"cave_9_6", &"cave_9_7", Vector2.RIGHT)
	room = world.get_room(&"cave_9_7")
	await reel(room, Vector2(336, 432), Vector2.RIGHT, 744)
	await collect(room, &"bigkey_c9")
	check(GameState.has_big_key(&"c9"), "actual Anchor Shaft Lockpick acquired")
	await reel(room, Vector2(720, 432), Vector2.LEFT, 312)
	await edge(&"cave_9_7", &"cave_9_6", Vector2.LEFT)
	room = world.get_room(&"cave_9_6")
	await reel(room, Vector2(1584, 432), Vector2.LEFT, 1176)
	await leap(room, Vector2(960, 624), Vector2.DOWN)
	await cross(&"move_down", &"cave_9_5")
	await edge(&"cave_9_5", &"cave_9_8", Vector2.DOWN)
	await edge(&"cave_9_8", &"cave_9_9", Vector2.LEFT)


func leap(room: Room, at: Vector2, direction: Vector2) -> void:
	player.place_at(room.global_position + at)
	player.facing = direction
	GameState.set_active_item(&"skitter_boots")
	var health := GameState.health
	check(player.use_item(), "actual boots launch over authored pit")
	await frames(3)
	check(player.is_airborne(), "real pit crossing airborne")
	await seconds(.9)
	check_eq(GameState.health, health, "real pit crossing lands without fall damage")
	check(
		player.global_position.distance_to(room.global_position + at + direction * 192) < 2,
		"boots cross full pit"
	)


func reel(room: Room, at: Vector2, direction: Vector2, landing_x: float) -> void:
	player.place_at(room.global_position + at)
	player.facing = direction
	GameState.set_active_item(&"reel_line")
	var health := GameState.health
	check(player.use_item(), "actual acquired Reel Line launches across e227 chasm")
	await seconds(1.4)
	check_near(
		player.global_position.x - room.global_position.x,
		landing_x,
		2,
		"real ring pulls to safe far bank"
	)
	check_eq(GameState.health, health, "anchor pull crosses pit without fall damage")


func vault_and_door() -> void:
	var room := await enter(&"cave_9_9")
	# C08 Lockpick has been acquired at its actual pedestal, but does not authorize C09.
	check(GameState.has_big_key(&"c8"), "foreign actual Lockpick retained")
	var stone = scripted(room, "resonance_stone.gd")
	var door := door_to(room, &"cave_9_9#vault")
	player.place_at(door.global_position)
	await frames(5)
	check_eq(world.get_current_room_id(), &"cave_9_9", "quiet vault rejects overlap")
	player.place_at(stone.global_position + Vector2(0, 192))
	GameState.set_active_item(&"lantern_chime")
	check(player.use_item(), "actual chime rings beside vault")
	await seconds(.7)
	check(stone.is_awake, "actual chime opens resonance vault")
	await pocket(&"cave_9_9", &"cave_9_9#vault")
	room = world.get_room(&"cave_9_9#vault")
	for id in [&"cache_cave_9_9_pots", &"slug_bundle_cave_9_9"]:
		await collect(room, id)
	check(
		GameState.has_flag(&"picked_cache_cave_9_9_ember1"),
		"actual co-located first ember collected"
	)
	check(
		GameState.has_flag(&"picked_cache_cave_9_9_ember2"),
		"actual co-located second ember collected"
	)
	await pocket(&"cave_9_9#vault", &"cave_9_9")
	room = world.get_room(&"cave_9_9")
	await contact(scripted(room, "boss_door.gd"), Vector2.DOWN)
	check(GameState.has_flag(&"door_boss_c9"), "actual scoped Lockpick opens boss door")
	check(GameState.has_big_key(&"c9"), "actual Lockpick retained after contact")
	await edge(&"cave_9_9", &"cave_9_10", Vector2.DOWN)


func pocket(host: StringName, target: StringName) -> void:
	var room := await enter(host)
	var door := door_to(room, target)
	player.place_at(door.global_position + Vector2(0, 120))
	await frames(3)
	player.place_at(door.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), target, "actual separate pocket door: " + target)
	await seconds(.4)
	check_eq(world.get_current_room_id(), target, "safe pocket marker avoids bounce")
	await capture_state(String(target).replace("#", "-"))


func shoot(at: Vector2) -> void:
	player.place_at(at + Vector2(-240, 0))
	player.facing = Vector2.RIGHT
	GameState.set_active_item(&"tallow_sling")
	var slugs := GameState.slugs
	check(player.use_item(), "actual earned sling fires")
	check_eq(GameState.slugs, slugs - 1, "real sling spends one slug")
	await seconds(.6)


func lock_floor() -> void:
	var room := await enter(&"cave_9_10")
	var boss = scripted_enemy(room, "lock_warden.gd")
	check(boss != null, "actual room-owned Lock Warden")
	if boss == null:
		return
	for reward in pickups(room):
		if reward.kind in [&"fragment", &"wick_core"]:
			check(not reward.visible, "rewards hidden before earned defeat")
	await seconds(1.6)
	check_eq(boss.plates.size(), 4, "natural intro creates exactly four lock plates")
	await clear_summons(room)
	for index in range(4):
		var plate = boss.plates[0]
		await shoot(plate.eye.global_position)
		check(plate.lid_left > 0, "actual slug opens real plate lid")
		await bomb(plate)
		check_eq(boss.plates.size(), 3 - index, "actual pot breaks opened plate")
	check_eq(boss.phase, 2, "four actual plate breaks earn phase two")
	check_eq(boss.hp, 24, "natural keyhole retains contracted health")
	await seconds(1.3)
	await clear_summons(room)
	for attempt in range(100):
		if boss.is_dying():
			break
		if boss.is_pausing() or boss.open_left <= .5:
			player.place_at(room.global_position + Vector2(300, 480))
			await frames(15)
			continue
		await hook_enemy(boss)
	check(
		GameState.has_flag(&"boss_cave_9_10_defeated"),
		"actual sling pots and hook earn boss defeat"
	)
	await seconds(1.7)
	await capture_state("lock-warden-rewards")
	var maximum := GameState.max_health
	await collect(room, &"frag_c9")
	await collect(room, &"wick_core_c9")
	check(GameState.has_flag(&"frag_c9"), "actual ninth fragment acquired")
	check_eq(GameState.max_health, maximum + 2, "single actual boss core adds one heart")


func persistence() -> void:
	check(isolated_test_profile(), "disk proof requires isolated user data")
	if not isolated_test_profile():
		return
	var before := SaveGame._snapshot()
	SaveGame.enabled = true
	check(SaveGame.save(), "full earned C09 state saves to isolated disk")
	reset_state()
	check(SaveGame.load_into_state(), "actual full C09 disk reload")
	var after := SaveGame._snapshot()
	check_near(after.playtime, before.playtime, .000001, "JSON playtime precision")
	before.playtime = after.playtime
	check_eq(after, before, "every persistent field survives disk roundtrip")
	SaveGame.enabled = false
	await dispose(world)
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	for number in range(1, 11):
		var room := await enter(StringName("cave_9_%d" % number))
		await capture_state(String(room.room_id))
		if number in [4, 10]:
			check_eq(room.get_enemies().size(), 0, "earned mini/boss absent after disk and unload")
		for reward in pickups(room):
			if reward.kind in [&"fragment", &"wick_core", &"big_key", &"key"]:
				check(not reward.visible, "disk reentry cannot duplicate progression pickup")
	var hall := world.get_room(&"cave_9_9")
	check(scripted(hall, "locked_door.gd").is_open, "disk restores second scoped contact lock")
	check(scripted(hall, "boss_door.gd").is_open, "disk restores boss contact lock")
	check(scripted(hall, "resonance_stone.gd").is_awake, "disk restores actual resonance opening")
	for id in [
		&"picked_cache_cave_9_2_brass",
		&"picked_cache_cave_9_9_pots",
		&"eye_e231",
		&"burned_e223",
		&"moved_e228"
	]:
		check(GameState.has_flag(id), "disk restores actual gate/cache flag " + String(id))
	var earned := summary()
	var disk_before_death := SaveGame._snapshot()
	player.set_hurtbox_enabled(self, true)
	player.take_damage(99, player.global_position + Vector2(10, 0))
	await await_respawn()
	earned.health = GameState.max_health
	check_eq(summary(), earned, "actual death preserves earned progression")
	var disk_after_death := SaveGame._snapshot()
	disk_before_death.health = GameState.max_health
	disk_before_death.current_room = "ow_0_2"
	check(disk_after_death.playtime >= disk_before_death.playtime, "death advances playtime")
	disk_before_death.playtime = disk_after_death.playtime
	check_eq(
		disk_after_death,
		disk_before_death,
		"death preserves every persistent field except health, room and elapsed time"
	)
	check_eq(
		world.get_current_room_id(), &"ow_0_2", "death returns to actual workshop mouth checkpoint"
	)
	await mouth()
	await edge(&"cave_9_2", &"cave_9_1", Vector2.LEFT)
	var room := world.get_room(&"cave_9_1")
	player.place_at(door_to(room, &"ow_0_2").global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"ow_0_2", "actual final cave return reaches overworld")


func capture_state(label: String) -> void:
	if OS.get_environment("WICK_C09_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		world.get_viewport().get_texture().get_image().save_png("/tmp/wick-c09-" + label + ".png"),
		OK,
		"actual C09 capture " + label
	)


func collect(room: Room, id: StringName) -> void:
	for node in pickups(room):
		if is_instance_valid(node) and node.persistent_id == id:
			player.place_at(node.global_position + Vector2(0, 44))
			await frames(5)
			check(
				GameState.has_flag(StringName("picked_" + String(id))),
				"actual pickup collected: " + String(id)
			)
			return
	check(false, "actual pickup exists: " + String(id))


func make_world() -> World:
	var scene := load("res://scenes/world/world.tscn") as PackedScene
	check(scene != null, "actual World scene available")
	if scene == null:
		return null
	var instance := scene.instantiate() as World
	if OS.get_environment("WICK_C09_CAPTURE") == "1":
		var view := SubViewport.new()
		view.size = Vector2i(1920, 1080)
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(view)
		view.add_child(instance)
	else:
		add_child(instance)
	await frames(2)
	return instance


func clear_summons(room: Room) -> void:
	for enemy in room.get_enemies():
		if (
			enemy.get_script() == null
			or not enemy.get_script().resource_path.ends_with("wickling.gd")
		):
			continue
		for attempt in range(20):
			if not is_instance_valid(enemy) or enemy.is_dead:
				break
			await hook_enemy(enemy)
		check(
			not is_instance_valid(enemy) or enemy.is_dead,
			"real hook kills naturally summoned wickling"
		)
