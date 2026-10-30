# Status: BJ's Menus (https://bjsmenus.com)

Audited 30 Oct 2026 (Asia/Karachi, PKT). This was a read-only check: nothing was published and nothing was committed to nbkdevs/bjs-menu. Rules: one Chrome theme, one extension (Firefox + Edge) and one skill per project. Browser-store items carry no brand, trademark or place names. Brand names are fine in packages and skills.

## Live

| Platform | Item | Live URL | Target URL | Link placement | Dofollow | Live? | Date | Notes |
|---|---|---|---|---|---|---|---|---|
| Firefox AMO | PlatePlan - Meal Builder (v2.0.0) | https://addons.mozilla.org/en-US/firefox/addon/plateplan-meal-builder/ | https://bjsmenus.com | Homepage + Support site fields (no in-text link) | no (AMO outgoing redirector) | yes (status public, author NBK Devs) | created 14 Oct 2026 12:53 PKT; updated 17 Oct 2026 | Verified through AMO API v5. Repo copy is in browser-extensions/firefox; the zip is releases/extensions/plateplan-firefox.zip. Gecko id `plateplan@example.com` |
| Edge Add-ons | PlatePlan - Meal Builder & Nutrition (v2.0.0) | https://microsoftedge.microsoft.com/addons/detail/gffohanbnhkaccpkheammaojgoekmjjb | https://bjsmenus.com (privacy: https://bjsmenus.com/privacy-policy/) | Publisher website + privacy policy fields | ? (not checked on the rendered page) | yes | about 14 Oct 2026 (lastUpdateDate) | storeProductId 0RDCKG5T7WV2, publisher NBK Devs, verified through the getproductdetailsbycrxid API. Zip: releases/extensions/plateplan-edge.zip |
| Chrome Web Store (theme) | Peach Facet Collage (v2.0.0) | https://chromewebstore.google.com/detail/peach-facet-collage/ejpjgpldgjacfpnebempdmeajfnlmaim | https://bjsmenus.com | Homepage / support field (no text link) | no (CWS rows in the sheet say nofollow) | yes | updated 15 Oct 2026 | The page shows bjsmenus.com and NBK Devs. Zip: releases/extensions/peach-facet-collage-chrome-theme.zip |
| GitHub | `nbkdevs/bjs-menu` (public repo) | https://github.com/nbkdevs/bjs-menu | https://bjsmenus.com | root README anchor "BJ's menu" (About "Website" field is EMPTY) | no (GitHub README links are nofollow) | yes | – | Quick win: set the About website with `gh repo edit nbkdevs/bjs-menu --homepage https://bjsmenus.com` (needs Nazzal's OK) |

The theme and extension slots are full. Do not build more browser-store items.

## Built but not published
- Flutter Android app "BJ's Meal Builder". The package is `com.bjsmenus.bjs_meal_builder` and the icons are in releases/. A signed release APK was built on 30 Oct 2026 (box only, not committed; see the Packages table). I found no Amazon Appstore or Google Play listing (see "Inconclusive" below). The app UI uses "BJ's" brand text. That is allowed for apps under the brief, but Amazon may question a trademark without the owner's permission.

## To build

