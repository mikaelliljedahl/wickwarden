extends TestCase
## Sub-item API: registry, Player.use_item with a fixture item, refusal, missing scenes, cycling.

const ALL_IDS: Array[StringName] = [
	&"tether_moth",
	&"pitch_pot",
	&"cinder_wick",
	&"tallow_sling",
	&"reed_raft",
	&"heft_mitts",
	&"glow_jar",
	&"lantern_chime",
	&"skitter_boots",
	&"reel_line",
]


func run() -> void:
	await _registry()
	await _use_item()
	await _cycle_input()
	await _cycle_order()


func _registry() -> void:
	check(ItemRegistry.items.has(&"tether_moth"), "tether_moth is registered")
	check(ItemRegistry.items.has(&"pitch_pot"), "pitch_pot is registered")
	check_eq(ItemRegistry.ids(), ALL_IDS, "all ten sub-items are registered, in registry order")
	for id in ALL_IDS:
		check_eq(
			String(ItemRegistry.items[id]["scene"]),
			"res://scenes/items/%s.tscn" % id,
			"%s has its scene path" % id
		)
		check(ItemRegistry.display_name(id) != String(id), "%s has a display name" % id)
	check_eq(ItemRegistry.get_scene(&"unknown_item"), null, "unknown ids give null")
	ItemRegistry.register(&"ghost", "res://scenes/items/does_not_exist.tscn")
	check_eq(ItemRegistry.get_scene(&"ghost"), null, "a missing scene gives null, no error")
	check_eq(ItemRegistry.create(&"ghost"), null, "create() of a missing scene gives null")
	ItemRegistry.unregister(&"ghost")


func _use_item() -> void:
	reset_state()
	ItemRegistry.register(&"test_item", "res://tests/fixtures/test_item.tscn", "Test")
	var arena := make_arena()
	var player := make_player(arena, Vector2(400, 400))
	await frames(2)
	check_eq(player.use_item(), false, "no active item: nothing happens")
	GameState.acquire_item(&"ghost")
	check_eq(player.use_item(), false, "an item whose scene is missing is a silent no-op")
	GameState.reset()
	GameState.acquire_item(&"test_item")
	Input.action_press(&"move_left")
	await frames(2)
	release_inputs()
	await frames(8)
	check(player.use_item(), "an item with a scene is used")
	var items := get_tree().get_nodes_in_group(ItemBase.group_name(&"test_item"))
	check_eq(items.size(), 1, "the item instance is in its group")
	var item := items[0] as ItemBase
	check(item.player == player, "the item gets the player")
	check_eq(item.facing, Vector2.LEFT, "the item gets the facing")
	check_eq(item.get_parent(), arena, "the item is added next to the player")
	check_near(
		item.global_position.distance_to(player.global_position),
		0.0,
		0.01,
		"the item starts at the player"
	)
	check_eq(player.use_item(), false, "the item can refuse a second use (limit)")
	await frames(2)
	check_eq(
		get_tree().get_nodes_in_group(ItemBase.group_name(&"test_item")).size(),
		1,
		"a refused item is freed"
	)
	item.finish()
	await frames(2)
	check_eq(
		get_tree().get_nodes_in_group(ItemBase.group_name(&"test_item")).size(),
		0,
		"finish() frees the item"
	)
	check(player.use_item(), "usable again after the first finished")
	# Pressing the key does the same.
	GameState.reset()
	GameState.acquire_item(&"test_item")
	for node in get_tree().get_nodes_in_group(&"items"):
		node.queue_free()
	await frames(2)
	Input.action_press(&"use_item")
	await frames(3)
	Input.action_release(&"use_item")
	check_eq(
		get_tree().get_nodes_in_group(ItemBase.group_name(&"test_item")).size(),
		1,
		"use_item key activates the item"
	)
	ItemRegistry.unregister(&"test_item")
	await dispose(arena)


func _cycle_input() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(400, 400))
	await frames(2)
	GameState.acquire_item(&"tether_moth")
	GameState.acquire_item(&"pitch_pot")
	Input.action_press(&"cycle_item")
	await frames(3)
	Input.action_release(&"cycle_item")
	await frames(2)
	check_eq(GameState.active_item, &"pitch_pot", "the cycle_item key switches the active item")
	player.cycle_item()
	check_eq(GameState.active_item, &"tether_moth", "Player.cycle_item() cycles too")
	await dispose(arena)


func _cycle_order() -> void:
	# Registry order, not acquisition order: pitch pot is held first, then tether moth, cinder wick.
	reset_state()
	GameState.acquire_item(&"pitch_pot")
	GameState.acquire_item(&"tether_moth")
	GameState.acquire_item(&"cinder_wick")
	check_eq(
		GameState.acquired_item_ids(),
		[&"tether_moth", &"pitch_pot", &"cinder_wick"],
		"acquired items are listed in registry order"
	)
	GameState.cycle_item()
	check_eq(
		GameState.active_item, &"cinder_wick", "the quick switch goes to the next in registry order"
	)
	GameState.cycle_item()
	check_eq(
		GameState.active_item,
		&"tether_moth",
		"the quick switch wraps to the first in registry order"
	)
	GameState.cycle_item()
	check_eq(GameState.active_item, &"pitch_pot", "the quick switch keeps going round")
	reset_state()
