# bjs-menu-nutrition

Total the calories, protein, carbs, fat and sodium of a BJ's Restaurant & Brewhouse meal, offline. Pick a main, sides, drinks and desserts (with quantities) and get meal totals, the allergens in the meal, and a clear flag on every item that has no published value, so a total is never silently low.

The bundled menu has 183 items (132 with published nutrition). Items listed only per slice, and items with no published value, are not added to a total; the total is shown with a `+` and the items are named. Unknown allergen info never passes an allergen filter.

## Install

```sh
cargo add bjs-menu-nutrition        # library
cargo install bjs-menu-nutrition    # CLI
```

## CLI

```sh
bjs-menu-nutrition total "BJ's Wagyu Burger" "2x Avocado Egg Rolls"
bjs-menu-nutrition search pizookie
bjs-menu-nutrition filter --max-cal 600 --min-protein 30 --without Milk --role main
```

```
1 x BJ's Wagyu Burger
2 x Avocado Egg Rolls

Calories 3,210 cal
Protein  68 g
Carbs    322 g
Fat      186 g
Sodium   5,669 mg
Allergens: Eggs, Fish, Milk, Other Gluten, Soy, Sulfites, Tree Nuts, Wheat
```

## Library

```rust
use bjs_menu_nutrition::{filter, Filter, Meal, Role};

let mut meal = Meal::new();
meal.add("BJ's Wagyu Burger")?.add("2x Avocado Egg Rolls")?;
for t in meal.totals() {
    println!("{:?}: {}", t.nutrient, t.format()); // Cal: 3,210 cal
}
let light = filter(&Filter { max_cal: Some(600), without: vec!["Milk".into()], role: Some(Role::Main), ..Default::default() });
```

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
