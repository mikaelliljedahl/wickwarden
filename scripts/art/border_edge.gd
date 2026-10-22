class_name BorderEdge
extends RefCounted
## Presentation-only geometry for the room border ring (see Room._draw). It traces the inner edge
## of the wall ring as a closed loop (rounded corners, door openings leave open runs), pushes the
## edge outwards with smooth deterministic noise (leafy lumps for the hedge, angular rock for the
## cave) and builds: the floor polygon, a contact shadow on the floor, a dark band and a lit lip
## inside the wall. Nothing here touches collision or room geometry.
##
## Usage: var e := BorderEdge.new(); e.build(size, thickness, exits, seed, dark)
## then draw e.floor_polygon, e.shadow_mesh, e.ao_mesh, e.lip_mesh.

const STEP := 4.0
const CORNER_RADIUS := 26.0
const EDGE_MIN := -3.0  ## furthest the wavy edge recedes into the wall rectangle
const EDGE_MAX := 12.0  ## furthest it reaches over the floor (visual only)

var floor_polygon := PackedVector2Array()
var shadow_mesh: ArrayMesh
var ao_mesh: ArrayMesh
var lip_mesh: ArrayMesh

var _seed: int = 0
var _dark: bool = false
var _total: float = 1.0
var _pos := PackedVector2Array()
var _nrm := PackedVector2Array()
var _free: Array[bool] = []
var _s := PackedFloat32Array()


## Builds everything for a room of `size` with a wall ring `thickness` thick and openings on
## the sides named in `exits` (&"n", &"e", &"s", &"w"; EXIT_WIDTH wide, centred).
func build(
	size: Vector2, thickness: float, exits: Array, seed_value: int, dark: bool, half_gap := 96.0
) -> void:
	_seed = seed_value & 0xffffff
	_dark = dark
	_trace(size, thickness, exits, half_gap)
	var displaced := PackedVector2Array()
	for i in _pos.size():
		displaced.append(_pos[i] + _nrm[i] * edge_offset(_s[i]) if _free[i] else _pos[i])
	# Polygon of the floor, pushed 1.5 px past the room border so no seam shows at the openings.
	floor_polygon = PackedVector2Array()
	for p in displaced:
		var q := p
		if q.x <= 0.5:
			q.x -= 1.5
		elif q.x >= size.x - 0.5:
			q.x += 1.5
		if q.y <= 0.5:
			q.y -= 1.5
		elif q.y >= size.y - 0.5:
			q.y += 1.5
		floor_polygon.append(q)
	_build_meshes(displaced)


## Edge displacement (px, towards the floor) at arc length `s` of the loop. Deterministic.
func edge_offset(s: float) -> float:
	# Periodic blend so the loop closes without a jump where it starts and ends.
	var w := smoothstep(_total - 90.0, _total, s)
	var v := _shape(s)
	if w > 0.0:
		v = lerpf(v, _shape(s - _total), w)
	return lerpf(EDGE_MIN, EDGE_MAX, clampf(inverse_lerp(0.15, 0.85, v), 0.0, 1.0))


static func hash01(i: int, seed_value: int) -> float:
	var x := (i * 374761393 + seed_value * 668265263) & 0x7fffffff
	x = ((x ^ (x >> 13)) * 1274126177) & 0x7fffffff
	x = x ^ (x >> 16)
	return float(x & 0xffff) / 65535.0


## Smooth value noise in 0..1.
static func smooth_noise(x: float, seed_value: int) -> float:
	var i := int(floor(x))
	var f := x - float(i)
	var u := f * f * (3.0 - 2.0 * f)
	return lerpf(hash01(i, seed_value), hash01(i + 1, seed_value), u)


## Linearly interpolated value noise in 0..1 (angular).
static func linear_noise(x: float, seed_value: int) -> float:
	var i := int(floor(x))
	var f := x - float(i)
	return lerpf(hash01(i, seed_value), hash01(i + 1, seed_value), f)


