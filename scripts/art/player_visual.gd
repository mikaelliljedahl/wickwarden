extends SpriteVisual
## Tamsin's Visual: a SpriteVisual that picks its animation from the parent Player's public state
## (docs/asset-contract.md section 9). Presentation only. It reads `state`, `facing`, `ward_up`,
## `charging`, `charge_ready`, `velocity` and the `hurt_taken` signal, and never writes to the
## parent. `modulate` and `visible` are left alone: player.gd uses them.
## player.gd creates it when SpriteVisual.has_art(&"player") is true, else keeps the Placeholder.

const HURT_TIME := 0.2

var _player: Player
var _hurt_time: float = 0.0
var _swing_time: float = 0.0
var _last_state: int = -1


func _init() -> void:
	super()
	auto_motion = false


func _ready() -> void:
	super()
	_player = get_parent() as Player
	if _player != null:
		_player.hurt_taken.connect(_on_hurt_taken)


func _process(delta: float) -> void:
	if _player == null or sprite_frames == null:
		return
	set_facing(_player.facing)
	var state := _player.state
	var entering := state != _last_state
	_last_state = state
	_hurt_time = maxf(_hurt_time - delta, 0.0)
	if state == Player.State.DEAD or _hurt_time > 0.0:
		_hold(&"hurt", 0)
	elif state == Player.State.SWING or state == Player.State.FLARE:
		_swing_frame(state, entering, delta)
	elif _player.ward_up:
		_hold(&"ward", 0)
	elif _player.charging:
		_hold(&"charge", 1 if _player.charge_ready else 0)
	elif _player.velocity.length() > MOVE_THRESHOLD:
		play_anim(&"walk")
	else:
		_hold(&"walk", 0)


func _on_hurt_taken(_amount: int) -> void:
	_hurt_time = HURT_TIME


## The swing (and flare) strip, once from frame 0 on the first frame of the state. The frames are
## spread over the state's duration, so it plays once even when the manifest loops the strip.
func _swing_frame(state: Player.State, entering: bool, delta: float) -> void:
	if entering:
		_swing_time = 0.0
	_swing_time += delta
	var total := Player.SWING_TOTAL if state == Player.State.SWING else Player.FLARE_TOTAL
	var count := _frame_count(&"swing")
	_hold(&"swing", mini(int(_swing_time / total * count), count - 1))


## Shows frame `index` of `base` (facing applied) and stops. Used for one-frame and held poses.
func _hold(base: StringName, index: int) -> void:
	var target := _resolve(base)
	if target == &"":
		return
	_base_anim = base
	if animation != target:
		animation = target
	stop()
	var count := sprite_frames.get_frame_count(target)
	set_frame_and_progress(clampi(index, 0, maxi(count - 1, 0)), 0.0)


func _frame_count(base: StringName) -> int:
	var target := _resolve(base)
	return 0 if target == &"" else sprite_frames.get_frame_count(target)
