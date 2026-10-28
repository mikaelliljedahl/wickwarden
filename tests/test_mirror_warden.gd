extends TestCase
## Controlled encounter checks use real hook/moth collisions; braziers replace the later jar.

const SCENE := "res://scenes/enemies/minibosses/mirror_warden.tscn"


func run() -> void:
	await _fixture_reentry()
	await _identity_and_swap()
	await _real_braziers()
	await _real_combo()
	await _real_moth_and_reset()
	await _live_reset()
	await _lifecycle()


func _enemy(arena: Node, at := Vector2(800, 480)) -> EnemyBase:
	var scene := load(SCENE) as PackedScene
	check(scene != null, "mirror scene loads")
	if scene == null:
		return null
	var enemy := scene.instantiate() as EnemyBase
	enemy.position = at
	arena.add_child(enemy)
	return enemy


func _wait_state(enemy: EnemyBase, target: int, limit := 300) -> int:
	for i in range(limit):
		if enemy.state == target:
			return i
		await frames(1)
	check(false, "bounded mirror state reached")
	return limit


func _fixture_reentry() -> void:
	reset_state()
	var scene := load("res://tests/fixtures/gallery/mirror_warden.tscn") as PackedScene
	check(scene != null, "gallery loads with actual brazier script resources")
	if scene == null:
		return
	var arena := make_arena()
	var room := scene.instantiate() as Room
	arena.add_child(room)
	for i in range(3):
		room.enter()
		await frames(2)
		var enemies := room.get_enemies()
		check_eq(enemies.size(), 1, "actual Room reentry has one real enemy")
		if enemies.size() == 1:
			var enemy = enemies[0]
			check_eq(enemy.decoys.size(), 2, "Room snapshot creates only two managed reflections")
			var warnings := enemy.get_children().filter(func(n: Node) -> bool: return n.name == "SlashWarning")
			check_eq(warnings.size(), 1, "Room reentry has one warning")
			var helpers := 0
			for child in enemy.get_children():
				if child.name.begins_with("Reflection"):
					helpers += 1
			check_eq(helpers, 2, "no copied reflection ghosts outside active targets")
			check_eq(enemy.hp, 18, "room reentry starts fullHP")

		room.leave()
	GameState.set_flag(&"mini_cave_5_4")
	room.enter()
	await frames(2)
	check_eq(room.get_enemies().size(), 0, "real Room flag prevents miniboss respawn")
	var retired = room.get_node("Enemies").get_child(0)
	check_eq(retired.decoys.size(), 0, "retired Room copy has no reflection helpers")
	var retired_helpers := retired.get_children().filter(
		func(n: Node) -> bool: return n.name.begins_with("Reflection")
	)
	check_eq(retired_helpers.size(), 0, "retired Room copy contains no hidden ghost sensors")
	await dispose(arena)


func _identity_and_swap() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = _enemy(arena)
	await frames(2)
	check_eq(enemy.hp, 18, "HP18")
	check_eq(enemy.contact_damage, 2, "contact2")
	check_eq(enemy.move_speed, 150.0, "walk150")
	check_eq(enemy.knockback_scale, .5, "half knockback")
	check(enemy.has_node("Visual"), "real Visual")
	check_eq(enemy.decoys.size(), 2, "two reflections")
	for decoy in enemy.decoys:
		check(decoy.has_node("Visual"), "decoy Visual")
		check_eq(decoy.find_children("*", "Hurtbox", true, false).size(), 0, "no decoy Hurtbox")
		check_eq(decoy.find_children("*", "Hitbox", true, false).size(), 0, "no decoy attack")
	var original: Vector2 = enemy.global_position
	var first: Vector2 = enemy.decoys[0].global_position
	var second: Vector2 = enemy.decoys[1].global_position
	await frames(295)
	check_eq(enemy.global_position, original, "no swap before five seconds")
	await frames(6)
	check_eq(enemy.global_position, first, "real moves into first reflection slot")
	check_eq(enemy.decoys[0].global_position, second, "first reflection takes second slot")
	check_eq(enemy.decoys[1].global_position, original, "second reflection takes real slot")
	check(enemy._flash_left > 0.0, "swap flashes")
	await _capture("mirror-swap")
	# Hold AI to isolate an actual hook hitting a reflection sensor, without a Hurtbox.
	enemy.set_physics_process(false)
	var decoy: Node2D = enemy.decoys[0]
	var player := make_player(arena, decoy.global_position + Vector2(0, 90))
	player.facing = Vector2.UP
	await frames(3)
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 18, "actual decoy hook never damages real HP")
	check(enemy._reveal_left > 0.0, "real hook cracks decoy and reveals true Warden")
	check_near(enemy._reveal_left, 1.0, .01, "reveal lasts one second")
	await _capture("mirror-cracked")
	enemy.set_physics_process(true)
	await frames(62)
	check_eq(enemy._reveal_left, 0.0, "reveal expires")
	await dispose(arena)


