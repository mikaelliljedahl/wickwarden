# Choir Warden Z1 source log

Built-in ImageGen; exact prompts and selected outputs follow. SHA-256 hashes refer to the copied original PNGs.

- `choir_new_side_v2.png`: `01a1833d-cabe-7592-aeda-e5cfdf76d9d5/exec-9769bc0b-9a50-4611-9bb4-860d310e9dc7.png`, SHA-256 `5374548678857fbdffd9e88203bece129de02f9a336c464dd796b4a150d3185a`.
- `choir_new_down_v1.png`: `01a1833d-cabe-7592-aeda-e5cfdf76d9d5/exec-a328f4b8-3bcf-4e7c-bc0e-fcc033bec9a1.png`, SHA-256 `a06b94b9c44a17cfc40bf7e2908c0d14ea6ebe482caa5bbcff25254d4f6826a2`.
- `choir_new_up_v1.png`: `01a1833d-cabe-7592-aeda-e5cfdf76d9d5/exec-2401ad38-fe86-4b79-bbde-f8f51c48c1bb.png`, SHA-256 `0368278af4d7395694474e46a5283b9d071ca7d850778a5ccea9dd604fe24304`.
- `choir_walk_down_z1.png`: `01a183b5-88ab-7a33-a4bc-1bda3e78e7d1/exec-2ec99d9d-7f3e-4b8a-b1c2-2d2735400003.png`, SHA-256 `c57a409bc4808be2fe05d3ca8923c68da80804f5264b58edb774286b78dce8f2`.
- `choir_walk_up_z1.png`: `01a183b5-88ab-7a33-a4bc-1bda3e78e7d1/exec-6a44b9d7-b598-4b5a-9c32-7c39b2710e75.png`, SHA-256 `f02922749dabac4055c47182a490ad1bb939574945944346d556dbf5affe4200`.

## Side prompts

Use case: stylized-concept
Asset type: source sprite sheet for Wickwarden, a top-down action-adventure.
Input image 1 is the documented existing Choir Warden walk sheet: use it as the character identity, proportions, lighting, scale, and right-facing side view reference, not as an image to copy as a four-frame walk.

Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours: tall hooded singer in a long dark-grey robe with brass organ-pipe ribs, pale folded hands, narrow boots. Precisely four separate full-body poses in one horizontal row on a 1536x1024 landscape canvas, all facing right in the same pure side view as the reference. Each figure has the SAME height and body proportions as the walking reference character, approximately 590 source pixels from hood to feet, leave about 200 pixels of empty magenta above and below the figures, exactly like the reference, with feet on the same baseline. Pose 1: neutral walk matching the reference. Pose 2: visibly inhaling, head slightly raised and dark mouth opening, chest expanded. Pose 3: visibly singing, head raised and mouth wide open. Pose 4: recovery, head lowered, hood framing a visible face with a clearly CLOSED mouth; do not hide the mouth in shadow. Each pose has both legs and feet fully visible. No sound ribbons, no particles or glyphs; the game draws the directional sound separately. No extra figures, no overlap, no cropping.

## Down prompts

Use case: stylized-concept
Asset type: source sprite sheet for Wickwarden, a top-down action-adventure.
Input image 1 is the documented existing front-facing Choir Warden walk sheet, and image 2 is the newly generated side action study. Match their character identity, proportions, lighting and scale. Draw the new sheet in the FRONT-facing orientation of image 1.

Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours: tall hooded singer in a long dark-grey robe with brass organ-pipe ribs, pale folded hands, narrow boots. Precisely four separate full-body poses in one horizontal row on a 1536x1024 landscape canvas, all facing directly down toward the viewer in the same frontal orientation as image 1. Each figure has the SAME height and body proportions as the walking reference character, approximately 590 source pixels from hood to feet, leave about 200 pixels of empty magenta above and below the figures, exactly like the reference, with feet on the same baseline. Pose 1: neutral walk matching the reference. Pose 2: visibly inhaling, head slightly raised and dark mouth opening, chest expanded. Pose 3: visibly singing, head raised and mouth wide open. Pose 4: recovery, head lowered, hood framing a visible face with a clearly CLOSED mouth; do not hide the mouth in shadow. Each pose has both legs and feet fully visible. No sound ribbons, no particles or glyphs; the game draws the directional sound separately. No extra figures, no overlap, no cropping.

## Up prompts

