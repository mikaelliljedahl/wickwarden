extends "res://scripts/enemies/boss_base.gd"
## Free reel pulls remove armour. Persistent rewards belong to the cave room.

const HEAPS := [Vector2(288, 288), Vector2(288, 672), Vector2(1056, 480), Vector2(1536, 672)]
const FRONT_BITE_DOT := 0.9659258  # Within 15 degrees of the drawn downward facing.
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


class PlateCue:
	extends Node2D
	var crown := false

	func _draw() -> void:
		# A cool rim separates the removable gold from the head's permanent scales.
		var color := Color(0.48, 0.95, 0.91, 0.95)
		draw_arc(Vector2.ZERO, 31.0, 0.0, TAU, 40, Color(0.03, 0.17, 0.18, 0.9), 6.0)
		draw_arc(Vector2.ZERO, 31.0, 0.0, TAU, 40, color, 2.5)
		if crown:
			var points := PackedVector2Array(
				[Vector2(-12, -31), Vector2(-7, -41), Vector2(0, -35), Vector2(7, -41), Vector2(12, -31)]
			)
			draw_polyline(points, color, 3.0, true)


class Strike:
	extends Node2D
	var box: Hitbox
	var life := 0.12
	var tail := false
	var facing := Vector2.RIGHT

	class TailVisual:
		extends Node2D

		func _draw() -> void:
			draw_rect(Rect2(-864, -48, 1728, 96), Color(1.0, 0.82, 0.35, 0.9), false, 4.0)

	class BiteVisual:
		extends Node2D
		var facing := Vector2.RIGHT

		func _ready() -> void:
			# The existing painted coin impact gives the bite a short scatter of gold.
			if not SpriteVisual.has_art(&"coinwyrm_coin"):
				return
			for angle in [-PI / 3, 0.0, PI / 3]:
				var holder := Node2D.new()
				holder.position = facing.rotated(angle) * 112.0
				add_child(holder)
				var impact := SpriteVisual.attach(holder, &"coinwyrm_coin") as SpriteVisual
				impact.auto_motion = false
				impact.play_anim(&"impact")

		func _draw() -> void:
			# Keep the complete damage boundary visible without a solid sector over the art.
			var points := PackedVector2Array([Vector2.ZERO])
			for i in range(25):
				points.append(facing.rotated(-PI / 2 + PI * i / 24.0) * 150)
			points.append(Vector2.ZERO)
			draw_polyline(points, Color(1.0, 0.82, 0.35, 0.9), 4.0)

	func _ready() -> void:
		if tail:
			var visual := TailVisual.new()
			visual.name = "Visual"
			add_child(visual)
		else:
			var visual := BiteVisual.new()
			visual.name = "Visual"
			visual.facing = facing
			add_child(visual)
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
	if not Placeholder.has_kind(&"coinwyrm_coin"):
		Placeholder.register_kind(
			&"coinwyrm_coin", {"shape": "circle", "color": Color(0.8, 0.65, 0.25), "radius": 12}
		)


func _boss_ready() -> void:
	if visual is SpriteVisual:
		visual.auto_motion = false
		if not visual.animation_finished.is_connected(_head_animation_finished):
			visual.animation_finished.connect(_head_animation_finished)
	_home = global_position
	# Presentation-only illumination follows the visible head in the dark arena.
	if not has_node("HeadLight"):
		var light := PointLight2D.new()
		light.name = "HeadLight"
		light.texture = LightTexture.make()
		light.texture_scale = LightTexture.scale_for(180.0)
		light.color = Color(1.0, 0.75, 0.4)
		light.energy = 0.8
		add_child(light)


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
			_set_heap_animation(global_position, &"quiver")
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
	_set_heap_animation(global_position, &"burst")
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
		var kind := &"coinwyrm_crown" if slot == 3 else &"coinwyrm_plate"
		if SpriteVisual.has_art(kind):
			var painted := SpriteVisual.attach(plate, kind, 26.0) as SpriteVisual
			if painted != null and slot == 1:
				painted.flip_h = true
		var cue := PlateCue.new()
		cue.name = "PlateCue"
		cue.crown = slot == 3
		plate.add_child(cue)
		var light := PointLight2D.new()
		light.name = "PlateLight"
		light.texture = LightTexture.make()
		light.texture_scale = LightTexture.scale_for(80.0)
		light.color = Color(0.48, 0.95, 0.91)
		light.energy = 0.65
		plate.add_child(light)
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
	_head_idle()
	_clear_heap_cues()
	_clear_plates()
	state = &"burrow"
	state_left = delay
	bare = false
	visible = false
	hurtbox.enabled = false
	set_contact_enabled(false)


