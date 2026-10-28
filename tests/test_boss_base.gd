extends TestCase
## BossBase (phases, intro, death, flag, arena lock, resupply, parts), BossPart, Telegraph, and the
## monster API of monsters-bosses-tools 7.2 (stun/knockback scale, chime stun, front guard, water flags,
## hitbox tick interval and carrier rule, capsule and homing projectiles).

const TELEGRAPH := preload("res://scripts/enemies/telegraph.gd")

var _finished := 0
var _hits := 0
var _blocked := 0


class Probe:
	extends "res://scripts/enemies/boss_base.gd"
	var entered: Array[int] = []
	var physics_ticks: int = 0
	var part_damage: int = 0
	var part_deaths: int = 0
	var resets: int = 0

	func reset_fight() -> void:
		resets += 1
		super()

	func _enter_phase(number: int) -> void:
		entered.append(number)

	func _boss_physics(_delta: float) -> void:
		physics_ticks += 1

	func _on_part_hurt(amount: int, _part: EnemyBase) -> void:
		part_damage += amount

	func _on_part_defeated(_part: EnemyBase) -> void:
		part_deaths += 1


class Eye:
	extends "res://scripts/enemies/boss_part.gd"

	func _init() -> void:
		max_hp = 4
		accepted_kinds = [&"sling"]


class Door:
	extends Node2D
	var locked: bool = false

	func set_locked(value: bool) -> void:
		locked = value


class Flyer:
	extends EnemyBase

	func _init() -> void:
		ignore_water = true


class Guarded:
	extends EnemyBase

	func _init() -> void:
		max_hp = 10
		contact_damage = 0
		drops_enabled = false

	func _enemy_ready() -> void:
		armor_front_deg = 140.0
		facing_dir = Vector2.RIGHT


func run() -> void:
	await _phases_and_flag()
	await _intro()
	await _hazards_and_phase_effects()
	await _arena_lock_and_reset()
	await _death_interrupted_by_player_death()
	await _subclass_death_interrupted_by_player_death()
	await _reset_combat_state()
	await _reset_intro_combat_state()
	await _miniboss_mode()
	await _defeated_stays_dead()
	await _resupply_and_death_drops()
	await _parts()
	await _telegraph()
	await _stun_knockback_chime()
	await _front_guard()
	await _water_flags()
	await _tick_interval()
	await _carrier_rule()
	await _capsule_and_homing()
	await _scenes()


func _make_boss(boss_id: StringName, arena_name: StringName, thresholds_list: Array[int]) -> Probe:
	var boss := Probe.new()
	boss.boss_id = boss_id
	boss.arena_id = arena_name
	boss.max_hp = 24
	boss.intro_time = 0.0
	boss.thresholds = thresholds_list
	return boss


func _phases_and_flag() -> void:
	reset_state()
	var arena := make_arena()
	var boss := _make_boss(&"test", &"cave_test_1", [12])
	arena.add_child(boss)
	boss.global_position = Vector2(960, 480)
	var phases_seen: Array[int] = []
	boss.phase_changed.connect(func(n: int) -> void: phases_seen.append(n))
	await frames(2)
	check_eq(boss.hp, 24, "boss starts at max hp")
	check_eq(boss.phase, 1, "boss starts in phase 1")
	check_eq(boss.entered, [1] as Array[int], "phase 1 starts when the intro ends")
	check_eq(boss.phase_count(), 2, "one threshold gives two phases")
	check(boss.apply_damage(6, Vector2.ZERO), "a hit lands on the boss")
	check_eq(boss.phase, 1, "above the threshold it stays in phase 1")
	await seconds(0.3)
	check(boss.apply_damage(6, Vector2.ZERO), "second hit lands after the i-frames")
	check_eq(boss.phase, 2, "hp 12 starts phase 2 (threshold 12)")
	check_eq(phases_seen, [2] as Array[int], "phase_changed fires once with 2")
	check(
		boss.is_pausing() and boss.invulnerable,
		"phase change pauses and makes the boss invulnerable"
	)
	check_eq(boss.entered, [1, 2] as Array[int], "_enter_phase(2) is called")
	check(not boss.apply_damage(3, Vector2.ZERO), "no damage during the phase pause")
	await seconds(1.3)
	check(not boss.is_pausing() and not boss.invulnerable, "the pause ends after 1.2 s")
	check(boss.physics_ticks > 0, "_boss_physics runs during the fight")
	await seconds(0.3)
	check(boss.apply_damage(12, Vector2.ZERO), "lethal hit lands")
	check(boss.is_dying(), "lethal hit starts the death throes")
	check_eq(boss.hp, 1, "hp is held at 1 during the throes")
	check(boss.is_defeated(), "boss is defeated at the lethal hit")
	check(
		GameState.has_flag(&"boss_cave_test_1_defeated"),
		"flag boss_<arena>_defeated is set on death"
	)
	await seconds(1.6)
	check(
		not is_instance_valid(boss) or boss.is_queued_for_deletion(),
		"boss dies after the 1.5 s throes"
	)
	await frames(2)
	check(not is_instance_valid(boss), "boss is gone after the throes")
	await dispose(arena)


