extends TestCase
## Positioned real-boots and attack probes; no continuous cave or human-balance claim.
const GALLERY := "res://tests/fixtures/gallery/B07.tscn"
const SCENE := "res://scenes/enemies/bosses/gloam_knight.tscn"


func run() -> void:
	await _geometry_and_boots()
	await _dive_and_phases()
	await _presentation_poses()
	await _warning_light()
	await _ward_and_slash()
	await _real_dodge()
	await _fall_api()
	await _streamed_falls()


func _fixture() -> Room:
	var packed := load(GALLERY) as PackedScene
	check(packed != null, "gallery loads")
	var room := packed.instantiate() as Room
	add_child(room)
	room.enter()
	return room


func _geometry_and_boots() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/GloamKnight")
	var player := make_player(room, Vector2(960, 192))
	player.set_hurtbox_enabled(self, false)
	check_eq(boss.hp, 36, "36HP")
	check_eq(boss.body_radius, 44.0, "44px body")
	check_eq(boss.contact_damage, 3, "contact3")
	check(
		not get_tree().get_nodes_in_group(&"pit_zone").is_empty(),
		"real P04 pit subclasses instantiated"
	)
	for y in range(1, 9):
		for x in range(1, 19):
			var point := Vector2(x * 96 + 48, y * 96 + 48)
			var held := false
			for pit in get_tree().get_nodes_in_group(&"pit_zone"):
				if pit.process_mode != Node.PROCESS_MODE_DISABLED and pit.holds(point):
					held = true
			check_eq(held, boss.island_at(point) == -1, "exact island/pit tile complement")
	await seconds(1.7)  # The intro pauses boss physics before facing can update.
	check(boss.visual is SpriteVisual, "knight uses painted body")
	check_eq(boss.visual.animation, &"idle_up", "knight faces player across the pit")
	player.place_at(Vector2(960, 240))
	player.facing = Vector2.DOWN
	Input.action_press(&"attack")
	await frames(10)
	Input.action_release(&"attack")
	check_eq(boss.hp, 36, "entry hook cannot reach central island")
	player.place_at(Vector2(960, 330))
	await frames(3)
	check_near(player.global_position.y, 192, 1, "fall returns fixed island A")
	check_eq(GameState.health, 4, "fall costs2")
	GameState.full_heal()
	await seconds(1)
	player.place_at(Vector2(960, 240))
	player.facing = Vector2.DOWN
	GameState.acquire_item(&"skitter_boots")
	GameState.set_active_item(&"skitter_boots")
	check(player.use_item(), "real boots launch A to C")
	await seconds(0.45)
	check_near(player.global_position.y, 432, 1, "192px leap lands on C")
	check_eq(GameState.health, 6, "successful leap avoids pit damage")
	await seconds(0.5)
	player.facing = Vector2.DOWN
	Input.action_press(&"attack")
	await frames(9)
	Input.action_release(&"attack")
	check(boss.hp < 36, "real hook reaches boss after leap")
	check(not boss.is_arena_locked(), "no retreat barrier")
	await dispose(room)


