## timeout=240
extends TestCase
## Controlled integration probe: positioned starts, regular enemies removed, real tool/contact gates.
## Captain and C02 bosses use real acquired tools and hook hitboxes. Not a human playthrough.
var world: World
var player: Player


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	var room := await enter(&"ow_0_1")
	await collect(room, &"tether_moth")
	check(GameState.has_item(&"tether_moth"), "actual overworld moth acquired")
	room = await enter(&"cave_1_3")
	player.place_at(room.global_position + Vector2(1008, 528))
	player.facing = Vector2.UP
	check(player.use_item(), "actual moth fetches independent c1 key through grate")
	await seconds(1.7)
	check_eq(GameState.keys_in(&"c1"), 1, "real other-cave key acquired for scope rejection")
	# Demonstrate missing fire cannot bypass the required thorn gate.
	room = await enter(&"cave_2_2")
	var thorn = scripted(room, "burnable.gd")
	await swing(thorn)
	check(not thorn.is_open, "real hook cannot burn Cinder gate")
	check(not GameState.has_item(&"cinder_wick"), "negative gate probe precedes Cinder acquisition")
	await blocked(Vector2(960, 240), &"move_up", thorn, "thorn gate")
	room = await enter(&"cave_1_5")
	await captain_fight(room)
	await collect(room, &"cinder_wick")
	check(GameState.has_item(&"cinder_wick"), "actual C01 pedestal supplies prerequisite Cinder")
	room = await enter(&"ow_5_1")
	for node in room.get_node("Props").get_children():
		if node is RoomDoor and node.target_room == &"cave_2_1":
			player.place_at(node.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_2_1", "real mouth contact enters C02")
	room = world.get_room(&"cave_2_1")
	check(
		(
			player.global_position.distance_to(
				room.get_node("Spawns/FromOverworld").global_position
			)
			< 60
		),
		"physical mouth uses arrival marker"
	)
	room = await enter(&"cave_2_2")
	thorn = scripted(room, "burnable.gd")
	await blocked(
		Vector2(1650, 480),
		&"move_right",
		scripted(room, "locked_door.gd"),
		"first lock without c2 key"
	)
	check_eq(GameState.keys_in(&"c1"), 1, "c2 rejection preserves actual wrong-scope key")
	var peer := world.get_room(&"cave_2_3")
	check(not scripted(peer, "burnable.gd").is_open, "preloaded thorn endpoint starts closed")
	await cast(thorn, &"cinder_wick", Vector2.UP, 180)
	await seconds(1.6)
	check(thorn.is_open, "actual acquired Cinder burns thorn gate")
	check(scripted(peer, "burnable.gd").is_open, "burn flag opens already loaded opposite endpoint")
	check(GameState.has_flag(&"burned_e156"), "canonical paired burn flag")
	player.place_at(room.global_position + Vector2(960, 200))
	await cross(&"move_up", &"cave_2_3")
	room = world.get_room(&"cave_2_3")
	await collect(room, &"key_c2_1")
	check_eq(GameState.keys_in(&"c2"), 1, "real first scoped key acquired")
	player.place_at(room.global_position + Vector2(960, 740))
	await cross(&"move_down", &"cave_2_2")
	room = world.get_room(&"cave_2_2")
	peer = world.get_room(&"cave_2_4")
	await contact(scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check(scripted(peer, "locked_door.gd").is_open, "real key contact opens preloaded paired lock")
	check_eq(GameState.keys_in(&"c2"), 0, "first lock spends one actual c2 key")
	check(GameState.has_flag(&"door_e157"), "first canonical key flag")
	await cross(&"move_right", &"cave_2_4")
	room = world.get_room(&"cave_2_4")
	await warden(room)
	player.place_at(room.global_position + Vector2(1680, 480))
	await cross(&"move_right", &"cave_2_5")
	room = world.get_room(&"cave_2_5")
	await collect(room, &"tallow_sling")
	check(GameState.has_item(&"tallow_sling"), "actual pale garden pedestal grants sling")
	check_eq(GameState.slugs, 12, "first sling gives twelve slugs")
	player.place_at(room.global_position + Vector2(960, 200))
	await cross(&"move_up", &"cave_2_6")
	room = world.get_room(&"cave_2_6")
	await collect(room, &"key_c2_2")
	await collect(room, &"slug_bundle_cave_2_6")
	check_eq(GameState.slugs, 18, "real accessible refill adds six slugs")
	peer = world.get_room(&"cave_2_7")
	var eye = eye_switch(room)
	await swing(eye)
	check(not eye.is_on, "hook cannot open sling-only eye")
	var before_eye := GameState.slugs
	await cast(eye, &"tallow_sling", Vector2.RIGHT, 140)
	await seconds(.5)
	check(eye.is_on and GameState.has_flag(&"eye_e160"), "real slug opens canonical eye gate")
	check(eye_blocker(peer).is_open, "real slug synchronizes preloaded opposite eye blocker")
	check_eq(GameState.slugs, before_eye - 1, "eye gate spends exactly one real slug")
	player.place_at(room.global_position + Vector2(1680, 528))
	await cross(&"move_right", &"cave_2_7")
	room = world.get_room(&"cave_2_7")
	# Lockpick is not owned yet: physical BossDoor rejection must precede pickup.
	var loft := room
	room = await enter(&"cave_2_8")
	await blocked(
		Vector2(1650, 480),
		&"move_right",
		scripted(room, "boss_door.gd"),
		"BossDoor without Lockpick"
	)
	check(not GameState.has_flag(&"door_boss_c2"), "small key and tools cannot forge boss flag")
	room = await enter(&"cave_2_7")
	check(room == loft or room.room_id == &"cave_2_7", "return to actual Lockpick room")
	await collect(room, &"bigkey_c2")
	check(GameState.has_big_key(&"c2"), "actual Eye Loft Lockpick acquired")
	player.place_at(room.global_position + Vector2(240, 528))
	await cross(&"move_left", &"cave_2_6")
	room = await enter(&"cave_2_5")
	peer = world.get_room(&"cave_2_8")
	await contact(scripted(room, "locked_door.gd"), Vector2.DOWN)
	check(scripted(peer, "locked_door.gd").is_open, "second real c2 key opens paired endpoint")
	check_eq(GameState.keys_in(&"c2"), 0, "two acquired keys spent once each")
	check_eq(GameState.keys_in(&"c1"), 1, "both real c2 locks preserve independent c1 key")
	check(GameState.has_flag(&"door_e161"), "second canonical lock flag")
	await cross(&"move_down", &"cave_2_8")
	room = world.get_room(&"cave_2_8")
	peer = world.get_room(&"cave_2_9")
	await contact(scripted(room, "boss_door.gd"), Vector2.RIGHT)
	check(GameState.has_flag(&"door_boss_c2"), "real Lockpick contact opens BossDoor")
	check(GameState.has_big_key(&"c2"), "BossDoor retains acquired Lockpick")
	check(
		scripted(peer, "boss_door.gd").is_open,
		"BossDoor flag synchronizes preloaded opposite endpoint"
	)
	# Spend real slugs into the antechamber wall to exercise assembled low-ammo supply.
	var drain := GameState.slugs - 7
	for shot in range(drain):
		player.place_at(room.global_position + Vector2(1400, 480))
		player.facing = Vector2.UP
		GameState.set_active_item(&"tallow_sling")
		check(player.use_item(), "real antechamber shot spends supply-test ammo")
		await seconds(.8)
	check_eq(GameState.slugs, 7, "low-ammo arena entry uses actual spent slugs")
	player.place_at(room.global_position + Vector2(1800, 480))
	await capture_state("boss-door")
	await cross(&"move_right", &"cave_2_9")
	room = world.get_room(&"cave_2_9")
	await mother(room)
	await persistence()
	await dispose(world)
	await reverse_pairs()


func warden(room: Room) -> void:
	var enemy = room.get_enemies()[0]
	await swing(enemy)
	check_eq(enemy.hp, 15, "real unstunned hook deals one through thorn skirt")
	await frames(25)
	await cast(enemy, &"tether_moth", Vector2.RIGHT, 200)
	await frames(16)
	check(enemy.is_stunned(), "actual acquired moth stuns assembled Thorn Warden")
	var hp: int = enemy.hp
	await swing(enemy)
	check_eq(enemy.hp, hp - 2, "real hook deals two after moth stun")
	await frames(25)
	hp = enemy.hp
	await cast(enemy, &"cinder_wick", Vector2.RIGHT, 160)
	await seconds(.7)
	check(enemy.hp <= hp - 2, "actual Cinder ticks deal two to Warden")
	for attempt in range(20):
		if not is_instance_valid(enemy) or enemy.is_dead:
			break
		await swing(enemy)
		await frames(25)
	await seconds(1.7)
	check(GameState.has_flag(&"mini_cave_2_4"), "real Warden defeat persists")
	await capture_state("warden-defeated")


func mother(room: Room) -> void:
	var boss = scripted_enemy(room, "briar_mother.gd")
	check(boss != null, "assembled Mother present")
	if boss == null:
		return
	var rewards := pickups(room).filter(
		func(n: PickupBase) -> bool: return n.kind in [&"fragment", &"wick_core"]
	)
	check_eq(rewards.size(), 2, "exactly one room fragment and core, no arena duplicates")
	for reward in rewards:
		check(not reward.visible, "boss rewards hidden before defeat")
	await seconds(1.7)
	var before_supply := GameState.slugs
	var supplies := pickups(room).filter(
		func(n: PickupBase) -> bool: return n.kind == &"slug_bundle" and n.persistent_id == &""
	)
	check_eq(supplies.size(), 1, "assembled low-ammo boss creates one real supply")
	if not supplies.is_empty():
		check_near(supplies[0].timeout, 8, .1, "boss supply has eight-second lifetime")
		player.place_at(supplies[0].global_position + Vector2(0, 30))
		await frames(5)
		check_eq(GameState.slugs, before_supply + 6, "physical boss refill contact adds six slugs")
	check_near(boss.SPORE_WARNING, .5, .001, "assembled Mother uses ruled half-second tell")
	# Observe a natural warning and release without forcing a timer or damage.
	var observed := false
	for tick in range(180):
		for pending: Dictionary in boss._pending:
			if pending.get("kind") == &"spore" or pending.get("kind") == "spore":
				observed = true
		if observed:
			break
		await frames(1)
	check(observed, "assembled Mother naturally schedules spore warning")
	if observed:
		await seconds(.4)
		check_eq(projectiles(room), 0, "natural half-second spore tell has not fired at .4 seconds")
		await seconds(.15)
		check(projectiles(room) > 0, "natural spore warning fires after .5 seconds")
	var shots := 0
	for attempt in range(30):
		if boss.phase != 1:
			break
		var target: EnemyBase = null
		for eye in boss.parts():
			if eye.hurtbox.enabled and not eye.invulnerable:
				target = eye
				break
		if target == null:
			await seconds(.15)
			continue
		var hp := target.hp
		await cast(target, &"tallow_sling", Vector2.UP, 110)
		await seconds(.3)
		if is_instance_valid(target):
			check_eq(target.hp, hp - 1, "acquired sling slug deals one to lowered boss eye")
		shots += 1
	check_eq(shots, 12, "three eyes require twelve actual sling shots")
	check_eq(boss.phase, 2, "real sling opens bloom phase")
	await seconds(1.3)
	await cast(boss, &"cinder_wick", Vector2.UP, 180)
	await seconds(.7)
	check(boss.hp <= 14, "actual acquired Cinder burns vulnerable bloom")
	await seconds(3)
	for attempt in range(12):
		if not is_instance_valid(boss) or boss.is_dying():
			break
		await swing(boss)
		await frames(25)
	check(GameState.has_flag(&"boss_cave_2_9_defeated"), "real sling Cinder and hook defeat Mother")
	await seconds(1.6)
	await capture_state("boss-rewards")
	var maximum := GameState.max_health
	await collect(room, &"frag_c2")
	await collect(room, &"wick_core_c2")
	check(GameState.has_flag(&"frag_c2"), "real Fragment of Growth collected")
	check_eq(GameState.max_health, maximum + 2, "one real core adds two half-hearts")
	check_eq(GameState.health, GameState.max_health, "core fully heals")


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
		enemy.drops_enabled = false
		enemy.kill()
	await frames(4)
	return room


func pickups(root: Node) -> Array[PickupBase]:
	var result: Array[PickupBase] = []
	if root is PickupBase:
		result.append(root)
	for child in root.get_children():
		result.append_array(pickups(child))
	return result


func collect(room: Room, id: StringName) -> void:
	var found := false
	for node in pickups(room):
		if node.persistent_id == id:
			found = true
			player.place_at(node.global_position + Vector2(0, 44))
			await frames(5)
	check(found, "real pickup exists: " + String(id))


func scripted(root: Node, suffix: String) -> Node:
	for node in root.get_children():
		var script: Script = node.get_script()
		if script != null and script.resource_path.ends_with(suffix):
			return node
		var nested := scripted(node, suffix)
		if nested != null:
			return nested
	return null


func scripted_enemy(room: Room, suffix: String) -> EnemyBase:
	for enemy in room.get_enemies():
		if enemy.get_script().resource_path.ends_with(suffix):
			return enemy
	return null


func eye_switch(room: Room) -> Node2D:
	for node in room.get_node("Props").get_children():
		if (
			node.get_script() != null
			and node.get_script().resource_path.ends_with("eye_switch.gd")
			and not node.blocker
		):
			return node
	return null


func eye_blocker(room: Room) -> Node2D:
	for node in room.get_node("Props").get_children():
		if (
			node.get_script() != null
			and node.get_script().resource_path.ends_with("eye_switch.gd")
			and node.blocker
		):
			return node
	return null


func cast(target: Node2D, item: StringName, direction: Vector2, distance: float) -> void:
	player.place_at(target.global_position - direction * distance)
	player.facing = direction
	GameState.set_active_item(item)
	await frames(2)
	check(player.use_item(), "actual acquired tool launches: " + String(item))


func swing(target: Node2D) -> void:
	player.place_at(target.global_position + Vector2(0, 90))
	player.facing = Vector2.UP
	await frames(3)
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	await frames(14)


func contact(target: Node2D, direction: Vector2) -> void:
	player.place_at(target.global_position - direction * 180)
	Input.action_press(action_for(direction))
	for tick in range(90):
		await frames(1)
		if target.is_open:
			break
	release_inputs()
	await frames(2)
	check(target.is_open, "physical contact opens " + String(target.name))


func blocked(at: Vector2, action: StringName, target: Node, label: String) -> void:
	var id := world.get_current_room_id()
	var room := world.get_room(id)
	player.place_at(room.global_position + at)
	Input.action_press(action)
	await seconds(1)
	release_inputs()
	check_eq(world.get_current_room_id(), id, label + " rejects physical crossing")
	check(not target.is_open, label + " remains shut")


func action_for(direction: Vector2) -> StringName:
	if direction == Vector2.RIGHT:
		return &"move_right"
	if direction == Vector2.LEFT:
		return &"move_left"
	return &"move_down" if direction == Vector2.DOWN else &"move_up"


func cross(action: StringName, target: StringName) -> void:
	Input.action_press(action)
	for tick in range(240):
		await frames(1)
		if world.get_current_room_id() == target:
			break
	release_inputs()
	await seconds(.4)
	check_eq(world.get_current_room_id(), target, "real exit crossing to " + String(target))
	if world.get_current_room_id() == target:
		await enter(target)


func persistence() -> void:
	check(not SaveGame.enabled, "route leaves normal disk writes disabled")
	var before := summary()
	await enter(&"cave_2_5")
	check_eq(GameState.keys_in(&"c2"), 0, "paired lock reentry never spends twice")
	var room := await enter(&"cave_2_9")
	check_eq(room.get_enemies().size(), 0, "defeated Mother and eyes stay absent")
	for reward in pickups(room):
		if reward.persistent_id in [&"frag_c2", &"wick_core_c2"]:
			check(not reward.visible, "collected persistent reward stays absent")
	check_eq(GameState.max_health, before["max"], "reentry cannot duplicate core")
	if OS.get_environment("WICK_C02_DISK") == "1":
		var isolated := OS.get_environment("XDG_DATA_HOME")
		var safe := (
			isolated.begins_with("/tmp/wick-c02-")
			and OS.get_user_data_dir().begins_with(isolated + "/")
		)
		check(safe, "disk proof requires isolated temporary userdata root")
		if safe:
			before = summary()
			SaveGame.enabled = true
			check(SaveGame.save(), "actual acquired route saves in isolated slot")
			reset_state()
			check(SaveGame.load_into_state(), "isolated disk slot reloads")
			check_eq(summary(), before, "full route state survives actual disk roundtrip")
			SaveGame.enabled = false
	var maximum := GameState.max_health
	player.set_hurtbox_enabled(self, true)
	player.take_damage(99, player.global_position + Vector2(10, 0))
	for tick in range(400):
		await frames(1)
		if not player.is_dead() and not world.is_transitioning():
			break
	check_eq(world.get_current_room_id(), &"ow_5_1", "actual death returns to C02 mouth checkpoint")
	check_eq(GameState.health, maximum, "death restores full health")
	for flag in [
		&"burned_e156",
		&"door_e157",
		&"eye_e160",
		&"door_e161",
		&"door_boss_c2",
		&"mini_cave_2_4",
		&"boss_cave_2_9_defeated",
		&"frag_c2"
	]:
		check(GameState.has_flag(flag), "death preserves real route flag " + String(flag))


func summary() -> Dictionary:
	var keys := {}
	for scope in GameState.KEY_SCOPES:
		keys[scope] = GameState.keys_in(scope)
	return {
		"keys": keys,
		"health": GameState.health,
		"max": GameState.max_health,
		"slugs": GameState.slugs,
		"pots": GameState.pitch_pots,
		"flags": GameState.flags.duplicate(),
		"items": GameState.acquired_item_ids(),
		"wallet": GameState.currency,
		"checkpoint": SaveGame.checkpoint_room()
	}


func capture_state(label: String) -> void:
	if OS.get_environment("WICK_C02_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		get_viewport().get_texture().get_image().save_png("/tmp/wick-c02-" + label + ".png"),
		OK,
		"actual capture " + label
	)


## Separate reset probes originate each change at the opposite endpoint.
## Pickup positioning sets up these fixtures; this scenario makes no reachability claim.
func reverse_pairs() -> void:
	reset_state()
	SaveGame.enabled = false
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	var room := await enter(&"ow_0_1")
	await collect(room, &"tether_moth")
	check(GameState.has_item(&"tether_moth"), "reverse fixture acquires real moth")
	room = await enter(&"cave_1_5")
	await captain_fight(room)
	await collect(room, &"cinder_wick")
	room = await enter(&"cave_2_3")
	var peer := world.get_room(&"cave_2_2")
	await cast(scripted(room, "burnable.gd"), &"cinder_wick", Vector2.DOWN, 180)
	await seconds(1.6)
	check(scripted(peer, "burnable.gd").is_open, "reverse real fire synchronizes loaded hub")
	await collect(room, &"key_c2_1")
	room = await enter(&"cave_2_4")
	peer = world.get_room(&"cave_2_2")
	await contact(scripted(room, "locked_door.gd"), Vector2.LEFT)
	check(scripted(peer, "locked_door.gd").is_open, "reverse real first key contact opens hub")
	check_eq(GameState.keys_in(&"c2"), 0, "reverse first lock spends one key")
	room = await enter(&"cave_2_5")
	await collect(room, &"tallow_sling")
	room = await enter(&"cave_2_6")
	await collect(room, &"key_c2_2")
	room = await enter(&"cave_2_7")
	peer = world.get_room(&"cave_2_6")
	await cast(eye_switch(room), &"tallow_sling", Vector2.LEFT, 140)
	await seconds(.5)
	check(eye_blocker(peer).is_open, "reverse real eye slug opens loaded walk endpoint")
	await collect(room, &"bigkey_c2")
	room = await enter(&"cave_2_8")
	peer = world.get_room(&"cave_2_5")
	await contact(scripted(room, "locked_door.gd"), Vector2.UP)
	check(scripted(peer, "locked_door.gd").is_open, "reverse second real key opens garden endpoint")
	check_eq(GameState.keys_in(&"c2"), 0, "reverse second lock spends one key")
	room = await enter(&"cave_2_9")
	peer = world.get_room(&"cave_2_8")
	await contact(scripted(room, "boss_door.gd"), Vector2.LEFT)
	check(
		scripted(peer, "boss_door.gd").is_open,
		"reverse actual Lockpick contact opens loaded antechamber"
	)
	check(GameState.has_big_key(&"c2"), "reverse BossDoor retains real Lockpick")
	await dispose(world)


func projectiles(root: Node) -> int:
	var count := 1 if root is EnemyProjectile else 0
	for child in root.get_children():
		count += projectiles(child)
	return count


## Reuse the C01 lead sequence: front guard, actual moth stun, then actual hook hits.
func captain_fight(room: Room) -> void:
	var captain = room.get_enemies()[0]
	var hp: int = captain.hp
	player.place_at(captain.global_position + Vector2(90, 0))
	player.facing = Vector2.LEFT
	captain.set_facing_dir(Vector2.RIGHT)
	await frames(2)
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(captain.hp, hp, "assembled captain blocks real front hook")
	await frames(25)
	player.place_at(captain.global_position - Vector2(180, 0))
	player.facing = Vector2.RIGHT
	GameState.set_active_item(&"tether_moth")
	check(player.use_item(), "actual moth launched at assembled captain")
	await frames(16)
	check(captain.is_stunned(), "actual moth drops captain guard")
	hp = captain.hp
	player.place_at(captain.global_position - Vector2(90, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check(captain.hp < hp, "real hook damages captain after moth drops guard")
	# Finish through actual player hook hitboxes from the unguarded side.
	for strike in range(12):
		if not is_instance_valid(captain) or captain.is_dead:
			break
		await frames(25)
		if not is_instance_valid(captain) or captain.is_dead:
			break
		player.place_at(captain.global_position + captain.facing_dir.orthogonal() * 80)
		player.facing = (captain.global_position - player.global_position).normalized()
		Input.action_press(&"attack")
		await frames(8)
		Input.action_release(&"attack")
	await seconds(1.6)
	check(GameState.has_flag(&"mini_cave_1_5"), "real captain death sets room flag")
