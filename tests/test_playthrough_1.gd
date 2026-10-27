## timeout=360
# gdlint: disable=max-file-lines
extends "res://tests/test_route_cave_2.gd"
## The opening walks through C1, defeats Kilnkeeper, collects its rewards and
## defeats C2 and C3, collects their rewards and reaches the C4 boss. The fixed seed 20261027
## collects the hermit and hidden C3 cores and farms earned enemy drops using player input.
## The bot reads enemy and pickup state.
## The continuous route defeats C4, collects its rewards and earns the C5 Lockpick.
## Its C4 bot reads boss and hazard internals and uses physics queries to steer.
## Later probes use positioned actions, warps and enemy removal; this is not a human playthrough.


func run() -> void:
	var start_frame := Engine.get_physics_frames()
	await walk_from_start()
	var first_script := load("res://tests/test_route_cave_1.gd") as GDScript
	check(first_script != null, "C1 route script loads")
	if first_script == null:
		return
	var first := first_script.new() as TestCase
	add_child(first)
	await first.run()
	checks += first.checks
	for failure in first.failures:
		failures.append("C1: " + failure)
	await dispose(first)
	check(GameState.has_fragment(&"c1"), "C1 boss dropped the earned first fragment")
	check(GameState.has_item(&"tether_moth"), "C1 route retained the earned moth")
	check(GameState.has_item(&"cinder_wick"), "C1 route retained the earned wick")
	check(GameState.has_flag(&"boss_cave_1_8_defeated"), "C1 boss was actually defeated")
	if not failures.is_empty():
		return
	if not await save_and_reload():
		return
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	await cave_two()
	check(GameState.has_fragment(&"c1"), "C1 fragment survives the C2 route")
	check(GameState.has_fragment(&"c2"), "C2 boss dropped the earned second fragment")
	check(GameState.has_flag(&"boss_cave_2_9_defeated"), "C2 boss was actually defeated")
	print(
		(
			"C1-C2 simulated play time: %.2f seconds"
			% ((Engine.get_physics_frames() - start_frame) / 60.0)
		)
	)
	await dispose(world)
	SaveGame.enabled = false


## Continuous opening through the C5 Lockpick: no repositioning, warps, enemy
## removal or damage suppression. Later cave probes use documented shortcuts.
func walk_from_start() -> void:
	seed(20261027)
	reset_state()
	SaveGame.enabled = false
	world = await make_world()
	player = world.player
	check_eq(world.get_current_room_id(), &"ow_0_0", "new game starts at Brackwater Edge")
	await walk_start_to(Vector2(480, 540))
	await walk_start_to(Vector2(960, 540))
	await walk_start_to(Vector2(960, 800))
	await walk_start_cross(&"move_down", &"ow_0_1")
	if world.get_current_room_id() == &"ow_0_1":
		await walk_start_to(Vector2(1200, 740))
		Input.action_press(&"move_right")
		await seconds(1.0)
		release_inputs()
		check(GameState.has_item(&"tether_moth"), "walking collects the first tool")
		await walk_start_to(Vector2(1600, 528))
		await walk_start_cross(&"move_right", &"ow_1_1")
	if world.get_current_room_id() == &"ow_1_1":
		await walk_start_to(Vector2(1392, 480))
		await walk_start_to(Vector2(1392, 240))
		await seconds(1.0)
	check_eq(world.get_current_room_id(), &"cave_1", "walking reaches the real C1 entrance")
	if world.get_current_room_id() == &"cave_1" and not player.is_dead():
		await walk_start_to(Vector2(960, 528))
		await walk_start_to(Vector2(250, 528))
		await walk_start_cross(&"move_left", &"cave_1_2")
	if world.get_current_room_id() == &"cave_1_2" and not player.is_dead():
		await walk_start_to(Vector2(960, 480))
		await walk_start_to(Vector2(960, 180))
		await walk_start_cross(&"move_up", &"cave_1_3")
	if world.get_current_room_id() == &"cave_1_3" and not player.is_dead():
		await walk_start_to(Vector2(1008, 528))
		Input.action_press(&"move_up")
		await frames(2)
		Input.action_release(&"move_up")
		Input.action_press(&"use_item")
		await frames(2)
		Input.action_release(&"use_item")
		await seconds(1.7)
		check(
			GameState.has_flag(&"picked_key_c1_1"),
			"walking route retrieves the C1 key through the grate"
		)
		check_eq(GameState.keys_in(&"c1"), 1, "retrieved key credits the C1 scope")
		await walk_start_to(Vector2(960, 780))
		await walk_start_cross(&"move_down", &"cave_1_2")
	if world.get_current_room_id() == &"cave_1_2" and not player.is_dead():
		await walk_start_to(Vector2(960, 480))
		await walk_start_to(Vector2(1680, 480))
		await walk_start_cross(&"move_right", &"cave_1")
	if world.get_current_room_id() == &"cave_1" and not player.is_dead():
		await walk_start_to(Vector2(960, 528))
		await walk_start_to(Vector2(1680, 528))
		await walk_start_cross(&"move_right", &"cave_1_4")
	if world.get_current_room_id() == &"cave_1_4" and not player.is_dead():
		await walk_start_to(Vector2(960, 380))
		await walk_start_to(Vector2(1700, 380))
		await walk_start_to(Vector2(1700, 480))
		await walk_start_cross(&"move_right", &"cave_1_6")
		check(GameState.has_flag(&"door_e151"), "walking opens the C1 locked door")
		check_eq(GameState.keys_in(&"c1"), 0, "walking through the door spends the earned C1 key")
		print(
			"Walking C1 lock health: %d/%d half-hearts" % [GameState.health, GameState.max_health]
		)
	if world.get_current_room_id() == &"cave_1_6" and not player.is_dead():
		await walk_start_to(Vector2(200, 480))
		await walk_start_cross(&"move_left", &"cave_1_4")
	if world.get_current_room_id() == &"cave_1_4" and not player.is_dead():
		await walk_start_to(Vector2(1296, 310))
		await walk_start_swing_up()
		await walk_start_to(Vector2(624, 310))
		await walk_start_swing_up()
		check(GameState.has_flag(&"brazier_c1_hall_west"), "walking lights the west brazier")
		check(GameState.has_flag(&"brazier_c1_hall_east"), "walking lights the east brazier")
		await walk_start_to(Vector2(960, 180))
		await walk_start_cross(&"move_up", &"cave_1_5")
	if world.get_current_room_id() == &"cave_1_5" and not player.is_dead():
		await walk_start_to(Vector2(1250, 720))
		await walk_start_to(Vector2(1250, 300))
		await walk_start_to(Vector2(960, 315))
		await frames(5)
		check(GameState.has_item(&"cinder_wick"), "walking collects the C1 wick")
		await walk_start_to(Vector2(1250, 315))
		await walk_start_to(Vector2(1250, 480))
		await walk_start_to(Vector2(1680, 480))
		await walk_start_cross(&"move_right", &"cave_1_7")
	if world.get_current_room_id() == &"cave_1_7" and not player.is_dead():
		await walk_start_to(Vector2(1250, 480))
		await walk_start_to(Vector2(1488, 315))
		await frames(5)
		check(GameState.has_big_key(&"c1"), "walking collects the C1 Lockpick")
		await walk_start_to(Vector2(1250, 315))
		await walk_start_to(Vector2(1250, 480))
		await walk_start_to(Vector2(200, 480))
		await walk_start_cross(&"move_left", &"cave_1_5")
	if world.get_current_room_id() == &"cave_1_5" and not player.is_dead():
		await walk_start_to(Vector2(1500, 720))
		await walk_start_to(Vector2(960, 780))
		await walk_start_cross(&"move_down", &"cave_1_4")
	if world.get_current_room_id() == &"cave_1_4" and not player.is_dead():
		await walk_start_to(Vector2(1100, 180))
		await walk_start_to(Vector2(1100, 380))
		await walk_start_to(Vector2(1700, 380))
		await walk_start_to(Vector2(1700, 480))
		await walk_start_cross(&"move_right", &"cave_1_6")
	if world.get_current_room_id() == &"cave_1_6" and not player.is_dead():
		await walk_start_to(Vector2(1680, 480))
		await walk_start_cross(&"move_right", &"cave_1_8")
		check(GameState.has_flag(&"door_boss_c1"), "walking opens the C1 boss door")
	if world.get_current_room_id() == &"cave_1_8" and not player.is_dead():
		await walking_boss()
	if world.get_current_room_id() == &"cave_1_6" and not player.is_dead():
		await walk_toward_c2()
	check(not player.is_dead(), "the opening route remains survivable")
	await dispose(world)


