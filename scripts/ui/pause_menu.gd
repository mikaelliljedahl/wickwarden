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
const RETURN_TO_TITLE_META := &"pause_return_to_title"
const TITLE_SCENE := "res://scenes/ui/title.tscn"
const SELECT_COLOR := Color(1.0, 0.85, 0.4)
const TEXT_COLOR := Color(0.92, 0.88, 0.78)

var is_open: bool = false
var _root: Control
var _buttons: Array[Button] = []
var _selected := 0
var _error: Label
## Test hook: perform the save but record the destination without changing the test scene.
var dry_run := false
var last_scene := ""


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

	var choices := HBoxContainer.new()
	choices.alignment = BoxContainer.ALIGNMENT_CENTER
	choices.add_theme_constant_override("separation", 80)
	column.add_child(choices)
	for text in ["Resume", "Back to title"]:
		var button := Button.new()
		button.text = text
		button.focus_mode = Control.FOCUS_NONE
		button.flat = true
		button.add_theme_font_size_override("font_size", FONT_SIZE)
		var index := _buttons.size()
		button.mouse_entered.connect(_select.bind(index))
		button.pressed.connect(_activate.bind(index))
		choices.add_child(button)
		_buttons.append(button)
	_error = Label.new()
	_error.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_error.add_theme_font_size_override("font_size", 26)
	column.add_child(_error)
	_select(0)


func _unhandled_input(event: InputEvent) -> void:
	# While the item subscreen is open, its own handler closes it on the pause key.
	if (
		event.is_action_pressed(&"pause")
		and get_tree().get_node_count_in_group(&"item_menu_open") == 0
	):
		toggle()
		get_viewport().set_input_as_handled()
	elif is_open:
		if event.is_action_pressed(&"move_left", true) or event.is_action_pressed(&"move_up", true):
			_select(posmod(_selected - 1, _buttons.size()))
		elif event.is_action_pressed(&"move_right", true) or event.is_action_pressed(&"move_down", true):
			_select(posmod(_selected + 1, _buttons.size()))
		elif event.is_action_pressed(&"confirm") or event.is_action_pressed(&"ui_accept"):
			_activate(_selected)
		else:
			return
		get_viewport().set_input_as_handled()


func toggle() -> void:
	set_open(not is_open)


func set_open(value: bool) -> void:
	is_open = value
	_root.visible = value
	get_tree().paused = value
	if value:
		_error.text = ""
		_select(0)


func _select(index: int) -> void:
	_selected = index
	for i in _buttons.size():
		var color := SELECT_COLOR if i == index else TEXT_COLOR
		_buttons[i].add_theme_color_override("font_color", color)
		_buttons[i].add_theme_color_override("font_hover_color", color)
		_buttons[i].add_theme_color_override("font_pressed_color", color)
		_buttons[i].text = ("> " if i == index else "") + (["Resume", "Back to title"][i])


func _activate(index: int) -> void:
	if index == 0:
		set_open(false)
		return
	var scene := load(TITLE_SCENE) as PackedScene
	if scene == null:
		_error.text = "Could not open the title screen."
		return
	# Flush the current run, including a debounced autosave, before leaving it.
	if SaveGame.enabled and SaveGame.launch_mode != SaveGame.MODE_DEV and not SaveGame.save():
		_error.text = "Could not save. Please try again."
		return
	last_scene = TITLE_SCENE
	if dry_run:
		return
	get_tree().root.set_meta(RETURN_TO_TITLE_META, true)
	get_tree().paused = false
	if get_tree().change_scene_to_packed(scene) != OK:
		get_tree().root.remove_meta(RETURN_TO_TITLE_META)
		get_tree().paused = true
		_error.text = "Could not open the title screen."
