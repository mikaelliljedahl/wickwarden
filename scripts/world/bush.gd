class_name Bush
extends StaticBody2D
## A bush cut by the lamp hook (swing, flare) or an explosion. Solid until cut. It may drop loot
## (same table as enemies). Place bushes in a room's `Bushes` container: they regrow on every
## room entry.
##
## `variant` is the look only (the cut is the same for all): bush, reed_cluster, rush_wall,
## moss_wall, dry_vine_screen or bush_cluster. Each name is also its Placeholder kind.

signal cut

@export var drops_enabled: bool = true
## Tests: force the drop roll (0..1). Negative = random.
@export var drop_roll_override: float = -1.0
## Look of the bush (see the class note). Set it before the bush enters the tree.
@export var variant: StringName = &"bush"

var is_cut: bool = false
var hurtbox: Hurtbox


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0
	_register_looks()


func _ready() -> void:
	add_to_group(&"bushes")
	var shape := CircleShape2D.new()
	shape.radius = 34.0
	var body := CollisionShape2D.new()
	body.shape = shape
	add_child(body)
	hurtbox = Hurtbox.new()
	hurtbox.name = "Hurtbox"
	hurtbox.team = Layers.Team.NEUTRAL
	hurtbox.add_circle(48.0)
	add_child(hurtbox)
	hurtbox.hurt.connect(_on_hurt)
	SpriteVisual.attach(self, variant, 40.0)


func _on_hurt(hitbox: Hitbox) -> void:
	if hitbox.kind == &"hook" or hitbox.kind == &"flare" or hitbox.kind == &"explosion":
		cut_down()


func cut_down() -> void:
	if is_cut:
		return
	is_cut = true
	hurtbox.enabled = false
	var parent := get_parent()
	if parent != null:
		var tint := Color(0.6, 0.8, 0.45)
		if SpriteVisual.spawn_effect(parent, &"explosion", global_position, 0.25, 3, tint) == null:
			Placeholder.puff(parent, global_position, Placeholder.color_of(variant), 36.0)
		if drops_enabled:
			var kind := DropTable.roll(drop_roll_override)
			if kind != &"":
				PickupBase.spawn(kind, parent, global_position)
	Audio.play_sfx(&"bush_cut", global_position)
	cut.emit()
	queue_free()


## Placeholder looks of the variants (registered once; "bush" is in Placeholder.KINDS already).
static func _register_looks() -> void:
	if Placeholder.has_kind(&"reed_cluster"):
		return
	Placeholder.register_kind(
		&"reed_cluster", {"shape": "circle", "color": Color(0.7, 0.68, 0.38), "radius": 40.0}, true
	)
	Placeholder.register_kind(
		&"rush_wall",
		{"shape": "rect", "color": Color(0.5, 0.62, 0.3), "size": Vector2(80, 80)},
		true
	)
	Placeholder.register_kind(
		&"moss_wall",
		{"shape": "rect", "color": Color(0.36, 0.5, 0.36), "size": Vector2(80, 80)},
		true
	)
	Placeholder.register_kind(
		&"dry_vine_screen",
		{"shape": "diamond", "color": Color(0.55, 0.45, 0.22), "radius": 40.0},
		true
	)
	Placeholder.register_kind(
		&"bush_cluster", {"shape": "circle", "color": Color(0.14, 0.4, 0.2), "radius": 40.0}, true
	)
