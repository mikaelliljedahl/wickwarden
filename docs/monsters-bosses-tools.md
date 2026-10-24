# Wickwarden: monsters, bosses and tools (spec)

Status: plan accepted. The world build is running; see [state.md](state.md) and [world-work-packages.md](world-work-packages.md).
Companions: [world-plan.md](world-plan.md) (master plan, Appendix A lists the monsters, section 2 the
tools), [world-graph.json](world-graph.json), [dev-world-plan.md](dev-world-plan.md) (sections 4-6 are
the number format used here), [code-contract.md](code-contract.md) (APIs and layers),
[story.md](story.md) (tone: the Hush are made of forgotten things).

This document specifies everything the world plan only names: the nine new regular monsters, the ten
minibosses, the ten bosses (one per cave C1 to C10) and the eight new tools. Every number from
`dev-world-plan.md` stays (96 px tiles, 20x10 rooms, half-hearts, hook damage 2, flare damage 4, pot damage 4).
Where this document needs a decision the plan does not make, it says so in section 8 (Open questions).

## 0. Decisions that are binding for this document

These came from the user after the world plan was written. They override the world plan where they differ.

| Topic | Decision | Effect here |
|---|---|---|
| Tallow sling ammo | The sling has limited ammo, like the pitch pot. | Max 30 slugs, 12 on first pickup of the item, slug bundle +6, drop chance 8 % (section 5.2). The plan said "no ammo". |
| Pitch pot limit | 10 now, raised by the two pot bags (P1 `ow_7_2#bag`, P2 `ow_10_1#hut`) to a final limit of **18**. | 10, then 14 after P1, then 18 after P2 (+4 each). The plan proposed 15 and 20. |
| C9 | Corrow's workshop, not a lantern. | The Lock Warden drops "Corrow's Last Wick" (the ninth fragment) and a wick core, no lantern theme. |
| Ninth Door | Opens only with all nine fragments (frag:c1 to frag:c9). | Nothing to add; the C10 section assumes nine. |
| C10 order | The final fight comes before the ending choice. | The Unlit dies, then the ending trigger appears (section 4.10, `ending_trigger.gd`). |
| Ward | A few puzzles need the ward. | Every monster and boss lists its ward interaction (section 1.4, tables). |

## 1. Conventions

### 1.1 Units and shared numbers

| Thing | Value |
|---|---|
| Tile / room | 96 px / 20x10 tiles = 1920x960 px. Walkable interior: tiles 1..18 x 1..8 = 1728x768 px. Room-local centre: (960, 480). |
| Damage | Half-hearts (int). Hook 2, flare 4, pitch pot 4 (enemies) / 2 (player), tallow slug 1, cinder flame 1 per 0.5 s tick, thrown object 3, moth 0. |
| Player | 360 px/s, hurtbox radius 26 px, i-frames 0.9 s, hit knockback 640 px/s for 0.14 s, hook reach 120 px (active 0.12 s, total 0.28 s), flare reach 140 px, ward blocks the front 120 degrees. |
| Enemy hit | Flash 0.1 s, knockback 480 px/s for 0.12 s, i-frames 0.25 s (unchanged). |
| Time | All timers count in `_physics_process(delta)`. "Telegraph" = the visible warning before a damaging attack. |
| Coordinates | Room-local pixels unless a tile is named: tile (c, r) has its centre at (96c+48, 96r+48). |

### 1.2 Telegraph rule

Every damaging attack has a visible telegraph (a glow, a crouch, a floor marker, a ripple). No text.

| Class | Minimum telegraph |
|---|---|
| Regular monster | 0.35 s |
| Miniboss | 0.5 s |
| Boss, normal attack | 0.5 s |
| Boss, heavy attack (damage 3 or more) | 0.7 s |

### 1.3 Stun, knockback and armour rules (extensions of the dev plan)

| Rule | Value |
|---|---|
| Moth stun (2.0 s) on regular monsters | Applies in full unless the monster's row says otherwise. |
| Moth stun on minibosses | Clamped to 1.5 s (1.0 s for Echo), then the miniboss is immune for 3.0 s (no stun lock). |
| Moth stun on bosses | Immune (`stun_scale = 0`), except boss parts named in the boss tables. The moth still carries pickups in boss rooms. |
| Boss knockback | Hook and flare do not push bosses (`knockback_scale = 0`). |
| Armour | A front guard or plate lets a hit through only if the hit passes its filter (section 7). A blocked hit shows a spark, deals 0 and pushes the attacker 200 px/s for 0.1 s. |
| Fire | Hitbox kind `&"fire"`. Ticks every 0.5 s for 1 damage. A flame that touches an enemy sticks to it for the rest of its 3.0 s (section 5.1). |
| Pierce | The charge flare (kind `&"flare"`) and explosions (kind `&"explosion"`) pierce front guards, unless a row says otherwise. |

### 1.4 The ward

The ward destroys or negates a hit that comes from the front 120 degrees of Tamsin. Two kinds of attack
exist:

| Attack kind | Ward result | Examples |
|---|---|---|
| Projectile | Projectile destroyed (existing rule). | Spore, watcher beam, ink bolt, lance, coin. |
| Area (cone, burst, ring) | The hit is negated for Tamsin; the attacker survives (new `Hitbox.block_destroys_carrier = false`, section 7). Works only if the attack's source is inside Tamsin's front 120 degrees when the hit lands. | Choirling cone, wisp burst, Bass ring, wax wave. |
| Contact, slam, floor marker, sweep band | Not blockable. | Hound bite, Colossus slam, deadbolt. |

While the ward is raised Tamsin moves at 40 % and cannot swing. Holding the ward and using an item at
the same time is allowed except while carrying (heft mitts) or on the raft (section 5.4).
Each monster and boss table below has a "Ward" line. Puzzles that need the ward: the watcher eye
approach (2.1), the cinder wisp burst (2.1), the Choir Warden's note (section 3), the Bass ring of the Dirge
Choir (4.6), the wax wave of the Unlit (4.10).

### 1.5 Drops

Roll `DropTable.pick` as in the dev plan, with one new entry: **slug bundle** (+6 slugs), 8 % once the
tallow sling is found. The table after the sling and pot are both found: ember 25 %, brass bit 35 %,
brass coin 5 %, pot bundle 10 %, slug bundle 8 %, nothing 17 %. Before an item is found its bundle
entry is "nothing". Rows say where a monster differs. Minibosses and bosses never use the table (sections 3
and 4).

---

## 2. Regular monsters (the Hush)

Same table style as `dev-world-plan.md` section 6. Speeds are px/s. "Contact" is the damage of body
contact in half-hearts. All of them use `EnemyBase`; they never leave their room; they respawn on entry.

### 2.1 Stats and behaviour

| Monster | Analog role | HP | Contact | Speed | Behaviour |
|---|---|---|---|---|---|
| **Bramble snapper** | Rooted biter | 3 | 2 | 0 | Rooted, sways. Trigger: Tamsin's centre within 144 px of its centre. Telegraph 0.35 s (jaws spread, thorns flare), aim locked at the end of the telegraph. Snap: 180 degree cone, radius 150 px toward the locked aim, active 0.15 s, damage 2. Then 1.0 s of closed jaws during which it cannot trigger. Cycle 1.5 s. Immune to the moth (`stun_scale = 0`). Any fire tick deals 6 and it burns away in 0.6 s. Ward: the bite is melee, not blockable. |
| **Fen leech** | Water lurker | 3 | 2 | 150 submerged, 420 lunge | Lives in water (`WaterZone`, deep or shallow) and cannot leave it. Submerged: hurtbox and contact off, only ripples show; it glides at 150 px/s toward the water point nearest to Tamsin. Trigger: Tamsin within 300 px of the leech. Telegraph 0.5 s (bubbles, it surfaces). Lunge toward Tamsin's position at the end of the telegraph: 420 px/s for up to 240 px, clamped to water. Then 1.2 s surfaced and still (hittable), 0.3 s dive, at least 1.5 s submerged before the next trigger. Moth stuns it only while surfaced. Ward: the lunge is contact, not blockable. |
| **Cinder wisp** | Floating bomb | 2 | 1 | 100 | Drifts toward Tamsin with a sine wobble (amplitude 40 px, period 1.2 s) and lights a 140 px radius around itself. Trigger: within 150 px. Telegraph 0.5 s (stops, swells from scale 1.0 to 1.6, glows white). Burst: ring hitbox radius 150 px, active 0.2 s, damage 2. The wisp is consumed by the burst (no drop). If killed during the telegraph the burst is cancelled and it drops normally. Immune to fire. Ward: the burst is an area hit; blocked when the wisp is in the front 120 degrees (the intended answer: raise the ward, let it burst, then continue). |
| **Watcher eye** | Wall turret | 2 | 0 | 0 | Mounted flush on the wall ring, faces inward along its row or column. Lid closed (invulnerable) by default. Trigger: Tamsin within 48 px of the eye's axis, 192 to 1100 px away, clear line. Telegraph 0.5 s (lid half open, iris glows). Fires one beam bolt: projectile, capsule 24x96 px, 300 px/s, damage 2. The lid stays open 1.0 s after the shot (vulnerable), then closes. Cycle 3.0 s. A stunned eye keeps its lid open for the stun (1.5 s). Ward: blocks the bolt. The base-kit answer: raise the ward on the axis, walk up, lower it and strike while the lid is open. Respawns on entry. |
| **Husk hound** | Fast charger | 2 | 2 | 160 prowl, 420 charge, 260 circle | Prowls toward Tamsin at 160 px/s in a zigzag. Every 1.4 to 2.2 s it checks alignment (same row or column within 48 px, distance 240 to 720 px). Aligned: telegraph 0.4 s (crouch, growl), then charges at 420 px/s up to 720 px or until a wall. A wall hit leaves it dizzy for 0.9 s (hittable). A charge that ends in the open is followed by a circle run: radius 220 px around Tamsin's position, 260 px/s, 1.0 s, random direction, then prowl. Packs of up to 3: a shared token allows one charge per 0.8 s. Ward: nothing to block. |
| **Brine crab** | Armoured walker | 4 | 2 | 110 sideways | Walks sideways relative to its facing and turns to face Tamsin at 80 degrees/s, so a fast flank beats it. Front guard: hits that come from inside the front 140 degrees are blocked (spark, 0 damage). The flare and explosions pierce. Strafe direction changes every 1.0 to 2.0 s or at a wall. Every 3.0 s a pincer lunge: telegraph 0.4 s (claws up), 160 px at 300 px/s, damage 2, then 0.8 s with the facing frozen and the claws down. Moth stun freezes the facing too. Ward: the lunge is melee, not blockable. |
| **Wickling** | Swarmer | 1 | 1 | 200 in bursts | Comes in packs of 2 or 3. Idle until Tamsin is within 420 px. Then stop-and-go: runs 0.5 s at 200 px/s, pauses 0.3 s, each pack member with its own approach offset of +-35 degrees. When a packmate dies the others get +20 % speed for 3.0 s. Fire kills it instantly. Drops roll only half of the time (an extra 50 % gate before the table). Ward: nothing to block. |
| **Mirror shade** | Mimic | 3 | 2 | 200 | Appears as a pair: the real shade and a decoy reflection at the point mirrored across the room's horizontal centre line (y' = 960 - y). Fade-in 0.6 s (invulnerable), then the real shade stalks Tamsin at 200 px/s; the decoy copies every move, swing and facing but has no hurtbox and no hitbox. Echo swing: 0.4 s after Tamsin starts a hook swing, if the real shade is within 150 px, it swings back (110 degree arc, reach 120, damage 2). Ward mirror: while Tamsin holds the ward the real shade's front 120 degrees is immune; flank it. A hit on the decoy cracks it and shows the real shade for 1.0 s. Under a glow jar light (`GlowJar.is_lit`) the decoy is gone and the real shade casts a dark shadow. Ward: the echo swing is melee, not blockable. |
| **Choirling** | Floating singer | 2 | 1 | 90 hover | Hovers 240 to 400 px from Tamsin (backs off at 140 px/s if closer than 200 px). Every 2.4 s: telegraph 0.6 s (mouth opens wide, a ring glyph), then sings a cone: 60 degrees, length 420 px, active 0.5 s, damage 2. Moth stun 2.0 s; chime stun 2.5 s. Ward: blocks the cone (area hit, front 120 degrees). |

