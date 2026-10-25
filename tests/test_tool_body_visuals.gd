extends TestCase
## Actual Player.use_item for all ten tools, plus painted-body state and missing-art lifecycle.

const BODY_KINDS: Array[StringName] = [
	&"flame", &"slug", &"reed_raft", &"jar_thrown", &"jar_lit", &"reel_tip", &"beam_bolt"
]


func run() -> void:
	SaveGame.enabled = false
	for id in ItemRegistry.ids():
		await _actual_use(id)
	await _directional_bodies()
	await _jar_states()
	await _flame_states()
	await _missing_art()


func _actual_use(id: StringName) -> void:
	reset_state()
	var scene := load("res://scenes/world/world.tscn") as PackedScene
	var world := scene.instantiate() as World
	add_child(world)
	await frames(1)
	world.apply_dev_loadout()
	world.start_at(&"ow_5_6" if id == &"reed_raft" else &"ow_0_0")
	await frames(3)
	for enemy in world.current_room.get_node("Enemies").get_children():
		enemy.queue_free()
	world.player.place_at(world.current_room.global_position + Vector2(960, 480))
	if id == &"reed_raft":
		for post in get_tree().get_nodes_in_group(&"mooring"):
			if post.get_parent().get_parent() == world.current_room:
				world.player.place_at(post.global_position)
				break
	world.player.facing = Vector2.RIGHT
	GameState.set_active_item(id)
	Input.action_press(&"use_item")
	check(world.player.use_item(), "%s real use succeeds" % id)
	_check_bodies(world)
	await frames(3)
	Input.action_release(&"use_item")
	await seconds(0.3)
	_check_bodies(world)
	await seconds(0.3)
	_check_bodies(world)
	await dispose(world)


func _check_bodies(node: Node) -> void:
	if node.name == &"Visual":
		if node is Placeholder:
			check(
				not node.visible or not node.kind in BODY_KINDS,
				"visible physical tool body has painted art: %s" % node.kind
			)
		elif node is SpriteVisual and node.kind in BODY_KINDS:
			check(node.sprite_frames != null, "%s has painted frames" % node.kind)
			check(node.is_playing(), "%s animation is playing" % node.kind)
			if node.kind == &"reed_raft":
				check_eq(
					node.position + node.offset,
					Vector2(-128, -206),
					"raft drawing retains its foot220 anchor and BOARD_OFFSET14"
				)
				check(node.position.y < 0.0, "raft sorts before its rider")
	for child in node.get_children():
		_check_bodies(child)


func _directional_bodies() -> void:
	for direction in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]:
		var arena := make_arena()
		var origin := Node2D.new()
		arena.add_child(origin)
		origin.position = Vector2(600, 500)
		for kind in [&"flame", &"slug", &"reel_tip", &"beam_bolt"]:
			var folder := "enemies" if kind == &"beam_bolt" else "items"
			var scene := load("res://scenes/%s/%s.tscn" % [folder, kind]) as PackedScene
			var body := scene.instantiate() as Node2D
			arena.add_child(body)
			if kind == &"flame":
				body.call(&"launch", origin.position, direction)
			elif kind == &"reel_tip":
				body.call(&"launch", origin, direction)
			elif kind == &"slug":
				body.position = origin.position
				body.call(&"launch", direction)
			else:
				body.call(&"launch", origin.position, direction)
			var visual := body.get_node("Visual") as SpriteVisual
			check(visual != null, "%s painted direction proof" % kind)
			var source_axis := Vector2.RIGHT
			if kind == &"reel_tip":
				source_axis = Vector2(1, -1).normalized()
			elif kind == &"beam_bolt":
				source_axis = Vector2.DOWN
			if visual != null:
				check(
					source_axis.rotated(visual.rotation).is_equal_approx(direction),
					"painted source axis follows actual launch direction"
				)
				check(
					visual.get_node_or_null("ContactShadow") == null,
					"flying body has no ground shadow"
				)
			check_near(body.rotation, 0.0, 0.001, "projectile root stays unrotated")
		await dispose(arena)


func _jar_states() -> void:
	reset_state()
	var arena := make_arena()
	var hero := make_player(arena, Vector2(600, 500))
	await frames(2)
	GameState.acquire_item(&"glow_jar")
	hero.facing = Vector2.RIGHT
	check(hero.use_item(), "jar state proof uses real item")
	var wrapper := get_tree().get_first_node_in_group(ItemBase.group_name(&"glow_jar"))
	var jar: Node2D = null
	for child in wrapper.get_children():
		if child.has_method(&"is_lit"):
			jar = child as Node2D
	check(jar != null, "actual use creates the physical jar")
	if jar == null:
		await dispose(arena)
		return
	var thrown := jar.get_node("Visual") as SpriteVisual
	check(thrown != null and thrown.kind == &"jar_thrown", "flight uses centred thrown art")
	await seconds(0.2)
	check(jar.get_node("Visual").position.y < 0.0, "existing throw arc lifts only Visual")
	await seconds(0.3)
	var lit := jar.get_node("Visual") as SpriteVisual
	check(lit != null and lit.kind == &"jar_lit", "landing changes to lit jar art")
	check_eq(jar.get_node("Visual").position, Vector2.ZERO, "landing resets visual lift")
	check(jar.is_in_group(&"glow_light"), "landing retains reveal light group")
	check((jar.get_node("Glow") as PointLight2D).enabled, "landing retains illumination")
	check(not (wrapper.get_node("Visual") as CanvasItem).visible, "wrapper remains hidden")
	await dispose(arena)


func _flame_states() -> void:
	reset_state()
	var arena := make_arena()
	var hero := make_player(arena, Vector2(600, 500))
	await frames(2)
	GameState.acquire_item(&"cinder_wick")
	hero.facing = Vector2.RIGHT
	check(hero.use_item(), "flame state proof starts with real player use")
	await seconds(0.3)
	var flame := get_tree().get_first_node_in_group(&"cinder_flames") as Node2D
	var visual := flame.get_node("Visual") as SpriteVisual
	check(visual != null, "rolling flame is painted")
	if visual != null:
		check_eq(visual.animation, &"roll", "actual rolling state plays roll")
	await seconds(0.7)
	check_near(flame.global_position.x, 936.0, 1.0, "roll reach is unchanged")
	if visual != null:
		check_eq(visual.animation, &"stand", "actual stopped state plays stand")
	await seconds(2.5)
	if visual != null:
		check(visual.modulate.a < 1.0, "standing flame fades before spend")
	await seconds(0.6)
	check(not is_instance_valid(flame), "flame frees after its original stand/fade")
	await dispose(arena)


func _missing_art() -> void:
	SpriteVisual.use_manifest("res://tests/fixtures/no_tool_manifest.json")
	for scene_name in [&"flame", &"slug", &"jar", &"reel_tip", &"reed_raft"]:
		var scene := load("res://scenes/items/%s.tscn" % scene_name) as PackedScene
		var body := scene.instantiate() as Node2D
		add_child(body)
		check(body.get_node("Visual") is Placeholder, "%s safely falls back" % scene_name)
		if scene_name == &"jar":
			body.call(&"_land")
			check(body.get_node("Visual") is Placeholder, "landed jar safely falls back")
		await dispose(body)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)
