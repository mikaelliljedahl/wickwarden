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

## Open points for the owner

- `reel_line_rope` (batch 21): the inventory gives both `96x16 tile` and `alpha strip 16x96`. The prompt uses a horizontal cord (96 long, 16 thick) that runs into both sides of the image.
- `edge_pit_rim` (batch 25): the inventory gives one unit for three pieces (a straight strip and two corners). The sheet has the three pieces on one image; the cut tool needs a multi-piece rule for it. The contract says one cell per edge strip, so this is a deviation from `asset-contract.md` section 7 until the cut tool is changed.
- `slag_chunk` (batch 24): the inventory gives a 96x96 cell with no foot line. The prompt puts it on the ground at the ground line of the other 96-px ground objects.
