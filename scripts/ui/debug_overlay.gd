class_name DebugOverlay
extends Node2D
## Dev aid: draws the shapes of every ACTIVE Hitbox (red) and every Hurtbox (green when it can take a
## hit, dim when disabled or invulnerable) in world space. The World toggles it
## with F1 in dev mode (`-- --dev-mode`). It only draws; nothing reads from it.

const HITBOX_ACTIVE := Color(1.0, 0.2, 0.2)
const HURTBOX_LIVE := Color(0.2, 1.0, 0.4)
const HURTBOX_IDLE := Color(0.3, 0.5, 0.4)


func _ready() -> void:
	z_index = 4000
	z_as_relative = false
	visible = false


func _physics_process(_delta: float) -> void:
	if visible:
		queue_redraw()


func _draw() -> void:
	for node in get_tree().get_nodes_in_group(&"hurtboxes"):
		var hurtbox := node as Hurtbox
		if hurtbox != null and hurtbox.is_visible_in_tree():
			var live := hurtbox.enabled and not hurtbox.invulnerable
			_draw_area(hurtbox, HURTBOX_LIVE if live else HURTBOX_IDLE)
	for node in get_tree().get_nodes_in_group(&"hitboxes"):
		var hitbox := node as Hitbox
		if hitbox != null and hitbox.active and hitbox.is_visible_in_tree():
			_draw_area(hitbox, HITBOX_ACTIVE)


func _draw_area(area: Area2D, color: Color) -> void:
	for child in area.get_children():
		if child is CollisionShape2D:
			var shape_node := child as CollisionShape2D
			if shape_node.shape != null and not shape_node.disabled:
				draw_set_transform_matrix(shape_node.global_transform)
				_draw_shape(shape_node.shape, color)
		elif child is CollisionPolygon2D:
			var poly := child as CollisionPolygon2D
			if poly.polygon.size() >= 3:
				draw_set_transform_matrix(poly.global_transform)
				var closed := poly.polygon.duplicate()
				closed.append(poly.polygon[0])
				draw_colored_polygon(poly.polygon, Color(color, 0.18))
				draw_polyline(closed, color, 3.0)
	draw_set_transform_matrix(Transform2D.IDENTITY)


func _draw_shape(shape: Shape2D, color: Color) -> void:
	if shape is CircleShape2D:
		var radius := (shape as CircleShape2D).radius
		draw_circle(Vector2.ZERO, radius, Color(color, 0.18))
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, color, 3.0)
	elif shape is RectangleShape2D:
		var rect := Rect2(-(shape as RectangleShape2D).size * 0.5, (shape as RectangleShape2D).size)
		draw_rect(rect, Color(color, 0.18))
		draw_rect(rect, color, false, 3.0)
