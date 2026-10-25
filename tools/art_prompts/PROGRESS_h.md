# Art production progress, producer h (batches 72 to 86)

Range: batches 72 to 86 only (`docs/art-inventory.md` section 4). Prompts: `batch_72.md` to `batch_86.md`. Invented details: `DESIGNS_h.md`. Logs: `tools/source_art/log_bNN.md`.

Facing and leg fix (from `PROGRESS.md`): applied to every figure-like sheet in this range (none is a walk cycle; the pocket and statue-like items face the viewer square on). Each image is described on its own.

Wave rule: at most 6 Codex jobs at the same time, one image per job, model `cheapest`. Each image is copied by the lead from the job's own session folder (`session_id` of get_job), never from the file named in a job report: several reports named another session's file.

| Batch | Units | Images | Status |
|---|---|---|---|
| 72 | hud_counter_brass, hud_counter_small_key, hud_counter_big_key, hud_counter_pot, hud_counter_slug | 15 | done: generated, verified (montages), logged (`log_b72.md`), provenance added; big_key v3 weak (key too tall), slug v2 weak (antennae and glow) |
| 73 | hud_socket_warmth, growth, rain, sleep, memory, song (three variants each), hud_socket_courage (variants 1 and 2) | 20 | done: generated, verified (montages), logged (`log_b73.md`), provenance added; no weak images; courage unlit glass has a white highlight (kept) |
| 74 | hud_socket_courage (variant 3), hud_socket_trade, hud_socket_ninth (Corrow's Last Wick) | 7 | done: generated, verified (montages), logged (`log_b74.md`), provenance added; all seven ok (three job reports named other sessions' files; the own-folder files were checked) |
| 75 | hud_minimap_unvisited, visited, current, cave_mouth, shop, boss (three variants each), hud_minimap_locked (variants 1 and 2) | 20 | done: generated, verified (montages), logged (`log_b75.md`), provenance added; visited v1 weak (gold, not pale wax), current v2 weak (glow wash on the key), shop v1 to v3 weak (compass rose, not an awning with a coin); minimap subjects rewritten as flat discs after the first two sets came back as figures and objects (see log) |
| 76 | hud_minimap_locked (variant 3), hud_minimap_pocket (three variants), hud_minimap_frame, hud_status_band, subscreen_panel (three variants each) | 13 | done: generated, verified (montages), logged (`log_b76.md`), provenance added; frame v2 weak (halo), band v2 weak (light spot), band v3 failed (white surround, not full canvas), panel v2 weak (ornate medallions); status band is a full-canvas stone strip, cut by the code |
| 77 | subscreen_slot_empty, subscreen_slot_selected, subscreen_slot_locked (three variants each), subscreen_cursor (three variants), pause_panel (three variants) | 15 | done: generated, verified (montages), logged (`log_b77.md`), provenance added; subscreen_cursor v2 weak (flecks); subscreen_cursor v3 is byte-identical to another producer's `lock_warden_body_closed_open_v3.png` (wrong copy there, not changed here); all other images ok |
| 78 | pause_button_normal, pause_button_selected, pause_button_disabled (three variants each), shop_price_plate (three variants) | 12 | done: generated, verified (montages), logged (`log_b78.md`), provenance added; normal v2 and v3 weak (studs, knobs), selected v1 and v3 weak (glow faint), disabled v3 weak (corner bolts); the rest ok |
| 79 | warp_picker_panel (three variants), warp_icon_c1 to warp_icon_c5 (three variants each), warp_icon_c6 (variants 1 and 2) | 20 | done: generated, verified (montages), logged (`log_b79.md`), provenance added; warp_picker_panel v2 weak (lantern and ivy on the outer edge), warp_icon_c1 v2 weak (magenta smear), warp_icon_c5 v2 weak (warm tan, not grey stone); the rest ok |
| 80 (partial, stopped by the coordinator) | warp_icon_c6 (variant 3), warp_icon_c7 (three variants) done; still open: warp_icon_c8, warp_icon_c9, warp_icon_c10 (three variants each), title_menu_panel, dialog_prompt_card (three variants each) | 4 of 19 | in progress: c7 v2 and v3 weak (figure or lantern in front of the mouth); the other 15 images not generated |

## Resumed Codex production, 2026-10-25

B80 c8 v2 and c9 v2 generated, own-session SHA256 matched, unique source hashes, opened `/tmp/wickwarden-art-wave4-review.jpg`. c8 v2 weak (oversize relative to prompt); c9 v2 ok with small plant sprig. Log: `log_art_resume_04.md`. Other c8/c9 and c10 variants in flight; no existing outputs regenerated. Provenance append rows under `/tmp/wickwarden-art-provenance-additions.md`; shared provenance unchanged.

B80 c8 v1/v3 and c9 v1 verified by own-session SHA256, unique hashes; opened `/tmp/wickwarden-art-wave5-review.jpg`; log `log_art_resume_05.md`. c8 v3 weak (closed door); c8 v1/c9 v1 clear mouths with busy foliage/stone bases. Submitted c10 v3 and title menu panel v1/v2 into free slots; six image jobs total.

B80 c9 v3, c10 v1–3 and title menu v1 verified by own-session SHA256/uniqueness; opened `/tmp/wickwarden-art-wave6-review.jpg`; log `log_art_resume_06.md`. c10 v2 weak (magenta gap at lower opening, oversize), other four ok. Five free slots refilled with title menu v3, dialog cards v1–3 and B81 death overlay v1; title menu v2 still pending.

B80 title menu v2 verified own-session hash/unique; opened `/tmp/wickwarden-art-wave7-review.jpg`; blank parchment centre clear, no text; log `log_art_resume_07.md`. Freed slot refilled with B81 death overlay v2.

