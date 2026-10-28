# C10 shell and lantern image trials, 2026-10-28

Both images were made with the built-in image-generation tool as edits of the
provenance-recorded 2026-10-27 native-alpha sources. Session
`01a18060-1911-7fc1-85d4-83976539057c`.

## Ninth Lantern glow

- Source: `ninth_lantern_glow_candidate_20261028a.png`, reference
  `ninth_lantern_candidate_20261027c.png`.
- Output: `exec-c0621961-984a-42a7-9322-4794fbfd826e.png`.
- SHA-256: `c3b520d46e2b17517b9011ea8a5c83fa76c4bd6237e168fed415c277b1d274ab`.
- Prompt:

> Edit the reference game sprite into one slightly brighter hanging-glow animation frame. Preserve the exact same complete lantern, object size, position, silhouette, short top loop, opaque dark violet glass, gold metal, candle, angle, perspective and painterly details. Only slightly vary the violet flame and its glow INSIDE the glass; do not change the lantern shape or the outer contour. One isolated complete object, true transparent background, no other objects, no ground shadow, no text, no border.

The accepted and new image use the same cutter scale group and centred anchor.
The two stills provide an ambient flicker; they are not the full planned sheet.

## Rejected shell walk

- Output: `exec-fe6ee685-14d0-4b83-bbb0-04088cc3e634.png`.
- SHA-256: `177077fa7b067f91c92495ca6fa60975a8fa3becea64854a619a3828cf50d620`.
- Reference: `unlit_shell_candidate_20261027a.png`.
- Prompt:

> Using the reference image as the exact character design, create one isolated sprite sheet for a top-down game. One horizontal row of FOUR separated, full-body frames of the SAME wax creature taking a slow heavy walk toward the viewer: left foot forward, passing, right foot forward, passing. Keep the creature's exact silhouette, identity, amber-and-charcoal layered wax, hollows, original head, body, arms, feet, lighting, proportions and painterly brushwork consistent. Each pose must have the same size and same baseline and must be clearly separated by generous TRANSPARENT empty columns. All limbs must remain within each frame; no touching, overlap, floor or cast shadow. True transparent background, no text, no border, no grid, no other subjects.

The cutter detected four poses, but a shared scale with the accepted still gave
roughly 156 px per walking pose versus 278 px for the still. The strip was
rejected and is not registered in the runtime manifest.
