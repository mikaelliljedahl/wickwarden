# Briar canopy base v4 acceptance and Archivist copy fairness

The supplied candidate is accepted after all three cutter frames and actual C02 presentation were inspected. This record preserves the image worker’s actual prompt and provenance below. Native image_gen.imagegen did not expose a model identifier; none is inferred. Candidate bytes are unchanged from its recorded origin. The model-family inventory wording elsewhere is not substituted for the tool’s actual metadata.

## Acceptance and mapping

- Candidate source: tools/source_art/briar_mother_canopybase_v4_candidate_20261025.png,1536x1024 RGB, SHA256 be8df4187da0ddf20dfc2b51e9798a808831fad5124fb92240dc40afc4307d73. Original source and every old PNG remain untouched.
- Runtime key briar_canopy remains cell[768,512], centre anchor[384,256], idle2@8fps looping / eye_lost1@1fps looping. New unique files briar_canopy_base_v4_idle.png and briar_canopy_base_v4_eye_lost.png. No actor/state/hurtbox changes.
- The original encounter_briar_canopy scale group is unchanged, including ORIGINAL v1 reference poses, so the candidate uses exactly the same numeric scale factor as the accepted art. No per-frame fit or silhouette distortion. The old sheet remains a scale reference but emits no overwritten PNGs.
- Same alpha-mass alignment as before. Old/new bounding boxes: idle0 [43,48,746,424] -> [43,48,745,424]; idle1 [39,48,739,427] -> [39,48,738,427]; eye_lost [12,41,768,425] unchanged. Alpha silhouette IoUs 0.9774304576,0.9828075946,0.9797005249. These support the opened visual comparison, not replace it. Brushwork is globally refreshed; pose shapes and feet/bottom bounds are preserved within one pixel. All painted fruit-eye slits and the socket become ordinary fruit; sleeping face and closed eyelids remain.
- Opened candidate, original and actual reference /tmp/b02-painted-final.png; temporary cutter proof and every selected old/new frame in /tmp/briar-v4-allframes-compare.jpg. Opened final cutter proof tools/source_art/proofs/briar_mother_canopybase_v4_candidate_20261025_proof.png. Actual /tmp/briar-copy-c02-canopy-proof.png shows candidate base with exactly three independent live eye parts (capture-only white ambient for legibility). Eye sources, positions, animation/mechanics remain unchanged.

## Archivist copy correction

The dedicated archivist_decoy_v1 output had a different silhouette scale/palette. The real floating paper sprites contain no painted ground shadow; its kind has no SpriteVisual shadow flag. Copies now reuse the EXACT existing archivist_idle.png and archivist_float.png animation records, not a recut approximation or recolour. Input recipes for decoy output are emitted from the real p1 source row0, with the real c45_archivist shared scale group; existing real files regenerate byte-identically. Both kinds keep cell[256,256], centre anchor[128,128], idle4/float4 at8fps looping and no SpriteVisual shadow. Old dedicated decoy PNGs and raw source remain byte-identical and present. Only the authorized archivist_decoy runtime entry changes.

Actual C05 capture harness enters the existing arena, waits through intro, applies ordinary damage to phase2, waits for the actor’s real three copies, and verifies all four frame images, scales and offsets match; no copy has a shadow child, and the real shadow is hidden without a jar. It then uses the actual player Glow Jar throw, waits for actual landing and asserts jar_lit and the existing real-only shadow become true while all three copies persist. No actor, jar, phase, draw, or physics code is edited. Opened actual unlit /tmp/briar-copy-c05-unlit.png and jar-revealed /tmp/briar-copy-c05-jar-revealed.png. Lighting/location can naturally differ, but the underlying paper bodies are identical; the existing jar shadow remains the intended clue.

## Validation and preservation

20 art tests pass; sprite_visual, boss_archivist and boss_briar_mother targeted suites pass; make lint passes. Temporary actual-world capture assertions pass with --audio-driver Dummy. All previous sprite PNG hashes remain byte-identical (including original canopy and decoy PNGs); all runtime entries except the two explicitly authorized briar_canopy/archivist_decoy entries compare semantically equal. No new runtime key or dimension. The original raw files are never overwritten. Shared provenance edits/foreign staging, other image candidates and actor files are untouched. No broad gate or push.

## Image-worker record (verbatim)

