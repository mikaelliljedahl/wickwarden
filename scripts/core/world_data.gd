class_name WorldData
extends RefCounted
## Run-time view of data/world_data.json: the trimmed copy of docs/world-graph.json written by
## tools/gen_world_data.py. Never edit the JSON by hand; `make world-data` regenerates it.
##
## Static helpers only. The file is read on first use and kept. Ids are Strings as in the JSON:
## rooms `ow_0_0` and `cave_1_4`, pockets `ow_2_0#cache`. An unknown id gives empty results.

const PATH := "res://data/world_data.json"
## Virtual grid row of every pocket. No room uses this row.
const POCKET_ROW := 30

static var _loaded := false
static var _rooms: Dictionary = {}
static var _pockets: Dictionary = {}
static var _edges_by_node: Dictionary = {}
static var _pickups_by_node: Dictionary = {}


## Every room id in file order (192 rooms). Pockets are not included.
static func room_ids() -> Array[String]:
	_ensure_loaded()
	var ids: Array[String] = []
	for id: String in _rooms:
		ids.append(id)
	return ids


## Every pocket id in file order (secret closets, shops, cache alcoves, ward plates).
static func all_pockets() -> Array[String]:
	_ensure_loaded()
	var ids: Array[String] = []
	for id: String in _pockets:
		ids.append(id)
	return ids


## True for a room id or a pocket id of the graph.
static func has(id: String) -> bool:
	return not _record(id).is_empty()


## Scene of a room or pocket, `res://scenes/world/rooms/<id>.tscn` (a pocket replaces `#` by `__`).
## Empty for an unknown id and for a pocket that opens in place, because it has no scene.
static func scene_path(id: String) -> String:
	var scene: Variant = _record(id).get("scene")
	return str(scene) if scene is String else ""


## Grid cell of a room or pocket. Overworld rooms use y 0..8, cave rooms y 12 and later, pockets
## POCKET_ROW. Vector2i(-1, -1) for an unknown id.
static func grid(id: String) -> Vector2i:
	var cell: Array = _record(id).get("grid", [])
	if cell.size() != 2:
		return Vector2i(-1, -1)
	return Vector2i(int(cell[0]), int(cell[1]))


## Sides ("n", "e", "s", "w") that lead through a step link. Empty for pockets and unknown ids.
static func exits(id: String) -> Array[String]:
	var sides: Array[String] = []
	for side in _record(id).get("exits", []):
		sides.append(str(side))
	return sides


## "ow" for overworld rooms and pockets, "c1" .. "c10" for cave rooms and pockets, "" if unknown.
static func scope_of(id: String) -> String:
	return str(_record(id).get("scope", ""))


## The cave key ("c1" .. "c10") of a cave room or pocket, "" for overworld and unknown ids.
static func cave_of(id: String) -> String:
	var scope := scope_of(id)
	return scope if scope.begins_with("c") else ""


## Ids joined to `id` by an edge of any kind (step or door), in file order.
static func neighbors(id: String) -> Array[String]:
	_ensure_loaded()
	var ids: Array[String] = []
	for edge: Dictionary in _edges_by_node.get(id, []):
		ids.append(_other_end(edge, id))
	return ids


## The edge record joining `a` and `b` (either order), or an empty Dictionary when there is none.
static func edge_between(a: String, b: String) -> Dictionary:
	_ensure_loaded()
	for edge: Dictionary in _edges_by_node.get(a, []):
		if _other_end(edge, a) == b:
			return edge
	return {}


## True when the link between `from_id` and `to_id` can only be walked from `from_id` to `to_id`
## (a ledge drop: the edge has dir "a>b" and `from_id` is its `a`). False for a two-way link, a
## missing link and the reverse direction.
static func is_oneway(from_id: String, to_id: String) -> bool:
	var edge := edge_between(from_id, to_id)
	return not edge.is_empty() and edge["dir"] == "a>b" and str(edge["a"]) == from_id


## Pickup records placed on a room or pocket, in file order.
static func pickups_in(id: String) -> Array[Dictionary]:
	_ensure_loaded()
	var pickups: Array[Dictionary] = []
	for pickup: Dictionary in _pickups_by_node.get(id, []):
		pickups.append(pickup)
	return pickups


static func _record(id: String) -> Dictionary:
	_ensure_loaded()
	if _rooms.has(id):
		return _rooms[id]
	return _pockets.get(id, {})


static func _other_end(edge: Dictionary, id: String) -> String:
	return str(edge["b"]) if str(edge["a"]) == id else str(edge["a"])


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("WorldData: %s is missing or is not a JSON object" % PATH)
		return
	var data: Dictionary = parsed
	for room: Dictionary in data.get("rooms", []):
		_rooms[room["id"]] = room
	for pocket: Dictionary in data.get("pockets", []):
		_pockets[pocket["id"]] = pocket
	for edge: Dictionary in data.get("edges", []):
		_append_to(_edges_by_node, str(edge["a"]), edge)
		_append_to(_edges_by_node, str(edge["b"]), edge)
	for pickup: Dictionary in data.get("pickups", []):
		_append_to(_pickups_by_node, str(pickup["node"]), pickup)


static func _append_to(index: Dictionary, key: String, record: Dictionary) -> void:
	if not index.has(key):
		index[key] = []
	index[key].append(record)
