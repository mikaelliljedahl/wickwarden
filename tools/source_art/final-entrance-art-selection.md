# Final entrance and terrain art selection

Runtime aliases follow `RoomDoor.entrance_kind()` at c065bc5. Source sheets remain untouched. Inventory cells: P14 192x192, ledge 96x96, pit texture 384x384. Existing cutter only; no edge-strip publication.

All entrances use pose 1 (open), because the runtime reveals traversable entrances rather than animating a closed door. First pose of ledge is straight, never the corner. Foot anchors use the established prop convention (cell height minus 6).

| Runtime key | Existing source | Row / pose | Anchor | SHA256 |
|---|---|---|---|---|
| `ledge_drop` | `ledge_drop_v3.png` | 0 / 0 | 48, 90 | `183812707e26f701b587f9ade1539492e5cfbf9f36f252f959ac3ad11cb2eaa6` |
| `pocket_stall` | `pocket_stall_v1.png` | 0 / 1 | 96, 186 | `3790305131fd5df17ece88188250464edb78d7fa724232c778b6e7b531fdb535` |
| `pocket_hut` | `pocket_hut_door_v1.png` | 0 / 1 | 96, 186 | `8af22c71763a6f8eb99379c77ee62943e33c36c18b978e602e27128953b86e7d` |
| `pocket_lighthouse` | `pocket_lighthouse_door_v1.png` | 0 / 1 | 96, 186 | `849e08c295c733b641db0daedc67d47c0a32093f57890c5f056f20a70f852505` |
| `pocket_grotto` | `pocket_grotto_v1.png` | 0 / 1 | 96, 186 | `e1507a1bd3e8be592b7069920deee62d83901048401042b79730e2622047d016` |
| `pocket_stairs` | `pocket_stairs_down_v1.png` | 0 / 1 | 96, 186 | `e84a8796fda1bae1c1fce06f932cfd1253adf411d3239183bbf9a2ce021456bc` |
| `pocket_plain` | `pocket_plain_door_v1.png` | 0 / 1 | 96, 186 | `5b6ed44075535504edd14d702727d306b3d3efcc29d409c4dc19d19b87bdfc2e` |
| `pit_fill` | `pit_fill_v1.png` | 0 / 0 | 192, 192 | `564826f08af93e138b4d056d964fb46f3f8dced9fce3640e20c8b8c04d01a7f4` |

Selection: v1 P14 props share warm ochre lamps, grey stone and restrained foliage. Stall v1 has a clear open counter; hut v1 a readable timber door and thatch; lighthouse v1 the least heavy stone surround (all variants retain the recorded square-base weakness); grotto v1 has the clearest dark open passage; stairs v1 has unobstructed descending steps; plain v1 has the simplest stone arch (the recorded ornamentation remains). Ledge v3 has the cleanest continuous lip and restrained foliage. Pit v1 has the darkest cool void and no warm cloud patches.

Comparison opened: `/tmp/final-entrance-comparison.jpg`, `/tmp/props-audit-candidates-1.jpg`, `/tmp/props-audit-candidates-2.jpg`. These aliases do not change generic door_marker or existing house art. Embedded painted house doors remain the runtime alignment owner’s responsibility.

Verification: `make art-test`, targeted Godot suites `sprite_visual gated_room_doors interactables world_zone_visual static_prop_visual`, and `make lint` passed. Temporary capture harness loaded all eight runtime textures and verified the seven sprite kinds (pit_fill is a texture, so has_art is intentionally false). Every preexisting runtime entry compares equal and every preexisting committed sprite PNG compares byte-for-byte equal to HEAD. The cutter's texture metadata rebuild was preserved by regenerating existing texture records into a temporary output directory and taking its generated sprites.json; existing PNGs were not rewritten.

Opened output proofs `/tmp/final-entrance-proofs.jpg` and actual runtime captures `/tmp/final-art-revealed-ow_0_2.png` (revealed stair entrance), `/tmp/final-art-ow_4_2.png` (three 96px ledge tiles over 288px), `/tmp/final-art-ow_9_5.png` (painted pit). Capture-only harness calls existing reveal hooks and removes the grotto reed blocker; no runtime scripts or source geometry are changed. Captures may retain known exit cleanup resource warnings and the missing future ow_9_6 room warning.

## Wickling body continuation

B15 existing source `wickling_v3.png`, SHA256 `2efc07fe68ece1b4391a8899bef4f8fc3dca0765965488b0f42f6732932136ca`; original provenance remains in `log_b15.md` (job `job_01a16f538c5379c18de25cb3f48bdb47`). Opened all three variants in `/tmp/wickling-source-comparison.jpg`. V3 has the most consistent run/pause body proportions, restrained upright flame and clear separated limbs; v1 has a smaller pause body and stronger sideways flame/sparks, v2 has the logged distant sparks weakness. All five v3 figures are contained and separated. Source bytes unchanged.

Binding cell 96x96, foot 88; actual BODY_RADIUS 16 gives runtime anchor [48,72]. Row 0 four run poses publish as `walk` (8fps loop); row 1 pause publishes as `idle` (1fps loop), matching SpriteVisual automatic motion names. One shared fit factor over all five poses, with 6px cell inset, preserves body scale across the rows and leaves the flame inside the foot-aligned cell. Existing cutter only, no source edits or runtime/combat changes.

Wickling validation: `make art-test` (20 tests), `make test T='wickling sprite_visual'` (both suites) and `make lint` pass. Opened `tools/source_art/proofs/wickling_v3_proof.png`, both generated strips, and actual `cave_1_3` capture `/tmp/wickling-cave_1_3.png`. Also opened `/tmp/wickling-cave_1_3-lit-proof.png`: same actual room and both bodies with capture-only ambient light override so their painted silhouettes can be inspected. Temporary capture harness asserts two live Wicklings use SpriteVisual, walk has four frames, idle one frame, textures load and body offset is [-48,-72]. Existing cave darkness is unchanged. Normal capture retains exit resource cleanup warnings; lit capture has no script/draw errors. Every prior runtime entry, all prior sprite PNG bytes (including eight final entrance/terrain keys), and all three raw Wickling source variants compare unchanged with the pre-task baseline/HEAD. No provenance edits.
