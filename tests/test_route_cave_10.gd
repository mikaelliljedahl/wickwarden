## timeout=360
extends "res://tests/test_route_cave_5.gd"
## Positioned integration, ordinary mobs removed except actual ward watchers; hurtbox suppressed.
## Prior tools use actual pedestal contacts; prior fragments use labelled physical pickup fixtures.
## This does not claim C1-C9 combat or a continuous human run. C10 has no new tool by binding plan.
## Main path never injects gate/defeat flags, phase, HP, attack timers or synthetic player hitboxes.

var route_captures: Dictionary = {}
var earned_final: Dictionary = {}


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	await acquire_kit()
	for source in [
		[&"cave_1_5", &"cinder_wick"],
		[&"cave_2_5", &"tallow_sling"],
		[&"cave_3_5", &"reed_raft"],
		[&"cave_4_5", &"heft_mitts"],
		[&"cave_5_5", &"glow_jar"],
		[&"cave_6_5", &"lantern_chime"],
		[&"cave_7_5", &"skitter_boots"],
		[&"cave_8_5", &"reel_line"]
	]:
		await collect(await enter(source[0]), source[1])
		check(GameState.has_item(source[1]), "labelled prior-cave actual pedestal " + source[1])
	await ninth_mouth()
	await garden_and_echo()
	await choir_and_chime()
	await span_and_ward()
	await vault_and_eye()
	await final_fight()
	await c10_persistence()
	await ending_branch(&"rekindle")
	# Independent second-choice fixture restores the genuinely earned pre-choice disk snapshot.
	# No fake defeat is set: the previous real sling/flame/reel/hook victory remains its source.
	await dispose(world)
	GameState.reset()
	SaveGame.enabled = true
	check(SaveGame.load_into_state(), "independent second-branch fixture reloads earned victory")
	SaveGame.enabled = false
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	await ending_branch(&"wickwarden")
	await dispose(world)
	get_tree().current_scene = get_parent()
	SaveGame.enabled = false


func enter(id: StringName) -> Room:
	if world.get_current_room_id() != id:
		world.start_at(id)
	var room := world.get_room(id)
	for enemy in room.get_enemies():
		if (
			enemy.scene_file_path.contains("/minibosses/")
			or enemy.scene_file_path.contains("/bosses/")
		):
			continue
		if id == &"cave_10_10" and enemy.get_script().resource_path.ends_with("watcher_eye.gd"):
			continue
		enemy.drops_enabled = false
		enemy.kill()
	await frames(4)
	return room


