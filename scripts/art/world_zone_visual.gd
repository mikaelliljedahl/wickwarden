extends Node2D
## Rendering only for rectangular terrain zones. Never creates physics bodies or changes gameplay state.

var footprint := Vector2.ZERO
var surface: StringName = &""
var _texture: Texture2D
var _ward_host: Node
var _progress := -1


static func attach(host: Node2D, kind: StringName, size: Vector2) -> Node2D:
	var visual := _new_visual()
	if visual == null:
		return null
	visual.name = "Visual"
	visual.set("footprint", size)
	visual.set("surface", kind)
	host.add_child(visual)
	return visual


static func ward_progress(host: Node2D, visual: Node2D) -> void:
	var progress := _new_visual()
	if progress == null:
		return
	progress.name = "WardProgress"
	progress.set("_ward_host", host)
	visual.add_child(progress)


static func _new_visual() -> Node2D:
	var script := load("res://scripts/art/world_zone_visual.gd") as Script
	if script == null:
		return null
	var node := Node2D.new()
	node.set_script(script)
	return node


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	if _ward_host != null:
		return
	set_process(false)
	if surface in [&"deep_water", &"shallow_water"]:
		_paint_water()
	elif surface in [&"pit", &"ravine"]:
		_texture = SpriteVisual.texture_of(&"pit_fill")
		if _texture == null:
			_texture = SpriteVisual.texture_of(&"ground_cave")
	else:
		_texture = SpriteVisual.texture_of(&"ledge_drop")
		if _texture == null:
			_texture = SpriteVisual.texture_of(&"wall_ruin_face")


func _process(_delta: float) -> void:
	if not is_instance_valid(_ward_host):
		return
	var progress := int(_ward_host.get("blocks_absorbed"))
	if bool(_ward_host.get("is_satisfied")):
		progress = int(_ward_host.get("blocks_required"))
	if progress != _progress:
		_progress = progress
		var visual := get_parent() as SpriteVisual
		if visual != null and bool(_ward_host.get("is_satisfied")):
			if visual.sprite_frames.has_animation(&"lit"):
				visual.play_anim(&"lit")
		queue_redraw()


func _paint_water() -> void:
	var shader := load("res://assets/shaders/pond.gdshader") as Shader
	var water := SpriteVisual.texture_of(&"water")
	var bank := SpriteVisual.texture_of(&"pond_bank")
	if shader == null or water == null or bank == null:
		return
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("water_tex", water)
	mat.set_shader_parameter("bank_tex", bank)
	var rect := Rect2(-footprint * 0.5, footprint)
	var rects: Array[Rect2] = [rect]
	var rectangle := PackedVector4Array(
		[Vector4(rect.position.x, rect.position.y, rect.end.x, rect.end.y)]
	)
	rectangle.resize(SolidBlock.MAX_RECTS)
	var segments := PackedVector4Array(SolidBlock.outline_of(rects))
	var segment_count := segments.size()
	segments.resize(SolidBlock.MAX_SEGS)
	mat.set_shader_parameter("rects", rectangle)
	mat.set_shader_parameter("rect_count", 1)
	mat.set_shader_parameter("segs", segments)
	mat.set_shader_parameter("seg_count", segment_count)
	if surface == &"shallow_water":
		mat.set_shader_parameter("face_height", 3.0)
		mat.set_shader_parameter("bank_width", 24.0)
	var painter := Polygon2D.new()
	painter.name = "Pond"
	painter.material = mat
	var bounds := rect.grow(SolidBlock.BANK_REACH)
	painter.polygon = PackedVector2Array(
		[
			bounds.position,
			Vector2(bounds.end.x, bounds.position.y),
			bounds.end,
			Vector2(bounds.position.x, bounds.end.y)
		]
	)
	if surface == &"shallow_water":
		painter.modulate = Color(1.14, 1.12, 0.94)
	add_child(painter)
	# Sort the entire ground painter below props, just as SolidBlock's pond does.
	var room_y := 0.0
	var node := get_parent()
	while node != null and not node is Room:
		if node is Node2D:
			room_y += (node as Node2D).position.y
		node = node.get_parent()
	get_parent().y_sort_enabled = true
	position.y = 1.0 - room_y
	painter.position.y = -position.y


func _draw() -> void:
	if is_instance_valid(_ward_host):
		_draw_progress()
		return
	if surface in [&"deep_water", &"shallow_water"]:
		return
	var rect := Rect2(-footprint * 0.5, footprint)
	if surface in [&"pit", &"ravine"]:
		var rim := _pit_outline(rect.grow(10.0), 5.0)
		var hole := _pit_outline(rect, 3.0)
		var rock := SpriteVisual.texture_of(&"ground_cave")
		_draw_textured_polygon(rock, rim, Color(0.48, 0.44, 0.4))
		var tint := Color.WHITE
		if SpriteVisual.texture_of(&"pit_fill") == null:
			tint = Color(0.12, 0.12, 0.16)
		_draw_textured_polygon(_texture, hole, tint)
		hole.append(hole[0])
		draw_polyline(hole, Color(0.015, 0.015, 0.025, 0.85), 5.0, true)
	elif _texture != null:
		# Tile the straight lip without stretching it across the arbitrary zone width.
		var cell := _texture.get_size()
		var x := rect.position.x
		while x < rect.end.x:
			var width := minf(cell.x, rect.end.x - x)
			var height := minf(cell.y, maxf(footprint.y, 96.0))
			var target := Rect2(Vector2(x, rect.end.y - height), Vector2(width, height))
			draw_texture_rect_region(_texture, target, Rect2(Vector2.ZERO, target.size))
			x += width


func _draw_progress() -> void:
	var count := int(_ward_host.get("blocks_required"))
	for i in range(count):
		var angle := TAU * float(i) / float(count) - PI * 0.5
		var point := Vector2(cos(angle), sin(angle)) * 46.0
		draw_circle(point, 6.0, Color(0.12, 0.13, 0.16, 0.9))
		if i < _progress:
			draw_circle(point, 4.0, Color(1.0, 0.76, 0.3))


func _pit_outline(rect: Rect2, roughness: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var corners := [
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y)
	]
	for side in range(4):
		var start: Vector2 = corners[side]
		var end: Vector2 = corners[(side + 1) % 4]
		var outward := (end - start).normalized().orthogonal()
		var steps := maxi(1, ceili(start.distance_to(end) / 22.0))
		for i in range(steps):
			var point := start.lerp(end, float(i) / float(steps))
			if i > 0:
				point += outward * (0.5 + 0.5 * sin(point.x * 0.73 + point.y * 0.37)) * roughness
			points.append(point)
	return points


func _draw_textured_polygon(tex: Texture2D, points: PackedVector2Array, tint: Color) -> void:
	if tex == null:
		return
	var uvs := PackedVector2Array()
	for point in points:
		uvs.append(point / tex.get_size())
	draw_polygon(points, PackedColorArray([tint]), uvs, tex)
