extends Control
## Title screen (F13, decision 14): the splash with the logo and a menu of New game, Continue and Quit.
## Continue is greyed out and skipped without a save, and it is the default selection when a save exists.
## New game over an existing save asks once (Yes/No) before it erases the slot (`pause` answers No).
## New game sets SaveGame.launch_mode `new` and goes to the intro (F14) unless the settings file says
## `intro_seen`; then it goes to world.tscn. Continue sets `continue` and goes to world.tscn. Quit quits.
## `--dev-mode` and `--start-room` skip the title (World starts in launch mode `dev`).
##
## Story text only: no button help here (the pause menu has it). The music is the overworld loop.
## Placeholder art: assets/art/title_splash.png and title_logo.png are used when they exist; until
## then a dark gradient with a drawn lamp glow and a text logo are shown.
##
## Tests set `dry_run`: the choice is recorded in `last_action` and `last_scene` and no scene changes.

const WORLD_SCENE := "res://scenes/world/world.tscn"
const INTRO_SCENE := "res://scenes/ui/intro.tscn"
const SETTINGS_PATH := "user://settings.json"
const SPLASH_PATH := "res://assets/art/title_splash.png"
const LOGO_PATH := "res://assets/art/title_logo.png"
const MENU_LIST_SCRIPT := "res://scripts/ui/menu_list.gd"
const LOGO_TEXT := "WICKWARDEN"
const LOGO_FONT := 150
const LOGO_SIZE := Vector2(960, 288)
const LOGO_COLOR := Color(0.95, 0.75, 0.35)
const COLUMN_SEPARATION := 72
const PROMPT_TEXT := "Starting a new game erases the saved game.\nErase it?"
const PROMPT_FONT := 40
const PROMPT_SEPARATION := 48
const DIM_COLOR := Color(0, 0, 0, 0.9)
const TOP_COLOR := Color(0.07, 0.07, 0.14)
const BOTTOM_COLOR := Color(0.02, 0.02, 0.05)
const BANDS := 36
const GLOW_COLOR := Color(0.95, 0.6, 0.25, 0.022)
const GLOW_RINGS := 30
const GLOW_STEP := 26.0

## Tests only: the choice is recorded (last_action, last_scene) and nothing changes scene or quits.
var dry_run: bool = false
var last_action: StringName = &""
var last_scene: String = ""

## The menu lists (menu_list.gd). Untyped: that script has no class_name.
var _menu
var _prompt_menu
var _prompt: Control
var _column: Control
var _has_splash: bool = false
var _leaving: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)
	if skips_title(OS.get_cmdline_user_args()):
		SaveGame.launch_mode = SaveGame.MODE_DEV
		call_deferred("_leave", &"dev", WORLD_SCENE)
		return
	_build()
	Audio.play_music(&"overworld")


func _unhandled_input(event: InputEvent) -> void:
	if _leaving or _menu == null:
		return
	var handled := false
	if _prompt.visible:
		handled = _prompt_menu.handle_input(event)
		if event.is_action_pressed(&"pause"):
			_close_prompt()
			handled = true
	else:
		handled = _menu.handle_input(event)
	if handled:
		get_viewport().set_input_as_handled()


func _draw() -> void:
	if _has_splash:
		return
	var area := size
	for band in BANDS:
		var t := float(band) / BANDS
		draw_rect(
			Rect2(0, area.y * t, area.x, area.y / BANDS + 1.0), TOP_COLOR.lerp(BOTTOM_COLOR, t)
		)
	var glow := Vector2(area.x * 0.5, area.y * 0.62)
	for ring in range(GLOW_RINGS, 0, -1):
		draw_circle(glow, ring * GLOW_STEP, GLOW_COLOR)


# ---- Public API ------------------------------------------------------------------------------


## True when the launch arguments start a run directly, without the title (--dev-mode, --start-room).
static func skips_title(args: PackedStringArray) -> bool:
	for arg in args:
		if arg == World.DEV_ARG or arg.begins_with(World.START_ROOM_ARG):
			return true
	return false


## True when the settings file says the intro was seen. F14 writes the flag; the title only reads it.
static func intro_seen() -> bool:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return false
	var json := JSON.new()  # the instance parser does not log a broken file as an engine error
	if json.parse(FileAccess.get_file_as_string(SETTINGS_PATH)) != OK:
		return false
	if typeof(json.data) != TYPE_DICTIONARY:
		return false
	var settings: Dictionary = json.data
	return settings.get("intro_seen", false) == true


