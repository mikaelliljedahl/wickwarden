## timeout=180
extends TestCase
## Q7 incremental integration coverage. Real player use, items and travelling hitboxes only.
## Controlled bare arenas and fixed initial positions; this is not a continuous playthrough.
## Pending: remaining tools/props, encounter weaknesses and regular-enemy permutations.

const TOOLS: Array[StringName] = [
	&"cinder_wick", &"tallow_sling", &"lantern_chime", &"reel_line", &"tether_moth", &"glow_jar"
]
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
	print("Q7 PARTIAL: 6 real tools x 7 real gate props; full combat matrix pending")
	for row: Array in GATES:
		for tool: StringName in TOOLS:
			await _gate_pair(row, tool)
	for tool: StringName in [&"cinder_wick", &"tallow_sling", &"lantern_chime", &"tether_moth"]:
		await _snapper_pair(tool)
	for prop: String in ["anchor_ring", "anchor_pocket", "reelable"]:
		for tool: StringName in [&"reel_line", &"tallow_sling", &"lantern_chime"]:
			await _reel_prop_pair(prop, tool)
	for width: float in [120.0, 288.0]:
		await _pit_pair(width, &"skitter_boots")
		await _pit_pair(width, &"reel_line")
	for prop: String in ["heavy_stone", "heavy_stones", "heavy_boulder", "heavy_door"]:
		await _heavy_pair(prop)
	await _mitts_throw_snapper()
	for front: bool in [true, false]:
		await _crab_slug(front)
	for opened: bool in [false, true]:
		await _watcher_slug(opened)
	await _briar_eye_tools()
	await _echo_chime()
	await _thorn_moth_hook()
	await _brute_pot()
	await _squire_pit_moth()
	await _coinwyrm_reel()


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


func _prop(parent: Node, name: String, at: Vector2) -> Node2D:
	var scene := load("res://scenes/world/%s.tscn" % name) as PackedScene
	check(scene != null, "real prop loads: " + name)
	if scene == null:
		return null
	var node := scene.instantiate() as Node2D
	node.position = at
	parent.add_child(node)
	return node


func _equip(player: Player, tool: StringName) -> void:
	GameState.acquire_item(tool)
	GameState.set_active_item(tool)
	player.facing = Vector2.RIGHT


func _reel_prop_pair(prop: String, tool: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 500))
	var target := _prop(arena, prop, Vector2(700, 500))
	if target == null:
		await dispose(arena)
		return
	var hits: Array[StringName] = []
	var signal_name := &"reeled" if prop == "reelable" else &"hooked"
	target.connect(signal_name, func(hit: Hitbox) -> void: hits.append(hit.kind))
	await frames(3)
	_equip(player, tool)
	var label := "%s -> %s" % [tool, prop]
	check(player.use_item(), label + ": real activation")
	await frames(2)
	check(hits.is_empty(), label + ": tip has not travelled 400 px yet")
	await seconds(1.5)
	check_eq(hits.size(), 1 if tool == &"reel_line" else 0, label + ": accepted contacts")
	if not hits.is_empty():
		check_eq(hits[0], &"reel", label + ": real contact kind")
	var pulls := tool == &"reel_line" and prop != "reelable"
	check_near(player.global_position.x, 628.0 if pulls else 300.0, 1.0, label + ": landing")
	check(not player.is_airborne(), label + ": motion settled")
	check(player.hurtbox.enabled, label + ": hurtbox restored")
	print("MATRIX ", label, " contacts=", hits.size())
	await dispose(arena)


