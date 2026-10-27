extends Node2D
## Non-interactive shopkeeper; the counter owns its separate collision.

@export var kind: StringName = &"npc_tilly"


func _ready() -> void:
	SpriteVisual.attach(self, kind, 28.0)
