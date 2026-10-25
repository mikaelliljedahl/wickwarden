extends RefCounted
## Extracts the graph represented by the built room scenes and checks it with the canonical solver.
## The graph source supplies solver-only metadata; observable room, gate, door and pickup contracts
## are read from the scenes and must agree before a graph is written.

const WORLD_DATA_PATH := "res://data/world_data.json"
const SOURCE_GRAPH_PATH := "res://docs/world-graph.json"
const ROOM_DIR := "res://scenes/world/rooms"
const AREA_BASE_PATH := "res://tests/area_base.gd"
const CHECKER_PATH := "res://tools/check_world_graph.py"
const OUTPUT_PATH := "user://scene-graph.json"


func run() -> Array[String]:
	var failures: Array[String] = []
	var world_data := _read_json(WORLD_DATA_PATH, failures)
	var source_graph := _read_json(SOURCE_GRAPH_PATH, failures)
	if not failures.is_empty():
		return failures

	var scene_paths: Dictionary = {}
	var room_records := _index_records(world_data["rooms"], "room", failures)
	var pocket_records := _index_records(world_data["pockets"], "pocket", failures)
	for id: String in room_records:
		scene_paths[id] = String(room_records[id]["scene"])
	for id: String in pocket_records:
		var pocket: Dictionary = pocket_records[id]
		if not bool(pocket["in_place"]):
			scene_paths[id] = String(pocket["scene"])

	_check_scene_file_set(scene_paths, failures)
	_check_source_sets(source_graph, world_data, room_records, pocket_records, failures)

	var validator_script := load(AREA_BASE_PATH) as GDScript
	if validator_script == null:
		failures.append("could not load the shared graph/scene validator %s" % AREA_BASE_PATH)
		return failures
	var validator: Variant = validator_script.new()
	validator.call("index_world")

	var roots_by_id: Dictionary = {}
	var roots_by_path: Dictionary = {}
	var expected_ids: Array[String] = []
	for id: String in scene_paths:
		expected_ids.append(id)
	expected_ids.sort()
	for id in expected_ids:
		var path := String(scene_paths[id])
		if not ResourceLoader.exists(path):
			failures.append("planned scene %s is missing: %s" % [id, path])
			continue
		var packed := ResourceLoader.load(path) as PackedScene
		if packed == null:
			failures.append("scene %s failed to load as a PackedScene: %s" % [id, path])
			continue
		var root := packed.instantiate()
		if root == null:
			failures.append("scene %s failed to instantiate: %s" % [id, path])
			continue
		roots_by_id[id] = root
		roots_by_path[path] = root
		_check_room_root(id, root, room_records, pocket_records, failures)

	validator.set("scene_cache", roots_by_path)
	_check_gate_props(world_data["edges"], validator, failures)
	_check_doors(expected_ids, roots_by_id, scene_paths, validator, failures)
	_check_pickups(expected_ids, roots_by_id, validator, failures)
	_check_cave_mouths(world_data["caves"], roots_by_id, failures)
	_check_persistent_ids(expected_ids, roots_by_id, failures)

	if not failures.is_empty():
		validator.free()
		_free_roots(roots_by_id)
		return failures

	var extracted := _make_scene_graph(source_graph, world_data, room_records, pocket_records, roots_by_id)
	if not _write_json(OUTPUT_PATH, extracted):
		validator.free()
		_free_roots(roots_by_id)
		return ["could not write %s" % OUTPUT_PATH]

	var checker_output: Array = []
	var checker := ProjectSettings.globalize_path(CHECKER_PATH)
	var graph_path := ProjectSettings.globalize_path(OUTPUT_PATH)
	var exit_code := OS.execute("python3", [checker, graph_path, "--no-selftest"], checker_output, true)
	if not checker_output.is_empty():
		print("\n".join(checker_output))
	if exit_code != 0:
		validator.free()
		_free_roots(roots_by_id)
		return ["tools/check_world_graph.py rejected the extracted scene graph (exit %d)" % exit_code]

	print("scene graph written to %s" % OUTPUT_PATH)
	validator.free()
	_free_roots(roots_by_id)
	return failures


