extends TestCase
## SaveGame: a rich run round-trips through the slot, a newer or corrupt slot is ignored and kept as
## save_1.bad, the checkpoint (cave mouth or shop) is where a death respawns, autosave writes on room
## entry with a one-second debounce, and nothing is written while saves are disabled.

const SLOT := "user://save_1.json"
const BAD := "user://save_1.bad"
const TEMP := "user://save_1.json.tmp"


func run() -> void:
	check(not SaveGame.enabled, "tests start with saves disabled")
	_clean()
	reset_state()
	await _nothing_is_written_while_disabled()
	SaveGame.enabled = true
	_round_trip()
	_erase_keeps_bad_slot()
	_newer_and_corrupt_slots()
	await _checkpoint_respawn()
	await _autosave_and_continue()
	_clean()
	SaveGame.enabled = false
	SaveGame.launch_mode = SaveGame.MODE_DEV


func _nothing_is_written_while_disabled() -> void:
	SaveGame.enabled = false
	SaveGame.launch_mode = SaveGame.MODE_NEW
	check(not SaveGame.save(), "save() is refused while disabled")
	check(not SaveGame.erase(), "erase() is refused while disabled")
	check(not FileAccess.file_exists(SLOT), "no slot file while disabled")
	SaveGame.request_save()
	await seconds(1.2)
	check(not FileAccess.file_exists(SLOT), "no autosave is written while disabled")
	SaveGame.launch_mode = SaveGame.MODE_DEV


func _round_trip() -> void:
	reset_state()
	SaveGame.begin_new_game()
	GameState.add_max_heart(2)  # max 10
	GameState.damage(3)  # health 7
	GameState.add_currency(250)
	GameState.add_key(2, &"ow")
	GameState.add_key(1, &"c3")
	GameState.add_pot_bag()  # pot max 14
	GameState.add_pitch_pots(12)
	GameState.acquire_item(&"tether_moth")
	GameState.acquire_item(&"tallow_sling")  # gives 12 slugs
	GameState.add_slugs(8)  # 20
	GameState.acquire_item(&"reed_raft")
	GameState.set_active_item(&"tallow_sling")
	GameState.add_big_key(&"c2")
	GameState.add_fragment(&"c1")
	GameState.set_flag(&"picked_ow_1_0_coin")
	GameState.set_flag(&"door_ow_2_0_gate")
	GameState.mark_visited(&"ow_0_0")
	GameState.mark_visited(&"ow_1_1")
	GameState.mark_visited(&"ow_0_1")
	SaveGame.checkpoint = &"ow_1_1"
	SaveGame.add_playtime(123.5)
	check(SaveGame.save(), "save() writes the slot")
	check(FileAccess.file_exists(SLOT), "the slot file exists")
	check(not FileAccess.file_exists(TEMP), "the temporary file is renamed away")
	var before := _state_summary()
	reset_state()
	SaveGame.begin_new_game()
	check(SaveGame.has_save(), "has_save() sees the slot")
	check(SaveGame.load_into_state(), "load_into_state() loads the slot")
	check_eq(_state_summary(), before, "a rich run round-trips")
	check_eq(GameState.pot_max(), 14, "the pot bag flag comes back with the pot limit")
	check_eq(GameState.pitch_pots, 12, "pitch pots are not clamped by the limit")
	check_eq(SaveGame.resume_room(), &"ow_0_1", "resume starts in the saved current room")


## Erase removes the slot only; a kept bad slot stays for inspection.
func _erase_keeps_bad_slot() -> void:
	_write_text(BAD, "old")
	check(SaveGame.erase(), "erase() removes the slot")
	check(not FileAccess.file_exists(SLOT), "the slot is gone")
	check(FileAccess.file_exists(BAD), "erase() keeps save_1.bad")
	check(not SaveGame.has_save(), "no slot, no save")
	_remove(BAD)


func _newer_and_corrupt_slots() -> void:
	reset_state()
	SaveGame.begin_new_game()
	GameState.add_currency(9)
	check(SaveGame.save(), "a valid slot to edit")

	var data := _slot_dict()
	data["format"] = SaveGame.FORMAT + 1
	_write_text(SLOT, JSON.stringify(data))
	reset_state()
	GameState.add_currency(5)
	check(not SaveGame.has_save(), "a newer format is no save")
	check(not FileAccess.file_exists(SLOT), "a newer slot leaves the slot name")
	check(FileAccess.file_exists(BAD), "a newer slot is kept as save_1.bad")
	check(not SaveGame.load_into_state(), "a newer slot does not load")
	check_eq(GameState.currency, 5, "a rejected load changes nothing")

	_write_text(SLOT, "{ this is not json")
	check(not SaveGame.has_save(), "a corrupt slot is no save")
	check(FileAccess.file_exists(BAD), "a corrupt slot is kept as save_1.bad")

	SaveGame.save()
	data = _slot_dict()
	data.erase("wallet")
	_write_text(SLOT, JSON.stringify(data))
	check(not SaveGame.has_save(), "a slot with a field missing is no save")
	check(not FileAccess.file_exists(SLOT), "a field-less slot is moved aside")
	_remove(BAD)
	reset_state()