func _dive_and_phases() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/GloamKnight")
	var player := make_player(room, Vector2(960, 192))
	player.set_hurtbox_enabled(self, false)
	await seconds(1.6)
	boss.dive_left = 0
	await frames(2)
	check_eq(boss.mode, &"crouch", "dive has0.5s crouch")
	await seconds(0.5)
	check_eq(boss.mode, &"air", "takeoff after warning")
	check(not boss.visible and not boss.hurtbox.enabled, "airborne untargetable")
	var fixed: Vector2 = boss.target
	player.place_at(Vector2(1100, 192))
	await seconds(0.55)
	check_eq(boss.mode, &"recover", "landing after0.5air")
	check_eq(boss.global_position, fixed, "landing target fixed at takeoff")
	check(not boss.invulnerable, "landing recovery hittable")
	await seconds(1.0)
	check(boss.mode != &"recover", "one second recovery ends")
	boss.apply_damage(18, boss.global_position, 0)
	check_eq(boss.phase, 2, "18HP second phase")
	await seconds(1.3)
	await frames(3)
	var collapsed := 0
	for pit in boss.arena.get_children():
		if (
			pit.has_method("holds")
			and pit.get_meta("side_island", false)
			and pit.process_mode != Node.PROCESS_MODE_DISABLED
		):
			collapsed += 1
	check_eq(collapsed, 2, "W/E become pit")
	check_eq(boss.island_at(Vector2(336, 480)), -1, "W no longer safe")
	boss.dive_left = 0
	await seconds(1.2)
	var rings := 0
	for hazard in boss._hazards:
		if is_instance_valid(hazard) and hazard.get("kind") == &"ring":
			rings += 1
			check_eq(hazard.box.damage, 2, "phase2ring damage2")
			check_eq(hazard.box.knockback, 0.0, "ring has0knockback")
	check(rings > 0, "phase2landing emits expanding ring")
	room.leave()
	await frames(3)
	room.enter()
	await frames(3)
	boss = room.get_node("Enemies/GloamKnight")
	check_eq(boss.hp, 36, "actual room reentry restores36HP")
	check_eq(boss.phase, 1, "actual room reentry restores phase1")
	for pit in boss.arena.get_children():
		if pit.has_method("holds") and pit.get_meta("side_island", false):
			check_eq(pit.process_mode, Node.PROCESS_MODE_DISABLED, "reentry restores side floor")

	Events.player_died.emit()
	await seconds(1.7)
	check_eq(boss.hp, 36, "death reset fullHP")
	check_eq(boss.phase, 1, "death reset phase1")
	check_eq(boss.island_at(Vector2(336, 480)), 3, "reset restores side island")
	for pit in boss.arena.get_children():
		if pit.has_method("holds") and pit.get_meta("side_island", false):
			check_eq(pit.process_mode, Node.PROCESS_MODE_DISABLED, "reset disables crumbled pits")
	var lethal := make_hitbox(room, boss.global_position, Layers.Team.PLAYER, 99, 60)
	lethal.kind = &"hook"
	await frames(3)
	await dispose(lethal)
	check(boss.is_dying(), "death throes")
	check(not boss.contact_hitbox.active, "death contact harmless")
	check(GameState.has_flag(&"boss_cave_7_11_defeated"), "canonical persistent defeat")
	await seconds(1.6)
	var scene := load(SCENE) as PackedScene
	check(scene != null, "boss scene loads")
	var retired = scene.instantiate()
	room.get_node("Enemies").add_child(retired)
	check(retired.is_dead and not retired.visible, "persistent boss stays dead")
	check(retired.death_drops.is_empty(), "no persistent rewards embedded")
	await dispose(room)


func _presentation_poses() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/GloamKnight")
	var player := make_player(room, Vector2(700, 480))
	player.set_hurtbox_enabled(self, false)
	await seconds(1.6)
	var look := boss.visual as SpriteVisual
	check(look != null, "Knight: painted body exists")
	if look == null:
		await dispose(room)
		return
	check_eq(look.sprite_frames.get_frame_count(&"walk_side"), 4, "walk has four frames")
	check_eq(look.sprite_frames.get_frame_count(&"crouch_side"), 2, "crouch has two frames")
	# Current fight has no walking movement. Probe the visual-only velocity branch.
	boss.mode = &"ready"
	boss.velocity = Vector2.LEFT * 100
	boss._sync_visual()
	check_eq(look.animation, &"walk_side", "moving uses walk strip")
	check(look.flip_h, "leftward walk mirrors side art")
	boss.velocity = Vector2.ZERO
	boss._sync_visual()
	check_eq(look.animation, &"idle_side", "stationary returns to idle")
	boss.dive_left = 0
	await frames(2)
	check_eq(boss.mode, &"crouch", "dive starts crouch")
	check_eq(look.animation, &"crouch_side", "dive plays crouch strip")
	check(look.flip_h, "crouch faces left toward player")
	check_eq(look.scale, Vector2.ONE, "painted crouch is not squashed")
	await seconds(0.3)
	check_eq(boss.mode, &"crouch", "crouch retains half-second duration")
	check_eq(look.frame, 1, "crouch holds its final pose until takeoff")
	await seconds(0.25)
	check_eq(boss.mode, &"air", "takeoff follows original crouch timer")
	await seconds(0.55)
	check_eq(boss.mode, &"recover", "normal landing still follows")
	check(look.animation != &"crouch_side", "landing exits crouch pose")
	await dispose(room)


