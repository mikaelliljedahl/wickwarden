extends Node2D
## Glow jar in flight and then burning light (glow_jar.gd throws it). The jar flies from where it starts to
## a landing point over FLIGHT_TIME. A wall on the way stops it short. Once landed it glows for GLOW_TIME
## seconds: a PointLight2D of GLOW_RADIUS px (energy fades in, stays full, fades out) and membership of the
## group `glow_light`. While it glows it calls reveal() on every `revealable` node within GLOW_RADIUS, each
## physics frame. When it goes out it calls hide_again() on those it revealed (a prop that is permanent keeps
## itself open). It emits `burnt_out` once and frees itself. Damage is zero: the jar is a light, not a weapon.
## monsters-bosses-tools.md, section 5.5.

signal burnt_out

const FLIGHT_TIME := 0.45
const ARC_HEIGHT := 40.0
## Stops this far short of a WORLD body on the way.
const LANDING_GAP := 12.0
const GLOW_RADIUS := 520.0
const GLOW_TIME := 6.0
const FADE_IN := 0.3
const FADE_OUT := 1.0
const GLOW_COLOR := Color(0.72, 0.9, 1.0)
## Peak light energy. The spec sets the radius and the timing only; this makes a 520 px pool read in a dark room.
const GLOW_ENERGY := 1.6
const JAR_RADIUS := 14.0

## For gallery fixtures: the jar starts landed and glowing at its own position. Items never set it.
@export var start_lit: bool = false

var _flying: bool = false
var _from: Vector2 = Vector2.ZERO
var _landing: Vector2 = Vector2.ZERO
var _fly_time: float = 0.0
var _lit: bool = false
var _glow_elapsed: float = 0.0
var _light: PointLight2D
## Revealed nodes -> true. Kept so that hide_again() reaches exactly the nodes this jar touched.
var _revealed: Dictionary = {}


func _ready() -> void:
	register_look()
	if not Placeholder.has_kind(&"jar_thrown"):
		Placeholder.register_kind(&"jar_thrown", Placeholder.definition_of(&"glow_jar"), true)
	if not Placeholder.has_kind(&"jar_lit"):
		Placeholder.register_kind(&"jar_lit", Placeholder.definition_of(&"glow_jar"), true)
	SpriteVisual.attach(self, &"jar_thrown")
	_light = PointLight2D.new()
	_light.name = "Glow"
	_light.texture = LightTexture.make()
	_light.texture_scale = LightTexture.scale_for(GLOW_RADIUS)
	_light.color = GLOW_COLOR
	_light.energy = 0.0
	_light.enabled = false
	add_child(_light)
	if start_lit:
		_land()


## Placeholder look of the jar (also used by the glow_jar item, which hides its own visual).
static func register_look() -> void:
	if not Placeholder.has_kind(&"glow_jar"):
		Placeholder.register_kind(
			&"glow_jar",
			{"shape": "circle", "color": Color(0.7, 0.9, 1.0, 0.85), "radius": JAR_RADIUS}
		)


## Starts the flight from the current global position along `dir` (cardinal in play) for at most `reach` px.
## The landing point is the reach, or stops LANDING_GAP short of the first WORLD body on the line.
func launch(dir: Vector2, reach: float) -> void:
	var step := dir.normalized() if dir != Vector2.ZERO else Vector2.RIGHT
	var from := global_position
	var hit: Dictionary = get_world_2d().direct_space_state.intersect_ray(
		PhysicsRayQueryParameters2D.create(from, from + step * reach, Layers.WORLD)
	)
	var dist := reach
	if not hit.is_empty():
		var hit_pos := hit["position"] as Vector2
		dist = maxf(from.distance_to(hit_pos) - LANDING_GAP, 0.0)
	_from = from
	_landing = from + step * dist
	_fly_time = 0.0
	_flying = true


func is_flying() -> bool:
	return _flying


func is_lit() -> bool:
	return _lit


func _physics_process(delta: float) -> void:
	if _flying:
		_fly(delta)
	elif _lit:
		_glow(delta)


func _fly(delta: float) -> void:
	_fly_time += delta
	var t := clampf(_fly_time / FLIGHT_TIME, 0.0, 1.0)
	global_position = _from.lerp(_landing, t)
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as Node2D
	if visual != null:
		visual.position = Vector2(0.0, -sin(t * PI) * ARC_HEIGHT)
	if t >= 1.0:
		_land()


func _land() -> void:
	_flying = false
	_lit = true
	_glow_elapsed = 0.0
	var visual := SpriteVisual.attach(self, &"jar_lit")
	visual.position = Vector2.ZERO
	add_to_group(&"glow_light")
	_light.enabled = true
	_light.energy = glow_energy()
	Audio.play_sfx(&"hook_clank", global_position, -6.0)


func _glow(delta: float) -> void:
	_glow_elapsed += delta
	_light.energy = glow_energy()
	_reveal_nearby()
	if _glow_elapsed >= GLOW_TIME:
		_go_out()


## Light energy at the current glow time: fades in over FADE_IN, full, fades out over FADE_OUT.
func glow_energy() -> float:
	if _glow_elapsed < FADE_IN:
		return GLOW_ENERGY * _glow_elapsed / FADE_IN
	if _glow_elapsed > GLOW_TIME - FADE_OUT:
		return GLOW_ENERGY * maxf((GLOW_TIME - _glow_elapsed) / FADE_OUT, 0.0)
	return GLOW_ENERGY


func _reveal_nearby() -> void:
	for node in get_tree().get_nodes_in_group(&"revealable"):
		var prop := node as Node2D
		if prop == null or not prop.has_method(&"reveal"):
			continue
		if global_position.distance_to(prop.global_position) > GLOW_RADIUS:
			continue
		prop.call(&"reveal")
		_revealed[prop] = true


func _go_out() -> void:
	_lit = false
	remove_from_group(&"glow_light")
	_light.enabled = false
	_release_reveals()
	burnt_out.emit()
	queue_free()


func _release_reveals() -> void:
	for prop: Object in _revealed.keys():
		if is_instance_valid(prop) and prop.has_method(&"hide_again"):
			prop.call(&"hide_again")
	_revealed.clear()


func _exit_tree() -> void:
	_lit = false
	_release_reveals()
