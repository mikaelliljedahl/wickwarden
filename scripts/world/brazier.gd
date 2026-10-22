class_name Brazier
extends StaticBody2D
## An unlit brazier. A lamp hook swing (or flare) that hits it lights it. Solid.
## Lit state persists through the flag "brazier_<id>" when `brazier_id` is set.
## A Gate listens to `lit_changed`.

signal lit_changed(is_lit: bool)

@export var brazier_id: StringName = &""
@export var lit: bool = false
## Light radius when lit (px). Only matters in dark rooms.
@export var light_radius: float = 220.0

var hurtbox: Hurtbox
var light: PointLight2D


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0


func _ready() -> void:
	add_to_group(&"braziers")
	var shape := CircleShape2D.new()
	shape.radius = 30.0
	var body := CollisionShape2D.new()
	body.shape = shape
	add_child(body)
	hurtbox = Hurtbox.new()
	hurtbox.name = "Hurtbox"
	hurtbox.team = Layers.Team.NEUTRAL
	hurtbox.add_circle(56.0)
	add_child(hurtbox)
	hurtbox.hurt.connect(_on_hurt)
	light = PointLight2D.new()
	light.name = "Flame"
	light.texture = LightTexture.make()
	light.texture_scale = LightTexture.scale_for(light_radius)
	light.color = Color(1.0, 0.7, 0.35)
	light.enabled = false
	add_child(light)
	Placeholder.attach(self, &"brazier", 0.0, Vector2(64, 64))
	if brazier_id != &"" and GameState.has_flag(flag_name()):
		lit = true
	_refresh()


func flag_name() -> StringName:
	return StringName("brazier_%s" % brazier_id)


## Lights the brazier. No-op if it is already lit.
func ignite() -> void:
	if lit:
		return
	lit = true
	if brazier_id != &"":
		GameState.set_flag(flag_name())
		Events.brazier_lit.emit(brazier_id)
	_refresh()
	lit_changed.emit(true)


func _on_hurt(hitbox: Hitbox) -> void:
	if hitbox.kind == &"hook" or hitbox.kind == &"flare":
		ignite()


func _refresh() -> void:
	light.enabled = lit
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as Placeholder
	if visual != null:
		visual.set_kind(&"brazier_lit" if lit else &"brazier")
