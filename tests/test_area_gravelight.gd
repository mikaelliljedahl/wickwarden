extends "res://tests/area_base.gd"
## All delivered Gravelight rooms and pockets, checked against the binding graph.

const REGION := [
	"ow_8_4",
	"ow_9_4",
	"ow_8_5",
	"ow_9_5",
	"ow_4_6",
	"ow_5_6",
	"ow_6_6",
	"ow_7_6",
	"ow_8_6",
	"ow_3_7",
	"ow_4_7",
	"ow_5_7",
	"ow_7_7",
	"ow_4_8",
	"ow_5_8"
]
const POCKETS := ["ow_8_5#ward", "ow_5_7#shop", "ow_4_8#cache"]


func run() -> void:
	index_world()
	var actual: Array[String] = []
	for id: String in rooms_by_id:
		if rooms_by_id[id]["region"] == "gravelight":
			actual.append(id)
	actual.sort()
	var expected: Array[String] = []
	expected.assign(REGION)
	expected.sort()
	check_eq(actual, expected, "all 15 R5 graph rooms covered")
	var pockets: Array[String] = []
	for id: String in pockets_by_id:
		if pockets_by_id[id]["region"] == "gravelight":
			pockets.append(id)
	pockets.sort()
	expected.assign(POCKETS)
	expected.sort()
	check_eq(pockets, expected, "all three graph pockets covered")
	for id: String in REGION + POCKETS:
		check(ResourceLoader.exists(WorldData.scene_path(id)), "%s is delivered" % id)
		check_area(id)
		check_eq(WorldData.scope_of(id), &"ow", "regional pickups keep overworld scope")
	for edge: Dictionary in world_json["edges"]:
		if not REGION.has(edge["a"]) and not REGION.has(edge["b"]):
			continue
		if edge["link"] != "step" or edge["gate"] == "oneway":
			continue
		for id: String in [edge["a"], edge["b"]]:
			check(
				ResourceLoader.exists(WorldData.scene_path(id)), "boundary endpoint exists: %s" % id
			)
			var other: String = edge["b"] if id == edge["a"] else edge["a"]
			check(WorldData.neighbors(id).has(other), "reciprocal graph boundary")
	for item: String in pending:
		print("PENDING R5: ", item)
	free_scenes()
