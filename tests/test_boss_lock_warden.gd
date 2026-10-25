extends TestCase
## Controlled positioned fixtures verify mechanics, not human balance.

const GALLERY := "res://tests/fixtures/gallery/B09.tscn"


func run() -> void:
	await _tools_and_finish()
	await _attacks_and_reset()
	await _lids_refill_and_phase_two()


func _fixture() -> Room:
	var scene := load(GALLERY) as PackedScene
	check(scene != null, "owned gallery loads")
	var room := scene.instantiate() as Room
	add_child(room)
	room.enter()
	return room


func _tools_and_finish() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/LockWarden")
	var player := make_player(room, Vector2(300, 192))
	player.set_hurtbox_enabled(self, false)
	GameState.acquire_item(&"pitch_pot")
	GameState.acquire_item(&"tallow_sling")
	GameState.add_slugs(30)
	GameState.add_pitch_pots(10)
	check(boss.is_in_intro(), "intro blocks combat")
	await seconds(1.6)
	check_eq(boss.plates.size(), 4, "four corner plates")
	check_eq(get_tree().get_nodes_in_group(&"wicklings").size(), 2, "two phase-one wicklings")
	await _capture(room, "plates")
	var plate = boss.plates[0]
	var hit := make_hitbox(room, plate.global_position, Layers.Team.PLAYER, 4, 40)
	hit.kind = &"explosion"
	await frames(4)
	check_eq(plate.hp, 4, "closed lid rejects explosion")
	await dispose(hit)
	# Real sling and real pitch pot for every plate, with controlled positioning.
	for i in range(4):
		plate = boss.plates[0]
		GameState.set_active_item(&"tallow_sling")
		player.place_at(plate.eye.global_position + Vector2(-240, 0))
		player.facing = Vector2.RIGHT
		check(player.use_item(), "actual sling launches")
		await seconds(0.5)
		check(plate.lid_left > 5, "actual slug opens lid for six seconds")
		GameState.set_active_item(&"pitch_pot")
		player.place_at(plate.global_position + Vector2(-192, 0))
		player.facing = Vector2.RIGHT
		check(player.use_item(), "actual pot placed")
		player.place_at(Vector2(300, 192))
		await seconds(1.9)
		check_eq(boss.plates.size(), 3 - i, "real explosion breaks one opened plate")
	check_eq(boss.phase, 2, "all plates trigger phase two")
	check_eq(boss.hp, 24, "core retains 24 HP")
	check(not boss.is_arena_locked(), "retreat remains open")
	await seconds(1.4)
	check_eq(get_tree().get_nodes_in_group(&"wicklings").size(), 2, "two fresh phase-two wicklings")
	var core_hit := make_hitbox(room, boss.global_position, Layers.Team.PLAYER, 4, 30)
	core_hit.kind = &"explosion"
	await frames(4)
	check_eq(boss.hp, 24, "closed keyhole rejects damage")
	await dispose(core_hit)
	for _frame in range(360):
		if boss.open_left > 2.8:
			break
		await frames(1)
	check(boss.open_left > 0, "tumbler tell opens keyhole")
	await _capture(room, "keyhole")
	# Controlled damage fixtures exercise the actual receiving API during the opening.
	for i in range(6):
		core_hit = make_hitbox(room, boss.global_position, Layers.Team.PLAYER, 4, 30)
		core_hit.kind = &"explosion"
		await frames(3)
		await dispose(core_hit)
		await seconds(0.3)
	check(boss.is_dying(), "six core explosions begin death")
	check(GameState.has_flag(&"boss_cave_9_10_defeated"), "canonical boss flag")
	await seconds(1.6)
	check_eq(get_tree().get_nodes_in_group(&"projectiles").size(), 0, "death clears projectiles")
	check(not GameState.has_flag(&"frag_c9"), "persistent fragment remains room-owned")
	await dispose(room)
	room = _fixture()
	boss = room.get_node("Enemies/LockWarden")
	check(boss.is_dead and not boss.visible, "defeated boss retires on reentry")
	await dispose(room)


