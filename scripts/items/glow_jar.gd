extends ItemBase
## Glow jar (lens). `use_item` throws one jar (jar.gd) THROW_REACH px along `facing`; the jar lights a
## GLOW_RADIUS px circle for six seconds and reveals the hidden props inside it. One jar at a time: a use is
## refused while a jar of this item is in the tree, flying or glowing. The item lives as long as its jar and
## finishes with it. No ammo, no damage. Spec: monsters-bosses-tools.md, section 5.5.

const JAR_SCRIPT := preload("res://scripts/items/jar.gd")
const JAR_SCENE_PATH := "res://scenes/items/jar.tscn"
const THROW_REACH := 288.0

var _jar: JAR_SCRIPT


func _init() -> void:
	item_id = &"glow_jar"


func _ready() -> void:
	JAR_SCRIPT.register_look()
	var visual := SpriteVisual.attach(self, &"glow_jar")
	# The jar draws itself; the item's own visual stays hidden.
	visual.visible = false


## True when a glowing jar lights `pos`: within GLOW_RADIUS of a jar in group `glow_light`.
static func is_lit(pos: Vector2) -> bool:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	for node in tree.get_nodes_in_group(&"glow_light"):
		var light := node as Node2D
		if light != null and light.global_position.distance_to(pos) <= JAR_SCRIPT.GLOW_RADIUS:
			return true
	return false


## Refuses while another jar of this item is in the tree. Otherwise the jar is thrown from the player.
func activate() -> bool:
	if active_count() > 1:
		return false
	var scene := load(JAR_SCENE_PATH) as PackedScene
	if scene == null:
		return false
	_jar = scene.instantiate() as JAR_SCRIPT
	if _jar == null:
		return false
	add_child(_jar)
	_jar.burnt_out.connect(finish)
	_jar.launch(facing, THROW_REACH)
	Audio.play_sfx(&"moth_launch", global_position)
	return true
