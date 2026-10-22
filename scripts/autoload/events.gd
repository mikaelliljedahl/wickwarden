extends Node
## Global signal bus. Emit from gameplay code, connect from HUD, world and tests.
## Nothing here holds state.

signal room_entered(room_id: StringName)
signal room_left(room_id: StringName)
signal enemy_died(enemy: Node, at: Vector2)
signal player_hurt(amount: int)
signal player_died
signal player_respawned
signal pickup_collected(kind: StringName)
signal brazier_lit(brazier_id: StringName)
signal explosion(at: Vector2, radius: float)
