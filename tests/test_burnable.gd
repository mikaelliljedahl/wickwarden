extends TestCase
## Burnable props: a fire hitbox starts the burn, the prop opens after 1.0 s and stays open with the
## flag burned_<id>; a plain hook does not burn it; a re-entered room starts open.

const HEDGE := "res://scenes/world/thorn_hedge.tscn"
const WALL := "res://scenes/world/thorn_wall.tscn"
const DOOR := "res://scenes/world/thorn_door.tscn"
const AT := Vector2(400, 400)


func run() -> void:
	await _fire_burns_then_opens()
	await _other_hits_do_nothing()
	await _flag_keeps_it_open_on_reentry()
	await _direct_on_fire_and_no_flag_without_id()
	_scenes_have_their_look()


## Builds a prop of `scene_path` with a burn id, in the arena at `at`.
func _make_prop(parent: Node, scene_path: String, id: StringName, at: Vector2) -> Variant:
	var scene := load(scene_path) as PackedScene
	var prop: Node = scene.instantiate()
	prop.set(&"burn_id", id)
	parent.add_child(prop)
	(prop as Node2D).global_position = at
	return prop


## A Hitbox of `kind` and the PLAYER team (like the cinder wick flame or the hook), active at `at`.
func _make_hit(parent: Node, kind: StringName, at: Vector2) -> Hitbox:
	var hitbox := Hitbox.new()
	hitbox.kind = kind
	hitbox.team = Layers.Team.PLAYER
	hitbox.add_circle(24.0)
	parent.add_child(hitbox)
	hitbox.global_position = at
	hitbox.activate()
	return hitbox


func _fire_burns_then_opens() -> void:
	reset_state()
	var arena := make_arena()
	var hedge: Variant = _make_prop(arena, HEDGE, &"test_hedge", AT)
	await frames(2)
	check(not hedge.is_open, "a thorn hedge starts closed")
	check(hedge.is_in_group(&"burnable"), "a thorn hedge is in group burnable")
	check(
		not (hedge.get_node("Shape") as CollisionShape2D).disabled, "a closed hedge has collision"
	)
	var fire := _make_hit(arena, &"fire", AT)
	await frames(2)
	check(hedge.is_burning, "a fire touch starts the burn")
	check(not hedge.is_open, "a burning hedge is still closed")
	await seconds(0.5)
	check(not hedge.is_open, "the hedge is still closed half a second into the burn")
	check(not GameState.has_flag(&"burned_test_hedge"), "no flag before the opening")
	await seconds(1.0)
	check(hedge.is_open, "the hedge opens after the 1.0 s burn")
	check(GameState.has_flag(&"burned_test_hedge"), "opening sets flag burned_<id>")
	check(not hedge.is_in_group(&"burnable"), "an open hedge is no longer burnable")
	check((hedge.get_node("Shape") as CollisionShape2D).disabled, "an open hedge has no collision")
	check(not (hedge.get_node("Visual") as CanvasItem).visible, "an open hedge hides its look")
	fire.deactivate()
	await dispose(fire)
	await dispose(arena)


func _other_hits_do_nothing() -> void:
	reset_state()
	var arena := make_arena()
	var wall: Variant = _make_prop(arena, WALL, &"test_wall", AT)
	var door: Variant = _make_prop(arena, DOOR, &"test_door", Vector2(400, 700))
	await frames(2)
	var hook := _make_hit(arena, &"hook", AT)
	var flare := _make_hit(arena, &"flare", Vector2(400, 700))
	await seconds(1.5)
	check(not wall.is_burning and not wall.is_open, "a hook hit does not burn a thorn wall")
	check(not door.is_burning and not door.is_open, "a flare hit does not burn a thorn door")
	check(not GameState.has_flag(&"burned_test_wall"), "a hook hit sets no flag")
	hook.deactivate()
	flare.deactivate()
	await dispose(hook)
	await dispose(flare)
	await dispose(arena)


func _flag_keeps_it_open_on_reentry() -> void:
	reset_state()
	var arena := make_arena()
	var first: Variant = _make_prop(arena, HEDGE, &"test_reenter", AT)
	await frames(2)
	first.on_fire(AT)
	await seconds(1.5)
	check(first.is_open, "the first visit burns the hedge open")
	await dispose(arena)
	# A new visit: the room is built again from its scene and the flag is still set.
	var later := make_arena()
	var again: Variant = _make_prop(later, HEDGE, &"test_reenter", AT)
	await frames(2)
	check(again.is_open, "a later visit starts with the hedge open")
	check(
		(again.get_node("Shape") as CollisionShape2D).disabled, "a reopened hedge has no collision"
	)
	check(not again.is_in_group(&"burnable"), "a reopened hedge is not burnable again")
	await dispose(later)


func _direct_on_fire_and_no_flag_without_id() -> void:
	reset_state()
	var arena := make_arena()
	var anon: Variant = _make_prop(arena, WALL, &"", AT)
	await frames(2)
	anon.on_fire(AT)
	check(anon.is_burning, "on_fire() starts the burn without a fire hitbox")
	await seconds(1.5)
	check(anon.is_open, "a prop with no burn id still opens for this visit")
	check(not GameState.has_flag(&"burned_"), "a prop with no burn id sets no flag")
	anon.on_fire(AT)
	check(not anon.is_burning, "a fire touch on an open prop starts no burn")
	await dispose(arena)


func _scenes_have_their_look() -> void:
	var looks := {HEDGE: &"thorn_hedge", WALL: &"thorn_wall", DOOR: &"thorn_door"}
	for scene_path in looks:
		var scene := load(scene_path) as PackedScene
		check(scene != null, "%s loads" % scene_path)
		if scene == null:
			continue
		var prop: Node = scene.instantiate()
		check(
			prop.get(&"look") == looks[scene_path],
			"%s has look %s" % [scene_path, looks[scene_path]]
		)
		check(
			Placeholder.has_kind(looks[scene_path]),
			"%s is a registered placeholder kind" % scene_path
		)
		check(prop.get(&"size") == Vector2(192, 96), "%s fills a 192 x 96 px gap" % scene_path)
		prop.free()
