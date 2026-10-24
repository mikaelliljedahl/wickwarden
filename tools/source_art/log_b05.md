# Batch 05 generation log (producer a)

Date: 2026-10-24. Native image generation through AgentTeamForge Codex jobs (model `cheapest`, tool gpt-image). One image per job, one prompt per entry of `tools/art_prompts/batch_05.md`, copied byte-identical from the job's own session folder under `~/.codex/generated_images/`. Reference images: `tamsin_walk.png` (design and scale) and `tamsin_walk_side.png` (accepted style). No image was edited or resized. Output size 1536x1024 for every image.

Checks: SHA-256 of all `tools/source_art/*.png` compared, no duplicate hashes. Each image viewed as a montage of its three variants. Verdicts: ok, or weak with the reason. Failed: none.

Session note: several jobs reported an output file name that is not in their own session folder, or two files in one folder. The rule used: take the file from the job's own session folder; where there are two, take the one that matches the job's reported output name, or else the later one. Each case is named below.

## tamsin_pot_place_side_v1.png

- File: `tools/source_art/tamsin_pot_place_side_v1.png`
- Job id: `b05_pot_place_side_v1`
- Verdict: ok
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f42-8249-7580-987d-a079218eaaeb`; output file: `exec-e7083352-9e3a-46f3-b90b-61a8e605b9ff.png`
- SHA-256: `2dfeea16c3aa79ca5ce5124a3f9822bb54d230ac01f082234879f2a9a30a947e`
- Source path copied from: `~/.codex/generated_images/01a16f42-8249-7580-987d-a079218eaaeb/exec-e7083352-9e3a-46f3-b90b-61a8e605b9ff.png`
- Defects not fixed: none listed
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, the hook and the lantern visible over her shoulder in this animation. She crouches and sets a squat round clay pot sealed with black pitch, with a short twisted fuse on top, onto the ground in front of her. Pose 1 crouch: knees bent low, the pot held in both hands at hip height close to the ground. Pose 2 set: the pot placed on the ground in front of her, both hands leaving it, the body bent forward and the fuse visible on top. The pot stays on the ground line; no lantern or hook changes. Variation for this image: standard composition, evenly spaced poses, clear silhouettes. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_pot_place_side_v2.png

- File: `tools/source_art/tamsin_pot_place_side_v2.png`
- Job id: `b05_pot_place_side_v2`
- Verdict: ok
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f42-843b-7860-8758-340c212f24b4`; output file: `exec-36fbc6a5-ca19-4718-8c89-63806dc09d01.png`
- SHA-256: `f7c4cfed93af92349fb57ee2059737f975cd6c7355701051b72acc49fe6e28f2`
- Source path copied from: `~/.codex/generated_images/01a16f42-843b-7860-8758-340c212f24b4/exec-36fbc6a5-ca19-4718-8c89-63806dc09d01.png`
- Defects not fixed: none listed
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, the hook and the lantern visible over her shoulder in this animation. She crouches and sets a squat round clay pot sealed with black pitch, with a short twisted fuse on top, onto the ground in front of her. Pose 1 crouch: knees bent low, the pot held in both hands at hip height close to the ground. Pose 2 set: the pot placed on the ground in front of her, both hands leaving it, the body bent forward and the fuse visible on top. The pot stays on the ground line; no lantern or hook changes. Variation for this image: slightly closer framing, more detail in the hands and the tool. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_pot_place_side_v3.png

