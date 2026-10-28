extends ItemBase
## Skitter boots (jump feather). `use_item` leaps LEAP_DISTANCE px (192, two tiles) along `facing` in LEAP_TIME s
## through the Player motion API (airborne, hurtbox off, body shape off). A shape cast of the body along the leap
## stops it short of a WORLD wall; a low rail (group `leapable`) does not stop it. Tamsin lands where the leap ends:
## a PitZone under her then makes her fall (pit_zone.gd), solid floor is safe. The item lives through the leap and
## COOLDOWN_TIME after the landing, so one leap at a time, the cooldown included. No ammo. Spec:
## monsters-bosses-tools.md, section 5.7.

const LEAP_DISTANCE := 192.0
const LEAP_TIME := 0.4
const COOLDOWN_TIME := 0.5
const RAIL_GROUP := &"leapable"

var _hero: Player
var _leaping: bool = false
var _cooling: bool = false
var _cooldown_left: float = 0.0


func _init() -> void:
	item_id = &"skitter_boots"


func _ready() -> void:
	if not Placeholder.has_kind(&"skitter_boots"):
		Placeholder.register_kind(
			&"skitter_boots", {"shape": "ring", "color": Color(0.7, 0.9, 1.0, 0.6), "radius": 24.0}
		)
	var cue_script := load("res://scripts/art/tool_cue_visual.gd") as GDScript
	if cue_script != null:
		cue_script.call(&"attach", self, &"skitter_boots", facing)


## Refuses while another boots node is in the tree (a leap or its cooldown), while the player is in a motion
## or holds an action lock (Player.use_item checks these too), and when a wall stops the leap before the body
## can move its own radius. A refused use spends nothing.
func activate() -> bool:
	_hero = player as Player
	if _hero == null or active_count() > 1:
		return false
	var start := _hero.global_position
	var free := _free_run(start)
	if free < Player.BODY_RADIUS:
		return false
	var path: Array[Vector2] = [start + facing * free]
	if not _hero.begin_external_motion(
		path, LEAP_DISTANCE / LEAP_TIME, {"airborne": true, "hurtbox": false}
	):
		return false
	var visual := get_node_or_null("Visual")
	if visual != null and visual.has_method("show_leap_dust"):
		visual.call("show_leap_dust", start)
	_leaping = true
	_hero.motion_finished.connect(_on_motion_finished, CONNECT_ONE_SHOT)
	Audio.play_sfx(&"moth_launch", start)
	return true


func _physics_process(delta: float) -> void:
	if _leaping:
		global_position = _hero.global_position
		return
	if not _cooling:
		return
	_cooldown_left -= delta
	if _cooldown_left <= 0.0:
		finish()


## Distance the body can travel from `start` along `facing` (up to LEAP_DISTANCE) before a WORLD body stops it.
## Rails in group `leapable` are excluded from the cast.
func _free_run(start: Vector2) -> float:
	var shape := CircleShape2D.new()
	shape.radius = Player.BODY_RADIUS
	var rails: Array[RID] = []
	for node in get_tree().get_nodes_in_group(RAIL_GROUP):
		var body := node as CollisionObject2D
		if body != null:
			rails.append(body.get_rid())
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, start)
	query.collision_mask = Layers.WORLD
	query.exclude = rails
	# cast_motion ignores bodies already overlapping the starting shape. Refuse
	# the leap until walking clears them; leapable rails stay excluded.
	if not get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty():
		return 0.0
	query.motion = facing * LEAP_DISTANCE
	var fractions := get_world_2d().direct_space_state.cast_motion(query)
	return fractions[0] * LEAP_DISTANCE


## Landed (or the motion was cut short by a death or place_at): the cooldown starts, the node stays.
func _on_motion_finished() -> void:
	_leaping = false
	_cooling = true
	_cooldown_left = COOLDOWN_TIME
	global_position = _hero.global_position
