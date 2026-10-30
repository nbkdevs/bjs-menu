"""Offline BJ's Restaurant meal nutrition totals, search and allergen filters."""
from __future__ import annotations

import json
import re
import unicodedata
from importlib import resources

__version__ = "1.0.0"
__all__ = ["items", "categories", "search", "find", "parse_line", "total", "filter_items", "format_total", "NUTRIENTS"]

NUTRIENTS = ("cal", "protein", "carbs", "fat", "sodium")
UNITS = {"cal": "cal", "protein": "g", "carbs": "g", "fat": "g", "sodium": "mg"}

_DATA = json.loads(resources.files(__package__).joinpath("menu.json").read_text(encoding="utf-8"))
_ITEMS = _DATA["items"]
SOURCE = _DATA["source"]


def _norm(s) -> str:
    s = unicodedata.normalize("NFKD", str(s).lower()).replace("\u2019", "").replace("\u2018", "").replace("'", "")
    return re.sub(r"[^a-z0-9]+", " ", s).strip()


def items() -> list[dict]:
    return [dict(i) for i in _ITEMS]


def categories() -> list[str]:
    seen: list[str] = []
    for i in _ITEMS:
        if i["category"] not in seen:
            seen.append(i["category"])
    return seen


def search(query: str) -> list[dict]:
    q = _norm(query)
    if not q:
        return []
    words = q.split(" ")
    return [i for i in _ITEMS if all(w in _norm(i["name"]) for w in words)]


def find(ref: str) -> dict:
    """Find one item by id, exact name, or a query matching exactly one item."""
    for i in _ITEMS:
        if i["id"] == ref:
            return i
    q = _norm(ref)
    for i in _ITEMS:
        if _norm(i["name"]) == q:
            return i
    hits = search(ref)
    if len(hits) == 1:
        return hits[0]
    if not hits:
        raise LookupError(f'No menu item matches "{ref}"')
    names = "; ".join(h["name"] for h in hits[:5])
    raise LookupError(f'"{ref}" matches {len(hits)} items: {names}')


def parse_line(text: str) -> tuple[str, int]:
    """'2x Avocado Egg Rolls' -> ('Avocado Egg Rolls', 2)."""
    m = re.match(r"^\s*(\d+)\s*[x\u00d7]\s+(.+)$", text, re.I)
    return (m.group(2).strip(), int(m.group(1))) if m else (text.strip(), 1)


def total(lines) -> dict:
    """Total a meal. Lines are refs ('2x Name') or (ref, qty) tuples.

    Items with no published value for a nutrient, or listed per slice, are not added and are named
    in ``missing``; the total is then partial.
    """
    resolved = []
    for line in lines:
        ref, qty = parse_line(line) if isinstance(line, str) else line
        item = find(ref)
        if not isinstance(qty, int) or not 1 <= qty <= 99:
            raise ValueError(f"Quantity for {item['name']} must be 1-99")
        resolved.append((item, qty))
    totals = {}
    for k in NUTRIENTS:
        s, missing = 0, []
        for item, qty in resolved:
            v = item.get(k)
            if v is None or item["perSlice"]:
                missing.append(item["name"])
            else:
                s += v * qty
        totals[k] = {"sum": s, "unit": UNITS[k], "missing": missing, "partial": bool(missing),
                     "listed": bool(resolved) and len(missing) < len(resolved)}
    allergens, unknown = set(), []
    for item, _ in resolved:
        if item["allergens"] is None:
            unknown.append(item["name"])
        else:
            allergens.update(item["allergens"])
    return {"lines": [{"name": i["name"], "qty": q} for i, q in resolved], "totals": totals,
            "allergens": sorted(allergens), "allergen_unknown": unknown}


def filter_items(max_cal=None, min_protein=None, max_sodium=None, without=(), role=None, category=None) -> list[dict]:
    """Filter items. Items with unknown allergen info are excluded when ``without`` is given."""
    wo = [_norm(w) for w in without]
    out = []
    for i in _ITEMS:
        if role and i["role"] != role:
            continue
        if category and _norm(i["category"]) != _norm(category):
            continue
        if max_cal is not None and (i["cal"] is None or i["perSlice"] or i["cal"] > max_cal):
            continue
        if min_protein is not None and (i["protein"] is None or i["protein"] < min_protein):
            continue
        if max_sodium is not None and (i["sodium"] is None or i["sodium"] > max_sodium):
            continue
        if wo:
            if i["allergens"] is None:
                continue
            have = [_norm(a) for a in i["allergens"]]
            if any(w in have for w in wo):
                continue
        out.append(i)
    return out


def format_total(t: dict) -> str:
    if not t["listed"]:
        return "Not listed"
    n = f"{round(t['sum']):,}"
    v = f"{n} cal" if t["unit"] == "cal" else f"{n} {t['unit']}"
    return v + "+" if t["partial"] else v
