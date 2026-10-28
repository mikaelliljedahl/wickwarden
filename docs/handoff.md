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
The isolated C9 phase-two survival attempts were documented in
`196d4a6b7c31c223f8e7e22ce88f437fb021bacb`, verified on `origin/main`.
The B04 quake art followed in `8a0b157375f650e6e5fb59c7a264bfbc2a87db9d`,
verified on `origin/main`.
The continuous earned-input Lock Warden victory followed in
`fc895af62dca947b7f2aa1d11d5f5010f6ea3a4d`, verified on `origin/main`.
The isolated C10 probe and ending-choice conflict were documented in
`79369cdcad32b78625b5dd30a520796a6b4dc58b`, verified on `origin/main`; the
user response on the choice remains pending.
The continuous earned route to C10 room 6 followed in
`9bfe631f1e07f623cf8156395f060ab2e37a360a`, verified on `origin/main`.
The test-runner import isolation followed in
`ca183c1d5b6cd52a4ba84669243b018793d003b6`, verified on `origin/main`.
The continuous C10 route to room 10 followed in
`0ca0ee673fe195e2ab3f4d7cedb44080b0cdc20f` on `origin/main`.
The C10 room-10 geometry fix, corrected hound regression and Q3 Reel-bank route
followed in `b5ba1124b771a0576228d105302eb20627753d53`, verified on `origin/main`.
The earned route to the C10 boss entrance followed in
`0d3ab887a9d915ae41a16ba5b088ef696d402a36`, verified on `origin/main`.
The Linux export preset followed in `fec1e9514b0dad0025602da7019d898eba1f1b79`,
verified on `origin/main`.
The rejected Fen Leech prototype and remaining limitation were documented in
`750e4f15f2912c7c3c5763b107c94b39a9209b8c`, verified on `origin/main`.
The B03/B09 immunity fixes and continuous earned route to the rekindle ending
scene followed in `59e339f01dcfc5158f4c5ffc607b8edea40b62d1`, verified on `origin/main`.
The `make playthrough` evidence followed in
`338e41fc9939b2b9d5ee1f3df4ea2f9832975e80`, verified on `origin/main`.
Both E1 ending-flow fixture checks were documented in
`b59388c4cb77e9297ead5b06f0536c56bdbe0963`, verified on `origin/main`.
The Cinder Wisp active attack presentation followed in
`7b25985f52a6ea08663734e487c77636b8444a69` on `origin/main`.
The Fen Leech warning presentation followed in
`ceb9c4b146ae40cdd69df1b3f2d3556dc3674d98` on `origin/main`.
The Sump Lurker water tells followed in
`772915a074161425debf0c182fed599660124037` on `origin/main`.
The Colossus attack presentation followed in
`e760223a0c4a46d1ee996200269cce43f65dbaad` on `origin/main`.
The title and Lull Mauler presentation followed in
`666d61d675893e4328e775eebc0e9228a37ab7d9` on `origin/main`.
The miniboss warning changes followed in
`80599b6061f66acc28b944cfb1387e20bfbcd731` on `origin/main`.
The Gloam Knight and Dirge Choir effects followed in
`553669501f7d9d0b309fa0b4b12d482108195aed` on `origin/main`.
The Snapper and Choirling warnings followed in
`19acc0541182b29cf42daa1db96e6ebbeefa8929` on `origin/main`.
The Cinder Wisp windup followed in
`0a1c45de95a93fc45dd585fbb5b6d8b92163250f` on `origin/main`.
The intro art and Thorn Warden projectile presentation followed in
`0b6f9ca46c990020dd87c48eb8f568b8de6e6ec8` on `origin/main`.
The Q7 real-tool extensions followed in
`58c58bc3312cc7d653a18b72a319b67ec9df5af6` on `origin/main`.
The Gloam Knight animation followed in
`cea4152e3cd0ca9074466184528f7e9cd48b4f4f` on `origin/main`.
The Unlit heart states followed in
`c31b391d690fc2002e949b832e2b8ff638d940a8` on `origin/main`.
The Q7 heavy-obstacle negative cases followed in
`26713bf764a958aca9ca4b57785488c3dae5a8ce` on `origin/main`.
The C10 lantern glow followed in `b41dc6d3c97c065bae20a1471db31d2cbd5135af`
on `origin/main`.
The Q7 hook-tap wall cases followed in
`a403f209af2ad1f3c6a3a7e24999bf3f8364476c` on `origin/main`.
The Q7 wax-seal cases followed in
`52cbdebd5e1a166e6dc790f7ee79f6bbb1a59436` on `origin/main`.
The Q7 gate revisit cases followed in
`0faeca54878a3750b5aed47427aa538fd8913f62` on `origin/main`.
The room census was recorded in `d003e28`; Q7 light/blast checks followed in
`304ce3707b6d5bb83196ae0280b5975ede2622db` on `origin/main`.
The route repeat and Q7 checks were documented in
`09ad1ecab32a656c26cb1fdc218bd7c8e6858af1` on `origin/main`.
The boss attack audit was recorded in `1a078b2`; the Coinwyrm presentation fix
followed in `3601e4b4102f3bd4634274e3c2532fd876bc2d18` on `origin/main`.
Coinwyrm documentation followed in `d5edd90` and the Tidewick ember bolt in
`bb87f5874b5028374e2444901fe1b2bd56114a12` on `origin/main`.
Tidewick and Q6/Q8 verification were documented in
`c780a05ffeddd47a3a2303c36266c38d0f208e46` on `origin/main`.
The Tidewick export check followed in `201b3f1`; the Q7 scoped grate-key tests
followed in `045900a1b11b4fdda8ee2e5162eea680b957e315` on `origin/main`.
The grate-check documentation followed in `0b531af`; Choir Warden's cone followed
in `f6b1dafd07391252aa562ab7f4a8113103917fd0` on `origin/main`.
The broad streaming survey followed in
`20acebe0d9769174b1cb115961c888fbd1324357` on `origin/main`.
After documentation `b8f75ef`, Gloam's slash followed in `df7de44` and
Coinwyrm's frontal bite in `501765e4a5928f07711744fa46b86ca1e0ac0404` on
`origin/main`.
After documentation `5e9b4c5` and `1b7d3cd`, lazy ending presentation landed in
`a65cec2` and Q7 Reel cases in `42b6327ec892043ce2addded8b279d085ed27b60` on
`origin/main`.
Kilnkeeper's wax splash followed in `934309234dc498fa8e2d8507dc67bada2fa7ae08`
on `origin/main`.
Its documentation followed in `4dfd5e6c6162f638d97fc323b9f2c0a163046a2a` on
`origin/main`.
Colossus falling shards landed in `7f7f245`, Gloam candidate review was recorded
in `2974f78`, and the clean check was documented in
`fc4395193c97bd43adf2f4e6538695d1f7ab6a51` on `origin/main`.
Shard and streaming investigation documentation followed in `77449fc`, and
Briar Mother spore lighting in `eeb017d6320c3c414b7ae356c96edddb3efe3162` on
`origin/main`.
Briar and streaming documentation followed in `d9f4315` and `2bdb566`; The
Unlit projectiles followed in `31dfc41c6aa2a93b1e180622b9d56a3ad83b05d9` on
`origin/main`.
Their documentation followed in `0a2726da39fa02c9864ca63224f9e24a7dd7635e` on
`origin/main`.
Q7 Brazier/Gate cases followed in `ad3f29d`; the active visual review was
documented in `135f2d0aac1d43a2d2f0682f8b444eb27627e2c0` on `origin/main`.
The route and Brazier checks were documented in `4c0a3cc`; Mirror Warden's
slash followed in `51b614e` and Q7 Echo tests in
`da5d9acdc7326046471495a4241f6082b4b42492` on `origin/main`.
Ending/miniboss and rejected Gloam documentation followed in `efd1ce9` and
`088498f`; Q7 Abacus guard testing landed in
`d2d9dc241cf102824ea1e1b82e55e1757d2000aa` on `origin/main`.
The Abacus and Captain review followed in
`0cd35a2ca57ad8acc0e3a3c1654b700ceaa2adcb` on `origin/main`.
Captain review documentation followed in `cfdb4a4` and `65e64ba`; Lull Mauler
active attacks followed in `86cbe7986a3359eca5811009cade0e62ee30e0c2` on
`origin/main`.
Mauler and test-isolation documentation followed in `8bd50f7` and `c0522b6`;
Sump Lurker's horizontal bite landed in `17de0e5e73a2b7fc2e040f9c982bd8e8f68de0cf`
on `origin/main`.
Sump documentation followed in `e024916`; the C10/playthrough guard landed in
`3e2eefde47d141e1cb5ad4926d47f868294bc42e` on `origin/main`.
Guard documentation followed in `ea605c1` and Choirling's active song in
`669633939d46c79dd81099a5297133b3d9909243` on `origin/main`.
Choirling documentation followed in `dfe0d78`; Watcher Eye beam presentation
is at `5d938dd1af1331c475d35f4a574288303dd786c2` on `origin/main`.
Beam documentation followed in `93ad466`; Watcher Eye warning is at
`0a2bffe11dd03b3dc782d361eb6d43344227d43a` on `origin/main`.
Warning documentation followed in `1221684`; integrated Z1 test isolation is
at `70d229d257737f0d8f302bdb54ee242448028006` on `origin/main`.
Z1 verification documentation followed in
`a82f678c6701fcd2aaad67b148f62cb76c273970` on `origin/main`.
Watcher Eye animation investigation was documented in
`534a812f20a5ba7e3598aee4040d3191be67342d` on `origin/main`.
The Brine Crab visual audit followed in
`a5fb2171f0f7c9c3fad556f25f21f736359c0ad9` on `origin/main`.
The rejected crab candidate was documented in `12a8ce1`; Fen Leech direction
landed in `b8c8a4c2856ec027eb2fd4b72149ad9fad4abc58` on `origin/main`.
Fen Leech and streaming results were documented in
`95c72ae88d7c10dcbbae3b8616609dcd3149a95b` on `origin/main`.
Clean-check documentation followed in `afc3c39`; Bramble Snapper's active bite
is at `1cd150cac9d2f22977096adc68d77affcc8b6529` on `origin/main`.
Bramble Snapper documentation followed in
`2c8c68ce755ab3e36d2daea0ecb500352843ff5b` on `origin/main`.
Clean-check documentation followed in `ed2f646`; Cinder Wisp windup is at
`d8935706723a1700a0ae49c625ee76a92453aabd` on `origin/main`.
Cinder Wisp windup was documented in
`d82b9553c612bd2575878ebee6416a7f4a2b27f9` on `origin/main`.
The Snapper prototype was documented in
`1858b014a2bba936e89271822f172078d974fa6f` on `origin/main`.
Snapper direction-candidate review followed in
`5c1751c0f6546da97fb566cccb2fb0e02760f5c7` on `origin/main`.
The Mirror Shade echo audit followed in
`424b845c4f1f450d1d7aaf6ab5561e6f964daa2b` on `origin/main`.
The Mirror Shade echo prototype was documented in
`9c935d3a857e9e0f828d6f92eb3498c3843c3d8d` on `origin/main`.
Mirror Shade effect studies were documented in `6e121b4`; Q7 Automaton jet
tests are at `6d72c5c6ce9eb946a9987c66a2e6bdbf62210708` on `origin/main`.
Automaton test documentation followed in `1a34e23`; Q7 Sump Lurker tests are at
`67f434051072ad1d3c50b91f35db49b407acfc32` on `origin/main`.
Sump test documentation followed in `b59d4a4`; the Q7 Dirge cycle is at
`d3c724fa4213ca1412b45bbc4582c1f19d7c21f4` on `origin/main`.
Dirge and Hound audit documentation followed in `5afe6e4`; Q7 Hollow Captain is
at `4b5f4ff32f54e6e3c47b0a159aad4646c44a6d67` on `origin/main`.
Captain testing and Hound art proof were documented in
`afdaead5a2b43da5b61a1cabb7df50618b07730b` on `origin/main`.
Clean-check documentation followed in `9125aaf`; Q7 Kilnkeeper phase two is at
`f257ebca8ec25f98ccf7b9a2bb6839317633ca84` on `origin/main`.
Kilnkeeper test documentation followed in `171fcf2`; Q7 Coinwyrm and Q6 drops
are at `403ec8b1b25ba0aaf23dfe768ec81a4efebb5311` on `origin/main`.
Coinwyrm and drop documentation followed in `ea58756`; Q6 room slides are at
`6c92d13f6e24140b5dcc1e63baf1a1d07ea33f66` on `origin/main`.
Room-slide documentation followed in `462b24b`; Q7 Briar Mother's eye cycle is
at `37ed92b87a223055147afad51645c25cfc48d860` on `origin/main`.
Briar eye documentation followed in `280b790`; Q7 repeated Unlit exposure is
landed in `0f6185c562d72db4caff5203b61b4b7837ed4046` on `origin/main`.
Unlit and streaming documentation followed in `8f05922`; the Q7 exposure cap is
landed in `e6ab2d3889383121a50aa5d9b3d55f61bf377e64` on `origin/main`.
Unlit cap and loader-failure documentation followed in `12f58f3`; Q7 Lock Warden
is at `1bbb94cc401f685848522ee616580ac0df1e6734` on `origin/main`.
Lock Warden test documentation followed in `f5cc279`; Lull Mauler reset landed
in `a8f06c7b700f559b4493e04105350dfeb9ea9545` on `origin/main`.
Reset audit documentation followed in `59ac8d3`; M0/MB1/B01 reset fixes landed
in `c8465bc14911bdf1de60a8fab47375b8fe905464` on `origin/main`.
Boss reset verification documentation followed in
`1895d08b819fa4d8dfcece735c96b33f72d276e7` on `origin/main`.
Choir Warden art review was documented in
`d2391e7401dc3704192675d523f7e6d6d9b288d6` on `origin/main`.
Streaming lifecycle review was documented in
`e279442b1188d252961ce2974e6e116c73d82926` on `origin/main`.
Choir Warden scale review followed in `0d15234`; B02's direct reset guard landed
in `2b9dc057f2fc417034bc5f840059f002179e5065` on `origin/main`.
Those 77 staged paths retain fingerprint
`cc7b8baf06d7e79c8d9ed63e5c68b4e971422c0795514e2e8381c9c1771cf4a3`.
An old empty `index.lock` from 16:21 without an active holder was moved to
`.git/index.lock.preserved-20261027` to sync the index; preserve that file.
Other tracked and untracked work may change concurrently; preserve it and
review the actual index, dependencies and remote before integration or push.

