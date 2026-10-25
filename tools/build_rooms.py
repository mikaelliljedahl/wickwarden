#!/usr/bin/env python3
"""Compiles the room sources tools/rooms/*.room into scenes/world/rooms/*.tscn (code-contract 16.8).

Usage:
    python3 tools/build_rooms.py [ROOM ...] [--check]
        [--rooms-dir DIR] [--out-dir DIR] [--world FILE] [--prices FILE]

ROOM is a room id (ow_0_1), a pocket id (ow_7_2#bag) or a file stem (ow_7_2__bag). Without ROOM every
*.room file of the rooms directory is built. Each file is validated against data/world_data.json (the
run-time copy of docs/world-graph.json), docs/world-graph.json (cache contents) and data/shop_prices.json.
Every error is printed as file:line: message; a room with an error is not written. --check validates and compares the generated text with the committed scene
without writing (`make rooms-check`). Exit codes: 0 = ok, 1 = errors or a stale scene, 2 = unreadable
world data. The format is documented in docs/room-kit.md. Stdlib only.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ROOMS_DIR = ROOT / "tools" / "rooms"
OUT_DIR = ROOT / "scenes" / "world" / "rooms"
WORLD_FILE = ROOT / "data" / "world_data.json"
SHOP_PRICES_FILE = ROOT / "data" / "shop_prices.json"
# The cache contents are free text in the graph; data/world_data.json (gen_world_data.py) does not carry them yet.
GRAPH_FILE = ROOT / "docs" / "world-graph.json"

TILE = 96
COLS, ROWS = 20, 10
EXIT_DEPTH = 3
SIDES = ("n", "e", "s", "w")
# The two ring tiles of each wall gap (code-contract section 15: two tiles wide, centred on the side).
GAP_TILES = {
    "n": [(9, 0), (10, 0)],
    "s": [(9, ROWS - 1), (10, ROWS - 1)],
    "w": [(0, 4), (0, 5)],
    "e": [(COLS - 1, 4), (COLS - 1, 5)],
}
ROOM_CENTRE_PX = (COLS * TILE / 2, ROWS * TILE / 2)  # Room._spawn_position without a Default marker
SPAWN_NAMES = ("Default", "FromCave", "FromOverworld", "FromPocket", "Inside")
# Grid characters. The ring is drawn by Room from the exits, so ring '#' are not emitted as blocks.
TERRAIN_KIND = {"#": "wall", "w": "water", "r": "rock", "t": "tree", "e": "reed"}
MERGED_CHARS = ("#", "w")  # merged into maximal rectangles, row-major; the others are one block per tile
BUSH_CHAR = "b"
FLOOR_CHAR = "."
GRID_CHARS = set(TERRAIN_KIND) | {BUSH_CHAR, FLOOR_CHAR}
SOLID_SCRIPT = "res://scripts/world/solid_block.gd"
BUSH_SCRIPT = "res://scripts/world/bush.gd"
ROOM_SCRIPT = "res://scripts/world/room.gd"
DOOR_SCRIPT = "res://scripts/world/room_door.gd"
LOCKED_SCRIPT = "res://scripts/world/locked_door.gd"
CRACKED_SCENE = "res://scenes/world/cracked_wall.tscn"
THORN_HEDGE_SCENE = "res://scenes/world/thorn_hedge.tscn"
CUT_SCREEN_SCENES = {
    "reed_cluster": "res://scenes/world/reed_cluster.tscn",
    "rush_wall": "res://scenes/world/rush_wall.tscn",
}
HIDDEN_STAIRS_SCENE = "res://scenes/world/hidden_stairs.tscn"
ITEM_PICKUP_SCENE = "res://scenes/pickups/item_pickup.tscn"
PICKUP_SCENES = {
    "wick_core": "res://scenes/pickups/wick_core.tscn",
    "small_key": "res://scenes/pickups/key.tscn",
    "pot_bag": "res://scenes/pickups/pot_bag.tscn",
    "pot_bundle": "res://scenes/pickups/pitch_pot_bundle.tscn",
    "slug_bundle": "res://scenes/pickups/slug_bundle.tscn",
    "big_key": "res://scenes/pickups/big_key.tscn",
    "fragment": "res://scenes/pickups/fragment.tscn",
}
PICKUP_NODE_NAME = {"item": "ItemPickup", "small_key": "Key", "pot_bundle": "PitchPotBundle"}
SHOP_SCENE = "res://scenes/world/shop_item.tscn"  # ShopItem (F9): stock kind, one-time id and shop id
SHOP_STOCK = ("ember", "pot_bundle", "slug_bundle", "tallow_flask")  # ShopItem.STOCK_KINDS
SHOP_ONE_TIME = ("pot_bundle", "slug_bundle")  # ShopItem.ONE_TIME: these need id=, the flag shop_<id>
SHOP_ID_RE = re.compile(r"^S\d+$")
# The dev rooms keep their section 15 persistent ids; see docs/room-kit.md. Other rooms use graph ids.
DEV_PICKUP_ID_ALIASES = {
    "ow_0_0": {},
    "ow_0_1": {"tether_moth": "tether_moth"},
    "ow_1_0": {},
    "ow_1_1": {},
    "ow_2_0": {"wick_core_ow_2_0": "wick_core_cache"},
    "ow_2_1": {"pitch_pot": "pitch_pot"},
    "cave_1": {"key_ow_1": "cave_key"},
}
# The pieces a cache is made of, from the graph's `contents` text. Slug bundles are not pieces: the graph gives
# each one its own pickup line (for example slug_bundle_ow_4_1), which the room places as `pickup slug_bundle`.
CACHE_PART_RE = re.compile(r"^(?:(\d+) brass|(\d+) embers|ember|pot bundle|slug bundle)$")
CACHE_PIECE_SCENES = {
    "brass": "res://scenes/pickups/brass_coin.tscn",
    "ember": "res://scenes/pickups/ember.tscn",
    "pot_bundle": "res://scenes/pickups/pitch_pot_bundle.tscn",
}
CACHE_PIECE_NAME = {"brass": "BrassCoin", "ember": "Ember", "pot_bundle": "PitchPotBundle"}
OPENER_SIZE = {
    "cracked_wall": (96, 96),
    "locked_door": (192, 96),
    "thorn_hedge": (192, 96),
    # Bush's collision circle is contained by one 96 px tile; a wide screen uses one per gap tile.
    "cut_screen": (96, 96),
}
OPENER_SIZE.update({"thorn_door": (192, 96), "eye_portcullis": (192, 96),
                    "heavy_stone": (96, 96), "heavy_boulder": (96, 96),
                    "hook_tap_wall": (192, 96), "wax_seal": (192, 96),
                    "ward_blocker": (192, 96)})
LINKED = {"eye_switch": "eye_portcullis", "ward_plate": "ward_blocker"}
SCRIPTED_OPENERS = {"thorn_door": ("thorn_door", "burn_id"),
                    "eye_portcullis": ("eye_portcullis", "eye_id"),
                    "heavy_stone": ("heavy_stone", "stone_id"),
                    "heavy_boulder": ("heavy_boulder", "stone_id"),
                    "hook_tap_wall": ("hook_tap_wall", "seam_id"),
                    "wax_seal": ("wax_seal", "seal_id"),
                    "ward_blocker": ("ward_plate", "ward_id")}
OPENER_SIZE.update({"gate": (192, 96), "boss_door": (192, 96)})
OPENER_OPTS = ("id", "size", "scope", "look", "braziers")
PROP_SIZE = (96, 96)
# Solid kinds a `prop` line may place: plain SolidBlocks in the hand-made scenes. A prop with its own script
# (burnable, gate, eye switch, ...) needs its own entity kind here first, so it cannot compile as a plain block.
PROP_KINDS = ("hut", "pedestal", "sign_post", "wall", "water", "rock", "tree", "reed")
POS_RE = re.compile(r"^(@)?(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)$")
IDENT_RE = re.compile(r"^[a-z][a-z0-9_]*$")
ENTITY_OPTS = {
    "eye_switch": ("id",),
    "ward_plate": ("id", "size", "blocks_required"),
    "anchor_ring": ("look", "max_range"),
    "grate": ("size",),
    "pit": ("size", "look"),
    "water": ("size",),
    "shallows": ("size",),
    "mooring": ("id", "target_room", "target_mooring", "landing_offset"),
    "ledge": ("size",),
    "enemy": (),
    "miniboss": (),
    "boss": (),
    "arena": (),
    "brazier": ("id",),
    "pickup": ("id", "requires", "scope"),
    "prop": ("size", "visual_offset"),
    "opener": OPENER_OPTS,
    "door": ("blocker",),
    "hidden_stairs": ("id",),
    "spawn": (),
    "shop": ("id",),
    "cache": ("id",),
}


# ---- geometry --------------------------------------------------------------------------------


def centre_of(col: int, row: int) -> tuple[float, float]:
    return (col * TILE + TILE / 2, row * TILE + TILE / 2)


def tile_of(px: float, py: float) -> tuple[int, int]:
    """Tile of a room-local point, clamped to the grid (tests/area_base.gd tile_of)."""
    return (min(max(int(px // TILE), 0), COLS - 1), min(max(int(py // TILE), 0), ROWS - 1))


def tiles_of_rect(left: float, top: float, width: float, height: float) -> set[tuple[int, int]]:
    """Tiles a rectangle overlaps, with the 4 px margin of tests/area_base.gd."""
    tiles: set[tuple[int, int]] = set()
    for col in range(COLS):
        for row in range(ROWS):
            x, y = col * TILE + 4.0, row * TILE + 4.0
            if x < left + width and left < x + TILE - 8 and y < top + height and top < y + TILE - 8:
                tiles.add((col, row))
    return tiles


def exit_corridor(side: str) -> list[tuple[int, int]]:
    """The corridor in front of a gap: two tiles wide, EXIT_DEPTH deep, the ring tiles included."""
    tiles: list[tuple[int, int]] = []
    for k in range(EXIT_DEPTH + 1):
        if side == "n":
            tiles += [(9, k), (10, k)]
        elif side == "s":
            tiles += [(9, ROWS - 1 - k), (10, ROWS - 1 - k)]
        elif side == "w":
            tiles += [(k, 4), (k, 5)]
        else:
            tiles += [(COLS - 1 - k, 4), (COLS - 1 - k, 5)]
    return tiles


def corridor_side(tile: tuple[int, int], exits: list[str]) -> str | None:
    """The graph exit corridor containing `tile`, if any."""
    return next((side for side in SIDES if side in exits and tile in exit_corridor(side)), None)


def neighbours(tile: tuple[int, int]) -> list[tuple[int, int]]:
    col, row = tile
    return [(col + 1, row), (col - 1, row), (col, row + 1), (col, row - 1)]


def flood(starts: list[tuple[int, int]], blocked: set[tuple[int, int]]) -> set[tuple[int, int]]:
    seen = {s for s in starts if s not in blocked and 0 <= s[0] < COLS and 0 <= s[1] < ROWS}
    stack = list(seen)
    while stack:
        for nxt in neighbours(stack.pop()):
            if 0 <= nxt[0] < COLS and 0 <= nxt[1] < ROWS and nxt not in seen and nxt not in blocked:
                seen.add(nxt)
                stack.append(nxt)
    return seen


def reaches(seen: set[tuple[int, int]], tile: tuple[int, int]) -> bool:
    """A pickup reaches its own tile and the tiles next to it (its circle is wider than the tile)."""
    return tile in seen or any(n in seen for n in neighbours(tile))


def merge_rects(grid: list[str], char: str) -> list[tuple[int, int, int, int]]:
    """Greedy row-major merge into (col, row, width, height). A ring '#' is never merged."""

    def emitted(col: int, row: int) -> bool:
        if grid[row][col] != char:
            return False
        return char != "#" or (0 < col < COLS - 1 and 0 < row < ROWS - 1)

    used: set[tuple[int, int]] = set()
    rects: list[tuple[int, int, int, int]] = []
    for row in range(ROWS):
        for col in range(COLS):
            if (col, row) in used or not emitted(col, row):
                continue
            width = 1
            while col + width < COLS and emitted(col + width, row) and (col + width, row) not in used:
                width += 1
            height = 1
            while row + height < ROWS and all(
                emitted(c, row + height) and (c, row + height) not in used for c in range(col, col + width)
            ):
                height += 1
            used.update((c, r) for r in range(row, row + height) for c in range(col, col + width))
            rects.append((col, row, width, height))
    return rects


# ---- world data ------------------------------------------------------------------------------


def snake(name: str) -> str:
    """Graph monster name to scene name: 'Tallow blob' -> tallow_blob, 'NEW:wickling' -> wickling."""
    text = name.lower().replace(" ", "_")
    return text[4:] if text.startswith("new:") else text


def persistent_pickup_id(room_id: str, graph_id: str) -> str:
    """Return the legacy persistent id for a dev pickup, or the graph id everywhere else."""
    return DEV_PICKUP_ID_ALIASES.get(room_id, {}).get(graph_id, graph_id)


class World:
    """The records of data/world_data.json the compiler reads, normalised, and the shop prices."""

    def __init__(self, data: dict, shop_prices: dict | None = None, graph: dict | None = None) -> None:
        self.prices: dict[str, dict[str, int]] = (shop_prices or {}).get("shops", {})
        graph_contents = {p["id"]: p["contents"] for p in (graph or {}).get("pickups", []) if "contents" in p}
        self.rooms: dict[str, dict] = {}
        graph_nodes = {n["id"]: n for n in (graph or {}).get("nodes", [])}
        for room in data["rooms"]:
            self.rooms[room["id"]] = {
                "id": room["id"],
                "grid": tuple(room["grid"]),
                "exits": list(room["exits"]),
                "dark": bool(room["dark"]),
                "scope": room["scope"],
                "enemies": {snake(n): int(c) for n, c in room["enemies"].items()},
                "encounters": {role: snake(graph_nodes.get(room["id"], {}).get(role, {})["name"])
                               for role in ("miniboss", "boss")
                               if "name" in graph_nodes.get(room["id"], {}).get(role, {})},
                "pocket": False,
                "host": None,
                "in_place": False,
            }
        for pocket in data["pockets"]:
            host = self.rooms.get(pocket["host"], {})
            cave_host = (re.fullmatch(r"c[1-9][0-9]*", pocket["scope"]) is not None
                         and pocket["scope"] == host.get("scope"))
            default_dark = host.get("dark", False) if cave_host else False
            pocket_dark = pocket.get("dark", graph_nodes.get(pocket["id"], {}).get("dark", default_dark))
            self.rooms[pocket["id"]] = {
                "id": pocket["id"],
                "grid": tuple(pocket["grid"]),
                "exits": [],
                "dark": bool(pocket_dark),
                "scope": pocket["scope"],
                "enemies": {},
                "pocket": True,
                "host": pocket["host"],
                "in_place": bool(pocket["in_place"]),
            }
        self.edges: list[dict] = data["edges"]
        self.pickups: list[dict] = [
            {
                "id": p["id"],
                "kind": p["kind"],
                "node": p["node"],
                "after_boss": bool(p.get("after_boss")),
                "scope": p.get("scope"),
                "needs": list(p.get("needs", [])),
                "shop": p.get("shop"),
                "contents": graph_contents.get(p["id"], p.get("contents", "")),
            }
            for p in data["pickups"]
        ]
        for key, record in data["items"].items():
            self.pickups.append(item_as_pickup(key, record))

    def room(self, room_id: str) -> dict | None:
        return self.rooms.get(room_id)

    def placed_nodes(self, room_id: str) -> set[str]:
        """The room and the pockets that open in place: their content is in this room's scene."""
        nodes = {room_id}
        nodes.update(r["id"] for r in self.rooms.values() if r["pocket"] and r["in_place"] and r["host"] == room_id)
        return nodes

    def price(self, shop: str, stock: str) -> int | None:
        return self.prices.get(shop, {}).get(stock)

    def pickup_record(self, ident: str) -> dict | None:
        return next((p for p in self.pickups if p["id"] == ident), None)

    def door_edges(self, room_id: str) -> list[dict]:
        return [e for e in self.edges if e["link"] == "door" and room_id in (e["a"], e["b"])]


