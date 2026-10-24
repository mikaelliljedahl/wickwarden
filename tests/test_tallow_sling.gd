extends TestCase
## Tallow sling (T02): ammo spend and refusal, one slug on screen, the slug hits a stand-in eye switch
## (first hurtbox only), range and wall stop it, the recoil holds Tamsin still, the item ends with its slug.


func run() -> void:
	await _refuses_without_slugs()
	await _spends_one_slug_per_shot()
	await _hits_eye_switch_once()
	await _stops_at_range()
	await _stops_at_wall()
	await _recoil_holds_still()


func _items() -> Array:
	return get_tree().get_nodes_in_group(ItemBase.group_name(&"tallow_sling"))


func _slugs() -> Array:
	return get_tree().get_nodes_in_group(&"sling_slugs")


## A stand-in eye switch: a neutral Hurtbox that takes only `sling` hits and counts them.
func _make_eye(parent: Node, at: Vector2) -> Node2D:
	var eye := Node2D.new()
	eye.set_meta(&"hits", 0)
	parent.add_child(eye)
	eye.global_position = at
	var box := Hurtbox.new()
	box.team = Layers.Team.NEUTRAL
	box.add_circle(30.0)
	box.filter = func(hitbox: Hitbox) -> bool: return hitbox.kind == &"sling"
	eye.add_child(box)
	box.hurt.connect(
		func(_hitbox: Hitbox) -> void: eye.set_meta(&"hits", eye.get_meta(&"hits") + 1)
	)
	return eye


func _hits(eye: Node2D) -> int:
	return int(eye.get_meta(&"hits"))


func _refuses_without_slugs() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 500))
	await frames(2)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"tallow_sling")
	check_eq(GameState.slugs, 12, "the first pickup of the sling gives 12 slugs")
	GameState.add_slugs(-12)
	check(not player.use_item(), "no slugs: the use is refused")
	check_eq(GameState.slugs, 0, "a refused shot spends nothing")
	check_eq(_items().size(), 0, "a refused shot leaves no item in the tree")
	check_eq(_slugs().size(), 0, "a refused shot fires no slug")
	await dispose(arena)


func _spends_one_slug_per_shot() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 500))
	await frames(2)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"tallow_sling")
	check(player.use_item(), "a shot is fired with slugs in stock")
	check_eq(GameState.slugs, 11, "a shot costs one slug")
	check_eq(_slugs().size(), 1, "one slug is in the air")
	check(not player.use_item(), "a second shot is refused while a slug is on screen")
	check_eq(GameState.slugs, 11, "the refused shot costs nothing")
	await seconds(1.5)
	check_eq(_slugs().size(), 0, "the slug is gone after its range")
	check_eq(_items().size(), 0, "the item ends with its slug")
	check(player.use_item(), "after the slug is gone the next shot is fired")
	check_eq(GameState.slugs, 10, "the next shot spends one more slug")
	await seconds(1.5)
	await dispose(arena)


func _hits_eye_switch_once() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 500))
	await frames(2)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"tallow_sling")
	var eye := _make_eye(arena, Vector2(700, 500))
	var behind := _make_eye(arena, Vector2(820, 500))
	await frames(2)
	check(player.use_item(), "the shot is fired at the eye")
	await seconds(0.3)
	check_eq(_hits(eye), 0, "the slug has not reached the eye after 0.3 s")
	await seconds(0.7)
	check_eq(_hits(eye), 1, "the slug hits the eye once")
	check_eq(_hits(behind), 0, "the slug does not go on to the eye behind it")
	check_eq(_slugs().size(), 0, "the slug is spent by its first hit")
	check_eq(_items().size(), 0, "the item ends with the slug")
	check_eq(GameState.slugs, 11, "the hit does not refund the slug")
	await dispose(arena)


func _stops_at_range() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 500))
	await frames(2)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"tallow_sling")
	check(player.use_item(), "the shot is fired with nothing in its way")
	await seconds(1.0)
	check_eq(_slugs().size(), 1, "the slug is still flying at 1.0 s (range 840 px)")
	await seconds(0.5)
	check_eq(_slugs().size(), 0, "the slug is spent at its 840 px range")
	await dispose(arena)


func _stops_at_wall() -> void:
	reset_state()
	var wall := Rect2(Vector2(600, 300), Vector2(32, 400))
	var arena := make_arena([wall])
	var player := make_player(arena, Vector2(300, 500))
	await frames(2)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"tallow_sling")
	var behind := _make_eye(arena, Vector2(800, 500))
	await frames(2)
	check(player.use_item(), "the shot is fired at a wall")
	await seconds(0.8)
	check_eq(_slugs().size(), 0, "the slug stops at the WORLD wall")
	check_eq(_hits(behind), 0, "the slug does not pass through the wall")
	await dispose(arena)


func _recoil_holds_still() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 500))
	await frames(2)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"tallow_sling")
	Input.action_press(&"move_right")
	var start := player.global_position.x
	check(player.use_item(), "the shot is fired while walking")
	await frames(6)
	check_near(player.global_position.x, start, 0.5, "Tamsin stands still during the recoil")
	await seconds(0.5)
	Input.action_release(&"move_right")
	check(player.global_position.x > start + 20.0, "Tamsin walks again after the recoil")
	await seconds(1.5)
	await dispose(arena)
