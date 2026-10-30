'use strict';
const DATA = require('./menu.json');

const NUTRIENTS = ['cal', 'protein', 'carbs', 'fat', 'sodium'];
const UNITS = { cal: 'cal', protein: 'g', carbs: 'g', fat: 'g', sodium: 'mg' };
const ITEMS = DATA.items;

const norm = (s) => String(s).toLowerCase().normalize('NFKD').replace(/[\u2018\u2019']/g, '').replace(/[^a-z0-9]+/g, ' ').trim();

function items() { return ITEMS.slice(); }

function categories() { return [...new Set(ITEMS.map((i) => i.category))]; }

function search(query) {
  const q = norm(query);
  if (!q) return [];
  const words = q.split(' ');
  return ITEMS.filter((i) => { const n = norm(i.name); return words.every((w) => n.includes(w)); });
}

/** Find one item by id, exact name, or a query that matches exactly one item. */
function find(ref) {
  const byId = ITEMS.find((i) => i.id === ref);
  if (byId) return byId;
  const q = norm(ref);
  const exact = ITEMS.filter((i) => norm(i.name) === q);
  if (exact.length) return exact[0];
  const hits = search(ref);
  if (hits.length === 1) return hits[0];
  if (!hits.length) throw new Error(`No menu item matches "${ref}"`);
  throw new Error(`"${ref}" matches ${hits.length} items: ${hits.slice(0, 5).map((h) => h.name).join('; ')}${hits.length > 5 ? '; ...' : ''}`);
}

/** Parse "2x Avocado Egg Rolls" or "Avocado Egg Rolls" into { ref, qty }. */
function parseLine(text) {
  const m = /^\s*(\d+)\s*[x×]\s+(.+)$/i.exec(text);
  return m ? { ref: m[2].trim(), qty: Number(m[1]) } : { ref: String(text).trim(), qty: 1 };
}

/**
 * Total a meal. Lines are item refs or { ref|item, qty }. An item with no published value for a
 * nutrient, or one listed per slice, is not added and is named in `missing`, so the total is partial.
 */
function total(lines) {
  const resolved = lines.map((l) => {
    const o = typeof l === 'string' ? parseLine(l) : l;
    const item = o.item || find(o.ref);
    const qty = o.qty == null ? 1 : Number(o.qty);
    if (!Number.isInteger(qty) || qty < 1 || qty > 99) throw new Error(`Quantity for ${item.name} must be 1-99`);
    return { item, qty };
  });
  const totals = {};
  for (const k of NUTRIENTS) {
    const t = { sum: 0, unit: UNITS[k], missing: [] };
    for (const { item, qty } of resolved) {
      const v = item[k];
      if (v == null || item.perSlice) t.missing.push(item.name); else t.sum += v * qty;
    }
    t.partial = t.missing.length > 0;
    t.listed = resolved.length > 0 && t.missing.length < resolved.length;
    totals[k] = t;
  }
  const allergens = new Set();
  const allergenUnknown = [];
  for (const { item } of resolved) {
    if (item.allergens == null) allergenUnknown.push(item.name); else item.allergens.forEach((a) => allergens.add(a));
  }
  return { lines: resolved, totals, allergens: [...allergens].sort(), allergenUnknown };
}

/** Filter items: { maxCal, minProtein, maxSodium, without: [allergens], role, category }. */
function filter(opts = {}) {
  const without = (opts.without || []).map(norm);
  return ITEMS.filter((i) => {
    if (opts.role && i.role !== opts.role) return false;
    if (opts.category && norm(i.category) !== norm(opts.category)) return false;
    if (opts.maxCal != null && (i.cal == null || i.perSlice || i.cal > opts.maxCal)) return false;
    if (opts.minProtein != null && (i.protein == null || i.protein < opts.minProtein)) return false;
    if (opts.maxSodium != null && (i.sodium == null || i.sodium > opts.maxSodium)) return false;
    if (without.length) {
      if (i.allergens == null) return false; // unknown allergen info is never "safe"
      const have = i.allergens.map(norm);
      if (without.some((w) => have.includes(w))) return false;
    }
    return true;
  });
}

const fmtNum = (n) => Math.round(n).toLocaleString('en-US');

function formatTotal(t) {
  if (!t.listed) return 'Not listed';
  const v = t.unit === 'cal' ? `${fmtNum(t.sum)} cal` : `${fmtNum(t.sum)} ${t.unit}`;
  return t.partial ? `${v}+` : v;
}

module.exports = { items, categories, search, find, parseLine, total, filter, formatTotal, NUTRIENTS, source: DATA.source, updated: DATA.updated };
