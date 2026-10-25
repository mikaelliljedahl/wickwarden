extends "res://tests/area_base.gd"
## The world graph against the real scenes (world-plan 5.7, code-contract 16.10). For every room and
## pocket of data/world_data.json whose scene exists, the scene agrees with its node (see area_base.gd).
## Also: every prop of the graph is in the table, every step link is mirrored except one-way ones,
## every plain door leads where the graph says, persistent ids are unique. Missing scenes and props
## of later work packages are PENDING: listed once, never failures. Two broken rooms built in memory
## must be rejected (a blocked exit, a missing exit).


func run() -> void:
	index_world()
	_gates_have_props()
	_scenes_agree_with_graph()
	_step_links_mirrored()
	_doors_have_their_scenes()
	_persistent_ids_unique()
	_broken_rooms_are_rejected()
	_gates_may_stand_in_gated_exits()
	_ninth_door_gate_regressions()
	_cut_screen_gate_regressions()
	_boss_door_geometry_regressions()
	_cave_validation_regressions()
	_reel_and_refill_regressions()
	_print_pending()
	free_scenes()


## Every gated edge of the graph has its prop in the table; a gate whose scenes or prop script do not
## exist yet is pending (gates at built rooms are checked by check_area).
func _gates_have_props() -> void:
	for edge: Dictionary in world_json["edges"]:
		if edge["gate"] == null:
			continue
		var prop := String(edge["prop"])
		check(
			PROP_SCRIPTS.has(prop),
			"edge %s: prop '%s' has a script in the F3 table" % [edge["id"], prop]
		)
		if PROP_SCRIPTS.has(prop) and edge_status(edge) == "pending":
			pending["gate %s (%s): prop or scene not built yet" % [edge["id"], prop]] = true


## Every room and pocket with a scene: check_area. Pending for those without a scene.
func _scenes_agree_with_graph() -> void:
	var ids: Array[String] = []
	ids.append_array(WorldData.room_ids())
	ids.append_array(WorldData.all_pockets())
	var checked := 0
	for id in ids:
		if scene_exists(WorldData.scene_path(id)):
			check_area(id)
			checked += 1
		elif not is_in_place(id):
			pending["scene %s" % id] = true
	check(checked >= 7, "at least the 7 dev rooms have a scene (%d found)" % checked)


## Both ends of a step link agree on the exit facing each other. A one-way link needs only its upper end.
func _step_links_mirrored() -> void:
	for edge: Dictionary in world_json["edges"]:
		if String(edge["link"]) != "step":
			continue
		var a := String(edge["a"])
		var b := String(edge["b"])
		var side_a := _side_of(WorldData.grid(b) - WorldData.grid(a))
		check(side_a != "", "step %s: %s and %s are grid neighbours" % [edge["id"], a, b])
		if side_a == "":
			continue
		check(WorldData.exits(a).has(side_a), "step %s: %s has exit %s" % [edge["id"], a, side_a])
		if String(edge["dir"]) == "both":
			var side_b := _side_of(WorldData.grid(a) - WorldData.grid(b))
			check(
				WorldData.exits(b).has(side_b),
				"step %s: %s has exit %s back" % [edge["id"], b, side_b]
			)


func _side_of(step: Vector2i) -> String:
	for side in SIDE_STEP:
		if SIDE_STEP[side] == step:
			return side
	return ""


## A plain door whose ends are not built yet is pending (the scene check covers the built ones).
func _doors_have_their_scenes() -> void:
	for edge: Dictionary in world_json["edges"]:
		if String(edge["link"]) != "door" or edge["gate"] != null:
			continue
		for end in [String(edge["a"]), String(edge["b"])]:
			if not scene_exists(content_scene(end)):
				pending["door %s at %s: scene not built yet" % [edge["id"], end]] = true


func _persistent_ids_unique() -> void:
	var seen := {}
	var ids: Array[String] = []
	ids.append_array(WorldData.room_ids())
	ids.append_array(WorldData.all_pockets())
	for id in ids:
		var root := scene_root(WorldData.scene_path(id))
		if root == null:
			continue
		for problem in _record_persistent_ids(id, root, seen):
			check(false, problem)
	check(seen.size() > 0, "the built scenes have persistent pickups")