func _warning_light() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/GloamKnight")
	var player := make_player(room, Vector2(960, 192))
	player.set_hurtbox_enabled(self, false)
	await seconds(1.7)
	boss.lance_left = 0.0
	await frames(2)
	check_eq(boss.mode, &"lance", "real lance enters its warning")
	var marker: Node2D
	for hazard in boss._hazards:
		if is_instance_valid(hazard) and hazard.has_method("progress"):
			marker = hazard
	check(marker != null, "lance creates its normal warning")
	if marker != null:
		var light := marker.get_node_or_null("WarningLight") as PointLight2D
		check(light != null and light.enabled, "warning illuminates the distant knight")
		check(light == null or not light.is_in_group(&"glow_light"), "warning is not a glow jar")
		await seconds(0.6)
		check(not is_instance_valid(marker), "warning and its light expire together")
	await dispose(room)


func _ward_and_slash() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(600, 480))
	var boss = make_enemy(arena, SCENE, Vector2(900, 480))
	await seconds(1.6)
	player.facing = Vector2.RIGHT
	Input.action_press(&"ward")
	await frames(3)
	boss.aim = Vector2.LEFT
	boss._fire_lance()
	var bolt = get_tree().get_nodes_in_group(&"projectiles")[0]
	check_near(bolt.speed, 420, 0.1, "lance speed420")
	check_eq(bolt.hitbox.damage, 2, "lance damage2")
	check_eq(bolt.hitbox.knockback, 0.0, "lance no knockback")
	var health := GameState.health
	await seconds(0.8)
	check_eq(GameState.health, health, "real ward blocks actual lance")
	boss.global_position = Vector2(720, 480)
	boss.aim = Vector2.LEFT
	boss._attack(&"slash", boss.global_position)
	var slash = boss._hazards[-1]
	var slash_ref: WeakRef = weakref(slash)
	var visual := slash.get_node("Visual") as Node2D
	var paint := visual.get_node_or_null("SlashPaint") as Node2D
	check(paint != null, "actual slash uses painted effect")
	if paint != null:
		check_eq(paint.get("direction"), Vector2.LEFT, "paint follows locked attack aim")
		check_eq(
			paint.get("texture").resource_path,
			"res://assets/sprites/mirror_tell_z1.png",
			"existing art reused"
		)
		check(paint.show_behind_parent, "paint sits behind the original contour")
		check(visual.material == null, "contour retains its original lighting")
		check(paint.material is CanvasItemMaterial, "only the painted child is unshaded")
		check_eq(paint.get_child_count(), 0, "paint adds no collision")
	var fallback := visual.get_script().new() as Node2D
	fallback.set(&"slash_art_path", "res://missing-gloam-slash.png")
	slash.add_child(fallback)
	check(fallback.get("slash_paint") == null, "missing art retains procedural fallback")
	check_eq(fallback.get_child_count(), 0, "missing art creates no painted child")
	fallback.queue_free()
	check_eq(slash.box.damage, 3, "slash damage remains three")
	check(not slash.box.blockable, "slash stays unblockable")
	var shape := slash.box.get_child(0) as CollisionShape2D
	var polygon := shape.shape as ConvexPolygonShape2D
	check_eq(polygon.points.size(), 26, "slash collision sector keeps its points")
	check_near(polygon.points[1].length(), 150.0, 0.01, "slash reach remains 150")
	check_near(
		rad_to_deg(polygon.points[1].angle_to(polygon.points[-1])),
		120.0,
		0.01,
		"slash retains 120 degree sector"
	)
	await frames(5)
	check(slash_ref.get_ref() == null, "slash expires after its short active window")
	check_eq(GameState.health, health - 3, "real slash pierces ward")
	check_near(player.global_position.x, 600, 1, "slash never knocks toward pit")
	release_inputs()
	await dispose(arena)