func _pit_pair(width: float, tool: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var start := Vector2(300, 500)
	var pit := _prop(arena, "pit", start + Vector2(40 + width * 0.5, 0))
	var ring := _prop(arena, "anchor_ring", start + Vector2(width + 176, 0))
	if pit == null or ring == null:
		await dispose(arena)
		return
	pit.set(&"size", Vector2(width, 384))
	ring.set(&"max_range", 576.0)
	var player := make_player(arena, start)
	await frames(3)
	_equip(player, tool)
	var label := "%s -> %.0f px real pit" % [tool, width]
	check(player.use_item(), label + ": activation")
	var crossed := false
	for i in range(100):
		await frames(1)
		if pit.call(&"holds", player.global_position) and player.is_airborne():
			crossed = true
	check(crossed, label + ": traverses live pit while airborne")
	var falls := tool == &"skitter_boots" and width == 288.0
	check_eq(GameState.health, 4 if falls else 6, label + ": fall damage")
	var landing := 300.0 if falls else 492.0
	if tool == &"reel_line":
		landing = ring.global_position.x - 72.0
	check_near(player.global_position.x, landing, 1.0, label + ": final bank")
	check(not player.is_airborne(), label + ": airborne clears")
	print("MATRIX ", label, " falls=", falls)
	await dispose(arena)


func _heavy_pair(prop: String) -> void:
	reset_state()
	var arena := make_arena()
	var start := Vector2(300, 500)
	var player := make_player(arena, start)
	# Set persistent identity before ready, as a compiled room does.
	var scene := load("res://scenes/world/%s.tscn" % prop) as PackedScene
	check(scene != null, "heavy scene loads: " + prop)
	if scene == null:
		await dispose(arena)
		return
	var stone := scene.instantiate() as Node2D
	stone.set(&"stone_id", &"matrix_heavy")
	stone.position = start + Vector2(100, 0)
	arena.add_child(stone)
	await frames(3)
	_equip(player, &"tallow_sling")
	check(player.use_item(), prop + ": actual slug fired")
	await seconds(0.4)
	check_eq(stone.global_position, start + Vector2(100, 0), prop + ": slug cannot move gate")
	check(not GameState.has_flag(&"moved_matrix_heavy"), prop + ": no false opening flag")
	_equip(player, &"heft_mitts")
	var pushes := prop in ["heavy_boulder", "heavy_door"]
	check(player.use_item(), prop + ": real grab")
	await frames(2)
	if pushes:
		Input.action_press(&"move_right")
	else:
		await seconds(0.4)
	check_eq(bool(stone.call(&"is_carried")), not pushes, prop + ": correct carry mode")
	if pushes:
		await seconds(0.8)
		release_inputs()
		check_near(stone.global_position.x, 496.0, 1.0, prop + ": one 96 px push")
	else:
		Input.action_press(&"use_item")
		await frames(1)
		release_inputs()
		await seconds(0.9)
	check(GameState.has_flag(&"moved_matrix_heavy"), prop + ": persistent opening")
	print("MATRIX mitts -> ", prop, " push=", pushes)
	await dispose(arena)


func _mitts_throw_snapper() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 500))
	var rock := _prop(arena, "liftable_rock", Vector2(372, 500))
	var enemy := make_enemy(arena, "res://scenes/enemies/bramble_snapper.tscn", Vector2(560, 500))
	enemy.drops_enabled = false
	var damage := [0]
	enemy.damaged.connect(func(amount: int) -> void: damage[0] += amount)
	await frames(3)
	_equip(player, &"heft_mitts")
	check(player.use_item(), "mitts/snapper: actual grab")
	await seconds(0.4)
	check(rock != null and rock.call(&"is_carried"), "mitts/snapper: carrying real rock")
	Input.action_press(&"use_item")
	await frames(1)
	release_inputs()
	await seconds(0.9)
	# Target-specific combat matrix 5.9 says Mitts '-' for this target.
	# Keep this strict: the generic thrown damage rule must not hide a target mismatch.
	check_eq(damage[0], 0, "mitts/snapper: matrix requires no damage")
	check(is_instance_valid(enemy) and not enemy.is_dead, "mitts/snapper: matrix requires survival")
	await dispose(arena)


func _crab_slug(front: bool) -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(300, 500))
	var crab := make_enemy(arena, "res://scenes/enemies/brine_crab.tscn", Vector2(540, 500))
	crab.drops_enabled = false
	# Isolated armour fixture: RECOVER freezes facing/position; no guard or HP override.
	crab.set(&"_state", 3)
	crab.set(&"_timer", 5.0)
	crab.set_facing_dir(Vector2.LEFT if front else Vector2.RIGHT)
	var blocks := [0]
	crab.guard_blocked.connect(func(_hit: Hitbox) -> void: blocks[0] += 1)
	await frames(3)
	_equip(player, &"tallow_sling")
	check(player.use_item(), "crab: actual slug fired")
	await seconds(0.6)
	check_eq(crab.hp, 4 if front else 3, "crab: front blocks, rear loses 1 HP")
	check_eq(blocks[0], 1 if front else 0, "crab: guard signal agrees with actual contact")
	check_eq(GameState.slugs, 11, "crab: blocked and landed shots both spend ammo")
	print("MATRIX sling -> crab front=", front, " HP=", crab.hp)
	await dispose(arena)


