extends TestCase
## Minimap cells (Hud.room_cell) for all 192 rooms of the graph: overworld rooms on their grid cell
## of the 12x9 map, cave rooms on the local 5x5 grid of their cave (smallest x and y at 0), pockets
## and unknown ids without a cell. Also checks equipped-tool and counter icon selection.


func run() -> void:
	var ids := WorldData.room_ids()
	check_eq(ids.size(), 192, "the graph holds 192 rooms")
	_overworld(ids)
	_caves(ids)
	_pockets_and_unknown()
	_lockpick_icon()
	_tool_icons()


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


func _lockpick_icon() -> void:
	var hud := Hud.new()
	var original_manifest := SpriteVisual.manifest_path
	var expected := SpriteVisual.icon_of(&"hud_counter_big_key")
	check(expected != null, "the lockpick has dedicated HUD art")
	check_eq(hud._icon_for(&"big_key"), expected, "the counter prefers dedicated HUD art")
	var fallback_manifest := "user://hud_lockpick_fallback.json"
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(original_manifest))
	manifest.erase("hud_counter_big_key")
	var file := FileAccess.open(fallback_manifest, FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest))
	file.close()
	SpriteVisual.use_manifest(fallback_manifest)
	var pickup := SpriteVisual.icon_of(&"big_key")
	check(pickup != null, "the lockpick has pickup art for fallback")
	check_eq(hud._icon_for(&"big_key"), pickup, "missing HUD art falls back to pickup art")
	SpriteVisual.use_manifest("res://tests/fixtures/no_item_art.json")
	check(hud._icon_for(&"big_key") == null, "missing lockpick art retains shape fallback")
	SpriteVisual.use_manifest(original_manifest)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(fallback_manifest))
	hud.free()


func _tool_icons() -> void:
	var hud := Hud.new()
	var original_manifest := SpriteVisual.manifest_path
	check_eq(ItemRegistry.ids().size(), 10, "all ten registered tools are covered")
	for id: StringName in ItemRegistry.ids():
		var expected := SpriteVisual.icon_of(StringName("icon_" + String(id)))
		check(expected != null, "%s has dedicated tool art" % id)
		check_eq(hud._icon_for(id), expected, "%s prefers its dedicated icon" % id)
	for kind in [&"brass_coin", &"key", &"pitch_pot_bundle", &"tallow_slug", &"fragment"]:
		check_eq(hud._icon_for(kind), SpriteVisual.icon_of(kind), "%s counter is unchanged" % kind)
	var fallback_manifest := "user://hud_tool_fallback.json"
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(original_manifest))
	for id in ItemRegistry.ids():
		manifest.erase("icon_" + String(id))
	var file := FileAccess.open(fallback_manifest, FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest))
	file.close()
	SpriteVisual.use_manifest(fallback_manifest)
	for id: StringName in ItemRegistry.ids():
		check_eq(hud._icon_for(id), SpriteVisual.icon_of(id), "%s falls back to object art" % id)
	for id in [&"tether_moth", &"pitch_pot"]:
		var icon := hud._icon_for(id) as AtlasTexture
		check(icon != null, "%s has accepted object fallback art" % id)
		if icon != null:
			check_eq(icon.region, Rect2(0, 0, 96, 96), "object fallback excludes adjacent frames")
	SpriteVisual.use_manifest("res://tests/fixtures/no_item_art.json")
	for id: StringName in ItemRegistry.ids():
		check(hud._icon_for(id) == null, "%s retains placeholder without art" % id)
	SpriteVisual.use_manifest(original_manifest)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(fallback_manifest))
	hud.free()