### 2.2 Where they appear, weakness, drops, art

Counts are placed enemies in `world-graph.json` (rooms in brackets).

| Monster | Regions and caves | Placed | Weakness and good answers | Drops | Art (one line for the sprite sheet) |
|---|---|---|---|---|---|
| Bramble snapper | Thornwood; C2 | 12 (9) | Fire (cinder wick, one tick kills), flare, pot. Sling from range (3 slugs). The moth does nothing. | Standard table | A thorn-root with a wide jaw of hawthorn spikes and a red throat, half sunk in the ground. |
| Fen leech | Tallowfen and Mirrormere; C3, C9, C10 | 31 (17) | Hook or flare while surfaced; moth when surfaced; sling when surfaced. Keep off the shore line. | Ember 35 % (instead of 25 %), rest standard | A long wax-black leech with a pale lamp-wick tail that glows when it surfaces. |
| Cinder wisp | Cinderflats; C4 | 22 (11) | Moth then hook, sling (2 slugs), or the ward. Immune to fire. | Standard (none if it burst) | A drifting orange ember with a smoky tail and two dim eyes in the glow. |
| Watcher eye | Gravelight Heights; C10 | 17 (9) | Hook while the lid is open, sling from range (2 slugs), moth keeps the lid open. Ward blocks the bolt. | Standard | A carved stone eye socket in the wall with a heavy lid and a cold blue iris. |
| Husk hound | Hushmarch; C10 | 31 (18) | Hook (one hit), moth, pot knockback. Strike after a wall bonk or the circle run. | Standard | A thin grey hound stitched from old sacks, rope and rusted lantern parts. |
| Brine crab | Hushmarch; C8, C10 | 15 (8) | Charge flare, pot, or any hit from the sides and back. Moth freezes the facing. | Standard, plus a guaranteed brass bit | A barnacled crab with a plate shell like a rusted breastplate and one huge claw. |
| Wickling | C1, C3, C5, C8, C9, C10 | 19 (10) | Charge flare sweep (360 degrees kills a pack), fire, one hook hit each. | Half rolls, otherwise standard | A thumb-high candle imp with a stub of wax for a body and a tiny flame head. |
| Mirror shade | C5, C10 | 12 (6) | Hook after a glow jar reveals it, or flank it around the ward mirror. | Standard | A flat, dark silhouette of Tamsin with a faint pale outline and no face. |
| Choirling | C6, C10 | 18 (9) | Hook (one hit), ward vs the cone, moth, chime stun. | Standard | A floating round mouth ringed with pale lamp-glass teeth, trailing ribbons. |

---

## 3. Minibosses

One per cave, in the room the plan names. Miniboss rules:

- A defeated miniboss stays dead: flag `mini_<room_id>` (persistent; the room does not respawn it). If Tamsin
  leaves the room while it lives, it returns to full HP.
- The room has no shutters. Nothing in the graph depends on the kill; it guards the way and the loot.
- Drops: 2 embers (timed) and 2 brass coins (timed), no wick core, no table roll.
- Moth stun: clamped (section 1.3). Knockback from the hook applies at 50 %.
- **Kit rule.** Each miniboss is beatable with the base kit, the moth, the pitch pot and the tools of the caves
  that must come before the cave (section 4.0). The plan's notes for C4, C5 and C8 name a tool that lies
  behind the miniboss room; the rows below keep the idea but use a trick that works without it (Open question 1).

| Miniboss | Cave, room | HP | Contact | Speed | Behaviour |
|---|---|---|---|---|---|
| **Hollow Captain** | C1, `cave_1_5` Wax Stair | 12 | 2 | 120 | A Hollow in a lamp-shade helm with a raised guard facing Tamsin: hits from the front 140 degrees are blocked (flare and pot pierce). It turns at 100 degrees/s, so circle it at 360 px/s and strike the side or back. Every 4.0 s a shield bash: telegraph 0.5 s (guard rises), dash 300 px/s for 0.4 s, damage 3, then 1.0 s with the guard down (hittable from the front). A moth stun drops the guard. Ward: the bash is melee, not blockable. The cinder wick lies on a pedestal in this room; it is placed on the far side of the patrol line. |
| **Thorn Warden** | C2, `cave_2_4` Fruiting Hall | 16 | 2 | 80 | A walking hedge with a bark of thorns: hook damage is 1 while it is not stunned, 2 when it is stunned (the thorn skirt retracts). Fire ticks deal 2 (flammable; the cinder wick is held on every route to C2). Every 3.0 s: telegraph 0.6 s (it bristles), 8 thorn needles in a ring (280 px/s, damage 1, ward blocks). Moth stun 1.5 s. |
| **Sump Lurker** | C3, `cave_3_4` Pump Hall | 16 | 3 | 160 submerged | A big cistern thing. The room has a 2-tile-deep pool (shallow water zones). It glides submerged (hurtbox off), surfaces at the pool edge nearest to Tamsin: telegraph 0.7 s (bubbles), then a bite cone 120 degrees, radius 150, damage 3, and stays surfaced 1.5 s (hittable), dives 0.4 s. When Tamsin is more than 300 px from the pool it spits a water jet every 2.5 s (200 px/s, damage 1, ward blocks). Moth stun only while surfaced (1.5 s). |
| **Lull-Mauler** | C4, `cave_4_4` Banked Furnace | 24 | 3 | 70 | A slow slab-armed brute. Overhead smash: telegraph 0.9 s (arms rise, a shadow marks the spot), area radius 110 at 96 px in front, damage 4, leaves a slag chunk (a 1-tile obstacle) and then 1.2 s of recovery. Backhand sweep: telegraph 0.6 s, 180 degree arc, reach 140, damage 3. A hook swing that hits a slag chunk knocks it back at 400 px/s for 4 damage to the Mauler. Moth stun 1.5 s, then 3 hook hits. |
| **Mirror Warden** | C5, `cave_5_4` Index Hall | 18 | 2 | 150 | Three figures: the real Warden and two decoys that swap places every 5.0 s with a flash. Only the real one has a hurtbox and attacks: 3-slash combo, telegraph 0.5 s, cone 100 degrees, reach 130, damage 2 each, 0.3 s apart. The room has 4 unlit braziers in the corners; every brazier the hook lights fades the decoys by 25 % opacity, at 4 lit they are gone (this is the pre-jar answer). A hit on a decoy cracks it and shows the real one for 1.0 s. Moth stun on the real one 1.5 s. Ward blocks nothing (melee). |
| **Choir Warden** | C6, `cave_6_4` Singing Hall | 20 | 2 | 100 | Walks at 100 px/s. Every 5.0 s the note: telegraph 0.8 s (inhale, ribbon glyph), then a sustained cone of sound: 90 degrees, reach 480, active 1.5 s, damage 2 once per target. The ward negates it (area hit, front 120 degrees). Strike during the 1.4 s that follow the note (mouth closed). A moth stun interrupts the note. Without the ward the player dodges around the cone's side. |
| **Pale Squire** | C7, `cave_7_4` Warden Landing | 16 | 2 | 160 | A fast Hollow. The room has a pit across the middle. Lunge: telegraph 0.4 s, 520 px/s for 0.6 s (312 px), crosses pits, stab damage 2, then 0.8 s recovery. If it is stunned or hit while over a pit it falls: 6 damage, gone for 3.0 s, then it returns at the entry spawn. Moth stun 1.5 s at the edge is the intended answer. |
| **Abacus Brute** | C8, `cave_8_4` Ledger Hall | 28 | 3 | 90 | A brute with a bead-chain. Chain whirl: telegraph 0.7 s, spin 1.2 s, radius 192 around it, damage 3 (a sweep, not blockable). Shield rail on its left arm: hits from the front 140 degrees are blocked; the rail has 4 HP and takes damage from explosions and the charge flare only. When the rail breaks it is gone and the Brute takes hook damage from every side and moves at 130 px/s. Moth stun 1.5 s. |
| **Wick Automaton** | C9, `cave_9_4` Corrow's Workbench | 30 | 3 | 110 | A brass lamp-tender built by Corrow. Brass plating: hook damage 1, flare 2, explosions 4. Every 4.0 s a flame jet: telegraph 0.6 s, 2 tiles ahead for 0.8 s, 1 damage per 0.3 s tick, ward blocks. After each jet its back vent is open for 1.5 s (hook deals 2). A moth stun (1.5 s) opens the vent too. The workbench places two pot bundles (respawn on entry). |
| **Corrow's Echo** | C10, `cave_10_4` Hollow Gate | 36 | 4 | 200 | The wax shape of Corrow, fighting out of habit with a wax lamp hook. It approaches, swings a 2-hit combo (telegraph 0.5 s, arc 110 degrees, reach 150, damage 3, 0.4 s apart), retreats 192 px, then charges a flare: 0.8 s lamp glow, 360 degree sweep, reach 170, damage 4, not blockable. The chime rung during the glow stuns it for 2.0 s (the Echo stops to listen). Second phase below 18 HP: it also throws its wax hook as a boomerang (600 px/s, 480 px out and back, damage 2, ward blocks). Moth stun 1.0 s. |

