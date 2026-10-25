extends Node
## Controlled fresh-state room portraits, not a continuous or human playthrough.
## make capture-all CAPTURE_ARGS="--rooms=ow_0_0,cave_1 --out=/tmp/captures"
## Defaults to all data targets. --list inventories without rendering. Full runs alone
## publish the 16 contact sheets; subset sheets and index stay beside the captures.

const SIZE := Vector2i(1920, 1080)
const THUMB := Vector2i(480, 270)
const WORLD_SCENE := "res://scenes/world/world.tscn"

var _out := "res://build/screens"
var _selected: PackedStringArray = []
var _frames := 30
var _list := false
var _records: Array[Dictionary] = []
var _viewport: SubViewport
var _failed := false
var _source_sha := ""
var _sheet_records: Array[Dictionary] = []


func _ready() -> void:
	SaveGame.enabled = false
	SaveGame.launch_mode = SaveGame.MODE_DEV
	get_window().unfocusable = true
	get_window().mode = Window.MODE_MINIMIZED
	call_deferred("_run")


func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--rooms="):
			_selected = arg.trim_prefix("--rooms=").split(",", false)
		elif arg.begins_with("--out="):
			_out = arg.trim_prefix("--out=")
		elif arg.begins_with("--frames="):
			_frames = int(arg.trim_prefix("--frames="))
		elif arg == "--list":
			_list = true
		else:
			_fail("Unknown option: " + arg)
	if _frames < 0 or _frames > 600:
		_fail("--frames must be between 0 and 600")
	if _failed:
		get_tree().quit(1)
		return
	_out = ProjectSettings.globalize_path(_out)
	if DirAccess.make_dir_recursive_absolute(_out) != OK:
		_fail("Cannot create output directory " + _out)
		get_tree().quit(1)
		return
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(WorldData.PATH))
	_source_sha = data.get("source_sha", "")
	var targets: Array = data["rooms"].duplicate()
	for pocket: Dictionary in data["pockets"]:
		if not pocket.get("in_place", false):
			targets.append(pocket)
	var known: Array[String] = []
	for target: Dictionary in targets:
		known.append(target["id"])
	for id in _selected:
		if not known.has(id):
			_fail("Not a standalone graph target: " + id)
	print(
		"capture-all: %d targets; binding row says 218 (reported, not rewritten)" % targets.size()
	)
	_viewport = SubViewport.new()
	_viewport.size = SIZE
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_viewport)
	for target: Dictionary in targets:
		if not _selected.is_empty() and not _selected.has(target["id"]):
			continue
		var record := target.duplicate(true)
		record["area"] = target["region"] if target["scope"] == "ow" else target["scope"]
		record["status"] = "listed" if ResourceLoader.exists(target["scene"]) else "missing"
		record["image"] = ""
		_records.append(record)
		if record["status"] == "missing":
			_fail("Missing scene for %s: %s" % [target["id"], target["scene"]])
		elif not _list:
			await _capture(record)
	if not _list:
		await _sheets()
	_write_index(targets.size())
	print(
		(
			"capture-all: %d selected; failed=%s; index=%s/index.json"
			% [_records.size(), _failed, _out]
		)
	)
	get_tree().quit(1 if _failed else 0)


func _capture(record: Dictionary) -> void:
	seed(1)
	GameState.reset()
	var packed := load(WORLD_SCENE) as PackedScene
	if packed == null:
		_fail("Cannot load World")
		record["status"] = "failed"
		return
	var world := packed.instantiate() as World
	_viewport.add_child(world)
	var id := StringName(record["id"])
	if world.get_room(id) == null:
		_fail("World cannot load " + str(id))
		record["status"] = "failed"
	else:
		world.start_at(id)
		world.set_process_unhandled_input(false)
		world.player.set_process_unhandled_input(false)
		for frame in range(_frames):
			await get_tree().physics_frame
		world.process_mode = Node.PROCESS_MODE_DISABLED
		# Occlusion/minimization can suppress frame_post_draw. Force the draw directly;
		# never await that signal. The outer launcher also bounds the whole process.
		RenderingServer.force_draw(false)
		var image := _viewport.get_texture().get_image()
		var path := _out.path_join(str(id) + ".png")
		if image == null or image.is_empty() or image.get_size() != SIZE:
			_fail("Invalid rendered image for " + str(id))
			record["status"] = "failed"
		elif image.save_png(path) != OK:
			_fail("Cannot save " + path)
			record["status"] = "failed"
		else:
			record["status"] = "captured"
			record["image"] = path
			record["dark_actual"] = world.current_room.dark
			record["health"] = GameState.health
			record["flags"] = GameState.flags.keys()
			record["items"] = GameState.items.keys()
			record["sha256"] = FileAccess.get_sha256(path)
			record["player_position"] = str(world.player.position - world.current_room.position)
			print("captured ", id)
	world.free()
	await get_tree().process_frame


