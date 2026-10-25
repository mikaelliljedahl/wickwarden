extends StaticBody2D
## Eye switch and the eye-linked blockers it opens. One script, two roles (`blocker` picks one):
##
## - Switch (default, group `eye_switch`): a wall-mounted eye. A tallow sling slug (`Hitbox.kind ==
##   &"sling"`) turns it on for good and sets the flag `eye_<eye_id>`. A hook swing or a flare does nothing.
##   Once on, it stops taking hits.
## - Blocker (`blocker = true`, group `eye_blocker`): a solid barrier (eye portcullis, eye cell). It opens
##   when the flag `eye_<eye_id>` exists: at once on a later visit, or live when a switch of the same id
##   turns on (the switch calls `open_for_eye` on every blocker of the group). Opening disables its collision
##   and hides it.
##
## The room places a switch and its blockers with the same `eye_id`; the id is the only link. Nothing
## reads a room node, so rooms can unload at any time.

signal turned_on
signal opened

const SWITCH_GROUP := &"eye_switch"
const BLOCKER_GROUP := &"eye_blocker"
const SWITCH_KIND := &"eye_switch"
const SWITCH_ON_KIND := &"eye_switch_on"
const SWITCH_RADIUS := 28.0
const SWITCH_BODY_RADIUS := 30.0
const SWITCH_HURT_RADIUS := 56.0

## Persistent id, shared by a switch and its blockers. The flag is `eye_<eye_id>`.
@export var eye_id: StringName = &""
## False: an eye switch. True: a solid blocker that opens on the same id.
@export var blocker: bool = false
## Look of a blocker: `eye_portcullis` or `eye_cell` (Placeholder kinds). Unused by a switch.
@export var look: StringName = &"eye_portcullis"
## Footprint of a blocker in px (centred on the origin). Unused by a switch.
@export var size: Vector2 = Vector2(192, 96)

var is_on: bool = false
var is_open: bool = false
var hurtbox: Hurtbox
var _shape: CollisionShape2D


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0


func _ready() -> void:
	_register_kinds()
	if eye_id == &"":
		push_error("EyeSwitch: %s needs an eye_id" % name)
	if blocker:
		_ready_blocker()
	else:
		_ready_switch()


func flag_name() -> StringName:
	return StringName("eye_%s" % eye_id)


## Turns a switch on (no-op when already on). Sets the flag and tells every blocker of this id.
func turn_on() -> void:
	if is_on or blocker:
		return
	is_on = true
	hurtbox.enabled = false
	if eye_id != &"":
		GameState.set_flag(flag_name())
	Audio.play_sfx(&"hook_clank", global_position)
	_refresh()
	turned_on.emit()
	get_tree().call_group(BLOCKER_GROUP, "open_for_eye", eye_id)


## Opens a blocker whose id matches. Other ids and switches are ignored.
func open_for_eye(id: StringName) -> void:
	if not blocker or is_open or id != eye_id or eye_id == &"":
		return
	_open(true)


func _ready_switch() -> void:
	add_to_group(SWITCH_GROUP)
	var body := CircleShape2D.new()
	body.radius = SWITCH_BODY_RADIUS
	var body_shape := CollisionShape2D.new()
	body_shape.shape = body
	add_child(body_shape)
	hurtbox = Hurtbox.new()
	hurtbox.name = "Hurtbox"
	hurtbox.team = Layers.Team.NEUTRAL
	hurtbox.add_circle(SWITCH_HURT_RADIUS)
	hurtbox.filter = _accepts_hit
	add_child(hurtbox)
	hurtbox.hurt.connect(_on_hurt)
	SpriteVisual.attach(self, SWITCH_KIND, SWITCH_RADIUS)
	if eye_id != &"" and GameState.has_flag(flag_name()):
		is_on = true
		hurtbox.enabled = false
	_refresh()


func _ready_blocker() -> void:
	add_to_group(BLOCKER_GROUP)
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
	_shape.shape = rect
	add_child(_shape)
	SpriteVisual.attach(self, look, 0.0, size)
	if eye_id != &"" and GameState.has_flag(flag_name()):
		_open(false)


## Hurtbox veto: only a sling slug reaches a switch that is still off.
func _accepts_hit(hitbox: Hitbox) -> bool:
	return not is_on and hitbox.kind == &"sling"


func _on_hurt(_hitbox: Hitbox) -> void:
	turn_on()


func _open(persist: bool) -> void:
	is_open = true
	# Deferred: a switch can be turned on during a physics step (a slug hit), where shapes may not change.
	_shape.set_deferred("disabled", true)
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = false
	if persist:
		Audio.play_sfx(&"gate_open", global_position)
	opened.emit()


func _refresh() -> void:
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as Node2D
	if visual != null and visual.has_method("set_kind"):
		visual.call("set_kind", SWITCH_ON_KIND if is_on else SWITCH_KIND)


static func _register_kinds() -> void:
	if not Placeholder.has_kind(SWITCH_KIND):
		Placeholder.register_kind(
			SWITCH_KIND,
			{"shape": "circle", "color": Color(0.45, 0.36, 0.22), "radius": SWITCH_RADIUS},
			true
		)
	if not Placeholder.has_kind(SWITCH_ON_KIND):
		Placeholder.register_kind(
			SWITCH_ON_KIND,
			{"shape": "circle", "color": Color(1.0, 0.85, 0.4), "radius": SWITCH_RADIUS},
			true
		)
	if not Placeholder.has_kind(&"eye_portcullis"):
		Placeholder.register_kind(
			&"eye_portcullis",
			{"shape": "rect", "color": Color(0.3, 0.3, 0.36), "size": Vector2(192, 96)},
			true
		)
	if not Placeholder.has_kind(&"eye_cell"):
		Placeholder.register_kind(
			&"eye_cell",
			{"shape": "rect", "color": Color(0.36, 0.26, 0.2), "size": Vector2(192, 96)},
			true
		)
