extends ItemBase
## Lantern chime. A press becomes a ring when released; holding for 1.2 seconds opens the visited
## cave-mouth list outside a boss arena. The ring itself lasts 0.5 seconds and has a 1.2 second
## cooldown. Spec: monsters-bosses-tools.md, section 5.6.

const HOLD_TIME := 1.2
const COOLDOWN_TIME := 1.2
const WAVE_SCENE_PATH := "res://scenes/items/chime_wave.tscn"
const WARP_PICKER_SCENE_PATH := "res://scenes/ui/warp_picker.tscn"
const BOSS_ARENAS: Array[StringName] = [
	&"cave_1_8",
	&"cave_2_9",
	&"cave_3_9",
	&"cave_4_10",
	&"cave_5_10",
	&"cave_6_11",
	&"cave_7_11",
	&"cave_8_12",
	&"cave_9_10",
	&"cave_10_14",
]

var _held_for: float = 0.0
var _resolved: bool = false
var _cooldown_left: float = 0.0
var _wave_finished: bool = true


func _init() -> void:
	item_id = &"lantern_chime"


func _ready() -> void:
	_register_kind()
	SpriteVisual.attach(self, &"lantern_chime")


func activate() -> bool:
	if active_count() > 1:
		return false
	_held_for = 0.0
	_resolved = false
	_cooldown_left = 0.0
	_wave_finished = true
	return true


func _physics_process(delta: float) -> void:
	if _resolved:
		if _cooldown_left > 0.0:
			_cooldown_left = maxf(0.0, _cooldown_left - delta)
		if _cooldown_left <= 0.0 and _wave_finished:
			finish()
		return
	if Input.is_action_pressed(&"use_item"):
		_held_for += delta
		if _held_for >= HOLD_TIME:
			_resolved = true
			if not _is_boss_arena():
				_open_warp_picker()
			finish()
		return
	_resolved = true
	_ring()


func _ring() -> void:
	var scene := load(WAVE_SCENE_PATH) as PackedScene
	if scene == null:
		finish()
		return
	var wave := scene.instantiate() as Node2D
	if wave == null:
		finish()
		return
	_cooldown_left = COOLDOWN_TIME
	_wave_finished = false
	add_child(wave)
	wave.global_position = global_position
	if wave.has_method(&"start"):
		wave.call(&"start")
	if wave.has_signal(&"finished"):
		wave.connect(&"finished", Callable(self, &"_on_wave_finished"))


func _on_wave_finished() -> void:
	_wave_finished = true


func _open_warp_picker() -> void:
	var world := get_tree().get_first_node_in_group(&"world") as World
	if world == null or world.phase != World.Phase.NONE:
		return
	var picker_scene := load(WARP_PICKER_SCENE_PATH) as PackedScene
	if picker_scene == null:
		return
	var picker := picker_scene.instantiate()
	if picker == null:
		return
	world.add_child(picker)
	if not picker.has_method(&"open") or not bool(picker.call(&"open", world)):
		picker.queue_free()


func _is_boss_arena() -> bool:
	var world := get_tree().get_first_node_in_group(&"world") as World
	return world != null and BOSS_ARENAS.has(world.get_current_room_id())


static func _register_kind() -> void:
	if not Placeholder.has_kind(&"lantern_chime"):
		Placeholder.register_kind(
			&"lantern_chime", {"shape": "diamond", "color": Color(0.95, 0.82, 0.36), "radius": 18.0}
		)
