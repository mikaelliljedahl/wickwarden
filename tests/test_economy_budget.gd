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


func _area_for(id: String) -> String:
	var node: Dictionary = rooms_by_id.get(id, pockets_by_id.get(id, {}))
	var area := String(node.get("region", ""))
	check(EXPECTED.has(area), "%s belongs to a budget area" % id)
	return area
