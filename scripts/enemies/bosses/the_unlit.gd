extends "res://scripts/enemies/boss_base.gd"
## Literal P1 orbit crosses the upper room edge. Eyes are deliberately unconfined;
## they return to the accessible lower arc. Visual/balance review remains open.

const EYE_SCENE := "res://scenes/enemies/bosses/unlit_eye.tscn"
const MASS := Vector2(960, 288)
const LANTERN := Vector2(960, 288)
const EYES := 5
const ORBIT := 330.0
const ORBIT_SPEED := 24.0

var eyes: Array[EnemyBase] = []
var angles: Array[float] = []
var gaze: Array[float] = []
var gaze_tell: Array[float] = []
var lantern: Node2D
var _reel_script: GDScript
var _heart_glow: Node2D
var exposed_left := 0.0
var pull_damage := 0
var pulls := 0
var _hands_left := 5.0
var _wave_left := 3.2
var _wave_tell := 0.0
var _drips_left := 12.0
var _torrent_left := 4.0
var _torrent_tell := 0.0
var _lash_left := 6.0
var _pulse_left := 3.0
var _hounds_entered := false
var _lash_index := 0
var _phase_origin := Vector2.ZERO
var _lantern_origin := Vector2.ZERO
var _lantern_target := Vector2.ZERO
var _slide_left := 0.0


func _init() -> void:
	boss_id = &"the_unlit"
	arena_id = &"cave_10_14"
	max_hp = 75
	thresholds = [60, 24]
	body_radius = 120.0
	contact_damage = 2
	move_speed = 70.0
	resupply = true
	arena_lock = false  # The boss door permits retreat (monster spec 4.0).
	death_drops = []
	drops_enabled = false
	stun_scale = 0.0
	knockback_scale = 0.0
	if not Placeholder.has_kind(&"the_unlit"):
		Placeholder.register_kind(
			&"the_unlit", {"shape": "circle", "color": Color(0.23, 0.18, 0.3), "radius": 120.0}
		)
	for kind in [
		&"unlit_p1_mass",
		&"unlit_p2_shell",
		&"unlit_p3_heart",
		&"ninth_lantern",
		&"unlit_eye",
		&"unlit_hush_hand"
	]:
		if not Placeholder.has_kind(kind):
			Placeholder.register_kind(
				kind, {"shape": "circle", "color": Color(0.48, 0.38, 0.55), "radius": 110.0}
			)
	visual_kind = &"unlit_p1_mass"


func _enter_tree() -> void:
	# Room templates duplicate children made by an earlier _ready(). Remove only
	# this actor's generated helper types before their _ready() can register
	# cloned reel targets. Retired actors take this path too, before BossBase
	# skips _boss_ready() on the saved defeat flag.
	_reel_script = load("res://scripts/world/reelable.gd") as GDScript
	for child in get_children():
		if child is HeartGlow or (_reel_script != null and child.get_script() == _reel_script):
			remove_child(child)
			child.free()
	lantern = null
	_heart_glow = null


func _boss_ready() -> void:
	contact_hitbox.get_child(0).shape.radius = 120.0
	_heart_glow = HeartGlow.new()
	_heart_glow.name = "HeartGlow"
	_heart_glow.z_index = 1
	_heart_glow.visible = false
	add_child(_heart_glow)
	_phase_origin = global_position - MASS
	var script := _reel_script
	if script != null:
		lantern = script.new() as Node2D
		lantern.name = "NinthLantern"
		lantern.top_level = true
		add_child(lantern)
		lantern.global_position = _phase_origin + LANTERN
		lantern.reeled.connect(_on_reeled)
		lantern.hurtbox.enabled = false
		var lamp_look := SpriteVisual.attach(lantern, &"ninth_lantern", 110)
		if lamp_look is SpriteVisual:
			lamp_look.auto_motion = false
			lamp_look.add_child(LanternGlowPresentation.new())
	queue_redraw()


