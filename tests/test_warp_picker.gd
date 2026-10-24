extends TestCase
## Warp picker (T06): lists only mouth_cN flags, closes without warping, and selects an overworld
## mouth using the FromCave spawn marker.

const PICKER_SCENE := "res://scenes/ui/warp_picker.tscn"


func run() -> void:
	await _visited_list()
	await _cancel()
	await _warp()
	get_tree().paused = false


func _visited_list() -> void:
	reset_state()
	var picker := await _make_picker()
	GameState.set_flag(&"mouth_c2")
	GameState.set_flag(&"mouth_c8")
	var mouths: Array = picker.call("visited_mouths")
	check_eq(mouths.size(), 2, "only cave mouths with mouth_cN flags appear")
	check_eq(mouths[0]["scope"], "c2", "the list keeps cave data order")
	check_eq(mouths[0]["room"], "ow_5_1", "the list uses the cave's configured mouth room")
	check_eq(mouths[1]["scope"], "c8", "later visited caves follow in order")
	check(String(mouths[1]["label"]).contains("Trade"), "the cave label comes from world data")
	await dispose(picker)


func _cancel() -> void:
	reset_state()
	var world := await make_world()
	world.start_at(&"ow_0_0")
	GameState.set_flag(&"mouth_c1")
	GameState.set_flag(&"mouth_c3")
	var picker := await _make_picker()
	check(picker.call("open", world), "the picker opens when a mouth has been visited")
	check(get_tree().paused, "the picker pauses the game")
	picker.call("_unhandled_input", _action_event(&"move_down"))
	check_eq(picker.get("selected"), 1, "down selects the next visited mouth")
	picker.call("_unhandled_input", _action_event(&"pause"))
	await frames(2)
	check(not get_tree().paused, "closing the picker resumes the game")
	check_eq(world.get_current_room_id(), &"ow_0_0", "cancel leaves the player in the current room")
	await dispose(world)


func _warp() -> void:
	reset_state()
	var world := await make_world()
	world.start_at(&"ow_0_0")
	GameState.set_flag(&"mouth_c1")
	var picker := await _make_picker()
	check(picker.call("open", world), "the picker opens before the warp")
	if picker.get("is_open"):
		picker.call("_unhandled_input", _action_event(&"confirm"))
		await frames(45)
		check_eq(world.get_current_room_id(), &"ow_1_1", "confirm warps to the cave mouth room")
		check_near(
			world.player.global_position.distance_to(
				world.current_room.get_spawn_position(&"FromCave")
			),
			0.0,
			0.01,
			"the world warp uses the FromCave spawn marker"
		)
	await dispose(world)


func _make_picker() -> Node:
	var scene := load(PICKER_SCENE) as PackedScene
	check(scene != null, "the warp picker scene loads")
	var picker := scene.instantiate()
	add_child(picker)
	await frames(1)
	return picker


func _action_event(action: StringName) -> InputEventAction:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	return event
