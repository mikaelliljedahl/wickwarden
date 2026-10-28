extends TestCase
## E1: real player overlap, final-boss gating, exclusive choice, persistence, coda and title routing.
## Add --ending-captures in a rendered run to save the actual frames to /tmp/wickwarden-e1-*.png.

const TRIGGER := "res://scenes/world/ending_trigger.tscn"
const SEQUENCE := "res://scenes/ui/ending.tscn"
const TITLE := "res://scenes/ui/title.tscn"
const ACTIONS_SKIP: Array[StringName] = [&"confirm", &"attack", &"ui_accept", &"pause"]


func run() -> void:
	await _choice_stands()
	await _lazy_reload()
	await _gating_and_choice()
	await _both_codas()
	await _skip_and_back()
	await _persistence_and_continue()
	await _unauthorized_entry()
	reset_state()


func _choice_stands() -> void:
	for missing in [false, true]:
		for flag_first in [false, true]:
			reset_state()
			if flag_first:
				GameState.set_flag(&"boss_cave_10_14_defeated")
			# The public test-manifest API simulates missing art without changing runtime files.
			if missing:
				SpriteVisual.use_manifest("res://tests/fixtures/no_ending_art.json")
			var trigger = _instantiate(TRIGGER)
			trigger.dry_run = true
			trigger.position = Vector2(960, 480)
			add_child(trigger)
			check_eq(trigger._zones.size(), 2, "both choice zones exist immediately")
			if not flag_first:
				check_eq(trigger.get_node("Visual").get_child_count(), 0, "presentation stays lazy")
				check(not trigger.get_node("Visual").visible, "presentation starts hidden")
				GameState.set_flag(&"boss_cave_10_14_defeated")
				check(not trigger.is_available(), "new boss flag retains death fade")
				check(not trigger.get_node("Visual").visible, "presentation remains hidden during fade")
				var count: int = trigger.get_node("Visual").get_child_count()
				GameState.set_flag(&"boss_cave_10_14_defeated", false)
				GameState.set_flag(&"boss_cave_10_14_defeated")
				check_eq(trigger.get_node("Visual").get_child_count(), count, "presentation builds once")
			else:
				check(trigger.is_available(), "existing boss flag presents choice immediately")
			for choice in [&"rekindle", &"wickwarden"]:
				var kind := StringName("arena_lantern_%s" % choice)
				var painted := SpriteVisual.has_art(kind)
				check_eq(
					painted, not missing, "%s painted availability in missing=%s" % [choice, missing]
				)
				var stand: Node = trigger.get_node_or_null("Visual/FallbackPedestal_%s" % choice)
				check_eq(
					stand != null, missing, "%s has a separate stand only without painted art" % choice
				)
				var visual: Node = trigger.get_node("Visual/Lantern_%s/Visual" % choice)
				check_eq(
					visual is SpriteVisual,
					not missing,
					"%s uses the actual painted or fallback visual" % choice
				)
			await _capture("choice-fallback" if missing else "choice-painted")
			await dispose(trigger)
			SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)


func _lazy_reload() -> void:
	reset_state()
	SaveGame.enabled = true
	SaveGame.launch_mode = SaveGame.MODE_NEW
	SaveGame.erase()
	GameState.set_flag(&"boss_cave_10_14_defeated")
	check(SaveGame.save(), "boss-defeated slot saves")
	GameState.reset()
	check(SaveGame.load_into_state(), "boss-defeated slot reloads")
	var trigger = _instantiate(TRIGGER)
	trigger.dry_run = true
	add_child(trigger)
	check(trigger.is_available(), "reloaded boss flag shows choice without another fade")
	check(trigger.get_node("Visual").visible, "reloaded presentation is visible immediately")
	check(trigger.get_node_or_null("Visual/Lantern_rekindle/Visual") != null, "reloaded left lamp exists")
	check(trigger.get_node_or_null("Visual/Lantern_wickwarden/Visual") != null, "reloaded right lamp exists")
	await dispose(trigger)
	SaveGame.erase()
	SaveGame.enabled = false
	SaveGame.launch_mode = SaveGame.MODE_DEV


func _gating_and_choice() -> void:
	for choice in [&"rekindle", &"wickwarden"]:
		reset_state()
		var arena := make_arena()
		var trigger = _instantiate(TRIGGER)
		trigger.dry_run = true
		trigger.position = Vector2(960, 480)
		arena.add_child(trigger)
		var at := Vector2(768, 480) if choice == &"rekindle" else Vector2(1152, 480)
		var player := make_player(arena, at)
		await frames(4)
		check(not trigger.is_available(), "choice is inert before the final boss flag")
		check(not trigger.choose(choice), "overlap cannot bypass the boss")
		GameState.set_flag(&"boss_cave_9_10_defeated")
		check(not trigger.is_available(), "another boss cannot enable ending")
		GameState.set_flag(&"boss_cave_10_14_defeated")
		check(not trigger.is_available(), "choice waits for the final boss death fade")
		await seconds(2.1)
		check(trigger.is_available(), "final boss flag enables choice after death fade")
		await _capture("choice-%s" % choice)
		check(not trigger.choose(&"unknown"), "unknown choice is rejected")
		player.place_at(Vector2(960, 800))
		await frames(4)
		check(not trigger.choose(choice), "confirm away from both pedestals does nothing")
		player.place_at(at)
		await frames(4)
		Input.action_press(&"confirm")
		await frames(2)
		Input.action_release(&"confirm")
		check(GameState.has_flag(StringName("ending_%s" % choice)), "real confirm commits choice")
		check_eq(trigger.last_scene, SEQUENCE, "choice starts ending sequence")
		check(not trigger.choose(choice), "choice cannot run twice")
		var other := &"wickwarden" if choice == &"rekindle" else &"rekindle"
		check(not GameState.has_flag(StringName("ending_%s" % other)), "other choice stays unset")
		await dispose(arena)
		var reentered = _instantiate(TRIGGER)
		reentered.dry_run = true
		add_child(reentered)
		check(not reentered.is_available(), "reentering completed arena never repeats choice")
		await dispose(reentered)


