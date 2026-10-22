class_name SolidBlock
extends StaticBody2D
## A solid rectangle on the WORLD layer (rock, pillar, water, interior wall). Centred on its
## origin. Place instances in a room's `Props` container and set `size` (multiples of 96) and
## `kind` (a Placeholder kind: rock, wall, water, pedestal, ...).
##
## Water and wall blocks are painted by a terrain shader. Touching blocks of the same kind in the
## same container form one group, and the shader paints the outline of their union: a pond with
## soft mud banks, or a ruined wall with a front face and broken top edges. The collision is
## always the plain rectangle.

@export var size: Vector2 = Vector2(96, 96)
@export var kind: StringName = &"rock"

## Kinds painted by a terrain shader: the shader and its texture parameters (terrain textures).
const TERRAIN := {
	&"water":
	{
		"shader": "res://assets/shaders/pond.gdshader",
		"textures": {"water_tex": &"water", "bank_tex": &"pond_bank"},
	},
	&"wall":
	{
		"shader": "res://assets/shaders/ruin_wall.gdshader",
		"textures": {"top_tex": &"wall_ruin", "face_tex": &"wall_ruin_face"},
	},
}
const TERRAIN_NAME := "Terrain"
## How far the pond bank reaches past the water rectangles (plus the shore wobble).
const BANK_REACH := 64.0
## How high the wall top sits above its footprint on screen (the height of the front face).
const WALL_HEIGHT := 48.0
## Array sizes of the shaders (MAX_RECTS, MAX_SEGS).
const MAX_RECTS := 16
const MAX_SEGS := 48


func _init() -> void:
	collision_layer = Layers.WORLD
	collision_mask = 0


func _ready() -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	var node := CollisionShape2D.new()
	node.shape = shape
	add_child(node)
	if not TERRAIN.has(kind):
		SpriteVisual.attach(self, kind, 0.0, size)
	elif not _attach_terrain():
		Placeholder.attach(self, kind, 0.0, size)


## The rectangle in the parent's space.
func rect() -> Rect2:
	return Rect2(position - size * 0.5, size)


## Every block of the same kind in the same container that touches this one, directly or through
## other blocks (along an edge, not only at a corner). Includes this block; ordered as in the tree.
func terrain_group() -> Array[SolidBlock]:
	var candidates: Array[SolidBlock] = []
	if get_parent() != null:
		for child in get_parent().get_children():
			if child is SolidBlock and (child as SolidBlock).kind == kind:
				candidates.append(child)
	else:
		candidates.append(self)
	var member := {self: true}
	var queue: Array[SolidBlock] = [self]
	while not queue.is_empty():
		var block: SolidBlock = queue.pop_back()
		for other in candidates:
			if not member.has(other) and _touch(block.rect(), other.rect()):
				member[other] = true
				queue.append(other)
	var group: Array[SolidBlock] = []
	for block in candidates:
		if member.has(block):
			group.append(block)
	return group


## The outline of the union of `rects`: axis-aligned segments as Vector4(x0, y0, x1, y1). Edges
## shared by two rectangles are not part of it, and collinear pieces are merged.
static func outline_of(rects: Array[Rect2]) -> Array[Vector4]:
	var xs := _cuts(rects, true)
	var ys := _cuts(rects, false)
	# occupancy of the cells between neighbouring cuts
	var occ: Array = []
	for i in range(xs.size() - 1):
		var column: Array[bool] = []
		for j in range(ys.size() - 1):
			var centre := Vector2(xs[i] + xs[i + 1], ys[j] + ys[j + 1]) * 0.5
			column.append(rects.any(func(r: Rect2) -> bool: return r.has_point(centre)))
		occ.append(column)
	var segs: Array[Vector4] = []
	for j in range(ys.size()):
		var start := -1
		for i in range(xs.size()):
			var edge := i < xs.size() - 1 and _occ(occ, i, j - 1) != _occ(occ, i, j)
			if edge and start < 0:
				start = i
			elif not edge and start >= 0:
				segs.append(Vector4(xs[start], ys[j], xs[i], ys[j]))
				start = -1
	for i in range(xs.size()):
		var start := -1
		for j in range(ys.size()):
			var edge := j < ys.size() - 1 and _occ(occ, i - 1, j) != _occ(occ, i, j)
			if edge and start < 0:
				start = j
			elif not edge and start >= 0:
				segs.append(Vector4(xs[i], ys[start], xs[i], ys[j]))
				start = -1
	return segs


