extends TestCase
## Reed raft (T03), fixed lane. Boarding within 72 px of a mooring post (refused away from one, or when the target post
## is not in the tree); the boarding stands Tamsin still with actions locked; the ride follows the post's lane at
## 240 px/s with the hurtbox on; the raft follows Tamsin; it survives the World's room-change sweep across a room edge;
## arrival, death and place_at end it. Also the deep water zone (water_zone.gd): geometry, the WATER blocker, groups.

const ZONE_SCENE := "res://scenes/world/water_zone.tscn"
const MOORING_SCENE := "res://scenes/world/mooring.tscn"
const MOORING_SCRIPT := "res://scripts/world/mooring.gd"
const FIXTURE_SCENE := "res://tests/fixtures/gallery/T03.tscn"
const ZONE_CENTRE := Vector2(600, 400)
const ZONE_SIZE := Vector2(192, 96)
const ROOM_W := 1920.0
const LANE_Y := 420.0


func run() -> void:
	await _geometry()
	await _deep_has_blocker()
	await _shallow_has_no_blocker()
	await _groups_and_scene()
	await _scene_registry_and_look()
	await _refused_away_from_mooring()
	await _refused_without_target()
	await _boards_and_rides_lane()
	await _raft_follows_and_hurtbox_on()
	await _one_at_a_time_and_no_use_while_riding()
	await _survives_room_edge_sweep()
	await _death_ends_ride()
	await _death_while_boarding_frees_raft()
	await _room_fixture()
	await _free_steering_controls()
	await _free_union_and_push()
	await _free_combat()
	await _free_cleanup()
	await _free_room_slide()
	await _free_auto_dock()


func _make_zone(parent: Node, deep: bool) -> Area2D:
	var scene := load(ZONE_SCENE) as PackedScene
	var zone := scene.instantiate() as Area2D
	zone.set(&"size", ZONE_SIZE)
	zone.set(&"deep", deep)
	parent.add_child(zone)
	zone.global_position = ZONE_CENTRE
	return zone


## Two Room nodes side by side (grid (0, 0) and (1, 0)), no walls, in the test tree.
func _make_rooms() -> Array[Room]:
	var rooms: Array[Room] = []
	for grid in [Vector2i(0, 0), Vector2i(1, 0)]:
		var room := Room.new()
		room.room_id = &"t03_a" if grid.x == 0 else &"t03_b"
		room.grid = grid
		room.build_walls = false
		add_child(room)
		rooms.append(room)
	return rooms


## A mooring post in `parent` (a Room, so it knows its room) with its target.
func _make_post(
	parent: Node, id: StringName, target_room: StringName, target: StringName, at: Vector2
) -> Variant:
	var scene := load(MOORING_SCENE) as PackedScene
	var post: Node2D = scene.instantiate()
	post.set(&"mooring_id", id)
	post.set(&"target_room", target_room)
	post.set(&"target_mooring", target)
	parent.add_child(post)
	post.global_position = at
	return post


func _give_raft(player: Player) -> void:
	GameState.acquire_item(&"reed_raft")
	GameState.set_active_item(&"reed_raft")
	player.facing = Vector2.RIGHT


func _rafts() -> Array:
	return get_tree().get_nodes_in_group(ItemBase.group_name(&"reed_raft"))


## Waits until the motion ends or `limit` seconds pass. Returns true when it ended.
func _wait_for_end(player: Player, limit: float) -> bool:
	var frames_left := int(limit * FPS)
	while frames_left > 0 and player.is_external_motion():
		await frames(1)
		frames_left -= 1
	return not player.is_external_motion()


func _geometry() -> void:
	reset_state()
	var arena := make_arena()
	var zone := _make_zone(arena, true)
	await frames(2)
	check(zone.call(&"contains_point", ZONE_CENTRE), "the centre is inside the water zone")
	check(
		zone.call(&"contains_point", ZONE_CENTRE + ZONE_SIZE * 0.5), "the corner counts as inside"
	)
	check(
		not zone.call(&"contains_point", ZONE_CENTRE + Vector2(120, 0)),
		"a point east of the zone is outside"
	)
	check_eq(
		zone.call(&"nearest_point", ZONE_CENTRE + Vector2(300, 0)),
		ZONE_CENTRE + Vector2(ZONE_SIZE.x * 0.5, 0),
		"the nearest point to a point east of the zone is on its east edge"
	)
	check_eq(
		zone.call(&"nearest_point", ZONE_CENTRE),
		ZONE_CENTRE,
		"the nearest point to an inside point is the point itself"
	)
	await dispose(arena)


