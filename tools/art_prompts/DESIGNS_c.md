# Invented design details, producer c (batches 20 to 27)

Designs that the inventory and the world docs do not describe. The owner can change any of them; a change means a new prompt entry, not a change to the source file.

## Shared decisions

- **Key colour:** pure magenta `#FF00FF` on every sprite sheet and every edge strip (no subject in batches 20 to 27 contains magenta). Textures have no key.
- **Facing rule** (from `tools/art_prompts/PROGRESS.md`): no sheet in these batches is a walk cycle or a turned figure. Every pose is described on its own and the camera is fixed in every pose.
- **Sizes:** sheets 1536x1024; `pit_fill` 1024x1024. Cell sizes come from the `cell` column of the inventory; a multi-row sheet has one animation or state per row.

## Batch 20

- `item_reel_line`: a small brass spool wound with braided cord, an iron hook tip at the loose end, on a short carved stone pedestal. Glint poses carry a small white highlight (poses 2 to 4).
- `icon_hook_flare_ward` (three icons, named by the owner's contract as the group id): `icon_base_hook` (a curled brass pole with a lantern on the hook), `icon_base_flare` (a hand-held signal flare with a burning white-amber head), `icon_base_ward` (a round dark-iron lantern-shield with an amber glass disc). The file names are mine; the inventory gives only the group id.
- `flame_cinder`: three rows in one sheet. Rolling flame (4 poses, a fire ball rolling), standing flame (4 poses, a flame on a charred bed), fade (3 poses, the flame dying to embers and smoke). The standing and fade rows sit on a dark charred bed, which the generator adds on its own; it is wider than the flame in the first two variants (see the log).
- `slug_tallow`: a pale cream tallow pellet, flight (2 poses, a streak behind it) and impact splat (3 poses).

## Batch 21

- `reed_raft_vehicle`: a raft of bundled reeds on water, with no person on it. The landing boards and mooring post of rows 2 and 3 are part of the sprite (the inventory says "raft under Tamsin, board 3, dock 2"); they are cut at the cell edge in all three variants.
- `jar_thrown` and `jar_lit`: a glass jar with a cork and a brass band, with a warm light inside. The jar_lit vessel came out heart-shaped in two of three variants; the inventory does not specify the shape.
- `reel_tip`: a curved dark iron hook with a brass collar and a spark at its point. The cord tail is extra.
- `liftable_rock_small`: row 1 holds three objects (mossy rock, clay urn, wooden crate), row 2 the break puff. The accepted name `liftable_rock_small` covers the whole sheet; the cut tool needs to split row 1 into three kinds, or the owner splits the names.

## Batch 22

- `slug_bundle`: four pale tallow pellets tied with brown string, on the ground.
- `pot_bag`: a brown leather drawstring pouch with a brass ring at the mouth.
- `tallow_flask`: intended as a small round glass flask of honey-gold tallow with a cork. All three variants drifted to a heart-shaped glass lantern with a flame inside (see the known problems); the pickup is failed.
- `bigkey`: a long iron shaft with a toothed bit and a lantern-shaped bow (brass bars around a flame-shaped glass). The brass came out saturated gold, not the neutral pale brass the code tint needs.

## Batch 23 (lantern fragments)

One shape for all nine: an upright, faceted shard of old lantern glass about as tall as a hand, wide base, tapering top, a thin brass rim at the base, light inside. The colour per fragment:

- c1 Warmth: amber and honey-orange glass, warm lamp amber light
- c2 Growth: moss-green glass with a leaf pattern inside, green-gold light
- c3 Rain: pale blue glass with round bubbles inside, cold teal light
- c4 Sleep: deep violet glass, dim dusk-violet light
- c5 Memory: pale silver-white glass with fine lines inside like folded paper (no writing), white-gold light
- c6 Song: rose-pink glass with ripple lines, soft rose light
- c7 Courage: deep red glass with a dark core, red-orange light
- c8 Trade: bronze-gold glass with a coin-like disc (batch 24)
- c9 Corrow's Last Wick: black glass with a white-hot wick flame (batch 24)

The glow poses are: medium, brightest with a halo, medium with the light shifted up, dimmest. Brass bases came out with prongs (wider than the thin rim), in most variants.

## Batch 24

- `fragment_c8` (Trade): bronze-gold glass with a flat coin-like disc inside. Variant 2 has the disc standing high and in front of the glass (weak).
- `fragment_c9` (Corrow's Last Wick): black glass with a white-hot wick flame. Variants came out grey-silver or bronze-tinted; the owner may want a redo with "black obsidian-like glass".
- `slag_chunk`: a dark grey-black lump with rust-red glints. All three variants show an orange molten glow (weak); the prompt says subtle glints.
- `thorn_hedge`, `thorn_wall`, `thorn_door`: three rows, the closed state, the five burning poses in order (small flicker, climbing flames, fire through the middle, large fire, embers), then the burnt-open state. Thorn walls and doors share the same burn sequence.

## Open points for the owner

- `reel_line_rope` (batch 21): the inventory gives both `96x16 tile` and `alpha strip 16x96`. The prompt uses a horizontal cord (96 long, 16 thick) that runs into both sides of the image.
- `edge_pit_rim` (batch 25): the inventory gives one unit for three pieces (a straight strip and two corners). The sheet has the three pieces on one image; the cut tool needs a multi-piece rule for it. The contract says one cell per edge strip, so this is a deviation from `asset-contract.md` section 7 until the cut tool is changed.
- `reed_raft_vehicle` (batch 21): the landing boards and posts inside the sprite are cut at the cell edge; the owner may want a raft-only redo.
- `tallow_flask` (batch 22): failed in all three variants. A redo needs an explicit sphere shape and no flame; the owner decides.
- `bigkey` (batch 22): the brass is saturated gold in all three variants, which the per-cave tint may not handle well.
- `slag_chunk` (batch 24): the inventory gives a 96x96 cell with no foot line. The prompt puts it on the ground at the ground line of the other 96-px ground objects. The orange glow in all three variants needs a redo before the cut.
