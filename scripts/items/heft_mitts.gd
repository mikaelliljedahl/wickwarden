extends ItemBase
## Heft mitts (power glove, T04). `use_item` reaches GRAB_REACH px ahead with a grab hitbox (kind `grab`, radius
## GRAB_RADIUS, GRAB_TIME s). A liftable (rock, urn, pot, shard) or a LIFT heavy stone it touches is lifted: Tamsin is
## rooted for LIFT_TIME s, then carries it at CARRY_SPEED px/s (HEAVY_CARRY_SPEED for a heavy stone). While carrying,
## the hook and the items are off (lock_actions). `use_item` throws the object along the facing (liftable.gd: 480 px
## at 720 px/s, damage 3); the item then stays THROW_LOCKOUT s. The ward button puts the object down one grab reach
## ahead. A hit on Tamsin breaks it at her feet. A PUSH heavy stone the grab touches is pushed: while the move keys
## point along the push direction, `try_move` is called every frame. Nothing grabbed: a NOTHING_TIME s lockout.
## Spec: docs/monsters-bosses-tools.md, section 5.3.

const GRAB_REACH := 72.0
const GRAB_RADIUS := 48.0
const GRAB_TIME := 0.1
## Total time of the no-op use when nothing is grabbed.
const NOTHING_TIME := 0.2
const LIFT_TIME := 0.25
const CARRY_SPEED := 252.0
const HEAVY_CARRY_SPEED := 216.0
const THROW_LOCKOUT := 0.4
## Smallest dot product of the move input and the push direction that keeps a push going (about 45 degrees).
const PUSH_CONE := 0.7

enum Phase { GRAB, LIFT, CARRY, PUSH, LOCKOUT }

var _walker: Player
var _grab: Hitbox
var _phase: Phase = Phase.GRAB
var _left: float = 0.0
## The object in hand, or the stone being pushed. Null when none.
var _prop: Node2D
var _push_dir: Vector2 = Vector2.ZERO
var _locked: bool = false
var _use_was_held: bool = false
var _use_pressed: bool = false


func _init() -> void:
	item_id = &"heft_mitts"


func _ready() -> void:
	if not Placeholder.has_kind(&"heft_mitts"):
		Placeholder.register_kind(
			&"heft_mitts", {"shape": "arc", "color": Color(0.7, 0.55, 0.3, 0.7), "radius": 28.0}
		)
	var cue_script := load("res://scripts/art/tool_cue_visual.gd") as GDScript
	if cue_script != null:
		cue_script.call(&"attach", self, &"heft_mitts", facing)
	_grab = Hitbox.new()
	_grab.name = "GrabHitbox"
	_grab.kind = &"grab"
	_grab.team = Layers.Team.PLAYER
	_grab.damage = 0
	_grab.knockback = 0.0
	_grab.add_circle(GRAB_RADIUS)
	_grab.hit_landed.connect(_on_grab_hit)
	add_child(_grab)


## Refuses while another mitts node is in the tree (a grab, a carry, a push or the lockout after a throw). Nothing
## is spent. The hook and the items are locked from here on, except while pushing.
func activate() -> bool:
	_walker = player as Player
	if _walker == null or active_count() > 1:
		return false
	_grab.position = facing * GRAB_REACH
	_grab.activate()
	_walker.hurt_taken.connect(_on_hurt_taken)
	_use_was_held = Input.is_action_pressed(&"use_item")
	_set_lock(true)
	_phase = Phase.GRAB
	_left = GRAB_TIME
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as Node2D
	if visual != null and visual.has_method(&"set_facing"):
		visual.call(&"set_facing", facing)
	return true


func _physics_process(delta: float) -> void:
	if not is_instance_valid(_walker):
		finish()
		return
	global_position = _walker.global_position
	var use_held := Input.is_action_pressed(&"use_item")
	_use_pressed = use_held and not _use_was_held
	_use_was_held = use_held
	match _phase:
		Phase.GRAB:
			_left -= delta
			if _left <= 0.0:
				_enter_lockout(NOTHING_TIME - GRAB_TIME)
		Phase.LIFT:
			if not _carrying():
				_end()
				return
			_left -= delta
			if _left <= 0.0:
				_phase = Phase.CARRY
				_set_scale(_carry_scale())
		Phase.CARRY:
			_update_carry()
		Phase.PUSH:
			_update_push()
		Phase.LOCKOUT:
			_left -= delta
			if _left <= 0.0:
				_end()


