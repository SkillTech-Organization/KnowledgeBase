using WebApi.Exceptions;

namespace WebApi.ValueObjects;

public sealed class Money
{
    public int Amount { get; }

    public Currency Currency { get; }

    public Money(int amount, Currency currency)
    {
        if (amount < 0)
        {
            throw InvalidMoneyException.InvalidAmount();
        }

        Amount = amount;
        Currency = currency;
    }

    public static Money operator +(Money a, Money b)
    {
        if (a.Currency != b.Currency)
        {
            // throw InvalidMoneyException.CurrencyMissmatch();
        }

        return new Money(a.Amount + b.Amount, a.Currency);
    }
}