- File: `tools/source_art/tamsin_pot_place_side_v3.png`
- Job id: `b05_pot_place_side_v3`
- Verdict: ok
- Note: The session holds two outputs, exec-25c6e123-9c3a-492d-9ee2-639477d034e2.png (20:54:15, not used) and exec-5da7cadf (20:54:48). The job reported exec-5da7cadf, the later file, and that one is taken.
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f42-858d-7852-a404-a14e3a1ff8f4`; output file: `exec-5da7cadf-5d4b-4a4f-a764-fd7a05e41c00.png`
- SHA-256: `f79c7e144301ab16d82e58d0724f86d92c13a2042c5dbfa2f2ea60b379021278`
- Source path copied from: `~/.codex/generated_images/01a16f42-858d-7852-a404-a14e3a1ff8f4/exec-5da7cadf-5d4b-4a4f-a764-fd7a05e41c00.png`
- Defects not fixed: none listed
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, the hook and the lantern visible over her shoulder in this animation. She crouches and sets a squat round clay pot sealed with black pitch, with a short twisted fuse on top, onto the ground in front of her. Pose 1 crouch: knees bent low, the pot held in both hands at hip height close to the ground. Pose 2 set: the pot placed on the ground in front of her, both hands leaving it, the body bent forward and the fuse visible on top. The pot stays on the ground line; no lantern or hook changes. Variation for this image: wider gaps between poses, more motion in the arms and coat. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_moth_throw_side_v1.png

- File: `tools/source_art/tamsin_moth_throw_side_v1.png`
- Job id: `b05_moth_throw_side_v1`
- Verdict: ok
- Note: The job reported that it could not name its file; the only file in its own folder is taken.
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f42-8c26-7583-97ba-82606b98f0be`; output file: `exec-bbcc4491-bcec-4ee6-a9ae-ebb29183af36.png`
- SHA-256: `ba7eb0c25d07886fc7242da2cee2ad29a85913bf97a997f645c705aeaf77a346`
- Source path copied from: `~/.codex/generated_images/01a16f42-8c26-7583-97ba-82606b98f0be/exec-bbcc4491-bcec-4ee6-a9ae-ebb29183af36.png`
- Defects not fixed: none listed
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, the hook and the lantern visible over her shoulder in this animation. She flicks a tether moth into the air: a small tame moth of pale lavender and cream with soft glowing amber wing edges, with a thin glowing brass thread trailing from it, held cupped in her right hand. Pose 1 flick: the arm swung back, the moth cupped in the hand at hip height. Pose 2 release: the arm thrust forward, the moth leaving the hand in front of her with the brass thread trailing. Pose 3 watch: the arm lowered, her head turned to follow the moth out of frame to the right, the moth itself not drawn in this pose. Variation for this image: standard composition, evenly spaced poses, clear silhouettes. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_moth_throw_side_v2.png

- File: `tools/source_art/tamsin_moth_throw_side_v2.png`
- Job id: `b05_moth_throw_side_v2`
- Verdict: ok
- Note: The job reported the generic name image.png; the only file in its own folder is taken.
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f43-36b6-7721-836f-64693acfbec8`; output file: `exec-16a2d73e-6f41-4ceb-9c99-760e0bfde8df.png`
- SHA-256: `50016cac3df6866b9c16c6e263cca42ee92ada7e5a49b6b7aa378899e0b24ef2`
- Source path copied from: `~/.codex/generated_images/01a16f43-36b6-7721-836f-64693acfbec8/exec-16a2d73e-6f41-4ceb-9c99-760e0bfde8df.png`
- Defects not fixed: none listed
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, the hook and the lantern visible over her shoulder in this animation. She flicks a tether moth into the air: a small tame moth of pale lavender and cream with soft glowing amber wing edges, with a thin glowing brass thread trailing from it, held cupped in her right hand. Pose 1 flick: the arm swung back, the moth cupped in the hand at hip height. Pose 2 release: the arm thrust forward, the moth leaving the hand in front of her with the brass thread trailing. Pose 3 watch: the arm lowered, her head turned to follow the moth out of frame to the right, the moth itself not drawn in this pose. Variation for this image: slightly closer framing, more detail in the hands and the tool. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_moth_throw_side_v3.png

- File: `tools/source_art/tamsin_moth_throw_side_v3.png`
- Job id: `b05_moth_throw_side_v3`
- Verdict: ok
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f43-37a6-7c92-92d5-bce06b81c052`; output file: `exec-542a4c72-5237-4850-a906-9fa31e98ef05.png`
- SHA-256: `10cb670c3bebd50fb98f90637d8bf5b1605ae02011cccfa6dc1f6e7d51188f90`
- Source path copied from: `~/.codex/generated_images/01a16f43-37a6-7c92-92d5-bce06b81c052/exec-542a4c72-5237-4850-a906-9fa31e98ef05.png`
- Defects not fixed: none listed
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, the hook and the lantern visible over her shoulder in this animation. She flicks a tether moth into the air: a small tame moth of pale lavender and cream with soft glowing amber wing edges, with a thin glowing brass thread trailing from it, held cupped in her right hand. Pose 1 flick: the arm swung back, the moth cupped in the hand at hip height. Pose 2 release: the arm thrust forward, the moth leaving the hand in front of her with the brass thread trailing. Pose 3 watch: the arm lowered, her head turned to follow the moth out of frame to the right, the moth itself not drawn in this pose. Variation for this image: wider gaps between poses, more motion in the arms and coat. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_item_get_down_v1.png

