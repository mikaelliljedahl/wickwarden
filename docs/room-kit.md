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
`dark`, scope and the monster counts come from the graph, never from the file. Shop prices come from
`data/shop_prices.json`; the contents of a cache come from the graph text (see `cache` below).

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
| `miniboss <name> <pos>` / `boss <name> <pos>` | the raw graph encounter, exactly once, in `Enemies`, from `scenes/enemies/minibosses/<name>.tscn` or `scenes/enemies/bosses/<name>.tscn`. These are separate from regular enemy counts. Missing scenes fail compilation. |
| `arena <boss name> <pos>` | explicit instance of `scenes/bosses/<name>_arena.tscn` in `Props`; the name must match this room’s graph boss. Use `@0,0` for room-local arena geometry. At most one; the file must exist. |
| `brazier <pos> id=<id>` | a `Brazier` using the committed script, with `brazier_id`. Solid on its tile. |
| `opener gate <pos> id=<edge id> braziers=<id>,<id> [size=<w>,<h>]` | `Gate` script with `gate_id`, `size` and typed `Array[NodePath]` references to the named room braziers. The edge must be a graph brazier gate touching this room. The graph prop `two braziers, gate` requires two distinct references. |
| `opener boss_door <pos> id=<edge id> [size=<w>,<h>]` | `boss_door.tscn`, with its `cave` export taken from room scope; the graph edge must require that cave’s big key. |
| `enemy <name> <pos>` | an instance of `scenes/enemies/<name>.tscn` in `Enemies`. Names are the graph names in lower case with spaces as `_` (`tallow_blob`); a `NEW:` prefix is dropped. |
| `pickup item <tool id> <pos>` | `item_pickup.tscn` with `persistent_id` and `item_id` = the tool id |
| `pickup <kind> <pos> id=<id> [requires=<flag>] [scope=<s>]` | the scene of the kind (table below); `small_key`, `big_key` and `fragment` infer scope from the graph pickup/capability, falling back to room scope for a small key; an explicit `scope=` must match. The historical alcove key keeps graph scope `ow` |
| `prop <kind> <pos> [size=<w>,<h>]` | a plain `SolidBlock` of a kind in `PROP_KINDS` (`hut`, `pedestal`, `sign_post`, `wall`, `water`, `rock`, `tree`, `reed`); size defaults to 96 x 96. Scripted props use their own entity lines below. |
| `anchor_ring <pos> [look=<kind>] [max_range=<pixels>]` | the real `anchor_ring.tscn` target, with optional `look` (`anchor_ring` or `anchor_pocket`) and finite nonnegative `max_range` (0 = no ring-specific limit; the reel still stops at 576 px). The ring is non-solid and does not open or hold state. |
| `opener resonance_door <pos> id=<id> [size=<w>,<h>]` | `resonance_door.tscn`, `resonance_id` = id, 192 x 96 by default. Only the lantern chime wakes the physical block; the persistent flag is `resonated_<id>`. Pair with the cave-mouth `door`. |
| `opener sealed_seam <pos> id=<id> [size=<w>,<h>]` | `sealed_seam.tscn`, `seam_id` = id, 192 x 96 by default. The glow jar reveals it; the scene keeps hook taps disabled. Pair with the cache `door`, whose blocker link tracks the seam's shown state and child body. |
| `opener ninth_door <pos> id=<compiler id> [size=<w>,<h>]` | `ninth_door.tscn`, 192 x 96 by default. The id selects the compiler's door link; no id property is exported. The existing scene checks all nine fragments on touch and persists `door_ninth`. Pair with the C10 mouth `door`. |
| `opener eye_portcullis <pos> id=<id> [size=<w>,<h>]` | Existing eye switch scene in blocker mode; pairs with `eye_switch <pos> id=<id>`. Graph props `eye switch` and `eye-switch portcullis` both require item / `tallow_sling`. |
| `opener heavy_stone <pos> id=<id> [size=<w>,<h>]` | Existing lift-mode `heavy_stone.tscn`, `stone_id` = id. Graph props `heavy stone` and `heavy stones` both require item / `heft_mitts`; this remains the LIFT scene, while `heavy_boulder` is the separate PUSH scene. |
| `opener hidden_seam <pos> id=<graph edge id> [size=<w>,<h>]` | `hidden_seam.tscn`, `seam_id` = the shared graph edge id (flag `revealed_<id>`), 192 x 96 by default. The glow jar reveals the real WORLD child body. A hidden step seam requires hidden / `glow_jar`, seals the exit while hidden, and must expose the exit when revealed; no RoomDoor is made. |
| `opener hook_tap_wall <pos> id=<id> [size=<w>,<h>]` | `hook_tap_wall.tscn`, `seam_id` = id, 192 x 96 by default; the scene enables hook taps. Graph prop `hook-tap wall` requires hidden / hook. Pair with a `door` to the cache. |
| `opener wax_seal <pos> id=<id> [size=<w>,<h>]` | `wax_seal.tscn`, `seal_id` = id, 192 x 96 by default; only charge flare melts it. Graph prop `wax seal` requires item / flare. Pair with a `door` to the cache. |
| `opener heavy_boulder <pos> id=<id> [size=<w>,<h>]` | `heavy_boulder.tscn`, `stone_id` = id, 96 x 96 by default; the scene uses PUSH mode and requires Heft Mitts. Graph prop `heavy boulder` requires item / heft_mitts. Pair with the cave-mouth `door`. |
| `opener cracked_wall <pos> id=<id>` | `cracked_wall.tscn` (96 x 96), `wall_id` = id |
| `opener locked_door <pos> id=<id> [scope=<s>] [size=<w>,<h>]` | a `LockedDoor` (192 x 96 by default), `door_id` = id, scope = the room's scope unless given |
| `opener thorn_hedge <pos> id=<id> [size=<w>,<h>]` | `thorn_hedge.tscn` (192 x 96 by default), `burn_id` = id; the flag is `burned_<id>`. It must stand in a graph exit corridor and rotates to fit an east or west gap. |
| `opener cut_screen <pos> look=<name>` | a cuttable Bush scene; `name` is `reed_cluster`, `rush_wall`, `moss_wall` or `dry_vine_screen`. Each line is one screen tile; place one per tile to cover a two-tile exit gap. The compiler puts these `Bush` instances in `Bushes`, so `Room` snapshots and regrows them on room entry. Screens take no id. |
| `hidden_stairs <target room> <spawn> <pos> id=<id>` | `hidden_stairs.tscn` (192 x 96); the reveal flag is `revealed_<id>`, and the revealed door targets the given room and spawn |
| `door <target room> <spawn> <pos> [blocker=<opener id>]` | a `RoomDoor` trigger (96 x 96) that warps to `target room` at marker `spawn` |
| `spawn <name> <pos>` | a `Marker2D` in `Spawns`. `Default` is the spawn of the room. |
| `shop <S1..S6> <stock> <pos> [id=<stock id>]` | a `ShopItem` (`scenes/world/shop_item.tscn`) with `shop`, `stock` and, when given, `stock_id`. The stock is `ember`, `pot_bundle`, `slug_bundle` or `tallow_flask`. A one-time stock (`pot_bundle`, `slug_bundle`) needs `id=` (its flag is `shop_<id>`). The price is not written: `ShopItem` reads it from `data/shop_prices.json`, and the compiler checks that the stock is priced for that shop. Use `@x,y` with y = 96r + 70 for a stock item on a pedestal. |
| `cache <pos> id=<graph cache id>` | the contents of the graph's cache `<id>`, placed on its spot as pickups: brass as one `brass_coin` with `amount` = the brass, each ember as `ember.tscn`, a pot bundle as `pitch_pot_bundle.tscn`. Their ids are `<id>_brass`, `<id>_ember<n>` and `<id>_pots`. A slug bundle of a cache is not a piece: the graph gives it its own pickup, placed by a `pickup slug_bundle` line. |

