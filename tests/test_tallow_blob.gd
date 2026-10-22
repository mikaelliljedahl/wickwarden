extends TestCase
## Tallow blob and tallow drop: stats, stepping toward the player, splitting on death, room rect.

const BLOB_SCENE := "res://scenes/enemies/tallow_blob.tscn"
const DROP_SCENE := "res://scenes/enemies/tallow_drop.tscn"
const BLOB_SCRIPT := "res://scripts/enemies/tallow_blob.gd"
const DROP_SCRIPT := "res://scripts/enemies/tallow_drop.gd"
const ROOM := Rect2(0, 0, 1920, 960)


func run() -> void:
	await _test_stats()
	await _test_moves_toward_player()
	await _test_split_on_death()
	await _test_drop_does_not_split()
	await _test_split_near_wall_stays_in_room()


## Direct children of `parent` whose script is `script_path` (the most derived script).
func _children_with_script(parent: Node, script_path: String) -> Array[Node]:
	var found: Array[Node] = []
	for child in parent.get_children():
		var attached: Script = child.get_script()
		if attached != null and attached.resource_path == script_path:
			found.append(child)
	return found


func _test_stats() -> void:
	reset_state()
	var arena := make_arena()
	var blob := make_enemy(arena, BLOB_SCENE, Vector2(400, 300))
	var drop := make_enemy(arena, DROP_SCENE, Vector2(600, 300))
	await frames(2)
	check_eq(blob.hp, 2, "tallow blob has 2 hp")
	check_eq(blob.contact_damage, 1, "tallow blob contact damage is 1")
	check_eq(blob.move_speed, 160.0, "tallow blob speed is 160")
	check_eq(drop.hp, 1, "tallow drop has 1 hp")
	check_eq(drop.contact_damage, 1, "tallow drop contact damage is 1")
	check_eq(drop.move_speed, 220.0, "tallow drop speed is 220")
	check(drop.body_radius < blob.body_radius, "tallow drop is smaller than the blob")
	await dispose(arena)


func _test_moves_toward_player() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(900, 300))
	var blob := make_enemy(arena, BLOB_SCENE, Vector2(400, 300))
	blob.room_rect = ROOM
	await frames(2)
	var start_dist := blob.global_position.distance_to(player.global_position)
	var moved := false
	for i in range(180):
		await frames(1)
		moved = moved or blob.velocity.length() > 0.0
	var end_dist := blob.global_position.distance_to(player.global_position)
	check(moved, "tallow blob takes steps")
	check(end_dist < start_dist - 40.0, "tallow blob moves toward the player")
	await dispose(arena)


func _test_split_on_death() -> void:
	reset_state()
	var arena := make_arena()
	var blob := make_enemy(arena, BLOB_SCENE, Vector2(600, 400))
	blob.room_rect = ROOM
	blob.drop_roll_override = 0.99
	await frames(2)
	blob.apply_damage(1, blob.global_position + Vector2(-30, 0))
	check_eq(blob.hp, 1, "damage reduces tallow blob hp")
	await seconds(0.4)
	# The first hit knocks the blob sideways, so the death position is measured, not assumed.
	var death_pos := blob.global_position
	blob.apply_damage(1, blob.global_position + Vector2(-30, 0))
	await frames(2)
	check(not is_instance_valid(blob), "tallow blob dies at 0 hp")
	var drops := _children_with_script(arena, DROP_SCRIPT)
	check_eq(drops.size(), 2, "killing a blob spawns exactly 2 tallow drops")
	check_eq(_children_with_script(arena, BLOB_SCRIPT).size(), 0, "a blob does not respawn itself")
	if drops.size() == 2:
		var xs: Array[float] = []
		for drop in drops:
			var d := drop as EnemyBase
			check(d.room_rect == ROOM, "tallow drop has the blob's room rect")
			check_near(d.global_position.y, death_pos.y, 1.0, "tallow drop spawns level with the blob")
			xs.append(d.global_position.x)
		xs.sort()
		check_near(xs[0], death_pos.x - 30.0, 1.0, "one tallow drop is 30 px left of the blob")
		check_near(xs[1], death_pos.x + 30.0, 1.0, "one tallow drop is 30 px right of the blob")
	await dispose(arena)


func _test_drop_does_not_split() -> void:
	reset_state()
	var arena := make_arena()
	var drop := make_enemy(arena, DROP_SCENE, Vector2(600, 400))
	drop.room_rect = ROOM
	drop.drop_roll_override = 0.99
	await frames(2)
	drop.apply_damage(1, drop.global_position + Vector2(-30, 0))
	await frames(2)
	check(not is_instance_valid(drop), "tallow drop dies at 0 hp")
	check_eq(_children_with_script(arena, DROP_SCRIPT).size(), 0, "a dying drop spawns no drops")
	check_eq(_children_with_script(arena, BLOB_SCRIPT).size(), 0, "a dying drop spawns no blobs")
	await dispose(arena)


func _test_split_near_wall_stays_in_room() -> void:
	reset_state()
	var arena := make_arena()
	var room := Rect2(0, 0, 800, 600)
	var blob := make_enemy(arena, BLOB_SCENE, Vector2(30, 300))
	blob.room_rect = room
	blob.drop_roll_override = 0.99
	await frames(2)
	blob.kill()
	await frames(2)
	var drops := _children_with_script(arena, DROP_SCRIPT)
	check_eq(drops.size(), 2, "a blob at the room edge still splits into 2 drops")
	for drop in drops:
		var d := drop as EnemyBase
		check(d.room_rect == room, "edge drop has the blob's room rect")
		check(room.has_point(d.global_position), "edge drop stays inside the room")
	await dispose(arena)
