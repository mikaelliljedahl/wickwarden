extends ItemBase
## Reel line (monsters-bosses-tools.md 5.8). `use_item` fires a reel tip (reel_tip.gd) along `facing`. The first
## anchor ring it reaches, in range of the firing point, pulls Tamsin to PULL_STOP px in front of the ring at
## PULL_SPEED px/s (external motion, hurtbox off), unless that landing spot is not solid floor (a wall, water or a
## pit): then the pull is refused and the tip reels back. Otherwise the tip reels back and hands over the small
## pickups it carried. One line at a time. The item lingers COOLDOWN_TIME s after the line is settled, so the
## next use is refused until then; the item finishes when the cooldown ends.

const TIP_SCENE_PATH := "res://scenes/items/reel_tip.tscn"
const TIP_SCRIPT := preload("res://scripts/items/reel_tip.gd")
const COOLDOWN_TIME := 0.3
const PULL_SPEED := 900.0
const PULL_STOP := 72.0

var _tip: TIP_SCRIPT
## Firing point of the line (the player's position when fired); the anchor range is measured from it.
var _fire_point: Vector2 = Vector2.ZERO
## Seconds left of the cooldown after the line is settled; -1 while the line is still out.
var _cooldown_left: float = -1.0


func _init() -> void:
	item_id = &"reel_line"


func _ready() -> void:
	if not Placeholder.has_kind(&"reel_line"):
		Placeholder.register_kind(
			&"reel_line",
			{"shape": "ring", "color": Color(0.85, 0.8, 0.6, 0.7), "radius": 26.0},
			true
		)
	SpriteVisual.attach(self, &"reel_line")


## Refuses while a line of this item is out or cooling down, or with no player. Nothing is spent.
func activate() -> bool:
	if active_count() > 1 or not is_instance_valid(player):
		return false
	var scene := load(TIP_SCENE_PATH) as PackedScene
	if scene == null:
		return false
	var tip := scene.instantiate() as TIP_SCRIPT
	if tip == null:
		return false
	add_child(tip)
	_tip = tip
	_fire_point = player.global_position
	tip.anchored.connect(_on_anchored)
	tip.returned.connect(_settle)
	tip.launch(player, facing)
	Audio.play_sfx(&"moth_launch", global_position)
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = false
	return true


func _physics_process(delta: float) -> void:
	if _cooldown_left < 0.0:
		return
	_cooldown_left -= delta
	if _cooldown_left <= 0.0:
		finish()


## A ring took the tip: pull Tamsin to it, or refuse and reel the tip back.
func _on_anchored(ring: Node) -> void:
	if _pull_to(ring):
		_settle()
	elif _tip != null:
		_tip.retract()


## The pull: in range of the firing point, at least PULL_STOP px away, and the landing spot is solid floor.
func _pull_to(ring: Node) -> bool:
	var anchor: Variant = ring
	var walker := player as Player
	if walker == null or not anchor.is_in_range(_fire_point):
		return false
	var ring_pos: Vector2 = anchor.get_anchor_position()
	var to_ring := ring_pos - walker.global_position
	if to_ring.length() <= PULL_STOP:
		return false
	var landing := ring_pos - to_ring.normalized() * PULL_STOP
	if not _is_solid_floor(landing):
		return false
	var path: Array[Vector2] = [landing]
	# Only a validated anchor pull clears hazards. Ordinary path motion remains grounded.
	return walker.begin_external_motion(path, PULL_SPEED, {"airborne": true, "hurtbox": false})


## Solid floor: no WORLD or WATER body and no pit zone at `spot`.
func _is_solid_floor(spot: Vector2) -> bool:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = spot
	query.collision_mask = Layers.WORLD | Layers.WATER
	query.collide_with_areas = false
	if not get_world_2d().direct_space_state.intersect_point(query, 1).is_empty():
		return false
	for pit in get_tree().get_nodes_in_group(&"pit_zone"):
		if pit.holds(spot):
			return false
	return true


## The line is over: hand over the carried pickups, free the tip and start the cooldown.
func _settle() -> void:
	if _cooldown_left >= 0.0:
		return
	if _tip != null:
		for pickup in _tip.take_carried():
			pickup.collect(player)
		_tip.queue_free()
		_tip = null
	_cooldown_left = COOLDOWN_TIME