func _enter_phase(number: int) -> void:
	_hands_left = 5.0
	_wave_left = 3.2
	_wave_tell = 0.0
	_drips_left = 12.0
	_torrent_left = 4.0
	_torrent_tell = 0.0
	_lash_left = 6.0
	_pulse_left = 3.0
	exposed_left = 0.0
	pull_damage = 0
	if number == 1:
		global_position = _phase_origin + MASS
		_spawn_eyes()
	else:
		global_position = _phase_origin + ARENA_CENTRE
	var looks: Array[StringName] = [&"unlit_p1_mass", &"unlit_p2_shell", &"unlit_p3_heart"]
	visual = SpriteVisual.attach(self, looks[number - 1], body_radius)
	visual.modulate = Color(1.0, 0.85, 0.55) if number == 2 else Color.WHITE
	_heart_glow.visible = number == 3 and not SpriteVisual.has_art(&"unlit_p3_heart")
	if number == 3 and visual is SpriteVisual:
		# Presentation follows the exposure timer, never the sprite's animation state.
		visual.auto_motion = false
		# The reeled lantern can cross the heart; keep the vulnerable centre readable.
		visual.z_index = 1
		visual.play_anim(&"shielded")
		var heart_light := PointLight2D.new()
		heart_light.texture = LightTexture.make()
		heart_light.texture_scale = LightTexture.scale_for(200.0)
		heart_light.color = Color(1.0, 0.75, 0.45)
		heart_light.energy = 0.9
		visual.add_child(heart_light)
	set_contact_enabled(number != 3)
	if is_instance_valid(lantern):
		lantern.global_position = _phase_origin + LANTERN
		lantern.hurtbox.enabled = number == 3 and not is_pausing()
		# The accepted P1 mass includes the lamp; its overlapping fallback hides it.
		# Later phases still show the existing separate lantern and reel target.
		var lamp_look := lantern.get_node_or_null("Visual") as Node2D
		if lamp_look != null:
			lamp_look.visible = number != 1 or not SpriteVisual.has_art(&"unlit_p1_mass")
	queue_redraw()


func _spawn_eyes() -> void:
	eyes.clear()
	angles.clear()
	gaze.clear()
	gaze_tell.clear()
	var scene := load(EYE_SCENE) as PackedScene
	if scene == null:
		return
	for i in range(EYES):
		var eye := scene.instantiate() as EnemyBase
		if eye == null:
			continue
		var angle := TAU * i / EYES
		adopt_part(eye, _phase_origin + MASS + Vector2.from_angle(angle) * ORBIT)
		var light := PointLight2D.new()
		light.name = "EyeLight"
		light.texture = LightTexture.make()
		light.texture_scale = LightTexture.scale_for(100.0)
		light.color = Color(0.35, 0.8, 0.85)
		light.energy = 0.65
		eye.add_child(light)
		eye.room_rect = Rect2()
		eyes.append(eye)
		angles.append(angle)
		gaze.append(3.0 + 0.7 * i)
		gaze_tell.append(0.0)


func arena_point(local: Vector2) -> Vector2:
	return _phase_origin + local


func _boss_physics(delta: float) -> void:
	if phase == 2 and is_instance_valid(lantern):
		lantern.global_position = _phase_origin + LANTERN
	if is_instance_valid(lantern):
		lantern.hurtbox.enabled = phase == 3 and exposed_left <= 0.0
	match phase:
		1:
			_tick_eyes(delta)
			_hands_left -= delta
			if _hands_left <= 0.0:
				_hands_left += 5.0
				_spawn_hands()
		2:
			velocity = direction_to_player() * move_speed
			_tick_wax(delta)
			visual.modulate = Color(1.6, 1.3, 0.8) if _wave_tell > 0 else Color(1.0, 0.85, 0.55)
		3:
			_tick_heart(delta)
			_heart_glow.exposed = exposed_left > 0
			_heart_glow.queue_redraw()
			if visual is SpriteVisual:
				var pose: StringName = &"shielded"
				if exposed_left > 0:
					pose = &"pulse" if fmod(exposed_left, 1.0) < 0.5 else &"idle"
				visual.play_anim(pose)
				visual.modulate = Color.WHITE
			else:
				visual.modulate = Color(1.2, 1.0, 0.7) if exposed_left > 0 else Color(0.35, 0.35, 0.55)
	queue_redraw()


