extends EnemyBase
## Brine crab: an armoured walker (monsters-bosses-tools 2.1). 4 hp, contact 2 (one heart).
##
## Strafe: it walks sideways relative to its facing at 110 px/s, and turns to face Tamsin at 80 degrees/s, so a
## fast flank beats it. The direction flips every 1.0 to 2.0 s or at a wall.
## Front guard: a hit from inside the front 140 degrees is blocked (spark, 0 damage). The flare and explosions
## pierce it, and it is down while the crab is stunned (base rule).
## Pincer lunge every 3.0 s (the period runs from one telegraph to the next):
##   TELEGRAPH  0.4 s, claws up, stands still, keeps turning to Tamsin.
##   LUNGE      160 px at 300 px/s along the facing. Contact damage 2 (melee, not blockable).
##   RECOVER    0.8 s, still, facing frozen, claws down.
## Drops: the standard table plus a guaranteed brass bit.
## It does NOT declare a class_name (WP files must not; see docs/code-contract.md).

const STRAFE_SPEED := 110.0
const TURN_SPEED_DEG := 80.0
const STRAFE_MIN := 1.0
const STRAFE_MAX := 2.0
const LUNGE_PERIOD := 3.0
const TELEGRAPH_TIME := 0.4
const LUNGE_SPEED := 300.0
const LUNGE_DISTANCE := 160.0
const RECOVER_TIME := 0.8
const GUARD_ARC_DEG := 140.0
const CLAWS_UP_SCALE := Vector2(1.2, 1.2)
const GUARANTEED_DROP := &"brass_bit"

enum State { STRAFE, TELEGRAPH, LUNGE, RECOVER }

var _state: State = State.STRAFE
## Seconds left in the strafe leg, the telegraph or the recovery.
var _timer: float = 0.0
## Seconds until the next lunge telegraph starts.
var _period_left: float = LUNGE_PERIOD
## +1 or -1: the side the crab walks to, relative to its facing.
var _side: float = 1.0
var _lunge_left: float = 0.0


func _init() -> void:
	_register_kind()
	max_hp = 4
	contact_damage = 2
	move_speed = STRAFE_SPEED
	visual_kind = &"brine_crab"
	body_radius = 30.0
	armor_front_deg = GUARD_ARC_DEG


static func _register_kind() -> void:
	if not Placeholder.has_kind(&"brine_crab"):
		Placeholder.register_kind(
			&"brine_crab", {"shape": "circle", "color": Color(0.55, 0.36, 0.24), "radius": 30.0}
		)


func _enemy_ready() -> void:
	_side = 1.0 if randf() < 0.5 else -1.0
	_timer = randf_range(STRAFE_MIN, STRAFE_MAX)


## True while the claws are up (telegraph).
func is_telegraphing() -> bool:
	return _state == State.TELEGRAPH


## True during the lunge.
func is_lunging() -> bool:
	return _state == State.LUNGE


func _enemy_physics(delta: float) -> void:
	_period_left -= delta
	match _state:
		State.STRAFE:
			_turn_to_player(delta)
			velocity = facing_dir.orthogonal() * _side * STRAFE_SPEED
			_timer -= delta
			if hit_wall or _timer <= 0.0:
				_side = -_side
				_timer = randf_range(STRAFE_MIN, STRAFE_MAX)
			if _period_left <= 0.0:
				_start_telegraph()
		State.TELEGRAPH:
			_turn_to_player(delta)
			velocity = Vector2.ZERO
			_timer -= delta
			if _timer <= 0.0:
				_start_lunge()
		State.LUNGE:
			var step := minf(LUNGE_SPEED * delta, _lunge_left)
			velocity = facing_dir * (step / delta)
			_lunge_left -= step
			if _lunge_left <= 0.0 or hit_wall:
				_start_recover()
		State.RECOVER:
			velocity = Vector2.ZERO
			_timer -= delta
			if _timer <= 0.0:
				_back_to_strafe()


func _on_death() -> void:
	var parent := get_parent()
	if parent != null:
		PickupBase.spawn(GUARANTEED_DROP, parent, global_position)


# ---- States ----------------------------------------------------------------------------------


## Turns the facing toward Tamsin at TURN_SPEED_DEG degrees per second (never faster).
func _turn_to_player(delta: float) -> void:
	var to_player := direction_to_player()
	if to_player == Vector2.ZERO:
		return
	var max_turn := deg_to_rad(TURN_SPEED_DEG) * delta
	set_facing_dir(facing_dir.rotated(clampf(facing_dir.angle_to(to_player), -max_turn, max_turn)))


func _start_telegraph() -> void:
	_state = State.TELEGRAPH
	_timer = TELEGRAPH_TIME
	_period_left = LUNGE_PERIOD
	if visual != null:
		visual.scale = CLAWS_UP_SCALE


func _start_lunge() -> void:
	_state = State.LUNGE
	_lunge_left = LUNGE_DISTANCE


func _start_recover() -> void:
	_state = State.RECOVER
	_timer = RECOVER_TIME
	if visual != null:
		visual.scale = Vector2.ONE


func _back_to_strafe() -> void:
	_state = State.STRAFE
	_timer = randf_range(STRAFE_MIN, STRAFE_MAX)
