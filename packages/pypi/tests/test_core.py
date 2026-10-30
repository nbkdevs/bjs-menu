import pytest

import bjs_menu_nutrition as m


def test_dataset():
    assert len(m.items()) == 183


def test_find():
    assert m.find("bj's wagyu burger")["id"] == "bjs-0003"
    with pytest.raises(LookupError):
        m.find("burger")


def test_total():
    r = m.total(["BJ's Wagyu Burger", "2x Avocado Egg Rolls"])
    assert r["totals"]["cal"]["sum"] == 1230 + 2 * 990
    assert m.format_total(r["totals"]["cal"]) == "3,210 cal"


def test_partial():
    r = m.total(["BJ's Wagyu Burger", "California Club Flatbread"])
    assert r["totals"]["cal"]["missing"] == ["California Club Flatbread"]
    assert m.format_total(r["totals"]["cal"]) == "1,230 cal+"


def test_filter():
    res = m.filter_items(max_cal=500, without=["milk"])
    assert res
    assert all(i["allergens"] is not None and "Milk" not in i["allergens"] and i["cal"] <= 500 for i in res)


def test_bad_qty():
    with pytest.raises(ValueError):
        m.total([("bjs-0003", 0)])
