## timeout=120
extends "res://tests/test_soak_brackwater.gd"
## Q6: all standalone scenes in this cave, sampled for five seconds.

const AREA_ROOMS: Array[StringName] = [
	&"cave_3_1",
	&"cave_3_2",
	&"cave_3_3",
	&"cave_3_4",
	&"cave_3_5",
	&"cave_3_6",
	&"cave_3_7",
	&"cave_3_8",
	&"cave_3_9",
]


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	check_area_inventory("cave_3", AREA_ROOMS)
	var world := await make_world()
	for id in AREA_ROOMS:
		await soak_room(world, id)
	await dispose(world)
