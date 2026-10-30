require_relative "lib/bjs_menu_nutrition/version"

Gem::Specification.new do |spec|
  spec.name = "bjs_menu_nutrition"
  spec.version = BjsMenuNutrition::VERSION
  spec.authors = ["BJ's Menus"]
  spec.summary = "Offline BJ's Restaurant meal builder: nutrition totals, missing-value flags and allergen filters."
  spec.description = "Total calories, protein, carbs, fat and sodium for a BJ's Restaurant meal, see which items have no " \
                     "published value, and filter the menu by calories, protein, sodium and allergens. Library and CLI."
  spec.homepage = "https://bjsmenus.com/"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"
  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/nbkdevs/bjs-menu/tree/main/packages/rubygems",
    "bug_tracker_uri" => "https://github.com/nbkdevs/bjs-menu/issues",
    "rubygems_mfa_required" => "true"
  }
  spec.files = Dir["lib/**/*.rb", "lib/**/*.json", "exe/*", "README.md", "LICENSE"]
  spec.bindir = "exe"
  spec.executables = ["bjs-menu-nutrition"]
  spec.require_paths = ["lib"]
end
