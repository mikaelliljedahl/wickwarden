## timeout=180
extends TestCase
## Controlled north-bank start; real movement, tools, enemies and damage thereafter.
var world: World
var player: Player


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	GameState.acquire_item(&"reel_line")
	GameState.add_key(1, &"c10")
	GameState.set_active_item(&"reel_line")
	GameState.add_max_heart(17)
	world = await make_world()
	world.start_at(&"cave_10_10")
	player = world.player
	var room := world.get_room(&"cave_10_10")
	player.place_at(room.global_position + Vector2(1008, 192))
	await frames(3)
	Input.action_press(&"move_down")
	await frames(1)
	Input.action_release(&"move_down")
	Input.action_press(&"use_item")
	await frames(1)
	Input.action_release(&"use_item")
	await seconds(2)
	check((player.global_position - room.global_position).distance_to(Vector2(1008, 648)) < 15,
		"real reel reaches south landing")
	await walk(Vector2(720, 624))
	await walk(Vector2(720, 528))
	await walk(Vector2(240, 528))
	Input.action_press(&"move_left")
	for i in range(240):
		if world.get_current_room_id() == &"cave_10_11":
			break
		await frames(1)
	Input.action_release(&"move_left")
	check_eq(world.get_current_room_id(), &"cave_10_11", "walk through actual e242")
	check_eq(GameState.keys_in(&"c10"), 0, "e242 consumes the fixture key")
	await walk(Vector2(1008, 336))
	check(GameState.has_flag(&"picked_key_c10_3"), "walk collects real third key")
	await dispose(world)
	await ward_probe()
	SaveGame.enabled = false


func ward_probe() -> void:
	reset_state()
	GameState.acquire_item(&"reel_line")
	GameState.set_active_item(&"reel_line")
	GameState.add_max_heart(17)
	world = await make_world()
	world.start_at(&"cave_10_10")
	player = world.player
	var room := world.get_room(&"cave_10_10")
	player.place_at(room.global_position + Vector2(1008, 192))
	await frames(3)
	Input.action_press(&"move_down")
	await frames(1)
	Input.action_release(&"move_down")
	Input.action_press(&"use_item")
	await frames(1)
	Input.action_release(&"use_item")
	await seconds(2)
	var hound: EnemyBase
	for enemy in room.get_enemies():
		if enemy.scene_file_path.ends_with("husk_hound.tscn"):
			hound = enemy
	check(is_instance_valid(hound) and hound.hp > 0, "actual hound is present and alive")
	if not is_instance_valid(hound) or hound.hp <= 0:
		await dispose(world)
		return
	for i in range(600):
		if not is_instance_valid(hound) or hound.hp <= 0:
			break
		var d := hound.global_position - player.global_position
		if abs(d.x) > abs(d.y):
			player.facing = Vector2.RIGHT if d.x > 0 else Vector2.LEFT
		else:
			player.facing = Vector2.DOWN if d.y > 0 else Vector2.UP
		if i % 30 == 0:
			Input.action_press(&"attack")
		elif i % 30 == 2:
			Input.action_release(&"attack")
		await frames(1)
	Input.action_release(&"attack")
	check(not is_instance_valid(hound) or hound.hp <= 0, "hook defeats active hound")
	await walk(Vector2(816, 624))
	await walk(Vector2(816, 816))
	Input.action_press(&"move_left")
	await seconds(1)
	Input.action_release(&"move_left")
	check((player.global_position - room.global_position).x > 690,
		"closed ward blocker physically prevents entry")
	check_eq(world.get_current_room_id(), &"cave_10_10", "closed cache cannot be entered")
	await walk(Vector2(816, 624))
	await walk(Vector2(1104, 624))
	# Ward plate receives real shots, with the hound and damage active.
	Input.action_press(&"move_right")
	await frames(1)
	Input.action_release(&"move_right")
	Input.action_press(&"ward")
	for i in range(1200):
		if GameState.has_flag(&"ward_e259"):
			break
		await frames(1)
	Input.action_release(&"ward")
	check(GameState.has_flag(&"ward_e259"), "real ward opens cache")
	await walk(Vector2(816, 624))
	await walk(Vector2(816, 816))
	await walk(Vector2(624, 816))
	await walk(Vector2(624, 720))
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_10_10#ward", "walk into ward cache")
	await walk(Vector2(1008, 336))
	check(GameState.has_flag(&"picked_cache_cave_10_10_ward_brass"), "collect ward cache")
	await walk(Vector2(912, 720))
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_10_10", "walk back from cache")
	room = world.get_room(&"cave_10_10")
	await walk(Vector2(240, 480))
	Input.action_press(&"move_left")
	await seconds(1)
	Input.action_release(&"move_left")
	check_eq(world.get_current_room_id(), &"cave_10_10", "e242 blocks without a key")
	check(not GameState.has_flag(&"door_e242"), "no e242 unlock without a key")
	await walk(Vector2(720, 528))
	await walk(Vector2(720, 624))
	await walk(Vector2(1008, 624))
	Input.action_press(&"move_up")
	await frames(1)
	Input.action_release(&"move_up")
	Input.action_press(&"use_item")
	await frames(1)
	Input.action_release(&"use_item")
	await seconds(2)
	check((player.global_position - room.global_position).distance_to(Vector2(1008, 216)) < 15,
		"real return reel reaches north bank")
	await dispose(world)
	SaveGame.enabled = false


func walk(target: Vector2) -> void:
	var room := world.get_room(world.get_current_room_id())
	var room_id := room.room_id
	for i in range(500):
		if world.get_current_room_id() != room_id:
			break
		var diff := target - (player.global_position - room.global_position)
		if diff.length() < 9:
			break
		release_inputs()
		if abs(diff.x) > 6:
			Input.action_press(&"move_right" if diff.x > 0 else &"move_left")
		if abs(diff.y) > 6:
			Input.action_press(&"move_down" if diff.y > 0 else &"move_up")
		await frames(1)
	release_inputs()
	if world.get_current_room_id() == room_id:
		check((target - (player.global_position - room.global_position)).length() < 15,
			"walk to %s in %s (at %s)" % [target, room.room_id,
			player.global_position - room.global_position])