## Builds one mesh of vertex-coloured quad strips. `rows` are polylines of equal length, `colors`
## the matching per-vertex colours. Each element of `strips` is {rows, colors}.
static func ladder_mesh(strips: Array) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	for strip in strips:
		var rows: Array = strip["rows"]
		var cols: Array = strip["colors"]
		var n: int = (rows[0] as PackedVector2Array).size()
		if n < 2:
			continue
		var verts := PackedVector2Array()
		var colors := PackedColorArray()
		var idx := PackedInt32Array()
		for k in rows.size():
			verts.append_array(rows[k])
			colors.append_array(cols[k])
		for k in rows.size() - 1:
			for i in n - 1:
				var a := k * n + i
				var b := a + 1
				var c := a + n
				var d := c + 1
				idx.append_array([a, b, c, b, d, c])
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = verts
		arrays[Mesh.ARRAY_COLOR] = colors
		arrays[Mesh.ARRAY_INDEX] = idx
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


## Darkening towards the outer screen edge, inside the wall band. `rects` are the wall
## rectangles (room-local); each fades from `alpha` at the room border to 0 at its inner side.
static func vignette_mesh(rects: Array[Rect2], size: Vector2, alpha: float) -> ArrayMesh:
	var strips: Array = []
	for r in rects:
		var rows: Array = []
		var horizontal := r.size.x > r.size.y
		var from_start: bool = (r.position.y < 0.5) if horizontal else (r.position.x < 0.5)
		var depth: float = r.size.y if horizontal else r.size.x
		for f in [0.0, 0.4, 1.0]:
			var o: float = f * depth if from_start else (1.0 - f) * depth
			if horizontal:
				var y := r.position.y + o
				rows.append(PackedVector2Array([Vector2(r.position.x, y), Vector2(r.end.x, y)]))
			else:
				var x := r.position.x + o
				rows.append(PackedVector2Array([Vector2(x, r.position.y), Vector2(x, r.end.y)]))
		var cols: Array = []
		for a in [alpha, alpha * 0.35, 0.0]:
			cols.append(PackedColorArray([Color(0, 0, 0, a), Color(0, 0, 0, a)]))
		strips.append({"rows": rows, "colors": cols})
	return ladder_mesh(strips)


func _shape(x: float) -> float:
	if _dark:
		# Rough rock: angular value noise, several octaves.
		return (
			0.55 * linear_noise(x / 44.0, _seed + 1)
			+ 0.30 * linear_noise(x / 19.0, _seed + 2)
			+ 0.15 * linear_noise(x / 8.0, _seed + 3)
		)
	# Hedge: soft swells plus round leaf lobes with small cusps between them.
	var phase := smooth_noise(x / 110.0, _seed + 3) * 5.0
	var leaf := sqrt(absf(sin(x * PI / 21.0 + phase)))
	return (
		0.5 * smooth_noise(x / 62.0, _seed + 1)
		+ 0.2 * smooth_noise(x / 26.0 + 9.1, _seed + 2)
		+ 0.3 * leaf
	)


func _edge(a: Vector2, b: Vector2, n: Vector2, free := true) -> Dictionary:
	return {"a": a, "b": b, "n": n, "free": free}


func _loop_edges(size: Vector2, t: float, exits: Array, h: float) -> Array:
	var w := size.x
	var ht := size.y
	var mx := w * 0.5
	var my := ht * 0.5
	var e: Array = []
	# North, west to east.
	if exits.has(&"n"):
		e.append(_edge(Vector2(t, t), Vector2(mx - h, t), Vector2(0, 1)))
		e.append(_edge(Vector2(mx - h, t), Vector2(mx - h, 0), Vector2(1, 0)))
		e.append(_edge(Vector2(mx - h, 0), Vector2(mx + h, 0), Vector2.ZERO, false))
		e.append(_edge(Vector2(mx + h, 0), Vector2(mx + h, t), Vector2(-1, 0)))
		e.append(_edge(Vector2(mx + h, t), Vector2(w - t, t), Vector2(0, 1)))
	else:
		e.append(_edge(Vector2(t, t), Vector2(w - t, t), Vector2(0, 1)))
	# East, north to south.
	if exits.has(&"e"):
		e.append(_edge(Vector2(w - t, t), Vector2(w - t, my - h), Vector2(-1, 0)))
		e.append(_edge(Vector2(w - t, my - h), Vector2(w, my - h), Vector2(0, 1)))
		e.append(_edge(Vector2(w, my - h), Vector2(w, my + h), Vector2.ZERO, false))
		e.append(_edge(Vector2(w, my + h), Vector2(w - t, my + h), Vector2(0, -1)))
		e.append(_edge(Vector2(w - t, my + h), Vector2(w - t, ht - t), Vector2(-1, 0)))
	else:
		e.append(_edge(Vector2(w - t, t), Vector2(w - t, ht - t), Vector2(-1, 0)))
	# South, east to west.
	if exits.has(&"s"):
		e.append(_edge(Vector2(w - t, ht - t), Vector2(mx + h, ht - t), Vector2(0, -1)))
		e.append(_edge(Vector2(mx + h, ht - t), Vector2(mx + h, ht), Vector2(-1, 0)))
		e.append(_edge(Vector2(mx + h, ht), Vector2(mx - h, ht), Vector2.ZERO, false))
		e.append(_edge(Vector2(mx - h, ht), Vector2(mx - h, ht - t), Vector2(1, 0)))
		e.append(_edge(Vector2(mx - h, ht - t), Vector2(t, ht - t), Vector2(0, -1)))
	else:
		e.append(_edge(Vector2(w - t, ht - t), Vector2(t, ht - t), Vector2(0, -1)))
	# West, south to north.
	if exits.has(&"w"):
		e.append(_edge(Vector2(t, ht - t), Vector2(t, my + h), Vector2(1, 0)))
		e.append(_edge(Vector2(t, my + h), Vector2(0, my + h), Vector2(0, -1)))
		e.append(_edge(Vector2(0, my + h), Vector2(0, my - h), Vector2.ZERO, false))
		e.append(_edge(Vector2(0, my - h), Vector2(t, my - h), Vector2(0, 1)))
		e.append(_edge(Vector2(t, my - h), Vector2(t, t), Vector2(1, 0)))
	else:
		e.append(_edge(Vector2(t, ht - t), Vector2(t, t), Vector2(1, 0)))
	return e