func _tick_eyes(delta: float) -> void:
	var alive := parts().size()
	for i in range(eyes.size()):
		var eye := eyes[i]
		if not is_instance_valid(eye) or eye.is_dead:
			continue
		eye.room_rect = Rect2()
		eye.collision_mask = 0
		angles[i] += deg_to_rad(ORBIT_SPEED) * (1.0 + (EYES - alive) * 0.25) * delta
		eye.global_position = _phase_origin + MASS + Vector2.from_angle(angles[i]) * ORBIT
		if gaze_tell[i] > 0.0:
			gaze_tell[i] -= delta
			if gaze_tell[i] <= 0.0:
				_bolt(eye.global_position, 320.0)
				gaze[i] = 3.0
		else:
			gaze[i] -= delta
			if gaze[i] <= 0.0:
				gaze_tell[i] = 0.5
				_marker(eye.global_position, 0.5, 44.0)
		var light := eye.get_node_or_null("EyeLight") as PointLight2D
		if light != null:
			light.energy = 1.3 if gaze_tell[i] > 0.0 else 0.65
	if alive <= 3 and not _hounds_entered:
		_hounds_entered = true
		_spawn_minions("husk_hound", 2, true)


func _on_part_hurt(amount: int, _part: EnemyBase) -> void:
	if phase != 1 or _dying:
		return
	hp = maxi(60, hp - amount)
	# Damage provenance is the eye's accepted sling hit; the mass is never hit directly.
	_on_hurt(null)


func _resolve_damage(hitbox: Hitbox, _amount: int) -> int:
	if phase == 2:
		if hitbox.kind == &"fire" or hitbox.kind == &"explosion":
			return mini(2, hp - 24)
	elif phase == 3 and exposed_left > 0.0:
		var damage := 0
		match hitbox.kind:
			&"hook":
				damage = 2
			&"flare", &"explosion":
				damage = 4
		damage = mini(damage, 8 - pull_damage)
		pull_damage += damage
		return damage
	return 0


## Scripted damage cannot bypass the forced tool sequence.
func apply_damage(_amount: int, _from: Vector2, _speed := 480.0, _time := 0.12) -> bool:
	return false


func _tick_wax(delta: float) -> void:
	_drips_left -= delta
	if _drips_left <= 0.0:
		_drips_left += 12.0
		_spawn_minions("wickling", 3)
	if _flame_attached():
		return
	if _wave_tell > 0.0:
		_wave_tell -= delta
		if _wave_tell <= 0.0:
			_ring(global_position, 720.0, 360.0, 96.0)
	else:
		_wave_left -= delta
		if _wave_left <= 0.0:
			_wave_left += 3.2
			_wave_tell = 0.8
			_marker(global_position, 0.8, body_radius + 20)


func _flame_attached() -> bool:
	for flame in get_tree().get_nodes_in_group(&"cinder_flames"):
		if flame.active and flame.get_overlapping_areas().has(hurtbox):
			return true
	return false


func _on_reeled(hitbox: Hitbox) -> void:
	if phase != 3 or is_pausing() or _dying or exposed_left > 0.0:
		return
	var puller := player_position(hitbox.origin())
	if puller.distance_to(lantern.global_position) > 576.0:
		return
	var toward := (puller - lantern.global_position).normalized()
	_lantern_origin = lantern.global_position
	_lantern_target = lantern.global_position + toward * 288.0
	_slide_left = 0.4
	exposed_left = 6.0
	pull_damage = 0
	pulls += 1
	_pulse_left = 3.0
	lantern.hurtbox.enabled = false
	_spawn_minions("husk_hound", 2)


func _tick_heart(delta: float) -> void:
	if exposed_left > 0.0:
		exposed_left = maxf(0.0, exposed_left - delta)
		if _slide_left > 0.0:
			_slide_left = maxf(0.0, _slide_left - delta)
			lantern.global_position = _lantern_origin.lerp(_lantern_target, 1.0 - _slide_left / 0.4)
		_pulse_left -= delta
		if _pulse_left <= 0.7 and _pulse_left + delta > 0.7:
			_marker(global_position, 0.7, 150.0)
		if _pulse_left <= 0.0:
			_pulse_left += 3.0
			_ring(global_position, 400.0, 400.0 / 0.6, 48.0)
		if exposed_left <= 0.0:
			lantern.global_position = _phase_origin + LANTERN
	_torrent_left -= delta
	if _torrent_tell > 0.0:
		_torrent_tell -= delta
		if _torrent_tell <= 0.0:
			for i in range(4):
				_bolt(global_position, 240.0, (i - 1.5) * 0.25, true)
	elif _torrent_left <= 0.0:
		_torrent_left += 4.0
		_torrent_tell = 0.5
		_marker(global_position, 0.5, 140.0)
	_lash_left -= delta
	if _lash_left <= 0.0:
		_lash_left += 6.0
		var line := Band.new()
		line.position = get_parent().to_local(_phase_origin + Vector2(576 + _lash_index * 384, 480))
		_lash_index = (_lash_index + 1) % 3
		get_parent().add_child(line)
		add_hazard(line)


