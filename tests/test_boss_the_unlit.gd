## timeout=180
extends TestCase
## Controlled positioning and disabled player hurtbox isolate tool provenance.
## These probes do not claim a human balance/feel playthrough.
const SCENE := "res://scenes/enemies/bosses/the_unlit.tscn"
const WORLD_SCENE := "res://scenes/world/world.tscn"
const GALLERY := "res://tests/fixtures/gallery/B10.tscn"
var captures := false
var capture_viewport: SubViewport


func run() -> void:
	captures = OS.get_cmdline_user_args().has("--b10-captures")
	if captures:
		capture_viewport = SubViewport.new()
		capture_viewport.size = Vector2i(1920, 1080)
		capture_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(capture_viewport)
	await _arena_presentation()
	await _room_clone_lifecycle()
	await _orbit_and_reset()
	await _full_physical_fight()
	await _hazards_and_ward()
	await _bolt_presentation()
	await _scheduled_attacks()
	await _world_presentation()
	await _missing_art_presentation()
	await _chain_presentation()
	await _lash_missing_art()


func _arena_presentation() -> void:
	reset_state()
	SaveGame.enabled = false
	var world := (load(WORLD_SCENE) as PackedScene).instantiate() as World
	add_child(world)
	world.start_at(&"cave_10_14")
	world.player.set_hurtbox_enabled(self, false)
	await frames(5)
	var room := world.current_room
	var boss = room.get_node("Enemies/TheUnlit1")
	var light: PointLight2D = boss._arena_light
	check(is_instance_valid(light), "arena has a presentation light")
	check(not light.is_in_group(&"glow_light"), "arena light does not activate glow gameplay")
	var origin: Vector2 = boss._phase_origin + boss.ARENA_CENTRE
	check_eq(light.global_position, origin, "arena light starts at room centre")
	boss.global_position += Vector2(100, 30)
	await frames(2)
	check_eq(light.global_position, origin, "arena light stays fixed when boss moves")
	boss._start_phase(2)
	check_eq(boss._arena_light, light, "phase two retains one arena light")
	boss._start_phase(3)
	check_eq(boss._arena_light, light, "phase three retains one arena light")
	var mounts := room.get_node("Props/Arena1/Visual")
	var names := ["LeftPost", "CentrePost", "RightPost"]
	var positions := [Vector2(576, 96), Vector2(960, 96), Vector2(1344, 96)]
	for i in range(names.size()):
		var mount := mounts.get_node(names[i]) as Sprite2D
		check(mount != null and mount.texture != null, "painted mount is present")
		check_eq(mount.position, positions[i], "chain post position is unchanged")
		check_eq(mount.get_child_count(), 0, "chain mount has no physics children")
		check(not mount.is_in_group(&"reelable"), "chain mount is not a reel target")
	world.start_at(&"cave_10_12")
	await frames(5)
	check(not is_instance_valid(light), "arena light is removed on room exit")
	world.start_at(&"cave_10_14")
	await frames(5)
	boss = world.current_room.get_node("Enemies/TheUnlit1")
	check(is_instance_valid(boss._arena_light), "arena light returns on re-entry")
	boss._on_death()
	await frames(2)
	check(not is_instance_valid(boss._arena_light), "arena light is removed on death")
	await dispose(world)
	reset_state()


func _lash_missing_art() -> void:
	reset_state()
	var arena := make_arena()
	var boss = (load(SCENE) as PackedScene).instantiate()
	var lash = boss.Band.new()
	arena.add_child(lash)
	var look = lash.get_node("Visual")
	look.picture.texture = null
	await frames(2)
	check(look.picture.texture == null, "missing lash texture keeps fallback path")
	check(not lash.active, "missing lash art preserves safe warning")
	check_eq((lash.get_child(0).shape as RectangleShape2D).size, Vector2(96, 768), "fallback keeps bounds")
	await seconds(0.8)
	check(is_instance_valid(lash) and lash.active, "missing lash art preserves activation")
	await dispose(arena)
	boss.free()


