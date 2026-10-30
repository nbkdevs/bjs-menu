import 'dart:io';

import 'package:bjs_menu_nutrition/bjs_menu_nutrition.dart';

const help = '''bjs_menu_nutrition - BJ's Restaurant meal nutrition totals (offline)

Usage:
  dart run bjs_menu_nutrition total "BJ's Wagyu Burger" "2x Avocado Egg Rolls"
  dart run bjs_menu_nutrition search <words>
  dart run bjs_menu_nutrition filter [--max-cal N] [--min-protein N] [--max-sodium N] [--without Milk,Wheat] [--role main|side|drink|dessert]''';

void main(List<String> args) {
  if (args.isEmpty || args.first == '--help' || args.first == '-h') {
    print(help);
    return;
  }
  final rest = args.sublist(1);
  try {
    switch (args.first) {
      case 'total':
        final meal = Meal();
        for (final a in rest) {
          meal.add(a);
        }
        for (final (i, q) in meal.lines) {
          print('$q x ${i.name}');
        }
        print('');
        final totals = meal.totals();
        final missing = <String>{};
        for (final t in totals.values) {
          print('${t.nutrient.label.padRight(9)}${t.format()}');
          missing.addAll(t.missing);
        }
        if (missing.isNotEmpty) print('\n+ partial: no published value (or per-slice only) for ${missing.join('; ')}');
        if (meal.allergens.isNotEmpty) print('Allergens: ${meal.allergens.join(', ')}');
        if (meal.allergenUnknown.isNotEmpty) print('Allergens not listed for: ${meal.allergenUnknown.join('; ')}');
      case 'search':
        search(rest.join(' ')).forEach(print);
      case 'filter':
        String? opt(String n) {
          final i = rest.indexOf(n);
          return i >= 0 && i + 1 < rest.length ? rest[i + 1] : null;
        }
        int? num(String n) => opt(n) == null ? null : int.parse(opt(n)!);
        final role = opt('--role');
        filter(
          maxCal: num('--max-cal'),
          minProtein: num('--min-protein'),
          maxSodium: num('--max-sodium'),
          without: opt('--without')?.split(',') ?? const [],
          role: role == null ? null : Role.values.byName(role),
        ).forEach(print);
      default:
        stderr.writeln('Unknown command "${args.first}"\n\n$help');
        exitCode = 1;
    }
  } on ArgumentError catch (e) {
    stderr.writeln(e.message);
    exitCode = 1;
  }
}
