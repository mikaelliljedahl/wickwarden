extends TestCase
## The fen leech and the shallows zone: stats and drops, zone geometry, immunity while submerged, the trigger
## (300 px, 1.5 s submerged), the lunge (contact only, clamped to the zone), the surfaced window, death.

const SCENE := "res://scenes/enemies/fen_leech.tscn"
const SCRIPT := "res://scripts/enemies/fen_leech.gd"
const ZONE_SCENE := "res://scenes/world/shallow_zone.tscn"
const ROOM := Rect2(0, 0, 1920, 960)
const POOL := Vector2(960, 480)
const POOL_SIZE := Vector2(1800, 800)


func run() -> void:
	await _warning_cleanup_probe()
	await _ripple_cleanup_probe()
	await _stats_and_drops()
	await _zone_geometry()
	await _submerged_is_immune()
	await _far_player_does_not_trigger()
	await _trigger_lunge_and_surfaced_window()
	await _lunge_stays_in_water()
	await _no_zone_no_motion()
	await _death_drops_ember()


func _stats_and_drops() -> void:
	reset_state()
	var arena := make_arena()
	var leech: Variant = make_enemy(arena, SCENE, POOL)
	await frames(2)
	check_eq(leech.hp, 3, "fen leech has 3 hp")
	check_eq(leech.contact_damage, 2, "fen leech contact damage is 2 (one heart)")
	check_near(leech.move_speed, 150.0, 0.01, "fen leech glides at 150 px/s")
	check(
		leech.water_only and leech.ignore_water, "fen leech lives in water and ignores deep water"
	)
	check(leech.get_node_or_null("Visual") != null, "fen leech has a Visual child")
	check(leech.is_submerged(), "fen leech starts submerged")
	check(leech.invulnerable, "fen leech is invulnerable while submerged")

	var script := load(SCRIPT) as GDScript
	check(script != null, "fen leech script loads")
	if script != null:
		check_eq(script.call(&"drop_for_roll", 0.1), &"ember", "ember at roll 0.10")
		check_eq(script.call(&"drop_for_roll", 0.34), &"ember", "ember is 35 % (roll 0.34)")
		check_eq(script.call(&"drop_for_roll", 0.36), &"brass_bit", "brass bit after ember (0.36)")
		check_eq(script.call(&"drop_for_roll", 0.95), &"", "nothing at roll 0.95")
		check_eq(script.call(&"drop_for_roll", 0.8), &"", "no pot bundle before the pitch pot")
		GameState.acquire_item(&"pitch_pot")
		check_eq(
			script.call(&"drop_for_roll", 0.8),
			&"pitch_pot_bundle",
			"pot bundle once pitch pot is found"
		)
	await dispose(arena)


func _zone_geometry() -> void:
	reset_state()
	var arena := make_arena()
	var zone: Variant = _make_zone(arena, POOL, Vector2(200, 100))
	await frames(2)
	check(zone.is_in_group(&"shallows"), "shallow zone is in group shallows")
	check(zone.get_node_or_null("Visual") != null, "shallow zone has a Visual child")
	check(bool(zone.call(&"contains_point", POOL)), "zone contains its centre")
	check(
		bool(zone.call(&"contains_point", POOL + Vector2(100, 50))),
		"zone contains its corner (edge included)"
	)
	check(not bool(zone.call(&"contains_point", POOL + Vector2(101, 0))), "zone stops at its edge")
	check_eq(
		zone.call(&"nearest_point", POOL + Vector2(300, 0)),
		POOL + Vector2(100, 0),
		"nearest point on the right edge"
	)
	check_eq(
		zone.call(&"nearest_point", POOL + Vector2(300, 300)),
		POOL + Vector2(100, 50),
		"nearest point at a corner"
	)
	check_eq(zone.call(&"nearest_point", POOL), POOL, "nearest point of an inside point is itself")
	await dispose(arena)


