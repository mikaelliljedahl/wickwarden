extends TestCase
## Pickups: effects, collection by the player and by a carrier, timeout and blink, persistence.

const SPRITE_FIXTURE := "res://tests/fixtures/sprites_fixture/sprites.json"


func run() -> void:
	await _item_visuals()
	await _effects()
	await _timeout_and_blink()
	await _carrier()
	await _persistence_and_items()
	await _scoped_keys_big_keys_and_fragments()
	await _requires_flag()
	await _reward_scenes()
	await _pot_bag_and_slug_bundle()
	await _slug_drop_gating()


func _item_visuals() -> void:
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)
	var arena := make_arena()
	for raw_id in ItemRegistry.ids():
		var id := StringName(raw_id)
		var pickup := PickupBase.new()
		pickup.kind = &"item"
		pickup.item_id = id
		arena.add_child(pickup)
		var visual := pickup.get_node_or_null(Placeholder.VISUAL_NAME)
		var expected := StringName("icon_%s" % id)
		check(SpriteVisual.has_art(expected), "%s has its dedicated pickup icon art" % id)
		check(visual is SpriteVisual, "%s pickup uses its painted icon" % id)
		if visual is SpriteVisual:
			check_eq((visual as SpriteVisual).kind, expected, "%s pickup selects its dedicated icon" % id)
		var collider := pickup.get_child(0) as CollisionShape2D
		check(
			collider != null
				and collider.shape is CircleShape2D
				and (collider.shape as CircleShape2D).radius == PickupBase.PICKUP_RADIUS,
			"%s icon leaves the pickup radius unchanged" % id
		)
	await frames(2)
	check_eq(GameState.acquired_item_ids().size(), 0, "showing item icons does not acquire tools")
	await dispose(arena)

	# The fixture has full body art for `walker` and no tool icons, so it exercises the legacy art path.
	SpriteVisual.use_manifest(SPRITE_FIXTURE)
	var fallback_arena := make_arena()
	var body_art := PickupBase.new()
	body_art.kind = &"item"
	body_art.item_id = &"walker"
	fallback_arena.add_child(body_art)
	var body_visual := body_art.get_node_or_null(Placeholder.VISUAL_NAME)
	check(body_visual is SpriteVisual, "an accepted item body art remains a fallback")
	if body_visual is SpriteVisual:
		check_eq((body_visual as SpriteVisual).kind, &"walker", "accepted body art keeps its kind")
	var registered := PickupBase.new()
	registered.kind = &"item"
	registered.item_id = &"tether_moth"
	fallback_arena.add_child(registered)
	var registered_visual := registered.get_node_or_null(Placeholder.VISUAL_NAME)
	check(registered_visual is Placeholder, "a registered item placeholder remains a fallback")
	if registered_visual is Placeholder:
		check_eq((registered_visual as Placeholder).kind, &"tether_moth", "registered item look keeps its kind")
	var generic := PickupBase.new()
	generic.kind = &"item"
	generic.item_id = &"missing_item_art"
	fallback_arena.add_child(generic)
	var generic_visual := generic.get_node_or_null(Placeholder.VISUAL_NAME)
	check(generic_visual is Placeholder, "an unknown item uses the registered generic item look")
	if generic_visual is Placeholder:
		check_eq((generic_visual as Placeholder).kind, &"item", "unknown item falls back to generic pickup")
	await frames(2)
	await dispose(fallback_arena)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)


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


func _scoped_keys_big_keys_and_fragments() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 300))
	await frames(2)
	var cave_key := PickupBase.new()
	cave_key.kind = &"key"
	cave_key.scope = &"c2"
	arena.add_child(cave_key)
	cave_key.global_position = Vector2(300, 300)
	await frames(3)
	check_eq(GameState.keys_in(&"c2"), 1, "a key pickup adds to its own scope")
	check_eq(GameState.keys_in(&"ow"), 0, "and not to the overworld")
	var big := PickupBase.new()
	big.kind = &"big_key"
	big.scope = &"c2"
	arena.add_child(big)
	big.global_position = Vector2(300, 300)
	await frames(3)
	check(GameState.has_big_key(&"c2"), "a big key pickup sets the big key of its cave")
	check(GameState.has_flag(&"bigkey_c2"), "as flag bigkey_c2")
	var frag := PickupBase.new()
	frag.kind = &"fragment"
	frag.scope = &"c2"
	arena.add_child(frag)
	frag.global_position = Vector2(300, 300)
	await frames(3)
	check(GameState.has_flag(&"frag_c2"), "a fragment pickup sets frag_c2")
	check_eq(GameState.fragment_count(), 1, "one fragment is held")
	check(player.collector != null, "the player collects them")
	await dispose(arena)


