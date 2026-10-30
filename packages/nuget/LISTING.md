# NuGet listing: BjsMenu.Nutrition

| Field | Value |
|---|---|
| Registry | NuGet |
| Name | `BjsMenu.Nutrition` (checked free via api.nuget.org flat container on 2026-10-30) |
| Version | 1.0.0 |
| Licence | MIT |
| Homepage | https://bjsmenus.com/ |
| Repository | https://github.com/nbkdevs/bjs-menu (directory `packages/nuget`) |
| Planned URL | https://www.nuget.org/packages/BjsMenu.Nutrition |
| Keywords | bjs; nutrition; calories; menu; meal-builder; allergens |
| Anchor used | [BJ's menu](https://bjsmenus.com/) (README Links section) |

**Short description:** Offline BJ's Restaurant meal builder: total calories, protein, carbs, fat and sodium for a meal, flag items with no published value, and filter the menu by calories and allergens.

**Long description:** see `README.md`.

**Features:** 183-item menu bundled (132 with published nutrition); quantities (`2x Name`); partial totals marked `+` with the missing items named; meal allergen union with unknowns listed; search; filters for max calories, min protein, max sodium, allergen-free and role; no dependencies.

**Publish (not run, needs the owner's OK):** `cd packages/nuget && dotnet pack src -c Release && dotnet nuget push src/bin/Release/*.nupkg -s nuget.org`