func _intro() -> void:
	reset_state()
	var arena := make_arena()
	var boss := Probe.new()
	boss.boss_id = &"intro"
	boss.arena_id = &"cave_test_intro"
	arena.add_child(boss)
	boss.global_position = Vector2(960, 480)
	await seconds(0.5)
	check(boss.is_in_intro(), "boss is in its intro for 1.5 s")
	check(not boss.hurtbox.enabled, "no hurtbox during the intro")
	check(boss.invulnerable, "invulnerable during the intro")
	check_eq(boss.physics_ticks, 0, "no attacks during the intro")
	check(boss.visible, "the boss is visible during the intro")
	await seconds(1.2)
	check(not boss.is_in_intro(), "the intro ends after 1.5 s")
	check(boss.hurtbox.enabled, "hurtbox on after the intro")
	check(boss.physics_ticks > 0, "attacks start after the intro")
	await dispose(arena)


func _hazards_and_phase_effects() -> void:
	reset_state()
	var arena := make_arena()
	var boss := _make_boss(&"haz", &"cave_test_haz", [12])
	arena.add_child(boss)
	boss.global_position = Vector2(960, 480)
	await frames(2)
	var shot := boss.fire_projectile(null, Vector2.RIGHT, 100.0, 1)
	var marker = TELEGRAPH.spawn(arena, Vector2(300, 300))
	boss.add_hazard(marker)
	await frames(2)
	check(is_instance_valid(shot), "boss projectile exists")
	GameState.damage(2)
	boss.apply_damage(12, Vector2.ZERO)
	await frames(2)
	check(not is_instance_valid(shot), "a phase change removes the boss projectiles")
	check(not is_instance_valid(marker), "a phase change removes the boss telegraphs")
	var embers := _count_pickups(arena, &"ember")
	check_eq(embers, 1, "a phase change drops one ember when Tamsin is hurt")
	GameState.heal(10)
	await dispose(arena)


func _arena_lock_and_reset() -> void:
	reset_state()
	var arena := make_arena()
	var door := Door.new()
	door.add_to_group(&"arena_door")
	arena.add_child(door)
	var boss := _make_boss(&"lock", &"cave_test_lock", [])
	arena.add_child(boss)
	boss.global_position = Vector2(960, 480)
	await frames(2)
	check(not door.locked, "doors stay open until the first hit")
	boss.apply_damage(3, Vector2.ZERO)
	check(door.locked, "the first hit closes the arena door")
	check(boss.is_arena_locked(), "the boss reports the arena lock")
	await seconds(0.3)
	boss.reset_fight()
	check(not door.locked, "reset_fight() opens the doors")
	check_eq(boss.hp, 24, "reset_fight() restores full hp")
	await frames(2)
	boss.apply_damage(3, Vector2.ZERO)
	check(door.locked, "the next hit locks the door again")
	Events.player_died.emit()
	check(not door.locked, "player death opens the doors")
	check_eq(boss.hp, 24, "player death restores full hp")
	await seconds(0.3)
	boss.apply_damage(24, Vector2.ZERO)
	await frames(2)
	check(not door.locked, "a death opens the doors")
	await dispose(arena)


