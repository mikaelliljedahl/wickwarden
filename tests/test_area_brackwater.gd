extends "res://tests/area_base.gd"
## R1 acceptance: all eight assembled rooms and S1, including the preserved in-place pockets.

const REGION := [
	"ow_0_0", "ow_1_0", "ow_2_0", "ow_0_1", "ow_1_1", "ow_2_1", "ow_0_2", "ow_1_2"
]


func run() -> void:
	index_world()
	for id: String in REGION:
		check_area(id)
	check_area("ow_1_2#shop")
	check(is_in_place("ow_2_0#cache"), "the original core cache remains in place")
	check(is_in_place("ow_2_1#closet"), "the original pot closet remains in place")
	check(is_in_place("cave_1#alcove"), "the original key alcove remains in place")
	var mouth := scene_root(WorldData.scene_path("ow_1_1"))
	var door := _door_to(mouth, "cave_1")
	check(not door.is_empty(), "the Crossroads still leads to C1")
	var stairs := scene_root(WorldData.scene_path("ow_0_2"))
	var target := _door_to(stairs, "cave_9_1")
	check_eq(target.get("spawn", ""), "FromOverworld", "C9 stairs declare the contracted spawn")
	# Missing later cave content is pending under F3; R1 still requires the real stairs above.
	for item: String in pending:
		print("PENDING R1: ", item)
	_graph_contract()
	_mutations_fail()
	free_scenes()


func _mutations_fail() -> void:
	var path := WorldData.scene_path("ow_1_2")
	var packed := load(path) as PackedScene
	check(packed != null, "Ford Road loads for mutation checks")
	if packed == null:
		return
	var broken := packed.instantiate() as Room
	broken.exits.erase(&"n")
	check(not room_problems("ow_1_2", broken).is_empty(), "a missing R1 exit is rejected")
	broken.free()
	broken = packed.instantiate() as Room
	for door in descendants_of_class(broken, RoomDoor):
		door.target_room = &"ow_0_0"
	check(not room_problems("ow_1_2", broken).is_empty(), "a shop door to the wrong room is rejected")
	broken.free()


func _graph_contract() -> void:
	var actual: Array[String] = []
	for id: String in rooms_by_id:
		if rooms_by_id[id]["region"] == "brackwater":
			actual.append(id)
	actual.sort()
	var expected: Array[String] = []
	expected.assign(REGION)
	expected.sort()
	check_eq(actual, expected, "acceptance covers exactly the graph's eight Brackwater rooms")
	for pair in [
		["ow_2_0", "ow_3_0", "item", "cinder_wick"],
		["ow_1_2", "ow_1_3", "cut", "hook"],
		["ow_0_2", "cave_9_1", "hidden", "glow_jar"],
		["ow_2_0", "ow_2_0#cache", "bomb", "pitch_pot"],
	]:
		var edge := WorldData.edge_between(pair[0], pair[1])
		check(not edge.is_empty(), "%s -> %s is a real graph edge" % [pair[0], pair[1]])
		check_eq(edge.get("gate"), pair[2], "%s gate type" % pair[0])
		check_eq(edge.get("needs"), [pair[3]], "%s gate capability" % pair[0])
	var lock := WorldData.edge_between("ow_2_1", "ow_2_1#closet")
	check_eq(lock.get("key"), "ow", "the historical pot closet spends an overworld key")
