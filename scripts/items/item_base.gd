class_name ItemBase
extends Node2D
## Base class of sub-item instances (tether moth, pitch pot, ...). One instance is created per
## USE of the item. The Player instantiates the item scene registered in ItemRegistry, sets
## `player` and `facing`, adds it to the player's parent and calls activate().
##
## Contract for item authors (WP6):
##   * Extend ItemBase, set `item_id` in _init(). No class_name.
##   * activate() returns false to REFUSE the use (no ammo, limit reached); the Player then frees
##     the node. Spend ammo inside activate() (GameState.spend_pitch_pot()).
##   * Limits like "one moth at a time" are checked in activate() with active_count().
##   * Items add themselves to the group "item_<id>" (done in _enter_tree) and are freed by the
##     World on every room change.
##   * Item scenes: root Node2D (or Area2D / CharacterBody2D) with the script attached. The root
##     of the scene must extend ItemBase.

signal finished

var item_id: StringName = &""
## The Player that used the item (typed loosely to avoid a script cycle; it is a Player).
var player: Node2D
## Cardinal facing of the player at the time of use (Vector2.UP/DOWN/LEFT/RIGHT).
var facing: Vector2 = Vector2.DOWN


func _enter_tree() -> void:
	add_to_group(&"items")
	if item_id != &"":
		add_to_group(group_name(item_id))


static func group_name(id: StringName) -> StringName:
	return StringName("item_%s" % id)


## Number of live instances of this item in the tree (including this one if already added).
func active_count() -> int:
	return get_tree().get_nodes_in_group(group_name(item_id)).size()


## Start the item's effect. Called once, after the node is in the tree with `player` and `facing`
## set. Return false to refuse the use.
func activate() -> bool:
	return true


## Call when the item is done; frees it.
func finish() -> void:
	finished.emit()
	queue_free()
