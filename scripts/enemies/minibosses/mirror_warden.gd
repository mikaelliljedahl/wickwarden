extends "res://scripts/enemies/boss_base.gd"
## C5 pre-jar answer: four room-owned hook-lit braziers dissolve the two reflections.

const KIND := &"mirror_warden"
const SWAP_INTERVAL := 5.0
const WARNING := 0.5
const SLASH_GAP := 0.3
const SLASH_REACH := 130.0
const SLASH_ARC := 100.0
const SLASH_ACTIVE := 0.12  # Same short active window as the hook; row fixes spacing, not duration.
const APPROACH := 1.5  # Unspecified combo cadence: a brief approach between combos.
const REVEAL_TIME := 1.0

enum State { WALK, TELEGRAPH, COMBO, RECOVER }

var state: State = State.WALK
var decoys: Array[Node2D] = []
var _timer := APPROACH
var _swap_left := SWAP_INTERVAL
var _flash_left := 0.0
var _reveal_left := 0.0
var _stun_immunity := 0.0
var _slash_left := 0.0
var _slashes := 0
var _aim := Vector2.RIGHT
var _slash: Hitbox


class Reflection:
	extends Node2D
	## A sensor, not a Hurtbox: reflections never receive damage, stun or enemy drops.
	signal struck
	var enabled := true
	var _sensor: Area2D
	var _cooldown := 0.0
	var _crack_left := 0.0

	func _ready() -> void:
		SpriteVisual.attach(self, &"mirror_warden")
		_sensor = Area2D.new()
		_sensor.collision_layer = 0
		_sensor.collision_mask = Layers.PLAYER_HITBOX
		var shape := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 30.0
		shape.shape = circle
		_sensor.add_child(shape)
		add_child(_sensor)

	func _physics_process(delta: float) -> void:
		_cooldown = maxf(0.0, _cooldown - delta)
		_crack_left = maxf(0.0, _crack_left - delta)
		if enabled and _cooldown <= 0.0:
			for area in _sensor.get_overlapping_areas():
				if area is Hitbox and area.active and area.team == Layers.Team.PLAYER:
					_cooldown = 0.28
					_crack_left = REVEAL_TIME
					struck.emit()
					break
		queue_redraw()

	func _draw() -> void:
		if _crack_left > 0.0:
			draw_line(Vector2(-18, -18), Vector2(15, 10), Color.WHITE, 4.0)
			draw_line(Vector2(15, 10), Vector2(-12, 25), Color.WHITE, 4.0)


func _init() -> void:
	max_hp = 18
	contact_damage = 2
	move_speed = 150.0
	body_radius = 30.0
	visual_kind = KIND
	miniboss = true
	arena_lock = false
	drops_enabled = false
	stun_scale = 1.0
	knockback_scale = 0.5
	Placeholder.register_kind(
		KIND, {"shape": "circle", "color": Color(0.72, 0.78, 0.9), "radius": 30.0}
	)


func _enter_tree() -> void:
	# Room snapshots an already-ready enemy. Discard copies before even a retired enemy enters.
	decoys = []
	for child in get_children():
		if child is Reflection:
			remove_child(child)
			child.free()


func _boss_ready() -> void:
	for i in range(2):
		var reflection := Reflection.new()
		reflection.name = "Reflection%d" % i
		reflection.top_level = true
		add_child(reflection)
		reflection.struck.connect(_on_decoy_hit)
		decoys.append(reflection)


func _enter_phase(_number: int) -> void:
	state = State.WALK
	_timer = APPROACH
	_swap_left = SWAP_INTERVAL
	_flash_left = 0.0
	_reveal_left = 0.0
	_stun_immunity = 0.0
	_slash_left = 0.0
	_slashes = 0
	_cancel_slash()
	for i in range(decoys.size()):
		decoys[i].global_position = _safe_spot(global_position + Vector2(192 * (2 * i - 1), -144))
		decoys[i]._crack_left = 0.0
		decoys[i]._cooldown = 0.0
	_refresh_decoys()


func reset_fight() -> void:
	super()
	if not is_dead:
		_enter_phase(1)


func _boss_physics(delta: float) -> void:
	velocity = Vector2.ZERO
	_timer -= delta
	_swap_left -= delta
	if _swap_left <= 0.0:
		_swap_places()
		_swap_left = SWAP_INTERVAL
	if _slash_left > 0.0:
		_slash_left -= delta
		if _slash_left <= 0.0:
			_cancel_slash()
	match state:
		State.WALK:
			var direction := direction_to_player()
			set_facing_dir(direction)
			velocity = direction * move_speed
			if _timer <= 0.0:
				state = State.TELEGRAPH
				_timer = WARNING
				_aim = facing_dir
				velocity = Vector2.ZERO
		State.TELEGRAPH:
			if _timer <= 0.0:
				state = State.COMBO
				_slashes = 0
				_next_slash()
		State.COMBO:
			if _timer <= 0.0:
				if _slashes < 3:
					_next_slash()
				else:
					state = State.RECOVER
					_timer = SLASH_GAP
		State.RECOVER:
			if _timer <= 0.0:
				state = State.WALK
				_timer = APPROACH
	_refresh_decoys()
	queue_redraw()


