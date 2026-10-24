#!/usr/bin/env python3
"""Checks docs/world-graph.json: structure, gate vocabulary, reachability and soft-locks.

Usage:
    python3 tools/check_world_graph.py [path/to/world-graph.json] [--stats] [--rounds] [--orders] [--no-selftest]

Exit code 0 = every check passed and every self-test mutation was rejected, 1 = otherwise.
Stdlib only. The file format and the rules are described in docs/world-plan.md section 5.
The self-test (world-plan 5.7) applies a list of mutations to copies of the graph in memory and
requires each one to fail a check; --no-selftest skips it.

Model:
  * Nodes are rooms and pockets (secret closets, shops, key alcoves). Edges are room links.
  * An edge can be passed when every capability in `needs` is held and, for a key edge, once it
    has been opened with a small key of its scope. `dir` "a>b" makes it one-way.
  * A collectible (item, key, wick core, ...) is picked up when its node is reached and its own
    `needs` are held. After a boss (`after_boss`) the boss weakness tools are needed as well.
  * Capabilities only grow. Small keys are the one consumable, so they are checked per scope by
    exploring every order in which that scope's doors can be opened.
  * Sling ammo (R6b, capability-free): every gate or boss that needs `tallow_sling` has a
    `slug_bundle` pickup in its region or cave that the player can reach without crossing it.
"""
import copy
import json
import sys
from collections import Counter, defaultdict

GATE_TYPES = {"item", "key", "bomb", "cut", "brazier", "boss", "oneway", "hidden"}
FIXED_NEEDS = {"bomb": {"pitch_pot"}, "cut": {"hook"}, "brazier": {"hook"}}
DIRS = {(0, -1): "n", (1, 0): "e", (0, 1): "s", (-1, 0): "w"}
SLING = "tallow_sling"


class Graph:
    def __init__(self, data):
        self.d = data
        self.start = data["start"]
        self.goal = data["goal"]
        self.base = set(data["base_capabilities"])
        self.caps = data["capabilities"]
        self.nodes = {n["id"]: n for n in data["nodes"]}
        self.edges = data["edges"]
        self.adj = defaultdict(list)
        for e in self.edges:
            self.adj[e["a"]].append((e, e["b"]))
            if e.get("dir", "both") == "both":
                self.adj[e["b"]].append((e, e["a"]))
        self.coll = []
        for cap, it in data["items"].items():
            self.coll.append({"id": cap, "cap": cap, "node": it["node"], "needs": set(it.get("needs", [])),
                              "after_boss": it.get("after_boss", False)})
        for p in data["pickups"]:
            self.coll.append({"id": p["id"], "kind": p["kind"], "node": p["node"], "scope": p.get("scope"),
                              "needs": set(p.get("needs", [])), "after_boss": p.get("after_boss", False),
                              "early": p.get("early", False)})
        self.by_node = defaultdict(list)
        for c in self.coll:
            self.by_node[c["node"]].append(c)
        self.key_edges = [e for e in self.edges if e.get("key")]
        self.scope_of_edge = {e["id"]: e["key"] for e in self.key_edges}
        self.scopes = sorted({e["key"] for e in self.key_edges})

    def cave_of(self, node_id):
        world = self.nodes[node_id].get("world", "")
        return int(world.split("_")[1]) if world.startswith("cave_") else None

    def scope_nodes(self, scope):
        """Nodes a key scope belongs to: the overworld for 'ow', the cave for 'cN'."""
        if scope == "ow":
            return {n for n, v in self.nodes.items() if v.get("world") == "overworld"}
        return {n for n, v in self.nodes.items() if v.get("world") == "cave_" + scope[1:]}

    def can_pass(self, e, caps, opened):
        if not set(e.get("needs", [])) <= caps:
            return False
        return not e.get("key") or e["id"] in opened

    def closure(self, opened=frozenset(), seed=(), start=None, skip=None, grow=True):
        """Everything reachable. Returns (reached, caps, keys_found).

        grow=False freezes the capability set: pickups are still counted in the result, but
        they do not unlock anything inside this call (used for the unlock rounds).
        `skip(collectible)` leaves a collectible on the floor.
        """
        held = set(self.base) | set(seed)
        found = set(held)
        keys = Counter()
        reached = {start or self.start}
        taken = set()
        changed = True
        while changed:
            changed = False
            stack = list(reached)
            while stack:
                n = stack.pop()
                for e, other in self.adj[n]:
                    if other not in reached and self.can_pass(e, held, opened):
                        reached.add(other)
                        stack.append(other)
                        changed = True
            for n in list(reached):
                boss_needs = set(self.nodes[n].get("boss", {}).get("needs", []))
                for c in self.by_node.get(n, []):
                    if c["id"] in taken or (skip and skip(c)):
                        continue
                    need = c["needs"] | (boss_needs if c["after_boss"] else set())
                    if not need <= held:
                        continue
                    taken.add(c["id"])
                    if "cap" in c:
                        found.add(c["cap"])
                        if grow:
                            held.add(c["cap"])
                            changed = True
                    elif c["kind"] == "small_key":
                        keys[c["scope"]] += 1
        return reached, found, keys

    def spend_options(self, reached, held, keys, opened):
        """Key doors that can be opened right now."""
        out = []
        for e in self.key_edges:
            if e["id"] in opened or not (e["a"] in reached or e["b"] in reached):
                continue
            if not set(e.get("needs", [])) <= held:
                continue
            spent = sum(1 for x in opened if self.scope_of_edge[x] == e["key"])
            if keys[e["key"]] - spent > 0:
                out.append(e["id"])
        return out

    def solve(self, skip=None, seed=(), grow=True):
        """Greedy full solve: open key doors as keys allow. Returns (reached, caps, opened)."""
        opened = set()
        while True:
            reached, caps, keys = self.closure(frozenset(opened), seed=seed, skip=skip, grow=grow)
            options = self.spend_options(reached, caps if grow else set(self.base) | set(seed), keys, opened)
            if not options:
                return reached, caps, opened
            opened.add(options[0])