func _death_interrupted_by_player_death() -> void:
	reset_state()
	var arena := make_arena()
	var boss := _make_boss(&"death_reset", &"cave_test_death_reset", [])
	var defeats := [0]
	boss.death_drops = [&"ember"]
	arena.add_child(boss)
	boss.defeated.connect(func(_boss: EnemyBase) -> void: defeats[0] += 1)
	await frames(2)
	check(boss.apply_damage(24, Vector2.ZERO), "lethal hit starts death reset test")
	check(boss.is_dying() and boss.is_defeated(), "lethal hit sets dying and defeated")
	check(GameState.has_flag(&"boss_cave_test_death_reset_defeated"), "defeat flag is set")
	Events.player_died.emit()
	check_eq(boss.resets, 0, "player death does not dispatch subclass reset during death")
	check(boss.is_dying() and boss.is_defeated(), "player death preserves death throes")
	check_eq(boss.hp, 1, "player death does not restore hp")
	boss.reset_fight()
	check(boss.is_dying() and boss.is_defeated(), "direct base reset preserves death throes")
	check_eq(boss.hp, 1, "direct reset does not restore hp")
	check_eq(defeats[0], 1, "defeated signal fires once")
	await seconds(1.6)
	check(not is_instance_valid(boss), "death completes after player death")
	check(GameState.has_flag(&"boss_cave_test_death_reset_defeated"), "defeat flag remains set")
	check_eq(_count_pickups(arena, &"ember"), 1, "death reward appears once")
	await dispose(arena)


func _subclass_death_interrupted_by_player_death() -> void:
	reset_state()
	var arena := make_arena()
	var scene := load("res://scenes/enemies/bosses/briar_mother.tscn") as PackedScene
	check(scene != null, "Briar Mother scene loads for subclass reset test")
	if scene == null:
		await dispose(arena)
		return
	var boss = scene.instantiate()
	boss.arena_id = &"cave_test_briar_death_reset"
	boss.intro_time = 0.0
	arena.add_child(boss)
	await frames(2)
	boss._begin_death()
	var eyes_before: Array = boss.eyes.duplicate()
	Events.player_died.emit()
	check(boss.is_dying() and boss.is_defeated(), "subclass stays defeated on player death")
	check_eq(boss.eyes, eyes_before, "player death does not recreate Briar Mother eyes")
	await seconds(1.6)
	check(not is_instance_valid(boss), "subclass completes death after player death")
	await dispose(arena)


func _reset_combat_state() -> void:
	reset_state()
	var arena := make_arena()
	var boss := _make_boss(&"reset_combat", &"cave_test_reset_combat", [12])
	boss.miniboss = true
	boss.knockback_scale = 1.0
	arena.add_child(boss)
	boss.global_position = Vector2(960, 480)
	await frames(2)
	check(boss.apply_damage(12, Vector2.ZERO), "reset setup enters phase 2 with damage immunity")
	boss.stun(1.5)
	boss.hit_wall = true
	var shot := boss.fire_projectile(null, Vector2.RIGHT, 100.0, 1)
	var eye := Eye.new()
	boss.adopt_part(eye, Vector2(480, 240))
	await frames(1)
	check(boss.is_stunned() and boss.is_knocked_back(), "reset setup has stun and knockback")
	check(boss.hurtbox.invulnerable, "reset setup has hurtbox immunity")
	boss.reset_fight()
	check(not boss.is_stunned(), "reset clears inherited stun immediately")
	check(not boss.is_knocked_back(), "reset clears inherited knockback immediately")
	check_eq(boss.velocity, Vector2.ZERO, "reset stops movement immediately")
	check(not boss.hit_wall, "reset clears stale wall contact")
	check_eq(boss.hp, 24, "combat reset restores full hp")
	check_eq(boss.phase, 1, "combat reset restores phase 1")
	check(not boss.is_pausing(), "combat reset clears the phase pause")
	check(boss.can_be_hurt(), "combat reset clears damage immunity immediately")
	check(not boss.hurtbox.invulnerable, "combat reset synchronizes hurtbox immunity immediately")
	check(not boss.is_dead and not boss.is_defeated(), "reset keeps an undefeated boss alive")
	var ticks := boss.physics_ticks
	var at := boss.global_position
	await frames(2)
	check(boss.physics_ticks > ticks, "combat resumes without waiting for the old stun")
	check_eq(boss.global_position, at, "old knockback cannot move the reset boss")
	check(not is_instance_valid(shot), "reset removes projectiles")
	check(not is_instance_valid(eye), "reset removes parts")
	check(boss.apply_damage(2, Vector2.ZERO), "a fresh hit lands after reset")
	check_eq(boss.hp, 22, "fresh damage uses restored hp")
	check(boss.is_knocked_back(), "fresh damage can still apply knockback")
	check(not boss.apply_damage(2, Vector2.ZERO), "fresh damage still grants normal i-frames")
	await dispose(arena)


