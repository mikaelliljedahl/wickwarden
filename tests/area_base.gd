extends TestCase
## Shared checks of the world rooms against the graph (world-plan 5.7, code-contract 16.10): the
## base of tests/test_world_graph.gd and of the area tests of later work packages. Not a test: the
## name has no test_ prefix, so the runner does not discover it. A test extends it with
## `extends "res://tests/area_base.gd"` and calls check_area(id) or room_problems(id, room).
##
## Every check runs on an instance of the room scene that is NOT in the tree (so no _ready), with
## geometry in room-local pixels on the 96 px tile grid (20 x 10). Missing scenes and props whose
## script does not exist yet are PENDING (collected in `pending`), never failures.

const TILE := 96.0
const COLS := 20
const ROWS := 10
const EXIT_DEPTH := 3
const SCRIPT_DIR := "res://scripts/world/"
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
				{"id": String(pickup["id"]), "node": node, "kind": String(pickup["kind"])}
			)
	var items: Dictionary = world_json["items"]
	for capability: String in items:
		var node := String(items[capability]["node"])
		if _on_room(node, room_id):
			records.append({"id": capability, "node": node, "kind": "tool"})
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
	var counts := {}
	for enemy in enemies.get_children():
		var position := (enemy as Node2D).position
		var key := String(enemy.scene_file_path.get_file().get_basename())
		counts[key] = int(counts.get(key, 0)) + 1
		if key == "hollow" and _off_tile_centre(position):
			problems.append("%s: hollow at %s is not on a tile centre" % [id, position])
	if counts != plan:
		problems.append("%s: enemies %s, the plan says %s" % [id, counts, plan])


func _off_tile_centre(p: Vector2) -> bool:
	var fx := fposmod(p.x - TILE * 0.5, TILE)
	var fy := fposmod(p.y - TILE * 0.5, TILE)
	return minf(fx, TILE - fx) > 0.5 or minf(fy, TILE - fy) > 0.5


## Obstacles, the tiles they cover and the tiles reached from the default spawn while every
## openable obstacle is closed. `walk` leaves out the openers that stand in a gated exit's gap or
## corridor (`gated_tiles`): such an opener is the gate of that exit, so it is not a wall of the walk.
func _geometry(room: Node, props: Node, bushes: Node, gated_tiles: Dictionary) -> Dictionary:
	var fixed: Array[Rect2] = []
	var openable: Array[Rect2] = []
	fixed.append_array(room.wall_rects())
	for node in props.get_children():
		if node is PickupBase or node is Area2D:
			continue
		if node is Brazier:
			fixed.append(Rect2((node as Node2D).position - Vector2(32, 32), Vector2(64, 64)))
		elif node is SolidBlock:
			var block := node as SolidBlock
			fixed.append(Rect2(block.position - block.size * 0.5, block.size))
		elif _is_wall_like(node):
			var size: Vector2 = node.get("size")
			openable.append(Rect2((node as Node2D).position - size * 0.5, size))
		elif node is StaticBody2D and node.get("size") is Vector2:
			var block_size: Vector2 = node.get("size")
			fixed.append(Rect2((node as Node2D).position - block_size * 0.5, block_size))
	for bush in bushes.get_children():
		fixed.append(Rect2((bush as Node2D).position - Vector2(34, 34), Vector2(68, 68)))
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


func _overlaps(tiles: Dictionary, other: Dictionary) -> bool:
	for tile in tiles:
		if other.has(tile):
			return true
	return false


func _is_wall_like(node: Node) -> bool:
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
		var tiles := exit_tiles(side)
		for tile in tiles:
			if walk.has(tile):
				problems.append("%s: exit %s corridor blocked at tile %s" % [id, side, tile])
		for tile in tiles:
			if not reach.has(tile):
				problems.append("%s: exit %s is not reachable from the spawn" % [id, side])
				break
	for enemy in enemies.get_children():
		if blocked.has(tile_of((enemy as Node2D).position)):
			problems.append("%s: %s starts on an obstacle" % [id, enemy.name])


func _check_pickups(id: String, room: Node, geometry: Dictionary, problems: Array[String]) -> void:
	var reach: Dictionary = geometry["reach"]
	var nodes := descendants_of_class(room, PickupBase)
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
		if reaches(reach, tile_of((node as Node2D).position), true):
			reachable += 1
		else:
			unreachable += 1
			if shop_items.has(node):
				problems.append("%s: shop stock %s is not reachable from the spawn" % [id, node.name])
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


## Every gated edge at this room must have its prop in a scene at either end.
func _check_gates(id: String, problems: Array[String]) -> void:
	for edge: Dictionary in gated_edges_of(id):
		match edge_status(edge):
			"missing":
				if String(edge["prop"]) == "mooring and water":
					pending["gate %s (mooring and water): compiler has no mooring line yet" % edge["id"]] = true
				else:
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
	for edge: Dictionary in plain_doors_of(id):
		var other := String(edge["b"]) if edge["a"] == id else String(edge["a"])
		partners.append(other)
		var door := _door_to(room, other)
		if door == null:
			problems.append("%s: no door to %s (edge %s)" % [id, other, edge["id"]])
		elif scene_exists(WorldData.scene_path(other)):
			var target := scene_root(WorldData.scene_path(other))
			if target.get_node_or_null("Spawns/%s" % door.target_spawn) == null:
				problems.append(
					"%s: door to %s needs marker %s there" % [id, other, door.target_spawn]
				)
		else:
			pending["door %s -> %s: target scene not built yet" % [id, other]] = true
	for door in descendants_of_class(room, RoomDoor):
		var target_room := String((door as RoomDoor).target_room)
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


func _door_to(room: Node, other: String) -> RoomDoor:
	for door in descendants_of_class(room, RoomDoor):
		if String((door as RoomDoor).target_room) == other:
			return door as RoomDoor
	return null


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
