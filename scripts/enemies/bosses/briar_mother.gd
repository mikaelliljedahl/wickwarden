extends "res://scripts/enemies/boss_base.gd"
## B02: three sling-only eyes, then the flammable bloom. Root ruling: spore warning is 0.5 s.
## Cadences include their warning. All coordinates are room-local; parts are room-owned siblings.

const EYE_SCENE := "res://scenes/enemies/bosses/seed_eye.tscn"
const SNAPPER_SCENE := "res://scenes/enemies/bramble_snapper.tscn"
const MARKER_SCENE := "res://scenes/enemies/telegraph.tscn"
const EYE_POINTS := [Vector2(480, 480), Vector2(960, 576), Vector2(1440, 480)]
const CANOPY := Vector2(960, 192)
const BLOOM := Vector2(960, 288)
const SPORE_WARNING := 0.5
const SEED_WARNING := 0.8
const SWEEP_WARNING := 0.7
const SWEEP_ACTIVE := 0.3
const SEED_LIFE := 3.0
const BURST_RADIUS := 120.0
const SWEEP_ROWS := [288.0, 480.0, 672.0]

var eyes: Array[EnemyBase] = []
var seeds: Array[EnemyBase] = []
var snappers: Array[EnemyBase] = []
var dead_eyes := 0
var _clock := 0.0
var _shot_left: Array[float] = []
var _seed_left := 4.0
var _sweep_left := 3.0
var _pending: Array[Dictionary] = []


class Seed:
	extends EnemyBase
	var mother: EnemyBase
	var age := 0.0

	func _init() -> void:
		max_hp = 1
		contact_damage = 0
		move_speed = 0.0
		drops_enabled = false
		stun_scale = 0.0
		knockback_scale = 0.0
		visual_kind = &"briar_seed"

	func _enemy_ready() -> void:
		add_to_group(&"burnable")
		hurtbox.filter = func(hit: Hitbox) -> bool: return hit.kind in [&"hook", &"flare", &"fire"]

	func _enemy_physics(delta: float) -> void:
		age += delta
		if age >= SEED_LIFE:
			if is_instance_valid(mother):
				mother.call(&"burst_seed", global_position)
			kill()

	func on_fire(_at: Vector2) -> void:
		kill()


## Short-lived area attack. Its life counts physics time, including the final damage frame.
class ThornArea:
	extends Node2D
	var life := SWEEP_ACTIVE
	var box: Hitbox
	var band := false

	func _ready() -> void:
		box = Hitbox.new()
		box.team = Layers.Team.ENEMY
		box.damage = 2
		box.kind = &"sweep" if band else &"burst"
		box.blockable = false
		box.source = self
		box.knockback = 640.0
		box.knockback_time = 0.14
		if band:
			var shape := RectangleShape2D.new()
			shape.size = Vector2(1920, 96)
			var collision := CollisionShape2D.new()
			collision.shape = shape
			box.add_child(collision)
		else:
			box.add_circle(BURST_RADIUS)
		add_child(box)
		Placeholder.attach(self, &"briar_band" if band else &"briar_burst")
		box.activate()

	func _physics_process(delta: float) -> void:
		life -= delta
		if life <= 0.0:
			box.deactivate()
			queue_free()


func _init() -> void:
	boss_id = &"briar_mother"
	arena_id = &"cave_2_9"
	max_hp = 28  # 3 x 4 eye HP, followed by the 16 HP bloom.
	thresholds = [16]
	contact_damage = 0
	move_speed = 0.0
	body_radius = 80.0
	stun_scale = 0.0
	knockback_scale = 0.0
	drops_enabled = false
	resupply = true
	visual_kind = &"briar_canopy"
	_register_briar_kinds()


func arena_point(local: Vector2) -> Vector2:
	var room := _room()
	if room != null:
		return room.global_position + local
	var parent := get_parent() as Node2D
	return local + (parent.global_position if parent != null else Vector2.ZERO)


func _boss_ready() -> void:
	hurtbox.filter = _bloom_open
	# Room snapshots placed enemies as templates before enter(). A template must never enqueue
	# sibling parts: those would survive the snapshot and duplicate the live boss's eyes.
	var room := _room()
	if room == null or room.is_entered:
		_make_eyes()