## Loads a named, controlled scene sample for fast contract feedback while a full content cohort is
## still arriving. This never writes a graph or relaxes run()'s all-scenes requirement.
func inspect_fixture_scenes(fixture_ids: Array[String]) -> Array[String]:
	var failures: Array[String] = []
	var world_data := _read_json(WORLD_DATA_PATH, failures)
	if not failures.is_empty():
		return failures
	var room_records := _index_records(world_data["rooms"], "room", failures)
	var pocket_records := _index_records(world_data["pockets"], "pocket", failures)
	var scene_paths: Dictionary = {}
	for id: String in room_records:
		scene_paths[id] = String(room_records[id]["scene"])
	for id: String in pocket_records:
		var pocket: Dictionary = pocket_records[id]
		if not bool(pocket["in_place"]):
			scene_paths[id] = String(pocket["scene"])

	var validator_script := load(AREA_BASE_PATH) as GDScript
	if validator_script == null:
		return ["could not load the shared graph/scene validator %s" % AREA_BASE_PATH]
	var validator: Variant = validator_script.new()
	validator.call("index_world")
	var roots_by_id: Dictionary = {}
	for id in fixture_ids:
		if not scene_paths.has(id):
			failures.append("fixture %s has no standalone scene" % id)
			continue
		var path := String(scene_paths[id])
		if not ResourceLoader.exists(path):
			failures.append("fixture scene %s is missing: %s" % [id, path])
			continue
		var packed := ResourceLoader.load(path) as PackedScene
		if packed == null:
			failures.append("fixture scene %s failed to load: %s" % [id, path])
			continue
		var root := packed.instantiate()
		if root == null:
			failures.append("fixture scene %s failed to instantiate: %s" % [id, path])
			continue
		roots_by_id[id] = root
		_check_room_root(id, root, room_records, pocket_records, failures)
		var pickups: Array[Node] = []
		for node in _descendants(root):
			if node is PickupBase:
				pickups.append(node)
			elif node is Area2D:
				var script: Script = node.get_script()
				if script != null and script.resource_path.ends_with("/shop_item.gd"):
					pickups.append(node)
		var pickup_failures: Array[String] = []
		validator.call("_check_pickup_specs", id, pickups, pickup_failures)
		failures.append_array(pickup_failures)
	_check_persistent_ids(fixture_ids, roots_by_id, failures)
	validator.free()
	_free_roots(roots_by_id)
	return failures


