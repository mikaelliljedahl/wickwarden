extends TestCase
## Glow jar (T05): one jar at a time, the jar lands 288 px ahead, a wall stops it short, the light lies in
## group glow_light and GlowJar.is_lit() reads the 520 px radius, it reveals stand-in props inside the radius
## only, it hides them again after the six seconds of glow, and the scenes load.

const GLOW_JAR_SCENE := "res://scenes/items/glow_jar.tscn"
const JAR_SCENE := "res://scenes/items/jar.tscn"
const GLOW_JAR_SCRIPT := preload("res://scripts/items/glow_jar.gd")
const PROP_SOURCE := """extends Node2D
var reveals := 0
var hides := 0

func reveal() -> void:
	reveals += 1

func hide_again() -> void:
	hides += 1
"""


func run() -> void:
	await _scenes_load()
	await _refuses_second_jar()
	await _lands_288_px_ahead()
	await _wall_stops_jar()
	await _reveals_inside_radius_only()
	await _is_lit_within_radius()
	await _hides_again_after_glow()
	await _light_radius_and_fade()


func _jars() -> Array:
	return get_tree().get_nodes_in_group(&"glow_light")


func _items() -> Array:
	return get_tree().get_nodes_in_group(ItemBase.group_name(&"glow_jar"))


## A stand-in hidden prop: a revealable Node2D that counts reveal() and hide_again() calls.
func _make_prop(parent: Node, at: Vector2) -> Node2D:
	var script := GDScript.new()
	script.source_code = PROP_SOURCE
	script.reload()
	var prop := Node2D.new()
	prop.set_script(script)
	prop.add_to_group(&"revealable")
	parent.add_child(prop)
	prop.global_position = at
	return prop


func _scenes_load() -> void:
	var item := (load(GLOW_JAR_SCENE) as PackedScene).instantiate() as ItemBase
	check(item != null, "the glow jar scene loads and its root extends ItemBase")
	check_eq(item.item_id, &"glow_jar", "the item id is glow_jar")
	if item != null:
		item.free()
	var jar := (load(JAR_SCENE) as PackedScene).instantiate() as Node2D
	check(jar != null, "the jar scene loads")
	if jar != null:
		check(jar.has_method(&"launch"), "the jar scene uses jar.gd")
		jar.free()
	await frames(1)


func _refuses_second_jar() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 500))
	await frames(2)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"glow_jar")
	check(player.use_item(), "the first jar is thrown")
	check_eq(_items().size(), 1, "one glow jar item is in the tree")
	check(not player.use_item(), "a second jar is refused while the first flies")
	check_eq(_items().size(), 1, "the refused jar leaves no item in the tree")
	await seconds(1.0)
	check(not player.use_item(), "a second jar is refused while the first glows")
	check_eq(_items().size(), 1, "still one glow jar item while it glows")
	await seconds(6.0)
	await dispose(arena)


func _lands_288_px_ahead() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 500))
	await frames(2)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"glow_jar")
	check(player.use_item(), "the jar is thrown to the right")
	await seconds(0.2)
	check_eq(_jars().size(), 0, "the jar is not lit while it flies")
	await seconds(0.4)
	check_eq(_jars().size(), 1, "the jar is lit after its flight")
	if _jars().size() == 1:
		var jar := _jars()[0] as Node2D
		check_near(jar.global_position.x, 588.0, 2.0, "the jar lands 288 px ahead of the player")
		check_near(jar.global_position.y, 500.0, 2.0, "the jar lands on the throw line")
	await seconds(6.0)
	await dispose(arena)


func _wall_stops_jar() -> void:
	reset_state()
	var wall := Rect2(Vector2(500, 300), Vector2(32, 400))
	var arena := make_arena([wall])
	var player := make_player(arena, Vector2(300, 500))
	await frames(2)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"glow_jar")
	check(player.use_item(), "the jar is thrown at a wall")
	await seconds(0.7)
	check_eq(_jars().size(), 1, "the jar lands before the wall")
	if _jars().size() == 1:
		var jar := _jars()[0] as Node2D
		check_near(jar.global_position.x, 488.0, 2.0, "the jar stops 12 px short of the wall")
	await seconds(6.0)
	await dispose(arena)


func _reveals_inside_radius_only() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 500))
	await frames(2)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"glow_jar")
	var near := _make_prop(arena, Vector2(860, 500))
	var far := _make_prop(arena, Vector2(1200, 500))
	check(player.use_item(), "the jar is thrown")
	await seconds(1.0)
	check(int(near.get(&"reveals")) > 0, "a prop 272 px from the jar is revealed")
	check_eq(int(far.get(&"reveals")), 0, "a prop 612 px from the jar is not revealed")
	await seconds(6.0)
	await dispose(arena)


func _is_lit_within_radius() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 500))
	await frames(2)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"glow_jar")
	check(not GLOW_JAR_SCRIPT.is_lit(Vector2(588, 500)), "nothing is lit before the jar is thrown")
	check(player.use_item(), "the jar is thrown")
	await seconds(0.6)
	check(GLOW_JAR_SCRIPT.is_lit(Vector2(588 + 519, 500)), "a point 519 px from the jar is lit")
	check(
		not GLOW_JAR_SCRIPT.is_lit(Vector2(588 + 530, 500)), "a point 530 px from the jar is dark"
	)
	check(GLOW_JAR_SCRIPT.is_lit(Vector2(300, 500)), "the player's spot 288 px away is lit too")
	check(not GLOW_JAR_SCRIPT.is_lit(Vector2(-12, 500)), "a point 600 px behind the jar is dark")
	await seconds(6.0)
	await dispose(arena)


func _hides_again_after_glow() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 500))
	await frames(2)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"glow_jar")
	var prop := _make_prop(arena, Vector2(860, 500))
	check(player.use_item(), "the jar is thrown")
	await seconds(4.0)
	check(int(prop.get(&"hides")) == 0, "the prop is still revealed while the jar glows")
	check_eq(_jars().size(), 1, "the jar still glows at 4 s")
	await seconds(3.0)
	check_eq(_jars().size(), 0, "the jar is out after its glow time")
	check_eq(int(prop.get(&"hides")), 1, "the prop is hidden again when the jar goes out")
	check_eq(_items().size(), 0, "the item ends with its jar")
	check(not GLOW_JAR_SCRIPT.is_lit(Vector2(588, 500)), "the spot is dark again")
	check(player.use_item(), "after the jar is out the next jar is thrown")
	await seconds(7.0)
	await dispose(arena)


func _light_radius_and_fade() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 500))
	await frames(2)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"glow_jar")
	check(player.use_item(), "the jar is thrown for the light check")
	await seconds(0.45 + 0.15)
	if _jars().size() == 1:
		var jar := _jars()[0] as Node2D
		var light := jar.get_node_or_null("Glow") as PointLight2D
		check(light != null and light.enabled, "the jar carries an enabled PointLight2D")
		if light != null:
			check_near(
				light.texture_scale,
				LightTexture.scale_for(520.0),
				0.001,
				"the light reaches 520 px"
			)
			check(light.energy < 1.6, "the light is still fading in at 0.15 s")
		await seconds(1.0)
		if light != null:
			check_near(light.energy, 1.6, 0.001, "the light is at full strength after the fade in")
	else:
		check(false, "the jar is lit for the light check")
	await seconds(6.0)
	await dispose(arena)
