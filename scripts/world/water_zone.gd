extends Area2D
## A water zone (monsters-bosses-tools 5.4): a rectangle of `size` px centred on the node's origin.
## A deep zone (`deep`, the default) also has a blocking body on layer WATER: the player and ground enemies
## stop at its edge, and the reed raft crosses it. A shallow zone has no body. Both kinds are in group
## `water_zone` (the raft's clamp) and in group `shallows` (fen leeches live in either kind, like shallow_zone.gd).
## The zone has no collision of its own: it answers geometric questions (`contains_point`, `nearest_point`).

const GROUP := &"water_zone"
const SHALLOWS_GROUP := &"shallows"
const DEEP_KIND := &"deep_water"
const SHALLOW_KIND := &"shallow_water"

## Footprint in px, centred on the origin.
@export var size: Vector2 = Vector2(192, 192)
## True: a deep zone with a blocking body on layer WATER. False: a shallow zone that walkers cross.
@export var deep: bool = true


func _init() -> void:
	_register_kinds()
	collision_layer = 0
	collision_mask = 0
	monitoring = false


func _ready() -> void:
	add_to_group(GROUP)
	add_to_group(SHALLOWS_GROUP)
	if deep:
		_add_blocker()
	var painter := load("res://scripts/art/world_zone_visual.gd") as Script
	if painter != null:
		painter.attach(self, DEEP_KIND if deep else SHALLOW_KIND, size)


## Global rectangle of the zone (no rotation or scale is applied).
func global_rect() -> Rect2:
	return Rect2(global_position - size * 0.5, size)


## True when the global point `pos` lies inside the zone, edges included.
func contains_point(pos: Vector2) -> bool:
	var rect := global_rect()
	return (
		pos.x >= rect.position.x
		and pos.x <= rect.end.x
		and pos.y >= rect.position.y
		and pos.y <= rect.end.y
	)


## The point of the zone (global) closest to `pos`: `pos` itself when it is inside.
func nearest_point(pos: Vector2) -> Vector2:
	var rect := global_rect()
	return Vector2(
		clampf(pos.x, rect.position.x, rect.end.x), clampf(pos.y, rect.position.y, rect.end.y)
	)


## Adds the blocking body of a deep zone: a StaticBody2D on WATER, covering the footprint.
func _add_blocker() -> void:
	var rect := RectangleShape2D.new()
	rect.size = size
	var shape := CollisionShape2D.new()
	shape.name = "Shape"
	shape.shape = rect
	var body := StaticBody2D.new()
	body.name = "Blocker"
	body.collision_layer = Layers.WATER
	body.collision_mask = 0
	body.add_child(shape)
	add_child(body)


static func _register_kinds() -> void:
	if not Placeholder.has_kind(DEEP_KIND):
		Placeholder.register_kind(
			DEEP_KIND,
			{"shape": "rect", "color": Color(0.1, 0.22, 0.34, 0.6), "size": Vector2(96, 96)},
			true
		)
	if not Placeholder.has_kind(SHALLOW_KIND):
		Placeholder.register_kind(
			SHALLOW_KIND,
			{"shape": "rect", "color": Color(0.22, 0.4, 0.5, 0.35), "size": Vector2(96, 96)},
			true
		)
