extends TestCase
## Real item use owns the cue lifecycle; the helper only draws and accepts facing.

const CUE_SCRIPT := "res://scripts/art/tool_cue_visual.gd"
const TOOLS: Array[StringName] = [
	&"cinder_wick", &"tallow_sling", &"heft_mitts", &"lantern_chime", &"skitter_boots"
]
const DIRECTIONS: Array[Vector2] = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]


func run() -> void:
	SaveGame.enabled = false
	for tool in TOOLS:
		for direction in DIRECTIONS:
			await _use_cue(tool, direction)
	await _missing_cinder_art()
	await _missing_sling_art()
	await _missing_dust_art()
	await _missing_mitts_art()


func _use_cue(tool: StringName, direction: Vector2) -> void:
	reset_state()
	var arena := make_arena()
	var hero := make_player(arena, Vector2(700, 500))
	await frames(2)
	GameState.acquire_item(tool)
	GameState.slugs = 10
	hero.facing = direction
	Input.action_press(&"use_item")
	check(hero.use_item(), "%s activates in %s" % [tool, direction])
	var items := get_tree().get_nodes_in_group(ItemBase.group_name(tool))
	check_eq(items.size(), 1, "one real item owns the cue")
	var item := items[0] as Node2D
	var visual := item.get_node("Visual") as Node2D
	check(not visual is Placeholder and not visual is SpriteVisual, "cue uses soft drawing")
	check_eq(
		visual.get_script().resource_path,
		"res://scripts/art/tool_cue_visual.gd",
		"the cue has the rendering helper"
	)
	check_eq(visual.get(&"_facing"), direction, "actual use passes the facing")
	check(visual.visible, "cue is initially visible")
	if tool == &"cinder_wick":
		check_eq(visual.get_child_count(), 1, "cinder cue has only its painted child")
		var painted := visual.get_node_or_null("CinderCast") as Sprite2D
		check(painted != null, "the only cinder child is the painted sprite")
		if painted != null:
			check_eq(painted.get_class(), "Sprite2D", "painted child is non-physical")
			check_eq(painted.get_child_count(), 0, "painted child has no body, shadow or collision")
			check(painted.texture != null, "painted child has the approved texture")
			if painted.texture != null:
				check_eq(
					painted.texture.resource_path,
					"res://assets/sprites/fx_cinder_cast_z1.png",
					"painted child uses the cinder cast asset"
				)
			check_near(painted.rotation, direction.angle(), 0.001, "painted cue faces the cast")
	elif tool == &"tallow_sling":
		check_eq(visual.get_child_count(), 1, "sling has only its painted trail")
		var trail := visual.get_node_or_null("SlingCast") as Sprite2D
		check(trail != null, "sling trail is non-physical")
		if trail != null:
			check_eq(trail.get_child_count(), 0, "sling trail has no collision or projectile")
			check(trail.texture != null, "sling trail has the painted texture")
			check(trail.material is ShaderMaterial, "sling trail has the neutral softening material")
			check_near(trail.rotation, direction.angle(), 0.001, "sling trail faces the cast")
	elif tool == &"skitter_boots":
		var puff := visual.get_node_or_null("LeapDust") as Sprite2D
		check(puff != null and puff.texture != null, "accepted leap creates painted dust")
		check_eq(visual.get_child_count(), 1, "boots have only the start puff")
	else:
		check_eq(visual.get_child_count(), 0, "other cues have no body, shadow or collision")
	var definition := Placeholder.definition_of(tool)
	check_eq(visual.get(&"_radius"), definition.radius, "cue preserves original reach")
	Input.action_release(&"use_item")
	await seconds(0.3)
	if tool in [&"cinder_wick", &"tallow_sling"]:
		check(not visual.visible, "existing windup/recoil hides the cue")
	elif tool == &"heft_mitts":
		check(not is_instance_valid(item), "empty grab ends on its original lockout")
	else:
		check(is_instance_valid(item), "wave/leap cooldown still owns its cue")
	await dispose(arena)


func _missing_cinder_art() -> void:
	var script := load(CUE_SCRIPT) as GDScript
	if script == null:
		check(false, "cue helper loads for missing-art fallback")
		return
	var visual := script.new() as Node2D
	visual.set(&"_kind", &"cinder_wick")
	visual.set(&"art_path", "res://missing-cinder-cast.png")
	visual.call(&"set_facing", Vector2.LEFT)
	add_child(visual)
	check_eq(visual.get_child_count(), 0, "missing art has no body, shadow or collision")
	check(visual.get(&"_painted") == null, "missing art retains the geometric drawing path")
	check(visual.visible, "missing-art cue remains visible")
	check_eq(visual.get(&"_facing"), Vector2.LEFT, "fallback retains the cast facing")
	visual.queue_free()
	await frames(1)


func _missing_dust_art() -> void:
	var script := load(CUE_SCRIPT) as GDScript
	var visual := script.new() as Node2D
	visual.set(&"_kind", &"skitter_boots")
	visual.set(&"dust_path", "res://missing-dust.png")
	add_child(visual)
	visual.call(&"show_leap_dust", Vector2.ZERO)
	check_eq(visual.get_child_count(), 0, "missing dust art does not create a child")
	visual.queue_free()
	await frames(1)


func _missing_sling_art() -> void:
	var script := load(CUE_SCRIPT) as GDScript
	var visual := script.new() as Node2D
	visual.set(&"_kind", &"tallow_sling")
	visual.set(&"sling_art_path", "res://missing-sling-cast.png")
	visual.call(&"set_facing", Vector2.UP)
	add_child(visual)
	check_eq(visual.get_child_count(), 0, "missing sling art has no physical child")
	check(visual.get(&"_painted") == null, "missing sling art retains the geometric fallback")
	check(visual.visible, "missing sling art leaves the cue visible")
	check_eq(visual.get(&"_facing"), Vector2.UP, "sling fallback retains facing")
	visual.queue_free()
	await frames(1)


func _missing_mitts_art() -> void:
	var script := load(CUE_SCRIPT) as GDScript
	var visual := script.new() as Node2D
	visual.set(&"_kind", &"heft_mitts")
	visual.set(&"mitts_art_path", "res://missing-mitts-effort.png")
	add_child(visual)
	visual.call(&"show_mitts_effort", Vector2.ZERO)
	check_eq(visual.get_child_count(), 0, "missing mitts art produces no physical child")
	visual.queue_free()
	await frames(1)
