extends Node2D
## A pit or a ravine: a hole that Tamsin falls into when her body touches it. A fall costs 2 half-hearts
## and puts her back on the last safe spot of the room, the place where she last stood on foot outside
## every pit of that room. A skitter-boots leap (Player.is_airborne()) over a pit does nothing; a leap
## that lands in a pit falls like a walk. A dead player is left alone.
##
## Geometry, not a physics overlap: the body touches the pit when its centre is within the footprint
## grown by the body radius. This is exact on the frame of a move (an Area2D overlap lags one frame).
## Visual: the Placeholder kind `look` (pit or ravine). Scenes set it; the kinds are registered here.

## Footprint in px, centred on the origin.
@export var size: Vector2 = Vector2(192, 192)
## Placeholder kind of the look: pit or ravine.
@export var look: StringName = &"pit"

const FALL_DAMAGE := 2  # half-hearts: one heart

## Physics frame of the last fall. Two pits that both hold the player fall the player once.
static var _last_fall_frame: int = -1

## Last safe position of this zone's room: where the player stood on foot, outside every pit.
var _safe_position: Vector2 = Vector2.ZERO
var _has_safe: bool = false


func _init() -> void:
	_register_looks()


func _ready() -> void:
	add_to_group(&"pit_zone")
	Placeholder.attach(self, look, 0.0, size)


func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player == null or player.is_dead() or player.is_airborne():
		return
	var pos := player.global_position
	if holds(pos):
		_fall(player)
	elif not player.is_external_motion() and _in_room(pos) and not _held_by_any_pit(pos):
		_safe_position = pos
		_has_safe = true


## True when a body with its centre at `pos` touches this pit (footprint grown by the body radius).
func holds(pos: Vector2) -> bool:
	return Rect2(global_position - size * 0.5, size).grow(Player.BODY_RADIUS).has_point(pos)


## The fall: 2 half-hearts (no knockback), then the player goes back to the safe spot. If the fall
## kills her, she stays where she is and the death flow of the World takes over.
func _fall(player: Player) -> void:
	if Engine.get_physics_frames() == _last_fall_frame:
		return
	_last_fall_frame = Engine.get_physics_frames()
	var dest := _safe_position if _has_safe else _fallback_position()
	player.take_damage(FALL_DAMAGE, global_position, 0.0)
	if not player.is_dead():
		player.place_at(dest)


## True when any pit of the tree touches `pos`. The pit that holds the player does the falling.
func _held_by_any_pit(pos: Vector2) -> bool:
	for pit in get_tree().get_nodes_in_group(&"pit_zone"):
		if pit.holds(pos):
			return true
	return false


## True when `pos` is inside the room that holds this zone. Without a room (tests) every spot counts.
func _in_room(pos: Vector2) -> bool:
	var room := _owning_room()
	return room == null or Rect2(room.global_position, WorldConst.ROOM_SIZE).has_point(pos)


## Used only when the player has never stood on safe ground in this room (for example a spawn
## inside a pit): the room's entry point, or the zone's own spot without a room.
func _fallback_position() -> Vector2:
	var room := _owning_room()
	if room == null:
		return global_position
	return room.get_spawn_position()


func _owning_room() -> Room:
	var node := get_parent()
	while node != null:
		if node is Room:
			return node as Room
		node = node.get_parent()
	return null


static func _register_looks() -> void:
	if Placeholder.has_kind(&"pit"):
		return
	Placeholder.register_kind(
		&"pit", {"shape": "rect", "color": Color(0.05, 0.05, 0.08), "size": Vector2(192, 192)}, true
	)
	Placeholder.register_kind(
		&"ravine", {"shape": "rect", "color": Color(0.08, 0.07, 0.11), "size": Vector2(576, 96)}, true
	)