B80 now complete: title menu v3 and dialog cards v1–3 verified; B81 death overlays v1/v2 also verified. Own-session hashes unique; opened `/tmp/wickwarden-art-wave8-review.jpg`; log `log_art_resume_08.md`. Two ok, three weak, death overlay v1 failed (worker reports signature-like artifact; retained for cull). Six B81 jobs submitted (death v3, loading v1–3, credit divider v1/v2). Missing-prompt audit prepared B11/B82–86 partial prompts; 30 variants blocked by title text conflict/provisional memories.

B81 loading wick v2/v3 and credit divider v1 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave9-review.jpg`; log `log_art_resume_09.md`. Loading sheets weak (unrequested brass bases), divider ok. Freed slots filled credit divider v3 and arena c1 v1/v2; six image jobs total.

B81 death v3, loading v1, dividers v2/v3 and arena c1 v1/v2 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave10-review.jpg`; log `log_art_resume_10.md`. Loading/death weak; divider/floor paintings ok, arena target aspect still needs pipeline handling. Submitted c1 v3,c2 v1–3,c3 v1/v2; six image jobs.

B81 c1 v3,c2 v3,c3 v1/v2 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave12-review.jpg`; log `log_art_resume_12.md`. C3 weak upright pump (v2 also lantern); C1/C2 clear floor-only. Submitted c3 v3 plus B11 brick-ground v1–3 in freed slots; c2 v1/v2 still pending, six image jobs total.

B81 now complete: c2 v1/v2 and c3 v3 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave13-review.jpg`; log `log_art_resume_13.md`. c2 v2 weak possible standing growth; C3v3 floor-level pump. All18 B81 variants present.

B82 C4v1–3/C5v1 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave16-review.jpg`; log `log_art_resume_16.md`. Foundry3 weak glowing slag despite cold subject; C5 radial floor clear. Submitted C5v3/C6v1–3/C7v1; C5v2 pending, six jobs total.

B82 C5v2/v3,C6v1–3,C7v1 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave17-review.jpg`; log `log_art_resume_17.md`. Five weak wall-like masonry from dominating wall reference; C6v1 decorative floor ok. Future ungenerated B82/B83 arena references changed to top-down `arena_c1_v3.png` (fenced prompts unchanged). Submitted C7v2/v3,C8v1–3,C9v1; six jobs.

B82 C8v3/C9v1 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave19-review.jpg`; log `log_art_resume_19.md`. Both weak: C1 circular brick layout dominates intended regional subjects. C9v2/v3 submitted into freed slots before visual verdict, six jobs. C10 ungenerated refs removed to avoid reference-content copying; fenced prompts unchanged.

B82 C7v2/v3,C8v1/v2 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave20-review.jpg`; log `log_art_resume_20.md`. Four weak C1 circular layout copied (C8v1 adds brass motifs). Submitted C10v1–3 without refs and intro01v1 with specified style ref; C9v2/v3pending, six jobs total.

B82 complete: C9v2/v3 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave21-review.jpg`; log `log_art_resume_21.md`. Both weak C1layout drift. Freed slots filled intro01v2/v3 without sprite reference; prompt reference lines updated, fenced prompts unchanged. Six jobs total.

B83 C10v1–3/intro01v1 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave22-review.jpg`; log `log_art_resume_22.md`. C10 weak standing candles though distinct floor layouts; intro01v1 weak ten sky lanterns/added Tamsin. B84scene02/03 refs removed (fenced subjects unchanged); submitted intro02v1–3/intro03v1. Six total with intro01v2/v3pending.

B83 intro01v2/v3 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave23-review.jpg`; log `log_art_resume_23.md`. Both nine sky lanterns; v2 weak realistic/ornate markings, v3 ok. Intro01 all3 present. Freed slots filled intro03v2/v3, six total.

B84 intro02v1–3/intro03v1 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave24-review.jpg`; log `log_art_resume_24.md`. Intro02v1 weak ambiguous event count from extra falling glows; other3ok. Submitted intro04v1–3/05v1 with specified design refs, six total with03v2/v3pending.

B84 intro03v2/v3 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave25-review.jpg`; log `log_art_resume_25.md`. Both weak warm lantern-like monster lights instead of cold Hush glow. Submitted hookv2/v3 into slots, six jobs total.

B84 intro04v1–3/05v1 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave26-review.jpg`; log `log_art_resume_26.md`. Tamsinv2weak passive near lamp; other3ok. Submitted intro06v1–3/endingAv1 with refs; six total withhookv2/v3pending.

B84 hookv2/v3 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave27-review.jpg`; log `log_art_resume_27.md`. V2weak wall-mounted sconce, v3ok free hookpole. Submitted endingAv2/v3,six jobs total.

B84 intro06v1–3/endingAv1 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave28-review.jpg`; log `log_art_resume_28.md`. All4ok (Tamsin+cave/fallen lantern; warm valley ending). Submitted endingBv1–3/creditsv1,six total withendingAv2/v3pending.

B84 endingAv2/v3 complete (all18B84present); B85 endingBv1/v3 and creditsv1 verified own-session hashes/unique; opened `/tmp/wickwarden-art-wave29-review.jpg`; log `log_art_resume_29.md`. Creditsweak added Tamsin/busy village; endings4ok. Submitted title_splashv1–3/creditsv2/v3,six total withendingBv2pending.

B85 endingBv2 verified own-session hash/unique; opened `/tmp/wickwarden-art-wave30-review.jpg`; ok dawn coast/extinguished lantern. Log `log_art_resume_30.md`; all ending variants present. Freed slot filled B47rekindle_motesv1; six image jobs total.
