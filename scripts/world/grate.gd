extends StaticBody2D
## A grate (P09): an iron grating across an alcove. It blocks the player's body and every walking
## enemy (layer WORLD), but it lets through what flies over it: the tether moth's turn-back ray
## ignores bodies in group `grate` (scripts/items/tether_moth.gd), and the moth's carrier is an Area2D,
## so a pickup behind the grate is fetched by the moth and brought back to the player. The grate
## never opens and sets no flag: it is permanent.
##
## Two overlapping fence bays span the gap; the original grate is the missing-art fallback.

## Footprint in px (centred on the origin). The default fills a 192 px room gap.
@export var size: Vector2 = Vector2(192, 96)

var _shape: CollisionShape2D


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0
	_register_look()


func _ready() -> void:
	add_to_group(&"grate")
	# Room templates may already contain the children built on their first ready.
	for child_name in ["Shape", "Visual"]:
		var old := get_node_or_null(NodePath(child_name))
		if old != null:
			remove_child(old)
			old.free()
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
	_shape.shape = rect
	add_child(_shape)
	_build_visual()


func _build_visual() -> void:
	if not SpriteVisual.has_art(&"grate_fence_bay"):
		SpriteVisual.attach(self, &"grate", 0.0, size)
		return
	var visual := Node2D.new()
	visual.name = "Visual"
	add_child(visual)
	for side in [-1, 1]:
		var holder := Node2D.new()
		holder.name = "Left" if side < 0 else "Right"
		holder.position = Vector2(side * 48, 0)
		visual.add_child(holder)
		SpriteVisual.attach(holder, &"grate_fence_bay", 0.0, size)


static func _register_look() -> void:
	if Placeholder.has_kind(&"grate"):
		return
	var definition := {
		"shape": "rect",
		"color": Color(0.32, 0.34, 0.36),
		"size": Vector2(192, 96),
		"radius": 48.0,
	}
	Placeholder.register_kind(&"grate", definition, true)
