extends TestCase
## Spitcap and its spore: stats, spitting at an aligned player, spore damage, ward block, death.

const SPITCAP_SCENE := "res://scenes/enemies/spitcap.tscn"
const SPORE_SCENE := "res://scenes/enemies/spore.tscn"


func run() -> void:
	await _stats()
	await _spits_when_aligned()
	await _spore_hits_player()
	await _ward_blocks_spore()
	await _dies_after_two_damage()


func _stats() -> void:
	reset_state()
	var arena := make_arena()
	var enemy := make_enemy(arena, SPITCAP_SCENE, Vector2(400, 300))
	await frames(2)
	check_eq(enemy.hp, 2, "spitcap has 2 hp")
	check_eq(enemy.contact_damage, 1, "spitcap contact damage is 1")
	check_near(enemy.move_speed, 120.0, 0.01, "spitcap walks at 120 px/s")
	var spore := make_spore(arena, Vector2(400, 300), Vector2.RIGHT)
	await frames(1)
	check_eq(spore.damage, 1, "spore damage is 1")
	check_near(spore.speed, 360.0, 0.01, "spore flies at 360 px/s")
	check(spore.blockable_by_ward, "spore is blockable by the ward")
	await dispose(arena)


func _spits_when_aligned() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(600, 500))
	var enemy := make_enemy(arena, SPITCAP_SCENE, Vector2(340, 500))
	await frames(2)
	# Keep the player 260 px to the right on the same row, whatever the spitcap does.
	var spore: EnemyProjectile = null
	for i in range(480):
		player.global_position = enemy.global_position + Vector2(260, 0)
		await frames(1)
		spore = _first_spore(arena)
		if spore != null:
			break
	check(spore != null, "spitcap spits a spore at an aligned player")
	if spore != null:
		check(spore.direction.dot(Vector2.RIGHT) > 0.99, "spore flies toward the player")
	await dispose(arena)


func _spore_hits_player() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(600, 500))
	await frames(2)
	var before := GameState.health
	var spore := make_spore(arena, player.global_position + Vector2(200, 0), Vector2.LEFT)
	await frames(60)
	check_eq(GameState.health, before - 1, "spore hits the player for 1 half-heart")
	check(not is_instance_valid(spore) or spore.is_destroyed, "spore is destroyed on hit")
	await dispose(arena)


func _ward_blocks_spore() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(600, 500))
	await frames(2)
	await _face(player, &"move_right")
	Input.action_press(&"ward")
	await frames(3)
	check(player.ward_up, "ward is up")
	var before := GameState.health
	var spore := make_spore(arena, player.global_position + Vector2(200, 0), Vector2.LEFT)
	await frames(60)
	check_eq(GameState.health, before, "ward takes no damage from a spore in front")
	check(not is_instance_valid(spore) or spore.is_destroyed, "ward destroys the spore")
	release_inputs()
	await dispose(arena)


func _dies_after_two_damage() -> void:
	reset_state()
	var arena := make_arena()
	var enemy := make_enemy(arena, SPITCAP_SCENE, Vector2(400, 300))
	await frames(2)
	enemy.apply_damage(1, enemy.global_position + Vector2(-30, 0))
	check_eq(enemy.hp, 1, "one damage leaves the spitcap at 1 hp")
	await seconds(0.4)
	enemy.apply_damage(1, enemy.global_position + Vector2(-30, 0))
	await frames(2)
	check(not is_instance_valid(enemy), "spitcap dies after 2 damage")
	await dispose(arena)


## Instantiates a spore in `parent` at `at`, aimed along `dir`. Free it with dispose().
func make_spore(parent: Node, at: Vector2, dir: Vector2) -> EnemyProjectile:
	var scene := load(SPORE_SCENE) as PackedScene
	var spore := scene.instantiate() as EnemyProjectile
	parent.add_child(spore)
	spore.launch(at, dir)
	return spore


func _first_spore(parent: Node) -> EnemyProjectile:
	for child in parent.get_children():
		if child is EnemyProjectile:
			return child as EnemyProjectile
	return null


func _face(player: Player, action: StringName) -> void:
	Input.action_press(action)
	await frames(2)
	Input.action_release(action)
	await frames(6)
	player.velocity = Vector2.ZERO
