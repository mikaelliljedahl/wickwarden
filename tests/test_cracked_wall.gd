extends TestCase
## Cracked wall: a real pitch pot blast opens it when in range, leaves it closed when out of range,
## and the persistent flag keeps it open on a later visit.

const WALL_SCENE := "res://scenes/world/cracked_wall.tscn"


func run() -> void:
	await _blast_opens_and_flags()
	await _fresh_visit_stays_open()
	await _preloaded_pair()
	await _c03_mouth_round_trip()


## Builds a cracked wall (untyped: the script has no class_name, so it is a plain Node here).
func _make_wall(parent: Node, id: StringName, at: Vector2) -> Variant:
	var scene := load(WALL_SCENE) as PackedScene
	var wall: Node = scene.instantiate()
	wall.set(&"wall_id", id)
	parent.add_child(wall)
	(wall as Node2D).global_position = at
	return wall


func _blast_opens_and_flags() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(400, 400))
	await frames(2)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"pitch_pot")
	GameState.add_pitch_pots(1)
	# The pot lands at (496, 400). `near` is 100 px from it (in range), `far` ~180 px (out of range).
	var near: Variant = _make_wall(arena, &"test_near", Vector2(644, 400))
	var far: Variant = _make_wall(arena, &"test_far", Vector2(644, 600))
	await frames(2)
	check(not near.is_open and not far.is_open, "cracked walls start closed")
	check(near.is_in_group(&"explodable"), "a cracked wall is in group explodable")
	check(player.use_item(), "the pot is placed")
	await seconds(1.9)
	check(near.is_open, "a blast in range opens the wall")
	check(not far.is_open, "a blast out of range leaves the wall closed")
	check(GameState.has_flag(&"cracked_test_near"), "opening sets the cracked_<id> flag")
	check(not GameState.has_flag(&"cracked_test_far"), "a closed wall sets no flag")
	check(not near.is_in_group(&"explodable"), "an open wall is no longer explodable")
	check((near.get_node("Shape") as CollisionShape2D).disabled, "an open wall has no collision")
	check(not (far.get_node("Shape") as CollisionShape2D).disabled, "a closed wall keeps collision")
	await dispose(arena)


func _fresh_visit_stays_open() -> void:
	reset_state()
	GameState.set_flag(&"cracked_test_again")
	var arena := make_arena()
	var wall: Variant = _make_wall(arena, &"test_again", Vector2(644, 400))
	await frames(2)
	check(wall.is_open, "the flag makes a later visit start with the wall open")
	check((wall.get_node("Shape") as CollisionShape2D).disabled, "a reopened wall has no collision")
	await dispose(arena)


func _preloaded_pair() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(400, 400))
	player.set_hurtbox_enabled(self, false)
	var source = _make_wall(arena, &"paired_blast", Vector2(644, 400))
	var peer = _make_wall(arena, &"paired_blast", Vector2(1200, 400))
	peer.process_mode = Node.PROCESS_MODE_DISABLED
	var unrelated = _make_wall(arena, &"other_blast", Vector2(1400, 400))
	var anonymous = _make_wall(arena, &"", Vector2(1600, 400))
	await frames(2)
	GameState.set_flag(&"cracked_unrelated")
	GameState.set_flag(&"cracked_paired_blast", false)
	GameState.flag_changed.emit(&"cracked_paired_blast", false)
	GameState.set_flag(&"cracked_")
	check(not source.is_open and not peer.is_open, "false/unrelated flags leave pair shut")
	check(not anonymous.is_open, "empty wall id never subscribes to anonymous flag")
	var signals_seen := {"flags": 0, "explosions": 0}
	var on_flag := func(flag: StringName, value: bool) -> void:
		if value and flag == &"cracked_paired_blast":
			signals_seen["flags"] += 1
	var on_blast := func(_at: Vector2, _radius: float) -> void: signals_seen["explosions"] += 1
	GameState.flag_changed.connect(on_flag)
	Events.explosion.connect(on_blast)
	GameState.acquire_item(&"pitch_pot")
	GameState.set_active_item(&"pitch_pot")
	GameState.add_pitch_pots(2)
	player.facing = Vector2.RIGHT
	check(player.use_item(), "actual source pot placed for loaded pair")
	await seconds(1.9)
	check(
		source.is_open and peer.is_open, "blast opens source and processing-disabled distant peer"
	)
	check(not unrelated.is_open, "unrelated wall id stays closed")
	check(peer.get_node("Shape").disabled, "disabled peer's collision actually clears")
	check(not peer.get_node("Visual").visible, "disabled peer's visual actually hides")
	check(not peer.is_in_group(&"explodable"), "peer cannot receive another blast")
	check_eq(GameState.pitch_pots, 1, "pair costs only one actual pot")
	check_eq(signals_seen["flags"], 1, "canonical true flag emitted once")
	check_eq(signals_seen["explosions"], 1, "peer emits no second explosion")
	GameState.flag_changed.emit(&"cracked_paired_blast", true)
	GameState.flag_changed.emit(&"cracked_paired_blast", false)
	await frames(2)
	check(peer.is_open and source.is_open, "duplicate true/false notifications cannot reclose pair")
	check_eq(GameState.pitch_pots, 1, "duplicate restore spends no ammo")
	GameState.flag_changed.disconnect(on_flag)
	Events.explosion.disconnect(on_blast)
	var peer_callback := Callable(peer, "_on_flag_changed")
	check(GameState.flag_changed.is_connected(peer_callback), "peer has live flag subscription")
	peer.free()
	check(
		not GameState.flag_changed.is_connected(peer_callback), "freeing peer cleans subscription"
	)
	GameState.flag_changed.emit(&"cracked_paired_blast", true)
	await dispose(arena)


