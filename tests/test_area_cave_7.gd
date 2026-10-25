extends "res://tests/area_base.gd"
## Strict checks retain the moth-only key reachability requirement.


func run() -> void:
	reset_state()
	index_world()
	var count := 0
	for id: String in rooms_by_id:
		if WorldData.scope_of(id) == &"c7":
			count += 1
	check_eq(count, 11, "C07 has exactly eleven rooms and no pockets")
	for number in range(1, 12):
		var id := "cave_7_" + str(number)
		check(ResourceLoader.exists(WorldData.scene_path(id)), "delivered " + id)
		check_area(id)
	check(pending.is_empty(), "C07 has no pending dependencies")
	var root := scene_root(WorldData.scene_path("cave_7_11"))
	var rewards := descendants_of_class(root, PickupBase).filter(
		func(n: Node) -> bool: return n.kind in [&"fragment", &"wick_core"]
	)
	check_eq(rewards.size(), 2, "single room-owned fragment and core")
	for reward: PickupBase in rewards:
		check_eq(reward.requires_flag, &"boss_cave_7_11_defeated", "canonical reward condition")
	free_scenes()
