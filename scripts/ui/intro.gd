extends Control
## Intro story (F14): six full-screen stills cross-fade after New game (title.gd sends the player here
## unless the settings file says `intro_seen`). The lines of each still are typed out from
## data/intro.json: about 0.04 s per character, a short pause between lines and a hold at the end of
## the still. A still without an image in assets/art/<id>.png shows a dark gradient panel instead.
##
## Any press of confirm, attack, ui_accept or pause (Esc) ends the intro at once, the first press
## included, and starts the game. After the last still the screen fades to black and the world loads.
## Either way the settings file gets `intro_seen`. No button help here: the skip hint lives only in
## the pause menu, which does not open during the intro.
##
## Timing runs in _physics_process. Skip presses are read in _unhandled_input.
##
## Tests set `dry_run`: nothing changes scene; `last_scene` records where the game goes.

const DATA_PATH := "res://data/intro.json"
const ART_DIR := "res://assets/art/"
const WORLD_SCENE := "res://scenes/world/world.tscn"
const SETTINGS_PATH := "user://settings.json"
const SKIP_ACTIONS: Array[StringName] = [&"confirm", &"attack", &"ui_accept", &"pause"]
const FADE_TIME := 1.0
const END_FADE_TIME := 1.5
const CHAR_TIME := 0.04
const LINE_PAUSE := 0.5
const TEXT_FONT := 44
const TEXT_COLOR := Color(0.95, 0.92, 0.84)
const TEXT_BAND_TOP := 0.7
const TEXT_BAND_COLOR := Color(0, 0, 0, 0.55)
const TEXT_MARGIN_SIDE := 220
const TEXT_MARGIN_BOTTOM := 110
const LINE_SEPARATION := 16
const TOP_COLOR := Color(0.07, 0.07, 0.14)
const BOTTOM_COLOR := Color(0.02, 0.02, 0.05)
const GRADIENT_SIZE := Vector2i(8, 256)

enum { FADING, TYPING, PAUSING, HOLDING, ENDING, FINISHED }
const PHASE_NAMES: Array[String] = ["fading", "typing", "pausing", "holding", "ending", "finished"]

## Tests only: nothing changes scene. last_scene records where the game goes.
var dry_run: bool = false
var last_scene: String = ""

var _stills: Array = []
var _nodes: Array[Control] = []
var _labels: Array = []
var _fallbacks: Array[bool] = []
var _overlay: ColorRect
var _index: int = 0
var _line: int = 0
var _phase: int = FADING
var _timer: float = 0.0


func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stills = _load_stills()
	if _stills.is_empty():
		push_warning("intro: no stills in %s, the intro is skipped" % DATA_PATH)
		call_deferred("_finish")
		return
	_build()


func _unhandled_input(event: InputEvent):
	if _phase == FINISHED:
		return
	for action in SKIP_ACTIONS:
		if event.is_action_pressed(action):
			get_viewport().set_input_as_handled()
			_finish()
			return


func _physics_process(delta: float):
	if _phase == FINISHED or _nodes.is_empty():
		return
	_timer += delta
	match _phase:
		FADING:
			_fade_in()
		TYPING:
			_type()
		PAUSING:
			if _timer >= LINE_PAUSE:
				_line += 1
				_timer = 0.0
				_phase = TYPING
		HOLDING:
			if _timer >= float(_stills[_index]["hold"]):
				_next_still()
		ENDING:
			_end_fade()


# ---- Public API ------------------------------------------------------------------------------


## True once the intro has ended (by the last still, or by a skip press).
func is_finished():
	return _phase == FINISHED


## Number of stills that were built (the six of data/intro.json that are valid).
func still_count():
	return _nodes.size()


func still_index():
	return _index


func line_index():
	return _line


## Name of the current phase, for tests: fading, typing, pausing, holding, ending or finished.
func phase_name():
	return PHASE_NAMES[_phase]


## Characters of the current line that are on screen.
func typed_chars():
	if _nodes.is_empty():
		return 0
	return _current_label().visible_characters


## True when the still has no image and shows the gradient panel.
func is_fallback(index: int):
	return _fallbacks[index]


## Every line text of every still, for tests (the story text only).
func texts():
	var result := PackedStringArray()
	for labels in _labels:
		for label: Label in labels:
			result.append(label.text)
	return result


## Seconds the intro takes from the first frame to the end, with no skip.
func planned_duration():
	var total := END_FADE_TIME
	for entry in _stills:
		total += FADE_TIME + float(entry["hold"])
		var lines: Array = entry["lines"]
		for line in lines:
			total += String(line).length() * CHAR_TIME
		total += (lines.size() - 1) * LINE_PAUSE
	return total


