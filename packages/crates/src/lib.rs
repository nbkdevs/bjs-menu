//! Offline BJ's Restaurant meal builder: total calories, protein, carbs, fat and sodium for a meal,
//! flag items with no published value, and filter menu items by calories and allergens.
//!
//! Data: published BJ's nutrition figures as collected by <https://bjsmenus.com/>.

mod data;

/// Course role of a menu item.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Role { Main, Side, Drink, Dessert }

impl Role {
    pub fn parse(s: &str) -> Option<Role> {
        match s.to_ascii_lowercase().as_str() {
            "main" => Some(Role::Main), "side" => Some(Role::Side),
            "drink" => Some(Role::Drink), "dessert" => Some(Role::Dessert), _ => None,
        }
    }
}

/// One menu item. `None` means the value is not published.
#[derive(Debug, Clone, PartialEq)]
pub struct Item {
    pub id: &'static str,
    pub name: &'static str,
    pub category: &'static str,
    pub role: Role,
    pub cal: Option<u32>,
    pub protein: Option<u32>,
    pub carbs: Option<u32>,
    pub fat: Option<u32>,
    pub sodium: Option<u32>,
    pub cal_text: Option<&'static str>,
    pub per_slice: bool,
    pub allergens: Option<&'static [&'static str]>,
}

/// Nutrients in display order.
pub const NUTRIENTS: [Nutrient; 5] = [Nutrient::Cal, Nutrient::Protein, Nutrient::Carbs, Nutrient::Fat, Nutrient::Sodium];

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Nutrient { Cal, Protein, Carbs, Fat, Sodium }

impl Nutrient {
    pub fn label(self) -> &'static str {
        match self { Nutrient::Cal => "Calories", Nutrient::Protein => "Protein", Nutrient::Carbs => "Carbs", Nutrient::Fat => "Fat", Nutrient::Sodium => "Sodium" }
    }
    pub fn unit(self) -> &'static str {
        match self { Nutrient::Cal => "cal", Nutrient::Sodium => "mg", _ => "g" }
    }
    fn of(self, i: &Item) -> Option<u32> {
        match self { Nutrient::Cal => i.cal, Nutrient::Protein => i.protein, Nutrient::Carbs => i.carbs, Nutrient::Fat => i.fat, Nutrient::Sodium => i.sodium }
    }
}

/// All menu items.
pub fn items() -> &'static [Item] { data::ITEMS }

fn norm(s: &str) -> String {
    let mut out = String::new();
    let mut space = false;
    for c in s.chars().flat_map(|c| c.to_lowercase()) {
        if c == '\'' || c == '\u{2019}' || c == '\u{2018}' { continue; }
        if c.is_ascii_alphanumeric() { if space && !out.is_empty() { out.push(' '); } space = false; out.push(c); } else { space = true; }
    }
    out
}

/// Items whose name contains every word of the query.
pub fn search(query: &str) -> Vec<&'static Item> {
    let q = norm(query);
    if q.is_empty() { return vec![]; }
    let words: Vec<&str> = q.split(' ').collect();
    items().iter().filter(|i| { let n = norm(i.name); words.iter().all(|w| n.contains(w)) }).collect()
}

/// Find one item by id, exact name, or a query matching exactly one item.
pub fn find(r: &str) -> Result<&'static Item, String> {
    if let Some(i) = items().iter().find(|i| i.id == r) { return Ok(i); }
    let q = norm(r);
    if let Some(i) = items().iter().find(|i| norm(i.name) == q) { return Ok(i); }
    let hits = search(r);
    match hits.len() {
        1 => Ok(hits[0]),
        0 => Err(format!("No menu item matches \"{r}\"")),
        n => Err(format!("\"{r}\" matches {n} items: {}", hits.iter().take(5).map(|h| h.name).collect::<Vec<_>>().join("; "))),
    }
}

/// Parse "2x Avocado Egg Rolls" into ("Avocado Egg Rolls", 2).
pub fn parse_line(text: &str) -> (String, u32) {
    let t = text.trim();
    if let Some(pos) = t.find(|c: char| !c.is_ascii_digit()) {
        if pos > 0 {
            let rest = &t[pos..];
            let rest2 = rest.trim_start();
            if let Some(after) = rest2.strip_prefix('x').or_else(|| rest2.strip_prefix('X')).or_else(|| rest2.strip_prefix('×')) {
                if after.starts_with(' ') {
                    if let Ok(q) = t[..pos].parse() { return (after.trim().to_string(), q); }
                }
            }
        }
    }
    (t.to_string(), 1)
}

