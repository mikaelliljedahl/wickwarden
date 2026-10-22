class_name Bush
extends StaticBody2D
## A bush cut by the lamp hook (swing, flare) or an explosion. Solid until cut. It may drop loot
## (same table as enemies). Place bushes in a room's `Bushes` container: they regrow on every
## room entry.

signal cut

@export var drops_enabled: bool = true
## Tests: force the drop roll (0..1). Negative = random.
@export var drop_roll_override: float = -1.0

var is_cut: bool = false
var hurtbox: Hurtbox


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0


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
	SpriteVisual.attach(self, &"bush", 40.0)


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
		Placeholder.puff(parent, global_position, Placeholder.color_of(&"bush"), 36.0)
		if drops_enabled:
			var kind := DropTable.roll(drop_roll_override)
			if kind != &"":
				PickupBase.spawn(kind, parent, global_position)
	cut.emit()
	queue_free()
