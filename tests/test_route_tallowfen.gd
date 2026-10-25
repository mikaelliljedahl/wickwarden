## timeout=180
extends "res://tests/test_dev_world_route.gd"
## Controlled room-entry probes, not a continuous playthrough: enemies are removed without drops.
## The natural-tool stage collects historical moth/key/pot pickups. No gate flags are forced.
## A separate, labeled late-game raft loadout probes fixed lanes without claiming C3 acquisition.
## Lake pocket probes start on their island; C3's missing raft pickup blocks earned raft travel.


func run() -> void:
	reset_state()
	world = await make_world()
	player = world.player
	await _dry_crossing()
	await _cut_pocket(&"ow_1_5", &"ow_1_5#cache", &"cache_ow_1_5_brass")
	await _cut_pocket(&"ow_5_5", &"ow_5_5#cache", &"cache_ow_5_5_brass")
	await _cut_pocket(&"ow_7_3", &"ow_7_3#grotto", &"wick_core_ow_7_3")
	await _lighthouse()
	await _tether_moth()
	await _cave_gate_and_key()
	await _locked_door_and_pitch_pot()
	await _c3_seal()
	await _raft_denial()
	await _fixed_lane_probe()
	print(
		"PENDING R4: earned raft traversal awaits C3 pickup/route; island entries above are probes"
	)
	await dispose(world)


func _door(room: Room, target: StringName) -> RoomDoor:
	for node in _props(room):
		if node is RoomDoor and node.target_room == target:
			return node
	return null


func _dry_crossing() -> void:
	var room := await _enter(&"ow_0_3")
	player.place_at(room.global_position + Vector2(1740, 480))
	Input.action_press(&"move_right")
	await seconds(1.2)
	Input.action_release(&"move_right")
	check_eq(world.get_current_room_id(), &"ow_1_3", "actual east crossing enters Reed Gate")
	room = await _enter(&"ow_4_3")
	player.place_at(room.global_position + Vector2(960, 180))
	Input.action_press(&"move_up")
	await seconds(1.0)
	Input.action_release(&"move_up")
	check_eq(world.get_current_room_id(), &"ow_4_3", "Drop Ledge cannot be climbed in reverse")


func _cut_pocket(host: StringName, target: StringName, reward: StringName) -> void:
	var room := await _enter(host)
	var door := _door(room, target)
	check(door != null, "%s has its real pocket door" % host)
	if door == null:
		return
	var blocker: Bush
	for node in _props(room):
		if node is Bush and node.position == door.position:
			blocker = node
	check(blocker != null, "%s door has its cut screen" % host)
	if blocker == null:
		return
	blocker.drops_enabled = false
	player.place_at(door.global_position)
	await frames(5)
	check_eq(world.get_current_room_id(), host, "uncut pocket does not warp on overlap")
	await _swing_at(door.global_position, Vector2.UP)
	check(not is_instance_valid(blocker) or blocker.is_cut, "real hook removes pocket screen")
	player.place_at(door.global_position)
	await seconds(1.0)
	check_eq(world.get_current_room_id(), target, "cut screen permits actual pocket entry")
	var pocket := world.get_room(target)
	if pocket == null:
		return
	var pickup := _pickup(pocket, reward)
	check(pickup != null, "%s contains its graph reward" % target)
	if pickup != null:
		var before := GameState.max_health if reward == &"wick_core_ow_7_3" else GameState.currency
		await _walk_onto(pickup)
		check(
			GameState.has_flag(StringName("picked_" + reward)), "collected pocket reward persists"
		)
		var after := GameState.max_health if reward == &"wick_core_ow_7_3" else GameState.currency
		var amount := 2 if reward == &"wick_core_ow_7_3" else 30
		check_eq(after, before + amount, "actual pocket reward changes the correct resource")
	var exit := _door(pocket, host)
	check(exit != null, "pocket has a real return door")
	if exit == null:
		return
	player.place_at(exit.global_position)
	await seconds(1.0)
	check_eq(world.get_current_room_id(), host, "pocket returns to its actual host")
	room = world.get_room(host)
	var marker := room.get_node("Spawns/FromPocket") as Marker2D
	check_near(
		player.global_position.distance_to(marker.global_position),
		0.0,
		2.0,
		"return uses FromPocket"
	)
	await _enter(&"ow_0_0")
	pocket = await _enter(target)
	check(_pickup(pocket, reward) == null, "collected reward stays absent after room reload")


