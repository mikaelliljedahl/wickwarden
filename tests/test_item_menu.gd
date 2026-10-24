extends TestCase
## Item subscreen (F10): opening and closing with Tab, move keys, equip with confirm, unfound items
## that cannot be equipped, the pause key, the pause menu and the item menu blocking each other, and
## a draw of every status state. Input goes through the real InputMap as parsed events.

const MENU_SCENE := "res://scenes/ui/item_menu.tscn"
const PAUSE_SCENE := "res://scenes/ui/pause_menu.tscn"


func run() -> void:
	await _open_and_close()
	await _selection()
	await _equip()
	await _pause_interplay()
	await _status_draws()
	get_tree().paused = false


func _open_and_close() -> void:
	reset_state()
	var menu = await _make_menu()
	check(not menu.is_open, "the item menu starts closed")
	check(not get_tree().paused, "the tree runs while the item menu is closed")
	await _tap(&"item_menu")
	check(menu.is_open, "Tab (item_menu) opens the item menu")
	check(get_tree().paused, "the tree pauses while the item menu is open")
	await _tap(&"item_menu")
	check(not menu.is_open, "Tab closes it again")
	check(not get_tree().paused, "the tree runs again after closing")
	await _tap(&"item_menu")
	await _tap(&"pause")
	check(not menu.is_open, "the pause key closes the item menu")
	check(not get_tree().paused, "the tree runs after the pause key closed the item menu")
	await dispose(menu)


func _selection() -> void:
	reset_state()
	var menu = await _make_menu()
	await _tap(&"item_menu")
	var ids: Array = ItemRegistry.ids()
	check_eq(menu.item_ids(), ids, "the grid holds every registered sub-item in registry order")
	check_eq(
		menu.selected_id(), ids[0], "with nothing equipped the selection starts on the first item"
	)
	await _tap(&"move_left")
	check_eq(menu.selected_id(), ids[0], "move left at the first column stays put")
	await _tap(&"move_right")
	check_eq(menu.selected_id(), ids[1], "move right selects the next column")
	await _tap(&"move_down")
	check_eq(menu.selected_id(), ids[6], "move down goes to the same column of the second row")
	await _tap(&"move_right")
	await _tap(&"move_right")
	await _tap(&"move_right")
	check_eq(menu.selected_id(), ids[9], "move right along the second row reaches the last item")
	await _tap(&"move_right")
	check_eq(menu.selected_id(), ids[9], "move right at the last column stays put")
	await _tap(&"move_up")
	check_eq(menu.selected_id(), ids[4], "move up goes to the same column of the first row")
	await _tap(&"move_down")
	await _tap(&"move_down")
	check_eq(menu.selected_id(), ids[9], "move down on the short last row clamps to the last item")
	await _tap(&"item_menu")
	await dispose(menu)


func _equip() -> void:
	reset_state()
	GameState.acquire_item(&"tether_moth")
	GameState.acquire_item(&"glow_jar")
	var menu = await _make_menu()
	await _tap(&"item_menu")
	check_eq(menu.selected_id(), &"tether_moth", "the selection starts on the equipped item")
	check(menu.is_found(&"glow_jar"), "a held item is found")
	check(not menu.is_found(&"reel_line"), "an item not held is an unfound silhouette")
	await _tap(&"move_down")
	await _tap(&"move_right")
	check_eq(menu.selected_id(), &"glow_jar", "the selection reaches a held item")
	await _tap(&"confirm")
	check_eq(GameState.active_item, &"glow_jar", "confirm equips the selected item")
	check(not menu.is_open, "confirm closes the menu")
	check(not get_tree().paused, "the tree runs after an equip")
	await _tap(&"item_menu")
	check_eq(menu.selected_id(), &"glow_jar", "the menu reopens on the equipped item")
	await _tap(&"move_right")
	await _tap(&"move_right")
	await _tap(&"move_right")
	check_eq(menu.selected_id(), &"reel_line", "the selection reaches an unfound item")
	await _tap(&"confirm")
	check(menu.is_open, "confirm on an unfound item does nothing and keeps the menu open")
	check_eq(GameState.active_item, &"glow_jar", "an unfound item is not equipped")
	await _tap(&"pause")
	check_eq(GameState.active_item, &"glow_jar", "the pause key closes without changing the item")
	check(not menu.is_open, "the pause key closed the item menu")
	await dispose(menu)


func _pause_interplay() -> void:
	reset_state()
	var item_menu = await _make_menu()
	var pause_menu = await _make_pause()
	await _tap(&"item_menu")
	check(item_menu.is_open, "the item menu is open for the pause check")
	await _tap(&"pause")
	check(not item_menu.is_open, "the pause key closes the open item menu")
	check(
		not pause_menu.is_open, "the pause key does not open the pause menu on top of the item menu"
	)
	await _tap(&"pause")
	check(pause_menu.is_open, "the pause key opens the pause menu when no item menu is open")
	check(get_tree().paused, "the pause menu pauses the tree")
	await _tap(&"item_menu")
	check(not item_menu.is_open, "the item menu does not open while the pause menu is open")
	await _tap(&"pause")
	check(not pause_menu.is_open, "the pause key closes the pause menu")
	check(not get_tree().paused, "the tree runs after the pause menu closed")
	await dispose(pause_menu)
	await dispose(item_menu)


## Draws the screen in the states that matter: nothing found, a few found, a cave with a big key and
## fragments, and every item found. Any script error in the draw fails the suite.
func _status_draws() -> void:
	reset_state()
	GameState.mark_visited(&"cave_1_5")
	check_eq(GameState.current_scope(), &"c1", "the cave room is in scope c1")
	var menu = await _make_menu()
	await _tap(&"item_menu")
	await frames(2)
	await _tap(&"item_menu")
	GameState.add_big_key(&"c1")
	GameState.add_fragment(&"c1")
	GameState.add_fragment(&"c2")
	for id in ItemRegistry.ids():
		GameState.acquire_item(id)
	GameState.damage(3)
	await _tap(&"item_menu")
	await frames(2)
	check(menu.is_open, "the menu draws with every item, a big key and fragments")
	check(GameState.has_big_key(&"c1"), "the big key of the cave is shown as held")
	await _tap(&"item_menu")
	await dispose(menu)


func _make_menu():
	var scene := load(MENU_SCENE) as PackedScene
	check(scene != null, "the item menu scene loads")
	var menu = scene.instantiate()
	add_child(menu)
	await frames(1)
	return menu


func _make_pause():
	var scene := load(PAUSE_SCENE) as PackedScene
	var menu = scene.instantiate()
	add_child(menu)
	await frames(1)
	return menu


## Presses and releases an action through the input map (a parsed key event), then lets it dispatch.
func _tap(action: StringName) -> void:
	var press := _key_event(action, true)
	if press == null:
		check(false, "action %s has a key binding" % action)
		return
	Input.parse_input_event(press)
	await frames(2)
	Input.parse_input_event(_key_event(action, false))
	await frames(2)


func _key_event(action: StringName, pressed: bool) -> InputEventKey:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var key := (event as InputEventKey).duplicate() as InputEventKey
			key.pressed = pressed
			return key
	return null
