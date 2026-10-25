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
