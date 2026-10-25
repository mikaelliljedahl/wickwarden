extends "res://tests/area_base.gd"
## Assembled Briar Hollow acceptance against the binding graph.

const ROOMS := [
	"cave_2_1",
	"cave_2_2",
	"cave_2_3",
	"cave_2_4",
	"cave_2_5",
	"cave_2_6",
	"cave_2_7",
	"cave_2_8",
	"cave_2_9"
]


func run() -> void:
	reset_state()
	index_world()
	var actual: Array[String] = []
	for id: String in rooms_by_id:
		if WorldData.scope_of(id) == &"c2":
			actual.append(id)
	actual.sort()
	check_eq(actual, ROOMS, "c2 contains exactly nine contracted rooms")
	for id: String in ROOMS:
		check_area(id)
	check(pending.is_empty(), "assembled C02 has no pending dependencies")
	var entrance := scene_root(WorldData.scene_path("cave_2_1"))
	check(entrance != null, "entrance delivered")
	if entrance != null:
		check(entrance.has_node("Spawns/FromOverworld"), "mouth arrival marker exists")
	var mouth := scene_root(WorldData.scene_path("ow_5_1"))
	check(mouth != null, "real mouth delivered")
	if mouth != null:
		check_eq(
			_door_to(mouth, "cave_2_1").get("spawn"), "FromOverworld", "mouth uses named marker"
		)
	var edges: Array[String] = []
	for edge: Dictionary in world_json["edges"]:
		if ROOMS.has(edge["a"]) and ROOMS.has(edge["b"]):
			edges.append(edge["id"])
	check_eq(
		edges,
		["e155", "e156", "e157", "e158", "e159", "e160", "e161", "e162"],
		"exact internal graph"
	)
	var boss := scene_root(WorldData.scene_path("cave_2_9"))
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
				reward.requires_flag, &"boss_cave_2_9_defeated", "reward waits for actual boss"
			)
		check(ids.has(&"frag_c2") and ids.has(&"wick_core_c2"), "canonical reward identities")
		mutation_proof()
	free_scenes()


func mutation_proof() -> void:
	var packed := load(WorldData.scene_path("cave_2_9")) as PackedScene
	check(packed != null, "real boss room loads for negative acceptance")
	if packed == null:
		return
	var broken := packed.instantiate() as Room
	broken.exits.clear()
	check(not room_problems("cave_2_9", broken).is_empty(), "missing boss exit rejected")
	broken.free()
	broken = packed.instantiate() as Room
	for reward in descendants_of_class(broken, PickupBase):
		reward.requires_flag = &"wrong_boss"
	check(not room_problems("cave_2_9", broken).is_empty(), "wrong boss reward flag rejected")
	broken.free()
