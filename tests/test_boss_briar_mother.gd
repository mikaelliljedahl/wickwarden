## timeout=180
extends TestCase

const BOSS := "res://scenes/enemies/bosses/briar_mother.tscn"
const ARENA := "res://scenes/bosses/briar_mother_arena.tscn"


func run() -> void:
	await _intro_and_cycle()
	await _eye_presentation()
	await _spore_warning_and_ward()
	await _freed_eye_during_warning()
	await _real_cinder_and_hook()
	await _real_sling_fight()
	await _seeds_and_sweep()
	await _band_cleanup_and_fallback()
	await _seed_burst_presentation()
	await _resupply_and_reset()
	await _scenes()


func _boss(arena: Node2D, intro: float = 0.0) -> EnemyBase:
	var scene := load(BOSS) as PackedScene
	check(scene != null, "B02 scene loads")
	if scene == null:
		return null
	var boss := scene.instantiate() as EnemyBase
	boss.set(&"intro_time", intro)
	boss.position = Vector2(960, 192)
	arena.add_child(boss)
	return boss


func _intro_and_cycle() -> void:
	reset_state()
	var arena := make_arena()
	var boss = _boss(arena, 1.5)
	await seconds(0.5)
	check(boss.is_in_intro(), "intro lasts 1.5 s")
	check_eq(boss.parts().size(), 3, "three eyes during intro")
	for eye in boss.parts():
		check(eye.invulnerable, "intro eyes cannot be hurt")
	check_eq(_shots(arena).size(), 0, "intro has no projectiles")
	await seconds(1.1)
	check(not boss.is_in_intro(), "intro completes")
	var eyes: Array = boss.eyes
	var start: Vector2 = eyes[0].global_position
	await seconds(1.0)
	check(absf(eyes[0].global_position.x - start.x) > 50, "eyes sway sideways")
	for i in range(540):
		await frames(1)
		var lowered := 0
		for eye in eyes:
			if eye.hurtbox.enabled:
				lowered += 1
		check(lowered >= 1, "offset eye cycles always leave a target")
		check_near(eyes[0].global_position.y, 480.0, 0.1, "eye 1 retains its row")
	check_near(boss.spore_interval(), 2.0, 0.001, "initial spore cadence")
	check_near(boss.seed_interval(), 4.0, 0.001, "initial seed cadence")
	await dispose(arena)


func _eye_presentation() -> void:
	reset_state()
	var arena := make_arena()
	var boss = _boss(arena)
	await frames(4)
	var eyes: Array = boss.eyes.duplicate()
	for eye in eyes:
		var light := eye.get_node_or_null("EyeLight") as PointLight2D
		check(light != null, "each eye owns its presentation light")
		if light != null:
			check(not light.is_in_group(&"glow_light"), "eye light is not gameplay glow")
			check_eq(light.is_visible_in_tree(), eye.visible, "light follows eye visibility")
	await seconds(3.2)
	var raised: EnemyBase = eyes[1]
	var raised_light := raised.get_node("EyeLight") as PointLight2D
	check(not raised.visible and not raised_light.is_visible_in_tree(), "raised eye casts no light")
	var lowered: EnemyBase = eyes[0]
	var dead_light := lowered.get_node("EyeLight") as PointLight2D
	check(lowered.visible and dead_light.is_visible_in_tree(), "lowered eye remains lit")
	lowered.apply_damage(4, lowered.global_position, 0)
	await frames(3)
	check(not is_instance_valid(dead_light), "defeated eye removes its light")
	boss.reset_fight()
	await frames(4)
	check_eq(boss.parts().size(), 3, "reset recreates the three eyes")
	for eye in boss.parts():
		check(eye.get_node_or_null("EyeLight") != null, "reset eye has its own light")
	await dispose(arena)


