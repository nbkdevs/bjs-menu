import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';

const _sorts = {'menu': 'Menu order', 'cal': 'Lowest calories', 'pro': 'Most protein', 'na': 'Lowest sodium'};

/// Searchable nutrition guide (bjsmenus.com/nutrition) with one-tap "add to meal".
class NutritionScreen extends StatefulWidget {
  final Meal meal;
  const NutritionScreen({super.key, required this.meal});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  String q = '';
  String? cat;
  String sort = 'menu';

  List<MenuItem> get _items {
    var list = Menu.items.where((i) => i.hasNutrition && (cat == null || i.category == cat) && i.name.toLowerCase().contains(q.toLowerCase())).toList();
    if (sort != 'menu') {
      final desc = sort == 'pro';
      list = list.where((i) => i.nut[sort] != null && !i.perSlice).toList()
        ..sort((a, b) => desc ? b.nut[sort]!.compareTo(a.nut[sort]!) : a.nut[sort]!.compareTo(b.nut[sort]!));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return CustomScrollView(slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        sliver: SliverList.list(children: [
          Text('NUTRITION', style: eyebrow()),
          const SizedBox(height: 6),
          Text('BJ’s Menu Nutrition', style: serif(32)),
          const SizedBox(height: 8),
          const Text('Calories, protein, carbohydrates, fat and sodium for BJ’s menu items where BJ’s publishes them.',
              style: TextStyle(fontSize: 15, height: 1.4)),
          const SizedBox(height: 16),
          TextField(
            onChanged: (v) => setState(() => q = v),
            decoration: InputDecoration(
              hintText: 'Search the menu',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: C.card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.line)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.line)),
            ),
          ),
          const SizedBox(height: 10),
        ]),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 40,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
            _chip('All', cat == null, () => setState(() => cat = null)),
            for (final c in Menu.categories()) _chip(c, cat == c, () => setState(() => cat = c)),
          ]),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        sliver: SliverToBoxAdapter(
          child: Row(children: [
            Text('${items.length} items', style: const TextStyle(color: C.muted, fontSize: 13)),
            const Spacer(),
            DropdownButton<String>(
              value: sort,
              underline: const SizedBox(),
              style: const TextStyle(color: C.ink, fontSize: 13, fontWeight: FontWeight.w600),
              items: [for (final e in _sorts.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
              onChanged: (v) => setState(() => sort = v!),
            ),
          ]),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        sliver: SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _card(items[i]),
        ),
      ),
    ]);
  }

  Widget _chip(String label, bool on, VoidCallback tap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: on,
          onSelected: (_) => tap(),
          showCheckmark: false,
          selectedColor: C.red,
          backgroundColor: C.card,
          side: BorderSide(color: on ? C.red : C.line),
          shape: const StadiumBorder(),
          labelStyle: TextStyle(color: on ? Colors.white : C.ink, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      );

  Widget _card(MenuItem it) {
    String v(String k, String unit) => it.nut[k] == null ? '—' : '${fmtNum(it.nut[k]!)}$unit';
    return PanelCard(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: () => _detail(it),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ItemThumb(it.img, it.name, size: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(it.name, style: const TextStyle(fontWeight: FontWeight.w700, color: C.ink, fontSize: 15)),
                Text(it.category, style: const TextStyle(fontSize: 12, color: C.faint)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(it.calTxt ?? (it.cal == null ? '—' : fmtNum(it.cal!)), style: serif(it.calTxt != null && it.calTxt!.length > 6 ? 13 : 20, c: C.red)),
              Text(it.perSlice ? 'cal / slice' : 'cal', style: const TextStyle(fontSize: 11, color: C.muted)),
            ]),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _macro('Protein', v('pro', ' g')),
            _macro('Carbs', v('carb', ' g')),
            _macro('Fat', v('fat', ' g')),
            _macro('Sodium', v('na', ' mg')),
          ]),
        ]),
      ),
    );
  }

  Widget _macro(String label, String value) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(color: C.bgAlt, borderRadius: BorderRadius.circular(8)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 10.5, color: C.muted)),
            FittedBox(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: C.ink, fontSize: 13))),
          ]),
        ),
      );

  void _detail(MenuItem it) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (it.img != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(aspectRatio: 16 / 10, child: Image.network(it.img!, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(color: C.redTint))),
            ),
          const SizedBox(height: 14),
          Text(it.category.toUpperCase(), style: eyebrow()),
          const SizedBox(height: 4),
          Text(it.name, style: serif(24)),
          const SizedBox(height: 6),
          Text('${roleLabel[it.role]} · ${it.calLabel}', style: const TextStyle(color: C.muted)),
          const SizedBox(height: 14),
          Table(
            border: TableBorder(horizontalInside: BorderSide(color: C.line)),
            children: [
              _row('Calories', it.calTxt ?? (it.cal == null ? 'Not listed' : '${fmtNum(it.cal!)}${it.perSlice ? ' per slice' : ''}')),
              _row('Protein', it.nut['pro'] == null ? 'Not listed' : '${it.nut['pro']} g'),
              _row('Carbohydrates', it.nut['carb'] == null ? 'Not listed' : '${it.nut['carb']} g'),
              _row('Fat', it.nut['fat'] == null ? 'Not listed' : '${it.nut['fat']} g'),
              _row('Sodium', it.nut['na'] == null ? 'Not listed' : '${fmtNum(it.nut['na']!)} mg'),
              _row('Allergens', it.allergens ?? 'Not listed'),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: Text(it.role == 'main' ? 'Set as my main' : 'Add to my meal'),
            onPressed: () {
              widget.meal.add(it);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text('Added ${it.name} to your meal'), duration: const Duration(seconds: 2)));
            },
          ),
        ]),
      ),
    );
  }

  TableRow _row(String k, String v) => TableRow(children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(k, style: const TextStyle(color: C.muted))),
        Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600, color: C.ink))),
      ]);
}
