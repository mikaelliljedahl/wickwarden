extends Control
## The chosen coda types one line at a time, then shows credits and returns to the title.
## Confirm or Esc skips the coda to credits; a fresh press on credits returns to title.
## Completion uses the existing persistent flag API. Continue resumes the last checkpoint.

const TITLE_SCENE := "res://scenes/ui/title.tscn"
const DATA_PATH := "res://data/ending.json"
const CHAR_TIME := 0.04
const LINE_PAUSE := 0.5
const FADE_TIME := 1.0
const SKIP_ACTIONS: Array[StringName] = [&"confirm", &"attack", &"ui_accept", &"pause"]

enum Phase { FADE, TYPING, PAUSE, HOLD, CREDITS, FINISHED }

var dry_run: bool = false
var last_scene: String = ""
var choice: StringName = &""
var phase: Phase = Phase.FADE
var fallback: bool = true
var _data: Dictionary = {}
var _entry: Dictionary = {}
var _labels: Array[Label] = []
var _picture: TextureRect
var _story: Control
var _credits: Control
var _timer: float = 0.0
var _line: int = 0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if GameState.has_flag(&"ending_rekindle"):
		choice = &"rekindle"
	elif GameState.has_flag(&"ending_wickwarden"):
		choice = &"wickwarden"
	if not GameState.has_flag(&"boss_cave_10_14_defeated") or choice == &"":
		call_deferred("_return_to_title")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if not parsed is Dictionary or not parsed.get(String(choice)) is Dictionary:
		push_warning("Ending: story data is missing")
		call_deferred("_return_to_title")
		return
	_data = parsed
	_entry = _data[String(choice)]
	_build()
	# SaveGame already persists all flags and resumes current_room. Do not erase the slot.
	GameState.set_flag(&"completed")
	GameState.mark_visited(SaveGame.checkpoint_room())
	SaveGame.save()


func _physics_process(delta: float) -> void:
	if phase == Phase.FINISHED or _labels.is_empty():
		return
	_timer += delta
	match phase:
		Phase.FADE:
			_story.modulate.a = minf(_timer / FADE_TIME, 1.0)
			if _timer >= FADE_TIME:
				_enter(Phase.TYPING)
		Phase.TYPING:
			var label := _labels[_line]
			label.visible_characters = mini(int(_timer / CHAR_TIME), label.text.length())
			if label.visible_characters == label.text.length():
				_enter(Phase.PAUSE if _line + 1 < _labels.size() else Phase.HOLD)
		Phase.PAUSE:
			if _timer >= LINE_PAUSE:
				_line += 1
				_enter(Phase.TYPING)
		Phase.HOLD:
			if _timer >= float(_entry.get("hold", 8)):
				show_credits()
		Phase.CREDITS:
			if _timer >= float(_data.get("credits_hold", 8)):
				_return_to_title()


func _unhandled_input(event: InputEvent) -> void:
	if phase == Phase.FINISHED or event.is_echo():
		return
	for action in SKIP_ACTIONS:
		if event.is_action_pressed(action):
			var viewport := get_viewport()
			viewport.set_input_as_handled()
			if phase == Phase.CREDITS:
				_return_to_title()
			else:
				show_credits()
			return


func show_credits() -> void:
	if phase == Phase.FINISHED or _credits == null:
		return
	_story.hide()
	_credits.show()
	_enter(Phase.CREDITS)


func _return_to_title() -> void:
	if phase == Phase.FINISHED:
		return
	_enter(Phase.FINISHED)
	last_scene = TITLE_SCENE
	if not dry_run:
		get_tree().paused = false
		var scene := load(TITLE_SCENE) as PackedScene
		if scene != null:
			get_tree().change_scene_to_packed(scene)


func _enter(next: Phase) -> void:
	phase = next
	_timer = 0.0


func _build() -> void:
	var background := ColorRect.new()
	background.color = Color(0.025, 0.03, 0.055)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	_story = Control.new()
	_story.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_story.modulate.a = 0.0
	add_child(_story)
	_picture = TextureRect.new()
	var id := String(_entry["id"])
	var texture: Texture2D = SpriteVisual.icon_of(StringName(id))
	var path := "res://assets/art/%s.png" % id
	if texture == null and ResourceLoader.exists(path):
		texture = load(path) as Texture2D
	fallback = texture == null
	if texture == null:
		var gradient := Gradient.new()
		gradient.colors = PackedColorArray([Color(0.18, 0.14, 0.22), Color(0.035, 0.05, 0.09)])
		var panel := GradientTexture2D.new()
		panel.gradient = gradient
		panel.fill_to = Vector2(0, 1)
		texture = panel
	_picture.texture = texture
	_picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_story.add_child(_picture)
	var band := ColorRect.new()
	band.color = Color(0, 0, 0, 0.65)
	band.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	band.anchor_top = 0.68
	_story.add_child(band)
	var column := _column(_story, 0.7, 0.94)
	for line in _entry.get("lines", []):
		var label := _label(String(line), 44)
		label.visible_characters = 0
		column.add_child(label)
		_labels.append(label)
	_credits = Control.new()
	_credits.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_credits)
	var credits_column := _column(_credits, 0.25, 0.75)
	for line in _data.get("credits", []):
		credits_column.add_child(_label(String(line), 52))
	_credits.hide()


func _column(parent: Control, top: float, bottom: float) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.anchor_left = 0.08
	column.anchor_right = 0.92
	column.anchor_top = top
	column.anchor_bottom = bottom
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 22)
	parent.add_child(column)
	return column


func _label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.95, 0.92, 0.84))
	return label
