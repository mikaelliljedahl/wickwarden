# The Unlit wax wave — 2026-10-27

Generated with the built-in image generation tool, transparent output enabled;
the tool did not expose a model version. Original:
`~/.codex/generated_images/01a17f32-c2cf-7331-b7c3-8f87d6268b07/exec-6a19350b-8c93-4c5e-8ae5-a29ed9b71e79.png`.
Source SHA-256: `eb4c1bf74bb149e4605a7302945b762a831b49a5ee246720665b7ef789c81445`.

Prompt: "Use case: stylized-concept. Asset type: a single continuous horizontal ribbon of molten wax for a dark fantasy top-down adventure game wave effect. Paint an extremely wide, thin band of agitated liquid golden ivory tallow, irregular ripples, small wax ridges and flecks, warm amber highlights and cool deep shadows, painterly brushwork. Viewed from above. The band runs horizontally from the left canvas edge to the right canvas edge at mid-height, and its left and right ends must match seamlessly so it can wrap into a ring. Above and below the band is true transparent alpha with soft edges. No floor, no characters, no separate rings, no text, no border, no flames. One continuous narrow band."

One native-alpha source, cut with the ordinary manifest and cutter:
`uv run --with pillow==12.3.0 --with numpy python tools/cut_sprites.py unlit_wax_wave_z1`.
The resulting 1024 x 192 cell is `assets/sprites/unlit_wax_wave_z1_idle.png`,
SHA-256 `6c9bfb386b1fef83bd62fad25584a9155f8c003ec449ca141a434227f91118e4`.
The cutter proof and controlled radii in the actual dark C10 room were inspected.
A shader wraps the band with constant radial width; separate outlines mark the
unchanged wave edges. Target collision also accounts for its existing 26 px radius.