func _watcher_slug(opened: bool) -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(444, 480))
	var eye := make_enemy(arena, "res://scenes/enemies/watcher_eye.tscn", Vector2(144, 480))
	eye.room_rect = Rect2(96, 96, 1728, 768)
	eye.drops_enabled = false
	await frames(3)
	_equip(player, &"tallow_sling")
	player.facing = Vector2.LEFT
	if opened:
		# Wait for the real axis trigger, telegraph and projectile; no phase setter.
		for i in range(150):
			if not eye.invulnerable:
				break
			await frames(1)
	check_eq(not eye.invulnerable, opened, "watcher: requested natural lid state reached")
	check(player.use_item(), "watcher: actual slug fired")
	await seconds(0.5)
	check_eq(eye.hp, 1 if opened else 2, "watcher: one real slug only damages open lid")
	check_eq(GameState.slugs, 11, "watcher: shot costs one slug")
	print("MATRIX sling -> watcher open=", opened, " HP=", eye.hp)
	await dispose(arena)


func _briar_eye_tools() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(480, 590))
	var scene := load("res://scenes/enemies/bosses/briar_mother.tscn") as PackedScene
	check(scene != null, "Briar Mother scene loads")
	if scene == null:
		await dispose(arena)
		return
	var boss = scene.instantiate()
	boss.intro_time = 0.0
	boss.position = Vector2(960, 192)
	arena.add_child(boss)
	await frames(4)
	var eye: EnemyBase = boss.eyes[0]
	player.place_at(eye.global_position + Vector2(0, 110))
	player.facing = Vector2.UP
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(eye.hp, 4, "Briar lowered eye rejects actual hook")
	await frames(20)
	player.place_at(eye.global_position + Vector2(0, 110))
	_equip(player, &"tallow_sling")
	player.facing = Vector2.UP
	check(player.use_item(), "Briar: actual sling fires")
	await seconds(0.3)
	check_eq(eye.hp, 3, "Briar lowered eye takes one actual slug")
	check_eq(GameState.slugs, 11, "Briar: shot consumes one slug")
	await dispose(arena)


func _echo_chime() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(
		arena, "res://scenes/enemies/minibosses/corrows_echo.tscn", Vector2(800, 480)
	)
	var player := make_player(arena, Vector2(940, 480))
	for i in range(400):
		if enemy.state == enemy.State.GLOW:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.GLOW, "Echo reaches natural flare glow")
	player.place_at(enemy.global_position + Vector2(250, 0))
	_equip(player, &"lantern_chime")
	check(player.use_item(), "Echo: actual chime rings")
	for i in range(35):
		if enemy.is_stunned():
			break
		await frames(1)
	check(enemy.is_stunned(), "Echo: travelling chime interrupts glow")
	check_near(enemy._stun_time, 2.0, 0.05, "Echo: opening lasts two seconds")
	player.place_at(enemy.global_position + Vector2(90, 0))
	player.facing = Vector2.LEFT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 34, "Echo: actual hook deals two during opening")
	await dispose(arena)


