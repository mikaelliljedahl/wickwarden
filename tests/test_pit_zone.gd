extends TestCase
## Pit zones (P04): a walk into a pit costs 2 half-hearts and returns Tamsin to the last safe spot;
## a leap over a pit (the airborne state of the boots) is safe; a leap that lands in a pit falls; a
## fall that kills leaves her where she died; two pits holding her cost one fall; the scenes load;
## the room's own spawn is the fallback and the room gallery fixture works.

const PIT_SCENE := "res://scenes/world/pit.tscn"
const RAVINE_SCENE := "res://scenes/world/ravine_leap.tscn"
const FIXTURE_SCENE := "res://tests/fixtures/gallery/P04.tscn"
const SAFE := Vector2(300, 500)
const PIT_CENTRE := Vector2(600, 500)


func run() -> void:
	await _walk_in_falls()
	await _leap_over_is_safe()
	await _landing_in_pit_falls()
	await _fall_can_kill()
	await _two_pits_one_fall()
	await _scenes_load()
	await _room_fixture()


func _make_pit(parent: Node, scene_path: String, at: Vector2) -> Node2D:
	var scene := load(scene_path) as PackedScene
	var pit := scene.instantiate() as Node2D
	parent.add_child(pit)
	pit.global_position = at
	return pit


func _walk_in_falls() -> void:
	reset_state()
	var arena := make_arena()
	_make_pit(arena, PIT_SCENE, PIT_CENTRE)
	var player := make_player(arena, SAFE)
	await frames(2)
	var health := GameState.health
	player.global_position = PIT_CENTRE  # the walk in, in one step
	await frames(3)
	check_eq(GameState.health, health - 2, "a fall costs 2 half-hearts")
	check_eq(player.global_position, SAFE, "a fall returns Tamsin to the last safe spot")
	check(not player.is_dead(), "one fall does not kill a healthy player")
	await dispose(arena)


func _leap_over_is_safe() -> void:
	reset_state()
	var arena := make_arena()
	_make_pit(arena, PIT_SCENE, PIT_CENTRE)
	var player := make_player(arena, Vector2(400, 500))
	await frames(2)
	var health := GameState.health
	var path: Array[Vector2] = [PIT_CENTRE, Vector2(800, 500)]
	check(player.begin_external_motion(path, 600.0, {"airborne": true}), "the leap starts")
	await frames(20)  # over the middle of the pit
	check(player.is_airborne(), "the stand-in airborne state is on over the pit")
	check_eq(GameState.health, health, "no fall while airborne over a pit")
	check(player.global_position.x > 550.0, "the leap is over the pit")
	await seconds(1.0)
	check(not player.is_external_motion(), "the leap is over")
	check_eq(GameState.health, health, "landing past the pit costs nothing")
	check_near(player.global_position.x, 800.0, 0.5, "Tamsin lands on the far side")
	await dispose(arena)


func _landing_in_pit_falls() -> void:
	reset_state()
	var arena := make_arena()
	_make_pit(arena, PIT_SCENE, PIT_CENTRE)
	var player := make_player(arena, SAFE)
	await frames(2)
	var health := GameState.health
	var path: Array[Vector2] = [PIT_CENTRE]
	player.begin_external_motion(path, 600.0, {"airborne": true})
	await seconds(1.0)
	check_eq(GameState.health, health - 2, "a leap that lands in a pit falls")
	check_eq(player.global_position, SAFE, "the fall goes back to the spot before the leap")
	await dispose(arena)


func _fall_can_kill() -> void:
	reset_state()
	var arena := make_arena()
	_make_pit(arena, PIT_SCENE, PIT_CENTRE)
	var player := make_player(arena, SAFE)
	await frames(2)
	GameState.health = 2
	player.global_position = PIT_CENTRE
	await frames(3)
	check(player.is_dead(), "a fall at one half-heart kills")
	check(player.global_position.distance_to(PIT_CENTRE) < 1.0, "a dead player is not moved back")
	await dispose(arena)


func _two_pits_one_fall() -> void:
	reset_state()
	var arena := make_arena()
	_make_pit(arena, PIT_SCENE, PIT_CENTRE)
	_make_pit(arena, PIT_SCENE, PIT_CENTRE)
	var player := make_player(arena, SAFE)
	await frames(2)
	var health := GameState.health
	player.global_position = PIT_CENTRE
	await frames(3)
	check_eq(GameState.health, health - 2, "two overlapping pits cost one fall")
	check_eq(player.global_position, SAFE, "two overlapping pits return her to the safe spot")
	await dispose(arena)


func _scenes_load() -> void:
	reset_state()
	var arena := make_arena()
	for scene_path in [PIT_SCENE, RAVINE_SCENE]:
		var pit := _make_pit(arena, scene_path, Vector2(200, 200))
		check(pit != null, "%s instantiates" % scene_path)
		check(pit.is_in_group(&"pit_zone"), "%s is in group pit_zone" % scene_path)
		check(pit.get_node_or_null("Visual") != null, "%s has a Visual child" % scene_path)
	await dispose(arena)


func _room_fixture() -> void:
	reset_state()
	var arena := make_arena()
	var scene := load(FIXTURE_SCENE) as PackedScene
	var room := scene.instantiate() as Node2D
	arena.add_child(room)
	await frames(2)
	var spawn := room.get_node("Spawns/Default") as Marker2D
	var pit := room.get_node("Props/Pit") as Node2D
	var player := make_player(arena, spawn.global_position)
	await frames(2)
	var health := GameState.health
	player.global_position = pit.global_position
	await frames(3)
	check_eq(GameState.health, health - 2, "the room's pit costs 2 half-hearts")
	check_eq(player.global_position, spawn.global_position, "the room's pit returns her to the spot she stood on")
	await dispose(arena)
