use bjs_menu_nutrition::{filter, find, items, search, Filter, Meal, Role};
use std::process::exit;

const HELP: &str = "bjs-menu-nutrition - BJ's Restaurant meal nutrition totals (offline)

Usage:
  bjs-menu-nutrition total \"BJ's Wagyu Burger\" \"2x Avocado Egg Rolls\"
  bjs-menu-nutrition search <words>
  bjs-menu-nutrition filter [--max-cal N] [--min-protein N] [--max-sodium N] [--without Milk,Wheat] [--role main|side|drink|dessert]
  bjs-menu-nutrition categories";

fn row(i: &bjs_menu_nutrition::Item) -> String {
    let cal = match (i.cal_text, i.cal) { (Some(t), _) => format!("{t} cal"), (None, Some(c)) => format!("{c} cal"), _ => "calories not listed".into() };
    format!("{} ({}) - {}", i.name, i.category, cal)
}

fn main() {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let Some(cmd) = args.first() else { println!("{HELP}"); return };
    let rest = &args[1..];
    let fail = |e: String| -> ! { eprintln!("{e}"); exit(1) };
    match cmd.as_str() {
        "total" => {
            if rest.is_empty() { fail("Give at least one item".into()) }
            let mut m = Meal::new();
            for a in rest { if let Err(e) = m.add(a) { fail(e) } }
            for (i, q) in &m.lines { println!("{q} x {}", i.name); }
            println!();
            let totals = m.totals();
            let mut missing: Vec<&str> = vec![];
            for t in &totals {
                println!("{:<9}{}", t.nutrient.label(), t.format());
                for n in &t.missing { if !missing.contains(n) { missing.push(n) } }
            }
            if !missing.is_empty() { println!("\n+ partial: no published value (or per-slice only) for {}", missing.join("; ")); }
            let (al, unknown) = m.allergens();
            if !al.is_empty() { println!("Allergens: {}", al.join(", ")); }
            if !unknown.is_empty() { println!("Allergens not listed for: {}", unknown.join("; ")); }
        }
        "search" => for i in search(&rest.join(" ")) { println!("{}", row(i)) },
        "find" => match find(&rest.join(" ")) { Ok(i) => println!("{}", row(i)), Err(e) => fail(e) },
        "filter" => {
            let mut f = Filter::default();
            let mut it = rest.iter();
            while let Some(a) = it.next() {
                let v = it.next().cloned().unwrap_or_default();
                let num = |v: &str| v.parse::<u32>().unwrap_or_else(|_| { eprintln!("{a} needs a number"); exit(1) });
                match a.as_str() {
                    "--max-cal" => f.max_cal = Some(num(&v)),
                    "--min-protein" => f.min_protein = Some(num(&v)),
                    "--max-sodium" => f.max_sodium = Some(num(&v)),
                    "--without" => f.without = v.split(',').map(|s| s.trim().to_string()).filter(|s| !s.is_empty()).collect(),
                    "--role" => f.role = Some(Role::parse(&v).unwrap_or_else(|| { eprintln!("unknown role {v}"); exit(1) })),
                    _ => fail(format!("unknown option {a}")),
                }
            }
            for i in filter(&f) { println!("{}", row(i)) }
        }
        "categories" => { let mut seen: Vec<&str> = vec![]; for i in items() { if !seen.contains(&i.category) { seen.push(i.category); println!("{}", i.category) } } }
        "-h" | "--help" => println!("{HELP}"),
        _ => fail(format!("Unknown command \"{cmd}\"\n\n{HELP}")),
    }
}