- File: `tools/source_art/tamsin_item_get_down_v1.png`
- Job id: `b05_item_get_down_v1`
- Verdict: weak (The object held overhead reads as a second lantern, not a small item.)
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f43-e23b-7161-8f0f-b1321851ea1e`; output file: `exec-b0a4ade4-6591-43ef-9358-4b7f3c565d27.png`
- SHA-256: `e4395182529977b13c90d0e8cf66f007072b9c349020bf613964829ff2fc68b8`
- Source path copied from: `~/.codex/generated_images/01a16f43-e23b-7161-8f0f-b1321851ea1e/exec-b0a4ade4-6591-43ef-9358-4b7f3c565d27.png`
- Defects not fixed: object reads as a lantern
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, mostly hidden behind her. Facing the viewer: her chest and face point at the viewer; her body is square to the camera, not turned to the right, and this is a front view, not a side profile. She lifts a small object with a warm glow up overhead in her right hand, the other arm at her side. Pose 1 raise: the object lifted to chest height in her right hand, her face looking up at it. Pose 2 hold overhead: the right arm raised straight above her head holding the object high, the body upright and proud. The two poses are one lift from the chest to the overhead hold. Variation for this image: standard composition, evenly spaced poses, clear silhouettes. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_item_get_down_v2.png

- File: `tools/source_art/tamsin_item_get_down_v2.png`
- Job id: `b05_item_get_down_v2`
- Verdict: weak (The object held overhead reads as a second lantern, not a small item. The job reported no file name; the only file in its own folder is taken.)
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f43-e1dc-7f13-94f5-99cb157870cf`; output file: `exec-7f8d6a18-ba09-4170-9270-8765a9164fc6.png`
- SHA-256: `b3570c55a942dbd7f4abf090c9f58205efb703c6b86efdf54513fbff3022d81c`
- Source path copied from: `~/.codex/generated_images/01a16f43-e1dc-7f13-94f5-99cb157870cf/exec-7f8d6a18-ba09-4170-9270-8765a9164fc6.png`
- Defects not fixed: object reads as a lantern
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, mostly hidden behind her. Facing the viewer: her chest and face point at the viewer; her body is square to the camera, not turned to the right, and this is a front view, not a side profile. She lifts a small object with a warm glow up overhead in her right hand, the other arm at her side. Pose 1 raise: the object lifted to chest height in her right hand, her face looking up at it. Pose 2 hold overhead: the right arm raised straight above her head holding the object high, the body upright and proud. The two poses are one lift from the chest to the overhead hold. Variation for this image: slightly closer framing, more detail in the hands and the tool. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_item_get_down_v3.png

- File: `tools/source_art/tamsin_item_get_down_v3.png`
- Job id: `b05_item_get_down_v3`
- Verdict: weak (The object held overhead reads as a second lantern, not a small item.)
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f43-e2b8-7801-8cb9-6b15c557aaf2`; output file: `exec-bd7d1263-102a-4497-9dd5-35116f254dfe.png`
- SHA-256: `b67646e6d6000bb402e24c368c3abc0b6f3597af281e68566bd1169fc3fc588d`
- Source path copied from: `~/.codex/generated_images/01a16f43-e2b8-7801-8cb9-6b15c557aaf2/exec-bd7d1263-102a-4497-9dd5-35116f254dfe.png`
- Defects not fixed: object reads as a lantern
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, mostly hidden behind her. Facing the viewer: her chest and face point at the viewer; her body is square to the camera, not turned to the right, and this is a front view, not a side profile. She lifts a small object with a warm glow up overhead in her right hand, the other arm at her side. Pose 1 raise: the object lifted to chest height in her right hand, her face looking up at it. Pose 2 hold overhead: the right arm raised straight above her head holding the object high, the body upright and proud. The two poses are one lift from the chest to the overhead hold. Variation for this image: wider gaps between poses, more motion in the arms and coat. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_flask_drink_down_v1.png

- File: `tools/source_art/tamsin_flask_drink_down_v1.png`
- Job id: `b05_flask_drink_down_v1`
- Verdict: ok
- Note: Front view, as the facing fix asks.
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f43-e28f-7263-baa9-0f8decdda214`; output file: `exec-aa814c6f-cae9-4000-9020-10ccb78d861c.png`
- SHA-256: `a0251feeb4acf148d4fa49ecc569ac7c61ce5530e39cb527172f5c22c0b04ef9`
- Source path copied from: `~/.codex/generated_images/01a16f43-e28f-7263-baa9-0f8decdda214/exec-aa814c6f-cae9-4000-9020-10ccb78d861c.png`
- Defects not fixed: none listed
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, mostly hidden behind her. Facing the viewer: her chest and face point at the viewer; her body is square to the camera, not turned to the right, and this is a front view, not a side profile. She drinks from a small round glass flask with a brass stopper, filled with warm amber liquid, held in her right hand. Pose 1 uncork: the flask held at the chest, the thumb pulling the brass stopper. Pose 2 drink: the flask raised to the mouth, the head tilted back a little. Pose 3 lower: the flask lowered again, the other hand resting at the belt, a small satisfied breath. Variation for this image: standard composition, evenly spaced poses, clear silhouettes. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_flask_drink_down_v2.png