func _reset_intro_combat_state() -> void:
	reset_state()
	var arena := make_arena()
	var boss := _make_boss(&"reset_intro", &"cave_test_reset_intro", [])
	arena.add_child(boss)
	await frames(2)
	boss.apply_damage(2, Vector2.ZERO)
	boss.stun(1.5)
	boss.apply_knockback(Vector2.RIGHT * 480.0, 1.0)
	boss.intro_time = 0.1
	boss.reset_fight()
	check(boss.is_in_intro(), "reset restarts the boss intro")
	check(not boss.hurtbox.enabled and boss.invulnerable, "reset intro protects the boss")
	check(boss.hurtbox.invulnerable, "reset intro synchronizes hurtbox immunity")
	check(not boss.contact_hitbox.active, "reset intro disables contact")
	check(not boss.apply_damage(2, Vector2.ZERO), "no damage during reset intro")
	await seconds(0.15)
	check(not boss.is_in_intro(), "old stun and knockback cannot delay the reset intro")
	check(boss.hurtbox.enabled and boss.contact_hitbox.active, "reset intro restores combat")
	check(boss.apply_damage(2, Vector2.ZERO), "old i-frames cannot outlast the reset intro")
	await dispose(arena)


func _miniboss_mode() -> void:
	reset_state()
	var arena := make_arena()
	var door := Door.new()
	door.add_to_group(&"arena_door")
	arena.add_child(door)
	var mini := Probe.new()
	mini.miniboss = true
	mini.arena_id = &"cave_mini_1"
	mini.max_hp = 12
	arena.add_child(mini)
	mini.global_position = Vector2(960, 480)
	await frames(2)
	check(not mini.is_in_intro(), "a miniboss has no intro")
	mini.apply_damage(3, Vector2.ZERO)
	check(not door.locked, "a miniboss does not lock the arena")
	await seconds(0.3)
	mini.apply_damage(9, Vector2.ZERO)
	await seconds(1.6)
	check(GameState.has_flag(&"mini_cave_mini_1"), "a miniboss sets mini_<room id> on death")
	check(
		not GameState.has_flag(&"boss_cave_mini_1_defeated"),
		"a miniboss does not set the boss flag"
	)
	await dispose(arena)


func _defeated_stays_dead() -> void:
	reset_state()
	GameState.set_flag(&"boss_cave_test_2_defeated")
	var arena := make_arena()
	var boss := _make_boss(&"dead", &"cave_test_2", [12])
	arena.add_child(boss)
	boss.global_position = Vector2(960, 480)
	await frames(3)
	check(boss.is_dead, "a boss whose flag is set is dead on entry")
	check(not boss.visible, "a defeated boss is hidden")
	check(not boss.hurtbox.enabled, "a defeated boss has no hurtbox")
	check_eq(boss.physics_ticks, 0, "a defeated boss never runs")
	boss.reset_fight()
	check(boss.is_dead and not boss.visible, "reset cannot revive a retired boss")
	check(not boss.hurtbox.enabled, "retired boss stays unhittable after reset")
	check(GameState.has_flag(&"boss_cave_test_2_defeated"), "reset preserves the defeat flag")
	await dispose(arena)


