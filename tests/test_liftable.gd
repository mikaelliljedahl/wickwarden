extends TestCase
## Liftable (P06): the mitts lift a small thing, it follows the carrier, a throw flies 480 px at 720 px/s
## and shatters on landing, a wall stops the flight, the throw hits an enemy once, and the ward puts it down.
## The grab zone accepts kind `grab` only.

const SCENE := "res://scenes/world/liftable_rock.tscn"
const AT := Vector2(400, 400)

var _grab_hits := 0
var _hook_hits := 0
var _landed_at := Vector2.ZERO
var _landed_count := 0


func run() -> void:
	await _scene_and_groups()
	await _grab_only()
	await _carry_follows_carrier()
	await _throw_flies_and_shatters()
	await _throw_hits_enemy_once()
	await _wall_stops_throw()
	await _put_down_and_shatter()


func _make(parent: Node, at: Vector2) -> Variant:
	var scene := load(SCENE) as PackedScene
	check(scene != null, "the liftable rock scene loads")
	var rock: Node = scene.instantiate()
	rock.position = at
	parent.add_child(rock)
	rock.shattered.connect(_on_shattered)
	return rock


func _on_shattered(at: Vector2) -> void:
	_landed_at = at
	_landed_count += 1


## A PLAYER hitbox of `kind` at `at`, active at once. Counts its hits in `counter` (a Callable).
func _hitbox_of(parent: Node, kind: StringName, at: Vector2, on_hit: Callable) -> Hitbox:
	var hitbox := make_hitbox(parent, at, Layers.Team.PLAYER, 0, 48.0)
	hitbox.kind = kind
	hitbox.hit_landed.connect(on_hit)
	return hitbox


func _count_grab(_hurtbox: Hurtbox) -> void:
	_grab_hits += 1


func _count_hook(_hurtbox: Hurtbox) -> void:
	_hook_hits += 1


## True once a node is freed or queued to be freed (a freed node cannot be asked anything).
func _gone(node: Variant) -> bool:
	return not is_instance_valid(node) or node.is_queued_for_deletion()


func _scene_and_groups() -> void:
	reset_state()
	var arena := make_arena()
	var rock: Variant = _make(arena, AT)
	await frames(2)
	check(rock.is_in_group(&"liftable"), "the rock is in group liftable")
	check(not rock.is_in_group(&"heavy"), "a rock is not a heavy stone")
	check(rock.get_node_or_null("Visual") != null, "the rock has a Visual child")
	check_eq(rock.collision_layer, Layers.WORLD, "the rock sits on the WORLD layer")
	check(not rock.is_carried(), "a rock starts on the floor")
	await dispose(arena)


func _grab_only() -> void:
	reset_state()
	var arena := make_arena()
	var rock: Variant = _make(arena, AT)
	await frames(2)
	_grab_hits = 0
	_hook_hits = 0
	_hitbox_of(arena, &"grab", AT, _count_grab)
	_hitbox_of(arena, &"hook", AT, _count_hook)
	await frames(3)
	check(_grab_hits >= 1, "a grab hit reaches the rock's grab zone")
	check_eq(_hook_hits, 0, "a hook hit does not reach the rock")
	check(not rock.is_carried(), "a grab hit alone does not lift (the mitts item lifts)")
	await dispose(arena)


func _carry_follows_carrier() -> void:
	reset_state()
	var arena := make_arena()
	var rock: Variant = _make(arena, AT)
	var carrier := Node2D.new()
	carrier.global_position = Vector2(400, 500)
	arena.add_child(carrier)
	await frames(2)
	rock.lift(carrier)
	await frames(2)
	check(rock.is_carried(), "lift(by) carries the rock")
	check((rock.get_node("Shape") as CollisionShape2D).disabled, "a carried rock has no collision")
	check(not (rock.get_node("Hurtbox") as Hurtbox).enabled, "a carried rock takes no grab hit")
	check(
		rock.global_position.distance_to(carrier.global_position + rock.carry_offset) < 1.0,
		"a carried rock floats at the carry offset"
	)
	carrier.global_position = Vector2(600, 500)
	await frames(2)
	check(
		rock.global_position.distance_to(carrier.global_position + rock.carry_offset) < 1.0,
		"the carried rock follows the carrier"
	)
	rock.lift(carrier)
	check(rock.is_carried(), "a second lift changes nothing")
	await dispose(arena)


func _throw_flies_and_shatters() -> void:
	reset_state()
	var arena := make_arena()
	var rock: Variant = _make(arena, AT)
	var carrier := Node2D.new()
	carrier.global_position = AT + Vector2(0, 80)
	arena.add_child(carrier)
	await frames(2)
	rock.lift(carrier)
	await frames(2)
	_landed_count = 0
	rock.throw(Vector2.RIGHT)
	check(not rock.is_carried(), "a thrown rock is no longer carried")
	var start: Vector2 = rock.global_position
	await frames(12)
	check_near(
		rock.global_position.x - start.x, 144.0, 6.0, "a throw covers 720 px/s (144 px in 0.2 s)"
	)
	await seconds(1.0)
	check_eq(_landed_count, 1, "a thrown rock shatters once on landing")
	check_near(_landed_at.x - start.x, 480.0, 8.0, "a throw lands 480 px away")
	check(_gone(rock), "a shattered rock is freed")
	await dispose(arena)


func _throw_hits_enemy_once() -> void:
	reset_state()
	var arena := make_arena()
	var rock: Variant = _make(arena, AT)
	var carrier := Node2D.new()
	carrier.global_position = AT + Vector2(0, 80)
	arena.add_child(carrier)
	var dummy := make_dummy(arena, AT + Vector2(200, 80), 9)
	await frames(2)
	rock.lift(carrier)
	await frames(2)
	rock.throw(Vector2.RIGHT)
	await seconds(1.2)
	check_eq(dummy.hp, 6, "a thrown rock hits an enemy for 3, once (flight and landing together)")
	await dispose(arena)


func _wall_stops_throw() -> void:
	reset_state()
	var arena := make_arena([Rect2(540, 300, 20, 200)])
	var rock: Variant = _make(arena, AT)
	var carrier := Node2D.new()
	carrier.global_position = AT + Vector2(0, 40)
	arena.add_child(carrier)
	await frames(2)
	rock.lift(carrier)
	await frames(2)
	_landed_count = 0
	rock.throw(Vector2.RIGHT)
	await seconds(1.0)
	check_eq(_landed_count, 1, "a wall stops a thrown rock and it shatters")
	check(_landed_at.x < 540.0, "the rock lands before the wall")
	check(_landed_at.x > 480.0, "the rock lands at the wall, not far before it")
	await dispose(arena)


func _put_down_and_shatter() -> void:
	reset_state()
	var arena := make_arena()
	var rock: Variant = _make(arena, AT)
	var carrier := Node2D.new()
	carrier.global_position = AT
	arena.add_child(carrier)
	await frames(2)
	rock.lift(carrier)
	await frames(2)
	rock.put_down(Vector2(300, 300))
	await frames(2)
	check(not rock.is_carried(), "put_down sets the rock on the floor")
	check(
		rock.global_position.distance_to(Vector2(300, 300)) < 1.0, "put_down places it at the point"
	)
	check(
		(rock.get_node("Hurtbox") as Hurtbox).enabled, "a rock on the floor takes a grab hit again"
	)
	rock.lift(carrier)
	await frames(2)
	rock.shatter()
	await seconds(0.3)
	check(_gone(rock), "shatter breaks a carried rock")
	await dispose(arena)
