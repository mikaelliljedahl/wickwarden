extends TestCase
## Real-scene regressions: the player's body reaches the trigger beyond an intact opener.


func run() -> void:
	for id in [&"ow_7_3", &"ow_1_5", &"ow_4_1", &"ow_6_0", &"ow_3_5"]:
		await _check_entrance(id)
	await _explicit_requirements()
	await _revealed_stairs_look()
	await _offset_seam()
	await _pushed_boulder()
	for id in [&"ow_1_5", &"ow_5_5", &"ow_7_3"]:
		await _regrowing_cut_entrance(id)


func _check_entrance(id: StringName) -> void:
	reset_state()
	var world := await make_world()
	world.start_at(id)
	await frames(3)
	var room := world.get_room(id)
	var door: RoomDoor
	for child in room.get_node("Props").get_children():
		if child is RoomDoor:
			door = child
	check(door != null, "%s has a real entrance" % id)
	if door == null:
		await dispose(world)
		return
	var opener := door.get_node_or_null(door.blocker_path) as Node2D
	if door.blocker_path.is_empty():
		for child in room.get_node("Props").get_children():
			if child is StaticBody2D and child.position == door.position:
				opener = child
	check(opener != null, "%s has an authoritative opener" % id)
	if opener == null:
		await dispose(world)
		return
	# 60 px is the reviewer's ow_7_3 repro: body overlaps the 96 px door below the bush.
	if not opener is Bush:
		# Force overlap for rectangular walls: normal collision recovery keeps bodies outside.
		world.player.set_physics_process(false)
	world.player.place_at(door.global_position + Vector2(0, 60))
	await frames(5)
	check(door.has_overlapping_bodies(), "%s reproduces trigger edge overlap" % id)
	check(not world.is_transitioning(), "%s intact opener prevents entry" % id)
	check(not door.get_node("Visual").visible, "%s intact opener conceals entrance art" % id)
	check_eq(world.get_current_room_id(), id, "%s stays outside" % id)
	var flag := &""
	if opener is Bush:
		opener.drops_enabled = false
		opener.cut_down()
	else:
		flag = opener.call("flag_name")
		opener.call("on_explosion", opener.global_position, 96.0)
	check(door._gate_is_open(), "%s required opener enables entry" % id)
	await frames(4)
	check(door.get_node("Visual").visible, "%s opened entrance art is visible" % id)
	if ResourceLoader.exists(WorldData.scene_path(String(door.target_room))):
		check(world.is_transitioning(), "%s enters after opening" % id)
	if flag != &"":
		check(GameState.has_flag(flag), "%s opening persists in GameState" % id)
	await seconds(1.0)
	await dispose(world)
	# Reinstantiate the actual scene with the same state: walls stay open, bushes regrow.
	var scene := load(WorldData.scene_path(String(id))) as PackedScene
	check(scene != null, "%s scene reloads" % id)
	var reloaded := scene.instantiate() as Room
	add_child(reloaded)
	reloaded.enter()
	await frames(2)
	for child in reloaded.get_node("Props").get_children():
		if child is RoomDoor:
			check_eq(child._gate_is_open(), flag != &"", "%s reload respects opener state" % id)
	await dispose(reloaded)


