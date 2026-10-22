# Wickwarden — art provenance

This is a work inventory, not a legal certificate. All raster art in this repository is original to
Wickwarden. It was generated with GPT Image (the native image generation tool of the Codex CLI)
from the project's own written prompts in [art-brief.md](art-brief.md), then cut by
`tools/cut_sprites.py` without destructive edits ([asset-contract.md](asset-contract.md)). No images
from other games, publishers or third-party asset packs are included, and no prompt names another
game, franchise or artist. A commercial release still needs a review of the image generator's terms.

The procedural parts (the swing trail in `scripts/art/swing_trail.gd`, the contact shadows, the
step-1 `Placeholder` shapes and the HUD hearts) are hand-written code.

## How the sources were made (2026-10-22)

- Each sheet came from one prompt: the shared block, the sheet block (or the texture block) and the
  sheet description from `art-brief.md`. The Tamsin swing and states sheets used the accepted
  `tamsin_walk.png` as a reference image. `hush_duskmoth_fly.png` used a crop of the accepted rest
  pose as its reference.
- The Codex jobs ran through AgentTeamForge. The Codex model drives the tool call; the image model
  is the same at every tier. The tool did not show a model version or a generation ID. The IDs
  below are the output file names that the tool wrote under `~/.codex/generated_images/<session>/`,
  and each source file below is byte-identical to that output (SHA-256 checked).
- Per-sheet prompts, attempts and reviews are in `tools/source_art/log_*.md`. Two Codex agents
  stopped in a daemon fault before they wrote a log. For those sheets (`items`, `fx_explosion`,
  `tamsin_walk`) the lead session reviewed the outputs and wrote the log; their exact prompt text is
  not recorded.
- No source image was resized or edited by hand. The textures and some sheets are 1254×1254 or
  2172×724 because the tool returned those sizes.

## Source inventory (`tools/source_art/`)

| Source | Size | Codex session | Output ID | SHA-256 (first 16) | Log |
|---|---|---|---|---|---|
| `tamsin_walk.png` | 1536×1024 | `01a16359-9f80-7e42-93b5-d7b5535ab87d` | `exec-a228f8cc-9891-4257-adfb-23a106886ef4` | `ac407e2a49af4cc8` | `log_tamsin.md` |
| `tamsin_swing.png` | 1536×1024 | `01a16363-440a-74d2-ac5c-d662b76c91b5` | `exec-49b5c221-47fe-4919-a34b-81d63fd7bcfd` | `3d7157c3128cdf41` | `log_tamsin_swing.md` |
| `tamsin_states.png` | 1536×1024 | `01a1636a-1d13-7303-b557-c416fbf242c6` | `exec-78ee1f0d-2c43-44fa-a538-da9934b00cb3` | `a0ed3d836c9f4158` | `log_tamsin_states.md` |
| `hush_spitcap.png` | 1536×1024 | `01a16348-22aa-7612-807c-52cc7627ae46` | `exec-93fc076b-dda6-44ef-b9cd-17ac2870b6dd` | `2fa5d61de61ba4c6` | `log_hush.md` |
| `hush_skitterwick.png` | 1536×1024 | `01a16348-22aa-7612-807c-52cc7627ae46` | `exec-d89030b4-a116-4a15-b872-196500a68773` | `2acfb658494b5a15` | `log_hush.md` |
| `hush_duskmoth.png` (rest row only) | 1536×1024 | `01a16348-22aa-7612-807c-52cc7627ae46` | `exec-cf5d74ad-795f-4a78-8b43-3abe36048c59` | `5129244fc1196541` | `log_hush.md` (redo) |
| `hush_duskmoth_fly.png` | 2172×724 | `01a16359-bcd7-7cb2-b5d7-36bbd1f3e080` | `exec-dadffb6c-9533-4aaf-a846-a47aa4f3cf98` | `adedd3ac9da9b4d9` | `log_items_b.md` |
| `hush_tallow.png` | 1536×1024 | `01a16348-22aa-7612-807c-52cc7627ae46` | `exec-558e66a8-f7d9-4b29-abdb-8dd848eb56cc` | `d038bd036e7d5acd` | `log_hush.md` |
| `hush_hollow.png` | 1536×1024 | `01a16348-22aa-7612-807c-52cc7627ae46` | `exec-4f2a0da6-7510-4d04-a06c-798c56daf177` | `b61382edd67d0740` | `log_hush.md` |
| `items.png` | 1536×1024 | `01a16348-2fcb-7dc3-98c1-e9677be62bcc` | `exec-c8e268cb-9ffa-444e-81fe-a714ebf87779` | `c79698c4500937bf` | `log_items.md` |
| `fx_explosion.png` | 1536×1024 | `01a16348-2fcb-7dc3-98c1-e9677be62bcc` | `exec-5d715b52-6c9d-4787-bac4-f293e3667833` | `553c92be97816e17` | `log_items.md` |
| `pickups.png` | 2172×724 | `01a16359-bcd7-7cb2-b5d7-36bbd1f3e080` | `exec-b1c5cf4a-9157-4467-88eb-d8fe72be2642` | `09120639c9505fb9` | `log_items_b.md` |
| `braziers.png` | 2172×724 | `01a16359-bcd7-7cb2-b5d7-36bbd1f3e080` | `exec-104a1402-c0b9-4679-96c7-0ed7652a2eba` | `0752af0a20ff6f6a` | `log_items_b.md` |
| `ow_props.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-01be40f6-41b1-4e2b-a549-16021f0624cf` | `4ff429f6b88ebcda` | `log_world.md` |
| `ow_structures.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-8dceb917-15d4-43bc-bb25-221ca3f0eba9` | `5a8016b5408a3f95` | `log_world.md` |
| `cave_exit.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-b4992961-d01d-465e-93d2-18e1c848aeb8` | `7fcc69abaf63abd7` | `log_world.md` |
| `tex_ground_grass.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-38a7a673-beec-4b51-bc49-6a13742cefac` | `cfd8c9bf2f62e13e` | `log_world.md` |
| `tex_wall_hedge.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-5eaf1d55-ee45-465e-855a-81788d891d9e` | `2b9d46d74a15e536` | `log_world.md` |
| `tex_wall_ruin.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-960e353e-ef46-4b35-9117-ef82969655ec` | `9bdce487357a46da` | `log_world.md` |
| `tex_water.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-8dd28f5d-e18c-41af-ab39-3b23e316eac1` | `e2be33fa288ffcd6` | `log_world.md` |
| `tex_ground_cave.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-03f3e9c5-a5a3-4919-a665-86916a86a647` | `1c649df700c17b8f` | `log_world.md` |
| `tex_wall_cave.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-a1bf1da6-551a-4089-b53b-6df41d9533ae` | `6446404de64b0241` | `log_world.md` |

Rejected outputs stay only in the local Codex folders and are not in the repository: the first
duskmoth flight row (inconsistent headings), two other duskmoth redo attempts, two other explosion
attempts and the second Tamsin walk attempt.

## Processing

`make art` (`tools/cut_sprites.py` with `tools/art_manifest.json`) writes every file under
`assets/sprites/` and `assets/sprites/sprites.json`. The tool removes the key colour with
continuous alpha, despills only partly transparent edge pixels, finds real gaps between poses,
scales each strip with one factor, aligns the foot line and makes the terrain textures seamless.
It never quantizes the palette or thresholds the alpha. `make art-test` runs its tests.

## Human review

The lead session looked at every source sheet and at the room screenshots in
`docs/screens/step2/`. No human visual approval is claimed yet. The user will judge the art, and
the width of the hook swing in particular, in play.
