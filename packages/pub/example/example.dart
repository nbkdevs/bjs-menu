import 'package:bjs_menu_nutrition/bjs_menu_nutrition.dart';

void main() {
  final meal = Meal()
    ..add("BJ's Wagyu Burger")
    ..add('2x Avocado Egg Rolls');
  for (final t in meal.totals().values) {
    print('${t.nutrient.label}: ${t.format()}');
  }
  print('Allergens: ${meal.allergens.join(', ')}');
  print(filter(maxCal: 600, without: ['Milk'], role: Role.main).take(5).join('\n'));
}
