# Amazon Appstore listing: BJ's Meal Builder (draft, not submitted)

Prepared 30 Oct 2026 (PKT). Nothing has been submitted. Submit from the Amazon Developer Console (Fire tablets) once Nazzal OKs it.

## App file
- APK: `build/app/outputs/flutter-apk/app-release.apk` (box copy: `/workspace/uploads/bjs-meal-builder-1.0.0-release.apk`; not committed)
- Package `com.bjsmenus.bjs_meal_builder`, version 1.0.0 (versionCode 1), minSdk 24, targetSdk 36, ABIs arm64-v8a / armeabi-v7a / x86_64, about 60 MB
- Signed with the upload key `~/keystores/bjs-meal-builder-upload.jks` (alias `upload`, on the box only). Amazon re-signs the app with its own key.
- Device support: Fire tablets (Fire OS 7/8). Android-device (non-Fire) submissions are closed.

## Text
- **Title:** BJ's Meal Builder - Nutrition Totals
- **Short description (≤ 1200 chars, shown in search):**
  Build a BJ's Restaurant meal and see its calories, protein, carbs, fat and sodium add up as you go. Independent tool, not affiliated with BJ's Restaurant & Brewhouse.
- **Long description:**
  Planning a night out at BJ's and want to know what you are really eating? BJ's Meal Builder lets you pick a main, add sides, drinks and a Pizookie, change quantities, and watch the totals update live.

  Features
  • Meal Builder: add a main, sides, drinks and desserts, set quantities, swap or remove items
  • Running totals for calories, protein, carbs, fat and sodium
  • Meal summary sheet with the full breakdown of every item
  • Nutrition tab to browse and compare items by calories and macros
  • Notes when an item's published value already includes a side, so nothing is counted twice
  • Nutrition data is built in, so totals work offline (food photos load when you are online)
  • No account, no ads, no tracking

  Nutrition values come from BJ's published nutrition information and are summarised on our companion site, which has the full BJ's menu with nutrition and meal tools: https://bjsmenus.com/

  This is an independent guide. It is not affiliated with, endorsed by or sponsored by BJ's Restaurant & Brewhouse. Values are for general information only; check with the restaurant for allergens and dietary needs.
- **Product feature bullets (Amazon allows up to 5):**
  1. Build a full BJ's meal and see live nutrition totals
  2. Calories, protein, carbs, fat and sodium for every item
  3. Meal summary with a per-item breakdown
  4. Browse and compare menu nutrition
  5. Free, built-in data, no account and no ads
- **Keywords:** BJ's menu, BJ's nutrition, meal builder, calorie counter, restaurant nutrition, macros, Pizookie calories, deep dish pizza calories, sodium tracker, food calculator
- **Category:** Health & Fitness (sub-category: Diet & Weight Loss). Alternative: Food & Drink.
- **Content rating:** General audience (no violence, no user content, no ads, no in-app purchases, no location or personal data collected)
- **Website:** https://bjsmenus.com/
- **Privacy policy URL:** https://bjsmenus.com/privacy-policy/
- **Support email:** use the developer account's support address
- **Price:** Free

## Images
| Asset | File | Size |
|---|---|---|
| Large icon | `bjs 512.png` (repo root) | 512 x 512 PNG |
| Small icon | `bjs 114.png` (repo root) | 114 x 114 PNG |
| Screenshots, phone portrait (3 to 10 needed) | `releases/amazon/screenshots/01-meal-builder.png`, `02-meal-totals.png`, `03-nutrition.png`, `04-pick-a-main.png` | 1080 x 1920 PNG |
| Screenshots, Fire tablet portrait | `releases/amazon/screenshots/0N-*-800x1280.png` (same 4 screens) | 800 x 1280 PNG |

The screenshots were rendered from the real app with Flutter golden tests. Food photos show letter placeholders because the test renderer had no network.

## Before submitting
- Trademark: the title and UI use "BJ's". Amazon may ask for proof of rights; the in-app and listing disclaimers say it is independent. If Amazon rejects it, rename to "Meal Builder for BJ's Menu" or drop the brand from the title.
- Keep the upload keystore and its passwords safe (box only, `android/key.properties` is gitignored).
