extends TestCase
## Reel line (T08): one line at a time and a cooldown after it settles; a flying tip pulls Tamsin to a stand-in
## anchor ring (72 px short, hurtbox off during the pull); a pull is refused out of range, onto a pit, and into a
## wall; a wall stops the line; a small pickup rides back to Tamsin; an enemy takes 1; a Reelable reports reel hits.

const RING_SCENE := "res://scenes/world/anchor_ring.tscn"
const PIT_SCENE := "res://scenes/world/pit.tscn"
const REELABLE_SCENE := "res://scenes/world/reelable.tscn"
const START := Vector2(300, 500)


func run() -> void:
	await _refuses_a_second_line()
	await _pulls_to_a_ring()
	await _refuses_a_pull_onto_a_pit()
	await _out_of_range_line_retracts()
	await _wall_stops_the_line()
	await _carries_a_pickup_back()
	await _cooldown_after_the_line_settles()
	await _tip_hits_an_enemy_for_one()
	await _reelable_reports_reel_hits()


func _items() -> Array:
	return get_tree().get_nodes_in_group(ItemBase.group_name(&"reel_line"))


func _tips() -> Array:
	return get_tree().get_nodes_in_group(&"reel_tips")


func _use(player: Player) -> void:
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"reel_line")


func _make(parent: Node, scene_path: String, at: Vector2) -> Variant:
	var scene := load(scene_path) as PackedScene
	var node: Node = scene.instantiate()
	parent.add_child(node)
	(node as Node2D).global_position = at
	return node


func _refuses_a_second_line() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	await frames(2)
	_use(player)
	check(player.use_item(), "the first line is fired")
	check(not player.use_item(), "a second line is refused while the first is out")
	check_eq(_items().size(), 1, "a refused use leaves no second item in the tree")
	await seconds(1.5)
	check_eq(_items().size(), 0, "the item ends after the line and its cooldown")
	check(player.use_item(), "after the cooldown the next line is fired")
	await seconds(1.5)
	await dispose(arena)


func _pulls_to_a_ring() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	var ring: Variant = _make(arena, RING_SCENE, START + Vector2(400, 0))
	await frames(2)
	_use(player)
	check(player.use_item(), "the line is fired at a ring 400 px ahead")
	await seconds(0.5)
	check(player.is_external_motion(), "the anchor pulls Tamsin (external motion)")
	check(not player.hurtbox.enabled, "the hurtbox is off during the pull")
	await seconds(1.0)
	check(not player.is_external_motion(), "the pull ends on arrival")
	check(player.hurtbox.enabled, "the hurtbox is back after the pull")
	check_near(
		player.global_position.x,
		ring.get_anchor_position().x - 72.0,
		2.0,
		"Tamsin lands 72 px before the ring"
	)
	check_near(player.global_position.y, START.y, 1.0, "the pull stays on the line")
	await seconds(0.5)
	check_eq(_items().size(), 0, "the item ends after the pull")
	await dispose(arena)


func _refuses_a_pull_onto_a_pit() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	var ring: Variant = _make(arena, RING_SCENE, START + Vector2(400, 0))
	_make(arena, PIT_SCENE, ring.get_anchor_position() - Vector2(72, 0))
	await frames(2)
	_use(player)
	check(player.use_item(), "the line is fired at a ring with a pit at the landing spot")
	await seconds(1.5)
	check(not player.is_external_motion(), "a pull onto a pit is refused")
	check_near(player.global_position.x, START.x, 1.0, "Tamsin stays where she stood")
	await seconds(1.0)
	check_eq(_items().size(), 0, "the refused line reels back and the item ends")
	await dispose(arena)


func _out_of_range_line_retracts() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	var ring: Variant = _make(arena, RING_SCENE, START + Vector2(400, 0))
	ring.max_range = 200.0
	await frames(2)
	_use(player)
	check(player.use_item(), "the line is fired at a ring out of its range")
	await seconds(1.0)
	check(not player.is_external_motion(), "an out-of-range ring does not pull Tamsin")
	check_near(player.global_position.x, START.x, 1.0, "Tamsin stays where she stood")
	await seconds(1.0)
	check_eq(_items().size(), 0, "the line retracts and the item ends")
	await dispose(arena)


func _wall_stops_the_line() -> void:
	reset_state()
	var arena := make_arena([Rect2(Vector2(400, 300), Vector2(32, 400))])
	var player := make_player(arena, START)
	await frames(2)
	_use(player)
	check(player.use_item(), "the line is fired toward a wall 100 px ahead")
	await seconds(0.09)
	check(
		_tips().size() == 1 and (_tips()[0] as Node2D).global_position.x > START.x + 60.0,
		"the tip stops at the wall and reels back"
	)
	await seconds(1.0)
	check(not player.is_external_motion(), "a wall never pulls Tamsin")
	check_eq(_tips().size(), 0, "the tip is gone after it reels back")
	check_eq(_items().size(), 0, "the item ends after the wall")
	await dispose(arena)


func _carries_a_pickup_back() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	var pickup := PickupBase.spawn(&"brass_bit", arena, START + Vector2(200, 0), false)
	await frames(2)
	_use(player)
	check(player.use_item(), "the line is fired over a brass bit")
	await seconds(0.4)
	check(pickup.is_carried(), "the tip carries the brass bit out")
	await seconds(1.0)
	check_eq(GameState.currency, 1, "the brass bit reaches Tamsin")
	check(
		not is_instance_valid(pickup) or pickup.is_collected,
		"the brass bit is gone after the handover"
	)
	await dispose(arena)


func _cooldown_after_the_line_settles() -> void:
	reset_state()
	var arena := make_arena([Rect2(Vector2(400, 300), Vector2(32, 400))])
	var player := make_player(arena, START)
	await frames(2)
	_use(player)
	check(player.use_item(), "the line is fired at a near wall")
	await seconds(0.3)
	check_eq(_items().size(), 1, "the item lingers while the cooldown runs")
	check(not player.use_item(), "a line is refused during the 0.3 s cooldown")
	await seconds(0.5)
	check(player.use_item(), "a line is fired again after the cooldown")
	await seconds(1.5)
	await dispose(arena)


func _tip_hits_an_enemy_for_one() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	var dummy := make_dummy(arena, START + Vector2(250, 0), 6)
	await frames(2)
	_use(player)
	check(player.use_item(), "the line is fired at a dummy 250 px ahead")
	await seconds(0.6)
	check_eq(dummy.hp, 5, "the reel tip deals 1 damage")
	await seconds(1.5)
	await dispose(arena)


func _reelable_reports_reel_hits() -> void:
	reset_state()
	var arena := make_arena()
	var part: Variant = _make(arena, REELABLE_SCENE, START + Vector2(200, 0))
	await frames(2)
	check(part.is_in_group(&"reelable"), "a reelable part is in group reelable")
	check(
		part.get_node_or_null(Placeholder.VISUAL_NAME) != null, "a reelable part has a Visual child"
	)
	var hits: Array = []
	part.reeled.connect(func(hitbox: Hitbox) -> void: hits.append(hitbox))
	var swing := make_hitbox(arena, part.global_position, Layers.Team.PLAYER, 2, 30.0)
	swing.kind = &"hook"
	await frames(3)
	check(hits.is_empty(), "a hook swing does not reach a reelable part")
	var tip := make_hitbox(arena, part.global_position, Layers.Team.PLAYER, 1, 12.0)
	tip.kind = &"reel"
	await frames(3)
	check_eq(hits.size(), 1, "a reel hit reports once")
	check(hits.size() > 0 and hits[0] == tip, "reeled carries the reel hitbox")
	await dispose(arena)
