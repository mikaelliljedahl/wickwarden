# Batch 31 generation log (producer d)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job). Each job copied its PNG unchanged to `tools/source_art/`; the copy was checked by SHA-256 against the PNG in the job's own `~/.codex/generated_images/<session>/` folder, and hashes are unique across `tools/source_art/`. Each image was viewed as a three-variant montage. One prompt and one attempt per image; no image was regenerated.

## Summary (one line per image)

- `pocket_stairs_down_v1.png`: ok - closed slab and slab slid aside over steps going down; moss and foliage on the stone
- `pocket_stairs_down_v2.png`: ok - closed slab and open stairs; clean
- `pocket_stairs_down_v3.png`: ok - closed slab and open stairs; clean
- `pocket_plain_door_v1.png`: weak - too ornate for a plain door: iron bands, a padlock and an arched stone frame, plus a hanging lantern in the open pose
- `pocket_plain_door_v2.png`: weak - iron bands, lock and an arched stone frame: the brief asks for a plain door with no decoration
- `pocket_plain_door_v3.png`: weak - iron bands and a padlock on an arched stone frame: too ornate for a plain door; job was still running at the check, file hash matched
- `shop_counter_v1.png`: ok - one pose: counter with shelf of jars, two brass pedestals and a hanging lantern; clean
- `shop_counter_v2.png`: ok - one pose: counter, shelf, pedestals, lantern; clean
- `shop_counter_v3.png`: ok - one pose: counter, shelf, pedestals, lantern; clean
- `ward_plate_v1.png`: ok - idle and three lit poses, glow builds up; lantern emblem on the stone, no text; job still running at the check, file hash matched
- `ward_plate_v2.png`: ok - idle and three lit poses; job reports a slightly banded magenta background (the cut tool measures the real key)
- `ward_plate_v3.png`: ok - idle and three lit poses; job still running at the check, file hash matched
- `street_lamp_v1.png`: ok - unlit pose and three lit poses with the flame flickering; ivy on the post; job still running at the check, file hash matched
- `street_lamp_v2.png`: ok - unlit and three lit poses; vines, flowers and a rocky base are prominent (kept)
- `street_lamp_v3.png`: ok - unlit and three lit poses (job did not assess defects; checked on the montage)
- `wall_torch_v1.png`: ok - four burn poses in one row, flames vary in height and lean
- `wall_torch_v2.png`: ok - four burn poses in one row; clean
- `wall_torch_v3.png`: ok - four burn poses in one row; job still running at the check, file hash matched

## Details

## `pocket_stairs_down_v1.png`

