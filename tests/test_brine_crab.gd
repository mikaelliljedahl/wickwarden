extends TestCase
## The brine crab: stats, sideways strafing, the turn to Tamsin at 80 degrees/s, the front guard (flare and
## pot pierce it, a stun drops it), the pincer lunge (160 px at 300 px/s, contact damage, still recovery), and
## the guaranteed brass bit.

const SCENE := "res://scenes/enemies/brine_crab.tscn"
const ROOM := Rect2(0, 0, 1920, 960)
const POS := Vector2(960, 480)


func run() -> void:
	await _stats()
	await _strafes_sideways()
	await _turns_toward_tamsin()
	await _front_guard()
	await _lunge()
	await _lunge_hurts_in_path()
	await _death_drops_brass_bit()
	await _visual_states()
	await _visual_fallback()


func _visual_states() -> void:
	reset_state()
	var arena := make_arena()
	var crab: Variant = make_enemy(arena, SCENE, POS)
	await frames(2)
	var art: SpriteVisual = crab.visual
	check(art is SpriteVisual, "painted crab is available")
	for pair in [[Vector2.RIGHT, "side"], [Vector2.LEFT, "side"], [Vector2.UP, "up"], [Vector2.DOWN, "down"]]:
		crab.set_facing_dir(pair[0])
		crab._start_telegraph()
		check_eq(String(art.animation), "warning_" + pair[1], "directional warning")
		check_eq(art.flip_h, pair[0] == Vector2.LEFT, "side warning mirrors left")
		check(
			art.material is CanvasItemMaterial
			and art.material.light_mode == CanvasItemMaterial.LIGHT_MODE_UNSHADED,
			"warning is visible without room light"
		)
		crab.stun(0.1)
		await frames(2)
		check(crab.is_telegraphing(), "stun pauses warning state")
		check_eq(String(art.animation), "warning_" + pair[1], "stun retains warning")
		crab._start_lunge()
		check_eq(String(art.animation), "lunge_" + pair[1], "directional lunge")
		check(art.material == null, "lunge restores material")
		crab._start_recover()
		check_eq(String(art.animation), "idle_" + pair[1], "directional recovery")
		check(art.auto_motion, "recovery restores automatic motion")
	crab._start_telegraph()
	crab.set_facing_dir(Vector2.UP)
	check_eq(String(art.animation), "warning_up", "turning updates warning")
	crab._start_lunge()
	crab._start_recover()
	crab._back_to_strafe()
	await frames(15)
	check(String(art.animation).begins_with("walk_"), "strafing resumes walk after recovery")
	await dispose(arena)

	var incomplete := make_arena()
	var partial: Variant = make_enemy(incomplete, SCENE, POS)
	await frames(2)
	partial.visual.sprite_frames = partial.visual.sprite_frames.duplicate()
	partial.visual.sprite_frames.remove_animation(&"warning_up")
	partial._start_telegraph()
	check_eq(partial.visual.scale, Vector2(1.2, 1.2), "incomplete action art uses fallback")
	partial._start_lunge()
	partial._start_recover()
	check_eq(partial.visual.scale, Vector2.ONE, "partial art restores scale")
	await dispose(incomplete)


func _visual_fallback() -> void:
	reset_state()
	SpriteVisual.use_manifest("res://missing_crab_manifest.json")
	var arena := make_arena()
	var crab: Variant = make_enemy(arena, SCENE, POS)
	await frames(2)
	check(not crab.visual is SpriteVisual, "missing art uses placeholder")
	crab._start_telegraph()
	check_eq(crab.visual.scale, Vector2(1.2, 1.2), "placeholder warning keeps original scale")
	crab._start_lunge()
	crab._start_recover()
	check_eq(crab.visual.scale, Vector2.ONE, "placeholder recovery restores scale")
	await dispose(arena)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)


func _stats() -> void:
	reset_state()
	var arena := make_arena()
	var crab: Variant = make_enemy(arena, SCENE, POS)
	await frames(2)
	check_eq(crab.hp, 4, "brine crab has 4 hp")
	check_eq(crab.contact_damage, 2, "brine crab contact damage is 2 (one heart)")
	check_near(crab.move_speed, 110.0, 0.01, "brine crab strafes at 110 px/s")
	check_near(crab.armor_front_deg, 140.0, 0.01, "brine crab front guard is 140 degrees")
	check(crab.get_node_or_null("Visual") != null, "brine crab has a Visual child")
	await dispose(arena)


func _strafes_sideways() -> void:
	reset_state()
	var arena := make_arena()
	var crab: Variant = make_enemy(arena, SCENE, POS)
	crab.room_rect = ROOM
	make_player(arena, POS + Vector2(400, 0))
	crab.set_facing_dir(Vector2.RIGHT)
	await frames(2)
	check_near(crab.velocity.x, 0.0, 2.0, "strafing has (almost) no motion along the facing")
	check_near(absf(crab.velocity.y), 110.0, 0.5, "strafing moves sideways at 110 px/s")
	await dispose(arena)


