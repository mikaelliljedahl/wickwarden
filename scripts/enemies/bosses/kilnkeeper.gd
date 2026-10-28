extends "res://scripts/enemies/boss_base.gd"
## Kilnkeeper, C1. Fire damages wax and separately counts the ticks that soften its armour.

const START := Vector2(1488, 480)
const SPLASH_RADIUS := 150.0

enum Attack { WALK, FAN_WARNING, RUSH_WARNING, RUSH, RECOVER, SPLASH_WARNING, SPLASH }

var attack: Attack = Attack.WALK
var melt_ticks: int = 0
var molten_left: float = 0.0
var _fan_left: float = 3.0
var _rush_left: float = 8.0
var _splash_left: float = 3.0
var _attack_left: float = 0.0
var _rush_distance: float = 0.0
var _aim := Vector2.LEFT
var _splash_frames: int = 0
var _splash: Hitbox
var _plate: Node2D


func _init() -> void:
	boss_id = &"kilnkeeper"
	arena_id = &"cave_1_8"
	max_hp = 24
	contact_damage = 2
	body_radius = 60.0
	move_speed = 100.0
	thresholds = [12]
	drops_enabled = false
	stun_scale = 0.0
	knockback_scale = 0.0
	visual_kind = &"kilnkeeper"
	Placeholder.register_kind(
		&"kilnkeeper", {"shape": "circle", "color": Color(0.58, 0.32, 0.15), "radius": 60.0}
	)
	Placeholder.register_kind(
		&"wax_plate", {"shape": "rect", "color": Color(0.95, 0.85, 0.55), "size": Vector2(76, 84)}
	)
	Placeholder.register_kind(
		&"kiln_slag", {"shape": "circle", "color": Color(1.0, 0.4, 0.1), "radius": 12.0}
	)

	Placeholder.register_kind(
		&"kiln_pillar",
		{"shape": "rect", "color": Color(0.25, 0.22, 0.2), "size": Vector2(96, 96)},
		true
	)
	Placeholder.register_kind(
		&"kiln_mouth",
		{"shape": "rect", "color": Color(0.5, 0.2, 0.08), "size": Vector2(96, 192)},
		true
	)


func _boss_ready() -> void:
	var scene := load("res://scenes/enemies/bosses/wax_plate.tscn") as PackedScene
	if scene != null:
		_plate = scene.instantiate() as Node2D
		if _plate != null:
			add_child(_plate)
			_plate.z_index = 1
			SpriteVisual.attach(_plate, &"wax_plate")
	visual = SpriteVisual.attach(self, &"kilnkeeper", body_radius)
	if visual is SpriteVisual:
		visual.auto_motion = false
	_suppress_painted_plate_fallbacks()


func _suppress_painted_plate_fallbacks() -> void:
	if not SpriteVisual.has_art(&"wax_plate"):
		return
	for node in find_children("*", "Placeholder", true, false):
		var fallback := node as Placeholder
		if fallback != null and fallback.kind == &"wax_plate":
			fallback.visible = false


func _process(_delta: float) -> void:
	var painted := visual as SpriteVisual
	if painted == null:
		return
	var pose := &"walk" if velocity.length() > 5.0 else &"idle"
	if phase == 1 and attack == Attack.FAN_WARNING:
		pose = &"slag_fan"
	elif phase == 2:
		if attack in [Attack.SPLASH_WARNING, Attack.SPLASH]:
			pose = &"splash"
		elif attack in [Attack.RUSH_WARNING, Attack.RUSH]:
			pose = &"rush"
	var direction := _aim if attack != Attack.WALK else facing_dir
	# Only the published down/side strips exist; phase two has side art only.
	var side := phase == 2 or absf(direction.x) >= absf(direction.y)
	var suffix := "side" if side else "down"
	if pose == &"slag_fan":
		suffix = "down"
	painted.set_facing(Vector2(signf(direction.x), 0) if suffix == "side" else Vector2.DOWN)
	painted.play_anim(StringName("%s_%s" % [pose, suffix]))


