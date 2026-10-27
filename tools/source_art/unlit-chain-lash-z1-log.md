# The Unlit chain lash — 2026-10-27

Generated with the built-in image generation tool with transparent output enabled;
the tool did not expose a model version. Original:
`~/.codex/generated_images/01a17f32-c2cf-7331-b7c3-8f87d6268b07/exec-a26792a3-3e6d-408b-a610-33730c0706f2.png`.
Source SHA-256: `31b2e2b1b3461229eba9e0b2ad60cba9c76cb5599b45978ba2076a423af030b6`.

Prompt: "Use case: stylized-concept. Asset type: transparent top-down game effect for Wickwarden. Create ONE continuous straight vertical chain lash lying flat on a dungeon floor, viewed from a three-quarter overhead game camera. Long narrow composition, an uninterrupted heavy old iron chain with linked oval links, weathered brass and cold dark steel, small warm glints and restrained painterly brush texture. The chain runs straight from near the top to near the bottom, centered, isolated with generous transparent side margins; clear silhouettes and naturally articulated links. Full-resolution hand-painted dark fantasy adventure game art, soft edges, warm light from upper left, cool shadows. Genuine transparent background. No floor, no glow rectangle, no frame, no text, no characters, no duplicate chains."

One native-alpha source, 1024 x 1536. Cut with the project cutter and
the main `tools/art_manifest.json`:
`uv run --with pillow==12.3.0 --with numpy python tools/cut_sprites.py unlit_chain_lash_z1`.
The cutter also generates its entry in `assets/sprites/sprites.json`.
The resulting 96 x 768 cell is `assets/sprites/unlit_chain_lash_z1_idle.png`,
SHA-256 `ba99a0ee452b6002e609870a77052087c3ea3e10b79180444e2098837c04fe95`.
The cutter proof and controlled warning and active states in the actual dark
C10 room were inspected. A separate outline shows the unchanged damage bounds.
