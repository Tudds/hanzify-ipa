#!/usr/bin/env python3
"""Split the combined collocation pool into per-HSK-level files.

Why: the Shorts startup feed only needs the active level (e.g. HSK2), but the
app used to load + jsonDecode the whole ~1.9MB `collocation_pool_hsk1_4.json`
on the main isolate before the first frame, then keep only a handful of items.
Splitting by level lets the repository parse just the level it needs
(~0.5MB) at startup. Total bundle bytes are unchanged; parse time drops.

Run from the repo root:  python3 tool/split_collocation_pool.py
Idempotent: regenerates per-level files and removes the combined source.
"""
import json
import os
from collections import OrderedDict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GEN = os.path.join(ROOT, "assets/data/generated")
COMBINED = os.path.join(GEN, "collocation_pool_hsk1_4.json")


def main() -> None:
    with open(COMBINED, encoding="utf-8") as fh:
        items = json.load(fh)

    by_level: "OrderedDict[int, list]" = OrderedDict()
    for item in items:  # preserve original order within each level
        by_level.setdefault(item["level"], []).append(item)

    for level in sorted(by_level):
        out = os.path.join(GEN, f"collocation_pool_hsk{level}.json")
        with open(out, "w", encoding="utf-8") as fh:
            json.dump(by_level[level], fh, ensure_ascii=False, separators=(",", ":"))
        print(f"  collocation_pool_hsk{level}.json: {len(by_level[level])} items")

    os.remove(COMBINED)
    print(f"Removed combined source ({len(items)} items split across "
          f"{len(by_level)} levels).")


if __name__ == "__main__":
    main()
