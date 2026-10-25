extends TestCase
## Controlled positioned fixtures verify mechanics, not human balance.

const GALLERY := "res://tests/fixtures/gallery/B09.tscn"


func run() -> void:
	await _plate_visual_states()
	await _room_clone_lifecycle()
	await _tools_and_finish()
	await _attacks_and_reset()
	await _lids_refill_and_phase_two()
	if "--lock-world-captures" in OS.get_cmdline_user_args():
		await _world_plate_capture()


func _plate_visual_states() -> void:
	# User-data fixtures exercise missing and incomplete art independently of mapper timing.
	var texture_path := "user://b09_plate_fixture.png"
	var manifest_path := "user://b09_plate_fixture.json"
	var image := Image.create(160, 160, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.7, 0.5, 0.2))
	check_eq(image.save_png(texture_path), OK, "plate fixture texture saves")
	for mode in ["missing", "incomplete", "painted"]:
		reset_state()
		var animations := {"closed": {"file": texture_path, "frames": 1}}
		if mode == "painted":
			animations["open"] = {"file": texture_path, "frames": 1}
		var manifest := {}
		if mode != "missing":
			manifest["lock_plate"] = {
				"cell": [160, 160], "anchor": [80, 80], "centered": true, "animations": animations
			}
		var file := FileAccess.open(manifest_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(manifest))
		file.close()
		SpriteVisual.use_manifest(manifest_path)
		var room := _fixture()
		var boss = room.get_node("Enemies/LockWarden")
		await seconds(1.6)
		check_eq(boss.plates.size(), 4, "visual fixture keeps four targets")
		for plate in boss.plates:
			check_eq(plate._uses_painted_eye(), mode == "painted", "usable art alone hides eye")
			check_eq(plate.eye.position, Vector2(0, -48), "visual keeps eye position")
			check_eq(plate.plate_box.position, Vector2.ZERO, "visual keeps plate position")
			if mode == "painted":
				var visual := plate.get_node("Visual") as SpriteVisual
				check_eq(visual.position, Vector2(16, -30), "constant painted target alignment")
				check_eq(visual.animation, &"closed", "painted plate starts closed")
				var hit := Hitbox.new()
				hit.kind = &"sling"
				check(plate._eye_accepts(hit), "painted eye accepts sling immediately")
				check_eq(plate.lid_left, 6.0, "visual preserves six-second window")
				hit.kind = &"explosion"
				check(plate._plate_accepts(hit), "damage gate opens before visual update")
				plate._refresh_plate_visual()
				check_eq(visual.animation, &"open", "existing lid window selects open")
				plate.lid_left = 0.001
				plate._physics_process(0.002)
				check_eq(visual.animation, &"closed", "expired window selects closed")
				check(not plate._plate_accepts(hit), "expired window rejects damage")
				check_eq(visual.position, Vector2(16, -30), "state change keeps offset")
				hit.free()
		await dispose(room)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)


func _fixture() -> Room:
	var scene := load(GALLERY) as PackedScene
	check(scene != null, "owned gallery loads")
	var room := scene.instantiate() as Room
	add_child(room)
	room.enter()
	return room


func _world_plate_capture() -> void:
	# Optional graphics proof runs only in an isolated project with the reviewed real mapping.
	reset_state()
	check(SpriteVisual.has_art(&"lock_plate"), "World proof requires real plate mapping")
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var scene := load("res://scenes/world/world.tscn") as PackedScene
	var world := scene.instantiate() as World
	viewport.add_child(world)
	world.start_at(&"cave_9_10")
	var room := world.get_room(&"cave_9_10")
	var boss = room.get_node("Enemies/LockWarden1")
	var player := world.player
	player.set_hurtbox_enabled(self, false)
	GameState.acquire_item(&"pitch_pot")
	GameState.acquire_item(&"tallow_sling")
	GameState.add_slugs(30)
	GameState.add_pitch_pots(10)
	player.place_at(room.global_position + Vector2(300, 192))
	await seconds(1.6)
	check_eq(boss.plates.size(), 4, "actual C9 Room has four painted targets")
	await _capture_world_plate(viewport, "closed")
	world.set_debug_draw(true)
	await _capture_world_plate(viewport, "targets")
	world.set_debug_draw(false)
	for i in range(4):
		var plate = boss.plates[0]
		var visual := plate.get_node("Visual") as SpriteVisual
		check(plate._uses_painted_eye(), "actual target suppresses fallback eye")
		check_eq(visual.position, Vector2(16, -30), "actual Room uses reviewed offset")
		GameState.set_active_item(&"tallow_sling")
		player.place_at(plate.eye.global_position + Vector2(-240, 0))
		player.facing = Vector2.RIGHT
		check(player.use_item(), "World actual sling launches")
		await seconds(0.5)
		check(plate.lid_left > 5, "World actual slug opens live eye")
		check_eq(visual.animation, &"open", "World painted eye reflects live opening")
		await _capture_world_plate(viewport, "open-%d" % i)
		GameState.set_active_item(&"pitch_pot")
		player.place_at(plate.global_position + Vector2(-192, 0))
		player.facing = Vector2.RIGHT
		check(player.use_item(), "World actual pot placed")
		player.place_at(room.global_position + Vector2(300, 192))
		await seconds(1.9)
		check(not is_instance_valid(plate), "broken painted target frees without animation delay")
		check_eq(boss.plates.size(), 3 - i, "World pot removes exactly one target")
	check_eq(boss.phase, 2, "World four real targets unlock core phase")
	check_eq(boss.hp, 24, "World painted targets preserve core health")
	check(boss.has_node("KeyholeVisual"), "unaccepted keyhole keeps procedural visual")
	await seconds(0.7)
	await _capture_world_plate(viewport, "plates-removed")
	await dispose(viewport)


