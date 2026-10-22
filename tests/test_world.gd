extends TestCase
## World: room graph, camera slide (0.45 s), entry position, pausing during the slide, enemy
## respawn on entry, warp fade (0.3 s), cave lighting, death and respawn, HUD, walls.


func run() -> void:
	var world := await make_world()
	await _room_graph(world)
	await _start(world)
	await _walls(world)
	await _slide_east(world)
	await _slide_pauses_and_respawns(world)
	await _slide_vertical(world)
	await _cave(world)
	await _death_respawn(world)
	await _hud(world)
	await dispose(world)


func _wait_transition(world: World, max_frames: int = 120) -> int:
	var n := 0
	while world.is_transitioning() and n < max_frames:
		await frames(1)
		n += 1
	return n


func _room_graph(world: World) -> void:
	check_eq(world.rooms.size(), 7, "all seven placeholder rooms load")
	for id in [&"ow_0_0", &"ow_1_0", &"ow_2_0", &"ow_0_1", &"ow_1_1", &"ow_2_1", &"cave_1"]:
		check(world.rooms.has(id), "room %s exists" % id)
	var sides := {&"n": Vector2i.UP, &"s": Vector2i.DOWN, &"w": Vector2i.LEFT, &"e": Vector2i.RIGHT}
	var opposite := {&"n": &"s", &"s": &"n", &"w": &"e", &"e": &"w"}
	for id in world.rooms:
		var room: Room = world.rooms[id]
		check_eq(
			room.position,
			Vector2(room.grid) * Vector2(1920, 960),
			"%s sits at its grid origin" % id
		)
		for side in room.exits:
			var neighbor := world.rooms.values().filter(
				func(r: Room) -> bool: return r.grid == room.grid + sides[side]
			)
			check_eq(neighbor.size(), 1, "%s exit %s leads to a room" % [id, side])
			if neighbor.size() == 1:
				check(neighbor[0].has_exit(opposite[side]), "%s exit %s is mirrored" % [id, side])
	check(world.rooms[&"cave_1"].dark, "the cave is dark")
	check(not world.rooms[&"ow_0_0"].dark, "overworld rooms are lit")


func _start(world: World) -> void:
	check_eq(world.get_current_room_id(), &"ow_0_0", "the game starts in ow_0_0")
	check_eq(
		world.camera.position, Vector2(960, 420), "camera shows the room under the 120 px HUD band"
	)
	check(GameState.visited_rooms.has(&"ow_0_0"), "the start room is visited")
	check(
		world.get_room(&"ow_0_0").get_rect().has_point(world.player.global_position),
		"player is inside the start room"
	)
	check(world.get_room(&"ow_1_0").visible == false, "other rooms are hidden")
	check_near(world.player.get_lamp_radius(), 260.0, 0.5, "lamp light radius is 260 px")
	check(not world.player.lamp.enabled, "the lamp light is off in bright rooms")


func _walls(world: World) -> void:
	reset_state()
	var player := world.player
	world.start_at(&"ow_0_0")
	player.place_at(Vector2(480, 300))
	await frames(2)
	Input.action_press(&"move_up")
	await seconds(2.0)
	release_inputs()
	check(
		player.global_position.y >= 96.0 + 26.0 - 0.5, "the north wall (no exit) blocks the player"
	)
	check_eq(world.get_current_room_id(), &"ow_0_0", "still in the start room")
	player.place_at(Vector2(200, 480))
	await frames(2)
	Input.action_press(&"move_left")
	await seconds(2.0)
	release_inputs()
	check(player.global_position.x >= 96.0 + 26.0 - 0.5, "the west wall blocks the player")
	# The east edge has an exit gap at the middle only.
	player.place_at(Vector2(1700, 250))
	await frames(2)
	Input.action_press(&"move_right")
	await seconds(1.0)
	release_inputs()
	check(
		player.global_position.x <= 1920.0 - 96.0 - 26.0 + 0.5,
		"outside the gap the east wall blocks"
	)
	check_eq(world.get_current_room_id(), &"ow_0_0", "no room change through a wall")