## True while the overwrite prompt is open.
func is_prompt_open() -> bool:
	return _prompt.visible


## The main menu list and the overwrite prompt's list, for tests and captures.
func menu() -> Variant:
	return _menu


func prompt_menu() -> Variant:
	return _prompt_menu


# ---- Layout ----------------------------------------------------------------------------------


func _build() -> void:
	var splash := _load_texture(SPLASH_PATH)
	_has_splash = splash != null
	if splash != null:
		add_child(_splash_picture(splash))
	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", COLUMN_SEPARATION)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(column)
	_column = column
	column.add_child(_logo())
	_menu = _new_menu()
	var has_save := SaveGame.has_save()
	var entries := [
		{"id": &"new", "label": "New game", "enabled": true},
		{"id": &"continue", "label": "Continue", "enabled": has_save},
		{"id": &"quit", "label": "Quit", "enabled": true},
	]
	_menu.set_entries(entries)
	if has_save:
		_menu.select(&"continue")
	_menu.activated.connect(_on_menu_choice)
	column.add_child(_menu)
	_prompt = _build_prompt()
	add_child(_prompt)


func _build_prompt() -> Control:
	var prompt := Control.new()
	prompt.name = "Prompt"
	prompt.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	prompt.visible = false
	var dim := ColorRect.new()
	dim.color = DIM_COLOR
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", PROMPT_SEPARATION)
	center.add_child(box)
	var question := Label.new()
	question.text = PROMPT_TEXT
	question.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	question.add_theme_font_size_override("font_size", PROMPT_FONT)
	box.add_child(question)
	_prompt_menu = _new_menu()
	var answers := [
		{"id": &"yes", "label": "Yes", "enabled": true},
		{"id": &"no", "label": "No", "enabled": true},
	]
	_prompt_menu.set_entries(answers)
	_prompt_menu.select(&"no")
	_prompt_menu.activated.connect(_on_prompt_choice)
	box.add_child(_prompt_menu)
	return prompt


func _logo() -> Control:
	var texture := _load_texture(LOGO_PATH)
	if texture != null:
		var picture := TextureRect.new()
		picture.texture = texture
		picture.custom_minimum_size = LOGO_SIZE
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return picture
	var label := Label.new()
	label.text = LOGO_TEXT
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", LOGO_FONT)
	label.add_theme_color_override("font_color", LOGO_COLOR)
	return label


func _splash_picture(texture: Texture2D) -> TextureRect:
	var picture := TextureRect.new()
	picture.texture = texture
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return picture


func _new_menu():
	var script := load(MENU_LIST_SCRIPT) as GDScript
	return script.new()


func _load_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


# ---- Choices ---------------------------------------------------------------------------------


func _on_menu_choice(id: StringName) -> void:
	match id:
		&"new":
			_new_game()
		&"continue":
			_continue_game()
		&"quit":
			_quit()


func _on_prompt_choice(id: StringName) -> void:
	if id == &"yes":
		# A failed erase (saves disabled, file locked) still starts the new run: the first autosave
		# overwrites the slot anyway.
		SaveGame.erase()
		_begin_new_game()
	else:
		_close_prompt()


func _new_game() -> void:
	if SaveGame.has_save():
		_prompt.visible = true
		_column.visible = false
		_prompt_menu.select(&"no")
		return
	_begin_new_game()


func _begin_new_game() -> void:
	SaveGame.launch_mode = SaveGame.MODE_NEW
	var scene := WORLD_SCENE
	if not intro_seen() and ResourceLoader.exists(INTRO_SCENE):
		scene = INTRO_SCENE
	_leave(&"new", scene)


func _continue_game() -> void:
	if not SaveGame.has_save():
		return
	SaveGame.launch_mode = SaveGame.MODE_CONTINUE
	_leave(&"continue", WORLD_SCENE)


func _close_prompt() -> void:
	_prompt.visible = false
	_column.visible = true


func _quit() -> void:
	if _leaving:
		return
	_leaving = true
	last_action = &"quit"
	if not dry_run:
		get_tree().quit()


## Leaves the title for `scene`, once. A dry run only records the choice.
func _leave(action: StringName, scene: String) -> void:
	if _leaving:
		return
	_leaving = true
	last_action = action
	last_scene = scene
	if not dry_run:
		get_tree().change_scene_to_file(scene)
