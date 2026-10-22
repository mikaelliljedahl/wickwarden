class_name Player
extends CharacterBody2D
## Tamsin. Top-down movement, lamp hook swing, charge flare, ward, sub-items, i-frames, death.
## All numbers come from docs/dev-world-plan.md section 4. Logic runs in _physics_process.
##
## Nodes are built in _ready (the scene is just a CharacterBody2D with this script), so the
## player works the same in tests and in the World.

signal died
signal hurt_taken(amount: int)
signal swing_started(facing: Vector2)
signal flare_fired
signal item_used(item_id: StringName)

enum State { NORMAL, SWING, FLARE, DEAD }

const WALK_SPEED := 360.0
const STOP_TIME := 0.06
const BODY_RADIUS := 26.0
const IFRAME_TIME := 0.9
const BLINK_INTERVAL := 0.08

const SWING_ARC_DEG := 110.0
const SWING_REACH := 120.0
const SWING_ACTIVE := 0.12
const SWING_TOTAL := 0.28
const SWING_DAMAGE := 2
const CHARGE_TIME := 0.8
const FLARE_REACH := 140.0
const FLARE_DAMAGE := 4
const FLARE_ACTIVE := 0.12
const FLARE_TOTAL := 0.30
const CHARGE_SPEED_MULT := 0.5
const WARD_SPEED_MULT := 0.4
const WARD_ARC_DEG := 120.0
const AXIS_PRESS := 0.5
const LAMP_RADIUS := 260.0
const HOOK_KNOCKBACK := 480.0
const HOOK_KNOCKBACK_TIME := 0.12

var state: State = State.NORMAL
## Cardinal facing: Vector2.UP / DOWN / LEFT / RIGHT.
var facing: Vector2 = Vector2.DOWN
var ward_up: bool = false
var charging: bool = false
var charge_ready: bool = false
var dark_mode: bool = false

var hurtbox: Hurtbox
var swing_hitbox: Hitbox
var flare_hitbox: Hitbox
var collector: PickupCollector
var lamp: PointLight2D
var visual: Node2D

var _swing_polygon: CollisionPolygon2D
var _swing_visual: Node2D
var _flare_visual: Node2D
var _ward_visual: Placeholder
var _state_time: float = 0.0
var _hold_time: float = 0.0
var _attack_prev: bool = false
var _item_prev: bool = false
var _cycle_prev: bool = false
var _iframes: float = 0.0
var _knock_velocity: Vector2 = Vector2.ZERO
var _knock_time: float = 0.0
var _locked: bool = false  # World freezes the player with process_mode; this is for tests/cutscenes


func _init() -> void:
	collision_layer = Layers.PLAYER_BODY
	collision_mask = Layers.WORLD
	motion_mode = MOTION_MODE_FLOATING


func _ready() -> void:
	add_to_group(&"player")
	var body := CollisionShape2D.new()
	body.name = "BodyShape"
	var circle := CircleShape2D.new()
	circle.radius = BODY_RADIUS
	body.shape = circle
	add_child(body)

	visual = _make_player_visual()
	_swing_visual = _make_swing_trail()
	_flare_visual = _make_flare_ring()
	_ward_visual = _make_arc_visual(&"ward", 64.0, WARD_ARC_DEG, "WardVisual")

	hurtbox = Hurtbox.new()
	hurtbox.name = "Hurtbox"
	hurtbox.team = Layers.Team.PLAYER
	hurtbox.add_circle(24.0)
	hurtbox.filter = _hurtbox_filter
	add_child(hurtbox)
	hurtbox.hurt.connect(_on_hurtbox_hurt)

	swing_hitbox = Hitbox.new()
	swing_hitbox.name = "SwingHitbox"
	swing_hitbox.team = Layers.Team.PLAYER
	swing_hitbox.kind = &"hook"
	swing_hitbox.damage = SWING_DAMAGE
	swing_hitbox.knockback = HOOK_KNOCKBACK
	swing_hitbox.knockback_time = HOOK_KNOCKBACK_TIME
	swing_hitbox.source = self
	_swing_polygon = CollisionPolygon2D.new()
	swing_hitbox.add_child(_swing_polygon)
	add_child(swing_hitbox)

	flare_hitbox = Hitbox.new()
	flare_hitbox.name = "FlareHitbox"
	flare_hitbox.team = Layers.Team.PLAYER
	flare_hitbox.kind = &"flare"
	flare_hitbox.damage = FLARE_DAMAGE
	flare_hitbox.knockback = HOOK_KNOCKBACK
	flare_hitbox.knockback_time = HOOK_KNOCKBACK_TIME
	flare_hitbox.source = self
	flare_hitbox.add_circle(FLARE_REACH)
	add_child(flare_hitbox)

	collector = PickupCollector.new()
	collector.name = "Collector"
	collector.owner_node = self
	collector.add_circle(28.0)
	add_child(collector)

	lamp = PointLight2D.new()
	lamp.name = "Lamp"
	lamp.texture = LightTexture.make()
	lamp.color = Color(1.0, 0.85, 0.55)
	lamp.energy = 1.1
	lamp.shadow_enabled = false
	lamp.enabled = false
	add_child(lamp)
	set_lamp_radius(LAMP_RADIUS)
	_apply_facing_visuals()


