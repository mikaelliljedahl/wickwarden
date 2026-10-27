extends TestCase
## Positioned combat probes use the real jar, player hook, ward and enemy projectiles.
const GALLERY := "res://tests/fixtures/gallery/B05.tscn"
const SCENE := "res://scenes/enemies/bosses/archivist.tscn"


func run() -> void:
	await _shadow_lifecycle()
	await _copy_challenge()
	await _effects()
	await _attacks_and_reset()
	await _ward()
	await _physical_finish()


func _shadow_count(boss: Node, expected: int) -> void:
	var polygons := boss.find_children("*", "Polygon2D", true, false)
	check_eq(polygons.size(), expected, "exact canonical shadow geometry, including hidden nodes")
	if expected == 1:
		check_eq(polygons[0].get_parent(), boss.get("shadow"), "only polygon belongs to public shadow")
		check(not boss.get("shadow").visible, "canonical shadow starts hidden without jar")


func _shadow_lifecycle() -> void:
	reset_state()
	var arena := make_arena()
	var fresh := make_enemy(arena, SCENE, Vector2(960, 480))
	_shadow_count(fresh, 1)
	await dispose(arena)
	for grid in [Vector2i.ZERO, Vector2i(20, 14)]:
		reset_state()
		var packed := load("res://scenes/world/rooms/cave_5_10.tscn") as PackedScene
		check(packed != null, "actual built C5 boss room loads")
		var room := packed.instantiate() as Room
		room.grid = grid
		add_child(room)
		for visit in range(3):
			room.enter()
			var boss := room.get_node("Enemies/Archivist1") as Node2D
			_shadow_count(boss, 1)
			check(room.get_rect().has_point(boss.global_position), "cloned boss retains translated room anchor")
			var old_shadow: WeakRef = weakref(boss.get("shadow"))
			room.leave()
			await frames(2)
			check(old_shadow.get_ref() == null, "leaving frees generated shadow geometry")
		GameState.set_flag(&"boss_cave_5_10_defeated")
		room.enter()
		var retired := room.get_node("Enemies/Archivist1") as EnemyBase
		check(retired.is_dead and not retired.visible, "defeated template clone retires")
		_shadow_count(retired, 0)
		check(not retired.hurtbox.enabled and not retired.contact_hitbox.active,
			"retired clone exposes no damage or contact")
		await dispose(room)


func _fixture() -> Room:
	var packed := load(GALLERY) as PackedScene
	check(packed != null, "owned gallery loads")
	var room := packed.instantiate() as Room
	add_child(room)
	room.enter()
	return room


func _hit(parent: Node, boss: Node2D, damage := 1) -> void:
	var hit := make_hitbox(parent, boss.global_position, Layers.Team.PLAYER, damage, 56)
	hit.kind = &"hook"
	await frames(3)
	await dispose(hit)


