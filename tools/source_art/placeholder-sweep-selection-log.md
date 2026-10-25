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

## Batch 2: existing-source static presentations

All 51 variants were opened as 17 comparison contacts (`/tmp/select-<stem>.jpg`). Detailed comparison notes and hashes: `/tmp/placeholder-source-selection.md`. Runtime APIs already select these kinds through SpriteVisual, including the EnemyBase path. Only idle/static subsets are published; current color/visibility cues and mechanics remain intact.

| Kind | Exact source and SHA-256 | Selection reason |
|---|---|---|
| `thorn_hedge` | `thorn_hedge_v1.png` / `70e7e120764e64a60a3a631dd9851e42be9cfcc610aba828c202d3a758d911f0` | v1 has the clearest interwoven woody barrier and broad closed silhouette; v2 is smaller and rounder, v3 busier. Burning smoke is magenta-adjacent; do not use burning row for this static integration. |
| `thorn_door` | `thorn_door_v1.png` / `cbfd8c876f56f078acec285d9e16e46dc208b31c61918f906ec0d4f5bc8c216e` | v1 has a legible wooden door, lock and diagonal thorn binding; v2 is squat and v3 has a more confused mesh. Flames/smoke are irrelevant to the closed state. All closed silhouettes are inside the canvas. |
| `bramble_snapper` | `bramble_snapper_v3.png` / `fac6ae08f4b2e655f019527c8febba033d006f8129b363f378a6cbebf44dcf13` | v3 idle jaws are more nearly closed and read as a rooted biter; v1 idle already looks mid-bite, v2 has loose thorn fragments in snap row. Idle poses are similar. No obvious clipped idle thorns. |
| `fen_leech` | `fen_leech_v1.png` / `de346197c727d7f028b7709a79a4d8b444d5ce05359fac199d831adb25bca9b2` | v1 surfaced idle is a clear right-facing long leech; v2 mouth reads as an open tube, v3 turns toward viewer. All have painted ripples/pale water and bright tail light: retained defects, not removable background. No obvious selected-pose crop. |
| `watcher_eye` | `watcher_eye_down_v1.png` / `ebebd2235547ffdb8fe625f3db25d87b3f4398af2a40b6560df9eae55e66d2e3` | v1 mount is readable and consistent with side v1; v2 is a good alternate, v3 has busy foliage. Closed lid only: runtime has glow/invulnerability but no lid animation selection. Fire poses paint a horizontal bolt even on down/up sheets; do not use them. |
| `grate` | `grate_v2.png` / `39dba09cdf7205cc735d10d3f3474e4126bdcfcf4d1601425613fe1f055a35fb` | v2 has the clearest iron bars and dark gaps; v1 has a heavier uneven arch, v3 softer bars. Select first pose only: second bakes a key into the alcove and would duplicate or misrepresent the real pickup. Dark backing is painted opaque, not key. |
| `heavy_stone` | `heavy_stone_v1.png` / `ab1d3007360faee56b169518668ed0be176ddc8b033b419e3f69cfec7ee20a68` | v1 squat cracked stone is clearest as a heavy movable block; v2 warmer/busier, v3 narrower/taller. Lifted pose has pink dust/key risk in all, especially v2; static sitting pose avoids it. |
| `hidden_stairs` | `hidden_stairs_v1.png` / `41bbf3db797a19e27a8b0d0f920e0ec404de1dd3ff1ebea8fae554ca93e5a234` | v1 final revealed pose has the clearest dark descending stairwell; v2 is warmly lit and v3 has shallow, oblique steps. Never select row 0 sealed slab: runtime hides Visual until revealed, then displays default art without changing animation. |
| `pot_bag` | `pot_bag_v1.png` / `a0764cdd0fc1f71609376447d5c2b86dcc0fa4ae588e475a858bff88e6aa5f66` | v1 simple warm pouch and drawstring reads at 64px; v2 has stronger highlights, v3 dark mottling and more hardware. First pose has no glint. Does not visibly contain pots, an existing semantic limitation. |
| `slug_bundle` | `slug_bundle_v1.png` / `ccb0ca57e4d71049f927a6cc8a8d1e8dab16e456ccf1ddfcce7e9db3c91f3682` | v1 pale wax cylinders and binding remain distinct at small size; v2 more gold than wax, v3 lumpy stones. First pose avoids sparkle. No visible edge failure. |
| `tallow_flask` | `tallow_flask_v2.png` / `7b6b95fe6817257207f377adc9b636f19f30959e5de6957ca6b9c1d131bb93a8` | v2 corked heart flask conveys a consumable more clearly than v1 lantern cap; v3 slightly duller glass. Transparent glass is painted over magenta: internal key contamination remains a proof-check risk, not a claim of clean alpha. |

