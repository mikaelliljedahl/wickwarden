## timeout=120
extends "res://tests/test_soak_brackwater.gd"
## Q6: all standalone scenes in this cave, sampled for five seconds.

const AREA_ROOMS: Array[StringName] = [
	&"cave_8_1",
	&"cave_8_2",
	&"cave_8_3",
	&"cave_8_4",
	&"cave_8_5",
	&"cave_8_6",
	&"cave_8_7",
	&"cave_8_8",
	&"cave_8_9",
	&"cave_8_10",
	&"cave_8_11",
	&"cave_8_12",
]


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	check_area_inventory("cave_8", AREA_ROOMS)
	var world := await make_world()
	for id in AREA_ROOMS:
		await soak_room(world, id)
	await dispose(world)
