## timeout=180
extends TestCase
## Q7 incremental integration coverage. Real player use, items and travelling hitboxes only.
## Controlled bare arenas and fixed initial positions; this is not a continuous playthrough.
## Pending: remaining tools/props, regular enemy matrix, all boss/miniboss weakness challenges,
## armour/open-state permutations, ward, stun and provenance checks beyond these gate pairs.

const TOOLS: Array[StringName] = [&"cinder_wick", &"tallow_sling", &"lantern_chime"]
const GATES := [
	["thorn_hedge", &"burn_id", &"cinder_wick", &"is_open", "burned_"],
	["thorn_wall", &"burn_id", &"cinder_wick", &"is_open", "burned_"],
	["thorn_door", &"burn_id", &"cinder_wick", &"is_open", "burned_"],
	["eye_switch", &"eye_id", &"tallow_sling", &"is_on", "eye_"],
	["resonance_stone", &"resonance_id", &"lantern_chime", &"is_awake", "resonated_"],
	["resonance_door", &"resonance_id", &"lantern_chime", &"is_awake", "resonated_"],
	["resonance_vault", &"resonance_id", &"lantern_chime", &"is_awake", "resonated_"],
]


func run() -> void:
	print("Q7 PARTIAL: 3 real tools x 7 real gate props; full combat matrix pending")
	for row: Array in GATES:
		for tool: StringName in TOOLS:
			await _gate_pair(row, tool)
	for tool: StringName in [&"cinder_wick", &"tallow_sling", &"lantern_chime", &"tether_moth"]:
		await _snapper_pair(tool)


func _gate(parent: Node, row: Array, at: Vector2) -> Node2D:
	var path := "res://scenes/world/%s.tscn" % row[0]
	var scene := load(path) as PackedScene
	check(scene != null, "real gate scene loads: " + path)
	if scene == null:
		return null
	var gate := scene.instantiate() as Node2D
	gate.set(row[1], &"matrix")
	parent.add_child(gate)
	gate.global_position = at
	return gate


func _gate_pair(row: Array, tool: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 500))
	var gate := _gate(arena, row, Vector2(540, 500))
	if gate == null:
		await dispose(arena)
		return
	var blockers: Array[Node2D] = []
	if row[0] == "eye_switch":
		for name: String in ["eye_portcullis", "eye_cell"]:
			var blocker_row := [name, &"eye_id"]
			blockers.append(_gate(arena, blocker_row, Vector2(900, 700)))
	await frames(3)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(tool)
	GameState.set_active_item(tool)
	var label := "%s -> %s" % [tool, row[0]]
	check(not bool(gate.get(row[3])), label + ": initially closed")
	check(player.use_item(), label + ": real player activates tool")
	await frames(2)
	check(not bool(gate.get(row[3])), label + ": no remote instant activation")
	await seconds(2.0)
	var opens: bool = tool == row[2]
	check_eq(bool(gate.get(row[3])), opens, label + ": gate result")
	var flag := StringName(String(row[4]) + "matrix")
	check_eq(GameState.has_flag(flag), opens, label + ": persistent flag")
	for blocker: Node2D in blockers:
		if blocker == null:
			continue
		check_eq(bool(blocker.get(&"is_open")), opens, label + ": linked blocker")
		var shape := blocker.get_node("Shape") as CollisionShape2D
		check_eq(shape.disabled, opens, label + ": blocker collision")
	if row[0] != "eye_switch":
		var shape := gate.get_node("Shape") as CollisionShape2D
		check_eq(shape.disabled, opens, label + ": gate collision")
	print("MATRIX ", label, " expected=", opens)
	await dispose(arena)
	# Revisit with the same in-memory GameState flag; no disk save is read or written.
	arena = make_arena()
	gate = _gate(arena, row, Vector2(540, 500))
	await frames(3)
	if gate != null:
		check_eq(bool(gate.get(row[3])), opens, label + ": revisit state")
	await dispose(arena)


func _snapper_pair(tool: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 500))
	var path := "res://scenes/enemies/bramble_snapper.tscn"
	var scene := load(path) as PackedScene
	check(scene != null, "real snapper scene loads")
	if scene == null:
		await dispose(arena)
		return
	var enemy := scene.instantiate() as EnemyBase
	# The real snapper is rooted. Only initial placement and loot suppression are controlled.
	enemy.drops_enabled = false
	arena.add_child(enemy)
	enemy.global_position = Vector2(540, 500)
	var observations := {"death": false, "damage": 0, "stun": false}
	enemy.died.connect(func(_who: EnemyBase) -> void: observations["death"] = true)
	enemy.damaged.connect(func(amount: int) -> void: observations["damage"] += amount)
	enemy.stunned.connect(func(_time: float) -> void: observations["stun"] = true)
	await frames(3)
	player.facing = Vector2.RIGHT
	GameState.acquire_item(tool)
	GameState.set_active_item(tool)
	var label := "%s -> rooted bramble snapper" % tool
	check_eq(enemy.hp, 3, label + ": initial HP")
	check(player.use_item(), label + ": real activation")
	await frames(2)
	check_eq(enemy.hp, 3, label + ": no instant remote damage")
	await seconds(2.0)
	if tool == &"cinder_wick":
		check(observations["death"], label + ": fire burn kills")
	elif is_instance_valid(enemy):
		check_eq(enemy.hp, 2 if tool == &"tallow_sling" else 3, label + ": HP result")
		check(not enemy.is_stunned(), label + ": no residual stun")
	else:
		check(false, label + ": unexpected death")
	check(not observations["stun"], label + ": stun immune throughout flight")
	if tool == &"tallow_sling":
		check_eq(observations["damage"], 1, label + ": one actual slug damage")
		check_eq(GameState.slugs, 11, label + ": one slug spent")
	print("MATRIX ", label, " death=", observations["death"], " damage=", observations["damage"])
	await dispose(arena)
