# E1 ending and choice art integration

Existing-source publication only. No image-generation tool was called. Original generation provenance remains in log_art_resume_28.md (ending A), log_art_resume_29.md (ending B), log_b42.md (choice lanterns) and log_b53.md (Corrow); this record does not invent a more specific tool model than those source records expose. All selected raw PNG bytes compare equal to committed sources.

## Ending stills: exact direct paths and geometry

The actual data/ending.json IDs are ending_a_rekindle and ending_b_dawn. scripts/ui/ending.gd first asks SpriteVisual.icon_of, then loads assets/art/<id>.png. This batch publishes the requested direct painting paths without creating competing sprite kinds or editing UI/data. Inventory binding output1920x1080. B84/B85 prompt notes explicitly say: “Target:1920x1080. Stills use the largest16:9crop; no cut-tool pass.” Sources are1536x1024. Therefore each export uses the centred maximum16:9 rectangle(0,80,1536,944),1536x864, followed by ONE uniform1.25x LANCZOS resample to1920x1080. No anisotropic stretch, custom reframing, colour edits, palette change or raw overwrite.

Selected v1 for both branches: A shows the lit lantern over the warm inhabited valley, B shows an unlit lantern above the dawn shore. Opened all six raw variants with canonical crop boundaries in /tmp/e1-source-compare-0.jpg. The selected crop retains Tamsin, whole carried lantern, horizon and story subject; only80px top/bottom margins are removed, per the source instruction. Opened actual resulting Ending UI captures /tmp/wickwarden-e1-coda-rekindle.png and /tmp/wickwarden-e1-coda-wickwarden.png. Output exports are assets/art/ending_a_rekindle.png and assets/art/ending_b_dawn.png.

Reproducible deterministic export (Pillow12.3.0; no new cutter/tool):
```python
for kind in ["ending_a_rekindle", "ending_b_dawn"]:
    im = Image.open("tools/source_art/" + kind + "_v1.png")
    assert im.size == (1536, 1024)
    im.crop((0, 80, 1536, 944)).resize((1920, 1080), Image.Resampling.LANCZOS).save("assets/art/" + kind + ".png")
```

## Choice sprite interface

| Runtime key | Binding cell | Foot / manifest anchor | Frames |
|---|---|---|---|
| arena_lantern_rekindle |160x224 (arena_pedestal_lantern inventory) |prop foot218, [80,218] |idle1@1fps |
| arena_lantern_wickwarden |160x224 (same inventory row) |prop foot218, [80,218] |idle1@1fps |
| npc_corrow_wax |256square |foot236, radius38 =>[128,198] |idle4/speak2@6fps loop; fade4@8fps nonloop |

The lantern props use established cell-height-minus6 foot alignment and rect_h60, overridden by ending_trigger’s existing radius30 footprint through SpriteVisual. No trigger size/offset changes. Selected rekindle_v1 has the clearest small glass-chimney lantern; v2 is a recessed shrine, v3 more ornate. Wickwarden_v2 has a readable tall iron cage/brass hooks; source still burns warm despite the trigger’s cool light, retained art design. Both B42 sources include full tall stone stands and foliage, as the original logs note. The trigger separately adds pedestal art underneath: actual /tmp/wickwarden-e1-choice-rekindle.png shows this existing presentation overlap. Reported to root; an E1 actor owner can suppress the extra pedestal when full stand art is available. The mapper does not crop the stand or modify actor placement.

Corrow down_v3 is the clean source-log candidate: four seated poses, two speech gestures, four dissolving-wax frames; no facing substitution. Single shared fit over all ten frames, foot236 fixed. Background drift is handled by the existing key estimator. Glow in the dissolving frames remains painted source material, not a claim of fully transparent final fade. The actual trigger currently uses default idle only. Opened all nine B42/B53 variants in /tmp/e1-source-compare-1.jpg, each selected cutter proof and every output frame; seated Corrow and both lamps visible in the actual choice capture.

## Source and output hashes

