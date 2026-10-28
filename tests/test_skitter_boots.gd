extends TestCase
## Skitter boots (T07): a 192 px leap in the facing direction through the motion API. It crosses a pit zone
## (the landing is safe), stops short of a wall and never lands inside one, passes a low rail (group `leapable`),
## ignores damage in the air (hurtbox off), refuses while locked or in a motion or cooldown, and spends nothing
## when refused. The scene loads, is registered and the gallery fixture works.

const ITEM_SCENE := "res://scenes/items/skitter_boots.tscn"
const PIT_SCENE := "res://scenes/world/pit.tscn"
const FIXTURE_SCENE := "res://tests/fixtures/gallery/T07.tscn"
const PIT_CENTRE := Vector2(600, 500)
const PIT_WIDTH := 120.0
## A 120 px gap: the start must be outside the pit grown by the body radius (x < 514) and the landing inside
## the far side (x > 686). 500 is a start that clears the pit and lands at 692.
const LEAP_START := Vector2(500, 500)
const LEAP_LANDING_X := 692.0


func run() -> void:
	await _dust_lifecycle()
	await _leap_crosses_pit()
	await _landing_in_pit_falls()
	await _stops_at_wall()
	await _passes_rail()
	await _damage_ignored_in_air()
	await _refused_when_locked()
	await _cooldown_and_one_at_a_time()
	await _refused_next_to_wall()
	await _leap_follows_facing()
	await _scene_and_registry()
	await _room_fixture()


func _boots() -> Array:
	return get_tree().get_nodes_in_group(ItemBase.group_name(&"skitter_boots"))


func _make_pit(parent: Node, at: Vector2) -> Node2D:
	var scene := load(PIT_SCENE) as PackedScene
	var pit := scene.instantiate() as Node2D
	pit.set("size", Vector2(PIT_WIDTH, 192.0))
	parent.add_child(pit)
	pit.global_position = at
	return pit


func _make_rail(parent: Node, rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = Layers.WORLD
	body.collision_mask = 0
	body.add_to_group(&"leapable")
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var node := CollisionShape2D.new()
	node.shape = shape
	body.add_child(node)
	body.position = rect.get_center()
	parent.add_child(body)


## Gives the boots as the active item and turns the player to `dir` (default right).
func _give_boots(player: Player, dir: Vector2 = Vector2.RIGHT) -> void:
	GameState.acquire_item(&"skitter_boots")
	GameState.set_active_item(&"skitter_boots")
	player.facing = dir


func _leap_crosses_pit() -> void:
	reset_state()
	var arena := make_arena()
	_make_pit(arena, PIT_CENTRE)
	var player := make_player(arena, LEAP_START)
	await frames(2)
	_give_boots(player)
	var health := GameState.health
	check(player.use_item(), "the boots leap")
	await frames(18)  # about 144 px into the 192 px leap: over the middle of the pit
	check(player.is_airborne(), "the leap is airborne over the pit")
	check(player.global_position.x > PIT_CENTRE.x, "the leap is over the pit centre")
	check_eq(GameState.health, health, "no fall while airborne over the pit")
	await seconds(0.5)
	check(not player.is_external_motion(), "the leap is over")
	check_near(
		player.global_position.x, LEAP_LANDING_X, 1.0, "Tamsin lands 192 px ahead, past the pit"
	)
	check_eq(GameState.health, health, "landing past the pit costs nothing")
	await dispose(arena)


func _landing_in_pit_falls() -> void:
	reset_state()
	var arena := make_arena()
	var safe := Vector2(300, 500)
	# The pit's centre is 192 px ahead of the start: the leap lands in it.
	_make_pit(arena, safe + Vector2(192, 0))
	var player := make_player(arena, safe)
	await frames(2)
	_give_boots(player)
	var health := GameState.health
	check(player.use_item(), "the boots leap towards the pit")
	await seconds(0.5)
	check_eq(GameState.health, health - 2, "a leap that lands in a pit falls")
	check_eq(player.global_position, safe, "the fall goes back to the spot before the leap")
	await dispose(arena)


func _stops_at_wall() -> void:
	reset_state()
	var walls: Array[Rect2] = [Rect2(Vector2(560, 300), Vector2(32, 400))]
	var arena := make_arena(walls)
	var player := make_player(arena, Vector2(400, 500))
	await frames(2)
	_give_boots(player)
	check(player.use_item(), "the leap starts with a wall ahead")
	await seconds(0.5)
	check_near(
		player.global_position.x, 534.0, 1.5, "the leap stops 26 px (body radius) before the wall"
	)
	check(
		player.global_position.x + Player.BODY_RADIUS <= 560.5, "Tamsin never lands inside the wall"
	)
	await dispose(arena)


func _passes_rail() -> void:
	reset_state()
	var arena := make_arena()
	_make_rail(arena, Rect2(Vector2(540, 300), Vector2(16, 400)))
	var player := make_player(arena, Vector2(400, 500))
	await frames(2)
	_give_boots(player)
	check(player.use_item(), "the leap starts over a low rail")
	await seconds(0.5)
	check_near(player.global_position.x, 592.0, 1.0, "a low rail does not stop the leap")
	await dispose(arena)


func _damage_ignored_in_air() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(400, 500))
	await frames(2)
	_give_boots(player)
	var health := GameState.health
	check(player.use_item(), "the leap starts")
	await frames(12)
	check(player.is_airborne(), "the player is airborne")
	check(not player.hurtbox.enabled, "the hurtbox is off in the air")
	var hitbox := make_hitbox(arena, player.global_position, Layers.Team.ENEMY, 2, 40.0)
	await frames(3)
	check_eq(GameState.health, health, "an enemy hit in the air does nothing")
	check(
		not player.take_damage(2, player.global_position), "scripted damage is refused in the air"
	)
	check_eq(GameState.health, health, "scripted damage in the air does nothing")
	await dispose(hitbox)
	await dispose(arena)


