import 'package:bjs_menu_nutrition/bjs_menu_nutrition.dart';
import 'package:test/test.dart';

void main() {
  test('dataset', () => expect(items.length, 183));
  test('find', () {
    expect(find("bj's wagyu burger").id, 'bjs-0003');
    expect(() => find('burger'), throwsArgumentError);
  });
  test('totals', () {
    final t = (Meal()..add("BJ's Wagyu Burger")..add('2x Avocado Egg Rolls')).totals();
    expect(t[Nutrient.cal]!.sum, 3210);
    expect(t[Nutrient.cal]!.format(), '3,210 cal');
  });
  test('partial', () {
    final t = (Meal()..add("BJ's Wagyu Burger")..add('California Club Flatbread')).totals();
    expect(t[Nutrient.cal]!.missing, ['California Club Flatbread']);
    expect(t[Nutrient.cal]!.format(), '1,230 cal+');
  });
  test('filter', () {
    final r = filter(maxCal: 500, without: ['milk']);
    expect(r, isNotEmpty);
    expect(r.every((i) => i.cal! <= 500 && !i.allergens!.contains('Milk')), isTrue);
  });
}
