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

# Temporary project override starts minimized before any window is mapped. All
# user data is isolated; no real slot/settings are read or written. CAPTURE_ARGS
# accepts --rooms=id,id, --frames=N, --out=path and --list. Timeout is a hard bound.
capture-all:
	GODOT=$(GODOT) CAPTURE_ARGS='$(CAPTURE_ARGS)' python3 -c 'import os, pathlib, shlex, subprocess, tempfile; \
	from tools.godot_env import isolated_env; \
	root=pathlib.Path.cwd(); \
	tmp=tempfile.TemporaryDirectory(prefix="wickwarden-capture-"); \
	base=pathlib.Path(tmp.name); \
	project=base/"project"; \
	project.mkdir(); \
	[(project/p.name).symlink_to(p, target_is_directory=p.is_dir()) for p in root.iterdir() if p.name != "project.godot"]; \
	config=(root/"project.godot").read_text().replace("[display]", "[display]\nwindow/size/mode=1\nwindow/size/window_width_override=64\nwindow/size/window_height_override=64"); \
	(project/"project.godot").write_text(config); \
	args=shlex.split(os.environ.get("CAPTURE_ARGS", "")); \
	args.append("--out="+str(root/"build/screens")) if not any(a.startswith("--out=") for a in args) else None; \
	result=subprocess.run([os.environ["GODOT"], "--path", str(project), *( ["--headless"] if "--list" in args else [] ), "--audio-driver", "Dummy", "--disable-render-loop", "--fixed-fps", "60", "res://tools/capture_all.tscn", "--", *args], env=isolated_env(base/"userdata"), timeout=30+20*(len(next((a.split("=",1)[1] for a in args if a.startswith("--rooms=")), "").split(",")) if any(a.startswith("--rooms=") for a in args) else 222), capture_output=True, text=True); \
	print(result.stdout, end=""); \
	print(result.stderr, end="", file=__import__("sys").stderr); \
	tmp.cleanup(); \
	raise SystemExit(result.returncode or int(any(line.startswith(("ERROR:", "SCRIPT ERROR:")) for line in result.stderr.splitlines())))'

playthrough:
	python3 tools/playthrough_route.py --check
	GODOT=$(GODOT) python3 tools/run_godot_check.py --verbose playthrough_
