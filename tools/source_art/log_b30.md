# Batch 30 generation log (producer d)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job). Each job copied its PNG unchanged to `tools/source_art/`; the copy was checked by SHA-256 against the PNG in the job's own `~/.codex/generated_images/<session>/` folder, and hashes are unique across `tools/source_art/`. Each image was viewed as a three-variant montage. One prompt and one attempt per image; no image was regenerated.

## Summary (one line per image)

- `pocket_stall_v1.png`: ok - closed (shutters, padlock) and open (lit interior) poses, same scale, ivy and stone base; job still running at the check, file hash matched
- `pocket_stall_v2.png`: ok - closed and open poses, clean
- `pocket_stall_v3.png`: ok - closed and open poses, clean
- `pocket_cart_v1.png`: ok - closed (canvas tied) and open (lit cargo) poses
- `pocket_cart_v2.png`: ok - closed and open poses, clean
- `pocket_cart_v3.png`: ok - open cart holds crates, a barrel, a sack and a lantern instead of a dark hollow; wheels a little large (kept)
- `pocket_lighthouse_door_v1.png`: weak - closed and open poses are right, but the tower base is square, not the round base the entry asks for
- `pocket_lighthouse_door_v2.png`: weak - tower base square, not round (as v1); job was still running at the check, file hash matched
- `pocket_lighthouse_door_v3.png`: weak - tower base square, not round (as v1); faint magenta halo on some foliage edges
- `pocket_mason_door_v1.png`: ok - closed and open poses; chisel and square carved over the door, no letters
- `pocket_mason_door_v2.png`: ok - closed and open poses; door carvings are abstract tool shapes (one reads like a chevron)
- `pocket_mason_door_v3.png`: weak - the carved shape on the door reads like a numeral 2 (the brief forbids numbers and letters)
- `pocket_hut_door_v1.png`: ok - closed and open poses, thatched lintel, ivy; clean
- `pocket_hut_door_v2.png`: ok - closed and open poses, clean
- `pocket_hut_door_v3.png`: ok - closed and open poses; the hut surround (thatch, stone, foliage) is larger than the door alone (kept)
- `pocket_grotto_v1.png`: ok - closed (ferns and shrine niche with candle) and open (dark passage with warm light) poses
- `pocket_grotto_v2.png`: ok - closed and open poses, clean
- `pocket_grotto_v3.png`: ok - closed and open poses; job was still running at the check, file hash matched

## Details

## `pocket_stall_v1.png`