func _deep_has_blocker() -> void:
	reset_state()
	var arena := make_arena()
	var zone := _make_zone(arena, true)
	await frames(2)
	var blocker := zone.get_node_or_null("Blocker") as StaticBody2D
	check(blocker != null, "a deep zone has a blocking body")
	if blocker != null:
		check_eq(blocker.collision_layer, Layers.WATER, "the blocker is on layer WATER")
		var shape := blocker.get_node("Shape") as CollisionShape2D
		check_eq(
			(shape.shape as RectangleShape2D).size, ZONE_SIZE, "the blocker covers the footprint"
		)
	var enemy := make_dummy(arena, ZONE_CENTRE + Vector2(0, 300))
	await frames(2)
	check(enemy.collision_mask & Layers.WATER != 0, "ground enemies collide with WATER")
	await dispose(arena)


func _shallow_has_no_blocker() -> void:
	reset_state()
	var arena := make_arena()
	var zone := _make_zone(arena, false)
	await frames(2)
	check(zone.get_node_or_null("Blocker") == null, "a shallow zone has no blocking body")
	await dispose(arena)


func _groups_and_scene() -> void:
	reset_state()
	var arena := make_arena()
	var deep := _make_zone(arena, true)
	var shallow := _make_zone(arena, false)
	await frames(2)
	for zone in [deep, shallow]:
		check(zone.is_in_group(&"water_zone"), "a water zone is in group water_zone")
		check(
			zone.is_in_group(&"shallows"), "a water zone is in group shallows (leeches live in it)"
		)
	check(Placeholder.has_kind(&"deep_water"), "the deep water look is registered")
	await dispose(arena)


func _scene_registry_and_look() -> void:
	reset_state()
	var scene := load("res://scenes/items/reed_raft.tscn") as PackedScene
	check(scene != null, "the reed raft scene loads")
	var item := ItemRegistry.create(&"reed_raft")
	check(item != null, "the registry creates the reed raft")
	if item != null:
		check(item.item_id == &"reed_raft", "the raft's item id is reed_raft")
		item.free()
	var script = load(MOORING_SCRIPT)
	check_near(script.RIDE_SPEED, 240.0, 0.01, "the raft rides at 240 px/s (as the mooring file)")
	var raft := scene.instantiate()
	add_child(raft)
	check(raft.get_node_or_null(Placeholder.VISUAL_NAME) != null, "the raft has a Visual child")
	check(Placeholder.has_kind(&"reed_raft"), "the raft look is registered")
	raft.free()


## Stands 200 px from a post with a target: no raft, nothing spent, no motion.
func _refused_away_from_mooring() -> void:
	reset_state()
	var rooms := _make_rooms()
	_make_post(rooms[0], &"west", &"t03_a", &"east", Vector2(400, LANE_Y))
	_make_post(rooms[0], &"east", &"t03_a", &"west", Vector2(1000, LANE_Y))
	var arena := make_arena()
	var player := make_player(arena, Vector2(600, LANE_Y))
	await frames(2)
	_give_raft(player)
	check(not player.use_item(), "the raft is refused 200 px from a mooring")
	check(_rafts().is_empty(), "a refused raft is not kept in the tree")
	check(not player.is_external_motion(), "a refused raft does not start a ride")
	await dispose(arena)
	for room in rooms:
		await dispose(room)


## A post in range with no target in the tree: the lane is empty, so the raft is refused.
func _refused_without_target() -> void:
	reset_state()
	var rooms := _make_rooms()
	var post: Variant = _make_post(rooms[0], &"lonely", &"t03_b", &"nowhere", Vector2(400, LANE_Y))
	var arena := make_arena()
	var player := make_player(arena, post.landing_position())
	await frames(2)
	_give_raft(player)
	check(not player.use_item(), "the raft is refused at a post whose target is not in the tree")
	check(not player.is_external_motion(), "no ride without a target")
	await dispose(arena)
	for room in rooms:
		await dispose(room)


