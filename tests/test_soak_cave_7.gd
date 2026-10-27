## timeout=120
extends "res://tests/test_soak_brackwater.gd"
## Q6: all standalone scenes in this cave, sampled for five seconds.

const AREA_ROOMS: Array[StringName] = [
	&"cave_7_1",
	&"cave_7_2",
	&"cave_7_3",
	&"cave_7_4",
	&"cave_7_5",
	&"cave_7_6",
	&"cave_7_7",
	&"cave_7_8",
	&"cave_7_9",
	&"cave_7_10",
	&"cave_7_11",
]


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	check_area_inventory("cave_7", AREA_ROOMS)
	var world := await make_world()
	for id in AREA_ROOMS:
		await soak_room(world, id)
	await dispose(world)
