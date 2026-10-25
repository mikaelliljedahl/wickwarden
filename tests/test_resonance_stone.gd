extends TestCase
## Resonance stone, door and vault: a chime wave wakes them, a hook swing, a flare or a pot blast does
## not, the awake state persists through the flag resonated_<id>, and the three scenes share one script.

const STONE_SCENE := "res://scenes/world/resonance_stone.tscn"
const DOOR_SCENE := "res://scenes/world/resonance_door.tscn"
const VAULT_SCENE := "res://scenes/world/resonance_vault.tscn"
const SCRIPT_PATH := "res://scripts/world/resonance_stone.gd"
const CHIME_SCENE := "res://scenes/items/lantern_chime.tscn"

var _matching_flag_changes := 0


func run() -> void:
	await _paired_real_chime_updates_disabled_peer()
	await _optional_c06_pair()
	await _chime_wakes()
	await _other_hits_do_not()
	await _flag_persists()
	await _scenes_share_script()


## Builds a resonance piece (untyped: the script has no class_name, so it is a plain Node here).
func _make(parent: Node, scene_path: String, id: StringName, at: Vector2) -> Variant:
	var scene := load(scene_path) as PackedScene
	var piece: Node = scene.instantiate()
	piece.set(&"resonance_id", id)
	parent.add_child(piece)
	(piece as Node2D).global_position = at
	return piece


func _chime_wakes() -> void:
	reset_state()
	var arena := make_arena()
	var stone: Variant = _make(arena, STONE_SCENE, &"test_stone", Vector2(600, 400))
	await frames(2)
	check(stone.is_in_group(&"resonant"), "a resonance stone is in group resonant")
	check(stone.has_method("on_chime"), "a resonance stone has on_chime()")
	check(Placeholder.has_kind(&"resonance_stone"), "the stone registers its placeholder kind")
	check(not stone.is_awake, "a resonance stone starts shut")
	check(not (stone.get_node("Shape") as CollisionShape2D).disabled, "a shut stone has collision")
	var chime := make_hitbox(arena, Vector2(600, 400), Layers.Team.PLAYER, 0, 480.0)
	chime.kind = &"chime"
	await frames(3)
	chime.deactivate()
	check(stone.is_awake, "a chime wave wakes the stone")
	check(GameState.has_flag(&"resonated_test_stone"), "waking sets resonated_<id>")
	await frames(2)
	check((stone.get_node("Shape") as CollisionShape2D).disabled, "an awake stone has no collision")
	var visual := stone.get_node(Placeholder.VISUAL_NAME) as CanvasItem
	check(visual != null and not visual.visible, "an awake stone hides its look")
	await dispose(arena)


func _other_hits_do_not() -> void:
	reset_state()
	var arena := make_arena()
	var stone: Variant = _make(arena, DOOR_SCENE, &"test_door", Vector2(600, 400))
	await frames(2)
	var swing := make_hitbox(arena, Vector2(600, 400), Layers.Team.PLAYER, 2, 60.0)
	swing.kind = &"hook"
	await frames(3)
	swing.deactivate()
	check(not stone.is_awake, "a hook swing does not wake a resonance door")
	var flare := make_hitbox(arena, Vector2(600, 400), Layers.Team.PLAYER, 2, 60.0)
	flare.kind = &"flare"
	await frames(3)
	flare.deactivate()
	check(not stone.is_awake, "a flare does not wake a resonance door")
	var blast := make_hitbox(arena, Vector2(600, 400), Layers.Team.NEUTRAL, 4, 150.0)
	blast.kind = &"explosion"
	await frames(3)
	blast.deactivate()
	check(not stone.is_awake, "a pot blast does not wake a resonance door")
	check(not GameState.has_flag(&"resonated_test_door"), "no hit sets the flag")
	check(
		not (stone.get_node("Shape") as CollisionShape2D).disabled,
		"a door no hit reaches keeps collision"
	)
	await dispose(arena)


func _flag_persists() -> void:
	reset_state()
	GameState.set_flag(&"resonated_test_again")
	var arena := make_arena()
	var vault: Variant = _make(arena, VAULT_SCENE, &"test_again", Vector2(600, 400))
	await frames(2)
	check(vault.is_awake, "the flag makes a later visit start with the vault awake")
	check((vault.get_node("Shape") as CollisionShape2D).disabled, "an awake vault has no collision")
	await dispose(arena)


func _scenes_share_script() -> void:
	var looks := {
		STONE_SCENE: &"resonance_stone",
		DOOR_SCENE: &"resonance_door",
		VAULT_SCENE: &"resonance_vault"
	}
	for scene_path: String in looks:
		var packed := load(scene_path) as PackedScene
		check(packed != null, "%s loads" % scene_path)
		if packed == null:
			continue
		var piece: Variant = packed.instantiate()
		check(
			piece.get_script().resource_path == SCRIPT_PATH,
			"%s uses resonance_stone.gd" % scene_path
		)
		check_eq(piece.get("look"), looks[scene_path], "%s has its own look" % scene_path)
		check_eq(piece.get("size"), Vector2(192, 96), "%s fills a 192 px gap" % scene_path)
		piece.free()
	await frames(1)


