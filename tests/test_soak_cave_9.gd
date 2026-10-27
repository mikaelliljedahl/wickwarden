## timeout=120
extends "res://tests/test_soak_brackwater.gd"
## Q6: all standalone scenes in this cave, sampled for five seconds.

const AREA_ROOMS: Array[StringName] = [
	&"cave_9_1",
	&"cave_9_2",
	&"cave_9_3",
	&"cave_9_4",
	&"cave_9_5",
	&"cave_9_6",
	&"cave_9_7",
	&"cave_9_8",
	&"cave_9_9",
	&"cave_9_10",
	&"cave_9_2#cell",
	&"cave_9_9#vault",
]


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	check_area_inventory("cave_9", AREA_ROOMS)
	var world := await make_world()
	for id in AREA_ROOMS:
		await soak_room(world, id)
	await dispose(world)
