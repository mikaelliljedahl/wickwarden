extends TestCase
## The mirror shade: stats and the decoy pair, the 0.6 s fade-in, stalking, the decoy's mirrored position and
## facing, the glow jar stand-in light, the ward's front guard, the echo swing after a hook swing, and death.

const SHADE := "res://scenes/enemies/mirror_shade.tscn"
const ROOM := Rect2(0, 0, 1920, 960)
const CENTRE_Y := 480.0
const START := Vector2(960, 300)


func run() -> void:
	await _test_decoy_art_and_fallback()
	await _test_stats_and_pair()
	await _test_fade_in_then_stalks()
	await _test_decoy_mirrors_position_and_facing()
	await _test_glow_light_reveals_real_shade()
	await _test_ward_guards_front()
	await _test_echo_swing_after_hook()
	await _test_stun_cancels_echo()
	await _test_death_hides_decoy()


func _test_decoy_art_and_fallback() -> void:
	var fixture := "res://tests/fixtures/sprites_fixture/sprites.json"
	var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(fixture))
	var path := "user://mirror_shade_decoy_test.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(
		JSON.stringify({"mirror_shade": source["walker"], "mirror_shade_decoy": source["walker"]})
	)
	file.close()
	for painted in [false, true]:
		SpriteVisual.use_manifest(path if painted else fixture)
		reset_state()
		var arena := _make_room()
		var enemy := _spawn(arena, START)
		make_player(arena, Vector2(300, 700))
		await seconds(0.8)
		var decoy := _decoy_of(enemy)
		var look := decoy.get_node("Visual") as Node2D
		check_eq(look is SpriteVisual, painted, "decoy uses art when mapped, fallback otherwise")
		check_eq(look is Placeholder, not painted, "missing decoy art retains Placeholder")
		check_eq(enemy.hp, 3, "visual choice preserves hp")
		check_eq(enemy.contact_damage, 2, "visual choice preserves contact damage")
		check(
			decoy.find_children("*", "Area2D", true, false).is_empty(),
			"painted and fallback decoys have no combat areas"
		)
		if painted:
			check((look as SpriteVisual).flip_h, "painted decoy follows left facing")
			var body := enemy.visual as SpriteVisual
			var reflection := look as SpriteVisual
			var body_material := body.material as ShaderMaterial
			var reflection_material := reflection.material as ShaderMaterial
			check(body_material != null, "painted real shade has a silhouette material")
			check(reflection_material != null, "painted reflection has a silhouette material")
			check(body_material != reflection_material, "pair materials are independent resources")
			check_eq(
				body_material.shader.code,
				reflection_material.shader.code,
				"pair uses the same silhouette profile"
			)
			check_eq(
				body_material.get_shader_parameter("cell_size"),
				Vector2(32, 32),
				"atlas sampling uses the loaded frame's cell"
			)
			var shadow := body.get_node("ContactShadow") as Sprite2D
			check(
				shadow.material == null and not shadow.use_parent_material,
				"silhouette does not recolour the existing contact shadow"
			)
			enemy.call("_set_flash", true)
			check_eq(body.modulate, Color(4, 4, 4, 1), "material retains base damage flash tint")
			check_eq(reflection.modulate, Color.WHITE, "real hit flash does not mutate reflection")
			enemy.call("_set_flash", false)
			await get_tree().process_frame
			await get_tree().process_frame
			check(body.is_playing(), "moving real shade plays its walk")
			check(reflection.is_playing(), "moving reflection plays its walk")
			check_eq(reflection.animation, body.animation, "reflection copies the body's animation")
			check_eq(reflection.frame, body.frame, "reflection copies the body's walk frame")
			check_near(
				reflection.frame_progress,
				body.frame_progress,
				0.01,
				"reflection copies walk progress without an independent motion clock"
			)
			enemy.move_speed = 0.0
			await frames(3)
			await get_tree().process_frame
			check(not body.is_playing(), "stationary real shade holds its first walk frame")
			check(not reflection.is_playing(), "stationary reflection holds its first walk frame")
			check_eq(reflection.frame, 0, "reflection holds the same idle frame")
		else:
			check((look as Placeholder).facing.x < 0.0, "fallback follows left facing")
		var light := Node2D.new()
		light.add_to_group(&"glow_light")
		arena.add_child(light)
		light.global_position = enemy.global_position
		await frames(2)
		check(not decoy.visible, "glow hides either decoy visual")
		check(enemy.visual.modulate.r < 0.5, "glow darkens the real shade with either visual")
		await dispose(arena)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _make_room() -> Node2D:
	return make_arena([])


