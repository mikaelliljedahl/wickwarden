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
	for width in [288.0, 384.0, 400.0]:
		await _real_chasm_round_trip(width)
	await _wide_chasm_refuses_unsafe_landing()
	await _walking_boots_and_grounded_motion_fall()


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


func _chasm(arena: Node, width: float) -> Node2D:
	var pit: Node2D = _make(arena, PIT_SCENE, START + Vector2(40 + width * 0.5, 0))
	pit.size = Vector2(width, 384)
	return pit


## Actual tip, AnchorRings and PitZone in both directions: no stand-in motion or pit immunity.
func _real_chasm_round_trip(width: float) -> void:
	reset_state()
	var arena := make_arena()
	var hero := make_player(arena, START)
	var pit := _chasm(arena, width)
	var far := START + Vector2(width + 176, 0)
	var ring: Node2D = _make(arena, RING_SCENE, far)
	ring.max_range = 576.0
	var home: Node2D = _make(arena, RING_SCENE, START - Vector2(72, 0))
	home.max_range = 576.0
	await frames(3)
	_use(hero)
	for direction in [Vector2.RIGHT, Vector2.LEFT]:
		hero.facing = direction
		Input.action_press(&"ward")
		await frames(2)
		check(hero.ward_up, "ward can be raised before firing")
		check(hero.use_item(), "real reel fires across %d px chasm" % int(width))
		var seen := false
		var over_pit := false
		for i in range(100):
			await frames(1)
			if hero.is_external_motion():
				if not seen:
					check(hero.is_airborne(), "validated real anchor pull is airborne")
					check(not hero.is_on_raft(), "reel never claims raft provenance")
					check(not hero.hurtbox.enabled, "reel keeps hurtbox off")
					check(not hero.ward_up, "ward is down during reel motion")
					check(not hero.use_item(), "items remain blocked during pull")
					check(not hero.take_damage(1, far), "pull remains invulnerable")
				seen = true
				over_pit = over_pit or pit.holds(hero.global_position)
			elif seen:
				break
		check(seen and over_pit, "actual anchor pull travels over live pit")
		var expected := far - Vector2(72, 0) if direction == Vector2.RIGHT else START
		check_eq(hero.global_position, expected, "reel stops exactly72 before target ring")
		check_eq(GameState.health, 6, "real pit does not damage legitimate grapple")
		check(not hero.is_airborne(), "arrival clears airborne state")
		check(hero.hurtbox.enabled, "arrival restores hurtbox")
		check(
			not (hero.get_node("BodyShape") as CollisionShape2D).disabled, "arrival restores body"
		)
		release_inputs()
		await seconds(0.7)
		check(_tips().is_empty() and _items().is_empty(), "line settles before return grapple")
	await dispose(arena)


func _wide_chasm_refuses_unsafe_landing() -> void:
	reset_state()
	var arena := make_arena()
	var hero := make_player(arena, START)
	_chasm(arena, 480.0)
	var ring: Node2D = _make(arena, RING_SCENE, START + Vector2(576, 0))
	ring.max_range = 576.0
	await frames(3)
	_use(hero)
	check(hero.use_item(), "line fires within576 toward480px pit")
	await seconds(1.5)
	check_eq(hero.global_position, START, "unsafe72px stop over480px pit is refused")
	check(not hero.is_airborne(), "refused pull grants no airborne state")
	check_eq(GameState.health, 6, "refusal stays safely on firing bank")
	await dispose(arena)


func _walking_boots_and_grounded_motion_fall() -> void:
	for mode in [&"walk", &"boots", &"grounded_motion"]:
		reset_state()
		var arena := make_arena()
		var hero := make_player(arena, START)
		_chasm(arena, 288.0)
		await frames(3)
		if mode == &"walk":
			Input.action_press(&"move_right")
			await frames(8)
			release_inputs()
		elif mode == &"boots":
			GameState.acquire_item(&"skitter_boots")
			hero.facing = Vector2.RIGHT
			check(hero.use_item(), "boots start ordinary192px leap")
			await seconds(0.6)
		else:
			var path: Array[Vector2] = [START + Vector2(400, 0)]
			hero.begin_external_motion(path, 900.0, {"hurtbox": false})
			await seconds(0.6)
		check_eq(GameState.health, 4, "%s still falls into reel-width pit" % mode)
		check(not hero.is_external_motion(), "%s fall clears motion" % mode)
		await dispose(arena)
