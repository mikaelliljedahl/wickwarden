extends StaticBody2D
## A resonance stone, door or vault: a solid block that the lantern chime wakes. Solid until awake.
## Only a chime hitbox (kind `chime`) reaches its hurtbox (PROP_HURTBOX): a hook swing, a flare or a
## pot blast passes the filter and does nothing. The chime calls `on_chime()` (group "resonant").
## The awake state persists through the flag "resonated_<id>" when `resonance_id` is set.
## `look` picks the placeholder kind: resonance_stone, resonance_door or resonance_vault.

const LOOK_DEFINITIONS := {
	&"resonance_stone":
	{"shape": "rect", "color": Color(0.45, 0.5, 0.62), "size": Vector2(192, 96)},
	&"resonance_door": {"shape": "rect", "color": Color(0.4, 0.44, 0.56), "size": Vector2(192, 96)},
	&"resonance_vault":
	{"shape": "rect", "color": Color(0.32, 0.36, 0.5), "size": Vector2(192, 96)},
}

@export var resonance_id: StringName = &""
## Placeholder kind of the look (a key of LOOK_DEFINITIONS). The scenes set it.
@export var look: StringName = &"resonance_stone"
## Footprint in px (centred on the origin). The default fills a 192 px gap.
@export var size: Vector2 = Vector2(192, 96)

var is_awake: bool = false
var hurtbox: Hurtbox
var _shape: CollisionShape2D


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0


func _ready() -> void:
	add_to_group(&"resonant")
	_register_kinds()
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
	_shape.shape = rect
	add_child(_shape)
	hurtbox = Hurtbox.new()
	hurtbox.name = "Hurtbox"
	hurtbox.team = Layers.Team.NEUTRAL
	hurtbox.filter = _accepts_chime
	var zone := RectangleShape2D.new()
	zone.size = size
	var zone_shape := CollisionShape2D.new()
	zone_shape.shape = zone
	hurtbox.add_child(zone_shape)
	add_child(hurtbox)
	hurtbox.hurt.connect(_on_hurt)
	SpriteVisual.attach(self, look, 0.0, size)
	if resonance_id != &"" and GameState.has_flag(flag_name()):
		_set_awake(true)


func flag_name() -> StringName:
	return StringName("resonated_%s" % resonance_id)


## Wakes the stone: the chime wave reached it, or the warp picker's tap calls it. No-op when awake.
func on_chime() -> void:
	if is_awake:
		return
	_set_awake(true)
	Audio.play_sfx(&"gate_open", global_position)
	if resonance_id != &"":
		GameState.set_flag(flag_name())


func _accepts_chime(hitbox: Hitbox) -> bool:
	return hitbox.kind == &"chime"


func _on_hurt(_hitbox: Hitbox) -> void:
	on_chime()


func _set_awake(value: bool) -> void:
	is_awake = value
	# Deferred: a chime can arrive during a physics step, where shapes may not change.
	_shape.set_deferred("disabled", value)
	hurtbox.enabled = not value
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = not value


static func _register_kinds() -> void:
	for entity_kind: StringName in LOOK_DEFINITIONS:
		if not Placeholder.has_kind(entity_kind):
			Placeholder.register_kind(entity_kind, LOOK_DEFINITIONS[entity_kind], true)