func _wall_in(room: Room) -> Node2D:
	for node in room.get_node("Props").get_children():
		var script: Script = node.get_script()
		if script != null and script.resource_path == "res://scripts/world/cracked_wall.gd":
			return node
	return null


func _c03_mouth_round_trip() -> void:
	reset_state()
	SaveGame.enabled = false
	var world := await make_world()
	world.start_at(&"ow_3_5")
	var outside := world.get_room(&"ow_3_5")
	var inside := world.get_room(&"cave_3_1")
	check(inside != null, "actual C03 entrance scene delivered")
	if inside == null:
		await dispose(world)
		return
	var source = _wall_in(outside)
	var peer = _wall_in(inside)
	check(source != null and peer != null, "actual e248 has both room endpoints")
	if source == null or peer == null:
		await dispose(world)
		return
	check(not inside.can_process(), "C03 endpoint is preloaded with processing disabled")
	var player := world.player
	player.set_hurtbox_enabled(self, false)
	for room in [outside, inside]:
		for enemy in room.get_enemies():
			enemy.drops_enabled = false
			enemy.kill()
	await frames(3)
	player.place_at(source.global_position + Vector2(0, 100))
	player.facing = Vector2.UP
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	await frames(12)
	check(not source.is_open and not peer.is_open, "actual hook cannot open either bomb endpoint")
	GameState.acquire_item(&"cinder_wick")
	GameState.set_active_item(&"cinder_wick")
	player.place_at(source.global_position + Vector2(0, 200))
	player.facing = Vector2.UP
	check(player.use_item(), "real flame launches at bomb mouth")
	await seconds(1.7)
	check(not source.is_open and not peer.is_open, "actual flame cannot open bomb mouth")
	for node in outside.get_node("Props").get_children():
		if node is RoomDoor and node.target_room == &"cave_3_1":
			check(not node._gate_is_open(), "bomb mouth remains concealed before actual pot")
	GameState.acquire_item(&"pitch_pot")
	GameState.set_active_item(&"pitch_pot")
	GameState.add_pitch_pots(2)
	player.place_at(source.global_position + Vector2(0, 160))
	player.facing = Vector2.UP
	check(player.use_item(), "real acquired pot placed at actual e248")
	await seconds(1.9)
	check(GameState.has_flag(&"cracked_e248"), "actual blast sets canonical e248 flag")
	check(source.is_open and peer.is_open, "actual preloaded mouth pair both open")
	check(peer.get_node("Shape").disabled, "C03 disabled peer shape cleared before entry")
	check_eq(GameState.pitch_pots, 1, "actual mouth pair spends one pot")
	player.place_at(source.global_position + Vector2(0, 100))
	await _walk_mouth(world, &"move_up", &"cave_3_1")
	check(
		(player.global_position - inside.global_position).distance_to(Vector2(528, 624)) < 10,
		"actual mouth arrives at FromOverworld"
	)
	await _walk_mouth(world, &"move_down", &"ow_3_5")
	outside = world.get_room(&"ow_3_5")
	check(
		(player.global_position - outside.global_position).distance_to(Vector2(912, 336)) < 10,
		"actual return arrives at FromCave"
	)
	check_eq(GameState.pitch_pots, 1, "round trip needs no second pot")
	await dispose(world)
	var reload_room := (load(WorldData.scene_path("cave_3_1")) as PackedScene).instantiate() as Room
	add_child(reload_room)
	await frames(2)
	check(_wall_in(reload_room).is_open, "actual C03 endpoint remains open on later visit")
	check(
		_wall_in(reload_room).get_node("Shape").disabled, "reloaded mouth collision remains cleared"
	)
	await dispose(reload_room)


func _walk_mouth(world: World, action: StringName, target: StringName) -> void:
	Input.action_press(action)
	for tick in range(180):
		await frames(1)
		if world.get_current_room_id() == target:
			break
	release_inputs()
	await seconds(0.5)
	check_eq(world.get_current_room_id(), target, "actual walking crosses paired bomb mouth")
