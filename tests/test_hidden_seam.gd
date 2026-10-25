extends TestCase
## Hidden seams: invisible and solid until a glow jar has lit them for 1.0 s (the flag then persists) or a
## lamp hook taps the hook-tap wall; a jar that stops early hides them again; stairs get a RoomDoor once
## shown; each scene has its look.

const SEAM := "res://scenes/world/hidden_seam.tscn"
const STAIRS := "res://scenes/world/hidden_stairs.tscn"
const SEALED := "res://scenes/world/sealed_seam.tscn"
const TAP := "res://scenes/world/hook_tap_wall.tscn"
const AT := Vector2(400, 400)


func run() -> void:
	await _starts_hidden_and_solid()
	await _jar_unseals_after_one_second()
	await _jar_that_stops_early_hides_again()
	await _hide_again_keeps_a_permanent_reveal()
	await _flag_keeps_it_open_on_reentry()
	await _hook_taps_the_tap_wall()
	await _other_hits_do_nothing()
	await _stairs_get_a_door_once_shown()
	_scenes_have_their_look()
	await _real_jar_pair()
	await _hook_pair()
	await _c05_pair_if_delivered()


## Builds a seam of `scene_path` with a seam id, in the arena at `at`.
func _make_seam(parent: Node, scene_path: String, id: StringName, at: Vector2) -> Variant:
	var scene := load(scene_path) as PackedScene
	var seam: Node = scene.instantiate()
	seam.set(&"seam_id", id)
	parent.add_child(seam)
	(seam as Node2D).global_position = at
	return seam


## Lights a seam the way the glow jar does: one reveal() call per physics frame for `frames_n` frames.
func _light(seam: Variant, frames_n: int) -> void:
	for i in range(frames_n):
		seam.reveal()
		await frames(1)


## A Hitbox of `kind` and the PLAYER team (like the lamp hook or a flare), active at `at`.
func _make_hit(parent: Node, kind: StringName, at: Vector2) -> Hitbox:
	var hitbox := Hitbox.new()
	hitbox.kind = kind
	hitbox.team = Layers.Team.PLAYER
	hitbox.add_circle(24.0)
	parent.add_child(hitbox)
	hitbox.global_position = at
	hitbox.activate()
	return hitbox


func _body_disabled(seam: Node) -> bool:
	return (seam.get_node("Body/Shape") as CollisionShape2D).disabled


func _visual_shown(seam: Node) -> bool:
	return (seam.get_node("Visual") as CanvasItem).visible


func _starts_hidden_and_solid() -> void:
	reset_state()
	var arena := make_arena()
	var seam: Variant = _make_seam(arena, SEAM, &"test_seam", AT)
	await frames(2)
	check(seam.is_in_group(&"revealable"), "a hidden seam is in group revealable")
	check(not seam.is_revealed and not seam.is_shown, "a hidden seam starts hidden")
	check(not _visual_shown(seam), "a hidden seam has no visible look")
	check(not _body_disabled(seam), "a hidden seam is solid")
	check(
		(seam.get_node("Body") as StaticBody2D).collision_layer == Layers.WORLD,
		"the seam body is on the WORLD layer"
	)
	check(not GameState.has_flag(&"revealed_test_seam"), "no flag before a reveal")
	await dispose(arena)


func _jar_unseals_after_one_second() -> void:
	reset_state()
	var arena := make_arena()
	var seam: Variant = _make_seam(arena, SEAM, &"test_jar", AT)
	await frames(2)
	seam.reveal()
	check(seam.is_shown and _visual_shown(seam), "one reveal() shows the seam at once")
	await frames(1)
	check(_body_disabled(seam), "a shown seam has no blocker")
	check(not seam.is_revealed, "one reveal() is not yet permanent")
	check(not GameState.has_flag(&"revealed_test_jar"), "no flag before 1.0 s of exposure")
	await _light(seam, 30)
	check(not seam.is_revealed, "half a second of exposure does not unseal it")
	await _light(seam, 32)
	check(seam.is_revealed, "1.0 s of continuous exposure unseals it for good")
	check(GameState.has_flag(&"revealed_test_jar"), "unsealing sets flag revealed_<id>")
	check(not seam.is_in_group(&"revealable"), "an unsealed seam is no longer revealable")
	check(_visual_shown(seam) and _body_disabled(seam), "an unsealed seam stays open")
	await dispose(arena)


