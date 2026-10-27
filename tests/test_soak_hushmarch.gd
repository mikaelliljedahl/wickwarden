## timeout=120
extends "res://tests/test_soak_brackwater.gd"
## Q6: all standalone scenes in this region, sampled for five seconds.

const AREA_ROOMS: Array[StringName] = [
	&"ow_10_5",
	&"ow_11_5",
	&"ow_9_6",
	&"ow_10_6",
	&"ow_11_6",
	&"ow_8_7",
	&"ow_9_7",
	&"ow_10_7",
	&"ow_11_7",
	&"ow_8_8",
	&"ow_9_8",
	&"ow_10_8",
	&"ow_11_6#cache",
	&"ow_10_7#shop",
	&"ow_11_7#cache",
	&"ow_8_8#cache",
]


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	check_area_inventory("hushmarch", AREA_ROOMS)
	var world := await make_world()
	for id in AREA_ROOMS:
		await soak_room(world, id)
	await dispose(world)
