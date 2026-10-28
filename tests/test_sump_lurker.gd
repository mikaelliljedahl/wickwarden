extends TestCase
## Real tool collisions plus bounded state timing. No saves or all-tools loadout.

const SCENE := "res://scenes/enemies/minibosses/sump_lurker.tscn"
const ZONE := "res://scenes/world/shallow_zone.tscn"


func run() -> void:
	await _shore_cycle()
	await _bite_presentation()
	await _real_tools()
	await _real_bite_geometry()
	await _real_jet_and_ward()
	await _lifecycle()


func _zone(arena: Node, at := Vector2(900, 400)) -> Area2D:
	var scene := load(ZONE) as PackedScene
	check(scene != null, "M3 shallows scene loads")
	if scene == null:
		return null
	var zone := scene.instantiate() as Area2D
	zone.position = at
	zone.size = Vector2(600, 192)
	arena.add_child(zone)
	return zone


func _wait_state(enemy: EnemyBase, target: int, limit: int = 240) -> int:
	for i in range(limit):
		if enemy.state == target:
			return i
		await frames(1)
	check(false, "bounded wait reaches lurker state %s" % target)
	return limit


func _shore_cycle() -> void:
	reset_state()
	var foreign := make_arena()
	_zone(foreign, Vector2(900, 600))
	var arena := make_arena()
	var zone := _zone(arena)
	var enemy = make_enemy(arena, SCENE, Vector2(900, 400))
	var player := make_player(arena, Vector2(900, 680))
	await frames(2)
	check_eq(enemy.max_hp, 16, "HP16")
	check_eq(enemy.contact_damage, 3, "contact3")
	check_eq(enemy.knockback_scale, 0.5, "half hook knockback")
	check(enemy.has_node("Visual"), "Visual child")
	check(not enemy.hurtbox.enabled, "submerged hurtbox off")
	check_near(enemy.velocity.length(), 160, 0.1, "submerged glide160")
	await _wait_state(enemy, enemy.State.TELEGRAPH)
	check_eq(enemy._zone, zone, "selects only own room zone")
	check_eq(
		enemy._nearest_shore(zone, Vector2(900, 420)),
		Vector2(900, 496),
		"player inside pool still selects a shoreline"
	)
	check_near(enemy.global_position.y, 496, 4, "surfaces at nearest south pool edge")
	await _capture("lurker-warning")
	var elapsed := await _wait_state(enemy, enemy.State.SURFACED)
	check_near(elapsed, 42, 2, "bubble telegraph .7 seconds")
	check(enemy.hurtbox.enabled, "surfaced hurtbox on")
	check_eq(enemy._bite.damage, 3, "real bite damage3")
	check(not enemy._bite.blockable, "melee bite not ward blockable")
	check_near(enemy._bite.rotation, PI / 2, .01, "bite faces committed target")
	await _capture("lurker-surfaced")
	elapsed = await _wait_state(enemy, enemy.State.DIVE)
	check_near(elapsed, 90, 2, "surfaced1.5 seconds")
	check(not enemy.hurtbox.enabled, "dive hurtbox off")
	elapsed = await _wait_state(enemy, enemy.State.SUBMERGED)
	check_near(elapsed, 24, 2, "dive .4 seconds")
	check(zone.call("contains_point", enemy.global_position), "remains in pool")
	player.queue_free()
	await dispose(arena)
	await dispose(foreign)


func _real_bite_geometry() -> void:
	for inside in [true, false]:
		reset_state()
		var arena := make_arena()
		_zone(arena)
		var enemy = make_enemy(arena, SCENE, Vector2(900, 496))
		var player := make_player(arena, Vector2(900, 620))
		await frames(2)
		enemy.set_physics_process(false)
		enemy._enter(enemy.State.SURFACED, 1.5)
		enemy.set_facing_dir(Vector2.DOWN if inside else Vector2.RIGHT)
		player.facing = Vector2.UP
		Input.action_press(&"ward")
		enemy._bite_attack()
		await frames(6)
		check_eq(
			GameState.health,
			3 if inside else 6,
			"actual120-degree bite hits inside only and bypasses ward"
		)
		release_inputs()
		await dispose(arena)


