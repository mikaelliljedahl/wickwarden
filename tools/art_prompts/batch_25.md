# Batch 25 prompts (18 images)

Source: `docs/art-inventory.md` section 4, row B25. Run recipe, prompt rules and file layout: [README.md](README.md). Sprite sheets are on a pure magenta `#FF00FF` key (no subject in this batch has magenta); textures have no key. Hi-fi painterly, never pixel art. Sheets are 1536x1024; a multi-row sheet has one animation or state per row, read top to bottom.

Facing and pose rule (from `tools/art_prompts/PROGRESS.md`): no sheet in this batch is a walk cycle or a turned figure, so the facing and leg rules do not apply. Every pose is described on its own, the camera angle is fixed in every pose, and no two poses in a row are the same picture.

Rows: `eye_switch`: 3, `eye_portcullis`: 3, `eye_cell`: 3, `mooring`: 3, `edge_pit_rim`: 3, `pit_fill`: 3.

## `eye_switch`

### b25_eye_switch_v1

- Job id: `b25_eye_switch_v1`
- Output file: `tools/source_art/eye_switch_v1.png`
- Key colour: pure magenta `#FF00FF`
- Size: 1536x1024
- Reference images (style and scale only, no design copied): `tools/source_art/ow_structures.png`
- Variant: 1 of 3
- Accepted name after the cull: `tools/source_art/eye_switch.png`
- Note: off 1, hit 2, on 1; cell 128

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

A carved stone eye set into a stone slab on a wall: a heavy stone lid over a round iris, the iris a cold blue. One row of four poses: off, hit, hit, on. Exactly 4 separate poses in one horizontal row, all at the same scale, all on one common ground line, wide equal gaps between them. Pose pose 1 of 4: Off: the lid closed and the iris dull grey-blue. Pose pose 2 of 4: Hit: the lid lifted a little, the iris flaring bright. Pose pose 3 of 4: Hit: the iris flashing pale blue with a small spark. Pose pose 4 of 4: On: the lid fully lifted, the iris steady warm blue-white. Variation for this image: Neutral, clear composition; poses evenly spaced. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

### b25_eye_switch_v2

- Job id: `b25_eye_switch_v2`
- Output file: `tools/source_art/eye_switch_v2.png`
- Key colour: pure magenta `#FF00FF`
- Size: 1536x1024
- Reference images (style and scale only, no design copied): `tools/source_art/ow_structures.png`
- Variant: 2 of 3
- Accepted name after the cull: `tools/source_art/eye_switch.png`
- Note: off 1, hit 2, on 1; cell 128

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

A carved stone eye set into a stone slab on a wall: a heavy stone lid over a round iris, the iris a cold blue. One row of four poses: off, hit, hit, on. Exactly 4 separate poses in one horizontal row, all at the same scale, all on one common ground line, wide equal gaps between them. Pose pose 1 of 4: Off: the lid closed and the iris dull grey-blue. Pose pose 2 of 4: Hit: the lid lifted a little, the iris flaring bright. Pose pose 3 of 4: Hit: the iris flashing pale blue with a small spark. Pose pose 4 of 4: On: the lid fully lifted, the iris steady warm blue-white. Variation for this image: Slightly warmer light and stronger detail in the material; poses spaced the same way. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

### b25_eye_switch_v3

- Job id: `b25_eye_switch_v3`
- Output file: `tools/source_art/eye_switch_v3.png`
- Key colour: pure magenta `#FF00FF`
- Size: 1536x1024
- Reference images (style and scale only, no design copied): `tools/source_art/ow_structures.png`
- Variant: 3 of 3
- Accepted name after the cull: `tools/source_art/eye_switch.png`
- Note: off 1, hit 2, on 1; cell 128

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

A carved stone eye set into a stone slab on a wall: a heavy stone lid over a round iris, the iris a cold blue. One row of four poses: off, hit, hit, on. Exactly 4 separate poses in one horizontal row, all at the same scale, all on one common ground line, wide equal gaps between them. Pose pose 1 of 4: Off: the lid closed and the iris dull grey-blue. Pose pose 2 of 4: Hit: the lid lifted a little, the iris flaring bright. Pose pose 3 of 4: Hit: the iris flashing pale blue with a small spark. Pose pose 4 of 4: On: the lid fully lifted, the iris steady warm blue-white. Variation for this image: Calmer, softer light with a little more age and weathering on the surface; poses spaced the same way. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## `eye_portcullis`

