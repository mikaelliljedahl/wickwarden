extends TestCase
## The seven dev-world rooms (plan section 2): contents per room, and layout sanity on the REAL
## room scenes: no entity on an obstacle, exits clear, everything reachable on the 96 px tile grid
## while the cracked wall / gate / locked door are closed, sealed spots only reachable once open.
## Also the dev-mode loadout and the hitbox overlay toggle.

const TILE := 96.0
const COLS := 20
const ROWS := 10
## Tiles that must stay clear in front of an exit gap (the player enters 1 tile inside).
const EXIT_DEPTH := 3

## room id -> {scene path -> count} of placed enemies.
const ENEMIES := {
	&"ow_0_0": {"spitcap": 2},
	&"ow_1_0": {"skitterwick": 3},
	&"ow_2_0": {"hollow": 2},
	&"ow_0_1": {"duskmoth": 4},
	&"ow_1_1": {"tallow_blob": 2, "spitcap": 1},
	&"ow_2_1": {},
	&"cave_1": {"hollow": 3},
}
## Placed pickups that sit behind something (unreachable until it opens): persistent id.
const SEALED := [&"wick_core_cache", &"cave_key", &"pitch_pot"]


func run() -> void:
	reset_state()
	var world := await make_world()
	_room_contents(world)
	for id in ENEMIES:
		await _layout(world, id)
	for id in ENEMIES:
		await _soak(world, id)
	_dev_loadout(world)
	await dispose(world)


# ---- contents ---------------------------------------------------------------------------------


func _props(room: Room) -> Array[Node]:
	return room.get_node("Props").get_children()


func _pickups(room: Room, kind: StringName) -> Array[Node]:
	return _props(room).filter(
		func(n: Node) -> bool: return n is PickupBase and (n as PickupBase).kind == kind
	)


func _by_script(room: Room, file: String) -> Array[Node]:
	return _props(room).filter(
		func(n: Node) -> bool:
			return n.get_script() != null and n.get_script().resource_path.ends_with(file)
	)


func _count_enemies(room: Room) -> Dictionary:
	var counts := {}
	for enemy in room.get_enemies():
		var key := String(enemy.scene_file_path.get_file().get_basename())
		counts[key] = int(counts.get(key, 0)) + 1
	return counts


func _room_contents(world: World) -> void:
	for id in ENEMIES:
		world.start_at(id)
		check_eq(_count_enemies(world.get_room(id)), ENEMIES[id], "%s enemies match the plan" % id)
	var moth_room := world.get_room(&"ow_0_1")
	var moth := _pickups(moth_room, &"item")
	check_eq(moth.size(), 1, "ow_0_1 has one item pickup")
	if moth.size() == 1:
		check_eq((moth[0] as PickupBase).item_id, &"tether_moth", "it is the tether moth")
	check_eq(_by_script(moth_room, "solid_block.gd").any(
		func(n: Node) -> bool: return (n as SolidBlock).kind == &"pedestal"
	), true, "the tether moth lies on a pedestal")
	var ruin := world.get_room(&"ow_2_0")
	check_eq(_props(ruin).filter(func(n: Node) -> bool: return n.is_in_group(&"explodable")).size(), 1,
		"ow_2_0 has one cracked wall")
	check_eq(_pickups(ruin, &"wick_core").size(), 1, "the secret cache holds a wick core")
	var dead_end := world.get_room(&"ow_2_1")
	check_eq(_by_script(dead_end, "locked_door.gd").size(), 1, "ow_2_1 has a locked door")
	var pot := _pickups(dead_end, &"item")
	check_eq(pot.size(), 1, "ow_2_1 has one item pickup")
	if pot.size() == 1:
		check_eq((pot[0] as PickupBase).item_id, &"pitch_pot", "it is the pitch pot")
	var cross := world.get_room(&"ow_1_1")
	var entrances := _by_script(cross, "room_door.gd").filter(
		func(n: Node) -> bool: return (n as RoomDoor).target_room == &"cave_1"
	)
	check_eq(entrances.size(), 1, "ow_1_1 has the cave entrance")
	var cave := world.get_room(&"cave_1")
	check_eq(_by_script(cave, "brazier.gd").size(), 2, "the cave has two braziers")
	check(_by_script(cave, "brazier.gd").all(func(n: Node) -> bool: return not (n as Brazier).lit),
		"both braziers start unlit")
	check_eq(_by_script(cave, "gate.gd").size(), 1, "the cave has a gate")
	check_eq(_pickups(cave, &"key").size(), 1, "the cave holds a key")
	check(cave.dark, "the cave is dark")
	check_eq(world.get_room(&"ow_0_0").get_node("Props").get_children().any(
		func(n: Node) -> bool: return n is SolidBlock and (n as SolidBlock).kind == &"sign_post"
	), true, "the start room has a sign post")


