class_name PauseMenu
extends CanvasLayer
## Pause menu with button help. This is the ONLY place controls are explained; never put
## tutorial text in the game world.

const HELP_TEXT := (
	"PAUSED\n\n"
	+ "Move            WASD / Arrows / Left stick\n"
	+ "Lamp hook       J / Space / A  (hold to charge a flare)\n"
	+ "Use item        K / X\n"
	+ "Ward            L / RB  (hold)\n"
	+ "Change item     I / Y\n"
	+ "Pause           Esc / Start"
)

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
	var label := Label.new()
	label.name = "Help"
	label.text = HELP_TEXT
	label.add_theme_font_size_override("font_size", 36)
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.position = Vector2(560, 300)
	_root.add_child(label)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	set_open(not is_open)


func set_open(value: bool) -> void:
	is_open = value
	_root.visible = value
	get_tree().paused = value
