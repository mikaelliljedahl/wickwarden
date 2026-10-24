# Invented design details, producer f (batches 48 to 59)

Details in the prompts of this range that the art brief, the monster document and the world plan do not fix. Each line is a choice made for the prompts; change it here and in the batch file together. The owner can change any of them, which means a new prompt entry, not an edit of a source file.

## Layout decisions

- **Walk sheets.** One sheet per facing (side, down, up); one row of 4 poses (contact, passing, contact, passing). Walk poses name leg A and leg B (leg A forward in pose 1, leg B forward in pose 3). Side view: leg A is the nearer leg. Front and back view: leg A is the figure's left leg.
- **Action sheets.** One sheet per facing (down and side, as the inventory says); the poses of all actions of one character are placed in rows of at most four poses, in the order the layout line gives (for example `hollow_captain_actions`: row 1 guard_up, bash_telegraph, bash 1 and 2; row 2 stunned). A row can hold part of one animation; the row map of each sheet is in its layout line, and the cut step must follow that map.
- **Shop NPCs** (`npc_tilly`, `npc_peddler`, `npc_ashwife`, `npc_mason`, `npc_pilgrim`, `npc_keeper`): one sheet, three rows: idle (4 poses), greet (2), farewell (1). Figure only; the stall, cart, burrow and counter are props that other batches draw (`shop_counter`, `pocket_stall`, `pocket_cart`, `pocket_hut_door`, `pocket_grotto`). Down view only.
- **Villagers** (`npc_villager_a`, `npc_villager_b`, optional): one sheet per facing (down, up, side), two rows of four poses: row 1 idle (a slow breathing sway), row 2 walk. The inventory's `idle 4` is therefore drawn per facing; the owner may drop the idle row if the cut needs one walk strip only.
- **Corrow** (`npc_corrow_wax`): one sheet, three rows: seated idle (4), speak (2), fade (4). Front view. `npc_corrow_ghost` (provisional): one row of 3 translucent idle poses.
- **Sump Lurker** (`sump_lurker`): one drawn direction (three-quarter right, the head to the right), four rows: surface (3), bite (3), surfaced idle and water-jet spit (2 and 2), dive (3).
- **Projectiles** (`proj_*`): one sheet, one row of 5 poses: 2 flight poses and 3 impact poses, as in the inventory. Magenta key, centred on one line.
- **Lights** (`light_*`): one image, one centred soft radial glow (no object, no shape inside). Square 1024x1024 for the warm and cold glows and the jar glow; portrait 1024x1536 for the dusk shaft (the cell is 512x1024, so the cut scales it by half). Magenta key outside the light, which the cut tool removes.

## Unit decisions

- **Hollow Captain** (`hollow_captain`, miniboss C1): a Hollow in a tin lamp-shade helm with a dark empty visor and a faint cold teal glow, a round brass guard on its left arm, dented pewter plates, a torn grey cloak, pewter greaves. Design reference: `tools/source_art/hush_hollow.png` and the accepted `hush_hollow_walk_side.png`.
- **Thorn Warden** (`thorn_warden`, miniboss C2): a man-sized walking hedge with a bark of thorns, a leaf face with dark eye holes, two root legs, a thorned bark skirt, dark-green leaves at the shoulders.
- **Sump Lurker** (miniboss C3): a pale blind wet grey-white worm, ridged back, a ring of small teeth at the head end, no eyes.
- **Lull-Mauler** (miniboss C4): a hunched grey wax body with cooled slag veins, a small low head, long slab forearms, two short thick legs.
- **Mirror Warden** (miniboss C5): a pale silver-grey steel suit with a featureless polished face plate, a long mirror-bright shield (plain sheen; no reflected figures, no writing).
- **Choir Warden** (miniboss C6): a tall hooded singer in a dark-grey hooded robe, organ-pipe ribs down the sides of the body like a cage, pale folded hands.
- **Pale Squire** (miniboss C7): a lean chalk-white Hollow with a thin cloth tabard, a steel spear held upright, a narrow helm with a slit visor.
- **Corrow** (`npc_corrow_wax`, C10 choice): an old man in a long dark coat, the left side of the coat wax-pale and melting into a drip at the hem, the right side still cloth and skin; seated on a low stool with hands folded. Matches the wax figure of `corrows_echo` in batch 62.
- **Shop NPCs:** Tilly (broad, cheerful woman, grey-blue shawl, dark apron with brass pins, a brass lamp in one hand); the peddler (small, wiry, patched brown smock, wide-brimmed felt hat, sack on the back); the Ashwife (tall, thin, long grey ash-dusted cloak, grey headscarf, pewter bell at the hip); the stone mason (broad, leather apron, flat cap, stone dust, mallet and chisel on the belt); the pilgrim (pale blue-grey robe, hood thrown back, walking staff with a cloth bundle, satchel); the keeper (lean old man, dark waistcoat with brass buttons, trimmed grey beard, a ring of brass keys).
- **Villagers** (optional): a farmer of Brackwater Ford (brown wool jerkin, grey hood, satchel); a village woman of Brackwater Ford (long dark-blue dress, patched apron, headscarf, wicker basket).
- **Projectiles:** slag ball (orange-white hot lump with a dark crust); spore seed ball (the brief's dusty green-gold seed); thorn needle (dark brown-green thorn with a cream tip); ember bolt (red-orange ember ball, white-gold core); cold beam bolt (narrow tapered capsule of pale blue-white light, long axis vertical in the frame); ink bolt (black-violet glossy blob with a spiked tail); torn parchment page (not readable); bronze musical note head (no staff lines); dark glass lance tip; brass coin with a lantern stamped on it (no letters); iron key with a flame-shaped brass bow; teal-white gaze orb with a violet rim; violet-white homing orb; dark cistern water spit; curved cream wax hook with a brass tip (boomerang).

## Other invented details

- Key colour is magenta `#FF00FF` on every sheet and light of this range. No subject in the range is magenta or pink.
- Reference images: `tools/source_art/tamsin_walk_side.png` for the light and style of every new figure; `tools/source_art/hush_spitcap.png` for projectiles (style); `tools/source_art/hush_hollow.png` and `hush_hollow_walk_side.png` for the Hollow Captain. A down or up sheet, and an action sheet of the same facing, name the accepted side sheet (`<sheet>_side_v1.png`) or the walk sheet of the same facing as their design reference; the first side variant is named in advance (v1), not chosen after the run.
- Variant wording: v1 neutral; v2 slightly more surface detail and stronger highlights; v3 softer edges and more worn texture (same design in all three).
