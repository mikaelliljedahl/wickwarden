# Batch 29 generation log (producer d)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job). Each job copied its PNG unchanged to `tools/source_art/`; the copy was checked by SHA-256 against the PNG in the job's own `~/.codex/generated_images/<session>/` folder, and hashes are unique across `tools/source_art/`. Each image was viewed as a three-variant montage. One prompt and one attempt per image; no image was regenerated.

## Summary (one line per image)

- `reed_cluster_v1.png`: ok - 1 whole + 3 cut poses in two rows; cut stems visible, same scale
- `reed_cluster_v2.png`: ok - 1 whole + 3 cut poses; the first cut pose is busy, stems overlap inside the clump
- `reed_cluster_v3.png`: ok - 1 whole + 3 cut poses; cut progression clear
- `rush_wall_v1.png`: ok - 1 whole + 3 cut poses; stone posts with moss and flowers and loose straw around; cut progression clear
- `rush_wall_v2.png`: ok - 1 whole + 3 cut poses; the sheet adds stone posts, flowers and rocks around the rushes (kept, within the description)
- `rush_wall_v3.png`: ok - 1 whole + 3 cut poses; all poses separated
- `moss_wall_v1.png`: ok - 1 whole + 3 cut poses; the curtain parts progressively in the cut poses; bottom poses large and close to the edges, not cropped
- `moss_wall_v2.png`: ok - 1 whole + 3 cut poses, clean
- `moss_wall_v3.png`: ok - 1 whole + 3 cut poses; moss is bright yellow-green rather than wet dusk green (kept)
- `dry_vine_screen_v1.png`: weak - each pose is two posts with vines between them (the sheet adds posts); the gap finder would see six blobs for three cut poses (count mismatch); prompt wording caused the posts
- `dry_vine_screen_v2.png`: weak - same as v1: two stone posts with vines between them in every pose; the cut poses split into six blobs by the gap finder
- `dry_vine_screen_v3.png`: weak - same as v1: two posts with vines between them in every pose; the cut poses split into six blobs by the gap finder
- `bush_cluster_v1.png`: weak - row 2 holds an uncut bush plus two cut poses, each cut pose shown as two halves: five blobs instead of three cut poses; the first row (whole) is fine
- `bush_cluster_v2.png`: weak - same layout as v1: an uncut bush in the cut row and two cut poses each made of two halves (five blobs)
- `bush_cluster_v3.png`: weak - same layout as v1: the cut row starts with an uncut bush, cut poses are split into halves
- `brittle_rocks_v1.png`: ok - whole heap and blasted rubble pose, same scale; foliage and flowers cover the heaps more than the brief (bare brittle rocks) asks
- `brittle_rocks_v2.png`: ok - whole heap and blasted pose with rubble; greenery covers both poses; the blasted pose keeps a rock centre
- `brittle_rocks_v3.png`: ok - whole heap and blasted pose; leafy growth and flowers on both poses, the blasted pose still has several large intact rocks

## Details

## `reed_cluster_v1.png`

