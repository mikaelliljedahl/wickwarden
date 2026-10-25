extends "res://tests/area_base.gd"
## The complete Mirrored Archive, including the pre-jar answer and room-owned rewards.

const ROOMS := [
	"cave_5_1",
	"cave_5_2",
	"cave_5_3",
	"cave_5_4",
	"cave_5_5",
	"cave_5_6",
	"cave_5_7",
	"cave_5_8",
	"cave_5_9",
	"cave_5_10"
]


func run() -> void:
	reset_state()
	index_world()
	var actual: Array[String] = []
	for id: String in rooms_by_id:
		if WorldData.scope_of(id) == &"c5":
			actual.append(id)
	actual.sort()
	var expected: Array[String] = []
	expected.assign(ROOMS)
	expected.sort()
	check_eq(actual, expected, "C05 has exactly the ten contracted rooms")
	for id: String in ROOMS:
		check(ResourceLoader.exists(WorldData.scene_path(id)), "C05 delivered: " + id)
		check_area(id)
	check(pending.is_empty(), "assembled C05 has no pending room dependencies")
	var foyer := scene_root(WorldData.scene_path("cave_5_1"))
	check(foyer.has_node("Spawns/FromOverworld"), "C05 named arrival marker")
	check_eq(
		_door_to(scene_root(WorldData.scene_path("ow_6_3")), "cave_5_1").get("spawn"),
		"FromOverworld",
		"Lantern Isle uses actual contracted entrance"
	)
	var index := scene_root(WorldData.scene_path("cave_5_4"))
	var braziers := descendants_of_class(index, Brazier)
	check_eq(braziers.size(), 4, "exactly four authored pre-jar corner braziers")
	var ids: Array[StringName] = []
	for brazier: Brazier in braziers:
		check(not ids.has(brazier.brazier_id), "each corner light has its own persistent identity")
		ids.append(brazier.brazier_id)
	check_eq(
		WorldData.edge_between("cave_5_5", "cave_5_6").get("needs"),
		["glow_jar"],
		"hidden step retains actual new-tool requirement"
	)
	for id: String in ["cave_5_5", "cave_5_6"]:
		var root := scene_root(WorldData.scene_path(id))
		var seams := root.find_children("*", "Area2D", true, false).filter(
			func(n: Node) -> bool: return n.get("seam_id") == &"e185"
		)
		check_eq(seams.size(), 1, "exactly one shared-id hidden seam on each step endpoint")
	var boss := scene_root(WorldData.scene_path("cave_5_10"))
	var lecterns := boss.find_children("Lectern*", "StaticBody2D", true, false)
	check_eq(lecterns.size(), 6, "six authored solid lecterns including arena descendants")
	var rewards := descendants_of_class(boss, PickupBase).filter(
		func(n: Node) -> bool: return n.kind in [&"fragment", &"wick_core"]
	)
	check_eq(rewards.size(), 2, "single fragment and core; arena adds no duplicate rewards")
	var reward_ids: Array[StringName] = []
	for reward: PickupBase in rewards:
		reward_ids.append(reward.persistent_id)
		check_eq(
			reward.requires_flag,
			&"boss_cave_5_10_defeated",
			"canonical actual boss reward condition"
		)
	check(reward_ids.has(&"frag_c5") and reward_ids.has(&"wick_core_c5"), "canonical reward ids")
	free_scenes()