func walking_boss() -> void:
	var boss = world.current_room.get_node("Enemies/Kilnkeeper1")
	Input.action_press(&"cycle_item")
	await frames(2)
	Input.action_release(&"cycle_item")
	check_eq(GameState.active_item, &"cinder_wick", "walking bot equips earned wick")
	var last_cast := -300
	# Circle using visible positions and cast when aligned; never inspect combat state.
	for tick in range(7200):
		if player.is_dead() or GameState.has_flag(&"boss_cave_1_8_defeated"):
			break
		var d: Vector2 = boss.global_position - player.global_position
		release_inputs()
		if tick - last_cast > 220 and d.length() < 390 and (absf(d.x) < 45 or absf(d.y) < 45):
			if absf(d.x) > absf(d.y):
				Input.action_press(&"move_right" if d.x > 0 else &"move_left")
			else:
				Input.action_press(&"move_down" if d.y > 0 else &"move_up")
			await frames(1)
			Input.action_press(&"use_item")
			last_cast = tick
		else:
			var motion := (
				d.normalized().orthogonal()
				+ d.normalized() * clampf((d.length() - 330.0) / 100.0, -1.5, 1.5)
			)
			if absf(motion.x) > 0.3:
				Input.action_press(&"move_right" if motion.x > 0 else &"move_left")
			if absf(motion.y) > 0.3:
				Input.action_press(&"move_down" if motion.y > 0 else &"move_up")
		await frames(1)
	release_inputs()
	check(not player.is_dead(), "walking boss fight finishes without death")
	check(GameState.has_flag(&"boss_cave_1_8_defeated"), "walking bot defeats Kilnkeeper")
	print(
		"Walking boss victory health: %d/%d half-hearts" % [GameState.health, GameState.max_health]
	)
	if player.is_dead() or not GameState.has_flag(&"boss_cave_1_8_defeated"):
		return
	await seconds(1.6)
	await walk_start_to(Vector2(1450, 200))
	await walk_start_to(Vector2(1152, 200))
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(1152, 480))
	check(GameState.has_fragment(&"c1"), "walking collects the C1 fragment")
	check_eq(GameState.max_health, 8, "walking collects the C1 wick core")
	check_eq(GameState.health, 8, "C1 wick core restores health")
	await walk_start_to(Vector2(240, 480))
	await walk_start_cross(&"move_left", &"cave_1_6")
	check(not player.is_dead(), "walking leaves the boss arena alive")


func walk_toward_c2() -> void:
	await walk_start_to(Vector2(200, 480))
	await walk_start_cross(&"move_left", &"cave_1_4")
	await walk_start_to(Vector2(200, 480))
	await walk_start_cross(&"move_left", &"cave_1")
	await walk_start_to(Vector2(960, 528))
	await walk_start_to(Vector2(960, 700))
	await walk_start_to(Vector2(960, 816))
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"ow_1_1", "walking leaves C1 by its mouth")
	if world.get_current_room_id() != &"ow_1_1" or player.is_dead():
		return
	await walk_start_to(Vector2(960, 180))
	await walk_start_cross(&"move_up", &"ow_1_0")
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(1100, 380))
	await walk_start_to(Vector2(1600, 380))
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"ow_2_0")
	await walk_start_to(Vector2(240, 480))
	await walk_start_to(Vector2(240, 528))
	await walk_start_to(Vector2(1600, 528))
	await walk_start_to(Vector2(1600, 480))
	Input.action_press(&"move_right")
	await frames(2)
	Input.action_release(&"move_right")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await seconds(3.0)
	check(GameState.has_flag(&"burned_e005"), "walking burns the Thornwood hedge")
	await walk_start_cross(&"move_right", &"ow_3_0")
	if world.get_current_room_id() != &"ow_3_0" or player.is_dead():
		return
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(960, 780))
	await walk_start_cross(&"move_down", &"ow_3_1")
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"ow_4_1")
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"ow_5_1")
	check(not player.is_dead(), "walking reaches the C2 mouth room alive")
	check(GameState.has_fragment(&"c1"), "walking retains the C1 fragment")
	check(GameState.has_item(&"cinder_wick"), "walking retains the earned wick")
	# Pass between the rooted snappers and take the direct approach to the mouth.
	await walk_start_to(Vector2(240, 528))
	await walk_start_to(Vector2(960, 528))
	await walk_start_to(Vector2(1488, 320))
	await walk_start_to(Vector2(1488, 240))
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"cave_2_1", "walking enters C2")
	check(not player.is_dead(), "walking enters C2 alive")
	check(GameState.has_fragment(&"c1"), "C1 fragment remains after walking into C2")
	check(GameState.has_item(&"tether_moth"), "earned moth remains after walking into C2")
	check(GameState.has_item(&"cinder_wick"), "earned wick remains after walking into C2")
	if world.get_current_room_id() == &"cave_2_1" and not player.is_dead():
		await walk_c2_first_key()
	print(
		(
			"Walking toward C2: room=%s health=%d/%d"
			% [world.get_current_room_id(), GameState.health, GameState.max_health]
		)
	)


func walk_c2_first_key() -> void:
	await walk_start_to(Vector2(900, 576))
	await walk_start_to(Vector2(1000, 624))
	Input.action_press(&"move_right")
	await frames(2)
	Input.action_release(&"move_right")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await seconds(1.7)
	await walk_start_to(Vector2(1296, 624))
	print("C2 snapper drop health: %d/%d" % [GameState.health, GameState.max_health])
	await walk_start_to(Vector2(1600, 480))
	await walk_start_cross(&"move_right", &"cave_2_2")
	check(not player.is_dead(), "walking reaches C2 seed hall alive")
	if world.get_current_room_id() != &"cave_2_2" or player.is_dead():
		return
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(960, 240))
	Input.action_press(&"move_up")
	await frames(2)
	Input.action_release(&"move_up")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await seconds(1.8)
	check(GameState.has_flag(&"burned_e156"), "walking burns the C2 thorn gate")
	await walk_start_to(Vector2(960, 180))
	await walk_start_cross(&"move_up", &"cave_2_3")
	await walk_start_to(Vector2(1008, 240))
	check_eq(GameState.keys_in(&"c2"), 1, "walking collects the first C2 key")
	await walk_start_to(Vector2(960, 780))
	await walk_start_cross(&"move_down", &"cave_2_2")
	check_eq(GameState.keys_in(&"c2"), 1, "walking retains the C2 key on return")
	check(not player.is_dead(), "walking returns to C2 seed hall alive")
	# The upper aisle avoids the skitterwicks without removing or disabling them.
	await walk_start_to(Vector2(960, 150))
	await walk_start_to(Vector2(1700, 150))
	await walk_start_to(Vector2(1700, 480))
	await walk_start_cross(&"move_right", &"cave_2_4")
	check(GameState.has_flag(&"door_e157"), "walking opens C2's first locked door")
	check_eq(GameState.keys_in(&"c2"), 0, "walking spends the earned C2 key")
	check(not player.is_dead(), "walking enters C2 miniboss room alive")
	await walk_c2_warden()


func walk_c2_warden() -> void:
	var enemy = world.current_room.get_node("Enemies/ThornWarden1")
	var last_cast := -300
	# Aim and circle using positions, with the earned wick and normal damage.
	for tick in range(3600):
		if player.is_dead() or GameState.has_flag(&"mini_cave_2_4"):
			break
		var d: Vector2 = enemy.global_position - player.global_position
		release_inputs()
		if tick - last_cast > 220 and d.length() < 390 and (absf(d.x) < 45 or absf(d.y) < 45):
			if absf(d.x) > absf(d.y):
				Input.action_press(&"move_right" if d.x > 0 else &"move_left")
			else:
				Input.action_press(&"move_down" if d.y > 0 else &"move_up")
			await frames(1)
			Input.action_press(&"use_item")
			last_cast = tick
		else:
			var motion := (
				d.normalized().orthogonal()
				+ d.normalized() * clampf((d.length() - 330.0) / 100.0, -1.5, 1.5)
			)
			if absf(motion.x) > 0.3:
				Input.action_press(&"move_right" if motion.x > 0 else &"move_left")
			if absf(motion.y) > 0.3:
				Input.action_press(&"move_down" if motion.y > 0 else &"move_up")
		await frames(1)
	release_inputs()
	check(not player.is_dead(), "walking survives Thorn Warden")
	check(GameState.has_flag(&"mini_cave_2_4"), "walking defeats Thorn Warden")
	if player.is_dead() or not GameState.has_flag(&"mini_cave_2_4"):
		return
	var drop_location: Vector2 = enemy.global_position - world.current_room.global_position
	await seconds(1.6)
	await walk_start_to(drop_location)
	check_eq(GameState.health, 5, "walking collects both Warden health drops")
	print("C2 Warden drops health: %d/%d" % [GameState.health, GameState.max_health])
	await walk_start_to(Vector2(1700, 480))
	await walk_start_cross(&"move_right", &"cave_2_5")
	check(not player.is_dead(), "walking reaches C2 sling room alive")
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(1200, 400))
	await walk_start_to(Vector2(1200, 315))
	await frames(5)
	check(GameState.has_item(&"tallow_sling"), "walking collects the C2 sling")
	check_eq(GameState.slugs, 12, "walking receives the sling's starting slugs")
	await walk_start_to(Vector2(960, 315))
	await walk_start_to(Vector2(960, 180))
	await walk_start_cross(&"move_up", &"cave_2_6")
	await walk_start_to(Vector2(960, 720))
	await walk_start_to(Vector2(528, 720))
	check_eq(GameState.keys_in(&"c2"), 1, "walking collects the second C2 key")
	await walk_start_to(Vector2(1104, 624))
	await frames(5)
	check_eq(GameState.slugs, 18, "walking collects the C2 slug bundle")
	print("C2 second key and bundle: health=%d slugs=%d" % [GameState.health, GameState.slugs])
	await walk_start_to(Vector2(1200, 336))
	Input.action_press(&"cycle_item")
	await frames(2)
	Input.action_release(&"cycle_item")
	check_eq(GameState.active_item, &"tallow_sling", "walking equips the earned sling")
	Input.action_press(&"move_right")
	await frames(2)
	Input.action_release(&"move_right")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await seconds(0.7)
	check(GameState.has_flag(&"eye_e160"), "walking opens the C2 eye gate with the sling")
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"cave_2_7")
	await walk_start_to(Vector2(1200, 480))
	await walk_start_to(Vector2(1488, 400))
	await walk_start_to(Vector2(1488, 315))
	await frames(5)
	check(GameState.has_big_key(&"c2"), "walking collects the C2 Lockpick")
	print("C2 Lockpick: health=%d slugs=%d" % [GameState.health, GameState.slugs])
	await walk_start_to(Vector2(1200, 480))
	await walk_start_to(Vector2(200, 480))
	await walk_start_cross(&"move_left", &"cave_2_6")
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(960, 780))
	await walk_start_cross(&"move_down", &"cave_2_5")
	await walk_start_to(Vector2(960, 780))
	await walk_start_cross(&"move_down", &"cave_2_8")
	check_eq(
		GameState.keys_in(&"c2"), 1, "walking retains the C2 key when the Lockpick opens the lock"
	)
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"cave_2_9")
	check(GameState.has_flag(&"door_boss_c2"), "walking opens the C2 boss door")
	check(not player.is_dead(), "walking reaches the C2 boss arena alive")
	check(GameState.has_big_key(&"c2"), "walking retains the C2 Lockpick")
	check_eq(GameState.slugs, 17, "walking retains the earned slugs after opening the eye")
	print("C2 boss entrance: health=%d slugs=%d" % [GameState.health, GameState.slugs])
	await walk_briar()


