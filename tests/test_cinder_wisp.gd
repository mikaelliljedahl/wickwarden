extends TestCase
## Cinder wisp (monsters-bosses-tools 2.1) and its flame ring: drift toward Tamsin, a 0.5 s wind-up, the burst
## (radius 150, damage 2, consumes the wisp, no drop, the ring lasts 0.2 s), the ward negating it from the front,
## a kill and a moth stun during the wind-up, and fire immunity.

const WISP := "res://scenes/enemies/cinder_wisp.tscn"
const RING_SCRIPT := "res://scripts/enemies/flame_ring.gd"


func run() -> void:
	await _windup_visual_and_fallback()
	await _burst_visual_lifetime()
	await _burst_visual_fallback()
	await _stats_and_light()
	await _drifts_toward_tamsin()
	await _fire_does_nothing()
	await _burst_hurts_and_consumes_the_wisp()
	await _ward_negates_the_burst_from_the_front()
	await _ward_does_not_help_from_behind()
	await _kill_during_windup_cancels_the_burst()
	await _stun_cancels_the_windup()


func _rings() -> Array:
	return get_tree().get_nodes_in_group(&"flame_rings")


func _pickups(arena: Node) -> int:
	return arena.get_children().filter(func(n: Node) -> bool: return n is PickupBase).size()


func _stats_and_light() -> void:
	reset_state()
	var arena := make_arena()
	var wisp := make_enemy(arena, WISP, Vector2(960, 480))
	await frames(2)
	check_eq(wisp.hp, 2, "cinder wisp has 2 hp")
	check_eq(wisp.contact_damage, 1, "cinder wisp contact damage is 1")
	check_near(wisp.move_speed, 100.0, 0.01, "cinder wisp drifts at 100 px/s")
	check(wisp.get_node_or_null("Visual") != null, "cinder wisp has a Visual child")
	var light := wisp.get_node_or_null("Glow") as PointLight2D
	check(light != null, "cinder wisp lights its surroundings")
	if light != null:
		check_near(light.texture_scale, 140.0 * 2.0 / 512.0, 0.001, "the light reaches 140 px")
	check_eq(_rings().size(), 0, "no flame ring before a burst")
	await dispose(arena)


func _drifts_toward_tamsin() -> void:
	reset_state()
	var arena := make_arena()
	make_player(arena, Vector2(900, 480))
	var wisp := make_enemy(arena, WISP, Vector2(300, 480))
	await frames(2)
	var start_x := wisp.global_position.x
	await seconds(1.0)
	check(
		is_instance_valid(wisp) and wisp.global_position.x - start_x > 60.0,
		"the wisp drifts toward Tamsin"
	)
	await dispose(arena)


func _fire_does_nothing() -> void:
	reset_state()
	var arena := make_arena()
	var wisp := make_enemy(arena, WISP, Vector2(400, 300))
	await frames(2)
	var fire := make_hitbox(arena, wisp.global_position, Layers.Team.PLAYER, 1)
	fire.kind = &"fire"
	await frames(3)
	check_eq(wisp.hp, 2, "fire does nothing to a cinder wisp (immune)")
	await dispose(fire)
	var slug := make_hitbox(arena, wisp.global_position, Layers.Team.PLAYER, 1)
	slug.kind = &"sling"
	await frames(3)
	check_eq(wisp.hp, 1, "a sling slug still hurts it")
	await dispose(arena)


func _burst_hurts_and_consumes_the_wisp() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(400, 300))
	var wisp := make_enemy(arena, WISP, Vector2(540, 300))
	wisp.drop_roll_override = 0.3
	await frames(2)
	var before := GameState.health
	await seconds(0.3)
	check(is_instance_valid(wisp) and not wisp.is_dead, "the wisp is still winding up at 0.3 s")
	check_eq(GameState.health, before, "no damage during the wind-up")
	await seconds(0.3)
	check(not is_instance_valid(wisp), "the wisp is consumed by the burst")
	check_eq(GameState.health, before - 2, "the burst deals 2 half-hearts")
	check_eq(_pickups(arena), 0, "a burst drops nothing")
	check_eq(_rings().size(), 1, "the flame ring is out for its 0.2 s")
	await seconds(0.3)
	check_eq(_rings().size(), 0, "the flame ring is gone after 0.2 s")
	check(is_instance_valid(player), "Tamsin stays in the room")
	await dispose(arena)


func _ward_negates_the_burst_from_the_front() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(400, 300))
	player.facing = Vector2.LEFT
	var wisp := make_enemy(arena, WISP, Vector2(260, 300))
	await frames(2)
	Input.action_press(&"ward")
	await frames(2)
	check(player.ward_up, "the ward is up")
	var before := GameState.health
	await seconds(0.9)
	check(not is_instance_valid(wisp), "the wisp bursts anyway, the ward does not stop it")
	check_eq(GameState.health, before, "the ward negates the burst from the front")
	release_inputs()
	await dispose(arena)


func _ward_does_not_help_from_behind() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(400, 300))
	player.facing = Vector2.RIGHT
	make_enemy(arena, WISP, Vector2(260, 300))
	await frames(2)
	Input.action_press(&"ward")
	await frames(2)
	var before := GameState.health
	await seconds(0.9)
	check_eq(GameState.health, before - 2, "a burst from behind the ward still hurts")
	release_inputs()
	await dispose(arena)


