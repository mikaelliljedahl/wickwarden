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
## Rune glow: presentation only. Fades in to half strength when some (not all) braziers are lit.
var rune: PointLight2D
var _rune_tween: Tween
var _shake_tween: Tween

const RUNE_HALF_ENERGY := 0.5
const SHAKE_TIME := 0.3
const SHAKE_PX := 2.5


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0


func _ready() -> void:
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape = CollisionShape2D.new()
	_shape.shape = rect
	add_child(_shape)
	SpriteVisual.attach(self, &"gate", 0.0, size)
	rune = PointLight2D.new()
	rune.name = "Rune"
	rune.texture = LightTexture.make()
	rune.texture_scale = LightTexture.scale_for(size.x * 0.8)
	rune.color = Color(1.0, 0.5, 0.2)
	rune.energy = 0.0
	rune.visible = false
	add_child(rune)
	if gate_id != &"" and GameState.has_flag(flag_name()):
		_set_open(true)
		return
	for path in braziers:
		var node := get_node_or_null(path) as Brazier
		if node != null:
			_watched.append(node)
			node.lit_changed.connect(_on_lit_changed)
	_check()
	_update_rune(false)


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
	Audio.play_sfx(&"gate_open", global_position)
	opened.emit()


func _on_lit_changed(_is_lit: bool) -> void:
	_check()
	_update_rune(true)


func lit_count() -> int:
	var count := 0
	for brazier in _watched:
		if brazier.lit:
			count += 1
	return count


## Presentation only: rune glow and a short shake when progress is made. No logic is touched.
func _update_rune(animate: bool) -> void:
	if rune == null:
		return
	var partial := not is_open and lit_count() > 0 and lit_count() < _watched.size()
	var target := RUNE_HALF_ENERGY if partial else 0.0
	if _rune_tween != null:
		_rune_tween.kill()
	if not is_inside_tree() or not animate:
		rune.energy = target
		rune.visible = target > 0.0
		return
	rune.visible = true
	_rune_tween = create_tween()
	_rune_tween.tween_property(rune, "energy", target, 0.5)
	if target <= 0.0:
		_rune_tween.tween_callback(func() -> void: rune.visible = false)
	if partial:
		_shake()


func _shake() -> void:
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as Node2D
	if visual == null:
		return
	if _shake_tween != null:
		_shake_tween.kill()
	visual.position.x = 0.0
	_shake_tween = create_tween()
	for i in range(6):
		var sign_f := 1.0 if i % 2 == 0 else -1.0
		_shake_tween.tween_property(visual, "position:x", sign_f * SHAKE_PX, SHAKE_TIME / 7.0)
	_shake_tween.tween_property(visual, "position:x", 0.0, SHAKE_TIME / 7.0)


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
	_update_rune(false)
