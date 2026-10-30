using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace BjsMenu.Nutrition;

/// <summary>Course role of a menu item.</summary>
public enum Role { Main, Side, Drink, Dessert }

/// <summary>Nutrients in display order.</summary>
public enum Nutrient { Calories, Protein, Carbs, Fat, Sodium }

/// <summary>One BJ's menu item. Null means the value is not published.</summary>
public sealed record MenuItem(string Id, string Name, string Category, Role Role, int? Calories, int? Protein, int? Carbs, int? Fat, int? Sodium, string? CaloriesText, bool PerSlice, string[]? Allergens)
{
    public int? Value(Nutrient n) => n switch
    {
        Nutrient.Calories => Calories, Nutrient.Protein => Protein, Nutrient.Carbs => Carbs, Nutrient.Fat => Fat, _ => Sodium,
    };

    public override string ToString() =>
        $"{Name} ({Category}) - {(CaloriesText != null ? CaloriesText + " cal" : Calories != null ? Calories + " cal" : "calories not listed")}";
}

/// <summary>Total for one nutrient. Items without a published value (or per slice) are listed in Missing.</summary>
public sealed class Total
{
    internal Total(Nutrient n, int lines) { Nutrient = n; Lines = lines; }
    public Nutrient Nutrient { get; }
    public int Lines { get; }
    public int Sum { get; internal set; }
    public List<string> Missing { get; } = new();
    public bool Partial => Missing.Count > 0;
    public bool Listed => Lines > 0 && Missing.Count < Lines;
    public string Unit => Nutrient switch { Nutrient.Calories => "cal", Nutrient.Sodium => "mg", _ => "g" };

    /// <summary>"3,210 cal", "68 g+" or "Not listed".</summary>
    public string Format() => !Listed ? "Not listed" : $"{Sum.ToString("N0", CultureInfo.InvariantCulture)} {Unit}{(Partial ? "+" : "")}";
}

/// <summary>A meal of menu items with quantities.</summary>
public sealed class Meal
{
    public List<(MenuItem Item, int Qty)> Lines { get; } = new();

    /// <summary>Add "2x Name", an id or a name. Quantity 1-99.</summary>
    public Meal Add(string line)
    {
        var (r, q) = Menu.ParseLine(line);
        var item = Menu.Find(r);
        if (q < 1 || q > 99) throw new ArgumentOutOfRangeException(nameof(line), $"Quantity for {item.Name} must be 1-99");
        Lines.Add((item, q));
        return this;
    }

    public IReadOnlyDictionary<Nutrient, Total> Totals()
    {
        var d = new Dictionary<Nutrient, Total>();
        foreach (Nutrient n in Enum.GetValues(typeof(Nutrient)))
        {
            var t = new Total(n, Lines.Count);
            foreach (var (item, qty) in Lines)
            {
                var v = item.Value(n);
                if (v == null || item.PerSlice) t.Missing.Add(item.Name); else t.Sum += v.Value * qty;
            }
            d[n] = t;
        }
        return d;
    }

    public IReadOnlyList<string> Allergens => Lines.Where(l => l.Item.Allergens != null).SelectMany(l => l.Item.Allergens!).Distinct().OrderBy(a => a, StringComparer.Ordinal).ToList();
    public IReadOnlyList<string> AllergenUnknown => Lines.Where(l => l.Item.Allergens == null).Select(l => l.Item.Name).ToList();
}

/// <summary>Search, lookup and filters over the bundled BJ's menu.</summary>
public static class Menu
{
    public static IReadOnlyList<MenuItem> Items => MenuData.Items;

    internal static string Norm(string s)
    {
        var low = s.ToLowerInvariant().Replace("'", "").Replace("\u2019", "").Replace("\u2018", "");
        return Regex.Replace(low, "[^a-z0-9]+", " ").Trim();
    }

    public static IReadOnlyList<MenuItem> Search(string query)
    {
        var q = Norm(query);
        if (q.Length == 0) return Array.Empty<MenuItem>();
        var words = q.Split(' ');
        return Items.Where(i => { var n = Norm(i.Name); return words.All(n.Contains); }).ToList();
    }

    /// <summary>Find by id, exact name, or a query matching exactly one item.</summary>
    public static MenuItem Find(string r)
    {
        var byId = Items.FirstOrDefault(i => i.Id == r);
        if (byId != null) return byId;
        var q = Norm(r);
        var exact = Items.FirstOrDefault(i => Norm(i.Name) == q);
        if (exact != null) return exact;
        var hits = Search(r);
        if (hits.Count == 1) return hits[0];
        if (hits.Count == 0) throw new KeyNotFoundException($"No menu item matches \"{r}\"");
        throw new ArgumentException($"\"{r}\" matches {hits.Count} items: {string.Join("; ", hits.Take(5).Select(h => h.Name))}");
    }

    public static (string Ref, int Qty) ParseLine(string text)
    {
        var m = Regex.Match(text, @"^\s*(\d+)\s*[xX\u00d7]\s+(.+)$");
        return m.Success ? (m.Groups[2].Value.Trim(), int.Parse(m.Groups[1].Value, CultureInfo.InvariantCulture)) : (text.Trim(), 1);
    }

    /// <summary>Items matching every limit. Unknown allergen info never passes a "without" filter.</summary>
    public static IReadOnlyList<MenuItem> Filter(int? maxCalories = null, int? minProtein = null, int? maxSodium = null, IEnumerable<string>? without = null, Role? role = null)
    {
        var wo = (without ?? Array.Empty<string>()).Select(Norm).Where(w => w.Length > 0).ToList();
        return Items.Where(i =>
        {
            if (role != null && i.Role != role) return false;
            if (maxCalories != null && (i.Calories == null || i.PerSlice || i.Calories > maxCalories)) return false;
            if (minProtein != null && (i.Protein == null || i.Protein < minProtein)) return false;
            if (maxSodium != null && (i.Sodium == null || i.Sodium > maxSodium)) return false;
            if (wo.Count > 0 && (i.Allergens == null || i.Allergens.Any(a => wo.Contains(Norm(a))))) return false;
            return true;
        }).ToList();
    }
}
