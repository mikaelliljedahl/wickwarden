extends TestCase
## Integration: the whole step-1 route on the real room scenes, driven at the logic level.
##   tether moth (ow_0_1) -> light both cave braziers (gate opens) -> cave key (cave_1) ->
##   locked door (ow_2_1) -> pitch pot item (+6 pots) -> pitch pot blast opens the cracked wall
##   (ow_2_0) -> wick core (+1 max heart, full heal).
## The player is placed next to each target (the walking itself is covered by test_world and the
## reachability checks in test_dev_world); hook swings, pickups, door, gate, blast and flags are real.

var world: World
var player: Player


func run() -> void:
	reset_state()
	world = await make_world()
	player = world.player
	await _tether_moth()
	await _cave_gate_and_key()
	await _locked_door_and_pitch_pot()
	await _cracked_wall_and_core()
	await _persistence()
	await dispose(world)


## Enters a room instantly and removes its enemies, so nothing interferes with the scripted steps.
func _enter(room_id: StringName) -> Room:
	world.start_at(room_id)
	var room := world.get_room(room_id)
	for enemy in room.get_enemies():
		(enemy as EnemyBase).drops_enabled = false
		(enemy as EnemyBase).kill()
	await frames(3)
	return room


func _props(room: Room) -> Array[Node]:
	return room.get_node("Props").get_children()


func _pickup(room: Room, persistent_id: StringName) -> PickupBase:
	for node in _props(room):
		if node is PickupBase and (node as PickupBase).persistent_id == persistent_id:
			return node as PickupBase
	return null


func _find(room: Room, file: String) -> Node:
	for node in _props(room):
		var script: Script = node.get_script()
		if script != null and script.resource_path.ends_with(file):
			return node
	return null


## Stands the player 46 px south of a pickup, in front of its pedestal or wall, and lets it collect.
func _walk_onto(pickup: PickupBase) -> void:
	player.place_at(pickup.global_position + Vector2(0, 46))
	await frames(4)


func _swing_at(target: Vector2, facing: Vector2) -> void:
	player.place_at(target - facing * 70.0)
	player.facing = facing
	await frames(3)
	Input.action_press(&"attack")
	await frames(2)
	Input.action_release(&"attack")
	await frames(14)


func _tether_moth() -> void:
	var room := await _enter(&"ow_0_1")
	var moth := _pickup(room, &"tether_moth")
	check(moth != null, "ow_0_1 has the tether moth pickup")
	check(not GameState.has_item(&"tether_moth"), "the moth is not owned yet")
	await _walk_onto(moth)
	check(GameState.has_item(&"tether_moth"), "collecting it grants the tether moth")
	check(GameState.has_flag(&"picked_tether_moth"), "the pickup is remembered")
	check_eq(GameState.active_item, &"tether_moth", "the first item found becomes active")
	check_eq(GameState.pitch_pots, 0, "no pitch pots yet")


func _cave_gate_and_key() -> void:
	# In through the real door: the entrance in ow_1_1 fades into the cave.
	world.start_at(&"ow_1_1")
	var door := _find(world.get_room(&"ow_1_1"), "room_door.gd") as RoomDoor
	check(door != null and door.target_room == &"cave_1", "ow_1_1 has the cave entrance")
	player.place_at(door.global_position)
	await seconds(1.0)
	check_eq(world.get_current_room_id(), &"cave_1", "the entrance leads into the cave")
	var cave := world.get_room(&"cave_1")
	for enemy in cave.get_enemies():
		(enemy as EnemyBase).drops_enabled = false
		(enemy as EnemyBase).kill()
	await frames(3)
	var west := cave.get_node("Props/BrazierWest") as Brazier
	var east := cave.get_node("Props/BrazierEast") as Brazier
	var gate := cave.get_node("Props/Gate") as Gate
	var key := _pickup(cave, &"cave_key")
	check(not west.lit and not east.lit and not gate.is_open, "braziers unlit, gate closed")
	await _swing_at(west.global_position, Vector2.RIGHT * -1.0)
	check(west.lit, "a hook swing lights the west brazier")
	check(not east.lit and not gate.is_open, "one brazier is not enough")
	check(not GameState.has_flag(&"gate_cave_gate"), "the gate flag is not set yet")
	await _swing_at(east.global_position, Vector2.RIGHT)
	check(east.lit, "a hook swing lights the east brazier")
	check(gate.is_open, "both braziers lit: the gate opens")
	check(GameState.has_flag(&"gate_cave_gate"), "the gate flag is set")
	await frames(2)
	check((gate.get_child(0) as CollisionShape2D).disabled, "an open gate has no collision")
	check_eq(GameState.keys, 0, "no key yet")
	await _walk_onto(key)
	check_eq(GameState.keys, 1, "the key behind the gate is collected")
	check(GameState.has_flag(&"picked_cave_key"), "the key pickup is remembered")


