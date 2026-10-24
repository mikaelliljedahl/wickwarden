# Art prompts (GPT Image)

The ready-to-run prompts for the generation batches of [docs/art-inventory.md](../../docs/art-inventory.md) section 4. One file per batch (`batch_NN.md`). Written so far: batches 1 to 3 (42 prompts, all Tamsin sprite sheets). The owner reviews the first images before the next batches are written.

Style, shared block, sheet block, texture block and character designs: [docs/art-brief.md](../../docs/art-brief.md). Sizes, key colours and names: [docs/asset-contract.md](../../docs/asset-contract.md) (normative). If a prompt and the contract disagree, the contract is correct.

## Run recipe

1. **Codex via an AgentTeamForge job, model `cheapest`.** The Codex model is only a proxy that calls the native image tool (gpt-image); the image model is the same at every tier, so the cheapest tier is the right one. Do not use Codex for anything else in these jobs.
2. **One image per job.** Each prompt in `batch_NN.md` is one job with the job id given in its heading. The job text is the fenced prompt, unchanged, plus the list of reference images (attach them to the image call). Do not let the job rewrite or shorten the prompt.
3. **Outputs are saved to `tools/source_art/`** under the exact output file name in the prompt entry (`<sheet>[_<facing>]_vN.png`, N = variant 1 to 3). Copy the file the tool wrote under `~/.codex/generated_images/<session>/` (use the folder of YOUR OWN session id only; never pick the newest file of the whole folder, because parallel jobs write there at the same time and a job can copy another job's image) without resizing or editing. The tool may return another size than requested (1536x1024 sheets have come back as 1536x1024 or 2172x724); do not fix it by hand. Check that the poses are still one row with the right count.
4. **The job writes a log** `tools/source_art/log_<batch>.md` (for example `log_b01.md`), in the layout of `log_terrain.md`: file, date, reference images, attempts, image size, tool, session and output id (the generated file name), source path copied from, defects not fixed, rejected attempts, and the exact prompt used.
5. **Every image is recorded in `docs/art-provenance.md`** (a row in the source inventory: size, Codex session, output id, SHA-256 first 16, log). Do this for kept images; rejected outputs are named in the log only.
6. **Cull.** The owner picks one variant per row. The kept file is copied to the accepted name (no `_vN`, shown in each entry) and listed in `tools/art_manifest.json` by the pipeline agent. Down and up units of a row are generated after the side unit; each entry names its reference.
7. A sheet is rejected and generated again (at most three times) if a pose touches another pose, the pose count is wrong, the background is not flat, there is text, the figure looks like pixel art, the design differs from the reference, or two poses of a walk-like cycle repeat the same leg arrangement.

## Prompt rules

Every prompt, in every batch, forbids and demands the same things:

- **Forbids pixel art** in all its forms: no pixel grid, no dithering, no limited palette, no 8-bit or 16-bit look, no thick black outlines, no hard outline around every shape (the shared block states this; keep it verbatim).
- **Forbids text of any kind:** no text, letters, numbers, labels or watermark, no real or fake writing on props, coats or signs.
- **Forbids grids and frames:** no frame borders, no grid lines, no cells, no guide marks, no floor, no cast shadow on the background.
- **Forbids contact:** poses never touch or overlap, nothing is cut off at the image edge, no extra poses.
- **Demands the structure:** the shared block verbatim, then the sheet block (or texture block, face block) verbatim with `{KEY}` replaced, then the subject, then the line `Image size: WxH.` The key colour is never used in the subject (Tamsin has no green; no prompt describes a green object).
- **Original designs only:** no prompt names another game, franchise, artist or character.

**Consistency with existing sheets.** The design of a figure is copied word for word from the art brief. Every Tamsin prompt starts its subject with *"Same character as in the reference image, identical design and colours."* and attaches `tamsin_walk.png` (design and scale) and `tamsin_walk_side.png` (accepted style and the lighting). A row that is also drawn in other facings (carry, push, pull) attaches its own side sheet as an extra reference for the down and up units, so tools, rock and mitts stay the same. Variants of one row differ only in composition, pose emphasis and detail; they never change the outfit, proportions or tool design. Walk-like cycles say in words which leg leads in which pose, because the model repeats leg arrangements otherwise (see `log_tamsin_walk_v2.md`).

## Assumptions made in the tool and pose descriptions

The art brief does not describe these; they are written once here and used the same in every variant:

- In every tool animation except the raft the brass hook pole is slung across Tamsin's back, with the lantern glowing over her shoulder.
- Cinder wick: a forearm-long rod of braided black wick cord with a brass cap and a glowing coal tip. Tallow sling: a short forked dark-wood handle, two leather bands, a pouch with a pale tallow slug. Heft mitts: oversized tan-leather work mitts with brass rivets and buckled cuffs. The raft is not drawn (the game draws it); she stands on the ground line with a plain wooden punting pole.
- The lifted and thrown object is a bucket-sized grey mossy rock, drawn in the poses where she holds it. The heavy stone she pushes or pulls is not drawn.
