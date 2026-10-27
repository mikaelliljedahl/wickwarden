## timeout=120
extends "res://tests/test_soak_brackwater.gd"
## Q6: all standalone scenes in this cave, sampled for five seconds.

const AREA_ROOMS: Array[StringName] = [
	&"cave_5_1",
	&"cave_5_2",
	&"cave_5_3",
	&"cave_5_4",
	&"cave_5_5",
	&"cave_5_6",
	&"cave_5_7",
	&"cave_5_8",
	&"cave_5_9",
	&"cave_5_10",
]


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	check_area_inventory("cave_5", AREA_ROOMS)
	var world := await make_world()
	for id in AREA_ROOMS:
		await soak_room(world, id)
	await dispose(world)
