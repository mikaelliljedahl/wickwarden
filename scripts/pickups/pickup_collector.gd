class_name PickupCollector
extends Area2D
## Passive area that can collect pickups. The Player has one (collects immediately); the tether
## moth adds one with `carrier = true` (pickups it touches are carried back, see PickupBase).
##
## Usage (moth): var c := PickupCollector.new(); c.carrier = true; c.add_circle(30.0)
##               add_child(c); c.picked.connect(_on_picked)

## Emitted when a pickup touched this collector (collected or picked up for carrying).
signal picked(pickup: PickupBase)

## False: pickups are collected the instant they overlap (player).
## True: pickups start following the collector's owner node and are NOT applied until the carrier
## hands them over with pickup.collect(player).
@export var carrier: bool = false
## Who receives the effect / carries the pickup. Defaults to this area's parent.
var owner_node: Node2D


func _init() -> void:
	monitoring = false
	monitorable = true
	collision_layer = Layers.PICKUP_COLLECTOR
	collision_mask = 0


func _ready() -> void:
	if owner_node == null:
		owner_node = get_parent() as Node2D


func add_circle(radius: float, at: Vector2 = Vector2.ZERO) -> CollisionShape2D:
	var shape := CircleShape2D.new()
	shape.radius = radius
	var node := CollisionShape2D.new()
	node.shape = shape
	node.position = at
	add_child(node)
	return node