Miniboss art lines: Hollow Captain, a Hollow with a tin lamp-shade for a helm and a round brass guard; Thorn Warden, a
man-sized walking hedge with a hollow face of leaves; Sump Lurker, a pale blind cistern worm with a ring of teeth;
Lull-Mauler, a hunched wax-and-slag brute with slab forearms; Mirror Warden, a pale armoured figure whose reflections
stand in the mirrors; Choir Warden, a tall hooded singer with organ-pipe ribs; Pale Squire, a lean white Hollow
with a long spear; Abacus Brute, a big brass-armoured brute wrapped in a chain of beads; Wick Automaton, a brass
clockwork lamp-tender with a funnel chimney; Corrow's Echo, a wax figure of an old man in Corrow's coat.

---

## 4. Bosses

### 4.0 Common rules and the kit check

| Rule | Value |
|---|---|
| Arena | One room of the cave, 20x10 tiles (1920x960 px), walkable 1728x768 px. The camera does not move. The player enters 96 px inside the boss door. The boss door does not shut (world plan 5.3). |
| Intro | 1.5 s after the player enters: the boss is visible, hurtbox and attacks off. |
| Leaving | Leaving the room (door, death, warp) resets the boss to full HP and phase 1. A defeated boss stays dead (flag `boss_<arena room id>_defeated`, persistent; for example `boss_cave_1_8_defeated`). The arena ids are `cave_1_8`, `cave_2_9`, `cave_3_9`, `cave_4_10`, `cave_5_10`, `cave_6_11`, `cave_7_11`, `cave_8_12`, `cave_9_10` and `cave_10_14` (the Arena row of sections 4.1 to 4.10). |
| Stun, knockback | Immune to stun and hook knockback (section 1.3), except parts named in the tables. |
| Phase change | At the HP threshold the boss is invulnerable for 1.2 s, all of its projectiles and hazards are removed, and one ember (timed 8 s) appears at (960, 480) if Tamsin is below full health. |
| Resupply | Bosses marked "resupply" (C2, C9, C10) spawn a pitch pot bundle when Tamsin owns the pot and has fewer than 4 pots, and a slug bundle when she owns the sling and has fewer than 8 slugs, at every phase start and every 30 s (timed pickups at (960, 480)). |
| Knockback near pits | In C7 all boss attacks have `knockback = 0` so a hit never throws Tamsin into a pit. |
| Death | 1.5 s of death throes (flash, no attacks, hazards cleared). Then the drops of the boss table appear at (960, 480) and 192 px to the right, not timed. |
| Drops | Every boss C1 to C9 drops its **fragment** (placed pickup `frag_cN`) and a **wick core** (`wick_core_cN`) plus 2 timed embers. **No boss drops a big key**: the big key lies in its own room before the antechamber (world plan, cave tables). C10 drops nothing; the ending choice appears instead. Fragment names: Warmth, Growth, Rain, Sleep, Memory, Song, Courage, Trade, and for C9 "Corrow's Last Wick" (the ninth). |
| HUD | No boss bar. Damage shows on the boss (cracks, dimming light). See Open question 2. |

Drops as in the plan, per cave: C1 Fragment of Warmth, C2 Growth, C3 Rain, C4 Sleep, C5 Memory, C6 Song, C7 Courage,
C8 Trade, C9 Corrow's Last Wick (ninth fragment), each with one wick core; C10 the ending choice.

**Kit check.** The kit is what Tamsin holds under every valid order of the world plan (section 5.5 and the
prerequisite table of section 5.2). Base kit = hook, flare, ward. Every player also holds the moth and the pot
(the pot is needed at the C3 mouth) when meeting a boss.

| Cave | Guaranteed kit when the boss starts (any valid order) | Required for the fight | Fight also uses (all held) |
|---|---|---|---|
| C1 | base, moth, pot, **cinder wick** (own, room 5) | cinder wick | ward (slag fan) |
| C2 | base, moth, pot, cinder wick (C1 first), **tallow sling** (own) | tallow sling | hook, ward, cinder wick (burns seeds and tendrils) |
| C3 | base, moth, pot, **reed raft** (own); nothing else guaranteed | reed raft | hook, flare, ward |
| C4 | base, moth, pot, cinder wick, tallow sling, **heft mitts** (own) | heft mitts | ward is not usable while carrying |
| C5 | base, moth, pot, reed raft (C3), **glow jar** (own); no wick or sling guaranteed | glow jar | hook, ward |
| C6 | all of the above except boots and reel line, plus **lantern chime** (own) | lantern chime | hook, ward |
| C7 | base, moth, pot, wick, sling, raft, jar, **skitter boots** (own); no mitts or chime guaranteed | skitter boots | sling, hook |
| C8 | wick, sling, raft, mitts, jar, chime, boots, **reel line** (own) | reel line | hook, ward, boots, flare |
| C9 | every tool | pitch pot and tallow sling | thrown pots (mitts), boots, ward |
| C10 | every tool | tallow sling, cinder wick, reel line | ward, hook, chime (miniboss), mitts |

Each boss below is written so that a player holding exactly the guaranteed kit can win.

### 4.1 C1 Kilnkeeper

| Field | Value |
|---|---|
| Arena | `cave_1_8` Kilnkeeper's Floor. Entrance on the west wall (rows 4-5). Dark room (lamp radius 260). Four pillars (96x96 solid) at tiles (5,3), (5,6), (14,3), (14,6). The kiln mouth is on the east wall; the boss starts at tile (15, 4.5). |
| Boss | HP 24, body radius 60, contact 2, walk 100 px/s, rush 420 px/s. Wax armour: while it is hard, hook, flare, pot, sling and thrown hits deal 0 (clink). |
| Required | Cinder wick. A flame that touches it sticks for 3.0 s (6 ticks). Melt counts 1 per tick. At 3 ticks the armour is **molten** for 8.0 s (phase 2: 6.0 s with 4 ticks needed), and then every damage source works. |
| Kit | Hook, flare, ward, wick. |
| Fight length | About 90 s (6 hook hits fit into one molten window; two windows per phase at most). |

| Phase | HP | Attack | Numbers |
|---|---|---|---|
| 1 | 24 to 12 | Slag fan | Every 3.0 s. Telegraph 0.6 s (belly door glows). 3 slag balls, +-20 degrees, 300 px/s, damage 2. Ward blocks. |
| 1 | | Kiln rush | Every 8.0 s. Telegraph 0.8 s (steam, bracing). Charges along the nearest cardinal line toward Tamsin, 420 px/s up to 960 px, contact 2. Ends on a wall or pillar: the Keeper is stunned 1.2 s (armour stays hard; this is the window to place the flame). |
| 1 | | Wax splash (molten only) | Every 3.0 s while molten. Telegraph 0.5 s. Ring radius 150 around it, damage 2, not blockable. It cannot rush while molten. Hooking from 150 to 180 px from its centre stays outside the ring. |
| 2 | 12 to 0 | Slag fan | Every 2.5 s, 5 balls, +-40 degrees, damage 2. |
| 2 | | Kiln rush | Every 6.0 s. |
| 2 | | Wax splash | As phase 1. Molten window 6.0 s. |

Drops: Fragment of Warmth, wick core. Art: a furnace-bellied wax giant with a cracked kiln door in its chest, dripping slag, a chimney hat.

### 4.2 C2 Briar Mother

| Field | Value |
|---|---|
| Arena | `cave_2_9` Briar Mother's Crown. Entrance west (rows 4-5). Root floor, a thorn canopy overhead. The Mother hangs at (960, 192). Resupply: yes. |
| Parts | Phase 1: three **seed-eyes** E1 (480, 480), E2 (960, 576), E3 (1440, 480), each HP 4, hurtbox accepts only kind `&"sling"` (hook, flare and pot pass over them). Each eye sways 96 px sideways with a 4.0 s period. Eye cycle: lowered 6.0 s, raised (hidden, invulnerable) 3.0 s; the three are offset by 3.0 s so at least one is lowered. Phase 2: the **bloom**, HP 16, body radius 80, at (960, 288); every weapon works; fire ticks deal 2 (flammable). |
| Required | Tallow sling: 12 slugs for the eyes. Ammo max is 30, so resupply keeps the fight winnable. |
| Fight length | About 120 s. |