func _chain_presentation() -> void:
	reset_state()
	var arena := make_arena()
	var packed := load(SCENE) as PackedScene
	var boss = packed.instantiate()
	arena.add_child(boss)
	await frames(2)
	check(boss._chains != null, "lantern chains use painted link when present")
	if boss._chains != null:
		var chains = boss._chains
		check(chains.texture != null, "chain retains its texture for drawing")
		check_eq(chains.get_child_count(), 0, "chains create no physics children")
		var short: Array[Vector2] = chains.pieces(67.0)
		var longer: Array[Vector2] = chains.pieces(92.0)
		check_eq(short.size(), 4, "short chain has overlapping pieces")
		check_eq(longer.size(), 5, "longer chain adds pieces")
		for i in range(short.size()):
			check_eq(short[i].x, longer[i].x, "existing links stay anchored at the post")
		check_near(short.back().y, 1.0, 0.001, "last partial link clips to the lantern")
	await dispose(arena)
	var missing_arena := make_arena()
	var missing = packed.instantiate()
	missing.chain_art_path = "res://missing-unlit-chain.png"
	missing_arena.add_child(missing)
	await frames(2)
	check(missing._chains == null, "missing chain art keeps original line fallback")
	await dispose(missing_arena)


func _missing_art_presentation() -> void:
	reset_state()
	SpriteVisual.use_manifest("res://tests/fixtures/b10_missing_art.json")
	var room := _fixture()
	var boss = room.get_node("Enemies/TheUnlit")
	await seconds(1.7)
	check(boss.visual is Placeholder, "missing mass retains body fallback")
	check(boss.lantern.get_node("Visual").visible, "missing mass retains lantern fallback")
	var hand = boss.Hand.new()
	room.add_child(hand)
	await frames(2)
	check(hand.visual is Placeholder, "missing hand retains fallback")
	check_eq(hand.visual.get_child_count(), 0, "missing hand needs no presentation observer")
	boss._bolt(Vector2(300, 300), 320.0)
	var fallback = boss._hazards.back()
	check_eq(fallback.visual_kind, &"spore", "missing projectile art retains spore fallback")
	fallback.destroy(&"hit")
	check_eq(room.find_children("BoltImpact", "Node2D", true, false).size(), 0, "no missing impact is spawned")
	await dispose(room)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)


func _bolt_presentation() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/TheUnlit")
	var player := make_player(room, Vector2(1400, 700))
	player.set_hurtbox_enabled(self, false)
	await seconds(1.6)
	boss.set_physics_process(false)
	for homing in [false, true]:
		var kind: StringName = &"unlit_hush_torrent" if homing else &"unlit_gaze_bolt"
		boss._bolt(Vector2(600, 400), 240.0 if homing else 320.0, 0.4, homing)
		var bolt = boss._hazards.back()
		check_eq(bolt.visual_kind, kind, "bolt selects its own painted art")
		check_eq(bolt.damage, 2, "bolt keeps two damage")
		check_eq(bolt.radius, 12.0, "bolt keeps collision radius")
		check(bolt.blockable_by_ward, "bolt remains blockable")
		var look := bolt.get_node("Visual") as SpriteVisual
		check(look != null, "bolt has painted visual")
		if look != null:
			check_eq(look.sprite_frames.get_frame_count(&"idle"), 2, "flight has two frames")
			check_near(look.rotation, bolt.direction.angle(), 0.001, "flight points along direction")
		var light := bolt.get_node("BoltLight") as PointLight2D
		check(not light.is_in_group(&"glow_light"), "bolt light is presentation only")
		await frames(10)
		if is_instance_valid(bolt) and look != null:
			check_near(look.rotation, bolt.direction.angle(), 0.001, "visual follows homing turns")
			bolt.destroy(&"wall")
			var impact = boss._hazards.back()
			check_eq(impact.name, &"BoltImpact", "physical impact spawns effect")
			var effect := impact.get_node("Visual") as SpriteVisual
			check_eq(effect.animation, &"impact", "impact plays its own animation")
			check_eq(effect.sprite_frames.get_frame_count(&"impact"), 3, "impact has three frames")
			await seconds(0.5)
			check(not is_instance_valid(impact), "impact retires after animation")
	for reason in [&"range", &"bounds"]:
		boss._bolt(Vector2(600, 400), 320.0)
		var bolt = boss._hazards.back()
		bolt.destroy(reason)
		check_eq(room.find_children("BoltImpact", "Node2D", true, false).size(), 0, "expiry has no impact")
	await dispose(room)


