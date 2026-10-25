# Mirror Shade production mapping — conditional alpha renderer — 2026-10-25

Accepts B16 source ALPHA and facings ONLY under mandatory M5 renderer d28ec6d (verified ancestor). Binding monsters-bosses-tools.md:122 flat dark faceless silhouette is satisfied by the committed actor shader, not by an owner exception or modified source. The raw down/up sources retain pale internal scarf/bag/boot seam RGB; those would be visible WITHOUT the shader. Never use these raw strip colors as accepted standalone Mirror Shade art. Actor d28ec6d applies same alpha-only dark fill/faint alpha-derived outline to real AND decoy, preserves existing color/flash/alpha modulation. No source/cutter flattening, no manual image editing, no new generation. Initial hold lifted only after all6 shaderproof images were REOPENED and accepted visually.

Exact same entries/strips/animation semantics for mirror_shade and mirror_shade_decoy. Shared commonheight140 across all12 sourceposes; cell192x192 foot176 radius28 anchor96,148, mirror_side:true. walk_down/up/side4@8fpsloop, idle_down/up/side1 firstframe@8loop. Four stored frames repeat approximately1≈3 and2≈4: honest TWO-POSE gait, not four distinct steps. No fade_in, echo_swing or decoy_crack art published. Existing actor controls fade/echo mechanics and jar/copy retirement. Identical shared6 PNGs avoid painted-real/geometric-decoy unfairness.

Reviewed actual source/raw and cutter proofs in prior review, exact /tmp/wickwarden-mirror-review/review_manifest.json commonheight140 retained. ReOPENED /tmp/wickwarden-mirror-shader-proof/{body_grid,body_grid_flash,body_grid_tint,c5_unlit,c5_jar,c5_retired}.png before integration. After production map, actual root-project GPU render using DEFAULT production SpriteVisual manifest, no override: /tmp/mirror-production-proof/{same6names}.png ALL OPENED. The temporary /tmp/mirror-production-proof.gd copies existing M5 proof harness, uses isolated XDG_DATA_HOME, SaveGame.disabled/launchdev, unfocusable minimized window, Dummy audio. Actual World cave_5_1: two real/shade pairs at mirrored y coordinates, both material present; unlit pairs silhouettes, real player.use_item GlowJar yields both decoys visible=false with existing jar tint, actual kill() retires both decoy nodes (weakref null assertions). Retired capture is actor retirement, NOT jar expiration. Twelve-pose body/flash/tint GPU grids show no interior linework and uniform dark fills with soft alpha-derived edge; tint makes them intentionally faint. Ordinary dark-room visibility unchanged, no lighting/gameplay tweaks.

Art22 PASS; SpriteVisual/MirrorShade/route_cave_5 all3 focused suites PASS; lintPASS; exact2keys/allanimations/alltexturesloadPASS. All prior manifest/runtime records semantically identical and every old PNG SHA256 byte-identical vs /tmp/mirror-production-before.json. Original raw bytes and historical B16 origin records unchanged; source original model history not inferred. Foreign77 staged paths untouched. No actor/core/scene/normative edits, no push.

## Exact source origin and raw SHA256

- `tools/source_art/mirror_shade_walk_down_v1.png`: 3de1de49159fb167a61fdc528376a8b546567224f92f71928a689068cea70ac9
  Historical tools/source_art/log_b16.md entry: - `mirror_shade_walk_down_v1.png` (1536x1024, job `job_01a16f5bfab67564894adf6e10338de3`, session `01a16f5c-0201-7360-a912-b2c8c6f8889e`, output `exec-ca2f3f26-007c-49aa-80aa-0a9eaf0b7cc7`, sha16 `3de1de49159fb167`): ok: flat silhouettes, four separate poses on one baseline, pale edge
- `tools/source_art/mirror_shade_walk_up_v1.png`: 8dfe731a142d4f23a59fee813190713e38d0b2062c87892f99066f4d272f1b45
  Historical tools/source_art/log_b16.md entry: - `mirror_shade_walk_up_v1.png` (1536x1024, job `job_01a16f5c12a37673b8007f497fcabb92`, session `01a16f5c-56b1-72b0-acd9-15ae397317e3`, output `exec-170ba681-bc41-4989-a661-f85be4ebc44d`, sha16 `8dfe731a142d4f23`): weak: faint internal seam lines and slight blue shading inside the silhouettes
