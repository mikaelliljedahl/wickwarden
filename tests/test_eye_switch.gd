extends TestCase
## Eye switch: a sling slug turns it on, a hook swing does not; the flag `eye_<id>` persists; a
## portcullis or cell with the same id opens live and on a later visit; other ids stay shut.

const SWITCH_SCENE := "res://scenes/world/eye_switch.tscn"
const PORTCULLIS_SCENE := "res://scenes/world/eye_portcullis.tscn"
const CELL_SCENE := "res://scenes/world/eye_cell.tscn"
const SWITCH_AT := Vector2(400, 400)
const PORTCULLIS_AT := Vector2(900, 400)


func run() -> void:
	await _sling_turns_on_and_opens_blocker()
	await _hook_does_not_turn_on()
	await _persistent_on_and_open_on_revisit()
	await _other_ids_stay_shut()


func _make(parent: Node, scene_path: String, id: StringName, at: Vector2) -> Variant:
	var scene := load(scene_path) as PackedScene
	var node: Node = scene.instantiate()
	node.set(&"eye_id", id)
	parent.add_child(node)
	(node as Node2D).global_position = at
	return node


func _shape_disabled(node: Variant) -> bool:
	return (node.get_node("Shape") as CollisionShape2D).disabled


func _sling_turns_on_and_opens_blocker() -> void:
	reset_state()
	var arena := make_arena()
	var eye: Variant = _make(arena, SWITCH_SCENE, &"test_a", SWITCH_AT)
	var portcullis: Variant = _make(arena, PORTCULLIS_SCENE, &"test_a", PORTCULLIS_AT)
	await frames(2)
	check(not eye.is_on and not portcullis.is_open, "switch and portcullis start off and shut")
	check(eye.is_in_group(&"eye_switch"), "a switch is in group eye_switch")
	check(portcullis.is_in_group(&"eye_blocker"), "a blocker is in group eye_blocker")
	check(not _shape_disabled(portcullis), "a shut portcullis keeps collision")
	var slug := make_hitbox(arena, SWITCH_AT, Layers.Team.PLAYER, 2, 12.0)
	slug.kind = &"sling"
	await frames(3)
	check(eye.is_on, "a sling slug turns the switch on")
	check(GameState.has_flag(&"eye_test_a"), "turning on sets the eye_<id> flag")
	check(portcullis.is_open, "the linked portcullis opens live")
	await frames(2)
	check(_shape_disabled(portcullis), "an open portcullis has no collision")
	check(not portcullis.get_node(Placeholder.VISUAL_NAME).visible, "an open portcullis is hidden")
	await dispose(arena)


func _hook_does_not_turn_on() -> void:
	reset_state()
	var arena := make_arena()
	var eye: Variant = _make(arena, SWITCH_SCENE, &"test_hook", SWITCH_AT)
	var cell: Variant = _make(arena, CELL_SCENE, &"test_hook", PORTCULLIS_AT)
	await frames(2)
	var swing := make_hitbox(arena, SWITCH_AT, Layers.Team.PLAYER, 2, 40.0)
	swing.kind = &"hook"
	var flare := make_hitbox(arena, SWITCH_AT, Layers.Team.PLAYER, 4, 40.0)
	flare.kind = &"flare"
	await frames(4)
	check(not eye.is_on, "a hook swing and a flare do not turn the switch on")
	check(not GameState.has_flag(&"eye_test_hook"), "a refused hit sets no flag")
	check(not cell.is_open and not _shape_disabled(cell), "the cell stays shut")
	await dispose(arena)


func _persistent_on_and_open_on_revisit() -> void:
	reset_state()
	GameState.set_flag(&"eye_test_again")
	var arena := make_arena()
	var eye: Variant = _make(arena, SWITCH_SCENE, &"test_again", SWITCH_AT)
	var cell: Variant = _make(arena, CELL_SCENE, &"test_again", PORTCULLIS_AT)
	await frames(2)
	check(eye.is_on, "the flag makes a later visit start with the switch on")
	check(not eye.hurtbox.enabled, "an on switch takes no more hits")
	check(cell.is_open, "the flag makes a later visit start with the cell open")
	check(_shape_disabled(cell), "a reopened cell has no collision")
	await dispose(arena)


func _other_ids_stay_shut() -> void:
	reset_state()
	var arena := make_arena()
	var eye: Variant = _make(arena, SWITCH_SCENE, &"test_b", SWITCH_AT)
	var other: Variant = _make(arena, PORTCULLIS_SCENE, &"test_c", PORTCULLIS_AT)
	await frames(2)
	var slug := make_hitbox(arena, SWITCH_AT, Layers.Team.PLAYER, 2, 12.0)
	slug.kind = &"sling"
	await frames(3)
	check(eye.is_on, "the switch of id test_b turns on")
	check(not other.is_open and not _shape_disabled(other), "a blocker of another id stays shut")
	check(not GameState.has_flag(&"eye_test_c"), "another id's flag is not set")
	await dispose(arena)
