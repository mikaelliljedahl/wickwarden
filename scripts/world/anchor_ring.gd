extends Node2D
## Anchor ring: the iron ring that a reel line (`reel_line`, monsters file 5.8) hooks onto. The ring is in
## group `anchor_ring`. Its hurtbox sits on PROP_HURTBOX and takes only `reel` hits (the hook tip). Each
## accepted hit emits `hooked`; the reel item decides what the hit does. The ring moves nothing itself and
## holds no state, so rooms can unload at any time.
##
## Queries for the reel item: `get_anchor_position()` is the world point the line runs to, and
## `is_in_range(from)` tells whether a firing point is within `max_range`.

signal hooked(hitbox: Hitbox)

const GROUP := &"anchor_ring"
const HIT_KIND := &"reel"
const RING_RADIUS := 24.0
const HURT_RADIUS := 32.0
const RING_KIND := &"anchor_ring"
const POCKET_KIND := &"anchor_pocket"

## Look of the ring: `anchor_ring` (cliff and shore) or `anchor_pocket` (a cache alcove). A Placeholder kind.
@export var look: StringName = RING_KIND
## Largest distance in px from a firing point to which the ring can be reached. 0 means no limit.
@export var max_range: float = 0.0

var hurtbox: Hurtbox


func _ready() -> void:
	add_to_group(GROUP)
	_register_kinds()
	hurtbox = Hurtbox.new()
	hurtbox.name = "Hurtbox"
	hurtbox.team = Layers.Team.NEUTRAL
	hurtbox.add_circle(HURT_RADIUS)
	hurtbox.filter = _accepts_hit
	add_child(hurtbox)
	hurtbox.hurt.connect(_on_hurt)
	Placeholder.attach(self, look, RING_RADIUS)


## World position of the ring: the point the reel line runs to.
func get_anchor_position() -> Vector2:
	return global_position


## True when the firing point `from` (world coordinates) is within `max_range`. Always true when `max_range`
## is 0.
func is_in_range(from: Vector2) -> bool:
	return max_range <= 0.0 or from.distance_to(global_position) <= max_range


func _accepts_hit(hitbox: Hitbox) -> bool:
	return hitbox.kind == HIT_KIND


func _on_hurt(hitbox: Hitbox) -> void:
	hooked.emit(hitbox)


static func _register_kinds() -> void:
	if not Placeholder.has_kind(RING_KIND):
		Placeholder.register_kind(
			RING_KIND,
			{"shape": "ring", "color": Color(0.5, 0.52, 0.56), "radius": RING_RADIUS},
			true
		)
	if not Placeholder.has_kind(POCKET_KIND):
		Placeholder.register_kind(
			POCKET_KIND,
			{"shape": "ring", "color": Color(0.85, 0.66, 0.3), "radius": RING_RADIUS},
			true
		)
