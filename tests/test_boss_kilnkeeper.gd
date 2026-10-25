extends TestCase

const BOSS := "res://scenes/enemies/bosses/kilnkeeper.tscn"
const FLAG := &"boss_cave_1_8_defeated"


func run() -> void:
	await _death_contact()
	await _armour_and_fight()
	await _molten_expiry_and_splash()
	await _attacks_and_reset()
	await _arena_scene()


func _death_contact() -> void:
	reset_state()
	var arena := make_arena()
	var boss = _boss(arena, Vector2(800, 480))
	await seconds(1.6)
	check(boss.contact_hitbox.active, "living boss enables contact after intro")
	boss.apply_damage(99, boss.global_position, 0.0)
	check(boss.is_dying(), "lethal damage starts real boss death throes")
	check_eq(boss.contact_hitbox.damage, 0, "death disables contact damage immediately")
	# A later enable request must not restore damage during death throes.
	boss.set_contact_enabled(true)
	var player := make_player(arena, boss.global_position)
	var health := GameState.health
	await frames(5)
	check(not boss.contact_hitbox.active, "death disables contact monitoring safely")
	check_eq(GameState.health, health, "overlapping real player takes no death contact damage")
	await seconds(1.0)
	check_eq(GameState.health, health, "contact stays harmless throughout death throes")
	player.place_at(Vector2(192, 192))
	boss.reset_fight()
	check(not boss.contact_hitbox.active, "reset keeps contact off during intro")
	check_eq(boss.contact_hitbox.damage, 0, "reset intro keeps immediate damage off")
	await seconds(1.6)
	check(boss.contact_hitbox.active, "reset restores contact after the new intro")
	check_eq(boss.contact_hitbox.damage, 2, "reset restores normal contact damage")
	player.place_at(boss.global_position)
	await frames(5)
	check_eq(GameState.health, health - 2, "living reset boss damages an overlapping player")
	await dispose(arena)


func _boss(parent: Node2D, at: Vector2) -> Variant:
	var scene := load(BOSS) as PackedScene
	check(scene != null, "real Kilnkeeper scene loads")
	if scene == null:
		return null
	var boss = scene.instantiate()
	parent.add_child(boss)
	boss.global_position = at
	boss.room_rect = Rect2(96, 96, 1728, 768)
	return boss


func _hit(arena: Node2D, boss: Variant, kind: StringName, damage: int) -> void:
	var hit := make_hitbox(arena, boss.global_position, Layers.Team.PLAYER, damage, 65)
	hit.kind = kind
	hit.knockback = 0
	await frames(3)
	await dispose(hit)
	await seconds(0.3)


func _swing(player: Player, boss: Variant) -> void:
	player.place_at(boss.global_position - Vector2(140, 0))
	player.facing = Vector2.RIGHT
	Input.action_press(&"attack")
	await frames(6)
	Input.action_release(&"attack")
	await frames(22)


func _cast(player: Player, boss: Variant) -> void:
	player.place_at(boss.global_position - Vector2(200, 0))
	player.facing = Vector2.RIGHT
	GameState.acquire_item(&"cinder_wick")
	GameState.set_active_item(&"cinder_wick")
	check(player.use_item(), "actual cinder wick activates")
	# Moving the player off the charge line is normal gameplay; the attached flame follows the boss.
	await seconds(0.7)
	player.place_at(Vector2(192, 192))


