# Current status

**Q3 hidden-core route, 2026-10-27 (working tree):** The fixed-seed continuous
input route uses the earned raft to collect the actual hidden core in
`cave_3_7`, reaches 14/14 maximum half-hearts after C3, and reaches C4 with
11/14 half-hearts and eight pots after the first boss hit. Enemies and damage
are normal; the bot reads internal state and uses no warps. The Q3 agent
reports four isolated shards, a repeat and lint passing; the owner also ran
`make test T=playthrough_1` successfully in the workspace. C4 victory, human
and visual verification, other seeds and a complete game remain open.

**Push handoff snapshot, 2026-10-27:** The working tree contains ongoing code,
art, test and documentation work, including staged changes and untracked files.
Progress checkpoint `aa6fc158087e4a5be21be22acf948f1f69c9cf8b` was pushed and
verified on `origin/main`, excluding the 77 previously staged paths. The
subsequent documentation checkpoint is `e3af885`. The isolated candidate before
the final documentation-only adjustment passed
`make check`: 154 Godot suites, lint, world-data check and 175 Python tests;
`rooms-check` passed 221, `art-test` passed 22 and `playthrough_route --check`
passed. The final documentation adjustment passed diff-check. No game tests
were run for this post-push documentation edit.
The C4 boss has not been defeated in the earned route, a complete game has not
been verified, and the removal or readability of every placeholder has not been
verified. Still captures and controlled probes do not establish those claims.

**Thornwood and Tallowfen visual reviews, 2026-10-27:** Q5 inspected stills for
all 20 Thornwood and 28 Tallowfen graph nodes, plus contact sheets and newer
shop stills. Reports are `docs/screens/step3/review-thornwood.txt` and
`docs/screens/step3/review-tallowfen.txt`. Regional terrain and landmarks need
presentation review; stills do not verify traversal, collision, active states
or human play. The contact sheets and some shop stills use older baselines.

**Gravelight and Hushmarch visual reviews, 2026-10-27 (working tree):** Q5
inspected 34 existing full-size room/pocket captures and both contact sheets;
reports are `docs/screens/step3/review-gravelight.txt` and
`docs/screens/step3/review-hushmarch.txt`. Region-specific ground, ravine edges,
gate readability and unreviewed action states need further attention. Some
shop captures predate their recent improvements.

**Fen Leech bubble review, 2026-10-27:** Two generated bubble treatments were
prototyped in isolated dark, outdoor and controlled raft views. The horizontal
variant reads better as water but can visually merge with the leech's existing
ripple or overlap the player; direction and real-time readability remain
uncertain. Neither candidate was integrated. The active fallback and separate
movement ripple still need a suitable presentation and action-state tests.

**C4 full-health attempts, 2026-10-27:** An isolated input bot using the
earned-health route, normal damage and real shards/pots reached phase three
with the boss at 12 HP but died before victory. Normal retries and respawns
also failed to produce a win. One separate experiment logged a freed-instance
error after leaving the arena; its backtrace points to the temporary
`fight_c4_probe` test code reading the freed boss, not to game code. Neither
the failed bot nor that probe was integrated. C4 victory remains open.

**Cinderflats visual review, 2026-10-27 (working tree):** Q5 inspected the
existing contact sheet and all 20 full-size graph room/pocket captures, with
findings in `docs/screens/step3/review-cinderflats.txt`. These are initial
states and do not establish action-state readability or human play.

**Verification after C4 lighting and earned-health route, 2026-10-27
(working tree):** `make check` passed 154 Godot suites, lint, the generated
world-data check and 175 Python tests with the owner-requested C4 light,
current wisp art and the continuous route's earned-health farming. C4 boss
victory, other seeds and a complete human or uninterrupted game remain open.

**C4 earned health farming, 2026-10-27 (working tree):** The fixed-seed input
route now revisits C4 enemies and collects their actual drops, reaching Hushed
Colossus at 12/12 half-hearts with nine pots after its first real pot hit.
The bot reads enemy and pickup state to do this; no direct health changes or
warps are used. Four playthrough shards and repeat first-shard runs passed in
an isolated copy with current B04 and T04; a Godot import was required before
the clean runs. C4 boss victory, other seeds and human play remain open. No
full `make check` was run after this latest test-only extension.

**Owner-requested C4 boss-room light, 2026-10-27 (working tree):** The
Colossus arena has a room-fixed presentation light covering the floor while
the fight is active. It does not join `glow_light` or change combat. The real
room and a controlled phase-three quake warning were inspected before/after;
floor, boss and marked versus safe tiles are now visible. Isolated and working
project B04, C4 route and mitts tests passed. A separate isolated probe verified
walking from a marked quake tile into the centre of an adjacent safe tile;
it did not exercise simultaneous slam or shard attacks. The owner must restart
an existing game process to load the change. Human play remains open.

**C4 legitimate retry and farm probe, 2026-10-27:** An isolated test farmed
actual respawning enemies and drops, reaching 12/12 half-hearts and ten pots,
and confirmed normal death respawns with persisted progress. Its best bot still
died in phase two with the boss at 18 HP. This demonstrates a legitimate way to
restore resources, not a boss victory; the experimental bot was not integrated.

**Owner C4 quake report and isolated dodge, 2026-10-27:** The owner reports
that the final phase's yellow area attack is hard to avoid in darkness and
explicitly requests lighting the boss room. In a real-room isolated quake probe
with normal player damage, walking from a marked tile to the centre of an
adjacent unmarked tile avoided damage; standing still on the marked tile took
three half-hearts. The 96-pixel visible tiles and collision rectangles matched
in the probe, but warnings were almost invisible outside the lamp. Concurrent
slams and falling shards were not included. Room-wide presentation lighting and
warning readability are being addressed at the owner's request.

**C5, C8 and C10 visual reviews, 2026-10-27 (working tree):** Q5 inspected
36 existing full-size room captures and the C10 pocket, recording reports in
`docs/screens/step3/review-c5.txt`, `review-c8.txt` and `review-c10.txt`.
These initial-state captures predate some newer boss art. Distant contrast,
pit edges and active interactions/combat remain to be reviewed; the reports
do not establish blocked routes or a complete visual playthrough.

**Cinder Wisp burst art, 2026-10-27 (working tree):** The active fire burst
now plays the recorded painted `fx_wisp_burst_v1` frames, while retaining a
visible outline for the full 150-pixel damage area. The hitbox's 0.2-second
lifetime, damage and ward behavior are unchanged; the animation finishes
separately. Controlled dark-cave and outdoor captures, and the cutter proof,
were inspected. Isolated Cinder Wisp, cutter and focused lint tests passed;
source provenance is in `tools/source_art/log_b44.md`. Human combat review and
the complete game remain open.

**Verification after C4 sweep fix, 2026-10-27 (working tree):** `make check`
passed 154 Godot suites, lint, world-data verification and 175 Python tests with
the B04 sweep direction/visibility change and current input route. C4 victory,
all active presentation states and a full human playthrough remain open.

**C4 sweep warning visibility, 2026-10-27 (working tree):** The existing
warning band now has a presentation-only rectangular light and outline in both
orientations; the light disappears when the attack activates. Its hitbox,
timing and damage are unchanged. Dark arena captures were inspected; isolated
B04, T04 and C4 route tests and focused lint passed. An earned-route bot's
stationary retreat to the north opening still died to boss contact before a
sweep; it is not a boss-victory proof. Human play remains open.

**C9 visual review, 2026-10-27 (working tree):** Q5 inspected ten existing
room captures and both pockets, with a room-by-room report in
`docs/screens/step3/review-c9.txt`. The boss image in that capture baseline is
stale relative to the newer painted body, deadbolt and volley. Active states
and human readability remain unreviewed; no blocked route was established.

**C4 sweep direction and safe opening, 2026-10-27 (working tree):** The
phase-two band now starts at the arena edge on the Colossus's side, instead of
always north or west, preserving its dimensions, warning, active time and
damage. Isolated B04, T04 and C4 route tests passed, including all four sweep
directions. With the earned boss door correctly open, input probes avoided both
orientations in the north opening without invulnerability; slams can still
reach it and no boss victory was demonstrated. The warning was very dark in
captures and a presentation fix is underway. This refines the earlier
closed-door edge observation below; human play remains open.

**C4 earned resupply, 2026-10-27 (working tree):** The continuous input route
now opens the actual wax-seal cache with a charged flare, collects its pot
bundle and avoids enemies in Quench Hall. It reaches the C4 boss after its
first pot hit with six of 12 half-hearts and nine pots. Enemies and damage stay
active; the new avoidance reads enemy positions and alive state. All four
shards passed in an isolated copy; the first passed three fresh-copy repeats
and again after integration, without script errors. The fight is not yet won;
other seeds, human play and the sweep investigation remain open.

**C4 sweep investigation, 2026-10-27:** With normal damage, input and a
12-half-heart fixture, an isolated boss bot died in all tested strategies; its
best attempt reached 18 boss HP. A phase-two sweep hit near the starting edge
in controlled input probes. The 96-pixel band currently crosses the entire
walkable length in 0.5 seconds and is unwardable, so its relationship to the
specification's "from the Colossus's side" and the available safe space is under
review. This is not proof that a human cannot win; no fix has been applied.

**Verification after C4 health route and thorn art, 2026-10-27 (working
tree):** `make check` passed 154 Godot suites, lint, generated world-data check
and 175 Python tests with the T04 race fix, current walking route and B02
full-width thorn effect. C4 victory and the complete uninterrupted game remain
open; the walking bot currently uses one seed and reads combat internals.

