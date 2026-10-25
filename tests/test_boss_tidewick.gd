extends TestCase
## Independent mechanics first; genuine raft combat is added with the public T03/F7 API.

const SCENE := "res://scenes/enemies/bosses/tidewick.tscn"
const GALLERY := "res://tests/fixtures/gallery/B03.tscn"


func run() -> void:
	await _motion_and_exposure()
	await _phases_reset_and_rewards()


func _fixture() -> Room:
	var packed := load(GALLERY) as PackedScene
	check(packed != null, "basin gallery loads")
	var room := packed.instantiate() as Room
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
	var before: Vector2 = boss.global_position
	await frames(1)
	check_near(boss.global_position.distance_to(before), 200.0 / 60.0, 0.1, "constant arc speed200")
	for segment in boss.followers:
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
	await seconds(0.9)
	check(boss.tail_exposed(), "tail resurfaces on5second cycle")
	var hp: int = boss.hp
	var hit := make_hitbox(room, boss.global_position, Layers.Team.PLAYER, 4, 65)
	hit.kind = &"flare"
	await frames(4)
	check_eq(boss.hp, hp, "head immune to actual flare hitbox")
	await dispose(hit)
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


func _capture(label: String) -> void:
	if OS.get_environment("WICK_B03_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		get_viewport().get_texture().get_image().save_png("/tmp/b03-" + label + ".png"),
		OK,
		"capture actual phase state"
	)
