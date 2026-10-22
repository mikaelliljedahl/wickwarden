# Tamsin walk v2 image generation log

All image calls used GPT Image through the native image generation tool, with `tools/source_art/tamsin_walk.png` passed as the reference image. The reference remains unmodified. Date: 2026-10-22. Required review rule applied: reject any sheet where two pose leg silhouettes are similar.

## tools/source_art/tamsin_walk_side.png

- Attempts: 3. Kept attempt 3 as the best size-correct result, despite the unresolved defect below.
- Image size: 1536 x 1024 pixels.
- Generation tool/model: native image generation tool (GPT Image; model identifier not shown).
- Generation/call ID: not shown. Session ID: not shown.
- Source path copied from: `/home/mikael/.codex/generated_images/01a163e1-bc66-7452-b66f-4edae8fc1e8f/exec-3281d230-6aa4-4f66-9ad3-77024638e612.png`.
- Attempt 1 call ID: not shown; generated file `exec-5104050c-0431-45ec-ac40-89b73da00938.png`, 2172 x 724, rejected (wrong dimensions and poses 1/3 too similar).
- Attempt 2 call ID: not shown; generated file `exec-1040154b-b186-4c43-a359-0af66af793f7.png`, 1536 x 1024, rejected (poses 1/3 too similar and poses 2/4 raise the same leg).
- Exact prompt used for kept attempt:

> Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.
>
> A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.
>
> Same character as in the reference image, identical design and colours. Tamsin Ode, young slim apprentice lamplighter, matching reference design: same youthful face, dark brown short thick braid, rust-red wool coat to mid-thigh, wide ochre scarf, dark umber trousers, brown boots, crossbody satchel. Her RIGHT hand grips the long brass lamp-hook pole, curled top holding a small warm amber glass lantern. Right-facing pure side view. Exactly four separated full-body drawings in one horizontal line on canvas 1536x1024 landscape. All four heads at same height, all grounded boots at same common baseline. Huge deliberate contrast in the leg silhouettes. Pose 1 contact: LEFT leg is the forward leg, extended diagonally forward to the right, heel planted; RIGHT leg trails dramatically behind to the left, straight, with toe touching. Pose 2 passing: RIGHT leg is forward and lifted, right knee sharply bent, boot floating high in front; LEFT leg straight vertical beneath hips. Pose 3 contact: RIGHT leg is now the forward leg, extended diagonally forward to the right, heel planted; LEFT leg trails dramatically behind to the left, straight, toe touching. It must be a true opposite-leg mirror of pose 1, with the knees and boots visibly exchanging positions. Pose 4 passing: LEFT leg forward and lifted, left knee sharply bent and boot high in air; RIGHT leg straight beneath hips. Every pose's legs are clearly distinct, unobscured by coat and satchel, with obvious gaps between limbs; coat hem held aside enough to see the legs. Do not repeat a leg arrangement. Preserve the same character design, outfit, pole and face. Lantern and coat may swing in alternating directions. Each of the four poses has a clearly different leg position; no two poses look alike. No extra poses, no cropping, no touching; green background. Painterly, no pixel art, no text.

- Unfixed defect: poses 1/3 repeat the same contact leg arrangement; poses 2/4 repeat the same lifted leg arrangement. Therefore this sheet does not pass the explicit pose review rule.

## tools/source_art/tamsin_walk_down.png

- Attempts: 2. Kept attempt 2 as best; defect remains.
- Image size: 1536 x 1024 pixels.
- Generation tool/model: native image generation tool (GPT Image; model identifier not shown).
- Generation/call ID: not shown. Session ID: not shown.
- Source path copied from: `/home/mikael/.codex/generated_images/01a163e1-bc66-7452-b66f-4edae8fc1e8f/exec-c9dabcab-581d-4b15-ac25-b6962a152239.png`.
- Attempt 1 call ID: not shown; generated file `exec-b1fd0fee-eaf8-4dbe-bd9b-763592025a95.png`, 1536 x 1024, rejected (contact poses 1/3 too similar and raised leg beats similar).
- Exact prompt used for kept attempt:

> Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.
>
> A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.
>
> Same character as in the reference image, identical design and colours. Tamsin facing toward viewer, same youth face, short thick dark braid, rust-red mid-thigh wool coat, wide ochre scarf, dark umber trousers, worn brown boots, cross-body satchel, right hand holding brass lamp-hook pole with curled top and small amber lantern. Exactly four separate full-body poses in one row, 1536x1024, same scale and ground line. Ensure legs are highly visible and each silhouette radically different. Pose 1: left boot forward toward viewer and lower in frame, right leg extended back away from viewer and higher in frame, legs spread apart in a long diagonal stride. Pose 2: right knee lifted high and outward, right boot clearly floating, sole visible; left leg straight beneath body. Pose 3: right boot forward toward viewer and lower in frame, left leg extended back away and higher in frame; opposite contact stride with the other leg leading. Pose 4: LEFT knee lifted high and outward, LEFT boot clearly floating with sole visible; RIGHT leg straight beneath body. Raised boot side must alternate right then left. Coat hem flares to expose legs; pole and lantern swing to opposite sides in poses 1 and 3. Each of the four poses has a clearly different leg position; no two poses look alike. Strong separation and wide green gaps; identical outfit/design throughout; painterly, no pixel art, no text.

