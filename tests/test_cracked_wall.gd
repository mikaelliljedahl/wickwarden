extends TestCase
## Cracked wall: a real pitch pot blast opens it when in range, leaves it closed when out of range,
## and the persistent flag keeps it open on a later visit.

const WALL_SCENE := "res://scenes/world/cracked_wall.tscn"


func run() -> void:
	await _blast_opens_and_flags()
	await _fresh_visit_stays_open()


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
