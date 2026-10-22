class_name Placeholder
extends Node2D
## Step 1 placeholder art: draws a simple shape in a fixed colour per entity kind.
##
## Every entity owns exactly one child named "Visual" (see Placeholder.attach). Game logic NEVER
## reads from it; it only writes presentation state (modulate, visible, facing). Step 2 replaces
## the node with an AnimatedSprite2D, so keep to `modulate`, `visible` and optional `set_facing`.
##
## Add a kind by adding one line to KINDS. shape: circle | rect | diamond | arc | ring.

const VISUAL_NAME := "Visual"

## kind -> {shape, color, radius (circle/diamond/arc/ring) or size (rect)}
const KINDS := {
	&"generic": {"shape": "circle", "color": Color(0.8, 0.8, 0.8), "radius": 24.0},
	# Player and her weapon
	&"player": {"shape": "circle", "color": Color(0.96, 0.72, 0.28), "radius": 30.0},
	&"hook_arc": {"shape": "arc", "color": Color(1.0, 0.92, 0.5, 0.55), "radius": 120.0},
	&"ward": {"shape": "arc", "color": Color(0.5, 0.8, 1.0, 0.5), "radius": 64.0},
	&"flare": {"shape": "ring", "color": Color(1.0, 0.85, 0.4, 0.6), "radius": 140.0},
	# Enemies
	&"dummy_walker": {"shape": "circle", "color": Color(0.85, 0.3, 0.75), "radius": 28.0},
	&"spitcap": {"shape": "circle", "color": Color(0.55, 0.65, 0.25), "radius": 30.0},
	&"spore": {"shape": "circle", "color": Color(0.75, 0.9, 0.45), "radius": 12.0},
	&"skitterwick": {"shape": "diamond", "color": Color(0.55, 0.35, 0.8), "radius": 30.0},
	&"duskmoth": {"shape": "diamond", "color": Color(0.3, 0.3, 0.6), "radius": 26.0},
	&"tallow_blob": {"shape": "circle", "color": Color(0.95, 0.88, 0.6), "radius": 34.0},
	&"tallow_drop": {"shape": "circle", "color": Color(0.98, 0.94, 0.75), "radius": 20.0},
	&"hollow": {"shape": "rect", "color": Color(0.82, 0.84, 0.88), "size": Vector2(56, 64)},
	# Items and projectiles
	&"tether_moth": {"shape": "diamond", "color": Color(0.75, 0.7, 1.0), "radius": 18.0},
	&"pitch_pot": {"shape": "circle", "color": Color(0.12, 0.1, 0.1), "radius": 24.0},
	&"explosion": {"shape": "circle", "color": Color(1.0, 0.55, 0.15, 0.6), "radius": 150.0},
	# Pickups
	&"ember": {"shape": "diamond", "color": Color(1.0, 0.45, 0.15), "radius": 16.0},
	&"brass_bit": {"shape": "circle", "color": Color(0.8, 0.65, 0.25), "radius": 10.0},
	&"brass_coin": {"shape": "circle", "color": Color(0.95, 0.8, 0.3), "radius": 16.0},
	&"pitch_pot_bundle": {"shape": "rect", "color": Color(0.3, 0.2, 0.15), "size": Vector2(32, 32)},
	&"key": {"shape": "rect", "color": Color(1.0, 0.9, 0.3), "size": Vector2(16, 36)},
	&"wick_core": {"shape": "diamond", "color": Color(0.85, 1.0, 1.0), "radius": 24.0},
	&"item": {"shape": "diamond", "color": Color(0.4, 0.9, 1.0), "radius": 26.0},
	# World props
	&"brazier": {"shape": "rect", "color": Color(0.5, 0.45, 0.42), "size": Vector2(64, 64)},
	&"brazier_lit": {"shape": "rect", "color": Color(1.0, 0.6, 0.2), "size": Vector2(64, 64)},
	&"locked_door": {"shape": "rect", "color": Color(0.5, 0.32, 0.15), "size": Vector2(192, 96)},
	&"gate": {"shape": "rect", "color": Color(0.3, 0.3, 0.38), "size": Vector2(192, 96)},
	&"bush": {"shape": "circle", "color": Color(0.2, 0.55, 0.25), "radius": 40.0},
	&"rock": {"shape": "rect", "color": Color(0.45, 0.45, 0.5), "size": Vector2(96, 96)},
	&"wall": {"shape": "rect", "color": Color(0.2, 0.2, 0.28), "size": Vector2(96, 96)},
	&"water": {"shape": "rect", "color": Color(0.15, 0.3, 0.6), "size": Vector2(96, 96)},
	&"cracked_wall": {"shape": "rect", "color": Color(0.4, 0.35, 0.3), "size": Vector2(96, 96)},
	&"pedestal": {"shape": "rect", "color": Color(0.6, 0.6, 0.65), "size": Vector2(72, 72)},
	&"tree": {"shape": "circle", "color": Color(0.1, 0.38, 0.18), "radius": 46.0},
	&"reed": {"shape": "rect", "color": Color(0.42, 0.52, 0.28), "size": Vector2(96, 96)},
	&"sign_post": {"shape": "rect", "color": Color(0.55, 0.4, 0.2), "size": Vector2(48, 64)},
	&"hut": {"shape": "rect", "color": Color(0.5, 0.33, 0.25), "size": Vector2(96, 96)},
	&"door_marker": {"shape": "rect", "color": Color(0.05, 0.05, 0.08), "size": Vector2(96, 96)},
}

