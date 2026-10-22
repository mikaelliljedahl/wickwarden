extends Node
## Audio autoload: pooled sound effects and crossfading music. Presentation only.
## Sounds are synthesised by tools/make_audio.py (docs/audio-provenance.md). A missing file is a
## warning, never a crash. Gameplay scripts call `Audio.play_sfx(&"name", position)`; the rest is
## driven by the Events bus (room music, deaths, pickups, explosions) and the tree's pause flag.

const SFX_DIR := "res://assets/audio/sfx/"
const MUSIC_DIR := "res://assets/audio/music/"
const SFX_NAMES: Array[StringName] = [
	&"swing",
	&"charge_start",
	&"charge_ready",
	&"flare",
	&"hook_hit",
	&"hook_clank",
	&"bush_cut",
	&"ward_block",
	&"moth_launch",
	&"pot_place",
	&"pot_explode",
	&"stun",
	&"player_hurt",
	&"player_death",
	&"enemy_hurt",
	&"enemy_death",
	&"spit",
	&"hollow_dash",
	&"pickup_heart",
	&"pickup_coin",
	&"pickup_key",
	&"pickup_pots",
	&"pickup_core",
	&"pickup_item",
	&"gate_open",
	&"door_unlock",
	&"wall_break",
	&"brazier_lit",
	&"room_transition",
	&"pause_open",
	&"pause_close",
	&"menu_move",
	&"menu_select",
]
const MUSIC_NAMES: Array[StringName] = [&"overworld", &"cave"]
## Pickup kind -> sound.
const PICKUP_SFX := {
	&"ember": &"pickup_heart",
	&"brass_bit": &"pickup_coin",
	&"brass_coin": &"pickup_coin",
	&"key": &"pickup_key",
	&"pitch_pot_bundle": &"pickup_pots",
	&"wick_core": &"pickup_core",
	&"item": &"pickup_item",
}
## Per-sound level trim in dB (files are all normalised to -3 dBFS).
const TRIM_DB := {
	&"swing": -4.0,
	&"menu_move": -8.0,
	&"room_transition": -6.0,
	&"enemy_hurt": -3.0,
	&"hook_hit": -2.0,
	&"pickup_coin": -4.0,
	&"pot_explode": -2.0,
	&"gate_open": -4.0,
	&"charge_start": -6.0,
	&"hollow_dash": -4.0,
}
const POOL_SIZE := 16
const MIN_REPEAT := 0.03
const CROSSFADE := 1.0
const SILENT_DB := -60.0
const PAUSED_MUSIC_DB := -8.0

var current_music: StringName = &""

var _streams: Dictionary = {}
var _music_streams: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _pool_2d: Array[AudioStreamPlayer2D] = []
var _next: int = 0
var _next_2d: int = 0
var _last_played: Dictionary = {}
var _music: Array[AudioStreamPlayer] = []
var _active: int = 0
var _tween: Tween
var _was_paused: bool = false
var _room_seen: bool = false
## Headless runs (tests) use the Dummy audio driver: nothing is played, so no playback objects
## are left alive at exit. Names, music state and the API behave the same.
var _silent: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_silent = AudioServer.get_driver_name() == "Dummy"
	_ensure_buses()
	for sfx_name in SFX_NAMES:
		var path := SFX_DIR + String(sfx_name) + ".wav"
		var stream := load(path) as AudioStream if ResourceLoader.exists(path) else null
		if stream == null:
			push_warning("Audio: missing sfx %s" % sfx_name)
		else:
			_streams[sfx_name] = stream
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = &"SFX"
		add_child(p)
		_pool.append(p)
		var p2 := AudioStreamPlayer2D.new()
		p2.bus = &"SFX"
		p2.max_distance = 1800.0
		p2.attenuation = 0.6
		add_child(p2)
		_pool_2d.append(p2)
	for i in range(2):
		var m := AudioStreamPlayer.new()
		m.bus = &"Music"
		m.volume_db = SILENT_DB
		add_child(m)
		_music.append(m)
	Events.room_entered.connect(_on_room_entered)
	Events.enemy_died.connect(_on_enemy_died)
	Events.player_hurt.connect(_on_player_hurt)
	Events.player_died.connect(_on_player_died)
	Events.pickup_collected.connect(_on_pickup_collected)
	Events.explosion.connect(_on_explosion)


func _exit_tree() -> void:
	# Release every stream so the engine reports no resources still in use at exit.
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_streams.clear()
	_music_streams.clear()
	for p in _pool:
		p.stop()
		p.stream = null
	for p2 in _pool_2d:
		p2.stop()
		p2.stream = null
	for m in _music:
		m.stop()
		m.stream = null