func _submerged_is_immune() -> void:
	reset_state()
	var arena := _arena_with_pool()
	var leech: Variant = make_enemy(arena, SCENE, Vector2(760, 480))
	leech.room_rect = ROOM
	make_player(arena, Vector2(1500, 480))
	await frames(2)
	await _hit(arena, leech.global_position, 2, &"hook")
	await _hit(arena, leech.global_position, 0, &"stun", 2.0)
	await frames(30)
	check_eq(leech.hp, 3, "submerged fen leech takes no hook damage")
	check(not leech.is_stunned(), "submerged fen leech takes no moth stun")
	check(leech.is_submerged(), "fen leech stays submerged while Tamsin is far")
	await dispose(arena)


func _far_player_does_not_trigger() -> void:
	reset_state()
	var arena := _arena_with_pool()
	var leech: Variant = make_enemy(arena, SCENE, Vector2(300, 480))
	leech.room_rect = ROOM
	make_player(arena, Vector2(1200, 480))
	await frames(2)
	var lunged := false
	for i in range(180):
		await frames(1)
		lunged = lunged or not leech.is_submerged()
	check(not lunged, "no trigger while Tamsin is more than 300 px away")
	check(leech.global_position.x > 400.0, "submerged fen leech glides toward Tamsin")
	await dispose(arena)


func _trigger_lunge_and_surfaced_window() -> void:
	reset_state()
	var arena := _arena_with_pool()
	var leech: Variant = make_enemy(arena, SCENE, Vector2(900, 480))
	leech.room_rect = ROOM
	var player := make_player(arena, Vector2(1150, 480))
	var hits := [0]
	player.hurt_taken.connect(func(_amount: int) -> void: hits[0] += 1)
	await frames(2)
	var waited: int = await _wait_until(func() -> bool: return not leech.is_submerged(), 180)
	check(waited >= 84 and waited <= 100, "trigger after 1.5 s submerged (got %d frames)" % waited)
	await _hit(arena, leech.global_position, 2, &"hook")
	check_eq(leech.hp, 3, "fen leech is not hurt while it telegraphs")
	var lunge_wait: int = await _wait_until(func() -> bool: return leech.is_lunging(), 60)
	check(lunge_wait >= 25 and lunge_wait <= 31, "tell lasts 0.5 s including the two hit-test frames")
	check(leech.get_node_or_null("BubbleWarning") == null, "warning ends with tell")
	check(leech.contact_hitbox.active, "contact damage is on during the lunge")
	var surfaced_wait: int = await _wait_until(func() -> bool: return leech.is_surfaced(), 120)
	check(surfaced_wait < 120, "fen leech surfaces after the lunge")
	check(not leech.contact_hitbox.active, "contact damage is off when surfaced")
	check(hits[0] >= 1, "the lunge hurts Tamsin standing in its path")
	await _hit(arena, leech.global_position, 2, &"hook")
	check_eq(leech.hp, 1, "a surfaced fen leech takes the hook (2 damage)")
	var dive_wait: int = await _wait_until(func() -> bool: return leech.is_submerged(), 120)
	check(dive_wait < 120, "fen leech dives back under")
	check(leech.invulnerable, "a diving fen leech is invulnerable again")
	await dispose(arena)


func _lunge_stays_in_water() -> void:
	reset_state()
	var arena := make_arena()
	var zone: Variant = _make_zone(arena, POOL, Vector2(240, 240))
	var leech: Variant = make_enemy(arena, SCENE, Vector2(900, 480))
	leech.room_rect = ROOM
	make_player(arena, Vector2(1130, 480))
	await frames(2)
	var rect: Rect2 = zone.call(&"global_rect")
	var inside := true
	var lunged := false
	for i in range(300):
		await frames(1)
		inside = inside and rect.grow(0.5).has_point(leech.global_position)
		lunged = lunged or leech.is_lunging() or leech.is_surfaced()
	check(inside, "fen leech never leaves its zone, lunge included")
	check(lunged, "fen leech lunged at Tamsin from the shore")
	await dispose(arena)


func _no_zone_no_motion() -> void:
	reset_state()
	var arena := make_arena()
	var leech: Variant = make_enemy(arena, SCENE, Vector2(900, 480))
	leech.room_rect = ROOM
	make_player(arena, Vector2(1150, 480))
	await frames(2)
	var start: Vector2 = leech.global_position
	await frames(180)
	check(leech.is_submerged(), "a fen leech with no shallows zone stays submerged")
	check(
		leech.global_position.distance_to(start) < 0.5,
		"a fen leech with no shallows zone does not move"
	)
	await dispose(arena)


