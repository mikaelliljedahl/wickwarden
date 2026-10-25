extends TestCase
## Existing Kiln Hall PackedScene used twice as paired endpoint prototypes.
## C01.b rooms 5/6 are not built yet; no substitute room files are generated.


func run() -> void:
	reset_state()
	var baseline := GameState.flag_changed.get_connections().size()
	var scene := load("res://scenes/world/rooms/cave_1_4.tscn") as PackedScene
	check(scene != null, "actual Kiln Hall scene exists")
	if scene == null:
		return
	var broadcasts: Array[StringName] = []
	var record := func(flag: StringName, _value: bool) -> void: broadcasts.append(flag)
	GameState.flag_changed.connect(record)
	var arena := make_arena()
	var first := scene.instantiate() as Node2D
	var opposite := scene.instantiate() as Node2D
	opposite.position = Vector2(4000, 0)
	opposite.process_mode = Node.PROCESS_MODE_DISABLED
	arena.add_child(first)
	arena.add_child(opposite)
	first.process_mode = Node.PROCESS_MODE_INHERIT
	opposite.position += Vector2(4000, 0)
	var gate := first.get_node("Props/Gate1") as Gate
	var peer := opposite.get_node("Props/Gate1") as Gate
	var lock := first.get_node("Props/LockedDoor1") as LockedDoor
	var peer_lock := opposite.get_node("Props/LockedDoor1") as LockedDoor
	var west := first.get_node("Props/Brazier1") as Brazier
	var east := first.get_node("Props/Brazier2") as Brazier
	check_eq(gate.gate_id, &"e149", "real gate canonical id")
	check_eq(lock.door_id, &"e151", "real lock canonical id")
	check_eq(lock.scope, &"c1", "real lock cave scope")
	var unrelated := Gate.new()
	unrelated.gate_id = &"unrelated"
	arena.add_child(unrelated)
	var other_lock := LockedDoor.new()
	other_lock.door_id = &"unrelated"
	other_lock.position = Vector2(-4000, -4000)
	arena.add_child(other_lock)
	await frames(3)
	check(not gate.is_open and not peer.is_open, "both gates initially closed")
	await _capture(first, "closed")
	for brazier in [west, east]:
		var hit := make_hitbox(arena, brazier.global_position, Layers.Team.PLAYER, 1)
		hit.kind = &"fire" if brazier == west else &"hook"
		await frames(4)
		await dispose(hit)
		if brazier == west:
			check(not gate.is_open and not peer.is_open, "one lamp cannot open either side")
	check(gate.is_open, "real fire and hook light both lamps and open source gate")
	check(peer.is_open, "disabled preloaded same-id gate opens too")
	var peer_west := opposite.get_node("Props/Brazier1") as Brazier
	check(peer_west.lit and peer_west.light.enabled, "same-id disabled brazier reflects saved light")
	await frames(2)
	check(peer._shape.disabled, "peer gate collision opens")
	check(not peer.get_node("Visual").visible, "peer gate visual opens")
	var player := make_player(arena, lock.global_position + Vector2(-65, 0))
	GameState.add_key(1, &"ow")
	await frames(5)
	check(not lock.is_open and not peer_lock.is_open, "overworld key cannot open c1 lock")
	check_eq(GameState.keys_in(&"ow"), 1, "overworld key preserved")
	GameState.add_key(2, &"c1")
	await frames(6)
	check(lock.is_open, "actual player contact unlocks source")
	check(peer_lock.is_open, "disabled same-id lock opens")
	check_eq(GameState.keys_in(&"c1"), 1, "paired opening costs exactly one cave key")
	check(not peer_lock.try_unlock(), "peer cannot spend again")
	check_eq(GameState.keys_in(&"c1"), 1, "no second spend")
	check(peer_lock._shape.disabled, "peer lock collision opens")
	check(not peer_lock.get_node("Visual").visible, "peer lock visual opens")
	check_eq(broadcasts.count(gate.flag_name()), 1, "gate flag broadcasts once")
	check_eq(broadcasts.count(lock.flag_name()), 1, "lock flag broadcasts once")
	check_eq(broadcasts.count(west.flag_name()), 1, "brazier flag broadcasts once")
	await _capture(first, "open")
	check(not unrelated.is_open and not other_lock.is_open, "different ids stay closed")
	check(not GameState.has_flag(unrelated.flag_name()), "unrelated gate flag untouched")
	check(not GameState.has_flag(other_lock.flag_name()), "unrelated lock flag untouched")
	GameState.damage(GameState.health)
	player.respawn(Vector2(960, 600))
	check(GameState.has_flag(gate.flag_name()), "death preserves opening flag")
	var replay := scene.instantiate() as Node2D
	replay.position = Vector2(8000, 0)
	replay.process_mode = Node.PROCESS_MODE_DISABLED
	arena.add_child(replay)
	await frames(2)
	check(replay.get_node("Props/Brazier1").lit, "own saved brazier replays lit")
	check(replay.get_node("Props/Gate1").is_open, "own saved gate replays open")
	check(replay.get_node("Props/LockedDoor1").is_open, "own saved lock replays open")
	GameState.set_flag(gate.flag_name(), false)
	GameState.set_flag(lock.flag_name(), false)
	check(gate.is_open and peer.is_open, "flag removal does not close live gates")
	check(lock.is_open and peer_lock.is_open, "flag removal does not close live locks")
	await dispose(arena)
	GameState.flag_changed.disconnect(record)
	check_eq(GameState.flag_changed.get_connections().size(), baseline, "freed listeners disconnect")
	reset_state()
	var fresh := scene.instantiate() as Node2D
	fresh.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(fresh)
	check(not fresh.get_node("Props/Gate1").is_open, "new game starts gate closed")
	check(not fresh.get_node("Props/LockedDoor1").is_open, "new game starts lock closed")
	check(not fresh.get_node("Props/Brazier1").lit, "new game starts brazier unlit")
	await dispose(fresh)
	check_eq(GameState.flag_changed.get_connections().size(), baseline, "reset lifecycle has no stale listeners")


func _capture(room: Node2D, label: String) -> void:
	if not OS.get_cmdline_user_args().has("--paired-visuals"):
		return
	room.visible = true
	var camera := Camera2D.new()
	camera.position = room.global_position + Vector2(960, 480)
	add_child(camera)
	camera.make_current()
	await frames(3)
	await RenderingServer.frame_post_draw
	var path := "/tmp/c01-paired-%s.png" % label
	check_eq(get_viewport().get_texture().get_image().save_png(path), OK, "capture " + label)
	await dispose(camera)