- File: `tools/source_art/tamsin_flask_drink_down_v2.png`
- Job id: `b05_flask_drink_down_v2`
- Verdict: ok
- Note: Front view.
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f44-9b25-77f2-9eb0-2a843fe6ba24`; output file: `exec-60533fc7-f5d6-4902-b117-f7a2de99f07d.png`
- SHA-256: `2eef147515ee435352a1b2d521789b0a519a8ff9ce329177daa3e317d7b7e620`
- Source path copied from: `~/.codex/generated_images/01a16f44-9b25-77f2-9eb0-2a843fe6ba24/exec-60533fc7-f5d6-4902-b117-f7a2de99f07d.png`
- Defects not fixed: none listed
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, mostly hidden behind her. Facing the viewer: her chest and face point at the viewer; her body is square to the camera, not turned to the right, and this is a front view, not a side profile. She drinks from a small round glass flask with a brass stopper, filled with warm amber liquid, held in her right hand. Pose 1 uncork: the flask held at the chest, the thumb pulling the brass stopper. Pose 2 drink: the flask raised to the mouth, the head tilted back a little. Pose 3 lower: the flask lowered again, the other hand resting at the belt, a small satisfied breath. Variation for this image: slightly closer framing, more detail in the hands and the tool. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_flask_drink_down_v3.png

- File: `tools/source_art/tamsin_flask_drink_down_v3.png`
- Job id: `b05_flask_drink_down_v3`
- Verdict: ok
- Note: Front view. The session holds two outputs, exec-a84a2fc5-27f9-4499-b253-8dbe164bc653.png (20:56:30, not used) and exec-fbfa7c9b (20:57:16). The job reported exec-fbfa7c9b, the later file, and that one is taken.
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f44-ebeb-7771-b5a5-1e3b843f6d61`; output file: `exec-fbfa7c9b-3d1e-4c06-97d0-9966d8a5acda.png`
- SHA-256: `8642dbb96000e2dafaa9397613b163492f3c82d70f8bc8d844a1c6078786ae1d`
- Source path copied from: `~/.codex/generated_images/01a16f44-ebeb-7771-b5a5-1e3b843f6d61/exec-fbfa7c9b-3d1e-4c06-97d0-9966d8a5acda.png`
- Defects not fixed: none listed
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, mostly hidden behind her. Facing the viewer: her chest and face point at the viewer; her body is square to the camera, not turned to the right, and this is a front view, not a side profile. She drinks from a small round glass flask with a brass stopper, filled with warm amber liquid, held in her right hand. Pose 1 uncork: the flask held at the chest, the thumb pulling the brass stopper. Pose 2 drink: the flask raised to the mouth, the head tilted back a little. Pose 3 lower: the flask lowered again, the other hand resting at the belt, a small satisfied breath. Variation for this image: wider gaps between poses, more motion in the arms and coat. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_pit_fall_down_v1.png

