extends TestCase
## Pocket door (P14): a RoomDoor that looks like its named entrance. Every variant gets its placeholder look.
## Stand-in host room and pocket (built here, added with add_room_scene): the way in fades and lands on
## `Inside`; the door in the pocket is the same scene and leads back to `FromPocket`.

const SCENE := "res://scenes/world/pocket_door.tscn"
const SCRIPT := "res://scripts/world/pocket_door.gd"
const HOST := &"ow_7_2"
const POCKET := &"ow_7_2#bag"
const VARIANTS: Array[String] = [
	"stall", "cart", "lighthouse", "mason", "hut", "grotto", "stairs", "plain"
]
const DOOR_AT := Vector2(960, 420)
const INSIDE_AT := Vector2(960, 700)

var world: World
var player: Player


func run() -> void:
	reset_state()
	world = await make_world()
	player = world.player
	await _built_entrance_looks()
	_variants_have_their_look()
	await _same_scene_both_sides()
	await _enter_and_leave()
	await dispose(world)


## Builds a pocket door of `variant` (untyped: the script has no class_name use here).
func _make_door(parent: Node, variant: String, at: Vector2) -> Variant:
	var scene := load(SCENE) as PackedScene
	check(scene != null, "the pocket door scene loads")
	var door: Node = scene.instantiate()
	door.set(&"variant", variant)
	parent.add_child(door)
	(door as Node2D).global_position = at
	return door


func _variants_have_their_look() -> void:
	var arena := make_arena()
	for variant in VARIANTS:
		var door: Variant = _make_door(arena, variant, DOOR_AT)
		await frames(1)
		var kind := StringName("pocket_%s" % variant)
		check(Placeholder.has_kind(kind), "variant %s has a placeholder look" % variant)
		var visual := door.get_node(Placeholder.VISUAL_NAME) as Node2D
		check(visual != null, "variant %s has a Visual child" % variant)
		check_eq(visual.get("kind"), kind, "variant %s shows its own look" % variant)
		check(Placeholder.is_static_kind(kind), "variant %s is a static look" % variant)
		check((door as RoomDoor).fade, "variant %s fades (link kind door)" % variant)
		check(
			(door as RoomDoor).size == Vector2(96, 96), "variant %s is 96 px like a door" % variant
		)
		await dispose(door)
	var plain: Variant = _make_door(arena, "plain", DOOR_AT)
	check_eq(plain.look_kind(), &"pocket_plain", "look_kind() names the variant")
	await dispose(arena)


## The door inside a pocket is the same scene as the way in.
func _same_scene_both_sides() -> void:
	var arena := make_arena()
	var way_in: Variant = _make_door(arena, "hut", DOOR_AT)
	var way_out: Variant = _make_door(arena, "hut", INSIDE_AT)
	await frames(1)
	check(way_in is RoomDoor and way_out is RoomDoor, "both doors are RoomDoors")
	check_eq(way_in.get_script().resource_path, SCRIPT, "the way in uses the pocket door script")
	check_eq(way_out.get_script().resource_path, SCRIPT, "the way out uses the pocket door script")
	check_eq(way_in.scene_file_path, SCENE, "the way in is the pocket door scene")
	check_eq(way_out.scene_file_path, SCENE, "the way out is the pocket door scene")
	await dispose(arena)


## A stand-in room: walls all round, the given doors and markers, no exits.
func _stand_in(room_id: StringName, markers: Dictionary, door: Dictionary) -> PackedScene:
	var room := Room.new()
	room.name = "Room"
	room.room_id = room_id
	room.grid = WorldData.grid(String(room_id))
	var spawns := Node2D.new()
	spawns.name = "Spawns"
	room.add_child(spawns)
	for marker_name in markers:
		var marker := Marker2D.new()
		marker.name = marker_name
		marker.position = markers[marker_name]
		spawns.add_child(marker)
	var props := Node2D.new()
	props.name = "Props"
	room.add_child(props)
	var scene := load(SCENE) as PackedScene
	var pocket_door: Node = scene.instantiate()
	pocket_door.set(&"variant", "hut")
	pocket_door.set(&"target_room", door["room"])
	pocket_door.set(&"target_spawn", door["spawn"])
	props.add_child(pocket_door)
	(pocket_door as Node2D).position = door["at"]
	_own(room, room)
	var packed := PackedScene.new()
	packed.pack(room)
	room.free()
	return packed