### b25_eye_portcullis_v1

- Job id: `b25_eye_portcullis_v1`
- Output file: `tools/source_art/eye_portcullis_v1.png`
- Key colour: pure magenta `#FF00FF`
- Size: 1536x1024
- Reference images (style and scale only, no design copied): `tools/source_art/ow_structures.png`
- Variant: 1 of 3
- Accepted name after the cull: `tools/source_art/eye_portcullis.png`
- Note: closed 1, opening 4, open 1

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

A stone arch in a wall with an iron portcullis: a grille of heavy iron bars with pointed tips, hanging in the arch. Three rows, each row one state. Exactly 6 separate poses in 3 horizontal rows (counts from the top: 1, 4, 1), all at the same scale, each row on its own ground line, wide equal gaps between all poses. Row 1 closed pose 1 of 1: The grille lowered to the ground, closed. Row 2 opening pose 1 of 4: The grille lifted a little off the ground. Row 2 opening pose 2 of 4: The grille lifted a third of the arch. Row 2 opening pose 3 of 4: The grille lifted about two thirds of the arch. Row 2 opening pose 4 of 4: The grille nearly fully raised, a thin gap left at the bottom. Row 3 open pose 1 of 1: The grille fully raised into the top of the arch, the passage clear. Variation for this image: Neutral, clear composition; poses evenly spaced. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

### b25_eye_portcullis_v2

- Job id: `b25_eye_portcullis_v2`
- Output file: `tools/source_art/eye_portcullis_v2.png`
- Key colour: pure magenta `#FF00FF`
- Size: 1536x1024
- Reference images (style and scale only, no design copied): `tools/source_art/ow_structures.png`
- Variant: 2 of 3
- Accepted name after the cull: `tools/source_art/eye_portcullis.png`
- Note: closed 1, opening 4, open 1

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

A stone arch in a wall with an iron portcullis: a grille of heavy iron bars with pointed tips, hanging in the arch. Three rows, each row one state. Exactly 6 separate poses in 3 horizontal rows (counts from the top: 1, 4, 1), all at the same scale, each row on its own ground line, wide equal gaps between all poses. Row 1 closed pose 1 of 1: The grille lowered to the ground, closed. Row 2 opening pose 1 of 4: The grille lifted a little off the ground. Row 2 opening pose 2 of 4: The grille lifted a third of the arch. Row 2 opening pose 3 of 4: The grille lifted about two thirds of the arch. Row 2 opening pose 4 of 4: The grille nearly fully raised, a thin gap left at the bottom. Row 3 open pose 1 of 1: The grille fully raised into the top of the arch, the passage clear. Variation for this image: Slightly warmer light and stronger detail in the material; poses spaced the same way. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

### b25_eye_portcullis_v3

- Job id: `b25_eye_portcullis_v3`
- Output file: `tools/source_art/eye_portcullis_v3.png`
- Key colour: pure magenta `#FF00FF`
- Size: 1536x1024
- Reference images (style and scale only, no design copied): `tools/source_art/ow_structures.png`
- Variant: 3 of 3
- Accepted name after the cull: `tools/source_art/eye_portcullis.png`
- Note: closed 1, opening 4, open 1

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

A stone arch in a wall with an iron portcullis: a grille of heavy iron bars with pointed tips, hanging in the arch. Three rows, each row one state. Exactly 6 separate poses in 3 horizontal rows (counts from the top: 1, 4, 1), all at the same scale, each row on its own ground line, wide equal gaps between all poses. Row 1 closed pose 1 of 1: The grille lowered to the ground, closed. Row 2 opening pose 1 of 4: The grille lifted a little off the ground. Row 2 opening pose 2 of 4: The grille lifted a third of the arch. Row 2 opening pose 3 of 4: The grille lifted about two thirds of the arch. Row 2 opening pose 4 of 4: The grille nearly fully raised, a thin gap left at the bottom. Row 3 open pose 1 of 1: The grille fully raised into the top of the arch, the passage clear. Variation for this image: Calmer, softer light with a little more age and weathering on the surface; poses spaced the same way. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## `eye_cell`

### b25_eye_cell_v1

- Job id: `b25_eye_cell_v1`
- Output file: `tools/source_art/eye_cell_v1.png`
- Key colour: pure magenta `#FF00FF`
- Size: 1536x1024
- Reference images (style and scale only, no design copied): `tools/source_art/ow_structures.png`
- Variant: 1 of 3
- Accepted name after the cull: `tools/source_art/eye_cell.png`
- Note: closed 1, opening 3, open 1

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