# ---------------------------------------------------------------------------- checks


def check_structure(g, errors):
    d = g.d
    ids = [n["id"] for n in d["nodes"]]
    if len(ids) != len(set(ids)):
        errors.append("duplicate node ids")
    if g.start not in g.nodes:
        errors.append("start is not a node")
    if g.goal not in g.nodes or "boss" not in g.nodes.get(g.goal, {}):
        errors.append("goal must be a node with a boss")
    eids = [e["id"] for e in g.edges]
    if len(eids) != len(set(eids)):
        errors.append("duplicate edge ids")
    known = set(g.caps)
    for e in g.edges:
        for end in (e["a"], e["b"]):
            if end not in g.nodes:
                errors.append("edge %s: unknown node %s" % (e["id"], end))
        gate = e.get("gate")
        if gate is not None and gate not in GATE_TYPES:
            errors.append("edge %s: unknown gate type %s" % (e["id"], gate))
        for cap in e.get("needs", []):
            if cap not in known:
                errors.append("edge %s: unknown capability %s" % (e["id"], cap))
        # rule: every gate names the capability that opens it
        if gate in ("item", "bomb", "cut", "brazier", "boss", "hidden") and not e.get("needs"):
            errors.append("edge %s: %s gate names no capability" % (e["id"], gate))
        if gate in FIXED_NEEDS and not set(e.get("needs", [])) >= FIXED_NEEDS[gate]:
            errors.append("edge %s: a %s gate must need %s" % (e["id"], gate, sorted(FIXED_NEEDS[gate])))
        if gate == "key" and not e.get("key"):
            errors.append("edge %s: key gate without a key scope" % e["id"])
        if e.get("key") and gate != "key":
            errors.append("edge %s: key scope on a gate that is not a key gate" % e["id"])
        if gate == "oneway" and e.get("dir") != "a>b":
            errors.append("edge %s: oneway gate needs dir a>b" % e["id"])
        if e.get("dir") == "a>b" and gate != "oneway":
            errors.append("edge %s: dir a>b only on oneway gates" % e["id"])
        if e.get("link") == "step" and e["a"] in g.nodes and e["b"] in g.nodes:
            na, nb = g.nodes[e["a"]], g.nodes[e["b"]]
            delta = (nb["grid"][0] - na["grid"][0], nb["grid"][1] - na["grid"][1])
            if delta not in DIRS:
                errors.append("edge %s: step link between non-adjacent cells %s %s" % (e["id"], e["a"], e["b"]))
    cells = Counter(tuple(n["grid"]) for n in d["nodes"] if n["kind"] == "room")
    for cell, count in cells.items():
        if count > 1:
            errors.append("two rooms share grid cell %s" % (cell,))
    for c in g.coll:
        if c["node"] not in g.nodes:
            errors.append("collectible %s at unknown node %s" % (c["id"], c["node"]))
        for cap in c["needs"]:
            if cap not in known:
                errors.append("collectible %s needs unknown capability %s" % (c["id"], cap))
    for cap in known - g.base:
        if cap not in d["items"]:
            errors.append("capability %s has no item" % cap)
    for cap in d["items"]:
        if cap not in known:
            errors.append("item %s is not a declared capability" % cap)
    for n in d["nodes"]:
        if "dark" in n and (n["kind"] != "room" or not isinstance(n["dark"], bool)):
            errors.append("node %s: dark must be true or false, and only rooms have it" % n["id"])
        for cap in n.get("boss", {}).get("needs", []):
            if cap not in known:
                errors.append("boss at %s needs unknown capability %s" % (n["id"], cap))
        real = {e["id"] for e in g.edges if e.get("gate") and n["id"] in (e["a"], e["b"])}
        if set(n.get("gates", [])) != real:
            errors.append("node %s: gates list does not match its edges" % n["id"])
        if n["kind"] == "room":
            exits = set()
            for e in g.edges:
                if e.get("link") == "step" and n["id"] in (e["a"], e["b"]):
                    if e.get("gate") == "oneway" and e["b"] == n["id"]:
                        continue  # the lower side of a ledge drop has no gap
                    other = g.nodes[e["b"] if e["a"] == n["id"] else e["a"]]
                    exits.add(DIRS[(other["grid"][0] - n["grid"][0], other["grid"][1] - n["grid"][1])])
            if exits != set(n.get("exits", [])):
                errors.append("room %s: exits %s do not match its step links" % (n["id"], sorted(n.get("exits", []))))