## Positioned visual fixture in the real streamed C10 room, not an earned route.
func _world_presentation() -> void:
	reset_state()
	var packed := load(WORLD_SCENE) as PackedScene
	check(packed != null, "actual World scene loads")
	if packed == null:
		return
	var world := packed.instantiate() as World
	if captures:
		capture_viewport.add_child(world)
	else:
		add_child(world)
	world.start_at(&"cave_10_14")
	world.player.set_hurtbox_enabled(self, false)
	world.player.place_at(world.current_room.position + Vector2(1280, 480))
	var boss = world.current_room.get_node("Enemies/TheUnlit1")
	await seconds(1.7)
	if captures:
		check(SpriteVisual.has_art(&"unlit_p1_mass"), "capture requires accepted mass art")
		check(SpriteVisual.has_art(&"unlit_hush_hand"), "capture requires accepted hand art")
	if SpriteVisual.has_art(&"unlit_p1_mass"):
		check(boss.visual is SpriteVisual, "World P1 selects accepted mass")
		check_eq(boss.visual.animation, &"idle", "World P1 plays mass idle")
		check_eq(boss.visual.sprite_frames.get_frame_count(&"idle"), 2, "mass idle has two frames")
		check_eq(boss.visual.offset, Vector2(-384, -384), "floating mass centre preserved")
	check_eq(
		boss.lantern.get_node("Visual").visible,
		not SpriteVisual.has_art(&"unlit_p1_mass"),
		"only painted P1 suppresses overlapping lantern body fallback"
	)
	await _capture("world-c10-p1")
	var hand: EnemyBase
	for tick in range(360):
		for hazard in boss._hazards:
			if is_instance_valid(hazard) and hazard.get_script() == boss.Hand:
				hand = hazard
				break
		if hand != null:
			break
		await frames(1)
	check(hand != null, "World C10 naturally schedules hands")
	if hand != null:
		await seconds(0.3)
		_check_hand_look(hand, &"rise", false)
		await _capture("world-c10-hand-rise")
		await seconds(0.9)
		_check_hand_look(hand, &"hold", true)
		await _capture("world-c10-hand-hold")
		await seconds(1.65)
		_check_hand_look(hand, &"sink", true)
		await _capture("world-c10-hand-sink")
		await seconds(0.25)
		check(not is_instance_valid(hand), "sink preserves three-second retirement")
	# Labelled presentation phase fixtures; the existing fight proves real tools.
	boss.hp = 60
	boss._start_phase(2)
	await seconds(1.7)
	check(SpriteVisual.has_art(&"unlit_p2_shell"), "shell has painted art")
	check(boss.visual is SpriteVisual, "World P2 selects the painted shell")
	check_eq(boss.visual.offset, Vector2(-256, -350), "shell foot and body anchor preserved")
	await _capture("world-c10-p2-shell")
	boss.hp = 24
	boss._start_phase(3)
	await seconds(1.7)
	check(is_instance_valid(boss.lantern), "World P3 keeps canonical lantern")
	check(boss.lantern.hurtbox.enabled, "World P3 exposes actual reel target")
	check(boss.lantern.get_node("Visual").visible, "P3 shows the lantern target")
	check(boss.lantern.get_node("Visual") is SpriteVisual, "P3 lantern uses painted art")
	check(boss.visual is SpriteVisual, "P3 heart uses painted art")
	check(not boss._heart_glow.visible, "painted heart replaces the geometric fallback")
	await _capture("world-c10-p3-fallback")
	GameState.set_flag(&"boss_cave_10_14_defeated")
	world.start_at(&"cave_10_13")
	world.start_at(&"cave_10_14")
	await frames(3)
	var retired = world.current_room.get_node("Enemies/TheUnlit1")
	check(retired.is_dead and not retired.visible, "World saved defeat retires actor")
	for target in get_tree().get_nodes_in_group(&"reelable"):
		check(not retired.is_ancestor_of(target), "World retired actor has no reel target")
	await _capture("world-c10-retired")
	await dispose(world)


func _check_hand_look(hand: EnemyBase, state: StringName, active: bool) -> void:
	check_eq(hand.contact_hitbox.active, active, "hand contact unchanged during " + state)
	check_eq(hand.hurtbox.enabled, active, "hand hurtbox unchanged during " + state)
	if SpriteVisual.has_art(&"unlit_hush_hand"):
		check(hand.visual is SpriteVisual, "hand selects accepted art")
		check_eq(hand.visual.animation, state, "natural hand presentation " + state)
		check_eq(
			hand.visual.sprite_frames.get_frame_count(state),
			{&"rise": 4, &"hold": 2, &"sink": 3}[state],
			"accepted hand frame count " + state
		)
		check_eq(hand.visual.offset, Vector2(-96, -76), "hand contractual foot anchor")


