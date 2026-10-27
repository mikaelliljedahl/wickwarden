extends TestCase

const BOSS := "res://scenes/enemies/bosses/kilnkeeper.tscn"
const REWARD_ROOM := "res://scenes/world/rooms/cave_1_8.tscn"
const FLAG := &"boss_cave_1_8_defeated"


func run() -> void:
	await _plate_visual_adapter()
	if _capture_requested():
		return
	await _death_contact()
	await _armour_and_fight()
	await _molten_expiry_and_splash()
	await _attacks_and_reset()
	await _arena_scene()


func _plate_visual_adapter() -> void:
	for missing_art in [false, true]:
		reset_state()
		SpriteVisual.use_manifest(
			(
				"res://tests/fixtures/no_wax_plate_art.json"
				if missing_art
				else SpriteVisual.DEFAULT_MANIFEST
			)
		)
		var scene := load(REWARD_ROOM) as PackedScene
		check(scene != null, "compiled C01 boss room loads for visual adapter")
		if scene == null:
			SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)
			return
		var room := scene.instantiate() as Room
		add_child(room)
		room.enter()
		await frames(2)
		var boss := room.get_node("Enemies").get_child(0) as Node2D
		var fallbacks := _plate_fallbacks(boss)
		check_eq(
			SpriteVisual.has_art(&"wax_plate"),
			not missing_art,
			"wax plate art availability follows the selected manifest"
		)
		var painted_plates := 0
		for node in boss.find_children("*", "AnimatedSprite2D", true, false):
			if node is SpriteVisual and node.kind == &"wax_plate":
				painted_plates += 1
		check_eq(
			painted_plates > 0, not missing_art, "wax plate uses its painted or procedural visual"
		)
		if missing_art:
			var visible_fallbacks := 0
			for fallback in fallbacks:
				if fallback.visible:
					visible_fallbacks += 1
			check(
				visible_fallbacks > 0, "missing wax plate art keeps the procedural fallback visible"
			)
		else:
			for fallback in fallbacks:
				check(
					not fallback.visible, "painted wax plate hides inherited procedural rectangles"
				)
		check(
			boss.get_node_or_null("BodyShape") is CollisionShape2D, "body collision stays present"
		)
		check(boss.get_node_or_null("Hurtbox") is Hurtbox, "hurtbox stays present")
		check(boss.get_node_or_null("ContactHitbox") is Hitbox, "contact hitbox stays present")
		check(boss.get_node_or_null("WaxPlate") != null, "functional wax plate child stays present")
		if _capture_requested():
			await _capture_adapter_world("fallback" if missing_art else "painted")
		await dispose(room)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)


func _plate_fallbacks(boss: Node) -> Array[Placeholder]:
	var fallbacks: Array[Placeholder] = []
	for node in boss.find_children("*", "Placeholder", true, false):
		var fallback := node as Placeholder
		if fallback != null and fallback.kind == &"wax_plate":
			fallbacks.append(fallback)
	return fallbacks


func _capture_requested() -> bool:
	return DisplayServer.get_name() != "headless" and "--b01-captures" in OS.get_cmdline_user_args()


func _capture_adapter_world(tag: String) -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var world := (load("res://scenes/world/world.tscn") as PackedScene).instantiate() as World
	viewport.add_child(world)
	await get_tree().physics_frame
	GameState.acquire_item(&"tether_moth")
	GameState.acquire_item(&"pitch_pot")
	GameState.add_pitch_pots(3)
	GameState.damage(3)
	world.start_at(&"cave_1_8", &"Default")
	world.player.place_at(world.get_room(&"cave_1_8").global_position + Vector2(1300, 480))
	await frames(60)
	await RenderingServer.frame_post_draw
	var path := "/tmp/wickwarden-b01-%s.png" % tag
	check_eq(viewport.get_texture().get_image().save_png(path), OK, "saves B01 %s capture" % tag)
	await dispose(viewport)


func _death_contact() -> void:
	reset_state()
	var arena := make_arena()
	var boss = _boss(arena, Vector2(800, 480))
	await seconds(1.6)
	check(boss.contact_hitbox.active, "living boss enables contact after intro")
	boss.apply_damage(99, boss.global_position, 0.0)
	check(boss.is_dying(), "lethal damage starts real boss death throes")
	check_eq(boss.contact_hitbox.damage, 0, "death disables contact damage immediately")
	# A later enable request must not restore damage during death throes.
	boss.set_contact_enabled(true)
	var player := make_player(arena, boss.global_position)
	var health := GameState.health
	await frames(5)
	check(not boss.contact_hitbox.active, "death disables contact monitoring safely")
	check_eq(GameState.health, health, "overlapping real player takes no death contact damage")
	await seconds(1.0)
	check_eq(GameState.health, health, "contact stays harmless throughout death throes")
	player.place_at(Vector2(192, 192))
	boss.reset_fight()
	check(not boss.contact_hitbox.active, "reset keeps contact off during intro")
	check_eq(boss.contact_hitbox.damage, 0, "reset intro keeps immediate damage off")
	await seconds(1.6)
	check(boss.contact_hitbox.active, "reset restores contact after the new intro")
	check_eq(boss.contact_hitbox.damage, 2, "reset restores normal contact damage")
	player.place_at(boss.global_position)
	await frames(5)
	check_eq(GameState.health, health - 2, "living reset boss damages an overlapping player")
	await dispose(arena)


