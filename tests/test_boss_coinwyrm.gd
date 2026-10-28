extends TestCase
## Controlled positioned fixtures verify mechanics, not human balance.

const GALLERY := "res://tests/fixtures/gallery/B08.tscn"


class MissingWarningArtCoinwyrm:
	extends "res://scripts/enemies/bosses/coinwyrm.gd"

	func _load_bite_warning_texture() -> Texture2D:
		return null


func run() -> void:
	await _bite_warning_lifecycle()
	await _bite_warning_fallback_and_reset()
	await _challenge()
	await _windows_and_anchor()
	await _attacks()
	await _strike_presentation()
	await _directional_bite_head()
	await _coin_presentation()
	await _physical_finish()
	await _finish()
	if "--coin-captures" in OS.get_cmdline_user_args():
		await _crown_capture()
		await _plate_world_capture()
		await _tail_world_capture()
		await _bite_world_capture()


func _fixture() -> Room:
	var scene := load(GALLERY) as PackedScene
	check(scene != null, "gallery loads")
	var room := scene.instantiate() as Room
	add_child(room)
	room.enter()
	return room


func _reel(player: Player, plate: Node2D) -> void:
	player.place_at(plate.global_position + Vector2(0, 200))
	player.facing = Vector2.UP
	check(player.use_item(), "actual reel launches")
	await seconds(1.4)


func _challenge() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Coinwyrm")
	var player := make_player(room, Vector2(1728, 480))
	player.set_hurtbox_enabled(self, false)
	GameState.acquire_item(&"reel_line")
	GameState.set_active_item(&"reel_line")
	check_eq(GameState.currency, 0, "empty wallet fixture")
	check(boss.is_in_intro(), "intro active")
	await seconds(1.6)
	check_eq(boss.state, &"quiver", "0.9s heap tell")
	check(not boss.hurtbox.enabled, "submerged head untargetable")
	check(boss.global_position.distance_to(player.global_position) >= 288, "heap keeps distance")
	var heaps: Array[SpriteVisual] = boss._heap_visuals()
	check_eq(heaps.size(), 4, "arena has four painted heaps")
	var active_heap: SpriteVisual
	for heap in heaps:
		if heap.global_position.distance_to(boss.global_position) < 1:
			active_heap = heap
	check(active_heap != null, "selected heap exists")
	if active_heap != null:
		check_eq(active_heap.animation, &"quiver", "selected heap warns before rearing")
		var light := active_heap.get_node_or_null("CueLight") as PointLight2D
		check(
			light != null and not light.is_in_group(&"glow_light"),
			"heap cue light is presentation only"
		)
	await seconds(0.9)
	if active_heap != null:
		check_eq(active_heap.animation, &"burst", "selected heap bursts when boss rears")
	check_eq(boss.plates.size(), 3, "three reelable plates")
	check(boss.get_node("Visual") is SpriteVisual, "head uses painted art")
	var head_light := boss.get_node_or_null("HeadLight") as PointLight2D
	check(
		head_light != null and not head_light.is_in_group(&"glow_light"),
		"head light is presentation only"
	)
	for part in boss.plates:
		check(part.get_node("Visual") is SpriteVisual, "plate uses painted art")
		check(part.get_node_or_null("PlateCue") != null, "each plate has a readable rim")
		var plate_light := part.get_node_or_null("PlateLight") as PointLight2D
		check(
			plate_light != null and not plate_light.is_in_group(&"glow_light"),
			"plate light is presentation only"
		)
		check_eq(
			part.position, boss.OFFSETS[part.get_meta("slot")], "painted plate keeps hitbox offset"
		)
	await _capture(room, "plated")
	var hit := make_hitbox(room, boss.global_position, Layers.Team.PLAYER, 4, 100)
	hit.kind = &"hook"
	await frames(4)
	check_eq(boss.hp, 36, "hook cannot bypass armour")
	await dispose(hit)
	var plate = boss.plates[1]
	var removed_cue: WeakRef = weakref(plate.get_node("PlateCue"))
	await _reel(player, plate)
	check_eq(boss.plates.size(), 2, "real tip removes one plate")
	check(removed_cue.get_ref() == null, "the removed plate's rim leaves with it")
	check_eq(GameState.currency, 5, "five bits drop and collect at feet")
	await _reel(player, boss.plates[0])
	await _reel(player, boss.plates[0])
	check(boss.bare, "third real reel exposes head")
	check_eq(boss.plates.size(), 0, "no plates remain")
	await _capture(room, "bare")
	var left: float = boss.state_left
	await seconds(0.5)
	check(boss.bare and boss.state_left < left, "bare window persists")
	player.place_at(boss.global_position + Vector2(0, 108))
	player.facing = Vector2.UP
	Input.action_press(&"attack")
	await frames(10)
	Input.action_release(&"attack")
	check_eq(boss.hp, 34, "actual hook damages bare head")
	boss.reset_fight()
	await frames(3)
	check_eq(boss.hp, 36, "reset full health")
	check_eq(boss.phase, 1, "reset phase one")
	check(boss.is_in_intro(), "reset intro")
	check(boss.plates.is_empty(), "reset clears plates")
	check(not boss.is_arena_locked(), "retreat stays open")
	await dispose(room)