- `tools/source_art/ending_a_rekindle_v1.png` SHA256 `e9927a115194b28bc7d2c80f5484d594ac144bf8ebc13f9391760868d70da3e2` (existing committed source).
- `tools/source_art/ending_b_dawn_v1.png` SHA256 `aa0ad39ef3444d58f8bef43aabf75408f4d59ebad0171a7f1a8c9c5fc59fc297` (existing committed source).
- `tools/source_art/arena_lantern_rekindle_v1.png` SHA256 `99d04869d003168db8aa79127a7c84f34df40073a1365eb307ded19130d95500` (existing committed source).
- `tools/source_art/arena_lantern_wickwarden_v2.png` SHA256 `cdd58d35c80229d4e87cdab7a2599d8838328ed755a2ddaf3cfd1c9e4506c02c` (existing committed source).
- `tools/source_art/npc_corrow_wax_down_v3.png` SHA256 `039c4445210e563b1e0155eaa7800a68354ec0ce2b6cd9d3c3426683f57c7089` (existing committed source).
- `arena_lantern_rekindle.idle` -> `assets/sprites/arena_lantern_rekindle.png`, SHA256 `b556a8d364a7526631aecef7186745a96741062b56abf06b84cbcb33a7e673c7`; 1frames, 1.0fps, loop=True.
- `arena_lantern_wickwarden.idle` -> `assets/sprites/arena_lantern_wickwarden.png`, SHA256 `024bcda9e8cbc3ac254b0c930d1e18a539fc82669af1352874f121eaf9cd11ac`; 1frames, 1.0fps, loop=True.
- `npc_corrow_wax.idle` -> `assets/sprites/npc_corrow_wax_idle.png`, SHA256 `c8843aa675c8b41515ba35c6f68365ea4be0fa238b55a7b62f26c07c5058dbac`; 4frames, 6.0fps, loop=True.
- `npc_corrow_wax.speak` -> `assets/sprites/npc_corrow_wax_speak.png`, SHA256 `2a74e415640fb596daa1f794bed8ed919ba72d09d326de6e3d7350450fa0df57`; 2frames, 6.0fps, loop=True.
- `npc_corrow_wax.fade` -> `assets/sprites/npc_corrow_wax_fade.png`, SHA256 `da304770b5e9f2985e93602c0930c02417878fe85f2d43601a7862642d03d8a6`; 4frames, 8.0fps, loop=False.
- `assets/art/ending_a_rekindle.png` SHA256 `f114241198442b9a8afe513ab3037d26ac656a4c253abe25f6f0e675ae4cd325`.
- `assets/art/ending_b_dawn.png` SHA256 `beb8b274ce41ce859759c27354fa94aaa7ba0cf6a24c87f7c08998d05f74ea8d`.

## Validation and recovery status

Prior Briar/copy work was already committed in710c798 when this recovery task began. Verified it is an ancestor of current HEAD, mapping/candidate/provenance paths clean, only its two explicitly authorized runtime entries differ from the earlier snapshot and every old PNG hash remains equal. Reopened actual C02 cleaned-canopy and C05 jar-revealed proof. No duplicate publication or rewrite of that batch.

E1: make art-test20 pass; targeted ending and sprite_visual suites pass; rendered actual test_ending.gd85checks pass with --audio-driver Dummy. Custom headless harness asserts actual Ending choice branches fallback=false, texture1920x1080 and correct exact direct paths; all three sprite kinds attach and every frame image loads, Corrow4/2/4 and fade nonloop. make lint passes. Required editor image import ran with --headless --audio-driver Dummy so direct TextureRect ResourceLoader can resolve fresh PNGs; generated import/UID sidecars are not staged.

All prior input kind/scale-group/sheet records, runtime entries and ALL prior assets PNG hashes compare unchanged against pre-E1 snapshots. Source origins remain unchanged. Existing texture metadata is preserved via the unchanged cutter in a temporary output directory. No UI/actor/gameplay/normative/source-original/protected-staging edits, no broad test gate or push. New B01 candidates/handoff remain deferred and untouched; their halo notes must be reviewed before any later acceptance.