func _process(_delta: float) -> void:
	var painted := visual as SpriteVisual
	if painted != null:
		if phase == 1:
			painted.play_anim(&"eye_lost" if dead_eyes > 0 else &"idle")
		else:
			var sweeping := _sweep_left >= 3.0 - SWEEP_WARNING - SWEEP_ACTIVE
			painted.play_anim(&"sweep" if sweeping else &"idle")
	for eye in eyes:
		if not is_instance_valid(eye):
			continue
		var look := eye.visual as SpriteVisual
		if look == null:
			continue
		var spitting := false
		for entry in _pending:
			if entry.kind == &"spore" and entry.eye == eye:
				spitting = true
				break
		look.play_anim(&"spore" if spitting else &"idle")


func _bloom_open(_hit: Hitbox) -> bool:
	return phase == 2


func _make_eyes() -> void:
	eyes = []
	_shot_left = [2.0, 2.0, 2.0]
	var scene := load(EYE_SCENE) as PackedScene
	if scene == null:
		return
	for point in EYE_POINTS:
		var eye := scene.instantiate() as EnemyBase
		if eye == null:
			continue
		eye.invulnerable = true
		eyes.append(eye)
		adopt_part(eye, arena_point(point))


func _enter_phase(number: int) -> void:
	_pending.clear()
	seeds.clear()
	snappers.clear()
	_seed_left = 4.0 if number == 1 else 3.0
	_sweep_left = 3.0
	if number == 1:
		_clock = 0.0
		dead_eyes = 0
		global_position = arena_point(CANOPY)
		if eyes.is_empty():
			_make_eyes()
	else:
		global_position = arena_point(BLOOM)
		if visual != null and visual.has_method(&"set_kind"):
			visual.call(&"set_kind", &"briar_bloom")


func _boss_physics(delta: float) -> void:
	_tick_pending(delta)
	_clock += delta
	if phase == 1:
		_tick_eyes(delta)
	else:
		_sweep_left -= delta
		if _sweep_left <= SWEEP_WARNING:
			_warn_sweep()
			_sweep_left += 3.0
	_seed_left -= delta
	if _seed_left <= SEED_WARNING:
		warn_seed()
		_seed_left += seed_interval()


func _tick_eyes(delta: float) -> void:
	for i in range(eyes.size()):
		var eye := eyes[i]
		if not is_instance_valid(eye) or eye.is_dead or eye.hurtbox == null:
			continue
		var lowered := fposmod(_clock + float(i) * 3.0, 9.0) < 6.0
		eye.visible = lowered
		eye.invulnerable = not lowered
		eye.hurtbox.enabled = lowered
		eye.global_position = arena_point(
			EYE_POINTS[i] + Vector2(96.0 * sin(TAU * _clock / 4.0), 0.0)
		)
		_shot_left[i] -= delta
		if _shot_left[i] <= SPORE_WARNING:
			if lowered:
				_warn_spore(eye)
			_shot_left[i] += spore_interval()


func spore_interval() -> float:
	return 2.0 - 0.4 * dead_eyes


func seed_interval() -> float:
	return 4.0 - 0.5 * dead_eyes if phase == 1 else 3.0


func _on_part_hurt(amount: int, _part: EnemyBase) -> void:
	hp -= amount
	_lock_arena()


func _on_part_defeated(_part: EnemyBase) -> void:
	dead_eyes += 1
	for i in range(_shot_left.size()):
		_shot_left[i] = minf(_shot_left[i], spore_interval())
	_seed_left = minf(_seed_left, seed_interval())
	if dead_eyes == 3:
		_start_phase(2)


func _resolve_damage(hitbox: Hitbox, amount: int) -> int:
	if phase != 2:
		return 0
	return 2 if hitbox.kind == &"fire" else amount


func reset_fight() -> void:
	super()
	if is_dead:
		return
	eyes.clear()
	_pending.clear()
	seeds.clear()
	snappers.clear()
	dead_eyes = 0
	global_position = arena_point(CANOPY)
	if visual != null and visual.has_method(&"set_kind"):
		visual.call(&"set_kind", &"briar_canopy")
	_make_eyes()


func _on_death() -> void:
	super()
	# The cave WP places the persistent fragment and core with requires_flag. Do not duplicate them.
	spawn_pickup(&"ember", ARENA_CENTRE, true)
	spawn_pickup(&"ember", ARENA_CENTRE + Vector2(192, 0), true)