func _record_persistent_ids(id: String, root: Node, seen: Dictionary) -> Array[String]:
	var problems: Array[String] = []
	for node in descendants_of_class(root, PickupBase):
		if _is_entry_refill(root, node):
			continue
		var pickup := node as PickupBase
		var pid := String(pickup.persistent_id)
		if pickup.respawn_on_enter:
			problems.append("%s: invalid respawning refill %s" % [id, node.name])
		if pid == "":
			problems.append("%s: pickup %s has no persistent_id" % [id, node.name])
		elif seen.has(pid):
			problems.append("persistent_id %s is used by %s and %s" % [pid, seen[pid], id])
		else:
			seen[pid] = id
	return problems


## Negative cases, built in memory from a real room: a blocked exit corridor and a missing exit.
func _broken_rooms_are_rejected() -> void:
	var blocked := _instance("ow_0_0")
	var block := SolidBlock.new()
	block.size = Vector2(96, 192)
	block.position = Vector2(1680, 480)
	(blocked.get_node("Props") as Node).add_child(block)
	var problems := room_problems("ow_0_0", blocked)
	check(
		_mentions(problems, "exit e corridor blocked"),
		"a room whose east exit is walled off is rejected"
	)
	blocked.free()
	var short := _instance("ow_0_0")
	var exits: Array[StringName] = [&"e"]
	short.exits = exits
	check(
		_mentions(room_problems("ow_0_0", short), "graph exit s is missing"),
		"a room without its south exit is rejected"
	)
	short.free()
	var wrong := _instance("ow_0_0")
	wrong.room_id = &"ow_9_9"
	check(
		_mentions(room_problems("ow_0_0", wrong), "room_id is ow_9_9"),
		"a room with another id is rejected"
	)
	wrong.free()
	var no_door := _instance("ow_2_1")
	for door in descendants_of_class(no_door, LockedDoor):
		door.get_parent().remove_child(door)
		door.free()
	check(
		_mentions(room_problems("ow_2_1", no_door), "gate e124"),
		"a room whose locked door is gone is rejected"
	)
	no_door.free()
	var no_moth := _instance("ow_0_1")
	for pickup in descendants_of_class(no_moth, PickupBase):
		pickup.get_parent().remove_child(pickup)
		pickup.free()
	check(
		_mentions(room_problems("ow_0_1", no_moth), "pickups placed"),
		"a room whose pickup is gone is rejected"
	)
	no_moth.free()


## A gated exit may hold its gate in the gap or the corridor (world-plan 1.1): ow_2_0 east is gated
## (edge e005), its scene has no east exit yet, so the instance gets one. A gate there passes, a plain
## solid block there still fails. A gate in the gap of an open exit (ow_0_0 east, edge e001) still fails.
func _gates_may_stand_in_gated_exits() -> void:
	var gated := _instance("ow_2_0")
	var gated_exits: Array[StringName] = [&"w", &"s", &"e"]
	gated.exits = gated_exits
	var gate := Gate.new()
	gate.size = Vector2(96, 192)
	gate.position = Vector2(1776, 480)
	(gated.get_node("Props") as Node).add_child(gate)
	check(
		room_problems("ow_2_0", gated).is_empty(),
		"a gate in the gap of a gated exit (ow_2_0 east) passes"
	)
	gated.free()
	var walled := _instance("ow_2_0")
	walled.exits = gated_exits
	var block := SolidBlock.new()
	block.size = Vector2(96, 192)
	block.position = Vector2(1776, 480)
	(walled.get_node("Props") as Node).add_child(block)
	check(
		_mentions(room_problems("ow_2_0", walled), "exit e corridor blocked"),
		"a solid block in the gap of a gated exit is rejected"
	)
	walled.free()
	var open := _instance("ow_0_0")
	var open_gate := Gate.new()
	open_gate.size = Vector2(96, 192)
	open_gate.position = Vector2(1776, 480)
	(open.get_node("Props") as Node).add_child(open_gate)
	check(
		_mentions(room_problems("ow_0_0", open), "exit e corridor blocked"),
		"a gate in the gap of an open exit is rejected"
	)
	open.free()


