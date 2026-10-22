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

var direction: Vector2 = Vector2.RIGHT
## Global rect the projectile may exist in. Rect2() = unbounded.
var room_rect: Rect2 = Rect2()
var hitbox: Hitbox
var is_destroyed: bool = false
var _age: float = 0.0


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


func _init() -> void:
	collision_layer = 0
	collision_mask = Layers.WORLD
	monitoring = true


func _ready() -> void:
	add_to_group(&"projectiles")
	if get_node_or_null("WallShape") == null:
		var shape := CircleShape2D.new()
		shape.radius = radius
		var node := CollisionShape2D.new()
		node.name = "WallShape"
		node.shape = shape
		add_child(node)
	hitbox = get_node_or_null("Hitbox") as Hitbox
	if hitbox == null:
		hitbox = Hitbox.new()
		hitbox.name = "Hitbox"
		hitbox.team = Layers.Team.ENEMY
		hitbox.add_circle(radius)
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
	global_position += direction * speed * delta
	hitbox.knockback_direction = direction
	if room_rect.size != Vector2.ZERO and not room_rect.has_point(global_position):
		destroy(&"bounds")
		return
	if has_overlapping_bodies():
		destroy(&"wall")


func _on_blocked() -> void:
	destroy(&"ward")


func _on_hit_landed(_hurtbox: Hurtbox) -> void:
	if destroy_on_hit:
		destroy(&"hit")