func _fixture() -> Room:
	var packed := load(GALLERY) as PackedScene
	check(packed != null, "owned gallery loads")
	var room := packed.instantiate() as Room
	if captures:
		capture_viewport.add_child(room)
	else:
		add_child(room)
	room.enter()
	return room


func _probe(parent: Node, at: Vector2, kind: StringName, damage: int) -> void:
	var hit := make_hitbox(parent, at, Layers.Team.PLAYER, damage, 36)
	hit.kind = kind
	await frames(4)
	await dispose(hit)
	await seconds(0.27)


func _orbit_and_reset() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/TheUnlit")
	check_eq(boss.hp, 75, "75 total HP")
	check(boss.is_in_intro(), "intro active")
	await _probe(room, boss.global_position, &"explosion", 75)
	check_eq(boss.hp, 75, "intro safe")
	await seconds(1.2)
	check_eq(boss.eyes.size(), 5, "five actual eye parts")
	for eye in boss.eyes:
		check_eq(eye.hp, 3, "eye3HP")
		check(eye.visual is SpriteVisual, "eye uses painted art")
		check(eye.get_node_or_null("EyeLight") is PointLight2D, "eye is visible in the dark")
		check_eq(eye.room_rect, Rect2(), "eye not body confined")
		check_near(eye.global_position.distance_to(Vector2(960, 288)), 330, 0.1, "literal330orbit")
	var eye = boss.eyes[0]
	await _probe(room, eye.global_position, &"hook", 99)
	check_eq(eye.hp, 3, "hook cannot damage eye")
	check(not boss.apply_damage(75, boss.global_position), "scripted bypass rejected")
	var upper := false
	var lower := false
	for i in range(100):
		await frames(10)
		if is_instance_valid(eye):
			var y: float = eye.global_position.y
			if not upper and y < 0:
				await _capture("p1-upper-arc")
			upper = upper or y < 0
			lower = lower or y > 480
	check(upper, "literal upper arc leaves room")
	check(lower, "same eye returns to accessible lower arc")
	Events.player_died.emit()
	await frames(3)
	check_eq(boss.hp, 75, "death resets fullHP")
	check_eq(boss.phase, 1, "death resets phase1")
	check(boss.parts().is_empty(), "reset clears old eyes")
	check(boss.is_in_intro(), "reset restores intro")
	await seconds(1.6)
	check_eq(boss.parts().size(), 5, "reset respawns exactly five")
	await dispose(room)