Pickup kinds and scenes:

| Kind | Scene | Kind | Scene |
|---|---|---|---|
| `item` (a tool) | `scenes/pickups/item_pickup.tscn` | `pot_bag` | `scenes/pickups/pot_bag.tscn` |
| `wick_core` | `scenes/pickups/wick_core.tscn` | `pot_bundle` | `scenes/pickups/pitch_pot_bundle.tscn` |
| `small_key` | `scenes/pickups/key.tscn` | `slug_bundle` | `scenes/pickups/slug_bundle.tscn` |
| `big_key` | `scenes/pickups/big_key.tscn` (F4) | `fragment` | `scenes/pickups/fragment.tscn` (F4) |

The graph's `cache` pickup is placed by the `cache` line and its shop stock by the `shop` lines, not by `pickup`.

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
   A `bigkey:cN` or `frag:cN` item of the graph is the pickup `bigkey_cN` or `frag_cN`. A `cache` line is the
   graph's `cache` pickup of its id. Shop records are checked in item 12.
8. A pickup of the room is reachable from the spawn and from every open exit. A pickup of an in-place pocket is
   sealed: unreachable with every opener closed, and reachable when exactly one opener is opened.
9. Each plain door of the graph to a room that is not in-place has a `door` line to that partner; every `door`
   line targets a graph partner of this room; door spawn names are one of `Default`, `FromCave`, `FromOverworld`, `FromPocket`, `Inside`.
