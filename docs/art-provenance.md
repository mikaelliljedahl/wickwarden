# Wickwarden — art provenance

This is a work inventory, not a legal certificate. All raster art in this repository is original to
Wickwarden. It was generated with GPT Image (the native image generation tool of the Codex CLI)
from the project's own written prompts in [art-brief.md](art-brief.md), then cut by
`tools/cut_sprites.py` without destructive edits ([asset-contract.md](asset-contract.md)). No images
from other games, publishers or third-party asset packs are included, and no prompt names another
game, franchise or artist. A commercial release still needs a review of the image generator's terms.

The procedural parts (the swing trail in `scripts/art/swing_trail.gd`, the contact shadows, the
step-1 `Placeholder` shapes, the HUD hearts, and the pond banks and ruin wall faces in
`assets/shaders/`) are hand-written code. The two terrain shaders only mask, shade and combine the
GPT Image terrain textures below; they add no other image.

## How the sources were made (2026-10-22)

- Each sheet came from one prompt: the shared block, the sheet block (or the texture block) and the
  sheet description from `art-brief.md`. The Tamsin swing and states sheets used the accepted
  `tamsin_walk.png` as a reference image. `hush_duskmoth_fly.png` used a crop of the accepted rest
  pose as its reference.
- The Codex jobs ran through AgentTeamForge. The Codex model drives the tool call; the image model
  is the same at every tier. The tool did not show a model version or a generation ID. The IDs
  below are the output file names that the tool wrote under `~/.codex/generated_images/<session>/`,
  and each source file below is byte-identical to that output (SHA-256 checked).
- Per-sheet prompts, attempts and reviews are in `tools/source_art/log_*.md`. Two Codex agents
  stopped in a daemon fault before they wrote a log. For those sheets (`items`, `fx_explosion`,
  `tamsin_walk`) the lead session reviewed the outputs and wrote the log; their exact prompt text is
  not recorded.
- `tex_pond_bank` and `tex_wall_ruin_face` came later (terrain pass, same day) from one Codex job at
  tier `cheapest`, one attempt each. The wall face prompt used the face block in `art-brief.md`,
  and its log names `tex_wall_ruin.png` as the reference image. Full SHA-256:
  `tex_pond_bank.png` `07448dcf0d67fd325271131bf6681b73615800c60fae60be681239e831a725d1`,
  `tex_wall_ruin_face.png` `dae6d22650c92bb18baa02da52c576374a93bf7d25b00c64c9490ffa03b47456`.
- The v2 walk sheets (`tamsin_walk_{down,up,side}`, `hush_hollow_walk_{up,side}`) replace the walk rows
  of `tamsin_walk.png` and `hush_hollow.png` in the game. `tamsin_walk.png` stays as the design and scale
  reference, and `hush_hollow.png` still supplies `hollow_walk_down`. The v2 sheets are one row of four
  poses each; the logs say the tool showed no session or call ID, so the IDs below are the output file
  names the logs record, each checked byte-identical (SHA-256) against `~/.codex/generated_images/<session>/`.
- Batches 1 to 3 (2026-10-24, Tamsin tool and mitts sheets, 42 images `tamsin_{wick_cast,sling_shot,raft_ride,mitts_*}[_facing]_v1..v3`) came from one Codex job per image at tier `cheapest`, prompts from `tools/art_prompts/batch_01.md` to `batch_03.md`. Each file was checked byte-identical against the png in its own job's session folder, and no two files share a hash. All variants are kept until the owner culls; the log lists defects (the pull and push `down` sheets face sideways).
- No source image was resized or edited by hand. The textures and some sheets are 1254×1254 or
  2172×724 because the tool returned those sizes.

## Source inventory (`tools/source_art/`)

