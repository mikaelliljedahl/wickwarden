## timeout=300
extends TestCase
## Controlled positioned integration probe; ordinary mobs removed, player hurtbox off except death.
## Kit is earned through real pickups/encounters. No forced progression flags or human-playthrough claim.
var world: World
var player: Player


func run() -> void:
	reset_state()
	SaveGame.enabled = false
	world = await make_world()
	player = world.player
	player.set_hurtbox_enabled(self, false)
	await acquire_kit()
	var room := await enter(&"ow_9_2")
	var mouth := door_to(room, &"cave_4_1")
	check(mouth != null, "real Sleeping Furnace mouth exists")
	if mouth == null:
		await dispose(world)
		return
	player.place_at(mouth.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"cave_4_1", "actual mouth contact enters C04")
	room = await enter(&"cave_4_1")
	check(
		(
			player.global_position.distance_to(
				room.get_node("Spawns/FromOverworld").global_position
			)
			< 60
		),
		"actual cave mouth uses clear named arrival"
	)
	player.place_at(room.global_position + Vector2(1680, 480))
	await cross(&"move_right", &"cave_4_2")
	room = world.get_room(&"cave_4_2")
	await blocked(
		Vector2(1650, 480),
		&"move_right",
		scripted(room, "locked_door.gd"),
		"first c4 lock with real wrong-scope key"
	)
	check_eq(GameState.keys_in(&"c1"), 1, "wrong-scope rejection retains actual c1 key")
	var peer := world.get_room(&"cave_4_3")
	var eye := eye_switch(room)
	await swing(eye)
	check(not eye.is_on, "actual hook cannot operate sling-only eye")
	var ammo := GameState.slugs
	await cast(eye, &"tallow_sling", Vector2.UP, 150)
	await seconds(.5)
	check(eye.is_on and GameState.has_flag(&"eye_e172"), "actual acquired sling operates eye gate")
	check(eye_blocker(peer).is_open, "eye flag opens already loaded opposite blocker")
	check_eq(GameState.slugs, ammo - 1, "actual eye gate spends one slug")
	player.place_at(room.global_position + Vector2(960, 200))
	await cross(&"move_up", &"cave_4_3")
	room = world.get_room(&"cave_4_3")
	await collect(room, &"key_c4_1")
	check_eq(GameState.keys_in(&"c4"), 1, "actual Eyed Cell key credits c4")
	player.place_at(room.global_position + Vector2(960, 740))
	await cross(&"move_down", &"cave_4_2")
	room = world.get_room(&"cave_4_2")
	peer = world.get_room(&"cave_4_4")
	await contact(scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check(
		scripted(peer, "locked_door.gd").is_open,
		"actual c4 spend synchronizes preloaded first lock"
	)
	check_eq(GameState.keys_in(&"c4"), 0, "first actual c4 key spent once")
	await cross(&"move_right", &"cave_4_4")
	room = world.get_room(&"cave_4_4")
	await mauler(room)
	player.place_at(room.global_position + Vector2(240, 480))
	await cross(&"move_left", &"cave_4_2")
	check_eq(GameState.keys_in(&"c4"), 0, "paired lock return never spends twice")
	room = world.get_room(&"cave_4_2")
	player.place_at(room.global_position + Vector2(1680, 480))
	await cross(&"move_right", &"cave_4_4")
	room = world.get_room(&"cave_4_4")
	check_eq(room.get_enemies().size(), 0, "actual Mauler defeat survives reentry")
	player.place_at(room.global_position + Vector2(1680, 480))
	await cross(&"move_right", &"cave_4_5")
	room = world.get_room(&"cave_4_5")
	check(not GameState.has_item(&"heft_mitts"), "Mauler was defeated before mitts acquisition")
	var stone := scripted(room, "heavy_stone.gd") as Node2D
	await swing(stone)
	check(not GameState.has_flag(&"moved_e175"), "actual hook cannot move mitts gate")
	await blocked_stone(room)
	await collect(room, &"heft_mitts")
	check(GameState.has_item(&"heft_mitts"), "actual Anvil Row pedestal grants mitts after mini")
	peer = world.get_room(&"cave_4_6")
	await lift_throw(stone, Vector2.UP)
	await seconds(.9)
	check(GameState.has_flag(&"moved_e175"), "actual acquired mitts lift/throw opens heavy gate")
	var opposite := scripted(peer, "heavy_stone.gd")
	check(
		opposite == null or not opposite.visible or opposite.state == opposite.State.SHATTERED,
		"P06 flag removes preloaded opposite heavy stone"
	)
	player.place_at(room.global_position + Vector2(960, 200))
	await cross(&"move_up", &"cave_4_6")
	room = world.get_room(&"cave_4_6")
	await collect(room, &"key_c4_2")
	check_eq(GameState.keys_in(&"c4"), 1, "actual Heavy Vault key credits c4")
	player.place_at(room.global_position + Vector2(960, 740))
	await cross(&"move_down", &"cave_4_5")
	room = world.get_room(&"cave_4_5")
	player.place_at(room.global_position + Vector2(960, 740))
	await cross(&"move_down", &"cave_4_7")
	room = world.get_room(&"cave_4_7")
	await wax_pocket(room)
	room = world.get_room(&"cave_4_7")
	peer = world.get_room(&"cave_4_8")
	await contact(scripted(room, "locked_door.gd"), Vector2.RIGHT)
	check(scripted(peer, "locked_door.gd").is_open, "second real c4 key synchronizes paired lock")
	check_eq(GameState.keys_in(&"c4"), 0, "both actual c4 keys spent once each")
	check_eq(GameState.keys_in(&"c1"), 1, "both c4 spends preserve actual c1 key")
	await cross(&"move_right", &"cave_4_8")
	room = world.get_room(&"cave_4_8")
	# Accessible antechamber before Lockpick pickup: reject base kit and scoped small keys.
	room = await enter(&"cave_4_9")
	await blocked(
		Vector2(960, 740), &"move_down", scripted(room, "boss_door.gd"), "BossDoor without Lockpick"
	)
	room = await enter(&"cave_4_8")
	await collect(room, &"bigkey_c4")
	check(GameState.has_big_key(&"c4"), "actual Bellows Loft Lockpick acquired")
	player.place_at(room.global_position + Vector2(240, 480))
	await cross(&"move_left", &"cave_4_7")
	room = world.get_room(&"cave_4_7")
	player.place_at(room.global_position + Vector2(240, 480))
	await cross(&"move_left", &"cave_4_9")
	room = world.get_room(&"cave_4_9")
	peer = world.get_room(&"cave_4_10")
	await contact(scripted(room, "boss_door.gd"), Vector2.DOWN)
	check(
		scripted(peer, "boss_door.gd").is_open,
		"actual Lockpick synchronizes preloaded boss endpoint"
	)
	check(GameState.has_big_key(&"c4"), "BossDoor retains actual Lockpick")
	await cross(&"move_down", &"cave_4_10")
	room = world.get_room(&"cave_4_10")
	await colossus(room)
	await persistence()
	await dispose(world)


func acquire_kit() -> void:
	var room := await enter(&"ow_0_1")
	await collect(room, &"tether_moth")
	check(GameState.has_item(&"tether_moth"), "actual overworld moth acquired")
	room = await enter(&"cave_1_3")
	player.place_at(room.global_position + Vector2(1008, 528))
	player.facing = Vector2.UP
	check(player.use_item(), "actual moth fetches c1 scope-rejection key")
	await seconds(1.7)
	check_eq(GameState.keys_in(&"c1"), 1, "real other-cave key acquired")
	room = await enter(&"cave_1")
	await swing_from(room.get_node("Props/BrazierWest").global_position, Vector2.UP)
	await swing_from(room.get_node("Props/BrazierEast").global_position, Vector2.UP)
	player.place_at(room.global_position + Vector2(960, 240))
	await frames(5)
	check_eq(GameState.keys_in(&"ow"), 1, "real braziers expose historical ow key")
	room = await enter(&"ow_2_1")
	var lock := scripted(room, "locked_door.gd") as LockedDoor
	player.place_at(lock.global_position + Vector2(0, -70))
	await frames(5)
	check(lock.is_open, "real overworld key opens pot closet by contact")
	await collect(room, &"pitch_pot")
	check(GameState.has_item(&"pitch_pot"), "actual pot pickup acquired")
	check_eq(GameState.pitch_pots, 6, "pot pickup supplies six real pots")
	room = await enter(&"cave_1_5")
	await captain_fight(room)
	await collect(room, &"cinder_wick")
	check(GameState.has_item(&"cinder_wick"), "actual Captain route pedestal grants Cinder")
	room = await enter(&"cave_2_4")
	await warden(room)
	room = await enter(&"cave_2_5")
	await collect(room, &"tallow_sling")
	check(
		GameState.has_item(&"tallow_sling"), "actual post-Warden pedestal grants prior-cave sling"
	)
	check_eq(GameState.slugs, 12, "real sling starts with twelve slugs")


func blocked_stone(room: Room) -> void:
	player.place_at(room.global_position + Vector2(960, 240))
	Input.action_press(&"move_up")
	await seconds(1)
	release_inputs()
	check_eq(
		world.get_current_room_id(), &"cave_4_5", "heavy stone physically blocks without mitts"
	)


func mauler(room: Room) -> void:
	var enemy = scripted_enemy(room, "lull_mauler.gd")
	check(enemy != null, "assembled Mauler exists")
	if enemy == null:
		return
	check(not GameState.has_item(&"heft_mitts"), "pre-mitts Mauler uses base hook solution")
	player.place_at(enemy.global_position + Vector2(400, 0))
	var chunk: Node2D
	for tick in range(360):
		for node in room.find_children("*", "", true, false):
			if node.is_in_group(&"liftable") and node.get("deflected") != null:
				chunk = node
		if chunk != null:
			break
		await frames(1)
	check(chunk != null, "natural smash creates real slag ammunition")
	if chunk == null:
		return
	check(enemy.state == enemy.State.RECOVER, "natural slag appears during smash recovery")
	# Lure the next natural walk away from the stationary slag; never move/freeze the chunk or enemy.
	player.place_at(enemy.global_position - Vector2(300, 0))
	for tick in range(240):
		if chunk.global_position.distance_to(enemy.global_position) > 185:
			break
		await frames(1)
	check(
		chunk.global_position.distance_to(enemy.global_position) > 185,
		"natural walk creates measurable return flight"
	)
	var direction: Vector2 = (enemy.global_position - chunk.global_position).normalized()
	player.place_at(chunk.global_position - direction * 90)
	player.facing = direction
	await frames(3)
	var hp: int = enemy.hp
	Input.action_press(&"attack")
	for tick in range(12):
		await frames(1)
		if chunk.deflected:
			break
	Input.action_release(&"attack")
	check(chunk.deflected, "actual pre-mitts hook collision deflects natural slag")
	check_eq(chunk._hitbox.damage, 4, "actual hook-deflected slag damage is four")
	var from: Vector2 = chunk.global_position
	await frames(1)
	check_near(
		chunk.global_position.distance_to(from) * 60,
		400,
		1,
		"actual natural slag flight is 400px/s"
	)
	await capture_state("mauler-slag")
	await seconds(.7)
	check_eq(enemy.hp, hp - 4, "actual returned natural slag damages Mauler by four")
	await frames(25)
	await cast(enemy, &"tether_moth", Vector2.RIGHT, 180)
	await frames(16)
	check(enemy.is_stunned(), "actual acquired moth stuns pre-mitts Mauler")
	for strike in range(20):
		if not is_instance_valid(enemy) or enemy.is_dying() or enemy.is_dead:
			break
		await swing(enemy)
		await frames(25)
	await seconds(1.7)
	check(GameState.has_flag(&"mini_cave_4_4"), "actual slag/moth/hook defeat persists")
	check(not GameState.has_item(&"heft_mitts"), "no new tool granted before mini defeat")


func lift_throw(prop: Node2D, direction: Vector2) -> void:
	player.place_at(prop.global_position - direction * 90)
	player.facing = direction
	GameState.set_active_item(&"heft_mitts")
	await frames(3)
	check(player.use_item(), "actual acquired mitts activate")
	await frames(22)
	check(prop.is_carried(), "real grab hitbox lifts actual prop")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")


func wax_pocket(room: Room) -> void:
	var seal := scripted(room, "wax_seal.gd") as Node2D
	var door := door_to(room, &"cave_4_7#seal")
	await swing(seal)
	check(not seal.is_open, "actual ordinary hook cannot melt wax seal")
	player.place_at(door.global_position)
	await frames(5)
	check_eq(
		world.get_current_room_id(),
		&"cave_4_7",
		"closed seal rejects actual pocket trigger overlap"
	)
	player.place_at(seal.global_position + Vector2(0, 100))
	player.facing = Vector2.UP
	await frames(3)
	Input.action_press(&"attack")
	await seconds(.9)
	Input.action_release(&"attack")
	await frames(10)
	check(
		seal.is_open and GameState.has_flag(&"melted_e180"),
		"actual player charged flare melts wax seal"
	)
	player.place_at(door.global_position + Vector2(0, 120))
	await cross(&"move_up", &"cave_4_7#seal")
	room = world.get_room(&"cave_4_7#seal")
	check(
		player.global_position.distance_to(room.get_node("Spawns/Inside").global_position) < 60,
		"actual pocket entry lands clear at Inside"
	)
	var brass := GameState.currency
	var pots := GameState.pitch_pots
	await collect(room, &"cache_cave_4_7_brass")
	check_eq(GameState.currency, brass + 30, "actual pocket cache grants thirty brass")
	check(
		GameState.has_flag(&"picked_cache_cave_4_7_pots"),
		"real co-located cache pot bundle collected"
	)
	check_eq(
		GameState.pitch_pots,
		mini(pots + 4, GameState.pot_max()),
		"real pocket pot bundle refills four"
	)
	var ammo := GameState.slugs
	await collect(room, &"slug_bundle_cave_4_7")
	check_eq(
		GameState.slugs, mini(ammo + 6, GameState.slug_max()), "actual pocket bundle adds six slugs"
	)
	await capture_state("seal-cache")
	var back := door_to(room, &"cave_4_7")
	player.place_at(back.global_position + Vector2(0, -100))
	await cross(&"move_down", &"cave_4_7")
	room = world.get_room(&"cave_4_7")
	check(
		player.global_position.distance_to(room.get_node("Spawns/FromPocket").global_position) < 60,
		"real pocket return uses clear FromPocket"
	)
	check(scripted(room, "wax_seal.gd").is_open, "actual flare opening persists on pocket return")


func colossus(room: Room) -> void:
	var boss = scripted_enemy(room, "hushed_colossus.gd")
	check(boss != null, "real assembled Colossus present")
	if boss == null:
		return
	check(GameState.has_item(&"heft_mitts"), "boss starts with actually earned mitts")
	var rewards := pickups(room).filter(
		func(n: PickupBase) -> bool: return n.kind in [&"fragment", &"wick_core"]
	)
	check_eq(rewards.size(), 2, "exactly one room-owned fragment and core")
	for reward in rewards:
		check(not reward.visible, "boss reward remains hidden before actual defeat")
	await seconds(1.7)
	var hp: int = boss.hp
	await swing(boss)
	check_eq(boss.hp, hp, "real hook cannot pierce Colossus armour")
	# Actual natural ammunition and mitts cause partial damage; physical retreat must reset it.
	for attempt in range(4):
		await natural_shard_throw(room, boss, false)
		if boss.hp < 48:
			break
	check_eq(boss.hp, 42, "actual first natural shard deals six before reset probe")
	player.place_at(room.global_position + Vector2(960, 200))
	await cross(&"move_up", &"cave_4_9")
	room = world.get_room(&"cave_4_9")
	check(GameState.has_big_key(&"c4"), "real retreat retains Lockpick")
	player.place_at(room.global_position + Vector2(960, 740))
	await cross(&"move_down", &"cave_4_10")
	room = world.get_room(&"cave_4_10")
	boss = scripted_enemy(room, "hushed_colossus.gd")
	check_eq(boss.hp, 48, "actual room retreat resets full boss HP")
	check_eq(boss.phase, 1, "actual room retreat resets first wake")
	check_eq(boss.floor_shards(), 0, "actual retreat clears previous natural ammunition")
	check(boss.is_in_intro(), "actual reentry restarts harmless intro")
	await seconds(1.7)
	var throws := 0
	for attempt in range(16):
		if not is_instance_valid(boss) or boss.is_dying():
			break
		if boss.is_pausing():
			await seconds(1.3)
		var before: int = boss.hp
		await natural_shard_throw(room, boss, throws == 0)
		if is_instance_valid(boss) and not boss.is_dying():
			var damage: int = before - boss.hp
			check(
				damage in [0, 6],
				"natural shard either misses or deals exactly six in wake " + str(boss.phase)
			)
			if damage == 6:
				throws += 1
		else:
			check(before <= 6, "only lethal eighth shard hit starts death")
			throws += 1
	check_eq(throws, 8, "eight actual natural shard hits defeat all three wakes")
	check(
		GameState.has_flag(&"boss_cave_4_10_defeated"),
		"actual earned mitts throws defeat assembled Colossus"
	)
	await seconds(1.6)
	player.place_at(room.global_position + Vector2(960, 600))
	await frames(3)
	await capture_state("boss-rewards")
	var maximum := GameState.max_health
	await collect(room, &"frag_c4")
	await collect(room, &"wick_core_c4")
	check(GameState.has_flag(&"frag_c4"), "actual Fragment of Sleep collected")
	check_eq(GameState.max_health, maximum + 2, "single actual boss core adds one heart")
	check_eq(GameState.health, GameState.max_health, "boss core fully heals")


func natural_shard_throw(room: Room, boss: Variant, capture: bool) -> void:
	var shard: Node2D
	for tick in range(600):
		for candidate in boss.shards:
			if (
				is_instance_valid(candidate)
				and not candidate.is_queued_for_deletion()
				and candidate.state == candidate.State.LYING
			):
				shard = candidate
				break
		if shard != null:
			break
		await frames(1)
	check(shard != null, "natural ceiling attack lands real liftable ammunition")
	if shard == null:
		return
	player.place_at(shard.global_position - Vector2(72, 0))
	player.facing = Vector2.RIGHT
	GameState.set_active_item(&"heft_mitts")
	await frames(3)
	check(player.use_item(), "actual acquired mitts grab natural ceiling shard")
	await frames(22)
	check(shard.is_carried(), "real grab collision carries naturally landed shard")
	check(player.actions_locked(), "actual carry locks hook and ward")
	# Controlled carry positioning preserves the real carrier/item state; neither boss nor shard is frozen.
	var direction := Vector2.RIGHT if boss.position.x > 500 else Vector2.LEFT
	player.global_position = boss.global_position - direction * 180 + Vector2(0, 40)
	player.facing = direction
	await frames(2)
	if capture:
		await capture_state("natural-shard-carry")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await seconds(.8)
	check(not player.actions_locked(), "actual throw releases carrying lockout")
	check(room.is_entered, "natural shard combat remains in the real cave room")


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
	for node in pickups(room):
		if is_instance_valid(node) and node.persistent_id == id:
			player.place_at(node.global_position + Vector2(0, 44))
			await frames(5)
			check(true, "real pickup exists: " + String(id))
			return
	check(false, "real pickup exists: " + String(id))


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
		if not is_instance_valid(enemy) or enemy.is_dead or enemy.is_dying():
			break
		await swing(enemy)
		await frames(25)
	await seconds(1.7)
	check(GameState.has_flag(&"mini_cave_2_4"), "real Warden defeat persists")


func door_to(room: Room, target: StringName) -> RoomDoor:
	for node in room.get_node("Props").get_children():
		if node is RoomDoor and node.target_room == target:
			return node
	return null


func persistence() -> void:
	check(not SaveGame.enabled, "route leaves normal disk writes disabled")
	var before := summary()
	await enter(&"cave_4_5")
	check_eq(GameState.keys_in(&"c4"), 0, "paired lock reentry never spends twice")
	var room := await enter(&"cave_4_7#seal")
	check(GameState.has_flag(&"picked_cache_cave_4_7_brass"), "real cache remains collected")
	check(
		GameState.has_flag(&"picked_cache_cave_4_7_pots"), "real cache provisions remain collected"
	)
	room = await enter(&"cave_4_1")
	var mouth := door_to(room, &"ow_9_2")
	player.place_at(mouth.global_position)
	await seconds(1)
	check_eq(world.get_current_room_id(), &"ow_9_2", "actual opened mouth returns to overworld")
	room = await enter(&"cave_4_10")
	check_eq(room.get_enemies().size(), 0, "defeated Colossus and natural shards stay absent")
	for reward in pickups(room):
		if reward.persistent_id in [&"frag_c4", &"wick_core_c4"]:
			check(not reward.visible, "collected persistent reward stays absent")
	check_eq(GameState.max_health, before["max"], "reentry cannot duplicate core")
	if OS.get_environment("WICK_C04_DISK") == "1":
		var safe := isolated_test_profile()
		check(safe, "disk proof requires isolated temporary userdata root")
		if safe:
			before = summary()
			SaveGame.enabled = true
			check(SaveGame.save(), "actual acquired route saves in isolated slot")
			reset_state()
			SaveGame.begin_new_game()
			check(
				(
					not GameState.has_item(&"heft_mitts")
					and not GameState.has_flag(&"boss_cave_4_10_defeated")
					and SaveGame.playtime == 0.0
				),
				"isolated reload starts from empty progress and cleared run record"
			)
			check(SaveGame.load_into_state(), "isolated disk slot reloads")
			check_near(
				SaveGame.playtime,
				before["playtime"],
				.000001,
				"isolated disk restores full elapsed playtime within JSON float precision"
			)
			before["playtime"] = SaveGame.playtime
			check_eq(summary(), before, "full route state survives actual disk roundtrip")
			SaveGame.enabled = false
	var maximum := GameState.max_health
	var before_death := summary()
	player.set_hurtbox_enabled(self, true)
	player.take_damage(99, player.global_position + Vector2(10, 0))
	for tick in range(400):
		await frames(1)
		if not player.is_dead() and not world.is_transitioning():
			break
	check_eq(world.get_current_room_id(), &"ow_9_2", "actual death returns to C04 mouth checkpoint")
	check_eq(GameState.health, maximum, "death restores full health")
	check(
		(
			SaveGame.playtime >= before_death["playtime"]
			and SaveGame.playtime < before_death["playtime"] + 7
		),
		"actual death keeps elapsed playtime and advances only during bounded respawn"
	)
	before_death["playtime"] = SaveGame.playtime
	before_death["health"] = maximum
	before_death["current_room"] = &"ow_9_2"
	check_eq(summary(), before_death, "actual death preserves complete acquired route state")
	for flag in [
		&"eye_e172",
		&"door_e173",
		&"moved_e175",
		&"door_e177",
		&"melted_e180",
		&"door_boss_c4",
		&"mini_cave_4_4",
		&"boss_cave_4_10_defeated",
		&"frag_c4"
	]:
		check(GameState.has_flag(flag), "death preserves real route flag " + String(flag))


func summary() -> Dictionary:
	var keys := {}
	for scope in GameState.KEY_SCOPES:
		keys[scope] = GameState.keys_in(scope)
	return {
		"keys": keys,
		"active_item": GameState.active_item,
		"visited": GameState.visited_rooms.duplicate(),
		"current_room": GameState.current_room,
		"playtime": SaveGame.playtime,
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
	if OS.get_environment("WICK_C04_CAPTURE") != "1":
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	check_eq(
		get_viewport().get_texture().get_image().save_png("/tmp/wick-c04-" + label + ".png"),
		OK,
		"actual capture " + label
	)


func swing_from(at: Vector2, direction: Vector2) -> void:
	player.place_at(at - direction * 90)
	player.facing = direction
	await frames(3)
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	await frames(14)