def check_coverage(g, errors, notes):
    reached, caps, opened = g.solve()
    missing = [n for n in g.nodes if n not in reached]
    if missing:
        errors.append("unreachable nodes (%d): %s" % (len(missing), ", ".join(missing[:10])))
    lost = sorted(set(g.caps) - caps)
    if lost:
        errors.append("capabilities never found: %s" % lost)
    left = []
    for c in g.coll:
        node = c["node"]
        if node not in reached:
            left.append(c["id"])
            continue
        need = c["needs"] | (set(g.nodes[node].get("boss", {}).get("needs", [])) if c["after_boss"] else set())
        if not need <= caps:
            left.append(c["id"])
    if left:
        errors.append("collectibles that can never be collected: %s" % left[:10])
    if g.goal in reached:
        need = set(g.nodes[g.goal]["boss"].get("needs", []))
        if not need <= caps:
            errors.append("final boss weakness never held: %s" % sorted(need - caps))
    else:
        errors.append("goal %s is not reachable" % g.goal)
    cores = [c for c in g.coll if c.get("kind") == "wick_core"]
    notes.append("wick cores %d: hearts %d -> %d (cap %d)" % (
        len(cores), g.d["start_hearts"], g.d["start_hearts"] + len(cores), g.d["max_hearts"]))
    if g.d["start_hearts"] + len(cores) > g.d["max_hearts"]:
        errors.append("more wick cores than the heart cap allows")
    keys = Counter(c["scope"] for c in g.coll if c.get("kind") == "small_key")
    for s in g.scopes:
        doors = sum(1 for e in g.key_edges if e["key"] == s)
        if keys[s] != doors:
            errors.append("key scope %s: %d keys for %d doors" % (s, keys[s], doors))
    return reached, caps