func _bolt(at: Vector2, speed: float, spread := 0.0, homing := false) -> void:
	var bolt := fire_projectile(
		null, (player_position(at + Vector2.DOWN) - at).normalized().rotated(spread), speed, 2, at
	)
	bolt.homing_turn_deg = 90.0 if homing else 0.0
	bolt.lifetime = 4.0 if homing else 8.0


func _marker(at: Vector2, duration: float, radius: float) -> void:
	var script := load("res://scripts/enemies/telegraph.gd") as GDScript
	if script == null:
		return
	var marker = script.new()
	marker.position = get_parent().to_local(at)
	marker.duration = duration
	marker.radius = radius
	get_parent().add_child(marker)
	marker.start()
	add_hazard(marker)


func _ring(at: Vector2, reach: float, speed: float, width: float) -> Hitbox:
	var ring := Ring.new()
	ring.position = get_parent().to_local(at)
	ring.reach = reach
	ring.speed = speed
	ring.width = width
	get_parent().add_child(ring)
	add_hazard(ring)
	return ring


func _spawn_hands() -> void:
	for side in [-1, 1]:
		var hand := Hand.new()
		var at := player_position(_phase_origin + ARENA_CENTRE) + Vector2(side * 120, 0)
		at.x = clampf(at.x, _phase_origin.x + 196, _phase_origin.x + 1724)
		at.y = clampf(at.y, _phase_origin.y + 196, _phase_origin.y + 764)
		adopt_deferred(hand, at)
		add_hazard(hand)


func _spawn_minions(kind: String, count: int, limit_hounds := false) -> void:
	var live := 0
	if limit_hounds:
		for hazard in _hazards:
			if is_instance_valid(hazard) and hazard.is_in_group(&"unlit_hounds"):
				live += 1
	var scene := load("res://scenes/enemies/%s.tscn" % kind) as PackedScene
	if scene == null:
		return
	for i in range(count):
		if limit_hounds and live >= 2:
			break
		var enemy := scene.instantiate() as EnemyBase
		if enemy == null:
			continue
		enemy.drops_enabled = false
		if kind == "husk_hound":
			enemy.add_to_group(&"unlit_hounds")
		adopt_deferred(enemy, _phase_origin + Vector2(288 + i * 576, 720))
		add_hazard(enemy)
		live += 1


func reset_fight() -> void:
	if _dying or _defeated or is_dead:
		return
	super()
	eyes.clear()
	angles.clear()
	gaze.clear()
	gaze_tell.clear()
	pulls = 0
	exposed_left = 0.0
	_slide_left = 0.0
	_hounds_entered = false
	_heart_glow.visible = false
	_lash_index = 0
	global_position = _phase_origin + MASS
	if is_instance_valid(lantern):
		lantern.global_position = _phase_origin + LANTERN
		lantern.hurtbox.enabled = false
	queue_redraw()


func _exit_tree() -> void:
	clear_hazards()
	_free_parts()
	super()


func _begin_death() -> void:
	super()
	_death_left = 2.0
	set_contact_enabled(false)
	hurtbox.enabled = false
	if is_instance_valid(lantern):
		lantern.hurtbox.enabled = false


func _tick_death(delta: float) -> void:
	_death_left -= delta
	if visual != null:
		visual.modulate.a = clampf(_death_left / 2.0, 0.0, 1.0)
	if is_instance_valid(lantern):
		lantern.global_position = lantern.global_position.move_toward(
			_phase_origin + ARENA_CENTRE, 720 * delta
		)
	_heart_glow.modulate.a = clampf(_death_left / 2.0, 0.0, 1.0)
	queue_redraw()
	if _death_left <= 0.0:
		# Keep the settled lantern with the arena after the defeated actor is freed.
		if is_instance_valid(lantern):
			lantern.reparent(get_parent())
		kill()


func _draw() -> void:
	super()
	if is_dead:
		return
	var lamp := to_local(_phase_origin + LANTERN)
	if is_instance_valid(lantern):
		lamp = to_local(lantern.global_position)
	for post in [Vector2(576, 96), Vector2(960, 96), Vector2(1344, 96)]:
		draw_line(
			to_local(_phase_origin + post),
			lamp,
			Color(0.55, 0.5, 0.45, clampf(_death_left / 2.0, 0, 1) if _dying else 1.0),
			6
		)