func _bite_presentation() -> void:
	reset_state()
	var arena := make_arena()
	_zone(arena)
	var enemy = make_enemy(arena, SCENE, Vector2(900, 400))
	var player := make_player(arena, Vector2(1350, 400))
	player.set_hurtbox_enabled(self, false)
	await _wait_state(enemy, enemy.State.SURFACED)
	check(enemy.visual is SpriteVisual, "painted lurker visual is available")
	if enemy.visual is SpriteVisual:
		var sprite := enemy.visual as SpriteVisual
		check_eq(sprite.animation, &"bite", "natural east bite plays painted bite")
		check(not sprite.flip_h, "east bite faces right")
		check(enemy._bite.active, "bite art starts with active hitbox")
		await frames(4)
		check(sprite.frame > 0, "bite advances while hitbox is active")
		await frames(6)
		check(not enemy._bite.active, "bite hitbox ends at existing duration")
		check_eq(sprite.animation, &"idle", "painted bite returns to surfaced idle")
		check_near(sprite.speed_scale, 1.0, .001, "idle playback speed restored")
		enemy.set_physics_process(false)
		enemy.set_facing_dir(Vector2.LEFT)
		enemy._bite_attack()
		check_eq(sprite.animation, &"bite", "west bite uses painted bite")
		check(sprite.flip_h, "west bite is mirrored")
		enemy.stun(1.5)
		check_eq(sprite.animation, &"idle", "stun cancels bite presentation")
		enemy.reset_fight()
		enemy._enter(enemy.State.SURFACED, 1.5)
		enemy.set_facing_dir(Vector2.RIGHT)
		enemy._bite_attack()
		enemy.reset_fight()
		check_eq(sprite.animation, &"idle", "reset cancels active bite presentation")
		enemy._enter(enemy.State.SURFACED, 1.5)
		enemy.set_facing_dir(Vector2.DOWN)
		enemy._bite_attack()
		check_eq(sprite.animation, &"idle", "vertical bite avoids sideways pose")
		enemy.reset_fight()
		check_eq(sprite.animation, &"idle", "reset restores idle presentation")
	await dispose(arena)


func _real_tools() -> void:
	reset_state()
	var arena := make_arena()
	_zone(arena)
	var enemy = make_enemy(arena, SCENE, Vector2(900, 496))
	var player := make_player(arena, Vector2(900, 760))
	await frames(2)
	# Hold states to isolate actual collision acceptance; timings are tested above.
	enemy.set_physics_process(false)
	enemy._enter(enemy.State.SUBMERGED, 0.0)
	GameState.acquire_item(&"tether_moth")
	player.facing = Vector2.UP
	check(player.use_item(), "real moth launches at submerged lurker")
	await frames(65)
	check(not enemy.is_stunned(), "real moth cannot stun submerged lurker")
	check_eq(enemy.hp, 16, "submerged moth does not damage")
	player.place_at(Vector2(900, 586))
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 16, "real hook cannot hit submerged lurker")
	await frames(30)
	enemy._enter(enemy.State.SURFACED, 1.5)
	enemy.hurtbox.invulnerable = false
	player.place_at(Vector2(900, 760))
	player.facing = Vector2.UP
	check(player.use_item(), "real moth launches at surfaced lurker")
	await frames(19)
	check(enemy.is_stunned(), "real moth stuns surfaced lurker")
	check_near(enemy._stun_time, 1.5, .02, "surface moth clamp1.5")
	check(not enemy.contact_hitbox.active, "stunned lurker harmless")
	player.place_at(Vector2(900, 586))
	player.facing = Vector2.UP
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 14, "real hook deals2 in surfaced window")
	enemy.set_physics_process(true)
	await frames(110)
	enemy.stun(2.0)
	check(not enemy.is_stunned(), "post-stun immunity prevents chain stun")
	enemy.reset_fight()
	check_eq(enemy.hp, 16, "reset restores HP")
	check(not enemy.is_stunned() and not enemy.is_knocked_back(), "reset clears combat timers")
	check(not enemy.hurtbox.enabled, "reset returns to submerged immunity")
	await dispose(arena)


