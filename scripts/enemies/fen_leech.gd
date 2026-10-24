extends EnemyBase
## Fen leech: a water lurker (monsters-bosses-tools 2.1). 3 hp, contact 2 (one heart). It lives in one shallows
## zone (group `shallows`, scripts/world/shallow_zone.gd) and never leaves it; its water is the zone's rectangle.
##
## Cycle:
##   SUBMERGED  glides at 150 px/s to the point of its zone nearest Tamsin. Invulnerable, no contact, only
##              ripples show. Trigger: Tamsin within 300 px and at least 1.5 s submerged since the last dive.
##   TELEGRAPH  0.5 s, bubbles, it surfaces. Not hittable.
##   LUNGE      toward Tamsin's position at the end of the telegraph: 420 px/s for up to 240 px, clamped to the
##              zone (it stops at the shore). Contact damage 2, not blockable. Not hittable.
##   SURFACED   1.2 s, still. The only hittable window; the moth stuns it here.
##   DIVE       0.3 s, submerging. Not hittable.
## It does NOT declare a class_name (WP files must not; see docs/code-contract.md).

const GLIDE_SPEED := 150.0
const TRIGGER_RANGE := 300.0
const MIN_SUBMERGED := 1.5
const TELEGRAPH_TIME := 0.5
const LUNGE_SPEED := 420.0
const LUNGE_DISTANCE := 240.0
const SURFACED_TIME := 1.2
const DIVE_TIME := 0.3
const RIPPLE_INTERVAL := 0.5
const RIPPLE_RADIUS := 14.0
const RIPPLE_COLOR := Color(0.8, 0.9, 1.0, 0.5)
const BUBBLE_COLOR := Color(0.85, 0.95, 1.0, 0.8)
const ZONE_GROUP := &"shallows"
## Ember is 35 % of this monster's drops (standard table: 25 %). The rest of the table is standard.
const EMBER_CHANCE := 0.35
const STANDARD_EMBER_CHANCE := 0.25

enum State { SUBMERGED, TELEGRAPH, LUNGE, SURFACED, DIVE }

var _state: State = State.SUBMERGED
## Seconds left in a timed state. In SUBMERGED: seconds submerged since the last dive.
var _timer: float = 0.0
var _lunge_dir := Vector2.ZERO
var _lunge_left: float = 0.0
var _ripple_wait: float = 0.0
var _zone: Area2D = null


func _init() -> void:
	_register_kind()
	max_hp = 3
	contact_damage = 2
	move_speed = GLIDE_SPEED
	visual_kind = &"fen_leech"
	body_radius = 26.0
	water_only = true
	ignore_water = true


static func _register_kind() -> void:
	if not Placeholder.has_kind(&"fen_leech"):
		Placeholder.register_kind(
			&"fen_leech", {"shape": "diamond", "color": Color(0.16, 0.14, 0.13), "radius": 26.0}
		)


func _enemy_ready() -> void:
	_enter(State.SUBMERGED, 0.0)


## True while submerged (hidden, invulnerable, no contact).
func is_submerged() -> bool:
	return _state == State.SUBMERGED


## True in the surfaced window (the only hittable state).
func is_surfaced() -> bool:
	return _state == State.SURFACED


## True during the lunge.
func is_lunging() -> bool:
	return _state == State.LUNGE


func _enemy_physics(delta: float) -> void:
	match _state:
		State.SUBMERGED:
			_submerged_physics(delta)
		State.TELEGRAPH:
			velocity = Vector2.ZERO
			_timer -= delta
			if _timer <= 0.0:
				_start_lunge()
		State.LUNGE:
			_lunge_physics(delta)
		State.SURFACED:
			velocity = Vector2.ZERO
			_timer -= delta
			if _timer <= 0.0:
				_enter(State.DIVE, DIVE_TIME)
		State.DIVE:
			velocity = Vector2.ZERO
			_timer -= delta
			if _timer <= 0.0:
				_enter(State.SUBMERGED, 0.0)


func _on_death() -> void:
	drops_enabled = false
	var parent := get_parent()
	if parent == null:
		return
	var kind := drop_for_roll(drop_roll_override if drop_roll_override >= 0.0 else randf())
	if kind != &"":
		PickupBase.spawn(kind, parent, global_position)