## Within one room: boards at the landing, stands still with actions locked, rides the arc at 240 px/s with the
## hurtbox on, arrives on the target's landing and the raft is gone.
func _boards_and_rides_lane() -> void:
	reset_state()
	var rooms := _make_rooms()
	var west: Variant = _make_post(rooms[0], &"west", &"t03_a", &"east", Vector2(400, LANE_Y))
	var east: Variant = _make_post(rooms[0], &"east", &"t03_a", &"west", Vector2(1000, LANE_Y))
	var arena := make_arena()
	var player := make_player(arena, west.landing_position())
	await frames(2)
	_give_raft(player)
	check(player.use_item(), "the raft boards at the landing")
	check_eq(_rafts().size(), 1, "one raft is in the tree while boarding")
	check(player.actions_locked(), "boarding locks the actions")
	check(not player.is_external_motion(), "boarding does not start the ride yet")
	await seconds(0.2)
	check(not player.is_external_motion(), "still boarding at 0.2 s")
	await seconds(0.3)
	check(player.is_external_motion(), "the ride starts after the boarding")
	check(not player.actions_locked(), "the ride hands the actions back to the motion")
	check(player.hurtbox.enabled, "the hurtbox stays on during the raft ride")
	await frames(10)
	check_near(player.velocity.length(), 240.0, 0.5, "the ride moves at 240 px/s")
	check(await _wait_for_end(player, 15.0), "the ride ends")
	check(
		player.global_position.is_equal_approx(east.landing_position()),
		"the ride ends on the target landing"
	)
	await frames(2)
	check(_rafts().is_empty(), "the raft is gone after the arrival")
	await dispose(arena)
	for room in rooms:
		await dispose(room)


func _raft_follows_and_hurtbox_on() -> void:
	reset_state()
	var rooms := _make_rooms()
	var west: Variant = _make_post(rooms[0], &"west", &"t03_a", &"east", Vector2(400, LANE_Y))
	_make_post(rooms[0], &"east", &"t03_a", &"west", Vector2(1000, LANE_Y))
	var arena := make_arena()
	var player := make_player(arena, west.landing_position())
	await frames(2)
	_give_raft(player)
	player.use_item()
	await seconds(1.0)
	var rafts := _rafts()
	check_eq(rafts.size(), 1, "the raft is in the tree during the ride")
	if not rafts.is_empty():
		check(
			(rafts[0] as Node2D).global_position.distance_to(player.global_position) < 1.0,
			"the raft follows Tamsin"
		)
	check(player.is_external_motion(), "the ride is still on after one second")
	player.end_external_motion()
	await frames(2)
	check(_rafts().is_empty(), "ending the ride frees the raft")
	await dispose(arena)
	for room in rooms:
		await dispose(room)


func _one_at_a_time_and_no_use_while_riding() -> void:
	reset_state()
	var rooms := _make_rooms()
	var west: Variant = _make_post(rooms[0], &"west", &"t03_a", &"east", Vector2(400, LANE_Y))
	_make_post(rooms[0], &"east", &"t03_a", &"west", Vector2(1000, LANE_Y))
	var arena := make_arena()
	var player := make_player(arena, west.landing_position())
	await frames(2)
	_give_raft(player)
	check(player.use_item(), "the first raft boards")
	check(not player.use_item(), "a second raft is refused while one is in the tree")
	await seconds(0.5)
	check(player.is_external_motion(), "riding")
	check(not player.use_item(), "no item use while riding")
	player.end_external_motion()
	await dispose(arena)
	for room in rooms:
		await dispose(room)


