# Current status

**Kilnkeeper wax splash, 2026-10-28 (committed in `9343092`):** A standalone
painted five-frame splash uses a verified ImageGen source, import and provenance,
with a thin active 150 px outline. The animation outlasts the three-frame
hitbox and is cleared on reset, phase change or death; damage and timing are
unchanged. The lead's import, `boss_kilnkeeper` and `route_cave_1` passed, along
with ten additional filter-matched tests; the agent reports lint, B01 ownership
and `art-test` PASS. Actual C1 captures at `/var/tmp/wick-c1-audit/phase1-active.png`,
`phase1-later.png`, `phase2-active.png` and `phase2-later.png` in that directory
used a placed, protected player, molten set and forced phase two, not human play.
Capture exit reported four ObjectDB and two resource warnings; a separate export
has not been verified.

**Lazy ending presentation and Q7 Reel, 2026-10-28 (committed in `a65cec2`
and `42b6327`):** Ending choice zones are created immediately; presentation is
created when the boss flag is set during the fade, or immediately if already
saved. Choice, save and fade behaviour is unchanged. The lead passed `ending`,
`boss_the_unlit`, `area_cave_10` and `tool_matrix`; the agent reports lint and
GUI fixture PASS. Captures are in `/var/tmp/wick-z1-ending-visual/`.

Isolated add-child-only measurements were 9.57–10.16 ms before and 0.15–0.19 ms
after, with work moved to the flag. Whole-switch times were 57.3–62.1 ms before
and 54.1–63.8 ms after, so no reliable overall improvement is demonstrated.
These runs were headless with warm disk; Q8 and the 50 ms limit remain open.

Q7 uses the real Reel Line against three thorn variants and the eye switch;
controlled contact is negative and flags and blockers are checked on recreation
with in-memory state. This is not a complete matrix or human play.

**Gloam and Coinwyrm attack presentation, 2026-10-28 (committed in
`df7de44` and `501765e`):** Gloam Knight's filled slash is replaced with a
procedural multilayer blade glint and 120° outline, without changes to damage,
area or timing. Dedicated painted slash art is still missing. The actual arena
capture `/var/tmp/wick-gloam-b2b4/cave_7_11-east.png` used a placed, protected
player and a frozen attack, not human play.

Coinwyrm uses new ImageGen bite-tell and bite animations when facing downward
within 15°; other directions retain the idle head and directional effect. Plate
hitboxes do not move, the head returns to idle and gameplay is unchanged.
`/home/mikael/.cache/wick-b08-direction/plated-grid.png` and `bare-grid.png` in
the same directory show controlled positioning, not human play. Directional
head animations for other angles remain open.

The lead's import, `boss_coinwyrm`, `area_cave_8`, `boss_gloam_knight` and
`route_cave_7` passed. The first route run stopped due to `/tmp` quota; after a
completed isolated profile was freed, the rerun passed. Agents report lint,
`art-test` and B07/B08 ownership PASS.

**Q8 profiling at clean `b8f75ef`, 2026-10-28:** Across three processes,
`cave_10_12` took 56.276–61.049 ms on its first pass versus 3.330–4.859 ms on
passes two and three; 21 checks passed. Instrumentation found synchronous
preloading of `cave_10_14` and `the_unlit`. Separate measurements were about
27 ms for boss scene load and 5.7 ms for ending scene load; instrumentation and
timing overhead mean these figures cannot be summed. Logs are
`/var/tmp/wick-q8-repeat{1,2,3}.log` and
`/var/tmp/wick-q8-profile-run{1,2,3}.log`. The shared machine was unstable, disk
was warm and runs were headless; calibrated CI, GPU and physical traversal are
not covered. Q8 and the 50 ms limit remain open; the later ending Z1 change is
recorded above.

**Q8 broad survey, 2026-10-28 (committed in `20acebe`):** Three passes over
222 scene targets made 666 direct warps. Matched passes two to three showed
maximum node growth of zero, static-memory growth of 141,888 bytes and zero orphan
growth; no orphans remained after World disposal. The agent reports the isolated
test PASS; the lead independently passed `TMPDIR=/tmp make test T=streaming`.
The agent measured a 6.501 ms mean and 79.971 ms maximum, with an earlier maximum
of 144.305 ms. Logs: `/var/tmp/wick-q8-broad-final.log` and
`/var/tmp/wick-q8-broad-final-rss.csv`. There is no calibrated CI or render/GPU
coverage or full physical traversal; the 50 ms limit is not established and Q8
remains open.

**Earlier Coinwyrm art candidate:** The frontal bite did not match sideways
attacks; its limited downward-facing integration is recorded above.

**Choir Warden song cone, 2026-10-28 (committed in `f6b1daf`):** The note
cone uses the existing painted treble note and a light-independent boundary;
damage, hitbox, ward and timing are unchanged. Actual arena captures are
`/var/tmp/wick-dynamic-7b3d/cave_6_4-tell.png` and
`/var/tmp/wick-dynamic-7b3d/cave_6_4-active.png`, with a placed, protected
player; this is not human play. The lead verified `choir_warden` and
`route_cave_6`; the agent reports lint and MB3 ownership PASS. Choir's song
animation is incomplete and uses `walk_side`. Gloam Knight showed a solid purple
sector in `/var/tmp/wick-dynamic-7b3d/cave_7_11-active.png`; its subsequent
presentation change is recorded above.

**Q7 scoped keys through grates, 2026-10-28 (committed in `045900a`):** Real
Tether Moth retrieves remaining scoped keys across grates in overworld and C1
cases, while Reel Line is stopped. Actual contact is measured and flags and
solid blockers are checked after recreation. These controlled fixtures retain
in-memory state, not a save file; they do not establish human play or a complete
matrix. `tool_matrix`, lint and Q7 ownership are reported PASS.

**Full check in a changing worktree:** `make check` passed 157 Godot test files
including playthrough shards, lint, world-check and 175 Python tests while
uncommitted boss, streaming and Q7 files were changing in parallel. It cannot
be attributed to an exact clean commit. The previous clean full check remains
`b41dc6d`.

**Linux release export at `bb87f58`, 2026-10-28:** A clean export of exact
`bb87f5874b5028374e2444901fe1b2bd56114a12` used official Godot 4.7.2 and its
matching template with an isolated profile. Import and export passed; the new
`.import` and remapped `.ctex` were verified in the PCK. Headless startup and C3
startup passed. In an isolated Xvfb GUI run of the export with
`--start-room=cave_3_9`, the boss naturally fired toward the player at spawn.
The capture is `/var/tmp/wick-bb87-export/c3-ember-flight.png` and the video is
`/var/tmp/wick-bb87-export/c3-export.mkv`. Dummy audio was used; this is neither
human play nor audible-sound verification.

**Q6 and Q8 isolated reports at `d5edd906`, 2026-10-28:** Q6's 16 soak and
economy tests passed. The soak instantiated 222 standalone scenes for five
simulated seconds each, sampling the centre every 0.5 seconds against known
obstacles; economy covered 2,348 checks with controlled drop rolls. This is not
continuous full-body coverage or human balance testing. The temporary log is
`/var/tmp/wick-q6-d5edd906-results.log`.

Q8 passed three headless four-room loops, each with 300 warps and 300
input-driven slides, using a placed player with damage disabled. Runs reported
276 nodes, peak RSS 161,816–163,712 KiB, RSS change of 96–155 KiB between the
2–3s and 8–9s windows, mean warp time 5.58–5.69 ms and maximum 42.26–46.19 ms,
and zero orphans at World disposal. Logs are in `/var/tmp/wick-q8-db8871/`.
This short warm loop does not cover GPU, cold start, calibrated CI or a
long-term plateau; Q8 is not fully verified.

**Tidewick ember bolt, 2026-10-28 (committed in `bb87f58`):** Tidewick now
fires a correctly oriented, painted animated ember bolt in place of the spore.
Its light is presentation-only, not gameplay glow; the existing fallback, speed,
damage and collision logic remain unchanged. The pipeline reuses a
provenance-documented source image and includes the Godot `.import`. The lead's
import, `boss_tidewick`, `area_cave_3` and `tool_matrix` passed; the agent reports
lint, B03 ownership and `art-test` PASS. The active arena capture
`/home/mikael/.cache/wick-b03-final/ember-flight.png` used a controlled, protected
player; human play remains unverified. The subsequent export check and Q6/Q8
reports are recorded above.

