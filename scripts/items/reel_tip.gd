extends Hitbox
## Reel tip: the hook tip of the reel line (reel_line.gd, monsters-bosses-tools.md 5.8). A PLAYER Hitbox of kind
## `reel`, damage 1, no knockback. It flies FLY_SPEED px/s along `dir` for at most RANGE px, or until a WORLD body
## stops it, then reels back to its origin at RETRACT_SPEED px/s and emits `returned`. The first anchor ring it
## reaches while flying emits `anchored(ring)` and the tip holds still until the owner calls retract() or frees it.
## Small pickups it touches are carried back and handed over with take_carried(). The tip draws the line from its
## origin to itself. Placed tips (`place_dir`, gallery fixtures) have no owner and launch on their first frame.

signal anchored(ring: Node)
signal returned

enum State { OUT, RETRACT, HELD }

const FLY_SPEED := 1200.0
const RETRACT_SPEED := 1400.0
const RANGE := 576.0
const RADIUS := 12.0
const DAMAGE := 1
const LINE_WIDTH := 2.0
const LINE_COLOR := Color(0.85, 0.8, 0.6, 0.9)
const ANCHOR_GROUP := &"anchor_ring"
## Pickup kinds the tip carries back. Items, big keys, fragments and pot bags stay where they lie.
const CARRY_KINDS: Array[StringName] = [
	&"ember", &"brass_bit", &"brass_coin", &"pitch_pot_bundle", &"key", &"slug_bundle"
]

## Non-zero: the tip launches from where it stands in this direction (a placed tip in a gallery fixture).
## The reel line calls launch() instead.
@export var place_dir: Vector2 = Vector2.ZERO

var _state: State = State.OUT
var _origin_node: Node2D
var _origin_pos: Vector2 = Vector2.ZERO
var _dir: Vector2 = Vector2.RIGHT
var _travelled: float = 0.0
var _carried: Array[PickupBase] = []
var _placed_pending: bool = false


func _init() -> void:
	team = Layers.Team.PLAYER
	kind = &"reel"
	damage = DAMAGE
	knockback = 0.0
	knockback_time = 0.0
	once_per_target = true


func _ready() -> void:
	super()
	top_level = true
	add_to_group(&"reel_tips")
	add_circle(RADIUS)
	_register_kinds()
	SpriteVisual.attach(self, &"reel_tip", RADIUS)
	hit_landed.connect(_on_hit_landed)
	_placed_pending = place_dir != Vector2.ZERO


## Starts the flight from `origin` (the player, who is followed on the way back) along `dir`.
func launch(origin: Node2D, dir: Vector2) -> void:
	_begin(origin, origin.global_position, dir)


## Stops flying and reels back to the origin. Does nothing once the tip is spent.
func retract() -> void:
	if active:
		_state = State.RETRACT


## Returns the pickups the tip carries and forgets them. The caller hands them over with collect().
func take_carried() -> Array[PickupBase]:
	var out: Array[PickupBase] = []
	for pickup in _carried:
		if is_instance_valid(pickup):
			pickup.end_carry()
			out.append(pickup)
	_carried.clear()
	return out


func _physics_process(delta: float) -> void:
	if _placed_pending:
		_placed_pending = false
		_begin(null, global_position, place_dir)
		return
	if not active or _state == State.HELD:
		return
	if _state == State.OUT:
		_fly(delta)
	else:
		_reel_in(delta)
	if not active:
		return
	_sweep_pickups()
	queue_redraw()
	super(delta)


func _draw() -> void:
	if not active:
		return
	draw_line(to_local(_origin_point()), Vector2.ZERO, LINE_COLOR, LINE_WIDTH)


func _begin(origin_node: Node2D, origin_pos: Vector2, dir: Vector2) -> void:
	_origin_node = origin_node
	_origin_pos = origin_pos
	_dir = dir.normalized() if dir != Vector2.ZERO else Vector2.RIGHT
	# The source hook points northeast, with its rope trailing southwest.
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as Node2D
	if visual != null:
		visual.rotation = _dir.angle() + PI * 0.25
	_travelled = 0.0
	_state = State.OUT
	global_position = origin_pos
	activate()


func _origin_point() -> Vector2:
	return _origin_node.global_position if is_instance_valid(_origin_node) else _origin_pos


func _fly(delta: float) -> void:
	var step := minf(FLY_SPEED * delta, RANGE - _travelled)
	var from := global_position
	var to := from + _dir * step
	var query := PhysicsRayQueryParameters2D.create(from, to, Layers.WORLD)
	var hit: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var stop: Vector2 = hit.position
		global_position = stop
		retract()
		return
	global_position = to
	_travelled += step
	if _travelled >= RANGE - 0.5:
		retract()


func _reel_in(delta: float) -> void:
	var target := _origin_point()
	var to_target := target - global_position
	var dist := to_target.length()
	var step := RETRACT_SPEED * delta
	if dist <= step:
		global_position = target
		_arrive()
	else:
		global_position += to_target * (step / dist)


func _arrive() -> void:
	active = false
	queue_redraw()
	returned.emit()


## Carries the small pickups under the tip (a pickup is carried once and follows the tip).
func _sweep_pickups() -> void:
	for node in get_tree().get_nodes_in_group(&"pickups"):
		var pickup := node as PickupBase
		if pickup == null or not CARRY_KINDS.has(pickup.kind):
			continue
		if global_position.distance_to(pickup.global_position) > RADIUS + PickupBase.PICKUP_RADIUS:
			continue
		if pickup.begin_carry(self):
			_carried.append(pickup)


## Only a flying tip is anchored: a ring hit on the way back does nothing.
func _on_hit_landed(hurtbox: Hurtbox) -> void:
	if _state != State.OUT:
		return
	var holder := hurtbox.get_parent()
	if holder != null and holder.is_in_group(ANCHOR_GROUP):
		_state = State.HELD
		anchored.emit(holder)


static func _register_kinds() -> void:
	if not Placeholder.has_kind(&"reel_tip"):
		Placeholder.register_kind(
			&"reel_tip",
			{"shape": "diamond", "color": Color(0.85, 0.8, 0.6), "radius": RADIUS},
			true
		)