# ---- Public API ------------------------------------------------------------------------------


func get_lamp_radius() -> float:
	return float(lamp.texture.get_width()) * lamp.texture_scale * 0.5


func set_lamp_radius(radius: float) -> void:
	lamp.texture_scale = LightTexture.scale_for(radius)


## Dark rooms: the lamp lights the surroundings. Bright rooms: the lamp light is off.
func set_dark_mode(on: bool) -> void:
	dark_mode = on
	lamp.enabled = on


func is_invulnerable() -> bool:
	return _iframes > 0.0


func is_swinging() -> bool:
	return state == State.SWING


func is_dead() -> bool:
	return state == State.DEAD


func get_facing() -> Vector2:
	return facing


## Teleports the player and clears motion and pending actions (room entry, respawn).
func place_at(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	_knock_time = 0.0
	reset_actions()


## Cancels swing, charge and ward. Does not touch health or i-frames.
func reset_actions() -> void:
	if state != State.DEAD:
		state = State.NORMAL
	_state_time = 0.0
	_hold_time = 0.0
	charging = false
	charge_ready = false
	ward_up = false
	swing_hitbox.deactivate()
	flare_hitbox.deactivate()
	_attack_prev = Input.is_action_pressed(&"attack")
	_apply_facing_visuals()


## Brings the player back from DEAD at `pos` with i-frames cleared. Health is GameState's job.
func respawn(pos: Vector2) -> void:
	state = State.NORMAL
	_iframes = 0.0
	hurtbox.enabled = true
	hurtbox.invulnerable = false
	visual.visible = true
	visual.modulate = Color.WHITE
	place_at(pos)
	set_physics_process(true)


## Item API. Uses the active sub-item (GameState.active_item) through ItemRegistry. Returns true
## if an item instance was created and accepted the use.
func use_item() -> bool:
	var id := GameState.active_item
	if id == &"" or state != State.NORMAL:
		return false
	var item := ItemRegistry.create(id)
	if item == null:
		return false
	item.player = self
	item.facing = facing
	var parent := get_parent()
	if parent == null:
		item.free()
		return false
	parent.add_child(item)
	item.global_position = global_position
	if not item.activate():
		parent.remove_child(item)
		item.free()
		return false
	item_used.emit(id)
	return true


## Switches the active sub-item to the next acquired one.
func cycle_item() -> void:
	GameState.cycle_item()


## True if a raised ward stops `hitbox` (it must come from the front 120 degrees).
func ward_blocks(hitbox: Hitbox) -> bool:
	if not ward_up or not hitbox.blockable:
		return false
	var dir := hitbox.origin() - global_position
	if dir.length_squared() < 0.0001:
		return true
	return absf(facing.angle_to(dir)) <= deg_to_rad(WARD_ARC_DEG * 0.5) + 0.0001


## Applies damage (half-hearts) as a hit from `from_pos`, honouring i-frames. For scripted
## damage; normal hits arrive through the Hurtbox.
func take_damage(
	amount: int, from_pos: Vector2, knock_speed: float = 640.0, knock_time: float = 0.14
) -> bool:
	if state == State.DEAD or _iframes > 0.0:
		return false
	_apply_hit(amount, from_pos, knock_speed, knock_time)
	return true


# ---- Internals -------------------------------------------------------------------------------


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	_tick_iframes(delta)
	var attack_held := Input.is_action_pressed(&"attack")
	var attack_pressed := attack_held and not _attack_prev
	var attack_released := _attack_prev and not attack_held
	_attack_prev = attack_held

	if _knock_time > 0.0:
		_knock_time -= delta
		velocity = _knock_velocity
		move_and_slide()
		if _knock_time <= 0.0:
			velocity = Vector2.ZERO
		return

	_update_attack(delta, attack_held, attack_pressed, attack_released)
	_update_ward()
	_update_movement(delta)
	move_and_slide()
	_update_items()
	_update_lamp_glow()


func _update_attack(delta: float, held: bool, pressed: bool, released: bool) -> void:
	if _locked:
		return
	match state:
		State.NORMAL:
			if pressed:
				_start_swing()
			elif released and charge_ready:
				_start_flare()
			elif held:
				_hold_time += delta
				charging = _hold_time > SWING_TOTAL
				charge_ready = _hold_time >= CHARGE_TIME
			else:
				_hold_time = 0.0
				charging = false
				charge_ready = false
		State.SWING:
			_hold_time = _hold_time + delta if held else 0.0
			_state_time += delta
			if _state_time >= SWING_ACTIVE and swing_hitbox.active:
				swing_hitbox.deactivate()
			if _state_time >= SWING_TOTAL:
				state = State.NORMAL
				_state_time = 0.0
		State.FLARE:
			_state_time += delta
			if _state_time >= FLARE_ACTIVE and flare_hitbox.active:
				flare_hitbox.deactivate()
			if _state_time >= FLARE_TOTAL:
				state = State.NORMAL
				_state_time = 0.0
				_hold_time = 0.0


func _start_swing() -> void:
	state = State.SWING
	_state_time = 0.0
	_hold_time = 0.0
	charging = false
	charge_ready = false
	_build_swing_polygon()
	swing_hitbox.activate()
	_swing_visual.call("set_facing", facing)
	_swing_visual.visible = false  # toggle so the trail always restarts its sweep
	_swing_visual.visible = true
	swing_started.emit(facing)


func _start_flare() -> void:
	state = State.FLARE
	_state_time = 0.0
	_hold_time = 0.0
	charging = false
	charge_ready = false
	flare_hitbox.activate()
	_flare_visual.visible = false  # toggle so the ring always restarts its sweep
	_flare_visual.visible = true
	flare_fired.emit()


func _build_swing_polygon() -> void:
	var points := PackedVector2Array([Vector2.ZERO])
	var base := facing.angle()
	var half := deg_to_rad(SWING_ARC_DEG) * 0.5
	var steps := 10
	for i in range(steps + 1):
		points.append(
			Vector2.from_angle(base - half + 2.0 * half * float(i) / float(steps)) * SWING_REACH
		)
	_swing_polygon.polygon = points


func _update_ward() -> void:
	var want := (
		Input.is_action_pressed(&"ward") and state == State.NORMAL and not charging and not _locked
	)
	if want != ward_up:
		ward_up = want
		_ward_visual.visible = ward_up
		_ward_visual.set_facing(facing)


func _update_movement(delta: float) -> void:
	var input_dir := (
		Vector2.ZERO
		if _locked
		else Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	)
	var frozen := (
		(state == State.SWING and swing_hitbox.active)
		or (state == State.FLARE and flare_hitbox.active)
	)
	if frozen:
		velocity = Vector2.ZERO
		return
	var mult := 1.0
	if ward_up:
		mult = WARD_SPEED_MULT
	elif charging:
		mult = CHARGE_SPEED_MULT
	if input_dir != Vector2.ZERO:
		velocity = input_dir * WALK_SPEED * mult
		if not ward_up:
			_update_facing(input_dir)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, WALK_SPEED / STOP_TIME * delta)


