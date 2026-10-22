class_name World
extends Node2D
## Holds every room, the player, the camera, the HUD and the pause menu, and runs room changes.
##
## * Edge crossing: the camera slides to the neighbouring room in 0.45 s. The player and both
##   rooms are frozen (process_mode DISABLED) during the slide; the player is moved to 1 tile
##   inside the new room.
## * warp_to(): fade to black 0.3 s, switch rooms, fade back 0.3 s (cave doors, respawn).
## * Death: the player dies, 0.8 s later the world fades out, resets health to full and puts the
##   player in the start room.
##
## The screen shows the room at y 120..1080 under the 120 px HUD band: the camera centre is the
## room origin + WorldConst.CAMERA_OFFSET. Timing is driven from _physics_process so tests are
## deterministic.

signal room_changed(room_id: StringName)
signal transition_finished
signal player_respawned

enum Phase { NONE, SLIDE, FADE_OUT, FADE_IN, DEATH_WAIT }

const ROOM_PATHS := {
	&"ow_0_0": "res://scenes/world/rooms/ow_0_0.tscn",
	&"ow_1_0": "res://scenes/world/rooms/ow_1_0.tscn",
	&"ow_2_0": "res://scenes/world/rooms/ow_2_0.tscn",
	&"ow_0_1": "res://scenes/world/rooms/ow_0_1.tscn",
	&"ow_1_1": "res://scenes/world/rooms/ow_1_1.tscn",
	&"ow_2_1": "res://scenes/world/rooms/ow_2_1.tscn",
	&"cave_1": "res://scenes/world/rooms/cave_1.tscn",
}
const START_ROOM := &"ow_0_0"
const START_SPAWN := &"Default"
const DEATH_WAIT := 0.8
const DARK_COLOR := Color(0.06, 0.06, 0.12)
const PLAYER_SCENE := "res://scenes/player/player.tscn"
const HUD_SCENE := "res://scenes/ui/hud.tscn"
const PAUSE_SCENE := "res://scenes/ui/pause_menu.tscn"
## Launch argument (`godot --path . -- --dev-mode`, `make dev`): all sub-items, 10 pitch pots, 5 keys
## and F1 toggles the hitbox / hurtbox overlay. Normal runs never see it.
const DEV_ARG := "--dev-mode"
const DEV_KEYS := 5
const DEV_PITCH_POTS := 10

var player: Player
var camera: Camera2D
var current_room: Room
var rooms: Dictionary = {}  # room id -> Room
var phase: Phase = Phase.NONE
var hud: Node
var fade_rect: ColorRect
var dev_mode: bool = false
var debug_overlay: DebugOverlay

var _rooms_node: Node2D
var _actors: Node2D
var _modulate: CanvasModulate
var _by_grid: Dictionary = {}  # Vector2i -> Room
var _t: float = 0.0
var _next_room: Room
var _cam_from: Vector2
var _cam_to: Vector2
var _player_from: Vector2
var _player_to: Vector2
var _warp_spawn: StringName = START_SPAWN
var _warp_switched: bool = false
var _respawn_pending: bool = false


func _ready() -> void:
	add_to_group(&"world")
	y_sort_enabled = true
	_rooms_node = Node2D.new()
	_rooms_node.name = "Rooms"
	_rooms_node.y_sort_enabled = true
	add_child(_rooms_node)
	_actors = Node2D.new()
	_actors.name = "Actors"
	_actors.y_sort_enabled = true
	add_child(_actors)
	_modulate = CanvasModulate.new()
	_modulate.name = "DarkModulate"
	add_child(_modulate)
	camera = Camera2D.new()
	camera.name = "Camera"
	camera.position_smoothing_enabled = false
	add_child(camera)
	_load_rooms()
	var player_scene := load(PLAYER_SCENE) as PackedScene
	player = player_scene.instantiate() as Player
	_actors.add_child(player)
	player.died.connect(_on_player_died)
	_build_overlay()
	debug_overlay = DebugOverlay.new()
	debug_overlay.name = "DebugOverlay"
	add_child(debug_overlay)
	if DEV_ARG in OS.get_cmdline_user_args():
		dev_mode = true
		apply_dev_loadout()
	start_at(START_ROOM, START_SPAWN)


func _unhandled_input(event: InputEvent) -> void:
	if not dev_mode or not event is InputEventKey:
		return
	var key := event as InputEventKey
	if key.pressed and not key.echo and key.keycode == KEY_F1:
		set_debug_draw(not debug_overlay.visible)
		get_viewport().set_input_as_handled()


# ---- Public API ------------------------------------------------------------------------------


## Dev loadout: every sub-item, DEV_PITCH_POTS pitch pots, DEV_KEYS keys. Does not set any flags.
func apply_dev_loadout() -> void:
	for id in ItemRegistry.ids():
		GameState.acquire_item(id)
	GameState.add_pitch_pots(DEV_PITCH_POTS)
	GameState.add_key(DEV_KEYS - GameState.keys)