func _full_physical_fight() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/TheUnlit")
	var player := make_player(room, Vector2(1632, 480))
	player.set_hurtbox_enabled(self, false)
	for item in [&"tallow_sling", &"cinder_wick", &"reel_line", &"pitch_pot"]:
		GameState.acquire_item(item)
	GameState.slugs = 0
	GameState.pitch_pots = 0
	await seconds(1.6)
	var slug_supply := false
	var pot_supply := false
	for pickup in get_tree().get_nodes_in_group(&"pickups"):
		slug_supply = slug_supply or pickup.kind == &"slug_bundle"
		pot_supply = pot_supply or pickup.kind == &"pitch_pot_bundle"
	check(slug_supply and pot_supply, "actual phase-start resupply")
	GameState.add_slugs(30)
	GameState.set_active_item(&"tallow_sling")
	await _capture("p1-accessible")
	# Real sling projectiles intercept moving eyes from controlled nearby positions.
	for eye in boss.eyes.duplicate():
		if not is_instance_valid(eye):
			continue
		var attempts := 0
		while is_instance_valid(eye) and not eye.is_dead and attempts < 12:
			while is_instance_valid(eye) and eye.global_position.y < 180:
				await frames(6)
			if not is_instance_valid(eye):
				break
			player.place_at(eye.global_position + Vector2(0, 80))
			player.facing = Vector2.UP
			if player.use_item():
				attempts += 1
			await seconds(0.35)
		check(not is_instance_valid(eye) or eye.is_dead, "real sling killed accessible moving eye")
	check_eq(boss.phase, 2, "fifteen real slug damage forces phase2")
	check_eq(boss.hp, 60, "shell begins at total60")
	await seconds(1.3)
	await _probe(room, boss.global_position, &"hook", 50)
	check_eq(boss.hp, 60, "shell rejects hook")
	await _probe(room, boss.global_position, &"sling", 50)
	check_eq(boss.hp, 60, "shell rejects sling")
	await _capture("p2-wax")
	GameState.set_active_item(&"cinder_wick")
	for cast in range(3):
		player.place_at(boss.global_position + Vector2(0, 180))
		player.facing = Vector2.UP
		check(player.use_item(), "real cinder cast accepted")
		await seconds(0.3)
		# The physical flame attaches; moving the player away keeps the shell walking.
		player.place_at(Vector2(1632, 720))
		var wave_before: float = boss._wave_left
		await seconds(2.5)
		if boss.phase == 2:
			check_near(boss._wave_left, wave_before, 0.05, "attached flame pauses wax wave")
		await seconds(1.2)
	check_eq(boss.phase, 3, "three actual flame casts finish36shell")
	check_eq(boss.hp, 24, "heart starts24")
	await seconds(1.3)
	check_eq(boss.visual.animation, &"shielded", "heart is visibly shielded")
	check_eq(boss.visual.offset, Vector2(-256, -256), "heart retains its centre anchor")
	var lamp_look := boss.lantern.get_node("Visual") as SpriteVisual
	check(lamp_look != null, "lantern uses painted art")
	if lamp_look != null:
		var first_lamp_frame := lamp_look.animation
		await seconds(0.5)
		check(lamp_look.animation != first_lamp_frame, "hanging lantern glow changes")
	await _probe(room, boss.global_position, &"flare", 99)
	check_eq(boss.hp, 24, "shielded heart rejects flare")
	await _capture("p3-shielded")
	GameState.set_active_item(&"reel_line")
	for cycle in range(3):
		player.place_at(Vector2(960, 720))
		player.facing = Vector2.UP
		check(player.use_item(), "actual reel fired within576")
		await seconds(0.5)
		check(boss.exposed_left > 0, "real reel hit exposes heart")
		check(boss.visual.animation in [&"idle", &"pulse"], "reel shows exposed heart")
		await seconds(0.4)
		check_near(
			boss.lantern.global_position.distance_to(Vector2(960, 288)),
			288,
			0.5,
			"lantern slides288towardplayer"
		)
		if cycle == 0:
			await _capture("p3-exposed")
		# Actual hook input produces two half-hearts per swing.
		for swing in range(5):
			player.place_at(boss.global_position + Vector2(0, 108))
			player.facing = Vector2.UP
			Input.action_press(&"attack")
			await frames(10)
			Input.action_release(&"attack")
			await seconds(0.3)
		check_eq(boss.hp, 16 - cycle * 8 if cycle < 2 else 1, "each pull allows exactly8HP")
		if cycle < 2:
			await seconds(3.6)
			check(boss.exposed_left <= 0, "six second exposure expires")
			check_eq(boss.visual.animation, &"shielded", "heart closes when exposure expires")
			check_eq(boss.lantern.global_position, Vector2(960, 288), "chains rehoist lantern")
	check_eq(boss.pulls, 3, "three physical reel pulls")
	check(boss.is_dying(), "real hook lethal starts fade")
	check(GameState.has_flag(&"boss_cave_10_14_defeated"), "canonical final boss flag")
	check(not GameState.has_flag(&"ending_rekindle"), "no invented ending flag")
	check(boss.death_drops.is_empty(), "final boss no rewards")
	boss.reset_fight()
	check(boss.is_dying(), "reset cannot revive defeat")
	await seconds(2.1)
	check(not is_instance_valid(boss), "two second fade frees actor")
	if is_instance_valid(lamp_look):
		var settled_frame := lamp_look.animation
		await seconds(0.5)
		check(lamp_look.animation != settled_frame, "settled lantern glow keeps changing")
	else:
		check(false, "settled lantern retains its visual")
	check(get_tree().get_nodes_in_group(&"projectiles").is_empty(), "death cleans projectiles")
	var packed := load(SCENE) as PackedScene
	check(packed != null, "actor scene loads")
	var retired = packed.instantiate()
	room.get_node("Enemies").add_child(retired)
	check(retired.is_dead and not retired.visible, "reload keeps final defeat")
	for pickup in get_tree().get_nodes_in_group(&"pickups"):
		check(
			pickup.kind != &"fragment" and pickup.kind != &"wick_core",
			"no persistent duplicate reward"
		)
	await dispose(room)


