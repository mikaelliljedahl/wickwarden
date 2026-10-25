extends StaticBody2D
## A ward puzzle pad and its linked blocker. The pad counts distinct blockable hitboxes whose
## blocked signal fires while Tamsin is standing on it with the ward raised. A blocker with the
## same ward_id opens when the required number of hits has been absorbed; `ward_<id>` persists it.
## Set `test_spore_post` only in test fixtures to provide a deterministic blockable shooter.

signal satisfied
signal opened

const BLOCKER_GROUP := &"ward_blocker"
const PLATE_LOOK := &"ward_plate"
const BLOCKER_LOOK := &"ward_blocker"
const SPORE_POST_LOOK := &"spore_post"
const DEFAULT_PAD_SIZE := Vector2(96, 96)

const LOOKS := {
	PLATE_LOOK: {"shape": "rect", "color": Color(0.36, 0.48, 0.55), "size": DEFAULT_PAD_SIZE},
	BLOCKER_LOOK: {"shape": "rect", "color": Color(0.28, 0.34, 0.42), "size": Vector2(192, 96)},
	SPORE_POST_LOOK: {"shape": "rect", "color": Color(0.56, 0.34, 0.22), "size": Vector2(64, 96)},
}

## Shared persistent id of one pad and its linked blocker(s). The flag is `ward_<ward_id>`.
@export var ward_id: StringName = &""
## True for the linked solid opener; false for the pressure pad.
@export var blocker: bool = false
## Number of distinct blockable hitboxes the pad must absorb.
@export_range(1, 20, 1) var blocks_required: int = 3
## Footprint used by the pad sensor, or by the blocker when blocker is true.
@export var size: Vector2 = DEFAULT_PAD_SIZE
## Optional test-only shooter; never enabled in game rooms.
@export var test_spore_post: bool = false
## The test shooter's position relative to the pad.
@export var spore_post_offset: Vector2 = Vector2(0, -192)

var blocks_absorbed: int = 0
var is_satisfied: bool = false
var is_open: bool = false

var _shape: CollisionShape2D
var _pad_area: Area2D
var _spore_post: Node2D
var _spore_timer: float = 0.35
var _counted_hitboxes: Dictionary = {}


func _init() -> void:
	collision_layer = 0
	collision_mask = 0
	_register_looks()


func _ready() -> void:
	if ward_id == &"":
		push_error("WardPlate: %s needs a ward_id" % name)
	if blocker:
		_ready_blocker()
	else:
		_ready_pad()


func flag_name() -> StringName:
	return StringName("ward_%s" % ward_id)


## Marks this pad complete, sets its persistent flag and opens every linked blocker in the room.
func satisfy() -> bool:
	if blocker or is_satisfied or ward_id == &"":
		return false
	is_satisfied = true
	GameState.set_flag(flag_name())
	get_tree().call_group(BLOCKER_GROUP, "open_for_ward", ward_id)
	Audio.play_sfx(&"gate_open", global_position)
	satisfied.emit()
	return true


## Opens a blocker when its id matches the completed pad.
func open_for_ward(id: StringName) -> void:
	if not blocker or is_open or ward_id == &"" or id != ward_id:
		return
	_open(true)


func _ready_pad() -> void:
	add_to_group(&"ward_plate")
	var sensor := RectangleShape2D.new()
	sensor.size = size
	var sensor_shape := CollisionShape2D.new()
	sensor_shape.name = "PadShape"
	sensor_shape.shape = sensor
	_pad_area = Area2D.new()
	_pad_area.name = "PadArea"
	_pad_area.collision_layer = 0
	_pad_area.collision_mask = Layers.PLAYER_BODY
	_pad_area.add_child(sensor_shape)
	add_child(_pad_area)
	Placeholder.attach(self, PLATE_LOOK, 0.0, size)
	_watch_existing_hitboxes()
	get_tree().node_added.connect(_on_node_added)
	if ward_id != &"" and GameState.has_flag(flag_name()):
		is_satisfied = true
	if test_spore_post:
		_make_spore_post()


