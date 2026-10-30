# BJ’s Meal Builder (Android)

Flutter Android app for [BJ's menu](https://bjsmenus.com/) — **Meal Builder** and **Nutrition** only. No prices.

## Features

- **Meal Builder** — pick a main, add sides / drinks / desserts, live totals for calories, protein, carbs, fat, sodium, plus allergen notes
- **Nutrition** — searchable, filterable guide of published nutrition figures; add items to your meal
- **Offline** — menu data is baked into `assets/data/items.json` (183 items from the site)

## Run

```bash
flutter pub get
flutter run
```

## Data

`assets/data/items.json` mirrors the site Meal Builder catalog (nutrition only — no prices). Refresh it from the site’s `meal-builder.js` when the menu changes.
