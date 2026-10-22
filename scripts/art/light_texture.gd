class_name LightTexture
extends RefCounted
## Radial white-to-transparent texture for PointLight2D. A light with texture_scale = 1 reaches
## SIZE / 2 pixels; use LightTexture.scale_for(radius).

const SIZE := 512


static func make() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.set_color(1, Color(1, 1, 1, 0))
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = SIZE
	tex.height = SIZE
	return tex


static func scale_for(radius: float) -> float:
	return radius * 2.0 / float(SIZE)