func _heap_visuals() -> Array[SpriteVisual]:
	var result: Array[SpriteVisual] = []
	var room := _room()
	if room == null:
		return result
	var props := room.get_node_or_null("Props")
	if props == null:
		return result
	for arena in props.get_children():
		for index in range(HEAPS.size()):
			var visual := arena.get_node_or_null("Heap%d/Visual" % index) as SpriteVisual
			if visual != null:
				result.append(visual)
	return result


func _set_heap_animation(at: Vector2, animation: StringName) -> void:
	for visual in _heap_visuals():
		if visual.global_position.distance_to(at) > 1.0:
			continue
		visual.play_anim(animation)
		if visual.get_node_or_null("CueLight") == null:
			var light := PointLight2D.new()
			light.name = "CueLight"
			light.texture = LightTexture.make()
			light.texture_scale = LightTexture.scale_for(130.0)
			light.color = Color(1.0, 0.72, 0.3)
			light.energy = 1.0
			visual.add_child(light)
		if animation == &"burst":
			var finished := _finish_heap_cue.bind(visual)
			if not visual.animation_finished.is_connected(finished):
				visual.animation_finished.connect(finished, CONNECT_ONE_SHOT)


func _finish_heap_cue(visual: SpriteVisual) -> void:
	if is_instance_valid(visual):
		var finished := _finish_heap_cue.bind(visual)
		if visual.animation_finished.is_connected(finished):
			visual.animation_finished.disconnect(finished)
		visual.play_anim(&"idle")
		var light := visual.get_node_or_null("CueLight")
		if light != null:
			light.queue_free()


func _clear_heap_cues() -> void:
	for visual in _heap_visuals():
		_finish_heap_cue(visual)


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
		bolt.visual_kind = &"coinwyrm_coin"
		bolt.blockable_by_ward = true
		get_parent().add_child(bolt)
		# Presentation only: coins must remain visible outside the lamp in the dark arena.
		var light := PointLight2D.new()
		light.name = "CoinLight"
		light.texture = LightTexture.make()
		light.texture_scale = LightTexture.scale_for(80.0)
		light.color = Color(1.0, 0.72, 0.3)
		light.energy = 0.9
		bolt.add_child(light)
		bolt.launch(global_position, direction.rotated(angle))
		bolt.destroyed.connect(_coin_impact.bind(bolt))
		add_hazard(bolt)


func _coin_impact(reason: StringName, bolt: EnemyProjectile) -> void:
	if reason not in [&"hit", &"wall", &"ward"] or not is_instance_valid(bolt):
		return
	var effect := SpriteVisual.spawn_effect(get_parent(), &"coinwyrm_coin", bolt.global_position)
	if effect is SpriteVisual:
		effect.play_anim(&"impact")


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
	_head_idle()
	# The authored head faces down; other directions use the directional strike effect.
	if direction.dot(Vector2.DOWN) >= FRONT_BITE_DOT and visual is SpriteVisual:
		visual.play_anim(&"bite_telegraph")
	var marker := _marker(at, &"cone", 0.5, 150, Vector2.ZERO, direction)
	if marker != null:
		_light_bite(marker, direction)
		marker.finished.connect(_strike.bind(at, direction, false))
	else:
		_head_idle()