# Briar canopy base candidate — not integrated
Date: 2026-10-25
Candidate: tools/source_art/briar_mother_canopybase_v4_candidate_20261025.png
Candidate SHA256: be8df4187da0ddf20dfc2b51e9798a808831fad5124fb92240dc40afc4307d73
Actual dimensions: 1536x1024, RGB PNG with opaque magenta key (same raw background convention).
Draft provenance row: | briar_mother_canopybase_v4_candidate_20261025.png | 1536x1024 | 01a17453-02c6-7440-b655-6e04a40c36d3 | exec-ee9d131b-886c-4729-a882-cfa197644413 | be8df4187da0ddf2 | /tmp/briar-canopybase-v4-candidate-notes.md |
Tool: native image_gen.imagegen, edit with referenced_image_paths; model identifier not exposed.
Parameters: referenced_image_paths=[selected v1 absolute path, /tmp/b02-painted-final.png]; transparent_background=false (selected raw uses opaque magenta key).
Session: 01a17453-02c6-7440-b655-6e04a40c36d3
Output ID: exec-ee9d131b-886c-4729-a882-cfa197644413
Original generated path: /home/mikael/.codex/generated_images/01a17453-02c6-7440-b655-6e04a40c36d3/exec-ee9d131b-886c-4729-a882-cfa197644413.png
Attempt: 1. Copied unchanged; no pixel edits, resizing, alpha threshold or postprocessing.
Source reference: tools/source_art/briar_mother_p1_v1.png, SHA256 0f34dae5ec95b5156d292fc6f94f8842eb64db86a7cc823b8792a8a91bbed208.
Opened actual original, runtime screenshot and generated result with view_image.
Visual assessment: all large fruit-eye slits and the lower black socket replaced with opaque natural red fruit. No new live eyes. Sleeping face/closed eyelids remain. Three-pose positions and branch silhouettes visually close; painterly surface details refreshed globally, so not pixel-identical outside edit. Lower pose retains body/branch variation, now with ordinary fruit in former socket.
Acceptance pending: sole mapper must inspect cutter proof and runtime alignment. No cell/anchor changes authorized. No runtime or gameplay tests performed (candidate only). Original sources/strips/proofs, mapping, manifest, repo provenance, actors/scenes untouched; no commit/push.

## Draft mapping
briar_canopy idle: candidate row0 poses[0,2], 2 frames 8fps loop=true.
briar_canopy eye_lost: candidate row1 pose0, 1 frame 1fps loop=true.
Preserve cell[768,512], anchor[384,256], centre alignment and shared strip scaling. This is a proposal, not applied. Preserve briar_eye and seed_eye sources and all live-eye positions/mechanics.

## Exact prompt
Use case: precise-object-edit.
Edit target Image 1: the selected original Briar Mother v1 sprite sheet. Image 2 is runtime context ONLY; do not reproduce its room, player, UI or separate live eye sprites.
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.
Make a surgical canopy BASE LAYER edit of Image 1 only. Preserve its exact 1536x1024 canvas, three pose layout (two upper idle poses, one lower eye-lost pose), pose positions, scale, outer silhouettes, branch tips, gaps, sleeping woman's face and closed eyelids, hands, bark, moss, tiny flowers, foliage, natural small berries, lighting, colors, brushwork and all surrounding pixels as closely as possible.
Change ONLY the embedded large red fruit-eye details in ALL THREE poses: replace eye-like pupils, eyeballs, eye-shaped dark fissures and the lower pose's black eye socket with ordinary opaque red-brown natural fruit surface and subtle organic rind texture. Retain natural fruit, stems and branches; these fruits must have no pupils, iris, sclera, eye-shaped slit, staring center, black socket or target-like concentric rings. Do not erase the normal sleeping face. Keep the lower pose's existing branch/body action variation so it can remain the eye_lost animation frame without a painted eye socket.
The base canopy must contain NO additional live eyes or new target organs. The game supplies exactly three separate live eye parts elsewhere; do not paint any of them here. No new objects or boss redesign.
Keep the original perfectly flat magenta #FF00FF key background and edge behavior. No transparency conversion, no floor, no cast shadow, no borders. Maintain exact source alignment; do not rearrange or rescale poses. Image size: 1536x1024.


Final origin verification: the accepted candidate was compared byte-for-byte with `/home/mikael/.codex/generated_images/01a17453-02c6-7440-b655-6e04a40c36d3/exec-ee9d131b-886c-4729-a882-cfa197644413.png`; equal. Final captures were rerun with the player clear of all four figures, and both unlit and actual-jar-revealed outputs reopened. The second capture again shows one existing real-only shadow and four matching paper silhouettes. No procedural shadow was baked into the shared strips.