func _copy_challenge() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Archivist")
	var player := make_player(room, Vector2(960, 300))
	player.set_hurtbox_enabled(self, false)
	check_eq(boss.hp, 30, "30 HP")
	check(boss.is_in_intro(), "1.5s intro")
	await _hit(room, boss, 4)
	check_eq(boss.hp, 30, "intro immune")
	await seconds(1.6)
	boss.apply_damage(10, boss.global_position, 0)
	check_eq(boss.phase, 2, "20HP phase2")
	check(boss.is_pausing(), "phase pause")
	await seconds(2.2)
	check_eq(boss.copies.size(), 3, "phase2 three decoys")
	check(boss.copying, "copy encounter active")
	check(not boss.shadow.visible, "real-only shadow stays hidden without a jar")
	if SpriteVisual.has_art(&"archivist"):
		check(boss.visual is SpriteVisual, "real body keeps the inherited painted factory")
		check(boss.visual.get_node_or_null("ContactShadow") == null,
			"body art adds no permanent shadow that bypasses jar reveal")
		boss._process(0.0)
		check_eq(boss.visual.animation, &"idle", "copy challenge gives real figure no exclusive action cue")
	for copy in boss.copies:
		if SpriteVisual.has_art(&"archivist_decoy"):
			var look := copy.get_node("Visual") as SpriteVisual
			check(look != null, "every decoy uses the dedicated painted factory")
			if look != null:
				check_eq(look.kind, &"archivist_decoy", "copy uses the committed decoy key")
				check(look.get_node_or_null("ContactShadow") == null,
					"painted decoy never acquires a contact shadow")
		check(copy.get_node_or_null("Shadow") == null, "decoy has no jar-reveal shadow")
	# Copy helpers can also be duplicated independently by snapshot tooling.
	var copy_probe := boss.copies[0].duplicate() as Node2D
	var stale_helper: WeakRef = weakref(copy_probe.find_children("*", "Area2D", true, false)[0])
	room.add_child(copy_probe)
	check(stale_helper.get_ref() == null, "copy ready frees its cloned old hurtbox helper")
	var helpers := copy_probe.find_children("*", "Area2D", true, false)
	check_eq(helpers.size(), 1, "copy clone has exactly one generated hurtbox")
	check(helpers[0] is Hurtbox, "canonical copy helper remains a real hurtbox")
	check(copy_probe.get_node_or_null("Shadow") == null, "copy helper cleanup adds no shadow")
	await dispose(copy_probe)
	check_eq(boss.copies.size(), 3, "disposing an independent clone preserves encounter copies")
	await _hit(room, boss)
	check_eq(boss.hp, 20, "unlit real rejects blind damage")
	var decoy = boss.copies[0]
	var at: Vector2 = decoy.global_position
	await _hit(room, decoy)
	check(not is_instance_valid(decoy), "decoy pops on real hitbox")
	check_eq(boss.copies.size(), 2, "popped decoy unregisters before its object is freed")
	for remaining in boss.copies:
		check(is_instance_valid(remaining), "copy registry contains only live figures")
	check_eq(boss.hp, 20, "decoy never damages boss HP")
	check(at.distance_to(Vector2(960, 480)) <= 288.1, "copy on compass")
	GameState.acquire_item(&"glow_jar")
	GameState.set_active_item(&"glow_jar")
	player.place_at(Vector2(960, 192))
	player.facing = Vector2.DOWN
	check(player.use_item(), "real jar thrown to arena centre")
	await seconds(0.6)
	check(boss.jar_lit(), "actual landed jar lights real boss")
	check(boss.shadow.visible, "jar shows real-only shadow")
	for copy in boss.copies:
		check(copy.get_node_or_null("Shadow") == null, "jar does not add a shadow to a decoy")
	player.place_at(boss.global_position + Vector2(0, 108))
	player.facing = Vector2.UP
	Input.action_press(&"attack")
	await frames(10)
	Input.action_release(&"attack")
	check_eq(boss.hp, 16, "actual hook page break counts double")
	check(not boss.copying and boss.copies.is_empty(), "page break clears copies")
	if boss.visual is SpriteVisual:
		boss._process(0.0)
		check_eq(boss.visual.animation, &"page_break", "actual doubled hook starts painted page break")
	var position_before: Vector2 = boss.global_position
	await seconds(1.5)
	check_eq(boss.global_position, position_before, "page break stuns for2seconds")
	if boss.visual is SpriteVisual:
		boss._process(0.0)
		check_eq(boss.visual.animation, &"stunned", "remaining real recovery shows stunned art")
	await seconds(0.7)
	boss.apply_damage(6, boss.global_position, 0)
	check_eq(boss.phase, 3, "10HP phase3")
	await seconds(2.2)
	check_eq(boss.copies.size(), 4, "phase3 four decoys")
	Events.player_died.emit()
	await frames(3)
	check_eq(boss.hp, 30, "reset full HP")
	check_eq(boss.phase, 1, "reset phase1")
	check(boss.copies.is_empty(), "reset clears copies")
	check(boss.is_in_intro(), "reset intro restored")
	await dispose(room)


func _effects() -> void:
	reset_state()
	var arena := make_arena()
	var boss = make_enemy(arena, SCENE, Vector2(960, 480))
	await seconds(1.6)
	boss._bolt(Vector2(800, 480), Vector2.RIGHT, 300)
	var bolt := get_tree().get_nodes_in_group(&"projectiles")[0] as EnemyProjectile
	var bolt_visual := bolt.get_node_or_null("Visual") as SpriteVisual
	check(bolt_visual != null, "ink bolt uses painted sprite")
	if bolt_visual != null:
		check_eq(bolt_visual.sprite_frames.get_frame_count(&"idle"), 2, "ink bolt animates")
		check_near(bolt_visual.rotation, -deg_to_rad(20.0), 0.001, "ink points in flight direction")
	var bolt_light := bolt.get_node_or_null("InkLight") as PointLight2D
	check(bolt_light != null and not bolt_light.is_in_group(&"glow_light"), "bolt light cannot reveal boss")
	boss.spatter(Vector2(600, 480))
	var burst := arena.get_child(arena.get_child_count() - 1) as Node2D
	var burst_visual := burst.get_node_or_null("Visual") as SpriteVisual
	check(burst_visual != null, "spatter uses painted sprite")
	check(burst.get_node_or_null("InkLight") != null, "spatter has presentation light")
	check(not burst.get_node("InkLight").is_in_group(&"glow_light"), "spatter cannot reveal boss")
	var box := burst.get("box") as Hitbox
	check_eq(box.damage, 2, "spatter retains damage")
	check(not box.blockable, "spatter remains unblockable")
	var shape := box.get_child(0) as CollisionShape2D
	check_near((shape.shape as CircleShape2D).radius, 100.0, 0.001, "spatter radius unchanged")
	await frames(4)
	check(not is_instance_valid(burst), "spatter clears after three physics frames")
	await dispose(arena)