func _boss(parent: Node2D, at: Vector2) -> Variant:
	var scene := load(BOSS) as PackedScene
	check(scene != null, "real Kilnkeeper scene loads")
	if scene == null:
		return null
	var boss = scene.instantiate()
	parent.add_child(boss)
	boss.global_position = at
	boss.room_rect = Rect2(96, 96, 1728, 768)
	return boss


func _hit(arena: Node2D, boss: Variant, kind: StringName, damage: int) -> void:
	var hit := make_hitbox(arena, boss.global_position, Layers.Team.PLAYER, damage, 65)
	hit.kind = kind
	hit.knockback = 0
	await frames(3)
	await dispose(hit)
	await seconds(0.3)


func _swing(player: Player, boss: Variant) -> void:
	player.place_at(boss.global_position - Vector2(140, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(6)
	Input.action_release(&"attack")
	await frames(22)


func _cast(player: Player, boss: Variant) -> void:
	player.place_at(boss.global_position - Vector2(200, 0))
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"cinder_wick")
	GameState.set_active_item(&"cinder_wick")
	check(player.use_item(), "actual cinder wick activates")
	# Moving the player off the charge line is normal gameplay; the attached flame follows the boss.
	await seconds(0.7)
	player.place_at(Vector2(192, 192))


func _armour_and_fight() -> void:
	reset_state()
	var fixture := OS.get_environment("WICKWARDEN_KILNKEEPER_ROOM")
	var scene := load(REWARD_ROOM if fixture.is_empty() else fixture) as PackedScene
	check(scene != null, "compiled C01 boss room loads")
	if scene == null:
		return
	var arena := scene.instantiate() as Room
	add_child(arena)
	arena.enter()
	var rewards := _rewards(arena)
	check_eq(rewards.size(), 2, "compiled room traversal finds exactly two real pickups")
	for reward in rewards:
		check(not reward.visible, "living boss hides reward")
		check(not reward.collect(), "living boss prevents reward collection")
		check_eq(reward.requires_flag, FLAG, "reward requires actual boss defeat")
		if reward.kind == &"fragment":
			check_eq(reward.scope, &"c1", "fragment has canonical cave scope")
			check_eq(reward.persistent_id, &"frag_c1", "fragment has canonical ID")
			check_eq(reward.position, Vector2(960, 480), "fragment keeps planned position")
		else:
			check_eq(reward.persistent_id, &"wick_core_c1", "core has canonical ID")
			check_eq(reward.position, Vector2(1152, 480), "core keeps planned position")
	var player := make_player(arena, Vector2(192, 192))
	player.set_hurtbox_enabled(self, false)
	var boss = arena.get_node("Enemies").get_child(0)
	check(not boss.drops_enabled, "boss does not duplicate placed rewards through drops")
	await seconds(1.6)
	check_eq(boss.hp, 24, "intro completes at full HP")
	if SpriteVisual.has_art(&"kilnkeeper"):
		check(boss.visual is SpriteVisual, "compiled boss retains the painted body factory")
		check_eq(boss.visual.kind, &"kilnkeeper", "first phase uses the armoured painting")
	for kind in [&"hook", &"flare", &"explosion", &"sling", &"thrown"]:
		await _hit(arena, boss, kind, 4)
	check_eq(boss.hp, 24, "all hard nonfire hits clink, including flare and pot")
	check_eq(boss.melt_ticks, 0, "nonfire never melts wax")
	await _cast(player, boss)
	for _i in range(120):
		if boss.is_molten():
			break
		await frames(1)
	check(boss.is_molten(), "real flame melts phase 1")
	check_eq(boss.melt_ticks, 3, "phase 1 needs three actual flame ticks")
	check_eq(boss.hp, 18, "threshold tick deals two HP exactly once")
	check(boss.molten_left > 7.8, "phase 1 molten window starts at eight seconds")
	# Stop this flame through its real lifecycle; the remaining ticks are real damage too.
	await seconds(3.1)
	if boss.phase == 1:
		await _hit(arena, boss, &"hook", 2)
	check_eq(boss.phase, 2, "real flame and hook damage cross the 12 HP threshold")
	check(boss.hp <= 12, "phase 2 starts at 12 HP or below")
	await seconds(1.3)
	check(not boss.is_molten(), "phase change restores hard wax")
	if SpriteVisual.has_art(&"kilnkeeper_p2"):
		check_eq(boss.visual.kind, &"kilnkeeper_p2", "real phase transition selects cracked painting")
		check_eq(boss.visual.scale, Vector2.ONE, "phase painting keeps the shared source scale")
	check_eq(boss.melt_ticks, 0, "phase change clears melt count")
	await _cast(player, boss)
	for _i in range(150):
		if boss.is_molten() or boss.is_dying():
			break
		await frames(1)
	check(boss.is_molten(), "real flame melts phase 2")
	check_eq(boss.melt_ticks, 4, "phase 2 needs four actual ticks")
	check_eq(boss.hp, 4, "four phase 2 fire ticks each deal two HP, once")
	check(boss.molten_left > 5.8, "phase 2 molten window starts at six seconds")
	# Stop the remaining flame so the real player hook delivers the finishing blows.
	for flame in get_tree().get_nodes_in_group(&"cinder_flames"):
		flame.queue_free()
	await frames(2)
	for _attempt in range(12):
		if boss.is_dying():
			break
		await _swing(player, boss)
	check(boss.is_dying(), "hook finishes the molten boss")
	check(GameState.has_flag(FLAG), "defeat writes the arena flag")
	check(not boss.is_arena_locked(), "death releases the inherited arena lock")
	await seconds(1.6)
	check(not is_instance_valid(boss), "death throes finish after 1.5 seconds")
	check_eq(_rewards(arena).size(), 2, "actual defeat leaves exactly the two placed rewards")
	var max_health := GameState.max_health
	var kinds: Array[StringName] = []
	for reward in rewards:
		kinds.append(reward.kind)
		check(reward.visible, "actual defeat reveals reward")
		check(reward.collect(player), "reward collects after actual defeat")
		check(not reward.collect(player), "same reward cannot collect twice")
	check_eq(kinds.count(&"fragment"), 1, "one actual fragment")
	check_eq(kinds.count(&"wick_core"), 1, "one actual wick core")
	check(GameState.has_flag(&"frag_c1"), "fragment grants C1 progression")
	check_eq(GameState.max_health, max_health + 2, "one core grants one heart")
	check(GameState.has_flag(&"picked_frag_c1"), "canonical fragment ID persists")
	check(GameState.has_flag(&"picked_wick_core_c1"), "canonical core ID persists")
	await dispose(arena)
	var reentry := scene.instantiate() as Room
	add_child(reentry)
	reentry.enter()
	await frames(2)
	check_eq(_rewards(reentry).size(), 0, "collected rewards stay absent on actual room reentry")
	var retired = reentry.get_node("Enemies").get_child(0)
	check(retired.is_dead and not retired.visible, "defeated boss stays dead on reentry")
	check_eq(GameState.max_health, max_health + 2, "reentry does not grant another heart")
	await dispose(reentry)


func _molten_expiry_and_splash() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(192, 192))
	player.set_hurtbox_enabled(self, false)
	var boss = _boss(arena, Vector2(1100, 480))
	await seconds(1.6)
	await _cast(player, boss)
	for _i in range(120):
		if boss.is_molten():
			break
		await frames(1)
	check(boss.is_molten(), "splash scenario melts through real fire")
	for flame in get_tree().get_nodes_in_group(&"cinder_flames"):
		flame.queue_free()
	await frames(2)
	for _i in range(190):
		if boss.attack == boss.Attack.SPLASH_WARNING:
			break
		await frames(1)
	check_eq(boss.attack, boss.Attack.SPLASH_WARNING, "molten wax warns before its splash")
	player.place_at(boss.global_position - Vector2(110, 0))
	player.facing = Vector2.RIGHT
	player.set_hurtbox_enabled(self, true)
	Input.action_press(&"ward")
	var health := GameState.health
	await seconds(0.65)
	check_eq(GameState.health, health - 2, "wax splash hits through the raised ward")
	Input.action_release(&"ward")
	player.set_hurtbox_enabled(self, false)
	player.place_at(Vector2(192, 192))
	await seconds(5.0)
	check(not boss.is_molten(), "phase 1 hardens after eight seconds")
	check_eq(boss.melt_ticks, 0, "hardening clears the old fire ticks")
	var hp_before: int = boss.hp
	await _hit(arena, boss, &"hook", 2)
	check_eq(boss.hp, hp_before, "hardened wax blocks the hook again")
	await dispose(arena)