**Coinwyrm attack presentation, 2026-10-28 (committed in `3601e4b`):**
Transparent outlines replace the filled bite and tail areas; the bite reuses
three painted coin impacts and the tail uses existing art. Collision, damage and
timing are unchanged. Actual active-state captures are
`/var/tmp/wick-b08-f29-bite.png` and `/var/tmp/wick-b08-f29-tail.png`, with
controlled positioning and a forced tail phase. The lead's `boss_coinwyrm` and
`route_cave_8` tests passed; the agent reports lint and B08 ownership PASS. A
distinct jaw animation is still missing, and this is not human play. Tidewick's
subsequent projectile change is recorded above.

**Boss attack visual audit, 2026-10-28:** At `304ce37`, an audit in the
actual World with ticking bosses and controlled player position visually found
Coinwyrm's active bite to be a solid-colour effect. Code also shows a
solid-colour tail sweep, which was not visually captured. Tidewick fires a
spore projectile instead of the planned ember bolt. Images are in the temporary
directory `/var/tmp/wickwarden-attack-audit-9155`. Coinwyrm and Tidewick
corrections are recorded above. This is not complete attack-state
coverage or human play.

**Route repeat and Q7 light/blast checks, 2026-10-28:** The route at `d003e28`
was run three times with normal damage and enemy AI; all three reached the final
boss and actual ending. The bot reads internal state, uses randomness and
respawns; this is not evidence of human balance or play. At `304ce37`, real
Glow Jar and Chime are tested against three secret openings: the Jar reveals
them and Chime does not. Real pitch-pot explosions open two cracked obstacle
types; flare does not. Contact, flags and solidity are checked on revisit using
in-memory state. The targeted `tool_matrix` test passed. These controlled
fixtures do not prove human play or complete tool/gate coverage; the latest full
`make check` remains `b41dc6d`.

**Q7 gate revisit cases, 2026-10-28 (committed in `0faeca5`):** Real Wick
positives cover three thorn variants, sling covers the eye switch and Chime covers
three resonance variants. Twenty-one hook/flare/pot negatives confirm contact
and check flags and solid blockers on revisit, including both eye blockers.
Isolated `tool_matrix` and lint passed; these are controlled fixtures, not human
play. Other tools, gates and encounter combinations remain open. The latest full
check was at `b41dc6d`.

**Q7 wax seal, 2026-10-28 (committed in `52cbdeb`):** A real flare opens the
seal after a controlled initial hook miss; hook and pitch-pot explosion are
negative with confirmed contact. Flag and solidity are checked before and after
revisit. Isolated `tool_matrix` and lint passed. This is a controlled fixture,
not human play; other tools and combinations remain open.

**Q7 hook-tap wall, 2026-10-28 (committed in `a403f20`):** A real hook hit is
positive; flare and pitch-pot explosion are negative with confirmed contact and
flag/solidity checked before and after revisit. The flare is charged beyond hook
range to prove the hook misses. Isolated `tool_matrix` and lint passed; this is a
controlled fixture, not human play. Other tools and matrix cases remain open.
The latest full `make check` was at `b41dc6d`, before this test change.

**C10 lantern glow, 2026-10-28 (committed in `b41dc6d`):** Two painted glow
variants alternate every 0.5 seconds through a presentation child that follows
the lantern after the boss dies. Mechanics are unchanged. Isolated import,
`boss_the_unlit`, `tool_matrix`, lint and `art-test` passed. An actual-arena
capture used forced phase two and a placed player, not human play. A new shell
walk candidate was rejected for scale and is not in runtime; shell animations
and the E1 conflict remain open. An isolated `make check` passed at `b41dc6d`:
157 Godot test files including playthrough, lint, world-check and 175 Python
tests. Another agent continues Q7 in an isolated copy.

**Q7 heavy obstacles, 2026-10-28 (committed in `26713bf`):** Twelve negative
cases use actual hook, flare and pitch-pot explosion against four heavy variants,
verifying contact and that each obstacle remains solid, undisturbed and unflagged
after revisit. Existing positive Mitts cases remain. Isolated `tool_matrix` and
lint passed; other gate families, tools and combinations remain incomplete and
this is not human gameplay. The latest full `make check` was at `c31b391`, before
this test change.

**Unlit heart states, 2026-10-28 (committed in `c31b391`):** Shielded and
exposed pulse states use two provenance-recorded ImageGen edits of the accepted
heart, shown on the existing timer with a small light. Gameplay and hitboxes are
unchanged. Isolated import, `boss_the_unlit` (296 checks), `tool_matrix` (1201),
lint and `art-test` passed. An actual C10 capture used a controlled phase and
real Reel, with the player repositioned and hurtbox disabled; it is not human
play. The later lantern glow is recorded above; shell animations remain incomplete. Gloam source review tested
all documented sources: none supplied a correctly segmented, correctly scaled
four-pose slash row, so none was installed; the rejected candidate and log remain.
The first full `make check` produced 13 route failures when temporary quota forced
profiles to `/var/tmp`, while the test safety boundary requires `/tmp`. After a
finished 101 MB scratch project copy was removed, `route_cave_5` passed and a
subsequent isolated `make check` passed 157 Godot test files, lint, world-check
and 175 Python tests. Remaining C10 animation art and the E1 conflict stay open.

**Gloam Knight animation, 2026-10-28 (committed in `cea4152`):** Two crouch
frames play during the existing 0.5-second warning, retaining the prior fallback.
Four `walk_side` frames are selected at nonzero speed, but the fight has no
natural walking; that cycle was tested in an arranged state. Isolated import,
`boss_gloam_knight`, `area_cave_7`, `tool_matrix`, lint and `art-test` passed,
and arena images were reviewed; human play remains unverified. Slash and other
phases remain incomplete; the image pipeline is seeking a suitable source.

**Export intro and animation audit, 2026-10-28:** A clean export of `d33a360`
under Xvfb used actual New game input, showed all six intro texts and images and
naturally entered World with isolated saves. Dummy audio was used; two ALSA
capture attempts failed, so audible audio remains unverified. Animation audit
found C10 phase-two, phase-three and lantern runtime art is idle-only, one frame,
and Gloam Knight used still images only at that audit. Later Gloam and heart-state
work is recorded above; planned animations remain incomplete. The earlier C10
candidate images lacked provenance and differed visually. The E1 specification
conflict remains open.

**Q7 real-tool extensions, 2026-10-28 (committed in `58c58bc`):** Actual tools
exercise The Unlit's five sling eyes, three Wick casts, Reel exposure and hook
against shield and heart, plus two two-half-heart fire ticks on Thorn Warden.
Isolated `tool_matrix` and lint passed. Positions are controlled and player
hurtbox disabled; this is not human play. Full tool/phase permutations and gate
negative cases remain incomplete. `make rooms-check` passed 221 rooms and
`art-test` passed 22 tests; the test tool emitted expected mismatch and resource
warnings. Later export intro and animation audit results are recorded above;
E1's specification conflict remains unanswered.

**Intro and Thorn Warden presentation, 2026-10-28 (committed in `0b6f9ca`):**
Six previously missing active intro images were completed from earlier generated
candidates, with provenance in `docs/art-provenance.md`; the actual intro was
visually reviewed at accelerated speed. Thorn Warden projectiles use a painted
lance instead of a diamond; natural emission in `cave_2_4` was reviewed with a
placed player. Isolated import, `intro`, `thorn_warden`, `area_cave_2` and lint
passed; this is not human play. A static asset audit found file resources for all
200 manifest kinds, without covering all dynamic states. Isolated `make check`
passed on `0b6f9ca`: 157 Godot test files including the full playthrough
shards, lint, world-check and 175 Python tests. Human play, complete dynamic
visual coverage and the ending-choice conflict remain open. A clean Linux export
on `0b6f9ca` using official Godot 4.7.2 passed import, export and headless
startup; its log includes all six intro PNG `.import` and ctex files, intro JSON
and scene. At that check the project intro was visually reviewed, not the exported
intro; the later export intro check is recorded above. A direct scene override exited 1 because the release
template does not support path overrides; this limits that method, not the
headless startup result.

**Cinder Wisp windup, 2026-10-28 (committed in `0a1c45d`):** The white warning
disc is replaced by a painted buildup and light-independent 150 px outline. The
0.5-second duration, damage and mechanics are unchanged; the active attack stays
separate. Isolated `test_cinder_wisp` and lint passed, including fallback and
stun. Bright and dark actual-room captures froze a natural windup with a placed
player; this is not human playtesting. An isolated `make check` passed on
`0a1c45d`: 157 Godot test files including four playthrough shards, lint,
world-check and 175 Python tests. A completed route is verified by test input
using internal information, not human balance play. Full visual coverage of all
possible states and E1's touch-versus-confirm specification conflict remain open.

