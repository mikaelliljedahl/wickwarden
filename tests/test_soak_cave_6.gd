## timeout=120
extends "res://tests/test_soak_brackwater.gd"
## Q6: all standalone scenes in this cave, sampled for five seconds.

const AREA_ROOMS: Array[StringName] = [
	&"cave_6_1",
	&"cave_6_2",
	&"cave_6_3",
	&"cave_6_4",
	&"cave_6_5",
	&"cave_6_6",
	&"cave_6_7",
	&"cave_6_8",
	&"cave_6_9",
	&"cave_6_10",
	&"cave_6_11",
	&"cave_6_8#ward",
	&"cave_6_9#crypt",
]


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	check_area_inventory("cave_6", AREA_ROOMS)
	var world := await make_world()
	for id in AREA_ROOMS:
		await soak_room(world, id)
	await dispose(world)
