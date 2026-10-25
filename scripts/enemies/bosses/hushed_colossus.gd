extends "res://scripts/enemies/boss_base.gd"
## C4: falling ammunition, unwardable floor attacks, three wakes. Rewards belong to the cave room.

const WALK := [60.0, 80.0, 100.0]
const SLAM_INTERVAL := 4.0
const SHARD_INTERVAL := [5.0, 4.0, 4.0]
var slam_left := SLAM_INTERVAL
var shard_left := 5.0
var sweep_left := 5.0
var quake_left := 8.0
var combo_left := 0.0
var combo_count := 0
var shards: Array[Node2D] = []
var _home := Vector2.ZERO
var _origin := Vector2.ZERO


class Shard:
	extends "res://scripts/world/liftable.gd"
	var floor_left := 12.0

	func _init() -> void:
		super._init()
		radius = 36.0
		look = &"colossus_shard"

	func _physics_process(delta: float) -> void:
		super._physics_process(delta)
		if state == State.LYING:
			floor_left -= delta
			if floor_left <= 0.0:
				queue_free()


class FloorVisual:
	extends Node2D

	func _draw() -> void:
		var attack: Node2D = get_parent()
		var color := Color(0.95, 0.65, 0.28, 0.35 if not attack.fired else 0.7)
		match attack.kind:
			&"sweep":
				draw_rect(Rect2(-attack.band_size * 0.5, attack.band_size), color)
			&"quake":
				for row in range(1, 9):
					for col in range(1, 19):
						if (row + col) % 2 == attack.parity:
							draw_rect(Rect2(col * 96, row * 96, 96, 96), color)
			&"ring":
				draw_arc(Vector2.ZERO, attack.ring_radius(), 0, TAU, 64, color, 14.0)
			_:
				var radius := 60.0 if attack.kind == &"fall" else 130.0
				draw_circle(Vector2.ZERO, radius, color)
				draw_arc(Vector2.ZERO, radius, 0, TAU, 48, Color(1, 0.85, 0.55), 3)


## Each attack owns its warning and hitbox, so clearing hazards cancels pending impacts too.
class FloorAttack:
	extends Node2D
	var colossus: EnemyBase
	var kind: StringName = &"slam"
	var warning := 0.8
	var active_time := 0.1
	var age := 0.0
	var fired := false
	var parity := 0
	var band_size := Vector2(1728, 96)
	var sweep_from := Vector2.ZERO
	var sweep_to := Vector2.ZERO
	var box: Hitbox
	var ring_shapes: Array[CollisionShape2D] = []

	func _ready() -> void:
		var picture := FloorVisual.new()
		picture.name = "Visual"
		add_child(picture)

	func ring_radius() -> float:
		return clampf((age - warning) / 0.4, 0.0, 1.0) * 260.0

	func _physics_process(delta: float) -> void:
		age += delta
		if kind == &"slam" and age < 0.3 and is_instance_valid(colossus):
			global_position = colossus.player_position(global_position)
		if not fired and age >= warning:
			fired = true
			_impact()
		if fired and kind == &"sweep":
			global_position = sweep_from.lerp(sweep_to, clampf((age - warning) / active_time, 0, 1))
		if fired and kind == &"ring":
			for i in range(ring_shapes.size()):
				ring_shapes[i].position = Vector2.from_angle(TAU * i / 40.0) * ring_radius()
		get_node("Visual").queue_redraw()
		if age >= warning + active_time:
			queue_free()

	func _rect(at: Vector2, dimensions: Vector2) -> void:
		var shape := RectangleShape2D.new()
		shape.size = dimensions
		var collision := CollisionShape2D.new()
		collision.shape = shape
		collision.position = at
		box.add_child(collision)

	func _impact() -> void:
		box = Hitbox.new()
		box.team = Layers.Team.ENEMY
		box.kind = kind
		box.damage = 2 if kind in [&"ring", &"fall"] else 3
		box.blockable = false
		box.knockback = 0.0
		box.source = self
		match kind:
			&"sweep":
				_rect(Vector2.ZERO, band_size)
			&"quake":
				for row in range(1, 9):
					for col in range(1, 19):
						if (row + col) % 2 == parity:
							_rect(Vector2(col * 96 + 48, row * 96 + 48), Vector2(96, 96))
			&"ring":
				for i in range(40):
					ring_shapes.append(box.add_circle(14.0))
			_:
				box.add_circle(60.0 if kind == &"fall" else 130.0)
		add_child(box)
		box.activate()
		if not is_instance_valid(colossus):
			return
		if kind == &"slam":
			colossus.call(&"start_attack", &"ring", global_position, 0.0, 0.4)
		elif kind == &"fall":
			colossus.call(&"land_shard", global_position)


func _init() -> void:
	boss_id = &"hushed_colossus"
	arena_id = &"cave_4_10"
	max_hp = 48
	thresholds = [32, 16]
	body_radius = 90.0
	stun_scale = 0.0
	knockback_scale = 0.0
	drops_enabled = false
	contact_damage = 3
	move_speed = 60.0
	arena_lock = false
	death_drops = []
	visual_kind = &"hushed_colossus"
	_register_looks()


