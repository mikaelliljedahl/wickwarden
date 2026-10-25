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
## Explicit opener link for entrances whose blocker is not centred on the trigger.
@export var blocker_path: NodePath
## Optional persistent opener requirement, using the opener's existing GameState flag.
@export var requires_flag: StringName = &""

## P14 presentation for built pocket entrances; routing and opener requirements stay scene-owned.
const POCKET_LOOKS := {
	"ow_1_2#shop": &"pocket_stall",
	"ow_1_5#cache": &"pocket_grotto",
	"ow_3_2#grate": &"pocket_plain",
	"ow_3_3#hut": &"pocket_hut",
	"ow_4_1#cache": &"pocket_grotto",
	"ow_5_5#cache": &"pocket_grotto",
	"ow_6_0#shop": &"pocket_grotto",
	"ow_6_5#shop": &"pocket_lighthouse",
	"ow_7_2#bag": &"pocket_grotto",
	"ow_7_3#grotto": &"pocket_grotto",
	"ow_8_5#ward": &"pocket_stairs",
}

var _blockers: Array[WeakRef] = []
var _blockers_bound := false


func _init() -> void:
	collision_layer = 0
	collision_mask = Layers.PLAYER_BODY


func _ready() -> void:
	var rect := RectangleShape2D.new()
	rect.size = size
	var shape := CollisionShape2D.new()
	shape.shape = rect
	add_child(shape)
	var art := entrance_kind()
	SpriteVisual.attach(self, art if SpriteVisual.has_art(art) else &"door_marker", 0.0, size)
	if _uses_building_door():
		get_node(Placeholder.VISUAL_NAME).visible = false


## These painted building thresholds align with the unchanged entrance triggers.
func _uses_building_door() -> bool:
	return target_room in [&"ow_1_2#shop", &"ow_3_3#hut"]


## Select art from the actual destination and host, never from the gate's current state.
func entrance_kind() -> StringName:
	if get_parent().get("look") == &"hidden_stairs":
		return &"pocket_stairs"
	if _in_dark_room():
		return &"cave_exit"
	var host: Node = get_parent()
	while host != null and not host is Room:
		host = host.get_parent()
	if host is Room and "#" in String(host.room_id):
		return &"pocket_plain"
	return POCKET_LOOKS.get(String(target_room), &"cave_mouth")


## True when the nearest Room above this door is dark (the cave side).
func _in_dark_room() -> bool:
	var node: Node = get_parent()
	while node != null:
		if node is Room:
			return (node as Room).dark
		node = node.get_parent()
	return false


func _physics_process(_delta: float) -> void:
	var gate_open := _gate_is_open()
	# A concealed mouth appears only after its opener is removed.
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = gate_open and not _uses_building_door()
	if not gate_open or not has_overlapping_bodies():
		return
	var world := get_tree().get_first_node_in_group(&"world")
	if world != null and world.has_method("warp_to") and not world.call("is_transitioning"):
		world.call("warp_to", target_room, target_spawn, fade)


## Bind once, after all sibling openers have completed _ready. Older scenes put the opener
## at exactly the door origin; this identifies the opener, never a player-distance threshold.
func _gate_is_open() -> bool:
	if not _blockers_bound:
		if not blocker_path.is_empty():
			var blocker := get_node_or_null(blocker_path)
			if blocker == null:
				return false
			_blockers.append(weakref(blocker))
		else:
			for sibling in get_parent().get_children():
				if sibling is StaticBody2D and sibling.position == position:
					_blockers.append(weakref(sibling))
		_blockers_bound = true
	if requires_flag != &"" and not GameState.has_flag(requires_flag):
		return false
	for reference in _blockers:
		var blocker: Node = reference.get_ref()
		# Cut bushes and shattered rocks are freed; retained openers expose their state.
		if blocker == null:
			continue
		if blocker is Bush:
			if not blocker.is_cut:
				return false
		elif blocker.get("is_open") != null:
			if not bool(blocker.get("is_open")):
				return false
		elif blocker is CollisionObject2D:
			if (blocker.collision_layer & Layers.WORLD) != 0:
				for child in blocker.get_children():
					if child is CollisionShape2D and not child.disabled:
						return false
	return true
