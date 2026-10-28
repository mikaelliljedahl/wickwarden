extends TestCase
## Attack timings and real player hook/moth/mitts against smash-created slag.

const SCENE := "res://scenes/enemies/minibosses/lull_mauler.tscn"


func run() -> void:
	await _attacks()
	await _real_attack_geometry()
	await _real_deflect(false)
	await _real_deflect(true)
	await _real_moth_and_hooks()
	await _attack_interruptions()
	await _lifecycle()


func _wait_state(enemy: EnemyBase, target: int, limit: int = 240) -> int:
	for i in range(limit):
		if enemy.state == target:
			return i
		await frames(1)
	check(false, "bounded wait reaches mauler state %s" % target)
	return limit


func _chunks(arena: Node) -> Array[Node]:
	return arena.get_children().filter(func(n: Node) -> bool: return n.is_in_group(&"liftable"))


func _attacks() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(800, 480))
	var player := make_player(arena, Vector2(1300, 480))
	await frames(2)
	check_eq(enemy.hp, 24, "mauler HP24")
	check_eq(enemy.contact_damage, 3, "contact3")
	check_near(enemy.velocity.length(), 70, .1, "walk70")
	check_eq(enemy.knockback_scale, .5, "half hook knockback")
	check(enemy.has_node("Visual"), "Visual exists")
	await _wait_state(enemy, enemy.State.SMASH_WARNING)
	var start: Vector2 = enemy.global_position
	var impact: Vector2 = enemy._impact
	check_near(impact.distance_to(start), 96, .1, "smash marks96 ahead")
	await _capture("mauler-smash-warning")
	var elapsed := await _wait_state(enemy, enemy.State.RECOVER)
	check_near(elapsed, 54, 2, "smash warning .9s")
	check_eq(enemy._attack.damage, 4, "smash damage4")
	check(not enemy._attack.blockable, "slam not ward blockable")
	var chunks := _chunks(arena)
	check_eq(chunks.size(), 1, "smash creates exactly one slag obstacle")
	if chunks.size() == 1:
		check_eq(chunks[0].global_position, impact, "slag remains at marked spot")
		check_eq(chunks[0]._shape.shape.size, Vector2(96, 96), "slag is one tile obstacle")
	await _capture("mauler-slag")
	elapsed = await _wait_state(enemy, enemy.State.WALK)
	check_near(elapsed, 72, 2, "smash recovery1.2s")
	await _wait_state(enemy, enemy.State.SWEEP_WARNING)
	await _capture("mauler-sweep-warning")
	elapsed = await _wait_state(enemy, enemy.State.RECOVER)
	check_near(elapsed, 36, 2, "sweep warning .6s")
	check_eq(enemy._attack.damage, 3, "sweep damage3")
	check(not enemy._attack.blockable, "sweep not ward blockable")
	check_eq(GameState.health, 6, "distant player outside both attack geometries")
	player.queue_free()
	enemy.reset_fight()
	await frames(2)
	check_eq(_chunks(arena).size(), 0, "reset removes all slag hazards")
	check(not enemy._attack.active, "reset disables live attack")
	await dispose(arena)


func _real_attack_geometry() -> void:
	for smash in [true, false]:
		for inside in [true, false]:
			reset_state()
			var arena := make_arena()
			var enemy = make_enemy(arena, SCENE, Vector2(800, 480))
			var player := make_player(arena, Vector2(1300, 480))
			var warning: int = enemy.State.SMASH_WARNING if smash else enemy.State.SWEEP_WARNING
			await _wait_state(enemy, warning, 500)
			var target: Vector2 = (
				enemy._impact + Vector2(0, 80)
				if smash
				else (enemy.global_position + enemy._aim * (120 if inside else -120))
			)
			if smash and not inside:
				target = enemy._impact + Vector2(0, 180)
			player.place_at(target)
			player.facing = (enemy.global_position - target).normalized()
			Input.action_press(&"ward")
			await frames(10)
			check_eq(GameState.health, 6, "telegraph is harmless before real attack")
			await _wait_state(enemy, enemy.State.RECOVER)
			await frames(5)
			var damage := 4 if smash else 3
			check_eq(
				GameState.health,
				6 - damage if inside else 6,
				"actual slam/sweep geometry respects radius/arc and bypasses ward"
			)
			release_inputs()
			await dispose(arena)


func _real_deflect(mitts: bool) -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(800, 480))
	var player := make_player(arena, Vector2(1300, 480))
	await _wait_state(enemy, enemy.State.RECOVER)
	var chunks := _chunks(arena)
	check_eq(chunks.size(), 1, "real attack supplies return ammunition")
	if chunks.size() != 1:
		await dispose(arena)
		return
	var chunk = chunks[0]
	await frames(10)
	# Hold recovery for isolated flight proof; attack cadence is tested separately.
	enemy.set_physics_process(false)
	# Separate combatants to measure flight before the real hurtbox collision.
	chunk.global_position = enemy.global_position + Vector2(300, 0)
	player.place_at(chunk.global_position + Vector2(90, 0))
	player.facing = Vector2.LEFT
	await frames(3)
	if mitts:
		GameState.acquire_item(&"heft_mitts")
		GameState.set_active_item(&"heft_mitts")
		check(player.use_item(), "actual mitts grab slag")
		await frames(20)
		check(chunk.is_carried(), "P06 carried state via real grab collision")
		Input.action_press(&"use_item")
		await frames(2)
		Input.action_release(&"use_item")
	else:
		check(not GameState.has_item(&"heft_mitts"), "mandatory route has no mitts")
		Input.action_press(&"attack")
		await frames(7)
		Input.action_release(&"attack")
		check(chunk.deflected, "real hook collision deflects slag")
		check_eq(chunk._hitbox.damage, 4, "hook-deflected slag damage4")
		var from: Vector2 = chunk.global_position
		await frames(1)
		check_near(
			chunk.global_position.distance_to(from) * 60.0, 400, 1, "actual deflected flight400px/s"
		)
	await _capture("mauler-mitts" if mitts else "mauler-deflect")
	await frames(40)
	check_eq(enemy.hp, 21 if mitts else 20, "real returned slag hits once for3/4")
	check(not is_instance_valid(chunk), "returned slag shatters, no repeated hits")
	check_eq(GameState.health, 6, "return test does not damage player")
	await dispose(arena)


