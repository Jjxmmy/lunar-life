"""Checks that furniture never blocks the way.

Reads scripts/outpost/outpost_layout.gd and scripts/academy/academy_layout.gd the same way
the painters do, builds a walk grid (floor minus blockers, shrunk by the astronaut's body
radius) and flood-fills from the spawn. Every station spot, crew spot and door centre must
be reachable, and no spot may sit inside a blocker.

    python3 tools/dev/check_layout.py      (exit code 1 on any problem)
"""
from __future__ import annotations

import sys
from collections import deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools" / "art"))
from paint_world import read_layout  # noqa: E402

CELL = 2          # map units per grid cell
BODY = 5          # half-width of the astronaut's feet, map units


def check(name: str, layout: dict, floors: list[str], spawn: str, spots: list[str]) -> list[str]:
    problems: list[str] = []
    W, H = layout["MAP"]
    blockers = [v for k, v in layout.items() if isinstance(v, tuple) and len(v) == 4 and k not in floors and k not in ("MAP",)]
    floor_rects = [layout[f] for f in floors]

    def inside(r, x, y, pad=0.0):
        return r[0] - pad <= x < r[0] + r[2] + pad and r[1] - pad <= y < r[1] + r[3] + pad

    def walkable(x, y):
        # The feet need floor under the whole body and no furniture within reach.
        on_floor = all(any(inside(f, x + dx, y + dy) for f in floor_rects) for dx in (-BODY, BODY) for dy in (-2, 2))
        return on_floor and not any(inside(b, x, y, BODY - 1) for b in blockers)

    cols, rows = int(W // CELL), int(H // CELL)
    grid = [[walkable(c * CELL + CELL / 2, r * CELL + CELL / 2) for c in range(cols)] for r in range(rows)]
    sx, sy = layout[spawn]
    start = (int(sy // CELL), int(sx // CELL))
    if not grid[start[0]][start[1]]:
        return [f"{name}: spawn {spawn} is not walkable"]
    seen = {start}
    queue = deque([start])
    while queue:
        r, c = queue.popleft()
        for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nr, nc = r + dr, c + dc
            if 0 <= nr < rows and 0 <= nc < cols and grid[nr][nc] and (nr, nc) not in seen:
                seen.add((nr, nc))
                queue.append((nr, nc))

    def reachable(x, y, radius=6):
        # A spot counts if any walkable cell within a few units of it was reached.
        for r in range(int((y - radius) // CELL), int((y + radius) // CELL) + 1):
            for c in range(int((x - radius) // CELL), int((x + radius) // CELL) + 1):
                if (r, c) in seen:
                    return True
        return False

    for s in spots:
        x, y = layout[s]
        for k, b in layout.items():
            if k in floors or k == "MAP" or not (isinstance(b, tuple) and len(b) == 4):
                continue
            if inside(b, x, y):
                problems.append(f"{name}: {s} {(x, y)} is inside {k}")
        if not reachable(x, y):
            problems.append(f"{name}: {s} {(x, y)} cannot be reached from {spawn}")
    print(f"{name}: {len(seen)} walkable cells reached, {len(spots)} spots checked, {len(blockers)} blockers")
    return problems


def main() -> int:
    out = read_layout(ROOT / "scripts" / "outpost" / "outpost_layout.gd")
    for door in ("POWER_DOOR", "GREEN_DOOR", "SHELTER_DOOR"):
        x, y, w, h = out[door]
        out[door + "_MID"] = (x + w / 2, y + h / 2)
    problems = check("outpost", out,
                     ["CORRIDOR", "POWER_ROOM", "POWER_DOOR", "GREEN_ROOM", "GREEN_DOOR", "SHELTER_ROOM", "SHELTER_DOOR"],
                     "SPAWN",
                     ["POWER_SPOT", "GREEN_SPOT", "HATCH_SPOT", "RETURN_SPOT", "LOG_SPOT", "BUNK_SPOT", "BIKE_SPOT",
                      "TANAKA_HOME", "TANAKA_WAIT", "TANAKA_SEAT", "RIVERA_HOME", "RIVERA_WAIT", "RIVERA_SEAT",
                      "HALL_JUNCTION", "POWER_DOOR_MID", "GREEN_DOOR_MID", "SHELTER_DOOR_MID"])
    aca = read_layout(ROOT / "scripts" / "academy" / "academy_layout.gd")
    problems += check("academy", aca, ["FLOOR"], "SPAWN",
                      ["HATCH_ARRIVAL", "BOARD_SPOT", "DESK_SPOT", "PLANT_SPOT", "COMMANDER_SPOT", "ENGINEER_SPOT",
                       "BOTANIST_SPOT", "ARM_SPOT"])
    for p in problems:
        print("PROBLEM:", p)
    print("LAYOUT CHECK:", "PASS" if not problems else f"{len(problems)} problems")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
