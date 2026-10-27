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
