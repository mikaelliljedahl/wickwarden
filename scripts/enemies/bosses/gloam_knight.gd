extends "res://scripts/enemies/boss_base.gd"
## Five islands, a fixed takeoff marker, and a one-second landing opening.
## Persistent cave rewards are authored by C07, never by this encounter.

const ISLANDS := [
	Rect2(672, 96, 576, 192),
	Rect2(672, 384, 576, 192),
	Rect2(672, 672, 576, 192),
	Rect2(96, 288, 480, 384),
	Rect2(1344, 288, 480, 384)
]
const CENTRES := [
	Vector2(960, 192), Vector2(960, 480), Vector2(960, 768), Vector2(336, 480), Vector2(1584, 480)
]
var arena: Node2D
var mode := &"ready"
var mode_left := 0.0
var dive_left := 6.0
var lance_left := 2.5
var combos := 0
var slash_count := 0
var slash_left := 0.0
var aim := Vector2.DOWN
var target := Vector2.ZERO
var _home := Vector2.ZERO
var _origin := Vector2.ZERO


class ArenaPit:
	extends "res://scripts/world/pit_zone.gd"
	# Room-local: pits outlive the boss templates and live clones.
	var entry := Vector2.ZERO

	func _fall(player: Player) -> void:
		if player.take_fall_damage(self) and not player.is_dead():
			player.place_at(_owning_room().to_global(entry))


class AttackVisual:
	extends Node2D
	var impact_texture: Texture2D
	var wave_texture: Texture2D

	func _ready() -> void:
		var path := ""
		if get_parent().kind == &"impact":
			path = "res://assets/sprites/colossus_quake_z1_idle.png"
		elif get_parent().kind == &"ring":
			path = "res://assets/sprites/unlit_wax_wave_z1_idle.png"
		if path != "" and ResourceLoader.exists(path):
			var texture := load(path) as Texture2D
			if get_parent().kind == &"impact":
				impact_texture = texture
			else:
				wave_texture = texture

	func _draw() -> void:
		var attack = get_parent()
		var color := Color(0.65, 0.5, 0.9, 0.65)
		var edge := Color(0.83, 0.75, 1.0, 0.9)
		if attack.kind == &"ring":
			var radius: float = attack.radius()
			var inner := maxf(0.0, radius - 12.0)
			var outer := radius + 12.0
			if wave_texture != null and radius > 1.0:
				for i in range(96):
					var a := Vector2.from_angle(TAU * i / 96.0)
					var b := Vector2.from_angle(TAU * (i + 1) / 96.0)
					var points := PackedVector2Array([a * inner, b * inner, b * outer, a * outer])
					var u := float(i) / 96.0
					var v := float(i + 1) / 96.0
					var uv := PackedVector2Array(
						[Vector2(u, 0), Vector2(v, 0), Vector2(v, 1), Vector2(u, 1)]
					)
					draw_polygon(
						points, PackedColorArray([Color(0.65, 0.53, 1.0)]), uv, wave_texture
					)
			else:
				draw_arc(Vector2.ZERO, radius, 0, TAU, 64, color, 24)
			if inner > 0.0:
				draw_arc(Vector2.ZERO, inner, 0, TAU, 96, edge, 2.0)
			draw_arc(Vector2.ZERO, outer, 0, TAU, 96, edge, 2.0)
		elif attack.kind == &"slash":
			var start: float = attack.direction.angle() - PI / 3.0
			var finish: float = attack.direction.angle() + PI / 3.0
			# A brief blade glint keeps the attack readable without a solid filled sector.
			draw_arc(Vector2.ZERO, 130.0, start, finish, 48, Color(0.42, 0.32, 0.68, 0.45), 36.0)
			draw_arc(Vector2.ZERO, 130.0, start, finish, 48, Color(0.72, 0.68, 0.94, 0.75), 12.0)
			draw_arc(Vector2.ZERO, 130.0, start, finish, 48, Color(0.96, 0.94, 1.0, 0.9), 3.0)
			# Trace the full 120-degree collision sector without obscuring the floor.
			draw_line(Vector2.ZERO, Vector2.from_angle(start) * 150.0, edge, 2.0)
			draw_line(Vector2.ZERO, Vector2.from_angle(finish) * 150.0, edge, 2.0)
			draw_arc(Vector2.ZERO, 150.0, start, finish, 48, edge, 2.0)
		else:
			if impact_texture != null:
				draw_texture_rect(
					impact_texture, Rect2(-130, -130, 260, 260), false, Color(0.65, 0.53, 1.0)
				)
			else:
				draw_circle(Vector2.ZERO, 130, color)
			draw_arc(Vector2.ZERO, 130, 0, TAU, 96, edge, 2.0)


