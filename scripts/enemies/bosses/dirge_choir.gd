extends "res://scripts/enemies/boss_base.gd"
## Three stationary singers. Only a timely chime opens their mouths; rewards are room-owned.

const HEAD_POINTS := [Vector2(336, 720), Vector2(1008, 720), Vector2(1584, 720)]
const CHOIRLING := "res://scenes/enemies/choirling.tscn"
var heads: Array[EnemyBase] = []
var singers: Array[EnemyBase] = []
var song_left := 0.0
var song_index := 0
var _origin := Vector2.ZERO
var _pending_death := false


class Head:
	extends "res://scripts/enemies/boss_part.gd"
	var choir: EnemyBase
	var voice := 0
	var song_age := -1.0
	var open_left := 0.0
	var deaf_left := 0.0
	var attack: Node2D
	var songs: Array[Node2D] = []

	func _init() -> void:
		max_hp = 12
		body_radius = 48
		contact_damage = 2
		stun_scale = 0
		knockback_scale = 0
		drops_enabled = false
		visual_kind = &"choir_head"

	func _enemy_ready() -> void:
		if (
			not is_instance_valid(choir)
			or not choir.is_inside_tree()
			or choir.is_queued_for_deletion()
		):
			set_contact_enabled(false)
			queue_free()
			return
		hurtbox.filter = _accept
		set_contact_enabled(false)

	func _accept(_hit: Hitbox) -> bool:
		return is_instance_valid(choir) and choir.call(&"heads_active")

	func _enemy_physics(delta: float) -> void:
		if (
			not is_instance_valid(choir)
			or not choir.is_inside_tree()
			or choir.is_queued_for_deletion()
		):
			queue_free()
			return
		velocity = Vector2.ZERO
		var active := is_instance_valid(choir) and bool(choir.call(&"heads_active"))
		set_contact_enabled(active)
		if not active:
			return
		if open_left > 0:
			open_left = maxf(0, open_left - delta)
			if open_left == 0:
				deaf_left = 3.0
		else:
			deaf_left = maxf(0, deaf_left - delta)
		if song_age >= 0:
			song_age += delta
			if song_age >= 1.8:
				song_age = -1
		queue_redraw()

	func begin_song() -> void:
		if is_dead or open_left > 0:
			return
		song_age = 0
		attack = choir.call(&"make_song", self, voice)
		songs.append(attack)

	func cancel_song() -> void:
		song_age = -1
		for song in songs:
			if is_instance_valid(song):
				song.queue_free()
		songs = []
		attack = null

	func _resolve_damage(hit: Hitbox, _amount: int) -> int:
		if hit.kind == &"chime":
			if song_age >= 0 and song_age < 1.8 and open_left <= 0 and deaf_left <= 0:
				if global_position.distance_to(hit.origin()) <= 480.0:
					cancel_song()
					open_left = 4.0
			return 0
		if open_left <= 0:
			return 0
		if hit.kind == &"hook":
			return 2
		if hit.kind == &"flare":
			return 4
		return _amount

	func _draw() -> void:
		if song_age >= 0:
			var color := [Color(0.9, 0.6, 0.2), Color(0.3, 0.8, 0.9), Color(0.8, 0.4, 0.8)]
			draw_arc(Vector2.ZERO, 64, 0, TAU, 48, color[voice], 6)
		if open_left > 0:
			draw_arc(Vector2.ZERO, 58, 0, TAU * open_left / 4.0, 48, Color(1, 0.9, 0.4), 5)


class Note:
	extends EnemyProjectile
	var health: Hurtbox

	func _ready() -> void:
		super._ready()
		health = Hurtbox.new()
		health.team = Layers.Team.ENEMY
		health.add_circle(16)
		health.hurt.connect(_struck)
		add_child(health)

	func _struck(hit: Hitbox) -> void:
		if hit.kind == &"hook" and hit.damage > 0:
			destroy(&"hit")


class SongVisual:
	extends Node2D

	func _draw() -> void:
		var song: Node2D = get_parent()
		var color := Color(0.95, 0.75, 0.35, 0.45)
		if song.voice == 0:
			var radius := maxf(56, song.progress() * 640)
			draw_arc(
				Vector2.ZERO,
				radius,
				song.aim + deg_to_rad(25),
				song.aim + TAU - deg_to_rad(25),
				80,
				color,
				64 if song.age >= 0.8 else 5
			)
		elif song.voice == 1:
			var points := PackedVector2Array([Vector2.ZERO])
			for step in range(17):
				points.append(Vector2.from_angle(song.angle() - PI / 12 + step * PI / 96) * 720)
			draw_colored_polygon(points, color)
		else:
			draw_arc(Vector2.ZERO, 64, 0, TAU, 48, color, 5)