func _marker(at: Vector2, duration: float, band: bool = false) -> Node2D:
	var scene := load(MARKER_SCENE) as PackedScene
	if scene == null:
		return null
	var marker := scene.instantiate() as Node2D
	if marker == null:
		return null
	marker.z_index = 1
	marker.set(&"duration", duration)
	marker.set(&"shape", &"rect" if band else &"circle")
	marker.set(&"size", Vector2(1920, 96))
	marker.set(&"radius", BURST_RADIUS if duration == SEED_WARNING else 26.0)
	get_parent().add_child(marker)
	marker.global_position = at
	marker.call(&"start")
	add_hazard(marker)
	return marker


func _warn_spore(eye: EnemyBase) -> void:
	var marker := _marker(eye.global_position, SPORE_WARNING)
	_pending.append({"kind": &"spore", "left": SPORE_WARNING, "eye": eye, "marker": marker})


func warn_seed() -> void:
	var at := player_position(arena_point(ARENA_CENTRE))
	at += Vector2.from_angle(randf() * TAU) * randf_range(0.0, 192.0)
	var origin := arena_point(Vector2.ZERO)
	at = at.clamp(origin + Vector2(124, 124), origin + Vector2(1796, 836))
	_marker(at, SEED_WARNING)
	_pending.append({"kind": &"seed", "left": SEED_WARNING, "at": at})


func _warn_sweep() -> void:
	# Three tile-wide bands, with a full safe tile row between each adjacent pair.
	for row in SWEEP_ROWS:
		_marker(arena_point(Vector2(960, row)), SWEEP_WARNING, true)
	_pending.append({"kind": &"sweep", "left": SWEEP_WARNING})


func _tick_pending(delta: float) -> void:
	for i in range(_pending.size() - 1, -1, -1):
		_pending[i]["left"] -= delta
		var entry := _pending[i]
		if entry["kind"] == &"spore":
			var eye: EnemyBase = entry["eye"]
			if is_instance_valid(eye) and is_instance_valid(entry["marker"]):
				entry["marker"].global_position = eye.global_position
		if entry["left"] > 0.0:
			continue
		_pending.remove_at(i)
		match entry["kind"]:
			&"spore":
				var eye: EnemyBase = entry["eye"]
				if is_instance_valid(eye) and not eye.is_dead and eye.visible:
					var aim := player_position(eye.global_position + Vector2.DOWN)
					fire_projectile(
						null,
						(aim - eye.global_position).normalized(),
						300.0,
						2,
						eye.global_position
					)
			&"seed":
				plant_seed(entry["at"])
			&"sweep":
				for row in SWEEP_ROWS:
					_area(arena_point(Vector2(960, row)), true)


func plant_seed(at: Vector2) -> EnemyBase:
	var seed := Seed.new()
	seed.mother = self
	seeds.append(seed)
	adopt(seed, at)
	add_hazard(seed)
	return seed


func burst_seed(at: Vector2) -> void:
	_area(at, false)
	var alive := 0
	for snapper in snappers:
		if is_instance_valid(snapper) and not snapper.is_dead:
			alive += 1
	if alive >= 3:
		return
	var scene := load(SNAPPER_SCENE) as PackedScene
	if scene == null:
		return
	var snapper := scene.instantiate() as EnemyBase
	if snapper == null:
		return
	snapper.drops_enabled = false
	adopt(snapper, at)
	snappers.append(snapper)
	add_hazard(snapper)


func _area(at: Vector2, band: bool) -> void:
	var area := ThornArea.new()
	area.band = band
	get_parent().add_child(area)
	area.global_position = at
	add_hazard(area)


static func _register_briar_kinds() -> void:
	var definitions := {
		&"briar_canopy":
		{"shape": "rect", "size": Vector2(384, 144), "color": Color(0.24, 0.38, 0.18)},
		&"briar_bloom": {"shape": "circle", "radius": 80.0, "color": Color(0.78, 0.28, 0.4)},
		&"briar_eye": {"shape": "circle", "radius": 26.0, "color": Color(0.9, 0.22, 0.16)},
		&"briar_seed": {"shape": "diamond", "radius": 28.0, "color": Color(0.6, 0.72, 0.22)},
		&"briar_band":
		{"shape": "rect", "size": Vector2(1920, 96), "color": Color(0.7, 0.3, 0.24, 0.55)},
		&"briar_burst": {"shape": "circle", "radius": 120.0, "color": Color(0.7, 0.3, 0.24, 0.55)},
	}
	for kind in definitions:
		if not Placeholder.has_kind(kind):
			Placeholder.register_kind(kind, definitions[kind])