Watcher additional facings: `watcher_eye_up_v1.png` SHA-256 `875d803aefef9a6a39439a742358b1a43aa442166bae916f53cfeb13cb0e56ed`; `watcher_eye_side_v1.png` SHA-256 `2f2d6e0ea66e2c90e03cc5f2056ae6e70f7226b90763eac675c402d793ca8acb`. All three use one shared factor from the down closed pose. Closed default mount preserves existing glow/invulnerability cues; no state-specific lid animation is introduced. Existing up-view weakness remains.

All sources already have generation provenance. No alias source copies, new images or raster edits. Props retain contract cells and use foot rows six pixels above the cell bottom, following existing prop records; these prop feet are implementation choices, not newly normative dimensions. Creature feet are 176, pickup feet 58; watcher is centred with no foot line. Hidden stairs select row 1 pose 2 (revealed stairwell), and visibility remains governed by HiddenSeam. Grate selects the first pose without a baked-in key.

Thorn door needed the existing cutter parameter `band_floor=0.9` with `min_gap_y=1` to separate smoky rows; this affects band detection only and preserves soft rendered alpha. The first two trial cuts failed closed on row count and published nothing for that source. Snapper output reports a two-pixel horizontal slide to fit the existing cell; no clipping or destructive scaling.

Accepted source limitations: tallow flask remains heart-shaped (best available v2), leech includes painted water and a bright tail, watcher up/open/fire directions are imperfect, unused burning/occupied/lifted poses have known defects. These are existing-source defects, not a claim of missing source art.

## Batch 3: art for scoped presentation wiring

The parent assigned the seven direct-placeholder entity scripts to a separate presentation worker. This pipeline task does not modify those scripts. The following mappings support that worker's SpriteVisual calls. All three variants of each source were opened in the same comparison set as batch 2.

| Kind | Exact source and SHA-256 | Reason |
|---|---|---|
| `mooring` | `mooring_v1.png` / `df92cf7fad956a2391376fe977ab3ca147dbd5a0e0edecb7a23119b387ceedae` | v1 idle post has simpler rock base than v2 and less foliage than v3; ring and rope are readable. ALL three occupied pose ropes hit the right canvas edge. Reject occupied pose, retain idle pose 0 only; idle rope fully contained. |
| `eye_switch` | `eye_switch_v3.png` / `943680055ea6088eba7decd8104d95e6e02c643f9b12736f8af7c16def778f3c` | v3 closed eye in squat stone mount has clean silhouette; v1 is tall with oversized on-eye, v2 more foliage and perspective skew. On state requires separate eye_switch_on kind from pose 3. No obvious crop; fine vegetation can carry magenta fringe. |
| `eye_portcullis` | `eye_portcullis_v1.png` / `84a4b04f790e72f9baedf9f048d62b17a0583adfae29cc658bf421ee20bac791` | v1 has clean discrete bars and key-colour gaps; v2 similar but heavier base, v3 closed gap/backing is muddy and partly filled. Opening/open art unnecessary because runtime hides blocker when open. |
| `ward_plate` | `ward_plate_v3.png` / `c8f4da9b4e98b368ffc3ceab472719bddbafd64ed03ef4f586e3e06fd3e56c93` | v3 compact flat pad has the clearest lantern emblem with restrained surrounding stones; v1 and v2 bases are busier. Lit glows are unused: script never switches look on satisfaction. Foliage fine edges need proof review. |
| `ward_blocker` | `eye_portcullis_v1.png` / `84a4b04f790e72f9baedf9f048d62b17a0583adfae29cc658bf421ee20bac791` | No dedicated ward_blocker source or inventory cell exists. Best existing-art alias is the selected closed portcullis: solid gate silhouette without an eye emblem. Shares exact source with eye_portcullis, not ward_plate. Alias cell/foot are inherited implementation recommendations, not a newly normative size. |

Eye on-state uses eye_switch_v3 row 0 pose 3 and the same factor as off, kind `eye_switch_on`; source and provenance are shared. Ward blocker uses the closed portcullis artwork as a presentation alias (no eye emblem), without a new source copy or image. Mooring occupied pose is explicitly excluded because its rope reaches the source edge. No failing terrain edge source is published. Four trial proofs were opened in `/tmp/sweep-batch3-proofs/`; actual combined-tree captures opened: `/tmp/sweep-batch3-eyegate.png`, `/tmp/sweep-batch3-ward.png`, `/tmp/sweep-batch3-mooring.png`. All four targeted suites passed (sprite_visual, mooring, eye_switch, ward_plate).

## Comprehensive inventory and residuals