## Shows or hides the hitbox / hurtbox overlay (F1 in dev mode).
func set_debug_draw(on: bool) -> void:
	debug_overlay.visible = on
	debug_overlay.queue_redraw()


func is_transitioning() -> bool:
	return phase != Phase.NONE


func get_current_room_id() -> StringName:
	return current_room.room_id if current_room != null else &""


func get_room(room_id: StringName) -> Room:
	return rooms.get(room_id)


## Puts the player in a room instantly (start of the game, tests). No fade, no slide.
func start_at(room_id: StringName, spawn: StringName = START_SPAWN) -> void:
	phase = Phase.NONE
	_set_paused(false)
	_switch_room(room_id, spawn)
	player.respawn(current_room.get_spawn_position(spawn))
	camera.position = current_room.position + WorldConst.CAMERA_OFFSET


## Fades out, moves the player to a spawn marker in `room_id`, fades in. With `fade = false`
## the switch is instant. Ignored while another transition runs.
func warp_to(room_id: StringName, spawn: StringName = START_SPAWN, fade: bool = true) -> void:
	if is_transitioning() or not rooms.has(room_id):
		return
	if not fade:
		_switch_room(room_id, spawn)
		_place_player_at_spawn(spawn)
		return
	_clear_transients()
	_next_room = rooms[room_id]
	_warp_spawn = spawn
	_warp_switched = false
	_set_paused(true)
	phase = Phase.FADE_OUT
	_t = 0.0


# ---- Frame loop ------------------------------------------------------------------------------


func _physics_process(delta: float) -> void:
	match phase:
		Phase.NONE:
			_check_edge()
		Phase.SLIDE:
			_step_slide(delta)
		Phase.FADE_OUT:
			_step_fade_out(delta)
		Phase.FADE_IN:
			_step_fade_in(delta)
		Phase.DEATH_WAIT:
			_t += delta
			if _t >= DEATH_WAIT:
				_respawn_pending = true
				_next_room = rooms[START_ROOM]
				_warp_spawn = START_SPAWN
				_warp_switched = false
				phase = Phase.FADE_OUT
				_t = 0.0


func _check_edge() -> void:
	if current_room == null or player.is_dead():
		return
	var r := current_room.get_rect()
	var p := player.global_position
	var dir := Vector2i.ZERO
	if p.x > r.end.x:
		dir = Vector2i.RIGHT
	elif p.x < r.position.x:
		dir = Vector2i.LEFT
	elif p.y > r.end.y:
		dir = Vector2i.DOWN
	elif p.y < r.position.y:
		dir = Vector2i.UP
	if dir == Vector2i.ZERO:
		return
	var next: Room = _neighbor(dir)
	if next == null:
		player.global_position = Vector2(
			clampf(p.x, r.position.x, r.end.x), clampf(p.y, r.position.y, r.end.y)
		)
		return
	_begin_slide(next, dir)


func _neighbor(dir: Vector2i) -> Room:
	var side := _side_name(dir)
	var opposite := _side_name(-dir)
	if not current_room.has_exit(side):
		return null
	var next: Room = _by_grid.get(current_room.grid + dir)
	if next == null or not next.has_exit(opposite):
		return null
	return next


func _side_name(dir: Vector2i) -> StringName:
	match dir:
		Vector2i.UP:
			return &"n"
		Vector2i.DOWN:
			return &"s"
		Vector2i.LEFT:
			return &"w"
		_:
			return &"e"


func _begin_slide(next: Room, dir: Vector2i) -> void:
	_clear_transients()
	_next_room = next
	next.enter()
	_set_paused(true)
	next.process_mode = Node.PROCESS_MODE_DISABLED
	phase = Phase.SLIDE
	_t = 0.0
	_cam_from = camera.position
	_cam_to = next.position + WorldConst.CAMERA_OFFSET
	_player_from = player.global_position
	_player_to = _entry_position(next, dir, player.global_position)
	player.reset_actions()
	player.velocity = Vector2.ZERO


## 1 tile inside `next`, keeping the lateral position inside the exit gap.
func _entry_position(next: Room, dir: Vector2i, from: Vector2) -> Vector2:
	var rect := next.get_rect()
	var center := rect.get_center()
	var lateral := WorldConst.EXIT_WIDTH * 0.5 - Player.BODY_RADIUS - 2.0
	match dir:
		Vector2i.RIGHT:
			return Vector2(
				rect.position.x + WorldConst.ENTRY_INSET,
				clampf(from.y, center.y - lateral, center.y + lateral)
			)
		Vector2i.LEFT:
			return Vector2(
				rect.end.x - WorldConst.ENTRY_INSET,
				clampf(from.y, center.y - lateral, center.y + lateral)
			)
		Vector2i.DOWN:
			return Vector2(
				clampf(from.x, center.x - lateral, center.x + lateral),
				rect.position.y + WorldConst.ENTRY_INSET
			)
		_:
			return Vector2(
				clampf(from.x, center.x - lateral, center.x + lateral),
				rect.end.y - WorldConst.ENTRY_INSET
			)


