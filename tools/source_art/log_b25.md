# Batch 25 log (18 images)

Prompts: `tools/art_prompts/batch_25.md` (job id in each heading). Backend codex, model `cheapest` (gpt-6-luna, effort medium), one image per job. Each output is checked byte-identical (SHA-256) against its own session folder under `~/.codex/generated_images/<session>/`. Verdicts: ok, weak (why), failed.

| Output | Job | Session | Generated file (output ID) | Size | SHA-256 (16) | Verdict |
|---|---|---|---|---|---|---|
| `eye_switch_v1.png` | `b25_eye_switch_v1` | `01a16f5b-f1ac-7983-8d1e-946acf0f08b1` | `exec-a8f18e5e-0f3b-403f-97d9-db48c700a08f.png` | 1536x1024 | `0fc7ba5406f6c0bb` | ok (off, hit, hit with sparks, on; poses 2 and 3 are told apart only by the sparks; ivy and rubble on the block) |
| `eye_switch_v2.png` | `b25_eye_switch_v2` | `01a16f5b-f75c-7e23-bc12-d35068263c02` | `exec-9255e061-963c-47ba-80e5-343bd3abbae0.png` | 1536x1024 | `67978de16723dd98` | ok (off, hit, hit with a flash, on; vines and rubble) |
| `eye_switch_v3.png` | `b25_eye_switch_v3` | `01a16f5b-ff47-7232-8cc0-6b1b79bd9f71` | `exec-57758fcd-493b-453c-a568-e9518167077a.png` | 1536x1024 | `943680055ea6088e` | ok (off, hit, hit, on; the clearest sequence of the three) |
| `eye_portcullis_v1.png` | `b25_eye_portcullis_v1` | `01a16f5c-062b-7681-9704-3c04811cfe9d` | `exec-8ff64f94-c9ec-4a83-8456-7222e6799d09.png` | 1536x1024 | `84a4b04f790e72f9` | ok (closed, four opening poses, open; 1/4/1 rows) |
| `eye_portcullis_v2.png` | `b25_eye_portcullis_v2` | `01a16f5c-1485-7c63-9042-f97d4facefa4` | `exec-6cea5863-ae1e-4976-92ff-aa6b1376d2ef.png` | 1536x1024 | `95ccea4f4ad8f3b3` | ok (heavy vines; the lift sequence is readable) |
| `eye_portcullis_v3.png` | `b25_eye_portcullis_v3` | `01a16f5c-32e9-7df0-b58f-8d0215db8749` | `exec-41bfb461-bd75-4b0b-82a5-74358766c95c.png` | 1536x1024 | `56904bb480951e78` | ok (closed, four opening poses, open) |
| `eye_cell_v1.png` | `b25_eye_cell_v1` | `01a16f5d-507f-7732-87d7-49e12c368938` | `exec-5d19e152-aaf4-44cf-bc91-942d5bbf0e12.png` | 1536x1024 | `11c9a55b650dc233` | ok (closed, three opening poses, open; 1/3/1 rows) |
| `eye_cell_v2.png` | `b25_eye_cell_v2` | `01a16f5d-577c-7683-bbd0-36588c4dfca2` | `exec-c0f788bb-1070-43cb-bc38-d2565f7a676a.png` | 1536x1024 | `f3dce88562e6bfcf` | failed (wrong pose count: one closed pose and four opening poses, no open pose; the job's own report says the same) |
| `eye_cell_v3.png` | `b25_eye_cell_v3` | `01a16f5d-63aa-7960-81fd-d04cae1f94d6` | `exec-d1c2d385-1c8c-48bc-93d5-0b29d89d07ce.png` | 1536x1024 | `0bc51d9f15f1a827` | ok (1/3/1 rows; the foliage and ground stones are heavy but the states are legible) |
| `mooring_v1.png` | `b25_mooring_v1` | `01a16f5d-85d9-7f01-af50-d415c3e08e07` | `exec-1b380260-9668-4438-b9d8-5ebedca73621.png` | 1536x1024 | `df92cf7fad956a23` | weak (the occupied pose's rope is cut off at the right edge of the image; the posts have large rock bases) |
| `mooring_v2.png` | `b25_mooring_v2` | `01a16f5d-c53a-7322-9f63-22f0f9a0fa27` | `exec-3d856d42-1f06-4407-8434-ed566f340588.png` | 1536x1024 | `485ac6a28feab48b` | weak (the occupied pose's rope reaches the right edge; poses 1 and 2 differ only slightly) |
| `mooring_v3.png` | `b25_mooring_v3` | `01a16f5d-c66a-7d33-b935-1b97009b06d0` | `exec-7c3c0d9e-08d8-4b4c-806d-8a06952b66d4.png` | 1536x1024 | `1a2d832ced3b386e` | weak (the occupied pose's rope runs to the right edge of the image) |
| `edge_pit_rim_v1.png` | `b25_edge_pit_rim_v1` | `01a16f5f-199b-7bd1-bcaf-733933a83bba` | `exec-466471c2-fa2c-41d7-9836-c132c1af076e.png` | 1536x1024 | `9eca33015c50f940` | ok (three pieces: a straight rim above, two corners below; a soft shadow under each; the cut needs a multi-piece rule) |
| `edge_pit_rim_v2.png` | `b25_edge_pit_rim_v2` | `01a16f5f-188e-7f43-bdc7-f12d81c8faa1` | `exec-326398a4-df25-472f-93b0-8bd02c25896e.png` | 1536x1024 | `1c7e775ee43fc29b` | ok (the two corner orientations are a little ambiguous) |
| `edge_pit_rim_v3.png` | `b25_edge_pit_rim_v3` | `01a16f5f-2088-7e32-879a-991ab9819f11` | `exec-63e86f94-e8c7-4f9f-af8e-9ce4da724a75.png` | 1536x1024 | `756170d88a4bb0ce` | weak (bright green foliage and warm highlights on the stone; the straight piece reads as a tall cliff wall, not a rim strip) |
| `pit_fill_v1.png` | `b25_pit_fill_v1` | `01a16f5f-2911-7c31-9429-4f37521abc4a` | `exec-7d1b0a1a-e7fd-40b4-ad40-530c1640bc6e.png` | 1254x1254 (requested 1024x1024, not fixed by hand) | `564826f08af93e13` | ok (dark blue-black void with diffuse violet mist; seam continuity not checked by eye) |
| `pit_fill_v2.png` | `b25_pit_fill_v2` | `01a16f5f-3043-71c3-a5f3-110883c34180` | `exec-2467cae3-03fb-4421-a7ec-58def3b4a2b6.png` | 1254x1254 (requested 1024x1024) | `698c6c75dd75720a` | weak (warm amber patches read as embers rather than a faint depth fade) |
| `pit_fill_v3.png` | `b25_pit_fill_v3` | `01a16f5f-390c-74e0-bbeb-69cd7bdc9499` | `exec-e0669716-53c1-44fc-b06c-f90ba432cd0d.png` | 1254x1254 (requested 1024x1024) | `e7676ac5dfacecd7` | ok (dark blue void with faint violet mist, no warm patches) |

## Batch 25 totals

18 images verified (SHA-256 matches the own-session folder for every file; no duplicate hashes in `tools/source_art/`).
Ok: 12 (`eye_switch` v1 to v3, `eye_portcullis` v1 to v3, `eye_cell_v1`, `eye_cell_v3`, `edge_pit_rim_v1`, `edge_pit_rim_v2`, `pit_fill_v1`, `pit_fill_v3`).
Weak: 5 (`mooring` v1 to v3, `edge_pit_rim_v3`, `pit_fill_v2`).
Failed: 1 (`eye_cell_v2`, wrong pose count: one closed pose and four opening poses, no open pose).
The two pit_fill textures came back at 1254x1254 instead of 1024x1024; they are kept as returned for the cut tool to scale.
