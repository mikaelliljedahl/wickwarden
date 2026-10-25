extends TestCase
## WardPlate (P15): only distinct blockable hits stopped by the raised ward while Tamsin is on the
## pad count. The matching blocker opens and the ward_<id> flag restores it on a later visit.

const SCENE := "res://scenes/world/ward_plate.tscn"
const PAD_AT := Vector2(500, 400)
const BLOCKER_AT := Vector2(900, 400)


func run() -> void:
	await _blocks_only_while_on_the_pad()
	await _opens_and_persists_for_matching_blocker()
	await _test_spore_post_opens_pad()
	await _runtime_watcher_opens_room()
	_scene_has_placeholder_looks()


func _make_part(
	parent: Node,
	id: StringName,
	at: Vector2,
	is_blocker: bool = false,
	blocks_required: int = 2,
	with_spore_post: bool = false
) -> Variant:
	var scene := load(SCENE) as PackedScene
	check(scene != null, "the ward plate scene loads")
	var part: Node = scene.instantiate()
	part.set(&"ward_id", id)
	part.set(&"blocker", is_blocker)
	part.set(&"blocks_required", blocks_required)
	part.set(&"test_spore_post", with_spore_post)
	parent.add_child(part)
	(part as Node2D).global_position = at
	return part


func _make_blockable_hit(parent: Node, player: Player, origin: Vector2 = Vector2.INF) -> Hitbox:
	var hitbox := Hitbox.new()
	hitbox.name = "TestShot"
	hitbox.team = Layers.Team.ENEMY
	hitbox.kind = &"spore"
	hitbox.damage = 0
	hitbox.blockable = true
	hitbox.source = Node2D.new()
	hitbox.source.name = "Shooter"
	parent.add_child(hitbox.source)
	hitbox.tree_exited.connect(hitbox.source.queue_free)
	hitbox.source.global_position = (
		player.global_position + player.facing * 120.0 if origin == Vector2.INF else origin
	)
	hitbox.add_circle(28.0)
	parent.add_child(hitbox)
	hitbox.global_position = player.global_position
	hitbox.activate()
	return hitbox


func _blocks_only_while_on_the_pad() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, PAD_AT)
	player.facing = Vector2.UP
	var pad: Variant = _make_part(arena, &"test_pad", PAD_AT)
	var blocker: Variant = _make_part(arena, &"test_pad", BLOCKER_AT, true)
	await frames(3)

	var unguarded := _make_blockable_hit(arena, player)
	await frames(3)
	check_eq(pad.blocks_absorbed, 0, "a blockable hit does not count while the ward is down")
	unguarded.deactivate()
	await dispose(unguarded)

	Input.action_press(&"ward")
	await frames(2)
	check(player.ward_up, "holding ward raises the ward")
	player.place_at(PAD_AT + Vector2(300, 0))
	await frames(2)
	var off_pad := _make_blockable_hit(arena, player)
	await frames(3)
	check_eq(pad.blocks_absorbed, 0, "a ward block outside the pad does not count")
	off_pad.deactivate()
	await dispose(off_pad)

	player.place_at(PAD_AT)
	await frames(2)
	player.facing = Vector2.UP
	check(player.ward_up, "the ward stays raised when returning to the pad")
	var behind := _make_blockable_hit(arena, player, PAD_AT + Vector2(0, 120))
	await frames(3)
	check_eq(pad.blocks_absorbed, 0, "a hit from behind is not absorbed by the ward")
	behind.deactivate()
	await dispose(behind)

	var first := _make_blockable_hit(arena, player)
	await frames(4)
	check_eq(pad.blocks_absorbed, 1, "the first absorbed blockable hit counts once")
	check(not pad.is_satisfied and not blocker.is_open, "one hit does not open a two-hit puzzle")
	await frames(4)
	check_eq(pad.blocks_absorbed, 1, "one persistent hitbox cannot count repeatedly")
	first.deactivate()
	await dispose(first)
	Input.action_release(&"ward")
	await dispose(arena)


func _opens_and_persists_for_matching_blocker() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, PAD_AT)
	player.facing = Vector2.UP
	var pad: Variant = _make_part(arena, &"persisted", PAD_AT)
	var matching: Variant = _make_part(arena, &"persisted", BLOCKER_AT, true)
	var other: Variant = _make_part(arena, &"other", BLOCKER_AT + Vector2(300, 0), true)
	await frames(3)
	Input.action_press(&"ward")
	await frames(2)
	check(player.ward_up, "the ward is raised before the linked blocker test")

	for hit_index in range(2):
		var hitbox := _make_blockable_hit(arena, player)
		await frames(3)
		hitbox.deactivate()
		await dispose(hitbox)
		await frames(2)

	check(pad.is_satisfied, "the required number of ward blocks satisfies the pad")
	check(GameState.has_flag(&"ward_persisted"), "satisfying the pad sets ward_<id>")
	check(matching.is_open, "the blocker with the same id opens")
	check(
		(matching.get_node("Shape") as CollisionShape2D).disabled,
		"an open blocker has no collision"
	)
	check(not other.is_open, "a blocker with another id stays closed")
	check(
		not (other.get_node("Shape") as CollisionShape2D).disabled,
		"an unrelated blocker retains its collision"
	)
	Input.action_release(&"ward")
	await dispose(arena)

	var later := make_arena()
	var restored: Variant = _make_part(later, &"persisted", BLOCKER_AT, true)
	await frames(2)
	check(restored.is_open, "the flag restores the matching blocker on a later visit")
	check(
		(restored.get_node("Shape") as CollisionShape2D).disabled,
		"a blocker restored from its flag has no collision"
	)
	await dispose(later)


