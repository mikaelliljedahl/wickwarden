extends "res://tests/area_base.gd"
## R6 assembled layout and graph acceptance; later cave destinations remain pending.

const REGION := [
	"ow_10_5",
	"ow_11_5",
	"ow_9_6",
	"ow_10_6",
	"ow_11_6",
	"ow_8_7",
	"ow_9_7",
	"ow_10_7",
	"ow_11_7",
	"ow_8_8",
	"ow_9_8",
	"ow_10_8"
]
const POCKETS := ["ow_11_6#cache", "ow_10_7#shop", "ow_11_7#cache", "ow_8_8#cache"]


func run() -> void:
	index_world()
	var actual: Array[String] = []
	for id: String in rooms_by_id:
		if rooms_by_id[id]["region"] == "hushmarch":
			actual.append(id)
	var expected: Array[String] = []
	expected.assign(REGION)
	actual.sort()
	expected.sort()
	check_eq(actual, expected, "R6 acceptance covers exactly twelve graph rooms")
	for id: String in REGION + POCKETS:
		check(ResourceLoader.exists(WorldData.scene_path(id)), "%s must be delivered" % id)
		check_area(id)
	var edge := WorldData.edge_between("ow_10_8", "cave_10_1")
	var fragments: Array[String] = []
	for n in range(1, 10):
		fragments.append("frag:c%d" % n)
	check_eq(edge.get("needs"), fragments, "Ninth Door requires each of the nine scoped fragments")
	for pair in [["ow_9_7", "cave_8_1"], ["ow_10_8", "cave_10_1"]]:
		var root := scene_root(WorldData.scene_path(pair[0]))
		var door := _door_to(root, pair[1])
		check_eq(door.get("spawn", ""), "FromOverworld", "cave mouth uses contracted spawn")
		if not ResourceLoader.exists(WorldData.scene_path(pair[1])):
			print("PENDING R6: actual destination ", pair[1], "; mouth only accepted")
	_mutation()
	for item: String in pending:
		check(
			item.begins_with("door ") and ("cave_8_1" in item or "cave_10_1" in item),
			"only the two future cave destinations may remain pending: %s" % item
		)
		print("PENDING R6: ", item)
	free_scenes()


func _mutation() -> void:
	var packed := load(WorldData.scene_path("ow_11_6")) as PackedScene
	check(packed != null, "Tide Cache loads for mutation")
	if packed == null:
		return
	var broken := packed.instantiate() as Room
	for door in descendants_of_class(broken, RoomDoor):
		door.target_room = &"ow_0_0"
	check(not room_problems("ow_11_6", broken).is_empty(), "wrong cache destination is rejected")
	broken.free()