func _locked_door_and_pitch_pot() -> void:
	var room := await _enter(&"ow_2_1")
	var door := _find(room, "locked_door.gd") as LockedDoor
	var pot := _pickup(room, &"pitch_pot")
	check(door != null and not door.is_open, "the locked door starts closed")
	check_eq(GameState.keys, 1, "the player carries the cave key")
	player.place_at(door.global_position + Vector2(0, -70))
	await frames(4)
	check(door.is_open, "touching the door with a key opens it")
	check_eq(GameState.keys, 0, "the key is spent")
	check(GameState.has_flag(&"door_ow_2_1_pitch"), "the door flag is set")
	check(not GameState.has_item(&"pitch_pot"), "the pitch pot is not owned yet")
	await _walk_onto(pot)
	check(GameState.has_item(&"pitch_pot"), "the pitch pot item is collected")
	check_eq(
		GameState.pitch_pots,
		PickupBase.ITEM_FOUND_AMMO[&"pitch_pot"],
		"finding the pitch pot grants its starting ammo"
	)
	check_eq(GameState.pitch_pots, 6, "that is 6 pitch pots")
	check_eq(GameState.active_item, &"tether_moth", "the active item is still the moth")
	GameState.set_active_item(&"pitch_pot")


func _cracked_wall_and_core() -> void:
	var room := await _enter(&"ow_2_0")
	var wall: Node = null
	for node in _props(room):
		if node.is_in_group(&"explodable"):
			wall = node
	var core := _pickup(room, &"wick_core_cache")
	check(wall != null and not wall.get("is_open"), "the cracked wall starts closed")
	check(core != null, "the cache holds a wick core")
	check_eq(GameState.max_health, 6, "three hearts before the core")
	# Stand south of the wall, facing it, and place a pot (it lands one tile in front).
	player.place_at(wall.global_position + Vector2(0, 48 + 26 + 8))
	player.facing = Vector2.UP
	await frames(3)
	check(player.use_item(), "a pitch pot is placed")
	check_eq(GameState.pitch_pots, 5, "it costs one pitch pot")
	await seconds(1.5)
	check(not wall.get("is_open"), "the fuse is still burning at 1.5 s")
	await seconds(0.4)
	check(wall.get("is_open"), "the blast opens the cracked wall")
	check(GameState.has_flag(&"cracked_ow_2_0_cache"), "the wall flag is set")
	check_eq(GameState.health, 4, "the blast cost the player one heart")
	check((wall.get_node("Shape") as CollisionShape2D).disabled, "the opened wall has no collision")
	await _walk_onto(core)
	check_eq(GameState.max_health, 8, "the wick core adds a max heart")
	check_eq(GameState.health, 8, "and heals fully")
	check(GameState.has_flag(&"picked_wick_core_cache"), "the core pickup is remembered")


## Re-entering rooms keeps what was done: opened wall and door stay open, pickups stay gone.
func _persistence() -> void:
	var ruin := await _enter(&"ow_2_0")
	var wall: Node = null
	for node in _props(ruin):
		if node.is_in_group(&"explodable") or (node.get_script() != null and node.get("wall_id") != null):
			wall = node
	check(wall != null and wall.get("is_open"), "an opened cracked wall stays open")
	await frames(2)
	check(_pickup(ruin, &"wick_core_cache") == null, "the collected core is gone")
	var dead_end := await _enter(&"ow_2_1")
	check((_find(dead_end, "locked_door.gd") as LockedDoor).is_open, "an opened door stays open")
	check(_pickup(dead_end, &"pitch_pot") == null, "the collected pitch pot item is gone")
	var cave := await _enter(&"cave_1")
	check((cave.get_node("Props/Gate") as Gate).is_open, "the cave gate stays open")
	check(
		(cave.get_node("Props/BrazierWest") as Brazier).lit and (cave.get_node("Props/BrazierEast") as Brazier).lit,
		"the braziers stay lit"
	)
	var moth_room := await _enter(&"ow_0_1")
	check(_pickup(moth_room, &"tether_moth") == null, "the collected moth pickup is gone")
