# Lockpick art and pipeline log

2026-10-25. Owner decision 45; presentation only, internal big_key/bigkey and save APIs unchanged. Native built-in imagegen only. Three calls total: pickup attempt 1 rejected, pickup attempt 2 accepted, HUD attempt 1 accepted. No CLI/API fallback, raster painting, external scaling, or cutter edits.

## Verified native outputs

| Workspace source | Native session path | Output | Raw and accepted dimensions | SHA-256 | Result |
|---|---|---|---|---|---|
| `tools/source_art/lockpick_pickup_v1.png` | `/home/mikael/.codex/generated_images/01a173b6-dd52-7ea2-9a1e-db4817496668` | `exec-106cc047-cad6-4702-a1a7-f26f2e262f7f.png` | 1536×1024 | `f887f6dc0a5e0e47a7f309cb91519820252704cb21a1a73b8ee3f3ae39bb8075` | accepted pickup attempt 2 |
| `tools/source_art/lockpick_hud_v1.png` | `/home/mikael/.codex/generated_images/01a173b6-dd52-7ea2-9a1e-db4817496668` | `exec-d61727d7-86a1-4fe0-95e6-084527a44566.png` | 1254×1254 | `43c9c5575dea7cb685b346fe8011723a2a4b641707af850384e4fa9fdca3698d` | accepted HUD attempt 1 |

Rejected pickup attempt 1: `exec-31295a85-fab5-4693-ac8f-2376105856c7.png` in the same session, 1536×1024. Four separated diagonal subjects visually, but overlapping x extents: cutter reported “found 1 poses, expected 4”. Retained in native session, never committed. Targeted retry changed all long axes to near vertical and required empty vertical column gaps; same subject/materials/glint. No old B22/B72 ornate key was a reference or target.

## Prompt set and references

All prompts used the full shared and sheet blocks from art-brief section 2: original Wickwarden, hand-painted storybook, visible brush strokes/soft edges, warm upper-left lamp light, cool dusk shadows, 50-degree top-down; no pixel art, text, labels, borders, watermark; flat #FF00FF, no floor/shadow, complete separate same-scale poses. Use case stylized-concept.

Pickup attempt 1: accepted `icon_cinder_wick_v1.png` opened before native call, explicitly material/brush style only. Exactly four copies, broad asymmetrical flattened forged-steel picking blade with short bent working tip, short battered brass thumb grip, uneven hammered surface; no key teeth/bow/ornate key/writing/sigils/flame. Idle then three steel glint frames growing, peaking, fading; no detached stars. Requested 1536×1024 and runtime 96×96 foot88. Attempt 2 used opened attempt 1 as design reference, preserved all constraints, corrected angle to 10-degree near vertical, approximately 180×560 subject bounds and at least 100 px completely empty column gaps. Accepted source is unmodified native bytes.

HUD: opened pickup attempt 1 design reference plus opened accepted Cinder Wick material/brush reference. Exactly one matching lockpick, square requested 1024×1024, diagonal grip bottom-left to bent steel tip top-right, 15 percent margins, readable 64×64 icon, stronger cool bright blade edge and warm brass grip. No duplication, key teeth, bow, ornament, text/sigils, flame or detached sparkles. Native result dimensions are recorded above; no source resize.

## Manifest and runtime

New kinds `bigkey` and `big_key`: 96×96 foot88 radius10, idle1 and glint3 at 6fps. Both aliases are cutter outputs from the same shared `lockpick_pickup` fit78×78 scale group across all four source poses. Files `lockpick_bigkey_{idle,glint}.png` and `lockpick_big_key_{idle,glint}.png`. New `hud_counter_big_key`: center-aligned 64×64 idle1, uniform fit52×52, file `lockpick_hud.png`. Only named new sheets cut; no existing kind/animation replaced. Runtime manifest assembled from cutter-generated new entries plus unchanged baseline entries (avoids unrelated terrain normalization).

PickupBase attaches `big_key`. Original HUD also asked icon_of(big_key), using the same default idle, so manifest-only wiring cannot choose separate sources by consumer. Reported to lead. Concurrent UI owner added dedicated hud_counter_big_key lookup in hud.gd; no code/UI changes belong to this commit. Canonical bigkey alias remains available. Neither animation timing nor glint autoplay was added to game logic.

## Visual findings and checks

Opened both accepted native files, both full cutter proofs, final cut contact sheet, actual World capture `/tmp/wickwarden-lockpick-runtime.png`. Pickup is an upright practical steel tool with bright bent tip, readable brass grip and darker irregular blade; HUD is a distinct diagonal composition at 32px. No visible clipping, key-colour halo, text, teeth or bow. Three glints visibly vary the steel highlight while silhouette/scale stay steady. Native grip has two plain retaining collars and a dark end face; no ornamental bow. Pickup remains relatively slim at native runtime size, consistent with a hand tool.

Temporary capture harness `/tmp/wickwarden-lockpick-runtime-capture.gd` instantiates real World, actual PickupBase big_key and actual Hud, sets cave c1 flag without collecting the shown pickup, checks both icon resolutions. No repository edits needed. Exit logs have four ObjectDB leaks/two resources still in use (temporary capture cleanup); capture and assertions succeeded.

- make art-test: 20 tests pass (`/tmp/wickwarden-lockpick-art-test.log`).
- make test T="sprite_visual pickups hud": all three suites pass (`/tmp/wickwarden-lockpick-tests.log`).
- make lint: no problems (`/tmp/wickwarden-lockpick-lint.log`).
- Import and actual display capture pass (`/tmp/wickwarden-lockpick-{import,runtime}.log`).
- Preservation baseline `/tmp/wickwarden-lockpick-baseline`: all 77 preexisting sprite/protected-source PNG hashes unchanged, all 53 runtime entries unchanged. This includes all B22 bigkey_v1..3 and B72 hud_counter_big_key_v1..3; no unrelated namespaces/animations changed.
- Deterministic regeneration verified against a fresh temporary output directory, including all five new PNG bytes and all three runtime entries.

Shared provenance untouched. Append-ready verified rows: `/tmp/wickwarden-lockpick-provenance.md`. No push performed.