func _attacks_and_reset() -> void:
	reset_state()
	var arena := make_arena([Rect2(700, 96, 96, 768)])
	var player := make_player(arena, Vector2(1200, 480))
	player.set_hurtbox_enabled(self, false)
	var boss = _boss(arena, Vector2(500, 480))
	await seconds(1.6)
	await seconds(3.1)
	check_eq(boss.attack, boss.Attack.FAN_WARNING, "fan waits behind its 0.6 second warning")
	for _i in range(40):
		if not get_tree().get_nodes_in_group(&"projectiles").is_empty():
			break
		await frames(1)
	var shots := get_tree().get_nodes_in_group(&"projectiles")
	check_eq(shots.size(), 3, "phase 1 slag fan has three balls")
	for shot in shots:
		check_eq(shot.damage, 2, "slag deals two half hearts")
		check_near(shot.speed, 300, 0.01, "slag speed is 300")
		check(shot.hitbox.blockable, "ward blocks slag")
		var visual := shot.get_node_or_null("Visual") as SpriteVisual
		check(visual != null, "slag uses painted sprite")
		if visual != null:
			check_eq(visual.sprite_frames.get_frame_count(&"idle"), 2, "slag flight animates")
			check_near(visual.rotation, shot.direction.angle() - deg_to_rad(20.0), 0.001, "slag points along flight")
		check(shot.get_node_or_null("SlagLight") is PointLight2D, "slag has presentation light")
	if not shots.is_empty():
		var shot = shots[0]
		shot.destroy(&"wall")
		var impact := arena.get_node_or_null("Puff") as SpriteVisual
		check(impact != null, "wall impact shows painted slag effect")
		if impact != null:
			check_eq(impact.animation, &"impact", "impact uses impact animation")
			check_eq(impact.sprite_frames.get_frame_count(&"impact"), 3, "impact has three frames")
			await seconds(0.6)
			check(not is_instance_valid(impact), "impact cleans itself up")
	await seconds(4.5)
	for _i in range(150):
		if boss.attack == boss.Attack.RECOVER:
			break
		await frames(1)
	check_eq(boss.attack, boss.Attack.RECOVER, "rush stops and recovers on a solid pillar")
	check(boss.global_position.x <= 641, "rush does not cross the pillar")
	boss.reset_fight()
	check_eq(boss.hp, 24, "reset restores HP")
	check_eq(boss.phase, 1, "reset restores phase 1")
	check_eq(boss.melt_ticks, 0, "reset clears armour state")
	check(boss.is_in_intro(), "reset restarts intro")
	await frames(2)
	check_eq(get_tree().get_nodes_in_group(&"projectiles").size(), 0, "reset clears all slag")
	await dispose(arena)


