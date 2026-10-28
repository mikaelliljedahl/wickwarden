# Coinwyrm bite sheets, 2026-10-28

Built-in ImageGen; reference for each image: `coinwyrm_bare_head_candidate_20261027a.png`. Both are 1536 × 1024, opaque magenta-key source sheets. Their independently generated poses preserve the bare head; plates remain separate. The first bite attempt (`exec-c79cb7e0-b364-4d72-b694-6c734728f905.png`, SHA-256 `bd32540beee2858e0a4ba716275f0ceab92d628454f810b93d767d8bc4b7825f`) had insufficient gaps and is not installed.

| Source | Session | Output | SHA-256 |
|---|---|---|---|
| `coinwyrm_bite_tell_candidate.png` | `01a180aa-043a-70b0-9eb6-2282cd818f5d` | `exec-74906545-c829-4d46-be55-96edc2670f8e.png` | `16d2b1278b2f9198bc3ea19474f482b4c94189a55ff2620f0969e116264bb5dc` |
| `coinwyrm_bite_candidate.png` | `01a180aa-043a-70b0-9eb6-2282cd818f5d` | `exec-f2c65014-131e-453a-9802-eaca2aabd412.png` | `7769793583d42fc0529b28f44efef6faa8fc323c8d9f45939f489029165eec11` |

Both prompts used the art brief's complete shared style and magenta sheet blocks. The tell requested two separate frontal poses: jaw beginning to open, then wider; matching the reference's head, eyes and exposed forehead and cheeks, with no crown, armour, coins, jewellery or effects. The accepted bite requested three separate frontal poses: mouth wide open, closing, then nearly closed; matching the reference, with clear forehead and cheeks and the same exclusions. It requested at least 100 px gaps and generous margins; actual gaps were smaller but visibly clear and the default cutter segmented all three. Both sheets use one scale factor per animation matched to the existing idle reference; proof sheets were inspected. B08 uses these strips for downward bites; other directions retain the existing directional strike effect. Actual arena captures with and without plates were reviewed in a controlled fixture.

## Exact prompts

The following shared block preceded each request:

> Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark. A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Tell, after the shared block:

> Create a 1536x1024 landscape sprite sheet with exactly TWO separate large poses in one horizontal row. Reference image is the exact character design and proportions, not a layout: the same bare frontal dark bronze reptile head and short neck, same eyes, forehead and cheeks, no crown, no armour plates, no coins or jewelry. Maintain the same fixed head and face position and scale in both poses. Pose 1 jaw begins opening; pose 2 jaw opens wider as a warning before biting. Preserve open space on the brow and cheeks for separately attached plates. No extra objects, no effects.

Accepted bite, after the shared block:

> 1536x1024 landscape, exactly three distinct separated heads in one horizontal row. Make each head small enough that at least 100 pixels of blank magenta separate every silhouette and generous margin surrounds the image. The reference is the exact bare bronze serpent head and short neck; same facial proportions and position; frontal view. No crown, no armour plates, no coins or jewelry; forehead and cheeks remain clear for independent armour overlays. First mouth wide open, second mouth closing, third mouth nearly closed recovering. No other objects or effects.