def item_as_pickup(key: str, record: dict) -> dict:
    """Graph items that are not tools: bigkey:cN is big_key bigkey_cN, frag:cN is fragment frag_cN."""
    if key.startswith("bigkey:"):
        ident, kind = "bigkey_" + key.split(":", 1)[1], "big_key"
    elif key.startswith("frag:"):
        ident, kind = "frag_" + key.split(":", 1)[1], "fragment"
    else:
        ident, kind = key, "item"
    return {
        "id": ident,
        "kind": kind,
        "node": record["node"],
        "after_boss": bool(record.get("after_boss")),
        "shop": None,
        "scope": key.split(":", 1)[1] if ":" in key else None,
        "needs": list(record.get("needs", [])),
        "contents": "",
    }


# ---- the .room source ------------------------------------------------------------------------


class Entity:
    def __init__(self, verb: str, line: int, pos: tuple[float, float], args: list[str], opts: dict[str, str]) -> None:
        self.verb = verb
        self.line = line
        self.pos = pos
        self.args = args
        self.opts = opts

    @property
    def tile(self) -> tuple[int, int]:
        return tile_of(*self.pos)


class Source:
    def __init__(self, path: Path) -> None:
        self.path = path
        self.scope = "ow"  # the room's key scope, set from the graph before the entities are read
        self.room_id: str | None = None
        self.room_line = 1
        self.floor: tuple[float, float, float] | None = None
        self.terrain: str | None = None
        self.grid: list[str] = []
        self.grid_lines: list[int] = []
        self.entities: list[Entity] = []


def where(path: Path, line: int) -> str:
    try:
        shown = path.relative_to(ROOT)
    except ValueError:
        shown = path
    return f"{shown}:{line}"


def parse_source(path: Path, errors: list[str]) -> Source | None:
    src = Source(path)
    lines = path.read_text(encoding="utf-8").replace("\r\n", "\n").split("\n")
    n_errors = len(errors)
    i = 0
    while i < len(lines):
        lineno = i + 1
        body = lines[i].split(";", 1)[0].strip()
        i += 1
        if not body:
            continue
        tokens = body.split()
        verb = tokens[0]
        if verb == "grid":
            if src.grid:
                errors.append(f"{where(path, lineno)}: a second grid block")
                continue
            rows = lines[i : i + ROWS]
            src.grid_lines = list(range(i + 1, i + 1 + len(rows)))
            i += len(rows)
            if len(rows) != ROWS:
                errors.append(f"{where(path, lineno)}: the grid needs {ROWS} rows")
                return None
            for row_no, row in zip(src.grid_lines, rows):
                if len(row) != COLS:
                    errors.append(f"{where(path, row_no)}: grid row has {len(row)} characters, needs {COLS}")
                elif any(ch not in GRID_CHARS for ch in row):
                    bad = "".join(sorted({ch for ch in row if ch not in GRID_CHARS}))
                    errors.append(f"{where(path, row_no)}: unknown grid character(s) {bad!r}")
            src.grid = rows
        elif verb == "room":
            if len(tokens) != 2:
                errors.append(f"{where(path, lineno)}: 'room' takes one id")
            else:
                src.room_id, src.room_line = tokens[1], lineno
        elif verb == "floor_color":
            try:
                rgb = tuple(float(t) for t in tokens[1:])
            except ValueError:
                rgb = ()
            if len(rgb) == 3 and all(0.0 <= c <= 1.0 for c in rgb):
                src.floor = (rgb[0], rgb[1], rgb[2])
            else:
                errors.append(f"{where(path, lineno)}: floor_color takes three values from 0 to 1")
        elif verb == "terrain":
            src.terrain = body[len("terrain") :].strip()
        elif not src.grid:
            errors.append(f"{where(path, lineno)}: '{verb}' comes before the grid block")
        else:
            entity = parse_entity(tokens, lineno, path, errors)
            if entity is not None:
                src.entities.append(entity)
    if src.room_id is None:
        errors.append(f"{where(path, 1)}: missing 'room <id>' line")
    if not src.grid and len(errors) == n_errors:
        errors.append(f"{where(path, 1)}: missing grid block")
    return src if len(errors) == n_errors else None


def parse_entity(tokens: list[str], line: int, path: Path, errors: list[str]) -> Entity | None:
    verb = tokens[0]
    if verb not in ENTITY_OPTS:
        errors.append(f"{where(path, line)}: unknown entity '{verb}'")
        return None
    pos: tuple[float, float] | None = None
    args: list[str] = []
    opts: dict[str, str] = {}
    for token in tokens[1:]:
        if "=" in token:
            key, _, value = token.partition("=")
            if key not in ENTITY_OPTS[verb]:
                errors.append(f"{where(path, line)}: '{verb}' takes no option '{key}'")
                return None
            opts[key] = value
            continue
        match = POS_RE.match(token) if pos is None else None
        if match is None:
            args.append(token)
            continue
        x, y = float(match.group(2)), float(match.group(3))
        if match.group(1):
            pos = (x, y)
        elif x.is_integer() and y.is_integer():
            pos = centre_of(int(x), int(y))
        else:
            errors.append(f"{where(path, line)}: tile position {token} must be whole tiles (use @x,y for pixels)")
            return None
    if pos is None:
        errors.append(f"{where(path, line)}: '{verb}' needs a position x,y (tile) or @x,y (pixels)")
        return None
    return Entity(verb, line, pos, args, opts)


def parse_size(text: str) -> tuple[float, float] | None:
    parts = text.split(",")
    if len(parts) != 2:
        return None
    try:
        width, height = float(parts[0]), float(parts[1])
    except ValueError:
        return None
    return (width, height) if width > 0 and height > 0 else None


# ---- the output tree -------------------------------------------------------------------------


class Res:
    """A script or scene a node uses; its ext_resource id is given when the text is written."""

    def __init__(self, kind: str, path: str) -> None:
        self.kind = kind
        self.path = path


