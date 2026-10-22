class_name PickupBase
extends Area2D
## A pickup. One script for every kind in plan section 5; `kind` selects look and effect.
##
## Kinds: ember, brass_bit, brass_coin, pitch_pot_bundle, key, wick_core, item.
##
## Collecting: PickupBase.collect(collector) applies the effect, frees the pickup and returns
## true. The Player's PickupCollector calls it automatically on overlap. A carrier collector
## (tether moth) calls begin_carry(); the carrier later hands over with collect(player).
##
## Timeout: dropped pickups (`timeout > 0`) vanish after 8 s and blink during the last 2 s.
## Placed pickups use `timeout = 0` (never vanish) and a `persistent_id`: once collected the flag
## "picked_<id>" is set in GameState and the pickup is gone on the next visit.

signal collected(kind: StringName)

const DEFAULT_TIMEOUT := 8.0
const BLINK_TIME := 2.0
const BLINK_INTERVAL := 0.1
const PICKUP_RADIUS := 36.0
const KINDS: Array[StringName] = [
	&"ember", &"brass_bit", &"brass_coin", &"pitch_pot_bundle", &"key", &"wick_core", &"item"
]

@export var kind: StringName = &"brass_bit"
@export var amount: int = 0  # 0 = default for the kind
## Seconds until it vanishes. 0 = never (placed pickups).
@export var timeout: float = 0.0
## Non-empty: persistent placed pickup, flag "picked_<id>".
@export var persistent_id: StringName = &""
## Kind "item" only: the sub-item id granted (tether_moth, pitch_pot).
@export var item_id: StringName = &""

var is_collected: bool = false
var carrier: Node2D
var _age: float = 0.0


## Creates a pickup of `pickup_kind` at `at` (global) under `parent`. Dropped pickups time out.
static func spawn(
	pickup_kind: StringName, parent: Node, at: Vector2, timed: bool = true
) -> PickupBase:
	var pickup := PickupBase.new()
	pickup.kind = pickup_kind
	pickup.timeout = DEFAULT_TIMEOUT if timed else 0.0
	parent.add_child(pickup)
	pickup.global_position = at
	return pickup


func _init() -> void:
	monitoring = true
	collision_layer = Layers.PICKUP
	collision_mask = Layers.PICKUP_COLLECTOR


func _ready() -> void:
	add_to_group(&"pickups")
	if persistent_id != &"" and GameState.has_flag(flag_name()):
		queue_free()
		return
	var shape := CircleShape2D.new()
	shape.radius = PICKUP_RADIUS
	var node := CollisionShape2D.new()
	node.shape = shape
	add_child(node)
	if get_node_or_null(Placeholder.VISUAL_NAME) == null:
		var look := kind
		if kind == &"item":
			look = item_id if Placeholder.KINDS.has(item_id) else &"item"
		Placeholder.attach(self, look)


func flag_name() -> StringName:
	return StringName("picked_%s" % persistent_id)


func get_amount() -> int:
	if amount > 0:
		return amount
	match kind:
		&"ember":
			return 2
		&"brass_bit":
			return 1
		&"brass_coin":
			return 5
		&"pitch_pot_bundle":
			return 4
		_:
			return 1


## Applies the effect to GameState and frees the pickup. Returns false if already collected.
## `collector` is the node that receives it (the Player); it is passed to the effect hook.
func collect(collector: Node = null) -> bool:
	if is_collected:
		return false
	is_collected = true
	_apply_effect(collector)
	if persistent_id != &"":
		GameState.set_flag(flag_name())
	collected.emit(kind)
	Events.pickup_collected.emit(kind)
	queue_free()
	return true


## Marks the pickup as carried by `by`: it follows `by`, stops timing out and is ignored by
## other carriers. Collect it with collect(player) when the carrier arrives.
func begin_carry(by: Node2D) -> bool:
	if is_collected or carrier != null:
		return false
	carrier = by
	_age = 0.0
	_set_blink(false)
	return true


func end_carry() -> void:
	carrier = null


func is_carried() -> bool:
	return carrier != null and is_instance_valid(carrier)


func time_left() -> float:
	return INF if timeout <= 0.0 else maxf(0.0, timeout - _age)


func _apply_effect(_collector: Node) -> void:
	match kind:
		&"ember":
			GameState.heal(get_amount())
		&"brass_bit", &"brass_coin":
			GameState.add_currency(get_amount())
		&"pitch_pot_bundle":
			GameState.add_pitch_pots(get_amount())
		&"key":
			GameState.add_key(get_amount())
		&"wick_core":
			GameState.add_max_heart(1)
		&"item":
			if item_id != &"":
				GameState.acquire_item(item_id)


func _physics_process(delta: float) -> void:
	if is_collected:
		return
	if is_carried():
		global_position = carrier.global_position
	else:
		if carrier != null:
			carrier = null
		_age += delta
		if timeout > 0.0:
			if _age >= timeout:
				queue_free()
				return
			_set_blink(timeout - _age <= BLINK_TIME and int(_age / BLINK_INTERVAL) % 2 == 1)
	for area in get_overlapping_areas():
		if area is PickupCollector:
			_touch(area as PickupCollector)
			if is_collected:
				return


func _touch(collector: PickupCollector) -> void:
	if collector.carrier:
		if collector.owner_node != null and begin_carry(collector.owner_node):
			collector.picked.emit(self)
	elif collect(collector.owner_node):
		collector.picked.emit(self)


func _set_blink(hidden: bool) -> void:
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = not hidden
