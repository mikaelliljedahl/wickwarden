extends "res://tests/test_dev_world_route.gd"
## Run the unchanged historical route first: real moth/pot pickups, braziers, key, lock and core.
## Then exercise R1 tools and doors on assembled rooms. Placement skips walking, as in the dev route.
## Cave tools are granted as an explicit later-game loadout; their source caves belong to other WPs.


func run() -> void:
	await super.run()
	reset_state()
	world = await make_world()
	player = world.player
	await _reed_gate()
	await _shop_route()
	await _thorn_border()
	await _hidden_stairs()
	await dispose(world)


func _reed_gate() -> void:
	var road := await _enter(&"ow_1_2")
	var reeds: Array[Vector2] = []
	for bush in _room_bushes(road):
		if bush is Bush and bush.variant == &"rush_wall":
			bush.drops_enabled = false
			reeds.append(bush.global_position)
	check_eq(reeds.size(), 2, "two real reed blockers fill the south gap")
	check(not GameState.has_item(&"pitch_pot"), "the base-kit route needs no pot")
	player.place_at(road.global_position + Vector2(960, 830))
	Input.action_press(&"move_down")
	await seconds(0.5)
	Input.action_release(&"move_down")
	check_eq(world.get_current_room_id(), &"ow_1_2", "uncut reeds prevent the south transition")
	check(player.position.y < road.position.y + 912, "the actual reed bodies stop the player")
	for pos in reeds:
		await _swing_at(pos, Vector2.DOWN)
	var remaining_reeds := 0
	for bush in _room_bushes(road):
		if bush.variant == &"rush_wall":
			remaining_reeds += 1
	check_eq(remaining_reeds, 0, "hook clears both real reed blockers")
	player.place_at(road.global_position + Vector2(960, 830))
	Input.action_press(&"move_down")
	await seconds(1.2)
	Input.action_release(&"move_down")
	check_eq(world.get_current_room_id(), &"ow_1_3", "the cleared reed gap leads to Reed Gate")


func _room_bushes(room: Room) -> Array[Bush]:
	var bushes: Array[Bush] = []
	for node in room.get_node("Bushes").get_children():
		if node is Bush:
			bushes.append(node)
	return bushes


func _shop_route() -> void:
	var road := await _enter(&"ow_1_2")
	var door := _find(road, "room_door.gd") as RoomDoor
	check(door != null, "Ford Road has a real shop door")
	if door == null:
		return
	player.place_at(door.global_position)
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"ow_1_2#shop", "the stall door enters S1")
	var shop := world.get_room(&"ow_1_2#shop")
	var ember: Node2D
	var pots: Node2D
	for node in _props(shop):
		if node.get_script() != null and node.get_script().resource_path.ends_with("shop_item.gd"):
			if node.get("stock") == &"ember":
				ember = node
			if node.get("stock") == &"pot_bundle":
				pots = node
	check(ember != null and pots != null, "S1 places the graph's ember and pot stock")
	if ember == null or pots == null:
		return
	check(not pots.is_offered(), "pot stock is unavailable before finding the tool")
	GameState.damage(2)
	player.place_at(ember.global_position)
	await frames(4)
	check_eq(GameState.health, 4, "no brass cannot buy an ember")
	GameState.add_currency(20)
	player.place_at(ember.global_position + Vector2(0, 100))
	await frames(3)
	player.place_at(ember.global_position)
	await frames(4)
	check_eq(GameState.health, 6, "S1 ember heals one heart")
	check_eq(GameState.currency, 12, "the actual S1 price is charged")
	# Collect the actual historical tool instead of granting it to unlock shop stock.
	await _tether_moth()
	await _cave_gate_and_key()
	await _locked_door_and_pitch_pot()
	shop = await _enter(&"ow_1_2#shop")
	for node in _props(shop):
		if node.get("stock_id") == &"pot_s1":
			pots = node
	check(pots.is_offered(), "the collected pot tool unlocks S1 stock")
	var before := GameState.pitch_pots
	player.place_at(pots.global_position)
	await frames(4)
	check_eq(GameState.pitch_pots, before + 4, "walking onto stock adds four real pots")
	check_eq(GameState.currency, 0, "S1 pot bundle costs twelve brass")
	check(GameState.has_flag(&"shop_pot_s1"), "the purchase persists")
	await _enter(&"ow_0_0")
	shop = await _enter(&"ow_1_2#shop")
	for node in _props(shop):
		if node.get("stock_id") == &"pot_s1":
			check(not node.is_offered(), "sold stock stays unavailable after reload")
	var exit := _find(shop, "room_door.gd") as RoomDoor
	player.place_at(exit.global_position)
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"ow_1_2", "S1 exit returns to Ford Road")


