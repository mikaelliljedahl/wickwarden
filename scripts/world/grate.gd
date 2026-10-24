extends StaticBody2D
## A grate (P09): an iron grating across an alcove. It blocks the player's body and every walking
## enemy (layer WORLD), but it lets through what flies over it: the tether moth's turn-back ray
## ignores bodies in group `grate` (scripts/items/tether_moth.gd), and the moth's carrier is an Area2D,
## so a pickup behind the grate is fetched by the moth and brought back to the player. The grate
## never opens and sets no flag: it is permanent.
##
## Visual: the Placeholder kind `grate`, registered here (no content WP edits Placeholder.KINDS).

## Footprint in px (centred on the origin). The default fills a 192 px room gap.
@export var size: Vector2 = Vector2(192, 96)

var _shape: CollisionShape2D


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0
	_register_look()


func _ready() -> void:
	add_to_group(&"grate")
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
	_shape.shape = rect
	add_child(_shape)
	SpriteVisual.attach(self, &"grate", 0.0, size)


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