func _refused_when_locked() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(400, 500))
	await frames(2)
	_give_boots(player)
	player.lock_actions(&"test_lock", true)
	check(not player.use_item(), "a locked player cannot leap")
	check_eq(_boots().size(), 0, "a refused leap leaves no boots node")
	player.lock_actions(&"test_lock", false)
	check(player.use_item(), "the leap works once unlocked")
	await dispose(arena)


func _cooldown_and_one_at_a_time() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(400, 500))
	await frames(2)
	_give_boots(player)
	check(player.use_item(), "the first leap")
	check(not player.use_item(), "no second leap during the leap")
	await frames(30)  # landed after 0.4 s; the 0.5 s cooldown still runs
	check(not player.is_external_motion(), "the first leap has landed")
	check(not player.use_item(), "no leap during the cooldown")
	check_eq(_boots().size(), 1, "a refused leap is freed, the cooldown node stays")
	await seconds(0.6)
	check_eq(_boots().size(), 0, "the cooldown node is gone after the cooldown")
	check(player.use_item(), "a leap after the cooldown")
	await dispose(arena)


func _refused_next_to_wall() -> void:
	reset_state()
	var walls: Array[Rect2] = [Rect2(Vector2(440, 300), Vector2(32, 400))]
	var arena := make_arena(walls)
	var player := make_player(arena, Vector2(400, 500))
	await frames(2)
	_give_boots(player)
	var health := GameState.health
	check(not player.use_item(), "no leap when a wall is right in front")
	check(not player.is_external_motion(), "a refused leap starts no motion")
	check_eq(_boots().size(), 0, "a refused leap leaves no boots node")
	check_eq(GameState.health, health, "a refused leap costs nothing")
	await dispose(arena)


func _leap_follows_facing() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(600, 600))
	await frames(2)
	_give_boots(player, Vector2.UP)
	check(player.use_item(), "the leap up")
	await seconds(0.5)
	check_near(player.global_position.y, 408.0, 1.0, "the leap goes 192 px up")
	check_near(player.global_position.x, 600.0, 0.5, "the leap up does not move sideways")
	await dispose(arena)


