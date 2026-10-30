/// Offline BJ's Restaurant meal builder: nutrition totals, missing-value flags,
/// search and calorie/allergen filters. Data collected by https://bjsmenus.com/.
library;

import 'src/data.dart';
import 'src/models.dart';

export 'src/models.dart';

/// All menu items.
List<MenuItem> get items => menuItems;

String _norm(String s) => s
    .toLowerCase()
    .replaceAll(RegExp("['\u2018\u2019]"), '')
    .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
    .trim();

/// Items whose name contains every word of [query].
List<MenuItem> search(String query) {
  final q = _norm(query);
  if (q.isEmpty) return [];
  final words = q.split(' ');
  return menuItems.where((i) {
    final n = _norm(i.name);
    return words.every(n.contains);
  }).toList();
}

/// Find one item by id, exact name, or a query that matches exactly one item.
MenuItem find(String ref) {
  for (final i in menuItems) {
    if (i.id == ref) return i;
  }
  final q = _norm(ref);
  for (final i in menuItems) {
    if (_norm(i.name) == q) return i;
  }
  final hits = search(ref);
  if (hits.length == 1) return hits.first;
  if (hits.isEmpty) throw ArgumentError('No menu item matches "$ref"');
  throw ArgumentError('"$ref" matches ${hits.length} items: ${hits.take(5).map((h) => h.name).join('; ')}');
}

/// Parse "2x Avocado Egg Rolls" into (ref, qty).
(String, int) parseLine(String text) {
  final m = RegExp(r'^\s*(\d+)\s*[xX\u00d7]\s+(.+)$').firstMatch(text);
  return m == null ? (text.trim(), 1) : (m.group(2)!.trim(), int.parse(m.group(1)!));
}

/// Total for one nutrient.
class Total {
  Total(this.nutrient, this.lines);
  final Nutrient nutrient;
  final int lines;
  int sum = 0;
  final List<String> missing = [];
  bool get partial => missing.isNotEmpty;
  bool get listed => lines > 0 && missing.length < lines;

  /// "3,210 cal", "68 g+", or "Not listed".
  String format() {
    if (!listed) return 'Not listed';
    final n = sum.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '$n ${nutrient.unit}${partial ? '+' : ''}';
  }
}

/// A meal of menu items with quantities.
class Meal {
  final List<(MenuItem, int)> lines = [];

  /// Add "2x Name", an id or a name. Quantity 1-99.
  Meal add(String line) {
    final (ref, qty) = parseLine(line);
    final item = find(ref);
    if (qty < 1 || qty > 99) throw ArgumentError('Quantity for ${item.name} must be 1-99');
    lines.add((item, qty));
    return this;
  }

  /// Items with no published value, or listed per slice, are not added and are named in `missing`.
  Map<Nutrient, Total> totals() {
    final out = <Nutrient, Total>{};
    for (final n in Nutrient.values) {
      final t = Total(n, lines.length);
      for (final (item, qty) in lines) {
        final v = item.value(n);
        if (v == null || item.perSlice) {
          t.missing.add(item.name);
        } else {
          t.sum += v * qty;
        }
      }
      out[n] = t;
    }
    return out;
  }

  /// Sorted union of listed allergens.
  List<String> get allergens => ({for (final (i, _) in lines) ...?i.allergens}.toList()..sort());

  /// Items with no allergen information.
  List<String> get allergenUnknown => [for (final (i, _) in lines) if (i.allergens == null) i.name];
}

/// Items matching every limit. Unknown allergen info never passes a [without] filter.
List<MenuItem> filter({int? maxCal, int? minProtein, int? maxSodium, List<String> without = const [], Role? role}) {
  final wo = without.map(_norm).toList();
  return menuItems.where((i) {
    if (role != null && i.role != role) return false;
    if (maxCal != null && (i.cal == null || i.perSlice || i.cal! > maxCal)) return false;
    if (minProtein != null && (i.protein == null || i.protein! < minProtein)) return false;
    if (maxSodium != null && (i.sodium == null || i.sodium! > maxSodium)) return false;
    if (wo.isNotEmpty) {
      if (i.allergens == null) return false;
      if (i.allergens!.any((a) => wo.contains(_norm(a)))) return false;
    }
    return true;
  }).toList();
}