func _resupply_and_death_drops() -> void:
	reset_state()
	GameState.acquire_item(&"tallow_sling")
	GameState.acquire_item(&"pitch_pot")
	var arena := make_arena()
	var boss := _make_boss(&"supply", &"cave_test_supply", [12])
	boss.resupply = true
	boss.death_drops = [&"wick_core"] as Array[StringName]
	arena.add_child(boss)
	boss.global_position = Vector2(960, 480)
	await frames(3)
	check_eq(
		_count_pickups(arena, &"pitch_pot_bundle"), 1, "resupply: pot bundle when pots are below 4"
	)
	check_eq(_count_pickups(arena, &"slug_bundle"), 0, "no slug bundle at 12 slugs (8 is the line)")
	var bundles := _pickups_of(arena, &"pitch_pot_bundle")
	if bundles.size() == 1:
		check_near(bundles[0].timeout, 8.0, 0.001, "resupply pickups are timed")
	GameState.add_slugs(-10)
	GameState.damage(2)
	await seconds(0.3)
	boss.apply_damage(12, Vector2.ZERO)
	await frames(3)
	check_eq(_count_pickups(arena, &"slug_bundle"), 1, "phase start: slug bundle below 8 slugs")
	check_eq(_count_pickups(arena, &"pitch_pot_bundle"), 2, "phase start: pot bundle again")
	GameState.heal(10)
	await seconds(1.3)
	boss.apply_damage(12, Vector2.ZERO)
	await seconds(1.6)
	await frames(2)
	check(not is_instance_valid(boss), "boss dies")
	check_eq(
		_count_pickups(arena, &"wick_core"), 1, "the death drops appear, and no drop table roll"
	)
	GameState.reset()
	await dispose(arena)


func _parts() -> void:
	reset_state()
	var arena := make_arena()
	var boss := _make_boss(&"parts", &"cave_test_parts", [])
	arena.add_child(boss)
	boss.global_position = Vector2(960, 480)
	await frames(2)
	var eye := Eye.new()
	boss.adopt_part(eye, Vector2(960, 300))
	await frames(2)
	check(eye.is_inside_tree(), "the part joins the room")
	check_eq(boss.parts().size(), 1, "the boss lists its live parts")
	var hook := make_hitbox(arena, eye.global_position, Layers.Team.PLAYER, 2, 30.0)
	hook.kind = &"hook"
	await frames(2)
	check_eq(eye.hp, 4, "a sling-only part ignores the hook")
	hook.queue_free()
	await frames(2)
	var slug := make_hitbox(arena, eye.global_position, Layers.Team.PLAYER, 2, 30.0)
	slug.kind = &"sling"
	await frames(2)
	check_eq(eye.hp, 2, "a sling hit damages the part")
	check_eq(boss.part_damage, 2, "the boss hears the damage through _on_part_hurt")
	slug.queue_free()
	await seconds(0.3)
	eye.apply_damage(2, eye.global_position)
	check(eye.is_dead, "the part dies at 0 hp")
	await frames(2)
	check_eq(boss.part_deaths, 1, "the boss hears the part's death")
	check_eq(boss.parts().size(), 0, "a dead part is no longer listed")
	await dispose(arena)


func _telegraph() -> void:
	reset_state()
	var arena := make_arena()
	_finished = 0
	var marker = TELEGRAPH.spawn(arena, Vector2(500, 500))
	marker.shape = &"cone"
	marker.radius = 200.0
	marker.arc_deg = 60.0
	marker.facing = Vector2.UP
	marker.duration = 0.3
	marker.finished.connect(func() -> void: _finished += 1)
	check(not marker.is_running(), "a telegraph waits for start()")
	marker.start()
	await seconds(0.15)
	check(marker.is_running(), "the telegraph runs")
	check(marker.progress() > 0.3 and marker.progress() < 0.7, "progress is about half way")
	await seconds(0.3)
	check_eq(_finished, 1, "finished fires once at the end of the duration")
	await frames(2)
	check(not is_instance_valid(marker), "the telegraph frees itself after finishing")
	marker = TELEGRAPH.spawn(arena, Vector2(500, 500))
	marker.shape = &"rect"
	marker.duration = 0.1
	marker.start()
	await seconds(0.2)
	check(not is_instance_valid(marker), "a rect telegraph also finishes and frees itself")
	await dispose(arena)