func _capture(room: Room, label: String) -> void:
	if not "--coin-captures" in OS.get_cmdline_user_args():
		return
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 960)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	room.reparent(viewport, false)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var path := "/tmp/wickwarden-b08-%s.png" % label
	check_eq(viewport.get_texture().get_image().save_png(path), OK, "fight capture saves")
	room.reparent(self, false)
	await dispose(viewport)


func _crown_capture() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Coinwyrm")
	await seconds(2.6)
	boss.apply_damage(16, boss.global_position, 0)
	await seconds(2.2)
	check_eq(boss.plates.size(), 4, "crown capture has all four targets")
	await _capture(room, "crown")
	await dispose(room)


func _plate_world_capture() -> void:
	# Controlled presentation states in the real dark room; combat is tested separately.
	reset_state()
	SaveGame.enabled = false
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var world := _world_scene().instantiate() as World
	viewport.add_child(world)
	world.start_at(&"cave_8_12")
	world.player.set_hurtbox_enabled(self, false)
	var boss = world.current_room.get_node("Enemies/Coinwyrm1")
	await seconds(2.6)
	await _save_world_plate_capture(viewport, "plates-dark")
	boss.apply_damage(16, boss.global_position, 0)
	await seconds(2.2)
	check_eq(boss.plates.size(), 4, "dark capture has four plates")
	await _save_world_plate_capture(viewport, "crown-dark")
	for part in boss.plates.duplicate():
		if part.get_meta("slot") != 3:
			boss._plate_pulled(null, part)
	await frames(2)
	check_eq(boss.plates.size(), 1, "dark capture isolates the crown")
	await _save_world_plate_capture(viewport, "crown-only-dark")
	boss._plate_pulled(null, boss.plates[0])
	await frames(2)
	await _save_world_plate_capture(viewport, "bare-dark")
	await dispose(viewport)


func _save_world_plate_capture(viewport: SubViewport, label: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		viewport.get_texture().get_image().save_png("/tmp/wickwarden-b08-%s.png" % label),
		OK,
		"dark plate capture saves"
	)


func _tail_world_capture() -> void:
	reset_state()
	SaveGame.enabled = false
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var scene := _world_scene()
	var world := scene.instantiate() as World
	viewport.add_child(world)
	world.start_at(&"cave_8_12")
	world.player.set_hurtbox_enabled(self, false)
	var boss = world.current_room.get_node("Enemies/Coinwyrm1")
	await seconds(2.6)
	boss.apply_damage(16, boss.global_position, 0)
	await seconds(2.2)
	check_eq(boss.phase, 2, "tail capture reaches phase two")
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		viewport.get_texture().get_image().save_png("/tmp/wickwarden-b08-tail-tell.png"),
		OK,
		"tail tell capture saves"
	)
	var sweep: Node2D
	for _i in range(60):
		await frames(1)
		for hazard in boss._hazards:
			if is_instance_valid(hazard) and hazard.get_script() == boss.get_script().Strike:
				if hazard.tail:
					sweep = hazard
		if sweep != null:
			break
	check(sweep != null, "tail sweep is active for capture")
	var tail_effect: SpriteVisual
	for hazard in boss._hazards:
		if is_instance_valid(hazard):
			var visual := hazard.get_node_or_null("Visual") as SpriteVisual
			if visual != null and visual.kind == &"coinwyrm_tail":
				tail_effect = visual
	check(tail_effect != null and tail_effect.animation == &"sweep", "tail plays sweep")
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		viewport.get_texture().get_image().save_png("/tmp/wickwarden-b08-tail-sweep.png"),
		OK,
		"tail sweep capture saves"
	)
	await seconds(0.55)
	check(
		is_instance_valid(tail_effect) and tail_effect.animation == &"burrow",
		"tail plays burrow after sweep"
	)
	await seconds(0.5)
	check(not is_instance_valid(tail_effect), "tail effect frees after burrowing")
	await dispose(viewport)