func _jar_that_stops_early_hides_again() -> void:
	reset_state()
	var arena := make_arena()
	var seam: Variant = _make_seam(arena, SEAM, &"test_early", AT)
	await frames(2)
	await _light(seam, 20)
	check(seam.is_shown, "a seam lit for a third of a second is shown")
	await seconds(0.5)
	check(not seam.is_shown and not _visual_shown(seam), "the light gone, the seam hides again")
	check(not _body_disabled(seam), "a hidden seam is solid again")
	check(not seam.is_revealed, "a seam lit only briefly stays revealable")
	check(not GameState.has_flag(&"revealed_test_early"), "a brief light sets no flag")
	seam.reveal()
	seam.hide_again()
	check(not seam.is_shown, "hide_again() hides a temporary reveal at once")
	await dispose(arena)


func _hide_again_keeps_a_permanent_reveal() -> void:
	reset_state()
	var arena := make_arena()
	var seam: Variant = _make_seam(arena, SEAM, &"test_keep", AT)
	await frames(2)
	await _light(seam, 62)
	check(seam.is_revealed, "the seam unsealed for good")
	seam.hide_again()
	check(seam.is_shown and _visual_shown(seam), "hide_again() does not hide a permanent reveal")
	check(_body_disabled(seam), "a permanent reveal keeps its blocker off")
	await dispose(arena)


func _flag_keeps_it_open_on_reentry() -> void:
	reset_state()
	var arena := make_arena()
	var first: Variant = _make_seam(arena, SEAM, &"test_reenter", AT)
	await frames(2)
	await _light(first, 62)
	await dispose(arena)
	# A new visit: the room is built again from its scene and the flag is still set.
	var later := make_arena()
	var again: Variant = _make_seam(later, SEAM, &"test_reenter", AT)
	await frames(2)
	check(again.is_revealed and again.is_shown, "a later visit starts with the seam open")
	check(_visual_shown(again) and _body_disabled(again), "a reopened seam shows and is passable")
	check(not again.is_in_group(&"revealable"), "a reopened seam is not revealable again")
	await dispose(later)


func _hook_taps_the_tap_wall() -> void:
	reset_state()
	var arena := make_arena()
	var wall: Variant = _make_seam(arena, TAP, &"test_tap", AT)
	await frames(2)
	check(wall.is_in_group(&"revealable"), "a tap wall is also revealable (group revealable)")
	var flare := _make_hit(arena, &"flare", AT)
	await frames(3)
	check(not wall.is_revealed, "a flare does not tap a tap wall")
	flare.deactivate()
	await dispose(flare)
	var hook := _make_hit(arena, &"hook", AT)
	await frames(3)
	check(wall.is_revealed, "a hook tap unseals a tap wall at once")
	check(GameState.has_flag(&"revealed_test_tap"), "a hook tap sets flag revealed_<id>")
	check(_visual_shown(wall) and _body_disabled(wall), "a tapped wall is open")
	hook.deactivate()
	await dispose(hook)
	await dispose(arena)


func _other_hits_do_nothing() -> void:
	reset_state()
	var arena := make_arena()
	var seam: Variant = _make_seam(arena, SEAM, &"test_plain", AT)
	var stairs: Variant = _make_seam(arena, STAIRS, &"test_stairs", Vector2(400, 700))
	await frames(2)
	var hook := _make_hit(arena, &"hook", AT)
	var fire := _make_hit(arena, &"fire", Vector2(400, 700))
	await seconds(0.5)
	check(not seam.is_shown and not seam.is_revealed, "a hook does not reveal a plain seam")
	check(not stairs.is_shown and not stairs.is_revealed, "a fire does not reveal stairs")
	check(not GameState.has_flag(&"revealed_test_plain"), "a hook hit sets no flag on a plain seam")
	hook.deactivate()
	fire.deactivate()
	await dispose(hook)
	await dispose(fire)
	await dispose(arena)