## Facing is the last cardinal input. With a diagonal input the current facing is kept if one of
## its axes is still pressed; otherwise the horizontal axis wins.
func _update_facing(dir: Vector2) -> void:
	var px := absf(dir.x) >= AXIS_PRESS
	var py := absf(dir.y) >= AXIS_PRESS
	var new_facing := facing
	if px and not py:
		new_facing = Vector2(signf(dir.x), 0.0)
	elif py and not px:
		new_facing = Vector2(0.0, signf(dir.y))
	elif px and py:
		var keeps_x := facing.x != 0.0 and signf(facing.x) == signf(dir.x)
		var keeps_y := facing.y != 0.0 and signf(facing.y) == signf(dir.y)
		if not (keeps_x or keeps_y):
			new_facing = Vector2(signf(dir.x), 0.0)
	if new_facing != facing:
		facing = new_facing
		_apply_facing_visuals()


func _apply_facing_visuals() -> void:
	if visual != null:
		visual.call("set_facing", facing)
	if _ward_visual != null:
		_ward_visual.set_facing(facing)


func _update_items() -> void:
	var item_held := Input.is_action_pressed(&"use_item")
	if item_held and not _item_prev and not _locked:
		use_item()
	_item_prev = item_held
	var cycle_held := Input.is_action_pressed(&"cycle_item")
	if cycle_held and not _cycle_prev and not _locked:
		cycle_item()
	_cycle_prev = cycle_held


