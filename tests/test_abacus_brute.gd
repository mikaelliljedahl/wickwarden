extends TestCase
## Real pre-reel pot/charge flare destroys the rail; no cave-own-tool prerequisite.

const SCENE := "res://scenes/enemies/minibosses/abacus_brute.tscn"
const FIXTURE := "res://tests/fixtures/gallery/abacus_brute.tscn"


func run() -> void:
	await _live_pot_route()
	await _real_guard_and_break(false)
	await _real_guard_and_break(true)
	await _real_whirl(false)
	await _real_whirl(true)
	await _real_moth_reset()
	await _room_lifecycle()


func _enemy(arena: Node) -> EnemyBase:
	var scene := load(SCENE) as PackedScene
	check(scene != null, "brute scene loads")
	if scene == null:
		return null
	var enemy := scene.instantiate() as EnemyBase
	enemy.position = Vector2(800, 480)
	arena.add_child(enemy)
	return enemy


func _wait_state(enemy: EnemyBase, target: int, limit := 300) -> int:
	for i in range(limit):
		if enemy.state == target:
			return i
		await frames(1)
	check(false, "bounded brute state reached")
	return limit


func _live_pot_route() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = _enemy(arena)
	var player := make_player(arena, Vector2(1400, 480))
	await _wait_state(enemy, enemy.State.TELEGRAPH)
	player.place_at(enemy.global_position + Vector2(200, 0))
	player.facing = Vector2.LEFT
	GameState.acquire_item(&"pitch_pot")
	GameState.add_pitch_pots(1)
	check(player.use_item(), "live pre-reel route plants actual pot during chain warning")
	player.place_at(enemy.global_position + Vector2(400, 0))
	await frames(108)
	check_eq(enemy.rail_hp, 0, "unfrozen encounter rail breaks during committed spin")
	check_eq(enemy.hp, 28, "live pot is absorbed by rail")
	check_eq(GameState.health, 6, "real pot retreat clears whirl and blast")
	check(not GameState.has_item(&"reel_line"), "live route never needs later reel")
	await _capture("brute-live-pot")
	await _wait_state(enemy, enemy.State.WALK)
	player.place_at(enemy.global_position + Vector2(110, 0))
	player.facing = Vector2.LEFT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 26, "real front hook damages unguarded live Brute")
	await dispose(arena)


func _real_guard_and_break(pot: bool) -> void:
	reset_state()
	var arena := make_arena()
	var enemy = _enemy(arena)
	var player := make_player(arena, Vector2(890, 480))
	await frames(2)
	enemy.set_physics_process(false)
	enemy.set_facing_dir(Vector2.RIGHT)
	check_eq(enemy.hp, 28, "HP28")
	check_eq(enemy.contact_damage, 3, "contact3")
	check_eq(enemy.move_speed, 90.0, "armoured walk90")
	check_eq(enemy.rail_hp, 4, "rail4HP")
	player.facing = Vector2.LEFT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 28, "real front hook blocked")
	check_eq(enemy.rail_hp, 4, "hook cannot damage rail")
	await frames(25)
	player.place_at(enemy.global_position - Vector2(90, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 26, "actual back hook damages body2")
	await frames(25)
	# AI is frozen for tool-geometry isolation; explicitly expire the prior hit i-frame.
	enemy._iframe_time = 0.0
	enemy.hurtbox.invulnerable = false
	# Later reel is deliberately absent from the mandatory preacquisition fight.
	check(not GameState.has_item(&"reel_line"), "no reel prerequisite")
	player.place_at(enemy.global_position + Vector2(110, 0))
	player.facing = Vector2.LEFT
	if pot:
		GameState.acquire_item(&"pitch_pot")
		GameState.set_active_item(&"pitch_pot")
		GameState.add_pitch_pots(1)
		# Place a real pot on the front side, then retreat outside its player blast radius.
		player.place_at(enemy.global_position + Vector2(200, 0))
		check(player.use_item(), "real pitch pot armed in front of rail")
		player.place_at(enemy.global_position + Vector2(400, 0))
		await frames(108)
	else:
		Input.action_press(&"attack")
		await frames(55)
		Input.action_release(&"attack")
		await frames(8)
	check_eq(enemy.rail_hp, 0, "real pot/charge flare breaks rail4HP")
	check_eq(enemy.hp, 26, "rail absorbs qualifying front hit without body spill")
	check_eq(enemy.armor_front_deg, 0.0, "front protection gone")
	check_eq(enemy.move_speed, 130.0, "unarmoured walk130")
	await _capture("brute-pot-broken" if pot else "brute-flare-broken")
	await frames(30)
	player.place_at(enemy.global_position + Vector2(90, 0))
	player.facing = Vector2.LEFT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 24, "real front hook damages body after rail break")
	enemy.reset_fight()
	check_eq(enemy.hp, 28, "reset full bodyHP")
	check_eq(enemy.rail_hp, 4, "reset restores railHP")
	check_eq(enemy.move_speed, 90.0, "reset restores guarded speed")
	await dispose(arena)