## Sets the owner of every node below `node` to `owner`, so PackedScene.pack keeps them.
func _own(node: Node, owner: Node) -> void:
	for child in node.get_children():
		child.owner = owner
		_own(child, owner)


func _door_in(room: Room) -> Variant:
	return room.get_node("Props").get_child(0)


func _enter_and_leave() -> void:
	world.add_room_scene(
		HOST,
		_stand_in(
			HOST,
			{"Default": Vector2(960, 700), "FromPocket": Vector2(960, 700)},
			{"room": POCKET, "spawn": &"Inside", "at": DOOR_AT}
		)
	)
	world.add_room_scene(
		POCKET,
		_stand_in(
			POCKET,
			{"Default": INSIDE_AT, "Inside": INSIDE_AT},
			{"room": HOST, "spawn": &"FromPocket", "at": DOOR_AT}
		)
	)
	world.start_at(HOST)
	await frames(3)
	var host := world.get_room(HOST)
	var way_in: Variant = _door_in(host)
	check(way_in != null and way_in.fade, "the way in fades")
	check_eq(way_in.target_spawn, &"Inside", "the way in lands on the pocket's Inside marker")

	# The trigger sees the overlap one or two physics frames after the teleport.
	player.place_at(way_in.global_position)
	await frames(3)
	check(world.is_transitioning(), "stepping into the pocket starts a fade")
	await seconds(1.0)
	check_eq(world.get_current_room_id(), POCKET, "the player is inside the pocket")
	var inside := world.get_room(POCKET).get_node("Spawns/Inside") as Node2D
	check(
		player.global_position.distance_to(inside.global_position) < 2.0,
		"the player stands on the Inside marker"
	)

	var way_out: Variant = _door_in(world.get_room(POCKET))
	player.place_at(way_out.global_position)
	await seconds(1.0)
	check_eq(world.get_current_room_id(), HOST, "the exit door leads back to the host room")
	var from_pocket := world.get_room(HOST).get_node("Spawns/FromPocket") as Node2D
	check(
		player.global_position.distance_to(from_pocket.global_position) < 2.0,
		"the player stands on the FromPocket marker"
	)
	world.start_at(&"ow_0_0")
	await frames(2)


## Audit the 26 built overworld/pocket entrances, plus the historical cave exit.
func _built_entrance_looks() -> void:
	var count := 0
	for pocket_id in RoomDoor.POCKET_LOOKS:
		for id in [pocket_id, pocket_id.get_slice("#", 0)]:
			var packed := load(WorldData.scene_path(id)) as PackedScene
			check(packed != null, "%s entrance scene loads" % id)
			var room := packed.instantiate() as Room
			add_child(room)
			await frames(1)
			for child in room.get_node("Props").get_children():
				if not child is RoomDoor:
					continue
				count += 1
				var expected: StringName = (
					&"pocket_plain" if "#" in id else RoomDoor.POCKET_LOOKS[pocket_id]
				)
				check_eq(child.entrance_kind(), expected, "%s uses its actual entrance" % id)
				var visual := child.get_node("Visual")
				if SpriteVisual.has_art(expected):
					check_eq(visual.get("kind"), expected, "%s shows published art" % id)
			await dispose(room)
	for id in ["ow_1_1", "ow_3_5", "ow_5_1", "ow_6_3", "cave_1"]:
		var packed := load(WorldData.scene_path(id)) as PackedScene
		var room := packed.instantiate() as Room
		add_child(room)
		for child in room.get_node("Props").get_children():
			if child is RoomDoor:
				count += 1
				check_eq(
					child.entrance_kind(),
					&"cave_exit" if id == "cave_1" else &"cave_mouth",
					"%s preserves the real cave entrance" % id
				)
		await dispose(room)
	check_eq(count, 27, "all 26 built entrances and the cave exit audited")
