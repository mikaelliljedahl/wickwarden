extends EnemyBase
## Husk hound (monsters-bosses-tools.md, 2.1): a fast charger. HP 2, contact 2, prowl 160 px/s.
##
## Prowl: toward Tamsin in a zigzag (35 degrees to either side, the side switches every 0.5-0.9 s).
## Every 1.4-2.2 s it checks alignment: same row or column within 48 px, 240 to 720 px away (aligned_axis).
## Aligned: a windup of 0.4 s (crouch, the telegraph), then a charge along that axis at 420 px/s up to 720 px or
## until a wall. A wall hit leaves it dizzy (a stun of 0.9 s, hittable). An open charge ends in a circle run:
## 220 px around Tamsin at 260 px/s for 1.0 s, in a random direction, then it prowls again.
## Packs (hounds in the same parent) share one windup token: one windup per 0.8 s (pack_ready).
## Ward: nothing to block (contact). It does NOT declare a class_name.

enum State { PROWL, WINDUP, CHARGE, CIRCLE }

const PROWL_ZIG_DEG := 35.0
const ZIG_TIME_MIN := 0.5
const ZIG_TIME_MAX := 0.9
const CHECK_MIN := 1.4
const CHECK_MAX := 2.2
const CHECK_RETRY := 0.2
const ALIGN_TOLERANCE := 48.0
const ALIGN_MIN := 240.0
const ALIGN_MAX := 720.0
const WINDUP_TIME := 0.4
const CHARGE_SPEED := 420.0
const CHARGE_RANGE := 720.0
const DIZZY_TIME := 0.9
const CIRCLE_SPEED := 260.0
const CIRCLE_RADIUS := 220.0
const CIRCLE_TIME := 1.0
const CIRCLE_CORRECTION := 4.0
const PACK_GAP := 0.8
const PACK_META := &"husk_pack_windup"
const CROUCH_SCALE := Vector2(1.15, 0.8)

var _state: State = State.PROWL
var _windup_left: float = 0.0
var _check_left: float = 0.0
var _zig_sign: float = 1.0
var _zig_left: float = 0.0
var _charge_dir: Vector2 = Vector2.RIGHT
var _charge_travelled: float = 0.0
var _circle_dir: float = 1.0
var _circle_left: float = 0.0


func _init() -> void:
	_register_kinds()
	max_hp = 2
	contact_damage = 2
	move_speed = 160.0
	visual_kind = &"husk_hound"
	body_radius = 26.0


func _enemy_ready() -> void:
	_enter_prowl()


func _enemy_physics(delta: float) -> void:
	match _state:
		State.PROWL:
			_prowl(delta)
		State.WINDUP:
			_windup(delta)
		State.CHARGE:
			_charge(delta)
		State.CIRCLE:
			_circle(delta)


## A stun (moth, or the dizzy after a wall) ends any windup, charge or circle run.
func _on_stunned(_seconds: float) -> void:
	_set_crouch(false)
	_enter_prowl()


## True when no hound in the same parent has started a windup within PACK_GAP seconds.
func pack_ready() -> bool:
	var holder := get_parent()
	if holder == null or not holder.has_meta(PACK_META):
		return true
	return _now() - float(holder.get_meta(PACK_META)) >= PACK_GAP


## Starts a windup and a charge along `dir` (a cardinal axis). Returns false when the pack token is busy or the
## hound is not prowling (a stunned or charging hound). The alignment check calls this.
func begin_charge(dir: Vector2) -> bool:
	if _state != State.PROWL or is_stunned() or not pack_ready():
		return false
	_charge_dir = dir.normalized()
	_state = State.WINDUP
	_windup_left = WINDUP_TIME
	var holder := get_parent()
	if holder != null:
		holder.set_meta(PACK_META, _now())
	set_facing_dir(_charge_dir)
	return true


