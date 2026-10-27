extends TestCase
## B04: bounded physics checks; real mitts and falling shards, no full cave route or human balance claim.

const BOSS := "res://scenes/enemies/bosses/hushed_colossus.tscn"
const GALLERY := "res://tests/fixtures/gallery/B04.tscn"
var boss: Variant
var player: Player
var arena: Node2D


func run() -> void:
	await _arena_presentation_light()
	await _sweep_sides()
	await _sweep_warning_light()
	await _quake_presentation()
	await _armour_and_intro()
	await _attack_physics()
	await _damage_and_expiration()
	await _actual_mitts_in_every_phase()
	await _reset_and_retirement()
	await _gallery()


func _quake_presentation() -> void:
	await _setup()
	boss.set_physics_process(false)
	player.hurtbox.enabled = false
	for parity in [0, 1]:
		var quake = boss.start_attack(&"quake", boss.arena_point(Vector2.ZERO), 1.2, 0.2)
		quake.parity = parity
		await frames(2)
		check(quake.get_node("Visual").quake_texture != null, "painted quake art loads")
		check(not quake.fired, "quake art starts in warning state")
		await frames(72)
		check(quake.fired, "quake switches to active state")
		check_eq(quake.box.get_child_count(), 72, "quake retains 72 dangerous tiles")
		for shape in quake.box.get_children():
			var cell: Vector2 = (shape.position - Vector2(48, 48)) / 96.0
			check_eq((int(cell.x) + int(cell.y)) % 2, parity, "hitbox matches marked parity")
			check_eq(shape.shape.size, Vector2(96, 96), "marked tile retains full hitbox")
		await dispose(quake)
	await dispose(arena)


func _arena_presentation_light() -> void:
	await _setup()
	var light := boss.get_node_or_null("ArenaPresentationLight") as PointLight2D
	check(light != null, "live boss illuminates the arena")
	if light != null:
		check(not light.is_in_group(&"glow_light"), "arena light does not affect gameplay")
		check_eq(light.texture.get_width(), 1920, "light covers the room width")
		check_eq(light.texture.get_height(), 960, "light covers the room height")
		var centre := light.global_position
		boss.position += Vector2(300, -200)
		check_eq(light.global_position, centre, "arena light stays fixed as the boss moves")
	boss.reset_fight()
	await frames(2)
	check(not is_instance_valid(light), "reset removes the old arena light")
	await frames(95)
	light = boss.get_node_or_null("ArenaPresentationLight") as PointLight2D
	check(light != null, "new fight restores arena light")
	boss.set_physics_process(false)
	Events.room_entered.emit(&"cave_4_9")
	await frames(1)
	check(not is_instance_valid(light), "room change removes light even if room remains loaded")
	Events.room_entered.emit(&"cave_4_10")
	await frames(1)
	light = boss.get_node_or_null("ArenaPresentationLight") as PointLight2D
	check(light != null, "returning to the arena restores light")
	await dispose(arena)
	check(not is_instance_valid(light), "leaving the room removes the arena light")


func _sweep_warning_light() -> void:
	await _setup()
	for size in [Vector2(1728, 96), Vector2(96, 768)]:
		var attack = boss.start_attack(&"sweep", Vector2(960, 480), 0.8, 0.5)
		attack.band_size = size
		attack.sweep_from = Vector2(960, 480)
		attack.sweep_to = Vector2(960, 600)
		await frames(3)
		var light := attack.get_node_or_null("Visual/SweepWarningLight") as PointLight2D
		check(light != null, "each sweep orientation has a warning light")
		if light != null:
			check(light.visible, "warning light is on before impact")
			check(not light.is_in_group(&"glow_light"), "presentation light does not reveal gameplay")
			check_eq(light.texture.get_width(), int(size.x), "light matches warning width")
			check_eq(light.texture.get_height(), int(size.y), "light matches warning height")
		check_eq(attack.warning, 0.8, "warning duration remains 0.8 s")
		check_eq(attack.active_time, 0.5, "sweep duration remains 0.5 s")
		await frames(48)
		check(attack.fired, "sweep fires at the existing warning duration")
		if light != null:
			check(not light.visible, "presentation light turns off after the warning")
		check_eq(attack.box.damage, 3, "sweep damage remains three")
		var collision := attack.box.get_child(0) as CollisionShape2D
		check_eq((collision.shape as RectangleShape2D).size, size, "sweep hitbox is unchanged")
		await dispose(attack)
	await dispose(arena)