| Platform | Suggested asset | Target URL | Link placement |
|---|---|---|---|
| Amazon Appstore (Fire) | Ship the existing Flutter app (build an APK) as a Fire tablet app. Lead with "independent, not affiliated". New Android-device submissions have ended, but Fire submissions still work (Turbo Luxury ASIN B0HL8FDQLD went live 30 Sep 2026) | https://bjsmenus.com | developer website + in-app link |
| npm | `bjs-menu-nutrition`: a meal totaler. Add items and get calories, protein, carbs, fat and sodium totals. Any item with no published value marks the total "incomplete" and names the item, the same rule as the site's Meal Builder | https://bjsmenus.com/tools/meal-builder/ | `homepage` + README anchor |
| PyPI | `bjs-menu-allergens`: an allergen and dietary filter (gluten-sensitive, contains-X) over a bundled dataset, with a CLI | https://bjsmenus.com/nutrition/ | Homepage + README anchor |
| crates.io | `bjs_menu_compare`: side-by-side nutrition comparison that flags the lowest/highest value per row (same rules as /tools/compare/) | https://bjsmenus.com/tools/compare/ | `homepage` + README |
| pub.dev | `bjs_meal_builder_core`: the Dart model and totaling logic pulled out of the Flutter app (the code already exists in lib/) | https://bjsmenus.com/tools/meal-builder/ | `homepage` + README |
| NuGet | `BjsMenu.MacroGoals`: checks a meal against macro targets (e.g. under 800 kcal, 40 g+ protein) | https://bjsmenus.com/ | `PackageProjectUrl` + README |
| RubyGems | `bjs_menu_sodium`: a sodium/calorie budget planner across a day's meals | https://bjsmenus.com/nutrition/ | `homepage` + README |
| Packagist | `nbkdevs/bjs-menu-nutrition`: PHP port of the totaler, submitted from a root composer.json | https://bjsmenus.com/ | `homepage` + README |
| Docker Hub (iamnazzal) | `iamnazzal/bjs-menu-nutrition`: a small API (POST items, get totals and allergens) plus a static page | https://bjsmenus.com/ | README anchor + OCI url label (dofollow on Hub) |
| HF Space (iamnazzal) | `iamnazzal/bjs-meal-builder`: a static meal-builder page | https://bjsmenus.com/tools/meal-builder/ | README anchor |
| ClawHub (nbkdevs) - the ONE skill | `restaurant-meal-nutrition-planner` (SKILL.md): build a meal under calorie, macro and allergen limits and show totals and missing values. Brand mention allowed | https://bjsmenus.com/tools/meal-builder/ | SKILL.md Links anchor + `metadata.openclaw.homepage` |
| Smithery skills (nbkdevs) | The same SKILL.md. **Smithery API/CLI shuts down 31 Oct 2026, so this must be published by tomorrow or dropped** | same | SKILL.md anchor (dofollow on Smithery) |
| SourceForge | Mirror project with the app APK + README (project URL field) | https://bjsmenus.com | project homepage field |
| Product Hunt | Launch "BJ's Menu Guide": meal builder + nutrition compare tools | https://bjsmenus.com | product website field |

## Searches and inconclusive results (30 Oct 2026 PKT)
- **Amazon Appstore: inconclusive.** curl searches by developer and keyword hit Amazon's bot interstitial (pages of about 2.3 KB). I did not try to bypass it. WebFetch of the search page came back empty. Web searches and TheGreatApps' NBK Devs Amazon list show no BJ's or PlatePlan app. Amazon developer names vary (Turbo Luxury is listed under "CoreiTalk"), so a check of the Amazon developer console by Nazzal is the only definitive test. The connected Gmail (nbkdevs@gmail.com) has no Amazon app notices. Amazon developer mail seems to go to nazzal5448@gmail.com, which is not connected.
- Google Play: the AppBrain NBK Devs list (11 apps) has no BJ's app. This came from a search snippet, so it may be incomplete.
- Registries, all 404/none: npm (maintainer `iamnazzal.com` has 13 packages, none for BJ's; also checked names bjs-menus, bjs-menu, bjs-meal-builder, bjs-nutrition, plateplan, meal-builder-nutrition), PyPI, crates.io (user nbkdevs only has semax-polska-research-notes), pub.dev, RubyGems (owner iamnazzal has 11 gems, none BJ's), NuGet (owners nbkdevs/iamnazzal, 13 packages, none), Packagist (vendor nbkdevs only ps2-bios-checksum; search "bjsmenus" 0), Docker Hub iamnazzal (15 repos, none), HF iamnazzal (12 Spaces, none).
- ClawHub: I found no nbkdevs BJ's or meal skill in CLI semantic search, and candidate slugs return 404. The API has no per-owner listing, so this is not fully conclusive.
- Smithery: CLI search did not return a nbkdevs meal skill. The same search also misses the known nbkdevs/car-wash-planner, so the search is weak and the result is inconclusive.
- SourceForge: curl got 403 and the profile /u/nbkdevs returned 404 via fetch. The known softrank projects (orefinder, travelpal, abu-dhabi-car-care-guide) are under another account, so a BJ's project could not be ruled out from here.
- Product Hunt: curl got 403, and a web search found no BJ's Menu Guide launch. Inconclusive.
- Tracking sheet (Ultimate Backlinks Sheet, tab Softrank): no BJ's rows.