func _update_lamp_glow() -> void:
	var glow := 1.0
	if charging:
		glow = 1.5 if charge_ready else 1.25
	lamp.energy = 1.1 * glow
	set_lamp_radius(LAMP_RADIUS * glow)
	visual.modulate = Color(1.4, 1.25, 0.9) if charge_ready else Color.WHITE


func _tick_iframes(delta: float) -> void:
	if _iframes <= 0.0:
		return
	_iframes -= delta
	if _iframes <= 0.0:
		_iframes = 0.0
		hurtbox.invulnerable = false
		visual.visible = true
	else:
		visual.visible = int(_iframes / BLINK_INTERVAL) % 2 == 0


func _hurtbox_filter(hitbox: Hitbox) -> bool:
	if ward_blocks(hitbox):
		hitbox.blocked.emit()
		return false
	return true


func _on_hurtbox_hurt(hitbox: Hitbox) -> void:
	var amount := hitbox.damage_for(hurtbox)
	if amount <= 0:
		return
	_apply_hit(amount, hitbox.origin(), hitbox.knockback, hitbox.knockback_time, hitbox)


func _apply_hit(
	amount: int, from_pos: Vector2, knock_speed: float, knock_time: float, hitbox: Hitbox = null
) -> void:
	var dead := GameState.damage(amount)
	hurt_taken.emit(amount)
	Events.player_hurt.emit(amount)
	_iframes = IFRAME_TIME
	hurtbox.invulnerable = true
	# A hit cancels swing, charge and ward.
	reset_actions()
	if knock_speed > 0.0:
		var dir := global_position - from_pos
		if hitbox != null and hitbox.knockback_direction != Vector2.ZERO:
			dir = hitbox.knockback_direction
		if dir.length_squared() < 0.0001:
			dir = -facing
		_knock_velocity = dir.normalized() * knock_speed
		_knock_time = knock_time
	if dead:
		_die()


func _die() -> void:
	state = State.DEAD
	velocity = Vector2.ZERO
	_knock_time = 0.0
	hurtbox.enabled = false
	swing_hitbox.deactivate()
	flare_hitbox.deactivate()
	_swing_visual.visible = false
	_flare_visual.visible = false
	_ward_visual.visible = false
	visual.visible = true
	visual.modulate = Color(0.4, 0.4, 0.4, 0.7)
	died.emit()
	Events.player_died.emit()


## Tamsin's Visual: a PlayerVisual (painted art) when the manifest has `player`, else Placeholder.
## Same steps as SpriteVisual.attach (replace an old "Visual", name it, set kind, add it). The
## radius override is 0.0 so the manifest body radius (26) is used.
func _make_player_visual() -> Node2D:
	var art_script := load("res://scripts/art/player_visual.gd") as GDScript
	if art_script == null or not SpriteVisual.has_art(&"player"):
		return Placeholder.attach(self, &"player", 30.0)
	var old := get_node_or_null(SpriteVisual.VISUAL_NAME)
	if old != null:
		remove_child(old)
		old.free()
	var art := art_script.new() as SpriteVisual
	art.name = SpriteVisual.VISUAL_NAME
	art.kind = &"player"
	art.radius_override = 0.0
	add_child(art)
	return art


## The hook sweep: swing_trail.gd covers exactly the hit arc. Falls back to the Placeholder arc.
func _make_swing_trail() -> Node2D:
	var trail_script := load("res://scripts/art/swing_trail.gd") as GDScript
	if trail_script == null:
		return _make_arc_visual(&"hook_arc", SWING_REACH, SWING_ARC_DEG, "SwingVisual")
	var trail := trail_script.new() as Node2D
	trail.name = "SwingVisual"
	trail.visible = false
	add_child(trail)
	return trail


## The charge flare's ring: flare_ring.gd (a sweep, then a fade). Falls back to the Placeholder arc.
func _make_flare_ring() -> Node2D:
	var ring_script := load("res://scripts/art/flare_ring.gd") as GDScript
	if ring_script == null:
		return _make_arc_visual(&"flare", FLARE_REACH, 360.0, "FlareVisual")
	var ring := ring_script.new() as Node2D
	ring.name = "FlareVisual"
	ring.visible = false
	add_child(ring)
	return ring


func _make_arc_visual(
	kind: StringName, reach: float, degrees: float, node_name: String
) -> Placeholder:
	var arc := Placeholder.new()
	arc.name = node_name
	arc.kind = kind
	arc.radius = reach
	arc.arc_degrees = degrees
	arc.visible = false
	add_child(arc)
	return arc