func _paired_real_chime_updates_disabled_peer() -> void:
	for forward in [true, false]:
		reset_state()
		_matching_flag_changes = 0
		var arena := make_arena()
		var source_x := 450.0 if forward else 1500.0
		var peer_x := 1500.0 if forward else 450.0
		var start_x := 300.0 if forward else 1800.0
		var direction := Vector2.RIGHT if forward else Vector2.LEFT
		var source: Variant = _make(arena, STONE_SCENE, &"e194", Vector2(source_x, 480))
		var peer: Variant = _make(arena, STONE_SCENE, &"e194", Vector2(peer_x, 480))
		var wrong: Variant = _make(arena, STONE_SCENE, &"other", Vector2(960, 700))
		var empty: Variant = _make(arena, STONE_SCENE, &"", Vector2(960, 300))
		peer.process_mode = Node.PROCESS_MODE_DISABLED
		await frames(2)
		GameState.set_flag(&"resonated_wrong")
		GameState.set_flag(&"resonated_e194", false)
		var player := make_player(arena, Vector2(start_x, 480))
		GameState.acquire_item(&"lantern_chime")
		await frames(2)
		check(not source.is_awake, "chime item ownership alone leaves the resonance source closed")
		check(not peer.is_awake, "chime item ownership alone leaves disabled peer closed")
		check(not wrong.is_awake and not empty.is_awake, "wrong and empty IDs stay closed")
		GameState.flag_changed.connect(_count_e194_flag)
		check(player.use_item(), "real Lantern Chime activates")
		await frames(40)
		check(source.is_awake, "actual expanding Chime wave wakes the source stone")
		check(GameState.has_flag(&"resonated_e194"), "actual source writes canonical e194 flag")
		check(peer.is_awake, "disabled same-ID peer wakes from canonical flag")
		check(
			(peer.get_node("Shape") as CollisionShape2D).disabled, "disabled peer collider clears"
		)
		check(not peer.hurtbox.enabled, "disabled peer chime hurtbox clears")
		check(not (peer.get_node("Visual") as CanvasItem).visible, "disabled peer visual hides")
		check(not wrong.is_awake and not empty.is_awake, "canonical update leaves other IDs alone")
		check_eq(_matching_flag_changes, 1, "peer restore does not republish the canonical flag")
		var wave_count := get_tree().get_nodes_in_group(&"chime_waves").size()
		GameState.set_flag(&"resonated_e194")
		await frames(2)
		check(peer.is_awake, "repeated true update remains awake")
		check_eq(_matching_flag_changes, 2, "repeated update is not republished")
		check_eq(
			get_tree().get_nodes_in_group(&"chime_waves").size(),
			wave_count,
			"flag restoration does not create another chime wave"
		)
		Input.action_press(&"move_right" if forward else &"move_left")
		await frames(240)
		release_inputs()
		check(
			(player.global_position.x - peer_x) * direction.x > 80.0,
			"real player traverses paired opening from the activated end"
		)
		Input.action_press(&"move_left" if forward else &"move_right")
		await frames(240)
		release_inputs()
		check(
			absf(player.global_position.x - start_x) < 100.0,
			"real player re-enters through paired opening"
		)
		GameState.flag_changed.disconnect(_count_e194_flag)
		await dispose(arena)
		var entries: int = GameState.flag_changed.get_connections().size()
		var reopened: Variant = _make(make_arena(), STONE_SCENE, &"e194", Vector2(600, 400))
		await frames(2)
		check(reopened.is_awake, "re-entry restores awake state from canonical flag")
		await dispose(reopened.get_parent())
		check_eq(
			GameState.flag_changed.get_connections().size(),
			entries,
			"resonance callbacks disconnect when props leave the tree"
		)


func _optional_c06_pair() -> void:
	var first_path := "res://scenes/world/rooms/cave_6_5.tscn"
	var second_path := "res://scenes/world/rooms/cave_6_6.tscn"
	if not ResourceLoader.exists(first_path) or not ResourceLoader.exists(second_path):
		check(true, "actual C06 pair is deferred until both F6 scenes exist")
		return
	# Real compiled pair becomes an additional probe when the room compiler delivery lands.
	reset_state()
	var first := load(first_path) as PackedScene
	var second := load(second_path) as PackedScene
	check(first != null and second != null, "actual C06 paired scenes load")
	if first == null or second == null:
		return
	var arena := make_arena()
	var room_a := first.instantiate() as Node2D
	var room_b := second.instantiate() as Node2D
	arena.add_child(room_a)
	arena.add_child(room_b)
	room_a.position = Vector2.ZERO
	room_b.position = Vector2(0, 2000)
	room_a.visible = true
	room_b.visible = true
	var source: Variant = _find_e194(room_a)
	var peer: Variant = _find_e194(room_b)
	check(source != null and peer != null, "actual C06 scenes contain both e194 stones")
	if source == null or peer == null:
		await dispose(arena)
		return
	peer.process_mode = Node.PROCESS_MODE_DISABLED
	var player := make_player(arena, Vector2(960, 440))
	GameState.acquire_item(&"lantern_chime")
	await frames(2)
	check(player.use_item(), "actual C06 pair accepts a real Chime activation")
	await frames(40)
	check(source.is_awake, "actual C06 source stone wakes from the wave")
	check(peer.is_awake, "actual disabled C06 paired stone syncs from the flag")
	await dispose(arena)


func _find_e194(room: Node2D) -> Variant:
	for prop in room.get_node("Props").get_children():
		if prop.get("resonance_id") == &"e194":
			return prop
	return null


func _count_e194_flag(flag: StringName, value: bool) -> void:
	if flag == &"resonated_e194" and value:
		_matching_flag_changes += 1
