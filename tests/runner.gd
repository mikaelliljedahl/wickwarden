extends Node
## Runs ONE test file: godot --headless --path . res://tests/runner.tscn -- --test=res://tests/test_x.gd
## Exit code 0 = all checks passed. Normally started by tools/run_godot_check.py.


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var path := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--test="):
			path = arg.trim_prefix("--test=")
	if path == "":
		printerr("runner: missing --test=res://tests/test_x.gd")
		get_tree().quit(2)
		return
	var script := load(path) as GDScript
	if script == null:
		printerr("runner: cannot load %s" % path)
		get_tree().quit(2)
		return
	var test := script.new() as TestCase
	if test == null:
		printerr("runner: %s does not extend TestCase" % path)
		get_tree().quit(2)
		return
	add_child(test)
	await test.run()
	for action in TestCase.ACTIONS:
		Input.action_release(action)
	var failed := test.failures.size()
	var checks := test.checks
	var messages := test.failures.duplicate()
	test.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	if failed == 0 and checks > 0:
		print("OK %s: %d checks" % [path.get_file(), checks])
		get_tree().quit(0)
	else:
		print("FAIL %s: %d of %d checks failed" % [path.get_file(), failed, checks])
		for message in messages:
			print("  - ", message)
		get_tree().quit(1)
