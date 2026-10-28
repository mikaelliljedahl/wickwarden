# Gloam Knight slash candidate, 2026-10-28

Built-in image generation tool, model version not exposed. Design reference:
`tools/source_art/gloam_knight_p1_side_v1.png` (SHA-256
`0b67f91cee58a74a5616c97a96a0161be43abcf1b6d70ef2c164ccb8581e6cbc`).
The second attempt is saved unchanged as
`gloam_knight_slash_side_candidate_20261028.png`, 2172×724 RGB,
SHA-256 `04d8c6733589f6014e4cf26418c2a2aa788ee16f717e6da3a2d2385060541959`;
original output `01a18068-d14c-7220-a7a6-c9c04c87379b/exec-56854add-22c8-445c-b27f-1bfe926f7cb1.png`.

Review: four distinct complete figures, separated by real magenta column gaps;
the ordinary cutter found four and the proof showed intact silhouettes. The
third pose had to slide 4 pixels to fit its 320-pixel cell. With the existing
shared `gloam_knight` scale factor, however, these bodies are substantially
larger than the existing side walk: cutter body-height measurements are
250–286 versus 201–209 source pixels. Thus the candidate is not registered
for runtime; the size jump remains unresolved. No scaling or image editing was
applied to the saved source.

First attempt output `exec-92dbe539-ec99-4d72-8f9b-850e55d83758.png` in the
same session: rejected because two poses touch; cutter found three groups.
Third attempt output `exec-95474975-29c1-47ce-af00-f68dda7c69cb.png` in the
same session, SHA-256 `e7f1cd6a2d9d296cc8dcbef1241ea0d5bd13d10f63675dedeb3e66c6f4bbd08e`:
its figures remain comparably large; not registered or copied into source_art.

## Saved candidate prompt

Use case: stylized-concept. Asset type: game animation sprite sheet. Reference image: same original Gloam Knight, identical dark glass-black armour, plain plumed helm, ragged deep dusk cape, lance, colours and proportions. Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark. A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions. Exactly four small complete poses arranged in one horizontal row with exceptionally wide vertical magenta gaps between the entire silhouettes including all lance tips and capes. Faces right: 1 slash telegraph with lance nearly vertical overhead; 2 first slash, lance held diagonally upwards close to body; 3 reverse slash, lance held diagonally downwards close to body; 4 recovery, lance vertical at side. Each lance stays within the width of its own figure. Do not add slash trails, effects, shadows, other objects or figures. Leave at least one entire figure width of empty background between silhouettes. Large margins.

## Fourth attempt: explicit source dimensions and figure height

Built-in image generation, same session and reference. Output
`exec-caa04075-84ed-4ece-b085-3fa507913330.png`, SHA-256
`bf5341b2ba11a8431c7e2791787fb81f786d235452027f5279865be4a4cb6653`.
The returned image is 2167×725 RGB, not the requested 1536×1024. The
figures appear substantially larger than the reference, and their silhouettes
and effects overlap in x. In an isolated trial with the normal cutter, the
row produced two groups instead of four; it stopped on the pose-count error.
No strip or foot-line proof was produced, and this rejected output was not
copied to source_art or registered for runtime. The generated original remains
in the built-in tool's session directory. Model version was not exposed.

Prompt:

Use case: stylized-concept. Asset type: original game animation sprite sheet. Input image is the design and absolute pixel-size reference. Create exactly four complete Gloam Knight attack poses on one shared 1536 x 1024 pixel source canvas. Each knight's body height from soles to helmet, excluding plume and lance, must be approximately 205 pixels, matching the reference figures' body height in source pixels. Keep ALL four figures at this same pixel scale, without enlargement; leave generous empty space around and between them. Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark. A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions. Same Gloam Knight as reference: dark glass-black armour, plain plumed helm, ragged deep-dusk cape and lance. Four distinct poses in one horizontal row, facing right: lance raised back in telegraph, first strike, return strike, recovery. Keep entire lances and capes within their own pose, with broad completely empty vertical magenta gaps between neighbouring silhouettes; no trails or effects cross the gaps. No additional figures.
