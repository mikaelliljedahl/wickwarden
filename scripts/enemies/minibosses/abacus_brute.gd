extends "res://scripts/enemies/boss_base.gd"
## C8 pre-reel answer: a pitch pot or charge flare shatters the four-HP front rail.

const KIND := &"abacus_brute"
const RAIL_HP := 4
const WARNING := 0.7
const WHIRL_TIME := 1.2
const WHIRL_RADIUS := 192.0
const APPROACH := 2.0  # The row does not prescribe an attack interval.

enum State { WALK, TELEGRAPH, WHIRL }

var state: State = State.WALK
var rail_hp := RAIL_HP
var _timer := APPROACH
var _stun_immunity := 0.0
var _chain_texture: Texture2D
var _whirl: Hitbox


func _init() -> void:
	max_hp = 28
	contact_damage = 3
	move_speed = 90.0
	body_radius = 40.0
	visual_kind = KIND
	miniboss = true
	arena_lock = false
	drops_enabled = false
	stun_scale = 1.0
	knockback_scale = 0.5
	armor_front_deg = 140.0
	Placeholder.register_kind(
		KIND, {"shape": "circle", "color": Color(0.65, 0.52, 0.35), "radius": 40.0}
	)


func _boss_ready() -> void:
	var path := "res://assets/sprites/abacus_whirl_z1.png"
	if ResourceLoader.exists(path):
		_chain_texture = load(path) as Texture2D
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	# Only this body's drawn floor cues use this material; Visual keeps its own lighting.
	var cue_material := CanvasItemMaterial.new()
	cue_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = cue_material


func _enter_phase(_number: int) -> void:
	state = State.WALK
	_timer = APPROACH
	rail_hp = RAIL_HP
	armor_front_deg = 140.0
	move_speed = 90.0
	_stun_immunity = 0.0
	_cancel_whirl()


func reset_fight() -> void:
	super()
	if not is_dead:
		_enter_phase(1)


func _boss_physics(delta: float) -> void:
	velocity = Vector2.ZERO
	_timer -= delta
	match state:
		State.WALK:
			var direction := direction_to_player()
			set_facing_dir(direction)
			velocity = direction * move_speed
			if _timer <= 0.0:
				state = State.TELEGRAPH
				_timer = WARNING
				velocity = Vector2.ZERO
		State.TELEGRAPH:
			if _timer <= 0.0:
				_start_whirl()
		State.WHIRL:
			if _timer <= 0.0:
				_cancel_whirl()
				state = State.WALK
				_timer = APPROACH
	queue_redraw()


func _start_whirl() -> void:
	_cancel_whirl()
	state = State.WHIRL
	_timer = WHIRL_TIME
	_whirl = Hitbox.new()
	_whirl.team = Layers.Team.ENEMY
	_whirl.kind = &"chain_whirl"
	_whirl.damage = 3
	_whirl.source = self
	_whirl.add_circle(WHIRL_RADIUS)
	add_child(_whirl)
	_whirl.activate()


func _cancel_whirl() -> void:
	if is_instance_valid(_whirl):
		_whirl.deactivate()
		_whirl.queue_free()
	_whirl = null


func _resolve_damage(hitbox: Hitbox, amount: int) -> int:
	if rail_hp > 0 and hitbox.kind in [&"flare", &"explosion"]:
		var offset := hitbox.origin() - global_position
		if offset.is_zero_approx() or absf(facing_dir.angle_to(offset)) <= deg_to_rad(70.0):
			rail_hp = maxi(0, rail_hp - amount)
			if rail_hp == 0:
				armor_front_deg = 0.0
				move_speed = 130.0
			queue_redraw()
			# The qualifying front hit is absorbed by the rail, without body-damage spill.
			return 0
	return amount


func stun(seconds: float) -> void:
	if _stun_immunity > 0.0 or is_stunned() or is_dying():
		return
	super.stun(minf(seconds, 1.5))


func _on_stunned(_seconds: float) -> void:
	_cancel_whirl()
	state = State.WALK
	_timer = APPROACH
	set_contact_enabled(false)


func _on_stun_end() -> void:
	_stun_immunity = 3.0
	set_contact_enabled(not is_dying())


func _tick_timers(delta: float) -> void:
	super(delta)
	_stun_immunity = maxf(0.0, _stun_immunity - delta)


