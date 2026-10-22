extends Node2D
## The charge flare's ring: presentation only. A soft warm ring of light exactly at radius
## Player.FLARE_REACH. When it becomes visible, one sweep runs a full 360 degrees round Tamsin over
## Player.FLARE_ACTIVE seconds. The swept part glows, then the whole ring fades over the rest of
## Player.FLARE_TOTAL and the node hides itself. Painterly bands in the style of swing_trail.gd:
## overlapping low-alpha bands, no outline. Game logic never reads from it.

const AMBER := Color("#f3b25c")
const CORE := Color("#ffd98a")
const BANDS := 4
const BAND_ALPHA := 0.2
const SEGMENTS := 48
const INNER_FROM := 0.8
const INNER_TO := 0.96
## Angle behind the sweep head over which the glow falls off.
const TAIL := 0.9
## Dimmest part of the ring, far from the head, so the full ring stays visible after the sweep.
const FLOOR := 0.35

var _elapsed: float = Player.FLARE_TOTAL


func _ready() -> void:
	# Additive blend: the bands add light to the ground instead of covering it.
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = mat
	visibility_changed.connect(_on_visibility_changed)


## The ring's radius: the flare reach.
func get_radius() -> float:
	return Player.FLARE_REACH


func _on_visibility_changed() -> void:
	if visible:
		_restart()


func _restart() -> void:
	_elapsed = 0.0
	queue_redraw()


func _process(delta: float) -> void:
	if not visible or _elapsed >= Player.FLARE_TOTAL:
		return
	_elapsed = minf(_elapsed + delta, Player.FLARE_TOTAL)
	queue_redraw()
	# The ring hides itself after the fade, so the next flare's `visible = true` restarts it.
	if _elapsed >= Player.FLARE_TOTAL:
		visible = false


func _draw() -> void:
	if not visible or _elapsed >= Player.FLARE_TOTAL:
		return
	var span := TAU * clampf(_elapsed / Player.FLARE_ACTIVE, 0.0, 1.0)
	if span <= 0.0:
		return
	var past_active := (_elapsed - Player.FLARE_ACTIVE) / (Player.FLARE_TOTAL - Player.FLARE_ACTIVE)
	var fade := 1.0 - clampf(past_active, 0.0, 1.0)
	for band in range(BANDS):
		var t := float(band) / float(BANDS - 1)
		var inner := Player.FLARE_REACH * lerpf(INNER_FROM, INNER_TO, t)
		var colour := CORE.lerp(AMBER, t)
		_draw_band(span, inner, Player.FLARE_REACH, colour, fade)


## One overlapping band of the ring, drawn as quads from the sweep start (angle 0 of the span) to
## the head. Vertex alpha is strongest at the head and falls off behind it.
func _draw_band(span: float, inner: float, outer: float, colour: Color, fade: float) -> void:
	for j in range(SEGMENTS):
		var a0 := span * float(j) / float(SEGMENTS)
		var a1 := span * float(j + 1) / float(SEGMENTS)
		var c0 := with_alpha(colour, BAND_ALPHA * fade * _glow(span - a0))
		var c1 := with_alpha(colour, BAND_ALPHA * fade * _glow(span - a1))
		var points := PackedVector2Array(
			[
				Vector2.from_angle(a0) * outer,
				Vector2.from_angle(a1) * outer,
				Vector2.from_angle(a1) * inner,
				Vector2.from_angle(a0) * inner,
			]
		)
		draw_polygon(points, PackedColorArray([c0, c1, c1, c0]))


## Glow at `behind` radians behind the sweep head: 1 at the head, FLOOR far away.
static func _glow(behind: float) -> float:
	var s := clampf(1.0 - behind / TAIL, 0.0, 1.0)
	return lerpf(FLOOR, 1.0, s * s * (3.0 - 2.0 * s))


static func with_alpha(colour: Color, alpha: float) -> Color:
	return Color(colour.r, colour.g, colour.b, alpha)
