# Art production progress, producer d (batches 28 to 35)

Range: batches 28 to 35 only (`docs/art-inventory.md` section 4). Prompts: `batch_28.md` to `batch_35.md`, generated from the shared block and sheet block of `batch_01.md`. Invented details: `DESIGNS_d.md`.

Facing and leg fix (from `PROGRESS.md`): applied to the statue sheets (`statue_figure_1`, `statue_figure_2`, `statue_eye`), which face the viewer square on. No walk-like character is in this range.

| Batch | Units | Images | Status |
|---|---|---|---|
| 28 | sealed_seam, hook_tap_wall, grate, boss_door, ninth_door, wax_seal | 18 | done: generated, verified, logged (`log_b28.md`), provenance rows added; wax_seal (3) weak: melt drips read as blood |
| 29 | reed_cluster, rush_wall, moss_wall, dry_vine_screen, bush_cluster, brittle_rocks | 18 | done: generated, verified, logged (`log_b29.md`), provenance added; dry_vine_screen (3) and bush_cluster (3) weak: posts or halves split the cut poses |
| 30 | pocket_stall, pocket_cart, pocket_lighthouse_door, pocket_mason_door, pocket_hut_door, pocket_grotto | 18 | done: generated, verified, logged (`log_b30.md`), provenance added; lighthouse door (3) weak: square base, not round; mason door v3 weak: carving reads like a numeral |
| 31 | pocket_stairs_down, pocket_plain_door, shop_counter, ward_plate, street_lamp, wall_torch | 18 | done: generated, verified, logged (`log_b31.md`), provenance added; pocket_plain_door (3) weak: too ornate for a plain door |
| 32 | pillar_1, pillar_2, pillar_3, lectern, statue_eye | 15 | done: generated, verified, logged (`log_b32.md`), provenance added; pillar_1 (3) weak: ivy on a plain pillar; pillar_2 v2 weak: flame on the wick; pillar_2 v3 and pillar_3 v2 each needed a second job after a null reference failure |
| 33 | statue_figure_1, statue_figure_2, crate_stack_1, crate_stack_2, crate_stack_3, cold_furnace | 18 | done: generated, verified, logged (`log_b33.md`), provenance added; statue_figure_1 v3 weak: cane and heavy overgrowth; cold_furnace v1 and v2 weak: door glows amber |
| 34 | anvil, slag_heap_1, slag_heap_2, glass_shards_1, glass_shards_2 | 15 | done: generated, verified, logged (`log_b34.md`), provenance added; slag_heap_2 v1 ok; glass shards read as crystal more than fused glass (kept); anvil v3 needed a second job after a wrong-prompt failure |
| 35 | dead_tree_1, dead_tree_2, thorn_bramble_1, thorn_bramble_2, fallen_log, root_bridge | 18 | prompts written |

Wave rule: at most 6 Codex jobs at the same time, one image per job, model `cheapest`, idempotency key `ww-bNN-<sheet>-vN-rK`.