**Snapper and Choirling warnings, 2026-10-28 (committed in `19acc05`):** Both
use painted warnings with clear edges; attack areas and timing are unchanged.
Isolated `bramble_snapper`, `choirling`, `area_cave_6` and lint passed. Images
used actual rooms with a placed player; Choirling was in a natural state, not
human play. The Snapper capture reported resource warnings at exit, cause
unknown. The later Wisp warning change and full check are recorded above.

**Gloam Knight and Dirge Choir effects, 2026-10-28 (committed in `5536695`):**
The Knight's landing and ring and the Choir's alto sector use painted effects
with thin outlines; hit areas and timing are unchanged. Isolated
`boss_gloam_knight`, `area_cave_7`, `route_cave_7`, `boss_dirge_choir`,
`area_cave_6` and lint passed. Actual-arena stills used forced frozen Knight
effects; its ring can, as before, appear outside the island where collisions are
inactive. The Choir attack was natural but the player was placed and its
hurtbox disabled. Human play remains unverified. An isolated full `make check`
passed on `5536695`: 157 Godot test files including playthrough, lint,
world-check and 175 Python tests. Images of shared telegraphs identified clear
presentation candidates for Cinder Wisp, Bramble Snapper and Choirling; later
Snapper and Choirling work is recorded above. Many thin markers are intentional
readability aids.

**Verification and visual follow-up at `80599b6`, 2026-10-28:** Isolated
`make check` passed 157 Godot test files including playthrough, lint,
world-check and 175 Python tests. Visual inventory found a filled Gloam Knight
landing disc and Dirge Choir's alto sector; the later change is recorded above.

**Miniboss warnings, 2026-10-28 (committed in `80599b6`):** Wick Automaton's
tell uses muted painted fire and a thin outline; Corrow's Echo GLOW/FLARE outline
is visible outside lamp light. Mechanics are unchanged. Isolated `wick_automaton`,
`corrows_echo`, `area_cave_10` and lint passed. Captures used actual cave rooms
with a placed player; Echo had raised test health and FLARE was slowed after a
natural transition. This is not human playtesting. Some capture tools reported
resource warnings on exit, cause unknown.

**Export check at `666d61d`, 2026-10-28:** An export using the official Godot
4.7.2 template contained all 222 world scenes, JSON and title images. The actual
GUI title screen and headless startup passed; gameplay and audio were not verified.

**Title and Lull Mauler presentation, 2026-10-28 (committed in `666d61d`):**
The title uses the planned painted splash, upscaled from a previously reviewed
source, and a new native-alpha logo recorded in `docs/art-provenance.md`. The
actual title scene was reviewed with and without an isolated test save;
`test_title` passed. The Mauler's smash warning uses painted cracks and its
sweep outline is visible in darkness; its focused test passed and a natural
state was reviewed with a placed player, not human play. Capture exit reported
resource warnings of unknown cause. Further late effects remain to be reviewed.
An isolated full `make check` has since passed on `666d61d`: 157 Godot test
files including the playthrough, lint, world-check and 175 Python tests. Export
verification and miniboss results are recorded above; further review remains.

**Verification at `e760223`, 2026-10-28:** `TMPDIR=/tmp make check` passed 157
Godot test files, lint, world-check and 175 Python tests. `TMPDIR=/tmp make
playthrough` passed the route check and all four shard files, including a
continuous fresh-save run through all caves and the final boss to the actual
ending. The bot reads internal state; this is not human playtesting and does not
prove every branch. The earlier separate checks of both endings remain separate
evidence. Full effect inventory remains in progress.

**Colossus attack presentation, 2026-10-28 (committed in `e760223`):** Slam,
ring and sweep, plus the yellow sweep and slam warnings, use painted effects and
thin hit-area boundaries; timing and hitboxes are unchanged. Isolated
`boss_hushed_colossus` and `area_cave_4` tests and lint passed. Stills from the
actual C4 arena used forced states, not human play. A small seam is visible in
the ring texture. Full effect inventory and natural playtesting remain open.

**Sump Lurker water tells, 2026-10-28 (committed in `772915a`):** The water
marker and bite warning reuse painted water art with mechanics unchanged. The
isolated `sump_lurker` test and lint passed. Natural states in `cave_3_4` were
visually reviewed with a placed player, not through human play or multiple
angles. The capture tool reported a resource/ObjectDB warning on exit; its cause
is unknown. The later Colossus presentation work is recorded above.

**Fen Leech warning, 2026-10-28 (committed in `ceb9c4b`):** Existing painted
water art replaces the yellow Placeholder puffs, with the 0.5-second warning
and mechanics unchanged. The isolated `fen_leech` test and lint passed. Captures
used a forced warning from a moving raft in dark `cave_3_6`; natural play has not
been tested. Static inventory identified candidate geometric effects in the
Colossus slam, shockwave and sweep and in Sump Lurker. Later Sump work is
recorded above; later Colossus work is also above and the full inventory is incomplete.

**Cinder Wisp active attack, 2026-10-28 (committed in `7b25985`):** The attack
reuses a painted fire ring with an outline marking its radius; mechanics are
unchanged. The isolated `cinder_wisp` test and lint passed. Controlled-position
captures were reviewed in a bright room and a dark cave, not human play. The
Fen Leech warning changed later as recorded above; the full inventory is incomplete.

**Independent placeholder census at `52cbdeb`, 2026-10-28 (read-only):** A
clean isolated scan instantiated all 222 World targets and inspected them after
four physics frames. It found four Placeholder nodes, all hidden in the tree:
the hook wall in `ow_8_0`, seam in `ow_11_7`, wax plate in `cave_1_8`, and
boss base in `cave_6_11`; none was visible. The temporary report is
`/var/tmp/wick-audit-52/census.json`. This does not prove pixels or cover later
attacks and transitions, in-place pockets, HUD, conditional fallbacks or human
play; full dynamic and visual coverage remains open.

**Earlier placeholder census, 2026-10-28 (read-only):** An isolated scan of 222
standalone room targets after four physics frames found 35 Placeholder nodes:
31 visible in the tree and four hidden, including generic puffs. Tree visibility
is not pixel proof, and this is not coverage of every state. At that census,
Fen Leech bubble and Cinder Wisp `flame_ring` were visually confirmed; the later
Wisp change is recorded above. Previously identified effects have been fixed or remain fallbacks, not
a guarantee that all placeholders are resolved. Active phases, HUD, in-place
pockets and human play are not fully reviewed. The temporary census is
`/tmp/wick-placeholder-audit/report.json`.

**E1 ending-flow verification, 2026-10-28 (fixtures; documented in `b59388c`):** Two separate
fixture saves with boss flag and checkpoint used actual player inputs under the
current confirm behavior through World → actual `ending.tscn` → credits → title
→ Continue → World. Each retained its correct exclusive ending flag, completed
state and save slot. Rekindle used the full natural holds; Wickwarden used
confirm-skip. Rendered text, images and credits were reviewed. The scratch
harness reported shutdown leak warnings after Continue; these have not been
shown to be a product defect. No real saves were touched. These are not an
earned boss route or human test; the ending-choice contract conflict and user
question remain open.

**Q3 playthrough command, 2026-10-28 (documented in `338e41f`):** After `59e339f`, the lead's
`TMPDIR=/tmp make playthrough` passed: `playthrough_route --check` and all four
shards passed. The first contains the continuous earned normal-damage route to
the rekindle scene described below; later sections use fixtures and warps. This
is not human testing. The bot, RNG and harness limitations below, untested
continuous credits/title and other ending, E1 conflict and Fen Leech placeholder
remain open.

**B03/B09 immunity fixes, 2026-10-28 (committed in `59e339f`):** Both subclass
initializers now call `BossBase`'s initializer; actual scenes have stun and
knockback scales zero and drops disabled. In B09, real sling damage no longer
pushes and the Moth does not stun; forced-death drop checks show only intended
embers. B03 retains real raft/tail and reward behavior. The agents report isolated
B03, B09, C3, C9 and Q7 tests and lint passing; the lead passed the five
corresponding tests. The earlier continuous Q3 ending-scene win depended on B09
knockback and predates these fixes; the synced rerun is recorded below.

**B09/B03 immunity audit, 2026-10-28:** In the actual Lock Warden scene,
knockback and stun scales are 1: an actual slug moves the boss and an actual
Moth stuns it, contrary to the binding boss immunity and stationary Warden
requirements. The audit points to subclass `_init`; `drops_enabled` is also
true, a static risk of unplanned drops. Tidewick likewise has defaults 1/true,
but its separate hitboxes filter interactions and a direct effect was not
demonstrated. The later committed fixes are recorded above. The earlier Q3
ending-scene victory preceded the B09 fix; the synced rerun is below.

