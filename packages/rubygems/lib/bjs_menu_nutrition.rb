# frozen_string_literal: true

require "json"
require_relative "bjs_menu_nutrition/version"

# Offline BJ's Restaurant meal builder: nutrition totals, missing-value flags,
# search and calorie/allergen filters. Data collected by https://bjsmenus.com/.
module BjsMenuNutrition
  NUTRIENTS = %w[cal protein carbs fat sodium].freeze
  UNITS = { "cal" => "cal", "protein" => "g", "carbs" => "g", "fat" => "g", "sodium" => "mg" }.freeze
  DATA = JSON.parse(File.read(File.join(__dir__, "bjs_menu_nutrition", "menu.json"), encoding: "utf-8")).freeze
  ITEMS = DATA["items"].freeze

  class Error < StandardError; end

  module_function

  def norm(str)
    str.to_s.downcase.delete("'\u2018\u2019").gsub(/[^a-z0-9]+/, " ").strip
  end

  def items = ITEMS

  def categories = ITEMS.map { |i| i["category"] }.uniq

  def search(query)
    q = norm(query)
    return [] if q.empty?

    words = q.split(" ")
    ITEMS.select { |i| n = norm(i["name"]); words.all? { |w| n.include?(w) } }
  end

  # Find by id, exact name, or a query that matches exactly one item.
  def find(ref)
    hit = ITEMS.find { |i| i["id"] == ref } || ITEMS.find { |i| norm(i["name"]) == norm(ref) }
    return hit if hit

    hits = search(ref)
    return hits.first if hits.size == 1
    raise Error, %(No menu item matches "#{ref}") if hits.empty?

    raise Error, %("#{ref}" matches #{hits.size} items: #{hits.first(5).map { |h| h["name"] }.join("; ")})
  end

  # "2x Avocado Egg Rolls" => ["Avocado Egg Rolls", 2]
  def parse_line(text)
    m = /\A\s*(\d+)\s*[xX\u00d7]\s+(.+)\z/.match(text)
    m ? [m[2].strip, m[1].to_i] : [text.strip, 1]
  end

  # Total a meal. Items with no published value for a nutrient, or listed per slice,
  # are not added and are named in "missing"; the total is then partial.
  def total(lines)
    resolved = lines.map do |l|
      ref, qty = l.is_a?(String) ? parse_line(l) : l
      item = find(ref)
      raise Error, "Quantity for #{item["name"]} must be 1-99" unless qty.is_a?(Integer) && qty.between?(1, 99)

      [item, qty]
    end
    totals = NUTRIENTS.to_h do |k|
      sum = 0
      missing = []
      resolved.each { |item, qty| item[k].nil? || item["perSlice"] ? missing << item["name"] : sum += item[k] * qty }
      [k, { "sum" => sum, "unit" => UNITS[k], "missing" => missing, "partial" => !missing.empty?,
            "listed" => !resolved.empty? && missing.size < resolved.size }]
    end
    known = resolved.reject { |i, _| i["allergens"].nil? }
    { "lines" => resolved.map { |i, q| { "name" => i["name"], "qty" => q } }, "totals" => totals,
      "allergens" => known.flat_map { |i, _| i["allergens"] }.uniq.sort,
      "allergen_unknown" => resolved.select { |i, _| i["allergens"].nil? }.map { |i, _| i["name"] } }
  end

  # Items matching every limit. Unknown allergen info never passes a without: filter.
  def filter(max_cal: nil, min_protein: nil, max_sodium: nil, without: [], role: nil)
    wo = without.map { |w| norm(w) }.reject(&:empty?)
    ITEMS.select do |i|
      next false if role && i["role"] != role
      next false if max_cal && (i["cal"].nil? || i["perSlice"] || i["cal"] > max_cal)
      next false if min_protein && (i["protein"].nil? || i["protein"] < min_protein)
      next false if max_sodium && (i["sodium"].nil? || i["sodium"] > max_sodium)
      next false if !wo.empty? && (i["allergens"].nil? || i["allergens"].any? { |a| wo.include?(norm(a)) })

      true
    end
  end

  def format_total(tot)
    return "Not listed" unless tot["listed"]

    n = tot["sum"].round.to_s.reverse.scan(/\d{1,3}/).join(",").reverse
    "#{n} #{tot["unit"]}#{"+" if tot["partial"]}"
  end

  def row(item)
    cal = item["calText"] ? "#{item["calText"]} cal" : (item["cal"] ? "#{item["cal"]} cal" : "calories not listed")
    "#{item["name"]} (#{item["category"]}) - #{cal}"
  end
end