func _sweep_sides() -> void:
	await _setup()
	for example in [
		[true, Vector2(960, 300), Vector2(960, 144), Vector2(960, 816)],
		[true, Vector2(960, 640), Vector2(960, 816), Vector2(960, 144)],
		[false, Vector2(400, 480), Vector2(144, 480), Vector2(1776, 480)],
		[false, Vector2(1400, 480), Vector2(1776, 480), Vector2(144, 480)],
	]:
		var points: Array = boss._sweep_points(example[0], example[1])
		check_eq(points[0], example[2], "sweep warning starts on the boss side")
		check_eq(points[1], example[3], "sweep travels to the opposite side")
	await dispose(arena)


func _setup() -> void:
	reset_state()
	arena = make_arena()
	player = make_player(arena, Vector2(400, 400))
	boss = (load(BOSS) as PackedScene).instantiate()
	boss.position = Vector2(960, 640)
	arena.add_child(boss)
	await frames(3)


func _hit(kind: StringName, amount: int = 99) -> void:
	var hit := make_hitbox(arena, boss.global_position, Layers.Team.PLAYER, amount, 100)
	hit.kind = kind
	await frames(4)
	await dispose(hit)
	await frames(20)


func _armour_and_intro() -> void:
	await _setup()
	check_eq(boss.max_hp, 48, "48 HP")
	check_eq(boss.body_radius, 90.0, "90 px body")
	check(boss.is_in_intro(), "intro starts with attacks off")
	await _hit(&"thrown")
	check_eq(boss.hp, 48, "intro prevents shard damage")
	await frames(80)
	check(not boss.is_in_intro(), "1.5 s intro ends")
	boss.move_speed = 0
	for kind in [&"hook", &"flare", &"sling", &"fire", &"reel", &"stun"]:
		await _hit(kind)
		check_eq(boss.hp, 48, "armour blocks " + String(kind))
	await _hit(&"explosion")
	check_eq(boss.hp, 46, "explosion damage is fixed at two")
	check(not boss.is_arena_locked(), "no retreat lock added")
	await dispose(arena)


