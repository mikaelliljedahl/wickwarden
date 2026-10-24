extends TestCase
## Choirling: stats, hover band, the cone shape, the cone hit, the ward block (the singer survives),
## the chime and moth stuns, death at 2 damage.

const CHOIRLING_SCENE := "res://scenes/enemies/choirling.tscn"
const NOTE_SCENE := "res://scenes/enemies/note.tscn"
## Telegraph (0.6 s) plus the first rest (1.3 s): the first song starts after about 1.9 s.
const FIRST_SONG_WAIT := 2.2


func run() -> void:
	await _stats()
	await _hovers_in_band()
	await _cone_shape()
	await _cone_hits_player()
	await _ward_blocks_cone()
	await _chime_stuns()
	await _moth_stuns()
	await _dies_after_two_damage()
	await _note_scene_loads()


func _stats() -> void:
	reset_state()
	var arena := make_arena()
	var singer := make_enemy(arena, CHOIRLING_SCENE, Vector2(600, 400))
	await frames(2)
	check_eq(singer.hp, 2, "choirling has 2 hp")
	check_eq(singer.contact_damage, 1, "choirling contact damage is 1")
	check_near(singer.move_speed, 90.0, 0.01, "choirling hovers at 90 px/s")
	check_near(singer.chime_stun_time, 2.5, 0.01, "choirling takes a 2.5 s chime stun")
	check(singer.ignore_water, "choirling flies over deep water")
	await dispose(arena)


func _hovers_in_band() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(600, 500))
	var singer := make_enemy(arena, CHOIRLING_SCENE, Vector2(900, 500))
	await frames(2)
	# Too close: it backs off (before its first song, which waits 1.3 s).
	player.global_position = singer.global_position + Vector2(-120, 0)
	await seconds(0.8)
	var gap := singer.global_position.distance_to(player.global_position)
	check(gap > 160.0, "choirling backs off when Tamsin is closer than 200 px")
	# Far away: it drifts in, and stops inside the band.
	player.global_position = singer.global_position + Vector2(-600, 0)
	await seconds(0.5)
	gap = singer.global_position.distance_to(player.global_position)
	check(gap < 580.0 and gap > 400.0, "choirling drifts in toward the 240 to 400 px band")
	await dispose(arena)


func _cone_shape() -> void:
	reset_state()
	var arena := make_arena()
	make_player(arena, Vector2(600, 500))
	var singer := make_enemy(arena, CHOIRLING_SCENE, Vector2(900, 500))
	await frames(2)
	var cone := await _wait_for_cone(singer, FIRST_SONG_WAIT + 1.0)
	check(cone != null, "choirling sings a cone")
	if cone != null:
		var poly := _cone_polygon(cone)
		check(poly.size() >= 3, "cone has a polygon")
		var reach := 0.0
		for point in poly:
			reach = maxf(reach, point.length())
		check_near(reach, 420.0, 1.0, "cone reaches 420 px")
		# The singer faces the player (to the west): the cone points west.
		check(Geometry2D.is_point_in_polygon(Vector2(-300, 0), poly), "cone covers its axis")
		check(
			not Geometry2D.is_point_in_polygon(Vector2(-300, -300), poly),
			"cone leaves 45 degrees out"
		)
		check(
			cone.origin().is_equal_approx(singer.global_position), "cone is attached to the singer"
		)
		check_eq(cone.damage, 2, "cone deals 2 half-hearts")
		check(cone.blockable, "cone can be blocked by the ward")
		check(not cone.block_destroys_carrier, "a ward block does not destroy the singer")
	await dispose(arena)


func _cone_hits_player() -> void:
	reset_state()
	var arena := make_arena()
	var singer := make_enemy(arena, CHOIRLING_SCENE, Vector2(600, 400))
	var player := make_player(arena, Vector2(900, 400))
	await frames(2)
	var before := GameState.health
	await seconds(FIRST_SONG_WAIT + 1.0)
	check_eq(GameState.health, before - 2, "cone hits the player in front for 2 half-hearts")
	check(is_instance_valid(singer), "singer is alive after singing")
	await dispose(arena)


