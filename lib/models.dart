import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const none9 = 'None of the 9';
const roles = ['main', 'side', 'drink', 'dessert'];
const roleLabel = {'main': 'Main', 'side': 'Side', 'drink': 'Drink', 'dessert': 'Dessert'};
const rolePlural = {'main': 'Mains', 'side': 'Sides', 'drink': 'Drinks', 'dessert': 'Desserts'};
const nutKeys = ['cal', 'pro', 'carb', 'fat', 'na'];

class MenuItem {
  final String id, name, category, role;
  final String? img, allergens, calTxt, flag;
  final bool fries;
  final Map<String, int?> nut;

  MenuItem.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        name = j['n'],
        category = j['c'],
        role = j['role'],
        img = j['img'],
        allergens = j['al'],
        calTxt = j['calTxt'],
        flag = j['flag'],
        fries = j['fries'] == 1,
        nut = {for (final k in nutKeys) k: (j[k] as num?)?.round()};

  bool get perSlice => flag == 'slice';
  int? get cal => nut['cal'];
  bool get hasNutrition => nut.values.any((v) => v != null) || calTxt != null;

  String get calLabel {
    if (calTxt != null) return '$calTxt cal';
    if (cal != null) return '${fmtNum(cal!)} cal${perSlice ? ' per slice' : ''}';
    return 'calories not listed';
  }

  String get nutLine {
    final bits = <String>[calTxt != null ? 'Calories: $calTxt' : (cal != null ? '${fmtNum(cal!)} cal' : 'Calories not listed')];
    if (perSlice) return '${bits.first}. Listed per slice or square, so it is not added to totals';
    if (nut['pro'] != null) bits.add('${nut['pro']} g protein');
    if (nut['carb'] != null) bits.add('${nut['carb']} g carbs');
    if (nut['fat'] != null) bits.add('${nut['fat']} g fat');
    if (nut['na'] != null) bits.add('${fmtNum(nut['na']!)} mg sodium');
    return bits.join(' · ');
  }
}

String fmtNum(num n) => n.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

class Menu {
  static late List<MenuItem> items;
  static late Map<String, MenuItem> byId;

  static Future<void> load() async {
    final raw = jsonDecode(await rootBundle.loadString('assets/data/items.json')) as List;
    items = raw.map((e) => MenuItem.fromJson(e)).toList();
    byId = {for (final i in items) i.id: i};
  }

  static List<String> categories() {
    final seen = <String>[];
    for (final i in items) {
      if (!seen.contains(i.category)) seen.add(i.category);
    }
    return seen;
  }
}

class Line {
  final String id;
  final String role;
  int qty;
  Line(this.id, this.role, [this.qty = 1]);
  MenuItem get item => Menu.byId[id]!;
}

class Total {
  num sum = 0;
  final List<String> missing = [];
}

/// Mirrors the site's meal state: one main plus any number of extras (qty 1–9).
class Meal extends ChangeNotifier {
  static const _key = 'bjsMeal';
  String? main;
  List<Line> extras = [];

  List<Line> get lines => [if (main != null) Line(main!, 'main'), ...extras];
  bool get isEmpty => main == null && extras.isEmpty;
  int get count => lines.fold(0, (s, l) => s + l.qty);

  int countFor(String role) => role == 'main' ? (main == null ? 0 : 1) : extras.where((e) => e.role == role).fold(0, (s, e) => s + e.qty);

  Future<void> restore() async {
    try {
      final p = await SharedPreferences.getInstance();
      final s = jsonDecode(p.getString(_key) ?? 'null');
      if (s == null) return;
      main = Menu.byId.containsKey(s['main']) ? s['main'] : null;
      extras = [
        for (final e in (s['extras'] as List? ?? []))
          if (Menu.byId.containsKey(e['id'])) Line(e['id'], Menu.byId[e['id']]!.role, (e['qty'] as int).clamp(1, 9)),
      ];
      notifyListeners();
    } catch (_) {}
  }

  String _encode() => jsonEncode({
        'main': main,
        'extras': [for (final e in extras) {'id': e.id, 'qty': e.qty}],
      });

  void _changed() {
    notifyListeners();
    final s = _encode();
    SharedPreferences.getInstance().then((p) => p.setString(_key, s));
  }

  void add(MenuItem it) {
    if (it.role == 'main') {
      main = it.id;
    } else {
      final ex = extras.where((e) => e.id == it.id).firstOrNull;
      if (ex == null) {
        extras.add(Line(it.id, it.role));
      } else if (ex.qty < 9) {
        ex.qty++;
      }
    }
    _changed();
  }

  void inc(Line l) {
    if (l.qty < 9) l.qty++;
    _changed();
  }

  void dec(Line l) {
    if (l.qty > 1) {
      l.qty--;
    } else {
      extras.remove(l);
    }
    _changed();
  }

  void remove(Line l) {
    if (!extras.remove(l)) main = null;
    _changed();
  }

  void swap(Line l, MenuItem to) {
    if (!extras.contains(l)) {
      main = to.id;
    } else {
      final i = extras.indexOf(l);
      extras[i] = Line(to.id, to.role, l.qty);
    }
    _changed();
  }

  /// Returns a snapshot that [restoreSnapshot] can bring back (for Undo).
  String clear() {
    final snap = _encode();
    main = null;
    extras = [];
    _changed();
    return snap;
  }

  void restoreSnapshot(String snap) {
    final s = jsonDecode(snap);
    main = s['main'];
    extras = [for (final e in s['extras']) Line(e['id'], Menu.byId[e['id']]!.role, e['qty'])];
    _changed();
  }

  /// Same rules as the site: items with no number, or per-slice nutrition, make a total partial ("+").
  Map<String, Total> totals() {
    final t = {for (final k in nutKeys) k: Total()};
    for (final l in lines) {
      final it = l.item;
      for (final k in nutKeys) {
        final v = it.nut[k];
        if (v == null || it.perSlice) {
          t[k]!.missing.add(it.name);
        } else {
          t[k]!.sum += v * l.qty;
        }
      }
    }
    return t;
  }

  String fmt(Map<String, Total> t, String k) {
    final total = t[k]!;
    final n = lines.length;
    if (n > 0 && total.missing.length == n) return 'Not listed';
    final unit = const {'pro': ' g', 'carb': ' g', 'fat': ' g', 'na': ' mg'}[k] ?? '';
    final v = '${fmtNum(total.sum)}$unit';
    return total.missing.isEmpty ? v : '$v+';
  }
}