- Unfixed defect: poses 1/3 still read as the same stride, and poses 2/4 repeat the same raised boot/leg silhouette. Therefore this sheet does not pass the explicit pose review rule.

## tools/source_art/tamsin_walk_up.png

- Attempts: 2. Kept attempt 2 as best; defect remains.
- Image size: 1536 x 1024 pixels.
- Generation tool/model: native image generation tool (GPT Image; model identifier not shown).
- Generation/call ID: not shown. Session ID: not shown.
- Source path copied from: `/home/mikael/.codex/generated_images/01a163e1-bc66-7452-b66f-4edae8fc1e8f/exec-98d28a3d-da49-4e07-ab01-c720198b562e.png`.
- Attempt 1 call ID: not shown; generated file `exec-f8579e91-22f9-4c5b-bda5-eb6ff828829b.png`, 1536 x 1024, rejected (poses 1/3 and 2/4 repeated leg silhouettes).
- Exact prompt used for kept attempt:

> Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.
>
> A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.
>
> Same character as in the reference image, identical design and colours. Back view Tamsin walking away, same thick braid, back of rust-red wool coat, ochre scarf, umber trousers, boots, satchel, and right hand holding brass lamp-hook with warm amber lantern. Exactly four separate full-body poses across one horizontal row, 1536x1024, same scale, common ground line, wide gaps. Exaggerate and visibly alternate leg silhouettes. Pose 1 contact: left leg reaching forward away from viewer (visually upward/behind torso), left boot planted; right leg extends back toward viewer (visually lower in picture), right toe planted; wide stride. Pose 2 passing: right knee bends and lifts high behind her, boot raised with its sole facing viewer; left leg straight supporting. Pose 3 opposite contact: right leg reaches forward away from viewer, right boot planted; left leg extends back toward viewer, left toe planted; mirror the first stride. Pose 4 passing: left knee bends and lifts high behind her, left boot raised with sole facing viewer; right leg straight supporting. Expose legs clearly below a flared coat hem. Never duplicate a pose, alternate boot lifted side. Same right hand pole. Coat hem and lantern swing opposite sides in contact poses. Each of the four poses has a clearly different leg position; no two poses look alike. Painterly, no text, no pixel art.

- Unfixed defect: pose pairs 1/3 and 2/4 have similar leg positions; the right boot appears lifted in both passing frames. Therefore this sheet does not pass the explicit pose review rule.

## tools/source_art/tamsin_walk_down.png — redo

- Attempts: 1. Kept attempt 1; the lantern pole stays consistently on picture-left in all four poses, which was the overriding review criterion. Legs show the requested alternation: poses 2 and 4 lift different legs. Contact poses are somewhat similar, but distinguishable.
- Image size: 1536 x 1024 pixels.
- Generation tool/model: native image generation tool (GPT Image; model identifier not shown).
- Generation/call ID: not shown. Session ID: not shown.
- Source path copied from: `/home/mikael/.codex/generated_images/01a163ed-5cf5-7ea0-a18c-6213dc71318e/exec-2a3c4827-3e06-4915-8b1d-ae993820826e.png`.
- Date: 2026-10-22.
- Reference images: `tools/source_art/tamsin_walk.png` (design) and `tools/source_art/tamsin_walk_side.png` (accepted style).
- Exact prompt used:

> Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.
>
> A sprite sheet on a perfectly flat, uniform pure green #00FF00 background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.
>
> Same character as in the reference image, identical design and colours. Tamsin Ode, young slim apprentice lamplighter, matching reference design: same youthful face, dark brown short thick braid, rust-red wool coat to mid-thigh, wide ochre scarf, dark umber trousers, worn brown leather boots, crossbody satchel. She faces directly toward the viewer in a three-quarter top-down front view. Exactly four separate full-body poses in one horizontal row, on 1536x1024 landscape canvas. All four poses same scale, feet share one exact common bottom baseline; generous equal green gaps. Lantern pole is an important invariant: "In all four poses she holds the lantern pole in her right hand, on the left side of the picture; the pole and lantern never move to the other side." The pole is always upright just to the left of her body, lantern hanging at its top, clearly separated from her face and body; never cross-body, never swap hands, never appear on picture-right. Match its exact side and placement in all poses.
>
> Four distinct walking leg beats, visibly legible below a lifted/flared coat hem, no limbs hidden: (1) her left foot (viewer's right) stepped forward and lower in the picture, the other foot back; (2) her right knee (viewer's left) lifted, that boot raised; (3) her right foot (viewer's left) forward and lower, the other back; (4) her left knee (viewer's right) lifted, that boot raised. Poses 2 and 4 lift DIFFERENT legs. Make the lifted boots clearly airborne with bent knees and visible green gap below each boot. Contact poses have widely separated feet, one boot visibly lower in the picture and forward, the other higher and back. Keep coat, satchel, face and braid consistent. Painterly high detail, no text, no pixel art.

Lead review: side and up accepted by the lead session.
