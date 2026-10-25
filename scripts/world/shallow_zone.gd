extends Area2D
## A shallow-water zone: the only water a fen leech lives in (monsters-bosses-tools 2.1). The zone is a
## rectangle of `size` px centred on the node's origin, in group `shallows`. It has no collision and does
## not detect anything: enemies ask it geometric questions (`contains_point`, `nearest_point`).
##
## Rooms place zones over the water tiles (R4, C03, C09, C10). Visual: the shared painted shallow-water terrain.

const GROUP := &"shallows"
const KIND := &"shallow_water"

## Footprint in px, centred on the origin.
@export var size: Vector2 = Vector2(192, 192)


func _init() -> void:
	_register_kind()
	collision_layer = 0
	collision_mask = 0
	monitoring = false


func _ready() -> void:
	add_to_group(GROUP)
	var painter := load("res://scripts/art/world_zone_visual.gd") as Script
	if painter != null:
		painter.attach(self, KIND, size)


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


static func _register_kind() -> void:
	if not Placeholder.has_kind(KIND):
		Placeholder.register_kind(
			KIND,
			{"shape": "rect", "color": Color(0.22, 0.4, 0.5, 0.35), "size": Vector2(96, 96)},
			true
		)
