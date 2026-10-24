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
## Rooms come from data/world_data.json (WorldData): the grid index is built from it, and a room
## is instantiated when it is first needed. The current room and the rooms its exits lead to stay
## loaded; every other room is freed when the player changes room, so no state lives in a room node
## (flags do). A room whose scene does not exist yet is a warning and a closed edge.
##
## The screen shows the room at y 120..1080 under the 120 px HUD band: the camera centre is the
## room origin + WorldConst.CAMERA_OFFSET. Timing is driven from _physics_process so tests are
## deterministic.

signal room_changed(room_id: StringName)
signal transition_finished
signal player_respawned

enum Phase { NONE, SLIDE, FADE_OUT, FADE_IN, DEATH_WAIT }

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
## Launch argument (`godot --path . -- --start-room=<id>[:spawn]`, also used by the capture tool):
## start play in that room at that entry marker. An unknown room falls back to START_ROOM.
const START_ROOM_ARG := "--start-room="

var player: Player
var camera: Camera2D
var current_room: Room
var rooms: Dictionary = {}  # room id -> Room, only the rooms that are loaded now
var phase: Phase = Phase.NONE
var hud: Node
var fade_rect: ColorRect
var dev_mode: bool = false
var debug_overlay: DebugOverlay

var _rooms_node: Node2D
var _actors: Node2D
var _modulate: CanvasModulate
var _by_grid: Dictionary = {}  # Vector2i -> StringName (room id), from WorldData
var _scene_overrides: Dictionary = {}  # room id -> PackedScene, from add_room_scene
var _warned: Dictionary = {}  # room id -> true, for warn-once messages
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
	_build_grid_index()
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
	var start := _start_position()
	start_at(start[0], start[1])


func _unhandled_input(event: InputEvent) -> void:
	if not dev_mode or not event is InputEventKey:
		return
	var key := event as InputEventKey
	if key.pressed and not key.echo and key.keycode == KEY_F1:
		set_debug_draw(not debug_overlay.visible)
		get_viewport().set_input_as_handled()


# ---- Public API ------------------------------------------------------------------------------


## `--start-room=<id>[:spawn]` in `args` as [room id, spawn marker]. The id is &"" when the argument
## is absent. A missing spawn part means START_SPAWN.
static func parse_start_room(args: PackedStringArray) -> Array[StringName]:
	for arg in args:
		if arg.begins_with(START_ROOM_ARG):
			var parts := arg.trim_prefix(START_ROOM_ARG).split(":")
			var spawn := START_SPAWN
			if parts.size() > 1 and not parts[1].is_empty():
				spawn = StringName(parts[1])
			return [StringName(parts[0]), spawn]
	return [&"", START_SPAWN]


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


## The room `room_id`, instantiated from its scene on first use. Null when the room has no scene
## yet (a warning, once per room).
func get_room(room_id: StringName) -> Room:
	if rooms.has(room_id):
		return rooms[room_id]
	return _load_room(room_id)


## Makes `packed_scene` the scene of `room_id` from now on (a test and capture hook; also for an
## id the graph lacks). A loaded copy is dropped unless it is the current room.
func add_room_scene(room_id: StringName, packed_scene: PackedScene) -> Room:
	_scene_overrides[room_id] = packed_scene
	if rooms.has(room_id) and rooms[room_id] != current_room:
		_unload(room_id)
	return get_room(room_id)


## Puts the player in a room instantly (start of the game, tests). No fade, no slide.
func start_at(room_id: StringName, spawn: StringName = START_SPAWN) -> void:
	var target := get_room(room_id)
	if target == null:
		return
	phase = Phase.NONE
	_set_paused(false)
	_switch_room(room_id, spawn)
	player.respawn(current_room.get_spawn_position(spawn))
	camera.position = current_room.position + WorldConst.CAMERA_OFFSET


