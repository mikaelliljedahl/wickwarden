extends "res://scripts/world/liftable.gd"
## A heavy stone, boulder or door that only the heft mitts move (P06; world-plan 2.2, monster file 5.3).
## Group `heavy`. The hook, flare, ward and sling never hit it: its grab zone accepts kind `grab` only.
##
## `mode` picks the two behaviours:
## - LIFT (heavy stone): `lift_by_mitts(by)` carries it like a liftable. A thrown stone shatters on
##   landing and the gap it sat in stays open for good: flag `moved_<stone_id>`.
## - PUSH (boulder, heavy door): `try_move(dir)` is called on every physics frame while the player holds
##   toward it. After PUSH_HOLD seconds of holding, it slides STEP (96 px) in that direction, at most
##   MAX_STEPS times. A wall, the player or an enemy in the way stops it (the check is made before the slide).
##   Each finished slide sets flag `moved_<stone_id>` and the path flag `moved_<stone_id>@<path>`, where the
##   path is one letter per step (R, L, U, D). The path restores the final position on every later visit,
##   and a save keeps it. PUSH stones are never lifted.
##
## Empty `stone_id` = not persistent: the stone starts where the scene puts it.
## Visual: Placeholder kinds heavy_stone, heavy_boulder, heavy_door and heavy_stones (registered here).

enum Mode { LIFT, PUSH }

## Slide per step in px.
const STEP := 96.0
## Seconds the player must hold toward a PUSH stone before it slides one step.
const PUSH_HOLD := 0.5
## Seconds one slide takes.
const SLIDE_TIME := 0.25
## Steps a PUSH stone takes in all.
const MAX_STEPS := 3
const LETTERS := {"R": Vector2i.RIGHT, "L": Vector2i.LEFT, "D": Vector2i.DOWN, "U": Vector2i.UP}
const LOOKS := {
	&"heavy_stone": Color(0.42, 0.4, 0.38),
	&"heavy_boulder": Color(0.5, 0.46, 0.4),
	&"heavy_door": Color(0.36, 0.26, 0.18),
	&"heavy_stones": Color(0.4, 0.42, 0.44),
}

## Persistent id. The flags are `moved_<stone_id>` and `moved_<stone_id>@<path>`.
@export var stone_id: StringName = &""
@export var mode: Mode = Mode.LIFT
## Footprint in px (centred on the origin). A lift stone is usually 96 x 96; a cluster is wider.
@export var size: Vector2 = Vector2(96, 96)

## The steps a PUSH stone has taken, one letter each (see the header). Empty = at its start.
var path: String = ""
var _hold := 0.0
var _hold_dir := Vector2i.ZERO
var _last_push_frame := -1
var _sliding := false
var _slide_from := Vector2.ZERO
var _slide_to := Vector2.ZERO
var _slide_t := 0.0
var _slide_letter := ""


func _init() -> void:
	super._init()
	_register_heavy_looks()


## Mitts: lifts a LIFT stone (same carry as a liftable). A PUSH stone is refused.
func lift_by_mitts(by: Node2D) -> void:
	lift(by)


## Mitts push (PUSH mode). Call it on every physics frame while the player holds toward the stone.
## `dir` is snapped to one of the four directions. Ignored in LIFT mode, while carried or sliding.
func try_move(dir: Vector2) -> void:
	if mode != Mode.PUSH or state != State.LYING or _sliding or dir == Vector2.ZERO:
		return
	var frame := Engine.get_physics_frames()
	if frame == _last_push_frame:
		return
	_last_push_frame = frame
	var step_dir := _cardinal(dir)
	if step_dir != _hold_dir:
		_hold = 0.0
		_hold_dir = step_dir
	_hold += get_physics_process_delta_time()
	if _hold >= PUSH_HOLD:
		_start_slide(step_dir)


func _group() -> StringName:
	return &"heavy"


func _body_shape() -> Shape2D:
	var rect := RectangleShape2D.new()
	rect.size = size
	return rect


func _hit_radius() -> float:
	return maxf(size.x, size.y) * 0.5 + HIT_MARGIN


func _attach_visual() -> void:
	# The one-tile PUSH boulder shares the painted stone's one-tile footprint.
	# Keep its own fallback for other footprints or when that art is unavailable.
	var visual_kind := look
	if look == &"heavy_boulder" and size == Vector2(96, 96):
		if SpriteVisual.has_art(&"heavy_stone"):
			visual_kind = &"heavy_stone"
	SpriteVisual.attach(self, visual_kind, 0.0, size)


func _can_lift() -> bool:
	return mode == Mode.LIFT


func _on_ready() -> void:
	if stone_id == &"" or not GameState.has_flag(_moved_flag()):
		return
	if mode == Mode.LIFT:
		state = State.SHATTERED
		_hide_body()
		queue_free()
		return
	path = _saved_path()
	position += Vector2(_offset_of(path)) * STEP


func _on_shattered() -> void:
	if mode == Mode.LIFT and stone_id != &"":
		GameState.set_flag(_moved_flag())


func _physics_process(delta: float) -> void:
	if _sliding:
		_slide(delta)
	elif Engine.get_physics_frames() - _last_push_frame > 1:
		_hold = 0.0
		_hold_dir = Vector2i.ZERO
	super._physics_process(delta)


func _start_slide(step_dir: Vector2i) -> void:
	_hold = 0.0
	if path.length() >= MAX_STEPS:
		return
	var motion := Vector2(step_dir) * STEP
	if test_move(global_transform, motion):
		return
	_sliding = true
	_slide_from = global_position
	_slide_to = global_position + motion
	_slide_t = 0.0
	_slide_letter = _letter_of(step_dir)


func _slide(delta: float) -> void:
	_slide_t = minf(_slide_t + delta / SLIDE_TIME, 1.0)
	global_position = _slide_from.lerp(_slide_to, _slide_t)
	if _slide_t >= 1.0:
		_sliding = false
		_record_step(_slide_letter)


func _record_step(letter: String) -> void:
	var before := path
	path += letter
	if stone_id == &"":
		return
	GameState.set_flag(_moved_flag())
	GameState.set_flag(_path_flag(before), false)
	GameState.set_flag(_path_flag(path))


## The path flag of the last saved path of this stone, or "" when none is saved.
func _saved_path() -> String:
	var prefix := String(_path_flag(""))
	for key: Variant in GameState.flags:
		if String(key).begins_with(prefix):
			return String(key).trim_prefix(prefix)
	return ""


func _moved_flag() -> StringName:
	return StringName("moved_%s" % stone_id)


func _path_flag(saved: String) -> StringName:
	return StringName("moved_%s@%s" % [stone_id, saved])


## The snapped direction of `dir`: one of the four unit steps.
static func _cardinal(dir: Vector2) -> Vector2i:
	if absf(dir.x) > absf(dir.y):
		return Vector2i(int(signf(dir.x)), 0)
	return Vector2i(0, int(signf(dir.y)))


static func _letter_of(step: Vector2i) -> String:
	for letter: String in LETTERS:
		if LETTERS[letter] == step:
			return letter
	return ""


static func _offset_of(saved: String) -> Vector2i:
	var total := Vector2i.ZERO
	for letter in saved:
		total += LETTERS.get(letter, Vector2i.ZERO)
	return total


static func _register_heavy_looks() -> void:
	for kind: StringName in LOOKS:
		if Placeholder.has_kind(kind):
			continue
		Placeholder.register_kind(
			kind, {"shape": "rect", "color": LOOKS[kind], "size": Vector2(96, 96)}, true
		)