| Source | Size | Codex session | Output ID | SHA-256 (first 16) | Log |
|---|---|---|---|---|---|
| `tamsin_walk.png` | 1536×1024 | `01a16359-9f80-7e42-93b5-d7b5535ab87d` | `exec-a228f8cc-9891-4257-adfb-23a106886ef4` | `ac407e2a49af4cc8` | `log_tamsin.md` |
| `tamsin_swing.png` | 1536×1024 | `01a16363-440a-74d2-ac5c-d662b76c91b5` | `exec-49b5c221-47fe-4919-a34b-81d63fd7bcfd` | `3d7157c3128cdf41` | `log_tamsin_swing.md` |
| `tamsin_states.png` | 1536×1024 | `01a1636a-1d13-7303-b557-c416fbf242c6` | `exec-78ee1f0d-2c43-44fa-a538-da9934b00cb3` | `a0ed3d836c9f4158` | `log_tamsin_states.md` |
| `hush_spitcap.png` | 1536×1024 | `01a16348-22aa-7612-807c-52cc7627ae46` | `exec-93fc076b-dda6-44ef-b9cd-17ac2870b6dd` | `2fa5d61de61ba4c6` | `log_hush.md` |
| `hush_skitterwick.png` | 1536×1024 | `01a16348-22aa-7612-807c-52cc7627ae46` | `exec-d89030b4-a116-4a15-b872-196500a68773` | `2acfb658494b5a15` | `log_hush.md` |
| `hush_duskmoth.png` (rest row only) | 1536×1024 | `01a16348-22aa-7612-807c-52cc7627ae46` | `exec-cf5d74ad-795f-4a78-8b43-3abe36048c59` | `5129244fc1196541` | `log_hush.md` (redo) |
| `hush_duskmoth_fly.png` | 2172×724 | `01a16359-bcd7-7cb2-b5d7-36bbd1f3e080` | `exec-dadffb6c-9533-4aaf-a846-a47aa4f3cf98` | `adedd3ac9da9b4d9` | `log_items_b.md` |
| `hush_tallow.png` | 1536×1024 | `01a16348-22aa-7612-807c-52cc7627ae46` | `exec-558e66a8-f7d9-4b29-abdb-8dd848eb56cc` | `d038bd036e7d5acd` | `log_hush.md` |
| `hush_hollow.png` | 1536×1024 | `01a16348-22aa-7612-807c-52cc7627ae46` | `exec-4f2a0da6-7510-4d04-a06c-798c56daf177` | `b61382edd67d0740` | `log_hush.md` |
| `items.png` | 1536×1024 | `01a16348-2fcb-7dc3-98c1-e9677be62bcc` | `exec-c8e268cb-9ffa-444e-81fe-a714ebf87779` | `c79698c4500937bf` | `log_items.md` |
| `fx_explosion.png` | 1536×1024 | `01a16348-2fcb-7dc3-98c1-e9677be62bcc` | `exec-5d715b52-6c9d-4787-bac4-f293e3667833` | `553c92be97816e17` | `log_items.md` |
| `pickups.png` | 2172×724 | `01a16359-bcd7-7cb2-b5d7-36bbd1f3e080` | `exec-b1c5cf4a-9157-4467-88eb-d8fe72be2642` | `09120639c9505fb9` | `log_items_b.md` |
| `braziers.png` | 2172×724 | `01a16359-bcd7-7cb2-b5d7-36bbd1f3e080` | `exec-104a1402-c0b9-4679-96c7-0ed7652a2eba` | `0752af0a20ff6f6a` | `log_items_b.md` |
| `ow_props.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-01be40f6-41b1-4e2b-a549-16021f0624cf` | `4ff429f6b88ebcda` | `log_world.md` |
| `ow_structures.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-8dceb917-15d4-43bc-bb25-221ca3f0eba9` | `5a8016b5408a3f95` | `log_world.md` |
| `cave_exit.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-b4992961-d01d-465e-93d2-18e1c848aeb8` | `7fcc69abaf63abd7` | `log_world.md` |
| `tex_ground_grass.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-38a7a673-beec-4b51-bc49-6a13742cefac` | `cfd8c9bf2f62e13e` | `log_world.md` |
| `tex_wall_hedge.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-5eaf1d55-ee45-465e-855a-81788d891d9e` | `2b9d46d74a15e536` | `log_world.md` |
| `tex_wall_ruin.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-960e353e-ef46-4b35-9117-ef82969655ec` | `9bdce487357a46da` | `log_world.md` |
| `tex_water.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-8dd28f5d-e18c-41af-ab39-3b23e316eac1` | `e2be33fa288ffcd6` | `log_world.md` |
| `tex_ground_cave.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-03f3e9c5-a5a3-4919-a665-86916a86a647` | `1c649df700c17b8f` | `log_world.md` |
| `tex_wall_cave.png` | 1254×1254 | `01a16348-3d13-7a42-8be4-1450d98d7fc9` | `exec-a1bf1da6-551a-4089-b53b-6df41d9533ae` | `6446404de64b0241` | `log_world.md` |
| `tamsin_walk_down.png` | 1536×1024 | `01a163ed-5cf5-7ea0-a18c-6213dc71318e` | `exec-2a3c4827-3e06-4915-8b1d-ae993820826e` | `192995d81e4d6370` | `log_tamsin_walk_v2.md` (redo) |
| `tamsin_walk_up.png` | 1536×1024 | `01a163e1-bc66-7452-b66f-4edae8fc1e8f` | `exec-98d28a3d-da49-4e07-ab01-c720198b562e` | `beda31ec2e7a0416` | `log_tamsin_walk_v2.md` |
| `tamsin_walk_side.png` | 1536×1024 | `01a163e1-bc66-7452-b66f-4edae8fc1e8f` | `exec-3281d230-6aa4-4f66-9ad3-77024638e612` | `1645331b48336e6a` | `log_tamsin_walk_v2.md` |
| `hush_hollow_walk_up.png` | 1536×1024 | `01a163e2-105c-7f63-a1f6-19f0996eb728` | `exec-a095ea5a-b3bd-4fc6-8626-d6be6b9d3572` | `f17f8c4cfd2e161c` | `log_hollow_walk_v2.md` |
| `hush_hollow_walk_side.png` | 2172×724 | `01a163e2-105c-7f63-a1f6-19f0996eb728` | `exec-0657a715-9683-4c6d-a9dd-f51a862f855b` | `3d937390de9276ad` | `log_hollow_walk_v2.md` |
| `tex_pond_bank.png` | 1254×1254 | `01a163da-a933-7313-9e9a-43e7e436266e` | `exec-5ce69000-6ba2-4781-b41d-ae1d36510bf7` | `07448dcf0d67fd32` | `log_terrain.md` |
| `tex_wall_ruin_face.png` | 1254×1254 | `01a163da-a933-7313-9e9a-43e7e436266e` | `exec-38baea37-8d44-45c4-82d6-1d08749b7e79` | `dae6d22650c92bb1` | `log_terrain.md` |
| `tamsin_jar_throw_side_v1.png` | 1536×1024 | `01a16f3d-b1e0-7e62-9743-164b7921a6ff` | `exec-8c33c7bc-083f-4c34-8570-62873fdd051c` | `bcab6b770a35d5b7` | `log_b04.md` |
| `tamsin_jar_throw_side_v2.png` | 1536×1024 | `01a16f3c-42c7-7e22-bd57-9e4d369f5773` | `exec-6186b9ed-72b2-416f-b827-33ef6c9eb3c8` | `d2780525d7f32058` | `log_b04.md` |
| `tamsin_jar_throw_side_v3.png` | 1536×1024 | `01a16f3c-4381-7003-ab2b-29391549a0c6` | `exec-9c0909ad-ad31-431c-aa07-f7b1ac8f8647` | `50ecdc1c425ad812` | `log_b04.md` |
| `tamsin_chime_ring_side_v1.png` | 1536×1024 | `01a16f3c-465d-7d92-aafd-ad25d93952ca` | `exec-555a5320-e94b-41cc-adeb-5a8d9ac123f3` | `2809da7aca5b1d6a` | `log_b04.md` |
| `tamsin_chime_ring_side_v2.png` | 1536×1024 | `01a16f3c-4c31-7e51-8819-5c9e1b57208f` | `exec-d067f67f-061d-4df3-be30-88198a3edf5c` | `aa31a053805ec74d` | `log_b04.md` |
| `tamsin_chime_ring_side_v3.png` | 1536×1024 | `01a16f3c-4ee9-7211-9671-db563d1cff52` | `exec-7a13e90d-4bf5-4ef5-911d-8dc6b729e0b4` | `66fc490de351158b` | `log_b04.md` |
| `tamsin_chime_hold_side_v1.png` | 1536×1024 | `01a16f3c-5304-7f72-a4d9-a7db9354c4bd` | `exec-dc9bc7ae-9fe0-4a00-8a7d-7e3039f5abdb` | `6e511aa424d66458` | `log_b04.md` |
| `tamsin_chime_hold_side_v2.png` | 1536×1024 | `01a16f3d-b1d0-7f60-95a4-266c61dada84` | `exec-5933ff96-b687-49d8-9a0f-4db07f530012` | `0c7cfc4a43bae8ab` | `log_b04.md` |
| `tamsin_chime_hold_side_v3.png` | 1536×1024 | `01a16f3d-b183-7e22-902e-5e3711f5fb32` | `exec-45e3084e-2597-4544-874f-44d98caca56f` | `4a4ec153ced41e1e` | `log_b04.md` |
| `tamsin_leap_side_v1.png` | 1536×1024 | `01a16f3d-b52e-7001-b7ef-1cb1f6860040` | `exec-bf6093c8-8015-46e5-a0b7-21eec7e768a1` | `177fd857d1746d23` | `log_b04.md` |
| `tamsin_leap_side_v2.png` | 1536×1024 | `01a16f3d-b96c-75f3-bb6e-08b99a0bf73c` | `exec-73c2e600-eb9b-4580-8896-2faa7167ba80` | `1a2b45e449691917` | `log_b04.md` |
| `tamsin_leap_side_v3.png` | 1536×1024 | `01a16f3d-bd4c-7dd0-8f1b-04bf4a7dc356` | `exec-0a48aab8-bc59-4bb7-8dbe-72e8d81f72ac` | `38cf2470aa12b87f` | `log_b04.md` |
| `tamsin_reel_fire_side_v1.png` | 1536×1024 | `01a16f3f-a85c-7342-a3f4-66433abdb921` | `exec-78230346-1084-46cf-8f1c-d7bb6bb96e9e` | `3e6bfd32cf5bf0a9` | `log_b04.md` |
| `tamsin_reel_fire_side_v2.png` | 1536×1024 | `01a16f3f-a8bc-7f70-91c0-e4d11511306b` | `exec-f305c791-a25f-4abe-b397-21dcb9a6731b` | `50e8669ed2d7b23b` | `log_b04.md` |
| `tamsin_reel_fire_side_v3.png` | 1536×1024 | `01a16f3f-aa88-7711-b880-a90b6f06459b` | `exec-6785875e-e97c-41df-9ae0-a8aacdd4260d` | `cc6b95835f887260` | `log_b04.md` |
| `tamsin_reel_pull_side_v1.png` | 1536×1024 | `01a16f3f-abbb-7012-bbc3-3a7eea22ad6a` | `exec-034d8c49-07c6-489e-aec7-1bcdf9341bb7` | `c1f7559762041c62` | `log_b04.md` |
| `tamsin_reel_pull_side_v2.png` | 1536×1024 | `01a16f3f-d856-7b80-9047-d79ffe1b105d` | `exec-45f35b1a-b6ec-41ae-8a39-809424acc552` | `1a12d3c09463a268` | `log_b04.md` |
| `tamsin_reel_pull_side_v3.png` | 1536×1024 | `01a16f3f-e01f-79a0-b7a6-1ad55d34e6f3` | `exec-a5cdb636-88e7-4a3d-a782-500abecb8ae2` | `5ee8debe983be2d7` | `log_b04.md` |
| `tamsin_pot_place_side_v1.png` | 1536×1024 | `01a16f42-8249-7580-987d-a079218eaaeb` | `exec-e7083352-9e3a-46f3-b90b-61a8e605b9ff` | `2dfeea16c3aa79ca` | `log_b05.md` |
| `tamsin_pot_place_side_v2.png` | 1536×1024 | `01a16f42-843b-7860-8758-340c212f24b4` | `exec-36fbc6a5-ca19-4718-8c89-63806dc09d01` | `f7c4cfed93af9234` | `log_b05.md` |
| `tamsin_pot_place_side_v3.png` | 1536×1024 | `01a16f42-858d-7852-a404-a14e3a1ff8f4` | `exec-5da7cadf-5d4b-4a4f-a764-fd7a05e41c00` | `f79c7e144301ab16` | `log_b05.md` |
| `tamsin_moth_throw_side_v1.png` | 1536×1024 | `01a16f42-8c26-7583-97ba-82606b98f0be` | `exec-bbcc4491-bcec-4ee6-a9ae-ebb29183af36` | `ba7eb0c25d07886f` | `log_b05.md` |
| `tamsin_moth_throw_side_v2.png` | 1536×1024 | `01a16f43-36b6-7721-836f-64693acfbec8` | `exec-16a2d73e-6f41-4ceb-9c99-760e0bfde8df` | `50016cac3df6866b` | `log_b05.md` |
| `tamsin_moth_throw_side_v3.png` | 1536×1024 | `01a16f43-37a6-7c92-92d5-bce06b81c052` | `exec-542a4c72-5237-4850-a906-9fa31e98ef05` | `10cb670c3bebd50f` | `log_b05.md` |
| `tamsin_item_get_down_v1.png` | 1536×1024 | `01a16f43-e23b-7161-8f0f-b1321851ea1e` | `exec-b0a4ade4-6591-43ef-9358-4b7f3c565d27` | `e4395182529977b1` | `log_b05.md` |
| `tamsin_item_get_down_v2.png` | 1536×1024 | `01a16f43-e1dc-7f13-94f5-99cb157870cf` | `exec-7f8d6a18-ba09-4170-9270-8765a9164fc6` | `b3570c55a942dbd7` | `log_b05.md` |
| `tamsin_item_get_down_v3.png` | 1536×1024 | `01a16f43-e2b8-7801-8cb9-6b15c557aaf2` | `exec-bd7d1263-102a-4497-9dd5-35116f254dfe` | `b67646e6d6000bb4` | `log_b05.md` |
| `tamsin_flask_drink_down_v1.png` | 1536×1024 | `01a16f43-e28f-7263-baa9-0f8decdda214` | `exec-aa814c6f-cae9-4000-9020-10ccb78d861c` | `a0251feeb4acf148` | `log_b05.md` |
| `tamsin_flask_drink_down_v2.png` | 1536×1024 | `01a16f44-9b25-77f2-9eb0-2a843fe6ba24` | `exec-60533fc7-f5d6-4902-b117-f7a2de99f07d` | `2eef147515ee4353` | `log_b05.md` |
| `tamsin_flask_drink_down_v3.png` | 1536×1024 | `01a16f44-ebeb-7771-b5a5-1e3b843f6d61` | `exec-fbfa7c9b-3d1e-4c06-97d0-9966d8a5acda` | `8642dbb96000e2da` | `log_b05.md` |
| `tamsin_pit_fall_down_v1.png` | 1536×1024 | `01a16f44-ec7c-7de1-a27f-c52a554bde6d` | `exec-fd81678d-3c1f-4443-86b3-d8e968df55e4` | `6667b6c170cdcd68` | `log_b05.md` |
| `tamsin_pit_fall_down_v2.png` | 1536×1024 | `01a16f44-eee9-7f82-8634-c2883989a978` | `exec-42577b15-b52f-4c2c-9a4d-af93f617653b` | `6c0ea430d8151439` | `log_b05.md` |
| `tamsin_pit_fall_down_v3.png` | 1536×1024 | `01a16f44-f5c6-7262-8a8a-4f8a9cc7516c` | `exec-26bca2b5-2194-439e-b40e-fb4acd55fa69` | `eee6856ba3d9097c` | `log_b05.md` |
| `tamsin_death_down_v1.png` | 1536×1024 | `01a16f45-11f1-7551-a7fb-5371e83e62f8` | `exec-c59f3e30-dc57-4ded-9786-67e5bafcde02` | `4abf7af1ceeebd39` | `log_b05.md` |
| `tamsin_death_down_v2.png` | 1536×1024 | `01a16f45-f1ce-7432-a036-19378909b147` | `exec-0f9d74c0-8de6-4e63-ab69-9cd638cda9ed` | `8c07cfcdcce53e80` | `log_b05.md` |
| `tamsin_death_down_v3.png` | 1536×1024 | `01a16f46-645f-71f3-9bed-fc0a57c8a702` | `exec-e8a9e154-971d-43e9-9b35-6c5a462b6cc7` | `efe562dfbd4af6c5` | `log_b05.md` |
| `tex_path_dirt_v1.png` | 1254×1254 | `01a16f47-fae9-7101-be31-0f2a2c7a9d77` | `exec-5155efd5-529b-41b7-9385-ae9aa9eefccc` | `96af9a4e2451cdcb` | `log_b06.md` |
| `tex_path_dirt_v2.png` | 1254×1254 | `01a16f47-fac5-7e12-bcd1-1d6fc2feaa41` | `exec-00865aeb-a61d-4c66-abd4-ea5d91d35b96` | `07a04221e035fce0` | `log_b06.md` |
| `tex_path_dirt_v3.png` | 1254×1254 | `01a16f47-fb3d-7df2-885a-e807994087ec` | `exec-26f378ad-67c1-4b19-ada2-8af5ac3fed5c` | `b720467106bf5386` | `log_b06.md` |
| `tex_ground_garden_v1.png` | 1254×1254 | `01a16f47-fcc8-71e3-ad59-a0096cda5597` | `exec-76cbdf21-0199-4df4-a6cf-bcac854c99c9` | `6f638afb976383de` | `log_b06.md` |
| `tex_ground_garden_v2.png` | 1254×1254 | `01a16f48-0227-7b02-ad16-d9fe544c41fc` | `exec-eb01b660-87bf-44a7-87df-bc0980f36173` | `333c55c26fde16f2` | `log_b06.md` |
| `tex_ground_garden_v3.png` | 1254×1254 | `01a16f48-045a-77b3-8076-52debec9767f` | `exec-11d8134a-0e65-48ee-99df-db0b204b8262` | `ae1a74f0ea3182a5` | `log_b06.md` |
| `tex_ground_thornwood_v1.png` | 1254×1254 | `01a16f49-295e-7252-97a2-1b2acef2900d` | `exec-1a28295b-d894-4b69-9773-69455beb2a93` | `657a8de1b5174cc6` | `log_b06.md` |
| `tex_ground_thornwood_v2.png` | 1254×1254 | `01a16f49-4d34-7543-b1a3-45cd66c1b174` | `exec-82f70aef-70db-4c6f-81b0-3961a4b009fc` | `b7d53f218972686e` | `log_b06.md` |
| `tex_ground_thornwood_v3.png` | 1254×1254 | `01a16f49-57ef-7ec2-a8b0-32c97b960697` | `exec-ac7cb018-9559-4574-be6a-6c60054796c7` | `1a95c528f25d4601` | `log_b06.md` |
| `tex_wall_thorn_v1.png` | 1254×1254 | `01a16f49-675a-75f1-aea4-1b644f7eece2` | `exec-823ba156-fee5-441d-9411-6744ec0c3212` | `721ce87471b8ebc6` | `log_b06.md` |
| `tex_wall_thorn_v2.png` | 1254×1254 | `01a16f49-844e-7852-90be-df2b14f0b463` | `exec-e1deb925-fc7f-4f92-9020-98593e3e4b76` | `72b219a049978f74` | `log_b06.md` |
| `tex_wall_thorn_v3.png` | 1254×1254 | `01a16f49-853c-7350-b3a4-1c0f69cd797f` | `exec-bbf5fd61-bf83-483a-bd34-d02057291114` | `921c139cce5d5c51` | `log_b06.md` |
| `tex_path_forest_v1.png` | 1254×1254 | `01a16f4a-b17a-7ef2-b44d-314ab1a8bbe2` | `exec-2a7f5ff1-dfc5-47c0-998b-0f791f71055e` | `82e72ea61bf147e9` | `log_b06.md` |
| `tex_path_forest_v2.png` | 1254×1254 | `01a16f4a-b3f8-7c83-baf0-a43de3c104a9` | `exec-cea18ccc-e171-43ee-bd74-c04d5da52d16` | `a12721f3979b32b2` | `log_b06.md` |
| `tex_path_forest_v3.png` | 1254×1254 | `01a16f4a-b6b9-7930-9e1e-865db15d1d3f` | `exec-3d7bb7c9-8831-448a-973a-554c649b67bc` | `4288640309fc8764` | `log_b06.md` |
| `tex_ground_ash_v1.png` | 1254×1254 | `01a16f4b-3d9b-71c3-bac2-32854d1ca25a` | `exec-965b5fc1-cd93-4188-b0c9-a825a7ae17c6` | `93e35844eb2e7a48` | `log_b06.md` |
| `tex_ground_ash_v2.png` | 1254×1254 | `01a16f4b-3d14-7af0-bace-cf1119141ffd` | `exec-7d3c13cd-3fd7-4826-9967-328464cc0c18` | `254b6a0fa763eeb3` | `log_b06.md` |
| `tex_ground_ash_v3.png` | 1254×1254 | `01a16f4b-41bf-7001-bc93-baa244663f79` | `exec-0d3c167d-97c4-453b-9e35-9d60269ba550` | `ea49628eb618cba7` | `log_b06.md` |
| `tex_ground_slag_v1.png` | 1254×1254 | `01a16f4d-408e-7260-a9f7-4a2302050ae0` | `exec-aff70e02-d0be-479b-8423-0a3f335a9a2a` | `21e7f9c52bbdf063` | `log_b07.md` |
| `tex_ground_slag_v2.png` | 1254×1254 | `01a16f4d-42d4-71e0-bd0d-d08811ac811a` | `exec-67eff0e4-72f5-4097-902f-ebfe43ce42fc` | `03fe6ce9b94180fe` | `log_b07.md` |
| `tex_ground_slag_v3.png` | 1254×1254 | `01a16f4d-47e8-7770-bef0-df9562968263` | `exec-54138882-f54c-424e-b52a-370bf07fbf80` | `78cc49a1570b5d59` | `log_b07.md` |
| `tex_wall_cinder_v1.png` | 1254×1254 | `01a16f4d-4c44-79c0-99a1-ccad9bcd921f` | `exec-360f2de5-1ca1-4afe-bdcd-8ae054353e13` | `e8d7a1ac2774df93` | `log_b07.md` |
| `tex_wall_cinder_v2.png` | 1254×1254 | `01a16f4d-5049-79f1-b978-af44c42335f0` | `exec-27af29c5-1f99-4bf7-a66c-3ac2b81c2cd8` | `6448b19c05428147` | `log_b07.md` |
| `tex_wall_cinder_v3.png` | 1254×1254 | `01a16f4d-5473-7113-9e64-e580ceb3f9b2` | `exec-570a32bb-e8bf-4340-8c01-ec4e9a4bb9cd` | `2a961887057206e6` | `log_b07.md` |
| `tex_wall_cinder_face_v1.png` | 1254×1254 | `01a16f50-2390-72c3-b82c-a3c7130804da` | `exec-44a209fb-175e-4435-a6a0-ab0f580ec8f0` | `8b2bac5718543d71` | `log_b07.md` |
| `tex_wall_cinder_face_v2.png` | 1254×1254 | `01a16f50-2264-7222-9d8c-1b5eda357eba` | `exec-b1b121b2-cb86-4c13-b334-7cb463dce312` | `670bb4c057662681` | `log_b07.md` |
| `tex_wall_cinder_face_v3.png` | 1254×1254 | `01a16f50-2401-7960-8214-a171d3682b59` | `exec-9f918cf9-643f-4309-b1a7-99e9f3cb6316` | `a99ec1550c91898d` | `log_b07.md` |
| `tex_ground_fen_v1.png` | 1254×1254 | `01a16f4e-bbcf-7e03-bbec-6f5f1289f7c7` | `exec-816581dd-3a2d-471b-83d4-4f48f3fd0ad6` | `4bdb81b2353cd37e` | `log_b07.md` |
| `tex_ground_fen_v2.png` | 1254×1254 | `01a16f4e-bc5e-7c60-b135-aa38ed7e9826` | `exec-e6f4a3af-7df4-4b43-9bf2-effbf7f84fb8` | `f49b33e231b7a5a0` | `log_b07.md` |
| `tex_ground_fen_v3.png` | 1254×1254 | `01a16f4e-be12-75a0-bfbd-6bc4d8b3d1ec` | `exec-fe1e66e1-70d9-4be9-bb91-50fcf5fc4a22` | `38bc4a3fe5c19e33` | `log_b07.md` |
| `tex_boardwalk_planks_v1.png` | 1254×1254 | `01a16f4e-c43e-7452-bcaf-fc5358f68207` | `exec-f41e86a3-4545-439f-b26b-6c480055aa74` | `68866b9e045158d4` | `log_b07.md` |
| `tex_boardwalk_planks_v2.png` | 1254×1254 | `01a16f4e-d1f9-7b02-a05c-2a8be34e73af` | `exec-629742a5-127d-4234-a1f4-e3e473f89254` | `c885ecc38736a245` | `log_b07.md` |
| `tex_boardwalk_planks_v3.png` | 1254×1254 | `01a16f4e-d287-7100-bc74-b60031b9e4aa` | `exec-a193997d-205c-487e-b8db-cf4e3b51d730` | `3be377590be2f31b` | `log_b07.md` |
| `tex_water_lake_v1.png` | 1254×1254 | `01a16f50-82f6-73d3-8d86-6aed085d626f` | `exec-bc4eb9d8-2e1f-495b-94e1-ea94c6ae45fa` | `4e49e99f1b676dae` | `log_b07.md` |
| `tex_water_lake_v2.png` | 1254×1254 | `01a16f50-9987-7d81-a010-a9753813db6a` | `exec-ad56c03c-5cc0-4056-888b-ac9d39525bd2` | `f1c4ce69d734bf96` | `log_b07.md` |
| `tex_water_lake_v3.png` | 1254×1254 | `01a16f50-a068-77c3-999f-d769f74958aa` | `exec-9688e347-9aac-46d3-b45e-0017d96b94ae` | `137a01c39b897fed` | `log_b07.md` |
| `tamsin_wick_cast_v1.png` | 1536×1024 | `01a16f29-722a-7593-af8d-4a8c2e7f801f` | `exec-b4fec007-f485-4e1d-a82f-3c9545296540` | `6494a3e8b13860f5` | `log_b01.md` |
| `tamsin_wick_cast_v2.png` | 1536×1024 | `01a16f2c-6e9f-7fe1-bb6f-2f797b5c27fd` | `exec-e11541d3-01b0-4822-b044-c5c540724195` | `02cb0742304a38c6` | `log_b01.md` |
| `tamsin_wick_cast_v3.png` | 1536×1024 | `01a16f2c-75af-7402-a9f7-949a18c2583d` | `exec-d151e71f-3417-42ec-bb60-edc21bacac43` | `fab2e4ac05c31eb2` | `log_b01.md` |
| `tamsin_sling_shot_v1.png` | 1536×1024 | `01a16f2c-800f-7463-bb4a-a64abc004728` | `exec-df3ea513-4eea-47db-a5f6-a2206586b3b9` | `a5db6d9883198187` | `log_b01.md` |
| `tamsin_sling_shot_v2.png` | 1536×1024 | `01a16f2c-8999-7980-ac8c-d6616c128f40` | `exec-d40d3eeb-f005-49cc-8098-38248c264c1d` | `5698cd082195a2d5` | `log_b01.md` |
| `tamsin_sling_shot_v3.png` | 1536×1024 | `01a16f2c-933b-7c40-90d6-a2fdc9f8c45b` | `exec-42c16a87-cde6-4564-9942-1473083a6a97` | `4745e7e47cb52ea7` | `log_b01.md` |
| `tamsin_raft_ride_v1.png` | 1536×1024 | `01a16f2c-9d4f-71c0-afef-1fc3eca2ccb8` | `exec-31819aaa-cebe-49a5-b232-f83961ba7b06` | `3a7ad2c6537ec929` | `log_b01.md` |
| `tamsin_raft_ride_v2.png` | 1536×1024 | `01a16f2c-a767-77e1-a31b-9aff1de41c38` | `exec-2b342914-0b74-47db-b79c-b39226ae4cdd` | `6789e27aaa1fe7d0` | `log_b01.md` |
| `tamsin_raft_ride_v3.png` | 1536×1024 | `01a16f2c-b4a1-7ab2-bc80-27e67495f4a9` | `exec-f6327517-7679-4c62-8b4d-6abca9ff156a` | `2d37d06a45c5791f` | `log_b01.md` |
| `tamsin_mitts_lift_v1.png` | 1536×1024 | `01a16f2c-bb5a-7741-a6d1-35f2f07f9a41` | `exec-edbd36d4-04f6-431e-9856-33ae76fb51bb` | `8bce57a7968faf74` | `log_b01.md` |
| `tamsin_mitts_lift_v2.png` | 1536×1024 | `01a16f2c-c5a8-7821-89aa-6bf83d848098` | `exec-09eb02ec-77ef-435d-bb66-b82d06ad9152` | `45cc841faed2b28c` | `log_b01.md` |
| `tamsin_mitts_lift_v3.png` | 1536×1024 | `01a16f2c-cf3c-7230-a9cd-b3b3a7e3cf59` | `exec-99ba7957-1dfa-4338-84c0-9324b17e95c0` | `c28b91dfefff5017` | `log_b01.md` |
| `tamsin_mitts_carry_side_v1.png` | 1536×1024 | `01a16f32-23f8-70b3-bded-65be432b7563` | `exec-bc237e0c-82ce-4a6c-88c4-b861c8d2baf6` | `86918ed018673125` | `log_b02_b03.md` |
| `tamsin_mitts_carry_side_v2.png` | 1536×1024 | `01a16f32-2c74-7f02-a32d-024120bddcc3` | `exec-7cf6b1df-2619-4c31-a245-936b50b58717` | `89e5f4eafc03923f` | `log_b02_b03.md` |
| `tamsin_mitts_carry_side_v3.png` | 1536×1024 | `01a16f32-35ee-7801-9bcd-42603c96ccfe` | `exec-e4cf1d29-6a2c-43ec-b91d-5efb0b2c8c71` | `0c15d908a99ceebe` | `log_b02_b03.md` |
| `tamsin_mitts_throw_v1.png` | 1536×1024 | `01a16f32-3f6d-7110-baef-550a25b9a57f` | `exec-a03be854-6f8a-498d-83be-9b38caa64cf8` | `5712ffaaeeeeda78` | `log_b02_b03.md` |
| `tamsin_mitts_throw_v2.png` | 1536×1024 | `01a16f32-486d-7341-bbc0-7f36780fe8c8` | `exec-dd5bfc83-f904-4ca5-b124-cc0fc5a37145` | `a2b80593089fb8e2` | `log_b02_b03.md` |
| `tamsin_mitts_throw_v3.png` | 1536×1024 | `01a16f32-524a-7f33-bb89-15bbac0a4bb8` | `exec-1ff71a7c-1f68-4685-890d-d7b5be51bf32` | `9a551325e48e4179` | `log_b02_b03.md` |
| `tamsin_mitts_pull_side_v1.png` | 1536×1024 | `01a16f32-5d33-71b1-9fe0-f361c9b53249` | `exec-fd815d2f-50fa-4369-9c59-1564baafe814` | `e8dbec5c07a7fa3f` | `log_b02_b03.md` |
| `tamsin_mitts_pull_side_v2.png` | 1536×1024 | `01a16f32-682d-7171-92c9-4823c5968045` | `exec-e1bbcf20-921e-424a-bf67-52de9f71e7e8` | `a0e9f06b838340b0` | `log_b02_b03.md` |
| `tamsin_mitts_pull_side_v3.png` | 1536×1024 | `01a16f32-7015-7f50-800c-d7ce14ea1ffa` | `exec-41b68609-4e71-43ef-ade0-96e23acab9e8` | `3a3ee6a87a4f3520` | `log_b02_b03.md` |
| `tamsin_mitts_push_side_v1.png` | 1536×1024 | `01a16f32-7a84-7350-842b-1602a4085780` | `exec-fa39cc6b-17ec-43ac-8109-7edb8b5ea79b` | `bdd4892af88d5055` | `log_b02_b03.md` |
| `tamsin_mitts_push_side_v2.png` | 1536×1024 | `01a16f32-84ab-79e0-a888-9f577a152c8a` | `exec-7db553b9-7355-4205-b224-d326756e067f` | `9c05af8f95c612e4` | `log_b02_b03.md` |
| `tamsin_mitts_push_side_v3.png` | 1536×1024 | `01a16f32-8d4b-7600-85c1-ab694cb46dda` | `exec-daa0eb6b-c416-4e3e-9263-e198fb283ea4` | `58ef08baf49b53e0` | `log_b02_b03.md` |
| `tamsin_mitts_carry_down_v1.png` | 1536×1024 | `01a16f37-cc25-7251-b931-4ffbd3b3b7d5` | `exec-c24b46db-14db-4814-a95e-4268d23c2b91` | `848dd78360394bae` | `log_b02_b03.md` |
| `tamsin_mitts_carry_down_v2.png` | 1536×1024 | `01a16f37-cff9-7213-bbb7-54076dce27b3` | `exec-ad510061-57b0-4859-813f-3c775c7252df` | `8d529b8116304693` | `log_b02_b03.md` |
| `tamsin_mitts_carry_down_v3.png` | 1536×1024 | `01a16f37-d8f7-75f1-939a-d67360e21662` | `exec-f6483113-6a69-4e65-9495-5228da7fd3bb` | `358d69f8d1e38afa` | `log_b02_b03.md` |
| `tamsin_mitts_carry_up_v2.png` | 1536×1024 | `01a16f37-eb70-7dd1-a195-72a576f525e5` | `exec-687c229b-6b96-4655-83cd-f16b8701a872` | `bdefec8f6114891d` | `log_b02_b03.md` |
| `tamsin_mitts_carry_up_v3.png` | 1536×1024 | `01a16f37-f583-7c10-bc79-1978ac010d8a` | `exec-2fc254b2-7083-49c0-990f-336bafd104de` | `09de29115c22a440` | `log_b02_b03.md` |
| `tamsin_mitts_pull_down_v1.png` | 1536×1024 | `01a16f38-012b-7372-86f8-8649605f79a7` | `exec-a9e553bd-b49d-44b1-aaa2-1ae45d91c35e` | `fe20b92d0b0581fc` | `log_b02_b03.md` |
| `tamsin_mitts_pull_down_v2.png` | 1536×1024 | `01a16f38-0b26-7273-9c3a-636d2e08e874` | `exec-6a6f8d97-0c94-4062-8170-0e48fb277858` | `e962f125b7ead2c0` | `log_b02_b03.md` |
| `tamsin_mitts_pull_down_v3.png` | 1536×1024 | `01a16f38-13b6-7b00-8391-ff590cb2e191` | `exec-a9865c1d-17e7-4cd6-a23b-cf3866ce1e97` | `029bb02afc2cba97` | `log_b02_b03.md` |
| `tamsin_mitts_pull_up_v1.png` | 1536×1024 | `01a16f38-1d56-74b2-bccf-8b2fd85f71b6` | `exec-2a2cdc52-149b-44e2-80fb-b2d5c73261d6` | `6fd60b5ff5b30bff` | `log_b02_b03.md` |
| `tamsin_mitts_pull_up_v2.png` | 1536×1024 | `01a16f38-24b3-7f41-b934-bf9542174d82` | `exec-1e27d6aa-42c3-4393-8513-2df9be496424` | `10943d77f1b673dc` | `log_b02_b03.md` |
| `tamsin_mitts_pull_up_v3.png` | 1536×1024 | `01a16f38-2f07-7703-aa6f-a656bea468a9` | `exec-a153ffbf-0ac6-4315-9f60-c43e0b35b155` | `d52ecbad8b7362ce` | `log_b02_b03.md` |
| `tamsin_mitts_push_down_v1.png` | 1536×1024 | `01a16f38-377f-7a52-9dfa-8e372bc804f9` | `exec-1ea133f8-aab4-44ba-a2ce-dc364003f2bd` | `7b25f001560e6e0a` | `log_b02_b03.md` |
| `tamsin_mitts_push_down_v2.png` | 1536×1024 | `01a16f38-4079-7391-8281-5d788742bf78` | `exec-f6e0b517-0062-4d42-ad81-e5381ba7684f` | `47d12c88d753f02c` | `log_b02_b03.md` |
| `tamsin_mitts_push_down_v3.png` | 1536×1024 | `01a16f38-4b64-7951-aee5-59bee5643704` | `exec-3cc6f23f-65e9-4968-b133-7500f0a2244f` | `b3a1eab7a9697eb1` | `log_b02_b03.md` |
| `tamsin_mitts_carry_up_v1.png` | 1536×1024 | `01a16f39-4e74-7062-8052-cd947bcf73c5` | `exec-eeb08c6c-f7f1-496c-9832-448e3b392ee1` | `bc8971709d844657` | `log_b02_b03.md` |
| `tamsin_mitts_push_up_v1.png` | 1536×1024 | `01a16f39-56f0-7541-8132-e6324873d36b` | `exec-c3d568b4-71c6-48f9-aca2-0d65179f81b2` | `4244b84345a2f10e` | `log_b02_b03.md` |
| `tamsin_mitts_push_up_v2.png` | 1536×1024 | `01a16f39-60a5-7b53-b041-9482a304ade4` | `exec-466b362d-f999-4b61-bf71-ec4267320538` | `11c5edf714f14564` | `log_b02_b03.md` |
| `tamsin_mitts_push_up_v3.png` | 1536×1024 | `01a16f39-68ff-7010-84fb-f3395e44ebfe` | `exec-c8664233-f552-407d-88b6-1a808229830b` | `7534d81930d15acb` | `log_b02_b03.md` |
| `tex_cave_stone_ground_v1.png` | 1254×1254 | `01a16f3f-8077-7831-a9e6-665c965955db` | `exec-9e714a94-5a7d-467e-a5d5-269cf4ed5d9f` | `eb506d23e3c3dee0` | `log_b12.md` |
| `item_reel_line_v1.png` | 1536×1024 | `01a16f40-bde2-7670-9216-8a21dd3850e5` | `exec-e33de974-b7e8-4038-8ade-411287d50786` | `63bba027b983b72a` | `log_b20.md` |
| `item_reel_line_v2.png` | 1536×1024 | `01a16f40-c3ec-7193-9f3e-a8e50284967f` | `exec-c72e5ae4-8099-4fb2-a0e4-02820c928fa6` | `c672eff8dc5b2714` | `log_b20.md` |
| `item_reel_line_v3.png` | 2172×724 | `01a16f40-ccf9-78f2-9b79-44d1921d0e03` | `exec-16235c85-ecf3-474f-a0e1-62b11102112c` | `4be5e5387988be6a` | `log_b20.md` |
| `icon_base_hook_v1.png` | 1536×1024 | `01a16f40-d24e-7f72-a313-4964436dbb1f` | `exec-32679af6-9f0e-4560-b4fe-559157ba6818` | `5fc024dd106601ff` | `log_b20.md` |
| `icon_base_hook_v2.png` | 1536×1024 | `01a16f40-da0e-7e42-b1c3-f5b9df34e757` | `exec-b7f115d2-634d-4b05-ba63-411b1722c723` | `4f90c01887a31c60` | `log_b20.md` |
| `icon_base_hook_v3.png` | 1536×1024 | `01a16f40-e178-76a1-b9bd-6a24ac14c5d2` | `exec-e7456958-8178-4453-a00a-969c6da3c6a3` | `6025b7b2a9314a78` | `log_b20.md` |
| `icon_base_flare_v1.png` | 1536×1024 | `01a16f42-6978-7f03-96cd-de43fba3da02` | `exec-e870d9a3-9064-44e1-974a-d281a8b2638f` | `b7f75038e9fb22c8` | `log_b20.md` |
| `icon_base_flare_v2.png` | 1536×1024 | `01a16f42-6aed-75c0-b84f-48f10f1f5c09` | `exec-9b5eef8e-c115-424b-84b8-13c325f4c0d2` | `cf4b00411dff5e7b` | `log_b20.md` |
| `icon_base_flare_v3.png` | 1536×1024 | `01a16f42-7155-7a43-8687-9abb992746c3` | `exec-15edd181-1c02-4167-b91a-8e21b8bde366` | `7f70cf96c46fd9e3` | `log_b20.md` |
| `icon_base_ward_v1.png` | 1536×1024 | `01a16f42-7aa4-7512-a5f4-41363cb4c407` | `exec-7f60bff5-75b6-41f7-bdc3-fb69cf59c832` | `e146f07add0b686b` | `log_b20.md` |
| `icon_base_ward_v2.png` | 1536×1024 | `01a16f42-8743-7692-a582-c019376b5c9a` | `exec-f94c0a55-7c64-4424-8283-95b6fb345251` | `372fd942df9ed14d` | `log_b20.md` |
| `icon_base_ward_v3.png` | 1536×1024 | `01a16f42-8ba2-7572-8704-89cf996445bc` | `exec-1c772399-81a6-4555-a9ef-9f7ac3edeab0` | `b9c1d70774eb7a5b` | `log_b20.md` |
| `flame_cinder_v1.png` | 1536×1024 | `01a16f43-ea89-7ce1-8bbc-2954e0c71db7` | `exec-31f3abea-d9ad-4c21-a7f3-14dfa0bb46bd` | `9fd8a3a1e6376461` | `log_b20.md` |
| `flame_cinder_v2.png` | 1536×1024 | `01a16f43-f042-7091-b09a-95b5995b9556` | `exec-0fd41328-a0a6-4f46-9ad8-5e292cd0a5bd` | `433158d4ac5156c3` | `log_b20.md` |
| `flame_cinder_v3.png` | 1536×1024 | `01a16f43-f720-7d62-b189-9532400f7b24` | `exec-f6e5d3e4-1dcf-4425-baee-c365cb9d12c2` | `c20fa52bc5b727f1` | `log_b20.md` |
| `slug_tallow_v1.png` | 1536×1024 | `01a16f44-11ae-7e31-84bd-41d3be7eb71d` | `exec-1980340c-3ef3-4447-8c34-e05e0d1f1357` | `6ce0cce59c7af7f5` | `log_b20.md` |
| `slug_tallow_v2.png` | 1536×1024 | `01a16f44-124d-7db0-83d4-c5c5e3a27a72` | `exec-54929239-f5c4-4515-a483-acbaec87b15e` | `d18faac825cd5363` | `log_b20.md` |
| `slug_tallow_v3.png` | 1536×1024 | `01a16f44-35c0-7113-9591-d0b87bda824f` | `exec-70507bc8-4ec0-46f5-9365-4f21c9587d5f` | `ad739268a4010531` | `log_b20.md` |
| `reed_raft_vehicle_v1.png` | 1536×1024 | `01a16f46-7936-76b0-944a-58b33922f806` | `exec-eb475811-44b7-4e3a-baa1-e912780f0a84` | `904a4b9fda219e6b` | `log_b21.md` |
| `reed_raft_vehicle_v2.png` | 1536×1024 | `01a16f46-8107-74f1-b548-c609540121f8` | `exec-cc52d0ab-1841-4cb3-919b-ddf47f4aa9d3` | `8465dc3426b433e1` | `log_b21.md` |
| `reed_raft_vehicle_v3.png` | 1536×1024 | `01a16f46-8864-7e92-a9e0-4393e6c00307` | `exec-7feb32d5-d5f5-4e79-88fa-648ff7d37fd7` | `35a77486c5a1a055` | `log_b21.md` |
| `jar_thrown_v1.png` | 1536×1024 | `01a16f46-91b3-7802-b279-da277ca83c7d` | `exec-cb0218bf-e258-4909-9250-dd399d561e40` | `c91551c0b0bc0e0b` | `log_b21.md` |
| `jar_thrown_v2.png` | 1536×1024 | `01a16f46-97e6-7da0-8068-4452a2ad618e` | `exec-d5ea1e61-4b62-4bba-aaca-57c7f0c0d64a` | `c2daa6ec5f7a5a8c` | `log_b21.md` |
| `jar_thrown_v3.png` | 1536×1024 | `01a16f46-9e11-7531-a20a-a9762db62ca2` | `exec-805cf2c4-3635-4c9f-a17c-378151be8737` | `beb40580514954bf` | `log_b21.md` |
| `jar_lit_v1.png` | 1536×1024 | `01a16f48-5347-7142-a8a2-7392afbfc31c` | `exec-22e563fc-af0e-464e-871c-f9b3e6565e81` | `a17c3e0d3708d536` | `log_b21.md` |
| `jar_lit_v2.png` | 1536×1024 | `01a16f48-57c1-7233-b58d-e21c501b2372` | `exec-3096e15a-06b6-4ece-8f09-ab034fde96f1` | `f487806740e7399a` | `log_b21.md` |
| `jar_lit_v3.png` | 1536×1024 | `01a16f48-5fcd-71c2-889f-e7108cd68578` | `exec-c440a73b-5710-4f2a-8189-1265cc4c592d` | `c30376bc6d409920` | `log_b21.md` |
| `reel_tip_v1.png` | 1536×1024 | `01a16f48-6893-79f1-a4a9-9e0f6acf7f82` | `exec-8504690c-ceb5-4234-9543-0379967457c3` | `6f62c40d526f0312` | `log_b21.md` |
| `reel_tip_v2.png` | 1536×1024 | `01a16f48-755d-7831-893c-a68994ae466a` | `exec-b8e2494a-4e14-4567-a17f-164245e637c0` | `186fecd51c1247f1` | `log_b21.md` |
| `reel_tip_v3.png` | 1536×1024 | `01a16f48-7734-7c52-86fc-7de6834db185` | `exec-fdd53b53-1d37-4da8-b0d9-de876d4a9b2e` | `983c9aa39eec3e4f` | `log_b21.md` |
| `reel_line_rope_v1.png` | 1536×1024 | `01a16f49-e900-74b3-844c-2451556d0466` | `exec-8ab8fe04-6681-4d09-9341-26ed6e95ff8b` | `96cea33db878043b` | `log_b21.md` |
| `reel_line_rope_v2.png` | 1536×1024 | `01a16f49-ee8f-7f20-96a6-7f3e1d80c887` | `exec-af3f0660-8306-4856-9470-430e55c342e0` | `b94c62bca0e09ebb` | `log_b21.md` |
| `reel_line_rope_v3.png` | 1536×1024 | `01a16f49-f602-7e00-b655-5517d8f34d09` | `exec-c537b821-93e4-4db8-a380-90ab9c5828ca` | `8b74d5a9bb153e05` | `log_b21.md` |
| `liftable_rock_small_v1.png` | 1536×1024 | `01a16f49-fd35-7ad0-80e8-7f0e9e19d388` | `exec-cb4f0246-919e-4f49-a75b-6ea68de609d4` | `9a1cecbe67fbcf9d` | `log_b21.md` |
| `liftable_rock_small_v2.png` | 1536×1024 | `01a16f4a-059c-7930-a417-3267e502cf77` | `exec-e2661998-af57-4b16-a6c1-d9a5dd76f58a` | `f25b1b0226f6f868` | `log_b21.md` |
| `liftable_rock_small_v3.png` | 1536×1024 | `01a16f4a-0b8a-7750-b166-110d1f699d15` | `exec-690ccd4b-bbb8-4ef7-b1ce-43cbbb8fbe99` | `ca5f071f54ce11ee` | `log_b21.md` |
| `slug_bundle_v1.png` | 1536×1024 | `01a16f4c-1210-7600-9fc3-65c2aa3bad14` | `exec-d44e9fa4-c8b1-4364-a81e-cde5dcf92c34` | `ccb0ca57e4d71049` | `log_b22.md` |
| `slug_bundle_v2.png` | 1536×1024 | `01a16f4c-19be-7441-a2d5-1dfc10047860` | `exec-43ad7f29-7b9a-49b9-b9c6-86779b50095c` | `bea66186138c2a7c` | `log_b22.md` |
| `slug_bundle_v3.png` | 1536×1024 | `01a16f4c-1f6e-7662-a2a9-60acbbe23104` | `exec-4e48a070-4649-48f0-a895-10e8bbf295d8` | `fdd7435fa2db1e3e` | `log_b22.md` |
| `pot_bag_v1.png` | 1536×1024 | `01a16f4c-2787-7a61-a8be-cfae40ca8d10` | `exec-2f01ff06-8be4-4619-8b8e-d1a02295a8dd` | `a0764cdd0fc1f716` | `log_b22.md` |
| `pot_bag_v2.png` | 1536×1024 | `01a16f4c-9bbe-7bf1-98c0-6a377062cf67` | `exec-d3fc4374-8369-40bf-b2e3-18c8a9496b35` | `533ade7ba7e38ff4` | `log_b22.md` |
| `pot_bag_v3.png` | 1536×1024 | `01a16f4c-9dc7-7953-89e9-73c56254c4ae` | `exec-d166f32a-80a0-474b-b64a-3964fd79945a` | `524cae95683eda77` | `log_b22.md` |
| `tallow_flask_v1.png` | 1536×1024 | `01a16f4d-f48a-7321-8f23-bca976c3add2` | `exec-2209af9c-e796-41e8-b126-1be407b8557c` | `a4fec6e1d0686d77` | `log_b22.md` |
| `tallow_flask_v2.png` | 1536×1024 | `01a16f4d-fafd-72e0-9ef5-b86dda7f79ba` | `exec-b443cd01-734c-4563-9abe-eef1b7a2a57c` | `7b6b95fe68172572` | `log_b22.md` |
| `tallow_flask_v3.png` | 1536×1024 | `01a16f4e-06eb-7311-884e-756ccdcb3224` | `exec-501accd4-f5bd-45d1-8e5b-0efe2b794b2d` | `3e8f231a284b6a2b` | `log_b22.md` |
| `bigkey_v1.png` | 1536×1024 | `01a16f4e-0d4a-7b00-9975-a248d78a9e89` | `exec-645e39d8-0aa8-42f2-b1b7-e3748ec973c3` | `e3c144683611ddf7` | `log_b22.md` |
| `bigkey_v2.png` | 1536×1024 | `01a16f4e-17bc-7d31-956a-c5e9c4e937bd` | `exec-fccbf139-3d6d-45b3-bf13-9595601949aa` | `fb06d2aaa31e0ca9` | `log_b22.md` |
| `bigkey_v3.png` | 1536×1024 | `01a16f4e-19df-7162-8535-87f08e72ff35` | `exec-a6d778e9-46c1-4117-91e2-9300ab6abb8d` | `3daa96ba672cea99` | `log_b22.md` |
| `fragment_c1_v1.png` | 1536×1024 | `01a16f4f-de20-77f3-a9fd-28fc0cd310d0` | `exec-2be456e2-e1d9-44c4-a1b5-2e29125252ed` | `f0ca630efbfd61c1` | `log_b23.md` |
| `fragment_c1_v2.png` | 1536×1024 | `01a16f4f-e3c8-7c93-a2e0-871280bc1f8f` | `exec-8049af27-7dbe-40da-a52d-559e8439e2a2` | `1da9e714678da13f` | `log_b23.md` |
| `fragment_c1_v3.png` | 1536×1024 | `01a16f4f-ef14-73c2-a7ed-9d725d6f082e` | `exec-16742f95-e795-441c-beba-7ce62fd021cf` | `020139caad508ffc` | `log_b23.md` |
| `fragment_c2_v1.png` | 1536×1024 | `01a16f4f-f67d-7540-8d6f-08f506e8046a` | `exec-7bce487e-c6d0-4253-849c-84ce38ba3ea5` | `eb708fe8554531b9` | `log_b23.md` |
| `fragment_c2_v2.png` | 1536×1024 | `01a16f4f-feea-71d2-b605-a5c16f426430` | `exec-ba5beee4-8e3f-45a2-a84f-7aea20a914b8` | `4074b427c6203b3d` | `log_b23.md` |
| `fragment_c2_v3.png` | 1536×1024 | `01a16f50-046b-7693-97f3-e38052355571` | `exec-a9056bff-5472-48d4-9004-312bd7aa6f4b` | `1a0e207e6fb7bc02` | `log_b23.md` |
| `fragment_c3_v1.png` | 1536×1024 | `01a16f51-7a2c-7ff1-8bd8-1135c5b26fa1` | `exec-eda93611-7c8c-4f78-bee9-c90bd1855d5b` | `a4253e687e7c2147` | `log_b23.md` |
| `fragment_c3_v2.png` | 1536×1024 | `01a16f51-80d6-7dd1-bbc3-6f231dc3c90f` | `exec-0445d760-9846-4ad1-bf9d-a51793e0b693` | `27231fd238e67a3e` | `log_b23.md` |
| `fragment_c3_v3.png` | 1536×1024 | `01a16f51-9259-7cf1-b762-67956f399bbd` | `exec-cecf32f5-8547-490d-86ad-f3c6f6023197` | `79250eae469ea79d` | `log_b23.md` |
| `fragment_c4_v1.png` | 1536×1024 | `01a16f51-c505-71f2-8913-318a99b494e8` | `exec-dfd34ca2-ed09-4fb8-81fc-429969f1fc63` | `bdb88c326fffe9d4` | `log_b23.md` |
| `fragment_c4_v2.png` | 1536×1024 | `01a16f51-c8fd-7e91-aa63-c7393d184f11` | `exec-96152922-42c3-42fe-a80f-9e71170c781b` | `566aa0f47f5f6f28` | `log_b23.md` |
| `fragment_c4_v3.png` | 1536×1024 | `01a16f51-dc47-77c2-9035-908b40fed15e` | `exec-df2f235b-b237-4b7c-992e-927265064bdd` | `f6dc51ffca74609c` | `log_b23.md` |
| `fragment_c5_v1.png` | 1536×1024 | `01a16f53-1940-76c2-961c-08fcc3191852` | `exec-3362d34c-4e7e-41c7-9445-7cc2b2a1b826` | `767f12f8e5e8e839` | `log_b23.md` |
| `fragment_c5_v2.png` | 1536×1024 | `01a16f53-1c98-7761-96e6-08424ef64050` | `exec-f759336c-2486-4da1-a9d1-462dba7ec2c1` | `63c6a18a152038a0` | `log_b23.md` |
| `fragment_c5_v3.png` | 1536×1024 | `01a16f53-2350-7212-be17-597c0f263c1e` | `exec-6807a208-c750-4f30-9c72-0dd5a10a3429` | `5f553a3770f5d808` | `log_b23.md` |
| `fragment_c6_v1.png` | 1536×1024 | `01a16f53-2c9b-7300-8508-c939c51fccab` | `exec-4f69a21f-6033-4a4f-9092-00a0e35d0704` | `17035ee73fe11c77` | `log_b23.md` |
| `fragment_c6_v2.png` | 1536×1024 | `01a16f53-329d-7051-9de9-f534b734ca48` | `exec-ed459320-55bd-41ee-b6d4-2274ab7751e0` | `9f201fb03d3a6eb8` | `log_b23.md` |
| `fragment_c6_v3.png` | 1536×1024 | `01a16f53-3b3f-7ee2-abab-9cbdd96bf2c4` | `exec-fe6f11bd-8601-42ff-afe2-5a762968c0da` | `401f792a79430cff` | `log_b23.md` |
| `fragment_c7_v1.png` | 1536×1024 | `01a16f54-897f-7cd3-a27b-ca7e7ce9d57e` | `exec-c72972cc-4559-467d-8b98-b14d1c91f3fd` | `bc6040b04ac35e36` | `log_b23.md` |
| `fragment_c7_v2.png` | 1536×1024 | `01a16f54-8adc-7542-81b5-40dfd1e363d2` | `exec-1c0c8c09-2428-4e1b-a789-5694ce50f978` | `2ee140d2b16e4d0c` | `log_b23.md` |
| `fragment_c7_v3.png` | 1536×1024 | `01a16f56-5f6d-78c1-b2a4-daa5cd5a30d9` | `exec-49881c64-b6f9-43cb-aeb1-a7f219d89dc6` | `496016e73957c91a` | `log_b24.md` |
| `fragment_c8_v1.png` | 1536×1024 | `01a16f56-684a-7de0-aab4-02bba18c3b14` | `exec-8137a157-6290-41bc-93d0-7e93fed02646` | `25bc5c908538a658` | `log_b24.md` |
| `fragment_c8_v2.png` | 1536×1024 | `01a16f56-6c89-7de3-9047-9effb66ef79a` | `exec-d3d8e52e-a315-4910-8faf-fecc1d12ed7e` | `26e21c72ccf1754d` | `log_b24.md` |
| `fragment_c8_v3.png` | 1536×1024 | `01a16f56-744a-7893-957f-31448905614e` | `exec-a60503c5-3aa0-48cc-bc09-c82925c97ce5` | `559a4c9b47f51006` | `log_b24.md` |
| `fragment_c9_v1.png` | 1536×1024 | `01a16f56-7bfc-7510-b0db-a2ebed1e0553` | `exec-400d12e0-15b2-4dcf-b853-2b30cef0a88f` | `d1e6d3385f976597` | `log_b24.md` |
| `fragment_c9_v2.png` | 1536×1024 | `01a16f56-838f-7e13-8527-a7c56cce4aed` | `exec-372230ad-1b50-4602-b39d-6107e654aa37` | `db49ed9738cecb06` | `log_b24.md` |
| `fragment_c9_v3.png` | 1536×1024 | `01a16f57-b8b8-7bc1-bdaa-a8e03160980e` | `exec-9a11dfc2-403c-48ce-9505-56f0585c28b7` | `bd2f1ba27d3526fa` | `log_b24.md` |
| `slag_chunk_v1.png` | 1536×1024 | `01a16f57-ba94-76e3-8823-3cc4f286182a` | `exec-69530920-11e5-45ac-8ad7-d505d54e977f` | `c4abe25c88b03b88` | `log_b24.md` |
| `slag_chunk_v2.png` | 1536×1024 | `01a16f57-c15a-77a1-a855-b2c1934249c5` | `exec-d3f1d688-74d9-46bb-b964-bccef0813176` | `21b3d1a95e7960fe` | `log_b24.md` |
| `slag_chunk_v3.png` | 1536×1024 | `01a16f57-c936-7041-81df-01fc77de08f8` | `exec-2ac94f39-7f69-46bd-b89c-33ece0c12aef` | `3d726ceb68a2b63a` | `log_b24.md` |
| `thorn_hedge_v1.png` | 1536×1024 | `01a16f57-d118-7e30-a47f-78cc5442013c` | `exec-943c2af9-755c-403f-a0dc-71f657e789bc` | `70e7e120764e64a6` | `log_b24.md` |
| `thorn_hedge_v2.png` | 1536×1024 | `01a16f57-d733-7b91-bddd-f6198b71e3bb` | `exec-c1b9a420-c0b4-46dc-8b08-e9af5a839b94` | `6b3053357cf4eaf9` | `log_b24.md` |
| `thorn_hedge_v3.png` | 1536×1024 | `01a16f59-3652-7590-b12e-fa53f283162e` | `exec-1c4e1d66-b68a-4d29-9fff-bb884032cd1f` | `4a8abda07c8da2eb` | `log_b24.md` |
| `thorn_wall_v1.png` | 1536×1024 | `01a16f59-435f-72a1-bab3-cba31cf1121b` | `exec-ade64a31-0ab6-4441-a07a-a79e2f07cbaf` | `3e5c36bd26fa46a0` | `log_b24.md` |
| `thorn_wall_v2.png` | 1536×1024 | `01a16f59-4310-7993-a5a9-4b14a63d7ca5` | `exec-e9750b27-ff4b-4428-919b-b627a407a2e0` | `26b6ecb1684e46e1` | `log_b24.md` |
| `thorn_wall_v3.png` | 1536×1024 | `01a16f59-4c86-7d42-aae1-15d0c89314e6` | `exec-a99f1026-c07a-4862-8b84-a68f1b459031` | `572a8c20c61a114d` | `log_b24.md` |
| `thorn_door_v1.png` | 1536×1024 | `01a16f59-52dd-7a02-a24a-31d858a64b4a` | `exec-56b99a45-7828-4554-b4a2-a29ae8ec4b19` | `cbfd8c876f56f078` | `log_b24.md` |
| `thorn_door_v2.png` | 1536×1024 | `01a16f59-5a46-7470-a193-af883bdf463a` | `exec-48452024-220d-4400-b40b-9001f5f20eed` | `32938ab9f40a7e65` | `log_b24.md` |
| `thorn_door_v3.png` | 1536×1024 | `01a16f5a-7749-7140-9a5b-d354fbfa96bd` | `exec-2a92c648-4595-4d61-9969-cc4f4862dd2a` | `ef8fd78652ea511e` | `log_b24.md` |
| `eye_switch_v1.png` | 1536×1024 | `01a16f5b-f1ac-7983-8d1e-946acf0f08b1` | `exec-a8f18e5e-0f3b-403f-97d9-db48c700a08f` | `0fc7ba5406f6c0bb` | `log_b25.md` |
| `eye_switch_v2.png` | 1536×1024 | `01a16f5b-f75c-7e23-bc12-d35068263c02` | `exec-9255e061-963c-47ba-80e5-343bd3abbae0` | `67978de16723dd98` | `log_b25.md` |
| `eye_switch_v3.png` | 1536×1024 | `01a16f5b-ff47-7232-8cc0-6b1b79bd9f71` | `exec-57758fcd-493b-453c-a568-e9518167077a` | `943680055ea6088e` | `log_b25.md` |
| `eye_portcullis_v1.png` | 1536×1024 | `01a16f5c-062b-7681-9704-3c04811cfe9d` | `exec-8ff64f94-c9ec-4a83-8456-7222e6799d09` | `84a4b04f790e72f9` | `log_b25.md` |
| `eye_portcullis_v2.png` | 1536×1024 | `01a16f5c-1485-7c63-9042-f97d4facefa4` | `exec-6cea5863-ae1e-4976-92ff-aa6b1376d2ef` | `95ccea4f4ad8f3b3` | `log_b25.md` |
| `eye_portcullis_v3.png` | 1536×1024 | `01a16f5c-32e9-7df0-b58f-8d0215db8749` | `exec-41bfb461-bd75-4b0b-82a5-74358766c95c` | `56904bb480951e78` | `log_b25.md` |
| `eye_cell_v1.png` | 1536×1024 | `01a16f5d-507f-7732-87d7-49e12c368938` | `exec-5d19e152-aaf4-44cf-bc91-942d5bbf0e12` | `11c9a55b650dc233` | `log_b25.md` |
| `eye_cell_v2.png` | 1536×1024 | `01a16f5d-577c-7683-bbd0-36588c4dfca2` | `exec-c0f788bb-1070-43cb-bc38-d2565f7a676a` | `f3dce88562e6bfcf` | `log_b25.md` |
| `eye_cell_v3.png` | 1536×1024 | `01a16f5d-63aa-7960-81fd-d04cae1f94d6` | `exec-d1c2d385-1c8c-48bc-93d5-0b29d89d07ce` | `0bc51d9f15f1a827` | `log_b25.md` |
| `mooring_v1.png` | 1536×1024 | `01a16f5d-85d9-7f01-af50-d415c3e08e07` | `exec-1b380260-9668-4438-b9d8-5ebedca73621` | `df92cf7fad956a23` | `log_b25.md` |
| `mooring_v2.png` | 1536×1024 | `01a16f5d-c53a-7322-9f63-22f0f9a0fa27` | `exec-3d856d42-1f06-4407-8434-ed566f340588` | `485ac6a28feab48b` | `log_b25.md` |
| `mooring_v3.png` | 1536×1024 | `01a16f5d-c66a-7d33-b935-1b97009b06d0` | `exec-7c3c0d9e-08d8-4b4c-806d-8a06952b66d4` | `1a2d832ced3b386e` | `log_b25.md` |
| `edge_pit_rim_v1.png` | 1536×1024 | `01a16f5f-199b-7bd1-bcaf-733933a83bba` | `exec-466471c2-fa2c-41d7-9836-c132c1af076e` | `9eca33015c50f940` | `log_b25.md` |
| `edge_pit_rim_v2.png` | 1536×1024 | `01a16f5f-188e-7f43-bdc7-f12d81c8faa1` | `exec-326398a4-df25-472f-93b0-8bd02c25896e` | `1c7e775ee43fc29b` | `log_b25.md` |
| `edge_pit_rim_v3.png` | 1536×1024 | `01a16f5f-2088-7e32-879a-991ab9819f11` | `exec-63e86f94-e8c7-4f9f-af8e-9ce4da724a75` | `756170d88a4bb0ce` | `log_b25.md` |
| `pit_fill_v1.png` | 1254×1254 | `01a16f5f-2911-7c31-9429-4f37521abc4a` | `exec-7d1b0a1a-e7fd-40b4-ad40-530c1640bc6e` | `564826f08af93e13` | `log_b25.md` |
| `pit_fill_v2.png` | 1254×1254 | `01a16f5f-3043-71c3-a5f3-110883c34180` | `exec-2467cae3-03fb-4421-a7ec-58def3b4a2b6` | `698c6c75dd75720a` | `log_b25.md` |
| `pit_fill_v3.png` | 1254×1254 | `01a16f5f-390c-74e0-bbeb-69cd7bdc9499` | `exec-e0669716-53c1-44fc-b06c-f90ba432cd0d` | `e7676ac5dfacecd7` | `log_b25.md` |
| `tex_cave_stone_ground_v2.png` | 1254×1254 | `01a16f3f-7f4d-78c0-b04d-be2a3ba2bc1e` | `exec-bdce3c34-cce2-4221-887a-23d806eda0df` | `ca1b5454dd556480` | `log_b12.md` |
| `tex_cave_stone_ground_v3.png` | 1254×1254 | `01a16f3f-81db-7bb2-b522-1a94a28ca371` | `exec-b5a0675b-bbec-4ceb-9f34-755feed69603` | `54508a8376fd9c63` | `log_b12.md` |
| `tex_cave_stone_wall_v1.png` | 1254×1254 | `01a16f3f-87a7-7023-8efd-ae6df971e252` | `exec-d1c9c383-1a0e-49fb-944b-a358bc246a22` | `33698bbeb585f328` | `log_b12.md` |
| `tex_cave_stone_wall_v2.png` | 1254×1254 | `01a16f3f-8ee5-7102-be6c-1f11a5bd5943` | `exec-546a6aea-7e75-474c-82fd-faed40693088` | `32e50ec09566306b` | `log_b12.md` |
| `tex_cave_stone_wall_v3.png` | 1254×1254 | `01a16f3f-9554-7d23-834b-8eb3b7ee13e9` | `exec-031f2d87-2bbb-4c7d-a8e2-13dca6177ef1` | `ee8322ae896f3b02` | `log_b12.md` |
| `tex_cave_stone_wall_face_v1.png` | 1254×1254 | `01a16f41-0bba-7df2-9d90-f62b61b200c1` | `exec-0fd91a58-a9f5-45b8-bb55-305e4ab930a1` | `f70e7e1d133880ae` | `log_b12.md` |
| `tex_cave_stone_wall_face_v2.png` | 1254×1254 | `01a16f41-0dd7-7f61-947b-5ee292808cb5` | `exec-7a40f8fe-9e01-4980-859b-74afc3bb4ee8` | `80481ce576e2efe6` | `log_b12.md` |
| `tex_cave_stone_wall_face_v3.png` | 1254×1254 | `01a16f41-15dd-7df0-9288-944647268bca` | `exec-ceafa7ce-9e9a-40a9-963d-fe6ac8e43f40` | `aa04cfe2e90f5c81` | `log_b12.md` |
| `tex_cave_root_ground_v1.png` | 1254×1254 | `01a16f41-1be0-72b2-a1ec-6f74e96b00b5` | `exec-f732aa4d-0814-49ba-94c7-85da0accc81e` | `63bf3457ef982aad` | `log_b12.md` |
| `tex_cave_root_ground_v3.png` | 1254×1254 | `01a16f41-86b7-7ba0-844a-e00a0833de3b` | `exec-0c420519-d895-4c6d-9ef6-812992cf1250` | `e1d2bf9e5614776b` | `log_b12.md` |
| `tex_cave_root_ground_v2.png` | 1254×1254 | `01a16f41-7689-7202-8146-8fdc735470dc` | `exec-77c12ea9-a479-413d-b511-42fdd99d3300` | `85ee3924e2259f3e` | `log_b12.md` |
| `tex_cave_root_wall_v1.png` | 1254×1254 | `01a16f43-453d-7111-ab1c-37d83cf9394e` | `exec-21f309c2-9276-4cd7-976f-1aa16609e4ea` | `dd2e89644ad7f5b9` | `log_b12.md` |
| `tex_cave_root_wall_v2.png` | 1254×1254 | `01a16f43-5021-75c1-8f13-e76f375cefae` | `exec-8efa9224-cdf1-4347-b380-0c47a5234326` | `5891625363d92c3f` | `log_b12.md` |
| `tex_cave_root_wall_v3.png` | 1254×1254 | `01a16f43-5667-7360-bdac-46e03492705d` | `exec-2c06f711-3e64-42db-b1f3-d508f1ade173` | `d8cd8a923d4e0614` | `log_b12.md` |
| `tex_cave_root_wall_face_v1.png` | 1254×1254 | `01a16f43-6062-7a40-a39f-55cedf651bc2` | `exec-22836512-cc3e-4083-879c-a337896610de` | `1d2ace2aa626914d` | `log_b12.md` |
| `tex_cave_root_wall_face_v3.png` | 1254×1254 | `01a16f43-6d6a-7340-ae9b-5d731dec4ef1` | `exec-70df8c84-f1aa-49d0-8afc-9315f6a6025e` | `c02713053b0fe320` | `log_b12.md` |
| `tex_cave_root_wall_face_v2.png` | 1254×1254 | `01a16f43-6625-7993-b2de-72a1c247967c` | `exec-e168a977-a435-4711-b9d2-74e2386ddba8` | `759d9b9be4b7f6b1` | `log_b12.md` |
| `sealed_seam_v1.png` | 1536×1024 | `01a16f3f-1c63-7b90-b759-8d2ffc2b5b7f` | `exec-d1653dbc-6f1f-45b7-ac10-8950d155b69f` | `4201831f4205672b` | `log_b28.md` |
| `sealed_seam_v2.png` | 1536×1024 | `01a16f3f-1cb8-7280-b936-37e6e7eb6153` | `exec-27dcb698-581b-42a6-8b75-312ee85acf7d` | `73adb7f6eba88f13` | `log_b28.md` |
| `sealed_seam_v3.png` | 1536×1024 | `01a16f3f-1f6e-7042-8f58-bdb8f23944e6` | `exec-1510d807-ea2e-475e-9beb-52b42d7860df` | `07c7f2630588b01e` | `log_b28.md` |
| `hook_tap_wall_v1.png` | 1536×1024 | `01a16f3f-264f-7691-ba62-a8ee51945ed2` | `exec-05932c6a-c0f0-4c65-975b-3b62161134d3` | `8e50b8e5ffd3a81b` | `log_b28.md` |
| `hook_tap_wall_v2.png` | 1536×1024 | `01a16f3f-2e31-78a1-b331-2873b4f1c3f3` | `exec-5e742b27-2cdc-477f-a1b1-95da813ddc25` | `128785742714d163` | `log_b28.md` |
| `hook_tap_wall_v3.png` | 1536×1024 | `01a16f3f-33a5-7153-8d76-dfe073bc77c9` | `exec-beb5f011-068e-4950-a6f0-7accb753b94b` | `c66722e0520d74c3` | `log_b28.md` |
| `grate_v1.png` | 1536×1024 | `01a16f40-bcf3-77c2-8987-55d2a5f69c6e` | `exec-40257ae5-49cb-45f1-81b1-599bd8a4bb68` | `a2173fc6b653ef5c` | `log_b28.md` |
| `grate_v2.png` | 1536×1024 | `01a16f40-c568-7c62-b194-31cbc30ffcba` | `exec-3a2aa7c8-7920-458a-8a07-0cc11aee6e1a` | `39dba09cdf7205cc` | `log_b28.md` |
| `grate_v3.png` | 1536×1024 | `01a16f40-ccbd-78f2-bdea-7bcd255a8cca` | `exec-80c25962-dece-4706-b939-4c3a1797901a` | `4977c483bab67103` | `log_b28.md` |
| `boss_door_v1.png` | 1536×1024 | `01a16f40-d2e1-71a1-8bff-20056179aa8f` | `exec-b28_boss_door_v1` | `012cd583b5657a54` | `log_b28.md` |
| `boss_door_v2.png` | 1536×1024 | `01a16f40-da93-79f0-995a-20c9307d594a` | `exec-cd19d27b-e750-48d3-bae8-6fd60d5b7235` | `3bc89481851e0e98` | `log_b28.md` |
| `boss_door_v3.png` | 1536×1024 | `01a16f40-e300-75e0-8ace-ce15a7345248` | `exec-324fbefa-f3a1-4f5d-8e9c-1360abc56b7e` | `5fbc05d6af75f189` | `log_b28.md` |
| `ninth_door_v1.png` | 1536×1024 | `01a16f42-6a81-7273-a304-251db0e6bcc6` | `exec-cd519554-7077-4af8-9dff-d78314d56993` | `b691807a4a61ed70` | `log_b28.md` |
| `ninth_door_v2.png` | 1536×1024 | `01a16f42-6d34-7360-9137-4795a6a4ab98` | `exec-c166f85c-7984-4901-8db1-c7d58afbaa1d` | `8ac161cc0e47c7ac` | `log_b28.md` |
| `ninth_door_v3.png` | 1536×1024 | `01a16f42-745c-7ce3-aac7-3df4118f9fbb` | `exec-3ed54351-80dc-4525-8d20-b1ca20087a37` | `cb1893757ef15e83` | `log_b28.md` |
| `wax_seal_v1.png` | 1536×1024 | `01a16f42-7d47-7971-bc75-b8a8647bb728` | `exec-9f11e503-33f6-4d51-8ae0-bd7a89f510ee` | `8368176e8354bf41` | `log_b28.md` |
| `wax_seal_v2.png` | 1536×1024 | `01a16f42-859d-7f40-b608-7e0609670448` | `exec-6cf36f06-7e50-4c3e-b8ec-a9500a357704` | `025baf3fb345a7fe` | `log_b28.md` |
| `wax_seal_v3.png` | 1536×1024 | `01a16f42-e162-79b2-a8c9-c0a5ca77315d` | `exec-37155fb9-0859-4e59-9d1d-99fbcc5247c2` | `3869cc73e4a395df` | `log_b28.md` |
| `reed_cluster_v1.png` | 1536×1024 | `01a16f45-affe-79c3-8e98-1e906cba22be` | `exec-522e9ca7-5e2c-4eb6-ae4b-7790da3c9783` | `7ea28b36aa2f9303` | `log_b29.md` |
| `reed_cluster_v2.png` | 1536×1024 | `01a16f45-b099-7543-9306-c6c0bca76a6f` | `exec-afa07197-aaf1-4239-a5b7-c200aa16fd6b` | `8383db2734785ccb` | `log_b29.md` |
| `reed_cluster_v3.png` | 1536×1024 | `01a16f45-b7e9-7bf3-8981-71c9ce8ea035` | `exec-c89b95a4-413e-48a5-954d-fe5dd0331de2` | `69eb3ec583e66e4d` | `log_b29.md` |
| `rush_wall_v1.png` | 1536×1024 | `01a16f45-beb5-7233-b177-900c1161b06e` | `exec-f1982be8-00e6-4395-9d96-0c2002679291` | `bd3c6f8d3d747833` | `log_b29.md` |
| `rush_wall_v2.png` | 1536×1024 | `01a16f45-c5a0-7de0-874a-f786a6b9a133` | `exec-229d4357-9ee3-4c6e-b066-2c678be91ec0` | `ad37a9b285db6cff` | `log_b29.md` |
| `rush_wall_v3.png` | 1536×1024 | `01a16f45-cd4b-71e0-a370-b9d2914f9bec` | `exec-cb52e093-59e9-4b17-95d9-63ade5856c89` | `57228b7f6bb4bb96` | `log_b29.md` |
| `moss_wall_v1.png` | 1536×1024 | `01a16f47-3fa9-7291-8eee-c6a448b790c3` | `exec-b404c7eb-1128-4ca6-8b1b-67adcac8a498` | `7569f3420c958c61` | `log_b29.md` |
| `moss_wall_v2.png` | 1536×1024 | `01a16f47-418b-7892-97e7-ed897a34c68a` | `exec-cf1630a8-0c46-47e2-bfb2-cdb054335c1c` | `70e1acc86f5436fe` | `log_b29.md` |
| `moss_wall_v3.png` | 1536×1024 | `01a16f47-4996-73c2-83e9-5a824435da4e` | `exec-1e5e254f-1bdd-4be3-8d3c-6cf1720cdb41` | `79d878d0a3457e34` | `log_b29.md` |
| `dry_vine_screen_v1.png` | 1536×1024 | `01a16f47-5184-7551-837b-0a323835b850` | `exec-d2fef4bb-d4ab-4a25-9958-a44bcd13d9ac` | `a075c4045130fe8c` | `log_b29.md` |
| `dry_vine_screen_v2.png` | 1536×1024 | `01a16f47-579a-7890-bc91-dd433f43171f` | `exec-11f8e7fa-67af-44b3-93a8-40425132b0d2` | `b8f238706acdd45e` | `log_b29.md` |
| `dry_vine_screen_v3.png` | 1536×1024 | `01a16f47-678e-7570-8244-b93a24534e08` | `exec-a117aafd-16dd-4190-913e-f9f1eba26347` | `83b152485f086ceb` | `log_b29.md` |
| `bush_cluster_v1.png` | 1536×1024 | `01a16f48-b9b5-70c3-96a2-35e00e4087f9` | `exec-48c1028e-b061-44de-872c-b0e22d07d541` | `43b26bb663ad7f16` | `log_b29.md` |
| `bush_cluster_v2.png` | 1536×1024 | `01a16f48-bed4-79f1-8f65-dc409d899d18` | `exec-b1065ac1-3159-4334-980e-e76188968d27` | `0a049ee821be88e5` | `log_b29.md` |
| `bush_cluster_v3.png` | 1536×1024 | `01a16f48-c965-7223-ad1d-c51efff86a12` | `exec-32a1d69d-213b-471a-a574-40d0bb1d31fa` | `985a128d6d26c2dc` | `log_b29.md` |
| `brittle_rocks_v1.png` | 1536×1024 | `01a16f48-ce4e-7f50-b311-9788cd40c57e` | `exec-2f2e8b66-ebf0-4cf3-bf39-b220975a1e33` | `d365f967a0e61032` | `log_b29.md` |
| `brittle_rocks_v2.png` | 1536×1024 | `01a16f48-e32a-7651-9037-f2820340f3d6` | `exec-45fac434-92ac-4597-95bb-7bc078ed4b80` | `5f516e27fbbf849d` | `log_b29.md` |
| `brittle_rocks_v3.png` | 1536×1024 | `01a16f49-1fc1-7711-b028-92ad606d5ba1` | `exec-d3e0e8e4-f327-4f0e-bc94-d481308ddc5a` | `d344e40ab70378a6` | `log_b29.md` |
| `tex_water_black_v1.png` | 1254×1254 | `01a16f45-f56a-7f41-a409-2a232060b2ef` | `exec-9c55e287-e739-43da-b1b6-cf8a82381295` | `1c7fe13b41bd6123` | `log_b13.md` |
| `tex_water_black_v3.png` | 1254×1254 | `01a16f46-01b7-7a20-95dc-4e1947a97e3f` | `exec-0c20c815-ab20-47f1-bddf-224bd30208d8` | `7162f7b52f751c2e` | `log_b13.md` |
| `edge_cave_floor_to_wall_v1.png` | 1983×793 | `01a16f46-0960-7291-8a1d-8f2d147ced87` | `exec-1ec98c63-c3b7-42d8-8068-8d3bb2ea575a` | `f9b8fbb7f32839e1` | `log_b13.md` |
| `edge_cave_floor_to_wall_v2.png` | 1973×797 | `01a16f46-1291-7710-b28f-ea4ed9e9925e` | `exec-5dcacc2d-974a-441a-b96c-da316d2084ca` | `9cf0e9836c6124c1` | `log_b13.md` |
| `edge_cave_floor_to_wall_v3.png` | 1983×793 | `01a16f46-18b1-7082-b865-df614a3d4fed` | `exec-580c0a96-78bb-44f5-83eb-fc9a52e07cf3` | `ccc9e32426875a29` | `log_b13.md` |
| `tex_water_black_v2.png` | 1254×1254 | `01a16f45-fbe7-7dd3-8c26-c136f851f878` | `exec-d9cc879f-aed4-4bd0-a8ba-22d00076a4ea` | `580e94e06688e8b7` | `log_b13.md` |
| `edge_cave_water_v1.png` | 1983×793 | `01a16f47-4063-7db0-b2b9-f4a80b33eb2c` | `exec-1b3edda1-7e3c-4c8d-b557-a75aaff8e2cd` | `5568b3ab7d9ea8b3` | `log_b13.md` |
| `edge_cave_water_v2.png` | 2048×768 | `01a16f47-43fa-7d10-8ede-b72d33951ec3` | `exec-98c3d97f-4c7c-4c2c-b850-4bc28c171e80` | `f08d04098a32e7c3` | `log_b13.md` |
| `edge_cave_water_v3.png` | 1983×793 | `01a16f47-4a96-7b01-a981-fe43f2dfd47c` | `exec-dc0bbccf-bea8-4082-a079-6a93217c6989` | `64559a309e1f8bec` | `log_b13.md` |
| `bramble_snapper_v1.png` | 1536×1024 | `01a16f47-51ec-7942-8ba5-cca471471c0c` | `exec-f9d48f2d-1a05-4d39-91a5-4c00fa728eb2` | `d5b017f30c86c2fe` | `log_b13.md` |
| `bramble_snapper_v2.png` | 1536×1024 | `01a16f47-5922-7dd2-9cfe-bdad5c93def8` | `exec-c8446af6-5879-45bd-b8f2-9a89c028c90e` | `d65f327b3d6e144c` | `log_b13.md` |
| `fen_leech_v2.png` | 1536×1024 | `01a16f48-c563-79f1-a2ab-c49d5701896a` | `exec-300155a3-9c44-4325-ba06-e8b6efed409f` | `16cc4faaa56d9b70` | `log_b13.md` |
| `fen_leech_v3.png` | 1536×1024 | `01a16f48-cda9-7c10-a63b-19cb1c4f06f5` | `exec-cdc9fcc4-c98f-4641-bca6-af2d8950491d` | `538ba67839358af6` | `log_b13.md` |
| `cinder_wisp_v1.png` | 1536×1024 | `01a16f48-e476-7f80-b94c-0ddaa09ddc8c` | `exec-7e227ad4-c885-411c-ac0c-7925c8a81e38` | `f904ad74e217d148` | `log_b13.md` |
| `fen_leech_v1.png` | 1536×1024 | `01a16f48-be46-7343-9ff8-2061135e8e72` | `exec-d06a1487-c81c-4129-9b48-3d6cf7235526` | `de346197c727d7f0` | `log_b13.md` |
| `cinder_wisp_v2.png` | 1536×1024 | `01a16f49-19e6-7893-b652-ad9d302cbcf0` | `exec-4b6ce46d-293e-49bc-ae05-259d82f21f7d` | `d7bede4ab3f455b8` | `log_b13.md` |
| `cinder_wisp_v3.png` | 1536×1024 | `01a16f49-fe7d-7310-bfd7-88de465709f5` | `exec-65e95606-aad4-4f01-9d5c-81a96498ace2` | `b191c25f2412381a` | `log_b13.md` |
| `bramble_snapper_v3.png` | 1536×1024 | `01a16f49-f845-7c50-8387-9ae105c2f82c` | `exec-5c96e364-0b1b-4b07-be12-8f9491360f8c` | `fac6ae08f4b2e655` | `log_b13.md` |
| `pocket_stall_v1.png` | 1536×1024 | `01a16f4a-8e45-72b3-ac4b-6df646baf43b` | `exec-0d99c8cc-0558-4bd9-8270-2b7c7c3d1f13` | `3790305131fd5df1` | `log_b30.md` |
| `pocket_stall_v2.png` | 1536×1024 | `01a16f4a-8f41-7ce1-97e5-eb295f8bff00` | `exec-9e0d7430-0689-4f4e-b2d4-c57e4586f486` | `1e556b1c36d16d46` | `log_b30.md` |
| `pocket_stall_v3.png` | 1536×1024 | `01a16f4a-91de-7b00-9536-961aa049ad2d` | `exec-29603980-081c-4680-a65c-38aa2925601f` | `c6c2e7fd99d8f981` | `log_b30.md` |
| `pocket_cart_v1.png` | 1536×1024 | `01a16f4a-9a34-7d10-b604-a44906e539ee` | `exec-4f0a3133-be02-4eea-949f-838fbe7517c2` | `781049c6c787b672` | `log_b30.md` |
| `pocket_cart_v2.png` | 1536×1024 | `01a16f4a-a42e-7af2-995e-b7ddaf04e9a5` | `exec-99c1fa85-b5ee-4365-978e-7a3d44a1bf15` | `4cabebf9d12f857e` | `log_b30.md` |
| `pocket_cart_v3.png` | 1536×1024 | `01a16f4a-a90a-7360-94b1-efed73f983d5` | `exec-18938ee1-eaeb-4f71-8a9e-d8eadbe97544` | `b466c83c42daaaa0` | `log_b30.md` |
| `pocket_lighthouse_door_v1.png` | 1536×1024 | `01a16f4b-e414-77c1-ae65-487c94637e55` | `exec-3f0596fd-58bf-4f8a-ad0e-8438ec3b4114` | `849e08c295c733b6` | `log_b30.md` |
| `pocket_lighthouse_door_v2.png` | 1536×1024 | `01a16f4b-ecec-7812-b4ec-0c866565e90c` | `exec-3853b0c5-1efd-45ec-898e-c991e5552ca3` | `be8d3c39fbb78f59` | `log_b30.md` |
| `pocket_lighthouse_door_v3.png` | 1536×1024 | `01a16f4b-f595-7500-b98d-93ef2291b0fd` | `exec-efd64cd0-d5f5-4d1f-a6d5-0c6fb71308a6` | `b86f9cc5b6d5d5d1` | `log_b30.md` |
| `pocket_mason_door_v1.png` | 1536×1024 | `01a16f4b-fc4f-7f01-a4ba-198d2de23fde` | `exec-7da56558-a861-42da-8cfd-9746f027e81f` | `8ea860226bbf49cd` | `log_b30.md` |
| `pocket_mason_door_v2.png` | 1536×1024 | `01a16f4c-0af0-72c2-92ac-3b71d1768acc` | `exec-d6e25f0c-84e8-454a-ae2b-e6abaaefe9d5` | `eb38908e859598de` | `log_b30.md` |
| `pocket_mason_door_v3.png` | 1536×1024 | `01a16f4c-0d12-75a3-ac3b-f0515577f317` | `exec-2d9f6510-6642-414f-898b-076b1fa83ea4` | `0125157077a8b715` | `log_b30.md` |
| `pocket_hut_door_v1.png` | 1536×1024 | `01a16f4d-2c63-7951-a533-a82263f45286` | `exec-7b75ba5f-6b5b-4901-a3a3-781bba5dc276` | `8af22c71763a6f8e` | `log_b30.md` |
| `pocket_hut_door_v2.png` | 1536×1024 | `01a16f4d-315d-7df1-99a2-fe135085506b` | `exec-3eed0228-956e-4976-8040-632fad2b6ca8` | `1014e2b1bcb79497` | `log_b30.md` |
| `pocket_hut_door_v3.png` | 1536×1024 | `01a16f4d-3ab3-7d72-bd4e-49a424c6e7d5` | `exec-1c46a62b-8516-4079-8d24-8172125f4abc` | `98c97ce6088b6e93` | `log_b30.md` |
| `pocket_grotto_v1.png` | 1536×1024 | `01a16f4d-4492-7201-80e9-78997e3e8b85` | `exec-14b53597-000d-4e12-a0e1-da26c0924b04` | `e1507a1bd3e8be59` | `log_b30.md` |
| `pocket_grotto_v2.png` | 1536×1024 | `01a16f4d-4a34-7070-973f-744e13028788` | `exec-a976569b-b954-45e0-91f3-7fc2b3b34b6d` | `b3659e1dab4b010b` | `log_b30.md` |
| `pocket_grotto_v3.png` | 1536×1024 | `01a16f4d-51ce-7ff2-a7ea-6bb24b7469f3` | `exec-4969684c-9b09-4a9e-860d-e0c9785d6e25` | `8f01c302fc557ef6` | `log_b30.md` |
| `watcher_eye_side_v1.png` | 1536×1024 | `01a16f4b-b6d5-71b2-b86b-8cd1fe10ed3a` | `exec-be81844e-8d95-414a-8e9c-e3e3a6ba7275` | `2f2d6e0ea66e2c90` | `log_b14.md` |
| `watcher_eye_side_v2.png` | 1536×1024 | `01a16f4b-bbae-7950-ae2e-35860909081d` | `exec-35823d63-3eeb-4f7f-bddd-a572a211f081` | `eb5d44baf94425ab` | `log_b14.md` |
| `watcher_eye_side_v3.png` | 1536×1024 | `01a16f4b-c2c8-7571-bdaf-e7109dac1662` | `exec-b910e250-cfaf-4724-b6b5-a46440ddb9cb` | `23247d2f576e1974` | `log_b14.md` |
| `husk_hound_walk_side_v1.png` | 1536×1024 | `01a16f4b-ca74-7911-a6a9-1e2fd7c2ebe6` | `exec-bf2b41ab-5c9c-4aa2-b662-2a2238ea2eaa` | `22c2ee871b63c32d` | `log_b14.md` |
| `husk_hound_walk_side_v2.png` | 1536×1024 | `01a16f4b-d355-72f1-90c0-919102b5daa3` | `exec-3b56ba06-d0a8-49cb-9d12-e24d1da1c44e` | `9b0edcdc9255cba7` | `log_b14.md` |
| `husk_hound_walk_side_v3.png` | 1536×1024 | `01a16f4b-d894-7790-8bf1-07ab2f173d35` | `exec-2e6d064f-f14d-47ae-939c-6a12a1d32fc1` | `1987c074be4caf09` | `log_b14.md` |
| `watcher_eye_down_v1.png` | 1536×1024 | `01a16f4d-5795-7ee3-b809-a666c752f88a` | `exec-98ac8bce-c280-4643-899e-b86dc771f414` | `ebebd2235547ffdb` | `log_b14.md` |
| `watcher_eye_down_v2.png` | 1536×1024 | `01a16f4d-5dd3-7ee1-8cf1-f9b17b5a33ac` | `exec-c31a9f6e-4b16-4cad-92ac-d0a8adab7740` | `ea40e0a8c1596b3d` | `log_b14.md` |
| `watcher_eye_down_v3.png` | 1536×1024 | `01a16f4d-66bd-7810-93c5-226db34060dd` | `exec-0caa4dd4-bf70-4e7e-bda9-a784e5de9120` | `a5a31fbd0d181286` | `log_b14.md` |
| `watcher_eye_up_v1.png` | 1536×1024 | `01a16f4d-6f4c-7fd3-8cce-1c6125ef5e09` | `exec-689a3cba-9415-4b25-be24-98a3c02223a0` | `875d803aefef9a6a` | `log_b14.md` |
| `watcher_eye_up_v3.png` | 1536×1024 | `01a16f4d-f3f9-7ce0-95fb-3d653ad49c7a` | `exec-30b49b80-2de8-4460-9b60-61bd95d7835c` | `aadd8e618d3f9003` | `log_b14.md` |
| `watcher_eye_up_v2.png` | 1536×1024 | `01a16f4d-ef73-7a50-95f7-6a1abdef3e1b` | `exec-d04798ee-4cd3-4827-b868-6e63d721a819` | `80d7daeee4df9338` | `log_b14.md` |
| `husk_hound_walk_down_v1.png` | 1536×1024 | `01a16f4f-23ed-7562-a511-4ffb5dcbabdc` | `exec-6bc359cb-7460-4f61-85cb-6662e153f1a0` | `3d85c6bd93380b44` | `log_b14.md` |
| `husk_hound_walk_down_v2.png` | 1536×1024 | `01a16f4f-2a36-7613-b4e1-d4a8e1b084f2` | `exec-c66bdc23-916e-4dc2-a8bb-a09fd2540cc4` | `09fa47955a42f73b` | `log_b14.md` |
| `husk_hound_walk_down_v3.png` | 1536×1024 | `01a16f4f-36e1-7e41-9bcc-93eac91ecff9` | `exec-d79aaf83-775d-4cac-8b41-e7ba7f580c0d` | `6de40ea04402f411` | `log_b14.md` |
| `husk_hound_walk_up_v1.png` | 1536×1024 | `01a16f4f-425f-7d00-9e76-9cdc2015e64a` | `exec-f6e28f1b-4ef1-4905-abb9-34fda2df3959` | `b4a3040074b90976` | `log_b14.md` |
| `husk_hound_walk_up_v2.png` | 1536×1024 | `01a16f4f-465e-7a81-90b0-f2231bbe872c` | `exec-47a71336-221a-4ffa-a064-45d341070c42` | `4c3d72a786b1c274` | `log_b14.md` |
| `husk_hound_walk_up_v3.png` | 1536×1024 | `01a16f50-517c-7662-9fc1-35bfbc550fee` | `exec-3dc1a8ba-05f6-4c03-a3d9-82f4da1ca7b8` | `73e2c202cd3d54a0` | `log_b14.md` |
| `pocket_stairs_down_v1.png` | 1536×1024 | `01a16f4e-82f8-7873-a2c4-625faef89f47` | `exec-48ca179a-9b06-4f1a-ab56-fae09fa30106` | `e84a8796fda1bae1` | `log_b31.md` |
| `pocket_stairs_down_v2.png` | 1536×1024 | `01a16f4e-898a-79f0-8fab-0e77e8da2c52` | `exec-a3c8fa74-5eb9-495b-b9fe-ee2ac08be3b8` | `816bd009f93c9729` | `log_b31.md` |
| `pocket_stairs_down_v3.png` | 1536×1024 | `01a16f4e-8fa3-7262-80b2-9b794f02c652` | `exec-7572fee7-ad50-4b38-b795-6eed815df354` | `90bfd62458bd5905` | `log_b31.md` |
| `pocket_plain_door_v1.png` | 1536×1024 | `01a16f4e-9ae4-7083-90ac-3f00519fabb1` | `exec-5fd91fcd-fc14-4d98-97f6-5e382b763339` | `5b6ed44075535504` | `log_b31.md` |
| `pocket_plain_door_v2.png` | 1536×1024 | `01a16f4e-ad7b-7301-aa81-113f310a92db` | `exec-83183301-388c-4315-adf7-80b274bbd06e` | `e45ec3193778df6a` | `log_b31.md` |
| `pocket_plain_door_v3.png` | 1536×1024 | `01a16f4e-a8eb-7c20-90b4-1186856bce84` | `exec-d675d151-60f2-458e-8376-de8d93df20e8` | `e908cd1774b35c7d` | `log_b31.md` |
| `shop_counter_v1.png` | 1536×1024 | `01a16f4f-cc72-7761-b9f3-0022744cc3e8` | `exec-f6ecee04-b191-4a0e-b7b4-bd5d7e827341` | `311bdb81d6034867` | `log_b31.md` |
| `shop_counter_v2.png` | 1536×1024 | `01a16f4f-d199-7f10-a38b-63e2e0dbe17f` | `exec-92ca7dd4-ae56-4393-a48c-1a7f16745a2b` | `567f52aa90d2e1be` | `log_b31.md` |
| `shop_counter_v3.png` | 1536×1024 | `01a16f4f-d817-73f2-a49d-a903092d7125` | `exec-13b505ea-a8f2-428a-aaf7-7563e551dfc6` | `e23f57fc01ce613a` | `log_b31.md` |
| `ward_plate_v1.png` | 1536×1024 | `01a16f4f-e10d-7e32-ab2c-71624c02446e` | `exec-a302ffbf-6447-4a3c-9240-2d59d22b2b8a` | `831b72bbe6f94429` | `log_b31.md` |
| `ward_plate_v2.png` | 1536×1024 | `01a16f4f-e7be-77d0-a388-143ea6d9fc51` | `exec-816ef55d-488c-4b29-bec2-3f00cf31f82a` | `904db50a6a319cd6` | `log_b31.md` |
| `ward_plate_v3.png` | 1536×1024 | `01a16f4f-efc8-7ef1-a9fb-55ef6b506c9a` | `exec-8503c2c7-e084-447f-8206-afd7b9d3ff5f` | `c8f4da9b4e98b368` | `log_b31.md` |
| `street_lamp_v1.png` | 1536×1024 | `01a16f51-0100-7551-bd2c-b32aa545e1ee` | `exec-157de674-a0f5-40c5-9b7e-beccdb06a636` | `572e0a60e2d06b37` | `log_b31.md` |
| `street_lamp_v2.png` | 1536×1024 | `01a16f51-05a9-77b1-aa82-a582bc446661` | `exec-6434a093-85ff-4933-a364-187f51a23309` | `a7460ce14e811f0a` | `log_b31.md` |
| `street_lamp_v3.png` | 1536×1024 | `01a16f51-0d00-7ce0-9bee-233c62f2ceb7` | `exec-e8a40712-0a92-4597-850f-4507d2a1df7b` | `f6c04683b1cc6589` | `log_b31.md` |
| `wall_torch_v1.png` | 1536×1024 | `01a16f51-1484-7952-b7e3-18a541878dd2` | `exec-9ff36a2e-22b9-40df-93bc-447674eef37f` | `315f9963adab69cb` | `log_b31.md` |
| `wall_torch_v2.png` | 1536×1024 | `01a16f51-25a1-7231-8f02-a827a5beb2fd` | `exec-ff8fe6ff-b217-4399-966a-c1874bed1f42` | `3acd4778745f9f7a` | `log_b31.md` |
| `wall_torch_v3.png` | 1536×1024 | `01a16f51-2a9c-7e22-8a1b-abb0f851cf6f` | `exec-3a85b000-00b4-4b01-9319-04d57424edca` | `3f2c2f5c9efa811e` | `log_b31.md` |
| `boardwalk_straight_v1.png` | 1536×1024 | `01a16f51-d753-7311-98a3-20456c6a48ba` | `exec-ddc6e9b0-1a41-4ed8-b852-12f25dcd6e1b` | `5ab4cabeffb28ab6` | `log_b36.md` |
| `boardwalk_straight_v2.png` | 1536×1024 | `01a16f51-d8e0-70f2-958c-f4ca5507a518` | `exec-d4eb6891-cf78-4cc3-b87a-df3ca1d25c7f` | `e116bd7d812bb263` | `log_b36.md` |
| `boardwalk_straight_v3.png` | 1536×1024 | `01a16f51-d9b8-7203-8c4d-d16eaf648bd8` | `exec-ccb241d8-a454-449b-a817-57e6548cff5d` | `eb61d82a5c8831e9` | `log_b36.md` |
| `boardwalk_end_v1.png` | 1536×1024 | `01a16f51-e57f-70d0-84a3-3b16712b50f8` | `exec-63f9f221-9bc0-4953-89f4-a8939f05072f` | `ddd6086bf009eb26` | `log_b36.md` |
| `boardwalk_end_v2.png` | 1536×1024 | `01a16f51-e7a0-7da2-b11a-4d5d6da9b863` | `exec-4bd1f971-29dd-4401-95ae-84cf5365296a` | `4eb3b1e95c055812` | `log_b36.md` |
| `boardwalk_end_v3.png` | 1536×1024 | `01a16f51-f31b-7dc2-a0de-be7220750b8e` | `exec-9c8fa67e-8dc6-4da3-8d6c-6003c605b5c9` | `cbe764dcc6ce07fd` | `log_b36.md` |
| `boardwalk_corner_v1.png` | 1536×1024 | `01a16f53-488e-7011-983a-72e1e27796e0` | `exec-3708ef46-c5eb-4002-9778-f562e6427df8` | `0b54ecdc5546672f` | `log_b36.md` |
| `boardwalk_corner_v2.png` | 1536×1024 | `01a16f53-4e56-7422-bb82-af318d65e53d` | `exec-a1ca649d-33b4-4afe-820f-616850a3eaed` | `5df6943044dfdbe1` | `log_b36.md` |
| `boardwalk_corner_v3.png` | 1536×1024 | `01a16f53-57a9-7040-9444-e0cc2ec3d164` | `exec-92777b02-252f-4284-b457-d36120d70dd0` | `8d92458212d3a2ad` | `log_b36.md` |
| `dock_pier_v1.png` | 1536×1024 | `01a16f53-7486-72c3-90d7-b8e88647c183` | `exec-ef5919c6-7e15-44a7-a9bb-d1e44ebe7027` | `5092d0aecb0b801d` | `log_b36.md` |
| `dock_pier_v2.png` | 1536×1024 | `01a16f53-8dca-7862-811f-bb2add284dcb` | `exec-9b08a16d-3346-4a29-bac8-68887e1deeaa` | `ba603728766b0d01` | `log_b36.md` |
| `dock_pier_v3.png` | 1536×1024 | `01a16f53-ac77-7351-aa9d-014c3257b0a2` | `exec-719f9dca-e515-4130-ab25-543ae08064c3` | `9e018fa1fe677655` | `log_b36.md` |
| `husk_hound_states_v1.png` | 1536×1024 | `01a16f51-e5e8-7552-a8ce-143e17049426` | `exec-b3ca6702-2d06-4d39-be86-5def23ec24fb` | `fd747f3dd912a38d` | `log_b15.md` |
| `husk_hound_states_v2.png` | 1536×1024 | `01a16f51-eed0-76c1-9e8e-6579bcaea228` | `exec-e650dc56-e38d-4dbe-ab2f-c63a952a281a` | `29fe0377ab2b9aaf` | `log_b15.md` |
| `husk_hound_states_v3.png` | 1536×1024 | `01a16f51-f644-79a1-b1fe-0edf10a38695` | `exec-75fcb827-1e16-4534-a12d-b5b3e6b2ac71` | `c519939a7db0d895` | `log_b15.md` |
| `brine_crab_walk_side_v1.png` | 1536×1024 | `01a16f52-4c1f-7972-983d-3d24765a51af` | `exec-f7750604-ab30-4987-b18a-5ac530916dff` | `51c39dbd2e16e5e3` | `log_b15.md` |
| `brine_crab_walk_side_v2.png` | 1536×1024 | `01a16f52-51a6-72f2-878d-1879ee6fcf7c` | `exec-8426b5a7-84bf-48b4-96e6-d917b87fbc9d` | `10e1e94ce228d570` | `log_b15.md` |
| `brine_crab_walk_side_v3.png` | 1536×1024 | `01a16f52-75a0-70f1-8393-bf69a45d7039` | `exec-981caae9-f106-45f6-888b-93b1ba306ab5` | `6951191cf473cc73` | `log_b15.md` |
| `wickling_v1.png` | 1536×1024 | `01a16f53-dcac-78e0-a712-ab984d7c92d9` | `exec-23657c17-d86c-439f-8a96-e926b386483a` | `c7f64a9a6a0719b8` | `log_b15.md` |
| `wickling_v2.png` | 1536×1024 | `01a16f54-0e2c-76d1-8ea3-87e1aa0c03a2` | `exec-5534c5ed-0ec2-4af1-a436-2d50784fa2c1` | `37aa3be22f363812` | `log_b15.md` |
| `wickling_v3.png` | 1536×1024 | `01a16f54-10a2-7911-accd-a27e46101669` | `exec-58a316f6-bd17-4ffa-9f24-25da73a4fb35` | `2efc07fe68ece1b4` | `log_b15.md` |
| `brine_crab_walk_down_v1.png` | 1536×1024 | `01a16f54-185a-7483-a636-248378865f0a` | `exec-022e04d9-ea70-4dba-b1e4-52896f627e43` | `ee5cdd57b4433be8` | `log_b15.md` |
| `brine_crab_walk_down_v2.png` | 1536×1024 | `01a16f54-2465-73b3-9acd-4a0d5bae5f81` | `exec-aaaa1c97-59f4-4e09-95aa-44a4c70ec81c` | `cd51f79464cee212` | `log_b15.md` |
| `brine_crab_walk_down_v3.png` | 1536×1024 | `01a16f54-3051-7451-8945-78a825b515f5` | `exec-d6828f95-d5b0-44fc-a50d-31e4673f1fda` | `03b5f5d0032d53c7` | `log_b15.md` |
| `brine_crab_walk_up_v1.png` | 1536×1024 | `01a16f55-9acc-7f62-aa05-73f061965581` | `exec-f314bd94-6867-4a48-b079-e0239646fdf5` | `99ef6d5067ccd5ff` | `log_b15.md` |
| `brine_crab_walk_up_v2.png` | 1536×1024 | `01a16f55-a5e1-7fb2-ba90-0d574a2c3102` | `exec-a727f72c-10f8-45e8-a463-6fcd27577dc6` | `0f7189a7d610db62` | `log_b15.md` |
| `brine_crab_walk_up_v3.png` | 1536×1024 | `01a16f55-ec69-7671-bfb7-85896b3f56be` | `exec-823b3e80-6cc4-407e-a992-7ebe44b64e70` | `f0a4c6a80a42d4cb` | `log_b15.md` |
| `brine_crab_states_v1.png` | 1536×1024 | `01a16f55-ee52-75b2-a4a7-cdafe930cb80` | `exec-c1fb47b6-e03a-420c-ab9f-ed1fa73235bd` | `de791ecbd9338f2e` | `log_b15.md` |
| `brine_crab_states_v3.png` | 1536×1024 | `01a16f56-051b-7bc3-bb73-855342c0b8ac` | `exec-9557284c-faf6-43b8-b26d-8cd0bf82b9ae` | `608ca2435a361b57` | `log_b15.md` |
| `brine_crab_states_v2.png` | 1536×1024 | `01a16f55-fa2a-78f1-90d4-123e4319081b` | `exec-9f4c0c3c-ce8f-4d51-9e2f-fcddce83e0e1` | `b200812005220c86` | `log_b15.md` |
| `hud_counter_brass_v1.png` | 1536×1024 | `01a16f51-19e3-7213-a7a4-9a513e611572` | `exec-36c93161-d5f1-400d-ad6d-c0f512ee6342` | `24e417089eb24b7d` | `log_b72.md` |
| `hud_counter_brass_v2.png` | 1536×1024 | `01a16f51-2bb6-7522-9391-370fe8ded9c0` | `exec-836aa5e1-4259-43db-b2a5-4d845df89bdc` | `b42b86dd45e6fed7` | `log_b72.md` |
| `hud_counter_brass_v3.png` | 1536×1024 | `01a16f55-a6f8-7f01-8f40-dadd32e86e9c` | `exec-0ebd9634-c954-41b1-93fa-f1d3909808bb` | `4af1415825a90f20` | `log_b72.md` |
| `hud_counter_small_key_v1.png` | 1536×1024 | `01a16f51-1ae7-7152-9e90-624b90a4dfcc` | `exec-0223fed3-8603-4b77-a0ec-4f0000315a47` | `88cdf71dcc00e684` | `log_b72.md` |
| `hud_counter_small_key_v2.png` | 1536×1024 | `01a16f53-b671-75e2-a023-377d2cbb0845` | `exec-ff5e84c2-047b-43b3-80cc-1ea616cd2186` | `2707298f0dd4aeb8` | `log_b72.md` |
| `hud_counter_small_key_v3.png` | 1536×1024 | `01a16f53-c310-7e73-b757-cf498da8f918` | `exec-16c9b42e-0275-41e2-924c-06dfd8e77e5f` | `c14e8cbc1d039f0d` | `log_b72.md` |
| `hud_counter_big_key_v1.png` | 1536×1024 | `01a16f51-1e0b-7970-9662-80a6e9c79601` | `exec-50417bac-b8b0-4999-a093-49b8808335b8` | `959bd5d5c4e065f3` | `log_b72.md` |
| `hud_counter_big_key_v2.png` | 1536×1024 | `01a16f53-cfdb-7842-b4eb-e480d5cc574e` | `exec-b2267280-1ca4-4ab1-bfc5-5a949344f33b` | `98d17b922cffea75` | `log_b72.md` |
| `hud_counter_big_key_v3.png` | 1536×1024 | `01a16f53-d5d8-7cd0-ba08-5fdf3eabdad7` | `exec-91c9b82f-c9d9-4028-b52a-71f09d78d393` | `1f9f98d45a86506f` | `log_b72.md` |
| `hud_counter_pot_v1.png` | 1536×1024 | `01a16f51-2343-7670-96f2-99b3b2f5767e` | `exec-89e6234e-f6eb-4759-adb1-950e48045bcb` | `d6a3737a97497850` | `log_b72.md` |
| `hud_counter_pot_v2.png` | 1536×1024 | `01a16f53-f87a-7e21-a524-bce428b3dc01` | `exec-6662e66f-7f59-4825-8b49-78d74bd07bec` | `7ca7a874ace0ab47` | `log_b72.md` |
| `hud_counter_pot_v3.png` | 1536×1024 | `01a16f54-0d79-7102-b4ae-3b22af41a8a1` | `exec-5f6ffad1-bedc-44e1-ba2c-444db644832f` | `fa3b29bd9f203650` | `log_b72.md` |
| `hud_counter_slug_v1.png` | 1536×1024 | `01a16f51-26f2-7102-96e1-f61211a7bb63` | `exec-e6dd0bef-25d6-4e38-9cb7-51ba43bd0ef3` | `5d993f1274575184` | `log_b72.md` |
| `hud_counter_slug_v2.png` | 1536×1024 | `01a16f55-9e20-76d2-9648-127907c06942` | `exec-f35211da-1e15-427d-a1a6-3659432221e0` | `7627a81b36de3fcf` | `log_b72.md` |
| `hud_counter_slug_v3.png` | 1536×1024 | `01a16f55-a02a-7012-aef4-d6645a99b646` | `exec-b3eabf81-45b0-4b75-b241-8c5de7ddae2c` | `a76ea76c478b39ed` | `log_b72.md` |
| `abacus_brute_actions_down_v1.png` | 1536×1024 | `01a16f59-9230-7a53-803e-913cb13d738f` | `exec-c46e1f5b-d749-4e9e-aba2-3e5fcf61f349` | `7b72aac43609560d` | `log_b60.md` |
| `abacus_brute_actions_down_v2.png` | 1536×1024 | `01a16f59-9ad8-7e40-bf2c-f4b098c8f298` | `exec-d7665825-5cba-474b-9f19-1836e3b8df2e` | `3142fedf55d3a008` | `log_b60.md` |
| `abacus_brute_actions_down_v3.png` | 1536×1024 | `01a16f59-9fd8-79b2-8e0e-c6794fe53bcd` | `exec-cf3d731d-5265-48a7-ac69-68c90fbab2e2` | `afcdf589d0d33b69` | `log_b60.md` |
| `abacus_brute_actions_side_v1.png` | 1536×1024 | `01a16f58-5357-7b40-84a7-26cb949e2776` | `exec-1bbaabaf-120f-47fc-a6d4-cc8fee1e336c` | `154f15ec17b51d94` | `log_b60.md` |
| `abacus_brute_actions_side_v2.png` | 1536×1024 | `01a16f59-8748-7ce2-b37f-786cc1dbfb28` | `exec-53b73641-dde9-4970-9be7-970d98f59ea4` | `e19f017e0ad529eb` | `log_b60.md` |
| `abacus_brute_actions_side_v3.png` | 1536×1024 | `01a16f59-8aac-7c80-9280-1c6cd3278874` | `exec-59dd35c5-52fd-4d14-bd6a-4a1d2a282d0d` | `818d21857cb6893b` | `log_b60.md` |
| `abacus_brute_walk_down_v1.png` | 1536×1024 | `01a16f57-2f50-72f1-b64d-8d5463d60e43` | `exec-f5550f84-79ec-4651-94d4-6ec3385a2ed6` | `f71392da7fc7e307` | `log_b60.md` |
| `abacus_brute_walk_down_v2.png` | 1536×1024 | `01a16f57-3559-7a83-9d4f-ca02bd059ad4` | `exec-1a2125c8-c5be-4d25-afb3-e1f03f3f5a07` | `f83620c1d4e3c7df` | `log_b60.md` |
| `abacus_brute_walk_down_v3.png` | 1536×1024 | `01a16f58-3b6d-7e11-807f-c2c9781687c5` | `exec-606d6434-0d4d-45a6-8a9e-9d01fe447700` | `a58fbec154963ff0` | `log_b60.md` |
| `abacus_brute_walk_side_v1.png` | 1536×1024 | `01a16f55-6533-76c3-b373-878943613dc6` | `exec-b9fa2a71-d447-4229-8c13-6d02fff43d1f` | `ad4465a9f473d1b5` | `log_b60.md` |
| `abacus_brute_walk_side_v2.png` | 1536×1024 | `01a16f55-6ead-7d60-bf01-073c449a6009` | `exec-3e31afa9-4f9e-48c3-ab17-ebaa6ca8bdf2` | `32eb8cbbdc16a9ca` | `log_b60.md` |
| `abacus_brute_walk_side_v3.png` | 1536×1024 | `01a16f55-7351-7d00-9f68-c22097441e40` | `exec-85cfc188-3b51-468e-a505-52d0b06e8a92` | `18302ea9a80f78cd` | `log_b60.md` |
| `abacus_brute_walk_up_v1.png` | 1536×1024 | `01a16f58-3df8-7542-8813-14598c1ea7ec` | `exec-bf129851-f78c-456a-b739-32f8d0ad42a0` | `00fbdd84b33ef082` | `log_b60.md` |
| `abacus_brute_walk_up_v2.png` | 1536×1024 | `01a16f58-4566-7510-a7eb-283c7372acd6` | `exec-f6600d8a-adc2-45c8-880f-c5e7ebe272d7` | `3dbf75663331dad1` | `log_b60.md` |
| `abacus_brute_walk_up_v3.png` | 1536×1024 | `01a16f58-4bc0-7671-a190-45b2fe47c459` | `exec-6af00a97-1a5e-4e0c-9860-ac32baeeafe9` | `38b28412b06809e0` | `log_b60.md` |
| `wick_automaton_actions_down_v1.png` | 1536×1024 | `01a16f5c-d2dc-7f82-b308-541fe5ae1885` | `exec-f7894688-f42a-46ee-a95d-56399f06ac3d` | `ed7531de78ad5161` | `log_b61.md` |
| `wick_automaton_actions_down_v2.png` | 1536×1024 | `01a16f5c-d594-7962-a101-807cdb54fd02` | `exec-9db26137-0019-429e-949b-dfb65d8b8acd` | `36d62832608593b3` | `log_b61.md` |
| `wick_automaton_actions_down_v3.png` | 1536×1024 | `01a16f5c-dc1f-7fc1-9fce-e51d4d697d49` | `exec-58fe0a6c-44ab-4f98-803f-31ef0c76b43f` | `ad0bb935f3f80f34` | `log_b61.md` |
| `wick_automaton_actions_side_v1.png` | 1536×1024 | `01a16f5b-bf84-7c53-a3f9-c05546a898cc` | `exec-aff3e102-af89-45d0-8d46-7cc16bde7010` | `66c1123a1aeed796` | `log_b61.md` |
| `wick_automaton_actions_side_v2.png` | 1536×1024 | `01a16f5b-c6a3-7a02-9beb-0e1caeec1e6f` | `exec-a8ea5feb-69b9-431d-a0aa-723f3fdcef54` | `8f3b0137199e4df1` | `log_b61.md` |
| `wick_automaton_actions_side_v3.png` | 1536×1024 | `01a16f5c-810f-74c3-a653-92129f35a295` | `exec-833a18af-5c1d-45b9-ba31-098eddf25704` | `ad9d09609c826173` | `log_b61.md` |
| `wick_automaton_walk_down_v1.png` | 1536×1024 | `01a16f5a-7722-78f0-89fe-e7f90ed6382c` | `exec-e8efbcc1-6f1b-43f2-b5e4-12a09edcc272` | `df6bf39180f449cb` | `log_b61.md` |
| `wick_automaton_walk_down_v2.png` | 1536×1024 | `01a16f5a-9e91-7ae2-bbd7-37d6d0b94481` | `exec-6cfda41b-eaf3-4912-bbe2-0a65025bcdf0` | `385cb73fa2bdbbfd` | `log_b61.md` |
| `wick_automaton_walk_down_v3.png` | 1536×1024 | `01a16f5a-a605-7592-b4e8-4fa15da24782` | `exec-d75303e0-d5b7-4749-8c84-51ca481bffd4` | `337a67d9b90e1d9d` | `log_b61.md` |
| `wick_automaton_walk_side_v1.png` | 1536×1024 | `01a16f55-7a45-7f83-8488-fcf839228926` | `exec-22540cc7-6033-40a2-9610-d45e05b44c31` | `c0eeebb42c3b0f95` | `log_b61.md` |
| `wick_automaton_walk_side_v2.png` | 1536×1024 | `01a16f55-8178-7133-b715-9ea17e028fe7` | `exec-3df09c42-c72c-4d8d-b1ca-5a00195e922e` | `6376f7f8bd6cd2c7` | `log_b61.md` |
| `wick_automaton_walk_side_v3.png` | 1536×1024 | `01a16f55-8834-7852-bd0e-9eb6973f6148` | `exec-3b1c6c46-62a1-409b-9ad0-3224cee18792` | `533a677f7b60d4f9` | `log_b61.md` |
| `wick_automaton_walk_up_v1.png` | 1536×1024 | `01a16f5b-ab6e-7252-b5af-04fdf759f75e` | `exec-2a233520-d0f3-4297-869c-ce93e301e3e5` | `86d47c582f975e5c` | `log_b61.md` |
| `wick_automaton_walk_up_v2.png` | 1536×1024 | `01a16f5b-b179-7f32-8c8e-b9950cb87047` | `exec-ad6d6caa-2a9f-4b72-b7a0-b75cbeb0673c` | `ef3dc5157f38c59a` | `log_b61.md` |
| `wick_automaton_walk_up_v3.png` | 1536×1024 | `01a16f5b-b863-74c0-8f22-1278fee7e1a9` | `exec-34af720b-a00c-4cac-8bea-f7eb0ca6932e` | `3fdcc9570d389327` | `log_b61.md` |
| `mirror_shade_walk_side_v1.png` | 1536×1024 | `01a16f57-7492-75f3-b208-e4cf08d0f9ca` | `exec-b495ba1b-86b9-44ce-a4b1-43a3b31b18f2` | `e41612ebf2142c0b` | `log_b16.md` |
| `mirror_shade_walk_side_v3.png` | 1536×1024 | `01a16f59-92c0-7b40-aa80-2791944a434b` | `exec-3b6e091f-2425-4f0b-8c20-e22ddfd18d4a` | `56137c2065a0eab3` | `log_b16.md` |
| `mirror_shade_walk_down_v1.png` | 1536×1024 | `01a16f5c-0201-7360-a912-b2c8c6f8889e` | `exec-ca2f3f26-007c-49aa-80aa-0a9eaf0b7cc7` | `3de1de49159fb167` | `log_b16.md` |
| `mirror_shade_walk_down_v2.png` | 1536×1024 | `01a16f5c-1097-7772-a892-10c209630549` | `exec-934a0e2a-d02f-4824-905b-d46587e1d971` | `8e7eb673b908449f` | `log_b16.md` |
| `mirror_shade_walk_down_v3.png` | 1536×1024 | `01a16f5c-275e-7630-a80a-0f14cceffdf4` | `exec-a276e091-50f0-4466-ac70-7de1488e8e73` | `e3097b3ffa4dce64` | `log_b16.md` |
| `mirror_shade_walk_up_v1.png` | 1536×1024 | `01a16f5c-56b1-72b0-acd9-15ae397317e3` | `exec-170ba681-bc41-4989-a661-f85be4ebc44d` | `8dfe731a142d4f23` | `log_b16.md` |
| `mirror_shade_walk_up_v2.png` | 1536×1024 | `01a16f5c-6e4c-70a2-9444-319ac2b0f387` | `exec-806f419a-b8f6-4823-a023-4a9dd30b24ab` | `856fd2d180be2eae` | `log_b16.md` |
| `mirror_shade_walk_up_v3.png` | 1536×1024 | `01a16f5c-991d-7b13-8f54-1143f4bde008` | `exec-ccbd8853-034a-4d3e-ad47-3c0797f03b54` | `82d6bb172e681c49` | `log_b16.md` |
| `mirror_shade_states_fade_down_v1.png` | 1536×1024 | `01a16f5e-2709-7ff3-b89a-e784f2c81122` | `exec-395e3450-8727-44c7-90f9-b55913e86aad` | `b4bea88880028cb2` | `log_b16.md` |
| `mirror_shade_states_fade_down_v2.png` | 1536×1024 | `01a16f5e-30be-7701-ba6d-98d7d2e710a2` | `exec-dc44bebd-cee0-4850-9cfe-1edfcefb9c81` | `8b25b195a76e9eff` | `log_b16.md` |
| `mirror_shade_states_fade_down_v3.png` | 1536×1024 | `01a16f5e-3461-7613-bcc0-8d63aec8abf5` | `exec-bafb9c7c-be62-48cf-8dcb-05ba8384c9a4` | `539154ff62542501` | `log_b16.md` |
| `mirror_shade_states_echo_side_v1.png` | 1536×1024 | `01a16f5e-3fa0-7b80-ac2d-289c32bcfaf5` | `exec-57756471-ea05-40c7-aa22-8bfa76e3cff6` | `e33fb771335c4b7e` | `log_b16.md` |
| `mirror_shade_states_echo_side_v2.png` | 1536×1024 | `01a16f5e-4d33-79c2-944d-0287c6949553` | `exec-3a5c8c61-94aa-4d2d-aded-6ca1b6b80985` | `9e985eabf7bb8df8` | `log_b16.md` |
| `mirror_shade_states_echo_side_v3.png` | 1536×1024 | `01a16f5e-7810-76a0-8c6e-af432d90f059` | `exec-66322417-49fb-4978-aaf0-9bdf6e3552bf` | `e24fb5e3fc961352` | `log_b16.md` |
| `mirror_shade_states_crack_down_v1.png` | 1536×1024 | `01a16f5f-ff0d-7271-82d7-4bac22eaa902` | `exec-dc3eb026-e96a-4b24-b527-55acb7940041` | `511ca54486751b92` | `log_b16.md` |
| `mirror_shade_states_crack_down_v2.png` | 1536×1024 | `01a16f60-11de-73d1-9f56-09d1938ee63b` | `exec-f62e1617-8df9-4d10-8b57-054fcf85d29b` | `27abd6d430c4a497` | `log_b16.md` |
| `mirror_shade_states_crack_down_v3.png` | 1536×1024 | `01a16f60-336b-7441-96bb-ff83a4b5a268` | `exec-50083e44-c1a0-436d-9c5e-c560ef3113b6` | `2afd553e0adbbc5e` | `log_b16.md` |
| `hud_socket_warmth_v1.png` | 1536×1024 | `01a16f58-c4d8-7eb2-9dd1-53660fd32788` | `exec-3d7c43a1-ee79-4ac8-b919-e5b6fbdc0752` | `127c5435b1a05972` | `log_b73.md` |
| `hud_socket_warmth_v2.png` | 1536×1024 | `01a16f58-c700-79a0-adb1-3f749c336b4d` | `exec-f6a4feb6-69ad-4c04-bf7d-e35a086556d0` | `0716112d4a850b56` | `log_b73.md` |
| `hud_socket_warmth_v3.png` | 1536×1024 | `01a16f58-ccb5-7341-af26-1f67996d5616` | `exec-753f25f0-4bfa-4fd2-94f9-30bdd7c4fc94` | `5b6e2bf3da2fd630` | `log_b73.md` |
| `hud_socket_growth_v1.png` | 1536×1024 | `01a16f58-d136-7ab1-8307-19ff1962129d` | `exec-55b3faf2-35a8-43f5-9fdb-ebc87b31e925` | `03961481895710d9` | `log_b73.md` |
| `hud_socket_growth_v2.png` | 1536×1024 | `01a16f58-d6c0-7cf3-a6b6-d948b94882d4` | `exec-7c9fec36-298a-4faf-9ad3-27cae0925258` | `cd6115afd0ee7ad7` | `log_b73.md` |
| `hud_socket_growth_v3.png` | 1536×1024 | `01a16f58-dfda-7221-a284-58cb19a98a1a` | `exec-06f907b7-4eb9-4dd1-9c43-e549fd435684` | `f331a895093b1436` | `log_b73.md` |
| `hud_socket_rain_v1.png` | 1536×1024 | `01a16f5b-26ca-73e0-b19e-fa4f3262ebf8` | `exec-df187476-add1-4476-9aff-6ba062a6b52a` | `f3fe07db042c704f` | `log_b73.md` |
| `hud_socket_rain_v2.png` | 1536×1024 | `01a16f5b-2818-7143-bf38-be54d57151da` | `exec-fa84435e-2413-4e3b-a8eb-683842246c42` | `9ba3995f20eb16ca` | `log_b73.md` |
| `hud_socket_rain_v3.png` | 1536×1024 | `01a16f5b-2c1f-7cc0-b76c-f72d7c71faa4` | `exec-e3acf9bb-ca44-4091-bced-eff820ceb9a8` | `0015a8a9a8c785a8` | `log_b73.md` |
| `hud_socket_sleep_v1.png` | 1536×1024 | `01a16f5b-33c6-7a10-93eb-22c27a19d9c1` | `exec-9c817296-4846-4c95-a498-e33b0bdd1946` | `238a91104bfd2647` | `log_b73.md` |
| `hud_socket_sleep_v2.png` | 1536×1024 | `01a16f5b-36b1-7601-beba-905480c7786e` | `exec-2d71e509-6357-4475-84d2-d9f0970ac7c8` | `47b61015214abeef` | `log_b73.md` |
| `hud_socket_sleep_v3.png` | 1536×1024 | `01a16f5b-4e4d-7a61-973c-a18d7b1fecc5` | `exec-54f4de35-f524-4f8b-bbe4-216e5c70c24b` | `0faa43ff3e1e5275` | `log_b73.md` |
| `hud_socket_memory_v1.png` | 1536×1024 | `01a16f5d-b71e-7f81-88e9-13759889cb48` | `exec-2f32e204-1d99-4c4f-811d-52336f7477b0` | `be5d57c2578eebf3` | `log_b73.md` |
| `hud_socket_memory_v2.png` | 1536×1024 | `01a16f5d-c4b6-7b12-b0d4-2a23b5ae39b4` | `exec-85dc8c5a-0a39-43a7-a1c9-e1d15cd031f9` | `f5067c99ad56afac` | `log_b73.md` |
| `hud_socket_memory_v3.png` | 1536×1024 | `01a16f5d-c80f-7381-b510-14068559c78f` | `exec-b22d9a1d-0539-4d1a-a5ee-19c866068bbd` | `ddbd0f8dadd11200` | `log_b73.md` |
| `hud_socket_song_v1.png` | 1536×1024 | `01a16f5d-d358-75c1-8f57-28fa59e704c5` | `exec-d328fa90-03cf-4b01-80e1-0e28954e3a88` | `c0eca169b51dd6c5` | `log_b73.md` |
| `hud_socket_song_v2.png` | 1536×1024 | `01a16f5d-eb88-7452-bcc4-fb6bed7cbcc0` | `exec-fb4089cc-f094-4c0a-96e3-cb522e071e0d` | `dcacd4ef5248281d` | `log_b73.md` |
| `hud_socket_song_v3.png` | 1536×1024 | `01a16f5e-23a1-7190-8474-1de8427d5c61` | `exec-61793816-9ce0-48dc-8383-2cbe97c34f83` | `fe3d8991b71c7061` | `log_b73.md` |
| `hud_socket_courage_v1.png` | 1536×1024 | `01a16f5f-ecd2-7822-b7ab-3328cca99a8d` | `exec-f5a9cb18-999d-46b3-be8f-48e75381b275` | `ee7af8a40058eba1` | `log_b73.md` |
| `hud_socket_courage_v2.png` | 1536×1024 | `01a16f60-1504-70d3-ac17-c7722c9ca199` | `exec-eb3470c8-880e-47b5-a8e7-91f92c4ed4f1` | `f1f6ab3208848edb` | `log_b73.md` |
| `corrows_echo_actions_down_v1.png` | 1536×1024 | `01a16f60-215d-72b1-8a01-3faaf890c3cc` | `exec-49940d80-f05e-454b-b24a-4e5fb74185df` | `4dc7997905ac7895` | `log_b62.md` |
| `corrows_echo_actions_down_v2.png` | 1536×1024 | `01a16f60-37ad-7a62-829c-b1fcbec6df23` | `exec-3f088b25-5362-4629-a5e5-c666d0a9a1ea` | `bc56114f97dd190c` | `log_b62.md` |
| `corrows_echo_actions_down_v3.png` | 1536×1024 | `01a16f60-9cec-78d2-8543-329b3d118ad2` | `exec-a85573a0-03ab-4874-8681-14d526c20d12` | `f321200157ee060b` | `log_b62.md` |
| `corrows_echo_actions_side_v1.png` | 1536×1024 | `01a16f5e-c179-7642-975d-f478e290ca22` | `exec-6508dc03-4388-4710-abd4-cec42a915d4a` | `8e1c580cfe07efce` | `log_b62.md` |
| `corrows_echo_actions_side_v2.png` | 1536×1024 | `01a16f5f-c7a8-7f41-9614-b41bb7ac28ce` | `exec-f51360b4-8407-4922-804a-616c88701895` | `52d04e07c7e1bb61` | `log_b62.md` |
| `corrows_echo_actions_side_v3.png` | 1536×1024 | `01a16f5f-f10d-7a93-bb63-a62b495415bf` | `exec-5b8cb2fc-e9a4-44b0-b362-c90ca3c1d37a` | `d4119d2d2fdb4dd8` | `log_b62.md` |
| `corrows_echo_walk_down_v1.png` | 1536×1024 | `01a16f5c-e47b-77d0-89d4-c43b249afd08` | `exec-721e4e93-a6b4-4f2d-895e-b50ebbd2427a` | `c3901a109f9e8486` | `log_b62.md` |
| `corrows_echo_walk_down_v2.png` | 1536×1024 | `01a16f5e-7936-7f80-8d34-293f4098c383` | `exec-6fc9b9ee-8b12-4fcc-914d-93be6f10490f` | `4e4442ae7e030e1c` | `log_b62.md` |
| `corrows_echo_walk_down_v3.png` | 1536×1024 | `01a16f5e-8b26-7a33-9fe9-7e15b1457cbc` | `exec-d35ba365-6e93-461a-bbce-5ccfad998d6d` | `732d9faeea9fc7ba` | `log_b62.md` |
| `corrows_echo_walk_side_v1.png` | 1536×1024 | `01a16f56-bc61-7b93-a1cd-d3dd6dc25dce` | `exec-96765bd6-c7e1-430a-a140-b8d57a791452` | `d0edfd062d5f4dbf` | `log_b62.md` |
| `corrows_echo_walk_side_v2.png` | 1536×1024 | `01a16f56-be1d-7dd2-9850-e79c5a938424` | `exec-07e32f8a-b069-45f1-99d6-f184cf85c71f` | `600a056cff3db859` | `log_b62.md` |
| `corrows_echo_walk_side_v3.png` | 1536×1024 | `01a16f56-c5fc-7281-aa14-1296c0bbbaa6` | `exec-ffe4538b-0513-4f4f-aa9c-483d6bbb094b` | `c274be4c827e347b` | `log_b62.md` |
| `corrows_echo_walk_up_v1.png` | 1536×1024 | `01a16f5e-8c3f-7832-8571-768f336c23f2` | `exec-5682efd1-6bb6-47a2-bdc4-72342b81fc9b` | `716e215358e37f2a` | `log_b62.md` |
| `corrows_echo_walk_up_v2.png` | 1536×1024 | `01a16f5e-9094-7552-92e1-7a29b7c2b2a5` | `exec-caf82f24-5e1a-4b1c-a0a1-5d4d84060402` | `99bc843a221d19c9` | `log_b62.md` |
| `corrows_echo_walk_up_v3.png` | 1536×1024 | `01a16f5e-9561-7270-942a-934adee802d4` | `exec-43163531-98c4-4ebb-aa1d-06d49b01964a` | `ac069402cf5f6153` | `log_b62.md` |
| `miniboss_death_wax_v1.png` | 1536×1024 | `01a16f56-cc32-7d22-b9f2-7e45e4602189` | `exec-c7fdf694-6154-4006-b7bd-d14329c4992e` | `c1be012ed9d1c762` | `log_b62.md` |
| `miniboss_death_wax_v2.png` | 1536×1024 | `01a16f61-8729-7fe3-85ce-b56158b54c26` | `exec-176eb7a6-ce70-45c3-906c-1528d52b894c` | `c691e43ca7599318` | `log_b62.md` |
| `miniboss_death_wax_v3.png` | 1536×1024 | `01a16f61-9bdc-7b20-8bdd-cdaab9bb09bc` | `exec-781b7ede-8ed6-40de-b3da-46dd7892fb7e` | `e2143c670e669b89` | `log_b62.md` |

Rejected outputs stay only in the local Codex folders and are not in the repository: the first
duskmoth flight row (inconsistent headings), two other duskmoth redo attempts, two other explosion
attempts and the second Tamsin walk attempt, and the rejected attempts of the v2 walk sheets (listed in `log_tamsin_walk_v2.md` and `log_hollow_walk_v2.md`; the first `tamsin_walk_down` output in the same session as `tamsin_walk_up` and `tamsin_walk_side` was replaced by the redo in a later session).

## Processing

`make art` (`tools/cut_sprites.py` with `tools/art_manifest.json`) writes every file under
`assets/sprites/` and `assets/sprites/sprites.json`. The tool removes the key colour with
continuous alpha, despills only partly transparent edge pixels, finds real gaps between poses,
scales each strip with one factor, aligns the foot line and makes the terrain textures seamless.
It never quantizes the palette or thresholds the alpha. `make art-test` runs its tests.

## Human review

The lead session looked at every source sheet and at the room screenshots in
`docs/screens/step2/`. No human visual approval is claimed yet. The user will judge the art, and
the width of the hook swing in particular, in play.