func _bite_world_capture() -> void:
	reset_state()
	SaveGame.enabled = false
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var scene := _world_scene()
	var world := scene.instantiate() as World
	viewport.add_child(world)
	world.start_at(&"cave_8_12")
	world.player.set_hurtbox_enabled(self, false)
	var boss = world.current_room.get_node("Enemies/Coinwyrm1")
	await seconds(2.6)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		viewport.get_texture().get_image().save_png("/tmp/wickwarden-b08-bite-tell.png"),
		OK,
		"bite tell capture saves"
	)
	var bite: Node2D
	for _i in range(60):
		await frames(1)
		for hazard in boss._hazards:
			if is_instance_valid(hazard) and hazard.get_script() == boss.get_script().Strike:
				if not hazard.tail:
					bite = hazard
		if bite != null:
			break
	check(bite != null, "bite strike is active for capture")
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		viewport.get_texture().get_image().save_png("/tmp/wickwarden-b08-bite-hit.png"),
		OK,
		"bite strike capture saves"
	)
	await dispose(viewport)


func _world_scene() -> PackedScene:
	return load("res://scenes/world/world.tscn") as PackedScene


func _coin_presentation() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Coinwyrm")
	await seconds(2.6)
	boss._volley()
	var bolts := get_tree().get_nodes_in_group(&"projectiles")
	check_eq(bolts.size(), 5, "coin presentation keeps five projectiles")
	for bolt in bolts:
		check_eq(bolt.visual_kind, &"coinwyrm_coin", "hostile coin has its own art")
		var light := bolt.get_node_or_null("CoinLight") as PointLight2D
		check(
			light != null and not light.is_in_group(&"glow_light"),
			"coin light is presentation only"
		)
		if SpriteVisual.has_art(&"coinwyrm_coin"):
			check(bolt.get_node("Visual") is SpriteVisual, "coin is painted")
	if not bolts.is_empty() and SpriteVisual.has_art(&"coinwyrm_coin"):
		bolts[0].destroy(&"wall")
		var effect := boss.get_parent().get_node_or_null("Puff") as SpriteVisual
		check(effect != null, "coin impact has painted effect")
		if effect != null:
			check_eq(effect.animation, &"impact", "coin impact plays impact frames")
		await seconds(0.6)
		check(not is_instance_valid(effect), "coin impact is freed")
		for heap in boss._heap_visuals():
			check_eq(heap.animation, &"idle", "heap returns to idle after burst")
			check(heap.get_node_or_null("CueLight") == null, "heap cue light is removed")
	await dispose(room)