func _stairs_get_a_door_once_shown() -> void:
	reset_state()
	var scene := load(STAIRS) as PackedScene
	var arena := make_arena()
	var stairs: Variant = scene.instantiate()
	stairs.set(&"seam_id", &"test_door")
	stairs.set(&"door_target", &"cave_7_1")
	stairs.set(&"door_spawn", &"FromOverworld")
	arena.add_child(stairs)
	stairs.global_position = AT
	await frames(2)
	check(stairs.get_node_or_null("Door") == null, "a hidden stair has no door yet")
	await _light(stairs, 62)
	var door := stairs.get_node_or_null("Door") as RoomDoor
	check(door != null, "a revealed stair gets a RoomDoor")
	if door == null:
		await dispose(arena)
		return
	check(door.target_room == &"cave_7_1", "the door leads to the target room")
	check(door.target_spawn == &"FromOverworld", "the door uses the target spawn")
	check(door.monitoring, "a revealed door is on")
	await dispose(arena)
	# The seam reopens for later visits: the same door is on from the first frame.
	var later := make_arena()
	var again := scene.instantiate()
	again.set(&"seam_id", &"test_door")
	again.set(&"door_target", &"cave_7_1")
	later.add_child(again)
	again.global_position = AT
	await frames(2)
	var again_door := again.get_node_or_null("Door") as RoomDoor
	check(again_door != null and again_door.monitoring, "a revealed stair starts with its door on")
	check(again_door != null and again_door.target_room == &"cave_7_1", "and it keeps its target")
	await dispose(later)


func _scenes_have_their_look() -> void:
	var looks := {
		SEAM: &"hidden_seam",
		STAIRS: &"hidden_stairs",
		SEALED: &"sealed_seam",
		TAP: &"hook_tap_wall",
	}
	for scene_path in looks:
		var scene := load(scene_path) as PackedScene
		check(scene != null, "%s loads" % scene_path)
		if scene == null:
			continue
		var seam: Node = scene.instantiate()
		check(
			seam.get(&"look") == looks[scene_path],
			"%s has look %s" % [scene_path, looks[scene_path]]
		)
		check(
			Placeholder.has_kind(looks[scene_path]),
			"%s is a registered placeholder kind" % scene_path
		)
		check(seam.get(&"size") == Vector2(192, 96), "%s fills a 192 x 96 px gap" % scene_path)
		check(seam.get(&"hook_tap") == (scene_path == TAP), "%s tap flag is right" % scene_path)
		seam.free()