func _stun_knockback_chime() -> void:
	reset_state()
	var arena := make_arena()
	var immune := make_dummy(arena, Vector2(600, 500), 20)
	immune.stun_scale = 0.0
	immune.knockback_scale = 0.0
	var stun_hit := make_hitbox(arena, Vector2(600, 500), Layers.Team.PLAYER, 0, 40.0)
	stun_hit.kind = &"stun"
	stun_hit.stun_time = 2.0
	stun_hit.knockback = 480.0
	await frames(2)
	check(not immune.is_stunned(), "stun_scale 0 makes the enemy immune to stun")
	stun_hit.queue_free()
	var hook := make_hitbox(arena, Vector2(560, 500), Layers.Team.PLAYER, 2, 40.0)
	hook.kind = &"hook"
	await frames(2)
	check(immune.hp < 20, "the hook still damages it")
	check(not immune.is_knocked_back(), "knockback_scale 0 means no knockback")
	hook.queue_free()
	await seconds(0.3)
	var chimed := make_dummy(arena, Vector2(900, 300), 20)
	chimed.chime_stun_time = 2.5
	var chime := make_hitbox(arena, Vector2(900, 300), Layers.Team.PLAYER, 0, 40.0)
	chime.kind = &"chime"
	await frames(2)
	check(chimed.is_stunned(), "a chime hit stuns for chime_stun_time")
	chime.queue_free()
	await seconds(0.3)
	var normal := make_dummy(arena, Vector2(1300, 300), 20)
	var stun_only := make_hitbox(arena, Vector2(1300, 300), Layers.Team.PLAYER, 0, 40.0)
	stun_only.kind = &"stun"
	stun_only.stun_time = 2.0
	await frames(2)
	check(normal.is_stunned(), "stun_scale 1 keeps the moth stun")
	await dispose(arena)


func _front_guard() -> void:
	reset_state()
	var arena := make_arena()
	var guarded := Guarded.new()
	arena.add_child(guarded)
	guarded.global_position = Vector2(600, 500)
	await frames(2)
	_blocked = 0
	guarded.guard_blocked.connect(func(_h: Hitbox) -> void: _blocked += 1)
	var front := make_hitbox(arena, Vector2(650, 500), Layers.Team.PLAYER, 2, 30.0)
	front.kind = &"hook"
	await frames(2)
	check_eq(guarded.hp, 10, "a hit from the guarded front deals 0")
	check_eq(_blocked, 1, "guard_blocked fires once")
	front.queue_free()
	await frames(2)
	var flare := make_hitbox(arena, Vector2(650, 500), Layers.Team.PLAYER, 4, 30.0)
	flare.kind = &"flare"
	await frames(2)
	check_eq(guarded.hp, 6, "a flare pierces the guard")
	flare.queue_free()
	await seconds(0.3)
	var back := make_hitbox(
		arena, guarded.global_position - Vector2(50, 0), Layers.Team.PLAYER, 2, 30.0
	)
	back.kind = &"hook"
	await frames(2)
	check_eq(guarded.hp, 4, "a hit from behind damages it")
	back.queue_free()
	await dispose(arena)


func _water_flags() -> void:
	reset_state()
	var arena := make_arena()
	var ground := make_dummy(arena, Vector2(300, 300), 2)
	var flyer := Flyer.new()
	arena.add_child(flyer)
	flyer.global_position = Vector2(500, 300)
	await frames(1)
	check((ground.collision_mask & Layers.WATER) != 0, "ground enemies stop at deep water")
	check((flyer.collision_mask & Layers.WATER) == 0, "ignore_water enemies pass over water")
	check((ground.collision_mask & Layers.WORLD) != 0, "every enemy still collides with WORLD")
	await dispose(arena)


