extends StaticBody2D
## A wax seal: a solid block in a vent, alcove or cache mouth that only a charge flare melts. A flare
## hitbox (`Hitbox.kind == &"flare"`) melts it at once and it opens for good; it sets the flag
## "melted_<seal_id>" when `seal_id` is set, so the seal starts open on every later visit and after a
## reload. A hook swing, a sling slug, fire or any other hit does nothing. `melt()` is the same opening
## for any other flare source.
##
## Visual: the Placeholder kind `wax_seal`, registered here, so no content work package edits
## Placeholder.KINDS.

const FLARE_KIND := &"flare"
const MELT_FLAG_PREFIX := "melted_"
const LOOK := &"wax_seal"
const LOOK_SIZE := Vector2(192, 96)

## Id for the persistent flag. Empty = not persistent.
@export var seal_id: StringName = &""
## Footprint in px (centred on the origin). The default fills a 192 px gap of a 96 px wall ring.
@export var size: Vector2 = LOOK_SIZE

var is_open: bool = false
var _shape: CollisionShape2D
var _hurtbox: Hurtbox


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0
	_register_look()


func _ready() -> void:
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
	_shape.shape = rect
	add_child(_shape)
	_hurtbox = Hurtbox.new()
	_hurtbox.name = "Hurtbox"
	_hurtbox.team = Layers.Team.NEUTRAL
	_hurtbox.filter = func(hitbox: Hitbox) -> bool: return hitbox.kind == FLARE_KIND
	var hurt_rect := RectangleShape2D.new()
	hurt_rect.size = size
	var hurt_shape := CollisionShape2D.new()
	hurt_shape.shape = hurt_rect
	_hurtbox.add_child(hurt_shape)
	add_child(_hurtbox)
	_hurtbox.hurt.connect(_on_hurt)
	Placeholder.attach(self, LOOK, 0.0, size)
	if seal_id != &"" and GameState.has_flag(flag_name()):
		_open(false)


func flag_name() -> StringName:
	return StringName("%s%s" % [MELT_FLAG_PREFIX, seal_id])


## Melts the seal open for good. Returns false when it is already open. Sets the flag when `seal_id`
## is set.
func melt() -> bool:
	if is_open:
		return false
	_open(true)
	return true


func _on_hurt(_hitbox: Hitbox) -> void:
	melt()


func _open(persist: bool) -> void:
	is_open = true
	_hurtbox.enabled = false
	# Deferred: the melt can happen during a physics step (a flare touch), where shapes may not change.
	_shape.set_deferred("disabled", true)
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = false
	if persist:
		Audio.play_sfx(&"wall_break", global_position)
	if persist and seal_id != &"":
		GameState.set_flag(flag_name())


static func _register_look() -> void:
	if Placeholder.has_kind(LOOK):
		return
	Placeholder.register_kind(
		LOOK, {"shape": "rect", "color": Color(0.82, 0.22, 0.16), "size": LOOK_SIZE}, true
	)
