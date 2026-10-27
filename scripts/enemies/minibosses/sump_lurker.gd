extends "res://scripts/enemies/boss_base.gd"
## C3 cistern miniboss. Only the surfaced window exposes its hurtbox.

const KIND := &"sump_lurker"
const GLIDE_SPEED := 160.0
const TRIGGER_RANGE := 300.0
const WARNING := 0.7
const SURFACED_TIME := 1.5
const DIVE_TIME := 0.4
const JET_INTERVAL := 2.5
const BITE_RADIUS := 150.0
const BITE_ANGLE := 120.0
# The row does not prescribe an active duration; one brief bite follows the warning.
const BITE_TIME := 0.12

enum State { SUBMERGED, TELEGRAPH, SURFACED, DIVE }

var state: State = State.SUBMERGED
var _timer := 0.0
var _jet_left := JET_INTERVAL
var _stun_immunity := 0.0
var _zone: Area2D
var _bite: Hitbox
var _bite_left := 0.0


func _init() -> void:
	max_hp = 16
	contact_damage = 3
	move_speed = GLIDE_SPEED
	body_radius = 40.0
	visual_kind = KIND
	drops_enabled = false
	miniboss = true
	arena_lock = false
	stun_scale = 1.0
	knockback_scale = 0.5
	water_only = true
	ignore_water = true
	Placeholder.register_kind(
		KIND, {"shape": "circle", "color": Color(0.64, 0.72, 0.64), "radius": 40.0}
	)
	Placeholder.register_kind(
		&"sump_water_jet", {"shape": "diamond", "color": Color(0.4, 0.75, 0.9), "radius": 12.0}
	)


func _enter_phase(_number: int) -> void:
	_timer = 0.0
	_jet_left = JET_INTERVAL
	_stun_immunity = 0.0
	_bite_left = 0.0
	if is_instance_valid(_bite):
		_bite.deactivate()
	_enter(State.SUBMERGED, 0.0)


func reset_fight() -> void:
	super()
	if not is_dead:
		_enter_phase(1)


func _confine() -> void:
	super()
	if is_instance_valid(_zone):
		global_position = _zone.call(&"nearest_point", global_position)


func _boss_physics(delta: float) -> void:
	velocity = Vector2.ZERO
	if _bite_left > 0.0:
		_bite_left -= delta
		if _bite_left <= 0.0 and is_instance_valid(_bite):
			_bite.deactivate()
	var zone := _home_zone()
	var player := get_player()
	if zone == null or player == null:
		return
	var shore := _nearest_shore(zone, player.global_position)
	var distance := shore.distance_to(player.global_position)
	match state:
		State.SUBMERGED:
			var offset := shore - global_position
			velocity = offset.normalized() * minf(GLIDE_SPEED, offset.length() / delta)
			if distance <= TRIGGER_RANGE and offset.length() <= 4.0:
				set_facing_dir(direction_to_player())
				_enter(State.TELEGRAPH, WARNING)
			else:
				_jet_left -= delta
				if distance > TRIGGER_RANGE and _jet_left <= 0.0:
					_fire_jet()
					_jet_left = JET_INTERVAL
		State.TELEGRAPH:
			_timer -= delta
			if _timer <= 0.0:
				_enter(State.SURFACED, SURFACED_TIME)
				_bite_attack()
		State.SURFACED:
			_timer -= delta
			if _timer <= 0.0:
				_enter(State.DIVE, DIVE_TIME)
		State.DIVE:
			_timer -= delta
			if _timer <= 0.0:
				_enter(State.SUBMERGED, 0.0)
	queue_redraw()


func _enter(next: State, duration: float) -> void:
	state = next
	_timer = duration
	hurtbox.enabled = state == State.SURFACED
	invulnerable = state != State.SURFACED
	set_contact_enabled(state == State.SURFACED)
	if visual != null:
		visual.visible = state != State.SUBMERGED
	queue_redraw()


func _nearest_shore(zone: Area2D, target: Vector2) -> Vector2:
	var point: Vector2 = zone.call(&"nearest_point", target)
	if not bool(zone.call(&"contains_point", target)):
		return point
	var rect: Rect2 = zone.call(&"global_rect")
	var candidates := [
		Vector2(rect.position.x, point.y),
		Vector2(rect.end.x, point.y),
		Vector2(point.x, rect.position.y),
		Vector2(point.x, rect.end.y)
	]
	var best := INF
	for candidate: Vector2 in candidates:
		var distance := candidate.distance_squared_to(target)
		if distance < best:
			best = distance
			point = candidate
	return point


