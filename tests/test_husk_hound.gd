extends TestCase
## Husk hound (monsters-bosses-tools 2.1): stats, the prowl toward Tamsin, the alignment rule, a 0.4 s windup and a
## charge along the axis, the circle run after an open charge, a wall bonk that leaves it dizzy (0.9 s, hittable),
## the pack windup token, and the drop.

const HOUND := "res://scenes/enemies/husk_hound.tscn"
const HuskHoundScript := preload("res://scripts/enemies/husk_hound.gd")


func run() -> void:
	await _stats()
	_aligned_axis_rule()
	await _prowls_toward_tamsin()
	await _winds_up_then_charges_along_the_axis()
	await _open_charge_ends_in_a_circle_run()
	await _wall_bonk_leaves_it_dizzy()
	await _pack_shares_one_windup_token()
	await _aligned_check_starts_a_windup()
	await _drops_once()


## A hound instance of HOUND at `at`, typed as the hound script.
func _hound(parent: Node, at: Vector2) -> HuskHoundScript:
	return make_enemy(parent, HOUND, at) as HuskHoundScript


## A Node2D in group `player` that stands in for Tamsin (no hurtbox, no movement).
func _stand_in(parent: Node, at: Vector2) -> Node2D:
	var node := Node2D.new()
	node.add_to_group(&"player")
	parent.add_child(node)
	node.global_position = at
	return node


func _stats() -> void:
	reset_state()
	var arena := make_arena()
	var hound := _hound(arena, Vector2(960, 480))
	await frames(2)
	check_eq(hound.hp, 2, "husk hound has 2 hp")
	check_eq(hound.contact_damage, 2, "husk hound contact damage is 2")
	check_near(hound.move_speed, 160.0, 0.01, "husk hound prowls at 160 px/s")
	check(hound.contact_hitbox.active, "the husk hound's body is contact damage")
	check(hound.get_node_or_null("Visual") != null, "husk hound has a Visual child")
	await dispose(arena)


func _aligned_axis_rule() -> void:
	check_eq(HuskHoundScript.aligned_axis(Vector2(400, 20)), Vector2.RIGHT, "same row 400 px east")
	check_eq(HuskHoundScript.aligned_axis(Vector2(-300, -30)), Vector2.LEFT, "same row 300 px west")
	check_eq(
		HuskHoundScript.aligned_axis(Vector2(10, 500)), Vector2.DOWN, "same column 500 px south"
	)
	check_eq(
		HuskHoundScript.aligned_axis(Vector2(-12, -240)), Vector2.UP, "same column 240 px north"
	)
	check_eq(
		HuskHoundScript.aligned_axis(Vector2(100, 100)), Vector2.ZERO, "too close: not aligned"
	)
	check_eq(HuskHoundScript.aligned_axis(Vector2(800, 0)), Vector2.ZERO, "too far: not aligned")
	check_eq(HuskHoundScript.aligned_axis(Vector2(400, 400)), Vector2.ZERO, "diagonal: not aligned")
	check_eq(
		HuskHoundScript.aligned_axis(Vector2(400, 60)),
		Vector2.ZERO,
		"off the row by 60 px: not aligned"
	)


func _prowls_toward_tamsin() -> void:
	reset_state()
	var arena := make_arena()
	_stand_in(arena, Vector2(1000, 800))
	var hound := _hound(arena, Vector2(300, 300))
	await frames(2)
	var before := hound.global_position.distance_to(Vector2(1000, 800))
	await seconds(1.0)
	var after := hound.global_position.distance_to(Vector2(1000, 800))
	check(before - after > 80.0, "the hound prowls toward Tamsin")
	await dispose(arena)


