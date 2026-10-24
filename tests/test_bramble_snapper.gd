extends TestCase
## Bramble snapper: stats and placeholder, rooted (no movement, no knockback), trigger range 144 px,
## the 0.35 s telegraph, the 0.15 s cone that locks its aim, the 1.0 s rest, the moth does nothing,
## fire starts a 0.6 s burn and then kills it.

const SCENE := "res://scenes/enemies/bramble_snapper.tscn"
const ROOM := Rect2(0, 0, 1920, 960)
const SNAPPER_AT := Vector2(400, 300)
const NEAR := Vector2(500, 300)
const FAR := Vector2(900, 600)


func run() -> void:
	await _stats()
	await _rooted_and_trigger_range()
	await _telegraph_snap_rest_cycle()
	await _cone_and_locked_aim()
	await _moth_and_hook_do_not_move_it()
	await _fire_burns_then_dies()


func _stats() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, SNAPPER_AT)
	enemy.room_rect = ROOM
	await frames(2)
	check_eq(enemy.max_hp, 3, "snapper has 3 max hp")
	check_eq(enemy.hp, 3, "snapper starts at 3 hp")
	check_eq(enemy.contact_damage, 2, "snapper contact damage is 2")
	check_eq(enemy.move_speed, 0.0, "snapper never walks")
	check_eq(enemy.stun_scale, 0.0, "snapper is immune to the moth stun")
	check(enemy.is_in_group(&"burnable"), "snapper is in group burnable")
	check(enemy.has_method(&"on_fire"), "snapper has on_fire(pos)")
	check(Placeholder.has_kind(&"bramble_snapper"), "snapper registered its placeholder kind")
	check(enemy.get_node_or_null("Visual") != null, "snapper has a Visual child")
	check(enemy.snap_hitbox != null and not enemy.snap_hitbox.active, "snap cone starts off")
	await dispose(arena)


func _rooted_and_trigger_range() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, SNAPPER_AT)
	enemy.room_rect = ROOM
	var player := make_player(arena, FAR)
	await frames(2)
	for i in range(90):
		await frames(1)
	check(not enemy.is_telegraphing(), "no trigger beyond 144 px")
	check(enemy.global_position.distance_to(SNAPPER_AT) < 0.5, "snapper does not move")
	player.global_position = Vector2(400 + 150, 300)
	await frames(30)
	check(not enemy.is_telegraphing(), "no trigger at 150 px (outside 144 px)")
	player.global_position = NEAR
	await frames(2)
	check(enemy.is_telegraphing(), "trigger inside 144 px starts the telegraph")
	await dispose(arena)


func _telegraph_snap_rest_cycle() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, SNAPPER_AT)
	enemy.room_rect = ROOM
	var player := make_player(arena, NEAR)
	await frames(2)
	var telegraph_frames := 0
	while not enemy.is_snapping() and telegraph_frames < 120:
		player.global_position = NEAR
		await frames(1)
		telegraph_frames += 1
	check_near(
		telegraph_frames,
		21.0,
		2.0,
		"telegraph lasts about 0.35 s (got %d frames)" % telegraph_frames
	)
	var snap_frames := 0
	while enemy.is_snapping() and snap_frames < 60:
		player.global_position = NEAR
		await frames(1)
		snap_frames += 1
	check_near(snap_frames, 9.0, 2.0, "snap lasts about 0.15 s (got %d frames)" % snap_frames)
	check(not enemy.snap_hitbox.active, "snap cone is off after the snap")
	var rest_frames := 0
	while rest_frames < 50:
		player.global_position = NEAR
		await frames(1)
		rest_frames += 1
		check(not enemy.is_snapping(), "no snap during the closed-jaw rest")
		check(not enemy.is_telegraphing(), "no telegraph during the closed-jaw rest")
	var cycle_frames := 0
	while not enemy.is_telegraphing() and cycle_frames < 60:
		player.global_position = NEAR
		await frames(1)
		cycle_frames += 1
	check(enemy.is_telegraphing(), "the next telegraph comes after the 1.0 s rest")
	await dispose(arena)