class Song:
	extends Node2D
	var choir: EnemyBase
	var head: EnemyBase
	var voice := 0
	var age := 0.0
	var aim := 0.0
	var box: Hitbox
	var fired := false

	func _ready() -> void:
		var picture := SongVisual.new()
		picture.name = "Visual"
		add_child(picture)

	func progress() -> float:
		return clampf(age - 0.8, 0, 1)

	func angle() -> float:
		return aim + deg_to_rad(90) * progress()

	func _physics_process(delta: float) -> void:
		if not is_instance_valid(head) or head.is_dead:
			queue_free()
			return
		age += delta
		if age >= 0.8:
			if not fired:
				fired = true
				aim = (head.player_position(global_position) - global_position).angle()
				if voice == 2:
					choir.call(&"fire_notes", head, aim)
				else:
					box = Hitbox.new()
					box.team = Layers.Team.ENEMY
					box.kind = &"song"
					box.damage = 3 if voice == 0 else 2
					box.blockable = true
					box.block_destroys_carrier = false
					box.source = head
					box.knockback = 0
					add_child(box)
					box.activate()
			if box != null:
				_shape()
		get_node("Visual").queue_redraw()
		if age >= 1.8:
			queue_free()

	func _shape() -> void:
		# Convex annulus slices avoid repeatedly decomposing one concave moving polygon.
		var count := 48 if voice == 0 else 1
		while box.get_child_count() < count:
			box.add_child(CollisionPolygon2D.new())
		if voice == 0:
			var radius := progress() * 640
			var inner := maxf(0.1, radius - 32)
			var outer := radius + 32
			for step in range(count):
				var a := aim + deg_to_rad(25) + deg_to_rad(310) * step / count
				var b := aim + deg_to_rad(25) + deg_to_rad(310) * (step + 1) / count
				var slice := box.get_child(step) as CollisionPolygon2D
				slice.polygon = PackedVector2Array(
					[
						Vector2.from_angle(a) * inner,
						Vector2.from_angle(a) * outer,
						Vector2.from_angle(b) * outer,
						Vector2.from_angle(b) * inner
					]
				)
		else:
			var points := PackedVector2Array([Vector2.ZERO])
			for step in range(17):
				points.append(Vector2.from_angle(angle() - PI / 12 + step * PI / 96) * 720)
			(box.get_child(0) as CollisionPolygon2D).polygon = points


func _init() -> void:
	boss_id = &"dirge_choir"
	arena_id = &"cave_6_11"
	max_hp = 36
	body_radius = 1
	contact_damage = 0
	drops_enabled = false
	stun_scale = 0
	knockback_scale = 0
	arena_lock = false
	death_drops = []
	visual_kind = &"dirge_choir"
	for kind in [&"dirge_choir", &"choir_head", &"treble_note"]:
		if not Placeholder.has_kind(kind):
			Placeholder.register_kind(
				kind,
				{
					"shape": "circle",
					"color": Color(0.6, 0.45, 0.65),
					"radius": 48 if kind == &"choir_head" else 12
				}
			)


func _boss_ready() -> void:
	var room := _room()
	_origin = room.global_position if room != null else get_parent().global_position
	call_deferred(&"_spawn_heads")
	visual.visible = false


func _spawn_heads() -> void:
	if not is_inside_tree() or is_queued_for_deletion():
		return
	heads = []
	for i in range(3):
		var head := Head.new()
		head.voice = i
		head.choir = self
		adopt_part(head, arena_point(HEAD_POINTS[i]))
		heads.append(head)


func arena_point(local: Vector2) -> Vector2:
	return _origin + local


func heads_active() -> bool:
	return _fight_started and not is_pausing() and not is_dying() and not is_dead


func _enter_phase(number: int) -> void:
	song_left = 0
	song_index = 0
	for head in heads:
		if is_instance_valid(head) and not head.is_dead:
			head.cancel_song()
	if number == 3:
		var scene := load(CHOIRLING) as PackedScene
		if scene != null:
			for at in [Vector2(576, 288), Vector2(1344, 288)]:
				var singer := scene.instantiate() as EnemyBase
				if singer != null:
					singer.drops_enabled = false
					adopt_deferred(singer, arena_point(at))
					add_hazard(singer)
					singers.append(singer)


func _boss_physics(delta: float) -> void:
	if _pending_death:
		_pending_death = false
		hp = 1
		_begin_death()
		return
	song_left -= delta
	if song_left > 0:
		return
	song_left += 1.0 if phase == 3 else 1.5
	var alive := parts()
	if alive.is_empty():
		return
	if phase == 1:
		alive[song_index % alive.size()].begin_song()
		song_index += 1
	else:
		for head in alive:
			head.begin_song()


func make_song(head: EnemyBase, voice: int) -> Song:
	var song := Song.new()
	song.head = head
	song.choir = self
	song.voice = voice
	song.aim = (head.player_position(head.global_position) - head.global_position).angle()
	song.position = get_parent().to_local(head.global_position)
	get_parent().add_child(song)
	add_hazard(song)
	return song


func fire_notes(head: EnemyBase, aim: float) -> void:
	for offset in [-0.2, 0.0, 0.2]:
		var note := Note.new()
		note.speed = 220
		note.damage = 2
		note.homing_turn_deg = 120
		note.lifetime = 3.0
		note.radius = 12
		note.visual_kind = &"treble_note"
		note.room_rect = room_rect
		note.position = get_parent().to_local(head.global_position)
		get_parent().add_child(note)
		note.launch(head.global_position, Vector2.from_angle(aim + offset))
		add_hazard(note)


func _resolve_damage(_hit: Hitbox, _amount: int) -> int:
	return 0


func _on_part_hurt(_amount: int, _part: EnemyBase) -> void:
	hp = 0
	for head in heads:
		if is_instance_valid(head):
			hp += maxi(head.hp, 0)
	if hp == 0:
		_pending_death = true


func _on_part_defeated(_part: EnemyBase) -> void:
	if is_dying() or is_dead or parts().is_empty():
		return
	_start_phase(4 - parts().size())


func reset_fight() -> void:
	if is_defeated():
		return
	super.reset_fight()
	singers = []
	_pending_death = false
	_spawn_heads()
	song_left = 0
	song_index = 0


func _on_death() -> void:
	super._on_death()
	spawn_pickup(&"ember", ARENA_CENTRE + Vector2(-96, 0), true)
	spawn_pickup(&"ember", ARENA_CENTRE + Vector2(96, 0), true)


func _exit_tree() -> void:
	clear_hazards()
	super._exit_tree()
