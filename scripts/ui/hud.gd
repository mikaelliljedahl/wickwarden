class_name Hud
extends CanvasLayer
## HUD band (120 px at the top): hearts, brass, keys of the current scope, big key and fragments of
## the current cave, pitch pots and slugs, the active sub-item frame and a minimap. The minimap shows
## the 12x9 overworld grid, or the local grid of the cave the player is in (at most 5x5, larger cells).
## Pockets are not on the map: the ring marks the room that holds them. Counters and the item frame
## draw the kind's icon (SpriteVisual.icon_of) and fall back to the placeholder shapes. Reads GameState
## and WorldData only. No tutorial text here: button help lives in the pause menu.

const BAND_COLOR := Color(0.05, 0.05, 0.08, 1.0)
const HEART_FULL := Color(0.9, 0.2, 0.25)
const HEART_EMPTY := Color(0.25, 0.1, 0.12)
const HEARTS_PER_ROW := 10
const HEART_SIZE := 34.0
const HEART_STEP := 42.0
const FRAGMENT_TOTAL := 9
## Right edge of the minimap (24 px margin on the 1920 px screen).
const MAP_RIGHT := 1896.0
const OW_GRID := Vector2i(12, 9)
const OW_CELL := Vector2(14, 10)
## Cell plus a 2 px gap; the whole overworld map is 192 x 108 px.
const OW_PITCH := Vector2(16, 12)
const OW_TOP := 6.0
const CAVE_GRID := Vector2i(5, 5)
const CAVE_CELL := Vector2(18, 18)
const CAVE_PITCH := Vector2(22, 22)
const CAVE_TOP := 5.0
const MARK_SIZE := 4.0
const MAP_UNVISITED := Color(0.16, 0.16, 0.22)
const MAP_VISITED := Color(0.55, 0.6, 0.5)
const MAP_CURRENT := Color(1.0, 0.9, 0.4)
const MARK_MOUTH := Color(1.0, 0.55, 0.2)
const MARK_SHOP := Color(0.45, 0.75, 1.0)
## Counter columns (x of the icon centre) and rows (y of the icon centre).
const COL_KEYS := 520.0
const COL_POTS := 650.0
const COL_CAVE := 800.0
const ROW_TOP := 36.0
const ROW_BOTTOM := 86.0

# Map index, built once from WorldData. Rooms only: pockets have no cell of their own.
static var _index_ready := false
static var _cell_of: Dictionary = {}  # room id (String) -> cell in its own grid
static var _ow_rooms: Dictionary = {}  # overworld cell -> room id (StringName)
static var _cave_rooms: Dictionary = {}  # "c1" .. "c10" -> {local cell -> room id (StringName)}
static var _mouth_cave: Dictionary = {}  # cave mouth room id (StringName) -> "c1" .. "c10"
static var _shop_pocket: Dictionary = {}  # host room id (StringName) -> shop pocket id (StringName)

var canvas: Control
var _heart: PackedVector2Array


func _ready() -> void:
	layer = 10
	canvas = Control.new()
	canvas.name = "Band"
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.size = Vector2(WorldConst.SCREEN_SIZE.x, WorldConst.HUD_HEIGHT)
	add_child(canvas)
	_heart = _build_heart(HEART_SIZE)
	canvas.draw.connect(_on_draw)
	GameState.health_changed.connect(_refresh)
	GameState.currency_changed.connect(_refresh)
	GameState.keys_changed.connect(_refresh)
	GameState.pitch_pots_changed.connect(_refresh)
	GameState.active_item_changed.connect(_refresh)
	GameState.item_acquired.connect(_refresh)
	GameState.room_visited.connect(_refresh)
	GameState.flag_changed.connect(_refresh)
	# A revisited room emits no room_visited, so the minimap ring needs the entry itself.
	Events.room_entered.connect(_refresh)
	_ensure_index()
	canvas.queue_redraw()