Use case: stylized-concept
Asset type: source sprite sheet for Wickwarden, a top-down action-adventure.
Input image 1 is the documented existing rear-facing Choir Warden walk sheet; use it for the character identity, proportions, lighting, scale and direction. Image 2 is the new side action study, a reference for the three stages, not its camera view.

Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours: tall hooded singer in a long dark-grey robe with brass organ-pipe ribs, pale folded hands, narrow boots. Precisely four separate full-body poses in one horizontal row on a 1536x1024 landscape canvas, all facing away from the viewer, showing the BACK in the same view as image 1. Each figure has the SAME height and body proportions as the walking reference character, approximately 590 source pixels from hood to feet, leave about 200 pixels of empty magenta above and below the figures, exactly like the reference, with feet on the same baseline. Pose 1: neutral walk matching the rear reference. Pose 2: inhaling, shoulders and ribs expanded, head tilted up. Pose 3: singing, hooded head clearly tilted upward, ribs expanded. Pose 4: recovery, shoulders and ribs relaxed, hooded head visibly bowed. The mouth faces away, so do not depict a face on the back of the head. Each pose has both legs and feet fully visible. No sound ribbons, no particles or glyphs; the game draws the directional sound separately. No extra figures, no overlap, no cropping.

## Walk prompts

# Built-in ImageGen prompts

Session 01a183b5-88ab-7a33-a4bc-1bda3e78e7d1.

## Down, selected exec-2ec99d9d-7f3e-4b8a-b1c2-2d2735400003.png
Reference: original 01a1833d-cabe-7592-aeda-e5cfdf76d9d5/exec-a328f4b8-3bcf-4e7c-bc0e-fcc033bec9a1.png

Use case: stylized-concept. Asset type: game sprite sheet. Refer to the attached front-facing Choir Warden design, especially its FIRST pose: hood conceals face, clasped hands, long dark frayed cloak with gold trim and organ pipes. Draw this exact character walking TOWARD camera in FOUR clearly DIFFERENT consecutive full-body frames in ONE horizontal row: frame 1 left boot planted forward with right boot back, frame 2 feet together, frame 3 RIGHT boot planted forward with left boot back, frame 4 feet together. Alternate feet visibly; keep the face shadowed and mouth closed in ALL four frames. Preserve the reference figure's size, same pose of hands, same costume, painterly look, camera, proportions and common foot line across the row. Four separate figures with ample empty gaps, no overlaps or cropped feet. Background pure solid magenta #ff00ff; no shadow, floor, effects, text, borders or additional figures.

## Up, selected exec-6a44b9d7-b598-4b5a-9c32-7c39b2710e75.png
Reference: original 01a1833d-cabe-7592-aeda-e5cfdf76d9d5/exec-2401ad38-fe86-4b79-bbde-f8f51c48c1bb.png

Use case: stylized-concept. Asset type: source sprite sheet for a top-down action-adventure. Input image is the existing Choir Warden BACK-view action sheet, identity and scale reference. Create exactly FOUR separate full-body BACK-view walking cycle poses of the SAME hooded organ-pipe warden, facing away from the viewer, in one horizontal row, in sequence: left foot forward, passing, right foot forward, passing. Keep the exact same charcoal hood, gold-trimmed shoulders, ragged layered dark robe and array of bronze organ pipes across the back, proportions, painterly rendering and camera angle as the reference. Only legs and robe move subtly. Keep all four figures the same full-body height, centered on a common ground line, evenly spaced and completely separated with ample gaps, no clipping. Solid pure magenta #ff00ff background. No floor, shadows, text, borders, extra figures or sound effects. Source for 256x256 cells, foot line 236; preserve subject scale across frames.

## Down rejected exec-2114cd52-f825-48c7-a184-b65e2673f800.png
Reference: as selected down.

Use case: stylized-concept. Asset type: source sprite sheet for a top-down action-adventure. Input image is the existing Choir Warden FRONT-view action sheet, identity and scale reference. Create exactly FOUR separate full-body FRONT-view walking cycle poses of the SAME hooded organ-pipe warden, facing toward the viewer, in one horizontal row, in sequence: left foot forward, passing, right foot forward, passing. Keep the exact same charcoal hood, clasped hands, ragged layered dark robe, gold trim and organ pipes, proportions, painterly rendering and camera angle as the reference. Only legs and robe move subtly. Keep all four figures the same full-body height, centered on a common ground line, evenly spaced and completely separated with ample gaps, no clipping. Solid pure magenta #ff00ff background. No floor, shadows, text, borders, extra figures or sound effects. Source for 256x256 cells, foot line 236; preserve subject scale across frames.
