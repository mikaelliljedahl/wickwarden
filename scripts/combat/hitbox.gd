class_name Hitbox
extends Area2D
## Deals damage to every Hurtbox it overlaps while `active`. Polls overlaps in _physics_process
## (never in signal callbacks), so it is safe to spawn nodes or free the owner from a hit.
##
## Damage is in half-hearts (int). Add a CollisionShape2D / CollisionPolygon2D child yourself, or
## use add_circle(radius). Layer, mask and monitoring are set by setup(team).

signal hit_landed(hurtbox: Hurtbox)
## Emitted when a ward destroyed the carrier of this hitbox (see Player ward).
signal blocked

@export var damage: int = 1
## Damage used instead of `damage` when the victim is on the player team. -1 = use `damage`.
@export var damage_vs_player: int = -1
## Knockback speed in px/s and duration in s applied to the victim, away from `source`.
@export var knockback: float = 480.0
@export var knockback_time: float = 0.12
## Seconds of stun applied to enemies (tether moth). 0 = none.
@export var stun_time: float = 0.0
## "hook", "flare", "explosion", "stun", "contact", "projectile" or anything the owner defines.
## Props (bush, brazier) and the ward filter on this.
@export var kind: StringName = &"contact"
@export var team: Layers.Team = Layers.Team.PLAYER
## The node knockback is measured from (and the ward direction check uses). Null = this hitbox.
var source: Node2D
## True: each hurtbox can be hit once per activation (swings). False: re-tried every frame, and
## the hurtbox's own invulnerability paces the hits (contact damage).
@export var once_per_target: bool = true
## True: a raised ward may destroy this hit (projectiles).
@export var blockable: bool = false
## Fixed knockback direction. Vector2.ZERO = away from `source`.
var knockback_direction: Vector2 = Vector2.ZERO
@export var active: bool = false:
	set(value):
		if value and not active:
			_hit_ids.clear()
		active = value
		monitoring = value

var _hit_ids: Dictionary = {}


func _ready() -> void:
	add_to_group(&"hitboxes")
	setup(team)
	monitoring = active


## Configures layer and mask for a team. Called automatically in _ready.
func setup(new_team: Layers.Team) -> void:
	team = new_team
	collision_layer = Layers.hitbox_layer(team)
	collision_mask = Layers.hitbox_mask(team)


func add_circle(radius: float, at: Vector2 = Vector2.ZERO) -> CollisionShape2D:
	var shape := CircleShape2D.new()
	shape.radius = radius
	var node := CollisionShape2D.new()
	node.shape = shape
	node.position = at
	add_child(node)
	return node


func activate() -> void:
	active = false
	active = true


func deactivate() -> void:
	active = false


func damage_for(hurtbox: Hurtbox) -> int:
	if hurtbox.team == Layers.Team.PLAYER and damage_vs_player >= 0:
		return damage_vs_player
	return damage


func can_hit(hurtbox: Hurtbox) -> bool:
	return (
		team == Layers.Team.NEUTRAL or hurtbox.team == Layers.Team.NEUTRAL or team != hurtbox.team
	)


func origin() -> Vector2:
	return source.global_position if is_instance_valid(source) else global_position


## Knockback velocity this hit applies to a victim standing at `victim_pos`.
func knockback_velocity(victim_pos: Vector2) -> Vector2:
	if knockback <= 0.0:
		return Vector2.ZERO
	var dir := knockback_direction
	if dir == Vector2.ZERO:
		dir = victim_pos - origin()
	if dir.length_squared() < 0.0001:
		dir = Vector2.DOWN
	return dir.normalized() * knockback


func _physics_process(_delta: float) -> void:
	if not active:
		return
	for area in get_overlapping_areas():
		if area is Hurtbox:
			_try_hit(area as Hurtbox)


func _try_hit(hurtbox: Hurtbox) -> void:
	if not can_hit(hurtbox):
		return
	if once_per_target and _hit_ids.has(hurtbox.get_instance_id()):
		return
	if hurtbox.receive_hit(self):
		_hit_ids[hurtbox.get_instance_id()] = true
		hit_landed.emit(hurtbox)
