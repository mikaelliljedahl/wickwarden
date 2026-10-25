class_name LockedDoor
extends StaticBody2D
## A scoped key lock. A cave Lockpick opens every key lock in its cave and is retained.
## Otherwise one small key of the door's scope is spent. Overworld locks require overworld keys.
## Opens persist through flag "door_<id>" when `door_id` is set. Solid until open.

signal opened

@export var door_id: StringName = &""
@export var size: Vector2 = Vector2(192, 96)
@export var scope: StringName = &"ow"

var is_open: bool = false
var _shape: CollisionShape2D
var _trigger: Area2D


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0


func _ready() -> void:
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape = CollisionShape2D.new()
	_shape.shape = rect
	add_child(_shape)
	_trigger = Area2D.new()
	_trigger.name = "KeyTrigger"
	_trigger.collision_layer = 0
	_trigger.collision_mask = Layers.PLAYER_BODY
	var trigger_rect := RectangleShape2D.new()
	trigger_rect.size = size + Vector2(24, 24)
	var trigger_shape := CollisionShape2D.new()
	trigger_shape.shape = trigger_rect
	_trigger.add_child(trigger_shape)
	add_child(_trigger)
	SpriteVisual.attach(self, &"locked_door", 0.0, size)
	GameState.flag_changed.connect(_on_flag_changed)
	if door_id != &"" and GameState.has_flag(flag_name()):
		_set_open(true)


func _on_flag_changed(flag: StringName, value: bool) -> void:
	# A paired endpoint may already be loaded with processing disabled.
	# Apply saved state only; never spend, replay effects or broadcast the flag again.
	if value and not is_open and door_id != &"" and flag == flag_name():
		_set_open(true)


func flag_name() -> StringName:
	return StringName("door_%s" % door_id)


## Prefers the retained cave Lockpick, otherwise spends one scoped small key.
func try_unlock() -> bool:
	if is_open:
		return false
	if not GameState.has_big_key(scope) and not GameState.use_key(scope):
		return false
	if door_id != &"":
		GameState.set_flag(flag_name())
	_set_open(true)
	Audio.play_sfx(&"door_unlock", global_position)
	opened.emit()
	return true


func _physics_process(_delta: float) -> void:
	if is_open:
		return
	if _trigger.has_overlapping_bodies():
		try_unlock()


func _set_open(value: bool) -> void:
	is_open = value
	_shape.set_deferred("disabled", value)
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = not value