func _spore_warning_and_ward() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(480, 760))
	var boss = _boss(arena)
	await frames(4)
	# Isolate one naturally fired spore without changing its warning, speed or damage.
	boss._shot_left = [100.0, 100.0, 100.0] as Array[float]
	var eye: EnemyBase = boss.eyes[0]
	boss._warn_spore(eye)
	await seconds(0.4)
	check_eq(_shots(arena).size(), 0, "spore warning lasts the ruled 0.5 seconds")
	await seconds(0.15)
	var shots := _shots(arena)
	check_eq(shots.size(), 1, "warning releases a spore after half a second")
	if not shots.is_empty():
		var shot := shots[0]
		check_near(shot.speed, 300, 0.001, "spore speed is 300 px/s")
		check_eq(shot.damage, 2, "spore damage is two half-hearts")
		player.place_at(shot.global_position + shot.direction * 100)
		player.facing = -shot.direction
		Input.action_press(&"ward")
		var health := GameState.health
		await seconds(0.5)
		Input.action_release(&"ward")
		check_eq(GameState.health, health, "real ward blocks spore damage")
		check(not is_instance_valid(shot), "ward destroys the actual spore")
	var target: EnemyBase = boss.eyes[1]
	target.invulnerable = false
	target.apply_damage(4, target.global_position, 0)
	check_near(boss.spore_interval(), 1.6, 0.001, "one dead eye speeds shots by 0.4")
	check_near(boss.seed_interval(), 3.5, 0.001, "one dead eye speeds seeds by 0.5")
	target = boss.eyes[2]
	target.invulnerable = false
	target.apply_damage(4, target.global_position, 0)
	check_near(boss.spore_interval(), 1.2, 0.001, "two dead eyes speed shots by 0.8")
	check_near(boss.seed_interval(), 3.0, 0.001, "two dead eyes speed seeds by 1.0")
	await dispose(arena)


func _freed_eye_during_warning() -> void:
	reset_state()
	var arena := make_arena()
	make_player(arena, Vector2(192, 800))
	var boss = _boss(arena)
	await seconds(1.3)
	# Queue a real seed warning first, so a later stale spore entry must not starve it.
	boss.warn_seed()
	var eye: EnemyBase = null
	for tick in range(30):
		await frames(1)
		for entry: Dictionary in boss._pending:
			if entry.kind == &"spore":
				eye = entry.eye
		if eye != null:
			break
	check(eye != null, "an eye naturally begins a spore warning")
	if eye != null:
		var hit := make_hitbox(arena, eye.global_position, Layers.Team.PLAYER, 4, 40)
		hit.kind = &"sling"
		await frames(3)
		check(not is_instance_valid(eye), "sling destroys the warned eye before the shot")
		await dispose(hit)
	await seconds(1.0)
	check_eq(boss.seeds.size(), 1, "earlier pending seed still lands after the eye is freed")
	var stale := 0
	for entry: Dictionary in boss._pending:
		if entry.kind == &"spore" and not is_instance_valid(entry.eye):
			stale += 1
	check_eq(stale, 0, "removed eye leaves no stale spore warning")
	await dispose(arena)


func _real_cinder_and_hook() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(960, 480))
	GameState.acquire_item(&"cinder_wick")
	GameState.set_active_item(&"cinder_wick")
	var boss = _boss(arena)
	await frames(4)
	for eye in boss.parts():
		eye.invulnerable = false
		eye.apply_damage(4, eye.global_position, 0)
	await seconds(1.3)
	player.facing = Vector2.UP
	check(player.use_item(), "real cinder wick launches toward bloom")
	await seconds(0.4)
	check_eq(boss.hp, 14, "first actual cinder tick deals two damage")
	await seconds(0.5)
	check_eq(boss.hp, 12, "next actual tick is also two, half a second later")
	# Let the real flame finish; finish any surviving bloom with actual player hook swings.
	await seconds(3.0)
	var swings := 0
	while is_instance_valid(boss) and not boss.is_dying() and swings < 8:
		player.place_at(boss.global_position + Vector2(0, 110))
		player.facing = Vector2.UP
		Input.action_press(&"attack")
		await frames(5)
		Input.action_release(&"attack")
		await seconds(0.4)
		swings += 1
	check(boss.is_dying(), "actual cinder and hook can finish the bloom")
	await dispose(arena)


