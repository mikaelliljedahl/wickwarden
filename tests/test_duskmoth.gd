extends TestCase
## The duskmoth: stats, rests when the player is far, wakes within 300 px, flies 2-4 s, rests >= 1 s,
## dies from one hit, and stays inside the room while flying.

const SCENE := "res://scenes/enemies/duskmoth.tscn"
const START := Vector2(400, 300)
## Player offset used to keep the player in wake range without ever touching the moth.
const NEAR := Vector2(200, 0)


func run() -> void:
	await _stats()
	await _rests_when_far()
	await _wakes_within_300()
	await _flight_then_rest()
	await _dies_from_one_hit()
	await _stays_in_room()


func _stats() -> void:
	reset_state()
	var arena := make_arena()
	var moth: Variant = make_enemy(arena, SCENE, START)
	await frames(2)
	check_eq(moth.hp, 1, "duskmoth has 1 hp")
	check_eq(moth.max_hp, 1, "duskmoth max hp is 1")
	check_eq(moth.contact_damage, 1, "duskmoth contact damage is 1")
	check_eq(moth.move_speed, 260.0, "duskmoth speed is 260 px/s")
	check(not moth.is_flying(), "duskmoth starts resting")
	await dispose(arena)


func _rests_when_far() -> void:
	reset_state()
	var arena := make_arena()
	var moth: Variant = make_enemy(arena, SCENE, START)
	make_player(arena, START + Vector2(400, 0))
	await frames(2)
	var flew := false
	var moved := false
	for _i in range(240):
		await frames(1)
		flew = flew or moth.is_flying()
		moved = moved or moth.velocity.length() > 0.0
	check(not flew, "duskmoth stays resting while the player is 400 px away")
	check(not moved, "a resting duskmoth does not move")
	await dispose(arena)


func _wakes_within_300() -> void:
	reset_state()
	var arena := make_arena()
	var moth: Variant = make_enemy(arena, SCENE, START)
	var player := make_player(arena, START + NEAR)
	await frames(2)
	var took_off: bool = await _wait_for_flight(moth, player, 180)
	check(took_off, "duskmoth starts flying when the player is within 300 px")
	await dispose(arena)


func _flight_then_rest() -> void:
	reset_state()
	var arena := make_arena()
	var moth: Variant = make_enemy(arena, SCENE, START)
	var player := make_player(arena, START + NEAR)
	await frames(2)
	var took_off: bool = await _wait_for_flight(moth, player, 180)
	check(took_off, "duskmoth takes off before the flight-time check")
	# Flight: 2-4 s, i.e. 120-240 frames at 60 fps; a frame of slack for signal ordering.
	var flight_frames := 0
	while moth.is_flying() and flight_frames < 360:
		_pin(player, moth)
		await frames(1)
		flight_frames += 1
	check(flight_frames >= 118 and flight_frames <= 242, "flight lasts 2-4 s (got %d frames)" % flight_frames)
	# Rest: at least 1.0 s (60 frames) before it can wake again, even with the player in range.
	var rest_frames := 0
	var rest_moved := false
	while not moth.is_flying() and rest_frames < 300:
		_pin(player, moth)
		await frames(1)
		rest_moved = rest_moved or moth.velocity.length() > 0.0
		rest_frames += 1
	check(rest_frames >= 59, "duskmoth rests at least 1 s (got %d frames)" % rest_frames)
	check(not rest_moved, "duskmoth is still while resting")
	check(moth.is_flying(), "duskmoth wakes again after the rest")
	await dispose(arena)


func _dies_from_one_hit() -> void:
	reset_state()
	var arena := make_arena()
	var moth: Variant = make_enemy(arena, SCENE, START)
	make_player(arena, START + Vector2(600, 0))
	await frames(2)
	make_hitbox(arena, moth.global_position, Layers.Team.PLAYER, 1, 30.0)
	await frames(3)
	check(not is_instance_valid(moth), "duskmoth dies from one hit")
	await dispose(arena)


func _stays_in_room() -> void:
	reset_state()
	var walls: Array[Rect2] = [
		Rect2(0, 0, 800, 50), Rect2(0, 550, 800, 50), Rect2(0, 0, 50, 600), Rect2(750, 0, 50, 600)
	]
	var arena := make_arena(walls)
	var moth: Variant = make_enemy(arena, SCENE, START)
	moth.room_rect = Rect2(0, 0, 800, 600)
	var player := make_player(arena, START + NEAR)
	await frames(2)
	var took_off: bool = await _wait_for_flight(moth, player, 180)
	check(took_off, "duskmoth takes off in the walled room")
	var min_pos: Vector2 = moth.global_position
	var max_pos: Vector2 = moth.global_position
	var flying_frames := 0
	for _i in range(300):  # 5 s of simulated time
		_pin(player, moth)
		await frames(1)
		var p: Vector2 = moth.global_position
		min_pos = min_pos.min(p)
		max_pos = max_pos.max(p)
		if moth.is_flying():
			flying_frames += 1
	check(
		min_pos.x >= 0.0 and min_pos.y >= 0.0 and max_pos.x <= 800.0 and max_pos.y <= 600.0,
		"duskmoth stays inside the room rect while flying"
	)
	check(
		min_pos.x >= 50.0 and min_pos.y >= 50.0 and max_pos.x <= 750.0 and max_pos.y <= 550.0,
		"duskmoth stays inside the walls while flying"
	)
	check(flying_frames >= 110, "duskmoth flies during the 5 s window (got %d frames)" % flying_frames)
	check(max_pos.distance_to(min_pos) > 50.0, "duskmoth covers ground")
	await dispose(arena)


## Keeps the player at a fixed offset from the moth so it stays in wake range and never touches it.
func _pin(player: Player, moth: Variant) -> void:
	player.global_position = moth.global_position + NEAR


## Waits up to `max_frames` for the moth to start flying, keeping the player pinned near it.
func _wait_for_flight(moth: Variant, player: Player, max_frames: int) -> bool:
	for _i in range(max_frames):
		_pin(player, moth)
		await frames(1)
		if moth.is_flying():
			return true
	return false
