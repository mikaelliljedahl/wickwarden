extends TestCase
## Strict Q2 inventory gate. Counts and scene paths come from generated world data; no missing
## scene is treated as pending.

const ROOM_COUNT := 192
const POCKET_COUNT := 33
const IN_PLACE_COUNT := 3
const STANDALONE_POCKET_COUNT := 30
const SCENE_COUNT := 222
const SCENE_DIR := "res://scenes/world/rooms"
const IN_PLACE_IDS := ["cave_1#alcove", "ow_2_0#cache", "ow_2_1#closet"]


func run() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(WorldData.PATH))
	check(typeof(parsed) == TYPE_DICTIONARY, "world data is a JSON object")
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var world: Dictionary = parsed
	var rooms: Array = world.get("rooms", [])
	var pockets: Array = world.get("pockets", [])
	var ids := _assert_graph_counts(rooms, pockets)
	_assert_unique_ids(rooms, pockets)
	_assert_scene_inventory(ids)


func _assert_graph_counts(rooms: Array, pockets: Array) -> Array[String]:
	var room_ids := WorldData.room_ids()
	var pocket_ids := WorldData.all_pockets()
	var in_place_ids: Array[String] = []
	var scene_ids: Array[String] = []
	for pocket: Dictionary in pockets:
		var id := String(pocket["id"])
		if bool(pocket.get("in_place", false)):
			in_place_ids.append(id)
		else:
			scene_ids.append(id)
	in_place_ids.sort()
	check_eq(rooms.size(), ROOM_COUNT, "the graph has all 192 main rooms")
	check_eq(room_ids.size(), ROOM_COUNT, "WorldData exposes all 192 main rooms")
	check_eq(pockets.size(), POCKET_COUNT, "the graph has all 33 pockets")
	check_eq(pocket_ids.size(), POCKET_COUNT, "WorldData exposes all 33 pockets")
	check_eq(in_place_ids.size(), IN_PLACE_COUNT, "exactly three pockets are in-place")
	check_eq(in_place_ids, IN_PLACE_IDS, "the three binding in-place pockets stay in their hosts")
	check_eq(scene_ids.size(), STANDALONE_POCKET_COUNT, "all 30 other pockets have scenes")
	check_eq(
		room_ids.size() + scene_ids.size(), SCENE_COUNT,
		"the graph requires 222 standalone room and pocket scenes"
	)
	room_ids.append_array(scene_ids)
	room_ids.sort()
	return room_ids


func _assert_unique_ids(rooms: Array, pockets: Array) -> void:
	var owners: Dictionary = {}
	for record: Dictionary in rooms + pockets:
		var id := String(record.get("id", ""))
		check(id != "", "every graph node has an id")
		if id == "":
			continue
		check(not owners.has(id), "world node id %s is unique" % id)
		owners[id] = true
	check_eq(owners.size(), ROOM_COUNT + POCKET_COUNT, "all 225 graph node ids are unique")


func _assert_scene_inventory(ids: Array[String]) -> void:
	var expected_paths: Dictionary = {}
	for id in ids:
		var path := WorldData.scene_path(id)
		check(path != "", "%s has a standalone scene path" % id)
		if path == "":
			continue
		check(not expected_paths.has(path), "scene path %s belongs to one graph id" % path)
		expected_paths[path] = id
		check(ResourceLoader.exists(path), "%s scene exists" % id)
	check_eq(expected_paths.size(), SCENE_COUNT, "the graph maps to exactly 222 scene paths")

	var directory := DirAccess.open(SCENE_DIR)
	check(directory != null, "the room scene directory exists")
	if directory == null:
		return
	var actual_paths: Dictionary = {}
	for filename in directory.get_files():
		if not filename.ends_with(".tscn"):
			continue
		var path := "%s/%s" % [SCENE_DIR, filename]
		actual_paths[path] = true
		check(expected_paths.has(path), "scene %s has a graph node" % path)
	for path: String in expected_paths:
		check(actual_paths.has(path), "graph scene %s is present in the directory" % path)
	check_eq(actual_paths.size(), SCENE_COUNT, "there are exactly 222 room and pocket scenes")
