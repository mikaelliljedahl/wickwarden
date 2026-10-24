# Batch 28 generation log (producer d)

Date: 2026-10-24. Codex jobs (AgentTeamForge, backend `codex`, model `cheapest`, one image per job). Each job copied its PNG unchanged to `tools/source_art/`; the copy was checked by SHA-256 against the PNG in the job's own `~/.codex/generated_images/<session>/` folder, and hashes are unique across `tools/source_art/`. Each image was viewed as a three-variant montage. One prompt and one attempt per image; no image was regenerated.

## Summary (one line per image)

- `sealed_seam_v1.png`: ok - 5 poses (1+3+1) in 3 rows, seam and open state readable; rock reads as a mossy boulder more than a flat cliff face; open state wider than asked
- `sealed_seam_v2.png`: weak - hidden pose drawn at a smaller scale than the revealed and open poses (scale not shared between rows)
- `sealed_seam_v3.png`: ok - 5 poses in 3 rows, same scale; extra foliage and small debris at the base of the rock
- `hook_tap_wall_v1.png`: ok - 4 poses (1+2+1): idle, two taps with dust and light ring, open; clean
- `hook_tap_wall_v2.png`: ok - 4 poses, all clear on the magenta, no contact
- `hook_tap_wall_v3.png`: ok - 4 poses, small loose rubble and plants at the base of the poses
- `grate_v1.png`: ok - 2 poses in one row: closed grate, grate with key visible; vegetation and stones spill beyond the square surround
- `grate_v2.png`: ok - 2 poses; job reports a second oversized key-shaped object beside the key in pose 2 (not checked at full size)
- `grate_v3.png`: ok - 2 poses; key visible behind the bars in pose 2
- `boss_door_v1.png`: ok - 1+4+1 in three rows, lock glow builds up in the four unlocking poses, same scale; session folder held two identical PNGs (the second is exec-f469b6b6-12d5-4a0f-b6b6-7d3b2e688d85.png)
- `boss_door_v2.png`: ok - 1+4+1, unlock steps readable; job reports a pink-purple background instead of pure magenta (the cut tool measures the real key)
- `boss_door_v3.png`: ok - 1+4+1; the worn-material variation is subtle
- `ninth_door_v1.png`: ok - 1+9+6+1 in four rows; sockets light one by one, door opens in six steps; row scale varies a little; the vault reads vine-covered
- `ninth_door_v2.png`: ok - four rows readable; poses in the socket-glow row are tightly spaced
- `ninth_door_v3.png`: ok - four rows readable; small reddish patch on the top of the arch in the sealed pose
- `wax_seal_v1.png`: weak - melting poses 4 and 5 read as dark red blood-like drips and smears on the wood (brief: no blood); each pose has a stone arch and foliage around the door
- `wax_seal_v2.png`: weak - melting poses read as dark red blood-like drips on the wood (brief: no blood); each pose shows the stone arch around the door
- `wax_seal_v3.png`: weak - melting poses read as dark red blood-like drips and smears on the wood (brief: no blood); each pose shows the stone arch and door

## Details

## `sealed_seam_v1.png`

