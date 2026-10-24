# Wickwarden: master world plan

Status: plan only. No code, scene or art changes come with this document.
Companion files: [world-graph.json](world-graph.json) (the machine-readable graph) and
[../tools/check_world_graph.py](../tools/check_world_graph.py) (the checker).

This plan grows the step-1 dev world ([dev-world-plan.md](dev-world-plan.md)) into the full game:
one large overworld of single-screen rooms and ten caves, the **Underlights** (the fallen lanterns
of [story.md](story.md)). The underworld is only these caves. The structure is a homage to the first
classic top-down adventures: free exploration, dungeons entered from the overworld, sub-items hidden
in the dungeons, each item opening new paths, secrets, shops, heart pieces (wick cores) and a final
dungeon. Mechanics, names and layouts are original.

**What does not change.** Every number in `dev-world-plan.md` stays: 96 px tiles, rooms of 20x10
tiles, the player, the two items, the five monsters, the HUD band. The dev world stays valid and
becomes the start of the big world (section 3.5 lists the few edits to the existing scenes). New
tools and monsters get their own numbers in their own specs. Hints are visual only: there is no
tutorial text in the game world.

## Summary

| Quantity | Value |
|---|---|
| Overworld rooms | 88 (inside a 12x9 grid of 108 cells; the rest is sea, cliff and void) |
| Cave rooms | 104 in 10 caves (8, 9, 9, 10, 10, 11, 11, 12, 10, 14) |
| Rooms in total | 192 |
| Pockets (secret closets, shops, key alcoves; not counted as rooms) | 33 |
| Graph size | 225 nodes, 259 edges, 128 gated edges |
| Tools | 10 (2 existing, 8 new) on top of the base kit hook, flare, ward |
| Wick cores | 17 (start 3 hearts, maximum 20 = the 20-heart cap) |
| Small keys / big keys / lantern fragments | 22 / 10 / 9 |
| Shops / caches / pot bags | 6 / 16 / 2 |
| Enemies placed | 213 in the overworld, 223 in the caves, plus 10 minibosses and 10 bosses |
| Rooms reachable with the base kit at the start | 38 overworld rooms and 6 rooms of C1 |
| Valid orders of C1 to C9 | 26 (see section 5.5) |

---

## 1. Design rules

### 1.1 How a room is described

| Thing | Rule |
|---|---|
| Overworld room id | `ow_<x>_<y>`. x grows east, y grows south. The room sits at world position `(x*1920, y*960)`. The existing ids and cells do not move. The overworld uses x 0..11 and y 0..8. |
| Cave room id | `cave_<N>_<K>`. N = cave 1..10, K = room number inside the cave (1 = entrance room). The legacy id `cave_1` is room 1 of C1 (it stays; there is no `cave_1_1`). Cave ids start with `cave`, so the music rule of `state.md` (`cave*` plays the cave track) still holds. |
| Cave grid | Caves live in an underground band so that `World._by_grid` stays valid. A cave room with local cell `(lx, ly)` has the global grid cell `(8*(N-1) + lx, 12 + ly)`. The overworld never goes below row 8, caves are at most 5 cells wide, so nothing overlaps. |
| Pocket id | `<room id>#<tag>`, for example `ow_2_0#cache`. A pocket is a one-screen interior (secret closet, shop, key alcove, hut) entered through a door or opened in place. It is not a room for the room counts. Its scene file name replaces `#` with `__`. |
| Region | One of six overworld regions (section 3.2) or `cave_<N>`. |
| Exits | A room lists the sides `N E S W` where the wall ring has a 192 px gap (2 tiles). The gap rules of `code-contract.md` section 11 apply. |
| Link kinds | `step`: two rooms on adjacent grid cells; the camera slides (0.45 s). `door`: a `RoomDoor` with a fade (cave mouths, pockets). |

Every border between two adjacent cells is in exactly one of these states:

| State | Wall ring | Map mark | Meaning |
|---|---|---|---|
| open | gap on both sides | `---` or `\|` | free passage |
| gated | gap on both sides, the gate prop stands in the gap or in the 3-tile corridor in front of it | a letter, for example `-c-` | passage needs a capability (section 1.3) |
| one-way | gap on the upper side only, a ledge drop (the lower room's `exits` omit that side) | `v` | passage in one direction (needs a small `World` change, section 2.3) |
| blocked | no gap (natural barrier: cliff, water, hedge wall, ruin wall) | ` # ` | no passage |
| void | no neighbouring room (sea, map edge) | blank | no passage |

### 1.2 Gate letters on the maps

| Letter | Gate |
|---|---|
| `c` `s` `r` `m` `j` `h` `b` `l` `t` | item gate: cinder wick, sling, raft, mitts, jar, chime, boots, reel line, moth |
| `B` | bomb wall (pitch pot) |
| `C` | cut bush (hook) |
| `F` | brazier gate (hook) |
| `K` | key gate (small key of the scope) |
| `X` | boss gate (big key, or nine fragments) |
| `v` | one-way |
| `?` | hidden |

### 1.3 Gate types (the vocabulary)

| Type | Meaning | Capability that opens it | Visual cue (no text) | World prop |
|---|---|---|---|---|
| `item` | A prop that only one tool clears. The prop says which tool (table in section 2.3). | the tool named in `needs` | the prop itself: thorn hedge, eye on a portcullis, mooring post, heavy stone, pit, anchor ring, resonance stone, grate | new props (section 2.3) |
| `key` | A locked door. | one small key of the scope (consumed) | brass keyhole door | existing `LockedDoor`, plus a key scope |
| `bomb` | A cracked wall or brittle rocks. | `pitch_pot` | cracked stone pattern, dust | existing `CrackedWall` |
| `cut` | A screen of bushes, reeds, moss or vines. | `hook` (the swing cuts it) | leaf cluster | existing `Bush` |
| `brazier` | A gate that opens when its braziers are lit. | `hook` (the swing lights them) | unlit embers that pulse | existing `Brazier` and `Gate` |
| `boss` | A boss door. | the big key of the cave; the mouth of C10 needs the nine lantern fragments | large door with a lantern-shaped lock (sockets for the fragments at C10) | new `BossDoor` |
| `oneway` | A ledge drop, or a shortcut door that opens from one side. | none; the way back must exist with what the player holds anyway (rule R5) | a ledge edge with a shadow | new `World` support |
| `hidden` | An opening that is not visible. | the capability that reveals it: `glow_jar` (light shows seams and stairs) or `hook` (a tap on a hollow wall) | a faint seam or scuff that the named capability makes clear | new `HiddenSeam` |

Counts in this plan:

| Gate type | Overworld | Caves | Total |
|---|---|---|---|
| item | 36 | 30 | 66 |
| key | 2 | 20 | 22 |
| bomb | 8 | 3 | 11 |
| cut | 5 | 2 | 7 |
| brazier | 0 | 2 | 2 |
| boss | 1 | 10 | 11 |
| oneway | 2 | 0 | 2 |
| hidden | 4 | 3 | 7 |
| **all** | 58 | 70 | 128 |

The item row includes the four ward puzzles (item gates that need `ward`, decision 8 of `docs/decisions.md`). The graph checker reports 128 gated edges (`python3 tools/check_world_graph.py --stats`).

### 1.4 The capability rule and the other hard rules

**R1. Every gate names the capability that opens it.** In `world-graph.json` every gated edge has a
non-empty `needs` list (a key gate names a key scope, a one-way gate names nothing and must pass
R5). The checker rejects a gate without a capability.

**R2. No circular gates.** The source of each capability is reachable while holding only
capabilities of earlier unlock rounds (section 5.2). The checker proves it.

**R3. A cave's tool lies inside the cave, before the gates that need it, and the cave's boss is
hurt by it.** So the tool matters, and a player who walks in without it still finds a fair first
half.

**R4. Small keys are scoped.** A key opens doors of its own scope only (`ow`, `c1` .. `c10`). In
every scope the number of keys equals the number of doors, and the doors are nested (a later door
is only reachable through an earlier one), or each key is reachable without any door of the scope.
So no order of spending can strand the player. The checker explores every spending order.

**R5. One-way edges are never traps.** After a one-way edge the player can walk back with the
capabilities he must hold anyway to have been at the upper side.

**R6. Only keys and pitch pots are consumed by progress.** Pots come from drops (10 % once the item
is found), bundles in caches and four shops. Brass, hearts and pots never gate anything else.

**R7. Hints are visual.** Each gate type has the fixed look of section 1.3. No sign, label or pop-up
explains anything. A gate that needs a tool is placed where the player can see it long before he
owns the tool (the Eyegate, the thorn hedge, the lake, the ravine are visible from the first visit).

**R8. Dev-world behaviour stays.** Enemies respawn on entry; collected items, opened doors, lit
braziers, broken walls and spent keys stay (flags, as in `code-contract.md` section 5). Dying
returns the player to `ow_0_0` with full health and keeps every flag.

**R9. Free exploration.** With the base kit alone the player can already walk 38 of the
88 overworld rooms (Brackwater, Tallowfen without the lake, Gravelight) and enter C1. Every
other region has a visible door that a tool opens.

**R10. The map is a graph of rooms, not a list of tasks.** Natural barriers (cliffs, water, hedges)
shape the overworld. Gates stand on region borders and inside regions; there is no invisible wall.

### 1.5 Pockets

A pocket has an edge of kind `door` from its room with the same gate vocabulary: a cracked wall
(`bomb`), a bush screen (`cut`), a thorn door (`item`), a seam (`hidden`), a locked door (`key`), a
plain door (open, for shops). Shops are open pockets that sell on a walk-up basis (items on
pedestals with a price in brass; section 6.7). The key alcove `cave_1#alcove` and the pitch pot
closet `ow_2_1#closet` are the existing dev-world pockets.

---

## 2. Capability list

### 2.1 The tools

The base kit (hook, flare, ward) is held at the start. A "tool" is a sub-item found in the world
and registered in `ItemRegistry`. Small keys, big keys and lantern fragments are also capabilities
in the graph (`bigkey:cN`, `frag:cN`), but they are not tools.

| Id | Name | Analog | Effect | Found in | Gates it opens (count) | Core change |
|---|---|---|---|---|---|---|
| `hook` | Lamp Hook | sword | Swing 110 deg, reach 120 px, damage 2; lights braziers, cuts bushes. (Existing, dev plan section 4.) | start | cut 7, hidden 1, brazier 2 | existing |
| `flare` | Charge Flare | sword beam | Hold 0.8 s, 360 deg sweep, reach 140 px, damage 4. (Existing.) | start | item 2 | existing |
| `ward` | Ward | shield | Hold to block projectiles in the front 120 deg. (Existing.) Also opens four optional ward puzzles (decision 8). | start | item 4 | existing |
| `tether_moth` | Tether Moth | boomerang | Flies 420 px, stuns enemies, carries pickups it touches back to Tamsin. | ow_0_1 (pedestal) | item 1 | none |
| `pitch_pot` | Pitch Pot | bomb | Placed pot explodes after 1.6 s; opens cracked walls and brittle rocks. | ow_2_1#closet (locked door) | bomb 11 | none |
| `cinder_wick` | Cinder Wick | candle | Lights a small flame one tile ahead that burns for 3 s; burns thorns and webs, lights far braziers. | C1 | item 5 | props only |
| `tallow_sling` | Tallow Sling | bow | Fires a tallow slug in a straight line; hits eye switches and fliers from range. Limited ammo: 12 at the start, 30 at most; a slug bundle adds 6 (decision 9). Pot bags do not change it. One slug on screen. | C2 | item 6 | props only, plus an ammo count in `GameState` (F5) |
| `reed_raft` | Reed Raft | raft | Used at a mooring post: Tamsin rides a raft over open water to the next mooring. | C3 | item 26 | NEW CORE |
| `heft_mitts` | Heft Mitts | power glove | Lifts and throws small rocks and pots; pushes or lifts heavy stones that the hook cannot move. | C4 | item 6 | NEW CORE (small) |
| `glow_jar` | Glow Jar | lens / candle | Throws a jar that glows with radius 520 px for 6 s; reveals hidden seams, ghost walls and sealed stairs. | C5 | hidden 6 | props only |
| `lantern_chime` | Lantern Chime | flute | Rings a chime: wakes resonance stones; held longer, it warps Tamsin to any rekindled cave mouth. | C6 | item 4 | NEW CORE (UI) |
| `skitter_boots` | Skitter Boots | jump feather | A short leap of up to 2 tiles in the facing direction; clears pits, ravines and low rails. | C7 | item 7 | NEW CORE |
| `reel_line` | Reel Line | hookshot | The hook flies out on a line to an anchor ring and pulls Tamsin across; also pulls small pickups. | C8 | item 5 | NEW CORE (small) |

Notes:

- The Wickwarden voice: wick, lamp, wax, moth, tallow, hush. Names avoid any classic item name.
- The charge flare opens two "wax seal" pockets (`flare` is a base capability, so they are early
  optional secrets). The ward is also a defence tool; four optional ward-plate caches need it (decision 8; open question 9).
- Gate counts count edges that name the tool in `needs`. Boss doors and key doors are separate.
- Item and gate counts are produced from `world-graph.json`; they do not need updating by hand.

### 2.2 Props used by item and hidden gates

| Capability | Gate type | Props used in the plan |
|---|---|---|
| `cinder_wick` | item | thorn hedge, thorn wall, thorn-sealed door |
| `flare` | item | wax seal |
| `glow_jar` | hidden | hidden seam, hidden stairs, sealed seam |
| `heft_mitts` | item | heavy boulder, heavy door, heavy stone, heavy stones |
| `hook` | hidden | hook-tap wall |
| `lantern_chime` | item | resonance door, resonance stone, resonance vault |
| `reed_raft` | item | flooded passage, mooring and water |
| `reel_line` | item | anchor ring, anchor ring pocket |
| `skitter_boots` | item | pit, ravine leap |
| `tallow_sling` | item | eye switch, eye-switch cell, eye-switch portcullis |
| `tether_moth` | item | grated alcove |

### 2.3 Fit to the item API, and what needs new core systems

All ten tools are an `ItemBase` subclass registered in `ItemRegistry` with a scene
`res://scenes/items/<id>.tscn`, as in `code-contract.md` section 9. `Player` stays generic. The
active item is chosen with `cycle_item` (open question 7: ten items need a better picker).

| Tool | Core change | Implementation note |
|---|---|---|
| `tether_moth` | none | Existing `ItemBase`. Grated alcoves need a new `Grate` prop; the moth's carrier `PickupCollector` already fetches the pickup. |
| `pitch_pot` | none | Existing `ItemBase` and `CrackedWall` (the brittle rocks reuse it with a rock look). |
| `cinder_wick` | props only | `ItemBase` that spawns a short-lived fire `Hitbox` (`kind = &"fire"`, a new kind string). New prop `Burnable` (group `burnable`, method `on_fire(pos)`) for thorn hedges, walls and webs. One flame at a time. |
| `tallow_sling` | props only | `ItemBase` with a moving `Area2D` slug (like the tether moth). New prop `EyeSwitch` that reacts to `kind = &"sling"`. Limited ammo: start 12, max 30, a slug bundle adds 6 (decision 9); one slug at a time. |
| `reed_raft` | NEW CORE | Needs the player external-motion mode (below) and two props: `Mooring` (a post on the shore with a target mooring) and a water lane. The water blocks walking as before; only the raft crosses. |
| `heft_mitts` | NEW CORE (small) | Needs a carry state on `Player` (speed, no hook while carrying) and a `Liftable` / `HeavyStone` prop. Throw = launch with a `Hitbox` on landing. |
| `glow_jar` | props only | `ItemBase` that throws a jar and adds a `PointLight2D` (radius 520 px, 6 s). New prop `HiddenSeam` (group `revealable`, `reveal()`); one jar at a time. |
| `lantern_chime` | NEW CORE (UI) | A tap rings the chime (group `resonant`, `on_chime()`). A hold opens a small warp picker (new UI) over `GameState` flags `mouth_cN` and calls `World.warp_to`. |
| `skitter_boots` | NEW CORE | Needs the external-motion mode (a 2-tile arc, hurtbox off in the air) and a `PitZone` prop (fall = 2 half-hearts and respawn at the room entry). |
| `reel_line` | NEW CORE (small) | Needs the external-motion mode to pull the player to an `AnchorRing` prop; the line is a `Hitbox` that also pulls small pickups. |

New systems the world needs, in the order a work package would build them:

| System | Needed by | Scope |
|---|---|---|
| Scoped small keys: `GameState.keys` becomes a count per scope, key pickups and `LockedDoor` get a `scope`, the HUD shows the keys of the current scope | all key doors | small |
| Player external-motion mode (controls locked, the player moved along a path with the body shape off) | raft, boots, reel line | medium |
| Props: `Burnable`, `EyeSwitch`, `Mooring`, `PitZone`, `AnchorRing`, `Liftable`/`HeavyStone`, `ResonanceStone`, `HiddenSeam`, `Grate`, `BossDoor`, `ShopItem` | the gates of section 1.3 | many, small, independent |
| One-way room edges: `World._neighbor` today needs a mirrored exit; a ledge drop has a gap on the upper side only and a landing spawn | `oneway` gates | small |
| Room data and streaming: `World.ROOM_PATHS` is a constant that loads every room scene at start; 192 rooms need a data table (generated from `world-graph.json`) and loading of the current room and its neighbours | all | medium |
| Minimap generalisation: `Hud.room_cell` parses `ow_<x>_<y>` for a 3x2 map; it needs a 12x9 overworld map and a small cave map | HUD | small |
| Boss doors and fragments: flags `bigkey_cN`, `frag_cN`, a `BossDoor` that reads them, a socket display at the Ninth Door | caves, C10 | small |
| Chime warp picker (list of rekindled cave mouths) | `lantern_chime` | small UI |
| Saving | the whole game (open question 8) | not in this plan |

---

## 3. Overworld map

### 3.1 The map

One cell is one room. `[Xm]`: X is the region letter, m the marker.

```
      0      1      2      3      4      5      6      7      8      9      10     11
  0  [BS]---[B ]---[BW]-c-[T ]---[T ]---[T ]---[T$]---[T ] # [A+]---[A+]---[A ]
      |      |      |      |      #      |      #      |      |      |      #
  1  [B ]---[B1]---[B+] # [T ]---[T+]---[T2]---[T ]---[T ]-s-[A ]---[A ]---[A+]---[A ]
      #      |             |      |      #      r      |      #      |      |      |
  2  [B9]---[B$]          [T+]---[T ]---[T ]-r-[F~]-r-[T+] # [A ]---[A4]---[A7]---[AW]
      #      C             |      v      r      r      r             |      |
  3  [F ]---[F ]          [TW] # [F ]-r-[F~]-r-[F5]-r-[FW]          [A ]---[A$]
      |      |                    |      r      r      r             m      |
  4  [F ]---[F ]---[F ]          [F ]-r-[F~]-r-[F~]-r-[F~]-r-[G ]---[G ] # [A ]
      #      |      |             |      r      r             |      |      l
  5  [F ]---[F+]---[F ]---[F3]---[F ]-r-[F+]-r-[F$]          [G ]---[G ] # [H ] # [H ]
             |      |             v      r      r             |      b      |      |
  6         [F ]---[F ]          [G ]---[G ]---[G6]---[G ]---[G ]-b-[H ]---[H ]---[HW]
                    |             |      #             |      #      |      |      #
  7                [F ]-C-[G ]---[G ]---[G$]          [G ] # [H ]---[H8]---[H$]---[H+]
                                  |      |                    |      |      |
  8                              [GW]---[G ]                 [H+]---[H ]---[HX]
```

Regions: `B` Brackwater Ford, `T` Thornwood, `A` Cinderflats (the ashen east), `F` Tallowfen and
Mirrormere (marsh and the central lake), `G` Gravelight Heights, `H` Hushmarch.

Markers (one per room; the first that applies): `S` start room; `1`-`9` the mouth of cave C1-C9;
`X` the mouth of C10, the Ninth Door; `$` a shop pocket; `W` a wick core pocket; `+` another pocket
(cache, bag, key, hut); `~` a lake room; blank otherwise.

Connectors: `---` and `|` open; ` # ` a natural barrier (cliff, water, hedge); a letter is a gate
(section 1.2). `v` is a one-way drop. Rooms next to blank space touch the sea or the map edge.

Landmarks: the start is the village edge in the north-west corner (`ow_0_0`). The **Eyegate** (`ow_7_1`)
is a stone portcullis that is visible from the first Thornwood visit. The **lake** is the big
water in the middle; all moorings stand on its shores. The **Ravine** between Gravelight and
Hushmarch is visible from the Ravine Edge. The **Ninth Door** (`ow_10_8`) is a giant sealed door at
the end of the south-east shore.

### 3.2 Regions

| Region | Letter | Rooms | Theme | Cave mouths | Main enemies |
|---|---|---|---|---|---|
| Brackwater Ford | B | 8 | Meadows, ponds and the start village. Easy, bright, open. | C1, C9 | Skitterwick, Tallow blob, Spitcap, Duskmoth |
| Thornwood | T | 15 | Briar forest, hedgerows, a stream and root bridges. Thorns hide the good paths. | C2 | Spitcap, Skitterwick, NEW:bramble_snapper, Duskmoth |
| Cinderflats | A | 14 | Burnt plains, slag roads and cold furnaces. Heat shimmer, ash, glass. | C4, C7 | NEW:cinder_wisp, Hollow, Skitterwick, Duskmoth |
| Tallowfen and Mirrormere | F | 24 | Marsh, boardwalks, rusted wax works and the great central lake. | C3, C5 | NEW:fen_leech, Duskmoth, Tallow blob, Hollow |
| Gravelight Heights | G | 15 | Stone terraces, carved eyes, quarries and sea cliffs. | C6 | Hollow, NEW:watcher_eye, Skitterwick, Spitcap |
| Hushmarch | H | 12 | The dead shore. Wrecks, salt and rusted lanterns. The Hush is thickest here. | C8, C10 | NEW:husk_hound, NEW:brine_crab, Hollow, Duskmoth |

Themes in short: Brackwater is warm and easy (the dev world). Thornwood hides its good paths behind
thorns. Cinderflats is open ground with long sight lines and fire creatures. Tallowfen is slow
ground, boardwalks and a lake that asks for a raft. Gravelight is stairs, statues and eyes that
watch. Hushmarch is the Hush's shore: fast hounds and armoured crabs.

### 3.3 Region borders and their gates

| Border | Link | Gate | Opens with | Prop |
|---|---|---|---|---|
| B - T | `ow_2_0` / `ow_3_0` | item | cinder_wick | thorn hedge |
| B - F | `ow_1_2` / `ow_1_3` | cut | hook | reed wall |
| T - A | `ow_7_1` / `ow_8_1` | item | tallow_sling | eye-switch portcullis |
| T - F | `ow_4_2` / `ow_4_3` | oneway | - | cliff ledge drop |
| A - G | `ow_9_3` / `ow_9_4` | item | heft_mitts | heavy stones |
| A - H | `ow_10_4` / `ow_10_5` | item | reel_line | anchor ring |
| F - G | `ow_4_5` / `ow_4_6` | oneway | - | cliff drop |
| F - G | `ow_2_7` / `ow_3_7` | cut | hook | rush wall |
| G - H | `ow_9_5` / `ow_9_6` | item | skitter_boots | ravine leap |
| G - H | `ow_8_6` / `ow_9_6` | item | skitter_boots | ravine leap |
| Lake (Mirrormere) - all shores | 22 links between the lake rooms and their shores | item | reed_raft | mooring posts and open water |

Reading the table: Brackwater opens to Tallowfen with a cut, and Tallowfen opens to Gravelight with
a cut, so three regions are open from the start. Thornwood needs the cinder wick (or the raft
around it, a sequence break in section 5.4). Cinderflats needs the sling at the Eyegate. Hushmarch
needs the skitter boots at the Ravine. The reel line is a second, later door from Cinderflats into
Hushmarch. Gravelight to Cinderflats needs the heft mitts. The two cliff drops are one-way.

### 3.4 Natural barriers

Blocked borders (land next to land with no gap), by reason: pond edge and cliff around the dev
world; hedge walls and a root wall in Thornwood; cliffs and a ravine between Thornwood and
Cinderflats; cliffs in Cinderflats; a peat bog in Tallowfen; cliffs in Gravelight; cliffs and a ravine
between Gravelight and Hushmarch; a salt pan and a wreck wall in Hushmarch. They are the `#` marks on the map and the missing edges in the
graph.

### 3.5 Changes to the existing rooms

The six overworld rooms keep their ids, cells and content. Only exits are added, and `cave_1`
moves into the underground band. No alias table is needed.

| Existing room | Exits now | Exits in the plan | Change |
|---|---|---|---|
| `ow_0_0` | E S | E S | none |
| `ow_1_0` | E S W | E S W | none |
| `ow_2_0` | S W | E S W | add exit E (east wall, rows 4-5; thorn hedge prop in the gap) |
| `ow_0_1` | N E | N E | none |
| `ow_1_1` | N E W | N E S W | add exit S (south wall, tiles 9-10; no gate prop here, the reed wall is on Ford Road) |
| `ow_2_1` | N W | N W | none |
| `cave_1` | - | E W | add exit E, W; grid (0,3) -> (1,13); the two braziers may move one tile off rows 4-5 |

Details for the scene work package (`code-contract.md` section 15 rules apply: three free tiles in
front of every gap, sealed spots stay closed):

- `ow_2_0` gets an east gap on rows 4-5 with the **thorn hedge** in the gap. The cache with the
  wick core (cracked wall `ow_2_0_cache`) is untouched.
- `ow_1_1` gets a south gap on tiles 9-10. The cave mouth stays at `(1392, 240)`.
- `cave_1` gets west and east gaps on rows 4-5. The braziers `cave_west` and `cave_east`, the gate
  `cave_gate` and the key `cave_key` stay; the key is the overworld key (scope `ow`) and opens
  `ow_2_1_pitch`. `cave_1.grid` changes from (0,3) to (1,13); `tests/test_world.gd` (which asserts
  seven rooms and world position `(0, 2880)`) must follow.
- `ow_0_0`, `ow_1_0`, `ow_0_1`, `ow_2_1` do not change.

### 3.6 Every overworld room

Columns: `Exits` are the wall gaps; `Gates` lists the gated links at the room (direction, gate type,
capability, prop). `NEW:<name>` is a monster from the monster document (list in Appendix A).

| Id | Region | Name | Terrain | Enemies | Exits | Gates | Contents |
|---|---|---|---|---|---|---|---|
| `ow_0_0` | B | Brackwater Edge | village edge, huts, sign post | 2 Spitcap | E S | - | START. Huts, sign post. |
| `ow_1_0` | B | Wickfield | open field, rocks, bushes | 3 Skitterwick | E S W | - | - |
| `ow_2_0` | B | Ruin of Ode | ruin walls, cracked wall | 2 Hollow | E S W | E item (cinder_wick): thorn hedge; door bomb (pitch_pot): cracked wall -> ow_2_0#cache | Cracked wall to the wick-core cache (pocket). East exit is the thorn hedge. |
| `ow_0_1` | B | Reedpond | pond, reeds | 4 Duskmoth | N E | - | Tether moth on a pedestal. |
| `ow_1_1` | B | Crossroads | crossroads, rocks, trees | 2 Tallow blob, 1 Spitcap | N E S W | - | Cave mouth C1. South exit to Ford Road. |
| `ow_2_1` | B | Dead End | walled grove | none | N W | door key (ow): locked door -> ow_2_1#closet | Locked door to the pitch pot closet (pocket). |
| `ow_0_2` | B | Lamplighter's Stump | broken lamp tower, ivy | 2 Skitterwick, 1 Tallow blob | E | door hidden (glow_jar): hidden stairs -> cave_9_1 | Hidden stairs to C9: a dark lamp stone glows under the glow jar. |
| `ow_1_2` | B | Ford Road | ford, stepping stones, lamp stall | 1 Spitcap, 2 Tallow blob | N S W | S cut (hook): reed wall | Shop S1 (Tilly's lamp stall). Reed wall to the south. |
| `ow_3_0` | T | Thorn Gate | briar archway | 2 Spitcap | E S W | W item (cinder_wick): thorn hedge | Arrival from Brackwater. The hedge gate is on the west side. |
| `ow_4_0` | T | Hedgerow | hedge rows | 2 Skitterwick, 1 NEW:bramble_snapper | E W | - | - |
| `ow_5_0` | T | Owl Clearing | clearing, stumps | 3 Duskmoth | E S W | - | - |
| `ow_6_0` | T | Standing Stones | stone ring | 2 Spitcap | E W | door bomb (pitch_pot): cracked wall -> ow_6_0#shop | Bomb wall to shop S2 (Peddler's Burrow). |
| `ow_7_0` | T | North Cliff | pine cliff | 2 Hollow | S W | - | Pitch pot bundle on a ledge. |
| `ow_3_1` | T | Thornpath | brambles, mushroom ring | 2 Tallow blob | N E S | - | - |
| `ow_4_1` | T | Fernhollow | ferns, ruined well | 3 Skitterwick | E S W | door bomb (pitch_pot): cracked wall -> ow_4_1#cache | Bomb wall to a cache (pots and brass). |
| `ow_5_1` | T | Briar Mouth | giant roots, cave mouth | 2 NEW:bramble_snapper, 1 Hollow | N E W | - | Cave mouth C2. |
| `ow_6_1` | T | Rootbridge | stream, root bridge | 2 Spitcap, 1 NEW:bramble_snapper | E S W | S item (reed_raft): mooring and water | Mooring post to the lake (south). |
| `ow_7_1` | T | Eyegate | stone portcullis, eye switch | 1 Hollow | N E S W | E item (tallow_sling): eye-switch portcullis | Portcullis east to Cinderflats, opened by the eye switch. |
| `ow_3_2` | T | Sunken Lane | sunken lane, vines | 2 Tallow blob, 1 Skitterwick | N E S | door item (tether_moth): grated alcove -> ow_3_2#grate | Grated alcove holding a small key (overworld key). |
| `ow_4_2` | T | Drop Ledge | cliff ledge, pines | 2 Spitcap | N E S W | S one-way down: cliff ledge drop | One-way drop south to Reed Shore North. |
| `ow_5_2` | T | Mossy Landing | moss, dock posts | 2 Duskmoth | E S W | E item (reed_raft): mooring and water; S item (reed_raft): mooring and water | Mooring post to the lake. |
| `ow_7_2` | T | Fallen Mast | shore wreck | 1 Hollow, 1 NEW:bramble_snapper | N S W | W item (reed_raft): mooring and water; S item (reed_raft): mooring and water; door bomb (pitch_pot): cracked wall -> ow_7_2#bag | Bomb wall to pot bag P1. Moorings. |
| `ow_3_3` | T | Hermit's Rise | small hill, hut | 1 NEW:bramble_snapper | N | door item (cinder_wick): thorn-sealed door -> ow_3_3#hut | Hut sealed by thorns, holds a wick core. |
| `ow_8_0` | A | Ash Rim | ash dunes | 2 NEW:cinder_wisp | E S | door hidden (hook): hook-tap wall -> ow_8_0#cache | Hook-tap wall to a brass cache. |
| `ow_9_0` | A | Smoke Terrace | vent terrace | 2 Hollow | E S W | door item (flare): wax seal -> ow_9_0#cache | Wax-sealed vent (charge flare) to a brass cache. |
| `ow_10_0` | A | Cinder Crown | crater rim | 1 Hollow, 2 NEW:cinder_wisp | W | - | - |
| `ow_8_1` | A | Portcullis Court | gate court | 2 Skitterwick, 1 Hollow | N E W | W item (tallow_sling): eye-switch portcullis | Arrival from Eyegate. |
| `ow_9_1` | A | Slag Road | slag road | 3 NEW:cinder_wisp | N E S W | - | - |
| `ow_10_1` | A | Kiln Fields | burnt fields | 2 Hollow | E S W | door key (ow): locked door -> ow_10_1#hut | Locked kiln hut (overworld key) with pot bag P2. |
| `ow_11_1` | A | Ember Shore | east cliff | 2 Duskmoth, 1 NEW:cinder_wisp | S W | - | - |
| `ow_8_2` | A | Ash Bridge | burnt bridge, ravine | 2 Skitterwick | E | - | - |
| `ow_9_2` | A | Sleeping Furnace | cold furnace, cave mouth | 1 Hollow, 2 NEW:cinder_wisp | N E S W | - | Cave mouth C4. |
| `ow_10_2` | A | Glassed Court | fused-glass court | 2 Hollow | N E S W | door hidden (glow_jar): hidden stairs -> cave_7_1 | Hidden stairs to C7: sealed stairs show under the glow jar. |
| `ow_11_2` | A | Slag Cache | slag pits, dead end | 3 NEW:cinder_wisp | N W | door bomb (pitch_pot): cracked wall -> ow_11_2#cache | Bomb wall to a wick core. |
| `ow_9_3` | A | Heavy Pass | boulder pass | 2 Skitterwick | N E S | S item (heft_mitts): heavy stones | Heavy stones to the south (Gravelight). |
| `ow_10_3` | A | Cooling Pools | steaming pools | 2 Tallow blob, 1 NEW:cinder_wisp | N S W | - | Shop S3 (Ashwife's cart). |
| `ow_10_4` | A | Anchor Ledge | cliff, iron ring | 1 Hollow | N S | S item (reel_line): anchor ring | Anchor ring over the shore to Hushmarch. |
| `ow_6_2` | F | North Reach | open water, reeds (lake) | 2 Duskmoth | N E S W | N item (reed_raft): mooring and water; W item (reed_raft): mooring and water; E item (reed_raft): mooring and water; S item (reed_raft): mooring and water | Moorings. |
| `ow_0_3` | F | Cattail Corner | cattails | 2 Duskmoth, 1 Tallow blob | E S | - | - |
| `ow_1_3` | F | Reed Gate | reed wall, boardwalk start | 2 Spitcap, 1 NEW:fen_leech | N S W | N cut (hook): reed wall | Arrival from Ford Road (reed wall, cut). |
| `ow_4_3` | F | Reed Shore North | shore, reeds | 2 Duskmoth | E S | N one-way (arrival): cliff ledge drop; E item (reed_raft): mooring and water | Landing of the Drop Ledge. Mooring. |
| `ow_5_3` | F | Whispering Shallows | shallows (lake) | 1 NEW:fen_leech, 2 Duskmoth | N E S W | N item (reed_raft): mooring and water; W item (reed_raft): mooring and water; E item (reed_raft): mooring and water; S item (reed_raft): mooring and water | - |
| `ow_6_3` | F | Lantern Isle | island, standing lamp (lake) | 2 NEW:fen_leech | N E S W | N item (reed_raft): mooring and water; W item (reed_raft): mooring and water; E item (reed_raft): mooring and water; S item (reed_raft): mooring and water | Cave mouth C5. |
| `ow_7_3` | F | Stone Islet | islet, reeds (lake) | 1 NEW:fen_leech | N S W | N item (reed_raft): mooring and water; W item (reed_raft): mooring and water; S item (reed_raft): mooring and water; door cut (hook): reed cluster -> ow_7_3#grotto | Reed grotto with a wick core. |
| `ow_0_4` | F | Mudflat | mudflat | 3 Tallow blob | N E | - | - |
| `ow_1_4` | F | Boardwalk | boardwalks | 2 NEW:fen_leech, 1 Duskmoth | N E S W | - | - |
| `ow_2_4` | F | Drowned Orchard | flooded orchard | 3 Skitterwick | S W | - | - |
| `ow_4_4` | F | Stranded Boat | shore, beached boat | 2 NEW:fen_leech | N E S | E item (reed_raft): mooring and water | Mooring. |
| `ow_5_4` | F | Drift Channel | channel (lake) | 2 NEW:fen_leech | N E S W | N item (reed_raft): mooring and water; W item (reed_raft): mooring and water; E item (reed_raft): mooring and water; S item (reed_raft): mooring and water | - |
| `ow_6_4` | F | Mirror Deep | deep water (lake) | 3 Duskmoth | N E S W | N item (reed_raft): mooring and water; W item (reed_raft): mooring and water; E item (reed_raft): mooring and water; S item (reed_raft): mooring and water | - |
| `ow_7_4` | F | East Landing | east pier (lake) | 1 NEW:fen_leech, 1 Duskmoth | N E W | N item (reed_raft): mooring and water; W item (reed_raft): mooring and water; E item (reed_raft): mooring and water | Mooring to Gravelight. |
| `ow_0_5` | F | Peat Hollow | peat bog | 2 Tallow blob, 1 Hollow | E | - | - |
| `ow_1_5` | F | Wickfarm | farm ruin | 2 Spitcap, 2 Duskmoth | N E S W | door cut (hook): bush cluster -> ow_1_5#cache | Cut-bush cache (brass). |
| `ow_2_5` | F | Sump Edge | brackish water, brittle rocks | 2 NEW:fen_leech | N E S W | - | - |
| `ow_3_5` | F | Sump Gate | sluice gate, cave mouth | 1 Hollow, 2 NEW:fen_leech | E W | door bomb (pitch_pot): brittle rocks -> cave_3_1 | Cave mouth C3, covered by brittle rocks (bomb wall). |
| `ow_4_5` | F | Dockside Bluff | bluff | 1 Hollow | N E S W | E item (reed_raft): mooring and water; S one-way down: cliff drop | Mooring. One-way drop south to Cliff Foot. |
| `ow_5_5` | F | South Swell | swell (lake) | 2 Duskmoth | N E S W | N item (reed_raft): mooring and water; W item (reed_raft): mooring and water; E item (reed_raft): mooring and water; S item (reed_raft): mooring and water; door cut (hook): reed cluster -> ow_5_5#cache | Cut-reed cache on a sandbar. |
| `ow_6_5` | F | Broken Lighthouse | lighthouse ruin (lake) | 1 Hollow | N S W | N item (reed_raft): mooring and water; W item (reed_raft): mooring and water; S item (reed_raft): mooring and water | Shop S6 (keeper's trade). |
| `ow_1_6` | F | Tallow Works | rusted vats | 3 Tallow blob | N E | - | - |
| `ow_2_6` | F | Candle Sheds | sheds | 2 Hollow | N S W | - | - |
| `ow_2_7` | F | Last Pier | broken pier | 2 NEW:fen_leech | N E | E cut (hook): rush wall | Rush wall east to Gravelight (cut). |
| `ow_8_4` | G | Landing Cliffs | cliffs | 2 Hollow | E S W | W item (reed_raft): mooring and water | Mooring from the lake. |
| `ow_9_4` | G | Boulder Gate | boulders | 2 NEW:watcher_eye | N S W | N item (heft_mitts): heavy stones | Heavy stones to the north (Cinderflats). |
| `ow_8_5` | G | Stair Terrace | stone stairs | 2 Skitterwick, 1 NEW:watcher_eye | N E S | - | - |
| `ow_9_5` | G | Ravine Edge | ravine rim | 1 Hollow, 1 NEW:watcher_eye | N S W | S item (skitter_boots): ravine leap | Leap south over the ravine to Hushmarch. |
| `ow_4_6` | G | Cliff Foot | cliff foot | 2 Skitterwick | E S | N one-way (arrival): cliff drop | Landing of the Dockside drop. |
| `ow_5_6` | G | Watchers' Steps | stone steps, carved eyes | 3 NEW:watcher_eye | N E W | N item (reed_raft): mooring and water | Mooring from the lake. |
| `ow_6_6` | G | Choir Steps | choir terrace, boulder | 2 Hollow, 1 NEW:watcher_eye | N E W | N item (reed_raft): mooring and water; door item (heft_mitts): heavy boulder -> cave_6_1 | Heavy boulder in front of cave mouth C6. Mooring. |
| `ow_7_6` | G | Gravelight Terrace | terrace | 2 Spitcap, 1 Hollow | E S W | - | - |
| `ow_8_6` | G | Ravine Bridge | broken bridge | 2 NEW:watcher_eye | N E W | E item (skitter_boots): ravine leap | Leap east over the ravine. |
| `ow_3_7` | G | Fen Pass | pass | 2 Skitterwick, 1 Tallow blob | E W | W cut (hook): rush wall | Rush wall to the west (Last Pier, cut). |
| `ow_4_7` | G | Quarry | quarry | 2 Hollow | N E S W | - | - |
| `ow_5_7` | G | Statuary | statue yard | 2 NEW:watcher_eye, 1 Hollow | S W | - | Shop S4 (stone mason). |
| `ow_7_7` | G | Windcut | wind cut, cliffs | 2 Spitcap, 1 Hollow | N | - | - |
| `ow_4_8` | G | South Cliff | sea cliff | 2 Hollow | N E | door bomb (pitch_pot): cracked wall -> ow_4_8#cache | Bomb wall to a wick core. |
| `ow_5_8` | G | Lowest Stair | stair, tide marks | 3 Skitterwick | N W | - | - |
| `ow_10_5` | H | Anchor Beach | beach, iron ring | 2 NEW:brine_crab | N S | N item (reel_line): anchor ring | Anchor landing from Anchor Ledge. |
| `ow_11_5` | H | Salt Flats | salt flats | 2 NEW:husk_hound | S | - | - |
| `ow_9_6` | H | Ravine Landing | ravine landing | 1 Hollow, 1 NEW:husk_hound | N E S W | N item (skitter_boots): ravine leap; W item (skitter_boots): ravine leap | Arrival from Gravelight (leap). |
| `ow_10_6` | H | Wreck Row | wrecks | 2 NEW:brine_crab, 1 Duskmoth | N E S W | - | - |
| `ow_11_6` | H | Tide Cache | tidal cave | 1 NEW:husk_hound | N W | door bomb (pitch_pot): cracked wall -> ow_11_6#cache | Bomb wall to a wick core. |
| `ow_8_7` | H | Cold Quay | quay | 2 NEW:husk_hound | E S | - | - |
| `ow_9_7` | H | Counting Gate | stone gate, resonance door | 2 Hollow | N E S W | door item (lantern_chime): resonance door -> cave_8_1 | Cave mouth C8 behind a resonance door. |
| `ow_10_7` | H | Pilgrim Road | road of lanterns | 2 NEW:brine_crab, 1 NEW:husk_hound | N E S W | - | Shop S5 (pilgrim's stall). |
| `ow_11_7` | H | Lantern Graveyard | rusted lanterns | 2 NEW:husk_hound, 1 Hollow | W | door hidden (glow_jar): sealed seam -> ow_11_7#cache | Sealed seam (glow jar) to a cache. |
| `ow_8_8` | H | Black Pier | pier | 3 NEW:husk_hound | N E | door item (reel_line): anchor ring pocket -> ow_8_8#cache | Anchor ring pocket with a brass cache. |
| `ow_9_8` | H | Hush Garden | garden of forgotten things | 2 Hollow, 2 NEW:husk_hound | N E W | - | - |
| `ow_10_8` | H | The Ninth Door | giant sealed door | 3 NEW:husk_hound | N W | door boss (9 fragments): sealed door (nine fragments) -> cave_10_1 | Cave mouth C10, sealed until nine fragments are held. |

### 3.7 Pockets

| Pocket | Room | Gate | Opens with | Prop | Holds |
|---|---|---|---|---|---|
| `ow_2_0#cache` | `ow_2_0` | bomb | pitch_pot | cracked wall | wick core |
| `ow_2_1#closet` | `ow_2_1` | key | key (ow) | locked door | item pitch_pot |
| `ow_1_2#shop` | `ow_1_2` | open | - | stall door | shop S1 |
| `ow_4_1#cache` | `ow_4_1` | bomb | pitch_pot | cracked wall | cache: pot bundle, 20 brass |
| `ow_6_0#shop` | `ow_6_0` | bomb | pitch_pot | cracked wall | shop S2 |
| `ow_7_2#bag` | `ow_7_2` | bomb | pitch_pot | cracked wall | pot bag |
| `ow_3_3#hut` | `ow_3_3` | item | cinder_wick | thorn-sealed door | wick core |
| `ow_3_2#grate` | `ow_3_2` | item | tether_moth | grated alcove | small key (ow) |
| `ow_8_0#cache` | `ow_8_0` | hidden | hook | hook-tap wall | cache: 40 brass |
| `ow_9_0#cache` | `ow_9_0` | item | flare | wax seal | cache: 40 brass |
| `ow_10_1#hut` | `ow_10_1` | key | key (ow) | locked door | pot bag |
| `ow_10_3#shop` | `ow_10_3` | open | - | cart | shop S3 |
| `ow_11_2#cache` | `ow_11_2` | bomb | pitch_pot | cracked wall | wick core |
| `ow_1_5#cache` | `ow_1_5` | cut | hook | bush cluster | cache: 30 brass |
| `ow_5_5#cache` | `ow_5_5` | cut | hook | reed cluster | cache: 30 brass, ember |
| `ow_7_3#grotto` | `ow_7_3` | cut | hook | reed cluster | wick core |
| `ow_6_5#shop` | `ow_6_5` | open | - | lighthouse door | shop S6 |
| `ow_5_7#shop` | `ow_5_7` | open | - | mason door | shop S4 |
| `ow_4_8#cache` | `ow_4_8` | bomb | pitch_pot | cracked wall | wick core |
| `ow_11_6#cache` | `ow_11_6` | bomb | pitch_pot | cracked wall | wick core |
| `ow_10_7#shop` | `ow_10_7` | open | - | stall door | shop S5 |
| `ow_11_7#cache` | `ow_11_7` | hidden | glow_jar | sealed seam | cache: 60 brass |
| `ow_8_8#cache` | `ow_8_8` | item | reel_line | anchor ring pocket | cache: 50 brass, pot bundle |
| `cave_1#alcove` | `cave_1` | brazier | hook | key alcove gate | small key (ow) |
| `cave_1_6#crack` | `cave_1_6` | bomb | pitch_pot | cracked wall | cache: 30 brass, ember |
| `cave_4_7#seal` | `cave_4_7` | item | flare | wax seal | cache: 30 brass, pot bundle |
| `cave_6_9#crypt` | `cave_6_9` | bomb | pitch_pot | cracked wall | wick core |
| `cave_9_2#cell` | `cave_9_2` | item | tallow_sling | eye-switch cell | cache: 80 brass |
| `cave_9_9#vault` | `cave_9_9` | item | lantern_chime | resonance vault | cache: pot bundle, 2 embers |

---

## 4. Cave list (C1 to C10)

Order is a recommendation (C1 first, C10 last). The prerequisites in section 5.5 allow
26 orders; the first cave can be C1, C3 and the middle can be played in several
orders.

| Cave | Name | Lantern | Entrance | Mouth gate | Rooms | Item | Small / big keys | Miniboss | Boss (weakness) | Reward |
|---|---|---|---|---|---|---|---|---|---|---|
| C1 | The Wick Cellar | Warmth | `ow_1_1` | open | 8 | cinder_wick | 1 / 1 | Hollow Captain | Kilnkeeper (cinder_wick) | Fragment of Warmth, wick core |
| C2 | The Briar Hollow | Growth | `ow_5_1` | open | 9 | tallow_sling | 2 / 1 | Thorn Warden | Briar Mother (tallow_sling) | Fragment of Growth, wick core |
| C3 | The Drowned Wick Works | Rain | `ow_3_5` | bomb (pitch_pot) | 9 | reed_raft | 1 / 1 | Sump Lurker | Tidewick (reed_raft) | Fragment of Rain, wick core |
| C4 | The Sleeping Foundry | Sleep | `ow_9_2` | open | 10 | heft_mitts | 2 / 1 | Lull-Mauler | Hushed Colossus (heft_mitts) | Fragment of Sleep, wick core |
| C5 | The Mirrored Archive | Memory | `ow_6_3` | open | 10 | glow_jar | 2 / 1 | Mirror Warden | Archivist (glow_jar) | Fragment of Memory, wick core |
| C6 | The Choir Vault | Song | `ow_6_6` | item (heft_mitts) | 11 | lantern_chime | 2 / 1 | Choir Warden | Dirge Choir (lantern_chime) | Fragment of Song, wick core |
| C7 | The Hall of Nerve | Courage | `ow_10_2` | hidden (glow_jar) | 11 | skitter_boots | 2 / 1 | Pale Squire | Gloam Knight (skitter_boots) | Fragment of Courage, wick core |
| C8 | The Counting House | Trade | `ow_9_7` | item (lantern_chime) | 12 | reel_line | 3 / 1 | Abacus Brute | Coinwyrm (reel_line) | Fragment of Trade, wick core |
| C9 | Corrow's Undercroft | none (Corrow's workshop) | `ow_0_2` | hidden (glow_jar) | 10 | none (uses all) | 2 / 1 | Wick Automaton | Lock Warden (pitch_pot, tallow_sling) | Corrow's Last Wick (ninth fragment), wick core |
| C10 | The Ninth Hollow | Seasons (the Ninth Lantern) | `ow_10_8` | boss (9 fragments) | 14 | none (uses all) | 3 / 1 | Corrow's Echo | The Unlit (tallow_sling, cinder_wick, reel_line) | The ending choice (no wick core) |

Cave layouts use `[RRt]`: room number `RR` and a role tag `t` (E entrance, m miniboss, I item, k
small key, b big key, a antechamber, B boss, s secret room). Connectors follow section 1.2. The
grid is the local cave grid; a cave drawing may be mirrored in the game world.

C9 is not a lantern: it is Corrow's hidden workshop under the lamp tower, the cave of the letters
and murals of the story. The nine lanterns of the story are C1 to C8 and C10 (the Ninth Hollow
holds the last lantern, the lantern of the seasons). Open question 1 asks whether the user wants
this reading.

### C1. The Wick Cellar

- **Lantern and theme:** Warmth. Kiln cellar under the old lampworks. Dark, dry, braziers.
- **Entrance:** `ow_1_1` (Crossroads); mouth gate: open; prop: cave mouth.
- **Rooms:** 8 (`cave_1` .. `cave_1_8`). Global grid origin of the cave: (0, 12).
- **Item:** `cinder_wick` (Cinder Wick) in room 5 (`cave_1_5`).
- **Keys:** 1 small key (scope `c1`, in rooms 3) and 1 big key (room 7, `cave_1_7`).
- **Gate structure:** boss (bigkey:c1) x1; brazier (hook) x1; key x1.
- **Miniboss:** `NEW:hollow_captain`. A Hollow in a lamp-shade helm. Raised ward; hit from the side.
- **Boss:** `NEW:kilnkeeper`. A furnace-bellied Hush made of old kiln wax. Its wax armour melts under the cinder wick; then the hook finishes it. Needs: `cinder_wick`.
- **Reward:** Fragment of Warmth, wick core.
- **Order:** the entrance opens in unlock round 0 and the fragment is found in round 2. Direct prerequisite caves: none.
- **Wick cores in this cave:** 1 (1 boss core).
- **Pockets:** `cave_1#alcove`, `cave_1_6#crack`.

Layout:

```
  [03k]           [05m]---[07b]
    |               F
  [02 ]---[01E]---[04 ]-K-[06 ]-X-[08B]
```

| Room | Local | Role | Name | Enemies | Exits | Gates | Contents |
|---|---|---|---|---|---|---|---|
| `cave_1` | (1,1) | entrance | Cellar Hub | 3 Hollow | E W | door brazier (hook): key alcove gate -> cave_1#alcove | Existing room. Two unlit braziers open the gate to the key alcove. Exits west and east added. |
| `cave_1_2` | (0,1) | hall | Spent Wicks | 2 Skitterwick, 2 Duskmoth | N E | - | - |
| `cave_1_3` | (0,0) | key | Grated Store | 2 NEW:wickling | S | - | Small key (c1) behind a grate: the tether moth fetches it. |
| `cave_1_4` | (2,1) | hub | Kiln Hall | 2 Hollow, 1 Spitcap | N E W | N brazier (hook): two braziers, gate; E key (c1): locked door | Two braziers light the gate north. |
| `cave_1_5` | (2,0) | miniboss | Wax Stair | MINIBOSS: NEW:hollow_captain | E S | S brazier (hook): two braziers, gate | Miniboss. Cinder wick on a pedestal. |
| `cave_1_6` | (3,1) | hall | Kiln Row | 2 Hollow, 1 Tallow blob | E W | W key (c1): locked door; E boss (bigkey:c1): boss door; door bomb (pitch_pot): cracked wall -> cave_1_6#crack | Door west is the key door. |
| `cave_1_7` | (3,0) | bigkey | Ash Closet | 2 Skitterwick | W | - | Big key (c1). |
| `cave_1_8` | (4,1) | boss | Kilnkeeper's Floor | BOSS: NEW:kilnkeeper | W | W boss (bigkey:c1): boss door | Boss. Fragment of Warmth, wick core. |

### C2. The Briar Hollow

- **Lantern and theme:** Growth. Root cave, seed halls and a thorn canopy.
- **Entrance:** `ow_5_1` (Briar Mouth); mouth gate: open; prop: cave mouth.
- **Rooms:** 9 (`cave_2_1` .. `cave_2_9`). Global grid origin of the cave: (8, 12).
- **Item:** `tallow_sling` (Tallow Sling) in room 5 (`cave_2_5`).
- **Keys:** 2 small keys (scope `c2`, in rooms 3, 6) and 1 big key (room 7, `cave_2_7`).
- **Gate structure:** boss (bigkey:c2) x1; item (cinder_wick) x1; item (tallow_sling) x1; key x2.
- **Miniboss:** `NEW:thorn_warden`. A walking thorn hedge. Stunned by the moth, then cut down with the hook.
- **Boss:** `NEW:briar_mother`. Hangs in the canopy and lowers three seed-eyes. Only the sling reaches the eyes. Needs: `tallow_sling`.
- **Reward:** Fragment of Growth, wick core.
- **Order:** the entrance opens in unlock round 1 and the fragment is found in round 4. Direct prerequisite caves: C1.
- **Wick cores in this cave:** 1 (1 boss core).

Layout:

```
          [03k]           [06k]-s-[07b]
            c               |
  [01E]---[02 ]-K-[04m]---[05I]
                            K
                          [08a]-X-[09B]
```

| Room | Local | Role | Name | Enemies | Exits | Gates | Contents |
|---|---|---|---|---|---|---|---|
| `cave_2_1` | (0,1) | entrance | Rootmouth | 2 NEW:bramble_snapper, 1 Spitcap | E | - | - |
| `cave_2_2` | (1,1) | hub | Seed Hall | 3 Skitterwick | N E W | N item (cinder_wick): thorn wall; E key (c2): locked door | - |
| `cave_2_3` | (1,0) | key | Thorn Nook | 2 NEW:bramble_snapper | S | S item (cinder_wick): thorn wall | Small key (c2), behind a thorn wall. |
| `cave_2_4` | (2,1) | miniboss | Fruiting Hall | MINIBOSS: NEW:thorn_warden | E W | W key (c2): locked door | Miniboss behind the first key door. |
| `cave_2_5` | (3,1) | item | Pale Garden | 2 Duskmoth, 1 NEW:bramble_snapper | N S W | S key (c2): locked door | Tallow sling on a pedestal. |
| `cave_2_6` | (3,0) | key | Overgrown Walk | 2 Tallow blob, 2 Spitcap | E S | E item (tallow_sling): eye-switch portcullis | Small key (c2). |
| `cave_2_7` | (4,0) | bigkey | Eye Loft | 1 NEW:bramble_snapper | W | W item (tallow_sling): eye-switch portcullis | Eye switch opens the way. Big key (c2). |
| `cave_2_8` | (3,2) | antechamber | Hanging Antechamber | 2 Skitterwick | N E | N key (c2): locked door; E boss (bigkey:c2): boss door | Key door in, boss door out. |
| `cave_2_9` | (4,2) | boss | Briar Mother's Crown | BOSS: NEW:briar_mother | W | W boss (bigkey:c2): boss door | Boss. Fragment of Growth, wick core. |

### C3. The Drowned Wick Works

- **Lantern and theme:** Rain. Flooded wax works. Pumps, sluices and black water.
- **Entrance:** `ow_3_5` (Sump Gate); mouth gate: bomb (pitch_pot); prop: brittle rocks.
- **Rooms:** 9 (`cave_3_1` .. `cave_3_9`). Global grid origin of the cave: (16, 12).
- **Item:** `reed_raft` (Reed Raft) in room 5 (`cave_3_5`).
- **Keys:** 1 small key (scope `c3`, in rooms 3) and 1 big key (room 6, `cave_3_6`).
- **Gate structure:** boss (bigkey:c3) x1; cut (hook) x1; item (reed_raft) x2; key x1.
- **Miniboss:** `NEW:sump_lurker`. A thing in the cistern. Surfaces to bite; stun it with the moth and strike.
- **Boss:** `NEW:tidewick`. A wick-serpent that circles a flooded basin. Fought from the raft; strike the glowing tail. Needs: `reed_raft`.
- **Reward:** Fragment of Rain, wick core.
- **Order:** the entrance opens in unlock round 1 and the fragment is found in round 4. Direct prerequisite caves: none.
- **Wick cores in this cave:** 2 (1 boss core, 1 hidden).

Layout:

```
          [03k]           [06b]-r-[07s]
            C               r
  [01E]---[02 ]-K-[04m]---[05I]
                            |
                          [08a]-X-[09B]
```

| Room | Local | Role | Name | Enemies | Exits | Gates | Contents |
|---|---|---|---|---|---|---|---|
| `cave_3_1` | (0,1) | entrance | Floodgate Hall | 2 NEW:fen_leech, 1 Duskmoth | E | door bomb (pitch_pot): brittle rocks -> ow_3_5 | - |
| `cave_3_2` | (1,1) | hub | Cistern | 2 Tallow blob, 2 NEW:fen_leech | N E W | N cut (hook): moss wall; E key (c3): locked door | - |
| `cave_3_3` | (1,0) | key | Mossed Pump Room | 2 NEW:wickling | S | S cut (hook): moss wall | Small key (c3), behind moss that the hook cuts. |
| `cave_3_4` | (2,1) | miniboss | Pump Hall | MINIBOSS: NEW:sump_lurker | E W | W key (c3): locked door | Miniboss behind the key door. |
| `cave_3_5` | (3,1) | item | Dry Dock | 2 Tallow blob | N S W | N item (reed_raft): flooded passage | Reed raft on a pedestal. |
| `cave_3_6` | (3,0) | bigkey | Sluice Walk | 2 NEW:fen_leech | E S | S item (reed_raft): flooded passage; E item (reed_raft): flooded passage | Flooded: the raft crosses. Big key (c3). |
| `cave_3_7` | (4,0) | secret | Drowned Gallery | 3 NEW:fen_leech | W | W item (reed_raft): flooded passage | Flooded gallery. Wick core (hidden). |
| `cave_3_8` | (3,2) | antechamber | Lock Chamber | 2 Hollow | N E | E boss (bigkey:c3): boss door | - |
| `cave_3_9` | (4,2) | boss | Tidewick Basin | BOSS: NEW:tidewick | W | W boss (bigkey:c3): boss door | Boss. Fragment of Rain, wick core. |

### C4. The Sleeping Foundry

- **Lantern and theme:** Sleep. A cold foundry where everything stopped mid-pour. Slag, anvils, silence.
- **Entrance:** `ow_9_2` (Sleeping Furnace); mouth gate: open; prop: cave mouth.
- **Rooms:** 10 (`cave_4_1` .. `cave_4_10`). Global grid origin of the cave: (24, 12).
- **Item:** `heft_mitts` (Heft Mitts) in room 5 (`cave_4_5`).
- **Keys:** 2 small keys (scope `c4`, in rooms 3, 6) and 1 big key (room 8, `cave_4_8`).
- **Gate structure:** boss (bigkey:c4) x1; item (heft_mitts) x1; item (tallow_sling) x1; key x2.
- **Miniboss:** `NEW:lull_mauler`. A slow slab-armed brute. Throw its dropped slag chunks back with the mitts, or stun and hook.
- **Boss:** `NEW:hushed_colossus`. A sleeping wax giant that wakes in phases. Lift and throw the stone shards that fall from the ceiling. Needs: `heft_mitts`.
- **Reward:** Fragment of Sleep, wick core.
- **Order:** the entrance opens in unlock round 2 and the fragment is found in round 5. Direct prerequisite caves: C2.
- **Wick cores in this cave:** 1 (1 boss core).
- **Pockets:** `cave_4_7#seal`.

Layout:

```
          [03k]           [06k]
            s               m
  [01E]---[02 ]-K-[04m]---[05I]
                            |
                  [09a]---[07 ]-K-[08b]
                    X
                  [10B]
```

| Room | Local | Role | Name | Enemies | Exits | Gates | Contents |
|---|---|---|---|---|---|---|---|
| `cave_4_1` | (0,1) | entrance | Cold Forecourt | 2 Hollow, 2 NEW:cinder_wisp | E | - | - |
| `cave_4_2` | (1,1) | hub | Slag Hall | 3 Skitterwick, 1 Hollow | N E W | N item (tallow_sling): eye switch; E key (c4): locked door | - |
| `cave_4_3` | (1,0) | key | Eyed Cell | 2 NEW:cinder_wisp | S | S item (tallow_sling): eye switch | Eye switch opens the cell. Small key (c4). |
| `cave_4_4` | (2,1) | miniboss | Banked Furnace | MINIBOSS: NEW:lull_mauler | E W | W key (c4): locked door | Miniboss behind the first key door. |
| `cave_4_5` | (3,1) | item | Anvil Row | 2 Hollow | N S W | N item (heft_mitts): heavy stone | Heft mitts on an anvil. |
| `cave_4_6` | (3,0) | key | Heavy Vault | 2 NEW:cinder_wisp | S | S item (heft_mitts): heavy stone | Heavy stone blocks the way. Small key (c4). |
| `cave_4_7` | (3,2) | hub | Quench Hall | 2 Tallow blob, 2 NEW:cinder_wisp | N E W | E key (c4): locked door; door item (flare): wax seal -> cave_4_7#seal | Wax-sealed alcove (charge flare) with a cache. |
| `cave_4_8` | (4,2) | bigkey | Bellows Loft | 2 Skitterwick | W | W key (c4): locked door | Behind the second key door. Big key (c4). |
| `cave_4_9` | (2,2) | antechamber | Sleeper's Antechamber | 2 Hollow | E S | S boss (bigkey:c4): boss door | - |
| `cave_4_10` | (2,3) | boss | Colossus' Bed | BOSS: NEW:hushed_colossus | N | N boss (bigkey:c4): boss door | Boss. Fragment of Sleep, wick core. |

### C5. The Mirrored Archive

- **Lantern and theme:** Memory. A drowned library of polished stone. Faces in every wall.
- **Entrance:** `ow_6_3` (Lantern Isle); mouth gate: open; prop: cave mouth.
- **Rooms:** 10 (`cave_5_1` .. `cave_5_10`). Global grid origin of the cave: (32, 12).
- **Item:** `glow_jar` (Glow Jar) in room 5 (`cave_5_5`).
- **Keys:** 2 small keys (scope `c5`, in rooms 3, 6) and 1 big key (room 8, `cave_5_8`).
- **Gate structure:** boss (bigkey:c5) x1; cut (hook) x1; hidden (glow_jar) x1; key x2.
- **Miniboss:** `NEW:mirror_warden`. Stands among reflections. Light the room with the jar to tell it from its copies.
- **Boss:** `NEW:archivist`. Splits into mirror copies. Only the real one casts a shadow under the glow jar. Needs: `glow_jar`.
- **Reward:** Fragment of Memory, wick core.
- **Order:** the entrance opens in unlock round 2 and the fragment is found in round 5. Direct prerequisite caves: C3.
- **Wick cores in this cave:** 1 (1 boss core).

Layout:

```
          [06k]           [03k]
            ?               C
          [05I]---[04m]-K-[02 ]---[01E]
            |
  [08b]-K-[07 ]---[09a]
                    X
                  [10B]
```

| Room | Local | Role | Name | Enemies | Exits | Gates | Contents |
|---|---|---|---|---|---|---|---|
| `cave_5_1` | (4,1) | entrance | Still Foyer | 2 NEW:mirror_shade, 1 Duskmoth | W | - | - |
| `cave_5_2` | (3,1) | hub | Hall of Faces | 2 Hollow, 1 NEW:mirror_shade | N E W | N cut (hook): dry vine screen; W key (c5): locked door | - |
| `cave_5_3` | (3,0) | key | Dust Reading Room | 2 NEW:wickling | S | S cut (hook): dry vine screen | Small key (c5), behind a cut-bush screen of dry vines. |
| `cave_5_4` | (2,1) | miniboss | Index Hall | MINIBOSS: NEW:mirror_warden | E W | E key (c5): locked door | Miniboss behind the first key door. |
| `cave_5_5` | (1,1) | item | Lantern Shelf | 2 NEW:mirror_shade | N E S | N hidden (glow_jar): hidden seam | Glow jar on a shelf. |
| `cave_5_6` | (1,0) | key | Unlit Stacks | 2 NEW:mirror_shade | S | S hidden (glow_jar): hidden seam | Reached by a hidden seam. Small key (c5). |
| `cave_5_7` | (1,2) | hub | Reflecting Hall | 3 Tallow blob | N E W | W key (c5): locked door | - |
| `cave_5_8` | (0,2) | bigkey | Vault of Names | 2 Hollow | E | E key (c5): locked door | Behind the second key door. Big key (c5). |
| `cave_5_9` | (2,2) | antechamber | Archivist's Antechamber | 2 NEW:mirror_shade | S W | S boss (bigkey:c5): boss door | - |
| `cave_5_10` | (2,3) | boss | The Last Page | BOSS: NEW:archivist | N | N boss (bigkey:c5): boss door | Boss. Fragment of Memory, wick core. |

### C6. The Choir Vault

- **Lantern and theme:** Song. A stone hall built to ring. Bells, organ pipes, resonance stones.
- **Entrance:** `ow_6_6` (Choir Steps); mouth gate: item (heft_mitts); prop: heavy boulder.
- **Rooms:** 11 (`cave_6_1` .. `cave_6_11`). Global grid origin of the cave: (40, 12).
- **Item:** `lantern_chime` (Lantern Chime) in room 5 (`cave_6_5`).
- **Keys:** 2 small keys (scope `c6`, in rooms 3, 7) and 1 big key (room 9, `cave_6_9`).
- **Gate structure:** bomb (pitch_pot) x1; boss (bigkey:c6) x1; hidden (glow_jar) x1; item (heft_mitts) x1; item (lantern_chime) x1; key x2.
- **Miniboss:** `NEW:choir_warden`. Sings a wall of sound that the ward blocks. Strike when the note ends.
- **Boss:** `NEW:dirge_choir`. Three singing heads. Answer each with the chime to stun it, then strike. Needs: `lantern_chime`.
- **Reward:** Fragment of Song, wick core.
- **Order:** the entrance opens in unlock round 3 and the fragment is found in round 6. Direct prerequisite caves: C4, C5.
- **Wick cores in this cave:** 2 (1 boss core, 1 hidden).
- **Pockets:** `cave_6_9#crypt`.

Layout:

```
          [03k]           [06 ]-?-[07k]
            B               h
  [01E]---[02 ]-K-[04m]---[05I]
                            |
                  [10a]-m-[08 ]-K-[09b]
                    X
                  [11B]
```

| Room | Local | Role | Name | Enemies | Exits | Gates | Contents |
|---|---|---|---|---|---|---|---|
| `cave_6_1` | (0,2) | entrance | Echo Steps | 2 NEW:choirling, 1 Duskmoth | E | door item (heft_mitts): heavy boulder -> ow_6_6 | - |
| `cave_6_2` | (1,2) | hub | Nave | 3 Hollow | N E W | N bomb (pitch_pot): cracked wall; E key (c6): locked door | - |
| `cave_6_3` | (1,1) | key | Cracked Loft | 2 NEW:choirling | S | S bomb (pitch_pot): cracked wall | Behind a bomb wall. Small key (c6). |
| `cave_6_4` | (2,2) | miniboss | Singing Hall | MINIBOSS: NEW:choir_warden | E W | W key (c6): locked door | Miniboss behind the first key door. |
| `cave_6_5` | (3,2) | item | Bell Room | 1 Hollow, 2 NEW:choirling | N S W | N item (lantern_chime): resonance stone | Lantern chime on a bell stand. |
| `cave_6_6` | (3,1) | hub | Resonance Hall | 2 Spitcap, 1 NEW:choirling | E S | S item (lantern_chime): resonance stone; E hidden (glow_jar): hidden seam | A resonance stone wakes to the chime. |
| `cave_6_7` | (4,1) | key | Organ Loft | 3 NEW:choirling | W | W hidden (glow_jar): hidden seam | Hidden seam (glow jar). Small key (c6). |
| `cave_6_8` | (3,3) | hub | Quiet Hall | 2 Tallow blob, 2 NEW:choirling | N E W | E key (c6): locked door; W item (heft_mitts): heavy door | - |
| `cave_6_9` | (4,3) | bigkey | Hollow Crypt | 2 Hollow | W | W key (c6): locked door; door bomb (pitch_pot): cracked wall -> cave_6_9#crypt | Behind the second key door. Big key (c6). |
| `cave_6_10` | (2,3) | antechamber | Choir Antechamber | 2 NEW:choirling | E S | E item (heft_mitts): heavy door; S boss (bigkey:c6): boss door | Heavy door (mitts) from the Quiet Hall. |
| `cave_6_11` | (2,4) | boss | Dirge Floor | BOSS: NEW:dirge_choir | N | N boss (bigkey:c6): boss door | Boss. Fragment of Song, wick core. |

### C7. The Hall of Nerve

- **Lantern and theme:** Courage. A ruined fort over black pits. Ledges, rails, drops.
- **Entrance:** `ow_10_2` (Glassed Court); mouth gate: hidden (glow_jar); prop: hidden stairs.
- **Rooms:** 11 (`cave_7_1` .. `cave_7_11`). Global grid origin of the cave: (48, 12).
- **Item:** `skitter_boots` (Skitter Boots) in room 5 (`cave_7_5`).
- **Keys:** 2 small keys (scope `c7`, in rooms 3, 6) and 1 big key (room 9, `cave_7_9`).
- **Gate structure:** boss (bigkey:c7) x1; item (skitter_boots) x2; key x2.
- **Miniboss:** `NEW:pale_squire`. A fast Hollow that lunges across pits. Stun it with the moth at the edge.
- **Boss:** `NEW:gloam_knight`. Fights on a pit-ringed floor and dives between islands. Follow with the boots. Needs: `skitter_boots`.
- **Reward:** Fragment of Courage, wick core.
- **Order:** the entrance opens in unlock round 3 and the fragment is found in round 6. Direct prerequisite caves: C2, C5.
- **Wick cores in this cave:** 1 (1 boss core).

Layout:

```
  [07s]-b-[06k]           [03k]
            b               |
          [05I]---[04m]-K-[02 ]---[01E]
            |
  [09b]-K-[08 ]---[10a]
                    X
                  [11B]
```

| Room | Local | Role | Name | Enemies | Exits | Gates | Contents |
|---|---|---|---|---|---|---|---|
| `cave_7_1` | (4,1) | entrance | Sunless Stair | 2 Hollow | W | door hidden (glow_jar): hidden stairs -> ow_10_2 | Reached by hidden stairs. |
| `cave_7_2` | (3,1) | hub | Pit Gallery | 2 Skitterwick, 2 Duskmoth | N E W | W key (c7): locked door | - |
| `cave_7_3` | (3,0) | key | Narrow Ledge | 2 Spitcap | S | - | Small key (c7) over a pit: the moth fetches it. |
| `cave_7_4` | (2,1) | miniboss | Warden Landing | MINIBOSS: NEW:pale_squire | E W | E key (c7): locked door | Miniboss behind the first key door. |
| `cave_7_5` | (1,1) | item | Boot Rack | 2 Hollow | N E S | N item (skitter_boots): pit | Skitter boots on a rack. |
| `cave_7_6` | (1,0) | key | Chasm Walk | 2 Duskmoth | S W | S item (skitter_boots): pit; W item (skitter_boots): pit | Pit leap. Small key (c7). |
| `cave_7_7` | (0,0) | secret | Bridge of Nerve | 2 Skitterwick | E | E item (skitter_boots): pit | Pit leap. Cache of brass. |
| `cave_7_8` | (1,2) | hub | Falling Hall | 3 Skitterwick | N E W | W key (c7): locked door | - |
| `cave_7_9` | (0,2) | bigkey | Cold Cell | 2 Hollow | E | E key (c7): locked door | Behind the second key door. Big key (c7). |
| `cave_7_10` | (2,2) | antechamber | Nerve Antechamber | 2 Tallow blob | S W | S boss (bigkey:c7): boss door | - |
| `cave_7_11` | (2,3) | boss | Coward's Crown | BOSS: NEW:gloam_knight | N | N boss (bigkey:c7): boss door | Boss. Fragment of Courage, wick core. |

### C8. The Counting House

- **Lantern and theme:** Trade. A bank of vaults and presses. Brass, scales, gilded rails.
- **Entrance:** `ow_9_7` (Counting Gate); mouth gate: item (lantern_chime); prop: resonance door.
- **Rooms:** 12 (`cave_8_1` .. `cave_8_12`). Global grid origin of the cave: (56, 12).
- **Item:** `reel_line` (Reel Line) in room 5 (`cave_8_5`).
- **Keys:** 3 small keys (scope `c8`, in rooms 3, 6, 9) and 1 big key (room 7, `cave_8_7`).
- **Gate structure:** boss (bigkey:c8) x1; item (reel_line) x1; item (skitter_boots) x1; item (tallow_sling) x1; key x3.
- **Miniboss:** `NEW:abacus_brute`. Swings a bead-chain. Pull its shield rail off with the reel line, then strike.
- **Boss:** `NEW:coinwyrm`. A hoard-serpent behind coin plates. The reel line pulls the plates off; then the hook. Needs: `reel_line`.
- **Reward:** Fragment of Trade, wick core.
- **Order:** the entrance opens in unlock round 4 and the fragment is found in round 7. Direct prerequisite caves: C6, C7.
- **Wick cores in this cave:** 1 (1 boss core).

Layout:

```
          [03k]           [06k]-b-[07b]
            s               l
  [01E]---[02 ]-K-[04m]---[05I]
                            |
                          [08 ]-K-[09k]
                                    |
                  [12B]-X-[11a]-K-[10 ]
```

| Room | Local | Role | Name | Enemies | Exits | Gates | Contents |
|---|---|---|---|---|---|---|---|
| `cave_8_1` | (0,2) | entrance | Tally Hall | 2 NEW:brine_crab, 1 Duskmoth | E | door item (lantern_chime): resonance door -> ow_9_7 | - |
| `cave_8_2` | (1,2) | hub | Scale Room | 3 Hollow | N E W | N item (tallow_sling): eye switch; E key (c8): locked door | - |
| `cave_8_3` | (1,1) | key | Weighing Loft | 2 NEW:wickling | S | S item (tallow_sling): eye switch | Eye switch opens the loft. Small key (c8). |
| `cave_8_4` | (2,2) | miniboss | Ledger Hall | MINIBOSS: NEW:abacus_brute | E W | W key (c8): locked door | Miniboss behind the first key door. |
| `cave_8_5` | (3,2) | item | Coin Press | 2 Hollow | N S W | N item (reel_line): anchor ring | Reel line on a press. |
| `cave_8_6` | (3,1) | key | Anchor Gallery | 2 NEW:wickling | E S | S item (reel_line): anchor ring; E item (skitter_boots): pit | Anchor ring pull over a gap. Small key (c8). |
| `cave_8_7` | (4,1) | bigkey | Gilded Walk | 2 NEW:brine_crab | W | W item (skitter_boots): pit | Pit leap from the gallery. Big key (c8). |
| `cave_8_8` | (3,3) | hub | Strongroom Hall | 2 Tallow blob, 2 NEW:brine_crab | N E | E key (c8): locked door | - |
| `cave_8_9` | (4,3) | key | Locked Till | 2 Hollow | S W | W key (c8): locked door | Behind the second key door. Small key (c8). |
| `cave_8_10` | (4,4) | hub | Counting Floor | 3 NEW:wickling | N W | W key (c8): locked door | - |
| `cave_8_11` | (3,4) | antechamber | Auditor's Gate | 2 NEW:brine_crab | E W | E key (c8): locked door; W boss (bigkey:c8): boss door | Behind the third key door. |
| `cave_8_12` | (2,4) | boss | Hoard Floor | BOSS: NEW:coinwyrm | E | E boss (bigkey:c8): boss door | Boss. Fragment of Trade, wick core. |

### C9. Corrow's Undercroft

- **Lantern and theme:** none (Corrow's workshop). The hidden workshop under the lamp tower. Letters, murals, locks. Uses every tool.
- **Entrance:** `ow_0_2` (Lamplighter's Stump); mouth gate: hidden (glow_jar); prop: hidden stairs.
- **Rooms:** 10 (`cave_9_1` .. `cave_9_10`). Global grid origin of the cave: (64, 12).
- **Item:** none; the cave uses every tool found so far.
- **Keys:** 2 small keys (scope `c9`, in rooms 3, 6) and 1 big key (room 7, `cave_9_7`).
- **Gate structure:** boss (bigkey:c9) x1; item (cinder_wick) x1; item (heft_mitts) x1; item (reed_raft) x1; item (reel_line) x1; item (skitter_boots) x1; key x2.
- **Miniboss:** `NEW:wick_automaton`. A brass lamp-tender that Corrow built. Stun it with the moth, then use the pots.
- **Boss:** `NEW:lock_warden`. A great brass lock. The sling opens its eyes and the pot breaks the plates. Needs: `pitch_pot`, `tallow_sling`.
- **Reward:** Corrow's Last Wick (ninth fragment), wick core.
- **Order:** the entrance opens in unlock round 3 and the fragment is found in round 7. Direct prerequisite caves: C8.
- **Wick cores in this cave:** 1 (1 boss core).
- **Pockets:** `cave_9_2#cell`, `cave_9_9#vault`.

Layout:

```
          [03k]           [06k]-l-[07b]
            c               b
  [01E]---[02 ]-K-[04m]-r-[05 ]
                            m
                  [09a]-K-[08 ]
                    X
                  [10B]
```

| Room | Local | Role | Name | Enemies | Exits | Gates | Contents |
|---|---|---|---|---|---|---|---|
| `cave_9_1` | (0,1) | entrance | Hidden Stair | 2 Hollow | E | door hidden (glow_jar): hidden stairs -> ow_0_2 | - |
| `cave_9_2` | (1,1) | hub | Letters Hall | 3 Hollow | N E W | N item (cinder_wick): thorn wall; E key (c9): locked door; door item (tallow_sling): eye-switch cell -> cave_9_2#cell | Murals and letters (visual story). |
| `cave_9_3` | (1,0) | key | Wax Study | 2 NEW:wickling | S | S item (cinder_wick): thorn wall | Thorn-sealed study. Small key (c9). |
| `cave_9_4` | (2,1) | miniboss | Corrow's Workbench | MINIBOSS: NEW:wick_automaton | E W | W key (c9): locked door; E item (reed_raft): flooded passage | Miniboss behind the first key door. |
| `cave_9_5` | (3,1) | hub | Flooded Cellar | 2 NEW:fen_leech, 2 Tallow blob | N S W | W item (reed_raft): flooded passage; N item (skitter_boots): pit; S item (heft_mitts): heavy stone | Flooded: the raft crosses. |
| `cave_9_6` | (3,0) | key | Pit Landing | 2 Skitterwick | E S | S item (skitter_boots): pit; E item (reel_line): anchor ring | Pit leap. Small key (c9). |
| `cave_9_7` | (4,0) | bigkey | Anchor Shaft | 2 NEW:wickling | W | W item (reel_line): anchor ring | Anchor ring pull. Big key (c9). |
| `cave_9_8` | (3,2) | hub | Heavy Door Hall | 2 Hollow, 1 NEW:wickling | N W | N item (heft_mitts): heavy stone; W key (c9): locked door | Heavy stone blocks the way. |
| `cave_9_9` | (2,2) | antechamber | Lock Antechamber | 2 Hollow | E S | E key (c9): locked door; S boss (bigkey:c9): boss door; door item (lantern_chime): resonance vault -> cave_9_9#vault | Behind the second key door. |
| `cave_9_10` | (2,3) | boss | Lock Floor | BOSS: NEW:lock_warden | N | N boss (bigkey:c9): boss door | Boss. Corrow's Last Wick, wick core. |

### C10. The Ninth Hollow

- **Lantern and theme:** Seasons (the Ninth Lantern). The deepest Underlight. Every tool, every cave theme, all of them worn down to roots and wax.
- **Entrance:** `ow_10_8` (The Ninth Door); mouth gate: boss (nine fragments); prop: sealed door (nine fragments).
- **Rooms:** 14 (`cave_10_1` .. `cave_10_14`). Global grid origin of the cave: (72, 12).
- **Item:** none; the cave uses every tool found so far.
- **Keys:** 3 small keys (scope `c10`, in rooms 3, 7, 11) and 1 big key (room 13, `cave_10_13`).
- **Gate structure:** boss (bigkey:c10) x1; hidden (glow_jar) x1; item (cinder_wick) x1; item (heft_mitts) x1; item (lantern_chime) x1; item (reed_raft) x1; item (reel_line) x1; item (skitter_boots) x1; item (tallow_sling) x1; key x3.
- **Miniboss:** `NEW:corrows_echo`. The wax shape of Corrow, fighting out of habit. Dodge, use the chime, strike.
- **Boss:** `NEW:the_unlit`. The Hush's heart at the Ninth Lantern. Phase 1: sling its eyes. Phase 2: burn its wax. Phase 3: reel the lantern loose. Then the ending choice. Needs: `tallow_sling`, `cinder_wick`, `reel_line`.
- **Reward:** The ending choice (no wick core).
- **Order:** last. The mouth opens when the fragments of C1 to C9 are held (round 8).

Layout:

```
          [03k]           [06 ]-h-[07k]
            c               ?
  [01E]---[02 ]-K-[04m]-r-[05 ]
                            m
                  [13b]   [08 ]-b-[09 ]
                    s               l
          [14B]-X-[12 ]-K-[11k]-K-[10 ]
```

| Room | Local | Role | Name | Enemies | Exits | Gates | Contents |
|---|---|---|---|---|---|---|---|
| `cave_10_1` | (0,2) | entrance | Ninth Stair | 2 NEW:husk_hound | E | door boss (9 fragments): sealed door (nine fragments) -> ow_10_8 | - |
| `cave_10_2` | (1,2) | hub | Root Hall | 2 NEW:husk_hound, 1 Hollow | N E W | N item (cinder_wick): thorn wall; E key (c10): locked door | - |
| `cave_10_3` | (1,1) | key | Wax Gardens | 2 NEW:husk_hound, 1 NEW:wickling | S | S item (cinder_wick): thorn wall | Thorn-sealed garden. Small key (c10). |
| `cave_10_4` | (2,2) | miniboss | Hollow Gate | MINIBOSS: NEW:corrows_echo | E W | W key (c10): locked door; E item (reed_raft): flooded passage | Miniboss behind the first key door. |
| `cave_10_5` | (3,2) | hub | Drowned Choir | 2 NEW:fen_leech, 2 NEW:choirling | N S W | W item (reed_raft): flooded passage; N hidden (glow_jar): hidden seam; S item (heft_mitts): heavy stone | Flooded: the raft crosses. |
| `cave_10_6` | (3,1) | hub | Mirror Walk | 3 NEW:mirror_shade | E S | S hidden (glow_jar): hidden seam; E item (lantern_chime): resonance stone | Hidden seam (glow jar). |
| `cave_10_7` | (4,1) | key | Chime Landing | 2 NEW:choirling, 1 NEW:husk_hound | W | W item (lantern_chime): resonance stone | Resonance stone (chime). Small key (c10). |
| `cave_10_8` | (3,3) | hub | Heavy Span | 2 Hollow, 1 NEW:husk_hound | N E | N item (heft_mitts): heavy stone; E item (skitter_boots): pit | Heavy stone (mitts). |
| `cave_10_9` | (4,3) | hub | Pit Rows | 3 Skitterwick, 1 NEW:husk_hound | S W | W item (skitter_boots): pit; S item (reel_line): anchor ring | Pit leap (boots). |
| `cave_10_10` | (4,4) | hub | Anchor Drop | 2 NEW:watcher_eye, 1 NEW:husk_hound | N W | N item (reel_line): anchor ring; W key (c10): locked door | Anchor ring pull (reel line). |
| `cave_10_11` | (3,4) | key | Key Vault | 2 Hollow, 2 NEW:husk_hound | E W | E key (c10): locked door; W key (c10): locked door | Behind the second key door. Small key (c10). |
| `cave_10_12` | (2,4) | hub | Eye Hall | 3 NEW:watcher_eye | N E W | E key (c10): locked door; N item (tallow_sling): eye switch; W boss (bigkey:c10): boss door | Behind the third key door. Eye switch north. |
| `cave_10_13` | (2,3) | bigkey | Bigkey Chamber | 2 NEW:husk_hound, 1 NEW:brine_crab | S | S item (tallow_sling): eye switch | Big key (c10). |
| `cave_10_14` | (1,4) | boss | The Ninth Lantern | BOSS: NEW:the_unlit | E | E boss (bigkey:c10): boss door | Final boss. Then the ending choice. |


---

## 5. Progression graph

### 5.1 The model

The world is a graph. Nodes are rooms and pockets. Edges are the links of section 1.1, with a gate
type and the capability that opens it. Collectibles (tools, keys, wick cores, shops, caches) sit on
nodes; some need a capability to take (a key behind a grate needs the moth), and everything in a
boss room needs the boss weakness tools.

A play state is the set of capabilities held and the set of key doors opened. Capabilities never
disappear. Opened doors stay open. Only small keys are consumed.

### 5.2 Unlock rounds: the topological order

Round r is the set of capabilities that can be found while holding only the capabilities of rounds
before r. It is computed by the checker (`--rounds`).

| Round | New capabilities (found while holding only earlier rounds) |
|---|---|
| 0 | hook, flare, ward (start) |
| 1 | cinder_wick, pitch_pot, tether_moth (also: bigkey:c1) |
| 2 | reed_raft, tallow_sling (also: frag:c1) |
| 3 | glow_jar, heft_mitts (also: bigkey:c2, bigkey:c3) |
| 4 | lantern_chime, skitter_boots (also: bigkey:c4, bigkey:c5, frag:c2, frag:c3) |
| 5 | reel_line (also: bigkey:c6, bigkey:c7, frag:c4, frag:c5) |
| 6 | - (also: bigkey:c8, bigkey:c9, frag:c6, frag:c7) |
| 7 | - (also: frag:c8, frag:c9) |
| 8 | - (also: bigkey:c10) |

The order of tools is therefore: moth, pot and cinder wick first (C1 holds the cinder wick, the
pot is the closet behind the alcove key), then the raft (C3, needs the pot) and the sling (C2,
needs the cinder wick), then the jar (C5, raft) and the mitts (C4, sling), then the chime (C6,
mitts and jar) and the boots (C7, sling and jar), then the reel line (C8, chime and boots). C9 needs
every tool. C10 needs nine fragments.

Where each capability lives, and its round:

| Capability | Name | Source node | Needs to collect | Round |
|---|---|---|---|---|
| `tether_moth` | Tether Moth | `ow_0_1` (Reedpond) | - | 1 |
| `pitch_pot` | Pitch Pot | `ow_2_1#closet` (closet) | - | 1 |
| `cinder_wick` | Cinder Wick | `cave_1_5` (Wax Stair) | - | 1 |
| `bigkey:c1` | Big key of The Wick Cellar | `cave_1_7` (Ash Closet) | - | 1 |
| `frag:c1` | Fragment of Warmth | `cave_1_8` (Kilnkeeper's Floor) | boss: cinder_wick | 2 |
| `tallow_sling` | Tallow Sling | `cave_2_5` (Pale Garden) | - | 2 |
| `bigkey:c2` | Big key of The Briar Hollow | `cave_2_7` (Eye Loft) | - | 3 |
| `frag:c2` | Fragment of Growth | `cave_2_9` (Briar Mother's Crown) | boss: tallow_sling | 4 |
| `reed_raft` | Reed Raft | `cave_3_5` (Dry Dock) | - | 2 |
| `bigkey:c3` | Big key of The Drowned Wick Works | `cave_3_6` (Sluice Walk) | - | 3 |
| `frag:c3` | Fragment of Rain | `cave_3_9` (Tidewick Basin) | boss: reed_raft | 4 |
| `heft_mitts` | Heft Mitts | `cave_4_5` (Anvil Row) | - | 3 |
| `bigkey:c4` | Big key of The Sleeping Foundry | `cave_4_8` (Bellows Loft) | - | 4 |
| `frag:c4` | Fragment of Sleep | `cave_4_10` (Colossus' Bed) | boss: heft_mitts | 5 |
| `glow_jar` | Glow Jar | `cave_5_5` (Lantern Shelf) | - | 3 |
| `bigkey:c5` | Big key of The Mirrored Archive | `cave_5_8` (Vault of Names) | - | 4 |
| `frag:c5` | Fragment of Memory | `cave_5_10` (The Last Page) | boss: glow_jar | 5 |
| `lantern_chime` | Lantern Chime | `cave_6_5` (Bell Room) | - | 4 |
| `bigkey:c6` | Big key of The Choir Vault | `cave_6_9` (Hollow Crypt) | - | 5 |
| `frag:c6` | Fragment of Song | `cave_6_11` (Dirge Floor) | boss: lantern_chime | 6 |
| `skitter_boots` | Skitter Boots | `cave_7_5` (Boot Rack) | - | 4 |
| `bigkey:c7` | Big key of The Hall of Nerve | `cave_7_9` (Cold Cell) | - | 5 |
| `frag:c7` | Fragment of Courage | `cave_7_11` (Coward's Crown) | boss: skitter_boots | 6 |
| `reel_line` | Reel Line | `cave_8_5` (Coin Press) | - | 5 |
| `bigkey:c8` | Big key of The Counting House | `cave_8_7` (Gilded Walk) | - | 6 |
| `frag:c8` | Fragment of Trade | `cave_8_12` (Hoard Floor) | boss: reel_line | 7 |
| `bigkey:c9` | Big key of Corrow's Undercroft | `cave_9_7` (Anchor Shaft) | - | 6 |
| `frag:c9` | Corrow's Last Wick (ninth fragment) | `cave_9_10` (Lock Floor) | boss: pitch_pot, tallow_sling | 7 |
| `bigkey:c10` | Big key of The Ninth Hollow | `cave_10_13` (Bigkey Chamber) | - | 8 |

Cave prerequisites (derived from the valid orders of section 5.5):

| Cave | Direct prerequisite caves (in every valid order) | Reason | All earlier caves (transitive) | Unlock round of the entrance | Fragment round |
|---|---|---|---|---|---|
| C1 | none | - | none | 0 | 2 |
| C2 | C1 | C1: the cinder wick burns the thorn wall in the Briar Hollow | C1 | 1 | 4 |
| C3 | none | - | none | 1 | 4 |
| C4 | C2 | C2: the sling opens the Eyegate to Cinderflats | C1, C2 | 2 | 5 |
| C5 | C3 | C3: the raft reaches Lantern Isle | C3 | 2 | 5 |
| C6 | C4, C5 | C4: the heft mitts move the boulder at the mouth; C5: the glow jar shows the hidden seam to the key | C1, C2, C3, C4, C5 | 3 | 6 |
| C7 | C2, C5 | C2: the sling opens the Eyegate to Cinderflats; C5: the glow jar shows the hidden stairs | C1, C2, C3, C5 | 3 | 6 |
| C8 | C6, C7 | C6: the chime opens the resonance door; C7: the skitter boots cross the Gravelight ravine | C1, C2, C3, C4, C5, C6, C7 | 4 | 7 |
| C9 | C8 | C8: the reel line is the last tool; the Undercroft needs every tool | C1, C2, C3, C4, C5, C6, C7, C8 | 3 | 7 |
| C10 | C1 to C9 | the Ninth Door needs nine fragments | all | 7 | - |

### 5.3 Why there is no soft-lock

A soft-lock is a reachable state from which the whole game can no longer be finished. In this
model there are only three ways to get one, and each is closed.

1. **Missing capability.** The checker computes the least fixed point: start with the base kit,
   walk everything reachable, take everything that can be taken, repeat. It must end with every
   node reached, every capability found, every pickup (including the boss rewards) collected and the
   final boss weakness (`tallow_sling`, `cinder_wick`, `reel_line`) held. Because every source is
   in an earlier round (R2), a player who has done the rounds in order never lacks anything.
2. **Spending keys on the wrong door.** Keys are scoped (R4). For each scope the checker
   searches every order in which its doors can be opened, with all capabilities from outside the
   scope assumed held. A state is dead if the scope can no longer be finished. The result is zero
   dead states in all eleven scopes. The design reason: every scope is nested, so the next door
   is the only door.
3. **Trap rooms.** Every edge is two-way except the two one-way drops. A player who stands at a
   node reached the node over edges whose needs he holds, and he still holds them, so he can walk
   back along the path. For the one-way edges the checker verifies (R5) that the lower side has a
   way back to the upper side using only the capabilities the player must hold to be at the upper
   side. In the finished state every node can walk back to the start. A boss door is a normal door;
   it does not shut behind the player.

What is not modelled, and why it is safe: **pitch pots** (spent by bomb gates) and **brass** are
consumables. Pots drop from every enemy (10 %, after the item), sit in bundles and are sold in
four shops; R6 forbids any other gate from needing them. **Death** returns to `ow_0_0` with all
flags kept; nothing is lost. **Hearts** gate nothing.

Key scopes (all doors nested except the overworld, whose two keys are each reachable without a door):

| Scope | Used in | Doors | Keys | Where the keys are | Door order |
|---|---|---|---|---|---|
| c1 | C1 | 1 | 1 | `cave_1_3` | nested: `cave_1_4`-`cave_1_6` |
| c10 | C10 | 3 | 3 | `cave_10_3`, `cave_10_7`, `cave_10_11` | nested: `cave_10_2`-`cave_10_4`, `cave_10_10`-`cave_10_11`, `cave_10_11`-`cave_10_12` |
| c2 | C2 | 2 | 2 | `cave_2_3`, `cave_2_6` | nested: `cave_2_2`-`cave_2_4`, `cave_2_5`-`cave_2_8` |
| c3 | C3 | 1 | 1 | `cave_3_3` | nested: `cave_3_2`-`cave_3_4` |
| c4 | C4 | 2 | 2 | `cave_4_3`, `cave_4_6` | nested: `cave_4_2`-`cave_4_4`, `cave_4_7`-`cave_4_8` |
| c5 | C5 | 2 | 2 | `cave_5_3`, `cave_5_6` | nested: `cave_5_2`-`cave_5_4`, `cave_5_7`-`cave_5_8` |
| c6 | C6 | 2 | 2 | `cave_6_3`, `cave_6_7` | nested: `cave_6_2`-`cave_6_4`, `cave_6_8`-`cave_6_9` |
| c7 | C7 | 2 | 2 | `cave_7_3`, `cave_7_6` | nested: `cave_7_2`-`cave_7_4`, `cave_7_8`-`cave_7_9` |
| c8 | C8 | 3 | 3 | `cave_8_3`, `cave_8_6`, `cave_8_9` | nested: `cave_8_2`-`cave_8_4`, `cave_8_8`-`cave_8_9`, `cave_8_10`-`cave_8_11` |
| c9 | C9 | 2 | 2 | `cave_9_3`, `cave_9_6` | nested: `cave_9_2`-`cave_9_4`, `cave_9_8`-`cave_9_9` |
| ow | overworld | 2 | 2 | `cave_1#alcove`, `ow_3_2#grate` | independent (each key is reachable without any door): `ow_2_1`-`ow_2_1#closet`, `ow_10_1`-`ow_10_1#hut` |

### 5.4 Sequence breaks (checked, intended or harmless)

| Break | Why it is safe |
|---|---|
| The raft before the cinder wick reaches Thornwood across the lake and bypasses the thorn hedge (`ow_3_0`, `ow_5_1` reachable). | C2 still needs the cinder wick inside (the thorn wall in the Seed Hall). Nothing in Thornwood needs the sling or later tools. |
| C3 before C1. The pot needs only the overworld key from the C1 alcove (two braziers, no fight), not C1 itself. | C3 holds the raft; the raft needs nothing from C1 to be used. |
| Gravelight and Tallowfen are open from the start (cut gates only). | The real progress there sits behind item gates (mitts, boots, chime). The open parts hold shops and secrets; the secrets need the pot, which comes from the alcove key in the first room of C1. |
| The lake gives access to Gravelight (moorings at `ow_7_4`, `ow_5_5`, `ow_6_5`). | Gravelight is already open; the lake only adds a route. |

Checked non-breaks: Cinderflats cannot be entered before the sling (the Eyegate is the only door;
the mitts route from Gravelight needs the mitts, which lie in Cinderflats). Hushmarch cannot be
entered before the boots (the reel line route needs the reel line from Hushmarch). C10 cannot be
entered before nine fragments.

### 5.5 Cave orders

The order check treats a cave as finished when its fragment is taken; the contents of a cave only
count after it is finished, except the key in the C1 alcove. 26 orders of C1 to C9 are
valid (C10 is always last). The recommended order is C1, C2, ..., C9, C10. All of them:

```
C1 C2 C3 C4 C5 C6 C7 C8 C9 C10
C1 C2 C3 C4 C5 C7 C6 C8 C9 C10
C1 C2 C3 C5 C4 C6 C7 C8 C9 C10
C1 C2 C3 C5 C4 C7 C6 C8 C9 C10
C1 C2 C3 C5 C7 C4 C6 C8 C9 C10
C1 C2 C4 C3 C5 C6 C7 C8 C9 C10
C1 C2 C4 C3 C5 C7 C6 C8 C9 C10
C1 C3 C2 C4 C5 C6 C7 C8 C9 C10
C1 C3 C2 C4 C5 C7 C6 C8 C9 C10
C1 C3 C2 C5 C4 C6 C7 C8 C9 C10
C1 C3 C2 C5 C4 C7 C6 C8 C9 C10
C1 C3 C2 C5 C7 C4 C6 C8 C9 C10
C1 C3 C5 C2 C4 C6 C7 C8 C9 C10
C1 C3 C5 C2 C4 C7 C6 C8 C9 C10
C1 C3 C5 C2 C7 C4 C6 C8 C9 C10
C3 C1 C2 C4 C5 C6 C7 C8 C9 C10
C3 C1 C2 C4 C5 C7 C6 C8 C9 C10
C3 C1 C2 C5 C4 C6 C7 C8 C9 C10
C3 C1 C2 C5 C4 C7 C6 C8 C9 C10
C3 C1 C2 C5 C7 C4 C6 C8 C9 C10
C3 C1 C5 C2 C4 C6 C7 C8 C9 C10
C3 C1 C5 C2 C4 C7 C6 C8 C9 C10
C3 C1 C5 C2 C7 C4 C6 C8 C9 C10
C3 C5 C1 C2 C4 C6 C7 C8 C9 C10
C3 C5 C1 C2 C4 C7 C6 C8 C9 C10
C3 C5 C1 C2 C7 C4 C6 C8 C9 C10
```

### 5.6 The file format of `world-graph.json`

One JSON object. Nodes, edges and pickups are one object per line so that diffs stay readable.

| Key | Type | Meaning |
|---|---|---|
| `format` | int | 1 |
| `start`, `goal` | node id | the start room `ow_0_0`; the room of the final boss (`cave_10_14`) |
| `start_hearts`, `max_hearts` | int | 3 and 20 |
| `base_capabilities` | list | `hook`, `flare`, `ward` |
| `capabilities` | object id -> `{name, kind}` | `base`, `tool`, `big_key` (`bigkey:cN`), `fragment` (`frag:cN`) |
| `nodes` | list | `{id, kind: "room" or "pocket", world: "overworld" or "cave_N", region, grid: [x,y] (rooms), name, terrain, enemies: {name: count}, contents, exits: ["n","e","s","w"], gates: [edge ids], dark? (rooms only: bool, default false; every cave room is dark except cave 9, decision 42), miniboss?, boss?: {name, design, needs}, role?, k?, local?}` |
| `edges` | list | `{id, a, b, link: "step" or "door", gate: null or one of item, key, bomb, cut, brazier, boss, oneway, hidden, needs: [capability ids], dir: "both" or "a>b", prop, key?: scope}` |
| `items` | object capability -> `{node, needs?, after_boss?}` | where every non-base capability lives |
| `pickups` | list | `{id, kind: small_key, wick_core, pot_bag, pot_bundle, cache or shop, node, scope?, needs?, after_boss?, early?, contents?, shop?}` |

Conventions:

- An edge is passable when every capability in `needs` is held. A `key` edge also needs one key of
  its scope, spent once. A `dir: "a>b"` edge is one-way. `boss` edges name `bigkey:cN`; the mouth of
  C10 names `frag:c1` .. `frag:c9`.
- A pickup with `after_boss` needs the `needs` of the boss in its room. A pickup with `needs`
  (a key behind a grate needs `tether_moth`) needs them as well.
- `early` marks the one pickup the order check allows before its cave is finished (the alcove key).
- Step links connect adjacent grid cells; the `exits` of a room equal its step links (checked).

Sample (verbatim lines from the file):

```
{"id":"ow_2_0","kind":"room","world":"overworld","region":"brackwater","grid":[2,0],"name":"Ruin of Ode","terrain":"ruin walls, cracked wall","enemies":{"Hollow":2},"contents":"Cracked wall to the wick-core cache (pocket). East exit is the thorn hedge.","gates":["e005","e123"],"exits":["e","s","w"]}
{"id":"ow_2_0#cache","kind":"pocket","world":"overworld","region":"brackwater","name":"cache","gates":["e123"]}
{"id":"e005","a":"ow_2_0","b":"ow_3_0","link":"step","gate":"item","needs":["cinder_wick"],"dir":"both","prop":"thorn hedge"}
{"id":"e151","a":"cave_1_4","b":"cave_1_6","link":"step","gate":"key","needs":[],"dir":"both","key":"c1","prop":"locked door"}
{"id":"cave_1_8","kind":"room","world":"cave_1","region":"cave_1","grid":[4,13],"name":"Kilnkeeper's Floor","role":"boss","terrain":"cave","enemies":{},"contents":"Boss. Fragment of Warmth, wick core.","k":8,"local":[4,1],"boss":{"name":"Kilnkeeper","design":"A furnace-bellied Hush made of old kiln wax. Its wax armour melts under the cinder wick; then the hook finishes it.","needs":["cinder_wick"]},"gates":["e152"],"exits":["w"]}
"cinder_wick": {"node": "cave_1_5"}
"frag:c1": {"node": "cave_1_8", "after_boss": true}
{"id":"key_c1_1","kind":"small_key","node":"cave_1_3","scope":"c1","needs":["tether_moth"]}
{"id":"wick_core_c1","kind":"wick_core","node":"cave_1_8","after_boss":true}
```

### 5.7 The checker and the solver test

`tools/check_world_graph.py` (committed with this plan, stdlib only):

```
python3 tools/check_world_graph.py                  # checks docs/world-graph.json
python3 tools/check_world_graph.py --stats --rounds --orders
```

Exit code 0 means every check passed. The checks:

1. **Structure**: unique ids; every edge, pickup and boss refers to known nodes and capabilities;
   gate vocabulary; R1 (a gate without a capability fails); fixed capabilities of bomb, cut and
   brazier gates; `exits` equal the step links; no two rooms share a grid cell; the `gates` list
   of a node equals its gated edges.
2. **Coverage**: starting from the base kit, grow capabilities and open key doors until nothing
   changes. Every node reached, every capability found, every pickup collectable, the goal and its
   boss weakness reachable; wick cores plus 3 do not exceed 20; keys equal doors in every scope.
3. **One-way edges** (R5): walk back from the lower side holding the capabilities that every route
   to the upper side needs (computed by removing one capability at a time).
4. **Return**: in the finished state every node can walk back to the start.
5. **Key scopes** (R4): all spending orders, per scope, no dead state.
6. `--rounds` prints the unlock rounds of section 5.2; `--orders` counts the valid cave orders of
   section 5.5; `--stats` prints counts.

Self-test of the checker (each mutation of the graph is rejected; produced by running the checker
on edited copies):

| Mutation of `world-graph.json` | Checker result |
|---|---|
| A small key moved behind the door it must open | FAILED: unreachable nodes (16): cave_2_8, cave_2_9, cave_10_1, cave_10_2, cave_10_3, cave_10_4, cave_10_5, cave_10_6, cave_10_7, cave_1... (+4 more) |
| The tallow sling placed behind the eye-switch gate that needs it | FAILED: unreachable nodes (104): ow_8_0, ow_9_0, ow_10_0, ow_8_1, ow_9_1, ow_10_1, ow_11_1, ow_8_2, ow_9_2, ow_10_2 (+4 more) |
| A bomb wall that names no capability | FAILED: edge e123: bomb gate names no capability (+1 more) |
| An 18th wick core (more hearts than the cap) | FAILED: more wick cores than the heart cap allows |
| The reed raft placed inside a cave whose mouth needs the raft | FAILED: unreachable nodes (94): ow_6_2, ow_5_3, ow_6_3, ow_7_3, ow_5_4, ow_6_4, ow_7_4, ow_5_5, ow_6_5, ow_10_5 (+4 more) |
| A second key door opened in parallel in the Briar Hollow (a key can be spent on the wrong door) | FAILED: key scope c2 can soft-lock; dead states: [['e161']] |
| The rush wall that lets Tamsin walk back from the Dockside drop now needs the boots | FAILED: one-way edge e087 (ow_4_5 -> ow_4_6): no way back with [] |

Tests a later work package writes (this plan only fixes what they check):

- `make world-check` runs the Python checker, and `make check` includes it. The Python checker
  owns the graph logic; there is no second solver to keep in sync.
- `tests/test_world_graph.gd` loads `docs/world-graph.json` and the real scenes and checks that
  they agree: every room node has a scene and a `ROOM_PATHS` entry and vice versa; `room_id`, `grid`
  and `exits` equal the node; every gated edge has the matching prop in the scene (for example a
  `CrackedWall` for `bomb`, a `LockedDoor` with the right scope for `key`, a `BossDoor` for `boss`);
  every pickup has its `persistent_id`; the cave mouths and pocket doors target the right rooms;
  every step link is mirrored.
- Scripted route tests per cave (like `tests/test_dev_world_route.gd`) walk the intended route of
  one cave at a time and prove that the tool opens the gate it is placed for.

### 5.8 Every gate

Each row is a gated edge of the graph. Capabilities in the last column are found at the node given
(see section 5.2 for rounds).

| Gate | Link | Type | Needs | Prop (visual cue) | Where the capability is found |
|---|---|---|---|---|---|
| e005 | `ow_2_0` <-> `ow_3_0` | item | cinder_wick | thorn hedge | cinder_wick: `cave_1_5` |
| e027 | `ow_6_1` <-> `ow_6_2` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e028 | `ow_7_1` <-> `ow_8_1` | item | tallow_sling | eye-switch portcullis | tallow_sling: `cave_2_5` |
| e037 | `ow_1_2` <-> `ow_1_3` | cut | hook | reed wall | hook (start) |
| e041 | `ow_4_2` -> `ow_4_3` | oneway | none (one-way) | cliff ledge drop | - |
| e042 | `ow_5_2` <-> `ow_6_2` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e043 | `ow_5_2` <-> `ow_5_3` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e044 | `ow_6_2` <-> `ow_7_2` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e045 | `ow_6_2` <-> `ow_6_3` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e046 | `ow_7_2` <-> `ow_7_3` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e055 | `ow_4_3` <-> `ow_5_3` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e057 | `ow_5_3` <-> `ow_6_3` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e058 | `ow_5_3` <-> `ow_5_4` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e059 | `ow_6_3` <-> `ow_7_3` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e060 | `ow_6_3` <-> `ow_6_4` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e061 | `ow_7_3` <-> `ow_7_4` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e063 | `ow_9_3` <-> `ow_9_4` | item | heft_mitts | heavy stones | heft_mitts: `cave_4_5` |
| e069 | `ow_4_4` <-> `ow_5_4` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e071 | `ow_5_4` <-> `ow_6_4` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e072 | `ow_5_4` <-> `ow_5_5` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e073 | `ow_6_4` <-> `ow_7_4` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e074 | `ow_6_4` <-> `ow_6_5` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e075 | `ow_7_4` <-> `ow_8_4` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e079 | `ow_10_4` <-> `ow_10_5` | item | reel_line | anchor ring | reel_line: `cave_8_5` |
| e086 | `ow_4_5` <-> `ow_5_5` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e087 | `ow_4_5` -> `ow_4_6` | oneway | none (one-way) | cliff drop | - |
| e088 | `ow_5_5` <-> `ow_6_5` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e089 | `ow_5_5` <-> `ow_5_6` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e090 | `ow_6_5` <-> `ow_6_6` | item | reed_raft | mooring and water | reed_raft: `cave_3_5` |
| e093 | `ow_9_5` <-> `ow_9_6` | item | skitter_boots | ravine leap | skitter_boots: `cave_7_5` |
| e104 | `ow_8_6` <-> `ow_9_6` | item | skitter_boots | ravine leap | skitter_boots: `cave_7_5` |
| e109 | `ow_2_7` <-> `ow_3_7` | cut | hook | rush wall | hook (start) |
| e123 | `ow_2_0` <-> `ow_2_0#cache` | bomb | pitch_pot | cracked wall | pitch_pot: `ow_2_1#closet` |
| e124 | `ow_2_1` <-> `ow_2_1#closet` | key | key (ow) | locked door | small keys of scope ow: `cave_1#alcove`, `ow_3_2#grate` |
| e126 | `ow_4_1` <-> `ow_4_1#cache` | bomb | pitch_pot | cracked wall | pitch_pot: `ow_2_1#closet` |
| e127 | `ow_6_0` <-> `ow_6_0#shop` | bomb | pitch_pot | cracked wall | pitch_pot: `ow_2_1#closet` |
| e128 | `ow_7_2` <-> `ow_7_2#bag` | bomb | pitch_pot | cracked wall | pitch_pot: `ow_2_1#closet` |
| e129 | `ow_3_3` <-> `ow_3_3#hut` | item | cinder_wick | thorn-sealed door | cinder_wick: `cave_1_5` |
| e130 | `ow_3_2` <-> `ow_3_2#grate` | item | tether_moth | grated alcove | tether_moth: `ow_0_1` |
| e131 | `ow_8_0` <-> `ow_8_0#cache` | hidden | hook | hook-tap wall | hook (start) |
| e132 | `ow_9_0` <-> `ow_9_0#cache` | item | flare | wax seal | flare (start) |
| e133 | `ow_10_1` <-> `ow_10_1#hut` | key | key (ow) | locked door | small keys of scope ow: `cave_1#alcove`, `ow_3_2#grate` |
| e135 | `ow_11_2` <-> `ow_11_2#cache` | bomb | pitch_pot | cracked wall | pitch_pot: `ow_2_1#closet` |
| e136 | `ow_1_5` <-> `ow_1_5#cache` | cut | hook | bush cluster | hook (start) |
| e137 | `ow_5_5` <-> `ow_5_5#cache` | cut | hook | reed cluster | hook (start) |
| e138 | `ow_7_3` <-> `ow_7_3#grotto` | cut | hook | reed cluster | hook (start) |
| e141 | `ow_4_8` <-> `ow_4_8#cache` | bomb | pitch_pot | cracked wall | pitch_pot: `ow_2_1#closet` |
| e142 | `ow_11_6` <-> `ow_11_6#cache` | bomb | pitch_pot | cracked wall | pitch_pot: `ow_2_1#closet` |
| e144 | `ow_11_7` <-> `ow_11_7#cache` | hidden | glow_jar | sealed seam | glow_jar: `cave_5_5` |
| e145 | `ow_8_8` <-> `ow_8_8#cache` | item | reel_line | anchor ring pocket | reel_line: `cave_8_5` |
| e248 | `ow_3_5` <-> `cave_3_1` | bomb | pitch_pot | brittle rocks | pitch_pot: `ow_2_1#closet` |
| e251 | `ow_6_6` <-> `cave_6_1` | item | heft_mitts | heavy boulder | heft_mitts: `cave_4_5` |
| e252 | `ow_10_2` <-> `cave_7_1` | hidden | glow_jar | hidden stairs | glow_jar: `cave_5_5` |
| e253 | `ow_9_7` <-> `cave_8_1` | item | lantern_chime | resonance door | lantern_chime: `cave_6_5` |
| e254 | `ow_0_2` <-> `cave_9_1` | hidden | glow_jar | hidden stairs | glow_jar: `cave_5_5` |
| e255 | `ow_10_8` <-> `cave_10_1` | boss | frag:c1 .. frag:c9 | sealed door (nine fragments) | nine fragments: boss rooms of C1..C9 (see section 5.2) |
| e149 | `cave_1_4` <-> `cave_1_5` | brazier | hook | two braziers, gate | hook (start) |
| e151 | `cave_1_4` <-> `cave_1_6` | key | key (c1) | locked door | small keys of scope c1: `cave_1_3` |
| e152 | `cave_1_6` <-> `cave_1_8` | boss | bigkey:c1 | boss door | bigkey:c1: `cave_1_7` |
| e153 | `cave_1` <-> `cave_1#alcove` | brazier | hook | key alcove gate | hook (start) |
| e154 | `cave_1_6` <-> `cave_1_6#crack` | bomb | pitch_pot | cracked wall | pitch_pot: `ow_2_1#closet` |
| e156 | `cave_2_2` <-> `cave_2_3` | item | cinder_wick | thorn wall | cinder_wick: `cave_1_5` |
| e157 | `cave_2_2` <-> `cave_2_4` | key | key (c2) | locked door | small keys of scope c2: `cave_2_3`, `cave_2_6` |
| e160 | `cave_2_6` <-> `cave_2_7` | item | tallow_sling | eye-switch portcullis | tallow_sling: `cave_2_5` |
| e161 | `cave_2_5` <-> `cave_2_8` | key | key (c2) | locked door | small keys of scope c2: `cave_2_3`, `cave_2_6` |
| e162 | `cave_2_8` <-> `cave_2_9` | boss | bigkey:c2 | boss door | bigkey:c2: `cave_2_7` |
| e164 | `cave_3_2` <-> `cave_3_3` | cut | hook | moss wall | hook (start) |
| e165 | `cave_3_2` <-> `cave_3_4` | key | key (c3) | locked door | small keys of scope c3: `cave_3_3` |
| e167 | `cave_3_5` <-> `cave_3_6` | item | reed_raft | flooded passage | reed_raft: `cave_3_5` |
| e168 | `cave_3_6` <-> `cave_3_7` | item | reed_raft | flooded passage | reed_raft: `cave_3_5` |
| e170 | `cave_3_8` <-> `cave_3_9` | boss | bigkey:c3 | boss door | bigkey:c3: `cave_3_6` |
| e172 | `cave_4_2` <-> `cave_4_3` | item | tallow_sling | eye switch | tallow_sling: `cave_2_5` |
| e173 | `cave_4_2` <-> `cave_4_4` | key | key (c4) | locked door | small keys of scope c4: `cave_4_3`, `cave_4_6` |
| e175 | `cave_4_5` <-> `cave_4_6` | item | heft_mitts | heavy stone | heft_mitts: `cave_4_5` |
| e177 | `cave_4_7` <-> `cave_4_8` | key | key (c4) | locked door | small keys of scope c4: `cave_4_3`, `cave_4_6` |
| e179 | `cave_4_9` <-> `cave_4_10` | boss | bigkey:c4 | boss door | bigkey:c4: `cave_4_8` |
| e180 | `cave_4_7` <-> `cave_4_7#seal` | item | flare | wax seal | flare (start) |
| e182 | `cave_5_2` <-> `cave_5_3` | cut | hook | dry vine screen | hook (start) |
| e183 | `cave_5_2` <-> `cave_5_4` | key | key (c5) | locked door | small keys of scope c5: `cave_5_3`, `cave_5_6` |
| e185 | `cave_5_5` <-> `cave_5_6` | hidden | glow_jar | hidden seam | glow_jar: `cave_5_5` |
| e187 | `cave_5_7` <-> `cave_5_8` | key | key (c5) | locked door | small keys of scope c5: `cave_5_3`, `cave_5_6` |
| e189 | `cave_5_9` <-> `cave_5_10` | boss | bigkey:c5 | boss door | bigkey:c5: `cave_5_8` |
| e191 | `cave_6_2` <-> `cave_6_3` | bomb | pitch_pot | cracked wall | pitch_pot: `ow_2_1#closet` |
| e192 | `cave_6_2` <-> `cave_6_4` | key | key (c6) | locked door | small keys of scope c6: `cave_6_3`, `cave_6_7` |
| e194 | `cave_6_5` <-> `cave_6_6` | item | lantern_chime | resonance stone | lantern_chime: `cave_6_5` |
| e195 | `cave_6_6` <-> `cave_6_7` | hidden | glow_jar | hidden seam | glow_jar: `cave_5_5` |
| e197 | `cave_6_8` <-> `cave_6_9` | key | key (c6) | locked door | small keys of scope c6: `cave_6_3`, `cave_6_7` |
| e198 | `cave_6_8` <-> `cave_6_10` | item | heft_mitts | heavy door | heft_mitts: `cave_4_5` |
| e199 | `cave_6_10` <-> `cave_6_11` | boss | bigkey:c6 | boss door | bigkey:c6: `cave_6_9` |
| e200 | `cave_6_9` <-> `cave_6_9#crypt` | bomb | pitch_pot | cracked wall | pitch_pot: `ow_2_1#closet` |
| e203 | `cave_7_2` <-> `cave_7_4` | key | key (c7) | locked door | small keys of scope c7: `cave_7_3`, `cave_7_6` |
| e205 | `cave_7_5` <-> `cave_7_6` | item | skitter_boots | pit | skitter_boots: `cave_7_5` |
| e206 | `cave_7_6` <-> `cave_7_7` | item | skitter_boots | pit | skitter_boots: `cave_7_5` |
| e208 | `cave_7_8` <-> `cave_7_9` | key | key (c7) | locked door | small keys of scope c7: `cave_7_3`, `cave_7_6` |
| e210 | `cave_7_10` <-> `cave_7_11` | boss | bigkey:c7 | boss door | bigkey:c7: `cave_7_9` |
| e212 | `cave_8_2` <-> `cave_8_3` | item | tallow_sling | eye switch | tallow_sling: `cave_2_5` |
| e213 | `cave_8_2` <-> `cave_8_4` | key | key (c8) | locked door | small keys of scope c8: `cave_8_3`, `cave_8_6`, `cave_8_9` |
| e215 | `cave_8_5` <-> `cave_8_6` | item | reel_line | anchor ring | reel_line: `cave_8_5` |
| e216 | `cave_8_6` <-> `cave_8_7` | item | skitter_boots | pit | skitter_boots: `cave_7_5` |
| e218 | `cave_8_8` <-> `cave_8_9` | key | key (c8) | locked door | small keys of scope c8: `cave_8_3`, `cave_8_6`, `cave_8_9` |
| e220 | `cave_8_10` <-> `cave_8_11` | key | key (c8) | locked door | small keys of scope c8: `cave_8_3`, `cave_8_6`, `cave_8_9` |
| e221 | `cave_8_11` <-> `cave_8_12` | boss | bigkey:c8 | boss door | bigkey:c8: `cave_8_7` |
| e223 | `cave_9_2` <-> `cave_9_3` | item | cinder_wick | thorn wall | cinder_wick: `cave_1_5` |
| e224 | `cave_9_2` <-> `cave_9_4` | key | key (c9) | locked door | small keys of scope c9: `cave_9_3`, `cave_9_6` |
| e225 | `cave_9_4` <-> `cave_9_5` | item | reed_raft | flooded passage | reed_raft: `cave_3_5` |
| e226 | `cave_9_5` <-> `cave_9_6` | item | skitter_boots | pit | skitter_boots: `cave_7_5` |
| e227 | `cave_9_6` <-> `cave_9_7` | item | reel_line | anchor ring | reel_line: `cave_8_5` |
| e228 | `cave_9_5` <-> `cave_9_8` | item | heft_mitts | heavy stone | heft_mitts: `cave_4_5` |
| e229 | `cave_9_8` <-> `cave_9_9` | key | key (c9) | locked door | small keys of scope c9: `cave_9_3`, `cave_9_6` |
| e230 | `cave_9_9` <-> `cave_9_10` | boss | bigkey:c9 | boss door | bigkey:c9: `cave_9_7` |
| e231 | `cave_9_2` <-> `cave_9_2#cell` | item | tallow_sling | eye-switch cell | tallow_sling: `cave_2_5` |
| e232 | `cave_9_9` <-> `cave_9_9#vault` | item | lantern_chime | resonance vault | lantern_chime: `cave_6_5` |
| e234 | `cave_10_2` <-> `cave_10_3` | item | cinder_wick | thorn wall | cinder_wick: `cave_1_5` |
| e235 | `cave_10_2` <-> `cave_10_4` | key | key (c10) | locked door | small keys of scope c10: `cave_10_3`, `cave_10_7`, `cave_10_11` |
| e236 | `cave_10_4` <-> `cave_10_5` | item | reed_raft | flooded passage | reed_raft: `cave_3_5` |
| e237 | `cave_10_5` <-> `cave_10_6` | hidden | glow_jar | hidden seam | glow_jar: `cave_5_5` |
| e238 | `cave_10_6` <-> `cave_10_7` | item | lantern_chime | resonance stone | lantern_chime: `cave_6_5` |
| e239 | `cave_10_5` <-> `cave_10_8` | item | heft_mitts | heavy stone | heft_mitts: `cave_4_5` |
| e240 | `cave_10_8` <-> `cave_10_9` | item | skitter_boots | pit | skitter_boots: `cave_7_5` |
| e241 | `cave_10_9` <-> `cave_10_10` | item | reel_line | anchor ring | reel_line: `cave_8_5` |
| e242 | `cave_10_10` <-> `cave_10_11` | key | key (c10) | locked door | small keys of scope c10: `cave_10_3`, `cave_10_7`, `cave_10_11` |
| e243 | `cave_10_11` <-> `cave_10_12` | key | key (c10) | locked door | small keys of scope c10: `cave_10_3`, `cave_10_7`, `cave_10_11` |
| e244 | `cave_10_12` <-> `cave_10_13` | item | tallow_sling | eye switch | tallow_sling: `cave_2_5` |
| e245 | `cave_10_12` <-> `cave_10_14` | boss | bigkey:c10 | boss door | bigkey:c10: `cave_10_13` |

---

## 6. Collectibles budget

### 6.1 Counts per region and per cave

| Area | Rooms | Tools | Wick cores | Small keys | Big keys | Fragments | Pot bags | Caches | Shops | Pot bundles | Slug bundles | Enemies |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Brackwater Ford | 8 | 2 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 20 |
| Thornwood | 15 | 0 | 1 | 1 | 0 | 0 | 1 | 1 | 1 | 1 | 1 | 34 |
| Cinderflats | 14 | 0 | 1 | 0 | 0 | 0 | 1 | 3 | 1 | 0 | 1 | 34 |
| Tallowfen and Mirrormere | 24 | 0 | 1 | 0 | 0 | 0 | 0 | 2 | 1 | 0 | 0 | 57 |
| Gravelight Heights | 15 | 0 | 1 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 1 | 38 |
| Hushmarch | 12 | 0 | 1 | 0 | 0 | 0 | 0 | 2 | 1 | 0 | 1 | 30 |
| C1 The Wick Cellar | 8 | 1 | 1 | 2 | 1 | 1 | 0 | 1 | 0 | 0 | 0 | 17 |
| C2 The Briar Hollow | 9 | 1 | 1 | 2 | 1 | 1 | 0 | 0 | 0 | 0 | 1 | 18 |
| C3 The Drowned Wick Works | 9 | 1 | 2 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 18 |
| C4 The Sleeping Foundry | 10 | 1 | 1 | 2 | 1 | 1 | 0 | 1 | 0 | 0 | 1 | 22 |
| C5 The Mirrored Archive | 10 | 1 | 1 | 2 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 19 |
| C6 The Choir Vault | 11 | 1 | 2 | 2 | 1 | 1 | 0 | 1 | 0 | 0 | 0 | 25 |
| C7 The Hall of Nerve | 11 | 1 | 1 | 2 | 1 | 1 | 0 | 1 | 0 | 0 | 0 | 21 |
| C8 The Counting House | 12 | 1 | 1 | 3 | 1 | 1 | 0 | 0 | 0 | 0 | 1 | 25 |
| C9 Corrow's Undercroft | 10 | 0 | 1 | 2 | 1 | 1 | 0 | 2 | 0 | 0 | 1 | 20 |
| C10 The Ninth Hollow | 14 | 0 | 0 | 3 | 1 | 0 | 0 | 1 | 0 | 0 | 1 | 38 |
| **Total** | **192** | **10** | **17** | **22** | **10** | **9** | **2** | **16** | **6** | **1** | **9** | **436** |

C1 shows two small keys because the overworld key (scope `ow`) lies in the C1 alcove; its own
scope has one. Tools: Brackwater holds the moth and the pot; each of C1 to C8 holds one.

Caches include the four ward pockets (Cinderflats, Gravelight, C6 and C10; decision 8 of `docs/decisions.md`). Slug bundles are the nine sling-ammo sources in the graph (decision 9): four in the overworld (the Thornwood cache and shops S3 to S5) and five in caves (C2, C4, C8, C9 and C10). Every sling gate has a slug source that is reachable without the sling in the same region or cave (rule R6b, checked by the graph checker). The graph has 33 pockets: 30 pocket scenes and the 3 sealed spots that stay in their rooms (decision 15).

### 6.2 Wick cores

17 wick cores: 9 boss cores (C1 to C9), 6 hidden in the overworld (`ow_2_0` the existing
cache, `ow_3_3` the hermit's hut, `ow_7_3` the lake islet, `ow_11_2` slag cache, `ow_4_8` south
cliff, `ow_11_6` tide cache) and 2 hidden in caves (`cave_3_7` the drowned gallery, `cave_6_9` the
crypt). Start health 3 hearts, so the maximum is 20 hearts, which is the 20-heart cap.
C10 gives no core: its reward is the ending.

Hearts on entry in the recommended order (the typical column assumes that the player finds about
half of the hidden cores along the way):

| Step | Cave | Boss cores before | Hidden cores in reach (typical) | Hearts on entry (min) | Hearts on entry (typical) |
|---|---|---|---|---|---|
| 1 | C1 | 0 | 0 | 3 | 3 |
| 2 | C2 | 1 | 1 | 4 | 5 |
| 3 | C3 | 2 | 2 | 5 | 7 |
| 4 | C4 | 3 | 3 | 6 | 9 |
| 5 | C5 | 4 | 4 | 7 | 11 |
| 6 | C6 | 5 | 4 | 8 | 12 |
| 7 | C7 | 6 | 5 | 9 | 14 |
| 8 | C8 | 7 | 6 | 10 | 16 |
| 9 | C9 | 8 | 7 | 11 | 18 |
| 10 | C10 | 9 | 8 | 12 | 20 |

Enemy hit points and damage do not change with the hearts curve; the caves get harder through
counts, combinations and the tools that the fights need.

### 6.3 Keys

22 small keys in 11 scopes and 10 big keys (one per cave). Section 5.3 has the
scope table. The overworld has two locked doors: `ow_2_1` (the pitch pot closet, existing) and
`ow_10_1` (the kiln hut with pot bag P2). Their keys are `cave_1#alcove` (existing) and the grated
alcove at `ow_3_2` (needs the moth).

### 6.4 Pitch pot upgrades

Two pot bags (P1 at the Fallen Mast `ow_7_2`, P2 in the kiln hut `ow_10_1`) raise the pot limit.
Each bag adds 4 to the limit (decision 4 of `docs/decisions.md`): the limit is 10 until the first bag, 14 after it and 18 after the second. `PITCH_POT_MAX` changes in F5 (`GameState.pot_max()`). Pot bags do not change the sling limit (section 2.1).

### 6.5 Shops

Six shops, all pockets, no text: items sit on pedestals with a price shown in brass digits.

| Shop | Room | Name | Stock (price in brass) | Reached by |
|---|---|---|---|---|
| S1 | `ow_1_2` | Tilly's lamp stall | Ember 8, Pitch pot bundle 12 | open door; needs base kit |
| S2 | `ow_6_0` | Peddler's burrow | Ember 8, Tallow flask 40 | bomb (pitch_pot); needs pitch_pot |
| S3 | `ow_10_3` | Ashwife's cart | Pitch pot bundle 12, Tallow flask 40, Slug bundle 10 | open door; needs cinder_wick, tallow_sling |
| S4 | `ow_5_7` | Stone mason | Ember 8, Pitch pot bundle 12, Tallow flask 40, Slug bundle 10 | open door; needs base kit |
| S5 | `ow_10_7` | Pilgrim's stall | Ember 6, Pitch pot bundle 10, Tallow flask 35, Slug bundle 10 | open door; needs cinder_wick, glow_jar, pitch_pot, reed_raft, skitter_boots, tallow_sling, tether_moth |
| S6 | `ow_6_5` | Keeper's trade | Tallow flask 50 | open door; needs pitch_pot, reed_raft |

- **Ember**: +1 heart (2 half-hearts), applied on purchase.
- **Tallow flask**: full heal, applied on purchase (no inventory slot; open question 5).
- **Pitch pot bundle**: +4 pots (only offered once the pitch pot is found).
- Prices are in the existing currency (brass bit = 1, brass coin = 5).

### 6.6 Secret caches

16 caches (brass, pots, embers). 9 are in the overworld, 7 in caves; they are in the
pocket table (section 3.7) and in the cave tables. Brass in caches in total: about 460.

### 6.7 Economy sketch

- Income: a kill drops brass with 35 % (1 brass) or 5 % (5 brass), so 0.6 brass per kill on
  average. All 436 placed enemies killed once give about 261 brass.
- A first playthrough meets a room about 1.3 times (re-entries respawn enemies), so kills give
  about 340 brass. Caches add about 460. The game offers roughly 800 brass in total.
- Sinks: ember 6-8, bundle 10-12, flask 35-50. A player who buys all six shops once (one flask and
  one bundle each) spends about 250. The rest is a buffer for refills in the long caves.
- The wallet cap is 999 brass (decision 7; open question 6).
- Pot supply: 6 pots from the pot item, a 10 % bundle drop per kill, 1 bundle on a ledge
  (`ow_7_0`), bundles in 4 caches and in 4 shops. The 128 gated edges include 11 bomb walls; each needs one pot.

---

## 7. Open questions

### 7.1 For the user (all resolved)

Status: resolved on 2026-10-24 by the project owner. Sources: `docs/decisions.md` items 1 to 13 and section 1 of `docs/world-work-packages.md`. Decision 14 there (title screen and intro) is the work plan's own addition, not one of these questions.

1. **Ten caves and nine lanterns.** The story has nine lanterns, the Ninth Hollow among them. The
   plan makes C1 to C8 lanterns, C9 a non-lantern cave (Corrow's Undercroft, the letters and
   murals) and C10 the Ninth Hollow. Do you want C9 as a workshop cave, or nine caves only?

   **Resolved:** C9 is Corrow's workshop, a cave without a lantern (Corrow's Undercroft). C1 to C8 hold lanterns; C10 is the Ninth Hollow. (Decision 1.)

2. **The Ninth Door.** It opens with all nine fragments (C9 gives "Corrow's Last Wick"). Nine or
   eight?

   **Resolved:** Nine. The Ninth Door needs all nine lantern fragments. (Decision 2.)

3. **Scoped keys.** The plan changes `GameState.keys` into one count per scope (overworld and one
   per cave) so that no key can be wasted. The alternative is one global pool with a stricter
   design rule (no two key doors reachable at once). Scoped keys are recommended.

   **Resolved:** Scoped. Small keys belong to one cave each, so no key can be wasted. (Decision 3; F4.)

4. **Pitch pot bags.** May the pot limit grow beyond 10 (to 15 and 20)? Otherwise the two bags
   become heart-free caches with brass.

   **Resolved:** Yes. Each of the two pot bags adds 4 to the pitch pot limit: 10, then 14, then 18. (Decision 4; section 6.4.)

5. **Tallow flask.** Full heal on purchase, or a held item (needs an inventory and a use button)?

   **Resolved:** Full heal on purchase, with no inventory slot. (Decision 13; F9.)

6. **Wallet and prices.** Is there a wallet cap? Are the prices of section 6.5 right?

   **Resolved:** Yes, a wallet cap of 999 brass. Prices are set in playtests; section 6.5 keeps the starting values. (Decision 7; F5, F9.)

7. **Ten sub-items and one `cycle_item` button.** Ten tools make cycling slow. A radial picker in
   the pause menu is proposed.

   **Resolved:** A pause-style item subscreen instead of a radial picker: a grid of all items, move keys select, confirm equips. `cycle_item` stays as the quick switch. (Decision 6; F10.)

8. **Saving.** A game with 192 rooms needs saves. Where and how (a lantern post, the pause menu)?

   **Resolved:** Saves are required (F12, F13). One save slot: autosave on room entry, respawn at the last cave mouth or shop. (Decision 5; `docs/decisions.md` item 16.)

9. **The ward.** No gate needs the ward. Add beam puzzles that need it, or keep it as defence?

   **Resolved:** Both: a few ward puzzles, all off the main path (four optional caches with a ward plate in Cinderflats, Gravelight, C6 and C10), and the ward stays a defence tool. (Decision 8; G1.)

10. **Sling ammo.** Unlimited (as planned) or wax shots from the wallet?

   **Resolved:** Limited ammo: start 12, max 30, a slug bundle adds 6, and the drop chance is 8 %. Shops S3 to S5 sell a slug bundle. Pot bags do not change the limit. (Decision 9; F5, G1.)

11. **Start in the corner.** The six dev rooms keep their ids, so the start is the north-west
    corner and the world grows east and south. Is that acceptable?

   **Resolved:** Yes. The start stays in the north-west corner and the six dev rooms keep their ids. (Decision 10.)

12. **One-way drops.** Two ledge drops need a small `World` change. Keep them, or replace them with
    plain gates?

   **Resolved:** Keep both one-way ledge drops (a small World change, F8). (Decision 11.)

13. **The final fight.** The Unlit and the ending choice of `story.md` follow each other. Is the
    boss fight before the choice right? Corrow's Echo is the miniboss of C10.

   **Resolved:** Yes. The Unlit is fought first, then the ending choice (E1). (Decision 12.)

### 7.2 Objections and required updates to existing documents

**Status: resolved by `docs/world-work-packages.md`** (its section 2 maps each objection to the work package that resolves it). The documents below are not edited here.

- `code-contract.md` section 11 and 15: `cave_1` is at grid (0,3) with `exits = []`; this plan moves
  it to (1,13) and gives it west and east gaps. `World.ROOM_PATHS` lists seven rooms and
  `tests/test_world.gd` asserts seven.
- `dev-world-plan.md` section 7: the HUD minimap is the 3x2 grid; the big world needs a 12x9
  overworld map and a cave map. The plan lists "five monster types" and `AGENTS.md` the same:
  new monsters grow the list.
- `code-contract.md` section 5: `GameState.keys` is one number and `PickupBase` kind `key` has no
  scope. Scoped keys change both.
- `dev-world-plan.md` section 4 gives pitch pots a maximum of 10; bags would change it (question 4).
- `story.md`: "nine lanterns" and the Ninth Hollow; see question 1. The plan also adds a hint of a
  workshop under the lamp tower that the story does not mention.
- `ItemRegistry` and `GameState.cycle_item`: ten items, see question 7.
- `tests/test_world.gd` asserts that every exit is mirrored by the neighbour; the two ledge drops
  have a gap on the upper side only, so the test needs a one-way exception (question 12).
- `docs/.gdignore` hides `docs/` from Godot's importer, and exports do not contain it. The later
  work package should generate the runtime room table (for example `data/world_rooms.json` or a
  `.gd` constant) from `world-graph.json` instead of reading `docs/` at run time.

---

## Appendix A. NEW monsters

The monster document specifies them. This plan only needs the names and roles.

Regular monsters (placed in rooms):

| Monster | Kind | Role | Used in |
|---|---|---|---|
| `NEW:bramble_snapper` | regular | Rooted thorn jaw. Snaps when Tamsin is within about 1.5 tiles; never moves. Burns away under the cinder wick; the moth does not stun it. | C2, Thornwood |
| `NEW:fen_leech` | regular | Hides in shallow water tiles and surfaces to lunge along a line. Can only be hurt while surfaced. | C10, C3, C9, Tallowfen and Mirrormere |
| `NEW:cinder_wisp` | regular | Floating ember that drifts toward Tamsin and bursts into a short ring of flame. The ward blocks the burst. | C4, Cinderflats |
| `NEW:watcher_eye` | regular | Wall-mounted eye that fires a slow beam along its row or column. The ward blocks it; the sling kills it. | C10, Gravelight Heights |
| `NEW:husk_hound` | regular | Fast Hush hound. Charges in straight lines, then circles. Low HP, high speed. | C10, Hushmarch |
| `NEW:brine_crab` | regular | Armoured shore crab that walks sideways. Its front is immune; hit it from behind, with the flare or with a pot. | C10, C8, Hushmarch |
| `NEW:wickling` | regular | Tiny candle imp that arrives in packs of two or three. Dies in one hit. | C1, C10, C3, C5, C8, C9 |
| `NEW:mirror_shade` | regular | Shadow that mirrors Tamsin's facing and appears beside her. Shows its real position under the glow jar. | C10, C5 |
| `NEW:choirling` | regular | Floating mouth that sings a short cone. The ward blocks the cone; the chime stuns it. | C10, C6 |

Minibosses and bosses (one pair per cave):

| Monster | Cave | Kind | Design | Weakness / tool needed |
|---|---|---|---|---|
| `NEW:hollow_captain` | C1 | miniboss | A Hollow in a lamp-shade helm. Raised ward; hit from the side. | hook; moth stun recommended |
| `NEW:thorn_warden` | C2 | miniboss | A walking thorn hedge. Stunned by the moth, then cut down with the hook. | hook; moth stun recommended |
| `NEW:sump_lurker` | C3 | miniboss | A thing in the cistern. Surfaces to bite; stun it with the moth and strike. | hook; moth stun recommended |
| `NEW:lull_mauler` | C4 | miniboss | A slow slab-armed brute. Throw its dropped slag chunks back with the mitts, or stun and hook. | hook; moth stun recommended |
| `NEW:mirror_warden` | C5 | miniboss | Stands among reflections. Light the room with the jar to tell it from its copies. | hook; moth stun recommended |
| `NEW:choir_warden` | C6 | miniboss | Sings a wall of sound that the ward blocks. Strike when the note ends. | hook; moth stun recommended |
| `NEW:pale_squire` | C7 | miniboss | A fast Hollow that lunges across pits. Stun it with the moth at the edge. | hook; moth stun recommended |
| `NEW:abacus_brute` | C8 | miniboss | Swings a bead-chain. Pull its shield rail off with the reel line, then strike. | hook; moth stun recommended |
| `NEW:wick_automaton` | C9 | miniboss | A brass lamp-tender that Corrow built. Stun it with the moth, then use the pots. | hook; moth stun recommended |
| `NEW:corrows_echo` | C10 | miniboss | The wax shape of Corrow, fighting out of habit. Dodge, use the chime, strike. | hook; moth stun recommended |
| `NEW:kilnkeeper` | C1 | boss | A furnace-bellied Hush made of old kiln wax. Its wax armour melts under the cinder wick; then the hook finishes it. | `cinder_wick` |
| `NEW:briar_mother` | C2 | boss | Hangs in the canopy and lowers three seed-eyes. Only the sling reaches the eyes. | `tallow_sling` |
| `NEW:tidewick` | C3 | boss | A wick-serpent that circles a flooded basin. Fought from the raft; strike the glowing tail. | `reed_raft` |
| `NEW:hushed_colossus` | C4 | boss | A sleeping wax giant that wakes in phases. Lift and throw the stone shards that fall from the ceiling. | `heft_mitts` |
| `NEW:archivist` | C5 | boss | Splits into mirror copies. Only the real one casts a shadow under the glow jar. | `glow_jar` |
| `NEW:dirge_choir` | C6 | boss | Three singing heads. Answer each with the chime to stun it, then strike. | `lantern_chime` |
| `NEW:gloam_knight` | C7 | boss | Fights on a pit-ringed floor and dives between islands. Follow with the boots. | `skitter_boots` |
| `NEW:coinwyrm` | C8 | boss | A hoard-serpent behind coin plates. The reel line pulls the plates off; then the hook. | `reel_line` |
| `NEW:lock_warden` | C9 | boss | A great brass lock. The sling opens its eyes and the pot breaks the plates. | `pitch_pot`, `tallow_sling` |
| `NEW:the_unlit` | C10 | boss | The Hush's heart at the Ninth Lantern. Phase 1: sling its eyes. Phase 2: burn its wax. Phase 3: reel the lantern loose. Then the ending choice. | `tallow_sling`, `cinder_wick`, `reel_line` |
