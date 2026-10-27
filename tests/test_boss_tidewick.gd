extends TestCase
## Real raft boarding and player hitboxes supplement deterministic boss mechanics.

const SCENE := "res://scenes/enemies/bosses/tidewick.tscn"
const GALLERY := "res://tests/fixtures/gallery/B03.tscn"
const WORLD := "res://scenes/world/world.tscn"


func run() -> void:
	await _room_template_lifecycle()
	await _motion_and_exposure()
	await _bolt_warning_presentation()
	await _phases_reset_and_rewards()
	await _wave_visual_directions()
	await _real_raft_combat()
	await _real_undertow()
	# Actual C3 basin coordinates exposed origin-relative hit-direction rounding.
	await _real_undertow(Vector2i(20, 14))
	await _real_ember_ward()
	if OS.get_environment("WICK_B03_CAPTURE") == "1":
		await _capture_real_ripple()
		await _capture_real_bolt_warning()
		await _capture_real_wave(Vector2.RIGHT, "right")
		await _capture_real_wave(Vector2.DOWN, "down")


func _assembly_check(boss: Node2D, room: Room) -> void:
	check_eq(boss.get_node("Serpent").get_child_count(), 9, "one assembly has seven bodies, tail, ripple")
	check_eq(boss.get_node("SerpentPaint").get_child_count(), 8, "seven body visuals and one tail visual")
	var tails := 0
	var contacts := 0
	var body_visuals := 0
	for node in boss.find_children("*", "Node2D", true, false):
		if node.has_meta(&"tidewick_body_visual"):
			body_visuals += 1
	check_eq(body_visuals, 7, "no hidden or origin-space duplicate body visuals survive")
	for node in boss.find_children("*", "Area2D", true, false):
		if node is Hurtbox or node is Hitbox:
			check(room.get_rect().has_point(node.global_position),
				"every generated target/contact stays inside its own translated room")
		if node is Hurtbox and node.name == &"Tail":
			tails += 1
			check_eq(node, boss.get("tail"), "public tail is the sole generated tail target")
			check(room.get_rect().has_point(node.global_position), "tail target stays in translated room")
		if node is Hitbox and node.kind == &"contact":
			contacts += 1
	check_eq(tails, 1, "template cloning leaves exactly one tail hurtbox")
	check_eq(contacts, 1, "template cloning leaves exactly one head contact")
	var looks: Array = boss.get("_body_visuals")
	var bodies: Array = boss.get("followers")
	check_eq(looks.size(), 7, "exactly seven generated body renderers")
	for i in range(looks.size()):
		check_near(looks[i].global_position.distance_to(bodies[i].global_position), 0, 0.01,
			"render sorting preserves every body world anchor")
	check_near(boss.get("tail_visual").global_position.distance_to(boss.get("tail").global_position),
		0, 0.01, "render sorting preserves tail world anchor")


func _room_template_lifecycle() -> void:
	for grid in [Vector2i.ZERO, Vector2i(20, 14)]:
		reset_state()
		var packed := load("res://scenes/world/rooms/cave_3_9.tscn") as PackedScene
		check(packed != null, "actual built C3 boss room loads")
		var room := packed.instantiate() as Room
		room.grid = grid
		add_child(room)
		for visit in range(3):
			room.enter()
			var boss := room.get_node("Enemies/Tidewick1") as Node2D
			_assembly_check(boss, room)
			await seconds(1.6)
			_assembly_check(boss, room)
			check(boss.get("tail").enabled, "canonical target opens after unchanged intro")
			var old_tail: WeakRef = weakref(boss.get("tail"))
			var old_contact: WeakRef = weakref(boss.get("contact_hitbox"))
			room.leave()
			await frames(2)
			check(old_tail.get_ref() == null, "leaving frees the generated tail target")
			check(old_contact.get_ref() == null, "leaving frees the head contact")
			for target in get_tree().get_nodes_in_group(&"hurtboxes"):
				check(not room.is_ancestor_of(target), "left room exposes no public hurtbox targets")
		await dispose(room)


func _fixture(grid: Vector2i = Vector2i.ZERO) -> Room:
	var packed := load(GALLERY) as PackedScene
	check(packed != null, "basin gallery loads")
	var room := packed.instantiate() as Room
	room.grid = grid
	add_child(room)
	room.enter()
	return room


