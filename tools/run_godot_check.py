#!/usr/bin/env python3
"""Run Wickwarden's headless test files in parallel.

Usage:
    python3 tools/run_godot_check.py              # every tests/test_*.gd
    python3 tools/run_godot_check.py player pickup  # files whose name contains a filter
    python3 tools/run_godot_check.py --list

Tests are DISCOVERED: any `tests/test_<name>.gd` that extends TestCase is a suite. Nobody edits
this file to add a test. Each file runs in its own Godot process (res://tests/runner.tscn) with an
isolated user:// directory. A suite fails on a non-zero exit, a timeout, a Godot SCRIPT ERROR or
engine ERROR line, or leaked objects at shutdown.

If the class cache (.godot/global_script_class_cache.cfg) is missing, one `--import` runs first.
Add `--import` to force it. Never run two imports at once in the same checkout.

A suite may declare `## timeout=<seconds>` as its first line to run longer than the default
TIMEOUT (the world playthrough shards need it).
"""

from __future__ import annotations

import argparse
import errno
import os
import re
import secrets
import shlex
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from godot_env import isolated_env

ROOT = Path(__file__).resolve().parents[1]
TESTS = ROOT / "tests"
FAILURE = re.compile(
    r"SCRIPT ERROR|^ERROR:|ObjectDB instances leaked|resources? still in use|Parse Error",
    re.I | re.M,
)
TIMEOUT = 90.0
TIMEOUT_HEADER = re.compile(r"\A## timeout=(\d+)\s*$", re.M)
SPACE_ERROR = re.compile(r"disk quota exceeded|no space left on device", re.I)


def root_candidates(tmpdir: str) -> list[Path]:
    """Only locations accepted by TestCase; never inherit an arbitrary TMPDIR."""
    allowed = [Path("/var/tmp"), Path("/tmp")]
    preferred = Path(tmpdir) if tmpdir in ("/tmp", "/var/tmp") else None
    if preferred is not None:
        allowed.remove(preferred)
        allowed.insert(0, preferred)
    return allowed


def probe_space(root: Path) -> None:
    """Check actual writes, not statvfs: per-user quotas can override free space."""
    with tempfile.TemporaryFile(dir=root) as probe:
        probe.write(b"\0" * 4096)
        probe.flush()
        os.fsync(probe.fileno())


def is_space_error(error: OSError) -> bool:
    return error.errno in (errno.ENOSPC, errno.EDQUOT)


def discover(filters: list[str]) -> list[Path]:
    files = sorted(TESTS.glob("test_*.gd"))
    if filters:
        files = [f for f in files if any(x.lower() in f.stem.lower() for x in filters)]
    return files


def class_cache_stale(cache: Path) -> bool:
    """True if a script that declares a class_name is newer than the class cache."""
    stamp = cache.stat().st_mtime
    for folder in ("scripts", "tests"):
        for script in (ROOT / folder).rglob("*.gd"):
            if script.stat().st_mtime > stamp and "\nclass_name " in "\n" + script.read_text():
                return True
    return False


def ensure_import(godot: list[str], force: bool, scratch: Path) -> bool:
    cache = ROOT / ".godot" / "global_script_class_cache.cfg"
    if cache.exists() and not force and not class_cache_stale(cache):
        return True
    print("importing project ...", flush=True)
    env = isolated_env(scratch / "import")
    env["TMPDIR"] = env["HOME"]
    done = subprocess.run(
        [*godot, "--headless", "--path", str(ROOT), "--editor", "--import", "--quit"],
        cwd=ROOT,
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )
    if SPACE_ERROR.search(done.stdout + done.stderr):
        print(done.stdout + done.stderr)
        raise OSError(errno.ENOSPC, "import reported insufficient space")
    if done.returncode != 0:
        print(done.stdout + done.stderr)
        probe_space(scratch)
    return done.returncode == 0


def timeout_of(file: Path) -> float:
    """The suite's own timeout from a `## timeout=<seconds>` first line, else TIMEOUT."""
    first_line = file.read_text(encoding="utf-8").split("\n", 1)[0]
    match = TIMEOUT_HEADER.match(first_line)
    return float(match.group(1)) if match else TIMEOUT


