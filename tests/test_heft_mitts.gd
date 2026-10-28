extends TestCase
## Heft mitts (T04): a grab lifts a liftable or a LIFT heavy stone in front (rooted for 0.25 s), the carry walks at
## 252 px/s (216 for a heavy stone) with the hook and the items off, a throw flies 480 px and hits a stand-in enemy
## for 3, the ward puts the object down, a hit breaks it, a PUSH boulder slides while the keys point at it, and a
## grab on nothing is a 0.2 s no-op. The scene loads, is registered and the gallery fixture works.

const ITEM_SCENE := "res://scenes/items/heft_mitts.tscn"
const ROCK_SCENE := "res://scenes/world/liftable_rock.tscn"
const STONE_SCENE := "res://scenes/world/heavy_stone.tscn"
const BOULDER_SCENE := "res://scenes/world/heavy_boulder.tscn"
const FIXTURE_SCENE := "res://tests/fixtures/gallery/T04.tscn"
const START := Vector2(400, 480)
## The grab reach: the object lies this far ahead of the player (matches heft_mitts.gd GRAB_REACH).
const AHEAD := Vector2(72, 0)
const CARRY_OFFSET := Vector2(0, -40)
const CARRY_SPEED := 252.0
const HEAVY_CARRY_SPEED := 216.0
const WALK_SPEED := 360.0

var _landed_count := 0


func run() -> void:
	await _scene_and_registry()
	await _effort_cues_follow_real_actions()
	await _vanishing_shards_release_mitts()
	await _lift_roots_then_carries_slower_than_walking()
	await _carry_blocks_hook_and_items()
	await _ward_puts_down()
	await _throw_flies_480_and_hits_once()
	await _throw_lockout()
	await _hurt_breaks_carried()
	await _heavy_stone_carries_at_216()
	await _push_slides_boulder()
	await _nothing_grabbed_is_a_short_lockout()
	await _room_fixture()


func _effort_cues_follow_real_actions() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	_give_mitts(player)
	var rock: Variant = _make_prop(arena, ROCK_SCENE, START + AHEAD)
	await frames(2)
	check(player.use_item(), "effort test starts real grab")
	await frames(2)
	check(rock.is_carried(), "effort test lifts real rock")
	var visual := _mitts()[0].get_node("Visual") as Node2D
	var lift := visual.get_node_or_null("MittsEffort") as Sprite2D
	check(lift != null and lift.texture != null, "successful lift produces painted effort")
	if lift != null:
		check(lift.top_level and lift.get_child_count() == 0, "effort is world-fixed and nonphysical")
		var lift_position := lift.global_position
		player.place_at(player.global_position + Vector2(20, 0))
		check_eq(lift.global_position, lift_position, "effort stays at the action position")
	await seconds(0.45)
	check(visual.get_node_or_null("MittsEffort") == null, "no lingering effect while carrying")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	check(not rock.is_carried(), "effort test throws the actual rock")
	check(visual.get_node_or_null("MittsEffort") != null, "throw produces painted effort")
	await dispose(arena)


func _mitts() -> Array:
	return get_tree().get_nodes_in_group(ItemBase.group_name(&"heft_mitts"))


func _give_mitts(player: Player, dir: Vector2 = Vector2.RIGHT) -> void:
	GameState.acquire_item(&"heft_mitts")
	GameState.set_active_item(&"heft_mitts")
	player.facing = dir


## A prop scene at `at` in `parent`. `stone_id` is set before the node enters the tree (heavy stones read it).
func _make_prop(
	parent: Node, scene_path: String, at: Vector2, stone_id: StringName = &""
) -> Variant:
	var scene := load(scene_path) as PackedScene
	check(scene != null, "the prop scene loads: %s" % scene_path)
	var prop: Variant = scene.instantiate()
	if stone_id != &"":
		prop.stone_id = stone_id
	prop.position = at
	parent.add_child(prop)
	prop.shattered.connect(_on_shattered)
	return prop


func _on_shattered(_at: Vector2) -> void:
	_landed_count += 1


