extends TestCase
## Resonance stone, door and vault: a chime wave wakes them, a hook swing, a flare or a pot blast does
## not, the awake state persists through the flag resonated_<id>, and the three scenes share one script.

const STONE_SCENE := "res://scenes/world/resonance_stone.tscn"
const DOOR_SCENE := "res://scenes/world/resonance_door.tscn"
const VAULT_SCENE := "res://scenes/world/resonance_vault.tscn"
const SCRIPT_PATH := "res://scripts/world/resonance_stone.gd"


func run() -> void:
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
