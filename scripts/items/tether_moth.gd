extends ItemBase
## Tether moth (boomerang). Flies RANGE px along the facing at SPEED, turns back early when it
## hits a wall, then homes on the player and finishes when it reaches them.
##
## Its stun hitbox stuns every enemy it touches (damage 0). Its carrier collector picks up loot it
## touches and brings it back: carried pickups are collected when the moth arrives at the player.
## One moth at a time: activate() refuses while another one is on screen.

const RANGE := 420.0
const SPEED := 900.0
const STUN_TIME := 2.0
const STUN_RADIUS := 24.0
const CARRY_RADIUS := 30.0

enum Phase { OUT, RETURN }

var _phase: Phase = Phase.OUT
var _dir: Vector2 = Vector2.RIGHT
var _travelled: float = 0.0
var _live: bool = false
var _stun_box: Hitbox
var _carried: Array[PickupBase] = []


func _init() -> void:
	item_id = &"tether_moth"


func _ready() -> void:
	SpriteVisual.attach(self, &"tether_moth")
	_stun_box = Hitbox.new()
	_stun_box.name = "StunHitbox"
	_stun_box.team = Layers.Team.PLAYER
	_stun_box.kind = &"stun"
	_stun_box.damage = 0
	_stun_box.knockback = 0.0
	_stun_box.stun_time = STUN_TIME
	_stun_box.once_per_target = true
	_stun_box.source = self
	_stun_box.add_circle(STUN_RADIUS)
	add_child(_stun_box)
	var carrier := PickupCollector.new()
	carrier.name = "Carrier"
	carrier.carrier = true
	carrier.add_circle(CARRY_RADIUS)
	add_child(carrier)
	carrier.picked.connect(_on_picked)


## Refuses (returns false) while another moth is already on screen.
func activate() -> bool:
	if active_count() > 1:
		return false
	_dir = facing.normalized() if facing != Vector2.ZERO else Vector2.DOWN
	_phase = Phase.OUT
	_travelled = 0.0
	_live = true
	Audio.play_sfx(&"moth_launch", global_position)
	_stun_box.activate()
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as Node2D
	if visual != null and visual.has_method(&"set_facing"):
		visual.call(&"set_facing", _dir)
	return true


func _physics_process(delta: float) -> void:
	if not _live:
		return
	if _phase == Phase.OUT:
		_fly_out(delta)
	else:
		_fly_home(delta)


func _fly_out(delta: float) -> void:
	var step := minf(SPEED * delta, RANGE - _travelled)
	var from := global_position
	var to := from + _dir * step
	if _hits_wall(from, to):
		_turn_back()
		return
	global_position = to
	_travelled += step
	if _travelled >= RANGE - 0.5:
		_turn_back()


func _fly_home(delta: float) -> void:
	var target := _home_point()
	var offset := target - global_position
	var dist := offset.length()
	var step := SPEED * delta
	if dist <= step:
		global_position = target
		_arrive()
	else:
		global_position += offset / dist * step


## Starts the way back. Re-arms the stun hitbox so enemies on the way back are stunned too.
func _turn_back() -> void:
	if _phase == Phase.RETURN:
		return
	_phase = Phase.RETURN
	_stun_box.activate()


func _home_point() -> Vector2:
	if player != null and is_instance_valid(player):
		return player.global_position
	return global_position


## Hands every carried pickup to the player, then frees the moth.
func _arrive() -> void:
	for pickup in _carried:
		if is_instance_valid(pickup) and pickup.is_carried():
			pickup.collect(player)
	_carried.clear()
	_live = false
	finish()


func _hits_wall(from: Vector2, to: Vector2) -> bool:
	var query := PhysicsRayQueryParameters2D.create(from, to, Layers.WORLD)
	var hit: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	return not hit.is_empty()


func _on_picked(pickup: PickupBase) -> void:
	if not _carried.has(pickup):
		_carried.append(pickup)


## A moth freed early (room change) lets go of what it carries; the pickups then time out normally.
func _exit_tree() -> void:
	for pickup in _carried:
		if is_instance_valid(pickup):
			pickup.end_carry()
	_carried.clear()