func walk_briar() -> void:
	var boss = world.current_room.get_node("Enemies/BriarMother1")
	var last_shot := -100
	var previous := {}
	# This bot reads eye HP/visibility, boss phase, and projectile direction/speed.
	for tick in range(6000):
		if player.is_dead() or GameState.has_flag(&"boss_cave_2_9_defeated"):
			break
		release_inputs()
		var evade := Vector2.ZERO
		for projectile in get_tree().get_nodes_in_group(&"projectiles"):
			if not projectile is EnemyProjectile:
				continue
			var rel: Vector2 = player.global_position - projectile.global_position
			var t: float = rel.dot(projectile.direction) / projectile.speed
			var nearest: Vector2 = rel - projectile.direction * rel.dot(projectile.direction)
			if t > 0 and t < 0.3 and nearest.length() < 50:
				evade += (
					nearest.normalized()
					if nearest.length() > 0.1
					else projectile.direction.orthogonal()
				)
		if evade != Vector2.ZERO:
			if absf(evade.x) > 0.25:
				Input.action_press(&"move_right" if evade.x > 0 else &"move_left")
			if absf(evade.y) > 0.25:
				Input.action_press(&"move_down" if evade.y > 0 else &"move_up")
			await frames(1)
			continue
		if boss.phase == 2:
			if GameState.active_item != &"cinder_wick":
				Input.action_press(&"cycle_item")
				await frames(2)
				Input.action_release(&"cycle_item")
				await frames(2)
				continue
			var diff: Vector2 = boss.global_position + Vector2(0, 175) - player.global_position
			if absf(diff.x) < 22 and absf(diff.y) < 30 and tick - last_shot > 220:
				Input.action_press(&"move_up")
				await frames(1)
				Input.action_press(&"use_item")
				last_shot = tick
			else:
				if absf(diff.x) > 15:
					Input.action_press(&"move_right" if diff.x > 0 else &"move_left")
				if absf(diff.y) > 15:
					Input.action_press(&"move_down" if diff.y > 0 else &"move_up")
				if tick % 25 == 0:
					Input.action_press(&"attack")
			await frames(1)
			continue
		var target: Node2D = null
		for eye in boss.eyes:
			if is_instance_valid(eye) and not eye.is_dead and eye.visible:
				if (
					target == null
					or eye.hp < target.hp
					or (
						eye.hp == target.hp
						and (
							eye.global_position.distance_to(player.global_position)
							< target.global_position.distance_to(player.global_position)
						)
					)
				):
					target = eye
		if target == null:
			await frames(1)
			continue
		var old: Vector2 = previous.get(target.get_instance_id(), target.global_position)
		var velocity: Vector2 = (target.global_position - old) * 60.0
		previous[target.get_instance_id()] = target.global_position
		var aim: Vector2 = target.global_position + velocity * 0.10
		var diff: Vector2 = aim + Vector2(0, 150) - player.global_position
		if absf(diff.x) < 16 and absf(diff.y) < 30 and tick - last_shot > 30:
			Input.action_press(&"move_up")
			await frames(1)
			Input.action_press(&"use_item")
			last_shot = tick
		else:
			if absf(diff.x) > 12:
				Input.action_press(&"move_right" if diff.x > 0 else &"move_left")
			if absf(diff.y) > 12:
				Input.action_press(&"move_down" if diff.y > 0 else &"move_up")
			if tick % 25 == 0:
				Input.action_press(&"attack")
		await frames(1)
	release_inputs()
	print("Walking C2 boss victory: health=%d slugs=%d" % [GameState.health, GameState.slugs])
	check(not player.is_dead(), "survives C2 boss")
	check(GameState.has_flag(&"boss_cave_2_9_defeated"), "defeats C2 boss")
	if player.is_dead() or not GameState.has_flag(&"boss_cave_2_9_defeated"):
		return
	await seconds(1.6)
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(1152, 480))
	check(GameState.has_fragment(&"c2"), "walking collects the C2 fragment")
	check_eq(GameState.max_health, 10, "walking collects the C2 wick core")
	check_eq(GameState.health, 10, "C2 wick core restores health")
	await walk_toward_c3()


func walk_toward_c3() -> void:
	await walk_start_to(Vector2(240, 480))
	await walk_start_cross(&"move_left", &"cave_2_8")
	await walk_start_to(Vector2(960, 180))
	await walk_start_cross(&"move_up", &"cave_2_5")
	await walk_start_to(Vector2(240, 480))
	await walk_start_cross(&"move_left", &"cave_2_4")
	await walk_start_to(Vector2(240, 480))
	await walk_start_cross(&"move_left", &"cave_2_2")
	await walk_start_to(Vector2(240, 480))
	await walk_start_cross(&"move_left", &"cave_2_1")
	await walk_start_to(Vector2(528, 720))
	await seconds(1)
	check_eq(world.get_current_room_id(), &"ow_5_1", "walking exits C2 by its mouth")
	check(not player.is_dead(), "walking exits C2 alive")
	await walk_start_to(Vector2(1200, 480))
	await walk_start_to(Vector2(200, 528))
	await walk_start_cross(&"move_left", &"ow_4_1")
	await walk_start_to(Vector2(960, 432))
	await walk_start_to(Vector2(200, 432))
	await walk_start_to(Vector2(200, 480))
	await walk_start_cross(&"move_left", &"ow_3_1")
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(960, 780))
	await walk_start_cross(&"move_down", &"ow_3_2")
	check(not player.is_dead(), "walking reaches Sunken Lane alive")
	await walk_start_to(Vector2(960, 780))
	await walk_start_cross(&"move_down", &"ow_3_3")
	await walk_start_to(Vector2(1200, 600))
	await walk_start_to(Vector2(1392, 550))
	for cycle in range(5):
		if GameState.active_item == &"cinder_wick":
			break
		Input.action_press(&"cycle_item")
		await frames(2)
		Input.action_release(&"cycle_item")
		await frames(2)
	Input.action_press(&"move_up")
	await frames(2)
	Input.action_release(&"move_up")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await seconds(3.0)
	check(GameState.has_flag(&"burned_e129"), "walking burns the hermit hut thorns")
	await walk_start_to(Vector2(1392, 432))
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"ow_3_3#hut", "walking enters the hermit hut")
	await walk_start_to(Vector2(912, 410))
	await frames(5)
	check(GameState.has_flag(&"picked_wick_core_ow_3_3"), "walking collects the hermit core")
	check_eq(GameState.max_health, 12, "hermit core increases maximum health")
	await walk_start_to(Vector2(912, 780))
	await walk_start_to(Vector2(912, 816))
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"ow_3_3", "walking leaves the hermit hut")
	await walk_start_to(Vector2(960, 180))
	await walk_start_cross(&"move_up", &"ow_3_2")
	await walk_start_to(Vector2(1250, 432))
	await walk_start_to(Vector2(1488, 384))
	await walk_start_to(Vector2(1488, 240))
	await seconds(1.0)
	check_eq(
		world.get_current_room_id(), &"ow_3_2#grate", "walking enters the overworld key alcove"
	)
	await walk_start_to(Vector2(912, 432))
	for cycle in range(3):
		if GameState.active_item == &"tether_moth":
			break
		Input.action_press(&"cycle_item")
		await frames(2)
		Input.action_release(&"cycle_item")
		await frames(2)
	Input.action_press(&"move_up")
	await frames(2)
	Input.action_release(&"move_up")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await seconds(1.8)
	check(GameState.has_flag(&"picked_key_ow_2"), "walking retrieves the overworld key with moth")
	check_eq(GameState.keys_in(&"ow"), 1, "walking holds the overworld key")
	await walk_start_to(Vector2(912, 780))
	await walk_start_to(Vector2(912, 816))
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"ow_3_2", "walking leaves the overworld key alcove")
	await walk_start_to(Vector2(960, 432))
	await walk_start_to(Vector2(960, 180))
	await walk_start_cross(&"move_up", &"ow_3_1")
	await walk_start_to(Vector2(960, 180))
	await walk_start_cross(&"move_up", &"ow_3_0")
	await walk_start_to(Vector2(200, 480))
	await walk_start_cross(&"move_left", &"ow_2_0")
	await walk_start_to(Vector2(1600, 528))
	await walk_start_to(Vector2(960, 780))
	await walk_start_cross(&"move_down", &"ow_2_1")
	check(not player.is_dead(), "walking reaches the pitch pot room alive")
	await walk_start_to(Vector2(1400, 432))
	await walk_start_to(Vector2(1536, 432))
	await walk_start_to(Vector2(1536, 600))
	await walk_start_to(Vector2(1700, 600))
	await walk_start_to(Vector2(1700, 800))
	await walk_start_to(Vector2(1584, 800))
	await walk_start_to(Vector2(1584, 790))
	await frames(5)
	check(GameState.has_item(&"pitch_pot"), "walking collects the pitch pot")
	check_eq(GameState.keys_in(&"ow"), 0, "walking spends overworld key on the pitch pot closet")
	check_eq(GameState.pitch_pots, 6, "walking acquires six starting pitch pots")
	await walk_start_to(Vector2(1700, 800))
	await walk_start_to(Vector2(1700, 600))
	await walk_start_to(Vector2(1536, 600))
	await walk_start_to(Vector2(1536, 432))
	await walk_start_to(Vector2(200, 432))
	await walk_start_to(Vector2(200, 480))
	await walk_start_cross(&"move_left", &"ow_1_1")
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(960, 780))
	await walk_start_cross(&"move_down", &"ow_1_2")
	await walk_start_to(Vector2(960, 750))
	Input.action_press(&"move_down")
	await frames(2)
	Input.action_release(&"move_down")
	Input.action_press(&"attack")
	await frames(2)
	Input.action_release(&"attack")
	await frames(25)
	await walk_start_cross(&"move_down", &"ow_1_3")
	check(not player.is_dead(), "walking reaches the Tallowfen road alive")
	await walk_start_to(Vector2(960, 780))
	await walk_start_cross(&"move_down", &"ow_1_4")
	await walk_start_to(Vector2(960, 780))
	await walk_start_cross(&"move_down", &"ow_1_5")
	await walk_start_to(Vector2(960, 432))
	await walk_start_to(Vector2(1680, 432))
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"ow_2_5")
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"ow_3_5")
	check(not player.is_dead(), "walking reaches the C3 mouth room alive")
	await walk_start_to(Vector2(912, 480))
	for cycle in range(4):
		if GameState.active_item == &"pitch_pot":
			break
		Input.action_press(&"cycle_item")
		await frames(2)
		Input.action_release(&"cycle_item")
		await frames(2)
	await walk_start_to(Vector2(912, 400))
	Input.action_press(&"move_up")
	await frames(2)
	Input.action_release(&"move_up")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await walk_start_to(Vector2(912, 650))
	await seconds(1.5)
	check(GameState.has_flag(&"cracked_e248"), "walking opens C3 mouth with earned pitch pot")
	check_eq(GameState.pitch_pots, 5, "walking spends one earned pitch pot")
	await walk_start_to(Vector2(912, 240))
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"cave_3_1", "walking enters C3 through the real mouth")
	check(not player.is_dead(), "walking enters C3 alive")
	check(GameState.has_fragment(&"c1"), "walking retains the C1 fragment on reaching C3")
	check(GameState.has_fragment(&"c2"), "walking retains the C2 fragment on reaching C3")
	check(GameState.has_item(&"pitch_pot"), "walking retains the earned pitch pot on reaching C3")
	await walk_c3_boss()
	print(
		"Post-C3 progression: room=%s health=%d" % [world.get_current_room_id(), GameState.health]
	)