func _read_json(path: String, failures: Array[String]) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		failures.append("could not read %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		failures.append("%s is not a JSON object" % path)
		return {}
	return parsed


func _index_records(records: Array, label: String, failures: Array[String]) -> Dictionary:
	var indexed: Dictionary = {}
	for value: Variant in records:
		if not value is Dictionary or not value.has("id"):
			failures.append("%s data contains a record without an id" % label)
			continue
		var id := String(value["id"])
		if indexed.has(id):
			failures.append("duplicate %s id %s in world data" % [label, id])
		else:
			indexed[id] = value
	return indexed


func _check_scene_file_set(scene_paths: Dictionary, failures: Array[String]) -> void:
	var directory := DirAccess.open(ROOM_DIR)
	if directory == null:
		failures.append("could not open room scene directory %s" % ROOM_DIR)
		return
	var expected_stems: Dictionary = {}
	for id: String in scene_paths:
		expected_stems[String(scene_paths[id]).get_file().get_basename()] = id
	var actual_stems: Dictionary = {}
	for file_name: String in directory.get_files():
		if file_name.ends_with(".tscn"):
			actual_stems[file_name.get_basename()] = true
	var missing: Array[String] = []
	var unexpected: Array[String] = []
	for stem: String in expected_stems:
		if not actual_stems.has(stem):
			missing.append(String(expected_stems[stem]))
	for stem: String in actual_stems:
		if not expected_stems.has(stem):
			unexpected.append(stem + ".tscn")
	missing.sort()
	unexpected.sort()
	if not missing.is_empty():
		failures.append("missing planned room/pocket scenes (%d): %s" % [missing.size(), ", ".join(missing)])
	if not unexpected.is_empty():
		failures.append("unexpected room scene ids (%d): %s" % [unexpected.size(), ", ".join(unexpected)])


func _check_source_sets(
	source_graph: Dictionary,
	world_data: Dictionary,
	room_records: Dictionary,
	pocket_records: Dictionary,
	failures: Array[String]
) -> void:
	var expected_nodes: Dictionary = {}
	for id: String in room_records:
		expected_nodes[id] = true
	for id: String in pocket_records:
		expected_nodes[id] = true
	var graph_nodes: Dictionary = {}
	for node: Dictionary in source_graph.get("nodes", []):
		var id := String(node.get("id", ""))
		if id == "" or graph_nodes.has(id):
			failures.append("source graph has an empty or duplicate node id %s" % id)
		else:
			graph_nodes[id] = true
	if not _same_keys(graph_nodes, expected_nodes):
		failures.append("source graph node ids differ from runtime room and pocket ids")

	var graph_edges: Dictionary = {}
	for edge: Dictionary in source_graph.get("edges", []):
		var id := String(edge.get("id", ""))
		if id == "" or graph_edges.has(id):
			failures.append("source graph has an empty or duplicate edge id %s" % id)
		else:
			graph_edges[id] = true
	var runtime_edges: Dictionary = {}
	for edge: Dictionary in world_data.get("edges", []):
		var id := String(edge.get("id", ""))
		if id == "" or runtime_edges.has(id):
			failures.append("runtime world data has an empty or duplicate edge id %s" % id)
		else:
			runtime_edges[id] = true
	if not _same_keys(graph_edges, runtime_edges):
		failures.append("source graph edge ids differ from runtime edge ids")

	var expected_capabilities: Dictionary = {}
	for capability: String in source_graph.get("base_capabilities", []):
		expected_capabilities[capability] = true
	for capability: String in world_data.get("items", {}):
		expected_capabilities[capability] = true
	var graph_capabilities: Dictionary = {}
	for capability: String in source_graph.get("capabilities", {}):
		graph_capabilities[capability] = true
	if not _same_keys(graph_capabilities, expected_capabilities):
		failures.append("source graph capability ids differ from runtime item ids and base capabilities")

	var data_source_sha := String(world_data.get("source_sha", ""))
	if data_source_sha == "" or data_source_sha != FileAccess.get_sha256(SOURCE_GRAPH_PATH):
		failures.append("runtime world data is stale against %s" % SOURCE_GRAPH_PATH)


func _check_room_root(
	id: String,
	root: Node,
	room_records: Dictionary,
	pocket_records: Dictionary,
	failures: Array[String]
) -> void:
	if not root is Room:
		failures.append("scene %s does not have a Room root" % id)
		return
	var room := root as Room
	if String(room.room_id) != id:
		failures.append("scene %s has room_id %s" % [id, room.room_id])
	if room_records.has(id):
		var record: Dictionary = room_records[id]
		var grid: Array = record["grid"]
		var expected_grid := Vector2i(int(grid[0]), int(grid[1]))
		if room.grid != expected_grid:
			failures.append("room %s grid is %s, expected %s" % [id, room.grid, expected_grid])
		var expected_exits: Array[String] = []
		for side: String in record["exits"]:
			expected_exits.append(side)
		var actual_exits: Array[String] = []
		for side: StringName in room.exits:
			actual_exits.append(String(side))
		expected_exits.sort()
		actual_exits.sort()
		if actual_exits != expected_exits:
			failures.append("room %s exits are %s, expected %s" % [id, actual_exits, expected_exits])
		if room.dark != bool(record["dark"]):
			failures.append("room %s dark flag differs from runtime world data" % id)
	elif pocket_records.has(id):
		var record: Dictionary = pocket_records[id]
		var grid: Array = record["grid"]
		var expected_grid := Vector2i(int(grid[0]), int(grid[1]))
		if room.grid != expected_grid:
			failures.append("pocket %s grid is %s, expected %s" % [id, room.grid, expected_grid])
		if not room.exits.is_empty():
			failures.append("pocket %s has world exits %s" % [id, room.exits])


func _check_gate_props(edges: Array, validator: Variant, failures: Array[String]) -> void:
	for edge: Dictionary in edges:
		if edge.get("gate") == null:
			continue
		var status := String(validator.call("edge_status", edge))
		if status != "ok":
			failures.append("gate %s (%s, %s): scene prop status is %s" % [edge["id"], edge["prop"], edge["gate"], status])


func _check_doors(
	ids: Array[String], roots_by_id: Dictionary, scene_paths: Dictionary, validator: Variant, failures: Array[String]
) -> void:
	for id in ids:
		var root: Node = roots_by_id.get(id)
		if root == null:
			continue
		var problems: Array[String] = []
		validator.set("subject_path", String(scene_paths[id]))
		validator.set("subject_room", root)
		validator.call("_check_doors", id, root, problems)
		for problem: String in problems:
			failures.append(problem)


func _check_pickups(ids: Array[String], roots_by_id: Dictionary, validator: Variant, failures: Array[String]) -> void:
	for id in ids:
		var root: Node = roots_by_id.get(id)
		if root == null:
			continue
		var pickups: Array[Node] = []
		for node in _descendants(root):
			if node is PickupBase:
				pickups.append(node)
			elif node is Area2D:
				var script: Script = node.get_script()
				if script != null and script.resource_path.ends_with("/shop_item.gd"):
					pickups.append(node)
		var problems: Array[String] = []
		validator.call("_check_pickup_specs", id, pickups, problems)
		for problem: String in problems:
			failures.append(problem)


func _check_cave_mouths(caves: Array, roots_by_id: Dictionary, failures: Array[String]) -> void:
	for cave: Dictionary in caves:
		var mouth := String(cave["mouth"])
		var entrance := String(cave["entrance"])
		var mouth_root: Node = roots_by_id.get(mouth)
		var entrance_root: Node = roots_by_id.get(entrance)
		if mouth_root == null or entrance_root == null:
			continue
		if mouth_root.get_node_or_null("Spawns/FromCave") == null:
			failures.append("cave mouth %s is missing Spawns/FromCave" % mouth)
		if entrance_root.get_node_or_null("Spawns/FromOverworld") == null:
			failures.append("cave entrance %s is missing Spawns/FromOverworld" % entrance)
		var outbound := false
		for node in _descendants(mouth_root):
			var door := _door_entry(node)
			if String(door.get("target", "")) == entrance:
				outbound = true
				if String(door.get("spawn", "")) != "FromOverworld":
					var message := "cave mouth %s targets %s at marker %s, expected FromOverworld"
					failures.append(message % [mouth, entrance, door.get("spawn", "")])
		if not outbound:
			failures.append("cave mouth %s has no door targeting %s" % [mouth, entrance])
		var inbound := false
		for node in _descendants(entrance_root):
			var door := _door_entry(node)
			if String(door.get("target", "")) == mouth:
				inbound = true
				if String(door.get("spawn", "")) != "FromCave":
					var message := "cave entrance %s targets %s at marker %s, expected FromCave"
					failures.append(message % [entrance, mouth, door.get("spawn", "")])
		if not inbound:
			failures.append("cave entrance %s has no door targeting %s" % [entrance, mouth])


func _door_entry(node: Node) -> Dictionary:
	if node is RoomDoor:
		return {"target": String(node.target_room), "spawn": String(node.target_spawn)}
	var script: Script = node.get_script()
	if script != null and script.resource_path.ends_with("/hidden_seam.gd"):
		return {"target": String(node.get("door_target")), "spawn": String(node.get("door_spawn"))}
	return {}


func _check_persistent_ids(ids: Array[String], roots_by_id: Dictionary, failures: Array[String]) -> void:
	var seen: Dictionary = {}
	for id in ids:
		var root: Node = roots_by_id.get(id)
		if root == null:
			continue
		for node in _descendants(root):
			if not node is PickupBase:
				continue
			var pickup := node as PickupBase
			var persistent_id := String(pickup.persistent_id)
			if pickup.respawn_on_enter:
				if persistent_id != "":
					failures.append("respawning refill %s in %s must not use a persistent_id" % [node.name, id])
				continue
			if persistent_id == "":
				failures.append("pickup %s in %s has no persistent_id" % [node.name, id])
			elif seen.has(persistent_id):
				failures.append("persistent_id %s is shared by %s and %s" % [persistent_id, seen[persistent_id], id])
			else:
				seen[persistent_id] = id


func _make_scene_graph(
	source_graph: Dictionary,
	world_data: Dictionary,
	room_records: Dictionary,
	pocket_records: Dictionary,
	roots_by_id: Dictionary
) -> Dictionary:
	var graph: Dictionary = source_graph.duplicate(true)
	var nodes: Array[Dictionary] = []
	for source_node: Dictionary in source_graph["nodes"]:
		var node: Dictionary = source_node.duplicate(true)
		var id := String(node["id"])
		if room_records.has(id):
			var room := roots_by_id[id] as Room
			node["grid"] = [room.grid.x, room.grid.y]
			node["exits"] = _exit_strings(room)
			node["dark"] = room.dark
			node["enemies"] = room_records[id]["enemies"].duplicate(true)
		elif pocket_records.has(id):
			var pocket: Dictionary = pocket_records[id]
			if not bool(pocket["in_place"]):
				var room := roots_by_id[id] as Room
				node["grid"] = [room.grid.x, room.grid.y]
				node["exits"] = _exit_strings(room)
		var gates: Array[String] = []
		for edge: Dictionary in world_data["edges"]:
			if edge.get("gate") != null and (String(edge["a"]) == id or String(edge["b"]) == id):
				gates.append(String(edge["id"]))
		gates.sort()
		node["gates"] = gates
		nodes.append(node)
	graph["nodes"] = nodes
	graph["edges"] = world_data["edges"].duplicate(true)
	graph["items"] = world_data["items"].duplicate(true)
	graph["pickups"] = world_data["pickups"].duplicate(true)
	return graph


func _exit_strings(room: Room) -> Array[String]:
	var exits: Array[String] = []
	for side: StringName in room.exits:
		exits.append(String(side))
	exits.sort()
	return exits


func _descendants(root: Node) -> Array[Node]:
	var found: Array[Node] = []
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		found.append(node)
		stack.append_array(node.get_children())
	return found


func _same_keys(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for key: Variant in a:
		if not b.has(key):
			return false
	return true


func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "\t") + "\n")
	return file.get_error() == OK


func _free_roots(roots_by_id: Dictionary) -> void:
	for root: Node in roots_by_id.values():
		if is_instance_valid(root):
			root.free()