func _attacks() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Coinwyrm")
	var player := make_player(room, Vector2(1536, 480))
	player.facing = Vector2.LEFT
	Input.action_press(&"ward")
	await seconds(5.1)
	var bolts := get_tree().get_nodes_in_group(&"projectiles")
	check_eq(bolts.size(), 5, "five coin fan")
	for bolt in bolts:
		check_eq(bolt.damage, 2, "coin damage two")
		check_near(bolt.speed, 280, 0.01, "fan speed280")
		check(bolt.hitbox.blockable, "coins wardable")
	var blocked: Array[StringName] = []
	for bolt in bolts:
		bolt.destroyed.connect(func(reason: StringName) -> void: blocked.append(reason))
	await seconds(1.8)
	check(&"ward" in blocked, "actual coin volley blocked by real ward")
	Input.action_release(&"ward")
	# Controlled phase transition: challenge above proves physical armour removal.
	boss.apply_damage(16, boss.global_position, 0)
	check_eq(boss.phase, 2, "20 HP phase two")
	await seconds(2.2)
	check_eq(boss.plates.size(), 4, "phase two crown plate")
	var tail_marker: Node2D
	for hazard in boss._hazards:
		if is_instance_valid(hazard):
			var painted := hazard.get_node_or_null("Visual") as SpriteVisual
			if painted != null and painted.kind == &"coinwyrm_tail":
				tail_marker = hazard
	check(tail_marker != null, "tail tell has painted sprite")
	if tail_marker != null:
		var light_count := 0
		for child in tail_marker.get_children():
			if child is PointLight2D and not child.is_in_group(&"glow_light"):
				light_count += 1
		check_eq(light_count, 7, "tail band is lit without jar gameplay lights")
	for part in boss.plates:
		if part.get_meta("slot") == 3:
			var crown := part.get_node("Visual") as SpriteVisual
			check(crown != null and crown.kind == &"coinwyrm_crown", "phase two crown is separate")
			check(part.get_node("PlateCue").crown, "crown has a distinct rim")
	player.place_at(Vector2(900, 288))
	GameState.max_health = 40
	GameState.full_heal()
	await seconds(0.8)
	check_eq(GameState.health, 37, "real tail row deals three")
	await seconds(1.8)
	bolts = get_tree().get_nodes_in_group(&"projectiles")
	check_eq(bolts.size(), 8, "phase two eight coin ring")
	for bolt in bolts:
		check_near(bolt.speed, 260, 0.01, "ring speed260")
	Events.player_died.emit()
	await frames(3)
	check_eq(boss.hp, 36, "death reset health")
	check(get_tree().get_nodes_in_group(&"projectiles").is_empty(), "reset clears coins")
	check(player != null, "real player fixture")
	await dispose(room)


func _strike_presentation() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Coinwyrm")
	await seconds(2.6)
	boss._strike(boss.global_position, Vector2.RIGHT, false)
	var bite = boss._hazards[-1]
	check_eq(bite.box.damage, 4, "bite damage remains four")
	var polygon := bite.box.get_child(0) as CollisionPolygon2D
	check_eq(polygon.polygon.size(), 26, "bite retains the 180-degree collision polygon")
	check_near(polygon.polygon[1].length(), 150, 0.01, "bite radius remains 150")
	var visual := bite.get_node("Visual") as Node2D
	if SpriteVisual.has_art(&"coinwyrm_coin"):
		check_eq(visual.get_child_count(), 3, "bite shows three painted coin impacts")
		for holder in visual.get_children():
			var impact := holder.get_node_or_null("Visual") as SpriteVisual
			check(impact != null and impact.animation == &"impact", "bite plays painted impact")
	boss._strike(boss.global_position, Vector2.RIGHT, true, boss.global_position)
	var sweep = boss._hazards[-1]
	check_eq(sweep.box.damage, 3, "tail damage remains three")
	var shape := sweep.box.get_child(0) as CollisionShape2D
	check_eq((shape.shape as RectangleShape2D).size, Vector2(1728, 96), "tail band unchanged")
	check_near(sweep.life, 0.12, 0.001, "strike duration remains 0.12 seconds")
	await dispose(room)