- `tools/source_art/mirror_shade_walk_side_v3.png`: 56137c2065a0eab3fa6e1799374fc2de61246444d7b9ec6e7098cc8cf35d9700
  Historical tools/source_art/log_b16.md entry: - `mirror_shade_walk_side_v3.png` (1536x1024, job `job_01a16f598d4d7f43951c7e0fa2a56e4c`, session `01a16f59-92c0-7b40-aa80-2791944a434b`, output `exec-3b6e091f-2425-4f0b-8c20-e22ddfd18d4a`, sha16 `56137c2065a0eab3`): weak: flat silhouette with pale outline holds (retry 1); poses 1 and 3 and 2 and 4 look alike

## Exact recipe and interface

```json
{
  "kinds": {
    "mirror_shade": {
      "cell": [
        192,
        192
      ],
      "foot": 176,
      "radius": 28,
      "mirror_side": true
    },
    "mirror_shade_decoy": {
      "cell": [
        192,
        192
      ],
      "foot": 176,
      "radius": 28,
      "mirror_side": true
    }
  },
  "scale": {
    "measure": "height",
    "value": 140,
    "ref": [
      {
        "sheet": "mirror_shade_walk_down_v1",
        "row": 0
      },
      {
        "sheet": "mirror_shade_walk_up_v1",
        "row": 0
      },
      {
        "sheet": "mirror_shade_walk_side_v3",
        "row": 0
      }
    ]
  },
  "sheets": {
    "mirror_shade_walk_down_v1": {
      "key": "magenta",
      "rows": [
        {
          "poses": 4,
          "outputs": [
            {
              "file": "mirror_shade_walk_down",
              "kind": "mirror_shade",
              "anim": "walk_down",
              "scale": "mirror_shade",
              "fps": 8,
              "loop": true
            },
            {
              "file": "mirror_shade_idle_down",
              "kind": "mirror_shade",
              "anim": "idle_down",
              "scale": "mirror_shade",
              "fps": 8,
              "loop": true,
              "poses": 0
            },
            {
              "file": "mirror_shade_walk_down",
              "kind": "mirror_shade_decoy",
              "anim": "walk_down",
              "scale": "mirror_shade",
              "fps": 8,
              "loop": true
            },
            {
              "file": "mirror_shade_idle_down",
              "kind": "mirror_shade_decoy",
              "anim": "idle_down",
              "scale": "mirror_shade",
              "fps": 8,
              "loop": true,
              "poses": 0
            }
          ]
        }
      ]
    },
    "mirror_shade_walk_up_v1": {
      "key": "magenta",
      "rows": [
        {
          "poses": 4,
          "outputs": [
            {
              "file": "mirror_shade_walk_up",
              "kind": "mirror_shade",
              "anim": "walk_up",
              "scale": "mirror_shade",
              "fps": 8,
              "loop": true
            },
            {
              "file": "mirror_shade_idle_up",
              "kind": "mirror_shade",
              "anim": "idle_up",
              "scale": "mirror_shade",
              "fps": 8,
              "loop": true,
              "poses": 0
            },
            {
              "file": "mirror_shade_walk_up",
              "kind": "mirror_shade_decoy",
              "anim": "walk_up",
              "scale": "mirror_shade",
              "fps": 8,
              "loop": true
            },
            {
              "file": "mirror_shade_idle_up",
              "kind": "mirror_shade_decoy",
              "anim": "idle_up",
              "scale": "mirror_shade",
              "fps": 8,
              "loop": true,
              "poses": 0
            }
          ]
        }
      ]
    },
    "mirror_shade_walk_side_v3": {
      "key": "magenta",
      "rows": [
        {
          "poses": 4,
          "outputs": [
            {
              "file": "mirror_shade_walk_side",
              "kind": "mirror_shade",
              "anim": "walk_side",
              "scale": "mirror_shade",
              "fps": 8,
              "loop": true
            },
            {
              "file": "mirror_shade_idle_side",
              "kind": "mirror_shade",
              "anim": "idle_side",
              "scale": "mirror_shade",
              "fps": 8,
              "loop": true,
              "poses": 0
            },
            {
              "file": "mirror_shade_walk_side",
              "kind": "mirror_shade_decoy",
              "anim": "walk_side",
              "scale": "mirror_shade",
              "fps": 8,
              "loop": true
            },
            {
              "file": "mirror_shade_idle_side",
              "kind": "mirror_shade_decoy",
              "anim": "idle_side",
              "scale": "mirror_shade",
              "fps": 8,
              "loop": true,
              "poses": 0
            }
          ]
        }
      ]
    }
  },
  "runtime": {
    "mirror_shade": {
      "cell": [
        192,
        192
      ],
      "anchor": [
        96.0,
        148.0
      ],
      "foot": 176,
      "radius": 28.0,
      "mirror_side": true,
      "animations": {
        "walk_down": {
          "file": "res://assets/sprites/mirror_shade_walk_down.png",
          "frames": 4,
          "fps": 8.0,
          "loop": true
        },
        "idle_down": {
          "file": "res://assets/sprites/mirror_shade_idle_down.png",
          "frames": 1,
          "fps": 8.0,
          "loop": true
        },
        "walk_up": {
          "file": "res://assets/sprites/mirror_shade_walk_up.png",
          "frames": 4,
          "fps": 8.0,
          "loop": true
        },
        "idle_up": {
          "file": "res://assets/sprites/mirror_shade_idle_up.png",
          "frames": 1,
          "fps": 8.0,
          "loop": true
        },
        "walk_side": {
          "file": "res://assets/sprites/mirror_shade_walk_side.png",
          "frames": 4,
          "fps": 8.0,
          "loop": true
        },
        "idle_side": {
          "file": "res://assets/sprites/mirror_shade_idle_side.png",
          "frames": 1,
          "fps": 8.0,
          "loop": true
        }
      }
    },
    "mirror_shade_decoy": {
      "cell": [
        192,
        192
      ],
      "anchor": [
        96.0,
        148.0
      ],
      "foot": 176,
      "radius": 28.0,
      "mirror_side": true,
      "animations": {
        "walk_down": {
          "file": "res://assets/sprites/mirror_shade_walk_down.png",
          "frames": 4,
          "fps": 8.0,
          "loop": true
        },
        "idle_down": {
          "file": "res://assets/sprites/mirror_shade_idle_down.png",
          "frames": 1,
          "fps": 8.0,
          "loop": true
        },
        "walk_up": {
          "file": "res://assets/sprites/mirror_shade_walk_up.png",
          "frames": 4,
          "fps": 8.0,
          "loop": true
        },
        "idle_up": {
          "file": "res://assets/sprites/mirror_shade_idle_up.png",
          "frames": 1,
          "fps": 8.0,
          "loop": true
        },
        "walk_side": {
          "file": "res://assets/sprites/mirror_shade_walk_side.png",
          "frames": 4,
          "fps": 8.0,
          "loop": true
        },
        "idle_side": {
          "file": "res://assets/sprites/mirror_shade_idle_side.png",
          "frames": 1,
          "fps": 8.0,
          "loop": true
        }
      }
    }
  },
  "png_sha256": {
    "assets/sprites/mirror_shade_idle_down.png": "9cdd4a69d1f48f206f2865e6b4b5cb72729f6338321a8415c22779f3557124a2",
    "assets/sprites/mirror_shade_idle_side.png": "fc3ec69a5c3fda50ed8164837899bbfe342db7315ac0dd887569ae7b9d6c44bb",
    "assets/sprites/mirror_shade_idle_up.png": "9e071c582cf5ce334fd06e128a3ec41d21feab474f567ffd2482b8e594870ec4",
    "assets/sprites/mirror_shade_walk_down.png": "afb6be23a33a4ecd3eababc0bff3dac62c6fc3de85c7d99c9f051579c10bbfbb",
    "assets/sprites/mirror_shade_walk_side.png": "af8767d95f3b5acf5e2efa69738dce79bb7b19a1436af82235165a44bbb09d3a",
    "assets/sprites/mirror_shade_walk_up.png": "dd05f85e59dfd8301840b174f391b92e0edfb58d4313b8b4ce21f0e772f8eed0"
  }
}
```