## A ride from room A across the edge into room B. The World's room-change sweep frees group `items` at the edge;
## the raft is not in that group while it rides, so it survives and the ride ends on the far post.
func _survives_room_edge_sweep() -> void:
	reset_state()
	var rooms := _make_rooms()
	var west: Variant = _make_post(rooms[0], &"west", &"t03_b", &"east", Vector2(1500, LANE_Y))
	var east: Variant = _make_post(
		rooms[1], &"east", &"t03_a", &"west", Vector2(ROOM_W + 300, LANE_Y)
	)
	var arena := make_arena()
	var player := make_player(arena, west.landing_position())
	await frames(2)
	_give_raft(player)
	check(player.use_item(), "the raft boards in room A")
	await seconds(0.4)
	var crossed := false
	var frames_left := int(15.0 * FPS)
	while frames_left > 0 and player.is_external_motion() and not crossed:
		await frames(1)
		frames_left -= 1
		crossed = player.global_position.x > ROOM_W
	check(crossed, "the ride crosses the edge into room B")
	for node in get_tree().get_nodes_in_group(&"items"):
		node.queue_free()  # what World._clear_transients does on a slide
	await frames(2)
	var rafts := _rafts()
	check_eq(rafts.size(), 1, "the raft survives the room-change sweep")
	check(player.is_external_motion(), "the ride goes on after the sweep")
	check(await _wait_for_end(player, 15.0), "the ride ends in room B")
	check(
		player.global_position.is_equal_approx(east.landing_position()), "it lands on the far post"
	)
	await frames(2)
	check(_rafts().is_empty(), "the raft is gone after the arrival")
	await dispose(arena)
	for room in rooms:
		await dispose(room)


## Lethal damage during the ride: the motion ends, the raft is freed and the player is dead.
func _death_ends_ride() -> void:
	reset_state()
	var rooms := _make_rooms()
	var west: Variant = _make_post(rooms[0], &"west", &"t03_a", &"east", Vector2(400, LANE_Y))
	_make_post(rooms[0], &"east", &"t03_a", &"west", Vector2(1000, LANE_Y))
	var arena := make_arena()
	var player := make_player(arena, west.landing_position())
	await frames(2)
	_give_raft(player)
	player.use_item()
	await seconds(0.8)
	check(player.is_external_motion(), "riding before the death")
	player.take_damage(6, player.global_position + Vector2(10, 0))
	check(player.is_dead(), "the player dies on the raft")
	check(not player.is_external_motion(), "death ends the ride")
	await frames(2)
	check(_rafts().is_empty(), "death frees the raft")
	await dispose(arena)
	for room in rooms:
		await dispose(room)


## Death while Tamsin is still boarding: the raft ends and the action lock is given back.
func _death_while_boarding_frees_raft() -> void:
	reset_state()
	var rooms := _make_rooms()
	var west: Variant = _make_post(rooms[0], &"west", &"t03_a", &"east", Vector2(400, LANE_Y))
	_make_post(rooms[0], &"east", &"t03_a", &"west", Vector2(1000, LANE_Y))
	var arena := make_arena()
	var player := make_player(arena, west.landing_position())
	await frames(2)
	_give_raft(player)
	player.use_item()
	await seconds(0.1)
	player.take_damage(6, player.global_position + Vector2(10, 0))
	await frames(2)
	check(_rafts().is_empty(), "death while boarding frees the raft")
	check(not player.actions_locked(), "death while boarding gives the action lock back")
	check(not player.is_external_motion(), "no ride starts after a death")
	await dispose(arena)
	for room in rooms:
		await dispose(room)


func _room_fixture() -> void:
	reset_state()
	var scene := load(FIXTURE_SCENE) as PackedScene
	check(scene != null, "the T03 gallery fixture loads")
	if scene == null:
		return
	var room := scene.instantiate()
	add_child(room)
	await frames(2)
	check(room.get_node_or_null("Props/WestMooring") != null, "the fixture has the west post")
	check(room.get_node_or_null("Props/EastMooring") != null, "the fixture has the east post")
	await dispose(room)


## Single-dock basin, with no paired target: free steering must not need a lane.
func _free_basin() -> Array:
	reset_state()
	var arena := make_arena()
	var zone := _make_zone(arena, true)
	zone.size = Vector2(600, 600)
	zone.global_position = Vector2(700, 500)
	zone.raft_free_steering = true
	var post: Variant = _make_post(arena, &"dock", &"", &"", Vector2(368, 400))
	var hero := make_player(arena, post.landing_position())
	await frames(2)
	_give_raft(hero)
	check(hero.use_item(), "a single dock boards free water without a paired target")
	await seconds(0.2)
	check(not hero.is_on_raft(), "free boarding takes at least 0.3 seconds")
	await seconds(0.2)
	check(hero.is_on_raft(), "free boarding enters raft rider state")
	check(hero.is_external_motion(), "raft is an external motion")
	check(hero.hurtbox.enabled, "free rider hurtbox is on")
	var body := hero.get_node("BodyShape") as CollisionShape2D
	check(body.disabled, "free rider body is off")
	return [arena, hero, zone, post]


