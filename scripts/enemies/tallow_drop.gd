extends "res://scripts/enemies/tallow_blob.gd"
## Tallow drop (plan section 6): the small piece a tallow blob splits into. Same stepping as the
## blob, but 1 hp, speed 220 and smaller. A drop never splits. No class_name (see code contract).


func _init() -> void:
	super()
	max_hp = 1
	contact_damage = 1
	move_speed = 220.0
	visual_kind = &"tallow_drop"
	body_radius = 20.0


## A drop never splits: its death only rolls the drop table (done by the base).
func _on_death() -> void:
	pass
