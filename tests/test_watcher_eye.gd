extends TestCase
## Watcher eye and its beam bolt: stats, the closed lid, the axis trigger, the beam, the ward block,
## the sling kill while the lid is open, facing toward the room's nearest wall.

const EYE_SCENE := "res://scenes/enemies/watcher_eye.tscn"
const BEAM_SCENE := "res://scenes/enemies/beam_bolt.tscn"
## Interior of a 1920x960 room with 96 px walls.
const INTERIOR := Rect2(96, 96, 1728, 768)
const EYE_AT := Vector2(144, 480)


func run() -> void:
	await _stats()
	await _faces_nearest_wall()
	await _lid_closed_ignores_sling()
	await _fires_beam_on_axis()
	await _no_fire_off_axis_or_out_of_range()
	await _ward_blocks_beam()
	await _sling_kills_open_eye()


func _stats() -> void:
	reset_state()
	var arena := make_arena()
	var eye := make_enemy(arena, EYE_SCENE, EYE_AT)
	await frames(2)
	check_eq(eye.hp, 2, "watcher eye has 2 hp")
	check_eq(eye.contact_damage, 0, "watcher eye has no contact damage")
	check_near(eye.move_speed, 0.0, 0.01, "watcher eye does not move")
	check(eye.invulnerable, "watcher eye starts with its lid closed")
	check(eye.get_node_or_null("Visual") != null, "watcher eye has a Visual child")
	await dispose(arena)


func _faces_nearest_wall() -> void:
	reset_state()
	var arena := make_arena()
	var eye := make_enemy(arena, EYE_SCENE, EYE_AT)
	eye.room_rect = INTERIOR
	await frames(2)
	check(eye.facing_dir.is_equal_approx(Vector2.RIGHT), "eye on the west wall faces east")
	var south := make_enemy(arena, EYE_SCENE, Vector2(960, 820))
	south.room_rect = INTERIOR
	await frames(2)
	check(south.facing_dir.is_equal_approx(Vector2.UP), "eye on the south wall faces north")
	await dispose(arena)


func _lid_closed_ignores_sling() -> void:
	reset_state()
	var arena := make_arena()
	var eye := make_enemy(arena, EYE_SCENE, EYE_AT)
	eye.room_rect = INTERIOR
	await frames(2)
	var sling := _sling_at(arena, EYE_AT)
	await frames(2)
	check_eq(eye.hp, 2, "a sling hit on the closed lid does nothing")
	await dispose(sling)
	await dispose(arena)


func _fires_beam_on_axis() -> void:
	reset_state()
	var arena := make_arena()
	var eye := make_enemy(arena, EYE_SCENE, EYE_AT)
	eye.room_rect = INTERIOR
	make_player(arena, EYE_AT + Vector2(300, 0))
	await frames(2)
	var beam := await _wait_for_beam(arena, 3.0)
	check(beam != null, "eye fires a beam at a player on its axis")
	if beam != null:
		check(beam.direction.is_equal_approx(Vector2.RIGHT), "beam flies along the eye's axis")
		check_eq(beam.damage, 2, "beam bolt deals 2 half-hearts")
		check_near(beam.speed, 300.0, 0.01, "beam bolt flies at 300 px/s")
		check(beam.shape_capsule, "beam bolt is a capsule")
	await dispose(arena)


func _no_fire_off_axis_or_out_of_range() -> void:
	reset_state()
	var arena := make_arena()
	var eye := make_enemy(arena, EYE_SCENE, EYE_AT)
	eye.room_rect = INTERIOR
	var player := make_player(arena, EYE_AT + Vector2(300, 60))
	await seconds(3.0)
	check(_first_beam(arena) == null, "no beam when the player is 60 px off the axis")
	player.global_position = EYE_AT + Vector2(150, 0)
	await seconds(3.0)
	check(_first_beam(arena) == null, "no beam when the player is closer than 192 px")
	await dispose(arena)


func _ward_blocks_beam() -> void:
	reset_state()
	var arena := make_arena()
	var eye := make_enemy(arena, EYE_SCENE, EYE_AT)
	eye.room_rect = INTERIOR
	var player := make_player(arena, EYE_AT + Vector2(300, 0))
	await frames(2)
	await _face(player, &"move_left")
	Input.action_press(&"ward")
	await frames(3)
	check(player.ward_up, "ward is up")
	var before := GameState.health
	var beam := await _wait_for_beam(arena, 3.0)
	var spawned := beam != null
	await seconds(1.0)
	check(spawned, "eye fires a beam at the warded player")
	check_eq(GameState.health, before, "ward takes no damage from the beam")
	check(not is_instance_valid(beam), "ward destroys the beam bolt")
	release_inputs()
	await dispose(arena)


func _sling_kills_open_eye() -> void:
	reset_state()
	var arena := make_arena()
	var eye := make_enemy(arena, EYE_SCENE, EYE_AT)
	eye.room_rect = INTERIOR
	await frames(2)
	eye.stun(1.5)
	await frames(2)
	check(not eye.invulnerable, "a stunned eye opens its lid")
	var sling := _sling_at(arena, EYE_AT)
	await frames(2)
	check(not is_instance_valid(eye) or eye.is_dead, "sling kills the eye while the lid is open")
	await dispose(sling)
	await dispose(arena)


## Waits up to `limit` seconds for a beam bolt in `parent`. Returns it or null.
func _wait_for_beam(parent: Node, limit: float) -> EnemyProjectile:
	var waited := 0.0
	while waited < limit:
		var beam := _first_beam(parent)
		if beam != null:
			return beam
		await frames(1)
		waited += 1.0 / 60.0
	return null


func _first_beam(parent: Node) -> EnemyProjectile:
	for child in parent.get_children():
		if child is EnemyProjectile:
			return child as EnemyProjectile
	return null


## A sling-kind hitbox at `at`, active, radius 30. Free it with dispose().
func _sling_at(parent: Node, at: Vector2) -> Hitbox:
	var hitbox := make_hitbox(parent, at, Layers.Team.PLAYER, 2, 30.0)
	hitbox.kind = &"sling"
	return hitbox


func _face(player: Player, action: StringName) -> void:
	Input.action_press(action)
	await frames(2)
	Input.action_release(action)
	await frames(6)
	player.velocity = Vector2.ZERO