10. Ids of openers and pickups are unique in the room. Opener footprints are not on an obstacle.
11. Every scene and script the room refers to exists. The message names the missing file.
12. Shops. A room with a `shop` line is the graph's shop of that id (`ow_1_2#shop` is `S1`), and a shop room has
    at least one stock line. Each stock line is priced for its shop in `data/shop_prices.json`, has an `id=` when it
    is one-time stock, and is reachable from the spawn. Each graph slug bundle of the shop (its `shop` field) is
    placed by a `shop slug_bundle` line with the same id. A cache's text must be one the compiler knows: `N brass`,
    `ember`, `N embers`, `pot bundle` or `slug bundle` (the last one is its own pickup line).

Obstacles are the solid tiles of the grid and the footprints of `prop` entities, with the 4 px margin of
`tests/area_base.gd`. Enemies and spawns may not stand on an obstacle; a pickup may (a pedestal item sits 22 px
in front of its pedestal, so `@x,y` with y = 96r + 70).

## Shop and cache templates

`tests/fixtures/rooms/shop.room` is the shop template: pedestals, two stock items of shop S1 and the door. The
tests compile it as `ow_1_2__shop.room`. The cache contents are read from `docs/world-graph.json` at build time:
`data/world_data.json` does not carry the `contents` text yet (`tools/gen_world_data.py` drops it). A later
change to the generator can move that read to `data/world_data.json`.

## Persistent ids

Room files identify pickups by graph id for validation. In the seven dev rooms, the compiler writes the persistent
ids used by code-contract section 15 and the dev tests: `wick_core_ow_2_0` becomes `wick_core_cache`, and `key_ow_1`
becomes `cave_key`; `tether_moth` and `pitch_pot` keep their names. Pickups in other rooms keep their graph ids.

## Additional validation and limits

- Other props with their own script not listed above
  still need an entity line each. The compiler refuses them as `prop` lines until their entity kind exists.
- Completeness of all graph gates remains checked by `tests/test_world_graph.gd` and the area tests. Authored cave gate and boss-door lines are checked against their graph edge and footprint.
- Pickups with `after_boss` in the graph must carry the exact `requires=boss_<pickup node>_defeated`, including wick cores and fragments.

Cave gate sizes default to 192 x 96. East/west step gates swap width and height; step gates must block their own graph corridor while closed and allow passage when opened. Brazier ids must be unique and gate references must resolve exactly once after output node sorting. Arena door locking remains outside the compiler. The historical `cave_1` remains handmade.

Room-level small keys with graph `needs=["tether_moth"]` use the permanent-grate check too: the key must be sealed from walking, with a clear straight moth launch across a grate within 420 px from the default spawn, every authored spawn and every graph exit entry. Both wick-core and fragment `after_boss` rewards require their own pickup node’s exact boss flag.