## Fades out, moves the player to a spawn marker in `room_id`, fades in. With `fade = false`
## the switch is instant. Ignored while another transition runs.
func warp_to(room_id: StringName, spawn: StringName = START_SPAWN, fade: bool = true) -> void:
	if is_transitioning():
		return
	var target := get_room(room_id)
	if target == null:
		return
	if not fade:
		_switch_room(room_id, spawn)
		_place_player_at_spawn(spawn)
		return
	_clear_transients()
	_next_room = target
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
				_next_room = get_room(START_ROOM)
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
	var id: StringName = _by_grid.get(current_room.grid + dir, &"")
	var next: Room = null
	if id != &"":
		next = get_room(id)
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
	var target := get_room(room_id)
	if target == null:
		return
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
	_refresh_loaded()
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


## Grid index of every overworld and cave room in the graph. Pockets are not on the grid.
func _build_grid_index() -> void:
	for id in WorldData.room_ids():
		var cell := WorldData.grid(id)
		if _by_grid.has(cell):
			push_error("World: grid %s holds both %s and %s" % [cell, _by_grid[cell], id])
			continue
		_by_grid[cell] = StringName(id)


## Instantiates a room from its scene (or its add_room_scene override). The grid comes from the
## graph; the scene must agree with it. The room starts disabled and hidden until it is entered.
func _load_room(room_id: StringName) -> Room:
	var scene := _scene_for(room_id)
	if scene == null:
		return null
	var node := scene.instantiate()
	var room := node as Room
	if room == null:
		node.free()
		_warn_once(room_id, "World: the scene of %s is not a Room" % room_id)
		return null
	room.room_id = room_id
	var id := String(room_id)
	if WorldData.has(id):
		var cell := WorldData.grid(id)
		if room.grid != cell:
			push_warning("World: %s is at grid %s in its scene, %s in the graph" % [room_id, room.grid, cell])
		room.grid = cell
	room.process_mode = Node.PROCESS_MODE_DISABLED
	_rooms_node.add_child(room)
	rooms[room_id] = room
	return room


func _scene_for(room_id: StringName) -> PackedScene:
	if _scene_overrides.has(room_id):
		return _scene_overrides[room_id]
	var id := String(room_id)
	if not WorldData.has(id):
		_warn_once(room_id, "World: %s is not a room of the graph" % room_id)
		return null
	var path := WorldData.scene_path(id)
	if path.is_empty() or not ResourceLoader.exists(path):
		_warn_once(room_id, "World: %s has no room scene yet; its edges are closed" % room_id)
		return null
	return load(path) as PackedScene


## Keeps the current room and the rooms its exits lead to loaded (so a slide finds them at once);
## frees every other room. Called whenever a room becomes the current one.
func _refresh_loaded() -> void:
	var keep: Array[StringName] = [current_room.room_id]
	for side in current_room.exits:
		var id: StringName = _by_grid.get(current_room.grid + _side_vector(side), &"")
		if id != &"":
			keep.append(id)
			get_room(id)
	for id in rooms.keys():
		if not keep.has(id):
			_unload(id)


## Room and spawn the game starts in: the `--start-room` argument when that room exists.
func _start_position() -> Array[StringName]:
	var requested := parse_start_room(OS.get_cmdline_user_args())
	if requested[0] != &"":
		if get_room(requested[0]) != null:
			return requested
		push_warning("World: --start-room=%s is not a room; starting in %s" % [requested[0], START_ROOM])
	return [START_ROOM, START_SPAWN]


func _unload(room_id: StringName) -> void:
	var room: Room = rooms[room_id]
	rooms.erase(room_id)
	_rooms_node.remove_child(room)
	room.queue_free()


func _side_vector(side: StringName) -> Vector2i:
	match side:
		&"n":
			return Vector2i.UP
		&"s":
			return Vector2i.DOWN
		&"w":
			return Vector2i.LEFT
		_:
			return Vector2i.RIGHT


func _warn_once(room_id: StringName, message: String) -> void:
	if _warned.has(room_id):
		return
	_warned[room_id] = true
	push_warning(message)


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