**Briar Mother direct reset guard, committed in `2b9dc05`:** Direct reset
during death is guarded so eyes do not revive; the test uses real sling eye
combat and a lethal hook hitbox, preserving two embers and living reset behavior.
Lead and agent targeted tests passed; the agent reports lint PASS. The static B02
gallery is not a death-sequence review. The latest clean full check remains
`c8465bc`; new MB3 source-art investigation is ongoing in scratch.

**Choir Warden MB3 scratch review, 2026-10-28:** Inhale/recover-only body art
shrinks versus walk: 230 px for walk and 177/178 px for action at 10% alpha.
A generated corrected note has a central direction but the same scale problem
and is barely visible in darkness. These prototypes are not integrated; review
used stills, a placed/protected player and enemy speed 0, not human play. Scratch
tests passed; capture reported four ObjectDB and two resource warnings. The
completed scratch scale study was not integrated: per-animation 1.3× scaling
conflicts with the shared-scale rule in binding `asset-contract.md` §5 and blurs
raster art. The foot coordinate is mathematically preserved but body proportions
change, the dark figure remains hard to see and the active pose's side stream is
wrong. Only controlled stills were reviewed, not full motion or human play;
correctly shared-scaled source art and a directional active pose remain needed.

**Choir Warden MB3 art review, 2026-10-28 (read-only):** Isolated `cave_6_4`
normal/dark stills in `/var/tmp/wick-mb3-review/{normal,dark}-{1,2,3}.png`
show the actual cone aimed downward, but `note_down`'s mouth stream points right
and is misleading; the singer is nearly invisible in darkness. The candidate
was rejected, with no implementation. These are stills, not verified animation.
The existing targeted test baseline passed.

**Boss and Captain reset fixes, committed in `c8465bc`:** M0 prevents
`player_died` from resetting defeated/dying bosses before override dispatch and
guards direct base-class reset; tests cover death progression, reward and Briar
Mother. MB1 restores Captain bash/contact damage immediately and guards death;
B01 guards Kilnkeeper direct reset and splits tests. All three targeted tests
passed. A clean full `make check` on exact `c8465bc` passed; log
`/var/tmp/wick-clean-c8465bc-z9f7ikmz/check.log`. This is the latest clean full
check. Earlier documentation commit `59ac8d3` was also pushed.

Direct subclass reset during death can still mutate subclass state in other
overrides; no production use was found except Tidewick init. Thorn Warden hazard
remains active until `queue_free`, but damage has not been demonstrated; this
remains open.

**Read-only reset audit, 2026-10-28:** Hollow Captain reset failure and defeated
bosses reviving during death throes were reproduced. Subsequent M0, MB1 and B01
fixes and their remaining limits are recorded above.

**Lull Mauler reset, committed in `a8f06c7`:** Reset closes active slam/sweep
hitboxes and resets the attack cycle; regression tests cover reset, stun and
death. `make test T=lull_mauler` passed. A clean full `make check` on exact
`a8f06c7` passed; log `/var/tmp/wick-clean-a8f06c7-j71imz6t/check.log`. This is
followed by the clean `c8465bc` check above. A sweep art prototype was rejected
because it misrepresents the hit area or is obscured; the geometric placeholder
remains.

**Q7 Lock Warden keyhole, committed in `1bbb94c`:** Natural B09 gallery
progression breaks four plates with real sling and pot, reaching phase two at
24 HP. A real slug overlaps the closed keyhole without accepted damage; a second
shot after natural opening deals one damage (HP 23). Agent and lead passed
`tool_matrix`; the agent reports 2,083 checks and lint PASS. The player is placed
and protected; this gallery is not the actual room or human play. Other tools,
closing and death remain open.

**Clean full check at `12f58f3`, 2026-10-28:** A clean exact `12f58f3` run
passed `make check`; log `/var/tmp/wick-clean-12f58f3-n8hf8asx/check.log`.
This preceded the Lock Warden test; the later clean `a8f06c7` check is above.

**Q7 Unlit exposure damage cap, committed in `e6ab2d3`:** In the real-tool B10
fixture, four hook hits during the first Reel exposure deal eight damage; a
fifth actual contact after normal i-frames does none. Natural reshield protects,
and a second real Reel exposure resets the cap and permits two more damage
(24→16→14). Agent and lead passed `tool_matrix`; the agent reports 2,058 checks
and lint PASS. The player is placed and protected; this is not World or human
play. Flare, pot, death and ending are not covered, and the later clean full check at
`12f58f3` is recorded above.

**Q7 Unlit repeated heart exposure, committed in `0f6185c`:** Existing real
sling/Wick play reaches phase three; two real Reel lantern contacts and hook
hits before, during, after and during the second exposure give
`exposed=[false,true,false,true]`, `damage=[2,2]`, HP 24→22→22→20, without
forced phases or timers. Agent and lead passed `tool_matrix`; the agent reports
2,041 checks and lint PASS. This is B10 gallery with a manually placed, protected
player, not actual World or human play. Ceiling, death, ending and broad phase
coverage remain open. The later clean full check is `12f58f3`.

**Q7 Briar Mother eye cycle, committed in `37ed92b`:** A real sling shot
physically overlaps the protected third eye without damage; the same eye lowers
naturally and another real sling hit deals one damage to the eye (4→3) and boss
(28→27), consuming two slugs. Agent and lead passed `tool_matrix`; the agent
reports 2,028 checks and lint PASS. This is a bare controlled arena with a
placed, protected player, covering one eye in phase one, not human play, actual
World or the full fight. The later clean full check is `12f58f3`.

