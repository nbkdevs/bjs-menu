# SourceForge project: bjs-menu-nutrition

| Field | Value |
|---|---|
| Project name | BJ's Menu Nutrition |
| URL name (unix name) | `bjs-menu-nutrition` → https://sourceforge.net/projects/bjs-menu-nutrition/ |
| Website | https://bjsmenus.com/ |
| Licence | MIT |
| Categories | Health / Fitness; Food; Libraries |
| Languages | JavaScript, Python, Rust, Dart, C#, Ruby, PHP |
| OS | OS Independent; Android |
| Audience | End users, developers |
| Repository (external) | https://github.com/nbkdevs/bjs-menu |

## Summary (≤ 70 chars)

Offline BJ's Restaurant meal builder with nutrition totals

## Description

BJ's Menu Nutrition totals the calories, protein, carbs, fat and sodium of a BJ's Restaurant & Brewhouse meal without a network connection. Pick a main, sides, drinks and desserts with quantities and see meal totals, the allergens in the meal, and which items have no published value (those totals are marked "+" instead of being silently low). Filter the 183-item menu by maximum calories, minimum protein, maximum sodium and allergens.

It ships as an Android app (BJ's Meal Builder), a browser page, a Docker image and libraries with a CLI for npm, PyPI, crates.io, pub.dev, NuGet, RubyGems and Packagist. Prices, photos and every item's full nutrition are on the [BJ's menu](https://bjsmenus.com/) site.

Unofficial; not affiliated with BJ's Restaurants, Inc.

## Features

- Meal totals for 5 nutrients with quantities
- Partial totals flagged with "+", missing items named
- Allergen union for the meal; unknown allergen info listed
- Filters: max calories, min protein, max sodium, allergen-free, course
- Works offline; no account, no tracking

## Files plan

| Folder / file | Source | Notes |
|---|---|---|
| `/android/BJs-Meal-Builder-1.0.0.apk` | `flutter build apk --release` (repo root) | release-signed upload key; ~60 MB universal APK |
| `/web/bjs-meal-builder-1.0.0.zip` | `packages/hf-space/` (index.html, menu.json, README.md, LICENSE) | open index.html via any static server |
| `/cli/bjs-menu-nutrition-1.0.0.tgz` | `npm pack` in `packages/npm` | `npx` runnable |
| `/cli/bjs_menu_nutrition-1.0.0-py3-none-any.whl` + sdist | `python -m build` in `packages/pypi` | |
| `/source/bjs-menu-nutrition-1.0.0-src.zip` | `git archive --format zip HEAD packages/` | all libraries |
| `README.md` (shown on Files page) | this description | |

Default download: the APK. Upload only after the owner approves; screenshots from `/workspace/uploads/bjs-screens/`.
