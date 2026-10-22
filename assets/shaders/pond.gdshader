shader_type canvas_item;

// A pond painted over the union of a group of water blocks (SolidBlock). From the inside out:
// water with lighter shallows, a wet shore line, and a soft, irregular mud bank that grass eats
// into. The far (north) bank shows a low earth face above the water (three-quarter view).
// Geometry is in the node's local space; the texture phase is in world space, so the pattern
// does not depend on where the node sits.

const int MAX_RECTS = 16;
const int MAX_SEGS = 48;
const float TAU_F = 6.2831853;

uniform sampler2D water_tex : source_color, repeat_enable, filter_linear;
uniform sampler2D bank_tex : source_color, repeat_enable, filter_linear;
uniform vec2 tex_size = vec2(384.0);
// Rectangles of the group as (x0, y0, x1, y1), and the outline of their union as segments.
uniform vec4 rects[MAX_RECTS];
uniform int rect_count = 0;
uniform vec4 segs[MAX_SEGS];
uniform int seg_count = 0;
uniform float bank_width = 40.0;
uniform float shore_wobble = 14.0;
uniform float round_radius = 22.0;
uniform float face_height = 11.0;

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

// Value noise in -1..1 with a little detail.
float fbm(vec2 p) {
	return (vnoise(p) * 0.6 + vnoise(p * 2.3 + 17.0) * 0.3 + vnoise(p * 5.1 - 9.0) * 0.1) * 2.0 - 1.0;
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

// The mean distance over a small ring rounds every corner of the union.
float field(vec2 p) {
	float sum = sdf(p);
	for (int k = 0; k < 8; k++) {
		float a = float(k) * TAU_F / 8.0;
		sum += sdf(p + vec2(cos(a), sin(a)) * round_radius);
	}
	return sum / 9.0;
}

void fragment() {
	vec2 p = local_pos;
	float wobble = (fbm(world_pos / 95.0) * 0.7 + fbm(world_pos / 33.0 + 40.0) * 0.3) * shore_wobble;
	float f = field(p) + wobble;
	float reach = bank_width + shore_wobble + 12.0;
	if (f > reach) {
		COLOR = vec4(0.0);
	} else {
		vec3 water = texture(water_tex, world_pos / tex_size).rgb;
		vec3 bank = texture(bank_tex, world_pos / tex_size).rgb;

		// Bank: wet and dark at the water line, drier outwards, eaten by grass at its outer edge.
		float grass = fbm(world_pos / 21.0 + 5.0) * 14.0;
		float bank_a = 1.0 - smoothstep(bank_width * 0.5, bank_width, f + grass);
		float wet = 1.0 - smoothstep(0.0, 16.0, f);
		vec3 land = bank * mix(vec3(1.0), vec3(0.52, 0.5, 0.5), wet);

		// Water: muddy, lighter shallows near the shore, the open water darker and cooler.
		float shallow = 1.0 - smoothstep(-30.0, -2.0, f);
		vec3 shallows = mix(water, bank * vec3(0.55, 0.62, 0.62), 0.45);
		vec3 wcol = mix(shallows, water * vec3(0.86, 0.9, 0.98), shallow);
		// A faint cool sky reflection on the water lip.
		float lip = 1.0 - smoothstep(0.0, 2.5, abs(f + 3.0));
		wcol = mix(wcol, vec3(0.5, 0.56, 0.64), lip * (0.06 + 0.22 * vnoise(world_pos / 18.0)));
		// Three-quarter view: the far bank shows a low earth face, and it shades the water below.
		float above = field(p - vec2(0.0, face_height)) + wobble;
		float face = smoothstep(-1.5, 1.5, above);
		float face_shade = smoothstep(-2.0, 2.0, field(p - vec2(0.0, face_height * 2.4)) + wobble);
		wcol *= mix(1.0, 0.72, face_shade);
		vec3 earth = bank * mix(0.32, 0.5, clamp(-f / face_height, 0.0, 1.0));
		wcol = mix(wcol, earth, face);

		float is_water = 1.0 - smoothstep(-1.0, 1.0, f);
		COLOR = vec4(mix(land, wcol, is_water), max(is_water, bank_a));
	}
}
