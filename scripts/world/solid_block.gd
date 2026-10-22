class_name SolidBlock
extends StaticBody2D
## A solid rectangle on the WORLD layer (rock, pillar, water, interior wall). Centred on its
## origin. Place instances in a room's `Props` container and set `size` (multiples of 96) and
## `kind` (a Placeholder kind: rock, wall, water, pedestal, ...).

@export var size: Vector2 = Vector2(96, 96)
@export var kind: StringName = &"rock"

## Kinds drawn as a texture tiled over the block (no sprite), with their texture name.
const TILED_TEXTURES := {&"wall": &"wall_ruin", &"water": &"water"}

var _tile: Texture2D


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0


func _ready() -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	var node := CollisionShape2D.new()
	node.shape = shape
	add_child(node)
	if TILED_TEXTURES.has(kind):
		_tile = SpriteVisual.texture_of(TILED_TEXTURES[kind])
	if _tile != null:
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		queue_redraw()
	elif TILED_TEXTURES.has(kind):
		Placeholder.attach(self, kind, 0.0, size)
	else:
		SpriteVisual.attach(self, kind, 0.0, size)


func _draw() -> void:
	if _tile == null:
		return
	# Sampled by world position, so neighbouring blocks continue one texture (no seams).
	var rect := Rect2(-size * 0.5, size)
	var tex_size := _tile.get_size()
	var world := global_position + rect.position
	var src := Rect2(
		Vector2(fposmod(world.x, tex_size.x), fposmod(world.y, tex_size.y)), rect.size
	)
	draw_texture_rect_region(_tile, rect, src, Color.WHITE, false, false)