func _gone(node: Variant) -> bool:
	return not is_instance_valid(node) or node.is_queued_for_deletion()


## A shard can be queued by its expiry before the grab callback, or disappear during LIFT.
## Both paths use the real hitbox, shard and mitts cycle; the signals control the race timing.
func _vanishing_shards_release_mitts() -> void:
	for queued_before_grab in [true, false]:
		reset_state()
		var arena := make_arena()
		var player := make_player(arena, START)
		_give_mitts(player)
		var boss_scene := load("res://scenes/enemies/bosses/hushed_colossus.tscn") as PackedScene
		check(boss_scene != null, "Colossus scene loads for real shard")
		if boss_scene == null:
			await dispose(arena)
			return
		var boss = boss_scene.instantiate()
		boss.position = Vector2(1500, 800)
		arena.add_child(boss)
		boss.land_shard(START + AHEAD)
		var shard = boss.shards.back()
		var hurtbox := shard.get_node("Hurtbox") as Hurtbox
		var seen := {"lifted": false}
		shard.lifted.connect(func(_by: Node2D) -> void: seen["lifted"] = true)
		if queued_before_grab:
			hurtbox.hurt.connect(func(_hit: Hitbox) -> void: shard.queue_free())
		else:
			shard.lifted.connect(func(_by: Node2D) -> void: shard.queue_free())
		await frames(2)
		check(player.use_item(), "real mitts start the shard grab")
		await frames(2)
		check(not is_instance_valid(shard), "shard is freed during the real grab cycle")
		check_eq(seen["lifted"], not queued_before_grab, "queued shard is rejected; live shard lifts")
		await seconds(0.4)
		check(_mitts().is_empty(), "mitts end safely when the shard vanishes")
		check(not player.actions_locked(), "actions are restored after the shard vanishes")
		Input.action_press(&"move_right")
		await frames(10)
		check_near(player.velocity.x, WALK_SPEED, 0.5, "walking speed is restored")
		release_inputs()
		check(player.use_item(), "mitts can be used again after the race")
		await seconds(0.3)
		await dispose(arena)


func _scene_and_registry() -> void:
	reset_state()
	check(load(ITEM_SCENE) != null, "the item scene loads")
	var item := ItemRegistry.create(&"heft_mitts")
	check(item != null, "the registry creates the mitts")
	if item == null:
		return
	var arena := make_arena()
	arena.add_child(item)
	check_eq(item.item_id, &"heft_mitts", "the mitts have their id")
	check(item.get_node_or_null("Visual") != null, "the mitts have a Visual child")
	await dispose(arena)


func _lift_roots_then_carries_slower_than_walking() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	await frames(2)
	_give_mitts(player)
	var rock: Variant = _make_prop(arena, ROCK_SCENE, START + AHEAD)
	await frames(2)
	check(player.use_item(), "the mitts grab a rock in front")
	await frames(2)
	check(rock.is_carried(), "the rock is lifted by the grab")
	check(player.actions_locked(), "the hook and the items are locked while carrying")
	check_near(
		rock.global_position.distance_to(player.global_position + CARRY_OFFSET),
		0.0,
		1.0,
		"the lifted rock floats above Tamsin"
	)
	Input.action_press(&"move_right")
	await frames(10)
	check_near(player.global_position.x, START.x, 0.5, "Tamsin is rooted during the 0.25 s lift")
	await seconds(0.25)
	var start := player.global_position
	await frames(60)
	check_near(player.global_position.x - start.x, CARRY_SPEED, 3.0, "the carry walks at 252 px/s")
	check(rock.is_carried(), "the rock is still carried while walking")
	check_near(
		rock.global_position.distance_to(player.global_position + CARRY_OFFSET),
		0.0,
		1.0,
		"the carried rock follows Tamsin"
	)
	release_inputs()
	rock.put_down(rock.global_position)
	await frames(2)
	check(not player.actions_locked(), "the lock is off once the rock is down")
	check(_mitts().is_empty(), "the mitts end with the put down")
	await dispose(arena)


