extends "res://scripts/enemies/boss_base.gd"
## Stationary two-tool lock. Persistent fragment and core are placed by C09.

const GENERATED_HELPER := &"lock_warden_generated_helper"
const OFFSETS := [Vector2(-128, -96), Vector2(128, -96), Vector2(-128, 96), Vector2(128, 96)]
var plates: Array[Node2D] = []
var volley_left := 3.5
var bolt_left := 8.0
var turn_left := 5.0
var open_left := 0.0


class Plate:
	extends Node2D
	var hp := 4
	var lid_left := 0.0
	var active := false
	var owner_boss: Node2D
	var plate_box: Hurtbox
	var eye: Hurtbox
	var _painted_plate: SpriteVisual

	func _ready() -> void:
		plate_box = get_node("Model/PlateHurtbox") as Hurtbox
		plate_box.filter = _plate_accepts
		plate_box.hurt.connect(_plate_hit)
		eye = get_node("Model/LidEye") as Hurtbox
		eye.filter = _eye_accepts
		_painted_plate = SpriteVisual.attach(self, &"lock_plate", 34) as SpriteVisual
		_refresh_plate_visual()

	func _uses_painted_eye() -> bool:
		if not is_instance_valid(_painted_plate) or _painted_plate.sprite_frames == null:
			return false
		for state in [&"closed", &"open"]:
			var frames := _painted_plate.sprite_frames
			if not frames.has_animation(state) or frames.get_frame_count(state) == 0:
				return false
			if frames.get_frame_texture(state, 0) == null:
				return false
		return true

	func _refresh_plate_visual() -> void:
		if not _uses_painted_eye():
			return
		_painted_plate.auto_motion = false
		# One offset for every frame aligns the painted lid with the existing eye target.
		_painted_plate.position = Vector2(16, -30)
		_painted_plate.play_anim(&"open" if lid_left > 0 else &"closed")

	func _eye_accepts(hit: Hitbox) -> bool:
		if active and hit.kind == &"sling":
			lid_left = 6.0
			owner_boss._lock_arena()
			return true
		return false

	func _plate_accepts(hit: Hitbox) -> bool:
		return active and lid_left > 0 and hit.kind in [&"explosion", &"thrown"]

	func _plate_hit(hit: Hitbox) -> void:
		if not active or lid_left <= 0:
			return
		var damage := 4 if hit.kind == &"explosion" else 3 if hit.kind == &"thrown" else 0
		if damage == 0:
			return
		hp -= damage
		owner_boss._lock_arena()
		if hp <= 0:
			active = false
			owner_boss.plate_broken(self)

	func _physics_process(delta: float) -> void:
		lid_left = maxf(0, lid_left - delta)
		_refresh_plate_visual()
		queue_redraw()

	func _draw() -> void:
		if _uses_painted_eye():
			return
		draw_circle(
			Vector2(0, -48), 22, Color(1, 0.8, 0.2) if lid_left > 0 else Color(0.25, 0.17, 0.07)
		)


class KeyholeVisual:
	extends Node2D

	func _physics_process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		var boss = get_parent()
		if SpriteVisual.has_art(&"lock_warden"):
			if boss.open_left > 0:
				draw_circle(Vector2(0, -5), 7, Color(1, 0.8, 0.25))
				draw_colored_polygon(
					PackedVector2Array(
						[Vector2(-4, -2), Vector2(4, -2), Vector2(7, 13), Vector2(-7, 13)]
					),
					Color(1, 0.8, 0.25)
				)
			return
		draw_circle(
			Vector2.ZERO, 28, Color(1, 0.85, 0.3) if boss.open_left > 0 else Color(0.08, 0.06, 0.03)
		)


