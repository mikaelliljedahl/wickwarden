extends TestCase


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
	for variant in [&"moss_wall", &"dry_vine_screen", &"bush_cluster"]:
		await _check_cut(variant, false)
	await _check_placeholder_fallback()


func _check_cut(variant: StringName, missing: bool) -> void:
	reset_state()
	var arena := make_arena()
	var bush: Bush
	if missing:
		bush = MissingBushArt.new() if variant == &"bush" else MissingReedBush.new()
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
	if not missing and variant in [&"reed_cluster", &"rush_wall"]:
		check(reed_fx != null, "%s spawns painted reeds" % variant)
		if reed_fx != null:
			check(reed_fx.top_level and reed_fx.z_index == 10, "effect is world fixed")
			check(reed_fx.modulate.a > 0.0 and reed_fx.modulate.a <= 0.65, "effect alpha fades from 0.65")
	elif not missing and variant == &"bush":
		check(bush_fx != null, "bush spawns painted leaves")
		if bush_fx != null:
			check(bush_fx.top_level and bush_fx.z_index == 10, "leaves are world fixed")
			check(bush_fx.modulate.a > 0.0 and bush_fx.modulate.a <= 0.65, "leaves fade")
	else:
		check(reed_fx == null, "other or missing art does not spawn reeds")
		check(bush_fx == null, "other or missing art does not spawn leaves")
		check(arena.find_child("Puff", false, false) != null, "original fallback appears")
	hit.deactivate()
	await seconds(0.35)
	check(not is_instance_valid(reed_fx), "painted effect ends after 0.25 s")
	check(not is_instance_valid(bush_fx), "leaf effect ends after 0.25 s")
	check_eq(cuts[0], 1, "cut signal is not repeated")
	await dispose(arena)


func _check_placeholder_fallback() -> void:
	reset_state()
	SpriteVisual.use_manifest("res://tests/fixtures/no_such_manifest.json")
	var arena := make_arena()
	var bush := MissingBushArt.new()
	bush.drops_enabled = false
	arena.add_child(bush)
	bush.cut_down()
	var puff := arena.find_child("Puff", false, false)
	check(puff is Placeholder, "missing leaf and explosion art uses placeholder")
	await dispose(arena)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)