class LanternGlowPresentation:
	extends Node
	## The lantern survives the boss, so its presentation travels with its visual.
	var elapsed := 0.0

	func _process(delta: float) -> void:
		elapsed += delta
		var look := get_parent() as SpriteVisual
		if look != null:
			look.play_anim(&"glow" if fmod(elapsed, 1.0) >= 0.5 else &"idle")


class HeartGlow:
	extends Node2D
	var exposed := false

	func _draw() -> void:
		draw_circle(Vector2.ZERO, 70, Color(1, 0.6, 0.25) if exposed else Color(0.18, 0.16, 0.25))
		if not exposed:
			draw_arc(Vector2.ZERO, 110, 0, TAU, 48, Color(0.8, 0.7, 0.3), 6)


class Ring:
	extends Hitbox
	var reach := 720.0
	var speed := 360.0
	var width := 96.0
	var radius := 0.0

	func _ready() -> void:
		team = Layers.Team.ENEMY
		damage = 3
		kind = &"unlit_ring"
		blockable = true
		block_destroys_carrier = false
		knockback = 640
		super()
		add_circle(reach + width / 2)
		var look: Node2D
		if width == 96.0:
			look = WaxWaveVisual.new()
		elif width == 48.0:
			look = HeartPulseVisual.new()
		else:
			look = Node2D.new()
		look.name = "Visual"
		add_child(look)
		activate()

	func _physics_process(delta: float) -> void:
		radius += speed * delta
		super(delta)
		queue_redraw()
		if radius >= reach:
			queue_free()

	func _try_hit(target: Hurtbox) -> void:
		if absf(target.global_position.distance_to(global_position) - radius) <= width / 2 + 26:
			super(target)

	func _draw() -> void:
		if width != 96.0 and width != 48.0:
			draw_arc(Vector2.ZERO, maxf(1, radius), 0, TAU, 80, Color(0.85, 0.7, 0.4, 0.65), width)


class WaxWaveVisual:
	extends Node2D
	var art: WaxWaveTexture

	func _ready() -> void:
		var light := CanvasItemMaterial.new()
		light.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		material = light
		art = WaxWaveTexture.new()
		add_child(art)

	func _process(_delta: float) -> void:
		queue_redraw()
		art.queue_redraw()

	func _draw() -> void:
		var ring := get_parent() as Ring
		var inner := maxf(0.0, ring.radius - ring.width / 2.0)
		var outer := ring.radius + ring.width / 2.0
		draw_arc(Vector2.ZERO, maxf(1.0, ring.radius), 0, TAU, 160, Color(0.65, 0.37, 0.12, 0.24), ring.width)
		if inner > 0:
			draw_arc(Vector2.ZERO, inner, 0, TAU, 160, Color(1, 0.72, 0.32, 0.85), 3)
		draw_arc(Vector2.ZERO, outer, 0, TAU, 160, Color(1, 0.72, 0.32, 0.85), 3)


class HeartPulseVisual:
	extends WaxWaveVisual

	func _ready() -> void:
		super()
		var path := "res://assets/sprites/unlit_heart_pulse_z1_idle.png"
		if ResourceLoader.exists(path):
			art.effect.set_shader_parameter("wax", load(path) as Texture2D)
			art.visible = true
		else:
			art.visible = false

	func _draw() -> void:
		var ring := get_parent() as Ring
		var inner := maxf(0.0, ring.radius - ring.width / 2.0)
		var outer := ring.radius + ring.width / 2.0
		draw_arc(Vector2.ZERO, maxf(1.0, ring.radius), 0, TAU, 160, Color(0.32, 0.24, 0.55, 0.28), ring.width)
		if inner > 0:
			draw_arc(Vector2.ZERO, inner, 0, TAU, 160, Color(0.74, 0.7, 1.0, 0.9), 2)
		draw_arc(Vector2.ZERO, outer, 0, TAU, 160, Color(0.74, 0.7, 1.0, 0.9), 2)


