extends TestCase
## Boss door: shut without the big key of its cave; touching it with that key opens it, the key is kept
## (nothing is spent); the flag door_boss_<cave> keeps it open on a later visit; small keys of any scope
## and another cave's big key do not open it.

const SCENE := "res://scenes/world/boss_door.tscn"
const DOOR_AT := Vector2(500, 400)
const PLAYER_AT := Vector2(500, 600)


func run() -> void:
	await _shut_without_key()
	await _big_key_opens_and_is_kept()
	await _flag_keeps_it_open()
	await _other_keys_do_not_open()
	await _preloaded_peer_and_cleanup()


func _make(parent: Node, cave: StringName, at: Vector2) -> Variant:
	var scene := load(SCENE) as PackedScene
	check(scene != null, "the boss door scene loads")
	var door: Node = scene.instantiate()
	door.set(&"cave", cave)
	parent.add_child(door)
	(door as Node2D).global_position = at
	return door


func _shape_disabled(door: Variant) -> bool:
	return (door.get_node("Shape") as CollisionShape2D).disabled


func _shut_without_key() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, PLAYER_AT)
	var door: Variant = _make(arena, &"c1", DOOR_AT)
	await frames(2)
	Input.action_press(&"move_up")
	await seconds(1.0)
	release_inputs()
	check(player.global_position.y > DOOR_AT.y, "the boss door blocks the player")
	check(not door.is_open, "it stays shut without the big key")
	check(not GameState.has_flag(&"door_boss_c1"), "a shut door sets no flag")
	await dispose(arena)


func _big_key_opens_and_is_kept() -> void:
	reset_state()
	var arena := make_arena()
	make_player(arena, DOOR_AT + Vector2(0, -70))
	var door: Variant = _make(arena, &"c1", DOOR_AT)
	GameState.add_key(1, &"c1")
	await frames(4)
	check(not door.is_open, "a small key of the cave does not open a boss door")
	check_eq(GameState.keys_in(&"c1"), 1, "and that small key is not spent")
	GameState.add_big_key(&"c1")
	await frames(4)
	check(door.is_open, "touching it with the big key opens it")
	check(_shape_disabled(door), "an open door has no collision")
	check(not door.get_node(Placeholder.VISUAL_NAME).visible, "an open door is hidden")
	check(GameState.has_big_key(&"c1"), "the big key is kept, not spent")
	check(GameState.has_flag(&"door_boss_c1"), "opening sets flag door_boss_c1")
	await dispose(arena)


func _flag_keeps_it_open() -> void:
	reset_state()
	GameState.set_flag(&"door_boss_c2")
	var arena := make_arena()
	var door: Variant = _make(arena, &"c2", DOOR_AT)
	await frames(2)
	check(door.is_open, "the flag makes a later visit start with the door open")
	check(_shape_disabled(door), "a door open from the flag has no collision")
	await dispose(arena)


func _other_keys_do_not_open() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, DOOR_AT + Vector2(0, -70))
	var door: Variant = _make(arena, &"c1", DOOR_AT)
	GameState.add_big_key(&"c2")
	GameState.add_key(1, &"ow")
	await frames(4)
	check(not door.is_open, "another cave's big key and an overworld key do not open it")
	check_eq(GameState.keys_in(&"ow"), 1, "the overworld key is not spent")
	check(GameState.has_big_key(&"c2"), "the other big key is not spent")
	check(not GameState.has_flag(&"door_boss_c1"), "a refused touch sets no flag")
	check(player.global_position.y < DOOR_AT.y, "the player stays on the near side")
	await dispose(arena)


func _preloaded_peer_and_cleanup() -> void:
	reset_state()
	var baseline := GameState.flag_changed.get_connections().size()
	var arena := make_arena()
	var player := make_player(arena, PLAYER_AT)
	var source = _make(arena, &"c2", DOOR_AT)
	var peer = _make(arena, &"c2", Vector2(1000, 400))
	var other = _make(arena, &"c1", Vector2(1400, 400))
	peer.process_mode = Node.PROCESS_MODE_DISABLED
	var signals := [0, 0]
	source.opened.connect(func(): signals[0] += 1)
	peer.opened.connect(func(): signals[1] += 1)
	GameState.add_key(2, &"c2")
	GameState.add_key(1, &"c1")
	GameState.add_big_key(&"c1")
	await frames(3)
	player.place_at(DOOR_AT + Vector2(0, -70))
	await frames(4)
	check(not source.is_open and not peer.is_open, "c1 Lockpick cannot open c2 endpoints")
	GameState.set_flag(&"door_boss_c1")
	GameState.set_flag(&"door_boss_c2", false)
	await frames(2)
	check(other.is_open, "c1 flag opens only its own cave")
	check(not source.is_open and not peer.is_open, "false or wrong-scope flag leaves c2 shut")
	GameState.add_big_key(&"c2")
	await frames(4)
	check(source.is_open, "real player contact opens c2 source")
	check(peer.is_open, "already loaded disabled peer follows canonical c2 flag")
	check(_shape_disabled(source) and _shape_disabled(peer), "both colliders disable")
	check(not peer.get_node(Placeholder.VISUAL_NAME).visible, "peer visual disappears")
	check_eq(signals, [1, 0], "only contact source emits unlock feedback")
	check(GameState.has_big_key(&"c2"), "synchronization keeps the Lockpick")
	check_eq(GameState.keys_in(&"c2"), 2, "neither endpoint spends c2 small keys")
	check_eq(GameState.keys_in(&"c1"), 1, "other scope keys remain untouched")
	check(not peer.try_open(), "synchronized endpoint cannot unlock twice")
	var reentry = _make(arena, &"c2", Vector2(1200, 700))
	await frames(2)
	check(reentry.is_open and _shape_disabled(reentry), "fresh endpoint restores open state")
	await dispose(arena)
	check_eq(
		GameState.flag_changed.get_connections().size(), baseline,
		"freed doors leave no flag subscriptions"
	)
	GameState.set_flag(&"door_boss_c2", false)
	GameState.set_flag(&"door_boss_c2")
	await frames(2)
