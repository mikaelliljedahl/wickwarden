extends "res://tests/area_base.gd"
## C01 assembled acceptance includes the historical alcove and the separate crack cache.

const ROOMS := [
	"cave_1", "cave_1_2", "cave_1_3", "cave_1_4", "cave_1_5", "cave_1_6", "cave_1_7", "cave_1_8"
]


func run() -> void:
	reset_state()
	index_world()
	var actual: Array[String] = []
	for id: String in rooms_by_id:
		if WorldData.scope_of(id) == &"c1":
			actual.append(id)
	actual.sort()
	var expected: Array[String] = []
	expected.assign(ROOMS)
	expected.sort()
	check_eq(actual, expected, "C1 scope contains exactly the eight contracted rooms")
	for id: String in ROOMS:
		check(scene_exists(WorldData.scene_path(id)), "delivered scene exists: " + id)
		check_area(id)
	check_area("cave_1_6#crack")
	check(pending.is_empty(), "C01 acceptance has no pending dependencies")
	check(is_in_place("cave_1#alcove"), "original historical alcove remains in place")
	var hub := scene_root(WorldData.scene_path("cave_1"))
	check_eq(
		hub.get_node("Spawns/FromOverworld").position,
		Vector2(960, 600),
		"original mouth spawn retained"
	)
	var mouth := scene_root(WorldData.scene_path("ow_1_1"))
	check_eq(
		_door_to(mouth, "cave_1").get("spawn"), "FromOverworld", "real mouth uses named cave spawn"
	)
	for spec in [
		["cave_1_4", "cave_1_5", "e149", "brazier"],
		["cave_1_4", "cave_1_6", "e151", "key"],
		["cave_1_6", "cave_1_8", "e152", "boss"],
		["cave_1_6", "cave_1_6#crack", "e154", "bomb"]
	]:
		var edge := WorldData.edge_between(spec[0], spec[1])
		check_eq(edge.get("id"), spec[2], "canonical cave edge identity")
		check_eq(edge.get("gate"), spec[3], "canonical cave gate type")
	var internal: Array[String] = []
	for edge: Dictionary in world_json["edges"]:
		var target := String(edge["b"])
		if ROOMS.has(edge["a"]) and (ROOMS.has(target) or target in ["cave_1#alcove", "cave_1_6#crack"]):
			internal.append(edge["id"])
	internal.sort()
	var edges := ["e146", "e147", "e148", "e149", "e150", "e151", "e152", "e153", "e154"]
	check_eq(internal, edges, "exact eight-room graph including both secrets")
	var boss := scene_root(WorldData.scene_path("cave_1_8"))
	var rewards := descendants_of_class(boss, PickupBase)
	check_eq(rewards.size(), 2, "boss room contains only one fragment and one core")
	for reward in rewards:
		check_eq(
			reward.requires_flag, &"boss_cave_1_8_defeated", "both rewards await actual boss death"
		)
	var pocket := scene_root(WorldData.scene_path("cave_1_6#crack"))
	check(pocket.dark, "separate cave cache inherits host darkness")
	_mutation_proof()
	free_scenes()


func _mutation_proof() -> void:
	var packed := load(WorldData.scene_path("cave_1_8")) as PackedScene
	check(packed != null, "actual boss room loads for negative acceptance")
	if packed == null:
		return
	var broken := packed.instantiate() as Room
	broken.exits.clear()
	check(not room_problems("cave_1_8", broken).is_empty(), "missing boss exit fails area checks")
	broken.free()
	broken = packed.instantiate() as Room
	for reward in descendants_of_class(broken, PickupBase):
		reward.requires_flag = &"wrong_boss"
	check(
		not room_problems("cave_1_8", broken).is_empty(),
		"wrong reward death flag fails area checks"
	)
	broken.free()
