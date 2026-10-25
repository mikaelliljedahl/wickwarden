extends TestCase
## Title screen (F13): the menu list (move keys with wrap-around, disabled entries skipped, confirm),
## the menu entries with and without a save, the overwrite prompt, the scene flow of New game,
## Continue and Quit, the intro flag in the settings file, and the launch arguments that skip the
## title. Input goes through the real InputMap as key events.

const MENU_LIST := "res://scripts/ui/menu_list.gd"
const TITLE_SCENE := "res://scenes/ui/title.tscn"
const SLOT := "user://save_1.json"
const BAD := "user://save_1.bad"
const TEMP := "user://save_1.json.tmp"
const SETTINGS := "user://settings.json"
const TITLE_SCRIPT := "res://scripts/ui/title.gd"
const INTRO_SCENE := "res://scenes/ui/intro.tscn"
const WORLD_SCENE := "res://scenes/world/world.tscn"


func run() -> void:
	_clean()
	await _menu_list()
	await _keys_reach_the_menu_list()
	await _nothing_else_is_handled()
	await _menu_without_save()
	await _menu_with_save()
	await _overwrite_prompt()
	await _detached_title_consumes_confirm()
	await _new_game_without_save()
	await _new_game_plays_the_intro_every_time()
	await _continue_with_save()
	await _continue_loads_the_save()
	await _new_game_resets_the_state()
	await _quit()
	await _title_music()
	_intro_flag_and_launch_arguments()
	_clean()
	SaveGame.enabled = false
	SaveGame.launch_mode = SaveGame.MODE_DEV


func _menu_list() -> void:
	var menu = _make_list()
	(
		menu
		. set_entries(
			[
				{"id": &"a", "label": "A", "enabled": true},
				{"id": &"b", "label": "B", "enabled": false},
				{"id": &"c", "label": "C", "enabled": true},
			]
		)
	)
	check_eq(menu.ids(), [&"a", &"b", &"c"], "the list keeps every entry in order")
	check_eq(menu.selected_id(), &"a", "the first enabled entry is selected")
	menu.move(1)
	check_eq(menu.selected_id(), &"c", "move next skips the disabled entry")
	menu.move(1)
	check_eq(menu.selected_id(), &"a", "move next wraps from the last entry to the first")
	menu.move(-1)
	check_eq(menu.selected_id(), &"c", "move previous wraps from the first entry to the last")
	check(menu.select(&"a"), "an enabled entry can be selected")
	check(not menu.select(&"b"), "a disabled entry cannot be selected")
	check_eq(menu.selected_id(), &"a", "a refused selection changes nothing")
	check(not menu.select(&"zz"), "an unknown entry cannot be selected")
	menu.set_enabled(&"a", false)
	check_eq(menu.selected_id(), &"c", "disabling the selection moves to the next enabled entry")
	menu.set_enabled(&"c", false)
	check_eq(menu.selected_id(), &"", "with every entry disabled nothing is selected")
	menu.move(1)
	check_eq(menu.selected_id(), &"", "moving with no enabled entry keeps nothing selected")
	menu.set_enabled(&"b", true)
	check_eq(menu.selected_id(), &"b", "enabling an entry selects it when nothing else is")
	check(menu.is_enabled(&"b") and not menu.is_enabled(&"a"), "is_enabled reads the state")
	menu.queue_free()
	await frames(2)


func _keys_reach_the_menu_list() -> void:
	var menu = _make_list()
	(
		menu
		. set_entries(
			[
				{"id": &"first", "label": "First", "enabled": true},
				{"id": &"second", "label": "Second", "enabled": true},
			]
		)
	)
	var chosen: Array[StringName] = []
	menu.activated.connect(func(id: StringName) -> void: chosen.append(id))
	check(menu.handle_input(_key(&"move_down")), "move down is a menu key")
	check_eq(menu.selected_id(), &"second", "move down selects the next entry")
	check(menu.handle_input(_key(&"move_right")), "move right is a menu key too")
	check_eq(menu.selected_id(), &"first", "move right wraps to the first entry")
	check(menu.handle_input(_key(&"move_up")), "move up is a menu key")
	check_eq(menu.selected_id(), &"second", "move up wraps to the last entry")
	check(menu.handle_input(_key(&"move_left")), "move left is a menu key too")
	check(menu.handle_input(_key(&"confirm")), "confirm is a menu key")
	check_eq(chosen, [&"first"], "confirm activates the selected entry once")
	menu.queue_free()
	await frames(2)


func _nothing_else_is_handled() -> void:
	var menu = _make_list()
	menu.set_entries([{"id": &"only", "label": "Only", "enabled": true}])
	check(not menu.handle_input(_key(&"attack")), "an unrelated action is not consumed")
	check(not menu.handle_input(_key(&"pause")), "pause is not consumed by the list")
	menu.queue_free()
	await frames(2)


