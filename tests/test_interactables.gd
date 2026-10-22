extends TestCase
## Interactables: bush (cut by the hook), brazier (lit by the hook), gate (opens when all its
## braziers are lit), locked door (one key), persistence through GameState flags.


func run() -> void:
	await _bush()
	await _brazier_and_gate()
	await _locked_door()
	await _visual_hints()


func _swing_at_right(player: Player) -> void:
	Input.action_press(&"move_right")
	await frames(2)
	Input.action_release(&"move_right")
	await frames(8)
	player.velocity = Vector2.ZERO
	Input.action_press(&"attack")
	await frames(1)
	Input.action_release(&"attack")
	await frames(10)


func _bush() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(400, 400))
	var bush := Bush.new()
	bush.drop_roll_override = 0.3
	arena.add_child(bush)
	bush.global_position = Vector2(480, 400)
	var untouched := Bush.new()
	arena.add_child(untouched)
	untouched.global_position = Vector2(400, 700)
	await frames(2)
	await _swing_at_right(player)
	check(not is_instance_valid(bush) or bush.is_cut, "the hook swing cuts a bush")
	check(is_instance_valid(untouched) and not untouched.is_cut, "bushes out of reach stay")
	var drops := arena.get_children().filter(func(n: Node) -> bool: return n is PickupBase)
	check_eq(
		drops.size() + GameState.currency,
		1,
		"a cut bush can drop loot (dropped or already picked up)"
	)
	# An enemy attack does not cut bushes.
	var hit := make_hitbox(arena, untouched.global_position, Layers.Team.ENEMY, 1)
	await frames(4)
	check(is_instance_valid(untouched) and not untouched.is_cut, "enemy hits do not cut bushes")
	hit.deactivate()
	# An explosion does.
	var blast := make_hitbox(arena, untouched.global_position, Layers.Team.NEUTRAL, 4)
	blast.kind = &"explosion"
	await frames(4)
	check(not is_instance_valid(untouched) or untouched.is_cut, "explosions cut bushes")
	blast.deactivate()
	await dispose(arena)


func _brazier_and_gate() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(400, 400))
	var first := Brazier.new()
	first.name = "B1"
	first.brazier_id = &"cave_a"
	arena.add_child(first)
	first.global_position = Vector2(490, 400)
	var second := Brazier.new()
	second.name = "B2"
	second.brazier_id = &"cave_b"
	arena.add_child(second)
	second.global_position = Vector2(900, 400)
	var gate := Gate.new()
	gate.gate_id = &"cave_gate"
	gate.braziers = [NodePath("../B1"), NodePath("../B2")]
	arena.add_child(gate)
	gate.global_position = Vector2(900, 800)
	await frames(2)
	check(not first.lit and not gate.is_open, "braziers start unlit and the gate closed")
	var enemy_hit := make_hitbox(arena, first.global_position, Layers.Team.ENEMY, 1)
	await frames(4)
	check(not first.lit, "only the lamp lights a brazier")
	enemy_hit.deactivate()
	await _swing_at_right(player)
	check(first.lit, "a hook swing lights the brazier")
	check(first.light.enabled, "a lit brazier gives light")
	check(not gate.is_open, "the gate needs every brazier")
	check(GameState.has_flag(&"brazier_cave_a"), "lit state is persistent")
	var spark := make_hitbox(arena, second.global_position, Layers.Team.PLAYER, 2)
	spark.kind = &"hook"
	await frames(4)
	check(second.lit, "the second brazier lights")
	await frames(2)
	check(gate.is_open, "the gate opens when all braziers are lit")
	check(GameState.has_flag(&"gate_cave_gate"), "the gate stays open (flag)")
	spark.deactivate()
	# A fresh instance starts open and lit.
	var gate_again := Gate.new()
	gate_again.gate_id = &"cave_gate"
	arena.add_child(gate_again)
	var brazier_again := Brazier.new()
	brazier_again.brazier_id = &"cave_a"
	arena.add_child(brazier_again)
	await frames(2)
	check(
		gate_again.is_open and brazier_again.lit,
		"opened gates and lit braziers persist across visits"
	)
	await dispose(arena)


func _locked_door() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(500, 600))
	var door := LockedDoor.new()
	door.door_id = &"ow_2_1"
	arena.add_child(door)
	door.global_position = Vector2(500, 400)
	await frames(2)
	Input.action_press(&"move_up")
	await seconds(1.0)
	release_inputs()
	check(player.global_position.y > 400.0, "a locked door blocks the player")
	check(not door.is_open, "it stays closed without a key")
	GameState.add_key()
	await seconds(0.5)
	check(door.is_open, "touching it with a key opens it")
	check_eq(GameState.keys, 0, "it spends exactly one key")
	check(GameState.has_flag(&"door_ow_2_1"), "an opened door stays open (flag)")
	await frames(2)
	Input.action_press(&"move_up")
	await seconds(1.0)
	release_inputs()
	check(player.global_position.y < 400.0, "the player walks through the open door")
	var again := LockedDoor.new()
	again.door_id = &"ow_2_1"
	arena.add_child(again)
	await frames(2)
	check(again.is_open, "an opened door is open on the next visit")
	await dispose(arena)


func _visual_hints() -> void:
	reset_state()
	var arena := make_arena()
	var first := Brazier.new()
	first.name = "B1"
	first.brazier_id = &"hint_a"
	arena.add_child(first)
	first.global_position = Vector2(490, 400)
	var second := Brazier.new()
	second.name = "B2"
	second.brazier_id = &"hint_b"
	arena.add_child(second)
	second.global_position = Vector2(900, 400)
	var gate := Gate.new()
	gate.gate_id = &"hint_gate"
	gate.braziers = [NodePath("../B1"), NodePath("../B2")]
	arena.add_child(gate)
	gate.global_position = Vector2(900, 800)
	await frames(2)
	check(first.ember.visible and first.ember.enabled, "an unlit brazier shows its ember glow")
	check(not first.light.enabled, "the ember is not the flame light")
	check(not gate.rune.visible, "the gate rune is dark while no brazier is lit")
	var energy_a := first.ember.energy
	await seconds(0.7)
	check(absf(first.ember.energy - energy_a) > 0.01, "the ember pulses")
	first.ignite()
	await seconds(0.1)
	check(not first.ember.visible, "a lit brazier has no ember glow")
	check(second.ember.visible, "the other brazier keeps its ember glow")
	check(gate.rune.visible, "the gate rune reacts when one brazier is lit")
	var visual := gate.get_node_or_null(Placeholder.VISUAL_NAME) as Node2D
	await frames(2)
	check(visual != null and absf(visual.position.x) > 0.0, "the gate shakes when one brazier is lit")
	await seconds(0.9)
	check_near(gate.rune.energy, Gate.RUNE_HALF_ENERGY, 0.05, "the rune fades in to half strength")
	check_near(visual.position.x, 0.0, 0.01, "the shake settles")
	check(not gate.is_open, "one lit brazier does not open the gate")
	check(gate._shape != null and not gate._shape.disabled, "the gate stays solid")
	check(not GameState.has_flag(&"gate_hint_gate"), "the gate flag is untouched")
	second.ignite()
	await seconds(0.8)
	check(gate.is_open, "both lit: the gate opens as before")
	check(not gate.rune.visible, "the rune gives way once the gate is open")
	await dispose(arena)
