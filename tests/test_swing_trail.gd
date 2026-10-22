extends TestCase
## Swing trail: after a swing starts the trail is visible, and its sector covers exactly the hit
## arc (Player.SWING_ARC_DEG centred on the facing, radius Player.SWING_REACH) for all four facings.


func run() -> void:
	await _sector_matches_hit_arc()


func _sector_matches_hit_arc() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(500, 500))
	await frames(2)
	var half := deg_to_rad(Player.SWING_ARC_DEG) * 0.5
	var facings: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
	for dir in facings:
		player.reset_actions()
		player.facing = dir
		player._start_swing()
		var trail: Node2D = player._swing_visual
		check(trail.visible, "the swing trail is visible after _start_swing (%s)" % dir)
		var sector: Vector3 = trail.call("get_sector")
		check_near(
			sector.x, dir.angle() - half, 0.001, "sector starts half an arc before (%s)" % dir
		)
		check_near(sector.y, dir.angle() + half, 0.001, "sector ends half an arc after (%s)" % dir)
		check_near(
			sector.z, Player.SWING_REACH, 0.001, "sector radius is the swing reach (%s)" % dir
		)
	player.reset_actions()
	await dispose(arena)
