extends TestCase
## World: streaming of rooms from the graph (on demand, closed edges for missing scenes), the room
## graph on the real scenes, the --start-room argument, add_room_scene, placeholder kinds, camera
## slide (0.45 s), entry position, pausing during the slide, enemy respawn on entry, warp fade
## (0.3 s), cave lighting, death and respawn, HUD, walls, and a 40-warp soak test.


func run() -> void:
	var world := await make_world()
	await _streaming(world)
	_start_argument()
	await _placeholder_kinds()
	await _added_scene(world)
	await _room_graph(world)
	await _start(world)
	await _walls(world)
	await _slide_east(world)
	await _slide_pauses_and_respawns(world)
	await _slide_vertical(world)
	await _cave(world)
	await _cave_mouth_flags(world)
	await _death_respawn(world)
	await _hud(world)
	await _soak_warps(world)
	await dispose(world)


func _wait_transition(world: World, max_frames: int = 120) -> int:
	var n := 0
	while world.is_transitioning() and n < max_frames:
		await frames(1)
		n += 1
	return n


## add_room_scene (the capture and test hook): a scene given for an id is entered, freed when the
## player leaves, and loaded again from the same scene on the next visit.
func _added_scene(world: World) -> void:
	var packed := PackedScene.new()
	var gallery := Room.new()
	gallery.name = "Gallery"
	packed.pack(gallery)
	gallery.free()
	world.add_room_scene(&"gallery_test", packed)
	world.warp_to(&"gallery_test", &"Default", false)
	check_eq(world.get_current_room_id(), &"gallery_test", "a room added by scene is entered")
	check_eq(world.get_room(&"gallery_test").room_id, &"gallery_test", "it keeps its id")
	world.warp_to(&"ow_0_0", &"Default", false)
	check(not world.rooms.has(&"gallery_test"), "a room the player left is freed")
	check(world.get_room(&"gallery_test") != null, "and it loads again from the same scene")
	world.start_at(&"ow_0_0")


## Runtime placeholder kinds: registered from a script, drawn like the table kinds, not overwriting it.
func _placeholder_kinds() -> void:
	check(Placeholder.has_kind(&"spitcap"), "a step-1 kind is known")
	check(not Placeholder.has_kind(&"test_crate"), "an unregistered kind is unknown")
	var crate := {"shape": "rect", "color": Color(0.5, 0.2, 0.1), "size": Vector2(40, 40)}
	Placeholder.register_kind(&"test_crate", crate, true)
	check(Placeholder.has_kind(&"test_crate"), "a registered kind is known")
	check(Placeholder.is_static_kind(&"test_crate"), "a static kind is marked static")
	check(not Placeholder.is_static_kind(&"spitcap"), "a turning kind is not static")
	check_eq(Placeholder.color_of(&"test_crate"), Color(0.5, 0.2, 0.1), "its colour is used")
	var visual := Placeholder.attach(self, &"test_crate")
	await frames(2)
	check_eq(visual.kind, &"test_crate", "a placeholder of a runtime kind is attached")
	check(visual.is_inside_tree(), "and it is in the tree")
	await dispose(visual)


## `--start-room=<id>[:spawn]` parses to a room and a spawn marker; the spawn defaults to Default.
func _start_argument() -> void:
	var none: Array[StringName] = [&"", &"Default"]
	check_eq(World.parse_start_room(PackedStringArray(["--dev-mode"])), none, "no argument: none")
	var room_only: Array[StringName] = [&"ow_1_1", &"Default"]
	check_eq(
		World.parse_start_room(PackedStringArray(["--start-room=ow_1_1"])), room_only, "room only"
	)
	var with_spawn: Array[StringName] = [&"cave_1", &"FromOverworld"]
	check_eq(
		World.parse_start_room(PackedStringArray(["--dev-mode", "--start-room=cave_1:FromOverworld"])),
		with_spawn,
		"room and spawn"
	)