func _armour_and_fight() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(192, 192))
	player.set_hurtbox_enabled(self, false)
	var boss = _boss(arena, Vector2(1000, 480))
	await seconds(1.6)
	check_eq(boss.hp, 24, "intro completes at full HP")
	for kind in [&"hook", &"flare", &"explosion", &"sling", &"thrown"]:
		await _hit(arena, boss, kind, 4)
	check_eq(boss.hp, 24, "all hard nonfire hits clink, including flare and pot")
	check_eq(boss.melt_ticks, 0, "nonfire never melts wax")
	await _cast(player, boss)
	for _i in range(120):
		if boss.is_molten():
			break
		await frames(1)
	check(boss.is_molten(), "real flame melts phase 1")
	check_eq(boss.melt_ticks, 3, "phase 1 needs three actual flame ticks")
	check_eq(boss.hp, 18, "threshold tick deals two HP exactly once")
	check(boss.molten_left > 7.8, "phase 1 molten window starts at eight seconds")
	# Stop this flame through its real lifecycle; the remaining ticks are real damage too.
	await seconds(3.1)
	if boss.phase == 1:
		await _hit(arena, boss, &"hook", 2)
	check_eq(boss.phase, 2, "real flame and hook damage cross the 12 HP threshold")
	check(boss.hp <= 12, "phase 2 starts at 12 HP or below")
	await seconds(1.3)
	check(not boss.is_molten(), "phase change restores hard wax")
	check_eq(boss.melt_ticks, 0, "phase change clears melt count")
	await _cast(player, boss)
	for _i in range(150):
		if boss.is_molten() or boss.is_dying():
			break
		await frames(1)
	check(boss.is_molten(), "real flame melts phase 2")
	check_eq(boss.melt_ticks, 4, "phase 2 needs four actual ticks")
	check_eq(boss.hp, 4, "four phase 2 fire ticks each deal two HP, once")
	check(boss.molten_left > 5.8, "phase 2 molten window starts at six seconds")
	# Stop the remaining flame so the real player hook delivers the finishing blows.
	for flame in get_tree().get_nodes_in_group(&"cinder_flames"):
		flame.queue_free()
	await frames(2)
	for _attempt in range(12):
		if boss.is_dying():
			break
		await _swing(player, boss)
	check(boss.is_dying(), "hook finishes the molten boss")
	check(GameState.has_flag(FLAG), "defeat writes the arena flag")
	check(not boss.is_arena_locked(), "death releases the inherited arena lock")
	await seconds(1.6)
	check(not is_instance_valid(boss), "death throes finish after 1.5 seconds")
	var retired = _boss(arena, Vector2(1000, 480))
	check(retired.is_dead and not retired.visible, "defeated boss stays dead on reentry")
	await dispose(arena)


func _molten_expiry_and_splash() -> void:
	reset_state()
	var arena := make_arena()
	var player := make_player(arena, Vector2(192, 192))
	player.set_hurtbox_enabled(self, false)
	var boss = _boss(arena, Vector2(1100, 480))
	await seconds(1.6)
	await _cast(player, boss)
	for _i in range(120):
		if boss.is_molten():
			break
		await frames(1)
	check(boss.is_molten(), "splash scenario melts through real fire")
	for flame in get_tree().get_nodes_in_group(&"cinder_flames"):
		flame.queue_free()
	await frames(2)
	for _i in range(190):
		if boss.attack == boss.Attack.SPLASH_WARNING:
			break
		await frames(1)
	check_eq(boss.attack, boss.Attack.SPLASH_WARNING, "molten wax warns before its splash")
	player.place_at(boss.global_position - Vector2(110, 0))
	player.facing = Vector2.RIGHT
	player.set_hurtbox_enabled(self, true)
	Input.action_press(&"ward")
	var health := GameState.health
	await seconds(0.65)
	check_eq(GameState.health, health - 2, "wax splash hits through the raised ward")
	Input.action_release(&"ward")
	player.set_hurtbox_enabled(self, false)
	player.place_at(Vector2(192, 192))
	await seconds(5.0)
	check(not boss.is_molten(), "phase 1 hardens after eight seconds")
	check_eq(boss.melt_ticks, 0, "hardening clears the old fire ticks")
	var hp_before: int = boss.hp
	await _hit(arena, boss, &"hook", 2)
	check_eq(boss.hp, hp_before, "hardened wax blocks the hook again")
	await dispose(arena)


