## timeout=300
extends "res://tests/test_route_cave_5.gd"
## Positioned integration route: prior tools are real pickups; regular mobs removed except ward singers.
## No injected keys, progression flags, boss HP/phases or attack timers. Not a continuous playthrough.
var captured: Dictionary = {}


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	await acquire_kit()
	await mouth()
	await first_key()
	await singer_and_chime()
	await second_key()
	await side_pockets()
	await dirge()
	await persistence()
	await dispose(world)
	await reverse_push_control()


func acquire_kit() -> void:
	await super.acquire_kit()
	var room := await enter(&"cave_4_5")
	await collect(room, &"heft_mitts")
	room = await enter(&"cave_5_5")
	await collect(room, &"glow_jar")
	check(
		GameState.has_item(&"heft_mitts") and GameState.has_item(&"glow_jar"),
		"actual prior-cave pickups"
	)
	check(not GameState.has_item(&"lantern_chime"), "C06 starts without its tool")


func enter(id: StringName) -> Room:
	if world.get_current_room_id() != id:
		world.start_at(id)
	var room := world.get_room(id)
	for enemy in room.get_enemies():
		if id == &"cave_6_11" or enemy.scene_file_path.contains("/minibosses/"):
			continue
		if id == &"cave_6_8" and enemy.get_script().resource_path.ends_with("choirling.gd"):
			continue
		enemy.drops_enabled = false
		enemy.kill()
	await frames(4)
	if String(id).begins_with("cave_6_") and not captured.has(id):
		captured[id] = true
		await capture_state(String(id).replace("#", "-"))
	return room


func mouth() -> void:
	var room := await enter(&"ow_6_6")
	var stone = scripted(room, "heavy_stone.gd")
	await capture_state("mouth-sealed")
	var door := door_to(room, &"cave_6_1")
	await swing_from(stone.global_position, Vector2.RIGHT)
	check(not GameState.has_flag(&"moved_cave6door"), "hook cannot replace mitts at real mouth")
	player.place_at(door.global_position)
	await frames(5)
	check_eq(world.get_current_room_id(), &"ow_6_6", "sealed actual mouth rejects trigger overlap")
	var threshold := door.global_position
	await push(stone, Vector2.RIGHT, 90)
	check(GameState.has_flag(&"moved_cave6door"), "actual mitts push opens Choir Steps mouth")
	if world.get_current_room_id() != &"cave_6_1":
		player.place_at(threshold + Vector2(0, 100))
		await frames(3)
		player.place_at(threshold)
		await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_6_1", "actual opened mouth enters C06")
	room = await enter(&"cave_6_1")
	check(
		(
			player.global_position.distance_to(
				room.get_node("Spawns/FromOverworld").global_position
			)
			< 60
		),
		"safe actual arrival marker"
	)
	check(GameState.has_flag(&"mouth_c6"), "actual entry records cave mouth checkpoint")
	await edge(&"cave_6_1", &"cave_6_2", Vector2.RIGHT)


