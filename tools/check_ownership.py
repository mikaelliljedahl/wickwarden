#!/usr/bin/env python3
"""Checks which files a work package of docs/world-work-packages.md may touch.

Usage:
    python3 tools/check_ownership.py <WP> [--base REF]    # stray check, file list on stdin
    python3 tools/check_ownership.py --global [--graph PATH]
    python3 tools/check_ownership.py --regen [--graph PATH]

Stray check: the changed files come one per line on stdin, so an agent never needs git. The lead
can pass --base REF instead; the script then asks git for the files changed against REF and adds
the untracked files. Exit 0 = every file is inside the WP's Owns (or amends) globs, 1 = stray files,
2 = usage error, unknown WP, or a per-ticket WP that has no static Owns.

Global check: every WP id of the document has an entry (and no unknown entry), every room batch
matches its table row, every room and pocket of docs/world-graph.json sits in exactly one batch,
every path is relative, and no path is owned by two WPs of waves 1 to 5.
`--regen` rewrites the room-batch entries from the batch tables (the other entries are hand-kept).

Room ids are read from docs/world-graph.json, not from data/world_data.json: F1 generates that file
and it does not exist yet. The ids are the same, so switch GRAPH_PATH once F1 has landed.

Glob rules: fnmatch on forward-slash paths, `*` also matches `/`. A path `X.uid` is allowed when `X`
is (Godot writes a .uid next to each script). The duplicate check compares literal paths with the
globs of other WPs and identical patterns; it does not prove that two different globs never overlap.
Stdlib only.
"""
import argparse
import fnmatch
import json
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DOC_PATH = ROOT / "docs" / "world-work-packages.md"
MANIFEST_PATH = ROOT / "tools" / "wp_ownership.json"
GRAPH_PATH = ROOT / "docs" / "world-graph.json"

BATCH_KIND = "room_batch"
SHARED_WAVES = range(1, 6)
SECTION_WAVE = {"5": 0, "6": 1, "7": 2, "8": 3, "9": 4, "10": 5}

RE_SECTION = re.compile(r"^## (\d+)\. ")
RE_HEADING_ID = re.compile(r"^###? (?:[\d.]+ )?([A-Z]{1,2}\d{1,2})\. ")
RE_CELL_ID = re.compile(r"^([A-Z]{1,2}\d{1,2})(?=[ ,]|$)")
RE_BATCH_ROW = re.compile(r"^\| (R\d\.[a-f]|C\d\d\.[a-f]) \| (\d+) rooms? \| (\d+) \| (.*) \|$")
RE_BATCH_ITEM = re.compile(r"^([a-z0-9_]+)(?: \(in-place #([a-z]+)\)| \+#([a-z]+))?$")


class DocError(Exception):
    pass


def parse_doc(text):
    """Return (waves, batches). waves maps each WP id of sections 5 to 10 to its wave.
    batches maps each room-batch id to its entry (rooms, pockets, in_place, owns)."""
    waves, batches = {}, {}
    wave = None
    for line in text.splitlines():
        m = RE_SECTION.match(line)
        if m:
            wave = SECTION_WAVE.get(m.group(1))
            continue
        if wave is None:
            continue
        m = RE_HEADING_ID.match(line)
        if m:
            _add_wp(waves, m.group(1), wave)
        if not line.startswith("|"):
            continue
        m = RE_BATCH_ROW.match(line)
        if m:
            batch_id, n_rooms, n_pockets, cell = m.group(1), int(m.group(2)), int(m.group(3)), m.group(4)
            batches[batch_id] = _batch_from_row(batch_id, n_rooms, n_pockets, cell)
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        m = RE_CELL_ID.match(cells[0]) if cells else None
        if m:
            _add_wp(waves, m.group(1), wave)
    return waves, batches


def _add_wp(waves, wp_id, wave):
    if waves.get(wp_id, wave) != wave:
        raise DocError("%s appears in two waves" % wp_id)
    waves[wp_id] = wave


def _batch_from_row(batch_id, n_rooms, n_pockets, cell):
    rooms, pockets, in_place = [], [], []
    for item in re.findall(r"`([^`]+)`", cell):
        m = RE_BATCH_ITEM.match(item.strip())
        if not m:
            raise DocError("%s: cannot read room item %r" % (batch_id, item))
        room, inplace_tag, pocket_tag = m.group(1), m.group(2), m.group(3)
        rooms.append(room)
        if inplace_tag:
            in_place.append("%s#%s" % (room, inplace_tag))
        if pocket_tag:
            pockets.append("%s#%s" % (room, pocket_tag))
    if len(rooms) != n_rooms:
        raise DocError("%s: table says %d rooms, lists %d" % (batch_id, n_rooms, len(rooms)))
    if len(pockets) != n_pockets:
        raise DocError("%s: table says %d pockets, lists %d" % (batch_id, n_pockets, len(pockets)))
    return batch_entry(batch_id, rooms, pockets, in_place)


