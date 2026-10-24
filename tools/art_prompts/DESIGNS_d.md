# Invented design details, batches 28 to 35 (producer d)

Details in the prompts that the art brief and the inventory do not fix. Each one is a choice made for the prompt, not an owner decision. Change them here and in the batch file together.

## Unit and count decisions

- **Pillar (B32).** The inventory says "stone pillar (C1) 1 + variants cave-themed: wax, root, brass" with count 3 x 3. Three units were made: `pillar_1` plain carved stone (C1), `pillar_2` wax-dressed, `pillar_3` root-wrapped. The brass variant is not drawn. Owner to confirm whether brass replaces one of the three.
- **Crate stack (B33).** Inventory "wood crate 2 variants + stack 1": `crate_stack_1` (old grey planks, iron straps), `crate_stack_2` (dark slatted boards, rope handles), `crate_stack_3` (stack of three).
- **Statue eye (B32).** Inventory says "2 variants" but count 1 x 3. One unit, `statue_eye`: a hooded stone figure with a carved round eye on the chest.
- **Statue figure (B33).** Two units: `statue_figure_1` standing with a lantern raised, `statue_figure_2` kneeling with a lantern at its feet. Both face the viewer square on (facing wording in the prompt, from the facing fix in PROGRESS.md).
- **Anvil (B34).** One unit with two poses in one row: the anvil, and the slag pour set (crucible on a stand with a ladle). The set is one prop in the inventory; it is drawn as two separate poses so the cut can keep them apart.
- **Slag heap and glass shards (B34).** Two units each. Heap 1: lumpy with orange cracks; heap 2: flatter ridged crust. Glass 1: smoky amber; glass 2: pale green-blue with milky patches.
- **Dead tree, thorn bramble (B35).** Two units each: tall charred tree and charred split stump; upright bramble clump and low sprawling bramble.

## Layout decisions

- **Rows are states.** Every multi-state prop is one sheet of several rows, one row per state, top row first (e.g. `sealed_seam`: hidden 1, revealed 3, open 1). All states of one prop are drawn at the same scale with the base at the same height, so the cut tool keeps one factor for the prop.
- **Pocket entrances (B30, B31).** Each is one row with two poses: closed, then open. Stall (striped awning), cart (canvas cover), lighthouse door (round stone base), mason door (carved stone), hut door (plank door, thatched lintel), grotto (fern curtain over a recess), stairs down (stone slab, steps below), plain door (no decoration).
- **Hook-cut screens (B29).** Reed cluster, rush wall, moss wall, dry vine screen and bush cluster each have a whole row (1 pose) and a cut row (3 poses: first cut, wide cut, open gap).
- **Ninth door (B28).** Four rows: sealed (1), socket glow (9 poses, one more socket lit in each), opening (6), open (1). Sheet 1536x1024; the cell is 576x480, so the cut tool scales the rows.
- **Root bridge (B35).** One row, two poses: straight segment and end segment with a root post.

## Other invented details

- Key colour is magenta `#FF00FF` for every prop in this range (no green foliage keyed on green, so the rim despill exception of the contract is not needed).
- Reference images: `tools/source_art/ow_structures.png` for doors, walls, pocket entrances and stall/furnace structures; `tools/source_art/ow_props.png` for rocks, plants, statues and crates.
- Variant wording: v1 neutral; v2 stronger warm light and more weathering; v3 softer edges and worn texture (same design in all three).
