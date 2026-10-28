# The Unlit projectile art, 2026-10-28

Reused the existing, provenance-recorded ImageGen sources `proj_gaze_bolt_v1.png`
(SHA-256 `9e32e379d9d8c79976f858407d502b2d3349ba589656d80973eeb09b77627f48`,
`log_b49.md`) and `proj_hush_torrent_v1.png` (SHA-256
`dbb3b99f7292f434bd5a803822c49d9939ea80a24cf217a1086e43fe38f50731`,
`log_b50.md`). No new image was generated. Versions 1–3 of each source were
visually compared; version 1 was chosen for clear, separated poses.

Run `make art SHEETS="proj_gaze_bolt_v1 proj_hush_torrent_v1"`. The two
96×96 kinds `unlit_gaze_bolt` and `unlit_hush_torrent` each have `idle` (two
flight frames, drawn pointing right) and `impact` (three frames), with a common
scale per source row. Proofs in `proofs/proj_gaze_bolt_v1_proof.png` and
`proofs/proj_hush_torrent_v1_proof.png` were reviewed on the dark checkerboard:
all five poses are separated and fit the cells. The cutter reports a one-pixel
slide of the first torrent flight frame to keep it in the cell.

Godot 4.7.2 imported the four strips in an isolated project with the same
resource paths. The files have not been connected to boss logic or reviewed in
the arena; flight rotation, visibility during play and impact timing remain to
be verified during integration. The proof directory is ignored by git and can
be recreated with the command above.
