extends Node
## Screenshot helper (not a test). Needs a display (not --headless). Renders the game into a
## 1920x1080 SubViewport, so the image size does not depend on the window (tiling window managers).
##
##   godot --path . res://tools/capture.tscn -- --room=ow_1_1 --out=/tmp/shot.png
##
## Options:
##   --room=<id> --spawn=<marker>   room and entry marker (default ow_0_0 / Default)
##   --frames=N                     physics frames to simulate before the shot (default 30)
##   --place=x,y                    put the player at this ROOM-LOCAL position first
##   --facing=up|down|left|right    turn the player before the shot
##   --dev                          dev-mode loadout (all items, 10 pots, 5 keys)
##   --action=flare                 hold attack 0.9 s, release, shoot during the sweep
##   --action=charge                hold attack 0.9 s and shoot while the lamp glows
##   --action=pot                   place a pitch pot and shoot at the explosion
##   --hitboxes                     draw hitboxes and hurtboxes (same as F1 in the game)

var _viewport: SubViewport


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var out := "/tmp/wickwarden_capture.png"
	var room := &"ow_0_0"
	var spawn := &"Default"
	var wait_frames := 30
	var place := Vector2.INF
	var facing := Vector2.ZERO
	var action := ""
	var dev := false
	var hitboxes := false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.trim_prefix("--out=")
		elif arg.begins_with("--room="):
			room = StringName(arg.trim_prefix("--room="))
		elif arg.begins_with("--spawn="):
			spawn = StringName(arg.trim_prefix("--spawn="))
		elif arg.begins_with("--frames="):
			wait_frames = int(arg.trim_prefix("--frames="))
		elif arg.begins_with("--place="):
			var parts := arg.trim_prefix("--place=").split(",")
			place = Vector2(float(parts[0]), float(parts[1]))
		elif arg.begins_with("--facing="):
			facing = _dir(arg.trim_prefix("--facing="))
		elif arg.begins_with("--action="):
			action = arg.trim_prefix("--action=")
		elif arg == "--dev":
			dev = true
		elif arg == "--hitboxes":
			hitboxes = true
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(1920, 1080)
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)
	var world := (load("res://scenes/world/world.tscn") as PackedScene).instantiate() as World
	_viewport.add_child(world)
	await get_tree().physics_frame
	if dev:
		world.apply_dev_loadout()
	else:
		GameState.acquire_item(&"tether_moth")
		GameState.acquire_item(&"pitch_pot")
		GameState.add_pitch_pots(3)
	GameState.damage(3)
	world.start_at(room, spawn)
	if place != Vector2.INF:
		world.player.place_at(world.get_room(room).global_position + place)
	if facing != Vector2.ZERO:
		world.player.facing = facing
	if hitboxes:
		world.set_debug_draw(true)
	await _frames(wait_frames)
	match action:
		"flare", "charge":
			Input.action_press(&"attack")
			await _frames(54)
			if action == "flare":
				Input.action_release(&"attack")
				await _frames(3)
		"pot":
			GameState.set_active_item(&"pitch_pot")
			world.player.use_item()
			await _frames(97)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := _viewport.get_texture().get_image()
	image.save_png(out)
	print("saved ", out, " ", image.get_size())
	Input.action_release(&"attack")
	get_tree().quit()


func _frames(n: int) -> void:
	for i in range(n):
		await get_tree().physics_frame


func _dir(dir_name: String) -> Vector2:
	match dir_name:
		"up":
			return Vector2.UP
		"left":
			return Vector2.LEFT
		"right":
			return Vector2.RIGHT
		_:
			return Vector2.DOWN