## The minimap cell of a room: its grid cell on the overworld, or its local cell in its cave (the
## smallest x and y of the cave are 0). Vector2i(-1, -1) for pockets and unknown ids.
static func room_cell(room_id: StringName) -> Vector2i:
	_ensure_index()
	return _cell_of.get(String(room_id), Vector2i(-1, -1))


func _refresh(_a: Variant = null, _b: Variant = null) -> void:
	canvas.queue_redraw()


func _on_draw() -> void:
	canvas.draw_rect(Rect2(Vector2.ZERO, canvas.size), BAND_COLOR)
	_draw_hearts()
	_draw_counters()
	_draw_item_frame()
	_draw_minimap()


func _draw_hearts() -> void:
	var total := GameState.max_health / 2
	for i in range(total):
		var row := i / HEARTS_PER_ROW
		var col := i % HEARTS_PER_ROW
		var at := Vector2(40.0 + col * HEART_STEP, 36.0 + row * 46.0)
		var xf := Transform2D(0.0, at)
		var pts := xf * _heart
		canvas.draw_colored_polygon(pts, HEART_EMPTY)
		var filled := GameState.health - i * 2
		if filled >= 2:
			canvas.draw_colored_polygon(pts, HEART_FULL)
		elif filled == 1:
			var clip := Rect2(
				at + Vector2(-HEART_SIZE, -HEART_SIZE), Vector2(HEART_SIZE, HEART_SIZE * 2.0)
			)
			var clip_poly := PackedVector2Array(
				[
					clip.position,
					Vector2(clip.end.x, clip.position.y),
					clip.end,
					Vector2(clip.position.x, clip.end.y)
				]
			)
			for piece in Geometry2D.intersect_polygons(pts, clip_poly):
				canvas.draw_colored_polygon(piece, HEART_FULL)


func _draw_counters() -> void:
	var font := ThemeDB.fallback_font
	var scope := _scope_now()
	var keys_at := Vector2(COL_KEYS, ROW_BOTTOM)
	if not _draw_icon(&"brass_coin", Vector2(COL_KEYS, ROW_TOP), 32.0):
		canvas.draw_circle(Vector2(COL_KEYS, ROW_TOP), 14.0, Placeholder.color_of(&"brass_coin"))
	_draw_number(font, Vector2(COL_KEYS, ROW_TOP), "%d" % GameState.currency)
	if not _draw_icon(&"key", keys_at, 40.0):
		canvas.draw_rect(
			Rect2(keys_at + Vector2(-6, -16), Vector2(12, 32)), Placeholder.color_of(&"key")
		)
	_draw_number(font, keys_at, "%d" % _keys_in(scope))
	if GameState.has_item(&"pitch_pot"):
		var pot_at := Vector2(COL_POTS, ROW_TOP)
		if not _draw_icon(&"pitch_pot_bundle", pot_at, 32.0):
			canvas.draw_circle(pot_at, 14.0, Placeholder.color_of(&"pitch_pot"))
		_draw_number(font, pot_at, "%d/%d" % [GameState.pitch_pots, _pot_max()])
	if GameState.has_item(&"tallow_sling"):
		var slug_at := Vector2(COL_POTS, ROW_BOTTOM)
		if not _draw_icon(&"tallow_slug", slug_at, 32.0):
			canvas.draw_circle(slug_at, 12.0, Placeholder.color_of(&"tallow_slug"))
		_draw_number(font, slug_at, "%d" % _slugs())
	if scope.begins_with("c") and GameState.has_flag(StringName("bigkey_" + scope)):
		var big_at := Vector2(COL_CAVE, ROW_TOP)
		if not _draw_icon(&"big_key", big_at, 32.0):
			canvas.draw_circle(big_at, 12.0, Placeholder.color_of(&"big_key"))
	var fragments := _fragments()
	if fragments > 0:
		var frag_at := Vector2(COL_CAVE, ROW_BOTTOM)
		if not _draw_icon(&"fragment", frag_at, 32.0):
			canvas.draw_circle(frag_at, 12.0, Placeholder.color_of(&"fragment"))
		_draw_number(font, frag_at, "%d/%d" % [fragments, FRAGMENT_TOTAL])


