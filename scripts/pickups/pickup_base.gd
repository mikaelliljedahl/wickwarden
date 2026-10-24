class_name PickupBase
extends Area2D
## A pickup. One script for every kind in plan section 5; `kind` selects look and effect.
##
## Kinds: ember, brass_bit, brass_coin, pitch_pot_bundle, key, wick_core, item, big_key, fragment,
## pot_bag (raises the pitch pot limit by 4, once per bag) and slug_bundle (+6 sling slugs).
## `scope` is the key scope of a `key` ("ow" or "cN") and the cave of a `big_key` or `fragment`.
## `requires_flag` (placed pickups): the pickup is invisible and inactive until that flag is set.
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
## Ammo granted when a placed sub-item pickup is collected for the first time. The plan says pitch pot
## ammo "starts 0" (GameState.acquire_item still grants none); the pickup in the world gives 6 so
## the first cracked wall can be opened without farming drops (WP7 decision).
const ITEM_FOUND_AMMO := {&"pitch_pot": 6}
const KINDS: Array[StringName] = [
	&"ember", &"brass_bit", &"brass_coin", &"pitch_pot_bundle", &"key", &"wick_core", &"item",
	&"big_key", &"fragment", &"pot_bag", &"slug_bundle"
]

@export var kind: StringName = &"brass_bit"
@export var amount: int = 0  # 0 = default for the kind
## Seconds until it vanishes. 0 = never (placed pickups).
@export var timeout: float = 0.0
## Non-empty: persistent placed pickup, flag "picked_<id>".
@export var persistent_id: StringName = &""
## Kind "item" only: the sub-item id granted (tether_moth, pitch_pot).
@export var item_id: StringName = &""
## Key scope: "ow" or a cave "cN". Kind `key` spends in that scope; `big_key` and `fragment` name the cave.
@export var scope: StringName = &"ow"
## Non-empty: the pickup stays invisible and inactive until this flag is set (for example a boss flag).
@export var requires_flag: StringName = &""

var is_collected: bool = false
var carrier: Node2D
var _age: float = 0.0
var _gated: bool = false  # true while requires_flag is not set


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
	_register_kinds()
	if get_node_or_null(Placeholder.VISUAL_NAME) == null:
		var look := kind
		if kind == &"item":
			var has_item_look := SpriteVisual.has_art(item_id) or Placeholder.has_kind(item_id)
			look = item_id if has_item_look else &"item"
		SpriteVisual.attach(self, look)
	if requires_flag != &"":
		GameState.flag_changed.connect(_on_flag_changed)
		_refresh_gate()


func _exit_tree() -> void:
	if GameState.flag_changed.is_connected(_on_flag_changed):
		GameState.flag_changed.disconnect(_on_flag_changed)


## Placeholder looks of the kinds that this script adds (placeholder visuals only).
static func _register_kinds() -> void:
	if not Placeholder.has_kind(&"big_key"):
		Placeholder.register_kind(
			&"big_key", {"shape": "diamond", "color": Color(1.0, 0.75, 0.25), "radius": 22.0}
		)
	if not Placeholder.has_kind(&"fragment"):
		Placeholder.register_kind(
			&"fragment", {"shape": "diamond", "color": Color(0.7, 0.55, 1.0), "radius": 16.0}
		)
	if not Placeholder.has_kind(&"pot_bag"):
		Placeholder.register_kind(
			&"pot_bag", {"shape": "rect", "color": Color(0.55, 0.4, 0.22), "size": Vector2(34, 30)}
		)
	if not Placeholder.has_kind(&"slug_bundle"):
		Placeholder.register_kind(
			&"slug_bundle", {"shape": "diamond", "color": Color(0.85, 0.78, 0.55), "radius": 12.0}
		)


## Invisible and inactive while `requires_flag` is unset; shown and collectable once it is set.
func _refresh_gate() -> void:
	_gated = requires_flag != &"" and not GameState.has_flag(requires_flag)
	visible = not _gated


func _on_flag_changed(flag: StringName, _value: bool) -> void:
	if flag == requires_flag:
		_refresh_gate()


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
		&"slug_bundle":
			return 6
		_:
			return 1


## Applies the effect to GameState and frees the pickup. Returns false if already collected.
## `collector` is the node that receives it (the Player); it is passed to the effect hook.
func collect(collector: Node = null) -> bool:
	if is_collected or _gated:
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
	if is_collected or _gated or carrier != null:
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
			GameState.add_key(get_amount(), scope)
		&"big_key":
			if not GameState.add_big_key(scope):
				push_error("PickupBase: big_key needs a cave scope, got %s" % scope)
		&"fragment":
			if not GameState.add_fragment(scope):
				push_error("PickupBase: fragment needs a cave scope 1-9, got %s" % scope)
		&"wick_core":
			GameState.add_max_heart(1)
		&"pot_bag":
			GameState.add_pot_bag()
		&"slug_bundle":
			GameState.add_slugs(get_amount())
		&"item":
			if item_id != &"":
				var first_time := not GameState.has_item(item_id)
				GameState.acquire_item(item_id)
				if first_time and ITEM_FOUND_AMMO.has(item_id):
					GameState.add_pitch_pots(int(ITEM_FOUND_AMMO[item_id]))


func _physics_process(delta: float) -> void:
	if is_collected or _gated:
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
