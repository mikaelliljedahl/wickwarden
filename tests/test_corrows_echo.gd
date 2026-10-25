extends TestCase
## Controlled positioning checks actual collision windows, not human balance.

const SCENE := "res://scenes/enemies/minibosses/corrows_echo.tscn"


func run() -> void:
	await _cycle_and_chime()
	await _attacks()
	await _lifecycle()


func _spawn(arena: Node) -> EnemyBase:
	var scene := load(SCENE) as PackedScene
	check(scene != null, "scene loads")
	if scene == null:
		return null
	var enemy := scene.instantiate() as EnemyBase
	enemy.position = Vector2(800, 480)
	enemy.arena_id = &"cave_10_4"
	arena.add_child(enemy)
	return enemy


func _wait_state(enemy: EnemyBase, target: int, limit := 400) -> int:
	for i in range(limit):
		if enemy.state == target:
			return i
		await frames(1)
	check(false, "bounded echo state")
	return limit


func _cycle_and_chime() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = _spawn(arena)
	var player := make_player(arena, Vector2(940, 480))
	await _wait_state(enemy, enemy.State.TELL)
	check_eq(enemy.max_hp, 36, "HP36")
	check_eq(enemy.move_speed, 200.0, "speed200")
	check_eq(enemy.contact_damage, 4, "contact4")
	check(enemy.has_node("Visual"), "Visual")
	player.place_at(Vector2(1400, 800))
	await _capture("echo-combo-tell")
	var elapsed := await _wait_state(enemy, enemy.State.COMBO)
	check_near(elapsed, 30, 2, ".5s combo tell")
	await _wait_state(enemy, enemy.State.RETREAT)
	var start: Vector2 = enemy.global_position
	await _wait_state(enemy, enemy.State.GLOW)
	check_near(enemy.global_position.distance_to(start), 192, 4, "retreat192")
	await _capture("echo-glow")
	player.place_at(enemy.global_position + Vector2(250, 0))
	GameState.acquire_item(&"lantern_chime")
	check(player.use_item(), "actual chime rings")
	for i in range(35):
		await frames(1)
		if enemy.is_stunned():
			break
	check(enemy.is_stunned(), "real wave interrupts glow")
	check_near(enemy._stun_time, 2.0, .05, "chime stun2")
	check_eq(enemy.chime_stun_time, 0.0, "chime window closed")
	check(not is_instance_valid(enemy._attack), "no flare after chime")
	player.place_at(enemy.global_position + Vector2(90, 0))
	player.facing = Vector2.LEFT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 34, "real hook during chime opening2")
	await _capture("echo-chime-opening")
	enemy.reset_fight()
	enemy.move_speed = 0  # Controlled outside-glow fixture.
	await frames(2)
	player.place_at(enemy.global_position + Vector2(250, 0))
	await frames(80)
	check(player.use_item(), "real chime outside glow")
	await frames(35)
	check(not enemy.is_stunned(), "outside glow chime has no stun")
	GameState.acquire_item(&"tether_moth")
	GameState.set_active_item(&"tether_moth")
	player.facing = Vector2.LEFT
	check(player.use_item(), "real moth launches")
	for i in range(40):
		await frames(1)
		if enemy.is_stunned():
			break
	check(enemy.is_stunned(), "real moth stuns Echo")
	check(enemy._stun_time <= 1.0, "moth clamped1")
	await dispose(arena)


