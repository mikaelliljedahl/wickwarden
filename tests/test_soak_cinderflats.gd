## timeout=120
extends "res://tests/test_soak_brackwater.gd"
## Q6: all standalone scenes in this region, sampled for five seconds.

const AREA_ROOMS: Array[StringName] = [
	&"ow_8_0",
	&"ow_9_0",
	&"ow_10_0",
	&"ow_8_1",
	&"ow_9_1",
	&"ow_10_1",
	&"ow_11_1",
	&"ow_8_2",
	&"ow_9_2",
	&"ow_10_2",
	&"ow_11_2",
	&"ow_9_3",
	&"ow_10_3",
	&"ow_10_4",
	&"ow_9_1#ward",
	&"ow_8_0#cache",
	&"ow_9_0#cache",
	&"ow_10_1#hut",
	&"ow_10_3#shop",
	&"ow_11_2#cache",
]


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	check_area_inventory("cinderflats", AREA_ROOMS)
	var world := await make_world()
	for id in AREA_ROOMS:
		await soak_room(world, id)
	await dispose(world)