- File: `tools/source_art/sealed_seam_v1.png` (accepted name after the cull: `tools/source_art/sealed_seam.png`)
- Job id: `b28_sealed_seam_v1` (job name `ww-b28-sealed_seam-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f3f-1c63-7b90-b759-8d2ffc2b5b7f`
- Generated file name: `exec-d1653dbc-6f1f-45b7-ac10-8950d155b69f.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f3f-1c63-7b90-b759-8d2ffc2b5b7f/exec-d1653dbc-6f1f-45b7-ac10-8950d155b69f.png`
- SHA-256: `4201831f4205672bd9aff8266664d8ebd5aac1cb0c904f3e35b26544c8d264c0`
- Verdict: ok. 5 poses (1+3+1) in 3 rows, seam and open state readable; rock reads as a mossy boulder more than a flat cliff face; open state wider than asked
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 5 separate poses in 3 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (hidden, 1 pose): A flat face of grey-brown cliff rock with only a fine dark seam running down its middle and a faint scuff of dust in the seam, no light. Row 2 (revealed, 3 poses): The same rock face: the seam is clearly visible in pose 1, its two edges part a little more in pose 2, and in pose 3 the stone is split with a warm amber glint of lamplight deep in the gap. Row 3 (open, 1 pose): The rock has parted into a narrow opening with a dark interior and cold dusk light beyond it. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `sealed_seam_v2.png`

- File: `tools/source_art/sealed_seam_v2.png` (accepted name after the cull: `tools/source_art/sealed_seam.png`)
- Job id: `b28_sealed_seam_v2` (job name `ww-b28-sealed_seam-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f3f-1cb8-7280-b936-37e6e7eb6153`
- Generated file name: `exec-27dcb698-581b-42a6-8b75-312ee85acf7d.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f3f-1cb8-7280-b936-37e6e7eb6153/exec-27dcb698-581b-42a6-8b75-312ee85acf7d.png`
- SHA-256: `73adb7f6eba88f13005dc2bbcf01ef94783cc6820a1769fd5c7ee3fdbd3787a0`
- Verdict: weak. hidden pose drawn at a smaller scale than the revealed and open poses (scale not shared between rows)
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 5 separate poses in 3 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (hidden, 1 pose): A flat face of grey-brown cliff rock with only a fine dark seam running down its middle and a faint scuff of dust in the seam, no light. Row 2 (revealed, 3 poses): The same rock face: the seam is clearly visible in pose 1, its two edges part a little more in pose 2, and in pose 3 the stone is split with a warm amber glint of lamplight deep in the gap. Row 3 (open, 1 pose): The rock has parted into a narrow opening with a dark interior and cold dusk light beyond it. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `sealed_seam_v3.png`

- File: `tools/source_art/sealed_seam_v3.png` (accepted name after the cull: `tools/source_art/sealed_seam.png`)
- Job id: `b28_sealed_seam_v3` (job name `ww-b28-sealed_seam-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f3f-1f6e-7042-8f58-bdb8f23944e6`
- Generated file name: `exec-1510d807-ea2e-475e-9beb-52b42d7860df.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f3f-1f6e-7042-8f58-bdb8f23944e6/exec-1510d807-ea2e-475e-9beb-52b42d7860df.png`
- SHA-256: `07c7f2630588b01e591e67e73bfc4ee81856616b4e2eee5c5a7111f3ff059563`
- Verdict: ok. 5 poses in 3 rows, same scale; extra foliage and small debris at the base of the rock
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 5 separate poses in 3 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (hidden, 1 pose): A flat face of grey-brown cliff rock with only a fine dark seam running down its middle and a faint scuff of dust in the seam, no light. Row 2 (revealed, 3 poses): The same rock face: the seam is clearly visible in pose 1, its two edges part a little more in pose 2, and in pose 3 the stone is split with a warm amber glint of lamplight deep in the gap. Row 3 (open, 1 pose): The rock has parted into a narrow opening with a dark interior and cold dusk light beyond it. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `hook_tap_wall_v1.png`

- File: `tools/source_art/hook_tap_wall_v1.png` (accepted name after the cull: `tools/source_art/hook_tap_wall.png`)
- Job id: `b28_hook_tap_wall_v1` (job name `ww-b28-hook_tap_wall-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f3f-264f-7691-ba62-a8ee51945ed2`
- Generated file name: `exec-05932c6a-c0f0-4c65-975b-3b62161134d3.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f3f-264f-7691-ba62-a8ee51945ed2/exec-05932c6a-c0f0-4c65-975b-3b62161134d3.png`
- SHA-256: `8e50b8e5ffd3a81b34f216372800c8b878369ca1ab2b18f9df2c6a85dcfe1b95`
- Verdict: ok. 4 poses (1+2+1): idle, two taps with dust and light ring, open; clean
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 3 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (idle, 1 pose): A section of old pale stone wall, solid and dull, plain square stones with dark joints. Row 2 (tapped, 2 poses): The same wall after a tap: pose 1 a thin puff of pale dust and a faint hairline crack in one stone; pose 2 the crack is wider, small chips of stone fall, and a faint ring of light crosses the face. Row 3 (open, 1 pose): The wall has swung open as a hollow panel, a dark opening behind it, the stone edges worn smooth. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `hook_tap_wall_v2.png`

- File: `tools/source_art/hook_tap_wall_v2.png` (accepted name after the cull: `tools/source_art/hook_tap_wall.png`)
- Job id: `b28_hook_tap_wall_v2` (job name `ww-b28-hook_tap_wall-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f3f-2e31-78a1-b331-2873b4f1c3f3`
- Generated file name: `exec-5e742b27-2cdc-477f-a1b1-95da813ddc25.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f3f-2e31-78a1-b331-2873b4f1c3f3/exec-5e742b27-2cdc-477f-a1b1-95da813ddc25.png`
- SHA-256: `128785742714d163d9c6fcf9ce94850018f83e85fa72c4d24632a89ea49e4198`
- Verdict: ok. 4 poses, all clear on the magenta, no contact
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 3 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (idle, 1 pose): A section of old pale stone wall, solid and dull, plain square stones with dark joints. Row 2 (tapped, 2 poses): The same wall after a tap: pose 1 a thin puff of pale dust and a faint hairline crack in one stone; pose 2 the crack is wider, small chips of stone fall, and a faint ring of light crosses the face. Row 3 (open, 1 pose): The wall has swung open as a hollow panel, a dark opening behind it, the stone edges worn smooth. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `hook_tap_wall_v3.png`

- File: `tools/source_art/hook_tap_wall_v3.png` (accepted name after the cull: `tools/source_art/hook_tap_wall.png`)
- Job id: `b28_hook_tap_wall_v3` (job name `ww-b28-hook_tap_wall-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f3f-33a5-7153-8d76-dfe073bc77c9`
- Generated file name: `exec-beb5f011-068e-4950-a6f0-7accb753b94b.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f3f-33a5-7153-8d76-dfe073bc77c9/exec-beb5f011-068e-4950-a6f0-7accb753b94b.png`
- SHA-256: `c66722e0520d74c3928b9d060165effa4b6cb2d9d651c297f87c4b456e185003`
- Verdict: ok. 4 poses, small loose rubble and plants at the base of the poses
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 4 separate poses in 3 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (idle, 1 pose): A section of old pale stone wall, solid and dull, plain square stones with dark joints. Row 2 (tapped, 2 poses): The same wall after a tap: pose 1 a thin puff of pale dust and a faint hairline crack in one stone; pose 2 the crack is wider, small chips of stone fall, and a faint ring of light crosses the face. Row 3 (open, 1 pose): The wall has swung open as a hollow panel, a dark opening behind it, the stone edges worn smooth. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `grate_v1.png`

- File: `tools/source_art/grate_v1.png` (accepted name after the cull: `tools/source_art/grate.png`)
- Job id: `b28_grate_v1` (job name `ww-b28-grate-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f40-bcf3-77c2-8987-55d2a5f69c6e`
- Generated file name: `exec-40257ae5-49cb-45f1-81b1-599bd8a4bb68.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f40-bcf3-77c2-8987-55d2a5f69c6e/exec-40257ae5-49cb-45f1-81b1-599bd8a4bb68.png`
- SHA-256: `a2173fc6b653ef5ce86eedcd69517272433120a5a3e059194a1772bdc1d3d0c8`
- Verdict: ok. 2 poses in one row: closed grate, grate with key visible; vegetation and stones spill beyond the square surround
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 an iron grate of dark rust-brown bars set in a square of stone over a small alcove, the alcove black behind the bars; pose 2 the same grate, and behind its bars a small brass key lies on the alcove floor, lit faintly by lamplight. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `grate_v2.png`

- File: `tools/source_art/grate_v2.png` (accepted name after the cull: `tools/source_art/grate.png`)
- Job id: `b28_grate_v2` (job name `ww-b28-grate-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f40-c568-7c62-b194-31cbc30ffcba`
- Generated file name: `exec-3a2aa7c8-7920-458a-8a07-0cc11aee6e1a.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f40-c568-7c62-b194-31cbc30ffcba/exec-3a2aa7c8-7920-458a-8a07-0cc11aee6e1a.png`
- SHA-256: `39dba09cdf7205cc735d10d3f3474e4126bdcfcf4d1601425613fe1f055a35fb`
- Verdict: ok. 2 poses; job reports a second oversized key-shaped object beside the key in pose 2 (not checked at full size)
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 an iron grate of dark rust-brown bars set in a square of stone over a small alcove, the alcove black behind the bars; pose 2 the same grate, and behind its bars a small brass key lies on the alcove floor, lit faintly by lamplight. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `grate_v3.png`

- File: `tools/source_art/grate_v3.png` (accepted name after the cull: `tools/source_art/grate.png`)
- Job id: `b28_grate_v3` (job name `ww-b28-grate-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f40-ccbd-78f2-bdea-7bcd255a8cca`
- Generated file name: `exec-80c25962-dece-4706-b939-4c3a1797901a.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f40-ccbd-78f2-bdea-7bcd255a8cca/exec-80c25962-dece-4706-b939-4c3a1797901a.png`
- SHA-256: `4977c483bab67103a0b83484b97930883a4060f5c4813feaea052a252de2629b`
- Verdict: ok. 2 poses; key visible behind the bars in pose 2
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 2 separate poses in one horizontal row on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line, wide equal gaps. Pose 1 an iron grate of dark rust-brown bars set in a square of stone over a small alcove, the alcove black behind the bars; pose 2 the same grate, and behind its bars a small brass key lies on the alcove floor, lit faintly by lamplight. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `boss_door_v1.png`

- File: `tools/source_art/boss_door_v1.png` (accepted name after the cull: `tools/source_art/boss_door.png`)
- Job id: `b28_boss_door_v1` (job name `ww-b28-boss_door-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f40-d2e1-71a1-8bff-20056179aa8f`
- Generated file name: `exec-b28_boss_door_v1.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f40-d2e1-71a1-8bff-20056179aa8f/exec-b28_boss_door_v1.png`
- SHA-256: `012cd583b5657a54ad77eca41095e7f3dc06102d372571a2044e693e2fb8f704`
- Verdict: ok. 1+4+1 in three rows, lock glow builds up in the four unlocking poses, same scale; session folder held two identical PNGs (the second is exec-f469b6b6-12d5-4a0f-b6b6-7d3b2e688d85.png)
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 6 separate poses in 3 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (closed, 1 pose): A massive dark oak door set in a heavy stone arch with iron bands, a round lantern-shaped lock plate of dull brass in the centre, the lock dark. Row 2 (unlocking, 4 poses): The same door in four steps: the lantern-shaped lock plate warms to a faint amber glow, then brighter, then the brass rings of the lock turn with light in their seams, then the bolt pulls back with light showing round the edges. Row 3 (open, 1 pose): The door swung fully open, warm lamp light spilling out of the doorway into the dark stone arch. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `boss_door_v2.png`

- File: `tools/source_art/boss_door_v2.png` (accepted name after the cull: `tools/source_art/boss_door.png`)
- Job id: `b28_boss_door_v2` (job name `ww-b28-boss_door-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f40-da93-79f0-995a-20c9307d594a`
- Generated file name: `exec-cd19d27b-e750-48d3-bae8-6fd60d5b7235.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f40-da93-79f0-995a-20c9307d594a/exec-cd19d27b-e750-48d3-bae8-6fd60d5b7235.png`
- SHA-256: `3bc89481851e0e9859923fab8508f90901f12c56383c48c1501bdee6e5e05373`
- Verdict: ok. 1+4+1, unlock steps readable; job reports a pink-purple background instead of pure magenta (the cut tool measures the real key)
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 6 separate poses in 3 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (closed, 1 pose): A massive dark oak door set in a heavy stone arch with iron bands, a round lantern-shaped lock plate of dull brass in the centre, the lock dark. Row 2 (unlocking, 4 poses): The same door in four steps: the lantern-shaped lock plate warms to a faint amber glow, then brighter, then the brass rings of the lock turn with light in their seams, then the bolt pulls back with light showing round the edges. Row 3 (open, 1 pose): The door swung fully open, warm lamp light spilling out of the doorway into the dark stone arch. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `boss_door_v3.png`

- File: `tools/source_art/boss_door_v3.png` (accepted name after the cull: `tools/source_art/boss_door.png`)
- Job id: `b28_boss_door_v3` (job name `ww-b28-boss_door-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f40-e300-75e0-8ace-ce15a7345248`
- Generated file name: `exec-324fbefa-f3a1-4f5d-8e9c-1360abc56b7e.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f40-e300-75e0-8ace-ce15a7345248/exec-324fbefa-f3a1-4f5d-8e9c-1360abc56b7e.png`
- SHA-256: `5fbc05d6af75f189891890dde7764050b681cdd7c956440b4b183401b9147d10`
- Verdict: ok. 1+4+1; the worn-material variation is subtle
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 6 separate poses in 3 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (closed, 1 pose): A massive dark oak door set in a heavy stone arch with iron bands, a round lantern-shaped lock plate of dull brass in the centre, the lock dark. Row 2 (unlocking, 4 poses): The same door in four steps: the lantern-shaped lock plate warms to a faint amber glow, then brighter, then the brass rings of the lock turn with light in their seams, then the bolt pulls back with light showing round the edges. Row 3 (open, 1 pose): The door swung fully open, warm lamp light spilling out of the doorway into the dark stone arch. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `ninth_door_v1.png`

- File: `tools/source_art/ninth_door_v1.png` (accepted name after the cull: `tools/source_art/ninth_door.png`)
- Job id: `b28_ninth_door_v1` (job name `ww-b28-ninth_door-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f42-6a81-7273-a304-251db0e6bcc6`
- Generated file name: `exec-cd519554-7077-4af8-9dff-d78314d56993.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f42-6a81-7273-a304-251db0e6bcc6/exec-cd519554-7077-4af8-9dff-d78314d56993.png`
- SHA-256: `b691807a4a61ed70bdbdfb0082408a27bd605fc29e4a3bb35c7838b6e9ab642a`
- Verdict: ok. 1+9+6+1 in four rows; sockets light one by one, door opens in six steps; row scale varies a little; the vault reads vine-covered
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 17 separate poses in 4 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (sealed, 1 pose): A huge round vault door of grey stone with iron bands, nine small empty sockets set in a ring around a dark central plate, the plate dim. Row 2 (socket glow, 9 poses): The same ring of nine sockets seen as glow only on a flat dark disc: pose 1 has one socket lit with a warm amber dot, each next pose lights one more socket, pose 9 has all nine sockets lit. Row 3 (opening, 6 poses): The vault door splitting open in six steps, the two halves sliding apart, a warm light growing in the crack, the last pose half open. Row 4 (open, 1 pose): The door fully open onto a dark passage with pale light at the far end. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `ninth_door_v2.png`

- File: `tools/source_art/ninth_door_v2.png` (accepted name after the cull: `tools/source_art/ninth_door.png`)
- Job id: `b28_ninth_door_v2` (job name `ww-b28-ninth_door-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f42-6d34-7360-9137-4795a6a4ab98`
- Generated file name: `exec-c166f85c-7984-4901-8db1-c7d58afbaa1d.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f42-6d34-7360-9137-4795a6a4ab98/exec-c166f85c-7984-4901-8db1-c7d58afbaa1d.png`
- SHA-256: `8ac161cc0e47c7ac414767d8144e74e83a8c9ee953d8b955cd1ffa0ee0e69451`
- Verdict: ok. four rows readable; poses in the socket-glow row are tightly spaced
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 17 separate poses in 4 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (sealed, 1 pose): A huge round vault door of grey stone with iron bands, nine small empty sockets set in a ring around a dark central plate, the plate dim. Row 2 (socket glow, 9 poses): The same ring of nine sockets seen as glow only on a flat dark disc: pose 1 has one socket lit with a warm amber dot, each next pose lights one more socket, pose 9 has all nine sockets lit. Row 3 (opening, 6 poses): The vault door splitting open in six steps, the two halves sliding apart, a warm light growing in the crack, the last pose half open. Row 4 (open, 1 pose): The door fully open onto a dark passage with pale light at the far end. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `ninth_door_v3.png`

- File: `tools/source_art/ninth_door_v3.png` (accepted name after the cull: `tools/source_art/ninth_door.png`)
- Job id: `b28_ninth_door_v3` (job name `ww-b28-ninth_door-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f42-745c-7ce3-aac7-3df4118f9fbb`
- Generated file name: `exec-3ed54351-80dc-4525-8d20-b1ca20087a37.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f42-745c-7ce3-aac7-3df4118f9fbb/exec-3ed54351-80dc-4525-8d20-b1ca20087a37.png`
- SHA-256: `cb1893757ef15e838173bee89f41b54c3abdebefbb48a36552f80e488d995d2c`
- Verdict: ok. four rows readable; small reddish patch on the top of the arch in the sealed pose
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 17 separate poses in 4 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (sealed, 1 pose): A huge round vault door of grey stone with iron bands, nine small empty sockets set in a ring around a dark central plate, the plate dim. Row 2 (socket glow, 9 poses): The same ring of nine sockets seen as glow only on a flat dark disc: pose 1 has one socket lit with a warm amber dot, each next pose lights one more socket, pose 9 has all nine sockets lit. Row 3 (opening, 6 poses): The vault door splitting open in six steps, the two halves sliding apart, a warm light growing in the crack, the last pose half open. Row 4 (open, 1 pose): The door fully open onto a dark passage with pale light at the far end. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `wax_seal_v1.png`

- File: `tools/source_art/wax_seal_v1.png` (accepted name after the cull: `tools/source_art/wax_seal.png`)
- Job id: `b28_wax_seal_v1` (job name `ww-b28-wax_seal-v1`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f42-7d47-7971-bc75-b8a8647bb728`
- Generated file name: `exec-9f11e503-33f6-4d51-8ae0-bd7a89f510ee.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f42-7d47-7971-bc75-b8a8647bb728/exec-9f11e503-33f6-4d51-8ae0-bd7a89f510ee.png`
- SHA-256: `8368176e8354bf410a08ff3a5c0170e4fbe260f1a84c7f3e2fe88c0f9650695a`
- Verdict: weak. melting poses 4 and 5 read as dark red blood-like drips and smears on the wood (brief: no blood); each pose has a stone arch and foliage around the door
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 7 separate poses in 3 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (closed, 1 pose): A round seal of dark red wax pressed over the joint of a wooden bar on a door, a plain lantern-shaped impression in it. Row 2 (melting, 5 poses): The same seal softening: pose 1 the edges slump slightly, pose 2 the wax sags and spreads, pose 3 it runs in thick drips, pose 4 most of it has melted into a glossy pool with drips, pose 5 only a dark wet smear is left. Row 3 (open, 1 pose): The wax gone, the wooden bar lifted clear, a warm glow in the gap behind it. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `wax_seal_v2.png`

- File: `tools/source_art/wax_seal_v2.png` (accepted name after the cull: `tools/source_art/wax_seal.png`)
- Job id: `b28_wax_seal_v2` (job name `ww-b28-wax_seal-v2`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f42-859d-7f40-b608-7e0609670448`
- Generated file name: `exec-6cf36f06-7e50-4c3e-b8ec-a9500a357704.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f42-859d-7f40-b608-7e0609670448/exec-6cf36f06-7e50-4c3e-b8ec-a9500a357704.png`
- SHA-256: `025baf3fb345a7fea38fe934c1e34cf06964cd5c424d40f07aa84259ffa68630`
- Verdict: weak. melting poses read as dark red blood-like drips on the wood (brief: no blood); each pose shows the stone arch around the door
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 7 separate poses in 3 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (closed, 1 pose): A round seal of dark red wax pressed over the joint of a wooden bar on a door, a plain lantern-shaped impression in it. Row 2 (melting, 5 poses): The same seal softening: pose 1 the edges slump slightly, pose 2 the wax sags and spreads, pose 3 it runs in thick drips, pose 4 most of it has melted into a glossy pool with drips, pose 5 only a dark wet smear is left. Row 3 (open, 1 pose): The wax gone, the wooden bar lifted clear, a warm glow in the gap behind it. Variation for this image: Slightly stronger warm light on the lit parts; more weathered surface detail and a few more chips and stains. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

## `wax_seal_v3.png`

- File: `tools/source_art/wax_seal_v3.png` (accepted name after the cull: `tools/source_art/wax_seal.png`)
- Job id: `b28_wax_seal_v3` (job name `ww-b28-wax_seal-v3`)
- Date: 2026-10-24
- Reference image: `tools/source_art/ow_structures.png`
- Attempts: 1
- Image size: 1536x1024 pixels (requested 1536x1024)
- Generation tool: Codex job, native image generation (model shown as `gpt-6-luna`, effort medium)
- Session ID: `01a16f42-e162-79b2-a8c9-c0a5ca77315d`
- Generated file name: `exec-37155fb9-0859-4e59-9d1d-99fbcc5247c2.png`
- Source path copied from: `/home/mikael/.codex/generated_images/01a16f42-e162-79b2-a8c9-c0a5ca77315d/exec-37155fb9-0859-4e59-9d1d-99fbcc5247c2.png`
- SHA-256: `3869cc73e4a395dfb82da838aacea6132365a2b28d5d454d1d1301f744b0c523`
- Verdict: weak. melting poses read as dark red blood-like drips and smears on the wood (brief: no blood); each pose shows the stone arch and door
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Exactly 7 separate poses in 3 horizontal rows on a 1536x1024 landscape canvas, one row per state, top row first. Every row is the same prop at the same scale, its base at the same height in every row, so the states can be compared. Row 1 (closed, 1 pose): A round seal of dark red wax pressed over the joint of a wooden bar on a door, a plain lantern-shaped impression in it. Row 2 (melting, 5 poses): The same seal softening: pose 1 the edges slump slightly, pose 2 the wax sags and spreads, pose 3 it runs in thick drips, pose 4 most of it has melted into a glossy pool with drips, pose 5 only a dark wet smear is left. Row 3 (open, 1 pose): The wax gone, the wooden bar lifted clear, a warm glow in the gap behind it. Variation for this image: Softer edges and more worn material texture; the shape kept simple and the same as the other variants. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

