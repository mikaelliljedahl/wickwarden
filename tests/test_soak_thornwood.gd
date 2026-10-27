## timeout=120
extends "res://tests/test_soak_brackwater.gd"
## Q6: all Thornwood rooms and standalone pockets use the same sampled soak.

const THORNWOOD_ROOMS: Array[StringName] = [
	&"ow_3_0", &"ow_4_0", &"ow_5_0", &"ow_6_0", &"ow_7_0",
	&"ow_3_1", &"ow_4_1", &"ow_5_1", &"ow_6_1", &"ow_7_1",
	&"ow_3_2", &"ow_4_2", &"ow_5_2", &"ow_7_2", &"ow_3_3",
	&"ow_4_1#cache", &"ow_6_0#shop", &"ow_7_2#bag", &"ow_3_3#hut", &"ow_3_2#grate"
]


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	check_area_inventory("thornwood", THORNWOOD_ROOMS)
	var world := await make_world()
	for id in THORNWOOD_ROOMS:
		await soak_room(world, id)
	await dispose(world)
