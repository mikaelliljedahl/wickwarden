## timeout=900
extends "res://tests/test_layout_all.gd"
## Q6: section 6.1 counts, backed by Q2's exact per-scene inventory checks.
## Enemies count regular placed actors; bosses and minibosses are checked by Q2
## separately, as they are not included in the 436-enemy budget.

const COLUMNS := [
	"rooms", "tools", "wick cores", "small keys", "big keys", "fragments",
	"pot bags", "caches", "shops", "pot bundles", "slug bundles", "enemies"
]
const EXPECTED := {
	"brackwater": [8, 2, 1, 0, 0, 0, 0, 0, 1, 0, 0, 20],
	"thornwood": [15, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1, 34],
	"cinderflats": [14, 0, 1, 0, 0, 0, 1, 3, 1, 0, 1, 34],
	"tallowfen": [24, 0, 1, 0, 0, 0, 0, 2, 1, 0, 0, 57],
	"gravelight": [15, 0, 1, 0, 0, 0, 0, 1, 1, 0, 1, 38],
	"hushmarch": [12, 0, 1, 0, 0, 0, 0, 2, 1, 0, 1, 30],
	"cave_1": [8, 1, 1, 2, 1, 1, 0, 1, 0, 0, 0, 17],
	"cave_2": [9, 1, 1, 2, 1, 1, 0, 0, 0, 0, 1, 18],
	"cave_3": [9, 1, 2, 1, 1, 1, 0, 0, 0, 0, 0, 18],
	"cave_4": [10, 1, 1, 2, 1, 1, 0, 1, 0, 0, 1, 22],
	"cave_5": [10, 1, 1, 2, 1, 1, 0, 0, 0, 0, 0, 19],
	"cave_6": [11, 1, 2, 2, 1, 1, 0, 1, 0, 0, 0, 25],
	"cave_7": [11, 1, 1, 2, 1, 1, 0, 1, 0, 0, 0, 21],
	"cave_8": [12, 1, 1, 3, 1, 1, 0, 0, 0, 0, 1, 25],
	"cave_9": [10, 0, 1, 2, 1, 1, 0, 2, 0, 0, 1, 20],
	"cave_10": [14, 0, 0, 3, 1, 0, 0, 1, 0, 0, 1, 38],
}
const TOTAL := [192, 10, 17, 22, 10, 9, 2, 16, 6, 1, 9, 436]
const PICKUP_COLUMNS := {
	"wick_core": 2, "small_key": 3, "pot_bag": 6, "cache": 7,
	"shop": 8, "pot_bundle": 9, "slug_bundle": 10,
}


func run() -> void:
	# Q2 matches actual scene actors and individual pickup ids to graph records.
	super.run()
	var counts := {}
	for area in EXPECTED:
		counts[area] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	for room: Dictionary in world_json["rooms"]:
		var area := String(room["region"])
		check(counts.has(area), "room has a budget area: " + String(room["id"]))
		if not counts.has(area):
			continue
		counts[area][0] += 1
		for quantity in room.get("enemies", {}).values():
			counts[area][11] += int(quantity)
	for item: String in world_json["items"]:
		var area := _area_for(String(world_json["items"][item]["node"]))
		var column := 4 if item.begins_with("bigkey:") else (5 if item.begins_with("frag:") else 1)
		if counts.has(area):
			counts[area][column] += 1
	for pickup: Dictionary in world_json["pickups"]:
		var area := _area_for(String(pickup["node"]))
		var kind := String(pickup["kind"])
		check(PICKUP_COLUMNS.has(kind), "pickup kind has a budget column: " + kind)
		if counts.has(area) and PICKUP_COLUMNS.has(kind):
			counts[area][PICKUP_COLUMNS[kind]] += 1
	var total := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	print("Q6 budget columns: ", COLUMNS)
	for area in EXPECTED:
		for i in range(COLUMNS.size()):
			check_eq(counts[area][i], EXPECTED[area][i], "%s %s" % [area, COLUMNS[i]])
			total[i] += counts[area][i]
		print("Q6 budget ", area, ": ", counts[area])
	check_eq(total, TOTAL, "world budget totals match section 6.1")
	print("Q6 budget total: ", total)
	await _death_drop_budget(false)
	await _death_drop_budget(true)
	reset_state()


func _area_for(id: String) -> String:
	var node: Dictionary = rooms_by_id.get(id, pockets_by_id.get(id, {}))
	var area := String(node.get("region", ""))
	check(EXPECTED.has(area), "%s belongs to a budget area" % id)
	return area


## Stratified rolls exercise actual enemy deaths and pickup effects, without relying on RNG luck.
## Totals are potential yields: resetting each resource prevents wallet/ammo/health caps hiding drops.
func _death_drop_budget(tools_found: bool) -> void:
	reset_state()
	if tools_found:
		GameState.acquire_item(&"pitch_pot")
		GameState.acquire_item(&"tallow_sling")
	var arena := make_arena()
	var counts := {&"ember": 0, &"brass_bit": 0, &"brass_coin": 0,
		&"pitch_pot_bundle": 0, &"slug_bundle": 0}
	var yields := [0, 0, 0, 0]  # half-hearts, brass, pots, slugs
	for i in range(100):
		var enemy := make_enemy(arena, "res://scenes/enemies/dummy_walker.tscn", Vector2.ZERO)
		enemy.drop_roll_override = (float(i) + 0.5) / 100.0
		check(enemy.apply_damage(enemy.hp, Vector2.LEFT), "sample enemy takes lethal damage")
		var drops := arena.get_children().filter(
			func(n: Node) -> bool: return n is PickupBase and not n.is_queued_for_deletion()
		)
		check(drops.size() <= 1, "standard death produces at most one pickup")
		if drops.size() == 1:
			var pickup := drops[0] as PickupBase
			counts[pickup.kind] += 1
			GameState.health = 1
			GameState.currency = 0
			GameState.pitch_pots = 0
			GameState.slugs = 0
			check(pickup.collect(), "death drop can be collected")
			yields[0] += GameState.health - 1
			yields[1] += GameState.currency
			yields[2] += GameState.pitch_pots
			yields[3] += GameState.slugs
	var expected := [25, 35, 5, 10 if tools_found else 0, 8 if tools_found else 0]
	check_eq(counts.values(), expected, "100 stratified deaths match the standard drop shares")
	check_eq(yields, [50, 60, 40 if tools_found else 0, 48 if tools_found else 0],
		"collected drops produce the expected potential resources")
	print("Q6 100 standard deaths, tools found=", tools_found, ": ", counts, " yields ", yields)
	await dispose(arena)
