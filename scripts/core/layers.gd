class_name Layers
extends RefCounted
## Collision layers as BITMASK VALUES, and teams. The single source of truth.
##
## Godot stores `collision_layer` / `collision_mask` as bitmasks. Layer number N (as shown in the
## editor, starting at 1) has the bitmask value 1 << (N - 1). Never assign a layer *number* to
## `collision_layer`; always use the constants below. Project layer names (project.godot) match.
##
## | Layer | Bit value | Constant         | Used by (collision_layer)         | Detects (collision_mask)      |
## |-------|-----------|------------------|-----------------------------------|-------------------------------|
## | 1     | 1         | WORLD            | walls, rocks, closed doors, gates | -                             |
## | 2     | 2         | PLAYER_BODY      | Player (CharacterBody2D)          | WORLD                         |
## | 3     | 4         | ENEMY_BODY       | enemies (CharacterBody2D)         | WORLD                         |
## | 4     | 8         | PLAYER_HURTBOX   | player Hurtbox                    | -                             |
## | 5     | 16        | ENEMY_HURTBOX    | enemy Hurtbox                     | -                             |
## | 6     | 32        | PLAYER_HITBOX    | hook swing, flare, moth stun      | ENEMY_HURTBOX, PROP_HURTBOX   |
## | 7     | 64        | ENEMY_HITBOX     | contact damage, projectiles       | PLAYER_HURTBOX                |
## | 8     | 128       | PICKUP           | pickups (Area2D)                  | PICKUP_COLLECTOR              |
## | 9     | 256       | PICKUP_COLLECTOR | player collector, moth carrier    | -                             |
## | 10    | 512       | PROP_HURTBOX     | bush, brazier (hit by the hook)   | -                             |
## | 11    | 1024      | WATER            | blocker bodies of deep water      | player, ground enemies        |
## | 12    | 2048      | FEET             | foot sensors (Player, Pale Squire)| PitZone                       |
##
## Passive areas (hurtboxes, collectors) have mask 0. Active areas (hitboxes, pickups) poll their
## overlaps in `_physics_process`. Triggers (RoomDoor, LockedDoor) use layer 0 and mask PLAYER_BODY.

enum Team { PLAYER, ENEMY, NEUTRAL }

const WORLD := 1
const PLAYER_BODY := 2
const ENEMY_BODY := 4
const PLAYER_HURTBOX := 8
const ENEMY_HURTBOX := 16
const PLAYER_HITBOX := 32
const ENEMY_HITBOX := 64
const PICKUP := 128
const PICKUP_COLLECTOR := 256
const PROP_HURTBOX := 512
const WATER := 1024
const FEET := 2048


## Mask a Hitbox of this team needs to detect the hurtboxes it may damage.
static func hitbox_mask(team: Team) -> int:
	match team:
		Team.PLAYER:
			return ENEMY_HURTBOX | PROP_HURTBOX
		Team.ENEMY:
			return PLAYER_HURTBOX
		_:
			return PLAYER_HURTBOX | ENEMY_HURTBOX | PROP_HURTBOX


## Layer a Hitbox of this team lives on.
static func hitbox_layer(team: Team) -> int:
	return ENEMY_HITBOX if team == Team.ENEMY else PLAYER_HITBOX


## Layer a Hurtbox of this team lives on.
static func hurtbox_layer(team: Team) -> int:
	match team:
		Team.PLAYER:
			return PLAYER_HURTBOX
		Team.ENEMY:
			return ENEMY_HURTBOX
		_:
			return PROP_HURTBOX
