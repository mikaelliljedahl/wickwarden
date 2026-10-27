#!/usr/bin/env python3
"""Generate graph-derived progression objectives for the playthrough tests.

The rounds are capability dependencies, not a physical walking route. Runtime
tests must still perform the gates, fights and pickups represented here.
"""

import argparse
import hashlib
import json
from pathlib import Path

from check_world_graph import run_checks, unlock_rounds


ROOT = Path(__file__).resolve().parent.parent
GRAPH = ROOT / "docs/world-graph.json"
OUTPUT = ROOT / "data/playthrough_route.json"


def generate(path: Path) -> dict:
    raw = path.read_bytes()
    data = json.loads(raw)
    graph, errors, _ = run_checks(data)
    if errors:
        raise ValueError("invalid world graph: " + "; ".join(errors))
    rounds, held = unlock_rounds(graph)
    objectives = []
    for number, capabilities in enumerate(rounds, 1):
        for capability in capabilities:
            item = data["items"][capability]
            node = graph.nodes[item["node"]]
            objective = {
                "round": number,
                "capability": capability,
                "node": item["node"],
                "needs": sorted(item.get("needs", [])),
                "after_boss": item.get("after_boss", False),
            }
            if objective["after_boss"]:
                objective["boss"] = node["boss"]
            objectives.append(objective)
    reached, _, _ = graph.solve(seed=held)
    if graph.goal not in reached:
        raise ValueError("goal is unreachable after the final unlock round")
    return {
        "source_sha256": hashlib.sha256(raw).hexdigest(),
        "start": graph.start,
        "goal": graph.goal,
        "base_capabilities": sorted(graph.base),
        "objectives": objectives,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="fail if the output is stale")
    args = parser.parse_args()
    try:
        content = json.dumps(generate(GRAPH), indent=2, ensure_ascii=False) + "\n"
        if args.check:
            if not OUTPUT.is_file() or OUTPUT.read_text(encoding="utf-8") != content:
                print(f"stale or missing: {OUTPUT.relative_to(ROOT)}")
                return 1
        else:
            OUTPUT.write_text(content, encoding="utf-8")
    except (OSError, ValueError, KeyError) as error:
        print(f"playthrough route: {error}")
        return 1
    print(f"playthrough objectives OK: {OUTPUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