func _instance(id: String) -> Node:
	var packed := load(WorldData.scene_path(id)) as PackedScene
	return packed.instantiate() if packed != null else null


func _mentions(problems: Array[String], text: String) -> bool:
	for problem in problems:
		if problem.contains(text):
			return true
	return false


func _print_pending() -> void:
	var keys := pending.keys()
	keys.sort()
	print("PENDING (not failures) %d, the scene and prop of later work packages:" % keys.size())
	for key in keys:
		print("  - ", key)


## In-memory fixtures exercise future cave checks without claiming those rooms are built.
func _cave_validation_regressions() -> void:
	var room := Node2D.new()
	var enemies := Node2D.new()
	room.add_child(enemies)
	var arena := Node2D.new()
	room.add_child(arena)
	var missing: Array[String] = []
	_check_enemies("cave_1_8", enemies, missing)
	check(not missing.is_empty(), "built boss room without its actor is rejected")
	var actor := EnemyBase.new()
	actor.scene_file_path = "res://scenes/enemies/bosses/kilnkeeper.tscn"
	arena.add_child(actor)
	var problems: Array[String] = []
	_check_enemies("cave_1_8", enemies, problems)
	check(problems.is_empty(), "nested exact boss scene satisfies cave role")
	actor.scene_file_path = "res://scenes/enemies/kilnkeeper.tscn"
	_check_enemies("cave_1_8", enemies, problems)
	check(not problems.is_empty(), "flat special-role path is rejected")
	actor.scene_file_path = "res://scenes/enemies/minibosses/hollow_captain.tscn"
	problems.clear()
	_check_enemies("cave_1_5", enemies, problems)
	check(problems.is_empty(), "miniboss resolves separately from regular enemies")
	var duplicate := EnemyBase.new()
	duplicate.scene_file_path = actor.scene_file_path
	arena.add_child(duplicate)
	_check_enemies("cave_1_5", enemies, problems)
	check(not problems.is_empty(), "duplicate miniboss is rejected")
	room.free()
	var fragment := PickupBase.new()
	fragment.kind = &"fragment"
	fragment.scope = &"c1"
	fragment.persistent_id = &"frag_c1"
	fragment.requires_flag = &"boss_cave_1_8_defeated"
	var core := PickupBase.new()
	core.kind = &"wick_core"
	core.persistent_id = &"wick_core_c1"
	core.requires_flag = fragment.requires_flag
	var rewards: Array[Node] = [fragment, core]
	problems.clear()
	_check_pickup_specs("cave_1_8", rewards, problems)
	check(problems.is_empty(), "exact boss rewards pass")
	fragment.requires_flag = &"boss_cave_2_9_defeated"
	_check_pickup_specs("cave_1_8", rewards, problems)
	check(_mentions(problems, "requires exact flag"), "another boss reward flag is rejected")
	fragment.requires_flag = core.requires_flag
	fragment.scope = &"c2"
	problems.clear()
	_check_pickup_specs("cave_1_8", rewards, problems)
	check(_mentions(problems, "wrong kind or scope"), "fragment in wrong cave scope is rejected")
	fragment.free()
	core.free()
	var key := PickupBase.new()
	key.kind = &"big_key"
	key.scope = &"c2"
	key.persistent_id = &"bigkey_c1"
	var keys: Array[Node] = [key]
	problems.clear()
	_check_pickup_specs("cave_1_7", keys, problems)
	check(_mentions(problems, "wrong kind or scope"), "Lockpick in wrong cave scope is rejected")
	key.scope = &"c1"
	problems.clear()
	_check_pickup_specs("cave_1_7", keys, problems)
	check(problems.is_empty(), "correct Lockpick passes")
	key.kind = &"key"
	key.persistent_id = &"key_c1_1"
	check(_needs_moth("cave_1_3", key), "C1 main-room small key requires grate fetch proof")
	check(not _needs_moth("cave_1", key), "historical key is not converted to C1 fetch")
	key.free()

	var fetch_room := _instance("cave_1")
	var props := fetch_room.get_node("Props")
	for prop in props.get_children():
		props.remove_child(prop)
		prop.free()
	var packed := load("res://scenes/world/grate.tscn") as PackedScene
	check(packed != null, "committed grate scene loads")
	if packed != null:
		var grate := packed.instantiate() as Node2D
		grate.position = Vector2(960, 336)
		grate.set("size", Vector2(192, 96))
		props.add_child(grate)
		for x in [432.0, 1488.0]:
			var wall := SolidBlock.new()
			wall.position = Vector2(x, 336)
			wall.size = Vector2(864, 96)
			props.add_child(wall)
		var pickup := PickupBase.new()
		pickup.position = Vector2(1008, 240)
		props.add_child(pickup)
		fetch_room.get_node("Spawns/Default").position = Vector2(1008, 528)
		var geometry := _geometry(fetch_room, props, fetch_room.get_node("Bushes"), {})
		problems.clear()
		check(
			_moth_pickup_valid(fetch_room, pickup, geometry, problems),
			"sealed main-room key has a clear moth launch across a grate"
		)
		var pit_scene := load("res://scripts/world/pit_zone.gd") as Script
		check(pit_scene != null, "real pit script loads for moth regression")
		if pit_scene != null:
			var pit := pit_scene.new() as Node2D
			pit.position = pickup.position
			pit.set("size", Vector2(192, 96))
			props.add_child(pit)
			geometry = _geometry(fetch_room, props, fetch_room.get_node("Bushes"), {})
			problems.clear()
			check(geometry["blocked"].has(tile_of(pickup.position)), "pit stays blocked to Player")
			check(
				_moth_pickup_valid(fetch_room, pickup, geometry, problems),
				"moth fetch crosses grate and flies over pit to key"
			)
			var wall := SolidBlock.new()
			wall.position = pickup.position
			wall.size = Vector2(192, 96)
			props.add_child(wall)
			geometry = _geometry(fetch_room, props, fetch_room.get_node("Bushes"), {})
			problems.clear()
			check(
				not _moth_pickup_valid(fetch_room, pickup, geometry, problems),
				"WORLD wall overlapping pit still denies moth fetch"
			)
			wall.position = grate.position
			geometry = _geometry(fetch_room, props, fetch_room.get_node("Bushes"), {})
			problems.clear()
			check(
				not _moth_pickup_valid(fetch_room, pickup, geometry, problems),
				"WORLD wall overlapping grate still denies moth fetch"
			)
			props.remove_child(wall)
			wall.free()
			pit.position = Vector2(1008, 528)
			pit.set("size", Vector2(192, 384))
			fetch_room.get_node("Spawns/Default").position = Vector2(1008, 816)
			geometry = _geometry(fetch_room, props, fetch_room.get_node("Bushes"), {})
			problems.clear()
			check(
				not _moth_pickup_valid(fetch_room, pickup, geometry, problems),
				"clear flight over pit beyond 420 px still denies moth fetch"
			)
			props.remove_child(pit)
			pit.free()
			fetch_room.get_node("Spawns/Default").position = Vector2(1008, 528)
		grate.position.y = 720
		geometry = _geometry(fetch_room, props, fetch_room.get_node("Bushes"), {})
		problems.clear()
		check(
			not _moth_pickup_valid(fetch_room, pickup, geometry, problems),
			"walkable key is rejected instead of accepted as a moth fetch"
		)
	fetch_room.free()


