extends TestCase
## Wax seal: a flare hitbox melts it at once and it opens for good with the flag melted_<id>; a hook
## swing, a sling slug or fire does not melt it; a later visit starts open; melt() is the same opening.

const SEAL := "res://scenes/world/wax_seal.tscn"
const AT := Vector2(400, 400)


func run() -> void:
	await _flare_melts_then_opens()
	await _other_hits_do_nothing()
	await _flag_keeps_it_open_on_reentry()
	_scene_has_its_look()


## Builds a seal of `scene_path` with a seal id, in the arena at `at`.
func _make_seal(parent: Node, id: StringName, at: Vector2) -> Variant:
	var scene := load(SEAL) as PackedScene
	var seal: Node = scene.instantiate()
	seal.set(&"seal_id", id)
	parent.add_child(seal)
	(seal as Node2D).global_position = at
	return seal


## A Hitbox of `kind` and the PLAYER team (like the charge flare or the hook), active at `at`.
func _make_hit(parent: Node, kind: StringName, at: Vector2) -> Hitbox:
	var hitbox := Hitbox.new()
	hitbox.kind = kind
	hitbox.team = Layers.Team.PLAYER
	hitbox.add_circle(24.0)
	parent.add_child(hitbox)
	hitbox.global_position = at
	hitbox.activate()
	return hitbox


func _flare_melts_then_opens() -> void:
	reset_state()
	var arena := make_arena()
	var seal: Variant = _make_seal(arena, &"test_seal", AT)
	await frames(2)
	check(not seal.is_open, "a wax seal starts closed")
	check(not (seal.get_node("Shape") as CollisionShape2D).disabled, "a closed seal has collision")
	check(not GameState.has_flag(&"melted_test_seal"), "no flag before the melt")
	var flare := _make_hit(arena, &"flare", AT)
	await frames(2)
	check(seal.is_open, "a charge flare melts the seal at once")
	check(GameState.has_flag(&"melted_test_seal"), "melting sets flag melted_<id>")
	check((seal.get_node("Shape") as CollisionShape2D).disabled, "an open seal has no collision")
	check(not (seal.get_node("Visual") as CanvasItem).visible, "an open seal hides its look")
	flare.deactivate()
	await dispose(flare)
	await dispose(arena)


func _other_hits_do_nothing() -> void:
	reset_state()
	var arena := make_arena()
	var seal: Variant = _make_seal(arena, &"test_other", AT)
	await frames(2)
	var hook := _make_hit(arena, &"hook", AT)
	await seconds(0.5)
	check(not seal.is_open, "a hook swing does not melt a wax seal")
	hook.deactivate()
	await dispose(hook)
	var sling := _make_hit(arena, &"sling", AT)
	await seconds(0.5)
	check(not seal.is_open, "a sling slug does not melt a wax seal")
	sling.deactivate()
	await dispose(sling)
	var fire := _make_hit(arena, &"fire", AT)
	await seconds(0.5)
	check(not seal.is_open, "a fire touch does not melt a wax seal")
	check(not GameState.has_flag(&"melted_test_other"), "other hits set no flag")
	fire.deactivate()
	await dispose(fire)
	await dispose(arena)


func _flag_keeps_it_open_on_reentry() -> void:
	reset_state()
	var arena := make_arena()
	var first: Variant = _make_seal(arena, &"test_reenter", AT)
	await frames(2)
	check(first.melt(), "melt() opens a closed seal")
	check(not first.melt(), "melt() on an open seal does nothing")
	await dispose(arena)
	# A new visit: the room is built again from its scene and the flag is still set.
	var later := make_arena()
	var again: Variant = _make_seal(later, &"test_reenter", AT)
	await frames(2)
	check(again.is_open, "a later visit starts with the seal open")
	check(
		(again.get_node("Shape") as CollisionShape2D).disabled, "a re-opened seal has no collision"
	)
	var flare := _make_hit(later, &"flare", AT)
	await frames(2)
	check(again.melt() == false, "an open seal cannot be melted again")
	flare.deactivate()
	await dispose(flare)
	await dispose(later)


func _scene_has_its_look() -> void:
	var scene := load(SEAL) as PackedScene
	check(scene != null, "the wax seal scene loads")
	check(Placeholder.has_kind(&"wax_seal"), "the wax seal look is registered")
