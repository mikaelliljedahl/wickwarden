extends "res://tests/area_base.gd"
## C09 is the lit workshop (decision 42), including two separate pocket scenes.


func run() -> void:
	reset_state()
	index_world()
	for number in range(1, 11):
		var id := "cave_9_%d" % number
		check(ResourceLoader.exists(WorldData.scene_path(id)), "C09 delivered: " + id)
		check_area(id)
		var room := scene_root(WorldData.scene_path(id)) as Room
		check(not room.dark, "C09 workshop intentionally lit: " + id)
	for id in ["cave_9_2#cell", "cave_9_9#vault"]:
		check_area(id)
	check(pending.is_empty(), "all ten C09 rooms and both pockets delivered")
	var entry := scene_root(WorldData.scene_path("cave_9_1"))
	check(entry.has_node("Spawns/FromOverworld"), "actual cave arrival marker")
	var boss := scene_root(WorldData.scene_path("cave_9_10"))
	var rewards := descendants_of_class(boss, PickupBase).filter(
		func(n: Node) -> bool: return n.kind in [&"fragment", &"wick_core"]
	)
	check_eq(rewards.size(), 2, "exactly one ninth fragment and one core")
	for reward: PickupBase in rewards:
		check_eq(reward.requires_flag, &"boss_cave_9_10_defeated", "canonical reward gate")
	var workbench := scene_root(WorldData.scene_path("cave_9_4"))
	var refills := descendants_of_class(workbench, PickupBase).filter(
		func(n: Node) -> bool: return n.kind == &"pitch_pot_bundle"
	)
	check_eq(refills.size(), 2, "two authored per-visit workbench pot bundles")
	for refill: PickupBase in refills:
		check_eq(refill.persistent_id, &"", "workbench refill is intentionally nonpersistent")
	free_scenes()