func ninth_mouth() -> void:
	var room := await enter(&"ow_10_8")
	var gate = scripted(room, "ninth_door.gd")
	var door := door_to(room, &"cave_10_1")
	player.place_at(door.global_position)
	await frames(5)
	check_eq(world.get_current_room_id(), &"ow_10_8", "zero fragments cannot enter Ninth Hollow")
	# Labelled physical prior-fragment fixture: actual PickupBase contact, no prior-boss claim.
	var packed := load("res://scenes/pickups/fragment.tscn") as PackedScene
	check(packed != null, "prior-fragment fixture uses real fragment scene")
	if packed == null:
		return
	for number in range(1, 10):
		var fragment := packed.instantiate() as PickupBase
		fragment.scope = StringName("c%d" % number)
		fragment.persistent_id = StringName("c10_fixture_prior_fragment_%d" % number)
		room.add_child(fragment)
		fragment.global_position = room.global_position + Vector2(960, 700)
		player.place_at(fragment.global_position + Vector2(0, 44))
		await frames(5)
		check(
			GameState.has_fragment(StringName("c%d" % number)),
			"physical labelled prior-fragment fixture"
		)
		if number == 8:
			player.place_at(gate.global_position + Vector2(0, 70))
			await frames(5)
			check(not gate.is_open, "eight actual fixture fragments cannot open Ninth Door")
	player.place_at(gate.global_position + Vector2(0, 70))
	await frames(5)
	check(gate.is_open, "ninth actual fixture fragment permits contact opening")
	check(GameState.has_flag(&"door_ninth"), "canonical Ninth Door flag earned by contact")
	player.place_at(door.global_position + Vector2(0, 160))
	await frames(3)
	player.place_at(door.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_10_1", "actual Ninth Door enters C10")
	check(GameState.has_flag(&"mouth_c10"), "actual C10 mouth checkpoint")
	await edge(&"cave_10_1", &"cave_10_2", Vector2.RIGHT)


func fire_at(at: Vector2, direction: Vector2) -> void:
	player.place_at(at - direction * 180)
	player.facing = direction
	GameState.set_active_item(&"cinder_wick")
	await frames(3)
	check(player.use_item(), "actual acquired cinder casts physical flame")
	await seconds(4)


func garden_and_echo() -> void:
	var room := await enter(&"cave_10_2")
	await blocked(
		Vector2(1650, 480), &"move_right", scripted(room, "locked_door.gd"), "wrong-scope c10 lock"
	)
	check_eq(GameState.keys_in(&"c1"), 1, "actual c1 key cannot open c10")
	var thorn = scripted(room, "burnable.gd")
	await swing_from(thorn.global_position, Vector2.UP)
	check(not GameState.has_flag(&"burned_e234"), "hook cannot burn thorn wall")
	await fire_at(thorn.global_position, Vector2.UP)
	check(GameState.has_flag(&"burned_e234"), "physical cinder opens garden")
	await edge(&"cave_10_2", &"cave_10_3", Vector2.UP)
	room = world.get_room(&"cave_10_3")
	await collect(room, &"key_c10_1")
	check_eq(GameState.keys_in(&"c10"), 1, "first actual C10 key")
	await edge(&"cave_10_3", &"cave_10_2", Vector2.DOWN)
	room = world.get_room(&"cave_10_2")
	await contact(scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check(
		scripted(world.get_room(&"cave_10_4"), "locked_door.gd").is_open,
		"first lock peer synchronized"
	)
	check_eq(GameState.keys_in(&"c10"), 0, "first key spent once")
	await edge(&"cave_10_2", &"cave_10_4", Vector2.RIGHT)
	room = world.get_room(&"cave_10_4")
	var echo = scripted_enemy(room, "corrows_echo.gd")
	check(echo != null, "actual room-owned Echo")
	if echo == null:
		return
	await hook_enemy(echo)
	check(echo.hp < 36, "actual player hook damages Echo")
	await edge(&"cave_10_4", &"cave_10_2", Vector2.LEFT)
	await edge(&"cave_10_2", &"cave_10_4", Vector2.RIGHT)
	room = world.get_room(&"cave_10_4")
	echo = scripted_enemy(room, "corrows_echo.gd")
	check_eq(echo.hp, 36, "unfinished Echo resets on actual reentry")
	var stunned := false
	for tick in range(900):
		player.place_at(echo.global_position + Vector2(0, 110))
		if echo.state == echo.State.GLOW:
			GameState.set_active_item(&"lantern_chime")
			check(player.use_item(), "actual prerequisite chime during natural Echo glow")
			await frames(16)
			stunned = echo.is_stunned()
			break
		await frames(1)
	check(stunned, "natural Echo glow interrupted by real chime wave")
	await capture_state("echo-chime")
	for attempt in range(70):
		if not is_instance_valid(echo) or echo.is_dying():
			break
		await hook_enemy(echo)
	check(GameState.has_flag(&"mini_cave_10_4"), "actual hook finish earns Echo defeat")
	await seconds(1.7)
	await edge(&"cave_10_4", &"cave_10_2", Vector2.LEFT)
	await edge(&"cave_10_2", &"cave_10_4", Vector2.RIGHT)
	room = world.get_room(&"cave_10_4")
	check_eq(room.get_enemies().size(), 0, "earned Echo defeat retires real room actor")
	await ride(room, &"cave_10_5", &"e236")


func choir_and_chime() -> void:
	var room := await enter(&"cave_10_5")
	var seam = scripted(room, "hidden_seam.gd")
	await swing_from(seam.global_position, Vector2.UP)
	check(not seam.is_shown, "hook cannot reveal jar-only seam")
	await throw_jar(room.global_position + Vector2(960, 432), Vector2.UP)
	await seconds(1.8)
	check(GameState.has_flag(&"revealed_e237"), "actual jar permanently reveals northern seam")
	await edge(&"cave_10_5", &"cave_10_6", Vector2.UP)
	room = world.get_room(&"cave_10_6")
	var stone = scripted(room, "resonance_stone.gd")
	await swing_from(stone.global_position, Vector2.RIGHT)
	check(not stone.is_awake, "hook cannot replace actual chime")
	player.place_at(stone.global_position + Vector2(-160, 0))
	GameState.set_active_item(&"lantern_chime")
	check(player.use_item(), "actual chime at final resonance gate")
	await seconds(1.2)
	check(GameState.has_flag(&"resonated_e238"), "actual chime opens Chime Landing")
	await edge(&"cave_10_6", &"cave_10_7", Vector2.RIGHT)
	room = world.get_room(&"cave_10_7")
	await collect(room, &"key_c10_2")
	check_eq(GameState.keys_in(&"c10"), 1, "second actual C10 key")
	await edge(&"cave_10_7", &"cave_10_6", Vector2.LEFT)
	await edge(&"cave_10_6", &"cave_10_5", Vector2.DOWN)
	room = world.get_room(&"cave_10_5")
	stone = scripted(room, "heavy_stone.gd")
	await swing_from(stone.global_position, Vector2.DOWN)
	check(not GameState.has_flag(&"moved_e239"), "hook cannot replace mitts")
	player.place_at(stone.global_position + Vector2(0, -100))
	player.facing = Vector2.DOWN
	GameState.set_active_item(&"heft_mitts")
	check(player.use_item(), "actual mitts grab final heavy stone")
	await seconds(.5)
	check(stone.is_carried(), "actual stone lifted")
	player.facing = Vector2.RIGHT
	Input.action_press(&"use_item")
	await frames(3)
	Input.action_release(&"use_item")
	await seconds(1.3)
	check(GameState.has_flag(&"moved_e239"), "actual throw opens paired heavy span")
	await edge(&"cave_10_5", &"cave_10_8", Vector2.DOWN)


func span_and_ward() -> void:
	await leap_edge(
		&"cave_10_8", &"cave_10_9", Vector2.RIGHT, Vector2(1584, 480), Vector2(1776, 480)
	)
	var room := world.get_room(&"cave_10_9")
	await anchor_pull(room, Vector2(1008, 384), Vector2.DOWN, Vector2(1008, 888))
	await edge(&"cave_10_9", &"cave_10_10", Vector2.DOWN)
	room = world.get_room(&"cave_10_10")
	await anchor_pull(room, Vector2(1008, 192), Vector2.DOWN, Vector2(1008, 720))
	var pad: Node2D
	for node in room.get_node("Props").get_children():
		if (
			node.get_script() != null
			and node.get_script().resource_path.ends_with("ward_plate.gd")
			and not node.blocker
		):
			pad = node
	check(pad != null, "actual optional C10 ward pad")
	if pad == null:
		return
	check(not pad.test_spore_post, "ward uses authored watchers without test shooter")
	player.place_at(pad.global_position)
	player.facing = Vector2.RIGHT
	player.set_hurtbox_enabled(self, true)
	Input.action_press(&"ward")
	await frames(4)
	var health := GameState.health
	for tick in range(1200):
		if pad.is_satisfied:
			break
		await frames(1)
	release_inputs()
	check(pad.is_satisfied, "real held ward blocks three natural watcher beams")
	check_eq(GameState.health, health, "ward protects actual cache approach")
	player.set_hurtbox_enabled(self, false)
	await capture_state("ward-earned")
	var door := door_to(room, &"cave_10_10#ward")
	player.place_at(door.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_10_10#ward", "actual optional ward cache entered")
	room = await enter(&"cave_10_10#ward")
	await collect(room, &"cache_cave_10_10_ward_brass")
	check(
		GameState.has_flag(&"picked_cache_cave_10_10_ward_brass"),
		"real optional cache reward collected"
	)
	player.place_at(door_to(room, &"cave_10_10").global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_10_10", "actual ward pocket return")


func anchor_pull(room: Room, at: Vector2, direction: Vector2, target: Vector2) -> void:
	player.place_at(room.global_position + at)
	player.facing = direction
	GameState.set_active_item(&"reel_line")
	await frames(3)
	check(player.use_item(), "actual reel across final pit")
	await seconds(.5)
	check(player.is_airborne(), "real anchor pull airborne")
	await seconds(.8)
	check(
		player.global_position.distance_to(room.global_position + target) < 90,
		"actual reel lands on opposite bank"
	)


func leap_edge(
	from: StringName, to: StringName, direction: Vector2, at: Vector2, end: Vector2
) -> void:
	var room := await enter(from)
	player.place_at(room.global_position + at)
	player.facing = direction
	GameState.set_active_item(&"skitter_boots")
	await frames(3)
	check(player.use_item(), "actual boots leap final trench")
	await seconds(.5)
	check(
		player.global_position.distance_to(room.global_position + end) < 40,
		"actual leap reaches safe bank"
	)
	await cross(action_for(direction), to)


func vault_and_eye() -> void:
	await spend_lock(&"cave_10_10", &"cave_10_11", &"e242")
	var room := world.get_room(&"cave_10_11")
	await collect(room, &"key_c10_3")
	check_eq(GameState.keys_in(&"c10"), 1, "third actual C10 key")
	await spend_lock(&"cave_10_11", &"cave_10_12", &"e243")
	room = world.get_room(&"cave_10_12")
	await blocked(
		Vector2(240, 480),
		&"move_left",
		scripted(room, "boss_door.gd"),
		"final boss door before Lockpick"
	)
	await collect(room, &"slug_bundle_cave_10_12")
	var eye: Node2D
	for node in room.get_node("Props").get_children():
		if (
			node.get_script() != null
			and node.get_script().resource_path.ends_with("eye_switch.gd")
			and not node.blocker
		):
			eye = node
	await swing_from(eye.global_position, Vector2.UP)
	check(not eye.is_on, "actual hook rejected by final eye switch")
	player.place_at(eye.global_position + Vector2(0, 160))
	player.facing = Vector2.UP
	GameState.set_active_item(&"tallow_sling")
	var ammo := GameState.slugs
	check(player.use_item(), "actual final eye slug")
	await seconds(.6)
	check(eye.is_on, "actual sling opens final Lockpick room")
	check_eq(GameState.slugs, ammo - 1, "real slug spent at eye gate")
	await edge(&"cave_10_12", &"cave_10_13", Vector2.UP)
	room = world.get_room(&"cave_10_13")
	await collect(room, &"bigkey_c10")
	check(GameState.has_big_key(&"c10"), "actual final Lockpick pickup")
	await edge(&"cave_10_13", &"cave_10_12", Vector2.DOWN)
	room = world.get_room(&"cave_10_12")
	await contact(scripted(room, "boss_door.gd"), Vector2.LEFT)
	check(
		scripted(world.get_room(&"cave_10_14"), "boss_door.gd").is_open,
		"final boss-door peer opens"
	)
	check_eq(GameState.keys_in(&"c1"), 1, "all three C10 spends preserve actual c1 key")
	await edge(&"cave_10_12", &"cave_10_14", Vector2.LEFT)


func spend_lock(from: StringName, to: StringName, id: StringName) -> void:
	var room := await enter(from)
	var target: Node2D
	for node in room.get_node("Props").get_children():
		if node is LockedDoor and node.door_id == id:
			target = node
	await contact(target, Vector2.LEFT)
	check_eq(GameState.keys_in(&"c10"), 0, "actual C10 scoped key spent exactly once")
	check(GameState.has_flag(StringName("door_" + id)), "actual keyed contact persists")
	await edge(from, to, Vector2.LEFT)


func final_fight() -> void:
	var room := await enter(&"cave_10_14")
	var boss = scripted_enemy(room, "the_unlit.gd")
	var trigger = scripted(room, "ending_trigger.gd")
	check(boss != null, "actual assembled Unlit")
	check(not trigger.is_available(), "actual ending unavailable before real fight")
	if boss == null:
		return
	await seconds(1.6)
	await capture_state("unlit-eyes")
	# Actual retreat is permitted; unfinished fight and helpers must reset through Room lifecycle.
	await edge(&"cave_10_14", &"cave_10_12", Vector2.RIGHT)
	await edge(&"cave_10_12", &"cave_10_14", Vector2.LEFT)
	room = world.get_room(&"cave_10_14")
	boss = scripted_enemy(room, "the_unlit.gd")
	trigger = scripted(room, "ending_trigger.gd")
	check_eq(boss.hp, 75, "actual retreat restores Unlit HP")
	check_eq(boss.phase, 1, "actual retreat restores first phase")
	await seconds(1.6)
	check_eq(boss.parts().size(), 5, "actual reentry creates exactly five eyes")
	# Actual death before victory, without changing boss HP or phase.
	var before := summary()
	player.set_hurtbox_enabled(self, true)
	player.take_damage(99, player.global_position + Vector2(10, 0))
	await await_respawn()
	before["health"] = GameState.max_health
	check_eq(summary(), before, "actual death preserves full earned route state")
	check_eq(world.get_current_room_id(), &"ow_10_8", "death returns to Ninth Door checkpoint")
	player.set_hurtbox_enabled(self, false)
	room = await enter(&"cave_10_14")
	boss = scripted_enemy(room, "the_unlit.gd")
	trigger = scripted(room, "ending_trigger.gd")
	await seconds(1.6)
	check_eq(boss.hp, 75, "death resets actual final fight")
	GameState.set_active_item(&"tallow_sling")
	for eye in boss.eyes.duplicate():
		for attempt in range(180):
			if not is_instance_valid(eye) or eye.is_dead:
				break
			var local: Vector2 = eye.global_position - room.global_position
			if local.y < 180 or local.y > 730:
				await frames(6)
				continue
			if GameState.slugs == 0:
				for supply: PickupBase in pickups(room):
					if supply.kind == &"slug_bundle" and supply.visible:
						player.place_at(supply.global_position)
						await frames(5)
			player.place_at(eye.global_position + Vector2(0, 80))
			player.facing = Vector2.UP
			player.use_item()
			await seconds(.35)
		check(not is_instance_valid(eye) or eye.is_dead, "real moving eye killed by actual slugs")
	check_eq(boss.phase, 2, "fifteen real sling damage earns shell")
	check_eq(boss.hp, 60, "natural shell starts with 60 total HP")
	if boss.phase != 2:
		return
	await seconds(1.3)
	await hook_enemy(boss)
	check_eq(boss.hp, 60, "actual hook cannot bypass shell fire requirement")
	await capture_state("unlit-shell")
	GameState.set_active_item(&"cinder_wick")
	for cast in range(5):
		if boss.phase != 2:
			break
		player.place_at(boss.global_position + Vector2(0, 180))
		player.facing = Vector2.UP
		check(player.use_item(), "actual earned cinder flame hits real wax shell")
		await seconds(.3)
		player.place_at(room.global_position + Vector2(1632, 720))
		await seconds(3.8)
	check_eq(boss.phase, 3, "actual attached flames earn heart phase")
	check_eq(boss.hp, 24, "natural heart starts at 24 HP")
	if boss.phase != 3:
		return
	await seconds(1.3)
	await hook_enemy(boss)
	check_eq(boss.hp, 24, "shielded real heart rejects player hook")
	await capture_state("unlit-heart-shielded")
	GameState.set_active_item(&"reel_line")
	for cycle in range(3):
		player.place_at(room.global_position + Vector2(960, 720))
		player.facing = Vector2.UP
		check(player.use_item(), "actual reel fired at real Ninth Lantern")
		await seconds(.9)
		check(boss.exposed_left > 0, "real reel exposes heart")
		check_near(
			boss.lantern.global_position.distance_to(room.global_position + Vector2(960, 288)),
			288,
			1,
			"actual lantern slides contracted distance"
		)
		await capture_state("unlit-heart-exposed")
		for swing in range(5):
			player.place_at(boss.global_position + Vector2(0, 108))
			player.facing = Vector2.UP
			Input.action_press(&"attack")
			await frames(10)
			Input.action_release(&"attack")
			await seconds(.3)
		check_eq(
			boss.hp,
			16 - cycle * 8 if cycle < 2 else 1,
			"each actual reel permits eight hook damage"
		)
		if cycle < 2:
			await seconds(3.6)
	check(GameState.has_flag(&"boss_cave_10_14_defeated"), "actual earned tools kill final Unlit")
	check(boss.is_dying(), "real lethal hook starts two-second fade")
	check(not trigger.is_available(), "ending choice waits during death fade")
	check(not boss.contact_hitbox.active, "dying final contact harmless")
	await seconds(1)
	check(is_instance_valid(boss), "actual final death persists beyond first second")
	check(not trigger.is_available(), "no premature choice during fade")
	await seconds(1.1)
	check(not is_instance_valid(boss), "two-second actual fade removes boss")
	check(trigger.is_available(), "real earned defeat reveals actual ending choice")
	for reward: PickupBase in pickups(room):
		check(
			reward.kind not in [&"fragment", &"wick_core"],
			"final boss grants no invented fragment/core"
		)
	await capture_state("earned-choice")


func c10_persistence() -> void:
	await edge(&"cave_10_14", &"cave_10_12", Vector2.RIGHT)
	await edge(&"cave_10_12", &"cave_10_14", Vector2.LEFT)
	check_eq(
		world.get_room(&"cave_10_14").get_enemies().size(), 0, "actual defeated boss stays retired"
	)
	var room := await enter(&"cave_10_1")
	player.place_at(door_to(room, &"ow_10_8").global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"ow_10_8", "actual C10 mouth returns to Hushmarch")
	check(OS.get_user_data_dir().begins_with("/tmp/"), "C10 disk proof uses isolated userdata")
	if not OS.get_user_data_dir().begins_with("/tmp/"):
		return
	var before := SaveGame._snapshot()
	SaveGame.enabled = true
	check(SaveGame.save(), "actual full earned C10 snapshot saved")
	reset_state()
	check(SaveGame.load_into_state(), "earned full snapshot reloads")
	var after := SaveGame._snapshot()
	check_near(after["playtime"], before["playtime"], .000001, "JSON playtime precision")
	before["playtime"] = after["playtime"]
	check_eq(after, before, "every persistent state field survives real save/load")
	SaveGame.enabled = false
	await dispose(world)
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	for id in [&"cave_10_4", &"cave_10_14"]:
		room = await enter(id)
		check_eq(room.get_enemies().size(), 0, "disk restores earned encounter retirement")
	check(GameState.has_flag(&"ward_e259"), "actual ward result restored")
	check(GameState.has_flag(&"picked_cache_cave_10_10_ward_brass"), "actual cache result restored")
	var earned := summary()
	player.set_hurtbox_enabled(self, true)
	player.take_damage(99, player.global_position + Vector2(10, 0))
	await await_respawn()
	earned["health"] = GameState.max_health
	check_eq(summary(), earned, "post-victory death preserves full earned progression")
	check_eq(world.get_current_room_id(), &"ow_10_8", "post-victory death resumes real mouth")
	player.set_hurtbox_enabled(self, false)
	# Preserve genuine pre-choice state for the independent second branch fixture.
	earned_final = SaveGame._snapshot()


func ending_branch(choice: StringName) -> void:
	var room := await enter(&"cave_10_14")
	var trigger = scripted(room, "ending_trigger.gd")
	check(trigger.is_available(), "earned victory permits branch " + choice)
	# Keep runner alive as a root sibling while actual runtime scenes change themselves.
	world.reparent(get_tree().root)
	SaveGame.enabled = true
	get_tree().current_scene = world
	player.place_at(room.global_position + Vector2(768 if choice == &"rekindle" else 1152, 480))
	await frames(4)
	Input.action_press(&"confirm")
	await frames(2)
	Input.action_release(&"confirm")
	await frames(6)
	var ending = get_tree().current_scene
	check(
		ending != null and ending.scene_file_path == "res://scenes/ui/ending.tscn",
		"actual World changes to real ending scene"
	)
	if ending == null or ending.scene_file_path != "res://scenes/ui/ending.tscn":
		return
	check_eq(ending.choice, choice, "actual requested coda branch")
	check(GameState.has_flag(&"completed"), "actual coda marks completed")
	var other := &"wickwarden" if choice == &"rekindle" else &"rekindle"
	check(not GameState.has_flag(StringName("ending_" + other)), "choice remains exclusive")
	await seconds(2)
	await capture_state("coda-" + choice)
	var event := InputEventAction.new()
	event.action = &"confirm"
	event.pressed = true
	ending._unhandled_input(event)
	check_eq(ending.phase, ending.Phase.CREDITS, "real skip leads to credits")
	await capture_state("credits-" + choice)
	ending._unhandled_input(event)
	await frames(8)
	var title = get_tree().current_scene
	check(
		title != null and title.scene_file_path == "res://scenes/ui/title.tscn",
		"actual credits return to actual title"
	)
	if title == null or title.scene_file_path != "res://scenes/ui/title.tscn":
		return
	# The real coda saved automatically; a manual save here would hide an E1 save defect.
	check(SaveGame.has_save(), "actual coda leaves completed slot")
	var completed := SaveGame._snapshot()
	var disk: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SaveGame.SAVE_PATH))
	check(disk["flags"].has("completed"), "actual coda auto-saved completed flag")
	await capture_state("title-" + choice)
	check(title.menu().is_enabled(&"continue"), "actual title enables Continue")
	title.menu().select(&"continue")
	title._unhandled_input(event)
	await frames(10)
	world = get_tree().current_scene as World
	check(world != null, "actual Continue changes title to World")
	if world == null:
		return
	player = world.player
	check_eq(world.get_current_room_id(), &"ow_10_8", "actual completed Continue loads checkpoint")
	check(GameState.has_flag(&"completed"), "actual Continue retains completed")
	check(
		GameState.has_flag(StringName("ending_" + choice)),
		"actual Continue retains selected branch"
	)
	var continued := SaveGame._snapshot()
	for field in [
		"health",
		"max_health",
		"wallet",
		"keys",
		"pitch_pots",
		"slugs",
		"items",
		"active_item",
		"flags",
		"checkpoint"
	]:
		check_eq(continued[field], completed[field], "actual Continue preserves " + field)
	await capture_state("continued-" + choice)
	SaveGame.enabled = false
	# Restore the real earned pre-choice snapshot for the separately labelled second branch.
	if choice == &"rekindle":
		var file := FileAccess.open(SaveGame.SAVE_PATH, FileAccess.WRITE)
		check(file != null, "isolated second-branch fixture file opens")
		if file != null:
			file.store_string(JSON.stringify(earned_final))
			file.close()


func capture_state(label: String) -> void:
	if OS.get_environment("WICK_C10_CAPTURE") != "1" or route_captures.has(label):
		return
	route_captures[label] = true
	await get_tree().process_frame
	RenderingServer.force_draw(false)
	check_eq(
		get_viewport().get_texture().get_image().save_png("/tmp/wick-c10-" + label + ".png"),
		OK,
		"actual C10 capture " + label
	)
