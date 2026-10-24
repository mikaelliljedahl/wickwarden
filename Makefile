GODOT ?= godot
GDTOOLKIT = uv tool run --from gdtoolkit==4.5.0

.PHONY: run dev import test lint format check art art-test audio world-data world-check world-gen-test rooms rooms-check capture-all playthrough

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

check: import test lint world-check world-gen-test

# Cuts tools/source_art/*.png into assets/sprites/ (see docs/asset-contract.md). Subset: make art SHEETS="tamsin_walk items"
art:
	uv run --with pillow==12.3.0 --with numpy python tools/cut_sprites.py $(SHEETS)

art-test:
	uv run --with pillow==12.3.0 --with numpy python tools/test_cut_sprites.py

# Synthesises every sound into assets/audio/ (stdlib Python + ffmpeg for the .ogg music). Subset: make audio ITEMS="swing cave"
audio:
	python3 tools/make_audio.py $(ITEMS)

# Regenerates data/world_data.json from docs/world-graph.json (never edit the JSON by hand).
world-data:
	python3 tools/gen_world_data.py

# Fails when data/world_data.json is not what the current graph gives (regenerates in memory).
world-check:
	python3 tools/gen_world_data.py --check

# Unit tests of the world data generator and the room kit compiler (stdlib unittest).
world-gen-test:
	python3 -m unittest tools/test_gen_world_data.py tools/test_build_rooms.py

# Compiles tools/rooms/*.room into scenes/world/rooms/ (docs/room-kit.md). Subset: make rooms ROOMS="ow_0_1"
rooms:
	python3 tools/build_rooms.py $(ROOMS)

# Validates every .room and fails when a committed scene differs from its compiled text (writes nothing).
rooms-check:
	python3 tools/build_rooms.py --check

# The next two targets need tools that later work packages add. Until then they fail with a message.

capture-all:
	@echo "make capture-all: not built yet (tools/capture_all.gd comes with WP Q4)"
	@exit 1

playthrough:
	@echo "make playthrough: not built yet (tests/test_playthrough_*.gd and tools/playthrough_route.py come with WP Q3)"
	@exit 1