func first_key() -> void:
	var room := await enter(&"cave_6_2")
	await blocked(
		Vector2(1650, 480), &"move_right", scripted(room, "locked_door.gd"), "wrong-scope C06 lock"
	)
	check_eq(GameState.keys_in(&"c1"), 1, "actual other-cave key is preserved")
	await bomb_arch(room)
	await edge(&"cave_6_2", &"cave_6_3", Vector2.UP)
	room = world.get_room(&"cave_6_3")
	await collect(room, &"key_c6_1")
	check_eq(GameState.keys_in(&"c6"), 1, "actual loft pickup credits c6")
	check(
		GameState.has_flag(&"cracked_e191_left") and GameState.has_flag(&"cracked_e191_right"),
		"both bomb arch halves persist"
	)
	await edge(&"cave_6_3", &"cave_6_2", Vector2.DOWN)
	room = world.get_room(&"cave_6_2")
	await contact(scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check(
		scripted(world.get_room(&"cave_6_4"), "locked_door.gd").is_open,
		"first earned key synchronizes peer"
	)
	check_eq(GameState.keys_in(&"c6"), 0, "first actual c6 key spent exactly once")
	await edge(&"cave_6_2", &"cave_6_4", Vector2.RIGHT)


func bomb_arch(room: Room) -> void:
	var wall = scripted(room, "cracked_wall.gd")
	await bomb(wall)
	check(wall.is_open, "actual pot opens cracked loft arch")


func singer_and_chime() -> void:
	var room := await enter(&"cave_6_4")
	var enemy = scripted_enemy(room, "choir_warden.gd")
	check(enemy != null, "actual Singing Hall miniboss")
	if enemy == null:
		return
	check(
		not GameState.has_item(&"lantern_chime"), "Choir Warden is fought before chime acquisition"
	)
	player.place_at(enemy.global_position + Vector2(350, 0))
	for tick in range(420):
		if enemy.state == enemy.State.TELEGRAPH:
			break
		await frames(1)
	player.place_at(enemy.global_position + enemy._aim * 300)
	player.facing = -enemy._aim
	Input.action_press(&"ward")
	await frames(3)
	player.set_hurtbox_enabled(self, true)
	var health := GameState.health
	var blocks: Array[int] = []
	for tick in range(180):
		if (
			is_instance_valid(enemy._cone)
			and not enemy._cone.blocked.is_connected(record_block.bind(blocks))
		):
			enemy._cone.blocked.connect(record_block.bind(blocks))
		if enemy.state == enemy.State.RECOVER:
			break
		await frames(1)
	check(not blocks.is_empty(), "real ward blocks naturally timed pre-chime Warden song")
	check_eq(GameState.health, health, "actual ward protects health")
	release_inputs()
	player.set_hurtbox_enabled(self, false)
	await hook_enemy(enemy)
	check(enemy.hp < 20, "actual hook damages natural closed-mouth recovery")
	await edge(&"cave_6_4", &"cave_6_2", Vector2.LEFT)
	await edge(&"cave_6_2", &"cave_6_4", Vector2.RIGHT)
	room = world.get_room(&"cave_6_4")
	enemy = scripted_enemy(room, "choir_warden.gd")
	check_eq(enemy.hp, 20, "actual unfinished room reentry restores miniboss HP")
	check(not is_instance_valid(enemy._cone), "actual reentry leaves no stale song")
	for attempt in range(400):
		if not is_instance_valid(enemy) or enemy.is_dying() or enemy.is_dead:
			break
		if enemy.state == enemy.State.RECOVER:
			await hook_enemy(enemy)
		else:
			player.place_at(room.global_position + Vector2(960, 300))
			await frames(10)
	check(GameState.has_flag(&"mini_cave_6_4"), "actual pre-chime hooks finish Choir Warden")
	await capture_state("warden-defeated")
	await seconds(1.7)
	await edge(&"cave_6_4", &"cave_6_5", Vector2.RIGHT)
	room = world.get_room(&"cave_6_5")
	var resonance = scripted(room, "resonance_stone.gd")
	await swing_from(resonance.global_position, Vector2.UP)
	check(not resonance.is_awake, "hook cannot replace the chime")
	player.place_at(room.global_position + Vector2(960, 260))
	Input.action_press(&"move_up")
	await seconds(.8)
	release_inputs()
	check_eq(
		world.get_current_room_id(), &"cave_6_5", "unacquired chime threshold physically blocks"
	)
	await collect(room, &"lantern_chime")
	check(
		GameState.has_item(&"lantern_chime"), "actual post-miniboss Bell Room pedestal grants chime"
	)
	await ring_at(resonance.global_position + Vector2(0, 240))
	check(resonance.is_awake, "actual earned chime wakes resonance stone")
	check(
		scripted(world.get_room(&"cave_6_6"), "resonance_stone.gd").is_awake,
		"real chime synchronizes disabled peer"
	)
	await edge(&"cave_6_5", &"cave_6_6", Vector2.UP)


func record_block(blocks: Array[int]) -> void:
	blocks.append(1)


func ring_at(at: Vector2) -> void:
	player.place_at(at)
	GameState.set_active_item(&"lantern_chime")
	await frames(3)
	Input.action_press(&"use_item")
	check(player.use_item(), "actual earned chime activates")
	await frames(2)
	Input.action_release(&"use_item")
	await frames(34)


func second_key() -> void:
	var room := await enter(&"cave_6_6")
	var seam = scripted(room, "hidden_seam.gd")
	await throw_jar(room.global_position + Vector2(1536, 480), Vector2.RIGHT)
	await seconds(1.8)
	check(seam.is_revealed, "actual acquired jar permanently reveals Organ Loft seam")
	check(
		scripted(world.get_room(&"cave_6_7"), "hidden_seam.gd").is_revealed,
		"jar reveals loaded opposite seam"
	)
	await edge(&"cave_6_6", &"cave_6_7", Vector2.RIGHT)
	room = world.get_room(&"cave_6_7")
	await collect(room, &"key_c6_2")
	check_eq(GameState.keys_in(&"c6"), 1, "actual Organ Loft key credits c6")
	await edge(&"cave_6_7", &"cave_6_6", Vector2.LEFT)
	await edge(&"cave_6_6", &"cave_6_5", Vector2.DOWN)
	await edge(&"cave_6_5", &"cave_6_8", Vector2.DOWN)


func side_pockets() -> void:
	var room := await enter(&"cave_6_8")
	await ward_cache(room)
	room = world.get_room(&"cave_6_8")
	await contact(scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check_eq(GameState.keys_in(&"c6"), 0, "second earned c6 key spent exactly once")
	check_eq(GameState.keys_in(&"c1"), 1, "both c6 locks preserve actual wrong-scope key")
	check(
		scripted(world.get_room(&"cave_6_9"), "locked_door.gd").is_open,
		"second key synchronizes peer"
	)
	await edge(&"cave_6_8", &"cave_6_9", Vector2.RIGHT)
	room = world.get_room(&"cave_6_9")
	var maximum := GameState.max_health
	await bomb(scripted(room, "cracked_wall.gd"))
	var door := door_to(room, &"cave_6_9#crypt")
	player.place_at(door.global_position)
	await seconds(1)
	check_eq(
		world.get_current_room_id(), &"cave_6_9#crypt", "actual bomb opens physical crypt entry"
	)
	room = await enter(&"cave_6_9#crypt")
	await collect(room, &"wick_core_c6_hidden")
	check_eq(GameState.max_health, maximum + 2, "actual crypt core adds one heart")
	await return_pocket(room, &"cave_6_9")
	room = world.get_room(&"cave_6_9")
	await collect(room, &"bigkey_c6")
	check(GameState.has_big_key(&"c6"), "actual crypt hall Lockpick earned")
	await edge(&"cave_6_9", &"cave_6_8", Vector2.LEFT)
	await push_gate(&"cave_6_8", &"cave_6_10")
	room = world.get_room(&"cave_6_10")
	await contact(scripted(room, "boss_door.gd"), Vector2.DOWN)
	check(
		scripted(world.get_room(&"cave_6_11"), "boss_door.gd").is_open,
		"actual Lockpick synchronizes boss endpoint"
	)
	await edge(&"cave_6_10", &"cave_6_11", Vector2.DOWN)


func ward_cache(room: Room) -> void:
	var plate: Node
	for n in room.get_node("Props").get_children():
		if n.is_in_group(&"ward_plate"):
			plate = n
	check(plate != null and not plate.test_spore_post, "actual ward pad has no synthetic shooter")
	if plate == null:
		return
	player.set_hurtbox_enabled(self, true)
	player.place_at(plate.global_position)
	Input.action_press(&"ward")
	var health := GameState.health
	for tick in range(1200):
		var nearest: EnemyBase
		for enemy in room.get_enemies():
			if (
				nearest == null
				or (
					enemy.global_position.distance_to(player.global_position)
					< nearest.global_position.distance_to(player.global_position)
				)
			):
				nearest = enemy
		if nearest != null:
			player.facing = player.global_position.direction_to(nearest.global_position)
		if plate.is_satisfied:
			break
		await frames(1)
	release_inputs()
	check(
		plate.is_satisfied and GameState.has_flag(&"ward_e258"),
		"three actual Choirling ward blocks open optional cache"
	)
	check_eq(GameState.health, health, "real ward puzzle preserves health")
	player.set_hurtbox_enabled(self, false)
	await capture_state("ward-open")
	for enemy in room.get_enemies():
		enemy.drops_enabled = false
		enemy.kill()
	var door := door_to(room, &"cave_6_8#ward")
	player.place_at(door.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_6_8#ward", "actual satisfied ward enters pocket")
	room = await enter(&"cave_6_8#ward")
	var brass := GameState.currency
	await collect(room, &"cache_cave_6_8_ward_brass")
	check_eq(GameState.currency, brass + 50, "actual authored ward cache grants fifty brass")
	await return_pocket(room, &"cave_6_8")


func return_pocket(room: Room, target: StringName) -> void:
	player.place_at(door_to(room, target).global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), target, "actual pocket return " + String(target))
	await seconds(.5)
	check_eq(world.get_current_room_id(), target, "pocket return marker avoids bounce")


func push(stone: Node2D, direction: Vector2, distance: float) -> void:
	player.place_at(stone.global_position - direction * distance)
	player.facing = direction
	GameState.set_active_item(&"heft_mitts")
	await frames(3)
	check(player.use_item(), "actual acquired mitts grab PUSH prop")
	Input.action_press(action_for(direction))
	for tick in range(180):
		if not is_instance_valid(stone):
			break
		await frames(1)
	release_inputs()
	if is_instance_valid(stone):
		check(stone.path.length() >= 2, "real PUSH slides at least two steps")


func push_gate(source: StringName, target: StringName) -> void:
	var room := await enter(source)
	var peer := world.get_room(target)
	var stone = scripted(room, "heavy_stone.gd")
	var opposite = scripted(peer, "heavy_stone.gd")
	check_eq(stone.mode, 1, "heavy door stays normative PUSH")
	await push(stone, Vector2.DOWN, 180)
	await capture_state("push-" + String(source))
	check_eq(opposite.path, stone.path, "actual PUSH synchronizes loaded peer path")
	var direction := Vector2.LEFT if source == &"cave_6_8" else Vector2.RIGHT
	await edge(source, target, direction)
	await edge(target, source, -direction)
	await edge(source, target, direction)
	check(GameState.has_flag(&"moved_e198"), "physical crossings retain actual PUSH flag")


func dirge() -> void:
	var room := await enter(&"cave_6_11")
	var boss = scripted_enemy(room, "dirge_choir.gd")
	check(boss != null, "actual assembled Dirge Choir")
	if boss == null:
		return
	await frames(3)
	check_eq(boss.parts().size(), 3, "exactly three real heads at translated room origin")
	for i in range(3):
		check_eq(
			boss.heads[i].global_position,
			room.global_position + boss.HEAD_POINTS[i],
			"head room-space anchor"
		)
	for reward in pickups(room):
		if reward.kind in [&"fragment", &"wick_core"]:
			check(not reward.visible, "room rewards await actual defeat")
	await seconds(1.6)
	await dirge_ward(room, boss)
	var head: EnemyBase = boss.heads[0]
	var before := head.hp
	await hook_enemy(head)
	check_eq(head.hp, before, "actual humming head rejects hook without chime")
	await open_head(boss, head)
	await hook_enemy(head)
	check(head.hp < before, "actual chime then hook damages real Bass")
	await edge(&"cave_6_11", &"cave_6_10", Vector2.UP)
	await edge(&"cave_6_10", &"cave_6_11", Vector2.DOWN)
	room = world.get_room(&"cave_6_11")
	boss = scripted_enemy(room, "dirge_choir.gd")
	await frames(3)
	check_eq(boss.parts().size(), 3, "actual retreat rebuilds exactly three heads")
	for part in boss.parts():
		check_eq(part.hp, 12, "unfinished retreat restores each actual head")
	# An actual player death must clear unfinished heads/songs without forging the boss flag.
	player.set_hurtbox_enabled(self, true)
	player.take_damage(99, player.global_position + Vector2(10, 0))
	await await_respawn()
	check_eq(world.get_current_room_id(), &"ow_6_6", "unfinished death returns to actual C06 mouth")
	check(not GameState.has_flag(&"boss_cave_6_11_defeated"), "unfinished death cannot earn defeat")
	player.set_hurtbox_enabled(self, false)
	room = await enter(&"cave_6_11")
	boss = scripted_enemy(room, "dirge_choir.gd")
	await seconds(1.7)
	var phases: Array[int] = []
	for voice in range(3):
		head = boss.heads[voice]
		await open_head(boss, head)
		for strike in range(6):
			if not is_instance_valid(head) or head.is_dead:
				break
			if head.open_left <= 0:
				await open_head(boss, head)
			await hook_enemy(head)
		await frames(3)
		check(
			not is_instance_valid(head) or head.is_dead,
			"actual chime and hook finish voice " + str(voice)
		)
		phases.append(boss.phase)
		await capture_state("dirge-voice-" + str(voice))
		if voice < 2:
			await seconds(1.3)
	check_eq(phases, [2, 3, 3], "actual head deaths advance natural chord and solo phases")
	check(
		GameState.has_flag(&"boss_cave_6_11_defeated"),
		"actual chime and player hook earn Dirge defeat"
	)
	await seconds(1.7)
	check(not is_instance_valid(boss), "actual boss death completes")
	check_eq(room.get_enemies().size(), 0, "death clears heads and solo choirlings")
	await capture_state("dirge-rewards")
	var maximum := GameState.max_health
	await collect(room, &"frag_c6")
	await collect(room, &"wick_core_c6")
	check(GameState.has_flag(&"frag_c6"), "actual Fragment of Song collected")
	check_eq(GameState.max_health, maximum + 2, "one actual boss core adds one heart")


func dirge_ward(room: Room, boss: EnemyBase) -> void:
	var treble: EnemyBase = boss.heads[2]
	# Outside Alto's 720px beam and Bass's 640px ring, in the natural Treble note path.
	player.place_at(treble.global_position + Vector2(0, -528))
	player.facing = Vector2.DOWN
	Input.action_press(&"ward")
	await frames(3)
	player.set_hurtbox_enabled(self, true)
	var health := GameState.health
	var blocks: Array[int] = []
	var observed: Dictionary = {}
	for tick in range(900):
		for node in get_tree().get_nodes_in_group(&"hitboxes"):
			if (
				node is Hitbox
				and room.is_ancestor_of(node)
				and not observed.has(node.get_instance_id())
			):
				observed[node.get_instance_id()] = true
				node.blocked.connect(record_block.bind(blocks))
		if not blocks.is_empty():
			break
		await frames(1)
	check(not blocks.is_empty(), "real held ward blocks a naturally scheduled Dirge song or note")
	check_eq(GameState.health, health, "actual Dirge ward block protects health")
	await capture_state("dirge-ward")
	release_inputs()
	player.set_hurtbox_enabled(self, false)


func open_head(boss: EnemyBase, head: EnemyBase) -> void:
	for tick in range(900):
		if not is_instance_valid(head) or head.is_dead:
			return
		player.place_at(head.global_position + Vector2(0, -180))
		if (
			boss.heads_active()
			and head.song_age >= 0
			and head.deaf_left <= 0
			and head.open_left <= 0
		):
			await ring_at(player.global_position)
			if head.open_left > 0:
				await capture_state("dirge-open-" + str(head.voice))
				return
		await frames(1)
	check(false, "natural singing head receives actual chime within bounded wait")


func persistence() -> void:
	await edge(&"cave_6_11", &"cave_6_10", Vector2.UP)
	await edge(&"cave_6_10", &"cave_6_8", Vector2.RIGHT)
	await edge(&"cave_6_8", &"cave_6_5", Vector2.UP)
	await edge(&"cave_6_5", &"cave_6_4", Vector2.LEFT)
	await edge(&"cave_6_4", &"cave_6_2", Vector2.LEFT)
	await edge(&"cave_6_2", &"cave_6_1", Vector2.LEFT)
	var room := await enter(&"cave_6_1")
	player.place_at(door_to(room, &"ow_6_6").global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"ow_6_6", "actual cave exit returns to Choir Steps")
	await seconds(.5)
	check_eq(world.get_current_room_id(), &"ow_6_6", "mouth return avoids bounce")
	var safe := OS.get_user_data_dir().begins_with("/tmp/")
	check(safe, "disk proof requires isolated temporary user data")
	if not safe:
		return
	var before := SaveGame._snapshot()
	SaveGame.enabled = true
	check(SaveGame.save(), "full earned route saves to isolated slot")
	reset_state()
	check(SaveGame.load_into_state(), "actual isolated disk state reloads")
	var restored := SaveGame._snapshot()
	check_near(
		restored["playtime"], before["playtime"], .000001, "full save preserves playtime precision"
	)
	before["playtime"] = restored["playtime"]
	check_eq(restored, before, "every persistent save field roundtrips")
	SaveGame.enabled = false
	await dispose(world)
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	for id: StringName in [&"cave_6_4", &"cave_6_11"]:
		room = await enter(id)
		check_eq(
			room.get_enemies().size(),
			0,
			"earned encounter stays absent after disk/unload " + String(id)
		)
	room = await enter(&"cave_6_6")
	check(scripted(room, "resonance_stone.gd").is_awake, "disk restores resonance")
	check(scripted(room, "hidden_seam.gd").is_revealed, "disk restores jar seam")
	for id: StringName in [&"cave_6_8", &"cave_6_10"]:
		room = await enter(id)
		check(
			scripted(room, "heavy_stone.gd").path.length() >= 2,
			"disk restores PUSH path " + String(id)
		)
	await edge(&"cave_6_10", &"cave_6_8", Vector2.RIGHT)
	await edge(&"cave_6_8", &"cave_6_10", Vector2.LEFT)
	await edge(&"cave_6_10", &"cave_6_11", Vector2.DOWN)
	room = world.get_room(&"cave_6_11")
	for reward in pickups(room):
		if reward.kind in [&"fragment", &"wick_core"]:
			check(not reward.visible, "disk cannot duplicate earned boss rewards")
	var earned := SaveGame._snapshot()
	player.set_hurtbox_enabled(self, true)
	player.take_damage(99, player.global_position + Vector2(10, 0))
	await await_respawn()
	var after := SaveGame._snapshot()
	earned["health"] = GameState.max_health
	# World continues clock/current-room bookkeeping during the real respawn.
	for key in ["playtime", "current_room", "visited_rooms"]:
		earned[key] = after[key]
	check_eq(after, earned, "real post-victory death preserves all earned save fields")
	check_eq(world.get_current_room_id(), &"ow_6_6", "actual post-victory mouth checkpoint")


func reverse_push_control() -> void:
	reset_state()
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	var room := await enter(&"cave_4_5")
	await collect(room, &"heft_mitts")
	check(not GameState.has_flag(&"moved_e198"), "reverse-first PUSH uses fresh flags")
	await push_gate(&"cave_6_10", &"cave_6_8")
	await dispose(world)


func make_world() -> World:
	if OS.get_environment("WICK_C06_CAPTURE") != "1":
		return await super.make_world()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var instance := (load("res://scenes/world/world.tscn") as PackedScene).instantiate() as World
	viewport.add_child(instance)
	await frames(2)
	return instance


func capture_state(label: String) -> void:
	if OS.get_environment("WICK_C06_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		world.get_viewport().get_texture().get_image().save_png(
			"/tmp/ww-c06-lead/" + label + ".png"
		),
		OK,
		"actual C06 capture " + label
	)