# ---- Terrain painting --------------------------------------------------------------------------


func _attach_terrain() -> bool:
	var spec: Dictionary = TERRAIN[kind]
	var shader := load(spec["shader"]) as Shader
	if shader == null:
		return false
	var mat := ShaderMaterial.new()
	mat.shader = shader
	var textures: Dictionary = spec["textures"]
	for param in textures:
		var tex := SpriteVisual.texture_of(textures[param])
		if tex == null:
			return false
		mat.set_shader_parameter(param, tex)
	var group := terrain_group()
	if kind == &"water" and group[0] != self:
		return true  # the first block of a pond paints all of it
	var painter := Polygon2D.new()
	painter.name = TERRAIN_NAME
	painter.material = mat
	# Children of this block y-sort on their own (y_sort), so the painter picks its sort line:
	# a pond lies flat under everything in the room, a wall sorts on its south edge.
	y_sort_enabled = true
	if kind == &"water":
		painter.position = Vector2(0.0, 1.0 - _room_local_y())
	else:
		painter.position = Vector2(0.0, size.y * 0.5)
	var rects: Array[Rect2] = []
	var bounds := Rect2()
	for block in group:
		var r := Rect2(block.position - position - block.size * 0.5 - painter.position, block.size)
		rects.append(r)
		bounds = r if rects.size() == 1 else bounds.merge(r)
	var own := Rect2(-size * 0.5 - painter.position, size)
	if kind == &"water":
		bounds = bounds.grow(BANK_REACH)
	else:
		var lift := Vector2(4.0, WALL_HEIGHT + 4.0)
		bounds = Rect2(own.position - lift, own.size + lift + Vector2(16.0, 14.0))
		mat.set_shader_parameter("own_rect", _vec4(own))
		mat.set_shader_parameter("height", WALL_HEIGHT)
	_set_geometry(mat, rects)
	var corners := [bounds.position, Vector2(bounds.end.x, bounds.position.y), bounds.end]
	corners.append(Vector2(bounds.position.x, bounds.end.y))
	painter.polygon = PackedVector2Array(corners)
	add_child(painter)
	return true


func _set_geometry(mat: ShaderMaterial, rects: Array[Rect2]) -> void:
	var segs := outline_of(rects)
	if rects.size() > MAX_RECTS or segs.size() > MAX_SEGS:
		push_warning("SolidBlock %s: terrain group too large for the shader" % name)
	var rect_data := PackedVector4Array()
	rect_data.resize(MAX_RECTS)
	for i in range(mini(rects.size(), MAX_RECTS)):
		rect_data[i] = _vec4(rects[i])
	var seg_data := PackedVector4Array()
	seg_data.resize(MAX_SEGS)
	for i in range(mini(segs.size(), MAX_SEGS)):
		seg_data[i] = segs[i]
	mat.set_shader_parameter("rects", rect_data)
	mat.set_shader_parameter("rect_count", mini(rects.size(), MAX_RECTS))
	mat.set_shader_parameter("segs", seg_data)
	mat.set_shader_parameter("seg_count", mini(segs.size(), MAX_SEGS))


## This block's y in the space of its Room (the room moves to its grid position later).
func _room_local_y() -> float:
	var y := position.y
	var node := get_parent()
	while node != null and not node is Room:
		if node is Node2D:
			y += (node as Node2D).position.y
		node = node.get_parent()
	return y


static func _vec4(r: Rect2) -> Vector4:
	return Vector4(r.position.x, r.position.y, r.end.x, r.end.y)


static func _touch(a: Rect2, b: Rect2) -> bool:
	var ga := a.grow(0.5)
	var gb := b.grow(0.5)
	if not ga.intersects(gb):
		return false
	var overlap := ga.intersection(gb)
	return maxf(overlap.size.x, overlap.size.y) > 1.5


## Sorted unique x (or y) coordinates of the rectangle edges.
static func _cuts(rects: Array[Rect2], horizontal: bool) -> Array[float]:
	var cuts: Array[float] = []
	for r in rects:
		for v in ([r.position.x, r.end.x] if horizontal else [r.position.y, r.end.y]):
			if not cuts.has(v):
				cuts.append(v)
	cuts.sort()
	return cuts


static func _occ(occ: Array, i: int, j: int) -> bool:
	if i < 0 or i >= occ.size():
		return false
	var column: Array[bool] = occ[i]
	return j >= 0 and j < column.size() and column[j]
