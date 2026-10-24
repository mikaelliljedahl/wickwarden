extends TestCase
## GameState arithmetic, item cycling and the input map from plan section 3.


func run() -> void:
	_health()
	_economy()
	_items()
	_flags_and_rooms()
	_scoped_keys()
	_big_keys_and_fragments()
	_wallet()
	_pot_bags()
	_slugs()
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


func _scoped_keys() -> void:
	reset_state()
	GameState.add_key(2, &"c3")
	check_eq(GameState.keys_in(&"c3"), 2, "a cave key is counted in its own scope")
	check_eq(GameState.keys_in(&"ow"), 0, "and not in the overworld")
	check_eq(GameState.use_key(&"ow"), false, "a cave key does not open an overworld door")
	check_eq(GameState.use_key(&"c4"), false, "nor a door of another cave")
	check_eq(GameState.use_key(&"c3"), true, "a key of its own scope is spent")
	check_eq(GameState.keys_in(&"c3"), 1, "the count of that scope drops by one")
	GameState.mark_visited(&"cave_1_4")
	check_eq(GameState.keys, 0, "keys is the count of the current scope (c1 here)")
	GameState.add_key(1, &"c1")
	check_eq(GameState.keys, 1, "a key of the current scope is counted")
	GameState.mark_visited(&"ow_0_0")
	check_eq(GameState.keys, 0, "in an overworld room keys is the overworld count")
	check_eq(GameState.keys_in(&"c1"), 1, "the cave key is kept for its cave")
	GameState.add_key()
	check_eq(GameState.keys_in(&"ow"), 1, "add_key without a scope adds to the current scope")
	check_eq(GameState.use_key(), true, "use_key without a scope spends from the current scope")
	check_eq(GameState.use_key(), false, "and there is no second one")


func _big_keys_and_fragments() -> void:
	reset_state()
	check(not GameState.has_big_key(&"c2"), "no big key at the start")
	check(GameState.add_big_key(&"c2"), "the big key of cave 2 is added")
	check(GameState.has_big_key(&"c2"), "and it is held")
	check(GameState.has_flag(&"bigkey_c2"), "as the flag bigkey_c2")
	check(not GameState.add_big_key(&"c2"), "a second big key of the same cave is refused")
	check(not GameState.add_big_key(&"ow"), "a big key needs a cave scope")
	check(GameState.add_fragment(&"c1"), "the fragment of cave 1 is added")
	check(GameState.has_flag(&"frag_c1"), "as the flag frag_c1")
	check(not GameState.add_fragment(&"c10"), "the Ninth Hollow gives no fragment")
	check(not GameState.has_fragment(&"c10"), "so none is held for it")
	check(GameState.add_fragment(&"c9"), "the fragment of cave 9 is added")
	check_eq(GameState.fragment_count(), 2, "two fragments are held")
	for number in range(2, 10):
		GameState.add_fragment(StringName("c%d" % number))
	check_eq(GameState.fragment_count(), 9, "all nine fragments are held")
	GameState.reset()
	check_eq(GameState.fragment_count(), 0, "reset clears the fragments")
	check(not GameState.has_big_key(&"c2"), "and the big keys")


func _wallet() -> void:
	reset_state()
	GameState.add_currency(5000)
	check_eq(GameState.currency, GameState.WALLET_CAP, "the wallet is capped at 999 brass")
	check_eq(GameState.WALLET_CAP, 999, "the cap is 999")
	check(GameState.spend_currency(999), "a purchase of the whole wallet is paid")
	check_eq(GameState.currency, 0, "and the wallet is empty")
	check(not GameState.spend_currency(1), "a purchase above the wallet is refused")
	GameState.add_currency(7)
	check(not GameState.spend_currency(8), "a price above the wallet is refused")
	check_eq(GameState.currency, 7, "and nothing is spent")
	check(not GameState.spend_currency(-1), "a negative price is refused")
	check(GameState.spend_currency(7), "a price within the wallet is paid")
	check_eq(GameState.currency, 0, "the wallet is empty again")


func _pot_bags() -> void:
	reset_state()
	check_eq(GameState.pot_max(), 10, "the pitch pot limit starts at 10")
	check(GameState.add_pot_bag(), "the first pot bag is taken")
	check(GameState.has_flag(&"pot_bag_1"), "as flag pot_bag_1")
	check_eq(GameState.pot_max(), 14, "the first bag raises the limit to 14")
	GameState.add_pitch_pots(25)
	check_eq(GameState.pitch_pots, 14, "pitch pots are capped at 14")
	check(GameState.add_pot_bag(), "the second pot bag is taken")
	check(GameState.has_flag(&"pot_bag_2"), "as flag pot_bag_2")
	check_eq(GameState.pot_max(), 18, "the second bag raises the limit to 18")
	check(not GameState.add_pot_bag(), "a third pot bag is refused")
	check_eq(GameState.pot_max(), 18, "and the limit stays at 18")
	GameState.add_pitch_pots(25)
	check_eq(GameState.pitch_pots, 18, "pitch pots are capped at 18")
	GameState.reset()
	check_eq(GameState.pot_max(), 10, "reset takes the bags back")


func _slugs() -> void:
	reset_state()
	check_eq(GameState.slugs, 0, "no slugs before the sling is found")
	check(not GameState.spend_slug(), "no slug to spend")
	GameState.acquire_item(&"tallow_sling")
	check_eq(GameState.slugs, 12, "the first pickup of the sling gives 12 slugs")
	GameState.acquire_item(&"tallow_sling")
	check_eq(GameState.slugs, 12, "a second pickup of the sling gives no more")
	check_eq(GameState.slug_max(), 30, "the slug maximum is 30")
	GameState.add_slugs(6)
	check_eq(GameState.slugs, 18, "a slug bundle adds its 6")
	GameState.add_slugs(50)
	check_eq(GameState.slugs, 30, "slugs are capped at 30")
	check(GameState.spend_slug(), "a slug is spent")
	check_eq(GameState.slugs, 29, "the count drops by one")
	GameState.add_slugs(-100)
	check_eq(GameState.slugs, 0, "slugs never go below 0")
	check(not GameState.spend_slug(), "and an empty sling spends nothing")
	GameState.add_slugs(3)
	GameState.reset()
	check_eq(GameState.slugs, 0, "reset clears the slugs")


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
