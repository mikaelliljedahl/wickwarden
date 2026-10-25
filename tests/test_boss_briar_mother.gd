## timeout=180
extends TestCase

const BOSS := "res://scenes/enemies/bosses/briar_mother.tscn"
const ARENA := "res://scenes/bosses/briar_mother_arena.tscn"


func run() -> void:
	await _intro_and_cycle()
	await _spore_warning_and_ward()
	await _real_cinder_and_hook()
	await _real_sling_fight()
	await _seeds_and_sweep()
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
	await seconds(0.6)
	check_eq(_areas(arena).size(), 0, "sweep warning is harmless for 0.7 s")
	await seconds(0.15)
	check_eq(_areas(arena).size(), 3, "sweep activates three horizontal bands")
	for area in _areas(arena):
		check(not area.box.blockable, "ward cannot block thorn sweep")
		check_eq(area.box.damage, 2, "sweep damage is two half-hearts")
	await seconds(0.3)
	check_eq(_areas(arena).size(), 0, "sweep bands end after 0.3 s")
	await dispose(arena)


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
		var fragment := arena.get_node("Fragment") as PickupBase
		check(not fragment.visible, "placed fragment is gated by defeat flag")
		GameState.set_flag(&"boss_cave_2_9_defeated")
		check(fragment.visible, "defeat reveals placed fragment")
		check_eq(fragment.scope, &"c2", "fragment has cave two scope")
		check_near(fragment.timeout, 0, 0.001, "placed fragment never times out")
		check_eq(
			(arena.get_node("WickCore") as PickupBase).persistent_id,
			&"wick_core_c2",
			"core has cave-two persistence"
		)
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