func _real_braziers() -> void:
	reset_state()
	var foreign := make_arena()
	var outside := Brazier.new()
	outside.position = Vector2(1600, 100)
	foreign.add_child(outside)
	outside.ignite()
	var arena := make_arena()
	var braziers: Array[Brazier] = []
	for i in range(4):
		var brazier := Brazier.new()
		brazier.position = Vector2(200 + (i % 2) * 1400, 200 + (i / 2) * 560)
		brazier.brazier_id = StringName("mb3_test_%d" % i)
		arena.add_child(brazier)
		braziers.append(brazier)
	var enemy = _enemy(arena)
	var player := make_player(arena, Vector2(200, 290))
	await frames(2)
	enemy.set_physics_process(false)
	check_eq(enemy.lit_brazier_count(), 0, "ignores lit brazier in another room")
	check(not GameState.has_item(&"glow_jar"), "base-kit route holds no later jar")
	for i in range(4):
		player.place_at(braziers[i].global_position + Vector2(0, 90))
		player.facing = Vector2.UP
		await frames(3)
		Input.action_press(&"attack")
		await frames(8)
		Input.action_release(&"attack")
		await frames(20)
		enemy._refresh_decoys()
		check(braziers[i].lit, "real hook lights corner brazier")
		check(GameState.has_flag(braziers[i].flag_name()), "brazier persists canonically")
		check_eq(enemy.lit_brazier_count(), i + 1, "counts room braziers only")
		for decoy in enemy.decoys:
			check_near(decoy.modulate.a, 1.0 - .25 * (i + 1), .001, "quarter fade per lit brazier")
	check(not enemy.decoys[0].visible and not enemy.decoys[1].visible, "four lights remove decoys")
	check(not enemy.decoys[0].enabled, "invisible decoy cannot receive false hits")
	await _capture("mirror-four-braziers")
	enemy.reset_fight()
	check(not enemy.decoys[0].visible, "reset respects persisted corner lights")
	await dispose(arena)
	await dispose(foreign)


func _real_combo() -> void:
	for inside in [true, false]:
		reset_state()
		var arena := make_arena()
		var enemy = _enemy(arena)
		var player := make_player(arena, Vector2(1400, 480))
		await _wait_state(enemy, enemy.State.TELEGRAPH)
		var warning = enemy.get_node("SlashWarning")
		check(warning.showing_warning(), "painted cue follows actual telegraph")
		check(not warning.showing_active(), "no active slash during the tell")
		check(warning.texture != null, "painted cue loads")
		var image: Texture2D = warning.texture
		warning.texture = null
		warning.queue_redraw()
		await frames(1)
		check(warning.showing_warning(), "missing texture retains fallback warning")
		warning.texture = image
		check_near(enemy.velocity.length(), 0, .01, "commits facing and stops during warning")
		var offset: Vector2 = enemy._aim * 110.0 if inside else enemy._aim.rotated(PI / 2) * 110.0
		player.place_at(enemy.global_position + offset)
		player.facing = -offset.normalized()
		Input.action_press(&"ward")
		await frames(10)
		check_eq(GameState.health, 6, "slash telegraph harmless")
		await _capture("mirror-slash-warning")
		var elapsed := await _wait_state(enemy, enemy.State.COMBO)
		check_near(elapsed + 11, 30, 2, "combo warns .5s")
		check(not warning.showing_warning(), "warning ends at the active combo")
		check(warning.showing_active(), "painted slash begins with the real combo")
		warning.texture = null
		warning.queue_redraw()
		await frames(1)
		check(warning.showing_active(), "missing texture retains the active fallback")
		warning.texture = image
		await frames(4)
		check_eq(
			GameState.health,
			4 if inside else 6,
			"real100degree slash respects arc; ward cannot block"
		)
		check_eq(enemy._slash.damage, 2, "slash damage2")
		check(not enemy._slash.blockable, "melee ward disabled")
		var start_slashes: int = enemy._slashes
		await frames(18)
		check_eq(enemy._slashes, start_slashes + 1, ".3s between actual slash activations")
		await frames(18)
		check_eq(enemy._slashes, 3, "exactly three slashes")
		release_inputs()
		await dispose(arena)