func walk_c3_boss() -> void:
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"cave_3_2")
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(960, 150))
	await walk_start_swing_up()
	await walk_start_cross(&"move_up", &"cave_3_3")
	await walk_start_to(Vector2(1008, 336))
	await frames(5)
	check_eq(GameState.keys_in(&"c3"), 1, "walking collects the C3 key")
	check(not player.is_dead(), "walking collects the C3 key alive")
	await walk_start_to(Vector2(960, 800))
	Input.action_press(&"move_down")
	await frames(2)
	Input.action_release(&"move_down")
	Input.action_press(&"attack")
	await frames(2)
	Input.action_release(&"attack")
	await frames(20)
	await walk_start_cross(&"move_down", &"cave_3_2")
	await walk_start_to(Vector2(960, 432))
	await walk_start_to(Vector2(1680, 432))
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"cave_3_4")
	check(GameState.has_flag(&"door_e165"), "walking opens the C3 locked door")
	check_eq(GameState.keys_in(&"c3"), 0, "walking spends the C3 key")
	check(not player.is_dead(), "walking reaches the C3 miniboss alive")
	await walk_start_to(Vector2(200, 150))
	await walk_start_to(Vector2(1700, 150))
	await walk_start_to(Vector2(1700, 480))
	await walk_start_cross(&"move_right", &"cave_3_5")
	check(not player.is_dead(), "walking reaches the C3 raft room alive")
	check(not GameState.has_flag(&"mini_cave_3_4"), "walking passes the active C3 miniboss")
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(1296, 450))
	await walk_start_to(Vector2(1296, 410))
	await frames(5)
	check(GameState.has_item(&"reed_raft"), "walking collects the C3 raft")
	await walk_start_to(Vector2(960, 260))
	await walk_start_to(Vector2(960, 200))
	for cycle in range(5):
		if GameState.active_item == &"reed_raft":
			break
		Input.action_press(&"cycle_item")
		await frames(2)
		Input.action_release(&"cycle_item")
		await frames(2)
	check_eq(GameState.active_item, &"reed_raft", "walking equips the C3 raft")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	for tick in range(600):
		await frames(1)
		if world.get_current_room_id() == &"cave_3_6" and not player.is_external_motion():
			break
	check_eq(world.get_current_room_id(), &"cave_3_6", "earned raft crosses the actual C3 sluice")
	check(not player.is_dead(), "walking reaches the C3 lockpick room alive")
	await walk_start_to(Vector2(1200, 336))
	await frames(5)
	check(GameState.has_big_key(&"c3"), "walking collects the C3 Lockpick")
	await walk_start_to(Vector2(1730, 480))
	await walk_raft_cross(&"cave_3_7")
	await walk_start_to(Vector2(1200, 480))
	await walk_start_to(Vector2(1488, 336))
	await walk_start_to(Vector2(1488, 240))
	await frames(5)
	check(GameState.has_flag(&"picked_wick_core_c3_hidden"), "walking collects the hidden C3 core")
	check_eq(GameState.max_health, 14, "hidden core increases maximum health")
	await walk_start_to(Vector2(1200, 480))
	await walk_start_to(Vector2(200, 480))
	await walk_raft_cross(&"cave_3_6")
	await walk_start_to(Vector2(960, 760))
	await seconds(0.5)
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	for tick in range(600):
		await frames(1)
		if world.get_current_room_id() == &"cave_3_5" and not player.is_external_motion():
			break
	check_eq(world.get_current_room_id(), &"cave_3_5", "earned raft crosses back to C3 dry dock")
	await walk_start_to(Vector2(960, 780))
	await walk_start_cross(&"move_down", &"cave_3_8")
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"cave_3_9")
	check(GameState.has_flag(&"door_boss_c3"), "walking opens the C3 boss door")
	check(not player.is_dead(), "walking reaches the C3 boss alive")
	check(GameState.has_big_key(&"c3"), "walking retains the C3 Lockpick")
	check(
		GameState.has_fragment(&"c1") and GameState.has_fragment(&"c2"),
		"walking retains both fragments"
	)
	await walk_tidewick()


func walk_tidewick() -> void:
	var boss = world.current_room.get_node("Enemies/Tidewick1")
	await walk_start_to(Vector2(184, 432))
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await seconds(0.4)
	check(player.is_on_raft(), "walking boards Tidewick basin raft")
	var previous: Vector2 = boss.tail.global_position
	var last_attack := -100
	# Track the tail's position and exposure; steer and swing through normal inputs.
	for tick in range(12000):
		if player.is_dead() or GameState.has_flag(&"boss_cave_3_9_defeated"):
			break
		var tail_pos: Vector2 = boss.tail.global_position
		var tail_vel: Vector2 = (tail_pos - previous) * 60.0
		previous = tail_pos
		var target: Vector2 = tail_pos + tail_vel * 0.5
		var diff: Vector2 = target - player.global_position
		release_inputs()
		var toward: Vector2 = tail_pos - player.global_position
		if boss.tail_exposed() and toward.length() < 140 and tick - last_attack > 24:
			if absf(toward.x) > absf(toward.y):
				Input.action_press(&"move_right" if toward.x > 0 else &"move_left")
			else:
				Input.action_press(&"move_down" if toward.y > 0 else &"move_up")
			await frames(1)
			Input.action_press(&"attack")
			last_attack = tick
		else:
			if absf(diff.x) > 20:
				Input.action_press(&"move_right" if diff.x > 0 else &"move_left")
			if absf(diff.y) > 20:
				Input.action_press(&"move_down" if diff.y > 0 else &"move_up")
		await frames(1)
	release_inputs()
	print("Walking Tidewick victory: health=%d" % GameState.health)
	check(not player.is_dead(), "walking survives Tidewick")
	check(GameState.has_flag(&"boss_cave_3_9_defeated"), "walking defeats Tidewick")
	if player.is_dead() or not GameState.has_flag(&"boss_cave_3_9_defeated"):
		return
	await seconds(1.6)
	var dock: Vector2 = world.current_room.global_position + Vector2(288, 432)
	for tick in range(900):
		if not player.is_on_raft() or player.is_dead():
			break
		var diff: Vector2 = dock - player.global_position
		release_inputs()
		if absf(diff.x) > 8:
			Input.action_press(&"move_right" if diff.x > 0 else &"move_left")
		if absf(diff.y) > 8:
			Input.action_press(&"move_down" if diff.y > 0 else &"move_up")
		await frames(1)
	release_inputs()
	check(not player.is_on_raft(), "real raft docks after the Tidewick victory")
	await walk_start_to(Vector2(192, 672))
	await walk_start_to(Vector2(192, 816))
	check(GameState.has_fragment(&"c3"), "walking collects the C3 fragment")
	check_eq(GameState.max_health, 16, "walking collects the C3 wick core")
	check_eq(GameState.health, 16, "C3 wick core restores health")
	await walk_toward_c4()


