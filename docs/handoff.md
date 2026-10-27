# Wickwarden — orchestrator handoff

Audience: a new orchestrator (an agent session or a human) who takes over the build with no other context.
Language: English. The owner writes Swedish; see section 7 for how to talk to him.

Read this file first, then [state.md](state.md). The rules for agents are in [../AGENTS.md](../AGENTS.md).

---

## Status (update at every push)

**Working-tree handoff, 2026-10-27:** This snapshot supersedes the older
checkpoint descriptions below where they describe current status. Progress
checkpoint `aa6fc158087e4a5be21be22acf948f1f69c9cf8b` was pushed and verified
on `origin/main`, excluding the 77 previously staged paths; documentation
checkpoint `e3af885` followed it. The runtime push used the
already signed-in `mikaelliljedahl` account without a global account switch.
The Q3 route was subsequently committed and pushed as
`80792dbe61db8817227160b47957d780692ae6a2`, verified on `origin/main`.
The Q3, Q6 and Q7 extensions, tests and documentation followed in
`e8e4b4e6bce2eb5075e0e788a1fd5a1642ed427a`, verified on `origin/main`.
The Colossus victory and Q8 probe followed in
`d5a0c067825d8b594d7dbb2576153afef088fd2e`, verified on `origin/main`.
The Q7 extension followed in `791cbc77c8910656690b10313532d59c0bcb3ea7`,
verified on `origin/main`.
The C5 Lockpick route, Q7 extension and B10 chain art followed in
`14a2217b1286193fa0db8c30d0508e753d6234ac`, verified on `origin/main`.
The Q7 extension to 15 selected encounters followed in
`ee9145abfc632da422d4f003acc68d7cdbca0e3e` on `origin/main`.
The Unlit's painted wax wave and its tests followed in
`6fc7bfba29725a5237512ef2d15fe5d879a1127e`, verified on `origin/main`.
The Archivist victory and selected actual-tool cases for all 20 encounters
followed in `7332bc07df0937c060f52cb0bd30f842627a3130` on `origin/main`.
The Tidewick warning and Q7 gate cases followed in
`faf963214f4a7bae92d04ca18e99dc5e6facc65a`, verified on `origin/main`.
The Q7 wall and raft cases followed in `81a240e5193f077112b2600c096760d1842732e6`
on `origin/main`.
The Wick Automaton jet followed in `bb7c6f8cf0c72d4077a0eb3463de3cef8f1c863a`,
verified on `origin/main`.
The Dirge Choir victory and C6 core audit followed in
`14b7836107ece10c61c1e6236e6371000314684a`, verified on `origin/main`.
The Q7 vegetation, rocks and gate cases followed in
`a53fc9d47010cf9bd85ff4b9933c5d093fd399f6`, verified on `origin/main`.
The P08 seam presentation and Q7 raft passage and ravine cases followed in
`8dbbabab106ef53b7077ad30142d83c895bdcdfa`, verified on `origin/main`.
The Q7 scoped-key, Lockpick and Ninth Door cases followed in
`0801f43502015e8de47efe795083c766ac2fc231`, verified on `origin/main`.
The Gloam Knight test victory and M0 guard spark followed in
`3a36abb362921cbb611de24bc3b04d8cb15fb813`, verified on `origin/main`.
The Q7 one-way test and open landing observation followed in
`ce9dc584bd69c95611d002c327cb74c7545213d4`, verified on `origin/main`.
The confirmed one-way softlock was documented in `2c16eb3`; the Coinwyrm
victory and B10 heart pulse followed in `6f33c122604c7b06faed35152b49963ccb068337`,
verified on `origin/main`. The revised softlock fix followed in
`ed79ed0eb3b9525bd13c8d8302da0b5a3141c891`, verified on `origin/main`;
independent review passed without blockers and the lead's full `make check` passed.
The 21 Q7 wrong-tool gate cases followed in
`3b96eec2c6edc2d32b3a1b00f3643f8c034a81c4`, verified on `origin/main`.
The Q7 gate audit and rush-screen case followed in
`10738c75441046f3fb315f75d2a17cf584fd3ea7` on `origin/main`.
The earned C9 boss approach followed in `c3f759fb94cb7ba317a4c5329caa669e071344cc`,
verified on `origin/main`; it does not establish a C9 victory.
The continuous C9 plate phase followed in
`44d0f0ea5dd5dc3892c580c3bc3d75db215ea20d`, verified on `origin/main`; it
reaches phase two without establishing a boss victory.
Those 77 staged paths retain fingerprint
`cc7b8baf06d7e79c8d9ed63e5c68b4e971422c0795514e2e8381c9c1771cf4a3`.
An old empty `index.lock` from 16:21 without an active holder was moved to
`.git/index.lock.preserved-20261027` to sync the index; preserve that file.
Other tracked and untracked work may change concurrently; preserve it and
review the actual index, dependencies and remote before integration or push.

**C9 phase-two survival probes (isolated, unintegrated):** The continuous
earned route reaches phase two at 13/26 half-hearts with enemies and damage
active. The best pot probe reduced boss HP from 24 to 16; the player was at
5/26 after the second hit and then died. Sling, hook and flare variants also
died; none demonstrated victory or was integrated. The Q3 bot reads boss,
plate, projectile and player state. Global seed `20261027` does not control or
log Archivist's and Tidewick's own randomization. Another agent is analysing
survival.

**Q3 C9 phase two, committed in `44d0f0e`:** After an ordinary boss death,
respawn and return, the continuous input route uses actual sling and pots to
break all four plates with normal damage and living wicklings. It reaches phase
two with boss HP 24 and player health 13/26; C9 victory and its core remain
unverified. The agent reports five separate green runs, four shards and lint
passing; the lead also passed `make test T=playthrough_1` in the workspace with
the pushed boots fix after phase-two integration. The bot reads plates, eye
positions, lid, phase, HP, player, item and flags. Earlier
bosses also use internal reads; uncontrolled RNG, the C7 low margin, bypassed
living minibosses, other seeds, human play and a complete route remain limits.

**Q3 C9 boss approach, committed in `c3f759f`:** The continuous earned input
route with normal damage obtains the Jar, Wick, first key, raft, boots, second
key, Reel and Lockpick, passes the active miniboss and opens the boss door. After
a deliberate ordinary boss death and respawn at `ow_0_2`, it returns with the
Lockpick and reaches the boss with 25/26 half-hearts, 10 pots and 30 slugs. The
boss is not defeated; unintegrated probes broke plates but died or retreated in
phase two. The C5 physical-reward route was improved after a random failure.
The agent reports four shards, a first-shard repeat and lint passing. These
baseline runs used the original World before the fix; after C9 entry integration,
the lead also passed `make test T=playthrough_1` in the workspace with the
pushed boots fix `ed79ed0`. Archivist's own RNG is uncontrolled, the C7 victory
had a low margin, and other seeds, human play and a complete route remain open.