A heavy iron cell door set in a stone wall, with a carved stone eye in its centre and a cold blue iris. Three rows, each row one state. Exactly 5 separate poses in 3 horizontal rows (counts from the top: 1, 3, 1), all at the same scale, each row on its own ground line, wide equal gaps between all poses. Row 1 closed pose 1 of 1: The door closed. Row 2 opening pose 1 of 3: The door a finger's width ajar. Row 2 opening pose 2 of 3: The door half open, a dark cell behind it. Row 2 opening pose 3 of 3: The door nearly fully open. Row 3 open pose 1 of 1: The door fully open, the cell dark inside. Variation for this image: Neutral, clear composition; poses evenly spaced. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

### b25_eye_cell_v2

- Job id: `b25_eye_cell_v2`
- Output file: `tools/source_art/eye_cell_v2.png`
- Key colour: pure magenta `#FF00FF`
- Size: 1536x1024
- Reference images (style and scale only, no design copied): `tools/source_art/ow_structures.png`
- Variant: 2 of 3
- Accepted name after the cull: `tools/source_art/eye_cell.png`
- Note: closed 1, opening 3, open 1

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

A heavy iron cell door set in a stone wall, with a carved stone eye in its centre and a cold blue iris. Three rows, each row one state. Exactly 5 separate poses in 3 horizontal rows (counts from the top: 1, 3, 1), all at the same scale, each row on its own ground line, wide equal gaps between all poses. Row 1 closed pose 1 of 1: The door closed. Row 2 opening pose 1 of 3: The door a finger's width ajar. Row 2 opening pose 2 of 3: The door half open, a dark cell behind it. Row 2 opening pose 3 of 3: The door nearly fully open. Row 3 open pose 1 of 1: The door fully open, the cell dark inside. Variation for this image: Slightly warmer light and stronger detail in the material; poses spaced the same way. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

### b25_eye_cell_v3

- Job id: `b25_eye_cell_v3`
- Output file: `tools/source_art/eye_cell_v3.png`
- Key colour: pure magenta `#FF00FF`
- Size: 1536x1024
- Reference images (style and scale only, no design copied): `tools/source_art/ow_structures.png`
- Variant: 3 of 3
- Accepted name after the cull: `tools/source_art/eye_cell.png`
- Note: closed 1, opening 3, open 1

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

A heavy iron cell door set in a stone wall, with a carved stone eye in its centre and a cold blue iris. Three rows, each row one state. Exactly 5 separate poses in 3 horizontal rows (counts from the top: 1, 3, 1), all at the same scale, each row on its own ground line, wide equal gaps between all poses. Row 1 closed pose 1 of 1: The door closed. Row 2 opening pose 1 of 3: The door a finger's width ajar. Row 2 opening pose 2 of 3: The door half open, a dark cell behind it. Row 2 opening pose 3 of 3: The door nearly fully open. Row 3 open pose 1 of 1: The door fully open, the cell dark inside. Variation for this image: Calmer, softer light with a little more age and weathering on the surface; poses spaced the same way. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## `mooring`

### b25_mooring_v1

- Job id: `b25_mooring_v1`
- Output file: `tools/source_art/mooring_v1.png`
- Key colour: pure magenta `#FF00FF`
- Size: 1536x1024
- Reference images (style and scale only, no design copied): `tools/source_art/ow_props.png`
- Variant: 1 of 3
- Accepted name after the cull: `tools/source_art/mooring.png`
- Note: idle 2 (sway), occupied 1; cell 96x160

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

A short wooden mooring post at the water's edge, weathered grey wood with an iron ring on its top and a coil of rope. Cell 96 wide and 160 tall. One row of three poses. Exactly 3 separate poses in one horizontal row, all at the same scale, all on one common ground line, wide equal gaps between them. Pose pose 1 of 3: Idle: the rope hanging loose from the ring. Pose pose 2 of 3: Idle: the rope swung a little to the left, the post unchanged. Pose pose 3 of 3: Occupied: a raft's rope tied to the ring and pulled taut. Variation for this image: Neutral, clear composition; poses evenly spaced. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

### b25_mooring_v2

- Job id: `b25_mooring_v2`
- Output file: `tools/source_art/mooring_v2.png`
- Key colour: pure magenta `#FF00FF`
- Size: 1536x1024
- Reference images (style and scale only, no design copied): `tools/source_art/ow_props.png`
- Variant: 2 of 3
- Accepted name after the cull: `tools/source_art/mooring.png`
- Note: idle 2 (sway), occupied 1; cell 96x160

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