## Text of a counter, right of its icon centre `at`.
func _draw_number(font: Font, at: Vector2, text: String) -> void:
	canvas.draw_string(font, at + Vector2(28, 12), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 34)


func _draw_item_frame() -> void:
	var frame := Rect2(Vector2(900, 16), Vector2(88, 88))
	canvas.draw_rect(frame, Color(0.12, 0.12, 0.18))
	canvas.draw_rect(frame, Color(0.7, 0.6, 0.35), false, 3.0)
	var id := GameState.active_item
	if id == &"":
		return
	var center := frame.get_center() + Vector2(0, -8)
	if not _draw_icon(id, center, 44.0):
		canvas.draw_circle(center, 22.0, Placeholder.color_of(id))
	var label := ItemRegistry.display_name(id)
	canvas.draw_string(
		ThemeDB.fallback_font,
		frame.position + Vector2(4, 80),
		label,
		HORIZONTAL_ALIGNMENT_CENTER,
		80,
		11
	)


## Draws the kind's HUD icon, `side` px square, centred on `center`. False when the kind has no
## art (the caller then draws its placeholder shape).
func _draw_icon(kind: StringName, center: Vector2, side: float) -> bool:
	var icon := _icon_for(kind)
	if icon == null:
		return false
	var extent := Vector2(side, side)
	canvas.draw_texture_rect(icon, Rect2(center - extent * 0.5, extent), false)
	return true


## Registered tools prefer dedicated icons; object art remains the fallback.
## Lockpick counters prefer the small HUD raster; pickup art remains the fallback.
func _icon_for(kind: StringName) -> Texture2D:
	if ItemRegistry.items.has(kind):
		var tool := SpriteVisual.icon_of(StringName("icon_" + String(kind)))
		if tool != null:
			return tool
	if kind == &"tallow_slug":
		var ammo_icon := SpriteVisual.icon_of(&"slug_bundle")
		if ammo_icon != null:
			return ammo_icon
	if kind == &"fragment":
		var fragment_icon := SpriteVisual.icon_of(&"fragment_c1")
		if fragment_icon != null:
			return fragment_icon
	if kind == &"big_key":
		var counter := SpriteVisual.icon_of(&"hud_counter_big_key")
		if counter != null:
			return counter
	return SpriteVisual.icon_of(kind)


## Keys of one scope. F4 makes keys scoped (`keys_in`); until it lands the single count is shown.
func _keys_in(scope: String) -> int:
	if GameState.has_method(&"keys_in"):
		return int(GameState.call(&"keys_in", StringName(scope)))
	return GameState.keys


## Pitch pot maximum (F5 adds `pot_max()`); the base limit until then.
func _pot_max() -> int:
	if GameState.has_method(&"pot_max"):
		return int(GameState.call(&"pot_max"))
	return GameState.PITCH_POT_MAX


## Slugs of the tallow sling (F5 adds the field); 0 until then.
func _slugs() -> int:
	var slugs: Variant = GameState.get(&"slugs")
	return int(slugs) if slugs != null else 0


## Fragments held: the flags `frag_c1` .. `frag_c9`.
func _fragments() -> int:
	var total := 0
	for n in range(1, FRAGMENT_TOTAL + 1):
		if GameState.has_flag(StringName("frag_c%d" % n)):
			total += 1
	return total


## "ow" on the overworld and "c1" .. "c10" in a cave. A pocket takes the scope of its room.
func _scope_now() -> String:
	var scope := WorldData.scope_of(String(GameState.current_room))
	return scope if scope.begins_with("c") else "ow"


