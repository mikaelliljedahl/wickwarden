class_name RoomDoor
extends Area2D
## A trigger that warps the player to another room (cave entrance/exit, stairs). The World fades
## to black (0.3 s), switches rooms, places the player at the target room's spawn marker and
## fades back in. Put the target spawn OUTSIDE the target door's own trigger, or the player
## bounces back.
##
## `target_spawn` names a Marker2D under the target room's `Spawns` container ("Default" = room
## centre). Needs a World in the tree (group "world"); without one it does nothing.

@export var target_room: StringName = &""
@export var target_spawn: StringName = &"Default"
@export var size: Vector2 = Vector2(96, 96)
## False: switch rooms instantly without the fade.
@export var fade: bool = true


func _init() -> void:
	collision_layer = 0
	collision_mask = Layers.PLAYER_BODY


func _ready() -> void:
	var rect := RectangleShape2D.new()
	rect.size = size
	var shape := CollisionShape2D.new()
	shape.shape = rect
	add_child(shape)
	# Every RoomDoor is a cave door: the cave side is cave_exit, the overworld side cave_mouth.
	var art := &"cave_exit" if _in_dark_room() else &"cave_mouth"
	SpriteVisual.attach(self, art if SpriteVisual.has_art(art) else &"door_marker", 0.0, size)


## True when the nearest Room above this door is dark (the cave side).
func _in_dark_room() -> bool:
	var node: Node = get_parent()
	while node != null:
		if node is Room:
			return (node as Room).dark
		node = node.get_parent()
	return false


func _physics_process(_delta: float) -> void:
	if not has_overlapping_bodies():
		return
	var world := get_tree().get_first_node_in_group(&"world")
	if world != null and world.has_method("warp_to") and not world.call("is_transitioning"):
		world.call("warp_to", target_room, target_spawn, fade)