class Node:
    def __init__(self, name: str, parent: str, typ: str | None = None, scene: Res | None = None) -> None:
        self.name = name
        self.parent = parent
        self.typ = typ
        self.scene = scene
        self.base = name  # numbered output name stem, see name_all()
        self.enemy = ""  # monster scene name, enemies only
        self.props: list[tuple[str, object]] = []


class Plan:
    """The nodes of one room and the tiles they block. Lists are in output order."""

    def __init__(self) -> None:
        self.static: set[tuple[int, int]] = set()
        self.merged: list[Node] = []
        self.singles: list[tuple[tuple, Node]] = []  # (sort key, node) for Props and Bushes
        self.enemies: list[tuple[tuple, Node, Entity]] = []
        self.spawns: list[tuple[str, tuple[int, int], Node]] = []
        self.openers: list[tuple[Entity, set[tuple[int, int]]]] = []
        self.pickups: list[tuple[Entity, str, str]] = []  # (entity, persistent id, kind); a cache is kind cache
        self.shops: list[tuple[Entity, str, str, str]] = []  # (entity, shop id, stock kind, stock id or "")
        self.doors: list[Entity] = []
        self.zones: list[tuple[Entity, tuple[float, float]]] = []
        self.water: set[tuple[int, int]] = set()
        self.moorings: list[Entity] = []
        self.anchors: list[Entity] = []
        self.entity_nodes: dict[Entity, Node] = {}
        self.door_links: list[tuple[Node, Node]] = []
        self.drop_exits: list[str] = []
        self.controls: list[Entity] = []
        self.grates: set[tuple[int, int]] = set()
        self.pits: set[tuple[int, int]] = set()
        self.pit_rects: list[tuple[Entity, tuple[float, float]]] = []
        self.braziers: dict[str, list[tuple[Entity, Node]]] = {}
        self.gate_links: list[tuple[Node, list[Node]]] = []


def build_plan(src: Source, world: World, errors: list[str]) -> Plan | None:
    """Turns the grid and the entities into nodes. Syntax and per-entity errors are reported here."""
    plan = Plan()
    grid = src.grid
    for row in range(ROWS):
        for col in range(COLS):
            if grid[row][col] in TERRAIN_KIND or grid[row][col] == BUSH_CHAR:
                plan.static.add((col, row))
    for char in MERGED_CHARS:
        for col, row, width, height in merge_rects(grid, char):
            node = Node("", "Props", "StaticBody2D")
            node.props = [
                ("position", vec2(col * TILE + width * TILE / 2, row * TILE + height * TILE / 2)),
                ("script", Res("Script", SOLID_SCRIPT)),
                ("size", vec2(width * TILE, height * TILE)),
                ("kind", sname(TERRAIN_KIND[char])),
            ]
            node.base = camel(TERRAIN_KIND[char])
            plan.merged.append(node)
    for row in range(ROWS):
        for col in range(COLS):
            char = grid[row][col]
            if char in TERRAIN_KIND and char not in MERGED_CHARS:
                node = Node("", "Props", "StaticBody2D")
                node.props = [
                    ("position", vec2(*centre_of(col, row))),
                    ("script", Res("Script", SOLID_SCRIPT)),
                    ("size", vec2(TILE, TILE)),
                    ("kind", sname(TERRAIN_KIND[char])),
                ]
                node.base = camel(TERRAIN_KIND[char])
                plan.singles.append(((row, col, -1), node))
            elif char == BUSH_CHAR:
                node = Node("", "Bushes", "StaticBody2D")
                node.props = [("position", vec2(*centre_of(col, row))), ("script", Res("Script", BUSH_SCRIPT))]
                node.base = "Bush"
                plan.singles.append(((row, col, -1), node))
    ok = True
    for seq, ent in enumerate(src.entities):
        ok = dispatch(ent, seq, src, plan, world, errors) and ok
        key = (ent.tile[1], ent.tile[0], seq)
        for candidate_key, node in plan.singles:
            if candidate_key == key:
                plan.entity_nodes[ent] = node
    if not ok:
        return None
    plan.singles.sort(key=lambda pair: pair[0])
    return plan


def dispatch(ent: Entity, seq: int, src: Source, plan: Plan, world: World, errors: list[str]) -> bool:
    where_ = where(src.path, ent.line)
    key = (ent.tile[1], ent.tile[0], seq)
    if ent.verb in ("eye_switch", "ward_plate", "grate", "pit"):
        return dispatch_scripted(ent, key, src, plan, errors)
    if ent.verb in ("water", "shallows", "mooring", "ledge", "anchor_ring"):
        return dispatch_crossing(ent, key, src, plan, world, errors)
    if ent.verb == "brazier":
        ident = ent.opts.get("id", "")
        if ent.args or not IDENT_RE.fullmatch(ident):
            errors.append(f"{where_}: brazier needs id=<snake_case id> and no other arguments")
            return False
        if ent.tile in plan.static:
            errors.append(f"{where_}: brazier overlaps a solid obstacle")
            return False
        node = Node("", "Props", "StaticBody2D")
        node.base = "Brazier"
        node.props = [("position", vec2(*ent.pos)),
                      ("script", Res("Script", "res://scripts/world/brazier.gd")),
                      ("brazier_id", sname(ident))]
        plan.braziers.setdefault(ident, []).append((ent, node))
        plan.static.add(ent.tile)
        plan.singles.append((key, node))
        return True
    if ent.verb == "arena":
        expected = world.room(src.room_id).get("encounters", {}).get("boss")
        if ent.args != [expected] or expected is None:
            errors.append(f"{where_}: arena must name this graph room's boss")
            return False
        node = Node("", "Props", None, Res("PackedScene", f"res://scenes/bosses/{expected}_arena.tscn"))
        node.base = "Arena"
        node.props = [("position", vec2(*ent.pos))]
        plan.singles.append((key, node))
        if sum(e.verb == "arena" for e in src.entities) != 1:
            errors.append(f"{where_}: only one arena instance is allowed")
            return False
        return True
    if ent.verb in ("enemy", "miniboss", "boss"):
        if len(ent.args) != 1 or not IDENT_RE.match(snake(ent.args[0])):
            errors.append(f"{where_}: enemy takes one monster name")
            return False
        name = snake(ent.args[0])
        directory = {"enemy": "", "boss": "bosses/", "miniboss": "minibosses/"}[ent.verb]
        node = Node("", "Enemies", None, Res("PackedScene", f"res://scenes/enemies/{directory}{name}.tscn"))
        node.props = [("position", vec2(*ent.pos))]
        node.base = camel(name)
        node.enemy = name
        plan.enemies.append((key, node, ent))
        return True
    if ent.verb == "spawn":
        if len(ent.args) != 1 or ent.args[0] not in SPAWN_NAMES:
            errors.append(f"{where_}: spawn name must be one of {', '.join(SPAWN_NAMES)}")
            return False
        node = Node(ent.args[0], "Spawns", "Marker2D")
        node.props = [("position", vec2(*ent.pos))]
        plan.spawns.append((ent.args[0], ent.tile, node))
        return True
    if ent.verb == "prop":
        if len(ent.args) != 1 or ent.args[0] not in PROP_KINDS:
            errors.append(f"{where_}: prop kind must be one of {', '.join(PROP_KINDS)} (docs/room-kit.md)")
            return False
        size = PROP_SIZE
        if "size" in ent.opts:
            parsed = parse_size(ent.opts["size"])
            if parsed is None:
                errors.append(f"{where_}: size takes two positive numbers, size=<w>,<h>")
                return False
            size = parsed
        node = Node("", "Props", "StaticBody2D")
        node.props = [
            ("position", vec2(*ent.pos)),
            ("script", Res("Script", SOLID_SCRIPT)),
            ("size", vec2(*size)),
            ("kind", sname(ent.args[0])),
        ]
        if "visual_offset" in ent.opts:
            try:
                offset = tuple(float(v) for v in ent.opts["visual_offset"].split(","))
            except ValueError:
                offset = ()
            if len(offset) != 2 or not all(math.isfinite(v) for v in offset):
                errors.append(f"{where_}: visual_offset takes two finite pixel numbers, visual_offset=<x>,<y>")
                return False
            if offset != (0.0, 0.0):
                node.props.append(("visual_offset", vec2(*offset)))
        node.base = camel(ent.args[0])
        plan.static |= tiles_of_rect(ent.pos[0] - size[0] / 2, ent.pos[1] - size[1] / 2, size[0], size[1])
        plan.singles.append((key, node))
        return True
    if ent.verb == "opener":
        return dispatch_opener(ent, key, src, plan, world, errors)
    if ent.verb == "door":
        if len(ent.args) != 2 or ent.args[1] not in SPAWN_NAMES:
            errors.append(f"{where_}: door takes a target room and a spawn name ({', '.join(SPAWN_NAMES)})")
            return False
        node = Node("", "Props", "Area2D")
        node.props = [
            ("position", vec2(*ent.pos)),
            ("script", Res("Script", DOOR_SCRIPT)),
            ("target_room", sname(ent.args[0])),
            ("target_spawn", sname(ent.args[1])),
        ]
        node.base = "Door"
        plan.doors.append(ent)
        plan.singles.append((key, node))
        return True
    if ent.verb == "hidden_stairs":
        return dispatch_hidden_stairs(ent, key, src, plan, errors)
    if ent.verb == "shop":
        return dispatch_shop(ent, key, src, plan, errors)
    if ent.verb == "cache":
        return dispatch_cache(ent, key, src, plan, world, errors)
    return dispatch_pickup(ent, key, src, plan, world, errors)


def edge_side(world: World, room_id: str, other: str) -> str | None:
    a, b = world.room(room_id), world.room(other)
    if a is None or b is None:
        return None
    delta = (b["grid"][0] - a["grid"][0], b["grid"][1] - a["grid"][1])
    return {(0, -1): "n", (1, 0): "e", (0, 1): "s", (-1, 0): "w"}.get(delta)