func _enter_phase(_number: int) -> void:
	attack = Attack.WALK
	melt_ticks = 0
	molten_left = 0.0
	_fan_left = 3.0 if phase == 1 else 2.5
	_rush_left = 8.0 if phase == 1 else 6.0
	_splash_left = 3.0
	_splash = null
	_show_wax()


func reset_fight() -> void:
	super()
	if is_dead:
		return
	global_position = arena_point(START)
	_enter_phase(1)


func is_molten() -> bool:
	return molten_left > 0.0


func _resolve_damage(hitbox: Hitbox, amount: int) -> int:
	if hitbox.kind == &"fire":
		if not is_molten():
			melt_ticks += 1
			if melt_ticks >= (3 if phase == 1 else 4):
				molten_left = 8.0 if phase == 1 else 6.0
				_splash_left = 3.0
				if attack == Attack.RUSH or attack == Attack.RUSH_WARNING:
					attack = Attack.WALK
				_show_wax()
		return 2
	if not is_molten():
		if amount > 0:
			_spark_guard(hitbox)
		return 0
	return amount


func _on_hurt(hitbox: Hitbox) -> void:
	super(hitbox)
	if is_dying():
		set_contact_enabled(false)
	_show_wax()


func set_contact_enabled(enabled: bool) -> void:
	if contact_hitbox == null:
		return
	var allowed := enabled and not is_dying() and contact_damage > 0
	# Stop damage in this physics frame; defer the monitoring change out of collision callbacks.
	contact_hitbox.damage = contact_damage if allowed else 0
	contact_hitbox.set_deferred(&"active", allowed)


func _show_wax() -> void:
	# Keep the original body as the fallback if the phase-two strip is unavailable.
	var kind := &"kilnkeeper_p2" if phase == 2 else &"kilnkeeper"
	if not SpriteVisual.has_art(kind):
		kind = &"kilnkeeper"
	var painted := visual as SpriteVisual
	if painted != null and painted.kind != kind:
		painted.set_kind(kind)
	if _plate != null:
		_plate.modulate = Color(1, 0.35, 0.1, 0.65) if is_molten() else Color.WHITE
		# The furnace dims as its wax body breaks; there is no HUD boss bar.
		_plate.scale = Vector2.ONE * (0.6 + 0.4 * float(hp) / float(max_hp))
	if visual != null:
		visual.modulate = Color(1, 0.55, 0.25) if phase == 2 else Color.WHITE


func _boss_physics(delta: float) -> void:
	if molten_left > 0.0:
		molten_left = maxf(0.0, molten_left - delta)
		if molten_left == 0.0:
			melt_ticks = 0
			_show_wax()
	_fan_left -= delta
	_rush_left -= delta
	if is_molten():
		_splash_left -= delta
	if attack != Attack.WALK:
		_tick_attack(delta)
		return
	if is_molten() and _splash_left <= 0.0:
		_splash_left = 3.0
		_warn(Attack.SPLASH_WARNING, 0.5, SPLASH_RADIUS)
	elif not is_molten() and _rush_left <= 0.0:
		_rush_left = 8.0 if phase == 1 else 6.0
		var toward := direction_to_player()
		_aim = (
			Vector2(signf(toward.x), 0)
			if absf(toward.x) >= absf(toward.y)
			else Vector2(0, signf(toward.y))
		)
		if _aim == Vector2.ZERO:
			_aim = Vector2.LEFT
		_warn(Attack.RUSH_WARNING, 0.8, body_radius)
	elif _fan_left <= 0.0:
		_fan_left = 3.0 if phase == 1 else 2.5
		_aim = direction_to_player()
		if _aim == Vector2.ZERO:
			_aim = Vector2.LEFT
		_warn(Attack.FAN_WARNING, 0.6, body_radius)
	else:
		velocity = direction_to_player() * move_speed
		set_facing_dir(velocity)