func _motion_and_exposure() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Tidewick")
	check_eq(boss.hp, 24, "tail has24 HP")
	check_eq(boss.followers.size(), 7, "seven submerged followers")
	check(not boss.tail_exposed(), "intro tail closed")
	await seconds(1.6)
	check(boss.tail_exposed(), "tail surfaces at first fight cycle")
	if SpriteVisual.has_art(&"tidewick_body"):
		for look in boss._body_visuals:
			check(look is SpriteVisual, "every serpent segment uses body art")
		var painted_segments := 0
		for look in boss.find_children("*", "AnimatedSprite2D", true, false):
			if look is SpriteVisual and look.kind == &"tidewick_body" and look.is_visible_in_tree():
				painted_segments += 1
		check_eq(painted_segments, 7, "room template copies do not paint a second serpent")
	if SpriteVisual.has_art(&"tidewick_tail"):
		check(boss.tail_visual is SpriteVisual, "tail uses its dedicated painted factory")
		boss._process(0.0)
		check_eq(boss.tail_visual.animation, &"exposed", "vulnerable tail shows flame-up art")
	var before: Vector2 = boss.global_position
	await frames(1)
	check_near(boss.global_position.distance_to(before), 200.0 / 60.0, 0.1, "constant arc speed200")
	var previous: Vector2 = boss.global_position
	for segment in boss.followers:
		check(
			(
				segment.global_position.distance_to(previous) >= 116.0
				and segment.global_position.distance_to(previous) <= 120.1
			),
			"120px path spacing keeps all seven followers separated"
		)
		previous = segment.global_position
		var local: Vector2 = segment.global_position - room.global_position - boss.CENTRE
		check_near(
			pow(local.x / 480, 2) + pow(local.y / 264, 2), 1.0, 0.005, "follower remains on ellipse"
		)
	check(boss.tail.global_position.x - 288 > 300, "dock cannot reach exposed tail")
	await seconds(2.0)
	check(not boss.tail_exposed(), "tail submerges after2 seconds")
	await seconds(1.0)
	var bolts := get_tree().get_nodes_in_group(&"projectiles")
	check(not bolts.is_empty(), "head fires real projectile")
	if not bolts.is_empty():
		check_near(bolts[0].speed, 320, 0.01, "ember speed320")
		check_eq(bolts[0].damage, 2, "ember damage2")
		check(bolts[0].hitbox.blockable, "ward blocks ember")
	await seconds(1.2)
	check(boss.ripple.visible, "next surfacing telegraphs0.8 seconds")
	if SpriteVisual.has_art(&"tidewick_tail"):
		var ripple_visual := boss.ripple.get_node("Visual") as SpriteVisual
		check(ripple_visual != null, "tail warning uses painted ripple")
		if ripple_visual != null:
			check_eq(ripple_visual.kind, &"tidewick_tail", "warning uses the tail's own art")
			check_eq(ripple_visual.animation, &"idle", "warning uses the submerged ripple")
	await seconds(0.9)
	check(boss.tail_exposed(), "tail resurfaces on5second cycle")
	check(not boss.ripple.visible, "warning ends when the tail surfaces")
	var hp: int = boss.hp
	var hit := make_hitbox(room, boss.global_position, Layers.Team.PLAYER, 4, 65)
	hit.kind = &"flare"
	await frames(4)
	check_eq(boss.hp, hp, "head immune to actual flare hitbox")
	await dispose(hit)
	await dispose(room)


func _bolt_warning_presentation() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Tidewick")
	await seconds(3.95)
	check(not is_instance_valid(boss._bolt_warning), "bolt warning not shown before 2.5s")
	check(get_tree().get_nodes_in_group(&"projectiles").is_empty(), "bolt not fired early")
	await seconds(0.1)
	var warning: Node2D = boss._bolt_warning
	check(is_instance_valid(warning), "bolt warning starts before the shot")
	if is_instance_valid(warning) and SpriteVisual.has_art(&"tidewick_bolt_tell"):
		var visual := warning.get_node_or_null("Visual") as SpriteVisual
		check(visual != null and visual.kind == &"tidewick_bolt_tell", "warning uses ember art")
		var lights := warning.find_children("*", "PointLight2D", false, false)
		check_eq(lights.size(), 1, "warning has one presentation light")
		if not lights.is_empty():
			check(not lights[0].is_in_group(&"glow_light"), "warning light is not gameplay glow")
		check_near(warning.global_position.distance_to(boss.global_position), 55.0, 0.1, "cue follows the head")
	await seconds(0.5)
	check(not is_instance_valid(warning), "warning is removed when the bolt fires")
	var bolts := get_tree().get_nodes_in_group(&"projectiles")
	check_eq(bolts.size(), 1, "one bolt fires at the end of the warning")
	if not bolts.is_empty():
		check_near(bolts[0].speed, 320.0, 0.01, "bolt retains its speed")
		check_eq(bolts[0].damage, 2, "bolt retains its damage")
	await dispose(room)