class Deadbolt:
	extends Node2D
	const SEGMENTS := [Vector2(96, 384), Vector2(576, 864)]
	var speed := 300.0

	func _ready() -> void:
		var visual := Node2D.new()
		visual.name = "Visual"
		add_child(visual)
		for segment in SEGMENTS:
			if SpriteVisual.has_art(&"lock_deadbolt"):
				var holder := Node2D.new()
				holder.position.y = (segment.x + segment.y) / 2
				visual.add_child(holder)
				var painted := SpriteVisual.attach(holder, &"lock_deadbolt")
				painted.scale.x = 32.0 / 23.0
			var box := Hitbox.new()
			box.team = Layers.Team.ENEMY
			box.damage = 4
			box.blockable = false
			box.source = self
			var shape := RectangleShape2D.new()
			shape.size = Vector2(32, segment.y - segment.x)
			var collision := CollisionShape2D.new()
			collision.shape = shape
			box.add_child(collision)
			box.position.y = (segment.x + segment.y) / 2
			add_child(box)
			box.activate()

	func _physics_process(delta: float) -> void:
		position.x += speed * delta
		if position.x > 1824:
			queue_free()
		queue_redraw()

	func _draw() -> void:
		if SpriteVisual.has_art(&"lock_deadbolt"):
			return
		draw_rect(Rect2(-16, 96, 32, 288), Color(0.9, 0.55, 0.15))
		draw_rect(Rect2(-16, 576, 32, 288), Color(0.9, 0.55, 0.15))


func _init() -> void:
	super._init()
	boss_id = &"lock_warden"
	arena_id = &"cave_9_10"
	max_hp = 40
	contact_damage = 2
	body_radius = 120
	thresholds = [24]  # Four plates account for 16 HP; the keyhole retains 24.
	resupply = true
	arena_lock = false
	death_drops = []
	visual_kind = &"lock_warden"
	for kind in [&"lock_warden", &"lock_plate"]:
		if not Placeholder.has_kind(kind):
			Placeholder.register_kind(
				kind,
				{
					"shape": "rect",
					"color":
					Color(0.65, 0.44, 0.14) if kind == &"lock_warden" else Color(0.4, 0.25, 0.08),
					"size": Vector2(288, 240) if kind == &"lock_warden" else Vector2(60, 60)
				}
			)
	if not Placeholder.has_kind(&"lock_key_volley"):
		Placeholder.register_kind(
			&"lock_key_volley", {"shape": "circle", "color": Color(0.8, 0.65, 0.25), "radius": 12.0}
		)


func _ready() -> void:
	# Room snapshots already-ready actors. Retire copied runtime helpers before the
	# base can rebuild an active boss or retire a persistently defeated one.
	_remove_generated_helpers(self)
	super._ready()


func _remove_generated_helpers(parent: Node) -> void:
	for child in parent.get_children():
		if child.has_meta(GENERATED_HELPER):
			parent.remove_child(child)
			child.free()
		else:
			_remove_generated_helpers(child)


func _boss_ready() -> void:
	var core := hurtbox.add_circle(28)
	core.set_meta(GENERATED_HELPER, true)
	hurtbox.filter = _core_accepts
	contact_hitbox.setup(Layers.Team.ENEMY)
	var lens := KeyholeVisual.new()
	lens.name = "KeyholeVisual"
	lens.set_meta(GENERATED_HELPER, true)
	add_child(lens)


func _core_accepts(_hit: Hitbox) -> bool:
	return phase == 2 and open_left > 0


func _enter_phase(number: int) -> void:
	volley_left = 3.5 if number == 1 else 3.0
	bolt_left = 8.0 if number == 1 else 6.0
	turn_left = 5.0
	open_left = 0
	if number == 1:
		_create_plates()
	_spawn_wicklings()


func _create_plates() -> void:
	_clear_plates()
	var scene := load("res://scenes/enemies/bosses/lock_plate.tscn") as PackedScene
	if scene == null:
		return
	for offset in OFFSETS:
		var plate := Plate.new()
		plate.set_meta(GENERATED_HELPER, true)
		plate.owner_boss = self
		plate.active = true
		# The owned resource supplies the plate's scene structure.
		var model := scene.instantiate()
		model.name = "Model"
		plate.add_child(model)
		add_child(plate)
		plate.position = offset
		plates.append(plate)


func plate_broken(plate: Node2D) -> void:
	plates.erase(plate)
	hp -= 4
	var bundle := PickupBase.spawn(&"pitch_pot_bundle", get_parent(), plate.global_position, true)
	bundle.amount = 2
	plate.queue_free()
	if plates.is_empty():
		_start_phase(2)