func _test_spore_post_opens_pad() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, PAD_AT)
	player.facing = Vector2.UP
	var pad: Variant = _make_part(arena, &"spore_test", PAD_AT, false, 2, true)
	var blocker: Variant = _make_part(arena, &"spore_test", BLOCKER_AT, true)
	await frames(3)
	Input.action_press(&"ward")
	await seconds(1.5)
	check(pad.is_satisfied, "the built-in spore post supplies distinct blockable shots")
	check(blocker.is_open, "the test spore post opens its linked blocker")
	Input.action_release(&"ward")
	await dispose(arena)


func _runtime_watcher_opens_room() -> void:
	reset_state()
	var world := await make_world()
	world.start_at(&"ow_8_5", &"Default")
	await frames(3)
	var room := world.get_room(&"ow_8_5")
	var pad: Variant
	var blocker: Variant
	for part in get_tree().get_nodes_in_group(&"ward_plate"):
		if room.is_ancestor_of(part):
			pad = part
	for part in get_tree().get_nodes_in_group(&"ward_blocker"):
		if room.is_ancestor_of(part):
			blocker = part
	check(pad != null and blocker != null, "the actual terrace room has its ward puzzle")
	if pad == null or blocker == null:
		await dispose(world)
		return
	check_eq(pad.blocks_required, 3, "the actual room requires three blocks")
	# Keep the runtime shooter; isolate its puzzle from roaming combat damage.
	for enemy in room.get_enemies():
		if enemy.name != &"WatcherEye1":
			enemy.queue_free()
	world.player.place_at(pad.global_position)
	world.player.facing = Vector2.RIGHT
	Input.action_press(&"ward")
	var seen: Dictionary = {}
	for frame in range(900):
		await frames(1)
		for shot in get_tree().get_nodes_in_group(&"projectiles"):
			if not shot is EnemyProjectile or not room.is_ancestor_of(shot):
				continue
			var hitbox: Hitbox = shot.hitbox
			if seen.has(hitbox.get_instance_id()):
				continue
			seen[hitbox.get_instance_id()] = true
			var callback: Callable = pad._on_hitbox_blocked.bind(hitbox)
			check(
				hitbox.blocked.is_connected(callback),
				"a spawned beam is watched before any manual rediscovery"
			)
			# Repeated discovery must not add another callback.
			pad._watch_existing_hitboxes()
			pad._on_node_added(hitbox)
			var connections := 0
			for connection in hitbox.blocked.get_connections():
				if connection.callable == callback:
					connections += 1
			check_eq(connections, 1, "each runtime watcher beam has exactly one pad connection")
		if pad.is_satisfied:
			break
	check_eq(seen.size(), 3, "three actual watcher beams reach the puzzle")
	check_eq(pad.blocks_absorbed, 3, "runtime watcher ward blocks count exactly once each")
	check(pad.is_satisfied and blocker.is_open, "three watcher blocks open the room blocker")
	check(GameState.has_flag(&"ward_e257"), "the room puzzle persists its completion flag")
	await frames(2)
	check((blocker.get_node("Shape") as CollisionShape2D).disabled, "the room blocker unblocks")
	if OS.get_cmdline_user_args().has("--ward-capture"):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("/tmp/ward-runtime-open.png")
	Input.action_release(&"ward")
	# Walk through the opened blocker into the real pocket door trigger.
	world.player.place_at(blocker.global_position + Vector2(0, 96))
	Input.action_press(&"move_up")
	for frame in range(90):
		await frames(1)
		if world.get_current_room_id() == &"ow_8_5#ward":
			break
	Input.action_release(&"move_up")
	check_eq(
		world.get_current_room_id(), &"ow_8_5#ward",
		"the opened blocker permits walking into the actual ward pocket"
	)
	await dispose(world)
	var later := await make_world()
	later.start_at(&"ow_8_5", &"Default")
	await frames(3)
	for part in get_tree().get_nodes_in_group(&"ward_blocker"):
		if later.get_room(&"ow_8_5").is_ancestor_of(part):
			check(part.is_open, "the actual room blocker stays open after reloading")
			check(
				(part.get_node("Shape") as CollisionShape2D).disabled,
				"the reloaded room blocker stays non-solid"
			)
	await dispose(later)


func _scene_has_placeholder_looks() -> void:
	check(Placeholder.has_kind(&"ward_plate"), "the plate look is registered")
	check(Placeholder.has_kind(&"ward_blocker"), "the blocker look is registered")
	check(Placeholder.has_kind(&"spore_post"), "the test spore post look is registered")
	var scene := load(SCENE) as PackedScene
	check(scene != null, "the scene resource is valid")
