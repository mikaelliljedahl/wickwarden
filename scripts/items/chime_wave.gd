extends Node2D
## Expanding, zero-damage player hitbox for the lantern chime. Resonant props and chime-sensitive
## enemies receive the same `chime` hit as the ring edge reaches them.

signal finished

const RADIUS := 480.0
const DURATION := 0.5
const RING_STEPS := 64

@export var preview_active: bool = false

var _elapsed: float = 0.0
var _active: bool = false
var _hitbox: Hitbox
var _shape: CollisionShape2D
var _ring: Line2D


func _ready() -> void:
	add_to_group(&"chime_waves")
	_hitbox = get_node_or_null("Hitbox") as Hitbox
	_shape = get_node_or_null("Hitbox/Shape") as CollisionShape2D
	_ring = get_node_or_null("Visual/Ring") as Line2D
	if _hitbox == null or _shape == null or _ring == null:
		push_error("ChimeWave: required Hitbox, Shape or Visual/Ring child is missing")
		return
	_hitbox.team = Layers.Team.PLAYER
	_hitbox.kind = &"chime"
	_hitbox.damage = 0
	_hitbox.knockback = 0.0
	_hitbox.once_per_target = true
	_hitbox.source = self
	_hitbox.deactivate()
	_set_radius(0.0)
	if preview_active:
		start()


func start() -> void:
	if _hitbox == null or _shape == null or _ring == null:
		return
	_elapsed = 0.0
	_active = true
	_hitbox.activate()


func _physics_process(delta: float) -> void:
	if not _active:
		return
	_elapsed = minf(_elapsed + delta, DURATION)
	_set_radius(RADIUS * _elapsed / DURATION)
	if _elapsed >= DURATION:
		_active = false
		_hitbox.deactivate()
		finished.emit()
		if not preview_active:
			queue_free()


func current_radius() -> float:
	return RADIUS * _elapsed / DURATION


func _set_radius(radius: float) -> void:
	var circle := _shape.shape as CircleShape2D
	if circle != null:
		circle.radius = radius
	var points := PackedVector2Array()
	for step in range(RING_STEPS + 1):
		var angle := TAU * float(step) / float(RING_STEPS)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	_ring.points = points
