extends "res://tests/area_base.gd"
## Assembled Sleeping Foundry acceptance against the binding graph.

const ROOMS := [
	"cave_4_1",
	"cave_4_2",
	"cave_4_3",
	"cave_4_4",
	"cave_4_5",
	"cave_4_6",
	"cave_4_7",
	"cave_4_8",
	"cave_4_9",
	"cave_4_10"
]


func run() -> void:
	reset_state()
	index_world()
	var actual: Array[String] = []
	for id: String in rooms_by_id:
		if WorldData.scope_of(id) == &"c4":
			actual.append(id)
	actual.sort()
	var expected: Array[String] = []
	expected.assign(ROOMS)
	expected.sort()
	check_eq(actual, expected, "c4 contains exactly ten contracted rooms")
	for id: String in ROOMS:
		check_area(id)
	check_area("cave_4_7#seal")
	check(
		(scene_root(WorldData.scene_path("cave_4_7#seal")) as Room).dark,
		"wax pocket inherits cave darkness"
	)
	check(pending.is_empty(), "assembled C04 has no pending dependencies")
	var entrance := scene_root(WorldData.scene_path("cave_4_1"))
	check(entrance != null, "entrance delivered")
	if entrance != null:
		check(entrance.has_node("Spawns/FromOverworld"), "mouth arrival marker exists")
	var mouth := scene_root(WorldData.scene_path("ow_9_2"))
	check(mouth != null, "real mouth delivered")
	if mouth != null:
		check_eq(
			_door_to(mouth, "cave_4_1").get("spawn"), "FromOverworld", "mouth uses named marker"
		)
	var edges: Array[String] = []
	for edge: Dictionary in world_json["edges"]:
		if ROOMS.has(edge["a"]) and (ROOMS.has(edge["b"]) or edge["b"] == "cave_4_7#seal"):
			edges.append(edge["id"])
	check_eq(
		edges,
		["e171", "e172", "e173", "e174", "e175", "e176", "e177", "e178", "e179", "e180"],
		"exact internal graph"
	)
	var boss := scene_root(WorldData.scene_path("cave_4_10"))
	check(boss != null, "boss room delivered")
	if boss != null:
		var rewards := descendants_of_class(boss, PickupBase).filter(
			func(n: Node) -> bool: return n.kind in [&"fragment", &"wick_core"]
		)
		check_eq(rewards.size(), 2, "single fragment and core including arena descendants")
		var ids: Array[StringName] = []
		for reward in rewards:
			ids.append(reward.persistent_id)
			check_eq(
				reward.requires_flag, &"boss_cave_4_10_defeated", "reward waits for actual boss"
			)
		check(ids.has(&"frag_c4") and ids.has(&"wick_core_c4"), "canonical reward identities")
		mutation_proof()
	free_scenes()


func mutation_proof() -> void:
	var packed := load(WorldData.scene_path("cave_4_10")) as PackedScene
	check(packed != null, "real boss room loads for negative acceptance")
	if packed == null:
		return
	var broken := packed.instantiate() as Room
	broken.exits.clear()
	check(not room_problems("cave_4_10", broken).is_empty(), "missing boss exit rejected")
	broken.free()
	broken = packed.instantiate() as Room
	for reward in descendants_of_class(broken, PickupBase):
		reward.requires_flag = &"wrong_boss"
	check(not room_problems("cave_4_10", broken).is_empty(), "wrong boss reward flag rejected")
	broken.free()