# ---- layout -----------------------------------------------------------------------------------


## Local rectangles of everything solid, split into permanent ones and ones that can open.
func _blockers(room: Room) -> Dictionary:
	var fixed: Array[Rect2] = []
	var openable: Array[Rect2] = []
	for r in room.wall_rects():
		fixed.append(r)
	for node in _props(room):
		if node is Brazier:
			fixed.append(Rect2(node.position - Vector2(32, 32), Vector2(64, 64)))
		elif node is SolidBlock:
			var block := node as SolidBlock
			fixed.append(Rect2(block.position - block.size * 0.5, block.size))
		elif node is LockedDoor or node is Gate or node.is_in_group(&"explodable"):
			var size: Vector2 = node.get("size")
			openable.append(Rect2(node.position - size * 0.5, size))
	for bush in room.get_node("Bushes").get_children():
		fixed.append(Rect2(bush.position - Vector2(34, 34), Vector2(68, 68)))
	return {"fixed": fixed, "openable": openable}


func _tile_of(p: Vector2) -> Vector2i:
	return Vector2i(clampi(int(p.x / TILE), 0, COLS - 1), clampi(int(p.y / TILE), 0, ROWS - 1))


func _blocked_tiles(rects: Array[Rect2]) -> Dictionary:
	var blocked := {}
	for r in rects:
		for c in range(COLS):
			for row in range(ROWS):
				if Rect2(c * TILE, row * TILE, TILE, TILE).grow(-4.0).intersects(r):
					blocked[Vector2i(c, row)] = true
	return blocked


func _flood(start: Array[Vector2i], blocked: Dictionary) -> Dictionary:
	var seen := {}
	var queue: Array[Vector2i] = []
	for s in start:
		if not blocked.has(s):
			seen[s] = true
			queue.append(s)
	while not queue.is_empty():
		var t: Vector2i = queue.pop_back()
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var n: Vector2i = t + d
			if n.x < 0 or n.y < 0 or n.x >= COLS or n.y >= ROWS:
				continue
			if seen.has(n) or blocked.has(n):
				continue
			seen[n] = true
			queue.append(n)
	return seen


func _reaches(seen: Dictionary, tile: Vector2i, allow_neighbour: bool) -> bool:
	if seen.has(tile):
		return true
	if allow_neighbour:
		for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			if seen.has(tile + d):
				return true
	return false


## Gap tiles in front of each exit, `EXIT_DEPTH` deep (the ring tile itself included).
func _exit_tiles(room: Room) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	for side in room.exits:
		for k in range(0, EXIT_DEPTH + 1):
			match side:
				&"n":
					tiles.append_array([Vector2i(9, k), Vector2i(10, k)])
				&"s":
					tiles.append_array([Vector2i(9, ROWS - 1 - k), Vector2i(10, ROWS - 1 - k)])
				&"w":
					tiles.append_array([Vector2i(k, 4), Vector2i(k, 5)])
				_:
					tiles.append_array([Vector2i(COLS - 1 - k, 4), Vector2i(COLS - 1 - k, 5)])
	return tiles