/// Total for one nutrient.
#[derive(Debug, Clone, PartialEq)]
pub struct Total { pub nutrient: Nutrient, pub sum: u32, pub missing: Vec<&'static str>, pub lines: usize }

impl Total {
    pub fn partial(&self) -> bool { !self.missing.is_empty() }
    pub fn listed(&self) -> bool { self.lines > 0 && self.missing.len() < self.lines }
    /// "3,210 cal", "68 g+", or "Not listed".
    pub fn format(&self) -> String {
        if !self.listed() { return "Not listed".into(); }
        format!("{} {}{}", thousands(self.sum), self.nutrient.unit(), if self.partial() { "+" } else { "" })
    }
}

fn thousands(n: u32) -> String {
    let s = n.to_string();
    let mut out = String::new();
    for (i, c) in s.chars().enumerate() { if i > 0 && (s.len() - i) % 3 == 0 { out.push(','); } out.push(c); }
    out
}

/// A meal: items with quantities.
#[derive(Debug, Clone, Default)]
pub struct Meal { pub lines: Vec<(&'static Item, u32)> }

impl Meal {
    pub fn new() -> Self { Self::default() }
    /// Add by reference ("2x Name", id or name). Quantity 1-99.
    pub fn add(&mut self, line: &str) -> Result<&mut Self, String> {
        let (r, q) = parse_line(line);
        let item = find(&r)?;
        if !(1..=99).contains(&q) { return Err(format!("Quantity for {} must be 1-99", item.name)); }
        self.lines.push((item, q));
        Ok(self)
    }
    /// Per-nutrient totals. Items with no published value, or listed per slice, are not added and are named in `missing`.
    pub fn totals(&self) -> Vec<Total> {
        NUTRIENTS.iter().map(|&n| {
            let mut t = Total { nutrient: n, sum: 0, missing: vec![], lines: self.lines.len() };
            for (i, q) in &self.lines {
                match n.of(i) { Some(v) if !i.per_slice => t.sum += v * q, _ => t.missing.push(i.name) }
            }
            t
        }).collect()
    }
    /// Union of listed allergens, and names of items with no allergen info.
    pub fn allergens(&self) -> (Vec<&'static str>, Vec<&'static str>) {
        let mut set: Vec<&'static str> = vec![];
        let mut unknown = vec![];
        for (i, _) in &self.lines {
            match i.allergens { Some(a) => for x in a { if !set.contains(x) { set.push(x) } }, None => unknown.push(i.name) }
        }
        set.sort();
        (set, unknown)
    }
}

/// Filter options; `None` means no limit.
#[derive(Debug, Clone, Default)]
pub struct Filter { pub max_cal: Option<u32>, pub min_protein: Option<u32>, pub max_sodium: Option<u32>, pub without: Vec<String>, pub role: Option<Role> }

/// Items matching every limit. Items with unknown allergen info are excluded when `without` is set.
pub fn filter(f: &Filter) -> Vec<&'static Item> {
    let wo: Vec<String> = f.without.iter().map(|w| norm(w)).collect();
    items().iter().filter(|i| {
        if let Some(r) = f.role { if i.role != r { return false; } }
        if let Some(m) = f.max_cal { match i.cal { Some(c) if !i.per_slice && c <= m => {}, _ => return false } }
        if let Some(m) = f.min_protein { match i.protein { Some(p) if p >= m => {}, _ => return false } }
        if let Some(m) = f.max_sodium { match i.sodium { Some(s) if s <= m => {}, _ => return false } }
        if !wo.is_empty() {
            match i.allergens { None => return false, Some(a) => if a.iter().any(|x| wo.contains(&norm(x))) { return false } }
        }
        true
    }).collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test] fn dataset() { assert_eq!(items().len(), 183); }
    #[test] fn find_works() { assert_eq!(find("bj's wagyu burger").unwrap().id, "bjs-0003"); assert!(find("burger").is_err()); }
    #[test] fn parse() { assert_eq!(parse_line("2x Avocado Egg Rolls"), ("Avocado Egg Rolls".into(), 2)); assert_eq!(parse_line("Boneless Wings").1, 1); }
    #[test] fn totals() {
        let mut m = Meal::new();
        m.add("BJ's Wagyu Burger").unwrap(); m.add("2x Avocado Egg Rolls").unwrap();
        let t = m.totals();
        assert_eq!(t[0].sum, 3210); assert_eq!(t[0].format(), "3,210 cal");
    }
    #[test] fn partial() {
        let mut m = Meal::new();
        m.add("BJ's Wagyu Burger").unwrap(); m.add("California Club Flatbread").unwrap();
        let t = m.totals();
        assert_eq!(t[0].missing, vec!["California Club Flatbread"]); assert_eq!(t[0].format(), "1,230 cal+");
    }
    #[test] fn filter_allergens() {
        let r = filter(&Filter { max_cal: Some(500), without: vec!["milk".into()], ..Default::default() });
        assert!(!r.is_empty());
        assert!(r.iter().all(|i| i.cal.unwrap() <= 500 && !i.allergens.unwrap().contains(&"Milk")));
    }
}