def essential_caps(g, node):
    """Capabilities that every way to `node` needs (it is unreachable if they are never found)."""
    out = set()
    for cap in g.caps:
        if cap in g.base:
            continue
        reached, _, _ = g.solve(skip=lambda c, cap=cap: c.get("cap") == cap)
        if node not in reached:
            out.add(cap)
    return out


def check_oneway(g, errors):
    """After a one-way edge, the way back must exist with what the player must hold anyway."""
    every_door = frozenset(e["id"] for e in g.key_edges)
    for e in g.edges:
        if e.get("dir") != "a>b":
            continue
        held = essential_caps(g, e["a"])
        reached, _, _ = g.closure(every_door, seed=held, start=e["b"])
        if e["a"] not in reached:
            errors.append("one-way edge %s (%s -> %s): no way back with %s" % (e["id"], e["a"], e["b"], sorted(held)))


def check_return(g, errors, reached):
    """In the finished state every node can walk back to the start (no trap rooms)."""
    caps = set(g.caps)
    every_door = {e["id"] for e in g.key_edges}
    back = {g.start}
    changed = True
    while changed:
        changed = False
        for e in g.edges:
            if not g.can_pass(e, caps, every_door):
                continue
            pairs = [(e["a"], e["b"])] if e.get("dir") == "a>b" else [(e["a"], e["b"]), (e["b"], e["a"])]
            for a, b in pairs:
                if b in back and a not in back:
                    back.add(a)
                    changed = True
    trapped = sorted(n for n in reached if n not in back)
    if trapped:
        errors.append("nodes with no way back to the start: %s" % trapped[:10])


def check_keys(g, errors, notes):
    """Per scope, from every state reachable by spending keys, the scope can still be finished.

    Capabilities found outside the scope are assumed held (best case for finishing, and every
    spending order stays possible); the scope's own capabilities have to be earned.
    """
    for s in g.scopes:
        mine = g.scope_nodes(s)
        outside = frozenset(cap for cap, it in g.d["items"].items() if it["node"] not in mine)
        others = frozenset(e["id"] for e in g.key_edges if e["key"] != s)
        memo = {}

        def explore(opened):
            if opened in memo:
                return memo[opened]
            memo[opened] = False
            reached, caps, keys = g.closure(others | opened, seed=outside)
            ok = all(n in reached for n in mine)
            for o in g.spend_options(reached, caps, keys, others | opened):
                if g.scope_of_edge[o] == s and explore(opened | {o}):
                    ok = True
            memo[opened] = ok
            return ok

        ok = explore(frozenset())
        dead = [sorted(o) for o, v in memo.items() if not v]
        notes.append("key scope %-3s doors %d, states explored %d, dead states %d" % (
            s, sum(1 for e in g.key_edges if e["key"] == s), len(memo), len(dead)))
        if not ok or dead:
            errors.append("key scope %s can soft-lock; dead states: %s" % (s, dead[:3]))


def reach_without(g, caps, opened, skip_edges, skip_nodes):
    """Nodes reachable from the start while holding `caps`, never crossing a skipped edge or entering a skipped node."""
    seen = {g.start}
    stack = [g.start]
    while stack:
        n = stack.pop()
        for e, other in g.adj[n]:
            if e["id"] in skip_edges or other in skip_nodes or other in seen:
                continue
            if g.can_pass(e, caps, opened):
                seen.add(other)
                stack.append(other)
    return seen


def sling_gates(g):
    """Every gate that needs the tallow sling: (label, regions the gate lies in, edges to skip, nodes to skip)."""
    out = []
    for e in g.edges:
        if SLING in e.get("needs", []):
            homes = {g.nodes[e["a"]].get("region"), g.nodes[e["b"]].get("region")}
            out.append((e["id"], homes, {e["id"]}, set()))
    for n in g.d["nodes"]:
        if SLING in n.get("boss", {}).get("needs", []):
            out.append((n["id"] + " (boss)", {n.get("region")}, set(), {n["id"]}))
    return out


