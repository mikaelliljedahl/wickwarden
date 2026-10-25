extends "res://tests/area_base.gd"
## R4 geometry/topology acceptance. Missing future cave destinations remain explicit pending work.

const REGION := [
	"ow_0_3",
	"ow_1_3",
	"ow_4_3",
	"ow_5_3",
	"ow_6_2",
	"ow_6_3",
	"ow_7_3",
	"ow_0_4",
	"ow_0_5",
	"ow_1_4",
	"ow_1_5",
	"ow_2_4",
	"ow_2_5",
	"ow_3_5",
	"ow_4_4",
	"ow_4_5",
	"ow_5_4",
	"ow_5_5",
	"ow_6_4",
	"ow_6_5",
	"ow_7_4",
	"ow_1_6",
	"ow_2_6",
	"ow_2_7"
]
const POCKETS := ["ow_1_5#cache", "ow_5_5#cache", "ow_7_3#grotto", "ow_6_5#shop"]


func run() -> void:
	index_world()
	var actual: Array[String] = []
	for id: String in rooms_by_id:
		if rooms_by_id[id]["region"] == "tallowfen":
			actual.append(id)
	actual.sort()
	var expected: Array[String] = []
	expected.assign(REGION)
	expected.sort()
	check_eq(actual, expected, "R4 covers exactly all 24 graph rooms")
	for id: String in REGION + POCKETS:
		check_area(id)
		check_eq(WorldData.scope_of(id), &"ow", "%s keeps overworld key scope" % id)
	var actual_pockets: Array[String] = []
	for id: String in pockets_by_id:
		if pockets_by_id[id]["region"] == "tallowfen":
			actual_pockets.append(id)
	actual_pockets.sort()
	var expected_pockets: Array[String] = []
	expected_pockets.assign(POCKETS)
	expected_pockets.sort()
	check_eq(actual_pockets, expected_pockets, "all four R4 pockets are covered")
	_check_raft_pairs()
	for pair in [["ow_4_2", "ow_4_3"], ["ow_4_5", "ow_4_6"]]:
		check(WorldData.is_oneway(pair[0], pair[1]), "ledge keeps its graph direction")
		check(not WorldData.is_oneway(pair[1], pair[0]), "ledge has no reverse drop")
	var mouth := WorldData.edge_between("ow_3_5", "cave_3_1")
	check_eq(mouth.get("needs"), ["pitch_pot"], "C3 mouth requires the collected pot tool")
	check_eq(mouth.get("gate"), "bomb", "C3 mouth stays bomb sealed")
	for item: String in pending:
		print("PENDING R4: ", item)
	free_scenes()


func _check_raft_pairs() -> void:
	var count := 0
	for edge: Dictionary in world_json["edges"]:
		if not REGION.has(edge["a"]) and not REGION.has(edge["b"]):
			continue
		if edge.get("prop") != "mooring and water":
			continue
		count += 1
		check_eq(edge["needs"], ["reed_raft"], "%s is raft scoped" % edge["id"])
		for id: String in [edge["a"], edge["b"]]:
			var room := scene_root(WorldData.scene_path(id))
			check(room != null or not REGION.has(id), "%s regional mooring endpoint exists" % id)
			if room == null:
				pending["raft endpoint %s awaits its owning region" % id] = true
				continue
			var other: String = edge["b"] if id == edge["a"] else edge["a"]
			var matches := 0
			for node: Node in room.get_node("Props").get_children():
				if (
					_script_file(node) != "mooring.gd"
					or String(node.get("mooring_id")) != edge["id"]
				):
					continue
				matches += 1
				check_eq(String(node.get("target_room")), other, "mooring targets graph partner")
				check_eq(
					String(node.get("target_mooring")), edge["id"], "pair shares graph edge id"
				)
			check_eq(matches, 1, "%s has exactly one %s post" % [id, edge["id"]])
	check_eq(count, 22, "all 22 R4 touching raft links are checked")