def dispatch_crossing(ent, key, src, plan, world, errors) -> bool:
    def fail(message):
        errors.append(f"{where(src.path, ent.line)}: {message}")
        return False

    verb = ent.verb
    scene = {"water": "water_zone", "shallows": "shallow_zone", "mooring": "mooring", "ledge": "ledge", "anchor_ring": "anchor_ring"}[verb]
    node = Node("", "Props", None, Res("PackedScene", f"res://scenes/world/{scene}.tscn"))
    node.base = camel(scene)
    node.props = [("position", vec2(*ent.pos))]
    if verb == "anchor_ring":
        if not (0 <= ent.pos[0] < COLS * TILE and 0 <= ent.pos[1] < ROWS * TILE):
            return fail("anchor_ring must stand inside the room")
        if ent.args or ent.opts.get("look", "anchor_ring") not in ("anchor_ring", "anchor_pocket"):
            return fail("anchor_ring takes optional look=anchor_ring or anchor_pocket and max_range=")
        try:
            distance = float(ent.opts.get("max_range", "0"))
        except ValueError:
            distance = -1
        if not math.isfinite(distance) or distance < 0:
            return fail("anchor_ring max_range must be a finite nonnegative pixel distance")
        if "look" in ent.opts:
            node.props.append(("look", sname(ent.opts["look"])))
        if "max_range" in ent.opts:
            node.props.append(("max_range", str(distance)))
        plan.anchors.append(ent)
    elif verb == "mooring":
        if ent.args or any(not IDENT_RE.fullmatch(ent.opts.get(k, "")) for k in ("id", "target_room", "target_mooring")):
            return fail("mooring takes id=, target_room= and target_mooring= identifiers")
        target = ent.opts["target_room"]
        if not any(e["prop"] in ("mooring and water", "flooded passage") and
                   {e["a"], e["b"]} == {src.room_id, target} for e in world.edges):
            return fail("mooring target must match a graph raft edge")
        if any(m.opts["id"] == ent.opts["id"] for m in plan.moorings):
            return fail("duplicate mooring id")
        for option, prop in (("id", "mooring_id"), ("target_room", "target_room"), ("target_mooring", "target_mooring")):
            node.props.append((prop, sname(ent.opts[option])))
        if "landing_offset" in ent.opts:
            match = POS_RE.fullmatch(ent.opts["landing_offset"])
            if match is None or match.group(1):
                return fail("landing_offset takes two pixel numbers")
            offset = (float(match.group(2)), float(match.group(3)))
            node.props.append(("landing_offset", vec2(*offset)))
        plan.moorings.append(ent)
        plan.static |= tiles_of_rect(ent.pos[0] - 16, ent.pos[1] - 16, 32, 32)
    else:
        size = parse_size(ent.opts.get("size", "288,48" if verb == "ledge" else "192,192"))
        if size is None:
            return fail("size takes two positive numbers")
        if verb == "ledge":
            if len(ent.args) != 1 or ent.args[0] not in SIDES:
                return fail("ledge takes one side n/e/s/w")
            side = ent.args[0]
            outgoing = [e for e in world.edges if e["gate"] == "oneway" and
                        ((e["a"] == src.room_id and e["dir"] == "a>b") or
                         (e["b"] == src.room_id and e["dir"] == "b>a"))]
            if not any(edge_side(world, src.room_id, e["b"] if e["a"] == src.room_id else e["a"]) == side for e in outgoing):
                return fail("ledge side must be an outgoing graph one-way drop")
            if side in plan.drop_exits:
                return fail("duplicate ledge side")
            plan.drop_exits.append(side)
        else:
            if ent.args:
                return fail(f"{verb} takes a position and optional size=")
            plan.zones.append((ent, size))
            if verb == "water":
                tiles = tiles_of_rect(ent.pos[0] - size[0] / 2, ent.pos[1] - size[1] / 2, *size)
                plan.water |= tiles
                plan.static |= tiles
                node.props.append(("deep", "true"))
        node.props.append(("size", vec2(*size)))
    plan.singles.append((key, node))
    return True


def dispatch_shop(ent: Entity, key: tuple, src: Source, plan: Plan, errors: list[str]) -> bool:
    """`shop <S1..Sn> <stock kind> <pos> [id=<stock id>]`: a ShopItem. Its price is checked in check_shops."""
    where_ = where(src.path, ent.line)
    if len(ent.args) != 2 or not SHOP_ID_RE.match(ent.args[0]) or ent.args[1] not in SHOP_STOCK:
        errors.append(f"{where_}: shop takes a shop id (S1..), a stock kind ({', '.join(SHOP_STOCK)}) and a position")
        return False
    shop_id, kind = ent.args
    ident = ent.opts.get("id", "")
    if ident and not IDENT_RE.match(ident):
        errors.append(f"{where_}: shop id={ident} must be snake_case")
        return False
    node = Node("", "Props", None, Res("PackedScene", SHOP_SCENE))
    node.props = [("position", vec2(*ent.pos)), ("shop", sname(shop_id)), ("stock", sname(kind))]
    if ident:
        node.props.append(("stock_id", sname(ident)))
    node.base = "ShopItem"
    plan.shops.append((ent, shop_id, kind, ident))
    plan.singles.append((key, node))
    return True


def dispatch_cache(ent: Entity, key: tuple, src: Source, plan: Plan, world: World, errors: list[str]) -> bool:
    """`cache <pos> id=<graph cache id>`: the contents come from the graph (brass, embers, a pot bundle)."""
    where_ = where(src.path, ent.line)
    ident = ent.opts.get("id", "")
    if ent.args or not IDENT_RE.match(ident):
        errors.append(f"{where_}: cache takes a position and id=<graph cache id>")
        return False
    plan.pickups.append((ent, ident, "cache"))
    record = world.pickup_record(ident)
    if record is None or record["kind"] != "cache":
        return True  # check_pickups reports an id the graph does not have
    pieces = cache_pieces(ident, record["contents"])
    if pieces is None:
        errors.append(f"{where_}: cache {ident} has contents {record['contents']!r}, which the compiler does not know")
        return False
    for kind, persistent, amount in pieces:
        node = Node("", "Props", None, Res("PackedScene", CACHE_PIECE_SCENES[kind]))
        node.props = [("position", vec2(*ent.pos)), ("persistent_id", sname(persistent))]
        if kind == "brass":
            node.props.append(("amount", str(amount)))
        node.base = CACHE_PIECE_NAME[kind]
        plan.singles.append((key, node))
    return True


def cache_pieces(ident: str, contents: str) -> list[tuple[str, str, int]] | None:
    """(kind, persistent id, amount) of each piece of a cache, from its graph text; None if a part is unknown.
    Pieces lie on the cache's spot and are collected together. A brass piece holds the whole amount."""
    pieces: list[tuple[str, str, int]] = []
    embers = 0
    for part in (text.strip() for text in contents.split(",")):
        match = CACHE_PART_RE.match(part)
        if match is None:
            return None
        if match.group(1):
            pieces.append(("brass", f"{ident}_brass", int(match.group(1))))
        elif match.group(2) or part == "ember":
            for _ in range(int(match.group(2) or 1)):
                embers += 1
                pieces.append(("ember", f"{ident}_ember{embers}", 0))
        elif part == "pot bundle":
            pieces.append(("pot_bundle", f"{ident}_pots", 0))
    return pieces


def dispatch_scripted(ent, key, src, plan, errors) -> bool:
    kind = ent.verb
    if ent.args:
        errors.append(f"{where(src.path, ent.line)}: {kind} takes no positional arguments besides position")
        return False
    default = {"eye_switch": (60, 60), "ward_plate": (96, 96), "grate": (192, 96), "pit": (192, 192)}[kind]
    size = parse_size(ent.opts["size"]) if "size" in ent.opts else default
    if size is None:
        errors.append(f"{where(src.path, ent.line)}: invalid size")
        return False
    scene = kind
    node = Node("", "Props", None, Res("PackedScene", f"res://scenes/world/{scene}.tscn"))
    node.base = camel(kind)
    node.props = [("position", vec2(*ent.pos))]
    if kind in LINKED:
        ident = ent.opts.get("id", "")
        if not IDENT_RE.fullmatch(ident):
            errors.append(f"{where(src.path, ent.line)}: {kind} needs id=<snake_case id>")
            return False
        node.props.append(("eye_id" if kind == "eye_switch" else "ward_id", sname(ident)))
        plan.controls.append(ent)
    if kind != "eye_switch":
        node.props.append(("size", vec2(*size)))
    if kind == "ward_plate":
        count = ent.opts.get("blocks_required", "3")
        if not count.isdigit() or not 1 <= int(count) <= 20:
            errors.append(f"{where(src.path, ent.line)}: blocks_required must be 1..20")
            return False
        node.props.append(("blocks_required", str(int(count))))
    if kind == "pit":
        look = ent.opts.get("look", "pit")
        if look not in ("pit", "ravine"):
            errors.append(f"{where(src.path, ent.line)}: pit look must be pit or ravine")
            return False
        node.props.append(("look", sname(look)))
    tiles = tiles_of_rect(ent.pos[0]-size[0]/2, ent.pos[1]-size[1]/2, *size)
    if kind == "grate" and tiles & plan.static:
        errors.append(f"{where(src.path, ent.line)}: grate overlaps a solid obstacle")
        return False
    if kind in ("grate", "eye_switch", "pit"):
        plan.static |= tiles
    if kind == "grate":
        plan.grates |= tiles
    if kind == "pit":
        plan.pits |= tiles
        plan.pit_rects.append((ent, size))
    plan.singles.append((key, node))
    return True