func _home_zone() -> Area2D:
	if is_instance_valid(_zone):
		return _zone
	var scope: Node = _room()
	if scope == null:
		scope = get_parent()
	var best := INF
	for node in get_tree().get_nodes_in_group(&"shallows"):
		if not scope.is_ancestor_of(node) or not node.has_method(&"nearest_point"):
			continue
		var point: Vector2 = node.call(&"nearest_point", global_position)
		var distance := point.distance_squared_to(global_position)
		if distance < best:
			best = distance
			_zone = node as Area2D
	if _zone != null:
		global_position = _zone.call(&"nearest_point", global_position)
	return _zone


func _bite_attack() -> void:
	if not is_instance_valid(_bite):
		_bite = Hitbox.new()
		_bite.team = Layers.Team.ENEMY
		_bite.damage = 3
		_bite.kind = &"bite"
		_bite.source = self
		var polygon := CollisionPolygon2D.new()
		var points := PackedVector2Array([Vector2.ZERO])
		for i in range(17):
			points.append(Vector2.from_angle(deg_to_rad(-60.0 + 120.0 * i / 16.0)) * BITE_RADIUS)
		polygon.polygon = points
		_bite.add_child(polygon)
		add_child(_bite)
	_bite.rotation = facing_dir.angle()
	_bite.activate()
	_bite_left = BITE_TIME


func _fire_jet() -> void:
	var projectile := EnemyProjectile.new()
	projectile.speed = 200.0
	projectile.damage = 1
	projectile.visual_kind = &"sump_water_jet"
	projectile.room_rect = room_rect
	get_parent().add_child(projectile)
	projectile.launch(global_position, direction_to_player())
	var look := projectile.get_node_or_null("Visual") as Node2D
	if look is SpriteVisual:
		look.rotation = projectile.direction.angle()
	var light := PointLight2D.new()
	light.name = "WaterJetLight"
	light.texture = LightTexture.make()
	light.texture_scale = LightTexture.scale_for(90.0)
	light.color = Color(0.55, 0.8, 1.0)
	light.energy = 1.0
	projectile.add_child(light)
	add_hazard(projectile)


func stun(seconds: float) -> void:
	if state != State.SURFACED or _stun_immunity > 0.0 or is_stunned() or is_dying():
		return
	super.stun(minf(seconds, 1.5))


func _on_stunned(_seconds: float) -> void:
	if is_instance_valid(_bite):
		_bite.deactivate()
	_bite_left = 0.0
	set_contact_enabled(false)


func _on_stun_end() -> void:
	_stun_immunity = 3.0
	set_contact_enabled(state == State.SURFACED)


func _tick_timers(delta: float) -> void:
	super(delta)
	_stun_immunity = maxf(0.0, _stun_immunity - delta)


func _on_hurt(hitbox: Hitbox) -> void:
	super(hitbox)
	if is_dying():
		_stun_time = 0.0
		_knock_time = 0.0
		velocity = Vector2.ZERO
		set_contact_enabled(false)
		if is_instance_valid(_bite):
			_bite.deactivate()


func _on_death() -> void:
	super()
	for kind: StringName in [&"ember", &"ember", &"brass_coin", &"brass_coin"]:
		PickupBase.spawn(kind, get_parent(), global_position, true)


func _draw() -> void:
	if is_dead or is_dying():
		return
	if state == State.SUBMERGED or state == State.TELEGRAPH or state == State.DIVE:
		var color := Color(0.65, 0.9, 1.0, 0.8)
		var radius := 48.0 if state == State.TELEGRAPH else 24.0
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, color, 4.0)
		if state == State.TELEGRAPH:
			var angle := facing_dir.angle()
			draw_arc(Vector2.ZERO, BITE_RADIUS, angle - PI / 3, angle + PI / 3, 24, color, 3.0)
	if state == State.SUBMERGED and _jet_left < 0.5:
		draw_circle(Vector2.ZERO, 18.0, Color(0.4, 0.8, 1.0, 0.8))
