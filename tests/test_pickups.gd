extends TestCase
## Pickups: effects, collection by the player and by a carrier, timeout and blink, persistence.


func run() -> void:
	await _effects()
	await _timeout_and_blink()
	await _carrier()
	await _persistence_and_items()


func _effects() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 300))
	await frames(2)
	GameState.damage(4)
	PickupBase.spawn(&"ember", arena, Vector2(300, 300))
	await frames(3)
	check_eq(GameState.health, 4, "ember heals 2 half-hearts (one heart)")
	PickupBase.spawn(&"brass_bit", arena, Vector2(300, 300))
	PickupBase.spawn(&"brass_coin", arena, Vector2(300, 300))
	await frames(3)
	check_eq(GameState.currency, 6, "brass bit +1, brass coin +5")
	PickupBase.spawn(&"pitch_pot_bundle", arena, Vector2(300, 300))
	await frames(3)
	check_eq(GameState.pitch_pots, 4, "bundle +4 pitch pots")
	PickupBase.spawn(&"key", arena, Vector2(300, 300), false)
	await frames(3)
	check_eq(GameState.keys, 1, "key +1")
	PickupBase.spawn(&"wick_core", arena, Vector2(300, 300), false)
	await frames(3)
	check_eq(GameState.max_health, 8, "wick core +1 max heart")
	check_eq(GameState.health, 8, "wick core heals fully")
	var far := PickupBase.spawn(&"brass_bit", arena, Vector2(900, 900))
	await frames(5)
	check(is_instance_valid(far) and not far.is_collected, "a pickup out of reach is not collected")
	check_eq(GameState.currency, 6, "currency unchanged")
	check(player.collector != null, "player has a collector area")
	var scene_kinds := ["ember", "brass_bit", "brass_coin", "pitch_pot_bundle", "key", "wick_core"]
	for kind in scene_kinds:
		var scene := load("res://scenes/pickups/%s.tscn" % kind) as PackedScene
		var node := scene.instantiate() as PickupBase
		check(
			node != null and node.kind == StringName(kind),
			"scene %s.tscn is a pickup of that kind" % kind
		)
		node.free()
	await dispose(arena)


func _timeout_and_blink() -> void:
	reset_state()
	var arena := make_arena()
	var timed := PickupBase.spawn(&"brass_bit", arena, Vector2(900, 900))
	var placed := PickupBase.spawn(&"key", arena, Vector2(950, 900), false)
	await seconds(5.5)
	var visual := timed.get_node("Visual") as CanvasItem
	check(is_instance_valid(timed) and visual.visible, "no blink before the last 2 s")
	var hidden_frames := 0
	var shown_frames := 0
	for i in range(int(2.0 * 60.0) - 20):
		await frames(1)
		if is_instance_valid(timed):
			if visual.visible:
				shown_frames += 1
			else:
				hidden_frames += 1
	check(hidden_frames > 5 and shown_frames > 5, "blinks during the last 2 s")
	await seconds(1.0)
	check(not is_instance_valid(timed), "a dropped pickup disappears after 8 s")
	await seconds(3.0)
	check(is_instance_valid(placed), "placed pickups never time out")
	check(placed.time_left() == INF, "placed pickups have no timer")
	await dispose(arena)


func _carrier() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 300))
	var moth := Node2D.new()
	arena.add_child(moth)
	moth.global_position = Vector2(900, 900)
	var carrier := PickupCollector.new()
	carrier.carrier = true
	carrier.add_circle(30.0)
	moth.add_child(carrier)
	var picked: Array[PickupBase] = []
	carrier.picked.connect(func(p: PickupBase) -> void: picked.append(p))
	var coin := PickupBase.spawn(&"brass_coin", arena, Vector2(900, 900))
	await frames(4)
	check_eq(picked.size(), 1, "a carrier collector reports the pickup it touched")
	check(coin.is_carried() and not coin.is_collected, "a carried pickup is not applied yet")
	check_eq(GameState.currency, 0, "carried pickups give nothing yet")
	moth.global_position = Vector2(700, 700)
	await frames(3)
	check_near(
		coin.global_position.distance_to(moth.global_position),
		0.0,
		1.0,
		"the pickup follows its carrier"
	)
	await seconds(9.0)
	check(is_instance_valid(coin), "a carried pickup does not time out")
	moth.global_position = player.global_position
	await frames(4)
	check_eq(GameState.currency, 5, "bringing it to the player collects it")
	check(not is_instance_valid(coin), "collected pickup is freed")
	var direct := PickupBase.spawn(&"ember", arena, Vector2(900, 900), false)
	check_eq(direct.collect(player), true, "collect() applies the effect")
	check_eq(direct.collect(player), false, "collect() works only once")
	await dispose(arena)


func _persistence_and_items() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 300))
	await frames(2)
	var placed := PickupBase.new()
	placed.kind = &"key"
	placed.persistent_id = &"ow_2_1_key"
	arena.add_child(placed)
	placed.global_position = Vector2(300, 300)
	await frames(3)
	check_eq(GameState.keys, 1, "placed key collected")
	check(GameState.has_flag(&"picked_ow_2_1_key"), "collecting a placed pickup sets its flag")
	var again := PickupBase.new()
	again.kind = &"key"
	again.persistent_id = &"ow_2_1_key"
	arena.add_child(again)
	await frames(2)
	check(
		not is_instance_valid(again) or again.is_queued_for_deletion(),
		"a collected placed pickup is gone on the next visit"
	)
	var item := PickupBase.new()
	item.kind = &"item"
	item.item_id = &"tether_moth"
	item.persistent_id = &"moth"
	arena.add_child(item)
	item.global_position = player.global_position
	await frames(3)
	check(GameState.has_item(&"tether_moth"), "an item pickup grants the sub-item")
	check_eq(GameState.active_item, &"tether_moth", "and selects it")
	await dispose(arena)
