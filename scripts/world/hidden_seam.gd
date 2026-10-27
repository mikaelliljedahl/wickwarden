extends Area2D
## A hidden opening: a seam in a wall, a sealed seam or hidden stairs. Solid and invisible until it is
## revealed (group `revealable`). Three ways to reveal it:
##
## - Glow jar: the jar calls `reveal()` on every revealable in its light, every physics frame while it
##   burns. The seam shows at once and stays open only while the calls go on. After EXPOSE_TIME (1.0 s) of
##   continuous exposure it unseals for good: flag "revealed_<seam_id>", no longer revealable. When the
##   calls stop before that, `hide_again()` (or the lapse of LIT_GRACE) hides it again.
## - Hook tap (`hook_tap` = true, the hook-tap wall): a lamp hook swing (kind `hook`) unseals it at once.
##   Fire, flare and sling do nothing.
## - `hide_again()` on a revealed seam does nothing: a permanent reveal stays.
##
## Shown means: the look is visible and the blocker body (layer WORLD, child `Body`) is off. A door
## (`door_target` names the room, `door_spawn` its spawn marker) is a RoomDoor made while the seam is
## shown and freed when it hides. Stairs and sealed seams to a cave or a pocket use it; a plain seam leaves
## it empty. The door is made at run time, not in the scene, because room checks read room scenes for
## RoomDoor nodes.
##
## Visual: the Placeholder kind `look` (hidden_seam, hidden_stairs, sealed_seam, hook_tap_wall). Scenes set
## it; the kinds are registered here, so no content work package edits Placeholder.KINDS.

const LIT_GRACE := 0.15
const EXPOSE_TIME := 1.0
const DOOR_NAME := "Door"
const BODY_NAME := "Body"

## Persistent id: the flag is "revealed_<seam_id>". Empty = not persistent (a reveal lasts for this visit).
@export var seam_id: StringName = &""
## Footprint in px (centred on the origin). The default fills a 192 px gap of a 96 px wall ring.
@export var size: Vector2 = Vector2(192, 96)
## Placeholder kind of the look: hidden_seam, hidden_stairs, sealed_seam or hook_tap_wall.
@export var look: StringName = &"hidden_seam"
## True: a lamp hook swing unseals it for good (the hook-tap wall).
@export var hook_tap: bool = false
## Room id of the door, empty for a plain seam. The room (cave, pocket) is entered through the RoomDoor.
@export var door_target: StringName = &""
## Spawn marker of `door_target` ("FromOverworld", "Inside", ...).
@export var door_spawn: StringName = &"Default"
## Gallery and capture only: starts in the revealed look without touching the flag.
@export var preview_revealed: bool = false

## True once the seam is open for good (flag set, or revealed in this visit with no id).
var is_revealed: bool = false
## True while the look is shown and the blocker is off (a live jar reveal, or a permanent reveal).
var is_shown: bool = false

var _lit_left: float = 0.0
var _exposure: float = 0.0
var _body_shape: CollisionShape2D
var _hurtbox: Hurtbox
var _door: RoomDoor


func _init() -> void:
	collision_layer = 0
	collision_mask = 0
	monitoring = false
	monitorable = false
	_register_looks()


func _ready() -> void:
	_build_body()
	if hook_tap:
		_build_hurtbox()
	SpriteVisual.attach(self, look, 0.0, size)
	GameState.flag_changed.connect(_on_flag_changed)
	if preview_revealed:
		_restore_revealed()
		return
	if seam_id != &"" and GameState.has_flag(flag_name()):
		_restore_revealed()
		return
	add_to_group(&"revealable")
	_set_open(false)


func _on_flag_changed(flag: StringName, value: bool) -> void:
	# Temporary light stays local. Only the permanent canonical flag opens a peer,
	# including one in a preloaded room with processing disabled.
	if value and not is_revealed and seam_id != &"" and flag == flag_name():
		_restore_revealed()


func _physics_process(delta: float) -> void:
	if not is_shown or is_revealed:
		return
	_lit_left -= delta
	if _lit_left <= 0.0:
		hide_again()
		return
	_exposure += delta
	if _exposure >= EXPOSE_TIME:
		_unseal()


func flag_name() -> StringName:
	return StringName("revealed_%s" % seam_id)


## Reveal contract (code-contract 16.3). The jar calls this every physics frame while its light covers the
## seam. The first call shows it; EXPOSE_TIME of continuous calls unseals it for good. No-op once revealed.
func reveal() -> void:
	if is_revealed or not is_inside_tree():
		return
	_lit_left = LIT_GRACE
	if not is_shown:
		_set_open(true)