func _real_sling_fight() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(192, 480))
	GameState.acquire_item(&"tallow_sling")
	GameState.acquire_item(&"pitch_pot")
	GameState.set_active_item(&"tallow_sling")
	GameState.health = GameState.max_health
	var boss = _boss(arena)
	await frames(4)
	# Other weapons pass over the eyes without spending their HP.
	var eye: EnemyBase = boss.eyes[0]
	for kind in [&"hook", &"flare", &"explosion", &"fire", &"thrown", &"reel"]:
		var hit := make_hitbox(arena, eye.global_position, Layers.Team.PLAYER, 4, 40)
		hit.kind = kind
		await frames(2)
		check_eq(eye.hp, 4, "eye rejects %s" % kind)
		await dispose(hit)
	var canopy := make_hitbox(arena, boss.global_position, Layers.Team.PLAYER, 99, 90)
	canopy.kind = &"flare"
	await frames(2)
	check_eq(boss.hp, 28, "canopy cannot skip the eyes")
	await dispose(canopy)
	var hits := 0
	while boss.phase == 1 and hits < 12:
		var target: EnemyBase = null
		for candidate in boss.parts():
			if candidate.hurtbox.enabled and not candidate.invulnerable:
				target = candidate
				break
		if target == null:
			await frames(1)
			continue
		# Fire from below at short range; tracking the target once is enough at this flight time.
		player.place_at(target.global_position + Vector2(0, 110))
		player.facing = Vector2.UP
		player.set_hurtbox_enabled(self, false)
		var hp_before := target.hp
		var ammo_before := GameState.slugs
		check(player.use_item(), "real sling fires at a lowered eye")
		check_eq(GameState.slugs, ammo_before - 1, "real shot spends exactly one slug")
		check(not player.use_item(), "one slug on screen refuses a second use")
		await seconds(0.3)
		if is_instance_valid(target):
			check_eq(target.hp, hp_before - 1, "real slug deals exactly one half-heart")
		hits += 1
	check_eq(hits, 12, "three four-HP eyes require twelve real slugs")
	check_eq(GameState.slugs, 0, "starting ammunition spent on the eyes")
	check_eq(boss.phase, 2, "last eye opens bloom phase")
	check_eq(boss.hp, 16, "bloom has sixteen HP")
	check(boss.is_pausing(), "phase change protects bloom for 1.2 s")
	check_near(boss.global_position.y, 288.0, 0.01, "bloom lowers to y288")
	await seconds(1.3)
	player.place_at(Vector2(192, 480))
	var flame := make_hitbox(arena, boss.global_position, Layers.Team.PLAYER, 1, 90)
	flame.kind = &"fire"
	await frames(2)
	check_eq(boss.hp, 14, "fire tick doubles to two damage on bloom")
	await dispose(flame)
	await seconds(0.3)
	for kind in [&"hook", &"flare", &"explosion", &"sling", &"thrown", &"reel"]:
		var before: int = boss.hp
		var hit := make_hitbox(arena, boss.global_position, Layers.Team.PLAYER, 1, 90)
		hit.kind = kind
		await frames(2)
		check_eq(boss.hp, before - 1, "bloom accepts %s" % kind)
		await dispose(hit)
		await seconds(0.3)
	var finish := make_hitbox(arena, boss.global_position, Layers.Team.PLAYER, 8, 90)
	finish.kind = &"hook"
	await frames(2)
	check(boss.is_dying(), "lethal bloom hit starts death throes")
	check(GameState.has_flag(&"boss_cave_2_9_defeated"), "B02 sets exact persistent flag")
	await dispose(finish)
	await seconds(1.6)
	check(not is_instance_valid(boss), "death ends after 1.5 s")
	check_eq(_pickups(arena, &"ember").size(), 2, "death creates two timed embers")
	var retired = _boss(arena)
	await frames(2)
	check(retired.is_dead and not retired.visible, "defeated Mother stays dead on reentry")
	await dispose(arena)


