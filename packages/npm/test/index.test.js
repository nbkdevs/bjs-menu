'use strict';
const test = require('node:test');
const assert = require('node:assert');
const m = require('../lib');

test('dataset loads', () => { assert.strictEqual(m.items().length, 183); });
test('find by name and id', () => {
  assert.strictEqual(m.find("bj's wagyu burger").id, 'bjs-0003');
  assert.strictEqual(m.find('bjs-0005').name, 'Avocado Egg Rolls');
});
test('ambiguous query throws', () => { assert.throws(() => m.find('burger'), /matches/); });
test('totals add quantities', () => {
  const r = m.total(["BJ's Wagyu Burger", '2x Avocado Egg Rolls']);
  assert.strictEqual(r.totals.cal.sum, 1230 + 2 * 990);
  assert.strictEqual(r.totals.cal.partial, false);
  assert.strictEqual(m.formatTotal(r.totals.cal), '3,210 cal');
  assert.ok(r.allergens.includes('Wheat'));
});
test('per-slice items make the total partial', () => {
  const r = m.total(["BJ's Wagyu Burger", 'California Club Flatbread']);
  assert.strictEqual(r.totals.cal.sum, 1230);
  assert.deepStrictEqual(r.totals.cal.missing, ['California Club Flatbread']);
  assert.strictEqual(m.formatTotal(r.totals.cal), '1,230 cal+');
});
test('filter excludes allergens and unknown allergen info', () => {
  const r = m.filter({ without: ['milk'], maxCal: 500 });
  assert.ok(r.length > 0);
  for (const i of r) { assert.ok(i.allergens && !i.allergens.includes('Milk')); assert.ok(i.cal <= 500); }
});
test('bad quantity rejected', () => { assert.throws(() => m.total([{ ref: 'bjs-0003', qty: 0 }])); });