func _winds_up_then_charges_along_the_axis() -> void:
	reset_state()
	var arena := make_arena()
	var hound := _hound(arena, Vector2(300, 400))
	await frames(2)
	check(hound.begin_charge(Vector2.RIGHT), "an idle hound starts a windup")
	check(
		not hound.begin_charge(Vector2.RIGHT), "a hound already winding up does not start another"
	)
	await seconds(0.2)
	check(hound.global_position.x - 300.0 < 2.0, "the windup holds the hound still")
	await seconds(0.7)
	var moved := hound.global_position.x - 300.0
	check(
		moved >= 150.0, "the charge covers ground at 420 px/s after the windup (moved %s)" % moved
	)
	check(absf(hound.global_position.y - 400.0) < 2.0, "the charge stays on its row")
	await dispose(arena)


func _open_charge_ends_in_a_circle_run() -> void:
	reset_state()
	var arena := make_arena()
	var tamsin := _stand_in(arena, Vector2(700, 400))
	var hound := _hound(arena, Vector2(300, 400))
	await frames(2)
	check(hound.begin_charge(Vector2.RIGHT), "the hound charges past Tamsin's row")
	await seconds(2.9)
	var dist := hound.global_position.distance_to(tamsin.global_position)
	check_near(
		dist, 220.0, 40.0, "after the open charge it circles 220 px around Tamsin (got %s)" % dist
	)
	check(not hound.is_stunned(), "an open charge does not stun")
	await dispose(arena)


func _wall_bonk_leaves_it_dizzy() -> void:
	reset_state()
	var arena := make_arena([Rect2(600, 200, 50, 400)])
	_stand_in(arena, Vector2(900, 400))
	var hound := _hound(arena, Vector2(300, 400))
	await frames(2)
	check(hound.begin_charge(Vector2.RIGHT), "the hound charges at the wall")
	await seconds(1.5)
	check(hound.is_stunned(), "a wall bonk leaves the hound dizzy")
	var hp_before := hound.hp
	hound.apply_damage(1, hound.global_position + Vector2(-30, 0))
	check_eq(hound.hp, hp_before - 1, "a dizzy hound can be hit")
	await seconds(1.0)
	check(not hound.is_stunned(), "the dizzy lasts 0.9 s")
	await dispose(arena)


func _pack_shares_one_windup_token() -> void:
	reset_state()
	var arena := make_arena()
	var first := _hound(arena, Vector2(300, 200))
	var second := _hound(arena, Vector2(300, 700))
	await frames(2)
	check(first.begin_charge(Vector2.RIGHT), "the first hound of a pack winds up")
	check(not second.pack_ready(), "the pack token is busy for 0.8 s")
	check(not second.begin_charge(Vector2.RIGHT), "the second hound waits for the token")
	await seconds(0.9)
	check(second.pack_ready(), "the token is free again after 0.8 s")
	check(second.begin_charge(Vector2.RIGHT), "the second hound winds up after the gap")
	await dispose(arena)


func _aligned_check_starts_a_windup() -> void:
	reset_state()
	var arena := make_arena()
	_stand_in(arena, Vector2(700, 400))
	var hound := _hound(arena, Vector2(300, 400))
	await frames(2)
	hound.set(&"_check_left", 0.0)
	await frames(1)
	var held := hound.global_position
	await seconds(0.2)
	check(
		hound.global_position.distance_to(held) < 0.5,
		"an aligned check starts the windup, the hound holds still"
	)
	await dispose(arena)


func _drops_once() -> void:
	reset_state()
	var arena := make_arena()
	var hound := _hound(arena, Vector2(300, 400))
	hound.drop_roll_override = 0.3
	await frames(2)
	hound.apply_damage(1, hound.global_position + Vector2(-30, 0))
	await seconds(0.4)
	hound.apply_damage(1, hound.global_position + Vector2(-30, 0))
	await frames(2)
	check(not is_instance_valid(hound), "the hound dies at 0 hp")
	check_eq(
		arena.get_children().filter(func(n: Node) -> bool: return n is PickupBase).size(),
		1,
		"the hound drops loot"
	)
	await dispose(arena)