- File: `tools/source_art/tamsin_pit_fall_down_v1.png`
- Job id: `b05_pit_fall_down_v1`
- Verdict: ok
- Note: The poses are airborne, not on the ground line; code can align them. The job reported exec-42577b15, which lies in pit_fall v2's folder; the only file in this job's own folder is taken.
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f44-ec7c-7de1-a27f-c52a554bde6d`; output file: `exec-fd81678d-3c1f-4443-86b3-d8e968df55e4.png`
- SHA-256: `6667b6c170cdcd6823c37b07b8c33c4ca5f08d6de3de9dcc00a6e71fcf65dfba`
- Source path copied from: `~/.codex/generated_images/01a16f44-ec7c-7de1-a27f-c52a554bde6d/exec-fd81678d-3c1f-4443-86b3-d8e968df55e4.png`
- Defects not fixed: none listed
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, mostly hidden behind her. Facing the viewer: her chest and face point at the viewer; her body is square to the camera, not turned to the right, and this is a front view, not a side profile. She tumbles downward into a pit, falling out of the frame, arms flailing, scarf and braid flying up, the body tilting and shrinking into the ground. Pose 1 start: the body tilting, one foot slipping off the ground line, the arms thrown out. Pose 2 tumble: the body rotated, the arms spread wide, the scarf whipping up. Pose 3 shrink: the body smaller and lower, sinking into the ground, the lamp light dim. Variation for this image: standard composition, evenly spaced poses, clear silhouettes. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_pit_fall_down_v2.png

- File: `tools/source_art/tamsin_pit_fall_down_v2.png`
- Job id: `b05_pit_fall_down_v2`
- Verdict: ok
- Note: The poses are airborne, not on the ground line; code can align them.
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f44-eee9-7f82-8634-c2883989a978`; output file: `exec-42577b15-b52f-4c2c-9a4d-af93f617653b.png`
- SHA-256: `6c0ea430d8151439d9e44a096966a69956f9275bfc4d076c3e4c8cf97889ae76`
- Source path copied from: `~/.codex/generated_images/01a16f44-eee9-7f82-8634-c2883989a978/exec-42577b15-b52f-4c2c-9a4d-af93f617653b.png`
- Defects not fixed: none listed
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, mostly hidden behind her. Facing the viewer: her chest and face point at the viewer; her body is square to the camera, not turned to the right, and this is a front view, not a side profile. She tumbles downward into a pit, falling out of the frame, arms flailing, scarf and braid flying up, the body tilting and shrinking into the ground. Pose 1 start: the body tilting, one foot slipping off the ground line, the arms thrown out. Pose 2 tumble: the body rotated, the arms spread wide, the scarf whipping up. Pose 3 shrink: the body smaller and lower, sinking into the ground, the lamp light dim. Variation for this image: slightly closer framing, more detail in the hands and the tool. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_pit_fall_down_v3.png

- File: `tools/source_art/tamsin_pit_fall_down_v3.png`
- Job id: `b05_pit_fall_down_v3`
- Verdict: ok
- Note: The poses are airborne, not on the ground line. The session holds two outputs, exec-e36a04f0-20e1-42eb-811e-48ee49e60bcd.png (20:56:36, not used) and exec-26bca2b5 (20:57:12). The job reported exec-26bca2b5, the later file, and that one is taken.
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f44-f5c6-7262-8a8a-4f8a9cc7516c`; output file: `exec-26bca2b5-2194-439e-b40e-fb4acd55fa69.png`
- SHA-256: `eee6856ba3d9097c06948d8e2cf26d70e15264c3e877535e8edb71187ee90e9c`
- Source path copied from: `~/.codex/generated_images/01a16f44-f5c6-7262-8a8a-4f8a9cc7516c/exec-26bca2b5-2194-439e-b40e-fb4acd55fa69.png`
- Defects not fixed: none listed
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, mostly hidden behind her. Facing the viewer: her chest and face point at the viewer; her body is square to the camera, not turned to the right, and this is a front view, not a side profile. She tumbles downward into a pit, falling out of the frame, arms flailing, scarf and braid flying up, the body tilting and shrinking into the ground. Pose 1 start: the body tilting, one foot slipping off the ground line, the arms thrown out. Pose 2 tumble: the body rotated, the arms spread wide, the scarf whipping up. Pose 3 shrink: the body smaller and lower, sinking into the ground, the lamp light dim. Variation for this image: wider gaps between poses, more motion in the arms and coat. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_death_down_v1.png

- File: `tools/source_art/tamsin_death_down_v1.png`
- Job id: `b05_death_down_v1`
- Verdict: ok
- Note: The session holds two outputs, exec-15e9bde6-67a7-4324-959f-324a455b3517.png (20:56:58, not used) and exec-c59f3e30 (20:57:34). The job reported exec-c59f3e30, the later file, and that one is taken.
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f45-11f1-7551-a7fb-5371e83e62f8`; output file: `exec-c59f3e30-dc57-4ded-9786-67e5bafcde02.png`
- SHA-256: `4abf7af1ceeebd398d1ce4acf4e5716be06edf329426d2c349f2b62ccfa3fedd`
- Source path copied from: `~/.codex/generated_images/01a16f45-11f1-7551-a7fb-5371e83e62f8/exec-c59f3e30-dc57-4ded-9786-67e5bafcde02.png`
- Defects not fixed: none listed
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, mostly hidden behind her. Facing the viewer: her chest and face point at the viewer; her body is square to the camera, not turned to the right, and this is a front view, not a side profile. She collapses slowly and lies down on the ground, her lantern dimming. Pose 1 stagger: the body swaying, one hand to the chest, the lantern bright. Pose 2 knees: the knees buckle, the body sinks low, the lantern flame dimmer. Pose 3 fall: the body falling forward, the arms out, the lantern almost out. Pose 4 lie: lying flat on the ground in front view, the scarf spread out, the lantern dark and nearly out. Variation for this image: standard composition, evenly spaced poses, clear silhouettes. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_death_down_v2.png

