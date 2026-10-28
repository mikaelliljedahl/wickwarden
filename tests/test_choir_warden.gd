extends TestCase
## The real sustained cone, front/back ward, actual moth interruption and hook opening.

const SCENE := "res://scenes/enemies/minibosses/choir_warden.tscn"


func run() -> void:
	SaveGame.enabled = false
	await _poses()
	await _fixture_reentry()
	await _cycle()
	await _real_ward_geometry()
	await _real_tools()
	await _lifecycle()


func _poses() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = _enemy(arena)
	await frames(2)
	check(enemy.visual is SpriteVisual, "painted choir visual loads")
	if enemy.visual is SpriteVisual:
		var visual: SpriteVisual = enemy.visual
		for direction in [Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT]:
			for state in [enemy.State.TELEGRAPH, enemy.State.SING, enemy.State.RECOVER]:
				enemy.state = state
				enemy._aim = direction
				enemy._process(0.0)
				var suffix := "side" if direction.x != 0 else ("up" if direction.y < 0 else "down")
				var base: String = ["inhale", "note", "recover"][state - 1]
				check_eq(visual.animation, StringName(base + "_" + suffix), "directional pose")
				check_eq(visual.flip_h, direction == Vector2.LEFT, "left mirrored")
		visual.sprite_frames.remove_animation(&"inhale_up")
		enemy.state = enemy.State.TELEGRAPH
		enemy._aim = Vector2.UP
		enemy._process(0.0)
		check_eq(visual.animation, &"walk_up", "missing action falls back to walk")
		visual.sprite_frames.remove_animation(&"walk_up")
		enemy._process(0.0)
		check(enemy.visual is Placeholder, "missing walk falls back to placeholder")
	check(not SaveGame.enabled, "saves disabled")
	await dispose(arena)


func _enemy(arena: Node) -> EnemyBase:
	var scene := load(SCENE) as PackedScene
	check(scene != null, "choir scene loads")
	if scene == null:
		return null
	var enemy := scene.instantiate() as EnemyBase
	enemy.position = Vector2(600, 480)
	arena.add_child(enemy)
	return enemy


func _wait_state(enemy: EnemyBase, target: int, limit := 400) -> int:
	for i in range(limit):
		if enemy.state == target:
			return i
		await frames(1)
	check(false, "bounded choir state reached")
	return limit


func _fixture_reentry() -> void:
	reset_state()
	var scene := load("res://tests/fixtures/gallery/choir_warden.tscn") as PackedScene
	check(scene != null, "choir fixture loads")
	if scene == null:
		return
	var arena := make_arena()
	var room := scene.instantiate() as Room
	arena.add_child(room)
	for i in range(2):
		room.enter()
		await frames(2)
		check_eq(room.get_enemies().size(), 1, "actual Room reentry has one singer")
		var enemy = room.get_enemies()[0]
		check_eq(enemy.hp, 20, "room reentry restores fullHP")
		check(not is_instance_valid(enemy._cone), "room reentry leaves no singing hazard")
		room.leave()
	await dispose(arena)


func _cycle() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = _enemy(arena)
	var player := make_player(arena, Vector2(1700, 480))
	await frames(2)
	check_eq(enemy.hp, 20, "HP20")
	check_eq(enemy.contact_damage, 2, "contact2")
	check_near(enemy.velocity.length(), 100, .01, "walk100")
	check_eq(enemy.knockback_scale, .5, "half hook knockback")
	check(enemy.has_node("Visual"), "Visual exists")
	var cue := enemy.get_node_or_null("SongCue") as Node2D
	check(cue != null, "song has a separate presentation cue")
	if cue != null:
		check(cue.material is CanvasItemMaterial, "song has a material")
		check_eq(
			(cue.material as CanvasItemMaterial).light_mode,
			CanvasItemMaterial.LIGHT_MODE_UNSHADED,
			"song remains visible in a dark room"
		)
		check(cue.note_texture != null, "song reuses the painted note art")
	await frames(290)
	check_eq(enemy.state, enemy.State.WALK, "note waits five seconds")
	await _wait_state(enemy, enemy.State.TELEGRAPH)
	check_eq(GameState.health, 6, "distant player safe on approach")
	await _capture("choir-warning")
	var elapsed := await _wait_state(enemy, enemy.State.SING)
	check_near(elapsed, 48, 2, "inhale .8s")
	check_eq(enemy._cone.damage, 2, "note damage2")
	var polygon := enemy._cone.get_child(0) as CollisionPolygon2D
	check_near(polygon.polygon[1].length(), 480.0, 0.01, "song collision reach unchanged")
	check(enemy._cone.once_per_target, "once per target per note")
	check(
		enemy._cone.blockable and not enemy._cone.block_destroys_carrier,
		"area ward negates without destroying singer"
	)
	await _capture("choir-note")
	elapsed = await _wait_state(enemy, enemy.State.RECOVER)
	check_near(elapsed, 90, 2, "note active1.5s")
	check(not is_instance_valid(enemy._cone), "cone removed at note end")
	await _capture("choir-recovery")
	elapsed = await _wait_state(enemy, enemy.State.WALK)
	check_near(elapsed, 84, 2, "closed mouth recovery1.4s")

	enemy.reset_fight()
	await _wait_state(enemy, enemy.State.SING)
	var live: Hitbox = enemy._cone
	check(live.active, "reset scenario starts in actual live song")
	enemy.reset_fight()
	check(not live.active, "reset disables live song immediately")
	check(not is_instance_valid(enemy._cone), "reset detaches the live cone")
	player.queue_free()
	await dispose(arena)