func _sheets() -> void:
	var areas: Dictionary = {}
	for record in _records:
		if record["status"] == "captured":
			var area: String = record["area"]
			if not areas.has(area):
				areas[area] = []
			areas[area].append(record)
	for area: String in areas:
		var records: Array = areas[area]
		var sheet := SubViewport.new()
		sheet.size = Vector2i(1920, ceili(records.size() / 4.0) * 300)
		sheet.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(sheet)
		for i in range(records.size()):
			var image := Image.load_from_file(records[i]["image"])
			image.resize(THUMB.x, THUMB.y, Image.INTERPOLATE_LANCZOS)
			var picture := TextureRect.new()
			picture.texture = ImageTexture.create_from_image(image)
			picture.position = Vector2((i % 4) * 480, (i / 4) * 300)
			sheet.add_child(picture)
			var label := Label.new()
			label.text = records[i]["id"]
			label.position = picture.position + Vector2(8, 270)
			label.add_theme_font_size_override("font_size", 20)
			sheet.add_child(label)
		await get_tree().process_frame
		RenderingServer.force_draw(false)
		var image := sheet.get_texture().get_image()
		var path := _out.path_join("contact-%s.png" % area)
		if image.save_png(path) != OK:
			_fail("Cannot save sheet " + path)
		else:
			_sheet_records.append(
				{
					"area": area,
					"path": path,
					"ids": records.map(func(record: Dictionary) -> String: return record["id"])
				}
			)
		sheet.free()
	# Publish only after every target and every sheet succeeded. Subset sheets
	# remain outside docs so they cannot be mistaken for complete area coverage.
	if _selected.is_empty() and not _failed:
		var destination := ProjectSettings.globalize_path("res://docs/screens/step3")
		if DirAccess.make_dir_recursive_absolute(destination) != OK:
			_fail("Cannot create contact sheet directory")
			return
		for sheet: Dictionary in _sheet_records:
			if (
				DirAccess.copy_absolute(
					sheet["path"], destination.path_join("contact-%s.png" % sheet["area"])
				)
				!= OK
			):
				_fail("Cannot publish " + str(sheet["area"]))


func _write_index(total: int) -> void:
	var file := FileAccess.open(_out.path_join("index.json"), FileAccess.WRITE)
	if file == null:
		_fail("Cannot write index")
		return
	file.store_string(
		JSON.stringify(
			{
				"source_sha": _source_sha,
				"expected_targets": total,
				"binding_row_count": 218,
				"subset": not _selected.is_empty(),
				"inventory_only": _list,
				"failed": _failed,
				"viewport": [1920, 1080],
				"thumbnail": [480, 270],
				"physics_frames": _frames,
				"seed": 1,
				"state": "fresh GameState before entry; Default spawn; no granted tools or flags",
				"engine": Engine.get_version_info()["string"],
				"sheets": _sheet_records,
				"coverage": "controlled still captures, not continuous human playthrough",
				"audio": AudioServer.get_driver_name(),
				"display": DisplayServer.get_name(),
				"renderer": RenderingServer.get_current_rendering_method(),
				"targets": _records
			},
			"\t"
		)
	)


func _fail(message: String) -> void:
	_failed = true
	printerr("capture-all: ", message)