A short wooden mooring post at the water's edge, weathered grey wood with an iron ring on its top and a coil of rope. Cell 96 wide and 160 tall. One row of three poses. Exactly 3 separate poses in one horizontal row, all at the same scale, all on one common ground line, wide equal gaps between them. Pose pose 1 of 3: Idle: the rope hanging loose from the ring. Pose pose 2 of 3: Idle: the rope swung a little to the left, the post unchanged. Pose pose 3 of 3: Occupied: a raft's rope tied to the ring and pulled taut. Variation for this image: Slightly warmer light and stronger detail in the material; poses spaced the same way. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

### b25_mooring_v3

- Job id: `b25_mooring_v3`
- Output file: `tools/source_art/mooring_v3.png`
- Key colour: pure magenta `#FF00FF`
- Size: 1536x1024
- Reference images (style and scale only, no design copied): `tools/source_art/ow_props.png`
- Variant: 3 of 3
- Accepted name after the cull: `tools/source_art/mooring.png`
- Note: idle 2 (sway), occupied 1; cell 96x160

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

A short wooden mooring post at the water's edge, weathered grey wood with an iron ring on its top and a coil of rope. Cell 96 wide and 160 tall. One row of three poses. Exactly 3 separate poses in one horizontal row, all at the same scale, all on one common ground line, wide equal gaps between them. Pose pose 1 of 3: Idle: the rope hanging loose from the ring. Pose pose 2 of 3: Idle: the rope swung a little to the left, the post unchanged. Pose pose 3 of 3: Occupied: a raft's rope tied to the ring and pulled taut. Variation for this image: Calmer, softer light with a little more age and weathering on the surface; poses spaced the same way. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## `edge_pit_rim`

### b25_edge_pit_rim_v1

- Job id: `b25_edge_pit_rim_v1`
- Output file: `tools/source_art/edge_pit_rim_v1.png`
- Key colour: pure magenta `#FF00FF`
- Size: 1536x1024
- Reference images (style and scale only, no design copied): `tools/source_art/ow_props.png`
- Variant: 1 of 3
- Accepted name after the cull: `tools/source_art/edge_pit_rim.png`
- Note: 3 pieces: straight 384x96-type strip, inner corner, outer corner; cut tool needs a multi-piece edge rule

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

An edge strip for a pit: a stone rim along the edge of a dark pit, drawn as an overlay: a lip of cut grey stone with a dark shadow under it, the same stone and the same light from the upper left in every piece. Three separate pieces on one image, no piece touching another, all on the flat magenta #FF00FF key background. (a) A straight piece of the rim, about four times as long as it is tall, placed across the upper part of the image and centred; its opaque stone face sits at the top of the piece and its lower edge fades out to nothing. (b) An inner corner piece, a small square, and (c) an outer corner piece, a small square; both corners placed side by side in the lower part of the image, with a wide gap between the three pieces. Each piece is an alpha overlay: the stone is opaque, the blend towards the pit is soft and transparent. Exactly three pieces. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text. Variation for this image: Neutral, clear composition; poses evenly spaced. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

### b25_edge_pit_rim_v2

- Job id: `b25_edge_pit_rim_v2`
- Output file: `tools/source_art/edge_pit_rim_v2.png`
- Key colour: pure magenta `#FF00FF`
- Size: 1536x1024
- Reference images (style and scale only, no design copied): `tools/source_art/ow_props.png`
- Variant: 2 of 3
- Accepted name after the cull: `tools/source_art/edge_pit_rim.png`
- Note: 3 pieces: straight 384x96-type strip, inner corner, outer corner; cut tool needs a multi-piece edge rule

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

An edge strip for a pit: a stone rim along the edge of a dark pit, drawn as an overlay: a lip of cut grey stone with a dark shadow under it, the same stone and the same light from the upper left in every piece. Three separate pieces on one image, no piece touching another, all on the flat magenta #FF00FF key background. (a) A straight piece of the rim, about four times as long as it is tall, placed across the upper part of the image and centred; its opaque stone face sits at the top of the piece and its lower edge fades out to nothing. (b) An inner corner piece, a small square, and (c) an outer corner piece, a small square; both corners placed side by side in the lower part of the image, with a wide gap between the three pieces. Each piece is an alpha overlay: the stone is opaque, the blend towards the pit is soft and transparent. Exactly three pieces. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text. Variation for this image: Slightly warmer light and stronger detail in the material; poses spaced the same way. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

