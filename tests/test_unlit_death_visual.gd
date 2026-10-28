extends TestCase
## The real room and hook collision, with the final phase/exposure positioned for a short test.


func run() -> void:
	await _physical_death("complete")
	await _physical_death("missing")
	await _physical_death("clipped")
	await _physical_death("wrong_fps")
	await _physical_death("missing_both")
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)
	reset_state()


func _physical_death(scenario: String) -> void:
	reset_state()
	SaveGame.enabled = false
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)
	SpriteVisual.has_art(&"explosion")
	var entry: Dictionary = SpriteVisual._manifest["fx_boss_death_wax_z1"]
	var animation: Dictionary = entry["animations"]["idle"]
	if scenario in ["missing", "missing_both"]:
		animation["file"] = "res://missing_wax_test.png"
	elif scenario == "clipped":
		var path := "res://clipped_wax_test.png"
		animation["file"] = path
		var img := Image.create(768 * 7, 768, false, Image.FORMAT_RGBA8)
		SpriteVisual._texture_cache[path] = ImageTexture.create_from_image(img)
	elif scenario == "wrong_fps":
		animation["fps"] = 5.0
	if scenario == "missing_both":
		SpriteVisual._manifest.erase("explosion")
	var missing := scenario != "complete"
	var world := (load("res://scenes/world/world.tscn") as PackedScene).instantiate() as World
	add_child(world)
	world.start_at(&"cave_10_14")
	world.player.set_hurtbox_enabled(self, false)
	await frames(30)
	var room := world.current_room
	var boss = room.get_node("Enemies/TheUnlit1")
	var parent: Node = boss.get_parent()
	boss.phase = 3
	boss._enter_phase(3)
	boss._intro_left = 0.0
	boss._pause_left = 0.0
	boss._fight_started = true
	boss.invulnerable = false
	boss.hurtbox.enabled = true
	boss.hurtbox.invulnerable = false
	boss.hp = 1
	boss.exposed_left = 6.0
	boss.pull_damage = 0
	var lantern: Node2D = boss.lantern
	var centre: Vector2 = boss._phase_origin + boss.ARENA_CENTRE
	world.player.place_at(boss.global_position + Vector2(0, 108))
	world.player.facing = Vector2.UP
	var hazard := Node2D.new()
	parent.add_child(hazard)
	boss.add_hazard(hazard)
	await frames(5)
	Input.action_press(&"attack")
	await frames(10)
	Input.action_release(&"attack")
	check(boss.is_dying(), "physical hook starts final boss death")
	check(GameState.has_flag(&"boss_cave_10_14_defeated"), "lethal hook sets flag")
	check(boss._hazards.is_empty(), "lethal hook clears hazards")
	check(not is_instance_valid(hazard) or hazard.is_queued_for_deletion(), "hazard retired")
	check_eq(boss._wax_effect_spawned, not missing, "effect only spawns with art")
	var effect := boss.get_node_or_null("Puff") as SpriteVisual
	if not missing:
		check(effect != null, "wax effect is owned by boss during death")
		if effect != null:
			check_eq(effect.sprite_frames.get_frame_count(&"idle"), 8, "eight wax frames")
			check_eq(effect.get_index(), 0, "wax renders before lantern")
	else:
		check(effect == null, "missing art does not create wax")
	var trigger = room.get_node("Props/EndingTrigger1")
	check(not trigger.is_available(), "choice remains gated during death")
	await seconds(1.0)
	check(is_instance_valid(boss) and boss.is_dying(), "boss remains during two second fade")
	if effect != null and is_instance_valid(effect):
		check(effect.frame > 0, "wax animation advances")
	await seconds(0.85)
	if not missing:
		check(not is_instance_valid(effect) or effect.modulate.a < 0.2, "wax fades before choices")
	var saw_explosion := false
	var saw_placeholder := false
	for i in 20:
		await frames(1)
		for node in parent.get_children():
			if node is SpriteVisual and node.kind == &"explosion":
				saw_explosion = true
			if node is Placeholder and node.name == &"Puff":
				saw_placeholder = true
	check_eq(saw_explosion, missing and scenario != "missing_both", "invalid wax retains explosion fallback: " + scenario)
	check_eq(saw_placeholder, scenario == "missing_both", "missing wax and explosion uses Placeholder")
	check(not is_instance_valid(boss), "boss retires after two seconds")
	check(is_instance_valid(lantern), "lantern survives boss")
	if is_instance_valid(lantern):
		check_eq(lantern.get_parent(), parent, "lantern is reparented to arena")
		check_near(lantern.global_position.distance_to(centre), 0.0, 1.0, "lantern settles at centre")
	check(trigger.is_available(), "choice appears after fade")
	check(trigger.get_node("Visual").visible, "choice presentation is visible")
	check_eq(trigger._zones[0].global_position, centre + Vector2(-192, 0), "left choice")
	check_eq(trigger._zones[1].global_position, centre + Vector2(192, 0), "right choice")
	check(not SaveGame.enabled, "save stays disabled")
	await dispose(world)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)
