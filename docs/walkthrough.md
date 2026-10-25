# Wickwarden walkthrough

This source-checked guide gives a recommended route, not a recorded full playthrough. Room names come first; room IDs in parentheses help locate a room when reporting a problem.

## Contents

1. [Start, controls, and saving](#start-controls-and-saving)
2. [Quick reference](#quick-reference)
3. [Recommended overworld route](#recommended-overworld-route)
4. [C1: The Wick Cellar](#c1-the-wick-cellar)
5. [C2: The Briar Hollow](#c2-the-briar-hollow)
6. [C3: The Drowned Wick Works](#c3-the-drowned-wick-works)
7. [C4: The Sleeping Foundry](#c4-the-sleeping-foundry)
8. [C5: The Mirrored Archive](#c5-the-mirrored-archive)
9. [C6: The Choir Vault](#c6-the-choir-vault)
10. [C7: The Hall of Nerve](#c7-the-hall-of-nerve)
11. [C8: The Counting House](#c8-the-counting-house)
12. [C9: Corrow’s Undercroft](#c9-corrows-undercroft)
13. [C10: The Ninth Hollow](#c10-the-ninth-hollow)
14. [Spoilers: the final boss and endings](#spoilers-the-final-boss-and-endings)

## Start, controls, and saving

- Run `make run` for the normal game. At the title, choose **New** for a fresh game or **Continue** to load the save. A new game always plays the intro; press confirm, Lamp Hook, or Esc to skip it. Starting New over an existing save asks before erasing that slot.
- Run `make dev` only when you want the test setup. It skips the title and starts with the sub-items, 10 Pitch Pots, and 5 keys; F1 toggles hitbox drawing. Dev mode does not autosave.
- There is one save slot. Normal play autosaves on room entry and when persistent pickups are collected. Continue normally resumes the saved room; death returns you to your checkpoint, the last cave mouth or shop you reached. Death restores full health and keeps collected items, opened routes, and other saved progress.
- To check a binding, pause with Esc or Start. The pause screen lists the same controls below.

| Action | Keyboard | Controller |
|---|---|---|
| Move | WASD or arrow keys | Left stick |
| Lamp Hook | Space or J; hold to charge a flare | A; hold to charge |
| Use item | E or K | X |
| Ward | Shift or L; hold | RB; hold |
| Change item | Q or I | Y |
| Open item menu | Tab | Select |
| Equip highlighted item | Enter | A, while the item menu is open |
| Confirm a menu choice | Enter or Numpad Enter | A |
| Pause | Esc | Start |

Use the item menu to equip any tool you have found. Q/I or Y cycles the active item. Face the prop or direction you want to use. Ordinary cave and overworld exits are crossed by walking through them; there is no interact button for a doorway.

## Quick reference

| If you see… | Do this |
|---|---|
| Brass keyhole door | Before you find that cave’s Lockpick, walk into it with one small key of the same scope; the door consumes the key and stays open. After you find the cave’s Lockpick, it opens that cave’s ordinary keyhole doors without spending small keys. Overworld doors still need an overworld key. |
| A large cave boss door | Walk into it with that cave’s Lockpick. It opens and keeps the Lockpick, which also opens ordinary keyhole doors in that cave. |
| The Ninth Door at the end of the overworld | Hold all nine fragments from C1–C9, then walk into the door. |
| A permanent grate with a pickup behind it | Send the Tether Moth through the bars to bring the pickup back. The grate itself never opens. |
| Thorns | Cinder Wick burns a path through. Its short-lived flame is local; it does not light a whole dark room. |
| Cracked rock or wall | Place a Pitch Pot nearby and step clear; it explodes after 1.6 seconds. |
| Faint stairs or a wall seam | Throw the Glow Jar within its 520-pixel light radius to reveal it. The glow lasts 6 seconds, but a revealed opening stays revealed. |
| A deep-water lane between posts | Use the Reed Raft at a mooring and steer to the next post. On the raft, only Hook, Charge Flare, and Ward work. |
| Heavy stone or sliding door | Equip Heft Mitts and face the prop. For a liftable stone, tap Use Item to pick it up and tap Use Item again to throw it. For a push boulder or door, tap Use Item while facing it, then keep moving toward it; it slides one tile after about half a second. |
| A pit or ravine | Use Skitter Boots to leap up to 192 pixels in the facing direction and land on the far bank. |
| A resonance stone or door | Tap Use Item with the Lantern Chime equipped. Hold it to open the warp picker for cave mouths you have visited. |
| An anchor ring over a gap | Aim the Reel Line at the ring to pull yourself across. It does not create a bridge across an arbitrary pit. |
| An eye switch | Shoot it with the Tallow Sling. Hook swings do not activate it, and each switch costs one slug. |

Small keys stay within their scope: the overworld key is separate from C1, and a C4 key cannot open another cave’s locks. Before you find a cave’s Lockpick, use its small keys on ordinary locked doors; once you have that Lockpick, it opens both ordinary keyhole doors and the boss door in the same cave without being spent. It does not open locks in another cave or the overworld. In C1, collect the key behind the Grated Store grate, then the Lockpick in Ash Closet; because you have the Lockpick before reaching the ordinary door e151, it opens that door and preserves the small key. The same Lockpick opens the Kilnkeeper’s boss door (e152).

The Tallow Sling starts with 12 slugs, holds at most 30, and each slug bundle adds 6. The HUD shows the current count; check it before spending shots on optional switches. The main route has bundles in C2’s Overgrown Walk, C8’s Scale Room, and C10’s Eye Hall; shops S3–S5 also sell bundles.

## Recommended overworld route

This order collects each cave’s tool before the next route needs it. C9’s hidden entrance can be visited earlier, but completing C9 is smoother after C7 and C8.

1. **C1, Crossroads (ow_1_1).** From Brackwater Edge go south to Reedpond to meet the Tether Moth, then east from Reedpond to Crossroads and enter the open cave mouth.
2. **C2, Briar Mouth (ow_5_1).** Return to Crossroads, go north to Wickfield and east to Ruin of Ode. Burn the thorn hedge on the east exit with the Cinder Wick; continue east through Thorn Gate, Hedgerow, and Owl Clearing, then south to Briar Mouth. C1’s Wick is required.
3. **Get the Pitch Pot for C3.** After C2, leave Briar Mouth west to Fernhollow, west to Thornpath, north to Thorn Gate, west to Ruin of Ode, west to Wickfield, then south to Crossroads. Go east to Dead End (ow_2_1). The Overworld key is in C1’s optional alcove; use it on the locked closet and take the Pitch Pot.
4. **C3, Sump Gate (ow_3_5).** From Crossroads go south to Ford Road, cut the reed screen at its south exit with the Hook, then continue south through Reed Gate and Boardwalk to Wickfarm. Go east to Sump Edge and east again to Sump Gate. Bomb the brittle rocks at the mouth with the Pitch Pot.
5. **C4, Sleeping Furnace (ow_9_2).** After C3, return west from Sump Gate to Sump Edge, north to Drowned Orchard, west to Boardwalk, north through Reed Gate and Ford Road, then north to Crossroads. Go north to Wickfield, east to Ruin of Ode, then east through the burned Thorn Gate, Hedgerow, and Owl Clearing. Go south to Briar Mouth, then east to Rootbridge and Eyegate; shoot the eye switch with the Sling. Continue east through Portcullis Court to Slag Road, then south to Sleeping Furnace.
6. **C5, Lantern Isle (ow_6_3).** After C4, go north from Sleeping Furnace to Slag Road, then west through Portcullis Court and Eyegate to Rootbridge. Use the Raft at the south mooring to reach North Reach, then continue south over the water to Lantern Isle.
7. **C6, Choir Steps (ow_6_6).** From Lantern Isle use the Raft south through Mirror Deep to Broken Lighthouse, then south again to Choir Steps. Face the cave-mouth boulder, tap Use Item with Mitts equipped, and keep moving toward it until it slides clear.
8. **C7, Glassed Court (ow_10_2).** After C6, raft north from Choir Steps to Broken Lighthouse, then north to Mirror Deep. Raft east to East Landing and Landing Cliffs, then east to Boulder Gate. Push the stones north into Heavy Pass with the Mitts; continue north to Sleeping Furnace and east to Glassed Court. Throw the Glow Jar at the dark lamp-stone stairs. The Sling must have opened Eyegate on the way into Cinderflats.
9. **C8, Counting Gate (ow_9_7).** From Glassed Court go west to Sleeping Furnace, then south through Heavy Pass into Boulder Gate. Move any stone that blocks the way with the Mitts. Continue south to Ravine Edge. Use the Boots to leap south to Ravine Landing, then south to Counting Gate. Ring the Chime at the resonance door. Both Chime (C6) and Boots (C7) are needed.
10. **C9, Lamplighter’s Stump (ow_0_2).** From Counting Gate go north to Ravine Landing, leap west to Ravine Bridge, then west through Gravelight Terrace to Choir Steps. Raft north to Broken Lighthouse, then west through South Swell and Dockside Bluff to Sump Gate. Go west to Sump Edge, north to Drowned Orchard, west to Boardwalk, north through Reed Gate and Ford Road, then west to the Stump. Throw the Glow Jar at the dark lamp stone. You can enter after C5, but Boots, Mitts, and Reel Line gate parts of the route; if you enter before those tools, leave and return when you have them. The recommended order completes C9 after C8.
11. **C10, The Ninth Door (ow_10_8).** After C9, go east from Lamplighter’s Stump to Ford Road, south through Reed Gate to Boardwalk, east to Drowned Orchard, south to Sump Edge, then east through Sump Gate to Dockside Bluff. Raft east through South Swell and Broken Lighthouse, south to Choir Steps, then east through Gravelight Terrace and Ravine Bridge. Leap east to Ravine Landing; continue east to Wreck Row, south to Pilgrim Road, and south to the Ninth Door. It opens only after you hold all nine fragments from C1–C9.

## C1: The Wick Cellar

**Entrance:** Crossroads (ow_1_1), open.  
**Tool:** Cinder Wick.

1. From Cellar Hub (cave_1), go west to Spent Wicks (cave_1_2), then north to Grated Store (cave_1_3). Send the Moth through the permanent grate to fetch the C1 small key. Return south to Spent Wicks and east to Cellar Hub.
2. Go east into Kiln Hall (cave_1_4). Light both braziers with the Hook; this opens the north passage. Go north to Wax Stair (cave_1_5).
3. Defeat the Hollow Captain before taking the Cinder Wick from the pedestal. Its raised guard blocks hits from the front; circle behind it or use the Moth to stun it, then hook it. After its shield bash, it is briefly open from the front.
4. From Wax Stair go east to Ash Closet (cave_1_7) and collect the C1 Lockpick. It opens C1’s ordinary keyhole doors as well as its boss door, without spending keys. Return west, then south to Kiln Hall.
5. Go east from Kiln Hall through the C1 key door into Kiln Row (cave_1_6); the Lockpick opens it, so the small key from the Grated Store is kept. Go east through the boss door with the same Lockpick (e152) to Kilnkeeper’s Floor (cave_1_8).
6. **Kilnkeeper:** hard wax ignores the Hook and ordinary weapons. Aim the Cinder Wick flame at it until the shell melts, then hook it during the molten window. Ward blocks its slag fans. Step clear of the charge and stay outside the close-range wax splash.

**Reward and return:** Take the Fragment of Warmth and wick core. Walk west from the arena through Kiln Row and Kiln Hall to Cellar Hub, then use the cave exit at the south side of the hub to return to Crossroads.

**Optional finds:** In Cellar Hub, light the two braziers to open the alcove and take its Overworld key. Use it at the closet in Dead End (ow_2_1) to get the Pitch Pot needed for C3. In Kiln Row, bomb the cracked store arch for a cache.

## C2: The Briar Hollow

**Entrance:** Briar Mouth (ow_5_1), after burning the Thorn Gate hedge with Cinder Wick.  
**Tool:** Tallow Sling.

1. From Rootmouth (cave_2_1) go east to Seed Hall (cave_2_2). Burn the north thorn wall and enter Thorn Nook (cave_2_3); take the C2 key, then return south.
2. Spend that key on the east door into Fruiting Hall (cave_2_4). Defeat the Thorn Warden before the Sling. The Moth can stun it; the Wick burns its thorn body, and Ward blocks the ring of needles. Continue east to Pale Garden (cave_2_5) and take the Tallow Sling.
3. Go north to Overgrown Walk (cave_2_6). Take the second C2 key and the slug bundle. Shoot the eye switch on the east side to open Eye Loft (cave_2_7); take the C2 Lockpick, then return west and south to Pale Garden.
4. Go south from Pale Garden through the second C2 key door to Hanging Antechamber (cave_2_8); the Lockpick opens it without spending the second small key. Walk east through the boss door with the Lockpick into Briar Mother’s Crown (cave_2_9).
5. **Briar Mother:** the three eyes can only be hit by Sling shots while lowered; each takes four slugs. Keep Ward facing the spore bolts. Hook, flare, or fire can destroy falling seeds before they burst. Once all three eyes are gone, attack the bloom with the Hook while avoiding its sweeping thorn rows.

**Reward and return:** Take the Fragment of Growth and wick core. Go west to Hanging Antechamber, north to Pale Garden, west to Fruiting Hall, west to Seed Hall, then west to Rootmouth and out through Briar Mouth.

**Optional finds:** There is no separate optional room in C2.

## C3: The Drowned Wick Works

**Entrance:** Sump Gate (ow_3_5), after opening the Dead End closet for a Pitch Pot.  
**Tool:** Reed Raft.

1. Bomb the brittle rocks at the mouth, enter Floodgate Hall (cave_3_1), and go east to Cistern (cave_3_2). Cut the moss screen on the north exit with the Hook. Enter Mossed Pump Room (cave_3_3), take the C3 key, and return south.
2. Spend the key on the east door to Pump Hall (cave_3_4). The Sump Lurker is vulnerable only while surfaced; wait by the pool for it to surface, stun it with the Moth then hook it. Ward blocks its water jet. Continue east to Dry Dock (cave_3_5) and take the Reed Raft.
3. Board at Dry Dock and ride north over the flooded passage to Sluice Walk (cave_3_6). Take the C3 Lockpick.
4. Ride east to Drowned Gallery (cave_3_7) for the optional wick core. Return west to Sluice Walk, then raft south to Dry Dock.
5. Go south from Dry Dock to Lock Chamber (cave_3_8), then east through the Lockpick boss door to Tidewick Basin (cave_3_9).
6. **Tidewick:** stay on the raft and strike the tail tip when it surfaces. Avoid the head. Ward blocks ember bolts; in the second phase, steer around the undertow wave because Ward cannot stop it.

**Reward and return:** Take the Fragment of Rain and wick core. Go west to Lock Chamber, north to Dry Dock, then west through Pump Hall and Cistern to Floodgate Hall and the Sump Gate mouth.

**Optional finds:** The wick core is at the far side of Drowned Gallery; the raft is required to reach it.

## C4: The Sleeping Foundry

**Entrance:** Sleeping Furnace (ow_9_2), after the Sling opens Eyegate.  
**Tool:** Heft Mitts.

1. From Cold Forecourt (cave_4_1) go east to Slag Hall (cave_4_2). Shoot the north eye switch to open Eyed Cell (cave_4_3); take the first C4 key and return south.
2. Spend it on the east door into Banked Furnace (cave_4_4). Defeat the Lull-Mauler before getting the Mitts. Stun it with the Moth and hook it during recovery; a hook swing can also send one of its fallen slag chunks back at it. Go east to Anvil Row (cave_4_5) and take the Heft Mitts.
3. Go north to Heavy Vault (cave_4_6). Lift and throw the heavy stone to clear the passage; take the second C4 key. Return south to Anvil Row, then go south to Quench Hall (cave_4_7).
4. Spend the second key on the east door to Bellows Loft (cave_4_8). Take the C4 Lockpick, return west to Quench Hall, then go west to Sleeper’s Antechamber (cave_4_9). Go south through the boss door into Colossus’ Bed (cave_4_10).
5. **Hushed Colossus:** Hook, Sling, and fire do not hurt its wax armour. Watch the falling-shard floor markers, then use the Mitts to lift and throw the shards at it. Move out of slam and sweep warnings; Ward does not block this boss’s attacks.

**Reward and return:** Take the Fragment of Sleep and wick core. Go north to Sleeper’s Antechamber, east to Quench Hall, north to Anvil Row, west to Banked Furnace, west to Slag Hall, and west to Cold Forecourt; exit to Sleeping Furnace.

**Optional finds:** Melt the wax seal in Quench Hall with a charged Hook flare to enter the cache. It includes a slug bundle.

## C5: The Mirrored Archive

**Entrance:** Lantern Isle (ow_6_3), reached by Reed Raft across Mirrormere.  
**Tool:** Glow Jar.

1. From Still Foyer (cave_5_1) go west to Hall of Faces (cave_5_2). Cut the dry vines at the north exit with the Hook and enter Dust Reading Room (cave_5_3). Take the first C5 key and return south.
2. Spend it on the west door to Index Hall (cave_5_4). Defeat the Mirror Warden before acquiring the Jar: light all four corner braziers with the Hook to fade away its decoys, then hook the real Warden. Continue west to Lantern Shelf (cave_5_5) and take the Glow Jar.
3. Throw the Jar at the faint north seam in Lantern Shelf. Enter Unlit Stacks (cave_5_6) and take the second C5 key. The seam remains open after the glow fades. Return south to Lantern Shelf, then south to Reflecting Hall (cave_5_7).
4. Spend the second key on the west door to Vault of Names (cave_5_8); take the C5 Lockpick and return east. Go east from Reflecting Hall to Archivist’s Antechamber (cave_5_9), then south through the boss door to The Last Page (cave_5_10).
5. **Archivist:** in the dark copy phases, throw the Jar so the real Archivist’s shadow is visible. Hit the real one with the Hook to end the copy phase and stun it. Ward blocks bolts and the page ring; do not strike a decoy.

**Reward and return:** Take the Fragment of Memory and wick core. Go north to the antechamber, west to Reflecting Hall, north to Lantern Shelf, east to Index Hall, east to Hall of Faces, and east to Still Foyer; leave through the Lantern Isle mouth.

**Optional finds:** There is no extra pocket in C5. The north seam and key in Unlit Stacks are part of the main route; revealing the seam does not consume the Jar or close the passage.

## C6: The Choir Vault

**Entrance:** Choir Steps (ow_6_6). Reach it by Reed Raft, then push the cave-mouth boulder with the Mitts: face it, tap Use Item, and keep moving toward it until it slides clear. The full route also uses the Pitch Pot and Glow Jar.  
**Tool:** Lantern Chime.

1. From Echo Steps (cave_6_1) go east to Nave (cave_6_2). Bomb the cracked north arch with a Pitch Pot; take the first C6 key in Cracked Loft (cave_6_3), then return south.
2. Spend the key on the east door to Singing Hall (cave_6_4). Defeat the Choir Warden before getting the Chime: face it and hold Ward during its note, then hook it during recovery. A Moth stun also interrupts the note. Continue east to Bell Room (cave_6_5) and take the Lantern Chime.
3. Ring the Chime at the north resonance stone to enter Resonance Hall (cave_6_6). Throw the Glow Jar at the east seam and enter Organ Loft (cave_6_7); take the second C6 key. Return west to Resonance Hall, south to Bell Room, then south again to Quiet Hall (cave_6_8).
4. Spend the second key on the east door to Hollow Crypt (cave_6_9). Take the C6 Lockpick. The cracked north niche opens with a Pitch Pot; the pocket beyond holds an optional wick core. Return west to Quiet Hall.
5. Push the heavy door on Quiet Hall’s west side with the Mitts: face it, tap Use Item, then keep moving west until it slides clear. Enter Choir Antechamber (cave_6_10), then go south through the Lockpick boss door to Dirge Floor (cave_6_11).
6. **Dirge Choir:** watch the colored ring that marks a singing head. Ring the Chime while that head is singing and within range, then move in and hook it during the stun. Ward blocks the heads’ songs and projectiles.

**Reward and return:** Take the Fragment of Song and wick core. Go north to Choir Antechamber, east to Quiet Hall, north to Bell Room, west to Singing Hall, west to Nave, and west to Echo Steps; exit to Choir Steps.

**Optional finds:** Quiet Hall’s ward plate opens the side chapel cache. Hold Ward toward the watcher beam at the plate until its blocker opens. The second optional find is the cracked crypt niche in Hollow Crypt.

## C7: The Hall of Nerve

**Entrance:** Glassed Court (ow_10_2). The Glow Jar reveals the stairs; Cinder Wick opens the Thorn Gate on the way to Cinderflats, and the Sling opens Eyegate.  
**Tool:** Skitter Boots.

1. From Sunless Stair (cave_7_1) go west to Pit Gallery (cave_7_2), then north to Narrow Ledge (cave_7_3). Send the Moth across the pit to fetch the C7 key behind the permanent grate. Return south.
2. Spend the key on the west door to Warden Landing (cave_7_4). Lure the Pale Squire over the pit; use the Moth while it is over the gap to make it fall. Repeat until it is defeated. Go west to Boot Rack (cave_7_5) and take the Boots.
3. Leap north from Boot Rack across the pit to Chasm Walk (cave_7_6); take the second C7 key.
4. Return to Boot Rack and go south to Falling Hall (cave_7_8). Spend the key on the west door to Cold Cell (cave_7_9); take the C7 Lockpick. Return east to Falling Hall, then east to Nerve Antechamber (cave_7_10). Go south through the boss door to Coward’s Crown (cave_7_11).
5. **Gloam Knight:** use the Boots to move between islands and to jump clear of its marked dive. Hook it during the one-second recovery after it lands. Falling costs a heart but does not reset the fight.

**Reward and return:** Take the Fragment of Courage and wick core. Go north to Nerve Antechamber, west to Falling Hall, north to Boot Rack, then east through Warden Landing and Pit Gallery to Sunless Stair; exit through Glassed Court.

**Optional finds:** From Chasm Walk, leap west across the side pit to Bridge of Nerve (cave_7_7) for its brass cache. Leap east back to Chasm Walk before returning to Boot Rack.

## C8: The Counting House

**Entrance:** Counting Gate (ow_9_7), opened by the Lantern Chime. Boots are needed to cross the Gravelight ravine; the Sling opens an eye switch inside.  
**Tool:** Reel Line.

1. From Tally Hall (cave_8_1) go east to Scale Room (cave_8_2). Collect the slug bundle and shoot the north eye switch. Enter Weighing Loft (cave_8_3), take the first C8 key, and return south.
2. Spend it on the east door to Ledger Hall (cave_8_4). Defeat the Abacus Brute before taking the Reel Line. Its front rail blocks Hook hits: break the rail with a charged Hook flare or a Pitch Pot, then hook the Brute. Ward does not block its chain whirl. Go east to Coin Press (cave_8_5) and take the Reel Line.
3. Reel to the north anchor ring from Coin Press to Anchor Gallery (cave_8_6); take the second key. Leap east across the pit to Gilded Walk (cave_8_7) and take the C8 Lockpick. Return west by Boots to Anchor Gallery, reel south to Coin Press, then go south to Strongroom Hall (cave_8_8).
4. Use the Lockpick to open the east key door to Locked Till (cave_8_9) without spending the second key; take the third C8 key. Go south to Counting Floor (cave_8_10), then west through the next key door to Auditor’s Gate (cave_8_11), again keeping your small keys because the Lockpick opens it. Go west through the boss door to Hoard Floor (cave_8_12).
5. **Coinwyrm:** reel off its coin plates while its head is reared. When all plates are gone, hook the bare head before it burrows. Ward blocks the coin volleys; sidestep the tail sweep.

**Reward and return:** Take the Fragment of Trade and wick core. Go east to Auditor’s Gate, east to Counting Floor, north to Locked Till, west to Strongroom Hall, north to Coin Press, west to Ledger Hall, west to Scale Room, and west to Tally Hall; exit to Counting Gate.

**Optional finds:** The Scale Room slug bundle is on the main route and helps pay for later eye switches and the final boss.

## C9: Corrow’s Undercroft

**Entrance:** Lamplighter’s Stump (ow_0_2), revealed with the Glow Jar. To finish the cave and boss, bring the Cinder Wick, Pitch Pot, Sling, Reed Raft, Mitts, Boots, and Reel Line; the Chime opens an optional vault.  
**Reward:** Corrow’s ninth fragment; no new tool. C9 is Corrow’s workshop, not a lantern cave.

1. From Hidden Stair (cave_9_1) go east to Letters Hall (cave_9_2). Burn the north thorn wall with the Cinder Wick and enter Wax Study (cave_9_3); take the first C9 key, then return south.
2. Spend it on the east door into Corrow’s Workbench (cave_9_4). Defeat the Wick Automaton before crossing the flooded passage. Its flame jet is blocked by Ward; the Moth stuns it and opens the back vent, or you can hook the vent after a jet. Pick up the two Pitch Pot bundles at the workbench if you need ammunition.
3. Ride east from the workbench to Flooded Cellar (cave_9_5). Leap north across the pit to Pit Landing (cave_9_6); take the second C9 key. Return south.
4. Leap north again to Pit Landing, then reel east across the anchor gap to Anchor Shaft (cave_9_7); take the C9 Lockpick. Reel back west, leap south to Flooded Cellar, and use the Mitts to lift the heavy stone on its south exit, then throw it aside to open the passage.
5. Enter Heavy Door Hall (cave_9_8), then go west through the second C9 key door to Lock Antechamber (cave_9_9); the Lockpick opens it without spending the second small key. Go south through the boss door with the Lockpick to Lock Floor (cave_9_10).
6. **Lock Warden:** shoot each lid eye with the Sling to open it, then place a Pitch Pot against the exposed plate. Each broken plate drops a two-pot bundle. Once all four plates are gone, hit the keyhole while it opens. Ward blocks the key volleys; leap over the deadbolt sweep with the Boots.

**Reward and return:** Take Corrow’s Last Wick (the ninth fragment) and a wick core. Go north from Lock Floor to the antechamber, east to Heavy Door Hall, north to Flooded Cellar, raft west through the workbench and Letters Hall, then west to Hidden Stair and the Stump.

**Optional finds:** In Letters Hall, shoot the south eye switch to open the cell for an 80-brass cache; skip this optional shot if you are conserving slugs. In Lock Antechamber, ring the Chime at the north resonance vault; it holds a cache and a slug bundle.

C9’s stairs become visible as soon as you own the Jar, so you can peek in early. The route past the workshop needs the Raft; the north pit needs Boots; the anchor shaft needs Reel Line; and the south heavy stone needs Mitts. Leave at any tool gate you cannot cross and return after the relevant cave. C8 supplies the last main-path tool.

## C10: The Ninth Hollow

**Entrance:** The Ninth Door (ow_10_8), which requires all nine fragments. The full cave route uses the Cinder Wick, Sling, Raft, Mitts, Glow Jar, Chime, Boots, and Reel Line. A Pitch Pot is useful against the final heart, but is not a gate.  
**New tool:** None.

1. Enter Ninth Stair (cave_10_1) and go east to Root Hall (cave_10_2). Burn the north thorn wall and enter Wax Gardens (cave_10_3); take the first C10 key and return south.
2. Spend it on the east door to Hollow Gate (cave_10_4). Defeat Corrow’s Echo before taking the raft east to Drowned Choir (cave_10_5). Ring the Chime during the Echo’s glowing charge to stun it, then hook it; Ward blocks its returning hook.
3. Throw the Glow Jar at the hidden seam on the north side of Drowned Choir. Enter Mirror Walk (cave_10_6), go east through the resonance passage with the Chime to Chime Landing (cave_10_7), and take the second key. Return west and south to Drowned Choir.
4. At the south exit, use the Mitts to lift the heavy stone and throw it aside to open the way to Heavy Span (cave_10_8). Leap east across the pit to Pit Rows (cave_10_9), then reel south across the anchor gap to Anchor Drop (cave_10_10).
5. Optional: satisfy the ward plate in Anchor Drop to enter its brass cache. Otherwise, go west through the second C10 key door to Key Vault (cave_10_11); take the third key. Continue west through the third key door to Eye Hall (cave_10_12). Collect the slug bundle before using the north eye switch to enter Bigkey Chamber (cave_10_13). Take the C10 Lockpick, return south, and go west through the boss door to The Ninth Lantern (cave_10_14).
6. **The Unlit:** the five phase-one eyes only take Sling hits; each needs three slugs. Collect the +6 bundle in Eye Hall before shooting its switch. After that switch, check the HUD and make sure at least 15 slugs remain before entering the arena; the main route also has bundles in C2 and C8, and shops S3–S5 sell them. Keep Ward toward the gaze bolts and move away from marked hand strikes. In phase two, attach about three Cinder Wick flames to melt the shell; Ward blocks the wave when the boss is in front. In phase three, reel the lantern down from within range; pulling exposes the heart but does not damage it. During the opening, hit the exposed heart with the Hook, a charged flare, or a Pitch Pot blast. Reel it down and attack again during each opening until it falls. Ward blocks homing bolts; leap or move clear of the chain lash.

**Reward and return:** The Unlit drops no fragment, core, or new tool. The ending choice becomes available after the boss’s two-second death fade. To leave without choosing, walk east out of the arena and retrace the route to Ninth Stair and the Ninth Door. Continue resumes the last saved room; death returns you to your last cave-mouth or shop checkpoint. If needed, return to the Ninth Lantern room: both choices remain available until you select an ending.

**Optional finds:** Anchor Drop’s ward plate opens the nearby chapel cache; keep Ward up toward the watcher beams until it opens.

## Spoilers: the final boss and endings

> **Spoilers:** This section names the truth about the lanterns and describes both endings.

After the two-second fade when The Unlit is defeated, two lantern stands appear beside the settled Ninth Lantern. Stand on the **left** pad and press Enter (or controller A) to **Rekindle** the last lantern. Stand on the **right** pad and press Enter (or controller A) to **Become the Wickwarden**.

- **Rekindle:** Tamsin relights the last lantern. Vey and the Nine Lanterns regain their old light and warmth, along with the old cost the lanterns took from the valley.
- **Become the Wickwarden:** Tamsin puts out the last lantern. The Hush settle, the valley finds its own light, and dusk slowly gives way to dawn.

The game saves the selected ending and completion. The coda leads to credits and then the title screen. Continue resumes the saved checkpoint and keeps that ending; it does not offer the other choice. The late truth is that Corrow pulled the lanterns down because their light took a little from every life; the Hush are what the lanterns took. The choice is whether to relight the last lantern and accept the old cost, or let Vey find its own dawn. The choice can only be made once on that save.