func _attacks_and_reset() -> void:
	reset_state()
	var arena := make_arena([Rect2(700, 96, 96, 768)])
	var player := make_player(arena, Vector2(1200, 480))
	player.set_hurtbox_enabled(self, false)
	var boss = _boss(arena, Vector2(500, 480))
	await seconds(1.6)
	await seconds(3.1)
	check_eq(boss.attack, boss.Attack.FAN_WARNING, "fan waits behind its 0.6 second warning")
	for _i in range(40):
		if not get_tree().get_nodes_in_group(&"projectiles").is_empty():
			break
		await frames(1)
	var shots := get_tree().get_nodes_in_group(&"projectiles")
	check_eq(shots.size(), 3, "phase 1 slag fan has three balls")
	for shot in shots:
		check_eq(shot.damage, 2, "slag deals two half hearts")
		check_near(shot.speed, 300, 0.01, "slag speed is 300")
		check(shot.hitbox.blockable, "ward blocks slag")
	await seconds(4.5)
	for _i in range(150):
		if boss.attack == boss.Attack.RECOVER:
			break
		await frames(1)
	check_eq(boss.attack, boss.Attack.RECOVER, "rush stops and recovers on a solid pillar")
	check(boss.global_position.x <= 641, "rush does not cross the pillar")
	boss.reset_fight()
	check_eq(boss.hp, 24, "reset restores HP")
	check_eq(boss.phase, 1, "reset restores phase 1")
	check_eq(boss.melt_ticks, 0, "reset clears armour state")
	check(boss.is_in_intro(), "reset restarts intro")
	await frames(2)
	check_eq(get_tree().get_nodes_in_group(&"projectiles").size(), 0, "reset clears all slag")
	await dispose(arena)


func _arena_scene() -> void:
	reset_state()
	var scene := load("res://tests/fixtures/gallery/B01.tscn") as PackedScene
	check(scene != null, "gallery loads")
	if scene == null:
		return
	var room := scene.instantiate() as Room
	add_child(room)
	room.enter()
	var viewer := make_player(room, Vector2(192, 480))
	viewer.set_hurtbox_enabled(self, false)
	await frames(2)
	var props := room.get_node("Props/Arena")
	for index in range(4):
		var pillar := props.get_node("Pillar%d" % index) as SolidBlock
		check_eq(pillar.size, Vector2(96, 96), "solid pillar is one tile")
		check_eq(pillar.collision_layer, Layers.WORLD, "pillar blocks WORLD bodies")
	var fragment := props.get_node("Fragment") as PickupBase
	var core := props.get_node("WickCore") as PickupBase
	check_eq(fragment.scope, &"c1", "fragment is scoped to C1")
	check_eq(fragment.persistent_id, &"frag_c1", "placed fragment has the planned ID")
	check_eq(core.persistent_id, &"wick_core_c1", "placed core has the planned ID")
	check_eq(fragment.requires_flag, FLAG, "fragment waits for defeat")
	check(not fragment.visible and not core.visible, "rewards stay hidden before defeat")
	check_eq(room.exits, [&"w"], "west retreat stays open, no physical shutter")
	var boss = room.get_node("Enemies/Kilnkeeper")
	await seconds(4.0)
	check_eq(boss.phase, 1, "capture demonstration is genuinely in phase 1 at four seconds")
	check(boss.is_molten(), "capture demonstration shows real molten wax")
	var largest_fan := 0
	for _i in range(330):
		largest_fan = maxi(largest_fan, get_tree().get_nodes_in_group(&"projectiles").size())
		await frames(1)
	check_eq(boss.phase, 2, "capture demonstration reaches phase 2 through actual fire")
	check(boss.is_molten(), "phase 2 capture has the four-tick molten state")
	check(largest_fan >= 5, "phase 2 demonstration fires its five-ball fan")
	await dispose(room)