**C9 resupply probe (isolated):** With real World and input, a fixture starting
at 0 pots and 0 slugs physically collected +4 pots and +6 slugs after the intro,
then collected them again after manual reset to zero and 31 seconds. Four actual
sling/pot eye-and-plate interactions passed; the probe reported 13/13 checks.
Ammo pickups expire after 8 seconds and resupply is at 30 seconds. Damage was
disabled, two wicklings removed and tools fixture-granted; this is not an earned
route, survival test, human play or phase-two victory. An initial attempt with
living wicklings missed a shot; its cause is unknown.

**Q7 gate audit and rush wall, committed in `10738c7`:** Every world-graph
gate family has a representative case, but the full correct/wrong tool matrix
and its printed report are incomplete. Several negative cases do not prove
actual hitbox overlap; the newer base-weapon and rush-Reel cases do. In the new
controlled-position case, the real Reel is rejected and a charged flare cuts
`rush_wall`, with normal player damage and drops disabled. The agent reports
two isolated matrix runs and lint passing. Graph edges, persistence, phases,
real-room and human coverage have substantial gaps.

**Q7 wrong-tool gate cases, committed in `3b96eec`:** Twenty-one cases use
actual hook, charged flare and exploding pot against seven real thorn, eye and
resonance gates. Actual hitbox overlap is checked, with no incorrect opening,
flag or collision change. Arenas are controlled and player damage is normal;
correct-tool positive cases existed previously. The agent reports two isolated
matrix runs and lint passing. Other combinations, real-room and human
verification remain open.

**Fen Leech presentation:** The latest prototype was rejected because it
overlaps at 35 px in darkness. The actual raft sequence provides evidence, but
no art solution has been accepted.

**Q3 Coinwyrm victory, committed in `6f33c12`:** The continuous earned input
route defeats C8's Coinwyrm with normal damage, using three keys, the Reel and
boots and passing an active miniboss. The reported victory leaves 3/24
half-hearts before physical fragment and core collection; the core raises
maximum health from 24 to 26 and restores health to 26. The agent reports five
victories, four isolated shards and lint passing; the original C8 runs used the
unchanged HEAD World. Global seed `20261027` does
not control Archivist's own randomization. The bot reads boss plates, state,
positions and projectiles as well as earlier internal state; the C7 victory had
1/22 health and minibosses remain active. Human play, a complete route and other
seeds remain unverified.

**Z1 revised one-way fix, committed in `ed79ed0`:** Version 3 restores Player
and World byte-identically and places the boots-start overlap check in
`scripts/items/skitter_boots.gd` (`_free_run`/`activate`) to preserve the generic
Player contract. It rejects WORLD overlaps except leapable rails, including a
jump away until the body is clear. The agent reports 120 regression checks
covering natural arrival, free jump starts after 3/15 frames, rails, corners,
real Reel and raft and damage, plus 15 relevant test files, lint and visual
captures. Independent review passed without blockers and verified the generic Player
contract, rail/overlap query, isolated 120-check one-way regression, boots,
raft, Reel, tool matrix and C7–C10 routes. The query is a snapshot, not coverage
of all moving obstacles or angles; a rejected press requires a new press after
clearing the overlap. The lead's full `make check` passed with the reworked fix:
the Godot suite including all four playthrough shards, lint, world-data check
and 175 Python tests. Human real-time play remains unverified.

**Z1 first proposal (not accepted):** At a blocked edge, World
ends external movement and places the player inside the wall plus body radius.
The `e041`/`e087` softlock was reproduced before the fix. The agent reports 62
checks after it with real input and natural landing, both edges and 3/15-frame
controls, observing over 10 seconds, collision, normal damage and walking away;
the fixture grants boots and removes enemies. Movement, boots, World and
C7/C8/C9/Gravelight route tests, lint and visual captures are reported
passing/reviewed by the agent. An independent reviewer identified a risk that
the proposal could cancel raft or Reel movement at a closed edge and place the
player unsafely near corners or obstacles. This is a review finding, not a
reproduced actual route. The proposal was not accepted; the revision is above.

**B10 heart pulse, committed in `6f33c12`:** A new native-alpha source supplies
the painted phase-three heart pulse through the ordinary art pipeline; geometry,
warning, speed and damage are unchanged. The lead reviewed radius 200; the
agent reviewed 40, 200 and 360 and a phase-two regression. The agent reports
isolated B10 and route tests, 22 art tests and lint passing. The source and
prompt are recorded in `tools/source_art/unlit-heart-pulse-z1-log.md` and
`docs/art-provenance.md`. Controlled frozen-ring captures do not establish human
action play; human play remains open.

**Q7 one-way transitions, committed in `ce9dc58`:** Real World cases for
`e041` and `e087` walk down normally and check that boots cannot return from a
controlled position 210 px into the lower room. Enemies are removed and damage
remains active. The agent reports two runs with isolated user data in the shared
project and lint passing. A separate natural-arrival probe confirmed a softlock:
immediate upward boots use reproduced it 3/3 times on each edge, leaving the
player airborne with collision and hurtbox disabled for over 10 seconds.
Enemies were removed, damage active and tools supplied by fixture. Controls
delayed by 3 or 15 physics frames worked. The prior uncertain observation is
superseded; the unaccepted Z1 proposal and its review are recorded above.
The committed controlled-position test does not cover this edge.

**Q3 Gloam Knight victory, committed in `3a36abb`:** The continuous input
route with normal damage and ordinary respawns defeats the C7 boss and
physically collects its fragment and core; the core raises maximum health from
22 to 24 half-hearts and restores health to 24. The C7 miniboss is bypassed and
alive. The bot attacks the Knight from the north with the hook after its dive,
without boots in the fight, and the reported victory leaves 1/22 half-hearts.
It reads mode, phase, target, position, island and hurtbox state; earlier bosses
also use extensive internal-state reads, and Archivist randomization is not
controlled. The agent reports five C7 victories, four isolated shards and lint
passing; a different variant died at C5. Other seeds, human balance and a full
route remain unverified.

**M0 guard spark, committed in `3a36abb`:** The existing painted
`lock_key_volley` impact replaces `Placeholder.puff` on a blocked hit, lasting
0.25 seconds with a fallback if art is unavailable. Position, guard behavior,
damage and sound are unchanged; no new art was added. The agent reports isolated
`enemy_base` and four guard-enemy tests and lint passing. The lead reviewed the
effect with the player in the actual dark `cave_1_5`, with the Captain held
still for reproducibility. Human play and other effects remain open.

**Q7 locks and keys, committed in `0801f43`:** Controlled arena cases physically
collect placed pickups and exercise real scoped locks, a boss door and the Ninth
Door. Wrong scope and sling are rejected; a matching C1 key is consumed, the
Lockpick is retained, and the Ninth Door rejects eight fragments but opens with
nine without consuming them. Player damage is active and there are no enemies.
The agent reports two isolated matrix runs and lint passing. Other combinations,
an actual world route, save/reload and human play remain open.

**Q7 raft passage and ravine, committed in `8dbbaba`:** A real World passage
across `e167` from `cave_3_5` to `cave_3_6` follows the actual moorings with
the raft; the sling does not cross. In a separate real `ravine_leap` arena case
the boots cross and the sling does not. Fixtures grant tools directly and remove
roamers at the source; damage remains active. These are not an earned
playthrough. The agent reports two isolated matrix runs and lint passing. Other
pairs and edges, visual and human verification remain open.

