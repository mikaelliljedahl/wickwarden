extends TestCase
## Grate (P09): a permanent iron grating. It blocks the player's body, sits in group `grate` on the WORLD
## layer, and the tether moth flies over it and fetches the key behind it.

const SCENE := "res://scenes/world/grate.tscn"
const GRATE_AT := Vector2(600, 400)
const PLAYER_AT := Vector2(600, 600)


func run() -> void:
	await _visual_fixtures()
	for grid in [Vector2i.ZERO, Vector2i(2, 1)]:
		await _room_clones(true, grid)
	await _in_group_on_world_layer()
	await _blocks_player()
	await _moth_fetches_key_behind_grate()
	await _production_world_route(&"cave_1_3", &"key_c1_1", &"c1")
	await _production_world_route(&"ow_3_2#grate", &"key_ow_2", &"ow")


func _production_world_route(id: StringName, key_id: StringName, scope: StringName) -> void:
	reset_state()
	var world := await make_world()
	world.start_at(id)
	var room := world.current_room
	for enemy in room.get_enemies():
		(enemy as EnemyBase).drops_enabled = false
		(enemy as EnemyBase).kill()
	await frames(3)
	var key: PickupBase
	var grate: Node2D
	for prop in room.get_node("Props").get_children():
		if prop is PickupBase and prop.persistent_id == key_id:
			key = prop
		if prop.is_in_group(&"grate"):
			grate = prop
	check(key != null and grate != null, "%s has its real key and grate" % id)
	if key == null or grate == null:
		await dispose(world)
		return
	_check_composition(grate, true)
	var aim_x := key.global_position.x
	world.player.place_at(Vector2(aim_x, grate.global_position.y + 160))
	Input.action_press(&"move_up")
	await seconds(0.5)
	release_inputs()
	check(world.player.global_position.y >= grate.global_position.y + 48,
		"%s real WORLD grate blocks northward approach" % id)
	GameState.acquire_item(&"tether_moth")
	world.player.facing = Vector2.UP
	check(world.player.use_item(), "%s launches moth toward actual key" % id)
	await seconds(1.8)
	check_eq(GameState.keys_in(scope), 1, "%s moth brings home scoped key" % id)
	check(GameState.has_flag(StringName("picked_%s" % key_id)), "real pickup flag persists")
	world.warp_to(&"ow_0_0", &"Default", false)
	world.warp_to(id, &"Default", false)
	await frames(3)
	var returned_grates := 0
	for prop in world.current_room.get_node("Props").get_children():
		if prop.is_in_group(&"grate"):
			returned_grates += 1
			_check_composition(prop, true)
		if prop is PickupBase:
			check(prop.persistent_id != key_id, "collected key absent after exit/return")
	check_eq(returned_grates, 1, "one permanent grate after World exit/return")
	check_eq(GameState.keys_in(scope), 1, "exit/return does not consume the fetched key")
	await dispose(world)


func _visual_fixtures() -> void:
	# Exercise both branches independently of whether the mapper has landed yet.
	var path := "user://grate_visual_fixture.json"
	for available in [false, true]:
		var manifest := {}
		if available:
			manifest["grate_fence_bay"] = {
				"cell": [128, 128], "anchor": [64, 122], "foot": 122,
				"prop": true, "rect_h": 96,
				"animations": {"idle": {
					"file": "res://assets/sprites/grate.png", "frames": 1,
					"fps": 1, "loop": true,
				}},
			}
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_string(JSON.stringify(manifest))
		file.close()
		SpriteVisual.use_manifest(path)
		for grid in [Vector2i.ZERO, Vector2i(2, 1)]:
			await _room_clones(available, grid)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)
	DirAccess.remove_absolute(path)