func _requires_flag() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 300))
	await frames(2)
	var gated := PickupBase.new()
	gated.kind = &"brass_bit"
	gated.requires_flag = &"boss_cave_10_14_defeated"
	arena.add_child(gated)
	gated.global_position = Vector2(300, 300)
	await frames(3)
	check_eq(GameState.currency, 0, "a pickup that needs a flag is not collected while it is unset")
	check(not gated.visible, "and it is invisible while the flag is unset")
	check(not gated.is_collected, "and it is not collected by a collector")
	GameState.set_flag(&"boss_cave_10_14_defeated")
	check(gated.visible, "it shows at once when the flag is set")
	await frames(3)
	check_eq(GameState.currency, 1, "and the player collects it")
	var later := PickupBase.new()
	later.kind = &"brass_bit"
	later.requires_flag = &"boss_cave_10_14_defeated"
	later.global_position = Vector2(300, 300)
	arena.add_child(later)
	await frames(3)
	check_eq(GameState.currency, 2, "a pickup whose flag is already set is active at once")
	var gated_item := PickupBase.new()
	gated_item.kind = &"item"
	gated_item.item_id = &"reed_raft"
	gated_item.requires_flag = &"test_raft_reward_unlocked"
	gated_item.global_position = player.global_position
	arena.add_child(gated_item)
	await frames(2)
	check(not gated_item.visible, "a gated item stays hidden before its unlock flag")
	var gated_visual := gated_item.get_node_or_null(Placeholder.VISUAL_NAME) as SpriteVisual
	check(gated_visual != null, "a gated item keeps its painted icon while hidden")
	if gated_visual != null:
		check_eq(gated_visual.kind, &"icon_reed_raft", "gated reed raft selects its dedicated icon")
	GameState.set_flag(&"test_raft_reward_unlocked")
	check(gated_item.visible, "the gated item appears as soon as its flag is set")
	await frames(3)
	check(GameState.has_item(&"reed_raft"), "the unlocked item still grants its registered tool")
	await dispose(arena)


func _pot_bag_and_slug_bundle() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 300))
	await frames(2)
	var bag_scene := load("res://scenes/pickups/pot_bag.tscn") as PackedScene
	var slug_scene := load("res://scenes/pickups/slug_bundle.tscn") as PackedScene
	check(bag_scene != null and slug_scene != null, "the pot bag and slug bundle scenes load")
	var bag := bag_scene.instantiate() as PickupBase
	arena.add_child(bag)
	bag.global_position = Vector2(300, 300)
	await frames(3)
	check(GameState.has_flag(&"pot_bag_1"), "a pot bag sets the first bag flag")
	check_eq(GameState.pot_max(), 14, "and raises the pitch pot limit to 14")
	var bag_two := PickupBase.spawn(&"pot_bag", arena, Vector2(300, 300), false)
	await frames(3)
	check(GameState.has_flag(&"pot_bag_2"), "a second pot bag sets the second flag")
	check_eq(GameState.pot_max(), 18, "and the limit becomes 18")
	check(not is_instance_valid(bag_two), "the second pot bag is collected and freed")
	var slug := slug_scene.instantiate() as PickupBase
	arena.add_child(slug)
	slug.global_position = Vector2(300, 300)
	await frames(3)
	check_eq(GameState.slugs, 6, "a slug bundle gives 6 slugs")
	check(not is_instance_valid(slug), "and the player collects it")
	check(player.collector != null, "the player has a collector")
	await dispose(arena)