func _thorn_moth_hook() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(
		arena, "res://scenes/enemies/minibosses/thorn_warden.tscn", Vector2(850, 480)
	)
	var player := make_player(arena, Vector2(760, 480))
	await frames(2)
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 15, "Thorn Warden: skirt reduces actual hook to one")
	await frames(25)
	player.place_at(enemy.global_position - Vector2(250, 0))
	_equip(player, &"tether_moth")
	check(player.use_item(), "Thorn Warden: actual moth launches")
	for i in range(40):
		if enemy.is_stunned():
			break
		await frames(1)
	check(enemy.is_stunned(), "Thorn Warden: real moth retracts skirt")
	check(enemy._stun_time <= 1.5, "Thorn Warden: moth stun is clamped")
	player.place_at(enemy.global_position - Vector2(90, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 13, "Thorn Warden: actual hook deals two while stunned")
	await dispose(arena)


func _brute_pot() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(
		arena, "res://scenes/enemies/minibosses/abacus_brute.tscn", Vector2(800, 480)
	)
	var player := make_player(arena, Vector2(1400, 480))
	for i in range(300):
		if enemy.state == enemy.State.TELEGRAPH:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.TELEGRAPH, "Brute reaches natural chain warning")
	player.place_at(enemy.global_position + Vector2(200, 0))
	_equip(player, &"pitch_pot")
	player.facing = Vector2.LEFT
	GameState.add_pitch_pots(1)
	check(player.use_item(), "Brute: actual pot placed before spin")
	player.place_at(enemy.global_position + Vector2(400, 0))
	await frames(108)
	check_eq(enemy.rail_hp, 0, "Brute: pot breaks rail during live spin")
	check_eq(enemy.hp, 28, "Brute: rail absorbs blast")
	check_eq(GameState.health, 6, "Brute: retreat avoids blast and spin")
	for i in range(300):
		if enemy.state == enemy.State.WALK:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.WALK, "Brute returns to walking")
	player.place_at(enemy.global_position + Vector2(110, 0))
	player.facing = Vector2.LEFT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 26, "Brute: actual front hook damages unguarded body")
	await dispose(arena)


func _squire_pit_moth() -> void:
	reset_state()
	var arena := make_arena()
	var pit := _prop(arena, "pit", Vector2(960, 480))
	if pit == null:
		await dispose(arena)
		return
	pit.set(&"size", Vector2(96, 576))
	var enemy = make_enemy(
		arena, "res://scenes/enemies/minibosses/pale_squire.tscn", Vector2(720, 480)
	)
	var player := make_player(arena, Vector2(1200, 480))
	for i in range(300):
		if enemy.state == enemy.State.LUNGE:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.LUNGE, "Squire reaches natural lunge")
	_equip(player, &"tether_moth")
	player.facing = Vector2.LEFT
	check(player.use_item(), "Squire: actual moth launched from bank")
	for i in range(60):
		if enemy.state == enemy.State.FALLEN:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.FALLEN, "Squire falls after moth collision")
	check(enemy._over_pit(enemy.global_position), "Squire falls over real pit")
	check_eq(enemy.hp, 10, "Squire fall deals six")
	check(not enemy.hurtbox.enabled, "fallen Squire cannot be hit")
	for i in range(200):
		if enemy.state == enemy.State.RECOVER:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.RECOVER, "Squire returns after fall")
	check_eq(enemy.hp, 10, "Squire retains fall damage on return")
	check_eq(GameState.health, 6, "Squire: player remains safe on bank")
	await dispose(arena)


func _coinwyrm_reel() -> void:
	reset_state()
	var scene := load("res://tests/fixtures/gallery/B08.tscn") as PackedScene
	check(scene != null, "Coinwyrm gallery loads")
	if scene == null:
		return
	var room := scene.instantiate() as Room
	add_child(room)
	room.enter()
	var boss = room.get_node("Enemies/Coinwyrm")
	var player := make_player(room, Vector2(1728, 480))
	# Focus this fixture on tool collision rather than surviving simultaneous attacks.
	player.set_hurtbox_enabled(self, false)
	_equip(player, &"reel_line")
	await seconds(2.5)
	check_eq(boss.plates.size(), 3, "Coinwyrm naturally rears with three plates")
	for expected in [2, 1, 0]:
		if boss.plates.is_empty():
			check(false, "Coinwyrm has a plate for the next shot")
			break
		var plate: Node2D = boss.plates[0]
		player.place_at(plate.global_position + Vector2(0, 200))
		player.facing = Vector2.UP
		check(player.use_item(), "Coinwyrm: actual reel launches")
		await seconds(1.4)
		check_eq(boss.plates.size(), expected, "Coinwyrm: real reel removes one plate")
	check(boss.bare, "Coinwyrm: third plate exposes head")
	check_eq(GameState.currency, 15, "Coinwyrm: three actual plate rewards collected")
	player.place_at(boss.global_position + Vector2(0, 108))
	player.facing = Vector2.UP
	Input.action_press(&"attack")
	await frames(10)
	Input.action_release(&"attack")
	check_eq(boss.hp, 34, "Coinwyrm: actual hook damages exposed head")
	await dispose(room)