After importing the thorn-band texture in the working project, the B02 boss,
C2 route and first playthrough shard passed there as well.

**Briar Mother full-width thorn sweep, 2026-10-27 (working tree):** The
active geometric sweep fallback is replaced by a single painted full-width
thorn strip, ordered behind the boss and player, with a separate outline for
the existing damage rectangle. The warning, hitbox and timings are unchanged.
Controlled dark-arena warning and active captures were inspected. Isolated B02
and C2-route tests, all 22 cutter tests and focused lint passed, including
fallback and cleanup at reset, phase change and room exit. The source and
prompt are recorded in `tools/source_art/briar-band-20261027-log.md`; the earlier
repeated-strip candidate below was rejected. Human action-state review remains.

**C4 approach health, 2026-10-27 (working tree):** Adjusted walking routes
leave five of 12 half-hearts after the first real pot hit on Hushed Colossus,
instead of two. The isolated continuous-route probe using real shards reached
34 HP on the boss before dying; a pot-only attempt reached 30 HP before dying.
Neither proves victory. The accepted test remains input-driven with normal
damage and passed four isolated shards and a post-integration first-shard run.
The T04 shard race fix was also checked against the accepted route. More health,
the C4 victory and full completion remain open.

**Mitts shard-lift race fix, 2026-10-27 (working tree):** Heft Mitts now
rejects an object already queued for deletion and safely cancels a lift if its
object disappears, restoring movement state. Regression tests use an actual
Colossus shard and reproduced script errors before the fix. Isolated mitts,
Colossus, heavy-stone and liftable tests, lint and diff checks passed; a T04
carry capture was inspected. This supersedes the race finding below. The C4
continuous boss victory remains open.

**C4 shard-lift race, 2026-10-27:** An isolated normal-damage boss probe
reproduced a script error when a crumbling shard was grabbed in the frame it
queued deletion; the mitts then dereferenced the freed object at lift completion.
A T04 fix and regression are in progress. The same investigation's best bot
reduced the boss to 30 HP before dying with a 12-half-heart fixture; it did not
prove a victory or that the fight is unwinnable.

**Briar sweep candidate review, 2026-10-27:** A generated transparent thorn
strip was tried in an isolated dark-arena prototype. Five repeats did not make
a seamless band and overlapped the boss; moving it behind the floor hid it.
The candidate was not integrated. A continuous or suitable tileable strip and
layering solution are still needed; the readable existing warning remains.

**C4 boss attempt, 2026-10-27:** Isolated input-driven strategies using the
earned mitts and an actual fallen shard reduced Hushed Colossus from 46 to 40 HP
but died in phase one; the accepted approach reaches the arena with only two
of 12 half-hearts. The probes read boss/hazard and shard state and used normal
damage, with no state or position manipulation. This does not prove the boss
unwinnable. Failed experiments were not integrated; the earlier walking test
remained green. Improving route health or legitimately recovering before the
fight, then verifying victory and rewards, remains open.

**Verification through the C4 boss approach, 2026-10-27 (working tree):**
`make check` passed 154 Godot suites, lint, the generated world-data check and
175 Python tests after the latest continuous C4 approach and B02 burst art.
The boss victory and full continuous playthrough remain unverified.

**Briar seed burst and continuous C4 approach, 2026-10-27 (working tree):**
The existing painted seed-burst animation now plays over the C2 seed's active
burst, with a visible outline for the unchanged 120-pixel damage radius. The
animation outlives the damage only as presentation. A controlled dark-arena
capture was inspected, and B02/C2 tests and focused lint passed. The fixed-seed
walking route now passes the active C4 miniboss, obtains the mitts and Lockpick,
opens the boss door and damages Hushed Colossus using an earned pot, surviving
with two of 12 half-hearts. It has not yet defeated that boss or the C3/C4
minibosses. Four shards passed in isolation; the first passed 731 checks after
integration. Other seeds and human play remain open.

**e042 mooring investigation, 2026-10-27:** An isolated real-room test boarded
and crossed e042 from `ow_5_2` at 62 pixels and rejected an attempt beyond the
72-pixel range. Item use during an active hook swing was rejected until the
button was released and pressed again after the swing. This could explain the
walking bot's earlier failure, but its original input/state was not logged, so
the cause is unconfirmed. No game files were changed; the focused probe passed.

**Continuous C4 entry, 2026-10-27 (working tree):** The fixed-seed route
leaves C3 after collecting its rewards, crosses the overworld with the earned
raft and sling and enters `cave_4_1` alive with 11 of 12 half-hearts. Normal
damage and enemies remain active; no death, warp or state manipulation occurred.
All four shards passed in an isolated copy, the first also after integration;
the bot's earlier C2/C3 fights read internal combat state. An alternative e042
boarding attempt from `ow_5_2` failed near the mooring and needs investigation;
the accepted route uses another crossing. C4 interior, other seeds and human
play remain open; earlier `make check` predates this test extension.

**Verification after C3 victory, 2026-10-27 (working tree):** `make check`
passed all 154 Godot suites, lint, world-data verification and 175 Python tests
after the continuous C3 victory, pause/title changes and latest recorded boss
effects. The continuous route uses one fixed seed and combat-state-aware bots;
later test shards retain shortcuts and do not establish full human completion.

**Continuous C3 victory, 2026-10-27 (working tree):** The fixed-seed input
route now boards and steers the earned raft, defeats Tidewick with normal damage
enabled, returns to the mooring and physically collects the C3 fragment and
wick core. Eight isolated repetitions passed 585 checks each; all four shards
passed in the isolated copy and the first passed after integration without
script errors. The player survived with seven of ten half-hearts before the core.
The bot reads tail position/exposure and raft state; its earlier C2 fight also
reads boss and projectile state. Sump Lurker was passed without defeat, and
other seeds, human/visual play and the continuous route after C3 remain open.

**Sump Lurker water jet, 2026-10-27 (working tree):** The C3 miniboss's
projectile now uses the recorded `proj_water_jet_v2` painted frames, oriented
along its motion with a presentation-only light. Damage, collision, timing and
speed are unchanged. A controlled dark C3 encounter was inspected; isolated
miniboss, C3 route and soak tests and focused lint passed. Source provenance is
in `tools/source_art/log_b50.md`; human combat readability remains open.

**Return to title with launch arguments, 2026-10-27 (working tree):** A
one-use scene-tree marker now prevents the title from immediately autostarting
the world after Back to title, while preserving the initial `--dev-mode` and
`--start-room` autostarts. Isolated subprocess tests exercised both arguments,
actual scene transitions, title visibility and marker cleanup; title/item-menu
tests and lint passed. This supersedes the launch-argument limitation below.

**Pause menu and continuous C3 boss approach, 2026-10-27 (working tree):**
The pause menu now offers Resume and Back to title with keyboard, controller and
mouse selection, saving before the title transition and staying paused on save
failure. A controlled menu capture and isolated scene transition were inspected;
the item-menu tests and lint passed. With `--dev-mode` or `--start-room`, the
title currently autostarts the world, so the return does not remain at title.
The fixed-seed walking route now reaches `cave_3_9` using the earned key, raft
and Lockpick, with normal damage and seven of ten half-hearts. It passes but does
not defeat Sump Lurker. The C3 boss and rewards have not yet been verified in
this continuous route. Four shortcut-containing shards passed in isolation,
and the first passed 575 checks after integration; other seeds and human play
remain open. Earlier `make check` checkpoints predate these changes.

**Archivist ink art, 2026-10-27 (working tree):** C5's ink projectile and
short spatter now use painted frames with local presentation lights; their
timing, damage and hitboxes remain unchanged. Controlled dark-arena projectile
and spatter captures and cutter proofs were inspected. Isolated Archivist, C5
route and soak tests, all 22 cutter tests and focused lint passed. The sources
and known provenance are recorded in `docs/art-provenance.md`; human combat
readability remains open.

**Continuous C3 entry, 2026-10-27 (working tree):** After C2 victory the
fixed-seed input route physically collects its rewards, earns an overworld key
with the moth, obtains the pitch pot and opens C3's entrance with an actual pot.
It enters `cave_3_1` alive with five of ten half-hearts and five pots, without
death or state manipulation. All four playthrough shards passed in an isolated
copy; the first passed 530 checks after integration, and three repetitions passed
with the current B02 presentation. The bot reads combat internals during C2;
other seeds, a human/visual run and the remainder of C3 onward remain open.

**Kilnkeeper slag art, 2026-10-27 (working tree):** The C1 boss's geometric
slag projectiles now use recorded painted flight and impact frames, rotating
with their direction and carrying a local presentation light. Mechanics and
collision remain unchanged. The cutter proof and a controlled dark arena
capture were inspected; isolated B01, C1 route/soak, C10 route/soak and all
22 cutter tests passed, along with focused lint. A human fight remains open.

**C7 visual review, 2026-10-27 (working tree):** Q5 reviewed all eleven
existing C7 room captures in `docs/screens/step3/review-c7.txt` and compared
the newer Gloam Knight visuals. Pit-edge contrast, distant objects and active
combat states need further review; these stills do not establish blocked routes.

**C6 visual review, 2026-10-27 (working tree):** Q5 inspected all eleven
existing fresh-state C6 room captures, both pockets and the contact sheet;
findings are in `docs/screens/step3/review-c6.txt`. Distant heads, keys, gates
and the chime are dim in those images. Action states, closer approaches and
transitions remain unreviewed; the stills do not establish a blocked route.

