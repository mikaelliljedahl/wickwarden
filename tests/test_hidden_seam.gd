extends TestCase
## Hidden seams: invisible and solid until a glow jar has lit them for 1.0 s (the flag then persists) or a
## lamp hook taps the hook-tap wall; a jar that stops early hides them again; stairs get a RoomDoor once
## shown; each scene has its look.

const SEAM := "res://scenes/world/hidden_seam.tscn"
const STAIRS := "res://scenes/world/hidden_stairs.tscn"
const SEALED := "res://scenes/world/sealed_seam.tscn"
const TAP := "res://scenes/world/hook_tap_wall.tscn"
const AT := Vector2(400, 400)


func run() -> void:
	await _starts_hidden_and_solid()
	await _jar_unseals_after_one_second()
	await _jar_that_stops_early_hides_again()
	await _hide_again_keeps_a_permanent_reveal()
	await _flag_keeps_it_open_on_reentry()
	await _hook_taps_the_tap_wall()
	await _other_hits_do_nothing()
	await _stairs_get_a_door_once_shown()
	_scenes_have_their_look()


## Builds a seam of `scene_path` with a seam id, in the arena at `at`.
func _make_seam(parent: Node, scene_path: String, id: StringName, at: Vector2) -> Variant:
	var scene := load(scene_path) as PackedScene
	var seam: Node = scene.instantiate()
	seam.set(&"seam_id", id)
	parent.add_child(seam)
	(seam as Node2D).global_position = at
	return seam


## Lights a seam the way the glow jar does: one reveal() call per physics frame for `frames_n` frames.
func _light(seam: Variant, frames_n: int) -> void:
	for i in range(frames_n):
		seam.reveal()
		await frames(1)


## A Hitbox of `kind` and the PLAYER team (like the lamp hook or a flare), active at `at`.
func _make_hit(parent: Node, kind: StringName, at: Vector2) -> Hitbox:
	var hitbox := Hitbox.new()
	hitbox.kind = kind
	hitbox.team = Layers.Team.PLAYER
	hitbox.add_circle(24.0)
	parent.add_child(hitbox)
	hitbox.global_position = at
	hitbox.activate()
	return hitbox


func _body_disabled(seam: Node) -> bool:
	return (seam.get_node("Body/Shape") as CollisionShape2D).disabled


func _visual_shown(seam: Node) -> bool:
	return (seam.get_node("Visual") as CanvasItem).visible


func _starts_hidden_and_solid() -> void:
	reset_state()
	var arena := make_arena()
	var seam: Variant = _make_seam(arena, SEAM, &"test_seam", AT)
	await frames(2)
	check(seam.is_in_group(&"revealable"), "a hidden seam is in group revealable")
	check(not seam.is_revealed and not seam.is_shown, "a hidden seam starts hidden")
	check(not _visual_shown(seam), "a hidden seam has no visible look")
	check(not _body_disabled(seam), "a hidden seam is solid")
	check(
		(seam.get_node("Body") as StaticBody2D).collision_layer == Layers.WORLD,
		"the seam body is on the WORLD layer"
	)
	check(not GameState.has_flag(&"revealed_test_seam"), "no flag before a reveal")
	await dispose(arena)


func _jar_unseals_after_one_second() -> void:
	reset_state()
	var arena := make_arena()
	var seam: Variant = _make_seam(arena, SEAM, &"test_jar", AT)
	await frames(2)
	seam.reveal()
	check(seam.is_shown and _visual_shown(seam), "one reveal() shows the seam at once")
	await frames(1)
	check(_body_disabled(seam), "a shown seam has no blocker")
	check(not seam.is_revealed, "one reveal() is not yet permanent")
	check(not GameState.has_flag(&"revealed_test_jar"), "no flag before 1.0 s of exposure")
	await _light(seam, 30)
	check(not seam.is_revealed, "half a second of exposure does not unseal it")
	await _light(seam, 32)
	check(seam.is_revealed, "1.0 s of continuous exposure unseals it for good")
	check(GameState.has_flag(&"revealed_test_jar"), "unsealing sets flag revealed_<id>")
	check(not seam.is_in_group(&"revealable"), "an unsealed seam is no longer revealable")
	check(_visual_shown(seam) and _body_disabled(seam), "an unsealed seam stays open")
	await dispose(arena)


func _jar_that_stops_early_hides_again() -> void:
	reset_state()
	var arena := make_arena()
	var seam: Variant = _make_seam(arena, SEAM, &"test_early", AT)
	await frames(2)
	await _light(seam, 20)
	check(seam.is_shown, "a seam lit for a third of a second is shown")
	await seconds(0.5)
	check(not seam.is_shown and not _visual_shown(seam), "the light gone, the seam hides again")
	check(not _body_disabled(seam), "a hidden seam is solid again")
	check(not seam.is_revealed, "a seam lit only briefly stays revealable")
	check(not GameState.has_flag(&"revealed_test_early"), "a brief light sets no flag")
	seam.reveal()
	seam.hide_again()
	check(not seam.is_shown, "hide_again() hides a temporary reveal at once")
	await dispose(arena)