## The real e152 footprints stay closed for placement checks, but their complete three-tile
## approaches are reachable in the graph's legitimate future-open model.
func _boss_door_geometry_regressions() -> void:
	var edge: Dictionary = {}
	for candidate: Dictionary in world_json["edges"]:
		if candidate["id"] == "e152":
			edge = candidate
	check(not edge.is_empty(), "canonical boss edge e152 exists")
	if edge.is_empty():
		return
	var packed := load("res://scenes/world/boss_door.tscn") as PackedScene
	check(packed != null, "real BossDoor scene loads")
	if packed == null:
		return
	var door := packed.instantiate() as Node2D
	door.set("cave", &"c1")
	check(_has_prop(door, SCRIPT_DIR + "boss_door.gd", edge), "exact C1 boss gate matches")
	for candidate: Dictionary in world_json["edges"]:
		if candidate["id"] == "e255":
			check(
				not _key_scope_ok(door, candidate),
				"true BossDoor cannot satisfy NinthDoor fragments"
			)
	door.set("cave", &"c2")
	check(not _key_scope_ok(door, edge), "another cave's big key cannot satisfy e152")
	door.set("cave", &"c1")
	var wrong_needs := edge.duplicate(true)
	wrong_needs["needs"] = ["bigkey:c2"]
	check(not _key_scope_ok(door, wrong_needs), "wrong graph big-key scope is rejected")
	wrong_needs["needs"] = ["unrelated_flag"]
	check(not _key_scope_ok(door, wrong_needs), "unrelated flag cannot open a boss gate")
	door.free()
	for id: String in ["cave_1_6", "cave_1_8"]:
		if not scene_exists(WorldData.scene_path(id)):
			continue
		var room := _instance(id)
		var props := room.get_node("Props")
		var side := "e" if id == "cave_1_6" else "w"
		for node in props.get_children():
			if not _is_boss_door(node):
				continue
			var geometry := _geometry(
				room, props, room.get_node("Bushes"), _gated_corridor_tiles(id)
			)
			check(not node.get("is_open"), "%s BossDoor initially closed" % id)
			for tile in rect_tiles(Rect2(node.position - node.size * 0.5, node.size)):
				check(geometry["blocked"].has(tile), "%s closed footprint blocks %s" % [id, tile])
			for tile in exit_tiles(side):
				check(
					geometry["reach"].has(tile), "%s future-open approach reaches %s" % [id, tile]
				)
			node.set("cave", &"c2")
			node.set("is_open", true)
			geometry = _geometry(room, props, room.get_node("Bushes"), _gated_corridor_tiles(id))
			check(
				not geometry["reach"].has(tile_of(node.position)),
				"%s wrong scope cannot bypass geometry even with is_open" % id
			)
			var block := SolidBlock.new()
			block.position = node.position
			block.size = node.size
			props.remove_child(node)
			node.free()
			props.add_child(block)
			check(
				_mentions(room_problems(id, room), "exit %s corridor blocked" % side),
				"%s identical plain solid footprint is rejected" % id
			)
		if id == "cave_1_6":
			var pocket_door := room.get_node("Props/Door1")
			pocket_door.set("target_room", &"cave_2_9")
			var problems: Array[String] = []
			_check_doors(id, room, problems)
			check(
				_mentions(problems, "which the graph does not link"), "wrong door target rejected"
			)
		room.free()


