extends TestCase
## Skitterwick: stats, hops of 140-260 px, no damage or contact while airborne, damage on the
## ground, death after 2 damage, hop targets inside the room, no hops while stunned.

const SCENE := "res://scenes/enemies/skitterwick.tscn"
const ROOM := Rect2(0, 0, 800, 600)


func run() -> void:
	await _stats()
	await _hop_and_airborne()
	await _ground_damage_and_death()
	await _targets_stay_in_room()
	await _stun_stops_hops()


func _stats() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(400, 300))
	enemy.room_rect = ROOM
	await frames(2)
	check_eq(enemy.max_hp, 2, "skitterwick has 2 max hp")
	check_eq(enemy.hp, 2, "skitterwick starts with 2 hp")
	check_eq(enemy.contact_damage, 1, "skitterwick contact damage is 1")
	check(enemy.get_node_or_null("Visual") != null, "skitterwick has a Visual child")
	await dispose(arena)


func _hop_and_airborne() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(400, 300))
	enemy.room_rect = ROOM
	make_player(arena, Vector2(120, 120))
	await frames(2)
	var hopped := false
	var was_air := false
	var prev: Vector2 = enemy.global_position
	var start: Vector2 = prev
	for i in range(600):
		await frames(1)
		var air: bool = enemy.is_airborne()
		if air:
			check(not enemy.can_be_hurt(), "airborne skitterwick cannot be hurt")
			check(not enemy.apply_damage(1, enemy.global_position + Vector2(-30, 0)), "no damage in the air")
			check_eq(enemy.hp, 2, "airborne skitterwick keeps its hp")
			check(not enemy.contact_hitbox.active, "no contact damage in the air")
		if air and not was_air:
			start = prev
			hopped = true
		if was_air and not air:
			var hop_len: float = (enemy.global_position - start).length()
			check(hop_len >= 139.5 and hop_len <= 260.5, "one hop moves 140-260 px (got %.1f)" % hop_len)
			check(enemy.contact_hitbox.active, "contact damage is back after landing")
			break
		was_air = air
		prev = enemy.global_position
	check(hopped, "skitterwick hops toward the player")
	await dispose(arena)


func _ground_damage_and_death() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(400, 300))
	enemy.room_rect = ROOM
	enemy.drops_enabled = false
	await frames(2)
	await _wait_until_grounded(enemy)
	check(enemy.apply_damage(1, enemy.global_position + Vector2(-30, 0)), "takes damage on the ground")
	check_eq(enemy.hp, 1, "one damage leaves 1 hp")
	await seconds(0.3)
	await _wait_until_grounded(enemy)
	enemy.apply_damage(1, enemy.global_position + Vector2(-30, 0))
	await frames(2)
	check(not is_instance_valid(enemy), "skitterwick dies after 2 damage")
	await dispose(arena)


func _targets_stay_in_room() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(90, 90))
	enemy.room_rect = ROOM
	make_player(arena, Vector2(60, 60))
	await frames(2)
	var hops := 0
	var inside := true
	var was_air := false
	for i in range(540):
		await frames(1)
		var air: bool = enemy.is_airborne()
		if air and not was_air:
			hops += 1
			inside = inside and ROOM.has_point(enemy.hop_target)
		inside = inside and ROOM.has_point(enemy.global_position)
		was_air = air
	check(hops >= 3, "skitterwick keeps hopping near the room corner (%d hops)" % hops)
	check(inside, "hop targets and positions stay inside the room rect")
	await dispose(arena)


func _stun_stops_hops() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, Vector2(400, 300))
	enemy.room_rect = ROOM
	await frames(2)
	enemy.stun(2.0)
	var hopped_while_stunned := false
	for i in range(100):
		await frames(1)
		hopped_while_stunned = hopped_while_stunned or enemy.is_airborne()
	check(not hopped_while_stunned, "no hops while stunned")
	var hopped_after := false
	for i in range(180):
		await frames(1)
		hopped_after = hopped_after or enemy.is_airborne()
	check(hopped_after, "hops resume after the stun")
	await dispose(arena)


## Waits until the skitterwick is on the ground and can take a hit (bounded wait).
func _wait_until_grounded(enemy) -> void:
	for i in range(240):
		if not enemy.is_airborne() and enemy.can_be_hurt():
			return
		await frames(1)