- File: `tools/source_art/pocket_stall_v1.png` (accepted name after the cull: `tools/source_art/pocket_stall.png`)
- Job id: `b30_pocket_stall_v1` (job name `ww-b30-pocket_stall-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4a-8e45-72b3-ac4b-6df646baf43b`
- Generated file name: `exec-0d99c8cc-0558-4bd9-8270-2b7c7c3d1f13.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4a-8e45-72b3-ac4b-6df646baf43b/exec-0d99c8cc-0558-4bd9-8270-2b7c7c3d1f13.png`
- SHA-256: `3790305131fd5df17ece88188250464edb78d7fa724232c778b6e7b531fdb535`
- Verdict: ok. closed (shutters, padlock) and open (lit interior) poses, same scale, ivy and stone base; job still running at the check, file hash matched
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a small market stall with a wine-red and cream striped awning and a wooden counter, the wooden shutters down and a padlock on them; pose 2 the shutters raised and a warm lamp glowing in the dark stall behind the counter. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_stall_v2.png`

- File: `tools/source_art/pocket_stall_v2.png` (accepted name after the cull: `tools/source_art/pocket_stall.png`)
- Job id: `b30_pocket_stall_v2` (job name `ww-b30-pocket_stall-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4a-8f41-7ce1-97e5-eb295f8bff00`
- Generated file name: `exec-9e0d7430-0689-4f4e-b2d4-c57e4586f486.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4a-8f41-7ce1-97e5-eb295f8bff00/exec-9e0d7430-0689-4f4e-b2d4-c57e4586f486.png`
- SHA-256: `1e556b1c36d16d465931627491df9ef028fc79fae3a39a8495e08a0585809e07`
- Verdict: ok. closed and open poses, clean
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a small market stall with a wine-red and cream striped awning and a wooden counter, the wooden shutters down and a padlock on them; pose 2 the shutters raised and a warm lamp glowing in the dark stall behind the counter. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_stall_v3.png`

- File: `tools/source_art/pocket_stall_v3.png` (accepted name after the cull: `tools/source_art/pocket_stall.png`)
- Job id: `b30_pocket_stall_v3` (job name `ww-b30-pocket_stall-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4a-91de-7b00-9536-961aa049ad2d`
- Generated file name: `exec-29603980-081c-4680-a65c-38aa2925601f.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4a-91de-7b00-9536-961aa049ad2d/exec-29603980-081c-4680-a65c-38aa2925601f.png`
- SHA-256: `c6c2e7fd99d8f98186349478db517c771a57b0d19b366e609db908eefed39b20`
- Verdict: ok. closed and open poses, clean
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a small market stall with a wine-red and cream striped awning and a wooden counter, the wooden shutters down and a padlock on them; pose 2 the shutters raised and a warm lamp glowing in the dark stall behind the counter. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_cart_v1.png`

- File: `tools/source_art/pocket_cart_v1.png` (accepted name after the cull: `tools/source_art/pocket_cart.png`)
- Job id: `b30_pocket_cart_v1` (job name `ww-b30-pocket_cart-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4a-9a34-7d10-b604-a44906e539ee`
- Generated file name: `exec-4f0a3133-be02-4eea-949f-838fbe7517c2.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4a-9a34-7d10-b604-a44906e539ee/exec-4f0a3133-be02-4eea-949f-838fbe7517c2.png`
- SHA-256: `781049c6c787b6720dbbd9549a29cb81f20b3a63cfb12fa9204cef03ffaf752a`
- Verdict: ok. closed (canvas tied) and open (lit cargo) poses
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a covered hand cart with grey canvas tied over its load and two iron-rimmed wheels; pose 2 the canvas drawn back and a dark hollow with a warm glow inside. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_cart_v2.png`

- File: `tools/source_art/pocket_cart_v2.png` (accepted name after the cull: `tools/source_art/pocket_cart.png`)
- Job id: `b30_pocket_cart_v2` (job name `ww-b30-pocket_cart-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4a-a42e-7af2-995e-b7ddaf04e9a5`
- Generated file name: `exec-99c1fa85-b5ee-4365-978e-7a3d44a1bf15.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4a-a42e-7af2-995e-b7ddaf04e9a5/exec-99c1fa85-b5ee-4365-978e-7a3d44a1bf15.png`
- SHA-256: `4cabebf9d12f857e8b61bee23c0de7b20c664c47073a16cb06da2dff0f6cb9a5`
- Verdict: ok. closed and open poses, clean
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a covered hand cart with grey canvas tied over its load and two iron-rimmed wheels; pose 2 the canvas drawn back and a dark hollow with a warm glow inside. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_cart_v3.png`

- File: `tools/source_art/pocket_cart_v3.png` (accepted name after the cull: `tools/source_art/pocket_cart.png`)
- Job id: `b30_pocket_cart_v3` (job name `ww-b30-pocket_cart-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4a-a90a-7360-94b1-efed73f983d5`
- Generated file name: `exec-18938ee1-eaeb-4f71-8a9e-d8eadbe97544.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4a-a90a-7360-94b1-efed73f983d5/exec-18938ee1-eaeb-4f71-8a9e-d8eadbe97544.png`
- SHA-256: `b466c83c42daaaa010687cde8b2cd8ebcf1d36bcd6f6670e85f1c406e9dec3f9`
- Verdict: ok. open cart holds crates, a barrel, a sack and a lantern instead of a dark hollow; wheels a little large (kept)
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a covered hand cart with grey canvas tied over its load and two iron-rimmed wheels; pose 2 the canvas drawn back and a dark hollow with a warm glow inside. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_lighthouse_door_v1.png`

- File: `tools/source_art/pocket_lighthouse_door_v1.png` (accepted name after the cull: `tools/source_art/pocket_lighthouse_door.png`)
- Job id: `b30_pocket_lighthouse_door_v1` (job name `ww-b30-pocket_lighthouse_door-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4b-e414-77c1-ae65-487c94637e55`
- Generated file name: `exec-3f0596fd-58bf-4f8a-ad0e-8438ec3b4114.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4b-e414-77c1-ae65-487c94637e55/exec-3f0596fd-58bf-4f8a-ad0e-8438ec3b4114.png`
- SHA-256: `849e08c295c733b641db0daedc67d47c0a32093f57890c5f056f20a70f852505`
- Verdict: weak. closed and open poses are right, but the tower base is square, not the round base the entry asks for
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a round stone tower base with a heavy iron-banded door and a small lamp bracket above it, the door shut; pose 2 the same round base with the heavy door open and warm light inside. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_lighthouse_door_v2.png`

- File: `tools/source_art/pocket_lighthouse_door_v2.png` (accepted name after the cull: `tools/source_art/pocket_lighthouse_door.png`)
- Job id: `b30_pocket_lighthouse_door_v2` (job name `ww-b30-pocket_lighthouse_door-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4b-ecec-7812-b4ec-0c866565e90c`
- Generated file name: `exec-3853b0c5-1efd-45ec-898e-c991e5552ca3.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4b-ecec-7812-b4ec-0c866565e90c/exec-3853b0c5-1efd-45ec-898e-c991e5552ca3.png`
- SHA-256: `be8d3c39fbb78f59bb06c5a0036f0d22e36f20f1c015bf98b4da2c6d8b6171bb`
- Verdict: weak. tower base square, not round (as v1); job was still running at the check, file hash matched
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a round stone tower base with a heavy iron-banded door and a small lamp bracket above it, the door shut; pose 2 the same round base with the heavy door open and warm light inside. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_lighthouse_door_v3.png`

- File: `tools/source_art/pocket_lighthouse_door_v3.png` (accepted name after the cull: `tools/source_art/pocket_lighthouse_door.png`)
- Job id: `b30_pocket_lighthouse_door_v3` (job name `ww-b30-pocket_lighthouse_door-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4b-f595-7500-b98d-93ef2291b0fd`
- Generated file name: `exec-efd64cd0-d5f5-4d1f-a6d5-0c6fb71308a6.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4b-f595-7500-b98d-93ef2291b0fd/exec-efd64cd0-d5f5-4d1f-a6d5-0c6fb71308a6.png`
- SHA-256: `b86f9cc5b6d5d5d19f96fe9580d1b99f1e5650d0c64aadd5ce97c73d925f1e2c`
- Verdict: weak. tower base square, not round (as v1); faint magenta halo on some foliage edges
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a round stone tower base with a heavy iron-banded door and a small lamp bracket above it, the door shut; pose 2 the same round base with the heavy door open and warm light inside. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_mason_door_v1.png`

- File: `tools/source_art/pocket_mason_door_v1.png` (accepted name after the cull: `tools/source_art/pocket_mason_door.png`)
- Job id: `b30_pocket_mason_door_v1` (job name `ww-b30-pocket_mason_door-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4b-fc4f-7f01-a4ba-198d2de23fde`
- Generated file name: `exec-7da56558-a861-42da-8cfd-9746f027e81f.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4b-fc4f-7f01-a4ba-198d2de23fde/exec-7da56558-a861-42da-8cfd-9746f027e81f.png`
- SHA-256: `8ea860226bbf49cd555be6ecc69a46ac292603dc5be3628b6a7b502b7c3735c3`
- Verdict: ok. closed and open poses; chisel and square carved over the door, no letters
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a carved stone door with mason's tool carvings (a chisel, a square, no letters) in a plain stone frame, the door shut; pose 2 the same carved stone door open, a dark passage with warm light beyond it. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_mason_door_v2.png`

- File: `tools/source_art/pocket_mason_door_v2.png` (accepted name after the cull: `tools/source_art/pocket_mason_door.png`)
- Job id: `b30_pocket_mason_door_v2` (job name `ww-b30-pocket_mason_door-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4c-0af0-72c2-92ac-3b71d1768acc`
- Generated file name: `exec-d6e25f0c-84e8-454a-ae2b-e6abaaefe9d5.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4c-0af0-72c2-92ac-3b71d1768acc/exec-d6e25f0c-84e8-454a-ae2b-e6abaaefe9d5.png`
- SHA-256: `eb38908e859598dee6d53d8acf872ad4873d985bf7d21e87f442916bed823216`
- Verdict: ok. closed and open poses; door carvings are abstract tool shapes (one reads like a chevron)
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a carved stone door with mason's tool carvings (a chisel, a square, no letters) in a plain stone frame, the door shut; pose 2 the same carved stone door open, a dark passage with warm light beyond it. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_mason_door_v3.png`

- File: `tools/source_art/pocket_mason_door_v3.png` (accepted name after the cull: `tools/source_art/pocket_mason_door.png`)
- Job id: `b30_pocket_mason_door_v3` (job name `ww-b30-pocket_mason_door-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4c-0d12-75a3-ac3b-f0515577f317`
- Generated file name: `exec-2d9f6510-6642-414f-898b-076b1fa83ea4.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4c-0d12-75a3-ac3b-f0515577f317/exec-2d9f6510-6642-414f-898b-076b1fa83ea4.png`
- SHA-256: `0125157077a8b71595031d4eddece1cd85bbcdee8d504b8135d813de5aa5ae55`
- Verdict: weak. the carved shape on the door reads like a numeral 2 (the brief forbids numbers and letters)
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a carved stone door with mason's tool carvings (a chisel, a square, no letters) in a plain stone frame, the door shut; pose 2 the same carved stone door open, a dark passage with warm light beyond it. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_hut_door_v1.png`

- File: `tools/source_art/pocket_hut_door_v1.png` (accepted name after the cull: `tools/source_art/pocket_hut_door.png`)
- Job id: `b30_pocket_hut_door_v1` (job name `ww-b30-pocket_hut_door-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4d-2c63-7951-a533-a82263f45286`
- Generated file name: `exec-7b75ba5f-6b5b-4901-a3a3-781bba5dc276.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4d-2c63-7951-a533-a82263f45286/exec-7b75ba5f-6b5b-4901-a3a3-781bba5dc276.png`
- SHA-256: `8af22c71763a6f8eb99379c77ee62943e33c36c18b978e602e27128953b86e7d`
- Verdict: ok. closed and open poses, thatched lintel, ivy; clean
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a small plank door in a timber frame under a thatched lintel, shut, with a latch; pose 2 the same plank door open, warm light from inside falling across the threshold. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_hut_door_v2.png`

- File: `tools/source_art/pocket_hut_door_v2.png` (accepted name after the cull: `tools/source_art/pocket_hut_door.png`)
- Job id: `b30_pocket_hut_door_v2` (job name `ww-b30-pocket_hut_door-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4d-315d-7df1-99a2-fe135085506b`
- Generated file name: `exec-3eed0228-956e-4976-8040-632fad2b6ca8.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4d-315d-7df1-99a2-fe135085506b/exec-3eed0228-956e-4976-8040-632fad2b6ca8.png`
- SHA-256: `1014e2b1bcb794974d1c5583531c72d42e61a4e9b5b25975e30305f1cf2e6a78`
- Verdict: ok. closed and open poses, clean
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a small plank door in a timber frame under a thatched lintel, shut, with a latch; pose 2 the same plank door open, warm light from inside falling across the threshold. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_hut_door_v3.png`

- File: `tools/source_art/pocket_hut_door_v3.png` (accepted name after the cull: `tools/source_art/pocket_hut_door.png`)
- Job id: `b30_pocket_hut_door_v3` (job name `ww-b30-pocket_hut_door-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4d-3ab3-7d72-bd4e-49a424c6e7d5`
- Generated file name: `exec-1c46a62b-8516-4079-8d24-8172125f4abc.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4d-3ab3-7d72-bd4e-49a424c6e7d5/exec-1c46a62b-8516-4079-8d24-8172125f4abc.png`
- SHA-256: `98c97ce6088b6e936a946103cd9686c7cedd1124a34337799f8fde45a192ee3e`
- Verdict: ok. closed and open poses; the hut surround (thatch, stone, foliage) is larger than the door alone (kept)
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a small plank door in a timber frame under a thatched lintel, shut, with a latch; pose 2 the same plank door open, warm light from inside falling across the threshold. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_grotto_v1.png`

- File: `tools/source_art/pocket_grotto_v1.png` (accepted name after the cull: `tools/source_art/pocket_grotto.png`)
- Job id: `b30_pocket_grotto_v1` (job name `ww-b30-pocket_grotto-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4d-4492-7201-80e9-78997e3e8b85`
- Generated file name: `exec-14b53597-000d-4e12-a0e1-da26c0924b04.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4d-4492-7201-80e9-78997e3e8b85/exec-14b53597-000d-4e12-a0e1-da26c0924b04.png`
- SHA-256: `e1507a1bd3e8be592b7069920deee62d83901048401042b79730e2622047d016`
- Verdict: ok. closed (ferns and shrine niche with candle) and open (dark passage with warm light) poses
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a grotto in a rock wall, a curtain of ferns hiding a dark recess with a small shrine niche; pose 2 the ferns pulled aside and a dark passage behind them with a faint warm glow. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_grotto_v2.png`

- File: `tools/source_art/pocket_grotto_v2.png` (accepted name after the cull: `tools/source_art/pocket_grotto.png`)
- Job id: `b30_pocket_grotto_v2` (job name `ww-b30-pocket_grotto-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4d-4a34-7070-973f-744e13028788`
- Generated file name: `exec-a976569b-b954-45e0-91f3-7fc2b3b34b6d.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4d-4a34-7070-973f-744e13028788/exec-a976569b-b954-45e0-91f3-7fc2b3b34b6d.png`
- SHA-256: `b3659e1dab4b010b8b198d5313704d2204ac88562a55574009be27ed62a8c8ba`
- Verdict: ok. closed and open poses, clean
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a grotto in a rock wall, a curtain of ferns hiding a dark recess with a small shrine niche; pose 2 the ferns pulled aside and a dark passage behind them with a faint warm glow. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_grotto_v3.png`

- File: `tools/source_art/pocket_grotto_v3.png` (accepted name after the cull: `tools/source_art/pocket_grotto.png`)
- Job id: `b30_pocket_grotto_v3` (job name `ww-b30-pocket_grotto-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4d-51ce-7ff2-a7ea-6bb24b7469f3`
- Generated file name: `exec-4969684c-9b09-4a9e-860d-e0c9785d6e25.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4d-51ce-7ff2-a7ea-6bb24b7469f3/exec-4969684c-9b09-4a9e-860d-e0c9785d6e25.png`
- SHA-256: `8f01c302fc557ef6de22a2c65dceceaba033fef0bd867fadc6a4b0f58f7f784e`
- Verdict: ok. closed and open poses; job was still running at the check, file hash matched
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a grotto in a rock wall, a curtain of ferns hiding a dark recess with a small shrine niche; pose 2 the ferns pulled aside and a dark passage behind them with a faint warm glow. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

