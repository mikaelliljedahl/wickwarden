extends TestCase
## Grate (P09): a permanent iron grating. It blocks the player's body, sits in group `grate` on the WORLD
## layer, and the tether moth flies over it and fetches the key behind it.

const SCENE := "res://scenes/world/grate.tscn"
const GRATE_AT := Vector2(600, 400)
const PLAYER_AT := Vector2(600, 600)


func run() -> void:
	await _in_group_on_world_layer()
	await _blocks_player()
	await _moth_fetches_key_behind_grate()


func _make(parent: Node, at: Vector2) -> Variant:
	var scene := load(SCENE) as PackedScene
	check(scene != null, "the grate scene loads")
	var grate: Node = scene.instantiate()
	parent.add_child(grate)
	(grate as Node2D).global_position = at
	return grate


func _in_group_on_world_layer() -> void:
	reset_state()
	var arena := make_arena()
	var grate: Variant = _make(arena, GRATE_AT)
	await frames(2)
	check(grate.is_in_group(&"grate"), "the grate is in group grate")
	check_eq(grate.collision_layer, Layers.WORLD, "the grate sits on the WORLD layer")
	await dispose(arena)


func _blocks_player() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, PLAYER_AT)
	_make(arena, GRATE_AT)
	await frames(2)
	Input.action_press(&"move_up")
	await seconds(1.0)
	release_inputs()
	check(player.global_position.y > GRATE_AT.y, "the grate blocks the player's body")
	await dispose(arena)


func _moth_fetches_key_behind_grate() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, PLAYER_AT)
	_make(arena, GRATE_AT)
	var key := PickupBase.spawn(&"key", arena, Vector2(600, 260), false)
	await frames(2)
	GameState.acquire_item(&"tether_moth")
	player.facing = Vector2.UP
	check(player.use_item(), "the moth is thrown up at the grate")
	await seconds(0.4)
	check(key.is_carried(), "the moth flies over the grate and picks up the key behind it")
	check_eq(GameState.keys_in(&"ow"), 0, "a carried key is not applied yet")
	await seconds(1.5)
	check_eq(GameState.keys_in(&"ow"), 1, "the key is brought back past the grate to the player")
	await dispose(arena)