def dispatch_opener(ent: Entity, key: tuple, src: Source, plan: Plan, world: World, errors: list[str]) -> bool:
    where_ = where(src.path, ent.line)
    if len(ent.args) != 1 or ent.args[0] not in OPENER_SIZE:
        errors.append(f"{where_}: opener takes one of {', '.join(OPENER_SIZE)}")
        return False
    kind = ent.args[0]
    if kind in ("gate", "boss_door"):
        allowed = {"id", "size", "braziers"} if kind == "gate" else {"id", "size"}
        ident = ent.opts.get("id", "")
        edge = next((e for e in world.edges if e["id"] == ident), None)
        expected_gate = "brazier" if kind == "gate" else "boss"
        if (set(ent.opts) - allowed or edge is None or edge["gate"] != expected_gate
                or src.room_id not in (edge["a"], edge["b"])):
            errors.append(f"{where_}: {kind} needs the matching graph edge id and supported options")
            return False
        if kind == "boss_door" and edge.get("needs") != [f"bigkey:{src.scope}"]:
            errors.append(f"{where_}: boss_door graph needs must match the room's cave big key")
            return False
        size = parse_size(ent.opts["size"]) if "size" in ent.opts else OPENER_SIZE[kind]
        if size is None:
            errors.append(f"{where_}: invalid size")
            return False
        other = edge["b"] if edge["a"] == src.room_id else edge["a"]
        side = edge_side(world, src.room_id, other) if edge["link"] == "step" else None
        if side is not None and ent.tile not in exit_corridor(side):
            errors.append(f"{where_}: {kind} must stand in its graph exit corridor")
            return False
        if side in ("e", "w"):
            size = (size[1], size[0])
        node = Node("", "Props", "StaticBody2D" if kind == "gate" else None,
                    None if kind == "gate" else Res("PackedScene", "res://scenes/world/boss_door.tscn"))
        node.base = camel(kind)
        node.props = [("position", vec2(*ent.pos)), ("size", vec2(*size))]
        if kind == "gate":
            node.props.extend([("script", Res("Script", "res://scripts/world/gate.gd")), ("gate_id", sname(ident))])
            ids = ent.opts.get("braziers", "").split(",")
            if not ids or any(not IDENT_RE.fullmatch(i) for i in ids) or len(set(ids)) != len(ids):
                errors.append(f"{where_}: gate needs distinct braziers=<id>,<id> references")
                return False
            if edge.get("prop") == "two braziers, gate" and len(ids) != 2:
                errors.append(f"{where_}: graph gate requires two braziers")
                return False
        else:
            node.props.append(("cave", sname(src.scope)))
        tiles = tiles_of_rect(ent.pos[0]-size[0]/2, ent.pos[1]-size[1]/2, *size)
        plan.openers.append((ent, tiles))
        plan.singles.append((key, node))
        return True
    if "braziers" in ent.opts:
        errors.append(f"{where_}: only opener gate takes braziers=")
        return False
    if kind in SCRIPTED_OPENERS:
        if set(ent.opts) - {"id", "size"}:
            errors.append(f"{where_}: {kind} only takes id and size")
            return False
        ident = ent.opts.get("id", "")
        size = parse_size(ent.opts["size"]) if "size" in ent.opts else OPENER_SIZE[kind]
        if not IDENT_RE.fullmatch(ident) or size is None:
            errors.append(f"{where_}: {kind} needs valid id and size")
            return False
        scene, field = SCRIPTED_OPENERS[kind]
        node = Node("", "Props", None, Res("PackedScene", f"res://scenes/world/{scene}.tscn"))
        node.base = camel(kind)
        node.props = [("position", vec2(*ent.pos)), (field, sname(ident)), ("size", vec2(*size))]
        if kind == "ward_blocker":
            node.props.append(("blocker", "true"))
        edge = next((e for e in world.edges if e["id"] == ident), None)
        expected = {"thorn_door": "thorn-sealed door", "eye_portcullis": "eye-switch portcullis",
                    "heavy_stone": "heavy stones", "heavy_boulder": "heavy boulder",
                    "hook_tap_wall": "hook-tap wall", "wax_seal": "wax seal",
                    "ward_blocker": "ward plate"}[kind]
        if edge is not None and (edge["prop"] != expected or src.room_id not in (edge["a"], edge["b"])):
            errors.append(f"{where_}: {kind} id does not match this graph gate")
            return False
        requirements = {"hook_tap_wall": ("hidden", ["hook"]),
                        "wax_seal": ("item", ["flare"]),
                        "heavy_boulder": ("item", ["heft_mitts"])}
        if edge is not None and kind in requirements:
            gate, needs = requirements[kind]
            if edge.get("gate") != gate or edge.get("needs") != needs:
                errors.append(f"{where_}: {kind} does not match the graph gate requirements")
                return False
        rec = world.room(src.room_id)
        side = corridor_side(ent.tile, rec["exits"])
        if kind == "eye_portcullis" and side in ("e", "w"):
            node.props.append(("rotation", "1.570796"))
            size = (size[1], size[0])
        tiles = tiles_of_rect(ent.pos[0]-size[0]/2, ent.pos[1]-size[1]/2, *size)
        plan.openers.append((ent, tiles))
        plan.singles.append((key, node))
        return True
    if kind == "cut_screen":
        if set(ent.opts) - {"look", "id"}:
            errors.append(f"{where_}: opener cut_screen only takes look= and optional id=")
            return False
        if "id" in ent.opts and not IDENT_RE.fullmatch(ent.opts["id"]):
            errors.append(f"{where_}: cut_screen id must be snake_case")
            return False
        look = ent.opts.get("look", "")
        if look not in CUT_SCREEN_SCENES:
            errors.append(f"{where_}: opener cut_screen needs look=reed_cluster or look=rush_wall")
            return False
        size = OPENER_SIZE[kind]
        tiles = tiles_of_rect(ent.pos[0] - size[0] / 2, ent.pos[1] - size[1] / 2, size[0], size[1])
        plan.openers.append((ent, tiles))
        node = Node("", "Props", None, Res("PackedScene", CUT_SCREEN_SCENES[look]))
        node.props = [("position", vec2(*ent.pos))]
        node.base = camel(look)
        plan.singles.append((key, node))
        return True

    if kind == "thorn_hedge" and "scope" in ent.opts:
        errors.append(f"{where_}: opener thorn_hedge does not take scope=")
        return False
    ident = ent.opts.get("id", "")
    if not IDENT_RE.match(ident):
        errors.append(f"{where_}: opener {kind} needs id=<snake_case id>")
        return False
    if "look" in ent.opts:
        errors.append(f"{where_}: opener {kind} does not take look=")
        return False
    size = OPENER_SIZE[kind]
    if "size" in ent.opts:
        parsed = parse_size(ent.opts["size"])
        if parsed is None:
            errors.append(f"{where_}: size takes two positive numbers, size=<w>,<h>")
            return False
        size = parsed
    side = None
    if kind == "thorn_hedge":
        rec = world.room(src.room_id or "")
        side = corridor_side(ent.tile, rec["exits"] if rec is not None else [])
        if side is None:
            errors.append(f"{where_}: opener thorn_hedge must stand in a graph exit corridor")
            return False
    footprint = (size[1], size[0]) if side in ("e", "w") else size
    tiles = tiles_of_rect(ent.pos[0] - footprint[0] / 2, ent.pos[1] - footprint[1] / 2,
                          footprint[0], footprint[1])
    plan.openers.append((ent, tiles))
    if kind == "cracked_wall":
        node = Node("", "Props", None, Res("PackedScene", CRACKED_SCENE))
        node.props = [("position", vec2(*ent.pos)), ("wall_id", sname(ident))]
        node.base = "CrackedWall"
    elif kind == "thorn_hedge":
        node = Node("", "Props", None, Res("PackedScene", THORN_HEDGE_SCENE))
        node.props = [("position", vec2(*ent.pos)), ("burn_id", sname(ident))]
        if side in ("e", "w"):
            node.props.append(("rotation", "1.570796"))
        if size != OPENER_SIZE["thorn_hedge"]:
            node.props.append(("size", vec2(*size)))
        node.base = "ThornHedge"
    else:
        node = Node("", "Props", "StaticBody2D")
        node.props = [("position", vec2(*ent.pos)), ("script", Res("Script", LOCKED_SCRIPT)), ("door_id", sname(ident))]
        scope = ent.opts.get("scope", src.scope)
        if scope != "ow":
            node.props.append(("scope", sname(scope)))
        if size != OPENER_SIZE["locked_door"]:
            node.props.append(("size", vec2(*size)))
        node.base = "LockedDoor"
    plan.singles.append((key, node))
    return True


def dispatch_hidden_stairs(ent: Entity, key: tuple, src: Source, plan: Plan, errors: list[str]) -> bool:
    """`hidden_stairs <target> <spawn> <pos> id=<id>` reveals a persistent RoomDoor after a glow-jar reveal."""
    where_ = where(src.path, ent.line)
    if len(ent.args) != 2 or ent.args[1] not in SPAWN_NAMES:
        errors.append(f"{where_}: hidden_stairs takes a target room and a spawn name ({', '.join(SPAWN_NAMES)})")
        return False
    ident = ent.opts.get("id", "")
    if not IDENT_RE.match(ident):
        errors.append(f"{where_}: hidden_stairs needs id=<snake_case id>")
        return False
    size = (192, 96)  # hidden_stairs.tscn's default size, which fills a 192 px wall gap
    tiles = tiles_of_rect(ent.pos[0] - size[0] / 2, ent.pos[1] - size[1] / 2, size[0], size[1])
    plan.openers.append((ent, tiles))
    plan.doors.append(ent)
    node = Node("", "Props", None, Res("PackedScene", HIDDEN_STAIRS_SCENE))
    node.props = [
        ("position", vec2(*ent.pos)),
        ("seam_id", sname(ident)),
        ("door_target", sname(ent.args[0])),
        ("door_spawn", sname(ent.args[1])),
    ]
    node.base = "HiddenStairs"
    plan.singles.append((key, node))
    return True


def dispatch_pickup(ent: Entity, key: tuple, src: Source, plan: Plan, world: World, errors: list[str]) -> bool:
    where_ = where(src.path, ent.line)
    if ent.verb != "pickup" or not ent.args:
        errors.append(f"{where_}: unknown entity '{ent.verb}'")
        return False
    if ent.args[0] == "item":
        if len(ent.args) != 2:
            errors.append(f"{where_}: 'pickup item' takes one tool id")
            return False
        kind, ident = "item", ent.args[1]
    else:
        if len(ent.args) != 1 or ent.args[0] not in PICKUP_SCENES:
            errors.append(f"{where_}: pickup kind must be item or one of {', '.join(sorted(PICKUP_SCENES))}")
            return False
        kind = ent.args[0]
        ident = ent.opts.get("id", "")
        if not IDENT_RE.match(ident):
            errors.append(f"{where_}: pickup {kind} needs id=<snake_case id>")
            return False
    scene = ITEM_PICKUP_SCENE if kind == "item" else PICKUP_SCENES[kind]
    node = Node("", "Props", None, Res("PackedScene", scene))
    persistent_id = persistent_pickup_id(src.room_id or "", ident)
    node.props = [("position", vec2(*ent.pos)), ("persistent_id", sname(persistent_id))]
    if kind == "item":
        node.props.append(("item_id", sname(ident)))
    if "scope" in ent.opts and kind not in ("small_key", "big_key", "fragment"):
        errors.append(f"{where_}: only small_key, big_key and fragment take scope=")
        return False
    if kind in ("small_key", "big_key", "fragment"):
        record = world.pickup_record(ident)
        expected_scope = (record or {}).get("scope") or src.scope
        scope = ent.opts.get("scope", expected_scope)
        if scope != expected_scope:
            errors.append(f"{where_}: pickup {ident} scope {scope}, the graph says {expected_scope}")
            return False
        if kind in ("big_key", "fragment") and not re.fullmatch(r"c(?:[1-9]|10)", scope):
            errors.append(f"{where_}: {kind} requires a graph cave scope")
            return False
        if kind == "fragment" and scope == "c10":
            errors.append(f"{where_}: fragment requires cave c1 .. c9")
            return False
        if scope != "ow":
            node.props.append(("scope", sname(scope)))
    if "requires" in ent.opts:
        node.props.append(("requires_flag", sname(ent.opts["requires"])))
    node.base = PICKUP_NODE_NAME.get(kind, camel(kind))
    plan.pickups.append((ent, ident, kind))
    plan.singles.append((key, node))
    return True


# ---- validation of one room ------------------------------------------------------------------


def ring_problems(src: Source, rec: dict, errors: list[str]) -> None:
    """The ring is the wall: '#' everywhere except the gap of every graph exit, which is '.'."""
    gap_owner = {tile: side for side in SIDES for tile in GAP_TILES[side]}
    for side in SIDES:
        for col, row in GAP_TILES[side]:
            ch = src.grid[row][col]
            line = src.grid_lines[row]
            if side in rec["exits"] and ch != FLOOR_CHAR:
                errors.append(f"{where(src.path, line)}: graph exit {side} needs a gap ('.') here, found '{ch}'")
            if side not in rec["exits"] and ch != "#":
                errors.append(f"{where(src.path, line)}: the graph has no exit {side}, this tile must be '#'")
    for row in range(ROWS):
        for col in range(COLS):
            ring = col in (0, COLS - 1) or row in (0, ROWS - 1)
            if ring and (col, row) not in gap_owner and src.grid[row][col] != "#":
                errors.append(f"{where(src.path, src.grid_lines[row])}: ring tile ({col},{row}) must be '#'")


