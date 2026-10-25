# Hidden Seam e185 existing-source integration — 2026-10-25

Reviewed OPEN actual hidden_seam_v1/v2/v3 raws and log_b27.md. Producer verdict is origin evidence, not acceptance. Selected v1: flatter low stone threshold, consistent footprint, cool blue revealed fissure. v2 raised paving geometry and v3 heavier jagged framing are less suitable. Honest limit: all candidates paint stone floor/scuff overlays with sparse foliage, not an open indoor wall aperture. Published a revealed passage threshold cue; no exterior cave-mouth substitution and no invented aperture or pixel repair.

Existing source origin: batch B27, job b27_hidden_seam_v1, session01a16f9b-5504-7df1-a723-854f20468fa6, output exec-3cf01f17-080f-4a92-922d-2458282fd4ac.png. Original record tools/source_art/log_b27.md and docs/art-provenance.md unchanged. No generation or inferred model history. Full raw SHA256: a7a97a1f423084eaa0b00d891f8261292dc413b20e590398050e440cdf2e252b.

Binding inventory cell128x128. Prop foot122, anchor64,122, rect_h96; actual actor size192x96 is an anchor/footprint override, NEVER a source stretch. One shared uniform fit116x110 across three revealed poses. Legacy magenta pipeline. Source row0 hidden1 measured/detected but emits NO output: actual actor keeps Visual invisible until is_shown. idle1@1 loop selects row1 pose2, the stable final revealed cue; revealed3@6 nonloop uses row1 poses0..2 (available, current actor requests defaultidle). No closed art leaked before jar. All output nonzero alpha bounds[4,44,121,123],117x79, foot inclusive122. Source/cut proof and final game-scale outputs OPENED. No manual alpha editing, geometry or physics changes.

Actual World sequence /tmp/hidden-seam-capture.gd (temporary capture only, SaveGame disabled, Dummy audio) used player.use_item with real acquired GlowJar, no direct reveal/flag injection: starts actual cave_5_6, asserts visual hidden, throws jarDOWN from(960,624), waits continuous exposure, asserts real e185 and preloaded peer permanent plus canonical revealed_e185 flag. Actual Input move_down traverses into cave_5_5; move_up returns cave_5_6. Both seam states restored and visual remains shown. Captures OPENED /tmp/hidden-seam-before.png, real-jar-reveal.png, permanent.png, paired.png, return-reentry.png. Initial snapshots use capture-only white ambient; room transitions restore normal dark lighting in paired/return captures. Tan rectangle replaced by painted threshold, secret remains concealed before jar. Existing unrelated Mirror Shade circle placeholders remain intentionally parked.

Art22 PASS; hidden_seam/sprite_visual/route_cave_5 all3 suites PASS; lint PASS. Exact runtime hidden_seam all animation/frame texture loads PASS. All preexisting manifest/runtime records semantic-equal; every old sprite PNG SHA256 byte-identical against /tmp/hidden-seam-before.json. No actor/core/room/flag/physics/normative/source edits or import. Foreign77 staged paths and shared provenance unchanged. Explicit owned-path commit, no push.

## Exact recipe and runtime interface

```json
{
  "kind": {
    "cell": [
      128,
      128
    ],
    "align": "foot",
    "foot": 122,
    "prop": true,
    "rect_h": 96
  },
  "scale": {
    "measure": "fit",
    "value": [
      116,
      110
    ],
    "ref": [
      {
        "sheet": "hidden_seam_v1",
        "row": 1
      }
    ]
  },
  "sheet": {
    "key": "magenta",
    "rows": [
      {
        "poses": 1,
        "outputs": []
      },
      {
        "poses": 3,
        "outputs": [
          {
            "kind": "hidden_seam",
            "anim": "idle",
            "file": "hidden_seam_idle",
            "poses": 2,
            "scale": "hidden_seam",
            "fps": 1,
            "loop": true
          },
          {
            "kind": "hidden_seam",
            "anim": "revealed",
            "file": "hidden_seam_revealed",
            "poses": [
              0,
              3
            ],
            "scale": "hidden_seam",
            "fps": 6,
            "loop": false
          }
        ]
      }
    ]
  },
  "runtime": {
    "cell": [
      128,
      128
    ],
    "anchor": [
      64.0,
      122
    ],
    "foot": 122,
    "mirror_side": false,
    "prop": true,
    "rect_h": 96,
    "animations": {
      "idle": {
        "file": "res://assets/sprites/hidden_seam_idle.png",
        "frames": 1,
        "fps": 1.0,
        "loop": true
      },
      "revealed": {
        "file": "res://assets/sprites/hidden_seam_revealed.png",
        "frames": 3,
        "fps": 6.0,
        "loop": false
      }
    }
  }
}
```