func _directional_bite_head() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Coinwyrm")
	var player := make_player(room, Vector2(1728, 480))
	player.set_hurtbox_enabled(self, false)
	await seconds(3.6)
	boss.clear_hazards()
	boss.set_physics_process(false)
	var look := boss.visual as SpriteVisual
	check(look != null, "bite head uses painted visual")
	if look == null:
		await dispose(room)
		return
	check_eq(look.sprite_frames.get_frame_count(&"bite_telegraph"), 2, "bite tell has two frames")
	check_eq(look.sprite_frames.get_frame_count(&"bite"), 3, "bite strike has three frames")
	for plated in [true, false]:
		if not plated:
			for plate in boss.plates.duplicate():
				boss._plate_pulled(null, plate)
			await frames(3)
		check_eq(boss.plates.size(), 3 if plated else 0, "test has expected armour")
		for direction: Vector2 in [Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT]:
			player.place_at(boss.global_position + direction * 250.0)
			boss._bite()
			await frames(20)
			var label := "bite %s plated=%s" % [direction, plated]
			check_eq(look.animation, &"bite_telegraph" if direction == Vector2.DOWN else &"idle",
				label + ": direction-correct tell")
			for plate in boss.plates:
				check_eq(plate.position, boss.OFFSETS[plate.get_meta("slot")],
					label + ": plate collision position unchanged")
			for hazard in boss._hazards:
				if is_instance_valid(hazard) and hazard.get_script() == boss.get_script().Strike:
					check(hazard.tail, label + ": no bite before 0.5 second tell")
			await frames(12)
			var strike: Node2D
			for hazard in boss._hazards:
				if is_instance_valid(hazard) and hazard.get_script() == boss.get_script().Strike:
					if not hazard.tail:
						strike = hazard
			check(strike != null, label + ": strike follows tell")
			if strike != null:
				check_eq(strike.facing, direction, label + ": actual hit area direction")
				check_eq(strike.box.damage, 4, label + ": damage unchanged")
			check_eq(look.animation, &"bite" if direction == Vector2.DOWN else &"idle",
				label + ": correct strike art")
			await frames(20)
			check_eq(look.animation, &"idle", label + ": restores idle")
			check(not is_instance_valid(strike), label + ": 0.12 second strike expires")
	await dispose(room)


func _finish() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Coinwyrm")
	await seconds(2.6)
	# Controlled lethal fixture checks persistence independently of combat duration.
	boss.apply_damage(36, boss.global_position, 0)
	check(not boss.drops_enabled, "random loot disabled")
	check(boss.is_dying(), "death throes begin")
	check(GameState.has_flag(&"boss_cave_8_12_defeated"), "canonical defeat flag")
	check(not boss.contact_hitbox.active, "death contact off")
	await seconds(1.6)
	check(not GameState.has_flag(&"frag_c8"), "room owns persistent fragment")
	for pickup in get_tree().get_nodes_in_group(&"pickups"):
		check(pickup.kind == &"ember", "only timed embers spawned: %s" % pickup.kind)
	await dispose(room)
	room = _fixture()
	boss = room.get_node("Enemies/Coinwyrm")
	await frames(3)
	check(boss.is_dead and not boss.visible, "defeated reload retired")
	await dispose(room)


func _windows_and_anchor() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Coinwyrm")
	var player := make_player(room, Vector2(1728, 480))
	GameState.max_health = 40
	GameState.full_heal()
	await seconds(2.5)
	player.place_at(boss.global_position + Vector2(100, 0))
	# Contact is disabled only for this isolated bite probe.
	boss.set_contact_enabled(false)
	await seconds(0.5)
	check_eq(GameState.health, 36, "real bite cone deals four after tell")
	player.set_hurtbox_enabled(self, false)
	GameState.acquire_item(&"reel_line")
	GameState.set_active_item(&"reel_line")
	await _reel(player, boss.plates[1])
	check_eq(boss.plates.size(), 2, "one plate removed for regrow probe")
	await seconds(2.2)
	check_eq(boss.plates.size(), 3, "one plate regrows at four seconds")
	player.place_at(Vector2(672, 400))
	player.facing = Vector2.UP
	check(player.use_item(), "real reel to pillar ring")
	await seconds(0.2)
	check(player.is_airborne(), "anchor pull is airborne")
	check(not player.take_damage(4, player.global_position), "anchor pull rejects damage")
	await seconds(0.7)
	check_near(
		player.global_position.distance_to(Vector2(672, 192)),
		72,
		1,
		"ring pull stops72px from pillar"
	)
	await dispose(room)