**Briar Mother eye readability and placeholder census, 2026-10-27
(working tree):** Living lowered eyes now carry small local presentation lights
which follow visibility and disappear with the eye, without changing mechanics
or the gameplay light group. Controlled lowered, raised and dead-eye captures
were inspected. Isolated B02, C2 route and input-fixture tests and focused lint
passed. A fresh code/manifest census identifies remaining active fallbacks in
Kilnkeeper slag, Archivist spatter/projectile, Sump Lurker jets, Briar Mother's
bands/bursts and several shared enemy effects. Existing source art needs
individual selection and action-state review; the census is not a complete
runtime or procedural-draw audit. Full human readability remains open.

**Verification after C2 victory, 2026-10-27 (working tree):** `make check`
passed all 154 Godot suites, lint, world-data verification and 175 Python tests
after the B02 fix, C3 presentation changes and continuous C2 victory test.
This does not resolve the fixed-seed, internal-bot-information and later
shortcut limitations described below.

**Continuous C2 victory, 2026-10-27 (working tree):** The fixed-seed input
route now defeats Briar Mother and physically collects its fragment and wick
core, without death, teleporting or disabling damage. Three isolated repeated
runs passed 440 checks without script errors; all four playthrough shards also
passed in an isolated copy with the final B02 fix and lighting. The bot reads
boss phase, eye health/visibility and projectile position, direction and speed;
it is not a human or visual playthrough. Other seeds and the continuous route
after C2 remain open. The full `make check` checkpoint below predates this
extension and the B02/C3 changes.

**Briar Mother sweep readability, 2026-10-27 (working tree):** Each of the
three phase-two bands now carries a matching rectangular presentation light
during its existing warning and attack. No timing, damage, hitbox or gameplay
light group changed. Controlled dark-arena warning and active captures were
inspected; isolated B02, C2 route and input-fixture tests passed, alongside
focused lint. Human play and the continuous earned fight remain to be verified.

**Tidewick undertow presentation, 2026-10-27 (working tree):** The active C3
water band now uses repeating painted ripple frames and a translucent outline
covering the entire existing damage rectangle. Timing, hitbox, movement and
damage are unchanged. Controlled dark-arena captures in both orientations and
the cutter proof were inspected; isolated boss, C3 route and soak, rendered boss
and cutter tests passed with focused lint. The earlier warning still uses its
existing visual, and human action-state review remains open.

**Briar Mother pending-eye fix, 2026-10-27 (working tree):** A pending spore
now checks whether its eye still exists before assigning the typed reference;
stale entries are discarded and other pending attacks continue. A regression
destroys an eye during its actual warning and checks that a pending seed still
lands; it failed with the former script error and passes with the fix. Isolated
boss and C2 route tests passed, as did focused lint. The input-driven fixture
fight won without the former script error, but uses a supplied loadout and reads
eye state. The continuous earned route's attempted boss fight died in phase one;
full survival and human readability remain open. This supersedes the error
finding immediately below.

**Briar Mother combat investigation, 2026-10-27:** An isolated input-driven
fight with damage enabled reached the dying animation, but is not a clean
victory proof: when an eye died during a pending spore warning, a freed-instance
assignment in `briar_mother.gd` emitted repeated script errors and could prevent
pending attacks from being processed. A B02 fix and regression test are in
progress. The dark arena also makes distant eyes and sweep warnings difficult
to read; actual human-play review remains open. The fixture supplied equipment
and the bot read eye positions, so this was not an earned human playthrough.

**Continuous C2 boss approach, 2026-10-27 (working tree):** The fixed-seed
walking route now collects the second C2 key and sling ammunition, opens the
eye switch with the earned sling, picks up the C2 Lockpick and opens the boss
door into `cave_2_9`. Enemies and player damage remain active and movement uses
input. The player arrives alive with four of eight half-hearts and 17 slugs.
All four playthrough shards passed in an isolated project copy; the first was
repeated and passed again after integration. The C2 boss fight, other seeds and
an earned-route visual playthrough are still open. The full `make check`
checkpoint below preceded this latest test-only extension.

**Verification checkpoint, 2026-10-27 (working tree):** After the C1 art,
Coinwyrm readability and Tidewick cue changes, `make check` passed all 154
Godot suites, lint, world-data verification and 175 Python tests. The separate
art cutter suite passed 22 tests, and `make rooms-check` verified 221 room
sources. The continuous walking test currently reaches
the C2 sling using one fixed seed; later route shards still use shortcuts, so
these passing checks do not prove a complete uninterrupted or human playthrough.

**Continuous C2 miniboss and sling, 2026-10-27 (working tree):** The walking
route now defeats Thorn Warden with the earned wick, collects both actual health
drops and reaches the Tallow Sling with its 12 slugs, using input and normal
damage throughout. Three isolated fixed-seed runs passed 401 checks; health rose
from one to five of eight half-hearts. Earlier failed attempts were removed.
The rest of C2, other seeds and a rendered earned-route playthrough remain open.

**Tidewick bolt warning, 2026-10-27 (working tree):** The C3 boss's bolt tell
now uses existing painted ember-spark art at the head with a presentation light;
the projectile timing and mechanics are unchanged. The cutter proof and dark
arena capture were inspected. Isolated boss, C3 route and soak tests, a
rendered boss capture and all 22 cutter tests passed; focused lint also passed.
The phase-two water-band fallback and human action-state review remain open.

**Owner C8 feedback, 2026-10-27:** The owner reports defeating Coinwyrm after
learning to use Reel Line on the three plates; the blocker was identifying the
appropriate tool, not an inability to damage the exposed head. The pause menu
currently lists controls but does not explain item uses. The newer plate cues
make targets visible but do not themselves identify Reel Line; discoverability
remains open within the rule against tutorial text in the game world.

**Continuous C2 lock, 2026-10-27 (working tree):** The fixed-seed walking
route now spends the earned C2 key on the first lock and reaches
`cave_2_4` alive using input, with normal enemies and damage. Three isolated
runs passed 389 checks; arrival health was one half-heart. The miniboss,
other seeds and the rest of the continuous game are not yet verified.

**Tidewick warning and continuous C2 key, 2026-10-27 (working tree):**
The C3 boss's tail-ripple warning now uses its existing painted submerged tail
animation, preserving the old timing, location and visual light. The actual
dark C3 capture was inspected; boss, C3 route and C3 soak tests passed, as did
focused lint and B03 ownership. The bolt warning and phase-two water band still
use placeholders. Separately, the fixed-seed input route now collects the C2
key and returns to the hall alive with one half-heart. Three isolated runs
passed 382 checks. Reaching the C2 lock, other seeds, and a continuous complete
playthrough remain unverified. Q5's fresh-state C4 findings are recorded in
`docs/screens/step3/review-c4.txt`; action states still require review.

**C1 kiln mouth, 2026-10-27 (working tree):** A new painted native-alpha
vent replaces the arena's geometric `kiln_mouth` fallback, without changing
collision or combat. The cutter proof and a normal-light capture of the actual
boss room with the player near the vent were inspected. The Kilnkeeper,
sprite-visual and static-prop tests passed, as did all 22 cutter tests. Prompt,
source and provenance are recorded in `tools/source_art/b01-kiln-mouth-20261027-log.md`.
This supersedes the C1 mouth finding in the fresh-state visual review; other
placeholder and action-state reviews remain open.

**Coinwyrm plate readability, C2 entry and C3 visual review, 2026-10-27
(working tree):** Reelable plates now have visible cyan outlines and local
presentation lights, with a distinct crown outline in phase two; each cue
disappears when its plate is removed. No hitbox, combat timing or damage was
changed. Four controlled dark-arena images, including crown-only and bare
states, were inspected. Isolated boss, C8 route, C8 soak and third playthrough
tests passed, as did focused lint and B08 ownership. Human combat readability
and an earned C8 fight remain open. The fixed-seed walking route now enters C2
alive with one half-heart using input and normal damage; three isolated runs
passed 365 checks. Later probes still reset or shortcut. The fresh-state C3
captures were reviewed in `docs/screens/step3/review-c3.txt`; combat effects,
transitions and the bombable entrance in an earned state require further review.

**Walking toward C2 and C2 visual review, 2026-10-27 (working tree):**
The fixed-seed continuous opening now leaves C1 after victory, burns the
overworld thorn with the earned wick and reaches `ow_5_1` at the C2 entrance
using input, with enemies and damage enabled. Three isolated headless runs
passed 356 checks; the player reached the room alive with one half-heart.
Entering C2 was not demonstrated: a further experimental approach died and
was removed. The later C1/C2 probes still reset or use shortcuts. Q5 reviewed
the existing fresh-state C2 room captures in `docs/screens/step3/review-c2.txt`;
no unambiguous geometric fallback was visible in those initial views. Dark
approaches, transitions and action states remain to be checked visually.

**C1 visual review and Coinwyrm combat probe, 2026-10-27 (working tree):**
Q5 reviewed the existing fresh-state C1 captures and recorded individual room
observations in `docs/screens/step3/review-c1.txt`. The kiln mouth remains a
visible geometric fallback; dark approaches and gate transitions need review
with the player nearby. The captures do not cover earned or active fight states.
Separately, an isolated Coinwyrm probe won four identical fights from the C8
arena spawn using input with damage enabled and 16 half-hearts. It used a
fixture loadout and read internal target positions and plate status, so it is
not an earned-route or human readability test. A less precise bot died in
phase two. Plate readability and normal human play remain open.

**Walking C1 boss victory, 2026-10-27 (working tree):** The continuous
fixed-seed opening now defeats Kilnkeeper, collects the fragment and wick core,
and walks back out of the arena using player input. Enemies and player damage
remain enabled; the boss fight does not reposition the player or inspect the
boss's combat state. Three isolated headless runs passed 324 checks each; the
player survived the fight and collected the health upgrade. Focused lint passed.
The following C1 and C2 probes still reset or use shortcuts. Other seeds, a
rendered earned-route fight and a complete continuous playthrough remain open.