**P08 seam presentation, committed in `8dbbaba`:** At the real seams in
`ow_8_0` and `ow_11_7`, the Placeholder is hidden only when an explicitly
linked RoomDoor has usable painted art. Standalone fallbacks and real seam art
remain; collision, flags and timing are unchanged. The agent reports real-room
reveal/re-entry and `gated_room_doors` tests and lint passing, and reviewed
closed states. The lead reviewed open states in both actual rooms. No new art
was added; human play remains unverified.

**Q7 vegetation, rocks and gates, committed in `a53fc9d`:** Actual hook and
pot cut five vegetation screens while sling and Cinder Wick do not; a real pot
opens brittle rocks while wrong tools are rejected. A ward plate requires two
blocked zero-damage test spores, and a two-brazier gate uses the actual hook and
Cinder Wick while rejecting the sling. These are controlled arenas without
enemies, with player damage active and a controlled projectile fixture. The
agent reports two isolated tests and lint passing. Other negative combinations,
room traversal and full gameplay or human verification remain open.

**Q3 Dirge Choir victory, committed in `14b7836`:** The continuous input route
uses normal damage, two deliberate ordinary enemy deaths and respawns in C6,
farming, the Chime, both keys and Lockpick to open the boss door and defeat
Dirge Choir. It physically collects the fragment and core. The agent reports
five isolated victories, all four shards and lint passing. Global seed
`20261027` does not control Archivist's own randomization. The bot reads boss
heads, timers, HP, projectiles, positions and flags, and C4/C5 internal state;
later shards use fixtures and warps. The C5 and C6 minibosses remain alive;
human play and other global seeds remain unverified. The physical reward walk
now checks the C6 core flag false and maximum health 20 before pickup, then the
flag true and both maximum health and health 22 half-hearts after pickup.
`GameState.MAX_HEALTH_CAP` is 40 half-hearts; the audit found no gameplay bug.
The agent reports all four isolated shards, a first-shard repeat and lint
passing after this check.

**Wick Automaton jet, committed in `bb7c6f8`:** A new native-alpha painted jet
replaces the active geometric placeholder, with a clear outline for the
unchanged 192×64 damage area and unchanged timing. The lead reviewed right and
up orientations in the actual room; the agent also reviewed the tell and vent.
The ordinary cutter and manifest are used, with previous entries unchanged; the
art agent updated provenance and `tools/source_art/wick-automaton-jet-z1-log.md`.
The agent reports isolated `wick_automaton` and `route_cave_9` tests, 22 art
tests and lint passing. Human play remains unverified.

**Q7 wall and raft cases, committed in `81a240e`:** A real pitch pot opens a
cracked wall with flag and collision checks; a distant wall and sling, Cinder
Wick and flare attempts are rejected. A real raft requires a mooring and crosses
deep water with player damage active; the sling cannot be used aboard. These are
controlled arenas without enemies. The agent reports two isolated `tool_matrix`
runs and lint passing; an initial fixture lacked ammo and was corrected. Other
pairs, room transitions and visual or human verification remain open.

**Tidewick phase-two warning, committed in `faf9632`:** Existing painted ripple
art and presentation light replace the barely visible Placeholder warning.
Warning dimensions, timing, hit area, damage and gameplay are unchanged. The
agent reports isolated `boss_tidewick` and `route_cave_3` tests and lint passing;
the lead reviewed both orientations in dark-arena captures. Human play remains
unverified.

**Q7 gate cases, committed in `faf9632`:** Actual player tools exercise three
seams opened by the Glow Jar, a hook-tap wall and a wax seal opened by charged
flare, with wrong tools rejected. The Tether Moth retrieves a real key behind a
grate; the Reel does not. Flags, blockers and revisit behavior are checked in
set-up arenas without enemies. The agent reports two isolated tests and lint
passing. Other gate/tool pairs, visual and human coverage remain open.

**Q3 Archivist victory, committed in `7332bc0`:** The continuous input route
defeats Archivist with normal damage, respawns after ordinary deaths and
physically collects the C5 fragment and core, reaching a maximum of 20
half-hearts. The agent reports six standalone victories, four isolated shards
and lint passing. The global seed is `20261027`, but the boss's own
randomization is uncontrolled. The bot identifies the real boss among copies
through internal state and reads boss phase, health, projectiles and light.
Later shards use fixtures and warps; the C5 miniboss remains alive. A complete
human playthrough and other global seeds remain unverified.

**Q7 selected encounter cases, committed in `7332bc0`:** `test_tool_matrix`
now has at least one selected actual-tool case for each of the 20 encounters,
adding Mirror Warden, Dirge Choir, Archivist, Tidewick and The Unlit. These use
controlled arenas and positions: Mirror Warden's AI and refresh are frozen,
Dirge Choir's song/timing is forced, Archivist's phase is reached by direct
damage, and Tidewick uses a controlled raft position. Player damage is disabled
in four of the five new cases. The agent reports three isolated `tool_matrix`
runs and lint passing. Full phase, tool, survival and human coverage remains
open; this is not complete Q7 acceptance.

**B10 wax wave, committed in `6fc7bfb`:** The phase-two active wave uses a
painted band cut through the ordinary manifest and wrapped by a shader, with
inner and outer outlines. Damage, geometry and timing are unchanged. The lead
reviewed controlled radius-340 and radius-650 captures; the agent also reviewed
radius 50 and reports isolated boss and route tests, 22 art tests and lint
passing. Source and prompt are recorded in `tools/source_art/unlit-wax-wave-z1-log.md`
and `docs/art-provenance.md`. Human action review remains open.

**Q7 extension, committed in `ee9145a`:** Selected actual-tool cases now cover
15 of 20 encounters, adding Lull Mauler, Gloam Knight and Hushed Colossus with
the hook, boots and mitts. The Mauler's chunk is repositioned and its physics
paused; player damage is disabled for Gloam Knight and Colossus, whose movement
and timers are paused and shard fall initiated. The agent reports two isolated
`tool_matrix` runs and lint passing. These controlled fixtures are not complete
fights or human verification; full Q7 coverage remains open.

**Q7 extension, committed in `14a2217`:** Three actual-tool cases add selected
weaknesses for Sump Lurker, Hollow Captain and Lock Warden, bringing coverage to
12 of 20 encounters. The tests use isolated arenas and repositioning; Sump
Lurker uses controlled states with AI paused, Lock Warden disables player damage,
and Hollow Captain keeps damage active. The agent reports two `tool_matrix`
runs and lint passing. Full Q7 and visual verification remain open.

**Q3 C5 Lockpick route, committed in `14a2217`:** After C4, the continuous
input route with normal damage takes one deliberate ordinary death and respawn,
crosses two raft connections and earns keys, the Glow Jar and C5 Lockpick,
with 2/18 half-hearts remaining. It does not defeat the C5 boss. The bot reads
internal state and later shards use fixtures and warps; other seeds and human
play remain unverified. The agent reports all four isolated shards, a repeat
and lint passing.

