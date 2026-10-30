# iamnazzal/bjs-menu-nutrition

A tiny offline web app and JSON API for BJ's Restaurant meal nutrition totals. Pick dishes in the browser page, or call the API to total calories, protein, carbs, fat and sodium for a meal. Items with no published value are flagged with `+`, never guessed. No outbound network calls; the 183-item menu is baked into the image.

## Run

```sh
docker run --rm -p 8080:8080 iamnazzal/bjs-menu-nutrition
# open http://localhost:8080/
```

## API

| Endpoint | Example |
|---|---|
| `GET /api/total?item=...` (repeat) | `/api/total?item=BJ%27s%20Wagyu%20Burger&item=2x%20Avocado%20Egg%20Rolls` → `"cal": "3,210 cal"` |
| `GET /api/search?q=` | `/api/search?q=pizookie` |
| `GET /api/filter?maxCal=&minProtein=&maxSodium=&without=&role=` | `/api/filter?maxCal=600&without=Milk&role=main` |
| `GET /api/items` | the full menu |
| `GET /healthz` | health check |

Runs as the non-root `node` user on port 8080 (`PORT` to change). Image: `node:22-alpine`, about 50 MB.

## Build

```sh
cd packages && docker build -f docker/Dockerfile -t iamnazzal/bjs-menu-nutrition:1.0.0 .
```

## Links

- Full menu with prices, photos and per-item nutrition: [BJ's menu](https://bjsmenus.com/)
- Source: https://github.com/nbkdevs/bjs-menu

Unofficial; not affiliated with BJ's Restaurants, Inc. MIT licence.