**Q6 enemy room slides, committed in `6c92d13`:** Real World input traverses
`ow_0_0↔ow_1_0` and back. Two Spitcaps and three Skitterwicks pause and remain
still during slides; outgoing enemies are freed, revisiting recreates them,
destination enemies resume and their centres stay in the room. At least one
Skitterwick moves within 1.5 simulated seconds; the initial 0.5-second window was
insufficient because of natural initial rest. The agent reports three runs PASS
and the lead passed `soak_brackwater`. This is one route with position sampling
and a placed, protected player, not human or full-body coverage. The latest
clean full check remains `afdaead`.

**Q7 Coinwyrm and Q6 gated drops, committed in `403ec8b`:** In the actual B08
gallery, natural phase-one rear has three plates: real hook does no damage,
three real Reel hits and natural returns remove the plates and yield 15 bits,
then hook deals two damage to the open head (36→34). The player is controlled
and protected; this covers only phase-one rear, not the real cave or human play.

Q6 independently sampled 100 stratified actual enemy deaths/pickups per mode:
pot-only yielded 10/0, sling-only 0/8, with potential 40/48 respectively;
2,900 checks. This is not natural randomness or an economy playthrough. Agent
tests and the lead's `tool_matrix` and `economy_budget` passed, as did lint. The
later clean full check is `12f58f3`.

**Q7 Kilnkeeper phase two, committed in `f257ebc`:** Six real Cinder Wick fire
contacts reduce the boss from 24 to 12 HP and trigger natural phase two. Hook is
blocked by hard armour; four further real Wick hits melt it, and hook hits for
4→2 HP. Agent and lead passed `tool_matrix`; the agent reports 2,002 checks and
lint PASS. The arena is controlled, the player placed and protected and boss
`move_speed=0`; this is not human play in a real room. Later death phase and
other combinations remain open. The latest full check is the earlier clean
`afdaead` run below.

**Clean full check at `afdaead`, 2026-10-28:** A clean git archive of exact
`afdaead5a2b43da5b61a1cabb7df50618b07730b`, with isolated HOME/XDG and
`TMPDIR=/var/tmp`, passed `make check`, including the newer Q7 tests. Log:
`/var/tmp/wick-clean-afdaead-kxq8q92_/check.log`. The later clean full check at `12f58f3` is recorded above; human, art,
coverage and performance limits remain open.

**Q7 Hollow Captain recovery, committed in `4b5f4ff`:** Real patrol, telegraph,
bash and recovery run in a controlled arena. A real sling shot is blocked from
the front during patrol and hits for one damage during recovery (12→11); ammo is
consumed. Agent and lead passed `tool_matrix`; the agent reports 1,982 checks and
lint PASS. The player is manually placed and protected; this is not a real room
or human play, and other directions/tools remain open.

**Husk Hound art proof:** `/var/tmp/wick-hound-art-proof/` shows source crouch
220 px, charge 280/279 px and dizzy 240/224 px at a common scale, exceeding the
binding 192² cell. A diagnostic 320 px cell is not approved; vertical poses are
missing. Nothing is integrated or human-tested.

**Husk Hound World audit, 2026-10-28:** State-confirmed natural warning
squash/walk, charge and wall-dizzy show `walk_side` in
`/var/tmp/wick-m2-hound/`. The v1 crouch/charge/dizzy source art remains uncut;
art pipeline, direction and anchoring are unresolved. The player was arranged
and protected; the review was horizontal in a light room, not human play. One
process reported four ObjectDB and two resource warnings. No runtime change.

**Q7 Dirge Choir natural Chime cycle, committed in `d3c724f`:** After natural
intro and bass song, a real hook is rejected while protected; real Chime
interrupts and opens the head, and real hook deals damage (12→10). During a
natural second song within three-second deafness, Chime makes contact but does
not open or interrupt. Agent and lead passed `tool_matrix`; the agent reports
1,962 checks and lint PASS. Only bass phase one is covered in a controlled arena
with a placed, protected player, not human play or a real room. The later clean
full check at `afdaead` is recorded above.

**Q7 Sump Lurker natural weakness, committed in `67f4340`:** With normal physics
in a controlled `shallow_zone` arena, real Moth physically overlaps the submerged
hurtbox without an accepted hit or damage. Following natural warning, surfacing
and active bite, real Tether Moth stuns for 1.5 seconds and hook deals two damage
(16→14). Agent and lead passed `tool_matrix`; the agent reports 1,939 checks and
lint PASS. The player is manually placed and protected; this is not a real room
or human play, and other phase/tool cases remain open.

**Clean full check at `1a34e23`, 2026-10-28:** A clean archive of exact
`1a34e23` with isolated HOME/XDG and `TMPDIR=/var/tmp` passed `make check`.
Log: `/var/tmp/wick-clean-1a34e23-uk_zij8_/check.log`. This preceded the Sump
test commit; the later clean full check at `afdaead` is recorded above.

**Q7 Wick Automaton jet, committed in `6d72c5c`:** In a controlled arena with
the actual natural warning and active jet, a real Chime hit has no effect; a
real Tether Moth hit then stuns for 1.5 seconds and opens the vent. A delayed
real pitch pot hits the vent for four damage (30→26), and the jet does not
resume. Agent and lead passed `tool_matrix`; the agent reports 1,916 verbose
checks and lint PASS. The player is protected and miniboss movement set to zero;
this is not a real room or human play. Other phase/tool combinations remain open;
the later clean full check at `1a34e23` is recorded above.

**Mirror Shade scratch cue and cutter studies, 2026-10-28:** In
`/var/tmp/wick-m5-sweep-review/`, an active cue was tried in four directions with
Glow Jar and decoy; stun/death/timeout lifecycle tests passed and eight World
images were captured. The vertical cue looks detached, can imply reach and
overlaps other visuals; no human play was verified.

`/var/tmp/wick-mirror-pipeline-hs5POG/` tested a native-alpha cutter/output:
import and 22 `art-test` tests passed, and other sprites were byte-identical.
256² is only a proposal; provenance and ownership remain open. The source
candidate is
`/home/mikael/.codex/generated_images/01a17dc5-6801-7be1-b963-170ed1dc4e82/exec-ac92106a-fc5d-4e32-b312-279c4fc406f8.png`.
Neither study is integrated and no normative change has been made.

**Mirror Shade scratch pipeline, 2026-10-28:** In
`/var/tmp/wick-shade-echo-M0pvQ5/`, side poses cut into a 192 px cell but the
strike pose is too dark in `cave_5_1`; three frames at 8 fps cannot fit within
the 0.12-second echo. Up/down sprites are missing. A few static samples used
natural AI, Glow Jar and a decoy; a targeted test passed but did not verify full
presentation or interruption. Nothing is integrated; a separate readable cue is
under investigation.

**Mirror Shade World audit, 2026-10-28:** Actual `cave_5_1` with natural AI,
a placed, protected player, real Glow Jar and player hook produced
`/var/tmp/wick-m5-shade/unlit.png`, `revealed.png` and `echo.png` in that
directory. State confirms an active echo for 0.12 seconds, but no strike effect
is visible; two shadows and overlap limit the observation. Painted source poses
exist uncut and pipeline work is in progress. No runtime change or human play.

**Rejected Snapper up candidate, 2026-10-28:** The ImageGen candidate
`/home/mikael/.codex/generated_images/01a17dc5-6801-7be1-b963-170ed1dc4e82/exec-a0629151-d909-4eec-be52-46417083e334.png`
and scratch proof `/var/tmp/wick-snap-up-JUXI3p/` show a visually correct up
direction, but a common scale gives 262×243 and 261×268 against the 192 px cell.
Silhouette and scale mismatch; in World the art is too large and obscures the
player. It was rejected and not integrated. Only stills were reviewed, not
animation or human play; new compact matching art is needed.

A further ImageGen candidate,
`/home/mikael/.codex/generated_images/01a17dc5-6801-7be1-b963-170ed1dc4e82/exec-a0ea4437-1783-4a13-976b-8b61387a7fb2.png`,
was judged by the lead to face right despite the requested upward direction. It
was rejected without cutting, World testing or integration.

**Bramble Snapper scratch prototype, 2026-10-28:** Painted v3 telegraph/snap
proofs in `/var/tmp/wick-snap-proof-wjEx9p/` and an isolated World prototype in
`/var/tmp/wick-snap-world-yZxIXj/` use 192² cells and byte-identical idle. Real
AI was exercised right/up, with idle/fire and active hitbox; targeted test and
lint passed. Jaws are clearer in the warning but the sector obscures them; the
bite is barely clearer, and when facing up the source art points right. Nothing
is integrated; visual animation and human approval remain open, as does
directional art.

**Cinder Wisp windup, committed in `d893570`:** Its registered `swell` animation
now plays during the 0.5-second warning; previously the animation stayed idle
while warning and ring were visible. Stun restores idle and `auto_motion`;
mechanics are unchanged. Targeted `cinder_wisp`, `husk_hound`, lint and M2
ownership passed. Actual World `ow_8_0` captures
`/var/tmp/wick-m2-wisp/windup-before.png` and `windup-after.png` in that directory
used natural AI and a placed, protected player. These are two stills in a light
room with a subtle difference, not human play or animation verification. The
before capture had six ObjectDB and three resource warnings; the after capture
had none. The latest full check is the earlier `2c8c68c` run below.

**Clean full check at `2c8c68c`, 2026-10-28:** A clean git archive of exact
`2c8c68ce755ab3e36d2daea0ecb500352843ff5b`, with isolated HOME/XDG and
`TMPDIR=/var/tmp`, passed `make check`. Log:
`/var/tmp/wick-clean-2c8c68c-h973z694/check.log`. The later clean full check at
`1a34e23` is recorded above; human play, art and performance remain open.