func _attack_physics() -> void:
	await _setup()
	await frames(95)
	boss.move_speed = 0
	# Observe the natural phase-one cadence without changing attack clocks.
	player.hurtbox.enabled = false
	await frames(370)
	check_eq(boss.floor_shards(), 2, "two warned shards land after five seconds plus warning")
	var floor_shard: Variant = boss.shards[0]
	check_eq(floor_shard.radius, 36.0, "shard radius is 36")
	check(floor_shard.is_in_group(&"liftable"), "fallen shard has real liftable grab interface")
	boss.shard_rain()
	await frames(70)
	check_eq(boss.floor_shards(), 4, "rain caps floor shards at four")
	boss.shard_rain()
	await frames(70)
	check_eq(boss.floor_shards(), 4, "further rain cannot exceed floor cap")
	# A warning follows the player only for the first 0.3 seconds.
	var slam: Variant = boss.start_attack(&"slam", player.global_position, 0.8, 0.1)
	await frames(10)
	player.place_at(Vector2(600, 300))
	await frames(4)
	check_near(slam.global_position.distance_to(player.global_position), 0, 1, "slam follows early")
	await frames(10)
	var locked: Vector2 = slam.global_position
	player.place_at(Vector2(350, 200))
	await frames(8)
	check_eq(slam.global_position, locked, "slam locks at 0.3 s")
	check(not slam.fired, "warning does no damage before 0.8 s")
	await frames(18)
	var ring: Variant = null
	for hazard in boss._hazards:
		if is_instance_valid(hazard) and hazard.get("kind") != null and hazard.kind == &"ring":
			ring = hazard
	check(ring != null, "slam impact creates expanding ring")
	if ring != null:
		await frames(3)
		check(ring.box != null and not ring.box.blockable, "shockwave cannot be warded")
		check_eq(ring.box.damage, 2, "shockwave damage two")
		check(ring.ring_radius() > 0 and ring.ring_radius() < 260, "ring expands over 0.4 s")
		check_eq(ring.ring_shapes.size(), 40, "annulus has no damaging filled centre")
	# Drive thresholds through actual hitboxes, then inspect naturally scheduled phase attacks.
	for i in range(3):
		await _hit(&"thrown", 3)
	check_eq(boss.phase, 2, "32 HP threshold starts phase two")
	check(boss.is_pausing(), "phase change pauses for 1.2 seconds")
	check_eq(boss.floor_shards(), 0, "phase change clears existing floor shards")
	await frames(80)
	boss.move_speed = 0
	await frames(300)
	var sweep: Variant = null
	for hazard in boss._hazards:
		if is_instance_valid(hazard) and hazard.get("kind") != null and hazard.kind == &"sweep":
			sweep = hazard
	check(sweep != null, "phase two naturally schedules arm sweep")
	if sweep != null:
		var expected: Array = boss._sweep_points(
			sweep.band_size.x > sweep.band_size.y, boss.position
		)
		check_eq(sweep.global_position, boss.arena_point(expected[0]), "warning starts on boss side")
		check_eq(sweep.sweep_to, boss.arena_point(expected[1]), "sweep ends across the arena")
		await frames(maxi(1, int(ceil((sweep.warning - sweep.age) * FPS)) + 2))
		check(is_instance_valid(sweep), "sweep survives through its active window")
		if is_instance_valid(sweep):
			check(sweep.fired, "sweep activates after 0.8 s")
			check_eq(sweep.box.damage, 3, "sweep damage three")
			check(not sweep.box.blockable, "sweep unwardable")
			var before: Vector2 = sweep.global_position
			await frames(5)
			if is_instance_valid(sweep):
				check(
					sweep.global_position.distance_to(before) > 50,
					"active band sweeps across floor"
				)
	for i in range(3):
		await _hit(&"thrown", 3)
	check_eq(boss.phase, 3, "16 HP threshold starts phase three")
	await frames(80)
	boss.move_speed = 0
	await frames(480)
	var quake: Variant = null
	for hazard in boss._hazards:
		if is_instance_valid(hazard) and hazard.get("kind") != null and hazard.kind == &"quake":
			quake = hazard
	check(quake != null, "phase three schedules quake every eight seconds")
	if quake != null:
		check(not quake.fired, "quake has 1.2 s warning")
		await frames(maxi(1, int(ceil((quake.warning - quake.age) * FPS)) + 2))
		check(is_instance_valid(quake), "quake survives through active damage frame")
		if is_instance_valid(quake):
			check_eq(quake.box.get_child_count(), 72, "half of 144 interior tiles erupt")
			check_eq(quake.box.damage, 3, "quake damage three")
	await dispose(arena)


func _damage_and_expiration() -> void:
	await _setup()
	await frames(95)
	boss.set_physics_process(false)
	player.place_at(Vector2(400, 400))
	var initial := GameState.health
	var fall: Variant = boss.start_attack(&"fall", player.global_position, 1.0, 0.1)
	await frames(50)
	check_eq(GameState.health, initial, "fall warning deals no premature damage")
	await frames(14)
	check_eq(GameState.health, initial - 2, "fall impact damages player by two")
	check(not fall.box.blockable, "fall is not wardable")
	var shard: Variant = boss.shards[0]
	player.place_at(Vector2(300, 250))
	await frames(724)
	check(not is_instance_valid(shard), "floor shard crumbles after twelve seconds")
	GameState.heal(99)
	initial = GameState.health
	boss.start_attack(&"slam", player.global_position, 0.8, 0.1)
	await frames(45)
	check_eq(GameState.health, initial, "slam warning deals no damage")
	await frames(7)
	check_eq(GameState.health, initial - 3, "slam impact damages player by three")
	await frames(105)
	GameState.heal(99)
	player.place_at(Vector2(336, 336))
	initial = GameState.health
	var quake: Variant = boss.start_attack(&"quake", boss.arena_point(Vector2.ZERO), 1.2, 0.2)
	quake.parity = 0
	await frames(70)
	check_eq(GameState.health, initial, "quake warning lasts 1.2 seconds")
	await frames(7)
	check_eq(GameState.health, initial - 3, "glowing checker tile deals three")
	await frames(105)
	GameState.heal(99)
	player.place_at(Vector2(432, 336))
	initial = GameState.health
	quake = boss.start_attack(&"quake", boss.arena_point(Vector2.ZERO), 1.2, 0.2)
	quake.parity = 0
	await frames(80)
	check_eq(GameState.health, initial, "complementary checker tile stays safe")
	await dispose(arena)


