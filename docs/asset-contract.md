# Wickwarden — asset contract (normative)

This document is the interface between the art pipeline and the game code. The style and the
prompts are in [art-brief.md](art-brief.md). Provenance is in [art-provenance.md](art-provenance.md).

## 1. The rule that is more important than the measurements

**Wickwarden is not a pixel-art game.** The art is painterly, at full resolution, with soft edges
and a free colour space. Hollowtide lost a full art round because its first contract forced the
images into a small palette and a small figure height. The source images were good. The
post-processing ruined them.

> **Post-processing is never destructive.** No palette quantization. No threshold on the alpha
> channel. No downscale below the target size followed by an upscale. No scale per frame.
> Remove the key colour, cut, scale the whole strip with one factor, align the foot line,
> assemble the strip. Nothing more.

## 2. Ownership (step 2)

| Path | Owner | Others |
|---|---|---|
| `tools/source_art/` | image generation (Codex jobs) | read only |
| `tools/cut_sprites.py`, `tools/art_manifest.json`, `tools/test_cut_sprites.py` | pipeline agent | read only |
| `assets/sprites/` (strips, terrain textures, `sprites.json`) | written only by `tools/cut_sprites.py` | read only; never edit by hand |
| `scripts/art/sprite_visual.gd` (`SpriteVisual`) | pipeline agent | read only |
| entity scripts and scenes | wiring agents, as the step-2 task assigns | — |

`tools/source_art/` has a `.gdignore` file. Godot does not import the large source sheets.

## 3. View, scale and facings

- **View:** three-quarter top-down. The camera looks down at about 50°. The viewer sees the top
  of the head and the front of the body. Ground props show their top face and their front face.
- **Scale:** one tile is **96 px**. Tamsin is about **140 px** high (about 1.5 tiles) from the soles
  to the top of the hair.
- **Facings:** characters with a front and a back (Tamsin, the hollow) have three drawn
  directions: `down` (towards the viewer), `up` (away from the viewer) and `side` (drawn
  **facing right**). The code mirrors `side` for left. That gives four facings.
- Creatures without a clear front (spitcap, skitterwick, duskmoth, tallow blob, tallow drop) have
  one drawn direction, facing the viewer or a three-quarter right. The code mirrors it for left.
- **Light:** a warm key light from the upper left, as from a lamp. Deep cool shadows. No cast
  shadow on the background: `SpriteVisual` draws a soft contact shadow under each entity.

## 4. Image format

- PNG, RGBA, true alpha with **soft edges**. Partly transparent edge pixels are wanted.
- Frames are **horizontal strips** of square cells. Frame *n* covers x from `n*W` to `(n+1)*W`.
  The code cuts on exact pixel boundaries. A wrong width breaks every frame after it.
- One file per animation: `assets/sprites/<kind>_<anim>.png`, for example `player_walk_down.png`.
- Single-frame props are one image each: `assets/sprites/<kind>.png`. Their size is in section 7.
- Terrain textures are opaque, seamless in both axes, and repeat with texture repeat on.

## 5. Scale each STRIP, never each frame

The cut tool calculates **one** scale factor per source row (one animation) from the tallest pose
in that row. It applies the same factor to every frame and aligns every frame to the foot line.

Scale per frame is a silent and severe bug. A walk cycle changes about 10 % in height between
the low and the high pose. If each frame scales to the same height, the figure pumps in size
many times each second. No single frame looks wrong, so the bug is hard to find.

All rows of one character (walk, swing, charge, ward, hurt) use **one** shared factor per
character, so Tamsin has the same size in every animation. The manifest names the reference row.

## 6. Cut rules (see also [pitfalls](#10-pitfalls-from-hollowtide))

1. **Key colour.** Each source sheet has a flat key background (pure `#FF00FF` magenta or pure
   `#00FF00` green, given per sheet in the art brief). The tool measures the real key colour from
   the sheet border, because generated "flat" colours drift. Alpha comes from the colour distance
   to the key, with a soft ramp between two thresholds. It is continuous, never a hard cut.
2. **Despill only the edge.** Remove key spill only on partly transparent pixels, and use alpha as
   the coverage rate when you un-premultiply. Never despill opaque pixels.
3. **Find real gaps.** Find the empty columns (and rows) between poses from the alpha. Never cut a
   sheet into equal-width columns: the image model places poses at uneven intervals. Remove
   small islands (noise), but keep loose parts that belong to a pose (a hook tip, a flame).
4. **Count.** If the number of found poses in a row does not match the manifest, stop with an error
   that names the sheet and the row. Never guess.
5. **Align.** Each frame: centre the pose horizontally on the body centre (the alpha mass of the
   lower half), and put the lowest opaque row of the reference pose on the foot line.
6. **Proof.** The tool writes a proof sheet per source sheet to `tools/source_art/proofs/`
   (ignored by git): every cut frame on a dark checkerboard, with the cell border and the foot
   line drawn. A person or an agent looks at every proof before the strips are used.

## 7. Sizes

`W` is the cell size (square). `foot` is the pixel row of the soles in the cell. `anchor` is the
point in the cell that sits on the entity origin. The origin of a body is the centre of its
collision circle, so the soles sit `r` px below it (`r` = body radius).

### Characters and creatures

