extends "res://scripts/enemies/boss_base.gd"
## C2 Thorn Warden: retracting thorn skirt and eight ward-blockable needles.

const KIND := &"thorn_warden"
const INTERVAL := 3.0
const WARNING := 0.6
const NEEDLE := "res://scenes/enemies/thorn_needle.tscn"

enum State { WALK, TELEGRAPH }

var state: State = State.WALK
var _cycle := INTERVAL
var _timer := 0.0
var _stun_immunity := 0.0


func _init() -> void:
	max_hp = 16
	contact_damage = 2
	move_speed = 80.0
	body_radius = 30.0
	visual_kind = KIND
	miniboss = true
	arena_lock = false
	drops_enabled = false
	stun_scale = 1.0
	knockback_scale = 0.5
	Placeholder.register_kind(
		KIND, {"shape": "circle", "color": Color(0.3, 0.5, 0.25), "radius": 30.0}
	)
	Placeholder.register_kind(
		&"thorn_needle", {"shape": "diamond", "color": Color(0.7, 0.8, 0.4), "radius": 10.0}
	)


func _enter_phase(_number: int) -> void:
	state = State.WALK
	_cycle = INTERVAL
	_timer = 0.0
	_stun_immunity = 0.0


func _boss_physics(delta: float) -> void:
	_cycle -= delta
	velocity = Vector2.ZERO
	if state == State.WALK:
		var dir := direction_to_player()
		set_facing_dir(dir)
		velocity = dir * move_speed
		if _cycle <= 0.0:
			state = State.TELEGRAPH
			_timer = WARNING
			_cycle = INTERVAL
	else:
		_timer -= delta
		if _timer <= 0.0:
			_fire_ring()
			state = State.WALK
	queue_redraw()


func _fire_ring() -> void:
	var scene := load(NEEDLE) as PackedScene
	if scene == null:
		return
	for i in range(8):
		var needle := fire_projectile(scene, Vector2.from_angle(TAU * float(i) / 8.0), 280.0, 1)
		if needle != null and SpriteVisual.has_art(&"gloam_lance"):
			# The painted lance points right; turn and tint only the visual.
			var visual := SpriteVisual.attach(needle, &"gloam_lance", needle.radius)
			visual.rotation = needle.direction.angle()
			visual.scale = Vector2.ONE * 0.55
			visual.modulate = Color(0.8, 1.0, 0.5)
			var light := PointLight2D.new()
			light.texture = LightTexture.make()
			light.texture_scale = LightTexture.scale_for(65.0)
			light.color = Color(0.8, 1.0, 0.55)
			light.energy = 1.1
			needle.add_child(light)


func _resolve_damage(hitbox: Hitbox, amount: int) -> int:
	if hitbox.kind == &"hook":
		return 2 if is_stunned() else 1
	if hitbox.kind == &"fire":
		return 2
	return amount


func _on_stunned(_seconds: float) -> void:
	state = State.WALK
	_timer = 0.0
	queue_redraw()


func _draw() -> void:
	if is_dead or is_dying() or is_stunned():
		return
	var radius := 66.0 if state == State.TELEGRAPH else 42.0
	for i in range(8):
		var dir := Vector2.from_angle(TAU * float(i) / 8.0)
		draw_line(dir * 30.0, dir * radius, Color(0.85, 0.8, 0.4), 5.0)


func stun(seconds: float) -> void:
	if _stun_immunity > 0.0 or is_stunned() or is_dying():
		return
	super.stun(minf(seconds, 1.5))


func _tick_timers(delta: float) -> void:
	super(delta)
	_stun_immunity = maxf(0.0, _stun_immunity - delta)


func _on_stun_end() -> void:
	_stun_immunity = 3.0


func _on_hurt(hitbox: Hitbox) -> void:
	super(hitbox)
	if is_dying():
		set_contact_enabled(false)


func _on_death() -> void:
	super()
	for kind: StringName in [&"ember", &"ember", &"brass_coin", &"brass_coin"]:
		PickupBase.spawn(kind, get_parent(), global_position, true)