func _hazards_and_ward() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/TheUnlit")
	var player := make_player(room, Vector2(960, 720))
	await seconds(1.6)
	player.facing = Vector2.UP
	Input.action_press(&"ward")
	await frames(4)
	var health := GameState.health
	boss._bolt(Vector2(960, 540), 320)
	var ward_impact: Node
	for tick in range(42):
		await frames(1)
		var impacts := room.find_children("BoltImpact", "Node2D", true, false)
		if not impacts.is_empty():
			ward_impact = impacts[0]
			break
	check(ward_impact != null, "real ward contact creates an impact effect")
	check_eq(GameState.health, health, "real ward destroys gaze bolt")
	boss.clear_hazards()
	await frames(3)
	check(not is_instance_valid(ward_impact), "clearing hazards removes impact effects")
	boss._ring(Vector2(960, 480), 720, 360, 96)
	await seconds(1.0)
	check_eq(GameState.health, health, "front ward negates annular wax area")
	boss.clear_hazards()
	await frames(3)
	player.place_at(Vector2(960, 720))
	player.facing = Vector2.DOWN
	await frames(4)
	boss._ring(Vector2(960, 480), 720, 360, 96)
	await seconds(1.0)
	check_eq(GameState.health, health - 3, "rear wave deals3through ward")
	release_inputs()
	boss.reset_fight()
	await frames(3)
	check(
		get_tree().get_nodes_in_group(&"projectiles").is_empty(), "reset clears projectile hazards"
	)
	await dispose(room)


func _capture(label: String) -> void:
	if not captures:
		return
	await get_tree().process_frame
	RenderingServer.force_draw(false)
	capture_viewport.get_texture().get_image().save_png("/tmp/b10-%s.png" % label)


