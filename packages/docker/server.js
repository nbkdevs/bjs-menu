'use strict';
// Tiny offline API + page for BJ's Restaurant meal nutrition totals.
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
let m;
try { m = require('bjs-menu-nutrition'); } catch { m = require('../npm/lib'); } // repo checkout fallback

const PAGE = fs.readFileSync(path.join(__dirname, 'public', 'index.html'));

function handle(req, res) {
  const url = new URL(req.url, 'http://x');
  const send = (code, body) => {
    res.writeHead(code, { 'content-type': 'application/json; charset=utf-8', 'access-control-allow-origin': '*' });
    res.end(JSON.stringify(body, null, 2));
  };
  try {
    if (url.pathname === '/healthz') return send(200, { ok: true });
    if (url.pathname === '/' || url.pathname === '/index.html') {
      res.writeHead(200, { 'content-type': 'text/html; charset=utf-8' });
      return res.end(PAGE);
    }
    if (url.pathname === '/menu.json') return send(200, { items: m.items() });
    if (url.pathname === '/api/items') return send(200, m.items());
    if (url.pathname === '/api/search') return send(200, m.search(url.searchParams.get('q') || ''));
    if (url.pathname === '/api/total') {
      const lines = url.searchParams.getAll('item');
      if (!lines.length) return send(400, { error: 'Add one or more ?item= parameters, e.g. ?item=2x Boneless Wings' });
      const r = m.total(lines);
      return send(200, { items: r.lines.map((l) => ({ id: l.item.id, name: l.item.name, qty: l.qty })), totals: r.totals, display: Object.fromEntries(m.NUTRIENTS.map((k) => [k, m.formatTotal(r.totals[k])])), allergens: r.allergens, allergenUnknown: r.allergenUnknown });
    }
    if (url.pathname === '/api/filter') {
      const n = (k) => (url.searchParams.has(k) ? Number(url.searchParams.get(k)) : undefined);
      return send(200, m.filter({ maxCal: n('maxCal'), minProtein: n('minProtein'), maxSodium: n('maxSodium'), without: (url.searchParams.get('without') || '').split(',').filter(Boolean), role: url.searchParams.get('role') || undefined }));
    }
    return send(404, { error: 'Not found. Try /api/total?item=BJ%27s%20Wagyu%20Burger' });
  } catch (e) { return send(400, { error: e.message }); }
}

if (require.main === module) {
  const port = Number(process.env.PORT || 8080);
  http.createServer(handle).listen(port, () => console.log(`bjs-menu-nutrition listening on :${port}`));
}
module.exports = { handle };