func _carry_blocks_hook_and_items() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	await frames(2)
	_give_mitts(player)
	var rock: Variant = _make_prop(arena, ROCK_SCENE, START + AHEAD)
	await frames(2)
	check(player.use_item(), "the grab starts")
	await seconds(0.4)
	check(rock.is_carried(), "the rock is carried")
	Input.action_press(&"attack")
	await frames(3)
	check(not player.is_swinging(), "the hook does not swing while carrying")
	release_inputs()
	check(not player.use_item(), "no second item use while carrying")
	check_eq(_mitts().size(), 1, "a refused use leaves no second mitts node")
	rock.put_down(rock.global_position)
	await dispose(arena)


func _ward_puts_down() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	await frames(2)
	_give_mitts(player)
	var rock: Variant = _make_prop(arena, ROCK_SCENE, START + AHEAD)
	await frames(2)
	check(player.use_item(), "the grab starts")
	await seconds(0.4)
	check(rock.is_carried(), "the rock is carried before the ward")
	Input.action_press(&"ward")
	await frames(2)
	release_inputs()
	check(not rock.is_carried(), "the ward button puts the rock down")
	check_near(
		rock.global_position.distance_to(START + AHEAD),
		0.0,
		1.0,
		"the rock lies one grab reach in front of Tamsin"
	)
	check(_mitts().is_empty(), "the mitts end with the put down")
	check(not player.actions_locked(), "the hook is back after the put down")
	await frames(2)
	Input.action_press(&"move_right")
	await frames(10)
	check_near(player.velocity.x, WALK_SPEED, 0.5, "walking is back to 360 px/s")
	release_inputs()
	await dispose(arena)


func _throw_flies_480_and_hits_once() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	await frames(2)
	_give_mitts(player)
	var rock: Variant = _make_prop(arena, ROCK_SCENE, START + AHEAD)
	var enemy := make_dummy(arena, START + Vector2(260, 0), 6)
	await frames(2)
	check(player.use_item(), "the grab starts")
	await seconds(0.4)
	check(rock.is_carried(), "the rock is carried before the throw")
	var from: Vector2 = rock.global_position
	_landed_count = 0
	Input.action_press(&"use_item")
	await frames(1)
	release_inputs()
	check(not rock.is_carried(), "use_item throws the rock")
	await seconds(1.0)
	check_eq(_landed_count, 1, "the rock breaks on landing once")
	check_eq(enemy.hp, 3, "the thrown rock hits the enemy in its path for 3, once")
	check(_mitts().is_empty(), "the mitts end after the lockout")
	check_near(
		from.distance_to(START + CARRY_OFFSET), 0.0, 1.0, "the throw starts from the carry spot"
	)
	await dispose(arena)


func _throw_lockout() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	await frames(2)
	_give_mitts(player)
	var first: Variant = _make_prop(arena, ROCK_SCENE, START + AHEAD)
	var second: Variant = _make_prop(arena, ROCK_SCENE, START + AHEAD + Vector2(0, 120))
	await frames(2)
	check(player.use_item(), "the grab starts")
	await seconds(0.4)
	check(first.is_carried(), "the first rock is carried")
	Input.action_press(&"use_item")
	await frames(1)
	release_inputs()
	await seconds(0.2)
	check_eq(_mitts().size(), 1, "the mitts stay 0.4 s after a throw")
	check(not player.use_item(), "no new grab during the throw lockout")
	await seconds(0.3)
	check_eq(_mitts().size(), 0, "the lockout ends after 0.4 s")
	check(not player.actions_locked(), "the lock is off after the lockout")
	check(not second.is_carried(), "the second rock was not grabbed")
	await seconds(1.0)
	await dispose(arena)