func _explicit_requirements() -> void:
	reset_state()
	var arena := make_arena()
	var plain := RoomDoor.new()
	arena.add_child(plain)
	check(plain._gate_is_open(), "plain door stays usable")
	var gated := RoomDoor.new()
	gated.position = Vector2(300, 300)
	gated.requires_flag = &"cracked_test"
	arena.add_child(gated)
	check(not gated._gate_is_open(), "required flag blocks entry")
	GameState.set_flag(&"cracked_test")
	check(gated._gate_is_open(), "authoritative flag enables entry")
	var bush := Bush.new()
	bush.name = "OffsetBush"
	bush.position = Vector2(500, 500)
	bush.drops_enabled = false
	arena.add_child(bush)
	var offset := RoomDoor.new()
	offset.position = Vector2(600, 500)
	offset.blocker_path = NodePath("../OffsetBush")
	arena.add_child(offset)
	check(not offset._gate_is_open(), "explicit link blocks even with offset opener")
	bush.cut_down()
	check(offset._gate_is_open(), "cutting linked offset opener enables entrance")
	offset.blocker_path = NodePath("../WrongAfterBinding")
	check(not offset._gate_is_open(), "bad replacement path cannot reuse a cut blocker cache")
	offset.blocker_path = NodePath("../OffsetBush")
	check(offset._gate_is_open(), "valid path rebinds the actual cut actor")
	var linked := RoomDoor.new()
	linked.blocker_path = NodePath("../Missing")
	arena.add_child(linked)
	check(not linked._gate_is_open(), "missing explicit blocker fails closed")
	await dispose(arena)


func _revealed_stairs_look() -> void:
	reset_state()
	var scene := load(WorldData.scene_path("ow_0_2")) as PackedScene
	check(scene != null, "actual hidden stairs scene loads")
	if scene == null:
		return
	var room := scene.instantiate() as Room
	add_child(room)
	var stairs := room.get_node("Props/HiddenStairs1")
	check(not stairs.get_node("Visual").visible, "unrevealed stairs stay concealed")
	check(stairs.get_node_or_null("Door") == null, "unrevealed stairs have no door")
	stairs.call("_unseal")
	await frames(2)
	var door := stairs.get_node("Door") as RoomDoor
	check_eq(door.entrance_kind(), &"pocket_stairs", "revealed stairs never become a cave mouth")
	check_eq(
		stairs.get_node("Visual").visible,
		not SpriteVisual.has_art(&"pocket_stairs"),
		"painted stairs replace the redundant backing only when available"
	)
	check_eq(door.position, Vector2.ZERO, "stairs presentation keeps the trigger in place")
	await dispose(room)


func _linked_door(
	parent: Node, blocker: Node2D, at: Vector2, footprint := Vector2(96, 96)
) -> RoomDoor:
	var door := RoomDoor.new()
	door.position = at
	door.size = footprint
	door.blocker_path = NodePath("../" + String(blocker.name))
	parent.add_child(door)
	return door


func _offset_seam() -> void:
	reset_state()
	var arena := make_arena()
	var packed := load("res://scenes/world/hook_tap_wall.tscn") as PackedScene
	check(packed != null, "real hook seam scene loads")
	if packed == null:
		await dispose(arena)
		return
	var seam = packed.instantiate()
	seam.name = "LinkedSeam"
	seam.position = Vector2(500, 400)
	arena.add_child(seam)
	var door := _linked_door(arena, seam, Vector2(500, 520))
	var player := make_player(arena, door.position)
	player.set_physics_process(false)
	await frames(4)
	check(door.has_overlapping_bodies(), "closed offset seam trigger actually contacted")
	check(not seam.get_node("Body/Shape").disabled, "closed seam child body is solid")
	check(not door._gate_is_open(), "closed seam denies offset trigger")
	check(not door.get_node("Visual").visible, "closed seam conceals offset entrance")
	await _probe_image("seam-closed")
	player.set_physics_process(true)
	player.place_at(seam.global_position + Vector2(0, 80))
	player.facing = Vector2.UP
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	await frames(4)
	check(seam.is_shown, "real player hook reveals linked seam")
	check(seam.get_node("Body/Shape").disabled, "hook clears actual seam body")
	check(door._gate_is_open(), "real reveal enables linked offset entrance")
	# Temporary jar reveals must close again when their light expires.
	var temporary = (load("res://scenes/world/hidden_seam.tscn") as PackedScene).instantiate()
	temporary.name = "TemporarySeam"
	temporary.position = Vector2(900, 400)
	arena.add_child(temporary)
	var temporary_door := _linked_door(arena, temporary, Vector2(900, 520))
	temporary.reveal()
	await frames(2)
	check(temporary_door._gate_is_open(), "live reveal enables temporary entrance")
	await frames(20)
	check(not temporary_door._gate_is_open(), "expired reveal closes entrance again")
	await _probe_image("seam-revealed")
	await dispose(arena)


