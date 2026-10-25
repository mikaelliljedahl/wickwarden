extends Node2D
## Place at the settled Ninth Lantern (arena-local 960, 480). Left rekindles; right extinguishes.
## The choice is silent. Confirm while touching a pedestal, after the final boss flag, commits once.
## E1 owns the scene transition; World and the boss need no private API or signal connection.

signal ending_requested(choice: StringName)

const BOSS_FLAG := &"boss_cave_10_14_defeated"
const CHOICES: Array[StringName] = [&"rekindle", &"wickwarden"]
const DEATH_FADE_TIME := 2.0
const ENDING_SCENE := "res://scenes/ui/ending.tscn"
const OFFSETS := [Vector2(-192, 0), Vector2(192, 0)]

var dry_run: bool = false
var last_scene: String = ""
var _chosen: bool = false
var _reveal_left: float = 0.0
var _zones: Array[Area2D] = []
var _presentation: Node2D


func _ready() -> void:
	_presentation = Node2D.new()
	_presentation.name = "Visual"
	add_child(_presentation)
	_build_choice()
	GameState.flag_changed.connect(_on_flag_changed)
	_refresh()


func _physics_process(delta: float) -> void:
	if _reveal_left > 0.0:
		_reveal_left = maxf(0.0, _reveal_left - delta)
		_refresh()
	if not is_available() or not Input.is_action_just_pressed(&"confirm"):
		return
	for index in _zones.size():
		for body in _zones[index].get_overlapping_bodies():
			if body is Player and GameState.health > 0:
				choose(CHOICES[index])
				return


func is_available() -> bool:
	return (
		GameState.has_flag(BOSS_FLAG)
		and _reveal_left <= 0.0
		and not _chosen
		and not GameState.has_flag(&"ending_rekindle")
		and not GameState.has_flag(&"ending_wickwarden")
	)


## This validates the same real overlap used by physics; remote calls cannot select a lantern.
func choose(choice: StringName) -> bool:
	var index := CHOICES.find(choice)
	if not is_available() or index < 0:
		return false
	var touching := false
	for body in _zones[index].get_overlapping_bodies():
		if body is Player and GameState.health > 0:
			touching = true
	if not touching:
		return false
	var scene := load(ENDING_SCENE) as PackedScene
	if scene == null:
		push_warning("Ending: sequence scene is missing")
		return false
	_chosen = true
	GameState.set_flag(StringName("ending_%s" % choice))
	_refresh()
	last_scene = ENDING_SCENE
	ending_requested.emit(choice)
	if not dry_run:
		call_deferred("_start_sequence", scene)
	return true


func _start_sequence(scene: PackedScene) -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(scene)


func _on_flag_changed(flag: StringName, value: bool) -> void:
	# B10 publishes defeat when its specified two-second death fade begins.
	if flag == BOSS_FLAG and value:
		_reveal_left = DEATH_FADE_TIME
	_refresh()


func _refresh() -> void:
	_presentation.visible = is_available()


func _build_choice() -> void:
	for index in CHOICES.size():
		var zone := Area2D.new()
		zone.name = String(CHOICES[index])
		zone.position = OFFSETS[index]
		zone.collision_layer = 0
		zone.collision_mask = Layers.PLAYER_BODY
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(144, 144)
		shape.shape = rectangle
		zone.add_child(shape)
		add_child(zone)
		_zones.append(zone)
		var pedestal := Node2D.new()
		pedestal.position = OFFSETS[index]
		_presentation.add_child(pedestal)
		SpriteVisual.attach(pedestal, &"pedestal", 0.0, Vector2(96, 96))
		var lamp := Node2D.new()
		lamp.position = OFFSETS[index] + Vector2(0, -48)
		_presentation.add_child(lamp)
		var kind := StringName("arena_lantern_%s" % CHOICES[index])
		_register(kind, Color(1.0, 0.68, 0.23) if index == 0 else Color(0.6, 0.85, 1.0))
		SpriteVisual.attach(lamp, kind, 30.0)
		var light := PointLight2D.new()
		light.texture = LightTexture.make()
		light.texture_scale = LightTexture.scale_for(160.0)
		light.color = Color(1.0, 0.68, 0.23) if index == 0 else Color(0.6, 0.85, 1.0)
		lamp.add_child(light)
	_register(&"npc_corrow_wax", Color(0.76, 0.71, 0.57))
	var corrow := Node2D.new()
	_presentation.add_child(corrow)
	SpriteVisual.attach(corrow, &"npc_corrow_wax", 38.0)


func _register(kind: StringName, color: Color) -> void:
	if not Placeholder.has_kind(kind):
		Placeholder.register_kind(kind, {"shape": "diamond", "color": color, "radius": 38.0}, true)
