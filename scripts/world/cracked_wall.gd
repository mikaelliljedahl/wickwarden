extends StaticBody2D
## A solid block that a pitch pot explosion can open. It is in group "explodable" and decides for
## itself whether a blast reaches it: the distance from the explosion centre to its nearest edge
## must be <= radius. Opening disables its collision, hides it and sets the persistent flag
## "cracked_<wall_id>" so the wall starts open on every later visit.
##
## `variant` is the look only: cracked_wall (default) or brittle_rocks (a rock look, the same blast).

## Id for the persistent flag. Empty = not persistent.
@export var wall_id: StringName = &""
## Footprint in px (centred on the origin).
@export var size: Vector2 = Vector2(96, 96)
## Look only: cracked_wall or brittle_rocks. Its name is also the Placeholder kind of the look.
@export var variant: StringName = &"cracked_wall"

var is_open: bool = false
var _shape: CollisionShape2D


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0
	_register_looks()


func _ready() -> void:
	add_to_group(&"explodable")
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
	_shape.shape = rect
	add_child(_shape)
	SpriteVisual.attach(self, variant, 0.0, size)
	if wall_id != &"" and GameState.has_flag(flag_name()):
		_open(false)


func flag_name() -> StringName:
	return StringName("cracked_%s" % wall_id)


## Explodable contract (code-contract section 9). `pos` is the blast centre in global space.
func on_explosion(pos: Vector2, radius: float) -> void:
	if is_open:
		return
	if _distance_to_body(pos) <= radius:
		_open(true)


## Distance from `pos` to the nearest point of the wall's footprint (0 when inside it).
func _distance_to_body(pos: Vector2) -> float:
	var half := size * 0.5
	var nearest := Vector2(
		clampf(pos.x, global_position.x - half.x, global_position.x + half.x),
		clampf(pos.y, global_position.y - half.y, global_position.y + half.y)
	)
	return pos.distance_to(nearest)


func _open(persist: bool) -> void:
	is_open = true
	remove_from_group(&"explodable")
	# Deferred: the opening can happen during a physics step (a blast), where shapes may not change.
	_shape.set_deferred("disabled", true)
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = false
	if persist:
		Audio.play_sfx(&"wall_break", global_position)
	if persist and wall_id != &"":
		GameState.set_flag(flag_name())


## Placeholder look of the brittle rocks (registered once; "cracked_wall" is in Placeholder.KINDS).
static func _register_looks() -> void:
	if Placeholder.has_kind(&"brittle_rocks"):
		return
	Placeholder.register_kind(
		&"brittle_rocks",
		{"shape": "rect", "color": Color(0.45, 0.45, 0.5), "size": Vector2(96, 96)},
		true
	)