func _menu_without_save() -> void:
	_clean()
	reset_state()
	var title = await _make_title()
	var menu = title.menu()
	check_eq(
		menu.ids(), [&"new", &"continue", &"quit"], "the title has New game, Continue and Quit"
	)
	check(not menu.is_enabled(&"continue"), "Continue is greyed out without a save")
	check_eq(menu.selected_id(), &"new", "New game is selected without a save")
	await _tap(&"move_down")
	check_eq(menu.selected_id(), &"quit", "move down skips the disabled Continue")
	await _tap(&"move_down")
	check_eq(menu.selected_id(), &"new", "move down wraps from Quit to New game")
	await _tap(&"move_up")
	check_eq(menu.selected_id(), &"quit", "move up wraps from New game to Quit")
	await _tap(&"move_left")
	check_eq(menu.selected_id(), &"new", "move left goes to the previous entry")
	await _tap(&"move_right")
	check_eq(menu.selected_id(), &"quit", "move right goes to the next entry")
	check(not title.is_prompt_open(), "no prompt is open at the start")
	await dispose(title)


func _menu_with_save() -> void:
	_clean()
	_write_save()
	var title = await _make_title()
	var menu = title.menu()
	check(menu.is_enabled(&"continue"), "Continue is enabled with a save")
	check_eq(menu.selected_id(), &"continue", "Continue is the selection when a save exists")
	await _tap(&"move_down")
	check_eq(menu.selected_id(), &"quit", "move down from Continue reaches Quit")
	await _tap(&"move_up")
	await _tap(&"move_up")
	check_eq(menu.selected_id(), &"new", "move up from Continue reaches New game")
	await dispose(title)
	_clean()


func _overwrite_prompt() -> void:
	_clean()
	_write_save()
	var title = await _make_title()
	await _tap(&"move_up")
	check_eq(title.menu().selected_id(), &"new", "New game is selected over a save")
	await _tap(&"confirm")
	check(title.is_prompt_open(), "New game over a save asks first")
	check_eq(title.prompt_menu().selected_id(), &"no", "the prompt starts on No")
	check_eq(title.last_action, &"", "nothing starts before the answer")
	await _tap(&"pause")
	check(not title.is_prompt_open(), "pause answers No and closes the prompt")
	check(SaveGame.has_save(), "No keeps the save")
	check_eq(title.last_action, &"", "No starts nothing")
	await _tap(&"confirm")
	await _tap(&"move_up")
	check_eq(title.prompt_menu().selected_id(), &"yes", "move up on the prompt selects Yes")
	SaveGame.enabled = true
	await _tap(&"confirm")
	SaveGame.enabled = false
	check(not SaveGame.has_save(), "Yes erases the saved game")
	check_eq(title.last_action, &"new", "Yes starts a new game")
	check_eq(title.last_scene, INTRO_SCENE, "New game over a save goes to the intro first")
	check_eq(SaveGame.launch_mode, SaveGame.MODE_NEW, "New game sets launch mode new")
	await dispose(title)


## Scene changes detach the title synchronously inside the menu's activated signal. Keep the
## runner alive while reproducing that lifecycle for both New game and Continue.
func _detached_title_consumes_confirm() -> void:
	for has_save in [false, true]:
		_clean()
		if has_save:
			_write_save()
		var title = await _make_title()
		var viewport := title.get_viewport() as Viewport
		title.menu().activated.connect(func(_id: StringName) -> void: remove_child(title))
		title._unhandled_input(_key(&"confirm"))
		check(not title.is_inside_tree(), "confirm detaches the title during activation")
		check(viewport.is_input_handled(), "the original viewport consumes the transition input")
		check_eq(
			title.last_action,
			&"continue" if has_save else &"new",
			"the detached title records the requested transition"
		)
		title.free()
	_clean()


func _new_game_without_save() -> void:
	_clean()
	reset_state()
	var title = await _make_title()
	await _tap(&"confirm")
	check(not title.is_prompt_open(), "New game without a save asks nothing")
	check_eq(title.last_action, &"new", "New game is recorded")
	check_eq(title.last_scene, INTRO_SCENE, "New game goes to the intro first")
	check_eq(SaveGame.launch_mode, SaveGame.MODE_NEW, "New game sets launch mode new")
	await dispose(title)


## Decision 44: the intro plays on every New game, even when the settings file says it was seen.
func _new_game_plays_the_intro_every_time() -> void:
	_clean()
	reset_state()
	_write_settings('{"intro_seen": true}')
	var title = await _make_title()
	await _tap(&"confirm")
	check_eq(title.last_scene, INTRO_SCENE, "intro_seen does not skip the intro on New game")
	check_eq(title.last_action, &"new", "New game is recorded with intro_seen set")
	await dispose(title)
	_clean()


func _continue_with_save() -> void:
	_clean()
	_write_save()
	var title = await _make_title()
	await _tap(&"confirm")
	check_eq(title.last_action, &"continue", "Continue is recorded")
	check_eq(title.last_scene, WORLD_SCENE, "Continue goes to the world")
	check_eq(SaveGame.launch_mode, SaveGame.MODE_CONTINUE, "Continue sets launch mode continue")
	await dispose(title)
	_clean()