func _scene_and_registry() -> void:
	reset_state()
	var scene := load(ITEM_SCENE) as PackedScene
	check(scene != null, "the item scene loads")
	var item := ItemRegistry.create(&"skitter_boots")
	check(item != null, "the registry creates the boots")
	if item == null:
		return
	var arena := make_arena()
	arena.add_child(item)
	await frames(2)
	check_eq(item.item_id, &"skitter_boots", "the boots have their id")
	check(item.get_node_or_null("Visual") != null, "the boots have a Visual child")
	await dispose(arena)


func _room_fixture() -> void:
	reset_state()
	var arena := make_arena()
	var scene := load(FIXTURE_SCENE) as PackedScene
	var room := scene.instantiate() as Node2D
	arena.add_child(room)
	await frames(2)
	var spawn := room.get_node("Spawns/Default") as Marker2D
	var pit := room.get_node("Props/Pit") as Node2D
	var rail := room.get_node("Props/Rail") as Node
	check(pit.is_in_group(&"pit_zone"), "the fixture pit is a pit zone")
	check(rail.is_in_group(&"leapable"), "the fixture rail is leapable")
	check(spawn != null, "the fixture has a spawn")
	var player := make_player(arena, Vector2(pit.global_position.x - 100.0, pit.global_position.y))
	await frames(2)
	_give_boots(player)
	var health := GameState.health
	check(player.use_item(), "the fixture leap starts")
	await seconds(0.5)
	check_eq(GameState.health, health, "the fixture leap clears the pit")
	check_near(
		player.global_position.x,
		pit.global_position.x + 92.0,
		1.0,
		"the fixture leap lands past the pit"
	)
	await dispose(arena)


func _dust_lifecycle() -> void:
	reset_state()
	var arena := make_arena()
	var start := Vector2(400, 500)
	var player := make_player(arena, start)
	await frames(2)
	_give_boots(player)
	check(player.use_item(), "dust test starts a leap")
	var item := _boots()[0] as Node2D
	var visual := item.get_node("Visual") as Node2D
	var puff := visual.get_node_or_null("LeapDust") as Sprite2D
	check(puff != null, "successful start produces one puff")
	if puff != null:
		check_eq(puff.global_position, start + Vector2(0, 8), "puff starts at the feet")
	await frames(8)
	if is_instance_valid(puff):
		check_eq(puff.global_position, start + Vector2(0, 8), "puff stays at the takeoff point")
	await seconds(0.5)
	check_eq(visual.get_child_count(), 0, "puff fades and landing creates no cue")
	await dispose(arena)

	reset_state()
	arena = make_arena()
	player = make_player(arena, start)
	await frames(2)
	_give_boots(player)
	check(player.use_item(), "cancellation test starts a leap")
	item = _boots()[0] as Node2D
	visual = item.get_node("Visual") as Node2D
	player.place_at(start + Vector2(192, 0))
	check_eq(visual.get_child_count(), 1, "cancel at endpoint creates no second puff")
	await seconds(0.5)
	check_eq(visual.get_child_count(), 0, "cancelled puff expires without landing cue")
	await dispose(arena)

	reset_state()
	arena = make_arena()
	player = make_player(arena, start)
	await frames(2)
	var path: Array[Vector2] = [start + Vector2(100, 0)]
	check(player.begin_external_motion(path, 100.0), "other motion starts")
	var scene := load(ITEM_SCENE) as PackedScene
	item = scene.instantiate() as Node2D
	item.set("player", player)
	item.set("facing", Vector2.RIGHT)
	arena.add_child(item)
	check(not item.call("activate"), "motion API refuses the leap")
	visual = item.get_node("Visual") as Node2D
	check_eq(visual.get_child_count(), 0, "refused motion creates no puff")
	await dispose(arena)
