# Wickwarden — step 1: dev world plan

The goal of step 1 is a small, playable dev world that gives the feel of the game: top-down
movement, the lamp hook, sub-items, flip-screen rooms and five monster types. Art is
placeholder in step 1. Step 2 replaces it with high-detail GPT Image art (see the last section).

> World build note: this file is the step-1 plan and keeps its numbers. The full game is planned in
> [world-plan.md](world-plan.md), split into work packages in [world-work-packages.md](world-work-packages.md),
> and contracted in [code-contract.md](code-contract.md) section 16. The owner's decisions are in
> [decisions.md](decisions.md). Where a note below points elsewhere, that document is the current rule.

## 1. Engine and format

- Godot 4.7, GDScript only. Run with `godot --path .`.
- Window 1920×1080, stretch mode `canvas_items`, aspect `keep`.
- Grid: **96 px tiles**. One room is **20×10 tiles = 1920×960 px**.
- A **HUD band of 120 px** is at the top of the screen. The room fills the rest (y 120–1080).
- View: three-quarter top-down. Characters use four facings: down, up, left, right.
- Physics: `CharacterBody2D` with `motion_mode = MOTION_MODE_FLOATING`. Use `y_sort_enabled`
  on the room entity layer.
- Movement and combat logic goes in `_physics_process`.

## 2. World layout (dev world)

Overworld grid of 3×2 rooms plus one cave interior.

| Room id | Grid | Contents |
|---|---|---|
| `ow_0_0` | (0,0) | Start. Village edge, a sign post (no text in step 1), 2 Spitcaps. |
| `ow_1_0` | (1,0) | Open field with rocks and bushes. 3 Skitterwicks. |
| `ow_2_0` | (2,0) | Ruin with a **cracked wall** (opens with a pitch pot) to a secret heart cache. 2 Hollows. |
| `ow_0_1` | (0,1) | Pond and reeds. 4 Duskmoths. The **tether moth** item lies here on a pedestal. |
| `ow_1_1` | (1,1) | Crossroads. 2 Tallow blobs, 1 Spitcap. A **cave entrance**. |
| `ow_2_1` | (2,1) | Dead end with a **locked door** (needs 1 key) to the pitch pot item. |
| `cave_1` | interior | Dark cave. Two **unlit braziers**; lighting both with the lamp opens a gate to a **key**. 3 Hollows. |

> World build note: the full world (192 rooms) is listed in [world-graph.json](world-graph.json). The rooms of
> this table keep their ids (decision 10). `cave_1` moves to grid (1, 13) with F2 (code-contract 16.7).

Room transitions:

- When the player crosses a room edge, the camera slides to the next room in **0.45 s**. The
  game pauses enemies and the player during the slide. The player is placed 1 tile inside the
  new room.
- The cave entrance and exit use a fade to black of 0.3 s.
- Enemies respawn when the player re-enters a room. Collected items and opened doors stay.

## 3. Controls

| Action | Keyboard | Gamepad |
|---|---|---|
| `move_*` | WASD and arrows | Left stick, D-pad |
| `attack` | J or Space | A / Cross |
| `use_item` | E or K | X / Square |
| `ward` | Shift or L (hold) | RB / R1 (hold) |
| `cycle_item` | Q or I | Y / Triangle |
| `pause` | Esc | Start |

NOTE: After the first playtest the primary keys moved to the left hand (E, Shift, Q). The old keys K, L and I stay as alternates.

## 4. Player (Tamsin)

Units: health is in **half-hearts**. Start health 6 (3 hearts). Max 20 hearts.

| Value | Number |
|---|---|
| Walk speed | 360 px/s, 8 directions, normalized diagonal |
| Acceleration / friction | instant start, 0.06 s stop (no ice feeling) |
| Facing | the last cardinal input; diagonals keep the current facing if one axis matches |
| Collision shape | circle, radius 26 px, at the feet |
| Invulnerability after a hit | 0.9 s, sprite blinks |
| Knockback when hit | 640 px/s for 0.14 s, away from the source |

### Lamp hook (main weapon)

- **Swing**: a 110° arc in the facing direction, reach 120 px, active 0.12 s, total 0.28 s.
  Damage 2 (one heart). The player cannot move during the active frames.
- **Charge flare**: hold `attack` for 0.8 s, then release. A 360° sweep with reach 140 px and
  damage 4. The lamp glows while it charges. Movement speed is 50 % while it charges.
- The swing cuts bushes and pushes enemies back 480 px/s for 0.12 s.

### Lamp

- The lamp is always on. It gives a light radius of 260 px in dark rooms.
- If the player swings the hook at an unlit brazier, the brazier lights.

### Ward (shield)

- Hold `ward` to raise the lamp shield. Movement speed is 40 %. Facing locks.
- Projectiles that hit the front 120° of the player are destroyed. No other effect in step 1.

### Sub-items (one active at a time; `cycle_item` changes it)

| Item | Analog | Behaviour | Ammo |
|---|---|---|---|
| **Tether moth** | Boomerang | Flies 420 px in the facing direction at 900 px/s, then returns to the player. Stuns enemies for 2.0 s, damage 0. Picks up loot that it touches. One on screen at a time. | none |
| **Pitch pot** | Bomb | Placed one tile in front of the player. Explodes after 1.6 s. Radius 150 px, damage 4 to enemies and 2 to the player. Opens `cracked_wall` nodes. Max 2 on screen. | starts 0, max 10 |

