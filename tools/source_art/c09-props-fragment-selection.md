# C09 Letters Hall props and fragment — 2026-10-25

OPENED actual user screenshot /tmp/codex-clipboard-cdfbfbd6-ad4c-42cb-9fc1-662c29e227cb.png: north e223 thorn_wall and southern e231 eye_cell were tan rectangles. Read actual burnable/eye_switch and C9 room/pickup behavior. Review OPEN all thorn_wall v1/v2/v3, eye_cell v1/v3, fragment_c9 v2 raw sources; eye_cell v2 known failed pose count excluded, producer ok is not acceptance. Selected thorn_wall v1 clean dense black thorn barrier with stone supports (v2/v3 mossier), eye_cell v1 actual iron cell bars and eye (v3 wooden leaf, less exact), fragment_c9 v2 first clean dark/smoky glass pose with pale warm white wick; bright halo/floating wick variants not published. Glass has warm bronze reflections, not a perfectly black flat surface.

Published minimum actual-needed idle CLOSED1@1loop for both props. Raw burned/opening/open rows segmented but EMPTY outputs, not runtime animations. Existing burnable tint then hide, eye flag hide unchanged. No open arch or exterior cave aliased to these props. Native192cell foot186 anchor96,186 prop rect_h96; one uniform fit180x174 per selectedclosedpose. Physical192x96 footprint remains actor-owned; size_override affects anchor, never scales art. Fragment_c9 binding96cell foot88 anchor48,88 uniformfit84x82 firstposeidle1@1loop, actual pickup resolver selects exact scopekey. No generic fragment mapping added. Legacy magenta only, no source/pixel edits, new generation, cutter changes or actor adapters.

OPENED existing-cutter source/output comparison proofs for all3, native-scale output strips, and actual World /tmp/c9-props-before.png, cinder-open.png, sling-open.png, paired-north-walk.png, fragment-reward-fixture.png. Temporary capture SaveGame disabled, Dummy audio, white ambient in initial/reward room; after transition normal room lighting. Player.use_item actual Cinder Wick sets burned_e223 and opens both preloaded endpoints; player.use_item actual Sling hits e231 and sets eye_e231, hiding cell blocker. Actual Input move_up traverses to cave_9_3, paired thorn remainsopen. No flag injection for tool interactions. Fragment capture is explicitly a fixture: boss_cave_9_10_defeated seeded to inspect actual existing room-owned reward; NOT a fresh boss combat proof. Route test independently exercises actual C9 progression and reward. Current underlying RoomDoor reveals a preexisting painted grotto after eye blocker hides; this map does not alter that entrance art. No claim all C9 art fixed; Lock Warden/plate separate, Mirror remainsparked.

Validation: art22 PASS; sprite_visual,burnable,eye_switch,pickups,route_cave_9 five suites PASS; lint PASS; exact3key runtime/all animation textures load PASS. Every preexisting manifest/runtime entry semantic-equal; every old PNG SHA256 identical against /tmp/c9-props-before.json. All original raws/origin records and foreign77 staged paths untouched. No broad import/cut, no physics/state/normative/room changes; explicitownedcommit only, no push.

## Exact recipe and interface

### thorn_wall

```json
{
  "kind": {
    "cell": [
      192,
      192
    ],
    "align": "foot",
    "foot": 186,
    "prop": true,
    "rect_h": 96
  },
  "sheet": {
    "key": "magenta",
    "rows": [
      {
        "poses": 1,
        "outputs": [
          {
            "kind": "thorn_wall",
            "anim": "idle",
            "file": "thorn_wall_idle",
            "poses": 0,
            "scale": {
              "measure": "fit",
              "value": [
                180,
                174
              ]
            },
            "fps": 1,
            "loop": true
          }
        ]
      },
      {
        "poses": 5,
        "outputs": []
      },
      {
        "poses": 1,
        "outputs": []
      }
    ]
  },
  "runtime": {
    "cell": [
      192,
      192
    ],
    "anchor": [
      96.0,
      186
    ],
    "foot": 186,
    "mirror_side": false,
    "prop": true,
    "rect_h": 96,
    "animations": {
      "idle": {
        "file": "res://assets/sprites/thorn_wall_idle.png",
        "frames": 1,
        "fps": 1.0,
        "loop": true
      }
    }
  }
}
```