## Skills (published 2026-10-30, v1.0.1, homepage anchor "BJ's menu")
- ClawHub: https://clawhub.ai/nbkdevs/restaurant-meal-nutrition-planner
- Smithery: https://smithery.ai/skills/nbkdevs/restaurant-meal-nutrition-planner (dofollow)

## Packages built 30 Oct 2026 (PKT): not published

All in `packages/<registry>/`. Same core in each: the bundled BJ's menu (183 items, 132 with published nutrition) and a meal totaler (calories, protein, carbs, fat, sodium; partial totals flag missing items) with a CLI and unit tests. Every README has a Links section with the anchor [BJ's menu](https://bjsmenus.com/), and every homepage field is https://bjsmenus.com/. Names were checked free on each registry. Publish commands are in each LISTING.md and need Nazzal's OK.

| Registry | Package | Version | Planned URL | Dry-run result |
|---|---|---|---|---|
| npm | `bjs-menu-nutrition` | 1.0.0 | https://www.npmjs.com/package/bjs-menu-nutrition | `npm test` pass; `npm pack --dry-run` OK (6 files, 10.4 kB) |
| PyPI | `bjs-menu-nutrition` | 1.0.0 | https://pypi.org/project/bjs-menu-nutrition/ | pytest 6 pass; `python -m build` sdist + wheel; `twine check` PASSED |
| crates.io | `bjs-menu-nutrition` | 1.0.0 | https://crates.io/crates/bjs-menu-nutrition | `cargo test` 6 pass; `cargo package` verified |
| pub.dev | `bjs_menu_nutrition` | 1.0.0 | https://pub.dev/packages/bjs_menu_nutrition | `dart pub publish --dry-run`: 0 warnings |
| NuGet | `BjsMenu.Nutrition` | 1.0.0 | https://www.nuget.org/packages/BjsMenu.Nutrition | `dotnet test` 5 pass; `dotnet pack` OK (README + LICENSE in nupkg) |
| RubyGems | `bjs_menu_nutrition` | 1.0.0 | https://rubygems.org/gems/bjs_menu_nutrition | minitest 5 pass; `gem build` OK |
| Packagist | `bjsmenus/bjs-menu-nutrition` (root composer.json, psr-4 → packages/packagist/src/) | 1.0.0 | https://packagist.org/packages/bjsmenus/bjs-menu-nutrition | `composer validate --strict` OK; phpunit 5 pass |
| Docker Hub | `iamnazzal/bjs-menu-nutrition` | 1.0.0 | https://hub.docker.com/r/iamnazzal/bjs-menu-nutrition | no Docker daemon on the box; daemonless OCI build (amd64 + arm64) OK, not pushed; `node --test` pass |
| HF Space | `iamnazzal/bjs-meal-builder` (sdk: static) | 1.0.0 | https://huggingface.co/spaces/iamnazzal/bjs-meal-builder | static index.html + menu.json; front-matter checked |
| SourceForge | `bjs-menu-nutrition` | 1.0.0 | https://sourceforge.net/projects/bjs-menu-nutrition/ | description + files plan in packages/sourceforge/PROJECT.md |
| Product Hunt | BJ's Meal Builder | – | – | draft in packages/producthunt/LISTING.md |
| Amazon Appstore | BJ's Meal Builder (`com.bjsmenus.bjs_meal_builder`) | 1.0.0 (1) | – | release APK built and signed with a new upload key; listing in AMAZON_APPSTORE_LISTING.md; screenshots in releases/amazon/screenshots/ |
