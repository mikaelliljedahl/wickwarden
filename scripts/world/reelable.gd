extends Node2D
## Reelable part (monsters-bosses-tools.md 5.8): a plate or a hook that a reel tip can yank. It is in group
## `reelable` and has a NEUTRAL hurtbox on PROP_HURTBOX that takes only `reel` hits. Each accepted hit emits
## `reeled`; what happens then (a plate flies off, a lantern slides) is the owner's decision. The part holds no
## state, so rooms can unload at any time.

signal reeled(hitbox: Hitbox)

const GROUP := &"reelable"
const HIT_KIND := &"reel"
const LOOK := &"reelable"
const LOOK_RADIUS := 22.0
const HURT_RADIUS := 26.0

var hurtbox: Hurtbox


func _ready() -> void:
	add_to_group(GROUP)
	_register_kinds()
	hurtbox = Hurtbox.new()
	hurtbox.name = "Hurtbox"
	hurtbox.team = Layers.Team.NEUTRAL
	hurtbox.add_circle(HURT_RADIUS)
	hurtbox.filter = _accepts_hit
	add_child(hurtbox)
	hurtbox.hurt.connect(_on_hurt)
	Placeholder.attach(self, LOOK, LOOK_RADIUS)


func _accepts_hit(hitbox: Hitbox) -> bool:
	return hitbox.kind == HIT_KIND


func _on_hurt(hitbox: Hitbox) -> void:
	reeled.emit(hitbox)


static func _register_kinds() -> void:
	if not Placeholder.has_kind(LOOK):
		Placeholder.register_kind(
			LOOK, {"shape": "rect", "color": Color(0.6, 0.6, 0.64), "size": Vector2(40, 40)}, true
		)