| Kind | W | foot | Approx. figure height | Animations (frames) |
|---|---|---|---|---|
| `player` | 192 | 176 | 140 | `walk_{down,up,side}` (6), `swing_{down,up,side}` (4), `charge_{down,up,side}` (2), `ward_{down,up,side}` (1), `hurt_{down,up,side}` (1). Idle = walk frame 0. |
| `hollow` | 192 | 176 | 150 | `walk_{down,up,side}` (4) |
| `spitcap` | 128 | 116 | 90 | `walk` (4), `spit` (2) |
| `skitterwick` | 128 | 116 | 70 | `idle` (2), `crouch` (1), `hop` (2) |
| `duskmoth` | 128 | 116 | 60 rest / 110 wide flying | `rest` (2), `fly` (4) |
| `tallow_blob` | 128 | 116 | 80 | `move` (4) |
| `tallow_drop` | 64 | 58 | 40 | `move` (3) |
| `spore` | 64 | centred | 28 | `fly` (2) |

### Items, effects and pickups

| Kind | W | anchor | Animations (frames) |
|---|---|---|---|
| `tether_moth` | 96 | centre | `fly` (4) |
| `pitch_pot` | 96 | foot 88 | `fuse` (2) |
| `explosion` | 384 | centre | `burst` (6), not looped |
| `ember`, `brass_bit`, `brass_coin`, `pitch_pot_bundle`, `key`, `wick_core` | 64 | foot 58 | `idle` (1) |

### Props (single images, anchored at the bottom centre of the collision rectangle)

| Kind | Image size | Notes |
|---|---|---|
| `brazier` | 128 × 192 | unlit `idle` (1); `brazier_lit`: `burn` (4), looped |
| `bush` | 128 × 128 | `idle` (1) |
| `rock` | 128 × 128 | two variants `rock_a`, `rock_b`; the code picks one from the position |
| `tree` | 192 × 288 | two variants `tree_a`, `tree_b`; canopy hangs over the tile above |
| `reed` | 128 × 128 | |
| `sign_post` | 96 × 160 | no text, no letters, no symbols |
| `pedestal` | 128 × 128 | |
| `hut` | 384 × 416 | stands on a 288 × 288 collision rectangle |
| `locked_door` | 192 × 192 | wooden door with an iron lock, in a stone frame |
| `gate` | 192 × 192 | iron bars in a stone frame |
| `cracked_wall` | 128 × 192 | ruin wall with a visible crack |
| `cave_mouth` | 192 × 192 | dark cave opening in rock (overworld side of a `door_marker`) |
| `cave_exit` | 192 × 192 | rough rock arch with pale dusk light behind it (cave side of a `door_marker`) |

### Terrain textures (opaque, seamless, 384 × 384 = 4 × 4 tiles)

| Texture | Use |
|---|---|
| `ground_grass` | overworld floor |
| `ground_cave` | cave floor |
| `wall_hedge` | overworld border ring (dense thorn hedge and mossy stone, seen from above) |
| `wall_cave` | cave border ring |
| `wall_ruin` | `wall` blocks (ruined stone wall top) |
| `water` | `water` blocks (dark pond water) |

Room floors keep `floor_color` as a soft tint on the texture, so the six overworld rooms still
read as different places.

## 8. The manifest `assets/sprites/sprites.json`

`tools/cut_sprites.py` writes this file. `SpriteVisual` reads it once and builds its `SpriteFrames`
at run time from `AtlasTexture` regions. Nobody edits it by hand.

```json
{
  "player": {
    "cell": [192, 192],
    "anchor": [96, 150],
    "mirror_side": true,
    "animations": {
      "walk_down": {"file": "res://assets/sprites/player_walk_down.png", "frames": 6, "fps": 10, "loop": true}
    }
  },
  "rock": {
    "cell": [128, 128], "anchor": [64, 112], "variants": ["rock_a", "rock_b"],
    "animations": {"idle": {"file": "res://assets/sprites/rock_a.png", "frames": 1, "fps": 1, "loop": true}}
  }
}
```

`anchor` is in cell pixels. For a body it is `[W/2, foot - r]`, so the soles touch the bottom of the
collision circle. `tools/art_manifest.json` (the input of the cut tool) maps each source sheet and
each row to the outputs above.

## 9. `SpriteVisual` (the runtime side)

`scripts/art/sprite_visual.gd`, `class_name SpriteVisual extends AnimatedSprite2D`. It replaces
`Placeholder` as the `Visual` child. Its API is a superset of the `Placeholder` API, so the
wiring is small:

```gdscript
static func attach(parent, kind, radius_override := 0.0, size_override := Vector2.ZERO) -> Node2D
    # SpriteVisual if the manifest has `kind`, else a Placeholder (fallback, never a crash)
static func has_art(kind) -> bool
func set_facing(dir: Vector2) -> void      # picks _down/_up/_side and flip_h
func set_kind(kind: StringName) -> void    # brazier -> brazier_lit
func play_anim(base: StringName) -> void   # "walk" -> "walk_down" etc. when the kind has facings
```

- Game logic **never reads** from the `Visual`. The visual may read public state of its parent
  (for example `velocity`) to choose walk or idle. It never changes it.
- `modulate` and `visible` keep their step-1 meaning (hit flash, i-frame blink, charge glow).
- Texture filter: linear with mipmaps off (`CanvasItem.TEXTURE_FILTER_LINEAR`). Never nearest.

## 10. Pitfalls from Hollowtide

- **Chroma key used as opacity on opaque pixels.** The figure turned green and lost its reds.
  Process only partly transparent edge pixels (section 6.1–6.2).
- **Equal-width columns.** Feet and hook tips were cut off or landed in the next cell as loose
  parts. Find real gaps (section 6.3) and look at every proof (section 6.6).
- **Scale per frame.** The figure pumped in size (section 5).
- **Four poses mirrored to eight.** The walk read as broken. All frames of one animation come from
  **one** generation, so the model keeps the figure the same between them.
- **Metrics instead of eyes.** Sizes and hashes passed while the feet were under the floor. Capture
  every room with `tools/capture.tscn` and look at each image.
