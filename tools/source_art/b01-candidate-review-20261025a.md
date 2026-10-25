# B01 transparent candidate review — NOT integrated

Accepted prior checkpoints verified: `710c798` and `b66ddd3` are ancestors of HEAD. No duplicate publication. This review changes no manifest/runtime mapping/generated PNG/actor/physics/cutter/raw image. Candidates are not accepted runtime assets yet.

## Review result

- Wax plate: source-level usable ivory/bronze protective panel, no main silhouette clipping. Measured alpha>.1 bounds785x889; a uniform fit into76x84 would be about74.17x84, inside approved maximum. Curved upper rim is retained source design. Acceptance remains conditional on a real native-alpha cutter proof and actual B01 alignment; no preview pixels were manually generated.
- Pillar: source-level usable compact solid wax/slag block; slightly isometric but distinct from a creature or entrance. Measured alpha>.1 bounds892x1007. Do not stretch to96x96; actual world collision remains96x96 and visual-cell/foot anchor fixed. Acceptance remains conditional on native-alpha proof and collision-footprint readability.
- Mouth candidates a AND b: NOT ACCEPTED. Both show broad exterior amber/brown glow; the attempted edit b did not remove the aura and increases saturation. Do not threshold or manually trim their alpha to force acceptance. Request an image-edit worker through root: preserve sealed furnace louvers, solid housing/material/perspective/internal embers, but remove exterior smoky/glow field to truly empty alpha outside a narrow soft silhouette edge. Keep full fixture and clear padding; no generic cave/door substitute. A newly arriving c candidate was noticed as an untracked file during this review and left unopened/untouched pending explicit root handoff.

## Exact required interface (not published)

| Key | Cell | Foot / anchor | prop rect_h | Runtime effective offset |
|---|---|---|---|---|
| wax_plate |96x96 |90 /[48,90] |84 |[-48,-48] with current no-override attach |
| kiln_pillar |96x96 |90 /[48,90] |96 |[-48,-42] with actual96x96 size override |
| kiln_mouth |96x192 |186 /[48,186] |192 |[-48,-90] (decorative Node2D) |

size_override shifts a prop anchor by half its footprint; it never scales art. Wax visible maximum76x84; pillar physics remains96x96; no scene/collision edits authorized or made.

## Blocking existing cutter interface

Actual tools/cut_sprites.py Context._load lines513–521 opens every source as RGB, estimates a key, indexes only magenta/green NOMINAL_KEYS and calls matte. It discards native RGBA source alpha. All four candidates have true native alpha, with black/near-black hidden RGB at transparent corners. Treating them as magenta/green-key sheets would rematte the wrong pixels and produce an invalid canvas. There is no native-source-alpha manifest mode in the current cutter. A temporary monkey-patched/ad-hoc cutter or alpha flatten/rekey image edit would violate this task’s scope, so none was used.

Reported to root for a narrow existing-cutter native-RGBA mode plus focused test ownership, or image-worker key-background renditions. Existing cutter/test files are outside this turn’s explicit manifest/generated/provenance scope. No source absent claim: sources exist, but loader support and mouth quality prevent safe publication. No generated sprite PNG or runtime key is claimed ready.

## Origin and read-only alpha evidence

Native image_gen__imagegen, built-in default model; tool did not expose a model identifier. Session01a17453-02c7-7c00-94a2-d27f09761339. All four raw candidates were compared byte-for-byte with the exact original output files recorded in the handoff; equal. No pixel processing/resizing/alpha thresholding performed. Alpha thresholds below were used ONLY to measure bounds, never to modify an image.

- `tools/source_art/b01_wax_plate_candidate_v20261025a.png`: [1254, 1254], RGBA, SHA256 `efcf8663749e0519b744d2debf50daca8e24f80e3e689ba60e3db168beeb3a99`; cornerRGBA[0, 0, 0, 0]; bounds by alpha `{'0': [0, 9, 1222, 1246], '0.04': [243, 171, 1028, 1060], '0.1': [243, 171, 1028, 1060], '0.5': [243, 172, 1028, 1059], '0.99': [245, 173, 1027, 1055]}`. Origin bytes match: True.
- `tools/source_art/b01_kiln_pillar_candidate_v20261025a.png`: [1254, 1254], RGBA, SHA256 `a2dc86753f77d796443724d18921434a326546e96c0a9dbb73bf487f9fdb4b8e`; cornerRGBA[0, 0, 0, 1]; bounds by alpha `{'0': [0, 0, 1238, 1254], '0.04': [184, 131, 1078, 1138], '0.1': [185, 131, 1077, 1138], '0.5': [185, 132, 1077, 1137], '0.99': [186, 132, 1076, 1136]}`. Origin bytes match: True.
- `tools/source_art/b01_kiln_mouth_candidate_v20261025a.png`: [1024, 1536], RGBA, SHA256 `7ec774ebb29e2fe081dbb7a750f91ec2321982c01a641b5288fe03c42da2042d`; cornerRGBA[1, 1, 1, 0]; bounds by alpha `{'0': [57, 31, 1008, 1536], '0.04': [270, 58, 754, 1445], '0.1': [271, 59, 754, 1445], '0.5': [271, 59, 753, 1444], '0.99': [273, 64, 752, 1441]}`. Origin bytes match: True.
- `tools/source_art/b01_kiln_mouth_candidate_v20261025b.png`: [1024, 1536], RGBA, SHA256 `3f171b55535bfd486205ea4a4f092b491c26eadce745314894e9c997bd1ec435`; cornerRGBA[1, 1, 1, 1]; bounds by alpha `{'0': [0, 0, 1004, 1512], '0.04': [269, 58, 755, 1447], '0.1': [269, 58, 755, 1446], '0.5': [270, 59, 755, 1446], '0.99': [272, 64, 753, 1443]}`. Origin bytes match: True.

