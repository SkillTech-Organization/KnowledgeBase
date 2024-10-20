using FluentAssertions;
using WebApi.Exceptions;
using WebApi.ValueObjects;

namespace WebApi.Tests;

public class MoneyTests
{
    [Fact]
    public void Money_With5Dollars_ResultsInAnObject()
    {
        var money = new Money(5, Currency.Usd);

        money.Amount.Should().Be(5);
        money.Currency.Should().Be(Currency.Usd);
    }

    [Fact]
    public void Money_NegativeAmount_ThrowsAnException()
    {
        var action = () => new Money(-5, Currency.Usd);

        action.Should().Throw<InvalidMoneyException>();
    }

    [Fact]
    public void Addition_TwoPositiveNumbers_ResultsInAPositiveNumber()
    {
        var money1 = new Money(5, Currency.Usd);
        var money2 = new Money(2, Currency.Usd);

        var result = money1 + money2;

        result.Amount.Should().Be(7);
    }
}