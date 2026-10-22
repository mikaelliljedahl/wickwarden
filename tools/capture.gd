extends Node
## Screenshot helper (not a test): godot --path . res://tools/capture.tscn -- --out=/tmp/shot.png --room=ow_1_1
## Needs a display (not --headless). Optional: --spawn=Default --dark --frames=30


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var out := "/tmp/wickwarden_capture.png"
	var room := &"ow_0_0"
	var spawn := &"Default"
	var wait_frames := 20
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.trim_prefix("--out=")
		elif arg.begins_with("--room="):
			room = StringName(arg.trim_prefix("--room="))
		elif arg.begins_with("--spawn="):
			spawn = StringName(arg.trim_prefix("--spawn="))
		elif arg.begins_with("--frames="):
			wait_frames = int(arg.trim_prefix("--frames="))
	var world := (load("res://scenes/world/world.tscn") as PackedScene).instantiate() as World
	add_child(world)
	await get_tree().physics_frame
	GameState.acquire_item(&"pitch_pot")
	GameState.add_pitch_pots(3)
	GameState.damage(3)
	world.start_at(room, spawn)
	for i in range(wait_frames):
		await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	image.save_png(out)
	print("saved ", out, " ", image.get_size())
	get_tree().quit()