## A death returns to the checkpoint: the last cave mouth or shop entered. Flags stay.
func _checkpoint_respawn() -> void:
	reset_state()
	SaveGame.begin_new_game()
	check_eq(SaveGame.checkpoint_room(), &"ow_0_0", "the checkpoint defaults to the start room")
	var world := await make_world()
	await frames(2)
	world.warp_to(&"ow_0_1", &"Default", false)
	check_eq(SaveGame.checkpoint_room(), &"ow_0_0", "an ordinary room is no checkpoint")
	world.warp_to(&"ow_1_1", &"Default", false)
	check_eq(SaveGame.checkpoint_room(), &"ow_1_1", "the cave mouth ow_1_1 is the checkpoint")
	world.warp_to(&"ow_0_1", &"Default", false)
	check_eq(SaveGame.checkpoint_room(), &"ow_1_1", "the checkpoint stays until the next one")
	await _die_and_wait(world, &"ow_1_1", "a death returns to the cave mouth")

	world.add_room_scene(
		&"ow_1_2#shop", load("res://scenes/world/rooms/ow_0_0.tscn") as PackedScene
	)
	world.warp_to(&"ow_1_2#shop", &"Default", false)
	check_eq(SaveGame.checkpoint_room(), &"ow_1_2#shop", "a shop pocket is the checkpoint")
	GameState.set_flag(&"door_test_respawn")
	await _die_and_wait(world, &"ow_1_2#shop", "a death in a shop returns to the shop")
	check(GameState.has_flag(&"door_test_respawn"), "flags are kept after a death")
	check_eq(GameState.health, GameState.max_health, "respawn with full health")

	var seconds_before := SaveGame.playtime
	await seconds(1.0)
	check_near(SaveGame.playtime - seconds_before, 1.0, 0.05, "playtime counts game seconds")
	await dispose(world)

	reset_state()
	check_eq(SaveGame.checkpoint_room(), &"ow_0_0", "a new run has no visited checkpoint")


## Autosave runs on room entry, debounced to once per second; a new game writes its first room and
## Continue resumes there with the saved wallet.
func _autosave_and_continue() -> void:
	_clean()
	SaveGame.enabled = true
	SaveGame.launch_mode = SaveGame.MODE_NEW
	var world := await make_world()
	await seconds(1.1)
	check(SaveGame.has_save(), "a new game writes its slot on the first room")
	check_eq(_slot_dict().get("current_room"), "ow_0_0", "the first save holds the start room")

	SaveGame.save()  # starts the one-second window
	GameState.add_currency(42)
	world.warp_to(&"ow_0_1", &"Default", false)
	await frames(2)
	check_eq(_slot_dict().get("current_room"), "ow_0_0", "a save within one second is debounced")
	await seconds(1.1)
	check_eq(_slot_dict().get("current_room"), "ow_0_1", "the debounced save follows the room")
	check_eq(_slot_dict().get("wallet"), 42, "the wallet is saved")

	GameState.set_flag(&"door_autosave_test")
	await seconds(1.1)
	check(_slot_dict().get("flags", []).has("door_autosave_test"), "a flag change is saved")
	await dispose(world)

	SaveGame.launch_mode = SaveGame.MODE_CONTINUE
	reset_state()
	world = await make_world()
	await frames(2)
	check_eq(world.get_current_room_id(), &"ow_0_1", "Continue resumes in the saved room")
	check_eq(GameState.currency, 42, "Continue restores the wallet")
	check(GameState.has_flag(&"door_autosave_test"), "Continue restores the flags")
	await dispose(world)

	SaveGame.launch_mode = SaveGame.MODE_NEW
	SaveGame.enabled = false
	_clean()
	world = await make_world()
	await seconds(1.2)
	check(not FileAccess.file_exists(SLOT), "a disabled run writes nothing")
	await dispose(world)
	SaveGame.launch_mode = SaveGame.MODE_DEV
	SaveGame.enabled = true
	reset_state()


func _die_and_wait(world: World, expected: StringName, message: String) -> void:
	world.player.take_damage(99, world.player.global_position + Vector2(10, 0))
	check(world.player.is_dead(), "the player dies")
	await frames(2)
	var waited := 0
	while (world.is_transitioning() or world.get_current_room_id() != expected) and waited < 400:
		await frames(1)
		waited += 1
	check_eq(world.get_current_room_id(), expected, message)
	check(not world.player.is_dead(), "the player is alive after the respawn")


## The run values the round trip must keep, in one comparable Dictionary.
func _state_summary() -> Dictionary:
	var keys := {}
	for scope in GameState.KEY_SCOPES:
		keys[scope] = GameState.keys_in(scope)
	var visited: Array = GameState.visited_rooms.keys()
	visited.sort()
	var flags: Array = GameState.flags.keys()
	flags.sort()
	return {
		"health": GameState.health,
		"max_health": GameState.max_health,
		"wallet": GameState.currency,
		"keys": keys,
		"pitch_pots": GameState.pitch_pots,
		"slugs": GameState.slugs,
		"items": GameState.acquired_item_ids(),
		"active_item": GameState.active_item,
		"visited": visited,
		"flags": flags,
		"current_room": GameState.current_room,
		"checkpoint": SaveGame.checkpoint_room(),
		"playtime": SaveGame.playtime,
	}


func _slot_dict() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SLOT))
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func _write_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _clean() -> void:
	for path in [SLOT, BAD, TEMP]:
		_remove(path)