func _hide_again_keeps_a_permanent_reveal() -> void:
	reset_state()
	var arena := make_arena()
	var seam: Variant = _make_seam(arena, SEAM, &"test_keep", AT)
	await frames(2)
	await _light(seam, 62)
	check(seam.is_revealed, "the seam unsealed for good")
	seam.hide_again()
	check(seam.is_shown and _visual_shown(seam), "hide_again() does not hide a permanent reveal")
	check(_body_disabled(seam), "a permanent reveal keeps its blocker off")
	await dispose(arena)


func _flag_keeps_it_open_on_reentry() -> void:
	reset_state()
	var arena := make_arena()
	var first: Variant = _make_seam(arena, SEAM, &"test_reenter", AT)
	await frames(2)
	await _light(first, 62)
	await dispose(arena)
	# A new visit: the room is built again from its scene and the flag is still set.
	var later := make_arena()
	var again: Variant = _make_seam(later, SEAM, &"test_reenter", AT)
	await frames(2)
	check(again.is_revealed and again.is_shown, "a later visit starts with the seam open")
	check(_visual_shown(again) and _body_disabled(again), "a reopened seam shows and is passable")
	check(not again.is_in_group(&"revealable"), "a reopened seam is not revealable again")
	await dispose(later)


func _hook_taps_the_tap_wall() -> void:
	reset_state()
	var arena := make_arena()
	var wall: Variant = _make_seam(arena, TAP, &"test_tap", AT)
	await frames(2)
	check(wall.is_in_group(&"revealable"), "a tap wall is also revealable (group revealable)")
	var flare := _make_hit(arena, &"flare", AT)
	await frames(3)
	check(not wall.is_revealed, "a flare does not tap a tap wall")
	flare.deactivate()
	await dispose(flare)
	var hook := _make_hit(arena, &"hook", AT)
	await frames(3)
	check(wall.is_revealed, "a hook tap unseals a tap wall at once")
	check(GameState.has_flag(&"revealed_test_tap"), "a hook tap sets flag revealed_<id>")
	check(_visual_shown(wall) and _body_disabled(wall), "a tapped wall is open")
	hook.deactivate()
	await dispose(hook)
	await dispose(arena)


func _other_hits_do_nothing() -> void:
	reset_state()
	var arena := make_arena()
	var seam: Variant = _make_seam(arena, SEAM, &"test_plain", AT)
	var stairs: Variant = _make_seam(arena, STAIRS, &"test_stairs", Vector2(400, 700))
	await frames(2)
	var hook := _make_hit(arena, &"hook", AT)
	var fire := _make_hit(arena, &"fire", Vector2(400, 700))
	await seconds(0.5)
	check(not seam.is_shown and not seam.is_revealed, "a hook does not reveal a plain seam")
	check(not stairs.is_shown and not stairs.is_revealed, "a fire does not reveal stairs")
	check(not GameState.has_flag(&"revealed_test_plain"), "a hook hit sets no flag on a plain seam")
	hook.deactivate()
	fire.deactivate()
	await dispose(hook)
	await dispose(fire)
	await dispose(arena)


func _stairs_get_a_door_once_shown() -> void:
	reset_state()
	var scene := load(STAIRS) as PackedScene
	var arena := make_arena()
	var stairs: Variant = scene.instantiate()
	stairs.set(&"seam_id", &"test_door")
	stairs.set(&"door_target", &"cave_7_1")
	stairs.set(&"door_spawn", &"FromOverworld")
	arena.add_child(stairs)
	stairs.global_position = AT
	await frames(2)
	check(stairs.get_node_or_null("Door") == null, "a hidden stair has no door yet")
	await _light(stairs, 62)
	var door := stairs.get_node_or_null("Door") as RoomDoor
	check(door != null, "a revealed stair gets a RoomDoor")
	if door == null:
		await dispose(arena)
		return
	check(door.target_room == &"cave_7_1", "the door leads to the target room")
	check(door.target_spawn == &"FromOverworld", "the door uses the target spawn")
	check(door.monitoring, "a revealed door is on")
	await dispose(arena)
	# The seam reopens for later visits: the same door is on from the first frame.
	var later := make_arena()
	var again := scene.instantiate()
	again.set(&"seam_id", &"test_door")
	again.set(&"door_target", &"cave_7_1")
	later.add_child(again)
	again.global_position = AT
	await frames(2)
	var again_door := again.get_node_or_null("Door") as RoomDoor
	check(again_door != null and again_door.monitoring, "a revealed stair starts with its door on")
	check(again_door != null and again_door.target_room == &"cave_7_1", "and it keeps its target")
	await dispose(later)


func _scenes_have_their_look() -> void:
	var looks := {
		SEAM: &"hidden_seam",
		STAIRS: &"hidden_stairs",
		SEALED: &"sealed_seam",
		TAP: &"hook_tap_wall",
	}
	for scene_path in looks:
		var scene := load(scene_path) as PackedScene
		check(scene != null, "%s loads" % scene_path)
		if scene == null:
			continue
		var seam: Node = scene.instantiate()
		check(
			seam.get(&"look") == looks[scene_path],
			"%s has look %s" % [scene_path, looks[scene_path]]
		)
		check(
			Placeholder.has_kind(looks[scene_path]),
			"%s is a registered placeholder kind" % scene_path
		)
		check(seam.get(&"size") == Vector2(192, 96), "%s fills a 192 x 96 px gap" % scene_path)
		check(seam.get(&"hook_tap") == (scene_path == TAP), "%s tap flag is right" % scene_path)
		seam.free()