func _seeds_and_sweep() -> void:
	reset_state()
	var arena := make_arena()
	var boss = _boss(arena)
	await frames(4)
	boss.warn_seed()
	check_eq(boss.seeds.size(), 0, "seed warning does not land immediately")
	await seconds(0.7)
	check_eq(boss.seeds.size(), 0, "seed warning lasts 0.8 s")
	await seconds(0.15)
	check_eq(boss.seeds.size(), 1, "warning lands a seed")
	var seed: EnemyBase = boss.seeds[0]
	check_eq(seed.hp, 1, "seed HP is one")
	var hit := make_hitbox(arena, seed.global_position, Layers.Team.PLAYER, 2, 40)
	hit.kind = &"hook"
	await frames(2)
	check(not is_instance_valid(seed) or seed.is_dead, "hook destroys seed")
	await dispose(hit)
	await seconds(3.1)
	# Remove the scheduled seeds to isolate a full germination and the three-snapper cap.
	boss.clear_hazards()
	boss.seeds.clear()
	await frames(2)
	for i in range(4):
		boss.plant_seed(Vector2(400 + i * 200, 700))
	await seconds(2.8)
	check_eq(boss.snappers.size(), 0, "seeds wait three seconds before bursting")
	await seconds(0.3)
	check_eq(boss.snappers.size(), 3, "at most three real bramble snappers spawn")
	for snapper in boss.snappers:
		check_eq(
			snapper.get_script().resource_path,
			"res://scripts/enemies/bramble_snapper.gd",
			"seed uses real M1 monster"
		)
		check(not snapper.drops_enabled, "summoned snappers cannot farm ammo")
	# A phase change clears every attack and pending seed; sweep starts after the pause.
	for eye in boss.parts():
		eye.invulnerable = false
		eye.apply_damage(eye.hp, eye.global_position, 0)
	await frames(3)
	check_eq(boss.phase, 2, "eyes transition the fight")
	check_eq(boss.snappers.size(), 0, "phase change clears snapper tracking")
	check_eq(_shots(arena).size(), 0, "phase change clears spores")
	await seconds(1.3)
	boss._warn_sweep()
	var warnings: Array[Node2D] = []
	for child in arena.get_children():
		if child.get_script() != null and child.get_script().resource_path == "res://scripts/enemies/telegraph.gd":
			if child.shape == &"rect":
				warnings.append(child)
	check_eq(warnings.size(), 3, "sweep warns all three bands")
	for warning in warnings:
		check_eq(warning.size, Vector2(1920, 96), "warning matches the full sweep band")
		check(_has_sweep_lights(warning), "warning lights the full band without gameplay glow")
	await seconds(0.6)
	check_eq(_areas(arena).size(), 0, "sweep warning is harmless for 0.7 s")
	await seconds(0.15)
	check_eq(_areas(arena).size(), 3, "sweep activates three horizontal bands")
	var band_art: Array[Node2D] = []
	for child in arena.get_children():
		var picture := child.get_node_or_null("Visual") as SpriteVisual
		if picture != null and picture.kind == &"briar_band_full_candidate":
			band_art.append(child)
	check_eq(band_art.size(), 3, "each sweep has one full-width painted strip")
	for holder in band_art:
		var art := holder.get_node_or_null("Visual") as SpriteVisual
		check(art != null and art.kind == &"briar_band_full_candidate", "band uses the cut art")
		if art != null:
			check_eq(art.sprite_frames.get_frame_texture(&"idle", 0).get_size(), Vector2(1920, 96), "one full-width cell")
	for area in _areas(arena):
		check(not area.box.blockable, "ward cannot block thorn sweep")
		check_eq(area.box.damage, 2, "sweep damage is two half-hearts")
		check_eq(area.box.get_child(0).shape.size, Vector2(1920, 96), "sweep hitbox is unchanged")
		check(_has_sweep_lights(area), "active sweep remains lit without gameplay glow")
	await seconds(0.3)
	check_eq(_areas(arena).size(), 0, "sweep bands end after 0.3 s")
	for holder in band_art:
		check(not is_instance_valid(holder), "painted band ends with the damaging area")
	for warning in warnings:
		check(not is_instance_valid(warning), "warning and its lights are removed after the tell")
	await dispose(arena)


func _band_cleanup_and_fallback() -> void:
	reset_state()
	var arena := make_arena()
	var boss = _boss(arena)
	await frames(4)
	boss._area(Vector2(960, 480), true)
	var holders := _band_holders(arena)
	check_eq(holders.size(), 1, "active sweep owns a painted holder")
	boss.reset_fight()
	await frames(3)
	check(not is_instance_valid(holders[0]), "reset removes the painted holder")
	check(_areas(arena).is_empty(), "reset removes the sweep hitbox")
	boss._area(Vector2(960, 480), true)
	holders = _band_holders(arena)
	check_eq(holders.size(), 1, "phase test starts with a painted holder")
	boss._start_phase(2)
	await frames(3)
	check(not is_instance_valid(holders[0]), "phase change removes the painted holder")
	check(_areas(arena).is_empty(), "phase change removes the sweep hitbox")
	await dispose(arena)

	SpriteVisual.use_manifest("res://tests/fixtures/no_item_art.json")
	arena = make_arena()
	boss = _boss(arena)
	await frames(4)
	boss._area(Vector2(960, 480), true)
	var areas := _areas(arena)
	check_eq(areas.size(), 1, "missing band art retains the attack")
	if not areas.is_empty():
		check(areas[0].get_node_or_null("Visual") is Placeholder, "missing art keeps fallback")
		check(_has_sweep_lights(areas[0]), "missing art keeps the full-band light")
		check_eq(areas[0].box.get_child(0).shape.size, Vector2(1920, 96), "fallback hitbox unchanged")
	check(_band_holders(arena).is_empty(), "missing art creates no painted holder")
	await seconds(0.4)
	check(_areas(arena).is_empty(), "fallback attack ends normally")
	await dispose(arena)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)

	reset_state()
	SaveGame.enabled = false
	var world := (load("res://scenes/world/world.tscn") as PackedScene).instantiate() as World
	add_child(world)
	await frames(3)
	world.start_at(&"cave_2_9")
	var room := world.current_room
	var mother = room.get_node("Enemies/BriarMother1")
	mother._area(room.global_position + Vector2(960, 480), true)
	holders = _band_holders(room)
	check_eq(holders.size(), 1, "real room owns the band presentation")
	world.start_at(&"cave_2_8")
	await frames(4)
	check(not is_instance_valid(holders[0]), "leaving the room removes the band presentation")
	await dispose(world)


