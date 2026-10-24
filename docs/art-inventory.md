# Wickwarden: art inventory (GPT Image)

Status: list only. No prompts and no images come with this document. It is the complete list of
graphic elements the full game needs from GPT Image, with status, size, animation frames and the
number of variants to generate. Prompts are written later from [art-brief.md](art-brief.md) (style,
shared block, sheet block, key colours), one batch at a time.

Inputs read: [asset-contract.md](asset-contract.md) (normative: cells, strips, naming),
[art-brief.md](art-brief.md), [art-provenance.md](art-provenance.md) (what exists), [world-plan.md](world-plan.md),
[monsters-bosses-tools.md](monsters-bosses-tools.md), [world-work-packages.md](world-work-packages.md) (section 11 for the
stills and the title), [story.md](story.md) and the files in `assets/sprites/`.

## 1. How to read the tables

| Column | Meaning |
|---|---|
| id | `snake_case`, the `<kind>` of the contract; strips become `<kind>_<anim>[_<facing>].png`. A `_{d,u,s}` in the animations column means three strips `_down`, `_up`, `_side` (side is drawn facing right; code mirrors it). |
| cat | category (the section) |
| source | sprite sheet (key-colour background, cut by `tools/cut_sprites.py`), texture (opaque seamless, or an alpha strip where stated), single painting (used as is, like the stills), UI icon (small single image on a key background) |
| animations | `name N` = N frames in one horizontal strip, one generation per strip. Facings are listed when the contract needs them |
| cell | target cell size in px, `foot` is the foot line of the contract. Sizes not in the contract are **proposals** and need a contract update before the cut (unclear point 1) |
| status | `done` = exists in `assets/sprites/` and in the provenance table; `todo` = to generate |
| units x var | `units` = generations per variant (for example the three facings of a player animation are 3 units, as in the v2 walk sheets); `var` = variants to generate (default 3; the user culls afterwards). Images = units x var. `done` rows cost 0 |

Rules that apply to every row: three-quarter top-down view, light from the upper left, no text, no pixel
art, one generation per animation (all frames of one animation from one call), identical figure in every
pose, flat key background (magenta or green, never a colour present in the subject). Sheets with more than
one unit use the finished first unit as a reference image ("same character as in the reference image").

Done means in the provenance table: Tamsin (walk, swing, charge, ward, hurt), hollow, spitcap, skitterwick,
duskmoth, tallow blob and drop, spore, tether moth, pitch pot, explosion, the six pickups, the brazier (cold
and lit), the 15 base prop families, cave exit, and the eight terrain textures.
The hearts, the swing trail, shadows and the pond and wall shaders are code, not art.

## 2. Inventory

### 2.1 Player (Tamsin)

Existing cut strips: `player_{walk,swing,charge,ward,hurt}_{down,up,side}`. The new rows are one animation per tool. Cell 192x192 with foot 176 unless noted; the reel and swing-like poses use the 288x192 wide cell (same foot row). Idle = first frame of the walk. Poses are drawn on the ground; leaps and falls are lifted or scaled by code, so the drawn foot line stays 176.

| id | source | animations (frames) | cell | used in | status | units x var |
|---|---|---|---|---|---|---|
| `player_walk` | sprite sheet | walk_{d,u,s} 4 | 192 foot 176 | all | done | - |
| `player_swing` | sprite sheet | swing_{d,u,s} 4 | 288x192 foot 176 | all | done | - |
| `player_charge` | sprite sheet | charge_{d,u,s} 2 | 192 foot 176 | all | done | - |
| `player_ward` | sprite sheet | ward_{d,u,s} 1 | 192 foot 176 | all | done | - |
| `player_hurt` | sprite sheet | hurt_{d,u,s} 1 | 192 foot 176 | all | done | - |
| `player_wick_cast` | sprite sheet | wick_cast_{d,u,s} 3 (hands up, cast, recover) | 192x192 foot 176 | after C1 | todo | 3 x 3 = 9 |
| `player_sling_shot` | sprite sheet | sling_{d,u,s} 3 (aim, release, recoil) | 192x192 foot 176 | after C2 | todo | 3 x 3 = 9 |
| `player_raft_ride` | sprite sheet | raft_{d,u,s} 2 (idle sway, pole push); stands on the raft prop | 192x192 foot 176 | C3, lake rooms | todo | 3 x 3 = 9 |
| `player_mitts_lift` | sprite sheet | lift_{d,u,s} 3 (reach, grab, overhead) | 192x192 foot 176 | after C4 | todo | 3 x 3 = 9 |
| `player_mitts_carry` | sprite sheet | carry_{d,u,s} 4 (walk with object overhead) | 192x192 foot 176 | after C4 | todo | 3 x 3 = 9 |
| `player_mitts_throw` | sprite sheet | throw_{d,u,s} 3 (wind, release, follow) | 192x192 foot 176 | after C4 | todo | 3 x 3 = 9 |
| `player_mitts_push` | sprite sheet | push_{d,u,s} 4 (shoulder against heavy stone) | 192x192 foot 176 | C4, C6, Gravelight | todo | 3 x 3 = 9 |
| `player_mitts_pull` | sprite sheet | pull_{d,u,s} 4 (backwards, gripping) | 192x192 foot 176 | C4, C6, C9 | todo | 3 x 3 = 9 |
| `player_jar_throw` | sprite sheet | jar_throw_{d,u,s} 3 (underhand wind, release, follow) | 192x192 foot 176 | after C5 | todo | 3 x 3 = 9 |
| `player_chime_ring` | sprite sheet | chime_{d,u,s} 3 (raise, ring, hold) | 192x192 foot 176 | after C6 | todo | 3 x 3 = 9 |
| `player_chime_hold` | sprite sheet | chime_hold_{d,u,s} 2 (warp charge, glowing, loop) | 192x192 foot 176 | after C6, warp | todo | 3 x 3 = 9 |
| `player_leap` | sprite sheet | leap_{d,u,s} 4 (crouch, launch, apex, land); code lifts the body, foot stays 176 | 192x192 foot 176 | after C7 | todo | 3 x 3 = 9 |
| `player_reel_fire` | sprite sheet | reel_fire_{d,u,s} 2 (cast, arm extended holding line) | 288x192 foot 176 (like swing) | after C8 | todo | 3 x 3 = 9 |
| `player_reel_pull` | sprite sheet | reel_pull_{d,u,s} 2 (dragged, body stretched forward) | 288x192 foot 176 | after C8 | todo | 3 x 3 = 9 |
| `player_pot_place` | sprite sheet | pot_place_{d,u,s} 2 (crouch, set pot) | 192x192 foot 176 | after pot | todo | 3 x 3 = 9 |
| `player_moth_throw` | sprite sheet | moth_throw_{d,u,s} 3 (flick, release, watch) | 192x192 foot 176 | after moth | todo | 3 x 3 = 9 |
| `player_item_get` | sprite sheet | item_get 2 (arm overhead holding the item), down only | 192x192 foot 176 | every item find | todo | 1 x 3 = 3 |
| `player_flask_drink` | sprite sheet | flask 3 (drink the tallow flask), down only | 192x192 foot 176 | shops | todo | 1 x 3 = 3 |
| `player_pit_fall` | sprite sheet | pit_fall 3 (tumble and shrink), down only | 192x192 foot 176 | C7, ravines | todo | 1 x 3 = 3 |
| `player_death` | sprite sheet | death 4 (collapse, lamp dims), down only | 192x192 foot 176 | all | todo | 1 x 3 = 3 |

### 2.2 Terrain textures (6 regions, 10 caves)

