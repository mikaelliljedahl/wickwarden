extends TestCase
## Player: movement speed, facing, swing damage and arc, charge flare, ward, i-frames, knockback.


func run() -> void:
	await _movement_speed()
	await _facing()
	await _swing()
	await _charge_flare()
	await _ward()
	await _iframes_and_knockback()
	await _death()


func _movement_speed() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena)
	check(
		(player.collision_mask & Layers.WATER) != 0,
		"player body collision mask includes deep water"
	)
	await frames(2)
	Input.action_press(&"move_right")
	await frames(10)
	check_near(player.velocity.x, 360.0, 0.5, "walks right at 360 px/s")
	var x0 := player.global_position.x
	await frames(30)
	check_near(player.global_position.x - x0, 180.0, 1.0, "moves 180 px in 0.5 s")
	Input.action_release(&"move_right")
	await frames(5)
	check_near(
		player.velocity.length(), 0.0, 0.5, "stops within 0.06 s (instant start, short stop)"
	)
	Input.action_press(&"move_right")
	Input.action_press(&"move_down")
	await frames(10)
	check_near(player.velocity.length(), 360.0, 1.0, "diagonal speed is normalised to 360")
	release_inputs()
	await frames(6)
	await dispose(arena)


func _facing() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena)
	await frames(2)
	check_eq(player.facing, Vector2.DOWN, "starts facing down")
	Input.action_press(&"move_left")
	await frames(2)
	check_eq(player.facing, Vector2.LEFT, "facing follows the last cardinal input")
	Input.action_press(&"move_up")
	await frames(2)
	check_eq(player.facing, Vector2.LEFT, "diagonal keeps the facing when one axis matches")
	Input.action_release(&"move_left")
	await frames(2)
	check_eq(player.facing, Vector2.UP, "releasing one axis turns to the other")
	Input.action_press(&"move_right")
	await frames(2)
	check_eq(player.facing, Vector2.UP, "diagonal up-right keeps up")
	release_inputs()
	await frames(6)
	await dispose(arena)


func _face(player: Player, action: StringName) -> void:
	Input.action_press(action)
	await frames(2)
	Input.action_release(action)
	await frames(6)
	player.velocity = Vector2.ZERO


func _swing() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(500, 500))
	await frames(2)
	await _face(player, &"move_right")
	var start := player.global_position
	var front := make_dummy(arena, start + Vector2(90, 0), 6)
	var far := make_dummy(arena, start + Vector2(190, 0), 6)
	var side := make_dummy(arena, start + Vector2(0, 100), 6)
	var back := make_dummy(arena, start + Vector2(-90, 0), 6)
	await frames(3)
	Input.action_press(&"attack")
	await frames(1)
	Input.action_release(&"attack")
	check(player.is_swinging(), "attack starts a swing")
	await frames(2)
	player.velocity = Vector2.ZERO
	var swing_pos := player.global_position
	await frames(5)
	check_eq(front.hp, 4, "swing deals 2 damage (one heart) to the target in front")
	check_eq(far.hp, 6, "swing reach is 120 px")
	check_eq(side.hp, 6, "swing arc is 110 degrees: 90 degrees off-axis is not hit")
	check_eq(back.hp, 6, "swing does not hit behind")
	check(front.global_position.x > start.x + 90.0 + 20.0, "swing knocks the enemy back")
	check_eq(player.global_position, swing_pos, "player cannot move during the active frames")
	await seconds(0.4)
	check(not player.is_swinging(), "swing ends after 0.28 s")
	check_eq(front.hp, 4, "one swing hits a target only once")
	await dispose(arena)


func _charge_flare() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(500, 500))
	await frames(2)
	var start := player.global_position
	var east := make_dummy(arena, start + Vector2(120, 0), 8)
	var west := make_dummy(arena, start + Vector2(-120, 0), 8)
	var far := make_dummy(arena, start + Vector2(0, 220), 8)
	await frames(3)
	Input.action_press(&"attack")
	await seconds(0.5)
	check(player.charging, "holding attack past the swing charges")
	check(not player.charge_ready, "not ready before 0.8 s")
	Input.action_press(&"move_right")
	await frames(6)
	check_near(absf(player.velocity.x), 180.0, 1.0, "movement is 50 % while charging")
	Input.action_release(&"move_right")
	await frames(6)
	player.velocity = Vector2.ZERO
	await seconds(0.4)
	check(player.charge_ready, "charge is ready after 0.8 s")
	Input.action_release(&"attack")
	var flare_seen := false
	for i in range(10):
		await frames(1)
		flare_seen = flare_seen or player.state == Player.State.FLARE
	check(flare_seen, "releasing a full charge fires the flare")
	check(east.hp < 8 and west.hp < 8, "flare is a 360 degree sweep")
	check_eq(far.hp, 8, "flare reach is 140 px")
	check_eq(west.hp, 4, "flare deals 4 damage")
	await dispose(arena)
	# A short press never fires a flare.
	reset_state()
	arena = make_arena()
	player = make_player(arena, Vector2(500, 500))
	var target := make_dummy(arena, player.global_position + Vector2(0, 160), 8)
	await frames(2)
	Input.action_press(&"attack")
	await seconds(0.4)
	Input.action_release(&"attack")
	await seconds(0.5)
	check_eq(target.hp, 8, "a half-charged release does not fire a flare")
	await dispose(arena)