func _slide_east(world: World) -> void:
	reset_state()
	var player := world.player
	world.start_at(&"ow_0_0")
	player.place_at(Vector2(1700, 480))
	await frames(2)
	Input.action_press(&"move_right")
	var guard := 0
	while not world.is_transitioning() and guard < 120:
		await frames(1)
		guard += 1
	release_inputs()
	check(world.is_transitioning(), "crossing the east edge starts a slide")
	check(not player.can_process(), "the player is frozen during the slide")
	var slide_frames := await _wait_transition(world)
	check(
		slide_frames >= 26 and slide_frames <= 29,
		"the slide takes 0.45 s (got %d frames)" % slide_frames
	)
	check_eq(world.get_current_room_id(), &"ow_1_0", "now in ow_1_0")
	check_eq(world.camera.position, Vector2(1920 + 960, 420), "camera arrived at the new room")
	check_near(
		player.global_position.x, 1920.0 + 96.0, 0.5, "player is placed 1 tile inside the new room"
	)
	check(player.can_process(), "the player is unfrozen after the slide")
	check(GameState.visited_rooms.has(&"ow_1_0"), "the new room is marked visited")
	check(world.get_room(&"ow_0_0").visible == false, "the old room is hidden")
	check(world.get_room(&"ow_1_0").is_entered, "the new room is entered")


func _slide_pauses_and_respawns(world: World) -> void:
	reset_state()
	var player := world.player
	world.start_at(&"ow_1_0")
	var next := world.get_room(&"ow_2_0")
	var template := EnemyBase.new()
	template.name = "Template"
	template.max_hp = 1
	template.drops_enabled = false
	next.register_template(&"Enemies", template)
	player.place_at(Vector2(1920 + 1700, 480))
	await frames(2)
	Input.action_press(&"move_right")
	var guard := 0
	while not world.is_transitioning() and guard < 120:
		await frames(1)
		guard += 1
	release_inputs()
	var enemies := _test_enemies(next)
	check_eq(enemies.size(), 1, "entering a room spawns its enemies")
	if enemies.size() == 1:
		check(not enemies[0].can_process(), "enemies are paused during the slide")
		check_eq(
			(enemies[0] as EnemyBase).room_rect,
			next.interior_rect(),
			"enemies are confined to the room interior"
		)
	await _wait_transition(world)
	enemies = _test_enemies(next)
	check(enemies.size() == 1 and enemies[0].can_process(), "enemies run after the slide")
	if enemies.size() == 1:
		(enemies[0] as EnemyBase).kill()
	await frames(3)
	check_eq(_test_enemies(next).size(), 0, "the enemy is dead")
	# Leave and come back: it respawns.
	player.place_at(Vector2(3840 + 96, 480))
	await frames(2)
	Input.action_press(&"move_left")
	guard = 0
	while not world.is_transitioning() and guard < 200:
		await frames(1)
		guard += 1
	release_inputs()
	await _wait_transition(world)
	check_eq(world.get_current_room_id(), &"ow_1_0", "walked back west")
	check_eq(_test_enemies(next).size(), 0, "a room you left holds no live enemies")
	player.place_at(Vector2(3840 - 96, 480))
	await frames(2)
	Input.action_press(&"move_right")
	guard = 0
	while not world.is_transitioning() and guard < 200:
		await frames(1)
		guard += 1
	release_inputs()
	await _wait_transition(world)
	check_eq(world.get_current_room_id(), &"ow_2_0", "re-entered the room")
	check_eq(_test_enemies(next).size(), 1, "enemies respawn when the player re-enters the room")


## The enemies a test registered itself (named "Template"); the room scene has its own.
func _test_enemies(room: Room) -> Array[Node]:
	return room.get_enemies().filter(func(e: Node) -> bool: return str(e.name).begins_with("Template"))


func _slide_vertical(world: World) -> void:
	reset_state()
	var player := world.player
	world.start_at(&"ow_0_0")
	player.place_at(Vector2(960, 700))
	await frames(2)
	Input.action_press(&"move_down")
	var guard := 0
	while not world.is_transitioning() and guard < 200:
		await frames(1)
		guard += 1
	release_inputs()
	await _wait_transition(world)
	check_eq(world.get_current_room_id(), &"ow_0_1", "a slide south reaches ow_0_1")
	check_near(player.global_position.y, 960.0 + 96.0, 0.5, "placed 1 tile inside, south")
	check_eq(world.camera.position, Vector2(960, 960 + 420), "camera follows south")


