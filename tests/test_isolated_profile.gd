extends TestCase
## Verify the runner contract, including rejection before writing into an unexpected profile.


func run() -> void:
	check(isolated_test_profile(), "runner supplies the matching private profile")
	var original_root := OS.get_environment("WICK_TEST_ROOT")
	var original_profile := OS.get_environment("WICK_TEST_PROFILE")
	var original_token := OS.get_environment("WICK_TEST_TOKEN")
	var original_data := OS.get_environment("XDG_DATA_HOME")
	OS.set_environment("WICK_TEST_TOKEN", "")
	check(not isolated_test_profile(), "missing runner token rejected")
	OS.set_environment("WICK_TEST_TOKEN", original_token)
	OS.set_environment("WICK_TEST_ROOT", original_root + "/../wrong")
	check(not isolated_test_profile(), "noncanonical root rejected")
	OS.set_environment("WICK_TEST_ROOT", original_root)
	OS.set_environment("XDG_DATA_HOME", "/var/tmp")
	check(not isolated_test_profile(), "incorrect XDG data root rejected")
	OS.set_environment("XDG_DATA_HOME", original_data)
	OS.set_environment("WICK_TEST_PROFILE", original_root.path_join("other"))
	check(not isolated_test_profile(), "different suite profile rejected")
	OS.set_environment("WICK_TEST_PROFILE", original_profile)
	var link := OS.get_user_data_dir().path_join("save_1.bad")
	var dir := DirAccess.open("/")
	check(dir != null and not FileAccess.file_exists(link), "bad-slot link fixture is absent")
	if dir != null and not FileAccess.file_exists(link):
		var made := dir.create_link(OS.get_user_data_dir(), link) == OK
		check(made, "create isolated symlink fixture")
		if made:
			check(not isolated_test_profile(), "symlinked bad slot rejected")
			check_eq(DirAccess.remove_absolute(link), OK, "remove own symlink fixture")
	check(isolated_test_profile(), "profile valid again after negative fixtures")
	reset_state()
	GameState.add_currency(17)
	SaveGame.enabled = true
	check(SaveGame.save(), "real save in isolated profile")
	reset_state()
	check(SaveGame.load_into_state(), "real save reloads")
	check_eq(GameState.currency, 17, "saved value survives reload")
	check(SaveGame.erase(), "isolated test slot erased")
	SaveGame.enabled = false