func _ward_blocks_cone() -> void:
	reset_state()
	var arena := make_arena()
	var singer := make_enemy(arena, CHOIRLING_SCENE, Vector2(600, 400))
	var player := make_player(arena, Vector2(900, 400))
	await frames(2)
	await _face(player, &"move_left")
	Input.action_press(&"ward")
	await frames(3)
	check(player.ward_up, "ward is up")
	var before := GameState.health
	await seconds(FIRST_SONG_WAIT + 1.0)
	check_eq(GameState.health, before, "ward negates the cone")
	check(is_instance_valid(singer) and not singer.is_dead, "the singer survives a blocked cone")
	release_inputs()
	await dispose(arena)


func _chime_stuns() -> void:
	reset_state()
	var arena := make_arena()
	var singer := make_enemy(arena, CHOIRLING_SCENE, Vector2(600, 400))
	await frames(2)
	var chime := make_hitbox(arena, singer.global_position, Layers.Team.PLAYER, 0, 40.0)
	chime.kind = &"chime"
	await frames(2)
	check(singer.is_stunned(), "chime stuns the choirling")
	await seconds(2.0)
	check(singer.is_stunned(), "chime stun lasts past 2.0 s")
	await seconds(0.8)
	check(not singer.is_stunned(), "chime stun ends after 2.5 s")
	await dispose(chime)
	await dispose(arena)


func _moth_stuns() -> void:
	reset_state()
	var arena := make_arena()
	var singer := make_enemy(arena, CHOIRLING_SCENE, Vector2(600, 400))
	await frames(2)
	var moth := make_hitbox(arena, singer.global_position, Layers.Team.PLAYER, 0, 40.0)
	moth.stun_time = 2.0
	await frames(2)
	check(singer.is_stunned(), "moth stuns the choirling")
	await dispose(moth)
	await dispose(arena)


func _dies_after_two_damage() -> void:
	reset_state()
	var arena := make_arena()
	var singer := make_enemy(arena, CHOIRLING_SCENE, Vector2(600, 400))
	await frames(2)
	singer.apply_damage(1, singer.global_position + Vector2(-30, 0))
	check_eq(singer.hp, 1, "one damage leaves the choirling at 1 hp")
	await seconds(0.4)
	singer.apply_damage(1, singer.global_position + Vector2(-30, 0))
	await frames(2)
	check(not is_instance_valid(singer), "choirling dies after 2 damage")
	await dispose(arena)


## The treble note projectile scene (fired by the Dirge Choir fight): a homing projectile, 2 damage.
func _note_scene_loads() -> void:
	var scene := load(NOTE_SCENE) as PackedScene
	check(scene != null, "note scene loads")
	if scene == null:
		return
	var note := scene.instantiate() as EnemyProjectile
	check(note != null, "note is an EnemyProjectile")
	if note != null:
		check_eq(note.damage, 2, "note deals 2 half-hearts")
		check_near(note.homing_turn_deg, 120.0, 0.01, "note turns 120 degrees per second")
		check_near(note.lifetime, 3.0, 0.01, "note lives 3.0 s")
		note.free()


## Waits up to `limit` seconds for the singer's cone hitbox (a child Hitbox that is not the contact).
func _wait_for_cone(singer: EnemyBase, limit: float) -> Hitbox:
	var waited := 0.0
	while waited < limit:
		var cone := _find_cone(singer)
		if cone != null:
			return cone
		await frames(1)
		waited += 1.0 / 60.0
	return null


func _find_cone(singer: EnemyBase) -> Hitbox:
	for child in singer.get_children():
		if child is Hitbox and (child as Hitbox).blockable:
			return child as Hitbox
	return null


func _cone_polygon(cone: Hitbox) -> PackedVector2Array:
	var points := PackedVector2Array()
	for child in cone.get_children():
		if child is CollisionPolygon2D:
			for point in (child as CollisionPolygon2D).polygon:
				points.append(point.rotated(cone.rotation))
	return points


func _face(player: Player, action: StringName) -> void:
	Input.action_press(action)
	await frames(2)
	Input.action_release(action)
	await frames(6)
	player.velocity = Vector2.ZERO
