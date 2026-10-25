extends StaticBody2D
## The boss door of a cave: a large door with a lantern-shaped lock. It opens when the player touches
## it while holding the big key of its cave (`GameState.has_big_key(cave)`, flag `bigkey_cN`). The big
## key is not spent: it opens the door for good, and the flag `door_boss_<cave>` keeps the door open on
## every later visit and after a reload. Solid until open. Small keys and other caves' big keys do not
## open it.
##
## Visual: the Placeholder kind `boss_door`, registered here (no content WP edits Placeholder.KINDS).

signal opened

## Cave id of the door, "c1" .. "c10". Required: the scene is a template, rooms set it.
@export var cave: StringName = &""
## Footprint in px (centred on the origin). The default is the width of a room gap.
@export var size: Vector2 = Vector2(192, 96)

var is_open: bool = false
var _shape: CollisionShape2D
var _trigger: Area2D


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0
	_register_look()


func _ready() -> void:
	if GameState.cave_number(cave) == 0:
		push_error("BossDoor: %s needs a cave id (c1 .. c10)" % name)
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
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
	SpriteVisual.attach(self, &"boss_door", 0.0, size)
	GameState.flag_changed.connect(_on_flag_changed)
	if cave != &"" and GameState.has_flag(flag_name()):
		_set_open(true)


func _on_flag_changed(flag: StringName, value: bool) -> void:
	# A paired door may be loaded in a room with processing disabled.
	# Restore the canonical state without spending keys or replaying unlock effects.
	if value and not is_open and cave != &"" and flag == flag_name():
		_set_open(true)


func _physics_process(_delta: float) -> void:
	if is_open or not _trigger.has_overlapping_bodies():
		return
	try_open()


func flag_name() -> StringName:
	return StringName("door_boss_%s" % cave)


## Opens the door when the big key of its cave is held. The key is kept. Returns false if already open
## or the key is missing.
func try_open() -> bool:
	if is_open or not GameState.has_big_key(cave):
		return false
	GameState.set_flag(flag_name())
	_set_open(true)
	Audio.play_sfx(&"door_unlock", global_position)
	opened.emit()
	return true


func _set_open(value: bool) -> void:
	is_open = value
	_shape.set_deferred("disabled", value)
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = not value


static func _register_look() -> void:
	if Placeholder.has_kind(&"boss_door"):
		return
	Placeholder.register_kind(
		&"boss_door",
		{"shape": "rect", "color": Color(0.58, 0.42, 0.14), "size": Vector2(192, 96)},
		true
	)
