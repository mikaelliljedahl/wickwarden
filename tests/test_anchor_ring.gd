extends TestCase
## Anchor ring (P05): the ring is in group anchor_ring with a NEUTRAL hurtbox on PROP_HURTBOX and its look;
## get_anchor_position() is its world point; is_in_range() honours max_range (0 means no limit); a reel hit
## emits `hooked` once, while a hook swing and a flare do not reach it.

const RING_SCENE := "res://scenes/world/anchor_ring.tscn"
const POCKET_SCENE := "res://scenes/world/anchor_pocket.tscn"
const RING_AT := Vector2(900, 400)


func run() -> void:
	await _ring_and_look()
	_position_query()
	_range_query()
	await _reel_hit_emits_hooked()
	await _other_hits_do_not_reach_it()


func _make(parent: Node, scene_path: String, at: Vector2) -> Variant:
	var scene := load(scene_path) as PackedScene
	var node: Node = scene.instantiate()
	parent.add_child(node)
	(node as Node2D).global_position = at
	return node


func _ring_and_look() -> void:
	reset_state()
	var arena := make_arena()
	var ring: Variant = _make(arena, RING_SCENE, RING_AT)
	var pocket: Variant = _make(arena, POCKET_SCENE, RING_AT + Vector2(200, 0))
	await frames(2)
	check(ring.is_in_group(&"anchor_ring"), "a ring is in group anchor_ring")
	check(pocket.is_in_group(&"anchor_ring"), "a pocket ring is in group anchor_ring")
	check(ring.hurtbox.team == Layers.Team.NEUTRAL, "the hurtbox is NEUTRAL")
	check(ring.hurtbox.collision_layer == Layers.PROP_HURTBOX, "the hurtbox sits on PROP_HURTBOX")
	check(ring.get_node_or_null(Placeholder.VISUAL_NAME) != null, "a ring has a Visual child")
	check(ring.get(&"look") == &"anchor_ring", "the ring scene uses the anchor_ring look")
	check(pocket.get(&"look") == &"anchor_pocket", "the pocket scene uses the anchor_pocket look")
	check(
		Placeholder.has_kind(&"anchor_ring") and Placeholder.has_kind(&"anchor_pocket"),
		"both looks are registered"
	)
	await dispose(arena)


func _position_query() -> void:
	reset_state()
	var arena := make_arena()
	var ring: Variant = _make(arena, RING_SCENE, RING_AT)
	await frames(1)
	check(ring.get_anchor_position() == RING_AT, "get_anchor_position() is the world position")
	ring.global_position = Vector2(300, 250)
	check(ring.get_anchor_position() == Vector2(300, 250), "the position follows the node")
	await dispose(arena)


func _range_query() -> void:
	reset_state()
	var arena := make_arena()
	var ring: Variant = _make(arena, RING_SCENE, RING_AT)
	await frames(1)
	check(ring.is_in_range(RING_AT + Vector2(5000, 0)), "max_range 0 means no limit")
	ring.max_range = 300.0
	check(ring.is_in_range(RING_AT + Vector2(300, 0)), "a point exactly max_range away is in range")
	check(ring.is_in_range(RING_AT + Vector2(0, 299)), "a point inside max_range is in range")
	check(
		not ring.is_in_range(RING_AT + Vector2(301, 0)), "a point beyond max_range is out of range"
	)
	await dispose(arena)


func _reel_hit_emits_hooked() -> void:
	reset_state()
	var arena := make_arena()
	var ring: Variant = _make(arena, RING_SCENE, RING_AT)
	await frames(2)
	var hits: Array = []
	ring.hooked.connect(func(hitbox: Hitbox) -> void: hits.append(hitbox))
	var tip := make_hitbox(arena, RING_AT, Layers.Team.PLAYER, 1, 12.0)
	tip.kind = &"reel"
	await frames(3)
	check(hits.size() == 1, "a reel hit emits hooked once")
	check(hits.size() > 0 and hits[0] == tip, "hooked carries the reel hitbox")
	await dispose(arena)


func _other_hits_do_not_reach_it() -> void:
	reset_state()
	var arena := make_arena()
	var ring: Variant = _make(arena, RING_SCENE, RING_AT)
	await frames(2)
	var hits: Array = []
	ring.hooked.connect(func(hitbox: Hitbox) -> void: hits.append(hitbox))
	var swing := make_hitbox(arena, RING_AT, Layers.Team.PLAYER, 2, 40.0)
	swing.kind = &"hook"
	var flare := make_hitbox(arena, RING_AT, Layers.Team.PLAYER, 4, 40.0)
	flare.kind = &"flare"
	var slug := make_hitbox(arena, RING_AT, Layers.Team.PLAYER, 2, 40.0)
	slug.kind = &"sling"
	await frames(4)
	check(hits.is_empty(), "a hook, a flare and a sling hit do not reach the ring")
	await dispose(arena)
