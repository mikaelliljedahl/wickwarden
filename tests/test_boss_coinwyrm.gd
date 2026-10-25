extends TestCase
## Controlled positioned fixtures verify mechanics, not human balance.

const GALLERY := "res://tests/fixtures/gallery/B08.tscn"


func run() -> void:
	await _challenge()
	await _windows_and_anchor()
	await _attacks()
	await _physical_finish()
	await _finish()


func _fixture() -> Room:
	var scene := load(GALLERY) as PackedScene
	check(scene != null, "gallery loads")
	var room := scene.instantiate() as Room
	add_child(room)
	room.enter()
	return room


func _reel(player: Player, plate: Node2D) -> void:
	player.place_at(plate.global_position + Vector2(0, 200))
	player.facing = Vector2.UP
	check(player.use_item(), "actual reel launches")
	await seconds(1.4)


func _challenge() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Coinwyrm")
	var player := make_player(room, Vector2(1728, 480))
	player.set_hurtbox_enabled(self, false)
	GameState.acquire_item(&"reel_line")
	GameState.set_active_item(&"reel_line")
	check_eq(GameState.currency, 0, "empty wallet fixture")
	check(boss.is_in_intro(), "intro active")
	await seconds(1.6)
	check_eq(boss.state, &"quiver", "0.9s heap tell")
	check(not boss.hurtbox.enabled, "submerged head untargetable")
	check(boss.global_position.distance_to(player.global_position) >= 288, "heap keeps distance")
	await seconds(1)
	check_eq(boss.plates.size(), 3, "three reelable plates")
	var hit := make_hitbox(room, boss.global_position, Layers.Team.PLAYER, 4, 100)
	hit.kind = &"hook"
	await frames(4)
	check_eq(boss.hp, 36, "hook cannot bypass armour")
	await dispose(hit)
	var plate = boss.plates[1]
	await _reel(player, plate)
	check_eq(boss.plates.size(), 2, "real tip removes one plate")
	check_eq(GameState.currency, 5, "five bits drop and collect at feet")
	await _reel(player, boss.plates[0])
	await _reel(player, boss.plates[0])
	check(boss.bare, "third real reel exposes head")
	check_eq(boss.plates.size(), 0, "no plates remain")
	var left: float = boss.state_left
	await seconds(0.5)
	check(boss.bare and boss.state_left < left, "bare window persists")
	player.place_at(boss.global_position + Vector2(0, 108))
	player.facing = Vector2.UP
	Input.action_press(&"attack")
	await frames(10)
	Input.action_release(&"attack")
	check_eq(boss.hp, 34, "actual hook damages bare head")
	boss.reset_fight()
	await frames(3)
	check_eq(boss.hp, 36, "reset full health")
	check_eq(boss.phase, 1, "reset phase one")
	check(boss.is_in_intro(), "reset intro")
	check(boss.plates.is_empty(), "reset clears plates")
	check(not boss.is_arena_locked(), "retreat stays open")
	await dispose(room)


func _attacks() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Coinwyrm")
	var player := make_player(room, Vector2(1536, 480))
	player.facing = Vector2.LEFT
	Input.action_press(&"ward")
	await seconds(5.1)
	var bolts := get_tree().get_nodes_in_group(&"projectiles")
	check_eq(bolts.size(), 5, "five coin fan")
	for bolt in bolts:
		check_eq(bolt.damage, 2, "coin damage two")
		check_near(bolt.speed, 280, 0.01, "fan speed280")
		check(bolt.hitbox.blockable, "coins wardable")
	var blocked: Array[StringName] = []
	for bolt in bolts:
		bolt.destroyed.connect(func(reason: StringName) -> void: blocked.append(reason))
	await seconds(1.8)
	check(&"ward" in blocked, "actual coin volley blocked by real ward")
	Input.action_release(&"ward")
	# Controlled phase transition: challenge above proves physical armour removal.
	boss.apply_damage(16, boss.global_position, 0)
	check_eq(boss.phase, 2, "20 HP phase two")
	await seconds(2.2)
	check_eq(boss.plates.size(), 4, "phase two crown plate")
	player.place_at(Vector2(900, 288))
	GameState.max_health = 40
	GameState.full_heal()
	await seconds(0.8)
	check_eq(GameState.health, 37, "real tail row deals three")
	await seconds(1.8)
	bolts = get_tree().get_nodes_in_group(&"projectiles")
	check_eq(bolts.size(), 8, "phase two eight coin ring")
	for bolt in bolts:
		check_near(bolt.speed, 260, 0.01, "ring speed260")
	Events.player_died.emit()
	await frames(3)
	check_eq(boss.hp, 36, "death reset health")
	check(get_tree().get_nodes_in_group(&"projectiles").is_empty(), "reset clears coins")
	check(player != null, "real player fixture")
	await dispose(room)