def run_one(file: Path, godot: list[str], scratch: Path) -> tuple[str, bool, float, str]:
    home = scratch / file.stem
    home.mkdir(mode=0o700)
    limit = timeout_of(file)
    env = isolated_env(home, dict(os.environ, PYTHONUNBUFFERED="1"))
    env["TMPDIR"] = str(home)
    env["WICK_TEST_ROOT"] = str(scratch)
    env["WICK_TEST_PROFILE"] = str(home)
    env["WICK_TEST_TOKEN"] = (scratch / ".wick-test-root").read_text(encoding="ascii")
    command = [
        *godot,
        "--headless",
        "--path",
        str(ROOT),
        "--fixed-fps",
        "60",
        "res://tests/runner.tscn",
        "--",
        f"--test=res://tests/{file.name}",
    ]
    started = time.monotonic()
    try:
        done = subprocess.run(
            command, cwd=ROOT, env=env, capture_output=True, text=True, timeout=limit, check=False
        )
        output = done.stdout + done.stderr
        ok = done.returncode == 0 and not FAILURE.search(output) and not SPACE_ERROR.search(output)
        if done.returncode != 0:
            output += f"\nexit={done.returncode}"
    except subprocess.TimeoutExpired as error:
        out = (error.stdout or b"") + (error.stderr or b"")
        output = out.decode(errors="replace") + f"\nTIMEOUT after {limit:.0f}s"
        ok = False
    return file.stem, ok, time.monotonic() - started, f"$ {shlex.join(command)}\n{output}"


def main() -> int:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("filters", nargs="*", help="only test files whose name contains a filter")
    parser.add_argument("--godot", default=os.environ.get("GODOT", "godot"))
    parser.add_argument("--jobs", "-j", type=int, default=max(2, (os.cpu_count() or 4) // 2))
    parser.add_argument("--list", action="store_true", help="list test files and exit")
    parser.add_argument("--import", dest="force_import", action="store_true", help="re-import first")
    parser.add_argument("--verbose", "-v", action="store_true", help="show passing output too")
    args = parser.parse_args()

    files = discover(args.filters)
    if args.list:
        for f in files:
            print(f.name)
        return 0
    if not files:
        print(f"no test file matches {args.filters}")
        return 1
    godot = shlex.split(args.godot)
    started = time.monotonic()
    failures: list[str] = []
    attempted = False
    for parent in root_candidates(os.environ.get("TMPDIR", "")):
        started_execution = False
        try:
            if parent.resolve(strict=True) != parent:
                raise OSError(errno.EINVAL, "temporary parent is not canonical", str(parent))
            with tempfile.TemporaryDirectory(prefix="wickwarden-check-", dir=parent) as scratch:
                scratch_path = Path(scratch)
                probe_space(scratch_path)
                (scratch_path / ".wick-test-root").write_text(secrets.token_hex(32), encoding="ascii")
                print(f"isolated test root: {scratch_path}", flush=True)
                started_execution = True
                if not ensure_import(godot, args.force_import, scratch_path):
                    print("FAIL  import")
                    return 1
                failures = []
                with ThreadPoolExecutor(max_workers=args.jobs) as pool:
                    jobs = [(f, pool.submit(run_one, f, godot, scratch_path)) for f in files]
                    for file, job in jobs:
                        try:
                            name, ok, seconds, output = job.result()
                        except Exception as error:
                            print(f"FAIL  {file.stem}: {type(error).__name__}: {error}", flush=True)
                            failures.append(file.stem)
                            continue
                        print(f"{'PASS' if ok else 'FAIL'}  {name:28} {seconds:5.1f}s", flush=True)
                        if not ok or args.verbose:
                            print(output.rstrip() + "\n", flush=True)
                        if not ok:
                            failures.append(name)
                attempted = True
                break
        except OSError as error:
            if not started_execution and (
                is_space_error(error) or error.errno in (errno.ENOENT, errno.EACCES, errno.EINVAL)
            ):
                print(
                    f"Test root {parent} unavailable before execution: {error}; trying next root.",
                    flush=True,
                )
                continue
            print(f"FAIL  execution stopped without retry: {error}", flush=True)
            return 1
    if not attempted:
        print("FAIL  no usable isolated test root", flush=True)
        return 1
    total = time.monotonic() - started
    if failures:
        print(f"\n{len(failures)}/{len(files)} failed in {total:.0f}s: {', '.join(failures)}")
        return 1
    print(f"\nall {len(files)} test files passed in {total:.0f}s")
    return 0


if __name__ == "__main__":
    sys.exit(main())
