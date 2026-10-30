using BjsMenu.Nutrition;
using Xunit;

public class MenuTests
{
    [Fact] public void Dataset() => Assert.Equal(183, Menu.Items.Count);

    [Fact]
    public void Find()
    {
        Assert.Equal("bjs-0003", Menu.Find("bj's wagyu burger").Id);
        Assert.Throws<ArgumentException>(() => Menu.Find("burger"));
    }

    [Fact]
    public void Totals()
    {
        var t = new Meal().Add("BJ's Wagyu Burger").Add("2x Avocado Egg Rolls").Totals();
        Assert.Equal(3210, t[Nutrient.Calories].Sum);
        Assert.Equal("3,210 cal", t[Nutrient.Calories].Format());
    }

    [Fact]
    public void Partial()
    {
        var t = new Meal().Add("BJ's Wagyu Burger").Add("California Club Flatbread").Totals();
        Assert.Equal(new[] { "California Club Flatbread" }, t[Nutrient.Calories].Missing);
        Assert.Equal("1,230 cal+", t[Nutrient.Calories].Format());
    }

    [Fact]
    public void Filter()
    {
        var r = Menu.Filter(maxCalories: 500, without: new[] { "milk" });
        Assert.NotEmpty(r);
        Assert.All(r, i => { Assert.True(i.Calories <= 500); Assert.DoesNotContain("Milk", i.Allergens!); });
    }
}
