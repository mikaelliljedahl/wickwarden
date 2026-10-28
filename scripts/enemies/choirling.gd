extends EnemyBase
## Choirling (monsters-bosses-tools section 2.1): a floating singer. It hovers 240 to 400 px from Tamsin:
## it backs off at 140 px/s when closer than 200 px and drifts in at its move speed when farther than
## 400 px. It flies, so it ignores deep water.
## Cycle 2.4 s: telegraph 0.6 s (a cone floor marker along its facing, drawn from its own position), then it
## sings a 60 degree cone of 420 px for 0.5 s (damage 2, once per target), then rests 1.3 s. It holds still
## while it sings. The cone is an area hit: a raised ward negates it and the singer survives.
## A stun (moth 2.0 s, chime 2.5 s) interrupts the song and starts the rest again.
## 2 hp, contact damage 1, speed 90. It does NOT declare a class_name (WP files must not; see docs/code-contract.md).

enum State { REST, TELEGRAPH, SING }

const TELEGRAPH_TIME := 0.6
const SING_TIME := 0.5
const REST_TIME := 1.3
const HOVER_NEAR := 200.0
const HOVER_FAR := 400.0
const BACK_OFF_SPEED := 140.0
const CONE_ANGLE := 60.0
const CONE_LENGTH := 420.0
const CONE_DAMAGE := 2
const CONE_KIND := &"song"
const CONE_SEGMENTS := 12
const CHIME_STUN := 2.5
const NOTE_KIND := &"note"


class SongWarning:
	extends Node2D
	var note_texture: Texture2D

	func _ready() -> void:
		note_texture = load("res://assets/sprites/treble_note_fly.png") as Texture2D
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		var light := CanvasItemMaterial.new()
		light.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		material = light

	func _draw() -> void:
		var half := deg_to_rad(CONE_ANGLE) * 0.5
		var edge := Color(1.0, 0.78, 0.43, 0.75)
		draw_line(Vector2.ZERO, Vector2.from_angle(-half) * CONE_LENGTH, edge, 2.0)
		draw_line(Vector2.ZERO, Vector2.from_angle(half) * CONE_LENGTH, edge, 2.0)
		draw_arc(Vector2.ZERO, CONE_LENGTH, -half, half, CONE_SEGMENTS, edge, 2.0)
		if note_texture != null:
			for i in range(3):
				var distance := 90.0 + i * 120.0
				var size := 55.0 + i * 25.0
				draw_texture_rect_region(
					note_texture, Rect2(distance - size / 2, -size / 2, size, size),
					Rect2(0, 0, 96, 96), Color(1, 1, 1, 0.65)
				)


var _state: State = State.REST
var _timer: float = REST_TIME
var _telegraph: Node2D
var _cone: Hitbox


func _init() -> void:
	max_hp = 2
	contact_damage = 1
	move_speed = 90.0
	visual_kind = &"choirling"
	body_radius = 24.0
	ignore_water = true
	chime_stun_time = CHIME_STUN
	_register_kinds()


static func _register_kinds() -> void:
	if not Placeholder.has_kind(&"choirling"):
		Placeholder.register_kind(
			&"choirling", {"shape": "circle", "color": Color(0.92, 0.9, 1.0), "radius": 24.0}
		)
	if not Placeholder.has_kind(NOTE_KIND):
		Placeholder.register_kind(
			NOTE_KIND, {"shape": "diamond", "color": Color(0.95, 0.9, 0.6), "radius": 14.0}
		)


func _enemy_physics(delta: float) -> void:
	_timer -= delta
	match _state:
		State.REST:
			velocity = _hover_velocity()
			var to_player := direction_to_player()
			if to_player != Vector2.ZERO:
				set_facing_dir(to_player)
			if _timer <= 0.0:
				_begin_telegraph()
		State.TELEGRAPH:
			velocity = Vector2.ZERO
			if _timer <= 0.0:
				_begin_sing()
		State.SING:
			velocity = Vector2.ZERO
			if _timer <= 0.0:
				_drop_cone()
				_set_state(State.REST, REST_TIME)


## A stun interrupts the telegraph or the song; the rest starts again.
func _on_stunned(_seconds: float) -> void:
	_drop_cone()
	_drop_telegraph()
	_set_state(State.REST, REST_TIME)


func _on_death() -> void:
	_drop_cone()
	_drop_telegraph()


## Velocity that keeps the hover band: back off inside 200 px, drift in beyond 400 px, else hold still.
func _hover_velocity() -> Vector2:
	var player := get_player()
	if player == null:
		return Vector2.ZERO
	var offset := player.global_position - global_position
	var dist := offset.length()
	if dist < HOVER_NEAR:
		return -offset.normalized() * BACK_OFF_SPEED
	if dist > HOVER_FAR:
		return offset.normalized() * move_speed
	return Vector2.ZERO


func _set_state(state: State, seconds: float) -> void:
	_state = state
	_timer = seconds


func _begin_telegraph() -> void:
	_set_state(State.TELEGRAPH, TELEGRAPH_TIME)
	_spawn_telegraph()


func _begin_sing() -> void:
	_drop_telegraph()
	_set_state(State.SING, SING_TIME)
	_cone = _make_cone()
	add_child(_cone)
	_cone.activate()


## The floor marker of the cone, a child of the singer (it follows it and is freed with it).
func _spawn_telegraph() -> void:
	var marker := SongWarning.new()
	marker.rotation = facing_dir.angle()
	add_child(marker)
	_telegraph = marker


func _drop_telegraph() -> void:
	if is_instance_valid(_telegraph):
		_telegraph.queue_free()
	_telegraph = null


func _drop_cone() -> void:
	if is_instance_valid(_cone):
		_cone.deactivate()
		_cone.queue_free()
	_cone = null


## The cone hitbox: a child of the singer, its polygon drawn along the facing at the start of the song.
## It is an area hit (not a projectile): a ward block negates it and does not destroy the singer.
func _make_cone() -> Hitbox:
	var cone := Hitbox.new()
	cone.team = Layers.Team.ENEMY
	cone.kind = CONE_KIND
	cone.damage = CONE_DAMAGE
	cone.knockback = 640.0
	cone.knockback_time = 0.14
	cone.once_per_target = true
	cone.blockable = true
	cone.block_destroys_carrier = false
	cone.source = self
	cone.rotation = facing_dir.angle()
	var polygon := CollisionPolygon2D.new()
	polygon.polygon = _cone_points()
	cone.add_child(polygon)
	return cone


## Fan of the cone in its own frame (pointing along +x): the apex and the arc.
func _cone_points() -> PackedVector2Array:
	var points := PackedVector2Array([Vector2.ZERO])
	var half := deg_to_rad(CONE_ANGLE) * 0.5
	for i in range(CONE_SEGMENTS + 1):
		var a := -half + float(i) * (2.0 * half) / float(CONE_SEGMENTS)
		points.append(Vector2.from_angle(a) * CONE_LENGTH)
	return points
