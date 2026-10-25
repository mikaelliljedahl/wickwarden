extends StaticBody2D
## A prop that a fire hitbox (kind `fire`, from the cinder wick) burns open: a thorn hedge, a thorn
## wall or a thorn-sealed door. Solid until open. The first fire that touches it starts a burn; it
## opens `burn_time` seconds later and stays open. The opening sets the flag "burned_<burn_id>" when
## `burn_id` is set, so the prop starts open on every later visit and after a reload. Other hits
## (hook, flare, sling) do nothing. Use `on_fire(pos)` for any fire source.
##
## Visual: the Placeholder kind is `look`. Scenes set it (thorn_hedge, thorn_wall, thorn_door); the
## kinds are registered here, so no content work package edits Placeholder.KINDS.

## Id for the persistent flag. Empty = not persistent.
@export var burn_id: StringName = &""
## Footprint in px (centred on the origin). The default fills a 192 px gap of a 96 px wall ring.
@export var size: Vector2 = Vector2(192, 96)
## Placeholder kind of the look: thorn_hedge, thorn_wall or thorn_door.
@export var look: StringName = &"thorn_hedge"
## Seconds from the first fire touch to the opening.
@export var burn_time: float = 1.0

## Burning colour of the visual (presentation only).
const BURN_TINT := Color(1.0, 0.62, 0.32)

var is_open: bool = false
var is_burning: bool = false
var _burn_left: float = 0.0
var _shape: CollisionShape2D
var _hurtbox: Hurtbox


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0
	_register_looks()


func _ready() -> void:
	add_to_group(&"burnable")
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
	_shape.shape = rect
	add_child(_shape)
	_hurtbox = Hurtbox.new()
	_hurtbox.name = "Hurtbox"
	_hurtbox.team = Layers.Team.NEUTRAL
	_hurtbox.filter = func(hitbox: Hitbox) -> bool: return hitbox.kind == &"fire"
	var hurt_rect := RectangleShape2D.new()
	hurt_rect.size = size
	var hurt_shape := CollisionShape2D.new()
	hurt_shape.shape = hurt_rect
	_hurtbox.add_child(hurt_shape)
	add_child(_hurtbox)
	_hurtbox.hurt.connect(_on_hurt)
	SpriteVisual.attach(self, look, 0.0, size)
	GameState.flag_changed.connect(_on_flag_changed)
	if burn_id != &"" and GameState.has_flag(flag_name()):
		_open(false)


func _on_flag_changed(flag: StringName, value: bool) -> void:
	# Paired gates can already exist in a neighbour room with processing disabled.
	# The persistent flag opens both sides, without replaying the burn or its sound.
	if value and not is_open and burn_id != &"" and flag == flag_name():
		_open(false)


func _physics_process(delta: float) -> void:
	if not is_burning or is_open:
		return
	_burn_left -= delta
	if _burn_left <= 0.0:
		is_burning = false
		_open(true)


func flag_name() -> StringName:
	return StringName("burned_%s" % burn_id)


## Fire contract (code-contract 16.3). `pos` is the flame position in global space. The first call
## starts the burn; calls during the burn or after the opening do nothing.
func on_fire(_pos: Vector2) -> void:
	if is_open or is_burning:
		return
	is_burning = true
	_burn_left = burn_time
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.modulate = BURN_TINT


func _on_hurt(hitbox: Hitbox) -> void:
	on_fire(hitbox.global_position)


## Opens the prop for good. `persist` is false when the flag already exists (no sound, no new flag).
func _open(persist: bool) -> void:
	is_open = true
	is_burning = false
	remove_from_group(&"burnable")
	_hurtbox.enabled = false
	# Deferred: the opening can happen during a physics step (a fire touch), where shapes may not change.
	_shape.set_deferred("disabled", true)
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = false
		visual.modulate = Color.WHITE
	if persist:
		Audio.play_sfx(&"wall_break", global_position)
	if persist and burn_id != &"":
		GameState.set_flag(flag_name())


static func _register_looks() -> void:
	if Placeholder.has_kind(&"thorn_hedge"):
		return
	Placeholder.register_kind(
		&"thorn_hedge",
		{"shape": "rect", "color": Color(0.2, 0.42, 0.16), "size": Vector2(192, 96)},
		true
	)
	Placeholder.register_kind(
		&"thorn_wall",
		{"shape": "rect", "color": Color(0.36, 0.3, 0.2), "size": Vector2(192, 96)},
		true
	)
	Placeholder.register_kind(
		&"thorn_door",
		{"shape": "rect", "color": Color(0.28, 0.2, 0.14), "size": Vector2(192, 96)},
		true
	)