func _capture_world_plate(viewport: SubViewport, label: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var path := "/tmp/wickwarden-b09-world-%s.png" % label
	check_eq(viewport.get_texture().get_image().save_png(path), OK, "World proof capture saves")
	print("saved ", path)


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


func _helper_counts(boss: Node) -> Vector2i:
	var counts := Vector2i.ZERO
	for child in boss.get_node("Hurtbox").get_children():
		if child is CollisionShape2D:
			counts.x += 1
	var script = boss.get_script()
	for child in boss.get_children():
		if child.get_script() == script.KeyholeVisual:
			counts.y += 1
	return counts


func _room_clone_lifecycle() -> void:
	for grid in [Vector2i.ZERO, Vector2i(2, 3)]:
		reset_state()
		var scene := load(GALLERY) as PackedScene
		var room := scene.instantiate() as Room
		room.grid = grid
		# An authored child must survive generated-helper retirement.
		var sentinel := Node2D.new()
		sentinel.name = "AuthoredSentinel"
		room.get_node("Enemies/LockWarden/Hurtbox").add_child(sentinel)
		add_child(room)
		var actor_scene := load("res://scenes/enemies/bosses/lock_warden.tscn") as PackedScene
		var fresh = actor_scene.instantiate()
		fresh.position = Vector2(960, 600)
		fresh.room_rect = room.interior_rect()
		room.get_node("Props").add_child(fresh)
		check_eq(_helper_counts(fresh), Vector2i(1, 1), "fresh canonical core and keyhole")
		await seconds(1.6)
		check_eq(fresh.plates.size(), 4, "fresh canonical four plates")
		await dispose(fresh)
		for visit in range(3):
			room.enter()
			var boss = room.get_node("Enemies/LockWarden")
			check_eq(_helper_counts(boss), Vector2i(1, 1), "Room clone canonical core and keyhole")
			check(boss.hurtbox.has_node("AuthoredSentinel"), "authored helper survives")
			check_eq(boss.hurtbox.hurt.get_connections().size(), 1, "one live core signal target")
			await seconds(1.6)
			check_eq(boss.plates.size(), 4, "Room clone four public plates")
			var script = boss.get_script()
			var actual_plates := 0
			for child in boss.get_children():
				if child.get_script() == script.Plate:
					actual_plates += 1
			check_eq(actual_plates, 4, "exactly four actual plate helpers")
			var live_targets: Array[Hurtbox] = [boss.hurtbox]
			for plate in boss.plates:
				live_targets.append(plate.eye)
				live_targets.append(plate.plate_box)
			for target in get_tree().get_nodes_in_group(&"hurtboxes"):
				if boss.is_ancestor_of(target):
					check(
						live_targets.has(target),
						"no stale generated hurt target outside public targets"
					)
			for i in range(4):
				var plate = boss.plates[i]
				var expected: Vector2 = room.global_position + Vector2(960, 600) + boss.OFFSETS[i]
				check(plate.is_inside_tree(), "public plate is live")
				check_eq(plate.owner_boss, boss, "plate targets current clone")
				check_eq(
					plate.global_position, expected, "plate stays at translated canonical position"
				)
				check_eq(
					plate.eye.global_position,
					expected + Vector2(0, -48),
					"eye is translated with plate"
				)
				check_eq(
					plate.plate_box.hurt.get_connections().size(), 1, "one live plate signal target"
				)
			check_eq(
				boss.hurtbox.global_position,
				room.global_position + Vector2(960, 600),
				"core has no origin-space copy"
			)
			room.leave()
			await frames(2)
			check(room.get_node("Enemies").get_children().is_empty(), "leave removes live targets")
		GameState.set_flag(&"boss_cave_9_10_defeated")
		room.enter()
		var retired = room.get_node("Enemies/LockWarden")
		check(retired.is_dead, "defeated clone retires")
		check_eq(
			_helper_counts(retired), Vector2i.ZERO, "retired clone has no generated core or keyhole"
		)
		check(retired.plates.is_empty(), "retired clone has no plates")
		check(
			retired.has_node("BodyShape") and retired.has_node("ContactHitbox/Shape"),
			"authored body and contact survive"
		)
		await dispose(room)
