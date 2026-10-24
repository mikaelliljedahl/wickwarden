extends TestCase
## Pitch pot: ammo and the two-on-screen limit, placement one tile ahead, the 1.6 s fuse, and the
## blast (4 to enemies in range, 2 to the player through the hit system, nothing out of range).


func run() -> void:
	await _ammo_and_limit()
	await _fuse_and_blast()
	await _pot_bags_raise_the_ammo_limit()


func _pots() -> Array:
	return get_tree().get_nodes_in_group(ItemBase.group_name(&"pitch_pot"))


func _ammo_and_limit() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(600, 500))
	await frames(2)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"pitch_pot")
	check(not player.use_item(), "no pitch pots: the use is refused")
	check_eq(_pots().size(), 0, "a refused pot is not left in the tree")
	GameState.add_pitch_pots(3)
	check(player.use_item(), "the first pot is placed")
	check_eq(GameState.pitch_pots, 2, "placing a pot spends one pitch pot")
	var first := _pots()[0] as Node2D
	check_near(
		first.global_position.x,
		player.global_position.x + 96.0,
		0.01,
		"the pot lands one tile (96 px) in front of the player"
	)
	check(player.use_item(), "the second pot is placed")
	check_eq(_pots().size(), 2, "two pots are on screen")
	check(not player.use_item(), "a third pot is refused (max two on screen)")
	check_eq(GameState.pitch_pots, 1, "a refused pot costs nothing")
	await seconds(2.0)
	check_eq(_pots().size(), 0, "both pots have exploded and are gone")
	GameState.add_pitch_pots(-10)
	check_eq(GameState.pitch_pots, 0, "ammo is empty")
	check(not player.use_item(), "no ammo: the use is refused")
	await dispose(arena)


func _fuse_and_blast() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(400, 400))
	await frames(2)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"pitch_pot")
	GameState.add_pitch_pots(1)
	# The pot lands at (496, 400): 100 px from `near` (in range), 300 px from `far` (out of range).
	var near := make_dummy(arena, Vector2(596, 400))
	var far := make_dummy(arena, Vector2(796, 400))
	await frames(2)
	check(player.use_item(), "the pot is placed")
	await seconds(1.5)
	check_eq(near.hp, near.max_hp, "nothing explodes before the 1.6 s fuse")
	check_eq(_pots().size(), 1, "the pot is still burning at 1.5 s")
	await seconds(0.3)
	check_eq(near.hp, near.max_hp - 4, "the blast does 4 damage to an enemy in range")
	check_eq(far.hp, far.max_hp, "an enemy out of range is not hurt")
	check_eq(GameState.health, GameState.START_HEALTH - 2, "the blast does 2 to the player in range")
	check_eq(_pots().size(), 0, "the pot is gone after the blast")
	await dispose(arena)


func _pot_bags_raise_the_ammo_limit() -> void:
	reset_state()
	GameState.acquire_item(&"pitch_pot")
	GameState.add_pitch_pots(25)
	check_eq(GameState.pitch_pots, 10, "the pot limit is 10 without bags")
	GameState.add_pot_bag()
	GameState.add_pitch_pots(25)
	check_eq(GameState.pitch_pots, 14, "one pot bag makes the limit 14")
	GameState.add_pot_bag()
	GameState.add_pitch_pots(25)
	check_eq(GameState.pitch_pots, 18, "two pot bags make the limit 18")