static func _register_looks() -> void:
	if not Placeholder.has_kind(&"hushed_colossus"):
		Placeholder.register_kind(
			&"hushed_colossus", {"shape": "circle", "color": Color(0.5, 0.48, 0.44), "radius": 90.0}
		)
	if not Placeholder.has_kind(&"colossus_shard"):
		Placeholder.register_kind(
			&"colossus_shard",
			{"shape": "rect", "color": Color(0.65, 0.61, 0.52), "size": Vector2(60, 64)},
			true
		)


func _boss_ready() -> void:
	_home = position
	_origin = global_position - Vector2(960, 640)


func arena_point(local: Vector2) -> Vector2:
	return _origin + local


func _enter_phase(_number: int) -> void:
	slam_left = SLAM_INTERVAL
	shard_left = SHARD_INTERVAL[phase - 1]
	sweep_left = 5.0
	quake_left = 8.0
	combo_count = 0
	combo_left = 0.0
	shards = []
	move_speed = WALK[phase - 1]
	if visual != null:
		visual.modulate = Color(1.0, 1.0 - 0.12 * (phase - 1), 1.0 - 0.2 * (phase - 1))


func _boss_physics(delta: float) -> void:
	velocity = direction_to_player() * move_speed
	slam_left -= delta
	shard_left -= delta
	if slam_left <= 0.0:
		slam_left += SLAM_INTERVAL
		combo_count = phase
		combo_left = 0.0
	if combo_count > 0:
		combo_left -= delta
		if combo_left <= 0.0:
			start_attack(&"slam", player_position(global_position), 0.8, 0.1)
			combo_count -= 1
			combo_left = 0.5 if phase == 3 else 0.6
	if shard_left <= 0.0:
		shard_left += SHARD_INTERVAL[phase - 1]
		shard_rain()
	if phase == 2:
		sweep_left -= delta
		if sweep_left <= 0.0:
			sweep_left += 5.0
			var horizontal := randi() % 2 == 0
			var local := Vector2(960, clampf(position.y, 144, 816))
			if not horizontal:
				local = Vector2(clampf(position.x, 144, 1776), 480)
			var attack := start_attack(&"sweep", arena_point(local), 0.8, 0.5)
			attack.band_size = Vector2(1728, 96) if horizontal else Vector2(96, 768)
			attack.sweep_from = arena_point(Vector2(960, 144) if horizontal else Vector2(144, 480))
			attack.sweep_to = arena_point(Vector2(960, 816) if horizontal else Vector2(1776, 480))
			attack.global_position = attack.sweep_from
	if phase == 3:
		quake_left -= delta
		if quake_left <= 0.0:
			quake_left += 8.0
			var quake := start_attack(&"quake", arena_point(Vector2.ZERO), 1.2, 0.2)
			quake.parity = randi() % 2


func start_attack(kind: StringName, at: Vector2, warning: float, active_time: float) -> FloorAttack:
	var attack := FloorAttack.new()
	attack.kind = kind
	attack.warning = warning
	attack.active_time = active_time
	attack.colossus = self
	attack.position = get_parent().to_local(at)
	get_parent().add_child(attack)
	add_hazard(attack)
	return attack


func shard_rain() -> void:
	var reserved := floor_shards()
	for hazard in _hazards:
		if is_instance_valid(hazard) and not hazard.is_queued_for_deletion():
			if hazard is FloorAttack and hazard.kind == &"fall" and not hazard.fired:
				reserved += 1
	var count := mini(3 if phase == 3 else 2, 4 - reserved)
	for i in range(maxi(count, 0)):
		var at := arena_point(Vector2(randf_range(192, 1728), randf_range(192, 768)))
		start_attack(&"fall", at, 1.0, 0.1)


func floor_shards() -> int:
	var count := 0
	for shard in shards:
		if is_instance_valid(shard) and not shard.is_queued_for_deletion():
			if shard.state == shard.State.LYING:
				count += 1
	return count


func land_shard(at: Vector2) -> void:
	if floor_shards() >= 4:
		return
	var shard := Shard.new()
	shard.position = get_parent().to_local(at)
	get_parent().add_child(shard)
	shards.append(shard)
	add_hazard(shard)


func _resolve_damage(hit: Hitbox, _amount: int) -> int:
	if hit.kind == &"thrown":
		return 6
	if hit.kind == &"explosion":
		return 2
	return 0


func reset_fight() -> void:
	if is_defeated():
		return
	super.reset_fight()
	if not is_dead and not is_defeated():
		position = _home
		_enter_phase(1)


func _on_hurt(hit: Hitbox) -> void:
	super._on_hurt(hit)
	if is_dying():
		set_contact_enabled(false)


func _on_death() -> void:
	super._on_death()
	spawn_pickup(&"ember", ARENA_CENTRE + Vector2(-96, 0), true)
	spawn_pickup(&"ember", ARENA_CENTRE + Vector2(96, 0), true)


func _exit_tree() -> void:
	clear_hazards()
	super._exit_tree()