func _actual_mitts_in_every_phase() -> void:
	await _setup()
	GameState.acquire_item(&"heft_mitts")
	GameState.set_active_item(&"heft_mitts")
	player.hurtbox.enabled = false
	await frames(95)
	# Stationary boss isolates throw geometry; attack timing is checked separately above.
	for hit_index in range(8):
		boss.move_speed = 0
		boss.slam_left = 100
		boss.shard_left = 100
		boss.sweep_left = 100
		boss.quake_left = 100
		var fall: Variant = boss.start_attack(
			&"fall", boss.global_position + Vector2(-300, 0), 1.0, 0.1
		)
		await frames(65)
		check(not is_instance_valid(fall) or fall.fired, "real falling marker completes")
		var shard: Variant = boss.shards.back()
		player.place_at(shard.global_position - Vector2(72, 0))
		player.facing = Vector2.RIGHT
		await frames(3)
		check(player.use_item(), "real mitts activate in phase " + str(boss.phase))
		await frames(22)
		check(shard.is_carried(), "real grab lifts landed shard")
		check(player.actions_locked(), "carrying disables hook and ward")
		check(not player.ward_up, "ward stays down while carrying")
		var before: int = boss.hp
		Input.action_press(&"use_item")
		await frames(2)
		Input.action_release(&"use_item")
		await frames(55)
		if hit_index < 7:
			check_eq(boss.hp, before - 6, "actual airborne shard deals six")
		else:
			check(boss.is_dying(), "eighth thrown shard starts death")
			check(not boss.contact_hitbox.active, "death throes disable contact damage")
			boss.reset_fight()
			check(boss.is_dying(), "reset during death cannot resurrect defeated boss")
		await frames(80)
	check(GameState.has_flag(&"boss_cave_4_10_defeated"), "canonical defeat persists")
	check(not GameState.has_flag(&"frag_c4"), "boss does not award room-owned fragment")
	check(not GameState.has_flag(&"picked_wick_core_c4"), "boss does not embed persistent core")
	for node in arena.get_children():
		if node is PickupBase:
			check_eq(node.kind, &"ember", "death produces only timed embers")
	await dispose(arena)


func _reset_and_retirement() -> void:
	await _setup()
	await frames(95)
	boss.move_speed = 0
	for i in range(3):
		await _hit(&"thrown", 3)
	await frames(80)
	boss.land_shard(Vector2(700, 400))
	boss.start_attack(&"slam", Vector2(500, 300), 0.8, 0.1)
	boss.reset_fight()
	await frames(3)
	check_eq(boss.hp, 48, "reset restores full health")
	check_eq(boss.phase, 1, "reset restores wake one")
	check_eq(boss.position, Vector2(960, 640), "reset restores seated start")
	check(boss.is_in_intro(), "reset repeats intro")
	check_eq(boss.floor_shards(), 0, "reset clears ammunition")
	check_eq(boss.combo_count, 0, "reset cancels pending combo")
	await dispose(arena)
	GameState.set_flag(&"boss_cave_4_10_defeated")
	arena = make_arena()
	boss = (load(BOSS) as PackedScene).instantiate()
	boss.position = Vector2(960, 640)
	arena.add_child(boss)
	await frames(100)
	check(boss.is_dead and not boss.visible, "defeated boss stays retired on reload")
	check_eq(boss.floor_shards(), 0, "retired boss spawns no hazards")
	await dispose(arena)


func _gallery() -> void:
	reset_state()
	var scene := load(GALLERY) as PackedScene
	check(scene != null, "gallery scene loads")
	if scene == null:
		return
	var fixture := scene.instantiate()
	add_child(fixture)
	fixture.enter()
	await frames(3)
	check(fixture.get_node("Enemies/HushedColossus/Visual") != null, "boss has Visual")
	check(
		fixture.get_node("Props/Arena").get_child_count() == 1,
		"arena contains no reward or barrier"
	)
	await dispose(fixture)
