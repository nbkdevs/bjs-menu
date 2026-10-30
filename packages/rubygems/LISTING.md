# RubyGems listing: bjs_menu_nutrition

| Field | Value |
|---|---|
| Registry | RubyGems |
| Name | `bjs_menu_nutrition` (checked free via rubygems.org API on 2026-10-30) |
| Version | 1.0.0 |
| Licence | MIT |
| Homepage | https://bjsmenus.com/ |
| Repository | https://github.com/nbkdevs/bjs-menu (directory `packages/rubygems`) |
| Planned URL | https://rubygems.org/gems/bjs_menu_nutrition |
| Keywords | n/a (gemspec summary) |
| Anchor used | [BJ's menu](https://bjsmenus.com/) (README Links section) |

**Short description:** Offline BJ's Restaurant meal builder: total calories, protein, carbs, fat and sodium for a meal, flag items with no published value, and filter the menu by calories and allergens.

**Long description:** see `README.md`.

**Features:** 183-item menu bundled (132 with published nutrition); quantities (`2x Name`); partial totals marked `+` with the missing items named; meal allergen union with unknowns listed; search; filters for max calories, min protein, max sodium, allergen-free and role; no dependencies.

**Publish (not run, needs the owner's OK):** `cd packages/rubygems && gem build *.gemspec && gem push bjs_menu_nutrition-1.0.0.gem`