func _layout(world: World, id: StringName) -> void:
	world.start_at(id)
	await frames(2)
	var room := world.get_room(id)
	var both := _blockers(room)
	var fixed: Array[Rect2] = both["fixed"]
	var openable: Array[Rect2] = both["openable"]
	var closed := fixed.duplicate()
	closed.append_array(openable)
	var blocked_closed := _blocked_tiles(closed)
	var blocked_open := _blocked_tiles(fixed)
	# Exit corridors are free of obstacles.
	for t in _exit_tiles(room):
		check(not blocked_closed.has(t), "%s: exit tile %s is clear" % [id, t])
	# Everything must be reachable from the default spawn.
	var spawn_tile := _tile_of(room.get_spawn_position() - room.global_position)
	var starts: Array[Vector2i] = [spawn_tile]
	check(not blocked_closed.has(spawn_tile), "%s: the default spawn is not inside an obstacle" % id)
	var reach_closed := _flood(starts, blocked_closed)
	var reach_open := _flood(starts, blocked_open)
	for t in _exit_tiles(room):
		check(reach_closed.has(t), "%s: exit tile %s is reachable" % [id, t])
	# Enemies: on free tiles, reachable.
	for enemy in room.get_enemies():
		var tile := _tile_of(enemy.position)
		check(not blocked_closed.has(tile), "%s: %s does not start on an obstacle" % [id, enemy.name])
		check(reach_closed.has(tile), "%s: %s starts in the reachable area" % [id, enemy.name])
		check(
			not _in_any(enemy.position, (enemy as EnemyBase).body_radius, closed),
			"%s: %s does not overlap an obstacle" % [id, enemy.name]
		)
	# Pickups: the sealed ones need the opening, the others are reachable at once.
	for node in _props(room):
		if not node is PickupBase:
			continue
		var pickup := node as PickupBase
		var tile := _tile_of(pickup.position)
		var sealed: bool = SEALED.has(pickup.persistent_id)
		check_eq(
			_reaches(reach_closed, tile, true),
			not sealed,
			"%s: pickup %s is %s while closed" % [id, pickup.persistent_id, "sealed" if sealed else "reachable"]
		)
		check(
			_reaches(reach_open, tile, true),
			"%s: pickup %s is reachable once everything is open" % [id, pickup.persistent_id]
		)
	# Doors in the room (cave exit, cave entrance) are reachable.
	for node in _props(room):
		if node is RoomDoor:
			check(
				_reaches(reach_closed, _tile_of(node.position), true),
				"%s: room door %s is reachable" % [id, node.name]
			)


func _in_any(p: Vector2, radius: float, rects: Array[Rect2]) -> bool:
	for r in rects:
		if r.grow(radius - 1.0).has_point(p):
			return true
	return false


## Lets a room's enemies run for a few seconds: they stay in the room and never end up inside an obstacle.
func _soak(world: World, id: StringName) -> void:
	reset_state()
	world.start_at(id)
	var room := world.get_room(id)
	world.player.hurtbox.enabled = false
	await seconds(5.0)
	var both := _blockers(room)
	var closed: Array[Rect2] = both["fixed"]
	closed.append_array(both["openable"])
	var interior := room.interior_rect()
	for enemy in room.get_enemies():
		check(interior.grow(1.0).has_point(enemy.global_position), "%s: %s stays in the room" % [id, enemy.name])
		check(not _in_any(enemy.position, 0.0, closed), "%s: %s is not inside an obstacle" % [id, enemy.name])
	world.player.hurtbox.enabled = true


# ---- dev mode ---------------------------------------------------------------------------------


func _dev_loadout(world: World) -> void:
	reset_state()
	check(not world.dev_mode, "a normal run is not in dev mode")
	world.apply_dev_loadout()
	check(GameState.has_item(&"tether_moth") and GameState.has_item(&"pitch_pot"), "dev: all sub-items")
	check_eq(GameState.pitch_pots, 10, "dev: 10 pitch pots")
	for scope in GameState.KEY_SCOPES:
		check_eq(GameState.keys_in(scope), 5, "dev: 5 keys in scope %s" % scope)
	check(not world.debug_overlay.visible, "the hitbox overlay starts hidden")
	world.set_debug_draw(true)
	check(world.debug_overlay.visible, "set_debug_draw shows the hitbox overlay")
	await frames(3)
	world.set_debug_draw(false)
	check(not world.debug_overlay.visible, "and hides it again")