func _real_ward_geometry() -> void:
	for mode in ["front", "back", "none", "side", "far"]:
		reset_state()
		var arena := make_arena()
		var enemy = _enemy(arena)
		var player := make_player(arena, Vector2(1700, 480))
		await _wait_state(enemy, enemy.State.TELEGRAPH)
		var offset := Vector2(320, 0)
		if mode == "side":
			offset = Vector2(0, 320)
		elif mode == "far":
			offset = Vector2(550, 0)
		player.place_at(enemy.global_position + offset)
		player.facing = Vector2.RIGHT if mode == "back" else Vector2.LEFT
		if mode in ["front", "back"]:
			Input.action_press(&"ward")
		await frames(10)
		check_eq(GameState.health, 6, "actual inhale marker harmless")
		await _wait_state(enemy, enemy.State.SING)
		await frames(65)
		var safe: bool = mode in ["front", "side", "far"]
		check_eq(
			GameState.health,
			6 if safe else 4,
			"real90deg/r480 note respects front ward and geometry"
		)
		check(not enemy.is_dead and enemy.hp == 20, "area ward preserves singer")
		if not safe:
			check_eq(GameState.health, 4, "sustained cone never damages same target twice")
		release_inputs()
		await dispose(arena)


func _real_tools() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = _enemy(arena)
	var player := make_player(arena, Vector2(1700, 480))
	await _wait_state(enemy, enemy.State.SING)
	# Stand behind the committed cone to isolate real hook immunity while singing.
	player.place_at(enemy.global_position - Vector2(90, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 20, "real hook cannot damage open singing mouth")
	await frames(20)
	player.place_at(enemy.global_position - Vector2(240, 0))
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"tether_moth")
	check(player.use_item(), "actual moth launches during note")
	for i in range(35):
		await frames(1)
		if enemy.is_stunned():
			break
	check(enemy.is_stunned(), "real moth interrupts sustained note")
	check(enemy._stun_time <= 1.5, "moth clamp1.5")
	check(not is_instance_valid(enemy._cone), "actual moth removes live cone")
	check(not enemy.contact_hitbox.active, "stunned singer harmless")
	player.place_at(enemy.global_position - Vector2(90, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 18, "actual hook damages stunned closed mouth2")
	await _capture("choir-moth-opening")
	for i in range(140):
		if not enemy.is_stunned():
			break
		await frames(1)
	enemy.stun(2.0)
	check(not enemy.is_stunned(), "three-second moth immunity")
	enemy.reset_fight()
	check_eq(enemy.hp, 20, "reset fullHP")
	check(not enemy.is_stunned() and not enemy.is_knocked_back(), "reset real combat timers")
	check(not is_instance_valid(enemy._cone), "reset cancels all note hazards immediately")
	player.place_at(Vector2(1700, 480))
	await _wait_state(enemy, enemy.State.RECOVER, 600)
	player.place_at(enemy.global_position - enemy.facing_dir * 90)
	player.facing = enemy.facing_dir
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 18, "real hook damages natural1.4s recovery without moth")
	await dispose(arena)


func _lifecycle() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = _enemy(arena)
	enemy.arena_id = &"cave_6_4"
	var player := make_player(arena, Vector2(1700, 480))
	await _wait_state(enemy, enemy.State.SING)
	enemy.stun(1.5)
	enemy.apply_damage(99, enemy.global_position, 0.0)
	check(GameState.has_flag(&"mini_cave_6_4"), "canonical mini flag")
	check(not enemy.contact_hitbox.active and not enemy.is_stunned(), "lethal stun/contact cleared")
	check(not is_instance_valid(enemy._cone), "lethal hit disables note")
	check(not enemy.is_arena_locked(), "never shutters arena")
	player.queue_free()
	await frames(100)
	var drops := arena.get_children().filter(func(n: Node) -> bool: return n is PickupBase)
	check_eq(drops.size(), 4, "four fixed drops only")
	var kinds: Array = []
	for drop in drops:
		kinds.append(drop.kind)
		check(drop.timeout > 0.0, "timed drops")
	check_eq(kinds.count(&"ember"), 2, "two embers")
	check_eq(kinds.count(&"brass_coin"), 2, "two coins, no tool/core")
	var scene := load(SCENE) as PackedScene
	check(scene != null, "retirement scene loads")
	if scene != null:
		var retired = scene.instantiate()
		retired.arena_id = &"cave_6_4"
		arena.add_child(retired)
		check(retired.is_dead and not retired.visible, "defeated singer stays gone")
	await dispose(arena)


func _capture(label: String) -> void:
	if OS.get_environment("WICK_MB3_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		get_viewport().get_texture().get_image().save_png("/tmp/mb3-" + label + ".png"),
		OK,
		"actual state capture " + label
	)