def boots_reach(plan: Plan, starts: set[tuple[int, int]], closed: set[tuple[int, int]]) -> set[tuple[int, int]]:
    """All safe 192 px cardinal leaps, including alternate routes around a reel chasm."""
    blocked = plan.static | closed
    solid = (plan.static - plan.pits) | closed
    reached = set(starts)
    while True:
        landings = set()
        for x, y in reached:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                middle, end = (x + dx, y + dy), (x + 2 * dx, y + 2 * dy)
                if (middle in plan.pits and middle not in solid and end not in blocked and
                        0 <= end[0] < COLS and 0 <= end[1] < ROWS):
                    landings.add(end)
        expanded = reached | flood(landings, blocked)
        if expanded == reached:
            return reached
        reached = expanded


def reel_reach(plan: Plan, starts: set[tuple[int, int]], closed: set[tuple[int, int]]) -> set[tuple[int, int]]:
    """Conservative cardinal tile-centre pulls using T08's actual range and stop distance.

    Rings are targets, never removable blockers. A qualifying pit chasm is 288–480 px wide;
    WORLD bodies stop the tip, and the 72 px stop point must be dry, safe floor.
    """
    blocked = plan.static | closed
    solid = (plan.static - plan.pits - plan.water) | closed
    reached = set(starts)
    while True:
        landings = set()
        for start in reached:
            sx, sy = centre_of(*start)
            for anchor in plan.anchors:
                ax, ay = anchor.pos
                dx, dy = ax - sx, ay - sy
                distance = abs(dx) + abs(dy)
                limit = float(anchor.opts.get("max_range", "0")) or 576
                if (dx != 0 and dy != 0) or not 72 < distance <= min(576, limit):
                    continue
                ux, uy = dx / distance, dy / distance
                lx, ly = ax - ux * 72, ay - uy * 72
                landing = tile_of(lx, ly)
                if landing in blocked:
                    continue
                # Sample at one pixel to include off-centre authored targets and the stop point.
                ray = [tile_of(sx + ux * step, sy + uy * step) for step in range(int(distance) + 1)]
                if any(t in solid for t in ray):
                    continue
                spans = []
                unsafe = False
                for pit, (width, height) in plan.pit_rects:
                    px, py = pit.pos
                    # PitZone.holds grows the rectangle by Player.BODY_RADIUS (26 px).
                    if abs(lx - px) <= width / 2 + 26 and abs(ly - py) <= height / 2 + 26:
                        unsafe = True
                    if dx == 0 and abs(sx - px) < width / 2:
                        ends = ((py - height / 2 - sy) * uy, (py + height / 2 - sy) * uy)
                    elif dy == 0 and abs(sy - py) < height / 2:
                        ends = ((px - width / 2 - sx) * ux, (px + width / 2 - sx) * ux)
                    else:
                        continue
                    lo, hi = sorted(ends)
                    if hi > 0 and lo < distance:
                        spans.append((max(0, lo), min(distance, hi)))
                merged = []
                for lo, hi in sorted(spans):
                    if merged and lo <= merged[-1][1]:
                        merged[-1] = (merged[-1][0], max(hi, merged[-1][1]))
                    else:
                        merged.append((lo, hi))
                if unsafe or len(merged) != 1 or not 288 <= merged[0][1] - merged[0][0] <= 480:
                    continue
                landings.add(landing)
        expanded = reached | flood(landings, blocked)
        if expanded == reached:
            return reached
        reached = expanded


def check_room(src: Source, rec: dict, world: World, plan: Plan, errors: list[str]) -> None:
    grid_line = src.grid_lines[0]
    path = src.path
    spawn_tile = next((t for n, t, _ in plan.spawns if n == "Default"), tile_of(*ROOM_CENTRE_PX))
    if spawn_tile in plan.static:
        errors.append(f"{where(path, grid_line)}: the default spawn is inside an obstacle")
    for name, tile, _ in plan.spawns:
        if tile in plan.static:
            errors.append(f"{where(path, grid_line)}: spawn {name} is on an obstacle at {tile}")

    closed = set().union(*(t for _, t in plan.openers)) if plan.openers else set()
    reach = flood([spawn_tile], plan.static | closed)
    raft_sides = {}
    if plan.moorings or plan.water:
        for edge in world.edges:
            if edge["prop"] != "mooring and water" or rec["id"] not in (edge["a"], edge["b"]):
                continue
            other = edge["b"] if edge["a"] == rec["id"] else edge["a"]
            side = edge_side(world, rec["id"], other)
            raft_sides[side] = other
            if not any(m.opts["target_room"] == other for m in plan.moorings):
                errors.append(f"{where(path, grid_line)}: raft exit {side} needs a mooring to {other}")
            if any(tile in reach for tile in GAP_TILES.get(side, [])):
                errors.append(f"{where(path, grid_line)}: raft exit {side} is walkable on foot")
    for ent in plan.moorings:
        offset = ent.opts.get("landing_offset", "0,56").split(",")
        landing = tile_of(ent.pos[0] + float(offset[0]), ent.pos[1] + float(offset[1]))
        if landing in plan.static:
            errors.append(f"{where(path, ent.line)}: mooring landing is on an obstacle")
    pit_sides = set()
    for edge in world.edges:
        if edge.get("prop") not in ("ravine leap", "pit") or rec["id"] not in (edge["a"], edge["b"]):
            continue
        other = edge["b"] if edge["a"] == rec["id"] else edge["a"]
        side = edge_side(world, rec["id"], other)
        if side is None:
            continue
        pit_sides.add(side)
        if not plan.pits:
            errors.append(f"{where(path, grid_line)}: pit exit {side} needs a pit zone")
        if any(t in reach for t in GAP_TILES[side]):
            errors.append(f"{where(path, grid_line)}: pit exit {side} is walkable on foot")
        # At tile centres a 192 px leap must land safely beyond a pit, without crossing WORLD bodies.
        landings = []
        solid = plan.static - plan.pits | closed
        for start in reach:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                middle = (start[0]+dx, start[1]+dy)
                end = (start[0]+2*dx, start[1]+2*dy)
                if middle in plan.pits and middle not in solid and end not in plan.static | closed:
                    landings.append(end)
        after = flood(landings, plan.static | closed)
        if not any(t in after for t in GAP_TILES[side]):
            errors.append(f"{where(path, grid_line)}: pit exit {side} has no safe 192 px leap")
    reel_sides = set()
    for anchor in plan.anchors:
        if anchor.tile in plan.static | closed:
            errors.append(f"{where(path, anchor.line)}: anchor ring is on an obstacle")
    for edge in world.edges:
        if edge.get("prop") != "anchor ring" or rec["id"] not in (edge["a"], edge["b"]):
            continue
        if edge.get("gate") != "item" or edge.get("needs") != ["reel_line"] or edge.get("link") != "step":
            errors.append(f"{where(path, grid_line)}: anchor ring gate needs a reel_line item step edge")
            continue
        other = edge["b"] if edge["a"] == rec["id"] else edge["a"]
        side = edge_side(world, rec["id"], other)
        if side is None:
            errors.append(f"{where(path, grid_line)}: anchor ring gate has no adjacent exit")
            continue
        reel_sides.add(side)
        gap = GAP_TILES[side]
        if any(t in reach for t in gap):
            errors.append(f"{where(path, grid_line)}: reel exit {side} is walkable on foot")
        if any(t in boots_reach(plan, reach, closed) for t in gap):
            errors.append(f"{where(path, grid_line)}: reel exit {side} is crossable with 192 px boots")
        after = reel_reach(plan, reach, closed)
        if not any(t in after for t in gap):
            errors.append(f"{where(path, grid_line)}: reel exit {side} needs a clear 576 px anchor pull over a 288–480 px chasm with safe landing")
        if edge.get("dir") == "both":
            reverse = reel_reach(plan, flood(gap, plan.static | closed), closed)
            if spawn_tile not in reverse:
                errors.append(f"{where(path, grid_line)}: reel exit {side} needs a return anchor pull")
    open_sides = []
    for side in rec["exits"]:
        corridor = exit_corridor(side)
        if side in raft_sides or side in pit_sides or side in reel_sides:
            continue
        if any(tile in plan.static for tile in corridor):
            blocked = next(tile for tile in corridor if tile in plan.static)
            errors.append(f"{where(path, grid_line)}: exit {side} corridor blocked at tile {blocked}")
        if not any(tile in closed for tile in GAP_TILES[side]):
            open_sides.append(side)
            if any(tile not in reach for tile in corridor):
                errors.append(f"{where(path, grid_line)}: exit {side} is not reachable from the spawn")

    for index, (opener, _) in enumerate(plan.openers):
        if not opener.args or opener.args[0] not in (*SCRIPTED_OPENERS, "gate", "boss_door"):
            continue
        edge = next((e for e in world.edges if e["id"] == opener.opts.get("id")), None)
        if edge is None or edge["link"] != "step":
            continue
        other = edge["b"] if edge["a"] == rec["id"] else edge["a"]
        side = edge_side(world, rec["id"], other)
        if side is not None:
            if any(t in reach for t in GAP_TILES[side]):
                errors.append(f"{where(path, opener.line)}: gate {edge['id']} is walkable while closed")
            opened = closed_flood(plan, spawn_tile, index)
            if not any(t in opened for t in GAP_TILES[side]):
                errors.append(f"{where(path, opener.line)}: gate {edge['id']} stays blocked after opening")
    for control in plan.controls:
        accessible = reaches(reach, control.tile) if control.verb == "eye_switch" else control.tile in reach
        if not accessible:
            errors.append(f"{where(path, control.line)}: {control.verb} is unreachable with blockers closed")
    check_enemies(src, rec, plan, errors)
    check_pickups(src, rec, world, plan, spawn_tile, reach, open_sides, errors)
    check_shops(src, rec, world, plan, reach, errors)
    check_doors(src, rec, world, plan, errors)
    check_openers_and_ids(src, plan, errors)


def check_enemies(src: Source, rec: dict, plan: Plan, errors: list[str]) -> None:
    counts: dict[str, int] = {}
    for _, node, ent in plan.enemies:
        name = node.enemy
        role = ent.verb
        if role == "enemy":
            counts[name] = counts.get(name, 0) + 1
        elif rec.get("encounters", {}).get(role) != name:
            errors.append(f"{where(src.path, ent.line)}: {role} {name} does not match the graph encounter")
        habitat = any(abs(ent.pos[0] - z.pos[0]) <= size[0] / 2 and
                      abs(ent.pos[1] - z.pos[1]) <= size[1] / 2 for z, size in plan.zones)
        if name == "fen_leech" and plan.zones and not habitat:
            errors.append(f"{where(src.path, ent.line)}: fen_leech must start in water or shallows")
        if ent.tile in plan.static and not (name == "fen_leech" and habitat and ent.tile in plan.water):
            errors.append(f"{where(src.path, ent.line)}: enemy {name} starts on an obstacle")
        centred = ent.pos[0] % TILE == TILE / 2 and ent.pos[1] % TILE == TILE / 2
        if name == "hollow" and not centred:
            errors.append(f"{where(src.path, ent.line)}: hollow is not on a tile centre")
    for role, name in rec.get("encounters", {}).items():
        if sum(ent.verb == role and node.enemy == name for _, node, ent in plan.enemies) != 1:
            errors.append(f"{where(src.path, 1)}: graph {role} {name} must be placed exactly once")
    if counts != rec["enemies"]:
        errors.append(f"{where(src.path, 1)}: enemies {counts}, the graph says {rec['enemies']}")