class Attack:
	extends Node2D
	var kind := &"impact"
	var direction := Vector2.DOWN
	var age := 0.0
	var box: Hitbox
	var beads: Array[CollisionShape2D] = []
	var island := Rect2()

	func radius() -> float:
		return minf(age / 0.4, 1) * 260

	func _ready() -> void:
		var picture := AttackVisual.new()
		picture.name = "Visual"
		add_child(picture)
		box = Hitbox.new()
		box.team = Layers.Team.ENEMY
		box.source = self
		box.kind = kind
		box.damage = 2 if kind == &"ring" else (3 if kind == &"slash" else 4)
		box.blockable = false
		box.knockback = 0
		if kind == &"ring":
			for i in range(64):
				beads.append(box.add_circle(12))
		elif kind == &"slash":
			var shape := ConvexPolygonShape2D.new()
			var points := PackedVector2Array([Vector2.ZERO])
			for i in range(25):
				points.append(direction.rotated(deg_to_rad(-60 + i * 5)) * 150)
			shape.points = points
			var collision := CollisionShape2D.new()
			collision.shape = shape
			box.add_child(collision)
		else:
			box.add_circle(130)
		add_child(box)
		box.activate()

	func _physics_process(delta: float) -> void:
		age += delta
		if kind == &"ring":
			for i in range(beads.size()):
				beads[i].position = Vector2.from_angle(TAU * i / beads.size()) * radius()
				beads[i].disabled = not island.has_point(global_position + beads[i].position)
		get_node("Visual").queue_redraw()
		if age >= (0.4 if kind == &"ring" else 0.05):
			box.deactivate()
			queue_free()


func _init() -> void:
	boss_id = &"gloam_knight"
	arena_id = &"cave_7_11"
	max_hp = 36
	thresholds = [18]
	body_radius = 44
	contact_damage = 3
	move_speed = 0
	stun_scale = 0
	knockback_scale = 0
	drops_enabled = false
	arena_lock = false
	death_drops = []
	visual_kind = &"gloam_knight"
	if not Placeholder.has_kind(visual_kind):
		Placeholder.register_kind(
			visual_kind,
			{"shape": "rect", "color": Color(0.23, 0.17, 0.34), "size": Vector2(72, 112)}
		)


func _ready() -> void:
	super._ready()
	# The arena also keeps its pit behavior when the persistent boss is retired.
	var room := _room()
	if room == null:
		return
	_origin = room.global_position
	for candidate in room.get_node("Props").get_children():
		if candidate.scene_file_path == "res://scenes/bosses/gloam_knight_arena.tscn":
			arena = candidate as Node2D
			break
	if arena == null:
		return
	if arena.has_meta("pits_built"):
		_set_sides(is_dead)
		return
	arena.set_meta("pits_built", true)
	for template in arena.get_children():
		if not template.has_meta("pit_size"):
			continue
		var pit := ArenaPit.new()
		pit.name = template.name + "Zone"
		pit.size = template.get_meta("pit_size")
		# Room._ready translates the room after its children build these pits.
		# Keep the destination room-local, independent of the boss respawn clone.
		pit.entry = CENTRES[0]
		pit.position = template.position
		pit.set_meta("side_island", template.has_meta("side_island"))
		pit.process_mode = (
			Node.PROCESS_MODE_DISABLED
			if template.has_meta("side_island")
			else Node.PROCESS_MODE_INHERIT
		)
		pit.visible = not template.has_meta("side_island")
		arena.add_child(pit)
		if template.has_meta("side_island"):
			pit.remove_from_group(&"pit_zone")
	if is_dead:
		_set_sides(true)


func _boss_ready() -> void:
	if visual is SpriteVisual:
		visual.auto_motion = false
	_home = global_position
	contact_hitbox.knockback = 0


func _enter_phase(number: int) -> void:
	mode = &"ready"
	mode_left = 0
	dive_left = 4.0 if number == 2 else 6.0
	lance_left = 2.5
	combos = 0
	slash_count = 0
	visible = true
	visual.scale = Vector2.ONE
	if number == 2:
		_set_sides(true)
		global_position = arena_point(CENTRES[1])


func island_at(point: Vector2) -> int:
	var local := point - _origin
	for i in range(3 if phase == 2 else 5):
		if ISLANDS[i].has_point(local):
			return i
	return -1


func _boss_physics(delta: float) -> void:
	# Facing is presentation only; aim remains fixed throughout an attack.
	if mode == &"ready" and visual.has_method("set_facing"):
		visual.call("set_facing", direction_to_player())
	dive_left -= delta
	lance_left -= delta
	mode_left -= delta
	match mode:
		&"crouch":
			if mode_left <= 0:
				_takeoff()
		&"air":
			if mode_left <= 0:
				_land()
		&"recover":
			if mode_left <= 0:
				mode = &"ready"
		&"lance":
			if mode_left <= 0:
				_fire_lance()
				mode = &"ready"
		&"combo":
			_tick_combo(delta)
		_:
			if dive_left <= 0 or combos >= 2:
				_start_dive()
			elif island_at(player_position(global_position)) == island_at(global_position):
				_start_combo()
			elif lance_left <= 0:
				aim = direction_to_player()
				mode = &"lance"
				mode_left = 0.5
				lance_left = 3
				_warning(global_position, 0.5, &"cone", 150)
	_sync_visual()


