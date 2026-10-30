import 'package:bjs_meal_builder/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('totals add quantities and mark per-slice items partial', () async {
    await Menu.load();
    final meal = Meal();
    final burger = Menu.byId['bjs-0003']!; // 1230 cal
    final wings = Menu.byId['bjs-0006']!; // 870 cal, main role
    meal.add(burger);
    expect(meal.fmt(meal.totals(), 'cal'), '1,230');
    meal.add(Menu.items.firstWhere((i) => i.role == 'drink' && i.cal != null));
    meal.inc(meal.extras.first);
    expect(meal.count, 3);
    meal.add(wings); // replaces main
    expect(meal.main, wings.id);
    meal.add(Menu.byId['bjs-0023']!); // per-slice flatbread replaces main
    expect(meal.fmt(meal.totals(), 'cal'), endsWith('+'));
    final snap = meal.clear();
    expect(meal.isEmpty, true);
    meal.restoreSnapshot(snap);
    expect(meal.count, 3);
  });
}