## Labelled controlled hitbox fixtures advance phases for attack timing probes.
## The separate full fight above proves the real tool path.
func _scheduled_attacks() -> void:
	reset_state()
	var room := _fixture()
	var boss = room.get_node("Enemies/TheUnlit")
	var player := make_player(room, Vector2(1500, 720))
	player.set_hurtbox_enabled(self, false)
	await seconds(1.6)
	await seconds(2.95)
	check(boss.gaze_tell[0] > 0, "gaze has half second tell before first shot")
	check_near(boss.eyes[0].get_node("EyeLight").energy, 1.3, 0.01, "eye brightens for tell")
	await seconds(0.55)
	check_near(boss.eyes[0].get_node("EyeLight").energy, 0.65, 0.01, "eye dims after tell")
	var gaze_bolts := 0
	for projectile in get_tree().get_nodes_in_group(&"projectiles"):
		if projectile.speed == 320:
			gaze_bolts += 1
	check(gaze_bolts > 0, "scheduled gaze fires320bolt")
	await seconds(1.6)
	var hands: Array[EnemyBase] = []
	for hazard in boss._hazards:
		if is_instance_valid(hazard) and hazard is EnemyBase and hazard.contact_damage == 4:
			hands.append(hazard)
	check_eq(hands.size(), 2, "two scheduled hands")
	for hand in hands:
		check(not hand.contact_hitbox.active, "hand marker has1second safe tell")
		check_eq(hand.max_hp, 2, "hand2HP")
	await seconds(1.0)
	for hand in hands:
		check(hand.contact_hitbox.active, "hand contact active aftertell")
		check_eq(hand.collision_layer, Layers.WORLD, "hand is actual obstacle")
	await seconds(2.0)
	for hand in hands:
		check(not is_instance_valid(hand), "hand expires after2seconds active")
	for i in range(2):
		await _probe(room, boss.eyes[i].global_position, &"sling", 3)
	await frames(3)
	check_eq(
		get_tree().get_nodes_in_group(&"unlit_hounds").size(), 2, "three eyes left summons2hounds"
	)
	for i in range(2, 5):
		await _probe(room, boss.eyes[i].global_position, &"sling", 3)
	check_eq(boss.phase, 2, "controlled fixture reaches shell")
	await seconds(1.3)
	await _probe(room, boss.global_position, &"explosion", 4)
	check_eq(boss.hp, 58, "explosion deals2to shell")
	await seconds(4.1)
	var wave: Hitbox
	for hazard in boss._hazards:
		if is_instance_valid(hazard) and hazard is Hitbox and hazard.kind == &"unlit_ring":
			wave = hazard
	check(wave != null, "scheduled wax wave exists after0.8tell")
	if wave != null:
		check_eq(wave.damage, 3, "wax3damage")
		check_near(wave.width, 96, 0.01, "wax96thickness")
		check_near(wave.speed, 360, 0.01, "wax360speed")
		check_near(wave.reach, 720, 0.01, "wax720reach")
		var look = wave.get_node("Visual")
		check(look.get_script() == boss.WaxWaveVisual, "wax wave uses the painted presentation")
		check(
			look.art.effect.get_shader_parameter("wax") != null,
			"wax wave texture is loaded"
		)
	await seconds(7.5)
	var drips := 0
	for hazard in boss._hazards:
		if is_instance_valid(hazard) and hazard is EnemyBase and hazard.visual_kind == &"wickling":
			drips += 1
	check_eq(drips, 3, "twelve second shell sheds3wicklings")
	for i in range(17):
		await _probe(room, boss.global_position, &"fire", 1)
	check_eq(boss.phase, 3, "controlled fixture reaches heart")
	await seconds(1.3)
	await seconds(4.55)
	var torrent := 0
	for projectile in get_tree().get_nodes_in_group(&"projectiles"):
		if projectile.speed == 240:
			torrent += 1
			check_near(projectile.homing_turn_deg, 90, 0.01, "torrent90turn")
			check_near(projectile.lifetime, 4, 0.01, "torrent4secondlife")
	check_eq(torrent, 4, "scheduled torrent4homingbolts")
	await seconds(1.5)
	var lash: Hitbox
	for hazard in boss._hazards:
		if is_instance_valid(hazard) and hazard is Hitbox and hazard.kind == &"chain_lash":
			lash = hazard
	check(lash != null, "six second chain lash tell")
	if lash != null:
		check(not lash.active, "chain lash0.8safe tell")
		check(not lash.blockable, "chain lash bypasses ward")
		check_near(lash.position.x, 576, 0.01, "lash starts at actual first post")
		var shape := lash.get_child(0) as CollisionShape2D
		check_eq((shape.shape as RectangleShape2D).size, Vector2(96, 768), "lash damage bounds")
		var look = lash.get_node("Visual")
		check(look.picture.texture != null, "lash uses the cut painted chain")
		check(look.picture.visible, "painted chain is visible during warning")
		check_eq(look.picture.modulate, Color(0.75, 0.84, 1.0, 0.25), "warning is faint and cool")
	await seconds(0.8)
	if is_instance_valid(lash):
		check(lash.active, "chain lash activates aftertell")
		check(lash.get_node("Visual").picture.visible, "chain appears during active lash")
		check_eq(lash.get_node("Visual").picture.modulate, Color.WHITE, "active lash keeps original art")
	GameState.acquire_item(&"reel_line")
	GameState.set_active_item(&"reel_line")
	player.place_at(Vector2(960, 720))
	player.facing = Vector2.UP
	check(player.use_item(), "actual reel for pulse probe")
	await seconds(3.5)
	var pulse: Hitbox
	for hazard in boss._hazards:
		if is_instance_valid(hazard) and hazard is Hitbox and hazard.kind == &"unlit_ring":
			pulse = hazard
	check(pulse != null, "exposed heart emits3secondpulse")
	if pulse != null:
		check_near(pulse.reach, 400, 0.01, "pulse400reach")
		check_near(pulse.width, 48.0, 0.01, "heart pulse keeps 48 pixel width")
		check_eq(pulse.damage, 3, "heart pulse keeps three damage")
		check(pulse.blockable, "heart pulse remains wardable")
		var look = pulse.get_node("Visual")
		check(look.get_script() == boss.HeartPulseVisual, "pulse uses painted presentation")
		var texture = look.art.effect.get_shader_parameter("wax") as Texture2D
		check(texture != null, "pulse texture loads")
		if texture != null:
			check_eq(
				texture.resource_path,
				"res://assets/sprites/unlit_heart_pulse_z1_idle.png",
				"pulse uses its own art"
			)
		check_near(pulse.speed, 400 / 0.6, 0.01, "pulse expands in0.6seconds")
	boss.reset_fight()
	await frames(3)
	check(boss._hazards.is_empty(), "reset forgets all phases hazards")
	await dispose(room)