func _real_whirl(fallback: bool) -> void:
	for inside in [true, false]:
		reset_state()
		var arena := make_arena()
		var enemy = _enemy(arena)
		var player := make_player(arena, Vector2(1400, 480))
		check(enemy._chain_texture != null, "painted chain loaded")
		if fallback:
			enemy._chain_texture = null
		await _wait_state(enemy, enemy.State.TELEGRAPH)
		await _capture("brute-whirl-warning")
		player.place_at(enemy.global_position + Vector2(140 if inside else 260, 0))
		player.facing = Vector2.LEFT
		Input.action_press(&"ward")
		await frames(10)
		check_eq(GameState.health, 6, "whirl warning harmless")
		var elapsed := await _wait_state(enemy, enemy.State.WHIRL)
		check_near(elapsed + 10, 42, 2, "whirl warns .7s")
		await frames(5)
		check_eq(GameState.health, 3 if inside else 6, "real192radius sweep bypasses ward")
		check(not enemy._whirl.blockable, "sweep not ward-blockable")
		check_eq(enemy._whirl.damage, 3, "whirl damage remains three")
		check_eq(
			enemy._whirl.get_child(0).shape.radius, 192.0, "whirl hit circle radius remains 192"
		)
		await _capture("brute-whirl")
		elapsed = await _wait_state(enemy, enemy.State.WALK)
		check_near(elapsed + 5, 72, 2, "spin1.2s")
		check(not is_instance_valid(enemy._whirl), "spin hazard removed")
		release_inputs()
		await dispose(arena)


func _real_moth_reset() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = _enemy(arena)
	var player := make_player(arena, Vector2(1400, 480))
	await _wait_state(enemy, enemy.State.WHIRL)
	player.place_at(enemy.global_position + Vector2(300, 0))
	player.facing = Vector2.LEFT
	GameState.acquire_item(&"tether_moth")
	check(player.use_item(), "real moth launched at spinning Brute")
	for i in range(40):
		await frames(1)
		if enemy.is_stunned():
			break
	check(enemy.is_stunned(), "real moth stuns Brute")
	check(enemy._stun_time <= 1.5, "moth1.5clamp")
	check(not is_instance_valid(enemy._whirl), "moth cancels actual whirl")
	check(not enemy.contact_hitbox.active, "stunned body harmless")
	player.place_at(enemy.global_position + Vector2(90, 0))
	player.facing = Vector2.LEFT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 26, "shared stun drops front guard for real hook")
	check_eq(enemy.rail_hp, 4, "moth/hook does not break rail")
	player.place_at(Vector2(1700, 800))
	for i in range(140):
		if not enemy.is_stunned():
			break
		await frames(1)
	enemy.stun(2.0)
	check(not enemy.is_stunned(), "three-second stun immunity")
	enemy.reset_fight()
	check(not enemy.is_stunned() and not enemy.is_knocked_back(), "reset combat timers")
	await _wait_state(enemy, enemy.State.WHIRL)
	var live: Hitbox = enemy._whirl
	enemy.reset_fight()
	check(not live.active, "reset disables actual live whirl immediately")
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
		check_eq(room.get_enemies().size(), 1, "one Brute per Room entry")
		var enemy = room.get_enemies()[0]
		check_eq(enemy.rail_hp, 4, "Room reentry restores guard")
		check_eq(enemy.hp, 28, "Room reentry restores body")
		room.leave()
	room.enter()
	await frames(2)
	var enemy = room.get_enemies()[0]
	enemy.stun(1.5)
	enemy.apply_damage(99, enemy.global_position, 0.0)
	check(GameState.has_flag(&"mini_cave_8_4"), "canonical mini flag")
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
		check(drop.timeout > 0, "timed drops")
	check_eq(kinds.count(&"ember"), 2, "two embers")
	check_eq(kinds.count(&"brass_coin"), 2, "two coins; no core/tool")
	room.leave()
	room.enter()
	await frames(2)
	check_eq(room.get_enemies().size(), 0, "persistently defeated Brute never respawns")
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
