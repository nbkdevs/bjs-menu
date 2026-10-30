/// Course role of a menu item.
enum Role { main, side, drink, dessert }

/// Nutrients, in display order.
enum Nutrient {
  cal('Calories', 'cal'),
  protein('Protein', 'g'),
  carbs('Carbs', 'g'),
  fat('Fat', 'g'),
  sodium('Sodium', 'mg');

  const Nutrient(this.label, this.unit);
  final String label;
  final String unit;
}

/// One BJ's menu item. `null` means the value is not published.
class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.role,
    this.cal,
    this.protein,
    this.carbs,
    this.fat,
    this.sodium,
    this.calText,
    this.perSlice = false,
    this.allergens,
  });

  final String id, name, category;
  final Role role;
  final int? cal, protein, carbs, fat, sodium;
  final String? calText;
  final bool perSlice;
  final List<String>? allergens;

  int? value(Nutrient n) => switch (n) {
        Nutrient.cal => cal,
        Nutrient.protein => protein,
        Nutrient.carbs => carbs,
        Nutrient.fat => fat,
        Nutrient.sodium => sodium,
      };

  @override
  String toString() => '$name ($category) - ${calText != null ? '$calText cal' : cal != null ? '$cal cal' : 'calories not listed'}';
}
