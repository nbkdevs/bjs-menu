# Docker Hub listing: iamnazzal/bjs-menu-nutrition

| Field | Value |
|---|---|
| Registry | Docker Hub |
| Name | `iamnazzal/bjs-menu-nutrition` (checked free via hub.docker.com v2 API on 2026-10-30) |
| Version | 1.0.0 |
| Licence | MIT |
| Homepage | https://bjsmenus.com/ |
| Repository | https://github.com/nbkdevs/bjs-menu (directory `packages/docker`) |
| Planned URL | https://hub.docker.com/r/iamnazzal/bjs-menu-nutrition |
| Keywords | OCI labels: image.url = https://bjsmenus.com/ |
| Anchor used | [BJ's menu](https://bjsmenus.com/) (README Links section) |

**Short description:** Offline BJ's Restaurant meal builder: total calories, protein, carbs, fat and sodium for a meal, flag items with no published value, and filter the menu by calories and allergens.

**Long description:** see `README.md`.

**Features:** 183-item menu bundled (132 with published nutrition); quantities (`2x Name`); partial totals marked `+` with the missing items named; meal allergen union with unknowns listed; search; filters for max calories, min protein, max sodium, allergen-free and role; no dependencies.

**Publish (not run, needs the owner's OK):** `cd packages && docker build -f docker/Dockerfile -t iamnazzal/bjs-menu-nutrition:1.0.0 -t iamnazzal/bjs-menu-nutrition:latest . && docker push --all-tags iamnazzal/bjs-menu-nutrition (or daemonless crane push)`

**Dry-run (30 Oct 2026, PKT):** the box has no Docker daemon, so the image was built daemonless with go-containerregistry (`/tmp/ocib`, not pushed): base `node:22-alpine` + one app layer (server.js, public/, npm lib as node_modules/bjs-menu-nutrition), the same config as the Dockerfile (USER node, WORKDIR /app, port 8080, HEALTHCHECK, OCI labels with url https://bjsmenus.com/). amd64 and arm64 images built (~61 MB tar each). The layer's server was started with node and answered `/api/total` and `/`. A real `docker build` was not run.
