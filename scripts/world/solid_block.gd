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
	if _tile != null:
		draw_texture_rect(_tile, Rect2(-size * 0.5, size), true)
