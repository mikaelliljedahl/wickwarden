extends TestCase
# gdlint: disable=max-file-lines
## Shared checks of the world rooms against the graph (world-plan 5.7, code-contract 16.10): the
## base of tests/test_world_graph.gd and of the area tests of later work packages. Not a test: the
## name has no test_ prefix, so the runner does not discover it. A test extends it with
## `extends "res://tests/area_base.gd"` and calls check_area(id) or room_problems(id, room).
##
## Every check runs on an instance of the room scene that is NOT in the tree (so no _ready), with
## geometry in room-local pixels on the 96 px tile grid (20 x 10). Missing scenes and props whose
## script does not exist yet are PENDING (collected in `pending`), never failures.

## Explicit monster-spec room roles: runtime data intentionally omits these fields.
const CAVE_ACTORS := {
	"cave_1_5": "minibosses/hollow_captain",
	"cave_1_8": "bosses/kilnkeeper",
	"cave_2_4": "minibosses/thorn_warden",
	"cave_2_9": "bosses/briar_mother",
	"cave_3_4": "minibosses/sump_lurker",
	"cave_3_9": "bosses/tidewick",
	"cave_4_4": "minibosses/lull_mauler",
	"cave_4_10": "bosses/hushed_colossus",
	"cave_5_4": "minibosses/mirror_warden",
	"cave_5_10": "bosses/archivist",
	"cave_6_4": "minibosses/choir_warden",
	"cave_6_11": "bosses/dirge_choir",
	"cave_7_4": "minibosses/pale_squire",
	"cave_7_11": "bosses/gloam_knight",
	"cave_8_4": "minibosses/abacus_brute",
	"cave_8_12": "bosses/coinwyrm",
	"cave_9_4": "minibosses/wick_automaton",
	"cave_9_10": "bosses/lock_warden",
	"cave_10_4": "minibosses/corrows_echo",
	"cave_10_14": "bosses/the_unlit",
}

const TILE := 96.0
const COLS := 20
const ROWS := 10
const EXIT_DEPTH := 3
const SCRIPT_DIR := "res://scripts/world/"
const CUT_VARIANTS := {
	"bush cluster": &"reed_cluster",
	"dry vine screen": &"dry_vine_screen",
	"moss wall": &"moss_wall",
	"reed cluster": &"reed_cluster",
	"reed wall": &"rush_wall",
	"rush wall": &"rush_wall",
}
const WALL_SCRIPTS := [
	"locked_door.gd", "gate.gd", "cracked_wall.gd", "burnable.gd", "resonance_stone.gd"
]
const SIDE_STEP := {
	"n": Vector2i(0, -1), "e": Vector2i(1, 0), "s": Vector2i(0, 1), "w": Vector2i(-1, 0)
}
## Every gate prop name of world-plan 1.3 and 2.2 (the graph's `prop`) -> its script in scripts/world/.
## tests/test_world_graph.gd fails when a prop of the graph has no entry here.
const PROP_SCRIPTS := {
	"thorn hedge": "burnable.gd",
	"thorn wall": "burnable.gd",
	"thorn-sealed door": "burnable.gd",
	"wax seal": "wax_seal.gd",
	"hidden seam": "hidden_seam.gd",
	"hidden stairs": "hidden_seam.gd",
	"sealed seam": "hidden_seam.gd",
	"hook-tap wall": "hidden_seam.gd",
	"heavy boulder": "heavy_stone.gd",
	"heavy door": "heavy_stone.gd",
	"heavy stone": "heavy_stone.gd",
	"heavy stones": "heavy_stone.gd",
	"mooring and water": "mooring.gd",
	"flooded passage": "water_zone.gd",
	"pit": "pit_zone.gd",
	"ravine leap": "pit_zone.gd",
	"anchor ring": "anchor_ring.gd",
	"anchor ring pocket": "anchor_ring.gd",
	"eye switch": "eye_switch.gd",
	"eye-switch cell": "eye_switch.gd",
	"eye-switch portcullis": "eye_switch.gd",
	"resonance door": "resonance_stone.gd",
	"resonance stone": "resonance_stone.gd",
	"resonance vault": "resonance_stone.gd",
	"grated alcove": "grate.gd",
	"ward plate": "ward_plate.gd",
	"cliff drop": "ledge.gd",
	"cliff ledge drop": "ledge.gd",
	"boss door": "boss_door.gd",
	"sealed door (nine fragments)": "ninth_door.gd",
	"cracked wall": "cracked_wall.gd",
	"brittle rocks": "cracked_wall.gd",
	"bush cluster": "bush.gd",
	"dry vine screen": "bush.gd",
	"moss wall": "bush.gd",
	"reed cluster": "bush.gd",
	"reed wall": "bush.gd",
	"rush wall": "bush.gd",
	"key alcove gate": "gate.gd",
	"two braziers, gate": "gate.gd",
	"locked door": "locked_door.gd",
}

## Text of every pending item -> true. The graph test prints them once.
var pending: Dictionary = {}

