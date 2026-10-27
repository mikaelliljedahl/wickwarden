extends TestCase
## EnemyBase: hit, hit flash, knockback, i-frames, stun, death, drops, confinement, contact damage.
## EnemyProjectile: walls, ward-independent behaviour, bounds. DropTable numbers.


class Counter:
	extends EnemyBase
	var physics_calls: int = 0
	var hurt_calls: int = 0
	var death_calls: int = 0
	var push: Vector2 = Vector2.ZERO

	func _enemy_physics(_delta: float) -> void:
		physics_calls += 1
		velocity = push

	func _on_hurt(_hitbox: Hitbox) -> void:
		hurt_calls += 1

	func _on_death() -> void:
		death_calls += 1


func run() -> void:
	await _hit_flash_knockback_iframes()
	await _guard_spark()
	await _stun()
	await _death_and_drops()
	await _drop_table()
	await _confinement()
	await _contact_damage()
	await _adopt()
	await _projectile()
	await _fire_projectile()


func _guard_spark() -> void:
	reset_state()
	var arena := make_arena()
	var enemy := Counter.new()
	enemy.max_hp = 6
	enemy.armor_front_deg = 140.0
	enemy.drops_enabled = false
	arena.add_child(enemy)
	enemy.global_position = Vector2(500, 500)
	enemy.set_facing_dir(Vector2.RIGHT)
	var hit := Hitbox.new()
	hit.team = Layers.Team.PLAYER
	hit.kind = &"hook"
	hit.damage = 2
	arena.add_child(hit)
	hit.global_position = Vector2(600, 500)
	await frames(2)
	var blocks := [0]
	enemy.guard_blocked.connect(func(_hitbox: Hitbox) -> void: blocks[0] += 1)
	enemy._on_hurtbox_hurt(hit)
	var spark := arena.get_node_or_null("Puff") as SpriteVisual
	check_eq(enemy.hp, 6, "guarded hit still causes no damage")
	check_eq(blocks[0], 1, "guarded hit still emits its signal")
	check(spark != null, "guard creates painted impact")
	if spark != null:
		check_eq(spark.animation, &"impact", "guard uses impact frames")
		check_near(spark.speed_scale, 1.5, 0.001, "impact retains quarter-second duration")
		check(spark.global_position.is_equal_approx(Vector2(528, 500)), "guard spark at body edge")
	await seconds(0.4)
	check(arena.get_node_or_null("Puff") == null, "painted guard spark frees itself")
	SpriteVisual.use_manifest("res://tests/fixtures/missing_guard_manifest.json")
	enemy._on_hurtbox_hurt(hit)
	check(arena.get_node_or_null("Puff") is Placeholder, "missing art uses visible fallback")
	check_eq(enemy.hp, 6, "missing art does not change guard damage")
	check_eq(blocks[0], 2, "missing art does not change guard signal")
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)
	await dispose(arena)


func _hit_flash_knockback_iframes() -> void:
	reset_state()
	var arena := make_arena()
	var enemy := Counter.new()
	enemy.max_hp = 6
	enemy.drops_enabled = false
	arena.add_child(enemy)
	enemy.global_position = Vector2(500, 500)
	await frames(2)
	var hit := make_hitbox(arena, Vector2(470, 500), Layers.Team.PLAYER, 1, 150.0)
	hit.once_per_target = false
	hit.knockback = 480.0
	hit.knockback_time = 0.12
	await frames(3)
	check_eq(enemy.hp, 5, "a hit deals its damage")
	check_eq(enemy.hurt_calls, 1, "_on_hurt hook is called once per hit")
	check(enemy.visual.modulate.r > 1.5, "enemy flashes white when hit")
	await frames(9)
	check(enemy.visual.modulate.r <= 1.0, "flash lasts 0.1 s")
	var travelled := enemy.global_position.x - 500.0
	check_near(travelled, 480.0 * 0.12, 14.0, "knockback 480 px/s for 0.12 s, away from the hit")
	check(enemy.global_position.y == 500.0, "knockback is along the hit direction")
	# i-frames of 0.25 s pace a continuous hitbox.
	await seconds(0.05)
	check_eq(enemy.hp, 5, "no second hit inside the 0.25 s i-frames")
	await seconds(0.3)
	check(enemy.hp <= 4, "hit again after the i-frames")
	hit.deactivate()
	await dispose(arena)