func _finish() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Coinwyrm")
	await seconds(2.6)
	# Controlled lethal fixture checks persistence independently of combat duration.
	boss.apply_damage(36, boss.global_position, 0)
	check(not boss.drops_enabled, "random loot disabled")
	check(boss.is_dying(), "death throes begin")
	check(GameState.has_flag(&"boss_cave_8_12_defeated"), "canonical defeat flag")
	check(not boss.contact_hitbox.active, "death contact off")
	await seconds(1.6)
	check(not GameState.has_flag(&"frag_c8"), "room owns persistent fragment")
	for pickup in get_tree().get_nodes_in_group(&"pickups"):
		check(pickup.kind == &"ember", "only timed embers spawned: %s" % pickup.kind)
	await dispose(room)
	room = _fixture()
	boss = room.get_node("Enemies/Coinwyrm")
	await frames(3)
	check(boss.is_dead and not boss.visible, "defeated reload retired")
	await dispose(room)


func _windows_and_anchor() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Coinwyrm")
	var player := make_player(room, Vector2(1728, 480))
	GameState.max_health = 40
	GameState.full_heal()
	await seconds(2.5)
	player.place_at(boss.global_position + Vector2(100, 0))
	# Contact is disabled only for this isolated bite probe.
	boss.set_contact_enabled(false)
	await seconds(0.5)
	check_eq(GameState.health, 36, "real bite cone deals four after tell")
	player.set_hurtbox_enabled(self, false)
	GameState.acquire_item(&"reel_line")
	GameState.set_active_item(&"reel_line")
	await _reel(player, boss.plates[1])
	check_eq(boss.plates.size(), 2, "one plate removed for regrow probe")
	await seconds(2.2)
	check_eq(boss.plates.size(), 3, "one plate regrows at four seconds")
	player.place_at(Vector2(672, 400))
	player.facing = Vector2.UP
	check(player.use_item(), "real reel to pillar ring")
	await seconds(0.2)
	check(player.is_airborne(), "anchor pull is airborne")
	check(not player.take_damage(4, player.global_position), "anchor pull rejects damage")
	await seconds(0.7)
	check_near(
		player.global_position.distance_to(Vector2(672, 192)),
		72,
		1,
		"ring pull stops72px from pillar"
	)
	await dispose(room)


func _physical_finish() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Coinwyrm")
	var player := make_player(room, Vector2(1728, 480))
	player.set_hurtbox_enabled(self, false)
	GameState.acquire_item(&"reel_line")
	GameState.set_active_item(&"reel_line")
	for tick in range(1000):
		if boss.is_dying():
			break
		if boss.state != &"rear" or boss.is_pausing():
			await frames(12)
			continue
		if not boss.plates.is_empty():
			var index := 1 if boss.plates.size() >= 3 else 0
			await _reel(player, boss.plates[index])
			continue
		player.place_at(boss.global_position + Vector2(0, 108))
		player.facing = Vector2.UP
		Input.action_press(&"attack")
		await frames(10)
		Input.action_release(&"attack")
		await frames(24)
	check(boss.is_dying(), "real reels and hook finish both phases")
	check(GameState.has_flag(&"boss_cave_8_12_defeated"), "physical finish persists")
	await dispose(room)