func _real_jar_pair() -> void:
	reset_state()
	var arena := make_arena()
	var source = _make_seam(arena, SEAM, &"jar_pair", AT)
	var peer = _make_seam(arena, SEAM, &"jar_pair", Vector2(1600, 400))
	peer.process_mode = Node.PROCESS_MODE_DISABLED
	peer.door_target = &"cave_7_1"
	peer.door_spawn = &"FromOverworld"
	var unrelated = _make_seam(arena, SEAM, &"other_pair", Vector2(1800, 400))
	var anonymous = _make_seam(arena, SEAM, &"", Vector2(2000, 400))
	var door := RoomDoor.new()
	door.position = Vector2(1600, 520)
	door.blocker_path = NodePath("../" + String(peer.name))
	arena.add_child(door)
	var player := make_player(arena, Vector2(400, 650))
	player.facing = Vector2.UP
	GameState.acquire_item(&"glow_jar")
	GameState.set_active_item(&"glow_jar")
	await frames(2)
	GameState.flag_changed.emit(&"revealed_jar_pair", false)
	GameState.set_flag(&"revealed_unrelated")
	GameState.set_flag(&"revealed_")
	check(not source.is_shown and not peer.is_shown, "false/unrelated flags leave pair concealed")
	check(not anonymous.is_revealed, "empty seam id ignores anonymous reveal flag")
	check(player.use_item(), "real jar launches for temporary discovery")
	await seconds(0.65)
	check(source.is_shown and not source.is_revealed, "real jar first shows source temporarily")
	check(not GameState.has_flag(&"revealed_jar_pair"), "temporary discovery publishes no flag")
	check(not peer.is_shown and not _body_disabled(peer), "temporary discovery never leaks to peer")
	check(not door._gate_is_open(), "temporary source discovery leaves peer entrance blocked")
	for item in get_tree().get_nodes_in_group(ItemBase.group_name(&"glow_jar")):
		item.queue_free()
	await seconds(0.4)
	check(
		not source.is_shown and not source.is_revealed, "interrupted real light hides source again"
	)
	check(not peer.is_shown, "interrupted discovery leaves disabled peer hidden")
	check(peer.get_node_or_null("Door") == null, "temporary discovery creates no remote door")
	var publications := {"count": 0}
	var on_flag := func(flag: StringName, value: bool) -> void:
		if value and flag == &"revealed_jar_pair":
			publications["count"] += 1
	GameState.flag_changed.connect(on_flag)
	check(player.use_item(), "second real jar launches after interrupted light")
	await seconds(1.7)
	check(
		source.is_revealed and peer.is_revealed,
		"real continuous jar permanently reveals loaded pair"
	)
	check(peer.is_shown and _body_disabled(peer), "disabled peer shows and clears child WORLD body")
	check(_visual_shown(peer), "permanent peer visual is shown")
	var peer_door := peer.get_node_or_null("Door") as RoomDoor
	check(peer_door != null, "permanent remote restore creates configured RoomDoor")
	if peer_door != null:
		check(peer_door._gate_is_open(), "restored child RoomDoor sees disabled seam body")
	check(not peer.is_in_group(&"revealable"), "permanent peer leaves revealable group")
	check(door._gate_is_open(), "permanent peer enables linked RoomDoor readiness")
	check(not unrelated.is_revealed and not unrelated.is_shown, "unrelated seam id stays secret")
	check_eq(publications["count"], 1, "peer restore republishes no canonical flag")
	check_eq(
		get_tree().get_nodes_in_group(ItemBase.group_name(&"glow_jar")).size(),
		1,
		"peer restore spawns no extra jar"
	)
	GameState.flag_changed.disconnect(on_flag)
	for seam in [source, peer]:
		player.place_at(seam.global_position + Vector2(0, 130))
		Input.action_press(&"move_up")
		await seconds(1.0)
		release_inputs()
		check(
			player.global_position.y < seam.global_position.y - 70,
			"real player physically traverses permanently revealed source/peer"
		)
	GameState.flag_changed.emit(&"revealed_jar_pair", false)
	peer.hide_again()
	await seconds(0.3)
	check(
		peer.is_shown and peer.is_revealed,
		"false notification and hide cannot reclose permanent peer"
	)
	var callback := Callable(peer, "_on_flag_changed")
	check(
		GameState.flag_changed.is_connected(callback),
		"permanent peer subscribes to canonical state"
	)
	peer.free()
	check(
		not GameState.flag_changed.is_connected(callback), "freed peer subscription cleans itself"
	)
	GameState.flag_changed.emit(&"revealed_jar_pair", true)
	await dispose(arena)


func _hook_pair() -> void:
	reset_state()
	var arena := make_arena()
	var source = _make_seam(arena, TAP, &"hook_pair", AT)
	var peer = _make_seam(arena, TAP, &"hook_pair", Vector2(1600, 400))
	peer.process_mode = Node.PROCESS_MODE_DISABLED
	var player := make_player(arena, AT + Vector2(0, 100))
	player.facing = Vector2.UP
	await frames(2)
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	await frames(4)
	check(
		source.is_revealed and peer.is_revealed,
		"real hook tap permanently reveals paired tap walls"
	)
	check(GameState.has_flag(&"revealed_hook_pair"), "hook tap is canonical permanent reveal")
	check(_body_disabled(peer), "hook peer child blocker clears while processing disabled")
	check(not peer.get_node("Hurtbox").enabled, "permanent hook peer no longer accepts taps")
	await dispose(arena)