**Walking to the C1 boss, 2026-10-27 (working tree):** The fixed-seed opening
now continues from the first lock back through the actual brazier gate, walks
past the active Hollow Captain to collect Cinder Wick, walks into the Ash
Closet for the C1 Lockpick, returns and opens the boss door into `cave_1_8`.
All movement and actions use input; regular enemies and damage remain active.
Three headless runs passed 311 checks. The later controlled C1 test still
resets state and positions the player, so this does not prove an uninterrupted
boss victory or a full game, nor robust play across random seeds. Fresh-state
captures of the miniboss, Lockpick and boss rooms were separately inspected;
they do not depict the earned route. Focused lint and Q3 ownership passed.

**Walking to the C1 lock, 2026-10-27 (working tree):** The opening playthrough
segment now continues from the C1 entrance by normal movement through the
turning hall to the grate, uses the real moth with input to retrieve the scoped
C1 key, walks back through the hall, spends that key on the east lock and
enters `cave_1_6`. Ordinary enemies and damage remain enabled; the walking bot
uses periodic hook attacks and fixes the RNG seed to 20261027 for reproducible
movement and enemy behaviour. Four repeated headless runs passed, arriving with
2 of 6 half-hearts. The C1 grate, lock hall and destination were inspected in
separate fresh-state captures; a fully rendered route attempt timed out, so
those are not screenshots of the bot's earned state. After this segment the
older C1 test resets state and the remaining shards use documented shortcuts;
neither the whole game nor random-seed robustness has been proved. The focused
playthrough test passed 277 checks, along with Q3 ownership and focused lint.

**Coinwyrm bite and tail recovery, 2026-10-27 (working tree):** The bite's
warning and 0.12-second strike now illuminate and draw their actual 180-degree,
150-pixel damage sector instead of a small geometric dot. The tail plays its
recorded burrow strip after the sweep, then frees the visual; boss resets clear
it. The lights are presentation only and do not join `glow_light`. Actual dark
C8 bite tell and strike captures were inspected; a rendered test passed 148
checks, including tail sweep-to-burrow and cleanup. Boss, C8 route, C8 soak,
third playthrough shard, focused lint and B08 ownership passed. The head and
plates remain stills, and this is not a continuous human playthrough. This
supersedes the unplayed tail-burrow finding below.

**Coinwyrm tail sweep, 2026-10-27 (working tree):** The second heap now shows
the recorded `coinwyrm_tail_v1` tell and sweep art during the existing phase-two
attack. The entire 96-pixel damage row is visibly lit during its tell and
0.12-second strike, using presentation lights outside `glow_light`; the timing,
collision and damage remain unchanged. Cutter proof and real dark C8 captures
of both tell and active strike were inspected. The rendered boss test passed
142 checks, and boss, C8 route, C8 soak and third playthrough shard passed;
focused lint and B08 ownership also passed. The tail's separate burrow strip is
cut but not yet played, and the head and plates remain still images. Source
provenance is in `docs/art-provenance.md` and `tools/source_art/log_b68.md`.

**Coinwyrm head and plates, 2026-10-27 (working tree):** A painted bare
serpent head replaces the geometric boss body. Existing recorded coin-plate
art is attached to each of the original reelable hitboxes, including a
separate crown in phase two; removed plates reveal the bare head. A local
presentation light makes the visible head readable in the dark arena without
joining `glow_light`. Cutter proofs, the real C8 scene and plated, bare and
crowned fight captures were inspected. The rendered boss test passed 136
checks, including real reel removals, phase-two crown and damage gates; boss,
C8 route, C8 soak and third playthrough shard passed, as did focused lint and
B08 ownership. A duplicate heap-animation signal connection found during
capture was also fixed. Head and plates are stills; the tail and other attack
presentation remain unfinished. The generated head prompt and source are in
`tools/source_art/coinwyrm-bare-head-20261027-log.md` and art provenance.

**Coinwyrm heaps, 2026-10-27 (working tree):** The arena's four geometric
heap markers now use the recorded `coin_heap_v1` idle, quiver and burst art.
The heap chosen by the existing 0.9-second cue quivers and lights up without
joining `glow_light`, then bursts and returns to idle; reset clears the cue.
The cutter proof and actual C8 quiver and rear captures were inspected. The
placeholder boss body obscures much of the burst and still needs its own art;
the rest of the arena remains very dark. Boss, C8 route, C8 soak and third
playthrough shard passed, including cue timing and cleanup, followed by focused
lint and B08 ownership. The source is recorded in `docs/art-provenance.md` and
`tools/source_art/log_b68.md`. This supersedes the heap-placeholder finding below.

**Coinwyrm coin volley, 2026-10-27 (working tree):** Hostile coins now use
the existing recorded `proj_coin_v2` two-frame flight and three-frame impact
instead of the collectible brass-bit sprite. Each carries a small presentation
light, outside the `glow_light` gameplay group, so the fan is visible beyond
the lamp in the dark C8 arena. The cutter proof and real C8 capture were
inspected. Boss, C8 route, C8 soak and third playthrough shard passed; these
include the fan, ring, actual ward block, impact cleanup and unchanged speeds
and damage. Focused lint and B08 ownership passed. The boss body and coin heaps
still use geometric placeholders, and the room remains very dark. Source
provenance is in `docs/art-provenance.md` and `tools/source_art/log_b49.md`.

**Lock Warden key volley, 2026-10-27 (working tree):** Its eight- and
twelve-projectile volleys now use the existing recorded `proj_key_volley_v1`
flight strip instead of brass pickup art, turn with their flight directions,
and play the three-frame impact on a wall, player or ward hit. The cutter proof
and a real C9 volley capture were inspected. The rendered boss test passed 468
checks, including flight direction, collision-effect cleanup, the existing
damage and ward rules, and the actual C9 volley. Boss, C9 route, C9 soak and
final playthrough shard passed, as did focused lint and B09 ownership. The
source is recorded in `docs/art-provenance.md` and `tools/source_art/log_b49.md`.
This does not complete the remaining art or prove a continuous playthrough.

**Shop counters and surfaces, 2026-10-27 (working tree):** S3–S6 now have
painted solid counters beside their shopkeepers. The burrow, mason's shop and
lighthouse chamber use stone room surfaces while retaining their overworld
scope; the room kit exposes this as `stone_interior`. The burrow no longer
contains outdoor trees. All five changed shops were visually inspected, and a
player walks from each entrance to buy one of its wares in the shop test.
`make check` passed 154 Godot suites, lint, world-data verification and 175
Python tests; `make rooms-check` passed all 221 sources. F8, F6 and F9
ownership checks passed for their respective shared files. The rooms still
need individual dressing (including roots for the burrow and an awning for
the cart), and contact sheets predate these changes. This supersedes the
missing-counter observation below.

**Lock Warden deadbolt, 2026-10-27 (working tree):** The two geometric sweep
segments now use painted brass art aligned with the existing hitboxes; the
192-pixel opening, timing, damage and boots interaction are unchanged. The
cutter proof, gallery and actual C9 fight captures were inspected. The rendered
boss test passed 439 checks, including the live C9 sweep; the focused boss,
C9 route, C9 soak and final playthrough shard passed, along with focused lint
and B09 ownership. The body remains a still and further placeholder and
full-playthrough work remains. Source and prompt are recorded in
`tools/source_art/lock-deadbolt-20261027-log.md` and art provenance. This
supersedes the geometric-deadbolt finding below.

**Lock Warden body, 2026-10-27 (working tree):** The geometric boss body is
replaced by a painted still, with its four independently controlled plate
targets overlaid. The keyhole glows when its existing damage window opens;
collision and timing are unchanged. The cutter proof and actual C9 room with
closed plates and open core were inspected. The rendered fight test passed 431
checks, including real sling and pot hits on all four plates; the boss, C9
route, C9 soak and final playthrough shard also passed. Focused lint and B09
ownership passed. The body is not animated, the deadbolt remains geometric,
and this is not a continuous human playthrough. Source and prompt are recorded
in `tools/source_art/lock-warden-body-20261027-log.md` and art provenance.

**S2–S6 shopkeepers, 2026-10-27 (working tree):** All six shops now show their
named, non-interactive shopkeepers using the four-frame idle rows of existing
recorded sources. S2 also has the painted solid counter; S3–S6 still need
counter placement and fuller dressing. The five changed shop captures were
inspected; two keepers were moved clear of overlapping walls. The layout and
economy checks, shop and regional route suites passed. `make check` passed 154
Godot suites, lint, the world-data check and 174 Python tests; `make rooms-check`
passed all 221 room sources. Contact sheets predate these shop changes.

**Z1 shopkeeper ticket:** Fresh captures show S2–S6 have no visible merchant.
This ticket owns `tools/build_rooms.py`, `tools/test_build_rooms.py`,
`docs/room-kit.md`, `tests/test_shop.gd`, the five S2–S6 `__shop.room` sources
and their generated scenes, and the art manifest and generated sprites for
`npc_peddler`, `npc_ashwife`, `npc_mason`, `npc_pilgrim` and `npc_keeper`.
It preserves stock, routes and the staged foreign work. The earlier S1 ticket
continues to own its own files.