func _step_slide(delta: float) -> void:
	_t += delta
	var k := clampf(_t / WorldConst.SLIDE_TIME, 0.0, 1.0)
	var e := k * k * (3.0 - 2.0 * k)  # smoothstep
	camera.position = _cam_from.lerp(_cam_to, e)
	player.global_position = _player_from.lerp(_player_to, e)
	if k >= 1.0:
		camera.position = _cam_to
		player.global_position = _player_to
		var old := current_room
		current_room = _next_room
		old.leave()
		old.process_mode = Node.PROCESS_MODE_DISABLED
		_finish_room_entry()
		_set_paused(false)
		phase = Phase.NONE
		transition_finished.emit()


func _step_fade_out(delta: float) -> void:
	_t += delta
	fade_rect.color.a = clampf(_t / WorldConst.FADE_TIME, 0.0, 1.0)
	if _t >= WorldConst.FADE_TIME:
		fade_rect.color.a = 1.0
		_switch_room(_next_room.room_id, _warp_spawn)
		_place_player_at_spawn(_warp_spawn)
		if _respawn_pending:
			_respawn_pending = false
			GameState.full_heal()
			player.respawn(player.global_position)
			Events.player_respawned.emit()
			player_respawned.emit()
		_set_paused(true)
		phase = Phase.FADE_IN
		_t = 0.0


func _step_fade_in(delta: float) -> void:
	_t += delta
	fade_rect.color.a = 1.0 - clampf(_t / WorldConst.FADE_TIME, 0.0, 1.0)
	if _t >= WorldConst.FADE_TIME:
		fade_rect.color.a = 0.0
		_set_paused(false)
		phase = Phase.NONE
		transition_finished.emit()


# ---- Room switching --------------------------------------------------------------------------


## Instant switch: leave the old room, enter the new one, jump the camera, apply lighting.
func _switch_room(room_id: StringName, spawn: StringName) -> void:
	var target: Room = rooms[room_id]
	_clear_transients()
	if current_room != null and current_room != target:
		current_room.leave()
		current_room.process_mode = Node.PROCESS_MODE_DISABLED
	elif current_room == target:
		target.leave()
	current_room = target
	current_room.enter()
	current_room.process_mode = Node.PROCESS_MODE_INHERIT
	camera.position = current_room.position + WorldConst.CAMERA_OFFSET
	_finish_room_entry()
	_warp_spawn = spawn


func _place_player_at_spawn(spawn: StringName) -> void:
	player.place_at(current_room.get_spawn_position(spawn))


func _finish_room_entry() -> void:
	current_room.process_mode = Node.PROCESS_MODE_INHERIT
	_modulate.color = DARK_COLOR if current_room.dark else Color.WHITE
	player.set_dark_mode(current_room.dark)
	GameState.mark_visited(current_room.room_id)
	Events.room_entered.emit(current_room.room_id)
	room_changed.emit(current_room.room_id)


func _set_paused(on: bool) -> void:
	player.process_mode = Node.PROCESS_MODE_DISABLED if on else Node.PROCESS_MODE_INHERIT
	if current_room != null:
		current_room.process_mode = Node.PROCESS_MODE_DISABLED if on else Node.PROCESS_MODE_INHERIT


## Frees thrown items and in-flight projectiles (they never survive a room change).
func _clear_transients() -> void:
	for node in get_tree().get_nodes_in_group(&"items"):
		node.queue_free()
	for node in get_tree().get_nodes_in_group(&"projectiles"):
		node.queue_free()


func _on_player_died() -> void:
	if phase != Phase.NONE:
		return
	_set_paused(true)
	phase = Phase.DEATH_WAIT
	_t = 0.0


# ---- Setup -----------------------------------------------------------------------------------


func _load_rooms() -> void:
	for room_id in ROOM_PATHS:
		var scene := load(String(ROOM_PATHS[room_id])) as PackedScene
		if scene == null:
			push_warning("World: room scene missing for %s" % room_id)
			continue
		var room := scene.instantiate() as Room
		if room == null:
			continue
		room.room_id = room_id
		_rooms_node.add_child(room)
		rooms[room_id] = room
		_by_grid[room.grid] = room


func _build_overlay() -> void:
	var hud_scene := load(HUD_SCENE) as PackedScene
	if hud_scene != null:
		hud = hud_scene.instantiate()
		add_child(hud)
	var fade_layer := CanvasLayer.new()
	fade_layer.name = "FadeLayer"
	fade_layer.layer = 20
	add_child(fade_layer)
	fade_rect = ColorRect.new()
	fade_rect.name = "Fade"
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_layer.add_child(fade_rect)
	var pause_scene := load(PAUSE_SCENE) as PackedScene
	if pause_scene != null:
		add_child(pause_scene.instantiate())