func _c05_pair_if_delivered() -> void:
	var ids := ["cave_5_5", "cave_5_6"]
	for id in ids:
		if not ResourceLoader.exists(WorldData.scene_path(id)):
			print("PENDING C05 real pair traversal: missing " + id + " scene")
			return
	reset_state()
	SaveGame.enabled = false
	var world := await make_world()
	world.start_at(&"cave_5_5")
	var source_room := world.get_room(&"cave_5_5")
	var peer_room := world.get_room(&"cave_5_6")
	var source = _e185_seam(source_room)
	var peer = _e185_seam(peer_room)
	check(source != null and peer != null, "actual e185 seam exports exist at both endpoints")
	if source == null or peer == null:
		await dispose(world)
		return
	check(not peer_room.can_process(), "actual C05 peer is preloaded disabled")
	for room in [source_room, peer_room]:
		for enemy in room.get_enemies():
			enemy.drops_enabled = false
			enemy.kill()
	var player := world.player
	player.set_hurtbox_enabled(self, false)
	for node in source_room.get_node("Props").get_children():
		if node is PickupBase and node.item_id == &"glow_jar":
			player.place_at(node.global_position + Vector2(0, 46))
	await frames(4)
	check(GameState.has_item(&"glow_jar"), "actual C05 pedestal grants glow jar")
	player.place_at(source_room.global_position + Vector2(960, 240))
	Input.action_press(&"move_up")
	await seconds(0.8)
	release_inputs()
	check(
		player.global_position.y - source_room.global_position.y > 100,
		"unrevealed actual C05 seam blocks real player"
	)
	GameState.set_active_item(&"glow_jar")
	player.facing = Vector2.UP
	check(player.use_item(), "actual C05 acquired jar launches at e185")
	await seconds(0.65)
	check(source.is_shown and not source.is_revealed, "actual e185 first reveals temporarily")
	check(not peer.is_shown, "actual temporary e185 discovery does not leak across rooms")
	await seconds(1.2)
	check(GameState.has_flag(&"revealed_e185"), "actual jar sets canonical permanent e185")
	check(
		peer.is_revealed and _body_disabled(peer), "disabled actual peer restores permanent state"
	)
	await _cross_c05(world, &"move_up", &"cave_5_6")
	Input.action_press(&"move_up")
	await seconds(0.6)
	release_inputs()
	check(
		player.global_position.y - peer_room.global_position.y < 800,
		"real player traverses cleared peer seam after room slide"
	)
	await _cross_c05(world, &"move_down", &"cave_5_5")
	source_room = world.get_room(&"cave_5_5")
	Input.action_press(&"move_down")
	await seconds(0.6)
	release_inputs()
	check(
		player.global_position.y - source_room.global_position.y > 150,
		"real return traverses cleared source seam"
	)
	await dispose(world)
	var reloaded := (load(WorldData.scene_path("cave_5_6")) as PackedScene).instantiate() as Room
	add_child(reloaded)
	await frames(2)
	var restored = _e185_seam(reloaded)
	check(
		restored.is_revealed and _body_disabled(restored),
		"actual C05 reentry restores permanent seam"
	)
	check(
		not restored.is_in_group(&"revealable"), "persisted peer remains outside revealable group"
	)
	await dispose(reloaded)


func _e185_seam(room: Room) -> Node2D:
	for node in room.get_node("Props").get_children():
		var script: Script = node.get_script()
		if script != null and script.resource_path == "res://scripts/world/hidden_seam.gd":
			if node.seam_id == &"e185":
				return node
	return null


func _cross_c05(world: World, action: StringName, target: StringName) -> void:
	Input.action_press(action)
	for tick in range(240):
		await frames(1)
		if world.get_current_room_id() == target:
			break
	release_inputs()
	await seconds(0.5)
	check_eq(world.get_current_room_id(), target, "actual physical e185 room slide")
