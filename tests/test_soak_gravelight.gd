## timeout=120
extends "res://tests/test_soak_brackwater.gd"
## Q6: all standalone scenes in this region, sampled for five seconds.

const AREA_ROOMS: Array[StringName] = [
	&"ow_8_4",
	&"ow_9_4",
	&"ow_8_5",
	&"ow_9_5",
	&"ow_4_6",
	&"ow_5_6",
	&"ow_6_6",
	&"ow_7_6",
	&"ow_8_6",
	&"ow_3_7",
	&"ow_4_7",
	&"ow_5_7",
	&"ow_7_7",
	&"ow_4_8",
	&"ow_5_8",
	&"ow_8_5#ward",
	&"ow_5_7#shop",
	&"ow_4_8#cache",
]


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	check_area_inventory("gravelight", AREA_ROOMS)
	var world := await make_world()
	for id in AREA_ROOMS:
		await soak_room(world, id)
	await dispose(world)
