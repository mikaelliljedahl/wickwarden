## timeout=120
extends "res://tests/test_soak_brackwater.gd"
## Q6: all standalone scenes in this cave, sampled for five seconds.

const AREA_ROOMS: Array[StringName] = [
	&"cave_2_1",
	&"cave_2_2",
	&"cave_2_3",
	&"cave_2_4",
	&"cave_2_5",
	&"cave_2_6",
	&"cave_2_7",
	&"cave_2_8",
	&"cave_2_9",
]


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	check_area_inventory("cave_2", AREA_ROOMS)
	var world := await make_world()
	for id in AREA_ROOMS:
		await soak_room(world, id)
	await dispose(world)
