extends TestCase

const SCENE := "res://scenes/enemies/minibosses/hollow_captain.tscn"


func run() -> void:
	await _reset_during_death()
	await _reset_natural_bash()
	await _guard_and_bash()
	await _real_hook_guard()
	await _real_moth_hit()
	await _stun_and_persistence()


func _reset_during_death() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(800, 480))
	enemy.arena_id = &"mb1_reset_death_test"
	await frames(2)
	var elapsed := 0
	while enemy.state != enemy.State.BASH and elapsed < 360:
		await frames(1)
		elapsed += 1
	check_eq(enemy.state, enemy.State.BASH, "death test reaches natural bash")
	enemy.apply_damage(99, enemy.global_position, 0.0)
	check(enemy.is_dying() and enemy.is_defeated(), "lethal hit starts death throes")
	check(not enemy.contact_hitbox.active, "lethal hit disables contact")
	var cycle: float = enemy._cycle
	var timer: float = enemy._timer
	var death_left: float = enemy._death_left
	var damage: int = enemy.contact_hitbox.damage
	enemy.reset_fight()
	check(enemy.is_dying() and enemy.is_defeated(), "direct reset preserves death throes")
	check_eq(enemy.state, enemy.State.BASH, "direct reset leaves attack state untouched")
	check_eq(enemy._cycle, cycle, "direct reset leaves attack cycle untouched")
	check_eq(enemy._timer, timer, "direct reset leaves attack timer untouched")
	check_eq(enemy.contact_hitbox.damage, damage, "direct reset leaves contact damage untouched")
	check(not enemy.contact_hitbox.active, "direct reset does not reactivate contact")
	check_eq(enemy._death_left, death_left, "direct reset leaves death timer untouched")
	check(GameState.has_flag(&"mini_mb1_reset_death_test"), "defeat flag remains set")
	await frames(100)
	check(not is_instance_valid(enemy), "death completes after direct reset")
	var drops := arena.get_children().filter(func(n: Node) -> bool: return n is PickupBase)
	check_eq(drops.size(), 4, "death still produces exactly four drops")
	await dispose(arena)


func _reset_natural_bash() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(800, 480))
	await frames(2)
	var elapsed := 0
	while enemy.state != enemy.State.BASH and elapsed < 360:
		await frames(1)
		elapsed += 1
	check_eq(enemy.state, enemy.State.BASH, "natural cycle reaches bash")
	check_eq(enemy.contact_hitbox.damage, 3, "natural bash raises contact damage")
	enemy.reset_fight()
	check_eq(enemy.state, enemy.State.PATROL, "reset immediately returns to patrol")
	check_eq(enemy.contact_hitbox.damage, 2, "reset immediately restores contact damage")
	check_eq(enemy._cycle, enemy.INTERVAL, "reset immediately restarts attack cycle")
	check_eq(enemy._timer, enemy.INTERVAL, "reset immediately clears bash timer")
	check_eq(enemy.armor_front_deg, 140.0, "reset immediately raises guard")
	check_eq(enemy.velocity, Vector2.ZERO, "reset immediately stops dash")
	await frames(2)
	check_eq(enemy.state, enemy.State.PATROL, "reset remains in patrol after physics")
	check_eq(enemy.contact_hitbox.damage, 2, "contact damage remains restored after physics")
	check(enemy._cycle > enemy.INTERVAL - 0.1, "new cycle starts after reset")
	await dispose(arena)


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
	await frames(92)
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
	var enemy = make_enemy(arena, SCENE, Vector2(850, 480))
	var player := make_player(arena, Vector2(600, 480))
	await frames(2)
	enemy.set_facing_dir(Vector2.LEFT)
	GameState.acquire_item(&"tether_moth")
	player.facing = Vector2.RIGHT
	check(player.use_item(), "Player creates and activates the real tether moth")
	var moths := get_tree().get_nodes_in_group(ItemBase.group_name(&"tether_moth"))
	check_eq(moths.size(), 1, "one real tether moth instance")
	if moths.size() != 1:
		await dispose(arena)
		return
	var moth := moths[0] as Node2D
	var launch := moth.global_position
	var travelled := 0.0
	var stun_events := [0]
	enemy.stunned.connect(func(_time: float) -> void: stun_events[0] += 1)
	for i in range(40):
		await frames(1)
		if is_instance_valid(moth):
			travelled = maxf(travelled, moth.global_position.distance_to(launch))
		if enemy.is_stunned():
			break
	check(travelled > 100.0, "activated moth travels from player to enemy")
	check_eq(stun_events[0], 1, "travelling real moth triggers enemy stun")
	check(enemy.is_stunned(), "real moth collision reaches miniboss hurtbox")
	check(enemy._stun_time <= 1.5, "real moth stun clamped to 1.5 seconds")
	check_eq(enemy.hp, enemy.max_hp, "moth inflicts no damage")
	player.place_at(enemy.global_position + Vector2(-90, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, enemy.max_hp - 2, "real player hook deals two after real moth stun")
	check(enemy.is_stunned(), "reset regression starts while still moth-stunned")
	check(enemy.is_knocked_back(), "real hook supplies knockback before reset")
	enemy.reset_fight()
	check(not enemy.is_stunned(), "reset_fight clears real moth stun immediately")
	check(not enemy.is_knocked_back(), "reset_fight clears real hook knockback immediately")
	check(enemy.can_be_hurt(), "reset_fight clears hit invulnerability immediately")
	check_eq(enemy.hp, enemy.max_hp, "reset restores health")
	player.place_at(Vector2(200, 480))
	await frames(2)
	check(not enemy.is_in_intro(), "reset miniboss immediately resumes its fight")
	check(enemy.velocity.length() > 0.0, "reset miniboss moves without waiting out old stun")
	await dispose(arena)


func _real_hook_guard() -> void:
	for front in [true, false]:
		reset_state()
		var arena := make_arena()
		var enemy = make_enemy(arena, SCENE, Vector2(800, 480))
		var offset := Vector2(90, 0) if front else Vector2(0, -90)
		var player := make_player(arena, enemy.global_position + offset)
		await frames(2)
		enemy.set_facing_dir(Vector2.RIGHT)
		player.facing = -offset.normalized()
		var blocks := [0]
		enemy.guard_blocked.connect(func(_hitbox: Hitbox) -> void: blocks[0] += 1)
		Input.action_press(&"attack")
		await frames(8)
		Input.action_release(&"attack")
		check_eq(enemy.hp, 12 if front else 10, "real hook front blocked / side damages")
		check_eq(blocks[0], 1 if front else 0, "real swing collision applies guard direction")
		await dispose(arena)