**B10 chain lash, committed in `14a2217`:** New painted chain art replaces the
active lash presentation, with a separate warning outline and unchanged damage
area and timing. The lead reviewed controlled phase captures; the agent reports
two focused isolated tests and lint passing. The lead's first local test lacked
the imported texture; after `make import`, `boss_the_unlit` and `route_cave_10`
both passed, as did `playthrough_1`. The art is now in the main
`tools/art_manifest.json` and generated `assets/sprites/sprites.json`; the
separate Z1 manifest was removed. The agent reports unchanged previous sprite
entries, a byte-identical PNG, 22 passing art tests, both focused tests and lint.
The source/provenance record is
`tools/source_art/unlit-chain-lash-z1-log.md`. The later wax-wave work is
recorded above; human combat readability remains unverified.

**Q7 extension, committed in `791cbc7`:** `test_tool_matrix` now exercises
selected weaknesses using actual tools for nine of 20 encounters. The new
Kilnkeeper, Choir Warden and Wick Automaton cases use controlled arenas and
repositioning; player damage is disabled for Kilnkeeper, Automaton movement
speed is zero, and Choir Warden uses normal damage. The agent reports two
isolated `tool_matrix` runs and lint passing; a subsequent local `tool_matrix`
run also passed. Full Q7 and visual verification
remain open; the earlier six committed cases are described below.

The lead ran `make check` with the Q3 victory and Q8 probe in the working tree:
155 Godot test files, lint, world-data check and 175 Python tests passed. The
CI timing budget was not enabled; this run does not establish that the 50 ms
budget is met.

**Latest Q3 result, committed in `d5a0c06`:** The continuous input route with
seed `20261027` defeats Hushed Colossus with normal damage, physically collects
the fragment and core and reaches 18/18 half-hearts. The bot reads internal
state including boss phase, timers and hazards; later shards use fixtures and
warps. The agent reports four isolated shards, a first-shard repeat and lint
passing. A full game, human play and other seeds remain unverified.

**Latest Q8 result, committed in `d5a0c06`:** The probe makes 300 actual
input-driven slides in a four-room loop, starting 35 pixels from exits with
damage disabled. A separate 300-warp sequence measures timing; nodes and static
memory were stable and orphans freed. Three sequential runs had machine-dependent
maxima from 46.547 to 52.574 ms. The 50 ms gate is explicitly enabled by an
environment variable for calibrated CI, not proof that CI meets the budget.
Cold-world loading, GPU, RSS and full continuous walking remain unmeasured. The
agent reports 15 checks in each of three runs and lint passing; Q8 remains open.

**C10 action-state review:** Earlier isolated phase captures showed the active
wax wave and chain lash as simple, dark geometric effects. The later chain-lash
and wax-wave changes are recorded above.

The isolated candidate before the final documentation-only adjustment passed
`make check`: 154 Godot suites, lint, world-data verification and 175 Python
tests. `rooms-check` passed 221, `art-test` passed 22 and
`playthrough_route --check` passed. The final documentation adjustment passed
diff-check. No game tests were run for this post-push documentation update.
The committed Q3 extension uses seed `20261027` to burn the hermit
hut thorns with the earned Cinder Wick and collect its core as well. The
continuous input route reaches 16/16 maximum half-hearts and has 16/16 and nine
pots after the first real C4 boss hit, with normal enemies and damage. The bot
reads internal state and uses no warps. The agent reports four isolated shards,
a repeat and lint passing. Two separate unintegrated normal-damage boss bots
reached 4 boss HP but died; those earlier attempts did not establish victory.

The committed Q6 economy test exercises 100 stratified actual standard enemy
deaths and pickup effects in each of two configurations, before and after the
pot and sling. It overrides rolls and resets resources to measure potential
yields without caps; it does not establish random outcomes, playthrough economy
or balance over time. The agent reports three relevant isolated suites and lint
passing. These Q3 and Q6 results are not a complete game or human playthrough.

Committed `test_tool_matrix` covers selected weaknesses using actual
tools for six of 20 encounters: Briar Mother, Corrow's Echo, Thorn Warden,
Abacus Brute, Pale Squire and Coinwyrm. The agent reports isolated tests and
lint passing. The Coinwyrm test disables the player's hurtbox; this is neither
complete Q7 coverage nor visual verification. The later Q8 probe and its
limitations are recorded above.

The committed Q3 fixed-seed continuous input route collects the actual hidden
core in `cave_3_7` using the earned raft, reaches 14/14 maximum half-hearts
after C3, and reaches C4 with 11/14 half-hearts and eight pots after its first
boss hit. Enemies and damage are normal; the bot reads internal state and uses
no warps. The Q3 agent reports four isolated shards, a repeat and lint passing;
the owner also passed `make test T=playthrough_1` in the workspace. This route
has not won C4 or received human or visual verification; later playthrough probes
use controlled interventions. That earlier checkpoint did not win C4; the later
committed victory is recorded above. A complete uninterrupted or human game,
and all placeholder removal and action-state readability remain unverified. Room
captures are controlled stills, with some reviews based on older captures.
Recheck the relevant tests and visual evidence against the final integration
state, keeping saves isolated, before reporting or pushing it.

The following entries retain historical evidence and observations; their older
open-work and git descriptions are not a current inventory.

Updated 2026-10-25 21:43 UTC. Full-gated runtime `16df5d1902a1e8fb6108aa117aa971cccefe44a7` remains the current tested checkpoint. This docs-only correction supersedes the mistaken Cave 5 screenshot attribution in `bdca18681f97d8ff13c554bb5e8b9cbc0a0f14d3` and records the missing `dry_vine_screen` art fallback in `cave_5_2`. No runtime or art files changed. Personal remote: https://github.com/mikaelliljedahl/wickwarden.git; use account `mikaelliljedahl` only.

**Final gate evidence:** isolated logs are in `/tmp/wickwarden-urgent-final-16df5d1-logs/`. `make check` passed 133/133 Godot suites, clean lint and world-data checks; Python generator/compiler tests passed 172. `rooms-check` passed 221/221, `art-test` 22/22, and global ownership passed for 92 WPs and 53 batches (192 rooms, 33 pockets). The first import and all graphics used Dummy audio. The verifier reported no timeout, SIGSEGV, engine/script/parse error, leak, skip or waiver. The detached test worktree was removed. These results apply to `16df5d1902a1e8fb6108aa117aa971cccefe44a7` only.

**Included changes:** P09's permanent low fence lets the real Tether Moth fetch through while blocking the player; cloned room placement and missing-art fallback passed in the actual World. The checkpoint also includes C09 props/fragment/portal/hidden reveal fixes, pocket-exit framing, sling-ammo HUD art, Cinder Wick light, Lock Warden plates, B06/B09 and heavy-door presentation, actor-only Abacus Brute and Pale Squire cues, and M5 Mirror Shade alpha presentation with default production GPU proof. Cue timings, radii and damage are unchanged. The all-ten guide landed in `d83944f`; correction `bb0821b` passed independent review at `/tmp/walkthrough-review.md`. It is a recommended guide, not Q3's recorded playthrough. Archivist fix `6753dcf` and multiple global cohorts clear the earlier SIGSEGV concern.

