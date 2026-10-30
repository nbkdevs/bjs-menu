using BjsMenu.Nutrition;

if (args.Length == 0 || args[0] is "-h" or "--help")
{
    Console.WriteLine("Usage: dotnet run --project cli -- total \"BJ's Wagyu Burger\" \"2x Avocado Egg Rolls\" | search <words> | filter --max-cal 600 --without Milk");
    return 0;
}
try
{
    var rest = args.Skip(1).ToArray();
    string? Opt(string n) { var i = Array.IndexOf(rest, n); return i >= 0 && i + 1 < rest.Length ? rest[i + 1] : null; }
    int? Num(string n) => Opt(n) is { } v ? int.Parse(v) : null;
    switch (args[0])
    {
        case "total":
            var meal = new Meal();
            foreach (var a in rest) meal.Add(a);
            foreach (var (item, qty) in meal.Lines) Console.WriteLine($"{qty} x {item.Name}");
            Console.WriteLine();
            foreach (var t in meal.Totals().Values) Console.WriteLine($"{t.Nutrient,-9}{t.Format()}");
            var missing = meal.Totals().Values.SelectMany(t => t.Missing).Distinct().ToList();
            if (missing.Count > 0) Console.WriteLine($"\n+ partial: no published value (or per-slice only) for {string.Join("; ", missing)}");
            if (meal.Allergens.Count > 0) Console.WriteLine($"Allergens: {string.Join(", ", meal.Allergens)}");
            break;
        case "search":
            foreach (var i in Menu.Search(string.Join(" ", rest))) Console.WriteLine(i);
            break;
        case "filter":
            Role? role = Opt("--role") is { } r ? Enum.Parse<Role>(r, true) : null;
            foreach (var i in Menu.Filter(Num("--max-cal"), Num("--min-protein"), Num("--max-sodium"), Opt("--without")?.Split(','), role)) Console.WriteLine(i);
            break;
        default:
            Console.Error.WriteLine($"Unknown command {args[0]}");
            return 1;
    }
}
catch (Exception e) when (e is ArgumentException or KeyNotFoundException)
{
    Console.Error.WriteLine(e.Message);
    return 1;
}
return 0;
