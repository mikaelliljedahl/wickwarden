extends StaticBody2D
## The Ninth Door (`ow_10_8`): the giant sealed door that closes the mouth of C10, the Ninth Hollow. Nine
## sockets sit in the door, one for the lantern fragment of each of C1 to C9. A socket is lit when that
## fragment is held (`GameState.has_fragment`, flag `frag_cN`). The door opens when the player touches it
## while all nine are held. Nothing is spent: the fragments stay. The opening sets the flag `door_ninth`,
## so the door starts open on every later visit and after a reload. Solid until open.
##
## Visual: the Placeholder kind `ninth_door`; each socket is a child `Socket_cN` drawn with the kind
## `ninth_socket` (dark) or `ninth_socket_lit`. The kinds are registered here, so no content work package
## edits Placeholder.KINDS. The sockets hide with the door.

signal opened

const OPEN_FLAG := &"door_ninth"
const DOOR_KIND := &"ninth_door"
const SOCKET_KIND := &"ninth_socket"
const SOCKET_LIT_KIND := &"ninth_socket_lit"
const SOCKET_RADIUS := 7.0
const SOCKET_SPACING := 20.0
const SOCKET_ROW_Y := -18.0

## Footprint in px (centred on the origin). The default is the width of a room gap.
@export var size: Vector2 = Vector2(192, 96)

var is_open: bool = false
var _shape: CollisionShape2D
var _trigger: Area2D
var _sockets: Array[Placeholder] = []


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0
	_register_kinds()


func _ready() -> void:
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
	_shape.shape = rect
	add_child(_shape)
	_trigger = Area2D.new()
	_trigger.name = "OpenTrigger"
	_trigger.collision_layer = 0
	_trigger.collision_mask = Layers.PLAYER_BODY
	var trigger_rect := RectangleShape2D.new()
	trigger_rect.size = size + Vector2(24, 24)
	var trigger_shape := CollisionShape2D.new()
	trigger_shape.shape = trigger_rect
	_trigger.add_child(trigger_shape)
	add_child(_trigger)
	SpriteVisual.attach(self, DOOR_KIND, 0.0, size)
	_add_sockets()
	GameState.fragment_acquired.connect(_on_fragment_acquired)
	if GameState.has_flag(OPEN_FLAG):
		_set_open(true)


func _physics_process(_delta: float) -> void:
	if is_open or not _trigger.has_overlapping_bodies():
		return
	try_open()


## True when all nine sockets are lit.
func can_open() -> bool:
	return lit_count() == GameState.FRAGMENT_CAVES


## Number of lit sockets, 0 to nine.
func lit_count() -> int:
	var count := 0
	for index in GameState.FRAGMENT_CAVES:
		if GameState.has_fragment(_cave_at(index)):
			count += 1
	return count


## Opens the door when all nine fragments are held. Returns false if it is already open or one is missing.
func try_open() -> bool:
	if is_open or not can_open():
		return false
	GameState.set_flag(OPEN_FLAG)
	_set_open(true)
	Audio.play_sfx(&"door_unlock", global_position)
	opened.emit()
	return true


func _add_sockets() -> void:
	var count := GameState.FRAGMENT_CAVES
	for index in count:
		var socket := Placeholder.new()
		socket.name = "Socket_%s" % _cave_at(index)
		socket.kind = SOCKET_KIND
		socket.radius = SOCKET_RADIUS
		socket.position = Vector2(
			(float(index) - float(count - 1) * 0.5) * SOCKET_SPACING, SOCKET_ROW_Y
		)
		add_child(socket)
		_sockets.append(socket)
	_refresh_sockets()


func _refresh_sockets() -> void:
	for index in _sockets.size():
		var lit := GameState.has_fragment(_cave_at(index))
		_sockets[index].set_kind(SOCKET_LIT_KIND if lit else SOCKET_KIND)


## Socket `index` (0 to 8) belongs to cave index + 1: c1 .. c9.
func _cave_at(index: int) -> StringName:
	return StringName("c%d" % (index + 1))


func _on_fragment_acquired(_cave: StringName) -> void:
	_refresh_sockets()


func _set_open(value: bool) -> void:
	is_open = value
	_shape.set_deferred("disabled", value)
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = not value
	for socket in _sockets:
		socket.visible = not value


static func _register_kinds() -> void:
	if not Placeholder.has_kind(DOOR_KIND):
		Placeholder.register_kind(
			DOOR_KIND,
			{"shape": "rect", "color": Color(0.26, 0.24, 0.3), "size": Vector2(192, 96)},
			true
		)
	if not Placeholder.has_kind(SOCKET_KIND):
		Placeholder.register_kind(
			SOCKET_KIND,
			{"shape": "circle", "color": Color(0.1, 0.1, 0.14), "radius": SOCKET_RADIUS},
			true
		)
	if not Placeholder.has_kind(SOCKET_LIT_KIND):
		Placeholder.register_kind(
			SOCKET_LIT_KIND,
			{"shape": "circle", "color": Color(1.0, 0.9, 0.55), "radius": SOCKET_RADIUS},
			true
		)
