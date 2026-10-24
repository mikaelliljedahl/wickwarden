extends CharacterBody2D
## A small thing the heft mitts lift, carry and throw: a rock, an urn, a shard (P06). Group `liftable`.
##
## The mitts item finds it by its grab hit (the Hurtbox filter accepts kind `grab` only, on PROP_HURTBOX),
## then calls `lift(by)`. Carried, it floats at `carry_offset` above the carrier and has no collision.
## `throw(dir)` flies it THROW_DISTANCE px at THROW_SPEED px/s, or until a WORLD body stops it. A throw
## Hitbox (team PLAYER, kind `thrown`) is active from the throw until the landing burst ends, so the flight
## and the landing hit, each target once. The object shatters on landing (LANDING_TIME later it is freed).
## `put_down(at)` sets a carried object on the floor again (the ward); `shatter()` breaks a carried one
## where it is (a hit on the carrier). A liftable is not a gate and sets no flag. HeavyStone (heavy_stone.gd)
## extends this script.
##
## Visual: Placeholder kind `look`; the kind is registered here, so no content work package edits Placeholder.KINDS.

signal lifted(by: Node2D)
signal thrown(dir: Vector2)
## Emitted on landing (or on shatter()) with the global position where the object broke.
signal shattered(at: Vector2)

enum State { LYING, CARRIED, FLYING, SHATTERED }

## Throw distance and speed in px and px/s (the heft mitts throw).
const THROW_DISTANCE := 480.0
const THROW_SPEED := 720.0
## Seconds the landing burst stays active after the object lands.
const LANDING_TIME := 0.15
## Thrown-object hit: damage 3 (half-hearts), knockback 560 px/s for 0.15 s.
const HIT_DAMAGE := 3
const HIT_KNOCKBACK := 560.0
const HIT_KNOCKBACK_TIME := 0.15
## Reach of the throw hit beyond the body, in px.
const HIT_MARGIN := 8.0
const SHATTER_SFX := &"wall_break"

## Radius of the round body in px. HeavyStone uses its `size` instead.
@export var radius: float = 28.0
## Placeholder look (liftable_rock: a small rock or urn).
@export var look: StringName = &"liftable_rock"
## Where a carried object floats, relative to the carrier's position, in px.
@export var carry_offset: Vector2 = Vector2(0.0, -40.0)

var state: State = State.LYING
## The node that carries the object (set while CARRIED, null otherwise).
var carrier: Node2D = null
var _shape: CollisionShape2D
var _hurtbox: Hurtbox
var _hitbox: Hitbox
var _fly_dir := Vector2.ZERO
var _fly_left := 0.0
var _shatter_left := 0.0


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = Layers.WORLD
	_register_looks()


func _ready() -> void:
	add_to_group(_group())
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
	_shape.shape = _body_shape()
	add_child(_shape)
	_hurtbox = Hurtbox.new()
	_hurtbox.name = "Hurtbox"
	_hurtbox.team = Layers.Team.NEUTRAL
	_hurtbox.filter = _accepts_grab
	var grab := CollisionShape2D.new()
	grab.shape = _body_shape()
	_hurtbox.add_child(grab)
	add_child(_hurtbox)
	_hitbox = Hitbox.new()
	_hitbox.name = "ThrowHitbox"
	_hitbox.kind = &"thrown"
	_hitbox.team = Layers.Team.PLAYER
	_hitbox.damage = HIT_DAMAGE
	_hitbox.knockback = HIT_KNOCKBACK
	_hitbox.knockback_time = HIT_KNOCKBACK_TIME
	_hitbox.add_circle(_hit_radius())
	add_child(_hitbox)
	_attach_visual()
	_on_ready()


func _physics_process(delta: float) -> void:
	match state:
		State.CARRIED:
			if is_instance_valid(carrier):
				global_position = carrier.global_position + carry_offset
			else:
				put_down(global_position)
		State.FLYING:
			_fly(delta)
		State.SHATTERED:
			_shatter_left -= delta
			if _shatter_left <= 0.0:
				queue_free()


func is_carried() -> bool:
	return state == State.CARRIED


## Mitts: picks the object up from the floor. Ignored while carried, flying or when `_can_lift()` is false.
func lift(by: Node2D) -> void:
	if state != State.LYING or not _can_lift():
		return
	carrier = by
	state = State.CARRIED
	_shape.set_deferred("disabled", true)
	_hurtbox.enabled = false
	global_position = by.global_position + carry_offset
	lifted.emit(by)


## Mitts: throws a carried object along `dir` (normalised; a zero vector throws it down).
func throw(dir: Vector2) -> void:
	if state != State.CARRIED:
		return
	var heading := dir.normalized()
	if heading == Vector2.ZERO:
		heading = Vector2.DOWN
	carrier = null
	state = State.FLYING
	_fly_dir = heading
	_fly_left = THROW_DISTANCE
	_hitbox.knockback_direction = heading
	_hitbox.activate()
	# Deferred: the object is carried through a physics step, where shapes may not change.
	_shape.set_deferred("disabled", false)
	thrown.emit(heading)


## Sets a carried object on the floor at `at` (global position). It can be lifted again.
func put_down(at: Vector2) -> void:
	if state != State.CARRIED:
		return
	carrier = null
	state = State.LYING
	global_position = at
	_shape.set_deferred("disabled", false)
	_hurtbox.enabled = true


## Breaks a carried object where it is (no hit): the carrier was hurt.
func shatter() -> void:
	if state != State.CARRIED:
		return
	carrier = null
	_land()


## Virtual: group of the object. HeavyStone uses `heavy`.
func _group() -> StringName:
	return &"liftable"


## Virtual: the body and grab shape (a circle here).
func _body_shape() -> Shape2D:
	var circle := CircleShape2D.new()
	circle.radius = radius
	return circle


## Virtual: radius of the throw hitbox in px.
func _hit_radius() -> float:
	return radius + HIT_MARGIN


## Virtual: the Visual child (a circle here).
func _attach_visual() -> void:
	SpriteVisual.attach(self, look, radius)


## Virtual: false refuses `lift`. HeavyStone lifts only in LIFT mode.
func _can_lift() -> bool:
	return true


## Virtual: runs at the end of _ready(), after the body, grab zone, hitbox and Visual exist.
func _on_ready() -> void:
	pass


## Virtual: runs when the object breaks on landing (or shatter()). HeavyStone sets its flag here.
func _on_shattered() -> void:
	pass


func _accepts_grab(hitbox: Hitbox) -> bool:
	return hitbox.kind == &"grab" and state == State.LYING


func _fly(delta: float) -> void:
	var step := minf(THROW_SPEED * delta, _fly_left)
	_fly_left -= step
	var hit := move_and_collide(_fly_dir * step)
	if hit != null or _fly_left <= 0.0:
		_land()


func _land() -> void:
	state = State.SHATTERED
	_shatter_left = LANDING_TIME
	_hide_body()
	Audio.play_sfx(SHATTER_SFX, global_position)
	shattered.emit(global_position)
	_on_shattered()


## Takes the body out of play: no collision, no grab zone, the look hidden. Used on landing and by
## HeavyStone when a gap is already open on a later visit.
func _hide_body() -> void:
	_shape.set_deferred("disabled", true)
	_hurtbox.enabled = false
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = false


static func _register_looks() -> void:
	if Placeholder.has_kind(&"liftable_rock"):
		return
	Placeholder.register_kind(
		&"liftable_rock", {"shape": "circle", "color": Color(0.55, 0.5, 0.45), "radius": 28.0}, true
	)
