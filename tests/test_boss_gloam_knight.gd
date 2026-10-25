extends TestCase
## Positioned real-boots and attack probes; no continuous cave or human-balance claim.
const GALLERY := "res://tests/fixtures/gallery/B07.tscn"
const SCENE := "res://scenes/enemies/bosses/gloam_knight.tscn"


func run() -> void:
	await _geometry_and_boots()
	await _dive_and_phases()
	await _ward_and_slash()
	await _real_dodge()
	await _fall_api()


func _fixture() -> Room:
	var packed := load(GALLERY) as PackedScene
	check(packed != null, "gallery loads")
	var room := packed.instantiate() as Room
	add_child(room)
	room.enter()
	return room


func _geometry_and_boots() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/GloamKnight")
	var player := make_player(room, Vector2(960, 192))
	player.set_hurtbox_enabled(self, false)
	check_eq(boss.hp, 36, "36HP")
	check_eq(boss.body_radius, 44.0, "44px body")
	check_eq(boss.contact_damage, 3, "contact3")
	check(
		not get_tree().get_nodes_in_group(&"pit_zone").is_empty(),
		"real P04 pit subclasses instantiated"
	)
	for y in range(1, 9):
		for x in range(1, 19):
			var point := Vector2(x * 96 + 48, y * 96 + 48)
			var held := false
			for pit in get_tree().get_nodes_in_group(&"pit_zone"):
				if pit.process_mode != Node.PROCESS_MODE_DISABLED and pit.holds(point):
					held = true
			check_eq(held, boss.island_at(point) == -1, "exact island/pit tile complement")
	await frames(3)
	player.place_at(Vector2(960, 240))
	player.facing = Vector2.DOWN
	Input.action_press(&"attack")
	await frames(10)
	Input.action_release(&"attack")
	check_eq(boss.hp, 36, "entry hook cannot reach central island")
	player.place_at(Vector2(960, 330))
	await frames(3)
	check_near(player.global_position.y, 192, 1, "fall returns fixed island A")
	check_eq(GameState.health, 4, "fall costs2")
	GameState.full_heal()
	await seconds(1)
	player.place_at(Vector2(960, 240))
	player.facing = Vector2.DOWN
	GameState.acquire_item(&"skitter_boots")
	GameState.set_active_item(&"skitter_boots")
	check(player.use_item(), "real boots launch A to C")
	await seconds(0.45)
	check_near(player.global_position.y, 432, 1, "192px leap lands on C")
	check_eq(GameState.health, 6, "successful leap avoids pit damage")
	await seconds(0.5)
	player.facing = Vector2.DOWN
	Input.action_press(&"attack")
	await frames(9)
	Input.action_release(&"attack")
	check(boss.hp < 36, "real hook reaches boss after leap")
	check(not boss.is_arena_locked(), "no retreat barrier")
	await dispose(room)


func _dive_and_phases() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/GloamKnight")
	var player := make_player(room, Vector2(960, 192))
	player.set_hurtbox_enabled(self, false)
	await seconds(1.6)
	boss.dive_left = 0
	await frames(2)
	check_eq(boss.mode, &"crouch", "dive has0.5s crouch")
	await seconds(0.5)
	check_eq(boss.mode, &"air", "takeoff after warning")
	check(not boss.visible and not boss.hurtbox.enabled, "airborne untargetable")
	var fixed: Vector2 = boss.target
	player.place_at(Vector2(1100, 192))
	await seconds(0.55)
	check_eq(boss.mode, &"recover", "landing after0.5air")
	check_eq(boss.global_position, fixed, "landing target fixed at takeoff")
	check(not boss.invulnerable, "landing recovery hittable")
	await seconds(1.0)
	check(boss.mode != &"recover", "one second recovery ends")
	boss.apply_damage(18, boss.global_position, 0)
	check_eq(boss.phase, 2, "18HP second phase")
	await seconds(1.3)
	await frames(3)
	var collapsed := 0
	for pit in boss.arena.get_children():
		if (
			pit.has_method("holds")
			and pit.get_meta("side_island", false)
			and pit.process_mode != Node.PROCESS_MODE_DISABLED
		):
			collapsed += 1
	check_eq(collapsed, 2, "W/E become pit")
	check_eq(boss.island_at(Vector2(336, 480)), -1, "W no longer safe")
	boss.dive_left = 0
	await seconds(1.2)
	var rings := 0
	for hazard in boss._hazards:
		if is_instance_valid(hazard) and hazard.get("kind") == &"ring":
			rings += 1
			check_eq(hazard.box.damage, 2, "phase2ring damage2")
			check_eq(hazard.box.knockback, 0.0, "ring has0knockback")
	check(rings > 0, "phase2landing emits expanding ring")
	room.leave()
	await frames(3)
	room.enter()
	await frames(3)
	boss = room.get_node("Enemies/GloamKnight")
	check_eq(boss.hp, 36, "actual room reentry restores36HP")
	check_eq(boss.phase, 1, "actual room reentry restores phase1")
	for pit in boss.arena.get_children():
		if pit.has_method("holds") and pit.get_meta("side_island", false):
			check_eq(pit.process_mode, Node.PROCESS_MODE_DISABLED, "reentry restores side floor")

	Events.player_died.emit()
	await seconds(1.7)
	check_eq(boss.hp, 36, "death reset fullHP")
	check_eq(boss.phase, 1, "death reset phase1")
	check_eq(boss.island_at(Vector2(336, 480)), 3, "reset restores side island")
	for pit in boss.arena.get_children():
		if pit.has_method("holds") and pit.get_meta("side_island", false):
			check_eq(pit.process_mode, Node.PROCESS_MODE_DISABLED, "reset disables crumbled pits")
	var lethal := make_hitbox(room, boss.global_position, Layers.Team.PLAYER, 99, 60)
	lethal.kind = &"hook"
	await frames(3)
	await dispose(lethal)
	check(boss.is_dying(), "death throes")
	check(not boss.contact_hitbox.active, "death contact harmless")
	check(GameState.has_flag(&"boss_cave_7_11_defeated"), "canonical persistent defeat")
	await seconds(1.6)
	var scene := load(SCENE) as PackedScene
	check(scene != null, "boss scene loads")
	var retired = scene.instantiate()
	room.get_node("Enemies").add_child(retired)
	check(retired.is_dead and not retired.visible, "persistent boss stays dead")
	check(retired.death_drops.is_empty(), "no persistent rewards embedded")
	await dispose(room)