## Actual B01 baseline and checks

Opened all four requested source PNGs and /tmp/b01-painted-final.png, then made/opened fresh actual World /tmp/b01-candidate-review-baseline.png with --audio-driver Dummy, SaveGame disabled and capture-only white ambient. It deliberately shows CURRENT fallback art, not integrated candidates. Tree inventory reports wax_plate3 (includes template/scene nodes), kiln_pillar4 and kiln_mouth1; do not call that three visible armour plates. Normal painted Kilnkeeper body remains intact.

20 art tests and focused boss_kilnkeeper/sprite_visual/static_prop_visual suites pass on unchanged runtime. Global lint currently fails only foreign tests/test_route_cave_9.gd:360 max-line-length; reported, unedited. No blanket green gate or new-asset validation claim. Current mapping/runtime/cutter paths remain clean. Protected77stagedpaths, shared provenance dirt, imports/UIDs and all original/old sprite PNG bytes untouched. Review record is the only owned change committed. No push.

## Original candidate handoff (verbatim; candidate status applies)

# B01 candidate handoff 2026-10-25
Status: candidate-only; sole mapper acceptance pending. No manifest/code/normative/repository-provenance edits or commits.

Tool: native image_gen__imagegen, built-in default model (model identifier not exposed by tool; do not infer gpt-image-2).
Session/output directory: /home/mikael/.codex/generated_images/01a17453-02c7-7c00-94a2-d27f09761339/
Parameters all calls: transparent_background=true; referenced_image_paths=[body raw] for initial three calls, mouth candidate-a for edit. Prompt strings below. No size/quality/model arguments are exposed; requested sizes were prompt-only.
Reference body: /home/mikael/code/github/wickwarden/tools/source_art/kilnkeeper_p1_down_v3.png
Also opened actual /tmp/b01-painted-final.png; generated/candidate images opened via view_image. No image pixel processing performed; byte copies only. ImageMagick used for read-only metadata; initial PIL metadata check failed because PIL absent.

Authorized interfaces (NEW candidate keys; idle1 all):
wax_plate: cell96x96 foot90 anchor48,90; visible content <=76x84; hard baseline ivory; game owns orange/alpha molten tint and hp0.6..1 scaling.
kiln_pillar: cell96x96 foot90 anchor48,90; existing physical96x96.
kiln_mouth: cell96x192 foot186 anchor48,186; existing visual96x192; scene is decorative Node2D with no collision shape.

SpriteVisual integration caveat:
size_override does not scale art. With prop:true, effective anchorY = anchorY - rect_h/2; size_override.y overrides manifest rect_h. Wax attach currently has no override (contrary to wording in task), only existing placeholder size76x84; preserving center requires mapper consider prop:true rect_h84. Pillar SolidBlock calls attach(...,0,size96x96); prop:true yields effective anchor48,42. Mouth visual is Node2D; prop:true rect_h192 yields effective anchor48,90. This is mapper guidance, NOT an implementation or authorization to change any offset. All candidate raw canvases require cutter gap/alpha inspection and uniform scale/foot alignment; raw canvases are NOT runtime cells.

Files (byte copies preserved; existing sources untouched):
- tools/source_art/b01_wax_plate_candidate_v20261025a.png: 1254x1254 RGBA. output exec-7bdf94d2-4fa0-4012-b2e0-04e7340352a3.png; sha256 efcf8663749e0519b744d2debf50daca8e24f80e3e689ba60e3db168beeb3a99
- tools/source_art/b01_kiln_pillar_candidate_v20261025a.png: 1254x1254 RGBA. output exec-e5f80abb-d42f-4d0b-9e30-c3afabb33680.png; sha256 a2dc86753f77d796443724d18921434a326546e96c0a9dbb73bf487f9fdb4b8e
- tools/source_art/b01_kiln_mouth_candidate_v20261025a.png: 1024x1536 RGBA. output exec-05391f20-92ca-4474-b658-feb16ee1fa42.png; sha256 7ec774ebb29e2fe081dbb7a750f91ec2321982c01a641b5288fe03c42da2042d
- tools/source_art/b01_kiln_mouth_candidate_v20261025b.png: 1024x1536 RGBA. EDIT of candidate-a. output exec-c504ad9a-e7b0-4601-bb59-352ab41318ab.png; sha256 3f171b55535bfd486205ea4a4f092b491c26eadce745314894e9c997bd1ec435

