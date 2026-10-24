extends ItemBase
## Tallow sling (bow). `use_item` fires one tallow slug (slug.gd) along `facing` and spends one slug
## (GameState.spend_slug()). One slug on screen at a time; with no slugs the use is refused and nothing is
## spent. Tamsin stands still for RECOIL_TIME. There is no other cooldown. The item lives as long as its
## slug: it finishes when the slug is spent, so the room change frees both.

const SLUG_SCENE_PATH := "res://scenes/items/slug.tscn"
const SLUG_SCRIPT := preload("res://scripts/items/slug.gd")
const RECOIL_TIME := 0.12
## The slug starts this far ahead of the player, so it does not overlap Tamsin's own hurtbox.
const SPAWN_DISTANCE := 40.0

var _recoil_left: float = 0.0
var _slug: SLUG_SCRIPT


func _init() -> void:
	item_id = &"tallow_sling"


func _ready() -> void:
	if not Placeholder.has_kind(&"tallow_sling"):
		Placeholder.register_kind(
			&"tallow_sling", {"shape": "arc", "color": Color(0.85, 0.65, 0.35, 0.7), "radius": 28.0}
		)
	SpriteVisual.attach(self, &"tallow_sling")


## Refuses while a slug is on screen or with no slugs left. The limit is checked first, and the slug
## is spent only when it is really fired, so a refused use costs nothing.
func activate() -> bool:
	if active_count() > 1:
		return false
	var scene := load(SLUG_SCENE_PATH) as PackedScene
	if scene == null or not GameState.spend_slug():
		return false
	_slug = scene.instantiate() as SLUG_SCRIPT
	if _slug == null:
		return false
	add_child(_slug)
	_slug.global_position = global_position + facing * SPAWN_DISTANCE
	_slug.spent.connect(finish)
	_slug.launch(facing)
	_set_still(true)
	_recoil_left = RECOIL_TIME
	Audio.play_sfx(&"moth_launch", global_position)
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as Node2D
	if visual != null and visual.has_method(&"set_facing"):
		visual.call(&"set_facing", facing)
	return true


func _physics_process(delta: float) -> void:
	if _recoil_left <= 0.0:
		return
	_recoil_left -= delta
	if _recoil_left <= 0.0:
		_set_still(false)
		var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
		if visual != null:
			visual.visible = false


func _exit_tree() -> void:
	if _recoil_left > 0.0:
		_set_still(false)
	_recoil_left = 0.0


## Holds the player still (speed scale 0) for the recoil. Only walking is held; the hook is not.
func _set_still(on: bool) -> void:
	if not is_instance_valid(player) or not player is Player:
		return
	(player as Player).set_speed_scale(self, 0.0 if on else 1.0)