func _ward_and_slash() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(600, 480))
	var boss = make_enemy(arena, SCENE, Vector2(900, 480))
	await seconds(1.6)
	player.facing = Vector2.RIGHT
	Input.action_press(&"ward")
	await frames(3)
	boss.aim = Vector2.LEFT
	boss._fire_lance()
	var bolt = get_tree().get_nodes_in_group(&"projectiles")[0]
	check_near(bolt.speed, 420, 0.1, "lance speed420")
	check_eq(bolt.hitbox.damage, 2, "lance damage2")
	check_eq(bolt.hitbox.knockback, 0.0, "lance no knockback")
	var health := GameState.health
	await seconds(0.8)
	check_eq(GameState.health, health, "real ward blocks actual lance")
	boss.global_position = Vector2(720, 480)
	boss.aim = Vector2.LEFT
	boss._attack(&"slash", boss.global_position)
	await frames(5)
	check_eq(GameState.health, health - 3, "real slash pierces ward")
	check_near(player.global_position.x, 600, 1, "slash never knocks toward pit")
	release_inputs()
	await dispose(arena)


func _real_dodge() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/GloamKnight")
	var player := make_player(room, Vector2(960, 240))
	GameState.acquire_item(&"skitter_boots")
	GameState.set_active_item(&"skitter_boots")
	await seconds(1.6)
	boss.dive_left = 0
	await seconds(0.6)
	check_eq(boss.mode, &"air", "real dodge starts at takeoff")
	player.facing = Vector2.DOWN
	check(player.use_item(), "actual boots dodge fixed landing marker")
	await seconds(0.6)
	check_eq(GameState.health, 6, "boots carry player clear of damage4 landing")
	check_near(player.global_position.y, 432, 1, "dodge reaches next island safely")
	check_eq(boss.target, Vector2(960, 240), "dive does not track airborne player")
	await dispose(room)


func _fall_api() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/GloamKnight")
	var player := make_player(room, Vector2(960, 192))
	await frames(3)
	check(player.take_damage(1, player.global_position, 0), "ordinary hit starts real i-frames")
	check(player.is_invulnerable(), "player has hit immunity before fall")
	player.place_at(Vector2(960, 330))
	await frames(3)
	check_eq(GameState.health, 3, "genuine pit costs2 despite hit i-frames")
	check_eq(player.global_position, Vector2(960, 192), "public fall API returns to island A")
	check_eq(boss.hp, 36, "nonlethal fall does not reset or damage boss")
	var pit: Node2D
	for zone in get_tree().get_nodes_in_group(&"pit_zone"):
		if zone.holds(Vector2(960, 330)):
			pit = zone
	check(pit != null, "real arena pit found")
	var safe := player.global_position
	pit._fall(player)
	check_eq(GameState.health, 3, "safe-ground fall callback rejected")
	check_eq(player.global_position, safe, "rejected fall never relocates player")
	await frames(3)
	player.place_at(Vector2(960, 330))
	await frames(3)
	check_eq(GameState.health, 1, "new fall after safe ground charges2 again")
	check_eq(player.global_position, Vector2(960, 192), "second fall returns A")
	await frames(3)
	player.place_at(Vector2(960, 330))
	await frames(3)
	check(player.is_dead(), "lethal fall uses real player death flow")
	check_eq(player.global_position, Vector2(960, 330), "lethal fall is not relocated")
	check_eq(boss.phase, 1, "player death keeps normal boss reset pipeline")
	await dispose(room)
