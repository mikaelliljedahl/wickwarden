extends TestCase
## Flare ring: after a flare the ring is visible, its radius is the flare reach, and it hides itself
## once the flare is over (Player.FLARE_TOTAL).


func run() -> void:
	await _ring_after_flare()


func _ring_after_flare() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(500, 500))
	await frames(2)
	var ring: Node2D = player._flare_visual
	check(not ring.visible, "the flare ring is hidden before a flare")
	player._start_flare()
	check(ring.visible, "the flare ring is visible after a flare")
	check_near(ring.call("get_radius"), Player.FLARE_REACH, 0.001, "ring radius is the flare reach")
	await seconds(Player.FLARE_TOTAL * 0.5)
	check(ring.visible, "the ring is still visible during the fade")
	await seconds(Player.FLARE_TOTAL)
	check(not ring.visible, "the ring hides itself after FLARE_TOTAL")
	player.reset_actions()
	await dispose(arena)
