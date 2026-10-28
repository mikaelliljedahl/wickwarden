## timeout=180
# gdlint: disable=max-file-lines
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
	print("Q7 PARTIAL: selected real-tool gate and encounter cases; permutations remain")
	for entry: String in [
		"Captain: moth/hook", "Thorn Warden: moth/hook, wick", "Lurker: moth/hook",
		"Mauler: hook/slag", "Mirror Warden: hook/braziers", "Choir Warden: moth/hook",
		"Squire: moth/pit", "Brute: pot/hook", "Automaton: moth/hook", "Echo: chime/hook",
		"Kilnkeeper: wick", "Briar Mother: sling eye", "Tidewick: raft/hook",
		"Colossus: mitts/shard", "Archivist: jar/hook", "Dirge: chime/hook",
		"Knight: boots/hook", "Coinwyrm: reel/hook", "Lock Warden: sling/pot plate",
		"Unlit: sling/wick/reel/hook",
	]:
		print("ENCOUNTER MATRIX ", entry)
	for row: Array in GATES:
		for tool: StringName in TOOLS:
			await _gate_pair(row, tool)
		for tool: StringName in [&"hook", &"flare", &"pitch_pot"]:
			await _gate_base_weapon_pair(row, tool)
		if row[0] in ["thorn_hedge", "thorn_wall", "thorn_door", "eye_switch"]:
			await _gate_base_weapon_pair(row, &"reel_line")
	for prop: String in ["hidden_seam", "hidden_stairs", "sealed_seam"]:
		for tool: StringName in [&"tallow_sling", &"lantern_chime", &"glow_jar"]:
			await _seam_pair(prop, tool)
		for tool: StringName in [&"glow_jar", &"lantern_chime"]:
			await _seam_light_contact(prop, tool)
	for tool: StringName in [&"tallow_sling", &"cinder_wick", &"hook"]:
		await _tap_wall_pair(tool)
	for tool: StringName in [&"hook", &"flare", &"pitch_pot"]:
		await _tap_wall_contact(tool)
	for tool: StringName in [&"hook", &"tallow_sling", &"cinder_wick", &"flare"]:
		await _wax_seal_pair(tool)
	for tool: StringName in [&"hook", &"flare", &"pitch_pot"]:
		await _wax_seal_contact(tool)
	for scope: StringName in [&"ow", &"c1"]:
		for tool: StringName in [&"tether_moth", &"reel_line"]:
			await _grate_key_pair(tool, scope)
	for tool: StringName in [&"pitch_pot", &"tallow_sling", &"cinder_wick", &"flare"]:
		for prop: String in ["cracked_wall", "brittle_rocks"]:
			await _cracked_wall_pair(tool, prop)
	for prop: String in ["cracked_wall", "brittle_rocks"]:
		for tool: StringName in [&"flare", &"pitch_pot"]:
			await _cracked_contact(prop, tool)
	for prop: String in ["reed_cluster", "rush_wall", "moss_wall", "dry_vine_screen", "bush_cluster"]:
		for tool: StringName in [&"hook", &"tallow_sling", &"cinder_wick", &"pitch_pot"]:
			await _cut_screen_pair(prop, tool)
	await _cut_screen_flare_and_reel()
	await _ward_plate_tools()
	await _brazier_gate_tools()
	for tool: StringName in [&"cinder_wick", &"tallow_sling"]:
		await _brazier_contact_revisit(tool)
	await _scoped_key_gate()
	await _boss_key_gate()
	await _ninth_fragment_gate()
	await _mooring_water_gate()
	await _flooded_room_pair()
	for edge: Array in [[&"ow_4_2", &"ow_4_3"], [&"ow_4_5", &"ow_4_6"]]:
		await _oneway_drop_pair(edge[0], edge[1])
	for tool: StringName in [&"skitter_boots", &"tallow_sling"]:
		await _ravine_pair(tool)
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
		for tool: StringName in [&"hook", &"flare", &"pitch_pot"]:
			await _heavy_wrong_weapon(prop, tool)
	await _mitts_throw_snapper()
	for front: bool in [true, false]:
		await _crab_slug(front)
	for opened: bool in [false, true]:
		await _watcher_slug(opened)
	await _briar_eye_tools()
	await _echo_chime()
	await _echo_chime_outside_glow()
	await _thorn_moth_hook()
	await _thorn_wick()
	await _brute_pot()
	await _brute_flare_rail()
	await _squire_pit_moth()
	await _coinwyrm_reel()
	await _kiln_wick()
	await _kiln_phase_two_wick()
	await _choir_warden_moth()
	await _automaton_moth()
	await _automaton_live_jet_tools()
	await _lurker_moth()
	await _lurker_natural_moth()
	await _captain_moth()
	await _captain_natural_bash_sling()
	await _lock_plate_tools()
	await _mauler_slag_hook()
	await _knight_boots()
	await _colossus_shard()
	await _mirror_braziers()
	await _dirge_chime()
	await _dirge_natural_chime()
	await _archivist_jar()
	await _tidewick_raft()
	await _unlit_tools()


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


