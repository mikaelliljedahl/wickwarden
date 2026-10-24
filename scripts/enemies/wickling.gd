extends EnemyBase
## Wickling (monsters-bosses-tools section 2.1): a thumb-high candle imp, 1 hp. A pack is the wicklings
## the room places together (2 or 3); packmates are the other living wicklings of the same parent.
## Idle until Tamsin is within 420 px. Then stop-and-go: runs 0.5 s at 200 px/s, pauses 0.3 s. Each
## member has its own approach offset of +-35 degrees, drawn once. When a packmate dies the others run
## 20 % faster for 3.0 s. Fire kills it at once. Half of the deaths roll the drop table (an extra 50 %
## gate). Nothing to block with the ward. It does NOT declare a class_name (see docs/code-contract.md).

const KIND := &"wickling"
const PACK_GROUP := &"wicklings"
const TRIGGER_RANGE := 420.0
const RUN_TIME := 0.5
const PAUSE_TIME := 0.3
const OFFSET_DEG := 35.0
const PACK_BOOST := 1.2
const PACK_BOOST_TIME := 3.0
const DROP_GATE := 0.5
const BODY_RADIUS := 16.0

var _awake: bool = false
var _running: bool = false
var _timer: float = 0.0
var _run_dir: Vector2 = Vector2.DOWN
var _offset_rad: float = 0.0
var _boost_left: float = 0.0


func _init() -> void:
	max_hp = 1
	contact_damage = 1
	move_speed = 200.0
	visual_kind = KIND
	body_radius = BODY_RADIUS
	_register_kind()


func _enemy_ready() -> void:
	add_to_group(PACK_GROUP)
	_offset_rad = deg_to_rad(randf_range(-OFFSET_DEG, OFFSET_DEG))


func _enemy_physics(delta: float) -> void:
	if _boost_left > 0.0:
		_boost_left -= delta
	if not _awake:
		if not _player_in_trigger_range():
			velocity = Vector2.ZERO
			return
		_awake = true
		_start_run()
	_timer -= delta
	if not _running and _timer <= 0.0:
		_start_run()
	if _running:
		velocity = _run_dir * run_speed()
		if hit_wall or _timer <= 0.0:
			_start_pause()
	else:
		velocity = Vector2.ZERO


## Fire kills at once: the hit is answered with the enemy's whole hp.
func _resolve_damage(hitbox: Hitbox, amount: int) -> int:
	if hitbox.kind == &"fire":
		return hp
	return amount


## Chooses the drop gate and tells the packmates that one of them died.
func _on_death() -> void:
	drops_enabled = drops_enabled and drop_gate_open(randf())
	for mate in get_tree().get_nodes_in_group(PACK_GROUP):
		if mate == self or mate.get_parent() != get_parent():
			continue
		if mate.has_method(&"pack_boost") and not bool(mate.get(&"is_dead")):
			mate.call(&"pack_boost")


## Called on the living packmates of a dying wickling: 20 % faster for 3.0 s (a new death restarts it).
func pack_boost() -> void:
	_boost_left = PACK_BOOST_TIME


## The speed of a run now (200 px/s, or 240 px/s while the pack boost lasts).
func run_speed() -> float:
	return move_speed * (PACK_BOOST if _boost_left > 0.0 else 1.0)


## True while the pack boost lasts.
func is_boosted() -> bool:
	return _boost_left > 0.0


## The approach offset of this member in degrees (-35 to +35), fixed for its life.
func approach_offset_deg() -> float:
	return rad_to_deg(_offset_rad)


## True while the wickling runs (0.5 s of each stop-and-go cycle).
func is_running() -> bool:
	return _running


## Drop gate: a death drops loot only when `roll` is under 0.5 (the table then rolls as usual).
func drop_gate_open(roll: float) -> bool:
	return roll < DROP_GATE


func _player_in_trigger_range() -> bool:
	var player := get_player()
	return player != null and global_position.distance_to(player.global_position) <= TRIGGER_RANGE


func _start_run() -> void:
	var to_player := direction_to_player()
	if to_player != Vector2.ZERO:
		_run_dir = to_player.rotated(_offset_rad)
		set_facing_dir(_run_dir)
	_running = true
	_timer = RUN_TIME


func _start_pause() -> void:
	_running = false
	_timer = PAUSE_TIME
	velocity = Vector2.ZERO


static func _register_kind() -> void:
	if not Placeholder.has_kind(KIND):
		Placeholder.register_kind(
			KIND, {"shape": "circle", "color": Color(1.0, 0.8, 0.4), "radius": BODY_RADIUS}
		)