func _phases_reset_and_rewards() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Tidewick")
	boss.rng.seed = 12345
	await seconds(1.6)
	check(boss.apply_damage(14, boss.global_position, 0), "scripted threshold setup accepted")
	check_eq(boss.phase, 2, "phase2 begins at10HP")
	check_near(boss.travel_speed, 260, 0.01, "phase2speed260")
	await seconds(1.4)
	check_eq(boss.leeches.size(), 2, "phase2 spawns two real fen leeches")
	for leech in boss.leeches:
		check(leech.scene_file_path.ends_with("fen_leech.tscn"), "actual M3 counterpart")
	await seconds(5.9)
	check(is_instance_valid(boss.wave_warning), "undertow telegraph before7second release")
	await seconds(1.0)
	check(is_instance_valid(boss.wave), "phase2 emits undertow")
	if is_instance_valid(boss.wave):
		check_eq(boss.wave.damage, 3, "wave damage3")
		check(not boss.wave.blockable, "wave ignores ward")
		var before: Vector2 = boss.wave.global_position
		await frames(1)
		check_near(boss.wave.global_position.distance_to(before), 5.0, 0.1, "wave travels300px/s")
	await _capture("phase2")
	var direction: float = boss.travel_direction
	await seconds(5.0)
	check(boss.travel_direction != direction, "seeded reversal occurs within8to12seconds")
	boss.reset_fight()
	await frames(3)
	check_eq(boss.hp, 24, "reset restores full HP")
	check_eq(boss.phase, 1, "reset restores phase1")
	check_eq(boss.leeches.size(), 0, "reset clears summoned leeches")
	check(not is_instance_valid(boss.wave), "reset clears wave")
	check(not boss.tail_exposed(), "reset intro closes tail")
	await seconds(1.6)
	boss.apply_damage(99, boss.global_position, 0)
	check(GameState.has_flag(&"boss_cave_3_9_defeated"), "death sets canonical flag")
	check(not boss.contact_hitbox.active, "death head harmless")
	check(not boss.tail_exposed(), "death closes tail")
	check(boss.death_drops.is_empty(), "boss owns no fragment/core rewards")
	await seconds(1.6)
	check(not is_instance_valid(boss), "death throes free boss")
	var scene := load(SCENE) as PackedScene
	var retired := scene.instantiate() as EnemyBase
	room.get_node("Enemies").add_child(retired)
	check(retired.is_dead and not retired.visible, "defeated boss stays retired")
	await dispose(room)


func _wave_visual_directions() -> void:
	for direction in [Vector2.RIGHT, Vector2.DOWN]:
		reset_state()
		var room := _fixture()
		var boss = room.get_node("Enemies/Tidewick")
		await seconds(1.6)
		boss.wave_direction = direction
		boss._start_wave()
		var collision := boss.wave.get_child(0) as CollisionShape2D
		var rectangle := collision.shape as RectangleShape2D
		var expected := Vector2(144, 768) if direction == Vector2.RIGHT else Vector2(1536, 144)
		check_eq(rectangle.size, expected, "undertow retains its contracted hitbox")
		if SpriteVisual.has_art(&"tidewick_wave_ripple"):
			var visual: Node2D = boss.wave.get_node("Visual")
			check_eq(visual.size, rectangle.size, "painted band marks the whole hitbox")
			var lights := visual.find_children("*", "PointLight2D", true, false)
			check_eq(lights.size(), 6 if direction == Vector2.RIGHT else 12, "band is lit end to end")
			for light in lights:
				check(not light.is_in_group(&"glow_light"), "wave lights are presentation only")
		await dispose(room)


func _capture(label: String) -> void:
	if OS.get_environment("WICK_B03_CAPTURE") != "1":
		return
	await get_tree().process_frame
	RenderingServer.force_draw()
	check_eq(
		get_viewport().get_texture().get_image().save_png("/tmp/b03-" + label + ".png"),
		OK,
		"capture actual phase state"
	)


