# Decisions log

Date: 2026-10-24
Owner: Mikael Liljedahl (project owner)

These decisions are binding. The project owner made them on 2026-10-24.

## World plan (docs/world-plan.md section 7.1)

1. Cave 9 is Corrow's workshop, a cave without a lantern. Caves 1-8 hold lanterns. Cave 10 is the Ninth Hollow.
2. The Ninth Door needs all nine lantern fragments.
3. Small keys belong to one cave each. Keys are scoped per cave.
4. Each of the two pot bags adds 4 to the pitch pot limit: 10, then 14, then 18.
5. The game has saves.
6. The sub-item picker is an item subscreen. It shows all items in a grid, like the Zelda item menu. `cycle_item` stays as a quick switch.
7. The wallet cap is 999 brass. Prices are set in playtests.
8. A few ward puzzles exist. All of them are off the main path (optional caches).
9. The tallow sling has limited ammo. Max is 30, start is 12, a slug bundle adds 6, and the drop chance is 8%. Shops S3-S5 sell a slug bundle. Pot bags do not change the sling limit.
10. The start is the north-west corner. The six dev rooms keep their ids.
11. The two one-way ledge drops stay. This is a small World change.
12. The final fight comes before the ending choice.
13. The tallow flask heals fully on purchase.

## Work packages (docs/world-work-packages.md open questions)

14. Build the `.room` compiler. Rooms are `.room` files that compile to scenes.
15. The 3 existing sealed spots stay in their rooms. The other 30 pockets get their own scenes.
16. There is one save slot. Autosave runs on room entry. Respawn happens at the last cave mouth or shop.
17. Add a JSON export filter when the first export preset is created.
18. Commit only 16 contact sheets of room captures. Do not commit the 218 full-size screenshots.
19. A short load hitch at a cave warp is acceptable.
20. The item subscreen opens with Tab. On gamepad it opens with Select.
21. The intro has no skip hint. Any confirm key or Esc skips it.
22. Ending: two lit lanterns with Corrow between them, no text. Credits are included.
23. Add "Back to title" to the pause menu.
24. A test suite may take a few minutes in CI.
25. Monster groups M1-M5 and MB1-MB5 are set once the monster file is final.

## Monster spec (docs/monsters-bosses-tools.md)

26. Minibosses in C4, C5 and C8 are fought with tools the player already holds: hook deflect, corner braziers, or a pot on the rail. They are not fought with the cave's own tool.
27. The cinder wick flame rolls up to 288 px. It can light far braziers. The plan said one tile.
28. For the remaining open questions in that file, agents choose the simplest solution. The agent notes the choice in the file.

## Art inventory (docs/art-inventory.md, docs/asset-contract.md)

29. Player animations: generate one facing (side, right). Up and down are generated only for the locomotion rows that are not symmetric (the walk-like mitts rows carry, push and pull). Code mirrors left from right. The existing `done` strips keep their three facings. `SpriteVisual` shows the side strip when a facing strip is missing.
30. Shop prices and counters: the digits are drawn in code with a font tinted brass. There is no numeral sheet (`ui_brass_digits` is removed).
31. Cave textures: three shared sets (brick, stone, root), each with ground, wall and wall face. Code tints them per cave. The per-cave texture rows (ground, wall, wall face and special for each of the ten caves) are removed. Per-region textures, cave-specific props and the boss arena paintings stay.
32. Watcher eye: three views are generated (down, up, side). The fourth wall uses the mirrored side view.
33. Creature hurt and death: hit flash by `modulate` plus the shared death effects (`fx_enemy_poof`, `miniboss_death_wax`, `fx_boss_death_light`, `fx_boss_death_wax`). No separate hurt or death poses for monsters, minibosses or bosses.
34. `docs/asset-contract.md` gets a terrain edge strip format for alpha overlays (region transitions, shore foam, pit rims, cave edges): cell 384 x 96 (corners 96 x 96), names `edge_*`, true alpha with no alpha threshold, a single-cell cut with no foot line. Opaque base tiles stay opaque. The cut tool code is not changed by this decision; it needs a separate task.
35. Remaining unclear points of the art inventory: the simplest option. The proposed sizes of minibosses, bosses and other large figures become a binding second cell-size table in the contract (floating bodies are anchored at the cell centre, with no foot line). The rekindle memory stills (`memory_c*`) and `npc_corrow_ghost` stay provisional. Two ending stills only, the optional villagers, the light textures and the backdrops stay as listed (optional items are generated last).

## Monster API changes (docs/monsters-bosses-tools.md section 7.2)

36. The four files that section 7.2 of `docs/monsters-bosses-tools.md` changes, `scripts/core/layers.gd`, `scripts/combat/hitbox.gd`, `scripts/enemies/enemy_base.gd` and `scripts/enemies/enemy_projectile.gd`, are owned by M0 (BossBase, wave 1), which lists them in its Owns. They must be merged before any wave 1 monster WP starts.
