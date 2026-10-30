# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/bjs_menu_nutrition"

class TestBjsMenuNutrition < Minitest::Test
  M = BjsMenuNutrition

  def test_dataset = assert_equal(183, M.items.size)

  def test_find
    assert_equal "bjs-0003", M.find("bj's wagyu burger")["id"]
    assert_raises(M::Error) { M.find("burger") }
  end

  def test_total
    r = M.total(["BJ's Wagyu Burger", "2x Avocado Egg Rolls"])
    assert_equal 3210, r["totals"]["cal"]["sum"]
    assert_equal "3,210 cal", M.format_total(r["totals"]["cal"])
  end

  def test_partial
    r = M.total(["BJ's Wagyu Burger", "California Club Flatbread"])
    assert_equal ["California Club Flatbread"], r["totals"]["cal"]["missing"]
    assert_equal "1,230 cal+", M.format_total(r["totals"]["cal"])
  end

  def test_filter
    r = M.filter(max_cal: 500, without: ["milk"])
    refute_empty r
    assert(r.all? { |i| i["cal"] <= 500 && !i["allergens"].include?("Milk") })
  end
end