func _resolve_damage(hit: Hitbox, _amount: int) -> int:
	if phase != 2 or open_left <= 0:
		return 0
	match hit.kind:
		&"hook":
			return 2
		&"flare", &"explosion":
			return 4
		&"sling":
			return 1
		_:
			return _amount


func _boss_physics(delta: float) -> void:
	volley_left -= delta
	bolt_left -= delta
	open_left = maxf(0, open_left - delta)
	if volley_left <= 0:
		volley_left += 3.5 if phase == 1 else 3.0
		_tell(global_position, Vector2(320, 32), 0.6, _volley)
	if bolt_left <= 0:
		bolt_left += 8.0 if phase == 1 else 6.0
		_tell(arena_point(Vector2(960, 480)), Vector2(1728, 192), 1.0, _deadbolt)
	if phase == 2:
		turn_left -= delta
		if turn_left <= 0:
			turn_left += 5.0
			_tell(global_position, Vector2(80, 80), 0.5, _open_core)
	queue_redraw()


func _tell(at: Vector2, size: Vector2, duration: float, callback: Callable) -> void:
	var script := load("res://scripts/enemies/telegraph.gd") as GDScript
	if script == null:
		return
	var marker = script.new()
	marker.shape = &"rect"
	marker.size = size
	marker.duration = duration
	get_parent().add_child(marker)
	marker.global_position = at
	marker.finished.connect(callback)
	add_hazard(marker)
	marker.start()


func _volley() -> void:
	if is_dying() or is_dead or is_pausing():
		return
	var count := 8 if phase == 1 else 12
	for i in range(count):
		var key := EnemyProjectile.new()
		key.speed = 260
		key.damage = 2
		key.blockable_by_ward = true
		key.visual_kind = &"lock_key_volley"
		get_parent().add_child(key)
		key.launch(global_position, Vector2.RIGHT.rotated(TAU * i / count))
		var visual := key.get_node_or_null("Visual") as Node2D
		if visual is SpriteVisual:
			# The painted key's tip points about 20 degrees clockwise from the x axis.
			visual.rotation = key.direction.angle() - deg_to_rad(20.0)
		key.destroyed.connect(_key_impact.bind(key))
		add_hazard(key)


func _key_impact(reason: StringName, key: EnemyProjectile) -> void:
	if reason not in [&"hit", &"wall", &"ward"] or not is_instance_valid(key):
		return
	var effect := SpriteVisual.spawn_effect(get_parent(), &"lock_key_volley", key.global_position)
	if effect is SpriteVisual:
		effect.rotation = key.direction.angle() - deg_to_rad(20.0)
		effect.play_anim(&"impact")


func _deadbolt() -> void:
	if is_dying() or is_dead or is_pausing():
		return
	var bar := Deadbolt.new()
	get_parent().add_child(bar)
	bar.global_position = arena_point(Vector2(96, 0))
	add_hazard(bar)


func _open_core() -> void:
	if not is_dying() and not is_dead and phase == 2:
		open_left = 3.0


func _spawn_wicklings() -> void:
	var scene := load("res://scenes/enemies/wickling.tscn") as PackedScene
	if scene == null:
		return
	for offset in [Vector2(-288, 0), Vector2(288, 0)]:
		var wick := scene.instantiate() as EnemyBase
		wick.drops_enabled = false
		adopt_deferred(wick, global_position + offset)
		add_hazard(wick)


func _clear_plates() -> void:
	for plate in plates:
		if is_instance_valid(plate):
			plate.queue_free()
	plates.clear()


func reset_fight() -> void:
	if is_dead or is_defeated():
		return
	_clear_plates()
	open_left = 0
	super.reset_fight()


func _on_hurt(hit: Hitbox) -> void:
	super._on_hurt(hit)
	if is_dying():
		set_contact_enabled(false)


func _on_death() -> void:
	_clear_plates()
	super._on_death()
	spawn_pickup(&"ember", ARENA_CENTRE, true)
	spawn_pickup(&"ember", ARENA_CENTRE + Vector2(192, 0), true)