func walk_toward_c4() -> void:
	await walk_start_to(Vector2(240, 480))
	await walk_start_cross(&"move_left", &"cave_3_8")
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(960, 180))
	await walk_start_cross(&"move_up", &"cave_3_5")
	await walk_start_to(Vector2(240, 480))
	await walk_start_cross(&"move_left", &"cave_3_4")
	await walk_start_to(Vector2(1700, 150))
	await walk_start_to(Vector2(200, 150))
	await walk_start_to(Vector2(200, 480))
	await walk_start_cross(&"move_left", &"cave_3_2")
	await walk_start_to(Vector2(240, 480))
	await walk_start_cross(&"move_left", &"cave_3_1")
	await walk_start_to(Vector2(528, 624))
	await walk_start_to(Vector2(528, 720))
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"ow_3_5", "walking exits C3 by the opened mouth")
	check(not player.is_dead(), "walking exits C3 alive")
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"ow_4_5")
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(960, 180))
	await walk_start_cross(&"move_up", &"ow_4_4")
	await walk_start_to(Vector2(1150, 720))
	await walk_start_to(Vector2(1150, 180))
	await walk_start_to(Vector2(960, 180))
	await walk_start_cross(&"move_up", &"ow_4_3")
	check(not player.is_dead(), "walking reaches the lake shore alive")
	await walk_start_to(Vector2(960, 528))
	await walk_start_to(Vector2(1600, 528))
	await walk_start_to(Vector2(1720, 480))
	await seconds(0.5)
	await walk_raft_cross(&"ow_5_3")
	await walk_start_to(Vector2(300, 600))
	await walk_start_to(Vector2(960, 600))
	await walk_start_to(Vector2(960, 200))
	await walk_raft_cross(&"ow_5_2")
	await walk_start_to(Vector2(200, 480))
	await walk_start_cross(&"move_left", &"ow_4_2")
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(960, 180))
	await walk_start_cross(&"move_up", &"ow_4_1")
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"ow_5_1")
	await walk_start_to(Vector2(240, 528))
	await walk_start_to(Vector2(960, 528))
	await walk_start_to(Vector2(1680, 400))
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"ow_6_1")
	check(not player.is_dead(), "walking reaches Rootbridge alive")
	await walk_start_to(Vector2(600, 300))
	await walk_start_to(Vector2(1680, 300))
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"ow_7_1")
	await walk_start_to(Vector2(1100, 300))
	await walk_start_to(Vector2(1100, 240))
	for cycle in range(5):
		if GameState.active_item == &"tallow_sling":
			break
		Input.action_press(&"cycle_item")
		await frames(2)
		Input.action_release(&"cycle_item")
		await frames(2)
	check_eq(GameState.active_item, &"tallow_sling", "walking equips the earned sling at Eyegate")
	Input.action_press(&"move_right")
	await frames(2)
	Input.action_release(&"move_right")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await seconds(0.7)
	check(GameState.has_flag(&"eye_e028"), "walking opens Eyegate with the earned sling")
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"ow_8_1")
	check(not player.is_dead(), "walking reaches Cinderflats alive")
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"ow_9_1")
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(960, 780))
	await walk_start_cross(&"move_down", &"ow_9_2")
	await walk_start_to(Vector2(960, 528))
	await walk_start_to(Vector2(720, 528))
	await walk_start_to(Vector2(720, 336))
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"cave_4_1", "walking enters C4 through its real mouth")
	check(not player.is_dead(), "walking enters C4 alive")
	print("C4 entry health=%d pots=%d" % [GameState.health, GameState.pitch_pots])
	# Let the entry encounter settle before crossing the forecourt.
	await seconds(2.0)
	await walk_c4_boss()
	check(
		(
			GameState.has_fragment(&"c1")
			and GameState.has_fragment(&"c2")
			and GameState.has_fragment(&"c3")
		),
		"walking retains all three fragments"
	)
	print("C5 progress: room=%s health=%d" % [world.get_current_room_id(), GameState.health])


func walk_c4_boss() -> void:
	await walk_start_to(Vector2(720, 800))
	await walk_start_to(Vector2(1700, 800))
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"cave_4_2")
	await walk_start_to(Vector2(1200, 480))
	await seconds(0.4)
	for cycle in range(5):
		if GameState.active_item == &"tallow_sling":
			break
		Input.action_press(&"cycle_item")
		await frames(2)
		Input.action_release(&"cycle_item")
		await frames(2)
	Input.action_press(&"move_up")
	await frames(2)
	Input.action_release(&"move_up")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await seconds(0.7)
	check(GameState.has_flag(&"eye_e172"), "walking opens the C4 eye gate with the earned sling")
	await walk_start_to(Vector2(960, 180))
	await walk_start_cross(&"move_up", &"cave_4_3")
	await walk_start_to(Vector2(912, 336))
	await frames(5)
	check_eq(GameState.keys_in(&"c4"), 1, "walking collects the first C4 key")
	check(not player.is_dead(), "walking collects the C4 key alive")
	await walk_start_to(Vector2(960, 780))
	await walk_start_cross(&"move_down", &"cave_4_2")
	await walk_start_to(Vector2(960, 150))
	await walk_start_to(Vector2(1680, 150))
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"cave_4_4")
	check(GameState.has_flag(&"door_e173"), "walking opens the C4 first lock")
	check_eq(GameState.keys_in(&"c4"), 0, "walking spends the earned C4 key")
	check(not player.is_dead(), "walking reaches the C4 miniboss alive")
	await walk_start_to(Vector2(200, 150))
	await walk_start_to(Vector2(1700, 150))
	await walk_start_to(Vector2(1700, 480))
	await walk_start_cross(&"move_right", &"cave_4_5")
	check(not GameState.has_flag(&"mini_cave_4_4"), "walking passes the active C4 miniboss")
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(1392, 480))
	await walk_start_to(Vector2(1392, 410))
	await frames(5)
	check(GameState.has_item(&"heft_mitts"), "walking collects the C4 mitts")
	check(not player.is_dead(), "walking collects the C4 mitts alive")
	await walk_start_to(Vector2(960, 150))
	for cycle in range(6):
		if GameState.active_item == &"heft_mitts":
			break
		Input.action_press(&"cycle_item")
		await frames(2)
		Input.action_release(&"cycle_item")
		await frames(2)
	await seconds(0.4)
	Input.action_press(&"move_up")
	await frames(2)
	Input.action_release(&"move_up")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await frames(22)
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await seconds(1.0)
	check(
		GameState.has_flag(&"moved_e175"), "walking uses the earned mitts to remove the heavy stone"
	)
	await walk_start_cross(&"move_up", &"cave_4_6")
	await walk_start_to(Vector2(912, 400))
	await walk_start_to(Vector2(912, 315))
	await frames(5)
	check_eq(GameState.keys_in(&"c4"), 1, "walking collects the second C4 key")
	check(not player.is_dead(), "walking reaches the C4 vault alive")
	await walk_start_to(Vector2(960, 780))
	await walk_start_cross(&"move_down", &"cave_4_5")
	await walk_start_to(Vector2(960, 780))
	await walk_start_cross(&"move_down", &"cave_4_7")
	await walk_start_to(Vector2(650, 400))
	await walk_start_to(Vector2(650, 800))
	await walk_start_to(Vector2(1680, 800))
	await walk_start_to(Vector2(1680, 480))
	await walk_start_cross(&"move_right", &"cave_4_8")
	check(GameState.has_flag(&"door_e177"), "walking opens the second C4 lock")
	check_eq(GameState.keys_in(&"c4"), 0, "walking spends the second C4 key")
	await walk_start_to(Vector2(1200, 528))
	await walk_start_to(Vector2(1392, 528))
	await walk_start_to(Vector2(1392, 510))
	await frames(5)
	check(GameState.has_big_key(&"c4"), "walking collects the C4 Lockpick")
	check(not player.is_dead(), "walking collects the C4 Lockpick alive")
	await walk_start_to(Vector2(1200, 528))
	await walk_start_to(Vector2(200, 480))
	await walk_start_cross(&"move_left", &"cave_4_7")
	await walk_start_to(Vector2(1488, 450))
	await seconds(0.4)
	Input.action_press(&"move_up")
	await frames(2)
	Input.action_release(&"move_up")
	Input.action_press(&"attack")
	await seconds(0.9)
	Input.action_release(&"attack")
	await frames(10)
	if not GameState.has_flag(&"melted_e180"):
		await walk_start_to(Vector2(1488, 450))
		await seconds(0.4)
		Input.action_press(&"move_up")
		await frames(2)
		Input.action_release(&"move_up")
		Input.action_press(&"attack")
		await seconds(0.9)
		Input.action_release(&"attack")
		await frames(10)
	check(GameState.has_flag(&"melted_e180"), "walking melts the C4 cache seal")
	await walk_start_to(Vector2(1488, 240))
	await seconds(0.5)
	check_eq(world.get_current_room_id(), &"cave_4_7#seal", "walking enters the C4 cache")
	await walk_start_to(Vector2(912, 336))
	await frames(5)
	check(
		GameState.has_flag(&"picked_cache_cave_4_7_pots"), "walking collects the cache pot bundle"
	)
	check_eq(GameState.pitch_pots, 10, "walking collects actual C4 cache resupply")
	await walk_start_to(Vector2(912, 672))
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"cave_4_7", "walking exits the C4 cache")
	await walk_fast_to(Vector2(960, 432))
	await walk_fast_to(Vector2(200, 480))
	await walk_start_cross(&"move_left", &"cave_4_9")
	await farm_c4_antechamber()
	for repeat in range(20):
		if GameState.health >= GameState.max_health:
			break
		await walk_start_to(Vector2(1200, 480))
		await walk_start_to(Vector2(1700, 480))
		await walk_start_cross(&"move_right", &"cave_4_7")
		await walk_fast_to(Vector2(200, 480), true)
		await walk_start_cross(&"move_left", &"cave_4_9")
		print("FARM revisit=%d health=%d" % [repeat + 1, GameState.health])
		await farm_c4_antechamber()
	check(GameState.health >= 16, "earned C4 enemy drops restore full health")
	await walk_fast_to(Vector2(960, 780), true)
	await walk_start_cross(&"move_down", &"cave_4_10")
	check(GameState.has_flag(&"door_boss_c4"), "walking opens the C4 boss door")
	check(not player.is_dead(), "walking reaches the C4 boss alive")
	check(GameState.has_big_key(&"c4"), "walking retains the C4 Lockpick")
	check(not GameState.has_flag(&"mini_cave_4_4"), "C4 miniboss remains undefeated")
	var boss = world.current_room.get_node("Enemies/HushedColossus1")
	var initial_boss_hp: int = boss.hp
	var initial_pots := GameState.pitch_pots
	await walk_start_to(Vector2(960, 300))
	for cycle in range(6):
		if GameState.active_item == &"pitch_pot":
			break
		Input.action_press(&"cycle_item")
		await frames(2)
		Input.action_release(&"cycle_item")
		await frames(2)
	Input.action_press(&"move_down")
	await frames(2)
	Input.action_release(&"move_down")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await walk_start_to(Vector2(600, 300))
	await seconds(1.5)
	check_eq(GameState.pitch_pots, initial_pots - 1, "walking spends an earned pot against C4 boss")
	check_eq(boss.hp, initial_boss_hp - 2, "walking's actual pot damages the C4 boss")
	check(not player.is_dead(), "walking survives the first C4 boss hit")
	check(GameState.health >= 16, "walking retains full health after the first C4 boss hit")
	check_eq(GameState.pitch_pots, 9, "walking retains the earned C4 cache pots")
	await fight_c4_probe(boss)
	check(GameState.has_flag(&"boss_cave_4_10_defeated"), "C4 boss defeated")
	if GameState.has_flag(&"boss_cave_4_10_defeated") and not player.is_dead():
		await seconds(2.0)
		await walk_start_to(Vector2(864, 480))
		await walk_start_to(Vector2(1056, 480))
		await frames(10)
		check(GameState.has_fragment(&"c4"), "C4 fragment collected")
		check(GameState.has_flag(&"picked_wick_core_c4"), "C4 wick core collected")
		await walk_toward_c5()