**New verified work and decision:** decision 47 is implemented by `4fe3f33` and route-tested in C2/C8 by `16df5d1`: a cave Lockpick passively opens all key-locked doors in that cave, including its boss door, without consuming held small keys. Before the pickup, ordinary doors consume one same-cave small key. Other caves, overworld doors, and elemental/barrier puzzles are unchanged. C1/C5 observations came from a read-only save; the save was not changed. HUD purple-fragment fallback uses existing `fragment_c1` art (`fa37150`), with 580 focused test cases.

**Confirmed world defect:** OW10_3 has a real regression from `26dd1`: decorative hut `(720, 816)` cannot be entered from its south/front wall and the functional shop door `(1200, 288)` floats. The earlier route check followed an old portal. Reproduction: `/tmp/ow103-regression-repro.log`. This is not fixed. OW10_7 has a similar item pending review. Next work needs RoomDoor building support/whitelisting, reachable house or trigger placement, and a safe pocket return. Read-only iframe audit `f05c40` is active; no values have been selected. After pause, review ordinary enemy attack invulnerability frames first and preserve the B07 pitfall exception.

**Owner screenshots:** `/tmp/codex-clipboard-06b4f477-9ff0-4b22-8945-8209d5051da8.png` shows the Ninth Door at `ow_10_8`, actor `NinthDoor` / P11, gate `e255`. Its nine sockets work; the purple rectangle is fallback placeholder art for the missing accepted `ninth_door` sprite. It opens on contact with all nine C1–C9 fragments and stays open. `/tmp/codex-clipboard-4d74bfa6-2eba-4996-96e0-fe34e8ebafaa.png` shows the implemented C8 resonance mouth at Counting Gate `ow_9_7`, actor `ResonanceDoor`, gate `e253` to `cave_8_1`. Open it with a tapped Lantern Chime, found in C6 Bell Room `cave_6_5`; controls are E/K or controller X. The radial wave reaches 480 px over 0.5 seconds. Holding for 1.2 seconds opens the warp picker instead. The Heft Mitts visible in that image are not the gate tool. The proposed 0.9-second recovery interval is not implemented, and Gloam Knight art remains open.

The third capture, `/tmp/codex-clipboard-791a715c-b7d5-4006-937a-80f0189bb1ec.png`, is C5 `cave_5_2` Hall of Faces: the highlighted minimap cell is local `(3,1)`. The two brown diamonds below Tamsin are the room's north-passage cut screens, declared in `tools/rooms/cave_5_2.room` at tiles `(9,1)` and `(10,1)` with `look=dry_vine_screen`. They are `Bush` actors from `scenes/world/dry_vine_screen.tscn`, intended to be cut by the hook. The `dry_vine_screen` key is absent from both `tools/art_manifest.json` and `assets/sprites/sprites.json`; `SpriteVisual.attach` falls back to the brown diamond registered in `scripts/world/bush.gd`, and `docs/art-inventory.md` still marks its sheet `todo`. This is a real missing-art/fallback issue, not a MirrorShade actor or load discrepancy. `cave_5_2` has one separate MirrorShade at tile `(11,6)`; it is not one of the screenshot objects. The prior `cave_5_5` Lantern Shelf / MirrorShade attribution is incorrect and withdrawn.

**Remaining work:** B09 body/keyhole, Gloam Knight, Coinwyrm, Ninth Lantern and B01 mouth art remain open or on HOLD. Broader cue polish remains for Lull Mauler, Hushed Colossus, Dirge Choir, Wick Automaton, Corrow's Echo, Hollow Captain, Mirror Warden, Thorn Warden, The Unlit and shared markers. Human balance, Q3 continuous playthrough, Q5 per-room review, Q6 economy/soak, full Q7 weakness matrix, Q8 performance, and release remain open. The guide is not a full recorded playthrough; no all-game completion claim is made.

**Preserved worktree:** the 77 foreign staged paths retain fingerprint `cc7b8baf06d7e79c8d9ed63e5c68b4e971422c0795514e2e8381c9c1771cf4a3`. Two unstaged tracked paths remain outside this task: `docs/art-provenance.md` has 36 FX rows removed; producer-E `tools/art_prompts/PROGRESS_e.md` updates B43–45 and leaves B46–47 not started. Preserve these, plus all staged, untracked art candidate, import and UID work. User game audio remains on; agent tests remain on Dummy audio.

## 1. What the project is

- **Wickwarden** is a top-down action-adventure in **Godot 4.7** (GDScript).
- It is a mechanics-only homage to *Zelda 1* and *A Link to the Past*. Story, names and art are original. Do not copy another game's characters, names or art.
- Player: **Tamsin**. Tools: lamp hook, charge flare, ward, sub-items. Enemies: the **Hush**.
- Art is **hi-fi painterly GPT Image** (generated through Codex). Never an 8-bit or 16-bit look. No pixel art, no outlines on every shape, no text in images.
- **Step 1** (dev world, 7 rooms) and **step 2** (art pass) are done.
- **The world build** (192 rooms including caves, 33 pockets, 10 caves, 10 bosses, 5 miniboss pairs, 8 tools) has all 222 graph scene targets committed. Regional acceptance, QA, runtime art and release work remain in progress by work package (WP).
- **Repo:** `/home/mikael/code/github/wickwarden`. Remote `origin` is `https://github.com/mikaelliljedahl/wickwarden.git`.
- **Account:** the repo is **private** on the **personal** account `mikaelliljedahl`, not the Auxality account. Do not use the Auxality account for this repo.
- **Pushes** require explicit integration assignment under the owner's standing authorization (see section 7). Use the installed `gh` binary as a command-local Git credential helper for the personal account. Do not persist credential configuration or print/store tokens; never use the Auxality account.

- **No AI attribution** in commits, PRs, code or docs. No `Co-authored-by` lines, no "generated with" lines.

## 2. Reading order

Index: [README.md](README.md). Where two documents differ, a binding document wins, and `decisions.md` wins over every plan.

Read in this order:

1. [state.md](state.md): where the project stands (may be stale; check section "Status" of this file and `git log`).
2. [decisions.md](decisions.md) (**binding**): the owner's decisions of 2026-10-24 and 2026-10-25, numbered 1–47.
3. [world-work-packages.md](world-work-packages.md) (**binding**): sections 3 (rules for every WP), 4 (interface contracts), 5 (wave 0), then the table of the wave you work on. Section 12 has the dependency graph, section 13 the rules for agents.
4. [code-contract.md](code-contract.md) (**binding**): section 1 (rules), section 16 (world build contract: 16.1 scope, 16.2 rules for every world WP, 16.3 interfaces, 16.4 flags, 16.8 file layout).
5. [world-plan.md](world-plan.md) (**binding**): the master plan (rooms, gates, caves, tools). Reference, large (117 KB). Read the section your WP names.
6. [world-graph.json](world-graph.json) (**binding** data): the graph. `data/world_data.json` is generated from it. Never edit the JSON by hand.
7. [monsters-bosses-tools.md](monsters-bosses-tools.md) (**binding**): monsters, minibosses, bosses, tools. Section 7 lists API additions.
8. [asset-contract.md](asset-contract.md) (**binding**): art interface (cells, foot line, strips, manifest, `SpriteVisual`).
9. Guides: [art-brief.md](art-brief.md), [art-inventory.md](art-inventory.md), [art-provenance.md](art-provenance.md), [room-kit.md](room-kit.md) (F6, committed in `e433d40`), [intro-script.md](intro-script.md), [story.md](story.md) (context), [audio-provenance.md](audio-provenance.md).
10. History: [dev-world-plan.md](dev-world-plan.md) (step 1), `screens/`.