func _process(_delta: float) -> void:
	var paused := get_tree().paused
	if paused == _was_paused:
		return
	_was_paused = paused
	play_sfx(&"pause_open" if paused else &"pause_close", Vector2.INF, 0.0, 0.0)
	_duck_music()


## True if the named effect loaded.
func has_sfx(sfx_name: StringName) -> bool:
	return _streams.has(sfx_name)


## Plays an effect. `at` = Vector2.INF plays it flat (UI, the player); a position plays it in 2D.
## Unknown or unloaded names are ignored.
func play_sfx(
	sfx_name: StringName, at := Vector2.INF, volume_db := 0.0, pitch_jitter := 0.05
) -> void:
	var stream := _streams.get(sfx_name) as AudioStream
	if stream == null or _silent:
		return
	var now := Time.get_ticks_msec() / 1000.0
	if now - float(_last_played.get(sfx_name, -1.0)) < MIN_REPEAT:
		return
	_last_played[sfx_name] = now
	var db := volume_db + float(TRIM_DB.get(sfx_name, 0.0))
	var pitch := 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	if at == Vector2.INF:
		var p := _pool[_next]
		_next = (_next + 1) % POOL_SIZE
		p.stream = stream
		p.volume_db = db
		p.pitch_scale = pitch
		p.play()
	else:
		var p2 := _pool_2d[_next_2d]
		_next_2d = (_next_2d + 1) % POOL_SIZE
		p2.stream = stream
		p2.volume_db = db
		p2.pitch_scale = pitch
		p2.global_position = at
		p2.play()


## Starts a music loop, crossfading (1 s) from the current one. Same name = no-op.
func play_music(music_name: StringName) -> void:
	if music_name == current_music:
		return
	var stream := _get_music(music_name)
	if stream == null:
		return
	current_music = music_name
	if _silent:
		return
	var old := _music[_active]
	_active = 1 - _active
	var fresh := _music[_active]
	fresh.stream = stream
	fresh.volume_db = SILENT_DB
	fresh.play()
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(fresh, "volume_db", _target_db(), CROSSFADE)
	_tween.tween_property(old, "volume_db", SILENT_DB, CROSSFADE)
	_tween.chain().tween_callback(old.stop)


func stop_music() -> void:
	current_music = &""
	for m in _music:
		m.stop()


## Music name for a room id: cave rooms use the cave loop.
static func music_for_room(room_id: StringName) -> StringName:
	return &"cave" if String(room_id).begins_with("cave") else &"overworld"


func _get_music(music_name: StringName) -> AudioStream:
	if _music_streams.has(music_name):
		return _music_streams[music_name] as AudioStream
	var path := MUSIC_DIR + String(music_name) + ".ogg"
	var stream := load(path) as AudioStream if ResourceLoader.exists(path) else null
	if stream == null:
		push_warning("Audio: missing music %s" % music_name)
		return null
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	_music_streams[music_name] = stream
	return stream


func _target_db() -> float:
	return PAUSED_MUSIC_DB if _was_paused else 0.0


func _duck_music() -> void:
	var playing := _music[_active]
	if playing.playing:
		create_tween().tween_property(playing, "volume_db", _target_db(), 0.3)


func _ensure_buses() -> void:
	for bus_name in [&"Music", &"SFX"]:
		if AudioServer.get_bus_index(bus_name) >= 0:
			continue
		AudioServer.add_bus()
		var idx := AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, bus_name)
		AudioServer.set_bus_send(idx, &"Master")
		AudioServer.set_bus_volume_db(idx, -10.0 if bus_name == &"Music" else 0.0)


func _on_room_entered(room_id: StringName) -> void:
	if _room_seen:
		play_sfx(&"room_transition", Vector2.INF, 0.0, 0.0)
	_room_seen = true
	play_music(music_for_room(room_id))


func _on_enemy_died(_enemy: Node, at: Vector2) -> void:
	play_sfx(&"enemy_death", at)


func _on_player_hurt(_amount: int) -> void:
	play_sfx(&"player_hurt")


func _on_player_died() -> void:
	play_sfx(&"player_death", Vector2.INF, 0.0, 0.0)


func _on_pickup_collected(kind: StringName) -> void:
	play_sfx(PICKUP_SFX.get(kind, &"pickup_item"), Vector2.INF, 0.0, 0.02)


func _on_explosion(at: Vector2, _radius: float) -> void:
	play_sfx(&"pot_explode", at)
