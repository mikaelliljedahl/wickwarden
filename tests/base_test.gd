class_name TestCase
extends Node
## Base class of every headless test. A test file is `tests/test_<name>.gd`, extends TestCase and
## overrides run(). The runner (tests/runner.tscn) discovers files by name; nothing is registered.
##
## run() may await. Use check() for assertions; any failed check makes the file fail.
## One Godot process per file, so GameState and Input start clean; still call reset_state() at
## the start of each scenario inside a file.

const FPS := 60.0
const ACTIONS: Array[StringName] = [
	&"move_left",
	&"move_right",
	&"move_up",
	&"move_down",
	&"attack",
	&"use_item",
	&"ward",
	&"cycle_item",
	&"pause"
]

var failures: Array[String] = []
var checks: int = 0


## Override. Put the scenarios here.
func run() -> void:
	pass


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		printerr("FAILED: ", message)


func check_near(actual: float, expected: float, tolerance: float, message: String) -> void:
	checks += 1
	if absf(actual - expected) > tolerance:
		var text := "%s (got %s, expected %s +/- %s)" % [message, actual, expected, tolerance]
		failures.append(text)
		printerr("FAILED: ", text)


func check_eq(actual: Variant, expected: Variant, message: String) -> void:
	checks += 1
	if actual != expected:
		var text := "%s (got %s, expected %s)" % [message, actual, expected]
		failures.append(text)
		printerr("FAILED: ", text)


## Waits n physics frames (1/60 s each under --fixed-fps 60).
func frames(n: int) -> void:
	for i in range(n):
		await get_tree().physics_frame


## Waits at least `s` seconds of game time.
func seconds(s: float) -> void:
	await frames(int(ceil(s * FPS)))


func reset_state() -> void:
	GameState.reset()
	release_inputs()


func release_inputs() -> void:
	for action in ACTIONS:
		Input.action_release(action)


## A bare arena: Node2D in the tree with an optional solid rectangle (global coords) per wall.
func make_arena(walls: Array[Rect2] = []) -> Node2D:
	var arena := Node2D.new()
	arena.name = "Arena"
	add_child(arena)
	for r in walls:
		var body := StaticBody2D.new()
		body.collision_layer = Layers.WORLD
		var shape := RectangleShape2D.new()
		shape.size = r.size
		var node := CollisionShape2D.new()
		node.shape = shape
		body.add_child(node)
		body.position = r.get_center()
		arena.add_child(body)
	return arena


func make_player(parent: Node, at: Vector2 = Vector2.ZERO) -> Player:
	var scene := load("res://scenes/player/player.tscn") as PackedScene
	var player := scene.instantiate() as Player
	parent.add_child(player)
	player.global_position = at
	return player


## Instantiates an enemy scene (path) or script-less EnemyBase subclass scene into `parent`.
func make_enemy(parent: Node, scene_path: String, at: Vector2) -> EnemyBase:
	var scene := load(scene_path) as PackedScene
	var enemy := scene.instantiate() as EnemyBase
	parent.add_child(enemy)
	enemy.global_position = at
	return enemy


## A stationary plain EnemyBase (no behaviour) with `hp` hit points, for hit/knockback tests.
func make_dummy(parent: Node, at: Vector2, hp: int = 6) -> EnemyBase:
	var enemy := EnemyBase.new()
	enemy.max_hp = hp
	enemy.contact_damage = 0
	enemy.drops_enabled = false
	parent.add_child(enemy)
	enemy.global_position = at
	return enemy


func make_world() -> World:
	var scene := load("res://scenes/world/world.tscn") as PackedScene
	var world := scene.instantiate() as World
	add_child(world)
	await frames(2)
	return world


## Frees a node and waits a frame so queue_free'd children are gone.
func dispose(node: Node) -> void:
	if is_instance_valid(node):
		node.queue_free()
	await frames(2)


## A Hitbox in the tree at `at` that is active immediately. Free it with dispose().
func make_hitbox(
	parent: Node, at: Vector2, team: Layers.Team, damage: int, radius: float = 30.0
) -> Hitbox:
	var hitbox := Hitbox.new()
	hitbox.team = team
	hitbox.damage = damage
	hitbox.add_circle(radius)
	parent.add_child(hitbox)
	hitbox.global_position = at
	hitbox.activate()
	return hitbox
