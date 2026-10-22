extends Node2D
## The lamp hook's sweep: presentation only. It covers exactly the player's hit arc
## (Player.SWING_ARC_DEG centred on the facing, reach Player.SWING_REACH). The hook head is traced
## from one end of the arc to the other over Player.SWING_ACTIVE seconds. A soft warm trail fills
## the swept part behind it and fades out over the rest of Player.SWING_TOTAL.
## player.gd sets the facing, then shows it at the swing start and hides it at the end of the hit
## window. Game logic never reads from it. Nothing is drawn outside the sector.

const AMBER := Color("#f3b25c")
const CORE := Color("#ffd98a")
const BRASS := Color("#c99a3c")
const BRASS_BRIGHT := Color("#fff1c2")
const BANDS := 4
const BAND_ALPHA := 0.16
const STEPS := 12
const INNER_FROM := 0.45
const INNER_TO := 0.85
const HEAD_RADIUS := 6.0
const HEAD_ALPHA := 0.9

var _angle: float = Vector2.DOWN.angle()
var _elapsed: float = Player.SWING_TOTAL


func _ready() -> void:
	# Additive blend: the bands add light to the ground instead of covering it.
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = mat
	visibility_changed.connect(_on_visibility_changed)


## Points the arc at `dir` (the swing facing) and starts a new sweep.
func set_facing(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		return
	_angle = dir.angle()
	_restart()


## Start angle, end angle (radians) and radius of the drawn sector.
func get_sector() -> Vector3:
	var half := deg_to_rad(Player.SWING_ARC_DEG) * 0.5
	return Vector3(_angle - half, _angle + half, Player.SWING_REACH)


func _on_visibility_changed() -> void:
	if visible:
		_restart()


func _restart() -> void:
	_elapsed = 0.0
	queue_redraw()


func _process(delta: float) -> void:
	if not visible or _elapsed >= Player.SWING_TOTAL:
		return
	_elapsed = minf(_elapsed + delta, Player.SWING_TOTAL)
	queue_redraw()
	# The trail hides itself after the fade, so the next swing's `visible = true` restarts it.
	if _elapsed >= Player.SWING_TOTAL:
		visible = false


func _draw() -> void:
	if not visible or _elapsed >= Player.SWING_TOTAL:
		return
	var half := deg_to_rad(Player.SWING_ARC_DEG) * 0.5
	var reach := Player.SWING_REACH
	var start := _angle - half
	var end := _angle + half
	var past_active := (_elapsed - Player.SWING_ACTIVE) / (Player.SWING_TOTAL - Player.SWING_ACTIVE)
	var fade := 1.0 - clampf(past_active, 0.0, 1.0)
	# The head disc sits inside the reach circle, so its centre is kept one disc-angle inside the
	# sector ends. That keeps the whole head within the 110 degree sector.
	var head_radius := reach - HEAD_RADIUS
	var margin := asin(HEAD_RADIUS / head_radius)
	var sweep := clampf(_elapsed / Player.SWING_ACTIVE, 0.0, 1.0)
	var head := lerpf(start + margin, end - margin, sweep)
	for band in range(BANDS):
		var t := float(band) / float(BANDS - 1)
		var inner := reach * lerpf(INNER_FROM, INNER_TO, t)
		var colour := CORE.lerp(AMBER, t)
		_draw_band(start, head, inner, reach, colour, fade)
	_draw_head(head, head_radius, fade)


## One overlapping band of the trail, from the tail (start) to the head. Vertex alpha rises from
## the tail, so the trail is soft at its end and has no outline.
func _draw_band(
	start: float, head: float, inner: float, outer: float, colour: Color, fade: float
) -> void:
	var points := PackedVector2Array()
	var colours := PackedColorArray()
	for j in range(STEPS + 1):
		var s := float(j) / float(STEPS)
		points.append(Vector2.from_angle(lerpf(start, head, s)) * outer)
		colours.append(with_alpha(colour, BAND_ALPHA * fade * _soft(s)))
	for j in range(STEPS, -1, -1):
		var s := float(j) / float(STEPS)
		points.append(Vector2.from_angle(lerpf(start, head, s)) * inner)
		colours.append(with_alpha(colour, BAND_ALPHA * fade * _soft(s)))
	draw_polygon(points, colours)


## The brass hook head: a soft disc with a short curl, centred at radius `head_radius`.
func _draw_head(head: float, head_radius: float, fade: float) -> void:
	var centre := Vector2.from_angle(head) * head_radius
	var alpha := HEAD_ALPHA * fade
	draw_circle(centre, HEAD_RADIUS, with_alpha(BRASS, alpha))
	draw_circle(centre, HEAD_RADIUS * 0.5, with_alpha(BRASS_BRIGHT, alpha))
	var curl := with_alpha(BRASS_BRIGHT, alpha)
	draw_arc(centre, HEAD_RADIUS * 0.6, head - PI * 0.5, head + PI * 0.5, 8, curl, 1.4, true)


## Smoothstep from the tail (0) to the head (1).
static func _soft(s: float) -> float:
	return s * s * (3.0 - 2.0 * s)


static func with_alpha(colour: Color, alpha: float) -> Color:
	return Color(colour.r, colour.g, colour.b, alpha)