func _ward() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(500, 500))
	await frames(2)
	await _face(player, &"move_right")
	Input.action_press(&"ward")
	await frames(3)
	check(player.ward_up, "ward raised while the button is held")
	Input.action_press(&"move_left")
	await frames(6)
	check_near(absf(player.velocity.x), 144.0, 1.0, "movement is 40 % while warding")
	check_eq(player.facing, Vector2.RIGHT, "facing is locked while warding")
	release_inputs()
	await frames(8)
	Input.action_press(&"ward")
	await frames(2)
	var front := EnemyProjectile.fire(arena, player.global_position + Vector2(200, 0), Vector2.LEFT)
	await frames(60)
	check(
		not is_instance_valid(front) or front.is_destroyed,
		"ward destroys a projectile from the front"
	)
	check_eq(GameState.health, 6, "ward takes no damage from the front")
	var behind := EnemyProjectile.fire(
		arena, player.global_position + Vector2(-200, 0), Vector2.RIGHT
	)
	await frames(60)
	check_eq(GameState.health, 5, "projectile from behind hurts")
	check(
		not is_instance_valid(behind) or behind.is_destroyed, "projectile is destroyed by the hit"
	)
	await seconds(1.0)
	var unblockable := EnemyProjectile.new()
	unblockable.blockable_by_ward = false
	arena.add_child(unblockable)
	unblockable.launch(player.global_position + Vector2(200, 0), Vector2.LEFT)
	await frames(60)
	check_eq(GameState.health, 4, "a non-blockable projectile ignores the ward")
	release_inputs()
	await seconds(1.0)
	var side := EnemyProjectile.fire(arena, player.global_position + Vector2(0, 200), Vector2.UP)
	Input.action_press(&"ward")
	await frames(60)
	check_eq(GameState.health, 3, "ward does not cover the sides (front 120 degrees only)")
	check(is_instance_valid(side) == false or side.is_destroyed, "side projectile consumed")
	await dispose(arena)


func _iframes_and_knockback() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(500, 500))
	await frames(2)
	var hitbox := make_hitbox(
		arena, player.global_position + Vector2(-20, 0), Layers.Team.ENEMY, 1, 250.0
	)
	hitbox.once_per_target = false
	hitbox.knockback = 640.0
	hitbox.knockback_time = 0.14
	var start_x := player.global_position.x
	await frames(3)
	check_eq(GameState.health, 5, "enemy hitbox deals 1 half-heart")
	check(player.is_invulnerable(), "i-frames start after a hit")
	await frames(10)
	check_near(
		player.global_position.x - start_x,
		640.0 * 0.14,
		12.0,
		"knockback 640 px/s for 0.14 s, away from the source"
	)
	var blinked := false
	var shown := false
	for i in range(30):
		await frames(1)
		blinked = blinked or not player.visual.visible
		shown = shown or player.visual.visible
	check(blinked and shown, "the sprite blinks during i-frames")
	check_eq(GameState.health, 5, "no second hit during the 0.9 s i-frames")
	await seconds(0.6)
	check(GameState.health <= 4, "hits land again after 0.9 s")
	hitbox.deactivate()
	await seconds(1.0)
	check(not player.is_invulnerable(), "i-frames end")
	check(player.visual.visible, "sprite is visible after the blink")
	await dispose(arena)


func _death() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(500, 500))
	await frames(2)
	var died := [false]
	player.died.connect(func() -> void: died[0] = true)
	player.take_damage(6, player.global_position + Vector2(10, 0))
	check(died[0], "player dies at 0 health")
	check(player.is_dead(), "dead state is set")
	player.respawn(Vector2(300, 300))
	check(not player.is_dead(), "respawn clears the dead state")
	check_eq(player.global_position, Vector2(300, 300), "respawn moves the player")
	await dispose(arena)