func _light_bite(parent: Node2D, direction: Vector2) -> void:
	var light := PointLight2D.new()
	light.texture = LightTexture.make()
	light.texture_scale = LightTexture.scale_for(210.0)
	light.color = Color(1.0, 0.72, 0.3)
	light.energy = 0.8
	light.position = direction * 60.0
	parent.add_child(light)


func _tail() -> void:
	for heap in HEAPS:
		var origin := arena_point(heap)
		if origin.distance_to(global_position) < 10:
			continue
		var at := origin
		at.x = arena_point(ARENA_CENTRE).x
		var marker := _marker(at, &"rect", 0.7, 0, Vector2(1728, 96), Vector2.RIGHT)
		if marker != null:
			_light_tail_band(marker)
			if SpriteVisual.has_art(&"coinwyrm_tail"):
				var visual := SpriteVisual.attach(marker, &"coinwyrm_tail") as SpriteVisual
				visual.position = origin - at
				visual.play_anim(&"tell")
			marker.finished.connect(_strike.bind(at, Vector2.RIGHT, true, origin))
		return


func _light_tail_band(parent: Node2D) -> void:
	for x in range(-768, 769, 256):
		var light := PointLight2D.new()
		light.texture = LightTexture.make()
		light.texture_scale = LightTexture.scale_for(180.0)
		light.color = Color(1.0, 0.72, 0.3)
		light.energy = 0.7
		light.position.x = x
		parent.add_child(light)


func _strike(at: Vector2, direction: Vector2, tail: bool, origin := Vector2.INF) -> void:
	if is_dying() or is_dead or is_pausing() or state != &"rear":
		return
	if not tail and direction.dot(Vector2.DOWN) >= FRONT_BITE_DOT and visual is SpriteVisual:
		visual.play_anim(&"bite")
	var strike := Strike.new()
	strike.tail = tail
	strike.facing = direction
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
	if tail:
		_light_tail_band(strike)
		if SpriteVisual.has_art(&"coinwyrm_tail"):
			var holder := Node2D.new()
			get_parent().add_child(holder)
			holder.global_position = origin
			add_hazard(holder)
			var effect := SpriteVisual.attach(holder, &"coinwyrm_tail") as SpriteVisual
			effect.animation_finished.connect(_tail_animation_finished.bind(effect))
			effect.play_anim(&"sweep")
			var light := PointLight2D.new()
			light.texture = LightTexture.make()
			light.texture_scale = LightTexture.scale_for(150.0)
			light.color = Color(1.0, 0.72, 0.3)
			light.energy = 0.8
			holder.add_child(light)
	else:
		_light_bite(strike, direction)
	add_hazard(strike)


func _head_idle() -> void:
	if visual is SpriteVisual:
		visual.play_anim(&"idle")


func _head_animation_finished() -> void:
	if visual is SpriteVisual and visual.animation == &"bite":
		_head_idle()


func _tail_animation_finished(effect: SpriteVisual) -> void:
	if not is_instance_valid(effect):
		return
	if effect.animation == &"sweep":
		effect.play_anim(&"burrow")
	else:
		effect.get_parent().queue_free()


func _on_hurt(hit: Hitbox) -> void:
	super._on_hurt(hit)
	if is_dying():
		_head_idle()
		_clear_plates()
		set_contact_enabled(false)


func reset_fight() -> void:
	if is_dead or is_defeated():
		return
	_head_idle()
	_clear_plates()
	global_position = _home
	visible = true
	state = &"burrow"
	super.reset_fight()


func _on_death() -> void:
	super._on_death()
	spawn_pickup(&"ember", ARENA_CENTRE, true)
	spawn_pickup(&"ember", ARENA_CENTRE + Vector2(192, 0), true)
