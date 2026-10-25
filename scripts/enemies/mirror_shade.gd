extends EnemyBase
## Mirror shade (monsters-bosses-tools.md, section 2.1, Mimic). It appears as a pair: the real shade and a
## decoy reflection at the point mirrored across the room's horizontal centre line (y' = 960 - y in room
## coordinates, that is y' = 2 * centre_y - y). The decoy is only a look: it copies the real shade's position,
## facing and fade, and it has no Hurtbox and no Hitbox.
##
## Fade-in 0.6 s (invulnerable, does not move), then the real shade stalks Tamsin at 200 px/s.
## Echo swing: 0.4 s after Tamsin starts a hook swing, if the real shade is within 150 px, it swings back at her
## (110 degree arc, reach 120, damage 2, knockback as a player hit, not blockable by the ward).
## Ward mirror: while Tamsin holds the ward the real shade's front 120 degrees is immune (armor_front_deg).
## Under a glow jar light (GlowJar.is_lit at the real shade's position) the decoy is gone and the real shade is
## drawn dark, a silhouette that casts a shadow.
## 3 hp, contact damage 2, speed 200. It does NOT declare a class_name (see docs/code-contract.md).

const GLOW_JAR_PATH := "res://scripts/items/glow_jar.gd"
const REAL_KIND := &"mirror_shade"
const DECOY_KIND := &"mirror_shade_decoy"
const DECOY_NAME := "Decoy"
const ECHO_NAME := "EchoSwing"
const APPEAR_TIME := 0.6
const ECHO_DELAY := 0.4
const ECHO_RANGE := 150.0
const ECHO_ARC_DEG := 110.0
const ECHO_REACH := 120.0
const ECHO_DAMAGE := 2
## Active time of the echo swing. The monster file gives no value; the hook's active time (0.12 s) is used.
const ECHO_ACTIVE := 0.12
## Knockback of a player hit (monsters-bosses-tools.md section 1.1: 640 px/s for 0.14 s).
const ECHO_KNOCKBACK := 640.0
const ECHO_KNOCKBACK_TIME := 0.14
const WARD_ARMOR_DEG := 120.0
const LIT_TINT := Color(0.12, 0.12, 0.16, 1.0)

## The glow jar script (T05), loaded at run time with a null check. Its static is_lit(pos) reads group `glow_light`.
var _glow_jar: Script
var _appear_time: float = APPEAR_TIME
var _echo_armed: bool = false
var _echo_wait: float = 0.0
var _echo_active: float = 0.0
var _watched: Player
var _decoy: Node2D
var _decoy_look: Node2D
var _echo: Hitbox


func _init() -> void:
	_register_kinds()
	max_hp = 3
	contact_damage = 2
	move_speed = 200.0
	visual_kind = REAL_KIND
	body_radius = 28.0


## Placeholder looks of the pair (placeholder visuals only).
static func _register_kinds() -> void:
	if not Placeholder.has_kind(REAL_KIND):
		Placeholder.register_kind(
			REAL_KIND, {"shape": "circle", "color": Color(0.1, 0.1, 0.14), "radius": 28.0}
		)
	if not Placeholder.has_kind(DECOY_KIND):
		Placeholder.register_kind(
			DECOY_KIND, {"shape": "circle", "color": Color(0.75, 0.82, 1.0, 0.45), "radius": 28.0}
		)


func _enemy_ready() -> void:
	invulnerable = true
	_glow_jar = load(GLOW_JAR_PATH) as Script
	_decoy = Node2D.new()
	_decoy.name = DECOY_NAME
	_decoy.top_level = true
	add_child(_decoy)
	_decoy_look = SpriteVisual.attach(_decoy, DECOY_KIND)
	if _decoy_look is SpriteVisual:
		(_decoy_look as SpriteVisual).auto_motion = false
	# Observe the body's presentation after SpriteVisual updates its motion animation.
	process_priority = 1
	_echo = _make_echo_hitbox()
	add_child(_echo)


## The reflection has no CharacterBody2D velocity to drive SpriteVisual's auto-motion.
## Copy presentation only; gameplay continues to use the real actor's state.
func _process(_delta: float) -> void:
	if not visual is SpriteVisual or not _decoy_look is SpriteVisual:
		return
	var body := visual as SpriteVisual
	var reflection := _decoy_look as SpriteVisual
	if not reflection.sprite_frames.has_animation(body.animation):
		return
	if body.is_playing():
		reflection.play(body.animation)
	else:
		reflection.animation = body.animation
		reflection.pause()
	reflection.set_frame_and_progress(body.frame, body.frame_progress)