Gated mouth doors bind `blocker_path` to the actual opener node. Use `blocker=<opener id>` to select an offset blocker explicitly; otherwise the matching graph edge id, colocated opener or unique matching kind is selected. The three opener kinds above take only `id` and `size`; their scenes supply interaction modes. A custom persistent id such as `cave6door` is supported.

### Reel corridors

For a graph step gate with prop `anchor ring`, use `anchor_ring` targets and real `pit` zones. The edge must require exactly `reel_line` as an item. The compiler checks that the gate exit cannot be reached by walking or by successive safe 192 px boots leaps, and can be reached by a clear cardinal reel pull from a reachable tile centre. The line must cross one contiguous 288–480 px pit chasm, hit the ring within 576 px (and its optional range limit), and stop 72 px before it on safe floor. WORLD obstacles stop the line. Landing checks include the pit's 26 px player-body margin. A two-way edge also needs a valid pull back from the exit bank to the default spawn's component; place a return ring on the opposite bank. Ring positions must be inside the room and off obstacles.

The proof uses local geometry in each room, so put the target and landing bank before the gated exit. An anchor ring does not create a remote target in an unloaded neighbour. These checks conservatively use cardinal launches from tile centres; diagonal or off-centre launch solutions are not inferred. The ordinary corridor rule still applies to other exits. No `opener`, gate flag, door blocker or item-presence shortcut stands in for the chasm and reel target.

### Remaining Hushmarch mouths

Use `opener resonance_door ... id=e253` with `door cave_8_1 FromOverworld ... blocker=e253`; use `opener sealed_seam ... id=e144` with `door ow_11_7#cache Inside ... blocker=e144`; use `opener ninth_door ... id=e255` with `door cave_10_1 FromOverworld ... blocker=e255`. Each takes only `id` and optional `size`; the scene supplies the interaction. These graph mouths require their actual door line, and their exact gate type and capability list are validated even when a custom compiler id is used.

For e145, use `anchor_ring ... look=anchor_pocket`, real `pit` geometry and `door ow_8_8#cache Inside ...` on the landing bank. This door takes no `blocker=`: the non-solid ring has no open state. Walking and boots must not reach the mouth from Default; a clear, safe reel pull must reach it. Supply a `FromPocket` spawn on the mouth's landing bank and a return ring that permits a pull back to Default's component. All ordinary graph exits must still be reachable on foot from Default with their corridors clear. A WORLD block overlapping a pit still stops the reel tip, regardless of entity order.

Audit of remaining R3.b/c/d, R5.d and R6.a/b/c gate props: heavy stones, anchor-ring steps, ravine leaps, locked doors, cracked walls and hidden stairs already have entity support. The four mouths above complete the missing kinds in those batches. This does not claim support for every future cave prop.

### Cistern screens and flooded corridors

`opener cut_screen <pos> look=moss_wall` instances the existing cuttable `moss_wall.tscn` Bush variant (e164). As with reed screens, author one screen per tile to seal a two-tile corridor; cutting opens the tile and the screen regrows on room entry.

Graph raft props `flooded passage` (including e167/e168) and `mooring and water` use the same mooring-target and corridor checks. A flooded exit needs its authored paired-lane mooring and water that denies walking through the exit; its landing must remain clear. Only an adjacent graph step edge with one of these two props receives the raft corridor exception. Unrelated water in an ordinary corridor does not receive that exception.

The `dry_vine_screen` look uses the existing `Bush` scene and hook-cut behavior (e182). Match each screen look to the graph cut prop at that exit; the compiler rejects a mismatched look for graph props it recognizes.

Encounter names in `miniboss` and `boss` lines normalize spaces and hyphens to underscores for scene filenames only (for example graph `Lull-Mauler` becomes `lull_mauler`). Apostrophes are removed from encounter filenames (`Corrow's Echo` -> `corrows_echo`). Graph IDs, flags and key names keep their original spelling.
