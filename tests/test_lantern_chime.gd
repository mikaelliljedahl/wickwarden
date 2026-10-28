extends TestCase
## Lantern chime (T06): press rings an expanding zero-damage chime hitbox, resonance props wake,
## chime-sensitive enemies stun, taps respect the cooldown, and a hold opens the mouth picker except
## in boss arenas.

const ITEM_SCENE := "res://scenes/items/lantern_chime.tscn"
const WAVE_SCENE := "res://scenes/items/chime_wave.tscn"
const STONE_SCENE := "res://scenes/world/resonance_stone.tscn"


func run() -> void:
	await _scenes_and_tap()
	await _missing_art_fallback()
	await _moving_hold_origin()
	await _cooldown()
	await _hold_warps()
	await _hold_is_blocked_in_boss_arena()
	get_tree().paused = false


func _scenes_and_tap() -> void:
	reset_state()
	var item_scene := load(ITEM_SCENE) as PackedScene
	var wave_scene := load(WAVE_SCENE) as PackedScene
	check(item_scene != null, "the lantern chime scene loads")
	check(wave_scene != null, "the chime wave scene loads")
	if item_scene == null or wave_scene == null:
		return
	var item := item_scene.instantiate() as ItemBase
	check(item != null, "the chime root extends ItemBase")
	if item != null:
		check_eq(item.item_id, &"lantern_chime", "the item id is lantern_chime")
		item.free()
	var arena := make_arena()
	var player := make_player(arena, Vector2(400, 480))
	var stone := (load(STONE_SCENE) as PackedScene).instantiate() as Node2D
	stone.set("resonance_id", &"chime_test")
	stone.position = Vector2(640, 480)
	arena.add_child(stone)
	var stunned := make_dummy(arena, Vector2(680, 480))
	stunned.chime_stun_time = 1.0
	var unaffected := make_dummy(arena, Vector2(720, 480))
	await frames(2)
	GameState.acquire_item(&"lantern_chime")
	check(player.use_item(), "the chime accepts a tap")
	await frames(21)
	var waves := get_tree().get_nodes_in_group(&"chime_waves")
	check_eq(waves.size(), 1, "the chime creates one wave")
	if waves.size() == 1:
		var wave := waves[0] as Node2D
		var painted := wave.get("_painted") as Sprite2D
		check(painted != null, "the chime uses its painted wave when the texture loads")
		if painted != null:
			check_eq(painted.texture.get_size(), Vector2(512, 512), "the full canvas is retained")
			check_near(
				painted.scale.x, float(wave.call("current_radius")) / 183.0, 0.001,
				"painted wave follows the collision radius"
			)
			check(not wave.get_node("Visual/Ring").visible, "the fallback ring is hidden")
		var shape := wave.get_node("Hitbox/Shape") as CollisionShape2D
		check_near(
			(shape.shape as CircleShape2D).radius, float(wave.call("current_radius")), 0.01,
			"the collision radius follows the existing timing"
		)
		check_near(
			float(waves[0].call("current_radius")),
			320.0,
			16.0,
			"the wave expands at the specified 480 px over 0.5 s rate"
		)
	check(stone.get("is_awake"), "the expanding wave wakes a resonant prop")
	check(GameState.has_flag(&"resonated_chime_test"), "the resonance flag stays set")
	check(stunned.is_stunned(), "an enemy with chime_stun_time is stunned")
	check_eq(unaffected.hp, unaffected.max_hp, "the zero-damage wave does not damage enemies")
	await seconds(0.4)
	check_eq(
		get_tree().get_nodes_in_group(&"chime_waves").size(),
		0,
		"the wave ends after its half-second ring"
	)
	await dispose(arena)


func _missing_art_fallback() -> void:
	var scene := load(WAVE_SCENE) as PackedScene
	if scene == null:
		check(false, "the chime wave scene loads for the fallback test")
		return
	var arena := make_arena()
	var wave := scene.instantiate() as Node2D
	wave.set("art_path", "res://assets/sprites/missing_chime_test.png")
	wave.set("preview_active", true)
	arena.add_child(wave)
	wave.set_physics_process(false)
	var ring := wave.get_node("Visual/Ring") as Line2D
	var shape := wave.get_node("Hitbox/Shape") as CollisionShape2D
	var hitbox := wave.get_node("Hitbox") as Hitbox
	check(wave.get("_painted") == null, "missing art creates no painted sprite")
	check(ring.visible and ring.is_visible_in_tree(), "missing art leaves the fallback ring visible")
	check(hitbox.active, "fallback wave starts with its hitbox active")
	wave.call("_physics_process", 0.25)
	check_near(float(wave.call("current_radius")), 240.0, 0.01, "fallback expands halfway in 0.25 s")
	check_near(ring.points[0].length(), 240.0, 0.01, "fallback ring follows the wave radius")
	check_near((shape.shape as CircleShape2D).radius, 240.0, 0.01, "fallback hitbox follows the wave")
	check(hitbox.active, "fallback hitbox remains active halfway through")
	wave.call("_physics_process", 0.25)
	check_near(float(wave.call("current_radius")), 480.0, 0.01, "fallback reaches full radius in 0.5 s")
	check_near(ring.points[0].length(), 480.0, 0.01, "fallback ring reaches full radius")
	check(not hitbox.active, "fallback hitbox deactivates after 0.5 s")
	await dispose(arena)


