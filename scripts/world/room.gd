class_name Room
extends Node2D
## One 1920x960 room at its grid origin (grid * ROOM_SIZE). Built of placeholder nodes so WP7 can
## fill it by editing a .tscn: add children to the containers below.
##
## Containers (Node2D children, created if missing):
##   Enemies  placed enemy instances. Snapshotted at _ready and re-spawned on every room entry.
##   Bushes   placed Bush instances. Same respawn behaviour as enemies.
##   Props    everything permanent: SolidBlock, Brazier, Gate, LockedDoor, RoomDoor, placed
##            PickupBase (with persistent_id), explodable walls. Never respawned by the Room.
##   Spawns   Marker2D children: named entry points (see get_spawn_position).
##
## Walls: a 96 px ring of StaticBody2D rectangles (layer WORLD) around the room, with a 192 px gap
## centred on each edge listed in `exits` (&"n", &"e", &"s", &"w"). Plain StaticBody2D rectangles
## are used instead of TileMapLayer collision on purpose (Hollowtide pitfall: tile collision
## polygons are measured from the tile centre). Step 2 may switch to tiles; test the real collision.

@export var room_id: StringName = &""
@export var grid: Vector2i = Vector2i.ZERO
@export var exits: Array[StringName] = []
## Dark rooms are lit only by the lamp (World turns the CanvasModulate on).
@export var dark: bool = false
@export var floor_color: Color = Color(0.17, 0.21, 0.17)
@export var build_walls: bool = true

const RESPAWN_CONTAINERS: Array[StringName] = [&"Enemies", &"Bushes"]

var is_entered: bool = false
var _templates: Dictionary = {}  # container name -> Array[Node]
var _wall_body: StaticBody2D
# Kept as members: the canvas item references the meshes until the next redraw.
var _border: BorderEdge
var _vignette: ArrayMesh


func _ready() -> void:
	position = Vector2(grid) * WorldConst.ROOM_SIZE
	y_sort_enabled = true
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	for container_name in [&"Enemies", &"Bushes", &"Props", &"Spawns"]:
		_ensure_container(container_name)
	for container_name in RESPAWN_CONTAINERS:
		var container := get_node(String(container_name))
		var list: Array[Node] = []
		for child in container.get_children():
			container.remove_child(child)
			list.append(child)
		_templates[container_name] = list
	if build_walls:
		_build_walls()
	leave()


func _exit_tree() -> void:
	for list in _templates.values():
		for template in list:
			if is_instance_valid(template) and not template.is_inside_tree():
				template.free()
	_templates.clear()


func _draw() -> void:
	# Terrain textures are sampled by world position, so neighbouring rooms line up. floor_color
	# stays as a soft tint. Flat colours when a texture is missing.
	var floor_tex := SpriteVisual.texture_of(&"ground_cave" if dark else &"ground_grass")
	var floor_tint := floor_color.lerp(Color.WHITE, 0.55)
	var room_rect := Rect2(Vector2.ZERO, WorldConst.ROOM_SIZE)
	if not build_walls:
		if floor_tex != null:
			_draw_world_tiled(floor_tex, room_rect, floor_tint)
		else:
			draw_rect(room_rect, floor_color)
		return
	# The wall texture fills the whole room; the floor is then drawn over it inside a wavy edge
	# (BorderEdge), followed by contact shadow, vignette, dark band and lit lip. All of this is
	# visual only: collision still uses wall_rects().
	var wall_tex := SpriteVisual.texture_of(&"wall_cave" if dark else &"wall_hedge")
	if wall_tex != null:
		_draw_world_tiled(wall_tex, room_rect)
	else:
		draw_rect(room_rect, Placeholder.color_of(&"wall"))
	var edge := BorderEdge.new()
	_border = edge
	edge.build(
		WorldConst.ROOM_SIZE,
		WorldConst.WALL_THICKNESS,
		exits,
		_edge_seed(),
		dark,
		WorldConst.EXIT_WIDTH * 0.5
	)
	if floor_tex != null:
		_draw_world_polygon(floor_tex, edge.floor_polygon, floor_tint)
	else:
		draw_colored_polygon(edge.floor_polygon, floor_color)
	draw_mesh(edge.shadow_mesh, null)
	_vignette = BorderEdge.vignette_mesh(
		wall_rects(), WorldConst.ROOM_SIZE, 0.5 if dark else 0.4
	)
	draw_mesh(_vignette, null)
	draw_mesh(edge.ao_mesh, null)
	draw_mesh(edge.lip_mesh, null)


## Deterministic per room: the same border every frame and every visit.
func _edge_seed() -> int:
	if room_id != &"":
		return String(room_id).hash()
	return grid.x * 7919 + grid.y * 104729 + 17


## Fills `points` (room-local polygon) with `tex`, world-aligned like _draw_world_tiled.
func _draw_world_polygon(tex: Texture2D, points: PackedVector2Array, tint: Color) -> void:
	var tex_size := tex.get_size()
	var uvs := PackedVector2Array()
	var colors := PackedColorArray()
	for p in points:
		var world := global_position + p
		uvs.append(Vector2(world.x / tex_size.x, world.y / tex_size.y))
		colors.append(tint)
	draw_polygon(points, colors, uvs, tex)


