# B01 wax plate and kiln pillar integration — 2026-10-25

Accepted only the plate and pillar candidates reviewed in b01-candidate-review-20261025a.md. That record retains the exact prompts, native generation session, output filenames and hashes. Native image_gen__imagegen model identifier is UNEXPOSED. No regeneration or raw pixel edits. The two candidate originals are committed byte-for-byte with this integration:

- b01_wax_plate_candidate_v20261025a.png: SHA256 efcf8663749e0519b744d2debf50daca8e24f80e3e689ba60e3db168beeb3a99.
- b01_kiln_pillar_candidate_v20261025a.png: SHA256 a2dc86753f77d796443724d18921434a326546e96c0a9dbb73bf487f9fdb4b8e.

Existing cutter 62a82aa native_alpha mode opted in ONLY for these two new sheets; defaults unchanged. One detected pose/row, idle1, 1fps loop; uniform fit76x84 plate and84x84 pillar. Both cell96x96, foot90, anchor48,90, prop:true; rect_h84 plate and96 pillar. No size_override scaling assumption or collider change. Generic pillar contract unchanged. Unique outputs b01_wax_plate_idle.png and b01_kiln_pillar_idle.png.

At alpha >0, >10/255, >25/255 and >127/255, output bounds are plate [10,7,85,91] (75x84), pillar [11,7,86,91] (75x84); feet end at inclusive y90. All nonzero output alpha stays inside these footprints; no rectangular opaque matte, external halo or clipped solid silhouette. Raw sources, cutter source/strip comparison proofs and final strips OPENED. No manual alpha thresholding, trimming, rekeying or image editing.

Actual World cave_1_8 capture OPENED: /tmp/b01-plate-pillar-integrated.png, capture-only white ambient; Dummy audio. Four painted pillars and painted plate visible. A residual tan wax_plate Placeholder rectangle remains behind the painted plate and needs actor-owner review; this mapping does not remove arbitrary actor nodes. Kiln mouth remains known brown fallback: all a/b/c candidates rejected, no mouth mapping published and no repeated image edit requested.

Validation: art-test22 PASS; boss_kilnkeeper, sprite_visual, static_prop_visual three suites PASS; lint PASS. All preexisting runtime entries semantically identical; every preexisting sprite PNG SHA256 identical, verified against /tmp/b01-integration-before.json. Texture records regenerated with existing cutter in /tmp to preserve previous metadata; old texture PNGs untouched. No actor, physics, cutter or normative edits; foreign provenance/staging untouched. No push.