func _spawn(arena: Node2D, at: Vector2) -> EnemyBase:
	var enemy := make_enemy(arena, SHADE, at)
	enemy.room_rect = ROOM
	return enemy


func _decoy_of(enemy: EnemyBase) -> Node2D:
	return enemy.get_node_or_null("Decoy") as Node2D


func _test_stats_and_pair() -> void:
	reset_state()
	var arena := _make_room()
	var enemy := _spawn(arena, START)
	await frames(2)
	check_eq(enemy.hp, 3, "mirror shade has 3 hp")
	check_eq(enemy.contact_damage, 2, "mirror shade contact damage is 2 (one heart)")
	check_near(enemy.move_speed, 200.0, 0.01, "mirror shade stalks at 200 px/s")
	check(enemy.get_node_or_null("Visual") != null, "mirror shade has a Visual child")
	var decoy := _decoy_of(enemy)
	check(decoy != null, "mirror shade has a decoy node")
	if decoy != null:
		check(decoy.get_node_or_null("Visual") != null, "the decoy has a Visual child")
		check(
			decoy.find_children("*", "Area2D", true, false).is_empty(),
			"the decoy has no hurtbox and no hitbox"
		)
	var echo := enemy.get_node_or_null("EchoSwing") as Hitbox
	check(echo != null, "mirror shade has an echo swing hitbox")
	if echo != null:
		check_eq(echo.damage, 2, "echo swing deals 2 damage")
		check(not echo.blockable, "echo swing is not blockable by the ward")
		check(not echo.active, "echo swing starts inactive")
	await dispose(arena)


func _test_fade_in_then_stalks() -> void:
	reset_state()
	var arena := _make_room()
	var enemy := _spawn(arena, Vector2(960, 300))
	make_player(arena, Vector2(1500, 300))
	await frames(2)
	check(enemy.invulnerable, "the shade is invulnerable while it fades in")
	var start := enemy.global_position
	await frames(20)
	check(
		enemy.global_position.distance_to(start) < 0.5, "the shade does not move while it fades in"
	)
	await seconds(0.6)
	check(not enemy.invulnerable, "the shade can be hurt after the 0.6 s fade-in")
	await frames(30)
	check_near(enemy.velocity.length(), 200.0, 1.0, "the shade stalks Tamsin at 200 px/s")
	check(enemy.velocity.x > 0.0, "the shade moves toward Tamsin")
	await dispose(arena)


func _test_decoy_mirrors_position_and_facing() -> void:
	reset_state()
	var arena := _make_room()
	var enemy := _spawn(arena, Vector2(960, 300))
	make_player(arena, Vector2(300, 700))
	await seconds(1.0)
	var decoy := _decoy_of(enemy)
	check(decoy != null and decoy.visible, "the decoy shows in the dark")
	if decoy != null:
		var mirrored := Vector2(enemy.global_position.x, 2.0 * CENTRE_Y - enemy.global_position.y)
		check(
			decoy.global_position.distance_to(mirrored) < 1.0,
			"the decoy sits at the point mirrored across the room's centre line (y' = 960 - y)"
		)
		var look := decoy.get_node_or_null("Visual") as Node2D
		if look is SpriteVisual:
			check((look as SpriteVisual).flip_h, "the painted decoy faces left with the shade")
		else:
			check(
				look is Placeholder and (look as Placeholder).facing.dot(enemy.facing_dir) > 0.99,
				"the fallback decoy copies the facing"
			)
	check(enemy.facing_dir.x < 0.0, "the shade faces Tamsin on her left")
	await dispose(arena)


