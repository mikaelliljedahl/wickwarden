extends TestCase
## Player external motion (F7): a path through open ground and through a wall, the airborne leap
## that ignores damage, a death that restores the player, place_at() that ends the motion.


func run() -> void:
	await _straight_path()
	await _through_wall()
	await _airborne_leap()
	await _death_restores()
	await _place_ends_motion()
	await _action_locks()
	await _ride_across_rooms()
	await _speed_scales()
	await _hurtbox_sources()


func _straight_path() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(500, 500))
	await frames(2)
	var path: Array[Vector2] = [Vector2(800, 500), Vector2(800, 700)]
	var empty: Array[Vector2] = []
	var finished := [false]
	player.motion_finished.connect(func() -> void: finished[0] = true)
	check(not player.begin_external_motion(empty, 300.0), "an empty path is refused")
	check(not player.begin_external_motion(path, 0.0), "a speed of zero is refused")
	check(player.begin_external_motion(path, 300.0), "a motion starts on a free player")
	check(player.is_external_motion(), "the motion runs")
	check(not player.is_airborne(), "a walking motion is not airborne")
	check(not player.begin_external_motion(path, 300.0), "a second motion is refused")
	await frames(30)
	check_near(player.global_position.x, 650.0, 6.0, "moves 300 px/s along the first leg")
	check(not finished[0], "motion_finished does not fire half-way")
	await seconds(2.0)
	check(finished[0], "motion_finished fires at the last point")
	check_eq(player.global_position, Vector2(800, 700), "ends exactly at the target")
	check(not player.is_external_motion(), "the motion is over at the target")
	check(player.velocity == Vector2.ZERO, "no velocity after the motion")
	await dispose(arena)


func _through_wall() -> void:
	reset_state()
	var walls: Array[Rect2] = [Rect2(Vector2(560, 380), Vector2(40, 240))]
	var arena := make_arena(walls)
	var player := make_player(arena, Vector2(500, 500))
	await frames(2)
	var body := player.get_node("BodyShape") as CollisionShape2D
	var path: Array[Vector2] = [Vector2(700, 500)]
	player.begin_external_motion(path, 300.0)
	await frames(3)
	check(body.disabled, "the body shape is off during a motion")
	await seconds(1.0)
	check_near(player.global_position.x, 700.0, 0.5, "a motion passes through a wall")
	check(not player.is_external_motion(), "the motion ends at the target past the wall")
	await frames(2)
	check(not body.disabled, "the body shape is back on after the motion")
	await dispose(arena)


func _airborne_leap() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(500, 500))
	await frames(2)
	var path: Array[Vector2] = [Vector2(800, 500)]
	player.begin_external_motion(path, 600.0, {"airborne": true})
	check(player.is_airborne(), "the leap is airborne")
	var hitbox := make_hitbox(arena, player.global_position, Layers.Team.ENEMY, 2)
	await frames(3)
	check_eq(GameState.health, 6, "a hitbox does no damage during the leap")
	check(not player.take_damage(2, player.global_position), "take_damage is refused in the air")
	check_eq(GameState.health, 6, "scripted damage does nothing during the leap")
	hitbox.deactivate()
	await seconds(0.5)
	check(not player.is_airborne(), "the leap ends at the target")
	check(not player.is_external_motion(), "the leap is a motion that ended")
	check_eq(GameState.health, 6, "full health after the leap")
	check(player.hurtbox.enabled, "the hurtbox is back after the leap")
	await dispose(hitbox)
	await dispose(arena)


func _death_restores() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(500, 500))
	await frames(2)
	var path: Array[Vector2] = [Vector2(900, 500)]
	var finished := [false]
	player.motion_finished.connect(func() -> void: finished[0] = true)
	player.begin_external_motion(path, 300.0, {"hurtbox": false})
	await frames(3)
	check(not player.hurtbox.enabled, "the hurtbox can be off for a motion")
	player.take_damage(6, player.global_position + Vector2(10, 0))
	check(player.is_dead(), "the player dies during the motion")
	check(finished[0], "motion_finished fires when death ends the motion")
	check(not player.is_external_motion(), "death ends the motion")
	await frames(2)
	var body := player.get_node("BodyShape") as CollisionShape2D
	check(not body.disabled, "death restores the body shape")
	check(not player.hurtbox.enabled, "a dead player has no hurtbox")
	player.respawn(Vector2(300, 300))
	check(not player.is_dead(), "respawn clears death")
	check(player.hurtbox.enabled, "respawn restores the hurtbox")
	check_eq(player.global_position, Vector2(300, 300), "respawn moves the player")
	Input.action_press(&"move_right")
	await frames(10)
	check(player.velocity.x > 300.0, "controls work again after respawn")
	release_inputs()
	await frames(6)
	await dispose(arena)


