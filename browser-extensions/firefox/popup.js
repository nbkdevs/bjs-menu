const STORAGE_KEY = 'platePlanMeal';
const ROLE_LABEL = { main: 'Main', side: 'Side', drink: 'Drink', dessert: 'Dessert' };

let ITEMS = [];
let byId = {};
let meal = { main: null, extras: [] }; // extras: [{id, qty}]
let pickRole = 'main';
let searchQ = '';

const $ = (s) => document.querySelector(s);
const fmt = (n) => Number(n).toLocaleString('en-US');

async function loadItems() {
  const res = await fetch(chrome.runtime.getURL('data/items.json'));
  ITEMS = await res.json();
  byId = Object.fromEntries(ITEMS.map((i) => [i.id, i]));
}

async function restore() {
  try {
    const data = await chrome.storage.local.get(STORAGE_KEY);
    const s = data[STORAGE_KEY];
    if (!s) return;
    meal.main = s.main && byId[s.main] ? s.main : null;
    meal.extras = (s.extras || [])
      .filter((e) => byId[e.id])
      .map((e) => ({ id: e.id, qty: Math.min(9, Math.max(1, e.qty | 0 || 1)) }));
  } catch (_) {}
}

function save() {
  chrome.storage.local.set({ [STORAGE_KEY]: meal });
}

function lines() {
  const L = [];
  if (meal.main) L.push({ key: 'm', id: meal.main, qty: 1, role: 'main' });
  meal.extras.forEach((e, i) => L.push({ key: 'e' + i, id: e.id, qty: e.qty, role: byId[e.id].role, idx: i }));
  return L;
}

function calLabel(it) {
  if (it.calTxt) return it.calTxt + ' cal';
  if (it.cal != null) return fmt(it.cal) + ' cal' + (it.flag === 'slice' ? ' / slice' : '');
  return 'calories not listed';
}

function nutLine(it) {
  if (it.flag === 'slice') return calLabel(it) + ' · not added to totals';
  const bits = [it.calTxt ? 'Calories: ' + it.calTxt : it.cal != null ? fmt(it.cal) + ' cal' : 'Calories not listed'];
  if (it.pro != null) bits.push(it.pro + ' g protein');
  if (it.carb != null) bits.push(it.carb + ' g carbs');
  if (it.fat != null) bits.push(it.fat + ' g fat');
  if (it.na != null) bits.push(fmt(it.na) + ' mg sodium');
  return bits.join(' · ');
}

function addItem(it) {
  if (it.role === 'main' || pickRole === 'main') {
    meal.main = it.id;
  } else {
    const ex = meal.extras.find((e) => e.id === it.id);
    if (ex && ex.qty < 9) ex.qty++;
    else if (!ex) meal.extras.push({ id: it.id, qty: 1 });
  }
  save();
  renderAll();
}

function totals() {
  const keys = ['cal', 'pro', 'carb', 'fat', 'na'];
  const T = Object.fromEntries(keys.map((k) => [k, { sum: 0, miss: [] }]));
  for (const l of lines()) {
    const it = byId[l.id];
    for (const k of keys) {
      if (it[k] == null || it.flag === 'slice') T[k].miss.push(it.n);
      else T[k].sum += it[k] * l.qty;
    }
  }
  return T;
}

function fmtTotal(T, k) {
  const t = T[k];
  const n = lines().length;
  if (n > 0 && t.miss.length === n) return 'Not listed';
  const unit = { pro: ' g', carb: ' g', fat: ' g', na: ' mg' }[k] || '';
  const v = fmt(t.sum) + unit;
  return t.miss.length ? v + '+' : v;
}

function renderTabs() {
  document.querySelectorAll('.tab').forEach((b) => {
    b.classList.toggle('on', b.dataset.tab === document.body.dataset.tab);
  });
  document.querySelectorAll('.panel').forEach((p) => {
    p.classList.toggle('on', p.id === 'panel-' + document.body.dataset.tab);
  });
}

function renderBuilder() {
  document.querySelectorAll('.role').forEach((b) => {
    b.classList.toggle('active-pick', b.dataset.role === pickRole);
    const count =
      b.dataset.role === 'main'
        ? meal.main
          ? 1
          : 0
        : meal.extras.filter((e) => byId[e.id].role === b.dataset.role).reduce((s, e) => s + e.qty, 0);
    b.classList.toggle('on', count > 0);
  });

  const items = ITEMS.filter((i) => i.role === pickRole).sort((a, b) => a.n.localeCompare(b.n));
  const groups = {};
  items.forEach((i) => (groups[i.c] = groups[i.c] || []).push(i));
  const host = $('#builderList');
  host.innerHTML = '';
  Object.keys(groups)
    .sort()
    .forEach((c) => {
      const h = document.createElement('div');
      h.className = 'cat';
      h.textContent = c.toUpperCase();
      host.appendChild(h);
      groups[c].forEach((it) => host.appendChild(itemCard(it, pickRole === 'main' ? 'Set as main' : 'Add')));
    });
}