func walk_toward_c5() -> void:
	await walk_start_to(Vector2(960, 180))
	await walk_start_cross(&"move_up", &"cave_4_9")
	await walk_fast_to(Vector2(1680, 480), true)
	await walk_start_cross(&"move_right", &"cave_4_7")
	await walk_fast_to(Vector2(960, 180), true)
	await walk_start_cross(&"move_up", &"cave_4_5")
	await walk_start_to(Vector2(960, 150))
	await walk_start_to(Vector2(200, 150))
	await walk_start_to(Vector2(200, 480))
	await walk_start_cross(&"move_left", &"cave_4_4")
	await walk_start_to(Vector2(1700, 150))
	await walk_start_to(Vector2(200, 150))
	await walk_start_to(Vector2(200, 480))
	await walk_start_cross(&"move_left", &"cave_4_2")
	await walk_start_to(Vector2(1700, 150))
	await walk_start_to(Vector2(200, 150))
	await walk_start_to(Vector2(200, 480))
	await walk_start_cross(&"move_left", &"cave_4_1")
	await walk_start_to(Vector2(960, 800))
	await walk_start_to(Vector2(720, 800))
	await walk_start_to(Vector2(720, 528))
	await walk_start_to(Vector2(528, 528))
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"ow_9_2", "walking exits C4 after victory")
	await walk_start_to(Vector2(720, 720))
	await walk_start_to(Vector2(1100, 720))
	await walk_start_to(Vector2(960, 480))
	await walk_start_to(Vector2(960, 180))
	await walk_start_cross(&"move_up", &"ow_9_1")
	await walk_start_to(Vector2(200, 480))
	await walk_start_cross(&"move_left", &"ow_8_1")
	await walk_start_to(Vector2(200, 480))
	await walk_start_cross(&"move_left", &"ow_7_1")
	await walk_start_to(Vector2(200, 480))
	await walk_start_cross(&"move_left", &"ow_6_1")
	await walk_start_to(Vector2(960, 600))
	await walk_start_to(Vector2(960, 760))
	for cycle in range(6):
		if GameState.active_item == &"reed_raft":
			break
		Input.action_press(&"cycle_item")
		await frames(2)
		Input.action_release(&"cycle_item")
		await frames(2)
	await seconds(0.5)
	await walk_raft_cross(&"ow_6_2")
	await walk_start_to(Vector2(960, 760))
	await seconds(0.5)
	await walk_raft_cross(&"ow_6_3")
	await walk_start_to(Vector2(816, 432))
	await walk_start_to(Vector2(816, 336))
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"cave_5_1", "walking enters C5 by its actual mouth")
	check(GameState.has_flag(&"mouth_c5"), "walking records the C5 mouth")
	check(GameState.has_fragment(&"c4"), "walking retains the earned C4 fragment")
	check(not player.is_dead(), "walking reaches C5 alive")
	print(
		(
			"C5 entry room=%s health=%d/%d pots=%d"
			% [
				world.get_current_room_id(),
				GameState.health,
				GameState.max_health,
				GameState.pitch_pots
			]
		)
	)
	# Wait for the active foyer enemies to trigger the ordinary C5 checkpoint respawn.
	for tick in range(5000):
		await frames(1)
		if player.is_dead():
			break
	check(player.is_dead(), "active C5 enemies trigger normal respawn")
	for tick in range(600):
		await frames(1)
		if not player.is_dead() and world.get_current_room_id() == &"ow_6_3":
			break
	check_eq(world.get_current_room_id(), &"ow_6_3", "normal respawn returns to C5 mouth")
	check_eq(GameState.health, 18, "normal respawn restores earned health")
	await walk_start_to(Vector2(200, 700))
	await walk_start_to(Vector2(300, 780))
	await walk_start_to(Vector2(900, 780))
	await walk_start_to(Vector2(960, 700))
	await walk_start_to(Vector2(960, 432))
	await walk_start_to(Vector2(816, 432))
	await walk_start_to(Vector2(816, 336))
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"cave_5_1", "walking re-enters C5 after respawn")
	if world.get_current_room_id() == &"cave_5_1" and not player.is_dead():
		await walk_start_to(Vector2(960, 480))
		await walk_start_to(Vector2(200, 480))
		await walk_start_cross(&"move_left", &"cave_5_2")
		await walk_start_to(Vector2(960, 200))
		await walk_start_swing_up()
		await walk_start_to(Vector2(960, 150))
		await walk_start_cross(&"move_up", &"cave_5_3")
		await walk_start_to(Vector2(1008, 336))
		await frames(5)
		check_eq(GameState.keys_in(&"c5"), 1, "walking collects the first C5 key")
		print("C5 key health=%d" % GameState.health)
		await walk_start_to(Vector2(960, 760))
		Input.action_press(&"move_down")
		await frames(2)
		Input.action_release(&"move_down")
		Input.action_press(&"attack")
		await frames(2)
		Input.action_release(&"attack")
		await frames(20)
		await walk_start_cross(&"move_down", &"cave_5_2")
		await walk_start_to(Vector2(200, 480))
		await walk_start_cross(&"move_left", &"cave_5_4")
		check(GameState.has_flag(&"door_e183"), "walking opens the first C5 lock")
		check_eq(GameState.keys_in(&"c5"), 0, "walking spends the first C5 key")
		print("C5 warden entry health=%d" % GameState.health)
		await walk_start_to(Vector2(1550, 150))
		await walk_start_to(Vector2(200, 150))
		await walk_start_to(Vector2(200, 480))
		await walk_start_cross(&"move_left", &"cave_5_5")
		await walk_start_to(Vector2(1450, 600))
		await walk_start_to(Vector2(1296, 510))
		await frames(5)
		check(GameState.has_item(&"glow_jar"), "walking collects the C5 glow jar")
		check(not player.is_dead(), "walking collects the C5 jar alive")
		print(
			(
				"C5 jar room=%s health=%d/%d"
				% [world.get_current_room_id(), GameState.health, GameState.max_health]
			)
		)
		await walk_start_to(Vector2(960, 432))
		for cycle in range(8):
			if GameState.active_item == &"glow_jar":
				break
			Input.action_press(&"cycle_item")
			await frames(2)
			Input.action_release(&"cycle_item")
			await frames(2)
		Input.action_press(&"move_up")
		await frames(2)
		Input.action_release(&"move_up")
		Input.action_press(&"use_item")
		await frames(2)
		Input.action_release(&"use_item")
		await seconds(1.8)
		check(
			GameState.has_flag(&"revealed_e185"), "walking reveals the C5 seam with the earned jar"
		)
		await walk_start_to(Vector2(960, 180))
		await walk_start_cross(&"move_up", &"cave_5_6")
		await walk_start_to(Vector2(1008, 240))
		await frames(5)
		check_eq(GameState.keys_in(&"c5"), 1, "walking collects the second C5 key")
		check(not player.is_dead(), "walking collects the second C5 key alive")
		print("C5 second key room=%s health=%d" % [world.get_current_room_id(), GameState.health])
		await walk_fast_to(Vector2(960, 780), true)
		await walk_start_cross(&"move_down", &"cave_5_5")
		await walk_fast_to(Vector2(960, 780), true)
		await walk_start_cross(&"move_down", &"cave_5_7")
		await walk_fast_to(Vector2(960, 480), true)
		await walk_fast_to(Vector2(200, 480), true)
		await walk_start_cross(&"move_left", &"cave_5_8")
		check(GameState.has_flag(&"door_e187"), "walking opens the C5 vault")
		check_eq(GameState.keys_in(&"c5"), 0, "walking spends the second C5 key")
		await walk_fast_to(Vector2(500, 550), true)
		await walk_start_to(Vector2(432, 510))
		await frames(5)
		check(GameState.has_big_key(&"c5"), "walking collects the C5 Lockpick")
		check(not player.is_dead(), "walking collects the C5 Lockpick alive")
		print("C5 lockpick room=%s health=%d" % [world.get_current_room_id(), GameState.health])


