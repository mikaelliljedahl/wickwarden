extends "res://tests/area_base.gd"
## Complete Choir Vault geometry and graph acceptance, including both optional pockets.

const ROOMS := [
	"cave_6_1",
	"cave_6_2",
	"cave_6_3",
	"cave_6_4",
	"cave_6_5",
	"cave_6_6",
	"cave_6_7",
	"cave_6_8",
	"cave_6_9",
	"cave_6_10",
	"cave_6_11"
]
const POCKETS := ["cave_6_8#ward", "cave_6_9#crypt"]


func run() -> void:
	reset_state()
	index_world()
	var actual: Array[String] = []
	for id: String in rooms_by_id:
		if WorldData.scope_of(id) == &"c6":
			actual.append(id)
	actual.sort()
	var expected: Array[String] = []
	expected.assign(ROOMS)
	expected.sort()
	check_eq(actual, expected, "exactly eleven contracted C06 rooms")
	for id: String in ROOMS + POCKETS:
		check(ResourceLoader.exists(WorldData.scene_path(id)), "delivered scene " + id)
		check_area(id)
		check((scene_root(WorldData.scene_path(id)) as Room).dark, "dark cave scene " + id)
	check(pending.is_empty(), "assembled C06 has no pending dependencies")
	var mouth := scene_root(WorldData.scene_path("ow_6_6"))
	check_eq(_door_to(mouth, "cave_6_1").get("spawn"), "FromOverworld", "actual mouth arrival")
	check(
		scene_root(WorldData.scene_path("cave_6_1")).has_node("Spawns/FromOverworld"),
		"arrival marker"
	)
	for id: String in ["cave_6_8", "cave_6_10"]:
		var root := scene_root(WorldData.scene_path(id))
		var doors := root.find_children("*", "CharacterBody2D", true, false).filter(
			func(n: Node) -> bool: return n.get("stone_id") == &"e198"
		)
		check_eq(doors.size(), 1, "one authored heavy gate at " + id)
		if not doors.is_empty():
			check_eq(doors[0].mode, 1, "normative PUSH mode at " + id)
	var boss := scene_root(WorldData.scene_path("cave_6_11"))
	var rewards := descendants_of_class(boss, PickupBase).filter(
		func(n: Node) -> bool: return n.kind in [&"fragment", &"wick_core"]
	)
	check_eq(rewards.size(), 2, "single room-owned fragment and core, including arena descendants")
	var ids: Array[StringName] = []
	for reward: PickupBase in rewards:
		ids.append(reward.persistent_id)
		check_eq(reward.requires_flag, &"boss_cave_6_11_defeated", "canonical reward condition")
	check(ids.has(&"frag_c6") and ids.has(&"wick_core_c6"), "canonical boss rewards")
	var broken := (load(WorldData.scene_path("cave_6_11")) as PackedScene).instantiate()
	broken.exits.clear()
	check(not room_problems("cave_6_11", broken).is_empty(), "missing exit mutation rejected")
	broken.free()
	free_scenes()
