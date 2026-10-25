## timeout=180
extends TestCase
## Controlled positioning and disabled player hurtbox isolate tool provenance.
## These probes do not claim a human balance/feel playthrough.
const SCENE := "res://scenes/enemies/bosses/the_unlit.tscn"
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
	await _orbit_and_reset()
	await _full_physical_fight()
	await _hazards_and_ward()
	await _scheduled_attacks()


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
	await seconds(0.7)
	check_eq(GameState.health, health, "real ward destroys gaze bolt")
	boss.clear_hazards()
	await frames(3)
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
	await seconds(0.55)
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
	await seconds(0.8)
	if is_instance_valid(lash):
		check(lash.active, "chain lash activates aftertell")
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
		check_near(pulse.speed, 400 / 0.6, 0.01, "pulse expands in0.6seconds")
	boss.reset_fight()
	await frames(3)
	check(boss._hazards.is_empty(), "reset forgets all phases hazards")
	await dispose(room)
