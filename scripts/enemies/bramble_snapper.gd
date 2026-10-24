extends EnemyBase
## Bramble snapper (monsters-bosses-tools section 2.1): a rooted biter that never moves.
## Trigger: Tamsin's centre within 144 px of its centre. Then a 0.35 s telegraph (cone marker; the
## aim follows Tamsin and locks at the end), a 0.15 s snap of a 180 degree cone (radius 150 px, toward
## the locked aim, damage 2), and 1.0 s of closed jaws during which it cannot trigger (cycle 1.5 s).
## The moth does nothing (stun_scale 0). A fire touch starts a 0.6 s burn; it then dies (fire damage 6).
## The bite is melee: the ward does not block it. It does NOT declare a class_name (see docs/code-contract.md).

const KIND := &"bramble_snapper"
const TRIGGER_RANGE := 144.0
const TELEGRAPH_TIME := 0.35
const SNAP_TIME := 0.15
const REST_TIME := 1.0
const SNAP_RADIUS := 150.0
const SNAP_ARC_DEG := 180.0
const SNAP_DAMAGE := 2
const SNAP_KNOCKBACK := 640.0
const SNAP_KNOCKBACK_TIME := 0.14
const ARC_SEGMENTS := 16
const BURN_TIME := 0.6
const FIRE_DAMAGE := 6
const BODY_RADIUS := 30.0
const BURN_TINT := Color(1.0, 0.55, 0.2)
const SWAY_SPEED := 2.0
const SWAY_ANGLE := 0.06
const TELEGRAPH_SCRIPT := "res://scripts/enemies/telegraph.gd"

enum State { IDLE, TELEGRAPH, SNAP, REST, BURNING }

## The cone hitbox of the snap. Off except during SNAP. Rotated to the locked aim.
var snap_hitbox: Hitbox

var _state: State = State.IDLE
var _timer: float = 0.0
var _aim: Vector2 = Vector2.DOWN
var _marker: Node2D
var _sway_clock: float = 0.0


func _init() -> void:
	max_hp = 3
	contact_damage = 2
	move_speed = 0.0
	visual_kind = KIND
	body_radius = BODY_RADIUS
	stun_scale = 0.0
	knockback_scale = 0.0
	_register_kind()


func _enemy_ready() -> void:
	add_to_group(&"burnable")
	snap_hitbox = Hitbox.new()
	snap_hitbox.name = "SnapHitbox"
	snap_hitbox.team = Layers.Team.ENEMY
	snap_hitbox.kind = &"contact"
	snap_hitbox.damage = SNAP_DAMAGE
	snap_hitbox.knockback = SNAP_KNOCKBACK
	snap_hitbox.knockback_time = SNAP_KNOCKBACK_TIME
	snap_hitbox.source = self
	snap_hitbox.active = false
	add_child(snap_hitbox)
	var shape := CollisionPolygon2D.new()
	shape.polygon = _cone_polygon()
	snap_hitbox.add_child(shape)


func _enemy_physics(delta: float) -> void:
	velocity = Vector2.ZERO
	match _state:
		State.IDLE:
			if _player_in_trigger_range():
				_begin_telegraph()
		State.TELEGRAPH:
			_track_aim()
			_timer -= delta
			if _timer <= 0.0:
				_begin_snap()
		State.SNAP:
			_timer -= delta
			if _timer <= 0.0:
				snap_hitbox.active = false
				_begin_rest()
		State.REST:
			_timer -= delta
			if _timer <= 0.0:
				_state = State.IDLE
		State.BURNING:
			_timer -= delta
			if _timer <= 0.0:
				_burn_out()


## Presentation only: a slow sway of the Visual while the snapper is rooted.
func _process(delta: float) -> void:
	_sway_clock += delta
	if visual != null:
		visual.rotation = sin(_sway_clock * SWAY_SPEED) * SWAY_ANGLE


## Fire burns it (a flame touch or a cinder wick). The first call starts a 0.6 s burn; later calls
## do nothing. The snapper is harmless while it burns and dies when the burn ends.
func on_fire(_pos: Vector2) -> void:
	if is_dead or _state == State.BURNING:
		return
	_state = State.BURNING
	_timer = BURN_TIME
	snap_hitbox.active = false
	set_contact_enabled(false)
	invulnerable = true
	_free_marker()
	if visual != null:
		visual.modulate = BURN_TINT


## Fire hits do their damage through the burn; they never reach the hp directly.
func _resolve_damage(hitbox: Hitbox, amount: int) -> int:
	if hitbox.kind == &"fire":
		on_fire(hitbox.origin())
		return 0
	return amount


func _on_death() -> void:
	_free_marker()


## True during the 0.35 s telegraph (the cone marker is shown).
func is_telegraphing() -> bool:
	return _state == State.TELEGRAPH


## True while the snap cone is active (0.15 s).
func is_snapping() -> bool:
	return _state == State.SNAP


## True while the fire burn runs (0.6 s).
func is_burning() -> bool:
	return _state == State.BURNING


## The direction of the snap (the locked aim during SNAP, the last aim otherwise).
func aim_direction() -> Vector2:
	return _aim


func _player_in_trigger_range() -> bool:
	var player := get_player()
	return player != null and global_position.distance_to(player.global_position) <= TRIGGER_RANGE


func _begin_telegraph() -> void:
	_state = State.TELEGRAPH
	_timer = TELEGRAPH_TIME
	_track_aim()
	_spawn_marker()


## Aim follows Tamsin during the telegraph; the last value is the locked aim.
func _track_aim() -> void:
	var dir := direction_to_player()
	if dir != Vector2.ZERO:
		_aim = dir
		set_facing_dir(dir)
	if is_instance_valid(_marker):
		_marker.set(&"facing", _aim)


func _begin_snap() -> void:
	_state = State.SNAP
	_timer = SNAP_TIME
	_free_marker()
	snap_hitbox.rotation = _aim.angle()
	snap_hitbox.active = true


func _begin_rest() -> void:
	_state = State.REST
	_timer = REST_TIME


func _burn_out() -> void:
	invulnerable = false
	if not apply_damage(FIRE_DAMAGE, global_position, 0.0, 0.0):
		kill()


func _spawn_marker() -> void:
	var script := load(TELEGRAPH_SCRIPT) as GDScript
	if script == null:
		return
	_marker = script.call(&"spawn", self, global_position) as Node2D
	if _marker == null:
		return
	_marker.set(&"shape", &"cone")
	_marker.set(&"radius", SNAP_RADIUS)
	_marker.set(&"arc_deg", SNAP_ARC_DEG)
	_marker.set(&"duration", TELEGRAPH_TIME)
	_marker.set(&"facing", _aim)
	_marker.call(&"start")


func _free_marker() -> void:
	if is_instance_valid(_marker):
		_marker.queue_free()
	_marker = null


## Half disc in the local frame (the aim is angle 0), from the origin.
func _cone_polygon() -> PackedVector2Array:
	var points := PackedVector2Array([Vector2.ZERO])
	var half := deg_to_rad(SNAP_ARC_DEG) * 0.5
	for i in range(ARC_SEGMENTS + 1):
		var a := -half + float(i) * (2.0 * half) / float(ARC_SEGMENTS)
		points.append(Vector2.from_angle(a) * SNAP_RADIUS)
	return points


static func _register_kind() -> void:
	if not Placeholder.has_kind(KIND):
		Placeholder.register_kind(
			KIND, {"shape": "rect", "color": Color(0.36, 0.52, 0.22), "size": Vector2(64, 56)}
		)
