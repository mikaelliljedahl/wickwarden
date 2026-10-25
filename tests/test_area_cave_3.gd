extends "res://tests/area_base.gd"
## Assembled Drowned Wick Works acceptance against the binding graph.

const ROOMS := [
	"cave_3_1",
	"cave_3_2",
	"cave_3_3",
	"cave_3_4",
	"cave_3_5",
	"cave_3_6",
	"cave_3_7",
	"cave_3_8",
	"cave_3_9"
]


func run() -> void:
	reset_state()
	index_world()
	var actual: Array[String] = []
	for id: String in rooms_by_id:
		if WorldData.scope_of(id) == &"c3":
			actual.append(id)
	actual.sort()
	check_eq(actual, ROOMS, "c3 contains exactly nine contracted rooms")
	for id: String in ROOMS:
		check_area(id)
	check(pending.is_empty(), "assembled C03 has no pending dependencies")
	var entrance := scene_root(WorldData.scene_path("cave_3_1"))
	check(entrance != null, "entrance delivered")
	if entrance != null:
		check(entrance.has_node("Spawns/FromOverworld"), "mouth arrival marker exists")
	var mouth := scene_root(WorldData.scene_path("ow_3_5"))
	check(mouth != null, "real mouth delivered")
	if mouth != null:
		check_eq(
			_door_to(mouth, "cave_3_1").get("spawn"), "FromOverworld", "mouth uses named marker"
		)
	var edges: Array[String] = []
	for edge: Dictionary in world_json["edges"]:
		if ROOMS.has(edge["a"]) and ROOMS.has(edge["b"]):
			edges.append(edge["id"])
	check_eq(
		edges,
		["e163", "e164", "e165", "e166", "e167", "e168", "e169", "e170"],
		"exact internal graph"
	)
	var boss := scene_root(WorldData.scene_path("cave_3_9"))
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
				reward.requires_flag, &"boss_cave_3_9_defeated", "reward waits for actual boss"
			)
		check(ids.has(&"frag_c3") and ids.has(&"wick_core_c3"), "canonical reward identities")
		mutation_proof()
	free_scenes()


func mutation_proof() -> void:
	var packed := load(WorldData.scene_path("cave_3_9")) as PackedScene
	check(packed != null, "real boss room loads for negative acceptance")
	if packed == null:
		return
	var broken := packed.instantiate() as Room
	broken.exits.clear()
	check(not room_problems("cave_3_9", broken).is_empty(), "missing boss exit rejected")
	broken.free()
	broken = packed.instantiate() as Room
	for reward in descendants_of_class(broken, PickupBase):
		reward.requires_flag = &"wrong_boss"
	check(not room_problems("cave_3_9", broken).is_empty(), "wrong boss reward flag rejected")
	broken.free()
