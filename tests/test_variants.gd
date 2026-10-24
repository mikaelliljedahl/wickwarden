extends TestCase
## Look variants (P13): the cut screens are Bush scenes with a look, the brittle rocks are CrackedWall
## with a rock look. Every variant has its own Visual kind, is cut like the original (hook, flare,
## explosion) and ignores enemy hits; the brittle rocks open to a blast in range, like the cracked wall.

const BUSH_VARIANTS := [
	"reed_cluster",
	"rush_wall",
	"moss_wall",
	"dry_vine_screen",
	"bush_cluster",
]
const BUSH_SCENE := "res://scenes/world/%s.tscn"
const ROCKS_SCENE := "res://scenes/world/brittle_rocks.tscn"
const CRACKED_SCENE := "res://scenes/world/cracked_wall.tscn"
const SPACING := 200.0
const AT := Vector2(400, 400)


func run() -> void:
	_bush_scenes_have_their_look()
	_default_bush_is_unchanged()
	await _every_variant_is_cut_like_the_bush()
	_brittle_rocks_have_their_look()
	await _brittle_rocks_open_to_a_blast()


## Builds a Bush scene of `variant` (untyped: the script is a plain node in this test).
func _make_bush(variant: String) -> Variant:
	var scene := load(BUSH_SCENE % variant) as PackedScene
	return scene.instantiate()


func _bush_scenes_have_their_look() -> void:
	for variant in BUSH_VARIANTS:
		var bush: Variant = _make_bush(variant)
		check(bush is Bush, "%s is a Bush" % variant)
		check_eq(bush.variant, StringName(variant), "%s sets its variant" % variant)
		check(Placeholder.has_kind(StringName(variant)), "%s has a registered look" % variant)
		bush.free()


func _default_bush_is_unchanged() -> void:
	var bush := Bush.new()
	check_eq(bush.variant, &"bush", "a plain Bush keeps the bush look")
	check(Placeholder.has_kind(&"bush"), "the bush look is still in KINDS")
	bush.free()


## A Hitbox of `kind` and team `team` at `at`, active at once. Free it with dispose().
func _make_hit(parent: Node, kind: StringName, team: Layers.Team, at: Vector2) -> Hitbox:
	var hitbox := Hitbox.new()
	hitbox.kind = kind
	hitbox.team = team
	hitbox.add_circle(24.0)
	parent.add_child(hitbox)
	hitbox.global_position = at
	hitbox.activate()
	return hitbox


func _every_variant_is_cut_like_the_bush() -> void:
	reset_state()
	var arena := make_arena()
	# Row 0: a bush hit by the hook, row 1: a bush hit by an explosion, row 2: a bush hit by an enemy.
	var rows := [&"hook", &"explosion", &"contact"]
	var bushes: Array = []
	var hits: Array[Hitbox] = []
	for i in BUSH_VARIANTS.size():
		var variant: String = BUSH_VARIANTS[i]
		var column := Vector2(SPACING * i, 0)
		var row_bushes: Array = []
		for row in rows.size():
			var at: Vector2 = AT + column + Vector2(0, SPACING * row)
			var bush: Variant = _make_bush(variant)
			arena.add_child(bush)
			bush.global_position = at
			row_bushes.append(bush)
		bushes.append(row_bushes)
	await frames(2)
	for i in BUSH_VARIANTS.size():
		var visual: Node = bushes[i][0].get_node("Visual")
		check_eq(
			visual.get("kind"),
			StringName(BUSH_VARIANTS[i]),
			"%s draws its own look" % BUSH_VARIANTS[i]
		)
	for i in BUSH_VARIANTS.size():
		var column := Vector2(SPACING * i, 0)
		for row in rows.size():
			var team := Layers.Team.ENEMY if rows[row] == &"contact" else Layers.Team.PLAYER
			if rows[row] == &"explosion":
				team = Layers.Team.NEUTRAL
			var at: Vector2 = AT + column + Vector2(0, SPACING * row)
			hits.append(_make_hit(arena, rows[row], team, at))
	await frames(4)
	for i in BUSH_VARIANTS.size():
		var variant: String = BUSH_VARIANTS[i]
		var row_bushes: Array = bushes[i]
		var hooked: Variant = row_bushes[0]
		var blasted: Variant = row_bushes[1]
		var enemy_hit: Variant = row_bushes[2]
		check(not is_instance_valid(hooked) or hooked.is_cut, "the hook cuts a %s" % variant)
		check(not is_instance_valid(blasted) or blasted.is_cut, "an explosion cuts a %s" % variant)
		check(
			is_instance_valid(enemy_hit) and not enemy_hit.is_cut,
			"an enemy hit does not cut a %s" % variant
		)
	for hit in hits:
		hit.deactivate()
	await dispose(arena)


func _brittle_rocks_have_their_look() -> void:
	var scene := load(ROCKS_SCENE) as PackedScene
	var rocks: Variant = scene.instantiate()
	check(rocks is Node2D and rocks.get_script() != null, "brittle rocks load")
	check_eq(rocks.variant, &"brittle_rocks", "brittle rocks set their variant")
	check(Placeholder.has_kind(&"brittle_rocks"), "brittle rocks have a registered look")
	rocks.free()
	var wall := (load(CRACKED_SCENE) as PackedScene).instantiate()
	check_eq(wall.get("variant"), &"cracked_wall", "a cracked wall keeps its look")
	wall.free()


func _brittle_rocks_open_to_a_blast() -> void:
	reset_state()
	var arena := make_arena()
	var rocks: Variant = (load(ROCKS_SCENE) as PackedScene).instantiate()
	rocks.set(&"wall_id", &"test_rocks")
	arena.add_child(rocks)
	rocks.global_position = AT
	var far: Variant = (load(ROCKS_SCENE) as PackedScene).instantiate()
	far.set(&"wall_id", &"test_rocks_far")
	arena.add_child(far)
	far.global_position = AT + Vector2(0, 400)
	await frames(2)
	check(rocks.is_in_group(&"explodable"), "brittle rocks are in group explodable")
	check(not rocks.is_open and not far.is_open, "brittle rocks start closed")
	rocks.on_explosion(AT + Vector2(120, 0), 100.0)
	far.on_explosion(AT + Vector2(0, 0), 60.0)
	check(not far.is_open, "a blast out of range leaves the rocks closed")
	check(rocks.is_open, "a blast in range opens the rocks")
	check(GameState.has_flag(&"cracked_test_rocks"), "opening sets the cracked_<id> flag")
	await frames(2)
	check((rocks.get_node("Shape") as CollisionShape2D).disabled, "open rocks have no collision")
	await dispose(arena)
