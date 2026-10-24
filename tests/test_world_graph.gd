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
	_print_pending()
	free_scenes()


## Every gated edge of the graph has its prop in the table; a gate whose scenes or prop script do not
## exist yet is pending (gates at built rooms are checked by check_area).
func _gates_have_props() -> void:
	for edge: Dictionary in world_json["edges"]:
		if edge["gate"] == null:
			continue
		var prop := String(edge["prop"])
		check(PROP_SCRIPTS.has(prop), "edge %s: prop '%s' has a script in the F3 table" % [edge["id"], prop])
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
			check(WorldData.exits(b).has(side_b), "step %s: %s has exit %s back" % [edge["id"], b, side_b])


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
		for node in descendants_of_class(root, PickupBase):
			var pid := String((node as PickupBase).persistent_id)
			if seen.has(pid):
				check(false, "persistent_id %s is used by %s and %s" % [pid, seen[pid], id])
			seen[pid] = id
	check(seen.size() > 0, "the built scenes have persistent pickups")


## Negative cases, built in memory from a real room: a blocked exit corridor and a missing exit.
func _broken_rooms_are_rejected() -> void:
	var blocked := _instance("ow_0_0")
	var block := SolidBlock.new()
	block.size = Vector2(96, 192)
	block.position = Vector2(1680, 480)
	(blocked.get_node("Props") as Node).add_child(block)
	var problems := room_problems("ow_0_0", blocked)
	check(_mentions(problems, "exit e corridor blocked"), "a room whose east exit is walled off is rejected")
	blocked.free()
	var short := _instance("ow_0_0")
	var exits: Array[StringName] = [&"e"]
	short.exits = exits
	check(_mentions(room_problems("ow_0_0", short), "graph exit s is missing"),
		"a room without its south exit is rejected")
	short.free()
	var wrong := _instance("ow_0_0")
	wrong.room_id = &"ow_9_9"
	check(_mentions(room_problems("ow_0_0", wrong), "room_id is ow_9_9"), "a room with another id is rejected")
	wrong.free()
	var no_door := _instance("ow_2_1")
	for door in descendants_of_class(no_door, LockedDoor):
		door.get_parent().remove_child(door)
		door.free()
	check(_mentions(room_problems("ow_2_1", no_door), "gate e124"),
		"a room whose locked door is gone is rejected")
	no_door.free()
	var no_moth := _instance("ow_0_1")
	for pickup in descendants_of_class(no_moth, PickupBase):
		pickup.get_parent().remove_child(pickup)
		pickup.free()
	check(_mentions(room_problems("ow_0_1", no_moth), "pickups placed"),
		"a room whose pickup is gone is rejected")
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
	check(room_problems("ow_2_0", gated).is_empty(), "a gate in the gap of a gated exit (ow_2_0 east) passes")
	gated.free()
	var walled := _instance("ow_2_0")
	walled.exits = gated_exits
	var block := SolidBlock.new()
	block.size = Vector2(96, 192)
	block.position = Vector2(1776, 480)
	(walled.get_node("Props") as Node).add_child(block)
	check(_mentions(room_problems("ow_2_0", walled), "exit e corridor blocked"),
		"a solid block in the gap of a gated exit is rejected")
	walled.free()
	var open := _instance("ow_0_0")
	var open_gate := Gate.new()
	open_gate.size = Vector2(96, 192)
	open_gate.position = Vector2(1776, 480)
	(open.get_node("Props") as Node).add_child(open_gate)
	check(_mentions(room_problems("ow_0_0", open), "exit e corridor blocked"),
		"a gate in the gap of an open exit is rejected")
	open.free()


func _instance(id: String) -> Node:
	var packed := load(WorldData.scene_path(id)) as PackedScene
	return packed.instantiate()


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