### b25_edge_pit_rim_v3

- Job id: `b25_edge_pit_rim_v3`
- Output file: `tools/source_art/edge_pit_rim_v3.png`
- Key colour: pure magenta `#FF00FF`
- Size: 1536x1024
- Reference images (style and scale only, no design copied): `tools/source_art/ow_props.png`
- Variant: 3 of 3
- Accepted name after the cull: `tools/source_art/edge_pit_rim.png`
- Note: 3 pieces: straight 384x96-type strip, inner corner, outer corner; cut tool needs a multi-piece edge rule

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

An edge strip for a pit: a stone rim along the edge of a dark pit, drawn as an overlay: a lip of cut grey stone with a dark shadow under it, the same stone and the same light from the upper left in every piece. Three separate pieces on one image, no piece touching another, all on the flat magenta #FF00FF key background. (a) A straight piece of the rim, about four times as long as it is tall, placed across the upper part of the image and centred; its opaque stone face sits at the top of the piece and its lower edge fades out to nothing. (b) An inner corner piece, a small square, and (c) an outer corner piece, a small square; both corners placed side by side in the lower part of the image, with a wide gap between the three pieces. Each piece is an alpha overlay: the stone is opaque, the blend towards the pit is soft and transparent. Exactly three pieces. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text. Variation for this image: Calmer, softer light with a little more age and weathering on the surface; poses spaced the same way. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## `pit_fill`

### b25_pit_fill_v1

- Job id: `b25_pit_fill_v1`
- Output file: `tools/source_art/pit_fill_v1.png`
- Key colour: none (texture, opaque seamless)
- Size: 1024x1024
- Reference images (style and scale only, no design copied): `tools/source_art/tex_ground_cave.png`
- Variant: 1 of 3
- Accepted name after the cull: `tools/source_art/pit_fill.png`
- Note: texture; no key colour

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A seamless tileable texture seen straight from above, filling the whole square image edge to edge, even lighting with no vignette and no single dominant feature, so that it repeats without visible seams. No objects that stand up from the surface, no perspective.

A dark void: deep blue-black with faint dusk-violet mist and slight variation in depth, very soft, as seen down into a pit. No edge, no rim, no stones, nothing standing up from the surface. Variation for this image: Neutral, clear composition; poses evenly spaced. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1024x1024.
```

### b25_pit_fill_v2

- Job id: `b25_pit_fill_v2`
- Output file: `tools/source_art/pit_fill_v2.png`
- Key colour: none (texture, opaque seamless)
- Size: 1024x1024
- Reference images (style and scale only, no design copied): `tools/source_art/tex_ground_cave.png`
- Variant: 2 of 3
- Accepted name after the cull: `tools/source_art/pit_fill.png`
- Note: texture; no key colour

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A seamless tileable texture seen straight from above, filling the whole square image edge to edge, even lighting with no vignette and no single dominant feature, so that it repeats without visible seams. No objects that stand up from the surface, no perspective.

A dark void: deep blue-black with faint dusk-violet mist and slight variation in depth, very soft, as seen down into a pit. No edge, no rim, no stones, nothing standing up from the surface. Variation for this image: Slightly warmer light and stronger detail in the material; poses spaced the same way. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1024x1024.
```

### b25_pit_fill_v3

- Job id: `b25_pit_fill_v3`
- Output file: `tools/source_art/pit_fill_v3.png`
- Key colour: none (texture, opaque seamless)
- Size: 1024x1024
- Reference images (style and scale only, no design copied): `tools/source_art/tex_ground_cave.png`
- Variant: 3 of 3
- Accepted name after the cull: `tools/source_art/pit_fill.png`
- Note: texture; no key colour

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A seamless tileable texture seen straight from above, filling the whole square image edge to edge, even lighting with no vignette and no single dominant feature, so that it repeats without visible seams. No objects that stand up from the surface, no perspective.

A dark void: deep blue-black with faint dusk-violet mist and slight variation in depth, very soft, as seen down into a pit. No edge, no rim, no stones, nothing standing up from the surface. Variation for this image: Calmer, softer light with a little more age and weathering on the surface; poses spaced the same way. The camera angle is the same in every pose. No extra poses, no cropping, no touching. Painterly high detail, no pixel art, no text.

Image size: 1024x1024.
```