func _free_steering_controls() -> void:
	var setup := await _free_basin()
	var hero: Player = setup[1]
	Input.action_press(&"move_right")
	await frames(6)
	check_near(hero.velocity.x, 120.0, 21.0, "raft accelerates halfway in 0.1 seconds")
	await frames(8)
	check_near(hero.velocity.length(), 240.0, 1.0, "raft reaches 240 in 0.2 seconds")
	Input.action_press(&"move_down")
	await frames(15)
	check_near(hero.velocity.length(), 240.0, 1.0, "diagonal raft speed is normalized")
	release_inputs()
	await frames(12)
	check_near(hero.velocity.length(), 120.0, 12.0, "raft brakes halfway in 0.2 seconds")
	await frames(14)
	check_near(hero.velocity.length(), 0.0, 1.0, "raft stops within 0.4 seconds")
	GameState.set_active_item(&"tether_moth")
	check(not hero.use_item(), "other tools cannot spawn afloat away from a dock")
	check(hero.is_on_raft(), "refused use leaves the rider afloat")
	hero.global_position = Vector2(440, 400)
	check(hero.use_item(), "use_item docks within 80 even with another selected tool")
	check_eq(hero.global_position, setup[3].landing_position(), "dock uses public landing marker")
	await frames(2)
	check(not hero.is_on_raft(), "docking clears raft query")
	check(not (hero.get_node("BodyShape") as CollisionShape2D).disabled, "dock restores body")
	await dispose(setup[0])


func _free_union_and_push() -> void:
	var setup := await _free_basin()
	var arena: Node = setup[0]
	var hero: Player = setup[1]
	var zone: Node2D = setup[2]
	var second := _make_zone(arena, true)
	second.size = Vector2(200, 600)
	second.global_position = Vector2(1100, 500)
	var island := _make_zone(arena, true)
	island.size = Vector2(200, 600)
	island.global_position = Vector2(1400, 500)
	await frames(2)
	hero.global_position = Vector2(950, 500)
	check(hero.push_raft(Vector2(150, 0)), "raft accepts queued displacement")
	check_near(hero.global_position.x, 950, 0.01, "push waits for physics")
	await frames(2)
	check_near(hero.global_position.x, 1100, 0.01, "push crosses touching water seam")
	var shallow_bridge := _make_zone(arena, false)
	shallow_bridge.size = Vector2(100, 600)
	shallow_bridge.global_position = Vector2(1250, 500)
	await frames(2)
	hero.push_raft(Vector2(300, 0))
	await frames(2)
	check_near(
		hero.global_position.x,
		1200,
		0.01,
		"shallow water does not bridge disconnected deep-water gap"
	)
	second.global_position.x += 1.0
	hero.global_position = Vector2(950, 500)
	hero.push_raft(Vector2(150, 0))
	await frames(2)
	check_near(hero.global_position.x, 1000, 0.01, "even a one-pixel land gap stops sweep")
	hero.global_position = Vector2(700, 500)
	var before := hero.global_position
	check(hero.take_damage(1, before - Vector2(20, 0)), "ordinary hit is accepted afloat")
	check(not hero.take_damage(1, before - Vector2(20, 0)), "iframes reject duplicate hit")
	await frames(2)
	check_near(hero.global_position.x - before.x, 96, 0.01, "accepted hit pushes exactly96 once")
	for i in range(30):
		hero.push_raft(Vector2(0, 200.0 / FPS))
		await frames(1)
	check_near(hero.global_position.y - before.y, 100, 4, "sustained200 push integrates time")
	check(zone.contains_point(hero.global_position), "all displacement stays in water")
	await dispose(arena)