func _seam_pair(prop: String, tool: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var seam := _gate(arena, [prop, &"seam_id"], Vector2(400, 400))
	if seam == null:
		await dispose(arena)
		return
	var player := make_player(arena, Vector2(400, 650))
	await frames(3)
	_equip(player, tool)
	player.facing = Vector2.UP
	check(player.use_item(), "%s -> %s: real activation" % [tool, prop])
	await seconds(1.8)
	var opens := tool == &"glow_jar"
	check_eq(seam.get(&"is_revealed"), opens, "%s -> %s: permanent result" % [tool, prop])
	check_eq(GameState.has_flag(&"revealed_matrix"), opens, "%s -> %s: flag" % [tool, prop])
	check_eq(
		(seam.get_node("Body/Shape") as CollisionShape2D).disabled,
		opens,
		"%s -> %s: blocker" % [tool, prop]
	)
	await dispose(arena)
	# Recreate the real scene using the same in-memory persistent flag.
	arena = make_arena()
	seam = _gate(arena, [prop, &"seam_id"], Vector2(400, 400))
	await frames(3)
	if seam != null:
		check_eq(seam.get(&"is_revealed"), opens, "%s -> %s: revisit" % [tool, prop])
	await dispose(arena)


func _seam_light_contact(prop: String, tool: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var seam := _gate(arena, [prop, &"seam_id"], Vector2(400, 400))
	if seam == null:
		await dispose(arena)
		return
	var player := make_player(arena, Vector2(400, 650))
	await frames(3)
	_equip(player, tool)
	player.facing = Vector2.UP
	var label := "%s -> %s" % [tool, prop]
	check(player.use_item(), label + ": real item activated")
	var reached := false
	var shown_before_permanent := false
	for i in range(110):
		await frames(1)
		if tool == &"glow_jar":
			for light in get_tree().get_nodes_in_group(&"glow_light"):
				if light.is_lit() and light.global_position.distance_to(seam.global_position) <= 520:
					reached = true
			shown_before_permanent = shown_before_permanent or (
				bool(seam.get(&"is_shown")) and not bool(seam.get(&"is_revealed"))
			)
		else:
			for wave in get_tree().get_nodes_in_group(&"chime_waves"):
				if wave.current_radius() >= wave.global_position.distance_to(seam.global_position):
					reached = true
	var opens := tool == &"glow_jar"
	check(reached, label + ": actual light or chime reaches opening")
	if opens:
		check(shown_before_permanent, label + ": briefly shown before permanent reveal")
	check_eq(bool(seam.get(&"is_revealed")), opens, label + ": persistent reveal")
	check_eq(GameState.has_flag(&"revealed_matrix"), opens, label + ": flag")
	check_eq((seam.get_node("Body/Shape") as CollisionShape2D).disabled, opens, label + ": solid")
	print("MATRIX ", label, " reaches=", reached, " opens=", opens)
	await dispose(arena)
	arena = make_arena()
	seam = _gate(arena, [prop, &"seam_id"], Vector2(400, 400))
	await frames(3)
	if seam != null:
		check_eq(bool(seam.get(&"is_revealed")), opens, label + ": revisit reveal")
		check_eq(GameState.has_flag(&"revealed_matrix"), opens, label + ": revisit flag")
		check_eq((seam.get_node("Body/Shape") as CollisionShape2D).disabled, opens,
			label + ": revisit solid")
	await dispose(arena)


func _tap_wall_pair(tool: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var seam := _gate(arena, ["hook_tap_wall", &"seam_id"], Vector2(400, 400))
	if seam == null:
		await dispose(arena)
		return
	var player := make_player(arena, Vector2(400, 500 if tool == &"hook" else 650))
	await frames(3)
	player.facing = Vector2.UP
	if tool == &"hook":
		Input.action_press(&"attack")
		await frames(8)
		Input.action_release(&"attack")
	else:
		_equip(player, tool)
		player.facing = Vector2.UP
		check(player.use_item(), "%s -> hook wall: real activation" % tool)
	await seconds(1.0)
	var opens := tool == &"hook"
	check_eq(seam.get(&"is_revealed"), opens, "%s -> hook wall: result" % tool)
	check_eq(GameState.has_flag(&"revealed_matrix"), opens, "%s -> hook wall: flag" % tool)
	check_eq(
		(seam.get_node("Body/Shape") as CollisionShape2D).disabled,
		opens,
		"%s -> hook wall: blocker" % tool
	)
	await dispose(arena)


func _tap_wall_contact(tool: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var wall := _gate(arena, ["hook_tap_wall", &"seam_id"], Vector2(400, 400))
	if wall == null:
		await dispose(arena)
		return
	var start := Vector2(400, 500 if tool == &"hook" else 650)
	if tool == &"pitch_pot":
		start = Vector2(400, 600)
	var player := make_player(arena, start)
	player.set_hurtbox_enabled(self, false)
	var hurtbox := wall.get_node("Hurtbox") as Hurtbox
	var accepted: Array[StringName] = []
	hurtbox.hurt.connect(func(hit: Hitbox) -> void: accepted.append(hit.kind))
	await frames(3)
	player.facing = Vector2.UP
	var label := "%s -> hook-tap wall" % tool
	var kind := &"explosion" if tool == &"pitch_pot" else tool
	var contact := false
	var flares := [0]
	player.flare_fired.connect(func() -> void: flares[0] += 1)
	if tool == &"pitch_pot":
		_equip(player, tool)
		player.facing = Vector2.UP
		GameState.add_pitch_pots(1)
		check(player.use_item(), label + ": actual pot placed")
	elif tool == &"flare":
		# The attack press also swings the hook. Charge well outside its reach.
		Input.action_press(&"attack")
		var initial_hook_contact := false
		for i in range(60):
			await frames(1)
			initial_hook_contact = initial_hook_contact or _gate_weapon_overlaps(wall, &"hook")
		check(not initial_hook_contact, label + ": initial hook misses")
		check(accepted.is_empty() and not wall.get(&"is_revealed"), label + ": wall stays closed")
		check(player.charge_ready, label + ": charge ready")
		player.global_position = Vector2(400, 500)
		Input.action_release(&"attack")
	else:
		Input.action_press(&"attack")
		await frames(8)
		Input.action_release(&"attack")
	for i in range(120):
		await frames(1)
		contact = contact or _gate_weapon_overlaps(wall, kind)
	var opens := tool == &"hook"
	if tool == &"flare":
		check_eq(flares[0], 1, label + ": charged flare fired")
	if opens:
		check_eq(accepted, [&"hook"], label + ": real hook accepted")
	else:
		check(contact, label + ": actual wrong-tool hitbox overlaps wall")
		check(accepted.is_empty(), label + ": wrong hit is rejected")
	check_eq(wall.get(&"is_revealed"), opens, label + ": opening")
	check_eq(GameState.has_flag(&"revealed_matrix"), opens, label + ": flag")
	check_eq((wall.get_node("Body/Shape") as CollisionShape2D).disabled, opens, label + ": solid")
	print("MATRIX ", label, " opens=", opens, " contact=", contact or not accepted.is_empty())
	await dispose(arena)
	arena = make_arena()
	wall = _gate(arena, ["hook_tap_wall", &"seam_id"], Vector2(400, 400))
	await frames(3)
	if wall != null:
		check_eq(wall.get(&"is_revealed"), opens, label + ": revisit opening")
		check_eq(GameState.has_flag(&"revealed_matrix"), opens, label + ": revisit flag")
		check_eq((wall.get_node("Body/Shape") as CollisionShape2D).disabled, opens,
			label + ": revisit solid")
	await dispose(arena)


func _wax_seal_pair(tool: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var seal := _gate(arena, ["wax_seal", &"seal_id"], Vector2(540, 500))
	if seal == null:
		await dispose(arena)
		return
	var player := make_player(arena, Vector2(400 if tool in [&"hook", &"flare"] else 300, 500))
	await frames(3)
	player.facing = Vector2.RIGHT
	if tool in [&"hook", &"flare"]:
		Input.action_press(&"attack")
		await frames(60 if tool == &"flare" else 8)
		Input.action_release(&"attack")
	else:
		_equip(player, tool)
		check(player.use_item(), "%s -> wax seal: real activation" % tool)
	await seconds(1.0)
	var opens := tool == &"flare"
	check_eq(seal.get(&"is_open"), opens, "%s -> wax seal: result" % tool)
	check_eq(GameState.has_flag(&"melted_matrix"), opens, "%s -> wax seal: flag" % tool)
	check_eq(
		(seal.get_node("Shape") as CollisionShape2D).disabled,
		opens,
		"%s -> wax seal: blocker" % tool
	)
	await dispose(arena)


func _wax_seal_contact(tool: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var seal := _gate(arena, ["wax_seal", &"seal_id"], Vector2(540, 500))
	if seal == null:
		await dispose(arena)
		return
	var start := Vector2(400, 500) if tool == &"hook" else Vector2(300, 500)
	if tool == &"pitch_pot":
		start = Vector2(340, 500)
	var player := make_player(arena, start)
	player.set_hurtbox_enabled(self, false)
	var accepted: Array[StringName] = []
	var hurtbox := seal.get_node("Hurtbox") as Hurtbox
	hurtbox.hurt.connect(func(hit: Hitbox) -> void: accepted.append(hit.kind))
	var flares := [0]
	player.flare_fired.connect(func() -> void: flares[0] += 1)
	await frames(3)
	player.facing = Vector2.RIGHT
	var label := "%s -> wax seal" % tool
	var kind := &"explosion" if tool == &"pitch_pot" else tool
	var contact := false
	if tool == &"pitch_pot":
		_equip(player, tool)
		GameState.add_pitch_pots(1)
		check(player.use_item(), label + ": actual pot placed")
	elif tool == &"flare":
		# A charge starts with a hook swing; keep that swing away from the seal.
		Input.action_press(&"attack")
		var initial_hook_contact := false
		for i in range(60):
			await frames(1)
			initial_hook_contact = initial_hook_contact or _gate_weapon_overlaps(seal, &"hook")
		check(not initial_hook_contact, label + ": initial hook misses")
		check(not seal.get(&"is_open") and accepted.is_empty(), label + ": still sealed")
		check(player.charge_ready, label + ": flare charged")
		player.global_position = Vector2(400, 500)
		Input.action_release(&"attack")
	else:
		Input.action_press(&"attack")
		for i in range(8):
			await frames(1)
			contact = contact or _gate_weapon_overlaps(seal, kind)
		Input.action_release(&"attack")
	for i in range(120):
		await frames(1)
		contact = contact or _gate_weapon_overlaps(seal, kind)
	var opens := tool == &"flare"
	if opens:
		check_eq(flares[0], 1, label + ": actual flare fired")
		check_eq(accepted, [&"flare"], label + ": actual flare accepted")
	else:
		check(contact, label + ": actual wrong hitbox overlaps seal")
		check(accepted.is_empty(), label + ": wrong hit rejected")
	check_eq(seal.get(&"is_open"), opens, label + ": opening")
	check_eq(GameState.has_flag(&"melted_matrix"), opens, label + ": flag")
	check_eq((seal.get_node("Shape") as CollisionShape2D).disabled, opens, label + ": solid")
	print("MATRIX ", label, " opens=", opens, " contact=", contact or not accepted.is_empty())
	await dispose(arena)
	arena = make_arena()
	seal = _gate(arena, ["wax_seal", &"seal_id"], Vector2(540, 500))
	await frames(3)
	if seal != null:
		check_eq(seal.get(&"is_open"), opens, label + ": revisit opening")
		check_eq(GameState.has_flag(&"melted_matrix"), opens, label + ": revisit flag")
		check_eq((seal.get_node("Shape") as CollisionShape2D).disabled, opens,
			label + ": revisit solid")
	await dispose(arena)


func _grate_key_pair(tool: StringName, scope: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(600, 600))
	var grate := _prop(arena, "grate", Vector2(600, 400))
	var key := PickupBase.new()
	key.kind = &"key"
	key.scope = scope
	key.persistent_id = &"matrix_grate_key"
	key.position = Vector2(600, 260)
	arena.add_child(key)
	if grate == null:
		await dispose(arena)
		return
	var label := "%s -> %s grate key" % [tool, scope]
	var collected := [0]
	key.collected.connect(func(_kind: StringName) -> void: collected[0] += 1)
	await frames(3)
	_equip(player, tool)
	player.facing = Vector2.UP
	check(player.use_item(), label + ": actual activation")
	var crossed := false
	var hit_grate := false
	var carried := false
	var grate_shape := grate.get_node("Shape") as CollisionShape2D
	var grate_rect := grate_shape.shape as RectangleShape2D
	var far_edge := grate.global_position.y - grate_rect.size.y * 0.5
	var near_edge := grate.global_position.y + grate_rect.size.y * 0.5
	for i in range(120):
		await frames(1)
		if is_instance_valid(key):
			carried = carried or key.is_carried()
		for moth in get_tree().get_nodes_in_group(&"item_tether_moth"):
			crossed = crossed or moth.global_position.y < far_edge
		for tip in get_tree().get_nodes_in_group(&"reel_tips"):
			hit_grate = hit_grate or (
				absf(tip.global_position.y - near_edge) < 1.0 and tip._state == tip.State.RETRACT
			)
	var fetched := tool == &"tether_moth"
	if fetched:
		check(crossed, label + ": real moth crosses the full grate")
		check(carried, label + ": moth actually carries the key")
	else:
		check(hit_grate, label + ": real reel tip hits and retracts at grate")
		check(not carried, label + ": reel never carries the key")
	check_eq(collected[0], 1 if fetched else 0, label + ": key collection signal")
	check_eq(GameState.keys_in(scope), 1 if fetched else 0, label + ": matching scoped key")
	var other_scope := &"c1" if scope == &"ow" else &"ow"
	check_eq(GameState.keys_in(other_scope), 0, label + ": other scope unchanged")
	check_eq(GameState.has_flag(&"picked_matrix_grate_key"), fetched, label + ": pickup flag")
	check(not (grate.get_node("Shape") as CollisionShape2D).disabled, label + ": grate solid")
	print("MATRIX ", label, " crossed=", crossed, " hit_grate=", hit_grate, " fetched=", fetched)
	await dispose(arena)
	arena = make_arena()
	grate = _prop(arena, "grate", Vector2(600, 400))
	var revisited := PickupBase.new()
	revisited.kind = &"key"
	revisited.scope = scope
	revisited.persistent_id = &"matrix_grate_key"
	revisited.position = Vector2(600, 260)
	arena.add_child(revisited)
	await frames(3)
	check_eq(is_instance_valid(revisited), not fetched, label + ": correct pickup on revisit")
	check_eq(GameState.has_flag(&"picked_matrix_grate_key"), fetched, label + ": revisit flag")
	check_eq(GameState.keys_in(scope), 1 if fetched else 0, label + ": revisit key count")
	check(not (grate.get_node("Shape") as CollisionShape2D).disabled, label + ": revisit solid")
	await dispose(arena)


func _cracked_wall_pair(tool: StringName, prop: String) -> void:
	reset_state()
	var arena := make_arena()
	var wall := _gate(arena, [prop, &"wall_id"], Vector2(644, 400))
	if wall == null:
		await dispose(arena)
		return
	var scene := load("res://scenes/world/%s.tscn" % prop) as PackedScene
	check(scene != null, "distant cracked wall scene loads")
	if scene == null:
		await dispose(arena)
		return
	var far := scene.instantiate() as Node2D
	far.set(&"wall_id", &"matrix_far")
	far.position = Vector2(644, 600)
	arena.add_child(far)
	var player := make_player(arena, Vector2(504 if tool == &"flare" else 400, 400))
	await frames(3)
	player.facing = Vector2.RIGHT
	if tool == &"flare":
		Input.action_press(&"attack")
		await frames(60)
		Input.action_release(&"attack")
	else:
		_equip(player, tool)
		if tool == &"pitch_pot":
			GameState.add_pitch_pots(1)
		check(player.use_item(), "%s -> cracked wall: actual activation" % tool)
	await seconds(1.9)
	var opens := tool == &"pitch_pot"
	check_eq(wall.get(&"is_open"), opens, "%s -> cracked wall: result" % tool)
	check_eq(GameState.has_flag(&"cracked_matrix"), opens, "%s -> cracked wall: flag" % tool)
	check_eq((wall.get_node("Shape") as CollisionShape2D).disabled, opens, "wall collision")
	check(not bool(far.get(&"is_open")), "%s -> distant wall remains closed" % tool)
	check(not GameState.has_flag(&"cracked_matrix_far"), "distant wall has no flag")
	await dispose(arena)


func _cracked_contact(prop: String, tool: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var wall := _gate(arena, [prop, &"wall_id"], Vector2(644, 400))
	if wall == null:
		await dispose(arena)
		return
	var player := make_player(arena, Vector2(444 if tool == &"pitch_pot" else 400, 400))
	player.set_hurtbox_enabled(self, false)
	var blasts: Array[Vector2] = []
	var radii: Array[float] = []
	var on_blast := func(pos: Vector2, radius: float) -> void:
		blasts.append(pos)
		radii.append(radius)
	Events.explosion.connect(on_blast)
	await frames(3)
	player.facing = Vector2.RIGHT
	var label := "%s -> %s" % [tool, prop]
	var contact := false
	var flares := [0]
	player.flare_fired.connect(func() -> void: flares[0] += 1)
	if tool == &"pitch_pot":
		_equip(player, tool)
		GameState.add_pitch_pots(1)
		check(player.use_item(), label + ": real pot placed")
	else:
		Input.action_press(&"attack")
		await frames(60)
		check(player.charge_ready, label + ": actual flare charged")
		var bounds := Rect2(wall.global_position - wall.size * 0.5, wall.size)
		check(player.global_position.x + Player.SWING_REACH < bounds.position.x,
			label + ": initial hook is outside wall reach")
		check(not bool(wall.get(&"is_open")), label + ": wall remains closed while charging")
		player.global_position = Vector2(504, 400)
		Input.action_release(&"attack")
	for i in range(120):
		await frames(1)
		if tool == &"flare" and player.flare_hitbox.active:
			var shape := player.flare_hitbox.get_child(0) as CollisionShape2D
			var query := PhysicsShapeQueryParameters2D.new()
			query.shape = shape.shape
			query.transform = shape.global_transform
			query.collision_mask = Layers.WORLD
			for result in arena.get_world_2d().direct_space_state.intersect_shape(query):
				contact = contact or result.collider == wall
	Events.explosion.disconnect(on_blast)
	if tool == &"flare":
		check_eq(flares[0], 1, label + ": actual flare fired")
	else:
		check_eq(blasts.size(), 1, label + ": one actual explosion")
		if blasts.size() == 1:
			var bounds := Rect2(wall.global_position - wall.size * 0.5, wall.size)
			var nearest := Vector2(
				clampf(blasts[0].x, bounds.position.x, bounds.end.x),
				clampf(blasts[0].y, bounds.position.y, bounds.end.y)
			)
			contact = blasts[0].distance_to(nearest) <= radii[0]
	check(contact, label + ": actual blast or flare reaches solid body")
	var opens := tool == &"pitch_pot"
	check_eq(bool(wall.get(&"is_open")), opens, label + ": opening")
	check_eq(GameState.has_flag(&"cracked_matrix"), opens, label + ": flag")
	check_eq((wall.get_node("Shape") as CollisionShape2D).disabled, opens, label + ": solid")
	print("MATRIX ", label, " contact=", contact, " opens=", opens)
	await dispose(arena)
	arena = make_arena()
	wall = _gate(arena, [prop, &"wall_id"], Vector2(644, 400))
	await frames(3)
	if wall != null:
		check_eq(bool(wall.get(&"is_open")), opens, label + ": revisit opening")
		check_eq(GameState.has_flag(&"cracked_matrix"), opens, label + ": revisit flag")
		check_eq((wall.get_node("Shape") as CollisionShape2D).disabled, opens,
			label + ": revisit solid")
	await dispose(arena)


func _cut_screen_pair(prop: String, tool: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var target := _prop(arena, prop, Vector2(500, 400)) as Bush
	if target == null:
		await dispose(arena)
		return
	target.drops_enabled = false
	var was_cut := [false]
	target.cut.connect(func() -> void: was_cut[0] = true)
	var player := make_player(arena, Vector2(410 if tool == &"hook" else 300, 400))
	await frames(3)
	player.facing = Vector2.RIGHT
	if tool == &"hook":
		Input.action_press(&"attack")
		await frames(8)
		Input.action_release(&"attack")
	else:
		_equip(player, tool)
		if tool == &"pitch_pot":
			GameState.add_pitch_pots(1)
		check(player.use_item(), "%s -> %s: actual activation" % [tool, prop])
	await seconds(1.9)
	var cuts := tool in [&"hook", &"pitch_pot"]
	check_eq(was_cut[0], cuts, "%s -> %s: actual cut result" % [tool, prop])
	if not cuts:
		check(is_instance_valid(target) and not target.is_cut, "%s remains solid" % prop)
	await dispose(arena)


func _cut_screen_flare_and_reel() -> void:
	reset_state()
	var arena := make_arena()
	var screen := _prop(arena, "rush_wall", Vector2(500, 400)) as Bush
	if screen == null:
		await dispose(arena)
		return
	screen.drops_enabled = false
	var cut := [false]
	screen.cut.connect(func() -> void: cut[0] = true)
	var player := make_player(arena, Vector2(300, 400))
	await frames(3)
	_equip(player, &"reel_line")
	check(player.use_item(), "rush wall: actual reel launches")
	var reel_contact := false
	for i in range(90):
		await frames(1)
		reel_contact = reel_contact or _gate_weapon_overlaps(screen, &"reel")
	check(reel_contact, "rush wall: actual reel hitbox overlaps screen")
	check(not cut[0] and is_instance_valid(screen), "rush wall: reel does not cut")
	check_near(player.global_position.x, 300, 1, "rush wall: reel does not pull player")
	# Charge outside hook reach; move into flare range only after the initial swing.
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(60)
	check(player.charge_ready, "rush wall: actual flare is charged")
	check(not cut[0], "rush wall: distant initial hook did not cut")
	player.global_position = Vector2(360, 400)
	player.facing = Vector2.RIGHT
	Input.action_release(&"attack")
	await frames(10)
	check(cut[0], "rush wall: actual charged flare cuts screen")
	await dispose(arena)


func _ward_plate_tools() -> void:
	reset_state()
	var arena := make_arena()
	var scene := load("res://scenes/world/ward_plate.tscn") as PackedScene
	check(scene != null, "ward plate scene loads")
	if scene == null:
		await dispose(arena)
		return
	var pad := scene.instantiate() as Node2D
	pad.set(&"ward_id", &"matrix_ward")
	pad.set(&"blocks_required", 2)
	# Deterministic zero-damage spore post is a test-only fixture, not a runtime enemy.
	pad.set(&"test_spore_post", true)
	pad.position = Vector2(500, 400)
	arena.add_child(pad)
	var blocker := scene.instantiate() as Node2D
	blocker.set(&"ward_id", &"matrix_ward")
	blocker.set(&"blocker", true)
	blocker.position = Vector2(900, 400)
	arena.add_child(blocker)
	var player := make_player(arena, Vector2(500, 400))
	await frames(3)
	_equip(player, &"tallow_sling")
	player.facing = Vector2.UP
	check(player.use_item(), "ward plate: actual sling fires while on pad")
	await seconds(0.8)
	check_eq(pad.get(&"blocks_absorbed"), 0, "ward plate: sling and unblocked spores do not count")
	check(not bool(blocker.get(&"is_open")), "ward plate: wrong tool leaves blocker closed")
	Input.action_press(&"ward")
	await seconds(1.5)
	check_eq(pad.get(&"blocks_absorbed"), 2, "ward plate: actual ward blocks two distinct spores")
	check(bool(blocker.get(&"is_open")), "ward plate: real ward opens linked blocker")
	check(GameState.has_flag(&"ward_matrix_ward"), "ward plate: opening persists")
	Input.action_release(&"ward")
	await dispose(arena)


func _brazier_gate_tools() -> void:
	reset_state()
	var arena := make_arena()
	var first := Brazier.new()
	first.name = "B1"
	first.brazier_id = &"matrix_b1"
	first.position = Vector2(490, 400)
	arena.add_child(first)
	var second := Brazier.new()
	second.name = "B2"
	second.brazier_id = &"matrix_b2"
	second.position = Vector2(900, 400)
	arena.add_child(second)
	var gate := Gate.new()
	gate.gate_id = &"matrix_braziers"
	gate.braziers = [NodePath("../B1"), NodePath("../B2")]
	gate.position = Vector2(900, 800)
	arena.add_child(gate)
	var player := make_player(arena, Vector2(290, 400))
	await frames(3)
	_equip(player, &"tallow_sling")
	check(player.use_item(), "brazier gate: actual sling fires")
	await seconds(0.5)
	check(not first.lit and not gate.is_open, "brazier gate: sling leaves it closed")
	player.place_at(Vector2(400, 400))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check(first.lit, "brazier gate: actual hook lights first")
	check(not gate.is_open, "brazier gate: one lit is insufficient")
	await frames(20)
	player.place_at(Vector2(700, 400))
	_equip(player, &"cinder_wick")
	check(player.use_item(), "brazier gate: actual cinder wick launches")
	await seconds(1.0)
	check(second.lit and gate.is_open, "brazier gate: real fire lights second and opens gate")
	check(GameState.has_flag(&"gate_matrix_braziers"), "brazier gate: completion persists")
	await dispose(arena)


func _brazier_contact_revisit(tool: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var nodes := _matrix_brazier_gate(arena)
	var brazier: Brazier = nodes[0]
	var gate: Gate = nodes[1]
	var player := make_player(arena, Vector2(290, 400))
	await frames(3)
	var label := "%s -> brazier gate" % tool
	var hits: Array[StringName] = []
	brazier.hurtbox.hurt.connect(func(hit: Hitbox) -> void: hits.append(hit.kind))
	_equip(player, tool)
	player.facing = Vector2.RIGHT
	check(not brazier.lit and not gate.is_open, label + ": initially closed")
	check(player.use_item(), label + ": actual item activated")
	var contact := false
	var kind := &"fire" if tool == &"cinder_wick" else &"sling"
	for i in range(120):
		await frames(1)
		contact = contact or _gate_weapon_overlaps(brazier, kind)
	var opens := tool == &"cinder_wick"
	check(contact or kind in hits, label + ": actual hitbox contacts brazier")
	check_eq(brazier.lit, opens, label + ": brazier state")
	check_eq(gate.is_open, opens, label + ": gate state")
	check_eq(GameState.has_flag(&"brazier_matrix_contact"), opens, label + ": brazier flag")
	check_eq(GameState.has_flag(&"gate_matrix_contact"), opens, label + ": gate flag")
	check_eq(gate._shape.disabled, opens, label + ": gate collision")
	print("MATRIX ", label, " contact=", contact or kind in hits, " opens=", opens)
	await dispose(arena)
	arena = make_arena()
	nodes = _matrix_brazier_gate(arena)
	brazier = nodes[0]
	gate = nodes[1]
	await frames(3)
	check_eq(brazier.lit, opens, label + ": revisit brazier")
	check_eq(gate.is_open, opens, label + ": revisit gate")
	check_eq(GameState.has_flag(&"brazier_matrix_contact"), opens, label + ": revisit brazier flag")
	check_eq(GameState.has_flag(&"gate_matrix_contact"), opens, label + ": revisit gate flag")
	check_eq(gate._shape.disabled, opens, label + ": revisit gate collision")
	await dispose(arena)


func _matrix_brazier_gate(arena: Node) -> Array:
	var brazier := Brazier.new()
	brazier.name = "MatrixBrazier"
	brazier.brazier_id = &"matrix_contact"
	brazier.position = Vector2(490, 400)
	arena.add_child(brazier)
	var gate := Gate.new()
	gate.gate_id = &"matrix_contact"
	gate.braziers = [NodePath("../MatrixBrazier")]
	gate.position = Vector2(900, 800)
	arena.add_child(gate)
	return [brazier, gate]


func _collect_gate_pickup(arena: Node, player: Player, kind: StringName, scope: StringName) -> void:
	# Place a real pickup by the player; inventory is gained through the collector collision.
	var pickup := PickupBase.new()
	pickup.kind = kind
	pickup.scope = scope
	pickup.position = Vector2(300, 600)
	arena.add_child(pickup)
	player.place_at(Vector2(300, 700))
	Input.action_press(&"move_up")
	await seconds(0.3)
	release_inputs()
	check(not is_instance_valid(pickup) or pickup.is_collected, "%s %s: physically collected" % [kind, scope])


func _scoped_key_gate() -> void:
	reset_state()
	var arena := make_arena()
	var door := LockedDoor.new()
	door.door_id = &"matrix_scope"
	door.scope = &"c1"
	door.position = Vector2(500, 400)
	arena.add_child(door)
	var player := make_player(arena, Vector2(500, 600))
	await frames(3)
	_equip(player, &"tallow_sling")
	player.facing = Vector2.UP
	check(player.use_item(), "scoped lock: real sling fires")
	await seconds(0.5)
	Input.action_press(&"move_up")
	await seconds(0.7)
	release_inputs()
	check(not door.is_open, "scoped lock: sling and keyless contact leave door closed")
	await _collect_gate_pickup(arena, player, &"key", &"ow")
	player.place_at(Vector2(500, 470))
	await frames(5)
	check(not door.is_open, "scoped lock: actual overworld key cannot open cave door")
	check_eq(GameState.keys_in(&"ow"), 1, "scoped lock: wrong key retained")
	await _collect_gate_pickup(arena, player, &"key", &"c1")
	player.place_at(Vector2(500, 470))
	await frames(5)
	check(door.is_open, "scoped lock: actual cave key opens on player contact")
	check_eq(GameState.keys_in(&"c1"), 0, "scoped lock: matching key spent once")
	check_eq(GameState.keys_in(&"ow"), 1, "scoped lock: wrong key still retained")
	check(GameState.has_flag(&"door_matrix_scope"), "scoped lock: persistent flag")
	await dispose(arena)


func _boss_key_gate() -> void:
	reset_state()
	var arena := make_arena()
	var scene := load("res://scenes/world/boss_door.tscn") as PackedScene
	check(scene != null, "boss door scene loads")
	if scene == null:
		await dispose(arena)
		return
	var door := scene.instantiate() as Node2D
	door.set(&"cave", &"c1")
	door.position = Vector2(500, 400)
	arena.add_child(door)
	var player := make_player(arena, Vector2(500, 600))
	await frames(3)
	_equip(player, &"cinder_wick")
	player.facing = Vector2.UP
	check(player.use_item(), "boss door: real wick launches")
	await seconds(0.8)
	check(not bool(door.get(&"is_open")), "boss door: wick leaves it closed")
	await _collect_gate_pickup(arena, player, &"key", &"c1")
	player.place_at(Vector2(500, 470))
	await frames(5)
	check(not bool(door.get(&"is_open")), "boss door: actual small key does not open")
	check_eq(GameState.keys_in(&"c1"), 1, "boss door: small key retained")
	await _collect_gate_pickup(arena, player, &"big_key", &"c1")
	player.place_at(Vector2(500, 470))
	await frames(5)
	check(bool(door.get(&"is_open")), "boss door: actual cave Lockpick opens on contact")
	check(GameState.has_big_key(&"c1"), "boss door: Lockpick retained")
	check(GameState.has_flag(&"door_boss_c1"), "boss door: canonical flag")
	await dispose(arena)


func _ninth_fragment_gate() -> void:
	reset_state()
	var arena := make_arena()
	var door := _prop(arena, "ninth_door", Vector2(500, 400))
	if door == null:
		await dispose(arena)
		return
	var player := make_player(arena, Vector2(500, 600))
	await frames(3)
	_equip(player, &"tallow_sling")
	player.facing = Vector2.UP
	check(player.use_item(), "ninth door: real sling fires")
	await seconds(0.5)
	check(not bool(door.get(&"is_open")), "ninth door: sling cannot open")
	for i in range(1, 9):
		await _collect_gate_pickup(arena, player, &"fragment", StringName("c%d" % i))
	player.place_at(Vector2(500, 470))
	await frames(5)
	check_eq(GameState.fragment_count(), 8, "ninth door: eight actual fragments collected")
	check(not bool(door.get(&"is_open")), "ninth door: eight fragments leave it closed")
	await _collect_gate_pickup(arena, player, &"fragment", &"c9")
	player.place_at(Vector2(500, 470))
	await frames(5)
	check(bool(door.get(&"is_open")), "ninth door: nine actual fragments open on contact")
	check_eq(GameState.fragment_count(), 9, "ninth door: fragments retained")
	check(GameState.has_flag(&"door_ninth"), "ninth door: canonical flag")
	await dispose(arena)


func _mooring_water_gate() -> void:
	reset_state()
	var arena := make_arena()
	var water := _prop(arena, "water_zone", Vector2(700, 500))
	var dock := _prop(arena, "mooring", Vector2(368, 400))
	if water == null or dock == null:
		await dispose(arena)
		return
	water.set(&"size", Vector2(600, 600))
	water.set(&"deep", true)
	water.set(&"raft_free_steering", true)
	var player := make_player(arena, dock.call(&"landing_position"))
	await frames(3)
	_equip(player, &"reed_raft")
	player.place_at(Vector2(200, 800))
	check(not player.use_item(), "raft refuses boarding away from mooring")
	check(not player.is_on_raft(), "distant use starts no raft ride")
	player.place_at(dock.call(&"landing_position"))
	_equip(player, &"tallow_sling")
	check(player.use_item(), "sling fires at the mooring")
	await seconds(0.4)
	check(not player.is_on_raft(), "sling does not board or open water passage")
	_equip(player, &"reed_raft")
	check(player.use_item(), "actual raft boards at the mooring")
	await seconds(0.4)
	check(player.is_on_raft(), "raft enters rider state")
	check(player.hurtbox.enabled, "raft rider retains active hurtbox")
	var start := player.global_position
	Input.action_press(&"move_right")
	await seconds(0.8)
	release_inputs()
	check(player.global_position.x > start.x + 100, "real raft crosses into water")
	check(bool(water.call(&"contains_point", player.global_position)), "rider remains on water")
	_equip(player, &"tallow_sling")
	check(not player.use_item(), "sling cannot be used afloat away from dock")
	check(player.is_on_raft(), "refused use keeps rider afloat")
	await dispose(arena)


func _flooded_room_pair() -> void:
	reset_state()
	var world := await make_world()
	world.start_at(&"cave_3_5")
	await frames(3)
	var room := world.get_room(&"cave_3_5")
	var peer := world.get_room(&"cave_3_6")
	var dock: Node2D
	for node in room.get_node("Props").get_children():
		if node.is_in_group(&"mooring") and node.get(&"mooring_id") == &"e167":
			dock = node
	check(dock != null and peer != null, "flooded e167: actual room pair and dock load")
	if dock == null or peer == null:
		await dispose(world)
		return
	# Remove roaming combatants to isolate the real gate and room transition.
	for enemy in room.get_enemies():
		enemy.queue_free()
	var player := world.player
	var destination: Node2D = dock.call(&"find_target")
	check(destination != null, "flooded e167: real paired mooring resolves")
	if destination == null:
		await dispose(world)
		return
	var landing: Vector2 = destination.call(&"landing_position")
	player.place_at(dock.call(&"landing_position"))
	_equip(player, &"tallow_sling")
	await frames(3)
	check(player.use_item(), "flooded e167: actual sling fires at dock")
	await seconds(0.5)
	check_eq(world.get_current_room_id(), &"cave_3_5", "flooded e167: sling does not cross")
	check(not player.is_external_motion(), "flooded e167: sling does not board")
	_equip(player, &"reed_raft")
	check(player.use_item(), "flooded e167: real raft boards at source")
	await seconds(0.4)
	check(player.is_external_motion(), "flooded e167: raft ride starts")
	for i in range(600):
		if world.get_current_room_id() == &"cave_3_6" and not player.is_external_motion():
			break
		await frames(1)
	check_eq(world.get_current_room_id(), &"cave_3_6", "flooded e167: raft reaches peer room")
	check(not player.is_external_motion(), "flooded e167: ride ends at paired dock")
	check(player.global_position.distance_to(landing) < 10, "flooded e167: lands at peer marker")
	await dispose(world)


func _oneway_drop_pair(upper: StringName, lower: StringName) -> void:
	reset_state()
	var world := await make_world()
	world.start_at(upper)
	await frames(3)
	var room := world.get_room(upper)
	var peer := world.get_room(lower)
	check(room != null and peer != null, "%s: actual one-way room pair loads" % upper)
	if room == null or peer == null:
		await dispose(world)
		return
	# Clear roaming enemies in both real rooms to isolate traversal; player damage stays enabled.
	for enemy in room.get_enemies() + peer.get_enemies():
		enemy.queue_free()
	var player := world.player
	player.place_at(room.global_position + Vector2(960, 780))
	await frames(3)
	check(not GameState.has_item(&"skitter_boots"), "%s: no boots needed for drop" % upper)
	Input.action_press(&"move_down")
	for i in range(180):
		if world.is_transitioning():
			break
		await frames(1)
	release_inputs()
	check(world.is_transitioning(), "%s: actual walking starts one-way drop" % upper)
	for i in range(150):
		if not world.is_transitioning():
			break
		await frames(1)
	check_eq(world.get_current_room_id(), lower, "%s: actual drop reaches lower room" % upper)
	# Start the reverse attempt inside the lower room rather than on its arrival boundary.
	player.place_at(peer.global_position + Vector2(960, 210))
	await frames(3)
	var before := GameState.health
	_equip(player, &"skitter_boots")
	player.facing = Vector2.UP
	check(player.use_item(), "%s: actual boots leap toward closed return" % lower)
	await seconds(0.8)
	check_eq(world.get_current_room_id(), lower, "%s: boots cannot reverse drop" % lower)
	check(
		player.global_position.y >= peer.global_position.y + WorldConst.WALL_THICKNESS,
		"%s: lower room wall stops return y=%.1f origin=%.1f" % [
			lower, player.global_position.y, peer.global_position.y
		]
	)
	check_eq(GameState.health, before, "%s: wall-stopped leap causes no damage" % lower)
	await dispose(world)


func _ravine_pair(tool: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var ravine := _prop(arena, "ravine_leap", Vector2(500, 444))
	if ravine == null:
		await dispose(arena)
		return
	var player := make_player(arena, Vector2(500, 348))
	await frames(3)
	_equip(player, tool)
	player.facing = Vector2.DOWN
	check(player.use_item(), "%s -> ravine: real activation" % tool)
	var crossed := false
	for i in range(80):
		await frames(1)
		if bool(ravine.call(&"holds", player.global_position)) and player.is_airborne():
			crossed = true
	check_eq(crossed, tool == &"skitter_boots", "%s -> ravine: airborne crossing" % tool)
	check_near(player.global_position.y, 540 if crossed else 348, 1, "%s -> ravine: landing" % tool)
	check_eq(GameState.health, 6, "%s -> ravine: no fall damage" % tool)
	await dispose(arena)


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
	var accepted: Array[StringName] = []
	var hurtbox := gate.get_node("Hurtbox") as Hurtbox
	hurtbox.hurt.connect(func(hit: Hitbox) -> void: accepted.append(hit.kind))
	check(not bool(gate.get(row[3])), label + ": initially closed")
	check(player.use_item(), label + ": real player activates tool")
	await frames(2)
	check(not bool(gate.get(row[3])), label + ": no remote instant activation")
	await seconds(2.0)
	var opens: bool = tool == row[2]
	if opens:
		var expected_kind: StringName = {
			&"cinder_wick": &"fire", &"tallow_sling": &"sling", &"lantern_chime": &"chime"
		}[tool]
		check(expected_kind in accepted, label + ": real tool hit accepted by gate")
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
		check_eq(GameState.has_flag(flag), opens, label + ": revisit flag")
		if row[0] != "eye_switch":
			check_eq((gate.get_node("Shape") as CollisionShape2D).disabled, opens,
				label + ": revisit collision")
		else:
			var restored_blockers: Array[Node2D] = []
			for name: String in ["eye_portcullis", "eye_cell"]:
				restored_blockers.append(_gate(arena, [name, &"eye_id"], Vector2(900, 700)))
			await frames(3)
			for restored: Node2D in restored_blockers:
				if restored != null:
					check_eq(bool(restored.get(&"is_open")), opens, label + ": revisit blocker")
					check_eq((restored.get_node("Shape") as CollisionShape2D).disabled, opens,
						label + ": revisit blocker collision")
	await dispose(arena)


func _gate_base_weapon_pair(row: Array, tool: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var gate := _gate(arena, row, Vector2(540, 500))
	if gate == null:
		await dispose(arena)
		return
	var start := Vector2(340, 500) if tool == &"pitch_pot" else Vector2(400, 500)
	var player := make_player(arena, start)
	var blockers: Array[Node2D] = []
	if row[0] == "eye_switch":
		for name: String in ["eye_portcullis", "eye_cell"]:
			blockers.append(_gate(arena, [name, &"eye_id"], Vector2(900, 700)))
	await frames(3)
	player.facing = Vector2.RIGHT
	var label := "%s -> %s" % [tool, row[0]]
	var contact := false
	var kind := &"explosion" if tool == &"pitch_pot" else tool
	if tool == &"reel_line":
		kind = &"reel"
	var blasts := [0]
	var on_blast := func(_pos: Vector2, _radius: float) -> void: blasts[0] += 1
	Events.explosion.connect(on_blast)
	if tool in [&"pitch_pot", &"reel_line"]:
		_equip(player, tool)
		if tool == &"pitch_pot":
			GameState.add_pitch_pots(1)
		check(player.use_item(), label + ": actual tool activated")
	else:
		Input.action_press(&"attack")
		for i in range(60 if tool == &"flare" else 8):
			await frames(1)
			contact = contact or _gate_weapon_overlaps(gate, kind)
		if tool == &"flare":
			check(player.charge_ready, label + ": actual charge ready")
		Input.action_release(&"attack")
	for i in range(120):
		await frames(1)
		contact = contact or _gate_weapon_overlaps(gate, kind)
	if tool == &"pitch_pot":
		check_eq(blasts[0], 1, label + ": actual pot detonates")
	Events.explosion.disconnect(on_blast)
	check(contact, label + ": real hitbox overlaps gate hurtbox")
	check(not bool(gate.get(row[3])), label + ": wrong weapon leaves gate closed")
	check(not GameState.has_flag(StringName(String(row[4]) + "matrix")), label + ": no flag")
	if row[0] != "eye_switch":
		check(not (gate.get_node("Shape") as CollisionShape2D).disabled, label + ": blocker solid")
	for blocker: Node2D in blockers:
		if blocker != null:
			check(not bool(blocker.get(&"is_open")), label + ": linked blocker closed")
			check(not (blocker.get_node("Shape") as CollisionShape2D).disabled,
				label + ": linked blocker solid")
	print("MATRIX ", label, " expected=false")
	await dispose(arena)
	arena = make_arena()
	gate = _gate(arena, row, Vector2(540, 500))
	await frames(3)
	if gate != null:
		check(not bool(gate.get(row[3])), label + ": revisit closed")
		check(not GameState.has_flag(StringName(String(row[4]) + "matrix")),
			label + ": revisit no flag")
		if row[0] != "eye_switch":
			check(not (gate.get_node("Shape") as CollisionShape2D).disabled,
				label + ": revisit solid")
		else:
			for name: String in ["eye_portcullis", "eye_cell"]:
				var blocker := _gate(arena, [name, &"eye_id"], Vector2(900, 700))
				if blocker != null:
					check(not bool(blocker.get(&"is_open")), label + ": revisit blocker")
					check(not (blocker.get_node("Shape") as CollisionShape2D).disabled,
						label + ": revisit blocker solid")
	await dispose(arena)


func _gate_weapon_overlaps(gate: Node, kind: StringName) -> bool:
	var hurtbox := gate.get_node_or_null("Hurtbox") as Hurtbox
	if hurtbox == null:
		return false
	for node in get_tree().get_nodes_in_group(&"hitboxes"):
		if node is Hitbox and node.kind == kind and node.active:
			if hurtbox in node.get_overlapping_areas():
				return true
	return false


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


func _heavy_wrong_weapon(prop: String, tool: StringName) -> void:
	reset_state()
	var arena := make_arena()
	var stone := _gate(arena, [prop, &"stone_id"], Vector2(540, 500))
	if stone == null:
		await dispose(arena)
		return
	var player := make_player(arena, Vector2(340 if tool == &"pitch_pot" else 400, 500))
	player.set_hurtbox_enabled(self, false)
	await frames(3)
	player.facing = Vector2.RIGHT
	var label := "%s -> %s" % [tool, prop]
	var kind := &"explosion" if tool == &"pitch_pot" else tool
	var contact := false
	if tool == &"pitch_pot":
		_equip(player, tool)
		GameState.add_pitch_pots(1)
		check(player.use_item(), label + ": actual pot placed")
	else:
		Input.action_press(&"attack")
		for i in range(60 if tool == &"flare" else 8):
			await frames(1)
			contact = contact or _gate_weapon_overlaps(stone, kind)
		if tool == &"flare":
			check(player.charge_ready, label + ": flare fully charged")
		Input.action_release(&"attack")
	for i in range(120):
		await frames(1)
		contact = contact or _gate_weapon_overlaps(stone, kind)
	check(contact, label + ": real hitbox overlaps grab zone")
	check(is_instance_valid(stone), label + ": obstacle survives")
	if is_instance_valid(stone):
		check_eq(stone.global_position, Vector2(540, 500), label + ": obstacle stays in place")
		check(not stone.call(&"is_carried"), label + ": not carried")
		check(not (stone.get_node("Shape") as CollisionShape2D).disabled, label + ": solid")
	check(not GameState.has_flag(&"moved_matrix"), label + ": no opening flag")
	print("MATRIX ", label, " expected=false contact=", contact)
	await dispose(arena)
	arena = make_arena()
	stone = _gate(arena, [prop, &"stone_id"], Vector2(540, 500))
	await frames(3)
	if stone != null:
		check_eq(stone.global_position, Vector2(540, 500), label + ": still closed on revisit")
		check(not (stone.get_node("Shape") as CollisionShape2D).disabled, label + ": revisit solid")
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
	player.set_hurtbox_enabled(self, false)
	var chime_hits := [0]
	enemy.hurtbox.hurt.connect(func(hit: Hitbox) -> void:
		if hit.kind == &"chime":
			chime_hits[0] += 1
	)
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
	check_eq(chime_hits[0], 1, "Echo: actual chime hits during glow")
	check_near(enemy._stun_time, 2.0, 0.05, "Echo: opening lasts two seconds")
	var flared := false
	for i in range(60):
		await frames(1)
		flared = flared or enemy.state == enemy.State.FLARE
	check(not flared and enemy.is_stunned(), "Echo: interrupted flare does not fire")
	player.place_at(enemy.global_position + Vector2(90, 0))
	player.facing = Vector2.LEFT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 34, "Echo: actual hook deals two during opening")
	await dispose(arena)


func _echo_chime_outside_glow() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(
		arena, "res://scenes/enemies/minibosses/corrows_echo.tscn", Vector2(800, 480)
	)
	var player := make_player(arena, Vector2(940, 480))
	player.set_hurtbox_enabled(self, false)
	for i in range(180):
		if enemy.state == enemy.State.TELL:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.TELL, "Echo: natural combo warning reached")
	var hit_states: Array[int] = []
	enemy.hurtbox.hurt.connect(func(hit: Hitbox) -> void:
		if hit.kind == &"chime":
			hit_states.append(enemy.state)
	)
	player.place_at(enemy.global_position + Vector2(100, 0))
	_equip(player, &"lantern_chime")
	check(player.use_item(), "Echo: actual chime rings outside glow")
	await frames(20)
	check_eq(hit_states, [enemy.State.TELL], "Echo: chime actually hits during combo warning")
	check(not enemy.is_stunned(), "Echo: outside-glow hit does not stun")
	check_eq(enemy.hp, 36, "Echo: chime causes no damage")
	var flared := false
	for i in range(240):
		await frames(1)
		if enemy.state == enemy.State.FLARE:
			flared = true
			break
	check(flared, "Echo: uninterrupted cycle reaches real flare")
	check(is_instance_valid(enemy._attack) and enemy._attack.active,
		"Echo: flare has an active attack")
	print("MATRIX Echo chime: warning hit=", hit_states, " later flare=", flared)
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


func _thorn_wick() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(
		arena, "res://scenes/enemies/minibosses/thorn_warden.tscn", Vector2(850, 480)
	)
	var player := make_player(arena, Vector2(610, 480))
	player.set_hurtbox_enabled(self, false)
	enemy.move_speed = 0
	var ticks: Array[int] = []
	enemy.damaged.connect(func(amount: int) -> void: ticks.append(amount))
	await frames(3)
	_equip(player, &"cinder_wick")
	check(player.use_item(), "Thorn Warden: actual wick launches")
	for i in range(90):
		if ticks.size() >= 2:
			break
		await frames(1)
	check_eq(ticks.size(), 2, "Thorn Warden: flame lands and ticks twice")
	if ticks.size() >= 2:
		check_eq(ticks[0], 2, "Thorn Warden: first fire tick deals two")
		check_eq(ticks[1], 2, "Thorn Warden: second fire tick deals two")
	check_eq(enemy.hp, 12, "Thorn Warden: real fire deals four total")
	print("MATRIX Thorn Warden: wick ticks=", ticks)
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


func _brute_flare_rail() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(
		arena, "res://scenes/enemies/minibosses/abacus_brute.tscn", Vector2(800, 480)
	)
	var player := make_player(arena, Vector2(910, 480))
	player.set_hurtbox_enabled(self, false)
	await frames(3)
	var blocks: Array[StringName] = []
	var hits: Array[StringName] = []
	var flares := [0]
	enemy.guard_blocked.connect(func(hit: Hitbox) -> void: blocks.append(hit.kind))
	enemy.hurtbox.hurt.connect(func(hit: Hitbox) -> void: hits.append(hit.kind))
	player.flare_fired.connect(func() -> void: flares[0] += 1)
	player.facing = Vector2.LEFT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(blocks, [&"hook"], "Brute: actual front hook contacts guard")
	check_eq(enemy.rail_hp, 4, "Brute: blocked hook leaves rail intact")
	check_eq(enemy.hp, 28, "Brute: blocked hook leaves body intact")
	await frames(25)
	player.place_at(enemy.global_position + Vector2(300, 0))
	player.facing = Vector2.LEFT
	Input.action_press(&"attack")
	await frames(60)
	check(player.charge_ready, "Brute: actual flare is charged")
	check_eq(blocks, [&"hook"], "Brute: distant charge swing misses guard")
	check_eq(hits, [&"hook"], "Brute: distant charge swing misses hurtbox")
	check_eq(enemy.rail_hp, 4, "Brute: rail intact before release")
	# place_at cancels charging, so reposition without resetting player actions.
	player.global_position = enemy.global_position + Vector2(110, 0)
	player.facing = Vector2.LEFT
	Input.action_release(&"attack")
	await frames(10)
	check_eq(flares[0], 1, "Brute: actual charged flare fired")
	check(&"flare" in hits, "Brute: actual charged flare contacts hurtbox")
	check_eq(enemy.rail_hp, 0, "Brute: flare breaks rail")
	check_eq(enemy.hp, 28, "Brute: rail absorbs flare without body damage")
	check_eq(enemy.move_speed, 130.0, "Brute: broken rail increases movement speed")
	await frames(25)
	player.place_at(enemy.global_position + Vector2(90, 0))
	player.facing = Vector2.LEFT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 26, "Brute: actual front hook damages body after flare")
	check_eq(blocks, [&"hook"], "Brute: second front hook is no longer blocked")
	check(not GameState.has_item(&"reel_line"), "Brute: flare route needs no later reel")
	print("MATRIX Brute: guard blocks=", blocks, " hits=", hits, " rail=", enemy.rail_hp)
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


func _kiln_wick() -> void:
	reset_state()
	var arena := make_arena()
	var boss = make_enemy(
		arena, "res://scenes/enemies/bosses/kilnkeeper.tscn", Vector2(800, 480)
	)
	boss.room_rect = Rect2(96, 96, 1728, 768)
	var player := make_player(arena, Vector2(192, 192))
	# This isolates armour and tool collisions from simultaneous boss attacks.
	player.set_hurtbox_enabled(self, false)
	await seconds(1.6)
	player.place_at(boss.global_position - Vector2(140, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(6)
	Input.action_release(&"attack")
	check_eq(boss.hp, 24, "Kilnkeeper: real hook cannot damage hard armour")
	await frames(22)
	player.place_at(boss.global_position - Vector2(200, 0))
	_equip(player, &"cinder_wick")
	check(player.use_item(), "Kilnkeeper: actual cinder wick launches")
	await seconds(0.7)
	player.place_at(Vector2(192, 192))
	for i in range(120):
		if boss.is_molten():
			break
		await frames(1)
	check(boss.is_molten(), "Kilnkeeper: attached flame melts armour")
	check_eq(boss.melt_ticks, 3, "Kilnkeeper: phase one requires three flame ticks")
	check_eq(boss.hp, 18, "Kilnkeeper: three real ticks each deal two")
	await dispose(arena)


func _kiln_phase_two_wick() -> void:
	reset_state()
	var arena := make_arena()
	var boss = make_enemy(arena, "res://scenes/enemies/bosses/kilnkeeper.tscn", Vector2(800, 480))
	boss.room_rect = Rect2(96, 96, 1728, 768)
	boss.move_speed = 0
	var player := make_player(arena, Vector2(600, 480))
	player.set_hurtbox_enabled(self, false)
	var hits: Array[StringName] = []
	var fire_phases: Array[int] = []
	var damage: Array[int] = []
	boss.hurtbox.hurt.connect(func(hit: Hitbox) -> void:
		hits.append(hit.kind)
		if hit.kind == &"fire":
			fire_phases.append(boss.phase)
	)
	boss.damaged.connect(func(amount: int) -> void: damage.append(amount))
	for i in range(120):
		if not boss.is_in_intro():
			break
		await frames(1)
	check_eq(boss.phase, 1, "Kilnkeeper: natural phase one starts")
	_equip(player, &"cinder_wick")
	player.facing = Vector2.RIGHT
	check(player.use_item(), "Kilnkeeper: real wick launches in phase one")
	for i in range(300):
		if boss.phase == 2:
			break
		await frames(1)
	check_eq(boss.phase, 2, "Kilnkeeper: actual fire reaches phase two")
	check_eq(boss.hp, 12, "Kilnkeeper: six real fire hits reach phase threshold")
	check_eq(hits.count(&"fire"), 6, "Kilnkeeper: six phase-one fire contacts")
	for i in range(180):
		if not boss.is_pausing() and get_tree().get_nodes_in_group(&"item_cinder_wick").is_empty():
			break
		await frames(1)
	check(not boss.is_pausing(), "Kilnkeeper: natural phase pause finishes")
	check(get_tree().get_nodes_in_group(&"item_cinder_wick").is_empty(), "Kilnkeeper: first wick expires")
	check(not boss.is_molten(), "Kilnkeeper: phase-two armour starts hard")
	player.place_at(boss.global_position - Vector2(140, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check(&"hook" in hits, "Kilnkeeper: actual hook contacts hard phase-two armour")
	check_eq(boss.hp, 12, "Kilnkeeper: hard armour rejects real hook")
	for i in range(20):
		if player.state == player.State.NORMAL:
			break
		await frames(1)
	player.place_at(boss.global_position - Vector2(200, 0))
	_equip(player, &"cinder_wick")
	check(player.use_item(), "Kilnkeeper: second real wick launches in phase two")
	for i in range(180):
		if hits.count(&"fire") >= 9:
			break
		await frames(1)
	check_eq(hits.count(&"fire"), 9, "Kilnkeeper: three actual phase-two fire contacts")
	check_eq(boss.melt_ticks, 3, "Kilnkeeper: three ticks recorded")
	check(not boss.is_molten(), "Kilnkeeper: three ticks do not melt phase-two armour")
	check_eq(boss.hp, 6, "Kilnkeeper: three phase-two ticks deal six")
	for i in range(50):
		if hits.count(&"fire") >= 10:
			break
		await frames(1)
	check_eq(hits.count(&"fire"), 10, "Kilnkeeper: fourth actual phase-two fire contact")
	check(boss.is_molten(), "Kilnkeeper: fourth tick melts phase-two armour")
	check_eq(boss.hp, 4, "Kilnkeeper: four phase-two ticks deal eight")
	# Allow the previous fire hit's normal i-frames to expire before the next hook.
	await frames(17)
	player.place_at(boss.global_position - Vector2(140, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(hits.count(&"hook"), 2, "Kilnkeeper: actual hook contacts molten armour")
	check_eq(boss.hp, 2, "Kilnkeeper: molten armour permits actual hook damage")
	print("MATRIX Kilnkeeper phase two: hits=", hits, " fire_phases=", fire_phases, " damage=", damage)
	await dispose(arena)


func _choir_warden_moth() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(
		arena, "res://scenes/enemies/minibosses/choir_warden.tscn", Vector2(600, 480)
	)
	var player := make_player(arena, Vector2(1700, 480))
	for i in range(400):
		if enemy.state == enemy.State.SING:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.SING, "Choir Warden reaches natural song")
	player.place_at(enemy.global_position - Vector2(90, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 20, "Choir Warden: real hook cannot damage singing mouth")
	await frames(20)
	player.place_at(enemy.global_position - Vector2(240, 0))
	_equip(player, &"tether_moth")
	check(player.use_item(), "Choir Warden: actual moth launches during song")
	for i in range(35):
		if enemy.is_stunned():
			break
		await frames(1)
	check(enemy.is_stunned(), "Choir Warden: real moth interrupts song")
	check(not is_instance_valid(enemy._cone), "Choir Warden: interrupted cone disappears")
	player.place_at(enemy.global_position - Vector2(90, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 18, "Choir Warden: real hook damages stunned mouth")
	await dispose(arena)


func _automaton_moth() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(
		arena, "res://scenes/enemies/minibosses/wick_automaton.tscn", Vector2(800, 480)
	)
	var player := make_player(arena, Vector2(710, 480))
	await frames(2)
	# Freeze movement, retaining physics, real item flight and damage processing.
	enemy.move_speed = 0
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 29, "Automaton: real hook deals one through plating")
	await frames(40)
	player.place_at(enemy.global_position - Vector2(240, 0))
	_equip(player, &"tether_moth")
	check(player.use_item(), "Automaton: actual moth launches")
	for i in range(40):
		if enemy.is_stunned():
			break
		await frames(1)
	check(enemy.is_stunned(), "Automaton: real moth opens vent")
	player.place_at(enemy.global_position - Vector2(90, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 27, "Automaton: real hook deals two during stun")
	await dispose(arena)


func _automaton_live_jet_tools() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(
		arena, "res://scenes/enemies/minibosses/wick_automaton.tscn", Vector2(800, 480)
	)
	var player := make_player(arena, Vector2(1200, 480))
	player.set_hurtbox_enabled(self, false)
	enemy.move_speed = 0
	var hits: Array[StringName] = []
	var hit_states: Array[int] = []
	var stun_states: Array[int] = []
	var damage: Array[int] = []
	enemy.hurtbox.hurt.connect(func(hit: Hitbox) -> void:
		hits.append(hit.kind)
		hit_states.append(enemy.state)
	)
	enemy.stunned.connect(func(_seconds: float) -> void: stun_states.append(enemy.state))
	enemy.damaged.connect(func(amount: int) -> void: damage.append(amount))
	for i in range(300):
		if enemy.state == enemy.State.TELL:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.TELL, "Automaton: natural jet warning begins")
	player.place_at(enemy.global_position + Vector2(140, 0))
	_equip(player, &"pitch_pot")
	player.facing = Vector2.LEFT
	GameState.add_pitch_pots(1)
	check(player.use_item(), "Automaton: real pot placed during warning")
	check_eq(GameState.pitch_pots, 0, "Automaton: real pot spends ammo")
	for i in range(60):
		if enemy.state == enemy.State.JET and is_instance_valid(enemy._jet) and enemy._jet.active:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.JET, "Automaton: warning reaches natural live jet")
	check(is_instance_valid(enemy._jet) and enemy._jet.active, "Automaton: real jet is active")
	_equip(player, &"lantern_chime")
	check(player.use_item(), "Automaton: actual chime rings into jet")
	for i in range(25):
		if &"chime" in hits:
			break
		await frames(1)
	check(&"chime" in hits, "Automaton: travelling chime contacts hurtbox")
	if &"chime" in hits:
		check_eq(hit_states[hits.find(&"chime")], enemy.State.JET, "Automaton: chime hits live jet")
	check_eq(enemy.state, enemy.State.JET, "Automaton: chime does not interrupt jet")
	check(not enemy.is_stunned(), "Automaton: chime does not stun")
	check_eq(enemy.hp, 30, "Automaton: chime deals no damage")
	player.place_at(enemy.global_position + Vector2(190, 0))
	_equip(player, &"tether_moth")
	player.facing = Vector2.LEFT
	check(player.use_item(), "Automaton: actual moth launched into live jet")
	for i in range(35):
		if enemy.is_stunned():
			break
		await frames(1)
	check(&"stun" in hits, "Automaton: travelling moth contacts hurtbox")
	check(enemy.is_stunned(), "Automaton: moth stuns during jet")
	check_eq(stun_states, [enemy.State.JET], "Automaton: stun starts in live jet state")
	check_eq(enemy.state, enemy.State.VENT, "Automaton: moth opens vent")
	check(not is_instance_valid(enemy._jet), "Automaton: moth removes active jet")
	check_near(enemy._stun_time, 1.5, 0.08, "Automaton: moth stun is clamped")
	for i in range(100):
		if &"explosion" in hits:
			break
		await frames(1)
	check(&"explosion" in hits, "Automaton: placed pot explosion contacts hurtbox")
	if &"explosion" in hits:
		check_eq(hit_states[hits.find(&"explosion")], enemy.State.VENT, "Automaton: explosion hits open vent")
	check(enemy.is_stunned(), "Automaton: pot lands during moth opening")
	check_eq(damage, [4], "Automaton: actual pot deals four damage")
	check_eq(enemy.hp, 26, "Automaton: real explosion damages brass")
	check(not is_instance_valid(enemy._jet), "Automaton: interrupted jet does not resume")
	print("MATRIX Automaton live jet: contacts=", hits, " states=", hit_states, " damage=", damage)
	await dispose(arena)


func _lurker_moth() -> void:
	reset_state()
	var arena := make_arena()
	var zone := _prop(arena, "shallow_zone", Vector2(900, 400))
	if zone == null:
		await dispose(arena)
		return
	zone.set(&"size", Vector2(600, 192))
	var enemy = make_enemy(
		arena, "res://scenes/enemies/minibosses/sump_lurker.tscn", Vector2(900, 496)
	)
	var player := make_player(arena, Vector2(900, 760))
	await frames(2)
	# Hold each state to isolate actual item collision from the surface cycle.
	enemy.set_physics_process(false)
	enemy._enter(enemy.State.SUBMERGED, 0.0)
	_equip(player, &"tether_moth")
	player.facing = Vector2.UP
	check(player.use_item(), "Lurker: actual moth launches at submerged target")
	await frames(65)
	check(not enemy.is_stunned(), "Lurker: submerged target ignores moth")
	check_eq(enemy.hp, 16, "Lurker: submerged target takes no moth damage")
	enemy._enter(enemy.State.SURFACED, 1.5)
	enemy.hurtbox.invulnerable = false
	player.place_at(Vector2(900, 760))
	check(player.use_item(), "Lurker: actual moth launches at surfaced target")
	await frames(19)
	check(enemy.is_stunned(), "Lurker: real moth stuns surfaced target")
	check_near(enemy._stun_time, 1.5, 0.02, "Lurker: moth stun clamped")
	player.place_at(Vector2(900, 586))
	player.facing = Vector2.UP
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 14, "Lurker: real hook damages surfaced target")
	await dispose(arena)


func _lurker_natural_moth() -> void:
	reset_state()
	var arena := make_arena()
	var zone := _prop(arena, "shallow_zone", Vector2(900, 400))
	if zone == null:
		await dispose(arena)
		return
	zone.set(&"size", Vector2(600, 192))
	var enemy = make_enemy(
		arena, "res://scenes/enemies/minibosses/sump_lurker.tscn", Vector2(900, 496)
	)
	var player := make_player(arena, Vector2(900, 830))
	player.set_hurtbox_enabled(self, false)
	var hits: Array[StringName] = []
	var states: Array[int] = []
	enemy.hurtbox.hurt.connect(func(hit: Hitbox) -> void:
		hits.append(hit.kind)
		states.append(enemy.state)
	)
	await frames(3)
	check_eq(enemy.state, enemy.State.SUBMERGED, "Lurker: naturally remains submerged at distant shore")
	check(not enemy.hurtbox.enabled, "Lurker: submerged hurtbox rejects contact")
	_equip(player, &"tether_moth")
	player.facing = Vector2.UP
	check(player.use_item(), "Lurker: real moth launches toward submerged target")
	var moths := get_tree().get_nodes_in_group(&"item_tether_moth")
	check_eq(moths.size(), 1, "Lurker: real moth exists")
	var overlapped := false
	if not moths.is_empty():
		var moth := moths[0] as Node2D
		var box := moth.get_node_or_null("StunHitbox") as Hitbox
		check(box != null and box.active, "Lurker: real moth hitbox is active")
		for i in range(50):
			await frames(1)
			if not is_instance_valid(box):
				break
			if box.get_overlapping_areas().has(enemy.hurtbox):
				overlapped = true
				check_eq(enemy.state, enemy.State.SUBMERGED, "Lurker: physical overlap occurs submerged")
				break
	check(overlapped, "Lurker: moth hitbox physically overlaps submerged hurtbox")
	check(hits.is_empty(), "Lurker: submerged overlap is not accepted")
	check(not enemy.is_stunned(), "Lurker: submerged overlap does not stun")
	check_eq(enemy.hp, 16, "Lurker: submerged overlap causes no damage")
	for i in range(100):
		if get_tree().get_nodes_in_group(&"item_tether_moth").is_empty():
			break
		await frames(1)
	check(get_tree().get_nodes_in_group(&"item_tether_moth").is_empty(), "Lurker: first moth returns")
	player.place_at(Vector2(900, 680))
	for i in range(180):
		if enemy.state == enemy.State.TELEGRAPH:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.TELEGRAPH, "Lurker: naturally reaches bubble warning")
	for i in range(60):
		if enemy.state == enemy.State.SURFACED:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.SURFACED, "Lurker: naturally surfaces")
	check(enemy.hurtbox.enabled, "Lurker: surfaced hurtbox accepts hits")
	check(is_instance_valid(enemy._bite) and enemy._bite.active, "Lurker: natural bite starts")
	player.facing = Vector2.UP
	check(player.use_item(), "Lurker: real moth launches at surfaced target")
	for i in range(35):
		if enemy.is_stunned():
			break
		await frames(1)
	check(&"stun" in hits, "Lurker: moth hits actual surfaced hurtbox")
	if &"stun" in hits:
		check_eq(states[hits.find(&"stun")], enemy.State.SURFACED, "Lurker: moth hits while surfaced")
	check(enemy.is_stunned(), "Lurker: surfaced moth stuns")
	check_near(enemy._stun_time, 1.5, 0.08, "Lurker: surfaced stun is clamped")
	player.place_at(enemy.global_position + Vector2(0, 90))
	player.facing = Vector2.UP
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check(&"hook" in hits, "Lurker: real hook contacts surfaced hurtbox")
	check_eq(enemy.hp, 14, "Lurker: actual hook deals two in opening")
	print("MATRIX Lurker natural moth: submerged overlap=", overlapped, " accepted=", hits, " states=", states)
	await dispose(arena)


func _captain_moth() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(
		arena, "res://scenes/enemies/minibosses/hollow_captain.tscn", Vector2(850, 480)
	)
	var player := make_player(arena, Vector2(760, 480))
	await frames(2)
	enemy.set_facing_dir(Vector2.LEFT)
	player.facing = Vector2.RIGHT
	var blocks := [0]
	enemy.guard_blocked.connect(func(_hit: Hitbox) -> void: blocks[0] += 1)
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(blocks[0], 1, "Captain: actual front hook contacts guard")
	check_eq(enemy.hp, 12, "Captain: front guard prevents hook damage")
	await frames(25)
	player.place_at(enemy.global_position - Vector2(250, 0))
	_equip(player, &"tether_moth")
	check(player.use_item(), "Captain: actual moth launches")
	for i in range(40):
		if enemy.is_stunned():
			break
		await frames(1)
	check(enemy.is_stunned(), "Captain: actual moth stuns and drops guard")
	player.place_at(enemy.global_position - Vector2(90, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(enemy.hp, 10, "Captain: real front hook damages stunned target")
	await dispose(arena)


func _captain_natural_bash_sling() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(
		arena, "res://scenes/enemies/minibosses/hollow_captain.tscn", Vector2(800, 480)
	)
	var player := make_player(arena, Vector2(1300, 480))
	player.set_hurtbox_enabled(self, false)
	var hits: Array[StringName] = []
	var states: Array[int] = []
	var blocks: Array[StringName] = []
	var damage: Array[int] = []
	enemy.hurtbox.hurt.connect(func(hit: Hitbox) -> void:
		hits.append(hit.kind)
		states.append(enemy.state)
	)
	enemy.guard_blocked.connect(func(hit: Hitbox) -> void: blocks.append(hit.kind))
	enemy.damaged.connect(func(amount: int) -> void: damage.append(amount))
	for i in range(150):
		if enemy.facing_dir.dot(Vector2.RIGHT) > 0.99:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.PATROL, "Captain: naturally patrols behind raised guard")
	check(enemy.facing_dir.dot(Vector2.RIGHT) > 0.99, "Captain: naturally turns toward player")
	player.place_at(enemy.global_position + Vector2(200, 0))
	_equip(player, &"tallow_sling")
	player.facing = Vector2.LEFT
	check(player.use_item(), "Captain: real sling fires at front guard")
	for i in range(40):
		if not blocks.is_empty():
			break
		await frames(1)
	check_eq(hits, [&"sling"], "Captain: actual slug reaches guarded hurtbox")
	check_eq(blocks, [&"sling"], "Captain: raised guard blocks actual slug")
	check_eq(enemy.hp, 12, "Captain: guarded slug deals no damage")
	check_eq(GameState.slugs, 11, "Captain: guarded slug consumes ammo")
	player.place_at(enemy.global_position + Vector2(1000, 0))
	for i in range(300):
		if enemy.state == enemy.State.TELEGRAPH:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.TELEGRAPH, "Captain: natural shield-bash warning")
	for i in range(60):
		if enemy.state == enemy.State.BASH:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.BASH, "Captain: warning leads to real bash")
	check_eq(enemy.contact_hitbox.damage, 3, "Captain: actual bash contact is active")
	for i in range(60):
		if enemy.state == enemy.State.RECOVER:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.RECOVER, "Captain: real bash leads to recovery")
	check_eq(enemy.armor_front_deg, 0.0, "Captain: guard drops during recovery")
	check(enemy.facing_dir.dot(Vector2.RIGHT) > 0.99, "Captain: still faces shot direction")
	player.place_at(enemy.global_position + Vector2(170, 0))
	player.facing = Vector2.LEFT
	check(player.use_item(), "Captain: real sling fires from front during recovery")
	for i in range(40):
		if hits.size() >= 2:
			break
		await frames(1)
	check_eq(hits, [&"sling", &"sling"], "Captain: second real slug hits")
	check_eq(states, [enemy.State.PATROL, enemy.State.RECOVER], "Captain: hits land in intended phases")
	check_eq(blocks, [&"sling"], "Captain: recovery slug is not blocked")
	check_eq(damage, [1], "Captain: unguarded slug deals one damage")
	check_eq(enemy.hp, 11, "Captain: recovery hit damages miniboss")
	check_eq(GameState.slugs, 10, "Captain: both real shots spend ammo")
	print("MATRIX Captain natural bash: hits=", hits, " states=", states, " blocked=", blocks, " damage=", damage)
	await dispose(arena)


func _lock_plate_tools() -> void:
	reset_state()
	var scene := load("res://tests/fixtures/gallery/B09.tscn") as PackedScene
	check(scene != null, "Lock Warden gallery loads")
	if scene == null:
		return
	var room := scene.instantiate() as Room
	add_child(room)
	room.enter()
	var boss = room.get_node("Enemies/LockWarden")
	var player := make_player(room, Vector2(300, 192))
	# Isolate the plate interaction from concurrent attacks and wicklings.
	player.set_hurtbox_enabled(self, false)
	GameState.acquire_item(&"tallow_sling")
	GameState.acquire_item(&"pitch_pot")
	GameState.add_pitch_pots(2)
	await seconds(1.6)
	check_eq(boss.plates.size(), 4, "Lock Warden: four plates after intro")
	var plate = boss.plates[0]
	_equip(player, &"pitch_pot")
	player.place_at(plate.global_position + Vector2(-192, 0))
	check(player.use_item(), "Lock Warden: actual pot placed at closed plate")
	player.place_at(Vector2(300, 192))
	await seconds(1.9)
	check_eq(boss.plates.size(), 4, "Lock Warden: closed plate survives real blast")
	check_eq(plate.hp, 4, "Lock Warden: closed lid blocks pot damage")
	_equip(player, &"tallow_sling")
	player.place_at(plate.eye.global_position + Vector2(-240, 0))
	check(player.use_item(), "Lock Warden: actual sling fires at eye")
	await seconds(0.5)
	check(plate.lid_left > 5, "Lock Warden: real slug opens lid")
	_equip(player, &"pitch_pot")
	player.place_at(plate.global_position + Vector2(-192, 0))
	check(player.use_item(), "Lock Warden: actual pot placed at open plate")
	player.place_at(Vector2(300, 192))
	await seconds(1.9)
	check_eq(boss.plates.size(), 3, "Lock Warden: real blast breaks open plate")
	await dispose(room)


func _mauler_slag_hook() -> void:
	reset_state()
	var arena := make_arena()
	var enemy = make_enemy(
		arena, "res://scenes/enemies/minibosses/lull_mauler.tscn", Vector2(800, 480)
	)
	var player := make_player(arena, Vector2(1300, 480))
	for i in range(240):
		if enemy.state == enemy.State.RECOVER:
			break
		await frames(1)
	check_eq(enemy.state, enemy.State.RECOVER, "Mauler: natural smash reaches recovery")
	var chunks := arena.get_children().filter(func(n: Node) -> bool: return n.is_in_group(&"liftable"))
	check_eq(chunks.size(), 1, "Mauler: actual smash creates one slag chunk")
	if chunks.size() != 1:
		await dispose(arena)
		return
	var chunk = chunks[0]
	await frames(10)
	# Freeze the enemy and position the real chunk to isolate deflected flight.
	enemy.set_physics_process(false)
	chunk.global_position = enemy.global_position + Vector2(300, 0)
	player.place_at(chunk.global_position + Vector2(90, 0))
	player.facing = Vector2.LEFT
	await frames(3)
	Input.action_press(&"attack")
	await frames(7)
	Input.action_release(&"attack")
	check(chunk.deflected, "Mauler: actual hook deflects smash-created slag")
	await frames(40)
	check_eq(enemy.hp, 20, "Mauler: returned real slag deals four")
	check(not is_instance_valid(chunk), "Mauler: returned chunk shatters")
	check_eq(GameState.health, 6, "Mauler: player avoids damage in fixture")
	await dispose(arena)


func _knight_boots() -> void:
	reset_state()
	var scene := load("res://tests/fixtures/gallery/B07.tscn") as PackedScene
	check(scene != null, "Gloam Knight gallery loads")
	if scene == null:
		return
	var room := scene.instantiate() as Room
	add_child(room)
	room.enter()
	var boss = room.get_node("Enemies/GloamKnight")
	var player := make_player(room, Vector2(960, 192))
	# Disable combat damage to isolate island access; pit damage remains active.
	player.set_hurtbox_enabled(self, false)
	await seconds(1.7)
	player.place_at(Vector2(960, 240))
	player.facing = Vector2.DOWN
	Input.action_press(&"attack")
	await frames(10)
	Input.action_release(&"attack")
	check_eq(boss.hp, 36, "Gloam Knight: entry hook cannot reach centre")
	await frames(25)
	player.place_at(Vector2(960, 240))
	_equip(player, &"skitter_boots")
	player.facing = Vector2.DOWN
	check(player.use_item(), "Gloam Knight: actual boots launch across pit")
	await seconds(0.45)
	check_near(player.global_position.y, 432, 1, "Gloam Knight: boots land on centre island")
	check_eq(GameState.health, 6, "Gloam Knight: leap avoids pit damage")
	await seconds(0.5)
	player.facing = Vector2.DOWN
	Input.action_press(&"attack")
	await frames(9)
	Input.action_release(&"attack")
	check(boss.hp < 36, "Gloam Knight: real hook reaches boss after leap")
	await dispose(room)


func _colossus_shard() -> void:
	reset_state()
	var arena := make_arena()
	var boss = make_enemy(
		arena, "res://scenes/enemies/bosses/hushed_colossus.tscn", Vector2(960, 640)
	)
	var player := make_player(arena, Vector2(400, 400))
	player.set_hurtbox_enabled(self, false)
	_equip(player, &"heft_mitts")
	await frames(95)
	# Hold boss movement and attack timers; spawn its real falling shard explicitly.
	boss.move_speed = 0
	boss.slam_left = 100
	boss.shard_left = 100
	boss.sweep_left = 100
	boss.quake_left = 100
	boss.start_attack(&"fall", boss.global_position + Vector2(-300, 0), 1.0, 0.1)
	await frames(65)
	check(not boss.shards.is_empty(), "Colossus: actual falling shard lands")
	if boss.shards.is_empty():
		await dispose(arena)
		return
	var shard = boss.shards.back()
	player.place_at(shard.global_position - Vector2(72, 0))
	player.facing = Vector2.RIGHT
	await frames(3)
	check(player.use_item(), "Colossus: actual mitts grab shard")
	await frames(22)
	check(shard.is_carried(), "Colossus: shard is carried")
	Input.action_press(&"use_item")
	await frames(2)
	Input.action_release(&"use_item")
	await frames(55)
	check_eq(boss.hp, 42, "Colossus: real thrown shard deals six")
	await dispose(arena)


func _matrix_room(path: String) -> Room:
	var scene := load(path) as PackedScene
	check(scene != null, "encounter gallery loads: " + path)
	if scene == null:
		return null
	var room := scene.instantiate() as Room
	add_child(room)
	room.enter()
	return room


func _mirror_braziers() -> void:
	reset_state()
	var arena := make_arena()
	var braziers: Array[Brazier] = []
	for i in range(4):
		var brazier := Brazier.new()
		brazier.position = Vector2(200 + (i % 2) * 1400, 200 + (i / 2) * 560)
		brazier.brazier_id = StringName("matrix_mirror_%d" % i)
		arena.add_child(brazier)
		braziers.append(brazier)
	var enemy = make_enemy(
		arena, "res://scenes/enemies/minibosses/mirror_warden.tscn", Vector2(800, 480)
	)
	var player := make_player(arena, Vector2(200, 290))
	await frames(2)
	# Frozen encounter and explicit refresh isolate the room's real brazier interactions.
	enemy.set_physics_process(false)
	for i in range(4):
		player.place_at(braziers[i].global_position + Vector2(0, 90))
		player.facing = Vector2.UP
		await frames(3)
		Input.action_press(&"attack")
		await frames(8)
		Input.action_release(&"attack")
		await frames(20)
		enemy._refresh_decoys()
		check(braziers[i].lit, "Mirror Warden: actual hook lights brazier")
		check_eq(enemy.lit_brazier_count(), i + 1, "Mirror Warden: counts lit braziers")
		for decoy in enemy.decoys:
			check_near(decoy.modulate.a, 1.0 - 0.25 * (i + 1), 0.001, "Mirror: decoy fades")
	check(not enemy.decoys[0].visible and not enemy.decoys[1].visible, "Mirror: decoys gone")
	await dispose(arena)


func _dirge_chime() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(336, 480))
	var boss = make_enemy(
		arena, "res://scenes/enemies/bosses/dirge_choir.tscn", Vector2.ZERO
	)
	player.set_hurtbox_enabled(self, false)
	await frames(95)
	# Hold cadence and explicitly begin the warning to isolate the chime window.
	boss.song_left = 100
	var head = boss.heads[0]
	head.cancel_song()
	head.begin_song()
	_equip(player, &"lantern_chime")
	check(player.use_item(), "Dirge: actual chime rings during warning")
	await frames(34)
	check(head.open_left > 3, "Dirge: real chime opens singing head")
	check_eq(head.song_age, -1.0, "Dirge: chime interrupts song")
	player.place_at(head.global_position + Vector2(0, -100))
	player.facing = Vector2.DOWN
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(head.hp, 10, "Dirge: actual hook deals two to open head")
	await dispose(arena)


func _dirge_natural_chime() -> void:
	reset_state()
	var arena := make_arena()
	var boss = make_enemy(arena, "res://scenes/enemies/bosses/dirge_choir.tscn", Vector2.ZERO)
	var player := make_player(arena, Vector2(336, 620))
	player.set_hurtbox_enabled(self, false)
	for i in range(180):
		if boss.heads.size() == 3 and boss.heads_active():
			break
		await frames(1)
	check_eq(boss.heads.size(), 3, "Dirge: real three heads spawned")
	check(boss.heads_active(), "Dirge: natural intro finishes")
	if boss.heads.size() != 3:
		await dispose(arena)
		return
	var head = boss.heads[0]
	var hits: Array[StringName] = []
	var damage: Array[int] = []
	head.hurtbox.hurt.connect(func(hit: Hitbox) -> void: hits.append(hit.kind))
	head.damaged.connect(func(amount: int) -> void: damage.append(amount))
	for i in range(60):
		if head.song_age >= 0.0:
			break
		await frames(1)
	check(head.song_age >= 0.0 and head.song_age < 0.8, "Dirge: bass naturally begins warning")
	check_eq(head.open_left, 0.0, "Dirge: humming head starts protected")
	player.facing = Vector2.DOWN
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check(&"hook" in hits, "Dirge: actual hook contacts protected bass")
	check_eq(head.hp, 12, "Dirge: protected bass rejects real hook damage")
	for i in range(20):
		if player.state == player.State.NORMAL:
			break
		await frames(1)
	check_eq(player.state, player.State.NORMAL, "Dirge: hook recovery ends before chime")
	_equip(player, &"lantern_chime")
	check(player.use_item(), "Dirge: actual chime rings during natural warning")
	for i in range(30):
		if &"chime" in hits:
			break
		await frames(1)
	check(&"chime" in hits, "Dirge: real wave contacts singing bass")
	check(head.open_left > 3.8, "Dirge: timely chime opens bass")
	check_eq(head.song_age, -1.0, "Dirge: real chime interrupts natural song")
	check(head.songs.is_empty(), "Dirge: interrupted song hazards removed")
	await frames(25)
	player.facing = Vector2.DOWN
	Input.action_press(&"attack")
	await frames(8)
	Input.action_release(&"attack")
	check_eq(hits.count(&"hook"), 2, "Dirge: second real hook contacts open bass")
	check_eq(damage, [2], "Dirge: only open hook deals two damage")
	check_eq(head.hp, 10, "Dirge: opened bass takes actual hook damage")
	for i in range(360):
		if head.song_age >= 0.0 and head.deaf_left > 0.0:
			break
		await frames(1)
	check(head.song_age >= 0.0, "Dirge: bass naturally sings again")
	check(head.deaf_left > 0.0 and head.open_left == 0.0, "Dirge: repeat song occurs while deaf")
	check(player.use_item(), "Dirge: actual chime rings during deaf song")
	for i in range(35):
		if hits.count(&"chime") >= 2:
			break
		await frames(1)
	check_eq(hits.count(&"chime"), 2, "Dirge: second travelling chime contacts bass")
	check(head.deaf_left > 0.0, "Dirge: deaf period remains during second contact")
	check_eq(head.open_left, 0.0, "Dirge: deaf bass does not reopen")
	check(head.song_age >= 0.0, "Dirge: deaf song is not interrupted")
	check_eq(head.hp, 10, "Dirge: chime itself deals no damage")
	print("MATRIX Dirge natural cycle: contacts=", hits, " damage=", damage,
		" deaf_left=", head.deaf_left, " song_age=", head.song_age)
	await dispose(arena)


func _archivist_jar() -> void:
	reset_state()
	var room := await _matrix_room("res://tests/fixtures/gallery/B05.tscn")
	if room == null:
		return
	var boss = room.get_node("Enemies/Archivist")
	var player := make_player(room, Vector2(960, 300))
	player.set_hurtbox_enabled(self, false)
	await seconds(1.6)
	# Direct damage selects phase two; the jar and page-break hook are real actions.
	boss.apply_damage(10, boss.global_position, 0)
	await seconds(2.2)
	check(boss.copying and boss.copies.size() == 3, "Archivist: phase-two copies active")
	check(not boss.shadow.visible, "Archivist: shadow hidden before jar")
	_equip(player, &"glow_jar")
	player.place_at(Vector2(960, 192))
	player.facing = Vector2.DOWN
	check(player.use_item(), "Archivist: actual jar thrown")
	await seconds(0.6)
	check(boss.jar_lit() and boss.shadow.visible, "Archivist: real jar reveals shadow")
	for copy in boss.copies:
		check(copy.get_node_or_null("Shadow") == null, "Archivist: decoy has no shadow")
	player.place_at(boss.global_position + Vector2(0, 108))
	player.facing = Vector2.UP
	Input.action_press(&"attack")
	await frames(10)
	Input.action_release(&"attack")
	check_eq(boss.hp, 16, "Archivist: actual hook page break deals four")
	check(not boss.copying and boss.copies.is_empty(), "Archivist: page break removes copies")
	await dispose(room)


func _tidewick_raft() -> void:
	reset_state()
	var room := await _matrix_room("res://tests/fixtures/gallery/B03.tscn")
	if room == null:
		return
	var boss = room.get_node("Enemies/Tidewick")
	var dock = room.get_node("Props/Basin/Dock")
	var player := make_player(room, dock.landing_position())
	player.set_hurtbox_enabled(self, false)
	_equip(player, &"reed_raft")
	check(player.use_item(), "Tidewick: actual raft boards from dock")
	await seconds(0.4)
	check(player.is_on_raft(), "Tidewick: rider aboard")
	Input.action_press(&"move_right")
	await seconds(0.6)
	release_inputs()
	await seconds(0.5)
	for i in range(360):
		if boss.tail_exposed():
			break
		await frames(1)
	check(boss.tail_exposed(), "Tidewick: natural tail exposure reached")
	# Controlled public raft displacement tracks the moving tail during the swing.
	for i in range(2):
		player.push_raft(boss.tail.global_position + Vector2(0, 75) - player.global_position)
		player.facing = Vector2.UP
		await frames(1)
	Input.action_press(&"attack")
	for i in range(7):
		player.push_raft(boss.tail.global_position + Vector2(0, 75) - player.global_position)
		await frames(1)
	Input.action_release(&"attack")
	await frames(22)
	check_eq(boss.hp, 22, "Tidewick: real raft rider hook damages exposed tail")
	await dispose(room)


func _unlit_tools() -> void:
	reset_state()
	var room := await _matrix_room("res://tests/fixtures/gallery/B10.tscn")
	if room == null:
		return
	var boss = room.get_node("Enemies/TheUnlit")
	var player := make_player(room, Vector2(1632, 480))
	player.set_hurtbox_enabled(self, false)
	_equip(player, &"tallow_sling")
	await seconds(1.6)
	check_eq(boss.eyes.size(), 5, "Unlit: phase one has five eyes")
	# Advance through the encounter with actual slugs, flames, reel and hook.
	GameState.add_slugs(30)
	for eye in boss.eyes.duplicate():
		var attempts := 0
		while is_instance_valid(eye) and not eye.is_dead and attempts < 12:
			while is_instance_valid(eye) and eye.global_position.y < 180:
				await frames(6)
			if not is_instance_valid(eye):
				break
			player.place_at(eye.global_position + Vector2(0, 80))
			player.facing = Vector2.UP
			if player.use_item():
				attempts += 1
			await seconds(0.35)
		check(not is_instance_valid(eye) or eye.is_dead, "Unlit: real slugs defeat eye")
	check_eq(boss.phase, 2, "Unlit: five eyes defeated by sling")
	check_eq(boss.hp, 60, "Unlit: shell starts at 36 HP")
	await seconds(1.3)
	_equip(player, &"cinder_wick")
	for cast in range(3):
		player.place_at(boss.global_position + Vector2(0, 180))
		player.facing = Vector2.UP
		check(player.use_item(), "Unlit: real wick launches at shell")
		await seconds(0.3)
		player.place_at(Vector2(1632, 720))
		await seconds(3.7)
	check_eq(boss.phase, 3, "Unlit: three real flames burn shell away")
	check_eq(boss.hp, 24, "Unlit: heart starts at 24 HP")
	await seconds(1.3)
	player.place_at(boss.global_position + Vector2(0, 108))
	player.facing = Vector2.UP
	Input.action_press(&"attack")
	await frames(10)
	Input.action_release(&"attack")
	check_eq(boss.hp, 24, "Unlit: actual hook cannot hit shielded heart")
	await seconds(0.4)
	_equip(player, &"reel_line")
	player.place_at(Vector2(960, 720))
	player.facing = Vector2.UP
	check(player.use_item(), "Unlit: real reel launches at lantern")
	await seconds(0.9)
	check(boss.exposed_left > 0, "Unlit: reel exposes heart")
	check_near(boss.lantern.global_position.distance_to(Vector2(960, 288)), 288, 0.5,
		"Unlit: reel moves lantern 288 pixels")
	player.place_at(boss.global_position + Vector2(0, 108))
	player.facing = Vector2.UP
	Input.action_press(&"attack")
	await frames(10)
	Input.action_release(&"attack")
	check_eq(boss.hp, 22, "Unlit: actual hook damages exposed heart")
	print("MATRIX Unlit: sling eyes, wick shell, reel and hook heart")
	await dispose(room)