## Rooms load on demand: only the current room and the rooms its exits lead to stay loaded.
func _streaming(world: World) -> void:
	check_eq(_loaded_ids(world), ["ow_0_0", "ow_0_1", "ow_1_0"], "the start loads its exits")
	world.warp_to(&"ow_1_0", &"Default", false)
	check_eq(
		_loaded_ids(world),
		["ow_0_0", "ow_1_0", "ow_1_1", "ow_2_0"],
		"after a move the far rooms are freed"
	)
	check(world.get_room(&"ow_3_0") == null, "a room without a scene is not loaded")
	check(not world.rooms.has(&"ow_3_0"), "and it is not kept")
	world.start_at(&"ow_0_0")


## Sorted ids of the loaded rooms, as Strings (StringName does not sort alphabetically).
func _loaded_ids(world: World) -> Array[String]:
	var ids: Array[String] = []
	for id in world.rooms.keys():
		ids.append(String(id))
	ids.sort()
	return ids


## The graph id of the room at `cell`, "" when there is none.
func _id_at(cell: Vector2i) -> String:
	for id in WorldData.room_ids():
		if WorldData.grid(id) == cell:
			return id
	return ""


## Every room whose scene exists loads at its graph grid, the scene agrees with the graph, and
## every exit leads to a mirrored room. The seven dev rooms are the ones with a scene so far.
func _room_graph(world: World) -> void:
	var sides := {&"n": Vector2i.UP, &"s": Vector2i.DOWN, &"w": Vector2i.LEFT, &"e": Vector2i.RIGHT}
	var opposite := {&"n": &"s", &"s": &"n", &"w": &"e", &"e": &"w"}
	var with_scene: Array[String] = []
	for id in WorldData.room_ids():
		if ResourceLoader.exists(WorldData.scene_path(id)):
			with_scene.append(id)
	check(with_scene.size() >= 7, "the seven placeholder rooms have scenes")
	for id in ["ow_0_0", "ow_1_0", "ow_2_0", "ow_0_1", "ow_1_1", "ow_2_1", "cave_1"]:
		check(with_scene.has(id), "room %s has a scene" % id)
	for id in with_scene:
		var probe := (load(WorldData.scene_path(id)) as PackedScene).instantiate() as Room
		check_eq(probe.grid, WorldData.grid(id), "%s scene agrees with the graph grid" % id)
		probe.free()
		var room := world.get_room(StringName(id))
		check(room != null, "room %s loads" % id)
		if room == null:
			continue
		check_eq(
			room.position,
			Vector2(room.grid) * Vector2(1920, 960),
			"%s sits at its grid origin" % id
		)
		for side in room.exits:
			var neighbor_id := _id_at(room.grid + sides[side])
			check(neighbor_id != "", "%s exit %s leads to a room" % [id, side])
			if neighbor_id == "":
				continue
			var neighbor := world.get_room(StringName(neighbor_id))
			check(neighbor != null, "%s exit %s leads to a loaded room" % [id, side])
			if neighbor != null and WorldData.is_oneway(id, neighbor_id):
				# A one-way ledge drop (test_oneway.gd): a declared drop side, and no gap back.
				check(
					room.is_drop_side(side), "%s drops %s through a declared drop side" % [id, side]
				)
				check(
					not neighbor.has_exit(opposite[side]), "%s drop %s has no way back" % [id, side]
				)
			elif neighbor != null:
				check(neighbor.has_exit(opposite[side]), "%s exit %s is mirrored" % [id, side])
				check(
					not room.is_drop_side(side),
					"%s side %s is a drop only on a one-way edge" % [id, side]
				)
	check(world.get_room(&"cave_1").dark, "the cave is dark")
	check(not world.get_room(&"ow_0_0").dark, "overworld rooms are lit")
	check_eq(
		world.get_room(&"cave_1").position,
		Vector2(1920, 12480),
		"cave_1 sits at world position (1920, 12480)"
	)


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
	player.place_at(world.get_room(&"cave_1").global_position + Vector2(960, 640))
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


