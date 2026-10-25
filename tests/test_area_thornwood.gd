extends "res://tests/area_base.gd"
## Assembled R2 acceptance; missing external destinations remain explicit pending dependencies.

const REGION := [
	"ow_3_0",
	"ow_4_0",
	"ow_5_0",
	"ow_6_0",
	"ow_7_0",
	"ow_3_1",
	"ow_4_1",
	"ow_5_1",
	"ow_6_1",
	"ow_7_1",
	"ow_3_2",
	"ow_4_2",
	"ow_5_2",
	"ow_7_2",
	"ow_3_3"
]
const POCKETS := ["ow_4_1#cache", "ow_6_0#shop", "ow_3_2#grate", "ow_3_3#hut", "ow_7_2#bag"]


func run() -> void:
	index_world()
	var actual: Array[String] = []
	for id: String in rooms_by_id:
		if rooms_by_id[id]["region"] == "thornwood":
			actual.append(id)
	actual.sort()
	var expected: Array[String] = []
	expected.assign(REGION)
	expected.sort()
	check_eq(actual, expected, "all fifteen graph Thornwood rooms are accepted")
	for id: String in REGION + POCKETS:
		check(ResourceLoader.exists(WorldData.scene_path(id)), "%s is delivered" % id)
		check_area(id)
	for pair in [
		["ow_2_0", "ow_3_0", "cinder_wick"],
		["ow_7_1", "ow_8_1", "tallow_sling"],
		["ow_3_3", "ow_3_3#hut", "cinder_wick"],
		["ow_3_2", "ow_3_2#grate", "tether_moth"],
		["ow_7_2", "ow_7_2#bag", "pitch_pot"],
	]:
		var edge := WorldData.edge_between(pair[0], pair[1])
		check_eq(edge.get("needs"), [pair[2]], "R2 gate retains its actual tool challenge")
	var mouth := _door_to(scene_root(WorldData.scene_path("ow_5_1")), "cave_2_1")
	check_eq(mouth.get("spawn"), "FromOverworld", "C02 mouth uses contracted arrival marker")
	for item: String in pending:
		print("PENDING R2 external boundary: ", item)
	free_scenes()
