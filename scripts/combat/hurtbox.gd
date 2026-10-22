class_name Hurtbox
extends Area2D
## Receives hits from Hitboxes. Passive: it never moves anything itself, it emits `hurt` and the
## owner (player, enemy, prop) reacts. The owner is also responsible for i-frames: set
## `invulnerable = true` inside the `hurt` handler.

## Emitted for every ACCEPTED hit. Compute damage with hitbox.damage_for(self).
signal hurt(hitbox: Hitbox)

@export var team: Layers.Team = Layers.Team.ENEMY
@export var enabled: bool = true
@export var invulnerable: bool = false
## Optional veto: Callable(hitbox: Hitbox) -> bool. Return false to ignore the hit (ward).
## Called BEFORE the invulnerability check.
var filter: Callable = Callable()


func _init() -> void:
	monitoring = false


func _ready() -> void:
	add_to_group(&"hurtboxes")
	setup(team)


func setup(new_team: Layers.Team) -> void:
	team = new_team
	collision_layer = Layers.hurtbox_layer(team)
	collision_mask = 0
	monitoring = false


func add_circle(radius: float, at: Vector2 = Vector2.ZERO) -> CollisionShape2D:
	var shape := CircleShape2D.new()
	shape.radius = radius
	var node := CollisionShape2D.new()
	node.shape = shape
	node.position = at
	add_child(node)
	return node


## Returns true if the hit was accepted (and `hurt` was emitted).
func receive_hit(hitbox: Hitbox) -> bool:
	if not enabled or not hitbox.can_hit(self):
		return false
	if filter.is_valid() and not bool(filter.call(hitbox)):
		return false
	if invulnerable:
		return false
	hurt.emit(hitbox)
	return true
