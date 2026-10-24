extends TestCase
## Wickling: stats, idle until 420 px, stop-and-go runs (0.5 s at 200 px/s, 0.3 s pauses), approach
## offsets within 35 degrees, pack boost (+20 % for 3.0 s after a packmate dies, same parent only),
## fire and any hit kill it, and the drop gate.

const SCENE := "res://scenes/enemies/wickling.tscn"
const ROOM := Rect2(0, 0, 1920, 960)
const AT := Vector2(400, 300)


func run() -> void:
	await _stats()
	await _idle_until_trigger()
	await _stop_and_go_and_speed()
	await _approach_offset_is_small()
	await _pack_boost_and_parent()
	await _one_hit_and_fire_kill()
	_drop_gate()


func _stats() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, AT)
	enemy.room_rect = ROOM
	await frames(2)
	check_eq(enemy.max_hp, 1, "wickling has 1 hp (dies in one hit)")
	check_eq(enemy.contact_damage, 1, "wickling contact damage is 1")
	check_eq(enemy.move_speed, 200.0, "wickling runs at 200 px/s")
	check(enemy.is_in_group(&"wicklings"), "wickling is in the pack group")
	check(Placeholder.has_kind(&"wickling"), "wickling registered its placeholder kind")
	check(enemy.get_node_or_null("Visual") != null, "wickling has a Visual child")
	await dispose(arena)


func _idle_until_trigger() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, AT)
	enemy.room_rect = ROOM
	var player := make_player(arena, AT + Vector2(600, 0))
	await frames(2)
	for i in range(90):
		player.global_position = AT + Vector2(600, 0)
		await frames(1)
	check(enemy.global_position.distance_to(AT) < 0.5, "wickling stays idle beyond 420 px")
	check(not enemy.is_running(), "no run beyond 420 px")
	player.global_position = AT + Vector2(400, 0)
	await frames(2)
	check(enemy.is_running(), "wickling runs once Tamsin is within 420 px")
	await dispose(arena)


func _stop_and_go_and_speed() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, AT)
	enemy.room_rect = ROOM
	var player := make_player(arena, AT + Vector2(410, 0))
	await frames(2)
	var segments: Array[int] = []
	var running_segments: Array[bool] = []
	var length := 0
	var last := false
	for i in range(120):
		player.global_position = AT + Vector2(410, 0)
		await frames(1)
		var running: bool = enemy.is_running()
		if running:
			check_near(enemy.velocity.length(), 200.0, 0.5, "run speed is 200 px/s")
		else:
			check_eq(enemy.velocity, Vector2.ZERO, "wickling stands still during a pause")
		if i > 0 and running != last:
			segments.append(length)
			running_segments.append(last)
			length = 0
		length += 1
		last = running
	check(segments.size() >= 3, "the wickling runs and pauses several times")
	check(running_segments[0], "the first segment is a run")
	check_near(segments[0], 30.0, 2.0, "run lasts 0.5 s (got %d frames)" % segments[0])
	check_near(segments[1], 18.0, 2.0, "pause lasts 0.3 s (got %d frames)" % segments[1])
	await dispose(arena)


func _approach_offset_is_small() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, AT)
	enemy.room_rect = ROOM
	var player := make_player(arena, AT + Vector2(300, 0))
	await frames(2)
	var offset: float = enemy.approach_offset_deg()
	check(absf(offset) <= 35.0, "approach offset is within +-35 degrees (got %.1f)" % offset)
	var aimed := false
	for i in range(60):
		player.global_position = AT + Vector2(300, 0)
		await frames(1)
		if enemy.is_running() and enemy.velocity.length() > 1.0:
			var to_player: Vector2 = enemy.direction_to_player()
			var angle := rad_to_deg(absf(enemy.velocity.angle_to(to_player)))
			check_near(angle, absf(offset), 1.0, "run follows the member's own offset")
			aimed = true
			break
	check(aimed, "the wickling was seen running")
	await dispose(arena)


func _pack_boost_and_parent() -> void:
	reset_state()
	var arena := make_arena()
	var other := make_arena()
	var a = make_enemy(arena, SCENE, Vector2(300, 200))
	var b = make_enemy(arena, SCENE, Vector2(300, 400))
	var c = make_enemy(arena, SCENE, Vector2(300, 600))
	var lone = make_enemy(other, SCENE, Vector2(300, 400))
	for w in [a, b, c, lone]:
		w.room_rect = ROOM
	await frames(2)
	check(not b.is_boosted(), "no boost before a packmate dies")
	a.apply_damage(1, a.global_position + Vector2(-20, 0))
	await frames(1)
	check(b.is_boosted() and c.is_boosted(), "packmates in the same room get the boost")
	check(not lone.is_boosted(), "a wickling in another room is not boosted")
	check_near(b.run_speed(), 240.0, 0.01, "boosted run speed is 20 % faster")
	await frames(170)
	check(b.is_boosted(), "the boost lasts for 3.0 s")
	await frames(25)
	check(not b.is_boosted(), "the boost ends after 3.0 s")
	check_near(b.run_speed(), 200.0, 0.01, "run speed is back at 200 px/s")
	await dispose(arena)
	await dispose(other)


func _one_hit_and_fire_kill() -> void:
	reset_state()
	var arena := make_arena()
	var one = make_enemy(arena, SCENE, Vector2(300, 300))
	var two = make_enemy(arena, SCENE, Vector2(600, 300))
	one.room_rect = ROOM
	two.room_rect = ROOM
	await frames(2)
	check(one.apply_damage(1, one.global_position + Vector2(-20, 0)), "a plain hit is accepted")
	await frames(2)
	check(not is_instance_valid(one) or one.is_dead, "one hit kills a wickling")
	var flame := make_hitbox(arena, two.global_position, Layers.Team.PLAYER, 1, 20.0)
	flame.kind = &"fire"
	await frames(2)
	flame.deactivate()
	await frames(2)
	check(not is_instance_valid(two) or two.is_dead, "fire kills a wickling at once")
	await dispose(arena)


func _drop_gate() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, AT)
	await frames(2)
	check(enemy.drop_gate_open(0.0), "drop gate opens for a roll of 0.0")
	check(enemy.drop_gate_open(0.49), "drop gate opens below 0.5")
	check(not enemy.drop_gate_open(0.5), "drop gate closes at 0.5")
	check(not enemy.drop_gate_open(0.99), "drop gate closes for a roll of 0.99")
	await dispose(arena)
