FROM node:22-alpine
LABEL org.opencontainers.image.title="bjs-menu-nutrition" \
      org.opencontainers.image.description="BJ's Restaurant meal builder: nutrition totals API and page (offline)" \
      org.opencontainers.image.source="https://github.com/nbkdevs/bjs-menu" \
      org.opencontainers.image.url="https://bjsmenus.com/" \
      org.opencontainers.image.documentation="https://bjsmenus.com/" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.vendor="BJ's Menus"
WORKDIR /app
# Build context: packages/ (so the npm library is copied in, not downloaded)
COPY npm/package.json npm/README.md npm/LICENSE ./node_modules/bjs-menu-nutrition/
COPY npm/lib ./node_modules/bjs-menu-nutrition/lib
COPY docker/server.js ./
COPY docker/public ./public
ENV NODE_ENV=production PORT=8080
USER node
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1
CMD ["node", "server.js"]
