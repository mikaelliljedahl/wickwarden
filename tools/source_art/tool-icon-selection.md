# Tool icon selection and integration

Date: 2026-10-25. Selection authorized by the delegated tool-icon integration task. No generation or source editing. All thirty B17/B18 variants visually reviewed in `/tmp/tool-icons-sources-1.jpg` and `/tmp/tool-icons-sources-2.jpg`. Shared provenance and `log_b17.md` / `log_b18.md` cover the original inputs.

The cutter already supports single-pose rows. Manifest sheet keys reference the selected original variant directly; no duplicate accepted source is required. Output kinds are isolated as `icon_<id>`. Binding inventory cells are 128x128, center aligned without a foot line. Existing `fit` scaling uses a 112x112 content envelope (8 px nominal margin for soft fringes), one uniform factor per icon; no external image resizing or manual cut. Pitch Pot uses a 112x96 fit envelope so its off-centre sparks stay inside the centered cell. Cinder Wick uses the existing `min_gap_y: 100` sheet parameter to retain its detached spark in the same single-pose row.

| Kind | Selected source | SHA-256 | Selection reason |
|---|---|---|---|
| `icon_tether_moth` | `icon_tether_moth_v1.png` | `1e6f4643034db13a5d671afd2ec46557d5819c09b312a9db9297421939700d37` | Clear cream/lavender wings and complete fine thread; v2 is more brightly flared, v3 has duller wing contrast. |
| `icon_pitch_pot` | `icon_pitch_pot_v2.png` | `754fca9c51cd1830985c689ed0fa3b88e51cebb5a348e0bdb0681c84a31bb38e` | Broad clay body and bright fuse read clearly at small size; v1 is narrower and v3 loses some clay highlights. |
| `icon_cinder_wick` | `icon_cinder_wick_v1.png` | `c676356f69975302846ebb872c284d22b9aed2de18263acebd08d590c6a642b0` | Simple brass cap and brightest coal distinguish both ends; v2 adds a distracting loop and v3 has a weaker ember. |
| `icon_tallow_sling` | `icon_tallow_sling_v1.png` | `253a06062b75ab43404eea534b581c0e2962c1ea505f8dc215cff4762fefb13f` | Plain fork and separated pale slug pouch give the clearest silhouette; v2 is busy and v3 has a smaller pouch. |
| `icon_reed_raft` | `icon_reed_raft_v1.png` | `54f6c7d13204fda25dc097b80045d629e013000bb027bc9cff78e7b6260de6ef` | Thick bundles and a clear diagonal pole read as a raft; v2 and v3 have busier thin reeds. |
| `icon_heft_mitts` | `icon_heft_mitts_v1.png` | `4a23f1fdb5cf3e9cc89371340a9f004ff648bf90b5cf2b1d66034f2ff6e49601` | Two distinct cuffs and clear mitten shapes; v2 overlaps more and v3 hides the second cuff. |
| `icon_glow_jar` | `icon_glow_jar_v1.png` | `31e8204d7f901d99a23240c8a021d95a2c4ae551a777e9216d693546da83e608` | Round vessel with broad luminous glass reads as a jar; v2 is narrower and v3 drifts to a heart shape. |
| `icon_lantern_chime` | `icon_lantern_chime_v2.png` | `1a63fb124f312580905a4b46a55a0c2bb24263a16839550284f6a2a190ae8c34` | Straight lantern body and three separated tubes retain clear structure; v1 is thinner and v3 has a smaller lantern. |
| `icon_skitter_boots` | `icon_skitter_boots_v2.png` | `5a347bc90b8e8080951c63aca9fe1d20a2fe4a27da47250dd889f5bc3f48ad81` | Sturdy separated boots with visible spring heels; v1 has weaker heel emphasis and v3 is more compact. |
| `icon_reel_line` | `icon_reel_line_v2.png` | `72b0ffc465b803ada5f8498c33323ae063654e38af7914ce52b30fc8b95a5131` | Open reel and bright separate hook communicate both parts; v1 is darker and v3 hides the spool behind a round plate. |

## Visual QA and validation

Opened both source contact sheets (all 30 variants), the final contact sheet, all ten cutter proofs in the proof contact sheet, and individual weak-detail crops for Pitch Pot, Cinder Wick, Tether Moth, Lantern Chime and Reel Line. Also opened the original and final Glow Jar after a hue diagnostic flagged seven fully opaque violet glass-reflection pixels. Those are painted subject colours and remain unchanged under the contract; the flat key and tinted alpha edge are absent. No clipping or loose key islands seen. All subjects read at 64/40 px; at 28 px the chime tubes and reel thread become fine detail, while their silhouettes remain distinct.

QA artifacts (temporary, not committed):
- `/tmp/tool-icons-sources-1.jpg`, `/tmp/tool-icons-sources-2.jpg`
- `/tmp/tool-icons-final-contact.png` (128, 64, 40 and 28 px)
- `/tmp/tool-icons-proofs-contact.jpg`, `/tmp/tool-icon-proofs/*_proof.png`
- `/tmp/tool-icon-{pitch_pot,cinder_wick,tether_moth,lantern_chime,reel_line}-qa.png`

Only the ten named sheets were passed to `tools/cut_sprites.py`. The existing cutter normalizes unrelated terrain entries when writing the runtime manifest. Final manifest assembly retains the original entries and appends only the cutter-generated icon entries; no preexisting kind or animation record changes. A fresh temporary-directory cutter run verifies every committed icon PNG byte-for-byte and every new manifest entry against generated output. No accepted world-object animation or HUD kind was replaced.

Validation:
- `make art-test`: 20 tests passed (`/tmp/tool-icon-art-test.log`).
- `make lint`: `Success: no problems found` (`/tmp/tool-icon-lint.log`).
- `make test T="sprite_visual item_menu"`: both test files passed (`/tmp/tool-icon-godot-tests.log`).
- `godot --headless --path . --script /tmp/validate-tool-icons.gd`: ten `SpriteVisual.icon_of` calls return nonempty 128x128 AtlasTextures (`/tmp/tool-icon-runtime.log`).
- `uv run --with pillow==12.3.0 --with numpy python /tmp/validate-tool-icons.py`: deterministic regeneration, source hashes, preserved original manifest entries, exact ten-kind addition, RGBA/soft alpha, clear borders and key-removal checks passed (`/tmp/tool-icon-validation.log`).

Runtime interface: `SpriteVisual.icon_of('icon_' + id)` resolves `idle`, frame 0, through `assets/sprites/sprites.json` to `res://assets/sprites/icon_<id>.png`. All ten cells and atlas regions are 128x128, with anchor [64,64], centered=true, mirror_side=false. Menu/HUD code integration remains owned by its UI package.