- File: `tools/source_art/reed_cluster_v1.png` (accepted name after the cull: `tools/source_art/reed_cluster.png`)
- Job id: `b29_reed_cluster_v1` (job name `ww-b29-reed_cluster-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f45-affe-79c3-8e98-1e906cba22be`
- Generated file name: `exec-522e9ca7-5e2c-4eb6-ae4b-7790da3c9783.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f45-affe-79c3-8e98-1e906cba22be/exec-522e9ca7-5e2c-4eb6-ae4b-7790da3c9783.png`
- SHA-256: `7ea28b36aa2f9303b3eb1ba3ae4106641ae3b76a27e057d62cf39a4336df5850`
- Verdict: ok. 1 whole + 3 cut poses in two rows; cut stems visible, same scale
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A thick clump of tall dusk-coloured reeds, straight and dense, filling a gap as a screen. Row 2 (cut, 3 poses): The same reed screen cut by a hook: pose 1 the first stems are sliced through with pale fresh ends showing, pose 2 a wide slice has cut a gap through the middle and the cut stems bend, pose 3 the gap is open and the cut stems lie flat. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `reed_cluster_v2.png`

- File: `tools/source_art/reed_cluster_v2.png` (accepted name after the cull: `tools/source_art/reed_cluster.png`)
- Job id: `b29_reed_cluster_v2` (job name `ww-b29-reed_cluster-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f45-b099-7543-9306-c6c0bca76a6f`
- Generated file name: `exec-afa07197-aaf1-4239-a5b7-c200aa16fd6b.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f45-b099-7543-9306-c6c0bca76a6f/exec-afa07197-aaf1-4239-a5b7-c200aa16fd6b.png`
- SHA-256: `8383db2734785ccb9bf673a181f53500ae620a6af99cd18c4371821b8c845893`
- Verdict: ok. 1 whole + 3 cut poses; the first cut pose is busy, stems overlap inside the clump
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A thick clump of tall dusk-coloured reeds, straight and dense, filling a gap as a screen. Row 2 (cut, 3 poses): The same reed screen cut by a hook: pose 1 the first stems are sliced through with pale fresh ends showing, pose 2 a wide slice has cut a gap through the middle and the cut stems bend, pose 3 the gap is open and the cut stems lie flat. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `reed_cluster_v3.png`

- File: `tools/source_art/reed_cluster_v3.png` (accepted name after the cull: `tools/source_art/reed_cluster.png`)
- Job id: `b29_reed_cluster_v3` (job name `ww-b29-reed_cluster-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f45-b7e9-7bf3-8981-71c9ce8ea035`
- Generated file name: `exec-c89b95a4-413e-48a5-954d-fe5dd0331de2.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f45-b7e9-7bf3-8981-71c9ce8ea035/exec-c89b95a4-413e-48a5-954d-fe5dd0331de2.png`
- SHA-256: `69eb3ec583e66e4d4935e56ef8cdfffbdc6fc49dab8be0c0d86459e7e50679ee`
- Verdict: ok. 1 whole + 3 cut poses; cut progression clear
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A thick clump of tall dusk-coloured reeds, straight and dense, filling a gap as a screen. Row 2 (cut, 3 poses): The same reed screen cut by a hook: pose 1 the first stems are sliced through with pale fresh ends showing, pose 2 a wide slice has cut a gap through the middle and the cut stems bend, pose 3 the gap is open and the cut stems lie flat. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `rush_wall_v1.png`

- File: `tools/source_art/rush_wall_v1.png` (accepted name after the cull: `tools/source_art/rush_wall.png`)
- Job id: `b29_rush_wall_v1` (job name `ww-b29-rush_wall-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f45-beb5-7233-b177-900c1161b06e`
- Generated file name: `exec-f1982be8-00e6-4395-9d96-0c2002679291.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f45-beb5-7233-b177-900c1161b06e/exec-f1982be8-00e6-4395-9d96-0c2002679291.png`
- SHA-256: `bd3c6f8d3d74783322ec704a43a96a2a21ca67c551365c60c0be97b7fd7c985b`
- Verdict: ok. 1 whole + 3 cut poses; stone posts with moss and flowers and loose straw around; cut progression clear
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A dense wall of dried straw-coloured rushes bound with grey cord, filling a gap in a stone wall. Row 2 (cut, 3 poses): The same rush wall cut by a hook: pose 1 the first bundles are sliced through with pale cut ends and loose straw, pose 2 a wide slice has cut a gap and the bound bundles hang loose, pose 3 the gap is open and the cut rushes lie flat on the ground. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `rush_wall_v2.png`

- File: `tools/source_art/rush_wall_v2.png` (accepted name after the cull: `tools/source_art/rush_wall.png`)
- Job id: `b29_rush_wall_v2` (job name `ww-b29-rush_wall-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f45-c5a0-7de0-874a-f786a6b9a133`
- Generated file name: `exec-229d4357-9ee3-4c6e-b066-2c678be91ec0.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f45-c5a0-7de0-874a-f786a6b9a133/exec-229d4357-9ee3-4c6e-b066-2c678be91ec0.png`
- SHA-256: `ad37a9b285db6cff0452c7e2f9f8ff345bd53bdb4a949f05555ea5bdee0fd069`
- Verdict: ok. 1 whole + 3 cut poses; the sheet adds stone posts, flowers and rocks around the rushes (kept, within the description)
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A dense wall of dried straw-coloured rushes bound with grey cord, filling a gap in a stone wall. Row 2 (cut, 3 poses): The same rush wall cut by a hook: pose 1 the first bundles are sliced through with pale cut ends and loose straw, pose 2 a wide slice has cut a gap and the bound bundles hang loose, pose 3 the gap is open and the cut rushes lie flat on the ground. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `rush_wall_v3.png`

- File: `tools/source_art/rush_wall_v3.png` (accepted name after the cull: `tools/source_art/rush_wall.png`)
- Job id: `b29_rush_wall_v3` (job name `ww-b29-rush_wall-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f45-cd4b-71e0-a370-b9d2914f9bec`
- Generated file name: `exec-cb52e093-59e9-4b17-95d9-63ade5856c89.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f45-cd4b-71e0-a370-b9d2914f9bec/exec-cb52e093-59e9-4b17-95d9-63ade5856c89.png`
- SHA-256: `57228b7f6bb4bb960ef30b1f75848b7ecb402259d416a218bf0436ff74ced33b`
- Verdict: ok. 1 whole + 3 cut poses; all poses separated
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A dense wall of dried straw-coloured rushes bound with grey cord, filling a gap in a stone wall. Row 2 (cut, 3 poses): The same rush wall cut by a hook: pose 1 the first bundles are sliced through with pale cut ends and loose straw, pose 2 a wide slice has cut a gap and the bound bundles hang loose, pose 3 the gap is open and the cut rushes lie flat on the ground. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `moss_wall_v1.png`

- File: `tools/source_art/moss_wall_v1.png` (accepted name after the cull: `tools/source_art/moss_wall.png`)
- Job id: `b29_moss_wall_v1` (job name `ww-b29-moss_wall-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f47-3fa9-7291-8eee-c6a448b790c3`
- Generated file name: `exec-b404c7eb-1128-4ca6-8b1b-67adcac8a498.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f47-3fa9-7291-8eee-c6a448b790c3/exec-b404c7eb-1128-4ca6-8b1b-67adcac8a498.png`
- SHA-256: `7569f3420c958c6161c87d13731401476e45b0270c268d49bff271c7edcc35c8`
- Verdict: ok. 1 whole + 3 cut poses; the curtain parts progressively in the cut poses; bottom poses large and close to the edges, not cropped
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A thick curtain of wet green moss hanging over a stone recess, dark roots at the top. Row 2 (cut, 3 poses): The same moss curtain cut by a hook: pose 1 a few strands of moss are sliced with pale cut roots showing, pose 2 a wide slice has cut a gap through the curtain and the moss hangs in torn strips, pose 3 the gap is open and the cut moss lies in clumps. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `moss_wall_v2.png`

- File: `tools/source_art/moss_wall_v2.png` (accepted name after the cull: `tools/source_art/moss_wall.png`)
- Job id: `b29_moss_wall_v2` (job name `ww-b29-moss_wall-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f47-418b-7892-97e7-ed897a34c68a`
- Generated file name: `exec-cf1630a8-0c46-47e2-bfb2-cdb054335c1c.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f47-418b-7892-97e7-ed897a34c68a/exec-cf1630a8-0c46-47e2-bfb2-cdb054335c1c.png`
- SHA-256: `70e1acc86f5436fee570836dfbb19280443ab683963b91a37d31b6f96b4e3e34`
- Verdict: ok. 1 whole + 3 cut poses, clean
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A thick curtain of wet green moss hanging over a stone recess, dark roots at the top. Row 2 (cut, 3 poses): The same moss curtain cut by a hook: pose 1 a few strands of moss are sliced with pale cut roots showing, pose 2 a wide slice has cut a gap through the curtain and the moss hangs in torn strips, pose 3 the gap is open and the cut moss lies in clumps. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `moss_wall_v3.png`

- File: `tools/source_art/moss_wall_v3.png` (accepted name after the cull: `tools/source_art/moss_wall.png`)
- Job id: `b29_moss_wall_v3` (job name `ww-b29-moss_wall-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f47-4996-73c2-83e9-5a824435da4e`
- Generated file name: `exec-1e5e254f-1bdd-4be3-8d3c-6cf1720cdb41.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f47-4996-73c2-83e9-5a824435da4e/exec-1e5e254f-1bdd-4be3-8d3c-6cf1720cdb41.png`
- SHA-256: `79d878d0a3457e34f05706b9fcfb5b4482b54066a1e921cb960d753289642d90`
- Verdict: ok. 1 whole + 3 cut poses; moss is bright yellow-green rather than wet dusk green (kept)
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A thick curtain of wet green moss hanging over a stone recess, dark roots at the top. Row 2 (cut, 3 poses): The same moss curtain cut by a hook: pose 1 a few strands of moss are sliced with pale cut roots showing, pose 2 a wide slice has cut a gap through the curtain and the moss hangs in torn strips, pose 3 the gap is open and the cut moss lies in clumps. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `dry_vine_screen_v1.png`

- File: `tools/source_art/dry_vine_screen_v1.png` (accepted name after the cull: `tools/source_art/dry_vine_screen.png`)
- Job id: `b29_dry_vine_screen_v1` (job name `ww-b29-dry_vine_screen-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f47-5184-7551-837b-0a323835b850`
- Generated file name: `exec-d2fef4bb-d4ab-4a25-9958-a44bcd13d9ac.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f47-5184-7551-837b-0a323835b850/exec-d2fef4bb-d4ab-4a25-9958-a44bcd13d9ac.png`
- SHA-256: `a075c4045130fe8c72cc0f40bcdd631d7ffee730bade359bfda7c473b5e5e2fa`
- Verdict: weak. each pose is two posts with vines between them (the sheet adds posts); the gap finder would see six blobs for three cut poses (count mismatch); prompt wording caused the posts
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A tangle of dry brown vines hung across a gap like a screen, brittle leaves gone. Row 2 (cut, 3 poses): The same vine screen cut by a hook: pose 1 the first vines are sliced through with brittle ends, pose 2 a wide slice has cut a gap and the dry vines hang loose, pose 3 the gap is open and the cut vines lie in a heap. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `dry_vine_screen_v2.png`

- File: `tools/source_art/dry_vine_screen_v2.png` (accepted name after the cull: `tools/source_art/dry_vine_screen.png`)
- Job id: `b29_dry_vine_screen_v2` (job name `ww-b29-dry_vine_screen-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f47-579a-7890-bc91-dd433f43171f`
- Generated file name: `exec-11f8e7fa-67af-44b3-93a8-40425132b0d2.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f47-579a-7890-bc91-dd433f43171f/exec-11f8e7fa-67af-44b3-93a8-40425132b0d2.png`
- SHA-256: `b8f238706acdd45e9107db02bbcb6b6ba04b162c0d3ee3a15cffb9bc15c57b3d`
- Verdict: weak. same as v1: two stone posts with vines between them in every pose; the cut poses split into six blobs by the gap finder
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A tangle of dry brown vines hung across a gap like a screen, brittle leaves gone. Row 2 (cut, 3 poses): The same vine screen cut by a hook: pose 1 the first vines are sliced through with brittle ends, pose 2 a wide slice has cut a gap and the dry vines hang loose, pose 3 the gap is open and the cut vines lie in a heap. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `dry_vine_screen_v3.png`

- File: `tools/source_art/dry_vine_screen_v3.png` (accepted name after the cull: `tools/source_art/dry_vine_screen.png`)
- Job id: `b29_dry_vine_screen_v3` (job name `ww-b29-dry_vine_screen-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f47-678e-7570-8244-b93a24534e08`
- Generated file name: `exec-a117aafd-16dd-4190-913e-f9f1eba26347.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f47-678e-7570-8244-b93a24534e08/exec-a117aafd-16dd-4190-913e-f9f1eba26347.png`
- SHA-256: `83b152485f086cebb1af96c5f5df189a327da8f4b2953082a9019ec2096600df`
- Verdict: weak. same as v1: two posts with vines between them in every pose; the cut poses split into six blobs by the gap finder
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A tangle of dry brown vines hung across a gap like a screen, brittle leaves gone. Row 2 (cut, 3 poses): The same vine screen cut by a hook: pose 1 the first vines are sliced through with brittle ends, pose 2 a wide slice has cut a gap and the dry vines hang loose, pose 3 the gap is open and the cut vines lie in a heap. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `bush_cluster_v1.png`

- File: `tools/source_art/bush_cluster_v1.png` (accepted name after the cull: `tools/source_art/bush_cluster.png`)
- Job id: `b29_bush_cluster_v1` (job name `ww-b29-bush_cluster-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f48-b9b5-70c3-96a2-35e00e4087f9`
- Generated file name: `exec-48c1028e-b061-44de-872c-b0e22d07d541.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f48-b9b5-70c3-96a2-35e00e4087f9/exec-48c1028e-b061-44de-872c-b0e22d07d541.png`
- SHA-256: `43b26bb663ad7f16aea9f71ebaa5364b2e8f2e2ab6071c4885b5f07fc5029a66`
- Verdict: weak. row 2 holds an uncut bush plus two cut poses, each cut pose shown as two halves: five blobs instead of three cut poses; the first row (whole) is fine
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A dense round dark-green bush with small pale blossoms, blocking a gap in a path. Row 2 (cut, 3 poses): The same bush cut by a hook: pose 1 a few branches are sliced through with pale cut wood showing, pose 2 a wide slice has cut a gap through the middle and the branches sag, pose 3 the gap is open and the cut branches lie to the side. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `bush_cluster_v2.png`

- File: `tools/source_art/bush_cluster_v2.png` (accepted name after the cull: `tools/source_art/bush_cluster.png`)
- Job id: `b29_bush_cluster_v2` (job name `ww-b29-bush_cluster-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f48-bed4-79f1-8f65-dc409d899d18`
- Generated file name: `exec-b1065ac1-3159-4334-980e-e76188968d27.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f48-bed4-79f1-8f65-dc409d899d18/exec-b1065ac1-3159-4334-980e-e76188968d27.png`
- SHA-256: `0a049ee821be88e5cfeb87f53e4cfe7d16932cc8e4d9dc176448dd2e701808e0`
- Verdict: weak. same layout as v1: an uncut bush in the cut row and two cut poses each made of two halves (five blobs)
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A dense round dark-green bush with small pale blossoms, blocking a gap in a path. Row 2 (cut, 3 poses): The same bush cut by a hook: pose 1 a few branches are sliced through with pale cut wood showing, pose 2 a wide slice has cut a gap through the middle and the branches sag, pose 3 the gap is open and the cut branches lie to the side. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `bush_cluster_v3.png`

- File: `tools/source_art/bush_cluster_v3.png` (accepted name after the cull: `tools/source_art/bush_cluster.png`)
- Job id: `b29_bush_cluster_v3` (job name `ww-b29-bush_cluster-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f48-c965-7223-ad1d-c51efff86a12`
- Generated file name: `exec-32a1d69d-213b-471a-a574-40d0bb1d31fa.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f48-c965-7223-ad1d-c51efff86a12/exec-32a1d69d-213b-471a-a574-40d0bb1d31fa.png`
- SHA-256: `985a128d6d26c2dc26d9a4883b66adcbbaa7953d3002978efa888fa8666d2399`
- Verdict: weak. same layout as v1: the cut row starts with an uncut bush, cut poses are split into halves
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A dense round dark-green bush with small pale blossoms, blocking a gap in a path. Row 2 (cut, 3 poses): The same bush cut by a hook: pose 1 a few branches are sliced through with pale cut wood showing, pose 2 a wide slice has cut a gap through the middle and the branches sag, pose 3 the gap is open and the cut branches lie to the side. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `brittle_rocks_v1.png`

- File: `tools/source_art/brittle_rocks_v1.png` (accepted name after the cull: `tools/source_art/brittle_rocks.png`)
- Job id: `b29_brittle_rocks_v1` (job name `ww-b29-brittle_rocks-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f48-ce4e-7f50-b311-9788cd40c57e`
- Generated file name: `exec-2f2e8b66-ebf0-4cf3-bf39-b220975a1e33.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f48-ce4e-7f50-b311-9788cd40c57e/exec-2f2e8b66-ebf0-4cf3-bf39-b220975a1e33.png`
- SHA-256: `d365f967a0e61032d1f2a129e11d79ab1e4fc924ed1110f56ceb06fd6cf20f6d`
- Verdict: ok. whole heap and blasted rubble pose, same scale; foliage and flowers cover the heaps more than the brief (bare brittle rocks) asks
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A heap of grey brittle rocks stacked against a rock wall, a few cracks in them. Row 2 (blasted, 1 pose): The same heap blasted apart: broken rubble scattered, the top rocks split into pieces and a dusty grey patch of loose stones. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `brittle_rocks_v2.png`

- File: `tools/source_art/brittle_rocks_v2.png` (accepted name after the cull: `tools/source_art/brittle_rocks.png`)
- Job id: `b29_brittle_rocks_v2` (job name `ww-b29-brittle_rocks-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f48-e32a-7651-9037-f2820340f3d6`
- Generated file name: `exec-45fac434-92ac-4597-95bb-7bc078ed4b80.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f48-e32a-7651-9037-f2820340f3d6/exec-45fac434-92ac-4597-95bb-7bc078ed4b80.png`
- SHA-256: `5f516e27fbbf849ddd5ee89aab3dd51e260097e2f5723d0857d54b0a7e752f27`
- Verdict: ok. whole heap and blasted pose with rubble; greenery covers both poses; the blasted pose keeps a rock centre
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A heap of grey brittle rocks stacked against a rock wall, a few cracks in them. Row 2 (blasted, 1 pose): The same heap blasted apart: broken rubble scattered, the top rocks split into pieces and a dusty grey patch of loose stones. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `brittle_rocks_v3.png`

- File: `tools/source_art/brittle_rocks_v3.png` (accepted name after the cull: `tools/source_art/brittle_rocks.png`)
- Job id: `b29_brittle_rocks_v3` (job name `ww-b29-brittle_rocks-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f49-1fc1-7711-b028-92ad606d5ba1`
- Generated file name: `exec-d3e0e8e4-f327-4f0e-bc94-d481308ddc5a.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f49-1fc1-7711-b028-92ad606d5ba1/exec-d3e0e8e4-f327-4f0e-bc94-d481308ddc5a.png`
- SHA-256: `d344e40ab70378a6844b1afb4a7c27b596f0f54d573d68d6b09811cafcd093da`
- Verdict: ok. whole heap and blasted pose; leafy growth and flowers on both poses, the blasted pose still has several large intact rocks
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (whole, 1 pose): A heap of grey brittle rocks stacked against a rock wall, a few cracks in them. Row 2 (blasted, 1 pose): The same heap blasted apart: broken rubble scattered, the top rocks split into pieces and a dusty grey patch of loose stones. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

