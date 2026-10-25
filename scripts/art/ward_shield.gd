extends Node2D
## Presentation only: a crescent of lamp light, feathered radially and at both tips.
## Player supplies its existing ward sector and controls facing and visibility. Nothing here
## reads or changes combat state. Like the hook trail, additive light leaves the floor visible.

const BRASS := Color("#edb65b")
const PALE := Color("#fff1c8")
const ANGLE_STEPS := 40
const RADIAL_STEPS := 24

var radius: float = 64.0
var arc_degrees: float = 120.0
var facing: Vector2 = Vector2.DOWN


func _ready() -> void:
	var light := CanvasItemMaterial.new()
	light.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = light


func set_facing(dir: Vector2) -> void:
	if dir == Vector2.ZERO or dir.normalized() == facing:
		return
	facing = dir.normalized()
	queue_redraw()


## Geometry for presentation checks, never queried by gameplay.
func get_sector() -> Vector3:
	var half := deg_to_rad(arc_degrees) * 0.5
	return Vector3(facing.angle() - half, facing.angle() + half, radius)


func _draw() -> void:
	var sector := get_sector()
	for radial in range(RADIAL_STEPS):
		var r0 := float(radial) / RADIAL_STEPS
		var r1 := float(radial + 1) / RADIAL_STEPS
		for angular in range(ANGLE_STEPS):
			var t0 := float(angular) / ANGLE_STEPS
			var t1 := float(angular + 1) / ANGLE_STEPS
			var a0 := Vector2.from_angle(lerpf(sector.x, sector.y, t0))
			var a1 := Vector2.from_angle(lerpf(sector.x, sector.y, t1))
			draw_polygon(
				PackedVector2Array(
					[a0 * r0 * radius, a0 * r1 * radius, a1 * r1 * radius, a1 * r0 * radius]
				),
				PackedColorArray([_light(r0, t0), _light(r1, t0), _light(r1, t1), _light(r0, t1)])
			)


## A broad pale veil behind a narrow brass rim; zero alpha at the centre, outer edge and tips.
func _light(radial: float, angular: float) -> Color:
	var tip := pow(sin(PI * angular), 0.7)
	var edge := smoothstep(0.0, 0.12, radial) * (1.0 - smoothstep(0.91, 1.0, radial))
	var veil := exp(-pow((radial - 0.68) / 0.22, 2.0)) * 0.13
	var rim := exp(-pow((radial - 0.86) / 0.045, 2.0)) * 0.62
	var colour := PALE.lerp(BRASS, clampf(rim, 0.0, 1.0))
	colour.a = (veil + rim) * edge * tip
	return colour
