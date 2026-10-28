## timeout=120
extends "res://tests/test_dev_world.gd"
## Q6: actual streamed Brackwater rooms, sampled throughout five seconds.
## The two in-place pockets are covered by their host rooms.

const SOAK_ROOMS: Array[StringName] = [
	&"ow_0_0", &"ow_1_0", &"ow_2_0", &"ow_0_1", &"ow_1_1", &"ow_2_1",
	&"ow_0_2", &"ow_1_2", &"ow_1_2#shop"
]


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	check_area_inventory("brackwater", SOAK_ROOMS)
	var world := await make_world()
	for id in SOAK_ROOMS:
		await soak_room(world, id)
	await _slide_real_enemies(world)
	await dispose(world)


func check_area_inventory(region: String, tested: Array[StringName]) -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(WorldData.PATH))
	var expected: Array[String] = []
	for entry: Dictionary in data.get("rooms", []) + data.get("pockets", []):
		if entry.get("region") == region and not entry.get("in_place", false):
			expected.append(String(entry["id"]))
	var actual: Array[String] = []
	for id in tested:
		actual.append(String(id))
	expected.sort()
	actual.sort()
	check_eq(actual, expected, "%s soak covers all standalone scene ids" % region)


func soak_room(world: World, id: StringName) -> void:
	reset_state()
	world.start_at(id)
	var room := world.get_room(id)
	check(room != null, "%s loads for the soak" % id)
	if room == null:
		return
	world.player.set_hurtbox_enabled(self, false)
	var blocks := _blockers(room)
	var closed: Array[Rect2] = blocks["fixed"]
	closed.append_array(blocks["openable"])
	var interior := room.interior_rect()
	for sample in range(10):
		await seconds(0.5)
		for enemy in room.get_enemies():
			# The Unlit's specified orbit crosses the north wall. Check that
			# authored path separately; a containment assertion is incompatible.
			if id == &"cave_10_14" and enemy.visual_kind == &"unlit_eye":
				check_near(
					enemy.global_position.distance_to(room.global_position + Vector2(960, 288)),
					330.0, 1.0, "C10 eye follows its specified orbit"
				)
				continue
			check(
				interior.grow(1.0).has_point(enemy.global_position),
				"%s: %s stays inside at %.1fs" % [id, enemy.name, (sample + 1) * 0.5]
			)
			check(
				not _in_any(enemy.global_position - room.global_position, 0.0, closed),
				"%s: %s avoids solids at %.1fs" % [id, enemy.name, (sample + 1) * 0.5]
			)
	world.player.set_hurtbox_enabled(self, true)
	print("Q6 soak: %s, 5.0 simulated seconds" % id)


## Exercise real room templates on an input-driven round trip, not a stand-in enemy.
func _slide_real_enemies(world: World) -> void:
	reset_state()
	world.start_at(&"ow_0_0")
	world.player.set_hurtbox_enabled(self, false)
	var first := world.get_room(&"ow_0_0")
	var second := world.get_room(&"ow_1_0")
	await seconds(0.5)
	check_eq(first.get_enemies().size(), 2, "source has real Spitcaps before slide")
	await _cross_with_enemies(world, first, second, true, 3)
	await seconds(0.5)
	await _cross_with_enemies(world, second, first, false, 2)
	world.player.set_hurtbox_enabled(self, true)


func _cross_with_enemies(world: World, source: Room, target: Room, east: bool, count: int) -> void:
	var old := source.get_enemies()
	var origin := source.global_position
	world.player.place_at(origin + Vector2(1700 if east else 220, 480))
	await frames(2)
	Input.action_press(&"move_right" if east else &"move_left")
	var waited := 0
	while not world.is_transitioning() and waited < 120:
		await frames(1)
		waited += 1
	release_inputs()
	check(world.is_transitioning(), "input crosses the real room edge")
	if not world.is_transitioning():
		return
	var incoming := target.get_enemies()
	check_eq(incoming.size(), count, "real target enemies spawn for slide")
	var positions: Array[Vector2] = []
	for enemy in old + incoming:
		positions.append(enemy.global_position)
		check(not enemy.can_process(), "both rooms' enemies are paused during slide")
	await frames(10)
	var i := 0
	for enemy in old + incoming:
		check_eq(enemy.global_position, positions[i], "paused enemy does not move during slide")
		i += 1
	while world.is_transitioning() and waited < 240:
		await frames(1)
		waited += 1
	check_eq(world.get_current_room_id(), target.room_id, "slide reaches real target")
	check_eq(source.get_enemies().size(), 0, "leaving clears real source enemies")
	for enemy in old:
		check(not is_instance_valid(enemy), "source enemy instance is freed on exit")
	check_eq(target.get_enemies().size(), count, "real target enemies remain after slide")
	var resumed_positions: Array[Vector2] = []
	for enemy in target.get_enemies():
		check(enemy.can_process(), "target enemy resumes after slide")
		resumed_positions.append(enemy.global_position)
	await seconds(1.5)
	var moved := false
	i = 0
	for enemy in target.get_enemies():
		check(target.interior_rect().grow(1.0).has_point(enemy.global_position),
			"resumed target enemy centre stays in room")
		moved = moved or enemy.global_position.distance_to(resumed_positions[i]) > 1.0
		i += 1
	if east:
		check(moved, "real Skitterwick AI moves after the slide")