func _draw_minimap() -> void:
	_ensure_index()
	var scope := _scope_now()
	var here := StringName(_host_of(String(GameState.current_room)))
	if scope.begins_with("c"):
		_draw_grid(_cave_rooms.get(scope, {}), CAVE_GRID, CAVE_PITCH, CAVE_CELL, CAVE_TOP, here)
	else:
		_draw_grid(_ow_rooms, OW_GRID, OW_PITCH, OW_CELL, OW_TOP, here)


## Draws one grid of rooms: `rooms` maps cells to room ids; a cell without a room is left blank.
func _draw_grid(
	rooms: Dictionary, grid: Vector2i, pitch: Vector2, cell: Vector2, top: float, here: StringName
) -> void:
	var origin := Vector2(MAP_RIGHT - grid.x * pitch.x, top)
	for gy in range(grid.y):
		for gx in range(grid.x):
			var at := Vector2i(gx, gy)
			if not rooms.has(at):
				continue
			var id: StringName = rooms[at]
			var rect := Rect2(origin + Vector2(gx, gy) * pitch, cell)
			var visited: bool = GameState.visited_rooms.has(id)
			canvas.draw_rect(rect, MAP_VISITED if visited else MAP_UNVISITED)
			_draw_marks(id, rect)
			if id == here:
				canvas.draw_rect(rect.grow(2.0), MAP_CURRENT, false, 2.0)


## Small marks: a visited cave mouth (top right corner) and a visited shop (bottom left corner).
func _draw_marks(id: StringName, rect: Rect2) -> void:
	if _mouth_cave.has(id) and GameState.has_flag(StringName("mouth_" + _mouth_cave[id])):
		var mouth := Rect2(rect.end.x - MARK_SIZE, rect.position.y, MARK_SIZE, MARK_SIZE)
		canvas.draw_rect(mouth, MARK_MOUTH)
	if _shop_pocket.has(id) and GameState.visited_rooms.has(_shop_pocket[id]):
		var shop := Rect2(rect.position.x, rect.end.y - MARK_SIZE, MARK_SIZE, MARK_SIZE)
		canvas.draw_rect(shop, MARK_SHOP)


## The room that holds a pocket ("ow_2_0#cache" -> "ow_2_0"); a room id is returned unchanged.
static func _host_of(id: String) -> String:
	return id.get_slice("#", 0)


static func _ensure_index() -> void:
	if _index_ready:
		return
	_index_ready = true
	var ids := WorldData.room_ids()
	var cave_min: Dictionary = {}
	for id in ids:
		var scope := WorldData.scope_of(id)
		if scope == "ow":
			continue
		var cell := WorldData.grid(id)
		var low: Vector2i = cave_min.get(scope, cell)
		cave_min[scope] = Vector2i(mini(low.x, cell.x), mini(low.y, cell.y))
	for id in ids:
		var scope := WorldData.scope_of(id)
		var cell := WorldData.grid(id)
		if scope == "ow":
			_cell_of[id] = cell
			_ow_rooms[cell] = StringName(id)
			continue
		var local: Vector2i = cell - cave_min[scope]
		_cell_of[id] = local
		if not _cave_rooms.has(scope):
			_cave_rooms[scope] = {}
		_cave_rooms[scope][local] = StringName(id)
	for pocket in WorldData.all_pockets():
		if pocket.ends_with("#shop"):
			_shop_pocket[StringName(_host_of(pocket))] = StringName(pocket)
	_read_mouths()


## The cave mouths are the `caves` records of data/world_data.json (WorldData has no accessor for them).
static func _read_mouths() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(WorldData.PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	for cave: Dictionary in parsed.get("caves", []):
		_mouth_cave[StringName(str(cave.get("mouth", "")))] = str(cave.get("scope", ""))


func _build_heart(size: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var steps := 28
	for i in range(steps):
		var t := TAU * float(i) / float(steps)
		var hx := 16.0 * pow(sin(t), 3.0)
		var hy := -(13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t))
		pts.append(Vector2(hx, hy) * (size / 34.0))
	return pts