func _real_moth_and_hooks() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(800, 480))
	var player := make_player(arena, Vector2(550, 480))
	await frames(2)
	GameState.acquire_item(&"tether_moth")
	player.facing = Vector2.RIGHT
	check(player.use_item(), "actual moth launches at mauler")
	for i in range(40):
		await frames(1)
		if enemy.is_stunned():
			break
	check(enemy.is_stunned(), "real moth stuns mauler")
	check(enemy._stun_time <= 1.5, "moth clamp1.5")
	for i in range(3):
		player.place_at(enemy.global_position - Vector2(90, 0))
		player.facing = Vector2.RIGHT
		Input.action_press(&"attack")
		await frames(8)
		Input.action_release(&"attack")
		await frames(18)
	check_eq(enemy.hp, 18, "three actual hook hits during moth stun")
	check(enemy.is_stunned(), "three-hook window fits within stun")
	for i in range(90):
		if not enemy.is_stunned():
			break
		await frames(1)
	enemy.stun(2.0)
	check(not enemy.is_stunned(), "three-second immunity prevents stun lock")
	enemy.reset_fight()
	check(not enemy.is_stunned() and not enemy.is_knocked_back(), "reset clears real tool timers")
	check_eq(enemy.hp, 24, "reset fullHP")
	await dispose(arena)


func _attack_interruptions() -> void:
	for smash in [true, false]:
		for interruption in [&"reset", &"stun", &"death"]:
			reset_state()
			var arena := make_arena()
			var enemy = make_enemy(arena, SCENE, Vector2(800, 480))
			make_player(arena, Vector2(1300, 480))
			var warning: int = enemy.State.SMASH_WARNING if smash else enemy.State.SWEEP_WARNING
			await _wait_state(enemy, warning, 500)
			await _wait_state(enemy, enemy.State.RECOVER)
			var attack: Hitbox = enemy._attack
			check(attack.active, "natural attack active before %s" % interruption)
			check_eq(attack.kind, &"slam" if smash else &"sweep", "expected attack kind")
			check_eq(_chunks(arena).size(), 1, "natural smash leaves one hazard")
			match interruption:
				&"reset":
					enemy.reset_fight()
					check_eq(enemy.state, enemy.State.WALK, "reset immediately restores walk")
					check_eq(enemy._timer, enemy.APPROACH_TIME, "reset restores approach timer")
					check(enemy._smash_next, "reset restores first smash")
					check_eq(enemy._attack_left, 0.0, "reset clears attack timer")
				&"stun":
					enemy.stun(1.5)
					check(enemy.is_stunned(), "stun interrupts active attack")
				&"death":
					enemy.apply_damage(99, enemy.global_position, 0.0)
					check(enemy.is_dying(), "lethal hit interrupts active attack")
			check(not attack.active, "%s immediately disables attack" % interruption)
			await frames(2)
			check(not attack.active, "attack stays disabled after %s" % interruption)
			if interruption != &"stun":
				check_eq(_chunks(arena).size(), 0, "%s removes slag" % interruption)
			if interruption == &"reset":
				await _wait_state(enemy, enemy.State.SMASH_WARNING)
				await _wait_state(enemy, enemy.State.RECOVER)
				check(enemy._attack.active, "next fight produces an active attack")
				check_eq(enemy._attack.kind, &"slam", "next fight starts with slam")
				check_eq(enemy._attack.damage, 4, "next fight retains slam damage")
				check_eq(_chunks(arena).size(), 1, "next fight creates fresh slag")
			await dispose(arena)


func _lifecycle() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(800, 480))
	enemy.arena_id = &"cave_4_4"
	await frames(2)
	enemy.stun(1.5)
	enemy.apply_damage(99, enemy.global_position, 0.0)
	check(not enemy.is_stunned(), "lethal damage clears stun before death throes")
	check(GameState.has_flag(&"mini_cave_4_4"), "canonical persisted mini flag")
	check(not enemy.is_arena_locked(), "no shutters or arena lock")
	check(not enemy.contact_hitbox.active, "death disables contact")
	await frames(100)
	var drops := arena.get_children().filter(func(n: Node) -> bool: return n is PickupBase)
	check_eq(drops.size(), 4, "exactly four fixed drops")
	var kinds: Array = []
	for drop in drops:
		kinds.append(drop.kind)
		check(drop.timeout > 0.0, "fixed drops timed")
	check_eq(kinds.count(&"ember"), 2, "two embers")
	check_eq(kinds.count(&"brass_coin"), 2, "two coins; no extra tool or core")
	var scene := load(SCENE) as PackedScene
	check(scene != null, "scene loads")
	if scene != null:
		var retired = scene.instantiate()
		retired.arena_id = &"cave_4_4"
		arena.add_child(retired)
		check(retired.is_dead and not retired.visible, "defeated mauler retires on reload")
	await dispose(arena)


func _capture(label: String) -> void:
	if OS.get_environment("WICK_MB2_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		get_viewport().get_texture().get_image().save_png("/tmp/mb2-" + label + ".png"),
		OK,
		"actual state capture " + label
	)
