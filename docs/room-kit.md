# Room kit: the `.room` source and its compiler

Work package F6 ([world-work-packages.md](world-work-packages.md)). The compiler is `tools/build_rooms.py` (stdlib
only). It turns one text file per room into the plain `.tscn` scene that `Room` loads. Rooms built this way are
never edited by hand; change the `.room` file and rebuild. The seven step-1 rooms stay hand-made and have no `.room`.

```
python3 tools/build_rooms.py [ROOM ...]      # validate and write scenes/world/rooms/<id>.tscn
python3 tools/build_rooms.py [ROOM ...] --check   # validate and compare with the committed scenes, write nothing
python3 -m unittest tools/test_build_rooms.py     # the compiler's own tests
```

`ROOM` is a room id (`ow_0_1`), a pocket id (`ow_7_2#bag`) or a file stem (`ow_7_2__bag`). Without it every
`tools/rooms/*.room` is built. Errors print as `file:line: message` and fail the run; a room with an error is
not written. The compiler reads `data/world_data.json` (run `make world-data` first). Room id, grid cell, exits,
`dark`, scope and the monster counts come from the graph, never from the file.

## Files

| File | Content |
|---|---|
| `tools/rooms/<id>.room` | a room (overworld or cave): `ow_3_3.room`, `cave_4_7.room` |
| `tools/rooms/<host>__<tag>.room` | a pocket that has its own scene: `ow_7_2__bag.room` for `ow_7_2#bag` |
| `scenes/world/rooms/<id>.tscn` | the output (`<host>__<tag>.tscn` for a pocket) |

A pocket that opens in place (`ow_2_0#cache`, `ow_2_1#closet`, `cave_1#alcove`) has no file of its own: its
content goes into the host room's file, and the compiler refuses a file for it.

## The file

```
; comment (from ';' to the end of the line)
room ow_0_1                       ; required; must equal the file's room id
terrain Reedpond: pond, reeds     ; optional text, copied into the scene as a comment
floor_color 0.16 0.25 0.25        ; optional r g b from 0 to 1; without it Room keeps its default
grid
#########..#########              ; exactly 10 rows of exactly 20 characters, no comments inside
#...ee..............#
...
enemy duskmoth 2,2                ; entities follow the grid
pickup item tether_moth @1392,742
```

## Grid

One character per tile. A tile `(c, r)` has its centre at `(96c + 48, 96r + 48)` in room-local pixels; the room
is 20 x 10 tiles.

| Char | Meaning | Output |
|---|---|---|
| `.` | floor, or the gap of a graph exit on the ring | nothing |
| `#` | wall. On the ring it is the wall that Room draws; inside the ring it is a block | `SolidBlock` kind `wall`, merged into maximal rectangles |
| `w` | water | `SolidBlock` kind `water`, merged into rectangles |
| `r` | rock | `SolidBlock` kind `rock`, one per tile |
| `t` | tree | `SolidBlock` kind `tree`, one per tile |
| `e` | reed | `SolidBlock` kind `reed`, one per tile |
| `b` | bush | `Bush` (`bush.gd`) in `Bushes`, one per tile |

Merging is greedy and row-major: the first unused tile of a kind starts a rectangle, extended to the right as far
as the row goes and then down while whole rows match. Ring `#` is never merged.

### The ring

The ring is the room's wall. Each side in the graph's `exits` has a two-tile gap in the middle, and every other
ring tile is `#`:

| Side | Gap tiles |
|---|---|
| n | `(9,0)`, `(10,0)` |
| s | `(9,9)`, `(10,9)` |
| w | `(0,4)`, `(0,5)` |
| e | `(19,4)`, `(19,5)` |

A gap of a graph exit is `.`. A gap of a side that the graph does not list is `#`. Pockets have no exits, so their
ring is all `#`; their door is an interior trigger (see `door` below).

## Entities

A position is `x,y` (whole tiles, the tile centre) or `@x,y` (room-local pixels, for a pedestal item and
such). A hollow must stand on a tile centre; the compiler checks it whatever the form.

