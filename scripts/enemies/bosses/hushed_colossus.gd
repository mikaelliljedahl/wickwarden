extends "res://scripts/enemies/boss_base.gd"
## C4: falling ammunition, unwardable floor attacks, three wakes. Rewards belong to the cave room.

const WALK := [60.0, 80.0, 100.0]
const SLAM_INTERVAL := 4.0
const SHARD_INTERVAL := [5.0, 4.0, 4.0]
const SLAM_RADIUS := 80.0
const RING_RADIUS := 160.0
var slam_left := SLAM_INTERVAL
var shard_left := 5.0
var sweep_left := 5.0
var quake_left := 8.0
var combo_left := 0.0
var combo_count := 0
var shards: Array[Node2D] = []
var _home := Vector2.ZERO
var _origin := Vector2.ZERO
var _arena_light: PointLight2D


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
	var sweep_light: PointLight2D
	var quake_texture: Texture2D
	var wave_texture: Texture2D
	var shard_fall_texture: Texture2D

	func _ready() -> void:
		if get_parent().kind in [&"quake", &"slam"]:
			var path := "res://assets/sprites/colossus_quake_z1_idle.png"
			if ResourceLoader.exists(path):
				quake_texture = load(path) as Texture2D
		if get_parent().kind in [&"ring", &"sweep"]:
			var path := "res://assets/sprites/unlit_wax_wave_z1_idle.png"
			if ResourceLoader.exists(path):
				wave_texture = load(path) as Texture2D
		if get_parent().kind == &"fall":
			var path := "res://assets/sprites/colossus_shard_fall.png"
			if ResourceLoader.exists(path):
				shard_fall_texture = load(path) as Texture2D
		if get_parent().kind == &"sweep":
			# The attack sets the band orientation immediately after it enters the tree.
			call_deferred(&"_make_sweep_light")

	func _make_sweep_light() -> void:
		var attack: Node2D = get_parent()
		var gradient := Gradient.new()
		gradient.set_color(0, Color.WHITE)
		gradient.set_color(1, Color.WHITE)
		var texture := GradientTexture2D.new()
		texture.width = int(attack.band_size.x)
		texture.height = int(attack.band_size.y)
		texture.gradient = gradient
		sweep_light = PointLight2D.new()
		sweep_light.name = "SweepWarningLight"
		sweep_light.texture = texture
		sweep_light.color = Color(1.0, 0.72, 0.3)
		sweep_light.energy = 0.12
		add_child(sweep_light)

	func _process(_delta: float) -> void:
		if is_instance_valid(sweep_light):
			sweep_light.visible = not get_parent().fired

	func _draw() -> void:
		var attack: Node2D = get_parent()
		var color := Color(0.95, 0.65, 0.28, 0.35 if not attack.fired else 0.7)
		match attack.kind:
			&"sweep":
				if wave_texture != null:
					var horizontal: bool = attack.band_size.x > attack.band_size.y
					var length: float = attack.band_size.x if horizontal else attack.band_size.y
					if not horizontal:
						draw_set_transform(Vector2.ZERO, PI * 0.5)
					draw_texture_rect(
						wave_texture, Rect2(-length * 0.5, -48, length, 96), false,
						Color(0.9, 0.65, 0.4, 1.0 if attack.fired else 0.45)
					)
					draw_set_transform(Vector2.ZERO)
				elif attack.fired:
					draw_rect(Rect2(-attack.band_size * 0.5, attack.band_size), color)
				draw_rect(
					Rect2(-attack.band_size * 0.5, attack.band_size),
					Color(1.0, 0.8, 0.4, 0.7 if attack.fired else 0.9), false, 2.0
				)
			&"quake":
				for row in range(1, 9, 4):
					for col in range(1, 19, 4):
						var block := Rect2(col * 96, row * 96, mini(4, 19 - col) * 96, 384)
						var danger: bool = FloorAttack.quake_cell(row, col) == attack.parity
						if not attack.fired:
							if danger:
								draw_rect(block, Color(0.95, 0.30, 0.08, 0.12))
								draw_rect(block.grow(-3), Color(1.0, 0.69, 0.25, 0.9), false, 4.0)
								if quake_texture != null:
									for tile_row in range(row, row + 4, 2):
										for tile_col in range(col, mini(col + 4, 19), 2):
											draw_texture_rect(
												quake_texture, Rect2(tile_col * 96, tile_row * 96, 192, 192),
												false, Color(1, 1, 1, 0.65)
											)
							else:
								# The entire cool outline lies at least 24 px inside the safe block.
								var safe := block.grow(-28)
								draw_rect(safe, Color(0.12, 0.72, 0.75, 0.10))
								draw_rect(safe, Color(0.45, 0.95, 0.95, 0.8), false, 4.0)
						elif danger:
							draw_rect(block, Color(0.95, 0.24, 0.04, 0.6))
							if quake_texture != null:
								for tile_row in range(row, row + 4):
									for tile_col in range(col, mini(col + 4, 19)):
										draw_texture_rect(quake_texture, Rect2(tile_col * 96, tile_row * 96, 96, 96), false)
			&"ring":
				var radius: float = attack.ring_radius()
				if wave_texture != null and radius > 1.0:
					for i in range(96):
						var a := Vector2.from_angle(TAU * i / 96.0)
						var b := Vector2.from_angle(TAU * (i + 1) / 96.0)
						var inner := maxf(0.0, radius - 24.0)
						var outer := radius + 24.0
						var points := PackedVector2Array([a * inner, b * inner, b * outer, a * outer])
						var u := float(i) / 96.0
						var next_u := float(i + 1) / 96.0
						var uv := PackedVector2Array([Vector2(u, 0), Vector2(next_u, 0), Vector2(next_u, 1), Vector2(u, 1)])
						draw_polygon(points, PackedColorArray([Color(0.9, 0.65, 0.4)]), uv, wave_texture)
				else:
					draw_arc(Vector2.ZERO, radius, 0, TAU, 64, color, 14.0)
				draw_arc(Vector2.ZERO, radius, 0, TAU, 96, Color(1, 0.8, 0.4, 0.75), 2.0)
			&"fall":
				# Keep the full floor shadow visible while the painted shard descends.
				draw_circle(Vector2.ZERO, 60.0, Color(0.14, 0.09, 0.06, 0.45))
				draw_arc(Vector2.ZERO, 60.0, 0, TAU, 48, Color(1, 0.85, 0.55), 3)
				if shard_fall_texture != null and not attack.fired:
					var progress: float = clampf((attack.age / maxf(attack.warning, 0.001) - 0.5) * 2.0, 0.0, 1.0)
					if progress > 0.0:
						var height := 120.0 * (1.0 - progress)
						draw_texture_rect(shard_fall_texture, Rect2(-48, -48 - height, 96, 96), false)
			_:
				var radius := 60.0 if attack.kind == &"fall" else SLAM_RADIUS
				if attack.kind != &"slam" or attack.fired:
					draw_circle(Vector2.ZERO, radius, color)
				if attack.kind == &"slam" and quake_texture != null:
						draw_texture_rect(
							quake_texture, Rect2(-SLAM_RADIUS, -SLAM_RADIUS, SLAM_RADIUS * 2, SLAM_RADIUS * 2), false,
						Color(1, 1, 1, 1.0 if attack.fired else 0.55)
					)
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
		return clampf((age - warning) / 0.4, 0.0, 1.0) * RING_RADIUS

	static func quake_cell(row: int, col: int) -> int:
		return (int((row - 1) / 4.0) + int((col - 1) / 4.0)) % 2

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
						if quake_cell(row, col) == parity:
							_rect(Vector2(col * 96 + 48, row * 96 + 48), Vector2(96, 96))
			&"ring":
				for i in range(40):
					ring_shapes.append(box.add_circle(14.0))
			_:
				box.add_circle(60.0 if kind == &"fall" else SLAM_RADIUS)
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
	Events.room_entered.connect(_on_room_entered)
	_make_arena_light()