## e255 shares the boss gate category but uses nine fragments, never a cave big key.
func _ninth_door_gate_regressions() -> void:
	var edge: Dictionary = {}
	for candidate: Dictionary in world_json["edges"]:
		if candidate["id"] == "e255":
			edge = candidate
	check(not edge.is_empty(), "canonical Ninth Door edge exists")
	var packed := load("res://scenes/world/ninth_door.tscn") as PackedScene
	check(packed != null, "real NinthDoor loads")
	if edge.is_empty() or packed == null:
		return
	var door := packed.instantiate()
	check(_has_prop(door, SCRIPT_DIR + "ninth_door.gd", edge), "exact nine fragment scopes pass")
	var changed := edge.duplicate(true)
	changed["needs"].reverse()
	check(_key_scope_ok(door, changed), "fragment scope order is immaterial")
	changed["needs"].pop_back()
	check(not _key_scope_ok(door, changed), "eight fragment scopes fail")
	changed = edge.duplicate(true)
	changed["needs"][8] = "frag:c10"
	check(not _key_scope_ok(door, changed), "substituted fragment scope fails")
	changed["needs"][8] = "frag:c8"
	check(not _key_scope_ok(door, changed), "duplicate fragment scope fails")
	changed["needs"][8] = "bigkey:c9"
	check(not _key_scope_ok(door, changed), "wrong capability kind fails")
	changed = edge.duplicate(true)
	changed["prop"] = "boss door"
	check(not _key_scope_ok(door, changed), "NinthDoor cannot stand in for a BossDoor")
	changed = edge.duplicate(true)
	changed["needs"] = ["door_ninth"]
	door.set("is_open", true)
	check(
		not _key_scope_ok(door, changed), "open state and persistence flag cannot replace fragments"
	)
	var impostor := SolidBlock.new()
	impostor.set_meta("cave", &"c1")
	impostor.set_meta("is_open", true)
	check(not _key_scope_ok(impostor, edge), "plain body with door metadata is rejected")
	impostor.free()
	door.free()


