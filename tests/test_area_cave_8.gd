extends "res://tests/area_base.gd"
## Counting House assembled graph, authored encounter and unique room-owned rewards.


func run() -> void:
	reset_state()
	index_world()
	var expected: Array[String] = []
	for number in range(1, 13):
		var id := "cave_8_%d" % number
		expected.append(id)
		check_area(id)
	var actual: Array[String] = []
	for id: String in rooms_by_id:
		if WorldData.scope_of(id) == &"c8":
			actual.append(id)
	actual.sort()
	expected.sort()
	check_eq(actual, expected, "exact twelve contracted C08 rooms")
	check(pending.is_empty(), "no missing C08 dependencies")
	var entrance := scene_root(WorldData.scene_path("cave_8_1"))
	check(entrance.has_node("Spawns/FromOverworld"), "named mouth arrival")
	var boss := scene_root(WorldData.scene_path("cave_8_12"))
	var rewards := descendants_of_class(boss, PickupBase).filter(
		func(n: Node) -> bool: return n.kind in [&"fragment", &"wick_core"]
	)
	check_eq(rewards.size(), 2, "one fragment/core pair including arena descendants")
	var ids: Array[StringName] = []
	for reward: PickupBase in rewards:
		ids.append(reward.persistent_id)
		check_eq(reward.requires_flag, &"boss_cave_8_12_defeated", "canonical boss condition")
	check(ids.has(&"frag_c8") and ids.has(&"wick_core_c8"), "canonical room reward identities")
	var anchors := boss.find_children("*", "Node2D", true, false).filter(
		func(n: Node) -> bool:
			return (
				n.get_script() != null and n.get_script().resource_path.ends_with("anchor_ring.gd")
			)
	)
	check_eq(anchors.size(), 4, "four arena anchor rings")
	free_scenes()
