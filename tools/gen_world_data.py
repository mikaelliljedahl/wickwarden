#!/usr/bin/env python3
"""Builds data/world_data.json: the run-time copy of docs/world-graph.json.

Usage:
    python3 tools/gen_world_data.py                # write data/world_data.json
    python3 tools/gen_world_data.py --out FILE     # write FILE instead
    python3 tools/gen_world_data.py --check        # exit 1 when data/world_data.json is stale
    python3 tools/gen_world_data.py --graph FILE   # read another graph (tests)

Exit codes: 0 = ok, 1 = --check found a stale file, 2 = the graph is unreadable or invalid.

The graph (docs/world-graph.json, format 1, world-plan 5.6) is the source. docs/ is hidden from the
game export, so the game reads only the trimmed file written here. Never edit the output by hand.
Stdlib only.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GRAPH_PATH = ROOT / "docs" / "world-graph.json"
OUT_PATH = ROOT / "data" / "world_data.json"

FORMAT = 1
SCENE_DIR = "res://scenes/world/rooms/"
# Pockets have no grid of their own in the world; they get a virtual cell in this row, which no
# room uses (overworld rows 0..8, caves rows 12 and later).
POCKET_ROW = 30
CAVE_COUNT = 10
# Pockets opened in place: they have no scene file (the dev-world sealed spots).
IN_PLACE = ("ow_2_0#cache", "ow_2_1#closet", "cave_1#alcove")
# Lantern name per cave (world-plan 4). C9 is Corrow's workshop and has no lantern.
LANTERNS = {
    1: "Warmth",
    2: "Growth",
    3: "Rain",
    4: "Sleep",
    5: "Memory",
    6: "Song",
    7: "Courage",
    8: "Trade",
    9: None,
    10: "Seasons",
}
# Node fields the game does not read at run time.
DROPPED_PICKUP_FIELDS = ("contents",)
STEP_SIDES = {(0, -1): "n", (1, 0): "e", (0, 1): "s", (-1, 0): "w"}
CAVE_WORLD = re.compile(r"^cave_(\d+)$")


class GraphError(Exception):
    """The graph breaks a rule the generator relies on."""


def scope_of(world: str) -> str:
    """'overworld' -> 'ow', 'cave_4' -> 'c4' (the scope names of the key edges)."""
    if world == "overworld":
        return "ow"
    match = CAVE_WORLD.match(world)
    if match is None:
        raise GraphError(f"unknown world {world!r}")
    return f"c{int(match.group(1))}"


def index_by_id(records: list[dict], what: str) -> dict[str, dict]:
    index: dict[str, dict] = {}
    for record in records:
        record_id = record["id"]
        if record_id in index:
            raise GraphError(f"duplicate {what} id {record_id!r}")
        index[record_id] = record
    return index


def grid_of(node: dict) -> tuple[int, int]:
    grid = node["grid"]
    if len(grid) != 2 or not all(isinstance(value, int) for value in grid):
        raise GraphError(f"room {node['id']!r} has a bad grid {grid!r}")
    return grid[0], grid[1]


def check_exits(rooms: dict[str, dict], edges: list[dict]) -> None:
    """Every room's exits must equal the sides of its step links (world-plan 1.1 and 5.6).

    A one-way link (dir "a>b") is a ledge drop: the upper room a lists the side, the lower room b
    does not.
    """
    sides: dict[str, set[str]] = {room_id: set() for room_id in rooms}
    for edge in edges:
        if edge["link"] != "step":
            continue
        a, b = edge["a"], edge["b"]
        if a not in rooms or b not in rooms:
            raise GraphError(f"step edge {edge['id']} must join two rooms")
        ax, ay = grid_of(rooms[a])
        bx, by = grid_of(rooms[b])
        side_ab = STEP_SIDES.get((bx - ax, by - ay))
        if side_ab is None:
            raise GraphError(f"step edge {edge['id']} joins cells that are not adjacent")
        sides[a].add(side_ab)
        if edge["dir"] == "both":
            sides[b].add(STEP_SIDES[(ax - bx, ay - by)])
    for room_id, room in rooms.items():
        if set(room["exits"]) != sides[room_id]:
            raise GraphError(
                f"exits of {room_id} are {sorted(room['exits'])}, step links give {sorted(sides[room_id])}"
            )


def find_caves(rooms: dict[str, dict], edges: list[dict]) -> list[dict]:
    """Each cave is entered by exactly one door from an overworld room (its mouth)."""
    caves = []
    for number in range(1, CAVE_COUNT + 1):
        scope = f"c{number}"
        found = []
        for edge in edges:
            if edge["link"] != "door":
                continue
            ends = [edge["a"], edge["b"]]
            overworld = [end for end in ends if end in rooms and rooms[end]["world"] == "overworld"]
            inside = [end for end in ends if end in rooms and scope_of(rooms[end]["world"]) == scope]
            if len(overworld) == 1 and len(inside) == 1:
                found.append((overworld[0], inside[0]))
        if len(found) != 1:
            raise GraphError(f"cave {scope} has {len(found)} doors from the overworld, expected 1")
        mouth, entrance = found[0]
        caves.append(
            {"scope": scope, "number": number, "mouth": mouth, "entrance": entrance, "lantern": LANTERNS[number]}
        )
    return caves


def build(graph: dict, graph_bytes: bytes) -> dict:
    """Returns the trimmed world data (a dict in the order of data/world_data.json)."""
    if graph.get("format") != FORMAT:
        raise GraphError(f"graph format must be {FORMAT}, found {graph.get('format')!r}")
    nodes = graph["nodes"]
    edges = graph["edges"]
    pickups = graph["pickups"]
    items = graph["items"]

    node_index = index_by_id(nodes, "node")
    index_by_id(edges, "edge")
    index_by_id(pickups, "pickup")
    rooms = {node["id"]: node for node in nodes if node["kind"] == "room"}
    pockets = [node for node in nodes if node["kind"] == "pocket"]
    if len(rooms) + len(pockets) != len(nodes):
        raise GraphError("every node must be a room or a pocket")

    seen_grids: dict[tuple[int, int], str] = {}
    for room_id, room in rooms.items():
        cell = grid_of(room)
        if cell in seen_grids:
            raise GraphError(f"{room_id} and {seen_grids[cell]} share grid cell {cell}")
        seen_grids[cell] = room_id
        if not isinstance(room.get("dark", False), bool):
            raise GraphError(f"{room_id}: dark must be true or false")
    for pocket in pockets:
        host = pocket["id"].split("#")[0]
        if host not in rooms or rooms[host]["world"] != pocket["world"]:
            raise GraphError(f"pocket {pocket['id']} has no room of its world to belong to")
    pocket_ids = {pocket["id"] for pocket in pockets}
    for pocket_id in IN_PLACE:
        if pocket_id not in pocket_ids:
            raise GraphError(f"in-place pocket {pocket_id} is not in the graph")

    check_exits(rooms, edges)
    for edge in edges:
        if edge["a"] not in node_index or edge["b"] not in node_index:
            raise GraphError(f"edge {edge['id']} refers to an unknown node")
        if edge["link"] not in ("step", "door") or edge["dir"] not in ("both", "a>b"):
            raise GraphError(f"edge {edge['id']} has an unknown link or dir")
    for pickup in pickups:
        if pickup["node"] not in node_index:
            raise GraphError(f"pickup {pickup['id']} refers to an unknown node")
    for capability, item in items.items():
        if item["node"] not in node_index:
            raise GraphError(f"item {capability} refers to an unknown node")

    room_records = [
        {
            "id": room["id"],
            "scene": f"{SCENE_DIR}{room['id']}.tscn",
            "grid": list(grid_of(room)),
            "exits": list(room["exits"]),
            "dark": room.get("dark", False),
            "scope": scope_of(room["world"]),
            "region": room["region"],
            "name": room["name"],
            "enemies": dict(room["enemies"]),
        }
        for room in rooms.values()
    ]
    pocket_records = []
    for index, pocket in enumerate(pockets):
        in_place = pocket["id"] in IN_PLACE
        pocket_records.append(
            {
                "id": pocket["id"],
                "host": pocket["id"].split("#")[0],
                "scene": None if in_place else f"{SCENE_DIR}{pocket['id'].replace('#', '__')}.tscn",
                "in_place": in_place,
                "grid": [index, POCKET_ROW],
                "scope": scope_of(pocket["world"]),
                "region": pocket["region"],
                "name": pocket["name"],
            }
        )
    edge_records = [
        {
            "id": edge["id"],
            "a": edge["a"],
            "b": edge["b"],
            "link": edge["link"],
            "gate": edge["gate"],
            "needs": list(edge["needs"]),
            "dir": edge["dir"],
            "key": edge.get("key"),
            "prop": edge.get("prop"),
        }
        for edge in edges
    ]
    pickup_records = [
        {key: value for key, value in pickup.items() if key not in DROPPED_PICKUP_FIELDS}
        for pickup in pickups
    ]
    shops = sorted(
        ({"id": pickup["shop"], "node": pickup["node"]} for pickup in pickups if pickup["kind"] == "shop"),
        key=lambda shop: shop["id"],
    )

    return {
        "format": FORMAT,
        "source_sha": hashlib.sha256(graph_bytes).hexdigest(),
        "rooms": room_records,
        "pockets": pocket_records,
        "edges": edge_records,
        "pickups": pickup_records,
        "items": {capability: dict(item) for capability, item in items.items()},
        "shops": shops,
        "caves": find_caves(rooms, edges),
    }


def render(data: dict) -> str:
    """JSON with one object per line for the long lists, so that diffs stay readable."""
    lines = ["{"]
    keys = list(data)
    for position, key in enumerate(keys):
        value = data[key]
        comma = "," if position < len(keys) - 1 else ""
        if isinstance(value, list):
            lines.append(f"{json.dumps(key)}: [")
            for item_position, item in enumerate(value):
                item_comma = "," if item_position < len(value) - 1 else ""
                lines.append(f"{json.dumps(item, ensure_ascii=False)}{item_comma}")
            lines.append(f"]{comma}")
        elif isinstance(value, dict):
            lines.append(f"{json.dumps(key)}: {{")
            entries = list(value.items())
            for item_position, (name, item) in enumerate(entries):
                item_comma = "," if item_position < len(entries) - 1 else ""
                lines.append(f"{json.dumps(name)}: {json.dumps(item, ensure_ascii=False)}{item_comma}")
            lines.append(f"}}{comma}")
        else:
            lines.append(f"{json.dumps(key)}: {json.dumps(value)}{comma}")
    lines.append("}")
    return "\n".join(lines) + "\n"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--graph", default=str(GRAPH_PATH), help="graph file (default docs/world-graph.json)")
    parser.add_argument("--out", default=str(OUT_PATH), help="output file (default data/world_data.json)")
    parser.add_argument("--check", action="store_true", help="fail when the output is not what the graph gives")
    args = parser.parse_args(argv)

    try:
        graph_bytes = Path(args.graph).read_bytes()
        text = render(build(json.loads(graph_bytes), graph_bytes))
    except (OSError, ValueError, KeyError, TypeError, GraphError) as error:
        print(f"gen_world_data: {error}", file=sys.stderr)
        return 2

    out = Path(args.out)
    if args.check:
        current = out.read_text(encoding="utf-8") if out.exists() else ""
        if current != text:
            print(f"gen_world_data: {out} is stale; run make world-data", file=sys.stderr)
            return 1
        print(f"{out} is up to date")
        return 0
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(text, encoding="utf-8", newline="\n")
    print(f"wrote {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
