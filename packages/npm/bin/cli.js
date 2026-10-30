#!/usr/bin/env node
'use strict';
const m = require('../lib');

const HELP = `bjs-menu-nutrition - BJ's Restaurant meal nutrition totals (offline)

Usage:
  bjs-menu-nutrition total "BJ's Wagyu Burger" "2x Avocado Egg Rolls" [--json]
  bjs-menu-nutrition search <words> [--json]
  bjs-menu-nutrition filter [--max-cal N] [--min-protein N] [--max-sodium N]
                            [--without Milk,Wheat] [--role main|side|drink|dessert] [--json]
  bjs-menu-nutrition categories
`;

const args = process.argv.slice(2);
const json = args.includes('--json');
const rest = args.filter((a) => a !== '--json');
const cmd = rest.shift();
const opt = (name) => { const i = rest.indexOf(name); return i >= 0 ? rest[i + 1] : undefined; };
const out = (o) => console.log(JSON.stringify(o, null, 2));
const row = (i) => `${i.name} (${i.category}) - ${i.calText ? i.calText + ' cal' : i.cal != null ? i.cal + ' cal' : 'calories not listed'}`;

try {
  if (!cmd || cmd === '-h' || cmd === '--help') { console.log(HELP); process.exit(0); }
  if (cmd === 'total') {
    if (!rest.length) throw new Error('Give at least one item');
    const r = m.total(rest);
    if (json) out({ items: r.lines.map((l) => ({ name: l.item.name, qty: l.qty })), totals: r.totals, allergens: r.allergens, allergenUnknown: r.allergenUnknown });
    else {
      r.lines.forEach((l) => console.log(`${l.qty} x ${l.item.name}`));
      console.log('');
      const label = { cal: 'Calories', protein: 'Protein', carbs: 'Carbs', fat: 'Fat', sodium: 'Sodium' };
      for (const k of m.NUTRIENTS) console.log(`${label[k].padEnd(9)}${m.formatTotal(r.totals[k])}`);
      const miss = [...new Set(m.NUTRIENTS.flatMap((k) => r.totals[k].missing))];
      if (miss.length) console.log(`\n+ partial: no published value (or per-slice only) for ${miss.join('; ')}`);
      if (r.allergens.length) console.log(`Allergens: ${r.allergens.join(', ')}`);
      if (r.allergenUnknown.length) console.log(`Allergens not listed for: ${r.allergenUnknown.join('; ')}`);
    }
  } else if (cmd === 'search') {
    const r = m.search(rest.join(' '));
    json ? out(r) : r.forEach((i) => console.log(row(i)));
  } else if (cmd === 'filter') {
    const num = (n) => (opt(n) == null ? undefined : Number(opt(n)));
    const r = m.filter({ maxCal: num('--max-cal'), minProtein: num('--min-protein'), maxSodium: num('--max-sodium'), without: opt('--without') ? opt('--without').split(',') : [], role: opt('--role') });
    json ? out(r) : r.forEach((i) => console.log(row(i)));
  } else if (cmd === 'categories') {
    m.categories().forEach((c) => console.log(c));
  } else throw new Error(`Unknown command "${cmd}"\n\n${HELP}`);
} catch (e) { console.error(e.message); process.exit(1); }