func _place_ends_motion() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(500, 500))
	await frames(2)
	var path: Array[Vector2] = [Vector2(900, 500)]
	player.begin_external_motion(path, 300.0)
	await frames(3)
	player.reset_actions()
	check(player.is_external_motion(), "reset_actions (used by World slides) keeps the motion")
	player.place_at(Vector2(100, 100))
	check(not player.is_external_motion(), "place_at ends the motion")
	check_eq(player.global_position, Vector2(100, 100), "place_at teleports the player")
	await frames(2)
	var body := player.get_node("BodyShape") as CollisionShape2D
	check(not body.disabled, "the body shape is back on after place_at")
	await dispose(arena)


func _action_locks() -> void:
	reset_state()
	ItemRegistry.register(&"test_item", "res://tests/fixtures/test_item.tscn", "Test")
	GameState.acquire_item(&"test_item")
	var arena := make_arena()
	var player := make_player(arena, Vector2(500, 500))
	await frames(2)
	var other := Node.new()
	player.lock_actions(self, true)
	check(player.actions_locked(), "a lock is on")
	Input.action_press(&"attack")
	await frames(2)
	Input.action_release(&"attack")
	await frames(2)
	check(not player.is_swinging(), "a locked player does not swing")
	check(not player.use_item(), "a locked player does not use the item")
	player.lock_actions(other, true)
	player.lock_actions(self, false)
	check(player.actions_locked(), "another source's lock keeps the actions blocked")
	player.lock_actions(other, false)
	check(not player.actions_locked(), "all locks released")
	check(player.use_item(), "the item works again after the unlock")
	Input.action_press(&"attack")
	await frames(2)
	Input.action_release(&"attack")
	check(player.is_swinging(), "the hook works again after the unlock")
	player.lock_actions(self, true)
	check(not player.is_swinging(), "a lock cancels a swing that runs")
	player.lock_actions(self, false)
	other.free()
	await frames(20)
	await dispose(arena)


func _speed_scales() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(500, 500))
	await frames(2)
	var slow := Node.new()
	var other := Node.new()
	player.set_speed_scale(slow, 0.5)
	Input.action_press(&"move_right")
	await frames(10)
	check_near(player.velocity.x, 180.0, 1.0, "a speed scale of 0.5 halves walking")
	player.set_speed_scale(slow, 1.0)
	await frames(2)
	check_near(player.velocity.x, 360.0, 1.0, "a scale of 1.0 removes the entry")
	player.set_speed_scale(slow, 0.5)
	player.set_speed_scale(other, 0.5)
	await frames(10)
	check_near(player.velocity.x, 90.0, 1.0, "the factors of two sources multiply")
	release_inputs()
	await frames(6)
	slow.free()
	other.free()
	await dispose(arena)


func _hurtbox_sources() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(500, 500))
	await frames(2)
	var source := Node.new()
	player.set_hurtbox_enabled(source, false)
	check(not player.hurtbox.enabled, "a source can switch the hurtbox off")
	var hitbox := make_hitbox(arena, player.global_position, Layers.Team.ENEMY, 1)
	await frames(3)
	check_eq(GameState.health, 6, "no hit while the hurtbox is off")
	hitbox.deactivate()
	player.set_hurtbox_enabled(source, true)
	check(player.hurtbox.enabled, "the hurtbox is back when the source lets go")
	hitbox.activate()
	await frames(3)
	check_eq(GameState.health, 5, "a hit lands again")
	hitbox.deactivate()
	source.free()
	await dispose(hitbox)
	await dispose(arena)


## A ride (raft) that crosses a room edge: the World slide pauses the player and moves it, but the
## motion is not cancelled and it ends at its target in the next room.
func _ride_across_rooms() -> void:
	reset_state()
	var world := await make_world()
	world.start_at(&"ow_0_0")
	await frames(2)
	var player := world.player
	player.place_at(Vector2(1800, 500))
	await frames(2)
	var path: Array[Vector2] = [Vector2(2100, 500)]
	var finished := [false]
	player.motion_finished.connect(func() -> void: finished[0] = true)
	check(player.begin_external_motion(path, 300.0), "a ride starts in the start room")
	await seconds(0.6)
	check(world.is_transitioning(), "the camera slides into the next room during the ride")
	check(player.is_external_motion(), "the World slide does not cancel the ride")
	await seconds(2.0)
	check(finished[0], "the ride finishes after the slide")
	check_eq(player.global_position, Vector2(2100, 500), "the ride ends at its target")
	check_eq(world.current_room.room_id, &"ow_1_0", "the ride ends in the next room")
	check(not world.is_transitioning(), "the slide is over")
	await dispose(world)