**Q3 earned route to ending scene, 2026-10-28 (committed in `59e339f`):** The
continuous input route from start through C1–C10 defeats The Unlit with normal
damage and active enemies, including an ordinary boss death, respawn and full
return, and an actual slug-bundle pickup. Phase one uses 15 sling shots, phase
two three Cinder Wick uses and ward, and phase three a physical ember, three Reel
uses and 24 hook damage; victory leaves 10/28 half-hearts. Physical contact at
the left pedestal plus the current confirm action loads the actual `ending.tscn`
and sets `ending_rekindle` and `completed`. To protect the test harness, the
test sets `current_scene` to null and restores the runner; SaveGame is disabled.
With both B03 and B09 fixes synced, the agent reports two exact isolated first
shards, a separate audit, shards 2–4 and lint passing. B09 remained stationary;
C9 victory was at 15/26 and C10 at 10/28. Actual ammo and ember were collected,
with ordinary C9 and C10 respawns, active enemies and no warp or manual state in
the continuous portion. The lead's `TMPDIR=/tmp make check` passed with the
B03/B09 fixes and route to ending: all Godot suites including four shards, lint,
world-data and Python tests. Credits, title return and the other ending are not
continuously tested. The bot reads boss, hazards, eyes, projectiles and other
internal state; the global seed does not control or log two bosses' own RNG, and
C7 had a 1/22 margin. Human play and balance remain open; the ending-choice
contract conflict and pending user decision remain unchanged.

**Z3 Linux export smoke test, 2026-10-28 (committed in `fec1e95`):**
`export_presets.cfg` defines Linux x86_64 with `all_resources`, `*.json`
included and `tests/*` and `tools/*` excluded. In isolated scratch using the
official Godot 4.7.2 template, the agent reports building a PCK and release
executable and running headless for 120 frames with Dummy audio and exit 0.
The export log contains four data JSON files, `sprites.json` and 222 room/pocket
paths. Scratch and its templates were removed; real saves and installed templates
were untouched. This is not human, audio, visual or full-playthrough verification;
Q3, E1 and release gates remain open.

**Q3 C10 boss entrance, 2026-10-28 (committed in `0d3ab88`):** With the room-10
fix `b5ba112` synced, the continuous earned input route physically spends key
two at `e242`, collects key three and spends it at `e243`, collects a +6 slug
bundle, uses the sling eye, earns the Lockpick and opens the boss door to the
actual The Unlit in `cave_10_14`. Entry is 10/28 half-hearts, 10 pots and 24
slugs. Enemies and damage are active, Echo is bypassed alive, no warp or manual
state is used, and the route includes an earlier ordinary respawn. The agent
reports two first-shard runs, shards 2–4 and lint passing; the lead passed
`TMPDIR=/tmp make test T=playthrough_1` locally with the boss entrance.
Global seed `20261027` does not control independent boss RNG; the bot reads boss
ID, phase and HP and earlier enemy/projectile state. At that checkpoint victory
and a full ending remained open; the later unpushed route and remaining limits
are recorded above. E1 is unchanged and the user response remains pending.

