extends "res://scripts/enemies/boss_base.gd"
## Free reel pulls remove armour. Persistent rewards belong to the cave room.

const HEAPS := [Vector2(288, 288), Vector2(288, 672), Vector2(1056, 480), Vector2(1536, 672)]
const OFFSETS := [Vector2(0, -58), Vector2(-58, 0), Vector2(58, 0), Vector2(0, -108)]

var plates: Array[Node2D] = []
var state := &"burrow"
var state_left := 0.0
var regrow_left := 4.0
var volley_left := 2.5
var bite_left := 0.0
var bare := false
var rear_age := 0.0
var _home := Vector2.ZERO


class Strike:
	extends Node2D
	var box: Hitbox
	var life := 0.12

	func _ready() -> void:
		Placeholder.attach(self, &"coinwyrm_strike", 10)
		add_child(box)
		box.activate()

	func _physics_process(delta: float) -> void:
		life -= delta
		if life <= 0:
			queue_free()


func _init() -> void:
	boss_id = &"coinwyrm"
	arena_id = &"cave_8_12"
	drops_enabled = false
	stun_scale = 0.0
	knockback_scale = 0.0
	max_hp = 36
	body_radius = 70
	contact_damage = 3
	thresholds = [20]
	arena_lock = false
	death_drops = []
	visual_kind = &"coinwyrm"
	if not Placeholder.has_kind(visual_kind):
		Placeholder.register_kind(
			visual_kind, {"shape": "circle", "color": Color(0.62, 0.39, 0.12), "radius": 70}
		)
	if not Placeholder.has_kind(&"coinwyrm_strike"):
		Placeholder.register_kind(
			&"coinwyrm_strike",
			{"shape": "circle", "color": Color(1, 0.65, 0.1, 0.4), "radius": 10},
			true
		)


func _boss_ready() -> void:
	_home = global_position


func _enter_phase(_number: int) -> void:
	_clear_plates()
	_begin_burrow(0.0)


func _resolve_damage(hit: Hitbox, amount: int) -> int:
	if state != &"rear" or not plates.is_empty():
		return 0
	return amount if hit.kind in [&"hook", &"flare", &"explosion", &"sling"] else 0


func _boss_physics(delta: float) -> void:
	if state == &"burrow":
		state_left -= delta
		if state_left <= 0:
			_choose_heap()
			state = &"quiver"
			state_left = 0.9
			_marker(global_position, &"circle", 0.9, 90, Vector2.ZERO, Vector2.RIGHT)
		return
	if state == &"quiver":
		state_left -= delta
		if state_left <= 0:
			_rear()
		return
	rear_age += delta
	state_left -= delta
	bite_left -= delta
	if bite_left <= 0:
		bite_left = INF
		_bite()
	if not bare:
		regrow_left -= delta
		if regrow_left <= 0:
			regrow_left += 4.0
			_grow_plate()
		volley_left -= delta
		if volley_left <= 0:
			volley_left += 2.5
			_volley()
	if state_left <= 0:
		_begin_burrow(maxf(0.0, 8.0 - rear_age - 0.9) if phase == 2 else 0.0)


func _choose_heap() -> void:
	var nearest := INF
	var target := player_position(arena_point(ARENA_CENTRE))
	for heap in HEAPS:
		var at := arena_point(heap)
		var distance := at.distance_to(target)
		if distance >= 288 and distance < nearest:
			nearest = distance
			global_position = at


func _rear() -> void:
	state = &"rear"
	state_left = 6.0 if phase == 1 else 5.0
	rear_age = 0
	regrow_left = 4
	volley_left = 2.5
	bite_left = 0.0
	bare = false
	visible = true
	hurtbox.enabled = true
	set_contact_enabled(true)
	for i in range(3 if phase == 1 else 4):
		_grow_plate()
	if phase == 2:
		_tail()


func _grow_plate() -> void:
	var limit := 3 if phase == 1 else 4
	if plates.size() >= limit:
		return
	var scene := load("res://scenes/enemies/bosses/coin_plate.tscn") as PackedScene
	if scene == null:
		return
	var used: Array[int] = []
	for plate in plates:
		used.append(plate.get_meta("slot"))
	for slot in range(limit):
		if slot in used:
			continue
		var plate := scene.instantiate() as Node2D
		plate.set_meta("slot", slot)
		plate.reeled.connect(_plate_pulled.bind(plate))
		add_child(plate)
		plate.position = OFFSETS[slot]
		plates.append(plate)
		return