func _stun() -> void:
	reset_state()
	var arena := make_arena()
	var enemy := Counter.new()
	enemy.max_hp = 4
	enemy.contact_damage = 1
	enemy.drops_enabled = false
	enemy.push = Vector2(100, 0)
	arena.add_child(enemy)
	enemy.global_position = Vector2(500, 500)
	await frames(3)
	var moving_x := enemy.global_position.x
	check(moving_x > 500.0 and enemy.physics_calls > 0, "enemy acts normally before the stun")
	var stun_hit := make_hitbox(arena, Vector2(500, 500), Layers.Team.PLAYER, 0)
	stun_hit.stun_time = 2.0
	stun_hit.knockback = 0.0
	await frames(3)
	stun_hit.deactivate()
	check(enemy.is_stunned(), "a stun hitbox stuns")
	check_eq(enemy.hp, 4, "stun does no damage")
	var calls := enemy.physics_calls
	var x := enemy.global_position.x
	await seconds(1.5)
	check_eq(enemy.physics_calls, calls, "_enemy_physics is not called while stunned")
	check_near(enemy.global_position.x, x, 0.01, "stunned enemies do not move")
	check(enemy.contact_hitbox.active, "contact damage stays active while stunned")
	await seconds(0.7)
	check(not enemy.is_stunned(), "stun ends after its time")
	check(enemy.physics_calls > calls, "enemy acts again after the stun")
	enemy.stun(1.0)
	enemy.stun(0.2)
	await seconds(0.5)
	check(enemy.is_stunned(), "a shorter stun never shortens a running one")
	await dispose(arena)


func _death_and_drops() -> void:
	reset_state()
	var arena := make_arena()
	var enemy := Counter.new()
	enemy.max_hp = 2
	enemy.drop_roll_override = 0.1
	arena.add_child(enemy)
	enemy.global_position = Vector2(400, 400)
	await frames(2)
	var died_count := [0]
	var death_calls := [0]
	enemy.died.connect(
		func(e: EnemyBase) -> void:
			died_count[0] += 1
			death_calls[0] = (e as Counter).death_calls
	)
	var hit := make_hitbox(arena, Vector2(400, 400), Layers.Team.PLAYER, 2)
	await frames(3)
	check_eq(died_count[0], 1, "died signal fires once at 0 hp")
	check_eq(death_calls[0], 1, "_on_death hook is called once, before the died signal")
	await frames(2)
	check(not is_instance_valid(enemy), "dead enemy is freed")
	check(arena.get_node_or_null("Puff") != null, "death leaves a puff")
	var drops := arena.get_children().filter(func(n: Node) -> bool: return n is PickupBase)
	check_eq(drops.size(), 1, "one drop was rolled")
	if drops.size() == 1:
		check_eq((drops[0] as PickupBase).kind, &"ember", "roll 0.10 is an ember")
		check_near((drops[0] as PickupBase).timeout, 8.0, 0.001, "drops time out after 8 s")
		check_near(
			drops[0].global_position.distance_to(Vector2(400, 400)),
			0.0,
			1.0,
			"drop appears where the enemy died"
		)
	hit.deactivate()
	await dispose(arena)
	# No drop when the roll misses.
	arena = make_arena()
	var lucky := Counter.new()
	lucky.max_hp = 1
	lucky.drop_roll_override = 0.95
	arena.add_child(lucky)
	await frames(2)
	lucky.apply_damage(1, Vector2(-50, 0))
	await frames(2)
	check_eq(
		arena.get_children().filter(func(n: Node) -> bool: return n is PickupBase).size(),
		0,
		"roll 0.95 drops nothing"
	)
	await dispose(arena)


func _drop_table() -> void:
	check_eq(DropTable.pick(0.0, false), &"ember", "ember at roll 0")
	check_eq(DropTable.pick(0.249, false), &"ember", "ember up to 25 %")
	check_eq(DropTable.pick(0.25, false), &"brass_bit", "brass bit from 25 %")
	check_eq(DropTable.pick(0.599, false), &"brass_bit", "brass bit 35 %")
	check_eq(DropTable.pick(0.60, false), &"brass_coin", "brass coin 5 %")
	check_eq(DropTable.pick(0.649, false), &"brass_coin", "brass coin up to 65 %")
	check_eq(DropTable.pick(0.65, true), &"pitch_pot_bundle", "bundle 10 % once the item is found")
	check_eq(DropTable.pick(0.65, false), &"", "no bundle before the item is found")
	check_eq(DropTable.pick(0.75, true), &"", "nothing above 75 %")
	var counts := {&"ember": 0, &"brass_bit": 0, &"brass_coin": 0, &"pitch_pot_bundle": 0, &"": 0}
	for i in range(1000):
		counts[DropTable.pick(float(i) / 1000.0, true)] += 1
	check_eq(counts[&"ember"], 250, "25 % ember")
	check_eq(counts[&"brass_bit"], 350, "35 % brass bit")
	check_eq(counts[&"brass_coin"], 50, "5 % brass coin")
	check_eq(counts[&"pitch_pot_bundle"], 100, "10 % bundle")


func _confinement() -> void:
	reset_state()
	var arena := make_arena()
	var enemy := Counter.new()
	enemy.drops_enabled = false
	enemy.push = Vector2(900, 0)
	enemy.room_rect = Rect2(0, 0, 600, 400)
	arena.add_child(enemy)
	enemy.global_position = Vector2(300, 200)
	await seconds(1.0)
	check(
		enemy.global_position.x <= 600.0 - enemy.body_radius + 0.01,
		"enemy never leaves its room rect"
	)
	check(enemy.global_position.x >= 570.0, "enemy reaches the rect edge")
	# Walls stop it and set hit_wall.
	var walled := make_arena([Rect2(1000, 0, 100, 600)])
	var runner := Counter.new()
	runner.drops_enabled = false
	runner.push = Vector2(300, 0)
	walled.add_child(runner)
	runner.global_position = Vector2(800, 300)
	await seconds(1.5)
	check(runner.global_position.x < 1000.0, "enemy bodies collide with the WORLD layer")
	check(runner.hit_wall, "hit_wall is set when the enemy touches a wall")
	await dispose(arena)
	await dispose(walled)


