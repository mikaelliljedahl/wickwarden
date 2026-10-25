extends ItemBase
## Cinder wick (candle). `use_item` roots Tamsin for ROOT_TIME s (hands up), then rolls one flame along `facing`
## (flame.gd). The item lives as long as its flame: it finishes when the flame is spent, so the room change frees
## both. One flame at a time; no ammo and no cooldown beyond the flame itself.

const FLAME_SCENE_PATH := "res://scenes/items/flame.tscn"
const FLAME_SCRIPT := preload("res://scripts/items/flame.gd")
const ROOT_TIME := 0.2

var _rooting: bool = false
var _root_left: float = 0.0
var _flame: FLAME_SCRIPT


func _init() -> void:
	item_id = &"cinder_wick"


func _ready() -> void:
	if not Placeholder.has_kind(&"cinder_wick"):
		Placeholder.register_kind(
			&"cinder_wick", {"shape": "arc", "color": Color(1.0, 0.6, 0.25, 0.7), "radius": 28.0}
		)
	var cue_script := load("res://scripts/art/tool_cue_visual.gd") as GDScript
	if cue_script != null:
		cue_script.call(&"attach", self, &"cinder_wick", facing)


## Refuses while a flame of this item is alive (this node counts as the first). Nothing is spent.
func activate() -> bool:
	if active_count() > 1:
		return false
	_rooting = true
	_root_left = ROOT_TIME
	_set_still(true)
	return true


func _physics_process(delta: float) -> void:
	if not _rooting:
		return
	_root_left -= delta
	if _root_left > 0.0:
		return
	_rooting = false
	_set_still(false)
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = false
	_launch_flame()


func _exit_tree() -> void:
	if _rooting:
		_set_still(false)
	_rooting = false


func _launch_flame() -> void:
	var scene := load(FLAME_SCENE_PATH) as PackedScene
	if scene == null:
		finish()
		return
	_flame = scene.instantiate() as FLAME_SCRIPT
	if _flame == null:
		finish()
		return
	add_child(_flame)
	_flame.spent.connect(finish)
	_flame.launch(global_position, facing)


## Holds the player still (speed scale 0) during the root. Only walking is held; the hook is not.
func _set_still(on: bool) -> void:
	if not is_instance_valid(player):
		return
	var walker := player as Player
	if walker != null:
		walker.set_speed_scale(self, 0.0 if on else 1.0)
