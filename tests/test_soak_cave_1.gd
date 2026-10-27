## timeout=120
extends "res://tests/test_soak_brackwater.gd"
## Q6: all standalone scenes in this cave, sampled for five seconds.

const AREA_ROOMS: Array[StringName] = [
	&"cave_1",
	&"cave_1_2",
	&"cave_1_3",
	&"cave_1_4",
	&"cave_1_5",
	&"cave_1_6",
	&"cave_1_7",
	&"cave_1_8",
	&"cave_1_6#crack",
]


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	check_area_inventory("cave_1", AREA_ROOMS)
	var world := await make_world()
	for id in AREA_ROOMS:
		await soak_room(world, id)
	await dispose(world)