func _capture_real_ripple() -> void:
	reset_state()
	SaveGame.enabled = false
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var packed := load(WORLD) as PackedScene
	var world := packed.instantiate() as World
	viewport.add_child(world)
	world.start_at(&"cave_3_9")
	var boss = world.current_room.get_node("Enemies/Tidewick1")
	await seconds(5.8)
	check(boss.ripple.visible, "real dark basin shows the tail warning")
	await get_tree().process_frame
	RenderingServer.force_draw()
	check_eq(
		viewport.get_texture().get_image().save_png("/tmp/b03-ripple-dark.png"),
		OK,
		"capture real dark basin warning"
	)
	await dispose(viewport)


func _capture_real_bolt_warning() -> void:
	reset_state()
	SaveGame.enabled = false
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var packed := load(WORLD) as PackedScene
	var world := packed.instantiate() as World
	viewport.add_child(world)
	world.start_at(&"cave_3_9")
	var boss = world.current_room.get_node("Enemies/Tidewick1")
	await seconds(4.2)
	check(is_instance_valid(boss._bolt_warning), "real dark basin shows the bolt warning")
	await get_tree().process_frame
	RenderingServer.force_draw()
	check_eq(
		viewport.get_texture().get_image().save_png("/tmp/b03-bolt-warning-dark.png"),
		OK,
		"capture real dark basin bolt warning"
	)
	await dispose(viewport)


func _capture_real_wave(direction: Vector2, label: String) -> void:
	# Controlled direction and phase in the real dark room, with the real moving hitbox.
	reset_state()
	SaveGame.enabled = false
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var packed := load(WORLD) as PackedScene
	var world := packed.instantiate() as World
	viewport.add_child(world)
	world.start_at(&"cave_3_9")
	var boss = world.current_room.get_node("Enemies/Tidewick1")
	await seconds(1.6)
	boss.apply_damage(14, boss.global_position, 0)
	await seconds(1.3)
	boss.wave_direction = direction
	boss._start_wave()
	await seconds(1.1)
	await get_tree().process_frame
	RenderingServer.force_draw()
	check_eq(
		viewport.get_texture().get_image().save_png("/tmp/b03-wave-" + label + "-dark.png"),
		OK,
		"capture real dark basin undertow"
	)
	await dispose(viewport)


func _board(room: Room) -> Player:
	var dock := room.get_node("Props/Basin/Dock")
	var hero := make_player(room, dock.landing_position())
	GameState.acquire_item(&"reed_raft")
	GameState.set_active_item(&"reed_raft")
	check(hero.use_item(), "real raft boards from basin's only dock")
	await seconds(0.4)
	check(hero.is_on_raft(), "actual free-steering rider is active")
	Input.action_press(&"move_right")
	await seconds(0.6)
	release_inputs()
	await seconds(0.5)
	check(hero.global_position.x > room.global_position.x + 360, "steering leaves dock into water")
	return hero


func _follow_tail(hero: Player, boss: Variant, ticks: int) -> void:
	for i in range(ticks):
		if not is_instance_valid(boss) or boss.is_dying():
			break
		# Controlled combat setup uses the public swept displacement, never private raft state.
		hero.push_raft(boss.tail.global_position + Vector2(0, 75) - hero.global_position)
		hero.facing = Vector2.UP
		await frames(1)


