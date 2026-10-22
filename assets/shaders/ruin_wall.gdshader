shader_type canvas_item;

// A low ruined dry-stone wall in the three-quarter view, painted for one wall block (SolidBlock)
// of a group of touching wall blocks. The footprint is the union of the group's rectangles. The
// wall top is the footprint drawn `height` px higher; the front face fills the band between the
// top and the south edge of the footprint. Some stone-wide columns are lower and some edge
// stones are missing, so the top edges look broken. A soft shadow falls to the lower right.
// Each block draws only the pixels whose ground point lies in its own rectangle (`own_rect`), so
// the group reads as one wall and every block still y-sorts on its own.

const int MAX_RECTS = 16;
const int MAX_SEGS = 48;

uniform sampler2D top_tex : source_color, repeat_enable, filter_linear;
uniform sampler2D face_tex : source_color, repeat_enable, filter_linear;
uniform vec2 tex_size = vec2(384.0);
// The face texture repeats every tex_size / face_scale px, so its stones are smaller.
uniform float face_scale = 1.5;
// Rectangles of the group as (x0, y0, x1, y1), and the outline of their union as segments.
uniform vec4 rects[MAX_RECTS];
uniform int rect_count = 0;
uniform vec4 segs[MAX_SEGS];
uniform int seg_count = 0;
uniform vec4 own_rect;
uniform float height = 48.0;
uniform vec2 shadow_offset = vec2(12.0, 8.0);

varying vec2 local_pos;
varying vec2 world_pos;

void vertex() {
	local_pos = VERTEX;
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	float a = mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x);
	float b = mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x);
	return mix(a, b, u.y);
}

bool inside(vec2 p) {
	for (int i = 0; i < MAX_RECTS; i++) {
		if (i >= rect_count) {
			break;
		}
		vec4 r = rects[i];
		if (p.x >= r.x && p.y >= r.y && p.x < r.z && p.y < r.w) {
			return true;
		}
	}
	return false;
}

bool owns(vec2 p) {
	return p.x >= own_rect.x && p.y >= own_rect.y && p.x < own_rect.z && p.y < own_rect.w;
}

// Exact signed distance to the union: negative inside.
float sdf(vec2 p) {
	float d = 1e5;
	for (int i = 0; i < MAX_SEGS; i++) {
		if (i >= seg_count) {
			break;
		}
		vec2 a = segs[i].xy;
		vec2 ab = segs[i].zw - a;
		float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-4), 0.0, 1.0);
		d = min(d, length(p - a - ab * t));
	}
	return inside(p) ? -d : d;
}

// How much lower the wall top is at world x: mostly 0, with crumbled dips here and there.
float drop(float wx) {
	float dip = smoothstep(0.5, 0.8, vnoise(vec2(wx / 38.0, 2.0)));
	return dip * 22.0 + vnoise(vec2(wx / 7.0, 1.0)) * 4.0;
}

// Missing edge stones: how far the outline is eaten back at this world point.
float erode(vec2 wp) {
	return smoothstep(0.5, 0.82, vnoise(wp / 15.0)) * 13.0 + vnoise(wp / 5.0) * 2.0;
}

void fragment() {
	vec2 q = local_pos;
	float lift = height - drop(world_pos.x);
	// The footprint point whose wall top shows at q.
	vec2 g = q + vec2(0.0, lift);
	vec2 wg = world_pos + vec2(0.0, lift);
	float dg = sdf(g) + erode(wg);
	float dq = sdf(q) + erode(world_pos) * 0.7;
	// Grass grows up in front of the foot of the wall (only where the south edge is near).
	float south = smoothstep(1.0, 5.0, sdf(q + vec2(0.0, 6.0)) - sdf(q));
	float tufts = smoothstep(0.5, 0.85, vnoise(vec2(world_pos.x / 3.5, world_pos.y / 12.0)));
	dq += south * tufts * 8.0;
	float top_a = 1.0 - smoothstep(-0.8, 0.8, dg);
	float face_a = (1.0 - smoothstep(-0.8, 0.8, dq)) * (1.0 - top_a);
	if (!owns(g)) {
		top_a = 0.0;
	}
	if (!owns(q)) {
		face_a = 0.0;
	}

	// Top: lit from the upper left, dark in the gaps where edge stones are missing, a bright lip
	// where it turns down into the front face.
	// The top texture keeps one phase per footprint point, so a dip does not shift the stones.
	vec3 top = texture(top_tex, (world_pos + vec2(0.0, height)) / tex_size).rgb * vec3(1.04, 1.03, 1.0);
	// Edge stones catch the light on the upper-left side and fall into shade on the lower right.
	vec2 dx = vec2(1.5, 0.0);
	vec2 dy = vec2(0.0, 1.5);
	vec2 n = vec2(sdf(g + dx) + erode(wg + dx) - sdf(g - dx) - erode(wg - dx),
			sdf(g + dy) + erode(wg + dy) - sdf(g - dy) - erode(wg - dy));
	float facing = dot(normalize(n + vec2(1e-4)), vec2(-0.7071, -0.7071));
	float rim = 1.0 - smoothstep(0.0, 4.0, -dg);
	top *= 1.0 + rim * (0.24 * facing - 0.06);
	float lip = smoothstep(-1.0, 1.0, sdf(g + vec2(0.0, 5.0)) + erode(wg));
	top = mix(top, top * 1.22, lip * 0.6);

	// Front face: in cool shade, darker towards the ground, with moss at the foot.
	vec3 face = texture(face_tex, world_pos * face_scale / tex_size).rgb;
	face = mix(face, vec3(dot(face, vec3(0.3, 0.5, 0.2))), 0.25) * vec3(0.6, 0.64, 0.72);
	float up = clamp(-dq / max(lift, 1.0), 0.0, 1.0);
	face *= mix(0.55, 1.0, up);
	float moss = (1.0 - smoothstep(0.0, 0.3, up)) * smoothstep(0.45, 0.7, vnoise(world_pos / 7.0));
	face = mix(face, vec3(0.16, 0.22, 0.12), moss * 0.7);

	vec3 col = mix(face, top, top_a);
	float alpha = max(top_a, face_a);

	// Soft shadow on the ground to the lower right of the footprint (only outside the wall).
	if (alpha < 0.99 && owns(q - shadow_offset)) {
		float shade = 1.0 - smoothstep(-6.0, 6.0, sdf(q - shadow_offset));
		float wall_any = max(1.0 - smoothstep(-0.8, 0.8, sdf(g) + erode(wg)),
				1.0 - smoothstep(-0.8, 0.8, sdf(q)));
		shade *= 0.38 * (1.0 - wall_any);
		col = mix(vec3(0.03, 0.04, 0.07), col, alpha / max(alpha + shade, 1e-4));
		alpha = alpha + shade * (1.0 - alpha);
	}
	COLOR = vec4(col, alpha);
}