func _band_holders(parent: Node) -> Array[Node2D]:
	var holders: Array[Node2D] = []
	for child in parent.get_children():
		var picture := child.get_node_or_null("Visual") as SpriteVisual
		if picture != null and picture.kind == &"briar_band_full_candidate":
			holders.append(child)
	return holders


func _seed_burst_presentation() -> void:
	reset_state()
	var arena := make_arena()
	make_player(arena, Vector2(600, 500))
	var boss = _boss(arena)
	await frames(4)
	boss._shot_left = [100.0, 100.0, 100.0] as Array[float]
	boss._seed_left = 100.0
	var seed: EnemyBase = boss.plant_seed(Vector2(500, 500))
	var health := GameState.health
	await seconds(2.9)
	check(is_instance_valid(seed) and _areas(arena).is_empty(), "seed waits three seconds to burst")
	await seconds(0.15)
	var areas := _areas(arena)
	check_eq(areas.size(), 1, "natural seed burst creates one damaging area")
	if not areas.is_empty():
		var area: Node2D = areas[0]
		check(area.box.active and not area.box.blockable, "burst stays active and unblockable")
		check_eq(area.box.damage, 2, "burst still deals two half-hearts")
		check_eq(area.box.get_child(0).shape.radius, 120.0, "burst radius remains 120 pixels")
	check_eq(GameState.health, health - 2, "real player inside burst radius takes damage")
	check_eq(boss.snappers.size(), 1, "natural burst still spawns a snapper")
	var holder := arena.get_node_or_null("SeedBurstEffect") as Node2D
	check(holder != null, "burst has a separate visual effect")
	if holder != null:
		var visual := holder.get_node_or_null("Visual") as SpriteVisual
		check(visual != null and visual.animation == &"burst", "painted seed burst plays")
		var light := holder.get_node_or_null("BurstLight") as PointLight2D
		check(light != null and not light.is_in_group(&"glow_light"), "burst light is presentation only")
	await seconds(0.3)
	check(_areas(arena).is_empty(), "burst hitbox and radius cue end after 0.3 seconds")
	check(is_instance_valid(holder), "painted animation finishes independently of damage")
	await seconds(0.3)
	check(not is_instance_valid(holder), "painted effect and light are cleaned up")
	await dispose(arena)
	SpriteVisual.use_manifest("res://tests/fixtures/no_item_art.json")
	arena = make_arena()
	boss = _boss(arena)
	await frames(4)
	boss.burst_seed(Vector2(500, 500))
	areas = _areas(arena)
	check_eq(areas.size(), 1, "missing art retains the burst hitbox")
	if not areas.is_empty():
		check(areas[0].get_node_or_null("Visual") is Placeholder, "missing art retains fallback cue")
	await seconds(0.4)
	check(arena.get_node_or_null("SeedBurstEffect") == null, "fallback light is cleaned up")
	await dispose(arena)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)


