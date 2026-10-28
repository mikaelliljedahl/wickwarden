## timeout=240
extends TestCase
## Physical edge/tool acceptance; combat starts are positioned, regular enemies removed.
## This is a controlled integration probe, not a human playthrough.
var world: World
var player: Player


func run() -> void:
	await reverse_pairs()
	reset_state()
	SaveGame.enabled = false
	world = await make_world()
	player = world.player
	var room: Room = await enter(&"ow_0_1")
	var moth := pickup(room, &"tether_moth")
	player.place_at(moth.global_position + Vector2(0, 46))
	await frames(4)
	check(GameState.has_item(&"tether_moth"), "actual overworld moth pickup acquired")
	room = await enter(&"ow_1_1")
	for node in room.get_node("Props").get_children():
		if node is RoomDoor and node.target_room == &"cave_1":
			player.place_at(node.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_1", "real mouth enters pilot")
	room = await enter(&"cave_1")
	check(
		(player.global_position-room.global_position).distance_to(Vector2(960,600))<50,
		"mouth physically arrives at FromOverworld marker"
	)
	check_eq(
		room.get_node("Spawns/Default").position, Vector2(960, 600), "historical default retained"
	)
	check_eq(
		room.get_node("Spawns/FromOverworld").position, Vector2(960, 600), "mouth marker retained"
	)
	await swing(room.get_node("Props/BrazierWest"))
	await swing(room.get_node("Props/BrazierEast"))
	player.place_at(room.global_position + Vector2(960, 480))
	await walk(Vector2(960, 240))
	await frames(4)
	check_eq(GameState.keys_in(&"ow"), 1, "real historical overworld key collected")
	room = await enter(&"cave_1_4")
	var wrong_lock: LockedDoor
	for node in room.get_node("Props").get_children():
		if node is LockedDoor:
			wrong_lock = node
	player.place_at(room.global_position + Vector2(1650, 480))
	Input.action_press(&"move_right")
	await seconds(1.2)
	release_inputs()
	check(not wrong_lock.is_open, "real ow key cannot open c1 lock")
	check(
		player.global_position.x - room.global_position.x < 1800,
		"closed east lock physically blocks walking"
	)
	check_eq(GameState.keys_in(&"ow"), 1, "wrong scope key is not spent")
	room = await enter(&"cave_1")
	# Walk the actual new west corridor and slide to the turning hall.
	player.place_at(room.global_position + Vector2(960, 528))
	await walk(Vector2(250, 528))
	await cross(&"move_left", &"cave_1_2")
	room = await enter(&"cave_1_2")
	await walk(Vector2(960, 480))
	await walk(Vector2(960, 180))
	await cross(&"move_up", &"cave_1_3")
	room = await enter(&"cave_1_3")
	await walk(Vector2(1008, 528))
	Input.action_press(&"move_up")
	await seconds(1)
	release_inputs()
	check(
		player.global_position.y - room.global_position.y >= 400,
		"real player body cannot walk through permanent grate"
	)
	check_eq(GameState.keys_in(&"c1"), 0, "key remains sealed from walking")
	player.place_at(room.global_position + Vector2(1008, 528))
	player.facing = Vector2.UP
	await frames(3)
	check(player.use_item(), "real moth launches through grate")
	await seconds(1.7)
	check(GameState.has_flag(&"picked_key_c1_1"), "real moth returns with the c1 key")
	check_eq(GameState.keys_in(&"c1"), 1, "carried pickup credits c1")
	check_eq(GameState.keys_in(&"ow"), 1, "carried pickup does not credit ow")
	await walk(Vector2(960, 780))
	await cross(&"move_down", &"cave_1_2")
	room = await enter(&"cave_1_2")
	await walk(Vector2(960, 480))
	await walk(Vector2(1680, 480))
	await cross(&"move_right", &"cave_1")
	room = await enter(&"cave_1")
	await walk(Vector2(960, 528))
	await walk(Vector2(1680, 528))
	await cross(&"move_right", &"cave_1_4")
	room = await enter(&"cave_1_4")
	var braziers: Array = []
	var gate: Gate
	var lock: LockedDoor
	for node in room.get_node("Props").get_children():
		if node is Brazier:
			braziers.append(node)
		if node is Gate:
			gate = node
		if node is LockedDoor:
			lock = node
	check_eq(braziers.size(), 2, "north gate has two real braziers")
	check(not gate.is_open, "north gate initially closed")
	await swing(braziers[0])
	check(braziers[0].lit and not gate.is_open, "one real hook-lit brazier leaves north shut")
	await swing(braziers[1])
	check(gate.is_open, "both real hook-lit braziers open north")
	await capture_state("puzzle-open")
	player.place_at(room.global_position + Vector2(960, 528))
	await walk(Vector2(960, 160))
	check(
		player.global_position.y - room.global_position.y < 190,
		"north approach walkable after opening"
	)
	# Recheck the preserved historical pickup before spending the independently fetched c1 key.
	room = await enter(&"cave_1")
	await swing(room.get_node("Props/BrazierWest"))
	await swing(room.get_node("Props/BrazierEast"))
	player.place_at(room.global_position + Vector2(960, 480))
	await walk(Vector2(960, 240))
	await frames(4)
	check_eq(GameState.keys_in(&"ow"), 1, "historical key still credits overworld")
	room = await enter(&"cave_1_4")
	lock = null
	for node in room.get_node("Props").get_children():
		if node is LockedDoor:
			lock = node
	# Test correct real c1 spend, while proving ow is untouched.
	player.place_at(room.global_position + Vector2(960, 480))
	await walk(Vector2(1808, 480))
	await frames(5)
	check(lock.is_open, "actual c1 key opens east lock by contact")
	check_eq(GameState.keys_in(&"c1"), 0, "east lock spends exactly one c1 key")
	check_eq(GameState.keys_in(&"ow"), 1, "east lock preserves overworld key")
	check(GameState.has_flag(&"door_e151"), "canonical shared edge persistence id")
	# Reenter and walk across the now-open full gate footprint before the actual slide.
	room = await enter(&"cave_1")
	room = await enter(&"cave_1_4")
	player.place_at(room.global_position + Vector2(1650, 480))
	await walk(Vector2(1860, 480))
	check_eq(GameState.keys_in(&"ow"), 1, "reentry costs no second key")
	player.set_hurtbox_enabled(self, false)
	await batch_b()
	await persistence()
	await dispose(world)


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


func pickup(room: Room, id: StringName) -> PickupBase:
	for node in room.get_node("Props").get_children():
		if node is PickupBase and node.persistent_id == id:
			return node
	return null


func walk(target: Vector2) -> void:
	var room := world.get_room(world.get_current_room_id())
	for i in range(500):
		var diff := target - (player.global_position - room.global_position)
		if diff.length() < 9:
			break
		release_inputs()
		if abs(diff.x) > 6:
			Input.action_press(&"move_right" if diff.x > 0 else &"move_left")
		if abs(diff.y) > 6:
			Input.action_press(&"move_down" if diff.y > 0 else &"move_up")
		await frames(1)
	release_inputs()
	check(
		(target - (player.global_position - room.global_position)).length() < 12,
		"real walking reaches %s in %s" % [target, room.room_id]
	)


func cross(action: StringName, target: StringName) -> void:
	Input.action_press(action)
	for i in range(180):
		await frames(1)
		if world.get_current_room_id() == target:
			break
	release_inputs()
	await seconds(.4)
	check_eq(world.get_current_room_id(), target, "real exit crossing")


func swing(target: Node2D) -> void:
	player.place_at(target.global_position + Vector2(0, 70))
	player.facing = Vector2.UP
	await frames(3)
	Input.action_press(&"attack")
	await frames(2)
	Input.action_release(&"attack")
	await frames(14)


func batch_b() -> void:
	player.set_hurtbox_enabled(self, false)
	# Both room6 and its lock were preloaded while room4's real key opened e151.
	await cross(&"move_right", &"cave_1_6")
	var room := world.get_room(&"cave_1_6")
	var lock := scripted(room, "locked_door.gd") as LockedDoor
	check(lock.is_open, "preloaded room6 mirrored e151 opened by actual source-side key")
	await walk(Vector2(300, 480))
	await cross(&"move_left", &"cave_1_4")
	check_eq(GameState.keys_in(&"c1"), 0, "actual lock roundtrip spends no second key")
	check_eq(GameState.keys_in(&"ow"), 1, "actual lock roundtrip preserves ow key")
	room = world.get_room(&"cave_1_4")
	await walk(Vector2(960, 480))
	await walk(Vector2(960, 180))
	await cross(&"move_up", &"cave_1_5")
	room = world.get_room(&"cave_1_5")
	check(
		(scripted(room, "gate.gd") as Gate).is_open,
		"preloaded room5 e149 synchronized while disabled"
	)
	for node in room.get_node("Props").get_children():
		if node is Brazier:
			check(node.lit, "paired brazier state synchronized")
	var captain = room.get_enemies()[0]
	var hp: int = captain.hp
	player.place_at(captain.global_position + Vector2(90, 0))
	player.facing = Vector2.LEFT
	captain.set_facing_dir(Vector2.RIGHT)
	await frames(2)
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(captain.hp, hp, "assembled captain blocks real front hook")
	await frames(25)
	player.place_at(captain.global_position - Vector2(180, 0))
	player.facing = Vector2.RIGHT
	GameState.set_active_item(&"tether_moth")
	check(player.use_item(), "actual moth launched at assembled captain")
	await frames(16)
	check(captain.is_stunned(), "actual moth drops captain guard")
	hp = captain.hp
	player.place_at(captain.global_position - Vector2(90, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check(captain.hp < hp, "real hook damages captain after moth drops guard")
	# Finish through actual player hook hitboxes from the unguarded side.
	for strike in range(12):
		if not is_instance_valid(captain) or captain.is_dead:
			break
		await frames(25)
		if not is_instance_valid(captain) or captain.is_dead:
			break
		player.place_at(captain.global_position + captain.facing_dir.orthogonal() * 80)
		player.facing = (captain.global_position - player.global_position).normalized()
		Input.action_press(&"attack")
		await frames(8)
		Input.action_release(&"attack")
	await seconds(1.6)
	check(GameState.has_flag(&"mini_cave_1_5"), "real captain death sets room flag")
	player.place_at(room.global_position + Vector2(960, 480))
	await walk(Vector2(960, 310))
	await frames(4)
	check(GameState.has_item(&"cinder_wick"), "pedestal grants actual cinder wick")
	await walk(Vector2(960, 480))
	await walk(Vector2(1680, 480))
	await cross(&"move_right", &"cave_1_7")
	room = world.get_room(&"cave_1_7")
	for enemy in room.get_enemies():
		enemy.drops_enabled = false
		enemy.kill()
	await walk(Vector2(1392, 480))
	await walk(Vector2(1488, 310))
	await frames(4)
	check(GameState.has_big_key(&"c1"), "actual Lockpick pickup grants c1 bigkey")
	await walk(Vector2(960, 480))
	await walk(Vector2(240, 480))
	await cross(&"move_left", &"cave_1_5")
	room = world.get_room(&"cave_1_5")
	check_eq(room.get_enemies().size(), 0, "Captain stays defeated after real room reentry")
	await walk(Vector2(960, 480))
	await walk(Vector2(960, 780))
	await cross(&"move_down", &"cave_1_4")
	# The optional store remains closed before its required tool is acquired.
	room = await enter(&"cave_1_6")
	var sealed = scripted(room,"cracked_wall.gd")
	check(not GameState.has_item(&"pitch_pot"),"secret tested before acquiring its bomb tool")
	await swing(sealed)
	check(not sealed.is_open,"hook cannot open the bomb-only secret")
	check(not GameState.has_flag(&"cracked_e154"),"false secret state persists before bomb")
	# Fetch the optional pot through its historical real ow-key door and pickup.
	room = await enter(&"ow_2_1")
	var potlock := scripted(room, "locked_door.gd") as LockedDoor
	player.place_at(potlock.global_position + Vector2(0, -70))
	await frames(5)
	check(potlock.is_open, "historical ow key opens real pot closet")
	var pot := pickup(room, &"pitch_pot")
	player.place_at(pot.global_position + Vector2(0, 46))
	await frames(4)
	check(GameState.has_item(&"pitch_pot"), "actual pitch pot pickup acquired")
	room = await enter(&"cave_1_6")
	var crack = scripted(room, "cracked_wall.gd")
	var door = scripted(room, "room_door.gd") as RoomDoor
	player.place_at(door.global_position)
	await frames(5)
	check_eq(
		world.get_current_room_id(),
		&"cave_1_6",
		"closed crack door rejects physical trigger overlap"
	)
	player.place_at(crack.global_position + Vector2(0, 82))
	player.facing = Vector2.UP
	GameState.set_active_item(&"pitch_pot")
	await frames(3)
	check(player.use_item(), "actual optional pot placed")
	await seconds(1.9)
	check(crack.is_open, "real pot blast opens e154")
	player.place_at(room.global_position + Vector2(1008, 500))
	await walk(Vector2(1008, 420))
	await cross(&"move_up", &"cave_1_6#crack")
	room = world.get_room(&"cave_1_6#crack")
	check(
		(player.global_position - room.global_position).distance_to(Vector2(960, 600)) < 50,
		"Inside marker lands clear of return trigger"
	)
	var brass: int = GameState.currency
	await walk(Vector2(960, 336))
	await frames(5)
	check_eq(GameState.currency, brass + 30, "actual pocket cache grants 30 brass")
	check(GameState.has_flag(&"picked_cache_cave_1_6_ember1"), "actual pocket ember collected")
	await capture_state("secret-open")
	await walk(Vector2(960, 680))
	await cross(&"move_down", &"cave_1_6")
	room = world.get_room(&"cave_1_6")
	check(
		(player.global_position - room.global_position).distance_to(Vector2(1008, 528)) < 50,
		"FromPocket marker lands outside sealed store"
	)
	await walk(Vector2(1500, 480))
	await walk(Vector2(1808, 480))
	check(GameState.has_flag(&"door_boss_c1"), "actual Lockpick contact opens BossDoor")
	check(GameState.has_big_key(&"c1"), "BossDoor retains Lockpick")
	await cross(&"move_right", &"cave_1_8")
	room = world.get_room(&"cave_1_8")
	await boss_fight(room)


func scripted(room: Room, suffix: String) -> Node:
	for node in room.get_node("Props").get_children():
		var script: Script = node.get_script()
		if script != null and script.resource_path.ends_with(suffix):
			return node
	return null


func boss_fight(room: Room) -> void:
	var boss = room.get_enemies()[0]
	var rewards: Array = []
	for node in room.find_children("*", "", true, false):
		if node is PickupBase and node.persistent_id in [&"frag_c1", &"wick_core_c1"]:
			rewards.append(node)
	check_eq(rewards.size(), 2, "exactly two room-owned boss rewards, no arena duplicates")
	for reward in rewards:
		check(not reward.visible, "reward hidden before actual boss defeat")

	await seconds(1.7)

	var hp: int = boss.hp
	await boss_swing(boss)
	check_eq(boss.hp, hp, "actual assembled hard boss rejects hook")
	for cycle in range(8):
		if boss.is_dying():
			break
		if not boss.is_molten():
			GameState.set_active_item(&"cinder_wick")
			var dir := Vector2.RIGHT if boss.position.x > 400 else Vector2.LEFT
			player.place_at(boss.global_position - dir * 200)
			player.facing = dir
			await frames(2)
			check(player.use_item(), "actual acquired wick casts at boss")
			await seconds(.7)
			player.place_at(room.global_position + Vector2(960, 800))
			for i in range(180):
				if boss.is_molten() or boss.is_dying():
					break
				await frames(1)
		if boss.is_molten():
			check(boss.melt_ticks >= 3, "actual attached flame ticks melt wax")
			for attempt in range(5):
				if boss.is_dying() or not boss.is_molten():
					break
				await boss_swing(boss)
		await seconds(3.2)
		if not is_instance_valid(boss) or GameState.has_flag(&"boss_cave_1_8_defeated"):
			break
	check(
		GameState.has_flag(&"boss_cave_1_8_defeated"),
		"actual wick and player hook defeat assembled boss"
	)
	await seconds(1.6)
	await capture_state("boss-rewards")
	player.place_at(room.global_position + Vector2(960, 480))
	await frames(5)
	player.place_at(room.global_position + Vector2(1152, 480))
	await frames(5)
	check(GameState.has_flag(&"frag_c1"), "real Fragment of Warmth pickup collected")
	check_eq(GameState.max_health, 8, "real boss wick core raises health by two")
	check_eq(GameState.health, 8, "real wick core fully heals")
	await walk(Vector2(240, 480))
	await cross(&"move_left", &"cave_1_6")
	check(GameState.has_big_key(&"c1"), "actual arena retreat retains Lockpick and open door")


func boss_swing(boss: Variant) -> void:
	var dir := Vector2.RIGHT if boss.position.x > 350 else Vector2.LEFT
	player.place_at(boss.global_position - dir * 140)
	player.facing = dir
	Input.action_press(&"attack")
	await frames(6)
	Input.action_release(&"attack")
	await frames(22)


func persistence() -> void:
	check(not SaveGame.enabled, "normal route never enables disk writes")
	var snapshot := summary()
	var room := await enter(&"cave_1_8")
	await frames(5)
	check_eq(room.get_enemies().size(), 0, "real defeated boss does not respawn")
	for node in room.find_children("*", "", true, false):
		if node is PickupBase and node.persistent_id in [&"frag_c1", &"wick_core_c1"]:
			check(not node.visible, "collected rewards remain absent on room reentry")
	check_eq(GameState.max_health, 8, "reentry never awards a second core")
	# Disk proof is opt-in only in a process with a deliberately isolated userdata root.
	if OS.get_environment("WICK_C01_DISK") == "1":
		var safe := isolated_test_profile()
		check(safe, "disk child has an isolated runner profile")
		if safe:
			snapshot = summary()
			SaveGame.enabled = true
			check(SaveGame.save(), "isolated actual route writes disk slot")
			reset_state()
			SaveGame.enabled = true
			check(SaveGame.load_into_state(), "isolated disk slot reloads")
			check_eq(
				summary(),
				snapshot,
				"health ammo scoped keys items flags fragments checkpoint round-trip on disk"
			)
			SaveGame.enabled = false
	else:
		check_eq(GameState.keys_in(&"c1"), snapshot["c1"], "room reentry preserves scoped keys")
	var before_death := summary()
	var hpmax := GameState.max_health
	player.set_hurtbox_enabled(self, true)
	player.take_damage(99, player.global_position + Vector2(10, 0))
	for tick in range(400):
		await frames(1)
		if not player.is_dead() and not world.is_transitioning():
			break
	check_eq(
		world.get_current_room_id(), &"ow_1_1", "actual death returns to cave-mouth checkpoint"
	)
	check_eq(GameState.health, hpmax, "checkpoint respawn restores full health")
	check(GameState.has_flag(&"boss_cave_1_8_defeated"), "death preserves actual boss defeat")
	check(GameState.has_flag(&"mini_cave_1_5"), "death preserves actual Captain defeat")
	check_eq(GameState.max_health, 8, "death keeps one core upgrade")
	before_death["health"] = hpmax
	before_death["current_room"] = &"ow_1_1"
	check_eq(summary(),before_death,"death preserves complete ammo keys flags fragments items wallet checkpoint state")


func summary() -> Dictionary:
	var keys := {}
	for scope in GameState.KEY_SCOPES:
		keys[scope] = GameState.keys_in(scope)
	return {
		"keys": keys,
		"visited": GameState.visited_rooms.duplicate(),
		"current_room": GameState.current_room,
		"active_item": GameState.active_item,
		"health": GameState.health,
		"max": GameState.max_health,
		"pots": GameState.pitch_pots,
		"slugs": GameState.slugs,
		"ow": GameState.keys_in(&"ow"),
		"c1": GameState.keys_in(&"c1"),
		"flags": GameState.flags.duplicate(),
		"items": GameState.acquired_item_ids(),
		"wallet": GameState.currency,
		"checkpoint": SaveGame.checkpoint_room()
	}


func capture_state(label: String) -> void:
	if OS.get_environment("WICK_C01_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var path := "/tmp/wick-c01-" + label + ".png"
	check_eq(
		get_viewport().get_texture().get_image().save_png(path), OK, "actual state capture " + label
	)


## Separate reset scenario proves the other loaded side can originate each shared state change.
func reverse_pairs() -> void:
	reset_state()
	SaveGame.enabled = false
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	var room := await enter(&"cave_1_5")
	var peer := world.get_room(&"cave_1_4")
	check(not (scripted(peer, "gate.gd") as Gate).is_open, "reverse gate peer starts closed")
	var lamps: Array[Brazier] = []
	for node in room.get_node("Props").get_children():
		if node is Brazier:
			lamps.append(node)
	await swing(lamps[0])
	check(not (scripted(peer, "gate.gd") as Gate).is_open, "reverse first lamp leaves peer shut")
	await swing(lamps[1])
	check(
		(scripted(peer, "gate.gd") as Gate).is_open, "reverse actual hooks open loaded room4 gate"
	)
	for node in peer.get_node("Props").get_children():
		if node is Brazier:
			check(node.lit, "reverse shared lamp state reaches loaded peer")
	player.place_at(room.global_position + Vector2(960, 720))
	await walk(Vector2(960, 780))
	await cross(&"move_down", &"cave_1_4")
	room = await enter(&"ow_0_1")
	player.place_at(pickup(room, &"tether_moth").global_position + Vector2(0, 46))
	await frames(4)
	room = await enter(&"cave_1_3")
	player.place_at(room.global_position + Vector2(1008, 528))
	player.facing = Vector2.UP
	await frames(3)
	check(player.use_item(), "reverse lock scenario fetches actual c1 key by moth")
	await seconds(1.7)
	check_eq(GameState.keys_in(&"c1"), 1, "reverse probe uses real fetched key")
	room = await enter(&"cave_1_6")
	var boss_door = scripted(room,"boss_door.gd")
	check_eq(boss_door.cave,&"c1","actual BossDoor requires matching cave Lockpick")
	player.place_at(room.global_position+Vector2(1650,480))
	Input.action_press(&"move_right")
	await seconds(1.2)
	release_inputs()
	check(not boss_door.is_open,"small key and moth cannot open the real BossDoor")
	check(player.global_position.x-room.global_position.x<1800,"closed BossDoor blocks actual body walking")
	check_eq(GameState.keys_in(&"c1"),1,"BossDoor rejection preserves actual small key")
	peer = world.get_room(&"cave_1_4")
	check(
		not (scripted(peer, "locked_door.gd") as LockedDoor).is_open,
		"reverse lock peer starts closed"
	)
	player.place_at(room.global_position + Vector2(300, 480))
	await walk(Vector2(110, 480))
	check(
		(scripted(peer, "locked_door.gd") as LockedDoor).is_open,
		"room6 contact opens already loaded room4 lock"
	)
	check_eq(GameState.keys_in(&"c1"), 0, "reverse contact spends one c1 key")
	await cross(&"move_left", &"cave_1_4")
	await walk(Vector2(1680, 480))
	await cross(&"move_right", &"cave_1_6")
	check_eq(GameState.keys_in(&"c1"), 0, "reverse paired roundtrip never spends twice")
	await dispose(world)
