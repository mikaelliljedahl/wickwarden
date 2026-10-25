extends TestCase
## Base-kit moth at an actual lunge over a real pit; no boots are needed.

const SCENE := "res://scenes/enemies/minibosses/pale_squire.tscn"
const FIXTURE := "res://tests/fixtures/gallery/pale_squire.tscn"


func run() -> void:
	await _real_lunge()
	await _real_stab()
	await _real_moth_fall()
	await _real_hook_fall()
	await _shore_stun_and_reset()
	await _room_lifecycle()


func _enemy(arena: Node, at := Vector2(720, 480)) -> EnemyBase:
	var scene := load(SCENE) as PackedScene
	check(scene != null, "squire scene loads")
	if scene == null:
		return null
	var enemy := scene.instantiate() as EnemyBase
	enemy.position = at
	arena.add_child(enemy)
	return enemy


func _pit(arena: Node, at := Vector2(960, 480)) -> Node2D:
	var scene := load("res://scenes/world/pit.tscn") as PackedScene
	check(scene != null, "actual P04 pit scene loads")
	if scene == null:
		return null
	var pit := scene.instantiate() as Node2D
	pit.position = at
	pit.size = Vector2(96, 576)
	arena.add_child(pit)
	return pit


func _wait_state(enemy: EnemyBase, target: int, limit := 300) -> int:
	for i in range(limit):
		if enemy.state == target:
			return i
		await frames(1)
	check(false, "bounded squire state reached")
	return limit


func _real_lunge() -> void:
	reset_state()
	var foreign := make_arena()
	_pit(foreign, Vector2(720, 480))
	var arena := make_arena()
	_pit(arena)
	var enemy = _enemy(arena)
	make_player(arena, Vector2(1400, 480))
	await frames(2)
	check_eq(enemy.hp, 16, "HP16")
	check_eq(enemy.contact_damage, 2, "contact/stab2")
	check_near(enemy.velocity.length(), 160, .01, "walk160")
	check_eq(enemy.knockback_scale, .5, "half hook knockback")
	check(not enemy._over_pit(Vector2(720, 480)), "ignores foreign-room pit")
	await _wait_state(enemy, enemy.State.TELEGRAPH)
	check(enemy.global_position.x <= 882, "ordinary patrol stops before pit")
	await _capture("squire-warning")
	var elapsed := await _wait_state(enemy, enemy.State.LUNGE)
	check_near(elapsed, 24, 2, "specific row warning .4s")
	var start: Vector2 = enemy.global_position
	await frames(2)
	check_near(enemy.velocity.length(), 520, .01, "actual lunge520")
	elapsed = await _wait_state(enemy, enemy.State.RECOVER)
	check_near(elapsed + 2, 36, 2, "lunge lasts .6s")
	check_near(enemy.global_position.distance_to(start), 312, 1, "actual travel312 across pit")
	check_eq(enemy.hp, 16, "uninterrupted lunge crosses without falling")
	elapsed = await _wait_state(enemy, enemy.State.WALK)
	check_near(elapsed, 48, 2, "recovery .8s")
	check(not enemy.contact_hitbox.blockable, "melee stab not ward blockable")
	await dispose(arena)
	await dispose(foreign)


func _real_stab() -> void:
	reset_state()
	var arena := make_arena()
	_pit(arena)
	var enemy = _enemy(arena)
	var player := make_player(arena, Vector2(1240, 480))
	player.facing = Vector2.LEFT
	Input.action_press(&"ward")
	await _wait_state(enemy, enemy.State.RECOVER)
	await frames(4)
	check_eq(GameState.health, 4, "actual crossing stab deals2 through front ward")
	release_inputs()
	await dispose(arena)


func _real_moth_fall() -> void:
	reset_state()
	var arena := make_arena()
	_pit(arena)
	var enemy = _enemy(arena)
	enemy.arena_id = &"mb4_real_moth_route"
	var player := make_player(arena, Vector2(1200, 480))
	await _wait_state(enemy, enemy.State.LUNGE)
	GameState.acquire_item(&"tether_moth")
	player.facing = Vector2.LEFT
	check(not GameState.has_item(&"skitter_boots"), "preacquisition challenge has no boots")
	check(player.use_item(), "actual moth launches from safe pit edge")
	await _wait_state(enemy, enemy.State.FALLEN, 60)
	check_eq(enemy.hp, 10, "actual moth collision over pit causes6 fall damage")
	check(enemy._over_pit(enemy.global_position), "fall occurs over own pit")
	check(
		not enemy.hurtbox.enabled and not enemy.contact_hitbox.active,
		"fallen enemy absent from combat"
	)
	check(not enemy.visual.visible, "fallen body hidden")
	await _capture("squire-fallen")
	var elapsed := await _wait_state(enemy, enemy.State.RECOVER)
	check_near(elapsed, 180, 2, "gone for3seconds")
	check_eq(
		enemy.global_position, Vector2(720, 480), "bare fixture returns to initial entry fallback"
	)
	check(enemy.hurtbox.enabled and enemy.visual.visible, "returns visible and hittable")
	check_eq(enemy.hp, 10, "return preserves damage")
	check_eq(GameState.health, 6, "moth route keeps player safely outside pit")

	# Finish the encounter through the same real pre-boots route, without scripted damage.
	for cycle in range(2):
		await _wait_state(enemy, enemy.State.LUNGE)
		player.facing = Vector2.LEFT
		check(player.use_item(), "repeat real moth after pit return")
		await _wait_state(enemy, enemy.State.FALLEN, 60)
		if cycle == 0:
			check_eq(enemy.hp, 4, "second real pit fall preserves cumulative damage")
			await _wait_state(enemy, enemy.State.RECOVER)
	check(GameState.has_flag(&"mini_mb4_real_moth_route"), "three real moth falls defeat Squire")
	check(not enemy.contact_hitbox.active, "pit-finishing blow disables contact")
	await _capture("squire-moth-defeat")
	await frames(100)
	check(not is_instance_valid(enemy), "actual-tool defeat completes death sequence")
	await dispose(arena)