func _kill_during_windup_cancels_the_burst() -> void:
	reset_state()
	var arena := make_arena()
	make_player(arena, Vector2(400, 300))
	var wisp := make_enemy(arena, WISP, Vector2(540, 300))
	wisp.drop_roll_override = 0.3
	await frames(2)
	var before := GameState.health
	await seconds(0.2)
	wisp.apply_damage(2, wisp.global_position + Vector2(-30, 0))
	await frames(2)
	check(not is_instance_valid(wisp), "the wisp dies to two hits in the wind-up")
	check_eq(_pickups(arena), 1, "a kill during the wind-up drops normally")
	await seconds(0.8)
	check_eq(GameState.health, before, "no burst after a kill")
	check_eq(_rings().size(), 0, "no flame ring after a kill")
	await dispose(arena)


func _stun_cancels_the_windup() -> void:
	reset_state()
	var arena := make_arena()
	make_player(arena, Vector2(400, 300))
	var wisp := make_enemy(arena, WISP, Vector2(540, 300))
	await frames(2)
	var before := GameState.health
	await seconds(0.2)
	wisp.stun(1.5)
	await seconds(0.6)
	check(
		is_instance_valid(wisp) and not wisp.is_dead,
		"a stun cancels the wind-up: no burst at 0.8 s"
	)
	check_eq(GameState.health, before, "no damage during the stun")
	await seconds(1.8)
	check(not is_instance_valid(wisp), "after the stun the wisp winds up again and bursts")
	check_eq(GameState.health, before - 2, "the second burst deals 2 half-hearts")
	await dispose(arena)


func _windup_visual_and_fallback() -> void:
	for missing_art in [false, true]:
		reset_state()
		if missing_art:
			SpriteVisual.use_manifest("res://tests/fixtures/no_item_art.json")
		var arena := make_arena()
		make_player(arena, Vector2(400, 300))
		var wisp := make_enemy(arena, WISP, Vector2(540, 300))
		await frames(3)
		var warning := wisp.get_node_or_null("WindupVisual")
		check(warning != null, "wind-up shows the boundary with or without art")
		if warning != null:
			var boundary_material := warning.material as CanvasItemMaterial
			check(
				(
					boundary_material != null
					and boundary_material.light_mode == CanvasItemMaterial.LIGHT_MODE_UNSHADED
				),
				"warning boundary is visible independently of lighting"
			)
			check_eq(
				warning.get_node_or_null("Visual") is SpriteVisual,
				not missing_art,
				"painted warning only when art is available"
			)
		check(
			wisp._telegraph != null and not wisp._telegraph.visible,
			"shared timer runs without its filled disc"
		)
		await seconds(0.2)
		check(is_instance_valid(wisp) and _rings().is_empty(), "warning is not a damaging burst")
		wisp.stun(1.5)
		await frames(2)
		check(wisp.get_node_or_null("WindupVisual") == null, "stun removes the warning")
		await dispose(arena)
		SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)


func _burst_visual_lifetime() -> void:
	reset_state()
	var arena := make_arena()
	var ring := (load(RING_SCRIPT) as Script).new() as Hitbox
	arena.add_child(ring)
	ring.global_position = Vector2(420, 310)
	await frames(2)
	check_eq(ring.damage, 2, "painted burst retains damage")
	check(ring.blockable and not ring.block_destroys_carrier, "ward behavior stays unchanged")
	var shape: CollisionShape2D
	for child in ring.get_children():
		if child is CollisionShape2D:
			shape = child
	check(shape != null and shape.shape is CircleShape2D, "burst has circular collision")
	if shape != null and shape.shape is CircleShape2D:
		check_near((shape.shape as CircleShape2D).radius, 150.0, 0.01, "burst radius stays 150")
	var ring_art := ring.get_node_or_null("Visual") as SpriteVisual
	check(ring_art != null, "active radius uses painted fire")
	if ring_art != null:
		check_eq(ring_art.frame, 3, "complete fire ring is held for the hitbox")
		check(not ring_art.is_playing(), "the ring does not shrink during the attack")
	check(ring.get_node_or_null("Boundary") != null, "painted fire has a radius boundary")
	var art := arena.get_node_or_null("Puff") as SpriteVisual
	check(art != null, "painted burst is separate")
	if art != null:
		check_eq(
			art.global_position, ring.global_position, "art follows the assigned burst position"
		)
	await seconds(0.25)
	check(not is_instance_valid(ring), "hitbox expires after 0.2 seconds")
	check(arena.get_node_or_null("Puff") is SpriteVisual, "animation outlives hitbox")
	await seconds(0.3)
	check(arena.get_node_or_null("Puff") == null, "painted burst cleans itself up")
	await dispose(arena)


func _burst_visual_fallback() -> void:
	reset_state()
	SpriteVisual.use_manifest("res://tests/fixtures/no_item_art.json")
	var arena := make_arena()
	var ring := (load(RING_SCRIPT) as Script).new() as Hitbox
	arena.add_child(ring)
	await frames(2)
	var fallback := ring.get_node_or_null("Visual") as Placeholder
	check(fallback != null and fallback.kind == &"flame_ring", "missing art uses ring fallback")
	check(ring.active and ring.blockable, "missing art preserves active wardable hitbox")
	await seconds(0.25)
	check(not is_instance_valid(ring), "fallback disappears with the hitbox")
	await dispose(arena)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)