func _real_raft_combat() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/Tidewick")
	var hero := make_player(room, Vector2(184, 432))
	await seconds(1.6)
	var hp: int = boss.hp
	var shore := make_hitbox(room, boss.tail.global_position, Layers.Team.PLAYER, 2, 45)
	shore.kind = &"hook"
	shore.source = hero
	await frames(4)
	check_eq(boss.hp, hp, "shore hook cannot damage even an exposed tail")
	await dispose(shore)
	await dispose(hero)
	hero = await _board(room)
	hero.set_hurtbox_enabled(self, false)
	for i in range(360):
		if boss.tail_exposed():
			break
		await frames(1)
	var wrong := make_hitbox(room, boss.tail.global_position, Layers.Team.PLAYER, 4, 45)
	wrong.kind = &"explosion"
	wrong.source = hero
	await frames(3)
	check_eq(boss.hp, hp, "rafted pot cannot replace hook/flare weakness")
	await dispose(wrong)
	await _follow_tail(hero, boss, 2)
	Input.action_press(&"attack")
	await _follow_tail(hero, boss, 7)
	Input.action_release(&"attack")
	await _follow_tail(hero, boss, 22)
	check_eq(boss.hp, hp - 2, "actual rider hook deals two half-hearts to tail")
	# Charge away from the exposed window, then release a real flare over the next surfacing.
	for i in range(240):
		if not boss.tail_exposed():
			break
		await frames(1)
	Input.action_press(&"attack")
	await seconds(0.9)
	for i in range(300):
		if boss.tail_exposed():
			break
		await _follow_tail(hero, boss, 1)
	await _follow_tail(hero, boss, 2)
	hp = boss.hp
	Input.action_release(&"attack")
	await _follow_tail(hero, boss, 10)
	check_eq(boss.hp, hp - 4, "actual rider charged flare deals four")
	await _capture("raft-tail")
	for strike in range(100):
		if boss.is_dying():
			break
		if not boss.tail_exposed() or boss.is_pausing():
			await _follow_tail(hero, boss, 10)
			continue
		await _follow_tail(hero, boss, 2)
		Input.action_press(&"attack")
		await _follow_tail(hero, boss, 7)
		Input.action_release(&"attack")
		await _follow_tail(hero, boss, 23)
	check(
		GameState.has_flag(&"boss_cave_3_9_defeated"),
		"actual raft hook/flare defeat both boss phases"
	)
	check(hero.is_on_raft(), "combat never required leaving actual raft")
	await seconds(1.6)
	await dispose(room)


func _real_undertow(grid: Vector2i = Vector2i.ZERO) -> void:
	reset_state()
	var room := _fixture(grid)
	var boss = room.get_node("Enemies/Tidewick")
	boss.rng.seed = 12345
	var hero := await _board(room)
	hero.set_hurtbox_enabled(self, false)
	await seconds(0.2)
	boss.apply_damage(14, boss.global_position, 0)
	for tick in range(600):
		if is_instance_valid(boss.wave):
			break
		await frames(1)
	check(is_instance_valid(boss.wave), "real undertow reaches boarded rider scenario")
	if not is_instance_valid(boss.wave):
		await dispose(room)
		return
	var direction: Vector2 = boss.wave_direction
	hero.push_raft(boss.wave.global_position + direction * 20 - hero.global_position)
	await frames(3)
	var before := hero.global_position
	await frames(2)
	check_near(
		(hero.global_position - before).dot(direction),
		200.0 / 30.0,
		0.5,
		"undertow applies200px/s even with damage disabled"
	)
	var hits: Array[int] = []
	hero.hurt_taken.connect(func(amount: int) -> void: hits.append(amount))
	Input.action_press(&"ward")
	hero.facing = -direction
	await frames(2)
	check(hero.ward_up, "actual rider ward is raised before wave")
	hero.set_hurtbox_enabled(self, true)
	before = hero.global_position
	await frames(5)
	release_inputs()
	check_eq(hits, [3], "actual undertow damages through ward exactly once during iframes")
	var displacement := (hero.global_position - before).dot(direction)
	check(
		displacement >= 96 and displacement < 130,
		"accepted hit adds96once alongside sustained flow, no duplicate boss push"
	)
	var water := room.get_node("Props/Basin/Basin")
	check(water.contains_point(hero.global_position), "real wave keeps rider inside basin")
	await _capture("raft-undertow")
	await dispose(room)


func _real_ember_ward() -> void:
	reset_state()
	var room := _fixture()
	var hero := await _board(room)
	var bolts: Array[Node] = []
	for tick in range(240):
		bolts = get_tree().get_nodes_in_group(&"projectiles")
		if not bolts.is_empty():
			break
		await frames(1)
	check(not bolts.is_empty(), "actual head fires toward real raft rider")
	if bolts.is_empty():
		await dispose(room)
		return
	var bolt := bolts[0] as EnemyProjectile
	var outcomes: Array[StringName] = []
	bolt.destroyed.connect(func(reason: StringName) -> void: outcomes.append(reason))
	hero.push_raft(bolt.global_position + bolt.direction * 240 - hero.global_position)
	hero.facing = -bolt.direction
	Input.action_press(&"ward")
	var health := GameState.health
	await seconds(1.0)
	release_inputs()
	check(outcomes.has(&"ward"), "actual rider ward destroys Tidewick ember")
	check_eq(GameState.health, health, "warded ember leaves rider health unchanged")
	check(hero.is_on_raft(), "ward block retains actual raft ride")
	await dispose(room)
