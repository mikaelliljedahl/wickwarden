extends TestCase
## Terrain blocks (SolidBlock water and wall): the outline of a group, group membership, and the
## painter nodes. The collision stays the plain rectangle of each block.


func run() -> void:
	_outline()
	await _groups_and_painters()


func _outline() -> void:
	var single := SolidBlock.outline_of([Rect2(0, 0, 96, 96)] as Array[Rect2])
	check_eq(single.size(), 4, "one rectangle has four edges")
	var pair := SolidBlock.outline_of([Rect2(0, 0, 96, 96), Rect2(96, 0, 96, 96)] as Array[Rect2])
	check_eq(pair.size(), 4, "two rectangles side by side merge into one outline of four edges")
	check(not pair.has(Vector4(96, 0, 96, 96)), "the shared edge is not part of the outline")
	# An L: 96 x 288 column with a 96 x 96 block to the right of its foot.
	var ell := SolidBlock.outline_of([Rect2(0, 0, 96, 288), Rect2(96, 192, 96, 96)] as Array[Rect2])
	check_eq(ell.size(), 6, "an L has six edges")
	var length := 0.0
	for s in ell:
		length += Vector2(s.x, s.y).distance_to(Vector2(s.z, s.w))
	check_near(length, 2.0 * (192 + 288), 0.01, "the L outline has the length of its perimeter")


func _block(parent: Node, kind: StringName, at: Vector2, size: Vector2) -> SolidBlock:
	var block := SolidBlock.new()
	block.kind = kind
	block.size = size
	block.position = at
	parent.add_child(block)
	return block


func _groups_and_painters() -> void:
	var arena := make_arena()
	var props := Node2D.new()
	props.y_sort_enabled = true
	arena.add_child(props)
	var water_a := _block(props, &"water", Vector2(624, 432), Vector2(480, 288))
	var water_b := _block(props, &"water", Vector2(336, 480), Vector2(96, 192))
	var lone := _block(props, &"water", Vector2(1200, 480), Vector2(96, 96))
	var wall_a := _block(props, &"wall", Vector2(1488, 240), Vector2(96, 288))
	var wall_b := _block(props, &"wall", Vector2(1584, 336), Vector2(96, 96))
	var corner := _block(props, &"wall", Vector2(1680, 432), Vector2(96, 96))
	await frames(1)

	check_eq(water_a.terrain_group(), [water_a, water_b] as Array[SolidBlock], "touching water blocks form one group")
	check_eq(lone.terrain_group(), [lone] as Array[SolidBlock], "a separate pond is its own group")
	check_eq(wall_b.terrain_group(), [wall_a, wall_b] as Array[SolidBlock], "walls touching along an edge group")
	check_eq(corner.terrain_group(), [corner] as Array[SolidBlock], "a corner-only contact does not group")

	var pond := water_a.get_node_or_null(SolidBlock.TERRAIN_NAME) as Polygon2D
	check(pond != null and pond.material is ShaderMaterial, "the first block of a pond paints it")
	check(water_b.get_node_or_null(SolidBlock.TERRAIN_NAME) == null, "other blocks of the pond paint nothing")
	if pond != null:
		check(pond.global_position.y < water_a.global_position.y, "the pond sorts under the actors in the room")
	var face := wall_a.get_node_or_null(SolidBlock.TERRAIN_NAME) as Node2D
	check(face != null and wall_b.get_node_or_null(SolidBlock.TERRAIN_NAME) != null, "every wall block paints")
	if face != null:
		check_near(face.global_position.y, 384.0, 0.01, "a wall sorts on the south edge of its footprint")

	for block in [water_a, water_b, lone, wall_a, wall_b, corner]:
		var shapes := (block as Node).find_children("*", "CollisionShape2D", false, false)
		check_eq(shapes.size(), 1, "one collision shape per block")
		var rect := (shapes[0] as CollisionShape2D).shape as RectangleShape2D
		check_eq(rect.size, (block as SolidBlock).size, "the collision is the block rectangle")
		check_eq((shapes[0] as CollisionShape2D).position, Vector2.ZERO, "the collision is centred")
	await dispose(arena)