- File: `tools/source_art/tamsin_death_down_v2.png`
- Job id: `b05_death_down_v2`
- Verdict: ok
- Note: The job reported the generic name image.png; the only file in its own folder is taken.
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f45-f1ce-7432-a036-19378909b147`; output file: `exec-0f9d74c0-8de6-4e63-ab69-9cd638cda9ed.png`
- SHA-256: `8c07cfcdcce53e806426828a50d8cc7dec28aefd005ccce0e0212336c9402e9f`
- Source path copied from: `~/.codex/generated_images/01a16f45-f1ce-7432-a036-19378909b147/exec-0f9d74c0-8de6-4e63-ab69-9cd638cda9ed.png`
- Defects not fixed: none listed
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, mostly hidden behind her. Facing the viewer: her chest and face point at the viewer; her body is square to the camera, not turned to the right, and this is a front view, not a side profile. She collapses slowly and lies down on the ground, her lantern dimming. Pose 1 stagger: the body swaying, one hand to the chest, the lantern bright. Pose 2 knees: the knees buckle, the body sinks low, the lantern flame dimmer. Pose 3 fall: the body falling forward, the arms out, the lantern almost out. Pose 4 lie: lying flat on the ground in front view, the scarf spread out, the lantern dark and nearly out. Variation for this image: slightly closer framing, more detail in the hands and the tool. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```

## tamsin_death_down_v3.png

- File: `tools/source_art/tamsin_death_down_v3.png`
- Job id: `b05_death_down_v3`
- Verdict: ok
- Reference images: see the entry in batch_05.md (tamsin_walk.png plus tamsin_walk_side.png, or tamsin_walk_down.png for the down rows)
- Attempts: 1
- Image size: 1536x1024
- Generation tool: native image generation (Codex job, model `cheapest`)
- Session ID: `01a16f46-645f-71f3-9bed-fc0a57c8a702`; output file: `exec-e8a9e154-971d-43e9-9b35-6c5a462b6cc7.png`
- SHA-256: `efe562dfbd4af6c55ae6ba7bdc5f6396036cac525ed340ae14c8513f589138ce`
- Source path copied from: `~/.codex/generated_images/01a16f46-645f-71f3-9bed-fc0a57c8a702/exec-e8a9e154-971d-43e9-9b35-6c5a462b6cc7.png`
- Defects not fixed: none listed
- Rejected attempts: none in this run (see the note above about other files in the same session folder)

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Tamsin Ode, a young apprentice lamplighter, about 17, slim, quick and determined. Dark brown hair in a short thick braid with a few loose strands. A rust-red wool coat to mid-thigh with a wide ochre scarf, dark umber trousers, worn brown leather boots, a satchel on a strap across the chest. Her small glass-and-brass lantern burns with a warm amber flame and lights her face and coat from below. The long brass lamp-hook pole with a curled hook at the top is slung across her back on a strap, mostly hidden behind her. Facing the viewer: her chest and face point at the viewer; her body is square to the camera, not turned to the right, and this is a front view, not a side profile. She collapses slowly and lies down on the ground, her lantern dimming. Pose 1 stagger: the body swaying, one hand to the chest, the lantern bright. Pose 2 knees: the knees buckle, the body sinks low, the lantern flame dimmer. Pose 3 fall: the body falling forward, the arms out, the lantern almost out. Pose 4 lie: lying flat on the ground in front view, the scarf spread out, the lantern dark and nearly out. Variation for this image: wider gaps between poses, more motion in the arms and coat. Painterly high detail, no pixel art, no text.

Image size: 1536x1024.
```