func _pushed_boulder() -> void:
	reset_state()
	var arena := make_arena()
	var packed := load("res://scenes/world/heavy_boulder.tscn") as PackedScene
	check(packed != null, "real PUSH boulder scene loads")
	if packed == null:
		await dispose(arena)
		return
	var stone = packed.instantiate()
	stone.name = "LinkedBoulder"
	stone.stone_id = &"door_push_probe"
	stone.position = Vector2(500, 400)
	arena.add_child(stone)
	var door := _linked_door(arena, stone, stone.position, Vector2(192, 96))
	await frames(2)
	check(not door._gate_is_open(), "unmoved boulder blocks entrance")
	GameState.set_flag(&"moved_unrelated")
	check(not door._gate_is_open(), "unrelated move flag cannot unlock boulder entrance")
	var narrow := _linked_door(arena, stone, stone.position)
	# A wide trigger still intersects after one completed step: moved is not cleared.
	await _push_door_stone(stone)
	check_eq(stone.path, "R", "real PUSH API completes one step")
	check(narrow._gate_is_open(), "one full step clears a standard entrance")
	check(not door._gate_is_open(), "moved boulder still overlapping wide entrance blocks it")
	await _probe_image("boulder-overlapping")
	await _push_door_stone(stone)
	check_eq(stone.path, "RR", "second real push completes")
	check((stone.collision_layer & Layers.WORLD) != 0, "cleared boulder remains WORLD solid")
	check(not stone.get_node("Shape").disabled, "cleared boulder shape remains enabled")
	check(door._gate_is_open(), "physically cleared PUSH boulder enables entrance")
	var wrapper := Node2D.new()
	wrapper.name = "UnrelatedSolid"
	wrapper.position = Vector2(1000, 400)
	arena.add_child(wrapper)
	var body := StaticBody2D.new()
	body.collision_layer = Layers.WORLD
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	body.add_child(shape)
	wrapper.add_child(body)
	var unrelated := _linked_door(arena, wrapper, Vector2(1200, 400))
	check(not unrelated._gate_is_open(), "unrelated offset child WORLD body remains blocked")
	await _probe_image("boulder-cleared")
	await dispose(arena)


func _push_door_stone(stone: Node) -> void:
	for tick in range(36):
		stone.call("try_move", Vector2.RIGHT)
		await frames(1)
	await frames(30)