Commands (from `Makefile`):

| Command | What it does |
|---|---|
| `make run` | start the game |
| `make dev` | start with all items, 10 pots, 5 keys, F1 hitbox overlay |
| `make import` | rebuild class cache (needed after adding or renaming a `class_name`) |
| `make test` | every `tests/test_*.gd`, each in its own headless Godot process. Subset: `make test T="player enemy"` |
| `make lint` | `gdlint scripts tests` (gdtoolkit 4.5.0 via uv) |
| `make format` | `gdformat` (not in `check`) |
| `make check` | import + test + lint + world-check + world-gen-test. **The gate.** |
| `make world-data` | regenerate `data/world_data.json` |
| `make world-check` | fail if the committed data differs from the graph |
| `make world-gen-test` | unit tests of the generator |
| `make art` / `make art-test` | cut `tools/source_art/` sheets into `assets/sprites/` / test the cut tool |
| `make audio` | synthesise sounds (`tools/make_audio.py`) |
| `make rooms`, `make rooms-check` | Wired to `tools/build_rooms.py`; compile only explicitly owned room ids during concurrent work. |
| `make capture-all` | Full 222-target still-capture baseline is committed at `d3cf9a5` in 16 area sheets; human visual review remains pending. |
| `make playthrough` | Full earned-route shards and acceptance remain pending (Q3). |

Other checkers (not in `make check`):
- `python3 tools/check_ownership.py --global`
- `python3 tools/check_world_graph.py --stats --rounds --orders`
- `python3 -m unittest tools/test_check_ownership.py`

## 3. The orchestration workflow

The lead (you) delegates and does as little as possible. Each WP is done by one agent. The lead delegates verification to an integration worker.

**Model rule (owner update, 2026-10-25):** use Codex **Luna xhigh** for mechanical tasks to save budget. The root lead orchestrates; workers execute implementation and checks. Model labels in the binding WP plan remain historical assignments; do not edit normative documents to match this workflow instruction.

**Per-WP flow:**

1. Pick a WP whose `Depends` are merged (committed on `main`) and whose files do not overlap with running WPs.
2. Start one agent with the brief of section 4.
3. The agent works in small steps. After each step it runs `make test T="<own suites>"`.
4. The agent commits only its own paths (`git add <paths>`, never `git add -A`). It reports.
5. The integration worker verifies on the lead’s instruction:
   - `git log --oneline | head` shows the commit, and `git show --stat <hash>` shows only the WP's Owns files.
   - `python3 tools/check_ownership.py <WP>` with the file list on stdin (see below) prints OK.
   - `make check` is green on the new HEAD.
   - The report lists the screenshot check where the WP needs one (`tools/capture.tscn`).
6. If a check fails, the lead sends the agent back, or starts a fix WP with its own Owns list. The lead does not hand-edit agent files without a reason.
7. Update `docs/state.md` when a WP lands (AGENTS rule). Update the status section of this file at every push.

**Ownership check.** The checker reads the changed file list on stdin:

```
(git diff --name-only; git ls-files --others --exclude-standard) | python3 tools/check_ownership.py P01
```