func _tick_interval() -> void:
	reset_state()
	var arena := make_arena()
	var target := make_dummy(arena, Vector2(600, 500), 50)
	var flame := Hitbox.new()
	flame.team = Layers.Team.PLAYER
	flame.kind = &"fire"
	flame.damage = 1
	flame.knockback = 0.0
	flame.once_per_target = false
	flame.tick_interval = 0.5
	flame.add_circle(40.0)
	arena.add_child(flame)
	flame.global_position = Vector2(600, 500)
	flame.hit_landed.connect(func(_h: Hurtbox) -> void: _hits += 1)
	_hits = 0
	flame.activate()
	await seconds(1.2)
	check_eq(_hits, 3, "a tick hitbox hits every 0.5 s (1.2 s gives 3 hits)")
	flame.deactivate()
	await dispose(flame)
	await dispose(arena)


func _carrier_rule() -> void:
	reset_state()
	var arena := make_arena()
	var shot := EnemyProjectile.fire(arena, Vector2(400, 400), Vector2.RIGHT, 100.0, 1)
	await frames(2)
	shot.hitbox.blocked.emit()
	await frames(2)
	check(not is_instance_valid(shot) or shot.is_destroyed, "a blocked projectile is destroyed")
	var area_shot := EnemyProjectile.fire(arena, Vector2(400, 600), Vector2.RIGHT, 100.0, 1)
	area_shot.hitbox.block_destroys_carrier = false
	await frames(2)
	area_shot.hitbox.blocked.emit()
	await frames(2)
	check(
		is_instance_valid(area_shot) and not area_shot.is_destroyed,
		"an area hit blocked by the ward keeps its carrier"
	)
	await dispose(arena)


func _capsule_and_homing() -> void:
	reset_state()
	var arena := make_arena()
	var beam := EnemyProjectile.new()
	beam.shape_capsule = true
	arena.add_child(beam)
	beam.launch(Vector2(400, 400), Vector2.DOWN)
	await frames(1)
	var wall := beam.get_node("WallShape") as CollisionShape2D
	check(wall.shape is CapsuleShape2D, "a capsule projectile uses a capsule shape")
	check_near(wall.rotation, PI, 0.01, "a downward capsule lies along the flight")
	beam.launch(Vector2(400, 400), Vector2.RIGHT)
	check_near(wall.rotation, PI * 0.5, 0.01, "relaunching turns the capsule")
	beam.destroy(&"hit")
	await frames(1)
	var target := Node2D.new()
	target.add_to_group(&"player")
	arena.add_child(target)
	target.global_position = Vector2(800, 100)
	var seeker := EnemyProjectile.new()
	seeker.homing_turn_deg = 90.0
	seeker.speed = 200.0
	arena.add_child(seeker)
	seeker.launch(Vector2(400, 400), Vector2.RIGHT)
	await seconds(0.5)
	check(seeker.direction.y < -0.4, "a homing projectile turns toward the player")
	check(seeker.direction.x > 0.0, "the turn is at most 90 degrees per second")
	await dispose(arena)


func _scenes() -> void:
	reset_state()
	var arena := make_arena()
	var part_scene := load("res://scenes/enemies/boss_part.tscn") as PackedScene
	var telegraph_scene := load("res://scenes/enemies/telegraph.tscn") as PackedScene
	check(part_scene != null and telegraph_scene != null, "the part and telegraph scenes load")
	var part := part_scene.instantiate() as EnemyBase
	arena.add_child(part)
	var marker := telegraph_scene.instantiate()
	arena.add_child(marker)
	await frames(2)
	check(part.hurtbox != null and part.visual != null, "a part scene gets its Hurtbox and Visual")
	check(marker.is_inside_tree(), "the telegraph scene instantiates")
	await dispose(arena)
	var gallery := load("res://tests/fixtures/gallery/M0.tscn") as PackedScene
	check(gallery != null, "the M0 gallery fixture loads")
	if gallery != null:
		var room := gallery.instantiate()
		add_child(room)
		await frames(2)
		check(room.get_node_or_null("Props/Eye") != null, "the fixture holds a boss part")
		await dispose(room)


func _count_pickups(parent: Node, kind: StringName) -> int:
	return _pickups_of(parent, kind).size()


func _pickups_of(parent: Node, kind: StringName) -> Array[PickupBase]:
	var found: Array[PickupBase] = []
	for node in parent.get_children():
		if node is PickupBase and (node as PickupBase).kind == kind:
			found.append(node as PickupBase)
	return found
