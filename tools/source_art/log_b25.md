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
