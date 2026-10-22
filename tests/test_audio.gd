extends TestCase
## Audio autoload: every declared effect loads, unknown names and missing music are harmless,
## music changes (crossfade) and the pause flag work.


func run() -> void:
	await frames(2)
	for sfx_name in Audio.SFX_NAMES:
		check(Audio.has_sfx(sfx_name), "sfx %s loads" % sfx_name)
	for music_name in Audio.MUSIC_NAMES:
		var path: String = Audio.MUSIC_DIR + String(music_name) + ".ogg"
		check(load(path) is AudioStream, "music %s loads" % music_name)
	check_eq(Audio.music_for_room(&"cave_1"), &"cave", "cave rooms use the cave loop")
	check_eq(Audio.music_for_room(&"ow_1_1"), &"overworld", "overworld rooms use the overworld loop")
	check(AudioServer.get_bus_index(&"Music") >= 0, "Music bus exists")
	check(AudioServer.get_bus_index(&"SFX") >= 0, "SFX bus exists")
	check(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music")) < 0.0, "music is quieter than sfx")

	Audio.play_sfx(&"no_such_sound")
	Audio.play_sfx(&"swing", Vector2(100, 100), -3.0, 0.1)
	for i in range(40):  # more than the pool: voices are recycled
		Audio.play_sfx(&"enemy_hurt")
		await frames(1)
	Audio.play_music(&"no_such_music")
	check_eq(Audio.current_music, &"", "a missing music name changes nothing")
	Audio.play_music(&"overworld")
	check_eq(Audio.current_music, &"overworld", "overworld music starts")
	await frames(10)
	Audio.play_music(&"cave")
	check_eq(Audio.current_music, &"cave", "music switches to the cave")
	await frames(70)
	Audio.play_music(&"cave")
	get_tree().paused = true
	await frames(3)
	get_tree().paused = false
	await frames(3)
	Events.room_entered.emit(&"ow_0_0")
	check_eq(Audio.current_music, &"overworld", "entering an overworld room switches the music")
	Audio.stop_music()