Output: `OK P01: n file(s) inside Owns` or `STRAY <path>` with exit 1. Other modes: `--base REF` (takes changed files from `git diff` against REF; note that it includes other agents' work, so use the stdin form for a single WP), `--global` (whole manifest: no path owned twice in waves 1–5), `--regen` (rebuild room-batch entries from the tables; needed only when the graph changes). The manifest is `tools/wp_ownership.json`.

**Parallel rules.**
- Run in parallel only WPs with disjoint files whose `Depends` are done.
- Waves 1–5: no two WPs own the same file (`--global` checks this).
- Wave 0 is sequential (F7 to F14 touch `world.gd`, `player.gd`, `hud.gd`, `pause_menu.gd`).
- `project.godot` and `Makefile` are shared: serialise the WPs that touch them.

**Git rules for agents and lead.**
- Commit only your own paths: `git add <paths>`. Never `git add -A` or `git add .`.
- Never `git reset`, `git stash`, `git checkout -- <file>`, `git clean` or force-push. Other agents' uncommitted work is in the tree.
- If `git status` shows staged files that are not yours, commit with the paths: `git commit -m "<msg>" -- <your paths>`. Do not unstage others' files.
- Do not push unless explicitly assigned integration push work by the lead (section 7).
- Commit messages: short, imperative, no WP-internal jargon needed. No AI attribution.

**Code rules (from `world-work-packages.md` section 3 and `code-contract.md` 16.2; AGENTS.md is the short form).**
- Read first: AGENTS.md, the contract section, the WP row, the named inputs. Never guess dimensions, paths or interfaces.
- Only write files in your `Owns` list. Anything else is reported, not patched.
- Movement and combat logic in `_physics_process`.
- Damage in half-hearts (int).
- `Layers.*` constants for collision layers, never numbers.
- `load()` with a null check for files another WP delivers. Never `preload()` for those.
- **No `class_name` in new WP files.** Older files keep theirs: `World`, `Placeholder`, `WorldData`, `Hud`, `ItemRegistry`, `PauseMenu`. (`extends "res://path.gd"` is fine.)
- Every entity has a `Visual` child. Game logic never reads from `Visual`.
- Placeholder art only for new entities (`Placeholder.register_kind(...)`). Art comes later.
- Persistence by `GameState` flags (names in code contract 16.4), never by room node state.
- No tutorial text or pop-up instructions in the game world. Button help only in the pause menu. Story text (title, intro, ending) is allowed.
- Tests: `tests/test_*.gd` are auto-discovered by `make test`. Each test file needs its suite to pass alone.
- Verify visually as well as with tests: `tools/capture.tscn` saves a 1920x1080 screenshot.
- A WP that finds a spec problem stops and reports it. It does not change numbers or normative documents.

## 4. How to start agents

Use AgentTeamForge with the Codex backend and the repo working directory. For mechanical tasks, use **Luna xhigh** per the owner. Read the current ATF tool schema for exact model identifiers and fields. Parallel jobs need disjoint owned paths. The root lead coordinates; delegated workers run shell commands and make changes.

Agents need self-contained briefs, including the current shared-tree and push restrictions.

**Brief template (fill the `<...>` parts):**

```
You are building work package <WP id> of Wickwarden (Godot 4.7, GDScript) in <repo path>.
You are one of several agents in this repo at the same time. Other agents have uncommitted files. Not yours: leave them.

READ FIRST (in this order, skip nothing):
1. AGENTS.md (repo root).
2. docs/world-work-packages.md: section 3 (rules), section 4 (interface contracts), the row of <WP id>, and the rows of its Depends: <Depends list>.
3. docs/code-contract.md: section 1 and section 16 (16.2 rules, 16.3 interfaces, 16.4 flags, 16.8 file layout).
4. docs/decisions.md (binding).
5. <WP-specific inputs: e.g. docs/monsters-bosses-tools.md section X, docs/world-plan.md section Y>.

YOUR FILES: only the paths in your Owns list: <Owns from the WP row and tools/wp_ownership.json>. Write nothing else. If you need a change elsewhere, stop and report it.

RULES: no class_name in new files; load() with null check for files from other WPs; Layers.* for collision; damage in half-hearts (int); every entity has a Visual child; movement in _physics_process; placeholder art only; no tutorial text in the world; no AI attribution anywhere.

GIT: never git add -A, never reset, stash, checkout or clean. Commit only your paths: git add <your paths>, then git commit -m "<message>" -- <your paths>. Do not push. Other agents commit at the same time; if git reports a conflict, stop and report.

WORK IN SMALL STEPS: one behaviour at a time. After each step run: make test T="<your suites>". Fix until green.

CHECK BEFORE YOU COMMIT:
- make test T="<your suites>" passes.
- make lint is clean.
- Ownership: (git diff --name-only; git ls-files --others --exclude-standard) | python3 tools/check_ownership.py <WP id>   must print OK.
- Visual check if the WP row names one: tools/capture.tscn, then look at the image.

FINAL COMMIT MESSAGE: "<short imperative summary>" (no WP jargon needed, no AI attribution).

REPORT (your final message, max 15 lines):
- DONE or FAILED.
- Commit hash.
- Every file touched.
- The exact result lines of make test and make lint.
- Unclear points or spec problems, one line each.
```

**Notes on the brief:**
- Give the WP its exact `Owns` line. Do not give a longer file list than the plan.
- Name the suites: `make test T="world"` works on a subset. Test file names map to `tests/test_<name>.gd`.
- If a worker fails twice on the same step, read its report and split the task into smaller assignments with explicit owned paths.

## 5. Art pipeline

**Documents and folders:**

| What | Where |
|---|---|
| Inventory: 397 rows, 1461 images, 86 batches (section 4 is the batch table B01–B86) | `docs/art-inventory.md` |
| Style, shared prompt blocks, character designs | `docs/art-brief.md` |
| Interface (cells, foot line, strips, manifest, edge strip format) | `docs/asset-contract.md` (binding) |
| Prompt files, one per batch (`batch_NN.md`), each prompt with a job id heading | `tools/art_prompts/` |
| Rules for the prompts and the run recipe | `tools/art_prompts/README.md` |
| Output images | `tools/source_art/` (file names `<sheet>[_<facing>]_vN.png`, N = 1 to 3) |
| Per-batch log (file, session, output id, SHA-256, defects, exact prompt) | `tools/source_art/log_bNN.md` (also `log_terrain.md` etc.) |
| Source provenance table | `docs/art-provenance.md` (every kept image gets a row) |
| Progress | `tools/art_prompts/PROGRESS.md` (producers 1–3) and `PROGRESS_a.md` … `PROGRESS_h.md` (producers a–h, ranges below) |
| Invented design details per producer | `tools/art_prompts/DESIGNS_a.md` … `DESIGNS_h.md` |
| Manifest for `make art` | `tools/art_manifest.json` (only accepted sheets go in) |

**Producers (by batch range):** a 4–11, b 12–19, c 20–27, d 28–35, e 36–47, f 48–59, g 60–71, h 72–86. Each producer works only in its range.

**Recipe (Codex image jobs):**
1. Submit one AgentTeamForge job per image: `backend: "codex"`, `model: "cheapest"` (gpt-6-luna; the image tool is the same at every tier). One image per job.
2. Job text: "Make ONE image call with your native image generation tool. Pass the fenced prompt from the batch file EXACTLY as written, with the reference images listed in the entry attached. Copy the generated PNG only from `~/.codex/generated_images/<your session id>/`. Edit no other file. Run no git. Report output path, size, generated file name, session id, visible defects." Set `expected_outputs` to the absolute PNG path, `timeout_s` 900, a unique `idempotency_key` (the job id; resubmit under a new key, e.g. `<job id>-r1`).
3. Limit: at most **6 Codex jobs per producer** at a time, about 48 in total over 8 producers.
4. Wait with background sleeps (a foreground `sleep` is blocked). A job takes about 3–5 minutes.
5. **Verify every PNG:**
   - Get the job's `session_id` (`get_job` / `list_jobs`).
   - Take the PNG **only** from `~/.codex/generated_images/<session_id>/`. Never take the newest file in the folder: parallel jobs write there and sometimes copy another job's image. Several job reports named another session's file.
   - Compare its SHA-256 with the file in `tools/source_art/` and with all other files there. No duplicates allowed.
   - Look at each image (montage of three variants: `magick a.png b.png c.png -resize 1000x -append out.jpg`).
6. `stop_agent` every job after its wave (`list_jobs` shows `agent_live: true` for open ones). Image jobs cost no Codex weekly quota.
7. Write the log, add provenance rows, commit only `tools/source_art/`, `tools/art_prompts/` and `docs/art-provenance.md`.
8. Do not reject an image by hand without the owner. Weak images are logged; the owner culls. Regenerate at most three times for a sheet that breaks the rules in `tools/art_prompts/README.md` section "Run recipe" item 7.

**Prompt rules (from the README):** forbid pixel art, text, grids and frames, poses that touch, and other games' names. Keep the shared block verbatim. Demand one row of poses, flat key background (magenta or green, never in the subject), `Image size: WxH.` as the last line. Walk cycles say in words which leg leads in which pose.

**Known art weak points (do not repeat them without a fix):**
- **Down and up views** often come out as **side profile** (batches 1–3 `pull_down`, `push_down`; batch 14 up units; batch 15 brine crab front and rear). Fix in later prompts: "her chest and face point at the viewer; her body is square to the camera, not turned to the right" (down); "her back is to the viewer, the braid and coat back visible" (up).
- **Walk cycles repeat poses**: poses 1 and 3 and poses 2 and 4 show the same leg arrangement. Fix: give every pose its own description (pose 1 = contact, leg A forward; pose 2 = passing; pose 3 = contact, leg B forward; pose 4 = passing with the other leg lifted).
- **Build agents cull variants**: the build agents pick one of v1–v3 per row when they use the images. The owner culls too. Do not assume a variant is accepted.
- Textures come back 1254x1254, not 1024x1024. Sheets may come back 2172x724 or 1536x1024. Do not resize by hand; log it.
- **Edge strips** (`edge_*`, decision 34: 384x96 cells, alpha, no foot line): the tool returns about 2.5:1 for a requested 4:1. **The cut tool has no edge-strip kind yet** (`tools/cut_sprites.py` has none). Edges are not cut until that task is done.
- Eight-frame strips (`fx_boss_death_light`, `fx_boss_death_wax`, `fx_rekindle_burst`) and `fx_chime_ring` (512 px cell, 480 px radius) have open cell-size questions (`DESIGNS_e.md`).
- Boardwalk tiles stand on legs or posts: prompt needs "flat on the ground, no legs, no stubs, no posts, nothing under the planks".
- Tallow flask drifts to a heart-shaped vessel (`tallow_flask`, batch 22, all failed); `jar_lit` similar.
- Glint poses come out with weak highlights.
- Batch 24: slag chunk orange glow; thorn hedge magenta spill.

**Art not yet in the game:** batches 1–3 and later art are not in `tools/art_manifest.json` until the owner accepts them. `make art` cuts only what the manifest lists.

## 6. Current working tree (other agents)

The tested code snapshot is `16df5d1902a1e8fb6108aa117aa971cccefe44a7`; it adds cave Lockpick key retention and the route-test updates after published runtime `fd5e59725ff1114881c4d5d567aaf56f8c9017e2`. The shared index has 77 foreign staged paths (fingerprint `cc7b8baf06d7e79c8d9ed63e5c68b4e971422c0795514e2e8381c9c1771cf4a3`), plus foreign unstaged and untracked work. The two unstaged tracked paths are `docs/art-provenance.md` (36 FX rows removed) and `tools/art_prompts/PROGRESS_e.md` (producer-E batches 43–45 updated; 46–47 not started). Preserve them and all art, import and UID files. There are 446 untracked paths. The all-ten guide and README link are in `d83944f`, with correction `bb0821b` independently reviewed; later owner-rule update is in `aaf7d65`. This status follow-up commits only `docs/state.md` and `docs/handoff.md` with explicit paths; no broad staging, reset, stash, clean, amend or history rewrite.

## 7. Owner preferences (for the orchestrating lead)

- The owner writes **Swedish**. Replies to him are in **Swedish**, short plain sentences, in the style of **ASD-STE100** (one idea per sentence, simple words, no idioms).
- All **repo documents, code, comments, commit messages and PR texts are in English.**
- The owner wants the lead to **delegate**. The lead does little work itself. Start agents; verify; report.
- Do not ask needless questions. Decide small things yourself, note the choice in the status or in the doc, and go on. Ask only for decisions that the decisions document does not settle, or for pushes and irreversible actions the owner has not asked for.
- **Push policy:** push only when asked, or when the owner says to push continuously. **Currently: push continuously.** After every push, update the "Status (update at every push)" section of this file (date and HEAD) and commit that change too.
- Push command: `GH_TOKEN=$(gh auth token --user mikaelliljedahl) git push origin main`. Only the delegated integration worker pushes when instructed by the lead.
- No AI attribution in commits, PRs or docs.

## 8. Start here (checklist for the new orchestrator)

1. **Orient.** Read this file, then [state.md](state.md). Delegate shell inspection: `git log --oneline | head -20`, `git status` and `git diff --cached --stat`. Note HEAD. Update the status section here if it is out of date.
2. **Read the binding rules.** `decisions.md`, `code-contract.md` section 1 and section 16, `world-work-packages.md` sections 3, 4, 5 and 13. Skim `world-plan.md` and `monsters-bosses-tools.md` only where a WP names them.
3. **Delegate the gate check.** Have the integration worker run `make check` and `python3 tools/check_ownership.py --global`. Both must be green. If not, the first WP is a fix, not new content.
4. **Continue from the checkpoint.** Read current work and remaining batches above. Foundation and wave 1 are delivered; choose remaining wave 2 work with satisfied dependencies and disjoint ownership. Source production is closed; runtime art integration continues separately.
5. **Start ATF workers.** Use Codex Luna xhigh for mechanical work, with the brief of section 4. Parallel only with disjoint files. The root lead only orchestrates; delegate shell checks and document work too.
6. **Delegate verification of each result.** `git show --stat <hash>`, `python3 tools/check_ownership.py <WP>` with the stdin list, `make check` on HEAD. Fix or send back. Update `docs/state.md` when a WP lands.
7. **Art, when the wave needs it.** Pick the next batch from `docs/art-inventory.md` section 4 whose prompts exist (or write them with the README rules). Run the Codex recipe (section 5). Verify SHA-256, log, provenance, commit only art paths. Stop all jobs after the wave.
8. **Push and update.** The integration worker waits for the lead’s instruction while this shared tree is active. Under the continuous push authorization: `make check` green, push with the command of section 7, update the status section of this file with the date and new HEAD, commit that, and report to the owner in Swedish, short.

---

## Appendix: what the WP numbers mean

- **G, D** — graph and decisions (wave 0, done).
- **F0–F14** — foundation (wave 0). F0 contract, F1 runtime data, F2 World runtime, F3 graph test, F4 keys/pickups, F5 wallet/pots/slugs, F6 room kit, F7 player motion API, F8 ledges, F9 shops, F10 item subscreen, F11 minimap, F12 saves, F13 title, F14 intro.
- **P01–P15** — props (wave 1). **T01–T08** — tools (wave 1). **M0–M5** — boss base and regular monsters (wave 1).
- **R1–R6** — regions (wave 2; batches of rooms, Haiku; a Sonnet lead per region). **MB1–MB5** — minibosses (wave 2). **B01–B10** — bosses (wave 2).
- **C01–C10** — caves (wave 3, batches). **E1** — ending (wave 3).
- **Q1–Q9** — integration and QA (wave 4). **Z1–Z3** — fix rounds, tuning, release candidate (wave 5).
- Batch ids for rooms: `ow_<x>_<y>` overworld, `cave_<n>_<k>` caves, `#pocket` suffix for pockets.

## Open art points from producers (added by the previous lead)

- **Edge strips:** the image tool returns about 2.5:1 (for example 1983x793 or 2048x768) where docs/asset-contract.md asks for 4:1 (1536x384). The cut tool needs a rule for this before `edge_*` files can be cut: either crop and scale to the contract size, or order again. `edge_cave_floor_to_wall_v2` and `edge_cave_water_v2` failed (band too low, magenta above).
- **Sizes:** every 1024x1024 request returned 1254x1254. The cut tool must scale with one factor. Sheets of 1536x1024 return as requested.
- **Weak groups that need new prompts** (details in tools/art_prompts/PROGRESS_*.md and tools/source_art/log_bNN.md): brine crab front and rear views (side profile), choirling (too mossy; try `hush_skitterwick.png` as reference), mirror shade (coloured Tamsin instead of silhouette), many walk cycles that repeat poses 1=3 and 2=4, `wax_seal` (drips read as blood), `dry_vine_screen` and `bush_cluster` (cut would count wrong blobs), `pocket_plain_door` (too ornate), `pocket_lighthouse_door` (square base).
- **Producers:** Claude-side producers a-h ran on the previous lead's account. b (12-19) and d (28-35) finished. Check PROGRESS_a, _c, _e, _f, _g, _h for the rest. Those historical producer states are superseded by the closed source coordinator recorded above; do not restart generation from this historical note.
- Build agents choose the best variant (v1-v3) when they use an image; the owner does not cull.