func _plate_pulled(_hit: Hitbox, plate: Node2D) -> void:
	if state != &"rear" or not plates.has(plate) or is_dying() or is_pausing():
		return
	plates.erase(plate)
	plate.queue_free()
	_lock_arena()
	var at := player_position(global_position)
	for i in range(5):
		PickupBase.spawn(&"brass_bit", get_parent(), at + Vector2(i * 3 - 6, 0), true)
	if plates.is_empty():
		bare = true
		state_left += 2.0


func _begin_burrow(delay: float) -> void:
	_clear_plates()
	state = &"burrow"
	state_left = delay
	bare = false
	visible = false
	hurtbox.enabled = false
	set_contact_enabled(false)


func _clear_plates() -> void:
	for plate in plates:
		if is_instance_valid(plate):
			plate.queue_free()
	plates.clear()


func _volley() -> void:
	var count := 5 if phase == 1 else 8
	var direction := direction_to_player()
	for i in range(count):
		var angle := deg_to_rad(-30 + i * 15) if phase == 1 else TAU * i / 8.0
		var bolt := EnemyProjectile.new()
		bolt.speed = 280 if phase == 1 else 260
		bolt.damage = 2
		bolt.visual_kind = &"brass_bit"
		bolt.blockable_by_ward = true
		get_parent().add_child(bolt)
		bolt.launch(global_position, direction.rotated(angle))
		add_hazard(bolt)


func _marker(
	at: Vector2,
	shape: StringName,
	duration: float,
	radius: float,
	size: Vector2,
	direction: Vector2
) -> Node2D:
	var script := load("res://scripts/enemies/telegraph.gd") as GDScript
	if script == null:
		return null
	var marker = script.new()
	marker.shape = shape
	marker.duration = duration
	marker.radius = radius
	marker.size = size
	marker.arc_deg = 180
	marker.facing = direction
	get_parent().add_child(marker)
	marker.global_position = at
	add_hazard(marker)
	marker.start()
	return marker


func _bite() -> void:
	var direction := direction_to_player()
	var at := global_position
	var marker := _marker(at, &"cone", 0.5, 150, Vector2.ZERO, direction)
	if marker != null:
		marker.finished.connect(_strike.bind(at, direction, false))


func _tail() -> void:
	for heap in HEAPS:
		var at := arena_point(heap)
		if at.distance_to(global_position) < 10:
			continue
		at.x = arena_point(ARENA_CENTRE).x
		var marker := _marker(at, &"rect", 0.7, 0, Vector2(1728, 96), Vector2.RIGHT)
		if marker != null:
			marker.finished.connect(_strike.bind(at, Vector2.RIGHT, true))
		return


func _strike(at: Vector2, direction: Vector2, tail: bool) -> void:
	if is_dying() or is_dead or is_pausing() or state != &"rear":
		return
	var strike := Strike.new()
	var box := Hitbox.new()
	box.team = Layers.Team.ENEMY
	box.damage = 3 if tail else 4
	box.blockable = false
	box.source = strike
	if tail:
		var shape := RectangleShape2D.new()
		shape.size = Vector2(1728, 96)
		var collision := CollisionShape2D.new()
		collision.shape = shape
		box.add_child(collision)
	else:
		var polygon := CollisionPolygon2D.new()
		var points := PackedVector2Array([Vector2.ZERO])
		for i in range(25):
			points.append(direction.rotated(-PI / 2 + PI * i / 24.0) * 150)
		polygon.polygon = points
		box.add_child(polygon)
	strike.box = box
	get_parent().add_child(strike)
	strike.global_position = at
	add_hazard(strike)


func _on_hurt(hit: Hitbox) -> void:
	super._on_hurt(hit)
	if is_dying():
		_clear_plates()
		set_contact_enabled(false)


func reset_fight() -> void:
	if is_dead or is_defeated():
		return
	_clear_plates()
	global_position = _home
	visible = true
	state = &"burrow"
	super.reset_fight()


func _on_death() -> void:
	super._on_death()
	spawn_pickup(&"ember", ARENA_CENTRE, true)
	spawn_pickup(&"ember", ARENA_CENTRE + Vector2(192, 0), true)