def moth_fetchable(plan, target, reach) -> bool:
    """Conservative straight launches: actual 420 px range, ignoring only permanent grates."""
    blocked = (plan.static - plan.grates - plan.pits) | set().union(*(t for _, t in plan.openers))
    for tile in reach:
        start = centre_of(*tile)
        dx, dy = target[0]-start[0], target[1]-start[1]
        if (dx != 0 and dy != 0) or abs(dx)+abs(dy) > 420:
            continue
        distance = abs(dx)+abs(dy)
        if not distance:
            continue
        crossed = set()
        for step in range(int(distance)+1):
            crossed.add(tile_of(start[0]+dx*step/distance, start[1]+dy*step/distance))
        if crossed & plan.grates and not crossed & blocked:
            return True
    return False


def moth_pocket(rec, world) -> bool:
    return rec["pocket"] and any(e["prop"] == "grated alcove" and
        rec["id"] in (e["a"], e["b"]) and "tether_moth" in e.get("needs", []) for e in world.edges)


def check_pickups(src, rec, world, plan, spawn_tile, reach, open_sides, errors) -> None:
    path = src.path
    # Shop records are checked by check_shops: their stock is placed by `shop` lines, not `pickup` lines.
    graph = {
        p["id"]: p
        for p in world.pickups
        if p["node"] in world.placed_nodes(rec["id"]) and not p["shop"]
    }
    placed: dict[str, Entity] = {}
    for ent, ident, kind in plan.pickups:
        where_ = where(path, ent.line)
        if ident in placed:
            errors.append(f"{where_}: pickup id {ident} is placed twice")
        placed[ident] = ent
        if ident not in graph:
            errors.append(f"{where_}: pickup {ident} is not in the graph for this room")
            continue
        if graph[ident]["kind"] != kind:
            errors.append(f"{where_}: pickup {ident} is kind {kind}, the graph says {graph[ident]['kind']}")
        if graph[ident]["after_boss"] and ent.opts.get("requires") != f"boss_{graph[ident]['node']}_defeated":
            errors.append(f"{where_}: {ident} comes after a boss, give requires=boss_{graph[ident]['node']}_defeated")
    for ident, rec_pickup in graph.items():
        if ident not in placed:
            errors.append(f"{where(path, 1)}: graph pickup {ident} ({rec_pickup['kind']}) is not placed")

    for ent, ident, _ in plan.pickups:
        if ident not in graph:
            continue
        tile = ent.tile
        if moth_pocket(rec, world) or (graph[ident]["kind"] == "small_key" and
                                       "tether_moth" in graph[ident].get("needs", [])):
            # Every entry must remain outside the sealed key compartment.
            starts = [spawn_tile] + [t for _, t, _ in plan.spawns]
            starts += [t for side in rec["exits"] for t in GAP_TILES[side]]
            for start in starts:
                walk = flood([start], plan.static | set().union(*(t for _, t in plan.openers)))
                if reaches(walk, tile):
                    errors.append(f"{where(path, ent.line)}: moth pickup {ident} is walkable")
                if not moth_fetchable(plan, ent.pos, walk):
                    errors.append(f"{where(path, ent.line)}: moth pickup {ident} has no clear launch within 420 px across grate")
            continue
        if graph[ident]["node"] != rec["id"]:
            # Sealed: in an in-place pocket. Closed, unreachable; exactly one opener opens it.
            if reaches(closed_flood(plan, spawn_tile, None), tile):
                errors.append(f"{where(path, ent.line)}: sealed pickup {ident} is reachable while closed")
            openers = [i for i in range(len(plan.openers)) if reaches(closed_flood(plan, spawn_tile, i), tile)]
            if len(openers) != 1:
                errors.append(f"{where(path, ent.line)}: sealed pickup {ident} needs exactly one opener, found {len(openers)}")
            continue
        if not reaches(reach, tile):
            errors.append(f"{where(path, ent.line)}: pickup {ident} is not reachable from the spawn")
        for side in open_sides:
            starts = [t for t in GAP_TILES[side] if t not in plan.static]
            if not reaches(flood(starts, plan.static | set().union(*(t for _, t in plan.openers))), tile):
                errors.append(f"{where(path, ent.line)}: pickup {ident} is not reachable from exit {side}")


def check_shops(
    src: Source, rec: dict, world: World, plan: Plan, reach: set[tuple[int, int]], errors: list[str]
) -> None:
    """A shop room has the graph's shop record and one `shop` line per stock item; each line is priced in
    data/shop_prices.json, reachable and off the obstacles. The graph's slug bundles of the shop are its stock."""
    path = src.path
    graph_shops = [p for p in world.pickups if p["kind"] == "shop" and p["node"] == rec["id"]]
    stock = {p["id"]: p for p in world.pickups if p["node"] == rec["id"] and p["shop"] and p["kind"] != "shop"}
    if plan.shops and not graph_shops:
        errors.append(f"{where(path, plan.shops[0][0].line)}: {rec['id']} is not a shop of the graph")
    for ent, shop_id, kind, ident in plan.shops:
        where_ = where(path, ent.line)
        if graph_shops and shop_id != graph_shops[0]["shop"]:
            errors.append(f"{where_}: {rec['id']} is shop {graph_shops[0]['shop']} in the graph, not {shop_id}")
        if world.price(shop_id, kind) is None:
            errors.append(f"{where_}: no price for {kind} in shop {shop_id} (data/shop_prices.json)")
        if kind in SHOP_ONE_TIME and not ident:
            errors.append(f"{where_}: {kind} is one-time stock and needs id=<stock id>")
        if not reaches(reach, ent.tile):
            errors.append(f"{where_}: shop stock {kind} is not reachable from the spawn")
    if graph_shops and not plan.shops:
        errors.append(f"{where(path, 1)}: shop {graph_shops[0]['shop']} has no stock line")
    placed = {ident: kind for _, _, kind, ident in plan.shops if ident}
    for ident, record in stock.items():
        if ident not in placed:
            errors.append(f"{where(path, 1)}: graph stock {ident} ({record['kind']}) is not placed")
        elif placed[ident] != record["kind"]:
            errors.append(f"{where(path, 1)}: stock {ident} is {placed[ident]}, the graph says {record['kind']}")


def closed_flood(plan: Plan, spawn_tile: tuple[int, int], opened: int | None) -> set[tuple[int, int]]:
    """Flood from the spawn with every opener closed, except the opener with index `opened`."""
    blocked = set(plan.static)
    for index, (_, tiles) in enumerate(plan.openers):
        if index != opened:
            blocked |= tiles
    return flood([spawn_tile], blocked)


def check_doors(src: Source, rec: dict, world: World, plan: Plan, errors: list[str]) -> None:
    path = src.path
    partners: dict[str, str] = {}
    for edge in world.door_edges(rec["id"]):
        other = edge["b"] if edge["a"] == rec["id"] else edge["a"]
        partners[other] = edge["gate"] or "plain"
    placed = {ent.args[0]: ent for ent in plan.doors if len(ent.args) == 2}
    for ent in plan.doors:
        where_ = where(path, ent.line)
        if ent.tile in plan.static:
            errors.append(f"{where_}: door to {ent.args[0]} stands on an obstacle")
        if ent.args[0] not in partners:
            errors.append(f"{where_}: door to {ent.args[0]} is not a door of the graph for {rec['id']}")
        if ent.verb == "door":
            link_door_blocker(src, rec, world, plan, ent, errors)
    for other, gate in partners.items():
        in_place = world.rooms.get(other, {}).get("in_place", False)
        if gate == "plain" and not in_place and other not in placed:
            errors.append(f"{where(path, 1)}: plain door to {other} is not placed")


def link_door_blocker(src, rec, world, plan, door, errors) -> None:
    """Bind an authored gate mouth to its actual opener, even with an offset trigger.

    Pocket return doors and the permanent-grate pocket entrance are freely entered. No item-owned
    capability or invented flag is used as a substitute for a physical opener's state.
    """
    edge = next((e for e in world.door_edges(rec["id"])
                 if door.args[0] in (e["a"], e["b"])), None)
    requested = door.opts.get("blocker")
    if edge is None:
        return  # check_doors already reports the invalid graph destination.
    kinds = {"thorn-sealed door": "thorn_door", "thorn wall": "thorn_door",
             "cracked wall": "cracked_wall", "bomb wall": "cracked_wall",
             "brittle rocks": "cracked_wall", "locked door": "locked_door",
             "bush cluster": "cut_screen", "reed cluster": "cut_screen",
             "rush wall": "cut_screen", "ward plate": "ward_blocker",
             "eye-switch cell": "eye_portcullis", "eye-switch portcullis": "eye_portcullis",
             "heavy stones": "heavy_stone", "heavy boulder": "heavy_boulder",
             "hook-tap wall": "hook_tap_wall", "wax seal": "wax_seal",
             "key alcove gate": "gate",
             "two braziers, gate": "gate", "boss door": "boss_door"}
    kind = kinds.get(edge.get("prop"))
    if not edge.get("gate") or rec["pocket"] or edge.get("prop") == "grated alcove":
        if requested:
            errors.append(f"{where(src.path, door.line)}: this freely entered door takes no blocker")
        return
    candidates = [ent for ent, _ in plan.openers if ent.verb == "opener" and ent.args == [kind]]
    if requested:
        candidates = [ent for ent in candidates if ent.opts.get("id") == requested]
    else:
        matching_id = [ent for ent in candidates if ent.opts.get("id") == edge["id"]]
        colocated = [ent for ent in candidates if ent.pos == door.pos]
        candidates = matching_id or colocated or candidates
    if len(candidates) != 1:
        errors.append(f"{where(src.path, door.line)}: gate door needs exactly one {kind or 'supported'} blocker; use blocker=<opener id> to disambiguate")
        return
    plan.door_links.append((plan.entity_nodes[door], plan.entity_nodes[candidates[0]]))