func _physical_finish() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Coinwyrm")
	var player := make_player(room, Vector2(1728, 480))
	player.set_hurtbox_enabled(self, false)
	GameState.acquire_item(&"reel_line")
	GameState.set_active_item(&"reel_line")
	for tick in range(1000):
		if boss.is_dying():
			break
		if boss.state != &"rear" or boss.is_pausing():
			await frames(12)
			continue
		if not boss.plates.is_empty():
			var index := 1 if boss.plates.size() >= 3 else 0
			await _reel(player, boss.plates[index])
			continue
		player.place_at(boss.global_position + Vector2(0, 108))
		player.facing = Vector2.UP
		Input.action_press(&"attack")
		await frames(10)
		Input.action_release(&"attack")
		await frames(24)
	check(boss.is_dying(), "real reels and hook finish both phases")
	check(GameState.has_flag(&"boss_cave_8_12_defeated"), "physical finish persists")
	await dispose(room)


func _bite_warning_lifecycle() -> void:
	reset_state()
	SaveGame.enabled = false
	var room := _fixture()
	var boss = room.get_node("Enemies/Coinwyrm")
	var player := make_player(room, boss.global_position + Vector2(200, 0))
	player.set_hurtbox_enabled(self, false)
	boss._bite()
	var warning := boss.get_parent().get_node_or_null("BiteWarning")
	check(warning != null, "paint warning spawned")
	var marker: Node2D
	for hazard in boss._hazards:
		if (
			is_instance_valid(hazard)
			and hazard.get_script().resource_path.ends_with("telegraph.gd")
		):
			marker = hazard
	check(marker != null and not marker.visible, "original timer is hidden")
	if marker != null:
		check_eq(marker.duration, 0.5, "duration preserved")
		check_eq(marker.radius, 150.0, "radius preserved")
		check_eq(marker.arc_deg, 180.0, "arc preserved")
		var finished := [0]
		marker.finished.connect(func(): finished[0] += 1)
		await frames(15)
		check(
			marker.progress() > 0.35 and marker.progress() < 0.65,
			"warning progress follows original timer"
		)
		check_eq(finished[0], 0, "signal not premature")
		await frames(20)
		check_eq(finished[0], 1, "signal exactly once")
		check(not is_instance_valid(warning), "warning removed with timer")
	await dispose(room)


func _bite_warning_fallback_and_reset() -> void:
	reset_state()
	SaveGame.enabled = false
	var room := _fixture()
	var original = room.get_node("Enemies/Coinwyrm")
	var boss := MissingWarningArtCoinwyrm.new()
	boss.position = original.position
	original.get_parent().add_child(boss)
	original.queue_free()
	var player := make_player(room, boss.global_position + Vector2(200, 0))
	player.set_hurtbox_enabled(self, false)
	boss._bite()
	var marker: Node2D
	for hazard in boss._hazards:
		if (
			is_instance_valid(hazard)
			and hazard.get_script().resource_path.ends_with("telegraph.gd")
		):
			marker = hazard
	check(marker != null and marker.visible, "missing art keeps visible original marker")
	check(
		boss.get_parent().get_node_or_null("BiteWarning") == null,
		"missing art creates no painted cue"
	)
	if marker != null:
		var finished := [0]
		marker.finished.connect(func(): finished[0] += 1)
		await frames(35)
		check_eq(finished[0], 1, "fallback still emits finished once")
		check(not is_instance_valid(marker), "fallback timer finishes normally")
	boss._bite()
	var reset_marker: Node2D = boss._hazards[-1]
	boss.reset_fight()
	await frames(3)
	check(not is_instance_valid(reset_marker), "reset removes fallback timer")
	await dispose(boss)
	boss = null
	var painted = (load("res://scripts/enemies/bosses/coinwyrm.gd") as GDScript).new()
	room.get_node("Enemies").add_child(painted)
	painted._bite()
	var warning: Node = painted.get_parent().get_node_or_null("BiteWarning")
	check(warning != null, "warning exists before reset")
	painted.reset_fight()
	await frames(3)
	check(not is_instance_valid(warning), "reset removes painted warning")
	check(painted._hazards.is_empty(), "reset clears hazards")
	await frames(35)
	check(painted._hazards.is_empty(), "cancelled warning spawns no strike")
	await dispose(room)