**Tilly's shop, 2026-10-27 (working tree):** S1 now has Tilly's animated idle
and a painted, solid counter using existing recorded sources. Tilly is a
non-interactive visual beside the counter; the shop remains an outdoor grass
setting, so further dressing and human review remain open. The room compiler
supports the new decoration and counter, and a real player walks from the S1
entry to buy an ember in the test. The actual shop capture was inspected;
the earlier Brackwater contact sheet predates this change. `make check` passed
154 Godot suites, lint, world-data verification and 174 Python tests;
`make rooms-check` passed 221 rooms and `make art-test` passed 22 tests.

**Current room captures and Brackwater review, 2026-10-27 (working tree):**
`make capture-all` rendered all 222 standalone scenes at 1920x1080 with fresh
state and updated the 16 labelled contact sheets. Index coverage and all image
hashes were checked. The binding Q4 row still says 218; the graph has 222.
Full-size Brackwater captures and its contact sheet were inspected, with one
line per scene or in-place pocket in `docs/screens/step3/review-brackwater.txt`.
S1's shop lacks its named shopkeeper and intended counter/setting; action states
and the remaining 15 areas still require review. Captures are stills, not a
full visual or human playthrough approval.

**Q6 economy budget, 2026-10-27 (working tree):** A budget test compares each
of the 16 graph areas and the total to world-plan 6.1, and first runs Q2's
scene inventory checks for graph pickup IDs, cache contents, shop stock and
placed enemy types. It passed 1,796 checks and prints the per-area counts and
totals: 192 rooms, 10 tools, 17 cores, 22 small keys, 10 Lockpicks, 9 fragments,
2 pot bags, 16 caches, 6 shops, 1 pot bundle, 9 slug bundles and 436 regular
enemies. Bosses and minibosses are checked separately by Q2. Focused lint and
Q6 ownership passed. A pedestal capture was inspected. The budget does not
verify play balance, drops over time or a continuous playthrough; the sampled
soak limitations and remaining visual work still apply.

**Unlit eye art, 2026-10-27 (working tree):** The five orbiting eye parts now
use a native-alpha painted still in place of the geometric fallback. A small
teal light makes each eye visible in the dark and brightens during its existing
half-second gaze tell; it is presentation only and does not join `glow_light`.
The cutter proof and actual C10 fight capture were inspected. The prescribed
orbit still crosses the north wall and under the HUD, so reachability and visual
balance remain open for human review; eye animations are also unfinished. The
source and prompt are in `tools/source_art/unlit-eye-20261027-log.md` and
`docs/art-provenance.md`. Boss, C10 route, C10 soak and earned-route tests
passed, as did focused lint and B10 ownership. The rendered C10 route passed
258 checks. This supersedes the eye-placeholder finding immediately below.

**Q6 world soak, 2026-10-27 (working tree):** The sampled five-second soak now
covers all 222 standalone room and pocket scenes in 16 area files. Living enemy
centres are checked every 0.5 seconds against room bounds and the dev-world
test's known solid rectangles. C10's five Unlit eyes follow their contracted
330-pixel orbit, which crosses the north wall; they are checked against that
orbit rather than room containment. The eyes still use placeholder art, and
their visibility and reachability around the wall need play review. A real C10
fight capture was inspected. All 16 soak suites passed; `make check` passed
153 Godot suites, lint, the generated world-data check and 172 Python tests.
Q6 ownership passed. Full-body and continuous collision, unmodelled obstacle
types, the economy budget, human balance and the full playthrough remain open.

**Q6 regional soak, 2026-10-27 (working tree):** Brackwater and Thornwood now
have five-second runtime soaks for all 29 standalone rooms and pockets in
those regions; the two Brackwater in-place pockets are covered by their hosts.
The tests check their scene lists against generated graph data and sample living
enemy centres every 0.5 seconds against room bounds and the dev-world test's
known solid rectangles. They passed with 410 and 701 checks respectively;
focused lint and Q6 ownership passed. A normal-light Thornwood room capture
after five seconds was inspected. This does not prove full-body collision,
continuous collision between samples, every new prop type, the other 14 areas,
the economy budget or human balance; those remain open.

**Walking opening, 2026-10-27 (working tree):** The first playthrough shard
now also walks from the new-game spawn through `ow_0_1`, collects the actual
Tether Moth and enters C1 through `ow_1_1`, using movement input throughout.
Ordinary enemies and player damage stay enabled for this opening segment; no
teleports or manual positioning are used. An in-room view of the pedestal
approach was inspected. The segment is followed by the older C1 route, which
resets the state and still uses positioned actions, enemy removal and warps;
this is not a continuous full-game or human playthrough. The first and final
playthrough shards passed, as did focused lint and Q3 ownership.

An additional generated kiln-mouth candidate was rejected because its exterior
halo remains visible. No new mouth image or mapping was added; the existing
fallback remains open.

**Gloam Knight warnings, 2026-10-27 (working tree):** Its attack markers now
carry a short-lived local light so the knight and marker can be seen in the
required dark arena. The light is not in `glow_light` and cannot act as the
glow jar; its lifetime follows the existing marker without changing attack
timing or geometry. Before/after captures of the real distant lance tell were
inspected. The boss and C7 route tests, full earned-route bot, focused lint
and B07 ownership check passed. Human combat readability review and the
remaining placeholders and animations stay open.

**Gloam Knight body, 2026-10-27 (working tree):** Three existing source sheets
now provide clean first-pose stills for down, side and up. The boss presents
the player's direction while ready and keeps that visual direction during an
attack; the stored attack aim and combat rules are unchanged. The cutter proofs
were inspected, including the deliberately omitted merged action bands. An
actual `cave_7_11` capture was inspected: the distant knight is very dark, so
combat readability needs human review. Phase-two, attack and dive animations
remain open; this is not a full art acceptance. Sources and original provenance
are in `log_b67.md` and `docs/art-provenance.md`. The boss, cave route and third
earned-route tests passed; focused lint and B07 ownership passed. Other
placeholders and a full human playthrough remain open.

**Unlit shell art, 2026-10-27 (working tree):** Phase two now selects a
native-alpha painted still instead of its geometric fallback, with the required
512-pixel cell and foot line. The image cutter proof and a capture from the
actual C10 fight were inspected. The fight's collision and mechanics are
unchanged; directional movement, burning, wave and break animations are still
open. The source and prompt are in `tools/source_art/unlit-shell-20261027-log.md`
and `docs/art-provenance.md`. The final-boss and earned-route tests passed,
as did the actual C10 route (258 checks), the focused lint and B10 ownership
check. Other placeholders and a full human playthrough remain open.

**Unlit heart art, 2026-10-27 (working tree):** Phase three uses a new
native-alpha painted still in place of the geometric heart fallback. Shielded
and exposed states retain distinct tinting and the existing lantern movement;
the sprite does not change the fight's collision or rules. The cutter proof and
actual C10 fight captures were inspected. The arena is very dark and the heart
is partly obscured during the exposed capture, so readability still needs human
play review. The source and prompt are recorded in
`tools/source_art/unlit-heart-20261027-log.md` and `docs/art-provenance.md`.
The actual C10 route passed 258 checks, `make art-test` passed 22 tests, and
`make check` passed 137 Godot suites, lint, world-data verification and 172
Python tests. The shell, other remaining placeholders and full human playthrough
are still open.

**Ninth Lantern art, 2026-10-27 (working tree):** The separate final-fight
lantern now uses a single native-alpha painted sprite instead of its geometric
fallback. Its size and centre preserve the existing reel target and collision.
The proof and actual streamed C10 phase-three captures were inspected. The
lantern's image is a still; shell, heart and other final-fight presentation work
remain open. The kept source and prompt are recorded in
`tools/source_art/ninth-lantern-20261027-log.md` and `docs/art-provenance.md`.
`test_boss_the_unlit`, the earned-route final test, `make art-test` (22 tests),
and `make check` (137 Godot suites, lint, world-data check and 172 Python tests)
passed. This supersedes the Ninth Lantern item in the census below.

**Fragment art and placed-placeholder census, 2026-10-27 (working tree):** The
existing `fragment_c6_v1`, `fragment_c7_v1` and `fragment_c8_v1` sources are now
cut and mapped. Only each clean first pose is used; the brighter poses have visible
key-colour halos. The cutter proofs and post-boss room captures were inspected.
`test_pickups` now checks painted art for all nine fragment scopes, and the full
earned-route test passes. `make check` passed 137 Godot suites, lint, world-data
verification and 172 Python tests; `make art-test` passed 22 tests.

A fresh headless census loaded all 222 standalone targets with a reset game state
and sampled their active room trees after four physics frames. It found 41
`Placeholder` nodes: 31 visible generic transient effects; five visible actor
visuals (`kiln_mouth`, `gloam_knight`, `coinwyrm`, `lock_warden`,
`ninth_lantern`); and five hidden nodes (`hook_tap_wall`, `sealed_seam`,
`wax_plate`, `tidewick_ripple`, `dirge_choir`). The three former fragment
fallbacks are gone. This is an initial-state census, not coverage of all transient
actions, later boss states, procedural drawing or a full visual review.

**Q3 earned-route bot, 2026-10-27 (working tree):** All four
`test_playthrough_*.gd` shards pass through `make playthrough`. The fourth runs
the earlier shards in the same process, opens the Ninth Door with the nine earned
fragments, fights the actual final boss, saves and reloads the earned state, and
tests both real endings and Continue from an isolated pre-choice save. The focused
run passed 1,233 checks and reported 930.97 seconds of simulated time including
both ending branches. Each shard performs an isolated save/reload. The bot uses
positioned actions and room warps, removes ordinary enemies, and suppresses
player damage except in explicit combat probes. It is not proof of an uninterrupted
human playthrough, ordinary-enemy balance or complete overworld walking reachability.
`make check` passed 137 Godot suites, lint, world-data verification and 172 Python
tests. Missing art and the remaining human, visual, soak, matrix and release gates
remain open.

