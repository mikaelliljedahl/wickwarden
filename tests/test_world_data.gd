extends TestCase
## WorldData: the generated run-time copy of docs/world-graph.json (data/world_data.json).
## Checks the counts, the scene names, the grids, the exits against the step links, the source
## hash of the graph and the query helpers. Regenerate with `make world-data` after a graph change.

const DATA_PATH := "res://data/world_data.json"
const GRAPH_PATH := "res://docs/world-graph.json"
const ROOM_SCENES := "res://scenes/world/rooms/"


func run() -> void:
	_counts()
	_source()
	_scene_paths()
	_grids()
	_exits_are_the_step_links()
	_queries()


func _raw() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))


func _counts() -> void:
	var raw := _raw()
	check_eq(WorldData.room_ids().size(), 192, "192 rooms")
	check_eq(WorldData.all_pockets().size(), 33, "33 pockets")
	check_eq(raw["edges"].size(), 259, "259 edges")
	check_eq(raw["pickups"].size(), 73, "73 pickups")
	check_eq(raw["caves"].size(), 10, "10 caves")
	check_eq(raw["shops"].size(), 6, "6 shops")
	var in_place := 0
	for pocket: Dictionary in raw["pockets"]:
		if pocket["in_place"]:
			in_place += 1
	check_eq(in_place, 3, "three pockets open in place (no scene)")


func _source() -> void:
	var raw := _raw()
	check_eq(int(raw["format"]), 1, "format 1")
	check_eq(str(raw["source_sha"]), FileAccess.get_sha256(GRAPH_PATH),
		"data built from the current docs/world-graph.json (run make world-data)")


func _scene_paths() -> void:
	for id in WorldData.room_ids():
		check_eq(WorldData.scene_path(id), ROOM_SCENES + id + ".tscn", "scene of room %s" % id)
	for pocket: Dictionary in _raw()["pockets"]:
		var id: String = pocket["id"]
		if pocket["in_place"]:
			check_eq(WorldData.scene_path(id), "", "in-place pocket %s has no scene" % id)
		else:
			var scene := ROOM_SCENES + id.replace("#", "__") + ".tscn"
			check_eq(WorldData.scene_path(id), scene, "scene of pocket %s" % id)


func _grids() -> void:
	var cells := {}
	for id in WorldData.room_ids():
		var cell := WorldData.grid(id)
		check(not cells.has(cell), "grid %s of %s is unique" % [cell, id])
		cells[cell] = id
		if WorldData.scope_of(id) == "ow":
			check(cell.x >= 0 and cell.x <= 11 and cell.y >= 0 and cell.y <= 8,
				"overworld room %s is in x 0..11, y 0..8" % id)
		else:
			check(cell.y >= 12, "cave room %s is in row 12 or later" % id)
	for id in WorldData.all_pockets():
		var cell := WorldData.grid(id)
		check(cell.y == WorldData.POCKET_ROW, "pocket %s sits in the pocket row" % id)
		check(not cells.has(cell), "pocket %s shares no cell with a room" % id)
		cells[cell] = id


func _exits_are_the_step_links() -> void:
	var expected := {}
	for id in WorldData.room_ids():
		expected[id] = []
	for edge: Dictionary in _raw()["edges"]:
		if edge["link"] != "step":
			continue
		var a: String = edge["a"]
		var b: String = edge["b"]
		expected[a].append(_side(WorldData.grid(a), WorldData.grid(b)))
		# A one-way ledge is listed by its upper room only.
		if edge["dir"] == "both":
			expected[b].append(_side(WorldData.grid(b), WorldData.grid(a)))
	for id in WorldData.room_ids():
		var sides := WorldData.exits(id)
		sides.sort()
		var wanted: Array = expected[id]
		wanted.sort()
		check_eq(sides, wanted, "exits of %s equal its step links" % id)


func _side(from: Vector2i, to: Vector2i) -> String:
	var step := to - from
	if step == Vector2i(0, -1):
		return "n"
	if step == Vector2i(1, 0):
		return "e"
	if step == Vector2i(0, 1):
		return "s"
	if step == Vector2i(-1, 0):
		return "w"
	return "?"


func _queries() -> void:
	check(WorldData.has("ow_0_0"), "a room is known")
	check(WorldData.has("ow_2_0#cache"), "a pocket is known")
	check(not WorldData.has("no_such_room"), "an unknown id is not known")
	check_eq(WorldData.scene_path("ow_1_2#shop"), ROOM_SCENES + "ow_1_2__shop.tscn", "shop pocket scene")
	check_eq(WorldData.scene_path("no_such_room"), "", "unknown id has no scene")
	check_eq(WorldData.grid("cave_5_6"), Vector2i(33, 12), "cave grid is the global cell")
	check_eq(WorldData.grid("no_such_room"), Vector2i(-1, -1), "unknown id has no grid")
	check_eq(WorldData.exits("ow_0_0"), ["e", "s"], "exits of the start room")
	check(WorldData.exits("ow_2_0#cache").is_empty(), "pockets have no exits")
	check_eq(WorldData.scope_of("ow_0_0"), "ow", "overworld scope")
	check_eq(WorldData.scope_of("cave_1_4"), "c1", "cave 1 scope")
	check_eq(WorldData.scope_of("cave_1#alcove"), "c1", "pocket of cave 1 has the cave scope")
	check_eq(WorldData.cave_of("cave_10_14"), "c10", "cave_of a cave room")
	check_eq(WorldData.cave_of("ow_0_0"), "", "cave_of an overworld room is empty")
	check(WorldData.neighbors("ow_0_0").has("ow_1_0"), "the east neighbour is linked")
	check_eq(WorldData.edge_between("ow_1_0", "ow_0_0")["id"], "e001", "edge found in either order")
	check(WorldData.edge_between("ow_0_0", "ow_5_5").is_empty(), "no edge between distant rooms")
	check(WorldData.is_oneway("ow_4_2", "ow_4_3"), "the ledge drops from ow_4_2 to ow_4_3")
	check(not WorldData.is_oneway("ow_4_3", "ow_4_2"), "the ledge cannot be climbed back")
	check(not WorldData.is_oneway("ow_0_0", "ow_1_0"), "a two-way link is not one-way")
	var pickups := WorldData.pickups_in("ow_2_0#cache")
	check_eq(pickups.size(), 1, "the cache holds one pickup")
	check_eq(pickups[0]["id"], "wick_core_ow_2_0", "the cache holds the wick core")
	check(WorldData.pickups_in("no_such_room").is_empty(), "unknown id has no pickups")
