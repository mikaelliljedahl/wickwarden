extends EnemyBase
## Hollow: a wax-husk knight. 4 hp, contact damage 2 (one heart), walks at 140 px/s.
##
## Grid walking: the hollow walks from tile centre to tile centre (tile 96 px, room-local grid).
## At each tile centre it may pick a new random cardinal direction (50 %) and it turns when the next
## tile centre is blocked (a wall or the room edge).
##
## Charge: when the player is on the same row or column (within 40 px on the other axis) and in
## front of or beside the hollow (not directly behind its facing), it faces the player and charges
## at 300 px/s for 0.5 s. It then recovers for 0.6 s (stands still, cannot charge) and snaps back
## onto the grid. A hit or a stun during the charge ends it early.
## It does NOT declare a class_name (WP files must not; see docs/code-contract.md).

const TILE := 96.0
const TILE_HALF := 48.0
const GRID_EPSILON := 0.5
const TURN_CHANCE := 0.5
const CHARGE_SPEED := 300.0
const CHARGE_TIME := 0.5
const RECOVER_TIME := 0.6
const ALIGN_TOLERANCE := 40.0
const DIRECTIONS: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

enum State { GRID, CHARGE, RECOVER }

var _state: State = State.GRID
var _timer: float = 0.0
var _probe: CircleShape2D = null


func _init() -> void:
	max_hp = 4
	contact_damage = 2
	move_speed = 140.0
	visual_kind = &"hollow"
	body_radius = 30.0


func _enemy_ready() -> void:
	_probe = CircleShape2D.new()
	_probe.radius = body_radius
	_state = State.GRID
	set_facing_dir(DIRECTIONS[randi() % DIRECTIONS.size()])


## True while the hollow is in its charge (0.5 s).
func is_charging() -> bool:
	return _state == State.CHARGE


func _enemy_physics(delta: float) -> void:
	match _state:
		State.CHARGE:
			_timer -= delta
			if _timer > 0.0:
				velocity = facing_dir * CHARGE_SPEED
			else:
				_enter_recover()
		State.RECOVER:
			velocity = Vector2.ZERO
			_timer -= delta
			if _timer <= 0.0:
				_state = State.GRID
		_:
			_grid_physics(delta)


func _on_hurt(_hitbox: Hitbox) -> void:
	_interrupt_charge()


func _on_stunned(_seconds: float) -> void:
	_interrupt_charge()


func _interrupt_charge() -> void:
	if _state == State.CHARGE:
		_enter_recover()


# ---- Grid walking ----------------------------------------------------------------------------


func _grid_physics(delta: float) -> void:
	var pos := global_position
	if not _is_centre(_across(pos)):
		# Off the grid (after a charge, a knock or a stun): snap both axes to the tile centre.
		velocity = (_snap(pos) - pos) / delta
		return
	var charge := _charge_direction()
	if charge != Vector2.ZERO:
		_start_charge(charge)
		return
	if _is_centre(_along(pos)):
		if not _choose_direction():
			velocity = Vector2.ZERO
			return
	var next := _next_centre(_along(pos), _along(facing_dir))
	var step := minf(move_speed * delta, absf(next - _along(pos)))
	velocity = facing_dir * (step / delta)


## Picks the next direction at a tile centre. Returns false when every direction is blocked.
func _choose_direction() -> bool:
	var choice := facing_dir
	if randf() < TURN_CHANCE:
		choice = DIRECTIONS[randi() % DIRECTIONS.size()]
	if not _is_free(choice):
		choice = Vector2.ZERO
		var options: Array[Vector2] = DIRECTIONS.duplicate()
		options.shuffle()
		for option in options:
			if _is_free(option):
				choice = option
				break
	if choice == Vector2.ZERO:
		return false
	set_facing_dir(choice)
	return true


## True when the next tile centre in `dir` lies in the room and no wall covers it.
func _is_free(dir: Vector2) -> bool:
	var target := _snap(global_position) + dir * TILE
	if room_rect.size != Vector2.ZERO and not room_rect.grow(-body_radius).has_point(target):
		return false
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _probe
	query.transform = Transform2D(0.0, target)
	query.collision_mask = Layers.WORLD
	return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


# ---- Charge ----------------------------------------------------------------------------------


## Cardinal direction toward the player when the hollow may charge, else ZERO.
## The player must be aligned (within ALIGN_TOLERANCE on the other axis) and not directly behind.
func _charge_direction() -> Vector2:
	var player := get_player()
	if player == null:
		return Vector2.ZERO
	var to := player.global_position - global_position
	var candidates: Array[Vector2] = []
	if absf(to.y) <= ALIGN_TOLERANCE and absf(to.x) > body_radius:
		candidates.append(Vector2(signf(to.x), 0.0))
	if absf(to.x) <= ALIGN_TOLERANCE and absf(to.y) > body_radius:
		candidates.append(Vector2(0.0, signf(to.y)))
	for candidate in candidates:
		if candidate.dot(facing_dir) >= 0.0:
			return candidate
	return Vector2.ZERO


func _start_charge(dir: Vector2) -> void:
	_state = State.CHARGE
	_timer = CHARGE_TIME
	set_facing_dir(dir)
	velocity = facing_dir * CHARGE_SPEED


func _enter_recover() -> void:
	_state = State.RECOVER
	_timer = RECOVER_TIME
	velocity = Vector2.ZERO


# ---- Grid helpers ----------------------------------------------------------------------------


func _horizontal() -> bool:
	return absf(facing_dir.x) > 0.5


## Coordinate along the walking direction.
func _along(p: Vector2) -> float:
	return p.x if _horizontal() else p.y


## Coordinate across the walking direction (must stay on a tile centre line while walking).
func _across(p: Vector2) -> float:
	return p.y if _horizontal() else p.x


## Centre of the tile containing `v` (also the nearest tile centre).
func _snap_axis(v: float) -> float:
	return floorf(v / TILE) * TILE + TILE_HALF


func _snap(p: Vector2) -> Vector2:
	return Vector2(_snap_axis(p.x), _snap_axis(p.y))


func _is_centre(v: float) -> bool:
	return absf(v - _snap_axis(v)) < GRID_EPSILON


## The next tile centre strictly ahead of `v` in direction `sign_dir` (+1 or -1).
func _next_centre(v: float, sign_dir: float) -> float:
	var from := _snap_axis(v) if _is_centre(v) else v
	if sign_dir > 0.0:
		return TILE * (floorf((from - TILE_HALF) / TILE) + 1.0) + TILE_HALF
	return TILE * (ceilf((from - TILE_HALF) / TILE) - 1.0) + TILE_HALF