**Bramble Snapper active bite, committed in `1cd150c`:** The previously
invisible active bite retains the existing painted `thorn_hedge` warning for
0.15 seconds, with an orange sector boundary and unshaded rendering; timing,
damage and hitbox are unchanged. `bramble_snapper`, `wickling`, lint and M1
ownership passed. State-confirmed actual World images in `ow_6_1`,
`/var/tmp/wick-m1-snap/snap-before.png` and `snap-after.png` in that directory,
used ticking AI and a placed, protected player. Only upward direction in a light
room was reviewed, not human play. The reused warning and geometric outline are
provisional; dedicated animated jaws remain missing. The later clean full check
at `2c8c68c` is recorded above.

**Clean full check at `95c72ae`, 2026-10-28:** A clean git archive of exact
`95c72ae88d7c10dcbbae3b8616609dcd3149a95b` in
`/var/tmp/wick-clean-95c72ae-c_oztizi/` with isolated HOME/XDG and
`TMPDIR=/var/tmp` passed `make check` (exit 0), including Fen Leech. The log is
`/var/tmp/wick-clean-95c72ae-c_oztizi/check.log`. The later clean full check at
`2c8c68c` is recorded above; human play and other coverage limitations remain open.

**Fen Leech lunge direction, committed in `b8c8a4c`:** A leftward lunge that
previously appeared rightward is now mirrored, with the warning bubble at the
correct head. Its own logic state controls direction without reading Visual;
vertical motion retains the last side. Damage, timing and collision are
unchanged. The agent reports `fen_leech`, lint and M3 ownership PASS. Actual
World captures `/var/tmp/wick-fen-m3/left-before.png` and
`left-direction-memory.png` in that directory used a placed, protected player
and naturally ticking AI. The before capture had four ObjectDB and two resource
warnings; the after capture had none. Dedicated painted vertical and diagonal
poses and human play remain open.

**Rejected Brine Crab ImageGen candidate, 2026-10-28:** Independent proof in
`/var/tmp/wick-crab-candidate-aCvf0g/` found idle 198 px and lunge 220 px wide
against the binding 192 px cell, warning edge clipping and 17 px displacement,
and body mismatch. The candidate
`/home/mikael/.codex/generated_images/01a17dc5-6801-7be1-b963-170ed1dc4e82/exec-0ed57e65-d182-48d2-a79e-bfa5ac5ac171.png`
was rejected, not integrated or verified as animation; up/down art remains absent.

**Brine Crab action-art review, 2026-10-28:** State-confirmed actual World
captures `/var/tmp/wick-m3-survey/warning.png` and `lunge.png` in that directory
show scaled idle with the same low claw. Scratch proofs in
`/var/tmp/wick-brine-proof-QAneZP/` show the existing lunge at 250–257 px, too
wide for the binding 192 px cell; the warning is shifted 16 px and has alpha
pixels at the edge. Body/walk also mismatch, and vertical source art is missing.
There is no safe integration of these sources; new compact fitting art is needed.
No runtime change was made.

**Watcher Eye open-state review, 2026-10-28:** The open state looks closed in
actual AI gameplay at `ow_5_6` (`/var/tmp/wick-regular-audit/eye-open-overworld.png`).
Down/side cutting proofs in `/var/tmp/wick-watcher-proof-HkQk0n/` are promising,
but the animation has not been reviewed during play and an up-facing source is
missing. A new ImageGen candidate at
`/home/mikael/.codex/generated_images/01a17dc5-6801-7be1-b963-170ed1dc4e82/exec-65898650-1ca0-4938-8be0-a2cc6a492966.png`
was independently rejected: its gaze is frontal, not upward. It is not used.

**Integrated Z1 test isolation and clean check, 2026-10-28 (committed in
`70d229d`):** A clean git archive of exact
`70d229d257737f0d8f302bdb54ee242448028006` at
`/var/tmp/wick-clean-70d229d-afalxh3d/` passed `make check` (exit 0): 158
Godot files, lint, world-check and 175 Python tests. Eleven root unit tests ran
separately and passed (`root-tests.log`); they are not part of `make check`.
A later clean full check at `95c72ae` is recorded above.

Agent evidence includes 12 negative separate Godot processes and positive
save/load probes at `/var/tmp/wick-profile-audit-Qx20RO/`, plus a real `/tmp`
EDQUOT fallback to `/var/tmp` before execution. Independent final review passed
the earlier error-masking concern; after a run starts, failures are not retried.
Limits: Linux scope; direct Godot can log before the guard; separate Makefile
import needs isolated HOME/XDG; parallel imports into the same `.godot` are not
protected; opt-in captures are unchanged. Human play and complete placeholder
coverage remain open.

**Watcher Eye warning, committed in `0a2bffe`:** The existing eye image is
unshaded for the 0.5-second warning; its material is restored on firing or stun,
with combat values unchanged. Targeted `watcher_eye`, lint and ownership passed.
Before/after captures `/var/tmp/wick-regular-audit/eye-warning-before.png` and
`eye-warning-after.png` in that directory show `cave_10_12` with a placed player
and ticking AI; the fired capture reported four ObjectDB and two resource
warnings. The whole stone frame lights up while the lid is closed; separate iris
and animation remain open. Human play and a direction matrix are not verified.

**Watcher Eye beam, committed in `5d938dd`:** The existing painted beam is
visible outside the lamp field using unshaded rendering; mechanics are unchanged.
In actual `cave_10_12`, the agent captured
`/var/tmp/wick-regular-audit/eye-before-130.png` and `eye-after-130.png` in that
directory with a placed player and ticking AI. The agent reports `watcher_eye`,
`choirling`, lint and ownership PASS. Only downward direction was verified; the
warning was difficult to see at that checkpoint; the later warning change is
recorded above. The broader enemy inventory remains open.
This is not human play.

**Choirling active song, committed in `6696339`:** Its previously invisible
0.5-second active song now uses existing painted `treble_note` images and a cone
outline, with damage, timing and hitbox unchanged. The lead passed `choirling`;
the agent reports M4 ownership and lint PASS. Actual `cave_6_8` captures
`/var/tmp/wick-regular-audit/choirling-song-after.png` and `warning.png` in that
directory used ticking AI and a placed player, not human play. Capture exit
reported four ObjectDB and two resource warnings. Dedicated animated song art
and a full regular-enemy audit remain open.

**C10 and playthrough save guard, committed in `3e2eefd`:** C10 and
Playthrough4 stop before disk steps when the runner profile is not isolated,
and disable `SaveGame.enabled` in that case. The guard examines the XDG prefix, simplified
paths and userdata, including slot/temp/bad symlinks; normal SaveGame behavior
is unchanged. A positive `/tmp-wickwarden-check` guard probe without saving
passed; negative XDG/slot-symlink and invalid-profile route/playthrough probes
passed with the sentinel untouched (Godot logs are separate). Isolated probes:
`/var/tmp/wick-c10-guard-I7WFim`. The agent reports lint and diff-check PASS.
Full positive save/load and suite verification was not run because of `/tmp`
quota. This does not protect against a deliberate same-UID race; the `/var/tmp`
runner contract and other tests remain open.

**Sump Lurker bite, committed in `17de0e5`:** The existing three painted bite
frames play within ±15° of horizontal, mirrored left; vertical and diagonal
directions retain idle and need directional art. The 0.12-second hitbox, damage
and timing are unchanged; idle speed is restored on stun, reset, phase change
and death. The lead passed `sump_lurker`, `area_cave_3` and `route_cave_3`; the
agent reports lint and MB2 ownership PASS. Natural C3 capture
`/var/tmp/wick-sump-bite/bite.png` used a placed, protected player, not human play.

**Test-root guard investigation, 2026-10-28:** Hardcoded `/tmp` prefixes, the
runner's temporary-directory fallback to `/var/tmp` and Gravelight's hardcoded
scratch path obstruct safe test execution when the `/tmp` quota is exhausted.
Z1 is working across the named runner, base, Q3 and route-test files toward an
explicit, unique, verified isolated test root, fail-closed behavior and actual
userdata checks. After discovering autosave and ending branches, Z1 also covers
SaveGame and the direct test runner, using an explicitly scoped ownership list.
The later integrated Z1 result and remaining limits are recorded above.

**Lull Mauler active attacks, committed in `86cbe79`:** The previously
invisible slam uses an existing painted crack and 110 px outline; sweep uses a
procedural glint and 180°/140 px boundary, shown only while the hitbox is active.
Mechanics are unchanged. Lead and agent passed `lull_mauler` and `route_cave_4`;
the agent reports lint and MB2 ownership PASS. Actual World captures
`/var/tmp/wick-mini-next/slam.png` and `sweep.png` in that directory used a
placed, protected player, not human play. A dedicated painted sweep and attack
pose remain open.

**Clean `cfdb4a4` check attempt:** `make check` failed 13 of 157 Godot files
when `/tmp` hit disk quota and tempfile fallback violated isolation; 144 passed.
Separate lint, world-check, 175 Python tests, rooms-check (221 rooms) and
art-test (22 tests) passed. Logs are in `/var/tmp/wick-cfdb4a4-gOuM0c/`. The
latest complete clean full check at that time was `4dfd5e6`; the later `70d229d`
check is recorded above.

**Hollow Captain image attempts, 2026-10-28:** Four new ImageGen candidates in
`/var/tmp/wick-captain-new/` were rejected for scale, pose/direction/overlap or
cell placement/size (`-8`, 174×277). No sprites were installed; art and human
play remain open.

**Q8 C10 load profiling at clean `d2d9dc2`, 2026-10-28:** Headless processes
with warm OS cache measured cold `the_unlit.gd` load at 28.35–29.16 ms,
boss-room scene load at 31.30–33.27 ms, instantiation at 0.076–0.121 ms and
`add_child` at 6.32–6.53 ms during 11→12. Instrumentation and dependencies are
not exclusive, so timings cannot be summed. Avoiding a redundant placeholder
saved only 8–13 microseconds; switch differences were within noise and the
experiment changed Reelable semantics, so it was not integrated. Logs are in
`/var/tmp/wick-q8-c10-d2d9dc2/`. Calibrated CI, GPU and human play are not
covered; Q8 remains open.

