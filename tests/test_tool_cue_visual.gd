extends TestCase
## Real item use owns the cue lifecycle; the helper only draws and accepts facing.

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
	var script := load("res://scripts/art/tool_cue_visual.gd") as GDScript
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
