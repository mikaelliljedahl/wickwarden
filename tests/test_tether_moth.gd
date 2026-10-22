extends TestCase
## Tether moth: flies out ~420 px and back, one at a time, turns early at a wall, stuns enemies,
## carries loot back to the player.

const DUMMY_SCENE := "res://scenes/enemies/dummy_walker.tscn"


func run() -> void:
	await _travel_and_return()
	await _refuse_second_use()
	await _stuns_enemy()
	await _carries_pickup()
	await _turns_back_at_wall()


func _moths() -> Array:
	return get_tree().get_nodes_in_group(ItemBase.group_name(&"tether_moth"))


## Throws through the real Player path, facing `facing`.
func _throw(player: Player, facing: Vector2) -> bool:
	player.facing = facing
	return player.use_item()


func _travel_and_return() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(600, 500))
	await frames(2)
	GameState.acquire_item(&"tether_moth")
	check(_throw(player, Vector2.RIGHT), "the moth can be thrown")
	var moths := _moths()
	check_eq(moths.size(), 1, "one moth is on screen after the throw")
	var moth := moths[0] as Node2D
	var start := player.global_position
	var max_out := 0.0
	var last_dist := -1.0
	for i in range(300):
		await frames(1)
		if not is_instance_valid(moth) or moth.is_queued_for_deletion():
			break
		last_dist = moth.global_position.distance_to(start)
		max_out = maxf(max_out, last_dist)
	check_near(max_out, 420.0, 16.0, "the moth flies about 420 px out")
	check(last_dist >= 0.0 and last_dist < 20.0, "the moth comes back to the player")
	var gone := not is_instance_valid(moth) or moth.is_queued_for_deletion()
	check(gone, "the moth despawns on reaching the player")
	await dispose(arena)


func _refuse_second_use() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(600, 500))
	await frames(2)
	GameState.acquire_item(&"tether_moth")
	check(_throw(player, Vector2.RIGHT), "the first throw is accepted")
	await frames(10)
	check(not _throw(player, Vector2.LEFT), "a second throw is refused while one is out")
	check_eq(_moths().size(), 1, "the refused throw leaves the one moth")
	await seconds(1.5)
	check_eq(_moths().size(), 0, "the moth is gone once it has returned")
	check(_throw(player, Vector2.UP), "a new moth can be thrown after the first came back")
	await seconds(1.5)
	await dispose(arena)


func _stuns_enemy() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(600, 500))
	var enemy := make_enemy(arena, DUMMY_SCENE, Vector2(850, 500))
	await frames(2)
	check(not enemy.is_stunned(), "the enemy starts unstunned")
	GameState.acquire_item(&"tether_moth")
	check(_throw(player, Vector2.RIGHT), "the moth is thrown at the enemy")
	var stunned := false
	for i in range(60):
		await frames(1)
		if enemy.is_stunned():
			stunned = true
			break
	check(stunned, "the moth stuns an enemy it touches")
	check_eq(enemy.hp, enemy.max_hp, "the moth does no damage")
	await seconds(1.0)
	check(enemy.is_stunned(), "the enemy is still stunned about 1 s later")
	await seconds(2.0)
	check(not enemy.is_stunned(), "the stun is over after its 2 s")
	await dispose(arena)


func _carries_pickup() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(600, 500))
	await frames(2)
	GameState.acquire_item(&"tether_moth")
	var coin := PickupBase.spawn(&"brass_coin", arena, Vector2(800, 510), false)
	await frames(2)
	check(_throw(player, Vector2.RIGHT), "the moth is thrown past a coin")
	await seconds(0.5)
	check(coin.is_carried(), "the moth picks up the coin it touches")
	check_eq(GameState.currency, 0, "a carried coin is not applied yet")
	await seconds(1.0)
	check_eq(GameState.currency, 5, "the coin is brought back to the player")
	check_eq(_moths().size(), 0, "the moth has returned")
	await dispose(arena)


func _turns_back_at_wall() -> void:
	reset_state()
	var walls: Array[Rect2] = [Rect2(750, 380, 40, 240)]
	var arena := make_arena(walls)
	var player := make_player(arena, Vector2(600, 500))
	await frames(2)
	GameState.acquire_item(&"tether_moth")
	check(_throw(player, Vector2.RIGHT), "the moth is thrown at a wall")
	var moth := _moths()[0] as Node2D
	var start := player.global_position
	var max_out := 0.0
	for i in range(300):
		await frames(1)
		if not is_instance_valid(moth) or moth.is_queued_for_deletion():
			break
		max_out = maxf(max_out, moth.global_position.distance_to(start))
	check(max_out > 120.0 and max_out < 150.0, "the moth turns back at the wall (150 px out)")
	check(not is_instance_valid(moth) or moth.is_queued_for_deletion(), "it still returns")
	await dispose(arena)