func _both_codas() -> void:
	for choice in [&"rekindle", &"wickwarden"]:
		reset_state()
		_set_choice(choice)
		var ending = _instantiate(SEQUENCE)
		ending.dry_run = true
		ending.set_physics_process(false)
		add_child(ending)
		check_eq(ending.choice, choice, "correct branch is loaded")
		check(GameState.has_flag(&"completed"), "completion is marked")
		ending._physics_process(1.0)
		ending._physics_process(0.4)
		check_eq(ending._labels[0].visible_characters, 10, "coda types at intro speed")
		check_eq(ending._labels[1].visible_characters, 0, "later lines wait")
		for step in range(3600):
			ending._physics_process(1.0 / FPS)
			if ending.phase == ending.Phase.HOLD:
				break
		check_eq(ending.phase, ending.Phase.HOLD, "all lines finish before the hold")
		await _capture("coda-%s" % choice)
		ending._physics_process(8.0)
		check_eq(ending.phase, ending.Phase.CREDITS, "coda leads to credits")
		await _capture("credits-%s" % choice)
		ending._physics_process(8.0)
		check_eq(ending.last_scene, TITLE, "natural credits finish at title")
		await dispose(ending)


func _skip_and_back() -> void:
	for action in ACTIONS_SKIP:
		reset_state()
		_set_choice(&"wickwarden")
		var ending = _instantiate(SEQUENCE)
		ending.dry_run = true
		add_child(ending)
		_send(ending, action)
		check_eq(ending.phase, ending.Phase.CREDITS, "%s skips to credits" % action)
		check_eq(ending.last_scene, "", "first skip preserves the credits card")
		_send(ending, action, true)
		check_eq(ending.last_scene, "", "key repeat cannot dismiss credits")
		_send(ending, action)
		check_eq(ending.last_scene, TITLE, "%s returns from credits" % action)
		await dispose(ending)


func _persistence_and_continue() -> void:
	reset_state()
	SaveGame.enabled = true
	SaveGame.launch_mode = SaveGame.MODE_NEW
	SaveGame.erase()
	GameState.mark_visited(&"ow_10_8")
	SaveGame.checkpoint = &"ow_10_8"
	GameState.mark_visited(&"cave_10_14")
	GameState.add_currency(41)
	_set_choice(&"rekindle")
	var ending = _instantiate(SEQUENCE)
	ending.dry_run = true
	add_child(ending)
	check(SaveGame.has_save(), "ending writes a valid slot")
	await dispose(ending)
	GameState.reset()
	check(SaveGame.load_into_state(), "completed slot reloads")
	check(GameState.has_flag(&"completed"), "completed persists")
	check(GameState.has_flag(&"ending_rekindle"), "branch persists")
	check(GameState.has_flag(&"boss_cave_10_14_defeated"), "final defeat persists")
	check_eq(GameState.currency, 41, "inventory survives completion")
	check_eq(SaveGame.resume_room(), &"ow_10_8", "Continue resumes last checkpoint")
	var title = _instantiate(TITLE)
	title.dry_run = true
	add_child(title)
	title._on_menu_choice(&"continue")
	check_eq(title.last_scene, "res://scenes/world/world.tscn", "completed Continue starts World")
	check_eq(SaveGame.launch_mode, SaveGame.MODE_CONTINUE, "Continue uses real load mode")
	await _capture("title-continue")
	await dispose(title)
	SaveGame.erase()
	SaveGame.enabled = false
	SaveGame.launch_mode = SaveGame.MODE_DEV


func _unauthorized_entry() -> void:
	reset_state()
	var ending = _instantiate(SEQUENCE)
	ending.dry_run = true
	add_child(ending)
	await frames(2)
	check(not GameState.has_flag(&"completed"), "direct scene entry cannot complete the game")
	check_eq(ending.last_scene, TITLE, "invalid entry returns safely to title")
	await dispose(ending)


func _set_choice(choice: StringName) -> void:
	GameState.set_flag(&"boss_cave_10_14_defeated")
	GameState.set_flag(StringName("ending_%s" % choice))


func _instantiate(path: String):
	var scene := load(path) as PackedScene
	check(scene != null, "%s loads" % path)
	return scene.instantiate()


func _send(ending: Control, action: StringName, echo: bool = false) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	if echo:
		var key := InputEventKey.new()
		key.keycode = KEY_ENTER
		key.pressed = true
		key.echo = true
		ending._unhandled_input(key)
	else:
		ending._unhandled_input(event)


func _capture(tag: String) -> void:
	if (
		DisplayServer.get_name() == "headless"
		or not "--ending-captures" in OS.get_cmdline_user_args()
	):
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var path := "/tmp/wickwarden-e1-%s.png" % tag
	check_eq(get_viewport().get_texture().get_image().save_png(path), OK, "capture %s" % tag)