**Q3 third shard, 2026-10-27 (working tree):** `test_playthrough_3.gd` runs
the earned C1–C5 route and continues through C6–C9 with actual gate interactions,
minibosses, bosses and pickups. It saves and reloads the earned state after C6.
The C9 vault supplies the real pot bundle used against Lock Warden. The focused
run passed 1,038 checks and reported 792.57 seconds simulated time from C1 to C9.
It uses positioned actions and room warps, removes ordinary enemies and suppresses
player damage except in explicit combat probes; it is not a human playthrough.
`make check` passed 136 Godot suites, lint, world-data verification and 172 Python
tests. C10 and both endings remain to be linked to this earned state.

**Q3 second shard, 2026-10-27 (working tree):** `test_playthrough_2.gd` runs the
earned C1–C2 route, then earns the C3–C5 tools and fragments using real gate
interactions and miniboss/boss fights. It saves and reloads the earned state
after C3 and crosses the actual `e027` and `e045` lake moorings with the earned
raft before entering C5. This is a positioned bot route: room warps are used,
ordinary enemies are removed and player damage is suppressed except in the
reused combat probes. It does not establish a human playthrough or a complete
walking route across the overworld. The focused run passed 590 checks and reported
394.33 seconds simulated time from C1 through C5. `make check` passed 135 Godot
suites, lint, world-data verification and 172 Python tests. C6–C10 and both
endings remain to be linked into the earned route.

**Q3 first shard, 2026-10-27 (working tree):** `test_playthrough_1.gd` carries
the actually earned C1 fragment and tools through an isolated disk save/reload
into the real C2 gates, miniboss and boss. The route uses positioned actions and
room warps, and reuses helpers that remove ordinary enemies; it is not a human
playthrough. The shard passed 241 checks and reports 158.13 seconds of simulated
time in its focused run. `make check` passed all 134 Godot suites, lint,
world-data verification and 172 Python tests. The other Q3 shards, full earned
route and both endings in that route remained open at that checkpoint. `tools/playthrough_route.py`
generates the graph-derived capability objectives and `--check` verifies the data.

**Ninth Door, 2026-10-27 (working tree):** The door uses a new painted 576×480
sprite with nine dark sockets. Individual fragment lights now use radial light
sprites, replacing the geometric socket placeholders. A five-fragment runtime
capture was inspected for alignment. The P11 tests verify individual socket
state, the eight-fragment refusal, opening with nine and persistence; the C10
route test also passed. The source, generation prompt and provenance are recorded
in `tools/source_art/ninth-door-20261027-log.md` and `docs/art-provenance.md`.
The image cutter proof was inspected. `make check` passed 133 Godot suites,
lint, world-data verification and 172 Python tests; `make art-test` passed 22.
This supersedes the Ninth Door placeholder finding below; other presentation and
the complete earned-route playthrough remain open.

**Pilgrim Road shop, 2026-10-27 (working tree):** S5 now uses the painted stall
as its entrance instead of an overlaid doorway and hut. The actual player walks
in from the south, purchases stock, returns without bouncing, walks away and
re-enters in `test_route_hushmarch`. The room capture was inspected. `make check`
passed 133 Godot suites, lint, world-data verification and 172 Python tests;
`make rooms-check` passed all 221 room sources and ownership checks passed.

**Cooling Pools shop, 2026-10-27 (working tree):** The S3 entrance is now the
painted Ashwife cart in the clearing, and the unrelated inaccessible hut has been
removed. This supersedes the OW10_3 regression finding below. The actual player
walks into S3 from the south, returns through the pocket door, walks away and
re-enters in `test_route_cinderflats`; the return marker does not bounce. The
cart uses the open pose of the existing `pocket_cart_v1` source. Its proof and a
real `ow_10_3` capture were inspected. `make check` passed 133 Godot suites,
lint, world-data verification and 172 Python tests; `make rooms-check` passed
221 rooms and global ownership passed. The Pilgrim Road review is recorded above.

**Dry vine screen presentation, 2026-10-27 (working tree):** `dry_vine_screen_v3.png`
is now mapped through the art cutter as a 192×192 idle prop, using only its intact pose.
The cut poses are excluded because the existing Bush removes the screen on a successful cut.
The original source and its provenance are unchanged. The cutter proof and a real
`cave_5_2` capture were inspected; both screens now render as vines instead of brown diamonds.
`make art-test` passed 22 tests, and `make test T="bush sprite_visual route_cave_5"`
passed the two matching suites. `make check` passed all 133 Godot suites, lint,
the world-data check, and 172 Python tests. All pre-existing sprite manifest records remain unchanged.
The complete playthrough and other missing artwork remain open.

Updated 2026-10-25 at 21:43 UTC. The verified runtime remains `16df5d1902a1e8fb6108aa117aa971cccefe44a7`. This docs-only correction supersedes the Cave 5 screenshot attribution in `bdca18681f97d8ff13c554bb5e8b9cbc0a0f14d3`; it identifies the visible brown diamonds as missing `dry_vine_screen` art fallbacks in `cave_5_2`, not MirrorShade actors in `cave_5_5`. No runtime or art files changed.

**Final checkpoint gate:** logs are in `/tmp/wickwarden-urgent-final-16df5d1-logs/`. `make check` passed 133/133 Godot suites, clean lint and world-data checks; Python generator/compiler tests passed 172. `rooms-check` passed 221/221, `art-test` passed 22/22, and global ownership passed for 92 work packages and 53 batches (192 rooms, 33 pockets). The isolated run used Dummy audio from the first import. The verifier reported no timeouts, SIGSEGV, engine/script/parse errors, leaks, skips, or waivers. The detached gate worktree was removed after testing. These results apply to `16df5d1902a1e8fb6108aa117aa971cccefe44a7`.

**Included fixes and reviews:** P09's low-fence grate is a permanent physical barrier: the real Tether Moth can fetch through it while the player is blocked; clone placement and missing-art fallback were verified in the actual World. `a7e0f1f` supplies the low-fence helper and `fd5e597` completes P09 runtime/tests. C09 thorn wall, eye cell, ninth fragment, portal, and hidden-seam reveal work are fixed (`909800b`, `aca1fb3`, `ce838b3`, `4c11205`). The sling-ammo HUD icon is in `23f4a1e`; Cinder Wick light is in `a2c6ee8`; Lock Warden plates are in `2c3d481`/`6ec36ff`; B06/B09 and heavy-door presentation are included. Abacus Brute and Pale Squire actor-only cues landed in `47db582`/`b3fcc83`: two focused suites and lint passed, and eight dark before/after captures are available; timings, radii and damage did not change.

M5 Mirror Shade alpha presentation is closed in `d28ec6d`/`c5f109b`: 71 shader proof images, all 12 frames checked against the flat-alpha requirement, and default production GPU rendering reviewed. The all-ten player guide and README link are in `d83944f`, with route correction `bb0821b` independently reviewed PASS at `/tmp/walkthrough-review.md`; later guide update `aaf7d65` records the cave Lockpick rule. The guide is a source-checked route, not a recorded full playthrough. The earlier Archivist SIGSEGV was fixed in `6753dcf`; multiple later global cohorts passed.

**Recent runtime and owner decisions:** decision 47 is implemented by `4fe3f33` and verified in cave route tests at `16df5d1`: each cave Lockpick passively opens every key-locked door in that cave, including the boss door, without consuming held small keys. Before pickup, ordinary locked doors still consume one same-cave small key. Other caves, overworld locks, and elemental/barrier puzzles are unchanged. Existing key retention is verified in C2 and C8. HUD fallback for the purple fragment now uses existing `fragment_c1` art (`fa37150`); its focused test coverage is 580.

**Confirmed regression:** OW10_3 has a real reachability/presentation regression from room build `26dd1`: the decorative hut at `(720, 816)` cannot be reached from its south/front wall, and the functional shop door at `(1200, 288)` floats. The earlier route check followed an old portal and did not validate this route. Reproduction is recorded at `/tmp/ow103-regression-repro.log`; the user's live save was not changed. Next work needs RoomDoor building support/whitelisting, a reachable house or trigger, and a safe route from the pocket. OW10_7 has a similar item flagged for review. Neither issue is fixed. The user's new iframe-breathing-space audit `f05c40` is read-only and active; no value is selected yet. After pause, review ordinary enemy attack invulnerability frames first, while preserving the B07 pitfall exception.

**Owner screenshot findings:** Screenshot 1, `/tmp/codex-clipboard-06b4f477-9ff0-4b22-8945-8209d5051da8.png`, is the Ninth Door in `ow_10_8` (The Ninth Door), actor `NinthDoor` / P11, graph gate `e255` to `cave_10_1`. The nine sockets are functional and reflect held C1–C9 fragments; this capture shows 1/9. The door opens on player contact once all nine are held, spends none, and persists `door_ninth`. The purple rectangular door body is the current `ninth_door` fallback placeholder because accepted sprite art for that kind is absent. This is a presentation backlog item, not a missing gate mechanic.

Screenshot 2, `/tmp/codex-clipboard-4d74bfa6-2eba-4996-96e0-fe34e8ebafaa.png`, is Counting Gate `ow_9_7`: actor `ResonanceDoor` (`resonance_stone.gd`), graph gate `e253` to C8 entrance `cave_8_1`. Equip the Lantern Chime, found in C6 Bell Room `cave_6_5`, and tap Use Item (keyboard E/K, controller X). The radial chime wave reaches 480 px over 0.5 seconds. A held press opens the warp picker at 1.2 seconds instead of ringing; release to ring. The resulting `resonated_e253` flag removes the blocker so the `RoomDoor` can be crossed. The Heft Mitts shown equipped in the capture do not open this door. The circular gold visual is the resonance-door art; the gate mechanic is implemented.