func _hurt_breaks_carried() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	await frames(2)
	_give_mitts(player)
	var rock: Variant = _make_prop(arena, ROCK_SCENE, START + AHEAD)
	await frames(2)
	check(player.use_item(), "the grab starts")
	await seconds(0.4)
	check(rock.is_carried(), "the rock is carried before the hit")
	_landed_count = 0
	var health := GameState.health
	check(player.take_damage(1, player.global_position + Vector2(-50, 0)), "Tamsin takes a hit")
	check_eq(GameState.health, health - 1, "the hit costs one half-heart")
	check_eq(_landed_count, 1, "the hit breaks the rock at once")
	check(not rock.is_carried(), "the rock is no longer carried")
	check_near(rock.global_position.distance_to(START), 0.0, 1.0, "the rock broke at her feet")
	await frames(2)
	check(_mitts().is_empty(), "the mitts end with the break")
	check(not player.actions_locked(), "the lock is off after the break")
	await seconds(0.5)
	await dispose(arena)


func _heavy_stone_carries_at_216() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	await frames(2)
	_give_mitts(player)
	var stone: Variant = _make_prop(arena, STONE_SCENE, START + AHEAD)
	await frames(2)
	check(player.use_item(), "the grab starts")
	await seconds(0.4)
	check(stone.is_carried(), "the heavy stone is lifted in LIFT mode")
	var start := player.global_position
	Input.action_press(&"move_right")
	await frames(60)
	release_inputs()
	check_near(
		player.global_position.x - start.x,
		HEAVY_CARRY_SPEED,
		3.0,
		"a heavy stone is carried at 216 px/s"
	)
	stone.put_down(stone.global_position)
	await frames(2)
	await dispose(arena)


func _push_slides_boulder() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	await frames(2)
	_give_mitts(player)
	var boulder: Variant = _make_prop(arena, BOULDER_SCENE, START + Vector2(100, 0), &"t04_push")
	await frames(2)
	var from: Vector2 = boulder.global_position
	check(player.use_item(), "the grab starts a push on the boulder")
	await frames(2)
	check(not boulder.is_carried(), "a boulder is pushed, not lifted")
	check(_mitts()[0].get_node("Visual").get_child_count() == 0, "push has no lift effect")
	check_eq(_mitts().size(), 1, "the mitts stay while the push runs")
	Input.action_press(&"move_right")
	await seconds(1.0)
	check_near(boulder.global_position.x - from.x, 96.0, 1.0, "the boulder slides one 96 px step")
	check(GameState.has_flag(&"moved_t04_push"), "the slide sets the moved flag")
	release_inputs()
	await seconds(0.5)
	check(_mitts().is_empty(), "the push ends when the keys let go")
	await dispose(arena)


func _nothing_grabbed_is_a_short_lockout() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, START)
	await frames(2)
	_give_mitts(player)
	check(player.use_item(), "a use on nothing starts")
	await frames(2)
	check(player.actions_locked(), "the hook is locked for the 0.2 s no-op")
	check(_mitts()[0].get_node("Visual").get_child_count() == 0, "empty grab has no effort")
	check(not player.use_item(), "a second use during the no-op is refused")
	check_eq(_mitts().size(), 1, "the refused use leaves the no-op node alone")
	await seconds(0.3)
	check_eq(_mitts().size(), 0, "the no-op ends after 0.2 s")
	check(not player.actions_locked(), "the hook is back after the no-op")
	await dispose(arena)


func _room_fixture() -> void:
	reset_state()
	var arena := make_arena()
	var scene := load(FIXTURE_SCENE) as PackedScene
	var room := scene.instantiate() as Node2D
	arena.add_child(room)
	await frames(2)
	var rock := room.get_node("Props/Rock") as Node
	var stone := room.get_node("Props/HeavyStone") as Node
	var boulder := room.get_node("Props/HeavyBoulder") as Node
	check(rock.is_in_group(&"liftable"), "the fixture rock is liftable")
	check(stone.is_in_group(&"heavy"), "the fixture heavy stone is heavy")
	check(boulder.is_in_group(&"heavy"), "the fixture boulder is heavy")
	check(room.get_node("Spawns/Default") != null, "the fixture has a spawn")
	var player := make_player(arena, rock.global_position - AHEAD)
	await frames(2)
	_give_mitts(player)
	check(player.use_item(), "the fixture grab starts")
	await frames(2)
	check(rock.is_carried(), "the fixture rock lifts")
	await dispose(arena)
