extends TestCase
## Intro (F14): the data file against the six stills of world-work-packages section 11 and against
## docs/intro-script.md, the fallback panel without art, typing speed, pauses and holds, the bounded
## length with no input, every skip key at the first, middle and last line, the end of the intro
## (intro_seen in the settings file, the world next) and the text (no button help in the game).
## Timing is driven by hand through _physics_process (the process is disabled for those steps), one
## step per 1/60 s. The skip presses go through the real InputMap.

const INTRO_SCENE := "res://scenes/ui/intro.tscn"
const INTRO_SCRIPT := "res://scripts/ui/intro.gd"
const DATA_PATH := "res://data/intro.json"
const SCRIPT_PATH := "res://docs/intro-script.md"
const ART_DIR := "res://assets/art/"
const TITLE_SCRIPT := "res://scripts/ui/title.gd"
const WORLD_SCENE := "res://scenes/world/world.tscn"
const SETTINGS := "user://settings.json"
const DELTA := 1.0 / FPS
const STEP_LIMIT := 20000
const STILL_IDS: Array[String] = [
	"intro_01_lanterns",
	"intro_02_lanternfall",
	"intro_03_dusk",
	"intro_04_tamsin",
	"intro_05_hook",
	"intro_06_setout",
]
const SKIP_KEYS: Array[StringName] = [&"confirm", &"attack", &"ui_accept", &"pause"]
const NO_SKIP_KEYS: Array[StringName] = [&"move_left", &"use_item"]
## Positions for the skip presses: still index, line index, characters typed in that line.
const POSITIONS := {
	"first line": [0, 0, 5],
	"middle line": [2, 1, 10],
	"last line": [5, 2, 10],
}


func run() -> void:
	_clean()
	_data_has_the_six_stills()
	_data_matches_the_script()
	await _fallback_without_art()
	await _text_types_line_by_line()
	await _hold_and_pause_lengths()
	await _bounded_without_input()
	await _skip_keys_end_the_intro()
	await _other_keys_do_not_skip()
	await _natural_end()
	await _skip_keeps_other_settings()
	await _no_button_help()
	_clean()


func _data_has_the_six_stills() -> void:
	var data: Variant = _read_json(DATA_PATH)
	check(data is Dictionary, "data/intro.json holds a JSON object")
	if not (data is Dictionary):
		return
	var stills: Array = data.get("stills", [])
	check_eq(stills.size(), 6, "the intro has six stills")
	for i in range(mini(stills.size(), 6)):
		var still: Dictionary = stills[i]
		check_eq(still.get("id"), STILL_IDS[i], "still %d is %s" % [i + 1, STILL_IDS[i]])
		var lines: Array = still.get("lines", [])
		check(lines.size() >= 2 and lines.size() <= 4, "still %d has 2 to 4 lines" % (i + 1))
		for line in lines:
			check(
				String(line).length() <= 70, "line of still %d is at most 70 characters" % (i + 1)
			)
		check(float(still.get("hold", 0.0)) > 0.0, "still %d has a hold" % (i + 1))


func _data_matches_the_script() -> void:
	if not FileAccess.file_exists(SCRIPT_PATH):
		return
	var expected := _parse_script(FileAccess.get_file_as_string(SCRIPT_PATH))
	var data: Variant = _read_json(DATA_PATH)
	var stills: Array = data.get("stills", []) if data is Dictionary else []
	check_eq(stills.size(), expected.size(), "data and docs/intro-script.md have the same stills")
	for i in range(mini(stills.size(), expected.size())):
		var still: Dictionary = stills[i]
		var want: Dictionary = expected[i]
		check_eq(still.get("id"), want["id"], "still %d id matches the script" % (i + 1))
		check_eq(still.get("lines"), want["lines"], "still %d lines match the script" % (i + 1))
		check_near(float(still.get("hold", 0.0)), want["hold"], 0.001, "still %d hold" % (i + 1))


func _fallback_without_art() -> void:
	reset_state()
	var intro = await _make_intro()
	check_eq(intro.still_count(), 6, "the intro builds six stills")
	for i in range(6):
		var id := STILL_IDS[i]
		var has_art := ResourceLoader.exists(ART_DIR + id + ".png")
		check_eq(
			intro.is_fallback(i), not has_art, "still %s uses the gradient when it has no art" % id
		)
	await dispose(intro)