func _probe_image(label: String) -> void:
	if OS.get_environment("WICK_DOOR_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var path := "/tmp/wick-door-" + label + ".png"
	check_eq(get_viewport().get_texture().get_image().save_png(path), OK, "probe capture " + label)


func _regrowing_cut_entrance(id: StringName) -> void:
	reset_state()
	SaveGame.enabled = false
	var packed := load(WorldData.scene_path(String(id))) as PackedScene
	check(packed != null, "%s generated scene exists" % id)
	if packed == null:
		return
	var preview := packed.instantiate() as Room
	var preview_door := _pocket_entrance(preview)
	check(preview_door != null, "%s has generated pocket entrance" % id)
	if preview_door == null:
		preview.free()
		return
	check(
		preview_door.get_node_or_null(preview_door.blocker_path) is Bush,
		"%s authored cross-container path resolves before ready" % id
	)
	# Querying early must not permanently capture the template instead of its live clone.
	check(not preview_door._gate_is_open(), "%s authored template starts closed" % id)
	add_child(preview)
	check(
		preview.get_node("Bushes").get_child_count() == 0,
		"%s ready snapshots bushes out of live container" % id
	)
	check(
		preview_door.get_node_or_null(preview_door.blocker_path) == null,
		"%s null before enter is expected template lifecycle" % id
	)
	check(not preview_door._gate_is_open(), "%s inactive empty container fails closed" % id)
	preview.enter()
	check(
		preview_door.get_node_or_null(preview_door.blocker_path) is Bush,
		"%s enter clones bush under authored name" % id
	)
	check(not preview_door._gate_is_open(), "%s live clone overrides early template binding" % id)
	await dispose(preview)
	var world := await make_world()
	world.start_at(id)
	var room := world.get_room(id)
	var door := _pocket_entrance(room)
	var player := world.player
	player.set_hurtbox_enabled(self, false)
	for enemy in room.get_enemies():
		enemy.drops_enabled = false
		enemy.kill()
	await frames(3)
	var bush := door.get_node_or_null(door.blocker_path) as Bush
	check(bush != null, "%s active World resolves live cut blocker" % id)
	if bush == null:
		await dispose(world)
		return
	var first_id := bush.get_instance_id()
	bush.drops_enabled = false
	check(not door._gate_is_open(), "%s actual active entrance starts blocked" % id)
	var entrance_at := door.global_position
	var target := door.target_room
	var approach := (room.get_spawn_position(&"FromPocket") - entrance_at).normalized()
	player.place_at(entrance_at + approach * 130.0)
	player.facing = -approach
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	await frames(15)
	check(door._gate_is_open(), "%s actual hook cut opens pocket entrance" % id)
	await _walk_to_pocket(world, entrance_at, approach, target)
	check_eq(world.get_current_room_id(), target, "%s physically enters pocket after cut" % id)
	if world.get_current_room_id() != target:
		await dispose(world)
		return
	var pocket := world.get_room(target)
	var back: RoomDoor
	for node in pocket.get_node("Props").get_children():
		if node is RoomDoor and node.target_room == id:
			back = node
	check(back != null, "%s pocket has actual return door" % id)
	if back == null:
		await dispose(world)
		return
	player.place_at(back.global_position + Vector2(0, -100))
	await _hold_for_room(world, &"move_down", id)
	room = world.get_room(id)
	door = _pocket_entrance(room)
	await frames(3)
	var regrown := door.get_node_or_null(door.blocker_path) as Bush
	check(regrown != null, "%s pocket return regrows named blocker" % id)
	if regrown != null:
		check(regrown.get_instance_id() != first_id, "%s return uses new live instance" % id)
	check(not door._gate_is_open(), "%s regrown blocker closes cached door" % id)
	check(not door.get_node("Visual").visible, "%s regrown secret entrance concealed again" % id)
	# Reenter the same live room object once more, without relying on an unload.
	room.leave()
	check(not door._gate_is_open(), "%s empty between visits stays closed" % id)
	room.enter()
	check(
		door.get_node_or_null(door.blocker_path) is Bush,
		"%s repeated entry resolves newest clone" % id
	)
	check(not door._gate_is_open(), "%s repeated entry cannot inherit dead cut reference" % id)
	await dispose(world)


func _pocket_entrance(room: Room) -> RoomDoor:
	for node in room.get_node("Props").get_children():
		if node is RoomDoor and "#" in String(node.target_room):
			return node
	return null


func _walk_to_pocket(world: World, at: Vector2, approach: Vector2, target: StringName) -> void:
	if world.get_current_room_id() == target:
		return
	world.player.place_at(at + approach * 130.0)
	var action := &"move_up" if approach.y > 0 else &"move_right"
	await _hold_for_room(world, action, target)


func _hold_for_room(world: World, action: StringName, target: StringName) -> void:
	Input.action_press(action)
	for tick in range(180):
		await frames(1)
		if world.get_current_room_id() == target:
			break
	release_inputs()
	await seconds(0.5)
	check_eq(world.get_current_room_id(), target, "actual walking reaches expected pocket/host")
