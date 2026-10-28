extends "res://scripts/enemies/boss_base.gd"
## Tidewick's head and submerged followers travel by arc length, not angular speed.
## The tail alone accepts raft hook/flare damage. Cave rooms own persistent rewards.

const CENTRE := Vector2(1152, 480)
const RADII := Vector2(480, 264)
const BASIN := Rect2(288, 96, 1536, 768)
const SEGMENTS := 7
const SPACING := 120.0
const PATH_STEPS := 720
const TAIL_RADIUS := 30.0

var tail: Hurtbox
var tail_light: PointLight2D
var ripple_light: PointLight2D
var tail_visual: Node2D
var ripple: Node2D
var followers: Array[Node2D] = []
var travel_speed := 200.0
var travel_direction := 1.0
var tail_clock := 0.0
var bolt_clock := 0.0
var wave_clock := 0.0
var reversal_left := 0.0
var wave: Hitbox
var wave_warning: Node2D
var wave_direction := Vector2.ZERO
var wave_age := 0.0
var leeches: Array[EnemyBase] = []
var rng := RandomNumberGenerator.new()
var _points := PackedVector2Array()
var _lengths := PackedFloat32Array()
var _distance := 0.0
var _trail: Array[Vector2] = []
var _assembly: Node2D
var _paint: Node2D
var _body_visuals: Array[Node2D] = []
var _bolt_warning: Node2D
var _leech_pending := false


class UndertowVisual:
	extends Node2D
	var size := Vector2.ZERO

	func _draw() -> void:
		# The outline marks the full damaging band between the painted ripples.
		draw_rect(Rect2(-size * 0.5, size), Color(0.12, 0.55, 0.72, 0.25))
		draw_rect(Rect2(-size * 0.5, size), Color(0.46, 0.83, 0.95, 0.85), false, 3.0)


func _init() -> void:
	super()
	boss_id = &"tidewick"
	arena_id = &"cave_3_9"
	max_hp = 24
	thresholds = [10]
	contact_damage = 2
	body_radius = 36.0
	ignore_water = true
	drops_enabled = false
	visual_kind = &"tidewick_head"
	for spec in [
		[&"tidewick_head", Color(0.32, 0.16, 0.08), 36.0],
		[&"tidewick_body", Color(0.12, 0.24, 0.27, 0.5), 28.0],
		[&"tidewick_tail", Color(1.0, 0.65, 0.16), TAIL_RADIUS],
		[&"tidewick_ripple", Color(0.5, 0.85, 1.0, 0.65), 42.0],
	]:
		Placeholder.register_kind(spec[0], {"shape": "circle", "color": spec[1], "radius": spec[2]})
	Placeholder.register_kind(
		&"tidewick_wave",
		{"shape": "rect", "color": Color(0.4, 0.75, 0.9, 0.5), "size": Vector2(144, 768)}
	)


func _boss_ready() -> void:
	# Room snapshots duplicate generated children as well as the authored boss.
	# Retire the entire obsolete assembly, including its copied tail hurtbox.
	for child in get_children():
		if child.has_meta(&"tidewick_generated") or child.name == &"Serpent":
			remove_child(child)
			child.free()
	followers.clear()
	_body_visuals.clear()
	y_sort_enabled = true
	collision_mask = 0
	hurtbox.filter = func(_hit: Hitbox) -> bool: return false
	contact_hitbox.knockback = 0.0
	rng.randomize()
	if visual is SpriteVisual:
		visual.auto_motion = false
	_build_path()
	_assembly = Node2D.new()
	_assembly.name = "Serpent"
	_assembly.top_level = true
	_assembly.set_meta(&"tidewick_generated", true)
	add_child(_assembly)
	# Paint in the boss's ordinary y-sort chain. The top-level physics assembly
	# stays at its canonical world anchors, without adding its global Y twice to sorting.
	_paint = Node2D.new()
	_paint.name = "SerpentPaint"
	_paint.y_sort_enabled = true
	_paint.set_meta(&"tidewick_generated", true)
	add_child(_paint)
	for i in range(SEGMENTS):
		var segment := Node2D.new()
		segment.name = "Segment%d" % (i + 1)
		_assembly.add_child(segment)
		var look := SpriteVisual.attach(segment, &"tidewick_body")
		look.set_meta(&"tidewick_body_visual", true)
		look.reparent(_paint)
		_body_visuals.append(look)
		followers.append(segment)
	tail = Hurtbox.new()
	tail.name = "Tail"
	tail.add_circle(TAIL_RADIUS)
	tail.filter = _tail_accepts
	tail.hurt.connect(_tail_hit)
	_assembly.add_child(tail)
	tail_visual = SpriteVisual.attach(tail, &"tidewick_tail")
	tail_visual.reparent(_paint)
	tail_light = _light(tail, Color(1.0, 0.6, 0.2), 160.0)
	ripple = Node2D.new()
	ripple.z_index = 1
	_assembly.add_child(ripple)
	if SpriteVisual.has_art(&"tidewick_tail"):
		var ripple_visual := SpriteVisual.attach(ripple, &"tidewick_tail") as SpriteVisual
		ripple_visual.auto_motion = false
		ripple_visual.play_anim(&"idle")
	else:
		Placeholder.attach(ripple, &"tidewick_ripple")
	ripple_light = _light(ripple, Color(0.4, 0.7, 1.0), 130.0)
	reset_fight()