func _next_slash() -> void:
	if not is_instance_valid(_slash):
		_slash = Hitbox.new()
		_slash.team = Layers.Team.ENEMY
		_slash.damage = 2
		_slash.kind = &"slash"
		_slash.source = self
		var polygon := CollisionPolygon2D.new()
		var points := PackedVector2Array([Vector2.ZERO])
		for i in range(17):
			points.append(Vector2.from_angle(deg_to_rad(-50.0 + 100.0 * i / 16.0)) * SLASH_REACH)
		polygon.polygon = points
		_slash.add_child(polygon)
		add_child(_slash)
	_slash.rotation = _aim.angle()
	_slash.activate()
	_slash_left = SLASH_ACTIVE
	_slashes += 1
	_timer = SLASH_GAP


func _cancel_slash() -> void:
	if is_instance_valid(_slash):
		_slash.deactivate()
	_slash_left = 0.0


func _scope() -> Node:
	var room := _room()
	return room if room != null else get_parent()


func lit_brazier_count() -> int:
	var count := 0
	var scope := _scope()
	for node in get_tree().get_nodes_in_group(&"braziers"):
		if scope.is_ancestor_of(node) and node is Brazier and node.lit:
			count += 1
	return mini(count, 4)


func _refresh_decoys() -> void:
	var opacity := 1.0 - 0.25 * lit_brazier_count()
	for reflection in decoys:
		reflection.enabled = opacity > 0.0 and not is_dying() and not is_dead
		reflection.visible = reflection.enabled
		reflection.modulate = (
			Color(1.8, 1.8, 1.8, opacity) if _flash_left > 0.0 else Color(1, 1, 1, opacity)
		)


func _safe_spot(at: Vector2) -> Vector2:
	var point := at
	if room_rect.size != Vector2.ZERO:
		var interior := room_rect.grow(-body_radius)
		point = point.clamp(interior.position, interior.end)
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = body_radius
	query.shape = shape
	query.transform = Transform2D(0.0, point)
	query.collision_mask = collision_mask
	return (
		global_position
		if not get_world_2d().direct_space_state.intersect_shape(query).is_empty()
		else point
	)


func _swap_places() -> void:
	if decoys.size() != 2:
		return
	var old := global_position
	var target := _safe_spot(decoys[0].global_position)
	global_position = target
	decoys[0].global_position = decoys[1].global_position
	decoys[1].global_position = old
	_flash_left = 0.15


func _on_decoy_hit() -> void:
	_reveal_left = REVEAL_TIME
	queue_redraw()


func stun(seconds: float) -> void:
	if _stun_immunity > 0.0 or is_stunned() or is_dying():
		return
	super.stun(minf(seconds, 1.5))


func _on_stunned(_seconds: float) -> void:
	_cancel_slash()
	state = State.RECOVER
	_timer = SLASH_GAP
	set_contact_enabled(false)


func _on_stun_end() -> void:
	_stun_immunity = 3.0
	set_contact_enabled(not is_dying())


func _tick_timers(delta: float) -> void:
	super(delta)
	_stun_immunity = maxf(0.0, _stun_immunity - delta)
	_reveal_left = maxf(0.0, _reveal_left - delta)
	_flash_left = maxf(0.0, _flash_left - delta)
	if not decoys.is_empty():
		_refresh_decoys()
		queue_redraw()


func _on_hurt(hitbox: Hitbox) -> void:
	super(hitbox)
	if is_dying():
		_stun_time = 0.0
		_knock_time = 0.0
		velocity = Vector2.ZERO
		_cancel_slash()
		set_contact_enabled(false)
		_refresh_decoys()


func _on_death() -> void:
	super()
	for kind: StringName in [&"ember", &"ember", &"brass_coin", &"brass_coin"]:
		PickupBase.spawn(kind, get_parent(), global_position, true)


func _draw() -> void:
	if is_dead or is_dying():
		return
	if state == State.TELEGRAPH:
		draw_arc(
			Vector2.ZERO,
			SLASH_REACH,
			_aim.angle() - deg_to_rad(50),
			_aim.angle() + deg_to_rad(50),
			24,
			Color(1, 0.85, 0.4),
			4.0
		)
	if _reveal_left > 0.0 or _flash_left > 0.0:
		draw_arc(Vector2.ZERO, 45.0, 0, TAU, 32, Color(0.7, 0.9, 1), 5.0)
