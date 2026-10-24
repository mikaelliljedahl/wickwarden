extends Node
## The save slot (decision 16): one JSON file, `user://save_1.json`, versioned and written atomically
## (temporary file, then rename). It holds the run state of GameState plus the checkpoint and the
## playtime. Autosave runs after each room entry, pickup and persistent flag change, debounced to
## once per second. A corrupt or newer file is ignored with a warning and kept as `save_1.bad`.
##
## Launch modes (set by the title, F13, before it changes to world.tscn): `new` starts a clean run,
## `continue` loads the slot, `dev` (the default; --dev-mode, --start-room, tests) keeps whatever state
## the caller set up and never autosaves. Writes are off while `enabled` is false (tests and --dev-mode).
##
## Checkpoint: the last cave mouth or shop entered. Death respawns there (World). It only counts for
## rooms visited in the current run, so a fresh GameState falls back to the start room.

const FORMAT := 1
const SAVE_PATH := "user://save_1.json"
const TEMP_PATH := "user://save_1.json.tmp"
const BAD_PATH := "user://save_1.bad"
const SAVE_INTERVAL := 1.0
const DEFAULT_CHECKPOINT := &"ow_0_0"
const MODE_NEW := &"new"
const MODE_CONTINUE := &"continue"
const MODE_DEV := &"dev"
const NUMBER_FIELDS: Array[String] = [
	"playtime", "health", "max_health", "wallet", "pitch_pots", "slugs"
]
const STRING_FIELDS: Array[String] = ["checkpoint", "current_room", "active_item"]
const LIST_FIELDS: Array[String] = ["items", "visited_rooms", "flags"]

## False in tests (the runner passes --test=) and in --dev-mode: nothing is written then.
var enabled: bool = _enabled_by_default()
## The mode of the current World launch. See the header.
var launch_mode: StringName = MODE_DEV
## Seconds of game time in the run (counted by World while the game runs, not while paused).
var playtime: float = 0.0
## The last cave mouth or shop entered. Read it with checkpoint_room().
var checkpoint: StringName = DEFAULT_CHECKPOINT

var _save_pending: bool = false
var _since_save: float = SAVE_INTERVAL
var _checkpoint_rooms: Dictionary = {}  # room id -> true: cave mouths and shop pockets


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_checkpoint_rooms = _read_checkpoint_rooms()
	Events.room_entered.connect(_on_room_entered)
	Events.pickup_collected.connect(_on_pickup_collected)
	GameState.flag_changed.connect(_on_flag_changed)


func _physics_process(delta: float) -> void:
	_since_save += delta
	if _save_pending and _since_save >= SAVE_INTERVAL:
		save()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and _save_pending:
		save()


# ---- Public API ------------------------------------------------------------------------------


## True when the slot holds a valid save of this format. A corrupt or newer file is reported as no
## save and, while writes are enabled, kept as save_1.bad.
func has_save() -> bool:
	return not _read_slot().is_empty()


## The checkpoint room. Falls back to the start room when the checkpoint was not visited in this run.
func checkpoint_room() -> StringName:
	if checkpoint != &"" and GameState.visited_rooms.has(checkpoint):
		return checkpoint
	return DEFAULT_CHECKPOINT


## The room a Continue resumes in: the saved current room, else the checkpoint.
func resume_room() -> StringName:
	if GameState.current_room != &"":
		return GameState.current_room
	return checkpoint_room()


## Starts a clean run record: checkpoint at the start room, playtime 0. GameState is reset by World.
func begin_new_game() -> void:
	checkpoint = DEFAULT_CHECKPOINT
	playtime = 0.0
	_save_pending = false


func add_playtime(seconds: float) -> void:
	playtime += seconds


## Writes the slot now (atomic). False, and nothing is written, while `enabled` is false.
func save() -> bool:
	if not enabled:
		return false
	_save_pending = false
	_since_save = 0.0
	var text := JSON.stringify(_snapshot(), "\t")
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("SaveGame: cannot write %s" % TEMP_PATH)
		return false
	file.store_string(text)
	var write_ok := file.get_error() == OK
	file.close()
	if not write_ok:
		_remove(TEMP_PATH)
		push_warning("SaveGame: writing %s failed" % TEMP_PATH)
		return false
	if not _rename(TEMP_PATH, SAVE_PATH):
		_remove(TEMP_PATH)
		push_warning("SaveGame: cannot replace %s" % SAVE_PATH)
		return false
	return true


## Replaces GameState, the checkpoint and the playtime with the slot. False, and no change, when there
## is no valid save. The run state is rebuilt through GameState's own API (items and slugs first, then
## the exact slug count).
func load_into_state() -> bool:
	var data := _read_slot()
	if data.is_empty():
		return false
	GameState.reset()
	_restore(data)
	return true


## Deletes the slot file (the kept save_1.bad stays). False when writes are disabled or there is no slot.
func erase() -> bool:
	if not enabled or not FileAccess.file_exists(SAVE_PATH):
		return false
	_save_pending = false
	return _remove(SAVE_PATH)


## Schedules an autosave. The write happens on a physics frame, at most once per SAVE_INTERVAL. Nothing
## is scheduled when writes are off (disabled, or launch mode dev).
func request_save() -> void:
	if enabled and launch_mode != MODE_DEV:
		_save_pending = true


# ---- Autosave triggers -----------------------------------------------------------------------


func _on_room_entered(room_id: StringName) -> void:
	if _checkpoint_rooms.has(room_id):
		checkpoint = room_id
	request_save()


func _on_pickup_collected(_kind: StringName) -> void:
	request_save()


