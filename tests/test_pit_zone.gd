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
	await _fall_ignores_hit_iframes()
	await _unsafe_spawn_charges_once()
	await _lethal_fall_during_iframes()
	await _held_input_recovery()


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
	check_eq(
		player.global_position,
		spawn.global_position,
		"the room's pit returns her to the spot she stood on"
	)
	await dispose(arena)


func _fall_ignores_hit_iframes() -> void:
	reset_state()
	var arena := make_arena()
	_make_pit(arena, PIT_SCENE, PIT_CENTRE)
	_make_pit(arena, PIT_SCENE, PIT_CENTRE)
	var hero := make_player(arena, SAFE)
	var notifications: Array[int] = []
	hero.hurt_taken.connect(func(amount: int) -> void: notifications.append(amount))
	await frames(2)
	check(hero.take_damage(1, SAFE, 0.0), "ordinary hit establishes active i-frames")
	check(hero.is_invulnerable(), "i-frames are active before fall")
	check(not hero.take_damage(1, SAFE), "ordinary second hit is rejected")
	hero.global_position = PIT_CENTRE
	await frames(3)
	check_eq(GameState.health, 3, "genuine fall charges2 despite active hit i-frames")
	check_eq(notifications, [1, 2], "overlapping pits emit one fall damage event")
	check_eq(hero.global_position, SAFE, "fall preserves last-safe return policy")
	check(hero.is_invulnerable(), "fall preserves ordinary post-hit protection")
	check(not hero.take_damage(1, SAFE), "post-fall ordinary hit is still immune")
	SaveGame.enabled = true
	check(SaveGame.save(), "post-fall health can be saved through existing API")
	GameState.full_heal()
	check(SaveGame.load_into_state(), "post-fall save loads through existing API")
	check_eq(GameState.health, 3, "save round-trip preserves genuine fall cost")
	SaveGame.erase()
	SaveGame.enabled = false
	await frames(20)
	check_eq(GameState.health, 3, "safe return is not charged repeatedly")
	# A new physical fall must work even while the preceding fall's i-frames remain active.
	hero.global_position = PIT_CENTRE
	await frames(3)
	check_eq(GameState.health, 1, "safe-ground recovery rearms a distinct fall during i-frames")
	await dispose(arena)


func _unsafe_spawn_charges_once() -> void:
	reset_state()
	var arena := make_arena()
	_make_pit(arena, PIT_SCENE, PIT_CENTRE)
	_make_pit(arena, PIT_SCENE, PIT_CENTRE)
	var hero := make_player(arena, PIT_CENTRE)
	await frames(30)
	check_eq(GameState.health, 4, "unsafe fallback spawn incurs one fall episode")
	check(not hero.is_dead(), "unsafe fallback does not drain health every physics frame")
	hero.place_at(SAFE)
	await frames(3)
	hero.global_position = PIT_CENTRE
	await frames(3)
	check_eq(GameState.health, 2, "leaving unsafe fallback rearms genuine future fall")
	await dispose(arena)


func _lethal_fall_during_iframes() -> void:
	reset_state()
	var arena := make_arena()
	_make_pit(arena, PIT_SCENE, PIT_CENTRE)
	var hero := make_player(arena, SAFE)
	var deaths := [0]
	hero.died.connect(func() -> void: deaths[0] += 1)
	await frames(2)
	GameState.health = 3
	hero.take_damage(1, SAFE, 0.0)
	hero.global_position = PIT_CENTRE
	await frames(10)
	check_eq(GameState.health, 0, "lethal fall writes zero through GameState health pipeline")
	check(hero.is_dead(), "lethal fall kills despite previous hit i-frames")
	check_eq(deaths[0], 1, "lethal fall emits death only once")
	check_eq(hero.global_position, PIT_CENTRE, "lethal fall does not relocate corpse")
	GameState.full_heal()
	hero.respawn(SAFE)
	await frames(3)
	check_eq(GameState.health, 6, "ordinary respawn health remains GameState-owned")
	check(not hero.is_dead() and not hero.is_invulnerable(), "respawn restores ordinary live state")
	await dispose(arena)


func _held_input_recovery() -> void:
	reset_state()
	var arena := make_arena()
	_make_pit(arena, PIT_SCENE, PIT_CENTRE)
	var lip := Vector2(476, 500)
	var hero := make_player(arena, lip)
	await frames(3)
	Input.action_press(&"move_right")
	await frames(30)
	check_eq(GameState.health, 4, "held input at return lip does not repeat fall damage")
	check(hero.global_position.x < 500, "recovery relocation prevents walking through the pit")
	release_inputs()
	await frames(3)
	hero.global_position = PIT_CENTRE
	await frames(3)
	check_eq(GameState.health, 2, "grounded recovery rearms a later distinct fall")
	await dispose(arena)
