"""Command line: bjs-menu-nutrition total|search|filter|categories."""
from __future__ import annotations

import argparse
import json
import sys

from . import NUTRIENTS, categories, filter_items, format_total, search, total

LABELS = {"cal": "Calories", "protein": "Protein", "carbs": "Carbs", "fat": "Fat", "sodium": "Sodium"}


def _row(i):
    cal = f"{i['calText']} cal" if i["calText"] else (f"{i['cal']} cal" if i["cal"] is not None else "calories not listed")
    return f"{i['name']} ({i['category']}) - {cal}"


def main(argv=None) -> int:
    p = argparse.ArgumentParser(prog="bjs-menu-nutrition", description="BJ's Restaurant meal nutrition totals (offline).")
    p.add_argument("--json", action="store_true", help="JSON output")
    sub = p.add_subparsers(dest="cmd", required=True)
    t = sub.add_parser("total", help='total a meal, e.g. total "BJ\'s Wagyu Burger" "2x Avocado Egg Rolls"')
    t.add_argument("items", nargs="+")
    s = sub.add_parser("search", help="search items by name")
    s.add_argument("words", nargs="+")
    f = sub.add_parser("filter", help="filter by calories, protein, sodium, allergens, role")
    f.add_argument("--max-cal", type=int)
    f.add_argument("--min-protein", type=int)
    f.add_argument("--max-sodium", type=int)
    f.add_argument("--without", default="", help="comma-separated allergens, e.g. Milk,Wheat")
    f.add_argument("--role", choices=["main", "side", "drink", "dessert"])
    sub.add_parser("categories", help="list menu categories")
    a = p.parse_args(argv)
    try:
        if a.cmd == "total":
            r = total(a.items)
            if a.json:
                print(json.dumps(r, indent=2))
                return 0
            for line in r["lines"]:
                print(f"{line['qty']} x {line['name']}")
            print()
            for k in NUTRIENTS:
                print(f"{LABELS[k]:<9}{format_total(r['totals'][k])}")
            missing = list(dict.fromkeys(n for k in NUTRIENTS for n in r["totals"][k]["missing"]))
            if missing:
                print(f"\n+ partial: no published value (or per-slice only) for {'; '.join(missing)}")
            if r["allergens"]:
                print("Allergens: " + ", ".join(r["allergens"]))
            if r["allergen_unknown"]:
                print("Allergens not listed for: " + "; ".join(r["allergen_unknown"]))
        elif a.cmd == "search":
            res = search(" ".join(a.words))
            print(json.dumps(res, indent=2)) if a.json else [print(_row(i)) for i in res]
        elif a.cmd == "filter":
            wo = [w for w in a.without.split(",") if w.strip()]
            res = filter_items(a.max_cal, a.min_protein, a.max_sodium, wo, a.role)
            print(json.dumps(res, indent=2)) if a.json else [print(_row(i)) for i in res]
        else:
            for c in categories():
                print(c)
    except (LookupError, ValueError) as e:
        print(e, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