func _room_clone_lifecycle() -> void:
	for grid in [Vector2i.ZERO, Vector2i(3, 4)]:
		reset_state()
		var packed := load(GALLERY) as PackedScene
		check(packed != null, "clone gallery loads")
		var room := packed.instantiate() as Room
		room.grid = grid
		if captures:
			capture_viewport.add_child(room)
		else:
			add_child(room)
		var origin := Vector2(grid) * WorldConst.ROOM_SIZE
		var death_listeners := Events.player_died.get_connections().size()
		for visit in range(3):
			room.enter()
			await frames(3)
			var boss = room.get_node("Enemies/TheUnlit")
			var hearts := 0
			var lamps := 0
			for child in boss.get_children():
				if child.get_script() == boss.HeartGlow:
					hearts += 1
					check_eq(
						child.global_position,
						origin + Vector2(960, 288),
						"canonical heart position"
					)
					check_eq(child.name, &"HeartGlow", "canonical heart name")
				if child.has_signal(&"reeled"):
					lamps += 1
			check_eq(hearts, 1, "clone has exactly one canonical heart")
			check_eq(lamps, 1, "clone has exactly one canonical lantern")
			var targets := 0
			var active_targets := 0
			var reel_hurtboxes := 0
			for target in get_tree().get_nodes_in_group(&"reelable"):
				if room.is_ancestor_of(target):
					targets += 1
					check_eq(
						target.global_position,
						origin + Vector2(960, 288),
						"translated canonical target position"
					)
					check_eq(
						target.reeled.get_connections().size(), 1, "one canonical reel listener"
					)
			for hurt in get_tree().get_nodes_in_group(&"hurtboxes"):
				if room.is_ancestor_of(hurt) and hurt.get_parent().is_in_group(&"reelable"):
					active_targets += int(hurt.enabled)
					reel_hurtboxes += 1
					check_eq(
						hurt.global_position,
						origin + Vector2(960, 288),
						"canonical reel hurtbox position"
					)
			check_eq(targets, 1, "one public reel target per visit")
			check_eq(reel_hurtboxes, 1, "one actual reel hurtbox per visit")
			check_eq(active_targets, 0, "P1 has no enabled reel hurtbox")
			# The true reel tip must never hit a ghost at the template origin.
			var tip_scene := load("res://scenes/items/reel_tip.tscn") as PackedScene
			check(tip_scene != null, "actual reel tip loads for target probe")
			var tip = tip_scene.instantiate()
			room.add_child(tip)
			var probe_origin := Node2D.new()
			room.add_child(probe_origin)
			probe_origin.global_position = Vector2(960, 400)
			tip.launch(probe_origin, Vector2.UP)
			var landed: Array[Hurtbox] = []
			tip.hit_landed.connect(func(hurt: Hurtbox): landed.append(hurt))
			await seconds(0.3)
			check(landed.is_empty(), "real tip cannot hit stale enabled origin target")
			await dispose(tip)
			await dispose(probe_origin)
			if captures and visit == 0:
				var camera := Camera2D.new()
				capture_viewport.add_child(camera)
				camera.position = origin + Vector2(960, 540)
				await _capture(
					"clone-p1-clean" if grid == Vector2i.ZERO else "clone-translated-clean"
				)
				await dispose(camera)
			room.leave()
			await frames(3)
			var remaining := 0
			for target in get_tree().get_nodes_in_group(&"reelable"):
				remaining += int(room.is_ancestor_of(target))
			check_eq(remaining, 0, "leave removes all public reel targets")
			check_eq(
				Events.player_died.get_connections().size(),
				death_listeners,
				"leave restores death listeners"
			)

		# Retired clones still traverse the real Room template path.
		GameState.set_flag(&"boss_cave_10_14_defeated")
		for visit in range(3):
			room.enter()
			await frames(3)
			var retired = room.get_node("Enemies/TheUnlit")
			check(retired.is_dead and not retired.visible, "cloned actor retires on saved flag")
			var retired_helpers := 0
			for child in retired.get_children():
				retired_helpers += int(
					child.get_script() == retired.HeartGlow or child.has_signal(&"reeled")
				)
			check_eq(retired_helpers, 0, "retired clone contains no generated helpers")
			if captures and grid == Vector2i.ZERO and visit == 0:
				await _capture("clone-retired-clean")
			for target in get_tree().get_nodes_in_group(&"reelable"):
				check(
					not room.is_ancestor_of(target), "retired clone exposes no public reel target"
				)
			room.leave()
			await frames(3)
			check_eq(
				Events.player_died.get_connections().size(),
				death_listeners,
				"retired leave restores death listeners"
			)
		await dispose(room)