func _real_moth_and_reset() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = _enemy(arena)
	var player := make_player(arena, Vector2(1200, 480))
	await _wait_state(enemy, enemy.State.TELEGRAPH)
	player.place_at(enemy.global_position + Vector2(250, 0))
	player.facing = Vector2.LEFT
	GameState.acquire_item(&"tether_moth")
	check(player.use_item(), "real moth launches toward real figure")
	for i in range(35):
		await frames(1)
		if enemy.is_stunned():
			break
	check(enemy.is_stunned(), "actual moth stuns real Warden")
	check(enemy._stun_time <= 1.5, "stun clamp1.5")
	check(not enemy.contact_hitbox.active, "stunned real figure harmless")
	player.place_at(enemy.global_position + Vector2(90, 0))
	player.facing = Vector2.LEFT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 16, "actual hook damages real figure2")

	player.place_at(Vector2(1700, 900))
	for i in range(140):
		if not enemy.is_stunned():
			break
		await frames(1)
	enemy.stun(2.0)
	check(not enemy.is_stunned(), "three-second immunity stops immediate repeat moth stun")
	await frames(182)
	enemy.stun(2.0)
	check(enemy.is_stunned(), "stun works after three-second immunity expires")
	enemy.reset_fight()
	check_eq(enemy.hp, 18, "reset fullHP")
	check(not enemy.is_stunned() and not enemy.is_knocked_back(), "reset tool timers")
	check(not is_instance_valid(enemy._slash) or not enemy._slash.active, "reset cancels slash")
	check_eq(enemy.decoys.size(), 2, "reset never duplicates reflections")
	await dispose(arena)


func _live_reset() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = _enemy(arena)
	make_player(arena, Vector2(1500, 480))
	await _wait_state(enemy, enemy.State.COMBO)
	check(enemy._slash.active, "reset scenario starts during actual live slash")
	var warning = enemy.get_node("SlashWarning")
	check(warning.showing_active(), "active visual follows live slash")
	enemy.reset_fight()
	check(not warning.showing_active(), "reset immediately clears the active visual")
	check(not enemy._slash.active, "reset immediately disables live slash")
	check_eq(enemy.decoys.size(), 2, "live reset keeps exactly two reflections")
	await dispose(arena)


func _lifecycle() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = _enemy(arena)
	enemy.arena_id = &"cave_5_4"
	await frames(2)
	enemy.stun(1.5)
	enemy.apply_damage(99, enemy.global_position, 0.0)
	check(GameState.has_flag(&"mini_cave_5_4"), "canonical mini persistence")
	check(not enemy.contact_hitbox.active and not enemy.is_stunned(), "death clears stun/contact")
	check(not enemy.decoys[0].enabled, "death disables false targets immediately")
	check(not enemy.is_arena_locked(), "no arena lock")
	await frames(100)
	var drops := arena.get_children().filter(func(n: Node) -> bool: return n is PickupBase)
	check_eq(drops.size(), 4, "four fixed drops only")
	var kinds: Array = []
	for drop in drops:
		kinds.append(drop.kind)
		check(drop.timeout > 0.0, "timed drop")
	check_eq(kinds.count(&"ember"), 2, "two embers")
	check_eq(kinds.count(&"brass_coin"), 2, "two coins, no tools or cores")
	var scene := load(SCENE) as PackedScene
	check(scene != null, "retirement scene loads")
	if scene != null:
		var retired = scene.instantiate()
		retired.arena_id = &"cave_5_4"
		arena.add_child(retired)
		check(retired.is_dead and not retired.visible, "defeated figure stays dead on reentry")
		check_eq(retired.decoys.size(), 0, "retired encounter creates no false targets")
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