func _attacks_and_reset() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Archivist")
	await seconds(4.3)
	var bolts := get_tree().get_nodes_in_group(&"projectiles")
	check_eq(bolts.size(), 3, "phase1 three ink bolts")
	for bolt in bolts:
		check_near(bolt.speed, 300, 0.01, "ink300px/s")
		check_eq(bolt.damage, 2, "ink damage2")
		check(bolt.hitbox.blockable, "ink wardable")
	await seconds(3.8)
	check(boss.global_position != Vector2(960, 480), "page blink teleports near lectern")
	boss.apply_damage(20, boss.global_position, 0)
	await seconds(2.2)
	check(get_tree().get_nodes_in_group(&"projectiles").is_empty(), "phase clears old bolts")
	await seconds(6.1)
	var pages := 0
	for bolt in get_tree().get_nodes_in_group(&"projectiles"):
		if bolt.speed == 240:
			pages += 1
	check(pages > 0, "last page emits240px/s ring")
	boss.reset_fight()
	await frames(3)
	check(get_tree().get_nodes_in_group(&"projectiles").is_empty(), "reset clears hazards")
	await seconds(1.6)
	boss.apply_damage(99, boss.global_position, 0)
	check(GameState.has_flag(&"boss_cave_5_10_defeated"), "canonical death flag")
	check(boss.death_drops.is_empty(), "no embedded persistent rewards")
	check(not boss.contact_hitbox.active, "death contact harmless")
	await seconds(1.6)
	check(not is_instance_valid(boss), "1.5s death completes")
	var scene := load(SCENE) as PackedScene
	check(scene != null, "boss scene loads")
	var retired = scene.instantiate()
	room.get_node("Enemies").add_child(retired)
	check(retired.is_dead and not retired.visible, "persistent defeat retires reloaded boss")
	retired.reset_fight()
	check(retired.is_dead and not retired.visible, "reset cannot unretire defeated boss")
	for pickup in get_tree().get_nodes_in_group(&"pickups"):
		check(
			pickup.kind != &"fragment" and pickup.kind != &"wick_core",
			"room owns persistent reward"
		)
	await dispose(room)


func _ward() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(600, 480))
	var boss = make_enemy(arena, SCENE, Vector2(1000, 480))
	await frames(3)
	player.facing = Vector2.RIGHT
	Input.action_press(&"ward")
	await frames(3)
	var health := GameState.health
	boss._bolt(Vector2(820, 480), Vector2.LEFT, 300)
	await seconds(0.8)
	check_eq(GameState.health, health, "real ward blocks actual ink projectile")
	check(get_tree().get_nodes_in_group(&"projectiles").is_empty(), "ward destroys ink")
	boss.spatter(player.global_position)
	await frames(5)
	# Intro refuses hazards; start the fight before probing the non-blockable burst.
	await seconds(1.0)
	boss.spatter(player.global_position)
	await frames(6)
	check_eq(GameState.health, health - 2, "actual spatter ignores held ward")
	release_inputs()
	await dispose(arena)


func _physical_finish() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Archivist")
	var player := make_player(room, Vector2(960, 192))
	player.set_hurtbox_enabled(self, false)
	GameState.acquire_item(&"glow_jar")
	GameState.set_active_item(&"glow_jar")
	await seconds(1.6)
	# Threshold setup uses real damaging hitboxes, not hp writes or direct phase calls.
	await _hit(room, boss, 10)
	check_eq(boss.phase, 2, "physical hit enters phase2")
	await seconds(2.2)
	var moth := make_hitbox(room, boss.global_position, Layers.Team.PLAYER, 0, 60)
	moth.kind = &"stun"
	moth.stun_time = 2
	await frames(3)
	check(not boss.is_stunned(), "boss immune to moth stun")
	await dispose(moth)
	player.place_at(Vector2(960, 192))
	player.facing = Vector2.DOWN
	check(player.use_item(), "second real jar lands across all compass positions")
	await seconds(0.6)
	await _hit(room, boss, 5)
	check_eq(boss.phase, 3, "lit doubled physical hit enters phase3")
	await seconds(2.2)
	check(boss.jar_lit(), "same jar covers phase3 centre")
	await _hit(room, boss, 5)
	check(boss.is_dying(), "lit physical hit defeats last page")
	check(not boss.contact_hitbox.active, "physical death contact disabled")
	boss.reset_fight()
	check(boss.is_dying(), "defeat cannot reset during death throes")
	await frames(3)
	check(
		get_tree().get_nodes_in_group(&"projectiles").is_empty(),
		"physical death clears bolts/pages"
	)
	await seconds(1.6)
	check(
		GameState.has_flag(&"boss_cave_5_10_defeated"), "physical fight persists canonical defeat"
	)
	await dispose(room)
