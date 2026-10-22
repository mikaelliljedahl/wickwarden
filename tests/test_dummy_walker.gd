extends TestCase
## The worked example enemy: behaves, stays inside walls, takes damage, dies and drops.


func run() -> void:
	reset_state()
	var walls: Array[Rect2] = [
		Rect2(0, 0, 800, 50), Rect2(0, 550, 800, 50), Rect2(0, 0, 50, 600), Rect2(750, 0, 50, 600)
	]
	var arena := make_arena(walls)
	var enemy := make_enemy(arena, "res://scenes/enemies/dummy_walker.tscn", Vector2(400, 300))
	enemy.room_rect = Rect2(0, 0, 800, 600)
	await frames(2)
	check_eq(enemy.hp, 2, "dummy walker has 2 hp")
	check_eq(enemy.contact_damage, 1, "dummy walker contact damage is 1")
	var min_pos := enemy.global_position
	var max_pos := enemy.global_position
	var moved := false
	for i in range(240):
		await frames(1)
		min_pos = min_pos.min(enemy.global_position)
		max_pos = max_pos.max(enemy.global_position)
		moved = moved or enemy.velocity.length() > 0.0
	check(moved, "dummy walker walks")
	check(
		min_pos.x >= 50.0 and min_pos.y >= 50.0 and max_pos.x <= 750.0 and max_pos.y <= 550.0,
		"stays inside the walls"
	)
	check(max_pos.distance_to(min_pos) > 20.0, "covers ground")
	enemy.drop_roll_override = 0.3
	enemy.apply_damage(1, enemy.global_position + Vector2(-30, 0))
	check_eq(enemy.hp, 1, "damage reduces hp")
	await seconds(0.4)
	enemy.apply_damage(1, enemy.global_position + Vector2(-30, 0))
	await frames(2)
	check(not is_instance_valid(enemy), "dies at 0 hp")
	check_eq(
		arena.get_children().filter(func(n: Node) -> bool: return n is PickupBase).size(),
		1,
		"drops loot"
	)
	await dispose(arena)
