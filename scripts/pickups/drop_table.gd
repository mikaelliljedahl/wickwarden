class_name DropTable
extends RefCounted
## Enemy drop table (plan section 5). One roll in [0, 1) picks at most one drop, so the
## chances are cumulative and mutually exclusive: ember 25 %, brass bit 35 %, brass coin 5 %,
## pitch pot bundle 10 %, nothing 25 %. The bundle only drops once the pitch pot item is found;
## when it is not, that slice drops nothing.

const TABLE := [
	[&"ember", 0.25],
	[&"brass_bit", 0.35],
	[&"brass_coin", 0.05],
	[&"pitch_pot_bundle", 0.10],
]


## Returns the pickup kind for roll `r` in [0, 1), or &"" for no drop.
static func pick(r: float, pitch_pot_found: bool) -> StringName:
	var acc := 0.0
	for entry in TABLE:
		acc += float(entry[1])
		if r < acc:
			var kind: StringName = entry[0]
			if kind == &"pitch_pot_bundle" and not pitch_pot_found:
				return &""
			return kind
	return &""


## Rolls with the global RNG and the current GameState. Pass roll >= 0 to force the roll (tests).
static func roll(forced_roll: float = -1.0) -> StringName:
	var r := forced_roll if forced_roll >= 0.0 else randf()
	return pick(r, GameState.has_item(&"pitch_pot"))