func _free_combat() -> void:
	var setup := await _free_basin()
	var arena: Node = setup[0]
	var hero: Player = setup[1]
	hero.global_position = Vector2(700, 500)
	hero.facing = Vector2.RIGHT
	var front := make_dummy(arena, Vector2(790, 500), 12)
	front.collision_mask = 0
	await frames(2)
	Input.action_press(&"attack")
	await frames(6)
	check_eq(front.hp, 10, "real afloat hook hit deals full2 damage")
	await seconds(0.9)
	check(hero.charge_ready, "real held attack charges afloat")
	var west := make_dummy(arena, Vector2(580, 500), 8)
	west.collision_mask = 0
	await frames(2)
	Input.action_release(&"attack")
	await frames(8)
	check_eq(west.hp, 4, "real afloat flare hits behind for full4 damage")
	await seconds(0.4)
	Input.action_press(&"ward")
	await frames(2)
	check(hero.ward_up, "ward raises afloat")
	var bolt := EnemyProjectile.fire(arena, hero.global_position + Vector2(150, 0), Vector2.LEFT)
	await frames(50)
	check(not is_instance_valid(bolt) or bolt.is_destroyed, "afloat ward stops actual projectile")
	check_eq(GameState.health, 6, "ward block causes no rider damage")
	check_eq(hero.global_position, Vector2(700, 500), "blocked shot causes no96 push")
	release_inputs()
	EnemyProjectile.fire(arena, hero.global_position - Vector2(150, 0), Vector2.RIGHT)
	await frames(50)
	check_eq(GameState.health, 5, "actual unwarded projectile damages afloat rider")
	check_near(hero.global_position.x, 796, 0.01, "actual projectile triggers exactly96 raft push")
	await dispose(arena)


func _free_cleanup() -> void:
	var setup := await _free_basin()
	var hero: Player = setup[1]
	hero.global_position = Vector2(700, 500)
	hero.take_damage(6, Vector2(650, 500))
	await frames(2)
	check(hero.is_dead() and not hero.is_on_raft(), "death clears raft state")
	check(_rafts().is_empty(), "death frees vehicle")
	check(not hero.push_raft(Vector2(96, 0)), "dead/off-raft push is refused")
	await dispose(setup[0])
	setup = await _free_basin()
	hero = setup[1]
	hero.place_at(Vector2(300, 500))
	await frames(2)
	check(not hero.is_external_motion() and _rafts().is_empty(), "teleport cleans raft state")
	check(not (hero.get_node("BodyShape") as CollisionShape2D).disabled, "teleport restores body")
	await dispose(setup[0])
	setup = await _free_basin()
	hero = setup[1]
	_rafts()[0].queue_free()
	await frames(3)
	check(not hero.is_external_motion(), "freeing vehicle restores player motion state")
	check(
		not (hero.get_node("BodyShape") as CollisionShape2D).disabled,
		"freeing vehicle restores body"
	)
	await dispose(setup[0])


## Use two real World rooms, replacing no gates or world transition code.
func _free_room_slide() -> void:
	reset_state()
	var world := await make_world()
	world.start_at(&"ow_0_0")
	await frames(2)
	for id in [&"ow_0_0", &"ow_1_0"]:
		var room := world.get_room(id)
		var water := _make_zone(room.get_node("Props"), true)
		water.size = Vector2(1920, 300)
		water.position = Vector2(960, 480)
		water.raft_free_steering = true
	var room := world.get_room(&"ow_0_0")
	var post: Variant = _make_post(room.get_node("Props"), &"free", &"", &"", Vector2(1750, 480))
	world.player.place_at(post.landing_position())
	_give_raft(world.player)
	await frames(2)
	check(world.player.use_item(), "free raft boards in actual World")
	await seconds(0.4)
	Input.action_press(&"move_right")
	await seconds(1.0)
	check(world.is_transitioning(), "free rider triggers existing room slide")
	check(world.player.is_on_raft(), "slide retains free rider state")
	await seconds(0.8)
	check_eq(world.current_room.room_id, &"ow_1_0", "free raft crosses into next room")
	check(world.player.is_on_raft(), "free raft survives transient sweep and room slide")
	check(world.player.velocity.x > 200.0, "free steering resumes after room slide")
	release_inputs()
	world.player.end_external_motion()
	await dispose(world)


func _free_auto_dock() -> void:
	var setup := await _free_basin()
	var hero: Player = setup[1]
	Input.action_press(&"move_right")
	await frames(35)
	check(hero.is_on_raft(), "source dock does not immediately auto-land at launch")
	Input.action_release(&"move_right")
	Input.action_press(&"move_left")
	for i in range(70):
		await frames(1)
		if not hero.is_on_raft():
			break
	release_inputs()
	check(not hero.is_on_raft(), "returning into source dock automatically lands")
	check_eq(hero.global_position, setup[3].landing_position(), "auto dock lands on shore marker")
	await dispose(setup[0])
