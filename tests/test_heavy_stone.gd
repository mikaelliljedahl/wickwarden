extends TestCase
## Heavy stones (P06): LIFT stones are carried by the mitts and gone for good once thrown; PUSH stones slide
## one 96 px step after 0.5 s of holding, stop at a wall, take at most 3 steps, and keep their final position
## through a reload (flags moved_<id> and moved_<id>@<path>). The hook never moves them.

const LIFT := "res://scenes/world/heavy_stone.tscn"
const BOULDER := "res://scenes/world/heavy_boulder.tscn"
const DOOR := "res://scenes/world/heavy_door.tscn"
const STONES := "res://scenes/world/heavy_stones.tscn"
const AT := Vector2(400, 400)
const STEP := 96.0

var _hook_hits := 0


func run() -> void:
	await _groups_and_looks()
	await _push_needs_hold_then_slides()
	await _push_stops_at_wall()
	await _three_steps_then_no_more()
	await _push_position_persists()
	await _lift_only_by_mitts_and_mode()
	await _thrown_stone_leaves_gap_for_good()
	await _hook_does_nothing()


func _make(parent: Node, scene_path: String, stone_id: StringName, at: Vector2) -> Variant:
	var scene := load(scene_path) as PackedScene
	check(scene != null, "%s loads" % scene_path)
	var stone: Node = scene.instantiate()
	stone.set(&"stone_id", stone_id)
	(stone as Node2D).position = at
	parent.add_child(stone)
	return stone


## Holds toward `dir` for `calls` physics frames (one try_move each), then lets go and waits 30 frames.
func _push(stone: Variant, dir: Vector2, calls: int) -> void:
	for i in range(calls):
		stone.try_move(dir)
		await frames(1)
	await frames(30)


func _groups_and_looks() -> void:
	reset_state()
	var arena := make_arena()
	var lift: Variant = _make(arena, LIFT, &"t_lift_look", AT)
	var boulder: Variant = _make(arena, BOULDER, &"t_boulder_look", Vector2(400, 700))
	var door: Variant = _make(arena, DOOR, &"t_door_look", Vector2(400, 1000))
	var stones: Variant = _make(arena, STONES, &"t_stones_look", Vector2(400, 1300))
	await frames(2)
	check(lift.is_in_group(&"heavy"), "a heavy stone is in group heavy")
	check(not lift.is_in_group(&"liftable"), "a heavy stone is not in group liftable")
	check_eq(lift.mode, 0, "the heavy stone scene is LIFT")
	check_eq(boulder.mode, 1, "the boulder scene is PUSH")
	check_eq(door.mode, 1, "the heavy door scene is PUSH")
	check_eq(stones.mode, 0, "the heavy stones scene is LIFT")
	check(lift.get_node_or_null("Visual") != null, "a heavy stone has a Visual child")
	check(boulder.get_node_or_null("Visual") != null, "a boulder has a Visual child")
	check(Placeholder.has_kind(&"heavy_door"), "the heavy door look is registered")
	await dispose(arena)


func _push_needs_hold_then_slides() -> void:
	reset_state()
	var arena := make_arena()
	var boulder: Variant = _make(arena, BOULDER, &"t_boulder", AT)
	await frames(2)
	await _push(boulder, Vector2.RIGHT, 20)
	check_near(boulder.global_position.x, AT.x, 0.5, "a boulder does not move on 0.33 s of holding")
	check(not GameState.has_flag(&"moved_t_boulder"), "no flag before the first slide")
	await _push(boulder, Vector2.RIGHT, 36)
	check_near(
		boulder.global_position.x, AT.x + STEP, 0.5, "after 0.5 s of holding it slides 96 px"
	)
	check(GameState.has_flag(&"moved_t_boulder"), "a slide sets flag moved_<id>")
	check(GameState.has_flag(&"moved_t_boulder@R"), "a slide saves its path (R)")
	await dispose(arena)


func _push_stops_at_wall() -> void:
	reset_state()
	var arena := make_arena([Rect2(448, 300, 40, 200)])
	var boulder: Variant = _make(arena, BOULDER, &"t_wall_boulder", AT)
	await frames(2)
	await _push(boulder, Vector2.RIGHT, 80)
	check_near(boulder.global_position.x, AT.x, 0.5, "a wall stops the boulder")
	check(not GameState.has_flag(&"moved_t_wall_boulder"), "a blocked push sets no flag")
	await dispose(arena)


