extends TestCase
## The hollow: stats, grid walking, the charge and its cooldown, death, stun.

const HOLLOW := "res://scenes/enemies/hollow.tscn"
const ROOM := Rect2(0, 0, 960, 576)
const START := Vector2(144, 240)
const PLAYER_AHEAD := Vector2(800, 240)


func run() -> void:
	await _test_stats_and_grid_walk()
	await _test_charge_and_cooldown()
	await _test_stun_stops_it()
	await _test_dies_after_four_damage()


## Interior 96..864 x 96..480 with 96 px wall tiles, so tile centres are at 144 + 96 * k.
func _make_room() -> Node2D:
	var walls: Array[Rect2] = [
		Rect2(0, 0, 960, 96),
		Rect2(0, 480, 960, 96),
		Rect2(0, 0, 96, 576),
		Rect2(864, 0, 96, 576),
	]
	return make_arena(walls)


func _on_line(v: float) -> bool:
	return absf(v - (floorf(v / 96.0) * 96.0 + 48.0)) < 1.0


func _test_stats_and_grid_walk() -> void:
	reset_state()
	var arena := _make_room()
	var enemy := make_enemy(arena, HOLLOW, START)
	enemy.room_rect = ROOM
	await frames(2)
	check_eq(enemy.hp, 4, "hollow has 4 hp")
	check_eq(enemy.contact_damage, 2, "hollow contact damage is 2 (one heart)")
	check_near(enemy.move_speed, 140.0, 0.01, "hollow walks at 140 px/s")
	check(enemy.get_node_or_null("Visual") != null, "hollow has a Visual child")

	var min_pos := enemy.global_position
	var max_pos := enemy.global_position
	var moved := false
	var off_grid := 0
	for i in range(600):
		await frames(1)
		var p: Vector2 = enemy.global_position
		min_pos = min_pos.min(p)
		max_pos = max_pos.max(p)
		moved = moved or enemy.velocity.length() > 0.0
		if not (_on_line(p.x) or _on_line(p.y)):
			off_grid += 1
	check(moved, "hollow walks")
	check_eq(off_grid, 0, "walking keeps one coordinate on a tile centre line")
	check(max_pos.distance_to(min_pos) > 96.0, "hollow covers ground")
	check(
		min_pos.x >= 126.0 and max_pos.x <= 834.0 and min_pos.y >= 126.0 and max_pos.y <= 450.0,
		"hollow stays inside the walls"
	)
	await dispose(arena)


func _test_charge_and_cooldown() -> void:
	reset_state()
	var arena := _make_room()
	make_player(arena, PLAYER_AHEAD)
	var enemy := make_enemy(arena, HOLLOW, START)
	enemy.room_rect = ROOM
	enemy.set_facing_dir(Vector2.RIGHT)
	var x0 := enemy.global_position.x
	await frames(18)
	check(enemy.call("is_charging"), "hollow charges at an aligned player in front")
	check_near(enemy.global_position.x - x0, 90.0, 6.0, "charge moves 300 px/s for 0.3 s")
	check_near(enemy.velocity.x, 300.0, 1.0, "charge speed is 300 px/s")

	# Continue to the end of the charge and the 0.6 s cooldown that follows it.
	var frame := 18
	var charge_end := -1
	var second_start := -1
	var end_pos := Vector2.ZERO
	var still := true
	var was_charging := true
	for i in range(150):
		await frames(1)
		frame += 1
		var charging: bool = enemy.call("is_charging")
		if was_charging and not charging and charge_end < 0:
			charge_end = frame
			end_pos = enemy.global_position
		if charge_end > 0 and second_start < 0 and frame - charge_end <= 30:
			still = still and enemy.global_position.distance_to(end_pos) < 1.0
		if charging and charge_end > 0 and second_start < 0:
			second_start = frame
		was_charging = charging
	check(charge_end > 0, "charge ends after 0.5 s")
	check(still, "hollow stands still during the cooldown after a charge")
	check(second_start > 0, "hollow charges again after the cooldown")
	check(
		second_start - charge_end >= 35,
		"next charge waits at least 0.6 s after the previous one ends"
	)
	await dispose(arena)


func _test_stun_stops_it() -> void:
	reset_state()
	var arena := _make_room()
	make_player(arena, PLAYER_AHEAD)
	var enemy := make_enemy(arena, HOLLOW, START)
	enemy.room_rect = ROOM
	enemy.set_facing_dir(Vector2.RIGHT)
	enemy.stun(1.0)
	var p0: Vector2 = enemy.global_position
	await frames(40)
	check(enemy.is_stunned(), "hollow is still stunned after 0.67 s")
	check(enemy.global_position.distance_to(p0) < 0.01, "stunned hollow does not move")
	check(not enemy.call("is_charging"), "stunned hollow does not charge")
	await dispose(arena)


func _test_dies_after_four_damage() -> void:
	reset_state()
	var arena := _make_room()
	var enemy := make_enemy(arena, HOLLOW, START)
	enemy.room_rect = ROOM
	enemy.drops_enabled = false
	var from := START + Vector2(-30, 0)
	enemy.apply_damage(2, from)
	await seconds(0.4)
	enemy.apply_damage(1, from)
	await seconds(0.4)
	check_eq(enemy.hp, 1, "hollow has 1 hp left after 3 damage")
	check(not enemy.is_dead, "hollow is alive after 3 damage")
	enemy.apply_damage(1, from)
	await frames(2)
	check(not is_instance_valid(enemy), "hollow dies after 4 damage")
	await dispose(arena)
