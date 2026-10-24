extends Node2D
## One-way ledge edge: a placeholder lip that a room places on the upper side of a drop, beside the gap.
## It has no collision and no logic. The drop itself is the room's gap (Room.drop_exits) together with
## the missing gap of the lower room, and World._neighbor checks the graph edge (WorldData.is_oneway).

## Footprint in px, centred on the origin.
@export var size: Vector2 = Vector2(288, 48)

const KIND := &"ledge"


func _ready() -> void:
	if not Placeholder.has_kind(KIND):
		Placeholder.register_kind(
			KIND, {"shape": "rect", "color": Color(0.36, 0.3, 0.22), "size": Vector2(288, 48)}, true
		)
	Placeholder.attach(self, KIND, 0.0, size)
