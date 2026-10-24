class_name EnemyProjectile
extends Area2D
## Base class of enemy projectiles (spore, ...). Moves straight, damages the player, is destroyed
## by walls and (if `blockable_by_ward`) by the player's ward.
##
## Create one with EnemyProjectile.fire(...) for a plain projectile, or instantiate a subclass
## scene and call launch(). The projectile is added to `parent` (use the shooter's get_parent()
## so it is cleaned up with the room).
##
## Hooks: _projectile_physics(delta) (extra motion, called before the straight move),
##        _on_destroyed(reason) with reason in &"wall", &"ward", &"hit", &"range", &"bounds".
## Options: `homing_turn_deg` > 0 turns the flight toward the player at that many degrees per second
## (Hush torrent, treble notes); `shape_capsule` uses a 24 x 96 px capsule along the flight direction
## (watcher beam) instead of the circle.

signal destroyed(reason: StringName)

@export var damage: int = 1
@export var speed: float = 360.0
@export var radius: float = 12.0
@export var blockable_by_ward: bool = true
## Seconds before it disappears on its own.
@export var lifetime: float = 5.0
@export var visual_kind: StringName = &"spore"
@export var knockback: float = 640.0
@export var knockback_time: float = 0.14
## Destroy on touching the player hurtbox (even if the hit was ignored by i-frames: no, only
## accepted hits). Set false for piercing projectiles.
@export var destroy_on_hit: bool = true
## Degrees per second the flight turns toward the player. 0 = straight flight.
@export var homing_turn_deg: float = 0.0
## True: the wall and hit shapes are a capsule of CAPSULE_SIZE along the flight direction.
@export var shape_capsule: bool = false

## Size of the capsule shape (width, length in px) when shape_capsule is set.
const CAPSULE_SIZE := Vector2(24.0, 96.0)

var direction: Vector2 = Vector2.RIGHT
## Global rect the projectile may exist in. Rect2() = unbounded.
var room_rect: Rect2 = Rect2()
var hitbox: Hitbox
var is_destroyed: bool = false
var _age: float = 0.0
var _shape_nodes: Array[CollisionShape2D] = []


## Spawns a plain projectile. Returns it.
static func fire(
	parent: Node, at: Vector2, dir: Vector2, proj_speed: float = 360.0, proj_damage: int = 1
) -> EnemyProjectile:
	var projectile := EnemyProjectile.new()
	projectile.speed = proj_speed
	projectile.damage = proj_damage
	parent.add_child(projectile)
	projectile.launch(at, dir)
	return projectile


## Layer and mask are set in _ready(): a subclass _init() does not run this one (Godot 4.7).
func _ready() -> void:
	collision_layer = 0
	collision_mask = Layers.WORLD
	monitoring = true
	add_to_group(&"projectiles")
	if get_node_or_null("WallShape") == null:
		var wall_node := _make_shape_node()
		wall_node.name = "WallShape"
		add_child(wall_node)
		_shape_nodes.append(wall_node)
	hitbox = get_node_or_null("Hitbox") as Hitbox
	if hitbox == null:
		hitbox = Hitbox.new()
		hitbox.name = "Hitbox"
		hitbox.team = Layers.Team.ENEMY
		var hit_node := _make_shape_node()
		hitbox.add_child(hit_node)
		_shape_nodes.append(hit_node)
		add_child(hitbox)
	hitbox.kind = &"projectile"
	hitbox.damage = damage
	hitbox.knockback = knockback
	hitbox.knockback_time = knockback_time
	hitbox.blockable = blockable_by_ward
	hitbox.source = self
	hitbox.active = true
	hitbox.blocked.connect(_on_blocked)
	hitbox.hit_landed.connect(_on_hit_landed)
	if get_node_or_null(Placeholder.VISUAL_NAME) == null:
		SpriteVisual.attach(self, visual_kind, radius)


## Places the projectile (global position) and sets its direction.
func launch(at: Vector2, dir: Vector2) -> void:
	global_position = at
	direction = dir.normalized() if dir != Vector2.ZERO else Vector2.RIGHT
	if hitbox != null:
		hitbox.knockback_direction = direction
	_orient_shapes()


## A circle of `radius`, or a capsule of CAPSULE_SIZE when shape_capsule is set.
func _make_shape_node() -> CollisionShape2D:
	var node := CollisionShape2D.new()
	if shape_capsule:
		var capsule := CapsuleShape2D.new()
		capsule.radius = CAPSULE_SIZE.x * 0.5
		capsule.height = CAPSULE_SIZE.y
		node.shape = capsule
	else:
		var circle := CircleShape2D.new()
		circle.radius = radius
		node.shape = circle
	return node


## A capsule stands upright by default; turn it so its long axis follows the flight direction.
func _orient_shapes() -> void:
	if not shape_capsule:
		return
	for node in _shape_nodes:
		if is_instance_valid(node):
			node.rotation = direction.angle() + PI * 0.5


func _projectile_physics(_delta: float) -> void:
	pass


func _on_destroyed(_reason: StringName) -> void:
	pass


func destroy(reason: StringName = &"hit") -> void:
	if is_destroyed:
		return
	is_destroyed = true
	hitbox.active = false
	_on_destroyed(reason)
	destroyed.emit(reason)
	queue_free()


func _physics_process(delta: float) -> void:
	if is_destroyed:
		return
	_age += delta
	if _age >= lifetime:
		destroy(&"range")
		return
	_projectile_physics(delta)
	if is_destroyed:
		return
	if homing_turn_deg > 0.0:
		_home(delta)
	global_position += direction * speed * delta
	hitbox.knockback_direction = direction
	_orient_shapes()
	if room_rect.size != Vector2.ZERO and not room_rect.has_point(global_position):
		destroy(&"bounds")
		return
	if has_overlapping_bodies():
		destroy(&"wall")


func _on_blocked() -> void:
	if hitbox.block_destroys_carrier:
		destroy(&"ward")


## Turns `direction` toward the player by at most homing_turn_deg per second.
func _home(delta: float) -> void:
	var target := get_tree().get_first_node_in_group(&"player") as Node2D
	if target == null:
		return
	var to_target := target.global_position - global_position
	if to_target.length_squared() < 0.0001:
		return
	var max_turn := deg_to_rad(homing_turn_deg) * delta
	direction = direction.rotated(clampf(direction.angle_to(to_target), -max_turn, max_turn))


func _on_hit_landed(_hurtbox: Hurtbox) -> void:
	if destroy_on_hit:
		destroy(&"hit")
