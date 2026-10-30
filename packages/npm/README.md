# bjs-menu-nutrition

Total the calories, protein, carbs, fat and sodium of a BJ's Restaurant & Brewhouse meal, offline. Pick a main, sides, drinks and desserts (with quantities) and get meal totals, the allergens in the meal, and a clear flag on every item that has no published value, so a total is never silently low.

The bundled menu has 183 items (132 with published nutrition). Items listed only per slice, and items with no published value, are not added to a total; the total is shown with a `+` and the items are named. Unknown allergen info never passes an allergen filter.

## Install

```sh
npm install bjs-menu-nutrition
# or run the CLI without installing
npx bjs-menu-nutrition total "BJ's Wagyu Burger" "2x Avocado Egg Rolls"
```

## CLI

```sh
bjs-menu-nutrition total "BJ's Wagyu Burger" "2x Avocado Egg Rolls"
bjs-menu-nutrition search pizookie
bjs-menu-nutrition filter --max-cal 600 --min-protein 30 --without Milk --role main
bjs-menu-nutrition categories
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

Add `--json` for machine-readable output.

## Library

```js
const m = require('bjs-menu-nutrition');

const meal = m.total(["BJ's Wagyu Burger", '2x Avocado Egg Rolls', 'California Club Flatbread']);
console.log(m.formatTotal(meal.totals.cal));      // "1,230 cal+" style partial totals
console.log(meal.totals.cal.missing);             // ['California Club Flatbread'] (per slice only)
console.log(meal.allergens, meal.allergenUnknown);

m.search('pizookie');                             // items whose name has every word
m.filter({ maxCal: 600, minProtein: 30, without: ['Milk'], role: 'main' });
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