func _lighthouse() -> void:
	var room := await _enter(&"ow_6_5")
	var door := _door(room, &"ow_6_5#shop")
	check(door != null, "lighthouse has S6 entrance")
	if door == null:
		return
	player.place_at(door.global_position)
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"ow_6_5#shop", "actual lighthouse door enters S6")
	var shop := world.get_room(&"ow_6_5#shop")
	var stock := _find(shop, "shop_item.gd") as Node2D
	check(stock != null, "S6 has its real flask stock")
	if stock != null:
		GameState.spend_currency(GameState.currency)
		GameState.damage(2)
		var health := GameState.health
		player.place_at(stock.global_position)
		await frames(4)
		check_eq(GameState.health, health, "unaffordable flask does not heal")
		GameState.add_currency(50)
		player.place_at(stock.global_position + Vector2(0, 110))
		await frames(4)
		player.place_at(stock.global_position)
		await frames(4)
		check_eq(GameState.health, GameState.max_health, "S6 flask heals fully")
		check_eq(GameState.currency, 0, "S6 charges exactly fifty brass")
	var exit := _door(shop, &"ow_6_5")
	player.place_at(exit.global_position)
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"ow_6_5", "S6 returns to Broken Lighthouse")


func _c3_seal() -> void:
	var room := await _enter(&"ow_3_5")
	var wall := _find(room, "cracked_wall.gd")
	check(wall != null and not wall.is_open, "C3 mouth begins bomb sealed")
	if wall == null:
		return
	await _swing_at(wall.global_position, Vector2.UP)
	check(not wall.is_open, "hook cannot open the bomb gate")
	check_eq(GameState.keys_in(&"ow"), 0, "historical scoped key was spent on the pot closet")
	check_eq(GameState.keys_in(&"c3"), 0, "R4 never grants or spends a future C3 key")
	GameState.set_active_item(&"pitch_pot")
	player.place_at(wall.global_position + Vector2(0, 82))
	player.facing = Vector2.UP
	await frames(3)
	var pots := GameState.pitch_pots
	check(player.use_item(), "collected pot tool places a real bomb at C3 seal")
	await seconds(2.0)
	check_eq(GameState.pitch_pots, pots - 1, "C3 seal costs one acquired pot")
	check(
		wall.is_open and GameState.has_flag(&"cracked_e248"), "real blast persists C3 seal opening"
	)
	await _enter(&"ow_0_0")
	room = await _enter(&"ow_3_5")
	check(_find(room, "cracked_wall.gd").is_open, "C3 mouth stays unsealed on reload")
	var door := _door(room, &"cave_3_1")
	check(door != null and door.target_spawn == &"FromOverworld", "C3 target keeps cave entry API")
	if not ResourceLoader.exists(WorldData.scene_path("cave_3_1")):
		print("PENDING R4: opened C3 mouth awaits actual cave_3_1; no substitute destination")


func _raft_denial() -> void:
	var room := await _enter(&"ow_4_3")
	check(not GameState.has_item(&"reed_raft"), "absent C3 pickup cannot silently grant raft")
	player.place_at(room.global_position + Vector2(1740, 480))
	Input.action_press(&"move_right")
	await seconds(1.0)
	Input.action_release(&"move_right")
	check_eq(
		world.get_current_room_id(), &"ow_4_3", "deep water prevents walking across raft border"
	)
	check(
		player.global_position.x < room.global_position.x + 1824, "water physically stops walking"
	)


## Separate late-game loadout probe allowed by the regional contract. This grants the raft tool
## only, never a gate/reveal/completion flag. It does not stand in for earning it in absent C3.
func _fixed_lane_probe() -> void:
	GameState.acquire_item(&"reed_raft")
	GameState.set_active_item(&"reed_raft")
	for pair in [
		[&"ow_4_3", &"ow_5_3", &"e055"],
		[&"ow_5_5", &"ow_6_5", &"e088"],
	]:
		var room := await _enter(pair[0])
		var destination := world.get_room(pair[1])
		check(destination != null, "controlled raft probe has real destination")
		if destination == null:
			continue
		for enemy in destination.get_enemies():
			(enemy as EnemyBase).drops_enabled = false
			(enemy as EnemyBase).kill()
		var post: Node2D
		for node in _props(room):
			if (
				node.get_script() != null
				and node.get_script().resource_path.ends_with("mooring.gd")
			):
				if node.get("mooring_id") == pair[2]:
					post = node
		check(post != null, "controlled raft probe uses the graph's real post")
		if post == null:
			continue
		var path: Array[Vector2] = post.call("get_ride_path")
		check(not path.is_empty(), "real mooring supplies a fixed lane")
		if path.is_empty():
			continue
		player.place_at(post.call("landing_position"))
		await frames(3)
		check(player.use_item(), "controlled loadout boards real raft through Player API")
		await seconds(0.5)
		check(player.is_external_motion(), "real raft begins external movement")
		for tick in range(1800):
			if not player.is_external_motion() and not world.is_transitioning():
				break
			await frames(1)
		check(not player.is_external_motion(), "fixed lane ride finishes")
		check_eq(world.get_current_room_id(), pair[1], "raft crosses into actual graph destination")
		check_near(
			player.global_position.distance_to(path[-1]), 0.0, 3.0, "raft lands at target post"
		)
	print("PROBE R4: two real fixed-lane raft crossings with explicit late-game tool loadout")