## Fills `rect` (room-local) with `tex`, repeated. The texture phase comes from the world position,
## so the pattern continues across room and block borders. Needs texture_repeat (set in _ready).
func _draw_world_tiled(tex: Texture2D, rect: Rect2, tint := Color.WHITE) -> void:
	var tex_size := tex.get_size()
	var world := global_position + rect.position
	var src := Rect2(
		Vector2(fposmod(world.x, tex_size.x), fposmod(world.y, tex_size.y)), rect.size
	)
	draw_texture_rect_region(tex, rect, src, tint, false, false)


# ---- Geometry --------------------------------------------------------------------------------


## The room in global coordinates.
func get_rect() -> Rect2:
	return Rect2(global_position, WorldConst.ROOM_SIZE)


## The walkable interior in global coordinates (inside the wall ring).
func interior_rect() -> Rect2:
	return get_rect().grow(-WorldConst.WALL_THICKNESS)


## Wall rectangles in room-local coordinates.
func wall_rects() -> Array[Rect2]:
	var size := WorldConst.ROOM_SIZE
	var t := WorldConst.WALL_THICKNESS
	var half_gap := WorldConst.EXIT_WIDTH * 0.5
	var rects: Array[Rect2] = []
	rects.append_array(_edge(Vector2(0, 0), Vector2(size.x, t), true, &"n", half_gap))
	rects.append_array(_edge(Vector2(0, size.y - t), Vector2(size.x, t), true, &"s", half_gap))
	rects.append_array(_edge(Vector2(0, 0), Vector2(t, size.y), false, &"w", half_gap))
	rects.append_array(_edge(Vector2(size.x - t, 0), Vector2(t, size.y), false, &"e", half_gap))
	return rects


## Global position of a named entry point. "Default" falls back to the room centre.
func get_spawn_position(spawn_name: StringName = &"Default") -> Vector2:
	var marker := get_node_or_null("Spawns/%s" % spawn_name) as Node2D
	if marker != null:
		return marker.global_position
	return global_position + WorldConst.ROOM_SIZE * 0.5


func has_exit(side: StringName) -> bool:
	return exits.has(side)


# ---- Lifecycle -------------------------------------------------------------------------------


## Makes the room visible and (re)spawns enemies and bushes. Does not change process_mode.
func enter() -> void:
	is_entered = true
	visible = true
	_clear_respawn_containers()
	for container_name in RESPAWN_CONTAINERS:
		var container := get_node(String(container_name))
		for template in _templates.get(container_name, []):
			var node: Node = template.duplicate()
			if node is EnemyBase:
				(node as EnemyBase).room_rect = interior_rect()
			container.add_child(node)


## Removes live enemies and bushes and hides the room.
func leave() -> void:
	is_entered = false
	visible = false
	_clear_respawn_containers()


## Adds a node as a respawn template of `container_name` ("Enemies" or "Bushes"): it is
## duplicated into the room on every enter(). The room takes ownership of `node` (it must not be
## in the tree). Used by tests and by code that builds rooms at runtime.
func register_template(container_name: StringName, node: Node) -> void:
	if not _templates.has(container_name):
		_templates[container_name] = [] as Array[Node]
	_templates[container_name].append(node)


func get_enemies() -> Array[Node]:
	var result: Array[Node] = []
	for child in get_node("Enemies").get_children():
		if child is EnemyBase and not (child as EnemyBase).is_dead:
			result.append(child)
	return result


func _clear_respawn_containers() -> void:
	for container_name in RESPAWN_CONTAINERS:
		var container := get_node_or_null(String(container_name))
		if container == null:
			continue
		for child in container.get_children():
			container.remove_child(child)
			child.free()


func _ensure_container(container_name: StringName) -> void:
	if get_node_or_null(String(container_name)) == null:
		var node := Node2D.new()
		node.name = String(container_name)
		node.y_sort_enabled = true
		add_child(node)


func _edge(
	origin: Vector2, size: Vector2, horizontal: bool, side: StringName, half_gap: float
) -> Array[Rect2]:
	if not exits.has(side):
		return [Rect2(origin, size)]
	var result: Array[Rect2] = []
	if horizontal:
		var mid := WorldConst.ROOM_SIZE.x * 0.5
		result.append(Rect2(origin, Vector2(mid - half_gap, size.y)))
		result.append(Rect2(Vector2(mid + half_gap, origin.y), Vector2(mid - half_gap, size.y)))
	else:
		var mid := WorldConst.ROOM_SIZE.y * 0.5
		result.append(Rect2(origin, Vector2(size.x, mid - half_gap)))
		result.append(Rect2(Vector2(origin.x, mid + half_gap), Vector2(size.x, mid - half_gap)))
	return result


func _build_walls() -> void:
	_wall_body = StaticBody2D.new()
	_wall_body.name = "Walls"
	_wall_body.collision_layer = Layers.WORLD
	_wall_body.collision_mask = 0
	add_child(_wall_body)
	for r in wall_rects():
		var shape := RectangleShape2D.new()
		shape.size = r.size
		var node := CollisionShape2D.new()
		node.shape = shape
		node.position = r.position + r.size * 0.5
		_wall_body.add_child(node)
	queue_redraw()