func _attacks() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = _spawn(arena)
	var player := make_player(arena, Vector2(940, 480))
	await _wait_state(enemy, enemy.State.TELL)
	Input.action_press(&"ward")
	player.facing = Vector2.LEFT
	await frames(39)
	check_eq(GameState.health, 3, "actual melee3 bypasses ward")
	player.place_at(Vector2(1500, 800))
	await _wait_state(enemy, enemy.State.GLOW)
	player.place_at(enemy.global_position + Vector2(140, 0))
	GameState.health = 6
	# Let prior melee i-frames expire before the flare.
	await _wait_state(enemy, enemy.State.FLARE)
	await frames(4)
	check_eq(GameState.health, 2, "actual radial flare4 bypasses ward")
	release_inputs()
	enemy.reset_fight()
	player.place_at(Vector2(1500, 800))
	await frames(2)
	# HP fixture; the actual attack cycle must choose the second-phase throw.
	enemy.hp = 17
	player.place_at(enemy.global_position + Vector2(140, 0))
	await _wait_state(enemy, enemy.State.TELL)
	player.place_at(Vector2(1500, 800))
	await _wait_state(enemy, enemy.State.RECOVER)
	check(is_instance_valid(enemy._hook), "natural phase2 cycle throws hook below18")
	enemy.reset_fight()
	await frames(2)
	# Controlled phase fixture: real projectile trajectory and ward collision.
	enemy.hp = 17
	enemy._throw_hook()
	var hook: EnemyProjectile = enemy._hook
	check(hook != null and hook.damage == 2 and hook.speed == 600, "phase2 boomerang numbers")
	player.place_at(Vector2(1500, 100))
	await frames(49)
	check(hook.returning, "hook turns at480")
	await _capture("echo-hook-return")
	await frames(52)
	check(not is_instance_valid(hook), "hook returns and cleans up")
	player.place_at(enemy.global_position + Vector2(250, 0))
	player.facing = Vector2.LEFT
	GameState.health = 6
	Input.action_press(&"ward")
	await frames(3)
	enemy._throw_hook()
	hook = enemy._hook
	await frames(28)
	check(not is_instance_valid(hook), "real ward destroys wax boomerang")
	check_eq(GameState.health, 6, "ward blocks wax hook2")
	release_inputs()
	player.place_at(Vector2(1500, 100))
	enemy._throw_hook()
	hook = enemy._hook
	enemy.reset_fight()
	check(hook.is_destroyed and not hook.hitbox.active, "reset immediately disables hook")
	check_eq(enemy.hp, 36, "reset fullHP")
	await dispose(arena)


func _lifecycle() -> void:
	reset_state()
	var arena := make_arena()
	var fixture := load("res://tests/fixtures/gallery/corrows_echo.tscn") as PackedScene
	check(fixture != null, "gallery loads")
	if fixture != null:
		var room := fixture.instantiate() as Room
		arena.add_child(room)
		for i in range(2):
			room.enter()
			await frames(2)
			check_eq(room.get_enemies().size(), 1, "one Echo on reentry")
			check_eq(room.get_enemies()[0].hp, 36, "reentry restores fullHP")
			room.leave()
		await dispose(room)
	var enemy = _spawn(arena)
	await frames(2)
	enemy.stun(1.0)
	enemy.apply_damage(99, enemy.global_position, 0)
	check(GameState.has_flag(&"mini_cave_10_4"), "canonical mini flag")
	check(not enemy.contact_hitbox.active, "death disables contact")
	check(not enemy.is_stunned(), "death cannot freeze in stun")
	Events.player_died.emit()
	check(enemy.is_dying(), "player death cannot revive defeated miniboss")
	await frames(100)
	var drops := arena.get_children().filter(func(n: Node) -> bool: return n is PickupBase)
	check_eq(drops.size(), 4, "only four fixed drops")
	var kinds: Array = []
	for drop in drops:
		kinds.append(drop.kind)
		check(drop.timeout > 0, "timed drops")
	check_eq(kinds.count(&"ember"), 2, "two embers")
	check_eq(kinds.count(&"brass_coin"), 2, "two coins")
	var retired = _spawn(arena)
	check(retired.is_dead and not retired.visible, "defeated stays gone")
	await dispose(arena)


func _capture(label: String) -> void:
	if OS.get_environment("WICK_MB5_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		get_viewport().get_texture().get_image().save_png("/tmp/mb5-" + label + ".png"),
		OK,
		"capture"
	)
