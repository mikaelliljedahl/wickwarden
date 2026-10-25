extends Hitbox
## Cinder wick flame (cinder_wick.gd). A PLAYER Hitbox of kind `fire`: it rolls ROLL_SPEED px/s along `dir`,
## starting SPAWN_AHEAD px ahead of the origin, and stops where its line meets a WORLD body, a burnable prop, a
## brazier or an enemy hurtbox (never closer than MIN_STOP px to the origin), or after MAX_ROLL px. It then stands
## for STAND_TIME s and is spent. It ticks TICK_DAMAGE every TICK_INTERVAL s, sticks to the first enemy it
## overlaps and follows it, and calls on_fire() on every burnable prop it overlaps (monsters-bosses-tools.md, 5.1).
## Braziers light through their own hurtbox (brazier.gd reacts to kind `fire`). It emits `spent` once and frees itself.

signal spent

const RADIUS := 56.0
const ROLL_SPEED := 480.0
const SPAWN_AHEAD := 48.0
const MAX_ROLL := 288.0
const MIN_STOP := 96.0
const STAND_TIME := 3.0
const FADE_TIME := 0.4
const TICK_DAMAGE := 1
const TICK_INTERVAL := 0.5
const MAX_RAY_HITS := 8
const LIGHT_RADIUS := 220.0
const LIGHT_COLOR := Color(1.0, 0.7, 0.35)

## Non-zero: the flame launches from where it stands in this direction (a placed flame in a gallery fixture).
## The cinder wick calls launch() instead.
@export var place_dir: Vector2 = Vector2.ZERO

var _origin: Vector2 = Vector2.ZERO
var _dir: Vector2 = Vector2.RIGHT
## Distance from the origin where the flame centre stops rolling.
var _reach: float = 0.0
## Distance from the origin of the flame centre (rolling).
var _distance: float = 0.0
var _rolling: bool = false
var _stand_left: float = STAND_TIME
var _attached: Node2D = null
var _spent: bool = false
var _placed_pending: bool = false
## Seconds until the next tick. Each tick re-activates the hitbox, which clears its hit memory.
var _tick_left: float = 0.0


func _init() -> void:
	team = Layers.Team.PLAYER
	kind = &"fire"
	damage = TICK_DAMAGE
	knockback = 0.0
	once_per_target = true


func _ready() -> void:
	super()
	add_to_group(&"cinder_flames")
	add_circle(RADIUS)
	_register_kinds()
	SpriteVisual.attach(self, &"flame", RADIUS)
	var glow := PointLight2D.new()
	glow.name = "Glow"
	glow.texture = LightTexture.make()
	glow.texture_scale = LightTexture.scale_for(LIGHT_RADIUS)
	glow.color = LIGHT_COLOR
	glow.energy = 1.0
	glow.shadow_enabled = false
	glow.enabled = true
	add_child(glow)
	# A placed flame launches on the first physics frame: the physics space must hold the bodies around it.
	_placed_pending = place_dir != Vector2.ZERO


## Starts the roll from `origin` (the player) along `dir` (cardinal in play; zero means right).
func launch(origin: Vector2, dir: Vector2) -> void:
	_origin = origin
	_dir = dir.normalized() if dir != Vector2.ZERO else Vector2.RIGHT
	_reach = _reach_from(origin, _dir)
	_distance = SPAWN_AHEAD
	_rolling = true
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as SpriteVisual
	if visual != null:
		visual.rotation = _dir.angle()
		visual.play_anim(&"roll")
	_stand_left = STAND_TIME
	global_position = origin + _dir * SPAWN_AHEAD
	_tick_left = TICK_INTERVAL
	activate()


func _physics_process(delta: float) -> void:
	if _placed_pending:
		_placed_pending = false
		launch(global_position, place_dir)
		return
	if not active:
		return
	if _rolling:
		_roll(delta)
	else:
		_stand(delta)
	if not active:
		return
	_tick_left -= delta
	if _tick_left <= 0.0:
		_tick_left += TICK_INTERVAL
		activate()
	if is_instance_valid(_attached):
		global_position = _attached.global_position
	_touch()
	super(delta)


## Distance from `origin` to where the flame centre stops along `dir`. Walks the ray past props and enemies
## that do not stop it (a bush, an eye switch), and clamps the stop to [MIN_STOP, SPAWN_AHEAD + MAX_ROLL].
func _reach_from(origin: Vector2, dir: Vector2) -> float:
	var limit := SPAWN_AHEAD + MAX_ROLL
	var to := origin + dir * limit
	var space := get_world_2d().direct_space_state
	var exclude: Array[RID] = []
	for _i in range(MAX_RAY_HITS):
		var query := PhysicsRayQueryParameters2D.create(
			origin, to, Layers.WORLD | Layers.PROP_HURTBOX | Layers.ENEMY_HURTBOX, exclude
		)
		query.collide_with_areas = true
		var hit: Dictionary = space.intersect_ray(query)
		if hit.is_empty():
			return limit
		if _stops_flame(hit.collider):
			return clampf(origin.distance_to(hit.position), MIN_STOP, limit)
		exclude.append(hit.rid)
	return limit


func _roll(delta: float) -> void:
	_distance = minf(_distance + ROLL_SPEED * delta, _reach)
	global_position = _origin + _dir * _distance
	if _distance >= _reach:
		_rolling = false
		var visual := get_node_or_null(Placeholder.VISUAL_NAME) as SpriteVisual
		if visual != null:
			visual.rotation = 0.0
			visual.play_anim(&"stand")


func _stand(delta: float) -> void:
	_stand_left -= delta
	if _stand_left < FADE_TIME and _stand_left + delta >= FADE_TIME:
		var painted := get_node_or_null(Placeholder.VISUAL_NAME) as SpriteVisual
		if painted != null:
			painted.play_anim(&"fade")
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null and _stand_left < FADE_TIME:
		visual.modulate.a = clampf(_stand_left / FADE_TIME, 0.0, 1.0)
	if _stand_left <= 0.0:
		_spend()


## Fire contract: every burnable prop in reach starts its burn; the first enemy touched is stuck to.
func _touch() -> void:
	for area in get_overlapping_areas():
		if not area is Hurtbox:
			continue
		var holder := area.get_parent()
		if holder == null:
			continue
		if holder.is_in_group(&"burnable") and holder.has_method(&"on_fire"):
			holder.call(&"on_fire", global_position)
		elif (
			holder is Node2D and holder.is_in_group(&"enemies") and not is_instance_valid(_attached)
		):
			_attached = holder as Node2D


func _spend() -> void:
	if _spent:
		return
	_spent = true
	active = false
	spent.emit()
	queue_free()


static func _stops_flame(collider: Object) -> bool:
	if collider is Hurtbox:
		var holder := (collider as Node).get_parent()
		return (
			holder != null
			and (
				holder.is_in_group(&"burnable")
				or holder.is_in_group(&"enemies")
				or holder.is_in_group(&"braziers")
			)
		)
	return (
		collider is CollisionObject2D
		and ((collider as CollisionObject2D).collision_layer & Layers.WORLD) != 0
	)


static func _register_kinds() -> void:
	if not Placeholder.has_kind(&"flame"):
		Placeholder.register_kind(
			&"flame",
			{"shape": "circle", "color": Color(1.0, 0.5, 0.15, 0.75), "radius": RADIUS},
			true
		)