var world_json: Dictionary = {}
var rooms_by_id: Dictionary = {}
var pockets_by_id: Dictionary = {}
var room_by_grid: Dictionary = {}
var scene_cache: Dictionary = {}
## The room instance that room_problems() is checking, and its scene path: gates read it, not the disk copy.
var subject_path := ""
var subject_room: Node = null

# ---- the graph -------------------------------------------------------------------------------


## Reads data/world_data.json once: the records WorldData does not expose (edges, pickups, items).
func index_world() -> void:
	if not world_json.is_empty():
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(WorldData.PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("area_base: %s is not a JSON object" % WorldData.PATH)
		return
	world_json = parsed
	for room: Dictionary in world_json["rooms"]:
		rooms_by_id[String(room["id"])] = room
		var cell: Array = room["grid"]
		room_by_grid[Vector2i(int(cell[0]), int(cell[1]))] = String(room["id"])
	for pocket: Dictionary in world_json["pockets"]:
		pockets_by_id[String(pocket["id"])] = pocket


func is_pocket(id: String) -> bool:
	return id.contains("#")


## The room a pocket belongs to; a room is its own host.
func host_of(id: String) -> String:
	index_world()
	if pockets_by_id.has(id):
		return String(pockets_by_id[id]["host"])
	return id


## True for a pocket that opens in place: its content lives in the host room's scene.
func is_in_place(id: String) -> bool:
	index_world()
	return pockets_by_id.has(id) and bool(pockets_by_id[id]["in_place"])


func is_sealed(node: String) -> bool:
	return is_in_place(node)


## The scene that holds the content of a room or pocket: its own, or the host's for an in-place pocket.
func content_scene(id: String) -> String:
	if is_in_place(id):
		return WorldData.scene_path(host_of(id))
	return WorldData.scene_path(id)


func scene_exists(path: String) -> bool:
	return path != "" and ResourceLoader.exists(path)


## Instance of a scene, not in the tree, cached until free_scenes(). Null when it does not exist.
func scene_root(path: String) -> Node:
	if not scene_cache.has(path):
		if not scene_exists(path):
			return null
		var packed := load(path) as PackedScene
		if packed == null:
			return null
		scene_cache[path] = packed.instantiate()
	return scene_cache[path]


func free_scenes() -> void:
	for node: Node in scene_cache.values():
		if is_instance_valid(node):
			node.free()
	scene_cache.clear()


## Pickups and tool items placed in a room: the records whose node is the room or one of its
## in-place pockets. Each is {id, node, kind}; `node` is the pocket id for a pocket record.
func placed_at(room_id: String) -> Array[Dictionary]:
	index_world()
	var records: Array[Dictionary] = []
	for pickup: Dictionary in world_json["pickups"]:
		var node := String(pickup["node"])
		if _on_room(node, room_id):
			records.append(
				{
					"id": String(pickup["id"]),
					"node": node,
					"kind": String(pickup["kind"]),
					"spec": pickup
				}
			)
	var items: Dictionary = world_json["items"]
	for capability: String in items:
		var node := String(items[capability]["node"])
		if _on_room(node, room_id):
			records.append(
				{"id": capability, "node": node, "kind": "tool", "spec": items[capability]}
			)
	return records


func _on_room(node: String, room_id: String) -> bool:
	return node == room_id or (is_in_place(node) and host_of(node) == room_id)


## Gated edges with `room_id` or one of its pockets at an end.
func gated_edges_of(room_id: String) -> Array[Dictionary]:
	index_world()
	var edges: Array[Dictionary] = []
	for edge: Dictionary in world_json["edges"]:
		if edge["gate"] == null:
			continue
		var ends := [host_of(String(edge["a"])), host_of(String(edge["b"]))]
		if ends.has(room_id):
			edges.append(edge)
	return edges


## Exit sides of `id` that a gated step edge leads through (the other end is a room, not a pocket).
func gated_sides_of(id: String) -> Array[String]:
	var sides: Array[String] = []
	for edge: Dictionary in gated_edges_of(id):
		var a := String(edge["a"])
		var b := String(edge["b"])
		if is_pocket(a) or is_pocket(b):
			continue
		var other := b if a == id else a
		var side := _side_towards(WorldData.grid(other) - WorldData.grid(id))
		if side != "" and not sides.has(side):
			sides.append(side)
	return sides


func _side_towards(step: Vector2i) -> String:
	for side: String in SIDE_STEP:
		if SIDE_STEP[side] == step:
			return side
	return ""


## Plain door edges (link door, no gate) that have `id` at one end.
func plain_doors_of(id: String) -> Array[Dictionary]:
	index_world()
	var edges: Array[Dictionary] = []
	for edge: Dictionary in world_json["edges"]:
		var plain := String(edge["link"]) == "door" and edge["gate"] == null
		if plain and (edge["a"] == id or edge["b"] == id):
			edges.append(edge)
	return edges


## "ok": a node of the prop's script is in a scene at one end of the edge (a key gate: a LockedDoor
## of the key's scope). "pending": a scene or the prop's script does not exist yet. "missing": all
## of them exist and the prop is not there. "unknown": the prop has no entry in PROP_SCRIPTS.
func edge_status(edge: Dictionary) -> String:
	var prop := String(edge["prop"])
	if not PROP_SCRIPTS.has(prop):
		return "unknown"
	var script := SCRIPT_DIR + String(PROP_SCRIPTS[prop])
	var unknown_scene := false
	for end in [String(edge["a"]), String(edge["b"])]:
		for path in _scene_candidates(end):
			if path == subject_path and subject_room != null:
				if _has_prop(subject_room, script, edge):
					return "ok"
			elif not scene_exists(path):
				unknown_scene = true
			elif _has_prop(scene_root(path), script, edge):
				return "ok"
	if unknown_scene or not ResourceLoader.exists(script):
		return "pending"
	return "missing"


## The scenes that may hold the prop of an end: its own scene and, for a pocket, its host's.
func _scene_candidates(id: String) -> Array[String]:
	var paths: Array[String] = []
	var own := WorldData.scene_path(id)
	if own != "":
		paths.append(own)
	if is_pocket(id):
		var host := WorldData.scene_path(host_of(id))
		if host != "" and not paths.has(host):
			paths.append(host)
	if paths.is_empty():
		paths.append("")
	return paths


func _has_prop(root: Node, script: String, edge: Dictionary) -> bool:
	if root == null:
		return false
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		var node_script: Script = node.get_script()
		if (
			node_script != null
			and node_script.resource_path == script
			and _key_scope_ok(node, edge)
		):
			return true
		stack.append_array(node.get_children())
	return false


func _key_scope_ok(node: Node, edge: Dictionary) -> bool:
	if edge["gate"] == "cut":
		if edge.get("needs", []) != ["hook"] or not CUT_VARIANTS.has(edge.get("prop", "")):
			return false
		var script: Script = node.get_script()
		var variant: Variant = node.get("variant")
		return (
			script != null
			and script.resource_path == SCRIPT_DIR + "bush.gd"
			and (variant is StringName or variant is String)
			and StringName(variant) == CUT_VARIANTS[edge["prop"]]
		)
	if edge["gate"] == "boss":
		var script: Script = node.get_script()
		if script != null and script.resource_path == SCRIPT_DIR + "ninth_door.gd":
			var fragments: Array[String] = []
			for number in range(1, 10):
				fragments.append("frag:c%d" % number)
			var needs: Array = edge.get("needs", []).duplicate()
			needs.sort()
			return edge.get("prop", "") == "sealed door (nine fragments)" and needs == fragments
		if not _is_boss_door(node) or edge.get("prop", "") != "boss door":
			return false
		var cave_value: Variant = node.get("cave")
		if not (cave_value is StringName or cave_value is String):
			return false
		var cave := String(cave_value)
		return (
			GameState.cave_number(StringName(cave)) > 0
			and edge.get("needs", []) == ["bigkey:" + cave]
			and WorldData.scope_of(host_of(String(edge["a"]))) == StringName(cave)
			and WorldData.scope_of(host_of(String(edge["b"]))) == StringName(cave)
		)
	if edge["gate"] != "key":
		return true
	var scope: Variant = node.get("scope")
	var door_scope := "ow" if scope == null else str(scope)
	return door_scope == str(edge["key"])


func descendants_of_class(root: Node, type: Variant) -> Array[Node]:
	var found: Array[Node] = []
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if is_instance_of(node, type):
			found.append(node)
		stack.append_array(node.get_children())
	return found


# ---- one room --------------------------------------------------------------------------------


## Standard checks of one room or pocket that has a scene: one failed check per problem.
func check_area(id: String) -> void:
	var path := WorldData.scene_path(id)
	check(scene_exists(path), "%s has a scene" % id)
	if not scene_exists(path):
		return
	for problem in room_problems(id, scene_root(path)):
		check(false, problem)


## Every problem of one room instance against its graph node, as text. Empty means the room agrees.
## `room` is an instance that is not in the tree (scene_root() or a modified copy of it).
func room_problems(id: String, room: Node) -> Array[String]:
	index_world()
	var problems: Array[String] = []
	if not room is Room:
		problems.append("%s: the scene root is not a Room" % id)
		return problems
	subject_path = WorldData.scene_path(id)
	subject_room = room
	if String(room.get("room_id")) != id:
		problems.append("%s: room_id is %s" % [id, room.get("room_id")])
	var scene_exits: Array[String] = []
	for side: StringName in room.get("exits"):
		scene_exits.append(String(side))
	if not is_pocket(id) and rooms_by_id.has(id):
		_check_grid_and_exits(id, room, scene_exits, problems)
	var props := room.get_node_or_null("Props")
	var bushes := room.get_node_or_null("Bushes")
	var enemies := room.get_node_or_null("Enemies")
	if props == null or bushes == null or enemies == null:
		problems.append("%s: Props, Bushes or Enemies container is missing" % id)
		return problems
	_check_enemies(id, enemies, problems)
	var geometry := _geometry(room, props, bushes, _gated_corridor_tiles(id))
	_check_layout(id, enemies, scene_exits, geometry, problems)
	_check_pickups(id, room, geometry, problems)
	_check_crossings(id, props, enemies, geometry, problems)
	_check_gates(id, problems)
	_check_doors(id, room, problems)
	subject_path = ""
	subject_room = null
	return problems


func _check_grid_and_exits(
	id: String, room: Node, scene_exits: Array[String], problems: Array[String]
) -> void:
	var grid_cell: Vector2i = room.get("grid")
	if grid_cell != WorldData.grid(id):
		problems.append("%s: grid is %s, the graph says %s" % [id, grid_cell, WorldData.grid(id)])
	if bool(room.get("dark")) != bool(rooms_by_id[id]["dark"]):
		problems.append("%s: dark flag differs from the graph" % id)
	var graph_exits: Array[String] = WorldData.exits(id)
	for side in scene_exits:
		if not graph_exits.has(side):
			problems.append("%s: scene has exit %s, the graph does not" % [id, side])
	for side in graph_exits:
		if scene_exits.has(side):
			continue
		# A side that leads to a room without a scene yet is pending, not a failure.
		var other: String = room_by_grid.get(WorldData.grid(id) + SIDE_STEP[side], "")
		if other == "" or not scene_exists(WorldData.scene_path(other)):
			pending["%s: exit %s waits for room %s" % [id, side, other]] = true
		else:
			problems.append(
				"%s: graph exit %s is missing in the scene (%s has its scene)" % [id, side, other]
			)


func _check_enemies(id: String, enemies: Node, problems: Array[String]) -> void:
	var plan := {}
	var record: Dictionary = rooms_by_id.get(id, {})
	var planned: Dictionary = record.get("enemies", {})
	for name: String in planned:
		var key := name.to_lower().replace(" ", "_").trim_prefix("new:")
		plan[key] = int(planned[name])
	if CAVE_ACTORS.has(id):
		plan["res://scenes/enemies/%s.tscn" % CAVE_ACTORS[id]] = 1
	var paths := {}
	for key: String in plan:
		var path := key if key.begins_with("res://") else "res://scenes/enemies/%s.tscn" % key
		paths[path] = plan[key]
	var counts := {}
	var stack: Array[Node] = [enemies.get_parent()]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if not node is EnemyBase:
			stack.append_array(node.get_children())
			continue
		# Boss parts belong to their actor, rather than the room's regular enemy count.
		var path := String(node.scene_file_path)
		counts[path] = int(counts.get(path, 0)) + 1
		if path == "res://scenes/enemies/hollow.tscn" and _off_tile_centre(node.position):
			problems.append("%s: hollow at %s is not on a tile centre" % [id, node.position])
	if counts != paths:
		problems.append("%s: enemies %s, the plan says %s" % [id, counts, paths])


func _off_tile_centre(p: Vector2) -> bool:
	var fx := fposmod(p.x - TILE * 0.5, TILE)
	var fy := fposmod(p.y - TILE * 0.5, TILE)
	return minf(fx, TILE - fx) > 0.5 or minf(fy, TILE - fy) > 0.5


## Obstacles, the tiles they cover and the tiles reached from the default spawn while every
## openable obstacle is closed. `walk` leaves out the openers that stand in a gated exit's gap or
## corridor (`gated_tiles`): such an opener is the gate of that exit, so it is not a wall of the walk.
func _geometry(room: Node, props: Node, bushes: Node, gated_tiles: Dictionary) -> Dictionary:
	var fixed: Array[Rect2] = []
	var moth_solids: Array[Rect2] = []
	var openable: Array[Rect2] = []
	var water: Array[Rect2] = []
	fixed.append_array(room.wall_rects())
	moth_solids.append_array(room.wall_rects())
	for node in props.get_children():
		if _script_file(node) == "ward_plate.gd" and not node.get("blocker"):
			continue
		if _script_file(node) == "pit_zone.gd":
			var pit_size: Vector2 = node.get("size")
			openable.append(Rect2((node as Node2D).position - pit_size * 0.5, pit_size))
			continue
		if node is Area2D and _script_file(node) == "water_zone.gd" and node.get("deep"):
			var zone_size: Vector2 = node.get("size")
			var rect := Rect2((node as Node2D).position - zone_size * 0.5, zone_size)
			fixed.append(rect)
			moth_solids.append(rect)
			water.append(rect)
			continue
		if _script_file(node) == "mooring.gd":
			fixed.append(Rect2((node as Node2D).position - Vector2(16, 16), Vector2(32, 32)))
			moth_solids.append(Rect2((node as Node2D).position - Vector2(16, 16), Vector2(32, 32)))
			continue
		if node is PickupBase or node is Area2D:
			continue
		if node is Brazier:
			fixed.append(Rect2((node as Node2D).position - Vector2(32, 32), Vector2(64, 64)))
			moth_solids.append(Rect2((node as Node2D).position - Vector2(32, 32), Vector2(64, 64)))
		elif node is SolidBlock:
			var block := node as SolidBlock
			fixed.append(Rect2(block.position - block.size * 0.5, block.size))
			moth_solids.append(Rect2(block.position - block.size * 0.5, block.size))
		elif _is_wall_like(node):
			var size: Vector2 = node.get("size")
			var footprint := Rect2(-size * 0.5, size)
			if _is_boss_door(node) and not _boss_door_matches_room(room, node):
				fixed.append((node as Node2D).transform * footprint)
				moth_solids.append((node as Node2D).transform * footprint)
			else:
				openable.append((node as Node2D).transform * footprint)
				moth_solids.append((node as Node2D).transform * footprint)
		elif node is StaticBody2D and node.get("size") is Vector2:
			var block_size: Vector2 = node.get("size")
			fixed.append(Rect2((node as Node2D).position - block_size * 0.5, block_size))
			if _script_file(node) != "grate.gd":
				moth_solids.append(Rect2((node as Node2D).position - block_size * 0.5, block_size))
	for bush in bushes.get_children():
		var bush_rect := Rect2((bush as Node2D).position - Vector2(34, 34), Vector2(68, 68))
		if _is_graph_cut_bush(room, bush) and _overlaps(rect_tiles(bush_rect), gated_tiles):
			openable.append(bush_rect)
			moth_solids.append(bush_rect)
		else:
			fixed.append(bush_rect)
			moth_solids.append(bush_rect)
	var closed: Array[Rect2] = fixed.duplicate()
	closed.append_array(openable)
	var walls: Array[Rect2] = fixed.duplicate()
	for rect in openable:
		if not _overlaps(rect_tiles(rect), gated_tiles):
			walls.append(rect)
	var blocked := blocked_tiles(closed)
	var walk := blocked_tiles(walls)
	var spawn_tile := tile_of(_spawn_position(room))
	return {
		"water": blocked_tiles(water),
		# Flight ignores pits and grates, retaining WORLD even where footprints overlap.
		"moth_blocked": blocked_tiles(moth_solids),
		"blocked": blocked,
		"walk": walk,
		"reach": flood([spawn_tile], walk),
		"spawn_tile": spawn_tile,
	}


## Tiles of the exit corridors (exit_tiles) of the sides that a gated step edge leads through.
func _gated_corridor_tiles(id: String) -> Dictionary:
	var tiles := {}
	for side in gated_sides_of(id):
		for tile in exit_tiles(side):
			tiles[tile] = true
	return tiles


## Only an exact Bush variant named by a cut edge can be removed from the future-open walk.
func _is_graph_cut_bush(room: Node, bush: Node) -> bool:
	for edge: Dictionary in gated_edges_of(String(room.get("room_id"))):
		if edge["gate"] == "cut" and _key_scope_ok(bush, edge):
			return true
	return false


func _overlaps(tiles: Dictionary, other: Dictionary) -> bool:
	for tile in tiles:
		if other.has(tile):
			return true
	return false


## Match the exact delivered script: an arbitrary static body is never a future-open door.
func _is_boss_door(node: Node) -> bool:
	var script: Script = node.get_script()
	return script != null and script.resource_path == SCRIPT_DIR + "boss_door.gd"


func _boss_door_matches_room(room: Node, node: Node) -> bool:
	for edge: Dictionary in gated_edges_of(String(room.get("room_id"))):
		if edge["gate"] == "boss" and _key_scope_ok(node, edge):
			return true
	return false


func _is_wall_like(node: Node) -> bool:
	if _is_boss_door(node):
		return node.get("size") is Vector2
	if _script_file(node) in ["eye_switch.gd", "ward_plate.gd"]:
		return node.get("blocker") == true
	if _script_file(node) == "heavy_stone.gd":
		return true
	if node is LockedDoor or node is Gate:
		return true
	var script: Script = node.get_script()
	if script == null or not (node.get("size") is Vector2):
		return false
	for file in WALL_SCRIPTS:
		if script.resource_path.ends_with(file):
			return true
	return false


func _check_layout(
	id: String,
	enemies: Node,
	scene_exits: Array[String],
	geometry: Dictionary,
	problems: Array[String]
) -> void:
	var blocked: Dictionary = geometry["blocked"]
	var walk: Dictionary = geometry["walk"]
	var reach: Dictionary = geometry["reach"]
	if blocked.has(geometry["spawn_tile"]):
		problems.append("%s: the default spawn is inside an obstacle" % id)
	for side in scene_exits:
		if _has_raft_mooring(id, side):
			continue
		var side_reach := reach
		for edge: Dictionary in gated_edges_of(id):
			var other := String(edge["b"] if edge["a"] == id else edge["a"])
			if (
				edge["link"] == "step"
				and edge.get("needs", []) == ["reel_line"]
				and WorldData.grid(other) - WorldData.grid(id) == SIDE_STEP[side]
			):
				side_reach = _reel_reach(subject_room, geometry)
		var tiles := exit_tiles(side)
		for tile in tiles:
			if walk.has(tile):
				problems.append("%s: exit %s corridor blocked at tile %s" % [id, side, tile])
		for tile in tiles:
			if not side_reach.has(tile):
				problems.append("%s: exit %s is not reachable from the spawn" % [id, side])
				break
	for enemy in enemies.get_children():
		var tile := tile_of((enemy as Node2D).position)
		if _script_file(enemy) == "fen_leech.gd" and geometry["water"].has(tile):
			continue
		if blocked.has(tile):
			problems.append("%s: %s starts on an obstacle" % [id, enemy.name])


## Add only safe cardinal reel landings; pits remain blocked in every ordinary flood.
func _reel_reach(room: Node, geometry: Dictionary) -> Dictionary:
	var reached: Dictionary = geometry["reach"].duplicate()
	var solids: Dictionary = geometry["moth_blocked"].duplicate()
	var pits: Array[Rect2] = []
	var rings: Array[Node2D] = []
	for prop in room.get_node("Props").get_children():
		if _script_file(prop) == "anchor_ring.gd":
			rings.append(prop as Node2D)
		elif _script_file(prop) in ["pit_zone.gd", "grate.gd"]:
			var size: Vector2 = prop.get("size")
			var rect := Rect2((prop as Node2D).position - size * 0.5, size)
			if _script_file(prop) == "pit_zone.gd":
				pits.append(rect.grow(Player.BODY_RADIUS))
			else:
				solids.merge(rect_tiles(rect))
	while true:
		var landings: Array[Vector2i] = []
		for tile: Vector2i in reached:
			var start := Vector2(tile) * TILE + Vector2.ONE * TILE * 0.5
			for ring in rings:
				var delta := ring.position - start
				var distance := delta.length()
				var limit: float = ring.get("max_range")
				if (delta.x != 0 and delta.y != 0) or distance <= 72 or distance > 576:
					continue
				if limit > 0 and distance > limit:
					continue
				var landing := ring.position - delta.normalized() * 72
				if (
					not Rect2(Vector2.ZERO, Vector2(COLS, ROWS) * TILE).has_point(landing)
					or geometry["blocked"].has(tile_of(landing))
				):
					continue
				var safe := true
				for pit in pits:
					if pit.has_point(landing):
						safe = false
				for step in range(int(ceil(distance)) + 1):
					if solids.has(tile_of(start + delta.normalized() * minf(step, distance))):
						safe = false
				if safe:
					landings.append(tile_of(landing))
		var expanded := reached.duplicate()
		expanded.merge(flood(landings, geometry["walk"]))
		if expanded.size() == reached.size():
			return reached
		reached = expanded
	return reached


func _script_file(node: Node) -> String:
	var script: Script = node.get_script()
	return script.resource_path.get_file() if script != null else ""


func _has_raft_mooring(id: String, side: String) -> bool:
	if subject_room == null:
		return false
	var other: String = room_by_grid.get(WorldData.grid(id) + SIDE_STEP[side], "")
	for node in subject_room.get_node("Props").get_children():
		if _script_file(node) == "mooring.gd" and String(node.get("target_room")) == other:
			return true
	return false


func _check_crossings(
	id: String, props: Node, enemies: Node, geometry: Dictionary, problems: Array[String]
) -> void:
	var zones: Array[Rect2] = []
	for node in props.get_children():
		if _script_file(node) in ["water_zone.gd", "shallow_zone.gd"]:
			var size: Vector2 = node.get("size")
			zones.append(Rect2((node as Node2D).position - size * 0.5, size))
	for side: String in WorldData.exits(id):
		if not _has_raft_mooring(id, side):
			continue
		for tile in exit_tiles(side):
			if (tile.x in [0, COLS - 1] or tile.y in [0, ROWS - 1]) and geometry["reach"].has(tile):
				problems.append("%s: raft exit %s is walkable on foot" % [id, side])
	if zones.is_empty():
		return
	for enemy in enemies.get_children():
		if _script_file(enemy) != "fen_leech.gd":
			continue
		var contained := false
		for zone in zones:
			if zone.has_point((enemy as Node2D).position):
				contained = true
		if not contained:
			problems.append("%s: fen leech %s is outside water or shallows" % [id, enemy.name])


func _is_entry_refill(room: Node, node: Node) -> bool:
	if not node is PickupBase:
		return false
	var pickup := node as PickupBase
	return (
		String(room.get("room_id")) == "cave_9_4"
		and pickup.get_parent() == room.get_node("Props")
		and pickup.respawn_on_enter
		and pickup.persistent_id == &""
		and pickup.kind == &"pitch_pot_bundle"
		and pickup.timeout == 0
	)


func _check_pickups(id: String, room: Node, geometry: Dictionary, problems: Array[String]) -> void:
	var reach: Dictionary = geometry["reach"]
	var nodes: Array[Node] = []
	var refills := 0
	for pickup in descendants_of_class(room, PickupBase):
		if _is_entry_refill(room, pickup):
			refills += 1
			continue
		if (pickup as PickupBase).respawn_on_enter:
			problems.append("%s: invalid respawning refill %s" % [id, pickup.name])
		nodes.append(pickup)
	if id == "cave_9_4" and refills != 2:
		problems.append("%s: requires exactly two explicit entry refills" % id)
	var shop_items: Array[Node] = []
	for node in descendants_of_class(room, Area2D):
		var script: Script = node.get_script()
		if script != null and script.resource_path.ends_with("/shop_item.gd"):
			shop_items.append(node)
	nodes.append_array(shop_items)
	var reachable := 0
	var unreachable := 0
	for node in nodes:
		if node is PickupBase and String((node as PickupBase).persistent_id) == "":
			problems.append("%s: pickup %s has no persistent_id" % [id, node.name])
		if _is_moth_pocket(id) or _needs_moth(id, node):
			if _moth_pickup_valid(room, node as Node2D, geometry, problems):
				reachable += 1
			continue
		if reaches(reach, tile_of((node as Node2D).position), true):
			reachable += 1
		else:
			unreachable += 1
			if shop_items.has(node):
				problems.append(
					"%s: shop stock %s is not reachable from the spawn" % [id, node.name]
				)
	_check_pickup_specs(id, nodes, problems)
	var sealed := 0
	var open := 0
	for record in placed_at(id):
		if is_sealed(String(record["node"])):
			sealed += 1
		else:
			open += 1
	if nodes.size() < sealed + open:
		problems.append(
			"%s: %d pickups placed, the graph places %d" % [id, nodes.size(), sealed + open]
		)
	if unreachable < sealed:
		problems.append(
			"%s: a sealed spot holds no unreachable pickup (%d of %d)" % [id, unreachable, sealed]
		)
	if reachable < open:
		problems.append(
			(
				"%s: %d pickup(s) of the graph are not reachable from the spawn"
				% [id, open - reachable]
			)
		)


func _needs_moth(id: String, node: Node) -> bool:
	if not node is PickupBase:
		return false
	for record in placed_at(id):
		if String(node.get("persistent_id")) == record["id"]:
			return "tether_moth" in record["spec"].get("needs", [])
	return false


func _check_pickup_specs(id: String, nodes: Array[Node], problems: Array[String]) -> void:
	for record in placed_at(id):
		var pid := String(record["id"])
		var kind := String(record["kind"])
		var scope := String(record["spec"].get("scope", ""))
		if pid.begins_with("bigkey:") or pid.begins_with("frag:"):
			scope = pid.get_slice(":", 1)
			kind = "big_key" if pid.begins_with("bigkey:") else "fragment"
			pid = ("bigkey_" if kind == "big_key" else "frag_") + scope
		elif kind == "small_key":
			kind = "key"
		# Historical in-place dev key keeps its original identity and overworld scope.
		if pid == "key_ow_1":
			pid = "cave_key"
		if pid == "wick_core_ow_2_0":
			pid = "wick_core_cache"
		if kind not in ["key", "big_key", "fragment", "wick_core"]:
			continue
		var matches: Array[Node] = []
		for node in nodes:
			if node is PickupBase and String(node.persistent_id) == pid:
				matches.append(node)
		if matches.size() != 1:
			problems.append("%s: pickup %s requires exactly one matching persistent_id" % [id, pid])
			continue
		var pickup := matches[0] as PickupBase
		if String(pickup.kind) != kind or (scope != "" and String(pickup.scope) != scope):
			problems.append("%s: pickup %s has wrong kind or scope" % [id, pid])
		if record["spec"].get("after_boss", false):
			var flag := "boss_%s_defeated" % host_of(String(record["node"]))
			if String(pickup.requires_flag) != flag:
				problems.append("%s: pickup %s requires exact flag %s" % [id, pid, flag])


func _is_moth_pocket(id: String) -> bool:
	if not is_pocket(id):
		return false
	for edge: Dictionary in world_json["edges"]:
		if edge["prop"] == "grated alcove" and (edge["a"] == id or edge["b"] == id):
			return true
	return false


func _moth_pickup_valid(
	room: Node, pickup: Node2D, geometry: Dictionary, problems: Array[String]
) -> bool:
	var grates := {}
	for prop in room.get_node("Props").get_children():
		if _script_file(prop) == "grate.gd":
			var size: Vector2 = prop.get("size")
			grates.merge(rect_tiles(Rect2((prop as Node2D).position - size * 0.5, size)))
	var blocked: Dictionary = geometry["moth_blocked"]
	var starts: Array[Vector2i] = [geometry["spawn_tile"]]
	for marker in room.get_node("Spawns").get_children():
		starts.append(tile_of((marker as Node2D).position))
	for start in starts:
		var walk := flood([start], geometry["blocked"])
		if reaches(walk, tile_of(pickup.position), true):
			problems.append("moth pickup %s is walkable" % pickup.name)
			return false
		var found := false
		for tile: Vector2i in walk:
			var launch := Vector2(tile) * TILE + Vector2.ONE * TILE * 0.5
			var delta := pickup.position - launch
			if (delta.x != 0 and delta.y != 0) or delta.length() > 420.0:
				continue
			var clear := true
			var crossed := false
			for step in range(int(delta.length()) + 1):
				var at := tile_of(launch + delta.normalized() * step)
				if blocked.has(at):
					clear = false
				if grates.has(at):
					crossed = true
			if clear and crossed:
				found = true
				break
		if not found:
			problems.append(
				"moth pickup %s has no clear launch within 420 px across grate" % pickup.name
			)
			return false
	return true


## Every gated edge at this room must have its prop in a scene at either end.
func _check_gates(id: String, problems: Array[String]) -> void:
	for edge: Dictionary in gated_edges_of(id):
		match edge_status(edge):
			"missing":
				var text := "%s: gate %s (%s, %s-%s) has no %s"
				problems.append(
					text % [id, edge["id"], edge["gate"], edge["a"], edge["b"], edge["prop"]]
				)
			"unknown":
				problems.append("%s: prop %s has no entry in PROP_SCRIPTS" % [id, edge["prop"]])
			"pending":
				pending["gate %s (%s): prop or scene not built yet" % [edge["id"], edge["prop"]]] = true


## Each room door must lead where the graph says (every plain door of the graph is there, and no door
## goes elsewhere). A door's target spawn marker must exist in the target scene.
func _check_doors(id: String, room: Node, problems: Array[String]) -> void:
	var partners: Array[String] = []
	index_world()
	for edge: Dictionary in world_json["edges"]:
		if String(edge["link"]) != "door" or (edge["a"] != id and edge["b"] != id):
			continue
		var other := String(edge["b"]) if edge["a"] == id else String(edge["a"])
		if is_in_place(other):
			continue
		partners.append(other)
		var door := _door_to(room, other)
		if door.is_empty():
			problems.append("%s: no door to %s (edge %s)" % [id, other, edge["id"]])
		elif scene_exists(WorldData.scene_path(other)):
			var target := scene_root(WorldData.scene_path(other))
			if target.get_node_or_null("Spawns/%s" % door["spawn"]) == null:
				problems.append("%s: door to %s needs marker %s there" % [id, other, door["spawn"]])
		else:
			pending["door %s -> %s: target scene not built yet" % [id, other]] = true
	for door: Dictionary in _door_entries(room):
		var target_room := String(door["target"])
		var own_pocket_target := (
			target_room.begins_with(id + "#")
			and pockets_by_id.has(target_room)
			and host_of(target_room) == id
		)
		var pocket_host_target := pockets_by_id.has(id) and host_of(id) == target_room
		if not partners.has(target_room) and not own_pocket_target and not pocket_host_target:
			problems.append(
				"%s: door targets %s, which the graph does not link here" % [id, target_room]
			)


## Scene checks run before _ready, so concealed seams declare their eventual door explicitly.
func _door_entries(room: Node) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for door in descendants_of_class(room, RoomDoor):
		entries.append({"target": String(door.target_room), "spawn": String(door.target_spawn)})
	for seam in descendants_of_class(room, Area2D):
		if _script_file(seam) != "hidden_seam.gd":
			continue
		var target := String(seam.get("door_target"))
		if target != "":
			entries.append({"target": target, "spawn": String(seam.get("door_spawn"))})
	return entries


func _door_to(room: Node, other: String) -> Dictionary:
	for door: Dictionary in _door_entries(room):
		if door["target"] == other:
			return door
	return {}


# ---- geometry helpers ------------------------------------------------------------------------


func _spawn_position(room: Node) -> Vector2:
	var marker := room.get_node_or_null("Spawns/Default") as Node2D
	if marker != null:
		return marker.position
	return WorldConst.ROOM_SIZE * 0.5


func tile_of(p: Vector2) -> Vector2i:
	return Vector2i(clampi(int(p.x / TILE), 0, COLS - 1), clampi(int(p.y / TILE), 0, ROWS - 1))


func blocked_tiles(rects: Array[Rect2]) -> Dictionary:
	var blocked := {}
	for r in rects:
		blocked.merge(rect_tiles(r))
	return blocked


func rect_tiles(r: Rect2) -> Dictionary:
	var tiles := {}
	for c in range(COLS):
		for row in range(ROWS):
			if Rect2(c * TILE, row * TILE, TILE, TILE).grow(-4.0).intersects(r):
				tiles[Vector2i(c, row)] = true
	return tiles


func flood(start: Array[Vector2i], blocked: Dictionary) -> Dictionary:
	var seen := {}
	var queue: Array[Vector2i] = []
	for s in start:
		if not blocked.has(s):
			seen[s] = true
			queue.append(s)
	while not queue.is_empty():
		var t: Vector2i = queue.pop_back()
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = t + d
			if n.x < 0 or n.y < 0 or n.x >= COLS or n.y >= ROWS:
				continue
			if seen.has(n) or blocked.has(n):
				continue
			seen[n] = true
			queue.append(n)
	return seen


## A tile is reached when it is in `seen`, or (with allow_neighbour) next to one: a pickup circle
## reaches what its tile touches.
func reaches(seen: Dictionary, tile: Vector2i, allow_neighbour: bool) -> bool:
	if seen.has(tile):
		return true
	if allow_neighbour:
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			if seen.has(tile + d):
				return true
	return false


## The tiles of one exit side, EXIT_DEPTH deep, the ring tile included, two tiles wide.
func exit_tiles(side: String) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	for k in range(0, EXIT_DEPTH + 1):
		match side:
			"n":
				tiles.append_array([Vector2i(9, k), Vector2i(10, k)])
			"s":
				tiles.append_array([Vector2i(9, ROWS - 1 - k), Vector2i(10, ROWS - 1 - k)])
			"w":
				tiles.append_array([Vector2i(k, 4), Vector2i(k, 5)])
			_:
				tiles.append_array([Vector2i(COLS - 1 - k, 4), Vector2i(COLS - 1 - k, 5)])
	return tiles