def check_openers_and_ids(src: Source, plan: Plan, errors: list[str]) -> None:
    seen: set[str] = set()
    for ident, entries in plan.braziers.items():
        seen.add(ident)
        if len(entries) != 1:
            errors.append(f"{where(src.path, entries[0][0].line)}: duplicate brazier id {ident}")
    for ent, _ in plan.openers:
        if ent.args != ["gate"]:
            continue
        ids = ent.opts["braziers"].split(",")
        if any(len(plan.braziers.get(i, [])) != 1 for i in ids):
            errors.append(f"{where(src.path, ent.line)}: gate references missing or duplicate brazier")
        else:
            plan.gate_links.append((plan.entity_nodes[ent], [plan.braziers[i][0][1] for i in ids]))
    for control in plan.controls:
        ident = control.opts["id"]
        matches = [e for e, _ in plan.openers if e.args[0] == LINKED[control.verb] and e.opts.get("id") == ident]
        if len(matches) != 1:
            errors.append(f"{where(src.path, control.line)}: {control.verb} needs exactly one linked {LINKED[control.verb]}")
        if sum(c.opts["id"] == ident for c in plan.controls) != 1:
            errors.append(f"{where(src.path, control.line)}: duplicate control id {ident}")
    for ent, tiles in plan.openers:
        ident = ent.opts.get("id", "")
        if ent.args and ent.args[0] in LINKED.values():
            if not any(LINKED[c.verb] == ent.args[0] and c.opts["id"] == ident for c in plan.controls):
                errors.append(f"{where(src.path, ent.line)}: blocker {ident} has no linked control")
        if ident:
            if ident in seen:
                errors.append(f"{where(src.path, ent.line)}: id {ident} is used twice in this room")
            seen.add(ident)
        if any(t in plan.static for t in tiles):
            label = ident or ent.args[0]
            errors.append(f"{where(src.path, ent.line)}: opener {label} stands on an obstacle")
    for ent, ident, _ in plan.pickups:
        if ident in seen:
            errors.append(f"{where(src.path, ent.line)}: id {ident} is used by a pickup and an opener")
        seen.add(ident)
    for ent, _, _, ident in plan.shops:
        if not ident:
            continue
        if ident in seen:
            errors.append(f"{where(src.path, ent.line)}: id {ident} is used twice in this room")
        seen.add(ident)


# ---- output ----------------------------------------------------------------------------------


def num(value: float) -> str:
    if float(value).is_integer():
        return str(int(value))
    return ("%.6f" % value).rstrip("0").rstrip(".")


def vec2(x: float, y: float) -> str:
    return f"Vector2({num(x)}, {num(y)})"


def sname(text: str) -> str:
    return f'&"{text}"'


def camel(text: str) -> str:
    return "".join(part.capitalize() for part in text.split("_"))


class Ext:
    """ext_resource ids in order of first use, as Godot writes them."""

    def __init__(self) -> None:
        self.items: list[tuple[str, str]] = []
        self.index: dict[tuple[str, str], str] = {}

    def ref(self, res: Res) -> str:
        key = (res.kind, res.path)
        if key not in self.index:
            self.items.append(key)
            self.index[key] = str(len(self.items))
        return f'ExtResource("{self.index[key]}")'


def name_all(plan: Plan, enemies_sorted: list[Node]) -> dict[str, list[Node]]:
    """Gives every node its name and returns the children of each container in output order."""
    counters: dict[str, int] = {}

    def numbered(base: str) -> str:
        counters[base] = counters.get(base, 0) + 1
        return f"{base}{counters[base]}"

    children: dict[str, list[Node]] = {"Enemies": [], "Bushes": [], "Props": [], "Spawns": []}
    for node in plan.merged:
        node.name = numbered(node.base)
    children["Props"].extend(plan.merged)
    for _, node in plan.singles:
        node.name = numbered(node.base)
        children[node.parent].append(node)
    counters.clear()
    for node in enemies_sorted:
        node.name = numbered(node.base)
        children["Enemies"].append(node)
    for name, _, node in plan.spawns:
        node.name = name
        children["Spawns"].append(node)
    return children


def emit(src: Source, rec: dict, plan: Plan) -> str:
    ext = Ext()
    exits = ", ".join(sname(s) for s in rec["exits"])
    root = Node(root_name(rec["id"]), "", "Node2D")
    root.props = [
        ("script", Res("Script", ROOM_SCRIPT)),
        ("room_id", sname(rec["id"])),
        ("grid", f"Vector2i({rec['grid'][0]}, {rec['grid'][1]})"),
        ("exits", f"Array[StringName]([{exits}])"),
    ]
    if plan.drop_exits:
        drops = ", ".join(sname(side) for side in sorted(plan.drop_exits))
        root.props.append(("drop_exits", f"Array[StringName]([{drops}])"))
    if rec["dark"]:
        root.props.append(("dark", "true"))
    if src.floor is not None:
        r, g, b = src.floor
        root.props.append(("floor_color", f"Color({num(r)}, {num(g)}, {num(b)}, 1)"))
    enemies = [node for _, node, _ in sorted(plan.enemies, key=lambda pair: pair[0])]
    children = name_all(plan, enemies)
    for gate, braziers in plan.gate_links:
        paths = ", ".join(f'NodePath("../{b.name}")' for b in braziers)
        gate.props.append(("braziers", f"Array[NodePath]([{paths}])"))
    for door, blocker in plan.door_links:
        door.props = [(key, value) for key, value in door.props if key != "blocker_path"]
        door.props.append(("blocker_path", f'NodePath("../{blocker.name}")'))
    containers = [Node(name, ".", "Node2D") for name in ("Enemies", "Bushes", "Props", "Spawns")]
    for container in containers:
        container.props = [("y_sort_enabled", "true")]

    groups = [[node_header(root, ext, root=True)] + prop_lines(root, ext)]
    for container in containers:
        groups.append([node_header(container, ext)] + prop_lines(container, ext))
        for child in children[container.name]:
            groups.append([node_header(child, ext)] + prop_lines(child, ext))
    source = f"tools/rooms/{rec['id'].replace('#', '__')}.room"
    head = [f"[gd_scene load_steps={len(ext.items) + 1} format=3]", f"; Generated by tools/build_rooms.py from {source}."]
    head.append("; Do not edit by hand: change the .room file and run make rooms.")
    if src.terrain:
        head.append(f"; terrain: {src.terrain}")
    ext_lines = [f'[ext_resource type="{kind}" path="{path}" id="{ext.index[(kind, path)]}"]' for kind, path in ext.items]
    parts = ["\n".join(head)]
    if ext_lines:
        parts.append("\n".join(ext_lines))
    parts += ["\n".join(group) for group in groups]
    return "\n\n".join(parts) + "\n"


def root_name(room_id: str) -> str:
    return "".join(part.capitalize() for part in re.split(r"[_#]", room_id))


def node_header(node: Node, ext: Ext, root: bool = False) -> str:
    if root:
        return f'[node name="{node.name}" type="{node.typ}"]'
    if node.scene is not None:
        return f'[node name="{node.name}" parent="{node.parent}" instance={ext.ref(node.scene)}]'
    return f'[node name="{node.name}" type="{node.typ}" parent="{node.parent}"]'


def prop_lines(node: Node, ext: Ext) -> list[str]:
    return [f"{key} = {ext.ref(value) if isinstance(value, Res) else value}" for key, value in node.props]


# ---- driver ----------------------------------------------------------------------------------


def room_id_of_file(path: Path) -> str:
    return path.stem.replace("__", "#", 1)


def compile_room(path: Path, world: World) -> tuple[str | None, list[str]]:
    """Validates one .room file and returns its scene text, or None with the errors."""
    errors: list[str] = []
    src = parse_source(path, errors)
    if src is None:
        return None, errors
    expected = room_id_of_file(path)
    if src.room_id != expected:
        errors.append(f"{where(path, src.room_line)}: room is {src.room_id}, the file is {expected}")
        return None, errors
    rec = world.room(expected)
    if rec is None:
        errors.append(f"{where(path, src.room_line)}: {expected} is not in the world graph")
        return None, errors
    if rec["in_place"]:
        errors.append(f"{where(path, src.room_line)}: {expected} opens in place; put it in its host room's file")
        return None, errors
    src.scope = rec["scope"]
    ring_problems(src, rec, errors)
    plan = build_plan(src, world, errors)
    if plan is None or errors:
        return None, errors
    check_room(src, rec, world, plan, errors)
    for res_path in missing_resources(plan):
        errors.append(f"{where(path, src.room_line)}: {res_path} does not exist (the part is not built yet)")
    if errors:
        return None, errors
    return emit(src, rec, plan), []


def missing_resources(plan: Plan) -> list[str]:
    """Scenes and scripts the room refers to that are not in the repository yet."""
    nodes = plan.merged + [n for _, n in plan.singles] + [n for _, n, _ in plan.enemies] + [n for _, _, n in plan.spawns]
    paths: set[str] = set()
    for node in nodes:
        if node.scene is not None:
            paths.add(node.scene.path)
        paths.update(v.path for _, v in node.props if isinstance(v, Res))
    return sorted(p for p in paths if not (ROOT / p[len("res://") :]).is_file())


def selected_files(names: list[str], rooms_dir: Path) -> tuple[list[Path], list[str]]:
    if not names:
        return sorted(rooms_dir.glob("*.room")), []
    files, errors = [], []
    for name in names:
        candidate = rooms_dir / (name.replace("#", "__") + ".room")
        if candidate.exists():
            files.append(candidate)
        else:
            errors.append(f"no source for {name}: {candidate} does not exist")
    return files, errors


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Compile tools/rooms/*.room into scenes/world/rooms.")
    parser.add_argument("rooms", nargs="*", help="room ids, pocket ids or file stems (default: all)")
    parser.add_argument("--check", action="store_true", help="validate and compare with the committed scenes")
    parser.add_argument("--rooms-dir", type=Path, default=ROOMS_DIR)
    parser.add_argument("--out-dir", type=Path, default=OUT_DIR)
    parser.add_argument("--world", type=Path, default=WORLD_FILE)
    parser.add_argument("--prices", type=Path, default=SHOP_PRICES_FILE)
    args = parser.parse_args(argv)
    try:
        world = World(
            json.loads(args.world.read_text(encoding="utf-8")),
            json.loads(args.prices.read_text(encoding="utf-8")),
            json.loads(GRAPH_FILE.read_text(encoding="utf-8")),
        )
    except (OSError, ValueError, KeyError) as exc:
        print(f"build_rooms: cannot read the world data: {exc} (run make world-data)", file=sys.stderr)
        return 2
    files, errors = selected_files(args.rooms, args.rooms_dir)
    failed = bool(errors)
    for message in errors:
        print(message, file=sys.stderr)
    done = 0
    for path in files:
        text, problems = compile_room(path, world)
        if text is None:
            failed = True
            for message in problems:
                print(message, file=sys.stderr)
            continue
        out = args.out_dir / (room_id_of_file(path).replace("#", "__") + ".tscn")
        if args.check:
            if not out.exists() or out.read_text(encoding="utf-8") != text:
                failed = True
                print(f"{where(out, 1)}: scene is missing or stale for {path.name}; run make rooms", file=sys.stderr)
                continue
        else:
            out.parent.mkdir(parents=True, exist_ok=True)
            out.write_text(text, encoding="utf-8")
        done += 1
    print(f"build_rooms: {'checked' if args.check else 'built'} {done} of {len(files)} room file(s)")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
