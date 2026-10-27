extends TestCase
## The Ninth Door: nine sockets, one per fragment of C1 to C9. It stays shut with 0 or 8 fragments and
## opens when the player touches it with all nine. Nothing is spent. The flag door_ninth keeps it open on a
## later visit and after a reload. A fragment taken while the door is in the tree lights its socket at once.

const SCENE := "res://scenes/world/ninth_door.tscn"
const DOOR_AT := Vector2(500, 400)
const PLAYER_AT := Vector2(500, 330)


func run() -> void:
	await _scene_has_nine_sockets()
	await _zero_fragments_stay_shut()
	await _eight_fragments_stay_shut()
	await _nine_open_and_are_kept()
	await _flag_keeps_it_open()


func _make(parent: Node, at: Vector2) -> Variant:
	var scene := load(SCENE) as PackedScene
	check(scene != null, "the ninth door scene loads")
	var door: Node = scene.instantiate()
	parent.add_child(door)
	(door as Node2D).global_position = at
	return door


func _shape_disabled(door: Variant) -> bool:
	return (door.get_node("Shape") as CollisionShape2D).disabled


func _lit_sockets(door: Variant) -> int:
	var lit := 0
	for number in range(1, GameState.FRAGMENT_CAVES + 1):
		var socket := door.get_node_or_null("Socket_c%d" % number) as Sprite2D
		if socket != null and socket.visible:
			lit += 1
	return lit


func _give_fragments(count: int) -> void:
	for number in range(1, count + 1):
		GameState.add_fragment(StringName("c%d" % number))


func _scene_has_nine_sockets() -> void:
	reset_state()
	var arena := make_arena()
	var door: Variant = _make(arena, DOOR_AT)
	await frames(2)
	check(
		door.get_node_or_null(Placeholder.VISUAL_NAME) != null, "the ninth door has a Visual child"
	)
	check(Placeholder.has_kind(&"ninth_door"), "the door registers its placeholder kind")
	check(door.get_node("Visual") is SpriteVisual, "the door has its painted sprite")
	for number in range(1, GameState.FRAGMENT_CAVES + 1):
		check(door.get_node_or_null("Socket_c%d" % number) != null, "socket %d exists" % number)
	check(door.get_node_or_null("Socket_c10") == null, "there is no socket for C10")
	check_eq(_lit_sockets(door), 0, "no socket is lit without fragments")
	GameState.add_fragment(&"c3")
	check(door.get_node("Socket_c3").visible, "the third fragment lights the third socket")
	check(not door.get_node("Socket_c1").visible, "other sockets stay dark")
	check(not door.is_open, "a door with one fragment stays shut")
	check(not (door.get_node("Shape") as CollisionShape2D).disabled, "a shut door has collision")
	await dispose(arena)


func _zero_fragments_stay_shut() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, PLAYER_AT)
	var door: Variant = _make(arena, DOOR_AT)
	await frames(4)
	check(not door.is_open, "touching it with no fragment keeps the door shut")
	check(not GameState.has_flag(&"door_ninth"), "a shut door sets no flag")
	check(player.global_position.y < DOOR_AT.y, "the player stays on the near side")
	await dispose(arena)


func _eight_fragments_stay_shut() -> void:
	reset_state()
	_give_fragments(8)
	var arena := make_arena()
	var player := make_player(arena, PLAYER_AT)
	var door: Variant = _make(arena, DOOR_AT)
	await frames(4)
	check_eq(_lit_sockets(door), 8, "eight fragments light eight sockets")
	check(not door.can_open(), "eight fragments are not enough")
	check(not door.is_open, "touching it with eight fragments keeps the door shut")
	check(not GameState.has_flag(&"door_ninth"), "a refused touch sets no flag")
	check(player.global_position.y < DOOR_AT.y, "the player stays on the near side")
	check_eq(GameState.fragment_count(), 8, "no fragment is spent")
	await dispose(arena)


func _nine_open_and_are_kept() -> void:
	reset_state()
	_give_fragments(8)
	var arena := make_arena()
	var player := make_player(arena, PLAYER_AT - Vector2(0, 200))
	var door: Variant = _make(arena, DOOR_AT)
	await frames(2)
	GameState.add_fragment(&"c9")
	await frames(2)
	check_eq(_lit_sockets(door), 9, "a fragment taken in the tree lights its socket at once")
	check(door.can_open(), "nine fragments open the door")
	player.place_at(PLAYER_AT)
	await frames(4)
	check(door.is_open, "touching it with nine fragments opens it")
	check(_shape_disabled(door), "an open door has no collision")
	check(not door.get_node(Placeholder.VISUAL_NAME).visible, "an open door hides its look")
	check(GameState.has_flag(&"door_ninth"), "opening sets flag door_ninth")
	check_eq(GameState.fragment_count(), 9, "the fragments are kept, not spent")
	check(player.global_position.y < DOOR_AT.y, "the player stays on the near side")
	await dispose(arena)


func _flag_keeps_it_open() -> void:
	reset_state()
	GameState.set_flag(&"door_ninth")
	var arena := make_arena()
	var door: Variant = _make(arena, DOOR_AT)
	await frames(2)
	check(door.is_open, "the flag makes a later visit start with the door open")
	check(_shape_disabled(door), "a door open from the flag has no collision")
	await dispose(arena)
