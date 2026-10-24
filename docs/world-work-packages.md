# Wickwarden: world work packages (build plan)

Status: plan only. No code, scene or art changes come with this document.
Inputs: [world-plan.md](world-plan.md) (master plan), [world-graph.json](world-graph.json) (the graph),
[../tools/check_world_graph.py](../tools/check_world_graph.py) (the checker),
[code-contract.md](code-contract.md) (file ownership style), [dev-world-plan.md](dev-world-plan.md)
(section 9 is the step-1 WP format) and [state.md](state.md). The specs of the new monsters, bosses and
tools are in `docs/monsters-bosses-tools.md` (written in parallel by another agent). This plan refers
to that file by name and never repeats a stat from it. Where this plan and that file disagree about a
number, the monster file wins; where they disagree about a decision of the user (section 1), this plan wins.

This document splits the build of the full game (88 overworld rooms, 104 cave rooms, 30 pocket
scenes, 8 new tools, 9 new monsters, 10 minibosses, 10 bosses, saves, title and intro) into work
packages (WP) that Sonnet and Haiku agents can build in parallel without touching the same file.

## Summary

| Wave | Content | WPs | Agent sessions | Parallelism |
|---|---|---|---|---|
| 0 | Foundation: graph amendments, docs, runtime data, World streaming, keys, wallet, room kit, player motion, ledges, shops, item subscreen, minimap, saves, title, intro | 19 | about 19 | sequential (D-WPs in parallel) |
| 1 | Parts: 15 props, 8 tools, boss base, 5 groups of regular monsters | 29 | 29 | up to 29 at once |
| 2 | Content 1: 6 regions (23 room batches), 5 miniboss pairs, 10 bosses | 21 | 44 | up to 44 at once |
| 3 | Content 2: 10 caves (30 room batches), the ending | 11 | 41 | up to 41 at once |
| 4 | Integration and QA: solver test, strict completeness, playthrough, capture of every room, review, soak, matrix, performance, docs | 9 | about 25 | up to 25 at once |
| 5 | Playtest rounds, tuning, release | 3 | rolling | lead-driven |
| | **Total** | **92** | **about 160** | |

Model split: Sonnet for every foundation WP, every WP that touches the player, World, UI or saves, all
bosses and the region/cave leads; Haiku for props, simple tools, regular monster groups, minibosses 1 to 3, all room batches and
the mechanical QA work. Section 9 has the sizes.

---

## 1. Decisions that bind this plan

The user answered the open questions of world-plan section 7.1. Each answer changes a WP:

| # | Decision | Effect on the WPs |
|---|---|---|
| 1 | C9 is Corrow's workshop, a non-lantern cave. C1-C8 are lanterns, C10 is the Ninth Hollow. | `story.md` and AGENTS.md wording in F0/D1. C09 (Corrow's Undercroft) has no lantern reward but the ninth fragment. |
| 2 | The Ninth Door needs all nine lantern fragments. | P11 builds nine sockets. The graph already says so. |
| 3 | Small keys are scoped per cave. | F4. |
| 4 | The two pot bags each add +4 to the pitch pot limit (10, 14, 18). | F5 (`GameState.pot_max()`), pickup kind `pot_bag`. |
| 5 | Saves are required. | F12 (save system), F13 (title and Continue). |
| 6 | The sub-item picker is a pause-style item subscreen: a grid of all items, move keys select, confirm equips. `cycle_item` stays as quick switch. | F10 (replaces the radial picker idea of world-plan 7.1 question 7). |
| 7 | Wallet cap 999 brass. Prices are set later in playtests. | F5 (cap), F9 reads prices from `data/shop_prices.json` so tuning never touches code (Z2). |
| 8 | A few puzzles need the ward. | G1 (graph), P15 (ward puzzle props), R3/R5/C06/C10 rooms. |
| 9 | The tallow sling has limited ammo, like the pitch pot. | F5 (`slugs`, `slug_bundle`), T02, shops and drops, G1 (refill rule). |
| 10 | The start stays in the north-west corner; the six dev rooms keep their ids. | none (already so). |
| 11 | Both one-way ledge drops stay (small World change). | F8. |
| 12 | The final fight comes before the ending choice. | E1 (the Unlit dies, then the choice). |
| 13 | The tallow flask heals fully on purchase (no inventory slot). | F9. |
| 14 | A title screen with a menu (New game, Continue, Quit) and a skippable intro story. | F13 (title, new-game flow), F14 (intro), D3 (intro script). |

