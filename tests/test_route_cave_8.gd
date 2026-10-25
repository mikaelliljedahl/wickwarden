## timeout=360
extends "res://tests/test_route_cave_5.gd"
## Controlled positions, ordinary mobs removed, hurtbox suppressed except explicit death.
## Prior-cave sling/chime/boots are real pickup-contact fixtures, not claimed prior-cave routes.
## C08 keys/reel/MB/boss use actual tools, AI and hitboxes; no boss HP/phase/flag injection.


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	await acquire_kit()
	for prerequisite in [
		[&"cave_2_5", &"tallow_sling"],
		[&"cave_6_5", &"lantern_chime"],
		[&"cave_7_5", &"skitter_boots"]
	]:
		var source := await enter(prerequisite[0])
		await collect(source, prerequisite[1])
		check(GameState.has_item(prerequisite[1]), "actual prerequisite pedestal contact")
	check(not GameState.has_item(&"reel_line"), "own tool never pregranted")
	await counting_mouth()
	await first_lock()
	await brute()
	await reel_and_vault()
	await final_locks()
	await coinwyrm()
	await c8_persistence()
	await dispose(world)


func counting_mouth() -> void:
	var room := await enter(&"ow_9_7")
	var gate = scripted(room, "resonance_stone.gd")
	if gate == null:
		gate = scripted(room, "resonance_door.gd")
	check(gate != null, "actual resonance mouth gate")
	var door := door_to(room, &"cave_8_1")
	player.place_at(door.global_position)
	await frames(5)
	check_eq(world.get_current_room_id(), &"ow_9_7", "closed resonance rejects mouth overlap")
	await swing_from(gate.global_position, Vector2.UP)
	check(not gate.is_awake, "hook cannot replace chime")
	var peer := world.get_room(&"cave_8_1")
	player.place_at(gate.global_position + Vector2(0, 160))
	GameState.set_active_item(&"lantern_chime")
	check(player.use_item(), "actual acquired chime launches at mouth")
	await seconds(1.2)
	check(gate.is_awake, "natural chime opens actual resonance door")
	check(scripted(peer, "resonance_stone.gd").is_awake, "paired cave mouth shares opened state")
	player.place_at(door.global_position + Vector2(0, 120))
	await frames(3)
	player.place_at(door.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_8_1", "actual mouth enters Counting House")
	check(GameState.has_flag(&"mouth_c8"), "mouth checkpoint earned")
	await edge(&"cave_8_1", &"cave_8_2", Vector2.RIGHT)


func first_lock() -> void:
	var room := await enter(&"cave_8_2")
	await blocked(
		Vector2(1650, 480), &"move_right", scripted(room, "locked_door.gd"), "wrong-scope c8 lock"
	)
	check_eq(GameState.keys_in(&"c1"), 1, "c1 actual key preserved")
	var eye := switch_in(room)
	await swing_from(eye.global_position, Vector2.UP)
	check(not eye.is_on, "hook cannot open sling-only eye")
	await collect(room, &"slug_bundle_cave_8_2")
	var before := GameState.slugs
	player.place_at(eye.global_position + Vector2(0, 160))
	player.facing = Vector2.UP
	GameState.set_active_item(&"tallow_sling")
	check(player.use_item(), "actual slug opens Scale Room eye")
	await seconds(.6)
	check(eye.is_on, "actual eye on")
	check_eq(GameState.slugs, before - 1, "eye consumes one real slug")
	await edge(&"cave_8_2", &"cave_8_3", Vector2.UP)
	room = world.get_room(&"cave_8_3")
	check(GameState.has_flag(&"eye_e212"), "paired eye flag on loft entry")
	for node in room.get_node("Props").get_children():
		if (
			node.get_script() != null
			and node.get_script().resource_path.ends_with("eye_switch.gd")
			and node.blocker
		):
			check(node.is_open, "actual paired loft blocker open")
	await collect(room, &"key_c8_1")
	await edge(&"cave_8_3", &"cave_8_2", Vector2.DOWN)
	room = world.get_room(&"cave_8_2")
	await contact(scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check(
		scripted(world.get_room(&"cave_8_4"), "locked_door.gd").is_open,
		"first lock peer synchronizes"
	)
	check_eq(GameState.keys_in(&"c8"), 0, "first key spent once")
	await edge(&"cave_8_2", &"cave_8_4", Vector2.RIGHT)


func switch_in(room: Room) -> Node2D:
	for node in room.get_node("Props").get_children():
		if (
			node.get_script() != null
			and node.get_script().resource_path.ends_with("eye_switch.gd")
			and not node.blocker
		):
			return node
	return null


func brute() -> void:
	var room := await enter(&"cave_8_4")
	var enemy = scripted_enemy(room, "abacus_brute.gd")
	check(not GameState.has_item(&"reel_line"), "Brute challenge precedes reel pickup")
	for tick in range(400):
		if enemy.state == enemy.State.TELEGRAPH:
			break
		await frames(1)
	player.place_at(enemy.global_position + enemy.facing_dir * 200)
	player.facing = -enemy.facing_dir
	GameState.set_active_item(&"pitch_pot")
	var ammo := GameState.pitch_pots
	check(player.use_item(), "actual pre-reel pot planted during natural warning")
	player.place_at(enemy.global_position + enemy.facing_dir * 400)
	await frames(108)
	check_eq(GameState.pitch_pots, ammo - 1, "real pot ammo spent")
	check_eq(enemy.rail_hp, 0, "live pot breaks front rail")
	check_eq(enemy.hp, 28, "rail absorbs pot without body damage")
	await capture_state("brute-pot")
	await edge(&"cave_8_4", &"cave_8_2", Vector2.LEFT)
	await edge(&"cave_8_2", &"cave_8_4", Vector2.RIGHT)
	room = world.get_room(&"cave_8_4")
	enemy = scripted_enemy(room, "abacus_brute.gd")
	check_eq(enemy.rail_hp, 4, "unfinished actual room reentry restores rail")
	check_eq(enemy.hp, 28, "unfinished actual room reentry restores body")
	for tick in range(400):
		if enemy.state == enemy.State.WHIRL:
			break
		await frames(1)
	player.place_at(enemy.global_position + enemy.facing_dir * 110)
	player.facing = -enemy.facing_dir
	Input.action_press(&"attack")
	await frames(55)
	Input.action_release(&"attack")
	await frames(8)
	check_eq(enemy.rail_hp, 0, "actual charged flare also breaks pre-reel rail")
	check_eq(enemy.hp, 28, "rail absorbs actual flare without body spill")
	for attempt in range(50):
		if not is_instance_valid(enemy) or enemy.is_dying():
			break
		await hook_enemy(enemy)
	check(GameState.has_flag(&"mini_cave_8_4"), "actual hook finish earns Brute defeat")
	await seconds(1.7)
	await edge(&"cave_8_4", &"cave_8_2", Vector2.LEFT)
	check_eq(GameState.keys_in(&"c8"), 0, "paired lock return costs no extra key")
	await edge(&"cave_8_2", &"cave_8_4", Vector2.RIGHT)
	check_eq(
		world.get_room(&"cave_8_4").get_enemies().size(),
		0,
		"defeated Brute absent on physical return"
	)
	await edge(&"cave_8_4", &"cave_8_5", Vector2.RIGHT)


func reel_and_vault() -> void:
	var room := await enter(&"cave_8_5")
	# Negative BossDoor probe is deliberately positioned, before obtaining the actual Lockpick.
	var antechamber := await enter(&"cave_8_11")
	await blocked(
		Vector2(240, 480),
		&"move_left",
		scripted(antechamber, "boss_door.gd"),
		"boss door without Lockpick"
	)
	check(
		not GameState.has_flag(&"door_boss_c8"), "small keys and tools cannot forge BossDoor flag"
	)
	room = await enter(&"cave_8_5")
	await collect(room, &"reel_line")
	check(GameState.has_item(&"reel_line"), "actual Coin Press pedestal grants reel")
	await anchor_pull(room, Vector2(1008, 672), Vector2.UP, Vector2(1008, 144))
	await edge(&"cave_8_5", &"cave_8_6", Vector2.UP)
	room = world.get_room(&"cave_8_6")
	await anchor_pull(room, Vector2(1008, 768), Vector2.UP, Vector2(1008, 240))
	await collect(room, &"key_c8_2")
	await leap_edge(&"cave_8_6", &"cave_8_7", Vector2.RIGHT, Vector2(1584, 480), Vector2(1776, 480))
	room = world.get_room(&"cave_8_7")
	await collect(room, &"bigkey_c8")
	check(GameState.has_big_key(&"c8"), "actual Gilded Walk Lockpick")
	await leap_edge(&"cave_8_7", &"cave_8_6", Vector2.LEFT, Vector2(352, 480), Vector2(160, 480))
	room = world.get_room(&"cave_8_6")
	await anchor_pull(room, Vector2(1008, 288), Vector2.DOWN, Vector2(1008, 816))
	await edge(&"cave_8_6", &"cave_8_5", Vector2.DOWN)
	room = world.get_room(&"cave_8_5")
	await anchor_pull(room, Vector2(1008, 192), Vector2.DOWN, Vector2(1008, 720))
	await edge(&"cave_8_5", &"cave_8_8", Vector2.DOWN)


func anchor_pull(room: Room, at: Vector2, direction: Vector2, target: Vector2) -> void:
	player.place_at(room.global_position + at)
	player.facing = direction
	GameState.set_active_item(&"reel_line")
	await frames(3)
	check(player.use_item(), "actual reel launches across room pit")
	await seconds(.5)
	check(player.is_airborne(), "real anchor pull airborne over pit")
	await seconds(.8)
	check(
		player.global_position.distance_to(room.global_position + target) < 90,
		"real anchor reaches opposite safe bank"
	)
	check(not player.is_dead(), "actual anchor crossing survives")


func leap_edge(
	from: StringName, to: StringName, direction: Vector2, start: Vector2, end: Vector2
) -> void:
	var room := await enter(from)
	player.place_at(room.global_position + start)
	player.facing = direction
	GameState.set_active_item(&"skitter_boots")
	await frames(3)
	check(player.use_item(), "actual acquired boots launch over trench")
	await seconds(.5)
	check(
		player.global_position.distance_to(room.global_position + end) < 40,
		"actual leap lands past pit"
	)
	await cross(action_for(direction), to)


func final_locks() -> void:
	var room := await enter(&"cave_8_8")
	check(GameState.has_big_key(&"c8"), "actual C8 Lockpick is held before the ordinary locks")
	check_eq(GameState.keys_in(&"c8"), 1, "second earned C8 key is held before Lockpick use")
	await contact(scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check_eq(GameState.keys_in(&"c8"), 1, "C8 Lockpick opens the second lock without spending its key")
	check(scripted(world.get_room(&"cave_8_9"), "locked_door.gd").is_open, "second lock peer open")
	await edge(&"cave_8_8", &"cave_8_9", Vector2.RIGHT)
	room = world.get_room(&"cave_8_9")
	await collect(room, &"key_c8_3")
	check(GameState.has_big_key(&"c8"), "C8 Lockpick remains held before the third ordinary lock")
	check_eq(GameState.keys_in(&"c8"), 2, "both earned C8 keys are held before Lockpick use")
	await edge(&"cave_8_9", &"cave_8_10", Vector2.DOWN)
	room = world.get_room(&"cave_8_10")
	await contact(scripted(room, "locked_door.gd"), Vector2.LEFT)
	check_eq(GameState.keys_in(&"c8"), 2, "C8 Lockpick opens the third lock without spending keys")
	check_eq(GameState.keys_in(&"c1"), 1, "all three spends preserve independent c1 key")
	check(scripted(world.get_room(&"cave_8_11"), "locked_door.gd").is_open, "third lock peer open")
	await edge(&"cave_8_10", &"cave_8_11", Vector2.LEFT)
	room = world.get_room(&"cave_8_11")
	await contact(scripted(room, "boss_door.gd"), Vector2.LEFT)
	check(scripted(world.get_room(&"cave_8_12"), "boss_door.gd").is_open, "paired BossDoor open")
	check(GameState.has_big_key(&"c8"), "Lockpick retained")
	await edge(&"cave_8_11", &"cave_8_12", Vector2.LEFT)


func coinwyrm() -> void:
	var room := await enter(&"cave_8_12")
	var boss = scripted_enemy(room, "coinwyrm.gd")
	for reward: PickupBase in pickups(room):
		if reward.kind in [&"fragment", &"wick_core"]:
			check(not reward.visible, "actual rewards hidden before defeat")
	var rejected := false
	var saw_four := false
	var retreated := false
	for attempt in range(1000):
		if not is_instance_valid(boss) or boss.is_dying():
			break
		if boss.state != &"rear" or boss.is_pausing():
			await frames(12)
			continue
		if not rejected:
			var hp: int = boss.hp
			await hook_enemy(boss)
			check_eq(boss.hp, hp, "actual hook cannot bypass coin plates")
			rejected = true
		if boss.plates.size() == 4:
			saw_four = true
		if not boss.plates.is_empty():
			var index := 1 if boss.plates.size() >= 3 else 0
			var plate: Node2D = boss.plates[index]
			player.place_at(plate.global_position + Vector2(0, 200))
			player.facing = Vector2.UP
			GameState.set_active_item(&"reel_line")
			check(player.use_item(), "actual reel tip yanks natural plate")
			await seconds(1.4)
			continue
		await hook_enemy(boss)
		if not retreated and boss.hp < 36:
			await edge(&"cave_8_12", &"cave_8_11", Vector2.RIGHT)
			await edge(&"cave_8_11", &"cave_8_12", Vector2.LEFT)
			room = world.get_room(&"cave_8_12")
			boss = scripted_enemy(room, "coinwyrm.gd")
			check_eq(boss.hp, 36, "actual retreat resets incomplete boss HP")
			check_eq(boss.phase, 1, "actual retreat resets phase")
			check(boss.plates.is_empty(), "reentry intro has no stale plates")
			retreated = true
	check(retreated, "actual armour removal and hook precede real retreat")
	check(saw_four, "damage-earned second phase rears four plates")
	check(GameState.has_flag(&"boss_cave_8_12_defeated"), "actual reel and hook finish Coinwyrm")
	if is_instance_valid(boss):
		check(not boss.contact_hitbox.active, "dying Coinwyrm contact harmless")
	await seconds(1.7)
	await capture_state("coinwyrm-rewards")
	var maximum := GameState.max_health
	await collect(room, &"frag_c8")
	await collect(room, &"wick_core_c8")
	check_eq(GameState.max_health, maximum + 2, "one boss core adds one heart")
	check(GameState.has_flag(&"frag_c8"), "actual Fragment of Trade collected")
	await edge(&"cave_8_12", &"cave_8_11", Vector2.RIGHT)
	await edge(&"cave_8_11", &"cave_8_12", Vector2.LEFT)
	check_eq(
		world.get_room(&"cave_8_12").get_enemies().size(), 0, "defeated Coinwyrm retired on return"
	)
	check_eq(GameState.max_health, maximum + 2, "physical return cannot duplicate core")


func c8_persistence() -> void:
	var room := await enter(&"cave_8_1")
	player.place_at(door_to(room, &"ow_9_7").global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"ow_9_7", "actual resonance return mouth")
	check(OS.get_user_data_dir().begins_with("/tmp/"), "isolated disk location")
	if not OS.get_user_data_dir().begins_with("/tmp/"):
		return
	var before := SaveGame._snapshot()
	SaveGame.enabled = true
	check(SaveGame.save(), "actual earned C08 state saved")
	reset_state()
	check(SaveGame.load_into_state(), "full disk roundtrip reloads")
	var after := SaveGame._snapshot()
	check_near(after["playtime"], before["playtime"], .000001, "disk playtime precision")
	before["playtime"] = after["playtime"]
	check_eq(after, before, "all persistent fields roundtrip")
	SaveGame.enabled = false
	await dispose(world)
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	for id in [&"cave_8_4", &"cave_8_12"]:
		room = await enter(id)
		check_eq(room.get_enemies().size(), 0, "disk restores actual encounter retirement")
		for reward: PickupBase in pickups(room):
			if reward.kind in [&"fragment", &"wick_core"]:
				check(not reward.visible, "disk restores collected reward absence")
	var earned := summary()
	player.set_hurtbox_enabled(self, true)
	player.take_damage(99, player.global_position + Vector2(10, 0))
	await await_respawn()
	earned["health"] = GameState.max_health
	check_eq(summary(), earned, "real death preserves acquired route state")
	check_eq(world.get_current_room_id(), &"ow_9_7", "death checkpoint Counting Gate")


func capture_state(label: String) -> void:
	if OS.get_environment("WICK_C08_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		get_viewport().get_texture().get_image().save_png("/tmp/wick-c08-" + label + ".png"),
		OK,
		"actual C08 capture"
	)