Screenshot 3, `/tmp/codex-clipboard-791a715c-b7d5-4006-937a-80f0189bb1ec.png`, maps to C5 Mirrored Archive, `cave_5_2` Hall of Faces (selected minimap cell local `(3,1)`). The two brown diamonds below Tamsin are the north-passage cut screens at room tiles `(9,1)` and `(10,1)`: `tools/rooms/cave_5_2.room` declares both as `opener cut_screen ... look=dry_vine_screen`, and the generated room instantiates `scenes/world/dry_vine_screen.tscn` (`Bush`, variant `dry_vine_screen`). This is the intended hook-cut barrier presentation. `dry_vine_screen` is absent from `tools/art_manifest.json` and `assets/sprites/sprites.json`; `SpriteVisual.attach` therefore uses the fallback registered by `Bush._register_looks`, which is a brown diamond. The art inventory still lists the `dry_vine_screen` sheet as `todo`. Track this as missing cut-screen art/mapping, not a MirrorShade actor or runtime-load discrepancy. `cave_5_2` does contain one separate MirrorShade farther into the room; it is not either visible diamond. The former `cave_5_5` / MirrorShade screenshot diagnosis is withdrawn.

The proposed 0.9-second enemy recovery interval remains unimplemented and is not an approved balance change. Gloam Knight art remains open; this screenshot review does not close that art work.

**Open work and preserved WIP:** B09 body/keyhole art remains on HOLD. Gloam Knight, Coinwyrm, Ninth Lantern and B01 mouth art remain open or on HOLD. Cue polish remains for Lull Mauler, Hushed Colossus, Dirge Choir, Wick Automaton, Corrow's Echo, Hollow Captain, Mirror Warden, Thorn Warden, The Unlit and shared markers. Human balance, Q3 continuous playthrough, Q5 per-room visual review, Q6 economy/soak, full Q7 weakness matrix, Q8 performance, and release remain open. The C1/C5 observation came from a read-only save; no user save was changed. Do not describe the former key behavior as unresolved: the current Lockpick rule is implemented and route-tested.

The worktree has two unstaged tracked changes outside this task: `docs/art-provenance.md` removes 36 FX source rows, and producer-E `tools/art_prompts/PROGRESS_e.md` records batches 43–45 complete while 46–47 remain unstarted. Preserve both. The 77 foreign staged paths retain fingerprint `cc7b8baf06d7e79c8d9ed63e5c68b4e971422c0795514e2e8381c9c1771cf4a3`; preserve the staged index, untracked art candidates, import metadata and UID files.

## World build and functional acceptance

- All **222/222 graph scene targets** are committed: 88 overworld rooms, 104 cave rooms, and 30 separate pocket scenes. The graph has 33 pockets total, three in-place. There are 221 `.room` sources because `cave_1` is hand-authored. No scene output is missing at the observed HEAD.
- Q2's strict inventory and layout checks passed at `c2a5924`; F3's full-graph run passed 1,136 checks at `92786ea`. The earlier C07 moth-pit and C09 reel/refill graph-validator flags were false positives, not content defects. A separate real B07 streamed pit-return issue was fixed in `5f69076`; its fresh-entry, death-reset, and re-entry checks passed. The binding Q2/Q4 inventory row still says 218 rather than the graph's 222; report the mismatch without changing normative documents.
- C06–C10 functional lead test commits are present: C06 `081518e` (166 headless and 193 render checks), C07 `32e0ab8` (route PASS), C08 `d5e65ad` (150 render checks), C09 `5cd96d9` (40 area, 227 route, 243 render checks), and C10 `1af39cc` (53 area, 243 route, 258 render checks). C09's older OPEN down-throw label has an independent recheck under job `816d3c`, currently marked needs_reconciliation; no result or confirmed reachability defect is available. P06 fix `4e9d1a4` passes 138 checks across all four throw directions.
- Decision 47's cave Lockpick rule is implemented in `4fe3f33`; C2/C8 route tests at `16df5d1` verify held small keys are retained. The earlier read-only save observation (C1 lock and already-open C5 door) did not change the save and is not an open mechanics issue.
- E1 ending flow and branch tests are present (`5728847`, `1af39cc`); ending paintings landed in `b66ddd3` and duplicate stands under painted lanterns were removed in `b905d4d`. This is not a completed continuous earned-route playthrough.

## QA and capture status

- Q1's scene-graph solver is committed and passes. Q2 inventory/layout acceptance is complete at the committed 222-target inventory. Q7 reports **582 passing checks** after Snapper fix `b4449ed`; coverage of all 20 encounters' weakness cases is still pending.
- The committed still-capture baseline `d3cf9a5` renders the 222 room and pocket targets from source snapshot `c2a5924` into 16 labelled area sheets at 480×270 thumbnails, with Dummy audio and isolated user data. This is a capture baseline, not Q5 human visual approval or a human playthrough.
- The previously reproduced Archivist native SIGSEGV was fixed in `6753dcf`; multiple later global cohorts passed, including the full gate at `16df5d1`. It is not a current open bug.
- Remaining QA: Q3 full continuous earned-route playthrough; Q5 human visual review; Q6 soak/economy; complete Q7's 20-encounter weakness coverage; Q8 performance/memory; and Q9/release checks.

## Art and presentation

Source image production is closed at final FX `d2fe1a5` and provenance checkpoint `2fa8c69`. Runtime mapper `02fded4` covers 26 keys. Native-alpha cutter support `62a82aa` passes, with 227 previously cut PNGs byte-identical. The ten found-tool menu icons and equipped HUD icons are integrated; equipped-label fit landed in `9664e50`. The `fd5e597` gate includes reviewed C09 props and seam, pocket exit framing, the sling-ammo HUD icon, Lock Warden plates, B06/B09 presentation, Mirror Shade alpha silhouettes and low-fence grate behavior.

Runtime presentation is not complete. Body and transient-tool fallbacks/placeholders, terrain and pickup/shop visuals, remaining mapping/render cleanup, and human visual review remain. B01 wax plate and kiln pillar are integrated; mouth candidates A–C were rejected for exterior halo/alpha spill. B09's four plate targets are delivered, but its body and keyhole art remain on HOLD. The C1/overworld consumer accepts B art at 104×51 with a clear waist projection against the 64 px target; raw source hash prefix `d463` is accepted without a binding exception. Gloam Knight, Coinwyrm and Ninth Lantern art remain open or on HOLD. Remaining actor cue backlog: Lull Mauler, Hushed Colossus, Dirge Choir, Wick Automaton, Corrow's Echo, Hollow Captain, Mirror Warden, Thorn Warden, The Unlit, and shared markers. No blanket all-art-done claim.

## Current checkpoint boundary and next gate

The shared index contains **77 foreign staged paths** (binary diff fingerprint `cc7b8baf06d7e79c8d9ed63e5c68b4e971422c0795514e2e8381c9c1771cf4a3`); this docs update preserves them and all other foreign work. The user's game audio remains enabled; headless gates use Dummy audio.

The latest published runtime is `16df5d1902a1e8fb6108aa117aa971cccefe44a7` in the docs-bearing checkpoint `f8d44c2ce36daaa35480fe999a9f217c771be84f`. This screenshot and walkthrough update is docs-only and adds no runtime or art blobs. Preserve the 77 staged paths and all dirty/untracked work. The guide and README link landed in `d83944f`, with route correction `bb0821b` independently reviewed PASS and owner-rule update `aaf7d65`; the guide does not count as Q3. Human balance and visual feel, continuous human playthrough, Q5 per-room review, Q6 soak/economy, complete Q7 weakness coverage, Q8 performance/memory, and release/export acceptance remain open.

## All-ten tool-menu and HUD icon checkpoint

All ten found tools have dedicated painted menu icons, and equipped HUD icons are integrated. The scoped F10 evidence and captures are historical checks of that feature, not a global gate for the current HEAD. Unfound tools retain their silhouettes and question marks.

## Step 1: the dev world (what runs today)

- **World**: 3x2 overworld (`ow_0_0` .. `ow_2_1`) plus the dark `cave_1`, room slides (0.45 s), cave fades (0.3 s),
  enemies respawn on entry, items/doors/walls/pickups stay changed. HUD band, pause menu with the button help.
- **Player**: Tamsin with lamp hook, charge flare, ward, two sub-items. Numbers as in the plan.
- **Enemies**: spitcap (+spore), skitterwick, duskmoth, tallow blob (+drop), hollow, on the shared `EnemyBase`.
- **Items and props**: tether moth, pitch pot (6 pots when the item is found), cracked wall, brazier + gate,
  locked door with small key, bushes, rocks, trees, pond, reeds, ruin walls, huts, sign post.
- **Rooms** (spec: plan section 2; screenshots in `docs/screens/step1/`):

  | Room | Content |
  |---|---|
  | `ow_0_0` | start, huts, sign post, 2 spitcaps |
  | `ow_1_0` | field with rocks and bushes, 3 skitterwicks |
  | `ow_2_0` | ruin, cracked wall to the secret cache with a wick core, 2 hollows |
  | `ow_0_1` | pond and reeds, 4 duskmoths, tether moth on a pedestal |
  | `ow_1_1` | crossroads, 2 tallow blobs, 1 spitcap, cave entrance |
  | `ow_2_1` | dead end, locked door to the pitch pot item |
  | `cave_1` | dark, 2 unlit braziers open a gate to a key, 3 hollows |

