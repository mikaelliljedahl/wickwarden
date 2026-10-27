# B01 kiln mouth — 2026-10-27

Generated with the native image generation tool, transparent output enabled;
the tool did not expose an image model version. Source output:
`~/.codex/generated_images/01a17dc5-6801-7be1-b963-170ed1dc4e82/exec-e19f02f9-4b65-4fff-8fa8-ef9c96c409a1.png`.
The copied source `b01_kiln_mouth_candidate_20261027d.png` has SHA-256
`c13a4f90d41ad96f1904174364f2596d72e48ccf821c3fa12b4d7115acc0b777`.
The reference `kilnkeeper_p1_down_v3.png` supplied palette and material style.

Prompt: "Use case: stylized-concept. Asset: isolated game sprite, one idle decorative kiln fixture. Reference image is palette and painterly material style only, do not reproduce the character. Paint one tall narrow sealed industrial furnace vent: soot-dark stone housing, aged bronze rim, tight horizontal metal louvers, a little pale hardened wax; dim ember light strictly INSIDE louvers. Three-quarter top-down storybook style with detailed hand-painted textures, no pixel art, no outlines. Silhouette approximately 1:2 width to height, intended for a 96x192 game cell. No doorway, opening, steps, character, scene, floor, shadow, text or smoke. Absolutely no exterior glow, bloom or haze: outside the solid object's antialiased silhouette must be genuinely transparent with ample empty padding on all sides. One complete centered fixture."

Native-alpha cutter proof inspected on a checkerboard; no broad exterior halo
was observed. The existing cutter fits the source uniformly into a 96x192 cell,
foot 186, without thresholding the source alpha. The actual C1 boss room was
also captured with the player near the vent and normal lighting; its appearance
and alignment were inspected. This decorative replacement does not change the
arena collision or boss mechanics.