**Hollow Captain source review, 2026-10-28:** Provenance matched for
`actions_side_v2` and `actions_down_v3`, but default source segmentation misses
poses. A temporary component method yields figures 142–191 px versus idle
206/231 px at the same scale, and down bash changes direction. The action images
were rejected and not installed. Proofs are in
`/var/tmp/wick-captain-cut/proofs/`; image attempts based on accepted idle are
in progress. Art and human-play verification remain open.

**Abacus attack art review, 2026-10-28:** Existing B60 sources have the chain
baked into the body, while Unlit links are the wrong type. Two new transparent
ImageGen candidates were tested in scratch and actual C8 with a placed,
protected player and frozen attack: a closed ring looked like a floating
necklace; an open radial chain crossed the body/face and lacked attachment in
some directions. Captures: `/var/tmp/wick-abacus-art/arena.png` and
`/var/tmp/wick-abacus-art/contact.png`. Both were rejected and neither was
registered; the painted attack remains open, and this was not human play.

**Q7 Abacus guard, committed in `d2d9dc2`:** A real frontal hook is
guard-blocked; the hook during charge misses, then a real flare hits and breaks
the rail from 4 to 0 without body damage (28 HP). A subsequent hook reduces
body HP to 26; no Reel is used. Enemy AI ticks, but the player is arranged and
protected: this is not human play, a full fight or a complete matrix. The lead
passed `tool_matrix`; the agent reports lint PASS. No visual capture was made
for this test.

**Hollow Captain QA:** `/var/tmp/wick-captain-qa/natural-bash.mp4` and
`contact.png` in the same directory show idle/walk during bash. Existing uncut
side/down actions need the art pipeline; human play remains untested.

**Continuous Wickwarden ending at clean `4c0a3cc`, 2026-10-28:** In a clean
archive of `4c0a3cca400a0b42ab6ab08a2b1757537d856a3b`, a fresh-state C1–C10
bot route with normal enemy AI and damage had eight normal deaths/respawns and
won the final boss at 10/28 half-hearts. The scratch wrapper selected the physical
right pedestal. Run 3 passed 1,542 checks through the real Wickwarden
`ending.tscn`, credits, title and Continue: state was reset before confirmation,
and actual World reloaded completed/Wickwarden flags, health and checkpoint
`ow_10_8` from isolated persistent save JSON. Log:
`/var/tmp/wick-ending-4c0a3cc-rXeJyO/run3.log`. Run 1 passed with a save
warning; run 2 failed due to `/tmp` quota; run 3 used a clean `/var/tmp` profile.
This is the other ending on this particular bot route, not human or broad-seed
coverage: the bot reads internal state, farms, deliberately dies and uses a fixed
seed.

**Mirror Warden and Echo checks, committed in `51b614e` and `da5d9ac`:** Mirror
Warden's previously invisible active slash now has a light-independent procedural
glint and outline; damage, timing and area are unchanged. Dedicated painted
slash art is still missing. The actual World image
`/var/tmp/wick-mini-inventory/cave_5_4.png` used a placed, protected player,
not human play. The agent reports `mirror_warden`, `route_cave_5` and lint PASS;
the lead passed `mirror_warden`, but `route_cave_5` failed its isolated user-data
safety guard because of `/tmp` quota, not as a normal-save-environment result.

Q7 tests real Chime contact during Echo's natural GLOW, causing two seconds of
stun and permitting hook; separately, actual contact during natural TELL caused
no stun or damage and natural FLARE followed. The lead passed `tool_matrix`;
the agent reports lint PASS. The player was placed and protected; there was no
visual capture, human test or complete matrix. Hollow Captain's bash and Abacus
Brute's whirl still lack dedicated painted animations.

**Three fresh-state route runs at clean `0a2726d`, 2026-10-28:** Three retries
passed 1,529 checks on the continuous route from new in-memory state, with
normal damage and enemy AI, reaching real `ending.tscn` with rekindle/completed.
Each had eight normal deaths: C5 twice, C6 twice, C7 once, C9 once and C10
twice including the final boss; the final boss retry began at 16/28 and won at
10/28 half-hearts. The bot reads internal state, farms and deliberately dies for
respawns; the global seed is fixed while some boss RNG is independent. This is
not human balance, broad randomness or both endings coverage.

The first three attempts also reached the ending but failed in scratch-wrapper
cleanup; after that wrapper was fixed, all three retries passed. Logs are
`/var/tmp/wick-route-0a2726d-oE3gzZ/retry{1,2,3}.log`. This route evidence is
separate from the clean full `make check` at `4dfd5e6` below.

**Q7 Brazier and Gate, committed in `ad3f29d`:** In a controlled fixture with
real Brazier and Gate, Cinder Wick is positive and Tallow Sling negative with
actual contact. Flags, gate collision and revisit through in-memory GameState
are checked. The lead passed `tool_matrix`; the agent reports lint PASS. There
was no actual room transition, disk save, human play or complete matrix coverage;
no visual capture was made because `xvfb-run` was missing in the agent environment.
The earlier active visual review below was documented in `135f2d0`.

**Read-only action image survey at `0a2726d`, 2026-10-28:** Actual World with
ticking attacks and a placed, protected player showed painted effects and
outlines in `/var/tmp/wick-action-survey/`: C2 natural seed burst
(`c2-seed.png`) and natural sweep in forced phase two (`c2-sweep.png`); C10
natural phase-one hand (`c10-hand.png`), forced phase-two wave (`c10-wave.png`),
and phase-three lash and pulse (`c10-lash.png`, `c10-pulse.png`) with manual
exposure. Remaining eyes in forced C10 phases are a fixture artifact. C2 seed
capture reported six ObjectDB and three resource warnings; the other captures
were not logged. This is not complete state, transition, Reel or human coverage.

Two further standalone Gloam slash ImageGen attempts were rejected: a chevron
or semicircle had incorrect reach, and green key artifacts appeared. Neither is
integrated; no runtime change resulted and dedicated slash art remains open.

**The Unlit projectiles, committed in `31dfc41`:** Gaze and phase three torrent
use distinct painted fly and impact art, correctly oriented including homing,
with presentation light and a spore fallback if art is missing. Damage, speed,
ward and collision values are preserved; impacts are created on hit, wall or
ward and hazards clear at phase change or reset. The lead passed import,
`boss_the_unlit`, `route_cave_10`, `anchor_drop` and `tool_matrix`; the agent
reports lint, B10 ownership and `art-test` PASS.

C10 captures in `/var/tmp/wick-b10-bolts/` show natural gaze in
`gaze-natural.png`, forced phase three with remaining eyes as a fixture artifact
in `torrent-phase3.png`, and manual wall destruction in `impact-arranged.png`.
The player was placed and protected; this is not human play. Capture exit reported
four ObjectDB and two resource warnings. The latest clean full check was at
`4dfd5e6`, before these changes.

**Briar Mother spores, committed in `eeb017d`:** Natural spores have
presentation lighting, not gameplay glow; damage, speed and timing are unchanged.
The lead passed `boss_briar_mother` and `route_cave_2`; the agent reports import,
lint and B02 ownership PASS. Actual arena capture
`/var/tmp/wick-states-next/cave_2_9.png` used a placed, protected player, not
human play; capture exit reported four ObjectDB and two resource warnings. The
inventory also found the earlier C10 gaze spore hard to see; the subsequent
gaze and torrent changes are recorded above. A later selective C2/C10 action
survey is also recorded above; complete state coverage remains open.

**Colossus falling shards, committed in `7f7f245`:** Existing painted
`colossus_shard_fall` art appears during the final half of the one-second
warning, with a 60 px marker; timing, hitbox and damage are unchanged. The lead
passed `boss_hushed_colossus` and `route_cave_4`; the agent reports import, lint
and B04 ownership PASS. Natural actual-arena captures
`/var/tmp/wick-b04-fall/falling.png`, `impact.png` and `landed.png` in that
directory used a placed, protected player, not human play. Capture exit reported
four ObjectDB and two resource warnings.

**Gloam art review (`2974f78`):** Three ImageGen slash candidates were rejected
because poses overlapped or weapon lengths differed. None was integrated;
dedicated painted slash art remains open.

**Clean verification at `4dfd5e6`, 2026-10-28:** An isolated git archive of
exact `4dfd5e6c6162f638d97fc323b9f2c0a163046a2a`, with isolated HOME/XDG and
`TMPDIR=/tmp`, passed `make check`: 157 Godot tests including four playthrough
shards, lint, world-check and 175 Python tests. `make rooms-check` passed 221
rooms and `make art-test` passed 22 tests, emitting expected mismatch diagnostics
and ResourceWarnings. Logs are in `/var/tmp/wick-verify-4dfd5e6-ZkaakT/`
(`check.log`, `rooms-check.log`, `art-test.log`). The later clean `70d229d`
check is recorded above; headless automation does not establish human balance, visual or audio
experience.

**Kilnkeeper wax splash, committed in `9343092`:** A standalone painted
five-frame splash uses a verified ImageGen source, import and provenance, with a
thin active 150 px outline. The animation outlasts the three-frame hitbox and is
cleared on reset, phase change or death; damage and timing are unchanged. The
lead's import, `boss_kilnkeeper` and `route_cave_1` passed; the filter also
matched two additional test files, `route_cave_10` and `route_cave_10_anchor_drop`.
The agent reports lint, B01 ownership and `art-test` PASS. Actual C1 captures at
`/var/tmp/wick-c1-audit/phase1-active.png`,
`phase1-later.png`, `phase2-active.png` and `phase2-later.png` in that directory
used a placed, protected player, molten set and forced phase two, not human play.
Capture exit reported four ObjectDB and two resource warnings; a separate export
has not been verified.

**Lazy ending presentation and Q7 Reel, committed in `a65cec2` and `42b6327`:**
Ending choice zones are created immediately; presentation is created when the
boss flag is set during the fade, or immediately if already saved. Choice, save
and fade behaviour is unchanged. The lead passed `ending`, `boss_the_unlit`,
`area_cave_10` and `tool_matrix`; the agent reports lint and GUI fixture PASS.
Captures are in `/var/tmp/wick-z1-ending-visual/`.

