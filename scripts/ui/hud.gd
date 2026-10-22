class_name Hud
extends CanvasLayer
## HUD band (120 px at the top): hearts, brass / keys / pitch pots, active sub-item frame and a
## minimap of the 3x2 overworld grid. Placeholder drawing; reads GameState only.
## No tutorial text here: button help lives in the pause menu.

const BAND_COLOR := Color(0.05, 0.05, 0.08, 1.0)
const HEART_FULL := Color(0.9, 0.2, 0.25)
const HEART_EMPTY := Color(0.25, 0.1, 0.12)
const HEARTS_PER_ROW := 10
const HEART_SIZE := 34.0
const HEART_STEP := 42.0
const MAP_GRID := Vector2i(3, 2)
const MAP_CELL := Vector2(60, 42)

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
	canvas.queue_redraw()


## Parses "ow_<x>_<y>" into a grid cell; Vector2i(-1, -1) for rooms that are not on the minimap.
static func room_cell(room_id: StringName) -> Vector2i:
	var parts := String(room_id).split("_")
	if parts.size() == 3 and parts[0] == "ow":
		return Vector2i(int(parts[1]), int(parts[2]))
	return Vector2i(-1, -1)


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
	var x := 520.0
	canvas.draw_circle(Vector2(x, 36), 14.0, Placeholder.color_of(&"brass_coin"))
	canvas.draw_string(
		font, Vector2(x + 28, 48), "%d" % GameState.currency, HORIZONTAL_ALIGNMENT_LEFT, -1, 34
	)
	canvas.draw_rect(Rect2(Vector2(x - 6, 70), Vector2(12, 32)), Placeholder.color_of(&"key"))
	canvas.draw_string(
		font, Vector2(x + 28, 98), "%d" % GameState.keys, HORIZONTAL_ALIGNMENT_LEFT, -1, 34
	)
	if GameState.has_item(&"pitch_pot"):
		var px := x + 150.0
		canvas.draw_circle(Vector2(px, 36), 14.0, Placeholder.color_of(&"pitch_pot"))
		canvas.draw_string(
			font,
			Vector2(px + 28, 48),
			"%d" % GameState.pitch_pots,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			34
		)


func _draw_item_frame() -> void:
	var frame := Rect2(Vector2(900, 16), Vector2(88, 88))
	canvas.draw_rect(frame, Color(0.12, 0.12, 0.18))
	canvas.draw_rect(frame, Color(0.7, 0.6, 0.35), false, 3.0)
	var id := GameState.active_item
	if id == &"":
		return
	var color := Placeholder.color_of(id)
	canvas.draw_circle(frame.get_center() + Vector2(0, -8), 22.0, color)
	var label := ItemRegistry.display_name(id)
	canvas.draw_string(
		ThemeDB.fallback_font,
		frame.position + Vector2(4, 82),
		label.left(9),
		HORIZONTAL_ALIGNMENT_LEFT,
		80,
		14
	)


func _draw_minimap() -> void:
	var origin := Vector2(WorldConst.SCREEN_SIZE.x - 24.0 - MAP_GRID.x * (MAP_CELL.x + 6.0), 18.0)
	var current := room_cell(GameState.current_room)
	for gy in range(MAP_GRID.y):
		for gx in range(MAP_GRID.x):
			var cell := Vector2i(gx, gy)
			var rect := Rect2(
				origin + Vector2(gx * (MAP_CELL.x + 6.0), gy * (MAP_CELL.y + 6.0)), MAP_CELL
			)
			var id := StringName("ow_%d_%d" % [gx, gy])
			if GameState.visited_rooms.has(id):
				canvas.draw_rect(rect, Color(0.55, 0.6, 0.5))
			else:
				canvas.draw_rect(rect, Color(0.15, 0.15, 0.2))
			canvas.draw_rect(rect, Color(0.4, 0.4, 0.5), false, 2.0)
			if cell == current:
				canvas.draw_rect(rect.grow(3.0), Color(1.0, 0.9, 0.4), false, 4.0)
	if current == Vector2i(-1, -1) and GameState.current_room != &"":
		canvas.draw_circle(origin + Vector2(-20, 20), 8.0, Color(1.0, 0.9, 0.4))


func _build_heart(size: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var steps := 28
	for i in range(steps):
		var t := TAU * float(i) / float(steps)
		var hx := 16.0 * pow(sin(t), 3.0)
		var hy := -(13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t))
		pts.append(Vector2(hx, hy) * (size / 34.0))
	return pts