func _death_drops_ember() -> void:
	reset_state()
	var arena := _arena_with_pool()
	var leech: Variant = make_enemy(arena, SCENE, Vector2(900, 480))
	leech.room_rect = ROOM
	leech.drop_roll_override = 0.1
	await frames(2)
	leech.kill()
	await frames(2)
	check(not is_instance_valid(leech), "fen leech dies and is freed")
	var embers := 0
	for child in arena.get_children():
		if child is PickupBase and (child as PickupBase).kind == &"ember":
			embers += 1
	check_eq(embers, 1, "fen leech drops one ember at roll 0.10")
	await dispose(arena)


## Arena with a shallows zone covering most of the room.
func _arena_with_pool() -> Node2D:
	var arena := make_arena()
	_make_zone(arena, POOL, POOL_SIZE)
	return arena


func _make_zone(parent: Node, at: Vector2, size: Vector2) -> Variant:
	var scene := load(ZONE_SCENE) as PackedScene
	var zone: Variant = scene.instantiate()
	zone.size = size
	parent.add_child(zone)
	zone.global_position = at
	return zone


## A hitbox of `kind` on `pos` for two physics frames, then freed.
func _hit(
	parent: Node, pos: Vector2, damage: int, kind: StringName, stun_time: float = 0.0
) -> void:
	var hitbox := make_hitbox(parent, pos, Layers.Team.PLAYER, damage)
	hitbox.kind = kind
	hitbox.stun_time = stun_time
	await frames(2)
	await dispose(hitbox)


## Waits frame by frame until `done` is true or `limit` frames pass. Returns the frames waited.
func _wait_until(done: Callable, limit: int) -> int:
	for i in range(limit):
		if done.call():
			return i
		await frames(1)
	return limit


func _warning_cleanup_probe() -> void:
	reset_state()
	var arena := _arena_with_pool()
	make_player(arena, Vector2(1150, 480))
	var first: Variant = make_enemy(arena, SCENE, Vector2(900, 480))
	var second: Variant = make_enemy(arena, SCENE, Vector2(1000, 480))
	await frames(2)
	first._enter(first.State.TELEGRAPH, first.TELEGRAPH_TIME)
	second._enter(second.State.TELEGRAPH, second.TELEGRAPH_TIME)
	first._bubble()
	second._bubble()
	var one: Node = first.get_node_or_null("BubbleWarning")
	var two: Node = second.get_node_or_null("BubbleWarning")
	check(one != null and two != null and one != two, "two leeches own separate warnings")
	check(one != null and one.get_child_count() == 1 and one.get_child(0) is PointLight2D, "warning owns its light")
	check(not first.contact_hitbox.active and first.invulnerable, "tell remains harmless and invulnerable")
	first._enter(first.State.LUNGE, 0.0)
	await frames(2)
	check(not is_instance_valid(one), "warning freed at end of tell")
	check(is_instance_valid(two), "other leech retains its warning")
	second.queue_free()
	await frames(2)
	check(not is_instance_valid(two), "warning freed with leech")
	first._enter(first.State.TELEGRAPH, first.TELEGRAPH_TIME)
	first._bubble()
	var room_warning: Node = first.get_node_or_null("BubbleWarning")
	check(room_warning != null, "warning exists before room removal")
	await dispose(arena)
	check(not is_instance_valid(room_warning), "room removal frees warning")


func _ripple_cleanup_probe() -> void:
	reset_state()
	var arena := _arena_with_pool()
	var leech: Variant = make_enemy(arena, SCENE, Vector2(900, 480))
	await frames(2)
	leech._ripple()
	var ripple := arena.get_node_or_null("WaterRipple") as Sprite2D
	check(ripple != null and ripple.texture != null, "submerged ripple uses painted art")
	await frames(20)
	check(not is_instance_valid(ripple), "painted ripple fades and is freed")
	await dispose(arena)