| Line | Output |
|---|---|
| `enemy <name> <pos>` | an instance of `scenes/enemies/<name>.tscn` in `Enemies`. Names are the graph names in lower case with spaces as `_` (`tallow_blob`); a `NEW:` prefix is dropped. |
| `pickup item <tool id> <pos>` | `item_pickup.tscn` with `persistent_id` and `item_id` = the tool id |
| `pickup <kind> <pos> id=<id> [requires=<flag>] [scope=<s>]` | the scene of the kind (table below); a `small_key` takes the room's scope unless `scope=` says otherwise (`scope=` is an error for other kinds) |
| `prop <kind> <pos> [size=<w>,<h>]` | a plain `SolidBlock` of a kind in `PROP_KINDS` (`hut`, `pedestal`, `sign_post`, `wall`, `water`, `rock`, `tree`, `reed`); size defaults to 96 x 96. A prop with its own script (a hedge, a gate, a switch) is not a plain block and has no line yet |
| `opener cracked_wall <pos> id=<id>` | `cracked_wall.tscn` (96 x 96), `wall_id` = id |
| `opener locked_door <pos> id=<id> [scope=<s>] [size=<w>,<h>]` | a `LockedDoor` (192 x 96 by default), `door_id` = id, scope = the room's scope unless given |
| `door <target room> <spawn> <pos>` | a `RoomDoor` trigger (96 x 96) that warps to `target room` at marker `spawn` |
| `spawn <name> <pos>` | a `Marker2D` in `Spawns`. `Default` is the spawn of the room. |

Pickup kinds and scenes:

| Kind | Scene | Kind | Scene |
|---|---|---|---|
| `item` (a tool) | `scenes/pickups/item_pickup.tscn` | `pot_bag` | `scenes/pickups/pot_bag.tscn` |
| `wick_core` | `scenes/pickups/wick_core.tscn` | `pot_bundle` | `scenes/pickups/pitch_pot_bundle.tscn` |
| `small_key` | `scenes/pickups/key.tscn` | `slug_bundle` | `scenes/pickups/slug_bundle.tscn` |
| `big_key` | `scenes/pickups/big_key.tscn` (F4) | `fragment` | `scenes/pickups/fragment.tscn` (F4) |

The graph's `cache` and `shop` pickups have no kind here yet (no scene). A room with one does not compile.

## What the compiler checks

Every error fails the build of that room.

1. The header id equals the file name, is in the graph, and is not an in-place pocket.
2. The ring matches the graph exits (gap `.` on each exit, `#` elsewhere) and only `#` `.` `w` `r` `t` `e` `b`
   appear in the grid.
3. The corridor of every exit (three tiles deep, two wide, ring tiles included) has no solid tile. Openers may
   stand in a gated gap (world-plan 1.1: a gate can stand in the gap or in the corridor).
4. Every open exit (no opener on its gap) is reachable from the spawn with every opener closed.
5. The default spawn and every other marker are not on an obstacle.
6. The enemies equal the graph's counts; a hollow is on a tile centre; no enemy starts on an obstacle; every
   enemy scene exists.
7. Placed pickups equal the graph's pickups of the room and of its in-place pockets: same ids, same kinds, none
   missing, none extra. A pickup id is the graph id (`wick_core_ow_2_0`, `bigkey_c1`, `frag_c1`, a tool name).
   A `bigkey:cN` or `frag:cN` item of the graph is the pickup `bigkey_cN` or `frag_cN`.
8. A pickup of the room is reachable from the spawn and from every open exit. A pickup of an in-place pocket is
   sealed: unreachable with every opener closed, and reachable when exactly one opener is opened.
9. Each plain door of the graph to a room that is not in-place has a `door` line to that partner; every `door`
   line targets a graph partner of this room; door spawn names are one of `Default`, `FromCave`, `FromOverworld`, `FromPocket`, `Inside`.
10. Ids of openers and pickups are unique in the room. Opener footprints are not on an obstacle.
11. Every scene and script the room refers to exists. The message names the missing file.

Obstacles are the solid tiles of the grid and the footprints of `prop` entities, with the 4 px margin of
`tests/area_base.gd`. Enemies and spawns may not stand on an obstacle; a pickup may (a pedestal item sits 22 px
in front of its pedestal, so `@x,y` with y = 96r + 70).

## Persistent ids

Pickup ids are the graph ids. The dev-world rooms keep the ids of code-contract section 15 (`wick_core_cache`,
`pitch_pot`); a new room follows the graph (`wick_core_ow_2_0`). See the report of F6 for the open question.

## Out of scope for this compiler

- Props with their own script (`burnable.gd` hedges and doors, `gate.gd`, `brazier.gd`, `eye_switch.gd`, ...) need
  an entity line each. The compiler refuses them as `prop` lines; a room that needs one waits for its entity kind.
- Gates (`gate` edges) are not checked against an opener here; `tests/test_world_graph.gd` and the area tests do
  that on the built scenes.
- Pickups with `after_boss` in the graph must carry `requires=boss_<room>_defeated`; the compiler checks the form only.