- **Route** (all tested): tether moth -> cave entrance -> light both braziers -> key -> locked door -> pitch pot
  (+6 pots) -> cracked wall in `ow_2_0` -> wick core (max hearts 3 -> 4).
- **Tooling**: `make run` (real start), `make dev` (all items, 10 pots, 5 keys, F1 hitbox overlay),
  `tools/capture.tscn` (1920x1080 screenshots incl. flare, charge and pot actions), `make test`, `make check`.
- **Tests**: per-feature suites from WP0-WP6, `tests/test_dev_world.gd` (room contents, layout/reachability on
  the real scenes, a 5 s enemy soak per room, dev loadout), `tests/test_dev_world_route.gd` (the route above).

### Deviations from the step-1 plan

- Pitch pot ammo: still "starts 0" in `GameState`, but picking up the item in the world grants 6
  (`PickupBase.ITEM_FOUND_AMMO`), otherwise the cracked wall could not be opened on the route.
- The cave entrance moved from `(1344, 288)` to the tile centre `(1392, 240)` (spawn marker `FromCave` to
  `(1392, 432)`), so it sits in a rock notch without straddling tiles. `tests/test_world.gd` follows.
- The cave exit is a 2-tile door (192x96) at the bottom of the cave instead of a 1-tile one.
- New placeholder kinds: tree, reed, sign_post, hut. Static props no longer draw the facing nub.
- The HUD item label shows the full name ("Tether Moth") instead of a 9-character cut.

### Step-1 known issues

- The tether moth is not mechanically needed for the route: the plan puts the key behind the braziers, and the
  hook lights them. The moth only comes first by room order and is useful against the hollows.
- The cave is very dark (lamp radius 260 on a near-black room, as in the plan). Unlit braziers are only visible
  close up; there is no hint text in the world by rule. Check the feel in play.
- A pitch pot placed at a cracked wall hurts the player (2 half-hearts, plan) because the wall is within 96 px.
  The player has 1.6 s to step back. Three hearts is enough, but it is tight with a hollow nearby.
- Walking is not simulated end to end: the route test places the player next to each target; reachability of
  everything is proven on the tile grid (`test_dev_world`), and the 5 s soak shows enemies do not clip into
  obstacles. A human playthrough with `make dev` is still the final judge of the feel.
- Skitterwick hops and duskmoth flights slide along obstacles; no special pathing. Hollows walk tile centres, so
  obstacles must stay on the 96 px grid (the layout test enforces the rest).
- The debug overlay draws hit/hurt boxes only, not body or wall shapes.
- Room border (presentation only): `scripts/art/border_edge.gd` gives the wall ring a wavy, per-room deterministic inner
  edge (leaves / rough rock), a contact shadow, a dark band and a lit lip; drawn from `Room._draw`. Collision unchanged.

## Step 2: the art pass (what it adds)

- **Art pipeline**: [asset-contract.md](asset-contract.md) (normative: cells for 96 px tiles, foot line,
  strips, non-destructive post-processing), [art-brief.md](art-brief.md) (style and one prompt per sheet),
  [art-provenance.md](art-provenance.md) (every source sheet with its Codex session, output ID and hash).
  24 step-2 source sheets in `tools/source_art/`; `make art` cuts the sheets listed in `tools/art_manifest.json`
  into `assets/sprites/` and `sprites.json`.
- **Runtime**: `SpriteVisual` (an `AnimatedSprite2D`) replaces `Placeholder` as each entity's `Visual`; it
  builds its frames from the manifest, draws a soft contact shadow and falls back to `Placeholder` for a
  kind without art. `PlayerVisual` picks Tamsin's walk, swing, charge, ward and hurt from her public state.
  Rooms draw world-aligned tiled terrain textures. Water and wall blocks are painted by terrain
  shaders (`assets/shaders/`): touching blocks form one pond with soft, irregular mud banks and a shore
  line, or one ruined wall with a front face, broken top edges and a soft shadow (three-quarter view).
  The collision rectangles are unchanged. The step-1 game logic is unchanged.
- **Walk cycles remade**: the first walk sheets had six near-identical poses per row, so the feet looked still.
  Tamsin's `walk_{down,up,side}` and the hollow's `walk_side` and `walk_up` now come from new sheets with four
  distinct poses (stride, passing, stride, passing; 8 fps); `tamsin_walk.png` stays as the design and scale
  reference only. The hollow's `walk_down` is still from `hush_hollow.png`.
- **Effects**: the hook swing trail (`scripts/art/swing_trail.gd`) and the flare ring
  (`scripts/art/flare_ring.gd`) are procedural, additive light drawn exactly on the hit shapes. The pitch
  pot explosion and the enemy and bush death puffs use the painted explosion strip.
- **Screenshots**: `docs/screens/step2/` (every room, swing, charge, flare, pot, lit brazier, hitboxes).
  `tools/capture.tscn` has a new `--action=swing`.

### Audio

All audio is synthesised by `tools/make_audio.py` (see [audio-provenance.md](audio-provenance.md)); rebuild
with `make audio`. The `Audio` autoload (`scripts/audio/audio.gd`, process mode ALWAYS) offers
`play_sfx(name, at := Vector2.INF, volume_db := 0.0, pitch_jitter := 0.05)` (16 pooled players, 2D when `at`
is given) and `play_music(name)` (1 s crossfade). Buses in `default_bus_layout.tres`: Master, Music (-10 dB), SFX.
Music follows `Events.room_entered`: `cave*` rooms play `cave`, all others `overworld`; it ducks while the tree is
paused. Audio is presentation only: gameplay scripts hold one-line `Audio.play_sfx` calls.

| Sound | Event |
|---|---|
| `swing` | hook swing starts (player) |
| `charge_start`, `charge_ready` | charge begins / reaches full (player) |
| `flare` | charge released (player) |
| `hook_hit`, `enemy_hurt` | hook or flare damages an enemy; any damaging hit (enemy_base) |
| `hook_clank` | hook hits an already lit brazier |
| `bush_cut` | bush cut down |
| `ward_block` | raised ward stops a hitbox |
| `moth_launch`, `stun` | tether moth thrown; an enemy is stunned |
| `pot_place`, `pot_explode` | pitch pot placed; `Events.explosion` |
| `player_hurt`, `player_death` | `Events.player_hurt`, `Events.player_died` |
| `enemy_death` | `Events.enemy_died` |
| `spit` | an enemy fires a projectile (`fire_projectile`) |
| `hollow_dash` | hollow starts its dash |
| `pickup_heart/coin/key/pots/core/item` | `Events.pickup_collected` by kind |
| `gate_open`, `door_unlock`, `wall_break`, `brazier_lit` | gate opens, key unlocks, cracked wall breaks, brazier ignites |
| `room_transition` | `Events.room_entered` (not the first) |
| `pause_open`, `pause_close` | the tree's paused flag changes (watched by the autoload) |
| `menu_move`, `menu_select` | synthesised and loadable, unused: the pause menu has no selectable items |

Not covered: the hook has no hit detection against rocks or walls, so there is no wall-hit sound.

## Open points

- The older C09 OPEN down-throw report has no reconciled result in the current record. The committed P06 change passes four-direction streamed-room checks; do not report a confirmed route failure unless the recheck reproduces one. C09's thorn wall, eye cell and ninth fragment art are mapped in `909800b`.
- Q7's 582 checks pass after `b4449ed`, but the requested 20-encounter weakness coverage is incomplete.
- The Archivist SIGSEGV fix landed in `6753dcf`, and two later global cohorts passed. No current SIGSEGV blocker is recorded.
- Runtime art still has body/transient-tool fallbacks, terrain and pickup/shop gaps, remaining mapping/render cleanup, B09 body/keyhole HOLD, and rejected haloed B01 mouth candidates. Human review is open. P09's low-fence grate fix and actual-World real Moth/player-block/clone/fallback checks passed in `fd5e597`.
- The Abacus Brute and Pale Squire actor-only cue pass is committed (`47db582`, `b3fcc83`); two focused suites and lint passed, and eight dark before/after captures await review. Broader cue cleanup remains open for Lull Mauler, Hushed Colossus, Dirge Choir, Wick Automaton, Corrow's Echo, Hollow Captain, Mirror Warden, Thorn Warden, The Unlit and shared markers.
- M5 Mirror Shade alpha rendering is closed in `d28ec6d`/`c5f109b`, including the default production GPU proof.
- The all-ten walkthrough and README link are committed in `d83944f`; route correction `bb0821b` passed independent review. This is a recommended guide, not a recorded full playthrough.
- The owner has not approved overall balance, visual feel, or a continuous full-game playthrough. Soak/economy, performance/memory, and release/export checks remain open.

## Next steps

1. Publish the verified runtime `16df5d1902a1e8fb6108aa117aa971cccefe44a7` with this docs-only status update to personal `origin/main`; verify the remote SHA.
2. Preserve the foreign staged index, provenance/progress WIP, and untracked art/import/UID work.
3. Fix and verify OW10_3/OW10_7 house access and trigger placement; finish the read-only iframe audit before selecting balance values. The proposed 0.9-second recovery interval is not implemented.
4. Complete Q3 full earned-route playthrough, Q5 per-room visual review, Q6 soak/economy, Q7 weakness coverage, Q8 performance/memory, human balance, and Q9/Z release work.
5. Finish remaining runtime art and obtain human visual approval. Source image production is closed, but the game is not fully art-complete.
