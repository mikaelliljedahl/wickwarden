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