func _on_room_entered(room_id: StringName) -> void:
	if room_id == arena_id and not is_defeated() and not is_dead:
		_make_arena_light()
	else:
		_clear_arena_light()


func _make_arena_light() -> void:
	if is_instance_valid(_arena_light):
		return
	var gradient := Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color.WHITE)
	var texture := GradientTexture2D.new()
	texture.width = 1920
	texture.height = 960
	texture.gradient = gradient
	_arena_light = PointLight2D.new()
	_arena_light.name = "ArenaPresentationLight"
	_arena_light.texture = texture
	_arena_light.color = Color(1.0, 0.9, 0.76)
	_arena_light.energy = 0.75
	add_child(_arena_light)
	_arena_light.top_level = true
	_arena_light.global_position = _origin + Vector2(960, 480)


func _clear_arena_light() -> void:
	if is_instance_valid(_arena_light):
		_arena_light.queue_free()
		_arena_light = null


func arena_point(local: Vector2) -> Vector2:
	return _origin + local


## The band starts at the arena edge on the Colossus's side and crosses to the opposite edge.
static func _sweep_points(horizontal: bool, boss_at: Vector2) -> Array:
	if horizontal:
		return [Vector2(960, 816), Vector2(960, 144)] if boss_at.y >= 480 else [
			Vector2(960, 144), Vector2(960, 816)
		]
	return [Vector2(1776, 480), Vector2(144, 480)] if boss_at.x >= 960 else [
		Vector2(144, 480), Vector2(1776, 480)
	]


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
	_make_arena_light()
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
			var points := _sweep_points(horizontal, position)
			var attack := start_attack(&"sweep", arena_point(points[0]), 0.8, 0.5)
			attack.band_size = Vector2(1728, 96) if horizontal else Vector2(96, 768)
			attack.sweep_from = arena_point(points[0])
			attack.sweep_to = arena_point(points[1])
	if phase == 3:
		quake_left -= delta
		# Finish the whole slam combo, including its ring, before warning a quake.
		if quake_left <= 0.0 and combo_count == 0 and not _slam_in_progress():
			quake_left = 8.0
			var quake := start_attack(&"quake", arena_point(Vector2.ZERO), 1.2, 0.2)
			quake.parity = randi() % 2


func _slam_in_progress() -> bool:
	for hazard in _hazards:
		if is_instance_valid(hazard) and not hazard.is_queued_for_deletion():
			if hazard is FloorAttack and hazard.kind in [&"slam", &"ring"]:
				return true
	return false


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
	_clear_arena_light()
	super.reset_fight()
	if not is_dead and not is_defeated():
		position = _home
		_enter_phase(1)


func _on_hurt(hit: Hitbox) -> void:
	super._on_hurt(hit)
	if is_dying():
		set_contact_enabled(false)


func _on_death() -> void:
	_clear_arena_light()
	super._on_death()
	spawn_pickup(&"ember", ARENA_CENTRE + Vector2(-96, 0), true)
	spawn_pickup(&"ember", ARENA_CENTRE + Vector2(96, 0), true)


func _exit_tree() -> void:
	_clear_arena_light()
	if Events.room_entered.is_connected(_on_room_entered):
		Events.room_entered.disconnect(_on_room_entered)
	clear_hazards()
	super._exit_tree()
