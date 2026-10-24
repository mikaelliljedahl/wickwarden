extends Hitbox
## Flame ring of the cinder wisp burst (monsters-bosses-tools.md, 2.1): an ENEMY area Hitbox of radius 150 px,
## damage 2, active for 0.2 s, then freed. It is an area hit: `blockable` with `block_destroys_carrier` false, so
## a raised ward (Tamsin's front 120 degrees, measured from the source) negates it, and the ring is spent at once.
## Kind `burst` is this ring's own kind; no prop reacts to it. The owner (cinder_wisp.gd) creates it, sets `source`
## and places it. It frees itself after ACTIVE_TIME. It does NOT declare a class_name.

const RADIUS := 150.0
const DAMAGE := 2
const ACTIVE_TIME := 0.2
const GROUP := &"flame_rings"

var _age: float = 0.0


func _init() -> void:
	team = Layers.Team.ENEMY
	kind = &"burst"
	damage = DAMAGE
	blockable = true
	block_destroys_carrier = false


func _ready() -> void:
	super()
	add_to_group(GROUP)
	add_circle(RADIUS)
	_register_kinds()
	Placeholder.attach(self, &"flame_ring", RADIUS)
	blocked.connect(deactivate)
	activate()


func _physics_process(delta: float) -> void:
	super(delta)
	_age += delta
	if _age >= ACTIVE_TIME:
		deactivate()
		queue_free()


static func _register_kinds() -> void:
	if not Placeholder.has_kind(&"flame_ring"):
		Placeholder.register_kind(
			&"flame_ring",
			{"shape": "ring", "color": Color(1.0, 0.5, 0.15, 0.8), "radius": RADIUS},
			true
		)
