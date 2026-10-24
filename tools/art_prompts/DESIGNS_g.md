# Invented design details, producer g (batches 60 to 71)

Details the prompts of this range use that `docs/art-brief.md`, `docs/monsters-bosses-tools.md` and the inventory do not fix. Each line is a choice made for the prompt, not an owner decision. Change it here and in the batch file together.

## Unit layout (how the inventory counts map to sheets)

- One unit = one sheet (1536x1024) with one facing (or one set of states) and one row per animation, rows listed top to bottom. A unit is generated 3 times (variants 1 to 3).
- Walkers: `<name>_walk_side`, `_down`, `_up` (3 units, one row of 4 poses each). The side unit is the anchor: `_down` and `_up` name its chosen variant as their design reference.
- Actions: `<name>_actions_side` and `_down` (2 units, one row per state). The down and side actions name the walk anchor as design reference.
- Multi-unit bosses and minibosses are split by facing or by state group (see the table below). Where the inventory gives a count of units that a split cannot follow exactly, the split is listed as an invented choice.

## Anchors (producer choice, not owner-accepted)

| Anchor unit | Chosen variant | Used by |
|---|---|---|
| `abacus_brute_walk_side` | v1 | abacus down, up, actions side and down (batch 60) |
| `wick_automaton_walk_side` | v1 | wick down, up, actions side and down (batch 61) |
| `corrows_echo_walk_side` | v1 (all three weak; kept for design only) | corrows down, up, actions (batch 62) |

Other anchors are recorded when chosen (see `PROGRESS_g.md`).

## Monster and boss designs

- **Abacus brute** (B60): big brass-armoured brute, dark iron helm with a teal slit visor, a long bead chain over the shoulders hanging from the right fist, a brass shield rail on the left forearm (the rail breaks off in the rail-break row).
- **Wick automaton** (B61): brass clockwork lamp-tender, funnel chimney, round vent flap on top beside the chimney (visible from every facing), flame spout on the chest with a pilot flame, amber lamp window.
- **Corrow's echo** (B62): wax old man in a long coat, wide hat, wax lamp hook (pole, curled hook, small wax lantern). `miniboss_death_wax` is a generic wax puddle with a dying violet glow, no identity.
- **Kilnkeeper** (B63): wax giant with a round kiln belly and a cracked kiln door, iron chimney stack as a hat. Phase 1 is hard grey wax; phase 2 cracks open, orange-white light and molten slag. Split: `_down` (idle, walk down, slag fan) and `_side` (walk side, rush, rush stun; p2 side also splash).
- **Briar Mother** (B63): woman-shaped root mass with thorn hair, three red fruit-eyes on vines; `eye_lost` row shows one eye torn away. **Seed-eye** (B63): dark seed pod on a fibrous stalk with one red-brown eye, a ring of thorns at the base.
- **Briar bloom** (B64): phase-2 red-pink flower bud with thorned petals; **briar seed** (B64): fist-sized dark seed with a thorn shell and a sap line.
- **Tidewick** (B64/B65): black lacquered wax and copper serpent; head with amber eyes and copper spines; tail ends in a wick flame. Head units `_down`, `_up`, `_side` (side also holds the ember-spit telegraph and the phase-2 scorched rows).
- **Hushed colossus** (B65): seated grey wax and slag giant, sealed eyes, glowing seams; arms split into `_slam` (slam telegraph, slam, double slam) and `_sweep` (arm sweep, quake).
- **Colossus shard** (B65): fallen grey wax and slag chunk, orange seam glow.
- **Archivist** (B65/B66): floating scribe of paper and ink, round mirror for a face, pages for a cloak, eyes on the pages. Phase 2/3 more pages torn and ink spread; decoy is paler and translucent with no shadow.
- **Dirge Choir heads** (B66): carved stone heads in organ pipes; bass has the widest pipe and heaviest jaw, alto a middle pipe, treble a thin pointed head in a tall thin pipe.
- **Gloam Knight** (B67): dark glass-black armour, empty plume, cape that bleeds shadow, long lance. Split: `_down` (walk, lance telegraph, lance), `_side` (walk, slash combo, dive crouch), `_up` (walk, airborne, land). Phase 2: cracked armour, frayed cape; `_down` idle and dive, `_side` slash and ring land.
- **Coinwyrm** (B68): bronze coin-plate serpent head with a gold crown and a purse-like jaw. Split: `_head_down` (bare, bite telegraph, bite), `_head_side` (rear, burrow, rise). Plates: two units, each with a whole pose then three yanked-off poses per part (`_plates_a`: brow and left cheek; `_plates_b`: right cheek and crown). Tail and coin heap as listed.
- **Lock Warden** (B69): brass door-lock with four hinged plates and a lidded eye above each; keyhole glows like a lamp. Split: `_closed_open` (closed, plates open) and `_broken` (plates broken). Plate and keyhole units show one corner plate and the keyhole.
- **Unlit** (B69-B71): mass of old wax, rope and tools around a dim lantern (p1 mass); lidless wax eye; wax hand rising from the floor; p2 wax shell on stubby legs with cracks (`_down`, `_side`); p3 heart split into `shielded` (2 poses) and `exposed` (4 poses); Ninth Lantern on chains (five rows); chains lying on the floor line.
- **HUD** (B71): hearts are dark red wax with a brass rim (`hud_heart_full`, `hud_heart_half_empty` with the half and empty icons, `hud_heart_beat`); wick-core slot is a brass socket with a glass bulb divided into four quarters; item frame is square brass with dark glass.

## Other decisions

- Key colour magenta `#FF00FF` on every sheet of this range; no subject uses magenta.
- Facing wording (from `PROGRESS.md`) is the same for monsters: down = the front faces the viewer, body square to the camera; up = the back faces the viewer; side = strict profile, facing right.
- Reference images: `tools/source_art/tamsin_walk_side.png` (style and light) for creatures and HUD; `tools/source_art/ow_props.png` for props and the unlit and lock units.