func farm_c4_antechamber() -> void:
	for cycle in range(6):
		if GameState.active_item == &"cinder_wick":
			break
		Input.action_press(&"cycle_item")
		await frames(2)
		Input.action_release(&"cycle_item")
		await frames(2)
	var last_cast := -400
	var deaths := 0
	var last_enemy_count := world.current_room.get_enemies().size()
	var last_health := GameState.health
	var last_pots := GameState.pitch_pots
	for tick in range(2400):
		if player.is_dead():
			break
		var candidates := world.current_room.get_enemies()
		var enemy: Node2D = null
		var best := 100000.0
		for e in candidates:
			if not is_instance_valid(e) or e.is_dead:
				continue
			var dist: float = e.global_position.distance_to(player.global_position)
			if dist < best:
				enemy = e
				best = dist
		if candidates.size() < last_enemy_count:
			deaths += last_enemy_count - candidates.size()
			last_enemy_count = candidates.size()
		var pickup: PickupBase = null
		for n in get_tree().get_nodes_in_group(&"pickups"):
			if (
				n is PickupBase
				and n.timeout > 0
				and not n.is_collected
				and n.global_position.distance_to(player.global_position) < 500
			):
				pickup = n
				break
		if enemy == null and pickup == null:
			break
		var motion := Vector2.ZERO
		release_inputs()
		if pickup != null and (enemy == null or best > 180):
			motion = (pickup.global_position - player.global_position).normalized()
		elif enemy != null:
			var d: Vector2 = enemy.global_position - player.global_position
			if tick - last_cast > 230 and d.length() < 330 and minf(absf(d.x), absf(d.y)) < 50:
				if absf(d.x) > absf(d.y):
					Input.action_press(&"move_right" if d.x > 0 else &"move_left")
				else:
					Input.action_press(&"move_down" if d.y > 0 else &"move_up")
				await frames(1)
				Input.action_press(&"use_item")
				last_cast = tick
			else:
				motion = (
					d.normalized().orthogonal()
					+ d.normalized() * clampf((d.length() - 250.0) / 100.0, -2.0, 2.0)
				)
		if absf(motion.x) > 0.2:
			Input.action_press(&"move_right" if motion.x > 0 else &"move_left")
		if absf(motion.y) > 0.2:
			Input.action_press(&"move_down" if motion.y > 0 else &"move_up")
		await frames(1)
		if GameState.health != last_health or GameState.pitch_pots != last_pots:
			print(
				(
					"FARM tick=%d kills=%d health=%d pots=%d"
					% [tick, deaths, GameState.health, GameState.pitch_pots]
				)
			)
			last_health = GameState.health
			last_pots = GameState.pitch_pots
	release_inputs()
	print(
		(
			"FARM end kills=%d health=%d pots=%d room=%s"
			% [deaths, GameState.health, GameState.pitch_pots, world.get_current_room_id()]
		)
	)


func fight_c4_probe(boss: Node2D) -> void:
	for cycle in range(6):
		if GameState.active_item == &"heft_mitts":
			break
		Input.action_press(&"cycle_item")
		await frames(2)
		Input.action_release(&"cycle_item")
		await frames(2)
	var cooldown := 0
	var last_hp: int = boss.hp
	var last_health := GameState.health
	var pot_cooldown := 0
	var slam_ref: Node2D = null
	var escape := Vector2.ZERO
	var phase3_escape := Vector2.ZERO
	for tick in range(18000):
		if (
			player.is_dead()
			or not is_instance_valid(boss)
			or world.get_current_room_id() != &"cave_4_10"
		):
			break
		if boss.is_dead or boss.is_dying():
			break
		var pot_mode: bool = boss.phase >= 2 and GameState.pitch_pots > 0
		var wanted: StringName = &"pitch_pot" if pot_mode else &"heft_mitts"
		if GameState.active_item != wanted:
			release_inputs()
			Input.action_press(&"cycle_item")
			await frames(2)
			Input.action_release(&"cycle_item")
			await frames(2)
			continue
		if pot_cooldown > 0:
			pot_cooldown -= 1
		var pos: Vector2 = player.global_position
		var bp: Vector2 = boss.global_position
		var delta: Vector2 = bp - pos
		var carried: Node2D = null
		var nearest: Node2D = null
		var nearest_dist := 100000.0
		for shard in boss.shards:
			if not is_instance_valid(shard) or shard.is_queued_for_deletion():
				continue
			if shard.state == shard.State.CARRIED:
				carried = shard
			elif shard.state == shard.State.LYING:
				var d: float = pos.distance_to(shard.global_position)
				if d < nearest_dist and shard.global_position.distance_to(bp) > 240:
					nearest = shard
					nearest_dist = d
		var motion := Vector2.ZERO
		var use := false
		if carried != null:
			if boss.phase == 3 and boss.slam_left < 1.7:
				motion = (
					Vector2(signf(delta.x), 0)
					if absf(delta.x) > absf(delta.y)
					else Vector2(0, signf(delta.y))
				)
				use = true
			elif (
				delta.length() < 490
				and delta.length() > 190
				and minf(absf(delta.x), absf(delta.y)) < 55
			):
				motion = (
					Vector2(signf(delta.x), 0)
					if absf(delta.x) > absf(delta.y)
					else Vector2(0, signf(delta.y))
				)
				use = true
			else:
				var aim := (
					Vector2(bp.x, pos.y) if absf(delta.x) < absf(delta.y) else Vector2(pos.x, bp.y)
				)
				motion = (aim - pos).normalized()
		elif nearest != null and delta.length() > 230:
			var sd: Vector2 = nearest.global_position - pos
			motion = sd.normalized()
			if sd.length() < 110 and boss.slam_left > (0.0 if boss.phase == 3 else 1.8):
				motion = (
					Vector2(signf(sd.x), 0) if absf(sd.x) > absf(sd.y) else Vector2(0, signf(sd.y))
				)
				use = true
		else:
			motion = delta.normalized().rotated(-PI / 2)
			if delta.length() < 380:
				motion -= delta.normalized()
		if pot_mode:
			motion = (
				delta.normalized().orthogonal()
				- delta.normalized() * clampf((360.0 - delta.length()) / 100.0, -1.0, 2.0)
			)
			if pot_cooldown > 35:
				motion = -delta.normalized()
			use = false
			if delta.length() < 340 and delta.length() > 235 and pot_cooldown == 0:
				motion = (
					Vector2(signf(delta.x), 0)
					if absf(delta.x) > absf(delta.y)
					else Vector2(0, signf(delta.y))
				)
				use = true
		if delta.length() < 190:
			motion += -delta.normalized() * 3.0
			use = false
		var slam_danger := false
		for hazard in boss._hazards:
			if not is_instance_valid(hazard) or hazard.is_queued_for_deletion():
				continue
			if not ("kind" in hazard):
				continue
			if hazard.kind in [&"slam", &"ring"]:
				slam_danger = true
			if hazard.kind == &"slam" and not hazard.fired:
				if slam_ref != hazard:
					slam_ref = hazard
					escape = Vector2.ZERO
					var score_best := -100000.0
					for i in range(8):
						var dir := Vector2.from_angle(TAU * i / 8.0)
						var query := PhysicsRayQueryParameters2D.create(
							pos, pos + dir * 420, Layers.WORLD
						)
						var hit := player.get_world_2d().direct_space_state.intersect_ray(query)
						var clearance := 420.0 if hit.is_empty() else pos.distance_to(hit.position)
						var predicted := (pos + dir * minf(clearance, 300)).distance_to(bp)
						var score := clearance + minf(predicted, 300.0) * 0.6
						if score > score_best:
							score_best = score
							escape = dir
				motion = escape * 20.0
				use = false
			if hazard.kind == &"fall" and not hazard.fired:
				var away: Vector2 = pos - hazard.global_position
				var radius := 290.0 if hazard.kind == &"slam" else 130.0
				if away.length() < radius:
					motion = (
						(away.normalized() if away.length() > 10 else motion.normalized()) * 10.0
					)
					use = false
			if hazard.kind == &"ring":
				var away: Vector2 = pos - hazard.global_position
				if away.length() < 340:
					motion = escape * 20.0
					use = false
			if hazard.kind == &"sweep" and hazard.age > 0.5:
				use = false
		var local: Vector2 = pos - world.current_room.global_position
		if local.x < 260:
			motion.x += (260 - local.x) / 25.0
		if local.x > 1660:
			motion.x -= (local.x - 1660) / 25.0
		if local.y < 230:
			motion.y += (230 - local.y) / 25.0
		if local.y > 730:
			motion.y -= (local.y - 730) / 25.0
		if boss.phase == 3:
			if boss.slam_left < 0.0 or boss.combo_count > 0 or slam_danger:
				if phase3_escape != Vector2.ZERO:
					var ahead := PhysicsRayQueryParameters2D.create(
						pos, pos + phase3_escape * 120, Layers.WORLD
					)
					if not player.get_world_2d().direct_space_state.intersect_ray(ahead).is_empty():
						phase3_escape = Vector2.ZERO
				if phase3_escape == Vector2.ZERO:
					var best_score := -INF
					for direction in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
						var query := PhysicsRayQueryParameters2D.create(
							pos, pos + direction * 700, Layers.WORLD
						)
						var hit := player.get_world_2d().direct_space_state.intersect_ray(query)
						var clear := 700.0 if hit.is_empty() else pos.distance_to(hit.position)
						var score := (
							clear
							+ minf((pos + direction * minf(clear, 300.0)).distance_to(bp), 350.0)
						)
						if score > best_score:
							best_score = score
							phase3_escape = direction
				motion = phase3_escape * 20.0
				use = false
			else:
				phase3_escape = Vector2.ZERO
			for item in get_tree().get_nodes_in_group(&"items"):
				if (
					"item_id" in item
					and item.item_id == &"pitch_pot"
					and "_fuse" in item
					and item._fuse < 0.7
				):
					var away: Vector2 = pos - item.global_position
					if away.length() < 230:
						motion = away.normalized() * 20.0
						use = false
		for quake in boss._hazards:
			if (
				not is_instance_valid(quake)
				or not ("kind" in quake)
				or quake.kind != &"quake"
				or quake.fired
			):
				continue
			var best_tile := Vector2.ZERO
			var best_score := INF
			for row in range(1, 9):
				for col in range(1, 19):
					if (row + col) % 2 == quake.parity:
						continue
					var tile := Vector2(col * 96 + 48, row * 96 + 48)
					var dist := local.distance_to(tile)
					if dist > 240:
						continue
					var risk := 0.0
					for threat in boss._hazards:
						if (
							is_instance_valid(threat)
							and "kind" in threat
							and threat.kind in [&"slam", &"fall"]
							and not threat.fired
						):
							var safe_dist := 200.0 if threat.kind == &"slam" else 120.0
							if (
								(world.current_room.global_position + tile).distance_to(
									threat.global_position
								)
								< safe_dist
							):
								risk += 500.0
					if (world.current_room.global_position + tile).distance_to(bp) < 180:
						risk += 500.0
					if dist + risk < best_score:
						best_score = dist + risk
						best_tile = tile
			if best_score < INF:
				motion = (
					(best_tile - local).normalized() * 20.0 if best_score > 10 else Vector2.ZERO
				)
				use = false
		release_inputs()
		if absf(motion.x) > 0.25:
			Input.action_press(&"move_right" if motion.x > 0 else &"move_left")
		if absf(motion.y) > 0.25:
			Input.action_press(&"move_down" if motion.y > 0 else &"move_up")
		if cooldown > 0:
			cooldown -= 1
		if use and cooldown == 0:
			await frames(2)
			Input.action_press(&"use_item")
			cooldown = 30
			if pot_mode:
				pot_cooldown = 70
		await frames(1)
		if not is_instance_valid(boss) or world.get_current_room_id() != &"cave_4_10":
			break
		if boss.hp != last_hp or GameState.health != last_health:
			print(
				(
					"PROBE tick=%d boss=%d health=%d pos=%s carried=%s"
					% [tick, boss.hp, GameState.health, local, carried != null]
				)
			)
			for h in boss._hazards:
				if is_instance_valid(h) and "kind" in h:
					print(
						(
							"  hazard %s age %.2f distance %.1f"
							% [h.kind, h.age, pos.distance_to(h.global_position)]
						)
					)
			last_hp = boss.hp
			last_health = GameState.health
	release_inputs()
	print(
		(
			"PROBE end boss=%s health=%d dead=%s room=%s"
			% [
				boss.hp if is_instance_valid(boss) else "unloaded",
				GameState.health,
				player.is_dead(),
				world.get_current_room_id()
			]
		)
	)