func _room_clones(available: bool, grid: Vector2i) -> void:
	var arena := make_arena()
	var template: Node2D = _make(arena, GRATE_AT)
	await frames(2)
	_check_composition(template, available)
	arena.remove_child(template)
	var room_script := load("res://scripts/world/room.gd")
	check(room_script != null, "real Room script loads")
	var room := Node2D.new()
	room.set_script(room_script)
	room.set("grid", grid)
	room.set("build_walls", false)
	arena.add_child(room)
	room.register_template(&"Bushes", template)
	for visit in range(3):
		room.enter()
		await frames(2)
		var live: Node2D = room.get_node("Bushes").get_child(0)
		_check_composition(live, available)
		check_eq(live.position, GRATE_AT, "clone retains local position")
		check_eq(live.global_position, room.position + GRATE_AT, "translated room clone")
		room.leave()
	await dispose(arena)


func _check_composition(grate: Node2D, available: bool) -> void:
	check_eq(grate.get_child_count(), 2, "exactly one shape and one Visual after ready")
	var shape := grate.get_node("Shape") as CollisionShape2D
	check_eq((shape.shape as RectangleShape2D).size, Vector2(192, 96), "same footprint")
	check_eq(grate.get("collision_layer"), Layers.WORLD, "same WORLD layer")
	check(grate.is_in_group(&"grate"), "same moth-transparent group")
	var visual := grate.get_node("Visual") as Node2D
	if not available:
		check(visual is Placeholder, "missing bay keeps registered grate fallback")
		return
	check_eq(visual.get_child_count(), 2, "exactly two fence holders")
	for side in [-1, 1]:
		var holder := visual.get_node("Left" if side < 0 else "Right") as Node2D
		check_eq(holder.position, Vector2(side * 48, 0), "fixed bay placement")
		check_eq(holder.get_child_count(), 1, "one sprite per holder")
		var bay := holder.get_node("Visual") as SpriteVisual
		check(bay != null, "bay uses SpriteVisual")
		if bay == null:
			continue
		check_eq(bay.kind, &"grate_fence_bay", "helper key")
		check_eq(bay.scale, Vector2.ONE, "no stretching")
		check(not bay.flip_h and not bay.flip_v, "original lighting orientation")
		check_eq(bay.offset, Vector2(-64, -74), "common foot at collision south edge")
		check_eq(bay.animation, &"idle", "permanent idle only")


func _make(parent: Node, at: Vector2) -> Variant:
	var scene := load(SCENE) as PackedScene
	check(scene != null, "the grate scene loads")
	var grate: Node = scene.instantiate()
	parent.add_child(grate)
	(grate as Node2D).global_position = at
	return grate


func _in_group_on_world_layer() -> void:
	reset_state()
	var arena := make_arena()
	var grate: Variant = _make(arena, GRATE_AT)
	await frames(2)
	check(grate.is_in_group(&"grate"), "the grate is in group grate")
	check_eq(grate.collision_layer, Layers.WORLD, "the grate sits on the WORLD layer")
	await dispose(arena)


func _blocks_player() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, PLAYER_AT)
	_make(arena, GRATE_AT)
	await frames(2)
	Input.action_press(&"move_up")
	await seconds(1.0)
	release_inputs()
	check(player.global_position.y > GRATE_AT.y, "the grate blocks the player's body")
	await dispose(arena)


func _moth_fetches_key_behind_grate() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, PLAYER_AT)
	_make(arena, GRATE_AT)
	var key := PickupBase.spawn(&"key", arena, Vector2(600, 260), false)
	await frames(2)
	GameState.acquire_item(&"tether_moth")
	player.facing = Vector2.UP
	check(player.use_item(), "the moth is thrown up at the grate")
	await seconds(0.4)
	check(key.is_carried(), "the moth flies over the grate and picks up the key behind it")
	check_eq(GameState.keys_in(&"ow"), 0, "a carried key is not applied yet")
	await seconds(1.5)
	check_eq(GameState.keys_in(&"ow"), 1, "the key is brought back past the grate to the player")
	await dispose(arena)