Isolated add-child-only measurements were 9.57–10.16 ms before and 0.15–0.19 ms
after, with work moved to the flag. Whole-switch times were 57.3–62.1 ms before
and 54.1–63.8 ms after, so no reliable overall improvement is demonstrated.
These runs were headless with warm disk; Q8 and the 50 ms limit remain open.

Q7 uses the real Reel Line against three thorn variants and the eye switch;
controlled contact is negative and flags and blockers are checked on recreation
with in-memory state. This is not a complete matrix or human play.

**Gloam and Coinwyrm attack presentation, committed in `df7de44` and
`501765e`:** Gloam Knight's filled slash is replaced with a procedural multilayer
blade glint and 120° outline, without changes to damage, area or timing.
Dedicated painted slash art is still missing. The actual arena capture
`/var/tmp/wick-gloam-b2b4/cave_7_11-east.png` used a placed, protected player
and a frozen attack, not human play.

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

**Q8 read-only failure review, 2026-10-28:** Production has no threaded loader.
In scratch `/var/tmp/wick-q8-failure-review/`, a failed path is retried without
limit (29 requests in 30 frames), and direct `SceneTree.quit` in test/capture
bypasses the exit guard. A simulated timeout cancels quit and restores pause,
but does not test an actually stuck worker or GUI. Real WM-close, cold disk and
GPU were not tested. A safe solution needs a long-lived owner, terminal cleanup,
failure quarantine, all exit paths, coordinated ownership and real tests. No new
implementation or test was performed; synchronous production remains unchanged,
with no robust solution or integration.

**Q8 exit-drain scratch review, 2026-10-28:** In the older snapshot at
`/var/tmp/wick-q8-exit-review/`, an idempotent drain of active threaded loads
before title-menu/WM quit had no parse/load/leak errors in isolated synthetic
WM, pause, title and save processes. Drain took 7–82 ms with a headless frame
gap around 7 ms. One direct quit bypasses it and still errors; actual compositor
close is unverified and stuck loads have no timeout. Cold disk, GPU, CI, human
play and a full HEAD comparison are missing; this is not ready for integration.

**Q8 deferred-load scratch probe, 2026-10-28:** In
`/var/tmp/wick-q8-defer-MQL0Qk/`, an older snapshot not fully compared with HEAD
was tested headless with warm OS cache. First input-slide maximum was 56–60 ms
baseline versus 18–21 ms deferred; RSS increased 5–6 MiB. Start and fade were
roughly equal, but fade still reached 99 ms. Immediate quit with an active
request produced parse/load errors and six ObjectDB warnings despite exit 0;
graceful drain is not integrated. Cold disk, GPU, human play and long churn were
not tested. The prototype is not ready for integration; Q8 remains open.

**Q8 resource owner prototype v2, 2026-10-28:** A minimal reproduction supports
unretrieved threaded request results as the cause of RefCounted warnings when
World is freed. A global owner polls to completion: one World-free sample took
2.3 ms and produced no warnings after ten frames. Experimental cooperative app
exit took an additional 55 ms without a frame spike, but actual quit paths are
not integrated and immediate quit still warns.

Across 36 headless processes with warm disk, room 11→12 slide maximum frame
time was 57–61 ms baseline versus 18–22 ms for the variant. Direct start/warp
and fade initiation were slower and RSS was about 10 MB higher. Job priority is
not guaranteed and synchronous fallback remains. Logs and prototype are in
`/var/tmp/wick-q8-owner-v2/`; render/GPU, CI, human play and a long-term plateau
were not tested. Nothing is merged into production and Q8 remains open.

**Q8 threaded resource-cache prototype, 2026-10-28:** An isolated scratch
prototype in `/var/tmp/wick-q8-thread-probe` compared baseline and variant in
three headless processes. Maximum frame time for the room 11→12 transition was
60.8–75 ms baseline versus 18.7–33.3 ms with the prototype, with the same slide
time and no extra room nodes. Direct cold starts and fade start were slower.
There were zero orphans at disposal but 1–3 ObjectDB warnings without a drain;
a blocking drain took 37 ms. Cache quota/churn and lifecycle remain unresolved.
The scratch copy had identical but mixed working files, and the OS cache was
warm; GPU, human play, CI and a long-term plateau were not covered. Nothing is
merged and Q8 remains open.

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

**Q8 broad survey, committed in `20acebe`:** Three passes over 222 scene targets
made 666 direct warps. Matched passes two to three showed maximum node growth
of zero, static-memory growth of 141,888 bytes and zero orphan growth; no orphans
remained after World disposal. The agent reports the isolated test PASS; the
lead independently passed `TMPDIR=/tmp make test T=streaming`. The agent
measured a 6.501 ms mean and 79.971 ms maximum, with an earlier maximum of
144.305 ms. Logs: `/var/tmp/wick-q8-broad-final.log` and
`/var/tmp/wick-q8-broad-final-rss.csv`. There is no calibrated CI or render/GPU
coverage or full physical traversal; the 50 ms limit is not established and Q8
remains open.

**Earlier Coinwyrm art candidate:** The frontal bite did not match sideways
attacks; its limited downward-facing integration is recorded above.

**Choir Warden song cone, committed in `f6b1daf`:** The note cone uses the
existing painted treble note and a light-independent boundary; damage, hitbox,
ward and timing are unchanged. Actual arena captures are
`/var/tmp/wick-dynamic-7b3d/cave_6_4-tell.png` and
`/var/tmp/wick-dynamic-7b3d/cave_6_4-active.png`, with a placed, protected
player; this is not human play. The lead verified `choir_warden` and
`route_cave_6`; the agent reports lint and MB3 ownership PASS. Choir's song
animation is incomplete and uses `walk_side`. Gloam Knight showed a solid purple
sector in `/var/tmp/wick-dynamic-7b3d/cave_7_11-active.png`; its subsequent
presentation change is recorded above.

**Q7 scoped keys through grates, committed in `045900a`:** Real Tether Moth
retrieves remaining scoped keys across grates in overworld and C1 cases, while
Reel Line is stopped. Actual contact is measured and flags and solid blockers
are checked after recreation. These controlled fixtures retain in-memory state,
not a save file; they do not establish human play or a complete matrix.
`tool_matrix`, lint and Q7 ownership are reported PASS.

**Full check in a changing worktree:** `make check` passed 157 Godot test files
including playthrough shards, lint, world-check and 175 Python tests while
uncommitted boss, streaming and Q7 files were changing in parallel. It cannot
be attributed to an exact clean commit. At that time the previous clean full
check was `b41dc6d`; the later clean `4dfd5e6` check is recorded above.

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

**Tidewick ember bolt, committed in `bb87f58`:** Tidewick now fires a correctly
oriented, painted animated ember bolt in place of the spore. Its light is
presentation-only, not gameplay glow; the existing fallback, speed, damage and
collision logic remain unchanged. The pipeline reuses a provenance-documented
source image and includes the Godot `.import`. The lead's import,
`boss_tidewick`, `area_cave_3` and `tool_matrix` passed; the agent reports lint,
B03 ownership and `art-test` PASS. The active arena capture
`/home/mikael/.cache/wick-b03-final/ember-flight.png` used a controlled, protected
player; human play remains unverified. The subsequent export check and Q6/Q8
reports are recorded above.

**Coinwyrm attack presentation, committed in `3601e4b`:** Transparent outlines
replace the filled bite and tail areas; the bite reuses three painted coin
impacts and the tail uses existing art. Collision, damage and timing are
unchanged. Actual active-state captures are `/var/tmp/wick-b08-f29-bite.png` and
`/var/tmp/wick-b08-f29-tail.png`, with controlled positioning and a forced tail
phase. The lead's `boss_coinwyrm` and `route_cave_8` tests passed; the agent
reports lint and B08 ownership PASS. A distinct jaw animation is still missing,
and this is not human play. Tidewick's subsequent projectile change is recorded
above.

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
fixtures do not prove human play or complete tool/gate coverage; the later clean
full `make check` at `4dfd5e6` is recorded above.

**Q7 gate revisit cases, committed in `0faeca5`:** Real Wick positives cover
three thorn variants, sling covers the eye switch and Chime covers three
resonance variants. Twenty-one hook/flare/pot negatives confirm contact and
check flags and solid blockers on revisit, including both eye blockers. Isolated
`tool_matrix` and lint passed; these are controlled fixtures, not human play.
Other tools, gates and encounter combinations remain open. The later clean full
check at `4dfd5e6` is recorded above.

**Q7 wax seal, committed in `52cbdeb`:** A real flare opens the seal after a
controlled initial hook miss; hook and pitch-pot explosion are negative with
confirmed contact. Flag and solidity are checked before and after revisit.
Isolated `tool_matrix` and lint passed. This is a controlled fixture, not human
play; other tools and combinations remain open.

**Q7 hook-tap wall, committed in `a403f20`:** A real hook hit is positive;
flare and pitch-pot explosion are negative with confirmed contact and
flag/solidity checked before and after revisit. The flare is charged beyond hook
range to prove the hook misses. Isolated `tool_matrix` and lint passed; this is a
controlled fixture, not human play. Other tools and matrix cases remain open.
At the time, the previous full `make check` was at `b41dc6d`; a later clean
check at `4dfd5e6` is recorded above.

**C10 lantern glow, committed in `b41dc6d`:** Two painted glow variants
alternate every 0.5 seconds through a presentation child that follows the
lantern after the boss dies. Mechanics are unchanged. Isolated import,
`boss_the_unlit`, `tool_matrix`, lint and `art-test` passed. An actual-arena
capture used forced phase two and a placed player, not human play. A new shell
walk candidate was rejected for scale and is not in runtime; shell animations
and the E1 conflict remain open. An isolated `make check` passed at `b41dc6d`:
157 Godot test files including playthrough, lint, world-check and 175 Python
tests. Another agent continues Q7 in an isolated copy.