func _arena_scene() -> void:
	reset_state()
	var scene := load("res://tests/fixtures/gallery/B01.tscn") as PackedScene
	check(scene != null, "gallery loads")
	if scene == null:
		return
	var room := scene.instantiate() as Room
	add_child(room)
	room.enter()
	var viewer := make_player(room, Vector2(192, 480))
	viewer.set_hurtbox_enabled(self, false)
	await frames(2)
	var props := room.get_node("Props/Arena")
	var mouth := props.get_node("KilnMouth/Visual")
	check(mouth is SpriteVisual, "kiln mouth uses its painted sprite visual")
	if mouth is SpriteVisual:
		check(mouth.sprite_frames != null, "kiln mouth has sprite frames")
		if mouth.sprite_frames != null:
			check(mouth.sprite_frames.has_animation(&"idle"), "kiln mouth has idle art")
			check(mouth.sprite_frames.get_frame_count(&"idle") > 0, "kiln mouth art is populated")
	for index in range(4):
		var pillar := props.get_node("Pillar%d" % index) as SolidBlock
		check_eq(pillar.size, Vector2(96, 96), "solid pillar is one tile")
		check_eq(pillar.collision_layer, Layers.WORLD, "pillar blocks WORLD bodies")
	check_eq(_rewards(props).size(), 0, "arena owns geometry only; cave owns rewards")
	check_eq(room.exits, [&"w"], "west retreat stays open, no physical shutter")
	var boss = room.get_node("Enemies/Kilnkeeper")
	await seconds(4.0)
	check_eq(boss.phase, 1, "capture demonstration is genuinely in phase 1 at four seconds")
	check(boss.is_molten(), "capture demonstration shows real molten wax")
	var largest_fan := 0
	for _i in range(330):
		largest_fan = maxi(largest_fan, get_tree().get_nodes_in_group(&"projectiles").size())
		await frames(1)
	check_eq(boss.phase, 2, "capture demonstration reaches phase 2 through actual fire")
	check(boss.is_molten(), "phase 2 capture has the four-tick molten state")
	check(largest_fan >= 5, "phase 2 demonstration fires its five-ball fan")
	await dispose(room)


func _rewards(node: Node) -> Array[PickupBase]:
	var result: Array[PickupBase] = []
	if node is PickupBase and node.persistent_id != &"":
		result.append(node)
	for child in node.get_children():
		result.append_array(_rewards(child))
	return result