All textures are 384x384 (4x4 tiles) in the game and are generated at 1024x1024. Rows `done` are the eight in the contract. Region rows: B Brackwater Ford, T Thornwood, A Cinderflats, F Tallowfen and Mirrormere, G Gravelight Heights, H Hushmarch. Per cave: `ground`, `wall` (top), `wall_face` (front, for ruin-style blocks), `special` (the cave's one extra floor or water or pit surface). `edge_*` and transition rows are alpha overlay strips, a new format (unclear point 5). `floor_color` tints stay in code, so a region can reuse a ground with a tint, but each region gets its own so the six read as different places.

| id | source | animations (frames) | cell | used in | status | units x var |
|---|---|---|---|---|---|---|
| `ground_grass` | texture | seamless opaque | 384x384 (source 1024) | overworld floor | done | - |
| `wall_hedge` | texture | seamless opaque | 384x384 (source 1024) | overworld border | done | - |
| `wall_ruin` | texture | seamless opaque | 384x384 (source 1024) | wall blocks top | done | - |
| `wall_ruin_face` | texture | seamless opaque | 384x384 (source 1024) | wall block front | done | - |
| `water` | texture | seamless opaque | 384x384 (source 1024) | ponds | done | - |
| `pond_bank` | texture | seamless opaque | 384x384 (source 1024) | pond shore | done | - |
| `ground_cave` | texture | seamless opaque | 384x384 (source 1024) | cave floor | done | - |
| `wall_cave` | texture | seamless opaque | 384x384 (source 1024) | cave border | done | - |
| `tex_path_dirt` | texture | seamless opaque | 384x384 (source 1024) | brackwater: village roads and paths | todo | 1 x 3 = 3 |
| `tex_ground_garden` | texture | seamless opaque | 384x384 (source 1024) | brackwater: village yards and gardens | todo | 1 x 3 = 3 |
| `tex_ground_thornwood` | texture | seamless opaque | 384x384 (source 1024) | thornwood: forest floor | todo | 1 x 3 = 3 |
| `tex_wall_thorn` | texture | seamless opaque | 384x384 (source 1024) | thornwood: thorn hedge border | todo | 1 x 3 = 3 |
| `tex_path_forest` | texture | seamless opaque | 384x384 (source 1024) | thornwood: trails | todo | 1 x 3 = 3 |
| `tex_ground_ash` | texture | seamless opaque | 384x384 (source 1024) | cinderflats: burnt plains floor | todo | 1 x 3 = 3 |
| `tex_ground_slag` | texture | seamless opaque | 384x384 (source 1024) | cinderflats: slag roads | todo | 1 x 3 = 3 |
| `tex_wall_cinder` | texture | seamless opaque | 384x384 (source 1024) | cinderflats: burnt cliff top | todo | 1 x 3 = 3 |
| `tex_wall_cinder_face` | texture | seamless opaque | 384x384 (source 1024) | cinderflats: cliff front face | todo | 1 x 3 = 3 |
| `tex_ground_fen` | texture | seamless opaque | 384x384 (source 1024) | tallowfen: peat marsh floor | todo | 1 x 3 = 3 |
| `tex_boardwalk_planks` | texture | seamless opaque | 384x384 (source 1024) | tallowfen: boardwalk floor | todo | 1 x 3 = 3 |
| `tex_water_lake` | texture | seamless opaque | 384x384 (source 1024) | tallowfen: great lake, deep | todo | 1 x 3 = 3 |
| `tex_lake_shore` | texture | seamless opaque | 384x384 (source 1024) | tallowfen: lake mud shore | todo | 1 x 3 = 3 |
| `tex_wall_fen` | texture | seamless opaque | 384x384 (source 1024) | tallowfen: reed and peat bank | todo | 1 x 3 = 3 |
| `tex_ground_gravel` | texture | seamless opaque | 384x384 (source 1024) | gravelight: stone terrace floor | todo | 1 x 3 = 3 |
| `tex_path_flagstone` | texture | seamless opaque | 384x384 (source 1024) | gravelight: terraces and stairs | todo | 1 x 3 = 3 |
| `tex_wall_cliff` | texture | seamless opaque | 384x384 (source 1024) | gravelight: cliff top | todo | 1 x 3 = 3 |
| `tex_wall_cliff_face` | texture | seamless opaque | 384x384 (source 1024) | gravelight: cliff face | todo | 1 x 3 = 3 |
| `tex_ground_salt` | texture | seamless opaque | 384x384 (source 1024) | hushmarch: salt shingle floor | todo | 1 x 3 = 3 |
| `tex_ground_wreck` | texture | seamless opaque | 384x384 (source 1024) | hushmarch: rusted plate decking | todo | 1 x 3 = 3 |
| `tex_wall_wreck` | texture | seamless opaque | 384x384 (source 1024) | hushmarch: rusted hull wall top | todo | 1 x 3 = 3 |
| `tex_wall_wreck_face` | texture | seamless opaque | 384x384 (source 1024) | hushmarch: hull front face | todo | 1 x 3 = 3 |
| `tex_water_sea` | texture | seamless opaque | 384x384 (source 1024) | hushmarch: grey sea | todo | 1 x 3 = 3 |
| `edge_grass_to_thorn` | texture | alpha edge strip (soft ragged blend of region ground over the neighbour), 384x96 tile, seamless along length | 384x96 | Brackwater to Thornwood | todo | 1 x 3 = 3 |
| `edge_thorn_to_ash` | texture | alpha edge strip (soft ragged blend of region ground over the neighbour), 384x96 tile, seamless along length | 384x96 | Thornwood to Cinderflats | todo | 1 x 3 = 3 |
| `edge_grass_to_fen` | texture | alpha edge strip (soft ragged blend of region ground over the neighbour), 384x96 tile, seamless along length | 384x96 | Brackwater/Thornwood to Tallowfen | todo | 1 x 3 = 3 |
| `edge_fen_to_gravel` | texture | alpha edge strip (soft ragged blend of region ground over the neighbour), 384x96 tile, seamless along length | 384x96 | Tallowfen to Gravelight | todo | 1 x 3 = 3 |
| `edge_ash_to_gravel` | texture | alpha edge strip (soft ragged blend of region ground over the neighbour), 384x96 tile, seamless along length | 384x96 | Cinderflats to Gravelight | todo | 1 x 3 = 3 |
| `edge_gravel_to_salt` | texture | alpha edge strip (soft ragged blend of region ground over the neighbour), 384x96 tile, seamless along length | 384x96 | Gravelight to Hushmarch | todo | 1 x 3 = 3 |
| `edge_ash_to_salt` | texture | alpha edge strip (soft ragged blend of region ground over the neighbour), 384x96 tile, seamless along length | 384x96 | Cinderflats to Hushmarch | todo | 1 x 3 = 3 |
| `edge_path_border` | texture | path/road border overlay, alpha strip | 384x96 | all regions | todo | 1 x 3 = 3 |
| `edge_shore_foam` | texture | lake and sea shore foam overlay, alpha strip | 384x96 | Tallowfen, Hushmarch | todo | 1 x 3 = 3 |
| `edge_cliff_shadow` | texture | cliff base shadow overlay, alpha strip | 384x96 | Cinderflats, Gravelight | todo | 1 x 3 = 3 |
| `tex_ground_c1` | texture | seamless opaque | 384x384 (source 1024) | C1 (Wick Cellar): floor, kiln flagstone with soot | todo | 1 x 3 = 3 |
| `tex_wall_c1` | texture | seamless opaque | 384x384 (source 1024) | C1: wall top, soot brick wall | todo | 1 x 3 = 3 |
| `tex_wall_face_c1` | texture | seamless vertical elevation, no top edge | 384x384 (source 1024) | C1: wall front face | todo | 1 x 3 = 3 |
| `tex_special_c1` | texture | seamless opaque | 384x384 (source 1024) | C1: ember grate floor | todo | 1 x 3 = 3 |
| `tex_ground_c2` | texture | seamless opaque | 384x384 (source 1024) | C2 (Briar Hollow): floor, root floor with packed earth | todo | 1 x 3 = 3 |
| `tex_wall_c2` | texture | seamless opaque | 384x384 (source 1024) | C2: wall top, tangled root wall | todo | 1 x 3 = 3 |
| `tex_wall_face_c2` | texture | seamless vertical elevation, no top edge | 384x384 (source 1024) | C2: wall front face | todo | 1 x 3 = 3 |
| `tex_special_c2` | texture | seamless opaque | 384x384 (source 1024) | C2: thorn canopy shadow overlay | todo | 1 x 3 = 3 |
| `tex_ground_c3` | texture | seamless opaque | 384x384 (source 1024) | C3 (Drowned Wick Works): floor, wet iron grating and flagstone | todo | 1 x 3 = 3 |
| `tex_wall_c3` | texture | seamless opaque | 384x384 (source 1024) | C3: wall top, rusted pipe and brick wall | todo | 1 x 3 = 3 |
| `tex_wall_face_c3` | texture | seamless vertical elevation, no top edge | 384x384 (source 1024) | C3: wall front face | todo | 1 x 3 = 3 |
| `tex_special_c3` | texture | seamless opaque | 384x384 (source 1024) | C3: black water | todo | 1 x 3 = 3 |
| `tex_ground_c4` | texture | seamless opaque | 384x384 (source 1024) | C4 (Sleeping Foundry): floor, cold slag plates | todo | 1 x 3 = 3 |
| `tex_wall_c4` | texture | seamless opaque | 384x384 (source 1024) | C4: wall top, iron and slag wall | todo | 1 x 3 = 3 |
| `tex_wall_face_c4` | texture | seamless vertical elevation, no top edge | 384x384 (source 1024) | C4: wall front face | todo | 1 x 3 = 3 |
| `tex_special_c4` | texture | seamless opaque | 384x384 (source 1024) | C4: cooled slag pour | todo | 1 x 3 = 3 |
| `tex_ground_c5` | texture | seamless opaque | 384x384 (source 1024) | C5 (Mirrored Archive): floor, polished stone with faint reflections | todo | 1 x 3 = 3 |
| `tex_wall_c5` | texture | seamless opaque | 384x384 (source 1024) | C5: wall top, polished stone with faces | todo | 1 x 3 = 3 |
| `tex_wall_face_c5` | texture | seamless vertical elevation, no top edge | 384x384 (source 1024) | C5: wall front face | todo | 1 x 3 = 3 |
| `tex_special_c5` | texture | seamless opaque | 384x384 (source 1024) | C5: mirror floor inlay | todo | 1 x 3 = 3 |
| `tex_ground_c6` | texture | seamless opaque | 384x384 (source 1024) | C6 (Choir Vault): floor, engraved ripple-line tiles | todo | 1 x 3 = 3 |
| `tex_wall_c6` | texture | seamless opaque | 384x384 (source 1024) | C6: wall top, organ-pipe wall | todo | 1 x 3 = 3 |
| `tex_wall_face_c6` | texture | seamless vertical elevation, no top edge | 384x384 (source 1024) | C6: wall front face | todo | 1 x 3 = 3 |
| `tex_special_c6` | texture | seamless opaque | 384x384 (source 1024) | C6: bell-metal inlay | todo | 1 x 3 = 3 |
| `tex_ground_c7` | texture | seamless opaque | 384x384 (source 1024) | C7 (Hall of Nerve): floor, cracked fort flagstone | todo | 1 x 3 = 3 |
| `tex_wall_c7` | texture | seamless opaque | 384x384 (source 1024) | C7: wall top, battlement stone wall | todo | 1 x 3 = 3 |
| `tex_wall_face_c7` | texture | seamless vertical elevation, no top edge | 384x384 (source 1024) | C7: wall front face | todo | 1 x 3 = 3 |
| `tex_special_c7` | texture | seamless opaque | 384x384 (source 1024) | C7: pit void + rim | todo | 1 x 3 = 3 |
| `tex_ground_c8` | texture | seamless opaque | 384x384 (source 1024) | C8 (Counting House): floor, brass-inlaid marble | todo | 1 x 3 = 3 |
| `tex_wall_c8` | texture | seamless opaque | 384x384 (source 1024) | C8: wall top, brass vault panel wall | todo | 1 x 3 = 3 |
| `tex_wall_face_c8` | texture | seamless vertical elevation, no top edge | 384x384 (source 1024) | C8: wall front face | todo | 1 x 3 = 3 |
| `tex_special_c8` | texture | seamless opaque | 384x384 (source 1024) | C8: coin-strewn floor | todo | 1 x 3 = 3 |
| `tex_ground_c9` | texture | seamless opaque | 384x384 (source 1024) | C9 (Corrow's Undercroft): floor, workshop plank and stone with chalk marks | todo | 1 x 3 = 3 |
| `tex_wall_c9` | texture | seamless opaque | 384x384 (source 1024) | C9: wall top, mural-plastered wall | todo | 1 x 3 = 3 |
| `tex_wall_face_c9` | texture | seamless vertical elevation, no top edge | 384x384 (source 1024) | C9: wall front face | todo | 1 x 3 = 3 |
| `tex_special_c9` | texture | seamless opaque | 384x384 (source 1024) | C9: workshop floor decals | todo | 1 x 3 = 3 |
| `tex_ground_c10` | texture | seamless opaque | 384x384 (source 1024) | C10 (Ninth Hollow): floor, wax and root floor | todo | 1 x 3 = 3 |
| `tex_wall_c10` | texture | seamless opaque | 384x384 (source 1024) | C10: wall top, wax-dripped rock wall | todo | 1 x 3 = 3 |
| `tex_wall_face_c10` | texture | seamless vertical elevation, no top edge | 384x384 (source 1024) | C10: wall front face | todo | 1 x 3 = 3 |
| `tex_special_c10` | texture | seamless opaque | 384x384 (source 1024) | C10: wax pool | todo | 1 x 3 = 3 |
| `tex_water_black` | texture | seamless opaque; black water for caves | 384x384 (source 1024) | C3, C9, C10 shallows and deep water | todo | 1 x 3 = 3 |
| `edge_cave_floor_to_wall` | texture | alpha overlay strip 384x96 | 384x384 (source 1024) | all caves | todo | 1 x 3 = 3 |
| `edge_cave_water` | texture | alpha overlay strip 384x96 | 384x384 (source 1024) | C3, C9, C10 water edge | todo | 1 x 3 = 3 |

### 2.3 Regular monsters

The nine new regular monsters of `monsters-bosses-tools.md` section 2 plus the seven existing types. Cells follow the contract families (128 for small, 192 for the hollow-size figures). Hurt flashes use `modulate`; the shared death effect is `fx_enemy_poof`.

| id | source | animations (frames) | cell | used in | status | units x var |
|---|---|---|---|---|---|---|
| `hollow` | sprite sheet | walk_{d,u,s} 4 | 192 foot 176 | Brackwater, Thornwood, Cinderflats, Tallowfen, Gravelight, Hushmarch | done | - |
| `spitcap` | sprite sheet | walk 4, spit 2 | 128 foot 116 | Brackwater, Thornwood, Cinderflats, Tallowfen, Gravelight, Hushmarch | done | - |
| `skitterwick` | sprite sheet | idle 2, crouch 1, hop 2 | 128 foot 116 | Brackwater, Thornwood, Cinderflats, Tallowfen, Gravelight, Hushmarch | done | - |
| `duskmoth` | sprite sheet | rest 2, fly 4 | 128 foot 116 | Brackwater, Thornwood, Cinderflats, Tallowfen, Gravelight, Hushmarch | done | - |
| `tallow_blob` | sprite sheet | move 4 | 128 foot 116 | Brackwater, Thornwood, Cinderflats, Tallowfen, Gravelight, Hushmarch | done | - |
| `tallow_drop` | sprite sheet | move 3 | 64 foot 58 | Brackwater, Thornwood, Cinderflats, Tallowfen, Gravelight, Hushmarch | done | - |
| `spore` | sprite sheet | fly 2 | 64 centred | Brackwater, Thornwood, Cinderflats, Tallowfen, Gravelight, Hushmarch | done | - |
| `bramble_snapper` | sprite sheet | idle 2 (sway), telegraph 2 (jaws spread), snap 2, burn_away 3; one direction | 192x192 foot 176 | Thornwood; C2 | todo | 1 x 3 = 3 |
| `fen_leech` | sprite sheet | surface 3, idle_surfaced 2, telegraph 2 (bubbles), lunge 2, dive 3; one direction (side, mirrored) | 192x192 foot 176 | Tallowfen, Mirrormere; C3, C9, C10 | todo | 1 x 3 = 3 |
| `cinder_wisp` | sprite sheet | float 4, swell 2 (telegraph glow); one direction | 128x128 centred | Cinderflats; C4 | todo | 1 x 3 = 3 |
| `watcher_eye` | sprite sheet | lid_closed 1, opening 3, open 1, fire 2; per wall facing {down, up, side} | 128x128 | Gravelight; C10 | todo | 3 x 3 = 9 |
| `husk_hound_walk` | sprite sheet | walk_{d,u,s} 4 (prowl and charge share it) | 192x192 foot 176 | Hushmarch; C10 | todo | 3 x 3 = 9 |
| `husk_hound_states` | sprite sheet | crouch 1, charge 2, dizzy 2, circle-run reuses charge; side only | 192x192 foot 176 | Hushmarch; C10 | todo | 1 x 3 = 3 |
| `brine_crab_walk` | sprite sheet | sidestep_{d,u,s} 4 | 192x192 foot 176 | Hushmarch; C8, C10 | todo | 3 x 3 = 9 |
| `brine_crab_states` | sprite sheet | claws_up 1, lunge 2, guard_spark pose 1; side only | 192x192 foot 176 | Hushmarch; C8, C10 | todo | 1 x 3 = 3 |
| `wickling` | sprite sheet | run 4, pause 1, melt (death) 3; one direction, packs of 2-3 | 96x96 foot 88 | C1, C3, C5, C8, C9, C10 | todo | 1 x 3 = 3 |
| `mirror_shade_walk` | sprite sheet | walk_{d,u,s} 4 (flat dark silhouette of Tamsin, pale outline) | 192x192 foot 176 | C5, C10 | todo | 3 x 3 = 9 |
| `mirror_shade_states` | sprite sheet | fade_in 3 (down), echo_swing 3 (side), decoy_crack 2 (down) | 192x192 foot 176 | C5, C10 | todo | 3 x 3 = 9 |
| `choirling` | sprite sheet | hover 4, telegraph 2 (mouth opening), sing 2; one direction | 128x128 centred | C6, C10 | todo | 1 x 3 = 3 |

### 2.4 Tools, pickups and item icons

Ten sub-items in the item subscreen grid (5x2): tether moth, pitch pot and the eight new tools. Icons are 128x128 and drawn without a background; the silhouette for unfound items is made by code from the icon alpha. World sprites are the item on its pedestal; the in-use effects and projectiles of each tool are rows below. Pickup art that exists: ember, brass bit, brass coin, pot bundle, key, wick core.

| id | source | animations (frames) | cell | used in | status | units x var |
|---|---|---|---|---|---|---|
| `icon_tether_moth` | UI icon | Tether Moth inventory icon, 1 frame (shown in item frame and subscreen; code makes the silhouette) | 128x128 | ow_0_1; HUD, subscreen | todo | 1 x 3 = 3 |
| `icon_pitch_pot` | UI icon | Pitch Pot inventory icon, 1 frame (shown in item frame and subscreen; code makes the silhouette) | 128x128 | ow_2_1#closet; HUD, subscreen | todo | 1 x 3 = 3 |
| `icon_cinder_wick` | UI icon | Cinder Wick inventory icon, 1 frame (shown in item frame and subscreen; code makes the silhouette) | 128x128 | C1; HUD, subscreen | todo | 1 x 3 = 3 |
| `icon_tallow_sling` | UI icon | Tallow Sling inventory icon, 1 frame (shown in item frame and subscreen; code makes the silhouette) | 128x128 | C2; HUD, subscreen | todo | 1 x 3 = 3 |
| `icon_reed_raft` | UI icon | Reed Raft inventory icon, 1 frame (shown in item frame and subscreen; code makes the silhouette) | 128x128 | C3; HUD, subscreen | todo | 1 x 3 = 3 |
| `icon_heft_mitts` | UI icon | Heft Mitts inventory icon, 1 frame (shown in item frame and subscreen; code makes the silhouette) | 128x128 | C4; HUD, subscreen | todo | 1 x 3 = 3 |
| `icon_glow_jar` | UI icon | Glow Jar inventory icon, 1 frame (shown in item frame and subscreen; code makes the silhouette) | 128x128 | C5; HUD, subscreen | todo | 1 x 3 = 3 |
| `icon_lantern_chime` | UI icon | Lantern Chime inventory icon, 1 frame (shown in item frame and subscreen; code makes the silhouette) | 128x128 | C6; HUD, subscreen | todo | 1 x 3 = 3 |
| `icon_skitter_boots` | UI icon | Skitter Boots inventory icon, 1 frame (shown in item frame and subscreen; code makes the silhouette) | 128x128 | C7; HUD, subscreen | todo | 1 x 3 = 3 |
| `icon_reel_line` | UI icon | Reel Line inventory icon, 1 frame (shown in item frame and subscreen; code makes the silhouette) | 128x128 | C8; HUD, subscreen | todo | 1 x 3 = 3 |
| `item_cinder_wick` | sprite sheet | Cinder Wick world pickup on its pedestal, idle 1 + glint 3 | 96x96 foot 88 | C1 item room | todo | 1 x 3 = 3 |
| `item_tallow_sling` | sprite sheet | Tallow Sling world pickup on its pedestal, idle 1 + glint 3 | 96x96 foot 88 | C2 item room | todo | 1 x 3 = 3 |
| `item_reed_raft` | sprite sheet | Reed Raft world pickup on its pedestal, idle 1 + glint 3 | 96x96 foot 88 | C3 item room | todo | 1 x 3 = 3 |
| `item_heft_mitts` | sprite sheet | Heft Mitts world pickup on its pedestal, idle 1 + glint 3 | 96x96 foot 88 | C4 item room | todo | 1 x 3 = 3 |
| `item_glow_jar` | sprite sheet | Glow Jar world pickup on its pedestal, idle 1 + glint 3 | 96x96 foot 88 | C5 item room | todo | 1 x 3 = 3 |
| `item_lantern_chime` | sprite sheet | Lantern Chime world pickup on its pedestal, idle 1 + glint 3 | 96x96 foot 88 | C6 item room | todo | 1 x 3 = 3 |
| `item_skitter_boots` | sprite sheet | Skitter Boots world pickup on its pedestal, idle 1 + glint 3 | 96x96 foot 88 | C7 item room | todo | 1 x 3 = 3 |
| `item_reel_line` | sprite sheet | Reel Line world pickup on its pedestal, idle 1 + glint 3 | 96x96 foot 88 | C8 item room | todo | 1 x 3 = 3 |
| `icon_hook_flare_ward` | UI icon | 3 base-kit icons (hook, flare, ward), 1 frame each (unlisted in the grid, used in the pause menu) | 128x128 | pause menu | todo | 3 x 3 = 9 |
| `flame_cinder` | sprite sheet | rolling flame 4, standing flame 4, fade 3 | 96x96 foot 88 | C1 cinder wick, thorn hedges | todo | 1 x 3 = 3 |
| `slug_tallow` | sprite sheet | slug in flight 2, impact splat 3 | 64x64 centred | C2 sling | todo | 1 x 3 = 3 |
| `reed_raft_vehicle` | sprite sheet | raft under Tamsin: idle bob 2, board 3, dock 2 | 256x256 foot 220 | C3 lake, moorings | todo | 1 x 3 = 3 |
| `jar_thrown` | sprite sheet | jar tumbling 4, shatter 3 | 64x64 centred | C5 jar | todo | 1 x 3 = 3 |
| `jar_lit` | sprite sheet | lit jar glowing on the ground: loop 4 | 96x96 foot 88 | C5 jar | todo | 1 x 3 = 3 |
| `reel_tip` | sprite sheet | hook tip 2 frames; the line itself is a tiling rope texture | 96x96 centred | C8 reel line | todo | 1 x 3 = 3 |
| `reel_line_rope` | texture | seamless rope/line strip, tiles along its length (alpha strip 16x96) | 96x16 tile | C8 reel line | todo | 1 x 3 = 3 |
| `liftable_rock_small` | sprite sheet | small rock 1, urn 1, wooden crate 1, break puff 4 (liftable and throwable things) | 96x96 foot 88 | C4, caves, Gravelight | todo | 1 x 3 = 3 |
| `slug_bundle` | sprite sheet | tallow slug bundle pickup, idle 1 + glint 3 | 64x64 foot 58 | shops, drops, C2/C9/C10 | todo | 1 x 3 = 3 |
| `pot_bag` | sprite sheet | pot bag (carry upgrade) pickup, idle 1 + glint 3 | 64x64 foot 58 | ow_7_2#bag, ow_10_1#hut | todo | 1 x 3 = 3 |
| `tallow_flask` | sprite sheet | tallow flask (full heal) pickup, idle 1 + glint 3 | 64x64 foot 58 | shops | todo | 1 x 3 = 3 |
| `ember` | sprite sheet | idle 1 (source: pickups sheet) | 64x64 foot 58 | everywhere | done | - |
| `brass_bit` | sprite sheet | idle 1 (source: pickups sheet) | 64x64 foot 58 | everywhere | done | - |
| `brass_coin` | sprite sheet | idle 1 (source: pickups sheet) | 64x64 foot 58 | everywhere | done | - |
| `pitch_pot_bundle` | sprite sheet | idle 1 (source: pickups sheet) | 64x64 foot 58 | everywhere | done | - |
| `key` | sprite sheet | idle 1 (source: pickups sheet) | 64x64 foot 58 | everywhere | done | - |
| `wick_core` | sprite sheet | idle 1 (source: pickups sheet) | 64x64 foot 58 | everywhere | done | - |
| `bigkey` | sprite sheet | big key (lantern-shaped bow), idle 1 + glint 3 | 96x96 foot 88 | 10 caves, one per cave (tinted by code) | todo | 1 x 3 = 3 |
| `fragment_c1_to_c9` | sprite sheet | nine lantern fragments, each a distinct glass shard with its own light colour (Warmth, Growth, Rain, Sleep, Memory, Song, Courage, Trade, Corrow's Last Wick): idle glow 4 | 96x96 foot 88 | C1-C9 boss drops; HUD | todo | 9 x 3 = 27 |
| `slag_chunk` | sprite sheet | slag chunk obstacle 1, hit 2 | 96x96 | C4 Lull-Mauler | todo | 1 x 3 = 3 |

### 2.5 Props

Props are anchored at the bottom centre of the collision rectangle (contract section 7). Gate props with a state list the frames of the opening. The 15 base prop families are done. Counts for the gate families follow `world-work-packages.md` section 6.1 (P01 to P15).

| id | source | animations (frames) | cell | used in | status | units x var |
|---|---|---|---|---|---|---|
| `brazier` | sprite sheet | idle 1 + brazier_lit burn 4 | 128x192 | caves | done | - |
| `bush` | sprite sheet | idle 1 | 128x128 | B, T | done | - |
| `rock_a` | sprite sheet | idle 1 | 128x128 | all overworld | done | - |
| `rock_b` | sprite sheet | idle 1 | 128x128 | all overworld | done | - |
| `tree_a` | sprite sheet | idle 1 | 192x288 | B, T, A | done | - |
| `tree_b` | sprite sheet | idle 1 | 192x288 | B, T | done | - |
| `reed` | sprite sheet | idle 1 | 128x128 | F | done | - |
| `sign_post` | sprite sheet | idle 1 | 96x160 | all | done | - |
| `pedestal` | sprite sheet | idle 1 | 128x128 | items | done | - |
| `hut` | sprite sheet | idle 1 | 384x416 | B | done | - |
| `locked_door` | sprite sheet | idle 1 | 192x192 | key gates | done | - |
| `gate` | sprite sheet | idle 1 | 192x192 | brazier gates | done | - |
| `cracked_wall` | sprite sheet | idle 1 | 128x192 | pot gates | done | - |
| `cave_mouth` | sprite sheet | idle 1 | 192x192 | 10 mouths | done | - |
| `cave_exit` | sprite sheet | idle 1 | 192x192 | cave entrances | done | - |
| `thorn_hedge` | sprite sheet | closed 1, burning 5, burnt open 1 | 192x192 | ow_2_0, B-T border; gate for cinder wick | todo | 1 x 3 = 3 |
| `thorn_wall` | sprite sheet | closed 1, burning 5, burnt open 1 (cave wall segment) | 192x192 | C2, C9, C10 | todo | 1 x 3 = 3 |
| `thorn_door` | sprite sheet | thorn-sealed door 1, burning 5, open 1 | 192x192 | ow_3_3#hut | todo | 1 x 3 = 3 |
| `eye_switch` | sprite sheet | off 1, hit 2, on 1 (carved stone eye) | 128x128 | Thornwood, Gravelight, C2, C4, C8, C10 | todo | 1 x 3 = 3 |
| `eye_portcullis` | sprite sheet | closed 1, opening 4, open 1 | 192x192 | ow_7_1 Eyegate; C2 | todo | 1 x 3 = 3 |
| `eye_cell` | sprite sheet | iron cell door with eye: closed 1, opening 3, open 1 | 192x192 | C9 cell | todo | 1 x 3 = 3 |
| `mooring` | sprite sheet | post with rope: idle 2 (sway), occupied 1 | 96x160 | 22 lake links, C3, C9, C10 | todo | 1 x 3 = 3 |
| `pit_edge` | sprite sheet | pit/ravine rim: straight, inner and outer corner (3 tiles, alpha overlays) | 96x96 each | C7, ravines, C8-C10 | todo | 1 x 3 = 3 |
| `pit_fill` | texture | dark void with faint depth fade (seamless) | 384x384 | C7, Hushmarch ravine | todo | 1 x 3 = 3 |
| `low_rail` | sprite sheet | low iron rail 2 variants (leapable)  | 192x96 | C7, Gravelight | todo | 1 x 3 = 3 |
| `anchor_ring` | sprite sheet | iron ring on stone post: idle 1, targeted glow 2 | 128x160 | Anchor Ledge, C8-C10 | todo | 1 x 3 = 3 |
| `anchor_pocket` | sprite sheet | ring set in a cliff pocket: idle 1, glow 2 | 192x192 | ow_8_8 | todo | 1 x 3 = 3 |
| `heavy_stone` | sprite sheet | heavy stone: sitting 1, lifted 1, shattered 3 | 192x192 | ow_9_3, C4, C9, C10 | todo | 1 x 3 = 3 |
| `heavy_boulder` | sprite sheet | pushable boulder, 1; push-step dust 3 | 192x192 | ow_6_6 (mouth of C6) | todo | 1 x 3 = 3 |
| `heavy_door` | sprite sheet | heavy slab door: closed 1, pushed 1 | 192x192 | C6 | todo | 1 x 3 = 3 |
| `heavy_stones` | sprite sheet | pair of heavy stones blocking a gap: 1 + shattered 3 | 192x192 | ow_9_3 | todo | 1 x 3 = 3 |
| `resonance_stone` | sprite sheet | dormant 1, awake ring glow 4 | 128x192 | C6, C10 | todo | 1 x 3 = 3 |
| `resonance_door` | sprite sheet | dormant 1, awake 4, open 1 | 192x192 | ow_9_7 (mouth of C8) | todo | 1 x 3 = 3 |
| `resonance_vault` | sprite sheet | dormant 1, awake 4, open 1 | 192x192 | C9 vault | todo | 1 x 3 = 3 |
| `hidden_seam` | sprite sheet | faint scuff overlay: hidden 1, revealed 3 | 128x128 | jar gates | todo | 1 x 3 = 3 |
| `hidden_stairs` | sprite sheet | sealed 1, revealed stairs going down 3 | 192x192 | ow_10_2, ow_0_2 | todo | 1 x 3 = 3 |
| `sealed_seam` | sprite sheet | seam in rock: hidden 1, revealed 3, open 1 | 192x192 | ow_11_7, C5 | todo | 1 x 3 = 3 |
| `hook_tap_wall` | sprite sheet | hollow-sounding wall: idle 1, tapped 2, open 1 | 128x192 | ow_8_0 | todo | 1 x 3 = 3 |
| `grate` | sprite sheet | iron grate over alcove, 1 + key visible behind 1 | 128x128 | ow_3_2 | todo | 1 x 3 = 3 |
| `boss_door` | sprite sheet | big lantern-lock door: closed 1, unlocking 4, open 1 | 192x288 | 10 caves | todo | 1 x 3 = 3 |
| `ninth_door` | sprite sheet | giant sealed door with nine fragment sockets: sealed 1, socket glow overlay 9, opening 6, open 1 | 576x480 | ow_10_8 | todo | 1 x 3 = 3 |
| `wax_seal` | sprite sheet | seal: closed 1, melting 5, open 1 | 192x192 | ow_9_0, C4 (flare) | todo | 1 x 3 = 3 |
| `reed_cluster` | sprite sheet | cut screen: whole 1, cut 3 (hook) | 192x192 | hook gates (reed_cluster) | todo | 1 x 3 = 3 |
| `rush_wall` | sprite sheet | cut screen: whole 1, cut 3 (hook) | 192x192 | hook gates (rush_wall) | todo | 1 x 3 = 3 |
| `moss_wall` | sprite sheet | cut screen: whole 1, cut 3 (hook) | 192x192 | hook gates (moss_wall) | todo | 1 x 3 = 3 |
| `dry_vine_screen` | sprite sheet | cut screen: whole 1, cut 3 (hook) | 192x192 | hook gates (dry_vine_screen) | todo | 1 x 3 = 3 |
| `bush_cluster` | sprite sheet | cut screen: whole 1, cut 3 (hook) | 192x192 | hook gates (bush_cluster) | todo | 1 x 3 = 3 |
| `brittle_rocks` | sprite sheet | rock pile: whole 1, blasted 1 (rubble) | 192x192 | pot gates | todo | 1 x 3 = 3 |
| `pocket_stall` | sprite sheet | entrance: closed 1 / open 1 | 192x192 | pocket entrance (stall) | todo | 1 x 3 = 3 |
| `pocket_cart` | sprite sheet | entrance: closed 1 / open 1 | 192x192 | pocket entrance (cart) | todo | 1 x 3 = 3 |
| `pocket_lighthouse_door` | sprite sheet | entrance: closed 1 / open 1 | 192x192 | pocket entrance (lighthouse_door) | todo | 1 x 3 = 3 |
| `pocket_mason_door` | sprite sheet | entrance: closed 1 / open 1 | 192x192 | pocket entrance (mason_door) | todo | 1 x 3 = 3 |
| `pocket_hut_door` | sprite sheet | entrance: closed 1 / open 1 | 192x192 | pocket entrance (hut_door) | todo | 1 x 3 = 3 |
| `pocket_grotto` | sprite sheet | entrance: closed 1 / open 1 | 192x192 | pocket entrance (grotto) | todo | 1 x 3 = 3 |
| `pocket_stairs_down` | sprite sheet | entrance: closed 1 / open 1 | 192x192 | pocket entrance (stairs_down) | todo | 1 x 3 = 3 |
| `pocket_plain_door` | sprite sheet | entrance: closed 1 / open 1 | 192x192 | pocket entrance (plain_door) | todo | 1 x 3 = 3 |
| `shop_counter` | sprite sheet | shop counter with shelf and pedestals | 384x192 | 6 shops | todo | 1 x 3 = 3 |
| `ward_plate` | sprite sheet | stone pad: idle 1, lit 3 | 128x128 | ward puzzles | todo | 1 x 3 = 3 |
| `street_lamp` | sprite sheet | unlit 1, lit 3 (loop) | 96x192 | Brackwater; Tamsin's lamplighting | todo | 1 x 3 = 3 |
| `wall_torch` | sprite sheet | lit torch on a bracket: burn 4 | 96x160 | caves | todo | 1 x 3 = 3 |
| `pillar` | sprite sheet | stone pillar (C1) 1 + variants cave-themed: wax, root, brass | 96x192 | C1, C5-C8 (3 variants) | todo | 3 x 3 = 9 |
| `lectern` | sprite sheet | reading lectern, half height | 96x128 | C5 arena | todo | 1 x 3 = 3 |
| `statue_eye` | sprite sheet | stone statue with carved eye, 2 variants | 128x192 | Gravelight | todo | 1 x 3 = 3 |
| `statue_figure` | sprite sheet | lamplighter statue, 2 variants | 128x192 | Gravelight, C6, C10 | todo | 2 x 3 = 6 |
| `crate_stack` | sprite sheet | wood crate 2 variants + stack 1 | 96x128 | Gravelight quarry, Hushmarch, C8 | todo | 3 x 3 = 9 |
| `cold_furnace` | sprite sheet | cold furnace/forge, 1 | 192x192 | Cinderflats, C4 | todo | 1 x 3 = 3 |
| `anvil` | sprite sheet | anvil + slag pour set | 128x128 | C4 | todo | 1 x 3 = 3 |
| `slag_heap` | sprite sheet | slag heap 2 variants | 128x128 | Cinderflats, C4 | todo | 2 x 3 = 6 |
| `glass_shards` | sprite sheet | fused glass shard cluster 2 variants | 128x128 | Cinderflats | todo | 2 x 3 = 6 |
| `dead_tree` | sprite sheet | burnt tree 2 variants | 192x288 | Cinderflats | todo | 2 x 3 = 6 |
| `thorn_bramble` | sprite sheet | bramble clump 2 variants | 128x128 | Thornwood, C2 | todo | 2 x 3 = 6 |
| `fallen_log` | sprite sheet | fallen log + mushrooms | 192x96 | Thornwood | todo | 1 x 3 = 3 |
| `root_bridge` | sprite sheet | bridge segments: straight 1, end 1 | 192x96 | Thornwood | todo | 1 x 3 = 3 |
| `boardwalk` | sprite sheet | plank boardwalk tile strip, straight 1, end 1, corner 1 | 96x96 | Tallowfen | todo | 3 x 3 = 9 |
| `dock_pier` | sprite sheet | wooden pier end with post | 192x192 | lake shores, C3 | todo | 1 x 3 = 3 |
| `wax_vat` | sprite sheet | rusted wax vat 2 variants + pipe 1 | 192x192 | Tallowfen, C3 | todo | 3 x 3 = 9 |
| `lily_pads` | sprite sheet | lily pad cluster, animated sway 3 | 128x128 | ponds, lake | todo | 1 x 3 = 3 |
| `shipwreck` | sprite sheet | beached wreck, 2 variants | 384x384 | Hushmarch | todo | 2 x 3 = 6 |
| `rusted_lantern_post` | sprite sheet | rusted lantern post, dark 1 | 96x192 | Hushmarch | todo | 1 x 3 = 3 |
| `salt_crystals` | sprite sheet | salt crystal cluster 2 variants | 128x128 | Hushmarch | todo | 2 x 3 = 6 |
| `driftwood_net` | sprite sheet | driftwood pile + net | 160x128 | Hushmarch | todo | 1 x 3 = 3 |
| `well_haystack` | sprite sheet | village well + haystack | 160x160 | Brackwater | todo | 2 x 3 = 6 |
| `cottage` | sprite sheet | small village cottage (second design next to the hut) | 288x320 | Brackwater | todo | 1 x 3 = 3 |
| `ledge_drop` | sprite sheet | cliff ledge edge with shadow: straight 1, corner 1 | 96x96 | ow_4_2, ow_4_5 | todo | 1 x 3 = 3 |
| `bell` | sprite sheet | bell + organ-pipe wall pieces 3 designs | 160x224 | C6 | todo | 3 x 3 = 9 |
| `pump_pipe` | sprite sheet | pump/sluice valve 2 variants + pipe segment | 160x160 | C3 | todo | 3 x 3 = 9 |
| `mirror_panel` | sprite sheet | standing mirror panel: reflective 2 variants + cracked 1 | 128x224 | C5 | todo | 3 x 3 = 9 |
| `workbench` | sprite sheet | Corrow's workbench + shelves 2 | 192x160 | C9 | todo | 2 x 3 = 6 |
| `mural_panel` | sprite sheet | mural wall painting 4 variants (no readable text) | 288x192 | C9 and story rooms | todo | 4 x 3 = 12 |
| `letter_pile` | sprite sheet | scattered letters (no readable text) | 96x96 | C9 | todo | 1 x 3 = 3 |
| `arena_pedestal_lantern` | sprite sheet | ending: lit lantern on pedestal, 2 designs (rekindle / wickwarden) | 160x224 | C10 ending choice | todo | 2 x 3 = 6 |
| `cave_mouth_ashen` | sprite sheet | regional cave mouth: ash rock | 192x192 | C4, C7 | todo | 1 x 3 = 3 |
| `cave_mouth_fen` | sprite sheet | regional cave mouth: marsh tunnel and timber | 192x192 | C3, C5, C9 | todo | 1 x 3 = 3 |
| `cave_mouth_stone` | sprite sheet | regional cave mouth: carved stone | 192x192 | C6, C8 | todo | 1 x 3 = 3 |

### 2.6 Effects, projectiles and lights

Effects are centred sprites on a key background (alpha, soft). Projectiles: 2 flight frames and 3 impact frames in one strip, 96x96 unless stated. Lights are soft alpha radial textures for `PointLight2D`.

| id | source | animations (frames) | cell | used in | status | units x var |
|---|---|---|---|---|---|---|
| `explosion_burst` | sprite sheet | burst 6 | 384x384 centred | pitch pot, bosses | done | - |
| `fx_fire_small` | sprite sheet | loop 4 (small living flame: ground fire, torches) | 128x128 foot 118 | wick, torches | todo | 1 x 3 = 3 |
| `fx_fire_big` | sprite sheet | loop 4 (large flame, hedge burning) | 192x256 | thorn gates, Kilnkeeper | todo | 1 x 3 = 3 |
| `fx_ember_sparks` | sprite sheet | rise 4 (sparks over braziers and embers) | 128x128 | braziers | todo | 1 x 3 = 3 |
| `fx_smoke_puff` | sprite sheet | puff 5 | 192x192 | explosions, burnt things | todo | 1 x 3 = 3 |
| `fx_smoke_column` | sprite sheet | loop 4 (thin rising smoke) | 128x256 | Cinderflats, furnaces | todo | 1 x 3 = 3 |
| `fx_dust_puff` | sprite sheet | puff 4 | 128x128 | landing, pushing, leaps | todo | 1 x 3 = 3 |
| `fx_hit_spark` | sprite sheet | spark 3 (guard clink) | 96x96 | armour blocks | todo | 1 x 3 = 3 |
| `fx_enemy_poof` | sprite sheet | wax-dissolve death 5, with violet glow | 192x192 | all regular monsters | todo | 1 x 3 = 3 |
| `fx_water_splash` | sprite sheet | splash 5 | 192x192 | raft, leech, boots into water | todo | 1 x 3 = 3 |
| `fx_water_ripple` | sprite sheet | ring 4 | 128x128 | submerged leech, rain, raft wake | todo | 1 x 3 = 3 |
| `fx_raft_wake` | sprite sheet | wake trail 4 | 128x128 | raft | todo | 1 x 3 = 3 |
| `fx_wisp_burst` | sprite sheet | ring flame 5 | 384x384 | cinder wisp | todo | 1 x 3 = 3 |
| `fx_chime_ring` | sprite sheet | expanding ring 5, radius to 480 px | 512x512 | chime | todo | 1 x 3 = 3 |
| `fx_warp_out` | sprite sheet | warp swirl 6 | 384x384 | chime warp | todo | 1 x 3 = 3 |
| `fx_warp_in` | sprite sheet | warp arrival 6 | 384x384 | chime warp | todo | 1 x 3 = 3 |
| `fx_glow_burst` | sprite sheet | jar shatter glow 4 | 192x192 | glow jar | todo | 1 x 3 = 3 |
| `fx_leap_dust` | sprite sheet | leap start/land 4 | 128x128 | skitter boots | todo | 1 x 3 = 3 |
| `fx_reel_hit` | sprite sheet | tip hit 3 | 96x96 | reel line | todo | 1 x 3 = 3 |
| `fx_wax_splash` | sprite sheet | wax splash ring 5 | 384x384 | Kilnkeeper, drips | todo | 1 x 3 = 3 |
| `fx_ink_splatter` | sprite sheet | ink burst 4 | 192x192 | Archivist | todo | 1 x 3 = 3 |
| `fx_shockwave` | sprite sheet | shockwave ring 5 | 512x512 | Colossus | todo | 1 x 3 = 3 |
| `fx_floor_glow_tile` | sprite sheet | glowing tile erupting 4 | 96x96 | Colossus quake | todo | 1 x 3 = 3 |
| `fx_thorn_burst` | sprite sheet | seed/thorn burst 4 | 192x192 | Briar Mother | todo | 1 x 3 = 3 |
| `fx_boss_death_light` | sprite sheet | light release 8 | 768x768 | boss deaths C1-C9 | todo | 1 x 3 = 3 |
| `fx_boss_death_wax` | sprite sheet | wax collapse 8 | 768x768 | Unlit, minibosses | todo | 1 x 3 = 3 |
| `fx_rekindle_burst` | sprite sheet | lantern rekindle burst 8 | 768x768 | fragment pickup | todo | 1 x 3 = 3 |
| `fx_rekindle_motes` | sprite sheet | rising light motes loop 6 | 384x384 | fragment pickup, endings | todo | 1 x 3 = 3 |
| `fx_pickup_sparkle` | sprite sheet | sparkle 4 | 96x96 | pickups, heart gain | todo | 1 x 3 = 3 |
| `fx_heal_glow` | sprite sheet | heal ember glow 5 | 192x192 | flask, ember | todo | 1 x 3 = 3 |
| `fx_save_wick` | sprite sheet | autosave wick flicker 4 | 96x96 | save indicator | todo | 1 x 3 = 3 |
| `proj_slag_ball` | sprite sheet | projectile flight 2 + impact 3 | 96x96 centred | Kilnkeeper | todo | 1 x 3 = 3 |
| `proj_spore_bolt` | sprite sheet | projectile flight 2 + impact 3 | 96x96 centred | Briar Mother | todo | 1 x 3 = 3 |
| `proj_thorn_needle` | sprite sheet | projectile flight 2 + impact 3 | 96x96 centred | Thorn Warden | todo | 1 x 3 = 3 |
| `proj_ember_bolt` | sprite sheet | projectile flight 2 + impact 3 | 96x96 centred | Tidewick | todo | 1 x 3 = 3 |
| `proj_beam_bolt` | sprite sheet | projectile flight 2 + impact 3 | 96x96 centred | watcher eye, 24x96 capsule | todo | 1 x 3 = 3 |
| `proj_ink_bolt` | sprite sheet | projectile flight 2 + impact 3 | 96x96 centred | Archivist | todo | 1 x 3 = 3 |
| `proj_page_ring` | sprite sheet | projectile flight 2 + impact 3 | 96x96 centred | Archivist, pages | todo | 1 x 3 = 3 |
| `proj_note_ring` | sprite sheet | projectile flight 2 + impact 3 | 96x96 centred | Dirge Choir notes | todo | 1 x 3 = 3 |
| `proj_lance` | sprite sheet | projectile flight 2 + impact 3 | 96x96 centred | Gloam Knight | todo | 1 x 3 = 3 |
| `proj_coin` | sprite sheet | projectile flight 2 + impact 3 | 96x96 centred | Coinwyrm coins | todo | 1 x 3 = 3 |
| `proj_key_volley` | sprite sheet | projectile flight 2 + impact 3 | 96x96 centred | Lock Warden keys | todo | 1 x 3 = 3 |
| `proj_gaze_bolt` | sprite sheet | projectile flight 2 + impact 3 | 96x96 centred | Unlit eyes | todo | 1 x 3 = 3 |
| `proj_hush_torrent` | sprite sheet | projectile flight 2 + impact 3 | 96x96 centred | Unlit homing bolts | todo | 1 x 3 = 3 |
| `proj_water_jet` | sprite sheet | projectile flight 2 + impact 3 | 96x96 centred | Sump Lurker | todo | 1 x 3 = 3 |
| `proj_wax_hook` | sprite sheet | projectile flight 2 + impact 3 | 96x96 centred | Corrow's Echo boomerang | todo | 1 x 3 = 3 |
| `light_glow_warm` | sprite sheet | radial lamp light texture 1, alpha | 512x512 | lamp, torch lights | todo | 1 x 3 = 3 |
| `light_glow_cold` | sprite sheet | radial cold teal glow 1, alpha | 512x512 | Hush glows | todo | 1 x 3 = 3 |
| `light_shaft` | sprite sheet | dusk light shaft overlay 1 | 512x1024 | intro, ambient | todo | 1 x 3 = 3 |
| `light_jar_glow` | sprite sheet | pale white glow 1, alpha | 1024x1024 | glow jar light | todo | 1 x 3 = 3 |

### 2.7 NPCs and shopkeepers

Shops are pocket scenes with no text; the shopkeeper stands behind the counter and faces the viewer. The shop list is from world-plan 6.5.

| id | source | animations (frames) | cell | used in | status | units x var |
|---|---|---|---|---|---|---|
| `npc_tilly` | sprite sheet | idle 4, greet 2, farewell 1; Tilly, lamp stall (S1); down only | 192x192 foot 176 | ow_1_2 shop | todo | 1 x 3 = 3 |
| `npc_peddler` | sprite sheet | idle 4, greet 2, farewell 1; Peddler in a burrow (S2); down only | 192x192 foot 176 | ow_6_0 shop | todo | 1 x 3 = 3 |
| `npc_ashwife` | sprite sheet | idle 4, greet 2, farewell 1; Ashwife with cart (S3); down only | 192x192 foot 176 | ow_10_3 shop | todo | 1 x 3 = 3 |
| `npc_mason` | sprite sheet | idle 4, greet 2, farewell 1; Stone mason (S4); down only | 192x192 foot 176 | ow_5_7 shop | todo | 1 x 3 = 3 |
| `npc_pilgrim` | sprite sheet | idle 4, greet 2, farewell 1; Pilgrim at stall (S5); down only | 192x192 foot 176 | ow_10_7 shop | todo | 1 x 3 = 3 |
| `npc_keeper` | sprite sheet | idle 4, greet 2, farewell 1; Keeper of the lighthouse trade (S6); down only | 192x192 foot 176 | ow_6_5 shop | todo | 1 x 3 = 3 |
| `npc_villager_a` | sprite sheet | idle 4, walk_{d,u,s} 4 (optional village life) | 192x192 foot 176 | Brackwater Ford (optional) | todo | 3 x 3 = 9 |
| `npc_villager_b` | sprite sheet | idle 4, walk_{d,u,s} 4 (optional, second design) | 192x192 foot 176 | Brackwater Ford (optional) | todo | 3 x 3 = 9 |
| `npc_corrow_wax` | sprite sheet | seated idle 4, speak 2, fade 4 (half wax, half man in Corrow's coat) | 256x256 foot 236 | C10 ending choice | todo | 1 x 3 = 3 |
| `npc_corrow_ghost` | sprite sheet | memory-scene figure: idle 3 (translucent, warm rim) for rekindle scenes | 192x192 | fragment memories (provisional) | todo | 1 x 3 = 3 |

### 2.8 Minibosses (10)

Ten minibosses (`monsters-bosses-tools.md` section 3). Walkers get `walk_{d,u,s}` plus an actions sheet in two views (down, side; `up` reuses the walk). Decoys of the Mirror Warden use the same sprites tinted by code. Large cells (256 to 384) are proposals.

| id | source | animations (frames) | cell | used in | status | units x var |
|---|---|---|---|---|---|---|
| `hollow_captain_walk` | sprite sheet | walk_{d,u,s} 4 | 256x256 foot 236 | C1 cave_1_5 | todo | 3 x 3 = 9 |
| `hollow_captain_actions` | sprite sheet | guard_up 1, bash_telegraph 1, bash 2, stunned guard-down 1 (down + side) | 256x256 foot 236 | C1 cave_1_5 | todo | 2 x 3 = 6 |
| `thorn_warden_walk` | sprite sheet | walk_{d,u,s} 4 | 256x256 foot 236 | C2 cave_2_4 | todo | 3 x 3 = 9 |
| `thorn_warden_actions` | sprite sheet | needle_telegraph 2, needle_ring 2, stunned skirt-retracted 2, burning 2 (down + side) | 256x256 foot 236 | C2 cave_2_4 | todo | 2 x 3 = 6 |
| `sump_lurker` | sprite sheet | surface 3, bite 3, surfaced idle 2, dive 3, water_jet spit 2; no walk, one direction | 384x384 foot 340 | C3 cave_3_4 | todo | 1 x 3 = 3 |
| `lull_mauler_walk` | sprite sheet | walk_{d,u,s} 4 | 320x320 foot 292 | C4 cave_4_4 | todo | 3 x 3 = 9 |
| `lull_mauler_actions` | sprite sheet | smash_telegraph 3, smash 3, sweep_telegraph 2, sweep 3, recover 1 (down + side) | 320x320 foot 292 | C4 cave_4_4 | todo | 2 x 3 = 6 |
| `mirror_warden_walk` | sprite sheet | walk_{d,u,s} 4 | 256x256 foot 236 | C5 cave_5_4 | todo | 3 x 3 = 9 |
| `mirror_warden_actions` | sprite sheet | slash_combo 6 (telegraph + three slashes), swap_flash 2 (down + side) | 256x256 foot 236 | C5 cave_5_4 | todo | 2 x 3 = 6 |
| `choir_warden_walk` | sprite sheet | walk_{d,u,s} 4 | 256x256 foot 236 | C6 cave_6_4 | todo | 3 x 3 = 9 |
| `choir_warden_actions` | sprite sheet | inhale 2, note_cone 2, mouth_closed recover 1 (down + side) | 256x256 foot 236 | C6 cave_6_4 | todo | 2 x 3 = 6 |
| `pale_squire_walk` | sprite sheet | walk_{d,u,s} 4 | 256x256 foot 236 | C7 cave_7_4 | todo | 3 x 3 = 9 |
| `pale_squire_actions` | sprite sheet | lunge_telegraph 1, lunge 2, pit_fall 3 (down + side) | 256x256 foot 236 | C7 cave_7_4 | todo | 2 x 3 = 6 |
| `abacus_brute_walk` | sprite sheet | walk_{d,u,s} 4 | 320x320 foot 292 | C8 cave_8_4 | todo | 3 x 3 = 9 |
| `abacus_brute_actions` | sprite sheet | whirl_telegraph 2, chain_whirl 6, rail_break 2 (down + side) | 320x320 foot 292 | C8 cave_8_4 | todo | 2 x 3 = 6 |
| `wick_automaton_walk` | sprite sheet | walk_{d,u,s} 4 | 256x256 foot 236 | C9 cave_9_4 | todo | 3 x 3 = 9 |
| `wick_automaton_actions` | sprite sheet | jet_telegraph 2, flame_jet 2, vent_open 2 (down + side) | 256x256 foot 236 | C9 cave_9_4 | todo | 2 x 3 = 6 |
| `corrows_echo_walk` | sprite sheet | walk_{d,u,s} 4 | 256x256 foot 236 | C10 cave_10_4 | todo | 3 x 3 = 9 |
| `corrows_echo_actions` | sprite sheet | combo 4, retreat 1, flare_charge 3, chime_stun 2, hook_throw 2 (down + side) | 256x256 foot 236 | C10 cave_10_4 | todo | 2 x 3 = 6 |
| `miniboss_death_wax` | sprite sheet | generic collapse 6 (wax/shadow dissolve), shared by all ten minibosses; tinted by code | 256x256 | C1-C10 | todo | 1 x 3 = 3 |

### 2.9 Bosses (10)

Ten bosses (section 4 of the monster file), drawn large because the arena camera is fixed and a boss fills the room (body radius 44 to 120 px). Each phase that changes the look has its own sheet. Parts that move apart from the body (eyes, plates, heads, tail, hands) are their own rows. Sizes are proposals.

| id | source | animations (frames) | cell | used in | status | units x var |
|---|---|---|---|---|---|---|
| `kilnkeeper_p1` | sprite sheet | idle_hard 2, walk 4 (down), walk 4 (side), slag_fan 3, rush 2, rush_stun 1 | 512x512 foot 470 | C1 cave_1_8 | todo | 2 x 3 = 6 |
| `kilnkeeper_p2` | sprite sheet | molten 3, cracked idle 2, walk 4 (down + side), splash 3 (wax ring), rush 2; phase 2 body is cracked and glows | 512x512 foot 470 | C1 cave_1_8 | todo | 2 x 3 = 6 |
| `kilnkeeper_death` | sprite sheet | collapse 6 (kiln door bursts open, light escapes) | 512x512 | C1 cave_1_8 | todo | 1 x 3 = 3 |
| `briar_mother_p1` | sprite sheet | canopy_sleep 2, hurt 2, eye-lost 1; the vast body hangs over the arena | 768x512 | C2 cave_2_9 | todo | 1 x 3 = 3 |
| `seed_eye` | sprite sheet | raised hidden 1, lowering 3, lowered idle 2, spore_telegraph 2, hurt 2, dead 3 | 128x192 foot 180 | C2 cave_2_9 (three of them) | todo | 1 x 3 = 3 |
| `briar_bloom_p2` | sprite sheet | bloom idle 2, sweep_telegraph 2, hurt 2, death 5 | 512x512 | C2 cave_2_9 | todo | 1 x 3 = 3 |
| `briar_seed` | sprite sheet | falling 1, landed 2 (wobble), burst 4 | 128x128 | C2 cave_2_9 | todo | 1 x 3 = 3 |
| `tidewick_head` | sprite sheet | swim_{d,u,s} 2, ember_spit telegraph 2, p2 scorched variant 2 (side) | 256x256 | C3 cave_3_9 | todo | 3 x 3 = 9 |
| `tidewick_body` | sprite sheet | segment submerged ripple 2 variants, reverse turn 1 | 192x192 | C3 cave_3_9 | todo | 1 x 3 = 3 |
| `tidewick_tail` | sprite sheet | submerged ripple 2, surfacing 3, tail_up wick-flame 4, hurt 2, death 5 | 256x256 | C3 cave_3_9 | todo | 1 x 3 = 3 |
| `hushed_colossus_body` | sprite sheet | asleep 1, wake_1 idle 2, wake_2 idle 2, wake_3 idle 2 (cracking wax, glowing seams) | 640x640 foot 600 | C4 cave_4_10 | todo | 1 x 3 = 3 |
| `hushed_colossus_arms` | sprite sheet | slam_telegraph 3, slam 3, double_slam 4, arm_sweep 4, quake 3, death 6 | 640x640 | C4 cave_4_10 | todo | 2 x 3 = 6 |
| `colossus_shard` | sprite sheet | falling 1, lying 3 variants (Liftable), crumble 4 | 96x96 foot 88 | C4 cave_4_10 | todo | 1 x 3 = 3 |
| `archivist_p1` | sprite sheet | float 4, bolt_cast 3, blink 3 (vanish, appear), hurt 2 | 256x256 centred | C5 cave_5_10 | todo | 1 x 3 = 3 |
| `archivist_p2_p3` | sprite sheet | copy_phase 3, stunned 2, page_break pop 3 (decoy ink spatter), last_page 3, death 6 | 256x256 | C5 cave_5_10 | todo | 1 x 3 = 3 |
| `archivist_decoy` | sprite sheet | decoy variant: same pose set, paler and no shadow cue, 4 float frames | 256x256 | C5 cave_5_10 | todo | 1 x 3 = 3 |
| `dirge_head_bass` | sprite sheet | humming idle 2, telegraph 3, sing 3, stunned 2, dead 3 (bass head, distinct pipe size) | 384x384 foot 340 | C6 cave_6_11 | todo | 1 x 3 = 3 |
| `dirge_head_alto` | sprite sheet | humming idle 2, telegraph 3, sing 3, stunned 2, dead 3 (alto head, distinct pipe size) | 384x384 foot 340 | C6 cave_6_11 | todo | 1 x 3 = 3 |
| `dirge_head_treble` | sprite sheet | humming idle 2, telegraph 3, sing 3, stunned 2, dead 3 (treble head, distinct pipe size) | 384x384 foot 340 | C6 cave_6_11 | todo | 1 x 3 = 3 |
| `gloam_knight_p1` | sprite sheet | walk_{d,u,s} 4, lance_telegraph 2, lance 2, slash_combo 4 (side), dive crouch 2, airborne 1, land 3 | 320x320 foot 292 | C7 cave_7_11 | todo | 3 x 3 = 9 |
| `gloam_knight_p2` | sprite sheet | cracked armour + frayed cape: idle 2, slash 4, dive 3, ring-land 3, death 6 | 320x320 foot 292 | C7 cave_7_11 | todo | 2 x 3 = 6 |
| `coinwyrm_head` | sprite sheet | rear 4, bare 2, bite_telegraph 2, bite 3, burrow 4, rise 3, death 6 | 512x512 | C8 cave_8_12 | todo | 2 x 3 = 6 |
| `coinwyrm_plates` | sprite sheet | brow, cheek_l, cheek_r, crown plate: whole 1, yanked off 3 each (4 parts) | 192x192 | C8 cave_8_12 | todo | 2 x 3 = 6 |
| `coinwyrm_tail` | sprite sheet | tail_sweep_telegraph 2, sweep 4, burrow 3 | 384x256 | C8 cave_8_12 | todo | 1 x 3 = 3 |
| `coin_heap` | sprite sheet | burrow point: quiet 1, quiver 3 (coin ripples), burst 3 | 192x192 | C8 cave_8_12 | todo | 1 x 3 = 3 |
| `lock_warden_body` | sprite sheet | closed 1, plates open 2, plates broken 2 (progressive damage), death 6 | 512x512 | C9 cave_9_10 | todo | 2 x 3 = 6 |
| `lock_plate` | sprite sheet | lid-eye closed 1, opening 3, open 1, plate hurt 2, broken 3 (four corner parts) | 160x160 | C9 cave_9_10 | todo | 1 x 3 = 3 |
| `lock_keyhole` | sprite sheet | closed 1, open glowing 3 (tumbler turn), hurt 2 | 192x192 | C9 cave_9_10 | todo | 1 x 3 = 3 |
| `unlit_p1_mass` | sprite sheet | mass idle 2 (wax, rope, old tools around the lantern), hurt 1 | 768x768 | C10 cave_10_14 | todo | 1 x 3 = 3 |
| `unlit_eye` | sprite sheet | open 3, closed 1, gaze telegraph 2, hurt 2, dead 3 (five orbiting parts) | 128x128 centred | C10 cave_10_14 | todo | 1 x 3 = 3 |
| `unlit_hush_hand` | sprite sheet | rise 4, hold 2 (obstacle), sink 3 | 192x192 | C10 cave_10_14 | todo | 1 x 3 = 3 |
| `unlit_p2_shell` | sprite sheet | wax shell walk 4 (down + side), wave_telegraph 3, burning 3, shell_break 5 | 512x512 foot 470 | C10 cave_10_14 | todo | 2 x 3 = 6 |
| `unlit_p3_heart` | sprite sheet | heart shielded 2, exposed pulse 4, hurt 2, death 8 (collapse into light) | 512x512 | C10 cave_10_14 | todo | 2 x 3 = 6 |
| `ninth_lantern` | sprite sheet | hanging glow 3, dropped 2, rehoist 3, settled lit 3, settled out 1 | 384x384 | C10 cave_10_14 | todo | 1 x 3 = 3 |
| `unlit_chains` | sprite sheet | chain link loop 1, lash 3 (floor line), taut 1 | 128x256 | C10 cave_10_14 | todo | 1 x 3 = 3 |

### 2.10 HUD and UI

Interface art that replaces plain code shapes. Everything here is optional for the engine (each screen has a code fallback) but wanted for a finished look. Text is never in the art; the brass numerals are a glyph sheet (unclear point 6).

| id | source | animations (frames) | cell | used in | status | units x var |
|---|---|---|---|---|---|---|
| `hud_heart` | UI icon | full 1, half 1, empty 1, beat 2 (replaces the procedural hearts if accepted) | 64x64 | HUD | todo | 3 x 3 = 9 |
| `hud_wick_core_slot` | UI icon | heart-piece indicator, 4 steps | 64x64 | HUD | todo | 1 x 3 = 3 |
| `hud_item_frame` | UI icon | active-item frame, empty 1, with glow 1 | 160x160 | HUD | todo | 1 x 3 = 3 |
| `hud_counter_icons` | UI icon | brass, small key, big key, pot, slug: 5 icons | 64x64 | HUD | todo | 5 x 3 = 15 |
| `hud_fragment_sockets` | UI icon | nine fragment sockets: empty 1 + lit 1 each colour | 64x64 | subscreen, HUD | todo | 9 x 3 = 27 |
| `hud_minimap_tiles` | UI icon | unvisited, visited, current-ring, cave mouth, shop, boss, locked, pocket markers | 32x32 | minimap | todo | 8 x 3 = 24 |
| `hud_minimap_frame` | UI icon | minimap frame, brass and glass | 288x192 | HUD | todo | 1 x 3 = 3 |
| `hud_status_band` | single painting | HUD top band background (120 px high) | 1920x120 | HUD | todo | 1 x 3 = 3 |
| `subscreen_panel` | single painting | item subscreen background panel (5x2 grid) | 1500x800 | subscreen | todo | 1 x 3 = 3 |
| `subscreen_slot` | UI icon | slot frame: empty 1, selected 1, locked silhouette 1 | 176x176 | subscreen | todo | 3 x 3 = 9 |
| `subscreen_cursor` | UI icon | cursor flame loop 3 | 96x96 | subscreen, menus | todo | 1 x 3 = 3 |
| `pause_panel` | single painting | pause menu panel, nine-patch | 900x700 | pause menu | todo | 1 x 3 = 3 |
| `pause_buttons` | UI icon | button states: normal, selected, disabled | 384x96 | pause, title menus | todo | 3 x 3 = 9 |
| `shop_price_plate` | UI icon | price plate under item | 160x64 | shop | todo | 1 x 3 = 3 |
| `ui_brass_digits` | UI icon | brass numerals 0-9 (glyph sheet) | 64x64 each | price, counters | todo | 10 x 3 = 30 |
| `warp_picker_panel` | single painting | warp list panel + ten cave mouth icons | 1100x700; icons 96 | chime warp | todo | 11 x 3 = 33 |
| `title_menu_panel` | single painting | menu backing for New game, Continue, Quit | 640x420 | title | todo | 1 x 3 = 3 |
| `dialog_prompt_card` | single painting | yes/no prompt card (overwrite save) | 640x320 | title | todo | 1 x 3 = 3 |
| `death_overlay` | single painting | death screen painting (lamp gone out) | 1920x1080 | death | todo | 1 x 3 = 3 |
| `loading_wick` | UI icon | wick flame loader loop 4 | 96x96 | scene fades | todo | 1 x 3 = 3 |
| `credit_divider` | single painting | credits ornament | 1200x120 | credits | todo | 1 x 3 = 3 |

### 2.11 Room backdrops

The room kit builds rooms from tiles; the plan needs a painted floor only where a room is unique. Boss arenas get a floor painting so the fixed camera shows a designed space. All optional, lower priority than tiles.

| id | source | animations (frames) | cell | used in | status | units x var |
|---|---|---|---|---|---|---|
| `arena_c1` | single painting | boss arena floor painting (one room, floor decals and cracks, no walls, no characters) | 1920x960 (source 1536x1024) | C1 boss room | todo | 1 x 3 = 3 |
| `arena_c2` | single painting | boss arena floor painting (one room, floor decals and cracks, no walls, no characters) | 1920x960 (source 1536x1024) | C2 boss room | todo | 1 x 3 = 3 |
| `arena_c3` | single painting | boss arena floor painting (one room, floor decals and cracks, no walls, no characters) | 1920x960 (source 1536x1024) | C3 boss room | todo | 1 x 3 = 3 |
| `arena_c4` | single painting | boss arena floor painting (one room, floor decals and cracks, no walls, no characters) | 1920x960 (source 1536x1024) | C4 boss room | todo | 1 x 3 = 3 |
| `arena_c5` | single painting | boss arena floor painting (one room, floor decals and cracks, no walls, no characters) | 1920x960 (source 1536x1024) | C5 boss room | todo | 1 x 3 = 3 |
| `arena_c6` | single painting | boss arena floor painting (one room, floor decals and cracks, no walls, no characters) | 1920x960 (source 1536x1024) | C6 boss room | todo | 1 x 3 = 3 |
| `arena_c7` | single painting | boss arena floor painting (one room, floor decals and cracks, no walls, no characters) | 1920x960 (source 1536x1024) | C7 boss room | todo | 1 x 3 = 3 |
| `arena_c8` | single painting | boss arena floor painting (one room, floor decals and cracks, no walls, no characters) | 1920x960 (source 1536x1024) | C8 boss room | todo | 1 x 3 = 3 |
| `arena_c9` | single painting | boss arena floor painting (one room, floor decals and cracks, no walls, no characters) | 1920x960 (source 1536x1024) | C9 boss room | todo | 1 x 3 = 3 |
| `arena_c10` | single painting | boss arena floor painting (one room, floor decals and cracks, no walls, no characters) | 1920x960 (source 1536x1024) | C10 boss room | todo | 1 x 3 = 3 |
| `backdrop_ninth_door` | single painting | room floor and shoreline for the Ninth Door approach | 1920x960 | ow_10_8 | todo | 1 x 3 = 3 |
| `backdrop_start_village` | single painting | Brackwater Ford street floor with cobbles, lamp pools | 1920x960 | ow_0_0, ow_1_0 (optional) | todo | 1 x 3 = 3 |

### 2.12 Stills: title, intro, endings, credits, memories

Full-screen paintings used as they are (no cut tool). The size is 1920x1080; generate at 1536x1024 or the largest the tool returns, then use the largest 16:9 crop (never upscale below target). File names are final (`assets/art/<name>.png`).

| id | source | animations (frames) | cell | used in | status | units x var |
|---|---|---|---|---|---|---|
| `title_splash` | single painting | valley of Vey at dusk, fallen lantern glow, Tamsin silhouette, open sky top third | 1920x1080 | title | todo | 1 x 3 = 3 |
| `title_logo` | single painting | 'Wickwarden' brass-and-wax wordmark with a lit wick, transparent (lettering is the one deliberate text image) | 1400x420 transparent | title | todo | 1 x 3 = 3 |
| `intro_01_lanterns` | single painting | Nine Lanterns drifting over a village at golden hour | 1920x1080 | intro 1 | todo | 1 x 3 = 3 |
| `intro_02_lanternfall` | single painting | lanterns falling and burning into the ground, craters glowing | 1920x1080 | intro 2 | todo | 1 x 3 = 3 |
| `intro_03_dusk` | single painting | slow dusk, Hush shapes gathering at the edge of Brackwater Ford | 1920x1080 | intro 3 | todo | 1 x 3 = 3 |
| `intro_04_tamsin` | single painting | Tamsin lighting the street lamps of Brackwater Ford | 1920x1080 | intro 4 | todo | 1 x 3 = 3 |
| `intro_05_hook` | single painting | Corrow's empty tower stair, the lamp hook and the lamp that will not go out | 1920x1080 | intro 5 | todo | 1 x 3 = 3 |
| `intro_06_setout` | single painting | Tamsin on the village path with hook and lamp, cave mouth glowing ahead | 1920x1080 | intro 6 | todo | 1 x 3 = 3 |
| `ending_a_rekindle` | single painting | last lantern rekindled over a warm valley | 1920x1080 | ending A | todo | 1 x 3 = 3 |
| `ending_b_dawn` | single painting | lantern put out, real dawn on the shore | 1920x1080 | ending B | todo | 1 x 3 = 3 |
| `credits_bg` | single painting | quiet dusk valley, painted background for the rolling credits (no text) | 1920x1080 | credits | todo | 1 x 3 = 3 |
| `memory_c1` | single painting | rekindle memory vignette, Warmth: a kiln-lit hall, Corrow and a younger Tamsin trimming wicks (provisional, story reveals the truth step by step) | 1920x1080 | rekindle C1 | todo | 1 x 3 = 3 |
| `memory_c2` | single painting | rekindle memory vignette, Growth: Corrow planting a seed beneath a lantern (provisional, story reveals the truth step by step) | 1920x1080 | rekindle C2 | todo | 1 x 3 = 3 |
| `memory_c3` | single painting | rekindle memory vignette, Rain: the lantern drawing water out of a field (provisional, story reveals the truth step by step) | 1920x1080 | rekindle C3 | todo | 1 x 3 = 3 |
| `memory_c4` | single painting | rekindle memory vignette, Sleep: the foundry stopping mid-pour (provisional, story reveals the truth step by step) | 1920x1080 | rekindle C4 | todo | 1 x 3 = 3 |
| `memory_c5` | single painting | rekindle memory vignette, Memory: Corrow reading letters in the archive (provisional, story reveals the truth step by step) | 1920x1080 | rekindle C5 | todo | 1 x 3 = 3 |
| `memory_c6` | single painting | rekindle memory vignette, Song: the vault's bells falling silent (provisional, story reveals the truth step by step) | 1920x1080 | rekindle C6 | todo | 1 x 3 = 3 |
| `memory_c7` | single painting | rekindle memory vignette, Courage: Corrow at the pit-edge fort, afraid (provisional, story reveals the truth step by step) | 1920x1080 | rekindle C7 | todo | 1 x 3 = 3 |
| `memory_c8` | single painting | rekindle memory vignette, Trade: the Counting House weighing lives against brass (provisional, story reveals the truth step by step) | 1920x1080 | rekindle C8 | todo | 1 x 3 = 3 |
| `memory_c9` | single painting | rekindle memory vignette, Corrow's Last Wick: his workshop, the plan to bury the lanterns (provisional, story reveals the truth step by step) | 1920x1080 | rekindle C9 | todo | 1 x 3 = 3 |
| `ninth_hollow_vista` | single painting | wide painting of the Ninth Hollow entrance for the final approach (optional) | 1920x1080 | ow_10_8 / C10 intro | todo | 1 x 3 = 3 |

## 3. Totals

| Category | Elements (rows) | todo rows | Generation units to do | Images (units x variants) |
|---|---|---|---|---|
| Player (Tamsin) | 25 | 20 | 52 | 156 |
| Terrain textures (6 regions, 10 caves) | 84 | 76 | 76 | 228 |
| Regular monsters | 19 | 12 | 22 | 66 |
| Tools, pickups and item icons | 39 | 33 | 43 | 129 |
| Props | 94 | 79 | 106 | 318 |
| Effects, projectiles and lights | 50 | 49 | 49 | 147 |
| NPCs and shopkeepers | 10 | 10 | 14 | 42 |
| Minibosses (10) | 20 | 20 | 47 | 141 |
| Bosses (10) | 35 | 35 | 48 | 144 |
| HUD and UI | 21 | 21 | 65 | 195 |
| Room backdrops | 12 | 12 | 12 | 36 |
| Stills: title, intro, endings, credits, memories | 21 | 21 | 21 | 63 |
| **Total** | **430** | **388** | **555** | **1665** |

Rows marked `done`: 42 (already in the repository, 0 images). At the default of 3 variants the plan generates 1665 images; with a keep rate of about one in three this ends with about 555 accepted assets. One generation call returns one sheet, so the number of calls is lower where a sheet holds several small items (the batches below group them).

## 4. Generation batches

Batches hold about 10 to 20 images, in dependency order: the player first (its look is the reference for everything), then terrain, regular monsters, tools and pickups, props, effects, NPCs, minibosses, bosses, UI, backdrops, and the stills last. A row that is larger than one batch is split by unit. Each batch ends with a review pass by the user before the next one starts, so the cull can steer later prompts.

| Batch | Images | Contents (id: images) |
|---|---|---|
| B01 | 18 | `player_wick_cast`: 9, `player_sling_shot`: 9 |
| B02 | 18 | `player_raft_ride`: 9, `player_mitts_lift`: 9 |
| B03 | 18 | `player_mitts_carry`: 9, `player_mitts_throw`: 9 |
| B04 | 18 | `player_mitts_push`: 9, `player_mitts_pull`: 9 |
| B05 | 18 | `player_jar_throw`: 9, `player_chime_ring`: 9 |
| B06 | 18 | `player_chime_hold`: 9, `player_leap`: 9 |
| B07 | 18 | `player_reel_fire`: 9, `player_reel_pull`: 9 |
| B08 | 18 | `player_pot_place`: 9, `player_moth_throw`: 9 |
| B09 | 18 | `player_item_get`: 3, `player_flask_drink`: 3, `player_pit_fall`: 3, `player_death`: 3, `tex_path_dirt`: 3, `tex_ground_garden`: 3 |
| B10 | 18 | `tex_ground_thornwood`: 3, `tex_wall_thorn`: 3, `tex_path_forest`: 3, `tex_ground_ash`: 3, `tex_ground_slag`: 3, `tex_wall_cinder`: 3 |
| B11 | 18 | `tex_wall_cinder_face`: 3, `tex_ground_fen`: 3, `tex_boardwalk_planks`: 3, `tex_water_lake`: 3, `tex_lake_shore`: 3, `tex_wall_fen`: 3 |
| B12 | 18 | `tex_ground_gravel`: 3, `tex_path_flagstone`: 3, `tex_wall_cliff`: 3, `tex_wall_cliff_face`: 3, `tex_ground_salt`: 3, `tex_ground_wreck`: 3 |
| B13 | 18 | `tex_wall_wreck`: 3, `tex_wall_wreck_face`: 3, `tex_water_sea`: 3, `edge_grass_to_thorn`: 3, `edge_thorn_to_ash`: 3, `edge_grass_to_fen`: 3 |
| B14 | 18 | `edge_fen_to_gravel`: 3, `edge_ash_to_gravel`: 3, `edge_gravel_to_salt`: 3, `edge_ash_to_salt`: 3, `edge_path_border`: 3, `edge_shore_foam`: 3 |
| B15 | 18 | `edge_cliff_shadow`: 3, `tex_ground_c1`: 3, `tex_wall_c1`: 3, `tex_wall_face_c1`: 3, `tex_special_c1`: 3, `tex_ground_c2`: 3 |
| B16 | 18 | `tex_wall_c2`: 3, `tex_wall_face_c2`: 3, `tex_special_c2`: 3, `tex_ground_c3`: 3, `tex_wall_c3`: 3, `tex_wall_face_c3`: 3 |
| B17 | 18 | `tex_special_c3`: 3, `tex_ground_c4`: 3, `tex_wall_c4`: 3, `tex_wall_face_c4`: 3, `tex_special_c4`: 3, `tex_ground_c5`: 3 |
| B18 | 18 | `tex_wall_c5`: 3, `tex_wall_face_c5`: 3, `tex_special_c5`: 3, `tex_ground_c6`: 3, `tex_wall_c6`: 3, `tex_wall_face_c6`: 3 |
| B19 | 18 | `tex_special_c6`: 3, `tex_ground_c7`: 3, `tex_wall_c7`: 3, `tex_wall_face_c7`: 3, `tex_special_c7`: 3, `tex_ground_c8`: 3 |
| B20 | 18 | `tex_wall_c8`: 3, `tex_wall_face_c8`: 3, `tex_special_c8`: 3, `tex_ground_c9`: 3, `tex_wall_c9`: 3, `tex_wall_face_c9`: 3 |
| B21 | 18 | `tex_special_c9`: 3, `tex_ground_c10`: 3, `tex_wall_c10`: 3, `tex_wall_face_c10`: 3, `tex_special_c10`: 3, `tex_water_black`: 3 |
| B22 | 15 | `edge_cave_floor_to_wall`: 3, `edge_cave_water`: 3, `bramble_snapper`: 3, `fen_leech`: 3, `cinder_wisp`: 3 |
| B23 | 18 | `watcher_eye`: 9, `husk_hound_walk`: 9 |
| B24 | 18 | `husk_hound_states`: 3, `brine_crab_walk`: 9, `brine_crab_states`: 3, `wickling`: 3 |
| B25 | 18 | `mirror_shade_walk`: 9, `mirror_shade_states`: 9 |
| B26 | 18 | `choirling`: 3, `icon_tether_moth`: 3, `icon_pitch_pot`: 3, `icon_cinder_wick`: 3, `icon_tallow_sling`: 3, `icon_reed_raft`: 3 |
| B27 | 18 | `icon_heft_mitts`: 3, `icon_glow_jar`: 3, `icon_lantern_chime`: 3, `icon_skitter_boots`: 3, `icon_reel_line`: 3, `item_cinder_wick`: 3 |
| B28 | 18 | `item_tallow_sling`: 3, `item_reed_raft`: 3, `item_heft_mitts`: 3, `item_glow_jar`: 3, `item_lantern_chime`: 3, `item_skitter_boots`: 3 |
| B29 | 18 | `item_reel_line`: 3, `icon_hook_flare_ward`: 9, `flame_cinder`: 3, `slug_tallow`: 3 |
| B30 | 18 | `reed_raft_vehicle`: 3, `jar_thrown`: 3, `jar_lit`: 3, `reel_tip`: 3, `reel_line_rope`: 3, `liftable_rock_small`: 3 |
| B31 | 12 | `slug_bundle`: 3, `pot_bag`: 3, `tallow_flask`: 3, `bigkey`: 3 |
| B32 | 20 | `fragment_c1_to_c9`: 20 |
| B33 | 19 | `fragment_c1_to_c9`: 7, `slag_chunk`: 3, `thorn_hedge`: 3, `thorn_wall`: 3, `thorn_door`: 3 |
| B34 | 18 | `eye_switch`: 3, `eye_portcullis`: 3, `eye_cell`: 3, `mooring`: 3, `pit_edge`: 3, `pit_fill`: 3 |
| B35 | 18 | `low_rail`: 3, `anchor_ring`: 3, `anchor_pocket`: 3, `heavy_stone`: 3, `heavy_boulder`: 3, `heavy_door`: 3 |
| B36 | 18 | `heavy_stones`: 3, `resonance_stone`: 3, `resonance_door`: 3, `resonance_vault`: 3, `hidden_seam`: 3, `hidden_stairs`: 3 |
| B37 | 18 | `sealed_seam`: 3, `hook_tap_wall`: 3, `grate`: 3, `boss_door`: 3, `ninth_door`: 3, `wax_seal`: 3 |
| B38 | 18 | `reed_cluster`: 3, `rush_wall`: 3, `moss_wall`: 3, `dry_vine_screen`: 3, `bush_cluster`: 3, `brittle_rocks`: 3 |
| B39 | 18 | `pocket_stall`: 3, `pocket_cart`: 3, `pocket_lighthouse_door`: 3, `pocket_mason_door`: 3, `pocket_hut_door`: 3, `pocket_grotto`: 3 |
| B40 | 18 | `pocket_stairs_down`: 3, `pocket_plain_door`: 3, `shop_counter`: 3, `ward_plate`: 3, `street_lamp`: 3, `wall_torch`: 3 |
| B41 | 15 | `pillar`: 9, `lectern`: 3, `statue_eye`: 3 |
| B42 | 18 | `statue_figure`: 6, `crate_stack`: 9, `cold_furnace`: 3 |
| B43 | 15 | `anvil`: 3, `slag_heap`: 6, `glass_shards`: 6 |
| B44 | 18 | `dead_tree`: 6, `thorn_bramble`: 6, `fallen_log`: 3, `root_bridge`: 3 |
| B45 | 12 | `boardwalk`: 9, `dock_pier`: 3 |
| B46 | 18 | `wax_vat`: 9, `lily_pads`: 3, `shipwreck`: 6 |
| B47 | 18 | `rusted_lantern_post`: 3, `salt_crystals`: 6, `driftwood_net`: 3, `well_haystack`: 6 |
| B48 | 15 | `cottage`: 3, `ledge_drop`: 3, `bell`: 9 |
| B49 | 18 | `pump_pipe`: 9, `mirror_panel`: 9 |
| B50 | 18 | `workbench`: 6, `mural_panel`: 12 |
| B51 | 18 | `letter_pile`: 3, `arena_pedestal_lantern`: 6, `cave_mouth_ashen`: 3, `cave_mouth_fen`: 3, `cave_mouth_stone`: 3 |
| B52 | 18 | `fx_fire_small`: 3, `fx_fire_big`: 3, `fx_ember_sparks`: 3, `fx_smoke_puff`: 3, `fx_smoke_column`: 3, `fx_dust_puff`: 3 |
| B53 | 18 | `fx_hit_spark`: 3, `fx_enemy_poof`: 3, `fx_water_splash`: 3, `fx_water_ripple`: 3, `fx_raft_wake`: 3, `fx_wisp_burst`: 3 |
| B54 | 18 | `fx_chime_ring`: 3, `fx_warp_out`: 3, `fx_warp_in`: 3, `fx_glow_burst`: 3, `fx_leap_dust`: 3, `fx_reel_hit`: 3 |
| B55 | 18 | `fx_wax_splash`: 3, `fx_ink_splatter`: 3, `fx_shockwave`: 3, `fx_floor_glow_tile`: 3, `fx_thorn_burst`: 3, `fx_boss_death_light`: 3 |
| B56 | 18 | `fx_boss_death_wax`: 3, `fx_rekindle_burst`: 3, `fx_rekindle_motes`: 3, `fx_pickup_sparkle`: 3, `fx_heal_glow`: 3, `fx_save_wick`: 3 |
| B57 | 18 | `proj_slag_ball`: 3, `proj_spore_bolt`: 3, `proj_thorn_needle`: 3, `proj_ember_bolt`: 3, `proj_beam_bolt`: 3, `proj_ink_bolt`: 3 |
| B58 | 18 | `proj_page_ring`: 3, `proj_note_ring`: 3, `proj_lance`: 3, `proj_coin`: 3, `proj_key_volley`: 3, `proj_gaze_bolt`: 3 |
| B59 | 18 | `proj_hush_torrent`: 3, `proj_water_jet`: 3, `proj_wax_hook`: 3, `light_glow_warm`: 3, `light_glow_cold`: 3, `light_shaft`: 3 |
| B60 | 18 | `light_jar_glow`: 3, `npc_tilly`: 3, `npc_peddler`: 3, `npc_ashwife`: 3, `npc_mason`: 3, `npc_pilgrim`: 3 |
| B61 | 12 | `npc_keeper`: 3, `npc_villager_a`: 9 |
| B62 | 15 | `npc_villager_b`: 9, `npc_corrow_wax`: 3, `npc_corrow_ghost`: 3 |
| B63 | 15 | `hollow_captain_walk`: 9, `hollow_captain_actions`: 6 |
| B64 | 18 | `thorn_warden_walk`: 9, `thorn_warden_actions`: 6, `sump_lurker`: 3 |
| B65 | 15 | `lull_mauler_walk`: 9, `lull_mauler_actions`: 6 |
| B66 | 15 | `mirror_warden_walk`: 9, `mirror_warden_actions`: 6 |
| B67 | 15 | `choir_warden_walk`: 9, `choir_warden_actions`: 6 |
| B68 | 15 | `pale_squire_walk`: 9, `pale_squire_actions`: 6 |
| B69 | 15 | `abacus_brute_walk`: 9, `abacus_brute_actions`: 6 |
| B70 | 15 | `wick_automaton_walk`: 9, `wick_automaton_actions`: 6 |
| B71 | 18 | `corrows_echo_walk`: 9, `corrows_echo_actions`: 6, `miniboss_death_wax`: 3 |
| B72 | 18 | `kilnkeeper_p1`: 6, `kilnkeeper_p2`: 6, `kilnkeeper_death`: 3, `briar_mother_p1`: 3 |
| B73 | 18 | `seed_eye`: 3, `briar_bloom_p2`: 3, `briar_seed`: 3, `tidewick_head`: 9 |
| B74 | 18 | `tidewick_body`: 3, `tidewick_tail`: 3, `hushed_colossus_body`: 3, `hushed_colossus_arms`: 6, `colossus_shard`: 3 |
| B75 | 18 | `archivist_p1`: 3, `archivist_p2_p3`: 3, `archivist_decoy`: 3, `dirge_head_bass`: 3, `dirge_head_alto`: 3, `dirge_head_treble`: 3 |
| B76 | 15 | `gloam_knight_p1`: 9, `gloam_knight_p2`: 6 |
| B77 | 18 | `coinwyrm_head`: 6, `coinwyrm_plates`: 6, `coinwyrm_tail`: 3, `coin_heap`: 3 |
| B78 | 18 | `lock_warden_body`: 6, `lock_plate`: 3, `lock_keyhole`: 3, `unlit_p1_mass`: 3, `unlit_eye`: 3 |
| B79 | 18 | `unlit_hush_hand`: 3, `unlit_p2_shell`: 6, `unlit_p3_heart`: 6, `ninth_lantern`: 3 |
| B80 | 18 | `unlit_chains`: 3, `hud_heart`: 9, `hud_wick_core_slot`: 3, `hud_item_frame`: 3 |
| B81 | 15 | `hud_counter_icons`: 15 |
| B82 | 20 | `hud_fragment_sockets`: 20 |
| B83 | 7 | `hud_fragment_sockets`: 7 |
| B84 | 20 | `hud_minimap_tiles`: 20 |
| B85 | 13 | `hud_minimap_tiles`: 4, `hud_minimap_frame`: 3, `hud_status_band`: 3, `subscreen_panel`: 3 |
| B86 | 15 | `subscreen_slot`: 9, `subscreen_cursor`: 3, `pause_panel`: 3 |
| B87 | 12 | `pause_buttons`: 9, `shop_price_plate`: 3 |
| B88 | 20 | `ui_brass_digits`: 20 |
| B89 | 10 | `ui_brass_digits`: 10 |
| B90 | 20 | `warp_picker_panel`: 20 |
| B91 | 19 | `warp_picker_panel`: 13, `title_menu_panel`: 3, `dialog_prompt_card`: 3 |
| B92 | 18 | `death_overlay`: 3, `loading_wick`: 3, `credit_divider`: 3, `arena_c1`: 3, `arena_c2`: 3, `arena_c3`: 3 |
| B93 | 18 | `arena_c4`: 3, `arena_c5`: 3, `arena_c6`: 3, `arena_c7`: 3, `arena_c8`: 3, `arena_c9`: 3 |
| B94 | 18 | `arena_c10`: 3, `backdrop_ninth_door`: 3, `backdrop_start_village`: 3, `title_splash`: 3, `title_logo`: 3, `intro_01_lanterns`: 3 |
| B95 | 18 | `intro_02_lanternfall`: 3, `intro_03_dusk`: 3, `intro_04_tamsin`: 3, `intro_05_hook`: 3, `intro_06_setout`: 3, `ending_a_rekindle`: 3 |
| B96 | 18 | `ending_b_dawn`: 3, `credits_bg`: 3, `memory_c1`: 3, `memory_c2`: 3, `memory_c3`: 3, `memory_c4`: 3 |
| B97 | 18 | `memory_c5`: 3, `memory_c6`: 3, `memory_c7`: 3, `memory_c8`: 3, `memory_c9`: 3, `ninth_hollow_vista`: 3 |

Total: 97 batches, 1665 images (average 17.2 per batch).

## 5. Unclear points

1. **Cell sizes beyond the contract.** The contract fixes cells up to 192 (288x192 for the swing) and prop sizes. Minibosses (256 to 384), bosses (320 to 768), the raft vehicle, large props and the 32 px minimap tiles are my proposals. The contract needs a second table before the cut tool is configured. The foot-line rule for floating or hanging bosses (centred, no foot) also needs a decision.
2. **What counts as a variant.** I read "variant" as a full regeneration of the same element for the user to cull. Animations with 3 facings are 3 units per variant, so the player rows cost 9 images each at 3 variants. If the user prefers one facing generated three times and the other two derived from the pick, the player total drops by about a third.
3. **Intro script does not exist yet.** `docs/intro-script.md` (D3) is missing; the six intro stills use the briefs of work-packages section 11, which the script is meant to override.
4. **Ending presentation and memories.** `world-work-packages.md` E1 says each ending is "a short sequence of the intro's style", but section 11 lists two ending stills only. The nine `memory_c*` stills (the rekindle scenes of story.md) are not specified anywhere (open question 9 of the monster file), so they are provisional and can be dropped. Same for `npc_corrow_ghost`.
5. **Alpha edge and transition strips.** The contract says terrain textures are opaque. Region transitions, shore foam, pit rims and cave edges need alpha overlay strips (a new format and new cut rules), or the shaders must blend two opaque textures instead. Decide before the `edge_*` rows are generated; they can then be deleted.
6. **Brass price digits.** World-plan 6.5 shows prices "in brass digits", but every art rule forbids numbers. `ui_brass_digits` assumes a glyph sheet is generated as an exception; the alternative is a code font tinted brass (then 30 images fall away).
7. **Watcher eye orientation.** Wall-mounted eyes sit on all four walls. I assumed three drawn views (down, up, side mirrored). The lid-state frames could instead be one view rotated by code.
8. **NPCs.** The plan names six shopkeepers and no other NPCs; Old Corrow is a figure in letters, murals and the C10 echo. `npc_villager_a/b` (the village life) are optional additions.
9. **Hollow, boss and miniboss hurt/death frames.** The contract has no hurt pose for creatures. I assume hit flash by `modulate` and the shared effects `fx_enemy_poof` and `miniboss_death_wax`; bosses get their own death strips.
10. **Boss phases.** Phase looks are drawn as separate sheets only where the monster file changes the body (molten Kilnkeeper, bloom, cracked Gloam Knight, wax shell, heart). Other phases only change attack animations.
11. **Per-cave tinting.** Each cave has its own floor, wall and face textures plus one special. If the user accepts code tinting of three shared cave textures, about 100 images in the terrain category can be cut.
12. **Light textures.** I could not tell from the docs whether the lamp glows are procedural. `light_*` rows are cheap and can be dropped if the shaders already draw them.
13. **Pickups on pedestals.** Only the eight new tools get world sprites. The tether moth and pitch pot reuse their existing sprites on a pedestal.
14. **Backdrops.** Boss arena floor paintings (10), the Ninth Door and the start village are optional; the room kit may make them unnecessary.

