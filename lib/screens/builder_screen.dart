import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/picker.dart';
import '../widgets/summary.dart';

class BuilderScreen extends StatelessWidget {
  final Meal meal;
  const BuilderScreen({super.key, required this.meal});

  static const _placeholder = {'main': 'Select a main…', 'side': 'Add a side…', 'drink': 'Add a drink…', 'dessert': 'Add a dessert…'};

  Future<void> _pick(BuildContext context, String role) async {
    final it = await pickItem(context, role, selectedId: role == 'main' ? meal.main : null);
    if (it == null || !context.mounted) return;
    meal.add(it);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(role == 'main' ? '${it.name} set as your main' : 'Added ${it.name}'), duration: const Duration(seconds: 2)));
  }

  void _openSummary(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .9,
        maxChildSize: .95,
        builder: (ctx, scroll) => ScaffoldMessenger(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: MealSummary(
              meal: meal,
              scroll: scroll,
              onChooseMain: () {
                Navigator.pop(ctx);
                _pick(context, 'main');
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: meal,
      builder: (context, _) => Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
            Text('MENU PLANNER', style: eyebrow()),
            const SizedBox(height: 6),
            Text('BJ’s Meal Builder', style: serif(34)),
            const SizedBox(height: 8),
            const Text('Pick a main, add sides, drinks and desserts, and watch your nutrition totals update.',
                style: TextStyle(fontSize: 15, height: 1.4)),
            const SizedBox(height: 18),
            PanelCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Build your meal', style: serif(20)),
                const SizedBox(height: 4),
                const Text('Choose from each list. Your total updates as you pick.', style: TextStyle(fontSize: 13, color: C.muted)),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.45,
                  children: [for (final (i, r) in roles.indexed) _field(context, i + 1, r)],
                ),
                const SizedBox(height: 12),
                const Text('You can add more than one side, drink or dessert.', style: TextStyle(fontSize: 13, color: C.muted)),
              ]),
            ),
            const SizedBox(height: 16),
            PanelCard(accentTop: true, padding: const EdgeInsets.only(top: 18), child: MealSummary(meal: meal, onChooseMain: () => _pick(context, 'main'))),
            const SizedBox(height: 16),
            const _HowItWorks(),
          ]),
        ),
        _bar(context),
      ]),
    );
  }

  Widget _field(BuildContext context, int n, String role) {
    final count = meal.countFor(role);
    final on = count > 0;
    final label = role == 'main' && meal.main != null ? Menu.byId[meal.main]!.name : _placeholder[role]!;
    return Material(
      color: on ? C.redTint : C.field,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _pick(context, role),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: on ? C.red.withValues(alpha: .4) : C.line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 10, backgroundColor: C.ink, child: Text('$n', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700))),
              const SizedBox(width: 6),
              Text(roleLabel[role]!.toUpperCase(), style: eyebrow(c: C.ink)),
              const Spacer(),
              if (on && role != 'main')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: C.red, borderRadius: BorderRadius.circular(99)),
                  child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
            ]),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.line)),
              child: Row(children: [
                Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: C.ink))),
                const Icon(Icons.arrow_drop_down, color: C.muted),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _bar(BuildContext context) {
    final t = meal.totals();
    final cal = meal.isEmpty ? 'No items yet' : meal.fmt(t, 'cal');
    final macros = meal.isEmpty
        ? 'Add a main to start'
        : 'P ${meal.fmt(t, 'pro')} · C ${meal.fmt(t, 'carb')} · F ${meal.fmt(t, 'fat')}';
    return Material(
      color: C.ink,
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: () => _openSummary(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              CircleAvatar(radius: 15, backgroundColor: C.red, child: Text('${meal.count}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(meal.isEmpty ? 'Your meal' : (cal == 'Not listed' ? cal : '$cal cal'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
                  Text(macros, style: const TextStyle(color: Color(0xFFD9D3CC), fontSize: 12.5)),
                ]),
              ),
              const Text('View meal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const Icon(Icons.keyboard_arrow_up, color: Colors.white),
            ]),
          ),
        ),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) => PanelCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: const ExpansionTile(
            title: Text('How the totals work', style: TextStyle(fontWeight: FontWeight.w700, color: C.ink)),
            childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(
                'Nutrition comes from BJ’s published figures for one serving. If an item has no single published number '
                '(for example pizza listed per slice, or a range), the total is shown with a + to mark it as incomplete. '
                'Independent tool, not affiliated with BJ’s Restaurant & Brewhouse.',
                style: TextStyle(fontSize: 13.5, height: 1.45),
              ),
            ],
          ),
        ),
      );
}