- File: `tools/source_art/pocket_stairs_down_v1.png` (accepted name after the cull: `tools/source_art/pocket_stairs_down.png`)
- Job id: `b31_pocket_stairs_down_v1` (job name `ww-b31-pocket_stairs_down-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4e-82f8-7873-a2c4-625faef89f47`
- Generated file name: `exec-48ca179a-9b06-4f1a-ab56-fae09fa30106.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4e-82f8-7873-a2c4-625faef89f47/exec-48ca179a-9b06-4f1a-ab56-fae09fa30106.png`
- SHA-256: `e84a8796fda1bae1c1fce06f932cfd1253adf411d3239183bbf9a2ce021456bc`
- Verdict: ok. closed slab and slab slid aside over steps going down; moss and foliage on the stone
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a flat stone slab set into the ground, shut; pose 2 the slab slid aside showing stone steps going down into warm dim light. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_stairs_down_v2.png`

- File: `tools/source_art/pocket_stairs_down_v2.png` (accepted name after the cull: `tools/source_art/pocket_stairs_down.png`)
- Job id: `b31_pocket_stairs_down_v2` (job name `ww-b31-pocket_stairs_down-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4e-898a-79f0-8fab-0e77e8da2c52`
- Generated file name: `exec-a3c8fa74-5eb9-495b-b9fe-ee2ac08be3b8.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4e-898a-79f0-8fab-0e77e8da2c52/exec-a3c8fa74-5eb9-495b-b9fe-ee2ac08be3b8.png`
- SHA-256: `816bd009f93c9729875e14100297cff6ea7174234ab1df4f7ecce5631d0d1700`
- Verdict: ok. closed slab and open stairs; clean
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a flat stone slab set into the ground, shut; pose 2 the slab slid aside showing stone steps going down into warm dim light. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_stairs_down_v3.png`

- File: `tools/source_art/pocket_stairs_down_v3.png` (accepted name after the cull: `tools/source_art/pocket_stairs_down.png`)
- Job id: `b31_pocket_stairs_down_v3` (job name `ww-b31-pocket_stairs_down-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4e-8fa3-7262-80b2-9b794f02c652`
- Generated file name: `exec-7572fee7-ad50-4b38-b795-6eed815df354.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4e-8fa3-7262-80b2-9b794f02c652/exec-7572fee7-ad50-4b38-b795-6eed815df354.png`
- SHA-256: `90bfd62458bd59055b15b17dd9548d9144bacfced90684ea156ea604e05d4326`
- Verdict: ok. closed slab and open stairs; clean
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a flat stone slab set into the ground, shut; pose 2 the slab slid aside showing stone steps going down into warm dim light. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_plain_door_v1.png`

- File: `tools/source_art/pocket_plain_door_v1.png` (accepted name after the cull: `tools/source_art/pocket_plain_door.png`)
- Job id: `b31_pocket_plain_door_v1` (job name `ww-b31-pocket_plain_door-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4e-9ae4-7083-90ac-3f00519fabb1`
- Generated file name: `exec-5fd91fcd-fc14-4d98-97f6-5e382b763339.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4e-9ae4-7083-90ac-3f00519fabb1/exec-5fd91fcd-fc14-4d98-97f6-5e382b763339.png`
- SHA-256: `5b6ed44075535504edd14d702727d306b3d3efcc29d409c4dc19d19b87bdfc2e`
- Verdict: weak. too ornate for a plain door: iron bands, a padlock and an arched stone frame, plus a hanging lantern in the open pose
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a plain wooden door in a plain stone frame with no decoration, shut; pose 2 the same door open with warm light beyond it. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_plain_door_v2.png`

- File: `tools/source_art/pocket_plain_door_v2.png` (accepted name after the cull: `tools/source_art/pocket_plain_door.png`)
- Job id: `b31_pocket_plain_door_v2` (job name `ww-b31-pocket_plain_door-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4e-ad7b-7301-aa81-113f310a92db`
- Generated file name: `exec-83183301-388c-4315-adf7-80b274bbd06e.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4e-ad7b-7301-aa81-113f310a92db/exec-83183301-388c-4315-adf7-80b274bbd06e.png`
- SHA-256: `e45ec3193778df6ae8c2206e9bac8fa9d47b90254a6780d638684049ee84c48b`
- Verdict: weak. iron bands, lock and an arched stone frame: the brief asks for a plain door with no decoration
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a plain wooden door in a plain stone frame with no decoration, shut; pose 2 the same door open with warm light beyond it. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `pocket_plain_door_v3.png`

- File: `tools/source_art/pocket_plain_door_v3.png` (accepted name after the cull: `tools/source_art/pocket_plain_door.png`)
- Job id: `b31_pocket_plain_door_v3` (job name `ww-b31-pocket_plain_door-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4e-a8eb-7c20-90b4-1186856bce84`
- Generated file name: `exec-d675d151-60f2-458e-8376-de8d93df20e8.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4e-a8eb-7c20-90b4-1186856bce84/exec-d675d151-60f2-458e-8376-de8d93df20e8.png`
- SHA-256: `e908cd1774b35c7dd28eeb8ececee7f4f821bc3551bd7c67bca881b4cfbf3f58`
- Verdict: weak. iron bands and a padlock on an arched stone frame: too ornate for a plain door; job was still running at the check, file hash matched
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 a plain wooden door in a plain stone frame with no decoration, shut; pose 2 the same door open with warm light beyond it. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `shop_counter_v1.png`

- File: `tools/source_art/shop_counter_v1.png` (accepted name after the cull: `tools/source_art/shop_counter.png`)
- Job id: `b31_shop_counter_v1` (job name `ww-b31-shop_counter-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4f-cc72-7761-b9f3-0022744cc3e8`
- Generated file name: `exec-f6ecee04-b191-4a0e-b7b4-bd5d7e827341.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4f-cc72-7761-b9f3-0022744cc3e8/exec-f6ecee04-b191-4a0e-b7b4-bd5d7e827341.png`
- SHA-256: `311bdb81d6034867d459056fb4ee56cf677bf59cb6ec12f36548b8e868c0ed55`
- Verdict: ok. one pose: counter with shelf of jars, two brass pedestals and a hanging lantern; clean
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 1 separate pose in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1, one counter: a shopkeeper's counter of old dark wood with a shelf of stoppered jars behind it and two small brass pedestals on its top, a lantern hanging above, no people. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `shop_counter_v2.png`

- File: `tools/source_art/shop_counter_v2.png` (accepted name after the cull: `tools/source_art/shop_counter.png`)
- Job id: `b31_shop_counter_v2` (job name `ww-b31-shop_counter-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4f-d199-7f10-a38b-63e2e0dbe17f`
- Generated file name: `exec-92ca7dd4-ae56-4393-a48c-1a7f16745a2b.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4f-d199-7f10-a38b-63e2e0dbe17f/exec-92ca7dd4-ae56-4393-a48c-1a7f16745a2b.png`
- SHA-256: `567f52aa90d2e1be648d7bfdd8fe168247971710d1c0751f7b9a9e28e9216dcd`
- Verdict: ok. one pose: counter, shelf, pedestals, lantern; clean
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 1 separate pose in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1, one counter: a shopkeeper's counter of old dark wood with a shelf of stoppered jars behind it and two small brass pedestals on its top, a lantern hanging above, no people. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `shop_counter_v3.png`

- File: `tools/source_art/shop_counter_v3.png` (accepted name after the cull: `tools/source_art/shop_counter.png`)
- Job id: `b31_shop_counter_v3` (job name `ww-b31-shop_counter-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4f-d817-73f2-a49d-a903092d7125`
- Generated file name: `exec-13b505ea-a8f2-428a-aaf7-7563e551dfc6.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4f-d817-73f2-a49d-a903092d7125/exec-13b505ea-a8f2-428a-aaf7-7563e551dfc6.png`
- SHA-256: `e23f57fc01ce613a323d6244d1af1ccb280e2d98bedd766f9be2b172c5f61bb4`
- Verdict: ok. one pose: counter, shelf, pedestals, lantern; clean
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 1 separate pose in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1, one counter: a shopkeeper's counter of old dark wood with a shelf of stoppered jars behind it and two small brass pedestals on its top, a lantern hanging above, no people. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `ward_plate_v1.png`

- File: `tools/source_art/ward_plate_v1.png` (accepted name after the cull: `tools/source_art/ward_plate.png`)
- Job id: `b31_ward_plate_v1` (job name `ww-b31-ward_plate-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4f-e10d-7e32-ab2c-71624c02446e`
- Generated file name: `exec-a302ffbf-6447-4a3c-9240-2d59d22b2b8a.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4f-e10d-7e32-ab2c-71624c02446e/exec-a302ffbf-6447-4a3c-9240-2d59d22b2b8a.png`
- SHA-256: `831b72bbe6f94429bb2c781bf696626b33e712b91617b9ded4ec3316e954a0b7`
- Verdict: ok. idle and three lit poses, glow builds up; lantern emblem on the stone, no text; job still running at the check, file hash matched
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (idle, 1 pose): A round stone pad set flat in the ground with a faint carved lantern ring, dull and unlit. Row 2 (lit, 3 poses): The same stone pad with its carved ring lit: pose 1 a faint amber glow, pose 2 a brighter glow, pose 3 the full bright ring with warm light spilling over the stone. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `ward_plate_v2.png`

- File: `tools/source_art/ward_plate_v2.png` (accepted name after the cull: `tools/source_art/ward_plate.png`)
- Job id: `b31_ward_plate_v2` (job name `ww-b31-ward_plate-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4f-e7be-77d0-a388-143ea6d9fc51`
- Generated file name: `exec-816ef55d-488c-4b29-bec2-3f00cf31f82a.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4f-e7be-77d0-a388-143ea6d9fc51/exec-816ef55d-488c-4b29-bec2-3f00cf31f82a.png`
- SHA-256: `904db50a6a319cd6262cae783d01f0709dd0c67fbe67c584e482dda2c1d64d96`
- Verdict: ok. idle and three lit poses; job reports a slightly banded magenta background (the cut tool measures the real key)
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (idle, 1 pose): A round stone pad set flat in the ground with a faint carved lantern ring, dull and unlit. Row 2 (lit, 3 poses): The same stone pad with its carved ring lit: pose 1 a faint amber glow, pose 2 a brighter glow, pose 3 the full bright ring with warm light spilling over the stone. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `ward_plate_v3.png`

- File: `tools/source_art/ward_plate_v3.png` (accepted name after the cull: `tools/source_art/ward_plate.png`)
- Job id: `b31_ward_plate_v3` (job name `ww-b31-ward_plate-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f4f-efc8-7ef1-a9fb-55ef6b506c9a`
- Generated file name: `exec-8503c2c7-e084-447f-8206-afd7b9d3ff5f.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f4f-efc8-7ef1-a9fb-55ef6b506c9a/exec-8503c2c7-e084-447f-8206-afd7b9d3ff5f.png`
- SHA-256: `c8f4da9b4e98b368ffc3ceab472719bddbafd64ed03ef4f586e3e06fd3e56c93`
- Verdict: ok. idle and three lit poses; job still running at the check, file hash matched
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (idle, 1 pose): A round stone pad set flat in the ground with a faint carved lantern ring, dull and unlit. Row 2 (lit, 3 poses): The same stone pad with its carved ring lit: pose 1 a faint amber glow, pose 2 a brighter glow, pose 3 the full bright ring with warm light spilling over the stone. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `street_lamp_v1.png`

- File: `tools/source_art/street_lamp_v1.png` (accepted name after the cull: `tools/source_art/street_lamp.png`)
- Job id: `b31_street_lamp_v1` (job name `ww-b31-street_lamp-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f51-0100-7551-bd2c-b32aa545e1ee`
- Generated file name: `exec-157de674-a0f5-40c5-9b7e-beccdb06a636.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f51-0100-7551-bd2c-b32aa545e1ee/exec-157de674-a0f5-40c5-9b7e-beccdb06a636.png`
- SHA-256: `572e0a60e2d06b37a54989b1d577199d7c789b3d3cfe58c3218309f3c3f3be84`
- Verdict: ok. unlit pose and three lit poses with the flame flickering; ivy on the post; job still running at the check, file hash matched
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (unlit, 1 pose): A tall iron street lamp post with a glass lantern on top, dark and unlit. Row 2 (lit, 3 poses): The same lamp lit, three frames of the flame flickering in the glass with slightly different flame heights and a warm glow on the ground. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `street_lamp_v2.png`

- File: `tools/source_art/street_lamp_v2.png` (accepted name after the cull: `tools/source_art/street_lamp.png`)
- Job id: `b31_street_lamp_v2` (job name `ww-b31-street_lamp-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f51-05a9-77b1-aa82-a582bc446661`
- Generated file name: `exec-6434a093-85ff-4933-a364-187f51a23309.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f51-05a9-77b1-aa82-a582bc446661/exec-6434a093-85ff-4933-a364-187f51a23309.png`
- SHA-256: `a7460ce14e811f0ac00006e12bba5526b1052d8ebef5708ec488d54179bb34ba`
- Verdict: ok. unlit and three lit poses; vines, flowers and a rocky base are prominent (kept)
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (unlit, 1 pose): A tall iron street lamp post with a glass lantern on top, dark and unlit. Row 2 (lit, 3 poses): The same lamp lit, three frames of the flame flickering in the glass with slightly different flame heights and a warm glow on the ground. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `street_lamp_v3.png`

- File: `tools/source_art/street_lamp_v3.png` (accepted name after the cull: `tools/source_art/street_lamp.png`)
- Job id: `b31_street_lamp_v3` (job name `ww-b31-street_lamp-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_props.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f51-0d00-7ce0-9bee-233c62f2ceb7`
- Generated file name: `exec-e8a40712-0a92-4597-850f-4507d2a1df7b.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f51-0d00-7ce0-9bee-233c62f2ceb7/exec-e8a40712-0a92-4597-850f-4507d2a1df7b.png`
- SHA-256: `f6c04683b1cc6589190b8f84478c14c2a1edc57aa57a3e5576a8e0f7eeb94846`
- Verdict: ok. unlit and three lit poses (job did not assess defects; checked on the montage)
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 2 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (unlit, 1 pose): A tall iron street lamp post with a glass lantern on top, dark and unlit. Row 2 (lit, 3 poses): The same lamp lit, three frames of the flame flickering in the glass with slightly different flame heights and a warm glow on the ground. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `wall_torch_v1.png`

- File: `tools/source_art/wall_torch_v1.png` (accepted name after the cull: `tools/source_art/wall_torch.png`)
- Job id: `b31_wall_torch_v1` (job name `ww-b31-wall_torch-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f51-1484-7952-b7e3-18a541878dd2`
- Generated file name: `exec-9ff36a2e-22b9-40df-93bc-447674eef37f.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f51-1484-7952-b7e3-18a541878dd2/exec-9ff36a2e-22b9-40df-93bc-447674eef37f.png`
- SHA-256: `315f9963adab69cb851dedd5aa8659dfd2b754275cfbd0ad863998b6b2718aaf`
- Verdict: ok. four burn poses in one row, flames vary in height and lean
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Each of the 4 poses: a wall bracket holding a wooden torch with a flame, four frames of the flame flickering: pose 1 tall, pose 2 shorter and leaning, pose 3 small, pose 4 tall again, each with warm light on the stone. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `wall_torch_v2.png`

- File: `tools/source_art/wall_torch_v2.png` (accepted name after the cull: `tools/source_art/wall_torch.png`)
- Job id: `b31_wall_torch_v2` (job name `ww-b31-wall_torch-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f51-25a1-7231-8f02-a827a5beb2fd`
- Generated file name: `exec-ff8fe6ff-b217-4399-966a-c1874bed1f42.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f51-25a1-7231-8f02-a827a5beb2fd/exec-ff8fe6ff-b217-4399-966a-c1874bed1f42.png`
- SHA-256: `3acd4778745f9f7ac297644dc60b23357729d2b08d49f978931324e0cf154e79`
- Verdict: ok. four burn poses in one row; clean
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Each of the 4 poses: a wall bracket holding a wooden torch with a flame, four frames of the flame flickering: pose 1 tall, pose 2 shorter and leaning, pose 3 small, pose 4 tall again, each with warm light on the stone. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `wall_torch_v3.png`

- File: `tools/source_art/wall_torch_v3.png` (accepted name after the cull: `tools/source_art/wall_torch.png`)
- Job id: `b31_wall_torch_v3` (job name `ww-b31-wall_torch-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f51-2a9c-7e22-8a1b-abb0f851cf6f`
- Generated file name: `exec-3a85b000-00b4-4b01-9319-04d57424edca.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f51-2a9c-7e22-8a1b-abb0f851cf6f/exec-3a85b000-00b4-4b01-9319-04d57424edca.png`
- SHA-256: `3f2c2f5c9efa811e9fcaf10c1e70aa7ae70520b6b18a563d71956e9f44e20253`
- Verdict: ok. four burn poses in one row; job still running at the check, file hash matched
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Each of the 4 poses: a wall bracket holding a wooden torch with a flame, four frames of the flame flickering: pose 1 tall, pose 2 shorter and leaning, pose 3 small, pose 4 tall again, each with warm light on the stone. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

