extends "res://scripts/enemies/boss_base.gd"
## The jar distinguishes the real scribe. Persistent rewards belong to the cave room.

const COMPASS := [Vector2(960, 192), Vector2(1248, 480), Vector2(960, 768), Vector2(672, 480)]
const LECTERNS := [
	Vector2(336, 336),
	Vector2(336, 624),
	Vector2(816, 528),
	Vector2(1104, 528),
	Vector2(1584, 336),
	Vector2(1584, 624)
]

var copies: Array[Node2D] = []
var copying := false
var shadow: Node2D
var rng := RandomNumberGenerator.new()
var _vanish := 0.0
var _copy_left := 0.0
var _recover := 0.0
var _bolt_left := 2.5
var _blink_left := 5.6
var _blink_warning := 0.0
var _ring_left := 6.0
var _volley_left := 0.75
var _volley_index := 0
var _pending: Array[Dictionary] = []
var _break_pending := false
var _home := Vector2.ZERO


class Copy:
	extends Node2D
	var boss: Node2D
	var box: Hurtbox
	var popped := false

	func _ready() -> void:
		# A duplicate carries generated children; replace its helper rather than
		# leave an extra hidden target behind the newly painted copy.
		for child in get_children():
			if child is Hurtbox:
				remove_child(child)
				child.free()
		SpriteVisual.attach(self, &"archivist_decoy", 48.0)
		box = Hurtbox.new()
		box.name = "Hurtbox"
		box.team = Layers.Team.ENEMY
		box.add_circle(48)
		box.hurt.connect(_hit)
		add_child(box)

	func _exit_tree() -> void:
		# The encounter registry must never retain a freed copy.
		if is_instance_valid(boss):
			boss.copies.erase(self)

	func _hit(hit: Hitbox) -> void:
		if popped or hit.damage_for(box) <= 0:
			return
		popped = true
		box.enabled = false
		if is_instance_valid(boss):
			boss.call_deferred("spatter", global_position)
		queue_free()


class Spatter:
	extends Node2D
	var ticks := 0
	var box: Hitbox

	func _ready() -> void:
		Placeholder.attach(self, &"archivist_spatter", 100.0)
		box = Hitbox.new()
		box.team = Layers.Team.ENEMY
		box.damage = 2
		box.blockable = false
		box.source = self
		box.add_circle(100)
		add_child(box)
		box.activate()

	func _physics_process(_delta: float) -> void:
		ticks += 1
		if ticks >= 3:
			box.deactivate()
			queue_free()


func _init() -> void:
	boss_id = &"archivist"
	arena_id = &"cave_5_10"
	drops_enabled = false
	stun_scale = 0.0
	knockback_scale = 0.0
	max_hp = 30
	body_radius = 48
	contact_damage = 2
	move_speed = 120
	thresholds = [20, 10]
	arena_lock = false
	death_drops = []
	visual_kind = &"archivist"
	if not Placeholder.has_kind(visual_kind):
		Placeholder.register_kind(
			visual_kind,
			{"shape": "rect", "color": Color(0.76, 0.73, 0.66), "size": Vector2(80, 96)}
		)
	if not Placeholder.has_kind(&"archivist_decoy"):
		Placeholder.register_kind(
			&"archivist_decoy",
			{"shape": "rect", "color": Color(0.76, 0.73, 0.66), "size": Vector2(80, 96)}
		)
	if not Placeholder.has_kind(&"archivist_spatter"):
		Placeholder.register_kind(
			&"archivist_spatter",
			{"shape": "circle", "color": Color(0.12, 0.08, 0.2, 0.6), "radius": 100.0},
			true
		)


func _enemy_ready() -> void:
	# Clean snapshots before BossBase can take its defeated/retired early return.
	# Only this actor's generated shadow is retired; authored arena props are untouched.
	for child in get_children():
		if child.has_meta(&"archivist_generated_shadow") or child.name == &"Shadow":
			remove_child(child)
			child.free()
	shadow = null
	super._enemy_ready()


func _boss_ready() -> void:
	if visual is SpriteVisual:
		visual.auto_motion = false
	_home = global_position
	rng.randomize()
	shadow = Node2D.new()
	shadow.name = "Shadow"
	shadow.set_meta(&"archivist_generated_shadow", true)
	add_child(shadow)
	var polygon := Polygon2D.new()
	polygon.color = Color(0.01, 0.01, 0.025, 0.9)
	var points := PackedVector2Array()
	for i in range(32):
		points.append(Vector2(cos(TAU * i / 32.0) * 56, sin(TAU * i / 32.0) * 18 + 48))
	polygon.polygon = points
	shadow.add_child(polygon)
	shadow.visible = false


func _process(_delta: float) -> void:
	var painted := visual as SpriteVisual
	if painted == null:
		return
	var pose := &"float" if velocity.length() > 5.0 else &"idle"
	if _vanish > 0.0:
		pose = &"copy"
	elif _recover > 0.0:
		pose = &"stunned"
		var frames := painted.sprite_frames
		if frames != null and frames.has_animation(&"page_break"):
			var duration := frames.get_frame_count(&"page_break") / frames.get_animation_speed(&"page_break")
			if _recover > 2.0 - duration:
				pose = &"page_break"
	elif copying:
		# The jar's existing shadow is the clue. Do not give the real figure an
		# exclusive cast/copy pose while the decoys stand at the compass points.
		pose = &"idle"
	elif _blink_warning > 0.0:
		pose = &"blink"
	elif phase == 3 and _ring_left > 6.0 - 3.0 / 8.0:
		pose = &"last_page"
	elif _bolt_left <= 0.5:
		pose = &"cast"
	painted.play_anim(pose)


