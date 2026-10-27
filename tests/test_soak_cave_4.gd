## timeout=120
extends "res://tests/test_soak_brackwater.gd"
## Q6: all standalone scenes in this cave, sampled for five seconds.

const AREA_ROOMS: Array[StringName] = [
	&"cave_4_1",
	&"cave_4_2",
	&"cave_4_3",
	&"cave_4_4",
	&"cave_4_5",
	&"cave_4_6",
	&"cave_4_7",
	&"cave_4_8",
	&"cave_4_9",
	&"cave_4_10",
	&"cave_4_7#seal",
]


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	check_area_inventory("cave_4", AREA_ROOMS)
	var world := await make_world()
	for id in AREA_ROOMS:
		await soak_room(world, id)
	await dispose(world)