func _text_types_line_by_line() -> void:
	reset_state()
	var intro = await _make_intro()
	intro.process_mode = Node.PROCESS_MODE_DISABLED
	check_eq(intro.phase_name(), "fading", "the first still starts with a fade")
	_step_until_phase(intro, "typing")
	check_eq(intro.still_index(), 0, "typing starts on the first still")
	check_eq(intro.typed_chars(), 0, "no character is shown when typing starts")
	_steps(intro, 16)
	check_eq(intro.typed_chars(), 6, "about 0.04 s per character: 16 frames give 6 characters")
	_steps(intro, 9)
	check_eq(intro.typed_chars(), 10, "25 frames give 10 characters")
	_step_until_phase(intro, "pausing")
	check_eq(intro.line_index(), 0, "the pause follows the first line")
	check_eq(intro.typed_chars(), 55, "the first line is complete before the pause")
	var pause := _count_phase(intro, "pausing")
	check_near(pause * DELTA, 0.5, 0.05, "the pause between lines is about half a second")
	check_eq(intro.line_index(), 1, "the second line follows the pause")
	check_eq(intro.typed_chars(), 0, "the second line starts empty")
	await dispose(intro)


func _hold_and_pause_lengths() -> void:
	reset_state()
	var intro = await _make_intro()
	intro.process_mode = Node.PROCESS_MODE_DISABLED
	_step_until_phase(intro, "holding")
	check_eq(intro.still_index(), 0, "the hold belongs to the first still")
	var held := 0
	while intro.still_index() == 0 and held < STEP_LIMIT:
		intro._physics_process(DELTA)
		held += 1
	check_near(held * DELTA, 8.0, 0.05, "the first still holds for its 8 seconds")
	check_eq(intro.still_index(), 1, "the second still follows the hold")
	await dispose(intro)


func _bounded_without_input() -> void:
	reset_state()
	var intro = await _make_intro()
	intro.process_mode = Node.PROCESS_MODE_DISABLED
	var planned: float = intro.planned_duration()
	check(planned > 60.0 and planned < 200.0, "the planned length is about 1.5 minutes")
	var steps := 0
	while not intro.is_finished() and steps < STEP_LIMIT:
		intro._physics_process(DELTA)
		steps += 1
	check(intro.is_finished(), "the intro ends by itself with no input")
	check_near(steps * DELTA, planned, 0.5, "the intro lasts the planned time")
	check_eq(intro.still_index(), 5, "the last still is the last one shown")
	await dispose(intro)


func _skip_keys_end_the_intro() -> void:
	for action in SKIP_KEYS:
		for where in POSITIONS:
			var at: Array = POSITIONS[where]
			reset_state()
			var intro = await _make_intro()
			await _drive(intro, at[0], at[1], at[2])
			check(not intro.is_finished(), "%s is still running at the %s" % [action, where])
			intro.process_mode = Node.PROCESS_MODE_INHERIT
			_send(action, true)
			await frames(2)
			_send(action, false)
			check(intro.is_finished(), "%s ends the intro at the %s" % [action, where])
			check_eq(intro.last_scene, WORLD_SCENE, "%s starts the game after the skip" % action)
			await dispose(intro)


func _other_keys_do_not_skip() -> void:
	for action in NO_SKIP_KEYS:
		reset_state()
		var intro = await _make_intro()
		await _drive(intro, 0, 0, 5)
		intro.process_mode = Node.PROCESS_MODE_INHERIT
		_send(action, true)
		await frames(3)
		_send(action, false)
		check(not intro.is_finished(), "%s does not skip the intro" % action)
		await dispose(intro)


func _natural_end() -> void:
	reset_state()
	_clean()
	var intro = await _make_intro()
	intro.process_mode = Node.PROCESS_MODE_DISABLED
	var steps := 0
	while not intro.is_finished() and steps < STEP_LIMIT:
		intro._physics_process(DELTA)
		steps += 1
	check(intro.is_finished(), "the intro ends after its last still")
	check_eq(intro.last_scene, WORLD_SCENE, "the game goes to the world after the last still")
	var title_script := load(TITLE_SCRIPT) as GDScript
	check(title_script.intro_seen(), "the title reads intro_seen as true after the intro")
	await dispose(intro)


