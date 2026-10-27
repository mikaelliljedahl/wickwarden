## timeout=120
extends "res://tests/test_soak_brackwater.gd"
## Q6: all standalone scenes in this cave, sampled for five seconds.

const AREA_ROOMS: Array[StringName] = [
	&"cave_10_1",
	&"cave_10_2",
	&"cave_10_3",
	&"cave_10_4",
	&"cave_10_5",
	&"cave_10_6",
	&"cave_10_7",
	&"cave_10_8",
	&"cave_10_9",
	&"cave_10_10",
	&"cave_10_11",
	&"cave_10_12",
	&"cave_10_13",
	&"cave_10_14",
	&"cave_10_10#ward",
]


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	check_area_inventory("cave_10", AREA_ROOMS)
	var world := await make_world()
	for id in AREA_ROOMS:
		await soak_room(world, id)
	await dispose(world)