func _test_glow_light_reveals_real_shade() -> void:
	reset_state()
	var arena := _make_room()
	var enemy := _spawn(arena, START)
	await seconds(0.8)
	var decoy := _decoy_of(enemy)
	var light := Node2D.new()
	light.add_to_group(&"glow_light")
	arena.add_child(light)
	light.global_position = START + Vector2(600, 0)
	await frames(2)
	check(decoy.visible, "a light 600 px away (outside 520 px) does not hide the decoy")
	light.global_position = START + Vector2(200, 0)
	await frames(2)
	check(not decoy.visible, "a stand-in light within 520 px hides the decoy")
	var look := enemy.get_node("Visual") as Node2D
	check(look.modulate.r < 0.5, "the real shade is drawn dark under the light")
	light.queue_free()
	await frames(2)
	check(decoy.visible, "the decoy returns when the light is gone")
	check(look.modulate.r > 0.9, "the real shade is drawn normally again")
	await dispose(arena)


func _test_ward_guards_front() -> void:
	reset_state()
	var arena := _make_room()
	var player := make_player(arena, Vector2(1260, 300))
	var enemy := _spawn(arena, START)
	await seconds(0.8)
	enemy.move_speed = 0.0
	Input.action_press(&"ward")
	await frames(3)
	check(player.ward_up, "the ward is raised")
	check_near(
		enemy.armor_front_deg, 120.0, 0.01, "the ward gives the shade a 120 degree front guard"
	)
	var hp_before := enemy.hp
	var hit := make_hitbox(
		arena, enemy.global_position + Vector2(30, 0), Layers.Team.PLAYER, 1, 10.0
	)
	await frames(3)
	check(not hit.get_overlapping_areas().is_empty(), "the test hit overlaps the shade")
	check_eq(enemy.hp, hp_before, "a hit from the front is blocked while the ward is up")
	await dispose(hit)
	Input.action_release(&"ward")
	await frames(3)
	check_near(enemy.armor_front_deg, 0.0, 0.01, "no guard without the ward")
	hit = make_hitbox(arena, enemy.global_position + Vector2(30, 0), Layers.Team.PLAYER, 1, 10.0)
	await frames(3)
	check_eq(enemy.hp, hp_before - 1, "the same hit lands without the ward")
	await dispose(hit)
	await dispose(arena)


func _test_echo_swing_after_hook() -> void:
	reset_state()
	var arena := _make_room()
	var player := make_player(arena, Vector2(1100, 300))
	var enemy := _spawn(arena, START)
	await seconds(0.8)
	enemy.move_speed = 0.0
	var health_before := GameState.health
	Input.action_press(&"attack")
	await frames(2)
	Input.action_release(&"attack")
	check(player.is_swinging(), "the hook swing starts")
	await seconds(0.3)
	check_eq(GameState.health, health_before, "no echo before the 0.4 s delay")
	await seconds(0.4)
	check_eq(GameState.health, health_before - 2, "the echo swing hits Tamsin for 2 damage")
	await dispose(arena)

	reset_state()
	arena = _make_room()
	player = make_player(arena, Vector2(960 + 300, 300))
	enemy = _spawn(arena, START)
	await seconds(0.8)
	enemy.move_speed = 0.0
	health_before = GameState.health
	Input.action_press(&"attack")
	await frames(2)
	Input.action_release(&"attack")
	await seconds(0.8)
	check_eq(GameState.health, health_before, "a shade 300 px away does not echo")
	await dispose(arena)


func _test_stun_cancels_echo() -> void:
	reset_state()
	var arena := _make_room()
	var player := make_player(arena, Vector2(1100, 300))
	var enemy := _spawn(arena, START)
	await seconds(0.8)
	enemy.move_speed = 0.0
	var health_before := GameState.health
	Input.action_press(&"attack")
	await frames(2)
	Input.action_release(&"attack")
	check(player.is_swinging(), "the hook swing starts for the stun test")
	enemy.stun(1.0)
	await seconds(1.2)
	check_eq(GameState.health, health_before, "a stun cancels the pending echo swing")
	await dispose(arena)


func _test_death_hides_decoy() -> void:
	reset_state()
	var arena := _make_room()
	var enemy := _spawn(arena, START)
	await seconds(0.8)
	var decoy := _decoy_of(enemy)
	enemy.drop_roll_override = 0.99
	enemy.apply_damage(3, enemy.global_position + Vector2(-30, 0))
	check(enemy.is_dead, "the shade dies at 0 hp")
	check(not decoy.visible, "the decoy is hidden on death")
	await dispose(arena)
