extends "res://tests/area_base.gd"
## All delivered R3 geometry; C04/C07 destinations remain explicit future dependencies.

const REGION := [
	"ow_8_0",
	"ow_9_0",
	"ow_10_0",
	"ow_8_1",
	"ow_9_1",
	"ow_10_1",
	"ow_11_1",
	"ow_8_2",
	"ow_9_2",
	"ow_10_2",
	"ow_11_2",
	"ow_9_3",
	"ow_10_3",
	"ow_10_4"
]
const POCKETS := [
	"ow_9_1#ward", "ow_8_0#cache", "ow_9_0#cache", "ow_10_1#hut", "ow_10_3#shop", "ow_11_2#cache"
]


func run() -> void:
	index_world()
	var actual: Array[String] = []
	for id: String in rooms_by_id:
		if rooms_by_id[id]["region"] == "cinderflats":
			actual.append(id)
	actual.sort()
	var expected: Array[String] = []
	expected.assign(REGION)
	expected.sort()
	check_eq(actual, expected, "all fourteen Cinderflats graph rooms included")
	for id: String in REGION + POCKETS:
		check(ResourceLoader.exists(WorldData.scene_path(id)), "R3 delivered scene: " + id)
		check_area(id)
	for spec in [
		["ow_8_0", "ow_8_0#cache", "hook"],
		["ow_9_0", "ow_9_0#cache", "flare"],
		["ow_9_1", "ow_9_1#ward", "ward"],
		["ow_11_2", "ow_11_2#cache", "pitch_pot"],
		["ow_9_3", "ow_9_4", "heft_mitts"],
		["ow_10_4", "ow_10_5", "reel_line"],
		["ow_10_2", "cave_7_1", "glow_jar"],
	]:
		check_eq(
			WorldData.edge_between(spec[0], spec[1]).get("needs"),
			[spec[2]],
			"R3 retains graph tool challenge"
		)
	var kiln := WorldData.edge_between("ow_10_1", "ow_10_1#hut")
	check_eq(kiln.get("key"), "ow", "kiln uses overworld scope")
	for id: String in ["cave_4_1", "cave_7_1"]:
		if not ResourceLoader.exists(WorldData.scene_path(id)):
			print("PENDING R3 future cave destination/acquisition: ", id)
	for item: String in pending:
		print("PENDING R3 external boundary: ", item)
	free_scenes()
