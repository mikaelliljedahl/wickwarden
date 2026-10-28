extends TestCase

const BUSH_CUT_PATH := "res://assets/sprites/bush_cut_z1.png"


class MissingReedBush extends Bush:
	func _reed_cut_texture() -> Texture2D:
		return null


class MissingBushArt extends Bush:
	func _bush_cut_texture() -> Texture2D:
		return null


func run() -> void:
	for variant in [&"reed_cluster", &"rush_wall"]:
		await _check_cut(variant, false)
		await _check_cut(variant, true)
	await _check_cut(&"bush", false)
	await _check_cut(&"bush", true)
	await _check_cut(&"moss_wall", false)
	await _check_cut(&"moss_wall", true)
	await _check_cut(&"dry_vine_screen", false)
	await _check_cut(&"dry_vine_screen", true)
	await _check_cut(&"bush_cluster", false)
	await _check_placeholder_fallback()


func _check_cut(variant: StringName, missing: bool) -> void:
	reset_state()
	var arena := make_arena()
	var bush: Bush
	if missing:
		bush = MissingBushArt.new() if variant in [&"bush", &"moss_wall", &"dry_vine_screen"] else MissingReedBush.new()
	else:
		bush = Bush.new()
	bush.variant = variant
	bush.drop_roll_override = 0.0
	arena.add_child(bush)
	bush.global_position = Vector2(400, 400)
	var cuts := [0]
	bush.cut.connect(func(): cuts[0] += 1)
	await frames(2)
	check_eq(bush.collision_layer, Layers.WORLD, "vegetation starts solid")
	var hit := Hitbox.new()
	hit.kind = &"hook"
	hit.team = Layers.Team.PLAYER
	hit.add_circle(24.0)
	arena.add_child(hit)
	hit.global_position = bush.global_position
	hit.activate()
	await frames(2)
	check_eq(cuts[0], 1, "%s emits cut once" % variant)
	check(not is_instance_valid(bush), "%s is removed, including collision" % variant)
	check_eq(get_tree().get_nodes_in_group(&"pickups").size(), 1, "forced drop is preserved")
	var reed_fx := arena.find_child("ReedCut", false, false) as Sprite2D
	var bush_fx := arena.find_child("BushCut", false, false) as Sprite2D
	var vine_fx := arena.find_child("VineCut", false, false) as Sprite2D
	if not missing and variant in [&"reed_cluster", &"rush_wall"]:
		check(reed_fx != null, "%s spawns painted reeds" % variant)
		if reed_fx != null:
			check(reed_fx.top_level and reed_fx.z_index == 10, "effect is world fixed")
			check(reed_fx.modulate.a > 0.0 and reed_fx.modulate.a <= 0.65, "effect alpha fades from 0.65")
	elif not missing and variant in [&"bush", &"moss_wall"]:
		check(bush_fx != null, "%s spawns painted leaves" % variant)
		if bush_fx != null:
			check(bush_fx.top_level and bush_fx.z_index == 10, "leaves are world fixed")
			check(bush_fx.modulate.a > 0.0 and bush_fx.modulate.a <= 0.65, "leaves fade")
			if variant == &"moss_wall":
				check_eq(bush_fx.texture, load(BUSH_CUT_PATH), "moss reuses bush leaf art")
				check(
					bush_fx.modulate.is_equal_approx(Color(0.65, 0.78, 0.56, bush_fx.modulate.a)),
					"moss leaves have muted green tint"
				)
	elif not missing and variant == &"dry_vine_screen":
		check(vine_fx != null, "vine screen spawns painted twigs")
		if vine_fx != null:
			check(vine_fx.top_level and vine_fx.z_index == 10, "twigs are world fixed")
			check_eq(vine_fx.get_child_count(), 5, "five twig fragments")
			var twig := vine_fx.get_child(0) as Sprite2D
			var atlas := twig.texture as AtlasTexture
			check(atlas != null and atlas.atlas == load(BUSH_CUT_PATH), "twigs reuse bush art")
	else:
		check(reed_fx == null, "other or missing art does not spawn reeds")
		check(bush_fx == null, "other or missing art does not spawn leaves")
		check(vine_fx == null, "other or missing art does not spawn twigs")
		check(arena.find_child("Puff", false, false) != null, "original fallback appears")
	hit.deactivate()
	await seconds(0.35)
	check(not is_instance_valid(reed_fx), "painted effect ends after 0.25 s")
	check(not is_instance_valid(bush_fx), "leaf effect ends after 0.25 s")
	check(not is_instance_valid(vine_fx), "twig effect ends after 0.25 s")
	check_eq(cuts[0], 1, "cut signal is not repeated")
	await dispose(arena)


func _check_placeholder_fallback() -> void:
	reset_state()
	SpriteVisual.use_manifest("res://tests/fixtures/no_such_manifest.json")
	for variant in [&"bush", &"dry_vine_screen"]:
		var arena := make_arena()
		var bush := MissingBushArt.new()
		bush.variant = variant
		bush.drops_enabled = false
		arena.add_child(bush)
		bush.cut_down()
		var puff := arena.find_child("Puff", false, false)
		check(puff is Placeholder, "%s: missing fragment and explosion art uses placeholder" % variant)
		await dispose(arena)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)