> World build note: the pitch pot limit of 10 is the base. Two pot bags raise it to 14 and then 18
> (decision 4; code-contract 16.5).

## 5. Pickups

| Pickup | Effect | Drop chance from an enemy |
|---|---|---|
| **Ember** | +2 health (one heart) | 25 % |
| **Brass bit** | +1 currency | 35 % |
| **Brass coin** | +5 currency | 5 % |
| **Pitch pot bundle** | +4 pitch pots (only after the item is found) | 10 % |
| **Key** | +1 small key | placed only |
| **Wick core** | +1 max heart and full heal | placed only |

Pickups disappear after 8 s. They blink during the last 2 s. Placed pickups do not disappear.

> World build note: small keys belong to one cave each (scoped keys, decision 3). Big keys, fragments, slug
> ammo and the wallet cap are added by the full game (code-contract 16.5).

## 6. Monsters (the Hush)

> World build note: the table below is the step-1 set. The full game's regular monsters, minibosses and
> bosses are specified in [monsters-bosses-tools.md](monsters-bosses-tools.md); their code contract is
> code-contract section 16.6. The five monster types of the first paragraph are the step-1 count.

All enemies use the shared enemy base (see the code contract). All enemies give contact damage.

| Monster | Analog role | HP | Contact dmg | Speed | Behaviour |
|---|---|---|---|---|---|
| **Spitcap** | Rock spitter | 2 | 1 | 120 | Walks in a random cardinal direction for 0.6–1.6 s, stops, turns to the player's axis if aligned, and spits a spore ball (360 px/s, damage 1). Ward blocks spores. |
| **Skitterwick** | Jumping spider | 2 | 1 | — | Waits 0.4–1.2 s, then hops toward a random point near the player. Hop distance 140–260 px, airtime 0.5 s. Invulnerable in the air. |
| **Duskmoth** | Bat | 1 | 1 | 260 | Rests on the ground. When the player is within 300 px, it flies in curves with random turns for 2–4 s, then rests again for 1 s. |
| **Tallow blob** | Splitting slime | 2 | 1 | 160 | Moves in short steps toward the player. When it dies, it splits into 2 **tallow drops** (HP 1, speed 220) unless it is already a drop. |
| **Hollow** | Skeleton knight | 4 | 2 | 140 | Walks in a grid-aligned pattern. Turns toward the player when the player is on the same row or column and steps forward fast (300 px/s) for 0.5 s. |

Shared enemy rules:

- When hit: flash white for 0.1 s, knockback 480 px/s for 0.12 s, invulnerable for 0.25 s.
- When killed: a small puff, then roll the drop table.
- Stun (from the tether moth): the enemy stops and does not attack for the stun time. Contact
  damage stays active.
- Enemies never leave their room.

## 7. HUD

The HUD band (120 px at the top) shows, from left to right:

1. Hearts (full, half, empty).
2. Brass count, key count and pitch pot count.
3. The active sub-item in a frame.
4. A minimap of the 3×2 grid. Visited rooms are filled. The current room is highlighted.

No tutorial text appears in the game world. Button help is allowed only in the pause menu.

> World build note: the 3×2 minimap is the step-1 HUD. The full game shows the overworld on a 12×9 map and
> a cave map, with the key, big key and fragment counters (work package F11 in
> [world-work-packages.md](world-work-packages.md)).

## 8. Placeholder art (step 1)

- All visuals in step 1 come from one helper: `scripts/art/placeholder.gd`. It draws simple
  shapes (circles, rectangles, arcs) with a fixed colour per entity type.
- Every entity has a `Visual` node. Step 2 replaces the `Visual` node with an `AnimatedSprite2D`
  that uses the real art. Game logic must never read from the `Visual` node.

## 9. Work packages

| WP | Owner | Scope |
|---|---|---|
| WP0 | Sonnet | Project, input map, autoloads, player, combat components, enemy base, pickup base, room system, HUD, placeholder helper, test runner, `docs/code-contract.md`. |
| WP1 | Haiku | Spitcap and the spore projectile. |
| WP2 | Haiku | Skitterwick. |
| WP3 | Haiku | Duskmoth. |
| WP4 | Haiku | Tallow blob and tallow drop. |
| WP5 | Haiku | Hollow. |
| WP6 | Haiku | Tether moth and pitch pot (sub-items) plus the cracked wall. |
| WP7 | Sonnet | Integration: build the 7 rooms, place enemies and items, brazier gate, locked door, tests, visual check, commit. |

WP1–WP6 run in parallel after WP0. Each package writes only its own files (see the code
contract). WP7 starts when WP1–WP6 are done.

## 10. Step 2 preview: high-detail art with GPT Image via Codex

- Codex generates painterly, high-detail source images: character turnarounds, enemy sheets,
  terrain tiles and props. The style must never imitate 8-bit or 16-bit pixel art.
- Source images go to `tools/source_art/`. A Python tool cuts them into sprite strips under
  `assets/sprites/`. The tool must not quantize the palette or threshold alpha.
- Rules from Hollowtide that apply here: scale each strip with one factor, find real gaps
  between poses, and check every strip visually in the game.
