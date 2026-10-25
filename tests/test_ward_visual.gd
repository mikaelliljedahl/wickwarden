extends TestCase
## Ward presentation follows the actual held action, facing lock and release without owning combat.


func run() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena)
	await frames(2)
	var shield := player.get_node("WardVisual") as Node2D
	check(not shield is Placeholder, "ward uses soft lamp light instead of a placeholder")
	check_eq(
		shield.get_script(),
		load("res://scripts/art/ward_shield.gd"),
		"dedicated presentation helper"
	)
	check(not shield.visible, "ward starts hidden")
	check_eq(shield.position, Vector2.ZERO, "ward keeps the original player centre")
	check_eq(
		shield.material.blend_mode, CanvasItemMaterial.BLEND_MODE_ADD, "light adds to the ground"
	)
	for direction in [Vector2.DOWN, Vector2.UP, Vector2.RIGHT, Vector2.LEFT]:
		player.facing = direction
		Input.action_press(&"ward")
		await frames(2)
		check(player.ward_up and shield.visible, "held ward shows the light")
		var sector: Vector3 = shield.call(&"get_sector")
		check_near(sector.z, 64.0, 0.001, "original 64 px reach")
		check_near(
			rad_to_deg(sector.y - sector.x), Player.WARD_ARC_DEG, 0.001, "original 120 degree arc"
		)
		check_near(
			(sector.x + sector.y) * 0.5, direction.angle(), 0.001, "light faces the ward direction"
		)
		Input.action_press(&"move_right")
		await frames(4)
		check_eq(player.facing, direction, "movement retains the ward facing lock")
		check_eq(shield.get(&"facing"), direction, "light stays locked with player facing")
		check_near(player.velocity.x, 144.0, 1.0, "existing ward movement speed")
		release_inputs()
		await frames(4)
		check(not player.ward_up and not shield.visible, "release hides light with ward state")
	var middle: Color = shield.call(&"_light", 0.86, 0.5)
	var inner: Color = shield.call(&"_light", 0.0, 0.5)
	var edge: Color = shield.call(&"_light", 1.0, 0.5)
	var tip: Color = shield.call(&"_light", 0.86, 0.0)
	check(middle.a > 0.2 and middle.r > middle.b, "readable warm rim")
	check(
		inner.a == 0.0 and edge.a == 0.0 and tip.a == 0.0, "transparent centre, outer edge and tips"
	)
	await dispose(arena)