World-plan section 7.1 must be marked resolved by D1. `docs/monsters-bosses-tools.md` is another agent's file: no WP of this plan edits it, and
a spec conflict is reported to the lead (the file already follows the user's decisions on sling ammo, pot limit and ward).

## 2. Objections of world-plan section 7.2 and the WP that resolves each

| Objection (world-plan 7.2) | Resolved by |
|---|---|
| `cave_1` grid (0,3), `exits = []`, `ROOM_PATHS` of seven rooms, `tests/test_world.gd` asserts seven | F1 (data), F2 (World loads from data; `cave_1` grid moves to (1,13); tests follow), C01 (exits E and W) |
| HUD minimap is 3x2; "five monster types" in `dev-world-plan.md` and AGENTS.md | F11 (12x9 overworld map and a cave map), F0 and D1 (wording) |
| `GameState.keys` is one number; `PickupBase` kind `key` has no scope | F4 |
| Pitch pot maximum 10 (bags) | F5 (10, 14, 18) |
| `story.md`: nine lanterns, the Ninth Hollow, workshop under the lamp tower | F0 (story.md text), D1 (plan wording), D3 (intro keeps to the same truth) |
| `ItemRegistry` and `cycle_item` with ten items | F10 (subscreen, all ten ids registered up front) |
| `tests/test_world.gd` mirrored exits vs. the two ledge drops | F8 (one-way exception) |
| `docs/.gdignore` hides `docs/` from the importer and exports | F1 (generator writes `data/world_data.json`; nothing reads `docs/` at run time) |

---

## 3. Rules that apply to every WP

1. **Read first**: AGENTS.md, `docs/code-contract.md` (as amended by F0), the WP row below and the named inputs. Never guess a dimension, path or interface.
2. **Only write the files in your `Owns` list.** Anything else is reported to the lead, not patched. In waves 1 to 5 no two WPs own the same file. Wave 0 is sequential: a later foundation WP may amend a file of an earlier one only where its `Owns` list says "amends".
3. All rules of `code-contract.md` section 1 stay: behaviour in `_physics_process`, no `class_name` in WP files (an `extends "res://path.gd"` is fine), `load()` plus null check for files another WP delivers, a `Visual` child, half-heart integers, `Layers.*` constants, no tutorial text in the game world. Story text (title, intro, ending) is allowed; button help lives only in the pause menu.
4. **Placeholder art only.** New entities register their look with `Placeholder.register_kind(...)` (F2) from their own script. Art and audio for the new content are a later pass (section 11 lists the needs). New content reuses the existing sounds or stays silent. `tools/make_audio.py` and `Placeholder.KINDS` are not edited by content WPs.
5. **Persistence by flags.** Anything that must survive a room change or a save is a `GameState` flag named in the code contract (`picked_<id>`, `door_<id>`, `gate_<id>`, `cracked_<id>`, `brazier_<id>`, plus the new ones of F0). Rooms can be unloaded at any time (F2), so no state lives in a room node.
6. **Interface contracts** (table in section 4) are the only coupling between parallel WPs. Tests of a WP use the real counterpart if it exists and a small stand-in that obeys the same contract otherwise. Q7 then tests every real pair.
7. **Done means**: `make test T="<own suites>"` passes, `make lint` is clean, the visual check of the row was made (a screenshot with `tools/capture.tscn`, see section 8), the report lists every file touched. The lead runs the full `make check` after the merge.
8. A WP that finds a spec problem stops and reports it. It does not change numbers, normative documents or `docs/monsters-bosses-tools.md`.

## 4. Interface contracts (F0 writes them into `code-contract.md`; wave 1 builds against them)

| Contract | Defined as |
|---|---|
| Fire | `Hitbox.kind = &"fire"`. A prop that burns is in group `burnable` and has `on_fire(pos: Vector2)`. `Brazier` also lights on `fire`. |
| Sling | `Hitbox.kind = &"sling"` (damage 2, one slug on screen, costs one slug). An `EyeSwitch` is in group `eye_switch` and reacts to `sling` hitboxes on `PROP_HURTBOX`. |
| Chime | A resonance prop is in group `resonant` and has `on_chime()`. The warp list is `GameState` flags `mouth_c1` .. `mouth_c10` (set when a cave mouth is first entered). |
| Glow | A hidden prop is in group `revealable` and has `reveal()` / `hide_again()`. The jar adds a `PointLight2D` (radius 520, 6 s) and calls `reveal()` on every `revealable` within its radius while it burns. |
| Raft | `Mooring` is in group `mooring` with `mooring_id`, `target_room`, `target_mooring`. The raft rides the player between two moorings with the Player motion API (F7). |
| Boots | `PitZone` is in group `pit_zone`. `Player.is_airborne()` is true during the leap; a pit only acts when the player is not airborne. |
| Reel | `AnchorRing` is in group `anchor_ring` with `get_anchor_position()`. The reel hitbox has `kind = &"reel"` and carries small pickups with `PickupBase.begin_carry`. |
| Mitts | A small thing is in group `liftable` (`lift(by)`, `throw(dir)`); a `HeavyStone` is in group `heavy` (`try_move(dir)`, `lift_by_mitts(by)`). The mitts item checks `GameState.has_item(&"heft_mitts")`. |
| Grate | A grate is in group `grate`. It blocks the player body (layer `WORLD`); the tether moth's turn-back ray ignores bodies in that group (P09 amends `tether_moth.gd`). |
| Ward | The ward absorbs a blockable `Hitbox`; the existing `Hitbox.blocked` signal fires. A `WardPlate` counts those blocks (P15). |
| Shallows | Fen leeches need `Area2D` zones in group `shallows`; rooms place them (R4, C03, C09, C10). |
| Boss | `BossBase` (M0) extends `EnemyBase`, sets flag `boss_<cave room id>_defeated` on death, emits `defeated`, and locks the arena doors for the fight. Placed rewards use `PickupBase.requires_flag` (F4) so they appear only after that flag. |
| Spawn markers | Cave mouth room has marker `FromCave`; cave entrance room has marker `FromOverworld`; pocket door pairs use `FromPocket` / `Inside`. All room doors take their targets from `data/world_data.json`. |
| Gate prop names | One prop name per row of world-plan 1.3 / 2.2; the generator emits a `prop` string per edge and `tests/test_world_graph.gd` maps each to a scene or script (F3 table). |

---

## 5. Wave 0: foundation (sequential, Sonnet unless noted)

Order: G1 first (the graph is the source of everything), then D1/D2/D3 (Haiku, may run beside F0 to F2), then F0 to F14 strictly in order. Each WP is
merged and `make check` is green before the next one starts. F7 to F14 touch different parts of `world.gd`, `player.gd`, `hud.gd` and
`pause_menu.gd` and are therefore sequential, not parallel. Waves 1 and later may start as soon as the WPs in their `Depends` column are merged;
they do not wait for the whole of wave 0.

### G1. Graph amendments: ward puzzles, sling ammo (Sonnet)

- **Depends:** none. **Blocks:** F1 and everything that reads the graph.
- **Owns:** `docs/world-graph.json`, `tools/check_world_graph.py`.
- **Inputs:** world-plan sections 1.4 (R1 to R6), 5.7, 6; decisions 8 and 9; the monster file for which monsters fire blockable shots (watcher eye beam, choirling cone, cinder wisp burst, spitcap spore).
- **Deliverable:**
  1. Ward puzzles: add four optional pockets (caches) behind a `ward` puzzle: gate type `item`, `needs: ["ward"]`, prop `ward plate`, one each in Cinderflats (cinder wisp bursts), Gravelight (watcher eye), C06 (choirling cones) and C10 (watcher eyes). The ward is a base capability, so no round changes. The checker keeps rejecting empty `needs`. Update the sample counts the checker prints.
  2. Sling ammo: new capability-free rule R6b in the checker: every `tallow_sling` gate (eye-switch portcullis, cell, boss fight of C02/C09/C10) must have a slug source reachable without the sling being used up: add pickup kind `slug_bundle` (cache contents or shop stock) near each such gate; the checker verifies that a slug source exists in the same region or cave. Mutation tests as in world-plan 5.7 for both rules.
  3. The pocket total becomes 33 (30 pocket scenes plus the 3 in-place pockets of section 6.2). All numbers in this document that depend on it say "per data".
- **Check:** `python3 tools/check_world_graph.py --stats --rounds --orders` exits 0, the 26 cave orders are unchanged, each new mutation is rejected.

### D1. Write the decisions into the master plan (Haiku)

- **Depends:** G1 (counts). **Owns:** `docs/world-plan.md` (and nothing else).
- **Deliverable:** world-plan section 7.1 marks all 13 questions resolved with the answers of section 1 of this document (decision 14 is this plan's own); section 7.2 is marked "resolved by docs/world-work-packages.md"; the count tables of sections 1.3, 2.1, 6.1 and 6.4 are updated for G1 (ward gates, slug bundles, pot limit 10/14/18, wallet cap 999, sling ammo). No design change beyond the user's answers.
- **Check:** the checker still passes; a text search for "unlimited" in the sling row finds none; diff touches only the sections named.

### D2. Ownership manifest and checker (Haiku)

- **Depends:** this document is merged. **Owns:** `tools/wp_ownership.json`, `tools/check_ownership.py`, `tools/test_check_ownership.py`.
- **Deliverable:** `wp_ownership.json` maps every WP id of this document to its `Owns` globs (room batches expand to their room ids from `data/world_data.json`, so the file is regenerated by the script from the batch tables). `python3 tools/check_ownership.py <WP> [--base main]` lists the files changed in the worktree (`git diff --name-only` is run by the lead's shell; the script takes a file list on stdin so Haiku agents never need git) and fails on any file outside the WP's globs, and a global check fails when two WPs of waves 1 to 5 own the same path.
- **Check:** the Python test covers a clean WP, a stray file, and a duplicate owner.

### D3. Intro script (Haiku)

- **Depends:** none. **Owns:** `docs/intro-script.md`.
- **Inputs:** `docs/story.md` (premise, protagonist, quest; not the late truth), the tone section.
- **Deliverable:** the intro in English: six beats, one per still (section 11), each 2 to 4 short lines (at most 70 characters per line), present tense, warm and melancholic. It covers the Nine Lanterns, the Lanternfall, the dusk and the Hush, Tamsin and Corrow's hook and lamp, and ends with her setting out. It must not reveal Corrow's truth. Format: `## Still N: <id>` then the lines, one per line, then `(hold: <seconds>)`. A closing table lists the still ids and a one-sentence picture brief each (the art inventory reads it).
- **Check:** at most 24 lines in total, every line at most 70 characters, no mention of a button or control.

### F0. Contract and documents (Sonnet)

- **Depends:** G1, D1. **Owns:** `docs/code-contract.md`, `AGENTS.md`, `docs/dev-world-plan.md` (notes only: HUD, pot limit, keys, monster list point to the new documents), `docs/story.md` (C9 workshop, the cave-and-lantern wording, title and intro pointer).
- **Deliverable:** code-contract gets a new section 16 "World build": the interface contracts of section 4 of this document; the new flag names (`mouth_cN`, `bigkey_cN`, `frag_cN`, `boss_<room>_defeated`, `pot_bag_1/2`, `intro_seen`); the new file layout (data/, tools/rooms/, scenes/world/rooms/, scenes/world/pockets/ does not exist: pockets live in `scenes/world/rooms/<id>__<tag>.tscn`); the amended sections 5, 11 and 15; the ownership rules of section 3; the amendment table. AGENTS.md: monster list wording, new commands (`make world-data`, `make world-check`, `make rooms`, `make capture-all`), the work-package pointer.
- **Check:** a lead read-through; the rest of the plan can quote section numbers. `make check` unchanged.

### F1. Runtime world data from the graph (Sonnet)

- **Depends:** G1, F0. **Owns:** `tools/gen_world_data.py`, `tools/test_gen_world_data.py`, `data/world_data.json` (generated), `scripts/core/world_data.gd` (`class_name WorldData`; the import is run by the lead), `tests/test_world_data.gd`, `Makefile` (all new targets are added here at once: `world-data`, `world-check`, `world-gen-test`, `rooms`, `rooms-check`, `capture-all`, `playthrough`; targets whose tool comes later print a clear "not built yet"; `check` gains `world-check` and `world-gen-test`).
- **Inputs:** `docs/world-graph.json`, world-plan 1.1 and 5.6.
- **Deliverable:** `data/world_data.json`, a trimmed copy of the graph that the game may read at run time (docs/ is hidden from exports): rooms (`id`, `scene` path, `grid`, `exits`, `dark`, `scope` = `ow` or `cN`, `region`, `name`, `enemies`), pockets (`id`, `scene` path with `#` replaced by `__`, `in_place`, virtual `grid` in a pocket band at row 30 so no pocket overlaps a room), edges (`a`, `b`, `link`, `gate`, `needs`, `dir`, `key`, `prop`), pickups, items, shops, caves (mouth room, entrance room, lantern name), plus `source_sha` of the graph. `WorldData` offers static `room_ids()`, `has(id)`, `scene_path(id)`, `grid(id)`, `exits(id)`, `scope_of(id)`, `neighbors(id)`, `edge_between(a, b)`, `is_oneway(a, b)`, `cave_of(id)`, `pickups_in(id)`, `all_pockets()`. Pocket policy: the three existing sealed spots (`ow_2_0#cache`, `ow_2_1#closet`, `cave_1#alcove`) are `in_place` (no scene); every other pocket has its own scene. `make world-check` regenerates to a temp file and fails when it differs from the committed file (the file is never merged by hand).
- **Check:** `tests/test_world_data.gd` (counts 192 rooms, pockets, every `scene` path under the agreed names, grids unique, caves in rows 12 and later, exits equal step links); `tools/test_gen_world_data.py`.

### F2. World runtime: data-driven rooms, streaming, shared hooks (Sonnet)

- **Depends:** F1. **Owns:** `scripts/world/world.gd`, `scenes/world/rooms/cave_1.tscn` (only `grid = (1,13)`), `tests/test_world.gd`, `tests/test_dev_world.gd`, `tests/test_dev_world_route.gd`, `scripts/art/placeholder.gd`, `tools/capture.gd`.
- **Deliverable:**
  1. `World.ROOM_PATHS` is removed. `_by_grid` is built from `WorldData`; rooms are instantiated on demand: the current room and the rooms it can slide into stay loaded, others are freed (`World.rooms` holds only loaded rooms; `get_room(id)` loads on demand so tests keep working; pockets load on `warp_to`). A room that does not exist yet (scene missing) is a warning and a closed edge, not an error, so partial worlds run during the build.
  2. Launch arguments `--start-room=<id>[:spawn]` for play and capture; `--dev-mode` stays (its key loadout is amended by F4).
  3. `Placeholder.register_kind(kind, definition, is_static := false)` (runtime registry beside `KINDS`) and `Placeholder.has_kind()`; `PickupBase` uses it (F4 amends the one call).
  4. `World.add_room_scene(room_id, packed_scene)` (a test and capture hook) and `capture.gd --fixture=<scene>` so a WP can screenshot its own gallery scene `tests/fixtures/gallery/<wp>.tscn`.
  5. Tests follow: `test_world.gd` asserts the room set equals `WorldData` rooms that have a scene, exits are mirrored for loaded neighbours, `cave_1` is at world position (1920, 12480), and every dev-world assertion stays.
- **Check:** `make test` (all 22 existing suites plus the changed ones) is green; `make run` and a capture of `ow_0_0` and of `cave_1` look unchanged; a soak test walks 40 `warp_to` calls between rooms and checks that the node count does not grow.

### F3. Graph-versus-scenes test and area test base (Sonnet)

- **Depends:** F2. **Owns:** `tests/test_world_graph.gd`, `tests/area_base.gd` (extends `TestCase`, no `class_name`), `tools/run_godot_check.py` (adds a first-line header `## timeout=<seconds>` so long suites such as the playthrough can exceed 90 s).
- **Deliverable:** the test of world-plan 5.7: for every node of `WorldData` whose scene exists, `room_id`, `grid` and `exits` equal the node; every gated edge has the matching prop (table: `item`+prop name to script, `key` to `LockedDoor` with the right scope, `bomb` to `CrackedWall`, `boss` to `BossDoor`, `hidden` to `HiddenSeam`, `oneway` to `Ledge`); every pickup has its `persistent_id`; mouths and pocket doors target the right rooms; every step link is mirrored except one-way ones. Missing scenes are listed as pending and are not failures here (Q2 adds the strict version). `area_base.gd` offers `check_area(area_id)` for the standard per-area checks: scenes load, enemy counts equal the graph, gates and pickups present, exits clear for 3 tiles, hollows on tile centres, sealed spots closed, reachable by tile flood fill from every exit.
- **Check:** passes on the 7 existing rooms (the pending list is long and printed once); a deliberately broken fixture room fails.

### F4. Scoped small keys, big keys, fragments, gated pickups (Sonnet)

- **Depends:** F2. **Owns:** `scripts/autoload/game_state.gd` (keys), `scripts/pickups/pickup_base.gd`, `scripts/world/locked_door.gd`, `scenes/pickups/big_key.tscn`, `scenes/pickups/fragment.tscn`, `tests/test_game_state.gd`, `tests/test_pickups.gd`, `tests/test_interactables.gd`; amends `scripts/world/world.gd` (`apply_dev_loadout`: 5 keys in every scope) and `tests/test_dev_world.gd` (the dev-keys assertion).
- **Deliverable:** `GameState.keys_in(scope)`, `add_key(n, scope)`, `use_key(scope)`; the property `keys` stays as the count of the current scope (derived from `WorldData.scope_of(current_room)`) so old code and tests keep working; `big_keys` and `fragments` as flag-backed sets with `has_big_key(cave)`, `add_fragment(cave)`; signals; `PickupBase` gets `scope` (default `ow`), kinds `big_key` and `fragment` (flags `bigkey_cN`, `frag_cN`), `requires_flag` (inactive and invisible until the flag exists); `LockedDoor` gets `scope`. The scope of a key pickup is explicit in the scene, and the graph test (F3) checks it against the graph.
- **Check:** unit tests for spend-in-wrong-scope, big key, fragment, requires_flag; the dev route still passes unchanged.

### F5. Wallet, pot capacity, bags, slug ammo (Sonnet)

- **Depends:** F4. **Owns:** `scripts/autoload/game_state.gd` (amends), `scripts/pickups/pickup_base.gd` (amends), `scripts/pickups/drop_table.gd`, `scripts/items/pitch_pot.gd`, `scenes/pickups/pot_bag.tscn`, `scenes/pickups/slug_bundle.tscn`, `tests/test_game_state.gd`, `tests/test_pickups.gd`, `tests/test_pitch_pot.gd` (amend).
- **Deliverable:** `WALLET_CAP = 999`, `spend_currency(n) -> bool`; `pot_max()` = 10 + 4 per bag flag (`pot_bag_1`, `pot_bag_2`) with `PITCH_POT_MAX` kept as the base; pickup kind `pot_bag` (sets the next bag flag, which raises the limit by 4); sling ammo: `slugs`, `slug_max()` (30; 12 slugs on the first pickup of the sling, bundle +6, as in `docs/monsters-bosses-tools.md` section 0), `add_slugs`, `spend_slug() -> bool`, signal, pickup kind `slug_bundle`, drop table entry (only after the sling is found, like the pot bundle). The slug drop is 8 % after the sling is found (monster file, section 1.5).
- **Check:** cap, bag steps 10/14/18, slug spend and drop gating; existing tests unchanged.

### F6. Room kit: layout compiler and validator (Sonnet)

- **Depends:** F3. **Owns:** `tools/build_rooms.py`, `tools/test_build_rooms.py`, `docs/room-kit.md`, `tests/fixtures/rooms/` (sample `.room` files and their expected `.tscn`).
- **Why:** a room scene has about 40 nodes in a fixed text format with ids and ext_resources. Hand-writing 220 of them with Haiku invites format errors. A small compiler turns a compact source into the same plain `.tscn` as step 1.
- **Deliverable:** `python3 tools/build_rooms.py [ids...] [--check]` reads `tools/rooms/<id>.room` (pocket: `<id>__<tag>.room`) and writes `scenes/world/rooms/<id>.tscn`. A `.room` file has a header (`room`, `terrain`, `dark`, `floor_color` taken from data) and a 20x10 character grid (tile = 96 px; `.` floor, `#` wall block merged into rectangles, `r` rock, `t` tree, `w` water, `b` bush, and so on) plus an entity list (`enemy hollow 5,3`, `prop thorn_hedge 9,0 id=ow_3_0_hedge`, `pickup item tether_moth id=tether_moth`, `door target=cave_1 spawn=FromOverworld`, `spawn FromCave 14,3`). `room_id`, `grid`, `exits`, `dark` come from `WorldData`, never from the file. Validation (errors fail the build): exits equal the graph, 3 free tiles in front of every gap, hollows on tile centres, nothing on an obstacle, enemy counts equal the graph node, every referenced scene exists, ids unique per room, sealed spots closed except for exactly one opener, tile flood fill reaches every pickup from every exit that is open, and the persistent ids follow the naming of the code contract. Generated `.tscn` files carry a header comment and are never edited by hand. The seven existing rooms stay hand-made and are not regenerated.
- **Check:** round trip on fixtures (a `.room` of `ow_0_1` produces a scene whose node list equals the existing scene); `make rooms-check` runs the validator over every `.room`; a `.room` with a blocked corridor fails.
- **Fallback** (open question 1): if the user rejects the kit, room WPs hand-write `.tscn` in the step-1 style and `area_base.gd` (F3) is the only validator; room batches then shrink to 3 rooms.

### F7. Player motion and modifier API (Sonnet)

- **Depends:** F2. **Owns:** `scripts/player/player.gd`, `tests/test_player_motion.gd`; amends nothing else.
- **Deliverable:** a generic API so that the raft, boots, reel line and mitts need no further `player.gd` edits: `begin_external_motion(path: Array[Vector2], speed, options)` and `end_external_motion()` (controls locked, body shape off, hurtbox optional), `is_airborne()`, `lock_actions(source, on)` (no hook, no item while on), `set_speed_scale(source, factor)`, `set_hurtbox_enabled(source, on)`, `signal motion_finished`. Rooms may change during a ride (the raft crosses rooms): the motion is not cancelled by `World` slides and ends at its target.
- **Check:** tests for a straight path, a path through a wall, damage ignored during an airborne leap, restoring on death; `test_player.gd` unchanged and green.

### F8. One-way ledge drops (Sonnet)

- **Depends:** F7. **Owns:** `scripts/world/room.gd`, `scripts/world/ledge.gd`, `scenes/world/ledge.tscn`, `tests/test_oneway.gd`; amends `scripts/world/world.gd` (`_neighbor`) and `tests/test_world.gd` (mirror exception).
- **Deliverable:** `Room.drop_exits` (sides where a drop leaves the room without a mirrored gap); `World._neighbor` accepts a one-way edge from `WorldData.is_oneway`; the lower room has no gap on that side; the camera slides as usual with a short drop sound reuse; `Ledge` prop draws the ledge edge. The way back is never blocked by the world (rule R5, checked by the graph).
- **Check:** the player drops from `drop` side and cannot climb back through the lower wall; the mirrored-exit test ignores exactly the edges that `WorldData` marks one-way.

### F9. Shops (Sonnet)

- **Depends:** F5, F6. **Owns:** `scripts/world/shop_item.gd`, `scenes/world/shop_item.tscn`, `data/shop_prices.json`, `tests/test_shop.gd`.
- **Deliverable:** `ShopItem` (a pedestal item with a brass-digit price; walk-up purchase; sold-out flag `shop_<id>` for one-time stock; refills of ember and flask are not one-time). Stock kinds: `ember` (+1 heart at purchase), `pot_bundle` (+4 pots, only after the pot item is found), `slug_bundle`, `tallow_flask` (full heal on purchase, no inventory slot). Prices come from `data/shop_prices.json` (initial values from world-plan 6.5; the user sets final ones in playtests). Not enough brass: nothing happens and a short denied sound is reused. The six shops are pocket scenes made later by R-WPs with `ShopItem` nodes; the shop template `.room` lives in `tests/fixtures/rooms/shop.room`.
- **Check:** buy, deny, cap at wallet 0, sold-out persistence, price lookup.

### F10. Item subscreen (Sonnet)

- **Depends:** F5. **Owns:** `scripts/ui/item_menu.gd`, `scenes/ui/item_menu.tscn`, `scripts/items/item_registry.gd`, `scripts/ui/pause_menu.gd`, `project.godot` (new actions `item_menu` and `confirm`), `tests/test_items.gd`, `tests/test_item_menu.gd`; amends `scripts/world/world.gd` (`_build_overlay`) and `scripts/autoload/game_state.gd` (cycle order follows the registry order).
- **Deliverable:** a pause-style subscreen opened by `item_menu` (Tab, gamepad Select) that pauses the tree like the pause menu: a grid of all ten sub-items (5x2) with silhouettes for items not found yet; move keys select, `confirm` equips and closes, `pause` or the menu button closes without change; the selected item's name is shown (text is allowed here, it is a menu); a status strip shows nine fragment sockets, big keys of the current cave and the heart count. `cycle_item` (Q/I/Y) stays as the quick switch. `ItemRegistry` registers all ten ids and scene paths up front (an item without a scene is a silent no-op, already the rule), so tool WPs never edit it. The pause menu help gets the new row.
- **Check:** open, select with every direction, equip, silhouette of unfound items, quick switch order, tree pausing; capture of the screen with 3 items found and with all ten.

### F11. Minimap for about 192 rooms (Sonnet)

- **Depends:** F2. **Owns:** `scripts/ui/hud.gd`, `tests/test_hud_map.gd`, `scenes/ui/hud.tscn` if needed; amends `tests/test_world.gd` (only the two `Hud.room_cell` assertions).
- **Deliverable:** in the overworld the HUD shows the 12x9 grid from `WorldData` (cell 14x10 px with 2 px gaps, 192x108 px, fits the 120 px band); blank where there is no room (sea), dim for unvisited, filled for visited, a ring for the current room, small marks for visited cave mouths and shops. Inside a cave the HUD shows that cave's local grid (at most 5 wide, 5 high) with larger cells. Pockets are not on the map. `Hud.room_cell` returns the grid cell for overworld ids and the local cell for cave ids. The counters show the keys of the current scope and the big key and fragment icons (read from F4). Pot count shows `pots / pot_max`; the slug counter appears once the sling is found. Counters never overlap the item frame or the map.
- **Check:** unit tests of the cell mapping for all 192 ids; captures with an empty save, a half-explored save and all rooms visited.

### F12. Save system (Sonnet)

- **Depends:** F4, F5, F11. **Owns:** `scripts/autoload/save_game.gd` (autoload `SaveGame`), `project.godot` (autoload line; amends the file of F10), `tests/test_save_game.gd`; amends `scripts/world/world.gd` (launch mode, checkpoint, autosave hook).
- **Deliverable:** one slot, `user://save_1.json`, versioned (`format`, `game_version`), atomic write (temp file then rename), containing health, max health, wallet, keys by scope, pots, slugs, items, active item, visited rooms, all flags, the checkpoint room and the playtime. Autosave on every room entry (debounced to once per second) and after every persistent pickup. `SaveGame.has_save()`, `save()`, `load_into_state()`, `erase()`, `launch_mode` (`&"new"`, `&"continue"`, `&"dev"`). The checkpoint is the last cave mouth or shop entered, defaulting to `ow_0_0`; death returns the player there with full health (this changes rule R8 only in the respawn room, flags are kept). `SaveGame.enabled` is false in tests and in `--dev-mode`, and `TestCase.reset_state()` keeps it so; a corrupted or newer file is ignored with a warning and kept as `save_1.bad`.
- **Check:** round trip of a rich state, version check, corrupted file, checkpoint respawn, nothing is written while disabled.

### F13. Title screen, menu and new-game flow (Sonnet)

- **Depends:** F10, F12. **Owns:** `scripts/ui/title.gd`, `scenes/ui/title.tscn`, `scripts/ui/menu_list.gd`, `project.godot` (main scene becomes the title; amends F12), `tests/test_title.gd`.
- **Deliverable:** the splash/title scene: the painted splash (section 11, fallback: a dark gradient with a drawn lamp glow) with the logo and a menu of three entries, New game, Continue, Quit, selected with the move keys and `confirm`. Continue is greyed out and skipped when `SaveGame.has_save()` is false. New game with an existing save asks once (Yes/No) before it erases the slot. New game sets `SaveGame.launch_mode = new`, plays the intro (F14) unless the flag `intro_seen` is set in a settings file (`user://settings.json`, so a second new game still lets the player skip with one press), then changes to `world.tscn`; Continue sets `continue` and changes scene; Quit calls `get_tree().quit()`. The title reuses the `overworld` music, ducked as usual. `--dev-mode`, `--start-room` and the capture tool skip the title. `make run` starts at the title.
- **Check:** menu navigation with every direction and wrap-around, Continue disabled without a save and enabled with one, overwrite prompt, scene changes (a test launches `world.tscn` and checks `GameState` was reset or loaded), capture of the title with and without a save.

### F14. Intro sequence (Sonnet)

- **Depends:** F13, D3. **Owns:** `scripts/ui/intro.gd`, `scenes/ui/intro.tscn`, `data/intro.json`, `tests/test_intro.gd`.
- **Deliverable:** the intro plays after New game: six full-screen stills (section 11) cross-fade; the text of each still appears line by line (about 0.04 s per character, a short pause between lines, a hold at the end of the still), taken from `data/intro.json`, which F14 builds from `docs/intro-script.md`; a still that is missing falls back to a dark gradient panel so the intro works before the art exists. **Skippable at any time**: any press of `confirm`, `attack`, `ui_accept` or Esc (`pause`) ends the intro at once and starts the game (the first press skips the whole intro, even while a line is still typing; there is no half-skip). Timing runs in `_physics_process`. No button help is shown; the skip hint exists only in the pause menu, which does not open during the intro. After the last still the intro fades to the world and sets `intro_seen`.
- **Check:** the intro ends by itself in a bounded time with no input; each of the skip keys ends it within one frame at the first, middle and last line; every still id in `data/intro.json` is one of the six of section 11; text lines equal the script (the test reads `docs/intro-script.md` when it exists); capture of three frames with the dark fallback.

### Wave 0 sizes

| WP | Model | Approx. files | Approx. lines (code and tests) |
|---|---|---|---|
| G1 | Sonnet | 2 | 600 |
| D1, D2, D3 | Haiku | 6 | 500 |
| F0 | Sonnet | 4 docs | 700 (text) |
| F1 | Sonnet | 6 | 900 |
| F2 | Sonnet | 6 | 600 |
| F3 | Sonnet | 3 | 700 |
| F4, F5 | Sonnet | 12 | 700 |
| F6 | Sonnet | 8 | 1100 |
| F7, F8 | Sonnet | 8 | 700 |
| F9, F10, F11 | Sonnet | 14 | 1300 |
| F12, F13, F14 | Sonnet | 12 | 1100 |
| **Total** | | **about 80** | **about 9500** |

---

## 6. Wave 1: parts (parallel; Haiku unless marked)

Every wave-1 WP depends only on foundation WPs and on `docs/monsters-bosses-tools.md`, because the pairs of tool and prop are coupled by the contracts of section 4, not by files. **Gate for the whole wave:** F0 to F7 merged (plus F5 for T02, F10 for T06). Standard files of a WP named `<n>`: `<script dir>/<n>.gd`, `<scene dir>/<n>.tscn`, `tests/test_<n>.gd` and `tests/fixtures/gallery/<WP>.tscn` (a one-screen room that shows the part in use for the capture), plus the `.uid` files that Godot makes. **Visual check** for all wave-1 WPs: `godot --path . res://tools/capture.tscn -- --fixture=res://tests/fixtures/gallery/<WP>.tscn --out=...` and a look at the picture (the agent reports what it saw, not just "ok").

### 6.1 Props (15)

Script dir `scripts/world/`, scene dir `scenes/world/`. Spec source: world-plan 1.3, 2.2 and 2.3 and the contract table of section 4.

| ID, model | Depends | Owns (besides the standard files) | Deliverable | Test |
|---|---|---|---|---|
| P01 Burnable, Haiku | F4 | `burnable.gd`; scenes `thorn_hedge`, `thorn_wall`, `thorn_door` | `Burnable` base (group `burnable`, `on_fire(pos)`, flag `burned_<id>`, opens when burned and stays open) and three scenes: a hedge that fills a 192 px gap, a wall, a door | fire hitbox opens it, flag persists after reload, plain hook does not |
| P02 EyeSwitch, Haiku | F4 | `eye_switch.gd`; scenes `eye_switch`, `eye_portcullis`, `eye_cell` | Group `eye_switch`; a `sling` hitbox flips it (flag `eye_<id>`); portcullis and cell open linked blockers | sling opens, hook does not, persistent |
| P03 Mooring, Haiku | F7 | `mooring.gd`; scene `mooring` | Post with `mooring_id`, `target_room`, `target_mooring`, `get_ride_path()` (an arc over water to the target's position, across a room edge if needed) | path ends on the target; a stand-in raft rides it |
| P04 PitZone, Haiku | F7 | `pit_zone.gd`; scenes `pit`, `ravine_leap` | Fall = 2 half-hearts and return to the last safe position of the room (tracked by the zone) unless `is_airborne()` | falls without leap, safe during a leap (stand-in airborne state) |
| P05 AnchorRing, Haiku | F7 | `anchor_ring.gd`; scenes `anchor_ring`, `anchor_pocket` | Group `anchor_ring`, `get_anchor_position()`, optional `max_range` | range and position queries |
| P06 Liftable and HeavyStone, Sonnet | F7 | `liftable.gd`, `heavy_stone.gd`; scenes `liftable_rock`, `heavy_stone`, `heavy_boulder`, `heavy_door`, `heavy_stones` | Small lift and throw (landing hitbox), heavy stones that only the mitts move (push or lift), openings flagged `moved_<id>` | stand-in mitts call `lift`/`try_move`; persistence |
| P07 Resonance, Haiku | F4 | `resonance_stone.gd`; scenes `resonance_stone`, `resonance_door`, `resonance_vault` | Group `resonant`, `on_chime()`, flag `resonated_<id>`, opens a door or vault | chime call opens, a hook swing does not |
| P08 HiddenSeam, Haiku | F4, F7 | `hidden_seam.gd`; scenes `hidden_seam`, `hidden_stairs`, `sealed_seam`, `hook_tap_wall` | Group `revealable`; invisible and non-interactive until `reveal()` (jar) or a hook tap (tap wall); reveal flag `revealed_<id>`; hidden stairs are a `RoomDoor` once revealed | reveal shows and enables; flag persists; `hide_again()` for the jar timeout does not hide permanent ones |
| P09 Grate, Haiku | F4 | `grate.gd`; scene `grate`; **amends** `scripts/items/tether_moth.gd`, `tests/test_tether_moth.gd` | Group `grate`; blocks the player, lets the moth's ray and carrier through; the key behind it is fetched by the moth | moth fetches a pickup behind the grate, player cannot walk in, old moth tests green |
| P10 BossDoor, Haiku | F4 | `boss_door.gd`; scene `boss_door` | Opens with `bigkey_cN` (flag `door_boss_<cave>`), consumes nothing, large lantern-lock look | closed without key, opens with, persists |
| P11 NinthDoor, Haiku | F4 | `ninth_door.gd`; scene `ninth_door` | Nine sockets each lit by `frag_cN`; opens with all nine (flag `door_ninth`) | 0, 8, 9 fragments |
| P12 WaxSeal, Haiku | F4 | `wax_seal.gd`; scene `wax_seal` | Only a charge-flare hitbox (`kind flare`) melts it | flare opens, hook does not |
| P13 Look variants, Haiku | F4 | `scripts/world/bush.gd`, `scripts/world/cracked_wall.gd` (a `variant` export; same behaviour); scenes `reed_cluster`, `rush_wall`, `moss_wall`, `dry_vine_screen`, `bush_cluster`, `brittle_rocks`; `tests/test_variants.gd` (instead of the standard test file) | Cut screens are `Bush` with a look, brittle rocks are `CrackedWall` with a rock look; every variant keeps the old tests green | each variant is cut or blasted like the original |
| P14 PocketDoor, Haiku | F2 | `pocket_door.gd` (`extends "res://scripts/world/room_door.gd"`); scene `pocket_door` with a `variant` export (stall, cart, lighthouse, mason, hut, grotto, stairs, plain) | A `RoomDoor` that looks like the named entrance; fade as the data says; the exit door inside the pocket is the same scene | enter and leave a stand-in pocket, spawn names `FromPocket` / `Inside` |
| P15 WardPlate, Sonnet | F7 | `ward_plate.gd`; scene `ward_plate` | A pad plus a linked opener: when the player stands on the pad with the ward up and N blockable shots are absorbed (signal `Hitbox.blocked`), a linked blocker opens (flag `ward_<id>`); the wave of shots comes from a placed shooter (a `watcher_eye`, `cinder_wisp` or `choirling` in the room, or the built-in `spore_post` of this WP for tests) | ward up opens, ward down does not, persistent |

### 6.2 Tools (8; specs are in the monster file, the tools section)

Script dir `scripts/items/`, scene dir `scenes/items/`. All extend `ItemBase`, are already registered by F10, need no `ItemRegistry` edit and no `player.gd` edit (they use the F7 API). Dev-mode loadout gets them automatically.

| ID, model | Depends | Owns (besides standard files) | Deliverable | Test |
|---|---|---|---|---|
| T01 `cinder_wick`, Haiku | F4 | `scripts/world/brazier.gd` (amends: also lights on `fire`) | Flame one tile ahead for 3 s, `Hitbox kind fire`, calls `on_fire` on `burnable` nodes in range, one flame at a time | burns a stand-in burnable, lights a brazier, limit of one |
| T02 `tallow_sling`, Haiku | F5 | - | Slug projectile, `Hitbox kind sling`, one on screen, costs one slug (`GameState.spend_slug()`), refuses with none | hits a stand-in eye switch, ammo spend and refusal |
| T03 `reed_raft`, Sonnet | F7 | - | At a `mooring`, rides the player along `get_ride_path()` to the target mooring using the motion API; refused away from a mooring | rides a stand-in mooring, crosses a room edge, cancelled on death |
| T04 `heft_mitts`, Sonnet | F7 | - | Lift a `liftable` in front, carry (speed scale, hook locked), throw; push or lift a `heavy` stone | lifts and throws a stand-in, carry blocks the hook, drops on damage |
| T05 `glow_jar`, Haiku | F4 | - | Thrown jar, `PointLight2D` radius 520 for 6 s, reveals `revealable` nodes in radius, one jar at a time | reveals a stand-in, hides again after 6 s, one at a time |
| T06 `lantern_chime`, Sonnet | F10 | `scripts/ui/warp_picker.gd`, `scenes/ui/warp_picker.tscn`, `tests/test_warp_picker.gd` | Tap rings the chime (calls `on_chime` on `resonant` nodes in radius); hold opens a warp list of cave mouths with flag `mouth_cN` and calls `World.warp_to` | tap resonates, hold lists only visited mouths, warp lands at the mouth room |
| T07 `skitter_boots`, Sonnet | F7 | - | Leap up to 2 tiles in the facing direction through the motion API (airborne, hurtbox off), clears pits and low rails, lands on the first free tile | crosses a pit zone, cannot land inside a wall, damage ignored in the air |
| T08 `reel_line`, Sonnet | F7 | - | Hook flies out on a line (`kind reel`), pulls the player to an `anchor_ring` in range and small pickups to the player | pulls to a stand-in ring, pulls a pickup, out-of-range line retracts |

### 6.3 Boss base and regular monsters (6)

Script dir `scripts/enemies/`, scene dir `scenes/enemies/`. Spec source: the monsters section of `docs/monsters-bosses-tools.md` (stats, behaviour, drops, the placeholder look to register). Every monster extends `EnemyBase`, sets stats in `_init()`, registers its placeholder kind and ships the test pattern of the worked example in `code-contract.md` section 12. Unit tests hold for any random roll.

| ID, model | Depends | Owns (besides standard files, per monster) | Deliverable | Test |
|---|---|---|---|---|
| M0 BossBase, Sonnet | F4 | `scripts/enemies/boss_base.gd`, `tests/test_boss_base.gd`, `scripts/combat/hitbox.gd`, `scripts/enemies/enemy_base.gd`, `scripts/enemies/enemy_projectile.gd`, `scripts/core/layers.gd` | `BossBase` (extends `EnemyBase`): phases, arena lock (closes the arena doors on first hit), flag `boss_<room>_defeated`, signal `defeated`, no drops except the placed rewards, optional health bar ring in the HUD canvas; miniboss mode (no arena lock) | phases advance, flag set on death, doors reopen on death or on player death/reset |
| M1 bramble_snapper, wickling, Haiku | F4 | monster files for both, projectile none | Snapper: rooted, snaps within about 1.5 tiles, `burnable` (group, `on_fire`), moth does not stun it. Wickling: pack of 2-3, dies in one hit | snaps in range, burns, pack count |
| M2 cinder_wisp, husk_hound, Haiku | F4 | both monsters, `scripts/enemies/flame_ring.gd` + scene if the monster file needs it | Wisp: drifts, bursts into a flame ring, ward blocks the burst. Hound: fast straight charges then circling | burst damage and ward block, charge and circle |
| M3 fen_leech, brine_crab, Haiku | F4 | both monsters, `scripts/world/shallow_zone.gd` + scene | Leech: lives in `shallows` zones, surfaces to lunge, hurt only when surfaced. Crab: sideways walker, front immune, back, flare or pot hurts | surfaced-only damage, front immunity |
| M4 watcher_eye, choirling, Haiku | F4 | both monsters and their beam and cone files named in the monster file | Eye: wall-mounted slow beam along row or column (ward blocks, sling kills). Choirling: floating singer with a cone (ward blocks, chime stuns) | beam blocked by ward, killed by a sling hitbox, cone shape |
| M5 mirror_shade, Sonnet | F4 | the monster | Mirrors Tamsin's facing beside her; under `glow_jar` light (a node in group `glow_light` within radius) it shows its real position | mirrors facing, reveal by a stand-in light |

---

## 7. Wave 2: regions, minibosses, bosses

### 7.1 Regions (R1 to R6)

A region WP has two kinds of session:

- **Batch sessions (Haiku)**, one per batch of table 7.1.1. A batch owns, for each room of the batch, `tools/rooms/<id>.room` and the generated `scenes/world/rooms/<id>.tscn`, and for each pocket of the batch `tools/rooms/<id>__<tag>.room` and `scenes/world/rooms/<id>__<tag>.tscn`. The room's source is written from the graph row (terrain, enemies, exits, gates, contents) and the rules of `docs/room-kit.md`; the compiler then writes the scene. The batch ends when `make rooms-check` accepts its files, the room loads, and a screenshot of each room has been looked at.
- **Lead session (Sonnet)**, one per region: owns `tests/test_area_<region>.gd` (five lines on `area_base.gd`) and the integration of the region: reads every batch result, fixes cross-room problems through the owning batch's files only after that batch is merged (the lead has its own files only until then), runs the area test and a short route test for the region's own gates with the items from the dev loadout.

**Pilot rule:** R1 (and C01 later) run first and alone; the lead reviews them and may amend F6/room-kit before the other batches start. Wave 2 starts when F0 to F9, F11 and the props and monsters named in the table are merged.

| WP, model | Depends | Region details | Extra owned files (lead) |
|---|---|---|---|
| R1 Brackwater Ford, Sonnet lead, Haiku batches | F6, F9, P01, P08, P13, P14 | 8 rooms: 6 existing (only `ow_2_0` gets the east exit with a thorn hedge and `ow_1_1` gets the south exit; `ow_0_0`, `ow_1_0`, `ow_0_1`, `ow_2_1` are not changed, their `.room` batch only verifies them against the graph); new rooms `ow_0_2` (hidden stairs to C9) and `ow_1_2` (Ford Road, reed wall, shop S1). Existing `ow_2_0.tscn` and `ow_1_1.tscn` are hand-edited by the batch that owns them. | `tests/test_area_brackwater.gd` |
| R2 Thornwood, Sonnet lead, Haiku batches | F6, F8, F9, P01, P02, P03, P09, P13, P14, M1 | 15 rooms, 5 pockets (shop S2 by bomb wall, cache, grate alcove with the overworld key, thorn-sealed hut with a wick core, pot bag P1); thorn hedges at both ends of the Brackwater border; the Eyegate (eye-switch portcullis); the Drop Ledge | `tests/test_area_thornwood.gd` |
| R3 Cinderflats, Sonnet lead, Haiku batches | F6, F9, P02, P05, P06, P08, P12, P14, P15, M2 | 14 rooms, 6 pockets (1 of them the ward cache from G1); wax seal, hook-tap wall, hidden stairs to C7, heavy stones, anchor ledge, kiln hut with the key door | `tests/test_area_cinderflats.gd` |
| R4 Tallowfen and Mirrormere, Sonnet lead, Haiku batches | F6, F8, F9, P03, P13, M3 | 24 rooms (12 lake rooms with 18+ moorings), 4 pockets; the lake rooms use the water tile layout of the dev pond (collision rectangles unchanged) and the mooring pairs of the graph; `shallows` zones for the leeches | `tests/test_area_tallowfen.gd` |
| R5 Gravelight Heights, Sonnet lead, Haiku batches | F6, F8, F9, P03, P04, P06, P14, P15, M4 | 15 rooms, 3 pockets (1 of them the ward cache from G1); ravine leaps (arrival side props), heavy boulder before C6, the Dockside drop landing | `tests/test_area_gravelight.gd` |
| R6 Hushmarch, Sonnet lead, Haiku batches | F6, F9, P04, P05, P07, P08, P11, P14, M2, M3 | 12 rooms, 4 pockets; anchor beach, resonance door to C8, sealed seam, the Ninth Door | `tests/test_area_hushmarch.gd` |

#### 7.1.1 Room batches (Haiku, at most 4 rooms; generated from the graph; pockets travel with their room)

Rooms are listed by id. Pockets after `+` are separate scenes; "in-place" pockets are sealed spots inside the room's own scene. The ward caches that G1 adds are assigned by the lead to the batch of their room (a batch grows by one scene).

| Batch | Rooms | Pockets | Room ids |
|---|---|---|---|
| R1.a | 4 rooms | 0 | `ow_0_0`, `ow_0_1`, `ow_1_0`, `ow_1_1` |
| R1.b | 4 rooms | 1 | `ow_2_0 (in-place #cache)`, `ow_2_1 (in-place #closet)`, `ow_0_2`, `ow_1_2 +#shop` |
| R2.a | 4 rooms | 1 | `ow_3_0`, `ow_3_1`, `ow_4_0`, `ow_4_1 +#cache` |
| R2.b | 4 rooms | 1 | `ow_5_0`, `ow_5_1`, `ow_6_0 +#shop`, `ow_6_1` |
| R2.c | 4 rooms | 2 | `ow_7_0`, `ow_7_1`, `ow_3_2 +#grate`, `ow_3_3 +#hut` |
| R2.d | 3 rooms | 1 | `ow_4_2`, `ow_5_2`, `ow_7_2 +#bag` |
| R3.a | 4 rooms | 3 | `ow_8_0 +#cache`, `ow_8_1`, `ow_9_0 +#cache`, `ow_9_1 +#ward` |
| R3.b | 4 rooms | 1 | `ow_10_0`, `ow_10_1 +#hut`, `ow_11_1`, `ow_8_2` |
| R3.c | 4 rooms | 1 | `ow_9_2`, `ow_9_3`, `ow_10_2`, `ow_10_3 +#shop` |
| R3.d | 2 rooms | 1 | `ow_11_2 +#cache`, `ow_10_4` |
| R4.a | 4 rooms | 0 | `ow_0_3`, `ow_1_3`, `ow_4_3`, `ow_5_3` |
| R4.b | 4 rooms | 1 | `ow_6_2`, `ow_6_3`, `ow_7_3 +#grotto`, `ow_0_4` |
| R4.c | 4 rooms | 1 | `ow_0_5`, `ow_1_4`, `ow_1_5 +#cache`, `ow_2_4` |
| R4.d | 4 rooms | 0 | `ow_2_5`, `ow_3_5`, `ow_4_4`, `ow_4_5` |
| R4.e | 4 rooms | 2 | `ow_5_4`, `ow_5_5 +#cache`, `ow_6_4`, `ow_6_5 +#shop` |
| R4.f | 4 rooms | 0 | `ow_7_4`, `ow_1_6`, `ow_2_6`, `ow_2_7` |
| R5.a | 4 rooms | 1 | `ow_8_4`, `ow_8_5 +#ward`, `ow_9_4`, `ow_9_5` |
| R5.b | 4 rooms | 0 | `ow_3_7`, `ow_4_6`, `ow_4_7`, `ow_5_6` |
| R5.c | 4 rooms | 1 | `ow_5_7 +#shop`, `ow_6_6`, `ow_7_6`, `ow_7_7` |
| R5.d | 3 rooms | 1 | `ow_8_6`, `ow_4_8 +#cache`, `ow_5_8` |
| R6.a | 4 rooms | 0 | `ow_10_5`, `ow_11_5`, `ow_8_7`, `ow_9_6` |
| R6.b | 4 rooms | 2 | `ow_9_7`, `ow_10_6`, `ow_10_7 +#shop`, `ow_11_6 +#cache` |
| R6.c | 4 rooms | 2 | `ow_11_7 +#cache`, `ow_8_8 +#cache`, `ow_9_8`, `ow_10_8` |

### 7.2 Minibosses (5 pair WPs)

Script dir `scripts/enemies/minibosses/`, scene dir `scenes/enemies/minibosses/`. Spec source: the miniboss section of `docs/monsters-bosses-tools.md`. Each miniboss extends `BossBase` in miniboss mode (no arena lock).

| ID, model | Depends | Owns (per monster: script, scene, `tests/test_<name>.gd`, gallery fixture) | Notes | Test |
|---|---|---|---|---|
| MB1 `hollow_captain`, `thorn_warden`, Haiku | M0, M1, P01 | the four files each | captain: raised ward, hit from the side; warden: stunned by the moth, cut with the hook | side hit damages, front is blocked; stun then hook |
| MB2 `sump_lurker`, `lull_mauler`, Haiku | M0, M3, P06 | same | lurker: surfaces to bite in a cistern (shallows); mauler: throws slag chunks (liftable) back with the mitts | surfaced-only damage; a thrown chunk hurts |
| MB3 `mirror_warden`, `choir_warden`, Haiku | M0, M4, M5 | same | warden among copies (jar shows the real one); choir warden: wall of sound, strike when the note ends | real one hurt only; ward blocks the wall |
| MB4 `pale_squire`, `abacus_brute`, Sonnet | M0, T07, T08, P04, P05 | same | squire lunges across pits (boots); brute: reel line pulls the shield rail off | lunge, rail pull |
| MB5 `wick_automaton`, `corrows_echo`, Sonnet | M0, T06 | same | automaton: stun then pots; echo: dodge, chime, strike | stun then pot damage; chime opening |

### 7.3 Bosses (10, Sonnet each)

One WP per boss. Spec source: the boss section of `docs/monsters-bosses-tools.md` (phases, weakness, numbers, reward). All extend `BossBase`.

Files per boss `<name>` (all inside the WP): `scripts/enemies/bosses/<name>.gd`, `scenes/enemies/bosses/<name>.tscn`, `scenes/bosses/<name>_arena.tscn` (only when the fight needs arena props such as pits, pools or pillars; the cave WP instances it in the boss room's `Props`), `tests/test_boss_<name>.gd`, `tests/fixtures/gallery/B<nn>.tscn`.

| ID | Boss | Cave | Depends | Weakness tool | Test (beyond phases and flags) | Visual check |
|---|---|---|---|---|---|---|
| B01 | `kilnkeeper` | C1 | M0, T01, M1 | cinder wick melts the wax armour, then the hook | armour melts only under fire, dies after hook | capture of the arena at each phase |
| B02 | `briar_mother` | C2 | M0, T02, M1 | sling reaches the seed-eyes | eyes only by sling, slug refill works | capture with the three seed-eyes |
| B03 | `tidewick` | C3 | M0, T03, P03 | raft: fight from a mooring raft, strike the glowing tail | tail hit from a raft only | capture of the basin |
| B04 | `hushed_colossus` | C4 | M0, T04, P06 | lift and throw falling shards | thrown shard damages in each phase | capture of the three phases |
| B05 | `archivist` | C5 | M0, T05, P08, M5 | the real copy casts a shadow under the jar | copies die to nothing, real one under light | capture lit and unlit |
| B06 | `dirge_choir` | C6 | M0, T06, M4, P07 | answer each head with the chime, then strike | stun on chime, damage after | capture of three heads |
| B07 | `gloam_knight` | C7 | M0, T07, P04 | pit-ringed floor, follow with the boots | cannot be reached without leaps | capture of the pit ring |
| B08 | `coinwyrm` | C8 | M0, T08, P05 | reel line pulls the coin plates, then the hook | plates only by reel, then hook | capture with plates on and off |
| B09 | `lock_warden` | C9 | M0, T02, existing pot | sling opens its eyes, pots break the plates | needs both, ammo refill present | capture of the lock |
| B10 | `the_unlit` | C10 | M0, T01, T02, T08 | phase 1 sling, phase 2 cinder wick, phase 3 reel the lantern loose | phase order is forced; flag `boss_cave_10_14_defeated` | capture of all three phases |

Each boss test fights in a bare arena built by the test, with the real tool if its WP is merged and a hitbox of the right `kind` otherwise. Q7 repeats the fights with the real tools.

---

## 8. Wave 3: caves and the ending

### 8.1 Caves (C01 to C10)

Same shape as the regions: Haiku batch sessions (table 8.1.1, at most 4 rooms) and one Sonnet lead per cave. The lead owns `tests/test_area_cave_<n>.gd` (area base) and `tests/test_route_cave_<n>.gd`, a scripted route like `tests/test_dev_world_route.gd`: enter at the mouth, take the cave's small keys through the gates in graph order, get the tool, use it on the gate it is placed for, beat the miniboss (scripted damage) and the boss with its weakness tool, take the big key, open the boss door and take the fragment and wick core. **Wave 3 starts for a cave when** F0 to F12, the cave's boss (Bnn), its miniboss pair, the props and monsters named below, and the region that holds its mouth (for the spawn markers) are merged; C01 is the pilot and runs first.

Room details come from world-plan section 4 (cave table of rooms) and the graph; a batch never invents gates. The lead places the boss arena fragment (`scenes/bosses/<name>_arena.tscn`) in the boss room and the reward pickups with `requires_flag = boss_<room>_defeated`; the big key sits in its own room as in the graph. Cave rooms are dark; `dark = true` comes from the data.

| WP, model | Depends (besides F0 to F12 and the batch tool F6) | Cave-specific content |
|---|---|---|
| C01 The Wick Cellar | B01, MB1, M1, P09, P10, P13 | existing `cave_1.tscn` is hand-edited by batch C01.a: exits E and W added, the two braziers may move one tile; the alcove stays in place; key (scope `c1`) behind a grate; `cave_1_6#crack` cache. Pilot. |
| C02 The Briar Hollow | B02, MB1, M1, P01, P02, P10 | thorn wall, eye-switch portcullis, 2 locked doors (scope `c2`) |
| C03 The Drowned Wick Works | B03, MB2, M1, M3, P03, P10, P13 | moss wall (cut), flooded passages (2 raft), leech shallows; mouth is a bomb wall (brittle rocks) |
| C04 The Sleeping Foundry | B04, MB2, M2, P02, P06, P10, P12 | eye switch, heavy stone, wax seal pocket `cave_4_7#seal` |
| C05 The Mirrored Archive | B05, MB3, M1, M5, P08, P10, P13 | dry vine screen, hidden seam, mirror shades |
| C06 The Choir Vault | B06, MB3, M4, P06, P07, P08, P10, P15 | resonance stone, heavy door, hidden seam, crypt pocket, one ward cache from G1; mouth is a heavy boulder |
| C07 The Hall of Nerve | B07, MB4, P04, P08 (mouth stairs are in R3), P10 | pits |
| C08 The Counting House | B08, MB4, M1, M3, P02, P04, P05, P10 | eye switch, anchor ring, pit, brine crabs; mouth is the resonance door in R6 |
| C09 Corrow's Undercroft | B09, MB5, M1, M3, P01, P02, P03, P04, P05, P06, P07, P10 | the cave that uses every tool: thorn wall, flooded passage, pit, anchor ring, heavy stone, eye-switch cell, resonance vault; no lantern, the ninth fragment |
| C10 The Ninth Hollow | B10, MB5, all M1 to M5, P01 to P07, P10, P15, E1 | 14 rooms, three small keys, one ward cache from G1, the final arena `cave_10_14`; opens only with nine fragments (P11 in R6) |

#### 8.1.1 Cave room batches (Haiku, at most 4 rooms)

| Batch | Rooms | Pockets | Room ids |
|---|---|---|---|
| C01.a | 4 rooms | 0 | `cave_1 (in-place #alcove)`, `cave_1_2`, `cave_1_3`, `cave_1_4` |
| C01.b | 4 rooms | 1 | `cave_1_5`, `cave_1_6 +#crack`, `cave_1_7`, `cave_1_8` |
| C02.a | 4 rooms | 0 | `cave_2_1`, `cave_2_2`, `cave_2_3`, `cave_2_4` |
| C02.b | 4 rooms | 0 | `cave_2_5`, `cave_2_6`, `cave_2_7`, `cave_2_8` |
| C02.c | 1 rooms | 0 | `cave_2_9` |
| C03.a | 4 rooms | 0 | `cave_3_1`, `cave_3_2`, `cave_3_3`, `cave_3_4` |
| C03.b | 4 rooms | 0 | `cave_3_5`, `cave_3_6`, `cave_3_7`, `cave_3_8` |
| C03.c | 1 rooms | 0 | `cave_3_9` |
| C04.a | 4 rooms | 0 | `cave_4_1`, `cave_4_2`, `cave_4_3`, `cave_4_4` |
| C04.b | 4 rooms | 1 | `cave_4_5`, `cave_4_6`, `cave_4_7 +#seal`, `cave_4_8` |
| C04.c | 2 rooms | 0 | `cave_4_9`, `cave_4_10` |
| C05.a | 4 rooms | 0 | `cave_5_1`, `cave_5_2`, `cave_5_3`, `cave_5_4` |
| C05.b | 4 rooms | 0 | `cave_5_5`, `cave_5_6`, `cave_5_7`, `cave_5_8` |
| C05.c | 2 rooms | 0 | `cave_5_9`, `cave_5_10` |
| C06.a | 4 rooms | 0 | `cave_6_1`, `cave_6_2`, `cave_6_3`, `cave_6_4` |
| C06.b | 4 rooms | 1 | `cave_6_5`, `cave_6_6`, `cave_6_7`, `cave_6_8 +#ward` |
| C06.c | 3 rooms | 1 | `cave_6_9 +#crypt`, `cave_6_10`, `cave_6_11` |
| C07.a | 4 rooms | 0 | `cave_7_1`, `cave_7_2`, `cave_7_3`, `cave_7_4` |
| C07.b | 4 rooms | 0 | `cave_7_5`, `cave_7_6`, `cave_7_7`, `cave_7_8` |
| C07.c | 3 rooms | 0 | `cave_7_9`, `cave_7_10`, `cave_7_11` |
| C08.a | 4 rooms | 0 | `cave_8_1`, `cave_8_2`, `cave_8_3`, `cave_8_4` |
| C08.b | 4 rooms | 0 | `cave_8_5`, `cave_8_6`, `cave_8_7`, `cave_8_8` |
| C08.c | 4 rooms | 0 | `cave_8_9`, `cave_8_10`, `cave_8_11`, `cave_8_12` |
| C09.a | 4 rooms | 1 | `cave_9_1`, `cave_9_2 +#cell`, `cave_9_3`, `cave_9_4` |
| C09.b | 4 rooms | 0 | `cave_9_5`, `cave_9_6`, `cave_9_7`, `cave_9_8` |
| C09.c | 2 rooms | 1 | `cave_9_9 +#vault`, `cave_9_10` |
| C10.a | 4 rooms | 0 | `cave_10_1`, `cave_10_2`, `cave_10_3`, `cave_10_4` |
| C10.b | 4 rooms | 0 | `cave_10_5`, `cave_10_6`, `cave_10_7`, `cave_10_8` |
| C10.c | 4 rooms | 1 | `cave_10_9`, `cave_10_10 +#ward`, `cave_10_11`, `cave_10_12` |
| C10.d | 2 rooms | 0 | `cave_10_13`, `cave_10_14` |

### 8.2 E1. The ending (Sonnet)

- **Depends:** B10, F13, F14, F12. **Owns:** `scripts/ui/ending.gd`, `scenes/ui/ending.tscn`, `scripts/world/ending_trigger.gd`, `scenes/world/ending_trigger.tscn`, `data/ending.json`, `tests/test_ending.gd`.
- **Deliverable:** after the Unlit dies (flag `boss_cave_10_14_defeated`) and not before (decision 12), the trigger in `cave_10_14` starts the choice from `story.md`: two lit lanterns on pedestals, Corrow half wax in the middle; walking into one and confirming chooses (rekindle the last lantern, or become the Wickwarden and put it out). No text during the choice (the world rule); each ending is a short sequence of the intro's style (stills with line-by-line text, skippable), then the credits card and a return to the title. The ending is saved: after it the save is marked `completed`, Continue still loads the last checkpoint. Stills for the endings are in section 11. Text lines are in `data/ending.json` written from `docs/story.md`.
- **Check:** both endings reachable in a test; the trigger is inert before the flag; skip works; return to the title; a capture of the two pedestals.

---

## 9. Wave 4: integration and QA

All run after the whole content is merged (waves 2 and 3), `make check` green, `tests/test_world_graph.gd` printing an empty pending list.

| ID, model | Depends | Owns | Deliverable | Check |
|---|---|---|---|---|
| Q1 Scene-graph solver test, Sonnet | F3, all R, all C | `tools/extract_scene_graph.gd` (headless script), `tests/test_scene_solver.gd` | Builds a graph from the built game (rooms from scenes: exits, gate props found in the scene, locked doors with scopes, pickups with persistent ids, boss doors, mouths) in the format of `world-graph.json`, writes it to `user://scene-graph.json`, runs `python3 tools/check_world_graph.py` on it and requires exit 0 and the same node, edge and capability sets as `data/world_data.json` (no second solver to keep in sync). Mutation test: a copy with one prop removed fails | passes; the mutation is rejected |
| Q2 Strict completeness and layout, Sonnet | F3, all R, all C | `tests/test_world_complete.gd`, `tests/test_layout_all.gd` | Every node of the data has a scene (no pending), no scene without a node, ids unique in the whole world; the area checks for every area (exits clear, nothing on obstacles, hollows on grid, sealed spots, reachability) across all 218 scenes, run in four shards inside the timeout header | passes; a stray room scene fails |
| Q3 Playthrough smoke test, Sonnet | Q1, all tools, E1, F12 | `tests/test_playthrough_1.gd` .. `_4.gd` (shards: A start to C2; C3 to C5 and the lake; C6 to C9; C10 and both endings), `tools/playthrough_route.py` (reads `check_world_graph.py --rounds` and writes the route list `data/playthrough_route.json`) | A bot follows the route of the unlock rounds in the recommended cave order: warps next to each target (as the dev route test does), performs the unlock (use tool at the gate, spend key, place pot, light brazier), collects pickups, defeats the miniboss and boss through their weakness (real hitboxes of the real tools), takes the fragment and ends in the final arena; each shard has a `timeout` header and saves and reloads once in the middle to check persistence | all four shards pass; the total simulated play time is printed |
| Q4 Capture of every room, Haiku | F2, all R, all C | `tools/capture_all.gd` (+ `.tscn`), `docs/screens/step3/contact-<area>.png` (16 contact sheets) | `make capture-all` renders every room and pocket at 1920x1080 into the untracked `build/screens/<id>.png` and a contact sheet per area (6 + 10 sheets, 480x270 thumbnails, labelled with ids); only the sheets are committed | 218 images exist; the sheets list every id once |
| Q5 Visual review, Haiku (16 small sessions) | Q4 | `docs/screens/step3/review-<area>.txt` (16 files) | One agent per area looks at the full-size captures and the sheet and lists problems per room: props overlapping, exits blocked, gate prop missing or unreadable, wrong terrain, unlit cave rooms with nothing to see, enemies on walls. It reads, never fixes | every room has a line; the lead triages into fix WPs of Z1 |
| Q6 Soak and economy, Haiku | Q2 | `tests/test_soak_<area>.gd` (16 small files from one template), `tests/test_economy_budget.gd` | A 5 s soak per room (as `test_dev_world`: enemies stay inside, nothing clips) and a count of placed pickups, wick cores, keys, caches, shops and enemies against world-plan 6.1 | all pass; the budget test lists the totals |
| Q7 Tool and gate matrix, Sonnet | all T, all P, MB, B | `tests/test_tool_matrix.gd` | Every tool against every gate prop it must open and every prop it must not open, with the real classes (replaces the stand-ins of wave 1), and every boss and miniboss against the real weakness tool | matrix printed, all expectations hold |
| Q8 Performance and memory, Sonnet | F2, Q4 | `tests/test_streaming.gd`, `tools/perf_walk.gd` | Walks a 300-room loop; checks that the node count and memory plateau, room load time stays under a budget (default 50 ms per room on the CI machine), no orphan nodes at exit | plateau reached; budget printed |
| Q9 Documentation, Haiku | Q1 to Q8 | `docs/state.md`, `README.md`, `docs/screens/step3/README.txt` | state after the build (counts, tests, known issues from the reviews), controls and commands, pointer to this plan as done | links resolve; test count correct |

## 10. Wave 5: playtest rounds and release (lead-driven, rolling)

| ID, model | Owns | Deliverable |
|---|---|---|
| Z1 Fix rounds, Sonnet or Haiku per ticket | files named in each ticket (one ticket, one owner; tickets come from Q5/Q6/Q7, the playthrough and human play) | Each ticket is a small WP with its own `Owns` list; merged one by one |
| Z2 Tuning, Haiku | `data/shop_prices.json`, constants named in the code contract (wallet and ammo drop rates, `slug_max`), never core logic | Prices and drop rates as the user decides in playtests (decision 7) |
| Z3 Release candidate, Sonnet | `docs/state.md` (amends Q9), `export_presets.cfg` if wanted | `make check`, `make world-check`, `make playthrough`, version tag; the export filter for `data/*.json` (open question 6) |

---

## 11. Art and audio needs for the new parts (for the art inventory)

Everything in this build uses placeholder art through `Placeholder` and `SpriteVisual` fallbacks. The painted art is a separate pass. This build asks for these images now, because the title and intro are story screens:

| Image | Size | Use | Brief |
|---|---|---|---|
| `title_splash` | 1920x1080 | title background | The valley of Vey at dusk; a fallen lantern's glow on the horizon; Tamsin as a small silhouette with the lamp hook; open sky in the upper third for the logo; painterly, strong light against deep dusk (art-brief style). |
| `title_logo` | about 1400x420, transparent | title logo | "Wickwarden" as a hand-lettered brass-and-wax wordmark with a lit wick in it. |
| `intro_01_lanterns` | 1920x1080 | intro still 1 | The Nine Lanterns drifting over the valley at golden hour, a village under them. |
| `intro_02_lanternfall` | 1920x1080 | intro still 2 | The Lanternfall: lanterns falling and burning into the ground, craters glowing. |
| `intro_03_dusk` | 1920x1080 | intro still 3 | The slow dusk; wax-and-shadow Hush shapes gathering at the edge of Brackwater Ford. |
| `intro_04_tamsin` | 1920x1080 | intro still 4 | Tamsin lighting the street lamps of Brackwater Ford. |
| `intro_05_hook` | 1920x1080 | intro still 5 | Corrow's empty tower stair with the lamp hook and the lamp that will not go out. |
| `intro_06_setout` | 1920x1080 | intro still 6 | Tamsin on the village path with hook and lamp, a cave mouth glowing ahead. |
| `ending_a_rekindle`, `ending_b_dawn` | 1920x1080 | two ending stills (E1) | The last lantern rekindled over a warm valley; the lantern put out and a real dawn on the shore. |

File names are final (`assets/art/<name>.png`, one pass of the cut tool is not needed: stills are used as they are). The intro script `docs/intro-script.md` (D3) carries one brief per intro still and wins over this table if they differ. `art-provenance.md` must list each image when it arrives. UI frames for the item subscreen (slot frame, silhouettes) are optional: F10 draws them with shapes.

New entities (9 monsters, 10 minibosses, 10 bosses, 8 tools and their projectiles, 15 prop families, terrain for the lake, cinder, gravel, march and caves) need painted sprites in the step-3 art pass; their kinds and names are those of `docs/monsters-bosses-tools.md` and of the prop table in section 6.1. Audio: no new sounds are required; the art-and-audio pass may add sounds for the new tools and bosses later.

---

## 12. Dependency graph and waves

```
Wave 0   G1 -> D1 ----------------------------------+
         G1 -> F0 -> F1 -> F2 -> F3 -> F4 -> F5 -> F6 -> F7 -> F8 -> F9 -> F10 -> F11 -> F12 -> F13 -> F14
         D2 (after this doc), D3 (any time, needed by F14)

Wave 1   (gates: F0..F7)
   props P01..P15      tools T01..T08       boss base M0 / monsters M1..M5
   (T06 also needs F10; T02 needs F5; P03/P04/P05/P06/P08/P15/T03/T04/T07/T08 need F7)

Wave 2
   R1 -> (pilot review) -> R2..R6     needs: F6 F9 + props/monsters of the region
   MB1..MB5                           needs: M0 + monsters/tools named
   B01..B10                           needs: M0 + weakness tool + props named

Wave 3
   C01 (pilot) -> C02..C10            needs: boss Bnn + miniboss + props + region mouth
   E1                                 needs: B10, F12..F14

Wave 4   Q1 Q2 -> Q3 ;  Q4 -> Q5 ;  Q2 -> Q6 ;  Q7 Q8 ;  Q9 last
Wave 5   Z1 Z2 Z3
```

Critical path: G1, F0 to F14 (about 15 sequential sessions), then the longest chain of wave 1 to 3: F7 (motion API), T08 reel line, B08/B10, C10, Q1, Q3. Everything else fits beside it. A cave never waits for another cave; a region never waits for another region (after the pilot).

Fine-grained gates matter more than the wave numbers: the lead starts a WP as soon as every WP in its `Depends` column is merged. Each wave's header names its gates.

### Sizes

| Wave | WPs | Sessions | New or changed files (about) | Lines written by hand (about) | Generated lines | Wall clock with the lead merging (about) |
|---|---|---|---|---|---|---|
| 0 | 19 | 19 | 80 | 9,500 | 0.5k (data) | 2 to 3 days (sequential: 15 Sonnet sessions of 1 to 3 h) |
| 1 | 29 | 29 | 190 | 7,500 | 0 | half a day with 10 agents in parallel |
| 2 | 21 | 44 | 120 sources (`.room`, boss and miniboss files, tests) and 100 generated scenes | 4,500 (room sources) + 8,000 (monsters, bosses, tests) | 30,000 (scenes) | one day |
| 3 | 11 | 41 | 150 sources and 130 generated scenes | 8,000 (room sources) + 3,000 (route tests, ending) | 40,000 (scenes) | one day |
| 4 | 9 | 25 | 60 | 2,500 | 0 | half a day plus the long test runs |
| 5 | 3 | rolling | rolling | rolling | 0 | until the user is satisfied |

Token cost grows with Sonnet sessions: foundation (19) and bosses/leads (about 40) dominate; the 120 or so Haiku sessions are cheap and independent.

---

## 13. Rules for Haiku worktree agents (they cannot run git; the lead commits and merges)

1. **One worktree per WP (and per batch).** The lead runs `git worktree add ../ww-<wp> -b wp/<wp> main`, then `make import` once in that worktree, and starts the agent there with the WP row, its inputs and the file list. Agents never share a worktree and never run `make import` again; WP files declare no `class_name` so no re-import is needed.
2. **The agent may run:** `make test T="..."`, `make lint`, `make rooms` / `make rooms-check` (room batches), `python3 tools/check_ownership.py <WP>` (reads the file list from stdin), and the capture tool. It may not run git, push, or edit outside its `Owns` list.
3. **The agent reports:** every file touched (the lead feeds the list to `check_ownership.py`), the test output, one sentence per screenshot of what it saw, and any spec doubt. A report without a visual check is sent back.
4. **Two strikes.** A Haiku WP that fails its own check twice goes to Sonnet with the failing output, not a third Haiku attempt.
5. **Room batches** write only `.room` sources and let the compiler produce scenes. They never hand-edit a generated `.tscn`. The only hand edits are the three existing scenes `ow_2_0`, `ow_1_1` and `cave_1` (their batches say so).
6. **Lead steps per WP:** run `check_ownership.py`; `git add` only the owned files; commit (`WP <id>: <title>`, no AI attribution lines); merge to `main` in the order of section 14; run `make check` on `main`; delete the worktree (`git worktree remove`).

## 14. Merge order and conflict avoidance

- **Merge order inside a wave:** foundation: strictly F-order. Wave 1: P (smallest first, P09 and P13 early because they amend existing files), then M0, then T, then M1 to M5. Wave 2: R1 first (pilot), then bosses and minibosses (they only add files), then R2 to R6. Wave 3: C01 first, then C02 to C10, then E1. Wave 4: Q1, Q2, then the rest.
- **File conflicts are removed by construction:**
  - one file per room (`.room` source and generated `.tscn`), 218 rooms, no shared room file; area tests are one per area;
  - one scene and one script per entity; `ItemRegistry` is filled once by F10; `Placeholder.KINDS` is not touched (runtime `register_kind`); `project.godot` and `Makefile` are edited by foundation WPs only; `tools/make_audio.py` by none;
  - core files with a single named owner per wave: `world.gd` (F2, F4, F8, F10, F12 sequentially), `player.gd` (F7), `hud.gd` (F11), `game_state.gd` (F4, F5, F10 sequentially), `brazier.gd` (T01), `tether_moth.gd` (P09), `bush.gd` and `cracked_wall.gd` (P13);
  - generated files (`data/world_data.json`, `scenes/world/rooms/*.tscn` that have a `.room` source) are never merged by hand: on any conflict the lead re-runs `make world-data` / `make rooms`;
  - `.uid` files belong to the WP of their script and are regenerated if they conflict;
  - docs are lead-only except where a WP owns one (D1, D3, F0, F6, Q9).
- **Gates between waves:** `make check` and `make world-check` green on `main`, the ownership check clean, a git tag `wave-<n>`.
- The lead keeps `tools/wp_ownership.json` in step when a batch is split or merged.

## 15. Open questions

1. **Room kit (F6).** Do you accept a small `.room` compiler for the 218 room scenes? Without it every room is a hand-written `.tscn` (step 1 style), batches shrink to 3 rooms and the validator is only the area test. Recommended: accept.
2. **Pockets.** The plan treats the three existing sealed spots as in-place and every other pocket (30 with G1) as its own scene. Is that the policy you want, or should cave caches be in-place sealed spots too?
3. **Ward puzzles (G1).** Four optional ward caches are proposed (Cinderflats, Gravelight, C06, C10). Should some ward puzzle be on the main path instead? That changes the graph rounds.
4. **Sling ammo.** The monster file fixes 30 slugs, 12 on first pickup, bundle +6, drop 8 %. Open: whether a pot bag also raises the slug limit, and the refill rule at the three sling boss fights and eye-switch gates (G1 proposes a slug bundle near each).
5. **Save details.** One slot is planned, autosave on room entry, respawn at the last cave mouth or shop (not always the start room). Do you want several slots, a manual save, or the original rule of always respawning at `ow_0_0`?
6. **JSON in exports.** `data/world_data.json`, `data/intro.json`, `data/shop_prices.json` need an export filter (`*.json`) in `export_presets.cfg`; no export preset exists yet. Z3 adds it unless you prefer generated `.gd` constants.
7. **Screenshots in git.** 218 full-size screenshots would be about 300 MB. The plan commits only 16 contact sheets and keeps the rest in `build/` (untracked). Acceptable?
8. **Streaming policy.** Current room plus the rooms it can slide into stay loaded (F2). Pocket scenes load on entry. Is a short load hitch at a cave warp acceptable?
9. **Item subscreen controls.** `item_menu` is bound to Tab and the gamepad Select/Back; is that the key you want? It conflicts with nothing in the current input map.
10. **Intro.** Skip hint: the intro never shows button help (the rule). A first-time player learns that it can be skipped only from the pause menu, which does not open during the intro. Accept, or show a tiny "skip" mark in the corner?
11. **Ending presentation.** The choice has no text in the world; are two lanterns on pedestals with Corrow between them clear enough, and do you want credits?
12. **Monster file alignment.** The groups M1 to M5 and MB1 to MB5 follow my reading of which monsters share mechanics. If `docs/monsters-bosses-tools.md` names other shared systems (for example a shared projectile or a beam helper), the lead moves the files to the right group before wave 1 starts.
13. **Quit to title.** The pause menu has no selectable items. Do you want "Quit to title" there?
14. **Per-suite timeouts.** F3 allows `## timeout=<s>` for long suites. The playthrough shards need it; is a CI limit of a few minutes per suite fine?
