# Built-room placeholder sweep selection log

Date: 2026-10-25. Baseline: 55 overworld scenes, 11 pocket scenes and historical `cave_1` (67 total). New cave work is excluded. Existing source PNGs are used unchanged; no new images or edge strips are published.

## Batch 1: hook-cut entrance screens

The clipboard room is `ow_1_3` (Reed Gate). Its two north entrance blockers are `cut_screen` openers with `look=rush_wall`, at cells (9,0) and (10,0). `ow_1_2` (Ford Road) has the matching south pair at (9,9) and (10,9). Compiled runtime entity: `scripts/world/bush.gd`, `SpriteVisual.attach(self, variant, 40.0)`.

Classification: source exists, uncut and unmapped. Both kinds already use SpriteVisual with a geometric fallback. All three variants were opened together at `/tmp/sweep-rush-reed-comparison.jpg`.

| Source file | SHA-256 | Choice |
|---|---|---|
| `rush_wall_v3.png` | `57228b7f6bb4bb960ef30b1f75848b7ecb402259d416a218bf0436ff74ced33b` | Compact intact screen with readable reeds and comparatively simple stone posts. |
| `reed_cluster_v3.png` | `69eb3ec583e66e4d4935e56ef8cdfffbdc6fc49dab8be0c0d86459e7e50679ee` | Clear narrow reed silhouette; less crowded than v2. |

Both sources already have provenance in `docs/art-provenance.md` and generation details in `log_b29.md`. No accepted alias copies are needed: the manifest reads the existing variant paths directly. Original variants remain intact.

Contract: 192 x 192 cells, foot row 176, prop anchor at the foot line, existing 80 px visual footprint. One factor fits the whole intact pose within 176 x 164 px. Only intact `idle` is published: current Bush removes the entity when cut, and that behavior is preserved. The three cut poses are skipped rather than repurposed or patched.

Proofs opened: `tools/source_art/proofs/rush_wall_v3_proof.png` and `reed_cluster_v3_proof.png` (also first trial proofs in `/tmp/sweep-first-proofs/`). Actual before captures: `/tmp/placeholder-baseline/ow_1_3.png`, `ow_1_2.png`; after captures opened: `/tmp/sweep-first-after-ow_1_3.png`, `/tmp/sweep-first-after-ow_1_2.png`. North artwork is partly behind the HUD because these blockers occupy the border row; south art is visible at the bottom edge. Room layout, collisions, flags and timing are unchanged.

Checks: `make art-test` passed 20 tests. `make test T="sprite_visual"` passed. Existing 56 manifest entries remain semantically identical after cutting the eight existing terrain sheets to preserve their generated texture metadata. No original sprite PNG changed.