func _process(_delta: float) -> void:
	var head := visual as SpriteVisual
	if head != null:
		var spitting := bolt_clock >= 2.5
		var down := not spitting and velocity.y > absf(velocity.x)
		head.set_facing(Vector2.DOWN if down else Vector2(signf(velocity.x), 0))
		head.play_anim(&"spit_side" if spitting else (&"walk_down" if down else &"walk_side"))
	for i in range(followers.size()):
		var look := _body_visuals[i]
		look.global_position = followers[i].global_position
		var body := look as SpriteVisual
		if body != null:
			body.play_anim(&"reverse" if travel_direction < 0.0 else &"idle")
	if is_instance_valid(tail_visual) and is_instance_valid(tail):
		tail_visual.global_position = tail.global_position
	var painted_tail := tail_visual as SpriteVisual
	if painted_tail != null:
		painted_tail.play_anim(&"exposed" if tail_exposed() else &"idle")


func _build_path() -> void:
	_points.clear()
	_lengths.clear()
	var total := 0.0
	for i in range(PATH_STEPS + 1):
		var angle := TAU * i / PATH_STEPS
		var point := CENTRE + RADII * Vector2(cos(angle), sin(angle))
		if i > 0:
			total += point.distance_to(_points[-1])
		_points.append(point)
		_lengths.append(total)


func path_point(distance: float) -> Vector2:
	var wrapped := fposmod(distance, _lengths[-1])
	var index := clampi(_lengths.bsearch(wrapped), 1, PATH_STEPS)
	var weight := (wrapped - _lengths[index - 1]) / (_lengths[index] - _lengths[index - 1])
	return _points[index - 1].lerp(_points[index], weight)


func reset_fight() -> void:
	super()
	if is_dead or tail == null:
		return
	_clear_leeches()
	_distance = 0.0
	travel_direction = 1.0
	travel_speed = 200.0
	_trail.clear()
	for i in range(240, -1, -1):
		_trail.append(path_point(-i * 4.0))
	global_position = arena_point(path_point(_distance))
	_reset_clocks()
	_update_followers()
	_set_tail(false, false)
	contact_hitbox.damage = 2


func _reset_clocks() -> void:
	tail_clock = 0.0
	bolt_clock = 0.0
	wave_clock = 0.0
	wave_age = 0.0
	wave = null
	wave_warning = null
	_bolt_warning = null


func _enter_phase(number: int) -> void:
	_reset_clocks()
	_set_tail(false, false)
	travel_speed = 200.0 if number == 1 else 260.0
	reversal_left = rng.randf_range(8.0, 12.0)
	_leech_pending = number == 2


func _boss_physics(delta: float) -> void:
	if _leech_pending:
		_leech_pending = false
		_spawn_leeches()
	if phase == 2:
		reversal_left -= delta
		if reversal_left <= 0.0:
			travel_direction *= -1.0
			reversal_left = rng.randf_range(8.0, 12.0)
	_distance += travel_direction * travel_speed * delta
	var next := path_point(_distance)
	velocity = (arena_point(next) - global_position) / delta
	_trail.append(next)
	if _trail.size() > 500:
		_trail.pop_front()
	_update_followers()
	_tick_tail(delta)
	_tick_bolt(delta)
	if phase == 2:
		_tick_wave(delta)