func _warn(next: Attack, duration: float, radius: float) -> void:
	attack = next
	_attack_left = duration
	var scene := load("res://scenes/enemies/telegraph.tscn") as PackedScene
	if scene == null:
		return
	var marker = scene.instantiate()
	marker.z_index = 1
	marker.radius = radius
	marker.duration = duration
	marker.color = Color(1, 0.5, 0.15)
	add_child(marker)
	add_hazard(marker)
	marker.start()


func _tick_attack(delta: float) -> void:
	_attack_left -= delta
	match attack:
		Attack.RUSH:
			if hit_wall or _rush_distance >= 960.0:
				attack = Attack.RECOVER
				_attack_left = 1.2
				return
			velocity = _aim * 420.0
			_rush_distance += velocity.length() * delta
			return
		Attack.SPLASH:
			_splash_frames += 1
			if _splash_frames < 3:
				return
			if is_instance_valid(_splash):
				_splash.queue_free()
			_splash = null
			attack = Attack.WALK
			return
	if _attack_left > 0.0:
		return
	match attack:
		Attack.FAN_WARNING:
			var count := 3 if phase == 1 else 5
			for index in range(count):
				var shot := EnemyProjectile.new()
				shot.visual_kind = &"kiln_slag"
				shot.speed = 300.0
				shot.damage = 2
				shot.room_rect = room_rect
				get_parent().add_child(shot)
				shot.launch(
					global_position, _aim.rotated(deg_to_rad((index - (count - 1) * 0.5) * 20.0))
				)
				var look := shot.get_node_or_null("Visual") as Node2D
				if look is SpriteVisual:
					# The painted ball travels roughly 20 degrees clockwise from the x axis.
					look.rotation = shot.direction.angle() - deg_to_rad(20.0)
				var light := PointLight2D.new()
				light.name = "SlagLight"
				light.texture = LightTexture.make()
				light.texture_scale = LightTexture.scale_for(80.0)
				light.color = Color(1.0, 0.5, 0.2)
				light.energy = 0.7
				shot.add_child(light)
				shot.destroyed.connect(_slag_impact.bind(shot))
				add_hazard(shot)
			attack = Attack.WALK
		Attack.RUSH_WARNING:
			attack = Attack.RUSH
			_rush_distance = 0.0
		Attack.SPLASH_WARNING:
			var effect := SpriteVisual.spawn_effect(self, &"fx_wax_splash", global_position, 0.8)
			if effect != null:
				var unshaded := CanvasItemMaterial.new()
				unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
				effect.material = unshaded
				add_hazard(effect)
			_splash = Hitbox.new()
			_splash.team = Layers.Team.ENEMY
			_splash.kind = &"wax_splash"
			_splash.damage = 2
			_splash.source = self
			_splash.blockable = false
			_splash.add_circle(SPLASH_RADIUS)
			var look := SplashVisual.new()
			look.name = "Visual"
			_splash.add_child(look)
			add_child(_splash)
			add_hazard(_splash)
			_splash.activate()
			_splash_frames = 0
			attack = Attack.SPLASH
		_:
			attack = Attack.WALK


func _on_death() -> void:
	super()
	spawn_pickup(&"ember", ARENA_CENTRE, true)
	spawn_pickup(&"ember", ARENA_CENTRE + Vector2(DROP_SPREAD, 0), true)


func _slag_impact(reason: StringName, shot: EnemyProjectile) -> void:
	if reason not in [&"hit", &"wall", &"ward"] or not is_instance_valid(shot):
		return
	var effect := SpriteVisual.spawn_effect(get_parent(), &"kiln_slag", shot.global_position)
	if effect is SpriteVisual:
		effect.play_anim(&"impact")


class SplashVisual:
	extends Node2D

	func _ready() -> void:
		var unshaded := CanvasItemMaterial.new()
		unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		material = unshaded

	func _draw() -> void:
		draw_arc(Vector2.ZERO, SPLASH_RADIUS, 0, TAU, 96, Color(1.0, 0.72, 0.3, 0.9), 3.0)