func _push(p: Vector2, n: Vector2, free: bool) -> void:
	_pos.append(p)
	_nrm.append(n)
	_free.append(free)


func _trace(size: Vector2, t: float, exits: Array, h: float) -> void:
	_pos = PackedVector2Array()
	_nrm = PackedVector2Array()
	_free = []
	var edges := _loop_edges(size, t, exits, h)
	var count := edges.size()
	# Fillet radius at the joint after edge i (0 when either edge is not free).
	var fr: Array[float] = []
	for i in count:
		var e1: Dictionary = edges[i]
		var e2: Dictionary = edges[(i + 1) % count]
		if not e1["free"] or not e2["free"]:
			fr.append(0.0)
			continue
		var l1: float = (e1["b"] - e1["a"]).length()
		var l2: float = (e2["b"] - e2["a"]).length()
		fr.append(minf(CORNER_RADIUS, minf(l1, l2) * 0.5))
	for i in count:
		var e: Dictionary = edges[i]
		var a: Vector2 = e["a"]
		var b: Vector2 = e["b"]
		if not e["free"]:
			_push((a + b) * 0.5, Vector2.ZERO, false)
			continue
		var dir := (b - a).normalized()
		var r_in: float = fr[(i - 1 + count) % count]
		var r_out: float = fr[i]
		var p0 := a + dir * r_in
		var p1 := b - dir * r_out
		var steps := maxi(1, int(ceil((p1 - p0).length() / STEP)))
		for k in steps + 1:
			_push(p0.lerp(p1, float(k) / float(steps)), e["n"], true)
		if r_out > 0.0:
			var e2: Dictionary = edges[(i + 1) % count]
			var n1: Vector2 = e["n"]
			var n2: Vector2 = e2["n"]
			var d2: Vector2 = (e2["b"] - e2["a"]).normalized()
			var concave: bool = d2.dot(n1) > 0.0  # floor corner: the arc bulges into the floor
			var c: Vector2 = b + r_out * (n1 + n2) if concave else b - r_out * (n1 + n2)
			var arc_steps := 6
			for k in range(1, arc_steps):
				var nl := n1.lerp(n2, float(k) / float(arc_steps)).normalized()
				var p := c - r_out * nl if concave else c + r_out * nl
				_push(p, nl, true)
	_s = PackedFloat32Array()
	var acc := 0.0
	for i in _pos.size():
		if i > 0:
			acc += _pos[i].distance_to(_pos[i - 1])
		_s.append(acc)
	_total = maxf(acc + _pos[0].distance_to(_pos[_pos.size() - 1]), 1.0)