### eye_cell

```json
{
  "kind": {
    "cell": [
      192,
      192
    ],
    "align": "foot",
    "foot": 186,
    "prop": true,
    "rect_h": 96
  },
  "sheet": {
    "key": "magenta",
    "rows": [
      {
        "poses": 1,
        "outputs": [
          {
            "kind": "eye_cell",
            "anim": "idle",
            "file": "eye_cell_idle",
            "poses": 0,
            "scale": {
              "measure": "fit",
              "value": [
                180,
                174
              ]
            },
            "fps": 1,
            "loop": true
          }
        ]
      },
      {
        "poses": 3,
        "outputs": []
      },
      {
        "poses": 1,
        "outputs": []
      }
    ]
  },
  "runtime": {
    "cell": [
      192,
      192
    ],
    "anchor": [
      96.0,
      186
    ],
    "foot": 186,
    "mirror_side": false,
    "prop": true,
    "rect_h": 96,
    "animations": {
      "idle": {
        "file": "res://assets/sprites/eye_cell_idle.png",
        "frames": 1,
        "fps": 1.0,
        "loop": true
      }
    }
  }
}
```

### fragment_c9

```json
{
  "kind": {
    "cell": [
      96,
      96
    ],
    "align": "foot",
    "foot": 88
  },
  "sheet": {
    "key": "magenta",
    "rows": [
      {
        "poses": 4,
        "outputs": [
          {
            "kind": "fragment_c9",
            "anim": "idle",
            "file": "fragment_c9_idle",
            "poses": 0,
            "scale": {
              "measure": "fit",
              "value": [
                84,
                82
              ]
            },
            "fps": 1,
            "loop": true
          }
        ]
      }
    ]
  },
  "runtime": {
    "cell": [
      96,
      96
    ],
    "anchor": [
      48.0,
      88.0
    ],
    "foot": 88,
    "mirror_side": false,
    "animations": {
      "idle": {
        "file": "res://assets/sprites/fragment_c9_idle.png",
        "frames": 1,
        "fps": 1.0,
        "loop": true
      }
    }
  }
}
```

## Existing source origins and full raw hashes

- `tools/source_art/thorn_wall_v1.png`: SHA256 3e5c36bd26fa46a01d90b026f6400dc240de5a04f43d80a59add0fa0a457508d
  Existing tools/source_art/log_b24.md: | `thorn_wall_v1.png` | `b24_thorn_wall_v1` | `01a16f59-435f-72a1-bab3-cba31cf1121b` | `exec-ade64a31-0ab6-4441-a07a-a79e2f07cbaf.png` | 1536x1024 | `3e5c36bd26fa46a0` | ok (closed wall, five burning poses, burnt-open passage) |
- `tools/source_art/eye_cell_v1.png`: SHA256 11c9a55b650dc2331514dee17a523f9d0a313f2357f96d32dcd1b1749d8c5ffb
  Existing tools/source_art/log_b25.md: | `eye_cell_v1.png` | `b25_eye_cell_v1` | `01a16f5d-507f-7732-87d7-49e12c368938` | `exec-5d19e152-aaf4-44cf-bc91-942d5bbf0e12.png` | 1536x1024 | `11c9a55b650dc233` | ok (closed, three opening poses, open; 1/3/1 rows) |
- `tools/source_art/fragment_c9_v2.png`: SHA256 db49ed9738cecb06f0222009cf8e6d4b44ecbee8a4b7ec55419356a4dd2b69ae
  Existing tools/source_art/log_b24.md: | `fragment_c9_v2.png` | `b24_fragment_c9_v2` | `01a16f56-838f-7e13-8527-a7c56cce4aed` | `exec-372230ad-1b50-4602-b39d-6107e654aa37.png` | 1536x1024 | `db49ed9738cecb06` | ok (Corrow's Last Wick: dark glass with a pale white wick flame, four poses) |

Original source model history not inferred; logs/docs provenance records preserved unchanged.
