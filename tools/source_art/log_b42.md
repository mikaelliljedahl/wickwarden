# Batch 42 log (18 images kept)

Prompts: `tools/art_prompts/batch_42.md` (job id in each heading). Backend codex, model `cheapest` (gpt-6-luna, effort medium), one image per job, one AgentTeamForge job per image, idempotency key = job id. Each output is checked byte-identical (SHA-256) against its own session folder under `~/.codex/generated_images/<session>/`, and no hash is duplicated in `tools/source_art/`. Verdicts: ok, weak (why). Nothing was rejected by hand; the owner culls.

Date: 2026-10-24. Producer e.

Reference images: `tools/source_art/ow_props.png` (letter pile, arena lantern), `tools/source_art/ow_structures.png` (cave mouths). No figure in this batch, so the facing and leg rule does not apply.

Attempts: every image was generated once (attempts 1 in AgentTeamForge). No rejected outputs. The first job (`b42_letter_pile_v1`) was the bridge test and went through the same recipe.

Sizes: every sheet came back as 1536x1024, as requested.

Defects not fixed (for the owner's cull): the arena lanterns (all three) came back with a tall, ornate pedestal and foliage instead of the short plain pedestal; the three ash cave mouths came back with green moss and foliage, not ash-grey; the stone cave mouth v1 has rune-like carvings; the letter pile v1 has faint script that looks partly readable.

Single-job note: `cave_mouth_fen_v1` wrote its PNG under the name `cave_mouth_fen_v1.png` in its session folder; the bytes are identical to the `exec-...` file in the same folder, so the copy is the exec file.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `letter_pile_v1.png` | `b42_letter_pile_v1` | `01a16f94-a03c-7343-bdf6-34f2aa58edef` | `exec-53bddfd2-e0f9-4f92-a937-a416f3656a5a.png` | 1536x1024 | `2a96872dd26bf041` | ok (faint script on the letters looks partly readable; ribbon and seal fine) |
| `letter_pile_v2.png` | `b42_letter_pile_v2` | `01a16f98-3097-7ea2-9e94-d2caa548613c` | `exec-6021fdfb-df10-4411-a4c2-2d9313733064.png` | 1536x1024 | `4b1790a33f8d48a7` | ok (minor magenta gaps between paper edges) |
| `letter_pile_v3.png` | `b42_letter_pile_v3` | `01a16f98-306c-7171-887a-813fd9bba6c3` | `exec-7ba42d00-2b12-4da8-a882-61c053bc2092.png` | 1536x1024 | `c60cfa2bf92361b6` | ok (scribbled ink lines, no readable words) |
| `arena_lantern_rekindle_v1.png` | `b42_arena_lantern_rekindle_v1` | `01a16f98-3117-7b41-9664-e93288aa89a0` | `exec-9d3cd5bd-4658-462e-aa1b-31ba9a85300a.png` | 1536x1024 | `99d04869d003168d` | weak (pedestal tall and ornate with foliage, not short and plain; lantern correct) |
| `arena_lantern_rekindle_v2.png` | `b42_arena_lantern_rekindle_v2` | `01a16f98-305d-78c0-9b0b-3e40168678ab` | `exec-47536a23-8d0e-4f84-9f16-0d83389af02d.png` | 1536x1024 | `347d1d854cb647fb` | weak (overgrown tall stone shrine, not a short plain pedestal) |
| `arena_lantern_rekindle_v3.png` | `b42_arena_lantern_rekindle_v3` | `01a16f98-3010-77d2-9454-3220f5338aae` | `exec-d63a1804-6611-4716-8e36-059545660232.png` | 1536x1024 | `493f4514922cb339` | weak (pedestal taller and more ornate than the plain short design; foliage) |
| `arena_lantern_wickwarden_v1.png` | `b42_arena_lantern_wickwarden_v1` | `01a16f98-321d-7522-9992-47084ed49068` | `exec-3e8c902f-96c4-44ef-96dc-03ea1e8f29de.png` | 1536x1024 | `9010da0929558b94` | ok (leafy growth round the pedestal base) |
| `arena_lantern_wickwarden_v2.png` | `b42_arena_lantern_wickwarden_v2` | `01a16f9c-8656-7542-b905-7702c50b4918` | `exec-a660f040-f957-431c-bba5-6ec31fc8dc75.png` | 1536x1024 | `cdd58d35c80229d4` | ok |
| `arena_lantern_wickwarden_v3.png` | `b42_arena_lantern_wickwarden_v3` | `01a16f9c-8587-71b1-9b31-81991042be0b` | `exec-4d31c959-dd33-4712-917a-17e0d9a6db67.png` | 1536x1024 | `d6b03e3108b81e8c` | ok (uneven magenta tone; hooks and foliage edges close to the key) |
| `cave_mouth_ashen_v1.png` | `b42_cave_mouth_ashen_v1` | `01a16f9c-83d5-7ea3-881d-00bcda70041c` | `exec-240842eb-020a-4477-83a8-49cbabfdc158.png` | 1536x1024 | `9e8753d23740b582` | weak (heavy green moss on top, not ash-grey and soot) |
| `cave_mouth_ashen_v2.png` | `b42_cave_mouth_ashen_v2` | `01a16f9c-8338-7c42-a840-8c7a1123e37f` | `exec-eeb7dfd4-f5eb-458a-91fd-90c026fbf98e.png` | 1536x1024 | `a0d40ec02b7ef5ef` | weak (lush bright green foliage; rocky path out of the mouth) |
| `cave_mouth_ashen_v3.png` | `b42_cave_mouth_ashen_v3` | `01a16f9c-84fd-7892-9e82-6764c1340c98` | `exec-ebf14d8e-7c2e-49bf-9ae7-aa2071539525.png` | 1536x1024 | `03c3da8f1730f1a6` | weak (rock and moss greener than the faded ash-grey variant) |
| `cave_mouth_fen_v1.png` | `b42_cave_mouth_fen_v1` | `01a16f9c-8394-75f1-aa9b-293e207bcc70` | `exec-e10b7c8d-372a-45dc-9a6f-2e7a0ef60e0c.png` | 1536x1024 | `d1868b928d7859f9` | ok (tunnel fills much of the frame; file name written by the job, bytes equal to the exec file) |
| `cave_mouth_fen_v2.png` | `b42_cave_mouth_fen_v2` | `01a16fa0-834c-7701-af89-2d60712a7f63` | `exec-19a9543e-84fe-4d17-be20-a471a7844671.png` | 1536x1024 | `3975dd1f399df051` | ok (reeds and cattails denser than the brief) |
| `cave_mouth_fen_v3.png` | `b42_cave_mouth_fen_v3` | `01a16fa0-821d-7421-a249-a72b2fd1c9af` | `exec-a92544cf-693d-4c33-89d0-386eb9155291.png` | 1536x1024 | `b0b5530271933a5e` | ok |
| `cave_mouth_stone_v1.png` | `b42_cave_mouth_stone_v1` | `01a16fa0-83a3-71b0-ad1b-d66c9138dee1` | `exec-546a0d3f-6483-4fba-8556-db5d57d22961.png` | 1536x1024 | `81fae4e7ecddcd0e` | weak (rune-like carvings on the arch, not plain bands) |
| `cave_mouth_stone_v2.png` | `b42_cave_mouth_stone_v2` | `01a16fa0-8229-7eb1-a1f4-c88dbbcc1be9` | `exec-67cdc037-2b03-48ea-8018-4395e64b4aae.png` | 1536x1024 | `69b67b439fde9c52` | ok |
| `cave_mouth_stone_v3.png` | `b42_cave_mouth_stone_v3` | `01a16fa0-821f-7ab2-8bf5-fda210f021d9` | `exec-263606ac-c61a-4456-b114-a396a9b6dcb3.png` | 1536x1024 | `29a68f34194972b9` | ok (zigzag ornament on the arch bands; slightly jagged foliage edges) |

## Batch 42 totals

18 images kept and verified. Verdicts: 11 ok, 7 weak (3 arena lanterns rekindle, 3 ash cave mouths, stone cave mouth v1). SHA-256 matches the own-session folder for every file; no duplicate hashes in `tools/source_art/`.