func _turns_toward_tamsin() -> void:
	reset_state()
	var arena := make_arena()
	var crab: Variant = make_enemy(arena, SCENE, POS)
	crab.room_rect = ROOM
	make_player(arena, POS + Vector2(0, -400))
	crab.set_facing_dir(Vector2.RIGHT)
	await frames(2)
	var before: float = crab.facing_dir.angle()
	await frames(10)
	var turned := absf(angle_difference(before, crab.facing_dir.angle()))
	check_near(
		rad_to_deg(turned), 10.0 * 80.0 / 60.0, 0.6, "the crab turns to Tamsin at 80 degrees/s"
	)
	await dispose(arena)


func _front_guard() -> void:
	reset_state()
	var arena := make_arena()
	var crab: Variant = make_enemy(arena, SCENE, POS)
	crab.room_rect = ROOM
	crab.set_facing_dir(Vector2.RIGHT)
	await frames(2)
	await _hit(arena, crab, Vector2(60, 0), 2, &"hook")
	check_eq(crab.hp, 4, "a hook from the front is blocked by the guard")
	await _hit(arena, crab, Vector2(60, 0), 1, &"flare")
	check_eq(crab.hp, 3, "a charge flare from the front pierces the guard")
	await _hit(arena, crab, Vector2(60, 0), 1, &"explosion")
	check_eq(crab.hp, 2, "an explosion (pot) from the front pierces the guard")
	await _hit(arena, crab, Vector2(-60, 0), 1, &"hook")
	check_eq(crab.hp, 1, "a hook from behind hurts")
	crab.hp = 4
	await frames(20)
	await _hit(arena, crab, Vector2(0, 60), 1, &"hook")
	check_eq(crab.hp, 3, "a hook from the side hurts")
	crab.hp = 4
	await frames(20)
	crab.stun(0.5)
	await _hit(arena, crab, Vector2(60, 0), 1, &"hook")
	check_eq(crab.hp, 3, "the guard is down while the crab is stunned")
	await dispose(arena)


func _lunge() -> void:
	reset_state()
	var arena := make_arena()
	var crab: Variant = make_enemy(arena, SCENE, POS)
	crab.room_rect = ROOM
	crab.set_facing_dir(Vector2.RIGHT)
	await frames(2)
	var telegraph_wait: int = await _wait_until(func() -> bool: return crab.is_telegraphing(), 200)
	check(telegraph_wait >= 150 and telegraph_wait <= 185, "first lunge telegraph after about 3 s")
	var lunge_wait: int = await _wait_until(func() -> bool: return crab.is_lunging(), 40)
	check(
		lunge_wait >= 22 and lunge_wait <= 28, "telegraph lasts 0.4 s (got %d frames)" % lunge_wait
	)
	var start: Vector2 = crab.global_position
	var facing: Vector2 = crab.facing_dir
	var lunge_frames := 0
	while crab.is_lunging() and lunge_frames < 60:
		await frames(1)
		lunge_frames += 1
	var end: Vector2 = crab.global_position
	check_near(end.distance_to(start), 160.0, 1.0, "lunge covers 160 px")
	check((end - start).normalized().dot(facing) > 0.99, "lunge goes along the facing")
	check(
		lunge_frames >= 30 and lunge_frames <= 34,
		"lunge takes 160 px at 300 px/s (about 32 frames)"
	)
	var still_from: Vector2 = crab.global_position
	await frames(20)
	check(
		crab.global_position.distance_to(still_from) < 0.5,
		"the crab stands still while it recovers"
	)
	await dispose(arena)


func _lunge_hurts_in_path() -> void:
	reset_state()
	var arena := make_arena()
	var crab: Variant = make_enemy(arena, SCENE, POS)
	crab.room_rect = ROOM
	crab.set_facing_dir(Vector2.RIGHT)
	var player := make_player(arena, POS + Vector2(120, 0))
	var hits := [0]
	player.hurt_taken.connect(func(_amount: int) -> void: hits[0] += 1)
	await frames(2)
	await _wait_until(func() -> bool: return crab.is_lunging(), 240)
	await frames(30)
	check(hits[0] >= 1, "the lunge hurts Tamsin in its path")
	await dispose(arena)


func _death_drops_brass_bit() -> void:
	reset_state()
	var arena := make_arena()
	var crab: Variant = make_enemy(arena, SCENE, POS)
	crab.drop_roll_override = 0.99
	await frames(2)
	crab.kill()
	await frames(2)
	var bits := 0
	for child in arena.get_children():
		if child is PickupBase and (child as PickupBase).kind == &"brass_bit":
			bits += 1
	check_eq(bits, 1, "the brine crab always drops a brass bit")
	await dispose(arena)


## A hitbox of `kind` at `offset` from the crab's current position, for two physics frames, then freed.
## Waits out the 0.25 s enemy i-frames after a landed hit (20 frames), so hits in a row all count.
func _hit(parent: Node, crab: Variant, offset: Vector2, damage: int, kind: StringName) -> void:
	var hitbox := make_hitbox(
		parent, crab.global_position + offset, Layers.Team.PLAYER, damage, 40.0
	)
	hitbox.kind = kind
	await frames(2)
	await dispose(hitbox)
	await frames(20)


## Waits frame by frame until `done` is true or `limit` frames pass. Returns the frames waited.
func _wait_until(done: Callable, limit: int) -> int:
	for i in range(limit):
		if done.call():
			return i
		await frames(1)
	return limit