func _contact_damage() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(500, 500))
	var enemy := make_dummy(arena, Vector2(520, 500), 2)
	enemy.contact_damage = 2
	enemy.contact_hitbox.damage = 2
	enemy.set_contact_enabled(true)
	await frames(4)
	check_eq(GameState.health, 4, "contact damage uses the enemy's contact damage in half-hearts")
	check(player.global_position.x < 500.0, "contact knocks the player away from the enemy")
	await dispose(arena)


func _fire_projectile() -> void:
	reset_state()
	var arena := make_arena()
	var shooter := make_dummy(arena, Vector2(300, 300), 2)
	shooter.room_rect = Rect2(0, 0, 900, 700)
	await frames(2)
	var shot := shooter.fire_projectile(null, Vector2.RIGHT, 200.0, 2)
	check(shot.get_parent() == arena, "projectiles are added next to the shooter")
	check_eq(shot.damage, 2, "fire_projectile sets the damage")
	check_eq(shot.speed, 200.0, "fire_projectile sets the speed")
	check_eq(shot.room_rect, shooter.room_rect, "projectiles share the room rect")
	check_eq(shot.global_position, Vector2(300, 300), "projectiles start at the shooter")
	shooter.set_facing_dir(Vector2(0, -3))
	check_eq(shooter.facing_dir, Vector2.UP, "set_facing_dir normalises")
	await dispose(arena)


func _projectile() -> void:
	reset_state()
	var arena := make_arena([Rect2(700, 0, 100, 800)])
	var projectile := EnemyProjectile.fire(arena, Vector2(300, 300), Vector2.RIGHT, 360.0, 1)
	var reasons: Array[StringName] = []
	projectile.destroyed.connect(func(reason: StringName) -> void: reasons.append(reason))
	check(projectile.blockable_by_ward, "projectiles are blockable by default")
	await frames(30)
	check_near(
		projectile.global_position.x, 300.0 + 360.0 * 0.5, 8.0, "projectile moves at its speed"
	)
	await seconds(1.0)
	check_eq(reasons, [&"wall"] as Array[StringName], "a wall destroys the projectile")
	var bounded := EnemyProjectile.fire(arena, Vector2(300, 300), Vector2.LEFT, 360.0, 1)
	bounded.room_rect = Rect2(0, 0, 400, 800)
	var bounded_reasons: Array[StringName] = []
	bounded.destroyed.connect(func(reason: StringName) -> void: bounded_reasons.append(reason))
	await seconds(1.0)
	check_eq(
		bounded_reasons,
		[&"bounds"] as Array[StringName],
		"leaving the room rect destroys the projectile"
	)
	var player := make_player(arena, Vector2(500, 600))
	await frames(2)
	var hit := EnemyProjectile.fire(arena, Vector2(300, 600), Vector2.RIGHT, 360.0, 1)
	var hit_reasons: Array[StringName] = []
	hit.destroyed.connect(func(reason: StringName) -> void: hit_reasons.append(reason))
	await seconds(1.0)
	check_eq(GameState.health, 5, "a projectile hit deals 1 half-heart")
	check_eq(hit_reasons, [&"hit"] as Array[StringName], "the projectile is destroyed by hitting")
	check(player.is_invulnerable() or GameState.health == 5, "player is hurt by it")
	await dispose(arena)


func _adopt() -> void:
	reset_state()
	var arena := make_arena()
	arena.position = Vector2(100, 50)
	var parent := make_dummy(arena, Vector2(500, 500))
	parent.room_rect = Rect2(0, 0, 2000, 2000)
	var now := EnemyBase.new()
	now.drops_enabled = false
	parent.adopt(now, Vector2(600, 500))
	check(now.is_inside_tree(), "adopt adds the child at once")
	check_near(now.global_position.x, 600.0, 0.5, "adopt places the child at the global position")
	check_eq(now.room_rect, parent.room_rect, "adopt shares the room rect")
	var later := EnemyBase.new()
	later.drops_enabled = false
	parent.adopt_deferred(later, Vector2(700, 500))
	check(not later.is_inside_tree(), "adopt_deferred waits until the end of the frame")
	await frames(2)
	check(later.is_inside_tree(), "the deferred child is in the tree afterwards")
	check_near(later.global_position.x, 700.0, 0.5, "the deferred child is at the global position")
	check_near(later.global_position.y, 500.0, 0.5, "also on the other axis (arena offset)")
	check_eq(later.room_rect, parent.room_rect, "the deferred child shares the room rect")
	await dispose(arena)