class WaxWaveTexture:
	extends Node2D
	var effect: ShaderMaterial

	func _ready() -> void:
		var shader := Shader.new()
		shader.code = """shader_type canvas_item;
render_mode unshaded;
uniform sampler2D wax : filter_linear, repeat_disable;
uniform float radius;
uniform float band_width;
uniform float outer_radius;
void fragment() {
    vec2 p = (UV - vec2(0.5)) * (2.0 * outer_radius);
    float d = length(p);
    float v = (d - radius) / band_width + 0.5;
    float u = atan(p.y, p.x) / 6.28318530718 + 0.5;
    if (v < 0.0 || v > 1.0) { COLOR = vec4(0.0); }
    else { COLOR = texture(wax, vec2(mix(0.005, 0.995, u), v)); }
}
"""
		effect = ShaderMaterial.new()
		effect.shader = shader
		var path := "res://assets/sprites/unlit_wax_wave_z1_idle.png"
		if ResourceLoader.exists(path):
			effect.set_shader_parameter("wax", load(path) as Texture2D)
		else:
			visible = false
		material = effect

	func _draw() -> void:
		var ring := get_parent().get_parent() as Ring
		var outer := ring.radius + ring.width / 2.0
		effect.set_shader_parameter("radius", ring.radius)
		effect.set_shader_parameter("band_width", ring.width)
		effect.set_shader_parameter("outer_radius", outer)
		draw_rect(Rect2(Vector2(-outer, -outer), Vector2(2 * outer, 2 * outer)), Color.WHITE)


class Hand:
	extends EnemyBase
	var age := 0.0

	func _init() -> void:
		max_hp = 2
		body_radius = 100
		contact_damage = 4
		drops_enabled = false
		knockback_scale = 0
		stun_scale = 0
		visual_kind = &"unlit_hush_hand"

	func _enemy_ready() -> void:
		contact_hitbox.get_child(0).shape.radius = 100.0
		collision_layer = 0
		collision_mask = 0
		hurtbox.enabled = false
		set_contact_enabled(false)
		visual.modulate.a = 0.25
		if visual is SpriteVisual:
			visual.auto_motion = false
			visual.add_child(HandPresentation.new())

	func _enemy_physics(delta: float) -> void:
		age += delta
		if age >= 1.0 and not hurtbox.enabled:
			hurtbox.enabled = true
			collision_layer = Layers.WORLD
			set_contact_enabled(true)
			visual.modulate.a = 1.0
		if age >= 3.0:
			queue_free()
		queue_redraw()

	func _draw() -> void:
		draw_arc(Vector2.ZERO, 100, 0, TAU, 48, Color(0.9, 0.6, 0.3), 4)


class HandPresentation:
	extends Node
	## Observe the existing three-second lifetime; sinking remains a live obstacle.
	## No animation callback controls contact, HP, collision or retirement.
	var _shown: StringName = &""

	func _process(_delta: float) -> void:
		var look := get_parent() as SpriteVisual
		var hand := look.get_parent() as Hand
		var state: StringName = &"rise" if hand.age < 1.0 else &"hold"
		if hand.age >= 2.5:
			state = &"sink"
		if state != _shown and look.sprite_frames.has_animation(state):
			_shown = state
			look.play_anim(state)


class Band:
	extends Hitbox
	var age := 0.0

	func _ready() -> void:
		team = Layers.Team.ENEMY
		damage = 3
		kind = &"chain_lash"
		super()
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(96, 768)
		shape.shape = rectangle
		add_child(shape)
		var look := BandPresentation.new()
		look.name = "Visual"
		add_child(look)

	func _physics_process(delta: float) -> void:
		age += delta
		if age >= 0.8 and not active:
			activate()
		super(delta)
		if age >= 1.0:
			queue_free()
		queue_redraw()

class BandPresentation:
	extends Node2D
	var picture: Sprite2D

	func _ready() -> void:
		var material := CanvasItemMaterial.new()
		material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		self.material = material
		picture = Sprite2D.new()
		picture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		picture.use_parent_material = true
		var path := "res://assets/sprites/unlit_chain_lash_z1_idle.png"
		if ResourceLoader.exists(path):
			picture.texture = load(path) as Texture2D
		add_child(picture)

	func _process(_delta: float) -> void:
		var band := get_parent() as Band
		picture.visible = band.age >= 0.8
		queue_redraw()

	func _draw() -> void:
		var band := get_parent() as Band
		var active := band.age >= 0.8
		var bounds := Rect2(-48, -384, 96, 768)
		if not active or picture.texture == null:
			draw_rect(bounds, Color(0.8, 0.56, 0.22, 0.12 if not active else 0.5))
		draw_rect(bounds, Color(1.0, 0.76, 0.35, 0.9 if active else 0.65), false, 3.0)
