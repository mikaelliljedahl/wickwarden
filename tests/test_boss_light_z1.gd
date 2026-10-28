extends TestCase


class Probe:
	extends "res://scripts/enemies/boss_base.gd"


func run() -> void:
	await _routing()
	for scenario in ["missing", "clipped", "short", "wrong_fps", "missing_both"]:
		await _invalid_art(scenario)
	await _physical()


func _routing() -> void:
	reset_state()
	var arena := make_arena()
	var boss := Probe.new()
	arena.add_child(boss)
	await frames(2)
	for id in [
		&"kilnkeeper",
		&"briar_mother",
		&"tidewick",
		&"hushed_colossus",
		&"archivist",
		&"dirge_choir",
		&"gloam_knight",
		&"coinwyrm",
		&"lock_warden"
	]:
		boss.boss_id = id
		boss._spawn_death_effect(arena)
		var fx := arena.get_node_or_null("Puff")
		check(fx is SpriteVisual and fx.kind == &"fx_boss_death_light_z1", str(id) + " gets light")
		if fx != null:
			fx.free()
	boss.boss_id = &"the_unlit"
	boss._spawn_death_effect(arena)
	var fallback := arena.get_node_or_null("Puff")
	check(
		fallback is SpriteVisual and fallback.kind == &"explosion", "C10 fallback remains explosion"
	)
	if fallback != null:
		fallback.free()
	boss.miniboss = true
	boss._spawn_death_effect(arena)
	var mini := arena.get_node_or_null("Puff")
	check(mini is SpriteVisual and mini.kind == &"miniboss_death_wax_z1", "miniboss retains wax")
	if mini != null:
		mini.free()
	boss.miniboss = false
	boss.boss_id = &"kilnkeeper"
	var original: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(SpriteVisual.DEFAULT_MANIFEST)
	)
	original.erase("fx_boss_death_light_z1")
	var path := "user://fx_boss_death_light_missing_art.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(original))
	file.close()
	SpriteVisual.use_manifest(path)
	boss._spawn_death_effect(arena)
	var missing := arena.get_node_or_null("Puff")
	check(missing is SpriteVisual and missing.kind == &"explosion", "missing light uses explosion")
	if missing != null:
		missing.free()
	original.erase("explosion")
	file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(original))
	file.close()
	SpriteVisual.use_manifest(path)
	boss._spawn_death_effect(arena)
	check(
		arena.get_node_or_null("Puff") is Placeholder, "missing light and explosion use placeholder"
	)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	await dispose(arena)


func _invalid_art(scenario: String) -> void:
	reset_state()
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)
	SpriteVisual.has_art(&"explosion")
	var entry: Dictionary = SpriteVisual._manifest["fx_boss_death_light_z1"]
	var animation: Dictionary = entry["animations"]["idle"]
	if scenario == "missing" or scenario == "missing_both":
		animation["file"] = "res://missing_light_test.png"
	elif scenario == "clipped" or scenario == "short":
		var path := "res://clipped_light_test.png"
		animation["file"] = path
		var width := 768 * 7 if scenario == "clipped" else 768 * 8
		var height := 768 if scenario == "clipped" else 767
		var img := Image.create(width, height, false, Image.FORMAT_RGBA8)
		SpriteVisual._texture_cache[path] = ImageTexture.create_from_image(img)
	elif scenario == "wrong_fps":
		animation["fps"] = 5.0
	if scenario == "missing_both":
		SpriteVisual._manifest.erase("explosion")
	var arena := make_arena()
	var boss := Probe.new()
	boss.boss_id = &"kilnkeeper"
	arena.add_child(boss)
	await frames(2)
	boss._spawn_death_effect(arena)
	var effect := arena.get_node_or_null("Puff")
	if scenario == "missing_both":
		check(effect is Placeholder, "invalid light and explosion use placeholder")
	else:
		check(effect is SpriteVisual and effect.kind == &"explosion", scenario + " uses explosion")
	await dispose(arena)
	SpriteVisual.use_manifest(SpriteVisual.DEFAULT_MANIFEST)


func _physical() -> void:
	reset_state()
	SaveGame.enabled = false
	var world := (load("res://scenes/world/world.tscn") as PackedScene).instantiate() as World
	add_child(world)
	world.start_at(&"cave_1_8")
	world.player.set_hurtbox_enabled(self, false)
	await frames(100)
	var room := world.current_room
	var boss: Node
	for node in room.get_node("Enemies").get_children():
		if node is EnemyBase and node.boss_id == &"kilnkeeper":
			boss = node
			break
	check(boss != null, "C1 boss exists")
	if boss == null:
		await dispose(world)
		return
	boss.hp = 1
	boss.molten_left = 8.0
	boss.death_drops = [&"ember"] as Array[StringName]
	var parent: Node = boss.get_parent()
	var hit := Hitbox.new()
	hit.team = Layers.Team.PLAYER
	hit.kind = &"hook"
	hit.damage = 2
	hit.knockback = 0.0
	hit.add_circle(100.0)
	room.add_child(hit)
	hit.global_position = boss.global_position
	hit.activate()
	await frames(4)
	hit.deactivate()
	check(boss.is_dying(), "physical hit starts death throes")
	check(GameState.has_flag(&"boss_cave_1_8_defeated"), "physical hit sets defeat flag")
	boss.reset_fight()
	check(boss.is_dying() and boss.is_defeated(), "reset cannot revive defeated boss")
	await seconds(0.7)
	check(is_instance_valid(boss), "boss remains during death throes")
	await seconds(0.95)
	check(not is_instance_valid(boss), "boss retires after death throes")
	var effect := parent.get_node_or_null("Puff") as SpriteVisual
	check(
		effect != null and effect.kind == &"fx_boss_death_light_z1", "physical death creates light"
	)
	var drops := 0
	for node in parent.get_children():
		if node is PickupBase and node.kind == &"ember" and node.timeout == 0.0:
			drops += 1
	check_eq(drops, 1, "physical death creates configured reward")
	await seconds(1.1)
	check(not is_instance_valid(effect), "light frees itself after animation")
	check(not SaveGame.enabled, "save remains disabled")
	await dispose(world)