func _trail_point(distance: float) -> Vector2:
	for i in range(_trail.size() - 1, 0, -1):
		var length := _trail[i].distance_to(_trail[i - 1])
		if distance <= length and length > 0.0:
			return _trail[i].lerp(_trail[i - 1], distance / length)
		distance -= length
	return _trail[0]


func _update_followers() -> void:
	for i in range(followers.size()):
		followers[i].global_position = arena_point(_trail_point((i + 1) * SPACING))
	tail.global_position = followers[-1].global_position
	for i in range(followers.size()):
		_body_visuals[i].global_position = followers[i].global_position
	tail_visual.global_position = tail.global_position


func _tick_tail(delta: float) -> void:
	var period := 5.0 if phase == 1 else 4.0
	var duration := 2.0 if phase == 1 else 1.6
	tail_clock = fposmod(tail_clock + delta, period)
	var warning := tail_clock >= period - 0.8
	_set_tail(tail_clock < duration, warning)
	if warning:
		var ahead := (period - tail_clock) * travel_speed
		ripple.global_position = arena_point(_trail_point(maxf(0.0, SEGMENTS * SPACING - ahead)))


func _set_tail(exposed: bool, warning: bool) -> void:
	tail.enabled = exposed and not is_dying() and not is_in_intro() and not is_pausing()
	tail_visual.visible = tail.enabled
	tail_light.enabled = tail.enabled
	ripple_light.enabled = warning and not is_dying()
	ripple.visible = warning and not is_dying()


func tail_exposed() -> bool:
	return tail != null and tail.enabled


func _tail_accepts(hit: Hitbox) -> bool:
	if not can_be_hurt() or is_dying() or not tail_exposed():
		return false
	if hit.kind not in [&"hook", &"flare"] or hit.team != Layers.Team.PLAYER:
		return false
	var hero := get_player() as Player
	return hero != null and hero.is_on_raft() and hit.source == hero


func _tail_hit(hit: Hitbox) -> void:
	if _tail_accepts(hit):
		apply_damage(hit.damage_for(tail), hit.origin(), 0.0)


func _resolve_damage(_hit: Hitbox, _amount: int) -> int:
	return 0


func _tick_bolt(delta: float) -> void:
	bolt_clock += delta
	if bolt_clock >= 2.5 and not is_instance_valid(_bolt_warning):
		_bolt_warning = Node2D.new()
		_bolt_warning.z_index = 1
		add_child(_bolt_warning)
		if SpriteVisual.has_art(&"tidewick_bolt_tell"):
			SpriteVisual.attach(_bolt_warning, &"tidewick_bolt_tell")
			_light(_bolt_warning, Color(1.0, 0.55, 0.22), 140.0)
		else:
			Placeholder.attach(_bolt_warning, &"tidewick_ripple")
		add_hazard(_bolt_warning)
	if is_instance_valid(_bolt_warning):
		_bolt_warning.position.x = signf(velocity.x) * 55.0
	if bolt_clock >= 3.0:
		bolt_clock -= 3.0
		if is_instance_valid(_bolt_warning):
			_bolt_warning.queue_free()
		var bolt := fire_projectile(null, direction_to_player(), 320.0, 2)
		# The generic projectile has already built its fallback; replace only its look.
		if SpriteVisual.has_art(&"tidewick_ember_bolt"):
			var look := SpriteVisual.attach(bolt, &"tidewick_ember_bolt", bolt.radius)
			look.rotation = bolt.direction.angle()
			_light(bolt, Color(1.0, 0.55, 0.22), 100.0)
		bolt.hitbox.knockback = 0.0