## The physical cut screen is checked at both ends of e182, while only its exact graph-named Bush
## variant is omitted from the future-open corridor flood.
func _cut_screen_gate_regressions() -> void:
	var edge: Dictionary = {}
	for candidate: Dictionary in world_json["edges"]:
		if candidate["id"] == "e182":
			edge = candidate
	check(not edge.is_empty(), "canonical C5 dry-vine edge e182 exists")
	if edge.is_empty():
		return
	check(edge_status(edge) == "ok", "e182 has the exact dry-vine Bush at an endpoint")
	var wrong: Dictionary = edge.duplicate(true)
	wrong["prop"] = "moss wall"
	var script := load(SCRIPT_DIR + "bush.gd") as Script
	var sample := script.new() as Node
	sample.set("variant", &"dry_vine_screen")
	check(not _key_scope_ok(sample, wrong), "wrong cut-screen kind is rejected")
	wrong = edge.duplicate(true)
	wrong["needs"] = ["bomb"]
	check(not _key_scope_ok(sample, wrong), "wrong cut requirement is rejected")
	var impostor := SolidBlock.new()
	impostor.set_meta("variant", &"dry_vine_screen")
	check(not _key_scope_ok(impostor, edge), "unrelated solid with matching metadata is rejected")
	impostor.free()
	sample.free()
	for id: String in ["cave_5_2", "cave_5_3"]:
		var room := _instance(id)
		check(room != null, "%s scene is available for e182 validation" % id)
		if room == null:
			continue
		var bushes: Node = room.get_node("Bushes")
		check(_has_prop(room, SCRIPT_DIR + "bush.gd", edge), "%s has its real e182 screen" % id)
		for bush in bushes.get_children():
			check(_key_scope_ok(bush, edge), "%s dry-vine variant satisfies e182" % id)
		var side := "n" if id == "cave_5_2" else "s"
		var gated_tiles := _gated_corridor_tiles(id)
		var geometry := _geometry(room, room.get_node("Props"), bushes, gated_tiles)
		for bush in bushes.get_children():
			check(geometry["blocked"].has(tile_of(bush.position)), "%s closed screen blocks" % id)
		for tile in exit_tiles(side):
			check(geometry["reach"].has(tile), "%s e182 approach is reachable when cut" % id)
		for bush in bushes.get_children():
			bush.set("variant", &"rush_wall")
		geometry = _geometry(room, room.get_node("Props"), bushes, gated_tiles)
		check(
			geometry["walk"].has(exit_tiles(side)[2]),
			"%s wrong Bush variant still blocks its corridor" % id
		)
		var solid_room := _instance(id)
		var solid_bushes: Node = solid_room.get_node("Bushes")
		for bush in solid_bushes.get_children():
			var block := SolidBlock.new()
			block.position = bush.position
			block.size = Vector2(68, 68)
			bushes = solid_bushes
			bushes.remove_child(bush)
			bush.free()
			solid_room.get_node("Props").add_child(block)
		geometry = _geometry(
			solid_room, solid_room.get_node("Props"), solid_bushes, _gated_corridor_tiles(id)
		)
		check(
			geometry["walk"].has(exit_tiles(side)[2]),
			"%s identical unrelated solid blocks its corridor" % id
		)
		solid_room.free()
		room.free()


