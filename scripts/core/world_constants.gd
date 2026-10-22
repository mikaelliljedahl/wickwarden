class_name WorldConst
extends RefCounted
## Geometry and timing constants for the room system (plan sections 1 and 2).

const TILE := 96
const ROOM_TILES := Vector2i(20, 10)
const ROOM_SIZE := Vector2(1920.0, 960.0)
const HUD_HEIGHT := 120.0
const SCREEN_SIZE := Vector2(1920.0, 1080.0)
## Border wall ring thickness. Exits are gaps in this ring.
const WALL_THICKNESS := 96.0
const EXIT_WIDTH := 192.0
const SLIDE_TIME := 0.45
const FADE_TIME := 0.3
## Distance of the player from the room edge after a slide (one tile).
const ENTRY_INSET := 96.0
## Camera centre relative to a room origin so the room fills y 120..1080 of the screen.
const CAMERA_OFFSET := Vector2(960.0, 420.0)