func _exit_tree() -> void:
	if _carrying():
		_prop.call(&"put_down", _prop.global_position)
	_release()
	if is_instance_valid(_walker) and _walker.hurt_taken.is_connected(_on_hurt_taken):
		_walker.hurt_taken.disconnect(_on_hurt_taken)


## The grab hitbox touched a prop. Liftables and heavy stones are lifted (a PUSH stone refuses the lift and is pushed).
func _on_grab_hit(hurtbox: Hurtbox) -> void:
	if _phase != Phase.GRAB:
		return
	var prop := hurtbox.get_parent() as Node2D
	if prop == null or prop.is_queued_for_deletion():
		return
	if not (prop.is_in_group(&"liftable") or prop.is_in_group(&"heavy")):
		return
	_grab.deactivate()
	_prop = prop
	prop.call(&"lift", _walker)
	if _carrying():
		_show_effort()
		_phase = Phase.LIFT
		_left = LIFT_TIME
		_set_scale(0.0)
	else:
		_phase = Phase.PUSH
		_push_dir = _walker.get_facing()
		_set_lock(false)


## Carrying: the ward puts the object down, `use_item` throws it, a hit breaks it (see _on_hurt_taken).
func _update_carry() -> void:
	if not _carrying():
		_end()
		return
	if Input.is_action_pressed(&"ward"):
		_prop.call(&"put_down", _put_down_spot())
		_end()
		return
	if _use_pressed:
		_show_effort()
		_prop.call(&"throw", _walker.get_facing())
		_prop = null
		_enter_lockout(THROW_LOCKOUT)


## Pushing: each frame the move keys point along the push direction, the stone is asked to move.
func _update_push() -> void:
	if not is_instance_valid(_prop) or _carrying():
		_end()
		return
	var move := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if move.dot(_push_dir) < PUSH_CONE:
		_end()
		return
	_prop.call(&"try_move", _push_dir)


## A hit drops the object at her feet and breaks it there.
func _on_hurt_taken(_amount: int) -> void:
	if _carrying():
		_prop.global_position = _walker.global_position
		_prop.call(&"shatter")
		_end()


func _carrying() -> bool:
	return (
		is_instance_valid(_prop)
		and not _prop.is_queued_for_deletion()
		and bool(_prop.call(&"is_carried"))
	)


func _carry_scale() -> float:
	var speed := HEAVY_CARRY_SPEED if _prop.is_in_group(&"heavy") else CARRY_SPEED
	return speed / Player.WALK_SPEED


## A free spot one grab reach ahead, or the player's own spot when a WORLD body is there.
func _put_down_spot() -> Vector2:
	var spot := _walker.global_position + _walker.get_facing() * GRAB_REACH
	var query := PhysicsPointQueryParameters2D.new()
	query.position = spot
	query.collision_mask = Layers.WORLD
	if get_world_2d().direct_space_state.intersect_point(query).is_empty():
		return spot
	return _walker.global_position


func _enter_lockout(seconds: float) -> void:
	_phase = Phase.LOCKOUT
	_left = seconds
	_set_scale(1.0)
	_set_lock(true)


func _end() -> void:
	_release()
	finish()


func _release() -> void:
	_set_lock(false)
	_set_scale(1.0)


func _set_lock(on: bool) -> void:
	if _locked == on or not is_instance_valid(_walker):
		return
	_locked = on
	_walker.lock_actions(self, on)


func _set_scale(factor: float) -> void:
	if is_instance_valid(_walker):
		_walker.set_speed_scale(self, factor)


func _show_effort() -> void:
	var visual := get_node_or_null(Placeholder.VISUAL_NAME)
	if visual != null and visual.has_method(&"show_mitts_effort"):
		visual.call(&"show_mitts_effort", _walker.global_position)
