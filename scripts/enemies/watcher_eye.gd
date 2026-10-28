extends EnemyBase
## Watcher eye (monsters-bosses-tools section 2.1): a wall turret. On its first physics frame it faces
## inward, away from the nearest wall of its room, and never moves (knockback is off).
## Lid closed (invulnerable) by default. When Tamsin is on its axis (within 48 px of it, 192 to 1100 px
## away, clear line of sight) it telegraphs for 0.5 s (glow), fires one beam bolt along the axis, keeps
## the lid open for 1.0 s (vulnerable) and rests 1.5 s, so one cycle is 3.0 s.
## A stun opens the lid for its whole length and interrupts an attack; the rest starts again after it.
## 2 hp, contact damage 0. It does NOT declare a class_name (WP files must not; see docs/code-contract.md).

enum State { REST, TELEGRAPH, OPEN }

const TELEGRAPH_TIME := 0.5
const OPEN_TIME := 1.0
const REST_TIME := 1.5
const AXIS_TOLERANCE := 48.0
const RANGE_MIN := 192.0
const RANGE_MAX := 1100.0
const BEAM_SPEED := 300.0
const BEAM_DAMAGE := 2
## Distance from the eye centre to the beam's centre: keeps the capsule off the wall it sits in.
const BEAM_START := 40.0
const BEAM_KIND := &"beam_bolt"
const BEAM_SCENE_PATH := "res://scenes/enemies/beam_bolt.tscn"
const GLOW := Color(1.0, 0.85, 0.45)

var _state: State = State.REST
var _timer: float = REST_TIME
var _aimed: bool = false
var _beam_scene: PackedScene


func _init() -> void:
	max_hp = 2
	contact_damage = 0
	move_speed = 0.0
	visual_kind = &"watcher_eye"
	body_radius = 24.0
	knockback_scale = 0.0
	_register_kinds()


static func _register_kinds() -> void:
	if not Placeholder.has_kind(&"watcher_eye"):
		Placeholder.register_kind(
			&"watcher_eye", {"shape": "ring", "color": Color(0.45, 0.72, 0.95), "radius": 24.0}
		)
	if not Placeholder.has_kind(BEAM_KIND):
		Placeholder.register_kind(
			BEAM_KIND, {"shape": "circle", "color": Color(0.6, 0.85, 1.0), "radius": 12.0}
		)


func _enemy_ready() -> void:
	_beam_scene = load(BEAM_SCENE_PATH) as PackedScene  # null is fine: plain projectile
	_set_state(State.REST, REST_TIME)


func _enemy_physics(delta: float) -> void:
	if not _aimed:
		_aim_inward()
	velocity = Vector2.ZERO
	_timer -= delta
	match _state:
		State.REST:
			if _timer <= 0.0 and _player_on_axis():
				_set_state(State.TELEGRAPH, TELEGRAPH_TIME)
		State.TELEGRAPH:
			if _timer <= 0.0:
				_fire()
		State.OPEN:
			if _timer <= 0.0:
				_set_state(State.REST, REST_TIME)


## A stun interrupts the attack and opens the lid for its length (the base skips _enemy_physics meanwhile).
func _on_stunned(_seconds: float) -> void:
	_state = State.REST
	_timer = REST_TIME
	_glow(false)
	invulnerable = false


func _on_stun_end() -> void:
	_set_state(State.REST, REST_TIME)


## Faces the nearest wall of room_rect (the interior of the room). Done once the room rect is known,
## so a test or a room that sets room_rect after _ready still gets it.
func _aim_inward() -> void:
	if room_rect.size == Vector2.ZERO:
		return
	var left := global_position.x - room_rect.position.x
	var right := room_rect.end.x - global_position.x
	var top := global_position.y - room_rect.position.y
	var bottom := room_rect.end.y - global_position.y
	var nearest := minf(minf(left, right), minf(top, bottom))
	var inward := Vector2.RIGHT
	if nearest == right:
		inward = Vector2.LEFT
	elif nearest == top:
		inward = Vector2.DOWN
	elif nearest == bottom:
		inward = Vector2.UP
	set_facing_dir(inward)
	_aimed = true


## True when Tamsin is in the firing zone: on the axis, in range and in sight.
func _player_on_axis() -> bool:
	var player := get_player()
	if player == null:
		return false
	var offset := player.global_position - global_position
	var along := offset.dot(facing_dir)
	if along < RANGE_MIN or along > RANGE_MAX:
		return false
	if absf(offset.dot(facing_dir.orthogonal())) > AXIS_TOLERANCE:
		return false
	var query := PhysicsRayQueryParameters2D.create(
		global_position, player.global_position, Layers.WORLD
	)
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _fire() -> void:
	var beam := fire_projectile(
		_beam_scene, facing_dir, BEAM_SPEED, BEAM_DAMAGE, global_position + facing_dir * BEAM_START
	)
	# The painted bolt must remain readable outside Tamsin's lamp in dark rooms.
	var beam_visual := beam.get_node_or_null("Visual") as CanvasItem
	if beam_visual != null:
		var light := CanvasItemMaterial.new()
		light.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		beam_visual.material = light
	_set_state(State.OPEN, OPEN_TIME)


## Sets the attack state, its length and the lid: closed (invulnerable) except while the beam is open.
func _set_state(state: State, seconds: float) -> void:
	_state = state
	_timer = seconds
	invulnerable = state != State.OPEN
	_glow(state == State.TELEGRAPH)


## Presentation only: the glow of the telegraph on the Visual.
func _glow(on: bool) -> void:
	if visual != null:
		visual.modulate = GLOW if on else Color.WHITE
