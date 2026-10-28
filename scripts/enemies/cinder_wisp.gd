extends EnemyBase
## Cinder wisp (monsters-bosses-tools.md, 2.1): a floating bomb. HP 2, contact 1, speed 100. It drifts toward
## Tamsin with a sine wobble (amplitude 40 px, period 1.2 s) and lights a 140 px radius around itself. Within
## 150 px of Tamsin it winds up for 0.5 s (it stops, swells to 1.6x, glows white; the telegraph is a 150 px
## circle), then bursts into a flame ring (flame_ring.gd: radius 150, damage 2, 0.2 s). The burst consumes the
## wisp, so it drops nothing. A kill during the wind-up cancels the burst and it drops normally. A moth stun
## cancels the wind-up; after the stun it drifts again and winds up again in range. Immune to fire.
## Ward: the burst is an area hit, negated when the wisp stands in Tamsin's front 120 degrees.
## It does NOT declare a class_name.

const FLAME_RING := preload("res://scripts/enemies/flame_ring.gd")
const TELEGRAPH_SCENE := "res://scenes/enemies/telegraph.tscn"
const WOBBLE_AMPLITUDE := 40.0
const WOBBLE_PERIOD := 1.2
const TRIGGER_RANGE := 150.0
const WINDUP_TIME := 0.5
const SWELL_SCALE := 1.6
const GLOW_WHITE := Color(2.5, 2.5, 2.5)
const LIGHT_RADIUS := 140.0
const LIGHT_COLOR := Color(1.0, 0.6, 0.25)

var _age: float = 0.0
## The wind-up telegraph while the wisp winds up; null otherwise.
var _telegraph: Node2D = null
var _warning_visual: Node2D = null


class WindupVisual:
	extends Node2D
	var timer: Node2D
	var flame: SpriteVisual

	func _ready() -> void:
		var boundary_material := CanvasItemMaterial.new()
		boundary_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		material = boundary_material
		if SpriteVisual.has_art(&"fx_wisp_burst"):
			var picture := SpriteVisual.attach(self, &"fx_wisp_burst")
			if picture is SpriteVisual:
				flame = picture as SpriteVisual
				if (
					flame.sprite_frames.has_animation(&"idle")
					and flame.sprite_frames.get_frame_count(&"idle") >= 2
				):
					flame.stop()
					flame.set_frame_and_progress(1, 0.0)
					flame.scale = Vector2.ONE * 0.65
				else:
					flame.queue_free()
					flame = null
		_update_look()

	func _process(_delta: float) -> void:
		_update_look()

	func _update_look() -> void:
		if not is_instance_valid(timer):
			return
		var progress := float(timer.call(&"progress"))
		if flame != null:
			flame.modulate = Color(1.0, 0.85, 0.65, lerpf(0.25, 0.55, progress))
		queue_redraw()

	func _draw() -> void:
		# The steady edge denotes the future 150 px hit radius, not an active hitbox.
		draw_arc(
			Vector2.ZERO, FLAME_RING.RADIUS, 0.0, TAU, 96, Color(1.0, 0.9, 0.65, 0.9), 2.0, true
		)


func _init() -> void:
	_register_kinds()
	max_hp = 2
	contact_damage = 1
	move_speed = 100.0
	visual_kind = &"cinder_wisp"
	body_radius = 24.0
	ignore_water = true


func _enemy_ready() -> void:
	var light := PointLight2D.new()
	light.name = "Glow"
	light.texture = LightTexture.make()
	light.texture_scale = LightTexture.scale_for(LIGHT_RADIUS)
	light.color = LIGHT_COLOR
	add_child(light)


func _enemy_physics(delta: float) -> void:
	if _telegraph != null:
		velocity = Vector2.ZERO
		_show_windup()
		return
	_age += delta
	var to_player := direction_to_player()
	var wobble := cos(TAU * _age / WOBBLE_PERIOD) * WOBBLE_AMPLITUDE * TAU / WOBBLE_PERIOD
	velocity = to_player * move_speed + to_player.orthogonal() * wobble
	if _player_distance() <= TRIGGER_RANGE:
		_start_windup()


## A moth stun cancels the wind-up (the telegraph goes, the look resets).
func _on_stunned(_seconds: float) -> void:
	_cancel_windup()


## Fire does nothing to a wisp (immune). Every other hit goes through the base rules.
func _resolve_damage(hitbox: Hitbox, amount: int) -> int:
	if hitbox.kind == &"fire":
		return 0
	return amount


## Starts the wind-up telegraph: a 150 px circle that fills over WINDUP_TIME, then `_on_windup_finished`.
func _start_windup() -> void:
	var scene := load(TELEGRAPH_SCENE) as PackedScene
	if scene == null:
		push_error("CinderWisp: missing telegraph scene %s" % TELEGRAPH_SCENE)
		return
	var telegraph := scene.instantiate() as Node2D
	telegraph.set(&"radius", FLAME_RING.RADIUS)
	telegraph.set(&"duration", WINDUP_TIME)
	telegraph.set(&"color", Color(1.0, 0.97, 0.85))
	add_child(telegraph)
	telegraph.connect(&"finished", _on_windup_finished)
	telegraph.call(&"start")
	if visual is SpriteVisual:
		var sprite := visual as SpriteVisual
		sprite.auto_motion = false
		sprite.play_anim(&"swell")
	# Keep the shared timer and its finished signal, but replace only its drawing.
	telegraph.visible = false
	_telegraph = telegraph
	var warning := WindupVisual.new()
	warning.name = "WindupVisual"
	warning.timer = telegraph
	add_child(warning)
	_warning_visual = warning


func _on_windup_finished() -> void:
	_telegraph = null
	_clear_warning_visual()
	if is_dead:
		return
	var holder := get_parent()
	if holder != null:
		var ring := FLAME_RING.new() as Hitbox
		ring.source = self
		holder.add_child(ring)
		ring.global_position = global_position
	# The burst consumes the wisp: no drop, but the death effect plays.
	drops_enabled = false
	kill()


func _cancel_windup() -> void:
	if is_instance_valid(_telegraph):
		_telegraph.queue_free()
	_telegraph = null
	_clear_warning_visual()
	if visual != null:
		visual.scale = Vector2.ONE
		visual.modulate = Color.WHITE
		if visual is SpriteVisual:
			var sprite := visual as SpriteVisual
			sprite.play_anim(&"idle")
			sprite.auto_motion = true


func _clear_warning_visual() -> void:
	if is_instance_valid(_warning_visual):
		_warning_visual.queue_free()
	_warning_visual = null


## Presentation only: swell and glow with the telegraph's progress.
func _show_windup() -> void:
	if visual == null or _telegraph == null:
		return
	var progress := float(_telegraph.call(&"progress"))
	visual.scale = Vector2.ONE * lerpf(1.0, SWELL_SCALE, progress)
	visual.modulate = Color.WHITE.lerp(GLOW_WHITE, progress)


func _player_distance() -> float:
	if get_player() == null:
		return INF
	return global_position.distance_to(player_position(global_position))


static func _register_kinds() -> void:
	if not Placeholder.has_kind(&"cinder_wisp"):
		Placeholder.register_kind(
			&"cinder_wisp", {"shape": "diamond", "color": Color(1.0, 0.55, 0.2), "radius": 24.0}
		)