**Q7 heavy obstacles, committed in `26713bf`:** Twelve negative cases use actual
hook, flare and pitch-pot explosion against four heavy variants, verifying
contact and that each obstacle remains solid, undisturbed and unflagged after
revisit. Existing positive Mitts cases remain. Isolated `tool_matrix` and lint
passed; other gate families, tools and combinations remain incomplete and this
is not human gameplay. The latest full `make check` was at `c31b391`, before
this test change.

**Unlit heart states, committed in `c31b391`:** Shielded and exposed pulse
states use two provenance-recorded ImageGen edits of the accepted heart, shown
on the existing timer with a small light. Gameplay and hitboxes are unchanged.
Isolated import, `boss_the_unlit` (296 checks), `tool_matrix` (1201), lint and
`art-test` passed. An actual C10 capture used a controlled phase and real Reel,
with the player repositioned and hurtbox disabled; it is not human play. The
later lantern glow is recorded above; shell animations remain incomplete. Gloam source review tested all
documented sources: none supplied a correctly segmented, correctly scaled
four-pose slash row, so none was installed; the rejected candidate and log remain.
The first full `make check` produced 13 route failures when temporary quota forced
profiles to `/var/tmp`, while the test safety boundary requires `/tmp`. After a
finished 101 MB scratch project copy was removed, `route_cave_5` passed and a
subsequent isolated `make check` passed 157 Godot test files, lint, world-check
and 175 Python tests. Remaining C10 animation art and the E1 conflict stay open.

**Gloam Knight animation, committed in `cea4152`:** Two crouch frames play
during the existing 0.5-second warning, retaining the prior fallback. Four
`walk_side` frames are selected at nonzero speed, but the fight has no natural
walking; that cycle was tested in an arranged state. Isolated import,
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

**Q7 real-tool extensions, committed in `58c58bc`:** Actual tools exercise The
Unlit's five sling eyes, three Wick casts, Reel exposure and hook against shield
and heart, plus two two-half-heart fire ticks on Thorn Warden. Isolated
`tool_matrix` and lint passed. Positions are controlled and player hurtbox
disabled; this is not human play. Full tool/phase permutations and gate
negative cases remain incomplete. `make rooms-check` passed 221 rooms and
`art-test` passed 22 tests; the test tool emitted expected mismatch and resource
warnings. Later export intro and animation audit results are recorded above;
E1's specification conflict remains unanswered.

**Intro and Thorn Warden presentation, committed in `0b6f9ca`:** Six previously
missing active intro images were completed from earlier generated candidates,
with provenance in `docs/art-provenance.md`; the actual intro was visually
reviewed at accelerated speed. Thorn Warden projectiles use a painted lance
instead of a diamond; natural emission in `cave_2_4` was reviewed with a placed
player. Isolated import, `intro`, `thorn_warden`, `area_cave_2` and lint passed;
this is not human play. A static asset audit found file resources for all 200
manifest kinds, without covering all dynamic states. Isolated `make check`
passed on `0b6f9ca`: 157 Godot test files including the full playthrough
shards, lint, world-check and 175 Python tests. Human play, complete dynamic
visual coverage and the ending-choice conflict remain open. A clean Linux export
on `0b6f9ca` using official Godot 4.7.2 passed import, export and headless
startup; its log includes all six intro PNG `.import` and ctex files, intro JSON
and scene. At that check the project intro was visually reviewed, not the exported
intro; the later export intro check is recorded above. A direct scene override exited 1 because the release
template does not support path overrides; this limits that method, not the
headless startup result.

**Cinder Wisp windup, committed in `0a1c45d`:** The white warning disc is
replaced by a painted buildup and light-independent 150 px outline. The
0.5-second duration, damage and mechanics are unchanged; the active attack stays
separate. Isolated `test_cinder_wisp` and lint passed, including fallback and
stun. Bright and dark actual-room captures froze a natural windup with a placed
player; this is not human playtesting. An isolated `make check` passed on
`0a1c45d`: 157 Godot test files including four playthrough shards, lint,
world-check and 175 Python tests. A completed route is verified by test input
using internal information, not human balance play. Full visual coverage of all
possible states and E1's touch-versus-confirm specification conflict remain open.

**Snapper and Choirling warnings, committed in `19acc05`:** Both use painted
warnings with clear edges; attack areas and timing are unchanged. Isolated
`bramble_snapper`, `choirling`, `area_cave_6` and lint passed. Images used actual
rooms with a placed player; Choirling was in a natural state, not human play.
The Snapper capture reported resource warnings at exit, cause unknown. The later
Wisp warning change and full check are recorded above.

**Gloam Knight and Dirge Choir effects, committed in `5536695`:** The Knight's
landing and ring and the Choir's alto sector use painted effects with thin
outlines; hit areas and timing are unchanged. Isolated `boss_gloam_knight`,
`area_cave_7`, `route_cave_7`, `boss_dirge_choir`, `area_cave_6` and lint
passed. Actual-arena stills used forced frozen Knight effects; its ring can,
as before, appear outside the island where collisions are inactive. The Choir
attack was natural but the player was placed and its hurtbox disabled. Human
play remains unverified. An isolated full `make check` passed on `5536695`: 157
Godot test files including playthrough, lint, world-check and 175 Python tests.
Images of shared telegraphs identified clear presentation candidates for Cinder
Wisp, Bramble Snapper and Choirling; later Snapper and Choirling work is
recorded above. Many thin markers are intentional readability aids.

**Verification and visual follow-up at `80599b6`, 2026-10-28:** Isolated
`make check` passed 157 Godot test files including playthrough, lint,
world-check and 175 Python tests. Visual inventory found a filled Gloam Knight
landing disc and Dirge Choir's alto sector; the later change is recorded above.

**Miniboss warnings, committed in `80599b6`:** Wick Automaton's tell uses muted
painted fire and a thin outline; Corrow's Echo GLOW/FLARE outline is visible
outside lamp light. Mechanics are unchanged. Isolated `wick_automaton`,
`corrows_echo`, `area_cave_10` and lint passed. Captures used actual cave rooms
with a placed player; Echo had raised test health and FLARE was slowed after a
natural transition. This is not human playtesting. Some capture tools reported
resource warnings on exit, cause unknown.

**Export check at `666d61d`:** An export using the official Godot 4.7.2 template
contained all 222 world scenes, JSON and title images. The actual GUI title
screen and headless startup passed; gameplay and audio were not verified.

**Title and Lull Mauler presentation, committed in `666d61d`:** The title uses
the planned painted splash, upscaled from a previously reviewed source, and a
new native-alpha logo recorded in `docs/art-provenance.md`. The actual title
scene was reviewed with and without an isolated test save; `test_title` passed.
The Mauler's smash warning uses painted cracks and its sweep outline is visible
in darkness; its focused test passed and a natural state was reviewed with a
placed player, not human play. Capture exit reported resource warnings of unknown
cause. Further late effects remain to be reviewed. An isolated full `make check`
has since passed on `666d61d`: 157 Godot test files including the playthrough,
lint, world-check and 175 Python tests. Export and miniboss results are recorded
above; further review remains.

**Verification at `e760223`, 2026-10-28:** `TMPDIR=/tmp make check` passed 157
Godot test files, lint, world-check and 175 Python tests. `TMPDIR=/tmp make
playthrough` passed the route check and all four shard files, including a
continuous fresh-save run through all caves and the final boss to the actual
ending. The bot reads internal state; this is not human playtesting and does not
prove every branch. The earlier separate checks of both endings remain separate
evidence. Full effect inventory remains in progress.

**Colossus attack presentation, committed in `e760223`:** Slam, ring and sweep,
plus yellow sweep and slam warnings, use painted effects and thin hit-area
boundaries; timing and hitboxes are unchanged. Isolated `boss_hushed_colossus`
and `area_cave_4` tests and lint passed. Stills from the actual C4 arena used
forced states, not human play. A small seam is visible in the ring texture. Full
effect inventory and natural playtesting remain open.

**Sump Lurker water tells, committed in `772915a`:** The water marker and bite
warning reuse painted water art with mechanics unchanged. The isolated
`sump_lurker` test and lint passed. Natural states in `cave_3_4` were visually
reviewed with a placed player, not through human play or multiple angles. The
capture tool reported a resource/ObjectDB warning on exit; its cause is unknown.
The later Colossus presentation work is recorded above.

**Fen Leech warning, committed in `ceb9c4b`:** Existing painted water art
replaces the yellow Placeholder puffs, with the 0.5-second warning and mechanics
unchanged. The isolated `fen_leech` test and lint passed. Captures used a forced
warning from a moving raft in dark `cave_3_6`; natural play has not been tested.
Static inventory identified candidate geometric effects in the Colossus slam,
shockwave and sweep and in Sump Lurker. Later Sump work is recorded above;
later Colossus work is also recorded above and the full inventory is incomplete.

**Cinder Wisp active attack, committed in `7b25985`:** The attack reuses a
painted fire ring with an outline marking its radius; mechanics are unchanged.
The isolated `cinder_wisp` test and lint passed. Controlled-position captures
were reviewed in a bright room and a dark cave, not human play. The Fen Leech
warning changed later as recorded above; the full inventory is incomplete.

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

**B03/B09 immunity fixes, committed in `59e339f`:** Both subclass initializers
now call `BossBase`'s initializer; actual scenes have stun and knockback scales
zero and drops disabled. In B09, real sling damage no longer pushes and the Moth
does not stun; forced-death drop checks show only intended embers. B03 retains
real raft/tail and reward behavior. The agents report isolated B03, B09, C3, C9
and Q7 tests and lint passing; the lead passed the five corresponding tests.
The earlier continuous Q3 ending-scene win depended on B09 knockback and predates
these fixes; the synced rerun is recorded below.

**B09/B03 immunity audit:** In the actual Lock Warden scene, knockback and stun
scales are 1: an actual slug moves the boss and an actual Moth stuns it, contrary
to binding boss immunity and stationary Warden requirements. The audit points to
subclass `_init`; `drops_enabled` is also true, a static risk of unplanned drops.
Tidewick likewise has defaults 1/true, but its separate hitboxes filter
interactions and a direct effect was not demonstrated. The later committed fixes
are recorded above. The earlier ending-scene victory preceded the B09 fix; the
synced rerun is below.

