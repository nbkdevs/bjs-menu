'use strict';
const test = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
const { handle } = require('../server');

function get(server, p) {
  return new Promise((resolve) => http.get({ port: server.address().port, path: p }, (res) => {
    let b = ''; res.on('data', (c) => (b += c)); res.on('end', () => resolve({ code: res.statusCode, body: b }));
  }));
}

test('api', async () => {
  const s = http.createServer(handle).listen(0);
  const r = await get(s, '/api/total?item=' + encodeURIComponent("BJ's Wagyu Burger") + '&item=' + encodeURIComponent('2x Avocado Egg Rolls'));
  assert.strictEqual(r.code, 200);
  assert.strictEqual(JSON.parse(r.body).display.cal, '3,210 cal');
  assert.strictEqual((await get(s, '/healthz')).code, 200);
  assert.strictEqual((await get(s, '/api/total?item=burger')).code, 400);
  s.close();
});
