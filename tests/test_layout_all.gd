## timeout=900
extends "res://tests/area_base.gd"
## Q2 layout gate. Every graph scene runs the shared room checks in four deterministic shards.
## Pending props or destinations are failures here, and every graph pickup must exist exactly once.

const SHARD_COUNT := 4
const EXPECTED_SCENES := 222

var pickup_owners: Dictionary = {}
var scene_id_owners: Dictionary = {}


func run() -> void:
	index_world()
	var ids := _standalone_scene_ids()
	check_eq(ids.size(), EXPECTED_SCENES, "all 222 graph scenes are included in layout checks")
	for shard in range(SHARD_COUNT):
		var first := ids.size() * shard / SHARD_COUNT
		var last := ids.size() * (shard + 1) / SHARD_COUNT
		print("Q2 layout shard %d/%d: %d scenes" % [shard + 1, SHARD_COUNT, last - first])
		for index in range(first, last):
			_check_scene(ids[index])
	_check_required_markers()
	_check_no_pending()
	free_scenes()


func _standalone_scene_ids() -> Array[String]:
	var ids := WorldData.room_ids()
	for id in WorldData.all_pockets():
		if not is_in_place(id):
			ids.append(id)
	ids.sort()
	return ids


func _check_scene(id: String) -> void:
	check_area(id)
	var path := WorldData.scene_path(id)
	if not scene_exists(path):
		return
	var root := scene_root(path)
	check(root != null, "%s scene loads" % id)
	if root == null:
		return
	var actual_id := String(root.get("room_id"))
	check_eq(actual_id, id, "%s scene root has its graph id" % id)
	if scene_id_owners.has(actual_id):
		check(
			false,
			"scene id %s is duplicated by %s and %s" % [actual_id, scene_id_owners[actual_id], id]
		)
	else:
		scene_id_owners[actual_id] = id
	_check_graph_pickups(id, root)


func _check_graph_pickups(id: String, root: Node) -> void:
	var exact_expected: Dictionary = {}
	var cache_prefixes: Array[String] = []
	var expected_shops: Dictionary = {}
	var expected_shop_stocks: Dictionary = {}
	for record: Dictionary in placed_at(id):
		var pickup_id := String(record["id"])
		match String(record["kind"]):
			"cache":
				cache_prefixes.append(pickup_id + "_")
			"shop":
				var shop_id := String(record["spec"].get("shop", ""))
				check(shop_id != "", "%s graph shop %s has a shop id" % [id, pickup_id])
				expected_shops[shop_id] = pickup_id
			"slug_bundle":
				if String(record["node"]).contains("#shop"):
					expected_shop_stocks[pickup_id] = true
					continue
				var canonical_id := _canonical_pickup_id(pickup_id)
				check(
					not exact_expected.has(canonical_id),
					"%s graph pickup id %s is unique" % [id, canonical_id]
				)
				exact_expected[canonical_id] = pickup_id
			_:
				var canonical_id := _canonical_pickup_id(pickup_id)
				check(
					not exact_expected.has(canonical_id),
					"%s graph pickup id %s is unique" % [id, canonical_id]
				)
				exact_expected[canonical_id] = pickup_id

	var pickups := descendants_of_class(root, PickupBase)
	var found_exact: Dictionary = {}
	var found_cache: Dictionary = {}
	for node in pickups:
		# F3 defines two exact cave_9_4 entry refills as respawning, non-persistent rewards.
		# Their shape and count are checked by check_area(); they are not graph pickup records.
		if _is_entry_refill(root, node):
			continue
		var pickup := node as PickupBase
		var persistent_id := String(pickup.persistent_id)
		check(persistent_id != "", "%s pickup %s has a persistent id" % [id, pickup.name])
		if persistent_id == "":
			continue
		if pickup_owners.has(persistent_id):
			check(
				false,
				"pickup id %s is duplicated by %s and %s"
				% [persistent_id, pickup_owners[persistent_id], id]
			)
		else:
			pickup_owners[persistent_id] = id
		if exact_expected.has(persistent_id):
			found_exact[persistent_id] = int(found_exact.get(persistent_id, 0)) + 1
			continue
		var matches_cache := false
		for prefix in cache_prefixes:
			if persistent_id.begins_with(prefix):
				found_cache[prefix] = true
				matches_cache = true
				break
		check(
			matches_cache,
			"%s pickup %s is represented by a graph placement" % [id, persistent_id]
		)
	for canonical_id in exact_expected:
		check_eq(
			int(found_exact.get(canonical_id, 0)), 1,
			"%s graph pickup %s appears exactly once" % [id, canonical_id]
		)
	for prefix in cache_prefixes:
		check(found_cache.has(prefix), "%s cache %s contains a pickup" % [id, prefix.trim_suffix("_")])

	var actual_shops: Dictionary = {}
	var actual_shop_stocks: Dictionary = {}
	for node in descendants_of_class(root, Area2D):
		if _script_file(node) != "shop_item.gd":
			continue
		var shop_id := String(node.get("shop"))
		actual_shops[shop_id] = int(actual_shops.get(shop_id, 0)) + 1
		check(expected_shops.has(shop_id), "%s shop item %s is in the graph" % [id, shop_id])
		var stock_id := String(node.get("stock_id"))
		if stock_id != "":
			actual_shop_stocks[stock_id] = int(actual_shop_stocks.get(stock_id, 0)) + 1
	for shop_id: String in expected_shops:
		check(actual_shops.has(shop_id), "%s graph shop %s has stock" % [id, shop_id])
	for stock_id: String in expected_shop_stocks:
		check_eq(
			int(actual_shop_stocks.get(stock_id, 0)), 1,
			"%s graph shop pickup %s appears exactly once" % [id, stock_id]
		)