func _sync_visual() -> void:
	if not visual is SpriteVisual:
		return
	var painted := visual as SpriteVisual
	if mode == &"crouch" and painted.sprite_frames.has_animation(&"crouch_side"):
		var dir := direction_to_player()
		painted.set_facing(Vector2.LEFT if dir.x < 0.0 else Vector2.RIGHT)
		if painted.animation != &"crouch_side":
			painted.play_anim(&"crouch_side")
	elif mode == &"ready" and velocity.length() > 1.0:
		painted.set_facing(velocity)
		painted.play_anim(&"walk_side")
	else:
		painted.play_anim(&"idle")


func _start_dive() -> void:
	mode = &"crouch"
	mode_left = 0.5
	dive_left = 4.0 if phase == 2 else 6.0
	combos = 0
	if not visual is SpriteVisual or not visual.sprite_frames.has_animation(&"crouch_side"):
		visual.scale = Vector2(1.2, 0.7)


func _takeoff() -> void:
	mode = &"air"
	mode_left = 0.5
	target = player_position(global_position)
	invulnerable = true
	hurtbox.enabled = false
	set_contact_enabled(false)
	visible = false
	_warning(target, 0.7, &"circle", 130)


func _land() -> void:
	mode = &"recover"
	mode_left = 1
	global_position = target
	visible = true
	visual.scale = Vector2.ONE
	invulnerable = false
	hurtbox.enabled = true
	set_contact_enabled(true)
	_attack(&"impact", target)
	if phase == 2:
		_attack(&"ring", target)


func _start_combo() -> void:
	mode = &"combo"
	mode_left = 0.5
	slash_left = 0.5
	slash_count = 0
	aim = direction_to_player()
	_warning(global_position, 0.5, &"cone", 150)


func _tick_combo(delta: float) -> void:
	slash_left -= delta
	if slash_left <= 0:
		_attack(&"slash", global_position)
		slash_count += 1
		slash_left += 0.3
		if slash_count == 2:
			combos += 1
			mode = &"ready"


func _attack(kind: StringName, at: Vector2) -> void:
	var attack := Attack.new()
	attack.kind = kind
	attack.direction = aim
	var index := island_at(at)
	if index >= 0:
		attack.island = Rect2(_origin + ISLANDS[index].position, ISLANDS[index].size)
	get_parent().add_child(attack)
	attack.global_position = at
	add_hazard(attack)


func _fire_lance() -> void:
	var bolt := EnemyProjectile.new()
	bolt.speed = 420
	bolt.damage = 2
	bolt.knockback = 0
	bolt.visual_kind = &"gloam_lance"
	if not Placeholder.has_kind(&"gloam_lance"):
		Placeholder.register_kind(
			&"gloam_lance",
			{"shape": "rect", "color": Color(0.7, 0.6, 0.9), "size": Vector2(36, 10)}
		)
	get_parent().add_child(bolt)
	bolt.launch(global_position, aim)
	add_hazard(bolt)


func _warning(at: Vector2, duration: float, shape: StringName, radius: float) -> void:
	var packed := load("res://scenes/enemies/telegraph.tscn") as PackedScene
	if packed == null:
		return
	var marker = packed.instantiate()
	marker.shape = shape
	marker.radius = radius
	marker.arc_deg = 120
	marker.facing = aim
	marker.duration = duration
	# The arena is dark: briefly light the warning and the knight, without
	# joining glow_light (which is reserved for the jar's gameplay effects).
	var light := PointLight2D.new()
	light.name = "WarningLight"
	light.texture = LightTexture.make()
	light.texture_scale = LightTexture.scale_for(radius + 70.0)
	light.color = Color(0.85, 0.65, 1.0)
	light.energy = 0.8
	marker.add_child(light)
	get_parent().add_child(marker)
	marker.global_position = at
	marker.start()
	add_hazard(marker)


func _set_sides(collapsed: bool) -> void:
	if not is_instance_valid(arena):
		return
	for pit in arena.get_children():
		if pit is ArenaPit and pit.get_meta("side_island", false):
			pit.process_mode = (
				Node.PROCESS_MODE_INHERIT if collapsed else Node.PROCESS_MODE_DISABLED
			)
			pit.visible = collapsed
			if collapsed:
				pit.add_to_group(&"pit_zone")
			else:
				pit.remove_from_group(&"pit_zone")


func _on_hurt(hit: Hitbox) -> void:
	super._on_hurt(hit)
	if is_dying():
		set_contact_enabled(false)
		visible = true


func reset_fight() -> void:
	if is_dead or is_defeated():
		return
	super.reset_fight()
	global_position = _home
	visible = true
	visual.scale = Vector2.ONE
	mode = &"ready"
	_set_sides(false)


func _on_death() -> void:
	super._on_death()
	spawn_pickup(&"ember", ARENA_CENTRE, true)
	spawn_pickup(&"ember", ARENA_CENTRE + Vector2(192, 0), true)