func _cave(world: World) -> void:
	reset_state()
	world.start_at(&"ow_1_1", &"FromCave")
	var player := world.player
	world.warp_to(&"cave_1")
	check(world.is_transitioning(), "warp_to starts a fade")
	check(not player.can_process(), "the player is frozen during the fade")
	await seconds(0.15)
	check(world.fade_rect.color.a > 0.3 and world.fade_rect.color.a < 0.7, "fading out to black")
	check_eq(world.get_current_room_id(), &"ow_1_1", "the room switches only when black")
	await seconds(0.2)
	check_eq(world.get_current_room_id(), &"cave_1", "now in the cave")
	check(world.fade_rect.color.a > 0.7, "(nearly) black at the switch")
	var total := await _wait_transition(world)
	check(total >= 14 and total <= 20, "fade in takes 0.3 s (got %d frames)" % total)
	check_near(world.fade_rect.color.a, 0.0, 0.01, "fade is clear afterwards")
	check(player.dark_mode and player.lamp.enabled, "the lamp lights up in the dark cave")
	check(
		world.get_room(&"cave_1").get_rect().has_point(player.global_position),
		"player is in the cave"
	)
	check_eq(
		world.camera.position,
		world.get_room(&"cave_1").position + Vector2(960, 420),
		"camera is on the cave"
	)
	# Walk down into the exit door: back to ow_1_1 at its FromCave marker.
	player.place_at(Vector2(960, 2880 + 640))
	await frames(2)
	Input.action_press(&"move_down")
	var guard := 0
	while world.get_current_room_id() != &"ow_1_1" and guard < 300:
		await frames(1)
		guard += 1
	release_inputs()
	await _wait_transition(world)
	check_eq(world.get_current_room_id(), &"ow_1_1", "the cave exit door leads back out")
	check(not player.dark_mode, "outside the lamp light is off again")
	var spawn := world.get_room(&"ow_1_1").get_spawn_position(&"FromCave")
	check_near(
		player.global_position.distance_to(spawn),
		0.0,
		40.0,
		"player appears at the cave entrance marker"
	)
	await seconds(1.0)
	check_eq(
		world.get_current_room_id(), &"ow_1_1", "the player does not bounce back into the cave"
	)
	# And in through the entrance door by walking.
	player.place_at(Vector2(1920 + 1392, 960 + 432))
	await frames(2)
	Input.action_press(&"move_up")
	guard = 0
	while world.get_current_room_id() != &"cave_1" and guard < 300:
		await frames(1)
		guard += 1
	release_inputs()
	await _wait_transition(world)
	check_eq(world.get_current_room_id(), &"cave_1", "the cave entrance door leads in")


func _death_respawn(world: World) -> void:
	reset_state()
	world.start_at(&"ow_1_0")
	var player := world.player
	GameState.add_currency(7)
	player.take_damage(99, player.global_position + Vector2(10, 0))
	check(player.is_dead(), "the player dies")
	check_eq(GameState.health, 0, "health is 0")
	await seconds(0.5)
	check_eq(world.get_current_room_id(), &"ow_1_0", "the world waits before respawning")
	await seconds(0.6)
	check(world.is_transitioning() or world.get_current_room_id() == &"ow_0_0", "then it fades out")
	await _wait_transition(world, 200)
	check_eq(world.get_current_room_id(), &"ow_0_0", "respawn in the start room")
	check_eq(GameState.health, GameState.max_health, "respawn with full health")
	check(not player.is_dead(), "the player is alive again")
	check(
		world.get_room(&"ow_0_0").get_rect().has_point(player.global_position), "at the start spawn"
	)
	check_eq(GameState.currency, 7, "death keeps currency")
	Input.action_press(&"move_right")
	var x := player.global_position.x
	await frames(10)
	release_inputs()
	check(player.global_position.x > x, "the player can move after respawning")


func _hud(world: World) -> void:
	check(world.hud != null, "the world has a HUD")
	check_eq(world.hud.canvas.size, Vector2(1920, 120), "the HUD band is 120 px high")
	check_eq(Hud.room_cell(&"ow_2_1"), Vector2i(2, 1), "minimap cell of an overworld room")
	check_eq(Hud.room_cell(&"cave_1"), Vector2i(-1, -1), "the cave is not on the minimap")
	GameState.acquire_item(&"pitch_pot")
	GameState.add_pitch_pots(3)
	GameState.damage(1)
	await frames(3)
	check(world.hud.canvas.is_visible_in_tree(), "the HUD redraws without errors")
