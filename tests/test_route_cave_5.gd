## timeout=300
extends "res://tests/test_route_cave_3.gd"
## Controlled positions, removed regular mobs and hurtbox suppression isolate actual tools/combat.
## Kit is earned at real pickups; no jar, gate flags, boss HP or phase transitions are injected.
## This is an integration route, not a continuous human playthrough.


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	await acquire_kit()
	await mouth()
	await first_key()
	await warden_and_jar()
	await seam_key_and_lockpick()
	await last_page()
	await persistence()
	await dispose(world)


func mouth() -> void:
	var room := await enter(&"ow_6_3")
	var door := door_to(room, &"cave_5_1")
	player.place_at(door.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_5_1", "actual Lantern Isle mouth enters C05")
	check(GameState.has_flag(&"mouth_c5"), "actual cave entry records mouth checkpoint")
	room = world.get_room(&"cave_5_1")
	check(
		(
			player.global_position.distance_to(
				room.get_node("Spawns/FromOverworld").global_position
			)
			< 60
		),
		"real mouth uses safe named arrival"
	)
	await edge(&"cave_5_1", &"cave_5_2", Vector2.LEFT)


func first_key() -> void:
	var room := await enter(&"cave_5_2")
	await blocked(
		Vector2(220, 480), &"move_left", scripted(room, "locked_door.gd"), "first c5 lock"
	)
	check_eq(GameState.keys_in(&"c1"), 1, "real wrong-scope C01 key preserved")
	player.place_at(room.global_position + Vector2(960, 290))
	Input.action_press(&"move_up")
	await seconds(.6)
	release_inputs()
	check_eq(world.get_current_room_id(), &"cave_5_2", "dry vines block actual first approach")
	await vines(room)
	await edge(&"cave_5_2", &"cave_5_3", Vector2.UP)
	room = world.get_room(&"cave_5_3")
	await collect(room, &"key_c5_1")
	check_eq(GameState.keys_in(&"c5"), 1, "actual Dust Reading Room key credits c5")
	check_eq(GameState.keys_in(&"c1"), 1, "new key never alters c1 scope")
	await vines(room)
	await edge(&"cave_5_3", &"cave_5_2", Vector2.DOWN)
	room = world.get_room(&"cave_5_2")
	var peer := world.get_room(&"cave_5_4")
	await contact(scripted(room, "locked_door.gd"), Vector2.LEFT)
	check(scripted(peer, "locked_door.gd").is_open, "actual c5 key opens preloaded Index Hall peer")
	check_eq(GameState.keys_in(&"c5"), 0, "first actual c5 key consumed once")
	check_eq(GameState.keys_in(&"c1"), 1, "correct spend preserves wrong-scope key")
	await edge(&"cave_5_2", &"cave_5_4", Vector2.LEFT)


func vines(room: Room) -> void:
	var at: Array[Vector2] = []
	for node in room.find_children("*", "", true, false):
		if node is Bush and node.variant == &"dry_vine_screen":
			node.drops_enabled = false
			at.append(node.global_position)
	check_eq(at.size(), 2, "authored paired dry-vine screen exists on endpoint")
	for point in at:
		await swing_from(
			point, Vector2.UP if point.y - room.global_position.y < 480 else Vector2.DOWN
		)
	var left := 0
	for node in room.find_children("*", "", true, false):
		if node is Bush and node.variant == &"dry_vine_screen":
			left += 1
	check_eq(left, 0, "actual hook cuts both dry-vine bodies")


func warden_and_jar() -> void:
	var room := await enter(&"cave_5_4")
	var enemy = scripted_enemy(room, "mirror_warden.gd")
	check(enemy != null, "actual room-owned Mirror Warden")
	if enemy == null:
		return
	check(not GameState.has_item(&"glow_jar"), "Mirror Warden must precede jar acquisition")
	check_eq(enemy.decoys.size(), 2, "two actual Warden reflections")
	# A real hit then actual room leave/reentry resets the unfinished fight, not a synthetic defeat.
	await hook_enemy(enemy)
	check(enemy.hp < 18, "actual hook damages Warden before reset")
	await edge(&"cave_5_4", &"cave_5_2", Vector2.RIGHT)
	await edge(&"cave_5_2", &"cave_5_4", Vector2.LEFT)
	room = world.get_room(&"cave_5_4")
	enemy = scripted_enemy(room, "mirror_warden.gd")
	check_eq(enemy.hp, 18, "unfinished Warden room reentry restores full HP")
	check_eq(enemy.decoys.size(), 2, "Warden reentry has exactly two live reflections")
	var lights: Array[Brazier] = []
	for node in room.get_node("Props").get_children():
		if node is Brazier:
			lights.append(node)
	check_eq(lights.size(), 4, "four authored corner braziers provide pre-jar answer")
	for index in range(lights.size()):
		await swing_from(lights[index].global_position, Vector2.UP)
		check(lights[index].lit, "real hook lights authored corner brazier")
		check_eq(enemy.lit_brazier_count(), index + 1, "natural pre-jar lighting accumulates")
	for decoy in enemy.decoys:
		check(not decoy.visible and not decoy.enabled, "four actual lights dissolve false targets")
	await capture_state("warden-four-lights")
	check(not GameState.has_item(&"glow_jar"), "four-brazier solution grants no premature jar")
	for attempt in range(40):
		if not is_instance_valid(enemy) or enemy.is_dying() or enemy.is_dead:
			break
		await hook_enemy(enemy)
	check(GameState.has_flag(&"mini_cave_5_4"), "actual hook finish earns Warden defeat")
	if is_instance_valid(enemy):
		check(not enemy.contact_hitbox.active, "dying Warden contact stops")
	await seconds(1.7)
	check(not GameState.has_item(&"glow_jar"), "Warden defeat does not inject item")
	await edge(&"cave_5_4", &"cave_5_5", Vector2.LEFT)
	room = world.get_room(&"cave_5_5")
	var seam = scripted(room, "hidden_seam.gd")
	player.place_at(room.global_position + Vector2(960, 250))
	Input.action_press(&"move_up")
	await seconds(.7)
	release_inputs()
	check_eq(world.get_current_room_id(), &"cave_5_5", "unlit seam blocks before actual jar pickup")
	check(not seam.is_shown, "new-tool seam starts concealed")
	await collect(room, &"glow_jar")
	check(GameState.has_item(&"glow_jar"), "actual post-Warden pedestal earns glow jar")
	check(GameState.has_flag(&"picked_glow_jar"), "jar has actual pickup persistence")
	await edge(&"cave_5_5", &"cave_5_4", Vector2.RIGHT)
	room = world.get_room(&"cave_5_4")
	check_eq(room.get_enemies().size(), 0, "earned Warden defeat prevents actual room respawn")
	await edge(&"cave_5_4", &"cave_5_5", Vector2.LEFT)


func seam_key_and_lockpick() -> void:
	var room := await enter(&"cave_5_5")
	var seam = scripted(room, "hidden_seam.gd")
	var peer := world.get_room(&"cave_5_6")
	var opposite = scripted(peer, "hidden_seam.gd")
	await swing_from(seam.global_position, Vector2.UP)
	check(not seam.is_shown, "hook cannot replace new jar on hidden step")
	await throw_jar(room.global_position + Vector2(960, 432), Vector2.UP)
	await seconds(1.8)
	check(
		seam.is_revealed and opposite.is_revealed,
		"actual jar permanently reveals both preloaded step endpoints"
	)
	check(GameState.has_flag(&"revealed_e185"), "permanent reveal has exact shared flag")
	await edge(&"cave_5_5", &"cave_5_6", Vector2.UP)
	room = world.get_room(&"cave_5_6")
	await collect(room, &"key_c5_2")
	check_eq(GameState.keys_in(&"c5"), 1, "actual Unlit Stacks key credits c5")
	await seconds(6.2)
	check(
		not scripted(room, "hidden_seam.gd").is_in_group(&"revealable"),
		"permanent seam survives jar burnout"
	)
	await edge(&"cave_5_6", &"cave_5_5", Vector2.DOWN)
	await edge(&"cave_5_5", &"cave_5_7", Vector2.DOWN)
	await edge(&"cave_5_7", &"cave_5_9", Vector2.RIGHT)
	room = world.get_room(&"cave_5_9")
	await blocked(
		Vector2(960, 730),
		&"move_down",
		scripted(room, "boss_door.gd"),
		"boss door without Lockpick"
	)
	await edge(&"cave_5_9", &"cave_5_7", Vector2.LEFT)
	room = world.get_room(&"cave_5_7")
	peer = world.get_room(&"cave_5_8")
	await contact(scripted(room, "locked_door.gd"), Vector2.LEFT)
	check(
		scripted(peer, "locked_door.gd").is_open,
		"second earned key opens both Vault of Names endpoints"
	)
	check_eq(GameState.keys_in(&"c5"), 0, "second actual key consumed exactly once")
	check_eq(GameState.keys_in(&"c1"), 1, "both c5 locks preserve actual c1 key")
	await edge(&"cave_5_7", &"cave_5_8", Vector2.LEFT)
	room = world.get_room(&"cave_5_8")
	await collect(room, &"bigkey_c5")
	check(GameState.has_big_key(&"c5"), "actual Vault of Names Lockpick earned")
	await edge(&"cave_5_8", &"cave_5_7", Vector2.RIGHT)
	await edge(&"cave_5_7", &"cave_5_9", Vector2.RIGHT)
	room = world.get_room(&"cave_5_9")
	peer = world.get_room(&"cave_5_10")
	await contact(scripted(room, "boss_door.gd"), Vector2.DOWN)
	check(scripted(peer, "boss_door.gd").is_open, "actual Lockpick opens preloaded Last Page peer")
	check(GameState.has_big_key(&"c5"), "Lockpick is retained")
	await edge(&"cave_5_9", &"cave_5_10", Vector2.DOWN)


func last_page() -> void:
	var room := await enter(&"cave_5_10")
	var boss = scripted_enemy(room, "archivist.gd")
	check(boss != null, "actual assembled Archivist")
	if boss == null:
		return
	check_eq(
		room.find_children("Lectern*", "StaticBody2D", true, false).size(),
		6,
		"six actual solid lecterns"
	)
	var rewards := pickups(room).filter(
		func(n: PickupBase) -> bool: return n.kind in [&"fragment", &"wick_core"]
	)
	check_eq(rewards.size(), 2, "exactly one actual fragment/core pair")
	for reward: PickupBase in rewards:
		check(not reward.visible, "rewards dormant before actual boss defeat")
	await natural_ward(boss)
	player.set_hurtbox_enabled(self, false)
	for attempt in range(30):
		if boss.phase > 1:
			break
		await hook_enemy(boss)
	check_eq(boss.phase, 2, "actual hooks reach natural second phase")
	await wait_copies(boss, 3)
	var before: int = boss.hp
	await hook_enemy(boss)
	check_eq(boss.hp, before, "unlit actual hook cannot bypass real-copy challenge")
	if not boss.copies.is_empty():
		var copy: Node2D = boss.copies[0]
		await hook_enemy(copy)
		check_eq(boss.hp, before, "actual decoy hook never damages true Archivist")
	await light_boss(boss)
	check(boss.jar_lit() and boss.shadow.visible, "actual earned jar exposes real-only shadow")
	await capture_state("archivist-lit-copies")
	await hook_enemy(boss)
	check(boss.hp < before, "actual lit hook breaks page for real damage")
	check(not boss.copying and boss.copies.is_empty(), "actual page break clears decoys")
	# A real player death resets an unfinished boss; preserve the genuinely earned kit and gates.
	var earned := summary()
	player.set_hurtbox_enabled(self, true)
	player.take_damage(99, player.global_position + Vector2(10, 0))
	await await_respawn()
	check_eq(world.get_current_room_id(), &"ow_6_3", "actual boss death checkpoint is Lantern Isle")
	check(
		not GameState.has_flag(&"boss_cave_5_10_defeated"),
		"unfinished boss never earns false defeat"
	)
	earned["health"] = GameState.max_health
	check_eq(summary(), earned, "actual death preserves full earned route state")
	player.set_hurtbox_enabled(self, false)
	room = await enter(&"cave_5_10")
	boss = scripted_enemy(room, "archivist.gd")
	rewards = pickups(room).filter(
		func(n: PickupBase) -> bool: return n.kind in [&"fragment", &"wick_core"]
	)
	check_eq(boss.hp, 30, "actual player death resets boss HP")
	check_eq(boss.phase, 1, "actual player death resets boss phase")
	check(boss.copies.is_empty(), "actual reset leaves no stale mirror copies")
	var phase_three_copies := false
	for attempt in range(80):
		if not is_instance_valid(boss) or boss.is_dying() or boss.is_dead:
			break
		if boss.is_in_intro() or boss.is_pausing() or not boss.hurtbox.enabled:
			await frames(15)
			continue
		if boss.copying:
			if boss.phase == 3 and not phase_three_copies:
				check_eq(boss.copies.size(), 4, "natural last phase creates four real decoys")
				phase_three_copies = true
			await light_boss(boss)
		await hook_enemy(boss)
	check(phase_three_copies, "actual fight reaches live final-page copy window")
	check(
		GameState.has_flag(&"boss_cave_5_10_defeated"),
		"actual jar and player hook finish Archivist"
	)
	if is_instance_valid(boss):
		check(not boss.contact_hitbox.active, "actual dying boss contact harmless")
		boss.reset_fight()
		check(boss.is_dying(), "reset cannot revive earned defeat during death throes")
	await seconds(1.7)
	check(not is_instance_valid(boss), "actual death throes complete")
	var remaining_projectiles := 0
	for shot in get_tree().get_nodes_in_group(&"projectiles"):
		if room.is_ancestor_of(shot):
			remaining_projectiles += 1
	check_eq(remaining_projectiles, 0, "actual death clears all owned ink and page projectiles")
	for reward: PickupBase in rewards:
		check(reward.visible, "actual canonical defeat reveals room reward")
	await capture_state("archivist-rewards")
	var maximum := GameState.max_health
	await collect(room, &"frag_c5")
	await collect(room, &"wick_core_c5")
	check(GameState.has_flag(&"frag_c5"), "actual Fragment of Memory acquired")
	check_eq(GameState.max_health, maximum + 2, "single actual cave core adds one heart")
	await edge(&"cave_5_10", &"cave_5_9", Vector2.UP)
	await edge(&"cave_5_9", &"cave_5_10", Vector2.DOWN)
	room = world.get_room(&"cave_5_10")
	check_eq(room.get_enemies().size(), 0, "defeated Archivist remains absent on physical return")
	check_eq(GameState.max_health, maximum + 2, "physical return cannot duplicate core")
	for reward: PickupBase in pickups(room):
		if reward.kind in [&"fragment", &"wick_core"]:
			check(not reward.visible, "collected reward remains dormant")


func natural_ward(boss: EnemyBase) -> void:
	while boss.is_in_intro():
		await frames(1)
	player.set_hurtbox_enabled(self, true)
	player.place_at(boss.global_position + Vector2(600, -240))
	player.facing = Vector2.LEFT
	Input.action_press(&"ward")
	await frames(3)
	check(player.ward_up, "actual ward is raised before natural ink volley")
	var blocked_hits: Array[int] = []
	var observed: Dictionary = {}
	var health := GameState.health
	for tick in range(330):
		for shot in get_tree().get_nodes_in_group(&"projectiles"):
			if not shot is EnemyProjectile or not world.get_room(&"cave_5_10").is_ancestor_of(shot):
				continue
			var hit: Hitbox = shot.hitbox
			if hit != null and not observed.has(hit.get_instance_id()):
				observed[hit.get_instance_id()] = true
				hit.blocked.connect(func() -> void: blocked_hits.append(1))
		player.facing = player.global_position.direction_to(boss.global_position)
		await frames(1)
		if not blocked_hits.is_empty():
			break
	check(not blocked_hits.is_empty(), "real held ward blocks naturally authored Archivist ink")
	check_eq(GameState.health, health, "actual ward protects health during ink block")
	release_inputs()


func wait_copies(boss: EnemyBase, count: int) -> void:
	for tick in range(240):
		if boss.copying and boss.hurtbox.enabled and not boss.is_pausing():
			break
		await frames(1)
	check(boss.copying and boss.hurtbox.enabled, "natural phase reaches live copy window")
	check_eq(boss.copies.size(), count, "natural phase creates contracted number of decoys")


func light_boss(boss: EnemyBase) -> void:
	for tick in range(600):
		if boss.jar_lit():
			await frames(2)
			return
		if get_tree().get_nodes_in_group(&"glow_light").is_empty():
			player.place_at(world.get_room(&"cave_5_10").global_position + Vector2(960, 192))
			player.facing = Vector2.DOWN
			GameState.set_active_item(&"glow_jar")
			if player.use_item():
				await frames(40)
		else:
			await frames(15)
		await frames(1)
	check(boss.jar_lit(), "real jar reaches natural Archivist copy position")


func throw_jar(at: Vector2, facing: Vector2) -> void:
	player.place_at(at)
	player.facing = facing
	GameState.set_active_item(&"glow_jar")
	await frames(3)
	check(player.use_item(), "actual earned jar is thrown")


func hook_enemy(enemy: Node2D) -> void:
	# Position only the hero; actual AI, invulnerability windows, swaps and collisions continue.
	var direction := Vector2.UP
	var room := world.get_room(world.get_current_room_id())
	for candidate: Vector2 in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var at := enemy.global_position - candidate * 90
		var local := at - room.global_position
		if not Rect2(120, 120, 1680, 720).has_point(local):
			continue
		var query := PhysicsPointQueryParameters2D.new()
		query.position = at
		query.collision_mask = Layers.WORLD
		query.collide_with_areas = false
		if room.get_world_2d().direct_space_state.intersect_point(query, 1).is_empty():
			direction = candidate
			break
	await swing_from(enemy.global_position, direction)
	await frames(10)


func edge(from: StringName, to: StringName, direction: Vector2) -> void:
	var room := await enter(from)
	var at := Vector2(960, 200) if direction == Vector2.UP else Vector2(960, 740)
	if direction == Vector2.LEFT:
		at = Vector2(240, 480)
	if direction == Vector2.RIGHT:
		at = Vector2(1680, 480)
	player.place_at(room.global_position + at)
	await cross(action_for(direction), to)


func await_respawn() -> void:
	for tick in range(400):
		await frames(1)
		if not player.is_dead() and not world.is_transitioning():
			return
	check(false, "actual death flow completes bounded respawn")


func persistence() -> void:
	check(not SaveGame.enabled, "ordinary user save writes stay disabled")
	var room := await enter(&"cave_5_1")
	player.place_at(door_to(room, &"ow_6_3").global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"ow_6_3", "actual C05 return door reaches Lantern Isle")
	await seconds(.5)
	check_eq(world.get_current_room_id(), &"ow_6_3", "mouth return marker avoids bounce")
	check(
		isolated_test_profile(),
		"full-state disk proof requires temporary isolated userdata"
	)
	if not isolated_test_profile():
		return
	var before := SaveGame._snapshot()
	SaveGame.enabled = true
	check(SaveGame.save(), "actual full earned C05 state writes isolated slot")
	reset_state()
	check(SaveGame.load_into_state(), "isolated full C05 disk state reloads")
	var restored := SaveGame._snapshot()
	check_near(
		restored["playtime"],
		before["playtime"],
		0.000001,
		"JSON retains playtime within microsecond precision"
	)
	before["playtime"] = restored["playtime"]
	check_eq(restored, before, "every persistent field survives actual disk roundtrip")
	SaveGame.enabled = false
	await dispose(world)
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	room = await enter(&"cave_5_5")
	check(
		scripted(room, "hidden_seam.gd").is_revealed,
		"permanent seam restores after disk and unload"
	)
	room = await enter(&"cave_5_6")
	check(
		scripted(room, "hidden_seam.gd").is_revealed, "opposite seam restores after disk and unload"
	)
	room = await enter(&"cave_5_4")
	check_eq(room.get_enemies().size(), 0, "earned mini stays absent after disk reload")
	room = await enter(&"cave_5_10")
	check_eq(room.get_enemies().size(), 0, "earned boss stays absent after disk reload")
	for reward: PickupBase in pickups(room):
		if reward.kind in [&"fragment", &"wick_core"]:
			check(not reward.visible, "disk cannot duplicate rewards")
	var earned := summary()
	player.set_hurtbox_enabled(self, true)
	player.take_damage(99, player.global_position + Vector2(10, 0))
	await await_respawn()
	earned["health"] = GameState.max_health
	check_eq(summary(), earned, "post-victory actual death preserves all earned progression")
	check_eq(
		world.get_current_room_id(),
		&"ow_6_3",
		"post-victory death returns to actual mouth checkpoint"
	)


func capture_state(label: String) -> void:
	if OS.get_environment("WICK_C05_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		get_viewport().get_texture().get_image().save_png("/tmp/wick-c05-" + label + ".png"),
		OK,
		"actual C05 state capture " + label
	)