function itemCard(it, label) {
  const el = document.createElement('div');
  el.className = 'item';
  el.innerHTML = `<div><strong></strong><small></small></div><div class="cal"></div>`;
  el.querySelector('strong').textContent = it.n;
  el.querySelector('small').textContent = (ROLE_LABEL[it.role] || it.role) + ' · ' + calLabel(it);
  el.querySelector('.cal').textContent = it.calTxt || (it.cal != null ? fmt(it.cal) : '—');
  const btn = document.createElement('button');
  btn.type = 'button';
  btn.textContent = label;
  btn.addEventListener('click', () => addItem(it));
  el.appendChild(btn);
  return el;
}

function renderNutrition() {
  const q = searchQ.trim().toLowerCase();
  const items = ITEMS.filter((i) => !q || i.n.toLowerCase().includes(q) || i.c.toLowerCase().includes(q)).slice(0, 80);
  const host = $('#nutritionList');
  host.innerHTML = '';
  if (!items.length) {
    host.innerHTML = '<div class="empty">No matches.</div>';
    return;
  }
  items.forEach((it) => host.appendChild(itemCard(it, it.role === 'main' ? 'Set as main' : 'Add to meal')));
}

function renderMeal() {
  const L = lines();
  $('#mealCount').textContent = String(L.reduce((s, l) => s + l.qty, 0));
  const empty = $('#mealEmpty');
  const linesEl = $('#mealLines');
  const totalsEl = $('#mealTotals');
  if (!L.length) {
    empty.classList.remove('hidden');
    linesEl.innerHTML = '';
    totalsEl.classList.add('hidden');
    return;
  }
  empty.classList.add('hidden');
  totalsEl.classList.remove('hidden');
  linesEl.innerHTML = '';
  L.forEach((l) => {
    const it = byId[l.id];
    const row = document.createElement('div');
    row.className = 'line';
    row.innerHTML = `<div class="role-l"></div><div class="name"></div><div class="nut"></div><div class="acts"></div>`;
    row.querySelector('.role-l').textContent = ROLE_LABEL[l.role].toUpperCase();
    row.querySelector('.name').textContent = it.n + (l.qty > 1 ? ` ×${l.qty}` : '');
    row.querySelector('.nut').textContent = nutLine(it);
    const acts = row.querySelector('.acts');
    if (l.key !== 'm') {
      const dec = document.createElement('button');
      dec.type = 'button';
      dec.textContent = '−';
      dec.addEventListener('click', () => {
        const x = meal.extras[l.idx];
        if (x.qty > 1) x.qty--;
        else meal.extras.splice(l.idx, 1);
        save();
        renderAll();
      });
      const inc = document.createElement('button');
      inc.type = 'button';
      inc.textContent = '+';
      inc.addEventListener('click', () => {
        if (meal.extras[l.idx].qty < 9) meal.extras[l.idx].qty++;
        save();
        renderAll();
      });
      acts.append(dec, inc);
    }
    const rm = document.createElement('button');
    rm.type = 'button';
    rm.textContent = 'Remove';
    rm.addEventListener('click', () => {
      if (l.key === 'm') meal.main = null;
      else meal.extras.splice(l.idx, 1);
      save();
      renderAll();
    });
    acts.appendChild(rm);
    linesEl.appendChild(row);
  });

  const T = totals();
  $('#totalCal').textContent = fmtTotal(T, 'cal') === 'Not listed' ? 'Not listed' : fmtTotal(T, 'cal') + ' cal';
  $('#totalPro').textContent = fmtTotal(T, 'pro');
  $('#totalCarb').textContent = fmtTotal(T, 'carb');
  $('#totalFat').textContent = fmtTotal(T, 'fat');
  $('#totalNa').textContent = fmtTotal(T, 'na');
  const miss = [...new Set(['cal', 'pro', 'carb', 'fat', 'na'].flatMap((k) => T[k].miss))];
  const note = $('#partialNote');
  if (miss.length) {
    note.classList.remove('hidden');
    note.textContent = 'Totals marked + are incomplete for: ' + miss.join(', ') + '.';
  } else note.classList.add('hidden');
}

function renderAll() {
  renderTabs();
  renderBuilder();
  renderNutrition();
  renderMeal();
}

document.querySelectorAll('.tab').forEach((b) =>
  b.addEventListener('click', () => {
    document.body.dataset.tab = b.dataset.tab;
    renderAll();
  }),
);
document.querySelectorAll('.role').forEach((b) =>
  b.addEventListener('click', () => {
    pickRole = b.dataset.role;
    document.body.dataset.tab = 'builder';
    renderAll();
  }),
);
$('#search').addEventListener('input', (e) => {
  searchQ = e.target.value;
  renderNutrition();
});
$('#clearMeal').addEventListener('click', () => {
  meal = { main: null, extras: [] };
  save();
  renderAll();
});

(async function init() {
  document.body.dataset.tab = 'builder';
  await loadItems();
  await restore();
  renderAll();
})();
