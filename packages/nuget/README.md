# BjsMenu.Nutrition

Total the calories, protein, carbs, fat and sodium of a BJ's Restaurant & Brewhouse meal, offline. Pick a main, sides, drinks and desserts (with quantities) and get meal totals, the allergens in the meal, and a clear flag on every item that has no published value, so a total is never silently low.

The bundled menu has 183 items (132 with published nutrition). Items listed only per slice, and items with no published value, are not added to a total; the total is shown with a `+` and the items are named. Unknown allergen info never passes an allergen filter.

## Install

```sh
dotnet add package BjsMenu.Nutrition
```

## Library

```csharp
using BjsMenu.Nutrition;

var meal = new Meal().Add("BJ's Wagyu Burger").Add("2x Avocado Egg Rolls");
foreach (var (nutrient, total) in meal.Totals())
    Console.WriteLine($"{nutrient}: {total.Format()}");   // Calories: 3,210 cal
Console.WriteLine(string.Join(", ", meal.Allergens));

var light = Menu.Filter(maxCalories: 600, without: new[] { "Milk" }, role: Role.Main);
```

A small CLI lives in `cli/` of the source repo: `dotnet run --project cli -- total "BJ's Wagyu Burger" "2x Avocado Egg Rolls"`.

## How totals work

- `2x Name` sets a quantity (1-99).
- A name can be the item id, the exact name, or words that match exactly one item; an ambiguous query such as `burger` is an error that lists the matches.
- A nutrient with no published value, or an item listed per slice, is skipped and named in `missing`; the formatted total ends with `+`. If no item in the meal has the value, it reads `Not listed`.

## Links

- Full menu with prices, photos and per-item nutrition: [BJ's menu](https://bjsmenus.com/)
- Source: https://github.com/nbkdevs/bjs-menu
- Issues: https://github.com/nbkdevs/bjs-menu/issues

## Notes

Values are as published by the restaurant and can change; check with your server about allergies. Unofficial; not affiliated with BJ's Restaurants, Inc.

## Licence

MIT