## Writes `intro_seen` to the settings file and keeps every other key.
static func mark_seen():
	var settings := {}
	if FileAccess.file_exists(SETTINGS_PATH):
		var json := JSON.new()  # the instance parser does not log a broken file as an engine error
		if json.parse(FileAccess.get_file_as_string(SETTINGS_PATH)) == OK:
			if typeof(json.data) == TYPE_DICTIONARY:
				settings = json.data
	settings["intro_seen"] = true
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("intro: cannot write %s" % SETTINGS_PATH)
		return
	file.store_string(JSON.stringify(settings, "\t"))


# ---- Data and layout -------------------------------------------------------------------------


func _load_stills():
	var stills: Array = []
	if not FileAccess.file_exists(DATA_PATH):
		return stills
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(DATA_PATH)) != OK:
		return stills
	if typeof(json.data) != TYPE_DICTIONARY:
		return stills
	var data: Dictionary = json.data
	var entries: Array = data.get("stills", [])
	for entry in entries:
		if _is_still(entry):
			stills.append(entry)
	return stills


func _is_still(entry: Variant):
	if typeof(entry) != TYPE_DICTIONARY:
		return false
	var dict: Dictionary = entry
	if typeof(dict.get("id")) != TYPE_STRING or typeof(dict.get("lines")) != TYPE_ARRAY:
		return false
	if typeof(dict.get("hold")) != TYPE_FLOAT and typeof(dict.get("hold")) != TYPE_INT:
		return false
	return not (dict["lines"] as Array).is_empty()


func _build():
	for entry: Dictionary in _stills:
		var still := Control.new()
		still.name = String(entry["id"])
		still.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		still.mouse_filter = Control.MOUSE_FILTER_IGNORE
		still.modulate.a = 0.0
		add_child(still)
		_nodes.append(still)
		still.add_child(_picture(String(entry["id"]), _fallbacks))
		_add_text(still, entry)
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)


func _picture(id: String, fallbacks: Array[bool]):
	var picture := TextureRect.new()
	var art: Texture2D = _art_for(id)
	fallbacks.append(art == null)
	picture.texture = _gradient() if art == null else art
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return picture


func _add_text(still: Control, entry: Dictionary):
	var band := ColorRect.new()
	band.color = TEXT_BAND_COLOR
	band.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	band.anchor_top = TEXT_BAND_TOP
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	still.add_child(band)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", TEXT_MARGIN_SIDE)
	margin.add_theme_constant_override("margin_right", TEXT_MARGIN_SIDE)
	margin.add_theme_constant_override("margin_bottom", TEXT_MARGIN_BOTTOM)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	still.add_child(margin)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_END
	column.add_theme_constant_override("separation", LINE_SEPARATION)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(column)
	var labels: Array[Label] = []
	for line in entry["lines"]:
		var label := Label.new()
		label.text = String(line)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.visible_characters = 0
		label.add_theme_font_size_override("font_size", TEXT_FONT)
		label.add_theme_color_override("font_color", TEXT_COLOR)
		column.add_child(label)
		labels.append(label)
	_labels.append(labels)


func _art_for(id: String):
	var path := ART_DIR + id + ".png"
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


func _gradient():
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([TOP_COLOR, BOTTOM_COLOR])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = GRADIENT_SIZE.x
	texture.height = GRADIENT_SIZE.y
	texture.fill_from = Vector2(0, 0)
	texture.fill_to = Vector2(0, 1)
	return texture


# ---- Timing ----------------------------------------------------------------------------------


func _current_label() -> Label:
	return (_labels[_index] as Array)[_line] as Label


func _fade_in():
	var k := minf(_timer / FADE_TIME, 1.0)
	_nodes[_index].modulate.a = k
	if _index > 0:
		_nodes[_index - 1].modulate.a = 1.0 - k
	if k >= 1.0:
		_timer = 0.0
		_phase = TYPING


func _type():
	var label := _current_label()
	var total := label.text.length()
	var shown := mini(int(_timer / CHAR_TIME), total)
	label.visible_characters = shown
	if shown < total:
		return
	_timer = 0.0
	var last_line := (_labels[_index] as Array).size() - 1
	_phase = PAUSING if _line < last_line else HOLDING


func _next_still():
	_timer = 0.0
	if _index + 1 < _nodes.size():
		_index += 1
		_line = 0
		_phase = FADING
	else:
		_phase = ENDING


func _end_fade():
	var k := minf(_timer / END_FADE_TIME, 1.0)
	_overlay.color.a = k
	if k >= 1.0:
		_finish()


## Ends the intro for good: the flag is written, then the world loads (unless a dry run).
func _finish():
	if _phase == FINISHED:
		return
	_phase = FINISHED
	mark_seen()
	last_scene = WORLD_SCENE
	if not dry_run:
		get_tree().change_scene_to_file(WORLD_SCENE)