def batch_entry(batch_id, rooms, pockets, in_place):
    owns = []
    for room in rooms:
        owns += ["tools/rooms/%s.room" % room, "scenes/world/rooms/%s.tscn" % room]
    for pocket in pockets:
        base = pocket.replace("#", "__")
        owns += ["tools/rooms/%s.room" % base, "scenes/world/rooms/%s.tscn" % base]
    wave = 2 if batch_id.startswith("R") else 3
    return {"wave": wave, "kind": BATCH_KIND, "rooms": rooms, "pockets": pockets,
            "in_place": in_place, "owns": owns}


def has_glob(pattern):
    return any(c in pattern for c in "*?[")


def overlaps(a, b):
    if a == b:
        return True
    if not has_glob(a) and fnmatch.fnmatchcase(a, b):
        return True
    return not has_glob(b) and fnmatch.fnmatchcase(b, a)


def normalise(path):
    p = path.strip().replace("\\", "/")
    while p.startswith("./"):
        p = p[2:]
    return p


def is_allowed(path, patterns):
    candidates = [path]
    if path.endswith(".uid"):
        candidates.append(path[:-4])
    return any(fnmatch.fnmatchcase(c, pat) for c in candidates for pat in patterns)


def stray_files(manifest, wp, files):
    entry = manifest["wps"][wp]
    patterns = entry.get("owns", []) + entry.get("amends", [])
    return [f for f in (normalise(x) for x in files) if f and not is_allowed(f, patterns)]


def shared_owners(wps):
    """Errors for every path that two WPs of waves 1 to 5 both own (amends do not count)."""
    items = [(pat, wp) for wp, e in wps.items() if e.get("wave") in SHARED_WAVES for pat in e.get("owns", [])]
    errors = []
    for i, (pa, wa) in enumerate(items):
        for pb, wb in items[i + 1:]:
            if wa != wb and overlaps(pa, pb):
                errors.append("%s is owned by both %s and %s" % (pa, wa, wb))
    return errors


def path_errors(wps):
    errors = []
    for wp, e in wps.items():
        for pat in e.get("owns", []) + e.get("amends", []):
            if not pat or pat.startswith("/") or ".." in pat.split("/") or "\\" in pat:
                errors.append("%s: path must be relative and use forward slashes: %r" % (wp, pat))
    return errors


def check_graph(graph, batches):
    """Every room and pocket of the graph is in exactly one batch, and nothing else is."""
    errors = []
    rooms = {n["id"] for n in graph["nodes"] if n["kind"] == "room"}
    pockets = {n["id"] for n in graph["nodes"] if n["kind"] == "pocket"}
    seen = defaultdict(list)
    for bid, b in batches.items():
        for room in b["rooms"]:
            seen[room].append(bid)
            if room not in rooms:
                errors.append("%s: %s is not a room in the graph" % (bid, room))
        for pocket in b["pockets"] + b["in_place"]:
            seen[pocket].append(bid)
            if pocket not in pockets:
                errors.append("%s: %s is not a pocket in the graph" % (bid, pocket))
    for ident, owners in sorted(seen.items()):
        if len(owners) > 1:
            errors.append("%s is in more than one batch: %s" % (ident, ", ".join(owners)))
    for ident in sorted((rooms | pockets) - set(seen)):
        errors.append("%s is in the graph but in no room batch" % ident)
    return errors, len(rooms), len(pockets)


def check_manifest(manifest, doc_text, graph):
    """All global checks. Returns (errors, summary)."""
    errors = []
    try:
        waves, doc_batches = parse_doc(doc_text)
    except DocError as exc:
        return ["document: %s" % exc], ""
    wps = manifest["wps"]
    manifest_batches = {k: v for k, v in wps.items() if v.get("kind") == BATCH_KIND}
    manifest_wps = {k: v for k, v in wps.items() if k not in manifest_batches}

    for wp, wave in sorted(waves.items()):
        if wp not in manifest_wps:
            errors.append("%s is in the document but has no manifest entry" % wp)
        elif manifest_wps[wp].get("wave") != wave:
            errors.append("%s is wave %s in the document, wave %s in the manifest"
                          % (wp, wave, manifest_wps[wp].get("wave")))
    for wp in sorted(set(manifest_wps) - set(waves)):
        errors.append("%s is in the manifest but not in the document" % wp)

    for bid, entry in sorted(doc_batches.items()):
        if bid not in manifest_batches:
            errors.append("%s is a room batch in the document but has no manifest entry (run --regen)" % bid)
        elif manifest_batches[bid] != entry:
            errors.append("%s does not match its batch table (run --regen)" % bid)
    for bid in sorted(set(manifest_batches) - set(doc_batches)):
        errors.append("%s is in the manifest but is no room batch of the document" % bid)

    errors += path_errors(wps)
    graph_errors, n_rooms, n_pockets = check_graph(graph, doc_batches)
    errors += graph_errors
    rooms = {n["id"] for n in graph["nodes"] if n["kind"] == "room"}
    for wp, e in wps.items():
        for pat in e.get("amends", []):
            m = re.match(r"^scenes/world/rooms/([a-z0-9_]+)\.tscn$", pat)
            if m and m.group(1) not in rooms:
                errors.append("%s amends %s, which is not a room in the graph" % (wp, pat))
    errors += shared_owners(wps)
    summary = ("%d work packages, %d room batches; graph: %d rooms and %d pockets, each in one batch"
               % (len(waves), len(doc_batches), n_rooms, n_pockets))
    return errors, summary


