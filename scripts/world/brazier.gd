class_name Brazier
extends StaticBody2D
## An unlit brazier. A lamp hook swing, a flare or a cinder wick flame (kind `fire`) that hits it lights it. Solid.
## Lit state persists through the flag "brazier_<id>" when `brazier_id` is set.
## A Gate listens to `lit_changed`.

signal lit_changed(is_lit: bool)

@export var brazier_id: StringName = &""
@export var lit: bool = false
## Light radius when lit (px). Only matters in dark rooms.
@export var light_radius: float = 220.0

var hurtbox: Hurtbox
var light: PointLight2D
## Faint pulsing ember glow while unlit (a visual hint; a light so the cave darkness cannot hide it).
var ember: PointLight2D
var _ember_tween: Tween

const EMBER_RADIUS := 170.0
const EMBER_ENERGY_LOW := 0.6
const EMBER_ENERGY_HIGH := 1.1
const EMBER_PERIOD := 2.6


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
	ember = PointLight2D.new()
	ember.name = "Ember"
	ember.texture = LightTexture.make()
	ember.texture_scale = LightTexture.scale_for(EMBER_RADIUS)
	ember.color = Color(1.0, 0.36, 0.12)
	ember.energy = EMBER_ENERGY_LOW
	ember.position = Vector2(0, -24)
	add_child(ember)
	SpriteVisual.attach(self, &"brazier", 0.0, Vector2(64, 64))
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
	Audio.play_sfx(&"brazier_lit", global_position)
	if brazier_id != &"":
		GameState.set_flag(flag_name())
		Events.brazier_lit.emit(brazier_id)
	_refresh()
	lit_changed.emit(true)


func _on_hurt(hitbox: Hitbox) -> void:
	if hitbox.kind == &"fire":
		# A cinder wick flame lights it silently; a flame touching a lit brazier does nothing.
		ignite()
		return
	if hitbox.kind == &"hook" or hitbox.kind == &"flare":
		if lit:
			Audio.play_sfx(&"hook_clank", global_position)
		ignite()


func _refresh() -> void:
	light.enabled = lit
	ember.visible = not lit
	ember.enabled = not lit
	if _ember_tween != null:
		_ember_tween.kill()
		_ember_tween = null
	if not lit and is_inside_tree():
		_ember_tween = create_tween().set_loops()
		_ember_tween.set_trans(Tween.TRANS_SINE)
		_ember_tween.tween_property(ember, "energy", EMBER_ENERGY_HIGH, EMBER_PERIOD * 0.5)
		_ember_tween.tween_property(ember, "energy", EMBER_ENERGY_LOW, EMBER_PERIOD * 0.5)
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as Node2D
	if visual != null and visual.has_method("set_kind"):
		visual.call("set_kind", &"brazier_lit" if lit else &"brazier")
