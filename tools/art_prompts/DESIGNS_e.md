# Invented design details, producer e (batches 36 to 47)

Details that the art brief and the inventory do not describe. Each line is what the prompts of this range say, so that every variant of one unit uses the same design. Change them here and in the batch file together.

## Unit splits (decisions of this range)

- **Boardwalk (B36).** The inventory row lists straight, end and corner pieces. Three units: `boardwalk_straight`, `boardwalk_end`, `boardwalk_corner`, one 96 px tile each.
- **Dock pier (B36).** One unit, `dock_pier`.
- **Wax vat (B37).** Three units: `wax_vat_1` (round tank with a domed lid), `wax_vat_2` (taller oval tank on short legs with a ladle), `wax_vat_pipe` (pipe segment with an elbow).
- **Lily pads (B37).** One unit with three frames (sway).
- **Shipwreck (B37).** Two units: `shipwreck_1` (hull on its side, torn sail), `shipwreck_2` (smaller bow half buried).
- **Rusted lantern post (B38).** One unit, dark glass housing.
- **Salt crystals (B38).** Two units: `salt_crystals_1` (angular spikes), `salt_crystals_2` (rounded cloudy crust).
- **Driftwood net (B38).** One unit: driftwood pile with a net heaped over it.
- **Well and haystack (B38).** The inventory row says "village well + haystack, 2 variants" with count 6. It is split into two single-pose units: `village_well` and `haystack`, three variants each. The cut manifest needs two kinds.
- **Cottage (B39).** One unit, one building: a pitched dark slate roof, stone and timber, a lit window with a shutter, a plank door, a lower and longer cottage than the lamplighter hut with a small wooden porch. The first prompt wording described a second house next to it, and the sheets came back with two houses; the wording was fixed ("single building only") and the sheets regenerated as the -r1 jobs.
- **Ledge drop (B39).** The inventory says "straight 1, corner 1" with count 1 x 3. One generation with two poses in one row (straight rim, outer corner). Same open point as `edge_pit_rim` (producer c): the cut tool needs a multi-piece rule, or the owner splits the names.
- **Bell (B39).** Three designs: `bell_1` (bronze bell in a timber frame), `bell_2` (wall of five organ pipes with a small bell), `bell_3` (wall of three brass and tin pipes with a bell at the side).
- **Pump pipe (B40).** Three units: `pump_valve_1` (wheel sluice valve), `pump_valve_2` (tall lever pump), `pipe_segment` (straight pipe with flanges).
- **Mirror panel (B40).** Three units: `mirror_reflective_1` (rectangular, dark wooden frame), `mirror_reflective_2` (oval, iron frame), `mirror_cracked` (cracked from the top corner). No reflected figure in any of them.
- **Workbench (B41).** Two units: `workbench_1` (table with vice and shelves), `workbench_2` (lower bench with drawer, apron and shavings).
- **Mural panel (B41).** Four units, one picture each, seen straight on from the front, framed in timber: `mural_1` (lanterns on a dusk hill), `mural_2` (harbour with a boat under a pale moon), `mural_3` (tree with birds), `mural_4` (ring of stones with a lantern). No letters, no figures.
- **Arena pedestal lantern (B42).** Two designs: `arena_lantern_rekindle` (lantern with a glass chimney and a rising spark), `arena_lantern_wickwarden` (tall iron cage with brass hooks and a wick flame).
- **Letter pile (B42).** One unit, pale folded letters tied with a faded ribbon, no readable marks.
- **Cave mouths (B42).** Three regional mouths, each one unit: `cave_mouth_ashen` (ash-grey rock and soot), `cave_mouth_fen` (dark timber posts and lintel, reed on top), `cave_mouth_stone` (pale carved stone arch with bands).

## Effects (B43 to B47)

- All effects are magenta-keyed strips. Frames are one row, one frame per slot, centred on one shared centre line; there is no ground line. The effect style reference is `fx_explosion.png`; fire units also use `braziers.png`.
- **Frame counts** follow the inventory: 3 to 6 frames for most effects, 8 for the three 768 px effects (`fx_boss_death_light`, `fx_boss_death_wax`, `fx_rekindle_burst`). Eight frames in a 1536 px row give 192 px slots, so these three are upscaled about 4x by the cut tool. Open point for the owner: a two-row layout or a wider canvas would avoid this; not changed here.
- **Chime ring (`fx_chime_ring`).** The inventory says a 512 px cell and a radius up to 480 px. A 512 px cell cannot hold a 480 px radius ring. The prompt asks for a ring that nearly fills its slot in frame 5; the code scales the sprite if it needs the full radius. Open point.
- **Fire base.** `fx_fire_small` (cell 128, foot 118) and `fx_fire_big` keep their flame base on a shared line at the bottom of each frame. `fx_smoke_column` rises from the bottom of each frame.
- **Wake and ripple.** `fx_raft_wake` is two pale V-lines spreading from the bottom edge of the frame; `fx_water_ripple` is a top-down ring with a faint highlight arc.
- **Warp.** `fx_warp_out` and `fx_warp_in` are a pale gold spiral with dusk smoke; out collapses to a point, in opens from one.
- **Boss death light (`fx_boss_death_light`).** A white-gold flare that blooms, then breaks into thin rising motes. No character.
- **Boss death wax (`fx_boss_death_wax`).** A cream wax mass that slumps, cracks and spreads into a warm pool. No blood.
- **Thorn burst (`fx_thorn_burst`).** Dark olive-brown thorns and pale seeds, no green foliage.

## Shared decisions

- **Key colour:** pure magenta `#FF00FF` on every sheet and strip in this range. No subject contains magenta.
- **Facing rule** (`PROGRESS.md`): no unit in this range is a walk cycle or a turned figure, so the facing and leg wording is not needed here. Every pose is described on its own.
- **Sizes:** sheets 1536x1024; cell sizes come from the `cell` column of the inventory.
- **Variant wording:** v1 neutral; v2 stronger warm light and more weathering (props) or a brighter core (effects); v3 softer edges and a slightly faded surface. Same design in all three.
