extends TestCase
## Q1: rebuild the solver input from the built room scenes, compare its id sets with WorldData,
## and prove that removing a scene-backed gate reference is rejected by the canonical checker.

const WORLD_DATA_PATH := "res://data/world_data.json"
const SOURCE_GRAPH_PATH := "res://docs/world-graph.json"
const GRAPH_OUTPUT_PATH := "user://scene-graph.json"
const MUTATION_OUTPUT_PATH := "user://scene-graph-mutated.json"
const CHECKER_PATH := "res://tools/check_world_graph.py"
const EXTRACTOR_PATH := "res://tools/extract_scene_graph.gd"
const FIXTURE_SCENE_IDS: Array[String] = [
	"ow_0_0", "cave_1", "ow_2_1", "ow_1_2#shop", "cave_9_4"
]


func run() -> void:
	var extractor_script := load(EXTRACTOR_PATH) as GDScript
	check(extractor_script != null, "the scene extractor script loads")
	if extractor_script == null:
		return
	var extractor: Variant = extractor_script.new()
	var fixture_failures: Array[String] = extractor.call("inspect_fixture_scenes", FIXTURE_SCENE_IDS)
	check(fixture_failures.is_empty(), "controlled built-scene fixtures satisfy room and pickup contracts")
	if not fixture_failures.is_empty():
		for failure: String in fixture_failures:
			printerr("SCENE FIXTURE: ", failure)

	var source_graph := _read_graph(SOURCE_GRAPH_PATH)
	check(not source_graph.is_empty(), "the canonical graph fixture is readable")
	if not source_graph.is_empty():
		_mutation_is_rejected(source_graph)

	var extraction_failures: Array[String] = extractor.call("run")
	check(extraction_failures.is_empty(), "scene extraction and canonical graph solver pass")
	if not extraction_failures.is_empty():
		for failure: String in extraction_failures:
			printerr("SCENE GRAPH: ", failure)
		return

	var graph_file := FileAccess.open(GRAPH_OUTPUT_PATH, FileAccess.READ)
	check(graph_file != null, "the extractor writes user://scene-graph.json")
	if graph_file == null:
		return
	var parsed: Variant = JSON.parse_string(graph_file.get_as_text())
	check(parsed is Dictionary, "the extracted scene graph is a JSON object")
	if not parsed is Dictionary:
		return
	var scene_graph: Dictionary = parsed
	var world_file := FileAccess.open(WORLD_DATA_PATH, FileAccess.READ)
	check(world_file != null, "runtime world data is readable")
	if world_file == null:
		return
	var world_parsed: Variant = JSON.parse_string(world_file.get_as_text())
	check(world_parsed is Dictionary, "runtime world data is a JSON object")
	if not world_parsed is Dictionary:
		return
	var world_data: Dictionary = world_parsed
	_check_id_sets(scene_graph, world_data)
	_mutation_is_rejected(scene_graph)


func _read_graph(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}


func _check_id_sets(scene_graph: Dictionary, world_data: Dictionary) -> void:
	var expected_nodes: Dictionary = {}
	for room: Dictionary in world_data["rooms"]:
		expected_nodes[String(room["id"])] = true
	for pocket: Dictionary in world_data["pockets"]:
		expected_nodes[String(pocket["id"])] = true
	var scene_nodes: Dictionary = {}
	for node: Dictionary in scene_graph.get("nodes", []):
		scene_nodes[String(node.get("id", ""))] = true
	check(_same_keys(scene_nodes, expected_nodes), "scene graph node ids equal all runtime rooms and pockets")

	var expected_edges: Dictionary = {}
	for edge: Dictionary in world_data["edges"]:
		expected_edges[String(edge["id"])] = true
	var scene_edges: Dictionary = {}
	for edge: Dictionary in scene_graph.get("edges", []):
		scene_edges[String(edge.get("id", ""))] = true
	check(_same_keys(scene_edges, expected_edges), "scene graph edge ids equal all runtime edges")

	var expected_capabilities: Dictionary = {}
	for capability: String in scene_graph.get("base_capabilities", []):
		expected_capabilities[capability] = true
	for capability: String in world_data.get("items", {}):
		expected_capabilities[capability] = true
	var scene_capabilities: Dictionary = {}
	for capability: String in scene_graph.get("capabilities", {}):
		scene_capabilities[capability] = true
	check(
		_same_keys(scene_capabilities, expected_capabilities),
		"scene graph capability ids equal runtime item ids plus base capabilities"
	)


func _mutation_is_rejected(scene_graph: Dictionary) -> void:
	var mutated: Dictionary = scene_graph.duplicate(true)
	var removed := false
	for node: Dictionary in mutated.get("nodes", []):
		var gates: Array = node.get("gates", [])
		if gates.is_empty():
			continue
		var gate_id := String(gates[0])
		gates.remove_at(0)
		node["gates"] = gates
		removed = true
		print("mutation: removed gate prop reference %s from node %s" % [gate_id, node["id"]])
		break
	check(removed, "the scene graph contains a gate prop reference to mutate")
	if not removed:
		return
	var file := FileAccess.open(MUTATION_OUTPUT_PATH, FileAccess.WRITE)
	check(file != null, "mutation graph can be written in isolated user data")
	if file == null:
		return
	file.store_string(JSON.stringify(mutated, "\t") + "\n")
	file.close()
	var checker_output: Array = []
	var checker_path := ProjectSettings.globalize_path(CHECKER_PATH)
	var mutation_path := ProjectSettings.globalize_path(MUTATION_OUTPUT_PATH)
	var result := OS.execute(
		"python3", [checker_path, mutation_path, "--no-selftest"], checker_output, true
	)
	check(result != 0, "the canonical checker rejects a missing gate prop reference")
	DirAccess.remove_absolute(mutation_path)


func _same_keys(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for key: Variant in a:
		if not b.has(key):
			return false
	return true
