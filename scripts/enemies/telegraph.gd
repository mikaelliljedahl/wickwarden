extends Node2D
## Floor marker shown before a damaging attack (telegraph rule, monsters-bosses-tools section 1.2).
## Shape: circle, rect or cone (a sector from the node position, pointing along `facing`). It fills
## up over `duration` seconds and then emits `finished` once and frees itself. The attack node listens
## to `finished` and spawns its Hitbox then. Presentation only: it has no collision and no damage.
## Timers run in _physics_process. Start it with start() after setting the shape, or set `autostart`.
## It does NOT declare a class_name (WP files must not; see docs/code-contract.md).

signal finished

const SCENE_PATH := "res://scenes/enemies/telegraph.tscn"
const SCRIPT_PATH := "res://scripts/enemies/telegraph.gd"
const CONE_SEGMENTS := 24

## &"circle", &"rect" or &"cone".
@export var shape: StringName = &"circle"
## Radius in px (circle and cone).
@export var radius: float = 48.0
## Size in px (rect), centred on the node position.
@export var size: Vector2 = Vector2(96.0, 96.0)
## Full opening angle in degrees (cone).
@export var arc_deg: float = 90.0
## Direction of the cone (cone only).
@export var facing: Vector2 = Vector2.RIGHT
## Seconds from start() to finished.
@export var duration: float = 0.5
@export var color: Color = Color(1.0, 0.85, 0.35)
## True: start() runs when the node enters the tree.
@export var autostart: bool = false

var _elapsed: float = 0.0
var _running: bool = false


## Spawns a telegraph under `parent` at `at` (global) and returns it. Not started: call start().
static func spawn(parent: Node, at: Vector2) -> Node2D:
	var scene := load(SCENE_PATH) as PackedScene
	var node: Node2D = null
	if scene != null:
		node = scene.instantiate() as Node2D
	if node == null:
		node = (load(SCRIPT_PATH) as GDScript).new() as Node2D
	parent.add_child(node)
	node.global_position = at
	return node


func _ready() -> void:
	if autostart:
		start()


func _physics_process(delta: float) -> void:
	if not _running:
		return
	_elapsed += delta
	if _elapsed >= duration:
		_running = false
		finished.emit()
		queue_free()
		return
	queue_redraw()


## Starts the countdown from zero. A duration of 0 or less finishes on the next physics frame.
func start() -> void:
	_elapsed = 0.0
	_running = true
	visible = true
	queue_redraw()


## 0.0 at start, 1.0 at finish (1.0 before start is never reached).
func progress() -> float:
	if duration <= 0.0:
		return 1.0
	return clampf(_elapsed / duration, 0.0, 1.0)


func is_running() -> bool:
	return _running


func _draw() -> void:
	if not _running and _elapsed <= 0.0:
		return
	var fill := color
	fill.a = 0.18 + 0.32 * progress()
	var edge := color
	edge.a = 0.9
	match shape:
		&"rect":
			draw_rect(Rect2(-size * 0.5, size), fill)
			draw_rect(Rect2(-size * 0.5, size), edge, false, 3.0)
		&"cone":
			var points := _cone_points()
			draw_colored_polygon(points, fill)
			points.append(points[0])
			draw_polyline(points, edge, 3.0)
		_:
			draw_circle(Vector2.ZERO, radius, fill)
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, edge, 3.0)


func _cone_points() -> PackedVector2Array:
	var points := PackedVector2Array([Vector2.ZERO])
	var base_angle := facing.angle() if facing != Vector2.ZERO else 0.0
	var half := deg_to_rad(arc_deg) * 0.5
	for i in range(CONE_SEGMENTS + 1):
		var a := base_angle - half + float(i) * (2.0 * half) / float(CONE_SEGMENTS)
		points.append(Vector2.from_angle(a) * radius)
	return points