func _on_hurt(hitbox: Hitbox) -> void:
	super(hitbox)
	if is_dying():
		_stun_time = 0.0
		_knock_time = 0.0
		velocity = Vector2.ZERO
		_cancel_whirl()
		set_contact_enabled(false)


func _on_death() -> void:
	super()
	for kind: StringName in [&"ember", &"ember", &"brass_coin", &"brass_coin"]:
		PickupBase.spawn(kind, get_parent(), global_position, true)


func _draw() -> void:
	if is_dead or is_dying():
		return
	if rail_hp > 0 and not is_stunned():
		# Tarnished rail rim: the same guarded front, with a soft contact edge.
		var start := facing_dir.angle() - deg_to_rad(70.0)
		var end := facing_dir.angle() + deg_to_rad(70.0)
		draw_arc(Vector2.ZERO, 52.0, start, end, 28, Color(0.22, 0.17, 0.12, 0.3), 15.0, true)
		draw_arc(Vector2.ZERO, 52.0, start, end, 28, Color(0.65, 0.57, 0.4, 0.65), 6.0, true)
		draw_arc(Vector2.ZERO, 50.0, start, end, 28, Color(0.85, 0.79, 0.61, 0.5), 1.5, true)
	if state == State.TELEGRAPH or state == State.WHIRL:
		if state == State.WHIRL and _chain_texture != null:
			_draw_painted_whirl()
		else:
			_draw_chain_scuff()


func _draw_chain_scuff() -> void:
	# The outer edge stays at the hit radius. All dust and bead marks lie inside it.
	var active := state == State.WHIRL
	var strength := 1.0 if active else 0.75
	draw_arc(
		Vector2.ZERO,
		WHIRL_RADIUS - 7.0,
		0,
		TAU,
		96,
		Color(0.61, 0.48, 0.31, 0.12 * strength),
		14.0,
		true
	)
	draw_arc(
		Vector2.ZERO, WHIRL_RADIUS, 0, TAU, 96, Color(0.78, 0.69, 0.51, 0.22 * strength), 3.0, true
	)
	var turn := (1.0 - _timer / WHIRL_TIME) * TAU if active else 0.0
	for i in range(24):
		var angle := float(i) * TAU / 24.0 + 0.035 * sin(float(i) * 2.3) + turn
		var length := 0.11 + 0.055 * sin(float(i) * 2.7)
		var radius := WHIRL_RADIUS - 5.0 - 3.0 * sin(float(i) * 1.8)
		draw_arc(
			Vector2.ZERO,
			radius,
			angle,
			angle + length,
			5,
			Color(0.73, 0.59, 0.38, 0.4 * strength),
			3.0 + 1.5 * sin(float(i) * 1.7),
			true
		)
		var bead := Vector2.from_angle(angle) * (WHIRL_RADIUS - 8.0)
		draw_circle(bead, 3.5, Color(0.32, 0.24, 0.16, 0.4 * strength), true, -1.0, true)
		draw_circle(
			bead - Vector2(0.7, 1.0), 1.6, Color(0.9, 0.81, 0.63, 0.6 * strength), true, -1.0, true
		)


func _draw_painted_whirl() -> void:
	# Bend the single painted chain into an orbit. The actor's Visual draws above it.
	draw_arc(
		Vector2.ZERO, WHIRL_RADIUS - 1.0, 0.0, TAU, 96, Color(0.78, 0.69, 0.51, 0.3), 2.0, true
	)
	var turn := (1.0 - _timer / WHIRL_TIME) * TAU
	var size := _chain_texture.get_size()
	var centers := [320.0, 425.0, 482.0, 523.0, 577.0, 550.0, 475.0]
	var segments := 96
	for i in range(segments):
		var points := PackedVector2Array()
		var uvs := PackedVector2Array()
		for corner in [[0, -1], [1, -1], [1, 1], [0, 1]]:
			var t: float = float(i + corner[0]) / segments
			var angle: float = turn + (t - 0.5) * 2.5
			var radius: float = 164.0 + corner[1] * 26.0
			points.append(Vector2.from_angle(angle) * radius)
			var c: float = t * 6.0
			var idx := mini(int(c), 5)
			var cy: float = lerpf(centers[idx], centers[idx + 1], c - idx)
			uvs.append(Vector2((20.0 + t * 1734.0) / size.x, (cy + corner[1] * 200.0) / size.y))
		draw_polygon(points, PackedColorArray([Color(1.4, 1.25, 1.1, 0.9)]), uvs, _chain_texture)
