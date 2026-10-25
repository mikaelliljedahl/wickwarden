extends TestCase
## Terrain rendering must follow arbitrary zone sizes without introducing any physics geometry.

const PAINTER := "res://scripts/art/world_zone_visual.gd"


func run() -> void:
	await _water_geometry_and_three_lanes()
	await _terrain_and_progress()


func _water_geometry_and_three_lanes() -> void:
	reset_state()
	var room := Room.new()
	room.build_walls = false
	add_child(room)
	var script := load("res://scripts/world/water_zone.gd") as Script
	var zone := Area2D.new()
	zone.set_script(script)
	zone.set("size", Vector2(192, 96))
	zone.position = Vector2(400, 400)
	room.add_child(zone)
	var visual := zone.get_node("Visual") as Node2D
	var pond := visual.get_node("Pond") as Polygon2D
	check(pond.material is ShaderMaterial, "deep gate uses the painted pond shader")
	var material := pond.material as ShaderMaterial
	check_eq(material.get_shader_parameter("rect_count"), 1, "one exact gate footprint")
	var rects: PackedVector4Array = material.get_shader_parameter("rects")
	check_eq(rects[0], Vector4(-96, -48, 96, 48), "pond follows the 192 by 96 water gate")
	check_eq(pond.global_position, zone.global_position, "sorting preserves world-aligned water")
	check_eq(
		visual.find_children("*", "CollisionObject2D", true, false).size(),
		0,
		"the painter creates no collision objects"
	)
	var player := CharacterBody2D.new()
	player.collision_layer = Layers.PLAYER_BODY
	player.collision_mask = Layers.WATER
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = Player.BODY_RADIUS
	shape.shape = circle
	player.add_child(shape)
	room.add_child(player)
	await frames(2)
	for x in [336.0, 400.0, 464.0]:
		player.position = Vector2(x, 250)
		var hit := player.move_and_collide(Vector2(0, 300))
		check(hit != null, "water still blocks walking in lane %s" % x)
		check(player.position.y < 352.0, "player stops before water in lane %s" % x)
	# The shallow instance uses the same renderer but never adds a blocker.
	var shallow := Area2D.new()
	shallow.set_script(script)
	shallow.set("deep", false)
	shallow.set("size", Vector2(287, 113))
	room.add_child(shallow)
	check(shallow.get_node_or_null("Blocker") == null, "shallow presentation adds no blocker")
	check(shallow.get_node("Visual/Pond") is Polygon2D, "shallow water is also painted")
	room.queue_free()
	await frames(2)


func _terrain_and_progress() -> void:
	var script := load(PAINTER) as Script
	for kind in [&"pit", &"ravine", &"ledge"]:
		var host := Node2D.new()
		add_child(host)
		var visual: Node2D = script.attach(host, kind, Vector2(287, 113))
		check_eq(visual.get("footprint"), Vector2(287, 113), "arbitrary footprint stays exact")
		check_eq(host.get_child_count(), 1, "terrain adds just its Visual")
		check_eq(
			visual.find_children("*", "CollisionObject2D", true, false).size(),
			0,
			"terrain presentation has no physics"
		)
		host.queue_free()
	var pad := StaticBody2D.new()
	pad.set_script(load("res://scripts/world/ward_plate.gd"))
	pad.set("ward_id", &"presentation_test")
	add_child(pad)
	await frames(2)
	var progress := pad.get_node("Visual/WardProgress")
	check_eq(progress.get("_progress"), 0, "ward progress starts unlit")
	pad.set("blocks_absorbed", 1)
	await frames(2)
	check_eq(progress.get("_progress"), 1, "presentation reads ward progress")
	pad.call("satisfy")
	await frames(2)
	check_eq(progress.get("_progress"), pad.get("blocks_required"), "completion lights all markers")
	check_eq(pad.get("blocks_absorbed"), 1, "presentation does not write the ward counter")
	pad.queue_free()
	await frames(2)