## The axis (a cardinal unit vector) a hound at `offset` from Tamsin can charge along, or ZERO when it is not
## aligned: same row or column within ALIGN_TOLERANCE, the distance between ALIGN_MIN and ALIGN_MAX.
## `offset` is Tamsin's position minus the hound's position. The unit points toward Tamsin.
static func aligned_axis(offset: Vector2) -> Vector2:
	var across_x := absf(offset.y) <= ALIGN_TOLERANCE and _in_band(absf(offset.x))
	if across_x:
		return Vector2(signf(offset.x), 0.0)
	var across_y := absf(offset.x) <= ALIGN_TOLERANCE and _in_band(absf(offset.y))
	if across_y:
		return Vector2(0.0, signf(offset.y))
	return Vector2.ZERO


static func _in_band(distance: float) -> bool:
	return distance >= ALIGN_MIN and distance <= ALIGN_MAX


func _prowl(delta: float) -> void:
	var to_player := direction_to_player()
	if to_player == Vector2.ZERO:
		velocity = Vector2.ZERO
		return
	_zig_left -= delta
	if _zig_left <= 0.0:
		_zig_left = randf_range(ZIG_TIME_MIN, ZIG_TIME_MAX)
		_zig_sign = -_zig_sign
	velocity = to_player.rotated(_zig_sign * deg_to_rad(PROWL_ZIG_DEG)) * move_speed
	set_facing_dir(to_player)
	_check_left -= delta
	if _check_left <= 0.0:
		_check_alignment()


func _check_alignment() -> void:
	var offset := player_position(global_position) - global_position
	var axis := aligned_axis(offset)
	if axis == Vector2.ZERO:
		_check_left = randf_range(CHECK_MIN, CHECK_MAX)
	elif not begin_charge(axis):
		_check_left = CHECK_RETRY


func _windup(delta: float) -> void:
	velocity = Vector2.ZERO
	_set_crouch(true)
	_windup_left -= delta
	if _windup_left > 0.0:
		return
	_set_crouch(false)
	_state = State.CHARGE
	_charge_travelled = 0.0
	Audio.play_sfx(&"hollow_dash", global_position)


func _charge(delta: float) -> void:
	if hit_wall:
		stun(DIZZY_TIME)
		return
	velocity = _charge_dir * CHARGE_SPEED
	_charge_travelled += CHARGE_SPEED * delta
	if _charge_travelled >= CHARGE_RANGE:
		_start_circle()


func _start_circle() -> void:
	_state = State.CIRCLE
	_circle_left = CIRCLE_TIME
	_circle_dir = 1.0 if randf() < 0.5 else -1.0


func _circle(delta: float) -> void:
	_circle_left -= delta
	if _circle_left <= 0.0:
		_enter_prowl()
		return
	var radial := global_position - player_position(global_position)
	var normal := radial.normalized() if radial != Vector2.ZERO else Vector2.RIGHT
	var tangent := normal.orthogonal() * _circle_dir
	var correction := clampf(
		(CIRCLE_RADIUS - radial.length()) * CIRCLE_CORRECTION, -CIRCLE_SPEED, CIRCLE_SPEED
	)
	velocity = tangent * CIRCLE_SPEED + normal * correction
	set_facing_dir(tangent)


func _enter_prowl() -> void:
	_state = State.PROWL
	_check_left = randf_range(CHECK_MIN, CHECK_MAX)
	_zig_left = randf_range(ZIG_TIME_MIN, ZIG_TIME_MAX)


func _set_crouch(on: bool) -> void:
	if visual != null:
		visual.scale = CROUCH_SCALE if on else Vector2.ONE


static func _now() -> float:
	return Engine.get_physics_frames() / float(Engine.physics_ticks_per_second)


static func _register_kinds() -> void:
	if not Placeholder.has_kind(&"husk_hound"):
		Placeholder.register_kind(
			&"husk_hound", {"shape": "circle", "color": Color(0.62, 0.62, 0.66), "radius": 26.0}
		)