## Drop kind for a roll in [0, 1): ember 35 %, then the standard table shifted by the 10 % extra ember.
static func drop_for_roll(roll: float) -> StringName:
	if roll < EMBER_CHANCE:
		return &"ember"
	return DropTable.pick(
		roll - (EMBER_CHANCE - STANDARD_EMBER_CHANCE),
		GameState.has_item(&"pitch_pot"),
		GameState.has_item(&"tallow_sling")
	)


# ---- States ----------------------------------------------------------------------------------


## Sets the state and its rules: hittable only when surfaced, contact only during the lunge, the
## Visual shows only above water.
func _enter(state: State, time: float) -> void:
	_state = state
	_timer = time
	invulnerable = state != State.SURFACED
	set_contact_enabled(state == State.LUNGE)
	if visual != null:
		visual.visible = state != State.SUBMERGED


func _submerged_physics(delta: float) -> void:
	velocity = Vector2.ZERO
	var zone := _home_zone()
	var player := get_player()
	if zone == null or player == null:
		return
	_timer += delta
	var target := player.global_position
	if _timer >= MIN_SUBMERGED and global_position.distance_to(target) <= TRIGGER_RANGE:
		_enter(State.TELEGRAPH, TELEGRAPH_TIME)
		_bubble()
		return
	var shore: Vector2 = zone.call(&"nearest_point", target)
	var to_shore := shore - global_position
	var dist := to_shore.length()
	if dist < 0.001:
		return
	velocity = to_shore.normalized() * minf(GLIDE_SPEED, dist / delta)
	_ripple_wait -= delta
	if _ripple_wait <= 0.0:
		_ripple_wait = RIPPLE_INTERVAL
		_ripple()


func _start_lunge() -> void:
	var to_target := player_position(global_position) - global_position
	_lunge_dir = to_target.normalized() if to_target.length_squared() > 0.0001 else facing_dir
	set_facing_dir(_lunge_dir)
	_lunge_left = LUNGE_DISTANCE
	_enter(State.LUNGE, 0.0)


func _lunge_physics(delta: float) -> void:
	var step := minf(LUNGE_SPEED * delta, _lunge_left)
	if hit_wall or not _zone_has(global_position + _lunge_dir * step):
		velocity = Vector2.ZERO
		_enter(State.SURFACED, SURFACED_TIME)
		return
	velocity = _lunge_dir * (step / delta)
	_lunge_left -= step
	if _lunge_left <= 0.0:
		_enter(State.SURFACED, SURFACED_TIME)


# ---- Water zone ------------------------------------------------------------------------------


## The zone this leech lives in. Found once (the zone that holds it, else the nearest one, and the
## leech is moved onto its shore). Null when the room has no shallows zone: the leech then stays put.
func _home_zone() -> Area2D:
	if is_instance_valid(_zone):
		return _zone
	_zone = null
	var best_dist := INF
	var best_shore := Vector2.ZERO
	for node in get_tree().get_nodes_in_group(ZONE_GROUP):
		var zone := node as Area2D
		if zone == null:
			continue
		if bool(zone.call(&"contains_point", global_position)):
			_zone = zone
			return _zone
		var shore: Vector2 = zone.call(&"nearest_point", global_position)
		var dist := global_position.distance_to(shore)
		if dist < best_dist:
			best_dist = dist
			best_shore = shore
			_zone = zone
	if _zone != null:
		global_position = best_shore
	return _zone


func _zone_has(pos: Vector2) -> bool:
	return _zone != null and bool(_zone.call(&"contains_point", pos))


# ---- Feedback --------------------------------------------------------------------------------


func _bubble() -> void:
	var parent := get_parent()
	if parent != null:
		Placeholder.puff(parent, global_position, BUBBLE_COLOR, RIPPLE_RADIUS * 1.5)


func _ripple() -> void:
	var parent := get_parent()
	if parent != null:
		Placeholder.puff(parent, global_position, RIPPLE_COLOR, RIPPLE_RADIUS)