func _resupply_and_reset() -> void:
	reset_state()
	GameState.acquire_item(&"tallow_sling")
	GameState.acquire_item(&"pitch_pot")
	GameState.add_slugs(-12)
	var arena := make_arena()
	var player := make_player(arena, Vector2(192, 480))
	var boss = _boss(arena)
	await frames(4)
	check_eq(_pickups(arena, &"slug_bundle").size(), 1, "empty ammo gets phase-start resupply")
	check_eq(_pickups(arena, &"pitch_pot_bundle").size(), 1, "low pots get phase-start resupply")
	GameState.set_active_item(&"tallow_sling")
	check(not player.use_item(), "real sling refuses empty ammo")
	var bundle := _pickups(arena, &"slug_bundle")[0]
	check_near(bundle.timeout, 8.0, 0.001, "resupply expires in eight seconds")
	check(bundle.collect(player), "real pickup resupplies ammunition")
	check_eq(GameState.slugs, 6, "bundle adds six real slugs")
	check(player.use_item(), "real sling works after collecting resupply")
	await seconds(1.3)
	boss._resupply_left = 0.01
	await frames(3)
	check_eq(_pickups(arena, &"slug_bundle").size(), 1, "periodic resupply repeats below eight")
	check_near(boss._resupply_left, 30.0, 0.1, "periodic supply resets to thirty seconds")
	for eye in boss.parts():
		eye.invulnerable = false
		eye.apply_damage(eye.hp, eye.global_position, 0)
	await frames(3)
	check_eq(_pickups(arena, &"slug_bundle").size(), 2, "phase two resupplies again")
	Events.player_died.emit()
	await frames(4)
	check_eq(boss.phase, 1, "death resets phase one")
	check_eq(boss.hp, 28, "reset restores all eye and bloom HP")
	check_eq(boss.parts().size(), 3, "reset restores three eyes")
	check_eq(boss.dead_eyes, 0, "reset clears dead eye acceleration")
	check_eq(boss._pending.size(), 0, "reset clears delayed attacks")
	await dispose(arena)


func _scenes() -> void:
	reset_state()
	var scene := load(ARENA) as PackedScene
	check(scene != null, "arena fragment loads")
	if scene != null:
		var arena := scene.instantiate()
		add_child(arena)
		await frames(2)
		check_eq(_rewards(arena).size(), 0, "arena leaves persistent rewards to the cave room")
		GameState.set_flag(&"boss_cave_2_9_defeated")
		await frames(2)
		check_eq(_rewards(arena).size(), 0, "defeat cannot create duplicate arena rewards")
		check_eq(arena.get_node("Mother").position, Vector2(960, 192), "Mother marker stays")
		for index in range(1, 4):
			check(arena.get_node("Eye%d" % index) is Marker2D, "eye marker stays")
		await dispose(arena)
	reset_state()
	var gallery := load("res://tests/fixtures/gallery/B02.tscn") as PackedScene
	check(gallery != null, "gallery loads")
	if gallery != null:
		var room := gallery.instantiate() as Room
		add_child(room)
		room.enter()
		await frames(3)
		check(room.get_node_or_null("Props/Arena") != null, "gallery instances arena fragment")
		check_eq(room.get_enemies().size(), 4, "live room has one Mother and exactly three eyes")
		room.leave()
		room.enter()
		await frames(4)
		check_eq(room.get_enemies().size(), 4, "reentry has no orphan template eyes")
		var mother = room.get_node("Enemies/BriarMother")
		for eye in mother.parts():
			eye.invulnerable = false
			eye.apply_damage(4, eye.global_position, 0)
		await frames(3)
		check_eq(room.get_enemies().size(), 1, "bloom phase leaves no template eyes behind")
		await dispose(room)


func _has_sweep_lights(parent: Node2D) -> bool:
	var light := parent.get_node_or_null("SweepLight") as PointLight2D
	if light == null or light.is_in_group(&"glow_light") or not light.enabled:
		return false
	return light.position == Vector2.ZERO and light.texture.get_size() == Vector2(1920, 96)


func _pickups(arena: Node, kind: StringName) -> Array[PickupBase]:
	var result: Array[PickupBase] = []
	for node in arena.get_children():
		if node is PickupBase and node.kind == kind and not node.is_queued_for_deletion():
			result.append(node)
	return result


func _shots(arena: Node) -> Array[EnemyProjectile]:
	var result: Array[EnemyProjectile] = []
	for node in arena.get_children():
		if node is EnemyProjectile:
			result.append(node)
	return result


func _areas(arena: Node) -> Array:
	var result: Array = []
	for node in arena.get_children():
		if node.get("box") is Hitbox:
			result.append(node)
	return result


func _rewards(node: Node) -> Array[PickupBase]:
	var result: Array[PickupBase] = []
	if node is PickupBase and node.persistent_id != &"":
		result.append(node)
	for child in node.get_children():
		result.append_array(_rewards(child))
	return result
