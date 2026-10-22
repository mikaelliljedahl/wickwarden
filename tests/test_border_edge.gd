extends TestCase
## Room border edge: deterministic per seed, bounded offsets, meshes built,
## openings keep the floor polygon open to the room border.


func run() -> void:
	var size := WorldConst.ROOM_SIZE
	var t := WorldConst.WALL_THICKNESS
	var a := BorderEdge.new()
	var b := BorderEdge.new()
	a.build(size, t, [&"s", &"e"], 1234, false)
	b.build(size, t, [&"s", &"e"], 1234, false)
	check(a.floor_polygon == b.floor_polygon, "same seed gives the same edge")
	var c := BorderEdge.new()
	c.build(size, t, [&"s", &"e"], 99, false)
	check(a.floor_polygon != c.floor_polygon, "a different seed gives a different edge")
	var reaches_border := false
	for p in a.floor_polygon:
		if p.y > size.y - 0.5 or p.x > size.x - 0.5:
			reaches_border = true
	check(BorderEdge.EDGE_MAX <= 12.0, "edge reaches at most 12 px over the floor")
	check(reaches_border, "openings leave the floor polygon open to the room border")
	check(a.shadow_mesh.get_surface_count() >= 2, "shadow strips exist on both sides of openings")
	check(a.lip_mesh.get_surface_count() >= 1, "lip mesh exists")
	for d in [true, false]:
		var e := BorderEdge.new()
		e.build(size, t, [], 5, d)
		check(e.shadow_mesh.get_surface_count() == 1, "closed ring is one shadow strip")
		for i in 200:
			var o := e.edge_offset(float(i) * 37.0)
			check(o >= BorderEdge.EDGE_MIN - 0.01 and o <= BorderEdge.EDGE_MAX + 0.01, "offset bounds")
	await get_tree().process_frame