def regen(manifest, doc_text):
    """Return a new manifest with the room-batch entries rebuilt from the batch tables."""
    _, doc_batches = parse_doc(doc_text)
    out = {}
    for key, value in manifest["wps"].items():
        if value.get("kind") == BATCH_KIND:
            continue
        out[key] = value
        for bid, entry in doc_batches.items():
            if bid.split(".")[0] == key:
                out[bid] = entry
    for bid, entry in doc_batches.items():
        out.setdefault(bid, entry)
    result = dict(manifest)
    result["wps"] = out
    return result


def changed_files(base):
    tracked = subprocess.run(["git", "diff", "--name-only", base], cwd=str(ROOT),
                             capture_output=True, text=True, check=True).stdout.splitlines()
    untracked = subprocess.run(["git", "ls-files", "--others", "--exclude-standard"], cwd=str(ROOT),
                               capture_output=True, text=True, check=True).stdout.splitlines()
    return tracked + untracked


def load_json(path):
    with open(str(path), encoding="utf-8") as fh:
        return json.load(fh)


def save_manifest(path, manifest):
    with open(str(path), "w", encoding="utf-8") as fh:
        fh.write(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")


def main(argv):
    parser = argparse.ArgumentParser(description="Check work package file ownership (docs/world-work-packages.md).")
    parser.add_argument("wp", nargs="?", help="WP id, for example P01 or R1.a")
    parser.add_argument("--base", metavar="REF", help="take the changed files from git diff against REF")
    parser.add_argument("--global", dest="global_check", action="store_true", help="check the whole manifest")
    parser.add_argument("--regen", action="store_true", help="rebuild the room-batch entries from the tables")
    parser.add_argument("--graph", metavar="PATH", default=str(GRAPH_PATH), help="world graph (default docs/world-graph.json)")
    args = parser.parse_args(argv[1:])
    modes = [bool(args.wp), args.global_check, args.regen]
    if sum(modes) != 1:
        parser.error("give exactly one of a WP id, --global or --regen")

    manifest = load_json(MANIFEST_PATH)
    if args.global_check or args.regen:
        doc_text = DOC_PATH.read_text(encoding="utf-8")
    if args.regen:
        try:
            new = regen(manifest, doc_text)
            _, doc_batches = parse_doc(doc_text)
        except DocError as exc:
            print("ERROR: %s" % exc)
            return 1
        save_manifest(MANIFEST_PATH, new)
        print("OK: wrote %d room batches to %s" % (len(doc_batches), MANIFEST_PATH.relative_to(ROOT)))
        return 0
    if args.global_check:
        errors, summary = check_manifest(manifest, doc_text, load_json(args.graph))
        for e in errors:
            print("ERROR: %s" % e)
        if errors:
            print("FAILED (%d)" % len(errors))
            return 1
        print("OK: %s; no path owned twice in waves 1 to 5" % summary)
        return 0

    wp = args.wp
    if wp not in manifest["wps"]:
        print("unknown WP id: %s" % wp, file=sys.stderr)
        return 2
    if manifest["wps"][wp].get("per_ticket"):
        print("%s is a per-ticket WP: it has no static Owns list, write the ticket entry first" % wp,
              file=sys.stderr)
        return 2
    if args.base:
        try:
            files = changed_files(args.base)
        except subprocess.CalledProcessError as exc:
            print("git failed: %s" % exc, file=sys.stderr)
            return 2
    else:
        files = sys.stdin.read().splitlines()
    files = [f for f in (normalise(x) for x in files) if f]
    strays = stray_files(manifest, wp, files)
    if strays:
        for f in strays:
            print("STRAY %s" % f)
        print("%s: %d file(s) outside Owns" % (wp, len(strays)))
        return 1
    print("OK %s: %d file(s) inside Owns" % (wp, len(files)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