## Entering a cave mouth for the first time sets its flag mouth_cN (code-contract 16.4); later visits keep
## it and set nothing again. Each of the ten mouths of the graph is checked in a world of its own with a
## stub room at the mouth's graph cell.
func _cave_mouth_flags(world: World) -> void:
	reset_state()
	world.start_at(&"ow_0_0")
	check(not GameState.has_flag(&"mouth_c1"), "no mouth flag before the mouth is entered")
	world.warp_to(&"ow_0_1", &"Default", false)
	check(not GameState.has_flag(&"mouth_c1"), "an ordinary room sets no mouth flag")
	world.warp_to(&"ow_1_1", &"Default", false)
	check(GameState.has_flag(&"mouth_c1"), "entering the mouth of C1 sets mouth_c1")
	world.warp_to(&"ow_0_1", &"Default", false)
	var changes: Array[int] = [0]
	var count_change := func(_flag: StringName, _value: bool) -> void: changes[0] += 1
	GameState.flag_changed.connect(count_change)
	world.warp_to(&"ow_1_1", &"Default", false)
	GameState.flag_changed.disconnect(count_change)
	check(GameState.has_flag(&"mouth_c1"), "the flag stays on a later visit")
	check_eq(changes[0], 0, "a later visit sets no flag again")

	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(WorldData.PATH))
	var mouth_world := await make_world()
	for cave: Dictionary in data.get("caves", []):
		var mouth := StringName(str(cave["mouth"]))
		var flag := StringName("mouth_%s" % str(cave["scope"]))
		reset_state()
		var stub := Room.new()
		stub.name = "Stub"
		stub.grid = WorldData.grid(str(mouth))
		var packed := PackedScene.new()
		packed.pack(stub)
		stub.free()
		mouth_world.add_room_scene(mouth, packed)
		mouth_world.start_at(&"ow_0_0")
		mouth_world.warp_to(mouth, &"Default", false)
		check(GameState.has_flag(flag), "entering %s sets %s" % [mouth, flag])
		var others := GameState.flags.keys().filter(func(f: StringName) -> bool: return String(f).begins_with("mouth_"))
		check_eq(others, [flag], "only %s is set by %s" % [flag, mouth])
	await dispose(mouth_world)
	reset_state()


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


## Forty warps in five rounds of eight through the dev rooms and the cave. Every warp lands where
## it names, at most five rooms are loaded at a time, and the node count of the world does not grow
## after the first round (freed rooms leave nothing behind).
func _soak_warps(world: World) -> void:
	reset_state()
	var route: Array[StringName] = [
		&"ow_1_1", &"cave_1", &"ow_2_1", &"ow_2_0", &"ow_0_1", &"cave_1", &"ow_0_0", &"ow_1_0"
	]
	world.player.hurtbox.enabled = false
	world.start_at(&"ow_1_0")
	var base := -1
	var landed := 0
	var max_loaded := 0
	for round_index in range(5):
		for id in route:
			world.warp_to(id)
			await _wait_transition(world)
			if world.get_current_room_id() == id:
				landed += 1
			max_loaded = maxi(max_loaded, world.rooms.size())
		await frames(2)
		var count := _node_count(world)
		if base < 0:
			base = count
		else:
			check(
				count <= base,
				"round %d: the node count does not grow (%d, first round %d)"
				% [round_index + 1, count, base]
			)
	check_eq(landed, 40, "all 40 warps land in the room they name")
	check(max_loaded <= 5, "at most five rooms are loaded at a time (got %d)" % max_loaded)
	world.player.hurtbox.enabled = true
	world.start_at(&"ow_0_0")


func _node_count(node: Node) -> int:
	var total := 1
	for child in node.get_children():
		total += _node_count(child)
	return total


func _hud(world: World) -> void:
	check(world.hud != null, "the world has a HUD")
	check_eq(world.hud.canvas.size, Vector2(1920, 120), "the HUD band is 120 px high")
	check_eq(Hud.room_cell(&"ow_2_1"), Vector2i(2, 1), "minimap cell of an overworld room")
	check_eq(Hud.room_cell(&"cave_1"), Vector2i(1, 1), "a cave room has its local cell")
	GameState.acquire_item(&"pitch_pot")
	GameState.add_pitch_pots(3)
	GameState.damage(1)
	await frames(3)
	check(world.hud.canvas.is_visible_in_tree(), "the HUD redraws without errors")