| Phase | Attack | Numbers |
|---|---|---|
| 1 (3 eyes) | Spore bolt | Each lowered eye fires every 2.0 s at Tamsin: telegraph 0.4 s, 300 px/s, damage 2. Ward blocks. |
| 1 | Seed drop | Every 4.0 s a seed falls within 192 px of Tamsin: floor marker 0.8 s, lands (HP 1). If not destroyed in 3.0 s it bursts (ring radius 120, damage 2, not blockable) and leaves a bramble snapper; at most 3 snappers alive, after that seeds only burst. Hook, flare and fire destroy a seed. |
| 1 | Eye lost | For every dead eye, remaining eyes fire 0.4 s faster and seeds drop 0.5 s faster. |
| 2 (bloom, all eyes dead) | Thorn sweep | Every 3.0 s. Telegraph 0.7 s (rows flash). Three horizontal bands of 96 px across the whole width, active 0.3 s, damage 2, leaving two safe rows. Not blockable. |
| 2 | Seed drop | Every 3.0 s as above. |

Drops: Fragment of Growth, wick core. Art: a vast sleeping woman-shaped root mass in the canopy, thorn hair and three red fruit-eyes on vines.

### 4.3 C3 Tidewick

| Field | Value |
|---|---|
| Arena | `cave_3_9` Tidewick Basin. Entrance west (rows 4-5) onto a dock: land at tiles x 1..2, a `Mooring` at tile (2, 4). The basin is deep water at tiles x 3..18, y 1..8 (a `WaterZone`). Tamsin crosses it only on the raft; the raft docks only at the Mooring. |
| Boss | A wick-serpent. Seven segments 120 px apart follow the head along an ellipse around (1152, 480), radii 480 x 264 px, 200 px/s clockwise. Body segments are submerged and harmless. The head is always visible: contact 2, spits an ember bolt every 3.0 s (telegraph 0.5 s, 320 px/s, damage 2, ward blocks). The **tail tip** is the only vulnerable part: HP 24. It surfaces for 2.0 s every 5.0 s (ripple telegraph 0.8 s at the surfacing point; the tail follows the same ellipse so the point can be predicted). Hook reach 120 and flare reach 140 hit it from a raft. |
| Required | Reed raft. From the dock the tail is 300 px or more away; no weapon reaches it. |
| Raft rules | Free steering at 240 px/s (section 5.4). On the raft Tamsin has hook, flare and ward only. A hit pushes the raft 96 px but never onto land. |
| Fight length | About 100 s. |

| Phase | HP (tail) | Attack | Numbers |
|---|---|---|---|
| 1 | 24 to 10 | Ember bolt | Every 3.0 s, damage 2, ward blocks. |
| 1 | | Head contact | 2. The head circles ahead of the tail; do not park in front of it. |
| 2 | 10 to 0 | Faster | Speed 260 px/s, direction reverses at a random 8 to 12 s. Tail up 1.6 s every 4.0 s. |
| 2 | | Undertow wave | Every 7.0 s. Telegraph 1.0 s (ripples cross a row or column). A band of water 144 px thick moves 300 px/s across the basin, damage 3, pushes the raft 200 px/s. Not blockable; steer around it. |
| 2 | | Leeches | Two fen leeches in the basin at phase start. |

Drops: Fragment of Rain, wick core. Art: a long black-and-copper serpent, its tail ending in a bright wick-flame, trailing wax like a candle drip.

### 4.4 C4 Hushed Colossus

| Field | Value |
|---|---|
| Arena | `cave_4_10` Colossus' Bed. Entrance north (columns 9-10). The Colossus sits at (960, 640), body radius 90, HP 48, contact 3, walk 60 / 80 / 100 px/s. Ceiling shards fall. |
| Armour | Hushed wax. It takes damage only from kind `&"thrown"` (6 per thrown shard) and `&"explosion"` (2). Hook, flare, sling, fire, reel deal 0. |
| Required | Heft mitts: lift a shard (0.25 s), carry at 252 px/s, throw 480 px at 720 px/s. A shard is a Liftable (radius 36, lies 12 s, then crumbles). Max 4 shards on the floor. |
| Fight length | About 140 s (8 shard hits, 6 each). |

| Wake | HP | Attack | Numbers |
|---|---|---|---|
| 1 | 48 to 32 | Slam | Every 4.0 s. Telegraph 0.8 s: a fist shadow follows Tamsin and locks at 0.3 s. Impact radius 130, damage 3, then a shockwave ring 0 to 260 px in 0.4 s, damage 2. |
| 1 | | Shard fall | 2 shards every 5.0 s. Floor marker (shadow circle radius 60) 1.0 s, damage 2 to anyone under it, then it lies as a Liftable. |
| 2 | 32 to 16 | Arm sweep | Every 5.0 s. Telegraph 0.8 s. A 96 px band sweeps across the room from the Colossus's side (row or column, random), 0.5 s active, damage 3. |
| 2 | | Slam, double | Two slams 0.6 s apart. Shards: 2 every 4.0 s. |
| 3 | 16 to 0 | Quake | Every 8.0 s. Telegraph 1.2 s: half of the floor tiles (checkerboard) glow. Glowing tiles erupt, damage 3. |
| 3 | | Slam combo | Three slams 0.5 s apart. Shards: 3 every 4.0 s. |

Ward: nothing here is blockable. The ward cannot be raised while carrying. Drops: Fragment of Sleep, wick core.
Art: a seated giant of grey wax and slag, eyes sealed, hands like anvils, roots of cooled metal across the floor.

### 4.5 C5 Archivist

| Field | Value |
|---|---|
| Arena | `cave_5_10` The Last Page. Entrance north (columns 9-10). Dark room (lamp radius 260). Six lecterns (96x96 solid, half height) at tiles (3,3), (3,6), (8,5), (11,5), (16,3), (16,6). |
| Boss | HP 30, body radius 48, contact 2, float speed 120 px/s. |
| Required | Glow jar. In copy phases only the real Archivist casts a shadow under a lit jar (radius 520 covers every copy position). |
| Fight length | About 150 s. |

| Phase | HP | Attack | Numbers |
|---|---|---|---|
| 1 | 30 to 20 | Ink bolts | Every 2.5 s, telegraph 0.5 s, 3 bolts, +-15 degrees, 300 px/s, damage 2. Ward blocks. |
| 1 | | Page blink | Every 6.0 s, telegraph 0.4 s (pages flutter). Teleports next to a lectern at least 384 px from Tamsin, then fires bolts. |
| 2 | 20 to 10 | Copy phase | The Archivist vanishes 0.8 s, then four figures (1 real, 3 decoys) stand at the compass points 288 px from the centre. Each figure fires bolts alternately every 3.0 s (0.75 s offset). Decoy bolts hurt. Lasts until the real one is hit or 15 s pass. |
| 2 | | Page break | The first hit on the real one ends the copy phase: decoys pop, the real one is stunned 2.0 s, and that hit counts double. A hit on a decoy pops it in an ink spatter (radius 100, damage 2, not blockable). |
| 3 | 10 to 0 | Last page | Copy phase starts at once with four decoys. Add a page ring: 8 pages, 240 px/s, damage 2, every 6.0 s, ward blocks. The room is dark; the jar is the only wide light. |

Drops: Fragment of Memory, wick core. Art: a floating scribe of paper and ink with a mirror for a face, pages for a cloak, eyes drawn on the pages.

### 4.6 C6 Dirge Choir

| Field | Value |
|---|---|
| Arena | `cave_6_11` Dirge Floor. Entrance north (columns 9-10). Three organ-pipe heads on the south side: Bass (336, 720), Alto (1008, 720), Treble (1584, 720). They never move. |
| Boss | Three heads, HP 12 each (total 36), contact 2. Each head is invulnerable ("humming") except while stunned. |
| Required | Lantern chime. A ring (section 5.6) stuns a head only while that head is singing (the 0.8 s telegraph plus the 1.0 s song) and only if the head is within 480 px of Tamsin. A stunned head is open for 4.0 s (hook 2, flare 4), then deaf to the chime for 3.0 s. |
| Fight length | About 150 s. |

| Phase | Attack | Numbers |
|---|---|---|
| 1 (three heads) | Song order | Bass, Alto, Treble, one every 1.5 s. Each song: telegraph 0.8 s (a coloured ring over the head), song 1.0 s. |
| 1 | Bass ring | A ring expands from the head, 0 to 640 px in 1.0 s, thickness 64, damage 3, with a 50 degree safe wedge aimed at Tamsin's position at song start. The ward negates it when the head is in front. |
| 1 | Alto beam | A 30 degree cone, reach 720, sweeping 90 degrees/s for 1.0 s from an aim at Tamsin, damage 2. Ward blocks. |
| 1 | Treble notes | 3 homing notes, 220 px/s, turn 120 degrees/s, lifetime 3.0 s, damage 2, HP 1 (the hook destroys them). Ward blocks. |
| 2 (one head dead) | Chords | The two heads sing at the same time (two songs per 1.5 s). |
| 3 (one head left) | Solo | The head sings again after 1.0 s. Two choirlings appear at phase start. |

Ward: all three songs are area or projectile attacks, so the ward is the way to stay alive while closing in to answer. Drops: Fragment of Song, wick core.
Art: three huge carved heads set into organ pipes, mouths wide, their bronze pipes breathing dust.

### 4.7 C7 Gloam Knight

| Field | Value |
|---|---|
| Arena | `cave_7_11` Coward's Crown. Entrance north (columns 9-10). Five islands over a pit (the rest of the walkable floor is pit, `PitZone`). Island A (entry) tiles x 7..12, y 1..2. Island C (centre) x 7..12, y 4..5. Island S x 7..12, y 7..8. Island W x 1..5, y 3..6. Island E x 14..18, y 3..6. Gaps between neighbouring islands are 1 tile (96 px), the skitter boots' leap is 192 px. A fall costs 2 half-hearts and respawns Tamsin on island A; the fight is not reset. |
| Boss | HP 36, body radius 44, contact 3. Starts on island C. |
| Required | Skitter boots: it fights from another island than the player. The sling (held) reaches it for 1 per slug but cannot finish the fight (ammo). |
| Fight length | About 150 s. |