func _canonical_pickup_id(graph_id: String) -> String:
	if graph_id.begins_with("bigkey:"):
		return "bigkey_" + graph_id.get_slice(":", 1)
	if graph_id.begins_with("frag:"):
		return "frag_" + graph_id.get_slice(":", 1)
	if graph_id == "key_ow_1":
		return "cave_key"
	if graph_id == "wick_core_ow_2_0":
		return "wick_core_cache"
	return graph_id


func _check_no_pending() -> void:
	var items := pending.keys()
	items.sort()
	check(items.is_empty(), "Q2 has no pending room, prop or door checks")
	for item in items:
		printerr("Q2 pending item: ", item)


func _check_required_markers() -> void:
	for cave: Dictionary in world_json["caves"]:
		var mouth := String(cave["mouth"])
		var entrance := String(cave["entrance"])
		var mouth_room := scene_root(WorldData.scene_path(mouth))
		var entrance_room := scene_root(WorldData.scene_path(entrance))
		check(mouth_room != null, "%s cave mouth scene loads" % mouth)
		check(entrance_room != null, "%s cave entrance scene loads" % entrance)
		if mouth_room == null or entrance_room == null:
			continue
		check(
			mouth_room.get_node_or_null("Spawns/FromCave") != null,
			"%s has the FromCave marker" % mouth
		)
		check(
			entrance_room.get_node_or_null("Spawns/FromOverworld") != null,
			"%s has the FromOverworld marker" % entrance
		)
		var into_cave := _door_to(mouth_room, entrance)
		var out_of_cave := _door_to(entrance_room, mouth)
		check_eq(into_cave.get("spawn", ""), "FromOverworld", "%s enters the cave marker" % mouth)
		check_eq(out_of_cave.get("spawn", ""), "FromCave", "%s returns to the mouth marker" % entrance)

	for pocket_id in WorldData.all_pockets():
		if is_in_place(pocket_id):
			continue
		var host := host_of(pocket_id)
		var host_room := scene_root(WorldData.scene_path(host))
		var pocket_room := scene_root(WorldData.scene_path(pocket_id))
		check(host_room != null, "%s pocket host scene loads" % pocket_id)
		check(pocket_room != null, "%s pocket scene loads" % pocket_id)
		if host_room == null or pocket_room == null:
			continue
		check(
			pocket_room.get_node_or_null("Spawns/Inside") != null,
			"%s has the Inside marker" % pocket_id
		)
		check(
			host_room.get_node_or_null("Spawns/FromPocket") != null,
			"%s has the FromPocket marker" % host
		)
		var into_pocket := _door_to(host_room, pocket_id)
		var out_of_pocket := _door_to(pocket_room, host)
		check_eq(into_pocket.get("spawn", ""), "Inside", "%s door enters Inside" % pocket_id)
		check_eq(
			out_of_pocket.get("spawn", ""), "FromPocket",
			"%s door returns to FromPocket" % pocket_id
		)