func _ready_blocker() -> void:
	add_to_group(BLOCKER_GROUP)
	collision_layer = Layers.WORLD
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape = CollisionShape2D.new()
	_shape.name = "Shape"
	_shape.shape = rect
	add_child(_shape)
	Placeholder.attach(self, BLOCKER_LOOK, 0.0, size)
	if ward_id != &"" and GameState.has_flag(flag_name()):
		_open(false)


func _watch_existing_hitboxes() -> void:
	for node in get_tree().get_nodes_in_group(&"hitboxes"):
		if node is Hitbox:
			_watch_hitbox(node as Hitbox)


func _on_node_added(node: Node) -> void:
	if not blocker and node is Hitbox:
		_watch_hitbox(node as Hitbox)


func _watch_hitbox(hitbox: Hitbox) -> void:
	# node_added fires before the spawning parent finishes configuring its hitbox.
	# Subscribe immediately; eligibility is checked when the ward actually blocks it.
	var callback := _on_hitbox_blocked.bind(hitbox)
	if not hitbox.blocked.is_connected(callback):
		hitbox.blocked.connect(callback)


func _physics_process(delta: float) -> void:
	if blocker:
		return
	_clear_inactive_blocks()
	if test_spore_post:
		_spore_timer -= delta
		if _spore_timer <= 0.0:
			_spore_timer = 0.55
			call_deferred("_fire_test_spore")


func _on_hitbox_blocked(hitbox: Hitbox) -> void:
	if blocker or is_satisfied or not is_instance_valid(hitbox) or not hitbox.blockable:
		return
	var hitbox_id := hitbox.get_instance_id()
	if _counted_hitboxes.has(hitbox_id):
		return
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player == null or not player.ward_up or not _pad_area.overlaps_body(player):
		return
	_counted_hitboxes[hitbox_id] = hitbox
	blocks_absorbed += 1
	if blocks_absorbed >= blocks_required:
		satisfy()


func _clear_inactive_blocks() -> void:
	for id in _counted_hitboxes.keys():
		var hitbox: Variant = _counted_hitboxes[id]
		if not is_instance_valid(hitbox) or not (hitbox as Hitbox).active:
			_counted_hitboxes.erase(id)


func _make_spore_post() -> void:
	_spore_post = Node2D.new()
	_spore_post.name = "SporePost"
	_spore_post.position = spore_post_offset
	add_child(_spore_post)
	Placeholder.attach(_spore_post, SPORE_POST_LOOK, 0.0, LOOKS[SPORE_POST_LOOK]["size"])


func _fire_test_spore() -> void:
	if not is_inside_tree() or blocker:
		return
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player == null:
		return
	var shot := Hitbox.new()
	shot.name = "TestSpore"
	shot.team = Layers.Team.ENEMY
	shot.kind = &"spore"
	shot.damage = 0
	shot.blockable = true
	shot.source = _spore_post
	shot.add_circle(18.0)
	shot.blocked.connect(_finish_test_spore.bind(shot))
	shot.hit_landed.connect(_finish_test_spore.bind(shot))
	get_parent().add_child(shot)
	shot.global_position = player.global_position
	shot.activate()


func _finish_test_spore(first: Variant, second: Variant = null) -> void:
	var shot := first as Hitbox
	if second is Hitbox:
		shot = second as Hitbox
	if is_instance_valid(shot):
		shot.deactivate()
		shot.queue_free()


func _open(play_sound: bool) -> void:
	is_open = true
	_shape.set_deferred("disabled", true)
	var visual := get_node_or_null(Placeholder.VISUAL_NAME) as CanvasItem
	if visual != null:
		visual.visible = false
	if play_sound:
		Audio.play_sfx(&"gate_open", global_position)
	opened.emit()


static func _register_looks() -> void:
	for entity_kind: StringName in LOOKS:
		if not Placeholder.has_kind(entity_kind):
			Placeholder.register_kind(entity_kind, LOOKS[entity_kind], true)
