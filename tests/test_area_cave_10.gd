extends "res://tests/area_base.gd"
## All fourteen Ninth Hollow rooms and the optional ward pocket. No C10 tool/core/fragment.


func run() -> void:
	reset_state()
	index_world()
	var ids: Array[String] = []
	for number in range(1, 15):
		var id := "cave_10_%d" % number
		ids.append(id)
		check(ResourceLoader.exists(WorldData.scene_path(id)), "delivered C10 room " + id)
		check_area(id)
		var root := scene_root(WorldData.scene_path(id))
		check(root.dark, "Ninth Hollow remains dark " + id)
		for pickup: PickupBase in descendants_of_class(root, PickupBase):
			check(
				pickup.kind not in [&"fragment", &"wick_core", &"item"],
				"C10 gives no invented tool, tenth fragment or core: " + id
			)
	var actual: Array[String] = []
	for id: String in rooms_by_id:
		if WorldData.scope_of(id) == &"c10":
			actual.append(id)
	actual.sort()
	ids.sort()
	check_eq(actual, ids, "exactly fourteen contracted C10 rooms")
	check_area("cave_10_10#ward")
	check(pending.is_empty(), "C10 has no pending scene dependencies")
	var arena := scene_root(WorldData.scene_path("cave_10_14"))
	var triggers := arena.find_children("*", "Node2D", true, false).filter(
		func(n: Node) -> bool:
			return (
				n.get_script() != null
				and n.get_script().resource_path == "res://scripts/world/ending_trigger.gd"
			)
	)
	check_eq(triggers.size(), 1, "one actual final ending trigger")
	if not triggers.is_empty():
		check_eq(triggers[0].position, Vector2(960, 480), "ending trigger at settled lantern")
	check(
		scene_root(WorldData.scene_path("cave_10_1")).has_node("Spawns/FromOverworld"),
		"named safe mouth arrival"
	)
	free_scenes()
