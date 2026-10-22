extends TestCase
## GameState arithmetic, item cycling and the input map from plan section 3.


func run() -> void:
	_health()
	_economy()
	_items()
	_flags_and_rooms()
	_input_map()


func _health() -> void:
	reset_state()
	check_eq(GameState.health, 6, "starts with 3 hearts (6 half-hearts)")
	check_eq(GameState.damage(1), false, "1 damage is not lethal")
	check_eq(GameState.health, 5, "damage is in half-hearts")
	GameState.heal(2)
	check_eq(GameState.health, 6, "heal is capped at max health")
	check_eq(GameState.damage(99), true, "lethal damage reports death")
	check_eq(GameState.health, 0, "health never goes below 0")
	GameState.add_max_heart(1)
	check_eq(GameState.max_health, 8, "wick core adds one heart")
	check_eq(GameState.health, 8, "wick core heals fully")
	for i in range(30):
		GameState.add_max_heart(1)
	check_eq(GameState.max_health, 40, "max health is capped at 20 hearts")


func _economy() -> void:
	reset_state()
	GameState.add_currency(5)
	check_eq(GameState.currency, 5, "currency adds")
	check_eq(GameState.use_key(), false, "no key to spend")
	GameState.add_key()
	check_eq(GameState.use_key(), true, "key is spent")
	check_eq(GameState.keys, 0, "key count drops")
	GameState.add_pitch_pots(25)
	check_eq(GameState.pitch_pots, 10, "pitch pots are capped at 10")
	check_eq(GameState.spend_pitch_pot(), true, "pot spent")
	check_eq(GameState.pitch_pots, 9, "pot count drops")
	GameState.reset()
	check_eq(GameState.spend_pitch_pot(), false, "no pot to spend after reset")


func _items() -> void:
	reset_state()
	check_eq(GameState.active_item, &"", "no active item at the start")
	GameState.cycle_item()
	check_eq(GameState.active_item, &"", "cycling with no items is a no-op")
	GameState.acquire_item(&"tether_moth")
	check_eq(GameState.active_item, &"tether_moth", "the first item found becomes active")
	GameState.cycle_item()
	check_eq(GameState.active_item, &"tether_moth", "cycling with one item keeps it")
	GameState.acquire_item(&"pitch_pot")
	check_eq(GameState.active_item, &"tether_moth", "a second item does not steal the slot")
	check_eq(GameState.pitch_pots, 0, "pitch pots start at 0")
	GameState.cycle_item()
	check_eq(GameState.active_item, &"pitch_pot", "cycle_item moves to the next item")
	GameState.cycle_item()
	check_eq(GameState.active_item, &"tether_moth", "cycle_item wraps")


func _flags_and_rooms() -> void:
	reset_state()
	check(not GameState.has_flag(&"door_a"), "flag unset")
	GameState.set_flag(&"door_a")
	check(GameState.has_flag(&"door_a"), "flag set")
	GameState.mark_visited(&"ow_0_0")
	check(GameState.visited_rooms.has(&"ow_0_0"), "room visited")
	check_eq(GameState.current_room, &"ow_0_0", "current room tracked")
	GameState.reset()
	check(not GameState.has_flag(&"door_a"), "reset clears flags")


func _input_map() -> void:
	var expected := {
		&"move_left": [KEY_A, KEY_LEFT],
		&"move_right": [KEY_D, KEY_RIGHT],
		&"move_up": [KEY_W, KEY_UP],
		&"move_down": [KEY_S, KEY_DOWN],
		&"attack": [KEY_J, KEY_SPACE],
		&"use_item": [KEY_E, KEY_K],
		&"ward": [KEY_SHIFT, KEY_L],
		&"cycle_item": [KEY_Q, KEY_I],
		&"pause": [KEY_ESCAPE],
	}
	for action in expected:
		check(InputMap.has_action(action), "input action %s exists" % action)
		var keys: Array = []
		var has_pad := false
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				keys.append((event as InputEventKey).physical_keycode)
			elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
				has_pad = true
		for key in expected[action]:
			check(keys.has(key), "%s is bound to key %s" % [action, OS.get_keycode_string(key)])
		check(has_pad, "%s has a gamepad binding" % action)
	var buttons := {
		&"attack": JOY_BUTTON_A, &"use_item": JOY_BUTTON_X, &"ward": JOY_BUTTON_RIGHT_SHOULDER
	}
	buttons[&"cycle_item"] = JOY_BUTTON_Y
	buttons[&"pause"] = JOY_BUTTON_START
	buttons[&"move_up"] = JOY_BUTTON_DPAD_UP
	for action in buttons:
		var found := false
		for event in InputMap.action_get_events(action):
			if (
				event is InputEventJoypadButton
				and (event as InputEventJoypadButton).button_index == buttons[action]
			):
				found = true
		check(found, "%s uses the planned gamepad button" % action)