func _enter_phase(number: int) -> void:
	visual.scale = Vector2.ONE
	_end_copies()
	_pending.clear()
	_break_pending = false
	_recover = 0
	_bolt_left = 2.5
	_blink_left = 5.6
	_blink_warning = 0
	_ring_left = 6
	if number > 1:
		_begin_copies()


func jar_lit() -> bool:
	for light in get_tree().get_nodes_in_group(&"glow_light"):
		if light is Node2D and light.global_position.distance_to(global_position) <= 520:
			return true
	return false


func _resolve_damage(_hit: Hitbox, amount: int) -> int:
	if _vanish > 0 or (copying and not jar_lit()):
		return 0
	if copying and amount > 0:
		_break_pending = true
		return amount * 2
	return amount


func _on_hurt(hit: Hitbox) -> void:
	if _break_pending:
		_end_copies()
		_break_pending = false
		_recover = 2.0
	super._on_hurt(hit)
	if is_dying():
		set_contact_enabled(false)
		_pending.clear()
		_end_copies()


func _boss_physics(delta: float) -> void:
	shadow.visible = jar_lit()
	if _recover > 0:
		_recover -= delta
		return
	if _vanish > 0:
		_vanish -= delta
		if _vanish <= 0:
			_show_copies()
		return
	_tick_pending(delta)
	if phase == 3:
		_ring_left -= delta
		if _ring_left <= 0:
			_ring_left += 6
			for i in range(8):
				_bolt(global_position, Vector2.RIGHT.rotated(TAU * i / 8.0), 240)
	if copying:
		_copy_left -= delta
		_volley_left -= delta
		if _volley_left <= 0:
			_volley_left += 0.75
			var figures: Array[Node2D] = [self]
			for copy in copies:
				if is_instance_valid(copy) and not copy.is_queued_for_deletion():
					figures.append(copy)
			var figure := figures[_volley_index % figures.size()]
			_volley_index += 1
			_fan(figure.global_position)
		if _copy_left <= 0:
			_end_copies()
			_blink_left = 5.6
		return
	_bolt_left -= delta
	_blink_left -= delta
	if _bolt_left <= 0.5:
		visual.modulate = Color(1.6, 1.3, 1.8)
	if _bolt_left <= 0:
		_fan(global_position, 0.0)
		_bolt_left += 2.5
		visual.modulate = Color.WHITE
	if _blink_warning > 0:
		_blink_warning -= delta
		visual.scale = Vector2(1.15, 0.85)
		if _blink_warning <= 0:
			_blink()
	elif _blink_left <= 0:
		_blink_warning = 0.4
		_blink_left = 6
	else:
		velocity = direction_to_player() * move_speed


func _tick_pending(delta: float) -> void:
	for entry in _pending.duplicate():
		entry.left -= delta
		if entry.left <= 0:
			for angle in [-15.0, 0.0, 15.0]:
				_bolt(entry.at, entry.dir.rotated(deg_to_rad(angle)), 300)
			_pending.erase(entry)


func _fan(at: Vector2, delay := 0.5) -> void:
	_pending.append(
		{"left": delay, "at": at, "dir": (player_position(at + Vector2.DOWN) - at).normalized()}
	)


func _bolt(at: Vector2, direction: Vector2, speed: float) -> void:
	var bolt := EnemyProjectile.new()
	bolt.speed = speed
	bolt.damage = 2
	bolt.visual_kind = &"archivist_spatter"
	bolt.blockable_by_ward = true
	get_parent().add_child(bolt)
	bolt.launch(at, direction)
	add_hazard(bolt)


func _blink() -> void:
	visual.scale = Vector2.ONE
	var choices: Array[Vector2] = []
	for lectern in LECTERNS:
		var point := arena_point(lectern + Vector2(96, 0))
		if point.distance_to(player_position(global_position)) >= 384:
			choices.append(point)
	if not choices.is_empty():
		global_position = choices[rng.randi_range(0, choices.size() - 1)]
	if phase > 1:
		_begin_copies()
	else:
		_fan(global_position)


func _begin_copies() -> void:
	_end_copies()
	copying = true
	_vanish = 0.8
	visible = false
	hurtbox.enabled = false
	set_contact_enabled(false)


func _show_copies() -> void:
	visible = true
	hurtbox.enabled = true
	set_contact_enabled(true)
	var real := rng.randi_range(0, 3)
	global_position = arena_point(COMPASS[real] if phase == 2 else ARENA_CENTRE)
	for i in range(4):
		if phase == 2 and i == real:
			continue
		var copy := Copy.new()
		copy.boss = self
		get_parent().add_child(copy)
		copy.global_position = arena_point(COMPASS[i])
		copies.append(copy)
		add_hazard(copy)
	_copy_left = 15
	_volley_left = 0.75
	_volley_index = 0


func _end_copies() -> void:
	for copy in copies:
		if is_instance_valid(copy):
			copy.queue_free()
	copies.clear()
	copying = false
	_vanish = 0
	visible = true
	if hurtbox != null:
		hurtbox.enabled = true


func spatter(at: Vector2) -> void:
	if is_dying() or is_dead or is_pausing() or is_in_intro():
		return
	var burst := Spatter.new()
	get_parent().add_child(burst)
	burst.global_position = at
	add_hazard(burst)


func reset_fight() -> void:
	if is_dead or is_defeated():
		return
	_end_copies()
	_pending.clear()
	_break_pending = false
	_recover = 0
	global_position = _home
	visual.scale = Vector2.ONE
	if shadow != null:
		shadow.visible = false
	super.reset_fight()


func _on_death() -> void:
	super._on_death()
	spawn_pickup(&"ember", ARENA_CENTRE, true)
	spawn_pickup(&"ember", ARENA_CENTRE + Vector2(192, 0), true)
