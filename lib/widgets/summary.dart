import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import 'picker.dart';

/// "Your meal" panel: line items, totals, allergens. Rebuilds whenever [meal] changes.
class MealSummary extends StatelessWidget {
  final Meal meal;
  final VoidCallback onChooseMain;
  /// When null the summary lays out inline (inside another scroll view) instead of scrolling itself.
  final ScrollController? scroll;
  const MealSummary({super.key, required this.meal, required this.onChooseMain, this.scroll});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: meal,
      builder: (context, _) {
        final children = meal.isEmpty ? [_empty()] : _filled(context);
        final all = [Text('YOUR MEAL', style: eyebrow(c: C.ink)), const SizedBox(height: 14), ...children];
        const pad = EdgeInsets.fromLTRB(20, 0, 20, 24);
        if (scroll == null) {
          return Padding(padding: pad, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: all));
        }
        return ListView(controller: scroll, padding: pad, children: all);
      },
    );
  }

  Widget _empty() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(color: C.redTint, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Text('✦', style: TextStyle(color: C.red, fontSize: 22)),
          ),
          const SizedBox(height: 16),
          Text('Build your BJ’s meal', style: serif(22)),
          const SizedBox(height: 6),
          const Text('Choose a main dish to get started.'),
          const SizedBox(height: 18),
          FilledButton(onPressed: onChooseMain, child: const Text('Choose a main')),
        ]),
      );

  List<Widget> _filled(BuildContext context) {
    final t = meal.totals();
    final partial = t.values.where((x) => x.missing.isNotEmpty).expand((x) => x.missing).toSet();
    return [
      for (final l in meal.lines) _line(context, l),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: C.bgAlt, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Your total', style: serif(18)),
          const SizedBox(height: 12),
          _big('Total calories', meal.fmt(t, 'cal'), C.red),
          const SizedBox(height: 12),
          Row(children: [
            for (final (n, k) in [('Protein', 'pro'), ('Carbs', 'carb'), ('Fat', 'fat'), ('Sodium', 'na')])
              Expanded(child: _cell(n, meal.fmt(t, k))),
          ]),
          if (partial.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Totals marked + are incomplete. No single published number to add for: ${partial.join(', ')}.',
                style: const TextStyle(fontSize: 12.5, color: C.muted)),
          ],
        ]),
      ),
      const SizedBox(height: 16),
      _allergens(),
      const SizedBox(height: 16),
      OutlinedButton(
        onPressed: () {
          final snap = meal.clear();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: const Text('Meal cleared'),
              action: SnackBarAction(label: 'Undo', onPressed: () => meal.restoreSnapshot(snap)),
            ));
        },
        child: const Text('Clear meal'),
      ),
    ];
  }

  Widget _big(String label, String value, Color c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: C.muted)),
        Text(value, style: serif(26, c: c)),
      ]);

  Widget _cell(String label, String value) => Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: C.muted)),
          FittedBox(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: C.ink))),
        ]),
      );

  Widget _line(BuildContext context, Line l) {
    final it = l.item;
    final isMain = !meal.extras.contains(l);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ItemThumb(it.img, it.name, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(roleLabel[l.role]!.toUpperCase(), style: eyebrow()),
              Text(it.name, style: const TextStyle(fontWeight: FontWeight.w700, color: C.ink, fontSize: 15)),
            ]),
          ),
          Text(it.calTxt ?? (it.cal == null ? '—' : fmtNum(it.cal! * l.qty)), style: serif(18, c: C.red)),
        ]),
        const SizedBox(height: 8),
        Text(it.nutLine, style: const TextStyle(fontSize: 13, color: C.muted)),
        if (it.fries)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text('BJ’s nutrition for this item includes fries. Adding another side counts on top of that.',
                style: TextStyle(fontSize: 12, color: C.redDark)),
          ),
        const SizedBox(height: 8),
        Row(children: [
          if (!isMain)
            Container(
              decoration: BoxDecoration(border: Border.all(color: C.lineStrong), borderRadius: BorderRadius.circular(99)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.remove, size: 18), onPressed: () => meal.dec(l), tooltip: 'Decrease'),
                Text('${l.qty}', style: const TextStyle(fontWeight: FontWeight.w700, color: C.ink)),
                IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.add, size: 18), onPressed: l.qty < 9 ? () => meal.inc(l) : null, tooltip: 'Increase'),
              ]),
            ),
          const Spacer(),
          TextButton(
            onPressed: () async {
              final to = await pickItem(context, l.role, selectedId: l.id);
              if (to != null) meal.swap(l, to);
            },
            child: Text(l.role == 'side' ? 'Swap' : 'Change'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: C.muted),
            onPressed: () => meal.remove(l),
            child: const Text('Remove'),
          ),
        ]),
      ]),
    );
  }

  Widget _allergens() {
    final set = <String>{}, none = <String>{}, unk = <String>{};
    final listed = <MenuItem>[];
    for (final l in meal.lines) {
      final it = l.item, a = (it.allergens ?? '').trim();
      if (a.isEmpty) {
        unk.add(it.name);
      } else if (a.startsWith(none9)) {
        none.add(it.name);
      } else {
        set.addAll(a.split(',').map((x) => x.trim()));
        if (!listed.contains(it)) listed.add(it);
      }
    }
    const small = TextStyle(fontSize: 13, height: 1.4);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Allergens', style: serif(18)),
      const SizedBox(height: 8),
      if (set.isNotEmpty) ...[
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final a in set.toList()..sort())
            Chip(label: Text(a), visualDensity: VisualDensity.compact, backgroundColor: C.redTint, side: BorderSide.none, labelStyle: const TextStyle(fontSize: 12, color: C.redDark)),
        ]),
        const SizedBox(height: 8),
        for (final it in listed)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text.rich(TextSpan(style: small, children: [TextSpan(text: '${it.name}: ', style: const TextStyle(fontWeight: FontWeight.w700)), TextSpan(text: it.allergens)])),
          ),
      ],
      if (none.isNotEmpty) Text('BJ’s lists none of the nine major allergens it tracks for: ${none.join(', ')}.', style: small),
      if (unk.isNotEmpty) Text('No allergen information is listed for: ${unk.join(', ')}. Ask your restaurant.', style: small),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFFFF4E0), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x33B7791F))),
        child: const Text(
          'BJ’s states that it cannot guarantee any menu item is completely allergen free, because its kitchens use shared preparation areas, utensils and fryers. Confirm with your restaurant. This app makes no allergen-free or celiac-safe claim.',
          style: TextStyle(fontSize: 12.5, height: 1.4),
        ),
      ),
    ]);
  }
}
