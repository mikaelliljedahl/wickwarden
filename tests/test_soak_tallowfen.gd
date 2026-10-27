## timeout=120
extends "res://tests/test_soak_brackwater.gd"
## Q6: all standalone scenes in this region, sampled for five seconds.

const AREA_ROOMS: Array[StringName] = [
	&"ow_0_3",
	&"ow_1_3",
	&"ow_0_4",
	&"ow_1_4",
	&"ow_2_4",
	&"ow_0_5",
	&"ow_1_5",
	&"ow_2_5",
	&"ow_3_5",
	&"ow_1_6",
	&"ow_2_6",
	&"ow_2_7",
	&"ow_4_3",
	&"ow_4_4",
	&"ow_4_5",
	&"ow_6_2",
	&"ow_5_3",
	&"ow_6_3",
	&"ow_7_3",
	&"ow_5_4",
	&"ow_6_4",
	&"ow_7_4",
	&"ow_5_5",
	&"ow_6_5",
	&"ow_1_5#cache",
	&"ow_5_5#cache",
	&"ow_7_3#grotto",
	&"ow_6_5#shop",
]


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	check_area_inventory("tallowfen", AREA_ROOMS)
	var world := await make_world()
	for id in AREA_ROOMS:
		await soak_room(world, id)
	await dispose(world)
