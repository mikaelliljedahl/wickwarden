GODOT ?= godot
GDTOOLKIT = uv tool run --from gdtoolkit==4.5.0

.PHONY: run dev import test lint format check art art-test

run:
	$(GODOT) --path .

# Dev start: all sub-items, 10 pitch pots, 5 keys, F1 toggles hitbox drawing.
dev:
	$(GODOT) --path . -- --dev-mode

# Rebuilds the class cache and .uid files. Run after adding or renaming a script with class_name.
import:
	$(GODOT) --headless --path . --editor --import --quit

# Every tests/test_*.gd runs in its own headless Godot process. Subset: make test T="player enemy"
test:
	GODOT=$(GODOT) python3 tools/run_godot_check.py $(T)

lint:
	$(GDTOOLKIT) gdlint scripts tests

# Optional: gdformat is not part of check. Run before committing if you like.
format:
	$(GDTOOLKIT) gdformat scripts tests

check: import test lint

# Cuts tools/source_art/*.png into assets/sprites/ (see docs/asset-contract.md). Subset: make art SHEETS="tamsin_walk items"
art:
	uv run --with pillow==12.3.0 --with numpy python tools/cut_sprites.py $(SHEETS)

art-test:
	uv run --with pillow==12.3.0 --with numpy python tools/test_cut_sprites.py