func _attacks_and_reset() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/LockWarden")
	await seconds(5.65)
	var keys := get_tree().get_nodes_in_group(&"projectiles")
	check_eq(keys.size(), 8, "phase-one eight-key ring after 0.6s tell")
	for key in keys:
		check_near(key.speed, 260, 0.01, "key speed")
		check_eq(key.damage, 2, "key damage")
		check(key.hitbox.blockable, "ward blocks keys")
	# Controlled timer fixture isolates the actual deadbolt geometry and player physics.
	boss.clear_hazards()
	boss.bolt_left = 0
	boss.volley_left = 100
	var player := make_player(room, Vector2(300, 480))
	GameState.max_health = 40
	GameState.full_heal()
	await seconds(1.9)
	check_eq(GameState.health, 40, "192px slot is safe")
	await _capture(room, "deadbolt")
	player.place_at(Vector2(600, 288))
	await seconds(1.1)
	check_eq(GameState.health, 36, "moving deadbolt damages outside slot")
	boss.reset_fight()
	await frames(3)
	check(boss.is_in_intro(), "reset restores intro")
	check_eq(boss.hp, 40, "reset total health")
	check_eq(boss.phase, 1, "reset phase")
	check_eq(boss.plates.size(), 0, "reset clears stale plates")
	await seconds(1.6)
	check_eq(boss.plates.size(), 4, "reset recreates four plates")
	await dispose(room)


func _lids_refill_and_phase_two() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/LockWarden")
	GameState.acquire_item(&"pitch_pot")
	GameState.acquire_item(&"tallow_sling")
	GameState.slugs = 0
	await seconds(1.7)
	var kinds: Array[StringName] = []
	for pickup in get_tree().get_nodes_in_group(&"pickups"):
		kinds.append(pickup.kind)
	check(kinds.has(&"pitch_pot_bundle"), "low pot resupply")
	check(kinds.has(&"slug_bundle"), "low slug resupply")
	var plate = boss.plates[0]
	var hit := make_hitbox(room, plate.eye.global_position, Layers.Team.PLAYER, 1, 20)
	hit.kind = &"hook"
	await frames(3)
	check_eq(plate.lid_left, 0.0, "hook cannot open lid")
	await dispose(hit)
	hit = make_hitbox(room, plate.eye.global_position, Layers.Team.PLAYER, 1, 20)
	hit.kind = &"sling"
	await frames(3)
	await dispose(hit)
	check(plate.lid_left > 5.8, "sling starts six-second opening")
	await seconds(6.1)
	check_eq(plate.lid_left, 0.0, "lid closes after six seconds")
	# Controlled fixtures verify thrown3 + explosion4 and phase-two schedules.
	plate.lid_left = 6
	hit = make_hitbox(room, plate.global_position, Layers.Team.PLAYER, 99, 20)
	hit.kind = &"thrown"
	await frames(3)
	check_eq(plate.hp, 1, "thrown damage is exactly three")
	await dispose(hit)
	boss._start_phase(2)
	boss._clear_plates()
	await seconds(1.3)
	boss.clear_hazards()
	boss.volley_left = 0
	boss.bolt_left = 100
	await seconds(0.7)
	var keys := get_tree().get_nodes_in_group(&"projectiles")
	check_eq(keys.size(), 12, "phase-two twelve-key ring")
	boss.clear_hazards()
	boss.volley_left = 100
	boss.bolt_left = 0
	var player := make_player(room, Vector2(300, 288))
	GameState.max_health = 40
	GameState.full_heal()
	GameState.acquire_item(&"skitter_boots")
	GameState.set_active_item(&"skitter_boots")
	await seconds(1.4)
	player.facing = Vector2.RIGHT
	check(player.use_item(), "real boots launch over deadbolt")
	await seconds(0.6)
	check_eq(GameState.health, 40, "boots clear moving deadbolt")
	boss.clear_hazards()
	player.place_at(Vector2(400, 288))
	player.facing = Vector2.LEFT
	Input.action_press(&"ward")
	await frames(3)
	var key := EnemyProjectile.new()
	key.speed = 260
	key.damage = 2
	key.blockable_by_ward = true
	room.add_child(key)
	key.launch(Vector2(300, 288), Vector2.RIGHT)
	await seconds(0.6)
	check_eq(GameState.health, 40, "actual ward blocks key projectile")
	Input.action_release(&"ward")
	await dispose(room)


func _capture(room: Room, label: String) -> void:
	if not "--lock-captures" in OS.get_cmdline_user_args():
		return
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 960)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	room.reparent(viewport, false)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var path := "/tmp/wickwarden-b09-%s.png" % label
	viewport.get_texture().get_image().save_png(path)
	print("saved ", path)
	room.reparent(self, false)
	await dispose(viewport)