**Q3 earned route to ending scene, committed in `59e339f`:** The continuous
input route from start through C1–C10 defeats The Unlit with normal damage and
active enemies, including an ordinary boss death, respawn and full return, and
an actual slug-bundle pickup. Phase one uses 15 sling shots, phase two three
Cinder Wick uses and ward, and phase three a physical ember, three Reel uses and
24 hook damage; victory leaves 10/28 half-hearts. Physical contact at the left
pedestal plus the current confirm action loads the actual `ending.tscn` and sets
`ending_rekindle` and `completed`. To protect the test harness, the test sets
`current_scene` to null and restores the runner; SaveGame is disabled. The agent
reports two exact isolated first shards, a separate audit, shards 2–4 and lint
passing with both B03 and B09 fixes synced. B09 remained stationary; C9 victory
was at 15/26 and C10 at 10/28. Actual ammo and ember were collected, with
ordinary C9 and C10 respawns, active enemies and no warp or manual state in the
continuous portion. The lead's `TMPDIR=/tmp make check` passed with the B03/B09
fixes and route to ending: all Godot suites including four shards, lint,
world-data and Python tests.
At that checkpoint credits, title return and the other ending were not continuously
tested; the later Wickwarden route through Continue is recorded above. The bot
reads boss, hazards, eyes, projectiles and other internal state;
the global seed does not control or log two bosses' own RNG, and C7 had a 1/22
margin. Human play and balance remain open; the ending-choice contract conflict
and pending user decision remain unchanged.

**Z3 Linux export smoke test, committed in `fec1e95`:** `export_presets.cfg`
defines Linux x86_64 with `all_resources`, `*.json` included and `tests/*` and
`tools/*` excluded. In isolated scratch using the official Godot 4.7.2 template,
the agent reports building a PCK and release executable and running headless for
120 frames with Dummy audio and exit 0. The export log contains four data JSON
files, `sprites.json` and 222 room/pocket paths. Scratch and its templates were
removed; real saves and installed templates were untouched. This is not human,
audio, visual or full-playthrough verification; Q3, E1 and release gates remain
open.

**Q3 C10 boss entrance, committed in `0d3ab88`:** With room-10 fix `b5ba112`
synced, the continuous earned input route physically spends key two at `e242`,
collects key three and spends it at `e243`, collects a +6 slug bundle, uses the
sling eye, earns the Lockpick and opens the boss door to the actual The Unlit in
`cave_10_14`. Entry is 10/28 half-hearts, 10 pots and 24 slugs. Enemies and
damage are active, Echo is bypassed alive, no warp or manual state is used, and
the route includes an earlier ordinary respawn. The agent reports two first-shard
runs, shards 2–4 and lint passing; the lead passed `TMPDIR=/tmp make test
T=playthrough_1` locally with the boss entrance. Global seed `20261027`
does not control independent boss RNG; the bot reads boss ID, phase and HP and
earlier enemy/projectile state. At that checkpoint victory and a full ending
remained open; the later unpushed route and remaining limits are recorded above.
E1 is unchanged and the user response remains pending.

**C10.c room-10 geometry, committed in `b5ba112`:** Two floor tiles were opened
in `cave_10_10` and `make rooms` generated the scene. From the north bank,
actual Reel input reaches `e242` and key three; a separate ward-cache case uses
real watcher shots and ward, then returns by Reel. These fixtures grant the
loadout, start position and key and use 40 half-hearts, with damage and enemies
active. The agent reports `rooms-check` 221, C10 area/route, the new test twice
and lint passing. The lead passed the new test and `hidden_seam` and reviewed an
actual-room capture. The lead's `TMPDIR=/tmp make check` passed the Godot suite
including four shards, lint, world-data and 175 Python tests with the preceding
version of the new tests. Independent review found no confirmed blockers or new
shortcuts; `rooms-check` 221 and the 30-check test passed. The null-hound
false-pass risk was corrected: the regression now requires an actual living
hound and then that same hound defeated. The agent reports the corrected test
and lint passing; the full `make check` preceded this test-only correction.
The north boundary without
Reel and the return transition have not been dynamically tested; the fixture uses
40 HP and human play remains open. The later unpushed earned route to the boss
entrance is recorded above.

**C10 room-10 access investigation:** Two independent input and geometry probes
found the `cave_10_10` landing at `(1008, 648)` separated from western `e242`
by a pit and walls; the ward-cache entrance is also enclosed. This strongly
suggests a level problem, but does not formally exclude every tool interaction.
A `FromPocket` fixture placed on the other side can walk to `e242` and key three
with damage and enemies active. C10.c's committed correction is recorded above.
The earlier Q3 route repeatedly reached the second Reel bank at 14/28
half-hearts. The lead passed `TMPDIR=/tmp make test T=playthrough_1` locally for
that landing; the later unpushed continuation to key three is recorded above.

**Q3 C10 room 10, committed in `0ca0ee6`:** The continuous input route defeats
three Mirror Shades, uses the actual Chime, earns the second key, and after an
ordinary enemy death and respawn retains a key. It uses raft, mitts, boots and
Reel to reach `cave_10_10` with 14/28 half-hearts and one C10 key. Damage and
enemies are active, Echo is bypassed alive, and no warps or manual state changes
are used. Further attempts failed and were not integrated; key three, Lockpick,
boss and ending remain open. The agent reports two full isolated first-shard
runs, shards 2–4 and lint passing; the lead passed `TMPDIR=/tmp make test
T=playthrough_1` locally with the new section. Archivist and Tidewick use
unlogged independent RNG; earlier bot internal-state reads,
C7's low margin and human-play limits remain.

**F3 runner import isolation, committed in `ca183c1`:**
`tools/run_godot_check.py` now creates its temporary root before `ensure_import`;
Godot import receives a separate `isolated_env` under `import`, and each suite
continues to use its own user directory. The agent reports isolated import and
`save_game`, lint, and fake-home/mock tests under `/tmp`, `/var/tmp` and custom
`TMPDIR` passing. The lead passed `TMPDIR=/tmp` with `--import save_game`. Q3's
hard `/tmp` guard is unchanged; a shared runner guard and Q3 changes require WP
owner coordination. This is not a complete solution or protection against
malicious code.

**Q3 C10 approach, committed in `9bfe631`:** The continuous earned input route
with normal damage wins C9, physically buys healing and slugs at S5 for 45
earned brass, passes the Ninth Door with nine fragments, then earns the Wick and
first key, passes the living Echo, uses the raft and Jar and reaches `cave_10_6`
with 14/28 half-hearts and 19 slugs. C10 boss and ending are not verified. A
second-key attempt died or became stuck and was not integrated. The agent
reports two isolated first-shard runs, all four shards and lint passing; the
`/dev/shm` scratch copy needed an isolated runner-path adjustment only in that
copy. The lead's first workspace `make test T=playthrough_1` reached C10 room 6
but failed the disk-roundtrip safety check: the `/tmp` user quota was full and
tempfile fell back to `/var/tmp`. After removing the lead's own finished temporary
verification copy, `TMPDIR=/tmp make test T=playthrough_1` passed with isolated
user data; no real saves were touched. Earlier RNG, bot internal-state reads,
bypassed minibosses and human-play limitations remain.

**C10 final-boss probe, 2026-10-28 (isolated; documented in `79369cd`):** A 47-check probe uses actual
World and final boss with normal damage, active hounds and wicklings, and sling,
Wick, Reel and hook, winning with 3/28 half-hearts. It physically tests a socket
and confirm flag with `dry_run=true`, so no actual scene transition occurs. The
fixture grants tools, health and ammo and repositions beside targets; this is
not an earned route or human proof.

**E1 ending-choice conflict (documented in `79369cd`):** Binding `monsters-bosses-tools.md` §4.10 says
touching a choice selects it, while binding `world-work-packages.md` §8.2 E1
says to walk to a pedestal and confirm. Decision 40 resolves file and flag names
only. The current trigger requires confirm while touching; it is unchanged and
no implementation change has been made. The user has been asked to resolve
the conflict. The probe exercises current confirm behavior, not touch alone;
its fixture and dry-run limitations above remain.

**Q3 Lock Warden victory, committed in `fc895af`:** The continuous earned
input route with normal damage and an ordinary C9 respawn breaks all four actual
plates with sling shots and defeats Lock Warden. It physically collects fragment
and core, raising maximum health from 26 to 28 and restoring health to 28. After
the plates, the player physically collects the phase-change ember: the
PickupCollector signal counts exactly one and health is checked from 13 to
15/26. The victory leaves 15/26 and one slug after 25 used in phase two. A
wickling count was observed changing from one to zero; its exact cause is
unknown. Enemies and damage remain active. The agent reports two final isolated
runs, shards 2–4 and lint passing. Global seed `20261027` does not control or log Archivist's and
Tidewick's own randomization. The bot reads boss, eye, plate, `open_left`,
`bolt_left`, wickling and projectile position/direction state, plus earlier
bosses' internals. Active minibosses are bypassed; human play, other seeds and a
complete game remain unverified.

**B04 quake art, committed in `8a0b157`:** Native-alpha painted cracks cover
dangerous 96×96 checkerboard tiles; outline and fill show the full hit rectangles
and the active state is brighter. Timing, damage and arena light are unchanged.
The lead reviewed warning and active captures in the actual arena with a forced
hazard; the agent reviewed both parities and 72 tiles and reports boss and route
tests and lint passing. Human action play remains open; the art agent maintains
provenance separately.

**C9 direct phase-two fixture (isolated):** With normal damage, three of three
attempts used actual inputs, ward and six flares to win and physically collect
fragment and core, raising maximum health from 26 to 28. Wicklings were initially
alive, but phase was set directly and the player placed at 13/26; reported health
before rewards was 3/26. The bot tracks the boss because of knockback. This is
not a continuous earned-route victory.

**C9 phase-two survival probes (isolated; documented in `196d4a6`):** The continuous
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