def check_slugs(g, errors, notes):
    """R6b (capability-free): every sling gate has a slug source it can reach without that gate.

    A slug source is a pickup of kind `slug_bundle` in a region or cave the gate lies in, reachable
    from the start without crossing the gate (or without entering the boss room). Ammo is not
    modelled, so this only proves that the player can refill before the gate.
    """
    _, caps, opened = g.solve()
    sources = [c for c in g.coll if c.get("kind") == "slug_bundle"]
    gates = sling_gates(g)
    for label, homes, skip_edges, skip_nodes in gates:
        free = reach_without(g, caps, opened, skip_edges, skip_nodes)
        found = [c["id"] for c in sources
                 if g.nodes[c["node"]].get("region") in homes and c["node"] in free and c["needs"] <= caps]
        if not found:
            errors.append("R6b: sling gate %s has no slug source in %s reachable without it" % (label, sorted(homes)))
    notes.append("slug sources %d for %d sling gates" % (len(sources), len(gates)))


def unlock_rounds(g):
    """Round r = the capabilities that can be found while holding only those of earlier rounds."""
    held, rounds = set(g.base), []
    while True:
        _, caps, _ = g.solve(seed=held, grow=False)
        new = sorted(c for c in caps if c not in held)
        if not new:
            return rounds, held
        rounds.append(new)
        held |= set(new)


def cave_orders(g):
    """Counts the orders in which caves 1..N-1 can be finished (the last cave comes last).

    A cave's contents (except pickups flagged `early`) only count once the cave is finished.
    """
    last = max(c for c in (g.cave_of(n) for n in g.nodes) if c)
    caves = list(range(1, last))
    frag_node = {i: g.d["items"]["frag:c%d" % i]["node"] for i in caves}

    def finishable(done, i):
        allowed = done | {i}
        def skip(c):
            cave = g.cave_of(c["node"])
            return cave is not None and cave not in allowed and not c.get("early")

        _, caps, _ = g.solve(skip=skip)
        return "frag:c%d" % i in caps

    memo = {}

    def count(done):
        if done in memo:
            return memo[done]
        if len(done) == len(caves):
            return 1
        memo[done] = sum(count(done | {i}) for i in caves if i not in done and finishable(done, i))
        return memo[done]

    total = count(frozenset())
    return total, [i for i in caves if finishable(frozenset(), i)], frag_node


def print_stats(g):
    rooms = [n for n in g.d["nodes"] if n["kind"] == "room"]
    print("rooms: %d, pockets: %d" % (len(rooms), len(g.d["nodes"]) - len(rooms)))
    for k, v in sorted(Counter(n["region"] for n in rooms).items()):
        print("  %-12s %d" % (k, v))
    print("edges: %d, gated: %d" % (len(g.edges), sum(1 for e in g.edges if e.get("gate"))))
    print("gate types:", dict(Counter(e["gate"] for e in g.edges if e.get("gate"))))
    print("collectibles:", dict(Counter(c.get("kind", "capability") for c in g.coll)))
    print("dark rooms: %d" % sum(1 for n in rooms if n.get("dark")))


def run_checks(data):
    """Runs every check on a parsed graph. Returns (graph, errors, notes)."""
    g = Graph(data)
    errors, notes = [], []
    check_structure(g, errors)
    if not errors:
        reached, _ = check_coverage(g, errors, notes)
        check_oneway(g, errors)
        check_return(g, errors, reached)
        check_keys(g, errors, notes)
        check_slugs(g, errors, notes)
    return g, errors, notes


# Self-test mutations (world-plan 5.7). Each takes a copy of the parsed graph, changes it in place,
# and must make run_checks report at least one error.


def _m_ward_plate_no_capability(d):
    for e in d["edges"]:
        if e.get("prop") == "ward plate":
            e["needs"] = []


def _m_ward_not_base(d):
    # The ward plates rely on the ward being a base capability (no round changes).
    d["base_capabilities"] = [c for c in d["base_capabilities"] if c != "ward"]


def _m_cave2_slug_source_removed(d):
    d["pickups"] = [p for p in d["pickups"] if p["id"] != "slug_bundle_cave_2_6"]


