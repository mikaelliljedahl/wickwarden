extends Hitbox
## Tallow slug: the shot of the tallow sling (tallow_sling.gd). A PLAYER Hitbox of kind `sling` that flies
## SPEED px/s in a straight line for at most RANGE px. It is spent by the first WORLD body it meets (a ray),
## by the first hurtbox it hits, or at range. It emits `spent` once and frees itself.
## Damage 1, knockback 240 px/s for 0.08 s away from the shot (monsters-bosses-tools.md, section 5.2).

signal spent

const SPEED := 720.0
const RANGE := 840.0
const RADIUS := 14.0
const DAMAGE := 1
const KNOCKBACK := 240.0
const KNOCKBACK_TIME := 0.08

## Non-zero: the slug flies in this direction as soon as it is ready (a placed slug in a gallery fixture).
## The tallow sling calls launch() instead.
@export var fly_dir: Vector2 = Vector2.ZERO

var _dir: Vector2 = Vector2.RIGHT
var _travelled: float = 0.0
var _spent: bool = false


func _init() -> void:
	team = Layers.Team.PLAYER
	kind = &"sling"
	damage = DAMAGE
	knockback = KNOCKBACK
	knockback_time = KNOCKBACK_TIME
	once_per_target = true


func _ready() -> void:
	super()
	add_to_group(&"sling_slugs")
	add_circle(RADIUS)
	_register_kinds()
	Placeholder.attach(self, &"slug", RADIUS)
	hit_landed.connect(_on_hit_landed)
	if fly_dir != Vector2.ZERO:
		launch(fly_dir)


## Starts the flight along `dir` (cardinal in play; zero means right).
func launch(dir: Vector2) -> void:
	_dir = dir.normalized() if dir != Vector2.ZERO else Vector2.RIGHT
	knockback_direction = _dir
	_travelled = 0.0
	_spent = false
	activate()


func _physics_process(delta: float) -> void:
	if not active:
		return
	var step := minf(SPEED * delta, RANGE - _travelled)
	var from := global_position
	var to := from + _dir * step
	if _hits_wall(from, to):
		_spend()
		return
	global_position = to
	_travelled += step
	super(delta)
	if _travelled >= RANGE - 0.5:
		_spend()


## Only the first hurtbox of a frame is hit: once the slug is spent, the rest of the overlaps are skipped.
func _try_hit(hurtbox: Hurtbox) -> void:
	if _spent:
		return
	super(hurtbox)


func _on_hit_landed(_hurtbox: Hurtbox) -> void:
	_spend()


func _spend() -> void:
	if _spent:
		return
	_spent = true
	active = false
	spent.emit()
	queue_free()


func _hits_wall(from: Vector2, to: Vector2) -> bool:
	var query := PhysicsRayQueryParameters2D.create(from, to, Layers.WORLD)
	var hit: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	return not hit.is_empty()


static func _register_kinds() -> void:
	if not Placeholder.has_kind(&"slug"):
		Placeholder.register_kind(
			&"slug", {"shape": "circle", "color": Color(0.82, 0.66, 0.38), "radius": RADIUS}, true
		)
