extends TestCase

const SCENE := "res://scenes/enemies/minibosses/hollow_captain.tscn"


func run() -> void:
	await _guard_and_bash()
	await _real_moth_hit()
	await _stun_and_persistence()


func _guard_and_bash() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(800, 480))
	await frames(2)
	check_eq(enemy.hp, 12, "captain HP")
	check_eq(enemy.contact_damage, 2, "contact is two half hearts")
	check_eq(enemy.move_speed, 120.0, "patrol speed")
	check_eq(enemy.knockback_scale, 0.5, "half knockback")
	check(enemy.has_node("Visual"), "Visual exists")
	enemy.set_facing_dir(Vector2.RIGHT)
	_hit(enemy, &"hook", enemy.global_position + Vector2(100, 0))
	check_eq(enemy.hp, 12, "front hook blocked")
	_hit(enemy, &"hook", enemy.global_position + Vector2(0, 100))
	check_eq(enemy.hp, 10, "side hook damages")
	_hit(enemy, &"flare", enemy.global_position + Vector2(100, 0), 4)
	check_eq(enemy.hp, 6, "flare pierces front")
	_hit(enemy, &"explosion", enemy.global_position + Vector2(100, 0), 4)
	check_eq(enemy.hp, 2, "pot pierces front")
	enemy.reset_fight()
	await frames(2)
	check_eq(enemy.hp, 12, "fight reset heals")
	var player := make_player(arena, enemy.global_position + Vector2(0, -500))
	enemy.set_facing_dir(Vector2.RIGHT)
	await frames(7)
	check(absf(enemy.facing_dir.angle()) <= deg_to_rad(14), "turn limited to 100 degrees/s")
	player.queue_free()
	while enemy.state != enemy.State.TELEGRAPH:
		await frames(1)
	var elapsed := 0
	while enemy.state == enemy.State.TELEGRAPH and elapsed < 60:
		await frames(1)
		elapsed += 1
	check_near(elapsed, 30, 2, "bash warns for 0.5 s")
	check_eq(enemy.contact_hitbox.damage, 3, "bash damage")
	check(not enemy.contact_hitbox.blockable, "ward cannot block melee bash")
	await frames(2)
	check_near(enemy.velocity.length(), 300, 0.1, "bash speed")
	elapsed = 2
	while enemy.state == enemy.State.BASH and elapsed < 60:
		await frames(1)
		elapsed += 1
	check_near(elapsed, 24, 2, "bash lasts 0.4 s")
	check_eq(enemy.armor_front_deg, 0.0, "guard drops in recovery")
	_hit(enemy, &"hook", enemy.global_position + enemy.facing_dir * 100)
	check_eq(enemy.hp, 10, "front hook damages during recovery")
	await frames(62)
	check_eq(enemy.armor_front_deg, 140.0, "guard returns after one second")
	enemy.stun(2.0)
	check_eq(enemy.armor_front_deg, 0.0, "moth drops guard immediately")
	_hit(enemy, &"hook", enemy.global_position + enemy.facing_dir * 100)
	check_eq(enemy.hp, 8, "front hook damages stunned captain")
	await dispose(arena)


func _stun_and_persistence() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(800, 480))
	enemy.arena_id = &"mb1_test"
	await frames(2)
	enemy.stun(2.0)
	check_near(enemy._stun_time, 1.5, 0.01, "moth stun clamped to 1.5 s")
	await frames(92)
	check(not enemy.is_stunned(), "stun ends")
	enemy.stun(2.0)
	check(not enemy.is_stunned(), "three second immunity prevents stun lock")
	await frames(182)
	enemy.stun(2.0)
	check(enemy.is_stunned(), "stun works again after immunity")
	enemy._stun_time = 0.0
	enemy.apply_damage(99, enemy.global_position, 0.0)
	check(GameState.has_flag(&"mini_mb1_test"), "death persists under mini room flag")
	check(not enemy.is_arena_locked(), "miniboss never locks arena")
	check(not enemy.contact_hitbox.active, "dying miniboss cannot hurt player")
	await frames(100)
	check(not is_instance_valid(enemy), "death finishes")
	var drops := arena.get_children().filter(func(n: Node) -> bool: return n is PickupBase)
	check_eq(drops.size(), 4, "exactly four fixed drops, no table roll")
	var kinds: Array[StringName] = []
	for drop in drops:
		kinds.append(drop.kind)
		check(drop.timeout > 0.0, "miniboss drops are timed")
	check_eq(kinds.count(&"ember"), 2, "two embers")
	check_eq(kinds.count(&"brass_coin"), 2, "two coins")
	var scene := load(SCENE) as PackedScene
	check(scene != null, "scene loads")
	var retired = scene.instantiate()
	retired.arena_id = &"mb1_test"
	arena.add_child(retired)
	check(retired.is_dead and not retired.visible, "defeated miniboss stays gone on reload")
	await dispose(arena)


func _hit(enemy: EnemyBase, kind: StringName, origin: Vector2, amount: int = 2) -> void:
	var hit := Hitbox.new()
	hit.kind = kind
	hit.damage = amount
	hit.knockback = 0.0
	add_child(hit)
	hit.global_position = origin
	enemy._iframe_time = 0.0
	enemy._on_hurtbox_hurt(hit)
	hit.queue_free()


func _real_moth_hit() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(800, 480))
	await frames(2)
	var moth := make_hitbox(arena, enemy.global_position, Layers.Team.PLAYER, 0, 40.0)
	moth.kind = &"stun"
	moth.stun_time = 2.0
	await frames(3)
	check(enemy.is_stunned(), "real moth hitbox stuns through hurtbox")
	check(enemy._stun_time <= 1.5, "real moth stun clamped")
	await dispose(arena)
