extends TestCase

const SCENE := "res://scenes/enemies/minibosses/thorn_warden.tscn"


func run() -> void:
	await _needle_reset_collision(false)
	await _needle_reset_collision(true)
	await _damage_and_ring()
	await _real_hook_skirt()
	await _real_flame_ticks()
	await _real_moth_hit()
	await _stun_and_persistence()


func _needle_reset_collision(reset_on_overlap: bool) -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(800, 480))
	enemy.move_speed = 0.0
	await frames(2)
	var player := make_player(arena, Vector2(1050, 480))
	var initial_health := GameState.health
	var needle: EnemyProjectile
	for i in range(280):
		await frames(1)
		var needles := get_tree().get_nodes_in_group(&"projectiles")
		if needles.size() == 8:
			needle = needles[0] as EnemyProjectile
			break
	check(needle != null, "natural needle ring appears")
	if needle == null:
		await dispose(arena)
		return
	var observed := [false, false, -1]
	needle.hitbox.area_entered.connect(
		func(area: Area2D) -> void:
			if area == player.hurtbox:
				observed[0] = true
				if reset_on_overlap:
					enemy.reset_fight()
					observed[1] = needle.is_queued_for_deletion()
					observed[2] = GameState.health
	)
	await frames(90)
	check(observed[0], "natural needle physically overlaps player hurtbox")
	if reset_on_overlap:
		check(observed[1], "reset queues the overlapping needle for deletion")
		check_eq(observed[2], initial_health, "player is unharmed at reset")
		check_eq(GameState.health, initial_health, "queued needle cannot hurt player after reset")
	else:
		check_eq(GameState.health, initial_health - 1, "control needle actually damages player")
	await dispose(arena)


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
	enemy.reset_fight()
	check(not enemy.is_stunned(), "reset clears active stun without test intervention")
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
		if SpriteVisual.has_art(&"gloam_lance"):
			check(needle.get_node("Visual") is SpriteVisual, "needle uses painted projectile")
		check_near(
			needle.direction.angle_to(Vector2.from_angle(TAU * i / 8.0)),
			0.0,
			0.001,
			"evenly spaced ring"
		)
	var needle := needles[0] as EnemyProjectile
	var player := make_player(arena, enemy.global_position + Vector2(200, 0))
	player.facing = Vector2.LEFT
	var blocked := [0]
	var destroyed_by: Array[StringName] = []
	needle.hitbox.blocked.connect(func() -> void: blocked[0] += 1)
	needle.destroyed.connect(func(reason: StringName) -> void: destroyed_by.append(reason))
	var health := GameState.health
	Input.action_press(&"ward")
	await frames(2)
	check(player.ward_up, "real player raises ward through input")
	for i in range(50):
		await frames(1)
		if not is_instance_valid(needle):
			break
	Input.action_release(&"ward")
	check_eq(blocked[0], 1, "travelling ring needle collides with real ward")
	check_eq(destroyed_by, [&"ward"], "actual ward collision destroys needle")
	check_eq(GameState.health, health, "ward prevents needle damage")
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


func _real_hook_skirt() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(800, 480))
	var player := make_player(arena, Vector2(710, 480))
	await frames(2)
	player.facing = Vector2.RIGHT
	check(not enemy.is_stunned(), "thorn skirt starts extended")
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 15, "real unstunned player hook deals one through thorn skirt")
	await dispose(arena)
