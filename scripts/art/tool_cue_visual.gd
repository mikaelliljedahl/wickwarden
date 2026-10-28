extends Node2D
## Held tool cues only. Reads the registered presentation definition, never gameplay state.
## The item retains control of visibility and lifetime. No body, icon, shadow or collision.

const SEGMENTS := 48
const BANDS := 8
const CINDER_ART := "res://assets/sprites/fx_cinder_cast_z1.png"
const CINDER_WIDTH := 82.0
const DUST_ART := "res://assets/sprites/fx_leap_dust_z1_idle.png"
const SLING_WIDTH := 64.0
## Soften the existing painted strokes into a neutral air trail; no moving projectile is drawn.
const SLING_SHADER := """
shader_type canvas_item;
render_mode unshaded;
void fragment() {
	float alpha = 0.0;
	for (int x = -2; x <= 2; x++) {
		for (int y = -2; y <= 2; y++) {
			alpha += texture(TEXTURE, UV + vec2(float(x), float(y)) * TEXTURE_PIXEL_SIZE * 6.0).a;
		}
	}
	COLOR = vec4(vec3(0.78, 0.76, 0.71), alpha * 0.65 / 25.0);
}
"""

var art_path: String = CINDER_ART
var dust_path: String = DUST_ART
var sling_art_path: String = CINDER_ART
var _kind: StringName
var _painted: Sprite2D
var _shape: String = "arc"
var _radius: float = 28.0
var _colour: Color = Color.WHITE
var _facing: Vector2 = Vector2.DOWN
var _elapsed: float = 0.0


static func attach(parent: Node, kind: StringName, facing: Vector2) -> Node2D:
	var script := load("res://scripts/art/tool_cue_visual.gd") as GDScript
	if script == null:
		return null
	var visual := script.new() as Node2D
	var definition := Placeholder.definition_of(kind)
	visual.name = Placeholder.VISUAL_NAME
	visual.set(&"_kind", kind)
	visual.set(&"_shape", String(definition.get("shape", "arc")))
	visual.set(&"_radius", float(definition.get("radius", 28.0)))
	visual.set(&"_colour", definition.get("color", Color.WHITE))
	visual.call(&"set_facing", facing)
	var old := parent.get_node_or_null(Placeholder.VISUAL_NAME)
	if old != null:
		parent.remove_child(old)
		old.free()
	parent.add_child(visual)
	return visual


func _ready() -> void:
	var blend := CanvasItemMaterial.new()
	blend.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	if _kind != &"skitter_boots":
		material = blend
	if _kind == &"tallow_sling" and ResourceLoader.exists(sling_art_path):
		var texture := load(sling_art_path) as Texture2D
		if texture != null and texture.get_width() > 0:
			_painted = Sprite2D.new()
			_painted.name = "SlingCast"
			_painted.texture = texture
			_painted.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			_painted.scale = Vector2.ONE * SLING_WIDTH / float(texture.get_width())
			var shader := Shader.new()
			shader.code = SLING_SHADER
			var paint := ShaderMaterial.new()
			paint.shader = shader
			_painted.material = paint
			add_child(_painted)
			_place_painted()
	if _kind == &"cinder_wick" and ResourceLoader.exists(art_path):
		var texture := load(art_path) as Texture2D
		if texture != null and texture.get_width() > 0:
			_painted = Sprite2D.new()
			_painted.name = "CinderCast"
			_painted.texture = texture
			_painted.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			_painted.scale = Vector2.ONE * CINDER_WIDTH / float(texture.get_width())
			add_child(_painted)
			_place_painted()


func set_facing(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		_facing = direction.normalized()
	_place_painted()
	queue_redraw()


func _place_painted() -> void:
	if _painted == null:
		return
	var hand := Vector2(38.0 if _facing == Vector2.UP else -38.0, -88.0)
	if _facing.x != 0.0:
		hand = Vector2(42.0 * signf(_facing.x), -88.0)
	_painted.position = hand + _facing * (40.0 if _kind == &"tallow_sling" else 25.0)
	_painted.rotation = _facing.angle()


func _process(delta: float) -> void:
	if not visible:
		return
	_elapsed += delta
	queue_redraw()


func _draw() -> void:
	if _kind == &"skitter_boots" or _painted != null:
		return
	# Nested bands feather both radial edges; vertex alpha feathers the arc ends.
	var span := deg_to_rad(110.0) if _shape == "arc" else TAU
	var start := _facing.angle() - span * 0.5
	var breath := 0.9 + 0.1 * sin(_elapsed * 5.0)
	for band in range(BANDS):
		var t := float(band) / float(BANDS)
		var inner := _radius * lerpf(0.62, 0.79, t)
		var outer := _radius * lerpf(1.0, 0.83, t)
		for segment in range(SEGMENTS):
			var u := float(segment) / SEGMENTS
			var v := float(segment + 1) / SEGMENTS
			var a := start + span * u
			var b := start + span * v
			var edge_a := sin(PI * u) if _shape == "arc" else 1.0
			var edge_b := sin(PI * v) if _shape == "arc" else 1.0
			var alpha := _colour.a * 0.055 * breath
			var ca := Color(_colour, alpha * edge_a)
			var cb := Color(_colour, alpha * edge_b)
			draw_polygon(
				PackedVector2Array(
					[_point(a, outer), _point(b, outer), _point(b, inner), _point(a, inner)]
				),
				PackedColorArray([ca, cb, cb, ca])
			)


func _point(angle: float, reach: float) -> Vector2:
	var direction := Vector2.from_angle(angle)
	if _shape == "diamond":
		direction /= absf(direction.x) + absf(direction.y)
	return direction * reach


func show_leap_dust(at: Vector2) -> void:
	if _kind != &"skitter_boots" or not ResourceLoader.exists(dust_path):
		return
	var texture := load(dust_path) as Texture2D
	if texture == null:
		return
	var puff := Sprite2D.new()
	puff.name = "LeapDust"
	puff.texture = texture
	puff.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	puff.modulate.a = 0.72
	puff.top_level = true
	add_child(puff)
	puff.global_position = at + Vector2(0, 8)
	var tween := create_tween()
	tween.tween_property(puff, "modulate:a", 0.0, 0.3)
	tween.tween_callback(puff.queue_free)