Visual assessment:
Plate reads as wax cuirass panel with bronze rim; palette strongly matches body, solid hard state, no baked molten glare. It has curved raised top rim (cuirass-like rather than perfectly flat slab). Pillar reads compact square stone/bronze wax-coated obstacle, perspective slightly more symmetrical/isometric than body. Both retain painted texture; no cut-off main silhouettes. Mouth reads sealed furnace louvers, not traversable entrance, but includes top illuminated cap and broad diffuse amber/brown exterior halo. Targeted IMAGEEDIT to remove halo did NOT remove it and increased saturation; b is retained as weak alternative, NOT accepted. Do not map mouth blindly: halo affects bounds/transparent padding. No manual alpha threshold/crop removal was performed.
True transparency verified: all files srgba, opaque=False. Read-only alpha bounding boxes (any alpha, includes faint islands): wax1222x1237+0+9; pillar1238x1254+0+0; mouth-a951x1505+57+31; mouth-b1004x1512+0+0. Wax/pillar faint alpha to edges means mapper must inspect cutter proof rather than use raw entire-canvas scale blindly. This is an acceptance issue, not authority to alter approved cells.
No game tests/capture run because there is no integration; final runtime alignment remains sole mapper verification.

## Exact prompts
### Initial wax
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark. Use case: style-transfer. Use attached Kilnkeeper sheet only as material/palette reference. Create ONE isolated idle wax armour plate, NOT a creature or whole body: a broad thick pale honey ivory hardened wax slab with scalloped drips and subtle soot/slag along worn bronze fastening rim, compact nearly rectangular upright silhouette, 76:84 width:height ratio. No hole, no face, no furnace aperture, no orange molten glow: existing game modulation supplies molten state. Clearly solid protective armour. True transparent RGBA background, no magenta, no floor, no cast/contact shadow. Complete object with ample clear padding; one single pose only. Target eventual 96x96 cell, visible content maximum 76x84, foot90 anchor48,90; source high resolution retains brushwork for mapper uniform scaling/alignment. Image size: 1024x1024.

### Initial pillar
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark. Use case: style-transfer. Attached Kilnkeeper sheet is material/palette reference only. Make ONE separate idle kiln obstacle: squat square solid slag-stone buttress block/pillar, compact nearly square silhouette rather than tall column. Heavy dark soot-brown stone/iron sides and visible top face, worn bronze restrained bands, sparse hardened pale wax drips matching boss. Must read solid impassable obstacle; no opening, no eyes, no creature, no body parts, no fire hazard, no floor or shadow. True transparent RGBA background, soft painted alpha edges, fully contained single complete prop with clear padding. Eventual cell96x96 foot90 anchor48,90 and unchanged96x96 physical footprint; high resolution source for uniform mapper scaling. Image size: 1024x1024.

### Initial mouth
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark. Use case: style-transfer. Attached Kilnkeeper sheet is palette/material reference only. Paint ONE isolated tall narrow kiln furnace vent fixture, idle single pose: upright soot-dark slag stone housing with worn brown bronze riveted rim, central series of tightly spaced horizontal metal furnace louvers with restrained amber ember light behind them, sparse pale old wax drips. Complete narrow vertical industrial furnace vent with sealed lower plinth. Visually machinery, NOT doorway, NOT player entrance, no traversable opening, no handle, no steps, no arch portal, no chimney dominating top, no character or whole boss. Silhouette about1:2 width:height to map into96x192 cell foot186 anchor48,186. Original material design coherent with reference warm bronze furnace/wax, cool soot shadows, soft brush edges. True transparent RGBA background, no magenta or scenery or floor or cast/contact shadow, complete object with transparent padding around all sides. High resolution source for mapper single uniform scale and foot alignment. Image size: 1024x1536.

### Mouth IMAGEEDIT
Use case: precise-object-edit / background-extraction. Edit this exact existing vent prop: remove ONLY the broad brown amber smoky glow/halo outside the solid object silhouette, making all exterior empty area truly transparent. Preserve the complete solid stone/bronze/wax furnace fixture unchanged, its exact shape, proportions, perspective, brush texture, wax drips, colors, internal amber louvers and top vent light. Keep soft antialiased silhouette edges. No surrounding aura, no smoke, no cast shadow, no floor, no scenery, no added details. This is a transparent game prop, one idle pose. Do not crop the object or enlarge it. RGBA true transparent background.