Baseline was captured 67/67 and visually opened as all six contacts plus 16 individual problem rooms. Full per-room/per-instance evidence: `/tmp/placeholder-runtime-inventory.md` and `.json`; capture review: `/tmp/placeholder-baseline-report.md`; frozen exact scene list: `/tmp/placeholder-baseline/frozen-scenes.json`. These distinguish placed initial-state nodes from transient combat/tool states. Source folder contained 1461 PNGs. Initial placed census: 861 SpriteVisual nodes and 164 Placeholder nodes. Pipeline batches 1+2 remove 52 initial fallback placements without entity edits. Batch 3 supplies art for another 47 placements after the separately owned mooring/eye/ward wiring lands.

Classification and remaining scope:

1. **Source exists but uncut/unmapped:** source sheets for transient beam_bolt, later item actions/vehicles and player tool poses still exist without complete runtime mapping. RoomDoor uses cave_mouth for 26 built entrances, including generic pocket doors; alternative pocket door sources exist. Requires separate presentation mapping/state work; no room geometry or compiler change is proposed.
2. **Actual source absent:** no proven new image requirement for the placed baseline. Dedicated names deep_water/shallow_water/ravine/ward_blocker do not imply missing art: existing terrain/barrier candidates exist. Ward blocker now uses the explicit portcullis alias. Edge strips remain blocked by source aspect/contract/cutter limitations; do not publish or resize them ad hoc.
3. **Deliberate procedural visuals:** debug hitboxes/overlay, mooring ride-path line, contact shadows, pond/ruin union shaders, hook/flare/ward arcs and enemy telegraph rings are intentional. Leech bubbles/ripples and impact sparks remain state cues; do not hide them through a global Placeholder change.
4. **Geometry/scale coverage:** historical gate and locked door alpha widths are 137/138px against 192px collision; ordinary reeds have narrow 77px plants on 96px solid footprints. New grate has a binding 128px cell against the built 192px footprint, so its painted slab remains narrower than its blocker. Actual grate capture keeps the real key visible. These need a scoped geometry-aware presentation decision; existing working art was not repainted, stretched beyond its cell or given new collision. Pocket terrain still uses outdoor floor/border dressing.

The 65 initial water/ledge/pit fallbacks (44 deep water, 18 shallow water, 2 ledge, 1 ravine) require the separately owned geometry-aware presentation worker; a static sprite alias cannot cover arbitrary footprints. Full exact placement list before that worker: `/tmp/placeholder-residual-after-batch2.json` (112 nodes also including the 47 mooring/eye/ward nodes now supported by batch 3). Do not call these final residual placeholders without rerunning against the worker's landed code.

After captures: all same 67 frozen paths in `/tmp/placeholder-after-batch2/`; shared scripts changed during this run, so early images are batch2-only and later images show combined work. The three explicit batch3 captures above are newer and authoritative for those kinds. New cave outputs were excluded throughout. Hidden stairs remain invisible before reveal; an additional revealed-state visual check is requested from capture review.

Mechanical parity evidence: `/tmp/placeholder-collision-proof.json`, `.gd`, `.log` PASS 24 cases for rush_wall/reed_cluster with real versus empty manifest across hook/flare/explosion/fire/sling/contact. Identical radius34 WORLD bodies and radius48 Hurtboxes; accepted cut kinds remove them exactly once, other hit kinds leave them intact. No collision, state, flags or timing code was edited by this pipeline task.

Final opened supplementary captures: `/tmp/sweep-supplement-ow_0_2.png` shows revealed stairs after calling the existing reveal API in memory; normal baseline/after room capture has no visible stair art. `/tmp/sweep-supplement-ow_1_3.png` shows the leech in its existing surfaced state over the newly painted shallows. All six after contact sheets were opened, covering the frozen 67 rooms. No save file was written.

Final combined-tree checks: `make art-test` 20 tests passed; `make check` 78 Godot suites, lint and 116 Python tests passed (`/tmp/sweep-final-{art-test,check}.log`). These include separately landed presentation work and are not an isolated pipeline-only test. Original 58 manifest entries at batch-1 checkpoint remain semantically unchanged, and no preexisting sprite PNG changed. Generated `.import` companions are left for the integration owner alongside inherited import files.

A fresh 67-room census after separately landed `607fae0` and `c065bc5` reports 938 SpriteVisual, 65 geometry-aware Visual nodes and 22 Placeholder nodes. Every remaining placed fallback is now `door_marker` on pocket RoomDoor nodes, introduced by target-specific entrance selection whose art mappings are not yet present. This is a separate coordinated mapping dependency, not a new-image requirement or a failure of the accepted prop sources. Exact fresh nodes: `/tmp/placeholder-final-runtime.json`; harness/log `/tmp/placeholder-final-inventory.{gd,log}`. Parent was notified before this pipeline commit. The earlier baseline and projected residual reports remain historical snapshots.
