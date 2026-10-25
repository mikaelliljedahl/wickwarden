# B09 Lock Plate accepted subset — 2026-10-25

Read /tmp/b09-targeted-review/recipe.json; OPENED actual lock_plate_v1 raw, game-scale-targets.png, plate-offset-targets.png and plate source/cutproof. Only lock_plate integration authorized. Reviewer body composition is evidence of misaligned baked targets, NOT body acceptance. No Lock Warden body/keyhole map. Existing B69 producer calls plate glossy 3D rather than painterly; this material/style limitation remains honest. Accepted clean isolated brass mechanics under this subset release.

Exact bindingcell160x160, centreanchor80,80, radius34, NOfoot. Shared uniform factor0.48484848484848486 from fit100x112 measured across all5 accepted poses: row0p0closed1; row1p0..2opening3; row2p0open1. idle aliases identicalclosedstrip. fps6, closed/open/idleloop, openingnonloop. Entire brokenrow3 skip:true outputs:[]; actual5blob segmentation does not equal3frames, no manualsplit/crop. No arbitrary scaling or per-state size correction. Production output stems exclude.png.

Actor adapter b657e7 owns position16,-30, closed/open immediate from lid_left and primitive-eye suppression only with complete textures. Mapping does not embed offset into anchor or change collision/lifetime. OPENED regenerated proof and all5 outputframes at game scale. Actual World cave_9_10 capture OPEN /tmp/lockplate-world-four-closed.png after100frames: four painted closed targets visible around existing geometric body (body remains withheld). Initial6frame /tmp/lockplate-world-closed.png predates plate spawn, not a plateproof. Capture SaveGame disabled, Dummyaudio, playerclear, capture-only white ambient. Separate B09 owner verifies final open/closed target alignment after dependencyhash; this is not fullboss-artacceptance.

Validation: art22PASS, SpriteVisual/boss_lock_warden2 suitesPASS, lintPASS, exact runtime lock_plate allstate/allframetexturesloadPASS. All old manifest/runtime records semantic-identical and every old PNG SHA256 byte-identical against /tmp/lockplate-before.json. Original raw/sourceorigin/provenance unchanged; foreign77staging preserved. No actor/scene/physics/cutter/normative changes, no push.

## Existing source origin

- File: `tools/source_art/lock_plate_v1.png`
- Job id: `b69_lock_plate_v1`
- Reference image(s): `tools/source_art/lock_warden_body_closed_open_v1.png` (producer pick, design reference: the chosen variant of `lock_warden_body_closed_open`)
- Attempts: 1
- Image size: 1536×1024 pixels (requested 1536x1024 (landscape))
- Generation tool: native image generation (gpt-image) through Codex, model `cheapest`
- Session ID: `01a16fcb-a01a-7441-9b31-061f49cfcaf6`
- Generated file: `exec-3d3397f3-ce7e-406a-86fc-646dc0e0f29f.png`
- Source path copied from: `~/.codex/generated_images/01a16fcb-a01a-7441-9b31-061f49cfcaf6/exec-3d3397f3-ce7e-406a-86fc-646dc0e0f29f.png`
- SHA-256: `a722af6927b7dc2be48e0d479831a8c49aac1f46fd7a7bf7dec9c6b254deb7de`
- Verdict (producer view, not owner cull): weak - glossy 3D-rendered brass more than painterly brushwork; no cropping or overlap
- Defects not fixed: glossy 3D look, not painterly
- Rejected attempts: none.

Exact prompt used:

```text
Original game art for "Wickwarden", a painterly top-down adventure. Hand-painted storybook illustration style with visible brush strokes and soft edges, high detail, warm lamp light against deep dusk colours, low saturation except for light sources. NOT pixel art, no pixel grid, no dithering, no thick black outlines. Three-quarter top-down view, camera about 50 degrees above the ground, key light from the upper left. No text, no letters, no numbers, no labels, no frame borders, no grid lines, no watermark.

A sprite sheet on a perfectly flat, uniform pure magenta #FF00FF background that fills the whole image, with no gradient, no texture, no vignette, no floor and no cast shadow on the background. Each pose is a separate, complete figure with a wide empty gap of background on all sides; poses never touch or overlap and nothing is cut off at the image edge. Poses in one row stand on one shared invisible ground line and have the same scale. The figure is identical in every pose: same design, same colours, same proportions.

Same character as in the reference image, identical design and colours. Exactly 8 separate poses in 4 horizontal rows on a 1536x1024 landscape canvas, all at the same scale, all bases on one common ground line within each row, wide equal gaps between all poses, no pose touching another. Subject: one corner plate of a huge brass lock: a hinged brass plate with a lidded eye above it and rivets along its edges. No facing: the subject is seen from above at the same three-quarter top-down angle, and it is the same object in every pose. Rows from top to bottom. Row 1, lid eye closed, 1 pose: pose 1: the lid shut over the eye, the plate whole. Row 2, opening, 3 poses: pose 1: the lid starting to lift; pose 2: the lid lifting higher, a glint in the eye; pose 3: the lid open, the eye showing. Row 3, open, 1 pose: pose 1: the eye open and glowing. Row 4, broken, 3 poses: pose 1: the plate split into four corner parts, the parts apart; pose 2: the four parts scattering further apart; pose 3: the four parts lying on the ground, the eye dark. Variation for this image: Neutral, clear composition; poses evenly spaced and well separated, the silhouette plain and readable. No extra poses, no cropping, no touching, no text. Painterly high detail, no pixel art.

Image size: 1536x1024.
```

Origin verbatim as existing record; no model identifier inferred from historical cheapest execution label. Full rawhash reverified: a722af6927b7dc2be48e0d479831a8c49aac1f46fd7a7bf7dec9c6b254deb7de

## Exact runtime and extraction

```json
{
  "kind": {
    "cell": [
      160,
      160
    ],
    "align": "center",
    "anchor": [
      80.0,
      80.0
    ],
    "radius": 34,
    "mirror_side": false
  },
  "scale": {
    "measure": "fit",
    "value": [
      100,
      112
    ],
    "ref": [
      {
        "sheet": "lock_plate_v1",
        "row": 0
      },
      {
        "sheet": "lock_plate_v1",
        "row": 1
      },
      {
        "sheet": "lock_plate_v1",
        "row": 2
      }
    ]
  },
  "sheet": {
    "key": "magenta",
    "rows": [
      {
        "poses": 1,
        "outputs": [
          {
            "kind": "lock_plate",
            "anim": "closed",
            "file": "lock_plate_closed",
            "scale": "lock_plate",
            "fps": 6,
            "poses": [
              0,
              1
            ],
            "loop": true
          },
          {
            "kind": "lock_plate",
            "anim": "idle",
            "file": "lock_plate_closed",
            "scale": "lock_plate",
            "fps": 6,
            "poses": [
              0,
              1
            ],
            "loop": true
          }
        ]
      },
      {
        "poses": 3,
        "outputs": [
          {
            "kind": "lock_plate",
            "anim": "opening",
            "file": "lock_plate_opening",
            "scale": "lock_plate",
            "fps": 6,
            "poses": [
              0,
              3
            ],
            "loop": false
          }
        ]
      },
      {
        "poses": 1,
        "outputs": [
          {
            "kind": "lock_plate",
            "anim": "open",
            "file": "lock_plate_open",
            "scale": "lock_plate",
            "fps": 6,
            "poses": [
              0,
              1
            ],
            "loop": true
          }
        ]
      },
      {
        "skip": true,
        "outputs": []
      }
    ]
  },
  "runtime": {
    "cell": [
      160,
      160
    ],
    "anchor": [
      80.0,
      80.0
    ],
    "radius": 34.0,
    "mirror_side": false,
    "centered": true,
    "animations": {
      "closed": {
        "file": "res://assets/sprites/lock_plate_closed.png",
        "frames": 1,
        "fps": 6.0,
        "loop": true
      },
      "idle": {
        "file": "res://assets/sprites/lock_plate_closed.png",
        "frames": 1,
        "fps": 6.0,
        "loop": true
      },
      "opening": {
        "file": "res://assets/sprites/lock_plate_opening.png",
        "frames": 3,
        "fps": 6.0,
        "loop": false
      },
      "open": {
        "file": "res://assets/sprites/lock_plate_open.png",
        "frames": 1,
        "fps": 6.0,
        "loop": true
      }
    }
  },
  "png_sha256": {
    "assets/sprites/lock_plate_closed.png": "fef716b1b196a23f162322e14c7bf654ed20ee70966d86a5cf314cb1756e76a1",
    "assets/sprites/lock_plate_opening.png": "94b0df46caafdfc5952f27af7469e08542e3db4f5dcbcd19f55cd709cc5d3c65",
    "assets/sprites/lock_plate_open.png": "9f21a92753ef9ae3e1ba435f502d331d8b81f4fc2417863da45528e67e8a50c8"
  }
}
```
