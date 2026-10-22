class_name Gate
extends StaticBody2D
## A barrier that opens when every listed Brazier is lit. Solid until open.
## Open state persists through the flag "gate_<id>" when `gate_id` is set.
##
## Set `braziers` to NodePaths (relative to the gate) in the room scene.

signal opened

@export var gate_id: StringName = &""
@export var braziers: Array[NodePath] = []
@export var size: Vector2 = Vector2(192, 96)

var is_open: bool = false
var _shape: CollisionShape2D
var _watched: Array[Brazier] = []


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0


func _ready() -> void:
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape = CollisionShape2D.new()
	_shape.shape = rect
	add_child(_shape)
	Placeholder.attach(self, &"gate", 0.0, size)
	if gate_id != &"" and GameState.has_flag(flag_name()):
		_set_open(true)
		return
	for path in braziers:
		var node := get_node_or_null(path) as Brazier
		if node != null:
			_watched.append(node)
			node.lit_changed.connect(_on_lit_changed)
	_check()


func flag_name() -> StringName:
	return StringName("gate_%s" % gate_id)


func watch(brazier: Brazier) -> void:
	_watched.append(brazier)
	brazier.lit_changed.connect(_on_lit_changed)


func open() -> void:
	if is_open:
		return
	if gate_id != &"":
		GameState.set_flag(flag_name())
	_set_open(true)
	opened.emit()


func _on_lit_changed(_is_lit: bool) -> void:
	_check()


func _check() -> void:
	if _watched.is_empty():
		return
	for brazier in _watched:
		if not brazier.lit:
			return
	open()


func _set_open(value: bool) -> void:
	is_open = value
	_shape.set_deferred("disabled", value)
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = not value
