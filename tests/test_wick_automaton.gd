extends TestCase
## Real tool collisions plus controlled state fixtures; no human balance claim.

const SCENE := "res://scenes/enemies/minibosses/wick_automaton.tscn"


func run() -> void:
	await _tools()
	await _jet()
	await _lifecycle()


func _spawn(arena: Node) -> EnemyBase:
	var scene := load(SCENE) as PackedScene
	check(scene != null, "scene loads")
	if scene == null:
		return null
	var enemy := scene.instantiate() as EnemyBase
	enemy.position = Vector2(800, 480)
	enemy.arena_id = &"cave_9_4"
	arena.add_child(enemy)
	return enemy


func _tools() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = _spawn(arena)
	var player := make_player(arena, Vector2(710, 480))
	await frames(2)
	# Controlled movement freeze leaves real tool geometry and hurt processing active.
	enemy.move_speed = 0
	check_eq(enemy.max_hp, 30, "HP30")
	check_eq(enemy.contact_damage, 3, "contact3")
	check(enemy.has_node("Visual"), "Visual")
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 29, "actual hook on brass1")
	await frames(40)
	player.place_at(enemy.global_position - Vector2(240, 0))
	GameState.acquire_item(&"tether_moth")
	check(player.use_item(), "real moth launched")
	for i in range(40):
		await frames(1)
		if enemy.is_stunned():
			break
	check(enemy.is_stunned(), "real moth opens vent")
	check(enemy._stun_time <= 1.5, "moth clamp")
	player.place_at(enemy.global_position - Vector2(90, 0))
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 27, "real hook in stunned vent2")
	await frames(45)
	GameState.acquire_item(&"pitch_pot")
	GameState.pitch_pots = 6
	GameState.active_item = &"pitch_pot"
	player.place_at(enemy.global_position - Vector2(96, 0))
	check(player.use_item(), "real pot placed")
	player.place_at(Vector2(1400, 800))
	await frames(105)
	check_eq(enemy.hp, 23, "real explosion on brass4")
	# Real charge release: initial hook is kept out of range, then flare overlaps.
	enemy.reset_fight()
	await frames(2)
	enemy.move_speed = 0
	player.place_at(enemy.global_position - Vector2(300, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(65)
	player.global_position = enemy.global_position - Vector2(140, 0)
	Input.action_release(&"attack")
	await frames(8)
	check_eq(enemy.hp, 28, "actual charge flare on plating2")
	await dispose(arena)


func _jet() -> void:
	for ward in [false, true]:
		reset_state()
		var arena := make_arena()
		var enemy = _spawn(arena)
		var player := make_player(arena, Vector2(1500, 480))
		await frames(2)
		enemy.move_speed = 0
		for i in range(260):
			if enemy.state == enemy.State.TELL:
				break
			await frames(1)
		check_eq(enemy.state, enemy.State.TELL, "natural four-second jet tell")
		player.place_at(enemy.global_position + Vector2(130, 0))
		player.facing = Vector2.LEFT
		if ward:
			Input.action_press(&"ward")
		await _capture("automaton-tell")
		await frames(40)
		check_eq(enemy.state, enemy.State.JET, ".6s warning then jet")
		check(is_instance_valid(enemy._jet), "real jet hitbox")
		check(enemy._fire_art != null, "painted jet texture loads")
		var jet_shape := enemy._jet.get_child(0) as CollisionShape2D
		check_eq((jet_shape.shape as RectangleShape2D).size, Vector2(192, 64), "jet area unchanged")
		check_eq(jet_shape.position, Vector2(96, 0), "jet starts at automaton")
		check_eq(enemy._jet.damage, 1, "jet damage unchanged")
		await _capture("automaton-jet")
		await frames(44)
		check_eq(enemy.state, enemy.State.VENT, ".8s jet then vent")
		check(not is_instance_valid(enemy._jet), "jet cleaned")
		check_eq(GameState.health, 6 if ward else 5, "front ward blocks actual jet")
		await _capture("automaton-vent")
		await frames(91)
		check_eq(enemy.state, enemy.State.WALK, "natural vent closes after1.5s")
		# Controlled timer advancement reaches a live jet to verify immediate reset cleanup.
		enemy._cycle = 0
		player.place_at(Vector2(1500, 480))
		await frames(40)
		check(is_instance_valid(enemy._jet), "live jet before reset")
		var live: Hitbox = enemy._jet
		enemy.reset_fight()
		check(not live.active, "reset disables jet immediately")
		check(not is_instance_valid(enemy._jet), "reset clears jet reference")
		release_inputs()
		await dispose(arena)


func _lifecycle() -> void:
	reset_state()
	var arena := make_arena()
	var scene := load("res://tests/fixtures/gallery/wick_automaton.tscn") as PackedScene
	check(scene != null, "gallery loads")
	if scene != null:
		var room := scene.instantiate() as Room
		arena.add_child(room)
		for i in range(2):
			room.enter()
			await frames(2)
			check_eq(room.get_enemies().size(), 1, "one automaton on room reentry")
			check_eq(room.get_enemies()[0].hp, 30, "reentry full HP")
			room.leave()
		await dispose(room)
	var enemy = _spawn(arena)
	await frames(2)
	enemy.hp = 10
	enemy.stun(1.5)
	enemy.reset_fight()
	await frames(2)
	check_eq(enemy.hp, 30, "reset full HP")
	check(not enemy.is_stunned(), "reset clears stun")
	enemy.apply_damage(99, enemy.global_position, 0)
	check(GameState.has_flag(&"mini_cave_9_4"), "persistent mini flag")
	check(not enemy.contact_hitbox.active, "lethal contact disabled")
	Events.player_died.emit()
	check(enemy.is_dying(), "player death cannot revive defeated miniboss")
	await frames(100)
	var drops := arena.get_children().filter(func(n: Node) -> bool: return n is PickupBase)
	check_eq(drops.size(), 4, "only four fixed drops")
	var kinds: Array = []
	for drop in drops:
		kinds.append(drop.kind)
		check(drop.timeout > 0, "timed drop")
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