| Phase | HP | Attack | Numbers |
|---|---|---|---|
| 1 | 36 to 18 | Lance | Used when Tamsin is on another island. Every 3.0 s, telegraph 0.5 s, 420 px/s, damage 2. Ward blocks. |
| 1 | | Slash combo | Telegraph 0.5 s, two slashes 0.3 s apart, 120 degree arc, reach 150, damage 3 each. |
| 1 | | Dive | Every 6.0 s or after two slash combos. Telegraph 0.5 s (crouch), airborne 0.5 s and untargetable, marker (radius 130) fixed at Tamsin's position at takeoff and shown for 0.7 s, landing damage 4. Then 1.0 s recovery (hittable). Tamsin's leap makes her invulnerable and gets her out. |
| 2 | 18 to 0 | Islands W and E crumble | They turn into pit permanently at the phase change. Three islands remain in a column. |
| 2 | | Dive | Every 4.0 s; landing also sends a ring across the island: 0 to 260 px in 0.4 s, damage 2. |

Drops: Fragment of Courage, wick core. Art: a tall knight of dark glass-black armour with an empty plume and a gloaming cape that bleeds shadow.

### 4.8 C8 Coinwyrm

| Field | Value |
|---|---|
| Arena | `cave_8_12` Hoard Floor. Entrance east (rows 4-5). Four coin heaps (burrow points) at (288, 288), (288, 672), (1056, 480), (1536, 672). Four anchor rings on pillars at (672, 192), (672, 768), (1344, 192), (1344, 768). |
| Boss | A hoard-serpent, head HP 36, radius 70, contact 3. It burrows between the heaps (submerged, untargetable) and rears at the heap nearest to Tamsin that is at least 288 px away. Plates: each `Reelable`, HP 1. The head takes hook, flare, pot or sling damage only when it has no plates. |
| Required | Reel line. A reel tip hit yanks a plate off (5 brass bits drop where it lands at Tamsin's feet). Tamsin can also reel herself to a ring: invulnerable during the pull. |
| Fight length | About 160 s. |

| Phase | HP | Attack | Numbers |
|---|---|---|---|
| 1 | 36 to 20 | Rear | Heap quivers 0.9 s (coin ripples), the head rears and stays up 6.0 s with 3 plates (brow, left cheek, right cheek). Plates regrow one per 4.0 s while it is up. After the third plate is pulled the head is **bare** for the rest of the time and 2.0 s more (hittable). Then it burrows. |
| 1 | | Bite | Telegraph 0.5 s, cone 180 degrees, radius 150, damage 4. |
| 1 | | Coin volley | While plated, every 2.5 s: 5 coins, +-30 degrees, 280 px/s, damage 2. Ward blocks. |
| 2 | 20 to 0 | Rear, 4 plates | Adds a crown plate; up 5.0 s; interval 8.0 s. |
| 2 | | Tail sweep | A tail breaks out of a second heap: telegraph 0.7 s, 96 px band across a row, damage 3. Not blockable. |
| 2 | | Coin ring | 8 coins, 260 px/s, damage 2. Ward blocks. |

Drops: Fragment of Trade, wick core. Art: a long serpent of bronze coin plates with a gold crown on its head, coins streaming off it, a jaw like a purse.

### 4.9 C9 Lock Warden

| Field | Value |
|---|---|
| Arena | `cave_9_10` Lock Floor. Entrance north (columns 9-10). Resupply: yes. The Lock fills a block at (960, 600), 288x240 px, body contact 2 (it does not move). |
| Parts | Four **plates** at the lock's corners (offsets (-128,-96), (128,-96), (-128,96), (128,96)), HP 4 each, behind **lids**. A lid-eye above each plate is hit by the sling to open it for 6.0 s. A plate takes damage from explosions (4) and thrown hits (3); all else deals 0. Core (phase 2): the **keyhole**, HP 24. |
| Required | Pitch pot (to break plates, up to 18 pots carried) and tallow sling (to open lids). |
| Fight length | About 170 s. |

| Phase | Attack | Numbers |
|---|---|---|
| 1 (plates) | Key volley | Every 3.5 s, telegraph 0.6 s, 8 keys in a ring, 260 px/s, damage 2. Ward blocks. |
| 1 | Deadbolt | Every 8.0 s. Telegraph 1.0 s (a slot of 192 px in a vertical bar lights). A bar sweeps west to east at 300 px/s across the room, damage 4, except in the lit slot. Not blockable; the boots' leap clears it. |
| 1 | Wicklings | Two at phase start. |
| 1 | Plate broken | Drops 1 pot bundle (amount 2). |
| 2 (all plates broken) | Tumbler turn | Every 5.0 s the keyhole opens for 3.0 s (telegraph 0.5 s, a click): all weapons deal damage (hook 2, flare 4, pot 4, sling 1). Closed: invulnerable. |
| 2 | Key volley | Every 3.0 s, 12 keys. Deadbolt every 6.0 s. Two wicklings at phase start. |

Drops: Corrow's Last Wick (ninth fragment), wick core. Art: a huge brass door-lock with four hinged plates, a lidded eye on each, a keyhole that glows like a lamp.

### 4.10 C10 The Unlit

| Field | Value |
|---|---|
| Arena | `cave_10_14` The Ninth Lantern. Entrance east (rows 4-5). The Ninth Lantern hangs at (960, 288), radius 110, held by three chains. Resupply: yes. No pits. |
| Boss | The Hush's heart. Three phases, total 75: P1 five eyes (HP 3 each = 15), P2 the wax shell (36), P3 the heart (24). |
| Required | Phase 1 tallow sling, phase 2 cinder wick, phase 3 reel line. Ward and hook used throughout. |
| Fight length | About 420 s. |

| Phase | Target | Attack | Numbers |
|---|---|---|---|
| 1 Eyes | 5 orbiting eyes (HP 3 each, hurtbox accepts only `&"sling"`) | Orbit | Radius 330 px around the mass at (960, 288), 24 degrees/s; every dead eye speeds the rest by 25 %. The mass has contact 2 (radius 120) and cannot be hurt. |
| 1 | | Gaze bolts | Each open eye fires every 3.5 s (0.7 s apart), telegraph 0.5 s, 320 px/s, damage 2. Ward blocks. |
| 1 | | Hands | Every 5.0 s two hush hands at floor markers (radius 100, 1.0 s) near Tamsin, damage 4, stay 2.0 s (HP 2, obstacles). Not blockable. |
| 1 | | Hounds | With 3 eyes left, 2 husk hounds enter (max 2 alive). |
| 2 Wax | Shell (36). The mass drops to (960, 480) in a thick wax shell, walks toward Tamsin at 70 px/s. Takes damage only from fire (2 per tick) and explosions (2). Hook, flare, sling, reel deal 0. | Wax wave | Every 4.0 s. Telegraph 0.8 s (shell glows). A ring 0 to 720 px at 360 px/s, thickness 96, damage 3. The ward negates it when the mass is in front. |
| 2 | | Drips | Three wicklings every 12 s. |
| 2 | | Burn | While a flame is attached, the wave pauses. About 3 flame casts (12 damage each) finish the shell. |
| 3 Lantern | The heart (24), shielded by the lantern's glow | Lantern pull | Fire the reel line at the lantern hook (a `Reelable`, within 576 px). The lantern slides 288 px toward Tamsin and drops: the heart is exposed for 6.0 s (hook 2, flare 4, pot 4). Then the chains re-hoist it and the heart is shielded. Three pulls, 8 HP each. |
| 3 | | Hush torrent | Every 4.0 s, 4 homing bolts, 240 px/s, turn 90 degrees/s, lifetime 4.0 s, damage 2. Ward blocks. |
| 3 | | Chain lash | Every 6.0 s. Telegraph 0.8 s. A 96 px line from a post to the opposite wall, damage 3. Not blockable. |
| 3 | | Heart pulse | While exposed, every 3.0 s a ring 0 to 400 px in 0.6 s, damage 3, ward blocks. 2 husk hounds per cycle. |

Death: 2.0 s fade, the Ninth Lantern settles at (960, 480), no pickups. The ending trigger appears (`ending_trigger.gd`, section 7.3): two sockets
left and right of the lantern, touching one chooses "rekindle" or "become the Wickwarden" (`story.md`). Art: a vast mass of wax, rope and old
tools around a dim lantern, five lidless eyes orbiting it, a heart glowing under the lantern when it is pulled down.

---

## 5. The eight new tools

All eight are `ItemBase` subclasses registered in `ItemRegistry` with a scene
`res://scenes/items/<id>.tscn`, found in the cave the plan names, and chosen with `cycle_item`. The existing
rules stay: `activate()` returns false to refuse (the node is freed), the World frees items on a room change, behaviour
runs in `_physics_process`. Ids: `cinder_wick`, `tallow_sling`, `reed_raft`, `heft_mitts`, `glow_jar`,
`lantern_chime`, `skitter_boots`, `reel_line`.

Same table style as `dev-world-plan.md` section 4 (sub-items):

| Item | Analog | Behaviour | Ammo |
|---|---|---|---|
| **Cinder wick** | Candle | Rolls a small flame up to 288 px ahead (stops 96 px ahead if something solid, burnable or an enemy is there). The flame burns 3.0 s, ticks 1 damage per 0.5 s, sticks to the first enemy it touches, burns thorns, webs and lights braziers. One flame at a time. | none |
| **Tallow sling** | Bow | Fires a tallow slug at 720 px/s, range 840 px, damage 1, in a straight line. Hits eye switches and fliers from range. One slug on screen. | max 30; 12 on first pickup; slug bundle +6 |
| **Reed raft** | Raft | Used at a mooring: Tamsin boards a raft and steers it at 240 px/s over open water to any other mooring. Hook, flare and ward only while on the raft. | none |
| **Heft mitts** | Power glove | Lifts a small rock, urn or lit pot (carry 252 px/s), throws it 480 px for damage 3; lifts or pushes heavy stones. | none |
| **Glow jar** | Lens | Throws a jar 288 px that glows radius 520 px for 6.0 s; shows hidden seams, ghost walls and sealed stairs. One jar at a time. | none |
| **Lantern chime** | Flute | Tap: a ring wave of radius 480 px that wakes resonance stones and stuns singers. Hold 1.2 s: choose a rekindled cave mouth and warp there. | none |
| **Skitter boots** | Jump feather | A leap of 192 px in the facing direction (0.4 s), invulnerable in the air; clears pits, ravines and low rails. | none |
| **Reel line** | Hookshot | Shoots the hook on a line 576 px; if it hits an anchor ring Tamsin is pulled across; pulls plates and light enemies; fetches small pickups. | none |

The pitch pot's limit rises from 10 to 14 (pot bag P1) and 18 (pot bag P2); this is binding (section 0).

### 5.1 Cinder wick (`cinder_wick`, found in C1 `cave_1_5`)

| Aspect | Spec |
|---|---|
| Use | `use_item`. `activate()` refuses if a flame of this item exists (`active_count() > 1`). Tamsin is rooted for 0.2 s (hands up), then the flame leaves. |
| Flame | Spawns 48 px ahead and rolls at 480 px/s for up to 288 px. It stops at the first `WORLD` body, `Burnable`, brazier or enemy hurtbox. If something solid or burnable is within 96 px it is placed at 96 px. It stands for 3.0 s (fade out the last 0.4 s). Radius 56 px. |
| Damage | `Hitbox`, team PLAYER, kind `&"fire"`, `once_per_target = false`, damage 1 per tick every 0.5 s (6 per flame), knockback 0. A flame that touches an enemy attaches to it and follows it for the rest of its 3.0 s. Bramble snapper: one tick kills. Wickling: fire kills. Wisp and Kilnkeeper: see tables. |
| Props | Hitting a `Burnable` prop (group `burnable`, `on_fire(pos)`) starts its burn: a thorn hedge is open after 1.0 s and stays open (flag `burned_<id>`). Braziers in range 56 px light as for the hook. |
| Friendly fire | The flame never hurts Tamsin. |
| Cost | No ammo. After the flame is gone there is no extra cooldown (a new cast is allowed). |
| Layers | The flame Hitbox is on `PLAYER_HITBOX`, mask `ENEMY_HURTBOX` + `PROP_HURTBOX`. A ray against `WORLD` stops the roll. `Burnable` props are on `PROP_HURTBOX` with a filter for kind `fire`. No new layer. |
| Gates it opens (5 in the graph) | `e005` `ow_2_0`<->`ow_3_0` thorn hedge; `e129` `ow_3_3`<->`ow_3_3#hut` thorn-sealed door; `e156` `cave_2_2`<->`cave_2_3` thorn wall; `e223` `cave_9_2`<->`cave_9_3` thorn wall; `e234` `cave_10_2`<->`cave_10_3` thorn wall. Placement rule: the hedge sits in the exit gap, 2 tiles wide, and the player can see it before he owns the wick. |
| In combat | Area denial and damage over time: 6 per cast, 12 against a wax-armoured body. Kills bramble snappers, wicklings, thorn wardens (flammable, 2 per tick), melts the Kilnkeeper and the Unlit's shell (2 per tick), burns Briar Mother seeds. Useless against wisps (immune). |

### 5.2 Tallow sling (`tallow_sling`, found in C2 `cave_2_5`)

| Aspect | Spec |
|---|---|
| Use | `use_item` spends 1 slug (`GameState.spend_slug()`). `activate()` refuses if a slug is alive or the count is 0. Tamsin stands still 0.12 s (recoil); no cooldown otherwise. |
| Slug | An `Area2D` hitbox, radius 14 px, 720 px/s, range 840 px. It is destroyed by a `WORLD` body, by the first hurtbox it hits, or at range. Damage 1, knockback 240 px/s for 0.08 s, kind `&"sling"`, team PLAYER, `once_per_target`. |
| Ammo | Max 30 slugs (`GameState.slugs`, `GameState.slug_max()`). The pickup of the item itself grants 12 (like the pot's 6). Slug bundle pickup: +6. Drop chance 8 % once the sling is found. Shops: not in the plan; see Open question 5. There is no ammo upgrade in this spec. |
| Props | `EyeSwitch` (on `PROP_HURTBOX`, filter kind `sling`) toggles on a slug and stays on (flag `eye_<id>`). Placement rule: the switch is in line of sight of a tile within 840 px, with a clear row or column. |
| Layers | `PLAYER_HITBOX` mask `ENEMY_HURTBOX` + `PROP_HURTBOX`; a ray against `WORLD`. No new layer. |
| Gates it opens (6) | `e028` `ow_7_1`<->`ow_8_1` eye-switch portcullis (the Eyegate); `e160` `cave_2_6`<->`cave_2_7` eye-switch portcullis; `e172` `cave_4_2`<->`cave_4_3` eye switch; `e212` `cave_8_2`<->`cave_8_3` eye switch; `e231` `cave_9_2`<->`cave_9_2#cell` eye-switch cell; `e244` `cave_10_12`<->`cave_10_13` eye switch. |
| In combat | A ranged 1-damage poke: duskmoths (1 HP) at range, watcher eyes (2 slugs), choirlings, wisps (2 slugs) before they reach Tamsin, boss eyes (Briar Mother 12 slugs, the Unlit 15 slugs), Lock Warden lids. Weak against armour. The ward and the sling fit together: hold the ward, drop it, fire. |

### 5.3 Heft mitts (`heft_mitts`, found in C4 `cave_4_5`)

| Aspect | Spec |
|---|---|
| Use | `use_item` facing a `Liftable` or `HeavyStone` within 72 px: a grab hitbox (kind `&"grab"`, damage 0, radius 48, 0.1 s) at 72 px ahead. A hit on a prop that accepts `grab` lifts it (0.25 s). If nothing is grabbed: no-op (0.2 s lockout). |
| Carry | Tamsin walks at 252 px/s. The hook, the flare, the ward and other items are off. `use_item` throws; the `ward` button puts the object down in front of her. A hit on Tamsin drops and breaks the object at her feet. |
| Throw | 480 px at 720 px/s in the facing direction. A `Hitbox` (team PLAYER, kind `&"thrown"`, damage 3, knockback 560 px/s for 0.15 s, once per target) is active in flight; on landing the object breaks (a small puff). Lockout 0.4 s. |
| Props | `Liftable`: rock, urn, a lit pitch pot (its fuse keeps running; a thrown pot explodes where it lands or when the fuse ends). `HeavyStone` has two modes: **lift** (carry as above at 216 px/s; thrown objects shatter on landing and the gap stays open: flag `moved_<id>`) for heavy stones; **push** for boulders and heavy doors (hold toward it for 0.5 s, it slides 96 px, repeatable up to 3 steps, stops at a wall; the final position is permanent). |
| Layers | `Liftable` and `HeavyStone` are `WORLD` bodies with an `Area2D` grab zone on `PROP_HURTBOX` (filter kind `grab`). The thrown `Hitbox` is `PLAYER_HITBOX`. No new layer. |
| Gates it opens (6) | `e063` `ow_9_3`<->`ow_9_4` heavy stones (lift); `e175` `cave_4_5`<->`cave_4_6` heavy stone (lift); `e198` `cave_6_8`<->`cave_6_10` heavy door (push); `e228` `cave_9_5`<->`cave_9_8` heavy stone (lift); `e239` `cave_10_5`<->`cave_10_8` heavy stone (lift); `e251` `ow_6_6`<->`cave_6_1` heavy boulder (push, the mouth of C6). |
| In combat | Throws shards, rocks and lit pots at range (3 damage, 6 against the Colossus). It leaves Tamsin helpless while carrying (no ward, no hook): lift only when the room is calm. |

### 5.4 Reed raft (`reed_raft`, found in C3 `cave_3_5`)

| Aspect | Spec |
|---|---|
| Use | `use_item` within 72 px of a `Mooring` post: board (0.3 s). Anywhere else `activate()` refuses. The raft is a vehicle, not an inventory object; it needs no ammo. |
| Riding | External-motion state `RAFT` on the Player. Free steering, 8 directions, 240 px/s, acceleration 0.2 s, deceleration 0.4 s. The body shape is off; the raft position is clamped to the union of `WaterZone` areas (deep water). It crosses room edges through water gaps like walking does. |
| While on the raft | Hook, flare and ward work; items other than the raft are off. The hurtbox stays on: a hit pushes the raft 96 px, never out of the water. `use_item` or walking into a dock zone near a `Mooring` (radius 80 px) lands Tamsin on the mooring's landing marker. |
| Props | `Mooring` (a post on `WORLD` plus a dock zone `Area2D`, mask `PLAYER_BODY`) and `WaterZone` (deep or shallow; deep water has a blocking body on the new layer `WATER` that walkers and ground enemies collide with). |
| Layers | New layer 11 `WATER` (bit 1024): the blocker body of deep water. `PLAYER_BODY` and `ENEMY_BODY` masks gain `WATER`; fen leeches, the raft and flying monsters (duskmoth, wisp, choirling) do not. |
| Gates it opens (26) | 22 `mooring and water` links between the lake rooms and their shores in the overworld (`e027`, `e042` to `e046`, `e055`, `e057` to `e061`, `e069`, `e071` to `e075`, `e086`, `e088` to `e090`) and 4 `flooded passage` links in caves: `e167` `cave_3_5`<->`cave_3_6`, `e168` `cave_3_6`<->`cave_3_7`, `e225` `cave_9_4`<->`cave_9_5`, `e236` `cave_10_4`<->`cave_10_5`. |
| In combat | A mobile platform. Fen leeches attack the rider (they surface within 300 px). Tidewick can only be fought from it. Fighting with the hook from the raft is full strength. |

### 5.5 Glow jar (`glow_jar`, found in C5 `cave_5_5`)

| Aspect | Spec |
|---|---|
| Use | `use_item` throws a jar to 288 px ahead (arc 0.45 s, stops short at a wall). `activate()` refuses while a jar glows. |
| Glow | A `PointLight2D` radius 520 px (fade in 0.3 s, full 4.7 s, fade out 1.0 s = 6.0 s total). The jar node is in group `glow_light`; `GlowJar.is_lit(pos)` is true within 520 px of a live jar. Tamsin's own lamp (260 px) does not count. |
| Reveal | `HiddenSeam` props (group `revealable`) within 520 px brighten; after 1.0 s of continuous exposure they unseal for good (flag `revealed_<id>`) and become a normal passage or stairs. |
| Layers | None. The jar is a node, light is a `PointLight2D`, `is_lit` is a distance check against the group. |
| Gates it opens (6) | `e144` `ow_11_7`<->`ow_11_7#cache` sealed seam; `e185` `cave_5_5`<->`cave_5_6` hidden seam; `e195` `cave_6_6`<->`cave_6_7` hidden seam; `e237` `cave_10_5`<->`cave_10_6` hidden seam; `e252` `ow_10_2`<->`cave_7_1` hidden stairs; `e254` `ow_0_2`<->`cave_9_1` hidden stairs. Placement rule: each seam is a faint scuff that stays hidden until a jar lights it; the player can throw the jar from any tile within 520 px of it. |
| In combat | A light, not a weapon (damage 0). It strips the decoy of the mirror shade, shows the real Archivist, lights dark rooms for 6 s. |

### 5.6 Lantern chime (`lantern_chime`, found in C6 `cave_6_5`)

| Aspect | Spec |
|---|---|
| Tap | `use_item` rings the chime: a ring wave from Tamsin, radius 0 to 480 px over 0.5 s. A `Hitbox` (team PLAYER, kind `&"chime"`, damage 0, `once_per_target`) with no knockback. Cooldown 1.2 s. |
| What it does | `ResonanceStone` and resonance doors/vaults (group `resonant`, `on_chime()`) wake when the wave reaches them and stay awake (flag `resonated_<id>`). Enemies with `chime_stun_time > 0` are stunned: choirling 2.5 s, Dirge head (only while it sings) 4.0 s, Corrow's Echo (only while it charges) 2.0 s. Nothing else is affected. |
| Hold | Hold `use_item` 1.2 s: the world pauses and a warp picker (new UI, list of the cave mouths whose flag `mouth_cN` is set) opens. Select a mouth to warp (World fade 0.3 s). Not allowed in a boss arena. See Open question 8. |
| Layers | A `Hitbox`; `ResonanceStone` is an Area2D on `PROP_HURTBOX` with filter kind `chime`. No new layer. |
| Gates it opens (4) | `e194` `cave_6_5`<->`cave_6_6` resonance stone; `e232` `cave_9_9`<->`cave_9_9#vault` resonance vault; `e238` `cave_10_6`<->`cave_10_7` resonance stone; `e253` `ow_9_7`<->`cave_8_1` resonance door (the mouth of C8). |
| In combat | A timing tool against singers: ring it during a song. The Dirge Choir and Echo fights rely on it. |

### 5.7 Skitter boots (`skitter_boots`, found in C7 `cave_7_5`)

| Aspect | Spec |
|---|---|
| Use | `use_item` leaps 192 px (2 tiles) in the facing direction in 0.4 s (480 px/s). Cooldown 0.5 s after landing. Refused while carrying, on the raft or in hit-stun. |
| Air | External-motion state `LEAP`. Controls locked, Tamsin's hurtbox off (i-frames for the whole 0.4 s), body shape off. A shape cast along the path against `WORLD` stops the leap at a wall; a low rail (group `leapable`) does not stop it. Tamsin lands on solid floor or falls. |
| Fall | A `PitZone` under her feet at landing (or walking into it): 2 half-hearts damage (ignores i-frames) and she respawns at the room entry spawn. |
| Geometry | A pit or ravine gap must be 96 to 144 px wide in the leap direction. Wider gaps (288 to 480 px) are anchor-ring chasms for the reel line, not boots gaps. |
| Layers | New layer 12 `FEET` (bit 2048): a small foot sensor (radius 10 px) on the Player and on enemies that can fall (Pale Squire); `PitZone` is an Area2D with mask `FEET`. No collision effect. |
| Gates it opens (7) | `e093` `ow_9_5`<->`ow_9_6` ravine leap; `e104` `ow_8_6`<->`ow_9_6` ravine leap; `e205` `cave_7_5`<->`cave_7_6` pit; `e206` `cave_7_6`<->`cave_7_7` pit; `e216` `cave_8_6`<->`cave_8_7` pit; `e226` `cave_9_5`<->`cave_9_6` pit; `e240` `cave_10_8`<->`cave_10_9` pit. |
| In combat | A dodge: 0.4 s of invulnerability and 192 px of movement across hazards (dives, deadbolt, rings). Crosses pit arenas (Gloam Knight). Does not damage. |

### 5.8 Reel line (`reel_line`, found in C8 `cave_8_5`)

| Aspect | Spec |
|---|---|
| Use | `use_item` fires the hook tip along the facing: 1200 px/s, range 576 px, then retracts at 1400 px/s. One line at a time; cooldown 0.3 s after it retracts. A visible line connects Tamsin and the tip. |
| Anchor | The tip hitting an `AnchorRing` pulls Tamsin along the line at 900 px/s to 72 px before the ring (external-motion state `REEL`, hurtbox off during the pull, body off so she crosses pits and water). She lands on solid floor beyond the ring or the pull is refused. |
| Other hits | Tip damage 1, kind `&"reel"`. `Reelable` parts (boss plates, the lantern hook) are yanked off or toward Tamsin. A light enemy (HP 2 or less and flagged `reel_light`: wickling, duskmoth, husk hound, cinder wisp, choirling, tallow drop) is pulled to Tamsin and stunned 0.8 s. Small pickups are carried to her (the tip has a carrier `PickupCollector`). The tip is stopped by `WORLD`. |
| Geometry | The chasm in front of a ring is 288 to 480 px wide; the ring is within 576 px of the firing tile. Boots cannot cross it. |
| Layers | The tip `Hitbox` is on `PLAYER_HITBOX` (mask `ENEMY_HURTBOX` + `PROP_HURTBOX`); `AnchorRing` and `Reelable` are `PROP_HURTBOX` Area2D with filter kind `reel`. No new layer. |
| Gates it opens (5) | `e079` `ow_10_4`<->`ow_10_5` anchor ring (Anchor Ledge, cliff to Hushmarch); `e145` `ow_8_8`<->`ow_8_8#cache` anchor ring pocket; `e215` `cave_8_5`<->`cave_8_6`; `e227` `cave_9_6`<->`cave_9_7`; `e241` `cave_10_9`<->`cave_10_10`. |
| In combat | Pulls Coinwyrm plates and the Unlit's lantern, yanks light enemies into hook range, fetches pickups, and is an escape (the pull is invulnerable). |

### 5.9 Combat matrix (what each answer does)

`X` = strong answer, `o` = works, `-` = no effect, `!` = blocked or harmful.

| Target | Hook | Flare | Pot | Moth | Wick | Sling | Ward | Mitts | Jar | Chime | Boots | Reel |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Bramble snapper | o | X | X | - | X | o | - | - | - | - | - | - |
| Fen leech (surfaced) | X | X | o | X | o | o | - | - | - | - | - | - |
| Cinder wisp | X | o | o | X | - | o | X | o | - | - | - | o (pull) |
| Watcher eye | X (lid open) | o | - | o | - | X | X | - | - | - | - | - |
| Husk hound | X | X | X | X | o | - | - | o | - | - | o | o (pull) |
| Brine crab | o (side/back) | X | X | X | o | o (back) | - | o | - | - | - | - |
| Wickling | X | X | o | - | X | - | - | - | - | - | - | o (pull) |
| Mirror shade | o | o | o | o | o | o | X (flank) | - | X | - | - | - |
| Choirling | X | X | o | o | o | o | X | - | - | X (stun) | - | o (pull) |

---

## 6. Difficulty curve across the caves

Hearts are from the world plan section 6.2 (hearts on entry, minimum with only boss cores, typical with about half
of the hidden cores). "Hits to die" is half-hearts divided by the boss's largest single hit, rounded up. The
largest single hit of a boss is the one with at least the heavy telegraph (section 1.2). Fight length is the
expected time for a player who knows the pattern.

| Cave | Tool gained | Hearts min / typ | Miniboss HP / max hit | Boss HP | Boss largest hit | Hits to die (min / typ) | Boss phases | Fight (s) | New monsters in the cave |
|---|---|---|---|---|---|---|---|---|---|
| C1 | cinder wick | 3 / 3 | 12 / 3 | 24 | 2 | 3 / 3 | 2 | 90 | wickling |
| C2 | tallow sling | 4 / 5 | 16 / 2 | 28 | 2 | 4 / 5 | 2 | 120 | bramble snapper |
| C3 | reed raft | 5 / 7 | 16 / 3 | 24 | 3 | 4 / 5 | 2 | 100 | fen leech |
| C4 | heft mitts | 6 / 9 | 24 / 4 | 48 | 3 | 4 / 6 | 3 | 140 | cinder wisp |
| C5 | glow jar | 7 / 11 | 18 / 2 | 30 | 3 | 5 / 8 | 3 | 150 | mirror shade |
| C6 | lantern chime | 8 / 12 | 20 / 2 | 36 | 3 | 6 / 8 | 3 | 150 | choirling |
| C7 | skitter boots | 9 / 14 | 16 / 2 | 36 | 4 | 5 / 7 | 2 | 150 | none (pit arenas) |
| C8 | reel line | 10 / 16 | 28 / 3 | 36 | 4 | 5 / 8 | 2 | 160 | brine crab |
| C9 | none | 11 / 18 | 30 / 3 | 40 | 4 | 6 / 9 | 2 | 170 | none (uses all tools) |
| C10 | none | 12 / 20 | 36 / 4 | 75 | 4 | 6 / 10 | 3 | 420 | watcher eye, husk hound (from the overworld) |

Reading the curve:

- Hits to die stays between 3 and 10 and grows slowly, because the hearts curve grows 3 to 20. Boss HP and phases grow faster: that is where the extra difficulty lives, as the plan asks (counts, combinations, tools).
- Largest hit: 2 (one heart) in C1 and C2, 3 in C3 to C6, 4 (two hearts) from C7. Regular monsters never hit for more than 2 (hollow, hound, crab, leech, snapper), so cave trash stays a chip-damage problem.
- Each boss introduces one idea and no more than two new rules: wax armour and fire (C1), part targeting with a ranged tool (C2), the vehicle (C3), carried ammunition (C4), the identity puzzle (C5), timing (C6), terrain (C7), the pull (C8), a two-tool puzzle (C9), the three-tool exam (C10).
- A player who arrives with only the minimum hearts is never below 3 hits from death at any boss, and the typical player never below 5.
- Regular monster pressure per room is in the world plan (counts per cave, 17 to 38 enemies).

---

## 7. Code contract additions

Not implemented here. This section lists what `code-contract.md` would need for a later work package to build this spec.
Rules of that contract still apply (no `class_name` in WP files, `load()` not `preload()`, behaviour in `_physics_process`,
`Visual` child, `Layers.*`).

### 7.1 Collision layers

| Layer | Value | `Layers.` | On this layer | Mask detects |
|---|---|---|---|---|
| 11 | 1024 | `WATER` | blocker bodies of deep water | player, ground enemies add it to their mask; leeches, raft, flyers do not |
| 12 | 2048 | `FEET` | foot sensors (Player, Pale Squire) | `PitZone` has mask `FEET` |

Everything else uses the existing layers: `PROP_HURTBOX` for props that react to a hitbox kind (with a `Hurtbox.filter`),
`PLAYER_HITBOX` for item hitboxes, `ENEMY_HITBOX` for enemy attacks.

### 7.2 API changes

| File | Change |
|---|---|
| `scripts/core/layers.gd` | add `WATER`, `FEET`. |
| `scripts/combat/hitbox.gd` | new kinds `&"fire"`, `&"sling"`, `&"reel"`, `&"thrown"`, `&"grab"`, `&"chime"`; new field `block_destroys_carrier := true` (false for cones, bursts and rings, so the ward negates the hit without killing the attacker); new field `tick_interval := 0.0` (fire flame hits every 0.5 s with `once_per_target = false`). |
| `scripts/enemies/enemy_base.gd` | new fields `stun_scale := 1.0`, `knockback_scale := 1.0`, `chime_stun_time := 0.0`, `reel_light := false`, `armor_front_deg := 0.0` (guard arc), `water_only := false`, `ignore_water := false`; new virtual `_resolve_damage(hitbox, amount) -> int` (return 0 to block; default returns `amount`), called by the base before applying a hit; new `signal guard_blocked(hitbox)`. Existing hooks are unchanged. |
| `scripts/enemies/enemy_projectile.gd` | optional `homing_turn_deg`, `shape_capsule` (for the watcher beam). |
| `scripts/player/player.gd` | state enum `NORMAL, CARRY, RAFT, LEAP, REEL` and `begin_external_motion(mode, path_or_controller)` / `end_external_motion()`; foot sensor on `FEET`; `set_hurtbox_enabled(bool)`; the existing `use_item()` stays generic (it only asks `ItemBase`). |
| `scripts/autoload/game_state.gd` | `slugs`, `slug_max()` (30), `pot_max()` (10, plus 4 per pot bag flag `pot_bag_1`, `pot_bag_2`, so 14 and 18; `PITCH_POT_MAX` stays as the base), `add_slugs(n)`, `spend_slug() -> bool`; signals `slugs_changed`, `pot_max_changed`. Pot bags come from pickup kind `pot_bag`, which sets the next flag. |
| `scripts/pickups/pickup_base.gd`, `scenes/pickups/` | new kinds `slug_bundle` (+6) and `pot_bag` (raises `pot_max()` by 4); item-found ammo constants for the sling (12). |
| `scripts/pickups/drop_table.gd` | `pick(roll, pitch_pot_found, sling_found)`: slug bundle 8 % (section 1.5). |
| `scripts/ui/hud.gd` | slug count for the sling, pot count shows the new maximum. |
| `scripts/items/item_registry.gd` | register the eight ids and scene paths of section 5. |

### 7.3 New files

Names and scene paths follow the existing pattern (`scripts/<dir>/<name>.gd` + `scenes/<dir>/<name>.tscn`).

| Group | Files |
|---|---|
| Tools | `scripts/items/{cinder_wick,tallow_sling,reed_raft,heft_mitts,glow_jar,lantern_chime,skitter_boots,reel_line}.gd` + `scenes/items/*.tscn`; helpers `flame.gd`, `slug.gd`, `jar.gd`, `chime_wave.gd`, `reel_tip.gd` (+ scenes) |
| Props | `scripts/world/{burnable,eye_switch,mooring,water_zone,pit_zone,anchor_ring,reelable,liftable,heavy_stone,resonance_stone,hidden_seam}.gd` (+ scenes) |
| UI | `scripts/ui/warp_picker.gd`, `scenes/ui/warp_picker.tscn` |
| Regular monsters | `scripts/enemies/{bramble_snapper,fen_leech,cinder_wisp,watcher_eye,husk_hound,brine_crab,wickling,mirror_shade,choirling}.gd` + scenes; projectile scenes `beam_bolt.tscn`, `thorn_needle.tscn`, `note.tscn` |
| Minibosses | `scripts/enemies/{hollow_captain,thorn_warden,sump_lurker,lull_mauler,mirror_warden,choir_warden,pale_squire,abacus_brute,wick_automaton,corrows_echo}.gd` + scenes |
| Boss framework | `scripts/enemies/boss_base.gd` (`extends EnemyBase`: `boss_id`, `phase`, `thresholds`, `_enter_phase(n)`, intro, reset on leave, flag `boss_<arena room id>_defeated`, death drops, resupply timer), `boss_part.gd` (`extends EnemyBase`: eyes, plates, heads, tail; reports damage to the owner boss), `telegraph.gd` (a floor marker node: shape circle, rect or cone, duration, signal `finished`; the attack node spawns its `Hitbox` on `finished`) |
| Bosses | `scripts/enemies/{kilnkeeper,briar_mother,tidewick,hushed_colossus,archivist,dirge_choir,gloam_knight,coinwyrm,lock_warden,the_unlit}.gd` + scenes, with part scenes (`seed_eye`, `wax_plate`, `choir_head`, `lock_plate`, `coin_plate`, `unlit_eye`) |
| Ending | `scripts/world/ending_trigger.gd` + `scenes/world/ending_trigger.tscn` (two sockets, flags `ending_rekindle` / `ending_wickwarden`) |
| Placeholders | new `Placeholder.KINDS` entries for each `visual_kind` above; art comes later through `docs/art-brief.md` |
| Tests | `tests/test_<name>.gd` per monster, per tool and per boss (guard tests for armour, ammo, pit fall, raft clamp, ward area hits, phase thresholds, reset on leave, drops) |

Already planned by the world plan and not repeated here: `Grate`, `BossDoor`, `ShopItem`, scoped keys, one-way edges,
world data table, minimap.

---

## 8. Open questions

1. **Minibosses that name a tool found behind them.** C4 (Lull-Mauler: "throw its slag chunks back with the mitts"), C5 (Mirror Warden:
   "light the room with the jar") and C8 (Abacus Brute: "pull its shield rail off with the reel line") name the cave's own
   tool, but in the cave tables the tool lies in the room after the miniboss. This spec keeps the idea with tools held
   then (hook deflect, the corner braziers, a pot on the rail). Alternative: move each miniboss behind the item room, which
   changes the graph and needs the checker rerun.
2. **Boss HP bar.** No bar in the HUD (damage shows on the boss). Add a thin bar?
3. **Reset on leaving.** A boss resets to full HP when Tamsin leaves the room. Persist damage instead?
4. **Cinder wick range.** The plan says a flame "one tile ahead". This spec rolls it up to 288 px (it stops 96 px ahead when something
   is there) so that it can light "far braziers" as the plan's tool table says. Sticking to enemies is also new. Accept?
5. **Sling ammo supply.** Resolved by decision 9: shops S3, S4 and S5 sell a slug bundle. Numbers (max 30, 12 on pickup, bundle +6,
   8 % drop) are mine. The price, 10 brass, is a proposal (decision 7: prices are set in playtests). Bosses with a sling dependency
   (C2, C9, C10) get resupply bundles.
6. **Pot bags.** The final limit is 18 (user). The step split (10, 14, 18: +4 per bag) is mine. Confirm, and update
   world-plan 6.4, which still says 15 and 20.
7. **Raft steering and lanes.** The plan says Tamsin rides "to the next mooring". This spec uses free steering within `WaterZone`s,
   docking only at moorings. A fixed lane (auto-ride) is simpler to build and would make Tidewick a different fight.
8. **Chime warp.** Resolved (decision 37): flag `mouth_cN` is set on the first entry of cave N's mouth room, so the list shows each mouth entered so far. C9 and C10 are listed the same way. Warp from inside a cave: yes, everywhere except boss arenas.
9. **Rekindle scene.** Collecting a fragment should trigger the story's memory scene. Not specified here; the boss spec only drops
   the pickup.
10. **Ending choice.** The two sockets and the interaction (hook strike on one, hold the ward toward the other) are placeholders.
11. **Ward while using items.** The plan says nothing on holding the ward and `use_item` together. This spec allows it except while
    carrying or on the raft.
12. **Mirror shade fallback.** Without the jar the player has two cues (footprint ripples, a cracked decoy shows the real
    shade). Are they enough, or should the first C5 rooms hold only one shade?
13. **Moth on minibosses and bosses.** The dev plan stuns for 2.0 s; this spec clamps it to 1.5 s (1.0 s for Echo) on minibosses and
    makes bosses immune. Contradicts nothing in the world plan, but it changes how "moth stun recommended" reads for bosses.
14. **Miniboss and boss persistence.** Minibosses stay dead after a kill (flag). The plan's rule R8 says enemies respawn on entry;
    this spec treats minibosses and bosses as the exception.
15. **Dev-plan wording.** `AGENTS.md` and the dev plan say "five monster types". There are now 14 regular types. Update when the
    first monster WP lands.
16. **Boss fight length in C10.** About 7 minutes in three phases. Too long for one fight with no checkpoint? A checkpoint at each phase is possible
    but not specified here.