## Splits the loop into runs of free points (open polylines; a closed ring when there are no
## openings). Each run is {p, n, s}.
func _runs(displaced: PackedVector2Array) -> Array:
	var runs: Array = []
	var n := _pos.size()
	var start := _free.find(false)
	var cur := {"p": PackedVector2Array(), "n": PackedVector2Array(), "s": PackedFloat32Array()}
	if start == -1:
		for i in n + 1:
			var j := i % n
			cur["p"].append(displaced[j])
			cur["n"].append(_nrm[j])
			cur["s"].append(_s[j])
		return [cur]
	for k in range(1, n + 1):
		var j := (start + k) % n
		if _free[j]:
			cur["p"].append(displaced[j])
			cur["n"].append(_nrm[j])
			cur["s"].append(_s[j])
		elif cur["p"].size() > 0:
			runs.append(cur)
			cur = {"p": PackedVector2Array(), "n": PackedVector2Array(), "s": PackedFloat32Array()}
	if cur["p"].size() > 0:
		runs.append(cur)
	return runs


func _build_meshes(displaced: PackedVector2Array) -> void:
	var shadow_col := Color(0.0, 0.0, 0.04) if _dark else Color(0.03, 0.02, 0.05)
	var ao_col := Color(0.0, 0.0, 0.03) if _dark else Color(0.02, 0.04, 0.02)
	var lip_col := Color(0.55, 0.7, 1.0) if _dark else Color(1.0, 0.9, 0.55)
	var shadow_strips: Array = []
	var ao_strips: Array = []
	var lip_strips: Array = []
	for run in _runs(displaced):
		var pts: PackedVector2Array = run["p"]
		var nrm: PackedVector2Array = run["n"]
		var ss: PackedFloat32Array = run["s"]
		var m := pts.size()
		# Shadow on the floor. Light comes from the upper left: edges that face right and down
		# (north and west walls) throw a longer, darker shadow.
		var rows: Array = [PackedVector2Array(), PackedVector2Array(), PackedVector2Array()]
		var cols: Array = [PackedColorArray(), PackedColorArray(), PackedColorArray()]
		var ao_rows: Array = [PackedVector2Array(), PackedVector2Array(), PackedVector2Array()]
		var ao_cols: Array = [PackedColorArray(), PackedColorArray(), PackedColorArray()]
		var lip_rows: Array = [PackedVector2Array(), PackedVector2Array(), PackedVector2Array()]
		var lip_cols: Array = [PackedColorArray(), PackedColorArray(), PackedColorArray()]
		for i in m:
			var p := pts[i]
			var n := nrm[i]
			var lit := n.x + n.y  # +1.4 faces the light's shadow side, -1.4 faces the light
			var alpha := (0.72 if _dark else 0.55) + 0.07 * lit
			var depth := (40.0 + 12.0 * smooth_noise(ss[i] / 120.0, _seed + 7)) * (1.0 + 0.12 * lit)
			rows[0].append(p - n * 2.0)
			rows[1].append(p + n * depth * 0.32)
			rows[2].append(p + n * depth)
			cols[0].append(Color(shadow_col, alpha))
			cols[1].append(Color(shadow_col, alpha * 0.4))
			cols[2].append(Color(shadow_col, 0.0))
			var ao_a := (0.65 if _dark else 0.34)
			ao_rows[0].append(p)
			ao_rows[1].append(p - n * 10.0)
			ao_rows[2].append(p - n * 28.0)
			ao_cols[0].append(Color(ao_col, ao_a))
			ao_cols[1].append(Color(ao_col, ao_a * 0.4))
			ao_cols[2].append(Color(ao_col, 0.0))
			var mod := 0.55 + 0.45 * smooth_noise(ss[i] / 33.0, _seed + 11)
			var lip_a := (0.34 if _dark else 0.22) * mod * (1.0 - 0.28 * lit)
			lip_rows[0].append(p)
			lip_rows[1].append(p - n * 4.0)
			lip_rows[2].append(p - n * 9.0)
			lip_cols[0].append(Color(lip_col, lip_a * 0.5))
			lip_cols[1].append(Color(lip_col, lip_a))
			lip_cols[2].append(Color(lip_col, 0.0))
		shadow_strips.append({"rows": rows, "colors": cols})
		ao_strips.append({"rows": ao_rows, "colors": ao_cols})
		lip_strips.append({"rows": lip_rows, "colors": lip_cols})
	shadow_mesh = ladder_mesh(shadow_strips)
	ao_mesh = ladder_mesh(ao_strips)
	lip_mesh = ladder_mesh(lip_strips)