func _moving_hold_origin() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(400, 480))
	await frames(2)
	GameState.acquire_item(&"lantern_chime")
	Input.action_press(&"use_item")
	await frames(3)
	var items := get_tree().get_nodes_in_group(ItemBase.group_name(&"lantern_chime"))
	check_eq(items.size(), 1, "holding creates one chime")
	if items.is_empty():
		Input.action_release(&"use_item")
		await dispose(arena)
		return
	var item := items[0] as Node2D
	var visual := item.get_node("Visual") as Node2D
	var origin := item.global_position
	Input.action_press(&"move_right")
	await frames(20)
	check(player.global_position.distance_to(origin) > 50.0, "player moves during the hold")
	check_eq(visual.global_position, origin, "hold cue remains at the activation origin")
	check(visual.visible, "hold cue remains visible while the player moves")
	Input.action_release(&"use_item")
	await frames(3)
	var waves := get_tree().get_nodes_in_group(&"chime_waves")
	check_eq(waves.size(), 1, "release creates one wave")
	if not waves.is_empty():
		check_eq((waves[0] as Node2D).global_position, origin, "wave retains the activation origin")
	check(not visual.visible, "release hides the hold cue")
	Input.action_release(&"move_right")
	await dispose(arena)


func _cooldown() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(400, 480))
	await frames(2)
	GameState.acquire_item(&"lantern_chime")
	check(player.use_item(), "the first tap starts")
	await frames(36)
	check(not player.use_item(), "a second tap is refused during cooldown")
	await frames(3)
	check_eq(
		get_tree().get_nodes_in_group(&"chime_waves").size(),
		0,
		"a tap during cooldown does not make a second wave"
	)
	await seconds(1.25)
	check(player.use_item(), "the chime can be tapped after the cooldown")
	await frames(2)
	check_eq(
		get_tree().get_nodes_in_group(&"chime_waves").size(),
		1,
		"the post-cooldown tap starts a new wave"
	)
	await dispose(arena)


func _hold_warps() -> void:
	reset_state()
	var world := await make_world()
	world.start_at(&"ow_0_0")
	GameState.set_flag(&"mouth_c1")
	GameState.set_flag(&"mouth_c3")
	GameState.acquire_item(&"lantern_chime")
	Input.action_press(&"use_item")
	await frames(2)
	check_eq(
		get_tree().get_nodes_in_group(ItemBase.group_name(&"lantern_chime")).size(),
		1,
		"the held chime activates once"
	)
	await seconds(1.0)
	check(get_tree().get_first_node_in_group(&"warp_picker_open") == null, "hold has not warped early")
	var held := get_tree().get_first_node_in_group(ItemBase.group_name(&"lantern_chime"))
	check(held != null and held.get_node("Visual").visible, "hold cue remains visible before warp")
	await seconds(0.25)
	var picker := get_tree().get_first_node_in_group(&"warp_picker_open")
	check(picker != null, "holding for 1.2 seconds opens the warp picker")
	if picker != null:
		check(get_tree().paused, "the world pauses while the warp list is open")
		check_eq(
			picker.get("entries").size(), 2, "the list includes only the two visited cave mouths"
		)
		check_eq(
			picker.get("entries")[0]["room"],
			"ow_1_1",
			"the first visited cave mouth maps to its overworld room"
		)
		Input.action_release(&"use_item")
		picker.call("_warp_selected")
		await frames(45)
		check_eq(world.get_current_room_id(), &"ow_1_1", "selecting a mouth warps to its room")
		check_near(
			world.player.global_position.distance_to(
				world.current_room.get_spawn_position(&"FromCave")
			),
			0.0,
			0.01,
			"the warp lands at the FromCave marker"
		)
	else:
		Input.action_release(&"use_item")
	await dispose(world)


func _hold_is_blocked_in_boss_arena() -> void:
	reset_state()
	var world := await make_world()
	var room := Room.new()
	room.room_id = &"cave_6_11"
	room.grid = WorldData.grid("cave_6_11")
	room.dark = true
	var packed := PackedScene.new()
	packed.pack(room)
	room.free()
	world.add_room_scene(&"cave_6_11", packed)
	world.start_at(&"cave_6_11")
	GameState.set_flag(&"mouth_c1")
	GameState.acquire_item(&"lantern_chime")
	Input.action_press(&"use_item")
	await frames(2)
	check_eq(
		get_tree().get_nodes_in_group(ItemBase.group_name(&"lantern_chime")).size(),
		1,
		"the chime accepts a hold in a boss arena"
	)
	await seconds(1.25)
	check(
		get_tree().get_first_node_in_group(&"warp_picker_open") == null,
		"a hold cannot open warp during a boss arena"
	)
	check(not get_tree().paused, "the boss arena remains unpaused")
	Input.action_release(&"use_item")
	await dispose(world)
