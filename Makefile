GODOT ?= godot
GDTOOLKIT = uv tool run --from gdtoolkit==4.5.0

.PHONY: run import test lint format check

run:
	$(GODOT) --path .

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