func _continue_loads_the_save() -> void:
	_clean()
	_write_save()
	reset_state()
	check(not GameState.has_item(&"tether_moth"), "the state is empty before Continue")
	var title = await _make_title()
	await _tap(&"confirm")
	var world := await make_world()
	check(GameState.has_item(&"tether_moth"), "Continue loads the saved items into the world")
	check_eq(GameState.health, 4, "Continue loads the saved health")
	await dispose(world)
	await dispose(title)
	SaveGame.launch_mode = SaveGame.MODE_DEV
	_clean()


func _new_game_resets_the_state() -> void:
	_clean()
	_write_save()
	reset_state()
	GameState.acquire_item(&"glow_jar")
	var title = await _make_title()
	await _tap(&"move_up")
	await _tap(&"confirm")
	check(title.is_prompt_open(), "New game over a save asks first")
	check(GameState.has_item(&"glow_jar"), "the prompt does not touch the state yet")
	await _tap(&"move_up")
	SaveGame.enabled = true
	await _tap(&"confirm")
	SaveGame.enabled = false
	var world := await make_world()
	check(not GameState.has_item(&"tether_moth"), "New game clears the saved items")
	check(not GameState.has_item(&"glow_jar"), "New game clears the state of the session")
	check_eq(GameState.health, GameState.max_health, "New game starts at full health")
	await dispose(world)
	await dispose(title)
	SaveGame.launch_mode = SaveGame.MODE_DEV
	_clean()


func _quit() -> void:
	reset_state()
	var title = await _make_title()
	await _tap(&"move_down")
	await _tap(&"confirm")
	check_eq(title.last_action, &"quit", "Quit is recorded and quits (no scene change)")
	check_eq(title.last_scene, "", "Quit changes no scene")
	await dispose(title)


func _title_music() -> void:
	reset_state()
	var title = await _make_title()
	check_eq(Audio.current_music, &"overworld", "the title plays the overworld music")
	await dispose(title)


func _intro_flag_and_launch_arguments() -> void:
	var script := load(TITLE_SCRIPT) as GDScript
	check(script != null, "the title script loads")
	_write_settings("{}")
	check(not script.intro_seen(), "no intro flag in the settings: the intro is not seen")
	_write_settings('{"intro_seen": true}')
	check(script.intro_seen(), "intro_seen in the settings file is read")
	_write_settings('{"intro_seen": false}')
	check(not script.intro_seen(), "intro_seen false is not seen")
	_write_settings("not json")
	check(not script.intro_seen(), "a broken settings file counts as not seen")
	_clean()
	check(not script.intro_seen(), "a missing settings file counts as not seen")
	check(script.skips_title(PackedStringArray(["--dev-mode"])), "--dev-mode skips the title")
	check(
		script.skips_title(PackedStringArray(["--start-room=ow_1_1:Default"])),
		"--start-room skips the title"
	)
	check(not script.skips_title(PackedStringArray([])), "no arguments: the title shows")
	check(
		not script.skips_title(PackedStringArray(["--test=res://tests/test_title.gd"])),
		"the test argument does not skip the title"
	)


# ---- Helpers ----------------------------------------------------------------------------------


func _make_title():
	var scene := load(TITLE_SCENE) as PackedScene
	check(scene != null, "the title scene loads")
	var title = scene.instantiate()
	title.dry_run = true
	add_child(title)
	await frames(6)
	return title


## A slot with a little run in it, written while saves are enabled, then disabled again.
func _write_save() -> void:
	SaveGame.enabled = true
	reset_state()
	SaveGame.begin_new_game()
	GameState.acquire_item(&"tether_moth")
	GameState.damage(GameState.health - 4)
	SaveGame.save()
	SaveGame.enabled = false
	reset_state()


func _write_settings(text: String) -> void:
	var file := FileAccess.open(SETTINGS, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _clean() -> void:
	for path in [SLOT, BAD, TEMP, SETTINGS]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


## Presses and releases `action` through the real InputMap.
func _tap(action: StringName) -> void:
	var press := _key(action)
	Input.parse_input_event(press)
	await frames(2)
	var release := press.duplicate() as InputEventKey
	release.pressed = false
	Input.parse_input_event(release)
	await frames(2)


func _make_list():
	var script := load(MENU_LIST) as GDScript
	check(script != null, "the menu list script loads")
	var menu = script.new()
	add_child(menu)
	return menu


## A pressed key event for the first keyboard key bound to `action`, or an empty press when none.
func _key(action: StringName) -> InputEventKey:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var press := (event as InputEventKey).duplicate() as InputEventKey
			press.pressed = true
			press.echo = false
			return press
	check(false, "action %s has a key binding" % action)
	return InputEventKey.new()
