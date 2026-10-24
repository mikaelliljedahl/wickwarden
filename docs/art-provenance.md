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
