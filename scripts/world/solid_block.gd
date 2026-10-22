class_name SolidBlock
extends StaticBody2D
## A solid rectangle on the WORLD layer (rock, pillar, water, interior wall). Centred on its
## origin. Place instances in a room's `Props` container and set `size` (multiples of 96) and
## `kind` (a Placeholder kind: rock, wall, water, pedestal, ...).

@export var size: Vector2 = Vector2(96, 96)
@export var kind: StringName = &"rock"


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0


func _ready() -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	var node := CollisionShape2D.new()
	node.shape = shape
	add_child(node)
	Placeholder.attach(self, kind, 0.0, size)