func _real_jet_and_ward() -> void:
	for ward in [true, false]:
		reset_state()
		var arena := make_arena()
		_zone(arena)
		var enemy = make_enemy(arena, SCENE, Vector2(900, 496))
		var player := make_player(arena, Vector2(900, 880))
		player.facing = Vector2.UP
		if ward:
			Input.action_press(&"ward")
		await frames(145)
		check_eq(get_tree().get_nodes_in_group(&"projectiles").size(), 0, "jet waits2.5 seconds")
		await frames(12)
		var projectiles := get_tree().get_nodes_in_group(&"projectiles")
		check_eq(projectiles.size(), 1, "far target causes real water jet")
		if projectiles.size() == 1:
			var jet := projectiles[0] as EnemyProjectile
			check_eq(jet.damage, 1, "water jet damage1")
			check_eq(jet.speed, 200.0, "water jet speed200")
			check(jet.hitbox.blockable, "water jet ward blockable")
			var visual := jet.get_node_or_null("Visual") as SpriteVisual
			check(visual != null, "water jet uses painted sprite")
			if visual != null:
				check_eq(visual.sprite_frames.get_frame_count(&"idle"), 2, "jet flight has two frames")
				check_near(visual.rotation, jet.direction.angle(), 0.001, "jet follows flight direction")
			var light := jet.get_node_or_null("WaterJetLight") as PointLight2D
			check(light != null and not light.is_in_group(&"glow_light"), "jet light is presentation only")
			check_near(jet.radius, 12.0, 0.001, "water jet collision radius unchanged")
			await _capture("lurker-jet")
			await frames(120)
			check(not is_instance_valid(jet), "real jet consumed on ward or hit")
		check_eq(
			GameState.health, 6 if ward else 5, "actual front ward blocks / unwarded jet hurts"
		)
		enemy.reset_fight()
		await frames(2)
		check_eq(
			get_tree().get_nodes_in_group(&"projectiles").size(), 0, "reset clears jet hazards"
		)
		release_inputs()
		await dispose(arena)


func _lifecycle() -> void:
	reset_state()
	var arena := make_arena()
	_zone(arena)
	var enemy = make_enemy(arena, SCENE, Vector2(900, 400))
	enemy.arena_id = &"cave_3_4"
	await frames(2)
	enemy._enter(enemy.State.SURFACED, 1.5)
	enemy.stun(1.5)
	enemy.apply_damage(99, enemy.global_position, 0.0)
	check(not enemy.is_stunned(), "lethal damage clears stun before death throes")
	check(GameState.has_flag(&"mini_cave_3_4"), "canonical persisted mini flag")
	check(not enemy.is_arena_locked(), "no arena lock")
	check(not enemy.contact_hitbox.active, "death contact disabled")
	await frames(100)
	var drops := arena.get_children().filter(func(n: Node) -> bool: return n is PickupBase)
	check_eq(drops.size(), 4, "exactly four fixed drops")
	var kinds: Array = []
	for drop in drops:
		kinds.append(drop.kind)
		check(drop.timeout > 0.0, "drops are timed")
	check_eq(kinds.count(&"ember"), 2, "two embers")
	check_eq(kinds.count(&"brass_coin"), 2, "two coins; no core or tool")
	var scene := load(SCENE) as PackedScene
	check(scene != null, "miniboss scene loads")
	if scene != null:
		var retired = scene.instantiate()
		retired.arena_id = &"cave_3_4"
		arena.add_child(retired)
		check(retired.is_dead and not retired.visible, "defeated miniboss retires on reload")
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