func _enemy_physics(delta: float) -> void:
	_watch_player()
	armor_front_deg = WARD_ARMOR_DEG if _ward_up() else 0.0
	if _appear_time > 0.0:
		_appear_time = maxf(_appear_time - delta, 0.0)
		velocity = Vector2.ZERO
		if _appear_time <= 0.0:
			invulnerable = false
	else:
		_stalk()
		_tick_echo(delta)


## Runs the base (movement, confinement) first, so the decoy and the looks follow the final position.
func _physics_process(delta: float) -> void:
	super(delta)
	_refresh_looks()


func _on_death() -> void:
	_cancel_echo()
	_decoy.visible = false


## A stun freezes the shade: a pending or running echo swing is cancelled.
func _on_stunned(_seconds: float) -> void:
	_cancel_echo()


# ---- Behaviour -------------------------------------------------------------------------------


func _stalk() -> void:
	var to_player := direction_to_player()
	if to_player == Vector2.ZERO:
		velocity = Vector2.ZERO
		return
	velocity = to_player * move_speed
	set_facing_dir(to_player)


func _tick_echo(delta: float) -> void:
	if _echo_active > 0.0:
		_echo_active -= delta
		if _echo_active <= 0.0:
			_echo.deactivate()
	if _echo_armed:
		_echo_wait -= delta
		if _echo_wait <= 0.0:
			_echo_armed = false
			_try_echo()


func _try_echo() -> void:
	var player := get_player()
	if player == null:
		return
	var to_player := player.global_position - global_position
	if to_player.length() > ECHO_RANGE:
		return
	set_facing_dir(to_player)
	_echo.rotation = facing_dir.angle()
	_echo.activate()
	_echo_active = ECHO_ACTIVE
	Audio.play_sfx(&"swing", global_position)


func _on_player_swing(_swing_facing: Vector2) -> void:
	if is_dead:
		return
	_echo_armed = true
	_echo_wait = ECHO_DELAY


func _cancel_echo() -> void:
	_echo_armed = false
	_echo_active = 0.0
	if _echo != null:
		_echo.deactivate()


## Connects to the player's hook swing once the player exists (the room may spawn the shade first).
func _watch_player() -> void:
	var player := get_player() as Player
	if player == null or (is_instance_valid(_watched) and _watched == player):
		return
	_watched = player
	player.swing_started.connect(_on_player_swing)


func _ward_up() -> bool:
	var player := get_player() as Player
	return player != null and player.ward_up


# ---- Looks -----------------------------------------------------------------------------------


## Decoy position, facing and fade follow the real shade; the decoy hides under a glow jar light.
func _refresh_looks() -> void:
	var fade := 1.0 - _appear_time / APPEAR_TIME
	var lit := _is_lit(global_position)
	var tint := LIT_TINT if lit else Color.WHITE
	tint.a = fade
	if visual != null:
		visual.modulate = tint
	_decoy.global_position = _mirror(global_position)
	_decoy.visible = not lit and not is_dead
	var decoy_tint := Color.WHITE
	decoy_tint.a = fade
	_decoy_look.modulate = decoy_tint
	_decoy_look.call("set_facing", facing_dir)


func _mirror(pos: Vector2) -> Vector2:
	if room_rect.size == Vector2.ZERO:
		return pos
	return Vector2(pos.x, 2.0 * room_rect.get_center().y - pos.y)


func _is_lit(pos: Vector2) -> bool:
	if _glow_jar == null:
		return false
	return bool(_glow_jar.call(&"is_lit", pos))


## Melee arc of the echo swing: a fan of CollisionPolygon2D points along +X, turned to face Tamsin.
func _make_echo_hitbox() -> Hitbox:
	var hitbox := Hitbox.new()
	hitbox.name = ECHO_NAME
	hitbox.team = Layers.Team.ENEMY
	hitbox.kind = &"echo"
	hitbox.damage = ECHO_DAMAGE
	hitbox.knockback = ECHO_KNOCKBACK
	hitbox.knockback_time = ECHO_KNOCKBACK_TIME
	hitbox.source = self
	hitbox.blockable = false
	var polygon := CollisionPolygon2D.new()
	var points := PackedVector2Array([Vector2.ZERO])
	var half := deg_to_rad(ECHO_ARC_DEG) * 0.5
	var steps := 10
	for i in range(steps + 1):
		points.append(Vector2.from_angle(-half + 2.0 * half * float(i) / float(steps)) * ECHO_REACH)
	polygon.polygon = points
	hitbox.add_child(polygon)
	return hitbox