func _reel_and_refill_regressions() -> void:
	for id in ["cave_9_6", "cave_9_7"]:
		var room := _instance(id)
		var props := room.get_node("Props")
		var geometry := _geometry(room, props, room.get_node("Bushes"), {})
		var side := "e" if id == "cave_9_6" else "w"
		var exit_tile: Vector2i = exit_tiles(side)[0]
		check(not geometry["reach"].has(exit_tile), "%s pit blocks ordinary walking" % id)
		check(_reel_reach(room, geometry).has(exit_tile), "%s safe reel reaches exit bank" % id)
		var rings: Array[Node2D] = []
		for prop in props.get_children():
			if _script_file(prop) == "anchor_ring.gd":
				rings.append(prop as Node2D)
				prop.set("max_range", 100.0)
		check(
			not _reel_reach(room, geometry).has(exit_tile),
			"%s out-of-range ring does not waive pit" % id
		)
		for ring in rings:
			ring.set("max_range", 0.0)
		var target := rings[0]
		for ring in rings:
			if (ring.position.x > target.position.x) == (id == "cave_9_6"):
				target = ring
		var anchor_position := target.position
		target.position.x = 2480 if id == "cave_9_6" else -560
		check(
			not _reel_reach(room, geometry).has(exit_tile),
			"%s reel cannot exceed actual 576 px range" % id
		)
		target.position.x = 1392 if id == "cave_9_6" else 528
		check(
			not _reel_reach(room, geometry).has(exit_tile),
			"%s reel refuses a landing in the pit" % id
		)
		target.position = anchor_position
		var wall := SolidBlock.new()
		wall.position = Vector2(1392, 480) if id == "cave_9_6" else Vector2(528, 480)
		wall.size = Vector2(96, 192)
		props.add_child(wall)
		geometry = _geometry(room, props, room.get_node("Bushes"), {})
		check(
			not _reel_reach(room, geometry).has(exit_tile),
			"%s WORLD overlapping pit blocks reel tip" % id
		)
		props.remove_child(wall)
		wall.free()
		for ring in rings:
			props.remove_child(ring)
			ring.free()
		geometry = _geometry(room, props, room.get_node("Bushes"), {})
		check(
			not _reel_reach(room, geometry).has(exit_tile), "%s missing rings do not waive pit" % id
		)
		room.free()

	var room := _instance("cave_9_4")
	var seen := {}
	check(_record_persistent_ids("cave_9_4", room, seen).is_empty(), "explicit refills need no id")
	var refills: Array[PickupBase] = []
	for pickup in descendants_of_class(room, PickupBase):
		if _is_entry_refill(room, pickup):
			refills.append(pickup as PickupBase)
	check(refills.size() == 2, "C9.4 has exactly two marked entry refills")
	if refills.size() == 2:
		var refill := refills[0]
		room.set("room_id", &"cave_9_5")
		check(not _is_entry_refill(room, refill), "refill exemption is confined to authored room")
		room.set("room_id", &"cave_9_4")
		refill.respawn_on_enter = false
		check(
			_mentions(_record_persistent_ids("cave_9_4", room, {}), "no persistent_id"),
			"unmarked empty-id pickup remains invalid"
		)
		var problems: Array[String] = []
		var geometry := _geometry(room, room.get_node("Props"), room.get_node("Bushes"), {})
		_check_pickups("cave_9_4", room, geometry, problems)
		check(_mentions(problems, "exactly two"), "missing explicit refill is rejected")
		refill.respawn_on_enter = true
		refill.persistent_id = &"invalid_refill_id"
		check(
			_mentions(_record_persistent_ids("cave_9_4", room, {}), "invalid respawning refill"),
			"marked refill must have empty id"
		)
		refill.respawn_on_enter = false
		refill.persistent_id = &"duplicate_fixture"
		refills[1].respawn_on_enter = false
		refills[1].persistent_id = refill.persistent_id
		check(
			_mentions(_record_persistent_ids("cave_9_4", room, {}), "is used by"),
			"ordinary persistent ids remain unique"
		)
		refill.respawn_on_enter = true
		refill.persistent_id = &""
		refill.kind = &"key"
		check(not _is_entry_refill(room, refill), "progression key cannot masquerade as refill")
		refill.kind = &"pitch_pot_bundle"
		var nested := Node2D.new()
		room.add_child(nested)
		refill.owner = null
		refill.reparent(nested)
		check(not _is_entry_refill(room, refill), "refill must be directly in Props")
	room.free()