func _thorn_border() -> void:
	var ruin := await _enter(&"ow_2_0")
	var hedge := _find(ruin, "burnable.gd")
	check(hedge != null, "the east border has a real thorn hedge")
	if hedge == null:
		return
	player.place_at(ruin.global_position + Vector2(1740, 480))
	Input.action_press(&"move_right")
	await seconds(0.5)
	Input.action_release(&"move_right")
	check_eq(world.get_current_room_id(), &"ow_2_0", "unburned hedge prevents east travel")
	check(player.global_position.x < ruin.global_position.x + 1872, "hedge physically blocks")
	await _swing_at(hedge.global_position, Vector2.RIGHT)
	check(not hedge.is_open, "the hook cannot open the cinder-wick gate")
	GameState.acquire_item(&"cinder_wick")
	GameState.set_active_item(&"cinder_wick")
	player.place_at(hedge.global_position - Vector2(180, 0))
	player.facing = Vector2.RIGHT
	check(player.use_item(), "the player uses the real cinder wick")
	await seconds(1.8)
	check(hedge.is_open, "cinder fire burns the border hedge")
	check(GameState.has_flag(&"burned_e005"), "the graph border burn persists")
	player.place_at(ruin.global_position + Vector2(1740, 480))
	Input.action_press(&"move_right")
	await seconds(1.2)
	Input.action_release(&"move_right")
	check_eq(world.get_current_room_id(), &"ow_3_0", "burned border enters actual Thorn Gate")
	var arrival := world.get_room(&"ow_3_0")
	var counterpart := _find(arrival, "burnable.gd")
	check(counterpart != null and counterpart.is_open, "paired border hedge shares its burn flag")
	await _enter(&"ow_0_0")
	ruin = await _enter(&"ow_2_0")
	check(_find(ruin, "burnable.gd").is_open, "the hedge stays open on reload")


func _hidden_stairs() -> void:
	var stump := await _enter(&"ow_0_2")
	var seam := _find(stump, "hidden_seam.gd")
	check(seam != null, "Lamplighter's Stump has the real hidden stairs")
	if seam == null:
		return
	check(not seam.is_shown and seam.get_node_or_null("Door") == null, "unlit stairs have no door")
	await _swing_at(seam.global_position, Vector2.UP)
	check(not seam.is_shown, "a hook cannot reveal jar-only stairs")
	GameState.acquire_item(&"glow_jar")
	GameState.set_active_item(&"glow_jar")
	player.place_at(seam.global_position + Vector2(0, 250))
	player.facing = Vector2.UP
	check(player.use_item(), "the player throws the real glow jar")
	await seconds(1.8)
	check(seam.is_shown and seam.is_revealed, "jar illumination permanently reveals the stairs")
	check(GameState.has_flag(&"revealed_ow_0_2_stairs"), "the reveal is persistent")
	var door := seam.get_node_or_null("Door") as RoomDoor
	check(door != null, "illumination creates a real usable room door")
	if door != null:
		check_eq(door.target_room, &"cave_9_1", "stairs target C9 from the graph")
		check_eq(door.target_spawn, &"FromOverworld", "stairs use the contracted cave spawn")
	if not ResourceLoader.exists(WorldData.scene_path("cave_9_1")):
		print("PENDING R1: revealed C9 stairs await cave_9_1; no substitute cave or boss")
	else:
		player.place_at(seam.global_position)
		await seconds(1.0)
		check_eq(world.get_current_room_id(), &"cave_9_1", "revealed stairs enter the real C9")
	await _enter(&"ow_0_0")
	stump = await _enter(&"ow_0_2")
	seam = _find(stump, "hidden_seam.gd")
	check(seam.is_revealed and seam.get_node_or_null("Door") != null, "stairs stay usable on reload")