func _on_flag_changed(_flag: StringName, _value: bool) -> void:
	request_save()


# ---- Slot contents ---------------------------------------------------------------------------


func _snapshot() -> Dictionary:
	var keys := {}
	for scope in GameState.KEY_SCOPES:
		keys[String(scope)] = GameState.keys_in(scope)
	return {
		"format": FORMAT,
		"game_version": str(ProjectSettings.get_setting("application/config/version", "dev")),
		"playtime": playtime,
		"checkpoint": String(checkpoint_room()),
		"health": GameState.health,
		"max_health": GameState.max_health,
		"wallet": GameState.currency,
		"keys": keys,
		"pitch_pots": GameState.pitch_pots,
		"slugs": GameState.slugs,
		"items": _names(GameState.items.keys()),
		"active_item": String(GameState.active_item),
		"visited_rooms": _names(GameState.visited_rooms.keys()),
		"current_room": String(GameState.current_room),
		"flags": _names(GameState.flags.keys()),
	}


func _restore(data: Dictionary) -> void:
	playtime = maxf(0.0, float(data["playtime"]))
	checkpoint = StringName(data["checkpoint"])
	for flag in data["flags"]:
		GameState.set_flag(StringName(flag))
	var max_hp := clampi(int(data["max_health"]), GameState.START_HEALTH, GameState.MAX_HEALTH_CAP)
	max_hp -= max_hp % 2
	GameState.add_max_heart((max_hp - GameState.START_HEALTH) / 2)
	GameState.damage(GameState.health - clampi(int(data["health"]), 1, GameState.max_health))
	GameState.add_currency(clampi(int(data["wallet"]), 0, GameState.WALLET_CAP))
	var keys: Dictionary = data["keys"]
	for scope in GameState.KEY_SCOPES:
		GameState.add_key(maxi(0, int(keys.get(String(scope), 0))), scope)
	for item in data["items"]:
		GameState.acquire_item(StringName(item))
	GameState.add_slugs(int(data["slugs"]) - GameState.slugs)
	GameState.add_pitch_pots(int(data["pitch_pots"]))
	var active := StringName(data["active_item"])
	if GameState.has_item(active):
		GameState.set_active_item(active)
	for room in data["visited_rooms"]:
		GameState.mark_visited(StringName(room))
	var current := StringName(data["current_room"])
	if current != &"":
		GameState.mark_visited(current)


## The slot as a Dictionary, or an empty one when there is no valid save.
func _read_slot() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var json := JSON.new()  # the instance parser does not log a corrupt file as an engine error
	if (
		json.parse(FileAccess.get_file_as_string(SAVE_PATH)) != OK
		or typeof(json.data) != TYPE_DICTIONARY
	):
		return _reject("is not a JSON object")
	var data: Dictionary = json.data
	var problem := _problem(data)
	if problem != "":
		return _reject(problem)
	return data


## Empty when the data is a save of this format, else the reason it is not.
func _problem(data: Dictionary) -> String:
	if not _is_number(data.get("format")):
		return "has no format"
	var format := int(data["format"])
	if format > FORMAT:
		return "is format %d, newer than %d" % [format, FORMAT]
	if format != FORMAT:
		return "is format %d, not %d" % [format, FORMAT]
	for field in NUMBER_FIELDS:
		if not _is_number(data.get(field)):
			return "has no number %s" % field
	for field in STRING_FIELDS:
		if typeof(data.get(field)) != TYPE_STRING:
			return "has no text %s" % field
	if typeof(data.get("keys")) != TYPE_DICTIONARY:
		return "has no keys"
	for field in LIST_FIELDS:
		if typeof(data.get(field)) != TYPE_ARRAY or not _all_strings(data[field]):
			return "has no list %s" % field
	return ""


## Ignores a bad slot. Moves it to save_1.bad when writes are enabled, so Continue no longer offers it.
func _reject(reason: String) -> Dictionary:
	push_warning("SaveGame: %s %s; it is ignored" % [SAVE_PATH, reason])
	if enabled:
		_remove(BAD_PATH)
		_rename(SAVE_PATH, BAD_PATH)
	return {}


func _read_checkpoint_rooms() -> Dictionary:
	var rooms := {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(WorldData.PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("SaveGame: %s is missing; checkpoints cannot be placed" % WorldData.PATH)
		return rooms
	for cave: Dictionary in parsed.get("caves", []):
		rooms[StringName(str(cave.get("mouth", "")))] = true
	for shop: Dictionary in parsed.get("shops", []):
		rooms[StringName(str(shop.get("node", "")))] = true
	return rooms


# ---- Files -----------------------------------------------------------------------------------


## Renames inside user://, replacing the target (Windows does not replace on rename, so remove first).
func _rename(from: String, to: String) -> bool:
	var from_path := ProjectSettings.globalize_path(from)
	var to_path := ProjectSettings.globalize_path(to)
	if DirAccess.rename_absolute(from_path, to_path) == OK:
		return true
	if FileAccess.file_exists(to):
		DirAccess.remove_absolute(to_path)
		return DirAccess.rename_absolute(from_path, to_path) == OK
	return false


func _remove(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK


static func _enabled_by_default() -> bool:
	for arg in OS.get_cmdline_user_args():
		if arg == "--dev-mode" or arg.begins_with("--test="):
			return false
	return true


static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT


static func _all_strings(list: Array) -> bool:
	for item in list:
		if typeof(item) != TYPE_STRING:
			return false
	return true


static func _names(list: Array) -> Array:
	var names: Array = []
	for item in list:
		names.append(String(item))
	return names