func _real_hook_fall() -> void:
	reset_state()
	var arena := make_arena()
	_pit(arena)
	var enemy = _enemy(arena, Vector2(960, 480))
	var player := make_player(arena, Vector2(1080, 480))
	await frames(2)
	# Hold position over the pit solely to isolate actual hook contact and additive fall damage.
	enemy.set_physics_process(false)
	player.facing = Vector2.LEFT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 8, "real hook2 plus environmental fall6")
	check_eq(enemy.state, enemy.State.FALLEN, "hit over pit falls")
	enemy.reset_fight()
	check_eq(enemy.hp, 16, "reset fullHP during fall")
	check(enemy.hurtbox.enabled and enemy.visual.visible, "reset restores absent body")
	check(not enemy.is_stunned() and not enemy.is_knocked_back(), "reset clears tool timers")
	await dispose(arena)


func _shore_stun_and_reset() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = _enemy(arena)
	var player := make_player(arena, Vector2(1050, 480))
	await frames(2)
	GameState.acquire_item(&"tether_moth")
	player.facing = Vector2.LEFT
	check(player.use_item(), "real moth launches on dry ground")
	for i in range(40):
		await frames(1)
		if enemy.is_stunned():
			break
	check(enemy.is_stunned(), "shore hit applies normal moth stun")
	check(enemy._stun_time <= 1.5, "moth clamp1.5")
	check_eq(enemy.hp, 16, "moth on safe ground deals no damage")
	player.place_at(Vector2(1700, 800))
	await frames(92)
	enemy.stun(2.0)
	check(not enemy.is_stunned(), "three-second stun immunity")
	enemy.reset_fight()
	check(not enemy.is_stunned(), "reset clears stun")
	await dispose(arena)


func _room_lifecycle() -> void:
	reset_state()
	var scene := load(FIXTURE) as PackedScene
	check(scene != null, "gallery loads")
	if scene == null:
		return
	var arena := make_arena()
	var room := scene.instantiate() as Room
	arena.add_child(room)
	for i in range(2):
		room.enter()
		await frames(2)
		check_eq(room.get_enemies().size(), 1, "one squire on real Room reentry")
		var enemy = room.get_enemies()[0]
		check_eq(enemy._entry, room.get_spawn_position(), "actual Room uses entry marker")
		check_eq(enemy.hp, 16, "reentry fullHP")

		if i == 0:
			enemy.global_position = room.global_position + Vector2(960, 480)
			enemy.stun(1.5)
			check_eq(enemy.state, enemy.State.FALLEN, "Room pit actually triggers fall")
			await _wait_state(enemy, enemy.State.RECOVER)
			check_eq(
				enemy.global_position,
				room.get_spawn_position(),
				"fall returns at actual Room entry spawn"
			)
		room.leave()
	room.enter()
	await frames(2)
	var enemy = room.get_enemies()[0]
	enemy.stun(1.5)
	enemy.apply_damage(99, enemy.global_position, 0.0)
	check(GameState.has_flag(&"mini_cave_7_4"), "canonical mini flag")
	check(not enemy.contact_hitbox.active and not enemy.is_stunned(), "lethal clears contact/stun")
	check(not enemy.is_arena_locked(), "no shutters")
	await frames(100)
	var drops := room.get_node("Enemies").get_children().filter(
		func(n: Node) -> bool: return n is PickupBase
	)
	check_eq(drops.size(), 4, "four fixed drops")
	var kinds: Array = []
	for drop in drops:
		kinds.append(drop.kind)
		check(drop.timeout > 0, "timed drop")
	check_eq(kinds.count(&"ember"), 2, "two embers")
	check_eq(kinds.count(&"brass_coin"), 2, "two coins; no core/tool")
	room.leave()
	room.enter()
	await frames(2)
	check_eq(room.get_enemies().size(), 0, "defeated Room copy never respawns")
	await dispose(arena)


func _capture(label: String) -> void:
	if OS.get_environment("WICK_MB4_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		get_viewport().get_texture().get_image().save_png("/tmp/mb4-" + label + ".png"),
		OK,
		"actual state capture " + label
	)
