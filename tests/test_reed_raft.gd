extends TestCase
## Reed raft (T03), water zone part: a deep WaterZone answers the geometric questions the raft clamp needs
## (contains_point, nearest_point) and has a blocking body on layer WATER; a shallow one has none; both are in
## the groups `water_zone` and `shallows` (fen leeches live in either); the scene loads.

const ZONE_SCENE := "res://scenes/world/water_zone.tscn"
const ZONE_CENTRE := Vector2(600, 400)
const ZONE_SIZE := Vector2(192, 96)


func run() -> void:
	await _geometry()
	await _deep_has_blocker()
	await _shallow_has_no_blocker()
	await _groups_and_scene()


func _make_zone(parent: Node, deep: bool) -> Area2D:
	var scene := load(ZONE_SCENE) as PackedScene
	var zone := scene.instantiate() as Area2D
	zone.set(&"size", ZONE_SIZE)
	zone.set(&"deep", deep)
	parent.add_child(zone)
	zone.global_position = ZONE_CENTRE
	return zone


func _geometry() -> void:
	reset_state()
	var arena := make_arena()
	var zone := _make_zone(arena, true)
	await frames(2)
	check(zone.call(&"contains_point", ZONE_CENTRE), "the centre is inside the water zone")
	check(
		zone.call(&"contains_point", ZONE_CENTRE + ZONE_SIZE * 0.5), "the corner counts as inside"
	)
	check(
		not zone.call(&"contains_point", ZONE_CENTRE + Vector2(120, 0)),
		"a point east of the zone is outside"
	)
	check_eq(
		zone.call(&"nearest_point", ZONE_CENTRE + Vector2(300, 0)),
		ZONE_CENTRE + Vector2(ZONE_SIZE.x * 0.5, 0),
		"the nearest point to a point east of the zone is on its east edge"
	)
	check_eq(
		zone.call(&"nearest_point", ZONE_CENTRE),
		ZONE_CENTRE,
		"the nearest point to an inside point is the point itself"
	)
	await dispose(arena)


func _deep_has_blocker() -> void:
	reset_state()
	var arena := make_arena()
	var zone := _make_zone(arena, true)
	await frames(2)
	var blocker := zone.get_node_or_null("Blocker") as StaticBody2D
	check(blocker != null, "a deep zone has a blocking body")
	if blocker != null:
		check_eq(blocker.collision_layer, Layers.WATER, "the blocker is on layer WATER")
		var shape := blocker.get_node("Shape") as CollisionShape2D
		check_eq(
			(shape.shape as RectangleShape2D).size, ZONE_SIZE, "the blocker covers the footprint"
		)
	var enemy := make_dummy(arena, ZONE_CENTRE + Vector2(0, 300))
	await frames(2)
	check(enemy.collision_mask & Layers.WATER != 0, "ground enemies collide with WATER")
	await dispose(arena)


func _shallow_has_no_blocker() -> void:
	reset_state()
	var arena := make_arena()
	var zone := _make_zone(arena, false)
	await frames(2)
	check(zone.get_node_or_null("Blocker") == null, "a shallow zone has no blocking body")
	await dispose(arena)


func _groups_and_scene() -> void:
	reset_state()
	var arena := make_arena()
	var deep := _make_zone(arena, true)
	var shallow := _make_zone(arena, false)
	await frames(2)
	for zone in [deep, shallow]:
		check(zone.is_in_group(&"water_zone"), "a water zone is in group water_zone")
		check(
			zone.is_in_group(&"shallows"), "a water zone is in group shallows (leeches live in it)"
		)
	check(Placeholder.has_kind(&"deep_water"), "the deep water look is registered")
	await dispose(arena)
