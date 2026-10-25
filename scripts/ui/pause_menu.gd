class_name PauseMenu
extends CanvasLayer
## Pause menu with button help. This is the ONLY place controls are explained; never put
## tutorial text in the game world.

const TITLE := "PAUSED"
const HELP_ROWS := [
	["Move", "WASD / Arrows / Left stick"],
	["Lamp hook", "Space / J / A  (hold to charge a flare)"],
	["Use item", "E / K / X"],
	["Ward", "Shift / L / RB  (hold)"],
	["Change item", "Q / I / Y"],
	["Item menu", "Tab / Select"],
	["Equip selected item", "Enter / A  (in item menu)"],
	["Pause", "Esc / Start"],
]
const FONT_SIZE := 36

var is_open: bool = false
var _root: Control


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root = Control.new()
	_root.name = "Root"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.visible = false
	add_child(_root)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(center)
	var column := VBoxContainer.new()
	column.name = "Help"
	column.add_theme_constant_override("separation", 40)
	center.add_child(column)
	var title := Label.new()
	title.text = TITLE
	title.add_theme_font_size_override("font_size", FONT_SIZE + 12)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 64)
	grid.add_theme_constant_override("v_separation", 12)
	column.add_child(grid)
	for row: Array in HELP_ROWS:
		for text: String in row:
			var cell := Label.new()
			cell.text = text
			cell.add_theme_font_size_override("font_size", FONT_SIZE)
			grid.add_child(cell)


func _unhandled_input(event: InputEvent) -> void:
	# While the item subscreen is open, its own handler closes it on the pause key.
	if (
		event.is_action_pressed(&"pause")
		and get_tree().get_node_count_in_group(&"item_menu_open") == 0
	):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	set_open(not is_open)


func set_open(value: bool) -> void:
	is_open = value
	_root.visible = value
	get_tree().paused = value
