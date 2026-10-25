## timeout=300
extends "res://tests/test_route_cave_5.gd"
## Positioned integration route: regular mobs removed, combat hurtbox suppressed.
## Tools and keys come from pickups; AI, HP, phases and earned flags are never injected.
## This controls execution, not human balance or continuous navigation.


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	var room := await enter(&"ow_0_1")
	await collect(room, &"tether_moth")
	room = await enter(&"cave_5_5")
	await collect(room, &"glow_jar")
	room = await enter(&"ow_10_2")
	var seam = scripted(room, "hidden_seam.gd")
	check(not seam.is_revealed, "C07 stairs start hidden")
	await throw_jar(seam.global_position + Vector2(0, 150), Vector2.UP)
	await seconds(2)
	check(seam.is_revealed, "real earned jar reveals C07 mouth")
	player.place_at(door_to(room, &"cave_7_1").global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_7_1", "actual hidden mouth enters C07")
	check(GameState.has_flag(&"mouth_c7"), "actual entry earns mouth checkpoint")
	await edge(&"cave_7_1", &"cave_7_2", Vector2.LEFT)
	room = world.get_room(&"cave_7_2")
	await blocked(Vector2(240, 480), &"move_left", scripted(room, "locked_door.gd"), "no c7 key")
	await edge(&"cave_7_2", &"cave_7_3", Vector2.UP)
	room = world.get_room(&"cave_7_3")
	player.place_at(room.global_position + Vector2(1008, 432))
	player.facing = Vector2.UP
	GameState.set_active_item(&"tether_moth")
	check(player.use_item(), "real moth fetches first key over pit and grate")
	await seconds(1.7)
	check_eq(GameState.keys_in(&"c7"), 1, "actual moth returns first c7 key")
	await edge(&"cave_7_3", &"cave_7_2", Vector2.DOWN)
	room = world.get_room(&"cave_7_2")
	await contact(scripted(room, "locked_door.gd"), Vector2.LEFT)
	check_eq(GameState.keys_in(&"c7"), 0, "first earned key spent once")
	await edge(&"cave_7_2", &"cave_7_4", Vector2.LEFT)
	await squire()
	await edge(&"cave_7_4", &"cave_7_5", Vector2.LEFT)
	room = world.get_room(&"cave_7_5")
	check(not GameState.has_item(&"skitter_boots"), "Squire defeated before boots")
	await collect(room, &"skitter_boots")
	check(GameState.has_item(&"skitter_boots"), "actual rack grants boots")
	await leap(Vector2(960, 336), Vector2.UP)
	await edge(&"cave_7_5", &"cave_7_6", Vector2.UP)
	room = world.get_room(&"cave_7_6")
	await collect(room, &"key_c7_2")
	check_eq(GameState.keys_in(&"c7"), 1, "actual second key earned")
	await leap(Vector2(336, 480), Vector2.LEFT)
	await edge(&"cave_7_6", &"cave_7_7", Vector2.LEFT)
	room = world.get_room(&"cave_7_7")
	var brass := GameState.currency
	await collect(room, &"cache_cave_7_7_brass")
	check(GameState.currency > brass, "actual optional Bridge cache collected")
	await leap(Vector2(1584, 480), Vector2.RIGHT)
	await edge(&"cave_7_7", &"cave_7_6", Vector2.RIGHT)
	await leap(Vector2(960, 624), Vector2.DOWN)
	await edge(&"cave_7_6", &"cave_7_5", Vector2.DOWN)
	await edge(&"cave_7_5", &"cave_7_8", Vector2.DOWN)
	room = world.get_room(&"cave_7_8")
	await contact(scripted(room, "locked_door.gd"), Vector2.LEFT)
	check_eq(GameState.keys_in(&"c7"), 0, "second earned key spent once")
	await edge(&"cave_7_8", &"cave_7_9", Vector2.LEFT)
	await collect(world.get_room(&"cave_7_9"), &"bigkey_c7")
	check(GameState.has_big_key(&"c7"), "actual Cold Cell Lockpick earned")
	await edge(&"cave_7_9", &"cave_7_8", Vector2.RIGHT)
	await edge(&"cave_7_8", &"cave_7_10", Vector2.RIGHT)
	room = world.get_room(&"cave_7_10")
	await contact(scripted(room, "boss_door.gd"), Vector2.DOWN)
	await edge(&"cave_7_10", &"cave_7_11", Vector2.DOWN)
	await knight()
	await persistence()
	await dispose(world)


func squire() -> void:
	var room := await enter(&"cave_7_4")
	var enemy = scripted_enemy(room, "pale_squire.gd")
	check(enemy != null, "actual room-owned Pale Squire")
	if enemy == null:
		return
	for cycle in range(3):
		check(not GameState.has_item(&"skitter_boots"), "moth fall is pre-boots")
		# Room's real respawn marker is north-west; lure back to the horizontal chasm.
		player.place_at(room.global_position + Vector2(1200, 480))
		var launched := false
		for tick in range(900):
			if enemy.state == enemy.State.LUNGE and not launched:
				player.facing = player.global_position.direction_to(enemy.global_position)
				GameState.set_active_item(&"tether_moth")
				launched = player.use_item()
			if enemy.state == enemy.State.FALLEN or enemy.is_dying():
				break
			await frames(1)
		check(launched, "actual moth launched at natural lunge")
		check_eq(enemy.hp, maxi(1, 16 - 6 * (cycle + 1)), "natural pit fall deals six")
		if enemy.is_dying():
			break
		check(enemy.state == enemy.State.FALLEN, "actual stun over authored pit causes fall")
		await seconds(3.1)
	check(GameState.has_flag(&"mini_cave_7_4"), "three actual moth falls earn Squire defeat")
	await seconds(1.7)


func leap(local: Vector2, direction: Vector2) -> void:
	var room := world.get_room(world.get_current_room_id())
	player.place_at(room.global_position + local)
	player.facing = direction
	GameState.set_active_item(&"skitter_boots")
	await frames(3)
	var before := player.global_position
	var health := GameState.health
	check(player.use_item(), "actual acquired boots launch")
	await seconds(.45)
	check_near(player.global_position.distance_to(before), 192, 2, "actual leap covers two tiles")
	check_eq(GameState.health, health, "successful leap avoids fall damage")
	await seconds(.55)


func knight() -> void:
	var room := await enter(&"cave_7_11")
	var boss = scripted_enemy(room, "gloam_knight.gd")
	check(boss != null, "actual assembled Gloam Knight")
	if boss == null:
		return
	for reward: PickupBase in pickups(room):
		if reward.kind in [&"fragment", &"wick_core"]:
			check(not reward.visible, "boss rewards dormant before actual defeat")
	await seconds(1.7)
	await leap(Vector2(960, 240), Vector2.DOWN)
	await hook_enemy(boss)
	check(boss.hp < 36, "actual hook after boots leap damages boss")
	var earned := summary()
	player.place_at(room.global_position + Vector2(960, 192))
	await seconds(1.1)
	player.set_hurtbox_enabled(self, true)
	check(
		player.take_damage(99, player.global_position + Vector2(10, 0)),
		"real lethal damage accepted"
	)
	await await_respawn()
	earned["health"] = GameState.max_health
	check_eq(summary(), earned, "real death preserves every earned route field")
	check_eq(world.get_current_room_id(), &"ow_10_2", "death returns to actual C07 mouth")
	player.set_hurtbox_enabled(self, false)
	room = await enter(&"cave_7_11")
	boss = scripted_enemy(room, "gloam_knight.gd")
	check_eq(boss.hp, 36, "unfinished boss resets full HP after death")
	check_eq(boss.phase, 1, "unfinished boss resets phase after death")
	player.place_at(room.global_position + Vector2(960, 192))
	await frames(3)
	var health := GameState.health
	check(player.take_damage(1, player.global_position, 0), "ordinary damage starts real i-frames")
	player.place_at(room.global_position + Vector2(960, 330))
	await frames(3)
	check_eq(GameState.health, health - 3, "genuine arena fall costs two despite hit i-frames")
	check_near(player.global_position.y, room.global_position.y + 192, 1, "real pit returns A")
	await seconds(1.1)

	var recovered := false
	var phase_two := false
	for attempt in range(180):
		if not is_instance_valid(boss) or boss.is_dying():
			break
		if boss.phase == 2:
			phase_two = true
		if boss.mode == &"recover":
			recovered = true
		if boss.hurtbox.enabled and not boss.is_pausing() and not boss.is_in_intro():
			await hook_enemy(boss)
		else:
			player.place_at(room.global_position + Vector2(960, 192))
			await frames(10)
	check(phase_two, "real attacks reach natural second phase")
	check(recovered, "natural dive landing recovery observed")
	check(GameState.has_flag(&"boss_cave_7_11_defeated"), "real hook fight earns canonical defeat")
	await seconds(1.7)
	var maximum := GameState.max_health
	await collect(room, &"frag_c7")
	await collect(room, &"wick_core_c7")
	check(GameState.has_flag(&"frag_c7"), "actual Fragment of Courage collected")
	check_eq(GameState.max_health, maximum + 2, "single actual core adds one heart")


func persistence() -> void:
	await edge(&"cave_7_11", &"cave_7_10", Vector2.UP)
	await edge(&"cave_7_10", &"cave_7_8", Vector2.LEFT)
	await edge(&"cave_7_8", &"cave_7_5", Vector2.UP)
	await edge(&"cave_7_5", &"cave_7_4", Vector2.RIGHT)
	check_eq(world.get_room(&"cave_7_4").get_enemies().size(), 0, "earned Squire stays absent")
	await edge(&"cave_7_4", &"cave_7_2", Vector2.RIGHT)
	await edge(&"cave_7_2", &"cave_7_1", Vector2.RIGHT)
	var room := world.get_room(&"cave_7_1")
	player.place_at(door_to(room, &"ow_10_2").global_position)
	await seconds(1.5)
	check_eq(
		world.get_current_room_id(), &"ow_10_2", "actual full return reaches mouth without bounce"
	)
	check(OS.get_user_data_dir().begins_with("/tmp/"), "disk proof requires isolated userdata")
	if not OS.get_user_data_dir().begins_with("/tmp/"):
		return
	var before := SaveGame._snapshot()
	SaveGame.enabled = true
	check(SaveGame.save(), "full earned state saves to isolated disk")
	reset_state()
	check(SaveGame.load_into_state(), "actual disk state reloads")
	var restored := SaveGame._snapshot()
	check_near(restored["playtime"], before["playtime"], .000001, "playtime JSON precision")
	before["playtime"] = restored["playtime"]
	check_eq(restored, before, "every persistent field survives disk roundtrip")
	SaveGame.enabled = false
	await dispose(world)
	world = await make_world()
	player = world.player
	room = await enter(&"cave_7_11")
	check_eq(room.get_enemies().size(), 0, "disk reload retains actual boss defeat")
	for reward: PickupBase in pickups(room):
		if reward.kind in [&"fragment", &"wick_core"]:
			check(not reward.visible, "disk reload never duplicates rewards")


func door_to(room: Room, target: StringName) -> RoomDoor:
	for node in room.find_children("*", "Area2D", true, false):
		if node is RoomDoor and node.target_room == target:
			return node
	return null


func collect(room: Room, id: StringName) -> void:
	for node: PickupBase in pickups(room):
		if is_instance_valid(node) and node.persistent_id == id:
			player.place_at(node.global_position + Vector2(0, 44))
			await frames(5)
			return
	check(false, "actual pickup exists: " + String(id))


func edge(from: StringName, to: StringName, direction: Vector2) -> void:
	var room := await enter(from)
	var at := Vector2(960, 200) if direction == Vector2.UP else Vector2(960, 740)
	if direction == Vector2.LEFT:
		at = Vector2(240, 480)
	if direction == Vector2.RIGHT:
		at = Vector2(1680, 480)
	# These banks have already been reached through a real boots leap.
	if from == &"cave_7_6" and direction == Vector2.DOWN:
		at.y = 816
	if from == &"cave_7_5" and direction == Vector2.UP:
		at.y = 144
	if from == &"cave_7_6" and direction == Vector2.LEFT:
		at.x = 144
	if from == &"cave_7_7" and direction == Vector2.RIGHT:
		at.x = 1776
	player.place_at(room.global_position + at)
	await cross(action_for(direction), to)


func hook_enemy(enemy: Node2D) -> void:
	var room := world.get_room(world.get_current_room_id())
	for direction: Vector2 in [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]:
		var at := enemy.global_position - direction * 90
		if not Rect2(room.global_position + Vector2(120, 120), Vector2(1680, 720)).has_point(at):
			continue
		var safe := true
		for pit in get_tree().get_nodes_in_group(&"pit_zone"):
			if room.is_ancestor_of(pit) and pit.process_mode != Node.PROCESS_MODE_DISABLED:
				if pit.holds(at):
					safe = false
		if safe:
			await swing_from(enemy.global_position, direction)
			await frames(10)
			return
	player.place_at(room.global_position + Vector2(960, 192))
	await frames(15)