func _three_steps_then_no_more() -> void:
	reset_state()
	var arena := make_arena()
	var boulder: Variant = _make(arena, BOULDER, &"t_steps", AT)
	await frames(2)
	for i in range(3):
		await _push(boulder, Vector2.RIGHT, 33)
	check_near(boulder.global_position.x, AT.x + 3.0 * STEP, 0.5, "three pushes move it 288 px")
	check(GameState.has_flag(&"moved_t_steps@RRR"), "the path after three steps is RRR")
	check(not GameState.has_flag(&"moved_t_steps@RR"), "an old path flag is removed")
	await _push(boulder, Vector2.RIGHT, 33)
	check_near(
		boulder.global_position.x,
		AT.x + 3.0 * STEP,
		0.5,
		"a fourth push does nothing (3 steps max)"
	)
	await dispose(arena)


func _push_position_persists() -> void:
	var arena := make_arena()
	var boulder: Variant = _make(arena, BOULDER, &"t_steps", AT)
	await frames(2)
	check_near(
		boulder.global_position.x,
		AT.x + 3.0 * STEP,
		0.5,
		"a reloaded boulder keeps its final position"
	)
	check(boulder.path == "RRR", "a reloaded boulder knows its path")
	await dispose(arena)


func _lift_only_by_mitts_and_mode() -> void:
	reset_state()
	var arena := make_arena()
	var lift: Variant = _make(arena, LIFT, &"t_lift_mode", AT)
	var boulder: Variant = _make(arena, BOULDER, &"t_boulder_mode", Vector2(400, 700))
	var carrier := Node2D.new()
	carrier.global_position = AT
	arena.add_child(carrier)
	await frames(2)
	boulder.lift_by_mitts(carrier)
	await frames(2)
	check(not boulder.is_carried(), "the mitts cannot lift a PUSH boulder")
	lift.try_move(Vector2.RIGHT)
	await _push(lift, Vector2.RIGHT, 40)
	check_near(lift.global_position.x, AT.x, 0.5, "try_move does nothing to a LIFT stone")
	lift.lift_by_mitts(carrier)
	await frames(2)
	check(lift.is_carried(), "the mitts lift a LIFT stone")
	await dispose(arena)


func _thrown_stone_leaves_gap_for_good() -> void:
	reset_state()
	var arena := make_arena()
	var lift: Variant = _make(arena, LIFT, &"t_gap", AT)
	var carrier := Node2D.new()
	carrier.global_position = AT + Vector2(0, 80)
	arena.add_child(carrier)
	await frames(2)
	lift.lift_by_mitts(carrier)
	await frames(2)
	lift.throw(Vector2.UP)
	await seconds(1.2)
	check(_gone(lift), "a thrown heavy stone shatters and is freed")
	check(GameState.has_flag(&"moved_t_gap"), "the shattered stone sets flag moved_<id>")
	var again: Variant = _make(arena, LIFT, &"t_gap", AT)
	await frames(2)
	check(_gone(again), "the gap stays open on a later visit")
	await dispose(arena)


func _hook_does_nothing() -> void:
	reset_state()
	var arena := make_arena()
	var boulder: Variant = _make(arena, BOULDER, &"t_hook", AT)
	await frames(2)
	var hook := make_hitbox(arena, AT, Layers.Team.PLAYER, 0, 48.0)
	hook.kind = &"hook"
	hook.hit_landed.connect(_count_hook)
	await frames(3)
	check_eq(_hook_hits, 0, "a hook swing does not reach a heavy stone")
	check_near(boulder.global_position.x, AT.x, 0.5, "a hook swing does not move it")
	await dispose(arena)


## True once a node is freed or queued to be freed (a freed node cannot be asked anything).
func _gone(node: Variant) -> bool:
	return not is_instance_valid(node) or node.is_queued_for_deletion()


func _count_hook(_hurtbox: Hurtbox) -> void:
	_hook_hits += 1