func walk_fast_to(target: Vector2, avoid_enemies: bool = false) -> void:
	var room := world.current_room
	for tick in range(900):
		var diff := target - (player.global_position - room.global_position)
		if diff.length() < 12 or player.is_dead() or world.current_room != room:
			break
		var motion := diff.normalized()
		if avoid_enemies:
			for enemy in room.get_enemies():
				if not is_instance_valid(enemy) or enemy.is_dead:
					continue
				var away: Vector2 = player.global_position - enemy.global_position
				if away.length() < 240:
					motion += away.normalized() * (240 - away.length()) / 60.0
		release_inputs()
		if absf(motion.x) > 0.2:
			Input.action_press(&"move_right" if motion.x > 0 else &"move_left")
		if absf(motion.y) > 0.2:
			Input.action_press(&"move_down" if motion.y > 0 else &"move_up")
		await frames(1)
	release_inputs()
	check(
		(
			world.current_room != room
			or (target - (player.global_position - room.global_position)).length() < 18
		),
		"fast walk reaches %s" % target
	)


func walk_raft_cross(target: StringName) -> void:
	check_eq(GameState.active_item, &"reed_raft", "earned raft is selected")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	for tick in range(600):
		await frames(1)
		if world.get_current_room_id() == target and not player.is_external_motion():
			break
	check_eq(world.get_current_room_id(), target, "earned raft crosses to " + String(target))
	check(not player.is_external_motion(), "earned raft lands at " + String(target))


func walk_start_swing_up() -> void:
	Input.action_press(&"move_up")
	await frames(2)
	Input.action_release(&"move_up")
	Input.action_press(&"attack")
	await frames(2)
	Input.action_release(&"attack")
	await frames(14)


func walk_start_to(target: Vector2) -> void:
	var room := world.get_room(world.get_current_room_id())
	var room_id := room.room_id
	var origin := room.global_position
	for tick in range(500):
		var diff := target - (player.global_position - origin)
		if diff.length() < 12.0 or player.is_dead() or world.get_current_room_id() != room_id:
			break
		release_inputs()
		if absf(diff.x) > 6.0:
			Input.action_press(&"move_right" if diff.x > 0 else &"move_left")
		if absf(diff.y) > 6.0:
			Input.action_press(&"move_down" if diff.y > 0 else &"move_up")
		if tick % 30 == 0:
			Input.action_press(&"attack")
		await frames(1)
	release_inputs()
	check(
		(
			world.get_current_room_id() != room_id
			or (target - (player.global_position - origin)).length() < 18.0
		),
		"walking reaches %s in %s (at %s)" % [target, room_id, player.global_position - origin]
	)


func walk_start_cross(action: StringName, target: StringName) -> void:
	Input.action_press(action)
	for tick in range(240):
		await frames(1)
		if world.get_current_room_id() == target or player.is_dead():
			break
	release_inputs()
	await seconds(0.4)
	check_eq(world.get_current_room_id(), target, "walking crosses to " + String(target))


func save_and_reload() -> bool:
	var isolated := OS.get_environment("XDG_DATA_HOME")
	var safe := isolated.begins_with("/tmp/wickwarden-check-")
	safe = safe and OS.get_user_data_dir().begins_with(isolated + "/")
	check(safe, "disk roundtrip requires the isolated test runner userdata")
	if not safe:
		return false
	var before := summary()
	SaveGame.enabled = true
	var saved := SaveGame.save()
	check(saved, "earned C1 state saves")
	if not saved:
		SaveGame.enabled = false
		return false
	reset_state()
	var loaded := SaveGame.load_into_state()
	check(loaded, "earned C1 state reloads")
	if loaded:
		check_eq(summary(), before, "earned state survives the save roundtrip")
	SaveGame.enabled = false
	return loaded


func cave_two() -> void:
	var room := await enter(&"ow_5_1")
	for node in room.get_node("Props").get_children():
		if node is RoomDoor and node.target_room == &"cave_2_1":
			player.place_at(node.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_2_1", "actual C2 mouth opens")
	room = await enter(&"cave_2_2")
	var thorn = scripted(room, "burnable.gd")
	await cast(thorn, &"cinder_wick", Vector2.UP, 180)
	await seconds(1.6)
	check(thorn.is_open, "earned wick opens C2 thorn gate")
	player.place_at(room.global_position + Vector2(960, 200))
	await cross(&"move_up", &"cave_2_3")
	room = world.get_room(&"cave_2_3")
	await collect(room, &"key_c2_1")
	player.place_at(room.global_position + Vector2(960, 740))
	await cross(&"move_down", &"cave_2_2")
	room = world.get_room(&"cave_2_2")
	await contact(scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check_eq(GameState.keys_in(&"c2"), 0, "first C2 door spends the earned key")
	await cross(&"move_right", &"cave_2_4")
	room = world.get_room(&"cave_2_4")
	await warden(room)
	player.place_at(room.global_position + Vector2(1680, 480))
	await cross(&"move_right", &"cave_2_5")
	room = world.get_room(&"cave_2_5")
	await collect(room, &"tallow_sling")
	check(GameState.has_item(&"tallow_sling"), "C2 pedestal grants the real sling")
	player.place_at(room.global_position + Vector2(960, 200))
	await cross(&"move_up", &"cave_2_6")
	room = world.get_room(&"cave_2_6")
	await collect(room, &"key_c2_2")
	await collect(room, &"slug_bundle_cave_2_6")
	var eye = eye_switch(room)
	await cast(eye, &"tallow_sling", Vector2.RIGHT, 140)
	await seconds(0.5)
	check(eye.is_on, "earned sling opens the C2 eye")
	player.place_at(room.global_position + Vector2(1680, 528))
	await cross(&"move_right", &"cave_2_7")
	room = world.get_room(&"cave_2_7")
	await collect(room, &"bigkey_c2")
	check(GameState.has_big_key(&"c2"), "C2 Lockpick is collected")
	room = await enter(&"cave_2_5")
	await contact(scripted(room, "locked_door.gd"), Vector2.DOWN)
	check_eq(GameState.keys_in(&"c2"), 1, "Lockpick retains the second key")
	await cross(&"move_down", &"cave_2_8")
	room = world.get_room(&"cave_2_8")
	await contact(scripted(room, "boss_door.gd"), Vector2.RIGHT)
	# The inherited boss probe tests the naturally spawned low-ammo refill.
	for shot in range(GameState.slugs - 7):
		player.place_at(room.global_position + Vector2(1400, 480))
		player.facing = Vector2.UP
		GameState.set_active_item(&"tallow_sling")
		check(player.use_item(), "real shot spends sling ammo")
		await seconds(0.8)
	player.place_at(room.global_position + Vector2(1800, 480))
	await cross(&"move_right", &"cave_2_9")
	await mother(world.get_room(&"cave_2_9"))
