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
	check_eq(visual.get_child_count(), 0, "no body, ground shadow or collision under cue")
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
