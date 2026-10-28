extends TestCase
## Cinder wick (T01): one flame at a time, the flame rolls up to 288 px and stops at a WORLD wall (never closer
## than 96 px), it burns a stand-in burnable open, lights a brazier, ticks an enemy and sticks to it, and the item
## ends with its flame.

const HEDGE := "res://scenes/world/thorn_hedge.tscn"
const START := Vector2(300, 500)


func run() -> void:
	await _cast_visual_and_fallback()
	await _refuses_a_second_flame()
	await _rolls_its_full_reach_on_open_ground()
	await _stops_at_a_wall()
	await _stops_no_closer_than_96_px()
	await _burns_a_stand_in_burnable()
	await _lights_a_brazier()
	await _ticks_and_sticks_to_an_enemy()


func _items() -> Array:
	return get_tree().get_nodes_in_group(ItemBase.group_name(&"cinder_wick"))


func _flames() -> Array:
	return get_tree().get_nodes_in_group(&"cinder_flames")


func _use(player: Player) -> void:
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"cinder_wick")


func _cast_visual_and_fallback() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	await frames(2)
	_use(player)
	check(player.use_item(), "the painted cue starts with a real cast")
	var item := _items()[0] as Node2D
	var cue := item.get_node_or_null("Visual") as Node2D
	check(cue != null, "the cast has a visual")
	if cue != null:
		var painted := cue.get_node_or_null("CinderCast") as Sprite2D
		check(painted != null and painted.texture != null, "the cast loads its painted cue")
		if painted != null:
			for direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
				cue.call(&"set_facing", direction)
				check_near(painted.rotation, direction.angle(), 0.001, "cue follows cast facing")
		check(cue.visible, "cue is visible during the root")
	await seconds(0.1)
	check_eq(_flames().size(), 0, "the cue precedes the flame")
	await seconds(0.2)
	check_eq(_flames().size(), 1, "the flame launches after the root")
	if cue != null:
		check(not cue.visible, "the cue hides when the flame launches")
	await dispose(arena)

	var cue_script := load("res://scripts/art/tool_cue_visual.gd") as GDScript
	if cue_script == null:
		check(false, "tool cue script loads for fallback")
		return
	var fallback := cue_script.new() as Node2D
	fallback.set(&"_kind", &"cinder_wick")
	fallback.set(&"art_path", "res://missing-cinder-cast.png")
	add_child(fallback)
	check(fallback.get_node_or_null("CinderCast") == null, "missing art retains geometric fallback")
	check(fallback.visible, "fallback visual remains visible")
	fallback.queue_free()
	var other := cue_script.new() as Node2D
	other.set(&"_kind", &"tallow_sling")
	add_child(other)
	check(other.get_node_or_null("CinderCast") == null, "other tools keep their own cue")
	other.queue_free()


func _refuses_a_second_flame() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	await frames(2)
	_use(player)
	check(player.use_item(), "the first flame is lit")
	check(not player.use_item(), "a second flame is refused while the first is alive")
	check_eq(_items().size(), 1, "a refused use leaves no second item in the tree")
	await seconds(0.3)
	check_eq(_flames().size(), 1, "one flame is in the world after the 0.2 s root")
	var flame := _flames()[0] as Area2D
	var glow := flame.get_node_or_null("Glow") as PointLight2D
	check(glow != null and glow.enabled, "the active flame carries an enabled point light")
	if glow != null:
		check_near(
			glow.texture_scale,
			LightTexture.scale_for(220.0),
			0.001,
			"the flame light uses the established 220 px brazier radius"
		)
		check(
			glow.color.r > glow.color.b and glow.color.g > glow.color.b,
			"the flame light uses a warm color"
		)
	await seconds(4.5)
	check_eq(_flames().size(), 0, "the flame is gone after its 3.0 s stand")
	check_eq(_items().size(), 0, "the item ends with its flame")
	check(player.use_item(), "after the flame is gone the next flame is lit")
	await seconds(4.5)
	await dispose(arena)