## Static props: drawn without the facing nub (the nub is for things that turn).
const STATIC_KINDS: Array[StringName] = [
	&"brazier",
	&"brazier_lit",
	&"locked_door",
	&"gate",
	&"bush",
	&"rock",
	&"wall",
	&"water",
	&"cracked_wall",
	&"pedestal",
	&"tree",
	&"reed",
	&"sign_post",
	&"hut",
	&"door_marker",
]

@export var kind: StringName = &"generic"
## Overrides for the table entry. 0 means "use the table".
@export var radius: float = 0.0
@export var size: Vector2 = Vector2.ZERO
## Arc opening in degrees (shape "arc").
@export var arc_degrees: float = 110.0

var facing: Vector2 = Vector2.DOWN
var color_override: Color = Color(0, 0, 0, 0)


## Creates (or replaces) the "Visual" child of `parent` for an entity kind and returns it.
static func attach(
	parent: Node,
	entity_kind: StringName,
	radius_override: float = 0.0,
	size_override: Vector2 = Vector2.ZERO
) -> Placeholder:
	var old := parent.get_node_or_null(VISUAL_NAME)
	if old != null:
		parent.remove_child(old)
		old.free()
	var visual := Placeholder.new()
	visual.name = VISUAL_NAME
	visual.kind = entity_kind
	visual.radius = radius_override
	visual.size = size_override
	parent.add_child(visual)
	return visual


static func color_of(entity_kind: StringName) -> Color:
	return KINDS.get(entity_kind, KINDS[&"generic"])["color"]


## Small expanding, fading circle used for enemy death. Frees itself.
static func puff(
	parent: Node, at: Vector2, color: Color = Color(1, 1, 1, 0.8), puff_radius: float = 28.0
) -> Node2D:
	var node := Placeholder.new()
	node.name = "Puff"
	node.kind = &"generic"
	node.radius = puff_radius
	node.color_override = color
	node.top_level = true
	parent.add_child(node)
	node.global_position = at
	var tween := node.create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "scale", Vector2(1.8, 1.8), 0.25)
	tween.tween_property(node, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(node.queue_free)
	return node


func set_facing(dir: Vector2) -> void:
	if dir != Vector2.ZERO and dir != facing:
		facing = dir.normalized()
		queue_redraw()


func set_kind(new_kind: StringName) -> void:
	kind = new_kind
	queue_redraw()


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var entry: Dictionary = KINDS.get(kind, KINDS[&"generic"])
	var color: Color = entry["color"]
	if color_override.a > 0.0:
		color = color_override
	var shape: String = entry["shape"]
	var r: float = radius if radius > 0.0 else float(entry.get("radius", 24.0))
	var rect_size: Vector2 = (
		size if size != Vector2.ZERO else Vector2(entry.get("size", Vector2(r * 2.0, r * 2.0)))
	)
	match shape:
		"circle":
			draw_circle(Vector2.ZERO, r, color)
			_draw_facing_nub(r, color)
		"rect":
			draw_rect(Rect2(-rect_size * 0.5, rect_size), color)
			_draw_facing_nub(rect_size.y * 0.5, color)
		"diamond":
			draw_colored_polygon(
				PackedVector2Array([Vector2(0, -r), Vector2(r, 0), Vector2(0, r), Vector2(-r, 0)]),
				color
			)
		"arc":
			_draw_arc_fan(r, color)
		"ring":
			draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, color, 8.0)
			draw_circle(Vector2.ZERO, r, Color(color.r, color.g, color.b, color.a * 0.25))


func _draw_facing_nub(extent: float, color: Color) -> void:
	if kind == &"generic" or not KINDS.has(kind) or STATIC_KINDS.has(kind):
		return
	var shade := Color(color.r * 0.45, color.g * 0.45, color.b * 0.45, color.a)
	draw_circle(facing * extent * 0.6, extent * 0.22, shade)


func _draw_arc_fan(reach: float, color: Color) -> void:
	var points := PackedVector2Array([Vector2.ZERO])
	var base := facing.angle()
	var half := deg_to_rad(arc_degrees) * 0.5
	var steps := 16
	for i in range(steps + 1):
		points.append(
			Vector2.from_angle(base - half + 2.0 * half * float(i) / float(steps)) * reach
		)
	draw_colored_polygon(points, color)