func _cone_and_locked_aim() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, SNAPPER_AT)
	enemy.room_rect = ROOM
	var player := make_player(arena, NEAR)
	await frames(2)
	check(await _wait_for_snap(enemy, player, NEAR), "the snapper snaps at Tamsin")
	check(enemy.aim_direction().x > 0.99, "aim points at Tamsin (right) at the lock")
	check(absf(enemy.snap_hitbox.rotation) < 0.01, "cone is rotated to the locked aim")
	# Tamsin steps behind the snapper during the snap: the aim stays locked to the right.
	player.global_position = Vector2(300, 300)
	await frames(3)
	check(enemy.aim_direction().x > 0.99, "the aim stays locked after the telegraph")
	check(absf(enemy.snap_hitbox.rotation) < 0.01, "the cone does not turn toward Tamsin behind")
	var poly: PackedVector2Array = (enemy.snap_hitbox.get_child(0) as CollisionPolygon2D).polygon
	check(
		Geometry2D.is_point_in_polygon(Vector2(100, 0), poly), "cone covers 100 px straight ahead"
	)
	check(
		Geometry2D.is_point_in_polygon(Vector2(60, 100), poly),
		"cone covers a point at about 60 degrees"
	)
	check(not Geometry2D.is_point_in_polygon(Vector2(-60, 0), poly), "cone does not cover the back")
	check(not Geometry2D.is_point_in_polygon(Vector2(160, 0), poly), "cone stops at 150 px")
	await dispose(arena)

	reset_state()
	arena = make_arena()
	enemy = make_enemy(arena, SCENE, SNAPPER_AT)
	enemy.room_rect = ROOM
	player = make_player(arena, Vector2(300, 300))
	await frames(2)
	var hits := [0]
	enemy.snap_hitbox.hit_landed.connect(func(_hurtbox: Hurtbox) -> void: hits[0] += 1)
	check(
		await _wait_for_snap(enemy, player, Vector2(300, 300)),
		"the snapper snaps at Tamsin on the left"
	)
	check(enemy.aim_direction().x < -0.99, "the telegraph aims at Tamsin on the left")
	await frames(2)
	check(hits[0] >= 1, "a cone aimed at Tamsin hits her in front")
	await dispose(arena)


## Keeps Tamsin at `at` until the snapper snaps (bounded). True when it did.
func _wait_for_snap(enemy: Variant, player: Node2D, at: Vector2) -> bool:
	for i in range(120):
		if enemy.is_snapping():
			return true
		player.global_position = at
		await frames(1)
	return false


func _moth_and_hook_do_not_move_it() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, SNAPPER_AT)
	enemy.room_rect = ROOM
	await frames(2)
	var stun := make_hitbox(arena, SNAPPER_AT + Vector2(20, 0), Layers.Team.PLAYER, 0, 30.0)
	stun.kind = &"stun"
	stun.stun_time = 2.0
	await frames(2)
	check(not enemy.is_stunned(), "the moth stun does nothing to the snapper")
	await dispose(stun)
	check(enemy.apply_damage(2, SNAPPER_AT + Vector2(-40, 0)), "a hook hit is accepted")
	await frames(12)
	check(
		enemy.global_position.distance_to(SNAPPER_AT) < 0.5, "a hook hit does not push the snapper"
	)
	check_eq(enemy.hp, 1, "a 2 damage hook leaves the snapper at 1 hp")
	await dispose(arena)


func _fire_burns_then_dies() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(arena, SCENE, SNAPPER_AT)
	enemy.room_rect = ROOM
	var player := make_player(arena, FAR)
	await frames(2)
	var flame := make_hitbox(arena, SNAPPER_AT, Layers.Team.PLAYER, 1, 30.0)
	flame.kind = &"fire"
	await frames(2)
	flame.deactivate()
	check(enemy.is_burning(), "a fire touch starts the burn")
	check(enemy.can_be_hurt() == false, "a burning snapper cannot be hit")
	enemy.on_fire(SNAPPER_AT)
	await frames(30)
	check(is_instance_valid(enemy) and not enemy.is_dead, "the snapper still burns after 0.5 s")
	await frames(20)
	check(not is_instance_valid(enemy) or enemy.is_dead, "the snapper dies when the burn ends")
	check(is_instance_valid(player), "Tamsin is untouched by the burn")
	await dispose(arena)