func _skip_keeps_other_settings() -> void:
	reset_state()
	_write_settings('{"volume": 0.5}')
	var intro = await _make_intro()
	_send(&"confirm", true)
	await frames(2)
	_send(&"confirm", false)
	var settings: Variant = _read_json(SETTINGS)
	check(settings is Dictionary, "the settings file is still a JSON object")
	if settings is Dictionary:
		check_eq(settings.get("intro_seen"), true, "a skip writes intro_seen")
		check_eq(settings.get("volume"), 0.5, "the other settings keys are kept")
	await dispose(intro)
	_clean()


func _no_button_help() -> void:
	reset_state()
	var scene := load(INTRO_SCENE) as PackedScene
	var intro = scene.instantiate()
	intro.dry_run = true
	intro.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(intro)
	await frames(2)
	for text in intro.texts():
		var lower := String(text).to_lower()
		check(not lower.contains("skip"), "no skip hint in the intro text: %s" % text)
		check(not lower.contains("press"), "no press hint in the intro text: %s" % text)
		check(not lower.contains("esc"), "no key name in the intro text: %s" % text)
	await dispose(intro)


# ---- Helpers ----------------------------------------------------------------------------------


func _make_intro():
	var scene := load(INTRO_SCENE) as PackedScene
	check(scene != null, "the intro scene loads")
	var intro = scene.instantiate()
	intro.dry_run = true
	add_child(intro)
	await frames(2)
	return intro


## Steps the intro by hand until it shows `chars` characters of line `line` of still `still`.
func _drive(intro, still: int, line: int, chars: int) -> void:
	intro.process_mode = Node.PROCESS_MODE_DISABLED
	var steps := 0
	while steps < STEP_LIMIT:
		var here: bool = (
			intro.still_index() == still
			and intro.line_index() == line
			and intro.typed_chars() >= chars
		)
		if here:
			break
		intro._physics_process(DELTA)
		steps += 1
	check(steps < STEP_LIMIT, "the intro reaches still %d line %d" % [still, line])
	await frames(1)


## Sends a press or a release of `action` as the first real InputEvent bound to it in the InputMap.
## Input.action_press alone sets the action state without an event, and the intro reads events.
func _send(action: StringName, pressed: bool) -> void:
	var event := InputMap.action_get_events(action)[0].duplicate() as InputEvent
	event.set("pressed", pressed)
	if event is InputEventKey:
		(event as InputEventKey).echo = false
	Input.parse_input_event(event)


func _steps(intro, count: int) -> void:
	for i in range(count):
		intro._physics_process(DELTA)


func _step_until_phase(intro, phase: String) -> void:
	var steps := 0
	while intro.phase_name() != phase and steps < STEP_LIMIT:
		intro._physics_process(DELTA)
		steps += 1
	check(steps < STEP_LIMIT, "the intro reaches the %s phase" % phase)


func _step_until_line(intro, line: int) -> void:
	var steps := 0
	while intro.line_index() != line and steps < STEP_LIMIT:
		intro._physics_process(DELTA)
		steps += 1
	check(steps < STEP_LIMIT, "the intro reaches line %d" % line)


## Frames spent in `phase` from now until the phase changes.
func _count_phase(intro, phase: String) -> int:
	var count := 0
	while intro.phase_name() == phase and count < STEP_LIMIT:
		intro._physics_process(DELTA)
		count += 1
	return count


## Reads docs/intro-script.md: `## Still N: <id>`, the lines, then `(hold: <seconds>)`.
func _parse_script(text: String) -> Array:
	var stills: Array = []
	var current: Dictionary = {}
	for raw in text.split("\n"):
		var line := raw.strip_edges()
		if line.begins_with("## Still "):
			current = {"id": line.get_slice(": ", 1), "lines": [], "hold": 0.0}
			stills.append(current)
		elif current.is_empty():
			continue
		elif line.begins_with("(hold: "):
			current["hold"] = float(line.trim_prefix("(hold: ").trim_suffix(")"))
			current = {}
		elif line != "" and not line.begins_with("#") and not line.begins_with("|"):
			(current.get("lines", []) as Array).append(line)
	return stills


func _read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var json := JSON.new()  # the instance parser does not log a broken file as an engine error
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		return null
	return json.data


func _write_settings(text: String) -> void:
	var file := FileAccess.open(SETTINGS, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _clean() -> void:
	if FileAccess.file_exists(SETTINGS):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SETTINGS))