def _m_overworld_slug_sources_removed(d):
    # Thornwood and Cinderflats: the cache and the shop stock are the only sources for the Eyegate.
    d["pickups"] = [p for p in d["pickups"] if p["id"] not in ("slug_bundle_ow_4_1", "slug_bundle_s3")]


def _m_c10_slug_source_behind_eye_switch(d):
    for p in d["pickups"]:
        if p["id"] == "slug_bundle_cave_10_12":
            p["node"] = "cave_10_13"


def _m_c9_slug_source_in_boss_room(d):
    for p in d["pickups"]:
        if p["id"] == "slug_bundle_cave_9_9":
            p["node"] = "cave_9_10"


def _m_c4_slug_source_in_wrong_cave(d):
    for p in d["pickups"]:
        if p["id"] == "slug_bundle_cave_4_7":
            p["node"] = "cave_8_2"


def _m_dark_not_boolean(d):
    for n in d["nodes"]:
        if n["id"] == "cave_1":
            n["dark"] = "yes"


def _m_dark_on_pocket(d):
    for n in d["nodes"]:
        if n["kind"] == "pocket":
            n["dark"] = True
            return


MUTATIONS = [
    ("ward plate gates with no capability (R1)", _m_ward_plate_no_capability),
    ("the ward taken out of the base kit (no item grants it)", _m_ward_not_base),
    ("every slug source of C2 removed (eye switch and boss, R6b)", _m_cave2_slug_source_removed),
    ("the slug sources of Thornwood and Cinderflats removed (Eyegate, R6b)", _m_overworld_slug_sources_removed),
    ("the C10 slug source moved behind the eye switch (R6b)", _m_c10_slug_source_behind_eye_switch),
    ("the C9 slug source moved into the boss room (R6b)", _m_c9_slug_source_in_boss_room),
    ("the C4 slug source moved into C8 (R6b, wrong cave)", _m_c4_slug_source_in_wrong_cave),
    ("dark is a string on a room (schema)", _m_dark_not_boolean),
    ("dark on a pocket (schema: only rooms have it)", _m_dark_on_pocket),
]


def run_selftest(data):
    """Applies every mutation to a copy of `data`. Returns how many were accepted or not applied."""
    base = json.dumps(data, sort_keys=True)
    bad = 0
    print("self-test: %d mutations" % len(MUTATIONS))
    for label, mutate in MUTATIONS:
        mutated = copy.deepcopy(data)
        mutate(mutated)
        if json.dumps(mutated, sort_keys=True) == base:
            print("  NOT APPLIED: %s" % label)
            bad += 1
            continue
        _, errors, _ = run_checks(mutated)
        if errors:
            print("  rejected: %s -> %s" % (label, errors[0]))
        else:
            print("  ACCEPTED: %s" % label)
            bad += 1
    return bad


def main(argv):
    flags = [a for a in argv[1:] if a.startswith("--")]
    args = [a for a in argv[1:] if not a.startswith("--")]
    with open(args[0] if args else "docs/world-graph.json", encoding="utf-8") as fh:
        data = json.load(fh)
    g, errors, notes = run_checks(data)
    for line in notes:
        print(line)
    if "--stats" in flags:
        print_stats(g)
    if "--rounds" in flags and not errors:
        rounds, _ = unlock_rounds(g)
        for i, new in enumerate(rounds, 1):
            print("round %d: %s" % (i, ", ".join(new)))
    if "--orders" in flags and not errors:
        total, firsts, _ = cave_orders(g)
        print("valid orders of the first nine caves: %d; possible first caves: %s" % (total, firsts))
    if errors:
        print("FAILED (%d):" % len(errors))
        for e in errors:
            print("  -", e)
        return 1
    print("OK: %d nodes, %d edges; goal reachable; no soft-lock found" % (len(g.nodes), len(g.edges)))
    if "--no-selftest" not in flags:
        if run_selftest(data):
            print("FAILED: a self-test mutation was not rejected")
            return 1
        print("self-test OK: every mutation rejected")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