func _real_dodge() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/GloamKnight")
	var player := make_player(room, Vector2(960, 240))
	GameState.acquire_item(&"skitter_boots")
	GameState.set_active_item(&"skitter_boots")
	await seconds(1.6)
	boss.dive_left = 0
	await seconds(0.6)
	check_eq(boss.mode, &"air", "real dodge starts at takeoff")
	player.facing = Vector2.DOWN
	check(player.use_item(), "actual boots dodge fixed landing marker")
	await seconds(0.6)
	check_eq(GameState.health, 6, "boots carry player clear of damage4 landing")
	check_near(player.global_position.y, 432, 1, "dodge reaches next island safely")
	check_eq(boss.target, Vector2(960, 240), "dive does not track airborne player")
	await dispose(room)


func _fall_api() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/GloamKnight")
	var player := make_player(room, Vector2(960, 192))
	await frames(3)
	check(player.take_damage(1, player.global_position, 0), "ordinary hit starts real i-frames")
	check(player.is_invulnerable(), "player has hit immunity before fall")
	player.place_at(Vector2(960, 330))
	await frames(3)
	check_eq(GameState.health, 3, "genuine pit costs2 despite hit i-frames")
	check_eq(player.global_position, Vector2(960, 192), "public fall API returns to island A")
	check_eq(boss.hp, 36, "nonlethal fall does not reset or damage boss")
	var pit: Node2D
	for zone in get_tree().get_nodes_in_group(&"pit_zone"):
		if zone.holds(Vector2(960, 330)):
			pit = zone
	check(pit != null, "real arena pit found")
	var safe := player.global_position
	pit._fall(player)
	check_eq(GameState.health, 3, "safe-ground fall callback rejected")
	check_eq(player.global_position, safe, "rejected fall never relocates player")
	await frames(3)
	player.place_at(Vector2(960, 330))
	await frames(3)
	check_eq(GameState.health, 1, "new fall after safe ground charges2 again")
	check_eq(player.global_position, Vector2(960, 192), "second fall returns A")
	await frames(3)
	player.place_at(Vector2(960, 330))
	await frames(3)
	check(player.is_dead(), "lethal fall uses real player death flow")
	check_eq(player.global_position, Vector2(960, 330), "lethal fall is not relocated")
	check_eq(boss.phase, 1, "player death keeps normal boss reset pipeline")
	await dispose(room)


func _streamed_falls() -> void:
	reset_state()
	SaveGame.enabled = false
	var packed := load("res://scenes/world/world.tscn") as PackedScene
	check(packed != null, "actual World loads")
	var world := packed.instantiate() as World
	add_child(world)
	world.start_at(&"cave_7_11")
	var player := world.player
	var room := world.get_room(&"cave_7_11")
	check_eq(room.global_position, Vector2(96000, 14400), "actual C7 streamed origin")
	var count := 0
	for visit in range(3):
		room = world.get_room(&"cave_7_11")
		var boss = room.get_node("Enemies").get_child(0)
		check_eq(boss._origin, room.global_position, "live clone uses translated room origin")
		check_eq(boss.arena.get_parent(), room.get_node("Props"), "clone references live arena")
		var pits := 0
		for node in boss.arena.get_children():
			if node.has_method("holds"):
				pits += 1
		if visit == 0:
			count = pits
		check_eq(pits, count, "visits never clone stale arena helpers")
		player.place_at(room.global_position + Vector2(960, 192))
		await frames(3)
		var health := GameState.health
		check(player.take_damage(1, player.global_position, 0), "streamed ordinary hit accepted")
		player.place_at(room.global_position + Vector2(960, 330))
		await frames(3)
		check_eq(GameState.health, health - 3, "streamed fall charges2 through hit immunity")
		check_eq(
			player.global_position,
			room.global_position + Vector2(960, 192),
			"streamed fall returns exact island A after fresh visit/death/reentry"
		)
		check_eq(boss.hp, 36, "nonlethal streamed fall preserves fight")
		if visit == 0:
			await seconds(1.1)
			check(player.take_damage(99, player.global_position, 0), "real World lethal hit")
			await seconds(4)
			check(not player.is_dead(), "real World death flow respawns")
		elif visit == 1:
			world.start_at(&"ow_0_0")
		world.start_at(&"cave_7_11")
		GameState.full_heal()
	await dispose(world)
