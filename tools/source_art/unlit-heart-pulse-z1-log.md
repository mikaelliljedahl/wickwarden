# The Unlit heart pulse — 2026-10-27

Generated with the built-in image generation tool, transparent output enabled;
the tool did not expose a model version. Original:
`~/.codex/generated_images/01a17f32-c2cf-7331-b7c3-8f87d6268b07/exec-04d26ae3-768d-4420-b626-fb7aeb7c6666.png`.
Source SHA-256: `e3e5ce2805deed26c6f4b59677a19b93321d20b8f95131ff65ab2f33c78d116c`.

Prompt: "Use case: stylized-concept. Asset: one transparent horizontal texture ribbon for the expanding heart pulse of a dark painterly top-down fantasy adventure game. One continuous thin horizontal band of eerie luminous violet-blue Hush energy, silver lavender glints and soft painterly wisps, like a ripple of ghostly light released by a dark heart. Viewed from above. The ribbon extends continuously from left edge to right edge of canvas, centered vertically, left and right ends matched for a seamless wrap. Surrounding space is genuine transparent alpha, no background. Subtle variations inside the ribbon, readable against black stone. No wax, no fire, no characters, no separate objects, no text, no border."

One native-alpha source cut with the main manifest and project cutter:
`uv run --with pillow==12.3.0 --with numpy python tools/cut_sprites.py unlit_heart_pulse_z1`.
The 1024 x 192 output is `assets/sprites/unlit_heart_pulse_z1_idle.png`,
SHA-256 `9c01cbec5f8bfafb8ac0be9efdeda67803699341f687fef8dd422e7ee918042a`.
The cutter proof and controlled stills at three radii in the actual dark C10
room were inspected. The existing ring shader wraps the band at fixed radial
width; separate outlines mark the unchanged 48 px ring edges. Collision also
accounts for the existing 26 px target radius. The player was active but the
probed ring was frozen; this is not a human action-state playthrough.