**C10.c room-10 geometry, 2026-10-28 (committed in `b5ba112`):** Two floor
tiles were opened in `cave_10_10` and `make rooms` generated the scene. From
the north bank, actual Reel input reaches `e242` and key three; a separate
ward-cache case uses real watcher shots and ward, then returns by Reel. These
fixtures grant the loadout, start position and key and use 40 half-hearts, with
damage and enemies active. The agent reports `rooms-check` 221, C10 area/route,
the new test twice and lint passing. The lead passed the new test and
`hidden_seam` and reviewed an actual-room capture. The lead's `TMPDIR=/tmp make
check` passed the Godot suite including four shards, lint, world-data and 175
Python tests with the preceding version of the new tests. Independent review
found no confirmed blockers or new shortcuts; `rooms-check` 221 and the 30-check
test passed. The null-hound false-pass risk was corrected: the regression now
requires an actual living hound and then that same hound defeated. The agent
reports the corrected test and lint passing; the full `make check` preceded this
test-only correction. The north boundary without Reel and the return transition have not
been dynamically tested; the fixture uses 40 HP and human play remains open.
The later unpushed earned route to the boss entrance is recorded above.

**C10 room-10 access investigation, 2026-10-28:** Two independent input and
geometry probes found the `cave_10_10` landing at `(1008, 648)` separated from
western `e242` by a pit and walls; the ward-cache entrance is also enclosed.
This strongly suggests a level problem, but does not formally exclude every
tool interaction. A `FromPocket` fixture placed on the other side can walk to
`e242` and key three with damage and enemies active. C10.c's committed room
correction is recorded above. The Q3 route repeatedly reaches the
second Reel bank at 14/28 half-hearts in the earlier run. The lead
passed `TMPDIR=/tmp make test T=playthrough_1` locally for this landing; the
later unpushed continuation to key three is recorded above.

**Q3 C10 room 10, 2026-10-28 (committed in `0ca0ee6`):** The continuous input
route defeats three Mirror Shades, uses the actual Chime, earns the second key,
and after an ordinary enemy death and respawn retains a key. It uses raft,
mitts, boots and Reel to reach `cave_10_10` with 14/28 half-hearts and one C10
key. Damage and enemies are active, Echo is bypassed alive, and no warps or
manual state changes are used. Further attempts failed and were not integrated;
key three, Lockpick, boss and ending remain open. The agent reports two full
isolated first-shard runs, shards 2–4 and lint passing; the lead passed
`TMPDIR=/tmp make test T=playthrough_1` locally with the new section. Archivist
and Tidewick use unlogged independent RNG; earlier bot
internal-state reads, C7's low margin and human-play limits remain.

**F3 runner import isolation, 2026-10-28 (committed in `ca183c1`):**
`tools/run_godot_check.py` now creates its temporary root before `ensure_import`;
Godot import receives a separate `isolated_env` under `import`, and each suite
continues to use its own user directory. The agent reports isolated import and
`save_game`, lint, and fake-home/mock tests under `/tmp`, `/var/tmp` and custom
`TMPDIR` passing. The lead passed `TMPDIR=/tmp` with `--import save_game`. Q3's
hard `/tmp` guard is unchanged; a shared runner guard and Q3 changes require WP
owner coordination. This is not a complete solution or protection against
malicious code.

**Q3 C10 approach, 2026-10-28 (committed in `9bfe631`):** The continuous
earned input route with normal damage wins C9, physically buys healing and slugs
at S5 for 45 earned brass, passes the Ninth Door with nine fragments, then earns
the Wick and first key, passes the living Echo, uses the raft and Jar and reaches
`cave_10_6` with 14/28 half-hearts and 19 slugs. C10 boss and ending are not
verified. A second-key attempt died or became stuck and was not integrated. The
agent reports two isolated first-shard runs, all four shards and lint passing;
the `/dev/shm` scratch copy needed an isolated runner-path adjustment only in
that copy. The lead's first workspace `make test T=playthrough_1` reached C10
room 6 but failed the disk-roundtrip safety check: the `/tmp` user quota was
full and tempfile fell back to `/var/tmp`. After removing the lead's own finished
temporary verification copy, `TMPDIR=/tmp make test T=playthrough_1` passed with
isolated user data; no real saves were touched. Earlier RNG, bot internal-state
reads, bypassed minibosses and human-play limitations remain.

**C10 final-boss probe, 2026-10-28 (isolated; documented in `79369cd`):** A 47-check probe uses actual
World and final boss with normal damage, active hounds and wicklings, and sling,
Wick, Reel and hook, winning with 3/28 half-hearts. It physically tests a socket
and confirm flag with `dry_run=true`, so no actual scene transition occurs. The
fixture grants tools, health and ammo and repositions beside targets; this is
not an earned route or human proof.

**E1 ending-choice conflict, 2026-10-28 (documented in `79369cd`):** Binding `monsters-bosses-tools.md`
§4.10 says touching a choice selects it, while binding `world-work-packages.md`
§8.2 E1 says to walk to a pedestal and confirm. Decision 40 resolves the file
and flag names only. The current trigger requires confirm while touching; it is
unchanged and no implementation change has been made. The user has been asked
to resolve the conflict. The probe exercises current confirm behavior, not touch
alone; its fixture and dry-run limitations above remain.

**Q3 Lock Warden victory, 2026-10-27 (committed in `fc895af`):** The continuous
earned input route with normal damage and an ordinary C9 respawn breaks all four
actual plates with sling shots and defeats Lock Warden. It physically collects
fragment and core, raising maximum health from 26 to 28 and restoring health to
28. After the plates, the player physically collects the phase-change ember:
the PickupCollector signal counts exactly one and health is checked from 13 to
15/26. The victory leaves 15/26 and one slug after 25 used in phase two. A
wickling count was observed changing from one to zero; its exact cause is
unknown. Enemies and damage remain active. The agent reports two final isolated
runs, shards 2–4 and lint passing. Global seed `20261027` does not control or log
Archivist's and Tidewick's own randomization. The bot reads boss, eye, plate,
`open_left`, `bolt_left`, wickling and projectile position/direction state, plus
earlier bosses' internals. Active minibosses are bypassed; human play, other
seeds and a complete game remain unverified.

**B04 quake art, 2026-10-27 (committed in `8a0b157`):** Native-alpha painted
cracks cover dangerous 96×96 checkerboard tiles; outline and fill show the full
hit rectangles and the active state is brighter. Timing, damage and arena light
are unchanged. The lead reviewed warning and active captures in the actual
arena with a forced hazard; the agent reviewed both parities and 72 tiles and
reports boss and route tests and lint passing. Human action play remains open.
The art agent maintains provenance separately.

**C9 direct phase-two fixture, 2026-10-27 (isolated):** With normal damage,
three of three attempts used actual inputs, ward and six flares to win and
physically collect fragment and core, raising maximum health from 26 to 28.
Wicklings were initially alive, but phase was set directly and the player placed
at 13/26; the reported health before rewards was 3/26. The bot tracks the boss
because of knockback. This is not a continuous earned-route victory.

**C9 phase-two survival probes, 2026-10-27 (isolated; documented in `196d4a6`):** The
continuous earned route reaches phase two at 13/26 half-hearts with enemies
and damage active. The best pot probe reduced boss HP from 24 to 16; the player
was at 5/26 after the second hit and then died. Sling, hook and flare variants
also died; none demonstrated victory or was integrated. The Q3 bot reads boss,
plate, projectile and player state. Global seed `20261027` does not control or
log Archivist's and Tidewick's own randomization. Another agent is analysing
survival.

**Q3 C9 phase two, 2026-10-27 (committed in `44d0f0e`):** After an ordinary
boss death, respawn and return, the continuous input route uses actual sling and
pots to break all four plates with normal damage and living wicklings. It reaches
phase two with boss HP 24 and player health 13/26; C9 victory and its core remain
unverified. The agent reports five separate green runs, four shards and lint
passing; the lead also passed `make test T=playthrough_1` in the workspace with
the pushed boots fix after phase-two integration. The bot reads
plates, eye positions, lid, phase, HP, player, item and flags. Earlier bosses
also use internal reads; uncontrolled RNG, the C7 low margin, bypassed living
minibosses, other seeds, human play and a complete route remain limitations.

**Q3 C9 boss approach, 2026-10-27 (committed in `c3f759f`):** The continuous
earned input route with normal damage obtains the Jar, Wick, first key, raft,
boots, second key, Reel and Lockpick, passes the active miniboss and opens the
boss door. After a deliberate ordinary boss death and respawn at `ow_0_2`, it
returns with the Lockpick and reaches the boss with 25/26 half-hearts, 10 pots
and 30 slugs. The boss is not defeated; unintegrated probes broke plates but
died or retreated in phase two. The C5 physical-reward route was improved after
a random failure. The agent reports four shards, a first-shard repeat and lint
passing. These baseline runs used the original World before the fix; after C9
entry integration, the lead also passed `make test T=playthrough_1` in the
workspace with the pushed boots fix `ed79ed0`. Archivist's own RNG is uncontrolled,
the C7 victory had a low margin, and other seeds, human play and a complete
route remain unverified.

**C9 resupply probe, 2026-10-27 (isolated):** With real World and input, a
fixture starting at 0 pots and 0 slugs physically collected +4 pots and +6
slugs after the intro, then collected them again after manual reset to zero and
31 seconds. Four actual sling/pot eye-and-plate interactions passed; the probe
reported 13/13 checks. Ammo pickups expire after 8 seconds and resupply is at
30 seconds. Damage was disabled, two wicklings removed and tools fixture-granted;
this is not an earned route, survival test, human play or phase-two victory.
An initial attempt with living wicklings missed a shot; its cause is unknown.

**Q7 gate audit and rush wall, 2026-10-27 (committed in `10738c7`):** Every
world-graph gate family has a representative case, but the full correct/wrong
tool matrix and its printed report are incomplete. Several negative cases do
not prove actual hitbox overlap; the newer base-weapon and rush-Reel cases do.
In the new controlled-position case, the real Reel is rejected and a charged
flare cuts `rush_wall`, with normal player damage and drops disabled. The agent
reports two isolated matrix runs and lint passing. Graph edges, persistence,
phases, real-room and human coverage have substantial gaps.

**Q7 wrong-tool gate cases, 2026-10-27 (committed in `3b96eec`):** Twenty-one
cases use actual hook, charged flare and exploding pot against seven real thorn,
eye and resonance gates. Actual hitbox overlap is checked, with no incorrect
opening, flag or collision change. Arenas are controlled and player damage is
normal; correct-tool positive cases existed previously. The agent reports two
isolated matrix runs and lint passing. Other combinations, real-room and human
verification remain open.

**Fen Leech presentation (documented in `750e4f1`):** An earlier prototype was rejected because it
overlaps at 35 px in darkness. A later unpublished paired-cluster prototype was
also rejected: it sits behind the player but hides one cluster, has broad static
duplication, and the actual raft route places part of it on land. Close real-raft,
multiple-enemy and cleanup behavior were not verified. Neither candidate changed
the repo. A subsequent native-alpha plume placed on the leech was also rejected
and not integrated: at 100% it covered the player's face during an actual moving
near-raft sequence, while at 45% it was too faint in darkness. Isolated tests
passed multiple warnings and cleanup on state exit, free and parent free; room
transition and human play were not verified. The later committed warning change
is recorded above.

**Q3 Coinwyrm victory, 2026-10-27 (committed in `6f33c12`):** The continuous
earned input route defeats C8's Coinwyrm with normal damage, using three keys,
the Reel and boots and passing an active miniboss. The reported victory leaves
3/24 half-hearts before physically collecting the fragment and core; the core
raises maximum health from 24 to 26 and restores health to 26. The agent reports
five victories, four isolated shards and lint passing; the original C8 runs
used the unchanged HEAD World. Global seed `20261027`
does not control Archivist's own randomization. The bot reads boss plates, state,
positions and projectiles as well as earlier internal state; the C7 victory had
1/22 health and minibosses remain active. Human play, a complete route and other
seeds remain unverified.

**Z1 revised one-way fix, 2026-10-27 (committed in `ed79ed0`):** Version 3
restores Player and World byte-identically and places the boots-start overlap
check in `scripts/items/skitter_boots.gd` (`_free_run`/`activate`) to preserve
the generic Player contract. It rejects WORLD overlaps except leapable rails,
including a jump away until the body is clear. The agent reports 120 regression
checks covering natural arrival, free jump starts after 3/15 frames, rails,
corners, real Reel and raft and damage, plus 15 relevant test files, lint and
visual captures. Independent review passed without blockers and verified the generic
Player contract, rail/overlap query, isolated 120-check one-way regression,
boots, raft, Reel, tool matrix and C7–C10 routes. The query is a snapshot, not
coverage of all moving obstacles or angles; a rejected press requires a new
press after clearing the overlap. The lead's full `make check` passed with the
reworked fix: the Godot suite including all four playthrough shards, lint,
world-data check and 175 Python tests. Human real-time play remains unverified.

**Z1 first proposal, 2026-10-27 (not accepted):** At a blocked
edge, World ends external movement and places the player inside the wall plus
body radius. The `e041`/`e087` softlock was reproduced before the fix. The agent
reports 62 checks after it with real input and natural landing, both edges and
3/15-frame controls, observing over 10 seconds, collision, normal damage and
walking away; the fixture grants boots and removes enemies. Movement, boots,
World and C7/C8/C9/Gravelight route tests, lint and visual captures are reported
passing/reviewed by the agent. An independent reviewer identified a risk that
the proposal could cancel raft or Reel movement at a closed edge and place the
player unsafely near corners or obstacles. This is a review finding, not a
reproduced actual route. The proposal was not accepted; the revision is above.

**B10 heart pulse, 2026-10-27 (committed in `6f33c12`):** A new native-alpha
source supplies the painted phase-three heart pulse through the ordinary art
pipeline; geometry, warning, speed and damage are unchanged. The lead reviewed
radius 200; the agent reviewed 40, 200 and 360 and a phase-two regression.
The agent reports isolated B10 and route tests, 22 art tests and lint passing.
The source and prompt are recorded in `tools/source_art/unlit-heart-pulse-z1-log.md`
and `docs/art-provenance.md`. Controlled frozen-ring captures do not establish
human action play; human play remains open.

**Q7 one-way transitions, 2026-10-27 (committed in `ce9dc58`):** Real World
cases for `e041` and `e087` walk down normally and check that boots cannot
return from a controlled position 210 px into the lower room. Enemies are
removed and damage remains active. The agent reports two runs with isolated
user data in the shared project and lint passing. A separate natural-arrival
probe confirmed a softlock: immediate upward boots use reproduced it 3/3 times
on each edge, leaving the player airborne with collision and hurtbox disabled
for over 10 seconds. Enemies were removed, damage active and tools supplied by
fixture. Controls delayed by 3 or 15 physics frames worked. The prior uncertain
observation is superseded; the unaccepted Z1 proposal and its review are
recorded above. The committed controlled-position test does not cover this
natural-arrival edge case.

**Q3 Gloam Knight victory, 2026-10-27 (committed in `3a36abb`):** The continuous
input route with normal damage and ordinary respawns defeats the C7 boss and
physically collects its fragment and core; the core raises maximum health from
22 to 24 half-hearts and restores health to 24. The C7 miniboss is bypassed and
alive. The bot attacks the Knight from the north with the hook after its dive,
without boots in the fight, and the reported victory leaves 1/22 half-hearts.
It reads mode, phase, target, position, island and hurtbox state; earlier bosses
also use extensive internal-state reads, and Archivist randomization is not
controlled. The agent reports five C7 victories, four isolated shards and lint
passing; a different variant died at C5. Other seeds, human balance and a full
route remain unverified.

**M0 guard spark, 2026-10-27 (committed in `3a36abb`):** The existing painted
`lock_key_volley` impact replaces `Placeholder.puff` on a blocked hit, lasting
0.25 seconds with a fallback if art is unavailable. Position, guard behavior,
damage and sound are unchanged; no new art was added. The agent reports isolated
`enemy_base` and four guard-enemy tests and lint passing. The lead reviewed the
effect with the player in the actual dark `cave_1_5`, with the Captain held
still for reproducibility. Human play and other effects remain open.

**Q7 locks and keys, 2026-10-27 (committed in `0801f43`):** Controlled arena
cases physically collect placed pickups and exercise real scoped locks, a boss
door and the Ninth Door. Wrong scope and sling are rejected; a matching C1 key
is consumed, the Lockpick is retained, and the Ninth Door rejects eight fragments
but opens with nine without consuming them. Player damage is active and there
are no enemies. The agent reports two isolated matrix runs and lint passing.
Other combinations, an actual world route, save/reload and human play remain open.

**Q7 raft passage and ravine, 2026-10-27 (committed in `8dbbaba`):** A real
World passage across `e167` from `cave_3_5` to `cave_3_6` follows the actual
moorings with the raft; the sling does not cross. In a separate real
`ravine_leap` arena case the boots cross and the sling does not. Fixtures grant
tools directly and remove roamers at the source; damage remains active. These
are not an earned playthrough. The agent reports two isolated matrix runs and
lint passing. Other pairs and edges, visual and human verification remain open.

**P08 seam presentation, 2026-10-27 (committed in `8dbbaba`):** At the real
seams in `ow_8_0` and `ow_11_7`, the Placeholder is hidden only when an
explicitly linked RoomDoor has usable painted art. Standalone fallbacks and real
seam art remain; collision, flags and timing are unchanged. The agent reports
real-room reveal/re-entry and `gated_room_doors` tests and lint passing, and
reviewed closed states. The lead reviewed open states in both actual rooms. No
new art was added; human play remains unverified.

**Q7 vegetation, rocks and gates, 2026-10-27 (committed in `a53fc9d`):**
Actual hook and pot cut five vegetation screens while sling and Cinder Wick do
not; a real pot opens brittle rocks while wrong tools are rejected. A ward plate
requires two blocked zero-damage test spores, and a two-brazier gate uses the
actual hook and Cinder Wick while rejecting the sling. These are controlled
arenas without enemies, with player damage active and a controlled projectile
fixture. The agent reports two isolated tests and lint passing. Other negative
combinations, room traversal and full gameplay or human verification remain open.

**Q3 Dirge Choir victory, 2026-10-27 (committed in `14b7836`):** The continuous
input route uses normal damage, two deliberate ordinary enemy deaths and
respawns in C6, farming, the Chime, both keys and Lockpick to open the boss door
and defeat Dirge Choir. It physically collects the fragment and core. The
agent reports five isolated victories, all four shards and lint passing. The
global seed is `20261027`, but Archivist's own randomization is uncontrolled.
The bot reads boss heads, timers, HP, projectiles, positions and flags, as well
as internal state in C4 and C5; later shards use fixtures and warps. The C5 and
C6 minibosses remain alive, and human play and other global seeds are unverified.
The physical reward walk now checks the C6 core flag is false and maximum
health 20 before pickup, then the flag is true and maximum health and health
are both 22 half-hearts afterward. `GameState.MAX_HEALTH_CAP` is 40 half-hearts;
the audit found no gameplay bug. The agent reports all four isolated shards, a
first-shard repeat and lint passing after this check.

**Wick Automaton jet, 2026-10-27 (committed in `bb7c6f8`):** A new native-alpha
painted jet replaces the active geometric placeholder, with a clear outline for
the unchanged 192×64 damage area and unchanged timing. The lead reviewed right
and up orientations in the actual room; the agent also reviewed the tell and
vent. The ordinary cutter and manifest are used, with previous entries unchanged;
the art agent updated provenance and `tools/source_art/wick-automaton-jet-z1-log.md`.
The agent reports isolated `wick_automaton` and `route_cave_9` tests, 22 art
tests and lint passing. Human play remains unverified.

**Q7 wall and raft cases, 2026-10-27 (committed in `81a240e`):** A real pitch
pot opens a cracked wall and its flag and collision are checked; a distant wall
and sling, Cinder Wick and flare attempts are rejected. A real raft requires a
mooring and crosses deep water with player damage active; the sling cannot be
used aboard. These are controlled arenas without enemies. The agent reports two
isolated `tool_matrix` runs and lint passing; an initial fixture lacked ammo and
was corrected. Other pairs, room transitions and visual or human verification
remain open.

**Tidewick phase-two warning, 2026-10-27 (committed in `faf9632`):** Existing
painted ripple art and presentation light replace the barely visible Placeholder
warning. Warning dimensions, timing, hit area, damage and gameplay are unchanged.
The agent reports isolated `boss_tidewick` and `route_cave_3` tests and lint
passing; the lead reviewed both orientations in dark-arena captures. Human
play remains unverified.

**Q7 gate cases, 2026-10-27 (committed in `faf9632`):** Actual player tools
exercise three seams opened by the Glow Jar, a hook-tap wall and a wax seal
opened by charged flare, with wrong tools rejected. The Tether Moth retrieves a
real key behind a grate; the Reel does not. The cases check flags, blockers and
revisit behavior in set-up arenas without enemies. The agent reports two
isolated tests and lint passing. Other gate/tool pairs, visual and human coverage
remain open.

**Q3 Archivist victory, 2026-10-27 (committed in `7332bc0`):** The continuous
input route defeats Archivist with normal damage, respawns after ordinary
deaths and physically collects the C5 fragment and core, reaching a maximum of
20 half-hearts. The agent reports six standalone victories, four isolated
shards and lint passing. The global seed is `20261027`, but the boss's own
randomization is uncontrolled. The bot identifies the real boss among copies
through internal state and reads boss phase, health, projectiles and light.
Later shards use fixtures and warps; the C5 miniboss remains alive. A complete
human playthrough and other global seeds remain unverified.

**Q7 selected encounter cases, 2026-10-27 (committed in `7332bc0`):**
`test_tool_matrix` now has at least one selected actual-tool case for each of
the 20 encounters, adding Mirror Warden, Dirge Choir, Archivist, Tidewick and
The Unlit. These use controlled arenas and positions: Mirror Warden's AI and
refresh are frozen, Dirge Choir's song/timing is forced, Archivist's phase is
reached by direct damage, and Tidewick uses a controlled raft position. Player
damage is disabled in four of the five new cases. The agent reports three
isolated `tool_matrix` runs and lint passing. This does not establish full
phase, tool, survival or human coverage; Q7 remains open.

**B10 wax wave, 2026-10-27 (committed in `6fc7bfb`):** The phase-two active
wave uses a painted band cut through the ordinary manifest and wrapped by a
shader, with inner and outer outlines. Damage, geometry and timing are unchanged.
The lead reviewed controlled radius-340 and radius-650 captures; the agent also
reviewed radius 50 and reports isolated boss and route tests, 22 art tests and
lint passing. The source and prompt are recorded in
`tools/source_art/unlit-wax-wave-z1-log.md` and `docs/art-provenance.md`.
The change and its tests were pushed to `origin/main` in
`6fc7bfba29725a5237512ef2d15fe5d879a1127e`. Human action review remains open.

**Q7 weakness extension, 2026-10-27 (committed in `ee9145a`):** Selected
actual-tool cases now cover 15 of 20 encounters, adding Lull Mauler, Gloam
Knight and Hushed Colossus using the hook, boots and mitts. These are controlled
fixtures: the Mauler's chunk is repositioned and its physics paused; player
damage is disabled for Gloam Knight and Colossus, whose movement and timers are
paused and shard fall initiated. The agent reports two isolated `tool_matrix`
runs and lint passing. These are not complete fights or human verification;
full Q7 coverage remains open.

**Q7 weakness extension, 2026-10-27 (committed in `14a2217`):** Three more
actual-tool cases cover selected weaknesses for Sump Lurker, Hollow Captain and
Lock Warden, bringing coverage to 12 of 20 encounters. The tests use isolated
arenas and repositioning; Sump Lurker uses controlled states with AI paused,
Lock Warden disables player damage, and Hollow Captain keeps damage active.
The agent reports two `tool_matrix` runs and lint passing. Full Q7 and visual
verification remain open.

**Q3 C5 Lockpick route, 2026-10-27 (committed in `14a2217`):** After C4, the
continuous input route uses normal damage, takes one deliberate ordinary death
and respawn, crosses two raft connections and earns keys, the Glow Jar and C5
Lockpick, with 2/18 half-hearts remaining. The C5 boss is not defeated. The
bot reads internal state; later shards use fixtures and warps. Other seeds and
human play are unverified. The agent reports all four isolated shards, a repeat
and lint passing.

**B10 chain lash, 2026-10-27 (committed in `14a2217`):** The active lash uses
new painted chain art with a separate warning outline; the damage area and
timing are unchanged. The lead reviewed controlled phase captures, and the
agent reports two focused isolated tests and lint passing.
The lead's first local test lacked the imported texture; after `make import`,
`boss_the_unlit` and `route_cave_10` both passed, as did `playthrough_1`.
The art is now in the main `tools/art_manifest.json` and generated
`assets/sprites/sprites.json`; the separate Z1 manifest was removed. The agent
reports unchanged previous sprite entries, a byte-identical PNG, 22 passing
art tests, both focused tests and lint. Source and provenance are recorded in
`tools/source_art/unlit-chain-lash-z1-log.md`. The later wax-wave work is
recorded above; these captures do not establish human combat readability.

**Q7 weakness extension, 2026-10-27 (committed in `791cbc7`):**
`test_tool_matrix` now covers selected weaknesses using actual tools for nine
of 20 encounters, adding Kilnkeeper, Choir Warden and Wick Automaton to the six
committed cases below. These use controlled arenas and repositioning: the
Kilnkeeper case disables player damage, the Automaton has movement speed zero,
and Choir Warden uses normal damage. The agent reports two isolated
`tool_matrix` runs and lint passing; a subsequent local `tool_matrix` run also
passed. The extension was pushed and verified on `origin/main` at
`791cbc77c8910656690b10313532d59c0bcb3ea7`. This is not full Q7 or visual verification.

**Checkpoint verification, 2026-10-27:** The lead ran `make check` with the
Q3 victory and Q8 probe present: 155 Godot test files, lint, world-data check
and 175 Python tests passed. The CI timing budget was not enabled, so this run
does not establish that the 50 ms budget is met.

**C10 action-state review, 2026-10-27:** Earlier isolated phase captures showed
the active wax wave and chain lash as simple, dark geometric effects. The later
chain-lash and wax-wave changes are recorded above.

**Q3 Colossus victory, 2026-10-27 (committed in `d5a0c06`):** The continuous
input route with seed `20261027` defeats Hushed Colossus with normal damage,
physically collects its fragment and core, and reaches 18/18 half-hearts. The
bot reads internal state including boss phase, timers and hazards; later shards
use fixtures and warps. The agent reports four isolated shards, a first-shard
repeat and lint passing. A complete game, human play and other seeds remain
unverified.

**Q8 transition probe, 2026-10-27 (committed in `d5a0c06`):** The test makes
300 actual input-driven slides around a four-room loop, starting 35 pixels from
each exit with damage disabled. A separate 300-warp sequence measures timing;
node counts and static memory were stable and orphans were freed. Across three
sequential runs the machine-dependent maxima ranged from 46.547 to 52.574 ms.
The 50 ms gate is an explicit environment-variable setting for calibrated CI,
not evidence that CI meets the budget. Cold-world loading, GPU, RSS and full
continuous walking are not covered. The agent reports 15 checks in each of
three runs and lint passing; Q8 remains open.

**Q7 and Q8 work, 2026-10-27:** Committed `test_tool_matrix` exercises
selected weaknesses with actual tools for six of the 20 encounters: Briar
Mother, Corrow's Echo, Thorn Warden, Abacus Brute, Pale Squire and Coinwyrm.
The agent reports isolated tests and lint passing. Coinwyrm's test disables the
player's hurtbox; these selected cases do not complete Q7 or provide visual
verification. The later Q8 probe and its limitations are recorded above.

**Q3 and Q6 extensions, 2026-10-27 (committed in `e8e4b4e`):** With seed `20261027`,
`test_playthrough_1` also burns the hermit hut thorns with the earned Cinder
Wick and collects its core. The continuous input route reaches 16/16 maximum
half-hearts and has 16/16 and nine pots after the first real C4 boss hit.
Enemies and damage remain normal; the bot reads internal state and uses no
warps. The agent reports four isolated shards, a repeat and lint passing.
Two separate, unintegrated normal-damage boss bots reduced the boss to 4 HP but
died. They do not establish a C4 victory or a full or human playthrough.

The Q6 economy test now exercises 100 stratified actual standard enemy deaths
and pickup effects in each of two configurations, before and after acquiring
the pot and sling. It overrides rolls and resets resources to measure potential
yields without caps; it is not a random sample, a real playthrough economy or
an assessment of balance over time. The agent reports three relevant isolated
test suites and lint passing. These Q3, Q6 and Q7 extensions, their tests and
documentation were pushed in `e8e4b4e6bce2eb5075e0e788a1fd5a1642ed427a` and
verified on `origin/main`.

**Q3 hidden-core route, 2026-10-27 (committed in `80792db`):** The fixed-seed continuous
input route uses the earned raft to collect the actual hidden core in
`cave_3_7`, reaches 14/14 maximum half-hearts after C3, and reaches C4 with
11/14 half-hearts and eight pots after the first boss hit. Enemies and damage
are normal; the bot reads internal state and uses no warps. The Q3 agent
reports four isolated shards, a repeat and lint passing; the owner also ran
`make test T=playthrough_1` successfully in the workspace. At that checkpoint
C4 victory was open; the later committed victory is recorded above. Human
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
The Q3 route followed in `80792dbe61db8817227160b47957d780692ae6a2`, and the
Q3, Q6 and Q7 extensions in `e8e4b4e6bce2eb5075e0e788a1fd5a1642ed427a`,
both verified on `origin/main`. The earlier full gate above applies to its
earlier candidate, not automatically to these later checkpoints.
At the earlier `e8e4b4e` checkpoint C4 victory was not yet demonstrated. The
later victory and Q8 probe were pushed in `d5a0c067825d8b594d7dbb2576153afef088fd2e`,
verified on `origin/main`. A complete game
has not been verified, and the removal or readability of every placeholder has not been
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

**Historical checkpoint, 2026-10-25 at 21:43 UTC:** The verified runtime then was `16df5d1902a1e8fb6108aa117aa971cccefe44a7`. This docs-only correction superseded the Cave 5 screenshot attribution in `bdca18681f97d8ff13c554bb5e8b9cbc0a0f14d3`; it identified the visible brown diamonds as missing `dry_vine_screen` art fallbacks in `cave_5_2`, not MirrorShade actors in `cave_5_5`. No runtime or art files changed in that correction. Later work mapped the vine art, as recorded above.

**Final checkpoint gate:** logs are in `/tmp/wickwarden-urgent-final-16df5d1-logs/`. `make check` passed 133/133 Godot suites, clean lint and world-data checks; Python generator/compiler tests passed 172. `rooms-check` passed 221/221, `art-test` passed 22/22, and global ownership passed for 92 work packages and 53 batches (192 rooms, 33 pockets). The isolated run used Dummy audio from the first import. The verifier reported no timeouts, SIGSEGV, engine/script/parse errors, leaks, skips, or waivers. The detached gate worktree was removed after testing. These results apply to `16df5d1902a1e8fb6108aa117aa971cccefe44a7`.

**Included fixes and reviews:** P09's low-fence grate is a permanent physical barrier: the real Tether Moth can fetch through it while the player is blocked; clone placement and missing-art fallback were verified in the actual World. `a7e0f1f` supplies the low-fence helper and `fd5e597` completes P09 runtime/tests. C09 thorn wall, eye cell, ninth fragment, portal, and hidden-seam reveal work are fixed (`909800b`, `aca1fb3`, `ce838b3`, `4c11205`). The sling-ammo HUD icon is in `23f4a1e`; Cinder Wick light is in `a2c6ee8`; Lock Warden plates are in `2c3d481`/`6ec36ff`; B06/B09 and heavy-door presentation are included. Abacus Brute and Pale Squire actor-only cues landed in `47db582`/`b3fcc83`: two focused suites and lint passed, and eight dark before/after captures are available; timings, radii and damage did not change.

M5 Mirror Shade alpha presentation is closed in `d28ec6d`/`c5f109b`: 71 shader proof images, all 12 frames checked against the flat-alpha requirement, and default production GPU rendering reviewed. The all-ten player guide and README link are in `d83944f`, with route correction `bb0821b` independently reviewed PASS at `/tmp/walkthrough-review.md`; later guide update `aaf7d65` records the cave Lockpick rule. The guide is a source-checked route, not a recorded full playthrough. The earlier Archivist SIGSEGV was fixed in `6753dcf`; multiple later global cohorts passed.

**Recent runtime and owner decisions:** decision 47 is implemented by `4fe3f33` and verified in cave route tests at `16df5d1`: each cave Lockpick passively opens every key-locked door in that cave, including the boss door, without consuming held small keys. Before pickup, ordinary locked doors still consume one same-cave small key. Other caves, overworld locks, and elemental/barrier puzzles are unchanged. Existing key retention is verified in C2 and C8. HUD fallback for the purple fragment now uses existing `fragment_c1` art (`fa37150`); its focused test coverage is 580.

**Historical regression report, 2026-10-25:** OW10_3 had a reachability/presentation regression from room build `26dd1`: the decorative hut at `(720, 816)` could not be reached from its south/front wall, and the functional shop door at `(1200, 288)` floated. The earlier route check followed an old portal. Reproduction is recorded at `/tmp/ow103-regression-repro.log`; the user's live save was not changed. OW10_7 was flagged for review. The later Cooling Pools and Pilgrim Road shop work and its route checks are recorded above. The iframe-breathing-space audit `f05c40` was read-only; the proposed 0.9-second interval was not implemented.

**Owner screenshot findings:** Screenshot 1, `/tmp/codex-clipboard-06b4f477-9ff0-4b22-8945-8209d5051da8.png`, is the Ninth Door in `ow_10_8` (The Ninth Door), actor `NinthDoor` / P11, graph gate `e255` to `cave_10_1`. The nine sockets are functional and reflect held C1–C9 fragments; this capture shows 1/9. The door opens on player contact once all nine are held, spends none, and persists `door_ninth`. The purple rectangular door body is the current `ninth_door` fallback placeholder because accepted sprite art for that kind is absent. This is a presentation backlog item, not a missing gate mechanic.

Screenshot 2, `/tmp/codex-clipboard-4d74bfa6-2eba-4996-96e0-fe34e8ebafaa.png`, is Counting Gate `ow_9_7`: actor `ResonanceDoor` (`resonance_stone.gd`), graph gate `e253` to C8 entrance `cave_8_1`. Equip the Lantern Chime, found in C6 Bell Room `cave_6_5`, and tap Use Item (keyboard E/K, controller X). The radial chime wave reaches 480 px over 0.5 seconds. A held press opens the warp picker at 1.2 seconds instead of ringing; release to ring. The resulting `resonated_e253` flag removes the blocker so the `RoomDoor` can be crossed. The Heft Mitts shown equipped in the capture do not open this door. The circular gold visual is the resonance-door art; the gate mechanic is implemented.

Screenshot 3, `/tmp/codex-clipboard-791a715c-b7d5-4006-937a-80f0189bb1ec.png`, maps to C5 Mirrored Archive, `cave_5_2` Hall of Faces (selected minimap cell local `(3,1)`). The two brown diamonds below Tamsin are the north-passage cut screens at room tiles `(9,1)` and `(10,1)`: `tools/rooms/cave_5_2.room` declares both as `opener cut_screen ... look=dry_vine_screen`, and the generated room instantiates `scenes/world/dry_vine_screen.tscn` (`Bush`, variant `dry_vine_screen`). This is the intended hook-cut barrier presentation. `dry_vine_screen` is absent from `tools/art_manifest.json` and `assets/sprites/sprites.json`; `SpriteVisual.attach` therefore uses the fallback registered by `Bush._register_looks`, which is a brown diamond. The art inventory still lists the `dry_vine_screen` sheet as `todo`. Track this as missing cut-screen art/mapping, not a MirrorShade actor or runtime-load discrepancy. `cave_5_2` does contain one separate MirrorShade farther into the room; it is not either visible diamond. The former `cave_5_5` / MirrorShade screenshot diagnosis is withdrawn.

The proposed 0.9-second enemy recovery interval remains unimplemented and is not an approved balance change. Gloam Knight art remains open; this screenshot review does not close that art work.

**Historical open work and preserved WIP, 2026-10-25:** B09 body/keyhole art was on HOLD; Gloam Knight, Coinwyrm, Ninth Lantern and B01 mouth art were open or on HOLD. Cue polish and QA remained open. Later art integrations and Q5 still reviews are recorded above; their active states and human approval remain open. The C1/C5 observation came from a read-only save; no user save was changed. The current Lockpick rule is implemented and route-tested.

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

The latest published checkpoint is `934309234dc498fa8e2d8507dc67bada2fa7ae08` on `origin/main`, including Kilnkeeper's wax splash above. Credits, title return and the other ending remain unverified in the continuous earned route; the user response on the ending-choice conflict remains pending. The Q3 `/tmp` guard and shared runner guard remain open. Preserve the staged paths and other dirty/untracked work. The guide and README link landed in `d83944f`, with route correction `bb0821b` independently reviewed PASS and owner-rule update `aaf7d65`; the guide does not itself prove Q3 completion. Q5 has recorded room-by-room still reviews, but action states and human visual approval remain open. Human balance and playthrough, Q6 soak/economy, complete Q7 phase/tool/survival coverage, Q8 performance/memory, and release/export acceptance remain open.

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
- Runtime presentation, fallback coverage, terrain and action-state readability still need review; individual art changes since the older checkpoint are recorded above. Human review is open. P09's low-fence grate fix and actual-World real Moth/player-block/clone/fallback checks passed in `fd5e597`.
- The Abacus Brute and Pale Squire actor-only cue pass is committed (`47db582`, `b3fcc83`); two focused suites and lint passed, and eight dark before/after captures await review. Broader cue cleanup remains open for Lull Mauler, Hushed Colossus, Dirge Choir, Wick Automaton, Corrow's Echo, Hollow Captain, Mirror Warden, Thorn Warden, The Unlit and shared markers.
- M5 Mirror Shade alpha rendering is closed in `d28ec6d`/`c5f109b`, including the default production GPU proof.
- The all-ten walkthrough and README link are committed in `d83944f`; route correction `bb0821b` passed independent review. This is a recommended guide, not a recorded full playthrough.
- The owner has not approved overall balance, visual feel, or a continuous full-game playthrough. Soak/economy, performance/memory, and release/export checks remain open.

## Next steps

1. Preserve the foreign staged index, the preserved lock file, and other agents' dirty and untracked work; verify the intended candidate and remote before a future push.
2. Extend the committed Q3 victory route into a complete earned-route playthrough; verify other seeds and human play.
3. Follow up Q5 still-review findings with action-state and human visual review. Complete Q6 soak/economy, Q7 weakness coverage, Q8 performance/memory, human balance, and Q9/Z release work.
4. Finish and verify remaining runtime presentation and placeholders; do not claim all art or the full game complete without evidence.