func _slug_drop_gating() -> void:
	check_eq(DropTable.pick(0.75, true, false), &"", "no slug bundle before the sling is found")
	check_eq(DropTable.pick(0.749, true, true), &"pitch_pot_bundle", "the pot bundle slice is unchanged")
	check_eq(DropTable.pick(0.75, true, true), &"slug_bundle", "a slug bundle drops at 75 % once the sling is found")
	check_eq(DropTable.pick(0.829, true, true), &"slug_bundle", "the slug bundle slice is 8 %")
	check_eq(DropTable.pick(0.83, true, true), &"", "nothing from 83 % up")
	var counts := {&"ember": 0, &"brass_bit": 0, &"brass_coin": 0, &"pitch_pot_bundle": 0, &"slug_bundle": 0, &"": 0}
	for i in range(1000):
		counts[DropTable.pick(float(i) / 1000.0, true, true)] += 1
	check_eq(counts[&"slug_bundle"], 80, "8 % slug bundle once the sling is found")
	check_eq(counts[&""], 170, "17 % nothing")
	GameState.reset()
	GameState.acquire_item(&"tallow_sling")
	check_eq(DropTable.roll(0.8), &"slug_bundle", "roll() reads the sling from GameState")


func _reward_scenes() -> void:
	for kind in ["big_key", "fragment"]:
		reset_state()
		var scene := load("res://scenes/pickups/%s.tscn" % kind) as PackedScene
		check(scene != null, "%s scene loads" % kind)
		if scene == null:
			continue
		var reward := scene.instantiate() as PickupBase
		check(reward != null, "%s scene instantiates as PickupBase" % kind)
		if reward == null:
			continue
		check_eq(reward.kind, StringName(kind), "%s scene selects its existing kind" % kind)
		check_eq(reward.timeout, 0.0, "%s is a placed pickup without a timeout" % kind)
		var arena := make_arena()
		var player := make_player(arena, Vector2(300, 300))
		reward.scope = &"c2"
		reward.persistent_id = StringName("scene_%s_c2" % kind)
		reward.requires_flag = &"boss_cave_2_9_defeated"
		reward.position = player.position
		arena.add_child(reward)
		await frames(3)
		var effect_flag := &"bigkey_c2" if kind == "big_key" else &"frag_c2"
		var other_flag := &"bigkey_c1" if kind == "big_key" else &"frag_c1"
		var picked_flag := reward.flag_name()
		check(reward.get_node_or_null("Visual") != null, "%s has a runtime Visual" % kind)
		check_eq(reward.collision_layer, Layers.PICKUP, "%s uses the pickup layer" % kind)
		check(not reward.visible, "%s is hidden before the boss flag" % kind)
		check(not reward.collect(player), "%s rejects direct collection while gated" % kind)
		check(not reward.begin_carry(player), "%s rejects carrying while gated" % kind)
		check(not GameState.has_flag(effect_flag), "%s overlap cannot bypass its gate" % kind)
		check(not GameState.has_flag(picked_flag), "%s is not persisted before collection" % kind)
		GameState.set_flag(&"boss_cave_1_8_defeated")
		check(not reward.visible, "%s ignores another boss flag" % kind)
		GameState.set_flag(&"boss_cave_2_9_defeated")
		check(reward.visible, "%s appears when its required flag is set" % kind)
		await frames(3)
		check(not is_instance_valid(reward), "%s is collected by the player" % kind)
		check(GameState.has_flag(effect_flag), "%s grants its scoped flag" % kind)
		check(not GameState.has_flag(other_flag), "%s leaves other caves unchanged" % kind)
		check(GameState.has_flag(picked_flag), "%s persists collection" % kind)
		check_eq(GameState.keys_in(&"c2"), 0, "%s does not grant a small key" % kind)
		var again := scene.instantiate() as PickupBase
		again.scope = &"c2"
		again.persistent_id = StringName("scene_%s_c2" % kind)
		arena.add_child(again)
		await frames(2)
		check(not is_instance_valid(again), "%s stays gone on a room revisit" % kind)
		var unlocked := scene.instantiate() as PickupBase
		unlocked.scope = &"c3"
		unlocked.requires_flag = &"boss_cave_2_9_defeated"
		unlocked.position = player.position
		arena.add_child(unlocked)
		check(unlocked.visible, "%s starts active if the required flag already exists" % kind)
		await frames(3)
		var next_flag := &"bigkey_c3" if kind == "big_key" else &"frag_c3"
		check(GameState.has_flag(next_flag), "%s also collects with a preexisting flag" % kind)
		await dispose(arena)