## The light is gone before the seam unsealed: hide it again. A permanent reveal stays open.
func hide_again() -> void:
	if is_revealed or not is_shown:
		return
	_lit_left = 0.0
	_exposure = 0.0
	_set_open(false)


func _on_hurt(_hitbox: Hitbox) -> void:
	_unseal()


## Unseals for good: flag, no longer revealable, no tap, the door stays on.
func _unseal() -> void:
	if is_revealed:
		return
	_restore_revealed()
	if seam_id != &"":
		GameState.set_flag(flag_name())
	Audio.play_sfx(&"gate_open", global_position)


## Restore permanent state without publishing it or replaying source reveal effects.
func _restore_revealed() -> void:
	is_revealed = true
	_lit_left = 0.0
	_exposure = 0.0
	remove_from_group(&"revealable")
	if _hurtbox != null:
		_hurtbox.enabled = false
	_set_open(true)


## Shows (`open` true) or hides the look, the blocker and the door. Never reads the look back.
func _set_open(open: bool) -> void:
	is_shown = open
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		# Revealed stairs use the door's painted P14 stairs, without a second backing.
		var painted_stairs := (
			look == &"hidden_stairs"
			and door_target != &""
			and SpriteVisual.has_art(&"pocket_stairs")
		)
		visual.visible = open and not painted_stairs and not _painted_linked_door(visual)
	# Deferred: a reveal can happen during a physics step (a hook hit), where shapes may not change.
	_body_shape.set_deferred("disabled", open)
	if open:
		_show_door()
	else:
		_hide_door()


## A linked room door supplies the revealed entrance; do not draw a missing-art rectangle behind it.
## Keep real seam art and the fallback for standalone seams or doors without usable art.
func _painted_linked_door(visual: CanvasItem) -> bool:
	if not visual is Placeholder or get_parent() == null:
		return false
	for sibling in get_parent().get_children():
		if sibling is RoomDoor and not sibling.blocker_path.is_empty():
			if sibling.get_node_or_null(sibling.blocker_path) == self:
				return (
					not sibling._uses_building_door()
					and SpriteVisual.has_art(sibling.entrance_kind())
				)
	return false


## The door exists only while the seam is shown: a RoomDoor polls its overlaps in physics, so a hidden one
## would error. A RoomDoor is a core trigger; the seam sets its target and footprint.
func _show_door() -> void:
	if door_target == &"" or _door != null:
		return
	_door = RoomDoor.new()
	_door.name = DOOR_NAME
	_door.target_room = door_target
	_door.target_spawn = door_spawn
	_door.size = size
	add_child(_door)


func _hide_door() -> void:
	if _door == null:
		return
	_door.queue_free()
	_door = null


func _build_body() -> void:
	var body := StaticBody2D.new()
	body.name = BODY_NAME
	body.collision_layer = Layers.WORLD
	body.collision_mask = 0
	var rect := RectangleShape2D.new()
	rect.size = size
	_body_shape = CollisionShape2D.new()
	_body_shape.name = "Shape"
	_body_shape.shape = rect
	body.add_child(_body_shape)
	add_child(body)


func _build_hurtbox() -> void:
	_hurtbox = Hurtbox.new()
	_hurtbox.name = "Hurtbox"
	_hurtbox.team = Layers.Team.NEUTRAL
	_hurtbox.filter = func(hitbox: Hitbox): return hitbox.kind == &"hook"
	var rect := RectangleShape2D.new()
	rect.size = size
	var shape := CollisionShape2D.new()
	shape.shape = rect
	_hurtbox.add_child(shape)
	add_child(_hurtbox)
	_hurtbox.hurt.connect(_on_hurt)


static func _register_looks() -> void:
	_register_look(&"hidden_seam", Color(0.42, 0.4, 0.36))
	_register_look(&"hidden_stairs", Color(0.3, 0.27, 0.24))
	_register_look(&"sealed_seam", Color(0.5, 0.5, 0.55))
	_register_look(&"hook_tap_wall", Color(0.58, 0.5, 0.36))


static func _register_look(kind: StringName, color: Color) -> void:
	if Placeholder.has_kind(kind):
		return
	Placeholder.register_kind(
		kind, {"shape": "rect", "color": color, "size": Vector2(192, 96)}, true
	)
