extends EnemyProjectile
## Spore: the spitcap's ball. Flies straight at 360 px/s, deals 1 half-heart, is blockable by the
## ward and is destroyed by walls (all from EnemyProjectile).
## It does NOT declare a class_name (WP files must not; see docs/code-contract.md).


func _init() -> void:
	damage = 1
	speed = 360.0
	radius = 12.0
	blockable_by_ward = true
	lifetime = 5.0
	visual_kind = &"spore"
