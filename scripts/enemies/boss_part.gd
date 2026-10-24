extends EnemyBase
## A damageable part of a boss: a seed-eye, a lock plate, a choir head, the tail tip, a lantern hook.
## A part is an ordinary EnemyBase (own hp, flash, death). The boss adds it with adopt_part(), which
## connects the part's `damaged` and `died` signals to the boss. The part never calls the boss itself.
## Boss rules by default: immune to stun and knockback (monsters-bosses-tools section 4.0); no drops.
## Parts that the boss tables name as stunnable or pushable set stun_scale / knockback_scale in their _init().
## Set `invulnerable = true` (or the hurtbox's `enabled`) to close a part; set `accepted_kinds` to the kinds
## that hurt it (for example [&"sling"] for a seed-eye).
## It does NOT declare a class_name (WP files must not; see docs/code-contract.md).

## Hitbox kinds that can hurt this part. Empty = every kind that reaches the hurtbox.
@export var accepted_kinds: Array[StringName] = []


func _init() -> void:
	_register_kinds()
	visual_kind = &"boss_part"
	body_radius = 26.0
	drops_enabled = false
	stun_scale = 0.0
	knockback_scale = 0.0


func _enemy_ready() -> void:
	if not accepted_kinds.is_empty():
		hurtbox.filter = _accepts_hitbox


## Placeholder look of the parts (placeholder visuals only).
static func _register_kinds() -> void:
	if not Placeholder.has_kind(&"boss_part"):
		Placeholder.register_kind(
			&"boss_part", {"shape": "circle", "color": Color(0.55, 0.2, 0.3), "radius": 26.0}
		)


func _accepts_hitbox(hitbox: Hitbox) -> bool:
	return accepted_kinds.is_empty() or accepted_kinds.has(hitbox.kind)
