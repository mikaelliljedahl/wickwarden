extends TestCase
## Minimap cells (Hud.room_cell) for all 192 rooms of the graph: overworld rooms on their grid cell
## of the 12x9 map, cave rooms on the local 5x5 grid of their cave (smallest x and y at 0), pockets
## and unknown ids without a cell. Pure data check, no scene.


func run() -> void:
	var ids := WorldData.room_ids()
	check_eq(ids.size(), 192, "the graph holds 192 rooms")
	_overworld(ids)
	_caves(ids)
	_pockets_and_unknown()


func _overworld(ids: Array[String]) -> void:
	var used: Dictionary = {}
	var count := 0
	for id in ids:
		if WorldData.scope_of(id) != "ow":
			continue
		count += 1
		var cell: Vector2i = Hud.room_cell(StringName(id))
		check_eq(cell, WorldData.grid(id), "overworld %s is on its grid cell" % id)
		check(
			cell.x >= 0 and cell.x < 12 and cell.y >= 0 and cell.y < 9,
			"overworld %s fits the 12x9 map" % id
		)
		check(not used.has(cell), "overworld cell %s is used once" % str(cell))
		used[cell] = id
	check_eq(count, 88, "88 overworld rooms are on the map")


func _caves(ids: Array[String]) -> void:
	var per_cave: Dictionary = {}
	for id in ids:
		var scope := WorldData.scope_of(id)
		if scope == "ow":
			continue
		var cell: Vector2i = Hud.room_cell(StringName(id))
		check(
			cell.x >= 0 and cell.x < 5 and cell.y >= 0 and cell.y < 5,
			"cave room %s fits the local 5x5 grid (cell %s)" % [id, str(cell)]
		)
		var cells: Dictionary = per_cave.get(scope, {})
		check(not cells.has(cell), "cave %s: local cell %s is used once" % [scope, str(cell)])
		cells[cell] = id
		per_cave[scope] = cells
	check_eq(per_cave.size(), 10, "ten caves have local cells")
	for scope in per_cave:
		var cells: Dictionary = per_cave[scope]
		var low := Vector2i(99, 99)
		for cell: Vector2i in cells:
			low = Vector2i(mini(low.x, cell.x), mini(low.y, cell.y))
		check_eq(low, Vector2i(0, 0), "cave %s starts at local cell (0, 0)" % scope)
	check_eq(Hud.room_cell(&"cave_1"), Vector2i(1, 1), "cave_1 is local cell (1, 1) of cave 1")


func _pockets_and_unknown() -> void:
	var pockets := WorldData.all_pockets()
	check_eq(pockets.size(), 33, "33 pockets exist")
	for pocket in pockets:
		check_eq(
			Hud.room_cell(StringName(pocket)), Vector2i(-1, -1), "pocket %s has no cell" % pocket
		)
	check_eq(Hud.room_cell(&"ow_12_0"), Vector2i(-1, -1), "an unknown overworld id has no cell")
	check_eq(Hud.room_cell(&"cave_99"), Vector2i(-1, -1), "an unknown cave id has no cell")
	check_eq(Hud.room_cell(&""), Vector2i(-1, -1), "the empty id has no cell")
