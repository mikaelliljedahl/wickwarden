class_name ItemRegistry
extends RefCounted
## Maps sub-item ids to their scene paths. The Player knows nothing about concrete items: it asks
## this registry for a PackedScene (loaded with load(), null-checked), so WP6 can deliver the
## scenes later without editing the Player. A missing scene means "item not implemented yet" and
## using it is a silent no-op.

## Registry order (the item subscreen grid and the quick-switch cycle), display names and scene
## paths. All ten sub-items are listed up front (code contract 16.5); a tool WP only adds its scene.
## `register()` does the same at runtime (tests).
static var items: Dictionary = {
	&"tether_moth": {"scene": "res://scenes/items/tether_moth.tscn", "name": "Tether Moth"},
	&"pitch_pot": {"scene": "res://scenes/items/pitch_pot.tscn", "name": "Pitch Pot"},
	&"cinder_wick": {"scene": "res://scenes/items/cinder_wick.tscn", "name": "Cinder Wick"},
	&"tallow_sling": {"scene": "res://scenes/items/tallow_sling.tscn", "name": "Tallow Sling"},
	&"reed_raft": {"scene": "res://scenes/items/reed_raft.tscn", "name": "Reed Raft"},
	&"heft_mitts": {"scene": "res://scenes/items/heft_mitts.tscn", "name": "Heft Mitts"},
	&"glow_jar": {"scene": "res://scenes/items/glow_jar.tscn", "name": "Glow Jar"},
	&"lantern_chime": {"scene": "res://scenes/items/lantern_chime.tscn", "name": "Lantern Chime"},
	&"skitter_boots": {"scene": "res://scenes/items/skitter_boots.tscn", "name": "Skitter Boots"},
	&"reel_line": {"scene": "res://scenes/items/reel_line.tscn", "name": "Reel Line"},
}


static func register(id: StringName, scene_path: String, display_name: String = "") -> void:
	items[id] = {"scene": scene_path, "name": display_name if display_name != "" else String(id)}


static func unregister(id: StringName) -> void:
	items.erase(id)


static func ids() -> Array:
	return items.keys()


static func display_name(id: StringName) -> String:
	return String(items.get(id, {}).get("name", id))


## The item scene, or null if the id is unknown or the scene file does not exist (yet).
static func get_scene(id: StringName) -> PackedScene:
	if not items.has(id):
		return null
	var path := String(items[id]["scene"])
	if not ResourceLoader.exists(path):
		return null
	return load(path) as PackedScene


## Instantiates an item scene as an ItemBase, or returns null. The caller owns the node.
static func create(id: StringName) -> ItemBase:
	var scene := get_scene(id)
	if scene == null:
		return null
	var node := scene.instantiate()
	var item := node as ItemBase
	if item == null:
		node.free()
	return item
