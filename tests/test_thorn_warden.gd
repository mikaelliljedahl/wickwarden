extends TestCase

const SCENE := "res://scenes/enemies/minibosses/thorn_warden.tscn"


func run() -> void:
	await _damage_and_ring()
	await _real_flame_ticks()
	await _real_moth_hit()
	await _stun_and_persistence()


func _damage_and_ring() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(800, 480))
	await frames(2)
	check_eq(enemy.hp, 16, "warden HP")
	check_eq(enemy.contact_damage, 2, "contact damage")
	check_eq(enemy.move_speed, 80.0, "walking speed")
	check(enemy.has_node("Visual"), "Visual exists")
	_hit(enemy, &"hook", enemy.global_position)
	check_eq(enemy.hp, 15, "thorn skirt reduces hook to one")
	_hit(enemy, &"fire", enemy.global_position, 1)
	check_eq(enemy.hp, 13, "fire tick deals two")
	enemy.stun(2.0)
	_hit(enemy, &"hook", enemy.global_position)
	check_eq(enemy.hp, 11, "stunned hook deals two")
	enemy._stun_time = 0.0
	enemy.reset_fight()
	await frames(2)
	var elapsed := 0
	while enemy.state != enemy.State.TELEGRAPH and elapsed < 200:
		await frames(1)
		elapsed += 1
	check_near(elapsed, 180, 4, "needle warning starts at three seconds")
	check_eq(get_tree().get_nodes_in_group(&"projectiles").size(), 0, "warning has no needles")
	elapsed = 0
	while enemy.state == enemy.State.TELEGRAPH and elapsed < 60:
		await frames(1)
		elapsed += 1
	check_near(elapsed, 36, 2, "needle warning lasts 0.6 s")
	var needles := get_tree().get_nodes_in_group(&"projectiles")
	check_eq(needles.size(), 8, "eight needles")
	for i in range(needles.size()):
		var needle = needles[i]
		check_eq(needle.damage, 1, "needle damage")
		check_eq(needle.speed, 280.0, "needle speed")
		check(needle.hitbox.blockable, "ward blocks needles")
		check(needle.has_node("Visual"), "needle has Visual")
		check_near(
			needle.direction.angle_to(Vector2.from_angle(TAU * i / 8.0)),
			0.0,
			0.001,
			"evenly spaced ring"
		)
	needles[0].hitbox.blocked.emit()
	await frames(2)
	check_eq(get_tree().get_nodes_in_group(&"projectiles").size(), 7, "ward destroys needle")
	enemy.reset_fight()
	await frames(2)
	check_eq(get_tree().get_nodes_in_group(&"projectiles").size(), 0, "reset clears hazards")
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


func _real_flame_ticks() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(800, 480))
	var scene := load("res://scenes/items/flame.tscn") as PackedScene
	check(scene != null, "real cinder flame scene available")
	if scene == null:
		await dispose(arena)
		return
	var flame = scene.instantiate()
	arena.add_child(flame)
	flame.launch(Vector2(700, 480), Vector2.RIGHT)
	await frames(15)
	check_eq(enemy.hp, 14, "real flame first tick deals two")
	enemy.global_position += Vector2(0, 100)
	await frames(22)
	check_eq(enemy.hp, 12, "attached flame follows and ticks again after 0.5 s")
	await dispose(arena)