func _rolls_its_full_reach_on_open_ground() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	await frames(2)
	_use(player)
	check(player.use_item(), "the flame is lit on open ground")
	await seconds(0.5)
	check_eq(_flames().size(), 1, "the flame is still rolling at 0.5 s")
	check(
		(_flames()[0] as Node2D).global_position.x < START.x + 336.0 - 40.0,
		"the flame is still on its way at 0.5 s"
	)
	await seconds(0.7)
	check_near(
		(_flames()[0] as Node2D).global_position.x,
		START.x + 336.0,
		1.0,
		"the flame rolls 288 px past its 48 px start (336 px from Tamsin)"
	)
	check_near(
		(_flames()[0] as Node2D).global_position.y, START.y, 0.5, "the flame stays on the line"
	)
	await dispose(arena)


func _stops_at_a_wall() -> void:
	reset_state()
	var wall := Rect2(Vector2(420, 300), Vector2(32, 400))
	var arena := make_arena([wall])
	var player := make_player(arena, START)
	await frames(2)
	_use(player)
	check(player.use_item(), "the flame is lit with a wall ahead")
	await seconds(1.5)
	check_near(
		(_flames()[0] as Node2D).global_position.x,
		420.0,
		1.0,
		"the flame stops at the WORLD wall, 120 px ahead"
	)
	await dispose(arena)


func _stops_no_closer_than_96_px() -> void:
	reset_state()
	var wall := Rect2(Vector2(340, 300), Vector2(32, 400))
	var arena := make_arena([wall])
	var player := make_player(arena, START)
	await frames(2)
	_use(player)
	check(player.use_item(), "the flame is lit with a wall close ahead")
	await seconds(1.5)
	check_near(
		(_flames()[0] as Node2D).global_position.x,
		START.x + 96.0,
		1.0,
		"a wall within 96 px puts the flame at 96 px"
	)
	await dispose(arena)


func _burns_a_stand_in_burnable() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	var scene := load(HEDGE) as PackedScene
	var hedge: Variant = scene.instantiate()
	hedge.set(&"burn_id", &"test_cinder_hedge")
	arena.add_child(hedge)
	(hedge as Node2D).global_position = Vector2(560, 500)
	await frames(2)
	_use(player)
	check(player.use_item(), "the flame is lit next to a thorn hedge")
	await seconds(0.2)
	check(not hedge.is_open, "the hedge is not open before the flame touches it")
	await seconds(2.3)
	check(hedge.is_open, "the flame burns the hedge open")
	check(GameState.has_flag(&"burned_test_cinder_hedge"), "the burnt hedge sets its flag")
	await dispose(arena)


func _lights_a_brazier() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	var brazier := Brazier.new()
	brazier.brazier_id = &"test_cinder_brazier"
	arena.add_child(brazier)
	brazier.global_position = Vector2(560, 500)
	await frames(2)
	check(not brazier.lit, "the brazier starts unlit")
	_use(player)
	check(player.use_item(), "the flame is lit next to a brazier")
	await seconds(1.5)
	check(brazier.lit, "the flame lights the brazier")
	check(GameState.has_flag(&"brazier_test_cinder_brazier"), "the lit brazier sets its flag")
	await dispose(arena)


func _ticks_and_sticks_to_an_enemy() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	var enemy := make_dummy(arena, Vector2(500, 500), 20)
	await frames(2)
	_use(player)
	check(player.use_item(), "the flame is lit in front of an enemy")
	await seconds(2.0)
	check(enemy.hp < 20, "the flame ticks the enemy")
	check(enemy.hp >= 20 - 6, "a flame deals at most 6 ticks of 1 damage")
	enemy.global_position = Vector2(500, 260)
	await frames(3)
	check_near(
		(_flames()[0] as Node2D).global_position.y,
		260.0,
		1.0,
		"the flame sticks to the enemy and follows it"
	)
	await seconds(2.0)
	check_eq(_flames().size(), 0, "the flame is spent after its stand")
	await dispose(arena)