func _tick_wave(delta: float) -> void:
	wave_clock += delta
	if wave_clock >= 6.0 and not is_instance_valid(wave_warning) and not is_instance_valid(wave):
		wave_direction = Vector2.RIGHT if rng.randi_range(0, 1) == 0 else Vector2.DOWN
		wave_warning = Node2D.new()
		wave_warning.z_index = 1
		get_parent().add_child(wave_warning)
		wave_warning.global_position = arena_point(BASIN.get_center())
		var dimensions := (
			Vector2(144, BASIN.size.y)
			if wave_direction == Vector2.RIGHT
			else Vector2(BASIN.size.x, 144)
		)
		_attach_wave_visual(wave_warning, dimensions)
		add_hazard(wave_warning)
	if wave_clock >= 7.0:
		wave_clock -= 7.0
		_start_wave()
	if is_instance_valid(wave):
		wave_age += delta
		wave.global_position += wave_direction * 300.0 * delta
		_push_wave_rider(delta)
		if (
			wave_age
			> (BASIN.size.x if wave_direction == Vector2.RIGHT else BASIN.size.y) / 300.0 + 0.5
		):
			wave.queue_free()


func _start_wave() -> void:
	if is_instance_valid(wave_warning):
		wave_warning.queue_free()
	wave = Hitbox.new()
	wave.team = Layers.Team.ENEMY
	wave.damage = 3
	wave.blockable = false
	wave.knockback = 0.0
	wave.once_per_target = false
	wave.kind = &"undertow"
	var rect := RectangleShape2D.new()
	rect.size = (
		Vector2(144, BASIN.size.y)
		if wave_direction == Vector2.RIGHT
		else Vector2(BASIN.size.x, 144)
	)
	var shape := CollisionShape2D.new()
	shape.shape = rect
	wave.add_child(shape)
	get_parent().add_child(wave)
	wave.global_position = arena_point(
		(
			Vector2(BASIN.position.x + 72, 480)
			if wave_direction == Vector2.RIGHT
			else Vector2(1056, BASIN.position.y + 72)
		)
	)
	wave.source = wave
	# The band carries riders downstream even when they straddle its centre.
	wave.knockback_direction = wave_direction
	wave.active = true
	_attach_wave_visual(wave, rect.size)
	add_hazard(wave)
	wave_age = 0.0


func _attach_wave_visual(parent: Node2D, size: Vector2) -> void:
	if not SpriteVisual.has_art(&"tidewick_wave_ripple"):
		Placeholder.attach(parent, &"tidewick_wave", 0.0, size)
		return
	var visual := UndertowVisual.new()
	visual.name = "Visual"
	visual.size = size
	parent.add_child(visual)
	var vertical := size.y > size.x
	var length := size.y if vertical else size.x
	var count := int(length / 128.0)
	for i in range(count):
		var holder := Node2D.new()
		var offset := -length * 0.5 + (i + 0.5) * 128.0
		holder.position = Vector2(0, offset) if vertical else Vector2(offset, 0)
		visual.add_child(holder)
		SpriteVisual.attach(holder, &"tidewick_wave_ripple")
		var light := _light(holder, Color(0.55, 0.8, 1.0), 160.0)
		light.energy = 0.7


func _push_wave_rider(delta: float) -> void:
	var hero := get_player() as Player
	if hero == null or not hero.is_on_raft():
		return
	var shape := wave.get_child(0) as CollisionShape2D
	var rect := shape.shape as RectangleShape2D
	if Rect2(wave.global_position - rect.size * 0.5, rect.size).has_point(hero.global_position):
		hero.push_raft(wave_direction * 200.0 * delta)


func _spawn_leeches() -> void:
	var packed := load("res://scenes/enemies/fen_leech.tscn") as PackedScene
	if packed == null:
		return
	for point in [Vector2(816, 336), Vector2(1488, 624)]:
		var leech := packed.instantiate() as EnemyBase
		if leech != null:
			leech.drops_enabled = false
			adopt_deferred(leech, arena_point(point))
			leeches.append(leech)


func _clear_leeches() -> void:
	for leech in leeches:
		if is_instance_valid(leech):
			leech.queue_free()
	leeches.clear()


func _on_hurt(hit: Hitbox) -> void:
	super(hit)
	if is_dying():
		contact_hitbox.damage = 0
		set_contact_enabled(false)
		_set_tail(false, false)
		_clear_leeches()


func _on_death() -> void:
	super()
	_clear_leeches()


func _light(parent: Node2D, color: Color, radius: float) -> PointLight2D:
	var light := PointLight2D.new()
	light.texture = LightTexture.make()
	light.texture_scale = LightTexture.scale_for(radius)
	light.color = color
	parent.add_child(light)
	return light
