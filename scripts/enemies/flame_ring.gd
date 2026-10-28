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


class Boundary:
	extends Node2D

	func _draw() -> void:
		# A fine edge marks the actual hit radius beneath the irregular painted flames.
		draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 96, Color(1.0, 0.84, 0.45, 0.9), 3.0, true)


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
	_attach_visual()
	var light := PointLight2D.new()
	light.texture = LightTexture.make()
	light.texture_scale = LightTexture.scale_for(RADIUS * 2.0)
	light.color = Color(1.0, 0.65, 0.3)
	add_child(light)
	_spawn_art.call_deferred()
	blocked.connect(deactivate)
	activate()


func _physics_process(delta: float) -> void:
	super(delta)
	_age += delta
	if _age >= ACTIVE_TIME:
		deactivate()
		queue_free()


func _attach_visual() -> void:
	var visual := SpriteVisual.attach(self, &"fx_wisp_burst")
	if visual is SpriteVisual:
		var painted := visual as SpriteVisual
		if painted.sprite_frames.has_animation(&"idle") and painted.sprite_frames.get_frame_count(&"idle") >= 4:
			# Frame 3 is the complete ring; the source strip fits 350 px in its cell.
			painted.stop()
			painted.set_frame_and_progress(3, 0.0)
			painted.scale = Vector2.ONE * (RADIUS * 2.0 / 350.0)
			var edge := Boundary.new()
			edge.name = "Boundary"
			add_child(edge)
			return
	_register_kinds()
	Placeholder.attach(self, &"flame_ring", RADIUS)


static func _register_kinds() -> void:
	if not Placeholder.has_kind(&"flame_ring"):
		Placeholder.register_kind(
			&"flame_ring",
			{"shape": "ring", "color": Color(1.0, 0.5, 0.15, 0.8), "radius": RADIUS},
			true
		)


func _spawn_art() -> void:
	if get_parent() != null:
		SpriteVisual.spawn_effect(get_parent(), &"fx_wisp_burst", global_position)
