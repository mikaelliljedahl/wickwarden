## timeout=300
extends TestCase
## Controlled integration probe: positioned starts, regular enemies removed, actual acquired tools.
## Player damage is suppressed except explicit undertow/death checks. Not a human playthrough.
var world: World
var player: Player


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	await acquire_kit()
	var room := await enter(&"ow_3_5")
	var wall = scripted(room, "cracked_wall.gd")
	var cave := world.get_room(&"cave_3_1")
	await swing_from(wall.global_position, Vector2.UP)
	check(not wall.is_open, "hook cannot open bomb-only C03 mouth")
	var door := door_to(room, &"cave_3_1")
	player.place_at(door.global_position)
	await frames(5)
	check_eq(world.get_current_room_id(), &"ow_3_5", "sealed mouth rejects real door overlap")
	await bomb(wall)
	check(wall.is_open, "actual acquired pot opens C03 brittle rocks")
	check(GameState.has_flag(&"cracked_e248"), "mouth persists canonical bomb flag")
	check(scripted(cave, "cracked_wall.gd").is_open, "bomb flag opens preloaded cave-side mouth")
	player.place_at(door.global_position + Vector2(0, 100))
	await frames(3)
	player.place_at(door.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_3_1", "actual opened mouth enters C03")
	room = await enter(&"cave_3_1")
	check(
		(
			player.global_position.distance_to(
				room.get_node("Spawns/FromOverworld").global_position
			)
			< 60
		),
		"named entrance spawn is clear"
	)
	player.place_at(room.global_position + Vector2(1680, 480))
	await cross(&"move_right", &"cave_3_2")
	room = world.get_room(&"cave_3_2")
	await blocked(
		Vector2(1650, 480), &"move_right", scripted(room, "locked_door.gd"), "wrong-scope key lock"
	)
	check_eq(GameState.keys_in(&"c1"), 1, "c3 lock preserves real wrong-scope c1 key")
	await cut_moss(room)
	player.place_at(room.global_position + Vector2(960, 200))
	await cross(&"move_up", &"cave_3_3")
	room = world.get_room(&"cave_3_3")
	await collect(room, &"key_c3_1")
	check_eq(GameState.keys_in(&"c3"), 1, "actual Mossed Pump Room key credits c3")
	await cut_moss(room)
	player.place_at(room.global_position + Vector2(960, 740))
	await cross(&"move_down", &"cave_3_2")
	room = world.get_room(&"cave_3_2")
	var peer := world.get_room(&"cave_3_4")
	await contact(scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check(scripted(peer, "locked_door.gd").is_open, "real c3 key opens preloaded paired lock")
	check_eq(GameState.keys_in(&"c3"), 0, "one actual c3 key spent once")
	check_eq(GameState.keys_in(&"c1"), 1, "correct c3 spend preserves c1 key")
	check(GameState.has_flag(&"door_e165"), "canonical c3 lock flag")
	await cross(&"move_right", &"cave_3_4")
	room = world.get_room(&"cave_3_4")
	await lurker(room)
	player.place_at(room.global_position + Vector2(240, 480))
	await cross(&"move_left", &"cave_3_2")
	check_eq(GameState.keys_in(&"c3"), 0, "actual paired lock return costs no second key")
	room = world.get_room(&"cave_3_2")
	player.place_at(room.global_position + Vector2(1680, 480))
	await cross(&"move_right", &"cave_3_4")
	room = world.get_room(&"cave_3_4")
	check_eq(room.get_enemies().size(), 0, "real defeated Lurker stays gone on return")
	player.place_at(room.global_position + Vector2(1680, 480))
	await cross(&"move_right", &"cave_3_5")
	room = world.get_room(&"cave_3_5")
	check(not GameState.has_item(&"reed_raft"), "flooded gate tested before raft pickup")
	player.place_at(room.global_position + Vector2(960, 300))
	Input.action_press(&"move_up")
	await seconds(1)
	release_inputs()
	check_eq(
		world.get_current_room_id(), &"cave_3_5", "deep water rejects physical unrafted crossing"
	)
	player.place_at(room.global_position + Vector2(960, 740))
	await cross(&"move_down", &"cave_3_8")
	room = world.get_room(&"cave_3_8")
	await blocked(
		Vector2(1650, 480),
		&"move_right",
		scripted(room, "boss_door.gd"),
		"BossDoor without actual Lockpick"
	)
	check(not GameState.has_flag(&"door_boss_c3"), "base kit and small key cannot forge boss door")
	player.place_at(room.global_position + Vector2(960, 200))
	await cross(&"move_up", &"cave_3_5")
	room = world.get_room(&"cave_3_5")
	await collect(room, &"reed_raft")
	check(GameState.has_item(&"reed_raft"), "actual Dry Dock pedestal grants raft")
	await ride(room, &"cave_3_6", &"e167")
	room = world.get_room(&"cave_3_6")
	await collect(room, &"bigkey_c3")
	check(GameState.has_big_key(&"c3"), "actual Sluice Walk Lockpick acquired")
	await ride(room, &"cave_3_7", &"e168")
	room = world.get_room(&"cave_3_7")
	var maximum := GameState.max_health
	await cut_hidden_core(room)
	if not GameState.has_flag(&"picked_wick_core_c3_hidden"):
		await collect(room, &"wick_core_c3_hidden")
	check_eq(GameState.max_health, maximum + 2, "actual hidden gallery core adds one heart")
	await ride(room, &"cave_3_6", &"e168")
	await ride(world.get_room(&"cave_3_6"), &"cave_3_5", &"e167")
	room = world.get_room(&"cave_3_5")
	player.place_at(room.global_position + Vector2(960, 740))
	await cross(&"move_down", &"cave_3_8")
	room = world.get_room(&"cave_3_8")
	peer = world.get_room(&"cave_3_9")
	await contact(scripted(room, "boss_door.gd"), Vector2.RIGHT)
	check(scripted(peer, "boss_door.gd").is_open, "actual Lockpick synchronizes boss endpoint")
	check(GameState.has_flag(&"door_boss_c3"), "canonical boss door flag")
	check(GameState.has_big_key(&"c3"), "Lockpick retained")
	await cross(&"move_right", &"cave_3_9")
	room = world.get_room(&"cave_3_9")
	await tidewick(room)
	await persistence()
	await dispose(world)


func acquire_kit() -> void:
	var room := await enter(&"ow_0_1")
	await collect(room, &"tether_moth")
	check(GameState.has_item(&"tether_moth"), "actual overworld moth acquired")
	room = await enter(&"cave_1_3")
	player.place_at(room.global_position + Vector2(1008, 528))
	player.facing = Vector2.UP
	check(player.use_item(), "real moth fetches c1 key through actual grate")
	await seconds(1.7)
	check_eq(GameState.keys_in(&"c1"), 1, "actual wrong-scope key available")
	room = await enter(&"cave_1")
	await swing_from(room.get_node("Props/BrazierWest").global_position, Vector2.UP)
	await swing_from(room.get_node("Props/BrazierEast").global_position, Vector2.UP)
	player.place_at(room.global_position + Vector2(960, 240))
	await frames(5)
	check_eq(GameState.keys_in(&"ow"), 1, "real braziers expose historical ow key")
	room = await enter(&"ow_2_1")
	var lock := scripted(room, "locked_door.gd") as LockedDoor
	player.place_at(lock.global_position + Vector2(0, -70))
	await frames(5)
	check(lock.is_open, "real overworld key opens pot closet by contact")
	await collect(room, &"pitch_pot")
	check(GameState.has_item(&"pitch_pot"), "actual pot pickup acquired")
	check_eq(GameState.pitch_pots, 6, "pot pickup supplies six real pots")


func bomb(wall: Node2D) -> void:
	player.place_at(wall.global_position + Vector2(0, 82))
	player.facing = Vector2.UP
	GameState.set_active_item(&"pitch_pot")
	await frames(3)
	var before := GameState.pitch_pots
	check(player.use_item(), "actual acquired pot placed")
	check_eq(GameState.pitch_pots, before - 1, "real bomb spends one pot")
	await seconds(1.9)


func cut_moss(room: Room) -> void:
	var count := 0
	var positions: Array[Vector2] = []
	for node in room.find_children("*", "", true, false):
		if node is Bush and node.variant == &"moss_wall":
			node.drops_enabled = false
			positions.append(node.global_position)
	for at in positions:
		await swing_from(at, Vector2.UP if at.y - room.global_position.y < 480 else Vector2.DOWN)
		count += 1
	check(count > 0, "actual moss gate exists on this endpoint")
	var remaining := 0
	for node in room.find_children("*", "", true, false):
		if node is Bush and node.variant == &"moss_wall":
			remaining += 1
	check_eq(remaining, 0, "actual hook cuts every moss gate body")


func cut_hidden_core(room: Room) -> void:
	var positions: Array[Vector2] = []
	for node in room.get_node("Bushes").get_children():
		if node is Bush:
			node.drops_enabled = false
			positions.append(node.global_position)
	for at in positions:
		await swing_from(at, Vector2.UP)


func lurker(room: Room) -> void:
	var enemy = scripted_enemy(room, "sump_lurker.gd")
	check(enemy != null, "assembled Sump Lurker delivered")
	if enemy == null:
		return
	player.place_at(room.global_position + Vector2(960, 760))
	check(not enemy.hurtbox.enabled, "submerged Lurker starts protected")
	var stunned := false
	for attempt in range(40):
		if not is_instance_valid(enemy) or enemy.is_dead or enemy.is_dying():
			break
		for tick in range(240):
			if enemy.state == enemy.State.SURFACED and enemy._timer > .6:
				break
			await frames(1)
		if enemy.state != enemy.State.SURFACED:
			check(false, "natural Lurker cycle reaches surfaced window")
			break
		if not stunned:
			player.place_at(enemy.global_position + Vector2(0, 150))
			player.facing = Vector2.UP
			GameState.set_active_item(&"tether_moth")
			check(player.use_item(), "actual acquired moth launches at surfaced Lurker")
			await frames(12)
			check(enemy.is_stunned(), "actual moth contact stuns surfaced Lurker")
			stunned = enemy.is_stunned()
		var hp: int = enemy.hp
		await swing_from(enemy.global_position, Vector2.UP)
		if not is_instance_valid(enemy) or enemy.is_dead or enemy.is_dying():
			break
		check(enemy.hp < hp, "actual hook damages naturally surfaced Lurker")
		await frames(20)
	await seconds(1.7)
	check(GameState.has_flag(&"mini_cave_3_4"), "real moth/hook Lurker defeat persists")
	await capture_state("lurker-defeated")


func ride(room: Room, target: StringName, id: StringName) -> void:
	var dock: Node2D
	for node in room.get_node("Props").get_children():
		if (
			node.get_script() != null
			and node.get_script().resource_path.ends_with("mooring.gd")
			and node.mooring_id == id
		):
			dock = node
	check(dock != null, "actual crossing dock exists: " + String(id))
	if dock == null:
		return
	var peer := world.get_room(target)
	var destination: Node2D = dock.find_target()
	check(destination != null, "paired actual mooring resolves")
	if destination == null:
		return
	var landing: Vector2 = destination.landing_position()
	player.place_at(dock.landing_position())
	GameState.set_active_item(&"reed_raft")
	await frames(3)
	check(player.use_item(), "actual acquired raft boards crossing " + String(id))
	await seconds(.4)
	check(player.is_external_motion(), "real raft crossing uses public external motion")
	for tick in range(600):
		await frames(1)
		if world.get_current_room_id() == target and not player.is_external_motion():
			break
	check_eq(world.get_current_room_id(), target, "actual raft traverses flooded graph edge")
	check(not player.is_external_motion(), "paired dock lands actual raft rider")
	check(player.global_position.distance_to(landing) < 10, "raft lands beside opposite post")
	await enter(peer.room_id)


func tidewick(room: Room) -> void:
	var boss = scripted_enemy(room, "tidewick.gd")
	check(boss != null, "actual assembled Tidewick present")
	if boss == null:
		return
	boss.rng.seed = 12345
	var rewards := pickups(room).filter(
		func(n: PickupBase) -> bool: return n.kind in [&"fragment", &"wick_core"]
	)
	check_eq(rewards.size(), 2, "one room fragment and one core, no arena duplicates")
	for reward in rewards:
		check(not reward.visible, "reward remains hidden before actual Tidewick defeat")
	var dock := scripted(room, "mooring.gd") as Node2D
	check(dock != null, "actual basin dock exists")
	if dock == null:
		return
	player.place_at(dock.landing_position())
	await seconds(1.6)
	var hp: int = boss.hp
	await swing_from(player.global_position + Vector2(90, 0), Vector2.RIGHT)
	check_eq(boss.hp, hp, "actual shore hook cannot reach tail across deep basin")
	player.place_at(dock.landing_position())
	GameState.set_active_item(&"reed_raft")
	check(player.use_item(), "actual acquired raft boards basin dock")
	await seconds(.4)
	check(player.is_on_raft(), "actual free-steering raft rider active")
	Input.action_press(&"move_right")
	await seconds(.6)
	release_inputs()
	await seconds(.5)
	check(
		player.global_position.x > room.global_position.x + 360,
		"real steering leaves quay into water"
	)
	for tick in range(360):
		if boss.tail_exposed():
			break
		await frames(1)
	await follow_tail(boss, 2)
	Input.action_press(&"attack")
	await follow_tail(boss, 7)
	Input.action_release(&"attack")
	await follow_tail(boss, 22)
	check_eq(boss.hp, hp - 2, "actual rider hook deals two to exposed tail")
	for tick in range(240):
		if not boss.tail_exposed():
			break
		await frames(1)
	Input.action_press(&"attack")
	await seconds(.9)
	for tick in range(300):
		if boss.tail_exposed():
			break
		await follow_tail(boss, 1)
	await follow_tail(boss, 2)
	hp = boss.hp
	Input.action_release(&"attack")
	await follow_tail(boss, 10)
	check_eq(boss.hp, hp - 4, "actual rider charged flare deals four")
	await capture_state("raft-tail")
	for strike in range(100):
		if boss.phase == 2:
			break
		await rider_hook(boss)
	check_eq(boss.phase, 2, "real rider attacks reach phase two")
	await undertow(room, boss)
	for strike in range(100):
		if boss.is_dying():
			break
		await rider_hook(boss)
	check(
		GameState.has_flag(&"boss_cave_3_9_defeated"),
		"real acquired raft hook and flare defeat both Tidewick phases"
	)
	check(player.is_on_raft(), "actual fight retains rider throughout")
	await seconds(1.6)
	# Swept public raft displacement returns to the actual dock; no private vehicle state.
	player.push_raft(room.global_position + Vector2(288, 432) - player.global_position)
	await frames(3)
	check(not player.is_on_raft(), "actual basin dock lands returning rider")
	player.place_at(room.global_position + Vector2(250, 744))
	await frames(3)
	await capture_state("boss-rewards")
	var maximum := GameState.max_health
	await collect(room, &"frag_c3")
	await collect(room, &"wick_core_c3")
	check(GameState.has_flag(&"frag_c3"), "actual Fragment of Rain collected")
	check_eq(GameState.max_health, maximum + 2, "exactly one boss core adds one heart")
	check_eq(GameState.health, GameState.max_health, "real boss core fully heals")


func rider_hook(boss: Variant) -> void:
	if not boss.tail_exposed() or boss.is_pausing():
		await follow_tail(boss, 10)
		return
	await follow_tail(boss, 2)
	Input.action_press(&"attack")
	await follow_tail(boss, 7)
	Input.action_release(&"attack")
	await follow_tail(boss, 23)


func follow_tail(boss: Variant, ticks: int) -> void:
	for tick in range(ticks):
		if not is_instance_valid(boss) or boss.is_dying():
			break
		player.push_raft(boss.tail.global_position + Vector2(0, 75) - player.global_position)
		player.facing = Vector2.UP
		await frames(1)


func undertow(room: Room, boss: Variant) -> void:
	for tick in range(600):
		if is_instance_valid(boss.wave):
			break
		await frames(1)
	check(is_instance_valid(boss.wave), "actual damage-earned phase two emits natural undertow")
	if not is_instance_valid(boss.wave):
		return
	var direction: Vector2 = boss.wave_direction
	player.push_raft(boss.wave.global_position + direction * 20 - player.global_position)
	await frames(3)
	var before := player.global_position
	await frames(2)
	check_near(
		(player.global_position - before).dot(direction),
		200.0 / 30.0,
		.5,
		"assembled undertow applies 200px/s with damage disabled"
	)
	var hits: Array[int] = []
	player.hurt_taken.connect(func(amount: int) -> void: hits.append(amount))
	Input.action_press(&"ward")
	player.facing = -direction
	await frames(2)
	check(player.ward_up, "actual rider ward raised before undertow")
	player.set_hurtbox_enabled(self, true)
	before = player.global_position
	await frames(5)
	release_inputs()
	check_eq(hits, [3], "actual undertow bypasses ward exactly once during iframes")
	var displacement := (player.global_position - before).dot(direction)
	check(
		displacement >= 96 and displacement < 130,
		"accepted wave hit adds 96 once alongside sustained flow without duplicate push"
	)
	var water := scripted(room, "water_zone.gd")
	check(water.contains_point(player.global_position), "actual wave keeps rider within basin")
	player.set_hurtbox_enabled(self, false)
	await capture_state("raft-undertow")


func door_to(room: Room, target: StringName) -> RoomDoor:
	for node in room.get_node("Props").get_children():
		if node is RoomDoor and node.target_room == target:
			return node
	return null


func swing_from(at: Vector2, direction: Vector2) -> void:
	player.place_at(at - direction * 90)
	player.facing = direction
	await frames(3)
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	await frames(14)


func enter(id: StringName) -> Room:
	if world.get_current_room_id() != id:
		world.start_at(id)
	var room := world.get_room(id)
	for enemy in room.get_enemies():
		if (
			enemy.scene_file_path.contains("/minibosses/")
			or enemy.scene_file_path.contains("/bosses/")
		):
			continue
		enemy.drops_enabled = false
		enemy.kill()
	await frames(4)
	return room


func pickups(root: Node) -> Array[PickupBase]:
	var result: Array[PickupBase] = []
	if root is PickupBase:
		result.append(root)
	for child in root.get_children():
		result.append_array(pickups(child))
	return result


func collect(room: Room, id: StringName) -> void:
	var found := false
	for node in pickups(room):
		if node.persistent_id == id:
			found = true
			player.place_at(node.global_position + Vector2(0, 44))
			await frames(5)
	check(found, "real pickup exists: " + String(id))


func scripted(root: Node, suffix: String) -> Node:
	for node in root.get_children():
		var script: Script = node.get_script()
		if script != null and script.resource_path.ends_with(suffix):
			return node
		var nested := scripted(node, suffix)
		if nested != null:
			return nested
	return null


func scripted_enemy(room: Room, suffix: String) -> EnemyBase:
	for enemy in room.get_enemies():
		if enemy.get_script().resource_path.ends_with(suffix):
			return enemy
	return null


func contact(target: Node2D, direction: Vector2) -> void:
	player.place_at(target.global_position - direction * 180)
	Input.action_press(action_for(direction))
	for tick in range(90):
		await frames(1)
		if target.is_open:
			break
	release_inputs()
	await frames(2)
	check(target.is_open, "physical contact opens " + String(target.name))


func blocked(at: Vector2, action: StringName, target: Node, label: String) -> void:
	var id := world.get_current_room_id()
	var room := world.get_room(id)
	player.place_at(room.global_position + at)
	Input.action_press(action)
	await seconds(1)
	release_inputs()
	check_eq(world.get_current_room_id(), id, label + " rejects physical crossing")
	check(not target.is_open, label + " remains shut")


func action_for(direction: Vector2) -> StringName:
	if direction == Vector2.RIGHT:
		return &"move_right"
	if direction == Vector2.LEFT:
		return &"move_left"
	return &"move_down" if direction == Vector2.DOWN else &"move_up"


func cross(action: StringName, target: StringName) -> void:
	Input.action_press(action)
	for tick in range(240):
		await frames(1)
		if world.get_current_room_id() == target:
			break
	release_inputs()
	await seconds(.4)
	check_eq(world.get_current_room_id(), target, "real exit crossing to " + String(target))
	if world.get_current_room_id() == target:
		await enter(target)


func persistence() -> void:
	check(not SaveGame.enabled, "route leaves normal disk writes disabled")
	var before := summary()
	await enter(&"cave_3_5")
	check_eq(GameState.keys_in(&"c3"), 0, "paired lock reentry never spends twice")
	var room := await enter(&"cave_3_7")
	check(
		GameState.has_flag(&"picked_wick_core_c3_hidden"),
		"hidden core remains collected on real gallery return"
	)
	for reward in pickups(room):
		if reward.persistent_id == &"wick_core_c3_hidden":
			check(not reward.visible, "hidden gallery core cannot be collected twice")
	room = await enter(&"cave_3_1")
	var mouth := door_to(room, &"ow_3_5")
	player.place_at(mouth.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"ow_3_5", "actual opened mouth returns to overworld")
	room = await enter(&"cave_3_9")
	check_eq(room.get_enemies().size(), 0, "defeated Tidewick and summoned leeches stay absent")
	for reward in pickups(room):
		if reward.persistent_id in [&"frag_c3", &"wick_core_c3"]:
			check(not reward.visible, "collected persistent reward stays absent")
	check_eq(GameState.max_health, before["max"], "reentry cannot duplicate core")
	if OS.get_environment("WICK_C03_DISK") == "1":
		var isolated := OS.get_environment("XDG_DATA_HOME")
		var safe := (
			isolated.begins_with("/tmp/wick-c03-")
			and OS.get_user_data_dir().begins_with(isolated + "/")
		)
		check(safe, "disk proof requires isolated temporary userdata root")
		if safe:
			before = summary()
			SaveGame.enabled = true
			check(SaveGame.save(), "actual acquired route saves in isolated slot")
			reset_state()
			check(SaveGame.load_into_state(), "isolated disk slot reloads")
			check_eq(summary(), before, "full route state survives actual disk roundtrip")
			SaveGame.enabled = false
	var maximum := GameState.max_health
	var before_death := summary()
	player.set_hurtbox_enabled(self, true)
	player.take_damage(99, player.global_position + Vector2(10, 0))
	for tick in range(400):
		await frames(1)
		if not player.is_dead() and not world.is_transitioning():
			break
	check_eq(world.get_current_room_id(), &"ow_3_5", "actual death returns to C03 mouth checkpoint")
	check_eq(GameState.health, maximum, "death restores full health")
	before_death["health"] = maximum
	check_eq(summary(), before_death, "actual death preserves complete acquired route state")
	for flag in [
		&"cracked_e248",
		&"door_e165",
		&"door_boss_c3",
		&"mini_cave_3_4",
		&"boss_cave_3_9_defeated",
		&"frag_c3"
	]:
		check(GameState.has_flag(flag), "death preserves real route flag " + String(flag))


func summary() -> Dictionary:
	var keys := {}
	for scope in GameState.KEY_SCOPES:
		keys[scope] = GameState.keys_in(scope)
	return {
		"keys": keys,
		"health": GameState.health,
		"max": GameState.max_health,
		"slugs": GameState.slugs,
		"pots": GameState.pitch_pots,
		"flags": GameState.flags.duplicate(),
		"items": GameState.acquired_item_ids(),
		"wallet": GameState.currency,
		"checkpoint": SaveGame.checkpoint_room()
	}


func capture_state(label: String) -> void:
	if OS.get_environment("WICK_C03_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		get_viewport().get_texture().get_image().save_png("/tmp/wick-c03-" + label + ".png"),
		OK,
		"actual capture " + label
	)
