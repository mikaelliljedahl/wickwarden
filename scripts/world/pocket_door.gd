extends "res://scripts/world/room_door.gd"
## A pocket door (P14): the way into a pocket (a shop, a hut, a grotto, a cache) that looks like the
## entrance it is named after: stall, cart, lighthouse, mason, hut, grotto, stairs or plain.
##
## It is a RoomDoor. `target_room` and `target_spawn` come from the room data (the room compiler writes
## them): the way in leads to the pocket's `Inside` marker, the way out to the host room's `FromPocket`
## marker. `fade` stays true, because the graph's link kind of a pocket is `door`. The door inside a
## pocket is this same scene, so one scene serves both sides.
##
## Visual: placeholder kinds `pocket_<variant>`, registered here (no content WP edits Placeholder.KINDS).

const LOOK_COLOURS := {
	"stall": Color(0.45, 0.3, 0.18),
	"cart": Color(0.55, 0.42, 0.25),
	"lighthouse": Color(0.82, 0.8, 0.74),
	"mason": Color(0.5, 0.5, 0.52),
	"hut": Color(0.5, 0.33, 0.25),
	"grotto": Color(0.14, 0.2, 0.16),
	"stairs": Color(0.3, 0.3, 0.36),
	"plain": Color(0.25, 0.2, 0.16),
}

## The entrance the door looks like (no text): stall, cart, lighthouse, mason, hut, grotto, stairs, plain.
@export_enum("stall", "cart", "lighthouse", "mason", "hut", "grotto", "stairs", "plain")
var variant: String = "plain"


func _init() -> void:
	super()
	_register_looks()


func _ready() -> void:
	super._ready()
	if not LOOK_COLOURS.has(variant):
		push_warning("PocketDoor: unknown variant '%s'" % variant)
	SpriteVisual.attach(self, look_kind(), 0.0, size)


## The placeholder kind of the look: pocket_<variant>.
func look_kind() -> StringName:
	return StringName("pocket_%s" % variant)


static func _register_looks() -> void:
	for variant_name in LOOK_COLOURS:
		var kind := StringName("pocket_%s" % variant_name)
		if Placeholder.has_kind(kind):
			continue
		var shape := "circle" if variant_name == "grotto" else "rect"
		var definition := {
			"shape": shape,
			"color": LOOK_COLOURS[variant_name],
			"size": Vector2(96, 96),
			"radius": 48.0,
		}
		Placeholder.register_kind(kind, definition, true)
