extends CanvasLayer
## Pause-style list of cave mouths Tamsin has visited. Selecting one returns to that overworld room
## at its FromCave marker. The picker never adds help text; button guidance stays in PauseMenu.

const TITLE := "CAVE MOUTHS"
const DATA_PATH := "res://data/world_data.json"
const BACKDROP := Color(0.015, 0.02, 0.035, 0.92)
const PANEL := Color(0.08, 0.09, 0.12, 0.98)
const FRAME := Color(0.62, 0.52, 0.31)
const HIGHLIGHT := Color(0.93, 0.78, 0.39)
const TEXT := Color(0.94, 0.9, 0.78)
const MUTED := Color(0.55, 0.57, 0.6)
const ROW_HEIGHT := 68.0
const MAX_ROWS := 10

signal closed

var is_open: bool = false
var selected: int = 0
var entries: Array[Dictionary] = []
var _world: World
var _canvas: Control


func _ready() -> void:
	layer = 31
	process_mode = Node.PROCESS_MODE_ALWAYS
	_canvas = Control.new()
	_canvas.name = "Canvas"
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.visible = false
	_canvas.draw.connect(_draw_picker)
	add_child(_canvas)


func open(world: World) -> bool:
	if world == null or world.phase != World.Phase.NONE or get_tree().paused:
		return false
	_world = world
	entries = visited_mouths()
	if entries.is_empty():
		return false
	selected = 0
	is_open = true
	add_to_group(&"warp_picker_open")
	_canvas.visible = true
	get_tree().paused = true
	_canvas.queue_redraw()
	return true


func visited_mouths() -> Array[Dictionary]:
	var mouths: Array[Dictionary] = []
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return mouths
	var caves: Variant = (parsed as Dictionary).get("caves", [])
	if not caves is Array:
		return mouths
	for cave_variant in caves:
		if typeof(cave_variant) != TYPE_DICTIONARY:
			continue
		var cave: Dictionary = cave_variant
		var scope := str(cave.get("scope", ""))
		var mouth := str(cave.get("mouth", ""))
		if scope == "" or mouth == "" or not GameState.has_flag(StringName("mouth_%s" % scope)):
			continue
		var number := int(cave.get("number", 0))
		var lantern := str(cave.get("lantern", ""))
		var label := "Cave %d" % number
		if lantern != "" and lantern != "null":
			label += "  ·  %s" % lantern
		elif number == 9:
			label += "  ·  Corrow's Workshop"
		mouths.append({"scope": scope, "room": mouth, "flag": "mouth_%s" % scope, "label": label})
	return mouths


func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"use_item"):
		_close()
	elif event.is_action_pressed(&"confirm"):
		_warp_selected()
	elif event.is_action_pressed(&"move_up", true):
		_move(-1)
	elif event.is_action_pressed(&"move_down", true):
		_move(1)
	else:
		return
	get_viewport().set_input_as_handled()


func _move(step: int) -> void:
	if entries.is_empty():
		return
	selected = posmod(selected + step, entries.size())
	_canvas.queue_redraw()


func _close() -> void:
	is_open = false
	remove_from_group(&"warp_picker_open")
	_canvas.visible = false
	get_tree().paused = false
	closed.emit()
	queue_free()


func _warp_selected() -> void:
	if selected < 0 or selected >= entries.size():
		_close()
		return
	var room_id := StringName(str(entries[selected].get("room", "")))
	var world := _world
	_close()
	if is_instance_valid(world) and room_id != &"":
		world.warp_to(room_id, &"FromCave", true)


func _draw_picker() -> void:
	var area := _canvas.size
	_canvas.draw_rect(Rect2(Vector2.ZERO, area), BACKDROP)
	var rows := mini(entries.size(), MAX_ROWS)
	var panel_height := 188.0 + rows * ROW_HEIGHT
	var panel := Rect2(
		Vector2(area.x * 0.29, (area.y - panel_height) / 2.0), Vector2(area.x * 0.42, panel_height)
	)
	_canvas.draw_rect(panel, PANEL)
	_canvas.draw_rect(panel, FRAME, false, 4.0)
	var font := ThemeDB.fallback_font
	_canvas.draw_string(
		font,
		Vector2(panel.position.x, panel.position.y + 88.0),
		TITLE,
		HORIZONTAL_ALIGNMENT_CENTER,
		panel.size.x,
		54,
		TEXT
	)
	if entries.is_empty():
		_canvas.draw_string(
			font,
			Vector2(panel.position.x, panel.position.y + 154.0),
			"No visited mouths",
			HORIZONTAL_ALIGNMENT_CENTER,
			panel.size.x,
			32,
			MUTED
		)
		return
	for index in rows:
		var row_top := panel.position.y + 120.0 + float(index) * ROW_HEIGHT
		var rect := Rect2(panel.position.x + 38.0, row_top, panel.size.x - 76.0, ROW_HEIGHT - 4.0)
		var color := HIGHLIGHT if index == selected else TEXT
		if index == selected:
			_canvas.draw_rect(rect, Color(0.52, 0.4, 0.17, 0.32))
			_canvas.draw_rect(rect, HIGHLIGHT, false, 2.0)
		_canvas.draw_string(
			font,
			Vector2(rect.position.x + 24.0, rect.position.y + 45.0),
			str(entries[index].get("label", "")),
			HORIZONTAL_ALIGNMENT_LEFT,
			rect.size.x - 48.0,
			34,
			color
		)
